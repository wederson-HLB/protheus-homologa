#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw?WSDL
Gerado em        05/31/17 08:07:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NKNZZPM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSGTFLG001
------------------------------------------------------------------------------- */

WSCLIENT WSGTFLG001

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETCADTES
	WSMETHOD GETCADTRP
	WSMETHOD GETCLIENT
	WSMETHOD GETCPGTOS
	WSMETHOD GETCUSTO
	WSMETHOD GETDEST
	WSMETHOD GETESTADO
	WSMETHOD GETFORNEC
	WSMETHOD GETISS
	WSMETHOD GETMENPAD
	WSMETHOD GETMUN
	WSMETHOD GETNATUR
	WSMETHOD GETPAG
	WSMETHOD GETPAIS
	WSMETHOD GETPRODUT
	WSMETHOD GETSERIENF
	WSMETHOD GETTES
	WSMETHOD GETTRANS
	WSMETHOD SETCAN
	WSMETHOD SETCLIENT
	WSMETHOD SETFIM
	WSMETHOD SETFORNEC
	WSMETHOD SETNFSAID
	WSMETHOD SETTRANSP

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCHAVE                   AS string
	WSDATA   oWSDADOSGET               AS GTFLG001_STDADOSGET
	WSDATA   oWSGETCADTESRESULT        AS GTFLG001_ARRAYOFGETCTESRET
	WSDATA   oWSGETCADTRPRESULT        AS GTFLG001_ARRAYOFGETTRSPRET
	WSDATA   oWSGETCLIENTRESULT        AS GTFLG001_ARRAYOFGETCLIRET
	WSDATA   oWSGETCPGTOSRESULT        AS GTFLG001_ARRAYOFGETCPGRET
	WSDATA   cCCODAMB                  AS string
	WSDATA   cCCODEMP                  AS string
	WSDATA   oWSGETCUSTORESULT         AS GTFLG001_ARRAYOFGETCUSTORET
	WSDATA   oWSGETDESTRESULT          AS GTFLG001_ARRAYOFGETDESTRET
	WSDATA   oWSGETESTADORESULT        AS GTFLG001_ARRAYOFGETESTADORET
	WSDATA   oWSGETFORNECRESULT        AS GTFLG001_ARRAYOFGETFORRET
	WSDATA   oWSGETISSRESULT           AS GTFLG001_ARRAYOFGETISSRET
	WSDATA   oWSGETMENPADRESULT        AS GTFLG001_ARRAYOFGETMENPADRET
	WSDATA   cCESTADO                  AS string
	WSDATA   oWSGETMUNRESULT           AS GTFLG001_ARRAYOFGETMUNRET
	WSDATA   oWSGETNATURRESULT         AS GTFLG001_ARRAYOFGETNATURRET
	WSDATA   oWSGETPAGRESULT           AS GTFLG001_ARRAYOFGETPAGRET
	WSDATA   oWSGETPAISRESULT          AS GTFLG001_ARRAYOFGETPAISRET
	WSDATA   oWSGETPRODUTRESULT        AS GTFLG001_ARRAYOFGETPRDRET
	WSDATA   oWSGETSERIENFRESULT       AS GTFLG001_ARRAYOFGETSERIRET
	WSDATA   oWSGETTESRESULT           AS GTFLG001_ARRAYOFGETTESRET
	WSDATA   oWSGETTRANSRESULT         AS GTFLG001_ARRAYOFGETTRANSRET
	WSDATA   oWSSETCANRESULT           AS GTFLG001_ARRAYOFSETSTSRET
	WSDATA   oWSDADOSSET               AS GTFLG001_STDADOSSET
	WSDATA   oWSSETCLIENTRESULT        AS GTFLG001_ARRAYOFSETSTSRET
	WSDATA   oWSSETFIMRESULT           AS GTFLG001_ARRAYOFSETSTSRET
	WSDATA   oWSSETFORNECRESULT        AS GTFLG001_ARRAYOFSETSTSRET
	WSDATA   cCSERIE                   AS string
	WSDATA   oWSSETNFSAIDRESULT        AS GTFLG001_ARRAYOFSETSTSRET
	WSDATA   oWSSETTRANSPRESULT        AS GTFLG001_ARRAYOFSETSTSRET

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTDADOSGET             AS GTFLG001_STDADOSGET
	WSDATA   oWSSTDADOSSET             AS GTFLG001_STDADOSSET

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSGTFLG001
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150508] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSGTFLG001
	::oWSDADOSGET        := GTFLG001_STDADOSGET():New()
	::oWSGETCADTESRESULT := GTFLG001_ARRAYOFGETCTESRET():New()
	::oWSGETCADTRPRESULT := GTFLG001_ARRAYOFGETTRSPRET():New()
	::oWSGETCLIENTRESULT := GTFLG001_ARRAYOFGETCLIRET():New()
	::oWSGETCPGTOSRESULT := GTFLG001_ARRAYOFGETCPGRET():New()
	::oWSGETCUSTORESULT  := GTFLG001_ARRAYOFGETCUSTORET():New()
	::oWSGETDESTRESULT   := GTFLG001_ARRAYOFGETDESTRET():New()
	::oWSGETESTADORESULT := GTFLG001_ARRAYOFGETESTADORET():New()
	::oWSGETFORNECRESULT := GTFLG001_ARRAYOFGETFORRET():New()
	::oWSGETISSRESULT    := GTFLG001_ARRAYOFGETISSRET():New()
	::oWSGETMENPADRESULT := GTFLG001_ARRAYOFGETMENPADRET():New()
	::oWSGETMUNRESULT    := GTFLG001_ARRAYOFGETMUNRET():New()
	::oWSGETNATURRESULT  := GTFLG001_ARRAYOFGETNATURRET():New()
	::oWSGETPAGRESULT    := GTFLG001_ARRAYOFGETPAGRET():New()
	::oWSGETPAISRESULT   := GTFLG001_ARRAYOFGETPAISRET():New()
	::oWSGETPRODUTRESULT := GTFLG001_ARRAYOFGETPRDRET():New()
	::oWSGETSERIENFRESULT := GTFLG001_ARRAYOFGETSERIRET():New()
	::oWSGETTESRESULT    := GTFLG001_ARRAYOFGETTESRET():New()
	::oWSGETTRANSRESULT  := GTFLG001_ARRAYOFGETTRANSRET():New()
	::oWSSETCANRESULT    := GTFLG001_ARRAYOFSETSTSRET():New()
	::oWSDADOSSET        := GTFLG001_STDADOSSET():New()
	::oWSSETCLIENTRESULT := GTFLG001_ARRAYOFSETSTSRET():New()
	::oWSSETFIMRESULT    := GTFLG001_ARRAYOFSETSTSRET():New()
	::oWSSETFORNECRESULT := GTFLG001_ARRAYOFSETSTSRET():New()
	::oWSSETNFSAIDRESULT := GTFLG001_ARRAYOFSETSTSRET():New()
	::oWSSETTRANSPRESULT := GTFLG001_ARRAYOFSETSTSRET():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTDADOSGET      := ::oWSDADOSGET
	::oWSSTDADOSSET      := ::oWSDADOSSET
Return

WSMETHOD RESET WSCLIENT WSGTFLG001
	::cCCHAVE            := NIL 
	::oWSDADOSGET        := NIL 
	::oWSGETCADTESRESULT := NIL 
	::oWSGETCADTRPRESULT := NIL 
	::oWSGETCLIENTRESULT := NIL 
	::oWSGETCPGTOSRESULT := NIL 
	::cCCODAMB           := NIL 
	::cCCODEMP           := NIL 
	::oWSGETCUSTORESULT  := NIL 
	::oWSGETDESTRESULT   := NIL 
	::oWSGETESTADORESULT := NIL 
	::oWSGETFORNECRESULT := NIL 
	::oWSGETISSRESULT    := NIL 
	::oWSGETMENPADRESULT := NIL 
	::cCESTADO           := NIL 
	::oWSGETMUNRESULT    := NIL 
	::oWSGETNATURRESULT  := NIL 
	::oWSGETPAGRESULT    := NIL 
	::oWSGETPAISRESULT   := NIL 
	::oWSGETPRODUTRESULT := NIL 
	::oWSGETSERIENFRESULT := NIL 
	::oWSGETTESRESULT    := NIL 
	::oWSGETTRANSRESULT  := NIL 
	::oWSSETCANRESULT    := NIL 
	::oWSDADOSSET        := NIL 
	::oWSSETCLIENTRESULT := NIL 
	::oWSSETFIMRESULT    := NIL 
	::oWSSETFORNECRESULT := NIL 
	::cCSERIE            := NIL 
	::oWSSETNFSAIDRESULT := NIL 
	::oWSSETTRANSPRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTDADOSGET      := NIL
	::oWSSTDADOSSET      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSGTFLG001
Local oClone := WSGTFLG001():New()
	oClone:_URL          := ::_URL 
	oClone:cCCHAVE       := ::cCCHAVE
	oClone:oWSDADOSGET   :=  IIF(::oWSDADOSGET = NIL , NIL ,::oWSDADOSGET:Clone() )
	oClone:oWSGETCADTESRESULT :=  IIF(::oWSGETCADTESRESULT = NIL , NIL ,::oWSGETCADTESRESULT:Clone() )
	oClone:oWSGETCADTRPRESULT :=  IIF(::oWSGETCADTRPRESULT = NIL , NIL ,::oWSGETCADTRPRESULT:Clone() )
	oClone:oWSGETCLIENTRESULT :=  IIF(::oWSGETCLIENTRESULT = NIL , NIL ,::oWSGETCLIENTRESULT:Clone() )
	oClone:oWSGETCPGTOSRESULT :=  IIF(::oWSGETCPGTOSRESULT = NIL , NIL ,::oWSGETCPGTOSRESULT:Clone() )
	oClone:cCCODAMB      := ::cCCODAMB
	oClone:cCCODEMP      := ::cCCODEMP
	oClone:oWSGETCUSTORESULT :=  IIF(::oWSGETCUSTORESULT = NIL , NIL ,::oWSGETCUSTORESULT:Clone() )
	oClone:oWSGETDESTRESULT :=  IIF(::oWSGETDESTRESULT = NIL , NIL ,::oWSGETDESTRESULT:Clone() )
	oClone:oWSGETESTADORESULT :=  IIF(::oWSGETESTADORESULT = NIL , NIL ,::oWSGETESTADORESULT:Clone() )
	oClone:oWSGETFORNECRESULT :=  IIF(::oWSGETFORNECRESULT = NIL , NIL ,::oWSGETFORNECRESULT:Clone() )
	oClone:oWSGETISSRESULT :=  IIF(::oWSGETISSRESULT = NIL , NIL ,::oWSGETISSRESULT:Clone() )
	oClone:oWSGETMENPADRESULT :=  IIF(::oWSGETMENPADRESULT = NIL , NIL ,::oWSGETMENPADRESULT:Clone() )
	oClone:cCESTADO      := ::cCESTADO
	oClone:oWSGETMUNRESULT :=  IIF(::oWSGETMUNRESULT = NIL , NIL ,::oWSGETMUNRESULT:Clone() )
	oClone:oWSGETNATURRESULT :=  IIF(::oWSGETNATURRESULT = NIL , NIL ,::oWSGETNATURRESULT:Clone() )
	oClone:oWSGETPAGRESULT :=  IIF(::oWSGETPAGRESULT = NIL , NIL ,::oWSGETPAGRESULT:Clone() )
	oClone:oWSGETPAISRESULT :=  IIF(::oWSGETPAISRESULT = NIL , NIL ,::oWSGETPAISRESULT:Clone() )
	oClone:oWSGETPRODUTRESULT :=  IIF(::oWSGETPRODUTRESULT = NIL , NIL ,::oWSGETPRODUTRESULT:Clone() )
	oClone:oWSGETSERIENFRESULT :=  IIF(::oWSGETSERIENFRESULT = NIL , NIL ,::oWSGETSERIENFRESULT:Clone() )
	oClone:oWSGETTESRESULT :=  IIF(::oWSGETTESRESULT = NIL , NIL ,::oWSGETTESRESULT:Clone() )
	oClone:oWSGETTRANSRESULT :=  IIF(::oWSGETTRANSRESULT = NIL , NIL ,::oWSGETTRANSRESULT:Clone() )
	oClone:oWSSETCANRESULT :=  IIF(::oWSSETCANRESULT = NIL , NIL ,::oWSSETCANRESULT:Clone() )
	oClone:oWSDADOSSET   :=  IIF(::oWSDADOSSET = NIL , NIL ,::oWSDADOSSET:Clone() )
	oClone:oWSSETCLIENTRESULT :=  IIF(::oWSSETCLIENTRESULT = NIL , NIL ,::oWSSETCLIENTRESULT:Clone() )
	oClone:oWSSETFIMRESULT :=  IIF(::oWSSETFIMRESULT = NIL , NIL ,::oWSSETFIMRESULT:Clone() )
	oClone:oWSSETFORNECRESULT :=  IIF(::oWSSETFORNECRESULT = NIL , NIL ,::oWSSETFORNECRESULT:Clone() )
	oClone:cCSERIE       := ::cCSERIE
	oClone:oWSSETNFSAIDRESULT :=  IIF(::oWSSETNFSAIDRESULT = NIL , NIL ,::oWSSETNFSAIDRESULT:Clone() )
	oClone:oWSSETTRANSPRESULT :=  IIF(::oWSSETTRANSPRESULT = NIL , NIL ,::oWSSETTRANSPRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTDADOSGET := oClone:oWSDADOSGET
	oClone:oWSSTDADOSSET := oClone:oWSDADOSSET
Return oClone

// WSDL Method GETCADTES of Service WSGTFLG001

WSMETHOD GETCADTES WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETCADTESRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCADTES xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCADTES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETCADTES",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETCADTESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCADTESRESPONSE:_GETCADTESRESULT","ARRAYOFGETCTESRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCADTRP of Service WSGTFLG001

WSMETHOD GETCADTRP WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETCADTRPRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCADTRP xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCADTRP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETCADTRP",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETCADTRPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCADTRPRESPONSE:_GETCADTRPRESULT","ARRAYOFGETTRSPRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCLIENT of Service WSGTFLG001

WSMETHOD GETCLIENT WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETCLIENTRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCLIENT xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCLIENT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETCLIENT",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETCLIENTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCLIENTRESPONSE:_GETCLIENTRESULT","ARRAYOFGETCLIRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCPGTOS of Service WSGTFLG001

WSMETHOD GETCPGTOS WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETCPGTOSRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCPGTOS xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCPGTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETCPGTOS",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETCPGTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCPGTOSRESPONSE:_GETCPGTOSRESULT","ARRAYOFGETCPGRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCUSTO of Service WSGTFLG001

WSMETHOD GETCUSTO WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETCUSTORESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCUSTO xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCUSTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETCUSTO",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETCUSTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCUSTORESPONSE:_GETCUSTORESULT","ARRAYOFGETCUSTORET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETDEST of Service WSGTFLG001

WSMETHOD GETDEST WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETDESTRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETDEST xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETDEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETDEST",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETDESTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETDESTRESPONSE:_GETDESTRESULT","ARRAYOFGETDESTRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETESTADO of Service WSGTFLG001

WSMETHOD GETESTADO WSSEND cCCHAVE WSRECEIVE oWSGETESTADORESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETESTADO xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETESTADO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETESTADO",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETESTADORESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETESTADORESPONSE:_GETESTADORESULT","ARRAYOFGETESTADORET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETFORNEC of Service WSGTFLG001

WSMETHOD GETFORNEC WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETFORNECRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETFORNEC xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETFORNEC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETFORNEC",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETFORNECRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETFORNECRESPONSE:_GETFORNECRESULT","ARRAYOFGETFORRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETISS of Service WSGTFLG001

WSMETHOD GETISS WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETISSRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETISS xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETISS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETISS",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETISSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETISSRESPONSE:_GETISSRESULT","ARRAYOFGETISSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETMENPAD of Service WSGTFLG001

WSMETHOD GETMENPAD WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETMENPADRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMENPAD xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETMENPAD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETMENPAD",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETMENPADRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETMENPADRESPONSE:_GETMENPADRESULT","ARRAYOFGETMENPADRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETMUN of Service WSGTFLG001

WSMETHOD GETMUN WSSEND cCCHAVE,cCESTADO WSRECEIVE oWSGETMUNRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMUN xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CESTADO", ::cCESTADO, cCESTADO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETMUN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETMUN",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETMUNRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETMUNRESPONSE:_GETMUNRESULT","ARRAYOFGETMUNRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETNATUR of Service WSGTFLG001

WSMETHOD GETNATUR WSSEND cCCHAVE WSRECEIVE oWSGETNATURRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETNATUR xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETNATUR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETNATUR",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETNATURRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETNATURRESPONSE:_GETNATURRESULT","ARRAYOFGETNATURRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPAG of Service WSGTFLG001

WSMETHOD GETPAG WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETPAGRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPAG xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETPAG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETPAG",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETPAGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPAGRESPONSE:_GETPAGRESULT","ARRAYOFGETPAGRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPAIS of Service WSGTFLG001

WSMETHOD GETPAIS WSSEND cCCHAVE WSRECEIVE oWSGETPAISRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPAIS xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETPAIS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETPAIS",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETPAISRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPAISRESPONSE:_GETPAISRESULT","ARRAYOFGETPAISRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPRODUT of Service WSGTFLG001

WSMETHOD GETPRODUT WSSEND cCCHAVE,oWSDADOSGET WSRECEIVE oWSGETPRODUTRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPRODUT xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSGET", ::oWSDADOSGET, oWSDADOSGET , "STDADOSGET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETPRODUT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETPRODUT",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETPRODUTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPRODUTRESPONSE:_GETPRODUTRESULT","ARRAYOFGETPRDRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSERIENF of Service WSGTFLG001

WSMETHOD GETSERIENF WSSEND cCCHAVE WSRECEIVE oWSGETSERIENFRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSERIENF xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETSERIENF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETSERIENF",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETSERIENFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSERIENFRESPONSE:_GETSERIENFRESULT","ARRAYOFGETSERIRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTES of Service WSGTFLG001

WSMETHOD GETTES WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETTESRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTES xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETTES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETTES",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETTESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTESRESPONSE:_GETTESRESULT","ARRAYOFGETTESRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTRANS of Service WSGTFLG001

WSMETHOD GETTRANS WSSEND cCCODAMB,cCCODEMP WSRECEIVE oWSGETTRANSRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTRANS xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCODAMB", ::cCCODAMB, cCCODAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODEMP", ::cCCODEMP, cCCODEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETTRANS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/GETTRANS",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSGETTRANSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTRANSRESPONSE:_GETTRANSRESULT","ARRAYOFGETTRANSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETCAN of Service WSGTFLG001

WSMETHOD SETCAN WSSEND cCCHAVE WSRECEIVE oWSSETCANRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETCAN xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETCAN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETCAN",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETCANRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETCANRESPONSE:_SETCANRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETCLIENT of Service WSGTFLG001

WSMETHOD SETCLIENT WSSEND cCCHAVE,oWSDADOSSET WSRECEIVE oWSSETCLIENTRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETCLIENT xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSSET", ::oWSDADOSSET, oWSDADOSSET , "STDADOSSET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETCLIENT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETCLIENT",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETCLIENTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETCLIENTRESPONSE:_SETCLIENTRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETFIM of Service WSGTFLG001

WSMETHOD SETFIM WSSEND cCCHAVE WSRECEIVE oWSSETFIMRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETFIM xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETFIM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETFIM",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETFIMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETFIMRESPONSE:_SETFIMRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETFORNEC of Service WSGTFLG001

WSMETHOD SETFORNEC WSSEND cCCHAVE,oWSDADOSSET WSRECEIVE oWSSETFORNECRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETFORNEC xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSSET", ::oWSDADOSSET, oWSDADOSSET , "STDADOSSET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETFORNEC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETFORNEC",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETFORNECRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETFORNECRESPONSE:_SETFORNECRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETNFSAID of Service WSGTFLG001

WSMETHOD SETNFSAID WSSEND cCCHAVE,cCSERIE,oWSDADOSSET WSRECEIVE oWSSETNFSAIDRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETNFSAID xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSSET", ::oWSDADOSSET, oWSDADOSSET , "STDADOSSET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETNFSAID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETNFSAID",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETNFSAIDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETNFSAIDRESPONSE:_SETNFSAIDRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETTRANSP of Service WSGTFLG001

WSMETHOD SETTRANSP WSSEND cCCHAVE,oWSDADOSSET WSRECEIVE oWSSETTRANSPRESULT WSCLIENT WSGTFLG001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETTRANSP xmlns="http://apptb717c.grantthornton.com.br:8080/">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DADOSSET", ::oWSDADOSSET, oWSDADOSSET , "STDADOSSET", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETTRANSP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://apptb717c.grantthornton.com.br:8080/SETTRANSP",; 
	"DOCUMENT","http://apptb717c.grantthornton.com.br:8080/",,"1.031217",; 
	"http://apptb717c.grantthornton.com.br:8080/GTFLG001.apw")

::Init()
::oWSSETTRANSPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SETTRANSPRESPONSE:_SETTRANSPRESULT","ARRAYOFSETSTSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STDADOSGET

WSSTRUCT GTFLG001_STDADOSGET
	WSDATA   oWSDADO                   AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_STDADOSGET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_STDADOSGET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_STDADOSGET
	Local oClone := GTFLG001_STDADOSGET():NEW()
	oClone:oWSDADO              := IIF(::oWSDADO = NIL , NIL , ::oWSDADO:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_STDADOSGET
	Local cSoap := ""
	cSoap += WSSoapValue("DADO", ::oWSDADO, ::oWSDADO , "ARRAYOFSTDADOGET", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFGETCTESRET

WSSTRUCT GTFLG001_ARRAYOFGETCTESRET
	WSDATA   oWSGETCTESRET             AS GTFLG001_GETCTESRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETCTESRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETCTESRET
	::oWSGETCTESRET        := {} // Array Of  GTFLG001_GETCTESRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETCTESRET
	Local oClone := GTFLG001_ARRAYOFGETCTESRET():NEW()
	oClone:oWSGETCTESRET := NIL
	If ::oWSGETCTESRET <> NIL 
		oClone:oWSGETCTESRET := {}
		aEval( ::oWSGETCTESRET , { |x| aadd( oClone:oWSGETCTESRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETCTESRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETCTESRET","GETCTESRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETCTESRET , GTFLG001_GETCTESRET():New() )
			::oWSGETCTESRET[len(::oWSGETCTESRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETTRSPRET

WSSTRUCT GTFLG001_ARRAYOFGETTRSPRET
	WSDATA   oWSGETTRSPRET             AS GTFLG001_GETTRSPRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETTRSPRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETTRSPRET
	::oWSGETTRSPRET        := {} // Array Of  GTFLG001_GETTRSPRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETTRSPRET
	Local oClone := GTFLG001_ARRAYOFGETTRSPRET():NEW()
	oClone:oWSGETTRSPRET := NIL
	If ::oWSGETTRSPRET <> NIL 
		oClone:oWSGETTRSPRET := {}
		aEval( ::oWSGETTRSPRET , { |x| aadd( oClone:oWSGETTRSPRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETTRSPRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETTRSPRET","GETTRSPRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETTRSPRET , GTFLG001_GETTRSPRET():New() )
			::oWSGETTRSPRET[len(::oWSGETTRSPRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETCLIRET

WSSTRUCT GTFLG001_ARRAYOFGETCLIRET
	WSDATA   oWSGETCLIRET              AS GTFLG001_GETCLIRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETCLIRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETCLIRET
	::oWSGETCLIRET         := {} // Array Of  GTFLG001_GETCLIRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETCLIRET
	Local oClone := GTFLG001_ARRAYOFGETCLIRET():NEW()
	oClone:oWSGETCLIRET := NIL
	If ::oWSGETCLIRET <> NIL 
		oClone:oWSGETCLIRET := {}
		aEval( ::oWSGETCLIRET , { |x| aadd( oClone:oWSGETCLIRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETCLIRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETCLIRET","GETCLIRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETCLIRET , GTFLG001_GETCLIRET():New() )
			::oWSGETCLIRET[len(::oWSGETCLIRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETCPGRET

WSSTRUCT GTFLG001_ARRAYOFGETCPGRET
	WSDATA   oWSGETCPGRET              AS GTFLG001_GETCPGRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETCPGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETCPGRET
	::oWSGETCPGRET         := {} // Array Of  GTFLG001_GETCPGRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETCPGRET
	Local oClone := GTFLG001_ARRAYOFGETCPGRET():NEW()
	oClone:oWSGETCPGRET := NIL
	If ::oWSGETCPGRET <> NIL 
		oClone:oWSGETCPGRET := {}
		aEval( ::oWSGETCPGRET , { |x| aadd( oClone:oWSGETCPGRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETCPGRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETCPGRET","GETCPGRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETCPGRET , GTFLG001_GETCPGRET():New() )
			::oWSGETCPGRET[len(::oWSGETCPGRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETCUSTORET

WSSTRUCT GTFLG001_ARRAYOFGETCUSTORET
	WSDATA   oWSGETCUSTORET            AS GTFLG001_GETCUSTORET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETCUSTORET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETCUSTORET
	::oWSGETCUSTORET       := {} // Array Of  GTFLG001_GETCUSTORET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETCUSTORET
	Local oClone := GTFLG001_ARRAYOFGETCUSTORET():NEW()
	oClone:oWSGETCUSTORET := NIL
	If ::oWSGETCUSTORET <> NIL 
		oClone:oWSGETCUSTORET := {}
		aEval( ::oWSGETCUSTORET , { |x| aadd( oClone:oWSGETCUSTORET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETCUSTORET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETCUSTORET","GETCUSTORET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETCUSTORET , GTFLG001_GETCUSTORET():New() )
			::oWSGETCUSTORET[len(::oWSGETCUSTORET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETDESTRET

WSSTRUCT GTFLG001_ARRAYOFGETDESTRET
	WSDATA   oWSGETDESTRET             AS GTFLG001_GETDESTRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETDESTRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETDESTRET
	::oWSGETDESTRET        := {} // Array Of  GTFLG001_GETDESTRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETDESTRET
	Local oClone := GTFLG001_ARRAYOFGETDESTRET():NEW()
	oClone:oWSGETDESTRET := NIL
	If ::oWSGETDESTRET <> NIL 
		oClone:oWSGETDESTRET := {}
		aEval( ::oWSGETDESTRET , { |x| aadd( oClone:oWSGETDESTRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETDESTRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETDESTRET","GETDESTRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETDESTRET , GTFLG001_GETDESTRET():New() )
			::oWSGETDESTRET[len(::oWSGETDESTRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETESTADORET

WSSTRUCT GTFLG001_ARRAYOFGETESTADORET
	WSDATA   oWSGETESTADORET           AS GTFLG001_GETESTADORET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETESTADORET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETESTADORET
	::oWSGETESTADORET      := {} // Array Of  GTFLG001_GETESTADORET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETESTADORET
	Local oClone := GTFLG001_ARRAYOFGETESTADORET():NEW()
	oClone:oWSGETESTADORET := NIL
	If ::oWSGETESTADORET <> NIL 
		oClone:oWSGETESTADORET := {}
		aEval( ::oWSGETESTADORET , { |x| aadd( oClone:oWSGETESTADORET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETESTADORET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETESTADORET","GETESTADORET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETESTADORET , GTFLG001_GETESTADORET():New() )
			::oWSGETESTADORET[len(::oWSGETESTADORET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETFORRET

WSSTRUCT GTFLG001_ARRAYOFGETFORRET
	WSDATA   oWSGETFORRET              AS GTFLG001_GETFORRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETFORRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETFORRET
	::oWSGETFORRET         := {} // Array Of  GTFLG001_GETFORRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETFORRET
	Local oClone := GTFLG001_ARRAYOFGETFORRET():NEW()
	oClone:oWSGETFORRET := NIL
	If ::oWSGETFORRET <> NIL 
		oClone:oWSGETFORRET := {}
		aEval( ::oWSGETFORRET , { |x| aadd( oClone:oWSGETFORRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETFORRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETFORRET","GETFORRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETFORRET , GTFLG001_GETFORRET():New() )
			::oWSGETFORRET[len(::oWSGETFORRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETISSRET

WSSTRUCT GTFLG001_ARRAYOFGETISSRET
	WSDATA   oWSGETISSRET              AS GTFLG001_GETISSRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETISSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETISSRET
	::oWSGETISSRET         := {} // Array Of  GTFLG001_GETISSRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETISSRET
	Local oClone := GTFLG001_ARRAYOFGETISSRET():NEW()
	oClone:oWSGETISSRET := NIL
	If ::oWSGETISSRET <> NIL 
		oClone:oWSGETISSRET := {}
		aEval( ::oWSGETISSRET , { |x| aadd( oClone:oWSGETISSRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETISSRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETISSRET","GETISSRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETISSRET , GTFLG001_GETISSRET():New() )
			::oWSGETISSRET[len(::oWSGETISSRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETMENPADRET

WSSTRUCT GTFLG001_ARRAYOFGETMENPADRET
	WSDATA   oWSGETMENPADRET           AS GTFLG001_GETMENPADRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETMENPADRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETMENPADRET
	::oWSGETMENPADRET      := {} // Array Of  GTFLG001_GETMENPADRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETMENPADRET
	Local oClone := GTFLG001_ARRAYOFGETMENPADRET():NEW()
	oClone:oWSGETMENPADRET := NIL
	If ::oWSGETMENPADRET <> NIL 
		oClone:oWSGETMENPADRET := {}
		aEval( ::oWSGETMENPADRET , { |x| aadd( oClone:oWSGETMENPADRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETMENPADRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETMENPADRET","GETMENPADRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETMENPADRET , GTFLG001_GETMENPADRET():New() )
			::oWSGETMENPADRET[len(::oWSGETMENPADRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETMUNRET

WSSTRUCT GTFLG001_ARRAYOFGETMUNRET
	WSDATA   oWSGETMUNRET              AS GTFLG001_GETMUNRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETMUNRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETMUNRET
	::oWSGETMUNRET         := {} // Array Of  GTFLG001_GETMUNRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETMUNRET
	Local oClone := GTFLG001_ARRAYOFGETMUNRET():NEW()
	oClone:oWSGETMUNRET := NIL
	If ::oWSGETMUNRET <> NIL 
		oClone:oWSGETMUNRET := {}
		aEval( ::oWSGETMUNRET , { |x| aadd( oClone:oWSGETMUNRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETMUNRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETMUNRET","GETMUNRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETMUNRET , GTFLG001_GETMUNRET():New() )
			::oWSGETMUNRET[len(::oWSGETMUNRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETNATURRET

WSSTRUCT GTFLG001_ARRAYOFGETNATURRET
	WSDATA   oWSGETNATURRET            AS GTFLG001_GETNATURRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETNATURRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETNATURRET
	::oWSGETNATURRET       := {} // Array Of  GTFLG001_GETNATURRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETNATURRET
	Local oClone := GTFLG001_ARRAYOFGETNATURRET():NEW()
	oClone:oWSGETNATURRET := NIL
	If ::oWSGETNATURRET <> NIL 
		oClone:oWSGETNATURRET := {}
		aEval( ::oWSGETNATURRET , { |x| aadd( oClone:oWSGETNATURRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETNATURRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETNATURRET","GETNATURRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETNATURRET , GTFLG001_GETNATURRET():New() )
			::oWSGETNATURRET[len(::oWSGETNATURRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETPAGRET

WSSTRUCT GTFLG001_ARRAYOFGETPAGRET
	WSDATA   oWSGETPAGRET              AS GTFLG001_GETPAGRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETPAGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETPAGRET
	::oWSGETPAGRET         := {} // Array Of  GTFLG001_GETPAGRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETPAGRET
	Local oClone := GTFLG001_ARRAYOFGETPAGRET():NEW()
	oClone:oWSGETPAGRET := NIL
	If ::oWSGETPAGRET <> NIL 
		oClone:oWSGETPAGRET := {}
		aEval( ::oWSGETPAGRET , { |x| aadd( oClone:oWSGETPAGRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETPAGRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETPAGRET","GETPAGRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETPAGRET , GTFLG001_GETPAGRET():New() )
			::oWSGETPAGRET[len(::oWSGETPAGRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETPAISRET

WSSTRUCT GTFLG001_ARRAYOFGETPAISRET
	WSDATA   oWSGETPAISRET             AS GTFLG001_GETPAISRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETPAISRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETPAISRET
	::oWSGETPAISRET        := {} // Array Of  GTFLG001_GETPAISRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETPAISRET
	Local oClone := GTFLG001_ARRAYOFGETPAISRET():NEW()
	oClone:oWSGETPAISRET := NIL
	If ::oWSGETPAISRET <> NIL 
		oClone:oWSGETPAISRET := {}
		aEval( ::oWSGETPAISRET , { |x| aadd( oClone:oWSGETPAISRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETPAISRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETPAISRET","GETPAISRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETPAISRET , GTFLG001_GETPAISRET():New() )
			::oWSGETPAISRET[len(::oWSGETPAISRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETPRDRET

WSSTRUCT GTFLG001_ARRAYOFGETPRDRET
	WSDATA   oWSGETPRDRET              AS GTFLG001_GETPRDRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETPRDRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETPRDRET
	::oWSGETPRDRET         := {} // Array Of  GTFLG001_GETPRDRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETPRDRET
	Local oClone := GTFLG001_ARRAYOFGETPRDRET():NEW()
	oClone:oWSGETPRDRET := NIL
	If ::oWSGETPRDRET <> NIL 
		oClone:oWSGETPRDRET := {}
		aEval( ::oWSGETPRDRET , { |x| aadd( oClone:oWSGETPRDRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETPRDRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETPRDRET","GETPRDRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETPRDRET , GTFLG001_GETPRDRET():New() )
			::oWSGETPRDRET[len(::oWSGETPRDRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETSERIRET

WSSTRUCT GTFLG001_ARRAYOFGETSERIRET
	WSDATA   oWSGETSERIRET             AS GTFLG001_GETSERIRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETSERIRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETSERIRET
	::oWSGETSERIRET        := {} // Array Of  GTFLG001_GETSERIRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETSERIRET
	Local oClone := GTFLG001_ARRAYOFGETSERIRET():NEW()
	oClone:oWSGETSERIRET := NIL
	If ::oWSGETSERIRET <> NIL 
		oClone:oWSGETSERIRET := {}
		aEval( ::oWSGETSERIRET , { |x| aadd( oClone:oWSGETSERIRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETSERIRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETSERIRET","GETSERIRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETSERIRET , GTFLG001_GETSERIRET():New() )
			::oWSGETSERIRET[len(::oWSGETSERIRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETTESRET

WSSTRUCT GTFLG001_ARRAYOFGETTESRET
	WSDATA   oWSGETTESRET              AS GTFLG001_GETTESRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETTESRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETTESRET
	::oWSGETTESRET         := {} // Array Of  GTFLG001_GETTESRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETTESRET
	Local oClone := GTFLG001_ARRAYOFGETTESRET():NEW()
	oClone:oWSGETTESRET := NIL
	If ::oWSGETTESRET <> NIL 
		oClone:oWSGETTESRET := {}
		aEval( ::oWSGETTESRET , { |x| aadd( oClone:oWSGETTESRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETTESRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETTESRET","GETTESRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETTESRET , GTFLG001_GETTESRET():New() )
			::oWSGETTESRET[len(::oWSGETTESRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFGETTRANSRET

WSSTRUCT GTFLG001_ARRAYOFGETTRANSRET
	WSDATA   oWSGETTRANSRET            AS GTFLG001_GETTRANSRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFGETTRANSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFGETTRANSRET
	::oWSGETTRANSRET       := {} // Array Of  GTFLG001_GETTRANSRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFGETTRANSRET
	Local oClone := GTFLG001_ARRAYOFGETTRANSRET():NEW()
	oClone:oWSGETTRANSRET := NIL
	If ::oWSGETTRANSRET <> NIL 
		oClone:oWSGETTRANSRET := {}
		aEval( ::oWSGETTRANSRET , { |x| aadd( oClone:oWSGETTRANSRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFGETTRANSRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GETTRANSRET","GETTRANSRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGETTRANSRET , GTFLG001_GETTRANSRET():New() )
			::oWSGETTRANSRET[len(::oWSGETTRANSRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSETSTSRET

WSSTRUCT GTFLG001_ARRAYOFSETSTSRET
	WSDATA   oWSSETSTSRET              AS GTFLG001_SETSTSRET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFSETSTSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFSETSTSRET
	::oWSSETSTSRET         := {} // Array Of  GTFLG001_SETSTSRET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFSETSTSRET
	Local oClone := GTFLG001_ARRAYOFSETSTSRET():NEW()
	oClone:oWSSETSTSRET := NIL
	If ::oWSSETSTSRET <> NIL 
		oClone:oWSSETSTSRET := {}
		aEval( ::oWSSETSTSRET , { |x| aadd( oClone:oWSSETSTSRET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFSETSTSRET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SETSTSRET","SETSTSRET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSETSTSRET , GTFLG001_SETSTSRET():New() )
			::oWSSETSTSRET[len(::oWSSETSTSRET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STDADOSSET

WSSTRUCT GTFLG001_STDADOSSET
	WSDATA   oWSDADO                   AS GTFLG001_ARRAYOFSTDADOSET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_STDADOSSET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_STDADOSSET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_STDADOSSET
	Local oClone := GTFLG001_STDADOSSET():NEW()
	oClone:oWSDADO              := IIF(::oWSDADO = NIL , NIL , ::oWSDADO:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_STDADOSSET
	Local cSoap := ""
	cSoap += WSSoapValue("DADO", ::oWSDADO, ::oWSDADO , "ARRAYOFSTDADOSET", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure GETCTESRET

WSSTRUCT GTFLG001_GETCTESRET
	WSDATA   oWSTES                    AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETCTESRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETCTESRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETCTESRET
	Local oClone := GTFLG001_GETCTESRET():NEW()
	oClone:oWSTES               := IIF(::oWSTES = NIL , NIL , ::oWSTES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETCTESRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_TES","ARRAYOFSTDADOGET",NIL,"Property oWSTES as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSTES := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSTES:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETTRSPRET

WSSTRUCT GTFLG001_GETTRSPRET
	WSDATA   oWSTRANSPORT              AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETTRSPRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETTRSPRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETTRSPRET
	Local oClone := GTFLG001_GETTRSPRET():NEW()
	oClone:oWSTRANSPORT         := IIF(::oWSTRANSPORT = NIL , NIL , ::oWSTRANSPORT:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETTRSPRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_TRANSPORT","ARRAYOFSTDADOGET",NIL,"Property oWSTRANSPORT as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSTRANSPORT := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSTRANSPORT:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETCLIRET

WSSTRUCT GTFLG001_GETCLIRET
	WSDATA   oWSCLIENTES               AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETCLIRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETCLIRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETCLIRET
	Local oClone := GTFLG001_GETCLIRET():NEW()
	oClone:oWSCLIENTES          := IIF(::oWSCLIENTES = NIL , NIL , ::oWSCLIENTES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETCLIRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLIENTES","ARRAYOFSTDADOGET",NIL,"Property oWSCLIENTES as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSCLIENTES := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSCLIENTES:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETCPGRET

WSSTRUCT GTFLG001_GETCPGRET
	WSDATA   oWSCONDPAG                AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETCPGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETCPGRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETCPGRET
	Local oClone := GTFLG001_GETCPGRET():NEW()
	oClone:oWSCONDPAG           := IIF(::oWSCONDPAG = NIL , NIL , ::oWSCONDPAG:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETCPGRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CONDPAG","ARRAYOFSTDADOGET",NIL,"Property oWSCONDPAG as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSCONDPAG := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSCONDPAG:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETCUSTORET

WSSTRUCT GTFLG001_GETCUSTORET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETCUSTORET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETCUSTORET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETCUSTORET
	Local oClone := GTFLG001_GETCUSTORET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETCUSTORET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETDESTRET

WSSTRUCT GTFLG001_GETDESTRET
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cLOJA                     AS string
	WSDATA   cNOME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETDESTRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETDESTRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETDESTRET
	Local oClone := GTFLG001_GETDESTRET():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODIGO              := ::cCODIGO
	oClone:cLOJA                := ::cLOJA
	oClone:cNOME                := ::cNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETDESTRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLOJA              :=  WSAdvValue( oResponse,"_LOJA","string",NIL,"Property cLOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETESTADORET

WSSTRUCT GTFLG001_GETESTADORET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETESTADORET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETESTADORET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETESTADORET
	Local oClone := GTFLG001_GETESTADORET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETESTADORET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETFORRET

WSSTRUCT GTFLG001_GETFORRET
	WSDATA   oWSFORNECEDORES           AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETFORRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETFORRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETFORRET
	Local oClone := GTFLG001_GETFORRET():NEW()
	oClone:oWSFORNECEDORES      := IIF(::oWSFORNECEDORES = NIL , NIL , ::oWSFORNECEDORES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETFORRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_FORNECEDORES","ARRAYOFSTDADOGET",NIL,"Property oWSFORNECEDORES as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSFORNECEDORES := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSFORNECEDORES:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETISSRET

WSSTRUCT GTFLG001_GETISSRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETISSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETISSRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETISSRET
	Local oClone := GTFLG001_GETISSRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETISSRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETMENPADRET

WSSTRUCT GTFLG001_GETMENPADRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETMENPADRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETMENPADRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETMENPADRET
	Local oClone := GTFLG001_GETMENPADRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETMENPADRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETMUNRET

WSSTRUCT GTFLG001_GETMUNRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cESTADO                   AS string
	WSDATA   cMUNICIPIO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETMUNRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETMUNRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETMUNRET
	Local oClone := GTFLG001_GETMUNRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cESTADO              := ::cESTADO
	oClone:cMUNICIPIO           := ::cMUNICIPIO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETMUNRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cESTADO            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,"Property cESTADO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMUNICIPIO         :=  WSAdvValue( oResponse,"_MUNICIPIO","string",NIL,"Property cMUNICIPIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETNATURRET

WSSTRUCT GTFLG001_GETNATURRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETNATURRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETNATURRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETNATURRET
	Local oClone := GTFLG001_GETNATURRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETNATURRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETPAGRET

WSSTRUCT GTFLG001_GETPAGRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETPAGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETPAGRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETPAGRET
	Local oClone := GTFLG001_GETPAGRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETPAGRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETPAISRET

WSSTRUCT GTFLG001_GETPAISRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETPAISRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETPAISRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETPAISRET
	Local oClone := GTFLG001_GETPAISRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETPAISRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETPRDRET

WSSTRUCT GTFLG001_GETPRDRET
	WSDATA   oWSPRODUTOS               AS GTFLG001_ARRAYOFSTDADOGET
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETPRDRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETPRDRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETPRDRET
	Local oClone := GTFLG001_GETPRDRET():NEW()
	oClone:oWSPRODUTOS          := IIF(::oWSPRODUTOS = NIL , NIL , ::oWSPRODUTOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETPRDRET
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PRODUTOS","ARRAYOFSTDADOGET",NIL,"Property oWSPRODUTOS as s0:ARRAYOFSTDADOGET on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPRODUTOS := GTFLG001_ARRAYOFSTDADOGET():New()
		::oWSPRODUTOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure GETSERIRET

WSSTRUCT GTFLG001_GETSERIRET
	WSDATA   cPROXIMONUMERO            AS string
	WSDATA   cSERIE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETSERIRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETSERIRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETSERIRET
	Local oClone := GTFLG001_GETSERIRET():NEW()
	oClone:cPROXIMONUMERO       := ::cPROXIMONUMERO
	oClone:cSERIE               := ::cSERIE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETSERIRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPROXIMONUMERO     :=  WSAdvValue( oResponse,"_PROXIMONUMERO","string",NIL,"Property cPROXIMONUMERO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERIE             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSERIE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETTESRET

WSSTRUCT GTFLG001_GETTESRET
	WSDATA   cCFOP                     AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   cFINALIDADE               AS string
	WSDATA   cTES                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETTESRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETTESRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETTESRET
	Local oClone := GTFLG001_GETTESRET():NEW()
	oClone:cCFOP                := ::cCFOP
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cFINALIDADE          := ::cFINALIDADE
	oClone:cTES                 := ::cTES
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETTESRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCFOP              :=  WSAdvValue( oResponse,"_CFOP","string",NIL,"Property cCFOP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFINALIDADE        :=  WSAdvValue( oResponse,"_FINALIDADE","string",NIL,"Property cFINALIDADE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTES               :=  WSAdvValue( oResponse,"_TES","string",NIL,"Property cTES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GETTRANSRET

WSSTRUCT GTFLG001_GETTRANSRET
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cNOME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_GETTRANSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_GETTRANSRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_GETTRANSRET
	Local oClone := GTFLG001_GETTRANSRET():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODIGO              := ::cCODIGO
	oClone:cNOME                := ::cNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_GETTRANSRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SETSTSRET

WSSTRUCT GTFLG001_SETSTSRET
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_SETSTSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_SETSTSRET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_SETSTSRET
	Local oClone := GTFLG001_SETSTSRET():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_SETSTSRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFSTDADOSET

WSSTRUCT GTFLG001_ARRAYOFSTDADOSET
	WSDATA   oWSSTDADOSET              AS GTFLG001_STDADOSET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFSTDADOSET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFSTDADOSET
	::oWSSTDADOSET         := {} // Array Of  GTFLG001_STDADOSET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFSTDADOSET
	Local oClone := GTFLG001_ARRAYOFSTDADOSET():NEW()
	oClone:oWSSTDADOSET := NIL
	If ::oWSSTDADOSET <> NIL 
		oClone:oWSSTDADOSET := {}
		aEval( ::oWSSTDADOSET , { |x| aadd( oClone:oWSSTDADOSET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_ARRAYOFSTDADOSET
	Local cSoap := ""
	aEval( ::oWSSTDADOSET , {|x| cSoap := cSoap  +  WSSoapValue("STDADOSET", x , x , "STDADOSET", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSTDADOGET

WSSTRUCT GTFLG001_ARRAYOFSTDADOGET
	WSDATA   oWSSTDADOGET              AS GTFLG001_STDADOGET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_ARRAYOFSTDADOGET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_ARRAYOFSTDADOGET
	::oWSSTDADOGET         := {} // Array Of  GTFLG001_STDADOGET():New()
Return

WSMETHOD CLONE WSCLIENT GTFLG001_ARRAYOFSTDADOGET
	Local oClone := GTFLG001_ARRAYOFSTDADOGET():NEW()
	oClone:oWSSTDADOGET := NIL
	If ::oWSSTDADOGET <> NIL 
		oClone:oWSSTDADOGET := {}
		aEval( ::oWSSTDADOGET , { |x| aadd( oClone:oWSSTDADOGET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_ARRAYOFSTDADOGET
	Local cSoap := ""
	aEval( ::oWSSTDADOGET , {|x| cSoap := cSoap  +  WSSoapValue("STDADOGET", x , x , "STDADOGET", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_ARRAYOFSTDADOGET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STDADOGET","STDADOGET",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTDADOGET , GTFLG001_STDADOGET():New() )
			::oWSSTDADOGET[len(::oWSSTDADOGET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STDADOSET

WSSTRUCT GTFLG001_STDADOSET
	WSDATA   cCAMPO                    AS string
	WSDATA   cCONTEUDO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_STDADOSET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_STDADOSET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_STDADOSET
	Local oClone := GTFLG001_STDADOSET():NEW()
	oClone:cCAMPO               := ::cCAMPO
	oClone:cCONTEUDO            := ::cCONTEUDO
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_STDADOSET
	Local cSoap := ""
	cSoap += WSSoapValue("CAMPO", ::cCAMPO, ::cCAMPO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CONTEUDO", ::cCONTEUDO, ::cCONTEUDO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure STDADOGET

WSSTRUCT GTFLG001_STDADOGET
	WSDATA   cCAMPO                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT GTFLG001_STDADOGET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT GTFLG001_STDADOGET
Return

WSMETHOD CLONE WSCLIENT GTFLG001_STDADOGET
	Local oClone := GTFLG001_STDADOGET():NEW()
	oClone:cCAMPO               := ::cCAMPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT GTFLG001_STDADOGET
	Local cSoap := ""
	cSoap += WSSoapValue("CAMPO", ::cCAMPO, ::cCAMPO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT GTFLG001_STDADOGET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCAMPO             :=  WSAdvValue( oResponse,"_CAMPO","string",NIL,"Property cCAMPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return