#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscProdutos
	WSDATA Status      As String
	WSDATA Codigo      As String  
	WSDATA Descricao   As String
	WSDATA UM          As String                    
	WSDATA SegUM       As String                    
	WSDATA Grupo       As String       
	WSDATA Conta       As String
	WSDATA NCM	   As String
ENDWSSTRUCT

WsService Mobile_Produtos_PD Description "Mobile Logos - Carrega produtos do ERP para o mobile."

   WsData Retorno As Array of DiscProdutos
   
   WsMethod ConsultaProdutos Description "Mobile Logos - Carrega produtos do ERP para o mobile."

EndWsService

WsMethod ConsultaProdutos WsReceive NULLPARAM WsSend Retorno WsService Mobile_Produtos_PD

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 
Local cTabela  := ""
Local aTabela  := {}

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de produtos.")

cQuery := "SELECT DISTINCT B1_COD, B1_DESC, B1_UM, B1_SEGUM, B1_GRUPO, B1_CONTA, B1_POSIPI FROM " + RetSQLName("SB1") + " SB1 "
cQuery += " WHERE "
cQuery += "B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery += "B1_MSBLQL <> '1' AND "
cQuery += "SB1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SB1QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando produtos.")
nX := 0

If !SB1QRY->(EOF())
	While !SB1QRY->(EOF())
		nX++
		conout("Produto: " + SB1QRY->B1_COD + "-" + SB1QRY->B1_DESC)
		aAdd(::Retorno, WSClassNew("DiscProdutos"))
		::Retorno[nX]:Status     := "1"
		::Retorno[nX]:Codigo     := SB1QRY->B1_COD
		::Retorno[nX]:Descricao  := SB1QRY->B1_DESC
		::Retorno[nX]:UM	 := SB1QRY->B1_UM
		::Retorno[nX]:SegUM	 := SB1QRY->B1_SEGUM
		::Retorno[nX]:Grupo      := SB1QRY->B1_GRUPO
		::Retorno[nX]:Conta      := SB1QRY->B1_CONTA
		::Retorno[nX]:NCM        := SB1QRY->B1_POSIPI
		SB1QRY->(dbSkip())
	End
Else
	nX++
	conout("Produto: ")
	aAdd(::Retorno, WSClassNew("DiscProdutos"))
	::Retorno[nX]:Status     := "0"
	::Retorno[nX]:Codigo     := ""
	::Retorno[nX]:Descricao  := ""
	::Retorno[nX]:UM	 := ""
	::Retorno[nX]:SegUM	 := ""
	::Retorno[nX]:Grupo      := ""
	::Retorno[nX]:Conta      := ""
	::Retorno[nX]:NCM	 := ""
EndIf
SB1QRY->(dbCloseArea())

ConOut("Mobile Logos - WebService de Cadastro de Produtos finalizado.")
           
Return(.T.)