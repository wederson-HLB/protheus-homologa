#Include "rwmake.ch"    

/*
Funcao      : GTFIN018
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento finalidade do lote para pagamento de folha banco Itau.
Autor		: Anderson Arrais
Data/Hora   : 10/08/2016
Módulo      : Financeiro / RH.
*/                      

*------------------------------*
 User Function GTFIN018(nOpc)   
*------------------------------*   
Local cRet := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalidade so lote				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
	If MV_PAR01 == 1 		//Adiantamento
		cRet := "02"
	ElseIf MV_PAR02 == 1    //Folha
		cRet := "01"
	ElseIf MV_PAR03 == 1    //1 parcela 13
		cRet := "04"
	ElseIf MV_PAR04 == 1    //2 parcela 13
		cRet := "04"
	ElseIf MV_PAR05 == 1    //Ferias
		cRet := "07"
	ElseIf MV_PAR06 == 1    //Extra
		cRet := "10"
	ElseIf MV_PAR28 == 1    //Rescisão
		cRet := "08"
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalidade em detalhe / historico  			 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 
	If MV_PAR01 == 1 		//Adiantamento
		cRet := "HP06"
	ElseIf MV_PAR02 == 1    //Folha
		cRet := "HP01"
	ElseIf MV_PAR03 == 1    //1 parcela 13
		cRet := "HP03"
	ElseIf MV_PAR04 == 1    //2 parcela 13
		cRet := "HP03"
	ElseIf MV_PAR05 == 1    //Ferias
		cRet := "HP02"
	ElseIf MV_PAR06 == 1    //Extra
		cRet := "HP14"
	ElseIf MV_PAR28 == 1    //Rescisão
		cRet := "HP07"
	EndIf
EndIf

Return(cRet)