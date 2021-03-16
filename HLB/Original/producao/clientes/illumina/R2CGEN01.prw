#include "Protheus.ch"
#include "Rwmake.ch"       
#include "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"

     
/*
Funcao      : R2CGEN01
Parametros  : 
Retorno     : 
Objetivos   : Integração e Geração de arquivos Illumina
Autor       : Tiago Luiz Mendonça
Data        : 10/11/2012
TDN         :                                                                                                        
Revisão     : 
Data/Hora   : 
Módulo      : Generico.
*/ 
//Função Principal para geração de arquivos.
*-------------------------*
 User Function R2CGEN01()
*-------------------------*
 
Local oMain, oDlg , oCbx 

Private lConnect
Private aArqs    := {}  


//Tela de geração de arquivos.
DEFINE MSDIALOG oDlg TITLE "Geração de arquivo FTP" From 1,15 To 13,50 OF oMain  

	@ 010,020 BUTTON "ARQUIVO DE ENTRADAS" size 100,15 ACTION Processa({|| GENEST01() }) of oDlg Pixel  
    @ 031,020 BUTTON "ARQUIVO DE SAIDA"    size 100,15 ACTION Processa({|| GENFAT02() }) of oDlg Pixel     
    @ 050,020 BUTTON "ARQUIVO DE REMESSA"    size 100,15 ACTION Processa({|| GENFAT03() }) of oDlg Pixel 
    @ 070,020 BUTTON "Cancela" size 100,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel                                                                 
                                                                        
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Return Nil 


//Gera arquivo de Entrada
*---------------------------*
  Static Function GENEST01()
*---------------------------*   
 
Local cSF1Txt,cSD1Txt
Local nSF1Hdl,nSD1Hdl
Local cWhereF,cWhereD
Local cDtLote,cChave 

Local cWhereF1 := ""
Local cWhereD1 := ""
Local cQuery   := ""
Local cContato := ""  

Local aNotas   := {}     
Local aButtons := {}
Local aButtons := {} 

Local cNum     := SubStr(Alltrim(DTOC(Date())),4,2)+SubStr(Alltrim(DTOC(Date())),1,2)     
Local oFont14  := TFont():New('Courier new',,-14,.T.)
Local cEOL     := "CHR(13)+CHR(10)" 
Local cDir     := "\ftp\2C\ENTRADA\"    
Local cPath	   := AllTrim(GetTempPath()) 

Local cData    := DTOS(Date()) 
Local lDados   :=.F.  
Local nOpcao   := 2    
Local n        := 1

        
Private cSF1Tit,cSD1Tit 

Private cMarca   := GetMark() 
                    
Private aCpos    := {}
Private aStruSF1 := {}
Private aItens   := {} 

Private lInverte := .f.


SET DATE FORMAT "dd/mm/yyyy"


// Alexandre Caetano - 01 de Outubro de 2012                           
// Criação de tela para seleção das notas a serem enviadas por arquivo 
If Select("TempSF1") > 0
	TempSF1->(DbCloseArea())	               
EndIf  

aadd(aButtons,{"PENDENTE",{|| MarcaTds("TempSF1")},"Marca ","Marca ",{|| .T.}})
aadd(aButtons,{"BMPPOST",{|| EnviaEmail("TempSF1")},"Reenvia Email","Reenvia Email",{|| .T.}})

//Campos do MarkBrowse
Aadd(aCpos, {"cINTEGRA"       ,"",                  })  
Aadd(aCpos, {"F1_DOC"         ,"", "Nota Fiscal",   })
Aadd(aCpos, {"F1_SERIE"       ,"", "Serie Fiscal",  })
Aadd(aCpos, {"F1_FORNECE" 	  ,"", "Cod.Fornecedor",})
Aadd(aCpos, {"A2_NOME"        ,"", "Fornecedor",    }) 
Aadd(aCpos, {"F1_LOJA"        ,"", "Loja",          })   
Aadd(aCpos, {"F1_EMISSAO"     ,"", "Emissao",       })
Aadd(aCpos, {"F1_VALBRUT"     ,"", "Valor da NF",   })

                 
// Arquivo Temporario  
Aadd(aStruSF1, {"F1_FILIAL"   ,AvSx3("F1_FILIAL" ,2),AvSx3("F1_FILIAL" ,3),AvSx3("F1_FILIAL" ,4)})
Aadd(aStruSF1, {"cINTEGRA"    ,"C"                  ,2                    ,0                    })
Aadd(aStruSF1, {"F1_DOC"      ,AvSx3("F1_DOC"    ,2),AvSx3("F1_DOC"    ,3),AvSx3("F1_DOC"    ,4)})
Aadd(aStruSF1, {"F1_SERIE"    ,AvSx3("F1_SERIE"  ,2),AvSx3("F1_SERIE"  ,3),AvSx3("F1_SERIE"  ,4)})  
Aadd(aStruSF1, {"F1_FORNECE"  ,AvSx3("F1_FORNECE",2),AvSx3("F1_FORNECE",3),AvSx3("F1_FORNECE",4)})
Aadd(aStruSF1, {"A2_NOME"     ,AvSx3("A2_NOME",   2),AvSx3("A2_NOME"   ,3),AvSx3("A2_NOME"   ,4)})
Aadd(aStruSF1, {"F1_LOJA"     ,AvSx3("F1_LOJA"   ,2),AvSx3("F1_LOJA"   ,3),AvSx3("F1_LOJA"   ,4)})
Aadd(aStruSF1, {"F1_EMISSAO"  ,AvSx3("F1_EMISSAO",2),AvSx3("F1_EMISSAO",3),AvSx3("F1_EMISSAO",4)})
Aadd(aStruSF1, {"F1_VALBRUT"  ,AvSx3("F1_VALBRUT",2),AvSx3("F1_VALBRUT",3),AvSx3("F1_VALBRUT",4)})

cNome := CriaTrab(aStruSF1, .T.)                   
DbUseArea(.T.,"DBFCDX",cNome,'TempSF1',.F.,.F.)       
IndRegua("TempSF1", cNome, "F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA",,.T.,"Indexando tabela temporária...")

If Select("SF1QRY") > 0
	SF1QRY->(DbCloseArea())	               
EndIf

/*
cQuery := " SELECT DISTINCT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_VALBRUT, SF1.F1_TIPO, " + Chr(13)
cQuery += "        SF4.F4_CODIGO, SF4.F4_ESTOQUE, SA2.A2_NOME "  + Chr(13)
cQuery += " FROM " + RetSqlName("SF1") + " SF1 "  + Chr(13)
cQuery += " INNER JOIN "  + RetSqlName("SD1") + " SD1 "  + Chr(13)
cQuery += "      ON (F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SD1.D_E_L_E_T_ = '') "  + Chr(13)
cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON (D1_TES = F4_CODIGO AND SF4.D_E_L_E_T_ = '' ) "  + Chr(13)
cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (A2_FILIAL = '" + xFilial("SA2") + "' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = '') "  + Chr(13)
cQuery += " WHERE SF1.D_E_L_E_T_ = ''"  + Chr(13)
cQuery += " AND F4_ESTOQUE = 'S' "  + Chr(13)
cQuery += " AND F1_FILIAL = '" + xFilial("SF1") + "' " + Chr(13) 
cQuery += " AND F1_P_GER = '' "   + Chr(13)
cQuery += " AND (SELECT COUNT(*) FROM " + RetSqlName("SD1") + " SD11 WHERE SD11.D1_DOC = SF1.F1_DOC AND SD11.D1_SERIE = SF1.F1_SERIE "  + Chr(13) 
cQuery += " AND SD11.D1_FORNECE = SF1.F1_FORNECE AND SD11.D1_LOJA = SF1.F1_LOJA AND SD11.D_E_L_E_T_ = '') = "  + Chr(13)
cQuery += "     (SELECT COUNT(*) FROM " + RetSqlName("SD1") + " SD12 INNER JOIN " + RetSqlName("SF4") + " SF41 ON (SD12.D1_TES = SF41.F4_CODIGO AND "  + Chr(13)
cQuery += "     SF41.D_E_L_E_T_ = '' )  WHERE SD12.D1_DOC = SF1.F1_DOC AND SD12.D1_SERIE = SF1.F1_SERIE AND SD12.D1_FORNECE = SF1.F1_FORNECE AND "  + Chr(13)
cQuery += "    SD12.D1_LOJA = SF1.F1_LOJA AND SD12.D_E_L_E_T_ = '' AND SF41.F4_ESTOQUE = 'S') " + Chr(13)
cQuery += " ORDER BY F1_DOC, F1_SERIE "  + Chr(13)
*/      


cQuery := " SELECT DISTINCT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_VALBRUT, SF1.F1_TIPO, " + Chr(13)
cQuery += "         SA2.A2_NOME "  + Chr(13)
cQuery += " FROM " + RetSqlName("SF1") + " SF1 "  + Chr(13)
cQuery += " INNER JOIN "  + RetSqlName("SD1") + " SD1 "  + Chr(13)
cQuery += "      ON (F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SD1.D_E_L_E_T_ = '') "  + Chr(13)
cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON (D1_TES = F4_CODIGO AND SF4.D_E_L_E_T_ = '' ) "  + Chr(13)
cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (A2_FILIAL = '" + xFilial("SA2") + "' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = '') "  + Chr(13)
cQuery += " WHERE SF1.D_E_L_E_T_ = ''"  + Chr(13)
cQuery += " AND F4_ESTOQUE = 'S' "  + Chr(13)
cQuery += " AND F1_FILIAL = '" + xFilial("SF1") + "' " + Chr(13) 
cQuery += " AND F1_P_GER = '' "   + Chr(13)


If Select("SF1QRY") > 0
	SF1QRY->(dbCloseArea())
Endif

//Cria Alias
TCQuery cQuery ALIAS "SF1QRY" NEW 

TcSetField("SF1QRY","F1_EMISSAO","D",08,00)
                                 
SF1QRY->(DbGoTop())
If !(SF1QRY->(!BOF() .and. !EOF()))
   	MsgStop("Não existe itens liberados para ser enviado","Illumina")
	Return .F.
EndIf   

SD1->(DbSetOrder(1))
SF4->(DbSetOrder(1))
    	
While SF1QRY->(!EOF())    
    
	RecLock("TempSF1",.T.)
	TempSF1->F1_FILIAL  := SF1QRY->F1_FILIAL            
	TempSF1->F1_DOC     := SF1QRY->F1_DOC
	TempSF1->F1_SERIE   := SF1QRY->F1_SERIE
	TempSF1->F1_FORNECE := SF1QRY->F1_FORNECE
	TempSF1->A2_NOME    := SF1QRY->A2_NOME
	TempSF1->F1_LOJA    := SF1QRY->F1_LOJA   	
	TempSF1->F1_EMISSAO := SF1QRY->F1_EMISSAO
	TempSF1->F1_VALBRUT := SF1QRY->F1_VALBRUT
	TempSF1->(MsUnlock())		

	
    SF1QRY->(DbSkip())
   
EndDo    
    
    
TempSF1->(DbGoTop())
If TempSF1->(!BOF() .and. !EOF())
    
   	DEFINE MSDIALOG oDlg TITLE "Notas Fiscais de Entrada" FROM 000,000 TO 545,1100 PIXEL
                      
        @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
        @ 026 , 015 Say  "SELECIONE SOMENTE AS NOTAS FISCAIS DE ENTRADA QUE SERÃO GERADOS PARA A BOMI" COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,8 Font oFont14 OF oDlg           
                        
        oTMsgBar := TMsgBar():New(oDlg,"GERAÇÃO DE ARQUIVOS",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont14,.F.)   
        oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
        oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
    	oMarkPrd:= MsSelect():New("TempSF1","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545},,,oDlg,,)   
     	   
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{|| (nOpcao:=2,oDlg:End())},,aButtons) CENTERED
    	
Else
   	MsgInfo("Nenhum dado encontrado para geração do arquivo","Illumina")
   	Return .F.   
EndIf

If nOpcao == 1
	cEOL := Trim(cEOL)
	cEOL := &cEOL       
  
	If !(MsgYesNo("Deseja realmente gerar o arquivo de ENTRADAS"))
		Return .F.
	Endif

 
	//Nome do arquivo baseado na data + letra     
	cNum := NomeArq(cNum,"ENT")     

	//Alexandre Caetano -  02 de Outubro de 2012
	//Montagem do arquivo de integração

	// Cabeçalho
	cSF1Txt:=cDir+"RHB"+cNum+".TXT"
	cSF1Tit:="RHB"+cNum+".TXT"
      
	nSF1Hdl:= fCreate(cSF1Txt)

	If nSF1Hdl == -1 // Testa se o arquivo foi gerado
		MsgAlert("O arquivo "+cSF1Txt+" nao pode ser executado!","Atenção")
	EndIf          
	//---------- 
             
	//Itens     
	cSD1Txt:=cDir+"RIB"+cNum+".TXT"
	cSD1Tit:="RIB"+cNum+".TXT"
                
	nSD1Hdl:= fCreate(cSD1Txt)
	If nSD1Hdl == -1 // Testa se o arquivo foi gerado
		MsgAlert("O arquivo "+cSD1Txt+" nao pode ser executado!","Atenção")
	EndIf  
	//----------
		                    

	SF1QRY->(DbGoTop())                
	Do While SF1QRY->(!EoF())   

    	TempSF1->(DbSeek(SF1QRY->F1_DOC+SF1QRY->F1_SERIE+SF1QRY->F1_FORNECE+SF1QRY->F1_LOJA))
    
		If TempSF1->cIntegra = cMarca   // Verifica se a NF foi marcada para envio
    	
			Aadd(aNotas,{SF1QRY->F1_DOC,SF1QRY->F1_SERIE,SF1QRY->F1_FORNECE,SF1QRY->F1_LOJA,SF1QRY->F1_TIPO})  
    	     
   	    	cChave:=SF1QRY->F1_DOC+SF1QRY->F1_SERIE+SF1QRY->F1_FORNECE+SF1QRY->F1_LOJA
    	            	
       	 	lDados:=.T.
    	     
    		//119                     
       		nTamLin   := 129
       	 	cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
       	 	//   Cabeçalho                -----------       Comentários
        
        	cCab  := Stuff(cCab,01,03,"ILU")               // Fixo com "ILU"      
                   
        	If SF1QRY->F1_TIPO =="N"
        		cCab  := Stuff(cCab,4,03,"TRB") 				// Tipo do recebimento 
        		SA2->(DbSetOrder(1))
           		If SA2->(DbSeek(xFilial("SA2")+SF1QRY->F1_FORNECE+SF1QRY->F1_LOJA))
           			cContato:=SA2->A2_CONTATO
				EndIf              	  
        	Else
        		cCab  := Stuff(cCab,4,03,"DEV") 		  		// Tipo do recebimento   
        		SA1->(DbSetOrder(1))
           		If SA1->(DbSeek(xFilial("SA1")+SF1QRY->F1_FORNECE+SF1QRY->F1_LOJA))
           			cContato:=SA1->A1_CONTATO
   				EndIf   
        	EndIf   
                
        	cCab  := Stuff(cCab,07,10,Alltrim(Str(Val(SF1QRY->F1_DOC))))             // Número da NF de entrada  
        	cCab  := Stuff(cCab,17,04,"VEN")              		// Fixo VEN 
        	cCab  := Stuff(cCab,21,02,SF1QRY->F1_SERIE)           // Serie da nota
        	cCab  := Stuff(cCab,23,06,space(6))              	// Origem da mercadoria
        	cCab  := Stuff(cCab,29,30,space(30))              	// Descrição da Origem 
       		cCab  := Stuff(cCab,59,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
       		cCab  := Stuff(cCab,69,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
       		cCab  := Stuff(cCab,79,30,space(30))       			 // Fonte de recebimento
       		cCab  := Stuff(cCab,109,01,"E")              		// Fonte de recebimento
       	 	cCab  := Stuff(cCab,110,06,"000000")             	// Hota
       	 	cCab  := Stuff(cCab,116,03,"REC")              		//Código de Area de recebimento BOMI
        	cCab  := Stuff(cCab,119,10,space(10))+cEOL              	// Transportadora
        
   	   		If fWrite(nSF1Hdl,cCab,Len(cCab)) != (Len(cCab))
  				If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabeçalho HDR (cCab). ","Atencao!")
     				Return .F. 
        		Endif 
       	 	EndIf
       	 	
        
        	//Arquivo de integração dos itens da NF
        	SD1->(DbGoTop(1))                                                 
       		SD1->(DbSeek(xFilial("SD1")+cChave))	
        
        	Do While SD1->D1_FILIAL = SF1QRY->F1_FILIAL .and. SD1->D1_DOC = SF1QRY->F1_DOC .and. SD1->D1_SERIE = SF1QRY->F1_SERIE .and.;
            	     SD1->D1_FORNECE = SF1QRY->F1_FORNECE .and. SD1->D1_LOJA = SF1QRY->F1_LOJA
                 
        		
        		// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
    			Aadd(aItens,{SF1QRY->F1_DOC+SF1QRY->F1_SERIE,SD1->D1_CONHEC,SD1->D1_COD,SD1->D1_LOTECTL,"Componente",SD1->D1_QUANT})  
        		
        		lDados:=.T.
                                      	       		
     			nTamLin   := 115
        		cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
          		//   ITENS               -----------       Comentários
        
           		cCab  := Stuff(cCab,01,03,"ILU")               // Fixo com "ILU"
                         
       	   		If SD1->D1_TIPO =="N"
      				cCab  := Stuff(cCab,04,03,"TRB") 				// Tipo do recebimento 
        			SA2->(DbSetOrder(1))
           			If SA2->(DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
           				cContato:=SA2->A2_CONTATO
					EndIf              	  
        		Else
           			cCab  := Stuff(cCab,04,03,"DEV") 		  		// Tipo do recebimento   
           			SA1->(DbSetOrder(1))
           			If SA1->(DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA))
           	 			cContato:=SA1->A1_CONTATO
		   			EndIf   
        		EndIf   
                
        		cCab  := Stuff(cCab,07,10,Alltrim(Str(Val(SD1->D1_DOC))))                    // Número da NF de entrada  
        		cCab  := Stuff(cCab,17,04,strzero(n,4))              	              	    // Fixo VEN 
        		cCab  := Stuff(cCab,21,15,Replicate(" ",15-Len(SD1->D1_COD))+SD1->D1_COD)   //Codigo do produto
        		cCab  := Stuff(cCab,36,10,"0"+ClearVal(strzero(SD1->D1_VUNIT,10,2)))        // Valor unitario
           		cCab  := Stuff(cCab,46,9,ClearVal(strzero(SD1->D1_QUANT,9,0)))              // Quantidade
        		cCab  := Stuff(cCab,55,01,"E")                           					// Fonte de recebimento  
        		SB1->(DbSetOrder(1))
        		If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))   
        			cCab  := Stuff(cCab,56,30,SubStr(Alltrim(SB1->B1_DESC),1,30))     		// Descrição do item
        		EndIf	
             		
        		cCab  := Stuff(cCab,86,15,SD1->D1_LOTECTL+"     ")   // Lote 
        		If !Empty(SD1->D1_DTVALID)
        			cCab  := Stuff(cCab,101,10,SubStr(DtoC(SD1->D1_DTVALID),7,4)+"-"+substr(DtoC(SD1->D1_DTVALID),4,2)+"-"+SubStr(DtoC(SD1->D1_DTVALID),1,2))    // Data do Pedido 
          		Else
          			cCab  := Stuff(cCab,101,10,space(10)) 
          		EndIF
          		cCab  := Stuff(cCab,111,03,"LIB")+cEOL               		//FIXO "LIB"
          			
	   			If fWrite(nSD1Hdl,cCab,Len(cCab)) != (Len(cCab))
  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
     		   			Return .F. 
        			Endif 
           		EndIf 
           		
           		n++
                 
        		SD1->(DbSkip())
        	Enddo
            	
   		Endif

		SF1QRY->(DbSkip())
	Enddo  

	aAdd(aArqs,cSF1Tit)
	aAdd(aArqs,cSD1Tit)
	
	fClose(nSF1Hdl) 
	fClose(nSD1Hdl)   
                                   
	SF1->(DbSetOrder(1))                
	SD1->(DbSetOrder(1))     

	If Len(aNotas) > 0      
                 
		// Atualiza SF1/SD1 com dados gerados.
		For i:=1 to Len(aNotas)
   	      		
			// aNotas 1.DOC,2.SERIE,3.FORNECE,4.LOJA,5.TIPO
			cChave:=aNotas[i][1]+aNotas[i][2]+aNotas[i][3]+aNotas[i][4]
         		
   			SF1->(DbGoTop())
			If SF1->(DbSeek(xFilial("SF1")+cChave))	
				RecLock("SF1",.F.) 
   				SF1->F1_P_GER :="S"
   				SF1->F1_P_ARQ :=cSF1Tit+";"+cSD1Tit
   				SF1->F1_P_OBS  := Alltrim( UsrFullName( __cUserID) ) + DtoS( Date() ) + Time()
   				SF1->(MsUnlock())
   				SF1->(DbSkip())                     
			EndIf             	
		Next
         	
		If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"ENT")) 
			RecLock("SX5",.F.)  
   	 		SX5->X5_DESCRI:=cNum
   	 		SX5->(MsUnlock())    
		EndIf
         	
		MsgInfo("Arquivos gerados com sucesso.","Illumina")    
          
		EMail(aNotas,"ENT",cSF1Txt+";"+cSD1Txt,aItens)   
		
		lConnect:=ConectaFTP()
		            
		If lConnect                                       
			
			FTPDirChange(cDir)  // Monta o diretório do FTP, será gravado na raiz "/"
			 
			For i=1 to Len(aArqs)	
				// Grava Arquivo no FTP
			 	If FTPUpLoad(cDir+alltrim(aArqs[i]),alltrim(aArqs[i]))
			     	Conout("Arquivo "+alltrim(aArqs[i])+" gerado com sucesso no FTP interno.")   		
				Else 
		 	 	   Conout("O Arquivo "+alltrim(aArqs[i])+" não pode ser gravado no FTP interno") 
				EndIf  
			Next	
			
		EndIf
			 
		FTPDisconnect()   

		                             
		If !(lDados)
			MsgInfo("Nenhum dado encontrado para geração do arquivo","Illumina")
  		EndIf
    
	Else
		MsgInfo("Nenhum dado encontrado para geração do arquivo","Illumina")    
	EndIf
Endif              

Return  
        
//Gera arquivo de SAIDA
*-------------------------*
 Static Function GENFAT02()
*-------------------------*   

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
	 	
	//Nome do arquivo baseado na data + letra     
	cNum := NomeArq(cNum,"SAI")    
	  
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
            /*
            SF2->(DbSetOrder(1))
            If SF2->(DbSeek(xFilial("SF2")+C9QRY->C9_NFISCAL+C9QRY->C9_SERIENF+C9QRY->C9_CLIENTE+C9QRY->C9_LOJA))
            	If !Empty(SF2->F2_CHVNFE)
            		C9QRY->(DbSkip())
         			loop                
            	EndIf
            
            EndIf
            */  
                        
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


	aadd(aButtons,{"PENDENTE",{|| MarcaTds("TempSF2")},"Marca ","Marca ",{|| .T.}})
	aadd(aButtons,{"BMPPOST",{|| EnviaEmail("TempSF2")},"Reenvia Email","Reenvia Email",{|| .T.}})

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
Local cDir  	:= "\ftp\2C\SAIDA\"    
Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cContato	:="" 
Local cNumAux   :=""
Local n         :=1  

Private cSC5Tit,cSC6Tit     

SET DATE FORMAT "dd/mm/yyyy"
         
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
        
		aAdd(aArqs,cSC5Tit)

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
        
        			cCab  := Stuff(cCab,01,03,"ILU")               		 // Fixo com "MEG"                      
           			//cCab  := Stuff(cCab,04,16,SC5->C5_NUM)             // Número do Pedido   
           			cCab  := Stuff(cCab,04,16,Alltrim(Str(Val(TempSC9->C9_NFISCAL))))  // Número do Pedido
        			cCab  := Stuff(cCab,20,03,"PEX")              		 // Fixo VEN           			        			
					cCab  := Stuff(cCab,23,02,SC5->C5_P_TPFRE) 			 // Tipo de transporte 
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
					cCab  := Stuff(cCab,231,04,"VEN")                	 // Fixo "VEN"
					cCab  := Stuff(cCab,235,03,"ILU")               	 // Fixo "MEG"				
					cCab  := Stuff(cCab,238,2,Space(2))             	 // Nivel de servico 
					cCab  := Stuff(cCab,240,2,Substr(TempSC9->C9_SERIENF,1,2)) // Serie da nota fiscal de saida
					cCab  := Stuff(cCab,242,2,Space(8))           		 // Campo configuravel     
					SF2->(DbSetOrder(1))
					SF2->(DbSeek(xFilial("SF2")+TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
					cCab  := Stuff(cCab,250,10,replicate("0",10-Len(ClearVal(SF2->F2_VALMERC)))+ClearVal(SF2->F2_VALMERC))// Valor da nota fiscal 
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
	     
	    n:=1 
	               		  
    	TempSC9->(DbGoTop()) 
    	cNumAux:=TempSC9->C9_PEDIDO
		While TempSC9->(!EOF())   
		
  			If Alltrim(TempSC9->cStatus)== "Liberado"  .And. !Empty(Alltrim(TempSC9->cINTEGRA))

	  			SC6->(DbGoTop(2))
	  			If SC6->(DbSeek(xFilial("SC6")+TempSC9->C9_PEDIDO+TempSC9->C9_ITEM))
	  			    
	  				
	  				If cNumAux<>TempSC9->C9_PEDIDO
	  			    	//n:=1
	  			    	cNumAux:=TempSC9->C9_PEDIDO
	  			    EndIf    
	  			
 					
 					If !Empty(SC6->C6_P_OP)    
 					
 				   		// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
    			   		Aadd(aItens,{TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF,SC6->C6_NUM,SC6->C6_PRODUTO,"Não possui","KIT",SC6->C6_QTDVEN})  	           
    	
	    	   			SD3->(DbSetOrder(1))
	    	   			IF SD3->(DbSeek(xFilial("SD3")+SC6->C6_P_OP))	    		
		    		
				    		Do While SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_OP == SC6->C6_P_OP 
			    		     
				    			If SD3->D3_CF == "PR0"  .Or. SD3->D3_ESTORNO == "S"               	
				    		    	SD3->(DbSkip())	
				    		    	Loop 
				    		    EndIf                        

				   				nTamLin   := 83
							    cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
							 
							 	//   ITENS             tiago	  -----------       Comentários
							  	cCab  := Stuff(cCab,01,03,"ILU")               	      // Fixo com "MEG"
							   	//cCab  := Stuff(cCab,04,16,TempSC9->C9_PEDIDO) 		          // Numero do pedido 
							        					    		         
								// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
		    					Aadd(aItens,{TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF,SC6->C6_NUM,SD3->D3_COD,SD3->D3_LOTECTL,"Componente",TempSC9->C9_QTDLIB})  
													
						       	cCab  := Stuff(cCab,04,16,Alltrim(Str(Val(TempSC9->C9_NFISCAL)))+space(16-len(Alltrim(Str(Val(TempSC9->C9_NFISCAL))))) ) 		  // Numero do pedido
							 	cCab  := Stuff(cCab,20,4,strzero(n,4))                // Sequencia	    
							   	cCab  := Stuff(cCab,24,15,SD3->D3_COD)                // Codigo do item
							   	cCab  := Stuff(cCab,39,9,strzero(SD3->D3_QUANT,9,0))  // Quantidade do item
							   	cCab  := Stuff(cCab,48,1,"N") 			              // Operação Cross-docking 
							   	cCab  := Stuff(cCab,49,4,"VEN ")                      // Armazem
							   	cCab  := Stuff(cCab,53,1,"N")                    	  // Linha pode ser dividida
							   	cCab  := Stuff(cCab,54,03,"PEX")                      // Tipo do pedido  
							   	SD2->(DbSetOrder(3))
							   	If SD2->(DbSeeK(xFilial("SD2")+TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF+TempSC9->C9_CLIENTE+TempSC9->C9_LOJA ))
							   		cCab  := Stuff(cCab,57,10,SubStr(DtoC(SD2->D2_EMISSAO),7,4)+"-"+substr(DtoC(SD2->D2_EMISSAO),4,2)+"-"+SubStr(DtoC(SD2->D2_EMISSAO),1,2))                    // Data do pedido
							   	EndIf
							  	cCab  := Stuff(cCab,67,15,SD3->D3_LOTECTL+space(9))   // Lote   
							   	cCab  := Stuff(cCab,82,01,"S")      				   // Fixo "S"
							   	cCab  := Stuff(cCab,83,07,space(7))+cEOL       		   // Branco 
							        		 
							  	n++ 
							        		      
							        		
							   	If fWrite(nSC6Hdl,cCab,Len(cCab)) != (Len(cCab))
				  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
				     					Return .F.    
				     			  	EndIf	
				        	  	Endif 
				           				
			
				      				        		    			                     
								SD3->(DbSkip())
			                
			        		EndDo 
			        		
			        	EndIf 
			        
			        Else
			        	
			        	//If  !Empty(TempSC9->C9_LOTECTL)           
			        	
								nTamLin   := 83
							 	cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
							 
							 	//   ITENS               -----------       Comentários
							 	cCab  := Stuff(cCab,01,03,"ILU")               	      // Fixo com "MEG"
							  	//cCab  := Stuff(cCab,04,16,TempSC9->C9_PEDIDO) 	  // Numero do pedido 
							        					    		         
								// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
		    					Aadd(aItens,{TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF,SC6->C6_NUM,TempSC9->C9_PRODUTO,TempSC9->C9_LOTECTL,"Componente",TempSC9->C9_QTDLIB})  
													
						        cCab  := Stuff(cCab,04,16,Alltrim(Str(Val(TempSC9->C9_NFISCAL)))+space(16-len(Alltrim(Str(Val(TempSC9->C9_NFISCAL))))) ) 		  // Numero do pedido
							    cCab  := Stuff(cCab,20,4,strzero(n,4))                // Sequencia	    
							 	cCab  := Stuff(cCab,24,15,TempSC9->C9_PRODUTO)            // Codigo do item
							  	cCab  := Stuff(cCab,39,9,strzero(TempSC9->C9_QTDLIB,9,0))// Quantidade do item
							   	cCab  := Stuff(cCab,48,1,"N") 			              // Operação Cross-docking 
							    cCab  := Stuff(cCab,49,4,"VEN ")                      // Armazem
							    cCab  := Stuff(cCab,53,1,"N")                    	  // Linha pode ser dividida
							    cCab  := Stuff(cCab,54,03,"PEX")                      // Tipo do pedido  
							    //cCab  := Stuff(cCab,57,10,SubStr(TempSC9->C9_DTVALID,1,4)+"-"+substr(TempSC9->C9_DTVALID,5,2)+"-"+SubStr(TempSC9->C9_DTVALID,7,2))                    // Data do pedido
							    SD2->(DbSetOrder(3))
							    If SD2->(DbSeeK(xFilial("SD2")+TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF+TempSC9->C9_CLIENTE+TempSC9->C9_LOJA ))
							    	cCab  := Stuff(cCab,57,10,SubStr(DtoC(SD2->D2_EMISSAO),7,4)+"-"+substr(DtoC(SD2->D2_EMISSAO),4,2)+"-"+SubStr(DtoC(SD2->D2_EMISSAO),1,2))                    // Data do pedido
							    EndIf
							    cCab  := Stuff(cCab,67,15,TempSC9->C9_LOTECTL+space(9))   // Lote   
							    cCab  := Stuff(cCab,82,01,"S")      				  // Fixo "S"
							    cCab  := Stuff(cCab,83,07,space(7))+cEOL       		  // Branco  
							    
							    If fWrite(nSC6Hdl,cCab,Len(cCab)) != (Len(cCab))
				  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
				     			   		Return .F. 
				        	   		Endif 
				           		EndIf   
				           		
				           		n++
			        	
				        	
				       //EndIf	
			        	
			        EndIf
			    				        
        		EndIf	
                
        	EndIf
        	
        	TempSC9->(DbSkip())
       	
       	EndDo

     	aAdd(aArqs,cSC6Tit)
           
		fClose(nSC6Hdl)   
                    
  		TempSC9->(dbCloseArea())  
          	        
    	// Atualiza SC5        	
     	For i:=1 to Len(aPed)
         		  
      		// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE    	  
         		         		
         	SC5->(DbGoTop())  
         	SC5->(DbSetOrder(1))
         	If SC5->(DbSeek(xFilial("SC5")+aPed[i][1]))	
          		RecLock("SC5",.F.) 
             	SC5->C5_P_GER :="S"
             	SC5->C5_P_ARQ  :=cSC5Tit+";"+cSC6Tit   
             	SC5->C5_P_OBS  := Alltrim( UsrFullName( __cUserID) ) + DtoS( Date() ) + Time()          	
               	SC5->(MsUnlock())
             	SC5->(DbSkip())                     
          	EndIf 
            
 		Next
 		
    	// Atualiza SC9
   		For i:=1 to Len(aPed)
     
                                                                                                                              
            SC9->(DbGoTop())    
            SC9->(DbSetOrder(1))  //C9_FILIAL+C9_PEDIDO                                                                                                                                
            If SC9->(DbSeek(xFilial("SC9")+aPed[i][1]))	
            	
            	While SC9->(!EOF()) .And. SC9->C9_PEDIDO == aPed[i][1]
	           
	            	RecLock("SC9",.F.) 
	            	SC9->C9_P_GER  :="S"          	
	            	SC9->(MsUnlock()) 	
                	
                	SC9->(DbSkip())
               
               	EndDo	                          
             
            EndIf                      
                	
      	Next
              		
       	If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"SAI")) 
	        RecLock("SX5",.F.)  
	        SX5->X5_DESCRI:=cNum
	        SX5->(MsUnlock())    
        EndIf
         	
        
        MsgInfo("Arquivos gerados com sucesso.","Illumina")    
          
		EMail(aPed,"SAI",cSC5Txt+";"+cSC6Txt,aItens)  
		
		
		lConnect:=ConectaFTP()
            
		If lConnect                                       
			
			FTPDirChange(cDir)  // Monta o diretório do FTP, será gravado na raiz "/"
			 
			For i=1 to Len(aArqs)	
				// Grava Arquivo no FTP
			 	If FTPUpLoad(cDir+alltrim(aArqs[i]),alltrim(aArqs[i]))
			     	Conout("Arquivo "+alltrim(aArqs[i])+" gerado com sucesso no FTP interno.")   		
				Else 
		 	 	   Conout("O Arquivo "+alltrim(aArqs[i])+" não pode ser gravado no FTP interno") 
				EndIf  
			Next	
			
		EndIf
			 
		FTPDisconnect()  
           
    Else
    	MsgStop("Existem itens não marcardos ou itens bloqueados que estão marcados, verificar.","Promega")  
    	TempSC9->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet      

// Função de envio de e-mail
*-------------------------------------------------*
  Static Function Email(aDados,cTipo,cFile,aItens)
*-------------------------------------------------*  

Local cSubject     := ""
Local cNome        := ""  
Local cNf          := ""
Local cAnexo       := ""  
Local cCC          := ""
Local cCampo       := ""
Local cAssunto     := "Integraçao Bomi" 
  
Local nPos         := 0     
Local nCampo       := 0 

Local cDestinatario:= Alltrim(GetMv( "MV_P_EMAIL"))+";"+Alltrim(GetMv( "MV_P_MAIL1"))  //"tiago.mendonca@hlb.com.br" 



	cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
 	cEmail += '<title>Nova pagina 1</title></head><body>'
  	cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
   	cEmail += 'Arquivo de integração gerado  </b></u></font></p>'   
   	    
   	//arquivo de entrada
   	If cTipo == "ENT"         
   	

   		//Tratamento para nome do arquivo
   		cCampo := cFile
	   	nCampo :=At("\ftp\2C\ENTRADA\",Alltrim(cCampo))
		While 0 < nCampo                          
  			cCampo:=Stuff(cCampo,nCampo,14,"")
  			nCampo:=At("\ftp\2C\ENTRADA\",Alltrim(cCampo))   
		EndDo 

   		cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cCampo+' disponivel no FTP' 
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Referente as notas de entrada: ' 
    
    //arquivo de saída    
    ElseIf cTipo == "SAI" 
    

		//Tratamento para nome do arquivo
   		cCampo := cFile
	   	nCampo :=At("\ftp\2C\SAIDA\",Alltrim(cCampo))
		While 0 < nCampo                          
  			cCampo:=Stuff(cCampo,nCampo,14,"")
  			nCampo:=At("\ftp\2C\SAIDA\",Alltrim(cCampo))   
		EndDo 
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cCampo+" disponivel no FTP"
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Composto pela(s) nota(s) de saída abaixo : ' 
    	cEmail += ' <Hr>'    
          
    //arquivo de remessa    
    ElseIf cTipo == "REM" 
    

		//Tratamento para nome do arquivo
   		cCampo := cFile
	   	nCampo :=At("\ftp\2C\REMESSA\",Alltrim(cCampo))
		While 0 < nCampo                          
  			cCampo:=Stuff(cCampo,nCampo,14,"")
  			nCampo:=At("\ftp\2C\REMESSA\",Alltrim(cCampo))   
		EndDo 
    
    	cEmail += '<p><font face="Courier New" size="2">Arquivos: '+cCampo+" disponivel no FTP"
    	cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>'    
    	cEmail += '<p><font face="Courier New" size="2">Composto pela(s) nota(s) de remessas abaixo : ' 
    	cEmail += ' <Hr>'    
   
   
    EndIf  
          
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
			
			cSubject:= " Arquivo de integracao Illumina disponivel "+cCampo     
			   

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
			cEmail += '<br>'
						  		    	           
		 	// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
		  	For j:=1 to Len(aItens)
		   		If (nPos:=aScan( aItens, { |x| alltrim(x[1]) == alltrim(aDados[i][1]+aDados[i][2])} )) > 0
		    		aItens[nPos][1] :="OK"
		   			cEmail += '		<td width="40"><font face="Courier New" size="2">'+aItens[nPos][5]+' : '+aItens[nPos][3]+' | Lote: '+aItens[nPos][4]+' QTD:'+Alltrim(str(aItens[nPos][6]))+'</font></td>'             
		   			cEmail += '<br>'  
		    	EndIf
		   	Next
		    	
		  	cEmail += '<br>' 
		   	cEmail += '<hr>'
		    cEmail += '<br>'  
		    cEmail += '<br>'  
		    	
		    
			
		ElseIf cTipo == "PED"    
		     
			// aDados - 1.Pedido,2.Cliente,3.Loja,4.Nota,5.Serie
			SA1->(DbSetOrder(1))
   			If SA1->(DbSeek(xFilial("SA1")+aDados[i][2]+aDados[i][3]))
      			cNome:=SA1->A1_NOME
         	EndIf  
         	

   			cSubject:= " Arquivo de integracao Illumina disponivel "+cSC5Tit+" / "+cSC6Tit      

			cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">Nota: '+aDados[i][4]+'</font></td>'
   			cEmail += '		<td width="40"><font face="Courier New" size="2">Pedido: '+aDados[i][1]+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">Cliente: '+aDados[i][2]+" "+Alltrim(cNome)+'</font></td>'
			cEmail += '	</tr>'
			cEmail += '<br>'     
			
		ElseIf cTipo == "SAI" .Or.  cTipo == "REM"     
		
			// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE  
			SA1->(DbSetOrder(1))
   			If SA1->(DbSeek(xFilial("SA1")+aDados[i][2]+aDados[i][3]))
      			cNome:=SA1->A1_NOME
         	EndIf                                   
         	
         	cSubject:= " Arquivo de integracao Illumina disponivel "+cCampo   
         	
         	If aDados[i][1] <> cNf
		   		
		   		cEmail += '	<tr>'
   				cEmail += '		<td width="40"><font face="Courier New" size="2">Nota Saida: '+aDados[i][4]+'</font></td>'
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Serie: '+aDados[i][5]+'</font></td>'        
		   		cEmail += '		<td width="113"><font face="Courier New" size="2">Pedido: '+aDados[i][1]+'</font></td>'
		   		cEmail += '		<td width="378"><font face="Courier New" size="2">Cliente: '+aDados[i][2]+" "+Alltrim(cNome)+'</font></td>'  
		   		cEmail += '	</tr>'
				cEmail += '<br>'  
				cEmail += '<br>'
						  		    	           
		    	// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
		    	For j:=1 to Len(aItens)
		    		If (nPos:=aScan( aItens, { |x| alltrim(x[1]) == alltrim(aDados[i][4]+aDados[i][5])} )) > 0
		    			aItens[nPos][1] :="OK"
		    			If Alltrim(aItens[nPos][5]) ==  "KIT"
		    				cEmail += '<br>'  
		       				cEmail += '<br>'
		    				cEmail += '	<td width="40"><font face="Courier New" size="2">'+aItens[nPos][5]+' : '+aItens[nPos][3]+' QTD:'+Alltrim(str(aItens[nPos][6]))+'</font></td>'   
 		    			Else	
		    				cEmail += '		<td width="40"><font face="Courier New" size="2">'+aItens[nPos][5]+' : '+aItens[nPos][3]+' | Lote: '+aItens[nPos][4]+' QTD:'+Alltrim(str(aItens[nPos][6]))+'</font></td>'             
		       			EndIF
		    			cEmail += '<br>'  
		    		EndIf
		    	Next
		    	
		  		cEmail += '<br>' 
		    	cEmail += '<hr>'
		    	cEmail += '<br>'  
		    	cEmail += '<br>'  
		    	
		    	cNf:=aDados[i][1] 
		    	
		    EndIf                  
		    
		EndIf	
   
	Next  
			
    cEmail += '<br>'   
    cEmail += '<br>'            	
          	 
    cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
    cEmail += '<p align="center">www.grantthornton.com.br</p>'
    cEmail += '</body></html>'    
    
    

    oEmail          :=  DEmail():New()
    //oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
  	//oEmail:cTo		:=  "tiago.mendonca@hlb.com.br" //;noeli.schinaider@hlb.com.br"    
	oEmail:cTo		:=  cDestinatario // AllTrim(GetMv("MV_P_EMAIL"))  
    oEmail:cSubject	:=	cSubject
    oEmail:cBody   	:= 	cEmail
    oEmail:cAnexos  :=  cFile
    oEmail:Envia()
    

  	//FErase(cFile)     

Return 



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
*-----------------------------------*
   Static Function MarcaTds(PAlias)
*-----------------------------------* 
   
	DbSelectArea(PAlias)   
 	(PAlias)->(DbGoTop())  
  	While (PAlias)->(!EOF())
    	RecLock(PAlias,.F.)     
     	If (PAlias)->cINTEGRA == cMarca     		
      		(PAlias)->cINTEGRA:=Space(02)         		
        Else
       		(PAlias)->cINTEGRA:= cMarca       
        EndIf 

         (PAlias)->(MsUnlock())
         (PAlias)->(DbSkip())
    EndDo      
    
    (PAlias)->(DbGoTop())      
      
Return  


//Reenvia email
*-----------------------------------*
   Static Function EnviaEmail(cAlias)
*-----------------------------------* 
  
Local aButtons    := {}
Local aSaiEmail   := {} 
Local aEntEmail   := {} 
Local aItensEmail := {}


Local oFont14  := TFont():New('Courier new',,-14,.T.)

Local lDados   :=.F.  

Local cNomeArq := ""
Local cNome    := ""
Local cAux     := ""   

Local oDlgE    

Private nOpc     := 2 
   
Private cMark    := GetMark() 
                    
Private aCp      := {}
Private aStruSF  := {} 
Private lInv     := .f.

If cAlias =="TempSF2"

	If Select("EmailSF2") > 0
		EmailSF2->(DbCloseArea())	               
	EndIf  
	 
	//Campos do MarkBrowse
	Aadd(aCp, {"cINTEGRA"       ,"",                  })  
	Aadd(aCp, {"C5_P_ARQ"       ,"", "Arquivo",       })
	Aadd(aCp, {"F2_DOC"         ,"", "Nota Fiscal",   })
	Aadd(aCp, {"F2_SERIE"       ,"", "Serie Fiscal",  })
	Aadd(aCp, {"F2_CLIENTE" 	,"", "Cod.Cliente",   })
	Aadd(aCp, {"F2_LOJA"        ,"", "Loja",          })   
	Aadd(aCp, {"F2_EMISSAO"     ,"", "Emissao",       })
	Aadd(aCp, {"F2_VALBRUT"     ,"", "Valor da NF",   })		
	                 
	// Arquivo Temporario  
	Aadd(aStruSF, {"F2_FILIAL"   ,AvSx3("F2_FILIAL" ,2),AvSx3("F2_FILIAL" ,3),AvSx3("F2_FILIAL" ,4)})
	Aadd(aStruSF, {"C5_P_ARQ"    ,AvSx3("C5_P_ARQ",2) ,AvSx3("C5_P_ARQ",3)   ,AvSx3("C5_P_ARQ"  ,4)})
	Aadd(aStruSF, {"cINTEGRA"    ,"C"                  ,2                    ,0                    })
	Aadd(aStruSF, {"F2_DOC"      ,AvSx3("F2_DOC"    ,2),AvSx3("F2_DOC"    ,3),AvSx3("F2_DOC"    ,4)})
	Aadd(aStruSF, {"F2_SERIE"    ,AvSx3("F2_SERIE"  ,2),AvSx3("F2_SERIE"  ,3),AvSx3("F2_SERIE"  ,4)})  
	Aadd(aStruSF, {"F2_CLIENTE"  ,AvSx3("F2_CLIENTE",2),AvSx3("F2_CLIENTE",3),AvSx3("F2_CLIENTE",4)})
	Aadd(aStruSF, {"F2_TIPO"     ,AvSx3("F2_TIPO",2)   ,AvSx3("F2_TIPO",3)   ,AvSx3("F2_TIPO",4   )})
	Aadd(aStruSF, {"F2_LOJA"     ,AvSx3("F2_LOJA"   ,2),AvSx3("F2_LOJA"   ,3),AvSx3("F2_LOJA"   ,4)})
	Aadd(aStruSF, {"F2_EMISSAO"  ,AvSx3("F2_EMISSAO",2),AvSx3("F2_EMISSAO",3),AvSx3("F2_EMISSAO",4)})
	Aadd(aStruSF, {"F2_VALBRUT"  ,AvSx3("F2_VALBRUT",2),AvSx3("F2_VALBRUT",3),AvSx3("F2_VALBRUT",4)})
	
	cNome := CriaTrab(aStruSF, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'EmailSF2',.F.,.F.)       
	IndRegua("EmailSF2", cNome, "F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA",,.T.,"Indexando tabela temporária...")
	  	
	cQuery := " SELECT *" + Chr(13)
	cQuery += " FROM " + RetSqlName("SC5") + " where "  + Chr(13)
	cQuery += "  C5_P_ARQ <> '' AND C5_P_GER = 'S'  AND D_E_L_E_T_ <> '*' "  + Chr(13)
	cQuery += " ORDER BY  C5_EMISSAO DESC "  + Chr(13)

	If Select("SFTemp") > 0
		SFTemp->(dbCloseArea())
	Endif
	
 	//Cria Alias
	TCQuery cQuery ALIAS "SFTemp" NEW 
	
	TcSetField("SFTemp","C5_EMISSAO","D",08,00)
	                                 
	SFTemp->(DbGoTop())
	If !(SFTemp->(!BOF() .and. !EOF()))
	   	MsgStop("Não encontradro notas para reenviar email","Illumina")
		Return .F.
	EndIf
    	
	While SFTemp->(!EOF())    

		RecLock("EmailSF2",.T.)
		EmailSF2->F2_FILIAL  := SFTemp->C5_FILIAL            
		EmailSF2->F2_DOC     := SFTemp->C5_NOTA
		EmailSF2->F2_SERIE   := SFTemp->C5_SERIE
		EmailSF2->F2_CLIENTE := SFTemp->C5_CLIENTE
		EmailSF2->F2_LOJA    := SFTemp->C5_LOJACLI   	
		EmailSF2->F2_EMISSAO := SFTemp->C5_EMISSAO
		EmailSF2->C5_P_ARQ   := SFTemp->C5_P_ARQ 
		EmailSF2->(MsUnlock())
	
	    SFTemp->(DbSkip())
   
	EndDo    
    
    
	EmailSF2->(DbGoTop())
	If EmailSF2->(!BOF() .and. !EOF())
	    
	   	DEFINE MSDIALOG oDlgE TITLE "Reenvia email de nota de saida ?" FROM 000,000 TO 545,1100 PIXEL
	                      
	        @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
	        @ 026 , 015 Say  "SELECIONE SOMENTE AS NOTAS FISCAIS DE SAIDA QUE DEVE GERAR EMAIL" COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,8 Font oFont14 OF oDlgE           
	                        
	        oTMsgBar := TMsgBar():New(oDlgE,"GERAÇÃO DE EMAIL",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont14,.F.)   
	        oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
	        oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
	    	oMarkPrd:= MsSelect():New("EmailSF2","cINTEGRA",,aCp,@lInv,@cMark,{50,6,247,545},,,oDlgE,,)   
	     	   
		ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE,{||nOpc:=1,oDlgE:End()},{|| (nOpc:=2,oDlgE:End())},,aButtons) CENTERED
	    	
	Else
	   	MsgInfo("Nenhum dado encontrado para geração de email","Illumina")
	   	Return .F.   
	EndIf
	
	if nOpc == 1
		
		EmailSF2->(DbGoTop())                
		Do While EmailSF2->(!EoF())   

	    	EmailSF2->(DbSeek(EmailSF2->F2_DOC+EmailSF2->F2_SERIE+EmailSF2->F2_CLIENTE+EmailSF2->F2_LOJA))
	    	If EmailSF2->cIntegra == cMark
		    	       
	    		SC6->(DbSetOrder(4))
	    		SC6->(DbSeek(xFilial("SC6")+EmailSF2->F2_DOC+EmailSF2->F2_SERIE))
	    	    
	    	    Do While (SC6->C6_NOTA == EmailSF2->F2_DOC  .And. SC6->C6_SERIE==EmailSF2->F2_SERIE .And. SC6->C6_FILIAL == EmailSF2->F2_FILIAL )
	    	                
	    		    // aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
	    			Aadd(aItensEmail,{EmailSF2->F2_DOC+EmailSF2->F2_SERIE,SC6->C6_NUM,SC6->C6_PRODUTO,"Não possui","KIT",SC6->C6_QTDVEN})  
	    	
	    	   		SD3->(DbSetOrder(1))
	    	   		SD3->(DbSeek(xFilial("SD3")+SC6->C6_P_OP+SC6->C6_PRODUTO))	    		
		    		
		    		Do While SD3->D3_FILIAL == EmailSF2->F2_FILIAL .and. SD3->D3_OP == SC6->C6_P_OP 
		    		     
		    		    If SD3->D3_CF == "PR0" .OR. SD3->D3_ESTORNO ==  'S'   
		    		    	SD3->(DbSkip())	
		    		    	Loop 
		    		    EndIf
		    		         
						// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE  
		    			Aadd(aSAIEmail,{SC6->C6_NUM,EmailSF2->F2_CLIENTE,EmailSF2->F2_LOJA,EmailSF2->F2_DOC,EmailSF2->F2_SERIE,})  
		 
						Aadd(aItensEmail,{EmailSF2->F2_DOC+EmailSF2->F2_SERIE,SC6->C6_NUM,SD3->D3_COD,SD3->D3_LOTECTL,"Componente",SD3->D3_QUANT})   	
		   			
	        		  	SD3->(DbSkip())   
	        		  	
		        	Enddo
		        
		        
	        		SC6->(DbSkip())
		        Enddo
			          
		    	If alltrim(EmailSF2->C5_P_ARQ) <> alltrim(cAux)  
		    		cAux:=EmailSF2->C5_P_ARQ
					cNomeArq+= "\ftp\2C\SAIDA\"+substr(Alltrim(EmailSF2->C5_P_ARQ),1,12)+" ; "+"\ftp\2C\SAIDA\"+substr(Alltrim(EmailSF2->C5_P_ARQ),14,12)
				EndIf		
			
			Endif      
		    
		
	        EmailSF2->(DbSkip())  
	        
	    EndDo
    	          
    	EMail(aSAIEmail,"SAI",cNomeArq,aItensEmail)  
    	
		lConnect:=ConectaFTP()
		            
		If lConnect                                       
			
			FTPDirChange(cDir)  // Monta o diretório do FTP, será gravado na raiz "/"
			 
			For i=1 to Len(aArqs)	
				// Grava Arquivo no FTP
			 	If FTPUpLoad(cDir+alltrim(aArqs[i]),alltrim(aArqs[i]))
			     	Conout("Arquivo "+alltrim(aArqs[i])+" gerado com sucesso no FTP interno.")   		
				Else 
		 	 	   Conout("O Arquivo "+alltrim(aArqs[i])+" não pode ser gravado no FTP interno") 
				EndIf  
			Next	
			
		EndIf
			 
		FTPDisconnect()   
		
    	
	
	EndIf	

Else

	If Select("EmailSF1") > 0
		EmailSF1->(DbCloseArea())	               
	EndIf  
	 
	//Campos do MarkBrowse
	Aadd(aCp, {"cINTEGRA"       ,"",                  })  
	Aadd(aCp, {"F1_P_ARQ"       ,"", "Arquivo",   })
	Aadd(aCp, {"F1_DOC"         ,"", "Nota Fiscal",   })
	Aadd(aCp, {"F1_SERIE"       ,"", "Serie Fiscal",  })
	Aadd(aCp, {"F1_FORNECE" 	,"", "Cod.Fornecedor",})
	Aadd(aCp, {"F1_LOJA"        ,"", "Loja",          })   
	Aadd(aCp, {"F1_EMISSAO"     ,"", "Emissao",       })
	Aadd(aCp, {"F1_VALBRUT"     ,"", "Valor da NF",   })		
	                 
	// Arquivo Temporario  
	Aadd(aStruSF, {"F1_FILIAL"   ,AvSx3("F1_FILIAL" ,2),AvSx3("F1_FILIAL" ,3),AvSx3("F1_FILIAL" ,4)})
	Aadd(aStruSF, {"F1_P_ARQ"    ,AvSx3("F1_P_ARQ",2) ,AvSx3("F1_P_ARQ",3)   ,AvSx3("F1_P_ARQ"  ,4)})
	Aadd(aStruSF, {"cINTEGRA"    ,"C"                  ,2                    ,0                    })
	Aadd(aStruSF, {"F1_DOC"      ,AvSx3("F1_DOC"    ,2),AvSx3("F2_DOC"    ,3),AvSx3("F1_DOC"    ,4)})
	Aadd(aStruSF, {"F1_SERIE"    ,AvSx3("F1_SERIE"  ,2),AvSx3("F1_SERIE"  ,3),AvSx3("F1_SERIE"  ,4)})  
	Aadd(aStruSF, {"F1_FORNECE"  ,AvSx3("F1_FORNECE",2),AvSx3("F1_FORNECE",3),AvSx3("F1_FORNECE",4)})
	Aadd(aStruSF, {"F1_TIPO"     ,AvSx3("F1_TIPO",2)   ,AvSx3("F1_TIPO",3)   ,AvSx3("F1_TIPO",4   )})
	Aadd(aStruSF, {"F1_LOJA"     ,AvSx3("F1_LOJA"   ,2),AvSx3("F1_LOJA"   ,3),AvSx3("F1_LOJA"   ,4)})
	Aadd(aStruSF, {"F1_EMISSAO"  ,AvSx3("F1_EMISSAO",2),AvSx3("F1_EMISSAO",3),AvSx3("F1_EMISSAO",4)})
	Aadd(aStruSF, {"F1_VALBRUT"  ,AvSx3("F1_VALBRUT",2),AvSx3("F1_VALBRUT",3),AvSx3("F1_VALBRUT",4)})
	
	cNome := CriaTrab(aStruSF, .T.)                   
	DbUseArea(.T.,"DBFCDX",cNome,'EmailSF1',.F.,.F.)       
	IndRegua("EmailSF1", cNome, "F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA",,.T.,"Indexando tabela temporária...")
	  	
	cQuery := " SELECT *" + Chr(13)
	cQuery += " FROM " + RetSqlName("SF1") + " where "  + Chr(13)
	cQuery += "  F1_P_ARQ <> '' AND F1_P_GER = 'S'  AND D_E_L_E_T_ <> '*' "  + Chr(13)
	cQuery += " ORDER BY  F1_EMISSAO DESC "  + Chr(13)

	If Select("SFTemp") > 0
		SFTemp->(dbCloseArea())
	Endif
	
	//Cria Alias
	TCQuery cQuery ALIAS "SFTemp" NEW 
	
	TcSetField("SFTemp","F1_EMISSAO","D",08,00)
	                                 
	SFTemp->(DbGoTop())
	If !(SFTemp->(!BOF() .and. !EOF()))
	   	MsgStop("Não encontradro notas para reenviar email","Illumina")
		Return .F.
	EndIf
    	
	While SFTemp->(!EOF())    

		RecLock("EmailSF1",.T.)
		EmailSF1->F1_FILIAL  := SFTemp->F1_FILIAL            
		EmailSF1->F1_DOC     := SFTemp->F1_DOC
		EmailSF1->F1_SERIE   := SFTemp->F1_SERIE
		EmailSF1->F1_FORNECE := SFTemp->F1_FORNECE
		EmailSF1->F1_LOJA    := SFTemp->F1_LOJA   	
		EmailSF1->F1_EMISSAO := SFTemp->F1_EMISSAO
		EmailSF1->F1_VALBRUT := SFTemp->F1_VALBRUT
		EmailSF1->F1_P_ARQ   := SFTemp->F1_P_ARQ 
		EmailSF1->(MsUnlock())
	
	    SFTemp->(DbSkip())
   
	EndDo    
    
    
	EmailSF1->(DbGoTop())
	If EmailSF1->(!BOF() .and. !EOF())
	    
	   	DEFINE MSDIALOG oDlgE TITLE "Reenvia email de nota de saida ?" FROM 000,000 TO 545,1100 PIXEL
	                      
	        @ 017 , 006 TO 045,540 LABEL "" OF oDlg PIXEL 
	        @ 026 , 015 Say  "SELECIONE SOMENTE AS NOTAS FISCAIS DE ENTRADA QUE DEVE GERAR EMAIL" COLOR CLR_HBLUE, CLR_WHITE      PIXEL SIZE 500,8 Font oFont14 OF oDlgE           
	                        
	        oTMsgBar := TMsgBar():New(oDlgE,"GERAÇÃO DE EMAIL",.F.,.F.,.F.,.F., RGB(116,116,116),,oFont14,.F.)   
	        oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
	        oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})
	    	oMarkPrd:= MsSelect():New("EmailSF1","cINTEGRA",,aCp,@lInv,@cMark,{50,6,247,545},,,oDlgE,,)   
	     	   
		ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE,{||nOpc:=1,oDlgE:End()},{|| (nOpc:=2,oDlgE:End())},,aButtons) CENTERED
	    	
	Else
	   	MsgInfo("Nenhum dado encontrado para geração de email","Illumina")
	   	Return .F.   
	EndIf
	
	if nOpc == 1
		
		EmailSF1->(DbGoTop())                
		Do While EmailSF1->(!EoF())   

	    	EmailSF1->(DbSeek(EmailSF1->F1_DOC+EmailSF1->F1_SERIE+EmailSF1->F1_FORNECE+EmailSF1->F1_LOJA))
	    	
	    	If EmailSF1->cIntegra == cMark
				
				Aadd(aEntEmail,{EmailSF1->F1_DOC,EmailSF1->F1_SERIE,EmailSF1->F1_FORNECE,EmailSF1->F1_LOJA,EmailSF1->F1_TIPO})  
	    	     
	   	    	cChave:=EmailSF1->F1_DOC+EmailSF1->F1_SERIE+EmailSF1->F1_FORNECE+EmailSF1->F1_LOJA
	    	    
	    	    SD1->(DbSeek(xFilial("SD1")+cChave))	
	        
	        	Do While SD1->D1_FILIAL = EmailSF1->F1_FILIAL .and. SD1->D1_DOC = EmailSF1->F1_DOC .and. SD1->D1_SERIE = EmailSF1->F1_SERIE .and.;
	            	     SD1->D1_FORNECE = EmailSF1->F1_FORNECE .and. SD1->D1_LOJA = EmailSF1->F1_LOJA
	                 
	        		
	        		// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
	    			Aadd(aItensEmail,{EmailSF1->F1_DOC+EmailSF1->F1_SERIE,SD1->D1_CONHEC,SD1->D1_COD,SD1->D1_LOTECTL,"Componente",SD1->D1_QUANT})  
	        		
	        		SD1->(DbSkip())
	        	
	        	Enddo
			    	       		
						          
		    	If alltrim(EmailSF1->F1_P_ARQ) <> alltrim(cAux)  
		    		cAux:=EmailSF1->F1_P_ARQ 
					cNomeArq+= "\ftp\2C\ENTRADA\"+substr(Alltrim(EmailSF1->F1_P_ARQ),1,12)+" ; "+"\ftp\2C\ENTRADA\"+substr(Alltrim(EmailSF1->F1_P_ARQ),14,12)
				EndIf		
			
			EndIf
				
	        EmailSF1->(DbSkip())  
	        
	    EndDo
    	          
    	EMail(aEntEmail,"ENT",cNomeArq,aItensEmail)  
	
	EndIf	

   
EndIf  
      
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

/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para conectar no FTP
Autor     	: Tiago Luiz Mendonça
Data     	: 24/04/2013 
Obs         :
*/   

*-----------------------------*
 Static Function ConectaFTP()
*-----------------------------*

Local cPath 	:= GETMV("MV_P_FTP") // "200.196.242.81"
Local clogin	:= GETMV("MV_P_USR") // "tiago"
Local cPass 	:= GETMV("MV_P_PSW") // "123" 
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)  


//Gera arquivo de REMESSA
*-------------------------*
 Static Function GENFAT03()
*-------------------------*   

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
	 	
	//Nome do arquivo baseado na data + letra     
	cNum := NomeArq(cNum,"SAI")    
	  
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
        		If SF4->F4_ESTOQUE <> "N"  .And. SF4->F4_PODER3 <> "R"
          			C9QRY->(DbSkip())
         			loop
            	EndIf
        	EndIf
                 
        	//Notas transmitidas não devem ser mostradas.                                                                                                  
            /*
            SF2->(DbSetOrder(1))
            If SF2->(DbSeek(xFilial("SF2")+C9QRY->C9_NFISCAL+C9QRY->C9_SERIENF+C9QRY->C9_CLIENTE+C9QRY->C9_LOJA))
            	If !Empty(SF2->F2_CHVNFE)
            		C9QRY->(DbSkip())
         			loop                
            	EndIf
            
            EndIf
            */  
                        
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


	aadd(aButtons,{"PENDENTE",{|| MarcaTds("TempSF2")},"Marca ","Marca ",{|| .T.}})
	aadd(aButtons,{"BMPPOST",{|| EnviaEmail("TempSF2")},"Reenvia Email","Reenvia Email",{|| .T.}})

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
     	   
     	 ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lRet:=GeraRem(cNum),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED    	
    	
    Else
    	MsgInfo("Nenhum dado encontrado para geração do arquivo","Promega")
    	Return .F.   
    EndIf  

Return 


//Gera o arquivo de Remessa    
*-----------------------------*    
  Static Function GeraRem(cNum)    
*-----------------------------*    
        
Local lRet:=lBloq:=lMarcado:=.T. 
Local cSC5Txt,cSC6Txt
Local nSC5Hdl,nSC6Hdl
Local aPed      :={}
Local aItens    :={}
Local cEOL  	:= "CHR(13)+CHR(10)" 
Local cDir  	:= "\ftp\2C\REMESSA\"    
Local cPath 	:= AllTrim(GetTempPath()) 
Local cData 	:= DTOS(Date())   
Local cContato	:="" 
Local cNumAux   :=""
Local n         :=1  

Private cSC5Tit,cSC6Tit     

SET DATE FORMAT "dd/mm/yyyy"
         
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
	
		If !(MsgYesNo("Deseja realmente gerar o arquivo de REMESSA"))
			Return .F.
		Endif
		 
		//Alexandre Caetano -  02 de Outubro de 2012
		//Montagem do arquivo de integração
	
		// Cabeçalho
		cSC5Txt:=cDir+"RHB"+cNum+".TXT"
		cSC5Tit:="RHB"+cNum+".TXT"

		aAdd(aArqs,cSC5Tit)
			      
		nSC5Hdl:= fCreate(cSC5Txt)
	
		If nSC5Hdl == -1 // Testa se o arquivo foi gerado
			MsgAlert("O arquivo "+cSC5Txt+" nao pode ser executado!","Atenção")
		EndIf          
       			                 		
		TempSC9->(DbGoTop()) 
		While TempSC9->(!EOF())   

			If Alltrim(TempSC9->cStatus)== "Liberado"  .And. !Empty(Alltrim(TempSC9->cINTEGRA)) .And. cNumAux <> TempSC9->C9_PEDIDO
		    	    	
    	   	    cNumAux:=TempSC9->C9_PEDIDO
       	             
    	    	// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE    
    	    	Aadd(aPed,{TempSC9->C9_PEDIDO,TempSC9->C9_CLIENTE,TempSC9->C9_LOJA,TempSC9->C9_NFISCAL,TempSC9->C9_SERIENF})  
    	           
    			SC5->(DbSetOrder(1))
    			If SC5->(DbSeek(xFilial("SC5")+TempSC9->C9_PEDIDO))
    	
	    			//119                     
		       		nTamLin   := 129
	       	   		cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	 
         	   		//   Cabeçalho                -----------       Comentários
	        
	          		cCab  := Stuff(cCab,01,03,"ILU")               				   		// Fixo com "ILU"  
	          		cCab  := Stuff(cCab,04,03,"TRB")     
	            	cCab  := Stuff(cCab,07,10,Alltrim(Str(Val(TempSC9->C9_NFISCAL))))  	// Número da NF de entrada  
	           		cCab  := Stuff(cCab,17,04,"VEN")              						// Fixo VEN 
	        		cCab  := Stuff(cCab,21,02,TempSC9->C9_SERIENF)           			// Serie da nota
	           		cCab  := Stuff(cCab,23,06,space(6))              					// Origem da mercadoria
	           		cCab  := Stuff(cCab,29,30,space(30))              					// Descrição da Origem 
	       			cCab  := Stuff(cCab,59,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
	       			cCab  := Stuff(cCab,69,10,SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,4))    // Data do Pedido 
	       			cCab  := Stuff(cCab,79,30,space(30))       			 				// Fonte de recebimento
	       	   		cCab  := Stuff(cCab,109,01,"E")              						// Fonte de recebimento
	       	   		cCab  := Stuff(cCab,110,06,"000000")             					// Hota
	       	   		cCab  := Stuff(cCab,116,03,"REC")              						//Código de Area de recebimento BOMI
	           		cCab  := Stuff(cCab,119,10,space(10))+cEOL              			// Transportadora
	        
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
    	
	    cSC6Txt:=cDir+"RIB"+cNum+".TXT"
	    cSC6Tit:="RIB"+cNum+".TXT"  	
	    
	    nSC6Hdl:= fCreate(cSC6Txt)
		If nSC6Hdl == -1 // Testa se o arquivo foi gerado
	    	MsgAlert("O arquivo "+cSC6Txt+" nao pode ser executado!","Atenção")
	    	Return .F.
	    EndIf
	     
	    n:=1 
	               		  
    	TempSC9->(DbGoTop()) 
    	cNumAux:=TempSC9->C9_PEDIDO
		While TempSC9->(!EOF())   
		
  			If Alltrim(TempSC9->cStatus)== "Liberado"  .And. !Empty(Alltrim(TempSC9->cINTEGRA))

	  			SC6->(DbGoTop(2))
	  			If SC6->(DbSeek(xFilial("SC6")+TempSC9->C9_PEDIDO+TempSC9->C9_ITEM))

	        		// aItens 1.DOC+SERIE,2.PEDIDO,3.PRODUTO,4.LOTE,5.DESC,6.QTD  
	    			Aadd(aItens,{TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF,"",SC6->C6_PRODUTO,SC6->C6_P_LOTE,"Componente",SC6->C6_QTDVEN})  

	        		
	        		lDados:=.T.
	                                      	       		
	     			nTamLin   := 115
	        		cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
	 
	          		//   ITENS               -----------       Comentários
	        
	           		cCab  := Stuff(cCab,01,03,"ILU")               // Fixo com "ILU"
	          		cCab  := Stuff(cCab,04,03,"TRB")   	                         
	                
	        		cCab  := Stuff(cCab,07,10,Alltrim(Str(Val(TempSC9->C9_NFISCAL))))                    // Número da NF de entrada  
	        		cCab  := Stuff(cCab,17,04,strzero(n,4))              	              	    // Fixo VEN 
	        		cCab  := Stuff(cCab,21,15,Replicate(" ",15-Len(SC6->C6_PRODUTO))+SC6->C6_PRODUTO)   //Codigo do produto
	        		cCab  := Stuff(cCab,36,10,"0"+ClearVal(strzero(ROUND(SC6->C6_PRCVEN,2),10,2)))        // Valor unitario
	           		cCab  := Stuff(cCab,46,9,ClearVal(strzero(SC6->C6_QTDVEN,9,0)))              // Quantidade
	        		cCab  := Stuff(cCab,55,01,"E")                           					// Fonte de recebimento  
	        		SB1->(DbSetOrder(1))
	        		If SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))   
	        			cCab  := Stuff(cCab,56,30,SubStr(Alltrim(SB1->B1_DESC),1,30))     		// Descrição do item
	        		EndIf	
	             		
	        		cCab  := Stuff(cCab,86,15,SC6->C6_P_LOTE+"     ")   // Lote 
	        		//If SD2->(DbSeeK(xFilial("SD2")+TempSC9->C9_NFISCAL+TempSC9->C9_SERIENF+TempSC9->C9_CLIENTE+TempSC9->C9_LOJA ))   
	        		If !Empty(SC6->C6_P_LOTE)
	        			SB8->(DbSetOrder(6)) 
	        			If SB8->(DbSeek(xFilial("SB8")+SC6->C6_P_LOTE))
							cCab  := Stuff(cCab,101,10,SubStr(DtoC(SB8->B8_DTVALID),7,4)+"-"+substr(DtoC(SB8->B8_DTVALID),4,2)+"-"+SubStr(DtoC(SB8->B8_DTVALID),1,2))                    // Data do pedido
						Else
							cCab  := Stuff(cCab,101,10,space(10)) 	
						EndIf
					Else						
	          			cCab  := Stuff(cCab,101,10,space(10)) 
	          		EndIF
	          		cCab  := Stuff(cCab,111,03,"LIB")+cEOL               		//FIXO "LIB"
	          			
		   			If fWrite(nSC6Hdl,cCab,Len(cCab)) != (Len(cCab))
	  					If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Itens (cCab). ","Atencao!")
	     		   			Return .F. 
	        			Endif 
	           		EndIf 
	           		
	           		n++
	                
	        	EndIf         
	            	
	   		Endif
	
			TempSC9->(DbSkip())
		
		Enddo  
	
		aAdd(aArqs,cSC5Tit)
		aAdd(aArqs,cSC6Tit)
		
		fClose(nSC5Hdl) 
		fClose(nSC6Hdl)  
		
                    
  		TempSC9->(dbCloseArea())  
          	        
    	// Atualiza SC5        	
     	For i:=1 to Len(aPed)
         		  
      		// aPed 1.NUM,2.CLIENTE,3.LOJA,4.NOTA,5.SERIE    	  
         		         		
         	SC5->(DbGoTop())  
         	SC5->(DbSetOrder(1))
         	If SC5->(DbSeek(xFilial("SC5")+aPed[i][1]))	
          		RecLock("SC5",.F.) 
             	SC5->C5_P_GER :="S"
             	SC5->C5_P_ARQ  :=cSC5Tit+";"+cSC6Tit   
             	SC5->C5_P_OBS  := Alltrim( UsrFullName( __cUserID) ) + DtoS( Date() ) + Time()          	
               	SC5->(MsUnlock())
             	SC5->(DbSkip())                     
          	EndIf 
            
 		Next
 		
    	// Atualiza SC9
   		For i:=1 to Len(aPed)
     
                                                                                                                              
            SC9->(DbGoTop())    
            SC9->(DbSetOrder(1))  //C9_FILIAL+C9_PEDIDO                                                                                                                                
            If SC9->(DbSeek(xFilial("SC9")+aPed[i][1]))	
            	
            	While SC9->(!EOF()) .And. SC9->C9_PEDIDO == aPed[i][1]
	           
	            	RecLock("SC9",.F.) 
	            	SC9->C9_P_GER  :="S"          	
	            	SC9->(MsUnlock()) 	
                	
                	SC9->(DbSkip())
               
               	EndDo	                          
             
            EndIf                      
                	
      	Next
              		
       	If SX5->(DbSeek(xFilial("SX5")+"ZZ"+"SAI")) 
	        RecLock("SX5",.F.)  
	        SX5->X5_DESCRI:=cNum
	        SX5->(MsUnlock())    
        EndIf
         	
        
        MsgInfo("Arquivos gerados com sucesso.","Illumina")    
          
		EMail(aPed,"REM",cSC5Txt+";"+cSC6Txt,aItens)  
		
		
		lConnect:=ConectaFTP()
            
		If lConnect                                       
			
			FTPDirChange(cDir)  // Monta o diretório do FTP, será gravado na raiz "/"
			 
			For i=1 to Len(aArqs)	
				// Grava Arquivo no FTP
			 	If FTPUpLoad(cDir+alltrim(aArqs[i]),alltrim(aArqs[i]))
			     	Conout("Arquivo "+alltrim(aArqs[i])+" gerado com sucesso no FTP interno.")   		
				Else 
		 	 	   Conout("O Arquivo "+alltrim(aArqs[i])+" não pode ser gravado no FTP interno") 
				EndIf  
			Next	
			
		EndIf
			 
		FTPDisconnect()  
           
    Else
    	MsgStop("Existem itens não marcardos ou itens bloqueados que estão marcados, verificar.","Promega")  
    	TempSC9->(DbGoTop())
    	lRet:=.F.
    EndIf
              

End Sequence
 
Return lRet      

 
 
