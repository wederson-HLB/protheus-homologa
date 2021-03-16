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
Funcao      : LP610
Objetivos   : Padronização do Lançamento Padrão 610
Autor       : Renato Rezende
Obs.        :   
Data        : 23/08/2013
*/       
 
*------------------------------*
User Function LP610()
*------------------------------*
             
Local xRet	:= "" 
Local cSeq  := ""
Local cTipo := ""

//Array que recebe os parâmetros informados.
cSeq  := PARAMIXB[1]
cTipo := PARAMIXB[2]

//Se a sequencia do lançamento padrão 610 for igual a 01
If cSeq $ "01"
	Do Case
	
		Case cTipo =="CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
			//RRP - 21/08/2014 - Parametrização para empresa Bottega
		    If cEmpAnt $ "46"
		    	DbSelectArea("SE1")
		    	SE1->(DbSetOrder(1)) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		    	If SE1->(DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC))
		    		//Dinheiro
		    		If Alltrim(SE1->E1_TIPO) == "R$"
		    			xRet:= "11112034"
		    		//Cartão
		    		ElseIf Alltrim(SE1->E1_TIPO) == "CC"
		    			If Alltrim(SE1->E1_NOMCLI) == "AMEX"  
		    				xRet:= "11313004"
		    			//Cielo
		    			Else		    				   
		    				xRet:= "11313001"	
		    			EndIf
		    		//Cheque
		    		ElseIf Alltrim(SE1->E1_TIPO) == "CH"
		    			xRet:= "11313008"
		    		EndIf
		    	EndIf
		    EndIf
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
		
		Case  cTipo =="ITD" .OR. cTipo =="ITC"
		   
			xRet:= 0      
	EndCase
EndIf

//Se a sequencia do lançamento padrão 610 for igual a 02/03
If cSeq $ "02/03"
     
	Do Case
	
		Case cTipo =="CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
		
			xRet:= 0 
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
			
		Case cTipo =="ITD" .OR. cTipo =="ITC"     
		    If cEmpAnt $ "R7"//Shiseido
		    	If !(cFilAnt) $ "01/10"
		    	    If cFilAnt == "04"
		    			xRet := "203"
		    		ElseIf cFilAnt == "06"
		    	   		xRet := "202"
		    		ElseIf cFilAnt == "07"
		    	   		xRet := "207"
		    		ElseIf cFilAnt == "08"
			    		xRet := "208"
		    		ElseIf cFilAnt == "11"
		    			xRet := "211"
		    		ElseIf cFilAnt == "12"
		    			xRet := "212"
		    		ElseIf cFilAnt == "13"
		    			xRet := "213"
		    		ElseIf cFilAnt == "14"
		    	   		xRet := "214"
		    		EndIf
		    	
		    	Else    
		    		//TLM 17/02/2014  - Tratamento de centro de item contabil,retirada Brasil - Chamado 017144
		    		If cFilAnt $ "10"
			    		DbSelectArea("SC5")
	      				SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
	      				If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
	         				xRet := Alltrim(SC5->C5_P_ITEMC)
	         			EndIf
	         		EndIf	
		    	EndIf				
			EndIf        
	EndCase

EndIf
//Se a sequencia do lançamento padrão 610 for igual a 04/05
If cSeq $ "04/05"
     
	Do Case
	
		Case cTipo =="CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
		
			xRet:= 0 
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
		
		Case  cTipo =="ITD" .OR. cTipo =="ITC"  
		    If cEmpAnt $ "R7"//Shiseido
		    	If !(cFilAnt) $ "01/10"
		    	    If cFilAnt == "04"
		    			xRet := "203"
		    		ElseIf cFilAnt == "06"
		    	   		xRet := "202"
		    		ElseIf cFilAnt == "07"
		    	   		xRet := "207"
		    		ElseIf cFilAnt == "08"
			    		xRet := "208"
		    		ElseIf cFilAnt == "11"
		    			xRet := "211"
		    		ElseIf cFilAnt == "12"
		    			xRet := "212"
		    		ElseIf cFilAnt == "13"
		    			xRet := "213"
		    		ElseIf cFilAnt == "14"
		    	   		xRet := "214"
		    		EndIf
		    	
		    	Else 
		    		//TLM 17/02/2014  - Tratamento de centro de item contabil,retirada Brasil - Chamado 017144
		    		If cFilAnt $ "10"
		    	   		DbSelectArea("SC5")
      					SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
      			   		If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
         					xRet := Alltrim(SC5->C5_P_ITEMC)
         				EndIf    
         			EndIF	
		    	EndIf				
			EndIf     
	EndCase

EndIf
//Se a sequencia do lançamento padrão 610 for igual a 15
If cSeq == "15"
     
	Do Case
	
		Case cTipo =="CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
		
			xRet:= 0 
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
		
		Case  cTipo =="ITD" .OR. cTipo =="ITC"  
		    If cEmpAnt $ "R7"//Shiseido
		    	If !(cFilAnt) $ "01/10"
		    	    If cFilAnt == "04"
		    			xRet := "203"
		    		ElseIf cFilAnt == "06"
		    	   		xRet := "202"
		    		ElseIf cFilAnt == "07"
		    	   		xRet := "207"
		    		ElseIf cFilAnt == "08"
			    		xRet := "208"
		    		ElseIf cFilAnt == "11"
		    			xRet := "211"
		    		ElseIf cFilAnt == "12"
		    			xRet := "212"
		    		ElseIf cFilAnt == "13"
		    			xRet := "213"
		    		ElseIf cFilAnt == "14"
		    	   		xRet := "214"
		    		EndIf
		    	
		    	Else 
		    		DbSelectArea("SC5")
      				SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
      				If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
         				xRet := Alltrim(SC5->C5_P_ITEMC)
         			EndIf
		    	EndIf				
			EndIf    
	EndCase

EndIf
//Se a sequencia do lançamento padrão 610 for igual a 16
If cSeq == "16"
     
	Do Case
	
		Case cTipo =="CC"
		
			xRet:= 0
			
		Case cTipo =="CD"
		
			xRet:= 0 
			
		Case cTipo =="VAL"    
		
			xRet:= 0		
		
		Case  cTipo =="ITD" .OR. cTipo =="ITC"   
		    If cEmpAnt $ "R7"//Shiseido
		    	If !(cFilAnt) $ "01/10"
		    	    If cFilAnt == "04"
		    			xRet := "203"
		    		ElseIf cFilAnt == "06"
		    	   		xRet := "202"
		    		ElseIf cFilAnt == "07"
		    	   		xRet := "207"
		    		ElseIf cFilAnt == "08"
			    		xRet := "208"
		    		ElseIf cFilAnt == "11"
		    			xRet := "211"
		    		ElseIf cFilAnt == "12"
		    			xRet := "212"
		    		ElseIf cFilAnt == "13"
		    			xRet := "213"
		    		ElseIf cFilAnt == "14"
		    	   		xRet := "214"
		    		EndIf
		    	
		    	Else 
		    		DbSelectArea("SC5")
      				SC5->(DbSetOrder(1))//C5_FILIAL, C5_NUM
      				If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
         				xRet := Alltrim(SC5->C5_P_ITEMC)
         			EndIf
		    	EndIf				
			EndIf         
	EndCase

EndIf

Return (xRet)