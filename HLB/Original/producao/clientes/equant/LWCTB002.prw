#include "totvs.ch"

/*                                                                                                          
Funcao      : LWCTB002   
Parametros  :

  PARAMIXB -> cLanc  ->  Lançamento padrão  ( 650,610,500, etc )
  PARAMIXB -> cTipo  ->  Representa o tipo do campo do LP

Objetivos   : Retornar a fatura no Historico
Autor       : Tiago L Mendonça
Obs.        :   
Data        : 23/08/2013
*/       
 
*------------------------------*
User Function LWCTB002()
*------------------------------*
             
Local xRet	:= "" 
Local cSeq  := ""
Local cTipo := ""

//Array que recebe os parâmetros informados.
cLanc  := PARAMIXB[1]
cTipo  := PARAMIXB[2]

If !cEmpAnt $ "LX/LW"
	xRet:= ""
	Return (xRet)
EndIf

If cLanc $ "650"
	Do Case
		Case  cTipo =="HST"
		
			SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO           
	    	If SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
   				If SF1->(FieldPos("F1_P_FATUR"))>0     
       				If !Empty(SF1->F1_P_FATUR)  
       					xRet:= " FATURA "+SF1->F1_P_FATUR    
		   			Else
		   				xRet:= " " 
		   			EndIf
		   		Else
			   		xRet:= ""    
				EndIf
			EndIf
		//RRP - 16/07/2015 - Tratamento por filial. Descentralização. Chamado 027965.
		Case  cTipo =="DBT"
			
			//SAO PAULO
			If cFilAnt =='01' .OR. cFilAnt =='04' .OR. cFilAnt =='06'
		   			xRet:= "11320021"
			//PARANA
			ElseIf cFilAnt =='05'
		   			xRet:= "11320027"
			//RIO GRANDE DO SUL
			ElseIf cFilAnt =='07'
		   			xRet:= "11320035"
			//SANTA CATARINA
			ElseIf cFilAnt =='08'
		   			xRet:= "11320033"
			//RIO DE JANEIRO
			ElseIf cFilAnt =='11'
		   			xRet:= "11320022"
			//RIO DE JANEIRO
			ElseIf cFilAnt =='12'
		   			xRet:= "11320023"
			//GOIAS
			ElseIf cFilAnt =='13'
		   			xRet:= "11320029"
			//ESPIRITO SANTO
			ElseIf cFilAnt =='18'.OR. cFilAnt =='30'
		   			xRet:= "11320030"
			//MINAS GERAIS
			ElseIf cFilAnt =='19'
		   			xRet:= "11320044"
			//DISTRITO FEDERAL
			ElseIf cFilAnt =='23'
		   			xRet:= "11320032"
		    //CEARA
			ElseIf cFilAnt =='25'
		   			xRet:= "11320045"
			//PERNAMBUCO
			ElseIf cFilAnt =='28'
		   			xRet:= "11320046"
			//BAHIA
			ElseIf cFilAnt =='31'
		   			xRet:= "11320047"
			EndIf
	EndCase
EndIf

If cLanc $ "500"
	Do Case
		Case  cTipo =="HST"
		
			If !Empty(SE2->E2_P_FATUR)  
				xRet:= " FATURA "+SE2->E2_P_FATUR    
	   		Else
	   			xRet:= " " 
		   	EndIf
	EndCase
EndIf
//RRP - 16/07/2015 - Tratamento por filial. Descentralização. Chamado 027965.  
If cLanc $ "610"
	Do Case
		Case cTipo == "CRD"
			
			//SAO PAULO
			If cFilAnt =='01' .OR. cFilAnt =='04' .OR. cFilAnt =='06'
		   			xRet:= "21116019"
			//PARANA
			ElseIf cFilAnt =='05'
		   			xRet:= "21116033"
			//RIO GRANDE DO SUL
			ElseIf cFilAnt =='07'
		   			xRet:= "21116031"
			//SANTA CATARINA
			ElseIf cFilAnt =='08'
		   			xRet:= "21116034"
			//RIO DE JANEIRO
			ElseIf cFilAnt =='11'
		   			xRet:= "21116023"
			//RIO DE JANEIRO
			ElseIf cFilAnt =='12'
		   			xRet:= "21116022"
			//GOIAS
			ElseIf cFilAnt =='13'
		   			xRet:= "21116037"
			//ESPIRITO SANTO
			ElseIf cFilAnt =='18'
		   			xRet:= "21116030"
			//MINAS GERAIS
			ElseIf cFilAnt =='19'
		   			xRet:= "21116036"
			//DISTRITO FEDERAL
			ElseIf cFilAnt =='23'
		   			xRet:= "21116032"
		    //CEARA
			ElseIf cFilAnt =='25'
		   			xRet:= "21116038"
			//PERNAMBUCO
			ElseIf cFilAnt =='28'
		   			xRet:= "21116039"
			//SERRA
			ElseIf cFilAnt =='30'
					xRet:= "21116020"
			//BAHIA
			ElseIf cFilAnt =='31'
		   			xRet:= "21116040"
			EndIf
	EndCase
EndIf


Return (xRet)