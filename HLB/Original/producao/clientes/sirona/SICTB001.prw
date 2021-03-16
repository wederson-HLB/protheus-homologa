
/*
Funcao      : SICTB001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor     	:
Data     	:                      
Obs         :
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Contabil 
Cliente     : Sirona
*/

*-------------------------*
  User Function SICTB001()                
*-------------------------*

_cItemCont := " " 
_cCC	   := "1000/4000/5000/6000/7000/8000/10000/11000/12000/15000/16000/17000/18000" 

If EMPTY(SD1->D1_CONHEC)
	
	If cEmpAnt $ "SI" .AND. AllTrim(SRZ->RZ_CC) $ _cCC
		
		Do Case
			Case alltrim(SRZ->RZ_CC) == "1000"
				_cItemCont := "900011"
				
	   		Case alltrim(SRZ->RZ_CC) == "4000"
		  		_cItemCont := "900013"  
		  		
	   		Case alltrim(SRZ->RZ_CC) == "5000"
				_cItemCont := "900012" 
				                                                 
	   		Case alltrim(SRZ->RZ_CC) == "6000"
		 		_cItemCont := "900015" 
		 		
	   		Case alltrim(SRZ->RZ_CC) == "7000"
	   			_cItemCont := "900014" 
	   			
	   		Case alltrim(SRZ->RZ_CC) == "8000"
				_cItemCont := "900018" 
				
			Case alltrim(SRZ->RZ_CC) == "10000"
	   	   		_cItemCont := "900020"  

			Case alltrim(SRZ->RZ_CC) == "11000"
	   	   		_cItemCont := "900017"  
	   	   		
			Case alltrim(SRZ->RZ_CC) == "12000"
		   		_cItemCont := "900016"	

			Case alltrim(SRZ->RZ_CC) == "15000"
		   		_cItemCont := "900029"
		   		
			Case alltrim(SRZ->RZ_CC) == "16000"
		   		_cItemCont := "900030"		   		

			Case alltrim(SRZ->RZ_CC) == "17000"
		   		_cItemCont := "900031"  
		   		
		 	Case alltrim(SRZ->RZ_CC) == "18000"
		   		_cItemCont := "900032"
	   		OTHERWISE
		   		_cItemCont := " "
		EndCase  
	EndIf
EndIf
	   
Return(_cItemCont)        