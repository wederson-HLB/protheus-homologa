#Include "rwmake.ch"    

/*
Funcao      : GTFIN019
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento do endereço para saber se leva o de cobrança ou o principal
Autor		: Anderson Arrais
Data/Hora   : 19/08/2016
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN019(nOpc)   
*------------------------------*   
Local cRet := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereço do cliente				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
	If EMPTY(SA1->A1_ENDCOB)
		cRet := SUBSTR(SA1->A1_END,1,40)
	Else
		cRet := SUBSTR(SA1->A1_ENDCOB,1,40)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Bairro do cliente								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2
	If EMPTY(SA1->A1_BAIRROC)
		cRet := SUBSTR(SA1->A1_BAIRRO,1,40)
	Else
		cRet := SUBSTR(SA1->A1_BAIRROC,1,40)
	EndIf                        
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CEP do cliente								 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 
	If EMPTY(SA1->A1_CEPC)
		cRet := STRTRAN(SA1->A1_CEP,"-","")
	Else
		cRet := STRTRAN(SA1->A1_CEPC,"-","")
	EndIf   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Municipio do cliente							 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 
	If EMPTY(SA1->A1_MUNC)
		cRet := SUBSTR(SA1->A1_MUN,1,15)
	Else
		cRet := SUBSTR(SA1->A1_MUNC,1,15)
	EndIf    
EndIf
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estado do cliente							 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5 
	If EMPTY(SA1->A1_ESTC)
		cRet := SUBSTR(SA1->A1_EST,1,2)
	Else
		cRet := SUBSTR(SA1->A1_ESTC,1,2)
	EndIf 
EndIf

Return(cRet)