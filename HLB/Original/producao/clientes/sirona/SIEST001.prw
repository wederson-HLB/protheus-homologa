/*
Funcao		: SICTB001
Parametros	: Nenhum
Retorno	: Item contabil
Autor		: João.Silva
Data		: 23/04/2014                      
Módulo		: Contabil 
Cliente	: Sirona
*/

*-------------------------*
  User Function SIEST001()                
*-------------------------*

_cItemCont := " " 
_cCC	   := "4000/5000/6000/7000/8000" 

If EMPTY(SD1->D1_CONHEC)
	
	If cEmpAnt $ "SI/20" .AND. AllTrim(SD1->D1_CC) $ _cCC
		
		Do Case
				
	   		Case alltrim(SD1->D1_CC) == "4000"
		  		_cItemCont := "900013"  
		  		
	   		Case alltrim(SD1->D1_CC) == "5000"
				_cItemCont := "900012" 
				                                                 
	   		Case alltrim(SD1->D1_CC) == "6000"
		 		_cItemCont := "900015" 
		 		
	   		Case alltrim(SD1->D1_CC) == "7000"
	   			_cItemCont := "900014" 
	   			
	   		Case alltrim(SD1->D1_CC) == "8000"
				_cItemCont := "900018" 				
	   	
	   		OTHERWISE
		   		_cItemCont := " "
		   		
		EndCase  
	EndIf
EndIf
	   
Return(_cItemCont)        