#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTFAT002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Verificação do certificado digital ao entrar no sistema.
Autor       : Jean Victor Rocha
Data/Hora   : 31/01/12          
*/
*-------------------------*
User Function GTFAT002()
*-------------------------*

Private aCert := {}

Private cServer:= "mail.br.gt.com"
Private cEmail := "totvs@br.gt.com"
Private cPass  := "Protheus@2010"
Private cPassM := "Protheus@2010"

Private cDe      := padr('totvs@br.gt.com',200)
Private cPara    := padr('jean.rocha@br.gt.com',200)
Private cCc      := padr('',200)
Private cAssunto := padr('Certificados Digitais em vencimento.',200)
Private cMsg     := ""
	
If !MSGYESNO("Adiciona todos e-mails para validação?")
	cPara    := padr('jean.rocha@br.gt.com',200)
EndIf
          
Busca()//verifica cada certificado de cada empresa.

If Len(aCert) == 0
	Return .T.
EndIf
       
Email()//monta e-mail

EnviaMail()//envia e-mail.
	 
Return .t.

*---------------------*
Static Function Busca()
*---------------------*
Local cFile 	:= ""
Local nRecno	:= 0
Local aRecnoSM0 := {}
Local lOpen		:= .F.
Local nI, nJ

__cInterNet := Nil

Begin Sequence
	For nJ := 1 To 20
		dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Abre compartilhado.
		If !Empty( Select( "SM0" ) ) 
			dbSetIndex("SIGAMAT.IND") 
			Exit	
		EndIf
		Sleep( 200 ) 
	Next nJ
	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf
		dbSkip()
	EndDo
	For nI := 1 To Len(aRecnoSM0)
		SM0->(dbGoto(aRecnoSM0[nI,1]))
		RpcSetType(2)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
		VerifCert()
		RpcClearEnv()
		For nJ := 1 To 20
			dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. ) //Abre compartilhado.
			If !Empty( Select( "SM0" ) ) 
				dbSetIndex("SIGAMAT.IND") 
				Exit	
			EndIf
			Sleep( 200 ) 
		Next nJ
	Next nI 
End Sequence

Return(.T.) 
           
*-------------------------*
Static Function VerifCert()
*-------------------------*
Local lRetorno := .F.
Local nX

SuperGetMv() //Limpa o cache de parametros
Private cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

//Verifica se o servidor da Totvs esta no ar
oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
If oWs:CFGCONNECT()
	lRetorno := .T.
EndIf

//Verifica o certificado digital.
If lRetorno
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := GetIdEnt()
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
	If oWs:CFGStatusCertificate()
		If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
			For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
				If 	oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date() .and.;
					oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO+02 >= Date()
					aAdd(aCert, {SM0->M0_NOME+"\"+SM0->M0_CODIGO,;                                               //Empresa/Cod
					             SUBSTR(cversao, AT(" ", cversao )+1, Len(cversao)) ,;                           //Ambiente
					             Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),;    //Data de validade
					             SM0->M0_CGC,;                                                                   //CNPJ
					             SM0->M0_INSC})                                                                  //Incrição Estadual
			   EndIf
			Next nX		
		EndIf
	EndIf
EndIf
    
Return .t.

*---------------------*
Static Function Email()
*---------------------*
Local cHora:= TIME()
Local i

cMsg += "<body style='background-color: #9370db'>"
cMsg += '	 <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0"> '
If VAl(SUBSTR(cHora, 1, 2)) < 12
	cMsg += '		 <td colspan="5"> Bom Dia!'
ElseIf VAl(SUBSTR(cHora, 1, 2)) < 18
	cMsg += '		 <td colspan="5"> Boa Tarde!'
Else 
	cMsg += '		 <td colspan="5"> Boa Noite!'
EndIf
cMsg += '			<br></br>'
cMsg += '		 </td>'
cMsg += '		 <tr>'
cMsg += "			<td colspan='5'>Os seguintes certificados digitais estão para expirar. Favor verificar!"
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '			</td>'
cMsg += '		 </tr>'
cMsg += '		 <tr>'
cMsg += "			 <td colspan='5'>                     				 </td>"
cMsg += '		 </tr>'
cMsg += '		 <tr>'
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Empresa\Cod.   </b></font></td>'
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Ambiente       </b></font></td>'
cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Data Validade  </b></font></td>'
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> CNPJ           </b></font></td>' 
cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Insc. Estadual </b></font></td>' 
cMsg += '		 </tr>'
For i:= 1 To Len(aCert)
	cMsg += '		 <tr>'  
	cMsg += '			 <td width="210" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+aCert[i][1]+'</td>'
	cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+aCert[i][2]+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+aCert[i][3]+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+aCert[i][4]+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+aCert[i][5]+'</td>'
	cMsg += '		 </tr>' 
Next i
cMsg += '		<tr>'
cMsg += '			 <td colspan="5">'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<em>'
cMsg += '					<strong>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe TI da GRANT THORNTON BRASIL. </Strong>'
cMsg += '				</em>'
cMsg += '			 </td>'
cMsg += '		</tr>'
cMsg += '	 </Table>'
cMsg += ' <BR?>'
cMsg += CRLF 


Return .t.   

*--------------------------*
STATIC FUNCTION EnviaMail()
*--------------------------*
Local lResulConn := .T.
Local lResulSend := .T.
Local cError := ""  

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
   GET MAIL ERROR cError
   Conout("GTFAT002 - Falha na conexão "+cError)
   Return(.F.)
Endif

SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend   

GET MAIL ERROR cError
If !lResulSend
	Conout("GTFAT002 - Falha no Envio do e-mail " + cError)
Endif

DISCONNECT SMTP SERVER                         

Return .T.

//Descrição Obtem o codigo da entidade apos enviar o post para o Totvs Service.
//Retorno   ExpC1: Codigo da entidade no Totvs Services
*------------------------*
Static Function GetIdEnt()
*------------------------*
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

//Obtem o codigo da entidade
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

If oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
EndIf

RestArea(aArea)
Return(cIdEnt)