#include "rwmake.ch"

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar o valor do PIS.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 03/07/09
*/

User Function LP9504VAL()
Local nResult:=0
Local cCfoP,cTes
Local aArea := SaveOrd("SD1")

//cTes := "1B6/1B7/1B8/1C1/1C2/1C3/1C4/1C5/1C6/1C7/1C8/1C9"
cCfoP:= "3101/3102/3551/3949"

IF cEmpAnt $ "XC" //DIALOGIC  JSS - Ajustado para atender o caso 025792
	IF SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		IF alltrim(SD1->D1_CF) $ (cCfoP)
			SWN->(DbSetOrder(2))
			IF SWN->(DbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))
				WHILE SWN->(!EOF()) .And. SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE
					nResult+=SWN->WN_VLRPIS
					SWN->(DbSkip())
				ENDDO
			ENDIF
		ENDIF
	ENDIF
ENDIF
If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))// JSS - Ajustado para atender o caso 015937
	IF alltrim(SD1->D1_CF) $ (cCfoP)
		SWN->(DbSetOrder(2))
		If SWN->(DbSeek(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))
			While SWN->(!EOF()) .And. xFilial("SWN")+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE
				nResult+=SWN->WN_VLRPIS
				SWN->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestOrd(aArea)
Return(nResult)

