#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscProdFor
	WSDATA Status      As String
	WSDATA Codigo      As String
	WSDATA Loja        As String  
	WSDATA Produto     As String  
ENDWSSTRUCT

WsService Mobile_ProdFor_PD Description "LOGOS Mobile Consulta produtos x fornecedores do ERP"
                                               
   WsData Codigo  As String
   WsData Loja    As String
   WsData Retorno As Array of DiscProdFor
   
   WsMethod ConsultaProdFor Description "LOGOS Mobile Retorna conteúdo da SA5 para o mobile"

EndWsService

WsMethod ConsultaProdFor WsReceive Codigo, Loja WsSend Retorno WsService Mobile_ProdFor_PD

Local nX       := 0
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação produto x fornecedor.")

cQuery := "SELECT A5_FORNECE, A5_LOJA, A5_PRODUTO FROM " + RetSQLName("SA5")
cQuery += " WHERE "
cQuery += "A5_FILIAL = '" + xFilial("SA5") + "' AND "
cQuery += "A5_FORNECE = '" + Codigo + "' AND "
cQuery += "A5_LOJA = '" + Loja + "' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA5QRY", .F., .F.)

ConOut("Mobile Logos - Carregando produto x fornecedor.")
If !SA5QRY->(EOF())
	While !SA5QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("DiscProdFor"))
		::Retorno[nX]:Status      := "1"
		::Retorno[nX]:Codigo      := SA5QRY->A5_FORNECE
		::Retorno[nX]:Loja        := SA5QRY->A5_LOJA
		::Retorno[nX]:Produto     := SA5QRY->A5_PRODUTO
		SA5QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("DiscProdFor"))
	::Retorno[nX]:Status      := "0"
	::Retorno[nX]:Codigo      := ""
	::Retorno[nX]:Loja        := ""
	::Retorno[nX]:Produto     := ""
EndIf
SA5QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de produtos x fornecedores finalizado.")

Return(.T.)