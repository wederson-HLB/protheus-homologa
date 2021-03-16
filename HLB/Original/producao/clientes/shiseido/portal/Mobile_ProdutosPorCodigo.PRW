#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT ProdutoCod
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String                    
	WSDATA DescIng   As String                    
	WSDATA UM        As String                    
	WSDATA SegUM     As String                    
	WSDATA Grupo     As String
	WSDATA FatConv   As Float
	WSDATA TipoConv  As String
ENDWSSTRUCT

WsService Mobile_ProdutosPorCodigo Description "Mobile Logos - Carrega produto do ERP para o mobile."

   WsData Codigo As String

   WsData Retorno As Array of ProdutoCod
   
   WsMethod RetornaProduto Description "Mobile Logos - Carrega produto do ERP para o mobile."

EndWsService

WsMethod RetornaProduto WsReceive Codigo WsSend Retorno WsService Mobile_ProdutosPorCodigo

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 

::Retorno := {}

cQuery := "SELECT B1_COD, B1_DESC, B1_DESCING, B1_UM, B1_SEGUM, B1_GRUPO, B1_CONV, B1_TIPCONV FROM " + RetSQLName("SB1") + " SB1 "
cQuery += " WHERE "
cQuery += "B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery += "B1_COD = '" + Codigo + "' AND "
cQuery += "SB1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SB1QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando produtos.")
nX := 0

If !SB1QRY->(EOF())
	While !SB1QRY->(EOF())
		nX++
		conout("Produto: " + SB1QRY->B1_COD + "-" + SB1QRY->B1_DESC)
		aAdd(::Retorno, WSClassNew("ProdutoCod"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := SB1QRY->B1_COD
		::Retorno[nX]:Descricao := SB1QRY->B1_DESC
		::Retorno[nX]:DescIng   := SB1QRY->B1_DESCING
		::Retorno[nX]:UM	    := SB1QRY->B1_UM
		::Retorno[nX]:SegUM	    := SB1QRY->B1_SEGUM
		::Retorno[nX]:Grupo     := SB1QRY->B1_GRUPO
		::Retorno[nX]:FatConv   := SB1QRY->B1_CONV
		::Retorno[nX]:TipoConv  := SB1QRY->B1_TIPCONV
		SB1QRY->(dbSkip())
	End
Else
	nX++
	conout("Produto: ")
	aAdd(::Retorno, WSClassNew("ProdutoCod"))
	::Retorno[nX]:Status    := "0"
	::Retorno[nX]:Codigo    := ""
	::Retorno[nX]:Descricao := ""
	::Retorno[nX]:DescIng   := ""
	::Retorno[nX]:UM	    := ""
	::Retorno[nX]:SegUM	    := ""
	::Retorno[nX]:Grupo     := ""
	::Retorno[nX]:FatConv   := 0
	::Retorno[nX]:TipoConv  := ""
EndIf
SB1QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de Produtos finalizado.")
           
Return(.T.)