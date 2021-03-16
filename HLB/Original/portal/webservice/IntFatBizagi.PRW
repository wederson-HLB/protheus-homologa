#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'

*----------------------------------------------------------------------------------------------------*
WsService IntFatBizagi Description "Realiza a integração com o Bizagi para o processo de faturamento."
*----------------------------------------------------------------------------------------------------*
WsData cCodigo as String
WsData cEmp    as String
WsData cFil    as String
WsData cStatus as String
WsData cRet    as String

WsMethod AtuStatus Description "Atualiza o status da solicitação"

EndWsService

*------------------------------------------------------------------------------------------*
WsMethod AtuStatus WsReceive cCodigo, cEmp, cFil, cStatus WsSend cRet WsService IntFatBizagi
*------------------------------------------------------------------------------------------*
 RpcClearEnv()
 RpcSetType( 3 )

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

ZF0->(DbSetOrder(1))
If ZF0->(DbSeek(xFilial("ZF0")+AvKey(cEmp,"ZF0_CODEMP")+AvKey(cFil,"ZF0_CODFIL")+AvKey(cCodigo,"ZF0_CODIGO")))
	
	ZF0->(RecLock("ZF0",.F.))
	ZF0->ZF0_STATUS := cStatus
	ZF0->(MsUnlock())

	::cRet := cStatus
	
EndIf

Return .T.
