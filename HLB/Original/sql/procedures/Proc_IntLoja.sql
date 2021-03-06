
USE P11_TESTE
GO
/****** Object:  StoredProcedure [dbo].[Proc_IntLoja]    Script Date: 07/07/2016 22:35:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Proc_IntLoja] ( 
	@xmlent Varchar( MAX ) , 
	@xmlarq varchar(200) 
) 
As
Declare @xml Xml
Declare @cnpjcli Varchar( 14 )
Declare @cnpjemp Varchar( 14 )
Declare @xnome Varchar( 40 )
Declare @xlgr Varchar( 60 )
Declare @nro Varchar( 10 )
Declare @xcpl Varchar( 50 )
Declare @xbairro Varchar( 30 )
Declare @xmun Varchar( 60 )
Declare @cep Varchar( 8 )
Declare @ie Varchar( 18 )
Declare @cprod Varchar( 15 )
Declare @xprod Varchar( 30 )
Declare @ncm Varchar( 10 )
Declare @recno Integer
Declare @recno2 Integer
Declare @codcli Varchar( 06 )
Declare @pessoa Varchar( 01 )
Declare @numorc Varchar( 06 )
Declare @loja Varchar( 02 )
Declare @emissao Varchar( 08 )
Declare @doc Varchar( 09 )
Declare @pdv Varchar( 03 ) 
Declare @numcup Varchar( 09 )
Declare @cpf Varchar( 11 )
Declare @tipocli Char( 1 )
Declare @total Numeric(15,2)
Declare @totalit Numeric(15,2)
Declare @chvnfe Varchar( 44 )

Declare @linha Integer 
Declare @produto Varchar( 15 )
Declare @prcven  Numeric(15,2)
Declare @qtde  Numeric(15,2)
Declare @unid  Varchar( 2 )
Declare @cfo  Varchar( 4 )
Declare @origem Char( 1 )
Declare @cst Varchar( 2 )
Declare @picms  Numeric(15,2)
Declare @vicms  Numeric(15,2)
Declare @sittrib Varchar( 05 )
Declare @tes Varchar( 03 )
Declare @formpagto Varchar( 02 )
Declare @adminis Varchar( 30 )
Declare @admc Varchar( 03 )
Declare @sql nVarchar( MAX )
Declare @count Integer
Declare @emp Varchar( 2 ) 
Declare @filsl Varchar( 02 ) 
Declare @filsa1 Varchar( 02 ) 
Declare @filsb1 Varchar( 02 )  


Begin

	SET @xmlent = REPLACE(@xmlent,'<?xml version="1.0" encoding="utf-8"?>','')
	SET @xml = @xmlent

	/*Dados do Emitente e Cliente efetuando parse do xml */
	SELECT 
		@chvnfe = Substring(X.emit.query('data(../@Id)').value('.', 'VARCHAR(47)'),4,44),	
		@xlgr = X.emit.query('enderEmit/xLgr').value('.', 'CHAR(60)'),
		@nro = X.emit.query('enderEmit/nro').value('.', 'CHAR(10)'),
		@xcpl = X.emit.query('enderEmit/xCpl').value('.', 'CHAR(50)'),
		@xbairro = X.emit.query('enderEmit/xBairro').value('.', 'CHAR(30)'),	
		@xmun = X.emit.query('enderEmit/xMun').value('.', 'CHAR(60)'),	
		@cep = X.emit.query('enderEmit/CEP').value('.', 'CHAR(8)'),			
		@cnpjcli = X.emit.query('../dest/CNPJ').value('.', 'CHAR(14)'),
		@cpf = X.emit.query('../dest/CPF').value('.', 'CHAR(11)'),	
		@cnpjemp = X.emit.query('CNPJ').value('.', 'CHAR(14)'),		
		@xnome = X.emit.query('xNome').value('.', 'CHAR(60)'),
		@ie = X.emit.query('IE').value('.', 'CHAR(18)')	,
		@emissao = X.emit.query('../ide/dEmi').value('.', 'CHAR(08)'),
		@doc = X.emit.query('../ide/cNF').value('.', 'CHAR(09)'),		
		@numcup = X.emit.query('../ide/nCFe').value('.', 'CHAR(09)'),
		@formpagto = X.emit.query('../pgto/MP/cMP').value('.', 'CHAR(02)'),
		@admc = ( CASE WHEN X.emit.exist( '../pgto/MP/cAdmC' ) = 1 THEN RIGHT(X.emit.query('../pgto/MP/cAdmC').value('.', 'CHAR(03)'),2) ELSE '' END )																										
	FROM @xml.nodes( 'CFe/infCFe/emit') AS X(emit)

	/*	Inicio controle transação */
	Begin Try
		Begin Tran

		SET @filsa1 = '  '
		SET @filsb1 = '  '
		SET @filsl = '01'

		/*-- Somente para fazer a carga do cnpj NO SIGAMAT - RETIRAR DEPOIS
		If ( SELECT COUNT(*) FROM SIGAMAT WHERE M0_CGC = @cnpjemp  ) = 0
		Begin
		SET @recno  = ( SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SIGAMAT )
		INSERT INTO SIGAMAT ( M0_CODIGO , M0_CODFIL , M0_NOME , M0_NOMECOM , M0_CGC , D_E_L_E_T_ , R_E_C_N_O_ )
		VALUES ( '' , '01' , @xnome , @xnome , @cnpjemp , ' ' , @recno )
		End
		*/

		--Busca qual empresa serão gravado os dados
		SELECT @emp = M0_CODIGO FROM SIGAMAT WHERE M0_CGC = @cnpjemp 

		SET @emp = 'FG' /* testes */
 
		If ( @emp IS NULL )
			Begin
				SET @sql = N'INSERT INTO LOGLOJA ( DATA, ARQ, LOGARQ,XML) VALUES ( ''' + REPLACE(CONVERT(char(10),GETDATE()  , 102 ),'.','')+''','''+@xmlarq+''',
				''CNPJ ' + @cnpjemp  + ' nao encontrado na tabela SIGAMAT do banco de dados. '','''+@xmlent + ''')'
				EXEC( @sql )
				WHILE ( @@TRANCOUNT > 0 )
					BEGIN
						COMMIT TRAN
					END 
				Return
			End 

		--Caso a chave eletronica já esteja na SL1 nao grava para evitar duplicidade
		SET @sql = N'SELECT @countOut=COUNT(*) FROM SL1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND L1_KEYNFCE = @Intchvnfe AND L1_FILIAL = @Intfilsl1'
		EXEC sp_executesql @sql , N'@Intchvnfe Varchar(44),@Intfilsl1 Varchar(02),@countOut Integer Output' , @Intchvnfe=@chvnfe ,@Intfilsl1=@filsl,@countOut = @count OUTPUT  
 
		If ( @count ) > 0
			Begin
				SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM Z99' + @emp + '0' 
				EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	

				SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,D_E_L_E_T_,R_E_C_N_O_ ) VALUES (
					''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''','''+@xmlarq+''',''Ja processado anteriormente.'' ,'''+@xmlent+''','' '','+CONVERT(VARCHAR,@recno)+')' 
	
				EXEC( @sql )		
				WHILE ( @@TRANCOUNT > 0 )
					BEGIN
						COMMIT TRAN
					END 
				Return
			End 

		SET @pessoa = 'J'
		SET @tipocli = 'R'

		If LEFT(@cpf,3) <> '000'
			Begin 
				SET @pessoa = 'F'
				SET @cnpjcli = @cpf
				SET @tipocli = 'F'		
			End
  
		--Inclui cliente se não tiver cadastrado
		SET @count = 0
		SET @sql = N'SELECT @countOut=COUNT(*) FROM SA1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND A1_FILIAL = @Intfilsa1 AND A1_CGC = @Intcnpj'
		EXEC sp_executesql @sql , N'@Intfilsa1 Varchar(02),@countOut Integer Output,@Intcnpj Varchar(14)',@Intfilsa1=@filsa1 ,@countOut = @count OUTPUT,@Intcnpj=@cnpjcli  

		If ( @count = 0 )
			Begin
				SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SA1' + @emp + '0' 
				EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	
	
				SET @sql = N'SELECT @codcliOut=ISNULL(MAX(A1_COD)+1,''1'') FROM SA1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND A1_FILIAL = @Intfilsa1'
				EXEC sp_executesql @sql , N'@codcliOut Varchar(6) Output,@Intfilsa1 Varchar(2)',@Intfilsa1=@filsa1,@codcliOut=@codcli OUTPUT   			 
				SET @codcli = RIGHT('000000' + @codcli,6)
				SET @loja = '01'
				SET @sql = N'INSERT INTO SA1' + @emp + '0 (A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_END,A1_COMPLEM,A1_BAIRRO,A1_MUN,A1_CGC,A1_CEP,A1_PESSOA,A1_TIPO,A1_CODPAIS,A1_INSCR,R_E_C_N_O_) 
				 VALUES (''' + @filsa1 + ''','''+ @codcli+''','''+@loja+''','''+@xnome+''','''+SUBSTRING(@xnome,1,20)+''','''+RTRIM(@xlgr)+''','''+@xcpl+''','''+@xbairro+''','''+@xmun+''','''+@cnpjcli+''','''+@cep+''','''+@pessoa+''','''+@tipocli+''',''01058'','''+@ie+''','+CONVERT(VARCHAR,@recno)+')' 
				EXEC( @sql )
			End

		Else
		Begin
			SET @sql = N'SELECT @codcliOut=A1_COD,@lojaOut=A1_LOJA,@tipocliOut=A1_TIPO FROM SA1' + @emp + '0 WHERE A1_FILIAL = @Intfilsa1 AND D_E_L_E_T_ = '''' AND A1_CGC = @Intcnpj '
			EXEC sp_executesql @sql , N'@codcliOut Varchar(6) Output,@lojaOut Varchar(2) Output,@tipocliOut Varchar(1) Output,@Intfilsa1 Varchar(2),@Intcnpj Varchar(14)',
					  @codcliOut=@codcli OUTPUT,@lojaOut=@loja OUTPUT,@tipocliOut=@tipocli OUTPUT,@Intcnpj=@cnpjcli,@Intfilsa1=@filsa1    			 
	
		End

		--Dados da Venda
		SELECT 
			ROW_NUMBER() OVER ( ORDER BY X.prod.query('prod[1]/cProd').value('.', 'VARCHAR(14)') ) LINHA,
			X.prod.query('prod[1]/cProd').value('.', 'VARCHAR(14)') CODPROD,
			X.prod.query('prod[1]/xProd').value('.', 'VARCHAR(50)') DESCPROD,
			X.prod.query('prod[1]/vUnCom').value('.', 'NUMERIC(10,2)') PRCVEN,
			X.prod.query('prod[1]/NCM').value('.', 'VARCHAR(8)') NCM,		
			X.prod.query('prod[1]/qCom').value('.', 'NUMERIC(10,2)') QTDE,
			X.prod.query('prod[1]/uCom').value('.', 'VARCHAR(2)') UNID,
			X.prod.query('prod[1]/vProd').value('.', 'NUMERIC(10,2)') TOTAL,            
			X.prod.query('prod[1]/CFOP').value('.', 'VARCHAR(4)') CFO,
			CASE WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS00' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS00/Orig').value('.', 'VARCHAR(1)') 
			WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS40' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS40/Orig').value('.', 'VARCHAR(1)') 
			ELSE ' ' END ORIGEM ,
			CASE WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS00' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS00/CST').value('.', 'VARCHAR(2)') 
			WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS40' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS40/CST').value('.', 'VARCHAR(2)')
			ELSE '  ' END CST ,		
			CASE WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS00' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS00/pICMS').value('.', 'NUMERIC(5,2)')
			WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS40/pICMS' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS40/pICMS').value('.', 'NUMERIC(5,2)')
			ELSE 0 END PICMS ,			
			CASE WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS00' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS00/vICMS').value('.', 'NUMERIC(10,2)')
			WHEN X.prod.exist( 'imposto[1]/ICMS/ICMS40/vICMS' ) = 1 THEN X.prod.query('imposto[1]/ICMS/ICMS40/vICMS').value('.', 'NUMERIC(10,2)')
			ELSE 0 END VICMS 
			INTO #ITENS          
		FROM @xml.nodes( 'CFe/infCFe/det') AS X(prod)

		SET @total = ( SELECT SUM(TOTAL) FROM #ITENS )

		--Tratamento Forma de Pagamento e Administradora
		SET @adminis = ''
		If ( @formpagto = '01' )
			SET @formpagto = 'R$'
	 
		Else If ( CHARINDEX(@formpagto, '03,05') > 0 )  /* Credito ou Credito Loja */
			Begin
				SET @formpagto = 'CC'
				SET @adminis = '' 	
				If RTRIM( @admc ) <> ''
					Begin
						 SET @sql = N'SELECT @adminisOut=LEFT(RTRIM(AE_COD)+'' - '' + RTRIM(AE_DESC),30) FROM SAE' + @emp + '0 WHERE AE_FILIAL = '''' AND D_E_L_E_T_ = '''' AND AE_COD = @Intcod + ''C'' '
						 EXEC sp_executesql @sql , N'@adminisOut Varchar(30) Output,@Intcod Varchar(3)',
							  @adminisOut=@adminis OUTPUT,@Intcod=@admc   			 
					End

				If ISNULL(@adminis,'' ) = ''
					Begin
						SET @adminis = '002 - CREDITO' 	
					End
			End
		Else If ( CHARINDEX(@formpagto, '04,10,11,12,13') > 0 )  /* Debito, vale refeição, vale alimentação */
			Begin
				SET @formpagto = 'CD'
				If RTRIM( @admc ) <> ''
					Begin
						SET @sql = N'SELECT @adminisOut=LEFT(RTRIM(AE_COD)+'' - '' + RTRIM(AE_DESC),30) FROM SAE' + @emp + '0 WHERE AE_FILIAL = '''' AND D_E_L_E_T_ = '''' AND AE_COD = @Intcod + ''D'' '
						EXEC sp_executesql @sql , N'@adminisOut Varchar(30) Output,@Intcod Varchar(3)',
							  @adminisOut=@adminis OUTPUT,@Intcod=@admc   			 
					End
		
				If ISNULL(@adminis,'' ) = ''
					Begin
						SET @adminis = '003 - DEBITO' 	
					End		
			End
		Else If ( @formpagto = '02' )
			Begin
				SET @formpagto = 'CH'
				SET @adminis = '001 - CHEQUE'
			End
				
			--Gravação SB1\SL1\SL2\SL4
			SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL1' + @emp + '0' 
			EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	
	
			SET @sql = N'SELECT @numorcOut=ISNULL(MAX(L1_NUM)+1,''1'') FROM SL1' + @emp + '0 WHERE D_E_L_E_T_ = '''' '
			EXEC sp_executesql @sql , N'@numorcOut Varchar(6) Output',@numorcOut=@numorc OUTPUT 	
			SET @numorc = RIGHT('000000' + @numorc,6)
		
			SET @sql = N'INSERT INTO SL1' + @emp + '0 (L1_FILIAL,L1_NUM,L1_CLIENTE,L1_LOJA,L1_CGCCLI,L1_EMISSAO,L1_DTLIM,L1_FORMPG,L1_ENTRADA,L1_SITUA,L1_VALMERC,L1_VALBRUT,L1_TIPO,L1_TIPOCLI,L1_CONDPG,L1_IMPRIME,L1_ESTACAO,L1_VEND,L1_DOC,L1_PDV,L1_KEYNFCE,R_E_C_N_O_) VALUES
			('''+@filsl+''','''+@numorc+''','''+@codcli+''','''+@loja+''','''+@cnpjcli+''','''+@emissao+''','''+@emissao+''','''+@formpagto+''','+CONVERT(VARCHAR,@total)+',''  '','+CONVERT(VARCHAR,@total)+','+CONVERT(VARCHAR,@total)+
			',''V'','''+@tipocli+''',''CN'',''1S'',''001'',''000001'','''+@doc+''','''+@pdv+''','''+@chvnfe+''','+CONVERT(VARCHAR,@recno)+')'
			EXEC( @sql )

			SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL2' + @emp + '0' 
			EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	
		 
			SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SB1' + @emp + '0' 
			EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno2 OUTPUT   		

		While ( SELECT COUNT(*) FROM #ITENS ) > 0 
			Begin
				SELECT TOP 1 @linha = LINHA , @produto = CODPROD , @xprod = DESCPROD , @prcven = PRCVEN , @qtde = QTDE , @unid = UNID ,
					   @totalit = TOTAL , @cfo = CFO , @origem = ORIGEM , @cst = CST , @picms = PICMS , @vicms = VICMS ,
					   @ncm = NCM
				FROM #ITENS

				--Verifica se é necessário cadastrar produto
				SET @count = 0
				SET @sql = N'SELECT @countOut=COUNT(*) FROM SB1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND B1_FILIAL = @Intfilsb1 AND B1_COD = @Intcodprod '
				EXEC sp_executesql @sql , N'@Intfilsb1 Varchar(02),@countOut Integer Output,@Intcodprod Varchar(15)',@Intfilsb1=@filsb1 ,@countOut = @count OUTPUT,@Intcodprod=@produto 
				If ( @count = 0 )
					Begin
						SET @tes = ''
						EXEC( N'INSERT INTO SB1' + @emp + '0 (B1_FILIAL,B1_COD,B1_DESC,B1_LOCPAD,B1_POSIPI,B1_ORIGEM,B1_UM,B1_TIPO,R_E_C_N_O_)
						VALUES ('''+@filsb1+''','''+@produto+''','''+@xprod+''',''01'','''+@ncm+''','''+@origem+''','''+@unid+''',''MP'','+@recno2+')' )
						SET @recno2 = @recno2 + 1			
					End
				Else
					Begin
						SET @sql = N'SELECT @tesOut=B1_TS FROM SB1' + @emp + '0 WHERE D_E_L_E_T_ = '''' AND B1_FILIAL = @Intfilsb1 AND B1_COD = @Intcodprod '
						EXEC sp_executesql @sql , N'@Intfilsb1 Varchar(02),@tesOut Varchar(3) Output,@Intcodprod Varchar(15)',@Intfilsb1=@filsb1 ,@tesOut = @tes OUTPUT,@Intcodprod=@produto 
					End
		
				If ( RTRIM(@tes) = '' )
					SET @tes = '501'
			
				--Tratamento do L2_SITTRIB
				If ( @cst = '00' ) /* Integral  */
					SET @sittrib = 'T' + RIGHT('00'+REPLACE(CONVERT( VARCHAR , @picms ),'.',''),4)
				Else If ( @cst =  '20' ) /*  Redução  */
					SET @sittrib = 'T' + RIGHT('00'+REPLACE(CONVERT( VARCHAR , @picms ),'.',''),4)
				Else If ( @cst =  '40' ) /*  Isento  */
					SET @sittrib = 'I'		
				Else If ( @cst =  '41' ) /*  Nao tributado  */
					SET @sittrib = 'N'		
				Else If ( @cst =  '50' OR @picms =  0 ) /*  Suspenso  */		
					SET @sittrib = 'N'		
				Else If ( @cst =  '60' ) /*   ICMS cobrado anteriormente por substituição tributária   */				
					SET @sittrib = 'F'							
			
				SET @sql = N'INSERT INTO SL2' + @emp + '0 
				(L2_FILIAL,L2_NUM,L2_PRODUTO,L2_ITEM,L2_DESCRI,L2_QUANT,L2_VRUNIT,L2_VLRITEM,L2_LOCAL,L2_UM,L2_TES,L2_CF,
				L2_VENDIDO,L2_PRCTAB,L2_BASEICM,L2_TABELA,L2_GRADE,L2_VEND,L2_ITEMSD1,L2_VALICM,L2_SITTRIB,R_E_C_N_O_) 
				VALUES
				('''+@filsl+''','''+@numorc+''','''+@produto+''','''+RIGHT('00'+@linha,2)+''','''+@xprod+''','+CONVERT(VARCHAR,@qtde)+','+CONVERT(VARCHAR,@prcven)+','+CONVERT(VARCHAR,@totalit)+',''01'','''+@unid+''','''+@tes+''','''+@cfo+''',
				''S'','+CONVERT(VARCHAR,@prcven)+','+CONVERT(VARCHAR,@totalit)+',''1'',''N'',''000001'',''000000'','+CONVERT(VARCHAR,@vicms)+','''+@sittrib+''','+CONVERT(VARCHAR,@recno)+')'
				EXEC( @sql )
		       
				DELETE FROM #ITENS WHERE LINHA = @linha
				SET @recno = @recno + 1
			End

		--Gravação tabela SL4 - Forma de Pagamento
		SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM SL4' + @emp + '0' 
		EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	
	
		SET @sql = N'INSERT INTO SL4' + @emp + '0  (L4_FILIAL,L4_NUM,L4_DATA,L4_VALOR,L4_FORMA,L4_ADMINIS,L4_CGC,R_E_C_N_O_)
		VALUES ('''+@filsl+''','''+@numorc+''','''+@emissao+''','+CONVERT(VARCHAR,@total)+','''+@formpagto+''','''+@adminis+''','''+@cnpjcli+''','+CONVERT(VARCHAR,@recno)+')'
		EXEC( @sql )
	
		--Atualiza campo L?_SITUA para RX somente após gravar tudo 
		EXEC( N'UPDATE SL1' + @emp + '0 SET L1_SITUA = ''RX'' WHERE L1_FILIAL = '''+ @filsl +''' AND L1_NUM = '''+@numorc+''' ' )
		EXEC( N'UPDATE SL2' + @emp + '0 SET L2_SITUA = ''RX'' WHERE L2_FILIAL = '''+ @filsl +''' AND L2_NUM = '''+@numorc+''' ' )
		EXEC( N'UPDATE SL4' + @emp + '0 SET L4_SITUA = ''RX'' WHERE L4_FILIAL = '''+ @filsl +''' AND L4_NUM = '''+@numorc+''' ' )

		SET @sql = N'SELECT @recnoOut=ISNULL(MAX(R_E_C_N_O_),0)+1 FROM Z99' + @emp + '0' 
		EXEC sp_executesql @sql , N'@recnoOut Integer Output',@recnoOut=@recno OUTPUT   	

		SET @sql = N'INSERT INTO Z99' + @emp + '0 ( Z99_FILIAL,Z99_DATA,Z99_ARQ,Z99_LOG,Z99_XML,D_E_L_E_T_,R_E_C_N_O_ ) VALUES (''  '','''+REPLACE(CONVERT(char(10),GETDATE(), 102 ),'.','')+''','''+@xmlarq+''',''Processado'' ,'''+@xmlent+''','' '','+CONVERT(VARCHAR,@recno)+')' 
	
		EXEC( @sql )
		
		WHILE ( @@TRANCOUNT > 0 )
			Begin
				COMMIT TRAN
			End 
		
	End Try

	Begin Catch

		WHILE ( @@TRANCOUNT > 0 )
			Begin
				ROLLBACK TRAN
			End 

		SET @sql = N'INSERT INTO LOGLOJA ( DATA, ARQ, LOGARQ,XML) VALUES ( ''' + REPLACE(CONVERT(char(10),GETDATE()  , 102 ),'.','')+''','''+@xmlarq+''',''' + ERROR_MESSAGE() + ''','''+@xmlent + ''')'
		EXEC( @sql )
	
	End Catch

End

