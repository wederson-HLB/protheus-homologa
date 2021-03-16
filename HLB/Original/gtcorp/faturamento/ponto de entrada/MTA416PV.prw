#include "topconn.ch"
#include "rwmake.ch"  

/*
Funcao      : MTA416PV 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada Alteração do Pedido na aprovação do orçamento.
Autor       : Jean Victor Rocha
Data/Hora   : 24/04/2015
Obs         : 
*/
*----------------------*
User Function MTA416PV()
*----------------------* 

If SCJ->(FieldPos("CJ_P_NUM")) <> 0 .and. SCJ->(FieldPos("CJ_P_OVE")) <> 0
	If !EMPTY(SCJ->CJ_P_NUM) .or. !EMPTY(SCJ->CJ_P_OVE)
		If M->(FieldPos("C5_P_NUM")) <> 0
			M->C5_P_NUM := SCJ->CJ_P_NUM
		EndIf 
		If M->(FieldPos("C5_MDCONTR")) <> 0
			M->C5_MDCONTR := SCJ->CJ_P_CONTR
		EndIf
	EndIf
EndIf
                                 
//JVR - 02/02/17 - Atualização da data de entrega para todas as linhas, com a data base do sistema
_aCols[PARAMIXB][15] := ddatabase

Return .T. 