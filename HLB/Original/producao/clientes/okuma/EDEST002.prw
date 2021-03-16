#INCLUDE  "protheus.ch"
#INCLUDE  "average.ch"

/*
Funcao      : EDEST002()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de transferência automatica de armazem baseado em nota fiscal de entrada
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
  

*-------------------------*                            
 User Function EDEST002()
*-------------------------*
                                                   
Local oFont
Local oTMsgBar
Local oTMsgItem2
Local oTMsgItem3 
Local oTBtnBmp1    
Local oTBtnBmp2 

Local lRet:=.F.             

Private cDoc   := "" 

Private cNota  :=space(9)
Private cSerie :=space(3) 
Private cLocDes:=space(2)   

Private oDlg
Private lOk     :=.F.
Private aBrowse := Array(0,0,0)    

Private aAuto   := {}
Private aItem   := {}  

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.


      
DEFINE MSDIALOG oDlg TITLE "Rotina de transferência automatica" FROM 000,000 TO 350,692 PIXEL   


      @ 010,010 Say "Nota :" 			OF oDlg PIXEL 

      @ 009,025 Get cNota  Size 40,10   OF oDlg PIXEL   
      
      @ 010,075 Say "Serie :"   		OF oDlg PIXEL 

      @ 009,100 Get cSerie Size 10,10  Valid  FindSF1() OF oDlg PIXEL          
      
      @ 010,130 Say "Armazem Destino :"   		OF oDlg PIXEL 

      @ 009,180 Get cLocDes Size 10,10   OF oDlg PIXEL   
      
                
      oFont := TFont():New('Courier new',,-14,.T.)
      oTMsgBar := TMsgBar():New(oDlg, ' HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
   
      oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||}) 
      oTMsgItem3 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
      
      @ 002,002 TO 030,300 LABEL "" OF oDlg PIXEL
      @ 002,303 TO 030,346 LABEL "" OF oDlg PIXEL
      @ 033,002 TO 158,346 LABEL "" OF oDlg PIXEL
                        
      oTBtnBmp1  := TBtnBmp2():New( 16, 615, 26, 26, 'reload'   ,,,,{|| If(lRet:=Valida(),oDlg:End(),"")},oDlg,'Realiza a transferência'    ,,.F.,.F. ) 
      oTBtnBmp2  := TBtnBmp2():New( 16, 645, 26, 26, 'CANCEL'   ,,,,{|| oDlg:End()},oDlg,'Cancela operação'    ,,.F.,.F. )
     
  ACTIVATE MSDIALOG oDlg  CENTERED


Return  
  
/*
Funcao      : FindSF1()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para mostrar os dados na nota de entrada
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
  
*------------------------*
 Static Function FindSF1()   
*------------------------*
                 
Local cLocal 	:= ""

Local lLocal :=.T.
Local lSD3   :=.F.

Local n      := 1   
         
//Cria objeto para dados da nota 
oBrowse := TSBrowse():New(35,04,340,120,oDlg,,16,,5)
oBrowse:AddColumn( TCColumn():New('Nota',,,{|| },{|| }) )
oBrowse:AddColumn( TCColumn():New('Serie',,,{|| },{|| }) ) 
oBrowse:AddColumn( TCColumn():New('Tipo',,,{|| },{|| }) )  
oBrowse:AddColumn( TCColumn():New('Local',,,{|| },{|| }) )
oBrowse:AddColumn( TCColumn():New('Fornecedor',,,{|| },{|| }) )     
oBrowse:AddColumn( TCColumn():New('Nome',,,{|| },{|| }) )
oBrowse:AddColumn( TCColumn():New('Observação',,,{|| },{|| }) )

//Valida a digitação da nota
If !Empty(cNota)
	SF1->(DbSetOrder(1))    
	//Procura a nota de entrada
	If SF1->(DbSeek(xFilial("SF1")+cNota+cSerie))
						
		lSD3:=ChecSD3(cNota)
		
			If lSD3
				   
				lOk:=.F.
				//RRP - 03/10/2013 - Ajuste para carregar o nome correto do fornecedor no aBrowse. 
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
					aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,SA2->A2_NOME,"Nota não pode ser transferida, já existe transferência: "+Alltrim(cNota) }}
	  				oBrowse:SetArray(aBrowse)
	  		 		oBrowse:Refresh()
	  		 	EndIf
            
	   		Else
				
		
				SD1->(DbSetorder(1))
				If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))	
				 
					//Apenas notas tipo N
					If SD1->D1_TIPO == "N"	
					
						cLocal := SD1->D1_LOCAL 
						//cDoc	:= GetSxENum("SD3","D3_DOC",1) 
						
						aAuto := {}
		   				aadd(aAuto,{cNota,dDataBase})  //Cabecalho
	
						//Loop para validar o local e adicionar os itens da nota
						While SD1->(!EOF()) .And. SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			
			    	   		//Todos itens da nota devem estar no mesmo armazem.
			    	   		If cLocal <> SD1->D1_LOCAL
			    		 		lLocal :=.F.
			        		EndIf   
                           
							//JVR - 29/05/2012 - Aglutinação de produtos com o mesmo codigo.
				        	If Len(aAuto) > 1 .And.;
				        		(npos := aScan(aAuto,{ | X |   ALLTRIM(X[1]) ==  ALLTRIM(SD1->D1_COD) }) ) <> 0
								aAuto[nPos][16]+=SD1->D1_QUANT
	
				        	Else 
			        	
			           		SB1->(DbSetOrder(1))
			           		SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))    
			        	
			           		//Cabecalho a Incluir	
	
							 	aadd(aAuto,{SD1->D1_COD,;  		 	//D3_COD
						  	 			 LEFT(SB1->B1_DESC,30),;	//D3_DESCRI		
										 SD1->D1_UM,;  		   	    //D3_UM
										 SD1->D1_LOCAL,;    		//D3_LOCAL
										 "",;        				//D3_LOCALIZ
							   	   		 SD1->D1_COD,;  	 		//D3_COD
								   		 LEFT(SB1->B1_DESC,30),;	//D3_DESCRI		
								   		 SD1->D1_UM,;  	 			//D3_UM
										 cLocDes,;         		    //D3_LOCAL
										 "",;        				//D3_LOCALIZ
										 "",;        				//D3_NUMSERI
										 "",;  						//D3_LOTECTL  
										 "",;    	 				//D3_NUMLOTE
										 dDataBase,;	 			//D3_DTVALID
									     1,;				 		//D3_POTENCI
										 SD1->D1_QUANT,; 	 		//D3_QUANT
										 0,;				 		//D3_QTSEGUM
										 "N",;         	     		//D3_ESTORNO
										 ProxNum(),;      			//D3_NUMSEQ 
										 "",;	 					//D3_LOTECTL
									     dDataBase,;		 		//D3_DTVALID
										 "",;						//D3_ITEMGRD
										 0,;						//D3_PERIMP - RRP 03/10/2013 - Inclusão do campo, pois o array aheader estava com inconsistencia de dados.		 						
										 ""})						//D3_OBSERVA - CAS 11/10/2019 -Inclusão do campo, pois o array aheader estava com inconsistencia de dados.		 																 
				            EndIf								
			            
			    	   		SD1->(DbSkip())        
			    		
				   		EndDo   		

				    	//Valida o armazem    
				   		If lLocal
							SA2->(DbSetOrder(1))
							If SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
				   				aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,cLocal,SF1->F1_FORNECE,SA2->A2_NOME,"Ok p/ transferencia automatica"      }}   
					   	   	Else
						  		aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,cLocal,SF1->F1_FORNECE,"","Ok p/ transferencia automatica"      }}  
	    			   		EndIf
	    					lOk:=.T.         
	    				Else  
	    					aBrowse := {{SF1->F1_DOC  ,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,SA2->A2_NOME,"Nota não pode ser transferida, possui armazens diferentes"      }}
	    				EndIf
	    			
	    				oBrowse:SetArray(aBrowse)
	  					oBrowse:Refresh()
	            
				
			   		Else
					
						lOk:=.F. 
					
						aBrowse := {{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_TIPO,"",SF1->F1_FORNECE,"","Nota não pode ser transferida, tipo diferente de NORMAL"      }}   
	    				oBrowse:SetArray(aBrowse)
	  					oBrowse:Refresh()
	              
	    			EndIf
	    			     
	    		EndIf 
	    		
	    	EndIf
	    

	    	
	Else
       
       	lOk:=.F.   
       
		aBrowse := {{cNota,cSerie,"","","","","Nota + Serie não encontrada"     }}
		oBrowse:SetArray(aBrowse)
		oBrowse:Refresh()

	EndIf     		

Else  
      
	lOk:=.F.

	aBrowse := {{"","","","","","","Informe o parâmetro de nota e serie"     }}
	oBrowse:SetArray(aBrowse)
	oBrowse:Refresh()


EndIf

 
Return          
         
/*
Funcao      : c()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que verifica se existi transferência
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
  
*---------------------------------*
 Static Function ChecSD3(cNota)   
*---------------------------------*
              
Local lRet:=.F.

SD3->(DbSetOrder(2))
If SD3->(DbSeek(xFilial("SD3")+cNota))
	
	While SD3->(!EOF()) .And. cNota == Alltrim(SD3->D3_DOC)
		
		If Empty(SD3->D3_ESTORNO)
			lRet:=.T.
		EndIf
		       		                  
		SD3->(DbSkip())
	EndDo 
	
EndIf	
	
Return lRet		

/*
Funcao      : Valida()  
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que valida os dados para transferência
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/10/2011
*/
  
*---------------------------------*
 Static Function Valida(aMata240)   
*---------------------------------*
Local lRet:=.F.
Local nOpcAuto:= 3 // Indica qual tipo de ação será tomada (Inclusão)   
Local cMsg := ""

If !(lOk)
	MsgAlert("Nota informada não pode ser transferida","Okuma")                
ElseIf Empty(cLocDes) 
	MsgAlert("Armazem deve ser preenchido","Okuma")        
ElseIf Len(Alltrim(cLocDes)) <> 2	
	MsgAlert("Armazem deve ter 2 caracteres","Okuma")  	
Else        
    

    For i := 2 to len(aAuto)
		aAuto[i][9]:= cLocDes// Atualiza o local. 
   		
    Next		
                                                  
		MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
			
		If lMsErroAuto
			cMsg += MostraErro("\SYSTEM\")+CHR(10)+CHR(13)
			cMsg += "---------------------------------------------"+CHR(10)+CHR(13)
		EndIf  


		If !Empty(cMsg)
			cMsg := "Erro na transferencia :"+CHR(10)+CHR(13) + cMsg
			EECVIEW(cMsg)
			MsgStop("Erro na inclusao!")
		Else
	   		MsgInfo("Tranferencia feita com sucesso. " + cNota)	
			lRet:=.T.
		EndIf  

EndIf
    
Return  lRet