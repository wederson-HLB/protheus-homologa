#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT ItensTab
	WSDATA status    As String
	WSDATA Codigo    As String
	WSDATA CodProd   As String
	WSDATA Preco     As Float
	WSDATA Estoque   As Float
ENDWSSTRUCT

WsService Mobile_ItensTab Description "Mobile Logos - Carrega itens da tabela de preços do ERP"

   WsData CodTab As String

   WsData Retorno As Array of ItensTab
   
   WsMethod CarregaItensTab Description "Mobile Logos - Retorna conteúdo da DA1 para o mobile"

EndWsService

WsMethod CarregaItensTab WsReceive CodTab WsSend Retorno WsService Mobile_ItensTab

Local nX       := 0     
Local nPos     := 0     
Local nRec     := 0
Local aTabela  := {}
Local cTabela  := ""
Local cQuery   := "" 

ConOut("Mobile Logos - Inicio da importação de itens de tabelas de preços.")

cQuery := "SELECT DA1_CODTAB, DA1_CODPRO, DA1_PRCVEN FROM " + RetSQLName("DA1") + " DA1 "
cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON B1_COD = DA1_CODPRO "
cQuery += " WHERE "
cQuery += "DA1_FILIAL = '" + xFilial("DA1") + "' AND "
cQuery += "DA1_CODTAB = '" + CodTab + "' AND "       
If CodTab == "007"
	cQuery += "B1_TIPO = 'PP' AND "       
EndIf
cQuery += "B1_MSBLQL <> '1' AND "
cQuery += "SB1.D_E_L_E_T_ = '' AND "
cQuery += "DA1.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DA1QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando itens tabelas de preços.")

SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
                     
::Retorno := {}
nX := 0
If !DA1QRY->(EOF())
	While !DA1QRY->(EOF())
		nX++
		SB1->(dbSeek(xFilial("SB1") + DA1QRY->DA1_CODPRO))
		SB2->(dbSeek(xFilial("SB2") + DA1QRY->DA1_CODPRO + SB1->B1_LOCPAD))
		aAdd(::Retorno, WSClassNew("ItensTab"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := DA1QRY->DA1_CODTAB
		::Retorno[nX]:CodProd   := DA1QRY->DA1_CODPRO
		If DA1QRY->DA1_CODTAB == "007"
			::Retorno[nX]:Preco     := SB2->B2_CM1
		Else
			::Retorno[nX]:Preco     := DA1QRY->DA1_PRCVEN
		EndIf
		::Retorno[nX]:Estoque   := SB2->(SaldoSB2())
		DA1QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("ItensTab"))
	::Retorno[nX]:Status    := "0"
	::Retorno[nX]:Codigo    := ""
	::Retorno[nX]:CodProd   := ""
	::Retorno[nX]:Preco     := 0
	::Retorno[nX]:Estoque   := 0
EndIf
DA1QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de itens tabelas de preços finalizado.")

Return(.T.)