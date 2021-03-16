#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT StatusPed
	WSDATA Status     As String
	WSDATA DataFatura As String
ENDWSSTRUCT

WsService Mobile_StatusPed Description "Mobile Logos - Carrega Status do Pedido do ERP para o mobile."

   WsData Pedido  As String
   WsData Retorno As Array of StatusPed
   
   WsMethod ConsultaStatus Description "Mobile Logos - Carrega Status do Pedido do ERP para o mobile."

EndWsService

WsMethod ConsultaStatus WsReceive Pedido WsSend Retorno WsService Mobile_StatusPed

Local nX       := 0     
Local nPos     := 0     

::Retorno := {}
                                        
SC5->(dbSetOrder(1))
SF2->(dbSetOrder(1))

ConOut("Mobile Logos - Carregando Status.")

nX := 0
If SC5->(dbSeek(xFilial("SC5") + Pedido))
		If !Empty(SC5->C5_NOTA)
			If SF2->(dbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE))
				nX++
				aAdd(::Retorno, WSClassNew("StatusPed"))
				::Retorno[nX]:Status    := "1"
				::Retorno[nX]:DataFatura := DtoC(SF2->F2_EMISSAO)
			EndIf
		Else
			nX++
			aAdd(::Retorno, WSClassNew("StatusPed"))
				::Retorno[nX]:Status    := "0"
				::Retorno[nX]:DataFatura := ""
		EndIf
Else
	nX++
	aAdd(::Retorno, WSClassNew("StatusPed"))
		::Retorno[nX]:Status    := "0"
		::Retorno[nX]:DataFatura := ""
EndIf
ConOut("Mobile Logos - WebService de Status de Pedido finalizado.")

Return(.T.)