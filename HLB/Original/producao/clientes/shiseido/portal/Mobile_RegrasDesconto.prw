#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT RegraDesconto
	WSDATA Status      As String
	WSDATA GrupoCli    As String
	WSDATA Produto     As String
	WSDATA Desconto    As float
ENDWSSTRUCT

WsService Mobile_RegrasDesconto Description "LOGOS Mobile Consulta Regras de Desconto do ERP"

   WsData Vendedor As String

   WsData Retorno As Array of RegraDesconto
   
   WsMethod ConsultaRegrasDesconto Description "LOGOS Mobile Retorna Regras de Desconto para o mobile"

EndWsService

WsMethod ConsultaRegrasDesconto WsReceive NULLPARAM WsSend Retorno WsService Mobile_RegrasDesconto

Local nX       := 0
Local cQuery   := "" 

ACO->(dbSetOrder(1))
ACP->(dbSetOrder(1))

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação de Regras de Desconto.")


ConOut("Mobile Logos - Carregando Regras de Desconto.")
ACP->(dbGoTop())
While !ACP->(EOF())
	If !Empty(ACP->ACP_CODPRO)
		If ACO->(dbSeek(xFilial("ACO") + ACP->ACP_CODREG))
			nX++
			aAdd(::Retorno, WSClassNew("RegraDesconto"))
			::Retorno[nX]:Status      := "1"
			::Retorno[nX]:GrupoCli    := ACO->ACO_GRPVEN
			::Retorno[nX]:Produto     := ACP->ACP_CODPRO
			::Retorno[nX]:Desconto    := ACP->ACP_PERDES
		EndIf
	EndIf
	ACP->(dbSkip())
End

If Empty(::Retorno)
	aAdd(::Retorno, WSClassNew("RegraDesconto"))
	::Retorno[1]:Status      := "0"
	::Retorno[1]:GrupoCli    := ""
	::Retorno[1]:Produto     := ""
	::Retorno[1]:Desconto    := 0
EndIf
	
ConOut("Mobile Logos - WebService de Regras de Desconto finalizado.")

Return(.T.)