#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
/*
Funcao      : IDI500MNU 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para adicionar o bot�o no aRotina do desembara�o
Autor       : Tiago Luiz Mendon�a
Data/Hora   :  25/04/2011       	
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/02/2012
Obs         : 
M�dulo      : Importa��o.
Cliente     : Todos
*/

*--------------------------*
  User Function IDI500MNU()
*--------------------------*

Local aMenu    := {}  
Local lTemLote := GetMv("MV_LOTEEIC",,.F.) 
// 
             
//Rotina de atualiza��o de lote
//If cEmpAnt $ ("IS/IJ")
If SW1->(FieldPos("W1_P_LOTE" )) > 0 .and. SW1->(FieldPos("W1_P_DTLOT" )) > 0 .and. SW1->(FieldPos("W1_P_SEQT" )) > 0 // TLM - 18/04/12 -  Atualiza��o para fieldpos.
   	If Alltrim(lTemLote) $ "S/T"  // TLM - 18/04/12 - P�metro de configura��o de lote na importa��o 
		aAdd(aMenu,{"Atualiza Lote" ,"U_ISEICLOTE",0,5})      
	EndIf
EndIf 
   
//Rotina de atualiza��o de adi��o
//If cEmpAnt $ ("SI/ED")
dbSelectArea("SW1")
If SW1->(FieldPos("W1_P_SEQAD" )) > 0 .and. SW1->(FieldPos("W1_P_ADI" )) > 0 //JVR - 16/03/12 - Atualiza��o para fieldpos.
   	aAdd(aMenu,{"Atualiza adi��es" ,"U_GTEIC002",0,5})      
EndIf 

Return aMenu                    
               
/*
Funcao      : ISEICLOTE
Objetivos   : Atualizar os lotes do desembara�o.
Autor       : Tiago Luiz Mendon�a
Obs.        :   
Data        : 25/04/2011   
Cliente     : Todos
Obs         : Antiga rotina de atualiza��o de lote do cliente Promega
*/

*--------------------------*
 User Function ISEICLOTE()
*--------------------------*
Local lSeqT  := .F.

Local cChave := ""
Local cSeq   := ""
Local cItem  := ""
    
SW7->(DbSetOrder(1)) 
If SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
	
	//Chave do processo que ser� atualizado.
	cChave:=SW6->W6_HAWB+SW7->W7_CC+SW7->W7_SI_NUM  
	
	SW9->(DbSetOrder(3))
	SW9->(DbSeek(xFilial("SW9")+SW7->W7_HAWB))  
	SWV->(DbSetOrder(1))  
	
	//Verifica se o processo j� foi atualizado. 
	If SWV->(DbSeek(xFilial("SWV")+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I)) 
		MsgStop("Esse processo j� foi atualizado","HLB BRASIL")
		Return .F.  		
  	EndIf
	
	While SW7->(!EOF()) .And. SW7->W7_HAWB+SW7->W7_CC+SW7->W7_SI_NUM == cChave	
		     
		//Testa se o item possui o mesmo codigo.
		SW1->(DbSetOrder(6))
		If cItem<>SW7->W7_COD_I  
			If SW1->(DbSeek(xFilial("SW1")+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+STR(SW7->W7_QTDE,13,3)  ))
		                              
		        //Busca o primeiro item que possui sequencia preenchida
		        While Empty(SW1->W1_P_SEQT) .And. SW1->W1_SI_NUM == SW7->W7_SI_NUM
                	 SW1->(DbSkip())	        
		        EndDo    
		        
		        If !Empty(SW1->W1_P_SEQT) .And. Len(Alltrim(SW1->W1_P_SEQT)) == 3
			        
			        //Sequencia de lote preenchida
			        lSeqT :=.T.
			            
					cItem:=SW7->W7_COD_I
					cSeq :=SW1->W1_P_SEQT
		   		   		    		    	
		       		RecLock("SWV",.T.)
		       		SWV->WV_FILIAL :=xFilial("SWV")
		    		SWV->WV_PGI_NUM:=SW7->W7_PGI_NUM
		    		SWV->WV_LOTE   :=SW1->W1_P_LOTE
		    		SWV->WV_FORN   :=SW7->W7_FORN
		       		SWV->WV_QTDE   :=SW7->W7_QTDE
		       		SWV->WV_CC     :=SW7->W7_CC
		       		SWV->WV_DT_VALI:=SW1->W1_P_DTLOT
		    		SWV->WV_OBS    :=Alltrim(cUserName)+" "+DTOC(date())	    	
		       		SWV->WV_INVOICE:=SW9->W9_INVOICE
		       		SWV->WV_PO_NUM :=SW7->W7_PO_NUM
		       		SWV->WV_SI_NUM :=SW7->W7_SI_NUM 
		       		SWV->WV_COD_I  :=SW7->W7_COD_I 
		    		SWV->WV_POSICAO:=SW7->W7_POSICAO
		    		SWV->WV_REG    :=1
		    		SWV->WV_HAWB   :=SW7->W7_HAWB
		    		SWV->(MsUnlock())
		   
				EndIf
		
			Else   
	    		MsgStop("S.I. n�o encontrada, entrar em contato com o suporte.","HLB BRASIL")
	  			Return .F.  
	    
	    	EndIf
	    
	    Else
	    	/*Caso tenha itens iguais na SI eles devem estar na sequencia no arquivo integrado no SW1 conforme alinhado com cliente.  
	    	Busca o lote pela sequencia incluida no SW1,somado 1 na sequencia para encontrar o lote certo.    */
	    	If SW1->(DbSeek(xFilial("SW1")+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I+STR(SW7->W7_QTDE,13,3)+Strzero(Val(cSeq)+1,3) ))
		       
		       	If ! Empty(SW1->W1_P_SEQT) .And. Len(Alltrim(SW1->W1_P_SEQT)) == 3
		            				
					cItem:=SW7->W7_COD_I
					cSeq :=SW1->W1_P_SEQT
			   		    		    	
		       		RecLock("SWV",.T.)
		       		SWV->WV_FILIAL :=xFilial("SWV")
		    		SWV->WV_PGI_NUM:=SW7->W7_PGI_NUM
		    		SWV->WV_LOTE   :=SW1->W1_P_LOTE
		    		SWV->WV_FORN   :=SW7->W7_FORN
		       		SWV->WV_QTDE   :=SW7->W7_QTDE
		       		SWV->WV_CC     :=SW7->W7_CC
		       		SWV->WV_DT_VALI:=SW1->W1_P_DTLOT
		    		SWV->WV_OBS    :=Alltrim(cUserName)+" "+DTOC(date())	    	
		       		SWV->WV_INVOICE:=SW9->W9_INVOICE
		       		SWV->WV_PO_NUM :=SW7->W7_PO_NUM
		       		SWV->WV_SI_NUM :=SW7->W7_SI_NUM 
		       		SWV->WV_COD_I  :=SW7->W7_COD_I 
		    		SWV->WV_POSICAO:=SW7->W7_POSICAO
		    		SWV->WV_REG    :=1
		    		SWV->WV_HAWB   :=SW7->W7_HAWB
		    		SWV->(MsUnlock())
	
				EndIf               
	
			Else   
	    		MsgStop("S.I. n�o encontrada, entrar em contato com o suporte.","HLB BRASIL")
	  			Return .F.  
	    
	    	EndIf
	    
	    EndIf
	      
		SW7->(DbSkip())
	
	EndDo
	
	If lSeqT
		MsgInfo("Atualizado com sucesso.","HLB BRASIL")
    Else
    	MsgInfo("Lote n�o atualizado, verificar campo de serquencia de lote ( deve possuir 3 caracteres ex: 001)","HLB BRASIL")
    EndIf
			
Else
	MsgStop("Processo n�o encontrado.","HLB BRASIL")
EndIf

Return    

/*
Funcao      : GTEIC002
Objetivos   : Atualizar as adi��es no desembara�o.
Autor       : Tiago Luiz Mendon�a
Obs.        :   
Data        : 25/04/2011 
Cliente     : Todos
*/

*-------------------------*
 User Function GTEIC002()
*-------------------------*

Local cChave     := ""
Local cItem      := ""          
Local cAuxAdicao := ""
Local cAuxSeqAdi := ""

Local n  := 0
Local i

Local aItens := {}

If !EMPTY(SW6->W6_NF_ENT) //JVR 19/03/2012 - Inclus�o de valida��o para processos que ja possuem NF.
	MsgInfo("Processo j� possui NF.", "HLB BRASIL")
	Return .F.
EndIf
    
SW7->(DbSetOrder(1)) 
If SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB)) 
	SW8->(DbSetOrder(3))
	If SW8->(DbSeek(xFilial("SW8")+SW7->W7_HAWB))	
	    
		cChave:= SW7->W7_HAWB+SW7->W7_CC+SW7->W7_SI_NUM
	 	// W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)
	
		While SW8->(!EOF()) .And. SW8->W8_HAWB+SW8->W8_CC+SW8->W8_SI_NUM == cChave	
			     
			//Testa se o item possui o mesmo codigo.
			DbSelectArea("SW1")
			//DbOrderNickName("SW1")
			IF UPPER(Alltrim(SubStr(GetEnvServer(),1,3))) == "P11"
				SW1->(DbSetOrder(5))//JVR
			ELSE
				SW1->(DbOrderNickName("SW1CUST")) //MATHEUS RIBEIRO 26-10-2018
			ENDIF
			If cItem<>(SW8->W8_COD_I+STR(SW8->W8_QTDE,13,3))  
				
				If SW1->(DbSeek(xFilial("SW1")+SW8->W8_CC+SW8->W8_SI_NUM+SW8->W8_COD_I+STR(SW8->W8_QTDE,13,3)))
			                               
			        //Busca o primeiro item que possui sequencia preenchida
			        IF Empty(SW1->W1_P_ADI)               
	                	 MsgInfo("N�o foi encontrado adi��o para o item "+Alltrim(SW8->W8_COD_I),"HLB")
	                	 Return .F.
	                EndIf    
	                
	                IF Empty(SW1->W1_P_SEQAD)
	                	 MsgInfo("N�o foi encontrado sequencia para o item "+Alltrim(SW8->W8_COD_I),"HLB")
	                	 Return .F.
	                EndIf    
			               		    		    	
		       		RecLock("SW8",.F.)		       		
		    		SW8->W8_ADICAO  := SW1->W1_P_ADI
		    		SW8->W8_SEQ_ADI := SW1->W1_P_SEQAD
	                SW8->(MsUnlock())   

	                aAdd(aItens, {SW1->W1_P_ADI,SW1->W1_P_SEQAD})//JVR - 05/01/12 - Valida��o da Adi��o.

	                cItem:=(SW8->W8_COD_I+STR(SW8->W8_QTDE,13,3))  
	                n:=1
		
				Else           
				
		    		MsgStop("S.I. n�o encontrada, entrar em contato com o suporte.","HLB BRASIL")
		  			Return .F.  
		    
		    	EndIf
		    
		    Else
		    	/*Caso tenha dois itens com c�digos iguais e quantidade iguais*/
		    	If SW1->(DbSeek(xFilial("SW1")+SW8->W8_CC+SW8->W8_SI_NUM+SW8->W8_COD_I+STR(SW8->W8_QTDE,13,3))) 
		    		SW1->(DbSkip(n))
		    		n++     

			     	RecLock("SW8",.F.)		       		
		    		SW8->W8_ADICAO  := SW1->W1_P_ADI
		    		SW8->W8_SEQ_ADI := SW1->W1_P_SEQAD
	                SW8->(MsUnlock())   

	                aAdd(aItens, {SW1->W1_P_ADI,SW1->W1_P_SEQAD})//JVR - 05/01/12 - Valida��o da Adi��o.	                

	                cItem:=(SW8->W8_COD_I+STR(SW8->W8_QTDE,13,3))      				         
			
				EndIf
			
			EndIf

		      
			SW8->(DbSkip())
		
		EndDo
		
		MsgInfo("Atualizado com sucesso.","HLB BRASIL")
		
	EndIf		
		
Else
	MsgStop("Processo n�o encontrado.","HLB BRASIL")
EndIf       

//JVR - 05/01/12 - Valida��o das adi��es.
If Len(aItens) > 1
	
	aSort(aItens)         
	cAuxAdicao:= aItens[1][1]
	cAuxSeqAdi:= aItens[1][2]
	
	For i:=2 to Len(aItens)
 		If cAuxAdicao == aItens[i][1] .and. cAuxSeqAdi == aItens[i][2]
   			MsgInfo("Existe itens com o mesmo numero e sequecia de adi��o, favor verificar e atualizar manualmente!","HLB BRASIL")
      	EndIf                 
      	cAuxAdicao:= aItens[i][1]
      	cAuxSeqAdi:= aItens[i][2]            
  	Next i

EndIf

Return
