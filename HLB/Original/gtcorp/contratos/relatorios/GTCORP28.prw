#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP28
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relat�rio de PROPOSTAS. Podendo ser gerado automaticamente via job ou executado atrav�s do menu.
			: Para executar via job � necess�rio passar na rotina o c�digo da empresa e o c�digo da filial, exemplo("YY","01")
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 17/07/2012    10:28
M�dulo      : Gest�o de Contratos
*/

/*
Funcao      : GTCORP28()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execu��o da rotina principal do relat�rio
Autor       : Matheus Massarotto
Data/Hora   : 17/07//2012
*/
*----------------------------*
User Function GTCORP28(aParam)
*----------------------------*
Private cEmpr		:=""
Private cFili		:=""
Private cTipo		:="1"
Private cPerg   	:="GTCORP28_P"
Private cAssunto	:=""
Private cPara		:="lucena@br.gt.com"
Private cEmpTitulo	:=""
Private cDatIni		:=""
Private cDatFim		:=""

conout("Entrou na GTCORP28")
if select("SX3")==0

	cEmpr	:=aParam[1]	//Empresa
	cFili	:=aParam[2]	//Filial

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmpr Filial cFili
	cTipo	:="2" //Execu��o via schedule	
	conout("Tipo inicial: "+cTipo)
endif

if !cEmpAnt $ "ZB/ZF"
	if cTipo=='1'
		Alert("Rotina n�o dispon�vel para esta empresa!")
		return()
	else
		conout("Rotina n�o dispon�vel para esta empresa!")
		return()
	endif
endif

if cEmpAnt=="ZB"
	cEmpTitulo:="Grant Thornton Auditores"
elseif	cEmpAnt=="ZF"
	cEmpTitulo:="Grant Thornton Corporate"
endif

cAssunto:="Relacao de propostas, "+cEmpTitulo

//executado atrav�s do menu
if cTipo=='1'
	
	//Defini��o das perguntas.
	PutSx1( "GTCORP28_P", "01", "Data De:"			, "Data De:"		, "Data De:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR01")
	PutSx1( "GTCORP28_P", "02", "Data Ate:"			, "Data Ate:"		, "Data Ate:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR02")
	PutSx1( "GTCORP28_P", "03", "Exibe Pendente?"	, "Exibe Pendente?"	, "Exibe Pendente?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR03","Sim","","","","N�o")
	PutSx1( "GTCORP28_P", "04", "Exibe Aprovado?"	, "Exibe Aprovado?"	, "Exibe Aprovado?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR04","Sim","","","","N�o")
	PutSx1( "GTCORP28_P", "05", "Exibe Recusado?"	, "Exibe Recusado?"	, "Exibe Recusado?"	, "", "N",1 ,00,00,"C","" , "","","","MV_PAR05","Sim","","","","N�o")
	
	If !Pergunte(cPerg,.T.)
		Return()
	EndIf

endif

Private cQry1:=""
Private cHtml:=""
Private nICor:=0

//executado atrav�s do menu
if cTipo=='1'
	cContStatus:=""
	
	if MV_PAR03==1
		cContStatus+="'','1',"
	endif                    
	if MV_PAR04==1
		cContStatus+="'2',"
	endif
	if MV_PAR05==1
		cContStatus+="'4',"
	endif
	
	cContStatus:=SUBSTR(cContStatus,1,len(cContStatus)-1)
endif

//Montagem da Query  
	cQry1 :=" SELECT "+CRLF
	cQry1 +=" CASE Z88_FILIAL WHEN '01' THEN 'SP' ELSE  "+CRLF
	cQry1 +=" 	CASE Z88_FILIAL WHEN '02' THEN 'RJ' ELSE  "+CRLF
	cQry1 +=" 		CASE Z88_FILIAL WHEN '03' THEN 'CP' ELSE "+CRLF
	cQry1 +=" 			CASE Z88_FILIAL WHEN '04' THEN 'PA' ELSE "+CRLF
	cQry1 +=" 				CASE Z88_FILIAL WHEN '05' THEN 'GO' "+CRLF
	cQry1 +=" 				END "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 		END  "+CRLF
	cQry1 +=" 	END "+CRLF
	cQry1 +=" END AS 'Z88_FILIAL', "+CRLF
	cQry1 +=" CASE Z88_STATUS WHEN '' THEN 'PENDENTE' ELSE "+CRLF
	cQry1 +=" 	CASE Z88_STATUS WHEN '1' THEN 'PENDENTE' ELSE "+CRLF
	cQry1 +=" 		CASE Z88_STATUS WHEN '2' THEN 'APROVADO' ELSE "+CRLF
	cQry1 +=" 			CASE Z88_STATUS WHEN '4' THEN 'RECUSADO' "+CRLF
	cQry1 +=" 			END "+CRLF
	cQry1 +=" 		END "+CRLF
	cQry1 +=" 	END "+CRLF
	cQry1 +=" END AS 'Z88_STATUS', "+CRLF
	cQry1 +=" Z88_NUM, "+CRLF
	cQry1 +=" Z88_DRAFT, "+CRLF
	cQry1 +=" Z88_DTINC,  "+CRLF
	cQry1 +=" Z88_DTAPRO, "+CRLF
	cQry1 +=" Z88_SOCIO, "+CRLF
	cQry1 +=" Z88_NOMESO, "+CRLF
	cQry1 +=" Z88_CLIENT, "+CRLF
	cQry1 +=" Z88_NOME, "+CRLF
	cQry1 +=" Z88_PROSPE,  "+CRLF
	cQry1 +=" Z88_PNOME,  "+CRLF
	cQry1 +=" Z88_VALOR,  "+CRLF
	cQry1 +=" Z88_VLRTOT,  "+CRLF
	cQry1 +=" Z88_MOTIVO  "+CRLF
	cQry1 +=" FROM   "+RETSQLNAME("Z88")
	cQry1 +=" WHERE D_E_L_E_T_ = '' "

	//executado atrav�s do menu	
	if cTipo=='1'
		cQry1 +=" AND Z88_DTINC BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
		cQry1 +=" AND Z88_STATUS IN ("+cContStatus+") 
	else
		cQry1 +=" AND Z88_DTINC BETWEEN "
	
		if MONTH(DATE())==1
		    
			cDatIni:=DTOS( CTOD( "01/01/"+cvaltochar(YEAR(DATE())-1) ) )
		    cDatFim:=DTOS( CTOD( "31/12/"+cvaltochar(YEAR(DATE())-1) ) )
		    
			cQry1 += "'"+cDatIni+"' AND '"
			cQry1 += cDatFim+"'"
	
		else
			
			cDatIni:=DTOS( CTOD( "01/01/"+cvaltochar(YEAR(DATE())) ) )
			cDatFim:=DTOS( CTOD( "31/"+cvaltochar(MONTH(DATE())-1)+"/"+cvaltochar(YEAR(DATE())) ) )
			
			cQry1 += "'"+cDatIni+"' AND '"
			cQry1 += cDatFim+"'"
		
		endif
		
	endif
	
	
	
	cQry1 +=" ORDER BY Z88_DTINC

//executado atrav�s do menu
if cTipo=='1'
	If tcsqlexec(cQry1)<0
		Alert("Ocorreu um problema na busca das informa��es!!")
		return
	EndIf
endif
conout("Depois da query")
if select("TRB88")>0
	TRB88->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRB88",.T.,.T.)

Count to nRecCount
conout("nRecCount: "+cvaltochar(nRecCount))
cHtml+=" <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cHtml+=" <html xmlns='http://www.w3.org/1999/xhtml'>"
cHtml+=" <head>"
cHtml+=" <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
cHtml+=" <title>Propostas</title>"

cHtml+=" <style type='text/css'>"
cHtml+=" .corLinHead {"
cHtml+=" 	background-color: #AA92C7;"
cHtml+="	font-weight:bold;"
cHtml+="	font-size:16px;"
cHtml+="	text-align:center;"
cHtml+=" }"

cHtml+=" .corLinBody {"
cHtml+=" 	background-color: #C2C2DC;"
cHtml+=" }"

cHtml+=" </style>"
cHtml+=" </head>"

cHtml+=" <body>"
cHtml+=" <table border='1'>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead' colspan='15'><font color='#FFFFFF'>"+cEmpTitulo+"</font></td>"
cHtml+=" </tr>"
cHtml+=" <tr>"
cHtml+=" 	<td class='corLinHead'>FILIAL</td>"
cHtml+="    <td class='corLinHead'>STATUS</td>"
cHtml+="    <td class='corLinHead'>N� PROPOSTA</td>"
cHtml+="    <td class='corLinHead'>COD.DA DRAFT</td>"
cHtml+="    <td class='corLinHead'>DATA DE EMISSAO</td>"
cHtml+="    <td class='corLinHead'>DATA DA ALTERACAO</td>"
cHtml+="    <td class='corLinHead'>COD. SOCIO</td>"
cHtml+="    <td class='corLinHead' width='400'>NOME DO SOCIO</td>"
cHtml+="    <td class='corLinHead'>COD.CLIENTE</td>"
cHtml+="    <td class='corLinHead' width='400'>NOME DO CLIENTE</td>"
cHtml+="    <td class='corLinHead'>COD. DO PROSPECT</td>"
cHtml+="    <td class='corLinHead' width='400'>NOME DO PROSPECT</td>"
cHtml+="    <td class='corLinHead'>VALOR S/IMP</td>"
cHtml+="    <td class='corLinHead'>VALOR C/IMP</td>"
cHtml+="    <td class='corLinHead' width='400'>MOTIVO</td>"
cHtml+=" </tr>"

if nRecCount>0
	TRB88->(DbGoTop())
	
	While TRB88->(!EOF())
	nICor++
		
		cHtml+=" <tr>"
		cHtml+=" 	<td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_FILIAL)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_STATUS)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_NUM)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_DRAFT)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty( IIF(empty(TRB88->Z88_DTINC),'',DTOC(STOD(TRB88->Z88_DTINC))) )+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty( IIF(empty(TRB88->Z88_DTAPRO),'',DTOC(STOD(TRB88->Z88_DTAPRO))) )+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB88->Z88_SOCIO)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_NOMESO)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB88->Z88_CLIENT)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_NOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+'="'+IsEmpty(TRB88->Z88_PROSPE)+'"'+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_PNOME)+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB88->Z88_VALOR,"@E 999,999,999,999.99"))+"</td> "
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRANSFORM(TRB88->Z88_VLRTOT,"@E 999,999,999,999.99"))+"</td>"
		cHtml+="    <td "+IIF(nICor%2==0,"class='corLinBody'","")+">"+IsEmpty(TRB88->Z88_MOTIVO)+"</td>"
		cHtml+=" </tr>	"
		TRB88->(DbSkip())
	Enddo
endif

cHtml+=" </table>"
cHtml+=" </body>"
cHtml+=" </html>"

TRB88->(DBCloseArea())
conout("Tipo "+cTipo)
//executado atrav�s do menu
if cTipo=='1'
	GExecl(cHtml)
elseif cTipo=='2'
	conout("entrei para enviar email")
	ENVIA_EMAIL(cAssunto,cHtml,cPara,cDatIni,cDatFim)
endif

Return

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Fun��o para gerar o excel
Autor       : Matheus Massarotto
Data/Hora   : 16/07/2012	17:17
*/
*------------------------------*
Static Function GExecl(cConteu)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	cArq := "Propostas_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Cria��o do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cConteu ) // Grava��o do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verifica��o do arquivo (GRAVADO OU NAO) e defini��o de valor de Bytes retornados.
		MsgStop("Erro de grava��o do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          
    sleep(10000)
	FERASE (cDest+cArq)

Return

/*
Funcao      : IsEmpty()
Parametros  : cConteudo
Retorno     : cRet
Objetivos   : Fun��o para retornar &nbsp; caso o campo seja braco
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012	17:17
*/
*--------------------------------*
Static Function IsEmpty(cConteudo)
*--------------------------------*
Local cRet:="&nbsp;"

if !empty(cConteudo)
	cRet:=cConteudo
endif

Return(cRet)

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cSubject,cBody,cTo
Retorno     : .T.
Objetivos   : Fun��o para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 17/07/2012
*/

*-----------------------------------------------------------------------------------------*
Static Function ENVIA_EMAIL(cSubject,cBody,cTo,cDatIni,cDatFim)
*-----------------------------------------------------------------------------------------*
Local cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
Local cUser,lMens:=.T.,nOp:=0,oDlg
Local nHora:=VAL(SUBSTR(TIME(),1,2))
Local cBody1:="<p class='style21' style='text-align:justify'>"+IIF(nHora<6,"Boa noite!",IIF(nHora<12,"Bom dia!",IIF(nHora<18,"Boa tarde!","Boa noite!")))+"</p>"
Local cCC      := ""

DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT cTo      := ""

cBody1+="Segue em anexo o relat�rio referente ao periodo: "+DTOC(STOD(cDatIni))+" a "+ DTOC(STOD(cDatFim))
cBody1+="<br>"
cBody1+="<br><br><br><br><br><br><br><br>"
cBody1+="Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe de TI da GRANT THORNTON BRASIL."
	
IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   

cFrom:=cAccount
cAttachment:=""

/***********************GERANDO DO ARQUIVO EXCEL, Para anexo************************************/
Private cDest :=  "\"+CURDIR()//Retorna o diret�rio corrente do servidor   //GetTempPath()

	cArq := "Propostas_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Cria��o do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cBody ) // Grava��o do seu Conteudo.
	if nBytesSalvo <= 0   // Verifica��o do arquivo (GRAVADO OU NAO) e defini��o de valor de Bytes retornados.
		CONOUT("Erro de grava��o do Destino. ROTINA: GTCORP16 . Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado	
		cAttachment:=cDest+cArq
	endif
/***********************FIM DA GERA��O DO ARQUIVO EXCEL, Para anexo************************************/

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autentica��o
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usu�rio para Autentica��o no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autentica��o no Servidor de Email
cTo := AvLeGrupoEMail(cTo)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conex�o com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "matheus.massarotto@br.gt.com";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "matheus.massarotto@br.gt.com";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   ConOut("E-mail enviado com sucesso.")
ENDIF   

FERASE (cDest+cArq)

RETURN .T.