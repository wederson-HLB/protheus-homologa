//------------------------------------------------------------------------------------------------------------//
//Wederson L. Santana - 25/08/2020                                                                            //  
//Web Service de integração - Operador logístico x Faturamento Shiseido                                       //
//------------------------------------------------------------------------------------------------------------//

#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

WSSTRUCT RetLog
	WSDATA Codigo	As String
	WSDATA Mensagem As String 
ENDWSSTRUCT

WSSTRUCT PedidoLog
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

WSSTRUCT StrPvLog
   WSDATA ListPv  AS Array Of PedidoLog
ENDWSSTRUCT

WSSERVICE R7WS002 Description "WS Protheus Faturamento - Integração Shiseido x Operador Logístico." 
   WSDATA oPV 	   As  StrPvLog
	WSDATA RetInt  As  Array Of RetLog
	WSMETHOD IntFatLog Description "Integra quantidade expedida pelo operador logístico "
ENDWSSERVICE

*-----------------------------------------------------------------------------------*
 WSMETHOD IntFatLog WSRECEIVE oPv WSSEND RetInt WSSERVICE R7WS002
*-----------------------------------------------------------------------------------*
Local nR		:= 0
Local cPedido	:= ""
Local cItem		:= ""
Local cProduto  := ""
Local cCliente  := ""
Local cLoja     := ""
Local nQuantExp := 0
Local nQuantSol := 0
Local nVol      := 0
Local cVolEsp   := ""
Local cObsOpr   := ""
Local cChave    := 0
Local cToken    := ""
Local cDataHr   := Dtos(dDataBase)+Time()
Local cMensagem := ""
Local nQtdEmp   := 0

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA "R7" FILIAL "01" TABLES "SA1" , "SB1" , "SC5" , "SC6"  MODULO "FAT"
conout("R7WS002 -"+cPedido+"- Ambiente iniciado. "+cDataHr)

cToken := AllTrim(SuperGetMV("MV_XTOKEN", .F.,"Hlb@09WsR7"))

For nR:= 1 to Len(::oPv:ListPV)
   
   cPedido	 := PadR(::oPv:ListPV[nR]:cNumPV   , Tamsx3("C5_NUM")[1] )
   cItem	 := PadR(::oPv:ListPV[nR]:cItemPV  , Tamsx3("C6_ITEM")[1])
   cProduto  := PadR(::oPv:ListPV[nR]:cCodProd , Tamsx3("B1_COD")[1] )
   cCliente  := PadR(::oPv:ListPV[nR]:cCodCli  , Tamsx3("A1_COD")[1] )
   cLoja     := PadR(::oPv:ListPV[nR]:cLjCli   , Tamsx3("A1_LOJA")[1])
   nQuantExp :=  Val(::oPv:ListPV[nR]:nQtdExp)
   nQuantSol :=  Val(::oPv:ListPV[nR]:nQtdSol)
   nVol      :=  Val(::oPv:ListPV[nR]:nVolume)
   cVolEsp   := PadR(::oPv:ListPV[nR]:cEspecie , Tamsx3("C5_ESPECI1")[1])
   cObsOpr   := PadR(::oPv:ListPV[nR]:cObs     , Tamsx3("C6_VDOBS" )[1])
   cChave    := PadR(::oPv:ListPV[nR]:cToken   , 10 )
   nQtdEmp   := Iif((nQuantSol-nQuantExp)>0,(nQuantSol-nQuantExp),0)

   If! Alltrim(cChave) == Alltrim(cToken)

	    AADD(::RetInt, WSClassNew("RetLog"))
	    ::RetInt[nR]:Codigo := "010"
	    ::RetInt[nR]:Mensagem := "Token inválido"
        
		cMensagem:= cPedido+" - Token invalido "+cChave+" - Token SYS "+cToken+"."
	    conout(cMensagem)

		fGravaLog(cPedido,"1",cMensagem,"010")
   Else
 
       SA1->(dbSetOrder(1))
	    If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
           If SA1->A1_MSBLQL <> "1"
	   
              SB1->(dbSetOrder(1))
		      If SB1->(dbSeek(xFilial("SB1")+cProduto))
                 If SB1->B1_MSBLQL <> "1"
               
			        SC5->(dbSetOrder(1))
				    If SC5->(dbSeek(xFilial("SC5")+cPedido))

					    If SC5->C5_CLIENTE== SA1->A1_COD .And. SC5->C5_LOJACLI == SA1->A1_LOJA

                        	If Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
				    
					       		SC6->(dbSetOrder(1))
                           		If SC6->(dbSeek(xFilial("SC6")+cPedido+cItem))
                              		Reclock("SC6",.F.)
						      		SC6->C6_QTDLIB  := nQuantExp
                              		SC6->C6_XXQTWMS := nQuantExp 
                              		SC6->C6_VDOBS   := cObsOpr   
									SC6->C6_QTDEMP  := nQtdEmp 
							  
							  		If nQuantExp==0
							     		SC6->C6_BLQ := "S"
							  		Else
							     		SC6->C6_BLQ := ""	 
							  		EndIf 	  
							  
					          		MsunLock()
                 
				              		SC5->(dbSetOrder(1))
					          		SC5->(dbSeek(xFilial("SC5")+cPedido))
				              		Reclock("SC5",.F.)
						      		SC5->C5_VOLUME1 := nVol
							  		SC5->C5_PESOL   := nVol * 2
							  		SC5->C5_PBRUTO  := (nVol * 2)+1
                              		SC5->C5_ESPECI1 := cVolEsp   
							  		SC5->C5_XXOPERA := "S"
						      		MsUnlock()
				  	          
							  		If nQuantExp > 0
	                             
								 		cMensagem:="Processamento realizado com sucesso para o item "+cItem+" do pedido."

                                 		AADD(::RetInt, WSClassNew("RetLog"))
								 		::RetInt[nR]:Codigo := "002"
	                             		::RetInt[nR]:Mensagem := cMensagem
								 
								 		fGravaLog(cPedido,"3",cMensagem,"002")

							  		Else
                                  
								  		cMensagem:= "Processamento realizado identificado ruptura para o item "+cItem+" do pedido."

                                  		AADD(::RetInt, WSClassNew("RetLog"))
								  		::RetInt[nR]:Codigo := "999"
	                              		::RetInt[nR]:Mensagem := cMensagem

								  		fGravaLog(cPedido,"1",cMensagem,"999")

							  		EndIf
				   
				              		conout("R7WS002 -"+cPedido+"- Processamento realizado com sucesso"+cItem+". "+cDataHr)
                              
				           		Else
                               		cMensagem:= "Item "+cItem+" do pedido não encontrado."

                               		AADD(::RetInt, WSClassNew("RetLog"))
	                           		::RetInt[nR]:Codigo := "011"
	                           		::RetInt[nR]:Mensagem := cMensagem

							   		fGravaLog(cPedido,"1",cMensagem,"011")
				           		EndIf

                       		Else
				            	Do Case
					           		Case !Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)

										SD2->(dbSetOrder(8))
                                    	If SD2->(dbSeek(xFilial("SD2")+cPedido+cItem))            
								  					
									   		cMensagem:="Item "+cItem+" do pedido faturado NF "+SD2->D2_DOC+" SERIE "+SD2->D2_SERIE+"."

									   		AADD(::RetInt, WSClassNew("RetLog"))
	                                   		::RetInt[nR]:Codigo := "004"
	                                   		::RetInt[nR]:Mensagem := cMensagem

                                       		fGravaLog(cPedido,"1",cMensagem,"004")

								    	Else

                                        	SC6->(dbSetOrder(1))
                                        	If SC6->(dbSeek(xFilial("SC6")+cPedido+cItem))
                                           		Reclock("SC6",.F.)
						                   		SC6->C6_QTDLIB  := nQuantExp
                                           		SC6->C6_XXQTWMS := nQuantExp 
                                           		SC6->C6_VDOBS   := cObsOpr   
												SC6->C6_QTDEMP  := nQtdEmp    
							  
							               		If nQuantExp==0
							                  		SC6->C6_BLQ := "S"
							               		Else
							                  		SC6->C6_BLQ := ""	 
							               		EndIf

										   		MsunLock()

										   		cMensagem:="Processamento realizado com sucesso para o item "+cItem+" do pedido."

                                           		AADD(::RetInt, WSClassNew("RetLog"))
								           		::RetInt[nR]:Codigo := "002"
	                                       		::RetInt[nR]:Mensagem := cMensagem
								 
								           		fGravaLog(cPedido,"3",cMensagem,"002")
											Else
										   		cMensagem:="Item "+cItem+" não encontrado no pedido."

                                           		AADD(::RetInt, WSClassNew("RetLog"))
	                                       		::RetInt[nR]:Codigo := "007"
	                                       		::RetInt[nR]:Mensagem := cMensagem

					                       		fGravaLog(cPedido,"1",cMensagem,"007")   
									    	EndIf	 
								    	EndIf	 

						       		Case !Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA).And. Empty(SC5->C5_BLQ)
						            
										cMensagem:="Pedido liberado anteriormente"

										AADD(::RetInt, WSClassNew("RetLog"))
	                                	::RetInt[nR]:Codigo := "012"
	                                	::RetInt[nR]:Mensagem := cMensagem

										fGravaLog(cPedido,"1",cMensagem,"012")

						       		Case SC5->C5_BLQ == '1'
							      
								    	cMensagem:= "Pedido com bloqueio"

						            	AADD(::RetInt, WSClassNew("RetLog"))
	                                	::RetInt[nR]:Codigo := "005"
	                                	::RetInt[nR]:Mensagem := cMensagem

										fGravaLog(cPedido,"1",cMensagem,"005")
						       		OtherWise
						           
								   		cMensagem:="SITUAÇÃO NÃO PREVISTA."

								   		AADD(::RetInt, WSClassNew("RetLog"))
	                               		::RetInt[nR]:Codigo := "001"
	                               		::RetInt[nR]:Mensagem := cMensagem
  					  	               
                                   		conout(cMensagem)

								   		fGravaLog(cPedido,"1",cMensagem,"001")

					           	EndCase  	   

				            EndIf	   
						Else

							cMensagem:="Cliente/loja informado difere do pedido."

							AADD(::RetInt, WSClassNew("RetLog"))
	                        ::RetInt[nR]:Codigo := "998"
	                        ::RetInt[nR]:Mensagem := cMensagem
  					  	               
                            conout(cMensagem)

							fGravaLog(cPedido,"1",cMensagem,"998")

						EndIf	
	                Else
                       cMensagem:="Pedido não encontrado"

                       AADD(::RetInt, WSClassNew("RetLog"))
	                   ::RetInt[nR]:Codigo := "007"
	                   ::RetInt[nR]:Mensagem := cMensagem

					   fGravaLog(cPedido,"1",cMensagem,"007")
                    EndIf
			    Else
                    cMensagem:="Produto do item "+cItem+" do pedido encontra-se bloqueado no sistema."

                    AADD(::RetInt, WSClassNew("RetLog"))
	                ::RetInt[nR]:Codigo := "007"
	                ::RetInt[nR]:Mensagem := cMensagem

					fGravaLog(cPedido,"1",cMensagem,"007")
                EndIf
             Else
                cMensagem:="Produto referente ao item  "+cItem+" do pedido não encontrado."
			      
                 AADD(::RetInt, WSClassNew("RetLog"))
	             ::RetInt[nR]:Codigo := "006"
	             ::RetInt[nR]:Mensagem := cMensagem

				 fGravaLog(cPedido,"1",cMensagem,"006")
		     EndIf
	       Else
		      cMensagem:="Cliente bloqueado"

			   AADD(::RetInt, WSClassNew("RetLog"))
	          ::RetInt[nR]:Codigo := "009"
	          ::RetInt[nR]:Mensagem := cMensagem
              
			  fGravaLog(cPedido,"1",cMensagem,"009")
           EndIf
       Else
	       cMensagem:="Cliente não encontrado"

		    AADD(::RetInt, WSClassNew("RetLog"))
	       ::RetInt[nR]:Codigo := "008"
	       ::RetInt[nR]:Mensagem := cMensagem

		   fGravaLog(cPedido,"1",cMensagem)
       EndIf
   EndIf
Next nR

conout("R7WS002 -"+cPedido+"- Ambiente encerrado. "+cDataHr)

Return .T.

//----------------------------------------

Static Function fGravaLog(cPedido,cStatus,cMensagem,cCodLog)
Local aArea := GetArea()

Reclock("Z0G",.T.)
Z0G->Z0G_FILIAL := xFilial("Z0G")
Z0G->Z0G_PEDIDO := cPedido
Z0G->Z0G_DATA   := dDataBase
Z0G->Z0G_HORA   := Time()
Z0G->Z0G_USER   := "schedule"
Z0G->Z0G_TABELA := cCodLog
Z0G->Z0G_CHAVE  := "IDL"+cPedido
Z0G->Z0G_PROCES := "R7WS002"
Z0G->Z0G_STATUS := cStatus
Z0G->Z0G_MENSAG := SubStr(cMensagem,1,TamSx3("Z0G_MENSAG")[1])
Z0G->Z0G_ARQUIV := ""
Z0G->Z0G_ARQLOC := ""
MsUnlock()

RestArea(aArea)

