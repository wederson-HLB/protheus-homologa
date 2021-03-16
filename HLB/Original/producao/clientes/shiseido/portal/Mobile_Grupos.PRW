#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Grupos
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_Grupos Description "Mobile Logos - Carrega grupos de produtos do ERP para o mobile."

   WsData Retorno As Array of Grupos
   
   WsMethod ConsultaGrupos Description "Mobile Logos - Carrega grupos de produtos do ERP para o mobile."

EndWsService

WsMethod ConsultaGrupos WsReceive NullParam WsSend Retorno WsService Mobile_Grupos

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de produtos.")

cQuery := "SELECT BM_GRUPO, BM_DESC FROM " + RetSQLName("SBM")
cQuery += " WHERE "
cQuery += "BM_FILIAL = '" + xFilial("SBM") + "' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SBMQRY", .F., .T.)  

ConOut("Mobile Logos - Carregando produtos.")
nX := 0
If !SBMQRY->(EOF())
	While !SBMQRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("Grupos"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := SBMQRY->BM_GRUPO
		::Retorno[nX]:Descricao := SBMQRY->BM_DESC
		SBMQRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("Grupos"))
	::Retorno[nX]:Status    := "0"
	::Retorno[nX]:Codigo    := ""
	::Retorno[nX]:Descricao := ""
EndIf
SBMQRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de Produtos finalizado.")

Return(.T.)