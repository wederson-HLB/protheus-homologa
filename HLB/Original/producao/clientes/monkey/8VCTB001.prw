#include "totvs.ch"

/*                                                                                                          
Funcao      : 8VCTB001
Objetivos   : HISTORICO para lançamentos padrões da empresa SurveyMonkey
Autor       : Renato Rezende
Obs.        :  
Empresa		: SurveyMonkey
Módulo		: Contabil    
Data        : 13/07/2015
*/

*------------------------------*
 User Function 8VCTB001(cTab)
*------------------------------*
             
Local cRet		:= ""

Do Case
	//Contas a Receber
	Case cTab == "SE1"
		cRet := Alltrim(SE1->E1_CLIENTE)+"@"+Alltrim(SE1->E1_NUM)+"@"
	//Contas a Pagar
	Case cTab == "SE2"
   		cRet := Alltrim(SE2->E2_FORNECE)+"#"+Alltrim(SE2->E2_NUM)+"#"
 	//Capa NF Entrada
	Case cTab == "SF1"
		cRet := Alltrim(SF1->F1_FORNECE)+"#"+Alltrim(SF1->F1_DOC)+"#"
	//Itens NF Entrada
	Case cTab == "SD1"
		cRet := Alltrim(SD1->D1_FORNECE)+"#"+Alltrim(SD1->D1_DOC)+"#"	
	//Capa NF Saída
	Case cTab == "SF2"
		cRet := Alltrim(SF2->F2_CLIENTE)+"@"+Alltrim(SF2->F2_DOC)+"@"
	//Itens NF Saida
	Case cTab == "SD2"
		cRet := Alltrim(SD2->D2_CLIENTE)+"@"+Alltrim(SD2->D2_DOC)+"@"
	//Cheques
	Case cTab == "SEF"
		cRet := Alltrim(SEF->EF_FORNECE)+"@"+Alltrim(SEF->EF_TITULO)+"@"			
EndCase

Return (cRet)