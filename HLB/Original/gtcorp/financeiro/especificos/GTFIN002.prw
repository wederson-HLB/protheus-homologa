#include "totvs.ch"

/*                                                                                                          
Funcao      : GTFIN002
Objetivos   : E5_HISTOR para Baixa a Receber e Baixa a Pagar.  
Autor       : Renato Rezende
Obs.        :   
Data        : 19/03/2013
*/

*------------------------------*
 User Function GTFIN002()
*------------------------------*
             
Local cRet		:= ""
Local cRotina	:= ""

//Retorna o nome da Rotina
cRotina := Alltrim(FunName())
Do Case
	//Contas a Receber
	//Baixas a Receber
	Case cRotina == "FINA070"
		cRet := Alltrim(SE1->E1_TIPO)+" "+Alltrim(SE1->E1_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE1->E1_NATUREZ,"ED_DESCRIC")
	//Comentado porque ao clicar no Baixas autom?ticos era posicionado no t?tulo que estava selecionado no browser e n?o no que seria baixado. 
	//Baixas Rec Automat
	//Case cRotina == "FINA110"
	//	cRet := Alltrim(SE1->E1_TIPO)+" "+Alltrim(SE1->E1_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE1->E1_NATUREZ,"ED_DESCRIC")
	//Retorno Cobran?as
	//Case cRotina == "FINA200"
	//	cRet := Alltrim(SE1->E1_TIPO)+" "+Alltrim(SE1->E1_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE1->E1_NATUREZ,"ED_DESCRIC")
	
	//Contas a Pagar
	//Baixas Pagar Man
	Case cRotina == "FINA080"
		cRet := Alltrim(SE2->E2_TIPO)+" "+Alltrim(SE2->E2_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")
	//Comentado porque ao clicar no Baixas autom?ticos era posicionado no t?tulo que estava selecionado no browser e n?o no que seria baixado.
	//Baixas Pagar Autom
	//Case cRotina == "FINA090"
	//	cRet := Alltrim(SE2->E2_TIPO)+" "+Alltrim(SE2->E2_NUM)+" - "+POSICIONE("SED",1,XFILIAL("SED")+ SE2->E2_NATUREZ,"ED_DESCRIC")
EndCase

Return (cRet)