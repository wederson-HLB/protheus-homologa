#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscItemContas
	WSDATA Status      As String
	WSDATA Codigo      As String  
	WSDATA Descricao   As String
ENDWSSTRUCT

WsService Mobile_ItensContabeis_PD Description "Mobile Logos - Carrega Itens Contabeis do ERP para o mobile."

   WsData Retorno As Array of DiscItemContas
   
   WsMethod ConsultaItens Description "Mobile Logos - Carrega Itens Contabeis do ERP para o mobile."

EndWsService

WsMethod ConsultaItens WsReceive NULLPARAM WsSend Retorno WsService Mobile_ItensContabeis_PD

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 
Local cTabela  := ""
Local aTabela  := {}

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de itens contabeis.")

cQuery := "SELECT DISTINCT CTD_ITEM, CTD_DESC01 FROM " + RetSQLName("CTD") + " CTD "
cQuery += " WHERE "
cQuery += "CTD_FILIAL = '" + xFilial("CTD") + "' AND "
cQuery += "CTD_CLASSE = '2' AND "
cQuery += "CTD_BLOQ <> '1' AND "
cQuery += "CTD.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "CTDQRY", .F., .F.)  

ConOut("Mobile Logos - Carregando Itens.")
nX := 0

If !CTDQRY->(EOF())
	While !CTDQRY->(EOF())
		nX++
		conout("Item: " + CTDQRY->CTD_ITEM + "-" + CTDQRY->CTD_DESC01)
		aAdd(::Retorno, WSClassNew("DiscItemContas"))
		::Retorno[nX]:Status     := "1"
		::Retorno[nX]:Codigo     := CTDQRY->CTD_ITEM
		::Retorno[nX]:Descricao  := CTDQRY->CTD_DESC01
		CTDQRY->(dbSkip())
	End
Else
	nX++
	conout("Item: ")
	aAdd(::Retorno, WSClassNew("DiscItemContas"))
	::Retorno[nX]:Status     := "0"
	::Retorno[nX]:Codigo     := ""
	::Retorno[nX]:Descricao  := ""
EndIf
CTDQRY->(dbCloseArea())

ConOut("Mobile Logos - WebService de Cadastro de Contas Contabeis finalizado.")
           
Return(.T.)