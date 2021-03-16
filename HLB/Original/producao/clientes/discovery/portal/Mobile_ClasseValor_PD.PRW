#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscClasses
	WSDATA Status      As String
	WSDATA Codigo      As String  
	WSDATA Descricao   As String
ENDWSSTRUCT

WsService Mobile_ClasseValor_PD Description "Mobile Logos - Carrega Classes de Valor do ERP para o mobile."

   WsData Retorno As Array of DiscClasses
   
   WsMethod ConsultaClasses Description "Mobile Logos - Carrega Classes de Valor do ERP para o mobile."

EndWsService

WsMethod ConsultaClasses WsReceive NULLPARAM WsSend Retorno WsService Mobile_ClasseValor_PD

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 
Local cTabela  := ""
Local aTabela  := {}

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de classes de valor.")

cQuery := "SELECT DISTINCT CTH_CLVL, CTH_DESC01 FROM " + RetSQLName("CTH") + " CTH "
cQuery += " WHERE "
cQuery += "CTH_FILIAL = '" + xFilial("CTH") + "' AND "
cQuery += "CTH_CLASSE = '2' AND "
cQuery += "CTH_BLOQ <> '1' AND "
cQuery += "CTH.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "CTHQRY", .F., .F.)  

ConOut("Mobile Logos - Carregando Classes.")
nX := 0

If !CTHQRY->(EOF())
	While !CTHQRY->(EOF())
		nX++
		conout("Classe: " + CTHQRY->CTH_CLVL + "-" + CTHQRY->CTH_DESC01)
		aAdd(::Retorno, WSClassNew("DiscClasses"))
		::Retorno[nX]:Status     := "1"
		::Retorno[nX]:Codigo     := CTHQRY->CTH_CLVL
		::Retorno[nX]:Descricao  := CTHQRY->CTH_DESC01
		CTHQRY->(dbSkip())
	End
Else
	nX++
	conout("Classe: ")
	aAdd(::Retorno, WSClassNew("DiscClasses"))
	::Retorno[nX]:Status     := "0"
	::Retorno[nX]:Codigo     := ""
	::Retorno[nX]:Descricao  := ""
EndIf
CTHQRY->(dbCloseArea())

ConOut("Mobile Logos - WebService de Cadastro de Classes de Valor finalizado.")
           
Return(.T.)