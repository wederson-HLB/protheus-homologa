#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Clientes
	WSDATA Status      As String
	WSDATA Codigo      As String
	WSDATA Loja        As String  
	WSDATA Doc         As String  
	WSDATA Nome        As String
	WSDATA Fantasia    As String
	WSDATA Tipo	   	   As String
	WSDATA Endereco    As String
	WSDATA Complemento As String
	WSDATA Bairro      As String
	WSDATA Cidade      As String
	WSDATA UF 	       As String
	WSDATA CEP 	       As String
	WSDATA DDD         As String
	WSDATA Telefone    As String
	WSDATA Contato     As String
	WSDATA Email       As String
	WSDATA DescTab     As Float
	WSDATA CondPag     As String
	WSDATA Tabela      As String
	WSDATA Transp      As String
	WSDATA GrpVen      As String
ENDWSSTRUCT

WsService Mobile_Clientes Description "LOGOS Mobile Consulta clientes do ERP"

   WsData Vendedor As String

   WsData Retorno As Array of Clientes
   
   WsMethod ConsultaClientes Description "LOGOS Mobile Retorna conteúdo da SA1 para o mobile"

EndWsService

WsMethod ConsultaClientes WsReceive Vendedor WsSend Retorno WsService Mobile_Clientes

Local nX       := 0
Local nPerDesc := 0
Local cQuery   := "" 

SE4->(dbSetOrder(1))
DA0->(dbSetOrder(1))

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de clientes.")

cQuery := "SELECT A1_COND, A1_TABELA, A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_NREDUZ, A1_END, A1_COMPLEM, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_DDD, "
cQuery += "A1_TEL, A1_CONTATO, A1_EMAIL, A1_TRANSP, A1_TIPO, A1_DESCTAB, A1_GRPVEN FROM " + RetSQLName("SA1")
cQuery += " WHERE "
cQuery += "A1_FILIAL = '" + xFilial("SA1") + "' AND "
cQuery += "A1_VEND = '" + Vendedor + "' AND "
cQuery += "A1_MSBLQL <> '1' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA1QRY", .F., .T.)

ConOut("Mobile Logos - Carregando clientes.")
If !SA1QRY->(EOF())
	While !SA1QRY->(EOF())
		nX++
		nPerDesc := U_RetDesc(SA1QRY->A1_GRPVEN)
		aAdd(::Retorno, WSClassNew("Clientes"))
		::Retorno[nX]:Status      := "1"
		::Retorno[nX]:Codigo      := SA1QRY->A1_COD
		::Retorno[nX]:Loja        := SA1QRY->A1_LOJA
		::Retorno[nX]:Doc         := SA1QRY->A1_CGC
		::Retorno[nX]:Nome        := SA1QRY->A1_NOME
		::Retorno[nX]:Fantasia    := SA1QRY->A1_NREDUZ
		::Retorno[nX]:Tipo        := SA1QRY->A1_TIPO
		::Retorno[nX]:Endereco    := SA1QRY->A1_END
		::Retorno[nX]:Complemento := SA1QRY->A1_COMPLEM
		::Retorno[nX]:Bairro      := SA1QRY->A1_BAIRRO
		::Retorno[nX]:Cidade      := SA1QRY->A1_MUN
		::Retorno[nX]:UF          := SA1QRY->A1_EST
		::Retorno[nX]:CEP         := SA1QRY->A1_CEP
		::Retorno[nX]:DDD         := SA1QRY->A1_DDD
		::Retorno[nX]:Telefone    := SA1QRY->A1_TEL
		::Retorno[nX]:Contato     := SA1QRY->A1_CONTATO
		::Retorno[nX]:Email       := SA1QRY->A1_EMAIL
		::Retorno[nX]:DescTab     := nPerDesc //SA1QRY->A1_DESCTAB
		::Retorno[nX]:CondPag     := SA1QRY->A1_COND
		::Retorno[nX]:Tabela      := SA1QRY->A1_TABELA
		::Retorno[nX]:Transp      := SA1QRY->A1_TRANSP
		::Retorno[nX]:GrpVen      := SA1QRY->A1_GRPVEN
		SA1QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("Clientes"))
	::Retorno[nX]:Status      := "0"
	::Retorno[nX]:Codigo      := ""
	::Retorno[nX]:Loja        := ""
	::Retorno[nX]:Doc         := ""
	::Retorno[nX]:Nome        := ""
	::Retorno[nX]:Fantasia    := ""
	::Retorno[nX]:Tipo        := ""
	::Retorno[nX]:Endereco    := ""
	::Retorno[nX]:Complemento := ""
	::Retorno[nX]:Bairro      := ""
	::Retorno[nX]:Cidade      := ""
	::Retorno[nX]:UF          := ""
	::Retorno[nX]:CEP         := ""
	::Retorno[nX]:DDD         := ""
	::Retorno[nX]:Telefone    := ""
	::Retorno[nX]:Contato     := ""
	::Retorno[nX]:Email       := ""
	::Retorno[nX]:DescTab     := 0
	::Retorno[nX]:CondPag     := ""
	::Retorno[nX]:Tabela      := ""
	::Retorno[nX]:Transp      := ""
	::Retorno[nX]:GrpVen      := ""
EndIf
SA1QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de clientes finalizado.")

Return(.T.)

User Function RetDesc(cGrupoCli)

Local cQuery  := ""
Local nPerDes := 0

If !Empty(cGrupoCli)
	cQuery := "SELECT ACO_PERDES FROM " + RetSQLName("ACO")
	cQuery += " WHERE "
	cQuery += "ACO_GRPVEN = '" + cGrupoCli + "' AND "
	cQuery += "D_E_L_E_T_ = ''"
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), "ACOQRY", .F., .F.)
	
	If !ACOQRY->(EOF())
		nPerDes := ACOQRY->ACO_PERDES
	EndIf
	ACOQRY->(dbCloseArea())
EndIf

Return(nPerDes)