#include "TOTVS.CH"

/*
Funcao      : GTCORP26()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Calculo do dollar para medição com moeda 2.
Autor       : Matheus Massarotto
Data/Hora   : 05/06/2012
*/
        
*------------------------*
 User Function GTCORP26()
*------------------------*

Local nPos1   	:= 0 
Local nPos2   	:= 0
Local nPos3   	:= 0
Local nMoedaCND	:= 0
  
nPos1  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNE_QUANT' }) 
nPos2  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNE_VLUNIT'})
nPos3  :=  aScan(aHeader, { |x| Alltrim(x[2]) == 'CNE_VLTOT' })  

//DbSelectArea("CN9")
//CN9->(DbSetOrder(1))
//if DbSeek(xFilial("CN9")+M->CNA_CONTRA+M->CNA_REVISA)
	nMoedaCND:=M->CND_MOEDA
//endif

If nMoedaCND<>0
	If Inclui  
	
		If nMoedaCND == 1
			 
		    // Valor unitario	 
			aCols[n][nPos2] := M->CNE_P_BRL
			
			//Valor total
		 	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
		    
	    ElseIf nMoedaCND == 2 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,2,dDataBase)  //aCols[nPos5][nPos4] * SM2->M2_MOEDA2 // M->CNE_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]      
		    
	    ElseIf nMoedaCND == 3 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,2,dDataBase)   //aCols[nPos5][nPos4] * SM2->M2_MOEDA3 // M->CNE_P_BRL  
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]	    
		    
		ElseIf nMoedaCND == 5 
	    	
	    	// Valor unitario	                        //RRP - alterado para pegar da memória.
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,5,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA5 // M->CNE_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]    
		
		EndIf
		
	Else  
	          	
		If nMoedaCND == 1
			 
		    // Valor unitario	 
			aCols[n][nPos2] := M->CNE_P_BRL   
			
			//Valor total
		 	aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
		    
	    ElseIf nMoedaCND == 2 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,2,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA2 // M->CNE_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]     
		    
		ElseIf nMoedaCND == 3 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,2,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA3 // M->CNE_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]         
		    
		ElseIf nMoedaCND == 5 
	    	
	    	// Valor unitario	 
			aCols[n][nPos2] :=  xMoeda(M->CNE_P_BRL ,1,5,dDataBase) //aCols[nPos5][nPos4] * SM2->M2_MOEDA5 // M->CNE_P_BRL   
			
			//Valor total
		    aCols[n][nPos3] := aCols[n][nPos2] * aCols[n][nPos1]
	 
		     
		EndIf   
		
	
	EndIf
Endif

Return .T.  