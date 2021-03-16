#include "rwmake.ch"

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar o valor do Cofins
Autor       : Tiago Luiz Mendonça
Data/Hora   : 03/07/08
*/

User Function LP9505VAL()

Local nResult:=0
Local cCfoP,cTes

//cTes := "1B6/1B7/1B8/1C1/1C2/1C3/1C4/1C5/1C6/1C7/1C8/1C9"
cCfoP:= "3101/3102/3551/3949"

IF cEmpAnt $ "XC" //DIALOGIC  JSS - Ajustado para atender o caso 025792
	IF Alltrim(SD1->D1_CF) $ (cCfoP)
		SWN->(DbSetOrder(2))
		IF SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))
			WHILE SWN->(!EOF()) .And. SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE
				nResult+=SWN->WN_VLRCOF-SWN->WN_VLCOFM // JSS - Ajustado para atender o caso 015937
				SWN->(DbSkip())
			ENDDO
		ENDIF
	ENDIF
ENDIF
IF Alltrim(SD1->D1_CF) $ (cCfoP)
	SWN->(DbSetOrder(2))
	If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))
		While SWN->(!EOF()) .And. xFilial("SWN")+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE
			nResult+=SWN->WN_VLRCOF-SWN->WN_VLCOFM // JSS - Ajustado para atender o caso 015937
			SWN->(DbSkip())
		EndDo
	EndIf
EndIf


Return(nResult)

