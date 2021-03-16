#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Transp
	WSDATA Status      As String
	WSDATA Codigo      As String
	WSDATA Doc         As String  
	WSDATA Nome        As String
	WSDATA Endereco    As String
	WSDATA Bairro      As String
	WSDATA Cidade      As String
	WSDATA UF 	       As String
	WSDATA CEP 	       As String
	WSDATA DDD         As String
	WSDATA Telefone    As String
	WSDATA Contato     As String
ENDWSSTRUCT

WsService Mobile_Transp Description "LOGOS Mobile Consulta Transportadoras do ERP"

   WsData Retorno As Array of Transp
   
   WsMethod ConsultaTransportadoras Description "LOGOS Mobile Retorna conteúdo da SA4 para o mobile"

EndWsService

WsMethod ConsultaTransportadoras WsReceive NullParam WsSend Retorno WsService Mobile_Transp

Local nX       := 0
Local cQuery   := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação cadastro de Transportadoras.")

cQuery := "SELECT A4_COD, A4_CGC, A4_NOME, A4_END, A4_BAIRRO, A4_MUN, A4_EST, A4_CEP, A4_DDD, A4_TEL, A4_CONTATO FROM " + RetSQLName("SA4")
cQuery += " WHERE "
cQuery += "A4_FILIAL = '" + xFilial("SA4") + "' AND "
cQuery += "D_E_L_E_T_ = ''"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SA4QRY", .F., .T.)

ConOut("Mobile Logos - Carregando Transportadoras.")
If !SA4QRY->(EOF())
	While !SA4QRY->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("Transp"))
		::Retorno[nX]:Status      := "1"
		::Retorno[nX]:Codigo      := SA4QRY->A4_COD
		::Retorno[nX]:Doc         := SA4QRY->A4_CGC
		::Retorno[nX]:Nome        := SA4QRY->A4_NOME
		::Retorno[nX]:Endereco    := SA4QRY->A4_END
		::Retorno[nX]:Bairro      := SA4QRY->A4_BAIRRO
		::Retorno[nX]:Cidade      := SA4QRY->A4_MUN
		::Retorno[nX]:UF          := SA4QRY->A4_EST
		::Retorno[nX]:CEP         := SA4QRY->A4_CEP
		::Retorno[nX]:DDD         := SA4QRY->A4_DDD
		::Retorno[nX]:Telefone    := SA4QRY->A4_TEL
		::Retorno[nX]:Contato     := SA4QRY->A4_CONTATO
		SA4QRY->(dbSkip())
	End
Else
	::Retorno[nX]:Status      := "0"
	::Retorno[nX]:Codigo      := ""
	::Retorno[nX]:Doc         := ""
	::Retorno[nX]:Nome        := ""
	::Retorno[nX]:Endereco    := ""
	::Retorno[nX]:Bairro      := ""
	::Retorno[nX]:Cidade      := ""
	::Retorno[nX]:UF          := ""
	::Retorno[nX]:CEP         := ""
	::Retorno[nX]:DDD         := ""
	::Retorno[nX]:Telefone    := ""
	::Retorno[nX]:Contato     := ""
EndIf
SA4QRY->(dbCloseArea())
ConOut("Mobile Logos - WebService de Cadastro de Transportadoras finalizado.")

Return(.T.)