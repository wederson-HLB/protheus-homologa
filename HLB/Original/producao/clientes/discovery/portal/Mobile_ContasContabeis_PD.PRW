#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscContas
	WSDATA Status      As String
	WSDATA Conta       As String  
	WSDATA DescConta   As String
	WSDATA Grupo       As String  
	WSDATA DescGrupo   As String
ENDWSSTRUCT

WsService Mobile_ContasContabeis_PD Description "Mobile Logos - Carrega C.Contabeis do ERP para o mobile."

   WsData Retorno As Array of DiscContas
   
   WsMethod ConsultaContas Description "Mobile Logos - Carrega C.Contabeis do ERP para o mobile."

EndWsService

WsMethod ConsultaContas WsReceive NULLPARAM WsSend Retorno WsService Mobile_ContasContabeis_PD

Local nX       := 0     
Local nPos     := 0     
Local cQuery   := "" 
Local cTabela  := ""
Local aTabela  := {}

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de contas contabeis.")

cQuery := "SELECT DISTINCT CT1_CONTA, CT1_DESC01, CTR_GRUPO, CTR_DESC FROM " + RetSQLName("CT1") + " CT1 "
cQuery += "INNER JOIN " + RetSQLName("CTR") + " CTR ON CTR_GRUPO = CT1_GRUPO "
cQuery += " WHERE "
cQuery += "CT1_FILIAL = '" + xFilial("CT1") + "' AND "
cQuery += "CTR_FILIAL = '" + xFilial("CTR") + "' AND "
cQuery += "CT1_CLASSE = '2' AND "
cQuery += "CT1_BLOQ = '2' AND "
cQuery += "CT1.D_E_L_E_T_ = '' AND "
cQuery += "CTR.D_E_L_E_T_ = ''"    

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "CT1QRY", .F., .F.)  

ConOut("Mobile Logos - Carregando Grupos Contábeis.")
nX := 0

If !CT1QRY->(EOF())
	While !CT1QRY->(EOF())
		nX++
		conout("Grupo: " + CT1QRY->CTR_GRUPO + "-" + CT1QRY->CTR_DESC)
		aAdd(::Retorno, WSClassNew("DiscContas"))
		::Retorno[nX]:Status     := "1"
		::Retorno[nX]:Conta      := CT1QRY->CT1_CONTA
		::Retorno[nX]:DescConta  := CT1QRY->CT1_DESC01
		::Retorno[nX]:Grupo      := CT1QRY->CTR_GRUPO
		::Retorno[nX]:DescGrupo  := CT1QRY->CTR_DESC
		CT1QRY->(dbSkip())
	End
Else
	nX++
	conout("Conta: ")
	aAdd(::Retorno, WSClassNew("DiscContas"))
	::Retorno[nX]:Status     := "0"
	::Retorno[nX]:Conta      := ""
	::Retorno[nX]:DescConta  := ""
	::Retorno[nX]:Grupo      := ""
	::Retorno[nX]:DescGrupo  := ""
EndIf
CT1QRY->(dbCloseArea())

ConOut("Mobile Logos - WebService de Cadastro de Grupos Contabeis finalizado.")
           
Return(.T.)