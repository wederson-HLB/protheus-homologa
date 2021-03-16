#include "TOTVS.CH"

/*
Funcao      : GTCORP21()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Calculo do dollar para pedidos com moeda 2.
Autor       : Matheus Massarotto
Data/Hora   : 05/06/2012
*/
        
*------------------------*
 User Function GTCORP21()
*------------------------*

Local nPos1   	:= 0 
Local nPos2   	:= 0
Local nPos3   	:= 0
Local nMoedaCN9	:= 0
  
nPos1  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNB_QUANT' }) 
nPos2  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNB_VLUNIT' })
nPos3  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNB_VLTOT' })  

//DbSelectArea("CN9")
//CN9->(DbSetOrder(1))
//if DbSeek(xFilial("CN9")+M->CNA_CONTRA+M->CNA_REVISA)
	//nMoedaCN9:=M->CN9_MOEDA
//endif

if FUNNAME()=="CNTA140"
	nMoedaCN9:=CN9->CN9_MOEDA
else
	nMoedaCN9:=M->CN9_MOEDA
endif

If nMoedaCN9<>0
	If Inclui  
	
		If nMoedaCN9 == 1
			 
		    // Valor unitario	 
			aCols[n][nPos2] := M->CNB_P_BRL
			
			//Valor total
		 	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
		    
	    ElseIf nMoedaCN9 == 2 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,2,dDataBase)  //aCols[nPos5][nPos4] * SM2->M2_MOEDA2 // M->CNB_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]      
		    
	    ElseIf nMoedaCN9 == 3 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,2,dDataBase)   //aCols[nPos5][nPos4] * SM2->M2_MOEDA3 // M->CNB_P_BRL  
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]	    
		    
		ElseIf nMoedaCN9 == 5 
	    	
	    	// Valor unitario	                        //RRP - alterado para pegar da memória.
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,5,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA5 // M->CNB_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]    
		
		EndIf
		
	Else  
	          	
		If nMoedaCN9 == 1
			 
		    // Valor unitario	 
			aCols[n][nPos2] := M->CNB_P_BRL   
			
			//Valor total
		 	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
		    
	    ElseIf nMoedaCN9 == 2 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,2,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA2 // M->CNB_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]     
		    
		ElseIf nMoedaCN9 == 3 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,2,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA3 // M->CNB_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]         
		    
		ElseIf nMoedaCN9 == 5 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNB_P_BRL ,1,5,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA5 // M->CNB_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
	 
		     
		EndIf   
		
	
	EndIf
Endif

Return .T.  