#include "Protheus.ch"
#include "Rwmake.ch"
     
/*
Funcao      : ISEICINT
Parametros  : 
Retorno     : 
Objetivos   : Integração e Geração de arquivos Promega
Autor       : Tiago Luiz Mendonça
Data        : 25/04/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 


//Função de inclusão de S.I no EIC
*-------------------------*
 User Function ISEICINT()
*-------------------------*
 
Local oMain, oDlg 
Local lRet:=.F.  
Private cArquivo := "C:\"+Space(50)   
Private cArq    


  If !(cEmpAnt $ "IS/IJ")
     MsgInfo("Especifico PROMEGA"," A T E N C A O ")  
     Return .F.
  Endif                     
                
//Tela para selecão do arquivo
DEFINE MSDIALOG oDlg TITLE "Selecione o arquivo" From 1,5 To 12,40 OF oMain  

	@ 015,105 BmpButton Type 14 Action LoadArq()
	@ 015,010 Get cArquivo Size 090,10 OF oDlg PIXEL 
	@ 050,080 BUTTON "Cancela" size 40,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
 	@ 050,030 BUTTON "Ok" size 40,15 ACTION Processa({|| lRet:=ExistArq(),;
                                                                 If(lRet,lRet:=ProcTxt(),),;
                                                                 If(lRet,oDlg:End(),"")}) of oDlg Pixel        
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return Nil   


//Função Principal para geração de arquivos.
*-------------------------*
 User Function ISGERARQ()
*-------------------------*
 
Local oMain, oDlg , oCbx 
Local lRet:=.F.
Local aItens:={"Todos não gerados","Data de hoje "+Alltrim(DTOC(date()))} 
Private cOpc 

//Tela de geração de arquivos.
DEFINE MSDIALOG oDlg TITLE "Geração de arquivo FTP" From 1,15 To 25,50 OF oMain  

	@ 010,020 BUTTON "ARQUIVO DE ENTRADAS" size 100,15 ACTION Processa({|| ISEstInt() }) of oDlg Pixel  
 	@ 030,020 BUTTON "ARQUIVO DE PEDIDOS"  size 100,15 ACTION Processa({|| ISPedInt() }) of oDlg Pixel                                                            
    @ 050,020 BUTTON "ARQUIVO DE SAIDA"    size 100,15 ACTION Processa({|| ISSaiInt() }) of oDlg Pixel   
    @ 070,020 BUTTON "ARQUIVO DE RETORNO"  size 100,15 ACTION Processa({|| ISRetInt() }) of oDlg Pixel  
    @ 090,020 BUTTON "ARQUIVO DE MAT" size 100,15 ACTION Processa({|| ISConfInt()}) of oDlg Pixel  
    
    @ 115,020 TO 110,117 LABEL "Agrupar dados por :" OF oDlg Pixel    
    @ 123,030  RADIO oCbx VAR cOpc ITEMS aItens[1],aItens[2] Pixel Size 080,120 of oDlg 
    @ 150,020 BUTTON "Cancela" size 100,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel                                                                 
                                                                        
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return Nil 

// Verifica se foi informado arquivo
*------------------------------*
  Static Function ExistArq()
*-----------------------------*        

If Len(Alltrim(cArquivo)) <= 3 
	MsgAlert("Arquivo inválido.")
	lRet:=.F.
Else
	lRet:=.T.     
EndIf

Return lRet  


// Carrega o arquivo
*----------------------------*
  Static Function LoadArq()
*----------------------------*

Local cType    := "Arq.  | *.TXT"
 

cArquivo := cGetFile(cType,"Selecione arquivo"+Subs(cType,1,6),1,'C:\',.T.,( GETF_LOCALHARD + GETF_LOCALFLOPPY ) ,.T.)
cArquivo := Upper(AllTrim(cArquivo))
                            
nPos:=At("\",Alltrim(cArquivo))   
cArq:=cArquivo
While 0 < nPos                          
   cArq:=Alltrim(SubStr(cArq,nPos+1,Len(alltrim(cArq))))
   nPos:=At("\",Alltrim(cArq))   
EndDo 

Return Nil  

// Le o arquivo
*------------------------------*
  Static Function ProcTxt()
*------------------------------*

Local aStruSW1  
Local cNum,cLinha,cInv,cHawb,cAux
Local cMsgSB1:=cMsgSA5:=cProd:=""     
Local lRet:=.F.
Local nReg:=1  
Local lok:=.T.                                
                                  
	If Select("Int_SW1")>0
		Int_SW1->(DBCLoseArea())  	
	EndIf

	aStruSW1 := SW1->(dbStruct())
	cNomeSW1 := CriaTrab(aStruSW1, .T.)                   
	DbUseArea(.T.,,cNomeSW1,'Int_SW1',.F.,.F.)       

	For nSW1:= 1 To Len(aStruSW1)
    	If aStruSW1[nSW1][2] <> "C" .and.  FieldPos(aStruSW1[nSW1][1]) > 0
     		TcSetField("Int_SW1",aStruSW1[nSW1][1],aStruSW1[nSW1][2],aStruSW1[nSW1][3],aStruSW1[nSW1][4])
        EndIf
 	Next

	If File(cArquivo)
	   
		FT_FUse(cArquivo)
	 	FT_FGOTOP()
	     
	  	cLinha := FT_FReadLn() 
	  	
	  	//Numereção SI
	  	SX5->(DbSetOrder(1))
    	If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"SW0")) 
               
        	cNum:=SX5->X5_DESCRI
	        cHawb :=SubStr(cLinha,125,14) 
	        
	        //Valida a numeração da SI  
	        //CC fixo 
	        SW0->(DbSetOrder(1))
	        If SW0->(DbSeek(xFilial("SW0")+"001  "+alltrim(cNum)))
	        	cNum:=StrZero(Val(cNum)+1,6)
	        	While lOk
	        		If SW0->(DbSeek(xFilial("SW0")+"001  "+alltrim(cNum)))
	        			cNum:=StrZero(Val(cNum)+1,6)	        	
	        	    Else
	        	    	lOK:=.F. 	
	        	    EndIf   
	        		SW0->(DbSkip())    
	        	EndDo
	        EndIf	
	          	 
	           	     
	    	While !FT_FEof()
            
            	cLinha := FT_FReadLn()
             
            	//Testa se é mesmo produto para o registro nReg
            	If alltrim(cProd)<>Alltrim(SubStr(cLinha,05,15))
            		nReg:=1
            		cProd:=SubStr(cLinha,05,15)
            	Else
            		nReg++
            	EndIf
            	           
	            //Valida se o item existe.
	            SB1->(DbSetOrder(1))
	            If SB1->(DbSeek(xFilial("SB1")+cProd ))
		    		 		    				    		
		    		//Fabricante e Fornecedor deve estar preenchido no cadastro de produto.
		    		If Empty(SB1->B1_P_FABR) .Or. Empty(SB1->B1_PROC) 
		    		
						If Len(cMsgSA5) <  400
							cMsgSA5+=Alltrim(SubStr(cLinha,05,15))+ " / " 
						EndIf	 
							
					Else  
					
						//Valida se o cadastro Produto x Fornecedor existe. 
		    			SA5->(DbSetOrder(3))
		    			If SA5->(DbSeek(xFilial("SA5")+SubStr(cLinha,05,15)+SB1->B1_P_FABR+SB1->B1_PROC)) 	
		    		
		    				RecLock("Int_SW1",.T.)
		    				Int_SW1->W1_FILIAL   := xFilial("SW1")   
		    				Int_SW1->W1_P_SEQ    :=	SubStr(cLinha,01,04)	    
			   				Int_SW1->W1_COD_I    := SubStr(cLinha,05,15)
							Int_SW1->W1_FABR     := SB1->B1_P_FABR
							Int_SW1->W1_FORN	 := SB1->B1_PROC	
							
							//Porduto deve ter quantidade
							If val(SubStr(cLinha,65,10)) < 0.01
								MsgStop("Produto "+Alltrim(SubStr(cLinha,05,15))+" não possui quantidade, necessario corrigir.","Promega" ) 
								Int_SW1->(DbCloseArea())  
								Return .F. 								
							Else
								Int_SW1->W1_QTDE     :=  Val(SubStr(cLinha,65,10))/100
							EndIf     
							
							Int_SW1->W1_SALDO_Q  := Int_SW1->W1_QTDE
				   			Int_SW1->W1_PRECO    := SB1->B1_CUSTD   // Custo Standart - (Val(SubStr(cLinha,100,10))/100 ) / Int_SW1->W1_QTDE
							Int_SW1->W1_CLASS    := "1"
							Int_SW1->W1_SEQ      := 0	 
				   			Int_SW1->W1_REG      := nReg
							Int_SW1->W1_CC       := "001"   
				   			Int_SW1->W1_SI_NUM   := cNum  
				   			Int_SW1->W1_P_INV	 := SubStr(cLinha,110,14)
				   			
				   			//Testa se o produto possui lote
				   			SB1->(DbSetOrder(1))
				   			IF SB1->(DbSeek(xFilial("SB1")+Alltrim(SubStr(cLinha,05,15))))
				   				If Alltrim(SB1->B1_RASTRO)=="L"	
				   					If Empty(SubStr(cLinha,75,15)) .Or. Empty(SubStr(cLinha,90,4)+SubStr(cLinha,95,2)+SubStr(cLinha,98,2))       
							   			MsgStop("Produto "+Alltrim(SubStr(cLinha,05,15))+" não possui lote ou data de vencimento, necessario corrigir.","Promega" ) 
							   			Int_SW1->(DbCloseArea())  
							   	   		Return .F.
									Else 
										Int_SW1->W1_P_LOTE   := SubStr(cLinha,75,15) 
										cAux:=SubStr(cLinha,90,4)+SubStr(cLinha,95,2)+SubStr(cLinha,98,2) 
										Int_SW1->W1_P_DTLOT  := Stod(cAux)  
								    EndIf
								EndIf
							EndIf 
							
	                    	Int_SW1->(MsUnlock())
	
                   		Else 
                   		     
                   			//Inclui vinculo do SA5
                   			RecLock("SA5",.T.)		    
			   				SA5->A5_FILIAL   := xFilial("SA5")   
			   				SA5->A5_FORNECE  := SB1->B1_PROC
							SA5->A5_LOJA     := SB1->B1_LOJPROC
							SA2->(DbSetOrder(1))
							If SA2->(DbSeek(xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC))
								SA5->A5_NOMEFOR  := SA2->A2_NOME 
							EndIf
							SA5->A5_PRODUTO  := SB1->B1_COD
							SA5->A5_NOMPROD  := SB1->B1_DESC
							SA5->A5_FABR     := SB1->B1_P_FABR  
							SA5->A5_FALOJA   := SB1->B1_P_FLOJA	 
                   			SA5->(MsUnlock()) 
                   			
                   			//Inclui dados da SI
                   			RecLock("Int_SW1",.T.)		    
			   				Int_SW1->W1_FILIAL   := xFilial("SW1")   
			   				Int_SW1->W1_P_SEQ    :=	SubStr(cLinha,01,04)
			   				Int_SW1->W1_COD_I    := SubStr(cLinha,05,15)
							Int_SW1->W1_FABR     := SB1->B1_P_FABR
							Int_SW1->W1_FORN	 := SB1->B1_PROC	
							Int_SW1->W1_QTDE     := Val(SubStr(cLinha,65,10))/100
							Int_SW1->W1_SALDO_Q  := Int_SW1->W1_QTDE
				   			Int_SW1->W1_PRECO    := SB1->B1_CUSTD // Custo Standart - (Val(SubStr(cLinha,100,10))/100 ) / Int_SW1->W1_QTDE) 
							Int_SW1->W1_CLASS    := "1"
							Int_SW1->W1_SEQ      := 0	 
				   			Int_SW1->W1_REG      := nReg
							Int_SW1->W1_CC       := "001"   
				   			Int_SW1->W1_SI_NUM   := cNum            
							Int_SW1->W1_P_INV	 := SubStr(cLinha,110,14)
							                    
							//Testa se possui lote.
							SB1->(DbSetOrder(1))
				   			IF SB1->(DbSeek(xFilial("SB1")+Alltrim(SubStr(cLinha,05,15))))
				   				If Alltrim(SB1->B1_RASTRO)=="L"	
				   					If Empty(SubStr(cLinha,75,15)) .Or. Empty(SubStr(cLinha,90,4)+SubStr(cLinha,95,2)+SubStr(cLinha,98,2))       
							   			MsgStop("Produto "+Alltrim(SubStr(cLinha,05,15))+" não possui lote ou data de vencimento, necessario corrigir.","Promega" ) 
							   			Int_SW1->(DbCloseArea())  
							   	   		Return .F.
									Else 
										Int_SW1->W1_P_LOTE   := SubStr(cLinha,75,15) 
										cAux:=SubStr(cLinha,90,4)+SubStr(cLinha,95,2)+SubStr(cLinha,98,2) 
										Int_SW1->W1_P_DTLOT  := Stod(cAux)  
								    EndIf
								EndIf
							EndIf
							
							Int_SW1->(MsUnlock())
                   			
       					EndIf            	    
            	    EndIf
				Else 
					If Len(cMsgSB1) <  400
			    		cMsgSB1+=Alltrim(SubStr(cLinha,05,15))+" / "  
			    	EndIf						
				EndIf  
				FT_FSkip()
					
			EndDo
	
		EndIf
	    	    
		If !Empty(cMsgSB1)
			MsgStop(cMsgSB1,"PRODUTO NAO CADASTRADO")
			Return .F.
		EndIf
	    
	   	If !Empty(cMsgSA5)
			MsgStop(cMsgSA5,"CHECAR FORN/FABR. NO PRODUTO")
			Return .F.
		EndIf                         
		
		If Select("QRY") > 0
  			QRY->(DbCloseArea())	               
     	EndIf
               
      	BeginSql Alias 'QRY'
        	SELECT R_E_C_N_O_ AS 'RECNUM'
         	FROM %Table:SW0%
            	WHERE %notDel%
             	AND W0_FILIAL = %exp:xFilial("SW0")%
              	AND W0_P_ARQ  = %exp:cArq%
        EndSql
        
        //Valida se o arquivo já foi integrado.       
        QRY->(DbGoTop())
        If QRY->(!BOF() .and. !EOF())   
        	MsgStop("Esse arquivo já foi integrado","Promega")
			Return .F.       
   		EndIf
		
		//Grava a S.I.   
		SW0->(DbSetOrder(1))
		If !(SW0->(DbSeek(xFilial("SW0")+cNum)))
			SW1->(DbSetOrder(1))
			If !(SW1->(DbSeek(xFilial("SW1")+cNum)))
		 		RecLock("SW0",.T.) 
	        	SW0->W0_FILIAL := xFilial("SW0")
		   		SW0->W0__CC    := "001"  
				SW0->W0__NUM   := cNum
		   		SW0->W0__DT    := dDataBase
		   		SW0->W0__POLE  := "01"
				SW0->W0_COMPRA := "01"
				SW0->W0_P_USER := Alltrim(cUserName)
				SW0->W0_P_DATA := Date()
				SW0->W0_P_ARQ  := cArq
				SW0->W0_P_HAWB := cHawb 
				SW0->W0_MOEDA  := "US$"
				SW0->W0_SOLIC  := "INTEGRADO POR ARQUIVO"
				
                SW0->(MsUnlock())
                
                Int_SW1->(DbGoTop())
                While Int_SW1->(!EOF())
                   
                	RecLock("SW1",.T.)
                	SW1->W1_FILIAL := Int_SW1->W1_FILIAL   
					SW1->W1_COD_I  := Int_SW1->W1_COD_I 
					SW1->W1_FORN   := Int_SW1->W1_FORN 
					SW1->W1_FABR   := Int_SW1->W1_FABR
					SW1->W1_QTDE   := Int_SW1->W1_QTDE   
					SW1->W1_SALDO_Q:= Int_SW1->W1_SALDO_Q  
					SW1->W1_PRECO  := Int_SW1->W1_PRECO    
					SW1->W1_CLASS  := Int_SW1->W1_CLASS   
					SW1->W1_SEQ    := Int_SW1->W1_SEQ      	 
				    SW1->W1_REG    := Int_SW1->W1_REG      
			   		SW1->W1_CC     := Int_SW1->W1_CC         
			   		SW1->W1_SI_NUM := Int_SW1->W1_SI_NUM              
					SW1->W1_P_LOTE := Int_SW1->W1_P_LOTE   
					SW1->W1_P_DTLOT:= Int_SW1->W1_P_DTLOT 
					SW1->W1_P_INV  := Int_SW1->W1_P_INV
					SW1->W1_DT_EMB := Date()
					SW1->W1_DTENTR_:= Date()+1 
					SW1->W1_P_SEQ  := Int_SW1->W1_P_SEQ              	
                	SW1->(MsUnlock())
                	  
                    Int_SW1->(DbSkip())
    			EndDo
    			    			
    			If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"SW0")) 
                    RecLock("SX5",.F.)  
                	SX5->X5_DESCRI:=StrZero(Val(cNum)+1,6)
                	SX5->(MsUnlock())    
                EndIf
                
                MsgInfo("S.I. : "+Alltrim(cNum)+" incluida com sucesso.")	
                	
				Int_SW1->(DbCloseArea())
						  			
			Else
				MsgStop("Número da S.I. invalido, entrar em contato com suporte","Promega")
			EndIf
		Else
			MsgStop("Número da S.I. invalido, entrar em contato com suporte","Promega")
		EndIf
	
	EndIf  
	
	
Erase &cNomeSW1+".DBF"
	
Return lRet				         

//Gera arquivo de Entrada
*-------------------------*
 Static Function ISESTINT()
*-------------------------*   

Local cWhereF,cWhereD
Local cSF1Txt,cSD1Txt
Local nSF1Hdl,nSD1Hdl
Local aNotas:={}  

Local cNum  := SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local cEOL  := "CHR(13)+CHR(10)" 
Local cDir  := "\\10.0.30.4\d$\Protheus10\Amb03\ftp\IS\ENTRADA\"    
Local cPath := AllTrim(GetTempPath()) 
Local cData := DTOS(Date()) 
Local cDtLote , cChave  
Local cContato:=""  
Local lDados :=.F.
         
Private cSF1Tit,cSD1Tit

cEOL := Trim(cEOL)
cEOL := &cEOL       
  
If !(MsgYesNo("Deseja realmente gerar o arquivo de ENTRADAS"))
	Return .F.
Endif
 
cWhereF := "%"		
If cOpc==2
	cWhereF +="	AND F1_EMISSAO = '"+cData+"'"
EndIf                                            
cWhereF += "%"   

cWhereD := "%"		
If cOpc==2
	cWhereD +="	AND D1_EMISSAO = '"+cData+"'"
EndIf                                            
cWhereD += "%"

//Nome do arquivo baseado na data + letra     
cNum := NomeArq(cNum,"ENT")    

Begin Sequence 
	
	If Select("FQRY") > 0
 		FQRY->(DbCloseArea())	               
   	EndIf
   	                
    BeginSql Alias 'FQRY'
       SELECT *
       FROM %Table:SF1%
       WHERE %notDel%
       AND F1_FILIAL = %exp:xFilial("SF1")%
       AND F1_P_GER  = ' '
       %exp:cWhereF%

       ORDER BY F1_DOC,F1_SERIE
       
    EndSql        
    
    If Select("DQRY") > 0
		DQRY->(DbCloseArea())	               
  	EndIf
    
    BeginSql Alias 'DQRY'
       SELECT *
       FROM %Table:SD1%
       WHERE %notDel%
       AND D1_FILIAL = %exp:xFilial("SD1")%
       AND D1_P_GER  = ' '
       %exp:cWhereD%

       ORDER BY D1_DOC,D1_SERIE
       
    EndSql
    
    FQRY->(DbGoTop())
    If FQRY->(!BOF() .and. !EOF())

       	cSF1Txt:=cDir+"RHB"+cNum+".TXT"
        cSF1Tit:="RHB"+cNum+".TXT"

		nSF1Hdl:= fCreate(cSF1Txt)
  		If nSF1Hdl == -1 // Testa se o arquivo foi gerado
    		MsgAlert("O arquivo "+cSF1Txt+" nao pode ser executado!","Atenção")
      	EndIf
 
    	While FQRY->(!EOF()) 
    	        
    	    Aadd(aNotas,{FQRY->F1_DOC,FQRY->F1_SERIE,FQRY->F1_FORNECE,FQRY->F1_LOJA,FQRY->F1_TIPO})  
    	     
    	    cChave:=FQRY->F1_DOC+FQRY->F1_SERIE+FQRY->F1_FORNECE+FQRY->F1_LOJA
    	    
    	    //Verifica se a nota atualiza estoque.
    	    SD1->(DbGoTop(1))
         	If SD1->(DbSeek(xFilial("SD1")+cChave))	
            	SF4->(DbSetOrder(1))
            	If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES)) 
            		If SF4->F4_ESTOQUE <> "S"  
            			FQRY->(DbSkip())
         				loop
            		EndIf
            	Else
            		//Nota não classificada
            		FQRY->(DbSkip())
         			loop            	
            	EndIf
            	
        	EndIf
        	
        	lDados:=.T.
    	     
    	    //119                     
       		nTamLin   := 129
        	cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
          	//   Cabeçalho                -----------       Comentários
        
        	cCab  := Stuff(cCab,01,03,"MEG")               // Fixo com "MEG"
      
                   
        	If FQRY->F1_TIPO =="N"
           		cCab  := Stuff(cCab,4,03,"TRB") 				// Tipo do recebimento 
        		SA2->(DbSetOrder(1))
            	If SA2->(DbSeek(xFilial("SA2")+FQRY->F1_FORNECE+FQRY->F1_LOJA))
            		cContato:=SA2->A2_CONTATO
				EndIf              	  
        	Else
           		cCab  := Stuff(cCab,4,03,"DEV") 		  		// Tipo do recebimento   
        		SA1->(DbSetOrder(1))
            	If SA1->(DbSeek(xFilial("SA1")+FQRY->F1_FORNECE+FQRY->F1_LOJA))
               		cContato:=SA1->A1_CONTATO
		   		EndIf   
        	EndIf   
                
        	cCab  := Stuff(cCab,07,10,FQRY->F1_DOC)             // Número da NF de entrada  
        	cCab  := Stuff(cCab,17,04,"VEN")              		// Fixo VEN 
        	cCab  := Stuff(cCab,21,02,FQRY->F1_SERIE)           // Serie da nota
        	cCab  := Stuff(cCab,23,06,space(6))              	// Origem da mercadoria
        	cCab  := Stuff(cCab,29,30,space(30))              	// Descrição da Origem 
       	   	cCab  := Stuff(cCab,59,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
       		cCab  := Stuff(cCab,69,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
       		cCab  := Stuff(cCab,79,30,space(30))       			 // Fonte de recebimento
       		cCab  := Stuff(cCab,109,01,"E")              		// Fonte de recebimento
        	cCab  := Stuff(cCab,110,06,"000000")             	// Hota
        	cCab  := Stuff(cCab,116,03,"REC")              		//Código de Area de recebimento BOMI
        	cCab  := Stuff(cCab,119,10,space(10))              	// Transportadora

	   		If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
  				If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho HDR (cCab). ","Atencao!")
     				Return .F. 
        		Endif 
        	EndIf
        
        	FQRY->(DbSkip())
    	EndDo
    	
    	fClose(nSF1Hdl) 
    	FQRY->(DbCloseArea()) 
    	
  	 	DQRY->(DbGoTop())
    	If DQRY->(!BOF() .and. !EOF())
    	
    		cSD1Txt:=cDir+"RIB"+cNum+".TXT"
      		cSD1Tit:="RIB"+cNum+".TXT"
                
			nSD1Hdl:= fCreate(cSD1Txt)
  			If nSD1Hdl == -1 // Testa se o arquivo foi gerado
    	   		MsgAlert("O arquivo "+cSD1Txt+" nao pode ser executado!","Atenção")
     		EndIf
            
    		While DQRY->(!EOF())                  

				//Verifique se a nota atualiza estoque.
				SF4->(DbSetOrder(1))
    			If SF4->(DbSeek(xFilial("SF4")+DQRY->D1_TES)) 
       				If SF4->F4_ESTOQUE <> "S"  
           				DQRY->(DbSkip())
         				loop
            		EndIf
            	Else
            		DQRY->(DbSkip())
         			loop   
            	EndIf  
            	
            	lDados:=.T.
                                      	       		
      			nTamLin   := 114
        		cCab  := Space(nTamLin) // Variavel para criacao da linha do registros para gravacao
 
          		//   ITENS               -----------       Comentários
        
        		cCab  := Stuff(cCab,01,03,"MEG")               // Fixo com "MEG"
      
                   
        		If DQRY->D1_TIPO =="N"
           			cCab  := Stuff(cCab,04,03,"TRB") 				// Tipo do recebimento 
        			SA2->(DbSetOrder(1))
            		If SA2->(DbSeek(xFilial("SA2")+DQRY->D1_FORNECE+DQRY->D1_LOJA))
            			cContato:=SA2->A2_CONTATO
					EndIf              	  
           		Else
           	   		cCab  := Stuff(cCab,04,03,"DEV") 		  		// Tipo do recebimento   
        	   		SA1->(DbSetOrder(1))
               		If SA1->(DbSeek(xFilial("SA1")+DQRY->D1_FORNECE+DQRY->D1_LOJA))
               	 		cContato:=SA1->A1_CONTATO
		   	   		EndIf   
        		EndIf   
                
           		cCab  := Stuff(cCab,07,10,DQRY->D1_DOC)             // Número da NF de entrada  
           		cCab  := Stuff(cCab,17,04,DQRY->D1_ITEM)              		// Fixo VEN 
        		cCab  := Stuff(cCab,21,15,Replicate(" ",15-Len(DQRY->D1_COD))+DQRY->D1_COD)           //Codigo do produto
        		cCab  := Stuff(cCab,36,10,"0"+ClearVal(strzero(DQRY->D1_VUNIT,10,2)))              	// Valor unitario
           		cCab  := Stuff(cCab,46,9,ClearVal(strzero(DQRY->D1_QUANT,9,0)))              	// Quantidade
        		cCab  := Stuff(cCab,55,01,"E")                           // Fonte de recebimento  
        		SB1->(DbSetOrder(1))
        		If SB1->(DbSeek(xFilial("SB1")+DQRY->D1_COD))   
        			cCab  := Stuff(cCab,56,30,SubStr(Alltrim(SB1->B1_DESC),1,30))     // Descrição do item
        		EndIf	
             		
        		cCab  := Stuff(cCab,86,15,DQRY->D1_LOTECTL+"     ")   // Lote 
        		If !Empty(DQRY->D1_DTVALID)
        			cCab  := Stuff(cCab,101,10,SubStr(Alltrim(DQRY->D1_DTVALID),1,4)+"-"+substr(Alltrim(DQRY->D1_DTVALID),5,2)+"-"+SubStr(Alltrim(DQRY->D1_DTVALID),7,2))    // Data do Pedido 
          		Else
          			cCab  := Stuff(cCab,101,10,space(10)) 
          		EndIF
          		cCab  := Stuff(cCab,111,03,"LIB")+cEOL               		//FIXO "LIB"
          		
	   			If fWrite(nSD1Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
     			   		Return .F. 
        	   		Endif 
           		EndIf
        
        		DQRY->(DbSkip())
       		EndDo
    	                 
			fClose(nSD1Hdl)   
                    
          	DQRY->(dbCloseArea())  
                
            SF1->(DbSetOrder(1))            
            SD1->(DbSetOrder(1))           
            
            // Atualiza SF1/SD1 com dados gerados.
         	For i:=1 to Len(aNotas)
         		
         		// aNotas 1.DOC,2.SERIE,3.FORNECE,4.LOJA,5.TIPO
         		cChave:=aNotas[i][1]+aNotas[i][2]+aNotas[i][3]+aNotas[i][4]
         		
         		SF1->(DbGoTop())
         		If SF1->(DbSeek(xFilial("SF1")+cChave))	
                	RecLock("SF1",.F.) 
                	SF1->F1_P_GER :="S"
                	SF1->F1_P_ARQ  :=cSF1Tit             	
                	SF1->(MsUnlock())
                	SF1->(DbSkip())                     
                EndIf 
                
                SD1->(DbGoTop())
                If SD1->(DbSeek(xFilial("SD1")+cChave))	
                	While SD1->(!EOF()) .And. cChave==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA  
                		RecLock("SD1",.F.) 
                		SD1->D1_P_GER  :="S"
                		SD1->D1_P_ARQ  :=cSD1Tit             	
                		SD1->(MsUnlock()) 
                		SD1->(DbSkip())  
                	EndDo		                 
                EndIf 
                	
         	Next
         	
         	If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"ENT")) 
          		RecLock("SX5",.F.)  
             	SX5->X5_DESCRI:=cNum
              	SX5->(MsUnlock())    
            EndIf
         	
         	MsgInfo("Arquivos gerados com sucesso.","Promega")    
          
          	EMail(aNotas,"ENT")  
                             
     		GrvLog(aNotas,"ENT")       
    
    	EndIf
       
    	If !(lDados)
    		MsgInfo("Nenhum dado encontrado para geração do arquivo","Promega")
    	EndIf
    
    Else
       
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Promega")
    
    EndIf
              

End Sequence
 
Return 

//Gera arquivo de PEDIDO
*---------------------------*
 Static Function ISPEDINT()
*---------------------------*   

Local cWhereC9
Local aStruSC9 :={}
Local aCpos    :={}
Local aButtons :={} 
Local aColors  :={}
Local lInverte:=.F.  
Local cNum  	:= SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local cData 	:= DTOS(Date())  

Private cMarca := GetMark()                     
  
	If Select("TempSC9") > 0
		TempSC9->(DbCloseArea())	               
	EndIf  
	
	aadd(aButtons,{"PENDENTE",{|| MarcaTds()},"Marca ","Marca ",{|| .T.}})
	aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Liberado'","BR_VERDE"}) 
	aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Estoque'" ,"BR_PRETO"}) 
	aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Credito'" ,"BR_AZUL"})   
	
	Aadd(aCpos, {"cINTEGRA"  ,"",})  
	Aadd(aCpos, {"C9_NFISCAL"   ,"","Nota Fiscal",})
	Aadd(aCpos, {"C9_SERIENF"   ,"","Serie Fiscal",})	
	Aadd(aCpos, {"C9_PEDIDO"   ,"","Pedido",}) 
	Aadd(aCpos, {"cStatus"  ,"","Status",}) 
	Aadd(aCpos, {"C9_PRODUTO","","Produto",})
	Aadd(aCpos, {"C9_QTDLIB" ,"","Quantidade", })
	Aadd(aCpos, {"C9_PRCVEN"  ,"","Unit. R$",})
	Aadd(aCpos, {"C9_VALOR","","Total",})
	Aadd(aCpos, {"C9_LOTECTL"   ,"","Lote",})		
	Aadd(aCpos, {"C9_DTVALID","","Data Validade",})   
	Aadd(aCpos, {"C9_CLIENTE","","Cliente",}) 
	Aadd(aCpos, {"C9_LOJA","","Loja",}) 
	                 
	Aadd(aStruSC9, {"C9_FILIAL"   ,"C",2  ,0})            
	Aadd(aStruSC9, {"cINTEGRA"    ,"C",2  ,0})
	Aadd(aStruSC9, {"cStatus"     ,"C",10,0})
	Aadd(aStruSC9, {"C9_NFISCAL"  ,"C",9 ,0}) 
	Aadd(aStruSC9, {"C9_SERIENF " ,"C",3,0}) 	
	Aadd(aStruSC9, {"C9_PEDIDO"   ,"C",6  ,0}) 
	Aadd(aStruSC9, {"C9_ITEM"     ,"C",2  ,0})   
	Aadd(aStruSC9, {"C9_PRODUTO"  ,"C",15 ,0})
	Aadd(aStruSC9, {"C9_QTDLIB"   ,"N",9  ,2})  
	Aadd(aStruSC9, {"C9_PRCVEN"   ,"N",12 ,2})
	Aadd(aStruSC9, {"C9_VALOR"    ,"N",12 ,2})
	Aadd(aStruSC9, {"C9_LOTECTL"  ,"C",10 ,0}) 
	Aadd(aStruSC9, {"C9_DTVALID"  ,"C",8  ,0})  
	Aadd(aStruSC9, {"C9_CLIENTE"  ,"C",6  ,0})  
	Aadd(aStruSC9, {"C9_LOJA"     ,"C",2 ,0})         
	   
	cNome := CriaTrab(aStruSC9, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'TempSC9',.F.,.F.)       
	 
	cWhereC9 := "%"		
	If cOpc==2
		cWhereC9 +="	AND C9_DATALIB = '"+cData+"'"
	EndIf                                            
	cWhereC9 += "%"
	
	//Nome do arquivo baseado na data + letra     
	cNum := NomeArq(cNum,"PED")    
	  
	If Select("C9QRY") > 0
		C9QRY->(DbCloseArea())	               
  	EndIf
    
    BeginSql Alias 'C9QRY'
       SELECT *
       FROM %Table:SC9%
       WHERE %notDel%
       AND C9_FILIAL = %exp:xFilial("SC9")%  
       AND C9_NFISCAL  <> ' '
       AND C9_P_GER  = ' ' 
       %exp:cWhereC9%

       ORDER BY C9_PEDIDO
       
    EndSql
        
    C9QRY->(DbGoTop())
    If !(C9QRY->(!BOF() .and. !EOF()))
    	MsgStop("Não existe itens liberados para ser enviado","Promega")
        Return .F.
    EndIf
    	
	C9QRY->(DbGoTop())
	While C9QRY->(!EOF())
	                       
		//Valida se a Tes atualiza estoque
		SC6->(DbGoTop(2))
  		If SC6->(DbSeek(xFilial("SC6")+C9QRY->C9_PEDIDO+C9QRY->C9_ITEM))	
    		   
    		//Verfica somente os que atualizam estoque    		
    		SF4->(DbSetOrder(1))
      		If SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES)) 
        		If SF4->F4_ESTOQUE <> "S"  
          			C9QRY->(DbSkip())
         			loop
            	EndIf
        	EndIf
                 
        	//Notas transmitidas não devem ser mostradas.                                                                                                  
            SF2->(DbSetOrder(1))
            If SF2->(DbSeek(xFilial("SF2")+C9QRY->C9_NFISCAL+C9QRY->C9_SERIENF+C9QRY->C9_CLIENTE+C9QRY->C9_LOJA))
            	If !Empty(SF2->F2_CHVNFE)
            		C9QRY->(DbSkip())
         			loop                
            	EndIf
            
            EndIf
                        
        EndIf  
                 	
		RecLock("TempSC9",.T.)
		TempSC9->C9_FILIAL  := C9QRY->C9_FILIAL            
		TempSC9->C9_NFISCAL := C9QRY->C9_NFISCAL
		TempSC9->C9_SERIENF := C9QRY->C9_SERIENF
		TempSC9->C9_PEDIDO  := C9QRY->C9_PEDIDO
		TempSC9->C9_CLIENTE := C9QRY->C9_CLIENTE
		TempSC9->C9_LOJA    := C9QRY->C9_LOJA   
		TempSC9->C9_ITEM    := C9QRY->C9_ITEM
		
		If 	Alltrim(C9QRY->C9_BLCRED)=="01"
			TempSC9->cStatus   :="Credito"	
		ElseIf Alltrim(C9QRY->C9_BLEST)=="02"
			TempSC9->cStatus   :="Estoque"
		ElseIf Alltrim(C9QRY->C9_BLEST)=="10" 
			TempSC9->cStatus   :="Liberado"  	
		EndIf 

		TempSC9->C9_PRODUTO:= C9QRY->C9_PRODUTO 
		TempSC9->C9_QTDLIB := C9QRY->C9_QTDLIB 
		TempSC9->C9_PRCVEN := C9QRY->C9_PRCVEN 
		TempSC9->C9_VALOR  := C9QRY->C9_QTDLIB * C9QRY->C9_PRCVEN  
		TempSC9->C9_LOTECTL:= C9QRY->C9_LOTECTL   
		TempSC9->C9_DTVALID:= C9QRY->C9_DTVALID  
		TempSC9->C9_CLIENTE:= C9QRY->C9_CLIENTE   
		TempSC9->C9_LOJA   := C9QRY->C9_LOJA     		 
		TempSC9->(MsUnlock()) 	
		C9QRY->(DbSkip())
   
	EndDo    

    TempSC9->(DbGoTop())
    If TempSC9->(!BOF() .and. !EOF())
    
   		DEFINE MSDIALOG oDlg TITLE "Pedidos" FROM 000,000 TO 545,1100 PIXEL
                
              //oTOleContainer := TOleContainer():New( 021,640,052,20,oDlg,.T.,cImg1)   
                
              @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
              @ 026 , 015 Say  "SELECIONE SOMENTE OS PRODUTOS QUE SERÃO GERADOS PARA A BOMI" COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,6 OF oDlg           
                        
              oFont := TFont():New('Courier new',,-14,.T.)
              oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVOS",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
              oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
              oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
              oMarkPrd:= MsSelect():New("TempSC9","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545},,,oDlg,,aColors)   
     	   
     	 ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lRet:=Gera(cNum),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED    	
    	
    Else
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Promega")
    	Return .F.   
    EndIf  
 
 Return    
         
//Gera o arquivo    
*-----------------------------*    
  Static Function Gera(cNum)    
*-----------------------------*    
        
Local lRet:=lBloq:=lMarcado:=.T. 
Local cSC5Txt,cSC6Txt
Local nSC5Hdl,nSC6Hdl
Local aPed      :={}
Local aItens    :={}
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\\10.0.30.4\d$\Protheus10\Amb03\ftp\IS\SAIDA\"    
Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cContato	:="" 
Local cNumAux   :=""
Local n         :=1  

Private cSC5Tit,cSC6Tit
         
cEOL := Trim(cEOL)
cEOL := &cEOL       

Begin Sequence 

	TempSC9->(DbGoTop()) 
	While TempSC9->(!EOF())     
		//Checa so marcou algum bloqueado.
		If ( Alltrim(TempSC9->cStatus)== "Credito"  .Or. Alltrim(TempSC9->cStatus)== "Estoque"  ) .And. !Empty(Alltrim(TempSC9->cINTEGRA))
    		lBloq:=.F.
		EndIf 
		 
		//Checa se marcou pelo menos um item.
		If !Empty(Alltrim(TempSC9->cINTEGRA)) .And. lMarcado
			lMarcado:=.F.		
		EndIf
		
		TempSC9->(DbSkip()) 
	EndDo

 
	If lBloq .And. !(lMarcado)
	
		cSC5Txt:=cDir+"PHB"+cNum+".TXT"
  		cSC5Tit:="PHB"+cNum+".TXT"

		nSC5Hdl:= fCreate(cSC5Txt)
  		If nSC5Hdl == -1 // Testa se o arquivo foi gerado
    		MsgAlert("O arquivo "+cSC5Txt+" nao pode ser executado!","Atenção")  
    		Return .F.
      	EndIf
           
		
		TempSC9->(DbGoTop()) 
		While TempSC9->(!EOF())   

			If Alltrim(TempSC9->cStatus)== "Liberado"  .And. !Empty(Alltrim(TempSC9->cINTEGRA)) .And. cNumAux <> TempSC9->C9_PEDIDO
		    	    	
    	   	    cNumAux:=TempSC9->C9_PEDIDO
       	             
    	    	// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE    
    	    	Aadd(aPed,{TempSC9->C9_PEDIDO,TempSC9->C9_CLIENTE,TempSC9->C9_LOJA,TempSC9->C9_NFISCAL,TempSC9->C9_SERIENF})  
    	           
    			SC5->(DbSetOrder(1))
    			If SC5->(DbSeek(xFilial("SC5")+TempSC9->C9_PEDIDO))
    	
     				nTamLin   := 340
        			cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
           			//   Cabeçalho                -----------       Comentários
        
        			cCab  := Stuff(cCab,01,03,"MEG")               		 // Fixo com "MEG"                      
           			//cCab  := Stuff(cCab,04,16,SC5->C5_NUM)             // Número do Pedido   
           			cCab  := Stuff(cCab,04,16,TempSC9->C9_NFISCAL)       // Número do Pedido
        			cCab  := Stuff(cCab,20,03,"PEX")              		 // Fixo VEN           			        			
		   			cCab  := Stuff(cCab,23,02,SC5->C5_P_PRIOR) // Prioridade  01-Normal / 02-Urgente   
           			cCab  := Stuff(cCab,25,15,space(15))                 // Número do pedido do cliente
        			SA1->(DbSetOrder(1))
         			If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))           	
        	        	cCab  := Stuff(cCab,40,30,SA1->A1_NOME)          // Razão social do cliente
        				cCab  := Stuff(cCab,70,40,SA1->A1_END)           // Endereço
        				cCab  := Stuff(cCab,110,20,SA1->A1_BAIRRO)       // Bairro
		        		cCab  := Stuff(cCab,130,30,SA1->A1_MUN)          // Cidade
		        		cCab  := Stuff(cCab,160,30,SA1->A1_EST)          // Estado
		        		cCab  := Stuff(cCab,190,30,SA1->A1_CEP)          // CEP          	   
        			EndIf	
			        cCab  := Stuff(cCab,220,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
			       	cCab  := Stuff(cCab,230,01,"N")                	 	 // Fixo "N"
					cCab  := Stuff(cCab,231,04,"VEN ")              	 // Fixo "VEN"
					cCab  := Stuff(cCab,235,03,"MEG")               	 // Fixo "MEG"				
					cCab  := Stuff(cCab,238,2,Space(2))             	 // Nivel de servico 
					cCab  := Stuff(cCab,240,2,Space(2))                  // Serie da nota fiscal de saida
					cCab  := Stuff(cCab,242,2,Space(8))           		 // Campo configuravel 
					cCab  := Stuff(cCab,250,10,"0000000000")     		 // Valor da nota fiscal 
					cCab  := Stuff(cCab,260,14,SA1->A1_CGC)        		 // CNPJ
					cCab  := Stuff(cCab,274,12,SA1->A1_INSCR)      		 // Inscr. Estadual
					cCab  := Stuff(cCab,286,50,Space(52))+cEOL            // Espaço em branco

	   				If fWrite(nSC5Hdl,cCab,Len(cCab)) != (Len(cCab))
  						If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho HDR (cCab). ","Atencao!")
     						Return .F. 
        				Endif 
        			EndIf

    	    	EndIf
    	    
    	    EndIf
    	    
    	    TempSC9->(DbSkip()) 
    		    
    	EndDo    
    	
    	fClose(nSC5Hdl)   
    	                         
    	
	    cSC6Txt:=cDir+"PIB"+cNum+".TXT"
	    cSC6Tit:="PIB"+cNum+".TXT"
	        	
	    nSC6Hdl:= fCreate(cSC6Txt)
		If nSC6Hdl == -1 // Testa se o arquivo foi gerado
	    	MsgAlert("O arquivo "+cSC6Txt+" nao pode ser executado!","Atenção")
	    	Return .F.
	    EndIf
	               		  
    	TempSC9->(DbGoTop()) 
    	cNumAux:=TempSC9->C9_PEDIDO
		While TempSC9->(!EOF())   
		
  			If Alltrim(TempSC9->cStatus)== "Liberado"  .And. !Empty(Alltrim(TempSC9->cINTEGRA))
  			       			
	  			//SC6->(DbGoTop(2))
	  			//If SC6->(DbSeek(xFilial("SC6")+TempSC9->C9_PEDIDO+TempSC9->C9_ITEM))
	  			    
	  				If cNumAux<>TempSC9->C9_PEDIDO
	  			    	n:=1
	  			    	cNumAux:=TempSC9->C9_PEDIDO
	  			    EndIf    
	  			    	             
	    	    	// aItens 1.NUM,2.ITEM,3.PRODUTO    
	    	    	Aadd(aItens,{TempSC9->C9_PEDIDO,TempSC9->C9_ITEM,TempSC9->C9_PRODUTO,TempSC9->C9_CLIENTE,TempSC9->C9_LOJA})  		
		    	                               	       		
	       			nTamLin   := 90
	        		cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	 
	          		//   ITENS               -----------       Comentários
	        
	        		cCab  := Stuff(cCab,01,03,"MEG")               	      // Fixo com "MEG"
	        		//cCab  := Stuff(cCab,04,16,TempSC9->C9_PEDIDO) 		          // Numero do pedido 
	        		cCab  := Stuff(cCab,04,16,TempSC9->C9_NFISCAL) 		          // Numero do pedido
	        		cCab  := Stuff(cCab,20,4,strzero(n,4))                // Sequencia	    
	           		cCab  := Stuff(cCab,24,15,TempSC9->C9_PRODUTO)            // Codigo do item
	           		cCab  := Stuff(cCab,39,9,strzero(TempSC9->C9_QTDLIB,9,0)) // Quantidade do item
	        		cCab  := Stuff(cCab,48,1,"N") 			              // Operação Cross-docking 
	        		cCab  := Stuff(cCab,49,4,"VEN ")                       // Armazem
	           		cCab  := Stuff(cCab,53,1,"N")                    	  // Linha pode ser dividida
	        		cCab  := Stuff(cCab,54,03,"PEX")                      // Tipo do pedido  
	        		cCab  := Stuff(cCab,57,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))                    // Data do pedido
	        		cCab  := Stuff(cCab,67,15,TempSC9->C9_LOTECTL+space(9))    // Lote   
	        		cCab  := Stuff(cCab,82,01,"S")      				   // Fixo "S"
	        		cCab  := Stuff(cCab,83,07,space(7))+cEOL       		   // Branco
	        		 
	        		n++ 
	        		     		
		   			If fWrite(nSC6Hdl,cCab,Len(cCab)) != (Len(cCab))
	  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
	     			   		Return .F. 
	        	   		Endif 
	           		EndIf
	        
        		//EndIf	
                
        	EndIf
        	
        	TempSC9->(DbSkip())
       	
       	EndDo
    	                 
		fClose(nSC6Hdl)   
                    
  		TempSC9->(dbCloseArea())  
          	        
    	// Atualiza SC5        	
     	For i:=1 to Len(aPed)
         		
      		// aPed 1.Pedido,2.Cliente,3.Loja
        	cChave:=aPed[i][1]+aPed[i][2]+aPed[i][3]
         		
         	SC5->(DbGoTop())  
         	SC5->(DbSetOrder(1))
         	If SC5->(DbSeek(xFilial("SC5")+aPed[i][1]))	
          		RecLock("SC5",.F.) 
             	SC5->C5_P_GER :="S"
             	SC5->C5_P_ARQ  :=cSC5Tit             	
               	SC5->(MsUnlock())
             	SC5->(DbSkip())                     
          	EndIf 
            
 		Next 
              		
    	// Atualiza SC6/SC9
   		For i:=1 to Len(aItens)
            
     		// aItens 1.NUM,2.ITEM,3.PRODUTO,4.CLIENTE,5.LOJA 
       		cChave:=aItens[i][1]+aItens[i][2]+aItens[i][3]
    	    	
			SC6->(DbGoTop())    
   			SC6->(DbSetOrder(1))  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
      		If SC6->(DbSeek(xFilial("SC6")+aItens[i][1]+aItens[i][2]+aItens[i][3]))	
        		RecLock("SC6",.F.) 
          		SC6->C6_P_GER  :="S"
          		SC6->C6_P_ARQ  :=cSC6Tit             	
          		SC6->(MsUnlock()) 		                 
            EndIf   
                     
                                                                                                                              
            SC9->(DbGoTop())    
            SC9->(DbSetOrder(2))  //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM                                                                                                                                
            If SC9->(DbSeek(xFilial("SC9")+aItens[i][4]+aItens[i][5]+aItens[i][1]+aItens[i][2]))	
            	
            	RecLock("SC9",.F.) 
            	SC9->C9_P_GER  :="S"          	
            	SC9->(MsUnlock()) 	
            	                          
            	//Para pedido parciais  - Tratamento para 3 vendas do mesmo pedido 
            	If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
            	                                  
            	     SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO                    
            		//Procurar sequencia 02 do SC9
            		If SC9->(DbSeek(xFilial("SC9")+aItens[i][1]+aItens[i][2]+"02"+aItens[i][3]))  
            		
            			RecLock("SC9",.F.) 
            			SC9->C9_P_GER  :="S"          	
            			SC9->(MsUnlock())
            			
            			//Procurar sequencia 03 do SC9
            			If SC9->(DbSeek(xFilial("SC9")+aItens[i][1]+aItens[i][2]+"03"+aItens[i][3]))   
            		
            				RecLock("SC9",.F.) 
            				SC9->C9_P_GER  :="S"          	
            				SC9->(MsUnlock())  	 
            			
            		    EndIf 
            		
            		EndIf            		
            	
            	EndIf            	
            		                 
            EndIf                      
                	
      	Next
      	   	
       	If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"PED")) 
	        RecLock("SX5",.F.)  
	        SX5->X5_DESCRI:=cNum
	        SX5->(MsUnlock())    
        EndIf
         	
        MsgInfo("Arquivos:"+Alltrim(cSC5Tit)+"/"+Alltrim(cSC6Tit)+" gerados com sucesso.","Promega")    
          
        EMail(aPed,"PED")
          	
        GrvLog(aPed,"PED")  
           
    Else
    	MsgStop("Existem itens não marcardos ou itens bloqueados que estão marcados, verificar.","Promega")  
    	TempSC9->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet      
            
//Gera arquivo de SAIDA
*-------------------------*
 Static Function ISSAIINT()
*-------------------------*   

Local cWhereD2
Local cSD2Txt
Local nSD2Hdl
Local aSai:={}  

Local cNum  := SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local cEOL  := "CHR(13)+CHR(10)" 
Local cDir  := "\\10.0.30.4\d$\Protheus10\Amb03\ftp\IS\SAIDA\"    
Local cPath := AllTrim(GetTempPath()) 
Local cData := DTOS(Date())   
Local cContato:=""

Private cSD2Tit
         
cEOL := Trim(cEOL)
cEOL := &cEOL       
  
If !(MsgYesNo("Deseja realmente gerar o arquivo de SAIDA"))
	Return .F.
Endif
 
cWhereD2 := "%"		
If cOpc==2
	cWhereD2 +="	AND D2_EMISSAO = '"+cData+"'"
EndIf                                            
cWhereD2 += "%"   

//Nome do arquivo baseado na data + letra     
cNum := NomeArq(cNum,"SAI")    

Begin Sequence	

	If Select("D2QRY") > 0
 		D2QRY->(DbCloseArea())	               
   	EndIf
   	                
    BeginSql Alias 'D2QRY'
       SELECT *
       FROM %Table:SD2%
       WHERE %notDel%
       AND D2_FILIAL = %exp:xFilial("SD2")%
       AND D2_P_GER  = ' '
       %exp:cWhereD2%

       ORDER BY D2_DOC
       
    EndSql 
    
               
    D2QRY->(DbGoTop())
    If D2QRY->(!BOF() .and. !EOF())
    
    	cSD2Txt:=cDir+"BNF"+cNum+".TXT"
     	cSD2Tit:="BNF"+cNum+".TXT"

		nSD2Hdl:= fCreate(cSD2Txt)
  		If nSD2Hdl == -1 // Testa se o arquivo foi gerado
    		MsgAlert("O arquivo "+cSD2Txt+" nao pode ser executado!","Atenção")
      	EndIf
           
    	While D2QRY->(!EOF()) 
    	             
    	    // aSAI 1.DOC,2.SERIE,3.CLIENTE,4.LOJA,5.TIPO,6.PEDIDO    
    	    Aadd(aSAI,{D2QRY->D2_DOC,D2QRY->D2_SERIE,D2QRY->D2_CLIENTE,D2QRY->D2_LOJA,D2QRY->D2_TIPO,D2QRY->D2_PEDIDO})  
   
    	    //Verifica se a nota atualiza estoque.
    	    SF4->(DbSetOrder(1))
         	If SF4->(DbSeek(xFilial("SF4")+D2QRY->D2_TES)) 
          		If SF4->F4_ESTOQUE <> "S"  
            		D2QRY->(DbSkip())
         			loop
            	EndIf
        	EndIf
    	
     		nTamLin   := 98
        	cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
          	//   Cabeçalho                -----------       Comentários
                                                                                           
        	//Chamado 001755
        	//cCab  := Stuff(cCab,01,16,D2QRY->D2_PEDIDO)            // Número do delivery                      
			cCab  := Stuff(cCab,01,16,D2QRY->D2_DOC)               // Número do delivery                      
        	cCab  := Stuff(cCab,17,01,D2QRY->D2_SERIE)             // Número da serie
        	cCab  := Stuff(cCab,18,15,D2QRY->D2_DOC)               // Número da nota  
        	SF2->(DbSetOrder(1))
        	If SF2->(DbSeek(xFilial("SF2")+D2QRY->D2_DOC+D2QRY->D2_SERIE+D2QRY->D2_CLIENTE+D2QRY->D2_LOJA))
        		cCab  := Stuff(cCab,33,16,"0"+ClearVal(strzero(SF2->F2_VALBRUT,16,2)))              	// Valor total da NF                                           
        	EndIf
        	
			cCab  := Stuff(cCab,49,15,D2QRY->D2_COD)               		// Código do item  
			cCab  := Stuff(cCab,64,15,D2QRY->D2_LOTECTL)          		// Lote 
	  		cCab  := Stuff(cCab,79,9,ClearVal(strzero(D2QRY->D2_QUANT,9,0)))     // Quantidade
     		cCab  := Stuff(cCab,88,10,SubStr(Alltrim(D2QRY->D2_DTVALID),1,4)+substr(Alltrim(D2QRY->D2_DTVALID),5,2)+SubStr(Alltrim(D2QRY->D2_DTVALID),7,2))+cEOL    // Data do Pedido 
      	
	   		If fWrite(nSD2Hdl,cCab,Len(cCab)) != (Len(cCab))
  				If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho HDR (cCab). ","Atencao!")
     				Return .F. 
        		Endif 
        	EndIf
        
        	D2QRY->(DbSkip())
    	EndDo
    	
    	fClose(nSD2Hdl) 
    	D2QRY->(DbCloseArea()) 
    	
		// Atualiza SD2 com dados gerados.
  		For i:=1 to Len(aSAI)
         		
    		// aSAI 1.DOC,2.SERIE,3.CLIENTE,4.LOJA,5.TIPO  
     		cChave:=aSAI[i][1]+aSAI[i][2]+aSAI[i][3]+aSAI[i][4]
         		
       		SD2->(DbGoTop(3))
       		If SD2->(DbSeek(xFilial("SD2")+cChave))	
				While SD2->(!EOF()) .And. cChave==SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA 
    				RecLock("SD2",.F.) 
        			SD2->D2_P_GER :="S"
           			SD2->D2_P_ARQ  :=cSD2Tit             	
              		SD2->(MsUnlock())
            		SD2->(DbSkip())      
              	EndDo		                 
        
        	EndIf        	
        Next
         	
        If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"SAI")) 
        	RecLock("SX5",.F.)  
         	SX5->X5_DESCRI:=cNum
          	SX5->(MsUnlock())    
        EndIf
         	
        MsgInfo("Arquivos gerados com sucesso.","Promega")    
          
        EMail(aSAI,"SAI")  
        
        GrvLog(aSAI,"SAI") 
             	
    Else
       
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Promega")
    
    EndIf
              

End Sequence
 
Return

//Gera arquivo de MAT
*---------------------------*
 Static Function ISCONFINT()
*----------------------------*   

Local cSB8Txt
Local nSB8Hdl
Local aItens:={}  
Local n:=1

Local cNum  := SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local cEOL  := "CHR(13)+CHR(10)" 
Local cDir  := "\\10.0.30.4\d$\Protheus10\Amb03\ftp\IS\INVENTARIO\"    
Local cPath := AllTrim(GetTempPath())                
Local cData 
Local cDtLote , cChave  
Local cContato:=""
    
cEOL := Trim(cEOL)
cEOL := &cEOL       
  
	If !(MsgYesNo("Deseja realmente integrar arquivo de MAT"))
		Return .F.
	Endif
 
	If EmptY(aArq:=Directory(cDir+"*.TXT",))
		MsgAlert("Nenhum arquivo encontrado para integrar","Promega")
		Return .F.	
	EndIf    
	
	      
	For i:=1 to Len(aArq)    
		
		ZX0->(DbSetOrder(1))
		If ZX0->(DbSeek(xFilial("ZX0")+Substr(aArq[i][1],1,8))) 
			MsgStop("O arquivo "+Substr(aArq[i][1],1,8)+" já foi integrado.","Promega")
		  	exit		
		EndIf
	 
		If File(cDir+aArq[i][1]) .And. Substr(aArq[i][1],1,3) == "MAT" 
	  
	  		RecLock("ZX0",.T.)
       		ZX0->ZX0_FILIAL :=xFilial("ZX0")
    		ZX0->ZX0_TIPO	:="MAT"
    		ZX0->ZX0_USER	:=cUserName
    		ZX0->ZX0_DT   	:=Date()
   	   		ZX0->ZX0_ARQ 	:=aArq[i][1]
   			ZX0->ZX0_CHAVE	:=Substr(aArq[i][1],1,8)  
   	    	ZX0->(MsUnlock())
   	       
   	    	FT_FUse(cDir+aArq[i][1])
	     	FT_FGOTOP() 
	     	     	   
       	    While !FT_FEof() 
       	    
       	    	cLin := FT_FReadLn()                                                                       
              	
              	If !(Empty(SubStr(cLin,31,4)))
       	      		RecLock("ZX1",.T.) 
          	   		ZX1->ZX1_FILIAL	:=xFilial("ZX1")
					ZX1->ZX1_TIPO  	:=If(Empty(SubStr(cLin,31,4)),"BRANCO",SubStr(cLin,31,4))
					ZX1->ZX1_ITEM	:=strzero(n,3)
					ZX1->ZX1_COD	:=SubStr(cLin,1,15)
					ZX1->ZX1_QUANT	:=Val(SubStr(cLin,35,9))  //Val(SubStr(cLin,65,7)+"."+SubStr(cLin,72,2))   
					ZX1->ZX1_LOTE	:=SubStr(cLin,16,15)
					ZX1->ZX1_DT_LOT :=STOD(ClearVal(SubStr(cLin,44,10)))
					ZX1->ZX1_CHAVE	:=Substr(aArq[i][1],1,8)  
			  		ZX1->ZX1_ARQ	:=aArq[i][1]
    			                                                                     
    				SB1->(DbSetOrder(1))
    				If SB1->(xFilial("SB1")+SubStr(cLin,1,15))
    			        
    			       	//Testa o lote
    					If Alltrim(SB1->B1_RASTRO)=="L"
    			   			
    			   			//B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL+B8_NUMLOTE
    						SB8->(DbSetOrder(1))
    			   			If SB8->(DbSeek(xFilial("SB8")+SubStr(cLin,1,15)+"01"+Alltrim(Clearval(SubStr(cLin,44,10)))+SubStr(cLin,16,10) ))
   				   		
   				   				ZX1->ZX1_SALDO	:=SB8->B8_SALDO
   				   				ZX1->ZX1_DIFERE :=(SB8->B8_SALDO-Val(SubStr(cLin,35,9)))
               			   
               					Else
              	   		
              	   		   		ZX1->ZX1_OBS	:="Produto não encontrado na tabela de saldos"              			
	     				
	     					EndIf
     		   
     		    		Else  
     		    		   
     		    			SB2->(DbSetOrder(1))
     		    		  	If SB2->(DbSeek(xFilial("SB2")+SubStr(cLin,1,15)+"01"))  // Acordado com o cliente armazen fixo 01.
     		    		       
     		    		    	ZX1->ZX1_SALDO	:= SB2->B2_QATU
   				   				ZX1->ZX1_DIFERE := (SB2->B2_QATU-Val(SubStr(cLin,35,9)))
               			   
              				Else
              	   		
              	   		   		ZX1->ZX1_OBS	:="Produto não encontrado na tabela de saldos"              			
	     				
	     					EndIf
     		    		     		    	     		    		
     		    		EndIf
     		    		
     		    		
     		    		ZX1->(MsUnlock())       
    			   
    				EndIf 
    			EndIf
    			
     			FT_FSkip()
     		        
     			n++
     		
     		EndDo
     		
     		FT_FUse()
   
   			cFinal:=cDir+Substr(aArq[i][1],1,8)+".Old"
   			cOri  :=cDir+aArq[i][1]         
     
     		If fRename(cOri,cFinal) < 0
     			MsgStop("O arquivo "+aArq[i][1]+" foi integrado, mas não renomeado, entrar em contato com suporte","Promega")
     		Else
     			MsgInfo("Arquivo integrado "+aArq[i][1]+" com sucesso","Promega")
     		EndIf	
     		           
     
        EndIf  
  
	Next 

Return

//Le o arquivo de retorno.
*-------------------------*
 Static Function ISRETINT()
*-------------------------*   

Local cNum  := SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local cDir  := "\\10.0.30.4\d$\Protheus10\Amb03\ftp\IS\REC\"    
Local cPath := AllTrim(GetTempPath()) 
Local cData := DTOS(Date())   
Local aArq	:= {}
Local cOri	:= ""
Local cFinal:= ""  
Local cLin  := ""
  
	If !(MsgYesNo("Deseja realmente buscar o arquivo de RETORNO"))
		Return .F.
	Endif

	If EmptY(aArq:=Directory(cDir+"*.TXT",))
		MsgAlert("Nenhum arquivo encontrado para integrar","Promega")
		Return .F.	
	EndIf    
		
	For i:=1 to Len(aArq)    
		
		ZX0->(DbSetOrder(1))
		If ZX0->(DbSeek(xFilial("ZX0")+Substr(aArq[i][1],1,8))) 
			MsgStop("O arquivo "+Substr(aArq[i][1],1,8)+" já foi integrado.","Promega")
		  	exit		
		EndIf
	 
		If File(cDir+aArq[i][1]) .And. Substr(aArq[i][1],1,3) == "REC" 
	  
	  		RecLock("ZX0",.T.)
       		ZX0->ZX0_FILIAL :=xFilial("ZX0")
    		ZX0->ZX0_TIPO	:="REC"
    		ZX0->ZX0_USER	:=cUserName
    		ZX0->ZX0_DT   	:=Date()
   	   		ZX0->ZX0_ARQ 	:=aArq[i][1]
   			ZX0->ZX0_CHAVE	:=Substr(aArq[i][1],1,8)  
   	    	ZX0->(MsUnlock())
   	       
   	    	FT_FUse(cDir+aArq[i][1])
	     	FT_FGOTOP() 
	     	     	   
       	    While !FT_FEof() 
       	    
       	    	cLin := FT_FReadLn()                                                                       
              	  
              	If !Empty(SubStr(cLin,25,15))
       	      		RecLock("ZX1",.T.) 
          			ZX1->ZX1_FILIAL	:=xFilial("ZX1")
					ZX1->ZX1_TIPO  	:=If(Empty(SubStr(cLin,74,4)),"BRANCO",SubStr(cLin,74,4))
					ZX1->ZX1_ITEM	:=SubStr(cLin,21,04)
					ZX1->ZX1_COD	:=SubStr(cLin,25,15)
					ZX1->ZX1_QUANT	:=Val(SubStr(cLin,65,9))  //Val(SubStr(cLin,65,7)+"."+SubStr(cLin,72,2))   
					ZX1->ZX1_LOTE	:=SubStr(cLin,40,10)
					ZX1->ZX1_DT_LOT :=STOD(ClearVal(SubStr(cLin,55,10)))
					ZX1->ZX1_DOC	:=SubStr(cLin,1,9)       
			 		ZX1->ZX1_SER	:=SubStr(cLin,9,1)
					ZX1->ZX1_EMISSA	:=STOD(ClearVal(SubStr(cLin,11,10)))
	 				ZX1->ZX1_CHAVE	:=Substr(aArq[i][1],1,8)  
			  		ZX1->ZX1_ARQ	:=aArq[i][1]
					ZX1->ZX1_PEDIDO	:=""
    				ZX1->(MsUnlock()) 
              	EndIf	   
              		
              		
     			FT_FSkip()
     		
     		EndDo
     		
     		FT_FUse()
   
   			cFinal:=cDir+Substr(aArq[i][1],1,8)+".Old"
   			cOri  :=cDir+aArq[i][1]         
     
     		If fRename(cOri,cFinal) < 0
     			MsgStop("O arquivo "+aArq[i][1]+" foi integrado, mas não renomeado, entrar em contato com suporte","Promega")
     		Else
     			MsgInfo("Arquivo integrado "+aArq[i][1]+" com sucesso","Promega")
     		EndIf	
     		
     		If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"RET")) 
           		RecLock("SX5",.F.)  
         		SX5->X5_DESCRI:=Substr(aArq[i][1],1,8)
          		SX5->(MsUnlock())    
        	EndIf	                 
     
        EndIf  
  
	Next
    
Return  

*----------------------------*
  User Function ISLOGINT() 
*----------------------------*  
         
Local  aCores:={}      

Private aRotina:={} 
   
  If !(cEmpAnt $ "IS/IJ")
     MsgInfo("Especifico PROMEGA"," A T E N C A O ")  
     Return .F.
  Endif    

  DbSelectArea("ZX0")
  DbSetOrder(1)   
  ZX0->(DbGoTop()) 

  aRotina := {{ "Pesquisa"        ,"AxPesqui"    , 0 , 1},;
	          { "Visualizar"      ,"U_ISVIEW"   , 0 , 2},; 
	          { "Legenda"         ,"U_ISLEG"    , 0 , 3}}  
	          
  aCores  := {{ "Alltrim(ZX0_TIPO)=='PEDIDO'"	,'BR_VERDE'   },;   // Arquivo de pedido 
              { "Alltrim(ZX0_TIPO)=='SAIDA'"	,'BR_AMARELO' },;   // Arquivo de saida
              { "Alltrim(ZX0_TIPO)=='ENTRADA'"	,'BR_AZUL'    },;   // Arquivo de entrada
              { "Alltrim(ZX0_TIPO)=='MAT'"       ,'BR_LARANJA' },;   // Arquivo de entrada
	          { "Alltrim(ZX0_TIPO)=='RETORNO'"	,'BR_VERMELHO'}}  // Arquivo de retorno		    

  mBrowse(6,1,22,75,"ZX0",,,,,,aCores)	   
   
Return  

//Visualização do log de integração
*--------------------------------------------*
  User Function ISVIEW(cAlias,nReg,nOpcx)      
*--------------------------------------------*   

Local i   
Local cTitulo        :="Logs do arquivo de integração"
Local cAliasEnchoice :="ZX0"
Local cAliasGetD     :="ZX1"
Local cLinOk         :="AllwaysTrue()"
Local cTudOk         :="AllwaysTrue()"
Local cFieldOk       :="AllwaysTrue()"			    
Local nOpcE,nOpcG,cAux
            

If nOpcx==2      //Visualização
   nOpcE:=nOpcG:=2
EndIf   

RegToMemory("ZX0",.F.)

nUsado:=i:=0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ZX1")

aHeader:={}                                                         
aCols:={}
	
While !Eof() .And. (X3_ARQUIVO=="ZX1")

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      nUsado++
      Aadd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO  , X3_PICTURE    ,;
	                      X3_TAMANHO, X3_DECIMAL,"AllwaysTrue()",;
    	                  X3_USADO  , X3_TIPO   , X3_ARQUIVO    , X3_CONTEXT } )
   EndIf
   SX3->(DbSkip())
   
EndDo

DbSelectArea("ZX1")
DbSetOrder(1)
DbSeek(xFilial()+M->ZX0_CHAVE)
	
While !(EOF()) .And. ( M->ZX0_CHAVE == ZX1->ZX1_CHAVE )

   Aadd(aCols,Array(nUsado+1))
   For i:=1 to nUsado
      aCols[Len(aCols),i]:=FieldGet(FieldPos(aHeader[i,2]))
   Next 
   aCols[Len(aCols),nUsado+1]:=.F.
  
   ZX1->(DbSkip())

EndDo    
  
If Len(aCols)>0                                                                                                                                  //Lin Col lin Col   Cab
   Modelo3(cTitulo ,cAliasEnchoice,cAliasGetD ,     ,cLinOk  ,cTudOk ,nOpcE,nOpcG,cFieldOk,         ,        ,              ,          ,         ,{121,102,750,1400},250 )   
          //cTitulo,cAlias        ,cAlias2    ,aMy  ,cLinhaOk,cTudoOk,nOpcE,nOpcG,cFieldOk, lVirtual, nLinhas, aAltEnchoice , nFreeze , aButtons ,aCordW, nSizeHeader) 
EndIf   

ZX0->(DbGoTop())

Return  
         
//Legenda
*-----------------------* 
  User Function ISLEG()
*-----------------------*

Local aCores := {}    

   aCores := {{"BR_VERDE"   ,"Arquivo de pedido" },;   
              {"BR_AMARELO" ,"Arquivo de saida"	 },;  
              {"BR_AZUL"    ,"Arquivo de entrada"},;  
              {"BR_LARANJA" ,"Arquivo de inventário (MAT)"},;
              {"BR_VERMELHO","Arquivo de retorno (REC)"}} 
     
   BrwLegenda("PROMEGA","Legenda",aCores) 
   
Return .T.

// Função de envio de e-mail
*------------------------------------*
  Static Function Email(aDados,cTipo)
*------------------------------------*  

Local cSubject     := ""
Local cNome        := ""  
Local cNf          := ""
Local cDestinatario:= "" // tiago.mendonca@hlb.com.br"  // Para testes, fora do ambiente produção.
    

	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
 	cEmail += '<title>Nova pagina 1</title></head><body>'
  	cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
   	cEmail += 'Arquivo de entrada gerado  </b></u></font></p>'   
   	    
   	//arquivo de entrada
   	If cTipo == "ENT" 
   	
   		cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cSF1Tit+" / "+cSD1Tit+' disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente as notas de entrada: ' 
    	If cEmpAnt $ "IS" //Produção   
    		//Sempre fixo conforme reunião
    		cDestinatario:="luciane.machado@promega.com ;ana.silva@bomibrasil.com.br; valdir.castro@bomibrasil.com.br; andre.bispo@bomibrasil.com.br; roseli.martins@promega.com;aline.cristina@bomibrasil.com.br"      
    	EndIf 
    	         	     
    	             
    //arquivo de pedido	
    ElseIf cTipo == "PED"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cSC5Tit+" / "+cSC6Tit+' disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente aos pedidos: '             
    	If cEmpAnt $ "IS" //Produção 
       		//Sempre fixo conforme reunião
       		cDestinatario:="luciane.machado@promega.com ;lidiane.silva@bomibrasil.com.br; patricia.xavier@bomibrasil.com.br; bruna.oliveira@bomibrasil.com.br;ana.silva@bomibrasil.com.br;Pedidos.brasil@promega.com ; roseli.martins@promega.com; aline.cristina@bomibrasil.com.br"  
        EndIf          
        
    //arquivo de saída    
    ElseIf cTipo == "SAI"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cSD2Tit+" disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente as notas de saída: '     
       	If cEmpAnt $ "IS" //Produção 
    		//Sempre fixo conforme reunião
    		cDestinatario:="luciane.machado@promega.com ;roseli.martins@promega.com; luciane.machado@promega.com; lidiane.silva@bomibrasil.com.br;  bruna.oliveira@bomibrasil.com.br;ana.silva@bomibrasil.com.br;Pedidos.brasil@promega.com "
    	EndIf         
    	
    //arquivo de materiais	
    ElseIf cTipo == "MAT"          
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cSB8Tit+" disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente a conferência: '     
    	If cEmpAnt $ "IS" //Produção      
    		//Sempre fixo conforme reunião
    		cDestinatario:="luciane.machado@promega.com ;roseli.martins@promega.com; luciane.machado@promega.com"  
     	EndIf  
    
    EndIf  
          
    cEmail += '<br>'   
   	cEmail += '<br>'           	 		
	cEmail += '<br>' 
          	
	For i:=1 to Len(aDados)
		
		If cTipo == "ENT"
			
			// aNotas 1.DOC,2.SERIE,3.FORNECE,4.LOJA,5.TIPO
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
			
			cSubject:= " Arquivo de integracao PROMEGA disponivel "+cSF1Tit+" / "+cSD1Tit     
			   

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
			
			
		ElseIf cTipo == "PED"    
		     
			// aDados - 1.Pedido,2.Cliente,3.Loja,4.Nota,5.Serie
			SA1->(DbSetOrder(1))
   			If SA1->(DbSeek(xFilial("SA1")+aDados[i][2]+aDados[i][3]))
      			cNome:=SA1->A1_NOME
         	EndIf  
         	

   			cSubject:= " Arquivo de integracao PROMEGA disponivel "+cSC5Tit+" / "+cSC6Tit      

			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">Nota: '+aDados[i][4]+'</font></td>'
   			cEmail += '		<td width="40"><font face="Courier New" size="2">Pedido: '+aDados[i][1]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Cliente: '+aDados[i][2]+" "+Alltrim(cNome)+'</font></td>'
			cEmail += '	</tr>'
			cEmail += '<br>'     
			
		ElseIf cTipo == "SAI"    
		     
			// aNotas 1.DOC,2.SERIE,3.FORNECE,4.LOJA,5.TIPO,6.PEDIDO
			SA1->(DbSetOrder(1))
   			If SA1->(DbSeek(xFilial("SA1")+aDados[i][3]+aDados[i][4]))
      			cNome:=SA1->A1_NOME
         	EndIf                                   
         	
         	cSubject:= " Arquivo de integracao PROMEGA disponivel "+cSD2Tit   
         	
         	If aDados[i][1] <> cNf
		   		
		   		cEmail += '	<tr>'
   				cEmail += '		<td width="40"><font face="Courier New" size="2">Nota Saida: '+aDados[i][1]+'</font></td>'
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Serie: '+aDados[i][2]+'</font></td>'        
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Pedido: '+aDados[i][6]+'</font></td>'
		   		cEmail += '		<td width="378"><font face="Courier New" size="2">Cliente: '+aDados[i][3]+" "+Alltrim(cNome)+'</font></td>'  
		   		cEmail += '	</tr>'
		    	cEmail += '<br>'  
		    	
		    	cNf:=aDados[i][1] 
		    	
		    EndIf
		   
			
			
		ElseIf cTipo == "MAT"    
		     
    	    //aItens. 1.B8_PRODUTO,2.B8_LOCAL,3.B8_DATA,4.B8_DTVALID,5.B8_LOTECTL,6.B8_SALDO  
			cSubject:= " Arquivo de integracao PROMEGA disponivel "+cSB8Tit     
			
			cEmail += '	<tr>'
   			cEmail += '		<td width="40"><font face="Courier New" size="2">Produto: '+aDados[i][1]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Lote: '+aDados[i][5]+'</font></td>'
			cEmail += '		<td width="378"><font face="Courier New" size="2">Qtd: '+Alltrim(Str(aDados[i][6]))+'</font></td>'  
			cEmail += '	</tr>'
			cEmail += '<br>'  		  
							
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


// Função para gravar o log
*------------------------------------*
  Static Function GrvLOG(aDados,cTipo)
*------------------------------------*  

	
	If cTipo == "ENT" 
    	
    	RecLock("ZX0",.T.)
    	ZX0->ZX0_FILIAL:=xFilial("SF1")
    	ZX0->ZX0_TIPO:="ENTRADA"
    	ZX0->ZX0_USER:=cUserName
    	ZX0->ZX0_DT   :=Date()
   		ZX0->ZX0_ARQ  :=cSF1Tit
   		ZX0->ZX0_CHAVE:="ENT"+SubStr(cSF1Tit,4,5)
   	    ZX0->(MsUnlock())
   	    
   	    For i:=1 to Len(aDados)
   	         
   	    	// aDados 1.DOC,2.Serie,3.Cliente,4.Loja
         	cChave:=aDados[i][1]+aDados[i][2]+aDados[i][3]+aDados[i][4]

			SD1->(DbSetOrder(1))
   			If SD1->(DbSeek(xFilial("SD1")+cChave))	
      			While SD1->(!EOF()) .And. cChave==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA  
         			RecLock("ZX1",.T.) 
          			ZX1->ZX1_FILIAL	:=xFilial("SD1")
					ZX1->ZX1_TIPO  	:="ENTRADA"
					ZX1->ZX1_ITEM	:=SD1->D1_ITEM
					ZX1->ZX1_COD	:=SD1->D1_COD
					ZX1->ZX1_QUANT	:=SD1->D1_QUANT
					ZX1->ZX1_CLIENT	:=SD1->D1_FORNECE
					ZX1->ZX1_LOJA	:=SD1->D1_LOJA
					ZX1->ZX1_DOC	:=SD1->D1_DOC
			   		ZX1->ZX1_SER	:=SD1->D1_SERIE
					ZX1->ZX1_EMISSA	:=SD1->D1_EMISSAO
					ZX1->ZX1_LOTE	:=SD1->D1_LOTECTL
					ZX1->ZX1_DT_LOT :=SD1->D1_DTVALID
 			   		ZX1->ZX1_CHAVE	:="ENT"+SubStr(cSF1Tit,4,5)
			   		ZX1->ZX1_ARQ	:=cSD1Tit
					ZX1->ZX1_PEDIDO	:=""
            		ZX1->(MsUnlock()) 
              		SD1->(DbSkip())  
                EndDo		                 
     		EndIf 
        
   	    
   	    Next
   	    
    EndIf


	If cTipo == "PED" 
    	
    	RecLock("ZX0",.T.)
    	ZX0->ZX0_FILIAL:=xFilial("SF1")
    	ZX0->ZX0_TIPO:="PEDIDO"
    	ZX0->ZX0_USER:=cUserName
    	ZX0->ZX0_DT   :=Date()
   		ZX0->ZX0_ARQ  :=cSC5Tit
   		ZX0->ZX0_CHAVE:="PED"+SubStr(cSC5Tit,4,5)
   	    ZX0->(MsUnlock())
   	    
   	    For i:=1 to Len(aDados)
   	         
   	    	// aPed 1.Pedido,2.Cliente,3.Loja
         	cChave:=aDados[i][1]+aDados[i][2]+aDados[i][3]

			SC6->(DbGoTop())
   			If SC6->(DbSeek(xFilial("SC6")+aDados[i][1]))	
      			While SC6->(!EOF()) .And. cChave==SC6->C6_NUM+SC6->C6_CLI+SC6->C6_LOJA  
         			RecLock("ZX1",.T.) 
          			ZX1->ZX1_FILIAL	:=xFilial("SD1")
					ZX1->ZX1_TIPO  	:="PEDIDO"
					ZX1->ZX1_ITEM	:=SC6->C6_ITEM
					ZX1->ZX1_COD	:=SC6->C6_PRODUTO
					ZX1->ZX1_QUANT	:=SC6->C6_QTDVEN
					ZX1->ZX1_CLIENT	:=SC6->C6_CLI
					ZX1->ZX1_LOJA	:=SC6->C6_LOJA
					ZX1->ZX1_DOC	:=""
			   		ZX1->ZX1_SER	:=""
					ZX1->ZX1_EMISSA	:=SC6->C6_P_DT
 			   		ZX1->ZX1_CHAVE	:="PED"+SubStr(cSC5Tit,4,5)
			   		ZX1->ZX1_ARQ	:=cSC6Tit
					ZX1->ZX1_PEDIDO	:=SC6->C6_NUM 
					ZX1->ZX1_LOTE	:=SC6->C6_LOTECTL
					ZX1->ZX1_DT_LOT :=SC6->C6_DTVALID
            		ZX1->(MsUnlock()) 
              		SC6->(DbSkip())  
                EndDo		                 
     		EndIf 
        
   	    
   	    Next
   	    
    EndIf


	If cTipo == "SAI" 
    	
    	RecLock("ZX0",.T.)
    	ZX0->ZX0_FILIAL:=xFilial("SD2")
    	ZX0->ZX0_TIPO	:="SAIDA"
    	ZX0->ZX0_USER	:=cUserName
    	ZX0->ZX0_DT   	:=Date()
   		ZX0->ZX0_ARQ  	:=cSD2Tit
   		ZX0->ZX0_CHAVE	:="SAI"+SubStr(cSD2Tit,4,5)
   	    ZX0->(MsUnlock())
   	    
   	    For i:=1 to Len(aDados)
   	         
   	    	// aDados 1.DOC,2.Serie,3.Cliente,4.Loja
         	cChave:=aDados[i][1]+aDados[i][2]+aDados[i][3]+aDados[i][4]

			SD2->(DbGoTop()) 
			SD2->(DbSetOrder(3))
   			If SD2->(DbSeek(xFilial("SD2")+cChave))	
      			While SD2->(!EOF()) .And. cChave==SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA  
         			RecLock("ZX1",.T.) 
          			ZX1->ZX1_FILIAL	:=xFilial("SD2")
					ZX1->ZX1_TIPO  	:="SAIDA"
					ZX1->ZX1_ITEM	:=SD2->D2_ITEM
					ZX1->ZX1_COD	:=SD2->D2_COD
					ZX1->ZX1_QUANT	:=SD2->D2_QUANT
					ZX1->ZX1_CLIENT	:=SD2->D2_CLIENTE
					ZX1->ZX1_LOJA	:=SD2->D2_LOJA
					ZX1->ZX1_DOC	:=SD2->D2_DOC
			   		ZX1->ZX1_SER	:=SD2->D2_SERIE
					ZX1->ZX1_EMISSA	:=SD2->D2_EMISSAO
 			   		ZX1->ZX1_CHAVE	:="SAI"+SubStr(cSD2Tit,4,5)
			   		ZX1->ZX1_ARQ	:=cSD2Tit
					ZX1->ZX1_PEDIDO	:=SD2->D2_PEDIDO  
					ZX1->ZX1_LOTE	:=SD2->D2_LOTECTL
					ZX1->ZX1_DT_LOT :=SD2->D2_DTVALID
            		ZX1->(MsUnlock()) 
              		SD2->(DbSkip())  
                EndDo		                 
     		EndIf 
        
   	    
   	    Next
   	    
   	EndIf
   	
   	If cTipo == "MAT" 
    	
    	RecLock("ZX0",.T.)
    	ZX0->ZX0_FILIAL	:=xFilial("ZX0")
    	ZX0->ZX0_TIPO	:="MAT"
    	ZX0->ZX0_USER	:=cUserName
    	ZX0->ZX0_DT   	:=Date()
   		ZX0->ZX0_ARQ  	:=cSB8Tit
   		ZX0->ZX0_CHAVE	:="MAT"+SubStr(cSB8Tit,4,5)
   	    ZX0->(MsUnlock())
   	    
   	    For i:=1 to Len(aDados)
   	    	
   	    	//aItens. 1.B8_PRODUTO,2.B8_LOCAL,3.B8_DATA,4.B8_DTVALID,5.B8_LOTECTL,6.B8_SALDO 
			RecLock("ZX1",.T.) 
   			ZX1->ZX1_FILIAL	:=xFilial("ZX1")
			ZX1->ZX1_TIPO  	:="MAT"
			ZX1->ZX1_ITEM	:=Strzero(i,4)
			ZX1->ZX1_COD	:=aDados[i][1]
			ZX1->ZX1_QUANT	:=aDados[i][6]
 	  		ZX1->ZX1_CHAVE	:="MAT"+SubStr(cSB8Tit,4,5)
			ZX1->ZX1_ARQ	:=cSB8Tit
			ZX1->ZX1_LOTE	:=aDados[i][5]
			ZX1->ZX1_DT_LOT :=STOD(aDados[i][4])
   			ZX1->(MsUnlock()) 
          
   	    Next

    
    EndIf

// Função numeração dos arquivos.
*--------------------------------------*
  Static Function NomeArq(cChave,cTipo)
*--------------------------------------* 

Local cNum,cData,cLetra  

SX5->(DbSetOrder(1))
If SX5->(DbSeek(xFilial("SX5")+"ZZ"+cTipo))
	cData  := Substr(SX5->X5_DESCRI,1,4)	
	cLetra := Substr(SX5->X5_DESCRI,5,1)	
	If cChave == cData
		cLetra := Alltrim(chr(asc(cLetra)+1))               	
		cNum   := cChave+cLetra
	Else
		cNum   := cChave+"A"	
	EndIf	

EndIf    

Return cNum  

//Marca todos
*----------------------------*
   Static Function MarcaTds()
*----------------------------* 
   
	DbSelectArea("TempSC9")   
 	TempSC9->(DbGoTop())  
  	While TempSC9->(!EOF())
    	RecLock("TempSC9",.F.)     
     	If TempSC9->cINTEGRA == cMarca
     		If Alltrim(TempSC9->cStatus) $ ("Liberado")    
      			TempSC9->cINTEGRA:=Space(02)   
      		EndIf
        Else
        	If Alltrim(TempSC9->cStatus) $ ("Liberado")  
        		TempSC9->cINTEGRA:= cMarca
        	EndIf	
        EndIf 

         TempSC9->(MsUnlock())
         TempSC9->(DbSkip())
    EndDo      
    
    TempSC9->(DbGoTop())      
      
Return 

                        
// Função para limpar as variaveis.
*----------------------------------*
  Static Function ClearVal(cCampo)
*----------------------------------* 

Local nPos,cCampo     

If valtype(cCampo) =="N" 
   cCampo:=Alltrim(Str(cCampo))  
EndIf  

nPos:=At(".",Alltrim(cCampo))   
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At(".",Alltrim(cCampo))   
EndDo 

nPos:=At("(",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At("(",Alltrim(cCampo))   
EndDo   

nPos:=At(")",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At(")",Alltrim(cCampo))   
EndDo  

nPos:=At("-",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")                                                         
   nPos:=At("-",Alltrim(cCampo))   
EndDo 
       
nPos:=At(" ",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At(" ",Alltrim(cCampo))   
EndDo 

nPos:=At("/",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At("/",Alltrim(cCampo))   
EndDo 

nPos:=At("\",Alltrim(cCampo))
While 0 < nPos                          
   cCampo:=Stuff(cCampo,nPos,1,"")
   nPos:=At("\",Alltrim(cCampo))   
EndDo 

Return (cCampo)  


//Função verificação de validade de lotes
*-------------------------*
 User Function ISESTLOTE()
*-------------------------*
 
Local oMain, oDlg 
Local lRet:=.F.  
Local aItens:={"Nao","Sim"}

Private cDe:=cAte:=space(3)
Private cGera
 
If !(cEmpAnt $ "IJ/IS/99" ) 
	MsgStop("Rotina especifico Promega ","Atenção") 
 	Return .F.
  EndIf
                
//Tela para selecão do arquivo
DEFINE MSDIALOG oDlg TITLE "Informe o periodo em dias" From 1,5 To 12,40 OF oMain  

	@ 013,020 Say "De"  of oDlg PIXEL 
	@ 010,039 Get cDe Size 010,10 OF oDlg PIXEL 
	@ 013,070 Say "a" of oDlg PIXEL 
	@ 010,085 Get cAte Size 010,10 OF oDlg PIXEL
	@ 032,033 Say "Gera excel"  of oDlg PIXEL 
	@ 030,075 Combobox cGera Items aItens PIXEL SIZE 30,6 OF oDlg
	@ 050,075 BUTTON "Cancela" size 40,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
 	@ 050,035 BUTTON "Ok" size 40,15 ACTION Processa({|| ProcRel(),oDlg:End()}) of oDlg Pixel        

ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return Nil     

*-----------------------------*
   Static Function ProcRel()           
*-----------------------------* 
 
  Local aStruSB8:= SB8->(DbStruct()) 
  Local cQuery:=""
  Local aCampos :={}
  Local cNome 	

  Private lRet:=.T.
  Private nPagina:=1
  Private oPrint

  Private oFont1   := TFont():New('Courier new',,-10,.T.)   
  Private oFont2   := TFont():New('Tahoma',,18,.T.)  
  Private oFont3   := TFont():New('Tahoma',,12,.T.) 
  Private oFont4   := TFont():New('Arial',,11,,.T.,,,,,.f. )   
  Private oFont5   := TFont():New('Arial',,9,,.T.,,,,,.f. )    
  Private oFont6   := TFont():New('Arial',,8,,.T.,,,,,.f. )   
  Private oFont7   := TFont():New('Arial',,6,,.T.,,,,,.f. ) 
  
                               	
   // Monta objeto para impressão
   oPrint := TMSPrinter():New("Impressão de saldos")
 
   // Define orientação da página para Retrato
   // pode ser usado oPrint:SetLandscape para Paisagem
   oPrint:SetPortrait()
    
   // Mostra janela de configuração de impressão
   //oPrint:Setup()

   // Inicia página
   oPrint:StartPage()  
    
    //Papel A4
   oPrint:SetpaperSize(9)                                                
    
   MontaRel() 
   
   If !(lRet)
      Return .F.     
   EndIf
   
   oPrint:EndPage()
                        
   // Mostra tela de visualização de impressão
   oPrint:Preview() 
    
   If cGera=="Sim"
   
   		If Select("QRB") > 0
   			QRB->(DbCloseArea())
   		EndIf 
   		
   		aCampos := {   {"PRODUTO"   ,"C",15,0},;
                       {"DESCRICAO" ,"C",40,0},;
                       {"SALDO"     ,"N",09,2},;
                       {"LOTE"      ,"C",10,0},;
                       {"VENCIMENTO","D",08,0}}
               
		cNome := CriaTrab(aCampos,.t.)
		dbUseArea(.T.,,cNome,"WORK",.F.,.F.)
   
		cQuery:= "SELECT * FROM "+RetSqlName("SB8")+" 
		cQuery+= "	Where B8_DTVALID >= '"+DTOS(Date()+val(cDe))+"'"  
		cQuery+= "	AND B8_SALDO>0 AND D_E_L_E_T_ <> '*' AND B8_DTVALID <= '"+DTOS(Date()+val(cAte))+"'"
		cQuery+= "  ORDER BY B8_PRODUTO"    

 		cQuery	:=	ChangeQuery(cQuery)
 		DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.) 
 		
 		For nI := 1 To Len(aStruSB8)
       		If aStruSB8[nI][2] <> "C" .and.  FieldPos(aStruSB8[nI][1]) > 0
	        	TcSetField("QRB",aStruSB8[nI][1],aStruSB8[nI][2],aStruSB8[nI][3],aStruSB8[nI][4])
   			EndIf
   		Next nI    
   		
   		QRB->(DbGoTop())
   		While QRB->(!EOF())
   		
   			RecLock("WORK",.T.) 
   			WORK->PRODUTO	:= QRB->B8_PRODUTO
   			SB1->(DbSetOrder(1))
   			If SB1->(DbSeek(xFilial("SB1")+QRB->B8_PRODUTO))
   		    	WORK->DESCRICAO := SB1->B1_DESC
   		    EndIf
   		    WORK->SALDO		:= QRB->B8_SALDO
   		    WORK->LOTE		:= QRB->B8_LOTECTL
   		    WORK->VENCIMENTO:= QRB->B8_DTVALID
   		                      
   		    Work->(MsUnlock())      
   			QRB->(DbSkip())
   		
   		EndDo   
   		
   		DbCloseArea("WORK") 
   		
   		cArqOrig := "\SYSTEM\"+cNome+".DBF"
   		cPath     := AllTrim(GetTempPath())                                                   
   		CpyS2T( cArqOrig , cPath, .T. )
                           
   		If ApOleClient("MsExcel")
      
      		oExcelApp:=MsExcel():New()
     		oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
      		oExcelApp:SetVisible(.T.)   
    
  		Else 
   
      		Alert("Excel não instalado") 
      
   		EndIf

		Erase "\SYSTEM\"+cNome+".DBF"
   
   EndIf
   
   //Finaliza Objeto 
   oPrint:End() 
	


Return     

*----------------------------*
  Static Function MontaRel() 
*----------------------------*
      
Local n:=1
Local nLinha:=560  
	
	MontaCab()
  
	cWhereB8 := "%"		
 	cWhereB8 +="	AND B8_DTVALID >= '"+DTOS(Date()+val(cDe))+"'" 
 	cWhereB8 +="	AND B8_DTVALID <= '"+DTOS(Date()+val(cAte))+"'"
	cWhereB8 += "%"   
 
	If Select("B8QRY") > 0
 		B8QRY->(DbCloseArea())	               
   	EndIf             
   
    BeginSql Alias 'B8QRY'
       SELECT *
       FROM %Table:SB8%
       WHERE %notDel%
       AND B8_FILIAL = %exp:xFilial("SB8")%
       AND B8_SALDO  >  0
       %exp:cWhereB8%

       ORDER BY B8_PRODUTO
       
    EndSql        
   	
	B8QRY->(DbGoTop())
    If !(B8QRY->(!BOF() .and. !EOF()))
    	MsgStop("Sem dados para visalização, verifique os dias informados")   
    	lRet:=.F.
    EndIf 
    
    SB1->(DbSetOrder(1))
    
    While B8QRY->(!EOF())	
   
      oPrint:Say(nLinha,50,Alltrim(B8QRY->B8_PRODUTO),oFont5)
      SB1->(DbSetOrder(1))
      If SB1->(DbSeek(xFilial("SB1")+B8QRY->B8_PRODUTO)) 
      	oPrint:Say(nLinha,400,Alltrim(SB1->B1_DESC),oFont5)
      EndIf
      oPrint:Say(nLinha,1130,Transform(B8QRY->B8_SALDO,"@E 999,999.99"),oFont5)
      oPrint:Say(nLinha,1300,Alltrim(B8QRY->B8_LOTECTL),oFont5)
      oPrint:Say(nLinha,1500,DTOC(STOD(B8QRY->B8_DTVALID)),oFont5)
      
         
      nLinha+=40
      n++   
      
      If nLinha==3320
            
         oPrint:EndPage()   
         oPrint:StartPage() 
         oPrint:SetPortrait()
         oPrint:SetpaperSize(9)
         nPagina++
         MontaCab()
         nLinha:=560
      
      EndIf   
      
   
      B8QRY->(DbSkip())   
      
    EndDo   
        
Return

*------------------------------*
   Static Function MontaCab()  
*------------------------------*   

	oPrint:Box(500,40,3320,2350)
   
   	//Linhas do Cabecario
   	oPrint:Line(550,40,550,2350)  //Linha
   	
   	oPrint:Line(500,390,3320,390)  //Coluna 
   	oPrint:Line(500,990,3320,990)  //Coluna 
   	oPrint:Line(500,1290,3320,1290)  //Coluna 
   	oPrint:Line(500,1490,3320,1490)  //Coluna 
   	   	   	   	 
    
	oPrint:SayBitmap(080,20,"\system\promega.bmp",400,300)
	oPrint:Say(190,2050,"Pagina  "+Alltrim(Str(nPagina)),oFont1)    
   	oPrint:Say(240,2050,"Emissão :"+Dtoc(date()),oFont1)   
   
   	oPrint:Say(120,500,SM0->M0_NOMECOM,oFont4)  
   	oPrint:Say(190,500,Alltrim(SM0->M0_ENDCOB),oFont5)   //Alltrim(SM0->M0_ENDCOB)
   	oPrint:Say(230,500,Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" ,"+Alltrim(SM0->M0_ESTCOB)+" - CEP "+Alltrim(SM0->M0_CEPCOB),oFont5)  
    oPrint:Say(270,500,"Telefone: ("+Substr(SM0->M0_TEL,1,2)+") "+Substr(SM0->M0_TEL,3,4)+"-"+Substr(SM0->M0_TEL,7,4)+"  FAX: ("+Substr(SM0->M0_FAX,1,2)+") "+Substr(SM0->M0_FAX,3,4)+"-"+Substr(SM0->M0_FAX,7,4) ,oFont5)

	oPrint:Say(400,700,"Relatório de lotes com vencimentos de "+Alltrim(cDe)+" até "+Alltrim(cAte)+" dias.",oFont4)   //SM0->M0_NOMECOM
   
	oPrint:Say(510,50,"Produto",oFont1)  
	oPrint:Say(510,400,"Descrição",oFont1)  
	oPrint:Say(510,1000,"Saldo",oFont1) 
	oPrint:Say(510,1300,"Lote",oFont1)     
	oPrint:Say(510,1500,"Vencimento",oFont1) 

Return


