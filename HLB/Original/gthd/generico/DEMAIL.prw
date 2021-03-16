#Include "protheus.ch"
#Include "ap5mail.ch"
#Include "tbiconn.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTHDC001  บAutor  Tiago Luiz Mendon็a  บ Data ณ  20/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse de Envio de email                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grant Thornton                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
Classe      : DEmail
Objetivos   : Classe de envio de email
Autor       : Tiago Luiz Mendon็a
Data/Hora   : 20/07/2011
*/
      
*-------------*
 Class DEmail 
*-------------*
 
	Data cFrom		as Character
	Data cTo		as Character
	Data cCC		as Character
	Data cBcc		as Character
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

*---------------------------*
 Method New() Class DEmail
*---------------------------* 

	::cFrom		:= ""
	::cTo		:= ""
	::cCC		:= ""
	::cBcc		:= ""
	::cSubject	:= ""
	::cBody		:= ""
	::cCodUser	:= ""
	::cAnexos 	:= ""
	::cNome		:= ""
	::cEmail	:= ""
Return


*---------------------------*
 Method Envia() Class DEmail     
*---------------------------*

Local lOk			:=	.t.

::lEnviou := Gera(@lOk,::cFrom,::cTo,::cCC,::cBcc,::cSubject,::cBody,::cAnexos)

Return ( lOk )


*---------------------------------------------------------------*
Static Function Gera(lOk,cFrom,cTo,cCC,cBcc,cSubject,cBody,cAnexos)
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
	/*
	If 	!MailAuth(cAccount,cPassword)
		Get Mail Error cErrorMsg
		Help("",1,"AVG0001056",,"Error (1): " + cErrorMsg,2,0)
		Disconnect Smtp Server Result lOk
		if 	!lOk
			Get Mail Error cErrorMsg
			Help("",1,"AVG0001056",,"Error (2): " + cErrorMsg,2,0)
		endif
		Return ( .f. )
	EndIf
	*/

	lOk := .f.

	//do while !lOk .and. nCount <= 50

		If 	!Empty(cCC)
			//SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
			SEND MAIL FROM cFrom TO cTo CC cCC BCC cBCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
		Else
			//SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
			SEND MAIL FROM cFrom TO cTo BCC cBCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
		EndIf
		
	//	nCount ++
	//enddo	

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
	Return ( .f. )
EndIf
	
Disconnect Smtp Server

Return ( .t. )
