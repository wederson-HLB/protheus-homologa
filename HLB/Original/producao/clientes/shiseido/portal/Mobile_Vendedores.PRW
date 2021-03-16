#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Vendedores
	WSDATA Codigo As String
	WSDATA Nome   As String
	WSDATA Email  As String
	WSDATA Status As String
ENDWSSTRUCT

WsService Mobile_Vendedores Description "Mobile Logos - Carrega vendedores do ERP"

   WsData Cpf As String
   WsData Retorno  As Array of Vendedores
   
   WsMethod ConsultaVendedores Description "Mobile Logos - Carrega vendedores do ERP"

EndWsService

WsMethod ConsultaVendedores WsReceive Cpf WsSend Retorno WsService Mobile_Vendedores

Local nX     := 0
Local cQuery := "" 

::Retorno := {}

cQuery := "SELECT A3_COD, A3_NOME, A3_EMAIL FROM " + RetSQLName("SA3")
cQuery += " WHERE "
cQuery += "A3_CGC = '" + Cpf + "' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA3QRY", .F., .T.)

ConOut("Carregando vendedor: " + SA3QRY->A3_COD)
If !SA3QRY->(EOF())
	aAdd(::Retorno, WSClassNew("Vendedores"))
	::Retorno[1]:Codigo := SA3QRY->A3_COD
	::Retorno[1]:Nome   := SA3QRY->A3_NOME
	::Retorno[1]:Email  := SA3QRY->A3_EMAIL
	::Retorno[1]:Status := "1"
Else
	aAdd(::Retorno, WSClassNew("Vendedores"))
	::Retorno[1]:Codigo := ""
	::Retorno[1]:Nome   := ""
	::Retorno[1]:Email  := ""
	::Retorno[1]:Status := "0"
EndIf
SA3QRY->(dbCloseArea())
ConOut("Vendedor carregado...")
          
Return(.T.)