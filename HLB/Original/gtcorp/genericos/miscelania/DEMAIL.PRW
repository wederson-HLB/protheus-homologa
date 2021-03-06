#Include "protheus.ch"
#Include "ap5mail.ch"
#Include "tbiconn.ch"


/*
Class       : DEmail
Parametros  : cFrom,cTo,cCC,cSubject,cAnexos,cBody,cCodUser,cNome,cEmail,cEmail,lEnviou
Retorno     : Nenhum   
Objetivos   : Enviar email
Autor     	: Tiago Luiz Mendon�a 
Data     	: 18/06/09
Obs         : 
TDN         : Ao acessar pelo SIGAMDI, este ponto de entrada � chamado ao entrar na rotina. Pelo modo SIGAADV, a abertura dos SXs � executado ap�s o login.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 22/03/2012
M�dulo      : Todos
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
	Data lExibMsg	as Logical

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
	::lExibMsg  := .F.
Return

*----------------------------*
Method Envia() Class DEmail     
*----------------------------*
Local lOk			:=	.t.

::lEnviou := Gera(@lOk,::cFrom,::cTo,::cCC,::cSubject,::cBody,::cAnexos,::lExibMsg)

Return lOk 


*---------------------------------------------------------------------*
Static Function Gera(lOk,cFrom,cTo,cCC,cSubject,cBody,cAnexos,lExibMsg)
*---------------------------------------------------------------------*
Local nCount		:=	1
Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount	:= AllTrim(SuperGetMv("MV_RELACNT",.F.,	""))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local cUserAut  := Alltrim(SuperGetMv("MV_RELAUSR",.F., ""))//Usu�rio para Autentica��o no Servidor de Email
Local cPassAut  := Alltrim(SuperGetMv("MV_RELAPSW",.F., ""))//Senha para Autentica��o no Servidor de Email
Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
Local cFrom		:= AllTrim(SuperGetMv("MV_RELFROM",.F., ""))//Email de origem 
Local lOk       := .T.
Local lAutOk    := .T.

Default lExibMsg := .F.
	
Connect Smtp Server cServer Account cAccount Password cPassword Result lOk

If ( lSmtpAuth )
	lAutOk := MailAuth(cUserAut,cPassAut)
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
		If lExibMsg
			MsgInfo("Email enviado com sucesso!!!")
		EndIf
	EndIf   
	         
Else   
	Get Mail Error cErrorMsg
	Help("",1,"AVG0001057",,"Error (4): " + cErrorMsg,2,0)
	Return .F.   

EndIf

Disconnect Smtp Server

Return .T.