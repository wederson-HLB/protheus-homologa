#include "rwmake.ch"
/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: LP590ITEM()
Parametros  : Nenhum
Retorno     : Nil
Objetivos 	: Função que retorna o codigo do Item contabil.
Data      	: 11/01/2016
----------------------------------------------------------------------------------------------------------------------------------------------
*/
*------------------------*
User Function LP590ClVl()
*------------------------*

Local cClVl := "" 
                           
If cEmpAnt $ '49'
	If AllTrim(SE2->E2_NATUREZ)$"4211/4212/4213"    /// PIS DE TERCEIROS/// CONFIS  DE TERCEIROS/// CLLS DE TERCEIROS
		cClVl:="120"	      
	EndIf 
EndIf 

Return(cClVl)

