#include "totvs.ch"

/*
  PARAMIXB -> cSeq  -> Representa a sequencia do lançamento padrão
  PARAMIXB -> cTipo -> Representa o tipo do campo do LP
  	
  	Nomenclatura do cTipo:
  	
  		Conta Credito 			-> CC
  		Conta Debito 			-> CD
  		Valor 					-> VAL
  		Centro de Custo Credito -> CCC
  		Centro de Custo Debito  -> CCD
  		Item Conta Credito 		-> ITC
  		Item Conta Debito 		-> ITD
  		Classe Valor Credito 	-> CLC
  		Classe Valor Debito 	-> CLD
  		Historico				-> HST
  		Historico Aglutinado	-> HTG
*/

/*                                                                                                          
Funcao      : LP508
Objetivos   : Padronização do Lançamento Padrão 508  
Autor       : Renato Rezende
Obs.        :   
Data        : 20/05/2013
*/       
    
*------------------------------*
User Function LP508()
*------------------------------*
             
Local xRet	:= "" 
Local cSeq  := ""
Local cTipo := ""

//Array que recebe os parâmetros informados.
cSeq  := PARAMIXB[1]
cTipo := PARAMIXB[2]

//Se a sequencia do lançamento padrão 508 for igual a 01
If cSeq == "01"
     
	Do Case
	
		Case cTipo == "CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
		
			xRet:= 0 
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
		
		Case cTipo =="CCC"
		
			xRet:= 0
			
		Case cTipo =="CCD" 
		
			xRet:= 0    
			
		Case cTipo =="ITC"  
		
			xRet:= 0     
			
		Case cTipo =="ITD"    
		
			xRet:= 0        
			
		Case cTipo =="CLC"     
		
			xRet:= 0  
			
		Case cTipo =="CLD"   
		
			xRet:= 0
		Case cTipo =="HST"
		
			// Pergunte se esta Aglutinando Lançamento Contabil no F12			
			If MV_PAR07 == 2 // 1 - Sim / 2 - Nao  
		
				If SE2->E2_MULTNAT == "1" .AND. SEV->EV_RATEICC == "1"
			
			 		xRet:= "VALOR REF "+TRIM(SE2->(E2_TIPO+E2_NUM))+" "+ALLTRIM(SA2->A2_NOME)+" - "+Alltrim(POSICIONE("SED",1,XFILIAL("SED")+SEZ->EZ_NATUREZ,"ED_DESCRIC"))+" - "+ALLTRIM(SE2->E2_HIST) 
			 	                          
				EndIf
				
			Else
				
				xRet:= "AGL - VALOR REF "+TRIM(SE2->(E2_TIPO+E2_NUM))+" "+ALLTRIM(SA2->A2_NOME)+" - "+Alltrim(POSICIONE("SED",1,XFILIAL("SED")+SE2->E2_NATUREZ,"ED_DESCRIC"))+" - "+ALLTRIM(SE2->E2_HIST) 
			
			EndIf
			
		Case cTipo =="HTG"   
		
			// Pergunte se esta Aglutinando Lançamento Contabil no F12			
			If MV_PAR07 == 2 // 1 - Sim / 2 - Nao  
		
				If SE2->E2_MULTNAT == "1" .AND. SEV->EV_RATEICC == "1"
			
			 		xRet:= "VALOR REF "+TRIM(SE2->(E2_TIPO+E2_NUM))+" "+ALLTRIM(SA2->A2_NOME)+" - "+Alltrim(POSICIONE("SED",1,XFILIAL("SED")+SEZ->EZ_NATUREZ,"ED_DESCRIC"))+" - "+ALLTRIM(SE2->E2_HIST) 
			 	                          
				EndIf
				
			Else
				
				xRet:= "AGL - VALOR REF "+TRIM(SE2->(E2_TIPO+E2_NUM))+" "+ALLTRIM(SA2->A2_NOME)+" - "+Alltrim(POSICIONE("SED",1,XFILIAL("SED")+SE2->E2_NATUREZ,"ED_DESCRIC"))+" - "+ALLTRIM(SE2->E2_HIST) 
			
			EndIf
		
	EndCase

EndIf

Return (xRet)