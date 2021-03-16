#Include "protheus.ch"
#Include "ap5mail.ch"
#Include "tbiconn.ch"


/*
Class       : DEmail
Parametros  : cFrom,cTo,cCC,cSubject,cAnexos,cBody,cCodUser,cNome,cEmail,cEmail,lEnviou
Retorno     : Nenhum   
Objetivos   : Enviar email
Autor     	: Tiago Luiz Mendonça 
Data     	: 18/06/09
Obs         : 
TDN         : Ao acessar pelo SIGAMDI, este ponto de entrada é chamado ao entrar na rotina. Pelo modo SIGAADV, a abertura dos SXs é executado após o login.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 22/03/2012
Módulo      : Todos
Cliente     : Todos
*/


*--------------*
  Class DEmail
*--------------*  

	Data cFrom		as Character
	Data cTo		as Character
	Data cCC		as Character
	Data cSubject	as Character
	Data cAnexos 	as Character
	Data cBody		as Character
	Data cCodUser	as Character
	Data cNome		as Character
	Data cEmail		as Character
	Data lEnviou	as Logical

	Method New() Constructor
	Method Envia() 
	
EndClass

*--------------------------*
 Method New() Class DEmail
*--------------------------*  

	::cFrom		:= ""
	::cTo		:= ""
	::cCC		:= ""
	::cSubject	:= ""
	::cBody		:= ""
	::cCodUser	:= ""
	::cAnexos 	:= ""
	::cNome		:= ""
	::cEmail	:= ""
Return

*----------------------------*
 Method Envia() Class DEmail     
*----------------------------*

Local lOk			:=	.t.

::lEnviou := Gera(@lOk,::cFrom,::cTo,::cCC,::cSubject,::cBody,::cAnexos)

Return lOk 


*---------------------------------------------------------------*
 Static Function Gera(lOk,cFrom,cTo,cCC,cSubject,cBody,cAnexos)
*---------------------------------------------------------------*

Local nCount		:=	1
Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  := AllTrim(GetNewPar("MV_RELFROM"," "))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
Local cFrom     := cAccount  
Local lOk       := .T.
Local lAutOk    := .T.
	
Connect Smtp Server cServer Account cAccount Password cPassword Result lOk

If ( lSmtpAuth )
	lAutOk := MailAuth(cAccount,cPassword)
Else
	lAutOk := .T.
EndIf
	
If 	lOk .AND. lAutOk  

	/* Desativado
	If 	!MailAuth(cAccount,cPassword)
		Get Mail Error cErrorMsg
		Help("",1,"AVG0001056",,"Error (1): " + cErrorMsg,2,0)
		Disconnect Smtp Server Result lOk
		if 	!lOk
			Get Mail Error cErrorMsg
			Help("",1,"AVG0001056",,"Error (2): " + cErrorMsg,2,0)
		endif
		Return .F.
	EndIf
	*/

	lOk := .f.

	If 	!Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	EndIf

	If 	!lOk 
		Get Mail Error cErrorMsg
		Help("",1,"AVG0001056",,"Error (3): " + cErrorMsg,2,0)
		Return ( .f. )
	Else
		MsgInfo("Email enviado com sucesso!!!")
	EndIf   
	         
Else   

	Get Mail Error cErrorMsg
	Help("",1,"AVG0001057",,"Error (4): " + cErrorMsg,2,0)
	Return .F.   
	
EndIf
	
Disconnect Smtp Server

Return .T.
