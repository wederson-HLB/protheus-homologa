#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Tabela
	WSDATA Status    As String
	WSDATA Codigo    As String
	WSDATA Descricao As String
ENDWSSTRUCT

WsService Mobile_Tabela Description "Mobile Logos - Consulta tabela de preços do ERP"

   WsData Vendedor As String
   WsData Retorno As Array of Tabela
   
   WsMethod CarregaTabela Description "Mobile Logos - Retorna conteúdo da DA0 para o mobile"

EndWsService

WsMethod CarregaTabela WsReceive Vendedor WsSend Retorno WsService Mobile_Tabela

Local nX       := 0     
Local nPos     := 0     
Local nRec     := 0
Local aTabela  := {}
Local cTabela  := ""
Local cQuery   := "" 

ConOut("Mobile Logos - Inicio da importação das tabelas de preços.")

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

cQuery := "SELECT DA0_CODTAB, DA0_DESCRI FROM " + RetSQLName("DA0") + " DA0 "
cQuery += " WHERE "
cQuery += "DA0_CODTAB IN (" + cTabela + ") AND "
cQuery += "DA0.D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DA0QRY", .F., .T.)  

ConOut("Mobile Logos - Carregando tabelas de preços.")
                     
::Retorno := {}
nX := 0
If !DA0QRY->(EOF())
	While !DA0QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("Tabela"))
		::Retorno[nX]:Status    := "1"
		::Retorno[nX]:Codigo    := DA0QRY->DA0_CODTAB
		::Retorno[nX]:Descricao := DA0QRY->DA0_DESCRI
		DA0QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("Tabela"))
	::Retorno[nX]:Status    := "0"
	::Retorno[nX]:Codigo    := ""
	::Retorno[nX]:Descricao := ""
End
DA0QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de tabelas de preços finalizado.")

Return(.T.)