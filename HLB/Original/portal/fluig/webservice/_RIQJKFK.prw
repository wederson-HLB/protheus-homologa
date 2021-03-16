#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://gt.fluig.com:8280/webdesk/ECMDocumentService?wsdl
Gerado em        07/28/16 14:34:14
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RIQJKFK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSECMDocumentServiceService
------------------------------------------------------------------------------- */

WSCLIENT WSECMDocumentServiceService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateSimpleDocument
	WSMETHOD approveDocument
	WSMETHOD createSimpleDocumentPrivate
	WSMETHOD getReportSubjectId
	WSMETHOD destroyDocument
	WSMETHOD getSecurity
	WSMETHOD getRelatedDocuments
	WSMETHOD createSimpleDocument
	WSMETHOD getDocumentApprovalHistory
	WSMETHOD getDocumentContent
	WSMETHOD updateGroupSecurityType
	WSMETHOD updateDocumentWithApprovementLevels
	WSMETHOD getApprovers
	WSMETHOD findMostPopularDocuments
	WSMETHOD getUserPermissions
	WSMETHOD updateDocumentConversionStatus
	WSMETHOD moveDocument
	WSMETHOD getDocumentVersion
	WSMETHOD destroyDocumentApproval
	WSMETHOD createDocumentWithApprovementLevels
	WSMETHOD findRecycledDocuments
	WSMETHOD restoreDocument
	WSMETHOD removeSecurity
	WSMETHOD copyDocumentToUploadArea
	WSMETHOD getDocumentByExternalId
	WSMETHOD validateIntegrationRequirements
	WSMETHOD updateDocument
	WSMETHOD findMostPopularDocumentsOnDemand
	WSMETHOD deleteDocument
	WSMETHOD getActiveDocument
	WSMETHOD getDocumentApprovalStatus
	WSMETHOD createDocument

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cusername                 AS string
	WSDATA   cpassword                 AS string
	WSDATA   ncompanyId                AS int
	WSDATA   ndocumentId               AS int
	WSDATA   cpublisherId              AS string
	WSDATA   cdocumentDescription      AS string
	WSDATA   oWSupdateSimpleDocumentAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWSupdateSimpleDocumentresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   cuserId                   AS string
	WSDATA   nversion                  AS int
	WSDATA   capproverId               AS string
	WSDATA   lapproved                 AS boolean
	WSDATA   cobservation              AS string
	WSDATA   oWSapproveDocumentresult  AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   nparentDocumentId         AS int
	WSDATA   oWScreateSimpleDocumentPrivateAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWScreateSimpleDocumentPrivateresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   ntopicId                  AS int
	WSDATA   cuser                     AS string
	WSDATA   ccolleagueId              AS string
	WSDATA   oWSdestroyDocumentresult  AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSgetSecuritySecurity    AS ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSgetRelatedDocumentsRelatedDocuments AS ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWScreateSimpleDocumentAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWScreateSimpleDocumentresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos AS ECMDocumentServiceService_documentApprovementHistoryDtoArray
	WSDATA   ndocumentoVersao          AS int
	WSDATA   cnomeArquivo              AS string
	WSDATA   cfolder                   AS base64Binary
	WSDATA   npermissionType           AS int
	WSDATA   nrestrictionType          AS int
	WSDATA   oWSupdateGroupSecurityTyperesult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsDocument AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWSupdateDocumentWithApprovementLevelssecurity AS ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsApproversWithLevels AS ECMDocumentServiceService_approverWithLevelDtoArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsLevels AS ECMDocumentServiceService_approvalLevelDtoArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsRelatedDocuments AS ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWSupdateDocumentWithApprovementLevelsresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSgetApproversApprovers  AS ECMDocumentServiceService_approverWithLevelDtoArray
	WSDATA   nnrResultados             AS int
	WSDATA   oWSfindMostPopularDocumentsresult AS ECMDocumentServiceService_documentDtoArray
	WSDATA   nresult                   AS int
	WSDATA   nstatus                   AS int
	WSDATA   cmsg                      AS string
	WSDATA   oWSupdateDocumentConversionStatusresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSmoveDocumentdocumentIds AS ECMDocumentServiceService_intArray
	WSDATA   ndestFolderId             AS int
	WSDATA   oWSgetDocumentVersionfolder AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSdestroyDocumentApprovalresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWScreateDocumentWithApprovementLevelsDocument AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWScreateDocumentWithApprovementLevelsAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWScreateDocumentWithApprovementLevelssecurity AS ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWScreateDocumentWithApprovementLevelsApproversWithLevels AS ECMDocumentServiceService_approverWithLevelDtoArray
	WSDATA   oWScreateDocumentWithApprovementLevelsLevels AS ECMDocumentServiceService_approvalLevelDtoArray
	WSDATA   oWScreateDocumentWithApprovementLevelsRelatedDocuments AS ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWScreateDocumentWithApprovementLevelsresult AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSfindRecycledDocumentsresult AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSrestoreDocumentresult  AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWScopyDocumentToUploadArearesult AS ECMDocumentServiceService_stringArray
	WSDATA   cexternalDocumentnId      AS string
	WSDATA   oWSgetDocumentByExternalIdDocuments AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSupdateDocumentDocument AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSupdateDocumentAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWSupdateDocumentsecurity AS ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSupdateDocumentApprovers AS ECMDocumentServiceService_approverDtoArray
	WSDATA   oWSupdateDocumentRelatedDocuments AS ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWSupdateDocumentresult   AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   nlimit                    AS int
	WSDATA   nlastRowId                AS int
	WSDATA   oWSfindMostPopularDocumentsOnDemandresult AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSdeleteDocumentresult   AS ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSgetActiveDocumentfolder AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos AS ECMDocumentServiceService_documentApprovalStatusDtoArray
	WSDATA   oWScreateDocumentDocument AS ECMDocumentServiceService_documentDtoArray
	WSDATA   oWScreateDocumentAttachments AS ECMDocumentServiceService_attachmentArray
	WSDATA   oWScreateDocumentsecurity AS ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWScreateDocumentApprovers AS ECMDocumentServiceService_approverDtoArray
	WSDATA   oWScreateDocumentRelatedDocuments AS ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWScreateDocumentresult   AS ECMDocumentServiceService_webServiceMessageArray

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSECMDocumentServiceService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120120] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSECMDocumentServiceService
	::oWSupdateSimpleDocumentAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWSupdateSimpleDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSapproveDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWScreateSimpleDocumentPrivateAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWScreateSimpleDocumentPrivateresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSdestroyDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSgetSecuritySecurity := ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWSgetRelatedDocumentsRelatedDocuments := ECMDocumentServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWScreateSimpleDocumentAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWScreateSimpleDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos := ECMDocumentServiceService_DOCUMENTAPPROVEMENTHISTORYDTOARRAY():New()
	::oWSupdateGroupSecurityTyperesult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsDocument := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWSupdateDocumentWithApprovementLevelssecurity := ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsApproversWithLevels := ECMDocumentServiceService_APPROVERWITHLEVELDTOARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsLevels := ECMDocumentServiceService_APPROVALLEVELDTOARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsRelatedDocuments := ECMDocumentServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWSupdateDocumentWithApprovementLevelsresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSgetApproversApprovers := ECMDocumentServiceService_APPROVERWITHLEVELDTOARRAY():New()
	::oWSfindMostPopularDocumentsresult := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSupdateDocumentConversionStatusresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSmoveDocumentdocumentIds := ECMDocumentServiceService_INTARRAY():New()
	::oWSgetDocumentVersionfolder := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSdestroyDocumentApprovalresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWScreateDocumentWithApprovementLevelsDocument := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWScreateDocumentWithApprovementLevelsAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWScreateDocumentWithApprovementLevelssecurity := ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWScreateDocumentWithApprovementLevelsApproversWithLevels := ECMDocumentServiceService_APPROVERWITHLEVELDTOARRAY():New()
	::oWScreateDocumentWithApprovementLevelsLevels := ECMDocumentServiceService_APPROVALLEVELDTOARRAY():New()
	::oWScreateDocumentWithApprovementLevelsRelatedDocuments := ECMDocumentServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWScreateDocumentWithApprovementLevelsresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSfindRecycledDocumentsresult := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSrestoreDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWScopyDocumentToUploadArearesult := ECMDocumentServiceService_STRINGARRAY():New()
	::oWSgetDocumentByExternalIdDocuments := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSupdateDocumentDocument := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSupdateDocumentAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWSupdateDocumentsecurity := ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWSupdateDocumentApprovers := ECMDocumentServiceService_APPROVERDTOARRAY():New()
	::oWSupdateDocumentRelatedDocuments := ECMDocumentServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWSupdateDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSfindMostPopularDocumentsOnDemandresult := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSdeleteDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSgetActiveDocumentfolder := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos := ECMDocumentServiceService_DOCUMENTAPPROVALSTATUSDTOARRAY():New()
	::oWScreateDocumentDocument := ECMDocumentServiceService_DOCUMENTDTOARRAY():New()
	::oWScreateDocumentAttachments := ECMDocumentServiceService_ATTACHMENTARRAY():New()
	::oWScreateDocumentsecurity := ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWScreateDocumentApprovers := ECMDocumentServiceService_APPROVERDTOARRAY():New()
	::oWScreateDocumentRelatedDocuments := ECMDocumentServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWScreateDocumentresult := ECMDocumentServiceService_WEBSERVICEMESSAGEARRAY():New()
Return

WSMETHOD RESET WSCLIENT WSECMDocumentServiceService
	::cusername          := NIL 
	::cpassword          := NIL 
	::ncompanyId         := NIL 
	::ndocumentId        := NIL 
	::cpublisherId       := NIL 
	::cdocumentDescription := NIL 
	::oWSupdateSimpleDocumentAttachments := NIL 
	::oWSupdateSimpleDocumentresult := NIL 
	::cuserId            := NIL 
	::nversion           := NIL 
	::capproverId        := NIL 
	::lapproved          := NIL 
	::cobservation       := NIL 
	::oWSapproveDocumentresult := NIL 
	::nparentDocumentId  := NIL 
	::oWScreateSimpleDocumentPrivateAttachments := NIL 
	::oWScreateSimpleDocumentPrivateresult := NIL 
	::ntopicId           := NIL 
	::cuser              := NIL 
	::ccolleagueId       := NIL 
	::oWSdestroyDocumentresult := NIL 
	::oWSgetSecuritySecurity := NIL 
	::oWSgetRelatedDocumentsRelatedDocuments := NIL 
	::oWScreateSimpleDocumentAttachments := NIL 
	::oWScreateSimpleDocumentresult := NIL 
	::oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos := NIL 
	::ndocumentoVersao   := NIL 
	::cnomeArquivo       := NIL 
	::cfolder            := NIL 
	::npermissionType    := NIL 
	::nrestrictionType   := NIL 
	::oWSupdateGroupSecurityTyperesult := NIL 
	::oWSupdateDocumentWithApprovementLevelsDocument := NIL 
	::oWSupdateDocumentWithApprovementLevelsAttachments := NIL 
	::oWSupdateDocumentWithApprovementLevelssecurity := NIL 
	::oWSupdateDocumentWithApprovementLevelsApproversWithLevels := NIL 
	::oWSupdateDocumentWithApprovementLevelsLevels := NIL 
	::oWSupdateDocumentWithApprovementLevelsRelatedDocuments := NIL 
	::oWSupdateDocumentWithApprovementLevelsresult := NIL 
	::oWSgetApproversApprovers := NIL 
	::nnrResultados      := NIL 
	::oWSfindMostPopularDocumentsresult := NIL 
	::nresult            := NIL 
	::nstatus            := NIL 
	::cmsg               := NIL 
	::oWSupdateDocumentConversionStatusresult := NIL 
	::oWSmoveDocumentdocumentIds := NIL 
	::ndestFolderId      := NIL 
	::oWSgetDocumentVersionfolder := NIL 
	::oWSdestroyDocumentApprovalresult := NIL 
	::oWScreateDocumentWithApprovementLevelsDocument := NIL 
	::oWScreateDocumentWithApprovementLevelsAttachments := NIL 
	::oWScreateDocumentWithApprovementLevelssecurity := NIL 
	::oWScreateDocumentWithApprovementLevelsApproversWithLevels := NIL 
	::oWScreateDocumentWithApprovementLevelsLevels := NIL 
	::oWScreateDocumentWithApprovementLevelsRelatedDocuments := NIL 
	::oWScreateDocumentWithApprovementLevelsresult := NIL 
	::oWSfindRecycledDocumentsresult := NIL 
	::oWSrestoreDocumentresult := NIL 
	::oWScopyDocumentToUploadArearesult := NIL 
	::cexternalDocumentnId := NIL 
	::oWSgetDocumentByExternalIdDocuments := NIL 
	::oWSupdateDocumentDocument := NIL 
	::oWSupdateDocumentAttachments := NIL 
	::oWSupdateDocumentsecurity := NIL 
	::oWSupdateDocumentApprovers := NIL 
	::oWSupdateDocumentRelatedDocuments := NIL 
	::oWSupdateDocumentresult := NIL 
	::nlimit             := NIL 
	::nlastRowId         := NIL 
	::oWSfindMostPopularDocumentsOnDemandresult := NIL 
	::oWSdeleteDocumentresult := NIL 
	::oWSgetActiveDocumentfolder := NIL 
	::oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos := NIL 
	::oWScreateDocumentDocument := NIL 
	::oWScreateDocumentAttachments := NIL 
	::oWScreateDocumentsecurity := NIL 
	::oWScreateDocumentApprovers := NIL 
	::oWScreateDocumentRelatedDocuments := NIL 
	::oWScreateDocumentresult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSECMDocumentServiceService
Local oClone := WSECMDocumentServiceService():New()
	oClone:_URL          := ::_URL 
	oClone:cusername     := ::cusername
	oClone:cpassword     := ::cpassword
	oClone:ncompanyId    := ::ncompanyId
	oClone:ndocumentId   := ::ndocumentId
	oClone:cpublisherId  := ::cpublisherId
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:oWSupdateSimpleDocumentAttachments :=  IIF(::oWSupdateSimpleDocumentAttachments = NIL , NIL ,::oWSupdateSimpleDocumentAttachments:Clone() )
	oClone:oWSupdateSimpleDocumentresult :=  IIF(::oWSupdateSimpleDocumentresult = NIL , NIL ,::oWSupdateSimpleDocumentresult:Clone() )
	oClone:cuserId       := ::cuserId
	oClone:nversion      := ::nversion
	oClone:capproverId   := ::capproverId
	oClone:lapproved     := ::lapproved
	oClone:cobservation  := ::cobservation
	oClone:oWSapproveDocumentresult :=  IIF(::oWSapproveDocumentresult = NIL , NIL ,::oWSapproveDocumentresult:Clone() )
	oClone:nparentDocumentId := ::nparentDocumentId
	oClone:oWScreateSimpleDocumentPrivateAttachments :=  IIF(::oWScreateSimpleDocumentPrivateAttachments = NIL , NIL ,::oWScreateSimpleDocumentPrivateAttachments:Clone() )
	oClone:oWScreateSimpleDocumentPrivateresult :=  IIF(::oWScreateSimpleDocumentPrivateresult = NIL , NIL ,::oWScreateSimpleDocumentPrivateresult:Clone() )
	oClone:ntopicId      := ::ntopicId
	oClone:cuser         := ::cuser
	oClone:ccolleagueId  := ::ccolleagueId
	oClone:oWSdestroyDocumentresult :=  IIF(::oWSdestroyDocumentresult = NIL , NIL ,::oWSdestroyDocumentresult:Clone() )
	oClone:oWSgetSecuritySecurity :=  IIF(::oWSgetSecuritySecurity = NIL , NIL ,::oWSgetSecuritySecurity:Clone() )
	oClone:oWSgetRelatedDocumentsRelatedDocuments :=  IIF(::oWSgetRelatedDocumentsRelatedDocuments = NIL , NIL ,::oWSgetRelatedDocumentsRelatedDocuments:Clone() )
	oClone:oWScreateSimpleDocumentAttachments :=  IIF(::oWScreateSimpleDocumentAttachments = NIL , NIL ,::oWScreateSimpleDocumentAttachments:Clone() )
	oClone:oWScreateSimpleDocumentresult :=  IIF(::oWScreateSimpleDocumentresult = NIL , NIL ,::oWScreateSimpleDocumentresult:Clone() )
	oClone:oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos :=  IIF(::oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos = NIL , NIL ,::oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos:Clone() )
	oClone:ndocumentoVersao := ::ndocumentoVersao
	oClone:cnomeArquivo  := ::cnomeArquivo
	oClone:cfolder       := ::cfolder
	oClone:npermissionType := ::npermissionType
	oClone:nrestrictionType := ::nrestrictionType
	oClone:oWSupdateGroupSecurityTyperesult :=  IIF(::oWSupdateGroupSecurityTyperesult = NIL , NIL ,::oWSupdateGroupSecurityTyperesult:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsDocument :=  IIF(::oWSupdateDocumentWithApprovementLevelsDocument = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsDocument:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsAttachments :=  IIF(::oWSupdateDocumentWithApprovementLevelsAttachments = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsAttachments:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelssecurity :=  IIF(::oWSupdateDocumentWithApprovementLevelssecurity = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelssecurity:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsApproversWithLevels :=  IIF(::oWSupdateDocumentWithApprovementLevelsApproversWithLevels = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsApproversWithLevels:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsLevels :=  IIF(::oWSupdateDocumentWithApprovementLevelsLevels = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsLevels:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsRelatedDocuments :=  IIF(::oWSupdateDocumentWithApprovementLevelsRelatedDocuments = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsRelatedDocuments:Clone() )
	oClone:oWSupdateDocumentWithApprovementLevelsresult :=  IIF(::oWSupdateDocumentWithApprovementLevelsresult = NIL , NIL ,::oWSupdateDocumentWithApprovementLevelsresult:Clone() )
	oClone:oWSgetApproversApprovers :=  IIF(::oWSgetApproversApprovers = NIL , NIL ,::oWSgetApproversApprovers:Clone() )
	oClone:nnrResultados := ::nnrResultados
	oClone:oWSfindMostPopularDocumentsresult :=  IIF(::oWSfindMostPopularDocumentsresult = NIL , NIL ,::oWSfindMostPopularDocumentsresult:Clone() )
	oClone:nresult       := ::nresult
	oClone:nstatus       := ::nstatus
	oClone:cmsg          := ::cmsg
	oClone:oWSupdateDocumentConversionStatusresult :=  IIF(::oWSupdateDocumentConversionStatusresult = NIL , NIL ,::oWSupdateDocumentConversionStatusresult:Clone() )
	oClone:oWSmoveDocumentdocumentIds :=  IIF(::oWSmoveDocumentdocumentIds = NIL , NIL ,::oWSmoveDocumentdocumentIds:Clone() )
	oClone:ndestFolderId := ::ndestFolderId
	oClone:oWSgetDocumentVersionfolder :=  IIF(::oWSgetDocumentVersionfolder = NIL , NIL ,::oWSgetDocumentVersionfolder:Clone() )
	oClone:oWSdestroyDocumentApprovalresult :=  IIF(::oWSdestroyDocumentApprovalresult = NIL , NIL ,::oWSdestroyDocumentApprovalresult:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsDocument :=  IIF(::oWScreateDocumentWithApprovementLevelsDocument = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsDocument:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsAttachments :=  IIF(::oWScreateDocumentWithApprovementLevelsAttachments = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsAttachments:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelssecurity :=  IIF(::oWScreateDocumentWithApprovementLevelssecurity = NIL , NIL ,::oWScreateDocumentWithApprovementLevelssecurity:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsApproversWithLevels :=  IIF(::oWScreateDocumentWithApprovementLevelsApproversWithLevels = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsApproversWithLevels:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsLevels :=  IIF(::oWScreateDocumentWithApprovementLevelsLevels = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsLevels:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsRelatedDocuments :=  IIF(::oWScreateDocumentWithApprovementLevelsRelatedDocuments = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsRelatedDocuments:Clone() )
	oClone:oWScreateDocumentWithApprovementLevelsresult :=  IIF(::oWScreateDocumentWithApprovementLevelsresult = NIL , NIL ,::oWScreateDocumentWithApprovementLevelsresult:Clone() )
	oClone:oWSfindRecycledDocumentsresult :=  IIF(::oWSfindRecycledDocumentsresult = NIL , NIL ,::oWSfindRecycledDocumentsresult:Clone() )
	oClone:oWSrestoreDocumentresult :=  IIF(::oWSrestoreDocumentresult = NIL , NIL ,::oWSrestoreDocumentresult:Clone() )
	oClone:oWScopyDocumentToUploadArearesult :=  IIF(::oWScopyDocumentToUploadArearesult = NIL , NIL ,::oWScopyDocumentToUploadArearesult:Clone() )
	oClone:cexternalDocumentnId := ::cexternalDocumentnId
	oClone:oWSgetDocumentByExternalIdDocuments :=  IIF(::oWSgetDocumentByExternalIdDocuments = NIL , NIL ,::oWSgetDocumentByExternalIdDocuments:Clone() )
	oClone:oWSupdateDocumentDocument :=  IIF(::oWSupdateDocumentDocument = NIL , NIL ,::oWSupdateDocumentDocument:Clone() )
	oClone:oWSupdateDocumentAttachments :=  IIF(::oWSupdateDocumentAttachments = NIL , NIL ,::oWSupdateDocumentAttachments:Clone() )
	oClone:oWSupdateDocumentsecurity :=  IIF(::oWSupdateDocumentsecurity = NIL , NIL ,::oWSupdateDocumentsecurity:Clone() )
	oClone:oWSupdateDocumentApprovers :=  IIF(::oWSupdateDocumentApprovers = NIL , NIL ,::oWSupdateDocumentApprovers:Clone() )
	oClone:oWSupdateDocumentRelatedDocuments :=  IIF(::oWSupdateDocumentRelatedDocuments = NIL , NIL ,::oWSupdateDocumentRelatedDocuments:Clone() )
	oClone:oWSupdateDocumentresult :=  IIF(::oWSupdateDocumentresult = NIL , NIL ,::oWSupdateDocumentresult:Clone() )
	oClone:nlimit        := ::nlimit
	oClone:nlastRowId    := ::nlastRowId
	oClone:oWSfindMostPopularDocumentsOnDemandresult :=  IIF(::oWSfindMostPopularDocumentsOnDemandresult = NIL , NIL ,::oWSfindMostPopularDocumentsOnDemandresult:Clone() )
	oClone:oWSdeleteDocumentresult :=  IIF(::oWSdeleteDocumentresult = NIL , NIL ,::oWSdeleteDocumentresult:Clone() )
	oClone:oWSgetActiveDocumentfolder :=  IIF(::oWSgetActiveDocumentfolder = NIL , NIL ,::oWSgetActiveDocumentfolder:Clone() )
	oClone:oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos :=  IIF(::oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos = NIL , NIL ,::oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos:Clone() )
	oClone:oWScreateDocumentDocument :=  IIF(::oWScreateDocumentDocument = NIL , NIL ,::oWScreateDocumentDocument:Clone() )
	oClone:oWScreateDocumentAttachments :=  IIF(::oWScreateDocumentAttachments = NIL , NIL ,::oWScreateDocumentAttachments:Clone() )
	oClone:oWScreateDocumentsecurity :=  IIF(::oWScreateDocumentsecurity = NIL , NIL ,::oWScreateDocumentsecurity:Clone() )
	oClone:oWScreateDocumentApprovers :=  IIF(::oWScreateDocumentApprovers = NIL , NIL ,::oWScreateDocumentApprovers:Clone() )
	oClone:oWScreateDocumentRelatedDocuments :=  IIF(::oWScreateDocumentRelatedDocuments = NIL , NIL ,::oWScreateDocumentRelatedDocuments:Clone() )
	oClone:oWScreateDocumentresult :=  IIF(::oWScreateDocumentresult = NIL , NIL ,::oWScreateDocumentresult:Clone() )
Return oClone

// WSDL Method updateSimpleDocument of Service WSECMDocumentServiceService

WSMETHOD updateSimpleDocument WSSEND cusername,cpassword,ncompanyId,ndocumentId,cpublisherId,cdocumentDescription,oWSupdateSimpleDocumentAttachments WSRECEIVE oWSupdateSimpleDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateSimpleDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("publisherId", ::cpublisherId, cpublisherId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWSupdateSimpleDocumentAttachments, oWSupdateSimpleDocumentAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateSimpleDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateSimpleDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSupdateSimpleDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method approveDocument of Service WSECMDocumentServiceService

WSMETHOD approveDocument WSSEND ncompanyId,cuserId,cpassword,ndocumentId,nversion,capproverId,lapproved,cobservation WSRECEIVE oWSapproveDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:approveDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("approverId", ::capproverId, capproverId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("approved", ::lapproved, lapproved , "boolean", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("observation", ::cobservation, cobservation , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:approveDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"approveDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSapproveDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createSimpleDocumentPrivate of Service WSECMDocumentServiceService

WSMETHOD createSimpleDocumentPrivate WSSEND cusername,cpassword,ncompanyId,nparentDocumentId,cdocumentDescription,oWScreateSimpleDocumentPrivateAttachments WSRECEIVE oWScreateSimpleDocumentPrivateresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createSimpleDocumentPrivate xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWScreateSimpleDocumentPrivateAttachments, oWScreateSimpleDocumentPrivateAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createSimpleDocumentPrivate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createSimpleDocumentPrivate",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWScreateSimpleDocumentPrivateresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getReportSubjectId of Service WSECMDocumentServiceService

WSMETHOD getReportSubjectId WSSEND cusername,cpassword,ncompanyId WSRECEIVE ntopicId WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getReportSubjectId xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getReportSubjectId>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getReportSubject",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::ntopicId           :=  WSAdvValue( oXmlRet,"_TOPICID","int",NIL,NIL,NIL,"N",NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method destroyDocument of Service WSECMDocumentServiceService

WSMETHOD destroyDocument WSSEND cuser,cpassword,ncompanyId,ndocumentId,ccolleagueId WSRECEIVE oWSdestroyDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:destroyDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:destroyDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"destroyDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSdestroyDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getSecurity of Service WSECMDocumentServiceService

WSMETHOD getSecurity WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE oWSgetSecuritySecurity WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getSecurity xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getSecurity>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getSecurity",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetSecuritySecurity:SoapRecv( WSAdvValue( oXmlRet,"_SECURITY","documentSecurityConfigDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getRelatedDocuments of Service WSECMDocumentServiceService

WSMETHOD getRelatedDocuments WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE oWSgetRelatedDocumentsRelatedDocuments WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getRelatedDocuments xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getRelatedDocuments>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getRelatedDocuments",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetRelatedDocumentsRelatedDocuments:SoapRecv( WSAdvValue( oXmlRet,"_RELATEDDOCUMENTS","relatedDocumentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createSimpleDocument of Service WSECMDocumentServiceService

WSMETHOD createSimpleDocument WSSEND cusername,cpassword,ncompanyId,nparentDocumentId,cpublisherId,cdocumentDescription,oWScreateSimpleDocumentAttachments WSRECEIVE oWScreateSimpleDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createSimpleDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("publisherId", ::cpublisherId, cpublisherId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWScreateSimpleDocumentAttachments, oWScreateSimpleDocumentAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createSimpleDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createSimpleDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWScreateSimpleDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDocumentApprovalHistory of Service WSECMDocumentServiceService

WSMETHOD getDocumentApprovalHistory WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDocumentApprovalHistory xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDocumentApprovalHistory>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDocumentApprovalHistory",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetDocumentApprovalHistoryDocumentApprovementHistoryDtos:SoapRecv( WSAdvValue( oXmlRet,"_DOCUMENTAPPROVEMENTHISTORYDTOS","documentApprovementHistoryDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDocumentContent of Service WSECMDocumentServiceService

WSMETHOD getDocumentContent WSSEND cusername,cpassword,ncompanyId,ndocumentId,ccolleagueId,ndocumentoVersao,cnomeArquivo WSRECEIVE cfolder WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDocumentContent xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentoVersao", ::ndocumentoVersao, ndocumentoVersao , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("nomeArquivo", ::cnomeArquivo, cnomeArquivo , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDocumentContent>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDocumentContent",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::cfolder            :=  WSAdvValue( oXmlRet,"_FOLDER","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateGroupSecurityType of Service WSECMDocumentServiceService

WSMETHOD updateGroupSecurityType WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion,npermissionType,nrestrictionType,ccolleagueId WSRECEIVE oWSupdateGroupSecurityTyperesult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateGroupSecurityType xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("permissionType", ::npermissionType, npermissionType , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("restrictionType", ::nrestrictionType, nrestrictionType , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateGroupSecurityType>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateGroupSecurityType",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSupdateGroupSecurityTyperesult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateDocumentWithApprovementLevels of Service WSECMDocumentServiceService

WSMETHOD updateDocumentWithApprovementLevels WSSEND cusername,cpassword,ncompanyId,oWSupdateDocumentWithApprovementLevelsDocument,oWSupdateDocumentWithApprovementLevelsAttachments,oWSupdateDocumentWithApprovementLevelssecurity,oWSupdateDocumentWithApprovementLevelsApproversWithLevels,oWSupdateDocumentWithApprovementLevelsLevels,oWSupdateDocumentWithApprovementLevelsRelatedDocuments WSRECEIVE oWSupdateDocumentWithApprovementLevelsresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateDocumentWithApprovementLevels xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Document", ::oWSupdateDocumentWithApprovementLevelsDocument, oWSupdateDocumentWithApprovementLevelsDocument , "documentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWSupdateDocumentWithApprovementLevelsAttachments, oWSupdateDocumentWithApprovementLevelsAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("security", ::oWSupdateDocumentWithApprovementLevelssecurity, oWSupdateDocumentWithApprovementLevelssecurity , "documentSecurityConfigDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("ApproversWithLevels", ::oWSupdateDocumentWithApprovementLevelsApproversWithLevels, oWSupdateDocumentWithApprovementLevelsApproversWithLevels , "approverWithLevelDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Levels", ::oWSupdateDocumentWithApprovementLevelsLevels, oWSupdateDocumentWithApprovementLevelsLevels , "approvalLevelDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("RelatedDocuments", ::oWSupdateDocumentWithApprovementLevelsRelatedDocuments, oWSupdateDocumentWithApprovementLevelsRelatedDocuments , "relatedDocumentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateDocumentWithApprovementLevels>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateDocumentWithApprovementLevels",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSupdateDocumentWithApprovementLevelsresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getApprovers of Service WSECMDocumentServiceService

WSMETHOD getApprovers WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE oWSgetApproversApprovers WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getApprovers xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getApprovers>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getApprovers",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetApproversApprovers:SoapRecv( WSAdvValue( oXmlRet,"_APPROVERS","approverWithLevelDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method findMostPopularDocuments of Service WSECMDocumentServiceService

WSMETHOD findMostPopularDocuments WSSEND cusername,cpassword,ncompanyId,ccolleagueId,nnrResultados WSRECEIVE oWSfindMostPopularDocumentsresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:findMostPopularDocuments xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("nrResultados", ::nnrResultados, nnrResultados , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:findMostPopularDocuments>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"findMostPopularDocuments",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSfindMostPopularDocumentsresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getUserPermissions of Service WSECMDocumentServiceService

WSMETHOD getUserPermissions WSSEND ncompanyId,cusername,ndocumentId,nversion WSRECEIVE nresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getUserPermissions xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getUserPermissions>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getUserPermissions",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::nresult            :=  WSAdvValue( oXmlRet,"_RESULT","int",NIL,NIL,NIL,"N",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateDocumentConversionStatus of Service WSECMDocumentServiceService

WSMETHOD updateDocumentConversionStatus WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion,nstatus,cmsg WSRECEIVE oWSupdateDocumentConversionStatusresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateDocumentConversionStatus xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("status", ::nstatus, nstatus , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("msg", ::cmsg, cmsg , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateDocumentConversionStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateDocumentConversionStatus",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSupdateDocumentConversionStatusresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method moveDocument of Service WSECMDocumentServiceService

WSMETHOD moveDocument WSSEND cusername,cpassword,ncompanyId,oWSmoveDocumentdocumentIds,ccolleagueId,ndestFolderId WSRECEIVE cresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:moveDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentIds", ::oWSmoveDocumentdocumentIds, oWSmoveDocumentdocumentIds , "intArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("destFolderId", ::ndestFolderId, ndestFolderId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:moveDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"moveDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDocumentVersion of Service WSECMDocumentServiceService

WSMETHOD getDocumentVersion WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion,ccolleagueId WSRECEIVE oWSgetDocumentVersionfolder WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDocumentVersion xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDocumentVersion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDocumentVersion",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetDocumentVersionfolder:SoapRecv( WSAdvValue( oXmlRet,"_FOLDER","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method destroyDocumentApproval of Service WSECMDocumentServiceService

WSMETHOD destroyDocumentApproval WSSEND cuserId,cpassword,ncompanyId,ndocumentId,cpublisherId WSRECEIVE oWSdestroyDocumentApprovalresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:destroyDocumentApproval xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("publisherId", ::cpublisherId, cpublisherId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:destroyDocumentApproval>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"destroyDocumentApproval",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSdestroyDocumentApprovalresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createDocumentWithApprovementLevels of Service WSECMDocumentServiceService

WSMETHOD createDocumentWithApprovementLevels WSSEND cusername,cpassword,ncompanyId,oWScreateDocumentWithApprovementLevelsDocument,oWScreateDocumentWithApprovementLevelsAttachments,oWScreateDocumentWithApprovementLevelssecurity,oWScreateDocumentWithApprovementLevelsApproversWithLevels,oWScreateDocumentWithApprovementLevelsLevels,oWScreateDocumentWithApprovementLevelsRelatedDocuments WSRECEIVE oWScreateDocumentWithApprovementLevelsresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createDocumentWithApprovementLevels xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Document", ::oWScreateDocumentWithApprovementLevelsDocument, oWScreateDocumentWithApprovementLevelsDocument , "documentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWScreateDocumentWithApprovementLevelsAttachments, oWScreateDocumentWithApprovementLevelsAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("security", ::oWScreateDocumentWithApprovementLevelssecurity, oWScreateDocumentWithApprovementLevelssecurity , "documentSecurityConfigDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("ApproversWithLevels", ::oWScreateDocumentWithApprovementLevelsApproversWithLevels, oWScreateDocumentWithApprovementLevelsApproversWithLevels , "approverWithLevelDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Levels", ::oWScreateDocumentWithApprovementLevelsLevels, oWScreateDocumentWithApprovementLevelsLevels , "approvalLevelDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("RelatedDocuments", ::oWScreateDocumentWithApprovementLevelsRelatedDocuments, oWScreateDocumentWithApprovementLevelsRelatedDocuments , "relatedDocumentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createDocumentWithApprovementLevels>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createDocumentWithApprovementLevels",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWScreateDocumentWithApprovementLevelsresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method findRecycledDocuments of Service WSECMDocumentServiceService

WSMETHOD findRecycledDocuments WSSEND cuser,cpassword,ncompanyId,ccolleagueId WSRECEIVE oWSfindRecycledDocumentsresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:findRecycledDocuments xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:findRecycledDocuments>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"findRecycledDocuments",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSfindRecycledDocumentsresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method restoreDocument of Service WSECMDocumentServiceService

WSMETHOD restoreDocument WSSEND cuser,cpassword,ncompanyId,ndocumentId,ccolleagueId WSRECEIVE oWSrestoreDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:restoreDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:restoreDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"restoreDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSrestoreDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeSecurity of Service WSECMDocumentServiceService

WSMETHOD removeSecurity WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE NULLPARAM WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:removeSecurity xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:removeSecurity>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"removeSecurity",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method copyDocumentToUploadArea of Service WSECMDocumentServiceService

WSMETHOD copyDocumentToUploadArea WSSEND cuser,cpassword,ncompanyId,ndocumentId,nversion,ccolleagueId WSRECEIVE oWScopyDocumentToUploadArearesult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:copyDocumentToUploadArea xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:copyDocumentToUploadArea>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"copyDocumentToUploadArea",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWScopyDocumentToUploadArearesult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","stringArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDocumentByExternalId of Service WSECMDocumentServiceService

WSMETHOD getDocumentByExternalId WSSEND cusername,cpassword,ncompanyId,cexternalDocumentnId,ccolleagueId WSRECEIVE oWSgetDocumentByExternalIdDocuments WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDocumentByExternalId xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("externalDocumentnId", ::cexternalDocumentnId, cexternalDocumentnId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDocumentByExternalId>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDocumentByExternalId",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetDocumentByExternalIdDocuments:SoapRecv( WSAdvValue( oXmlRet,"_DOCUMENTS","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method validateIntegrationRequirements of Service WSECMDocumentServiceService

WSMETHOD validateIntegrationRequirements WSSEND cusername,cpassword,ncompanyId WSRECEIVE cresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:validateIntegrationRequirements xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:validateIntegrationRequirements>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"validateIntegrationRequirements",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateDocument of Service WSECMDocumentServiceService

WSMETHOD updateDocument WSSEND cusername,cpassword,ncompanyId,oWSupdateDocumentDocument,oWSupdateDocumentAttachments,oWSupdateDocumentsecurity,oWSupdateDocumentApprovers,oWSupdateDocumentRelatedDocuments WSRECEIVE oWSupdateDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Document", ::oWSupdateDocumentDocument, oWSupdateDocumentDocument , "documentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWSupdateDocumentAttachments, oWSupdateDocumentAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("security", ::oWSupdateDocumentsecurity, oWSupdateDocumentsecurity , "documentSecurityConfigDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Approvers", ::oWSupdateDocumentApprovers, oWSupdateDocumentApprovers , "approverDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("RelatedDocuments", ::oWSupdateDocumentRelatedDocuments, oWSupdateDocumentRelatedDocuments , "relatedDocumentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSupdateDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method findMostPopularDocumentsOnDemand of Service WSECMDocumentServiceService

WSMETHOD findMostPopularDocumentsOnDemand WSSEND ncompanyId,cuser,cpassword,ccolleagueId,nlimit,nlastRowId WSRECEIVE oWSfindMostPopularDocumentsOnDemandresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:findMostPopularDocumentsOnDemand xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("limit", ::nlimit, nlimit , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("lastRowId", ::nlastRowId, nlastRowId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:findMostPopularDocumentsOnDemand>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"findMostPopularDocumentsOnDemand",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSfindMostPopularDocumentsOnDemandresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteDocument of Service WSECMDocumentServiceService

WSMETHOD deleteDocument WSSEND cuser,cpassword,ncompanyId,ndocumentId,ccolleagueId WSRECEIVE oWSdeleteDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:deleteDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("user", ::cuser, cuser , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:deleteDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"deleteDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSdeleteDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getActiveDocument of Service WSECMDocumentServiceService

WSMETHOD getActiveDocument WSSEND cusername,cpassword,ncompanyId,ndocumentId,ccolleagueId WSRECEIVE oWSgetActiveDocumentfolder WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getActiveDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getActiveDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getActiveDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetActiveDocumentfolder:SoapRecv( WSAdvValue( oXmlRet,"_FOLDER","documentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getDocumentApprovalStatus of Service WSECMDocumentServiceService

WSMETHOD getDocumentApprovalStatus WSSEND cusername,cpassword,ncompanyId,ndocumentId,nversion WSRECEIVE oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getDocumentApprovalStatus xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getDocumentApprovalStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getDocumentApprovalStatus",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWSgetDocumentApprovalStatusDocumentApprovalStatusDtos:SoapRecv( WSAdvValue( oXmlRet,"_DOCUMENTAPPROVALSTATUSDTOS","documentApprovalStatusDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createDocument of Service WSECMDocumentServiceService

WSMETHOD createDocument WSSEND cusername,cpassword,ncompanyId,oWScreateDocumentDocument,oWScreateDocumentAttachments,oWScreateDocumentsecurity,oWScreateDocumentApprovers,oWScreateDocumentRelatedDocuments WSRECEIVE oWScreateDocumentresult WSCLIENT WSECMDocumentServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createDocument xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Document", ::oWScreateDocumentDocument, oWScreateDocumentDocument , "documentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Attachments", ::oWScreateDocumentAttachments, oWScreateDocumentAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("security", ::oWScreateDocumentsecurity, oWScreateDocumentsecurity , "documentSecurityConfigDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("Approvers", ::oWScreateDocumentApprovers, oWScreateDocumentApprovers , "approverDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("RelatedDocuments", ::oWScreateDocumentRelatedDocuments, oWScreateDocumentRelatedDocuments , "relatedDocumentDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createDocument>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createDocument",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://gt.fluig.com:8280/webdesk/ECMDocumentService")

::Init()
::oWScreateDocumentresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure attachmentArray

WSSTRUCT ECMDocumentServiceService_attachmentArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_attachment OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_attachmentArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_attachmentArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_attachmentArray
	Local oClone := ECMDocumentServiceService_attachmentArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_attachmentArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "attachment", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure webServiceMessageArray

WSSTRUCT ECMDocumentServiceService_webServiceMessageArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_webServiceMessage OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_webServiceMessageArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_webServiceMessageArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_WEBSERVICEMESSAGE():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_webServiceMessageArray
	Local oClone := ECMDocumentServiceService_webServiceMessageArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_webServiceMessageArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_webServiceMessage():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure documentSecurityConfigDtoArray

WSSTRUCT ECMDocumentServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_documentSecurityConfigDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentSecurityConfigDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentSecurityConfigDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_DOCUMENTSECURITYCONFIGDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentSecurityConfigDtoArray
	Local oClone := ECMDocumentServiceService_documentSecurityConfigDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_documentSecurityConfigDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "documentSecurityConfigDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentSecurityConfigDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_documentSecurityConfigDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure relatedDocumentDtoArray

WSSTRUCT ECMDocumentServiceService_relatedDocumentDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_relatedDocumentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_relatedDocumentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_relatedDocumentDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_RELATEDDOCUMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_relatedDocumentDtoArray
	Local oClone := ECMDocumentServiceService_relatedDocumentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_relatedDocumentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "relatedDocumentDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_relatedDocumentDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_relatedDocumentDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure documentApprovementHistoryDtoArray

WSSTRUCT ECMDocumentServiceService_documentApprovementHistoryDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_documentApprovementHistoryDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_DOCUMENTAPPROVEMENTHISTORYDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDtoArray
	Local oClone := ECMDocumentServiceService_documentApprovementHistoryDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_documentApprovementHistoryDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure documentDtoArray

WSSTRUCT ECMDocumentServiceService_documentDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_documentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_DOCUMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentDtoArray
	Local oClone := ECMDocumentServiceService_documentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_documentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "documentDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_documentDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure approverWithLevelDtoArray

WSSTRUCT ECMDocumentServiceService_approverWithLevelDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_approverWithLevelDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approverWithLevelDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approverWithLevelDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_APPROVERWITHLEVELDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approverWithLevelDtoArray
	Local oClone := ECMDocumentServiceService_approverWithLevelDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approverWithLevelDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "approverWithLevelDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_approverWithLevelDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_approverWithLevelDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure approvalLevelDtoArray

WSSTRUCT ECMDocumentServiceService_approvalLevelDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_approvalLevelDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approvalLevelDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approvalLevelDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_APPROVALLEVELDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approvalLevelDtoArray
	Local oClone := ECMDocumentServiceService_approvalLevelDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approvalLevelDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "approvalLevelDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure intArray

WSSTRUCT ECMDocumentServiceService_intArray
	WSDATA   nitem                     AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_intArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_intArray
	::nitem                := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_intArray
	Local oClone := ECMDocumentServiceService_intArray():NEW()
	oClone:nitem                := IIf(::nitem <> NIL , aClone(::nitem) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_intArray
	Local cSoap := ""
	aEval( ::nitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "int", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure stringArray

WSSTRUCT ECMDocumentServiceService_stringArray
	WSDATA   citem                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_stringArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_stringArray
	::citem                := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_stringArray
	Local oClone := ECMDocumentServiceService_stringArray():NEW()
	oClone:citem                := IIf(::citem <> NIL , aClone(::citem) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_stringArray
	Local oNodes1 :=  WSAdvValue( oResponse,"_ITEM","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::citem ,  x:TEXT  ) } )
Return

// WSDL Data Structure approverDtoArray

WSSTRUCT ECMDocumentServiceService_approverDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_approverDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approverDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approverDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_APPROVERDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approverDtoArray
	Local oClone := ECMDocumentServiceService_approverDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approverDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "approverDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure documentApprovalStatusDtoArray

WSSTRUCT ECMDocumentServiceService_documentApprovalStatusDtoArray
	WSDATA   oWSitem                   AS ECMDocumentServiceService_documentApprovalStatusDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentApprovalStatusDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentApprovalStatusDtoArray
	::oWSitem              := {} // Array Of  ECMDocumentServiceService_DOCUMENTAPPROVALSTATUSDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentApprovalStatusDtoArray
	Local oClone := ECMDocumentServiceService_documentApprovalStatusDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentApprovalStatusDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMDocumentServiceService_documentApprovalStatusDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure webServiceMessage

WSSTRUCT ECMDocumentServiceService_webServiceMessage
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cdocumentDescription      AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cwebServiceMessage        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_webServiceMessage
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_webServiceMessage
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_webServiceMessage
	Local oClone := ECMDocumentServiceService_webServiceMessage():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nversion             := ::nversion
	oClone:cwebServiceMessage   := ::cwebServiceMessage
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_webServiceMessage
	Local oNodes4 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentDescription :=  WSAdvValue( oResponse,"_DOCUMENTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes4 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cwebServiceMessage :=  WSAdvValue( oResponse,"_WEBSERVICEMESSAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure documentSecurityConfigDto

WSSTRUCT ECMDocumentServiceService_documentSecurityConfigDto
	WSDATA   nattributionType          AS int OPTIONAL
	WSDATA   cattributionValue         AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   ldownloadEnabled          AS boolean OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   lpermission               AS boolean OPTIONAL
	WSDATA   nsecurityLevel            AS int OPTIONAL
	WSDATA   lsecurityVersion          AS boolean OPTIONAL
	WSDATA   nsequence                 AS int OPTIONAL
	WSDATA   lshowContent              AS boolean OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentSecurityConfigDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentSecurityConfigDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentSecurityConfigDto
	Local oClone := ECMDocumentServiceService_documentSecurityConfigDto():NEW()
	oClone:nattributionType     := ::nattributionType
	oClone:cattributionValue    := ::cattributionValue
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:ldownloadEnabled     := ::ldownloadEnabled
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:lpermission          := ::lpermission
	oClone:nsecurityLevel       := ::nsecurityLevel
	oClone:lsecurityVersion     := ::lsecurityVersion
	oClone:nsequence            := ::nsequence
	oClone:lshowContent         := ::lshowContent
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_documentSecurityConfigDto
	Local cSoap := ""
	cSoap += WSSoapValue("attributionType", ::nattributionType, ::nattributionType , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("attributionValue", ::cattributionValue, ::cattributionValue , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("downloadEnabled", ::ldownloadEnabled, ::ldownloadEnabled , "boolean", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("permission", ::lpermission, ::lpermission , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("securityLevel", ::nsecurityLevel, ::nsecurityLevel , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("securityVersion", ::lsecurityVersion, ::lsecurityVersion , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("sequence", ::nsequence, ::nsequence , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("showContent", ::lshowContent, ::lshowContent , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentSecurityConfigDto
	Local oNodes6 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nattributionType   :=  WSAdvValue( oResponse,"_ATTRIBUTIONTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cattributionValue  :=  WSAdvValue( oResponse,"_ATTRIBUTIONVALUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ldownloadEnabled   :=  WSAdvValue( oResponse,"_DOWNLOADENABLED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	aEval(oNodes6 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::lpermission        :=  WSAdvValue( oResponse,"_PERMISSION","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsecurityLevel     :=  WSAdvValue( oResponse,"_SECURITYLEVEL","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lsecurityVersion   :=  WSAdvValue( oResponse,"_SECURITYVERSION","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsequence          :=  WSAdvValue( oResponse,"_SEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lshowContent       :=  WSAdvValue( oResponse,"_SHOWCONTENT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure relatedDocumentDto

WSSTRUCT ECMDocumentServiceService_relatedDocumentDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nrelatedDocumentId        AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_relatedDocumentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_relatedDocumentDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_relatedDocumentDto
	Local oClone := ECMDocumentServiceService_relatedDocumentDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nrelatedDocumentId   := ::nrelatedDocumentId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_relatedDocumentDto
	Local cSoap := ""
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("relatedDocumentId", ::nrelatedDocumentId, ::nrelatedDocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_relatedDocumentDto
	Local oNodes3 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes3 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::nrelatedDocumentId :=  WSAdvValue( oResponse,"_RELATEDDOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure documentApprovementHistoryDto

WSSTRUCT ECMDocumentServiceService_documentApprovementHistoryDto
	WSDATA   capprovementDate          AS dateTime OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ndocumentVersion          AS int OPTIONAL
	WSDATA   niterationSequence        AS int OPTIONAL
	WSDATA   nlevelId                  AS int OPTIONAL
	WSDATA   nmovementSequence         AS int OPTIONAL
	WSDATA   cobservation              AS string OPTIONAL
	WSDATA   lsigned                   AS boolean OPTIONAL
	WSDATA   nstatus                   AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDto
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDto
	Local oClone := ECMDocumentServiceService_documentApprovementHistoryDto():NEW()
	oClone:capprovementDate     := ::capprovementDate
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ndocumentVersion     := ::ndocumentVersion
	oClone:niterationSequence   := ::niterationSequence
	oClone:nlevelId             := ::nlevelId
	oClone:nmovementSequence    := ::nmovementSequence
	oClone:cobservation         := ::cobservation
	oClone:lsigned              := ::lsigned
	oClone:nstatus              := ::nstatus
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentApprovementHistoryDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::capprovementDate   :=  WSAdvValue( oResponse,"_APPROVEMENTDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentVersion   :=  WSAdvValue( oResponse,"_DOCUMENTVERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::niterationSequence :=  WSAdvValue( oResponse,"_ITERATIONSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nlevelId           :=  WSAdvValue( oResponse,"_LEVELID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nmovementSequence  :=  WSAdvValue( oResponse,"_MOVEMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cobservation       :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lsigned            :=  WSAdvValue( oResponse,"_SIGNED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nstatus            :=  WSAdvValue( oResponse,"_STATUS","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure documentDto

WSSTRUCT ECMDocumentServiceService_documentDto
	WSDATA   naccessCount              AS int OPTIONAL
	WSDATA   lactiveUserApprover       AS boolean OPTIONAL
	WSDATA   lactiveVersion            AS boolean OPTIONAL
	WSDATA   cadditionalComments       AS string OPTIONAL
	WSDATA   lallowMuiltiCardsPerUser  AS boolean OPTIONAL
	WSDATA   lapprovalAndOr            AS boolean OPTIONAL
	WSDATA   lapproved                 AS boolean OPTIONAL
	WSDATA   capprovedDate             AS dateTime OPTIONAL
	WSDATA   carticleContent           AS string OPTIONAL
	WSDATA   oWSattachments            AS ECMDocumentServiceService_attachment OPTIONAL
	WSDATA   natualizationId           AS int OPTIONAL
	WSDATA   cbackgroundColor          AS string OPTIONAL
	WSDATA   cbackgroundImage          AS string OPTIONAL
	WSDATA   cbannerImage              AS string OPTIONAL
	WSDATA   ccardDescription          AS string OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ncrc                      AS long OPTIONAL
	WSDATA   ccreateDate               AS dateTime OPTIONAL
	WSDATA   ncreateDateInMilliseconds AS long OPTIONAL
	WSDATA   cdatasetName              AS string OPTIONAL
	WSDATA   ldateFormStarted          AS boolean OPTIONAL
	WSDATA   ldeleted                  AS boolean OPTIONAL
	WSDATA   cdocumentDescription      AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cdocumentKeyWord          AS string OPTIONAL
	WSDATA   ndocumentPropertyNumber   AS int OPTIONAL
	WSDATA   ndocumentPropertyVersion  AS int OPTIONAL
	WSDATA   cdocumentType             AS string OPTIONAL
	WSDATA   cdocumentTypeId           AS string OPTIONAL
	WSDATA   ldownloadEnabled          AS boolean OPTIONAL
	WSDATA   ldraft                    AS boolean OPTIONAL
	WSDATA   cexpirationDate           AS dateTime OPTIONAL
	WSDATA   lexpiredForm              AS boolean OPTIONAL
	WSDATA   lexpires                  AS boolean OPTIONAL
	WSDATA   cexternalDocumentId       AS string OPTIONAL
	WSDATA   lfavorite                 AS boolean OPTIONAL
	WSDATA   cfileURL                  AS string OPTIONAL
	WSDATA   nfolderId                 AS int OPTIONAL
	WSDATA   lforAproval               AS boolean OPTIONAL
	WSDATA   niconId                   AS int OPTIONAL
	WSDATA   ciconPath                 AS string OPTIONAL
	WSDATA   limutable                 AS boolean OPTIONAL
	WSDATA   lindexed                  AS boolean OPTIONAL
	WSDATA   linheritSecurity          AS boolean OPTIONAL
	WSDATA   linternalVisualizer       AS boolean OPTIONAL
	WSDATA   lisEncrypted              AS boolean OPTIONAL
	WSDATA   ckeyWord                  AS string OPTIONAL
	WSDATA   clanguageId               AS string OPTIONAL
	WSDATA   clanguageIndicator        AS string OPTIONAL
	WSDATA   clastModifiedDate         AS dateTime OPTIONAL
	WSDATA   clastModifiedTime         AS string OPTIONAL
	WSDATA   nmetaListId               AS int OPTIONAL
	WSDATA   nmetaListRecordId         AS int OPTIONAL
	WSDATA   lnewStructure             AS boolean OPTIONAL
	WSDATA   lonCheckout               AS boolean OPTIONAL
	WSDATA   nparentDocumentId         AS int OPTIONAL
	WSDATA   cpdfRenderEngine          AS string OPTIONAL
	WSDATA   npermissionType           AS int OPTIONAL
	WSDATA   cphisicalFile             AS string OPTIONAL
	WSDATA   nphisicalFileSize         AS float OPTIONAL
	WSDATA   npriority                 AS int OPTIONAL
	WSDATA   cprivateColleagueId       AS string OPTIONAL
	WSDATA   lprivateDocument          AS boolean OPTIONAL
	WSDATA   lprotectedCopy            AS boolean OPTIONAL
	WSDATA   cpublisherId              AS string OPTIONAL
	WSDATA   cpublisherName            AS string OPTIONAL
	WSDATA   crelatedFiles             AS string OPTIONAL
	WSDATA   nrestrictionType          AS int OPTIONAL
	WSDATA   nrowId                    AS int OPTIONAL
	WSDATA   nsearchNumber             AS int OPTIONAL
	WSDATA   nsecurityLevel            AS int OPTIONAL
	WSDATA   csiteCode                 AS string OPTIONAL
	WSDATA   oWSsociableDocumentDto    AS ECMDocumentServiceService_sociableDocumentDto OPTIONAL
	WSDATA   csocialDocument           AS string OPTIONAL
	WSDATA   ltool                     AS boolean OPTIONAL
	WSDATA   ntopicId                  AS int OPTIONAL
	WSDATA   ltranslated               AS boolean OPTIONAL
	WSDATA   cUUID                     AS string OPTIONAL
	WSDATA   lupdateIsoProperties      AS boolean OPTIONAL
	WSDATA   luserAnswerForm           AS boolean OPTIONAL
	WSDATA   luserNotify               AS boolean OPTIONAL
	WSDATA   nuserPermission           AS int OPTIONAL
	WSDATA   cvalidationStartDate      AS dateTime OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cversionDescription       AS string OPTIONAL
	WSDATA   cversionOption            AS string OPTIONAL
	WSDATA   cvisualization            AS string OPTIONAL
	WSDATA   cvolumeId                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentDto
	::oWSattachments       := {} // Array Of  ECMDocumentServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentDto
	Local oClone := ECMDocumentServiceService_documentDto():NEW()
	oClone:naccessCount         := ::naccessCount
	oClone:lactiveUserApprover  := ::lactiveUserApprover
	oClone:lactiveVersion       := ::lactiveVersion
	oClone:cadditionalComments  := ::cadditionalComments
	oClone:lallowMuiltiCardsPerUser := ::lallowMuiltiCardsPerUser
	oClone:lapprovalAndOr       := ::lapprovalAndOr
	oClone:lapproved            := ::lapproved
	oClone:capprovedDate        := ::capprovedDate
	oClone:carticleContent      := ::carticleContent
	oClone:oWSattachments := NIL
	If ::oWSattachments <> NIL 
		oClone:oWSattachments := {}
		aEval( ::oWSattachments , { |x| aadd( oClone:oWSattachments , x:Clone() ) } )
	Endif 
	oClone:natualizationId      := ::natualizationId
	oClone:cbackgroundColor     := ::cbackgroundColor
	oClone:cbackgroundImage     := ::cbackgroundImage
	oClone:cbannerImage         := ::cbannerImage
	oClone:ccardDescription     := ::ccardDescription
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ncompanyId           := ::ncompanyId
	oClone:ncrc                 := ::ncrc
	oClone:ccreateDate          := ::ccreateDate
	oClone:ncreateDateInMilliseconds := ::ncreateDateInMilliseconds
	oClone:cdatasetName         := ::cdatasetName
	oClone:ldateFormStarted     := ::ldateFormStarted
	oClone:ldeleted             := ::ldeleted
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cdocumentKeyWord     := ::cdocumentKeyWord
	oClone:ndocumentPropertyNumber := ::ndocumentPropertyNumber
	oClone:ndocumentPropertyVersion := ::ndocumentPropertyVersion
	oClone:cdocumentType        := ::cdocumentType
	oClone:cdocumentTypeId      := ::cdocumentTypeId
	oClone:ldownloadEnabled     := ::ldownloadEnabled
	oClone:ldraft               := ::ldraft
	oClone:cexpirationDate      := ::cexpirationDate
	oClone:lexpiredForm         := ::lexpiredForm
	oClone:lexpires             := ::lexpires
	oClone:cexternalDocumentId  := ::cexternalDocumentId
	oClone:lfavorite            := ::lfavorite
	oClone:cfileURL             := ::cfileURL
	oClone:nfolderId            := ::nfolderId
	oClone:lforAproval          := ::lforAproval
	oClone:niconId              := ::niconId
	oClone:ciconPath            := ::ciconPath
	oClone:limutable            := ::limutable
	oClone:lindexed             := ::lindexed
	oClone:linheritSecurity     := ::linheritSecurity
	oClone:linternalVisualizer  := ::linternalVisualizer
	oClone:lisEncrypted         := ::lisEncrypted
	oClone:ckeyWord             := ::ckeyWord
	oClone:clanguageId          := ::clanguageId
	oClone:clanguageIndicator   := ::clanguageIndicator
	oClone:clastModifiedDate    := ::clastModifiedDate
	oClone:clastModifiedTime    := ::clastModifiedTime
	oClone:nmetaListId          := ::nmetaListId
	oClone:nmetaListRecordId    := ::nmetaListRecordId
	oClone:lnewStructure        := ::lnewStructure
	oClone:lonCheckout          := ::lonCheckout
	oClone:nparentDocumentId    := ::nparentDocumentId
	oClone:cpdfRenderEngine     := ::cpdfRenderEngine
	oClone:npermissionType      := ::npermissionType
	oClone:cphisicalFile        := ::cphisicalFile
	oClone:nphisicalFileSize    := ::nphisicalFileSize
	oClone:npriority            := ::npriority
	oClone:cprivateColleagueId  := ::cprivateColleagueId
	oClone:lprivateDocument     := ::lprivateDocument
	oClone:lprotectedCopy       := ::lprotectedCopy
	oClone:cpublisherId         := ::cpublisherId
	oClone:cpublisherName       := ::cpublisherName
	oClone:crelatedFiles        := ::crelatedFiles
	oClone:nrestrictionType     := ::nrestrictionType
	oClone:nrowId               := ::nrowId
	oClone:nsearchNumber        := ::nsearchNumber
	oClone:nsecurityLevel       := ::nsecurityLevel
	oClone:csiteCode            := ::csiteCode
	oClone:oWSsociableDocumentDto := IIF(::oWSsociableDocumentDto = NIL , NIL , ::oWSsociableDocumentDto:Clone() )
	oClone:csocialDocument      := ::csocialDocument
	oClone:ltool                := ::ltool
	oClone:ntopicId             := ::ntopicId
	oClone:ltranslated          := ::ltranslated
	oClone:cUUID                := ::cUUID
	oClone:lupdateIsoProperties := ::lupdateIsoProperties
	oClone:luserAnswerForm      := ::luserAnswerForm
	oClone:luserNotify          := ::luserNotify
	oClone:nuserPermission      := ::nuserPermission
	oClone:cvalidationStartDate := ::cvalidationStartDate
	oClone:nversion             := ::nversion
	oClone:cversionDescription  := ::cversionDescription
	oClone:cversionOption       := ::cversionOption
	oClone:cvisualization       := ::cvisualization
	oClone:cvolumeId            := ::cvolumeId
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_documentDto
	Local cSoap := ""
	cSoap += WSSoapValue("accessCount", ::naccessCount, ::naccessCount , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("activeUserApprover", ::lactiveUserApprover, ::lactiveUserApprover , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("activeVersion", ::lactiveVersion, ::lactiveVersion , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("additionalComments", ::cadditionalComments, ::cadditionalComments , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("allowMuiltiCardsPerUser", ::lallowMuiltiCardsPerUser, ::lallowMuiltiCardsPerUser , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("approvalAndOr", ::lapprovalAndOr, ::lapprovalAndOr , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("approved", ::lapproved, ::lapproved , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("approvedDate", ::capprovedDate, ::capprovedDate , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("articleContent", ::carticleContent, ::carticleContent , "string", .F. , .T., 0 , NIL, .F.) 
	aEval( ::oWSattachments , {|x| cSoap := cSoap  +  WSSoapValue("attachments", x , x , "attachment", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("atualizationId", ::natualizationId, ::natualizationId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("backgroundColor", ::cbackgroundColor, ::cbackgroundColor , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("backgroundImage", ::cbackgroundImage, ::cbackgroundImage , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bannerImage", ::cbannerImage, ::cbannerImage , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("cardDescription", ::ccardDescription, ::ccardDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueName", ::ccolleagueName, ::ccolleagueName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("crc", ::ncrc, ::ncrc , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("createDate", ::ccreateDate, ::ccreateDate , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("createDateInMilliseconds", ::ncreateDateInMilliseconds, ::ncreateDateInMilliseconds , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("datasetName", ::cdatasetName, ::cdatasetName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("dateFormStarted", ::ldateFormStarted, ::ldateFormStarted , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("deleted", ::ldeleted, ::ldeleted , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, ::cdocumentDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentKeyWord", ::cdocumentKeyWord, ::cdocumentKeyWord , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentPropertyNumber", ::ndocumentPropertyNumber, ::ndocumentPropertyNumber , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentPropertyVersion", ::ndocumentPropertyVersion, ::ndocumentPropertyVersion , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentType", ::cdocumentType, ::cdocumentType , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentTypeId", ::cdocumentTypeId, ::cdocumentTypeId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("downloadEnabled", ::ldownloadEnabled, ::ldownloadEnabled , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("draft", ::ldraft, ::ldraft , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("expirationDate", ::cexpirationDate, ::cexpirationDate , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("expiredForm", ::lexpiredForm, ::lexpiredForm , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("expires", ::lexpires, ::lexpires , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("externalDocumentId", ::cexternalDocumentId, ::cexternalDocumentId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("favorite", ::lfavorite, ::lfavorite , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fileURL", ::cfileURL, ::cfileURL , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("folderId", ::nfolderId, ::nfolderId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("forAproval", ::lforAproval, ::lforAproval , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("iconId", ::niconId, ::niconId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("iconPath", ::ciconPath, ::ciconPath , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("imutable", ::limutable, ::limutable , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("indexed", ::lindexed, ::lindexed , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("inheritSecurity", ::linheritSecurity, ::linheritSecurity , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("internalVisualizer", ::linternalVisualizer, ::linternalVisualizer , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("isEncrypted", ::lisEncrypted, ::lisEncrypted , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("keyWord", ::ckeyWord, ::ckeyWord , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("languageId", ::clanguageId, ::clanguageId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("languageIndicator", ::clanguageIndicator, ::clanguageIndicator , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("lastModifiedDate", ::clastModifiedDate, ::clastModifiedDate , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("lastModifiedTime", ::clastModifiedTime, ::clastModifiedTime , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("metaListId", ::nmetaListId, ::nmetaListId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("metaListRecordId", ::nmetaListRecordId, ::nmetaListRecordId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("newStructure", ::lnewStructure, ::lnewStructure , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("onCheckout", ::lonCheckout, ::lonCheckout , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, ::nparentDocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("pdfRenderEngine", ::cpdfRenderEngine, ::cpdfRenderEngine , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("permissionType", ::npermissionType, ::npermissionType , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("phisicalFile", ::cphisicalFile, ::cphisicalFile , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("phisicalFileSize", ::nphisicalFileSize, ::nphisicalFileSize , "float", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("priority", ::npriority, ::npriority , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("privateColleagueId", ::cprivateColleagueId, ::cprivateColleagueId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("privateDocument", ::lprivateDocument, ::lprivateDocument , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("protectedCopy", ::lprotectedCopy, ::lprotectedCopy , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("publisherId", ::cpublisherId, ::cpublisherId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("publisherName", ::cpublisherName, ::cpublisherName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("relatedFiles", ::crelatedFiles, ::crelatedFiles , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("restrictionType", ::nrestrictionType, ::nrestrictionType , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("rowId", ::nrowId, ::nrowId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("searchNumber", ::nsearchNumber, ::nsearchNumber , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("securityLevel", ::nsecurityLevel, ::nsecurityLevel , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("siteCode", ::csiteCode, ::csiteCode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("sociableDocumentDto", ::oWSsociableDocumentDto, ::oWSsociableDocumentDto , "sociableDocumentDto", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("socialDocument", ::csocialDocument, ::csocialDocument , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("tool", ::ltool, ::ltool , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("topicId", ::ntopicId, ::ntopicId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("translated", ::ltranslated, ::ltranslated , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UUID", ::cUUID, ::cUUID , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("updateIsoProperties", ::lupdateIsoProperties, ::lupdateIsoProperties , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("userAnswerForm", ::luserAnswerForm, ::luserAnswerForm , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("userNotify", ::luserNotify, ::luserNotify , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("userPermission", ::nuserPermission, ::nuserPermission , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("validationStartDate", ::cvalidationStartDate, ::cvalidationStartDate , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("versionDescription", ::cversionDescription, ::cversionDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("versionOption", ::cversionOption, ::cversionOption , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("visualization", ::cvisualization, ::cvisualization , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("volumeId", ::cvolumeId, ::cvolumeId , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentDto
	Local nRElem10 , nTElem10
	Local aNodes10 := WSRPCGetNode(oResponse,.T.)
	Local oNode75
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::naccessCount       :=  WSAdvValue( oResponse,"_ACCESSCOUNT","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lactiveUserApprover :=  WSAdvValue( oResponse,"_ACTIVEUSERAPPROVER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lactiveVersion     :=  WSAdvValue( oResponse,"_ACTIVEVERSION","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cadditionalComments :=  WSAdvValue( oResponse,"_ADDITIONALCOMMENTS","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lallowMuiltiCardsPerUser :=  WSAdvValue( oResponse,"_ALLOWMUILTICARDSPERUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lapprovalAndOr     :=  WSAdvValue( oResponse,"_APPROVALANDOR","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lapproved          :=  WSAdvValue( oResponse,"_APPROVED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::capprovedDate      :=  WSAdvValue( oResponse,"_APPROVEDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::carticleContent    :=  WSAdvValue( oResponse,"_ARTICLECONTENT","string",NIL,NIL,NIL,"S",NIL,"xs") 
	nTElem10 := len(aNodes10)
	For nRElem10 := 1 to nTElem10 
		If !WSIsNilNode( aNodes10[nRElem10] )
			aadd(::oWSattachments , ECMDocumentServiceService_attachment():New() )
  			::oWSattachments[len(::oWSattachments)]:SoapRecv(aNodes10[nRElem10])
		Endif
	Next
	::natualizationId    :=  WSAdvValue( oResponse,"_ATUALIZATIONID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cbackgroundColor   :=  WSAdvValue( oResponse,"_BACKGROUNDCOLOR","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cbackgroundImage   :=  WSAdvValue( oResponse,"_BACKGROUNDIMAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cbannerImage       :=  WSAdvValue( oResponse,"_BANNERIMAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccardDescription   :=  WSAdvValue( oResponse,"_CARDDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ncrc               :=  WSAdvValue( oResponse,"_CRC","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccreateDate        :=  WSAdvValue( oResponse,"_CREATEDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncreateDateInMilliseconds :=  WSAdvValue( oResponse,"_CREATEDATEINMILLISECONDS","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdatasetName       :=  WSAdvValue( oResponse,"_DATASETNAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ldateFormStarted   :=  WSAdvValue( oResponse,"_DATEFORMSTARTED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldeleted           :=  WSAdvValue( oResponse,"_DELETED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cdocumentDescription :=  WSAdvValue( oResponse,"_DOCUMENTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentKeyWord   :=  WSAdvValue( oResponse,"_DOCUMENTKEYWORD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentPropertyNumber :=  WSAdvValue( oResponse,"_DOCUMENTPROPERTYNUMBER","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentPropertyVersion :=  WSAdvValue( oResponse,"_DOCUMENTPROPERTYVERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentType      :=  WSAdvValue( oResponse,"_DOCUMENTTYPE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdocumentTypeId    :=  WSAdvValue( oResponse,"_DOCUMENTTYPEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ldownloadEnabled   :=  WSAdvValue( oResponse,"_DOWNLOADENABLED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldraft             :=  WSAdvValue( oResponse,"_DRAFT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cexpirationDate    :=  WSAdvValue( oResponse,"_EXPIRATIONDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::lexpiredForm       :=  WSAdvValue( oResponse,"_EXPIREDFORM","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lexpires           :=  WSAdvValue( oResponse,"_EXPIRES","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cexternalDocumentId :=  WSAdvValue( oResponse,"_EXTERNALDOCUMENTID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lfavorite          :=  WSAdvValue( oResponse,"_FAVORITE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cfileURL           :=  WSAdvValue( oResponse,"_FILEURL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nfolderId          :=  WSAdvValue( oResponse,"_FOLDERID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lforAproval        :=  WSAdvValue( oResponse,"_FORAPROVAL","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::niconId            :=  WSAdvValue( oResponse,"_ICONID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ciconPath          :=  WSAdvValue( oResponse,"_ICONPATH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::limutable          :=  WSAdvValue( oResponse,"_IMUTABLE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lindexed           :=  WSAdvValue( oResponse,"_INDEXED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::linheritSecurity   :=  WSAdvValue( oResponse,"_INHERITSECURITY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::linternalVisualizer :=  WSAdvValue( oResponse,"_INTERNALVISUALIZER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lisEncrypted       :=  WSAdvValue( oResponse,"_ISENCRYPTED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ckeyWord           :=  WSAdvValue( oResponse,"_KEYWORD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clanguageId        :=  WSAdvValue( oResponse,"_LANGUAGEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clanguageIndicator :=  WSAdvValue( oResponse,"_LANGUAGEINDICATOR","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clastModifiedDate  :=  WSAdvValue( oResponse,"_LASTMODIFIEDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::clastModifiedTime  :=  WSAdvValue( oResponse,"_LASTMODIFIEDTIME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nmetaListId        :=  WSAdvValue( oResponse,"_METALISTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nmetaListRecordId  :=  WSAdvValue( oResponse,"_METALISTRECORDID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lnewStructure      :=  WSAdvValue( oResponse,"_NEWSTRUCTURE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lonCheckout        :=  WSAdvValue( oResponse,"_ONCHECKOUT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nparentDocumentId  :=  WSAdvValue( oResponse,"_PARENTDOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cpdfRenderEngine   :=  WSAdvValue( oResponse,"_PDFRENDERENGINE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::npermissionType    :=  WSAdvValue( oResponse,"_PERMISSIONTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cphisicalFile      :=  WSAdvValue( oResponse,"_PHISICALFILE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nphisicalFileSize  :=  WSAdvValue( oResponse,"_PHISICALFILESIZE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::npriority          :=  WSAdvValue( oResponse,"_PRIORITY","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cprivateColleagueId :=  WSAdvValue( oResponse,"_PRIVATECOLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lprivateDocument   :=  WSAdvValue( oResponse,"_PRIVATEDOCUMENT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lprotectedCopy     :=  WSAdvValue( oResponse,"_PROTECTEDCOPY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cpublisherId       :=  WSAdvValue( oResponse,"_PUBLISHERID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cpublisherName     :=  WSAdvValue( oResponse,"_PUBLISHERNAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::crelatedFiles      :=  WSAdvValue( oResponse,"_RELATEDFILES","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nrestrictionType   :=  WSAdvValue( oResponse,"_RESTRICTIONTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nrowId             :=  WSAdvValue( oResponse,"_ROWID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nsearchNumber      :=  WSAdvValue( oResponse,"_SEARCHNUMBER","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nsecurityLevel     :=  WSAdvValue( oResponse,"_SECURITYLEVEL","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::csiteCode          :=  WSAdvValue( oResponse,"_SITECODE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode75 :=  WSAdvValue( oResponse,"_SOCIABLEDOCUMENTDTO","sociableDocumentDto",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode75 != NIL
		::oWSsociableDocumentDto := ECMDocumentServiceService_sociableDocumentDto():New()
		::oWSsociableDocumentDto:SoapRecv(oNode75)
	EndIf
	::csocialDocument    :=  WSAdvValue( oResponse,"_SOCIALDOCUMENT","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ltool              :=  WSAdvValue( oResponse,"_TOOL","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ntopicId           :=  WSAdvValue( oResponse,"_TOPICID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ltranslated        :=  WSAdvValue( oResponse,"_TRANSLATED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cUUID              :=  WSAdvValue( oResponse,"_UUID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lupdateIsoProperties :=  WSAdvValue( oResponse,"_UPDATEISOPROPERTIES","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::luserAnswerForm    :=  WSAdvValue( oResponse,"_USERANSWERFORM","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::luserNotify        :=  WSAdvValue( oResponse,"_USERNOTIFY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nuserPermission    :=  WSAdvValue( oResponse,"_USERPERMISSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cvalidationStartDate :=  WSAdvValue( oResponse,"_VALIDATIONSTARTDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cversionDescription :=  WSAdvValue( oResponse,"_VERSIONDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cversionOption     :=  WSAdvValue( oResponse,"_VERSIONOPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cvisualization     :=  WSAdvValue( oResponse,"_VISUALIZATION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cvolumeId          :=  WSAdvValue( oResponse,"_VOLUMEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure approverWithLevelDto

WSSTRUCT ECMDocumentServiceService_approverWithLevelDto
	WSDATA   napproverType             AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nlevelId                  AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approverWithLevelDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approverWithLevelDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approverWithLevelDto
	Local oClone := ECMDocumentServiceService_approverWithLevelDto():NEW()
	oClone:napproverType        := ::napproverType
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nlevelId             := ::nlevelId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approverWithLevelDto
	Local cSoap := ""
	cSoap += WSSoapValue("approverType", ::napproverType, ::napproverType , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("levelId", ::nlevelId, ::nlevelId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_approverWithLevelDto
	Local oNodes5 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::napproverType      :=  WSAdvValue( oResponse,"_APPROVERTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes5 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::nlevelId           :=  WSAdvValue( oResponse,"_LEVELID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure approvalLevelDto

WSSTRUCT ECMDocumentServiceService_approvalLevelDto
	WSDATA   napprovalMode             AS int OPTIONAL
	WSDATA   clevelDescription         AS string OPTIONAL
	WSDATA   nlevelId                  AS int OPTIONAL
	WSDATA   lmandatorySignature       AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approvalLevelDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approvalLevelDto
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approvalLevelDto
	Local oClone := ECMDocumentServiceService_approvalLevelDto():NEW()
	oClone:napprovalMode        := ::napprovalMode
	oClone:clevelDescription    := ::clevelDescription
	oClone:nlevelId             := ::nlevelId
	oClone:lmandatorySignature  := ::lmandatorySignature
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approvalLevelDto
	Local cSoap := ""
	cSoap += WSSoapValue("approvalMode", ::napprovalMode, ::napprovalMode , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("levelDescription", ::clevelDescription, ::clevelDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("levelId", ::nlevelId, ::nlevelId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("mandatorySignature", ::lmandatorySignature, ::lmandatorySignature , "boolean", .F. , .T., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure approverDto

WSSTRUCT ECMDocumentServiceService_approverDto
	WSDATA   napproverType             AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nlevelId                  AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_approverDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_approverDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_approverDto
	Local oClone := ECMDocumentServiceService_approverDto():NEW()
	oClone:napproverType        := ::napproverType
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nlevelId             := ::nlevelId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_approverDto
	Local cSoap := ""
	cSoap += WSSoapValue("approverType", ::napproverType, ::napproverType , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("levelId", ::nlevelId, ::nlevelId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure documentApprovalStatusDto

WSSTRUCT ECMDocumentServiceService_documentApprovalStatusDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   nstatus                   AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_documentApprovalStatusDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_documentApprovalStatusDto
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_documentApprovalStatusDto
	Local oClone := ECMDocumentServiceService_documentApprovalStatusDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:nstatus              := ::nstatus
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_documentApprovalStatusDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nstatus            :=  WSAdvValue( oResponse,"_STATUS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure attachment

WSSTRUCT ECMDocumentServiceService_attachment
	WSDATA   lattach                   AS boolean OPTIONAL
	WSDATA   ldescriptor               AS boolean OPTIONAL
	WSDATA   lediting                  AS boolean OPTIONAL
	WSDATA   cfileName                 AS string OPTIONAL
	WSDATA   oWSfileSelected           AS ECMDocumentServiceService_attachment OPTIONAL
	WSDATA   nfileSize                 AS long OPTIONAL
	WSDATA   cfilecontent              AS base64Binary OPTIONAL
	WSDATA   cfullPatch                AS string OPTIONAL
	WSDATA   ciconPath                 AS string OPTIONAL
	WSDATA   lmobile                   AS boolean OPTIONAL
	WSDATA   cpathName                 AS string OPTIONAL
	WSDATA   lprincipal                AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_attachment
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_attachment
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_attachment
	Local oClone := ECMDocumentServiceService_attachment():NEW()
	oClone:lattach              := ::lattach
	oClone:ldescriptor          := ::ldescriptor
	oClone:lediting             := ::lediting
	oClone:cfileName            := ::cfileName
	oClone:oWSfileSelected      := IIF(::oWSfileSelected = NIL , NIL , ::oWSfileSelected:Clone() )
	oClone:nfileSize            := ::nfileSize
	oClone:cfilecontent         := ::cfilecontent
	oClone:cfullPatch           := ::cfullPatch
	oClone:ciconPath            := ::ciconPath
	oClone:lmobile              := ::lmobile
	oClone:cpathName            := ::cpathName
	oClone:lprincipal           := ::lprincipal
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_attachment
	Local cSoap := ""
	cSoap += WSSoapValue("attach", ::lattach, ::lattach , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("descriptor", ::ldescriptor, ::ldescriptor , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("editing", ::lediting, ::lediting , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fileName", ::cfileName, ::cfileName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fileSelected", ::oWSfileSelected, ::oWSfileSelected , "attachment", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fileSize", ::nfileSize, ::nfileSize , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("filecontent", ::cfilecontent, ::cfilecontent , "base64Binary", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fullPatch", ::cfullPatch, ::cfullPatch , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("iconPath", ::ciconPath, ::ciconPath , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("mobile", ::lmobile, ::lmobile , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("pathName", ::cpathName, ::cpathName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("principal", ::lprincipal, ::lprincipal , "boolean", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_attachment
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lattach            :=  WSAdvValue( oResponse,"_ATTACH","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldescriptor        :=  WSAdvValue( oResponse,"_DESCRIPTOR","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lediting           :=  WSAdvValue( oResponse,"_EDITING","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cfileName          :=  WSAdvValue( oResponse,"_FILENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode5 :=  WSAdvValue( oResponse,"_FILESELECTED","attachment",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode5 != NIL
		::oWSfileSelected := ECMDocumentServiceService_attachment():New()
		::oWSfileSelected:SoapRecv(oNode5)
	EndIf
	::nfileSize          :=  WSAdvValue( oResponse,"_FILESIZE","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cfilecontent       :=  WSAdvValue( oResponse,"_FILECONTENT","base64Binary",NIL,NIL,NIL,"SB",NIL,"xs") 
	::cfullPatch         :=  WSAdvValue( oResponse,"_FULLPATCH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ciconPath          :=  WSAdvValue( oResponse,"_ICONPATH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lmobile            :=  WSAdvValue( oResponse,"_MOBILE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cpathName          :=  WSAdvValue( oResponse,"_PATHNAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lprincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
Return

// WSDL Data Structure sociableDocumentDto

WSSTRUCT ECMDocumentServiceService_sociableDocumentDto
	WSDATA   lcommented                AS boolean OPTIONAL
	WSDATA   ldenounced                AS boolean OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   lfollowing                AS boolean OPTIONAL
	WSDATA   lliked                    AS boolean OPTIONAL
	WSDATA   nnumberComments           AS int OPTIONAL
	WSDATA   nnumberDenouncements      AS int OPTIONAL
	WSDATA   nnumberFollows            AS int OPTIONAL
	WSDATA   nnumberLikes              AS int OPTIONAL
	WSDATA   nnumberShares             AS int OPTIONAL
	WSDATA   lshared                   AS boolean OPTIONAL
	WSDATA   nsociableId               AS long OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMDocumentServiceService_sociableDocumentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMDocumentServiceService_sociableDocumentDto
Return

WSMETHOD CLONE WSCLIENT ECMDocumentServiceService_sociableDocumentDto
	Local oClone := ECMDocumentServiceService_sociableDocumentDto():NEW()
	oClone:lcommented           := ::lcommented
	oClone:ldenounced           := ::ldenounced
	oClone:ndocumentId          := ::ndocumentId
	oClone:lfollowing           := ::lfollowing
	oClone:lliked               := ::lliked
	oClone:nnumberComments      := ::nnumberComments
	oClone:nnumberDenouncements := ::nnumberDenouncements
	oClone:nnumberFollows       := ::nnumberFollows
	oClone:nnumberLikes         := ::nnumberLikes
	oClone:nnumberShares        := ::nnumberShares
	oClone:lshared              := ::lshared
	oClone:nsociableId          := ::nsociableId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMDocumentServiceService_sociableDocumentDto
	Local cSoap := ""
	cSoap += WSSoapValue("commented", ::lcommented, ::lcommented , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("denounced", ::ldenounced, ::ldenounced , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("following", ::lfollowing, ::lfollowing , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("liked", ::lliked, ::lliked , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numberComments", ::nnumberComments, ::nnumberComments , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numberDenouncements", ::nnumberDenouncements, ::nnumberDenouncements , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numberFollows", ::nnumberFollows, ::nnumberFollows , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numberLikes", ::nnumberLikes, ::nnumberLikes , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("numberShares", ::nnumberShares, ::nnumberShares , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("shared", ::lshared, ::lshared , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("sociableId", ::nsociableId, ::nsociableId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMDocumentServiceService_sociableDocumentDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lcommented         :=  WSAdvValue( oResponse,"_COMMENTED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldenounced         :=  WSAdvValue( oResponse,"_DENOUNCED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lfollowing         :=  WSAdvValue( oResponse,"_FOLLOWING","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lliked             :=  WSAdvValue( oResponse,"_LIKED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nnumberComments    :=  WSAdvValue( oResponse,"_NUMBERCOMMENTS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nnumberDenouncements :=  WSAdvValue( oResponse,"_NUMBERDENOUNCEMENTS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nnumberFollows     :=  WSAdvValue( oResponse,"_NUMBERFOLLOWS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nnumberLikes       :=  WSAdvValue( oResponse,"_NUMBERLIKES","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nnumberShares      :=  WSAdvValue( oResponse,"_NUMBERSHARES","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lshared            :=  WSAdvValue( oResponse,"_SHARED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsociableId        :=  WSAdvValue( oResponse,"_SOCIABLEID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return