#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Produtos
	WSDATA Status      As String
	WSDATA Codigo      As String
	WSDATA UM          As String                    
	WSDATA SegUM       As String                    
	WSDATA Grupo       As String
	WSDATA FatConv     As Float
	WSDATA TipoConv    As String
	WSDATA PrazoPromo  As Integer
ENDWSSTRUCT

WsService Mobile_Produtos Description "Mobile Logos - Carrega produtos do ERP para o mobile."

   WsData Vendedor As String

   WsData Retorno As Array of Produtos
   
   WsMethod ConsultaProdutos Description "Mobile Logos - Carrega produtos do ERP para o mobile."

EndWsService

WsMethod ConsultaProdutos WsReceive Vendedor WsSend Retorno WsService Mobile_Produtos

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 
Local cTabela  := ""
Local aTabela  := {}

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de produtos.")

cQuery := "SELECT A1_TABELA FROM " + RetSQLName("SA1")
cQuery += " WHERE "
cQuery += "A1_FILIAL = '" + xFilial("SA1") + "' AND "
cQuery += "A1_VEND = '" + Vendedor + "' AND "
cQuery += "A1_MSBLQL <> '1' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA1QRY", .F., .T.)

aAdd(aTabela, "007")
While !SA1QRY->(EOF())
	nPos := Ascan(aTabela, {|x| x == SA1QRY->A1_TABELA})
	If nPos == 0
		aAdd(aTabela, SA1QRY->A1_TABELA)
	EndIf
	SA1QRY->(dbSkip())
End
SA1QRY->(dbCloseArea())

For nX := 1 to Len(aTabela)
	cTabela += "'" + aTabela[nX] + "',"
Next nX
cTabela := SubStr(cTabela, 1, Len(cTabela)-1)

cQuery := "SELECT DISTINCT DA1_CODPRO, B1_DESC, B1_DESCING, B1_UM, B1_SEGUM, B1_GRUPO, B1_CONV, B1_TIPCONV, B1_P_PRPRO FROM " + RetSQLName("DA1") + " DA1 "
cQuery += "INNER JOIN " + RetSQLName("DA0") + " DA0 ON DA0_CODTAB = DA1_CODTAB "
cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON B1_COD = DA1_CODPRO "
cQuery += " WHERE "
cQuery += "DA1_FILIAL = '" + xFilial("DA1") + "' AND "
cQuery += "DA0_FILIAL = '" + xFilial("DA0") + "' AND "
cQuery += "B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery += "B1_MSBLQL <> '1' AND "
cQuery += "DA1_CODTAB IN (" + cTabela + ") AND "
cQuery += "DA1.D_E_L_E_T_ = '' AND "
cQuery += "DA0.D_E_L_E_T_ = '' AND "
cQuery += "SB1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DA1QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando produtos.")
nX := 0

If !DA1QRY->(EOF())
	While !DA1QRY->(EOF())
		nX++
		conout("Produto: " + DA1QRY->DA1_CODPRO + "-" + DA1QRY->B1_DESC)
		aAdd(::Retorno, WSClassNew("Produtos"))
		::Retorno[nX]:Status     := "1"
		::Retorno[nX]:Codigo     := DA1QRY->DA1_CODPRO
		::Retorno[nX]:UM	     := DA1QRY->B1_UM
		::Retorno[nX]:SegUM	     := DA1QRY->B1_SEGUM
		::Retorno[nX]:Grupo      := DA1QRY->B1_GRUPO
		::Retorno[nX]:FatConv    := DA1QRY->B1_CONV
		::Retorno[nX]:TipoConv   := DA1QRY->B1_TIPCONV
		::Retorno[nX]:PrazoPromo := DA1QRY->B1_P_PRPRO
		DA1QRY->(dbSkip())
	End
Else
	nX++
	conout("Produto: ")
	aAdd(::Retorno, WSClassNew("Produtos"))
	::Retorno[nX]:Status     := "0"
	::Retorno[nX]:Codigo     := ""
	::Retorno[nX]:UM	     := ""
	::Retorno[nX]:SegUM	     := ""
	::Retorno[nX]:Grupo      := ""
	::Retorno[nX]:FatConv    := ""
	::Retorno[nX]:TipoConv   := ""
	::Retorno[nX]:PrazoPromo := 0
EndIf
DA1QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de Produtos finalizado.")
           
Return(.T.)