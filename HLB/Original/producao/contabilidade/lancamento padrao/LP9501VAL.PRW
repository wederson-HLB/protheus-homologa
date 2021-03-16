#include "rwmake.ch"     

/*
Funcao      : LP9501VAL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retornar o valor da mercadoria de importação, caso tenha COFINS majorada, soma ao valor
Autor       : Anderson de Oliveira Arrais
Data/Hora   : 05/09/2013
Módulo      : EIC
*/
*-------------------------*
User Function LP9501VAL()
*-------------------------*       
Local nResult:= SF1->F1_VALMERC+SF1->F1_DESPESA
Local aArea := SaveOrd("SD1")

SD1->(DbSetOrder(1))
If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))  // JSS - Ajustado para atender o caso 015937
	If SD1->D1_VALCMAJ > 0
		While SD1->(!EOF()) .And. xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			nResult+=SD1->D1_VALCMAJ
			SD1->(DbSkip())
		EndDo
	EndIf
EndIf
RestOrd(aArea)

Return(nResult)