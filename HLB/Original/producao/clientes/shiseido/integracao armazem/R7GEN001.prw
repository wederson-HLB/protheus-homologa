#include "protheus.ch"
#include "Rwmake.ch"


/*
Funcao      : R7GEN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivos de interface de integração entre Shiseido e o armazem Shuttle
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
Obs         : 
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Generico. 
Cliente     : Shiseido
*/

*-------------------------*
 User Function R7GEN001()
*-------------------------*    

Local oMain, oDlg , oCbx 
Local lRet:=.F.

  //Validação da empresa
  If !(cEmpAnt $ "R7")
     MsgInfo("Especifico Shiseido"," A T E N C A O ")  
     Return .F.
  Endif                     
                

//Tela de geração de arquivos.
DEFINE MSDIALOG oDlg TITLE "Geração de arquivo FTP" From 1,15 To 25,50 OF oMain  

	@ 010,020 BUTTON "ARQUIVO DE ENTRADAS" 			size 100,15 ACTION Processa({|| R7ENT() }) of oDlg Pixel    //Gera arquivo de nota de entrada
 	@ 030,020 BUTTON "ARQUIVO DE SAIDAS"  	   		size 100,15 ACTION Processa({|| R7SAI() }) of oDlg Pixel    //Gera arquivo de nota de saida                                                       
    @ 050,020 BUTTON "ARQUIVO DE CLI/FORN/TRANS"    size 100,15 ACTION Processa({|| R7CLI() }) of oDlg Pixel    //Gera arquivo de cliente
    @ 070,020 BUTTON "ARQUIVO DE PRODUTOS"  		size 100,15 ACTION Processa({|| R7PRO() }) of oDlg Pixel    //Gera arquivo de produtos

    @ 150,020 BUTTON "Cancela" size 100,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel                                                                 
                                                                        
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return Nil 

/*
Funcao      : R7ENT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivos de interface de entrada
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/

*-------------------------*
  Static Function R7ENT()
*-------------------------*   

Local aStruSF1  :={}
Local aCpos     :={}
Local aButtons  :={} 

Local lInverte  :=.F.  

Private cMarca  := GetMark()                     
    
	If Select("TempSF1") > 0
		TempSF1->(DbCloseArea())	               
	EndIf  
	
	aadd(aButtons,{"PENDENTE",{|| MarcaTds("ENT")},"Marca ","Marca ",{|| .T.}})
	
	Aadd(aCpos, {"cINTEGRA"  ,"",})   
	Aadd(aCpos, {"F1_TIPO"   ,"","Tipo",})
	Aadd(aCpos, {"F1_DOC"    ,"","Nota Fiscal",})
	Aadd(aCpos, {"F1_SERIE"  ,"","Serie Fiscal",})
	Aadd(aCpos, {"F1_EMISSAO","","Emissao",}) 
	Aadd(aCpos, {"F1_VALBRUT","","Total",})  	
	Aadd(aCpos, {"F1_FORNECE","","Cod. Forn",})
	Aadd(aCpos, {"F1_LOJA"   ,"","Loja", })
	Aadd(aCpos, {"F1_DESC"   ,"","Fornecedor",})	

	                 
	Aadd(aStruSF1, {"F1_FILIAL"   ,"C", 2,0})            
	Aadd(aStruSF1, {"cINTEGRA"    ,"C", 2,0})
	Aadd(aStruSF1, {"F1_TIPO"     ,"C", 1,0}) 
	Aadd(aStruSF1, {"F1_DOC"      ,"C", 9,0}) 
	Aadd(aStruSF1, {"F1_SERIE "   ,"C", 3,0}) 	
	Aadd(aStruSF1, {"F1_EMISSAO"  ,"C", 8,0})
	Aadd(aStruSF1, {"F1_VALBRUT"  ,"N",16,2}) 
	Aadd(aStruSF1, {"F1_FORNECE"  ,"C", 6,0})
	Aadd(aStruSF1, {"F1_LOJA"     ,"C", 2,0})  
	Aadd(aStruSF1, {"F1_DESC"     ,"C",30,0})
   	Aadd(aStruSF1, {"F1_BASEICM"  ,"N",14,2})                                            
	Aadd(aStruSF1, {"F1_VALICM"   ,"N",14,2})
	Aadd(aStruSF1, {"F1_VALIPI"   ,"N",14,2})
	Aadd(aStruSF1, {"F1_VALMERC"  ,"N",14,2})  
	   
	cNome := CriaTrab(aStruSF1, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'TempSF1',.F.,.F.)       	 

	  
	If Select("F1QRY") > 0
		F1QRY->(DbCloseArea())	               
  	EndIf
    
    //Seleciona notas que não foram geradas F1_P_GER branco
    BeginSql Alias 'F1QRY'                               
       SELECT *
       FROM %Table:SF1%
       WHERE %notDel%
       AND F1_FILIAL = %exp:xFilial("SF1")%  
       AND F1_P_GER  = ' ' 
       AND F1_TIPO  IN ('N','B','D')
       AND F1_EMISSAO > '20120401' // notas antigas não devem ser mostradas.

       ORDER BY F1_DOC,F1_SERIE,F1_FORNECE
       
    EndSql
        
    F1QRY->(DbGoTop())
    If !(F1QRY->(!BOF() .and. !EOF()))
    	MsgStop("Não existe nota de entrada para ser enviado","Shiseido")
        Return .F.
    EndIf
    	 
    F1QRY->(DbGoTop())
	While F1QRY->(!EOF())
	                       
		//Valida se a Tes atualiza estoque utiliza sempre o primeiro item
		SD1->(DbSetOrder(1))
  		If SD1->(DbSeek(xFilial("SD1")+F1QRY->F1_DOC+F1QRY->F1_SERIE+F1QRY->F1_FORNECE+F1QRY->F1_LOJA))	
    		   
    		//Verfica somente os que atualizam estoque    		
    		SF4->(DbSetOrder(1))
      		If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES)) 
        		If SF4->F4_ESTOQUE <> "S"  
          			F1QRY->(DbSkip())
         			loop
            	EndIf
        	EndIf 
        	
        	SB1->(DbSetOrder(1))
        	If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
        		If Alltrim(SB1->B1_P_MULTB) <> "064"     
        			F1QRY->(DbSkip())
         			loop        	  
        		EndIf
        	EndIf               
                        
        EndIf  
                 	
		RecLock("TempSF1",.T.)
		TempSF1->F1_FILIAL  := F1QRY->F1_FILIAL            
		TempSF1->F1_TIPO    := F1QRY->F1_TIPO
		TempSF1->F1_DOC     := F1QRY->F1_DOC
		TempSF1->F1_SERIE   := F1QRY->F1_SERIE 
		TempSF1->F1_FORNECE := F1QRY->F1_FORNECE 
		TempSF1->F1_LOJA    := F1QRY->F1_LOJA  
   		TempSF1->F1_BASEICM := F1QRY->F1_BASEICM
 		TempSF1->F1_VALICM  := F1QRY->F1_VALICM
 		TempSF1->F1_VALIPI  := F1QRY->F1_VALIPI
 		TempSF1->F1_VALMERC := F1QRY->F1_VALMERC
		TempSF1->F1_VALBRUT := F1QRY->F1_VALBRUT
		TempSF1->F1_EMISSAO := F1QRY->F1_EMISSAO 
  		 		
		If F1QRY->F1_TIPO $ ("N/B")
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2")+F1QRY->F1_FORNECE+F1QRY->F1_LOJA )) 
		  		TempSF1->F1_DESC    := SA2->A2_NOME 	
	   		EndIf
		Else
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+F1QRY->F1_FORNECE+F1QRY->F1_LOJA )) 
		  		TempSF1->F1_DESC    := SA1->A1_NOME 	
	   		EndIf				
		EndIf 
	
		TempSF1->(MsUnlock()) 	
		F1QRY->(DbSkip())
   
	EndDo    

    TempSF1->(DbGoTop())
    If TempSF1->(!BOF() .and. !EOF())
    
   		DEFINE MSDIALOG oDlg TITLE "Shiseido - Notas de entrada não enviadas para Shuttle " FROM 000,000 TO 545,1100 PIXEL
                
              //oTOleContainer := TOleContainer():New( 021,640,052,20,oDlg,.T.,cImg1)   
                
              @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
              @ 026 , 015 Say  "SELECIONE SOMENTE AS NOTAS DE ENTRADA QUE SERÃO GERADAS PARA A SHUTTLE" COLOR CLR_HBLUE, CLR_WHITE    PIXEL SIZE 500,6 OF oDlg           
                        
              oFont := TFont():New('Courier new',,-14,.T.)
              oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVOS",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
              oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
              oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
              oMarkPrd:= MsSelect():New("TempSF1","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545},,,oDlg,,)   
     	   
     	 ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lRet:=GERAENT(),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED    	
    	
    Else
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Shiseido")
    	Return .F.   
    EndIf  
 
 
Return 
 

/*
Funcao      : GERAENT
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Gerar arquivos de interface de entrada
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/

*----------------------------*    
Static Function GERAENT()    
*----------------------------*    
           
Local lRet     := .T.
Local lNotas   := .T.
Local lMarcado := .T. 

Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\ftp\R7\Shuttle\Entrada\"  

Local cCab      := ""   
Local cNumAux   := ""
Local cInsc     := ""
Local cSF1Txt   := ""
Local cSeq      := "" 
Local cDoc      := ""
Local cSerie    := ""


Local cSeq      := "01"     
Local nTot      := 0
Local nSF1Hdl   := 0 
Local nLocal    := 0 
 
Local aNfeEnt   := {}

Private cSF1Txt   := ""
         
cEOL := Trim(cEOL)
cEOL := &cEOL       

Begin Sequence 

	TempSF1->(DbGoTop()) 
	While TempSF1->(!EOF())     

		//Checa se marcou pelo menos um item.
		If !Empty(Alltrim(TempSF1->cINTEGRA)) .And. lMarcado
			lMarcado:=.F.		
		EndIf
		
		TempSF1->(DbSkip()) 
	EndDo

 
	If  !(lMarcado)
	
		
		TempSF1->(DbGoTop()) 
		While TempSF1->(!EOF())   

			If !Empty(Alltrim(TempSF1->cINTEGRA)) .And. cNumAux <> TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA
		    
		    	If Empty(cNumAux) 
					cSF1Txt:="E_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".txt
				Else
					cSF1Txt:="E_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Alltrim(str(Val(Substr(TIME(),7,2))+1))+".txt
				EndIf  
				
     			// Vetor para workflow aNfeEnt  1.Documento,2.Serie,3.Fornecedor,4.Loja,5.Tipo,6.Arquivo   
    	    	Aadd(aNfeEnt,{TempSF1->F1_DOC,TempSF1->F1_SERIE,TempSF1->F1_FORNECE,TempSF1->F1_LOJA,TempSF1->F1_TIPO,cSF1Txt}) 
    	    	          
				nSF1Hdl:= fCreate(cDir+cSF1Txt)
  		   		If nSF1Hdl == -1 // Testa se o arquivo foi gerado
    	   			MsgAlert("O arquivo "+cSF1Txt+" nao pode ser executado!","Atenção")  
    		   		Return .F.
       			EndIf      
       			       			      			
       			nTamLin   := 2   
	   			cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	    	 	cCab  	  := Stuff(cCab,01,02,"YY")                             // FIXO      
    	    	
    	    	If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho YY (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf    
        		
        		       			
       			nTamLin   := 248   
	   			cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao 
    	    	
        		cDoc  := substr(TempSF1->F1_DOC,2,8)      			        			
        		cSerie := TempSF1->F1_SERIE 
        	    	  
    	    	cCab  := Stuff(cCab,01,02,"E0")               		      	  // Fixo com "E0"                      
          		cCab  := Stuff(cCab,03,01,"N")                           	  // Fixo "N" - Nota Fiscal
        		cCab  := Stuff(cCab,04,14,"04711147001031")                   // CGC Fialil - Sempre será o da Shuttle    
        		cCab  := Stuff(cCab,18,08,cDoc)                            	  // Numero da nota fiscal  
     			cCab  := Stuff(cCab,26,02,TempSF1->F1_SERIE+space(1))         // Serie da nota fiscal
        		cCab  := Stuff(cCab,28,30,cDoc+space(22))                     // Numero da nota fiscal  
        		cCab  := Stuff(cCab,58,01,"R")                            	  // Fixo com "R" - Remessa
        		cCab  := Stuff(cCab,59,04,"1905")                             // Fixo "1905" - Cfop   
        		cData := SubStr(Alltrim(TempSF1->F1_EMISSAO),1,4)+substr(Alltrim(TempSF1->F1_EMISSAO),5,2)+SubStr(Alltrim(TempSF1->F1_EMISSAO),7,2) 
        		cData := SubStr(Alltrim(TempSF1->F1_EMISSAO),7,2)+substr(Alltrim(TempSF1->F1_EMISSAO),5,2)+SubStr(Alltrim(TempSF1->F1_EMISSAO),1,4)
        		cCab  := Stuff(cCab,63,08,cData)                          	  // Data de emissao da nota
        		cCab  := Stuff(cCab,71,14,"03973238000191")                   // CNPJ da filial - conforme email, sempre será o da Shiseido  
        		cCab  := Stuff(cCab,85,12,space(12))                          // Sem uso
        		cCab  := Stuff(cCab,97,14,"03973238000191")                   // CNPJ do fornecedor - conforme email , sempre será o da Shiseido    
        		cInsc := SA2->A2_INSCR
        		      		
        		/* 
        		// CNPJ do fornecedor - Sempre será o da Shiseido  
        		If TempSF1->F1_TIPO $ "N/B" // Notas normais e beneficiamento
        			SA2->(DbSetOrder(1))
        			If SA2->(DbSeek(xFilial("SA2")+TempSF1->F1_FORNECE+TempSF1->F1_LOJA))
        		 		cCab  := Stuff(cCab,97,14,SA2->A2_CGC)        // CNPJ do fornecedor  
        		 		cInsc := SA2->A2_INSCR
        			EndIf
        		Else  // devolução
        			SA1->(DbSetOrder(1))
        			If SA1->(DbSeek(xFilial("SA1")+TempSF1->F1_FORNECE+TempSF1->F1_LOJA))
        		 		cCab  := Stuff(cCab,97,14,SA1->A1_CGC)        // CNPJ do cliente 
        		 		cInsc := SA1->A1_INSCR 
        			EndIf
        		
        		EndIf	
        		  
        		*/
        		
        	    nLocal:=00.00  
        		
			    cCab  := Stuff(cCab,111,12,space(12))                         				      // Sem uso
			    //cCab  := Stuff(cCab,123,15,strtran(strzero(TempSF1->F1_BASEICM,15,2),".",","))  // Base de ICMS
    	        cCab  := Stuff(cCab,123,15,strtran(strzero(TempSF1->F1_VALBRUT,15,2),".",","))    // Base de ICMS
    	        //cCab  := Stuff(cCab,138,15,strtran(strzero(TempSF1->F1_VALICM ,15,2),".",","))  // Valor do ICMS
    	        cCab  := Stuff(cCab,138,15,strtran(strzero(nlocal ,15,2),".",","))				  // Valor do ICMS
    	        //cCab  := Stuff(cCab,153,15,strtran(strzero(TempSF1->F1_VALIPI ,15,2),".",","))  // Valor do IPI
    	        cCab  := Stuff(cCab,153,15,strtran(strzero(nLocal ,15,2),".",",")) 				  // Valor do IPI
    	        cCab  := Stuff(cCab,168,15,strtran(strzero(TempSF1->F1_VALBRUT,15,2),".",","))    // Valor da Mercadoria
    	        cCab  := Stuff(cCab,183,15,strtran(strzero(TempSF1->F1_VALBRUT,15,2),".",","))    // Valor Total NF
    	        cCab  := Stuff(cCab,198,20,SM0->M0_INSC)                     				      // Inscrição estadual filial                            
    	        cCab  := Stuff(cCab,218,20,SM0->M0_INSC)                                          // Inscrição estadual shiseido - sempre será da shisseido     	        
    	        //cCab  := Stuff(cCab,218,20,cInsc)                                               // Inscrição estadual forncedor               
    	        
    	        If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho E0 (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf  
        		   
        		//Sequencial por nota
        		n:=1
    	        	           
    			SD1->(DbSetOrder(1))
    			If SD1->(DbSeek(xFilial("SD1")+TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA))
    	        
    				While SD1->(!EOF()) .And.  TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
     				
	     				nTamLin   := 217   
	     			
	        			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	 
	           			//   Itens  ----------------------------------------------------       Comentários
	        
	        			cCab  := Stuff(cCab,01,02,"E2")               		   		  			// Fixo com "E2"                        
			 	   		cCab  := Stuff(cCab,03,08,cDoc)        		 					        // Numero da nota fiscal  
	        			cCab  := Stuff(cCab,11,02,TempSF1->F1_SERIE+space(2))                	// Serie da nota fiscal
        	   			cCab  := Stuff(cCab,13,30,cDoc+space(21))                               // Numero da nota fiscal  			        			
			   			cCab  := Stuff(cCab,43,03,cSeq)                             	        	// Sequencial  
						cCab  := Stuff(cCab,45,74,SD1->D1_COD)               	   	   			// Código do produto
	     				cCab  := Stuff(cCab,75,15,strtran(strzero(SD1->D1_QUANT,15,2),".",",")) // Quantidade
	           			cCab  := Stuff(cCab,90,03,"UN ")                        	        	// Unidade de medida    
	           		    
	           			SB1->(DbSetOrder(1))
	           			IF SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
	           		    	cCab  := Stuff(cCab,93,10,"00"+SB1->B1_POSIPI)                  			 // NCM   
	           			EndIf                                                                 
	           			
	           			cCab  := Stuff(cCab,103,15,strtran(strzero(SD1->D1_VUNIT,15,2),".",","))            // Preço unitario
	           			//cCab  := Stuff(cCab,118,05,strtran(strzero(SD1->D1_PICM,5,2),".",","))            // Aliquota de icms
	           			cCab  := Stuff(cCab,118,05,strtran(strzero(nLocal,5,2),".",","))                    // Aliquota de icms
	           			//cCab  := Stuff(cCab,123,05,strtran(strzero(SD1->D1_IPI,5,2),".",","))             // Aliquota de ipi
	           			cCab  := Stuff(cCab,123,05,strtran(strzero(nLocal,5,2),".",","))                    // Aliquota de ipi
	           			cCab  := Stuff(cCab,128,15,strtran(strzero(SD1->D1_TOTAL,15,2),".",","))            // Valor da mercadoria 
	           			//cCab  := Stuff(cCab,143,15,strtran(strzero(SD1->D1_TOTAL+SD1->D1_VALIMP5+SD1->D1_VALIMP6+SD1->D1_VALIPI+SD1->D1_VALICM,15,2),".",","))          // Valor Total
	           			cCab  := Stuff(cCab,143,15,strtran(strzero(SD1->D1_TOTAL,15,2),".",",")) 
	           			cCab  := Stuff(cCab,158,30,SD1->D1_LOTECTL+space(20))         				      // Lote da mercadoria
	           			cCab  += cEOL   
	           			       
	           			cSeq:=Soma1(cSeq)
	           			nTot++
	           		
	           			If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
	  						If !MsgAlert("Ocorreu um erro na gravacao do arquivo, itens E2 (Var:cCab). ","Atencao!")
	     						Return .F. 
	        				Endif 
	        			EndIf 
	        			
	        		SD1->(DbSkip()) 		
	                 
					EndDo
	
    	    	EndIf
    	    
    	    EndIf  
            
			If !Empty(Alltrim(TempSF1->cINTEGRA)) .And. alltrim(cNumAux) <> TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA 
			
				nTamLin   := 45  
		   		cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao    	
	    		cCab 	  := Stuff(cCab,01,01,"E3")       
		   		cCab  	  := Stuff(cCab,03,08,cDoc)             	   // Numero da nota fiscal  
	   	   		cCab  	  := Stuff(cCab,11,02,cSerie+space(1))         // Serie da nota fiscal
	   	   		cCab  	  := Stuff(cCab,13,30,cDoc+space(22))          // Numero da nota fiscal  
	    		cCab  	  := Stuff(cCab,43,3,strzero(nTot,3,0))        // Quantidade de itens  

	       		If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
		  			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, itens E3 (Var:cCab). ","Atencao!")
		    	   		Return .F. 
		      		Endif 
		    	EndIf       
		    	
		    	nTamLin   := 2   
	   			cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	    	 	cCab  	  := Stuff(cCab,01,02,"WW")                             // FIXO      

    	    	If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho WW (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf   
        		
        		fClose(nSF1Hdl)   
		    	
		    	MsgInfo("Arquivo: "+Alltrim(cSF1Txt)+" gerado com sucesso.","Shiseido")    
    	    
    	    	EMail(aNfeEnt,"ENT")
                   		    
       		   					//Controle de para chcar notas   	
    	   	    cNumAux:=TempSF1->F1_DOC+TempSF1->F1_SERIE+TempSF1->F1_FORNECE+TempSF1->F1_LOJA
	    	

       	   
      		EndIf 
       		
       		      
       
    	    TempSF1->(DbSkip()) 
    		    
    	EndDo

    	
    	                                   	        
    	// Atualiza SF1        	
     	For i:=1 to Len(aNfeEnt)
         	 
 
 			//aNfeEnt  1.Documento,2.Serie,3.Fornecedor,4.Loja,5.Tipo,6.Arquivo  ( F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_TIPO )
        	cChave:=aNfeEnt[i][1]+aNfeEnt[i][2]+aNfeEnt[i][3]+aNfeEnt[i][4]
         		
         	SF1->(DbGoTop())  
         	SF1->(DbSetOrder(1))
         	If SF1->(DbSeek(xFilial("SF1")+cChave))	
          		RecLock("SF1",.F.) 
             	SF1->F1_P_GER   :="S"
             	SF1->F1_P_ARQ   :=aNfeEnt[i][6]  
             	SF1->F1_P_USER  :=alltrim(cUserName)          	
               	SF1->(MsUnlock())
             	SF1->(DbSkip())                     
          	EndIf 
            
 		Next 
           
        
              	          	
           
    Else
    	MsgStop("Existem notas não marcardos, verificar.","Shiseido")  
    	TempSF1->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet      

/*
Funcao      : R7SAI
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivos de interface de saida
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/

*-------------------------*
 Static Function R7SAI()
*-------------------------*   

Local aStruSF2  :={}
Local aCpos     :={}
Local aButtons  :={} 

Local lInverte  :=.F.  

Private cMarca  := GetMark()                     
  
	If Select("TempSF2") > 0
		TempSF2->(DbCloseArea())	               
	EndIf  
	
	aadd(aButtons,{"PENDENTE",{|| MarcaTds("ENT")},"Marca ","Marca ",{|| .T.}})
	
	Aadd(aCpos, {"cINTEGRA"  ,"",})   
	Aadd(aCpos, {"F2_TIPO"   ,"","Tipo",})
	Aadd(aCpos, {"F2_DOC"    ,"","Nota Fiscal",})
	Aadd(aCpos, {"F2_SERIE"  ,"","Serie Fiscal",})
	Aadd(aCpos, {"F2_EMISSAO","","Emissao",}) 
	Aadd(aCpos, {"F2_VALBRUT","","Total",})  	
	Aadd(aCpos, {"F2_CLIENTE","","Cod. Cli",})
	Aadd(aCpos, {"F2_LOJA"   ,"","Loja", })
	Aadd(aCpos, {"F2_DESC"   ,"","Cliente",})	

	                 
	Aadd(aStruSF2, {"F2_FILIAL"   ,"C", 2,0})            
	Aadd(aStruSF2, {"cINTEGRA"    ,"C", 2,0})
	Aadd(aStruSF2, {"F2_TIPO"     ,"C", 1,0}) 
	Aadd(aStruSF2, {"F2_DOC"      ,"C", 9,0}) 
	Aadd(aStruSF2, {"F2_SERIE "   ,"C", 3,0}) 	
	Aadd(aStruSF2, {"F2_EMISSAO"  ,"C", 8,0})
	Aadd(aStruSF2, {"F2_VALBRUT"  ,"N",16,2}) 
	Aadd(aStruSF2, {"F2_CLIENTE"  ,"C", 6,0})
	Aadd(aStruSF2, {"F2_LOJA"     ,"C", 2,0})  
	Aadd(aStruSF2, {"F2_DESC"     ,"C",30,0})
   	Aadd(aStruSF2, {"F2_BASEICM"  ,"N",14,2})                                            
	Aadd(aStruSF2, {"F2_VALICM"   ,"N",14,2})
	Aadd(aStruSF2, {"F2_VALIPI"   ,"N",14,2})
	Aadd(aStruSF2, {"F2_VALMERC"  ,"N",14,2})  
	Aadd(aStruSF2, {"F2_TRANSP"   ,"C",6,0})  
	Aadd(aStruSF2, {"F2_ICMSRET"  ,"N",14,2})  
	Aadd(aStruSF2, {"F2_FRETE"    ,"N",14,2})  
	Aadd(aStruSF2, {"F2_SEGURO"   ,"N",14,2})    
	Aadd(aStruSF2, {"F2_DESPESA"  ,"N",14,2})  
	Aadd(aStruSF2, {"F2_VOLUME1"  ,"N",06,0})  
	Aadd(aStruSF2, {"F2_PBRUTO"   ,"N",14,2})  	
	
	cNome := CriaTrab(aStruSF2, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'TempSF2',.F.,.F.)       	 

	  
	If Select("F2QRY") > 0
		F2QRY->(DbCloseArea())	               
  	EndIf
    
    //Seleciona notas que não foram geradas F2_P_GER branco
    BeginSql Alias 'F2QRY'
       SELECT *
       FROM %Table:SF2%
       WHERE %notDel%
       AND F2_FILIAL = %exp:xFilial("SF2")%  
       AND F2_P_GER  = ' ' 
       AND F2_TIPO  IN ('N','B','D')
       AND F2_EMISSAO > '20120401'  // notas antigas não devem ser mostradas. 


       ORDER BY F2_DOC,F2_SERIE,F2_CLIENTE
       
    EndSql
        
    F2QRY->(DbGoTop())
    If !(F2QRY->(!BOF() .and. !EOF()))
    	MsgStop("Não existe nota de saida para ser enviada","Shiseido")
        Return .F.
    EndIf
    	 
    F2QRY->(DbGoTop())
	While F2QRY->(!EOF())
	                       
		//Valida se a Tes atualiza estoque utiliza sempre o primeiro item
		SD2->(DbSetOrder(1))
  		If SD2->(DbSeek(xFilial("SD2")+F2QRY->F2_DOC+F2QRY->F2_SERIE+F2QRY->F2_CLIENTE+F2QRY->F2_LOJA))	
    		   
    		//Verfica somente os que atualizam estoque    		
    		SF4->(DbSetOrder(1))
      		If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES)) 
        		If SF4->F4_ESTOQUE <> "S"  
          			F2QRY->(DbSkip())
         			loop
            	EndIf
        	EndIf  
        	
        	SB1->(DbSetOrder(1))
        	If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        		If Alltrim(SB1->B1_P_MULTB) <> "064"     
        			F2QRY->(DbSkip())
         			loop        	  
        		EndIf
        	EndIf                 
                        
        EndIf  
                 	
		RecLock("TempSF2",.T.)
		TempSF2->F2_FILIAL  := F2QRY->F2_FILIAL            
		TempSF2->F2_TIPO    := F2QRY->F2_TIPO
		TempSF2->F2_DOC     := F2QRY->F2_DOC
		TempSF2->F2_SERIE   := F2QRY->F2_SERIE 
		TempSF2->F2_CLIENTE := F2QRY->F2_CLIENTE
		TempSF2->F2_LOJA    := F2QRY->F2_LOJA  
   		TempSF2->F2_BASEICM := F2QRY->F2_BASEICM
 		TempSF2->F2_VALICM  := F2QRY->F2_VALICM
 		TempSF2->F2_VALIPI  := F2QRY->F2_VALIPI
 		TempSF2->F2_VALMERC := F2QRY->F2_VALMERC
		TempSF2->F2_VALBRUT := F2QRY->F2_VALBRUT
		TempSF2->F2_EMISSAO := F2QRY->F2_EMISSAO 
		TempSF2->F2_TRANSP  := F2QRY->F2_TRANSP
		TempSF2->F2_ICMSRET := F2QRY->F2_ICMSRET
    	TempSF2->F2_FRETE   := F2QRY->F2_FRETE 
    	TempSF2->F2_SEGURO  := F2QRY->F2_SEGURO
    	TempSF2->F2_DESPESA := F2QRY->F2_DESPESA     	         	        
		TempSF2->F2_PBRUTO  := F2QRY->F2_PBRUTO   
		TempSF2->F2_VOLUME1 := F2QRY->F2_VOLUME1 
  				
		If F2QRY->F2_TIPO $ ("N/B")
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+F2QRY->F2_CLIENTE+F2QRY->F2_LOJA )) 
		  		TempSF2->F2_DESC    := SA1->A1_NOME 	
	   		EndIf
		Else
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2")+F2QRY->F2_CLIENTE+F2QRY->F2_LOJA )) 
		  		TempSF2->F2_DESC    := SA2->A2_NOME 	
	   		EndIf				
		EndIf 
		

		TempSF2->(MsUnlock()) 	
		F2QRY->(DbSkip())
   
	EndDo    
    
    TempSF2->(DbGoTop())
    If TempSF2->(!BOF() .and. !EOF())
    
   		DEFINE MSDIALOG oDlg TITLE "Shiseido - Notas de saidas não enviadas para Shuttle " FROM 000,000 TO 545,1100 PIXEL
                
              //oTOleContainer := TOleContainer():New( 021,640,052,20,oDlg,.T.,cImg1)   
                
              @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
              @ 026 , 015 Say  "SELECIONE SOMENTE AS NOTAS DE SAIDA QUE SERÃO GERADAS PARA A SHUTTLE" COLOR CLR_HBLUE, CLR_WHITE    PIXEL SIZE 500,6 OF oDlg           
                        
              oFont := TFont():New('Courier new',,-14,.T.)
              oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVOS",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
              oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
              oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
              oMarkPrd:= MsSelect():New("TempSF2","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545},,,oDlg,,)   
     	   
     	 ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lRet:=GERASAI(),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED    	
    	
    Else
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Shiseido")
    	Return .F.   
    EndIf 
 
Return 
 
/*
Funcao      : GERASAI
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Gerar arquivos de interface de saída
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/

*------------------------------*    
  Static Function GERASAI()    
*------------------------------*    
           
Local lRet     := .T.
Local lMarcado := .T. 

Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\ftp\R7\Shuttle\Saida\"  

Local cCab      := ""   
Local cNumAux   := ""
Local cInscC    := ""
Local cInscT    := ""
Local cSeq      := ""
Local cDoc      := ""
Local cSerie    := ""

Local n         := 1     
Local nTot      := 0
Local nSF2Hdl   := 0 
Local nLocal    := 0

Local aNfeSai   := {}

Private cSF2Txt   := ""

         
cEOL := Trim(cEOL)
cEOL := &cEOL       

Begin Sequence 

	TempSF2->(DbGoTop()) 
	While TempSF2->(!EOF())     

		//Checa se marcou pelo menos um item.
		If !Empty(Alltrim(TempSF2->cINTEGRA)) .And. lMarcado
			lMarcado:=.F.		
		EndIf
		
		TempSF2->(DbSkip()) 
	EndDo

 
	If  !(lMarcado)
		
		TempSF2->(DbGoTop()) 
		While TempSF2->(!EOF())   

			If !Empty(Alltrim(TempSF2->cINTEGRA)) .And. cNumAux <> TempSF2->F2_DOC+TempSF2->F2_SERIE+TempSF2->F2_CLIENTE+TempSF2->F2_LOJA
		    	 
	  
		 		If Empty(cNumAux) 
					cSF2Txt:="S_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".txt
				Else
					cSF2Txt:="S_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Alltrim(str(Val(Substr(TIME(),7,2))+1))+".txt
				EndIf     
				
				nSF2Hdl:= fCreate(cDir+cSF2Txt)
  		   		If nSF2Hdl == -1 // Testa se o arquivo foi gerado
    	   			MsgAlert("O arquivo "+cSF2Txt+" nao pode ser executado!","Atenção")  
    		   		Return .F.
       			EndIf 
				       	             
    	    	// Vetor para workflow aNfeSai  1.Documento,2.Serie,3.Fornecedor,4.Loja,5.Tipo,6.Arquivo   
    	    	Aadd(aNfeSai,{TempSF2->F2_DOC,TempSF2->F2_SERIE,TempSF2->F2_CLIENTE,TempSF2->F2_LOJA,TempSF2->F2_TIPO,cSF2Txt}) 
    	    	
       			nTamLin   := 2   
	   			cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	    	 	cCab  	  := Stuff(cCab,01,02,"YY")                             // FIXO      
    	    	
    	    	If fWrite(nSF2Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho YY (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf    
        		
        		cDoc  := substr(TempSF2->F2_DOC,2,9)         			        			
		 		cSerie:=TempSF2->F2_SERIE
        	    	  
    	    	cCab  := Stuff(cCab,01,02,"SX")               		      	     // Fixo com "SX"                      
          		cCab  := Stuff(cCab,03,01,"N")                           	     // Fixo "N" - Nota Fiscal
        		cCab  := Stuff(cCab,04,14,"04711147001031")                      // CGC da Filial – sempre será o da Shuttle 
        		cCab  := Stuff(cCab,18,08,Substr(TempSF2->F2_DOC,2,9))   	     // Numero da nota fiscal  
     			cCab  := Stuff(cCab,26,02,TempSF2->F2_SERIE+space(1))            // Serie da nota fiscal
        		cCab  := Stuff(cCab,28,30,Substr(TempSF2->F2_DOC,2,9)+space(22)) // Numero da nota fiscal  
        		cCab  := Stuff(cCab,58,04,"5906")                                // Fixo "1905" - Cfop   
        		cData := SubStr(Alltrim(TempSF2->F2_EMISSAO),1,4)+substr(Alltrim(TempSF2->F2_EMISSAO),5,2)+SubStr(Alltrim(TempSF2->F2_EMISSAO),7,2) 
        		cData := SubStr(Alltrim(TempSF2->F2_EMISSAO),7,2)+substr(Alltrim(TempSF2->F2_EMISSAO),5,2)+SubStr(Alltrim(TempSF2->F2_EMISSAO),1,4)
        		cCab  := Stuff(cCab,62,08,cData)                          	      // Data de emissao da nota
          		cCab  := Stuff(cCab,70,08,cData)                          	      // Data de emissao da nota
        		cCab  := Stuff(cCab,78,14,"03973238000191")                       // CGC Depositante / cliente - Sempre será o da Shiseido 
        		cCab  := Stuff(cCab,92,12,space(12))                              // Sem uso
        		
				SA1->(DbSetOrder(1))
    			If SA1->(DbSeek(xFilial("SA1")+TempSF2->F2_CLIENTE+TempSF2->F2_LOJA))
       				cCab  := Stuff(cCab,104,14,SA1->A1_CGC)                   // CNPJ do fornecedor  
        		 	cInscC := SA1->A1_INSCR
       			EndIf

        		cCab  := Stuff(cCab,118,12,space(12))                         // Sem uso
        		
        		SA4->(DbSetOrder(1))
        		If SA4->(DbSeek(xFilial("SA4")+TempSF2->F2_TRANSP))
        			cCab  := Stuff(cCab,130,14,SA4->A4_CGC)                    // CNPJ da transportadora      
        			cInscT := SA4->A4_INSEST
        		Else
        	   		cCab  := Stuff(cCab,130,14,space(14))               		
        		EndIf
        		 
        		nLocal:=00.00        
        		
			    cCab  := Stuff(cCab,144,12,space(12))                          					  // Sem uso
			    //cCab  := Stuff(cCab,156,15,strtran(strzero(TempSF2->F2_BASEICM,15,2),".",","))  // Base de ICMS
    	        cCab  := Stuff(cCab,156,15,strtran(strzero(nlocal,15,2),".",","))  				  // Base de ICMS
    	        //cCab  := Stuff(cCab,171,15,strtran(strzero(TempSF2->F2_VALICM ,15,2),".",","))  // Valor do ICMS
    	        cCab  := Stuff(cCab,171,15,strtran(strzero(nlocal ,15,2),".",","))  			  // Valor do ICMS
    	        //cCab  := Stuff(cCab,186,15,strtran(strzero(TempSF2->F2_VALIPI ,15,2),".",","))  // Valor do IPI
    	        cCab  := Stuff(cCab,186,15,strtran(strzero(nlocal ,15,2),".",","))			      // Valor do IPI
    	        cCab  := Stuff(cCab,201,15,strtran(strzero(TempSF2->F2_VALMERC,15,2),".",","))    // Valor da Mercadoria
    	        //cCab  := Stuff(cCab,216,15,strtran(strzero(TempSF2->F2_ICMSRET,15,2),".",","))  // Valor do ICMS substituto
    	        cCab  := Stuff(cCab,216,15,strtran(strzero(nlocal,15,2),".",","))  				  // Valor do ICMS substituto
    	        //cCab  := Stuff(cCab,231,15,strtran(strzero(TempSF2->F2_FRETE,15,2),".",","))    // Valor do frete
    	        cCab  := Stuff(cCab,231,15,strtran(strzero(nlocal,15,2),".",","))   			  // Valor do frete
    	        //cCab  := Stuff(cCab,246,15,strtran(strzero(TempSF2->F2_SEGURO,15,2),".",","))   // Valor do seguro
    	        cCab  := Stuff(cCab,246,15,strtran(strzero(nlocal,15,2),".",","))  				  // Valor do seguro
    	        //cCab  := Stuff(cCab,261,15,strtran(strzero(TempSF2->F2_DESPESA,15,2),".",","))  // Valor das despesas    	         	        
    	        cCab  := Stuff(cCab,261,15,strtran(strzero(nlocal,15,2),".",","))  				  // Valor das despesas   
    	        cCab  := Stuff(cCab,276,15,strtran(strzero(TempSF2->F2_VALMERC,15,2),".",","))    // Valor Total NF
    	        //cCab  := Stuff(cCab,291,15,strtran(strzero(TempSF2->F2_PBRUTO,15,2),".",","))   // Valor Peso Total NF  
    	        cCab  := Stuff(cCab,291,15,strtran(strzero(nlocal,15,2),".",","))  				  // Valor Peso Total NF 
    	        //cCab  := Stuff(cCab,306,15,strtran(strzero(TempSF2->F2_VOLUME1,15,2),".",","))  // Valor Peso Total NF
    	        cCab  := Stuff(cCab,306,15,strtran(strzero(nlocal,15,2),".",","))  				  // Valor Peso Total NF
    	        cCab  := Stuff(cCab,321,20,SM0->M0_INSC+space(6))              				     // Inscrição estadual filial                            
    	        If !Empty(cInscC)
    	        	cCab  := Stuff(cCab,341,20,cInscC+space(6))                    					// Inscrição estadual cliente       
     	        Else
     	        	cCab  := Stuff(cCab,341,20,space(20)) 
     	        EndIf
     	        If !Empty(cInscT)
     	        	cCab  := Stuff(cCab,361,20,cInscT+space(6))                    					// Inscrição estadual transportadora  
    	        Else
    	        	cCab  := Stuff(cCab,361,20,space(20))   
    	        EndIf 
    	        
    	        SC9->(DbSetOrder(6))
    	        If SC9->(Dbseek(xFilial("SC9")+TempSF2->F2_SERIE+TempSF2->F2_DOC)) 
    	        	SC5->(DbSetOrder(1))
    	        	If SC5->(Dbseek(xFilial("SC5")+SC9->C9_PEDIDO))
    	        		cCab  := Stuff(cCab,381,01,SC5->C5_TPFRETE)                 // Tipo do frete	
    	        	EndIF
    	        EndIf 	    
    	        
    	        cCab  := Stuff(cCab,382,60,SA1->A1_END+space(20))                   // Logradouro      
      	        cCab  := Stuff(cCab,442,08,replicate("0",8))                        // Numero - Obs numero está no endereço
     	        cCab  := Stuff(cCab,450,60,SA1->A1_COMPLEM+space(10))               //Complemento
     	        cCab  := Stuff(cCab,510,60,SA1->A1_BAIRRO+space(30))                //Bairro    	        
     	        cCab  := Stuff(cCab,570,60,SA1->A1_MUN+space(30))                   //Cidade
     	        cCab  := Stuff(cCab,630,02,SA1->A1_EST)                             //Estado    	        		    	        
      	        cCab  := Stuff(cCab,632,08,strzero(VAl(SA1->A1_CEP),8,0))           //CEP
      	           	        
    	        cCab  += cEOL          
    	        
    	        If fWrite(nSF2Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho E0 (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf  
        		   
        		//Sequencial por nota
        		n:=1
    	        	           
    			SD2->(DbSetOrder(3))
    			If SD2->(DbSeek(xFilial("SD2")+TempSF2->F2_DOC+TempSF2->F2_SERIE+TempSF2->F2_CLIENTE+TempSF2->F2_LOJA))
    	        
    				While SD2->(!EOF()) .And.  TempSF2->F2_DOC+TempSF2->F2_SERIE+TempSF2->F2_CLIENTE+TempSF2->F2_LOJA == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
     				
	     				nTamLin   := 218   
	     			
	        			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	 
	           			//   Itens  ----------------------------------------------------       Comentários
	        
	        			cCab  := Stuff(cCab,01,02,"S4")               		   		   				// Fixo com "S4"                        
			 	   		cCab  := Stuff(cCab,03,08,cDoc)                             			    // Numero da nota fiscal  
	        			cCab  := Stuff(cCab,11,02,TempSF2->F2_SERIE+space(1))          			    // Serie da nota fiscal
        	   			cCab  := Stuff(cCab,13,30,cDoc+space(22))                     			    // Numero da nota fiscal  			        			
			   			cCab  := Stuff(cCab,43,04,Strzero(n,4))                         	     	// Sequencial  
						cCab  := Stuff(cCab,47,74,SD2->D2_COD)               	   			     	// Código do produto
	     				cCab  := Stuff(cCab,77,15,strtran(strzero(SD2->D2_QUANT,15,2),".",","))     // Quantidade
	           			cCab  := Stuff(cCab,92,03,"UN ")                        	             	// Unidade de medida    
	           		    
	           			SB1->(DbSetOrder(1))
	           			IF SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	           		    	cCab  := Stuff(cCab,95,10,"00"+alltrim(SB1->B1_POSIPI))                   // NCM   
	           			EndIf                                                                 
	           			
	           			cCab  := Stuff(cCab,105,15,strtran(strzero(SD2->D2_PRCVEN,15,2),".",","))         // Preço unitario
	           			cCab  := Stuff(cCab,120,05,strtran(strzero(SD2->D2_PICM,5,2),".",","))            // Aliquota de icms
	           			cCab  := Stuff(cCab,125,05,strtran(strzero(SD2->D2_IPI,5,2) ,".",","))            // Aliquota de ipi
	           			cCab  := Stuff(cCab,130,15,strtran(strzero(SD2->D2_TOTAL,15,2),".",","))          // Valor da mercadoria 
	           			cCab  := Stuff(cCab,145,15,strtran(strzero(SD2->D2_TOTAL,15,2),".",","))          // Valor Total
	           			cCab  := Stuff(cCab,160,30,SD2->D2_LOTECTL+space(20))           		 	 	  // Lote da mercadoria
	           			cCab  := Stuff(cCab,190,30,space(30))                         				      // Branco
	           			cCab  += cEOL   
	           			n++
	           			nTot++
	           		
	           			If fWrite(nSF2Hdl,cCab,Len(cCab)) != (Len(cCab))
	  						If !MsgAlert("Ocorreu um erro na gravacao do arquivo, itens E2 (Var:cCab). ","Atencao!")
	     						Return .F. 
	        				Endif 
	        			EndIf 
	        			
	        		SD2->(DbSkip()) 		
	                 
					EndDo
	
    	    	EndIf
    	    
    	    EndIf 


			If !Empty(Alltrim(TempSF2->cINTEGRA)) .And. cNumAux <> TempSF2->F2_DOC+TempSF2->F2_SERIE+TempSF2->F2_CLIENTE+TempSF2->F2_LOJA 
			
    	
				nTamLin   := 46  
			 	cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao    	
		    	cCab 	  := Stuff(cCab,01,02,"S3")       
				cCab  	  := Stuff(cCab,03,08,cDoc) 			  	   // Numero da nota fiscal  
		   		cCab  	  := Stuff(cCab,11,02,cSerie+space(1))         // Serie da nota fiscal
		   		cCab  	  := Stuff(cCab,13,30,cDoc+space(22))          // Numero da nota fiscal  
		    	cCab  	  := Stuff(cCab,43,03,strzero(nTot,3,0))        // Quantidade de itens  		
		    	
		    	If fWrite(nSF2Hdl,cCab,Len(cCab)) != (Len(cCab))
			  		If !MsgAlert("Ocorreu um erro na gravacao do arquivo, itens S3 (Var:cCab). ","Atencao!")
			    		Return .F. 
			     	Endif 
			    EndIf        
			    
			    		    	
		    	nTamLin   := 2   
	   			cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	    	 	cCab  	  := Stuff(cCab,01,02,"WW")                             // FIXO      

    	    	If fWrite(nSF2Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho WW (Var:cCab). ","Atencao!")
     					Return .F. 
        			Endif 
        		EndIf   
			    
			    MsgInfo("Arquivo: "+Alltrim(cSF2Txt)+" gerado com sucesso.","Shiseido")    
    	    
    	    	EMail(aNfeSai,"SAI")
             	        	
    			fClose(nSF2Hdl)   
                
 
 
       		EndIf 
    	    
    
    	    TempSF2->(DbSkip()) 
    		    
    	EndDo    
    	                	                                   	        
    	// Atualiza SF2        	
     	For i:=1 to Len(aNfeSai)
         	 
 
 			//aNfeSai  1.Documento,2.Serie,3.Fornecedor,4.Loja,5.Tipo,6.Arquivo  ( F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_TIPO )
        	cChave:=aNfeSai[i][1]+aNfeSai[i][2]+aNfeSai[i][3]+aNfeSai[i][4]
         		
         	SF2->(DbGoTop())  
         	SF2->(DbSetOrder(1))
         	If SF2->(DbSeek(xFilial("SF2")+cChave))	
          		RecLock("SF2",.F.) 
             	SF2->F2_P_GER   :="S"
             	SF2->F2_P_ARQ   :=aNfeSai[i][6] 
             	SF2->F2_P_USER  :=alltrim(cUserName)          	
               	SF2->(MsUnlock())
             	SF2->(DbSkip())                     
          	EndIf 
            
 		Next 
           
                      
    Else
    	MsgStop("Existem notas não marcardos, verificar.","Shiseido")  
    	TempSF2->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet   

/*
Funcao      : R7CLI
Parametros  : cNum
Retorno     : lRet
Objetivos   : Gerar arquivos de interface de clientes ( fornecedores e transportador fazem parte )
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/         

*--------------------------*    
  Static Function R7CLI()    
*--------------------------*    
           
Local lRet     := .T.

Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\ftp\R7\Shuttle\clientes\"      

Local cCab      := ""   
Local cSA1Txt   := ""
Local cSeq      := ""

Local n         := 1     
Local nSA1Hdl   := 0
 
Local aSA1      := {}

Private cNum    := "C_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".txt
         
cEOL := Trim(cEOL)
cEOL := &cEOL       

Begin Sequence 

	If Select("TempSA1") > 0
		TempSA1->(DbCloseArea())	               
  	EndIf
    
    //Seleciona clientes que não foram gerados A1_P_GER branco
    BeginSql Alias 'TempSA1'
       SELECT *
       FROM %Table:SA1%
       WHERE %notDel%
       AND A1_FILIAL = %exp:xFilial("SA1")%  
       AND A1_P_GER  = ' ' 
       AND A1_CGC <> ' '
       AND A1_PESSOA <> ' '
       ORDER BY A1_COD
       
    EndSql   
    
    
	If Select("TempSA2") > 0
		TempSA2->(DbCloseArea())	               
  	EndIf
    
    //Seleciona forncedores que não foram gerados A2_P_GER branco
    BeginSql Alias 'TempSA2'
       SELECT *
       FROM %Table:SA2%
       WHERE %notDel%
       AND A2_FILIAL = %exp:xFilial("SA2")%  
       AND A2_P_GER  = ' '  
       AND A2_CGC <> ' '
       AND A2_TIPO <> ' '
       ORDER BY A2_COD
       
    EndSql
    
    
	If Select("TempSA4") > 0
		TempSA4->(DbCloseArea())	               
  	EndIf
    
    //Seleciona transportadoras que não foram gerados A4_P_GER branco
    BeginSql Alias 'TempSA4'
       SELECT *
       FROM %Table:SA4%
       WHERE %notDel%
       AND A4_FILIAL = %exp:xFilial("SA4")%  
       AND A4_P_GER  = ' ' 
       AND A4_CGC <> ' '
       ORDER BY A4_COD
       
    EndSql

    TempSA1->(DbGoTop())
    TempSA2->(DbGoTop())
    TempSA4->(DbGoTop())
    If ( TempSA1->(!BOF() .and. !EOF()) ) .Or.  ( TempSA2->(!BOF() .and. !EOF()) ) .Or.  ( TempSA4->(!BOF() .and. !EOF()) )
         
		cSA1Txt:=cDir+cNum

		nSA1Hdl:= fCreate(cSA1Txt)
  		If nSA1Hdl == -1 // Testa se o arquivo foi gerado
    		MsgAlert("O arquivo "+cSA1Txt+" nao pode ser executado!","Atenção")  
    		Return .F.
      	EndIf  
      	
      	nTamLin   := 2   
	  	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	  	cCab  	  := Stuff(cCab,01,02,"YY")                             // FIXO      
    	    	
    	If fWrite(nSA1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   		If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho YY (Var:cCab). ","Atencao!")
    			Return .F. 
    		Endif 
    	EndIf    
        		           
		While TempSA1->(!EOF())   
		    	 
			// Vetor para workflow aSA1  1.Codigo,2.Nome,3.Tipo,4.CNPJ,5.Loja      
   			Aadd(aSA1,{TempSA1->A1_COD,TempSA1->A1_NOME,"1",TempSA1->A1_CGC,TempSA1->A1_LOJA})     			
    	    	
    		nTamLin   := 560   
	     			
			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
    	
    	    cCab  := Stuff(cCab, 01,02,"KF")               		      	      // Fixo com "XT"                      
        	cCab  := Stuff(cCab, 03,14,TempSA1->A1_CGC)                   	  // CNJP         			        			
        	cCab  := Stuff(cCab, 17,12,space(12))                   	      // Branco   
        	cCab  := Stuff(cCab, 29,30,TempSA1->A1_CGC)                   	  // CNPJ   
        	cCab  := Stuff(cCab, 59,01,TempSA1->A1_PESSOA)                 	  // Tipo do cliente           	        	
        	cCab  := Stuff(cCab, 60,60,TempSA1->A1_NOME)                   	  // Nome do cliente    
        	cCab  := Stuff(cCab,120,60,TempSA1->A1_END)                   	  // Logradouro  
        	cCab  := Stuff(cCab,180,08,space(8))                     	      // Número 
        	cCab  := Stuff(cCab,188,60,Substr(TempSA1->A1_COMPLEM,1,60))      // Complemento  
        	cCab  := Stuff(cCab,248,60,TempSA1->A1_BAIRRO)                    // Bairro
        	cCab  := Stuff(cCab,308,60,TempSA1->A1_MUN)                       // Cidade
        	cCab  := Stuff(cCab,368,02,TempSA1->A1_EST)                       // Estado
        	cCab  := Stuff(cCab,370,08,TempSA1->A1_CEP)                       // Cep	
        	cCab  := Stuff(cCab,378,60,TempSA1->A1_CONTATO+space(45))         // Contato
        	cCab  := Stuff(cCab,438,20,TempSA1->A1_TEL+space(5))              // Telefone
        	cCab  := Stuff(cCab,458,20,TempSA1->A1_FAX+space(5))              // Fax	
        	cCab  := Stuff(cCab,478,61,Substr(TempSA1->A1_EMAIL,1,61))        // Email	
         	cCab  := Stuff(cCab,539,20,TempSA1->A1_INSCR+space(2))            // Inscrição estadual	
         	cCab  +=cEOL 
         	       	   	        
    	   	If fWrite(nSA1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho E0 (Var:cCab). ","Atencao!")
    				Return .F. 
    			Endif 
    		EndIf  
        		      
    	    TempSA1->(DbSkip()) 
    		    
    	EndDo  
    	    	
    	While TempSA2->(!EOF())   
		    	 
			// Vetor para workflow aSA1  1.Codigo,2.Nome,3.Tipo,4.CNPJ,5.Loja     
   			Aadd(aSA1,{TempSA2->A2_COD,TempSA2->A2_NOME,"2",TempSA2->A2_CGC,TempSA2->A2_LOJA}) 
    	    	
    		nTamLin   := 560   
	     			
			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
    	
    	    cCab  := Stuff(cCab,01,02,"XT")               		      	      // Fixo com "XT"                      
        	cCab  := Stuff(cCab,03,14,TempSA2->A2_CGC)                   	  // CNJP         			        			
        	cCab  := Stuff(cCab,17,12,space(12))                   	          // Branco   
        	cCab  := Stuff(cCab,29,30,TempSA2->A2_CGC)                   	  // CNPJ   
        	cCab  := Stuff(cCab,59,01,TempSA2->A2_TIPO)                 	  // Tipo do forncedor          	        	
        	cCab  := Stuff(cCab,60,60,TempSA2->A2_NOME)                   	  // Nome do forncedor  
        	cCab  := Stuff(cCab,120,60,TempSA2->A2_END)                   	  // Logradouro  
        	cCab  := Stuff(cCab,180,08,space(8))                     	      // Número 
        	cCab  := Stuff(cCab,188,60,TempSA2->A2_COMPLEM)                   // Complemento  
        	cCab  := Stuff(cCab,248,60,TempSA2->A2_BAIRRO)                    // Bairro
        	cCab  := Stuff(cCab,308,60,TempSA2->A2_MUN)                       // Cidade
        	cCab  := Stuff(cCab,368,02,TempSA2->A2_EST)                       // Estado
        	cCab  := Stuff(cCab,370,08,TempSA2->A2_CEP)                       // Cep	
        	cCab  := Stuff(cCab,378,60,TempSA2->A2_CONTATO+space(45))         // Contato
        	cCab  := Stuff(cCab,438,20,TempSA2->A2_TEL+space(5))              // Telefone
        	cCab  := Stuff(cCab,458,20,TempSA2->A2_FAX+space(5))              // Fax	
        	cCab  := Stuff(cCab,478,61,TempSA2->A2_EMAIL)                     // Email	
         	cCab  := Stuff(cCab,539,20,TempSA2->A2_INSCR+space(2))            // Inscrição estadual				        			
   	        cCab  +=cEOL  
   	        
    	   	If fWrite(nSA1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho E0 (Var:cCab). ","Atencao!")
    				Return .F. 
    			Endif 
    		EndIf  
        		      
    	    TempSA2->(DbSkip()) 
    		    
    	EndDo  
    	   	
    	While TempSA4->(!EOF())   
		    	 
			// Vetor para workflow aSA1  1.Codigo,2.Nome,3.Tipo,4.CNPJ,5.Loja    
   			Aadd(aSA1,{TempSA4->A4_COD,TempSA4->A4_NOME,"3",TempSA4->A4_CGC," "}) 
    	    	
    		nTamLin   := 560   
	     			
			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
    	
    	    cCab  := Stuff(cCab,01,02,"XT")               		      	      // Fixo com "XT"                      
        	cCab  := Stuff(cCab,03,14,TempSA4->A4_CGC)                     	  // CNJP         			        			
        	cCab  := Stuff(cCab,17,12,space(12))                   	          // Branco   
        	cCab  := Stuff(cCab,29,30,TempSA4->A4_CGC)                   	  // CNPJ   
        	cCab  := Stuff(cCab,59,01,"J")                       	          // Juridico       	        	
        	cCab  := Stuff(cCab,60,60,TempSA4->A4_NOME)                   	  // Nome da transportadora    
        	cCab  := Stuff(cCab,120,60,TempSA4->A4_END)                   	  // Logradouro  
        	cCab  := Stuff(cCab,180,08,space(8))                     	      // Número 
        	cCab  := Stuff(cCab,188,60,TempSA4->A4_COMPLEM)                   // Complemento  
        	cCab  := Stuff(cCab,248,60,TempSA4->A4_BAIRRO)                    // Bairro
        	cCab  := Stuff(cCab,308,60,TempSA4->A4_MUN)                       // Cidade
        	cCab  := Stuff(cCab,368,02,TempSA4->A4_EST)                       // Estado
        	cCab  := Stuff(cCab,370,08,TempSA4->A4_CEP)                       // Cep	
        	cCab  := Stuff(cCab,378,60,TempSA4->A4_CONTATO+space(45))         // Contato
        	cCab  := Stuff(cCab,438,20,TempSA4->A4_TEL+space(5))              // Telefone
        	cCab  := Stuff(cCab,458,20,space(20))                             // Fax	
        	cCab  := Stuff(cCab,478,61,TempSA4->A4_EMAIL)                     // Email	
         	cCab  := Stuff(cCab,539,20,TempSA4->A4_INSEST+space(2))           // Inscrição estadual			        			
   	        cCab  +=cEOL 
   	        
    	   	If fWrite(nSA1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho E0 (Var:cCab). ","Atencao!")
    				Return .F. 
    			Endif 
    		EndIf  
        		      
    	    TempSA4->(DbSkip()) 
    		    
    	EndDo  
    	
    	nTamLin   := 2   
	   	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	    cCab  	  := Stuff(cCab,01,02,"WW")                             // FIXO      

		If fWrite(nSA1Hdl,cCab,Len(cCab)) != (Len(cCab))
  			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho WW (Var:cCab). ","Atencao!")
     			Return .F. 
        	Endif 
     	EndIf   
			     

    	fClose(nSA1Hdl)
             	                                   	        
    	//Atualiza gerados        	
     	For i:=1 to Len(aSA1)
         	                             
         	//Cliente
         	If Alltrim(aSA1[i][3]) == "1"         		 
         		SA1->(DbSetOrder(1))
         		If SA1->(DbSeek(xFilial("SA1")+aSA1[i][1]+aSA1[i][5]))	
          	   		RecLock("SA1",.F.) 
              		SA1->A1_P_GER   :="S"
               		SA1->A1_P_ARQ   :=cNum   
             		SA1->A1_P_USER  :=alltrim(cUserName)          	
               		SA1->(MsUnlock())
                 EndIf
         	//Forncedor
            ElseIf Alltrim(aSA1[i][3]) == "2"         		 
         		SA2->(DbSetOrder(1))
         		If SA2->(DbSeek(xFilial("SA2")+aSA1[i][1]+aSA1[i][5]))	
          	   		RecLock("SA2",.F.) 
              		SA2->A2_P_GER   :="S"
               		SA2->A2_P_ARQ   :=cNum   
             		SA2->A2_P_USER  :=alltrim(cUserName)          	
               		SA2->(MsUnlock())
                 EndIf                
            //Transportadora
         	ElseIf Alltrim(aSA1[i][3]) == "3"         		 
         		SA4->(DbSetOrder(1))
         		If SA4->(DbSeek(xFilial("SA4")+aSA1[i][1]+aSA1[i][5]))	
          	   		RecLock("SA4",.F.) 
              		SA4->A4_P_GER   :="S"
               		SA4->A4_P_ARQ   :=cNum   
             		SA4->A4_P_USER  :=alltrim(cUserName)          	
               		SA4->(MsUnlock())  
               	EndIf	                          
          	EndIf                             	
            
 		Next 
          
              	
        MsgInfo("Arquivo: "+Alltrim(cNum)+" gerado com sucesso.","Shiseido")    
          
        EMail(aSA1,"CLI")
          	
           
    Else
    	MsgStop("Não existem clientes para integração, verificar.","Shiseido")  

    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet 


/*
Funcao      : R7PRO
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivos de interface de produtos
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/         

*-------------------------*    
  Static Function R7PRO()    
*-------------------------*    
           
Local lRet     := .T.

Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\ftp\R7\Shuttle\Produto\"     
Local cCab      := ""   
Local cSB1Txt   := ""
Local cSeq      := ""

Local n         := 1     
Local nSB1Hdl   := 0
 
Local aSB1      := {}

Private cNum    := "P_"+DTOS(dDataBase)+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".txt
         
cEOL := Trim(cEOL)
cEOL := &cEOL       

Begin Sequence 

	If Select("TempSB1") > 0
		TempSB1->(DbCloseArea())	               
  	EndIf
    
    BeginSql Alias 'TempSB1'
       SELECT *
       FROM %Table:SB1%
       WHERE %notDel%
       AND B1_FILIAL = %exp:xFilial("SB1")%  
       AND B1_P_GER  = ' '   
       AND B1_P_MULTB = '064' 
       AND B1_POSIPI <> ' ' 

       ORDER BY B1_COD
       
    EndSql


    TempSB1->(DbGoTop())
    If TempSB1->(!BOF() .and. !EOF())
         

		cSB1Txt:=cDir+cNum

		nSB1Hdl:= fCreate(cSB1Txt)
  		If nSB1Hdl == -1 // Testa se o arquivo foi gerado
    		MsgAlert("O arquivo "+cSB1Txt+" nao pode ser executado!","Atenção")  
    		Return .F.
      	EndIf 
      	
      	nTamLin   := 2   
	  	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
	  	cCab  	  := Stuff(cCab,01,02,"YY")                             // FIXO      

    	If fWrite(nSB1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   		If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho YY (Var:cCab). ","Atencao!")
    			Return .F. 
    		Endif 
    	EndIf    
        		         	
                 
		While TempSB1->(!EOF())   
		    	 
			// Vetor para workflow aSB1  1.Produto,2.Descrição    
   			Aadd(aSB1,{TempSB1->B1_COD,TempSB1->B1_DESC}) 
    	    	
    		nTamLin   := 706   
	     			
			cCab      := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
    	
    	    cCab  := Stuff(cCab,01,02,"XT")               		      	  // Fixo com "XT"                      
        	cCab  := Stuff(cCab,03,14,SM0->M0_CGC)                   	  // CNPJ da filial          			        			
		 	cCab  := Stuff(cCab,17,08,space(12))   	                      // Em branco, sem uso  
     		cCab  := Stuff(cCab,29,30,TempSB1->B1_COD)                    // Codigo do produto
      		cCab  := Stuff(cCab,59,30,TempSB1->B1_DESC)                   // Descrição do produto
      		cCab  := Stuff(cCab,119,300,space(300))                       // Descrição longa do  produto
      		cCab  := Stuff(cCab,419,10,TempSB1->B1_POSIPI)                // NCM
    	    cCab  := Stuff(cCab,429,03,"UN ")                             // Unidade de medida fixo
    	    cCab  := Stuff(cCab,432,03,"UN ")                             // Unidade de medida fixo
    	    cCab  := Stuff(cCab,435,04,"0001")                            // Fixo 
    	    cCab  := Stuff(cCab,439,03,"UN ")                             // Unidade de medida fixo
     	    cCab  := Stuff(cCab,442,03,"0001")                            // Qtde. unidades expedição - fixo
     	    cCab  := Stuff(cCab,446,03,Replicate("0",96))                 // Dados de peso / altura / comprimemento    
   
 			SB1->(DbSetOrder(1))
     	    If SB1->(DbSeek(xFilial("SB1")+TempSB1->B1_COD))
     	    	If SB1->B1_RASTRO == "L"
					cCab  := Stuff(cCab,542,01,"D")                         // D lote SIM    	    	
     	    	Else     
     	       		cCab  := Stuff(cCab,542,01,"N")                         // N lote Nao      	    	
     	    	EndIF
     	    
     	    EndIf
     	    
     	    cCab  := Stuff(cCab,543,03,"999")                        	    // Num. dias validade	    
      	    cCab  := Stuff(cCab,546,01,"V")                          	    //Fixo - V - Validade
      	    
      	    cCab  := Stuff(cCab,547,30,"12583"+space(25))                   // Dados de departamento  
      	    cCab  := Stuff(cCab,577,30,"0"+space(29))						// Setor  
      	    cCab  := Stuff(cCab,607,30,"0"+space(29))						// Familia
      	    cCab  := Stuff(cCab,637,30,"0"+space(29))						//  Sub-familia         	    
      	    cCab  := Stuff(cCab,667,06,Replicate("0",6))                    // Dados de caixa de pallet e altura de pallet 
      	    cCab  := Stuff(cCab,673,13,"0000000000000")                     // Fixo  
      	    cCab  := Stuff(cCab,686,01,Replicate(" ",1))                    // Classificassao ABC  
      	    cCab  := Stuff(cCab,687,03,SM0->M0_INSC+space(6))               // Inscrição estadual   
      	    
      	       	        
    	   	If fWrite(nSB1Hdl,cCab,Len(cCab)) != (Len(cCab))
  	   			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho XT (Var:cCab). ","Atencao!")
    				Return .F. 
    			Endif 
    		EndIf  
        		      
    	    TempSB1->(DbSkip()) 
    		    
    	EndDo 
  
		nTamLin   := 2   
	 	cCab      := Space(nTamLin)+cEOL 								// Variavel para criacao da linha do registros para gravacao
		cCab  	  := Stuff(cCab,01,02,"WW")                             // FIXO      

		If fWrite(nSB1Hdl,cCab,Len(cCab)) != (Len(cCab))
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho WW (Var:cCab). ","Atencao!")
				Return .F. 
			Endif 
		EndIf   
			          	
    	fClose(nSB1Hdl)   
    	                                   	        
    	// Atualiza SB1        	
     
     	For i:=1 to Len(aSB1)
         	         		 
         	SB1->(DbSetOrder(1))
         	If SB1->(DbSeek(xFilial("SB1")+aSB1[i][1]))	
          		RecLock("SB1",.F.) 
             	SB1->B1_P_GER   :="S"
             	SB1->B1_P_ARQ   :=cNum   
             	SB1->B1_P_USER  :=alltrim(cUserName)          	
               	SB1->(MsUnlock())
             	SB1->(DbSkip())                     
          	EndIf 
            
 		Next   
              	
        MsgInfo("Arquivo: "+Alltrim(cNum)+" gerado com sucesso.","Shiseido")    
          
        EMail(aSB1,"PRO")
          	
           
    Else
    	MsgStop("Não existem produtos para integração, verificar.","Shiseido")  
    	TempSB1->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet 
      
/*
Funcao      : Email
Parametros  : aDados,cTipo
Retorno     : Nenhum
Objetivos   : Enviar notificação da interface
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/  

*------------------------------------*
  Static Function Email(aDados,cTipo)
*------------------------------------*  

Local cSubject     := ""
Local cNome        := ""  
Local cNf          := ""
Local cDestinatario:= GetMv("MV_P_EMAIL",,"")   //" tiago.mendonca@hlb.com.br"  // Para testes, fora do ambiente produção.  

Local cUserEmp1 := GetMv("MV_P_EMP01",,"")//JVR - 27/03/12 - Inserido o valor Defalt.
Local cUserEmp2 := GetMv("MV_P_EMP02",,"")
    

	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
 	cEmail += '<title>Nova pagina 1</title></head><body>'
  	cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
   	cEmail += 'Detalhes do arquivo </b></u></font></p>'   
   	    
   	//arquivo de entrada
   	If cTipo == "ENT" 
   	
   		cEmail += '<p><font face="Courier New" size="2">Arquivos de entrada  disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente as notas de entrada: ' 
    	         	         	             
    //arquivo de pedido	
    ElseIf cTipo == "SAI"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos de saida  disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente a notas de saídas : '             
             
    //arquivo de saída    
    ElseIf cTipo == "CLI"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cNum+" disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente a clientes,forncedores e transportadoras : '     

    //arquivo de materiais	
    ElseIf cTipo == "PRO"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cNum+" disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente a produtos :  '     
    
    EndIf  
          
    cEmail += '<br>'   
   	cEmail += '<br>'           	 		
	cEmail += '<br>' 
          	
	For i:=1 to Len(aDados)
		
		If cTipo == "ENT"
			
			//aNfeEnt  1.Documento,2.Serie,3.Fornecedor,4.Loja,5.Tipo,6.arquivo  ( F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_TIPO )
			IF aDados[i][5] == "D"  
				SA1->(DbSetOrder(1))
         		If SA1->(DbSeek(xFilial("SA1")+aDados[i][3]+aDados[i][4]))
         			cNome:=SA1->A1_NOME
         		EndIf 
			Else
				SA2->(DbSetOrder(1))
         		If SA2->(DbSeek(xFilial("SA2")+aDados[i][3]+aDados[i][4]))
         			cNome:=SA2->A2_NOME
         		EndIf  
			EndIf
			
			cSubject:= " Arquivo de integracao "+alltrim(aDados[i][6])+" Shiseido/Shuttle disponivel no FTP " 
			   

			cEmail += '	<tr>'
   			cEmail += '		<td width="40"><font face="Courier New" size="2">Nota Entrada: '+aDados[i][1]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Serie: '+aDados[i][2]+'</font></td>'   
			If alltrim(aDados[i][5]) =="N"
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Tipo Normal</font></td>'    
		 	ElseIf alltrim(aDados[i][5]) =="D"	
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Tipo Devolução</font></td>' 
		   	ElseIf alltrim(aDados[i][5]) =="B"	
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Tipo Beneficiamento</font></td>' 
			EndIf
			
			cEmail += '		<td width="378"><font face="Courier New" size="2">Fornecedor: '+aDados[i][3]+" "+Alltrim(cNome)+'</font></td>'  

			cEmail += '	</tr>'
			cEmail += '<br>'    
			
			
		ElseIf cTipo == "SAI"    
		     
			//aNfeSai 1.DOC,2.SERIE,3.FORNECE,4.LOJA,5.TIPO,6.Arquivo
			SA1->(DbSetOrder(1))
   			If SA1->(DbSeek(xFilial("SA1")+aDados[i][3]+aDados[i][4]))
      			cNome:=SA1->A1_NOME
         	EndIf                                   
         	
         	cSubject:= " Arquivo de integracao "+alltrim(aDados[i][6])+" Shiseido/Shuttle disponivel no FTP "   
         	
         	If aDados[i][1] <> cNf
		   		
		   		cEmail += '	<tr>'
   				cEmail += '		<td width="40"><font face="Courier New" size="2">Nota Saida: '+aDados[i][1]+'</font></td>'
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Serie: '+aDados[i][2]+'</font></td>'        
		   		cEmail += '		<td width="378"><font face="Courier New" size="2">Cliente: '+aDados[i][3]+" "+Alltrim(cNome)+'</font></td>'  
		   		cEmail += '	</tr>'
		    	cEmail += '<br>'  
		    	
		    	cNf:=aDados[i][1] 
		    	
		    EndIf
		   			
		ElseIf cTipo == "CLI"    
		     
    	    //aSA1  1.Codigo,2.Nome,3.Tipo,4.CNPJ   
			cSubject:= " Arquivo de integracao "+alltrim(cNum)+" Shiseido/Shuttle disponivel no FTP "    
			
			cEmail += '	<tr>'
   			cEmail += '		<td width="40"><font face="Courier New" size="2">Cliente: '+aDados[i][1]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">CNPJ :'+aDados[i][4]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Nome :'+aDados[i][2]+'</font></td>'

			cEmail += '	</tr>'
			cEmail += '<br>'  		  
							
		ElseIf cTipo == "PRO"    
		    
		    If i < 200 // Para não estourar o html
		     
    	    	//aSB1  1.Produto,2.Descrição    
				cSubject:= " Arquivo de integracao "+alltrim(cNum)+" Shiseido/Shuttle disponivel no FTP "    
				
				cEmail += '	<tr>'
   				cEmail += '		<td width="40"><font face="Courier New" size="2">Produto: '+aDados[i][1]+'</font></td>'
				cEmail += '		<td width="113"><font face="Courier New" size="2">Descrição: '+aDados[i][2]+'</font></td>'
		   		cEmail += '	</tr>'
				cEmail += '<br>'  		  
			     
			
			EndIf
		
							
		EndIf		
   
	Next  
			
    cEmail += '<br>'   
    cEmail += '<br>'            	
          	 
    cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
    cEmail += '<p align="center">www.grantthornton.com.br</p>'
    cEmail += '</body></html>'
	  
    oEmail          :=  DEmail():New()
    oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
    oEmail:cTo		:=  cDestinatario // AllTrim(GetMv("MV_P_EMAIL"))   // Ex: "tiago.mendonca@hlb.com.br" 
    oEmail:cSubject	:=	cSubject
    oEmail:cBody   	:= 	cEmail
    //oEmail:cAnexos   :=  cFile
    oEmail:Envia()
 
 	//FErase(cFile)     

Return 


/*
Funcao      : MarcaTds
Parametros  : cTipo
Retorno     : lRet
Objetivos   : Função para selecionar todos os registros do temporario.
Autor     	: Tiago Luiz Mendonça
Data     	: 26/03/2012 
*/  

*---------------------------------*
  Static Function MarcaTds(cTipo)
*---------------------------------* 
  
//Entrada  
If cTipo == "ENT"   
	DbSelectArea("TempSF1")   
 	TempSF1->(DbGoTop())  
  	While TempSF1->(!EOF())
    	RecLock("TempSF1",.F.)     
     	If TempSF1->cINTEGRA == cMarca
     		TempSF1->cINTEGRA:=Space(02)   
        Else
      		TempSF1->cINTEGRA:= cMarca
        EndIf 
        TempSF1->(MsUnlock())
        TempSF1->(DbSkip())
    EndDo         
    TempSF1->(DbGoTop())      
EndIf 

//Saida
If cTipo == "SAI"   
	DbSelectArea("TempSF2")   
 	TempSF2->(DbGoTop())  
  	While TempSF2->(!EOF())
    	RecLock("TempSF2",.F.)     
     	If TempSF2->cINTEGRA == cMarca
     		TempSF2->cINTEGRA:=Space(02)   
        Else
      		TempSF2->cINTEGRA:= cMarca
        EndIf 
        TempSF2->(MsUnlock())
        TempSF2->(DbSkip())
    EndDo         
    TempSF2->(DbGoTop())      
EndIf     
      
Return 

