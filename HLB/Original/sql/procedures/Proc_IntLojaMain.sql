GO
/****** Object:  StoredProcedure [PROC_INTLOJAMAIN].[PROC_INTLOJAMAIN]    Script Date: 07/07/2016 22:37:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Procedure......: PROC_INTLOJAMAIN
Objetivo.......: Integrar para o Protheus Xml de Cupom Fiscal 
Autor..........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...........: 10/06/2016
*/

/*
ATENCAO:
1 - permissão de pasta compartilhada, deve estar compartilhada com o usuario usado no xp_cmdshell, 
para saber o usuario, execute o comando abaixo e depois adicione na segurança de pasta do windows
EXEC xp_cmdshell 'osql -E -Q "SUSER_SNAME select ()" '

2- a pasta compartilhada no server do SQL deve estar compartilhada com permissão para 'EVERYONE' tambem.

3- Habilitar o comando xp_cmdshell no SQL com o script abaixo
USE master 
GO 
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE WITH OVERRIDE 
GO
EXEC sp_configure 'show advanced options', 0
GO 
RECONFIGURE WITH OVERRIDE 
GO

*/

ALTER PROCEDURE [dbo].[PROC_INTLOJAMAIN] 
 
As
Declare @dirxml Varchar( 300 )
Declare @dirtxt Varchar( 300 )
Declare @arqxml Varchar( 300 )
Declare @arqtxt Varchar( 300 )
Declare @arqINI Varchar( 300 )
Declare @fullnamexml Varchar( 500 )
Declare @fullnametxt Varchar( 500 )
Declare @xml Varchar( MAX )
Declare @txt Varchar( MAX )
Declare @xml2 Xml
Declare @sql nVarchar( MAX )
Declare @dirdest Varchar( 500 )
Declare @command Varchar( 500 )
Declare @cnpjemp Varchar( 14 )
Declare @emissao Varchar( 08 )
Declare @TEMP Table  (subdirectory varchar(MAX), depth int,isfile bit)
      
Begin
	--Diretorio onde estao localizados os arquivos .xml de cupom fiscal
	SET @dirxml = '\\SQLTB717\Temp\REXGT'
	SET @dirtxt = '\\SQLTB717\temp\txt'
	SET @arqINI = '\\SQLTB717\temp\txt\param.ini'

	/*Verifica os parametros Passados pelo Protheus para o Banco, via arquivo INI*/
	IF OBJECT_ID('PARAMINI') IS NOT NULL
		DROP TABLE PARAMINI
	IF OBJECT_ID('LINHA') IS NOT NULL
		DROP TABLE LINHA
	
	--Valida se o arquivo INI existe e inicia o processamento
	DECLARE @result INT
    EXEC master.dbo.xp_fileexist @arqINI, @result OUTPUT
    IF @result = 1
		Begin
			CREATE TABLE LINHA ( LIN VARCHAR( MAX ) )
			SET @sql = N'BULK INSERT LINHA FROM ''' + @arqINI + '''' 
			EXEC sp_executesql @sql 
			SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,1,2) as EMP,
					SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,3,30) as PAR,
					SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,33,250) as CONT,
					ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO PARAMINI 
			FROM LINHA
			IF OBJECT_ID('LINHA') IS NOT NULL
				DROP TABLE LINHA
			
			SET @command = 'del '+@arqINI
			EXEC master.dbo.xp_cmdshell @command, no_output 
		End

	/*	*** Inicio Leitura arquivos Xml ***/
	/*	Grava retorno da procedure xp_dirtree na tabela temporaria */
	INSERT @TEMP (subdirectory,depth,isfile)
	EXEC master.dbo.xp_dirtree @dirxml, 1, 1  
	DELETE FROM @TEMP WHERE CHARINDEX( '.XML' , UPPER( subdirectory ) ) = 0
	While ( SELECT COUNT(*) FROM @TEMP ) > 0
		Begin 
			SELECT TOP 1 @arqxml = subdirectory FROM @TEMP
			SET @fullnamexml = RTRIM(@dirxml)+'\'+RTRIM(@arqxml)
			SET @sql = N'SELECT @xmlOut = CAST(BulkColumn AS VARCHAR(MAX) )
			FROM OPENROWSET(BULK ''' + @fullnamexml + ''', SINGLE_BLOB)
			AS Arquivo' 
			EXEC sp_executesql @sql , N'@xmlOut Varchar(max) Output' ,@xmlOut = @xml OUTPUT  
 			EXEC dbo.Proc_IntLoja @xml , @arqxml
			DELETE FROM @TEMP WHERE subdirectory = @arqxml 
			--Configura diretorio de destino dinamicamente
			SET @xml2 = @xml 
			SELECT 
				@cnpjemp = X.emit.query('CNPJ').value('.', 'CHAR(14)'),		
				@emissao = X.emit.query('../ide/dEmi').value('.', 'CHAR(08)')
			FROM @xml2.nodes( 'CFe/infCFe/emit') AS X(emit)	
			SET @dirdest = 'C:\' + @cnpjemp + '\' + SUBSTRING(@emissao,1,4) + '\' + SUBSTRING(@emissao,5,2)+ '\' + @emissao + '\xml'
			EXEC sys.xp_create_subdir @dirdest
			--Move arquivo processado
			SET @command = 'move ' + @fullnamexml + ' ' + @dirdest 
			EXEC sys.xp_cmdshell @command , no_output  
		End
	DELETE FROM @TEMP 

	/****  Inicio Leitura arquivos Txt ***/
	INSERT @TEMP (subdirectory,depth,isfile)
	EXEC master.dbo.xp_dirtree @dirtxt, 1, 1  
	--DELETE FROM @TEMP WHERE NOT ( CHARINDEX( '.12G' , UPPER( subdirectory ) ) > 0 OR  CHARINDEX( '.22G' , UPPER( subdirectory ) ) > 0 )
	DELETE FROM @TEMP WHERE CHARINDEX( '.INI' , UPPER( subdirectory ) ) > 0
	While ( SELECT COUNT(*) FROM @TEMP ) > 0
		Begin 
			SELECT TOP 1 @arqtxt = subdirectory FROM @TEMP
			SET @fullnametxt = RTRIM(@dirtxt)+'\'+RTRIM(@arqtxt)
 			--Executa procedure para gravação do cupom 
			EXEC dbo.Proc_IntLojaTxt @fullnametxt , @arqtxt
			DELETE FROM @TEMP WHERE subdirectory = @arqtxt 

			SET @command = 'del '+@fullnametxt
			EXEC master.dbo.xp_cmdshell @command, no_output 
		End

	IF OBJECT_ID('PARAMINI') IS NOT NULL
		DROP TABLE PARAMINI
End