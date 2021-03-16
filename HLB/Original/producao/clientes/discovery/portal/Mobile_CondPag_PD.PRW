#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscCondPag
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_CondPag_PD Description "LOGOS Mobile Consulta condição de pagamento do ERP"

   WsData Retorno  As Array of DiscCondPag
   
   WsMethod ConsultaCondPag Description "LOGOS Mobile Retorna conteúdo da SE4 para o mobile"

EndWsService

WsMethod ConsultaCondPag WsReceive NULLPARAM WsSend Retorno WsService Mobile_CondPag_PD

Local nX       := 0     
Local nPos     := 0     
Local aCond    := {}
Local cCond    := ""
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de Cond.Pagtos.")

cQuery := "SELECT E4_CODIGO, E4_DESCRI FROM " + RetSQLName("SE4")
cQuery += " WHERE "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SE4QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando condições de pagamento.")
nX := 0

If !SE4QRY->(EOF())
	While !SE4QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("DiscCondPag"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := SE4QRY->E4_CODIGO
		::Retorno[nX]:Descricao := SE4QRY->E4_DESCRI
		SE4QRY->(dbSkip())
	End
Else
		nX++
		aAdd(::Retorno, WSClassNew("DiscCondPag"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:Codigo    := ""
		::Retorno[nX]:Descricao := ""
EndIf           
SE4QRY->(dbCloseArea())

ConOut("Mobile Logos - WebService de Condições de pagamento finalizado.")
          
Return(.T.)