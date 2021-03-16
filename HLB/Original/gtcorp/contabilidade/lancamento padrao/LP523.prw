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
*/

/*                                                                                                          
Funcao      : LP523
Objetivos   : Padronização do Lançamento Padrão 523  
Autor       : Renato Rezende
Obs.        :   
Data        : 29/01/2013
*/       

*------------------------------*
User Function LP523()
*------------------------------*
             
Local nRet  := 0
Local cSeq  := ""
Local cTipo := ""

//Array que recebe os parâmetros informados.
cSeq  := PARAMIXB[1]
cTipo := PARAMIXB[2]

//Se a sequencia do lançamento padrão 523 for igual a 03
If cSeq == "03"
     
	Do Case
	
		Case cTipo == "CC"
		
			nRet:= 0
			
		Case cTipo =="CD"
		
			nRet:= 0 
			
		Case cTipo =="VAL"
		
			nRet:= 0
			
		Case cTipo =="CCC"
		
			nRet:= 0 
			
		Case cTipo =="CCD" 
		
			nRet:= 0    
			
		Case cTipo =="ITC"  
		
			nRet:= 0      
			
		Case cTipo =="ITD"    
		
			nRet:= 0        
			
		Case cTipo =="CLC"     
		
			nRet:= 0   
			
		Case cTipo =="CLD"   
		
			nRet:= 0
		
	EndCase

//Se a sequencia do lançamento padrão 523 for igual a 05
ElseIf cSeq == "05"
     
	Do Case
	
		Case cTipo =="CC"
		
			nRet:= 0
			
		Case cTipo =="CD"
		
			nRet:= 0 
			
		Case cTipo =="VAL"
		
			If SE1->E1_EMISSAO <= CTOD("31/12/2012")
			
				If Alltrim(SE1->E1_SITUACA) == "0" .OR. Alltrim(SE1->E1_SITUACA) == "1"
					If SE1->E1_SALDO == 0
						nRet := SE1->E1_IRRF
					Else
						nRet := 0
					EndIf
				Else
					nRet := 0
				EndIf
			  	
			EndIf
			
		Case cTipo =="CCC"
		
			nRet:= 0 
			
		Case cTipo =="CCD" 
		
			nRet:= 0    
			
		Case cTipo =="ITC"  
		
			nRet:= 0      
			
		Case cTipo =="ITD"    
		
			nRet:= 0        
			
		Case cTipo =="CLC"     
		
			nRet:= 0   
			
		Case cTipo =="CLD"   
		
			nRet:= 0
		
	EndCase

EndIf

Return (nRet)