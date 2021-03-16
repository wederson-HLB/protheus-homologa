#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT CC
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_CC Description "Mobile Logos - Carrega CC do ERP para o mobile."

   WsData Retorno As Array of CC
   
   WsMethod ConsultaCC Description "Mobile Logos - Carrega CC do ERP para o mobile."

EndWsService

WsMethod ConsultaCC WsReceive NullParam WsSend Retorno WsService Mobile_CC

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de CC.")
cQuery := "SELECT CTT_CUSTO, CTT_DESC01 FROM " + RetSQLName("CTT")
cQuery += " WHERE "
cQuery += "CTT_FILIAL = '" + xFilial("CTT") + "' AND "
cQuery += "CTT_CLASSE = '2' AND "
cQuery += "CTT_BLOQ = '2' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "CTTQRY", .F., .T.)  

ConOut("Mobile Logos - Carregando CC.")
nX := 0
If !CTTQRY->(EOF())
	While !CTTQRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("CC"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := CTTQRY->CTT_CUSTO
		::Retorno[nX]:Descricao := CTTQRY->CTT_DESC01
		CTTQRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("CC"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:Codigo    := ""
		::Retorno[nX]:Descricao := ""
EndIf
CTTQRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de CC finalizado.")

Return(.T.)