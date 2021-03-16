#Include "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTCORP43  บAutor  ณTiago Luiz Mendon็a บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvio de email                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grant Thornton                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
                               
/*
Funcao      : GTCORP43
Parametros  : cFrom,cTo,cCC,cSubject,cAnexos
Retorno     : lRet
Objetivos   : Envio de email de senha baseado no SRA  
Autor       : Tiago Luiz Mendon็a
Data/Hora   : 10/09/12
*/

*-------------------------------------------------------------*
 User Function GTCORP43(cFrom,cTo,cCC,cSubject,cBody,cAnexos)
*-------------------------------------------------------------*  

Local cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount  := AllTrim(GetNewPar("MV_RELFROM"," "))
Local cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
 
Local lOk       := .T.
Local lAutOk    := .T.          
Local lRet      := .T.                      

Connect Smtp Server cServer Account cAccount Password cPassword Result lOk

If ( lSmtpAuth )
	lAutOk := MailAuth(cAccount,cPassword)
Else
	lAutOk := .T.
EndIf
	
If lAutOk .And. lOk

	lOK:= .F.
	
	If 	!Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	EndIf

	If 	!lOk 
		//Get Mail Error cErrorMsg
		//Help("",1,"AVG0001056",,"Error (3): " + cErrorMsg,2,0)
		lRet:=.F.
	EndIf            
Else
	//Get Mail Error cErrorMsg
	//Help("",1,"AVG0001057",,"Error (4): " + cErrorMsg,2,0)
	lRet:=.F.
EndIf
	
Disconnect Smtp Server

Return lRet       






