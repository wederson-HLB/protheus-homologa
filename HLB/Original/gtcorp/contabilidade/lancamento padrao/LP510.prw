#include "rwmake.ch"

*-------------------*
User Function LP510()
*-------------------*
Local cRet := ""

Local aArea := SE2->(GetArea("SE2"))

//Array que recebe os parâmetros informados.
Local cSeq  := PARAMIXB[1]
Local cTipo := PARAMIXB[2]

If cSeq == "01"

	//Centro de Custo Débito
	If cTipo == "CCD"
			
		//Verifica se é lançamento de multipla natureza
		If SE2->E2_MULTNAT <> "2"
			SE2->(DbSetOrder(1))
			If SE2->(DbSeek(xFilial("SE2")+SEV->EV_PREFIXO+SEV->EV_NUM))	
				cRet := SE2->E2_CCD
			EndIf
		Else
			cRet := SE2->E2_CCD
		EndIf
			
	//Item Contábil Débito		
	ElseIf cTipo == "ITD"

		//Verifica se é lançamento de multipla natureza
		If SE2->E2_MULTNAT <> "2"
			SE2->(DbSetOrder(1))
			If SE2->(DbSeek(xFilial("SE2")+SEV->EV_PREFIXO+SEV->EV_NUM))	
				cRet := SE2->E2_ITEMD
			EndIf
		Else
			cRet := SE2->E2_ITEMD
		EndIf

	//Classe Valor Débito		
	ElseIf cTipo == "CVD"

		//Verifica se é lançamento de multipla natureza
		If SE2->E2_MULTNAT <> "2"
			SE2->(DbSetOrder(1))
			If SE2->(DbSeek(xFilial("SE2")+SEV->EV_PREFIXO+SEV->EV_NUM))	
				cRet := SE2->E2_CLVLDB
			EndIf
		Else
			cRet := SE2->E2_CLVLDB
		EndIf
		
	EndIf
			
EndIf	

RestArea(aArea)

Return cRet