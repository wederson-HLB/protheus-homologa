#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT CondPag
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_CondPag Description "LOGOS Mobile Consulta condição de pagamento do ERP"

   WsData Vendedor As String
   WsData Retorno  As Array of CondPag
   
   WsMethod ConsultaCondPag Description "LOGOS Mobile Retorna conteúdo da SE4 para o mobile"

EndWsService

WsMethod ConsultaCondPag WsReceive Vendedor WsSend Retorno WsService Mobile_CondPag

Local nX       := 0     
Local nPos     := 0     
Local aCond    := {}
Local cCond    := ""
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de Cond.Pagtos.")

cQuery := "SELECT A1_COND FROM " + RetSQLName("SA1")
cQuery += " WHERE "
cQuery += "A1_FILIAL = '" + xFilial("SA1") + "' AND "
cQuery += "A1_VEND = '" + Vendedor + "' AND "
cQuery += "A1_MSBLQL <> '1' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA1QRY", .F., .T.)

While !SA1QRY->(EOF())
	nPos := Ascan(aCond, {|x| x == SA1QRY->A1_COND})
	If nPos == 0
		aAdd(aCond, SA1QRY->A1_COND)
	EndIf
	SA1QRY->(dbSkip())
End
SA1QRY->(dbCloseArea())

For nX := 1 to Len(aCond)
	cCond += "'" + aCond[nX] + "',"
Next nX
cCond := SubStr(cCond, 1, Len(cCond)-1)

cQuery := "SELECT E4_CODIGO, E4_DESCRI FROM " + RetSQLName("SE4")
cQuery += " WHERE "
cQuery += "E4_CODIGO IN('" + cCond + "') AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SE4QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando condições de pagamento.")
nX := 0

If !SE4QRY->(EOF())
	While !SE4QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("CondPag"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := SE4QRY->E4_CODIGO
		::Retorno[nX]:Descricao := SE4QRY->E4_DESCRI
		SE4QRY->(dbSkip())
	End
Else
		nX++
		aAdd(::Retorno, WSClassNew("CondPag"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:Codigo    := ""
		::Retorno[nX]:Descricao := ""
EndIf           
nX++
aAdd(::Retorno, WSClassNew("CondPag"))
::Retorno[nX]:Status    := "1"
::Retorno[nX]:Codigo    := "***"
::Retorno[nX]:Descricao := "PROMOCIONAL"
SE4QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Condições de pagamento finalizado.")
          
Return(.T.)