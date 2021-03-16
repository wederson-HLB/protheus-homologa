#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://gt.fluig.com:8280/webdesk/ECMDatasetService?wsdl
Gerado em        07/28/16 14:32:50
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VAJCRFN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSECMDatasetServiceService
------------------------------------------------------------------------------- */

WSCLIENT WSECMDatasetServiceService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateDataset
	WSMETHOD getAvailableDatasets
	WSMETHOD findAllFormulariesDatasets
	WSMETHOD addDataset
	WSMETHOD deleteDataset
	WSMETHOD loadDataset
	WSMETHOD getDataset

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ncompanyId                AS int
	WSDATA   cusername                 AS string
	WSDATA   cpassword                 AS string
	WSDATA   cname                     AS string
	WSDATA   cdescription              AS string
	WSDATA   cimpl                     AS string
	WSDATA   cdataset                  AS string
	WSDATA   oWSgetAvailableDatasetsdatasets AS ECMDatasetServiceService_anyTypeArray
	WSDATA   oWSfindAllFormulariesDatasetsdataset AS ECMDatasetServiceService_formDatasetDTOArray
	WSDATA   oWSloadDatasetdataset     AS ECMDatasetServiceService_dataset
	WSDATA   oWSgetDatasetfields       AS ECMDatasetServiceService_stringArray
	WSDATA   oWSgetDatasetconstraints  AS ECMDatasetServiceService_searchConstraintDtoArray
	WSDATA   oWSgetDatasetorder        AS ECMDatasetServiceService_stringArray
	WSDATA   oWSgetDatasetdataset      AS ECMDatasetServiceService_datasetDto

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSECMDatasetServiceService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120120] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSECMDatasetServiceService
	::oWSgetAvailableDatasetsdatasets := ECMDatasetServiceService_ANYTYPEARRAY():New()
	::oWSfindAllFormulariesDatasetsdataset := ECMDatasetServiceService_FORMDATASETDTOARRAY():New()
	::oWSloadDatasetdataset := ECMDatasetServiceService_DATASET():New()
	::oWSgetDatasetfields := ECMDatasetServiceService_STRINGARRAY():New()
	::oWSgetDatasetconstraints := ECMDatasetServiceService_SEARCHCONSTRAINTDTOARRAY():New()
	::oWSgetDatasetorder := ECMDatasetServiceService_STRINGARRAY():New()
	::oWSgetDatasetdataset := ECMDatasetServiceService_DATASETDTO():New()
Return

WSMETHOD RESET WSCLIENT WSECMDatasetServiceService
	::ncompanyId         := NIL 
	::cusername          := NIL 
	::cpassword          := NIL 
	::cname              := NIL 
	::cdescription       := NIL 
	::cimpl              := NIL 
	::cdataset           := NIL 
	::oWSgetAvailableDatasetsdatasets := NIL 
	::oWSfindAllFormulariesDatasetsdataset := NIL 
	::oWSloadDatasetdataset := NIL 
	::oWSgetDatasetfields := NIL 
	::oWSgetDatasetconstraints := NIL 
	::oWSgetDatasetorder := NIL 
	::oWSgetDatasetdataset := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSECMDatasetServiceService
Local oClone := WSECMDatasetServiceService():New()
	oClone:_URL          := ::_URL 
	oClone:ncompanyId    := ::ncompanyId
	oClone:cusername     := ::cusername
	oClone:cpassword     := ::cpassword
	oClone:cname         := ::cname
	oClone:cdescription  := ::cdescription
	oClone:cimpl         := ::cimpl
	oClone:cdataset      := ::cdataset
	oClone:oWSgetAvailableDatasetsdatasets :=  IIF(::oWSgetAvailableDatasetsdatasets = NIL , NIL ,::oWSgetAvailableDatasetsdatasets:Clone() )
	oClone:oWSfindAllFormulariesDatasetsdataset :=  IIF(::oWSfindAllFormulariesDatasetsdataset = NIL , NIL ,::oWSfindAllFormulariesDatasetsdataset:Clone() )
	oClone:oWSloadDatasetdataset :=  IIF(::oWSloadDatasetdataset = NIL , NIL ,::oWSloadDatasetdataset:Clone() )
	oClone:oWSgetDatasetfields :=  IIF(::oWSgetDatasetfields = NIL , NIL ,::oWSgetDatasetfields:Clone() )
	oClone:oWSgetDatasetconstraints :=  IIF(::oWSgetDatasetconstraints = NIL , NIL ,::oWSgetDatasetconstraints:Clone() )
	oClone:oWSgetDatasetorder :=  IIF(::oWSgetDatasetorder = NIL , NIL ,::oWSgetDatasetorder:Clone() )
	oClone:oWSgetDatasetdataset :=  IIF(::oWSgetDatasetdataset = NIL , NIL ,::oWSgetDatasetdataset:Clone() )
Return oClone

// WSDL Method updateDataset of Service WSECMDatasetServiceService

WSMETHOD updateDataset WSSEND ncompanyId,cusername,cpassword,cname,cdescription,cimpl WSRECEIVE cdataset WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateDataset xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("name", ::cname, cname , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("description", ::cdescription, cdescription , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("impl", ::cimpl, cimpl , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateDataset>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateDataset",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::cdataset           :=  WSAdvValue( oXmlRet,"_DATASET","string",NIL,NIL,NIL,"S",NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableDatasets of Service WSECMDatasetServiceService

WSMETHOD getAvailableDatasets WSSEND ncompanyId,cusername,cpassword WSRECEIVE oWSgetAvailableDatasetsdatasets WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableDatasets xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getAvailableDatasets>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableDatasets",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::oWSgetAvailableDatasetsdatasets:SoapRecv( WSAdvValue( oXmlRet,"_DATASETS","anyTypeArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method findAllFormulariesDatasets of Service WSECMDatasetServiceService

WSMETHOD findAllFormulariesDatasets WSSEND ncompanyId,cusername,cpassword WSRECEIVE oWSfindAllFormulariesDatasetsdataset WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:findAllFormulariesDatasets xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "long", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:findAllFormulariesDatasets>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"findAllFormulariesDatasets",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::oWSfindAllFormulariesDatasetsdataset:SoapRecv( WSAdvValue( oXmlRet,"_DATASET","formDatasetDTOArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method addDataset of Service WSECMDatasetServiceService

WSMETHOD addDataset WSSEND ncompanyId,cusername,cpassword,cname,cdescription,cimpl WSRECEIVE cdataset WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:addDataset xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("name", ::cname, cname , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("description", ::cdescription, cdescription , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("impl", ::cimpl, cimpl , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:addDataset>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"addDataset",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::cdataset           :=  WSAdvValue( oXmlRet,"_DATASET","string",NIL,NIL,NIL,"S",NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteDataset of Service WSECMDatasetServiceService

WSMETHOD deleteDataset WSSEND ncompanyId,cusername,cpassword,cname WSRECEIVE NULLPARAM WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:deleteDataset xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("name", ::cname, cname , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:deleteDataset>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"deleteDataset",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method loadDataset of Service WSECMDatasetServiceService

WSMETHOD loadDataset WSSEND ncompanyId,cusername,cpassword,cname WSRECEIVE oWSloadDatasetdataset WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:loadDataset xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("name", ::cname, cname , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:loadDataset>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"loadDataset",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::oWSloadDatasetdataset:SoapRecv( WSAdvValue( oXmlRet,"_DATASET","dataset",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDataset of Service WSECMDatasetServiceService

WSMETHOD getDataset WSSEND ncompanyId,cusername,cpassword,cname,oWSgetDatasetfields,oWSgetDatasetconstraints,oWSgetDatasetorder WSRECEIVE oWSgetDatasetdataset WSCLIENT WSECMDatasetServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDataset xmlns:q1="http://ws.dataservice.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("name", ::cname, cname , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("fields", ::oWSgetDatasetfields, oWSgetDatasetfields , "stringArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("constraints", ::oWSgetDatasetconstraints, oWSgetDatasetconstraints , "searchConstraintDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("order", ::oWSgetDatasetorder, oWSgetDatasetorder , "stringArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDataset>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDataset",; 
	"RPCX","http://ws.dataservice.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDatasetService")

::Init()
::oWSgetDatasetdataset:SoapRecv( WSAdvValue( oXmlRet,"_DATASET","datasetDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure anyTypeArray

WSSTRUCT ECMDatasetServiceService_anyTypeArray
	WSDATA   oWSitem                   AS SCHEMA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_anyTypeArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_anyTypeArray
	::oWSitem              := {} // Array Of  SCHEMA():New()
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_anyTypeArray
	Local oClone := ECMDatasetServiceService_anyTypeArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_anyTypeArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , aNodes1[nRElem1] )
		Endif
	Next
Return

// WSDL Data Structure formDatasetDTOArray

WSSTRUCT ECMDatasetServiceService_formDatasetDTOArray
	WSDATA   oWSitem                   AS ECMDatasetServiceService_formDatasetDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_formDatasetDTOArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_formDatasetDTOArray
	::oWSitem              := {} // Array Of  ECMDatasetServiceService_FORMDATASETDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_formDatasetDTOArray
	Local oClone := ECMDatasetServiceService_formDatasetDTOArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_formDatasetDTOArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDatasetServiceService_formDatasetDTO():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure dataset

WSSTRUCT ECMDatasetServiceService_dataset
	WSDATA   cdatasetBuilder           AS string OPTIONAL
	WSDATA   cdatasetDescription       AS string OPTIONAL
	WSDATA   cdatasetImpl              AS string OPTIONAL
	WSDATA   oWSdatasetPK              AS ECMDatasetServiceService_datasetPK OPTIONAL
	WSDATA   njournalingAdherence      AS int OPTIONAL
	WSDATA   nlastRemoteSync           AS long OPTIONAL
	WSDATA   nlastReset                AS long OPTIONAL
	WSDATA   nlistId                   AS int OPTIONAL
	WSDATA   lmobileCache              AS boolean OPTIONAL
	WSDATA   lofflineMobileCache       AS boolean OPTIONAL
	WSDATA   nresetType                AS int OPTIONAL
	WSDATA   lserverOffline            AS boolean OPTIONAL
	WSDATA   csyncDetails              AS string OPTIONAL
	WSDATA   nsyncStatus               AS int OPTIONAL
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   nupdateInterval           AS long OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_dataset
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_dataset
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_dataset
	Local oClone := ECMDatasetServiceService_dataset():NEW()
	oClone:cdatasetBuilder      := ::cdatasetBuilder
	oClone:cdatasetDescription  := ::cdatasetDescription
	oClone:cdatasetImpl         := ::cdatasetImpl
	oClone:oWSdatasetPK         := IIF(::oWSdatasetPK = NIL , NIL , ::oWSdatasetPK:Clone() )
	oClone:njournalingAdherence := ::njournalingAdherence
	oClone:nlastRemoteSync      := ::nlastRemoteSync
	oClone:nlastReset           := ::nlastReset
	oClone:nlistId              := ::nlistId
	oClone:lmobileCache         := ::lmobileCache
	oClone:lofflineMobileCache  := ::lofflineMobileCache
	oClone:nresetType           := ::nresetType
	oClone:lserverOffline       := ::lserverOffline
	oClone:csyncDetails         := ::csyncDetails
	oClone:nsyncStatus          := ::nsyncStatus
	oClone:ctype                := ::ctype
	oClone:nupdateInterval      := ::nupdateInterval
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_dataset
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdatasetBuilder    :=  WSAdvValue( oResponse,"_DATASETBUILDER","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdatasetDescription :=  WSAdvValue( oResponse,"_DATASETDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdatasetImpl       :=  WSAdvValue( oResponse,"_DATASETIMPL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode4 :=  WSAdvValue( oResponse,"_DATASETPK","datasetPK",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode4 != NIL
		::oWSdatasetPK := ECMDatasetServiceService_datasetPK():New()
		::oWSdatasetPK:SoapRecv(oNode4)
	EndIf
	::njournalingAdherence :=  WSAdvValue( oResponse,"_JOURNALINGADHERENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nlastRemoteSync    :=  WSAdvValue( oResponse,"_LASTREMOTESYNC","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nlastReset         :=  WSAdvValue( oResponse,"_LASTRESET","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nlistId            :=  WSAdvValue( oResponse,"_LISTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lmobileCache       :=  WSAdvValue( oResponse,"_MOBILECACHE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lofflineMobileCache :=  WSAdvValue( oResponse,"_OFFLINEMOBILECACHE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nresetType         :=  WSAdvValue( oResponse,"_RESETTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lserverOffline     :=  WSAdvValue( oResponse,"_SERVEROFFLINE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::csyncDetails       :=  WSAdvValue( oResponse,"_SYNCDETAILS","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nsyncStatus        :=  WSAdvValue( oResponse,"_SYNCSTATUS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ctype              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nupdateInterval    :=  WSAdvValue( oResponse,"_UPDATEINTERVAL","long",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure datasetPK

WSSTRUCT ECMDatasetServiceService_datasetPK
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cdatasetId                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_datasetPK
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_datasetPK
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_datasetPK
	Local oClone := ECMDatasetServiceService_datasetPK():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cdatasetId           := ::cdatasetId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_datasetPK
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdatasetId         :=  WSAdvValue( oResponse,"_DATASETID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure stringArray

WSSTRUCT ECMDatasetServiceService_stringArray
	WSDATA   citem                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_stringArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_stringArray
	::citem                := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_stringArray
	Local oClone := ECMDatasetServiceService_stringArray():NEW()
	oClone:citem                := IIf(::citem <> NIL , aClone(::citem) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDatasetServiceService_stringArray
	Local cSoap := ""
	aEval( ::citem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure searchConstraintDtoArray

WSSTRUCT ECMDatasetServiceService_searchConstraintDtoArray
	WSDATA   oWSitem                   AS ECMDatasetServiceService_searchConstraintDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_searchConstraintDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_searchConstraintDtoArray
	::oWSitem              := {} // Array Of  ECMDatasetServiceService_SEARCHCONSTRAINTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_searchConstraintDtoArray
	Local oClone := ECMDatasetServiceService_searchConstraintDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDatasetServiceService_searchConstraintDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "searchConstraintDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure datasetDto

WSSTRUCT ECMDatasetServiceService_datasetDto
	WSDATA   ccolumns                  AS string OPTIONAL
	WSDATA   oWSvalues                 AS ECMDatasetServiceService_valuesDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_datasetDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_datasetDto
	::ccolumns             := {} // Array Of  ""
	::oWSvalues            := {} // Array Of  ECMDatasetServiceService_VALUESDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_datasetDto
	Local oClone := ECMDatasetServiceService_datasetDto():NEW()
	oClone:ccolumns             := IIf(::ccolumns <> NIL , aClone(::ccolumns) , NIL )
	oClone:oWSvalues := NIL
	If ::oWSvalues <> NIL 
		oClone:oWSvalues := {}
		aEval( ::oWSvalues , { |x| aadd( oClone:oWSvalues , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_datasetDto
	Local oNodes1 :=  WSAdvValue( oResponse,"_COLUMNS","string",{},NIL,.T.,"S",NIL,"xs") 
	Local nRElem2 , nTElem2
	//Local aNodes2 := WSRPCGetNode(oResponse,.T.)
	Local aNodes2 := WSAdvValue( oResponse,"_VALUES","string",{},NIL,.T.,"S",NIL,"xs")
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::ccolumns ,  x:TEXT  ) } )
	nTElem2 := len(aNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( aNodes2[nRElem2] )
			aadd(::oWSvalues , ECMDatasetServiceService_valuesDto():New() )
  			::oWSvalues[len(::oWSvalues)]:SoapRecv(aNodes2[nRElem2])
		Endif
	Next
Return

// WSDL Data Structure valuesDto

WSSTRUCT ECMDatasetServiceService_valuesDto
	WSDATA   oWSvalue                  AS SCHEMA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_valuesDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_valuesDto
	::oWSvalue             := {} // Array Of  SCHEMA():New()
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_valuesDto
	Local oClone := ECMDatasetServiceService_valuesDto():NEW()
	oClone:oWSvalue := NIL
	If ::oWSvalue <> NIL 
		oClone:oWSvalue := {}
		aEval( ::oWSvalue , { |x| aadd( oClone:oWSvalue , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_valuesDto
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		//If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSvalue , aNodes1[nRElem1] )
		//Endif
	Next
Return

// WSDL Data Structure formDatasetDTO

WSSTRUCT ECMDatasetServiceService_formDatasetDTO
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cdatasetId                AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   nid                       AS long OPTIONAL
	WSDATA   lmobileOffline            AS boolean OPTIONAL
	WSDATA   lserverOffline            AS boolean OPTIONAL
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_formDatasetDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_formDatasetDTO
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_formDatasetDTO
	Local oClone := ECMDatasetServiceService_formDatasetDTO():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cdatasetId           := ::cdatasetId
	oClone:ndocumentId          := ::ndocumentId
	oClone:nid                  := ::nid
	oClone:lmobileOffline       := ::lmobileOffline
	oClone:lserverOffline       := ::lserverOffline
	oClone:ctype                := ::ctype
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDatasetServiceService_formDatasetDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdatasetId         :=  WSAdvValue( oResponse,"_DATASETID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nid                :=  WSAdvValue( oResponse,"_ID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::lmobileOffline     :=  WSAdvValue( oResponse,"_MOBILEOFFLINE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lserverOffline     :=  WSAdvValue( oResponse,"_SERVEROFFLINE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ctype              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure searchConstraintDto

WSSTRUCT ECMDatasetServiceService_searchConstraintDto
	WSDATA   ccontraintType            AS string OPTIONAL
	WSDATA   cfieldName                AS string OPTIONAL
	WSDATA   cfinalValue               AS string OPTIONAL
	WSDATA   cinitialValue             AS string OPTIONAL
	WSDATA   llikeSearch               AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDatasetServiceService_searchConstraintDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDatasetServiceService_searchConstraintDto
Return

WSMETHOD CLONE WSCLIENT ECMDatasetServiceService_searchConstraintDto
	Local oClone := ECMDatasetServiceService_searchConstraintDto():NEW()
	oClone:ccontraintType       := ::ccontraintType
	oClone:cfieldName           := ::cfieldName
	oClone:cfinalValue          := ::cfinalValue
	oClone:cinitialValue        := ::cinitialValue
	oClone:llikeSearch          := ::llikeSearch
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDatasetServiceService_searchConstraintDto
	Local cSoap := ""
	cSoap += WSSoapValue("contraintType", ::ccontraintType, ::ccontraintType , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fieldName", ::cfieldName, ::cfieldName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("finalValue", ::cfinalValue, ::cfinalValue , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("initialValue", ::cinitialValue, ::cinitialValue , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("likeSearch", ::llikeSearch, ::llikeSearch , "boolean", .F. , .T., 0 , NIL, .F.) 
Return cSoap