#Include 'rwmake.ch'
#include 'totvs.ch'
#include 'tbiconn.ch' 
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTWRHO02  ºAutor  ³Tiago Luiz Mendonça º Data ³  10/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Generico - Validação do campo de superiro no SRA: RA_P_MATSUº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
                               
/*
Funcao      : GTWRHG01
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Validar o conteúdo inserido no campo RA_P_MATSU
Autor       : Tiago Luiz Mendonça
Data/Hora   : 19/09/12
*/


*-----------------------*
 User Function GTWRHG01()
*-----------------------*
 
Local cTable     := ""
Local cMatSup    := ""
Local cEmpSup    := ""
Local cFilSup 	 := ""

Local  oMain 
Local  oDlg	

Local lRet		 := .T.

	If !Empty(M->RA_P_MATSU)
	   			
		//Código do superior é composto por codigo da empresa + filial de origem + matricula  ex: CH01000399 
		cMatSup  := Substr(M->RA_P_MATSU,5,6)
	 	cEmpSup  := Substr(M->RA_P_MATSU,1,2)
	 	cFilSup  := Substr(M->RA_P_MATSU,3,2)
	 	cTable   := "SRA"+cEmpSup+"0"
	
		
		SM0->(DbSetOrder(1))          
  		If SM0->(DbSeek(cEmpSup+cFilSup)) 
            	
			If Select("TempSup") > 0
	  			TempSup->(DbCloseArea())	               
	   	 	EndIf    
		  
	 		aStruSRA := SRA->(dbStruct())
	    
	 		//Cria temporario da SRA do superior                        
			cQuery:=" SELECT * "
			cQuery+=" FROM "+cTable 
			cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
			cQuery+=" AND RA_MAT = '"+cMatSup+"'"  
			cQuery+=" AND RA_FILIAL = '"+cFilSup+"'"
		
	   		TCQuery cQuery ALIAS "TempSup" NEW
	
			For nX := 1 To Len(aStruSRA)
				If aStruSRA[nX,2]<>"C"
					TcSetField("TempSup",aStruSRA[nX,1],aStruSRA[nX,2],aStruSRA[nX,3],aStruSRA[nX,4])
				 EndIf
			Next nX
				
			cTMP := CriaTrab(NIL,.F.)
			Copy To &cTMP
			dbCloseArea()
			dbUseArea(.T.,,cTMP,"TempSup",.T.)    
	
		    
		    TempSup->(DbGoTop())	    
		    If TempSup->(!BOF() .and. !EOF())
	    
	         	DEFINE MSDIALOG oDlg TITLE "Colaborador selecionado" From 1,12 To 12,45 OF oMain     
	   
	   				@ 015,008 SAY "Matricula:"			Of oDlg PIXEL 
	            	@ 015,035 SAY TempSup->RA_MAT       Of oDlg PIXEL 
	            	
	            	@ 025,008 SAY "Nome:"            	Of oDlg PIXEL 
	            	@ 025,035 SAY TempSup->RA_NOME      Of oDlg PIXEL 
	            	   
	            	SM0->(DbSetOrder(1))          
	            	If SM0->(DbSeek(cEmpSup+cFilSup)) 
	            	                              	
		            	@ 035,008 SAY "Cod. / Fil:"   		Of oDlg PIXEL 
		            	@ 035,035 SAY Alltrim(SM0->M0_CODIGO)+" / "+Alltrim(SM0->M0_CODFIL)   Of oDlg PIXEL 	       
		     			@ 045,008 SAY "Empresa:"   		Of oDlg PIXEL            
		            	@ 045,035 SAY Alltrim(SM0->M0_NOME)   Of oDlg PIXEL 		     
		     
	    			EndIf             
	    
	    
	         	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())	    	
		    	
		    Else   
		    
	     		DEFINE MSDIALOG oDlg TITLE "Colaborador invalido" From 1,12 To 12,45 OF oMain       
	   
	   		   		@ 010,008 SAY "O código deve ser composto por :"	Of oDlg PIXEL 
	     	   		@ 020,008 SAY "Código da empresa [ Exemplo :Z4 ] + "  	Of oDlg PIXEL               
	     			@ 030,008 SAY "Filial [ Exemplo: 05 ] + "  	Of oDlg PIXEL     	    
	     			@ 040,008 SAY "Matricula [ Exemplo :000522 ] "  	Of oDlg PIXEL     	    
	     			@ 050,008 SAY "___________________________________________"  	Of oDlg PIXEL     
	     	   		@ 060,008 SAY " Resultado : Z405000522"  	Of oDlg PIXEL                  
	    
	    
	         	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())	    	
		    	
	            lRet:=.F.
	            
	        EndIf                         
		 
	    Else
	    	
	    	DEFINE MSDIALOG oDlg TITLE "Colaborador invalido" From 1,12 To 12,45 OF oMain        
	   
	   			@ 010,008 SAY "O código deve ser composto por :"	Of oDlg PIXEL 
	     		@ 020,008 SAY "Código da empresa [ Exemplo :Z4 ] + "  	Of oDlg PIXEL               
	     		@ 030,008 SAY "Filial [ Exemplo: 05 ] + "  	Of oDlg PIXEL     	    
	     		@ 040,008 SAY "Matricula [ Exemplo :000522 ]  "  	Of oDlg PIXEL     	    
	     		@ 050,008 SAY "___________________________________________"  	Of oDlg PIXEL     
	     		@ 060,008 SAY " Resultado : Z405000522"  	Of oDlg PIXEL     

	    
	    	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())	    	
		    	
	      	lRet:=.F.
	    
	    
	    EndIf
           
    EndIf


Return lRet 
