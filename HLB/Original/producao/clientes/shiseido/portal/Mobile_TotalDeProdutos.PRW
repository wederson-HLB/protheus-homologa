#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WsService Mobile_TotalProdutos Description "Mobile Logos - Total de Produtos do ERP para o mobile."

   WsData TotalProdutos As Float

   WsMethod RetornaTotal Description "Mobile Logos - Total de Produtos do ERP para o mobile."

EndWsService

WsMethod RetornaTotal WsReceive NullParam WsSend TotalProdutos WsService Mobile_TotalProdutos

Local nX       := 0     
Local cQuery   := "" 

cQuery := "SELECT Count(*) AS Total FROM " + RetSQLName("SB1") + " SB1 "
cQuery += " WHERE "
cQuery += "B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery += "B1_TIPO IN ('MC','PP','ME') AND "
cQuery += "SB1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SB1QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando Total produtos.")
nX := 0

If !SB1QRY->(EOF())
	::TotalProdutos := SB1QRY->TOTAL
Else
	::TotalProdutos := 0
EndIf
SB1QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Total de Produtos finalizado.")
           
Return(.T.)