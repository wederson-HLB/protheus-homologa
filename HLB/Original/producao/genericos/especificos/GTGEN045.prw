#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "AP5MAIL.CH"

/*
Funcao      : GTGEN045
Parametros  : cEmail,cSubject,cTo,cToOculto,cAnexos
Retorno     : lRet
Objetivos   : Conecta e envia e-mail
Autor     	: Anderson Arrais
Data		: 12/06/2018
*/
*----------------------------------------------------------------*
 User Function GTGEN045(cEmail,cSubject,cCC,cTo,cToOculto,cAnexos)
*----------------------------------------------------------------*
Local cFrom			:= AllTrim(GetMv("MV_RELFROM"	,,""))
Local cPassword 	:= AllTrim(GetMv("MV_RELPSW"	,,""))
Local cUserAut  	:= Alltrim(GetMv("MV_RELAUSR"	,,""))//Usuário para Autenticação no Servidor de Email 
Local cPassAut  	:= Alltrim(GetMv("MV_RELAPSW"	,,""))//Senha para Autenticação no Servidor de Email
Local cServer		:= AllTrim(GetMv("MV_RELSERV"	,,""))//Nome do Servidor de Envio de Email
Local cAccount		:= AllTrim(GetMv("MV_RELACNT"	,,""))//Conta para acesso ao Servidor de Email
Local cAttachment	:= Iif(Empty(cAnexos),"",cAnexos)
Local cCC      		:= Iif(Empty(cCC),"",cCC)
Local cTo			:= AvLeGrupoEMail(cTo)

Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local lRet			:= .T.

If Empty(cServer)
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	lRet := .F.
EndIf

If Empty(cAccount)
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	lRet := .F.
EndIf

If lRet
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
	
	If !lOK
		MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
		lRet := .F.
	Else
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				MsgInfo("Falha na Autenticacao do Usuario","HLB BRASIL")
				DISCONNECT SMTP SERVER RESULT lOk
				lRet := .F.
			EndIf
		EndIf
		IF !EMPTY(cCC)  
			SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		Else
			SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		EndIf
		If !lOK
			ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
			lRet := .F.
		ENDIF
	ENDIF
	
	DISCONNECT SMTP SERVER
Else
	MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
EndIf

Return lRet