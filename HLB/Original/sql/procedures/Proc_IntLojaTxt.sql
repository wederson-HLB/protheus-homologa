--http://www.fazenda.sp.gov.br/publicacao/noticia.aspx?id=571
GO
/****** Object:  StoredProcedure [dbo].[Proc_IntLojaTxt]    Script Date: 07/08/2016 09:35:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Procedure......: Proc_IntLojaTxt
Objetivo.......: Integrar para o Protheus Txt de Cupom Fiscal 
Autor..........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...........: 04/07/2016
*/
ALTER PROCEDURE [dbo].[Proc_IntLojaTxt] (
	@fullnametxt VARCHAR( MAX ) , 
	@txtarq VARCHAR(200) 
)

AS
DECLARE @sql NVARCHAR( MAX )
DECLARE @serpdv VARCHAR( 20 )
DECLARE @pdv VARCHAR( 03 )
DECLARE @linha VARCHAR( MAX )
DECLARE @reg INTEGER
DECLARE @reg2 INTEGER
DECLARE @emp VARCHAR(2)
DECLARE @fil VARCHAR(2)
DECLARE @cnpjcli VARCHAR( 14 )
DECLARE @cnpjemp VARCHAR( 14 )
DECLARE @txtcont NVARCHAR( max ) = ''
DECLARE @count INTEGER
DECLARE @filsl VARCHAR( 02 )   = '01' 
DECLARE @filsa1 VARCHAR( 02 ) = '  '
DECLARE @filsb1 VARCHAR( 02 )  = '  '
DECLARE @doc VARCHAR(06)
DECLARE @chvnfe VARCHAR(44) = ''
DECLARE @item VARCHAR(2) 
DECLARE @totalcanc NUMERIC( 13,2) 

DECLARE @xnome VARCHAR( 40 )
DECLARE @xlgr VARCHAR( 60 ) = ''
DECLARE @xcpl VARCHAR( 50 ) = ''
DECLARE @xbairro VARCHAR( 30 ) = ''
DECLARE @xmun VARCHAR( 60 ) = ''
DECLARE @cep VARCHAR( 8 ) = ''
DECLARE @ie VARCHAR( 18 ) = ''
DECLARE @cprod VARCHAR( 15 ) 
DECLARE @xprod VARCHAR( 15 )
DECLARE @itemCancel VARCHAR( 1 )
DECLARE @ncm VARCHAR( 10 )
DECLARE @codcli VARCHAR( 06 )
DECLARE @pessoa VARCHAR( 01 )
DECLARE @numorc VARCHAR( 06 )
DECLARE @loja VARCHAR( 02 )
DECLARE @dtmovto VARCHAR( 08 )
DECLARE @emissao VARCHAR( 08 )
DECLARE @hora VARCHAR( 06 )
DECLARE @cpf VARCHAR( 11 )
DECLARE @tipocli CHAR( 1 )
DECLARE @total NUMERIC(15,2)
DECLARE @descont NUMERIC(15,2)
DECLARE @descit NUMERIC(15,2)
DECLARE @totalit NUMERIC(15,2)
DECLARE @formpagto VARCHAR( 30 ) 
--DECLARE @adminis VARCHAR( 30 )
--DECLARE @val_mpagto NUMERIC(13,2)
DECLARE @seqarq INTEGER = 0
DECLARE @sittrib VARCHAR(05)
DECLARE @prcven NUMERIC(8,2)
DECLARE @quant NUMERIC(7,2)
DECLARE @unid VARCHAR(02)
DECLARE @tes VARCHAR(03) 
DECLARE @cancel VARCHAR(01)
DECLARE @situa VARCHAR(02)
DECLARE @situaItem VARCHAR(02)
DECLARE @newsitua VARCHAR(02) = 'RX'
DECLARE @campos_sfi VARCHAR(300)
DECLARE @cont_sfi VARCHAR(300)
DECLARE @numero_sfi VARCHAR(06)
DECLARE @coo VARCHAR(06)
DECLARE @numcupini VARCHAR(06)
DECLARE @numcupfim VARCHAR(06)
DECLARE @sb1grava VARCHAR( 03 )

IF OBJECT_ID('#E02') IS NOT NULL
	DROP TABLE #E02
IF OBJECT_ID('#E12') IS NOT NULL
	DROP TABLE #E12
IF OBJECT_ID('#E13') IS NOT NULL
	DROP TABLE #E13
IF OBJECT_ID('#E14') IS NOT NULL
	DROP TABLE #E14
IF OBJECT_ID('#E15') IS NOT NULL
	DROP TABLE #E15
IF OBJECT_ID('#E21') IS NOT NULL
	DROP TABLE #E21
IF OBJECT_ID('LINHA2') IS NOT NULL
	DROP TABLE LINHA2
IF OBJECT_ID('LINHA') IS NOT NULL
	DROP TABLE LINHA
	
CREATE TABLE LINHA ( LIN VARCHAR( MAX ) )

BEGIN
	BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;

		SET @sql = N'BULK INSERT LINHA FROM ''' + @fullnametxt + '''' 
		EXEC sp_executesql @sql 
		SELECT LIN,ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO LINHA2 FROM LINHA

		--Definição de variaveis
		SELECT	@cnpjemp= SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,45	,14),
				@serpdv = SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4	,20),
				@xlgr	= SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,113,120),
				@xnome	= SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,73	,40)
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E02'

		--Atribui para a Tabela E02
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) as E02_SERPDV,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,45,14) as E02_CGC,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,59,14) as E02_IE,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,73,40) as E02_NOMEEMP,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,113,120) as E02_ENDEMP,
				ROW_NUMBER() OVER ( ORDER BY LIN ) as E02_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E02 
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E02'

		--Atribui para a Tabela E12
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) as E12_SERPDV,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,47,06) as E12_NUMERO,			
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,53,06) as E12_COO,	
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,65,08) as E12_DTMOVTO,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,73,08) as E12_EMISSAO,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,81,06) as E12_HORA,
				CONVERT(NUMERIC(14,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,87,12)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,99,02)) as E12_VALCONT,				
				ROW_NUMBER() OVER ( ORDER BY LIN ) as E12_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E12
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E12'	

		--Atribui para a Tabela E13
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) as E13_SERPDV,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,47,06) as E13_NUMERO,			
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,53,07) as E13_TIPOTOT,	
				CONVERT(NUMERIC(13,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,60,11)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,71,02)) as E13_VALPARC,				
				ROW_NUMBER() OVER ( ORDER BY LIN ) as E13_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E13
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E13'

		--Atribui para a Tabela E14
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) AS E14_SERPDV ,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,47,06) AS E14_DOC,			
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,59,08) AS E14_EMISSAO,	
				CONVERT(NUMERIC(14,2),SUBSTRING(REPLACE(LIN,CHAR(39),' '),109,12)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' '),121,02)) AS E14_VALMERC,				
				CONVERT(NUMERIC(14,2),SUBSTRING(REPLACE(LIN,CHAR(39),' '),81,11)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' '),92,02)) AS E14_DESCONT,				
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,94,1) AS E14_TP_DESC,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,123,1) AS E14_P_CANC,						
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,138,40) AS E14_NOMECLI,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,178,14) AS E14_CNPJCLI,
				ROW_NUMBER() OVER ( ORDER BY LIN ) AS E14_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E14
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E14'

		--Atribui para a Tabela E15
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) as E15_SERPDV,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,53,06) as E15_DOC,			
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,59,03) as E15_ITEM,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,62,14) as E15_PRODUTO,				
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,76,100) as E15_DESCRI,							
				CONVERT(NUMERIC(7,3),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,176,04)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,180,03)) as E15_QUANT,				
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,183,3) as E15_UM,							
				CONVERT(NUMERIC(8,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,186,06)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,192,02)) as E15_VRUNIT,				
				CONVERT(NUMERIC(8,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,194,06)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,200,02)) as E15_DESC,							
				CONVERT(NUMERIC(14,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,210,12)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,222,02)) as E15_VLRITEM,										
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,231,1)as E15_P_CANC,
				CONVERT(NUMERIC(7,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,232,05)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,237,02)) as E15_P_QTDCANC,							
				CONVERT(NUMERIC(13,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,239,11)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,250,02) )as E15_P_VLCANC,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,226,05) as E15_SITTRIB,							
				ROW_NUMBER() OVER ( ORDER BY LIN ) as E15_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E15
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E15'

		--Atribui para a Tabela E15A (tabela para tratamento do SB1
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,62,14) as E15_PRODUTO,				
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,76,100) as E15_DESCRI,							
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,183,3) as E15_UM
				INTO #E15TEMP
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E15'
		GROUP BY SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,62,14),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,76,100),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,183,3)

		SELECT	*
		INTO #E15A
		FROM (SELECT DISTINCT A.E15_PRODUTO , B.E15_DESCRI, A.E15_UM	
				FROM #E15TEMP AS A 
				CROSS APPLY (SELECT TOP(1) B.E15_PRODUTO, B.E15_DESCRI FROM #E15TEMP AS B WHERE B.E15_PRODUTO = A.E15_PRODUTO) AS B) AS TAB

		--Atribui para a Tabela E21'  /* Forma de Pagamento */
		SELECT	SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,4,20) as E21_SERPDV,
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,53,06) as E21_DOC,			
				SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,65,15) as E21_FORMA,
				CONVERT(NUMERIC(13,2),SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,80,11)+'.'+SUBSTRING(REPLACE(LIN,CHAR(39),' ')	,91,02)) as E21_VALOR,
				ROW_NUMBER() OVER ( ORDER BY LIN )	as 	E21_SEQ,
				ROW_NUMBER() OVER ( ORDER BY LIN ) REG INTO #E21	
		FROM LINHA
		WHERE LEFT( LIN,3 )  = 'E21'

		IF OBJECT_ID('LINHA2') IS NOT NULL
			DROP TABLE LINHA2
		IF OBJECT_ID('LINHA') IS NOT NULL
			DROP TABLE LINHA

		--Busca qual empresa serão gravado os dados
 		SELECT @emp = M0_CODIGO,
			 @fil = M0_CODFIL FROM SIGAMAT WHERE M0_CGC = @cnpjemp
		IF ( @emp IS NULL )
			BEGIN
				SET @sql = N'INSERT INTO LOGLOJA ( DATA, ARQ, LOGARQ,XML) 
								VALUES ( ''' + REPLACE(CONVERT(char(10),GETDATE()  , 102 ),'.','')+''','''+@txtarq+''',
								''CNPJ ' + @cnpjemp  + ' nao encontrado na tabela SIGAMAT do banco de dados. '','''+@txtcont + ''')'
				EXEC( @sql )
				WHILE ( @@TRANCOUNT > 0 )
					BEGIN
						COMMIT TRAN
					END 
				RETURN
			END

		--Definição de variaveis com base no parametros Protheus
		IF OBJECT_ID('PARAMINI') IS NOT NULL
			Begin
				SELECT TOP 1 @newsitua=CONT From PARAMINI where EMP = @emp AND PAR = 'SITUA'
				IF @newsitua is null
					Begin
						SET @newsitua = 'RX'
					End

				SELECT TOP 1 @filsa1=CONT From PARAMINI where EMP = @emp  AND PAR = 'SA1_FILIAL'
				IF @newsitua is null
					Begin
						SET @filsa1 = '  '
					End

				SELECT TOP 1 @filsb1=CONT From PARAMINI where EMP = @emp AND PAR = 'SB1_FILIAL'
				IF @newsitua is null
					Begin
						SET @filsb1 = '  '
					End

				SELECT TOP 1 @filsl=CONT From PARAMINI where EMP = @emp AND PAR = 'SL_FILIAL'
				IF @newsitua is null
					Begin
						SET @filsl = '01'
					End
				
				SELECT TOP 1 @sb1grava=RTRIM(CONT) From PARAMINI where EMP = @emp AND PAR = 'SB1_GRAVA'
				IF @sb1grava is null
					Begin
						SET @sb1grava = 'NAO'
					End
			End
		ELSE
			Begin
				SET @sb1grava = 'NAO'
			End

		--Busca numero do PDV na SLG ( LG_SERPDV )
		SET @sql = N'SELECT @Intpdv=LG_CODIGO FROM SLG' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND LG_SERPDV = @Intserpdv AND LG_FILIAL = @Intfilsl'
		EXEC sp_executesql @sql , N'@Intserpdv VARCHAR(20),@Intfilsl VARCHAR(02),@Intpdv VARCHAR(03) OUTPUT' ,
															 @Intserpdv=@serpdv ,@Intfilsl=@filsl,@Intpdv = @pdv OUTPUT 
	
		IF ( @pdv IS NULL )
			BEGIN
				SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,D_E_L_E_T_,R_E_C_N_O_ ) 
								VALUES (''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''','''+@txtarq+''',''PDV nao encontrado para o ECF numero '
								+@serpdv+''','''+@txtcont+''','' '',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM Z99'+@emp+'0))' 
				EXEC( @sql )
				WHILE ( @@TRANCOUNT > 0 )
					BEGIN
						COMMIT TRAN
					END 
				RETURN
			END	

		--Caso numero do documento ja esteja na SL1, nao grava para evitar duplicidade
		SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,R_E_C_N_O_ )
						SELECT ''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''',''arquivo'',''Documento ''+E14_DOC+'' ja existente na base de dados.'' ,
						''TXT'',(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM Z99' + @emp + '0) + ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_)
						FROM #E14 E14
							INNER JOIN (SELECT * 
										FROM SL1' + @emp + '0 
										WHERE D_E_L_E_T_ = '''' AND L1_PDV = '''+@pdv+''' AND L1_FILIAL = '''+@filsl+''') AS SL1 ON L1_DOC = E14.E14_DOC'
		EXEC( @sql )
		--Remove os duplicados da query para não serem processados.
		SET @sql = N'DELETE FROM #E14 
						WHERE E14_SEQ in (SELECT E14_SEQ
										FROM #E14 E14
											INNER JOIN (SELECT * 
												FROM SL1' + @emp + '0 
												WHERE D_E_L_E_T_ = '''' AND L1_PDV = '''+@pdv+''' 
																		AND L1_FILIAL = '''+@filsl+''') AS SL1 ON L1_DOC = E14.E14_DOC)'
		EXEC( @sql )

		--SB1
		IF @sb1grava = 'SIM'
			BEGIN
				--Insere quando não existe no SB1
				SET @sql = N'INSERT INTO SB1' + @emp + '0 (B1_FILIAL,B1_COD,B1_DESC,B1_LOCPAD,B1_UM,B1_TIPO,R_E_C_N_O_)
								SELECT '''+@filsb1+''',E15_PRODUTO,E15_DESCRI,''01'',
										E15_UM,''MP'',(Select ISNULL(MAX(R_E_C_N_O_),0) FROM SB1'+@emp+'0)+ROW_NUMBER() OVER ( ORDER BY E15_PRODUTO )
								FROM #E15A E15
								WHERE E15_PRODUTO not in (Select B1_COD
															From SB1' + @emp + '0
															Where D_E_L_E_T_ <> ''*'' AND B1_FILIAL = '''+@filsb1+'''
															Group By B1_COD )'
				EXEC( @sql )
			END
		ELSE
			BEGIN
				-- quando não existir, insere o Log na Z99
				SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,D_E_L_E_T_,R_E_C_N_O_ ) 
								SELECT ''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''',
								'''+@txtarq+''',''Produto nao encontrado para o codigo ''+E15_PRODUTO+''  '',
								'''+@txtcont+''','' '',(Select ISNULL(MAX(R_E_C_N_O_),1) FROM Z99'+@emp+'0)+ROW_NUMBER() OVER ( ORDER BY E15_PRODUTO )
								FROM #E15 E15
								WHERE E15_PRODUTO not in (Select B1_COD
														From SB1' + @emp + '0
														Where D_E_L_E_T_ <> ''*'' AND B1_FILIAL = '''+@filsb1+'''
														Group By B1_COD )' 
				EXEC( @sql )

				-- quando não existir, retira o cabeçalho do cupom deste item
				SET @sql = N'DELETE FROM #E14 WHERE E14_SERPDV+E14_DOC in (SELECT E15_SERPDV+E15_DOC
																	FROM #E15 E15
																	WHERE E15_PRODUTO not in (Select B1_COD
																						From SB1' + @emp + '0
																						Where D_E_L_E_T_ <> ''*'' AND B1_FILIAL = '''+@filsb1+'''
																						Group By B1_COD ))' 
				EXEC( @sql )
			END

		--Inicio gravação SL1/SL2/SL4 **     
		SET @numcupini = ''		
		SET @numcupfim = ''	
		WHILE ( SELECT COUNT(*) FROM #E14 ) > 0
			BEGIN
				SELECT TOP 1	@doc=E14_DOC		,@cnpjcli=E14_CNPJCLI,
								@xnome=E14_NOMECLI	,@emissao=E14_EMISSAO,@total=E14_VALMERC,
								@descont=E14_DESCONT,@cancel=E14_P_CANC,
								@reg=E14_SEQ 
				FROM #E14

				IF (@cancel) = 'S'
					SET @situa = '08'
				ELSE
					SET @situa = 'AG'					

				--Inclui cliente se não tiver cadastrado
				If (@cnpjcli = '00000000000000')--atribui CNPJ do proprio cliente caso não seja informado.
					SET @cnpjcli = @cnpjemp

				SET @pessoa = 'J'
				SET @tipocli = 'R'
				IF LEFT(@cnpjcli,3) = '000'
					BEGIN 
						SET @pessoa = 'F'
						SET @tipocli = 'F'	
						SET @cnpjcli = SUBSTRING(@cnpjcli,4,11)	
					END		
				SET @sql = N'SELECT @countOut=COUNT(*) FROM SA1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND A1_FILIAL = @Intfilsa1 AND A1_CGC = @Intcnpj'
				EXEC sp_executesql @sql , N'@Intfilsa1 VARCHAR(02),@countOut Integer Output,@Intcnpj VARCHAR(14)',@Intfilsa1=@filsa1 ,@countOut = @count OUTPUT,@Intcnpj=@cnpjcli  

				IF ( @count = 0 )
					BEGIN
						SET @sql = N'SELECT @codcliOut=ISNULL(MAX(CAST(A1_COD AS INT))+1,''1'') FROM SA1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND A1_FILIAL = @Intfilsa1'
						EXEC sp_executesql @sql , N'@codcliOut VARCHAR(6) Output,@Intfilsa1 VARCHAR(2)',@Intfilsa1=@filsa1,@codcliOut=@codcli OUTPUT   			 
						SET @codcli = RIGHT('000000' + @codcli,6)
						SET @loja = '01'
						SET @sql = N'INSERT INTO SA1' + @emp + '0 (A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_END,A1_COMPLEM,A1_BAIRRO,A1_MUN,
										A1_CGC,A1_CEP,A1_PESSOA,A1_TIPO,A1_CODPAIS,A1_INSCR,R_E_C_N_O_) 
										VALUES (''' + @filsa1 + ''','''+ @codcli+''','''+@loja+''','''+SUBSTRING(@xnome,1,40)+''','''+SUBSTRING(@xnome,1,20)+''','''
										+SUBSTRING(RTRIM(@xlgr),1,40)+''','''+@xcpl+''','''+@xbairro+''','''+@xmun+''','''+@cnpjcli+''','''+@cep+''','''+@pessoa+''','''
										+@tipocli+''',''01058'','''+@ie+''',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SA1'+@emp+'0))' 
						EXEC( @sql )
					END
				ELSE
					BEGIN
						SET @sql = N'SELECT @codcliOut=A1_COD,@lojaOut=A1_LOJA,@tipocliOut=A1_TIPO FROM SA1' + @emp + '0 WHERE A1_FILIAL = @Intfilsa1 AND D_E_L_E_T_ = '''' AND A1_CGC = @Intcnpj '
						EXEC sp_executesql @sql , N'@codcliOut VARCHAR(6) Output,@lojaOut VARCHAR(2) Output,@tipocliOut VARCHAR(1) Output,@Intfilsa1 VARCHAR(2),@Intcnpj VARCHAR(14)',
								  @codcliOut=@codcli OUTPUT,@lojaOut=@loja OUTPUT,@tipocliOut=@tipocli OUTPUT,@Intcnpj=@cnpjcli,@Intfilsa1=@filsa1    			 
					END

				SET @sql = N'SELECT @numorcOut=ISNULL(MAX(L1_NUM)+1,''1'') FROM SL1' + @emp + '0 WHERE D_E_L_E_T_ = '''' '
				EXEC sp_executesql @sql , N'@numorcOut Varchar(6) Output',@numorcOut=@numorc OUTPUT 	
				SET @numorc = RIGHT('000000' + @numorc,6)	
				
				IF @numcupini = '' OR @doc <= @numcupini  	
					SET @numcupini = @doc
				IF @doc >= @numcupfim  	
					SET @numcupfim = @doc			
			
				--Gravação SL2
				SELECT * INTO #ITENS
				FROM #E15
				WHERE E15_DOC = @doc AND E15_SERPDV=@serpdv 

				SET @total = 0
				SET @item = '01'
				SET @totalcanc = 0
				WHILE ( SELECT COUNT(*) FROM #ITENS ) > 0 
					BEGIN
						SELECT TOP 1 @cprod = E15_PRODUTO , @xprod = E15_DESCRI , @prcven = E15_VRUNIT , @quant = E15_QUANT , @unid = E15_UM ,
						@totalit = E15_VLRITEM , @sittrib = E15_SITTRIB , @descit=E15_DESC, @reg2=E15_SEQ, @itemCancel=E15_P_CANC
						FROM #ITENS
							
						SET @sql = N'SELECT @tesOut=B1_TS FROM SB1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND B1_FILIAL = @Intfilsb1 AND B1_COD = @Intcodprod '
						EXEC sp_executesql @sql , N'@Intfilsb1 Varchar(02),@tesOut Varchar(3) Output,@Intcodprod Varchar(15)',
																				@Intfilsb1=@filsb1 ,@tesOut=@tes OUTPUT,@Intcodprod=@cprod 

						IF RTRIM( @tes ) = ''
							SET @tes = '6BI'

						-- Este tratamento nunca sera executado, pois passou a deletar
						Set @situaItem = @situa
						IF ( @itemCancel = 'S' ) 
							Set @situaItem = '08'

						SET @sql = N'INSERT INTO SL2' + @emp + '0 
									(L2_FILIAL,L2_NUM,L2_PRODUTO,L2_SERPDV,L2_SITUA,L2_ITEM,L2_DESCRI,L2_QUANT,L2_VRUNIT,L2_VLRITEM,L2_LOCAL,L2_UM,L2_TES,L2_CF,
									L2_VENDIDO,L2_VALDESC,L2_PRCTAB,L2_BASEICM,L2_TABELA,L2_GRADE,L2_VEND,L2_ITEMSD1,L2_VALICM,L2_SITTRIB,L2_DOC,L2_SERIE,L2_PDV,R_E_C_N_O_) 
									VALUES ('''+@filsl+''','''+@numorc+''','''+@cprod+''','''+@serpdv+''','''+@situaItem+''','''+@item+''',
									'''+@xprod+''','+CONVERT(VARCHAR,convert(decimal(16,2),@quant))+','+CONVERT(VARCHAR,convert(decimal(16,2),@prcven))+',
									'+CONVERT(VARCHAR,convert(decimal(16,2),@totalit))+',''01'','''+@unid+''','''+@tes+''','''',''S'',
									'+CONVERT(VARCHAR,convert(decimal(16,2),@descit))+','+CONVERT(VARCHAR,convert(decimal(16,2),@prcven))+',
									'+CONVERT(VARCHAR,convert(decimal(16,2),@totalit))+',''1'',''N'',''000001'',''000000'',0,'''
									+@sittrib+''','''+@doc+''','''+@pdv+''','''+@pdv+''',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL2'+@emp+'0))'
						EXEC( @sql )
						
						IF ( @itemCancel = 'S' ) 
							Begin
								SET @sql = N'Update SL2' + @emp + '0 set D_E_L_E_T_ = ''*'', R_E_C_D_E_L_ = (Select ISNULL(MAX(R_E_C_N_O_),0) 
											FROM SL2'+@emp+'0)
											Where R_E_C_N_O_ = (Select ISNULL(MAX(R_E_C_N_O_),0) FROM SL2'+@emp+'0)'
								EXEC( @sql )
							End
						Else
							SET @total = @total + @totalit	

						IF ( @cancel = 'S' ) 
							SET @totalcanc = @totalcanc + @totalit

						--Tratamento Para sequencia do Item do SL2
						IF ASCII(LEFT(@item,1)) >= 48 AND ASCII(LEFT(@item,1)) <= 57
							BEGIN
								IF (@item = '99')
									SET @item = 'A0'
								ELSE IF (ASCII(RIGHT(@item,1)) >= 57)
									SET @item = CHAR(ASCII(LEFT(@item,1))+1)+CHAR(48)
								ELSE 
									SET @item = LEFT(@item,1)+CHAR(ASCII(RIGHT(@item,1))+1)
							END
						ELSE IF ASCII(LEFT(@item,1)) >= 65 AND ASCII(LEFT(@item,1)) <= 90
							BEGIN
								IF (ASCII(RIGHT(@item,1)) = 57)
									SET @item = LEFT(@item,1)+CHAR(65)
								ELSE IF (ASCII(RIGHT(@item,1)) < 90)
									SET @item = LEFT(@item,1)+CHAR(ASCII(RIGHT(@item,1))+1)
								ELSE IF (ASCII(RIGHT(@item,1)) >= 90)
									SET @item = CHAR(ASCII(LEFT(@item,1))+1)+CHAR(48)
								ELSE 
									SET @item = 'ZZ'
							END
						ELSE
							SET @item = 'ZZ'

						DELETE FROM #ITENS WHERE E15_SEQ = @reg2
					END 
				DROP TABLE #ITENS

				/** SL4 ( Formas de pagamento ) */
				SELECT * INTO #PAGTO
				FROM #E21 
				WHERE E21_DOC=@doc AND E21_SERPDV=@serpdv 

				/* Tratamento cupons CANCELADOS, pois nao trazem as formas de pagamento. Nesta situação, deve ser cadastrado como default "R$" - Dinheiro */
				IF ( @cancel = 'S' ) AND ( SELECT COUNT(*) FROM #PAGTO ) = 0 
					BEGIN
						INSERT INTO #PAGTO (E21_SERPDV ,E21_DOC ,E21_FORMA ,E21_VALOR,E21_SEQ ) 
						VALUES (@serpdv ,@doc ,'Dinheiro',@total,1)
					END

				SET @sql = N'INSERT INTO SL4' + @emp + '0 (L4_FILIAL,L4_NUM,L4_SERPDV,L4_DATA,L4_SITUA,L4_VALOR,L4_FORMA,L4_ADMINIS,L4_CGC,R_E_C_N_O_)
							SELECT '''+@filsl+''','''+@numorc+''','''+@serpdv+''','''+@emissao+''','''+@situa+''',CONVERT(VARCHAR,E21_VALOR),
									CASE WHEN UPPER(RTRIM(E21_FORMA))  = ''CARTAO DEBITO'' THEN ''CD''
										 WHEN UPPER(RTRIM(E21_FORMA))  = ''CARTAO CREDITO'' THEN ''CC''
										 ELSE ''R$''
									END,
									CASE WHEN UPPER(RTRIM(E21_FORMA))  = ''CARTAO DEBITO'' THEN ''003 - DEBITO'' 
										 WHEN UPPER(RTRIM(E21_FORMA))  = ''CARTAO CREDITO'' THEN ''002 - CREDITO'' 	
										 ELSE ''''
									END,
									'''+@cnpjcli+''',(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL4' + @emp + '0) + ROW_NUMBER() OVER (ORDER BY E21_SEQ)
							FROM #PAGTO'
				EXEC( @sql )
				DROP TABLE #PAGTO

				SET @formpagto = ''
				/** Gravação da SL1*/
				SET @sql = N'INSERT INTO SL1' + @emp + '0 (L1_FILIAL,L1_NUM,L1_CLIENTE,L1_LOJA,L1_CGCCLI,L1_EMISSAO,L1_DTLIM,L1_FORMPG,L1_ENTRADA,L1_SITUA,
							L1_VALMERC,L1_VALBRUT,L1_VLRTOT,L1_VLRLIQ,L1_TIPO,L1_TIPOCLI,L1_CONDPG,L1_IMPRIME,L1_ESTACAO,L1_VEND,L1_DOC,L1_EMISNF,L1_DESCONT,
							L1_KEYNFCE,L1_PDV,L1_SERIE,L1_SERPDV,R_E_C_N_O_) 
							VALUES ('''+@filsl+''','''+@numorc+''','''+@codcli+''','''+@loja+''','''+@cnpjcli+''','''+@emissao+''','''+@emissao+''','''
							+@formpagto+''','+CONVERT(VARCHAR,convert(decimal(16,2),@total))+','''+@situa+''','+CONVERT(VARCHAR,convert(decimal(16,2),@total))+',
							'+CONVERT(VARCHAR,convert(decimal(16,2),@total))+','+CONVERT(VARCHAR,convert(decimal(16,2),@total))+',
							'+CONVERT(VARCHAR,convert(decimal(16,2),@total))+',''V'','''+@tipocli+''',''CN'',''1S'',''001'',''000001'',
							'''+@doc+''','''+@emissao+''','+CONVERT(VARCHAR,convert(decimal(16,2),@descont))+',
							'''+@chvnfe+''','''+@pdv+''','''+@pdv+''','''+@serpdv+''',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL1'+@emp+'0))'
				EXEC( @sql )
				
				DELETE FROM #E14 WHERE E14_SEQ = @reg
			END
	
		/*	* Gravação SFI ( Redução Z )
			* Grava conteudo dos campos dinamicamente */
		IF @numcupini <> ''
			BEGIN
				SET @campos_sfi = 'FI_FILIAL,FI_PDV,FI_SERPDV,FI_NUMERO,FI_DTMOVTO,FI_DTREDZ,FI_HRREDZ,FI_COO,FI_VALCON,FI_NUMINI,FI_NUMFIM,R_E_C_N_O_'
				SET @cont_sfi = ''
				SELECT @campos_sfi	= @campos_sfi+(CASE WHEN E13_TIPOTOT = 'Can-T' THEN ',FI_CANCEL' --Cancelamento – ICMS
														--WHEN E13_TIPOTOT = 'CAN-S' THEN ',FI_CANCEL' --Cancelamento – ISSQN 
														--WHEN E13_TIPOTOT = 'AS' THEN ',' --Acréscimo – ISSQN
														--WHEN E13_TIPOTOT = 'AT' THEN ','--Acréscimo – ICMS
														--WHEN E13_TIPOTOT = 'DS' THEN ','--Desconto – ISSQN
														WHEN E13_TIPOTOT = 'DT' THEN ',FI_DESC'--Desconto – ICMS
														--WHEN E13_TIPOTOT = 'OPNF' THEN ','--Operações Não Fiscais
														--WHEN E13_TIPOTOT = 'NSn' THEN ','--Não-incidência – ISSQN
														--WHEN E13_TIPOTOT = 'Isn' THEN ','--Isento – ISSQN
														--WHEN E13_TIPOTOT = 'FSn' THEN ','--Substituição Tributária – ISSQN
														--WHEN E13_TIPOTOT = 'Nn' THEN ','--Não-incidência – ICMS
														--WHEN E13_TIPOTOT = 'In' THEN ','--Isento – ICMS
														WHEN LEFT(E13_TIPOTOT,1) = 'F' AND LEFT(E13_TIPOTOT,2) <> 'FS'  THEN ',FI_SUBTRIB'--Substituição Tributária – ICMS
														--WHEN E13_TIPOTOT = 'xxSnnnn' THEN ','--Tributado ISSQN
														--WHEN E13_TIPOTOT = 'xxSnnnn' THEN ','--Tributado ICMS
														ELSE ',FI_OUTROSR' END) ,--Tributado ICMS
						@cont_sfi	= @cont_sfi + ',' + CONVERT(VARCHAR,convert(decimal(16,2),E13_VALPARC)),
						@total		= E12_VALCONT,
						@coo		= E12_COO,
						@dtmovto	= E12_DTMOVTO,
						@emissao	= E12_EMISSAO,
						@hora		= E12_HORA,
						@numero_sfi	= E12_NUMERO
				FROM #E12 INNER JOIN #E13 ON E12_NUMERO = E13_NUMERO
				WHERE E13_TIPOTOT in ('Can-T','DT') OR (LEFT(E13_TIPOTOT,1) = 'F' AND LEFT(E13_TIPOTOT,2) <> 'FS') 

				SET @cont_sfi = ''''+@filsl+''','''+@pdv+''','''+@serpdv+''','''+@numero_sfi+''','''+@dtmovto+''','''+@emissao+''','''+@hora+''','''+@coo+''','
								+CONVERT(VARCHAR,@total)+','''+@numcupini+''','''+@numcupfim+''',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SFI'+@emp+'0)'+@cont_sfi	
				SET @sql = 'INSERT INTO SFI' + @emp + '0 (' + @campos_sfi + ',FI_SITUA ) VALUES ( ' + @cont_sfi + ',''AG'')'
				EXEC( @sql )

				SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,D_E_L_E_T_,R_E_C_N_O_ ) VALUES (
						''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''','''+@txtarq+''',''Processado'' ,'''
						+@txtcont+''','' '',(Select ISNULL(MAX(R_E_C_N_O_),0)+1 FROM Z99'+@emp+'0))' 
				EXEC( @sql )

				/** Atualiza campo L?_SITUA para PE somente após gravar tudo */
				EXEC( N'UPDATE SL1' + @emp + '0 SET L1_SITUA = '''+@newsitua+''' WHERE L1_FILIAL = '''+ @filsl +''' AND L1_SITUA = ''AG'' ' )
				EXEC( N'UPDATE SL2' + @emp + '0 SET L2_SITUA = '''+@newsitua+''' WHERE L2_FILIAL = '''+ @filsl +''' AND L2_SITUA = ''AG'' ' )
				EXEC( N'UPDATE SL4' + @emp + '0 SET L4_SITUA = '''+@newsitua+''' WHERE L4_FILIAL = '''+ @filsl +''' AND L4_SITUA = ''AG'' ' )
				EXEC( N'UPDATE SFI' + @emp + '0 SET FI_SITUA = '''+@newsitua+''' WHERE FI_FILIAL = '''+ @filsl +''' AND FI_SITUA = ''AG'' ' )

				--Atualiza os Cupons que não vão ser ajustados os pagamentos quando não forem CC
				EXEC( N'UPDATE SL1' + @emp + '0 SET L1_SITUA = ''RX'' WHERE (L1_FILIAL+L1_NUM) in (Select L4_FILIAL+L4_NUM 
							From SL4' + @emp + '0 where D_E_L_E_T_ = '''' AND L4_FORMA <> ''CC'' AND L4_SITUA = ''PE'') ' )
				EXEC( N'UPDATE SL2' + @emp + '0 SET L2_SITUA = ''RX'' WHERE (L2_FILIAL+L2_NUM) in (Select L4_FILIAL+L4_NUM 
							From SL4' + @emp + '0 where D_E_L_E_T_ = '''' AND L4_FORMA <> ''CC'' AND L4_SITUA = ''PE'') ' )
				EXEC( N'UPDATE SL4' + @emp + '0 SET L4_SITUA = ''RX'' WHERE L4_FORMA <> ''CC'' AND L4_SITUA = ''PE'' ' )
			END
		IF OBJECT_ID('#E02') IS NOT NULL
			DROP TABLE #E02
		IF OBJECT_ID('#E12') IS NOT NULL
			DROP TABLE #E12
		IF OBJECT_ID('#E13') IS NOT NULL
			DROP TABLE #E13
		IF OBJECT_ID('#E14') IS NOT NULL
			DROP TABLE #E14
		IF OBJECT_ID('#E15') IS NOT NULL
			DROP TABLE #E15
		IF OBJECT_ID('#E21') IS NOT NULL
			DROP TABLE #E21

		WHILE ( @@TRANCOUNT > 0 )
			BEGIN
				COMMIT TRAN
			END 

	END TRY
	BEGIN CATCH
		WHILE ( @@TRANCOUNT > 0 )
			BEGIN
				ROLLBACK TRAN
			END 
		SET @sql = N'INSERT INTO LOGLOJA ( DATA, ARQ, LOGARQ,XML) 
						VALUES ( ''' + REPLACE(CONVERT(char(10),GETDATE()  , 102 ),'.','')+''','''+@txtarq+''',''' + ERROR_MESSAGE() + ''','''')'
		EXEC( @sql )
	END CATCH	
END