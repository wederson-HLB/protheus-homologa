#include "Totvs.ch"

/*
Funcao      : EICSI400 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para validar o numero de adi��o e sequencia na inclus�o da SI 
Autor       : Tiago Luiz Mendon�a
Data/Hora   :      
Obs         : 
TDN         : Utilizado durante a rotina de manuten��o do Solicita��o de importa��o.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 12/07/2012
Obs         : 
M�dulo      : Importa��o.
Cliente     : Todos
*/


*------------------------*
  User Function EICSI400() 
*------------------------*

Local aItens := {} 
Local aErro  := {}

Local cAux   := ""      
Local cLog   := ""
Local cMsg   := ""
Local cParam := ""

Local m      := 0 
Local n      := 0  
Local nAdic  := 1
Local nSeq   := 1  

Local lErro  :=.T.

If ValType(ParamIXB) == "C" 
	cParam:= ParamIXB 
EndIf 
      

//Valida��o para Altera��o da SI  
  
If cParam == "ANTES_GRAVA_SW0"

	//Verifica se os campos customizados existem :  Adi��o e Sequ�ncia
	If FieldPos("W1_P_ADI") > 0 .And. FieldPos("W1_P_SEQAD") > 0 
		 		
		TRB->(DBGOTOP()) 
		While  TRB->(!EOF())     
		
			//Para valida��o da rotina os campos devem estar preenchidos.
			If !Empty(TRB->W1_P_ADI) .And. !Empty(TRB->W1_P_SEQADI)
	    
				Aadd(aItens,{TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI}) 
				
			Else  
				//Verifica se apenas um campo est� preenchido 
			   If !Empty(TRB->W1_P_ADI) .Or. !Empty(TRB->W1_P_SEQADI) 
			   		aAdd(aErro,{"1",TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI})	
			   EndIf
			   
			   //Verifica se os dois estiverem em branco
			   If Empty(TRB->W1_P_ADI) .And. Empty(TRB->W1_P_SEQADI) 
			   		aAdd(aErro,{"2",TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI})	
			   EndIf
			
			EndIf	
		
	    	n++ 
	   
			TRB->(DBSKIP())
 
  		EndDo 
                            
  		// aItens :  1.Item / 2.Qtd / 3.Adicao / 4.Sequencia
  
  		//Verifica se alguma adi��o ou sequencia foi preenchida
  		If Len(aItens) > 0    
                                  	
         	//Ordena por adi��o + sequencia
        	aSort(aItens,,,{|x,y| x[3]+x[4] < y[3]+y[4]})
        	
        	For i:=1 to len(aItens)
        	
        		If ChkCpo(aItens[i][3]) $ "Branco/Numero/000"  .Or. Len(Alltrim(aItens[i][3])) <> 3
        			aAdd(aErro,{"1",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})		
        		EndIf
        		
        		If ChkCpo(aItens[i][4]) $ "Branco/Numero/000" .Or. Len(Alltrim(aItens[i][4])) <> 3 
        			aAdd(aErro,{"1",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        		EndIf
    
        	
        	Next   
        	     
        	// Se nenhum erro tipo 1 e 2 encontrado, validar adi��es e sequencias
        	If Len(aErro) == 0   
        	
        		//Ordena por adi��o + sequencia
           		aSort(aItens,,,{|x,y| x[3]+x[4] < y[3]+y[4]})
        	
        		For i:=1 to len(aItens)
        	    	               
        	    	// Valida a sequencia da adi��o
        			If Val(aItens[i][3]) ==  nAdic
        				          
        				// Valida a sequencia da sequencia
        				If Val(aItens[i][4]) == nSeq                            
        		                  					
        					nSeq++
        					
        				Else	
        		    		    
        		    	 	aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        		    	 	 
        		    	EndIf
        		    	
        		    Else      
        		    
        		        // Verifica a numeracao da proxima adi��o
        		    	If Val(aItens[i][3]) == nAdic + 1
        					nAdic++
        					nSeq:=1   
        					
        					// Valida a sequencia da sequencia
        			   		If Val(aItens[i][4]) == nSeq                            
        		                  					
        				   		nSeq++
        					
        			   		Else	
        		    		    
        		    	 		aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        		    	 	 
        		    		EndIf
        					                    					       				
        				Else
        					aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        				EndIf	
        			        
        			EndIf
    
        	
        		Next                      
        	
        	
        	EndIf          
                      
        EndIf 
                    
        // aErro :  1.Tipo /2.Item / 3.Qtd / 4.Adicao / 5.Sequencia 
        
        //Conta quantos erros tipo 2 existem
		For i:=1 to len(aErro)
			If aErro[i][1]=="2"
				m++
			EndIf
		Next 
			       
		//Caso todos os erros sejam tipo 2 ( adic e seq em branco ) n�o deve ser mostrado mensagem de erro
		//n - todos os itens da SI, m - todos os erros tipo 2
		If m==n
			lErro:=.F.
		Endif           
                       
		If Len(aErro)>0  .And. lErro
		            
		    cMsg:="Diverg�ncia nas adi��es."	
			     
		     
			For i:=1 to Len(aErro)
			                        
			                        
				// Adi��o ou sequencia em branco
				If aErro[i][1] == "1"
					
					cLog+=" Adi��o: "+ChkCpo(aErro[i][4])+" | Seq. : "+ChkCpo(aErro[i][5])+"  | Item : "+aErro[i][2]+" Qtd "+Alltrim(Str(aErro[i][3]))+"  "+Chr(13)+Chr(10) 
					 
				EndIf     
				             
				// Adi��o e sequencia em branco
				If aErro[i][1] == "2"
				                     
				   cLog+= "Existe linha(s) da solicita��o de importa��o sem adi��o e sequencia"+Chr(13)+Chr(10)
				    
				EndIf 

				  
				If aErro[i][1] == "3"    
				
					cLog+= " Erro na adi��o "+alltrim(aErro[i][4])+" sequencia "+alltrim(aErro[i][5])+Chr(13)+Chr(10)
				
				EndIf     
			
			Next			
		   
			MsgAlert(cMsg,"HLB BRASIL") 
			EecView(cLog,"Detalhes da diverg�ncia encontrada") 
		      
			//lValid:= .F.  - TLM - 26/07/2012 Sempre grava
			lValid:= .T.     
		
		EndIf

    EndIf    
	
EndIf    


//Valida��o para Inclus�o da SI

If cParam == "DEPOIS_TELA_INCLUI"

	//Verifica se os campos customizados existem :  Adi��o e Sequ�ncia
	If FieldPos("W1_P_ADI") > 0 .And. FieldPos("W1_P_SEQAD") > 0      
	
		If nOpcA == 1 
			 		
			TRB->(DBGOTOP()) 
			While  TRB->(!EOF())     
		
				//Para valida��o da rotina os campos devem estar preenchidos.
				If !Empty(TRB->W1_P_ADI) .And. !Empty(TRB->W1_P_SEQADI)
	    
					Aadd(aItens,{TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI}) 
				
				Else     
				
					// Erro 1 - Verifica se apenas um campo est� preenchido 
			   		If !Empty(TRB->W1_P_ADI) .Or. !Empty(TRB->W1_P_SEQADI) 
			   			aAdd(aErro,{"1",TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI})	
			   		EndIf
			   
			   		// Erro 2 - Verifica se os dois estiverem em branco
			   		If Empty(TRB->W1_P_ADI) .And. Empty(TRB->W1_P_SEQADI) 
			   			aAdd(aErro,{"2",TRB->W1_COD_I,TRB->W1_QTDE,TRB->W1_P_ADI,TRB->W1_P_SEQADI})	
			   		EndIf
			
				EndIf	
		
	    		n++ 
	   
				TRB->(DBSKIP())
 
  			EndDo 
                            
  			// aItens :  1.Item / 2.Qtd / 3.Adicao / 4.Sequencia
  
  			//Verifica se alguma adi��o ou sequencia foi preenchida
  	   		If Len(aItens) > 0 
                                  	
         		//Ordena por adi��o + sequencia
        		aSort(aItens,,,{|x,y| x[3]+x[4] < y[3]+y[4]})
        	
        		For i:=1 to len(aItens)
        	
        			If ChkCpo(aItens[i][3]) $ "Branco/Numero/000"  .Or. Len(Alltrim(aItens[i][3])) <> 3
        				aAdd(aErro,{"1",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})		
        			EndIf
        		
        			If ChkCpo(aItens[i][4]) $ "Branco/Numero/000" .Or. Len(Alltrim(aItens[i][4])) <> 3 
        				aAdd(aErro,{"1",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        	   		EndIf
    
        	
        		Next   
        	     
        		// Se nenhum erro tipo 1 e 2 encontrado, validar adi��es e sequencias
        		If Len(aErro) == 0   
        	
        			//Ordena por adi��o + sequencia
           			aSort(aItens,,,{|x,y| x[3]+x[4] < y[3]+y[4]})
        	
        			For i:=1 to len(aItens)
        	    	               
        	    		// Valida a sequencia da adi��o
        				If Val(aItens[i][3]) ==  nAdic
        				          
        					// Valida a sequencia da sequencia
        					If Val(aItens[i][4]) == nSeq                            
        		                  					
        						nSeq++
        					
        					Else	
        		    		    
        		    	 		aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        		    	 	 
        		    		EndIf
        		    	
        		    	Else      
        		    
        		        	// Verifica a numeracao da proxima adi��o
        		    		If Val(aItens[i][3]) == nAdic + 1
        					 
        						nAdic++
        						nSeq:=1 
      						
        						// Valida a sequencia da sequencia
        						If Val(aItens[i][4]) == nSeq                            
        		                  					
        							nSeq++
        					
        			   			Else	
        		    		    
        		    	 			aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
        		    	 	 
        		    			EndIf
        					            
				
	        				Else
	        					aAdd(aErro,{"3",aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4]})
	        				EndIf	
	        			        
	        			EndIf
	    
	        	
	        		Next                      
	        	
	        	
	        	EndIf          
	                      
	        EndIf 
                    
        	// aErro :  1.Tipo /2.Item / 3.Qtd / 4.Adicao / 5.Sequencia
  
			//Conta quantos erros tipo 2 existem
			For i:=1 to len(aErro)
				If aErro[i][1]=="2"
			    	m++
				EndIf
			Next 
			       
			//Caso todos os erros sejam tipo 2 ( adic e seq em branco ) n�o deve ser mostrado mensagem de erro
			//n - todos os itens da SI, m - todos os erros tipo 2
			If m==n
				lErro:=.F.
			Endif           
               
        
			If Len(aErro)>0 .And. lErro
		            
		    	cMsg:="Diverg�ncia nas adi��es."	
			     
		     
				For i:=1 to Len(aErro)
			                        
			                        
					// Adi��o ou sequencia em branco
					If aErro[i][1] == "1"
						
						cLog+=" Adi��o: "+ChkCpo(aErro[i][4])+" | Seq. : "+ChkCpo(aErro[i][5])+"  | Item : "+aErro[i][2]+" Qtd "+Alltrim(Str(aErro[i][3]))+"  "+Chr(13)+Chr(10) 
						 
					EndIf     
					             
					// Adi��o e sequencia em branco
					If aErro[i][1] == "2"
					                     
					   cLog+= "Existe linha(s) da solicita��o de importa��o sem adi��o e sequencia"+Chr(13)+Chr(10)
					    
					EndIf 
	
					  
					If aErro[i][1] == "3"    
					
						cLog+= " Erro na adi��o "+alltrim(aErro[i][4])+" sequencia "+alltrim(aErro[i][5])+Chr(13)+Chr(10)
					
					EndIf     
				
				Next
				
							   
				MsgAlert(cMsg,"HLB BRASIL") 
				EecView(cLog,"Detalhes da diverg�ncia encontrada") 
				
				//lLoop:= .T. TLM - 26/07/2012 Sempre grava 	
				lLoop:= .F.   
				
			Else                                                                                                                                                 
				lLoop:= .F.   
			EndIf
	
	    
		Elseif nOpcA == 3	 
		     
		    lLoop:= .F.  
			
		EndIf	
		
	EndIf	   
	        
	
EndIf

Return .T.
             
*------------------------------*
 Static Function ChkCpo(cCpo) 
*------------------------------*

If Empty(Alltrim(cCpo)) 
	cCpo:="Branco"
ElseIf Len(Alltrim(cCpo)) <> 3
    cCpo:= "Numero caracteres inv�lido." 
ElseIf cCpo == "000"   
	cCpo:= "000 inv�lida."  
EndIf            

Return cCpo

