#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : LWCTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório Equant/Orange
Autor       : Renato Rezende
Data/Hora   : 29/07/2014
*/                          
*-------------------------*
 User Function LWCTB001()
*-------------------------*
Private cPerg		:= ""
Private titulo		:= "Relatório Equant"
Private titulo2		:= "Executando a Consulta"
Private cDest		:= ""
Private cArq		:= ""
Private cQuery		:= ""
Private nBytesSalvo	:= 0 
Private nRecCount	:= 0
Private cQuery2     := ""
Private cQuery3		:= ""

//Verificando se está na empresa Equant
If !(cEmpAnt) $ "LW/LX"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "LWCTB1"
//Criando Pergunte
CriaPerg()
//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return  
EndIf

//Gravado no local indicado pelo pergunte
cDest	:=  ALLTRIM(mv_par07)

If FILE (cDest+"_Equant.xls")
	FERASE (cDest+"_Equant.xls")
EndIf
cArq	:= "_Equant.xls"

GeraTMP()                      	

Return

/*
Funcao      : GeraHtm
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório
Autor     	: Renato Rezende  	 	
Data     	: 29/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*------------------------------*
 Static Function GeraHtm(cTabTemp)
*------------------------------*
Local cHtml			:= ""
Local aTitCab		:= ""
Local cLinha		:= ""
Local lCor			:= .T.

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""
aTitCab	:= ""

//Cabeçalho das colunas do relatório
aTitCab1:= {'VENDORNUM',;
			'VENDORNAME',;
			'INVOICEDATE',;
			'INVOICEDUEDATE',;
			'PAIDDATE',;
			'INVOICENUM',;
			'TRANSACTIONDATE',;
			'CURRENCYCOD',;
			'DEBCRE',;
			'AMOUNTCURCREDIT',;
			'AMOUNTCURDEBIT',;
			'COMPANY',;
			'COSTCENTER',;
			'OFFSETACCOUNT',;
			'TXT',;
			'CHAVE'}
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeçalho no relatório
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

TMP->(DbGoTop())

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()
	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor	

	cHtml+='		<tr>'             

	cHtml+='			<td class="'+cLinha+'" width=180>'+'="'+Alltrim(TMP->VENDORNUM)+'"</td>'
	cHtml+='			<td class="'+cLinha+'" width=350>'+Alltrim(TMP->VENDORNAME)+'</td>'
	cHtml+='			<td class="'+cLinha+'" width=180>'+Alltrim(TMP->INVOICEDATE)+'</td>'
	cHtml+='			<td class="'+cLinha+'" width=180>'+Alltrim(TMP->INVOICEDUEDATE)+'</td>'
	cHtml+='			<td class="'+cLinha+'" width=180>'+Alltrim(TMP->PAIDDATE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+Alltrim(TMP->INVOICENUM)+'"</td>'
	cHtml+='			<td class="'+cLinha+'" width=180>'+Alltrim(TMP->TRANSACTIONDATE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->CURRENCYCOD)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->DEBCRE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->AMOUNTCURCREDIT),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((TMP->AMOUNTCURDEBIT),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->COMPANY)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->COSTCENTER)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->OFFSETACCOUNT)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TMP->TXT)+'</td>'
	cHtml+='			<td class="'+cLinha+'" width=300>'+'="'+Alltrim(TMP->CHAVE)+'"</td>'
	cHtml+='		</tr>'
	
	cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.	
	
	TMP->(DbSkip())
EndDo
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

//Dropa a tabela Temporária
cQuery3:= "DROP TABLE "+cTabTemp + CRLF
If TcSqlExec(cQuery3) < 0
	conout("ERRO"+CRLF)
	conout(TCSQLError())
EndIf

GeraExcel()

Return cHtml

/*
Funcao      : GeraTMP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório
Autor     	: Renato Rezende  	 	
Data     	: 29/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*------------------------------*
 Static Function GeraTMP()
*------------------------------*
cQuery	:= ""
cQuery2	:= ""
cQuery3	:= ""

cTabTemp:= "##TEMPCT2_"+alltrim(STRTRAN(Time(),":",""))

//Verificando se a procedure existe
If !TCSPExist("SP_P_RELATORIO_FONTE_LWCTB001")
	cQuery+= " CREATE PROCEDURE SP_P_RELATORIO_FONTE_LWCTB001 "  + CRLF
Else
	cQuery+= " ALTER PROCEDURE SP_P_RELATORIO_FONTE_LWCTB001 "  + CRLF
Endif

//Início do Select
cQuery+= "AS "  + CRLF 
cQuery+= "SET NOCOUNT ON"  + CRLF 
cQuery+= "Declare @Codigo VARCHAR(10); "  + CRLF
cQuery+= "Declare @Nome VARCHAR(200); "  + CRLF
cQuery+= "Declare @Nota VARCHAR(10); "  + CRLF
cQuery+= "Declare @Emissao VARCHAR(10); "  + CRLF
cQuery+= "Declare @Vencimento VARCHAR(10); "  + CRLF
cQuery+= "Declare @Baixa VARCHAR(10); "  + CRLF
cQuery+= "Declare @Recno int; "  + CRLF
cQuery+= "Declare @LancPad VarChar(6); "  + CRLF
cQuery+= "Declare @CT2_KEY VarChar(500); "  + CRLF
cQuery+= "Declare @Query VarChar(8000); "  + CRLF
cQuery+= "Declare @TabBusc Varchar(3); "  + CRLF
cQuery+= "Declare @ChaveBusc Varchar(500); "  + CRLF
cQuery+= "Declare @TabCliFor TABLE(Codigo varchar(10), Nome varchar(200), Nota varchar(10), Emissao varchar(8),Vencimento varchar(8),Baixa varchar(8)) "  + CRLF

cQuery+= "SET @Codigo=''"  + CRLF 
cQuery+= "SET @Nome=''"  + CRLF 
cQuery+= "SET @Emissao=''"  + CRLF 
cQuery+= "SET @Vencimento=''"  + CRLF 
cQuery+= "SET @Baixa=''"  + CRLF 
cQuery+= "SET @Nota=''"  + CRLF 

cQuery+= " if object_id('tempdb.."+cTabTemp+"') IS NOT NULL"  + CRLF 
cQuery+= "	begin"  + CRLF 
cQuery+= "		DROP TABLE "+cTabTemp  + CRLF 
cQuery+= "	end"  + CRLF 


cQuery+= "SELECT "  + CRLF 
cQuery+= "@Codigo AS 'VENDORNUM', "  + CRLF
cQuery+= "@Nome AS 'VENDORNAME', "  + CRLF
cQuery+= "@Emissao AS 'INVOICEDATE', "  + CRLF
cQuery+= "@Vencimento AS 'INVOICEDUEDATE', "  + CRLF
cQuery+= "@Baixa AS 'PAIDDATE', "  + CRLF
cQuery+= "@Nota AS 'INVOICENUM', "  + CRLF

cQuery+= "CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),103)AS 'TRANSACTIONDATE', "  + CRLF
cQuery+= "CTO.CTO_SIMB AS 'CURRENCYCOD', "  + CRLF
cQuery+= "CASE WHEN CT2_DC='1' THEN 'D' ELSE 'C' END AS 'DEBCRE', "  + CRLF
cQuery+= "CASE WHEN CT2_DC='2' THEN CT2.CT2_VALOR ELSE '' END AS 'AMOUNTCURCREDIT', "  + CRLF
cQuery+= "CASE WHEN CT2_DC='1' THEN CT2.CT2_VALOR ELSE '' END AS 'AMOUNTCURDEBIT', "  + CRLF
cQuery+= "CASE WHEN 'LW'='"+cEmpAnt+"' THEN 'GBJ' ELSE 'GBH' END AS 'COMPANY', "  + CRLF
cQuery+= "CASE WHEN CT2_DC='1' THEN CT2_CCD ELSE CT2_CCC END AS 'COSTCENTER', "  + CRLF
cQuery+= "CASE WHEN CT2_DC='1' THEN CT2_DEBITO ELSE CT2_CREDIT END AS 'OFFSETACCOUNT', "  + CRLF

cQuery+= "CT2_HIST AS 'TXT', "  + CRLF
cQuery+= "CT2.R_E_C_N_O_ AS 'RECNO', "  + CRLF
cQuery+= "CT2.CT2_LP AS 'LANCPAD', "  + CRLF
cQuery+= "CT2.CT2_KEY AS 'CT2_KEY', "  + CRLF
cQuery+= "CT2.CT2_DATA+ CT2.CT2_LOTE+ CT2.CT2_SBLOTE+ CT2.CT2_DOC+CT2_LINHA AS 'CHAVE' "  + CRLF

cQuery+= "INTO "+cTabTemp  + CRLF
cQuery+= "FROM "+RETSQLNAME("CT2")+" CT2 "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON (CASE WHEN CT2_DC='1' THEN CT2_DEBITO ELSE CT2_CREDIT END) = CT1_CONTA "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON (CASE WHEN CT2_DC='1' THEN CT2_CCD ELSE CT2_CCC END) = CTT_CUSTO "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTO")+" CTO ON CT2_MOEDLC=CTO_MOEDA AND CTO.D_E_L_E_T_='' "  + CRLF
cQuery+= "	LEFT JOIN (SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "  + CRLF
cQuery+= "				 FROM "+RETSQLNAME("CT2")+"  WHERE CT2_DC IN ('1','2') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02') "  + CRLF
cQuery+= "			   ) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA "  + CRLF
cQuery+= "	JOIN "+RETSQLNAME("CTL")+" CTL ON CTL_LP = CT2_LP AND CTL_ALIAS IN ('SE2','SD1','SF1','SE5') "  + CRLF
cQuery+= "WHERE CT2_DC IN ('1','2') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01') "  + CRLF
//Inclusão dos filtros
//Data De/Ate
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND CT2_DATA BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"' " + CRLF
EndIf
//Conta De/Ate
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND ((CT2_CREDIT >= '"+Alltrim(mv_par01)+"' AND CT2_CREDIT <= '"+Alltrim(mv_par02)+"' )" + CRLF
	cQuery += " 	  OR (CT2_DEBITO >= '"+Alltrim(mv_par01)+"' AND CT2_DEBITO <= '"+Alltrim(mv_par02)+"' ))" + CRLF
EndIf
//Centro de Custo De/Ate
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND ((CT2_CCC >= '"+Alltrim(mv_par05)+"' AND CT2_CCC <= '"+Alltrim(mv_par06)+"' )" + CRLF
	cQuery += " 	  OR (CT2_CCD >= '"+Alltrim(mv_par05)+"' AND CT2_CCD <= '"+Alltrim(mv_par06)+"' ))" + CRLF
EndIf

cQuery+= "--PARTIDA DOBRADA - CREDITO "  + CRLF

cQuery+= "UNION ALL "  + CRLF

cQuery+= "SELECT "  + CRLF 
cQuery+= "@Codigo AS 'VENDORNUM', "  + CRLF
cQuery+= "@Nome AS 'VENDORNAME', "  + CRLF
cQuery+= "@Emissao AS 'INVOICEDATE', "  + CRLF
cQuery+= "@Vencimento AS 'INVOICEDUEDATE', "  + CRLF
cQuery+= "@Baixa AS 'PAIDDATE', "  + CRLF
cQuery+= "@Nota AS 'INVOICENUM', "  + CRLF

cQuery+= "CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),103)AS 'TRANSACTIONDATE', "  + CRLF
cQuery+= "CTO.CTO_SIMB AS 'CURRENCYCOD', "  + CRLF
cQuery+= "'C' AS 'DEBCRE', "  + CRLF
cQuery+= "CT2.CT2_VALOR AS 'AMOUNTCURCREDIT', "  + CRLF
cQuery+= "'' AS 'AMOUNTCURDEBIT', "  + CRLF
cQuery+= "CASE WHEN 'LW'='"+cEmpAnt+"' THEN 'GBJ' ELSE 'GBH' END AS 'COMPANY', "  + CRLF
cQuery+= "CT2_CCC AS 'COSTCENTER', "  + CRLF
cQuery+= "CT2_CREDIT AS 'OFFSETACCOUNT', "  + CRLF
cQuery+= "CT2_HIST AS 'TXT', "  + CRLF
cQuery+= "CT2.R_E_C_N_O_ AS 'RECNO', "  + CRLF
cQuery+= "CT2.CT2_LP AS 'LANCPAD', "  + CRLF
cQuery+= "CT2.CT2_KEY AS 'CT2_KEY', "  + CRLF
cQuery+= "CT2.CT2_DATA+ CT2.CT2_LOTE+ CT2.CT2_SBLOTE+ CT2.CT2_DOC+CT2_LINHA AS 'CHAVE' "  + CRLF

cQuery+= "FROM "+RETSQLNAME("CT2")+" CT2 "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT2_DEBITO = CT1_CONTA "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CT2_CCD = CTT_CUSTO "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTO")+" CTO ON CT2_MOEDLC=CTO_MOEDA AND CTO.D_E_L_E_T_='' "  + CRLF
cQuery+= "	LEFT JOIN(SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "  + CRLF 
cQuery+= "				FROM "+RETSQLNAME("CT2")+"  WHERE CT2_DC IN ('3') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02') "  + CRLF
cQuery+= "			  ) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA "  + CRLF
cQuery+= "	JOIN "+RETSQLNAME("CTL")+" CTL ON CTL_LP = CT2_LP AND CTL_ALIAS IN ('SE2','SD1','SF1','SE5') "  + CRLF
cQuery+= "WHERE CT2_DC IN ('3') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01') "  + CRLF
//Inclusão dos filtros
//Data De/Ate
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND CT2_DATA BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"' " + CRLF
EndIf
//Conta De/Ate
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND (CT2_CREDIT >= '"+Alltrim(mv_par01)+"' AND CT2_CREDIT <= '"+Alltrim(mv_par02)+"' )" + CRLF
EndIf
//Centro de Custo De/Ate
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND (CT2_CCC >= '"+Alltrim(mv_par05)+"' AND CT2_CCC <= '"+Alltrim(mv_par06)+"' )" + CRLF
EndIf

cQuery+= "--PARTIDA DOBRADA - DEBITO "  + CRLF

cQuery+= "UNION ALL "  + CRLF
cQuery+= "SELECT "  + CRLF 
cQuery+= "@Codigo AS 'VENDORNUM', "  + CRLF
cQuery+= "@Nome AS 'VENDORNAME', "  + CRLF
cQuery+= "@Emissao AS 'INVOICEDATE', "  + CRLF
cQuery+= "@Vencimento AS 'INVOICEDUEDATE', "  + CRLF
cQuery+= "@Baixa AS 'PAIDDATE', "  + CRLF
cQuery+= "@Nota AS 'INVOICENUM', "  + CRLF

cQuery+= "CONVERT(VARCHAR(10), CONVERT(datetime,CT2_DATA,126),103)AS 'TRANSACTIONDATE', "  + CRLF
cQuery+= "CTO.CTO_SIMB AS 'CURRENCYCOD', "  + CRLF
cQuery+= "'D' AS 'DEBCRE', "  + CRLF
cQuery+= "''AS 'AMOUNTCURCREDIT', "  + CRLF
cQuery+= "CT2.CT2_VALOR AS 'AMOUNTCURDEBIT', "  + CRLF
cQuery+= "CASE WHEN 'LW'='"+cEmpAnt+"' THEN 'GBJ' ELSE 'GBH' END AS 'COMPANY', "  + CRLF
cQuery+= "CT2_CCD AS 'COSTCENTER', "  + CRLF
cQuery+= "CT2_DEBITO AS 'OFFSETACCOUNT', "  + CRLF
cQuery+= "CT2_HIST AS 'TXT',"  + CRLF
cQuery+= "CT2.R_E_C_N_O_ AS 'RECNO', "  + CRLF
cQuery+= "CT2.CT2_LP AS 'LANCPAD', "  + CRLF
cQuery+= "CT2.CT2_KEY AS 'CT2_KEY', "  + CRLF
cQuery+= "CT2.CT2_DATA+ CT2.CT2_LOTE+ CT2.CT2_SBLOTE+ CT2.CT2_DOC+CT2_LINHA AS 'CHAVE' "  + CRLF

cQuery+= "FROM "+RETSQLNAME("CT2")+" CT2 "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT2_DEBITO = CT1_CONTA "  + CRLF
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CT2_CCD = CTT_CUSTO "  + CRLF 
cQuery+= "	LEFT JOIN "+RETSQLNAME("CTO")+" CTO ON CT2_MOEDLC=CTO_MOEDA AND CTO.D_E_L_E_T_='' "  + CRLF
cQuery+= "	LEFT JOIN(SELECT CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS ID ,CT2_VALOR,CT2_MOEDLC "  + CRLF 
cQuery+= "				FROM "+RETSQLNAME("CT2")+"  WHERE CT2_DC IN ('3') AND D_E_L_E_T_='' AND CT2_MOEDLC IN ('02') "  + CRLF
cQuery+= "			  ) AS DIFREAL ON DIFREAL.ID = CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA "  + CRLF
cQuery+= "	JOIN "+RETSQLNAME("CTL")+" CTL ON CTL_LP = CT2_LP AND CTL_ALIAS IN ('SE2','SD1','SF1','SE5') "  + CRLF
cQuery+= "WHERE CT2_DC IN ('3') AND CT1.D_E_L_E_T_='' AND CT2.D_E_L_E_T_='' AND CT2.CT2_MOEDLC IN ('01') "  + CRLF
//Inclusão dos filtros
//Data De/Ate
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND CT2_DATA BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"' " + CRLF
EndIf
//Conta De/Ate
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND (CT2_DEBITO >= '"+Alltrim(mv_par01)+"' AND CT2_DEBITO <= '"+Alltrim(mv_par02)+"' )" + CRLF
EndIf
//Centro de Custo De/Ate
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND (CT2_CCD >= '"+Alltrim(mv_par05)+"' AND CT2_CCD <= '"+Alltrim(mv_par06)+"' )" + CRLF
EndIf

cQuery+= "CREATE INDEX IDX_RECNO ON "+cTabTemp+"(RECNO)"+CRLF
cQuery+= "BEGIN TRANSACTION"  + CRLF

cQuery+= "DECLARE ct2_cursor CURSOR FOR "  + CRLF

cQuery+= "SELECT RECNO,LANCPAD,CT2_KEY FROM "+cTabTemp  + CRLF

cQuery+= "OPEN ct2_cursor "  + CRLF

cQuery+= "Fetch Next From ct2_cursor into @Recno,@LancPad,@CT2_KEY "  + CRLF
 
cQuery+= "While @@FETCH_STATUS = 0 " + CRLF
cQuery+= "Begin " + CRLF
cQuery+= "	SET @Codigo= '' " + CRLF
cQuery+= "	SET @Nome= '' " + CRLF
cQuery+= "	SELECT @TabBusc=CTL_ALIAS,@ChaveBusc=CTL_KEY FROM "+RETSQLNAME("CTL")+" WHERE CTL_LP=@LancPad " + CRLF
cQuery+= "	SET @ChaveBusc = REPLACE(@ChaveBusc,'DTOS','') " + CRLF
cQuery+= "	SET @ChaveBusc = REPLACE(@ChaveBusc,'STOD','') " + CRLF
cQuery+= "	SET @ChaveBusc = REPLACE(@ChaveBusc,'(','') " + CRLF
cQuery+= "	SET @ChaveBusc = REPLACE(@ChaveBusc,')','') " + CRLF
cQuery+= "	SET @ChaveBusc = RTRIM(@ChaveBusc) " + CRLF

cQuery+= "	if @TabBusc='SE2' " + CRLF 
cQuery+= "	Begin " + CRLF 
cQuery+= "		SET @Query = 'SELECT ISNULL(E2_FORNECE,'+''''+''''+') AS E2_FORNECE,ISNULL(E2_NOMFOR,'+''''+''''+'),E2_NUM,E2_EMISSAO,E2_VENCREA,E2_BAIXA AS E2_NOMFOR FROM "+RETSQLNAME("SE2")+" SE2 " + CRLF 
cQuery+= "							  WHERE SE2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' " + CRLF 
cQuery+= "		insert @TabCliFor exec(@Query) " + CRLF 
cQuery+= "	End " + CRLF 
cQuery+= "	else " + CRLF
cQuery+= "		if @TabBusc='SF1' " + CRLF 
cQuery+= "		Begin " + CRLF 
cQuery+= "			SET @Query = 'SELECT ISNULL(A2_COD,'+''''+''''+') ,ISNULL(A2_NOME,'+''''+''''+') ,ISNULL(E2_NUM,'+''''+''''+') ,ISNULL(E2_EMISSAO,'+''''+''''+') ,ISNULL(E2_VENCREA,'+''''+''''+') ,ISNULL(E2_BAIXA,'+''''+''''+') FROM "+RETSQLNAME("SF1")+" SF1 " + CRLF 
cQuery+= "							JOIN "+RETSQLNAME("SA2")+" SA2 ON F1_FORNECE=A2_COD AND F1_LOJA = A2_LOJA " + CRLF 
cQuery+= "							LEFT JOIN "+RETSQLNAME("SE2")+" SE2 ON E2_FILORIG=F1_FILIAL AND F1_PREFIXO=E2_PREFIXO AND F1_DUPL=E2_NUM AND F1_FORNECE=E2_FORNECE AND F1_LOJA=E2_LOJA AND SE2.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "						  WHERE SF1.D_E_L_E_T_='+''''+''''+' AND SA2.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' " + CRLF 
cQuery+= "			insert @TabCliFor exec(@Query) " + CRLF 
cQuery+= "		End " + CRLF
cQuery+= "		else " + CRLF 
cQuery+= "			if @TabBusc='SD1' " + CRLF 
cQuery+= "			Begin " + CRLF 
cQuery+= "				SET @Query = 'SELECT ISNULL(A2_COD,'+''''+''''+'),ISNULL(A2_NOME,'+''''+''''+'),ISNULL(E2_NUM,'+''''+''''+'),ISNULL(E2_EMISSAO,'+''''+''''+'),ISNULL(E2_VENCREA,'+''''+''''+'),ISNULL(E2_BAIXA,'+''''+''''+') FROM "+RETSQLNAME("SD1")+" SD1 " + CRLF 
cQuery+= "								JOIN "+RETSQLNAME("SF1")+" SF1 ON D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA=F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA AND SF1.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "								JOIN "+RETSQLNAME("SA2")+" SA2 ON F1_FORNECE=A2_COD AND F1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "								LEFT JOIN "+RETSQLNAME("SE2")+" SE2 ON E2_FILORIG=F1_FILIAL AND F1_PREFIXO=E2_PREFIXO AND F1_DUPL=E2_NUM AND F1_FORNECE=E2_FORNECE AND F1_LOJA=E2_LOJA AND SE2.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "							  WHERE SD1.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' " + CRLF 
cQuery+= "				insert @TabCliFor exec(@Query) " + CRLF 
cQuery+= "			End " + CRLF  
cQuery+= "			else	" + CRLF
cQuery+= "				if @TabBusc='SE5'" + CRLF 
cQuery+= "				Begin " + CRLF
cQuery+= "					SET @Query = 'SELECT ISNULL(CASE WHEN E5_RECPAG='+''''+'P'+''''+' THEN A2_COD ELSE A1_COD END,'+''''+''''+') AS [CODIGO],ISNULL(CASE WHEN E5_RECPAG='+''''+'P'+''''+' THEN A2_NOME ELSE A1_NOME END,'+''''+''''+') AS [NOME],ISNULL(E2_NUM,'+''''+''''+'),ISNULL(E2_EMISSAO,'+''''+''''+'),ISNULL(E2_VENCREA,'+''''+''''+'),ISNULL(E2_BAIXA,'+''''+''''+')  FROM "+RETSQLNAME("SE5")+" SE5 " + CRLF
cQuery+= "								LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_COD=E5_CLIFOR AND A2_LOJA=E5_LOJA AND SA2.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "								LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON A1_COD=E5_CLIFOR AND A1_LOJA=E5_LOJA AND SA1.D_E_L_E_T_='+''''+''''+' " + CRLF
cQuery+= "								LEFT JOIN "+RETSQLNAME("SE2")+" SE2 ON E2_PREFIXO=E5_PREFIXO AND E2_NUM=E5_NUMERO AND E2_PARCELA=E5_PARCELA AND E2_TIPO=E5_TIPO AND E2_FORNECE=E5_CLIFOR AND E2_LOJA=E5_LOJA  AND SE2.D_E_L_E_T_='+''''+''''+'  " + CRLF
cQuery+= "								WHERE SE5.D_E_L_E_T_='+''''+''''+' AND '+ @ChaveBusc +' ='+''''+ @CT2_KEY+'''' " + CRLF

cQuery+= "	 				insert @TabCliFor exec(@Query) " + CRLF

cQuery+= "	 			End " + CRLF
cQuery+= "				else " + CRLF 
cQuery+= "				Begin " + CRLF
cQuery+= "					SET @Query = 'SELECT '+''''+''''+' ,'+''''+''''+' ,'+''''+''''+' ,'+''''+''''+' ,'+''''+''''+' ,'+''''+'''' " + CRLF
cQuery+= "					insert @TabCliFor exec(@Query) " + CRLF 
cQuery+= "				End " + CRLF 

cQuery+= "		if @TabBusc='SE5' AND (SELECT COUNT(*) FROM @TabCliFor WHERE Nota='')>0"  + CRLF 
cQuery+= "			begin"  + CRLF 
cQuery+= "           		DELETE FROM "+cTabTemp  + CRLF 
cQuery+= "           		WHERE RECNO=@Recno "  + CRLF 
cQuery+= "           	end"  + CRLF 

cQuery+= "		if (select count(*) from @TabCliFor)>0"  + CRLF 
cQuery+= "          begin"  + CRLF 
cQuery+= "			SELECT @Codigo=ISNULL(Codigo,''),@Nome=ISNULL(Nome,''),@Nota=ISNULL(Nota,''),@Emissao=ISNULL(Emissao,''),@Vencimento=ISNULL(Vencimento,''),@Baixa=ISNULL(Baixa,'') FROM @TabCliFor " + CRLF 

cQuery+= "			DELETE FROM @TabCliFor " + CRLF 

cQuery+= "			Update "+cTabTemp+" Set VENDORNUM=@Codigo , " + CRLF
cQuery+= "			VENDORNAME=@Nome, " + CRLF
cQuery+= "			INVOICENUM=@Nota, " + CRLF
cQuery+= "			INVOICEDATE= CASE WHEN @Emissao='' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(datetime,@Emissao,126),103) END, " + CRLF
cQuery+= "			INVOICEDUEDATE= CASE WHEN @Emissao='' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(datetime,@Vencimento,126),103) END, " + CRLF
cQuery+= "			PAIDDATE= CASE WHEN @Baixa='' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(datetime,@Baixa,126),103) END " + CRLF 
cQuery+= "			where RECNO=@Recno " + CRLF 
cQuery+= "			end"  + CRLF 

cQuery+= "		Fetch Next From ct2_cursor into @Recno,@LancPad,@CT2_KEY " + CRLF 
cQuery+= "End " + CRLF
				
cQuery+= "Close ct2_cursor " + CRLF 
cQuery+= "Deallocate ct2_cursor " + CRLF

cQuery+= "COMMIT" + CRLF

cQuery+= "SELECT VENDORNUM " + CRLF
cQuery+= ",VENDORNAME " + CRLF
cQuery+= ",INVOICEDATE " + CRLF
cQuery+= ",INVOICEDUEDATE " + CRLF
cQuery+= ",PAIDDATE " + CRLF
cQuery+= ",INVOICENUM " + CRLF
cQuery+= ",TRANSACTIONDATE " + CRLF
cQuery+= ",CURRENCYCOD " + CRLF
cQuery+= ",AMOUNTCURCREDIT " + CRLF
cQuery+= ",AMOUNTCURDEBIT " + CRLF
cQuery+= ",COMPANY " + CRLF
cQuery+= ",COSTCENTER " + CRLF
cQuery+= ",OFFSETACCOUNT " + CRLF
cQuery+= ",TXT " + CRLF
cQuery+= ",CHAVE " + CRLF
cQuery+= "FROM "+cTabTemp + CRLF
//cQuery+= "DROP TABLE #TEMPCT2 " + CRLF

//Criando ou alterando a procedure
If TcSqlExec(cQuery) < 0
	msgstop("ERRO"+CRLF+TCSQLError())
	return()
EndIf 

//Executa a procedure.
Processa({|| GProcessa()},titulo2)

cQuery2:= " SELECT * FROM "+cTabTemp
cQuery2+= " ORDER BY VENDORNAME,INVOICENUM,TRANSACTIONDATE" //Adicionado conforme e-mail do Rodrigo do dia 25/08, solicitando a ordenação.

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery2),'TMP',.F.,.T.) //execução da query2

//Verificando se foi gerado algum resultado
count to nRecCount
If nRecCount > 0
	Processa({|| GeraHtm(cTabTemp)},titulo)
Else
	MsgInfo("Nao existem dados para serem gerados !","HLB BRASIL")
EndIf


Return

/*
Funcao      : GProcessa
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Executa a procedure
Autor     	: Renato Rezende  	 	
Data     	: 30/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*------------------------------*
 Static Function GProcessa
*------------------------------* 

If TcSqlExec("exec SP_P_RELATORIO_FONTE_LWCTB001") < 0
	conout("ERRO"+CRLF)
	conout(TCSQLError())
EndIf

Return

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 29/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

/*
Funcao      : GeraExcel
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Gera o Excel com o Html gravado.
Autor     	: Renato Rezende  	 	
Data     	: 29/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*---------------------------------*
 Static Function GeraExcel(cHtml)
*---------------------------------*

//Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado

	msginfo("Arquivo gerado com sucesso!")

	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel ou Html
EndIf
 
TMP->(DbSkip())

TMP->(DbCloseArea())

Return 

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte LWCTB1 no SX1
Autor     	: Renato Rezende  	 	
Data     	: 29/07/2014
Módulo      : Contabil.
Cliente     : Orange.
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "01", "Da Conta ?",     			"De Conta ?",        		"De Conta ?",				"mv_ch1","C",20,0,0, "G","","CT1"	,"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Ate Conta ?",    			"Ate Conta ?",       		"Ate Conta ?",				"mv_ch2","C",20,0,0, "G","","CT1"	,"","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Data de ?",        		"Data de ?",        		"Data de ?",				"mv_ch3","D",10,0,0, "G","","",		 "","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Data Ate ?",       		"Data Ate ?",       		"Data Ate ?",				"mv_ch4","D",10,0,0, "G","","",		 "","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Do Centro de Custo ?",		"Do Centro de Custo ?",     "Do Centro de Custo ?",		"mv_ch5","C",09,0,0, "G","","CTT"	,"","","mv_par05","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Ate Centro de Custo ?",	"Ate Centro de Custo ?", 	"Ate Centro de Custo ?",	"mv_ch6","C",09,0,0, "G","","CTT"	,"","","mv_par06","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Arquivo ?",				"Arquivo ?",				"Arquivo ?",				"mv_ch7","C",60,0,0, "G","","",		 "","","mv_par07","","","","","","","","","","","","","","","","",{},{},{},"")

Return
