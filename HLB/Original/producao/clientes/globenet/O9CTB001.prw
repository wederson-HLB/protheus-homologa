#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"

/*
Funcao      : O9CTB001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de Lançamentos
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*----------------------*
User Function O9CTB001()
*----------------------*
Private oWizMan
Private cArq := DTOS(Date())+".XLS"
Private dDtIni	:= dDataBase-30 
Private dDtFim	:= dDataBase
Private cDirArq := "c:\"+Space(100)

oWizMan := APWizard():New("Relatorio Lançamentos", ""/*<chMsg>*/, "Relatorio Lançamentos",;
													"- Esta rotina tem por objetivo a geração em Excel do Relatorio de Lançamentos"+CRLF+;
													"da Empresa "+FWEmpName(cEmpAnt) ,;
									 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

//Painel 2
oWizMan:NewPanel( "Parametros", "Parametros para a Geração do Relatorio.",{ ||.T.}/*<bBack>*/, {|| (GetQry(),.T.)}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizMan:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Inicial? " SIZE 100,10 OF oSBox1 PIXEL
odDtIni:= TGet():New(20,85,{|u| if(PCount()>0,dDtIni:=u,dDtIni)},oSBox1,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtIni')
@ 41,20 SAY oSay1 VAR "Dt. Final? " SIZE 100,10 OF oSBox1 PIXEL
odDtFim:= TGet():New(40,85,{|u| if(PCount()>0,dDtFim:=u,dDtFim)},oSBox1,50,05,'@D',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtFim')

@ 61,20 SAY oSay2 VAR "Diretorio? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(60,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,43,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
@ 60,127.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())

//Painel 3
oWizMan:NewPanel( "", "",{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizMan := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[3] PIXEL
oSBox2 := TScrollBox():New( oWizMan:oMPanel[3],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay3 VAR "" SIZE 100,10 OF oSBox2 PIXEL
oBtn2 := TButton():New(41,30,"Abrir",oSBox2,{|| OpenArq()},060,012,,,,.T.,,"",,,,.F. )

oWizMan:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .T.

/*
Funcao      : O9CTB001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função responsavel pela Abertura do Arquivo em excel
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*-----------------------*
Static Function OpenArq()
*-----------------------*
If File(cDirArq+cArq)
	SHELLEXECUTE("open",(cDirArq+cArq),"","",5)   // Gera o arquivo em Excel
Else
	MsgInfo("Falha na Abertura do Arquivo!","HLB BRASIL.")
EndIf
Return .T.

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

Return .T.
 
/*
Funcao      : GetQry
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função responsavel pela execução da query.
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*------------------------*
Static Function GetQry()
*------------------------*
Local cQry := ""

cDirArq := ALLTRIM(cDirArq)

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif   

//MSM - 17/07/2014 - Montagem da procedure que busca as informações   - Chamado: 020128
//MSM - 17/07/2014 - Foi criado por forma de procedure pois o comando tcsqlexec quando executava a query não atualizava os valores corretamente.
if !TCSPExist("SP_P_RELATORIO_FONTE_O9CTB001")
	cQry += " CREATE PROCEDURE SP_P_RELATORIO_FONTE_O9CTB001
else
	cQry += " ALTER PROCEDURE SP_P_RELATORIO_FONTE_O9CTB001
endif

cQry += " AS
cQry += " Declare @Codigo VARCHAR(10);"+CRLF
cQry += " Declare @Nome VARCHAR(200);"+CRLF
cQry += " Declare @Recno int;"+CRLF
cQry += " Declare @LancPad VarChar(6);"+CRLF
cQry += " Declare @CT2_KEY VarChar(500);"+CRLF
cQry += " Declare @Query VarChar(8000);"+CRLF
cQry += " Declare @TabBusc Varchar(3);"+CRLF
cQry += " Declare @ChaveBusc Varchar(500);"+CRLF
cQry += " Declare @TabCliFor TABLE(Codigo varchar(10), Nome varchar(200))"+CRLF

cQry += "  SELECT CT1_P_CONT 														AS 'NATACCOUNT', "+CRLF
cQry += "  	CASE WHEN CT2_DC='1' THEN CT2_DEBITO ELSE CT2_CREDIT END   				AS 'HLBACCOUNT',"+CRLF
cQry += "  	CT1_DESC04 																AS 'ACCOUNTDESC', "+CRLF
cQry += "  	CASE WHEN CT2_DC='1' THEN CT2_CCD ELSE CT2_CCC END 						AS 'CC',"+CRLF
cQry += "  	ISNULL(CTT_DESC01,'') 													AS 'CCDESC',"+CRLF
cQry += "  	CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA 					  				AS 'JOURNAL',"+CRLF
cQry += "  	'' 																		AS 'JOURNALHEAD',"+CRLF
cQry += "  	CT2_HIST 												 				AS 'JOURNALLINE',"+CRLF
cQry += "  	@Codigo																	AS 'CUSTVENDID',"+CRLF
cQry += "  	@Nome																	AS 'CUSTVENDNAME',"+CRLF
cQry += "  	'' 																		AS 'SOURCELEDGER',"+CRLF
cQry += "  	'' 														 				AS 'DOCTYPE',"+CRLF
cQry += "  	SUBSTRING( CONVERT(VARCHAR(8), CONVERT(datetime,CT2_DATA,126),3),4,5)	AS 'MTHYR',"+CRLF
cQry += "  	RIGHT('0'+(CONVERT(VARCHAR,MONTH(CT2_DATA))),2) 						AS 'PERIOD',"+CRLF
cQry += "  	CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),101) 				AS 'GLDATE',"+CRLF
cQry += "  	DIFREAL.CT2_VALOR * (CASE WHEN CT2_DC='1' THEN -1 ELSE 1 END ) 			AS 'USD',"+CRLF
cQry += "  	'USD' 														   			AS 'FCCODE',"+CRLF
cQry += "  	CT2.CT2_VALOR * (CASE WHEN CT2_DC='1' THEN -1 ELSE 1 END ) 				AS 'TRXVALUE',"+CRLF
cQry += "  	'BRF' 														   			AS 'TRXCODE',"+CRLF
cQry += " 	CT2.R_E_C_N_O_															AS 'RECNO',"+CRLF
cQry += " 	CT2.CT2_LP																AS 'LANCPAD',"+CRLF
cQry += " 	CT2.CT2_KEY																AS 'CT2_KEY'"+CRLF
cQry += "  INTO ##TEMPCT2"+CRLF
cQry += "  FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQry += "  		LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON (CASE WHEN CT2_DC='1' THEN CT2_DEBITO ELSE CT2_CREDIT END) = CT1_CONTA"+CRLF
cQry += "  		LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON (CASE WHEN CT2_DC='1' THEN CT2_CCD ELSE CT2_CCC END) = CTT_CUSTO"+CRLF 
cQry += "  		LEFT JOIN (SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "+CRLF
cQry += "  					FROM "+RETSQLNAME("CT2")
cQry += "  					WHERE CT2_DC IN ('1','2') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02')"+CRLF
cQry += "  					) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA"+CRLF
cQry += "  WHERE CT2_DC IN ('1','2') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01')"+CRLF
cQry += " AND CT2_DATA BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFIM)+"'"+CRLF
//  --DEBITOS DA PARTIDA DOBRADA
cQry += "  UNION ALL"+CRLF
cQry += "  SELECT CT1_P_CONT 														AS 'NATACCOUNT',"+CRLF 
cQry += "  	CT2_DEBITO 																AS 'HLBACCOUNT',"+CRLF
cQry += "  	CT1_DESC04 																AS 'ACCOUNTDESC', "+CRLF
cQry += "  	CT2_CCD 																AS 'CC',"+CRLF
cQry += "  	ISNULL(CTT_DESC01,'') 													AS 'CCDESC',"+CRLF
cQry += "  	CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA 									AS 'JOURNAL',"+CRLF
cQry += "  	'' 											 					 		AS 'JOURNALHEAD',"+CRLF
cQry += "  	CT2_HIST 														 		AS 'JOURNALLINE',"+CRLF
cQry += "  	'' 											 					 		AS 'CUSTVENDID',"+CRLF
cQry += "  	'' 											 					  		AS 'CUSTVENDNAME',"+CRLF
cQry += "  	'' 											 					   		AS 'SOURCELEDGER',"+CRLF
cQry += "  	'' 											 					   		AS 'DOCTYPE',"+CRLF
cQry += "  	SUBSTRING( CONVERT(VARCHAR(8), CONVERT(datetime,CT2_DATA,126),3),4,5) 	AS 'MTHYR',"+CRLF
cQry += "  	RIGHT('0'+(CONVERT(VARCHAR,MONTH(CT2_DATA))),2) 						AS 'PERIOD',"+CRLF
cQry += "  	CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),101) 				AS 'GLDATE',"+CRLF
cQry += "  	DIFREAL.CT2_VALOR * -1 													AS 'USD',"+CRLF
cQry += "  	'USD' 																	AS 'FCCODE',"+CRLF
cQry += "  	CT2.CT2_VALOR * -1  													AS 'TRXVALUE',"+CRLF
cQry += "  	'BRF' 																	AS 'TRXCODE',"+CRLF
cQry += " 	CT2.R_E_C_N_O_															AS 'RECNO',"+CRLF
cQry += " 	CT2.CT2_LP																AS 'LANCPAD',"+CRLF
cQry += " 	CT2.CT2_KEY																AS 'CT2_KEY'"+CRLF
cQry += "  FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQry += "  		LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT2_DEBITO = CT1_CONTA"+CRLF
cQry += "  		LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CT2_CCD = CTT_CUSTO "+CRLF
cQry += "  		LEFT JOIN(SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "+CRLF
cQry += "  					FROM "+RETSQLNAME("CT2")
cQry += "  					WHERE CT2_DC IN ('3') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02')"+CRLF
cQry += "  					) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA"+CRLF
cQry += "  WHERE CT2_DC IN ('3') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01')"+CRLF
cQry += " AND CT2_DATA BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFIM)+"'"+CRLF
//  --CREDITOS DA PARTIDA DOBRADA
cQry += " UNION ALL"+CRLF
cQry += " SELECT CT1_P_CONT 														AS 'NATACCOUNT', "+CRLF
cQry += " 	CT2_CREDIT 	   															AS 'HLBACCOUNT',"+CRLF
cQry += " 	CT1_DESC04 	   															AS 'ACCOUNTDESC', "+CRLF
cQry += " 	CT2_CCC 																AS 'CC',"+CRLF
cQry += " 	ISNULL(CTT_DESC01,'')													AS 'CCDESC',"+CRLF
cQry += " 	CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA 									AS 'JOURNAL',"+CRLF
cQry += " 	'' 																		AS 'JOURNALHEAD',"+CRLF
cQry += " 	CT2_HIST 																AS 'JOURNALLINE',"+CRLF
cQry += " 	'' 																		AS 'CUSTVENDID',"+CRLF
cQry += " 	'' 																		AS 'CUSTVENDNAME',"+CRLF
cQry += " 	''																		AS 'SOURCELEDGER',"+CRLF
cQry += " 	'' 																		AS 'DOCTYPE',"+CRLF
cQry += " 	SUBSTRING( CONVERT(VARCHAR(8), CONVERT(datetime,CT2_DATA,126),3),4,5) 	AS 'MTHYR',"+CRLF
cQry += " 	RIGHT('0'+(CONVERT(VARCHAR,MONTH(CT2_DATA))),2) 						AS 'PERIOD',"+CRLF
cQry += " 	CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),101) 				AS 'GLDATE',"+CRLF
cQry += " 	DIFREAL.CT2_VALOR 											  			AS 'USD',"+CRLF
cQry += " 	'USD' 																	AS 'FCCODE',"+CRLF
cQry += " 	CT2.CT2_VALOR 											   				AS 'TRXVALUE',"+CRLF
cQry += " 	'BRF' 											 						AS 'TRXCODE',"+CRLF
cQry += " 	CT2.R_E_C_N_O_															AS 'RECNO',"+CRLF
cQry += " 	CT2.CT2_LP																AS 'LANCPAD',"+CRLF
cQry += " 	CT2.CT2_KEY																AS 'CT2_KEY'"+CRLF
cQry += " FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQry += " 		LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT2_CREDIT = CT1_CONTA"+CRLF
cQry += " 		LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CT2_CCC = CTT_CUSTO "+CRLF
cQry += " 		LEFT JOIN (SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "+CRLF
cQry += "  					FROM "+RETSQLNAME("CT2")
cQry += "  					WHERE CT2_DC IN ('3') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02')"+CRLF
cQry += " 					) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA"+CRLF
cQry += " WHERE CT2_DC IN ('3') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01')"+CRLF
cQry += " AND CT2_DATA BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFIM)+"'"+CRLF

// --DECLARAÇÃO DO CURSOR
cQry += "  DECLARE ct2_cursor CURSOR FOR"+CRLF
cQry += " 	SELECT RECNO,LANCPAD,CT2_KEY FROM ##TEMPCT2"+CRLF

cQry += " OPEN ct2_cursor"+CRLF

cQry += " Fetch Next From ct2_cursor into @Recno,@LancPad,@CT2_KEY"+CRLF

cQry += " While @@FETCH_STATUS = 0"+CRLF
cQry += " 	Begin"+CRLF
		
cQry += " 		SET @Codigo	 = ''"+CRLF
cQry += " 		SET @Nome	 = ''"+CRLF
cQry += " 		SET @TabBusc = ''"+CRLF //RRP - 24/07/2015 - Chamado 028064.

//		--Busco na tabela 'relacionamentos contábies', qual a tabela e a chave de acordo com o lançamento padrão
cQry += " 		SELECT @TabBusc=CTL_ALIAS,@ChaveBusc=CTL_KEY FROM "+RETSQLNAME("CTL")
cQry += " 		WHERE CTL_LP=@LancPad"+CRLF

//		--RETIRO FUNÇÕES DO PROTHEUS DA CHAVE
cQry += " 		SET @ChaveBusc = REPLACE(@ChaveBusc,'DTOS','')"+CRLF
cQry += " 		SET @ChaveBusc = REPLACE(@ChaveBusc,'STOD','')"+CRLF
cQry += " 		SET @ChaveBusc = REPLACE(@ChaveBusc,'(','')"+CRLF
cQry += " 		SET @ChaveBusc = REPLACE(@ChaveBusc,')','')"+CRLF
cQry += " 		SET @ChaveBusc = RTRIM(@ChaveBusc)"+CRLF

//		--Verifico qual tabela o lancamento padrão faz parte para fazer a busca de cliente e fornecedor
cQry += " 		if @TabBusc='SF2'"+CRLF
cQry += " 			Begin"+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(A1_COD,'+''''+''''+') AS A1_COD ,ISNULL(A1_NOME,'+''''+''''+') AS A1_NOME FROM "+RETSQLNAME("SF2")+" SF2 "+CRLF
cQry += " 								JOIN "+RETSQLNAME("SA1")+" SA1 ON F2_CLIENTE=A1_COD AND F2_LOJA = A1_LOJA "+CRLF
cQry += " 								WHERE SF2.D_E_L_E_T_='+''''+''''+' AND SA1.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF
cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF
cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SD2' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(A1_COD,'+''''+''''+') AS A1_COD,ISNULL(A1_NOME,'+''''+''''+') AS A1_NOME FROM "+RETSQLNAME("SD2")+" SD2 "+CRLF
cQry += " 								JOIN "+RETSQLNAME("SA1")+" SA1 ON D2_CLIENTE=A1_COD AND D2_LOJA = A1_LOJA "+CRLF
cQry += " 								WHERE SD2.D_E_L_E_T_='+''''+''''+' AND SA1.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF
cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SF1' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(A2_COD,'+''''+''''+') AS A2_COD,ISNULL(A2_NOME,'+''''+''''+') AS A2_NOME FROM "+RETSQLNAME("SF1")+" SF1 "+CRLF
cQry += " 								JOIN "+RETSQLNAME("SA2")+" SA2 ON F1_FORNECE=A2_COD AND F1_LOJA = A2_LOJA "+CRLF
cQry += " 								WHERE SF1.D_E_L_E_T_='+''''+''''+' AND SA2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF

cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SD1' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(A2_COD,'+''''+''''+') AS A2_COD,ISNULL(A2_NOME,'+''''+''''+') AS A2_NOME FROM "+RETSQLNAME("SD1")+" SD1 "+CRLF
cQry += " 								JOIN "+RETSQLNAME("SA2")+" SA2 ON D1_FORNECE=A2_COD AND D1_LOJA = A2_LOJA "+CRLF
cQry += " 								WHERE SD1.D_E_L_E_T_='+''''+''''+' AND SA2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF
cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SE1' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(E1_CLIENTE,'+''''+''''+') AS E1_CLIENTE,ISNULL(E1_NOMCLI,'+''''+''''+') AS E1_NOMCLI FROM "+RETSQLNAME("SE1")+" SE1 "+CRLF
cQry += " 								WHERE SE1.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF
cQry += "  "+CRLF
cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End		 "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SE2' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(E2_FORNECE,'+''''+''''+') AS E2_FORNECE,ISNULL(E2_NOMFOR,'+''''+''''+') AS E2_NOMFOR FROM "+RETSQLNAME("SE2")+" SE2 "+CRLF
cQry += " 								WHERE SE2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF

cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SE5' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(CASE WHEN E5_RECPAG='+''''+'P'+''''+' THEN A2_COD ELSE A1_COD END,'+''''+''''+') AS [CODIGO],ISNULL(CASE WHEN E5_RECPAG='+''''+'P'+''''+' THEN A2_NOME ELSE A1_NOME END,'+''''+''''+') AS [NOME] FROM "+RETSQLNAME("SE5")+" SE5 "+CRLF
cQry += " 								LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_COD=E5_CLIFOR AND A2_LOJA=E5_LOJA AND SA2.D_E_L_E_T_='+''''+''''+' "+CRLF
cQry += " 								LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD=E5_CLIFOR AND A1_LOJA=E5_LOJA AND SA1.D_E_L_E_T_='+''''+''''+' "+CRLF
cQry += " 								WHERE SE5.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF

cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF

cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SC7' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(A2_COD,'+''''+''''+') AS A2_COD,ISNULL(A2_NOME,'+''''+''''+') AS A2_NOME FROM "+RETSQLNAME("SC7")+" SC7 "+CRLF
cQry += " 								JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA "+CRLF
cQry += " 								WHERE SC7.D_E_L_E_T_='+''''+''''+' AND SA2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF

cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End "+CRLF
cQry += " 		else "+CRLF
cQry += " 			if @TabBusc='SEF' "+CRLF
cQry += " 			Begin "+CRLF
cQry += " 				SET @Query = 'SELECT ISNULL(CASE WHEN EF_FORNECE<>'+''''+''+''''+' THEN A2_COD ELSE A1_COD END,'+''''+''''+') AS [CODIGO],ISNULL(CASE WHEN EF_FORNECE<>'+''''+''+''''+' THEN A2_NOME ELSE A1_NOME END,'+''''+''''+') AS [NOME] FROM "+RETSQLNAME("SEF")+" SEF "+CRLF
cQry += " 								LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_COD=EF_FORNECE AND A2_LOJA=EF_LOJA AND SA2.D_E_L_E_T_='+''''+''''+' "+CRLF
cQry += " 								LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD=EF_CLIENTE AND A1_LOJA=EF_LOJACLI AND SA1.D_E_L_E_T_='+''''+''''+' "+CRLF
cQry += " 								WHERE EF_SEQUENC='+''''+'01'+''''+' AND SEF.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' "+CRLF

cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End						 "+CRLF
cQry += " 		else "+CRLF
cQry += " 			Begin"+CRLF
cQry += " 				SET @Query = 'SELECT '+''''+''''+' ,'+''''+''''	"+CRLF
cQry += " 				insert @TabCliFor exec(@Query) "+CRLF
cQry += " 			End
//		--grava nas variaveis de codigo e nome o resultado da busca acima, que está na tabela temporária @TabCliFor					
cQry += " 		SELECT @Codigo=ISNULL(Codigo,''),@Nome=ISNULL(Nome,'') FROM @TabCliFor "+CRLF
cQry += " 		DELETE FROM @TabCliFor "+CRLF
cQry += " 		
// 		--Atualizo a temporária para ter o código do cliente/fornecedor + o nome	
cQry += " 		Update ##TEMPCT2 Set CUSTVENDID=@Codigo ,CUSTVENDNAME=@Nome "+CRLF
cQry += " 		where RECNO=@Recno "+CRLF

cQry += " 		Fetch Next From ct2_cursor into @Recno,@LancPad,@CT2_KEY "+CRLF
cQry += " 	End "+CRLF

cQry += " Close ct2_cursor "+CRLF
cQry += " Deallocate ct2_cursor "


//MSM - 17/07/2014 - Executa  o comando para criar a procedure.  - Chamado: 020128
nRet:=TCSQLEXEC(cQry)

if nRet<0
	conout("ERRO"+CRLF)
	conout(TCSQLError())
endif

//MSM - 17/07/2014 - Executa a procedure
nRet:=TCSQLEXEC("exec SP_P_RELATORIO_FONTE_O9CTB001")

if nRet<0
	conout("ERRO"+CRLF)
	conout(TCSQLError())
endif

//MSM - 17/07/2014 - Select na temporária criada pela procedure. - Chamado: 020128
cQry := " SELECT * FROM ##TEMPCT2
cQry += " ORDER BY 'MTHYR','GLDATE','JOURNAL'


if SELECT("QRY")>0
	DbCloseArea("QRY")
endif

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.T.,.T.)

QRY->(DbGoTop())

If QRY->(EOF()) .and. QRY->(BOF())  
	oSay3:CCAPTION := "Sem dados para Exibir!"   
	oBtn2:LVISIBLE := .F.
	Return .T.
EndIf                                                                 

If File(cDirArq+cArq)
	If FErase(cDirArq+cArq) <> 0
		oSay3:CCAPTION := "Falha na tentativa de apagar o arquivo antigo na Pasta '"+ALLTRIM(cDirArq)+"'!" 
		oBtn2:LVISIBLE := .F. 
		Return .T.
	EndIf
EndIf 

nHdl		:= FCREATE(cDirArq+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, "" ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

//Gera Arquivo Excel.
WriteXML()

If File(cDirArq+cArq)
	oSay3:CCAPTION := "Arquivo Gerado na Pasta '"+ALLTRIM(cDirArq+cArq)+"'!"   
Else
	oSay3:CCAPTION := "Falha na Geração do Arquivo na Pasta '"+ALLTRIM(cDirArq)+"'!" 
	oBtn2:LVISIBLE := .F. 
EndIf


//MSM - 17/07/2014 - Dropa a tabela temporária criada no banco. - Chamado: 020128
TCSQLEXEC("DROP TABLE ##TEMPCT2")

Return .T.
 
/*
Funcao      : GrvXLS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função responsavel pela gravação do arquivo XLS.
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*--------------------------*
Static Function GrvXLS(cMsg)
*--------------------------*
Local nHdl		:= Fopen(cDirArq+cArq)
FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)
Return ""

/*
Funcao      : WriteXML
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função responsavel pela Geração do arquivo XLS.
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*------------------------*
Static Function WriteXML()
*------------------------*
Local cXml := "" 
Local lColor := .T.

cXml += ' <?xml version="1.0"?>
cXml += ' <?mso-application progid="Excel.Sheet"?>
cXml += ' <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml += '  xmlns:o="urn:schemas-microsoft-com:office:office"
cXml += '  xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml += '  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml += '  xmlns:html="http://www.w3.org/TR/REC-html40">
cXml += '  <Styles>
cXml += '   <Style ss:ID="Default" ss:Name="Normal">
cXml += '    <Alignment ss:Vertical="Bottom"/>
cXml += '    <Borders/>
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml += '    <Interior/>
cXml += '    <NumberFormat/>
cXml += '    <Protection/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s64">
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s140">
cXml += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '    <Interior ss:Color="#8064A2" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s155">
cXml += '    <Borders/>
cXml += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '   <Style ss:ID="s185">
cXml += '    <Borders/>
cXml += '    <Interior ss:Color="#E4DFEC" ss:Pattern="Solid"/>
cXml += '    <NumberFormat ss:Format="@"/>
cXml += '   </Style>
cXml += '  </Styles>
cXml += '  <Worksheet ss:Name="'+LEFT(FWEmpName(cEmpAnt),15)+'">
cXml += '   <Table ss:ExpandedColumnCount="19" ss:ExpandedRowCount="999999" x:FullColumns="1" x:FullRows="1" ss:StyleID="s64" ss:DefaultRowHeight="15">
cXml += '    <Column ss:StyleID="s64" ss:Width="92.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="75"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="189"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="98.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="148.5"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="101.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="100.5"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="202.5"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="89.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="108"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="83.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="90.75"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="51"/>
cXml += '    <Column ss:Index="15" ss:StyleID="s64" ss:Width="75"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="74.25"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="73.5"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="60.75"/>
cXml += '    <Column ss:StyleID="s64" ss:Width="76.5"/>
cXml += '    <Row>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Natural Account		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">HLB Account				</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Account Description	</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Cost Center Code		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">CC Desc				</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Journal #				</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Journal head desc		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Journal line desc		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Cust/Vendor ID	   		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Cust/Vendor Name		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Source Ledger	   		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Document Type	   		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Mth/Yr			  		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Period			  		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">GL post date	  		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">USD Activity	   		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">FC curr code	  		</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Trx Value				</Data></Cell>
cXml += '     <Cell ss:StyleID="s140"><Data ss:Type="String">Trx curr code			</Data></Cell>
cXml += '    </Row>

cXml := GrvXLS(cXml) //Grava e limpa memoria da variavel.

QRY->(DbGoTop())
While QRY->(!EOF())
	If lColor
		cStyleId := "s185"
	Else
		cStyleId := "s155"
	EndIf            
	
	lColor := !lColor	
	
	cXml += '    <Row>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->NATACCOUNT								+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->HLBACCOUNT								+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->ACCOUNTDESC								+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->CC										+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->CCDESC									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->JOURNAL									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->JOURNALHEAD								+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->JOURNALLINE								+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+alltrim(QRY->CUSTVENDID)						+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+alltrim(QRY->CUSTVENDNAME)					+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->SOURCELEDGER							+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->DOCTYPE									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->MTHYR									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->PERIOD									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->GLDATE									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM(QRY->USD		,"@R 999999999999.99"),",","."))+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->FCCODE									+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM(QRY->TRXVALUE	,"@R 999999999999.99"),",","."))+'</Data></Cell>
	cXml += '     <Cell ss:StyleID="'+cStyleId+'"><Data ss:Type="String">'+QRY->TRXCODE									+'</Data></Cell>
	cXml += '    </Row>            
	
	If Len(cXml) >= 30000
		cXml := GrvXLS(cXml) //Grava e limpa memoria da variavel.
	EndIf
	
	QRY->(DbSkip())
EndDO

cXml += '   </Table>
cXml += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXml += '    <PageSetup>
cXml += '     <Header x:Margin="0.31496062000000002"/>
cXml += '     <Footer x:Margin="0.31496062000000002"/>
cXml += '     <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>
cXml += '    </PageSetup>
cXml += '    <Print>
cXml += '     <ValidPrinterInfo/>
cXml += '     <PaperSizeIndex>9</PaperSizeIndex>
cXml += '     <Scale>26</Scale>
cXml += '     <HorizontalResolution>600</HorizontalResolution>
cXml += '     <VerticalResolution>600</VerticalResolution>
cXml += '    </Print>
cXml += '    <ShowPageBreakZoom/>
cXml += '    <PageBreakZoom>100</PageBreakZoom>
cXml += '    <Selected/>
cXml += '   </WorksheetOptions>
cXml += '   <AutoFilter x:Range="R1C1:R1C19" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>
cXml += '  </Worksheet>
cXml += ' </Workbook>

cXml := GrvXLS(cXml) //Grava e limpa memoria da variavel.

Return .T.