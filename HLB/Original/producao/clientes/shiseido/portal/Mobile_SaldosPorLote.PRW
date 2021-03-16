#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT SaldoLote
	WSDATA Status    As String
	WSDATA Produto   As String
	WSDATA Lote	     As String
	WSDATA Local     As String
	WSDATA DtValid   As String
	WSDATA Saldo     As Float
ENDWSSTRUCT

WsService Mobile_SaldosPorLote Description "Mobile Logos - Carrega Saldos por Lote do ERP para o mobile."
                 
   WsData Retorno As Array of SaldoLote
   
   WsMethod ConsultaSaldoLote Description "Mobile Logos - Carrega Saldos por Lote do ERP para o mobile."

EndWsService

WsMethod ConsultaSaldoLote WsReceive NullParam WsSend Retorno WsService Mobile_SaldosPorLote

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação dos Saldos por Lote.")
cQuery := "SELECT B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL FROM " + RetSQLName("SB8") + " SB8 "
cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON B1_COD = B8_PRODUTO "
cQuery += " WHERE "
cQuery += "B8_FILIAL = '" + xFilial("SB8") + "' AND "
cQuery += "B8_LOCAL IN ('04','10','15','16') AND "              
cQuery += "B8_SALDO > '0' AND "              
cQuery += "B1_MSBLQL <> '1' AND "              
cQuery += "SB8.D_E_L_E_T_ = '' AND "
cQuery += "SB1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SB8QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando Saldos por Lote.")
nX := 0
If !SB8QRY->(EOF())
	While !SB8QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("SaldoLote"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Produto   := SB8QRY->B8_PRODUTO
		::Retorno[nX]:Local     := SB8QRY->B8_LOCAL
		::Retorno[nX]:Lote      := SB8QRY->B8_LOTECTL
		::Retorno[nX]:DtValid   := SB8QRY->B8_DTVALID
		::Retorno[nX]:Saldo     := SB8QRY->B8_SALDO
		SB8QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("SaldoLote"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:Produto   := ""
		::Retorno[nX]:Local     := ""
		::Retorno[nX]:Lote      := ""
		::Retorno[nX]:DtValid   := ""
		::Retorno[nX]:Saldo     := 0
EndIf
SB8QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Saldos por Lote finalizado.")

Return(.T.)