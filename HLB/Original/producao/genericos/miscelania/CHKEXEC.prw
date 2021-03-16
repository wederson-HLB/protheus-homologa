#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "totvs.ch"  
#INCLUDE "XMLXFUN.CH" 
#Include "ap5mail.ch"
       
/*
Funcao      : CHKEXEC
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. executado a cada chamada do menu do protheus
Autor     	: Jean Victor Rocha
Data     	: 21/12/2017
Obs         : 
TDN         : 
MÛdulo      : Todos
Cliente     : 
*/
*---------------------*
User Function CHKEXEC() 
*---------------------*
//INICIO - Tratamento provisorio para LOG de acessso para a migraÁ„o
Local cFuncao	:= SubStr(ParamIXB, 1, At('(',ParamIXB)-1 ) 
Local cEnv		:= GetEnvServer()
//Local cMODULO := cMODULO
Local cMenuFile := FWGetMnuFile()
Local cCustom	:= IIF(ExistBlock(cFuncao, , .T.),"SIM","NAO")
//Local cUserName := cUserName
TCSQLEXEC("INSERT INTO P12_01.dbo.MIG_MNT_FONTE VALUES('"+cFuncao+"','"+cEnv+"','"+cMODULO+"','"+cMenuFile+"','"+cCustom+"','"+cUserName+"',GETDATE(),convert(varchar(8), GETDATE(), 108))")
//FIM - Tratamento provisorio para LOG de acessso para a migraÁ„o

//Tratamento para correÁ„o de conteundo da System que geram erro.log, como por exemplo de XX4
ChkSystem()

Return .T.

*-------------------------*
Static Function ChkSystem()
*-------------------------*
Local i
Local cMsg		:= ""
Local cTo		:= "suporte.sistemas@hlb.com.br"
Local aFiles 	:= {	"XX4"+cEmpAnt+".DBF",;
						"XX4"+cEmpAnt+".CDX",;
						"SXH"+cEmpAnt+".DBF",;
						"SXH.DBF",;
						"SXH.CDX",;
						"SXH.FPT",;
						"SXI.DBF",;
						"SXI.CDX"} 

For i:=1 to len(aFiles)
	If FILE(aFiles[i])
		cMsg += "<li>"+aFiles[i]+"</li>"
		FERASE(aFiles[i])
	EndIf
Next i

If !EMPTY(cMsg)
	cMsg := "Foi encontrado arquivo que pode gerar erro no Protheus, segue abaixo os arquivos apagados:"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg
	SendAlert(cMsg,cTo)
EndIf

Return .T.

*-----------------------------------*
Static Function SendAlert(cEmail,cTo)
*-----------------------------------*
Local cFrom 		:= ""
Local cAttachment 	:= ""
Local cCC      		:= ""
Local cSubject		:= "[TI-monitoramento] Alerta de arquivos inv&aacute;lido na System - Emp: "+cEmpAnt

cMsg :=" <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
cMsg +=" <html xmlns='http://www.w3.org/1999/xhtml'>
cMsg +="	<head>
cMsg +="		<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
cMsg +="		<title>HLB - Sistemas</title>
cMsg +="		<style type='text/css'>
cMsg +=" .GT {font-family: Tahoma, Geneva, sans-serif;color: #FFF;font-weight: bold;font-size: 24px;}
cMsg +=" .textoTitulo {font-family: Tahoma, Geneva, sans-serif;color: #FFF;}
cMsg +=" .textorodape {font-family: Tahoma, Geneva, sans-serif;font-size: 9px;color: #FFF;}
cMsg +=" .textocorpo {font-family: Tahoma, Geneva, sans-serif;font-size:10px;color: #FFF;}
cMsg +="		</style>
cMsg +="	</head>
cMsg +="	<body>
cMsg +="		<table width='800' border='0' cellspacing='0' cellpadding='0'>
cMsg +="			<tr>
cMsg +="				<td height='3' colspan='3' bgcolor='#4B0082'>
cMsg +="					<img name='' src='' width='3' height='3' alt='' />
cMsg +="				</td>
cMsg +="			</tr>
cMsg +="			<tr>
cMsg +="				<td width='10%' height='26' bgcolor='#666666'>&nbsp;</td>
cMsg +="				<td width='19%' rowspan='2' align='center' bgcolor='#4B0082' class='GT'>HLB - Sistemas</td>
cMsg +="				<td width='71%' bgcolor='#666666'>&nbsp;</td>
cMsg +="			</tr>
cMsg +="			<tr>
cMsg +="				<td height='56' bgcolor='#3e3e3e'>&nbsp;</td>
cMsg +="				<td align='right' valign='middle' bgcolor='#3e3e3e' class='textoTitulo'>"+cSubject+"</td>
cMsg +="			</tr>
cMsg +="			<tr>
cMsg +="				<td height='2' colspan='3'>
cMsg +="					<img name='' src='' width='2' height='2' alt='' />
cMsg +="				</td>
cMsg +="			</tr>
cMsg +="			<tr>
cMsg +="				<td colspan='3' align='center' bgcolor='#DFDFDF'>
cMsg +="					<br />
cMsg +="					<table width='98%' border='0' cellspacing='0' cellpadding='0'>
cMsg +="						<tr>
cMsg +="							<td>
cMsg +=cEmail
cMsg +="							</td>
cMsg +="						</tr>
cMsg +="					</table>
cMsg +="					<br />
cMsg +="				</td>
cMsg +="			</tr>
cMsg +="			<tr>
cMsg +="				<td height='120' colspan='10' align='right' bgcolor='#666666'>
cMsg +="					<p class='textoTitulo'>Email gerado dinamicamente, n&atilde;o responder</p>
cMsg +="					<p class='textorodape'>&#174; 2018 HLB BRASIL - Todos os direitos reservados. 'HLB BRASIL' refere-se &agrave;
cMsg +="					<br />marca sob a qual as empresas membro da HLB BRASIL fornecem servi&ccedil;os de auditoria, 
cMsg +="					<br />tributos e consultoria aos seus clientes . HLB BRASIL &eacute; uma empresa membro 
cMsg +="					<br />da HLB BRASIL International Ltd (GTIL). GTIL e as firmas-membro n&atilde;o s&atilde;o uma parceria 
cMsg +="					<br />mundial. GTIL e cada empresa membro &eacute; uma entidade jur&iacute;dica independente e os trabalhos 
cMsg +="					<br />s&atilde;o entregues pelas firmas membro. A GTIL n&atilde;o fornece servi&ccedil;os aos clientes diretamente. 
cMsg +="					<br />GTIL e suas empresas membros n&atilde;o s&atilde;o agentes, n&atilde;o se obrigam umas &agrave;s outras e n&atilde;o s&atilde;o 
cMsg +="					<br />respons&aacute;veis por atos ou omiss&otilde;es realizadas por outras firmas-membro.
cMsg +="					</p>
cMsg +="					
cMsg +="					
cMsg +="				</td>
cMsg +="			</tr>
cMsg +="		</table>
cMsg +="	</body>
cMsg +=" </html>

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("CHKFILE - Nome do servidor de envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("CHKFILE - Conta para acesso ao servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF

cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica 	:= GetMv("MV_RELAUTH",,.F.)             //Determina se o Servidor de Email necessita de Autentica√ß√£o
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))    //Usu√°rio para Autentica√ß√£o no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))    //Senha para Autentica√ß√£o no Servidor de Email
cCC 		:= ""
cFrom 		:= AllTrim(GetMv("MV_RELFROM"))

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("CHKFILE - Falha na conex„o com servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na autenticacao do usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf

	SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cMsg RESULT lOK
	
	If !lOK
		ConOut("CHKFILE - Falha no envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. ) 