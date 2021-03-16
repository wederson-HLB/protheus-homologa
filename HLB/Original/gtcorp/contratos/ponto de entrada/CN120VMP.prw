#include 'protheus.ch'
#include 'parmtype.ch'
#define ENTER CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±¿ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Programa  * CN120VMP.PRW *                                                                   ³±?
±±?Autor     * Guilherme Fernandes Pilan - GFP *                                                ³±?
±±?Data      * 23/03/2017 - 16:11 *                                                             ³±?
±±¿ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Descricao * Tratamento para gravação automatica de Centro de Custo na Medição de Contratos * ³±?
±±?          * Sistema buscará o Centro de Custo da ultima medição encerrada ou buscará dao *   ³±?
±±?          * Contrato e gravará na Medição antes da geração do Pedido de Venda *              ³±?
±±¿ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Uso       * GESTÃO DE CONTRATOS - SIGAGCT                                                    ³±?
±±¿ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-----------------------*
User Function CN120VMP()
*-----------------------*
Local lPermissao := Paramixb[1]
Local cNumMed := "", i, j, lDivergencias := .F.
Local aRateios := {}, aVerRat1 := {}, aVerRat2 := {}
Local aOrd := SaveOrd({"CN9","CNZ","CN1","CNE"})

Begin Sequence

	If lPermissao
		CN9->(DbSetOrder(1))
		If CN9->(DbSeek(xFilial("CN9")+CND->CND_CONTRA+CND->CND_REVISA))
			CN1->(DbSetOrder(1))
			If CN1->(DbSeek(xFilial("CN1")+CN9->CN9_TPCTO)) .AND. CN1->CN1_ESPCTR <> "2" // Caso Contrato não seja Venda.
				Break
			EndIf
		EndIf
		
		//Verifica se itens foram medidos.
		CNE->(DbSetOrder(4))
		If CNE->(DbSeek(xFilial("CNE")+CND->CND_NUMMED)) 
			Do While CNE->(!Eof()) .AND. CNE->(CNE_FILIAL+CNE_NUMMED) == xFilial("CNE")+CND->CND_NUMMED
			    If Empty(CNE->CNE_QUANT)
			    	Break
			    EndIf
				CNE->(DbSkip())
			EndDo
		EndIf
		
		//Verifica se medicao tem rateio
		CNZ->(DbSetOrder(2))
		If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED)) 
			If !IsInCallStack("CNTA260") .AND. Empty(CND->CND_REVISA) // Para casos em que os rateios entre medição e contrato (sem revisão) são diferentes.
				// Armazenar Rateios da medição
				Do While CNZ->(!Eof()) .AND. ;
	   				CNZ->CNZ_FILIAL+CNZ->CNZ_CONTRA+CNZ->CNZ_REVISA+CNZ->CNZ_NUMMED == xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED
			   		aAdd(aVerRat1,{	CNZ->CNZ_ITCONT,;
			    				CNZ->CNZ_ITEM,;
			    				CNZ->CNZ_PERC,;
			    				CNZ->CNZ_CC,;
			    				CNZ->CNZ_VALOR1,;
			    				CNZ->CNZ_VALOR2,;
			    				CNZ->CNZ_VALOR3,;
			    				CNZ->CNZ_VALOR4,;
			    				CNZ->CNZ_VALOR5	})
			    	CNZ->(DbSkip())
				EndDo
				// Armazenar Rateios do contrato
				If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+AvKey("","CND_NUMMED")))
			   		Do While CNZ->(!Eof()) .AND. ;
	   			   		CNZ->CNZ_FILIAL+CNZ->CNZ_CONTRA+CNZ->CNZ_REVISA+CNZ->CNZ_NUMMED == xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+AvKey("","CND_NUMMED")
			   	   		aAdd(aVerRat2,{	CNZ->CNZ_ITCONT,;
			    				CNZ->CNZ_ITEM,;
			    				CNZ->CNZ_PERC,;
			    				CNZ->CNZ_CC,;
			    				CNZ->CNZ_VALOR1,;
			    				CNZ->CNZ_VALOR2,;
			    				CNZ->CNZ_VALOR3,;
			    				CNZ->CNZ_VALOR4,;
			    				CNZ->CNZ_VALOR5	})
			       		CNZ->(DbSkip())
					EndDo
				EndIf
			    If !(lDivergencias := Len(aVerRat1) <> Len(aVerRat2))
			    	For i := 1 To Len(aVerRat1)
			    		For j := 1 To Len(aVerRat1[i])
							If (lDivergencias := aVerRat1[i][j] <> aVerRat2[i][j])
								Exit
					   		EndIf  
					   Next j
			    	Next i
			    EndIf
			    If lDivergencias
			    	If MsgYesNo("Existem divergencias entre os rateios informados no Contrato e na Medição." + ENTER +;
			    	   			"Deseja considerar as informações da Medição para a geração do Pedido de Venda?" + Replicate(ENTER,2) +;
			    				"Sim: Considerar as informações de rateios da Medição." + ENTER +;
			    				"Não: Considerar as informações de rateios do Contrato.","Grant Thornton")
						aRateios := aClone(aVerRat1)
			    	Else
			    		aRateios := aClone(aVerRat2)
			    	EndIf
			    EndIf
				CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED))
			ElseIf !Empty(CNZ->CNZ_PERC)
				Break
			EndIf
		EndIf
		
		If Len(aRateios) == 0
			//Se nao, localizar ultima medicao
			If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA))
				Do While CNZ->(!Eof()) .AND. CNZ->(CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA) == xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA
				    If !Empty(CNZ->CNZ_NUMMED) .AND. CNZ->CNZ_NUMMED <> CND->CND_NUMMED
			    		cNumMed := CNZ->CNZ_NUMMED
				    EndIf
					CNZ->(DbSkip())
				EndDo
			EndIf
		
			//Se existir, pegar rateio de la.
			If !Empty(cNumMed)
				If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+cNumMed))
					Do While CNZ->(!Eof()) .AND. ;
	   					CNZ->CNZ_FILIAL+CNZ->CNZ_CONTRA+CNZ->CNZ_REVISA+CNZ->CNZ_NUMMED == xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+cNumMed
	   					aAdd(aRateios,{	CNZ->CNZ_ITCONT,;
			    					CNZ->CNZ_ITEM,;
			    					CNZ->CNZ_PERC,;
			    					CNZ->CNZ_CC,;
			    					CNZ->CNZ_VALOR1,;
				    				CNZ->CNZ_VALOR2,;
				    				CNZ->CNZ_VALOR3,;
				    				CNZ->CNZ_VALOR4,;
				    				CNZ->CNZ_VALOR5	})
			    		CNZ->(DbSkip())
				    EndDo
				EndIf
			Else
			//Se nao, pegar do contrato.
				If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+AvKey("","CND_REVISA")+AvKey("","CND_NUMMED")))
					Do While CNZ->(!Eof()) .AND. ;
	   					CNZ->CNZ_FILIAL+CNZ->CNZ_CONTRA+CNZ->CNZ_REVISA+CNZ->CNZ_NUMMED == xFilial("CNZ")+CND->CND_CONTRA+AvKey("","CND_REVISA")+AvKey("","CND_NUMMED")
	   					aAdd(aRateios,{	CNZ->CNZ_ITCONT,;
			    					CNZ->CNZ_ITEM,;
			    					CNZ->CNZ_PERC,;
			    					CNZ->CNZ_CC,;
			    					CNZ->CNZ_VALOR1,;
				    				CNZ->CNZ_VALOR2,;
				    				CNZ->CNZ_VALOR3,;
				    				CNZ->CNZ_VALOR4,;
				    				CNZ->CNZ_VALOR5	})
			    		CNZ->(DbSkip())
				    EndDo
				EndIf
	   		EndIf
      	EndIf
      	
		If Len(aRateios) # 0
			If CNZ->(DbSeek(xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED)) //.AND. Empty(CNZ->CNZ_PERC)
				Do While CNZ->(!Eof()) .AND. ;
	   					CNZ->CNZ_FILIAL+CNZ->CNZ_CONTRA+CNZ->CNZ_REVISA+CNZ->CNZ_NUMMED == xFilial("CNZ")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED	
	   				If RecLock("CNZ",.F.)
	   					CNZ->(DbDelete())
	   					CNZ->(MsUnlock())
	   				EndIf
	   				CNZ->(DbSkip())
	   			EndDo
			EndIf
			For i := 1 To Len(aRateios)
				If RecLock("CNZ",.T.)
					CNZ->CNZ_FILIAL := xFilial("CNZ")
					CNZ->CNZ_CONTRA := CND->CND_CONTRA
					CNZ->CNZ_REVISA := CND->CND_REVISA
					CNZ->CNZ_CODPLA := CND->CND_NUMERO
					CNZ->CNZ_NUMMED := CND->CND_NUMMED
					CNZ->CNZ_CLIENT := CND->CND_CLIENT
					CNZ->CNZ_LOJACL := CND->CND_LOJACL 
					CNZ->CNZ_ITCONT := aRateios[i][1]
					CNZ->CNZ_ITEM	:= aRateios[i][2]
					CNZ->CNZ_PERC	:= aRateios[i][3]
					CNZ->CNZ_CC		:= aRateios[i][4]
					CNZ->CNZ_VALOR1	:= aRateios[i][5]
					CNZ->CNZ_VALOR2	:= aRateios[i][6]
					CNZ->CNZ_VALOR3	:= aRateios[i][7]
					CNZ->CNZ_VALOR4	:= aRateios[i][8]
					CNZ->CNZ_VALOR5	:= aRateios[i][9]
					CNZ->(MsUnlock())				
				EndIf
			Next i		
		EndIf		
	EndIf

End Sequence

RestOrd(aOrd,.T.)
Return lPermissao