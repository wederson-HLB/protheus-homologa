#Include "rwmake.ch"    

/*
Funcao      : F420SOMA
Retorno     : nRet
Objetivos   : Soma valor ao retorno SOMAVALOR() para total de lote no cnab modelo 2.
Autor       : Anderson Arrais
OBS			: Layout 240 posi��es contas a pagar.
Revis�o     : Anderson Arrais
Data/Hora   : 25/05/2018
M�dulo      : Financeiro.
*/                      

*------------------------*
 User Function F420SOMA()   
*------------------------*   

Local nRet := 0

DbSelectArea("SE2")
If FieldPos("E2_P_VRENT") > 0
	nRet := SE2->E2_SALDO+SE2->E2_SDACRES+SE2->E2_P_VRENT-SE2->E2_SDDECRE
Else
	nRet := SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE
EndIf 

Return (nRet)