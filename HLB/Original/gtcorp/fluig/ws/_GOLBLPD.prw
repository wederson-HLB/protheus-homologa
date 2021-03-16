#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://fluig.grantthornton.com.br/wsfluig/GED.apw?WSDL
Gerado em        02/15/16 14:41:11
Observações      Código-Fonte gerado por 
ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GOLBLPD ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSGED
------------------------------------------------------------------------------- */

WSCLIENT WSGED

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GEDGETFORN

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCLIENTE                 AS string
	WSDATA   oWSGEDGETFORNRESULT       AS GED_ARRAYOFGEDRETORNO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSGED
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20140829] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSGED
	::oWSGEDGETFORNRESULT := GED_ARRAYOFGEDRETORNO():New()
Return

WSMETHOD RESET WSCLIENT WSGED
	::cCCLIENTE          := NIL 
	::oWSGEDGETFORNRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSGED
Local oClone := WSGED():New()
	oClone:_URL          := ::_URL 
	oClone:cCCLIENTE     := ::cCCLIENTE
	oClone:oWSGEDGETFORNRESULT :=  IIF(::oWSGEDGETFORNRESULT = NIL , NIL ,::oWSGEDGETFORNRESULT:Clone() )
Return oClone

// WSDL Method GEDGETFORN of Service WSGED

WSMETHOD GEDGETFORN WSSEND cCCLIENTE WSRECEIVE oWSGEDGETFORNRESULT WSCLIENT WSGED
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GEDGETFORN xmlns="http://fluig.grantthornton.com.br/">'
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GEDGETFORN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://fluig.grantthornton.com.br/GEDGETFORN",; 
	"DOCUMENT","http://fluig.grantthornton.com.br/",,"1.031217",; 
	"http://fluig.grantthornton.com.br/wsfluig/GED.apw")

::Init()
::oWSGEDGETFORNRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GEDGETFORNRESPONSE:_GEDGETFORNRESULT","ARRAYOFGEDRETORNO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFGEDRETORNO

WSSTRUCT GED_ARRAYOFGEDRETORNO
	WSDATA   oWSGEDRETORNO             AS GED_GEDRETORNO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GED_ARRAYOFGEDRETORNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GED_ARRAYOFGEDRETORNO
	::oWSGEDRETORNO        := {} // Array Of  GED_GEDRETORNO():New()
Return

WSMETHOD CLONE WSCLIENT GED_ARRAYOFGEDRETORNO
	Local oClone := GED_ARRAYOFGEDRETORNO():NEW()
	oClone:oWSGEDRETORNO := NIL
	If ::oWSGEDRETORNO <> NIL 
		oClone:oWSGEDRETORNO := {}
		aEval( ::oWSGEDRETORNO , { |x| aadd( oClone:oWSGEDRETORNO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GED_ARRAYOFGEDRETORNO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GEDRETORNO","GEDRETORNO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGEDRETORNO , GED_GEDRETORNO():New() )
			::oWSGEDRETORNO[len(::oWSGEDRETORNO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure GEDRETORNO

WSSTRUCT GED_GEDRETORNO
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cRAZAO                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GED_GEDRETORNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GED_GEDRETORNO
Return

WSMETHOD CLONE WSCLIENT GED_GEDRETORNO
	Local oClone := GED_GEDRETORNO():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODIGO              := ::cCODIGO
	oClone:cRAZAO               := ::cRAZAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GED_GEDRETORNO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAZAO             :=  WSAdvValue( oResponse,"_RAZAO","string",NIL,"Property cRAZAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


