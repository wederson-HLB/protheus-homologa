//---------------------------------------------------------------------------------------------------------------------------------------------//
//Wederson L. Santana -HLB- 21/05/2020
//Específico Shiseido
//WS para integração com o operador logístico
//---------------------------------------------------------------------------------------------------------------------------------------------//

#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

WSSTRUCT RetOperador
	WSDATA Codigo	As String
	WSDATA Mensagem As String 
ENDWSSTRUCT

WSSTRUCT oPedido
WsData cNumPV     as String
WsData cItemPV    as String
WsData cCodProd   as String
WsData cCodCli    as String
WsData cLjCli     as String
WsData nQtdExp    as String
WsData nQtdSol    as String
WsData nVolume    as String
WsData cEspecie   as String
WsData cObs       as String
WsData cToken     as String

ENDWSSTRUCT


WSSERVICE R7WS001 Description "WS Protheus Shiseido Integração x Operador Logístico" 
	WSDATA oPv		As oPedido
	WSDATA RetInt   As Array of RetOperador
	WSMETHOD IntPvOperador Description "Integra quantidade expedida pelo operador logístico"
ENDWSSERVICE

*----------------------------------------------------------------------------------*
 WSMETHOD IntPvOperador WSRECEIVE oPv WSSEND RetInt WSSERVICE R7WS001
*----------------------------------------------------------------------------------*

Local cPedido	:= PadR(::oPv:cNumPV   , Tamsx3("C5_NUM")[1] )
Local cItem		:= PadR(::oPv:cItemPV  , Tamsx3("C6_ITEM")[1] )
Local cProduto  := PadR(::oPv:cCodProd , Tamsx3("B1_COD")[1] )
Local cCliente  := PadR(::oPv:cCodCli  , Tamsx3("A1_COD")[1] )
Local cLoja     := PadR(::oPv:cLjCli   , Tamsx3("A1_LOJA")[1] )
Local nQuantExp := Val(::oPv:nQtdExp)
Local nQuantSol := Val(::oPv:nQtdSol)
Local nVol      := Val(::oPv:nVolume)
Local cVolEsp   := PadR(::oPv:cEspecie , Tamsx3("C5_ESPECI1")[1] )
Local cObsOpr   := PadR(::oPv:cObs     , Tamsx3("C6_VDOBS" )[1] )
Local cChave    := PadR(::oPv:cToken   , 10 )
Local aEmp			:= {}

If! cChave== "0123456789"
	AADD(::RetInt, WSClassNew("RetOperador"))
	::RetInt[1]:Codigo := "010"
	::RetInt[1]:Mensagem := "Token inválido"

	conout("R7WS001 -"+cPedido+"- Token invalido.")
Else
    RpcClearEnv()
    RpcSetType( 3 )
    PREPARE ENVIRONMENT EMPRESA "R7" FILIAL "01" TABLES "SA1" , "SB1" , "SC5" , "SC6"  MODULO "FAT"
    conout("R7WS001 -"+cPedido+"- Ambiente iniciado.")

    SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
       If SA1->A1_MSBLQL <> "1"
	   
          SB1->(dbSetOrder(1))
		  If SB1->(dbSeek(xFilial("SB1")+cProduto))
             If SB1->B1_MSBLQL <> "1"
               
			    SC5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+cPedido))

                   If Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
				    
					   SC6->(dbSetOrder(1))
                       If SC6->(dbSeek(xFilial("SC6")+cPedido+cItem))
                          // nQuantSol 

                          Reclock("SC6",.F.)
						  SC6->C6_QTDLIB  := nQuantExp
                          SC6->C6_XXQTWMS := nQuantExp 
                          SC6->C6_VDOBS := cObsOpr   
					      MsunLock()
                 
				          SC5->(dbSetOrder(1))
					      SC5->(dbSeek(xFilial("SC5")+cPedido))
				          Reclock("SC5",.F.)
						  SC5->C5_VOLUME1 += nVol      
                          SC5->C5_ESPECI1 := cVolEsp   
						  MsUnlock()

				  	      AADD(::RetInt, WSClassNew("RetOperador"))
	                      ::RetInt[1]:Codigo := "002"
	                      ::RetInt[1]:Mensagem := "Processamento realizado com sucesso"
				   
				          conout("R7WS001 -"+cPedido+"- Processamento realizado com sucesso.")

				       Else
                           AADD(::RetInt, WSClassNew("RetOperador"))
	                       ::RetInt[1]:Codigo := "011"
	                       ::RetInt[1]:Mensagem := "Item do pedido não encontrado"
				       EndIf

                   Else
				       
					   Do Case
					      Case !Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)
                               AADD(::RetInt, WSClassNew("RetOperador"))
	                           ::RetInt[1]:Codigo := "004"
	                           ::RetInt[1]:Mensagem := "Pedido faturado"
						  Case !Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA).And. Empty(SC5->C5_BLQ)
						       AADD(::RetInt, WSClassNew("RetOperador"))
	                           ::RetInt[1]:Codigo := "012"
	                           ::RetInt[1]:Mensagem := "Pedido liberado anteriormente"
						  Case SC5->C5_BLQ == '1'
						       AADD(::RetInt, WSClassNew("RetOperador"))
	                           ::RetInt[1]:Codigo := "005"
	                           ::RetInt[1]:Mensagem := "Pedido com bloqueio"
						  OtherWise
						      AADD(::RetInt, WSClassNew("RetOperador"))
	                          ::RetInt[1]:Codigo := "001"
	                          ::RetInt[1]:Mensagem := "Erro interno"

  					  	      conout("R7WS001 -"+cPedido+"- Erro interno.")
					   EndCase  	   

				   EndIf	   
	            Else
                    AADD(::RetInt, WSClassNew("RetOperador"))
	                ::RetInt[1]:Codigo := "007"
	                ::RetInt[1]:Mensagem := "Pedido não encontrado"
                EndIf
			 Else
                 AADD(::RetInt, WSClassNew("RetOperador"))
	             ::RetInt[1]:Codigo := "007"
	             ::RetInt[1]:Mensagem := "Produto bloqueado"
             EndIf
          Else
              AADD(::RetInt, WSClassNew("RetOperador"))
	          ::RetInt[1]:Codigo := "006"
	          ::RetInt[1]:Mensagem := "Produto não encontrado"
		  EndIf
	   Else
		   AADD(::RetInt, WSClassNew("RetOperador"))
	       ::RetInt[1]:Codigo := "009"
	       ::RetInt[1]:Mensagem := "Cliente bloqueado"
       EndIf
    Else
		AADD(::RetInt, WSClassNew("RetOperador"))
	    ::RetInt[1]:Codigo := "008"
	    ::RetInt[1]:Mensagem := "Cliente não encontrado"
    EndIf

   // RESET ENVIRONMENT
    conout("R7WS001 -"+cPedido+"- Ambiente encerrado.")
EndIf
Return .T.

