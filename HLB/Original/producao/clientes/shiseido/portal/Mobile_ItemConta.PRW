#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT ItemConta
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_ItemConta Description "Mobile Logos - Carrega ItemConta do ERP para o mobile."

   WsData Retorno As Array of ItemConta
   
   WsMethod ConsultaItemConta Description "Mobile Logos - Carrega ItemConta do ERP para o mobile."

EndWsService

WsMethod ConsultaItemConta WsReceive NullParam WsSend Retorno WsService Mobile_ItemConta

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de ItemConta.")
cQuery := "SELECT CTD_ITEM, CTD_DESC01 FROM " + RetSQLName("CTD")
cQuery += " WHERE "
cQuery += "CTD_FILIAL = '" + xFilial("CTD") + "' AND "
cQuery += "CTD_CLASSE = '2' AND "
cQuery += "CTD_BLOQ = '2' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "CTDQRY", .F., .T.)  

ConOut("Mobile Logos - Carregando ItemConta.")
nX := 0
If !CTDQRY->(EOF())
	While !CTDQRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("ItemConta"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := CTDQRY->CTD_ITEM
		::Retorno[nX]:Descricao := CTDQRY->CTD_DESC01
		CTDQRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("ItemConta"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:Codigo    := ""
		::Retorno[nX]:Descricao := ""
EndIf
CTDQRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de ItemConta finalizado.")

Return(.T.)