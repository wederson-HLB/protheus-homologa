#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECTS.CH"  
/*
Funcao      : DIABACEN
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Programa de integração de taxa
Autor       : Biale,Tiago Luiz Mendonça
Data/Hora   : 28/04/2010
Modificações: 16/04/2013 - MSM - Alterado regra para executar o job 1 vez e gravar a taxa em todos os ambientes
			  07/11/2014 - RRP - Alteração do fonte para inclusão do EURO para atualização automática. Chamado 022054. 
			  25/06/2015 - JVR - Tratamento para considerar os dados no GTHD, como, banco, porta, ambiente e outros.
			  20/07/2017 - GFP - Tratamento GTCORP e P11 Clientes, visto que GTHD foi desativado.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 16/04/2012
Módulo      : Genérico.
*/
/*
PROCESSO: BUSCA DE DADOS BACEN PTAX VIA WEBSERVICE
----------------------------------------------------------------------
NOME: WSBACEN():NEW(dPar,nPar)
dPar ---> data da operacao financeira
npar ---> dado a resgatar, 1 para venda e 10813 para compra
----------------------------------------------------------------------
RETORNO: OBJETO COM ATRIBUTOS
::dData     := ----> DATA SOLICTADA
::dPTAX     := ----> DATA DE RETORNO (DIFERENTE QUANDO NAO HOUVE OPERACAO NADATA SOLICITADA)
::nTipo     := ----> TIPO SOLICITADO
::cTipo     := ----> DESCRICAO DO TIPO
::nValor    := -----> VALOR DE RETORNO
::cMensagem := -----> MENSAGEM DE OK OU ERRO
::lNodia    := .T.------> .T. PARA PTAX DO DIA SOLICITADO, .F. PTAX DO ULTIMO DIA VALIDO
::lStatus   := .T. -----> .T. PARA PROCESSAMENTO OK, .F. PARA ERRO    

OBS: TRATAMENTO PARA A DATA, O OBJETO TRATA APENAS 7 ANTECIPADOS DIAS FORA DATA
     EXEMPLO, SE SOLICITADO UM DOMINGO ELE TRAZ A ULTIMA SEXTA
     
     fonte TSTBACEN() 
----------------------------------------------------------------------
*/
*----------------------*
User Function DIABACEN()
*----------------------*
Local xPar1 := ""
Local xPar2 := 1     // CODIGO 1 PARA DOLAR
Local oBC
Local nDollar 	:= 0  
Local nEuro   	:= 0
Local nLibraEst	:= 0
Local nDollarCan:= 0

Private cDiaSemana := ""
Private cMsgAuxErr	:= ""
Private cMsgAuxOk	:= "GTCORP11"

SET DATE FORMAT "dd/mm/yyyy"

xPar1 := DATE()

RpcClearEnv()
RpcSetType(2)
If !RpcSetEnv("YY","01")
	RETURN
EndIf

xPar2	:= 1     // CODIGO 1 PARA DOLAR
oBC		:= WSBACEN():NEW(xPar1,xPar2)
nDollar	:= oBC:NVALOR
	
oBc		:= nil  
xPar2	:= 21623 //Série Libra esterlina (venda)
oBC		:= WSBACEN():NEW(xPar1,xPar2)
nLibraEst	:= oBC:NVALOR 
	
oBc		:= nil  
xPar2	:= 21619 //Série EURO no banco central
oBC		:= WSBACEN():NEW(xPar1,xPar2)
nEuro	:= oBC:NVALOR 
		
oBc		:= nil  
xPar2	:= 21635 //Série Dólar Canadense (venda)
oBC		:= WSBACEN():NEW(xPar1,xPar2)
nDollarCan	:= oBC:NVALOR 
	
If nDollar > 0 .OR. nEuro > 0
	If Select("SM2") == 0
		ChkFile("SM2")
	EndIf
			
	SM2->(DbSetOrder(1))
	If RecLock("SM2", !SM2->(DbSeek(DTOS(DATE()))))
		SM2->M2_DATA	:= DATE()
		SM2->M2_MOEDA2	:= nDollar
		SM2->M2_MOEDA4	:= Round(1,4)
		SM2->M2_MOEDA5	:= nEuro
		SM2->M2_MOEDA3	:= nLibraEst
		SM2->M2_MOEDA6	:= nDollarCan
		SM2->(MsUnlock())
	EndIf
EndIf

EnviaMail(nDollar,nEuro,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan,"YY")

RETURN

/*
=================================================
Objeto de tratamento do acesso aos dados do BACEN
=================================================
*/      
CLASS WSBacen

//======================
METHOD NEW() constructor

//=============
METHOD finish()  

DATA dData   // data da operacao
DATA dPTAX   // data do ptax
DATA nTipo   // tipo
DATA cTipo
DATA nValor  
DATA cDia
DATA cMensagem           
DATA lNoDia
DATA lStatus 

ENDCLASS
                     
//=====================================
METHOD NEW(_dData,_nTipo) CLASS WsBacen      
Private cSoapSend	:= ""
Private cSoapAction := ""
Private cURL := ""
Private aSem := {"DOMINGO","SEGUNDA","TERCA","QUARTA","QUINTA","SEXTA","SABADO"}
Private nProc := 0
Private __lWsErro //:= .f.  //variavel para controle de erro, se .t. erro de operacao
Private __cWSErro //:= ""   // variavel com o log de erro caso __lWSErro seja .t.
Private __dData //:= _dData
Private __dPTAX //:= _dData 
Private __nTipo //:= _nTipo
Private __cTipo //:= IIF(_nTipo == 1, "VENDA" , IIF(_nTipo==10813,"Compra","Indeterminado") )
Private __nValor //:= 0
Private __cDia   //:= aSem[dow(::dPTAX)]
Private __cMensagem //:= "Objeto Iniciado"
Private __lNoDia  //:= .t.
Private __lStatus //:= .T.

DEFAULT _dData := date()
DEFAULT _NTIPO := 1 // VENDA

__lWsErro := .f.  //variavel para controle de erro, se .t. erro de operacao
__cWSErro := ""   // variavel com o log de erro caso __lWSErro seja .t.
__dData := _dData
__dPTAX := _dData 
__nTipo := _nTipo
__cTipo := IIF(_nTipo == 1, "VENDA" , IIF(_nTipo==10813,"Compra","Indeterminado") )
__nValor := 0
__cDia   := aSem[dow(__dPTAX)]
__cMensagem := "Objeto Iniciado"
__lNoDia  := .t.
__lStatus := .T.

//cURL := "https://www3.bcb.gov.br/sgspub/JSP/sgsgeral/FachadaWSSGS.wsdl"
cURL := "https://www3.bcb.gov.br/wssgs/services/FachadaWSSGS?method=getValor&codigoSerie=#MOEDA#&data=#DATA#"

oRet := GETSEFAZ(__dPtax,__nTipo)
     
While !UPPER(VALTYPE(oRet)) == "O" .and. nProc < 7
	nProc++ 
	__dPTAX := __dPTAX - 1
	oRet := GETSEFAZ(__dPtax,__nTipo)
EndDo
  
Do Case
	Case nProc == 7
		__nValor    := 0
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Processado inversao de data com mais de 7 niveis"
        __lNoDia    := .f.
        __lStatus   := .f.

	case UPPER(VALTYPE(oRet)) == "O"
        __nValor    := val(oRet:_MULTIREF:TEXT)
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Processado em "+DTOC(DATE())+" PTAX DE "+DTOC(__dPTAX)+" | "+__cTipo
        __lNoDia    := iif(__dData == __dPTAX,.t.,.f.)
        __lStatus   := .t.
      
	case __lWsErro 
       __nValor    := 0
       __cDia      := aSem[dow(__dPTAX)]
       __cMensagem := "Falha |"+__cWSErro
       __lNoDia    := .f.
       __lStatus   := .f.
      
	otherwise
        __nValor    := 0
        __cDia      := aSem[dow(__dPTAX)]
        __cMensagem := "Falha inesperada |Abra um chamado para equipe de sistemas."
        __lNoDia    := .f.
        __lStatus   := .f.

endcase 
   
::dData := __dData          
::dPTAX := __dPTAX
::nValor    := val(oRet:_MULTIREF:TEXT)
::cDia      := aSem[dow(__dPTAX)]
::cMensagem := "Processado em "+DTOC(DATE())+" PTAX DE "+DTOC(__dPTAX)+" | "+__cTipo
::lNoDia    := iif(__dData == __dPTAX,.t.,.f.)
::lStatus   := .t.

RETURN(self)

//===========================
method Finish() class wsbacen
::dData     := STOD("")
::dPTAX     := STOD("")
::nTipo     := 0
::cTipo     := ""
::nValor    := 0
::cDia      := ""
::cMensagem := ""  
::lStatus   := .F. 
return(self) 
                                                                      
*---------------------------------*
STATIC FUNCTION GETSEFAZ(_xx1,_xx2)
*---------------------------------*
//---------------------------------------------
// SOAP REQUEST RETIRADO DA FERRAMENTA SOAPUI
//---------------------------------------------
x1 := alltrim(str(int(_xx2)))
x2 := STRZERO(DAY(_xx1),2)+"/"+strzero(month(_xx1),2)+"/"+strzero(year(_xx1),4) 

oXml := ITFSvcSoapCall(cUrl, x1, x2)

return(oXML)

*--------------------------------------------------------------------*
STATIC Function ITFSvcSoapCall(cUrl, x1, x2, DbgLevel)
*--------------------------------------------------------------------*
// variaveis para o request e reponse do post
Local XMLPostRet := ""
Local nTimeOut	:= 120
Local aHeadOut	:= {}
Local XMLHeadRet := ""
// variaveis para checar o header response
Local cHeaderRet := ""
Local nPosCType := 0
Local nPosCTEnd := 0
// variaveis para o parser XML
Local oXmlRet := NIL
Local cError := ""
Local cWarning := ""
// variaveis para retirar ENVELOPE e BODY
Local aTmp1 := {}
Local aTmp2 := {}
Local cEnvSoap := ""
Local cEnvBody := ""
Local cSoapPrefix := ""
// variaveis para determinar soapfault
Local cFaultString := ""
Local cFaultCode := ""

DEFAULT DbgLevel := 2

// REALIZANDO O POST
cUrl := StrTran(cUrl, "#MOEDA#", x1)
cUrl := StrTran(cUrl, "#DATA#", x2)
XMLPostRet := HttpGet(cUrl)

// Verifica Retorno
If XMLPostRet == NIL
	wserrolog("WSCERR044 / Não foi possível POST : URL " + cURL)
	return .f.
ElseIf Empty(XMLPostRet)
	If !empty(XMLHeadRet)
		wserrolog("WSCERR045 / Retorno Vazio de POST : URL "+cURL+' ['+XMLHeadRet+']')
		return .f.
	Else
		wserrolog("WSCERR045 / Retorno Vazio de POST : URL "+cURL)
		return .f.
	Endif
Endif

If DbgLevel > 0
	conout(padc(" POST RETURN ",79,'='))
	If !empty(XMLHeadRet)
		conout(XMLHeadRet)
		conout(replicate('-',79))
	Endif
	conout(XMLPostRet)
	conout(replicate('=',79))
Endif

// --------------------------------------------------------
// Antes de Mandar o XML para o PArser , Verifica se o Content-Type é XML !
// --------------------------------------------------------
If !empty(XMLHeadRet)
	cHeaderRet := XMLHeadRet
	nPosCType := at("CONTENT-TYPE:",Upper(cHeaderRet))
	If nPosCType > 0
		cHeaderRet := substr(cHeaderRet,nPosCType)
		nPosCTEnd := at(CHR(13)+CHR(10) , cHeaderRet)
		cHeaderRet := substr(cHeaderRet,1,IIF(nPosCTEnd > 0 ,nPosCTEnd-1, NIL ) )
		If !"XML"$upper(cHeaderRet)
			wserrolog("WSCERR064 / Invalid Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
			return .f.
		Endif
	Else
		wserrolog("WSCERR065 / EMPTY Content-Type return ("+cHeaderRet+") from "+cURL+CHR(13)+CHR(10)+;
						" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
		return .f.
	Endif
Endif

//--------------------------------------------------------
// Passa pela XML Parser...
//-------------------------------------------------------
oXmlRet := XmlParser(XMLPostRet,'_',@cError,@cWarning)

If !empty(cWarning)
	wserrolog('WSCERR046 / XML Warning '+cWarning+' ( POST em '+cURL+' )'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
ElseIf !empty(cError)
	wserrolog('WSCERR047 / XML Error '+cError+' ( POST em '+cURL+' )'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
ElseIF oXmlRet = NIL
	wserrolog('WSCERR073 / Build '+GETBUILD()+' XML Internal Error.'+CHR(13)+CHR(10)+" HEADER:["+XMLHeadRet+"] POST-RETURN:["+XMLPostRet+"]")
	return .f.
Endif

//--------------------------------------------------------
// Identifica os nodes inicias ENVELOPE e BODY Eles devem ser os primeiros niveis do XML
// RETIRA OS NODES E RETORNA APENAS OS DADOS
//--------------------------------------------------------
If Empty(aTmp1 := ClassDataArr(oXmlRet))
	aTmp1 := NIL
	wserrolog('WSCERR056 / Invalid XML-Soap Server Response : soap-envelope not found.')
	return .f.
Endif

If empty(cEnvSoap := aTmp1[1][1])
	aTmp1 := NIL
	wserrolog('WSCERR057 / Invalid XML-Soap Server Response : soap-envelope empty.')
	return .f.
Endif

// Limpa a variável temporária
aTmp1 := NIL

// ITFxGetInfo no lugar de xGetInfo é uma função da LIB de WEB SERVICES
// Elimina este node, re-atribuindo o Objeto
oXmlRet := ITFxGetInfo( oXmlRet, cEnvSoap  )

If valtype(oXmlRet) <> 'O'
	wserrolog('WSCERR058 / Invalid XML-Soap Server Response : Invalid soap-envelope ['+cEnvSoap+'] object as valtype ['+valtype(oXmlRet)+']')
	return .f.
Endif

If Empty(aTmp2 := ClassDataArr(oXmlRet))
	aTmp2 := NIL
	wserrolog('WSCERR059 / Invalid XML-Soap Server Response : soap-body not found.')
	return .f.
Endif

If empty(cEnvBody := aTmp2[1][1])
	aTmp2 := NIL
	wserrolog('WSCERR060 / Invalid XML-Soap Server Response : soap-body envelope empty.')
	return .f.
Endif

// Limpa a variável temporária
aTmp2 := NIL

// Elimina este node, re-atribuindo o Objeto
oXmlRet := ITFxGetInfo( oXmlRet, cEnvBody )

If valtype(oXmlRet) <> 'O'
	wserrolog('WSCERR061 / Invalid XML-Soap Server Response : Invalid soap-body ['+cEnvBody+'] object as valtype ['+valtype(oXmlRet)+']')
	return .f.
Endif

cSoapPrefix := substr(cEnvSoap,1,rat("_",cEnvSoap)-1)

If Empty(cSoapPrefix)
	wserrolog('WSCERR062 / Invalid XML-Soap Server Response : Unable to determine Soap Prefix of Envelope ['+cEnvSoap+']')
	return .f.
Endif

//--------------------------------------------------------
// TRATAMENTO DO SOAP FAULT, CASO TENHA SIDO RETORNADO UM
//--------------------------------------------------------
If ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:TEXT" ) != NIL
	// Se achou um soap_fault....
	
	cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
	
	If !empty(cFaultString)
		// deve ser protocolo soap 1.0 ou 1.1
		cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" )
	Else
		// caso contrario, trato como soap 1.2
		cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTCODE:TEXT" )
		If Empty(cFaultCode)
			cFaultCode := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_CODE:TEXT" )
		Else
			cFaultCode += " [FACTOR] " + ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTACTOR:TEXT" )
		EndIf
		DEFAULT cFaultCode := ""
		cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_DETAIL:TEXT" )
		If !Empty(cFaultString)
			cFaultString := ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:_FAULTSTRING:TEXT" ) + " [DETAIL] " + cFaultString
		Else
			cFaultString :=  ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_REASON:"+cSoapPrefix+"_TEXT:TEXT" )
			DEFAULT cFaultString := ""
			cFaultString += " [DETAIL] " + ITFxGetInfo( oXmlRet ,cSoapPrefix+"_FAULT:"+cSoapPrefix+"_DETAIL:TEXT" )
			DEFAULT cFaultString := ""
		Endif
	Endif
	
	// Aborta processamento atual com EXCEPTION
	wserrolog('WSCERR048 / SOAP FAULT '+cFaultCode+' ( POST em '+cURL+' ) : ['+cFaultString+']')
	return .f.
	
Endif

//--------------------------------------------------------
// Passou por Tudo .. então retorna um XML parseado Bonitinho ...
//--------------------------------------------------------

return oXmlRet

/* ----------------------------------------------------------------------------------
Funcao        ITFxGetInfo no lugar de xGetInfo
Parametros     oObj = Objeto XML
cObjCpoInfo = propriedade:xxx do objeto a retornar
Retorno        Conteudo solicitado. Caso não exista , retorna xDefault
Se xDefault não especificado , default = NIL
Exemplo        xGetInfo( oXml , '_SOAP_ENVELOPE:_SOAP_BODY:_NODE:TEXT' )
---------------------------------------------------------------------------------- */
*----------------------------------------------------------------------*
STATIC FUNCTION ITFxGetInfo( oXml ,cObjCpoInfo , xDefault , cNotNILMsg )
*----------------------------------------------------------------------*
Local bEval    := &('{ |x| x:' + cObjCpoInfo +' } ')
Local xRetInfo
Local bOldError := Errorblock({|e| Break(e) })

BEGIN SEQUENCE
xRetInfo := eval(bEval , oXml)
RECOVER
xRetInfo := NIL
END SEQUENCE

ErrorBlock(bOldError)

DEFAULT xRetInfo := xDefault

If xRetInfo == NIL .and. !empty(cNotNILMsg)
	__XMLSaveInfo := .T.
	wserrolog("WSCERR041 / "+cNotNILMsg)
Endif

Return xRetInfo    

*-------------------------------*
Static function wserrolog(cParam)
*-------------------------------*
__lWsErro := .t.
__cWSErro := alltrim(cParam) 

ConOut(replicate("=",50))
ConOut(".")
ConOut("  wserrolog ")
ConOut("  Data: "+DTOC(DATE())+"  Hora: "+time())
ConOut("  "+cParam)
ConOut(".") 
ConOut(".")
ConOut(".")
ConOut(replicate("=",50))
                  
return nil   

*----------------------------------------------------------------------------------------*
Static Function EnviaMail(nVal,nVal2,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan,cEmpresas) 
*----------------------------------------------------------------------------------------*
Local i, cServer, cAccount, cEmail
Local xRet, lEnvioOK := .T.

IF EMPTY(cServer := AllTrim(GetNewPar("MV_RELSERV","")))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY(cAccount := AllTrim(GetNewPar("MV_RELACNT","")))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF

cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email

///********* MONTAGEM DE MENSAGEM *********///
oMessage 			:= TMailMessage():New()
oMessage:cDate		:= cValToChar(Date())
oMessage:cFrom		:= cAccount
oMessage:cTo		:= SuperGetMv("MV_P_00104",,UsrRetMail(__cUserID))
oMessage:cSubject	:= "Atualizacao de taxa"
oMessage:cBody		:= Email(nVal,nVal2,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan,cEmpresas)

///********* CONEXÃO DE E-MAIL *********///
oServer := TMailManager():New()
oServer:SetUseTLS(.T.)
xRet := oServer:Init( "", cServer, cAccount, cPassword, 0, 587 )
If xRet != 0
	Alert( "Could not initialize SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
xRet := oServer:SetSMTPTimeout( 60 )
If xRet != 0
    Alert( "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout ) ) 
	lEnvioOK := .F.
EndIf
xRet := oServer:SMTPConnect()
If xRet <> 0
	Alert( "Could not connect on SMTP server: " + oServer:GetErrorString( xRet ) )
	lEnvioOK := .F.
EndIf
If lAutentica
	// try with account and pass
	nRet:=oServer:SMTPAuth(cAccount,cPassword)
	If nRet != 0
		// try with user and pass
		nRet := oServer:SMTPAuth(cUserAut,cPassAut)
		If nRet != 0
			Alert("[Autentica] FAIL TRY with USER() and PASS()" )
			Alert("[Autentica][ERROR] "+str(nRet,6),oServer:GetErrorString(nRet))
			Return .F.
   		Endif
	Endif
Endif 

///********* ENVIO DE E-MAIL *********///
xRet := oMessage:Send( oServer )
If xRet <> 0
    Alert("Could not send message: " + oServer:GetErrorString( xRet ))
    lEnvioOK := .F.
EndIf

xRet := oServer:SMTPDisconnect()
If xRet <> 0
    Alert("Could not disconnect from SMTP server: " + oServer:GetErrorString(xRet))
    lEnvioOK := .F.
EndIf

If !lEnvioOK
	Alert("Não foi possível enviar o e-mail.")
EndIf

Return lEnvioOK

*------------------------------------------------------------------------------------*
Static Function Email(nVal,nVal2,cMsgAuxErr,cMsgAuxOk,nLibraEst,nDollarCan,cEmpresas)    
*------------------------------------------------------------------------------------*
Local cEmail
cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
cEmail += '<title>Nova pagina 1</title></head><body>'
cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
cEmail += 'Taxa gravada no(s) ambiente(s) abaixo:</b></u></font></p>'   
cEmail += '<p><font face="Courier New" size="2">Ambiente(s) : '+alltrim(cMsgAuxOk)+'</p>'  
cEmail += '<p><font face="Courier New" size="2">Empresa(s) : ' +alltrim(cEmpresas)+'</p>'  
cEmail += '<p><font face="Courier New" size="2">Data		: '+DTOC(Date())+'</p>' 
cEmail += '<p><font face="Courier New" size="2">(2) Dollar           : '+ Alltrim(Str(nVal))+'</p>'
cEmail += '<p><font face="Courier New" size="2">(3) Libra esterlina	 : '+ Alltrim(Str(nLibraEst))+'</p>'
cEmail += '<p><font face="Courier New" size="2">(4) Moeda4           : 1.00</p>'
cEmail += '<p><font face="Courier New" size="2">(5) Euro	         : '+ Alltrim(Str(nVal2))+'</p>'
cEmail += '<p><font face="Courier New" size="2">(6) Dollar Canadense : '+ Alltrim(Str(nDollarCan))+'</p>'

If alltrim(cDiaSemana) == "SEXTA" 
	cEmail += '<p><font face="Courier New" size="2">TAXA REPLICADA PARA SABADO E DOMINGO</p>' 
EndIf   
If !EMPTY(cMsgAuxErr)
	cEmail += '<p>-----------------------------------------------------------------------------------------------------------------------------</p>'
	cEmail += 'Taxa não gravada no(s) ambiente(s) abaixo: </b></u></font></p>'   
	cEmail += '<p><font face="Courier New" size="2">Ambiente(s) : '+alltrim(cMsgAuxErr)+'</p>'  
EndIf         
cEmail += '<br>'   
cEmail += '<br>'
         	 
cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
cEmail += '<p align="center">www.grantthornton.com.br</p>'
cEmail += '</body></html>'
   
Return cEmail

*---------------------------*
Static Function MyOpenSM0Ex()
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atenção", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)