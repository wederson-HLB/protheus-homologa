#INCLUDE "totvs.ch"  
#INCLUDE "XMLXFUN.CH" 
#Include "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT103FIM  บ Autor ณ William Souza      บ Data ณ  03/01/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ User function de envio de email para os processos de work- บฑฑ
ฑฑบ          ณ flow                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ doTerra Brasil                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function N6GEN001(cEmail,cSubject,cFile,cTo)

Local cFrom 		:= ""
Local cAttachment 	:= ""
Local cCC      		:= ""
Local cSubject		:= "[doTERRA]"+cSubject

cMsg :="<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
cMsg +="<html xmlns='http://www.w3.org/1999/xhtml'>"
cMsg +="<head>"
cMsg +="<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />"
cMsg +="<title>doTERRA</title>"
cMsg +="<style type='text/css'>"
cMsg +=".doterra {font-family: Tahoma, Geneva, sans-serif;color: #FFF;font-weight: bold;font-size: 24px;}"
cMsg +=".textoTitulo {font-family: Tahoma, Geneva, sans-serif;color: #FFF;}"
cMsg +=".textorodape {font-family: Tahoma, Geneva, sans-serif;font-size: 9px;color: #FFF;}"
cMsg +=".textocorpo {font-family: Tahoma, Geneva, sans-serif;font-size:10px;color: #FFF;}"
cMsg +="</style>"
cMsg +="</head>"
cMsg +="<body>"
cMsg +="<table width='800' border='0' cellspacing='0' cellpadding='0'>"
cMsg +="<tr><td height='3' colspan='3' bgcolor='#BABB00'><img name='' src='' width='3' height='3' alt='' /></td></tr>"
cMsg +="<tr><td width='10%' height='26' bgcolor='#666666'>&nbsp;</td>"
cMsg +="<td width='19%' rowspan='2' align='center' bgcolor='#BABB00' class='doterra'>doTERRA</td>"
cMsg +="<td width='71%' bgcolor='#666666'>&nbsp;</td></tr>"
cMsg +="<tr><td height='56' bgcolor='#3e3e3e'>&nbsp;</td>"
cMsg +="<td align='right' valign='middle' bgcolor='#3e3e3e' class='textoTitulo'>"+cSubject+"&nbsp;</td></tr>"
cMsg +="<tr><td height='2' colspan='3'><img name='' src='' width='2' height='2' alt='' /></td></tr>"
cMsg +="<tr><td colspan='3' align='center' bgcolor='#DFDFDF'><br /><table width='98%' border='0' cellspacing='0' cellpadding='0'><tr><td>"
cMsg += cEmail
cMsg +="</td></tr></table><br /></td></tr><tr>"
cMsg +="<td height='120' colspan='10' align='right' bgcolor='#666666'><p class='textoTitulo'>Email gerado dinamicamente, nใo responder</p>"
cMsg +="<p class='textorodape'>ฉ 2018 doTERRA. All Rights Reserved.<br />Except as indicated, all words with a <br />"
cMsg +="trademark or registered trademark symbol <br />are trademarks or registered trademarks <br />of doTERRA Holdings, LLC.</p></td>"
cMsg +="</tr></table></body></html>"

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF

cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica 	:= GetMv("MV_RELAUTH",,.F.)             //Determina se o Servidor de Email necessita de Autenticaรงรฃo
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))    //Usuรกrio para Autenticaรงรฃo no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))    //Senha para Autenticaรงรฃo no Servidor de Email
cCC 		:= ""
cFrom 		:= AllTrim(GetMv("MV_RELFROM"))

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexรฃo com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf

	If empty(cFile)
		SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cMsg RESULT lOK
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cMsg ATTACHMENT cFile FORMAT TEXT RESULT lOK
	EndIf	
	
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. )  
