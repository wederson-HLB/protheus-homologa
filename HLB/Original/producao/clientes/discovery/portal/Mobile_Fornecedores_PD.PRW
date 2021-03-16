#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscForn
	WSDATA Status      As String
	WSDATA Codigo      As String
	WSDATA Loja        As String  
	WSDATA Cnpj        As String  
	WSDATA Nome        As String
	WSDATA Endereco    As String
	WSDATA Bairro      As String
	WSDATA Cidade      As String
	WSDATA UF 	       As String
	WSDATA CEP 	       As String       
	WSDATA DDD         As String
	WSDATA Telefone    As String
	WSDATA Email       As String
	WSDATA IE		   As String
	WSDATA IM          As String
	WSDATA Banco	   As String
	WSDATA Agencia     As String
	WSDATA Conta	   As String
ENDWSSTRUCT

WsService Mobile_Fornecedores_PD Description "LOGOS Mobile Consulta fornecedores do ERP"

   WsData Vendedor As String

   WsData Retorno As Array of DiscForn
   
   WsMethod ConsultaFornecedores Description "LOGOS Mobile Retorna conteúdo da SA2 para o mobile"

EndWsService

WsMethod ConsultaFornecedores WsReceive NULLPARAM WsSend Retorno WsService Mobile_Fornecedores_PD

Local nX       := 0
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de fornecedores.")

cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC, A2_NOME, A2_END, A2_BAIRRO, A2_BANCO, A2_AGENCIA, A2_NUMCON, "
cQuery += "A2_MUN, A2_EST, A2_CEP, A2_DDD, A2_TEL, A2_EMAIL, A2_INSCR, A2_INSCRM FROM " + RetSQLName("SA2")
cQuery += " WHERE "
cQuery += "A2_FILIAL = '" + xFilial("SA1") + "' AND "
cQuery += "A2_MSBLQL <> '1' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA2QRY", .F., .F.)

ConOut("Mobile Logos - Carregando fornecedores.")
If !SA2QRY->(EOF())
	While !SA2QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("DiscForn"))
		::Retorno[nX]:Status      := "1"
		::Retorno[nX]:Codigo      := SA2QRY->A2_COD
		::Retorno[nX]:Loja        := SA2QRY->A2_LOJA
		::Retorno[nX]:Cnpj        := SA2QRY->A2_CGC
		::Retorno[nX]:Nome        := SA2QRY->A2_NOME
		::Retorno[nX]:Endereco    := SA2QRY->A2_END
		::Retorno[nX]:Bairro      := SA2QRY->A2_BAIRRO
		::Retorno[nX]:Cidade      := SA2QRY->A2_MUN
		::Retorno[nX]:UF          := SA2QRY->A2_EST
		::Retorno[nX]:CEP         := SA2QRY->A2_CEP
		::Retorno[nX]:DDD         := SA2QRY->A2_DDD
		::Retorno[nX]:Telefone    := SA2QRY->A2_TEL
		::Retorno[nX]:Email       := SA2QRY->A2_EMAIL
		::Retorno[nX]:IE          := SA2QRY->A2_INSCR
		::Retorno[nX]:IM	      := SA2QRY->A2_INSCRM
		::Retorno[nX]:Banco       := SA2QRY->A2_BANCO
		::Retorno[nX]:Agencia     := SA2QRY->A2_AGENCIA
		::Retorno[nX]:Conta		  := SA2QRY->A2_NUMCON
		SA2QRY->(dbSkip())
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("DiscForn"))
	::Retorno[nX]:Status      := "0"
	::Retorno[nX]:Codigo      := ""
	::Retorno[nX]:Loja        := ""
	::Retorno[nX]:Cnpj        := ""
	::Retorno[nX]:Nome        := ""
	::Retorno[nX]:Endereco    := ""
	::Retorno[nX]:Bairro      := ""
	::Retorno[nX]:Cidade      := ""
	::Retorno[nX]:UF          := ""
	::Retorno[nX]:CEP         := ""
	::Retorno[nX]:DDD         := ""
	::Retorno[nX]:Telefone    := ""
	::Retorno[nX]:Email       := ""
	::Retorno[nX]:IE          := ""
	::Retorno[nX]:IM	      := ""
	::Retorno[nX]:Banco       := ""
	::Retorno[nX]:Agencia     := ""
	::Retorno[nX]:Conta		  := ""
EndIf
SA2QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de fornecedores finalizado.")

Return(.T.)