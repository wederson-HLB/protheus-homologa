#Include "topconn.ch"                    
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#include "fileio.ch"  
#include "protheus.ch"
#include "intveraz.ch"  
                                                                        	
/*
Funcao      : INTVERAZ
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração de arquivos       
Autor     	: Tiago Luiz Mendonça
Data     	: 08/09/2009
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*--------------------------*
  User Function IntVeraz() 
*--------------------------*                             

Local Odlg
Private oMain, oCbx, nSelec ,cArq
Private lCLIENT:=lPRODUT:=lNFENTR:=lPEDIDO:=lAut:=.F.                                                                            
Private aItensP:={STR001,STR002,STR003,STR004,STR005,STR006}    
Private cArquivo := "C:\"+Space(50)   
Private lRet:=.T.
Private aButtons:={}  
Private cMarca := GetMark() 


   If !(cEmpAnt $ "KX/XC")
      MsgInfo("Especifico Veraz"," A T E N C A O ")      
      Return .F.
   Endif                                                                          

   aadd(aButtons,{STR007,{|| Ordena()}  ,STR008,STR008,{|| .T.}})              
   aadd(aButtons,{STR009,{|| MarcaTds()},STR010,STR010,{|| .T.}}) 

   DEFINE MSDIALOG oDlg TITLE STR011 From 1,7 To 22,70 OF oMain  

      nLin1:=010
      nLin2:=083
      nCol1:=040
      nCol2:=220      
   
      @ nLin1,nCol1 TO nLin2,nCol2 LABEL STR012 OF oDlg PIXEL     
   
      nLin:=040  
      nCol:=045
   
      @ nLin, nCol RADIO oCbx VAR nSelec ITEMS aItensP[5],aItensP[6] COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 170,200  OF oDlg                                                                                                               


      @ 086,040 TO 117,220  LABEL STR013 OF oDlg PIXEL  // Caixa do meio 
      @ 097,045 Get cArquivo Size 145,10 OF oDlg PIXEL 
      @ 098,192 BmpButton Type 14 Action LoadArq()
                                                              
      @ 120,040 TO 144,220  LABEL "" OF oDlg PIXEL  // Caixa do botao 
      @ 125,086 BUTTON STR014 size 40,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
      @ 125,130 BUTTON STR015 size 40,15 ACTION Processa({|| lRet:=ExistArq(),;
                                                                 If(lRet,lRet:=ProcTxt(),MsgAlert(STR016,STR017)),;
                                                                 If(lRet,oDlg:End(),"")}) of oDlg Pixel    

   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())         

Return .F.

// Carrega o arquivo
*------------------------------*
  Static Function LoadArq()
*-----------------------------*

Local nPos

cType    := "Arq.  | *.TXT"
cArquivo := Upper(cGetFile(cType, OemToAnsi(STR018+Subs(cType,1,6))))
                            
nPos:=At("\",Alltrim(cArquivo))   
cArq:=cArquivo
While 0 < nPos                          
   cArq:=SubStr(cArq,nPos+1,Len(alltrim(cArq)))
   nPos:=At("\",Alltrim(cArq))   
EndDo 


Return           

// Verifica se foi informado arquivo
*------------------------------*
  Static Function ExistArq()
*-----------------------------*        
  
If Len(Alltrim(cArquivo)) <= 3 
   lRet:=.F.
Else
   lRet:=.T.     
EndIf

Return lRet  

// Le o arquivo
*------------------------------*
  Static Function ProcTxt()
*------------------------------*
                                
Local aStruZX1:=aStruZX2:=aStruZX3:=aStruZX4:={}
Local oMarkPrd , cAliasSX3
Local lInverte:= lIncDoc:= .F.
Local aCpos := {}      
Local nCountAc:= nCountCapa:= nIncDoc:= nAux:= 0
Local nRecno:=nCountItens:= 1         
Local cComp:=cPedido := cAux:= ""        
Local cImg1:="D:\Protheus10\Rdmake\GT\LogoGT.bmp"  
Local Indice1,Indice2,cB1_TIPO
Local cBranco:= Space(174)                     

Private aSa1:=aSa2:={}
Private lInt:=.T.     
Private cTp,cConverte   


   If nSelec==1   
      nSelec:=5   //Romaneio de Entrada
   ElseIf nSelec==2
      nSelec:=6   //Romaneio de Saída
   EndIf   
      
   If nSelec==5  // Pre Nota Entrada
            
      If Select("INT_ZX1") > 0
         INT_ZX1->(DBCLoseArea())
      EndIf
      
      If Select("INT_ZX2") > 0
         INT_ZX2->(DBCLoseArea())
      EndIf    
  
      cAliasSX3 := "ZX1"
      DbSelectArea("SX3")
      DbSetOrder(1)   
      
      If __LANGUAGE="PORTUGUESE"
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"ZX1Status"  ,"","Status",}) 
         Aadd(aCpos, {"ZX1_TIPO"   ,"","Tipo da Nota",})
         Aadd(aCpos, {"ZX1_ORIGEM" ,"","Origem",})  
         Aadd(aCpos, {"ZX1_NUM"    ,"","Romaneio.",}) 
         Aadd(aCpos, {"QTD_ITENS"  ,"","Qtd de Itens"    ,})
         Aadd(aCpos, {"ZX1_DATA"   ,"","DT Romaneio",}) 
         Aadd(aCpos, {"ZX1_DT_INC" ,"","Data Inclusão",})
         Aadd(aCpos, {"ZX1_FORNEC" ,"","Cod. Fornec.",})
         Aadd(aCpos, {"ZX1_NOMEF"  ,"","Fornecedor",})
         Aadd(aCpos, {"ZX1_LOJA"   ,"","Loja Fornec.",})
         Aadd(aCpos, {"ZX1_MUN"    ,"","Cod. Municip.",})
         Aadd(aCpos, {"ZX1_ESTADO" ,"","Estado",})
         Aadd(aCpos, {"ZX1_TP_FOR" ,"","Tipo Fornc.",})
         Aadd(aCpos, {"ZX1_CNPJ"   ,"","CNPJ/CPF",})
         Aadd(aCpos, {"ZX1_INSC_E" ,"","Inscr. Est.",})
         Aadd(aCpos, {"ZX1_LOG_I"  ,"","User",})
         Aadd(aCpos, {"ZX1_ARQUIV" ,"","Arquivo",} )
         Aadd(aCpos, {"LOG_INT"    ,"","Problema"        ,})		
      Else
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"ZX1Status"  ,"","Status",}) 
         Aadd(aCpos, {"ZX1_TIPO"   ,"","Tipo da Nota",})
         Aadd(aCpos, {"ZX1_ORIGEM" ,"","Origem",}) 
         Aadd(aCpos, {"ZX1_NUM"    ,"","Romaneio",})  
         Aadd(aCpos, {"QTD_ITENS"  ,"","Qtd de Itens"    ,})
         Aadd(aCpos, {"ZX1_DATA"   ,"","DT Romaneio",}) 
         Aadd(aCpos, {"ZX1_DT_INC" ,"","DT Inclusão",})
         Aadd(aCpos, {"ZX1_FORNEC" ,"","Cod. Fornec.",})
         Aadd(aCpos, {"ZX1_NOMEF"  ,"","Fornecedor",})  
         Aadd(aCpos, {"ZX1_LOJA"   ,"","Loja Fornec.",})
         Aadd(aCpos, {"ZX1_MUN"    ,"","Municipio",})
         Aadd(aCpos, {"ZX1_ESTADO" ,"","Estado",})
         Aadd(aCpos, {"ZX1_TP_FOR" ,"","Tipo Fornc.",} )
         Aadd(aCpos, {"ZX1_CNPJ"   ,"","CNPJ/CPF",} )
         Aadd(aCpos, {"ZX1_INSC_E" ,"","Inscr. Est.",})
         Aadd(aCpos, {"ZX1_LOG_I"  ,"","User",})
         Aadd(aCpos, {"ZX1_ARQUIV" ,"","Arquivo",} )
         Aadd(aCpos, {"LOG_INT"    ,"","Problema"        ,})
      EndIf  
                                                   
      Aadd(aStruZX1, {"cINTEGRA"    ,"C",2   ,0})
      Aadd(aStruZX1, {"ZX1Status"   ,"C",8   ,0})   
      Aadd(aStruZX1, {"ZX1_FILIAL"  ,"C",2   ,0})
      Aadd(aStruZX1, {"ZX1_TIPO"    ,"C",1   ,0})
      Aadd(aStruZX1, {"ZX1_ORIGEM"  ,"C",3   ,0}) 
      Aadd(aStruZX1, {"ZX1_NUM"     ,"C",9   ,0}) 
      Aadd(aStruZX1, {"QTD_ITENS"   ,"N",3   ,0})
      Aadd(aStruZX1, {"ZX1_DATA"    ,"D",8   ,0}) 
      Aadd(aStruZX1, {"ZX1_DT_INC"  ,"D",8   ,0})	
      Aadd(aStruZX1, {"ZX1_FORNEC"  ,"C",6   ,0})
      Aadd(aStruZX1, {"ZX1_LOJA"    ,"C",2   ,0})
      Aadd(aStruZX1, {"ZX1_NOMEF"   ,"C",40  ,0})
      Aadd(aStruZX1, {"ZX1_NOMEF1"  ,"C",20  ,0})
      Aadd(aStruZX1, {"ZX1_MUN"     ,"C",15  ,0})
      Aadd(aStruZX1, {"ZX1_ESTADO"  ,"C",2   ,0})
      Aadd(aStruZX1, {"ZX1_TP_FOR"  ,"C",1   ,0})
      Aadd(aStruZX1, {"ZX1_CNPJ"    ,"C",14  ,0})
      Aadd(aStruZX1, {"ZX1_INSC_E"  ,"C",18  ,0})		
      Aadd(aStruZX1, {"ZX1_LOG_I"   ,"C",25  ,0})
      Aadd(aStruZX1, {"ZX1_LOG_A"   ,"C",25  ,0})
      Aadd(aStruZX1, {"ZX1_ARQUIV"  ,"C",15  ,0})
      Aadd(aStruZX1, {"ZX1_VINC"    ,"C",25  ,0})
      Aadd(aStruZX1, {"ZX1_NOTA"    ,"C",9   ,0})
      Aadd(aStruZX1, {"ZX1_SERIE"   ,"C",3   ,0})
      Aadd(aStruZX1, {"ZX1_MOVIM"   ,"C",1   ,0})
      Aadd(aStruZX1, {"LOG_INT"     ,"C",300,0})
      Aadd(aStruZX1, {"nRecno"      ,"N",3   ,0}) 	   
      
      cNome := CriaTrab(aStruZX1, .T.)                   
      DbUseArea(.T.,"DBFCDX",cNome,'Int_ZX1',.F.,.F.) 
      
      Indice1:=E_Create(,.F.)
      IndRegua("Int_ZX1",Indice1+OrdBagExt(),"nRecno")
      
      Indice2:=E_Create(,.F.)
      IndRegua("Int_ZX1",Indice2+OrdBagExt(),"ZX1Status")   
      
      SET INDEX TO (Indice1+OrdBagExt()),(Indice2+OrdBagExt()) 
       
       
      aStruZX2  := ZX2->(dbStruct())
      cNomeZX2 := CriaTrab(aStruZX2, .T.)                   
      DbUseArea(.T.,,cNomeZX2,'Int_ZX2',.F.,.F.)       

      For nZX2:= 1 To Len(aStruZX2)
         If aStruZX2[nZX2][2] <> "C" .and.  FieldPos(aStruZX2[nZX2][1]) > 0
            TcSetField("Int_ZX2",aStruZX2[nZX2][1],aStruZX2[nZX2][2],aStruZX2[nZX2][3],aStruZX2[nZX2][4])
         EndIf
      Next

      If File(cArquivo)
	   
	     FT_FUse(cArquivo)
	     FT_FGOTOP()
	     
	     Linha := FT_FReadLn()
	     
	     //Valida o arquivo
         If SubStr(Linha,01,03) == "IDO"  
            cCodEmp   := SubStr(Linha,04,02)		    		       
         Else
            MsgAlert(STR019,STR017) //"Arquivo de integração inválido, verifique o arquivo","Atenção" 
		    Return .F.          
         EndIf    
	        
	     
	     While !FT_FEof()
            
            Linha := FT_FReadLn() 
	        
	        //Verifique se inclui ou não fornecedor/cliente                         
	        If SubStr(Linha,01,03) == "IDO"
	           cIncAtuFor:= SubStr(Linha,07,01)  
	        EndIf      
	        
	        //Capa do Romaneio
		    If SubStr(Linha,01,03) == "CPN"
		       RecLock("Int_ZX1",.T.)		    
			   Int_ZX1->ZX1_FILIAL   := xFilial("ZX1")   
			   Int_ZX1->ZX1_TIPO     := SubStr(Linha,06,01)
               Int_ZX1->ZX1_NUM      := SubStr(Linha,13,09)        
			   Int_ZX1->ZX1_FORNEC   := SubStr(Linha,25,06) 			   
			   Int_ZX1->ZX1_LOJA     := SubStr(Linha,31,02) 
			   Int_ZX1->ZX1_DATA     := CtoD(SubStr(Linha,33,10))          
			   Int_ZX1->ZX1_DT_INC   := Date() 
			   Int_ZX1->ZX1_LOG_I    := cUserName
			   Int_ZX1->ZX1_ARQUIV   := Alltrim(cArq)			   
		       Int_ZX1->nRecno       := nRecno  
		       
		       If Alltrim(Int_ZX1->ZX1_TIPO) <> "D"
		       
		          SA2->(DbSetOrder(1))
			      If SA2->(DbSeek(xFilial("SA2")+Int_ZX1->ZX1_FORNEC+Int_ZX1->ZX1_LOJA )) 
			         Int_ZX1->ZX1_NOMEF  :=SA2->A2_NOME
			         Int_ZX1->ZX1_NOMEF1 :=SA2->A2_NREDUZ
			         Int_ZX1->ZX1_MUN    :=SA2->A2_MUN
                     Int_ZX1->ZX1_ESTADO :=SA2->A2_EST
                     Int_ZX1->ZX1_TP_FOR :=SA2->A2_TIPO
                     Int_ZX1->ZX1_CNPJ   :=SA2->A2_CGC
                     Int_ZX1->ZX1_INSC_E :=SA2->A2_INSCR
			      Else   
			         Int_ZX1->ZX1_NOMEF :="Não encontrado"
			      EndIf
		       
		       Else  
		          
		          SA1->(DbSetOrder(1))
			      If SA1->(DbSeek(xFilial("SA1")+Int_ZX1->ZX1_FORNEC+Int_ZX1->ZX1_LOJA )) 
			         Int_ZX1->ZX1_NOMEF  :=SA1->A1_NOME
			         Int_ZX1->ZX1_NOMEF1 :=SA1->A1_NREDUZ
			         Int_ZX1->ZX1_MUN    :=SA1->A1_MUN
                     Int_ZX1->ZX1_ESTADO :=SA1->A1_EST
                     Int_ZX1->ZX1_TP_FOR :=SA1->A1_TIPO
                     Int_ZX1->ZX1_CNPJ   :=SA1->A1_CGC
                     Int_ZX1->ZX1_INSC_E :=SA1->A1_INSCR
			      Else   
			         Int_ZX1->ZX1_NOMEF :="Não encontrado"
			      EndIf
		       
		       
		       EndIf
		       
		       
		       nRecno++     
              
			   lInt:=.T.  // Necessário inicializar com .T. a cada validação 
			  
			   Int_ZX1->LOG_INT     := Validacoes("ZX1") // Validacoes dos campos, retorna Log e seta variavel lInt com .F. caso recusado.
			   	     
               If lInt   
                  Int_ZX1->ZX1Status:=STR020 
               Else    
                  Int_ZX1->ZX1Status:=STR021                     
               EndIf 
               
			   nCountCapa++
			   
     		   Int_ZX1->(MsUnlock())
		
		    EndIf 
			
			//Item do Romaneio
		    If SubStr(Linha,01,03) == "IPI"   
		       
		       //Caso seja outra nota inicializa contador de sequencia e item
		       If Alltrim(cComp)<> Alltrim(Int_ZX1->ZX1_NUM)
		          cComp:=Alltrim(Int_ZX1->ZX1_NUM)
		          nCountItens:=1 
		       Endif
		    
		       RecLock("Int_ZX2",.T.) 
		       Int_ZX2->ZX2_FILIAL   := xFilial("SD1")
		       Int_ZX2->ZX2_PRODUT   := SubStr(Linha,04,15) 
		       
		       SB1->(DbSetOrder(1))
		       If SB1->(DbSeek(xFilial("SB1")+Int_ZX2->ZX2_PRODUT))
		          Int_ZX2->ZX2_PROD_D   := SB1->B1_DESC  
		          Int_ZX2->ZX2_LOCAL    := "02" //SB1->B1_LOCPAD             
		       EndIf
		       
		       /*
		       If Empty(Int_ZX2->ZX2_LOCAL)
		          Int_ZX2->ZX2_LOCAL    := SubStr(Linha,19,02) 
		       EndIf
		       */
		       
		       Int_ZX2->ZX2_UM       := SubStr(Linha,21,02)
		       Int_ZX2->ZX2_QTD      := Val(SubStr(Linha,23,11)) 
		       Int_ZX2->ZX2_SALDO    := Val(SubStr(Linha,23,11))
		       Int_ZX2->ZX2_PRECUN   := Val(SubStr(Linha,34,11))
		       Int_ZX2->ZX2_TOTAL    := Val(SubStr(Linha,45,14))
		       Int_ZX2->ZX2_ITEM     := StrZero(nCountItens,3,0)
		       Int_ZX2->ZX2_NUM      := Int_ZX1->ZX1_NUM  
		       //Int_ZX2->ZX2_PO     := SubStr(Linha,59,06)
		       Int_ZX2->ZX2_TIPO     := "COMPONENTE"
		                
		       //Caso continue na mesma nota incrementa contador de sequencia e item
		       If Alltrim(cComp) == Alltrim(Int_ZX1->ZX1_NUM)
		          nCountItens++ 
               EndIf 
               
		       Int_ZX2->(MsUnlock())            
		   	                            
		       DBSElectarea("Int_ZX1")
		       //Validacoes no ZX2 - Grava log no ZX1
		       RecLock("Int_ZX1",.F.)	
		       Int_ZX1->LOG_INT  := Alltrim(Int_ZX1->LOG_INT) + Validacoes("ZX2") 
		       Int_ZX1->QTD_ITENS :=nCountItens-1    
		       If SubStr(Linha,65,03) == "LOC"
		          Int_ZX1->ZX1_ORIGEM   := SubStr(Linha,65,03)
		       Else
		          Int_ZX1->ZX1_ORIGEM   := "IMP"  
		       EndIf  
		       
		       If lInt
                  Int_ZX1->ZX1Status:=Alltrim(STR020)                   
               Else
                  Int_ZX1->ZX1Status:=Alltrim(STR021) 
               EndIf
		       
		       Int_ZX1->(MsUnlock())
	        
	        EndIf          
	     
	        FT_FSkip()	                      
	    
	     EndDo          
	     
	     Int_ZX1->(DBGoTop())
	     //Contador de aceitos
	     While Int_ZX1->(!EOF())      
	        If Alltrim(Int_ZX1->ZX1Status) $ Alltrim(STR020)   
	           nCountAc++
	        EndIf   
	        Int_ZX1->LOG_INT  := Substr(Alltrim(Int_ZX1->LOG_INT),1,Len(Alltrim(Int_ZX1->LOG_INT))-2)    
	        Int_ZX1->(DbSkip())
	     EndDo   

	     If select("Int_ZX1") > 0
	        Int_ZX1->(DBGoTop())                                         //Altura/Comprimento
            DEFINE MSDIALOG oDlg TITLE "Romaneio Entrada" FROM 000,000 TO 545,1100 PIXEL  //645,1420 PIXEL  
            
                //oTOleContainer := TOleContainer():New( 021,540,052,20,oDlg,.T.,cImg1)   
                oTOleContainer := TOleContainer():New( 021,470,052,20,oDlg,.T.,cImg1) 
                        
                @ 017 , 006 TO   045,540 LABEL "" OF oDlg PIXEL 
                
                @ 021 , 010 Say  STR022     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 057 Say  Alltrim(cArq)          COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,6 OF oDlg  
                
                @ 033 , 010 Say  "Nr Romaneios"     PIXEL SIZE 60,6 OF oDlg 
                @ 033 , 057 Say  Alltrim(Str(nCountCapa))    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
                
                @ 021 , 250 Say  STR024     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 280 Say  Alltrim(cUserName)         COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
                
                @ 033 , 250 Say  STR025     PIXEL SIZE 60,6 OF oDlg
                @ 033 , 280 Say  Date()                     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
                
                @ 021 , 350 Say  STR026     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 390 Say  Alltrim(Str(nCountAc))     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
                
                //@ 033 , 230 Say  STR027             PIXEL SIZE 60,6 OF oDlg         
                oTHButton := THButton():New(28,340,STR027,oDlg,{||Alert(STR028)},40,20,,STR029)
                @ 033 , 390 Say  Alltrim(Str(nCountCapa-nCountAc)) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg     
                
                oFont := TFont():New('Courier new',,-14,.T.)
                oTMsgBar := TMsgBar():New(oDlg, '  Grant Thronton',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
                oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
                oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})                  
                                                                                               
     	        //oMarkPrd:= MsSelect():New("Int_ZX1","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,305,705})    
     	        oMarkPrd:= MsSelect():New("Int_ZX1","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545}) 
            ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||Grava("ZX1")},{|| Finaliza()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
         EndIf

         FT_FUse() 
        
      EndIf 
           
      Int_ZX1->(DBCLoseArea())   
      Int_ZX2->(DBCLoseArea())   

   EndIf

If nSelec==6  // Pre Nota Entrada
            
      If Select("INT_ZX3") > 0
         INT_ZX3->(DBCLoseArea())
      EndIf
      
      If Select("INT_ZX4") > 0
         INT_ZX4->(DBCLoseArea())
      EndIf    
  
      cAliasSX3 := "ZX3"
      DbSelectArea("SX3")
      DbSetOrder(1)   
      
      If __LANGUAGE="PORTUGUESE"
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"ZX3Status"  ,"","Status"        ,}) 
         Aadd(aCpos, {"ZX3_TIPO"   ,"","Tipo do Pedido"  ,}) 
         Aadd(aCpos, {"ZX3_NUM"    ,"","Romaneio."     ,})
         Aadd(aCpos, {"ZX3_DLRY"   ,"","Delivery"      ,})  
         Aadd(aCpos, {"QTD_ITENS"  ,"","Qtd de Itens"  ,})
         Aadd(aCpos, {"ZX3_DATA"   ,"","DT Romaneio"   ,})          
         Aadd(aCpos, {"ZX3_DT_INC" ,"","Data Inclusão" ,}) 
         Aadd(aCpos, {"ZX3_CLIENT" ,"","Cod. Cliente"  ,})
         Aadd(aCpos, {"ZX3_NOMEF"  ,"","Cliente"       ,})
         Aadd(aCpos, {"ZX3_LOJA"   ,"","Loja Cliente"  ,})
         Aadd(aCpos, {"ZX3_MUN"    ,"","Cod. Municip." ,})
         Aadd(aCpos, {"ZX3_ESTADO" ,"","Estado"        ,})
         Aadd(aCpos, {"ZX3_TP_CLI" ,"","Tipo Cliente"  ,})
         Aadd(aCpos, {"ZX3_CNPJ"   ,"","CNPJ/CPF"      ,})
         Aadd(aCpos, {"ZX3_INSC_E" ,"","Inscr. Est."   ,})
         Aadd(aCpos, {"ZX3_LOG_I"  ,"","User"          ,})
         Aadd(aCpos, {"ZX3_ARQUIV" ,"","Arquivo"       ,})
         Aadd(aCpos, {"ZX3_TRANSP" ,"","Transp."       ,}) 
         Aadd(aCpos, {"ZX3_TP_F"   ,"","Tp. Frete"     ,})   
         Aadd(aCpos, {"ZX3_MOEDA"  ,"","Moeda"         ,})
         Aadd(aCpos, {"ZX3_PESOB"  ,"","Peso Bruto"    ,}) 
         Aadd(aCpos, {"ZX3_PESOL"  ,"","Peso Liq."     ,})                         
         Aadd(aCpos, {"LOG_INT"    ,"","Problema"      ,})
         Aadd(aCpos, {"ZX3_PEDCLI ","","Ped. Cliente"  ,})  
         Aadd(aCpos, {"ZX3_OBS "   ,"","Observação"    ,})  
         Aadd(aCpos, {"ZX3_TX"     ,"","Taxa Convers"  ,}) 
      Else
         Aadd(aCpos, {"cINTEGRA"   ,"",})
         Aadd(aCpos, {"ZX3Status"  ,"","Status"        ,}) 
         Aadd(aCpos, {"ZX3_TIPO"   ,"","Tipo do Pedido",}) 
         Aadd(aCpos, {"ZX3_NUM"    ,"","Romaneio."     ,}) 
         Aadd(aCpos, {"ZX3_DLRY"   ,"","Delivery"      ,})  
         Aadd(aCpos, {"QTD_ITENS"  ,"","Qtd de Itens"  ,})
         Aadd(aCpos, {"ZX3_DATA"   ,"","DT Romaneio"   ,})          
         Aadd(aCpos, {"ZX3_DT_INC" ,"","Data Inclusão" ,}) 
         Aadd(aCpos, {"ZX3_CONPAG" ,"","Cond. Pagto"   ,}) 
         Aadd(aCpos, {"ZX3_CLIENT" ,"","Cod. Cliente"  ,})
         Aadd(aCpos, {"ZX3_NOMEF"  ,"","Cliente"       ,})
         Aadd(aCpos, {"ZX3_LOJA"   ,"","Loja Cliente"  ,})
         Aadd(aCpos, {"ZX3_MUN"    ,"","Cod. Municip." ,})
         Aadd(aCpos, {"ZX3_ESTADO" ,"","Estado"        ,})
         Aadd(aCpos, {"ZX3_TP_CLI" ,"","Tipo Cliente"  ,})
         Aadd(aCpos, {"ZX3_CNPJ"   ,"","CNPJ/CPF"      ,})
         Aadd(aCpos, {"ZX3_INSC_E" ,"","Inscr. Est."   ,})
         Aadd(aCpos, {"ZX3_LOG_I"  ,"","User"          ,})
         Aadd(aCpos, {"ZX3_ARQUIV" ,"","Arquivo"       ,})
         Aadd(aCpos, {"ZX3_TRANSP" ,"","Transp."       ,}) 
         Aadd(aCpos, {"ZX3_TP_F"   ,"","Tp. Frete"     ,})   
         Aadd(aCpos, {"ZX3_MOEDA"  ,"","Moeda"         ,})
         Aadd(aCpos, {"ZX3_PESOB"  ,"","Peso Bruto"    ,}) 
         Aadd(aCpos, {"ZX3_PESOL"  ,"","Peso Liq."     ,})                         
         Aadd(aCpos, {"LOG_INT"    ,"","Problema"      ,}) 
         Aadd(aCpos, {"ZX3_PEDCLI ","","Ped. Cliente"  ,})  
         Aadd(aCpos, {"ZX3_OBS "   ,"","Observação"    ,})  
         Aadd(aCpos, {"ZX3_TX"     ,"","Taxa Convers"  ,}) 
          
      EndIf  
                                                   
      Aadd(aStruZX3, {"cINTEGRA"    ,"C",2   ,0})
      Aadd(aStruZX3, {"ZX3Status"   ,"C",8   ,0})   
      Aadd(aStruZX3, {"ZX3_FILIAL"  ,"C",2   ,0})
      Aadd(aStruZX3, {"ZX3_TIPO"    ,"C",1   ,0}) 
      Aadd(aStruZX3, {"ZX3_NUM"     ,"C",9   ,0}) 
      Aadd(aStruZX3, {"ZX3_DLRY"    ,"C",9   ,0}) 
      Aadd(aStruZX3, {"QTD_ITENS"   ,"N",3   ,0})
      Aadd(aStruZX3, {"ZX3_DATA"    ,"D",8   ,0}) 
      Aadd(aStruZX3, {"ZX3_DT_INC"  ,"D",8   ,0})
      Aadd(aStruZX3, {"ZX3_CONPAG"  ,"C",3   ,0})	
      Aadd(aStruZX3, {"ZX3_CLIENT"  ,"C",6   ,0})
      Aadd(aStruZX3, {"ZX3_LOJA"    ,"C",2   ,0})
      Aadd(aStruZX3, {"ZX3_NOMEF"   ,"C",40  ,0})
      Aadd(aStruZX3, {"ZX3_NOMEF1"  ,"C",20  ,0})
      Aadd(aStruZX3, {"ZX3_MUN"     ,"C",15  ,0})
      Aadd(aStruZX3, {"ZX3_ESTADO"  ,"C",2   ,0})
      Aadd(aStruZX3, {"ZX3_TP_CLI"  ,"C",1   ,0})
      Aadd(aStruZX3, {"ZX3_CNPJ"    ,"C",14  ,0})
      Aadd(aStruZX3, {"ZX3_INSC_E"  ,"C",18  ,0})		
      Aadd(aStruZX3, {"ZX3_LOG_I"   ,"C",25  ,0})
      Aadd(aStruZX3, {"ZX3_LOG_A"   ,"C",25  ,0})
      Aadd(aStruZX3, {"ZX3_ARQUIV"  ,"C",40  ,0})
      Aadd(aStruZX3, {"ZX3_VINC"    ,"C",25  ,0})
      Aadd(aStruZX3, {"ZX3_NOTA"    ,"C",9   ,0})
      Aadd(aStruZX3, {"ZX3_SERIE"   ,"C",3   ,0})
      Aadd(aStruZX3, {"ZX3_MOVIM"   ,"C",1   ,0})
      Aadd(aStruZX3, {"ZX3_TRANSP"  ,"C",6   ,0})
      Aadd(aStruZX3, {"ZX3_TP_F"    ,"C",1   ,0})
      Aadd(aStruZX3, {"ZX3_MOEDA"   ,"N",1   ,0})
      Aadd(aStruZX3, {"ZX3_PESOB"   ,"N",11  ,4})
      Aadd(aStruZX3, {"ZX3_PESOL"   ,"N",11  ,4}) 
      Aadd(aStruZX3, {"LOG_INT"     ,"C",300 ,0})
      Aadd(aStruZX3, {"nRecno"      ,"N",3   ,0})
      Aadd(aStruZX3, {"ZX3_PEDCLI " ,"C",6   ,0}) 
      Aadd(aStruZX3, {"ZX3_OBS "    ,"C",150 ,0})
      Aadd(aStruZX3, {"ZX3_TX"      ,"N",7   ,4})    	   
      
      cNome := CriaTrab(aStruZX3, .T.)                   
      DbUseArea(.T.,"DBFCDX",cNome,'Int_ZX3',.F.,.F.) 
      
      Indice1:=E_Create(,.F.)
      IndRegua("Int_ZX3",Indice1+OrdBagExt(),"nRecno")
      
      Indice2:=E_Create(,.F.)
      IndRegua("Int_ZX3",Indice2+OrdBagExt(),"ZX3Status")   
      
      SET INDEX TO (Indice1+OrdBagExt()),(Indice2+OrdBagExt()) 
       
     
      aStruZX4  := ZX4->(dbStruct())
      cNomeZX4 := CriaTrab(aStruZX4, .T.)                   
      DbUseArea(.T.,,cNomeZX4,'Int_ZX4',.F.,.F.)       

      For nZX4:= 1 To Len(aStruZX4)
         If aStruZX4[nZX4][2] <> "C" .and.  FieldPos(aStruZX4[nZX4][1]) > 0
            TcSetField("Int_ZX4",aStruZX4[nZX4][1],aStruZX4[nZX4][2],aStruZX4[nZX4][3],aStruZX4[nZX4][4])
         EndIf
      Next

      If File(cArquivo)
	   
	     FT_FUse(cArquivo)
	     FT_FGOTOP()
	     
	     Linha := FT_FReadLn()
	     
	     //Valida o arquivo
         If SubStr(Linha,01,03) == "IDO"  
            cCodEmp   := SubStr(Linha,04,02)		    		       
         Else
            MsgAlert(STR019,STR017) //"Arquivo de integração inválido, verifique o arquivo","Atenção" 
		    Return .F.          
         EndIf    
	        
	     
	     While !FT_FEof()
            
            Linha := FT_FReadLn() 
	        
	        //Verifique se inclui ou não fornecedor/cliente                         
	        If SubStr(Linha,01,03) == "IDO"
	           cIncAtuFor:= SubStr(Linha,07,01)  
	        EndIf      
	        
	        //Capa do Romaneio
		    If SubStr(Linha,01,03) == "CPV"
		       RecLock("Int_ZX3",.T.)		    
			   Int_ZX3->ZX3_FILIAL   := xFilial("SC6")   
			   Int_ZX3->ZX3_NUM      := SubStr(Linha,04,06) 
			   Int_ZX3->ZX3_TIPO     := SubStr(Linha,10,01)
			   Int_ZX3->ZX3_CLIENT   := SubStr(Linha,11,06)        			   			   
			   Int_ZX3->ZX3_LOJA     := SubStr(Linha,17,02)
			   Int_ZX3->ZX3_TRANSP   := SubStr(Linha,27,06)  
			   Int_ZX3->ZX3_TP_CLI   := SubStr(Linha,33,01)	 
			   Int_ZX3->ZX3_MOEDA    := Val(SubStr(Linha,37,01))	  
			   Int_ZX3->ZX3_DATA     := CtoD(SubStr(Linha,38,8)) 
			   Int_ZX3->ZX3_CONPAG   := SubStr(Linha,46,03)
			   Int_ZX3->ZX3_TP_F     := SubStr(Linha,60,01)  
			   Int_ZX3->ZX3_PESOB    := Val(SubStr(Linha,99,11)) 
			   Int_ZX3->ZX3_PESOL    := Val(SubStr(Linha,110,11))  
			   Int_ZX3->ZX3_OBS      := SubStr(Linha,139,150)
			   Int_ZX3->ZX3_TX       := Val(SubStr(Linha,439,7))
			   cConverte             := SubStr(Linha,446,01)

			   If cConverte == "Y"    
			      Int_ZX3->ZX3_MOEDA :=2
			   Else
			      Int_ZX3->ZX3_MOEDA :=1
			   EndIf 		   
			   
			          			   
			   Int_ZX3->ZX3_DT_INC   := Date() 
			   Int_ZX3->ZX3_LOG_I    := cUserName
			   Int_ZX3->ZX3_ARQUIV   := Alltrim(cArq)
	 
		       Int_ZX3->nRecno       := nRecno  
		       
		       SA1->(DbSetOrder(1))
			   If SA1->(DbSeek(xFilial("SA1")+Int_ZX3->ZX3_CLIENT+Int_ZX3->ZX3_LOJA )) 
			      Int_ZX3->ZX3_NOMEF  :=SA1->A1_NOME
			      Int_ZX3->ZX3_NOMEF1 :=SA1->A1_NREDUZ
			      Int_ZX3->ZX3_MUN    :=SA1->A1_MUN
                  Int_ZX3->ZX3_ESTADO :=SA1->A1_EST
                  Int_ZX3->ZX3_TP_CLI :=SA1->A1_TIPO
                  Int_ZX3->ZX3_CNPJ   :=SA1->A1_CGC
                  Int_ZX3->ZX3_INSC_E :=SA1->A1_INSCR
			   Else   
			      Int_ZX3->ZX3_NOMEF :="Não encontrado"
			   EndIf
		       
		       nRecno++     
              
			   lInt:=.T.  // Necessário inicializar com .T. a cada validação 
			  
			   Int_ZX3->LOG_INT     := Validacoes("ZX3") // Validacoes dos campos, retorna Log e seta variavel lInt com .F. caso recusado.
			   	     
               If lInt   
                  Int_ZX3->ZX3Status:=STR020 
               Else    
                  Int_ZX3->ZX3Status:=STR021                     
               EndIf 
               
			   nCountCapa++
			   
     		   Int_ZX3->(MsUnlock())
		
		    EndIf 
			
			//Item do Romaneio
		    If SubStr(Linha,01,03) == "ITV" .OR. SubStr(Linha,01,03) == "ITS"  .OR. SubStr(Linha,01,03) == "ITC"      
		        
		       cTp:=SubStr(Linha,01,03)
		       
		       //Caso seja outra nota inicializa contador de sequencia e item
		       If Alltrim(cComp)<> Alltrim(Int_ZX3->ZX3_NUM)
		          cComp:=Alltrim(Int_ZX3->ZX3_NUM)
		          nCountItens:=1 
		       Endif
		    
		       RecLock("Int_ZX4",.T.) 
		       
		       Linha := Transform(Linha,"@!")
		       Int_ZX4->ZX4_FILIAL   := xFilial("SD1")
		       Int_ZX4->ZX4_PRODUT   := SubStr(Linha,10,25) 
		       Int_ZX4->ZX4_PROD_D   := SubStr(Linha,25,150)		        
		       Int_ZX4->ZX4_UM       := SubStr(Linha,175,02) 		   		      
		       Int_ZX4->ZX4_QTD      := Val(SubStr(Linha,177,9))
		       Int_ZX4->ZX4_PRECUN   := Val(SubStr(Linha,186,11))
		       Int_ZX4->ZX4_TOTAL    := Val(SubStr(Linha,197,14))   
		         
		       Int_ZX4->ZX4_ITEM     := StrZero(nCountItens,3,0) //StrZero(nCountItens,4-Len(Alltrim(str(nCountItens))),0)
		       Int_ZX4->ZX4_NUM      := Int_ZX3->ZX3_NUM  
		       
		       // Caso o campo ZX4_COD_C esteja preenchido ele terá o código veraz, e o campo ZX4_PRODUT o código do produto do cliente
		       // é necessário inverter os conteúdos.
		       
		       If !Empty(Alltrim(SubStr(Linha,244,15))) .And. !Empty(Alltrim(SubStr(Linha,259,150)))
		          
		          Int_ZX4->ZX4_COD_C:= Int_ZX4->ZX4_PRODUT  //Recebe o código produto cliente
		          Int_ZX4->ZX4_DESCC:= Int_ZX4->ZX4_PROD_D  //Recebe a descrição produto cliente 
		          
		          Int_ZX4->ZX4_PRODUT:= SubStr(Linha,244,15)   //Recebe o código Veraz
		          Int_ZX4->ZX4_PROD_D:= SubStr(Linha,259,150)  //Recebe a descrição Veraz
		       
		       EndIf  
		       
		       SB1->(DbSetOrder(1))
		       If SB1->(DbSeek(xFilial("SB1")+Int_ZX4->ZX4_PRODUT))
		          Int_ZX4->ZX4_PROD_D   := SB1->B1_DESC  
		          Int_ZX4->ZX4_LOCAL    := "02" //SB1->B1_LOCPAD 
		          cB1_TIPO              := SB1->B1_P_TIP   
		       EndIf   
		     
		       If cTp == "ITV"
		          Int_ZX4->ZX4_TIPO  :="COMP. SISTEMA"
		       ElseIf cTp == "ITS"
		          Int_ZX4->ZX4_TIPO  :="SISTEMA"
		       ElseIf cTp == "ITC" 
		          If SB1->B1_P_TIP=="2" 
		             Int_ZX4->ZX4_TIPO := "ITEM P/ NF SERVIÇO"
		          Else
		             Int_ZX4->ZX4_TIPO  :="COMP. P/ VENDA"
		          EndIf
		       EndIf          
		                
		       If cConverte == "Y"   
		          Int_ZX4->ZX4_PRC_US := Int_ZX4->ZX4_PRECUN / Int_ZX3->ZX3_TX  
		          Int_ZX4->ZX4_TOT_US := Int_ZX4->ZX4_TOTAL  / Int_ZX3->ZX3_TX 
		       EndIf   
		                
		       //Caso continue na mesma nota incrementa contador de sequencia e item
		       If Alltrim(cComp) == Alltrim(Int_ZX3->ZX3_NUM)
		          nCountItens++ 
               EndIf 
               
		       Int_ZX4->(MsUnlock())  		       
		        		   	                            
		       DBSElectarea("Int_ZX3")
		       //Validacoes no ZX4 - Grava log no ZX3
		       RecLock("Int_ZX3",.F.)	  
		       
		       Int_ZX3->ZX3_DLRY    := SubStr(Linha,409,09)
		       Int_ZX3->LOG_INT     := Alltrim(Int_ZX3->LOG_INT) + Validacoes("ZX4") 
		       Int_ZX3->QTD_ITENS   := nCountItens-1
		       Int_ZX3->ZX3_PEDCLI  := SubStr(Linha,235,9)  
		       
		       //Necessário validar - Delivery
		       Int_ZX3->LOG_INT     := Alltrim(Int_ZX3->LOG_INT) + Validacoes("ZX3") // Validacoes dos campos, retorna Log e seta variavel lInt com .F. caso recusado.  
		       
		       If lInt
                  Int_ZX3->ZX3Status:=Alltrim(STR020)                   
               Else
                  Int_ZX3->ZX3Status:=Alltrim(STR021) 
               EndIf
		                                 
		      
		       
		       Int_ZX3->(MsUnlock())
	        
	        EndIf          
	     
	        FT_FSkip()	                                
	    
	     EndDo          
	     
	     Int_ZX3->(DBGoTop())
	     //Contador de aceitos
	     While Int_ZX3->(!EOF())      
	        If Alltrim(Int_ZX3->ZX3Status) $ Alltrim(STR020)   
	           nCountAc++
	        EndIf   
	        Int_ZX3->LOG_INT  := Substr(Alltrim(Int_ZX3->LOG_INT),1,Len(Alltrim(Int_ZX3->LOG_INT))-2)    
	        Int_ZX3->(DbSkip())
	     EndDo   

	     If select("Int_ZX3") > 0
	        Int_ZX3->(DBGoTop())                                         //Altura/Comprimento
            DEFINE MSDIALOG oDlg TITLE "Romaneio Saída" FROM 000,000 TO 545,1100 PIXEL  //645,1420 PIXEL   
            
                //oTOleContainer := TOleContainer():New( 021,640,052,20,oDlg,.T.,cImg1)   
                oTOleContainer := TOleContainer():New( 021,470,052,20,oDlg,.T.,cImg1)
                        
                //@ 017 , 006 TO   045,705 LABEL "" OF oDlg PIXEL 
                @ 017 , 006 TO   045,540 LABEL "" OF oDlg PIXEL    
               
                @ 021 , 010 Say  STR022     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 057 Say  Alltrim(cArq)          COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 170,6 OF oDlg  
               
                @ 033 , 010 Say  "Nr Romaneios"     PIXEL SIZE 60,6 OF oDlg 
                @ 033 , 057 Say  Alltrim(Str(nCountCapa))    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
               
                @ 021 , 250 Say  STR024     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 280 Say  Alltrim(cUserName)         COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
               
                @ 033 , 250 Say  STR025     PIXEL SIZE 60,6 OF oDlg
                @ 033 , 280 Say  Date()                     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg    
               
                @ 021 , 350 Say  STR026     PIXEL SIZE 60,6 OF oDlg           
                @ 021 , 390 Say  Alltrim(Str(nCountAc))     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
               
                //@ 033 , 230 Say  STR027             PIXEL SIZE 60,6 OF oDlg         
                oTHButton := THButton():New(28,340,STR027,oDlg,{||Alert(STR028)},40,20,,STR029)
                @ 033 , 390 Say  Alltrim(Str(nCountCapa-nCountAc)) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg     
                
                oFont := TFont():New('Courier new',,-14,.T.)
                oTMsgBar := TMsgBar():New(oDlg, '  HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
                oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
                oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})                  
                                                                                               
     	        //oMarkPrd:= MsSelect():New("Int_ZX3","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,305,705})   
                oMarkPrd:= MsSelect():New("Int_ZX3","cINTEGRA",,aCpos,@lInverte,@cMarca,{50,6,247,545}) 
            ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||Grava("ZX3")},{|| Finaliza()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
         EndIf

         FT_FUse() 
        
      EndIf 
           
      Int_ZX3->(DBCLoseArea())   
      Int_ZX4->(DBCLoseArea())   

   EndIf


Return .T.
          

*-----------------------------------*
  Static Function Validacoes(cTipo)
*-----------------------------------*

Local cLog := ""   

   If cTipo == "ZX1" 

      If alltrim(Int_ZX1->ZX1_NUM) <> "" 
         If Valida_ZX1(Alltrim(Int_ZX1->ZX1_NUM)) <> ""
	       cLog := "ROMANEIO JA EXISTE /"
           lInt:=.F.
         EndIf
      EndIf
	  	  
	  If !Int_ZX1->ZX1_TIPO $ "NDIPBC"
	     cLog := cLog + "TIPO DE NOTA INCORRETO / "
	     lInt:=.F.
	  EndIf 
			
	  If Alltrim(Int_ZX1->ZX1_FORNEC) <> "" .Or. Alltrim(Int_ZX1->ZX1_LOJA) <> ""	
         If !(Alltrim(Int_ZX1->ZX1_TIPO) $ "B/D")  
	        If Alltrim(Valida_FORN(Int_ZX1->ZX1_FORNEC,Int_ZX1->ZX1_LOJA)) == ""  // Impede a gravação pois o fornecedor não eixste.  lInt:=.F.
	           cLog:=cLog + "FORNECEDOR NAO CADASTRADO / "
	           lInt:=.F.    
	        EndIf
	     Else  
	        If Alltrim(Valida_CLI(Int_ZX1->ZX1_FORNECE,Int_ZX1->ZX1_LOJA)) == ""   // Impede a gravação pois o cliente não eixste.  lInt:=.F.
	           cLog := cLog + "CLIENTE NAO CADASTRADO / "  
	           lInt:=.F. 
	        EndIf
	     EndIf      
	  Else 
	     cLog := cLog + "CLIENTE/FORNECEDOR OU LOJA NAO CADASTRADO / " 
	     lInt:=.F.
	  EndIf 
    	  
   EndIf	   
	 
   If cTipo=="ZX2" 
   
      If Valida_Produto(Int_ZX2->ZX2_PRODUT) == ""
	     cLog := cLog + STR043 + AllTrim(Int_ZX2->ZX2_PRODUT) + STR044  // " PRODUTO ","NAO CADASTRADO / "
	     lInt:=.F.
	  EndIf 
	
	  //If AllTrim(Int_ZX2->ZX2_LOCAL) == ""
	  //   cLog := cLog + STR045  //"LOCAL NAO PREENCHIDO / "
	  //   lInt:=.F.
      //EndIf
      
      //If Valida_Local(Int_ZX2->ZX2_PRODUT,Int_ZX2->ZX2_LOCAL) == ""  
      //   cLog := cLog + STR046  //"LOCAL INVALIDO / "   
	  //   lInt:=.F.  
	  //EndIf   

	  If AllTrim(Int_ZX2->ZX2_UM) == ""
	     cLog := cLog + STR047  //"UNIDADE NAO PREENCHIDO / "
	     lInt:=.F.
      EndIf
      
      If !(Int_ZX2->ZX2_QTD > 0 )
	     cLog := cLog + STR048  //"QUANTIDADE NAO PREENCHIDO / "
	     lInt:=.F.
      EndIf 
      
      //If !(Int_ZX2->ZX2_PRECUN > 0)  
	  //   cLog := cLog + STR049  //"VALOR UNITARIO NAO PREENCHIDO / "  
	  //   lInt:=.F.
      //EndIf  
      
      //If !(Int_ZX2->ZX2_TOTAL > 0)
	  //   cLog := cLog + STR050  //"VALOR TOTAL NAO PREENCHIDO / " 
	  //   lInt:=.F.
     // EndIf             
   
   EndIf
   
   If cTipo=="ZX3"
   
      If !Int_ZX3->ZX3_TIPO $ "N/C/I/P/X"
	     cLog := STR051  //"TIPO DE PEDIDO INCORRETO/"
	     lInt:=.F.
	  EndIf
			
	  If !Int_ZX3->ZX3_TP_CLI $ "F/L/R/S/X"
	     cLog := cLog + STR052 //"TIPO DE CLIENTE INCORRETO/"
	     lInt:=.F.
	  EndIf 
			
	  If Alltrim(Valida_CLI(Int_ZX3->ZX3_CLIENT,Int_ZX3->ZX3_LOJA)) == ""
	     cLog := cLog + STR041 // "CLIENTE NAO CADASTRADO/"
	     lInt:=.F.
	  EndIf 
	
 	  If Valida_ZX3(Int_ZX3->ZX3_NUM,Int_ZX3->ZX3_DLRY) <> ""
	     cLog := cLog +  "ROMANEIO JA CONSTA NO SISTEMA / "
	     lInt:=.F.
	  EndIf 
	
	  If Alltrim(Int_ZX3->ZX3_LOJA) == ""
	     cLog := cLog + STR054 // "LOJA CLIENTE INVALIDA/"
	     lInt:=.F.
	  EndIf     
	  
	  If cConverte == "Y"
	     If Int_ZX3->ZX3_TX==0
	        cLog := cLog + " TAXA DE CONVERSAO INVALIDA PARA ARQUIVO COM 'Y' (POS.446) / "
	        lInt:=.F.
	     EndIf    
	  
	  EndIf                                        
   
   EndIf
   
   If cTipo=="ZX4"

      If Valida_Produto(Int_ZX4->ZX4_PRODUT) == ""
         cLog := cLog + STR043 + AllTrim(Int_ZX4->ZX4_PRODUT) + STR044 + " OU ARQUIVO SEM REFERNCIA CODIGO VERAZ /"
	     lInt:=.F.
	  EndIf 
      /*
	  If AllTrim(Int_ZX4->ZX4_LOCAL) == ""
	     cLog := cLog + STR045 //"LOCAL NAO PREENCHIDO /"  
	     lInt:=.F.
	  EndIf
      */           
   EndIf
   
Return AllTrim(cLog)            

//Grava os dados.                            
*--------------------------------------*
   Static Function Grava(cTipo)
*--------------------------------------*

Local lOk:=.F.
  
If cTipo=="ZX1"  
         
   DbSelectArea("ZX1")
   ZX1->(DbSetOrder(1))
   Int_ZX1->(dbGotop()) 
   
   While !Int_ZX1->(Eof())                         
      
      IF (AllTrim(Int_ZX1->cINTEGRA) <> "") .And. (AllTrim(Int_ZX1->ZX1Status) $ Alltrim(STR021))
         MsgStop(STR034,STR017) // "Existe pedido(s) recusado(s) marcado(s), verifique a mensagem","Atenção" 
         Return .F.
      EndIf              
      
      Int_ZX1->(DbSkip())   
   EndDo   
   
   Int_ZX1->(dbGotop()) 

   While !Int_ZX1->(Eof())
      
      If (AllTrim(Int_ZX1->cINTEGRA) <> "") .And. !(AllTrim(Int_ZX1->ZX1Status) $ Alltrim(STR021) )		  
      
         If !ZX1->(DbSeek(xFilial("ZX1")+Int_ZX1->ZX1_NUM))
           
            RecLock("ZX1",.T.)      
            ZX1->ZX1_FILIAL  :=Int_ZX1->ZX1_FILIAL 
	        ZX1->ZX1_TIPO    :=Int_ZX1->ZX1_TIPO  
	        ZX1->ZX1_ORIGEM  :=Int_ZX1->ZX1_ORIGEM  
            ZX1->ZX1_NUM     :=Int_ZX1->ZX1_NUM                         
	        ZX1->ZX1_FORNEC  :=Int_ZX1->ZX1_FORNEC 
	        ZX1->ZX1_LOJA    :=Int_ZX1->ZX1_LOJA            
	        ZX1->ZX1_DATA    :=Int_ZX1->ZX1_DATA 
	        ZX1->ZX1_DT_INC  :=Int_ZX1->ZX1_DT_INC
            ZX1->ZX1_NOMEF   :=Int_ZX1->ZX1_NOMEF 
            ZX1->ZX1_NOMEF1  :=Int_ZX1->ZX1_NOMEF1 
            ZX1->ZX1_MUN     :=Int_ZX1->ZX1_MUN 
            ZX1->ZX1_ESTADO  :=Int_ZX1->ZX1_ESTADO
            ZX1->ZX1_TP_FOR  :=Int_ZX1->ZX1_TP_FOR 
            ZX1->ZX1_CNPJ    :=Int_ZX1->ZX1_CNPJ
            ZX1->ZX1_INSC_E  :=Int_ZX1->ZX1_INSC_E
            ZX1->ZX1_LOG_I   :=Int_ZX1->ZX1_LOG_I
            ZX1->ZX1_ARQUIV  :=Int_ZX1->ZX1_ARQUIV   
            
            If ZX1->ZX1_ORIGEM == "LOC"
               ZX1->ZX1_VINC    :="L"   // Compra Local
            Else
               ZX1->ZX1_VINC    :="N"   // Compra Externa
            EndIf
              
            ZX1->(MsUnlock())     

            lOk:=.T.

            Int_ZX2->(dbGotop())
            DbSelectArea("ZX2")
         
            While !Int_ZX2->(Eof()) 
                   
               If (Int_ZX1->ZX1_NUM == Int_ZX2->ZX2_NUM) 
                                 
                  RecLock("ZX2",.T.)     
                  ZX2->ZX2_FILIAL := Int_ZX2->ZX2_FILIAL 
                  ZX2->ZX2_PRODUT := Int_ZX2->ZX2_PRODUT
                  ZX2->ZX2_PROD_D := Int_ZX2->ZX2_PROD_D
                  ZX2->ZX2_ITEM   := Int_ZX2->ZX2_ITEM
                  ZX2->ZX2_QTD    := Int_ZX2->ZX2_QTD
                  ZX2->ZX2_PRECUN := Int_ZX2->ZX2_PRECUN 
                  ZX2->ZX2_TOTAL  := Int_ZX2->ZX2_TOTAL
                  ZX2->ZX2_UM     := Int_ZX2->ZX2_UM
                  ZX2->ZX2_LOCAL  := Int_ZX2->ZX2_LOCAL
                  ZX2->ZX2_NUM    := Int_ZX2->ZX2_NUM
                  ZX2->ZX2_TIPO   := Int_ZX2->ZX2_TIPO 

                  ZX2->(MsUnlock())   
                  
               EndIf
                      
               Int_ZX2->(DbSkip())           
            EndDo       
      
         
         EndIf
      
      EndIf  
                       
      Int_ZX1->(DbSkip())
   EndDo 
   
EndIf

If cTipo=="ZX3"  
         
   DbSelectArea("ZX3")
   ZX3->(DbSetOrder(1))
   Int_ZX3->(dbGotop()) 
   
   While !Int_ZX3->(Eof())                         
      
      IF (AllTrim(Int_ZX3->cINTEGRA) <> "") .And. (AllTrim(Int_ZX3->ZX3Status) $ Alltrim(STR021))
         MsgStop(STR034,STR017) // "Existe pedido(s) recusado(s) marcado(s), verifique a mensagem","Atenção" 
         Return .F.
      EndIf              
      
      Int_ZX3->(DbSkip())   
   EndDo   
   
   Int_ZX3->(dbGotop()) 

   While !Int_ZX3->(Eof())
      
      If (AllTrim(Int_ZX3->cINTEGRA) <> "") .And. !(AllTrim(Int_ZX3->ZX3Status) $ Alltrim(STR021) )		  
      
         If !ZX3->(DbSeek(xFilial("ZX3")+Int_ZX3->ZX3_NUM+Int_ZX3->ZX3_DLRY))
           
            RecLock("ZX3",.T.)      
            ZX3->ZX3_FILIAL  :=Int_ZX3->ZX3_FILIAL 
	        ZX3->ZX3_TIPO    :=Int_ZX3->ZX3_TIPO    
            ZX3->ZX3_NUM     :=Int_ZX3->ZX3_NUM                         
	        ZX3->ZX3_CLIENT  :=Int_ZX3->ZX3_CLIENT 
	        ZX3->ZX3_LOJA    :=Int_ZX3->ZX3_LOJA            
	        ZX3->ZX3_DATA    :=Int_ZX3->ZX3_DATA 
	        ZX3->ZX3_DT_INC  :=Int_ZX3->ZX3_DT_INC 
	        ZX3->ZX3_CONPAG  :=Int_ZX3->ZX3_CONPAG
            ZX3->ZX3_NOMEF   :=Int_ZX3->ZX3_NOMEF 
            ZX3->ZX3_NOMEF1  :=Int_ZX3->ZX3_NOMEF1 
            ZX3->ZX3_MUN     :=Int_ZX3->ZX3_MUN 
            ZX3->ZX3_ESTADO  :=Int_ZX3->ZX3_ESTADO
            ZX3->ZX3_TP_CLI  :=Int_ZX3->ZX3_TP_CLI 
            ZX3->ZX3_CNPJ    :=Int_ZX3->ZX3_CNPJ
            ZX3->ZX3_INSC_E  :=Int_ZX3->ZX3_INSC_E
            ZX3->ZX3_LOG_I   :=Int_ZX3->ZX3_LOG_I
            ZX3->ZX3_ARQUIV  :=Int_ZX3->ZX3_ARQUIV  
            ZX3->ZX3_PEDCLI  :=Int_ZX3->ZX3_PEDCLI 
            ZX3->ZX3_DLRY    :=Alltrim(Int_ZX3->ZX3_DLRY)
            ZX3->ZX3_VINC    :="N"  
            ZX3->ZX3_OBS     :=Int_ZX3->ZX3_OBS
            ZX3->ZX3_MOEDA   :=Int_ZX3->ZX3_MOEDA
            ZX3->ZX3_TX      :=Int_ZX3->ZX3_TX       

            ZX3->(MsUnlock())     

            lOk:=.T.

            Int_ZX4->(dbGotop())
            DbSelectArea("ZX4")
         
            While !Int_ZX4->(Eof()) 
                   
               If (Alltrim(Int_ZX3->ZX3_NUM) == Alltrim(Int_ZX4->ZX4_NUM)) 
               
                  
                  RecLock("ZX4",.T.)     
                  ZX4->ZX4_FILIAL := Int_ZX4->ZX4_FILIAL 
                  ZX4->ZX4_PRODUT := Int_ZX4->ZX4_PRODUT
                  ZX4->ZX4_PROD_D := Int_ZX4->ZX4_PROD_D
                  ZX4->ZX4_ITEM   := Int_ZX4->ZX4_ITEM
                  ZX4->ZX4_QTD    := Int_ZX4->ZX4_QTD
                  ZX4->ZX4_PRECUN := Int_ZX4->ZX4_PRECUN 
                  ZX4->ZX4_TOTAL  := Int_ZX4->ZX4_TOTAL
                  ZX4->ZX4_UM     := Int_ZX4->ZX4_UM
                  ZX4->ZX4_LOCAL  := Int_ZX4->ZX4_LOCAL
                  ZX4->ZX4_NUM    := Int_ZX4->ZX4_NUM
                  ZX4->ZX4_TIPO   := Int_ZX4->ZX4_TIPO 
                  ZX4->ZX4_COD_C  := Int_ZX4->ZX4_COD_C
                  ZX4->ZX4_DESCC  := Int_ZX4->ZX4_DESCC 
                  ZX4->ZX4_PROD_D := Int_ZX4->ZX4_PROD_D 
                  ZX4->ZX4_DLRY    :=Alltrim(Int_ZX3->ZX3_DLRY)  
                  
                  If cConverte=="Y" 
                     ZX4->ZX4_PRC_US := Int_ZX4->ZX4_PRC_US
                     ZX4->ZX4_TOT_US := Int_ZX4->ZX4_TOT_US
                  EndIf

                  ZX4->(MsUnlock())   
                  
               EndIf
                      
               Int_ZX4->(DbSkip())           
            EndDo       
      
         
         EndIf
      
      EndIf  
                       
      Int_ZX3->(DbSkip())
   EndDo 
   
EndIf


If lOk
   MsgAlert(STR031,STR017) //"Importação Finalizada","Atenção"
   oDlg:End()      
Else
   MsgAlert(STR032,STR017)  //"Nenhum dado importado","Atenção"
   If cTipo=="ZX1"
      Int_ZX1->(DbGoTop())
   ElseIf cTipo=="ZX3"
      Int_ZX3->(DbGoTop())
   EndIf
EndIf


Return .F.    

//Marca todos
*---------------------------------------*
   Static Function MarcaTds()
*---------------------------------------* 

Local lExist:=.F.
   
   If nSelec==5 // Entrada
     
      DbSelectArea("Int_ZX1")   
      Int_ZX1->(DbGoTop())  
      While Int_ZX1->(!EOF())
         RecLock("Int_ZX1",.F.)     
         If Alltrim(Int_ZX1->ZX1Status) == Alltrim(STR020) //Aceito
            If Int_ZX1->cINTEGRA == cMarca    
               Int_ZX1->cINTEGRA:=Space(02)   
            Else
               Int_ZX1->cINTEGRA:= cMarca
            EndIf 
            lExist:=.T.               
         EndIf
         Int_ZX1->(MsUnlock())
         Int_ZX1->(DbSkip())
      EndDo      
      Int_ZX1->(DbGoTop())      
      If !(lExist) 
         MsgInfo(STR030)  //"Não existe registros aceitos para integrar"	 
      EndIf             
     
   EndIf    
   
   If nSelec==6 // Saida
     
      DbSelectArea("Int_ZX3")   
      Int_ZX3->(DbGoTop())   
      While Int_ZX3->(!EOF())
         RecLock("Int_ZX3",.F.)
         If Alltrim(Int_ZX3->ZX3Status) == Alltrim(STR020)  //Aceito  
            If Int_ZX3->cINTEGRA == cMarca    
               Int_ZX3->cINTEGRA:=Space(02)   
            Else
               Int_ZX3->cINTEGRA:= cMarca
            EndIf
            lExist:=.T.              
         EndIf
         Int_ZX3->(MsUnlock())
         Int_ZX3->(DbSkip())
      EndDo     
      Int_ZX3->(DbGoTop())           
      If !(lExist)
         MsgInfo(STR030)  //"Não existe registros aceitos para integrar"	 
      EndIf     
  
   EndIf  
    
Return            
      

//Ordena Aceitos
*-----------------------------*
   Static Function Ordena()
*-----------------------------* 

Local lExist:=.F.  
Local nOrd:=IndexOrd()
   
   If nSelec==5 // Entrada     
      If nOrd == 1 
         DbSelectArea("Int_ZX1")   
         Int_ZX1->(DbSetOrder(2))
         Int_ZX1->(DbGoTop())           
      Else 
         DbSelectArea("Int_ZX1")   
         Int_ZX1->(DbSetOrder(1))
         Int_ZX1->(DbGoTop())       
      EndIf           
   EndIf    
   
   If nSelec==6 // Saida
      If nOrd == 1   
         DbSelectArea("Int_ZX3")   
         Int_ZX3->(DbSetOrder(2))
         Int_ZX3->(DbGoTop()) 
      Else
         DbSelectArea("Int_ZX3")   
         Int_ZX3->(DbSetOrder(1))
         Int_ZX3->(DbGoTop())       
      EndIf 
   EndIf  
 
Return            
      
*------------------------------*
  Static Function Finaliza()
*------------------------------*  

Local lRet:=.F.
 
If MsgNoYes(STR059,STR017) //"Deseja sair ?","Atenção"    
   oDlg:End()
EndIf

Return lRet
 

//Valida Cliente 
*---------------------------------------*
  Static Function Valida_CLI(cCli,cLoja)
*---------------------------------------*

If Select("SQL") > 0
   SQL->(dbCloseArea())
EndIf               

cQuery := "SELECT A1_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SA1")+Chr(10)
cQuery += " WHERE A1_COD = '"+Alltrim(cCli)+"'"+Chr(10)      
cQuery += " AND A1_LOJA = '"+Alltrim(cLoja)+"'"+Chr(10)    
cQuery += " AND D_E_L_E_T_ <> '*' and A1_FILIAL='"+xFilial("SA1")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->A1_COD    
                           
//Valida Fornecedor                                                                                                                 
*-------------------------------------------*
   Static Function Valida_FORN(cForn,cLoja)
*-------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                         

cQuery := "SELECT A2_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SA2")+Chr(10)
cQuery += " WHERE A2_COD = '"+Alltrim(cForn)+"'"+Chr(10)      
cQuery += " AND A2_LOJA = '"+Alltrim(cLoja)+"'"+Chr(10)    
cQuery += " AND D_E_L_E_T_ <> '*' and A2_FILIAL='"+xFilial("SA2")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->A2_COD    
                 
//Valida Produto
*------------------------------------------*
  Static Function Valida_Produto(cProduto)    
*------------------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT B1_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SB1")+Chr(10)
cQuery += " WHERE B1_COD = '"+cProduto+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return Alltrim(SQL->B1_COD)  


//Valida Local
*------------------------------------------*
  Static Function Valida_Local(cCod,cLocal)    
*------------------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT B2_LOCAL "+Chr(10)
cQuery += " FROM "+RetSqlName("SB2")+Chr(10)
cQuery += " WHERE B2_LOCAL = '"+cLocal+"'"+Chr(10) 
cQuery += " AND B2_COD = '"+cCod+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' AND  B2_FILIAL='"+xFilial("SB2")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return Alltrim(SQL->B2_LOCAL)


//Busca do Vendedor    
*----------------------------------------*
  Static Function Valida_Vendedor(_cVend)
*----------------------------------------* 

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT A3_COD "+Chr(10)
cQuery += " FROM "+RetSqlName("SA3")+Chr(10)
cQuery += " WHERE A3_COD = '"+Alltrim(_cVend)+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->A3_COD 

// Valida Numero do nota
*------------------------------------------*
  Static Function Valida_ZX1(cNum)
*------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT ZX1_NUM "+Chr(10)
cQuery += " FROM "+RetSqlName("ZX1")+Chr(10)
cQuery += " WHERE ZX1_NUM = '"+Alltrim(cNUm)+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' and ZX1_FILIAL='"+xFilial("ZX1")+"'"

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->ZX1_NUM)
   

//Busca do Agencia
*--------------------------------------------* 
  Static Function Valida_Agencia(cAgencia)
*--------------------------------------------* 

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT ZA_AGENCIA "+Chr(10)
cQuery += " FROM "+RetSqlName("SZA")+Chr(10)
cQuery += " WHERE ZA_AGENCIA = '"+Alltrim(cAgencia)+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->ZA_AGENCIA)        

//Busca Numero do Pedido   
*----------------------------------------*
  Static Function BuscaCodPed(cFILIAL)
*----------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := "SELECT max(C5_NUM)+ 1 AS PEDIDO"+Chr(10)
cQuery += " FROM "+RetSqlName("SC5")+Chr(10)
cQuery += " WHERE patindex( '%[^0-9]%' , SUBSTRING(C5_NUM,1,6))=0 and left(C5_NUM,1)<>'9' AND C5_FILIAL ='"+cFILIAL+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->PEDIDO

// Valida Numero do Romaneio
*------------------------------------------* 
  Static Function Valida_ZX3(cNUM,cDelivery)
*------------------------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT ZX3_NUM "+Chr(10)
cQuery += " FROM "+RetSqlName("ZX3")+Chr(10)
cQuery += " WHERE ZX3_NUM = '"+cNUM+"'"+Chr(10)
cQuery += " AND ZX3_DLRY= '"+cDelivery+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return AllTrim(SQL->ZX3_NUM)       
       
//Valida numeração da nota fiscal de entrada.
*----------------------------------------------------*
  Static Function  Valida_NFE(cNota,cSerie,cFormul)
*----------------------------------------------------*
   
Local cFil:=xFilial("SF1")

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT F1_DOC "+Chr(10)
cQuery += " FROM "+RetSqlName("SF1")+Chr(10)
cQuery += " WHERE F1_FILIAL='"+cFil+"'"+Chr(10)
cQuery += " AND F1_DOC   = '"+cNota+"'"+Chr(10)
cQuery += " AND F1_SERIE = '"+cSerie+"'"+Chr(10)
cQuery += " AND F1_FORMUL   = '"+cFormul+"'"+Chr(10)
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->F1_DOC      
                     
//Busca Ultima numeração usada
*----------------------------------------------------*
  Static Function NumNFE()
*----------------------------------------------------*
   
Local cFil:=xFilial("SF1")

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT MAX(F1_DOC) + 1 AS NEXTDOC "+Chr(10)
cQuery += " FROM "+RetSqlName("SF1")+Chr(10)
cQuery += " Where patindex( '%[^0-9]%' , SUBSTRING(F1_DOC,1,9))=0 and left(F1_DOC,1)<>'9' AND F1_FILIAL='"+cFil+"'"+Chr(10) 
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->NEXTDOC

//Busca ultimo código SD3
*--------------------------------------*
 Static Function  BuscaNumSD3(cFILIAL)
*--------------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT max(D3_DOC)+ 1 AS DOC"+Chr(10)
cQuery += " FROM "+RetSqlName("SD3")+Chr(10)
cQuery += " WHERE patindex( '%[^0-9]%' , SUBSTRING(D3_DOC,1,6))=0 and left(D3_DOC,1)<>'9' AND D3_FILIAL='"+cFILIAL+"'"
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->DOC

//Busca ultima sequencia SD3
*-------------------------------*
 Static Function  BuscaSeqSD3(cFILIAL)
*-------------------------------*  

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf                        

cQuery := " SELECT max(D3_NUMSEQ)+ 1 AS DOC"+Chr(10)
cQuery += " FROM "+RetSqlName("SD3")+Chr(10)
cQuery += " WHERE patindex( '%[^0-9]%' , SUBSTRING(D3_NUMSEQ,1,6))=0 and left(D3_NUMSEQ,1)<>'9' AND D3_FILIAL='"+cFILIAL+"'"
cQuery += " AND D_E_L_E_T_ <> '*' "

TCQuery cQuery ALIAS "SQL" NEW

Return SQL->DOC

                                                                                               
/*
Funcao      : Visualização do Romaneio
Autor       : Tiago Luiz Mendonça
Data/Hora   : 09/02/10
Descrição   : A visalização dos romaneios foi dividida em funções distintas para facilitar a manutenção

Função ERomaneio - Romaneio de entrada

ZX1  - Capa
ZX2  - Itens
WORK - Itens do romaneio para gerar movimentação no SD3 e atualizar saldo e custo no SB2.

*/
           
// Função Principal do romaneio de entrada.
*--------------------------*
  User Function ERomaneio()      
*--------------------------*     

Local  aCores:={}      
Private aRotina:={}
Private cLeg:="E"  

  
  If !(cEmpAnt $ "KX/XC")
     MsgInfo("Especifico Veraz"," A T E N C A O ")      
     Return .F.
  Endif    


  DbSelectArea("ZX1")
  DbSetOrder(1)   
  ZX1->(DbGoTop()) 

  aRotina := {{ "Pesquisa"             ,"AxPesqui"   , 0 , 1},;
	          { "Visualizar"           ,"U_EViewXC"   , 0 , 2},;  
	          { "Excluir "             ,"U_EViewXC"   , 0 , 3},;
	          { "Gerar Movim."         ,"U_EGerarXC"  , 0 , 4},;
	          { "Estorna Movim."       ,"U_EEstXC"    , 0 , 4},;
	          { "Legenda"              ,"U_LegXC"    , 0 , 3} }  
	          
  aCores  := {{ "ZX1_VINC=='N'",'BR_VERDE'   },;	//Romaneio de Entrada não vinculado. 
              { "ZX1_VINC=='V'",'BR_AMARELO' },;	//Romaneio de Entrada vinculado a nota fiscal
	          { "ZX1_VINC=='L'",'BR_BRANCO' },;     //Romaenio de Entrada Local pra Pre-NOTA
	          { "ZX1_VINC=='G'",'BR_VERMELHO'}}  	//Romaneio de Entrada Vinculado a nota e com movimentação gerada.		    



   mBrowse(6,1,22,75,"ZX1",,,,,,aCores)	   
   
Return       

/*
Funcao      : Visualização do Romaneio
Autor       : Tiago Luiz Mendonça
Data/Hora   : 25/02/10

Função SRomaneio - Romaneio de saída

ZX3  - Capa
ZX4  - Itens
WORK - Itens do romaneio para gerar o pedido no SC5/SC6, movimentação no SD3 e atualizar saldo e custo no SB2.

*/
           
// Função Principal do romaneio de saída.
*--------------------------*
  User Function SRomaneio()      
*--------------------------*     

Local  aCores:={}      
Private aRotina:={} 
Private cLeg:="S"    

  If !(cEmpAnt $ "KX/XC")
     MsgInfo("Especifico Veraz"," A T E N C A O ")  
     Return .F.
  Endif    

  DbSelectArea("ZX3")
  DbSetOrder(1)   
  ZX3->(DbGoTop()) 

  aRotina := {{ "Pesquisa"             ,"AxPesqui"   , 0 , 1},;
	          { "Visualizar"           ,"U_SViewXC"  , 0 , 2},;  
	          { "Excluir "             ,"U_SViewXC"  , 0 , 3},;
	          { "Gerar Pedido"         ,"U_SGerarXC" , 0 , 4},;
	          { "Legenda"              ,"U_LegXC"    , 0 , 3} }  
	          
  aCores  := {{ "ZX3_VINC=='N'",'BR_VERDE'   },;	//Romaneio de Saída não vinculado. 
	          { "ZX3_VINC=='G'",'BR_VERMELHO'}}  	//Romaneio Vinculado a nota e com movimentação gerada.		    



   mBrowse(6,1,22,75,"ZX3",,,,,,aCores)	   
   
Return


*--------------------------------------------*
  User Function EViewXC(cAlias,nReg,nOpcx)   	    
*--------------------------------------------*

Local i   
Local cTitulo        :="Romaneio de Entrada"
Local cAliasEnchoice :="ZX1"
Local cAliasGetD     :="ZX2"
Local cLinOk         :="AllwaysTrue()"
Local cTudOk         :="AllwaysTrue()"
Local cFieldOk       :="AllwaysTrue()"			    
Local nOpcE,nOpcG,cAux
            

If nOpcx==2      //Visualização
   nOpcE:=nOpcG:=2
ElseIf nOpcx==3  //Exclusão
   nOpcE:=nOpcG:=3
EndIf   
     
If !(ZX1->ZX1_VINC == "N" .Or. ZX1->ZX1_VINC == "L" ) .And. nOpcE==3
   MsgStop("Esse romaneio não pode ser excluído.","Veraz")
   Return .F.    
EndIf

RegToMemory("ZX1",.F.)

nUsado:=i:=0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ZX2")

aHeader:={}
aCols:={}
	
While !Eof() .And. (X3_ARQUIVO=="ZX2")

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      nUsado++
      Aadd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO  , X3_PICTURE    ,;
	                      X3_TAMANHO, X3_DECIMAL,"AllwaysTrue()",;
    	                  X3_USADO  , X3_TIPO   , X3_ARQUIVO    , X3_CONTEXT } )
   EndIf
   SX3->(DbSkip())
   
EndDo

DbSelectArea("ZX2")
DbSetOrder(1)
DbSeek(xFilial()+M->ZX1_NUM)
	
While !(EOF()) .And. ( ZX2->ZX2_NUM == M->ZX1_NUM  )

   Aadd(aCols,Array(nUsado+1))
   For i:=1 to nUsado
      aCols[Len(aCols),i]:=FieldGet(FieldPos(aHeader[i,2]))
   Next 
   aCols[Len(aCols),nUsado+1]:=.F.
  
   ZX2->(DbSkip())

EndDo    


If nOpcx==3
   If MsgNoYes("Deseja realmente excluir","Veraz")
      cAux:=ZX1->ZX1_NUM 
      RecLock("ZX1",.F.)                    
      DbDelete()
      ZX1->(MsUnlock()) 
              
      ZX2->(DbSetOrder(1))  
      If ZX2->(DbSeek(xFilial("ZX2")+cAux)) 
         While ZX2->(!Eof()) .And. cAux==ZX2->ZX2_NUM 
            RecLock("ZX2",.F.)                    
            DbDelete()
            ZX2->(MsUnlock()) 
            
            ZX2->(DbSkip())  
         EndDo
      EndIF                              
   EndIf
   
   ZX1->(DbGoTop())
   
   Return .F.

EndIf
  
If Len(aCols)>0                                                                                                                                  //Lin Col lin Col   Cab
   Modelo3(cTitulo ,cAliasEnchoice,cAliasGetD ,     ,cLinOk  ,cTudOk ,nOpcE,nOpcG,cFieldOk,         ,        ,              ,          ,         ,{121,102,750,1400},250 )   
          //cTitulo,cAlias        ,cAlias2    ,aMy  ,cLinhaOk,cTudoOk,nOpcE,nOpcG,cFieldOk, lVirtual, nLinhas, aAltEnchoice , nFreeze , aButtons ,aCordW, nSizeHeader) 
EndIf   


Return     

*--------------------------------------------*
  User Function SViewXC(cAlias,nReg,nOpcx)   	    
*--------------------------------------------*

Local i   
Local cTitulo        :="Romaneio de Saída"
Local cAliasEnchoice :="ZX3"
Local cAliasGetD     :="ZX4"
Local cLinOk         :="AllwaysTrue()"
Local cTudOk         :="AllwaysTrue()"
Local cFieldOk       :="AllwaysTrue()"
Local cNum,cDelivery			    
Local nOpcE,nOpcG,cAux
            

If nOpcx==2      //Visualização
   nOpcE:=nOpcG:=2
ElseIf nOpcx==3  //Exclusão
   nOpcE:=nOpcG:=3
EndIf   
     
If ZX3->ZX3_VINC <> "N"  .And. nOpcE==3
   MsgStop("Esse romaneio não pode ser excluído.","Veraz")
   Return .F.    
EndIf

RegToMemory("ZX3",.F.)

nUsado:=i:=0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ZX4")

aHeader:={}
aCols:={}
	

While !Eof() .And. (X3_ARQUIVO=="ZX4")

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      nUsado++
      Aadd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO  , X3_PICTURE    ,;
	                      X3_TAMANHO, X3_DECIMAL,"AllwaysTrue()",;
    	                  X3_USADO  , X3_TIPO   , X3_ARQUIVO    , X3_CONTEXT } )
   EndIf
   SX3->(DbSkip())
   
EndDo
   
cNum:=M->ZX3_NUM
cDelivery:=Alltrim(M->ZX3_DLRY)


DbSelectArea("ZX4")
DbSetOrder(1)
DbSeek(xFilial()+cNum+cDelivery)
	
While !(EOF()) .And. ( Alltrim(ZX4->ZX4_NUM)+Alltrim(ZX4->ZX4_DLRY) == Alltrim(cNum)+Alltrim(cDelivery))

   Aadd(aCols,Array(nUsado+1))
   For i:=1 to nUsado
      aCols[Len(aCols),i]:=FieldGet(FieldPos(aHeader[i,2]))
   Next 
   aCols[Len(aCols),nUsado+1]:=.F.
  
   ZX4->(DbSkip())

EndDo    


If nOpcx==3
   If MsgNoYes("Deseja realmente excluir","Veraz")
      cAux:=ZX3->ZX3_NUM+ZX3->ZX3_DLRY 
      RecLock("ZX3",.F.)                    
      DbDelete()
      ZX3->(MsUnlock()) 
              
      ZX4->(DbSetOrder(1))  
      If ZX4->(DbSeek(xFilial("ZX4")+cAux)) 
         While ZX4->(!Eof()) .And. cAux==ZX4->ZX4_NUM+ZX4->ZX4_DLRY 
            
            RecLock("ZX4",.F.)                    
            DbDelete()
            ZX4->(MsUnlock()) 
            
            ZX4->(DbSkip())  
         EndDo
      EndIF                              
   EndIf
   
   ZX3->(DbGoTop())
   
   Return .F.

EndIf
  
If Len(aCols)>0                                                                                                                                  //Lin Col lin Col   Cab
   Modelo3(cTitulo ,cAliasEnchoice,cAliasGetD ,     ,cLinOk  ,cTudOk ,nOpcE,nOpcG,cFieldOk,         ,        ,              ,          ,         ,{121,102,750,1400},250 )   
          //cTitulo,cAlias        ,cAlias2    ,aMy  ,cLinhaOk,cTudoOk,nOpcE,nOpcG,cFieldOk, lVirtual, nLinhas, aAltEnchoice , nFreeze , aButtons ,aCordW, nSizeHeader) 
EndIf   


Return

*-----------------------------* 
  User Function LegXC()
*-----------------------------*

Local aCores := {}    
                
If cLeg == "E" //Entrada  
   
   aCores := {{"BR_VERDE"   ,"Aberto"},;  
              {"BR_AMARELO" ,"Vinculado a nota fiscal"},; 
              {"BR_BRANCO"  ,"Pre-Nota não gerada"},;    
              {"BR_VERMELHO","Gerado Movimentação ou Pre-Nota"}} 
     
   BrwLegenda("Veraz","Legenda",aCores) 
   
Else  //Saída
   aCores := {{"BR_VERDE"   ,"Aberto"},;  
              {"BR_VERMELHO","Gerado Pedido"}} 
     
   BrwLegenda("Veraz","Legenda",aCores)  

EndIf
   

Return .T.   

// Prepara para gerar movimentação e atualização de saldo e custo.
*-----------------------------* 
  User Function EGerarXC()
*-----------------------------*

Local nUsado:=nAux:=0  
Local aStruct
Local oDlg,cNum,oCbxOrd
Local n:=1
Local cNota,cSerie,cFornece,cSerie,cRomaneio
Local cNotaGet   :=Space(9)  
Local cSerieGet  :="  3" 
Local cEspecieGet:="SPED " //Space(5)
Local cFormul:=""   
Local lTemSistema:=.F.
 
Private lRet:=lRefresh:=.T.   
Private aHeader,aTot,aDivSaldo,aDivVal
Private oGetDb,olbx,olbx1,olbx2
Private aHeader,aCols
Private nTotSD1:=nNrItens:=nNrSistemas:=0  
Private nTotRomaneio:=0
Private cSistema
Private cLog:=cTitulo:=""
Private aSistema:={}
Private aNsistema:={} 
Private lFirst:=lProbDesm:=lProbArm:=.T.
Private lSaida:=lOk:=.F.
Private nCol:=950       
Private cBar:="___________________"
Private aComboBOx := {"SIM","NAO"}    

                                                 
//ZX1 -Capa do Romaneio de entrada
//ZX2 -Item do Romaneio de entrada

// ZX1_VINC="L" e ZX1_ORIGEM="LOC"  Romaneio veraz local aberto ( não gerado PRE-NOTA ) 
// ZX1_VINC="G" e ZX1_ORIGEM="LOC"  Romaneio veraz local gerado PRE-NOTA    

// ZX1_VINC="N" e ZX1_ORIGEM="IMP"  Romaneio veraz Israel aberto ( sem vinculo com nota de entrada ) 
// ZX1_VINC="V" e ZX1_ORIGEM="IMP"  Romaneio veraz Israel vinculado a um nota de entrada ( Importação ) 
// ZX1_VINC="G" e ZX1_ORIGEM="IMP"  Romaneio veraz Israel vinculado a um nota de entrada e com movimentação gerada - desmembramento de item.
     
          
     If cEmpAnt $ "KX/XC"   

        aHeader      :={}
        aStruct      :={}   
        aTot         :={}
        aDivSaldo    :={} 
        aDivVal      :={}
        cNum         :=ZX1->ZX1_NUM
    
        DbSelectArea("SX3")
        DbSetOrder(1)
        DbSeek("ZX2")       
                      
        If ZX1->ZX1_VINC <> 'G'  //Não foi gerado
           If ZX1->ZX1_ORIGEM=="IMP" .And. Alltrim(ZX1->ZX1_NOTA) == ""  
              If MsgNoYes("Importação possui sistemas para desmembrar ?","Veraz")        
                 lTemSistema:=.T.  
              EndIf
           EndIf
        EndIf
        
        If Alltrim(ZX1->ZX1_NOTA) == ""  .And.  ZX1->ZX1_ORIGEM<> "LOC"  .And.  lTemSistema
           MsgStop("Para desmontar Sistemas Romaneio deve estar vinculado a nota fiscal de entrada vinculada","Veraz")
           Return .F.   
        EndIf
                            
        // Compra Local - geração da pre nota  ou importação não possui sistemas, gerado Pre-Nota de componentes                   
        If ZX1->ZX1_ORIGEM=="LOC" .Or.  !(lTemSistema)
        
           If Alltrim(ZX1->ZX1_NOTA) <>  ""
           
              MsgStop("Romaneio já possui PRE-NOTA gerada.","Veraz")
              Return .F.
           
           EndIf    
                     
           cNotaGet:= StrZero(NumNfE(),9)    
                 
                                          
           DEFINE MSDIALOG oDlg TITLE "Dados da  NF" FROM 000,000 TO 140,235 PIXEL    //235
              
              @ 5    , 5  Say  "Informe os dados para PRE-NOTA. "            PIXEL SIZE 150,6 OF oDlg  
           
              @ 15   , 5  Say  "Nota Fiscal : "        PIXEL SIZE 20,6 OF oDlg  
              @ 15   , 35 Get  cNotaGet                PIXEL SIZE 9,6 OF oDlg      
              @ 27   , 5  Say  "Serie : "              PIXEL SIZE 80,6 OF oDlg  
              @ 27   , 35 Get  cSerieGet               PIXEL SIZE 1,1  OF oDlg 
              @ 28   , 60 Say  "Form. Proprio:"          PIXEL SIZE 40,40 OF oDlg     
              @ 38   , 75 COMBOBOX  cFormul ITEMS aComboBOx PIXEL Size 25,6  OF oDlg         
              @ 39   , 5  Say  "Especie : "            PIXEL SIZE 80,6 OF oDlg  
              @ 39   , 35 Get  cEspecieGet   F3 "42"   SIZE 10,6      

                                              
              @ 52,20 BUTTON "Cancel" size 40,15 ACTION Processa({|| oDlg:End(),lSaida:=.T.}) of oDlg Pixel             
              @ 52,60 BUTTON "OK"     size 40,15 ACTION Processa({|| oDlg:End(),lSaida:=.F.}) of oDlg Pixel  
           
           Activate MSDIALOG oDlg Centered 
           
           If lSaida
              Return .F.
           EndIf
           
           If Empty(cNotaGet)
              MsgStop("Nota inválida","Veraz")                          
              Return .F.           
           EndIf     
           
           If Empty(cSerieGet)
              cSerieGet:="   "   
           EndIf 
           
           If cFormul =="SIM"
              cFormul:="S"         
           Else
              cFormul:=" " 
           EndIf
                                           
           If  Valida_NFE(cNotaGet,cSerieGet,cFormul) <> " "   
              MsgStop("Numero + Serie existente no sistema","Veraz")                          
              Return .F.
           Else     
              
              RecLock("SF1",.T.)
              SF1->F1_FILIAL     := xFilial("SF1")
              SF1->F1_TIPO       := ZX1->ZX1_TIPO
              SF1->F1_DOC        := cNotaGet
              SF1->F1_SERIE      := cSerieGet
              SF1->F1_FORNECE    := ZX1->ZX1_FORNEC
              SF1->F1_LOJA       := ZX1->ZX1_LOJA
              SF1->F1_EMISSAO    := ZX1->ZX1_DATA
              SF1->F1_EST        := ZX1->ZX1_ESTADO
              SF1->F1_DTDIGIT    := date()
              SF1->F1_ESPECIE    := cEspecieGet 
              SF1->F1_FORMUL     := cFormul              
              SF1->(MsUnlock())
              
              RecLock("ZX1",.F.)
              ZX1->ZX1_VINC  :="G"
              ZX1->ZX1_NOTA  :=cNotaGet  
              ZX1->ZX1_SERIE :=cSerieGet
              ZX1->ZX1_DT_NF :=date()
              ZX1->(MsUnlock())
              
                        
              ZX2->(DbSeek(xFilial("ZX2")+ZX1->ZX1_NUM))                               
              While ZX2->(!EOF()) .And. ZX1->ZX1_NUM==ZX2->ZX2_NUM    
                 
                 RecLock("SD1",.T.) 
                 SD1->D1_FILIAL  := xFilial("SD1")                
                 SD1->D1_ITEM    := "0"+ZX2->ZX2_ITEM          
                 SD1->D1_COD     := ZX2->ZX2_PRODUT 
                 SD1->D1_LOCAL   := ZX2->ZX2_LOCAL
                 SD1->D1_UM      := ZX2->ZX2_UM 
                 SD1->D1_QUANT   := ZX2->ZX2_QTD
                 SD1->D1_VUNIT   := ZX2->ZX2_PRECUN
                 SD1->D1_TOTAL   := ZX2->ZX2_TOTAL  
                 SD1->D1_DOC     := cNotaGet 
                 SD1->D1_SERIE   := cSerieGet
                 SD1->D1_FORNECE := ZX1->ZX1_FORNEC
                 SD1->D1_LOJA    := ZX1->ZX1_LOJA  
                 SD1->D1_EMISSAO := ZX1->ZX1_DATA
                 SD1->D1_DTDIGIT := date()
                 SD1->D1_TIPO    := ZX1->ZX1_TIPO 
                 
                 SB1->(DbSetOrder(1))
		         If SB1->(DbSeek(xFilial("SB1")+ZX2->ZX2_PRODUT))
		            SD1->D1_TP     := SB1->B1_TIPO
		         EndIf 
		         
		         RecLock("ZX2",.F.)
                 ZX2->ZX2_NOTA  :=cNotaGet  
                 ZX2->ZX2_SERIE :=cSerieGet
                 ZX2->ZX2_DT_NF :=date()    
                 ZX2->ZX2_QTD_U :=SD1->D1_QUANT 
                 ZX2->ZX2_QTD_D :=SD1->D1_QUANT  
                 ZX2->(MsUnlock())

                 SD1->(MsUnlock())
                 ZX2->(DbSkip())  
                 
              EndDo
              
              MsgAlert("PRE-NOTA gerada com suscesso.","Veraz")
              Return .F. 
                         
           EndIf
        EndIf 
        
        
        While !Eof() .And. (SX3->X3_ARQUIVO=="ZX2")

           If X3USO(x3_usado).And.cNivel>=x3_nivel 
              
              nUsado++
              Aadd(aHeader,{ Substr(Alltrim(X3_TITULO),1,10),X3_CAMPO ,X3_PICTURE,X3_TAMANHO, X3_DECIMAL,"","", X3_TIPO   ,""   ,""} )   
    	      Aadd(aStruct,{ SX3->X3_CAMPO,SX3->X3_TIPO , SX3->X3_TAMANHO, SX3->X3_DECIMAL})                          

           EndIf
     
           SX3->(DbSkip())
     
        EndDo           
        
        Aadd(aStruct,{"FLAG","L",1,0})
        Aadd(aStruct,{"nRecno"      ,"N",3   ,0}) 
        Aadd(aStruct,{"ZX2_LastU"      ,"N",11  ,2})
        Aadd(aStruct,{"ZX2_LastS"      ,"N",11  ,2})
        Aadd(aStruct,{"ZX2_LastD"      ,"N",11  ,2})
       
        cNome:=CriaTrab(aStruct,.T.)                     
        DbUseArea(.T.,"DBFCDX",cNome,'Work',.F.,.F.)
        
        Indice1:=E_Create(,.F.)
        IndRegua("Work",Indice1+OrdBagExt(),"Work->ZX2_NUM+Work->ZX2_PRODUT")   
        
        Indice2:=E_Create(,.F.)
        IndRegua("Work",Indice2+OrdBagExt(),"nRecno")   
      
        SET INDEX TO (Indice1+OrdBagExt()),(Indice2+OrdBagExt())           
                     
        
        DbSelectArea("ZX2")
        ZX2->(DbSetOrder(1))  
                       
        DbSelectArea("WORK")
                    
        
        ZX2->(DbSeek(xFilial("ZX2")+ZX1->ZX1_NUM))                               
           
        While ZX2->(!EOF()) .And. ZX1->ZX1_NUM==ZX2->ZX2_NUM    
              
           RecLock("Work",.T.)  
           Work->ZX2_ITEM   :=ZX2->ZX2_ITEM    
           Work->ZX2_NUM    :=ZX2->ZX2_NUM
           Work->ZX2_PRODUT :=ZX2->ZX2_PRODUT
           Work->ZX2_PROD_D :=ZX2->ZX2_PROD_D  
           Work->ZX2_QTD    :=ZX2->ZX2_QTD 
           Work->ZX2_UM     :=ZX2->ZX2_UM
           Work->ZX2_NOTA   :=ZX2->ZX2_NOTA
           Work->ZX2_SERIE  :=ZX2->ZX2_SERIE  
           Work->ZX2_PRECUN :=0
           Work->ZX2_TOTAL  :=0  
           Work->ZX2_QTD_U  :=0 
           Work->ZX2_LastU  :=ZX2->ZX2_QTD 
           Work->ZX2_LastS  :=ZX2->ZX2_QTD 
           Work->ZX2_LastD  :=0
           Work->ZX2_SALDO  :=ZX2->ZX2_QTD    
           Work->ZX2_LOCAL  :=""  
           Work->ZX2_DT_NF  :=ZX2->ZX2_DT_NF 
           Work->ZX2_TIPO   :=ZX2->ZX2_TIPO 
           Work->ZX2_DESM   :=""
           
           nRecno           := n 
           Work->(MsUnlock()) 
           
           nNrItens++  
                         
           ZX2->(DbSkip()) 
           
        EndDo  
        
        cNota    :=Work->ZX2_NOTA
        cSerie   :=Work->ZX2_SERIE
        cRomaneio:=Work->ZX2_NUM
              
        SD1->(DbSetOrder(1))
        
        If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie))  
           
           cFornece :=SD1->D1_FORNECE
           cLoja    :=SD1->D1_LOJA
        
           While SD1->(!EOF()) .And. SD1->D1_DOC+SD1->D1_SERIE==cNota+cSerie 
           
              If !Empty(SD1->D1_P_PACK)
                 
                 cSistema:=Alltrim(SD1->D1_COD)+Alltrim(SD1->D1_ITEM)  //Chave, caso existe dois sistemas iguais no SD1        
                 
                 nNrSistemas++         
                 
                 Work->(DbGoTop())  
                 Work->(DbSetOrder(0))  
                 
                 If Work->(EOF()) // Se não tiver itens na work, houve erro de saldo no desmembramento pelo usuário.       
                    MsgAlert("Utilizado saldo de todos os componentes, existe sistemas sem componentes","Veraz")              
                 EndIf
                 
                 cTitulo:="Romaneio Entrada "+Alltrim(SD1->D1_P_PACK)+"    NF: "+Alltrim(SD1->D1_DOC)+ " Serie: "+Alltrim(SD1->D1_SERIE)+"        " 
                    
                 DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 450,nCol PIXEL
         
                 oGetDB:= MsGetDB():New(5,;//1
                                        5,;//2
                                      175,;//3
                                      470,;//4
                                        4,;//5
	                          "U_E_Valid",;//06
                                         ,;//07
                                         ,;//08
                                      .F.,;//09 - Habilita exclusão
                                         ,;//10 - Vetor cps Alteração
                                        1,;//11
                                      .T.,;//12
                                         ,;//13
                                   "Work",;//14
                                         ,;//15
                                      .F.,;//16
                                         ,;//17
                                     oDlg,;//18
                                      .T.,;//19
                                      .F.,;//20
                                        ,;//21
                                        ) //22     
                                        
                                     
                 //oGetDb:oBrowse:bWhen:={||oGetDb:oBrowse:Refresh(),dbSelectArea("WORK"),.T.}    
                                   
                 //Monta tela de sistema lateral
                 If !(lFirst)
                 
                    @ 5,473 ListBox olbx FIELDS HEADER "TIPO","COD","QTD","Unitário","R$ TOTAL","CUSTO" COLSIZES 35,35,18,30,38,35 SIZE 216,170 of ODLG PIXEL
                    olbx:SetArray(aSistema)
                    olbx:bLine:={|| {aSistema[olbx:nAt,1],aSistema[olbx:nAt,2],aSistema[olbx:nAt,3],aSistema[olbx:nAt,4],aSistema[olbx:nAt,5],aSistema[olbx:nAt,6]}} 
                    
                    @ 180,473 TO 210,699  LABEL "" OF oDlg PIXEL 
                                 
                 EndIf
        
                 oFont := TFont():New('Courier new',,-14,.T.)
                 oTMsgBar := TMsgBar():New(oDlg, '  HLB BRASIL',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)   
                 oTMsgItem1 := TMsgItem():New( oTMsgBar,CVERSAO, 100,,,,.T.,{||})
                 oTMsgItem2 := TMsgItem():New( oTMsgBar,SM0->M0_NOME, 100,,,,.T., {||})   
                                                                           
                 @ 187   , 010 Say  "SISTEMA :"       PIXEL SIZE 80,6 OF oDlg 
                 @ 187   , 045 Say  Alltrim(SD1->D1_COD)         COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg           
                 @ 187   , 115 Say  "Quatidade:"           PIXEL SIZE 80,6 OF oDlg  
                 @ 187   , 150 Say  SD1->D1_QUANT   Picture "@E 999,999.99"     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg          
                 @ 197   , 010 Say  "Valor Unitário R$ :"    PIXEL SIZE 80,6 OF oDlg 
                 @ 197   , 060 Say  SD1->D1_VUNIT   Picture "@E 999,999.99"     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
                 @ 197   , 115 Say  "Valor Total R$ :"       PIXEL SIZE 80,6 OF oDlg  
                 @ 197   , 160 Say  SD1->D1_TOTAL   Picture "@E 999,999.99"     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg 
                 @ 187   , 210 Say  "Custo Unitário R$ :"             PIXEL SIZE 80,6 OF oDlg  
                 @ 187   , 260 Say  SD1->D1_CUSTO/SD1->D1_QUANT   Picture "@E 999,999.99"     COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg                    
                 @ 197   , 210 Say  "Custo Total R$ :"             PIXEL SIZE 80,6 OF oDlg  
                 @ 197   , 260 Say  SD1->D1_CUSTO   Picture "@E 999,999.99"     COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg              
         
         
                 @ 180,005 TO 210,470  LABEL "" OF oDlg PIXEL 
        
             //  @ 190,410 BUTTON "Conferecia" size 40,15 ACTION Processa({|| Confere(Work->ZX2_NOTA,Work->ZX2_SERIE),oGetDb:ForceRefresh()}) of oDlg Pixel  
                 @ 190,385 BUTTON "Cancel" size 40,15 ACTION Processa({|| oDlg:End(),lSaida:=.T.}) of oDlg Pixel  
                 @ 190,425 BUTTON "Next"      size 40,15 ACTION Processa({|| lRet:=NextSist(),oDlg:End()}) of oDlg Pixel    
                              

                 Activate MSDIALOG oDlg Centered    
                                
                 If lSaida 
                    Work->(DbCloseArea())
                    Return .F.
                 EndIf 
                 
                 If !(lProbDesm) 
                    MsgAlert("Desmonta S/N deve ser preenchido para todos os itens.")
                    loop
                 EndIf  
                 
                 If !(lProbArm)
                    MsgAlert("Armazem deve ser preenchido para todos os itens.")
                    loop
                 EndIf
                 
                 If !(lRet)
                    MsgAlert("Problema com valor ou preço de um(s) item(s), verificar.") 
                    loop
                 EndIf

                 If lFirst
                    lFirst:=.F.
                 EndIf
                 
                 lOk:=.T.    
                                                     
              EndIf  
                  
              SD1->(DbSkip())
                 
           EndDo 
           
           If lOk           
              
              //Totaliza o custo da  nota
              SD1->(DbSetOrder(1))
              If SD1->(DbSeek(xFilial("SD1")+cNota+cSerie))     
                 While SD1->(!Eof()) .And. SD1->D1_DOC==cNota .And. SD1->D1_SERIE==cSerie 
                    If !Empty(SD1->D1_P_PACK)
                       nTotSD1+=SD1->D1_CUSTO 
                    EndIf                         
                    SD1->(DbSkip())
                 EndDo  
              Else  
                 MsgAlert("Nota fiscal não encontrada para ser totalizada","Veraz")    
              EndIf
              
                                  
              //Totaliza a Work - Romaneio 
              Work->(DbGoTop())  
              While Work->(!EOF())  
                 If Work->ZX2_QTD <> Work->ZX2_QTD_U //Checa se toda quantidade foi utilizada
                    nAux:= Work->ZX2_QTD - Work->ZX2_QTD_U     
                    If nAux == Work->ZX2_SALDO // Testa novamente a quantidade 
                       Aadd(aDivSaldo,{Work->ZX2_PRODUT,"Saldo disponivel",nAux}) // Adiciona o Total ao final de cada Sistema 
                       Aadd(aDivSaldo,{cBar,cBar,cBar+cBar}) // Adiciona linha em branco     
                    Else 
                       Aadd(aDivSaldo,{Work->ZX2_PRODUT,"Quantidade usada x saldo, divergente","Refazer o desmembramento"}) // Adiciona o Total ao final de cada Sistema 
                       Aadd(aDivSaldo,{cBar,cBar,cBar+cBar}) // Adiciona linha em branco                  
                    EndIf
                 Else 
                    Aadd(aDivSaldo,{"Ok","Nenhum produto com problema ","   ------  "}) // Adiciona o Total ao final de cada Sistema 
                 EndIf
                 Work->(DbSkip())   
              EndDo
                   
              If Empty(aDivSaldo) // Quando o saldo total do item é utilizado ele não faz mas parte da Work.
                 Aadd(aDivSaldo,{"Ok","Nenhum produto com problema ","   ------  "})
              EndIf    
              
              If Empty(aDivVal) // Quando o saldo total do item é utilizado ele não faz mas parte da Work.
                 Aadd(aDivVal ,{"Ok","  ---  ","  ---  ","  ---  ","  ---  "}) 
              EndIf    
                      
              //MONTA TELA FINAL 
           
              DEFINE MSDIALOG oDlg1 TITLE cTitulo FROM 000,000 TO 450,nCol-140 PIXEL  
                                                                                    
                 @ 5,5 TO 225,265  LABEL "Estrutura Sistemas x Componentes" OF oDlg1 PIXEL 
           
                 @ 12,10 ListBox olbx FIELDS HEADER "Tipo","Código","QTD","Valor unitário","Valor Total"," CUSTO" COLSIZES 40,60,17,42,40 SIZE 250,208 of oDlg1 PIXEL
                 olbx:SetArray(aSistema)
                 olbx:bLine:={|| {aSistema[olbx:nAt,1],aSistema[olbx:nAt,2],aSistema[olbx:nAt,3],aSistema[olbx:nAt,4],aSistema[olbx:nAt,5],aSistema[olbx:nAt,6]}}   
                 
                 @ 5,270 TO 180,390  LABEL "Dados do Romaneio e Nota Fiscal" OF oDlg1 PIXEL   
                                 
                 @ 20    , 275 Say  "ROMANEIO : "               PIXEL SIZE 80,6 OF oDlg  
                 @ 20    , 349 Say  cRomaneio   Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1     
                 @ 30    , 275 Say  "QTD COMPONENTES  : "       PIXEL SIZE 80,6 OF oDlg  
                 @ 30    , 349 Say  nNrItens                    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1 
                 @ 40    , 275 Say  "TOTAL CUSTO COMP.: "       PIXEL SIZE 80,6 OF oDlg  
                 @ 40    , 349 Say  nTotRomaneio    Picture "@E 999,999.99" COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1                                       
                 @ 70    , 275 Say  "NOTA FISCAL : "            PIXEL SIZE 80,6 OF oDlg  
                 @ 70    , 349 Say  cNota       Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1      
                 @ 80    , 275 Say  "SERIE : "                  PIXEL SIZE 80,6 OF oDlg  
                 @ 80    , 349 Say  cSerie      Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1     
                 @ 90    , 275 Say  "FORNECEDOR :"              PIXEL SIZE 80,6 OF oDlg  
                 @ 90    , 349 Say  cFornece    Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1      
                 @ 100   , 275 Say  "LOJA : "                   PIXEL SIZE 80,6 OF oDlg  
                 @ 100   , 349 Say  cLoja       Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1     
                 @ 110   , 275 Say  "QTD SISTEMAS: "            PIXEL SIZE 80,6 OF oDlg  
                 @ 110   , 349 Say  nNrSistemas Picture "@!"    COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1  
                 @ 120   , 275 Say  "TOTAL CUSTOS: "            PIXEL SIZE 80,6 OF oDlg  
                 @ 120   , 349 Say  nTotSD1 Picture "@E 999,999.99"   COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 60,6 OF oDlg1  
                 
                 @ 5,395 TO 110,622  LABEL "Divergências do desmembramento" OF oDlg1 PIXEL        
                 
                 @ 12,399 ListBox olbx1 FIELDS HEADER "Produto","Problema","Quantidade" COLSIZES 35,50,25 SIZE  221,95 of oDlg1 PIXEL
                 olbx1:SetArray(aDivSaldo)
                 olbx1:bLine:={|| {aDivSaldo[olbx1:nAt,1],aDivSaldo[olbx1:nAt,2],aDivSaldo[olbx1:nAt,3]}}  
                 
                 @ 116,395 TO 225,622  LABEL "Divergências de valores" OF oDlg1 PIXEL 
                 
                 @ 123,399 ListBox olbx2 FIELDS HEADER "Sistema","Vlr. Sistema"," ","Vlr. Componente","Divergência" COLSIZES 45,40,3,44,35 SIZE 221,96 of oDlg1 PIXEL
                 olbx2:SetArray(aDivVal)
                 olbx2:bLine:={|| {aDivVal[olbx2:nAt,1],aDivVal[olbx2:nAt,2],aDivVal[olbx2:nAt,3],aDivVal[olbx2:nAt,4],aDivVal[olbx2:nAt,5]}}  
                 
                 @ 185,270 TO 225,390  LABEL "" OF oDlg1 PIXEL
                 
                 @ 197,290 BUTTON "Cancel" size 40,15 ACTION Processa({|| oDlg1:End(),lSaida:=.T.}) of oDlg1 Pixel  
                 @ 197,330 BUTTON "Gera"      size 40,15 ACTION Processa({|| lRet:=GeraMov(cNum), ;
                                                                  If(lRet,oDlg1:End(),)}) of oDlg1 Pixel   
                                                             
              Activate MSDIALOG oDlg1 Centered    
           
              //EECVIEW(cLog,"Detalhes da atualização")
           
           Else
              Alert("Romaneio não encontrado","Veraz") 
           EndIf
           
        Else 
           Alert("Nota não encontrada","Veraz")                   
        EndIf
        
        
        Work->(DbCloseArea())
  
     EndIf      
  
Return  
 
// Atualiza total da Work 
*----------------------------*
   User Function E_Valid()                                                                                              
*----------------------------*   
 
local lRet:=.T.     
      
 If Work->ZX2_SALDO < 0    
    MsgStop("Saldo não pode ser negativo") 
    lRet:=.F. 
 EndIf  
 
 If Work->ZX2_QTD_D <> 0 .And. Work->ZX2_PRECUN==0
    MsgStop("Valor UNITARIO deve ser preenchido quando a QUANTIDADE estiver preenchida") 
    lRet:=.F.      
 EndIf 
 
 If Alltrim(Work->ZX2_LOCAL) == "" 
    MsgStop("Informar o Armazem do item : "+Alltrim(Work->ZX2_PRODUT)) 
    lRet:=.F.      
 EndIf 
 
 If  Alltrim(Work->ZX2_DESM) == "" 
    MsgStop("Informar se desmonta SIM ou NAO para o item : "+Alltrim(Work->ZX2_PRODUT)) 
    lRet:=.F.      
 EndIf     
 
  RecLock("Work",.F.)
  Work->ZX2_PRECUN :=Work->ZX2_PRECUN 
  Work->ZX2_TOTAL  :=Work->ZX2_PRECUN*Work->ZX2_QTD_D  
  Work->ZX2_QTD_D  :=Work->ZX2_QTD_D
  Work->ZX2_LOCAL  :=Work->ZX2_LOCAL  
  Work->ZX2_DESM   :=Work->ZX2_DESM   
  Work->(MsUnlock())
                                                
Return .T.	 

*----------------------------*
  User Function XC_SALDO()
*----------------------------* 
             
Local nSaldo,nDif,nPos

/*Controle de quantidade digitada x Saldo x Utilizada   

Work->ZX2_QTD   :Quantidade original 
Work->ZX2_QTD_D :Digitada pelo usuário
Work->ZX2_QTD_U :Quantidade já utilizada

Campos auxiliares.        

Work->ZX2_LastU :Ultima quantidade utilizada    
Work->ZX2_LastD :Ultima quantidade digitada
Work->ZX2_LastS :Ultima quantidade de saldo

 */ 
 
If lFirst
   
   //Se a quantidade maior que 0, o campo observação guarda o histórico do item.
   If Work->ZX2_QTD_D > 0    
      Work->ZX2_OBS    :=cSistema
   EndIf
     
   //Valida a quantidade digitada.                       
   If Work->ZX2_QTD_D > 0 
      If Work->ZX2_QTD_D <= Work->ZX2_QTD
          Work->ZX2_QTD_U  :=Work->ZX2_QTD_D
      Else
          MsgStop("Quantidade informada não pode ser maior que a inicial.") 
      EndIf
   EndIf
   
   //Caso a quantidade seja zero, o historico no campo OBS é limpo.
   If Work->ZX2_QTD_D == 0 
      Work->ZX2_QTD_U :=0
      Work->ZX2_PRECUN:=0 
      Work->ZX2_TOTAL :=0 
      nPos:=At(cSistema,Alltrim(Work->ZX2_OBS))
      Work->ZX2_OBS:=Stuff(Work->ZX2_OBS,nPos,Len(cSistema),"")       
   EndIf
   
   //Valida a quantidade digitada.
   If Work->ZX2_QTD-Work->ZX2_QTD_D < 0 
      nSaldo :=Work->ZX2_QTD
      Work->ZX2_QTD_D  :=0     
      Work->ZX2_TOTAL  :=0 
      Work->ZX2_PRECUN :=0
      MsgStop("Saldo não pode ser negativo")  
   Else
      nSaldo :=Work->ZX2_QTD-Work->ZX2_QTD_D 
   EndIf 
          
Else   
   //Valida a quantidade digitada.
   If Work->ZX2_SALDO-Work->ZX2_QTD_D < 0 
      nSaldo := Work->ZX2_SALDO  
      Work->ZX2_QTD_D:=0
      MsgStop("Saldo não pode ser negativo")
   Else 
      //Verifica se o item atual já foi alterado
      If cSistema $ Alltrim(Work->ZX2_OBS)  
      
         Work->ZX2_SALDO:=Work->ZX2_LastS

         nSaldo :=Work->ZX2_SALDO-Work->ZX2_QTD_D
         Work->ZX2_QTD_U:= Work->ZX2_QTD-Work->ZX2_SALDO    
      
         If nSaldo < 0 
            MsgStop("Saldo não pode ser negativo")
            Work->ZX2_QTD_D:=0
         Else            
            Work->ZX2_LastU:=Work->ZX2_QTD_U    
            Work->ZX2_LastD:=Work->ZX2_QTD_D 
            Work->ZX2_LastS:=Work->ZX2_SALDO               
         EndIf  
         
         If Work->ZX2_QTD_D==0
            Work->ZX2_PRECUN:=0 
            Work->ZX2_TOTAL :=0
            nPos:=At(cSistema,Alltrim(Work->ZX2_OBS))               
            
            Work->ZX2_OBS:=Stuff(Work->ZX2_OBS,nPos,Len(cSistema),"")       
         EndIf 
      
      Else  
      
         //Guarda os últimos valores antes de atualizar novamente os campos.
         Work->ZX2_LastU:=Work->ZX2_QTD_U    
         Work->ZX2_LastD:=Work->ZX2_QTD_D 
         Work->ZX2_LastS:=Work->ZX2_SALDO
         
         nSaldo :=Work->ZX2_SALDO-Work->ZX2_QTD_D
         Work->ZX2_QTD_U  := Work->ZX2_QTD_U+Work->ZX2_QTD_D
         Work->ZX2_OBS    :=Alltrim(Work->ZX2_OBS)+"/"+cSistema 

         If nSaldo < 0 
            MsgStop("Saldo não pode ser negativo")
            Work->ZX2_QTD_D :=0 
            Work->ZX2_PRECUN:=0
            Work->ZX2_TOTAL :=0
         EndIf   
      
      EndIf   
           
   EndIf   
     
EndIf      

Return nSaldo
                  
*----------------------------*
  Static Function NextSist()
*----------------------------* 
                                      
Local nTotal:=0
Local lRet  :=.F. 
Local cCusto:=0             

   If Work->(EOF()) // Se não tiver itens na work, houve erro de saldo no desmembramento pelo usuário.       
      MsgStop("Necessário refazer o desmembramento.","Veraz") 
      Return .F.             
   EndIf
  
   Work->(DbGoTop())  
   While Work->(!EOF())   //Valida se o valor foi preenchido. 
      If (Work->ZX2_QTD_D <>0 .And. Work->ZX2_PRECUN<>0)   // Checa se pelo menos um dos itens tem quantidade e valor unitário
         lRet:=.T.  
         Exit    
      EndIf            
      
      If lFirst  // Na tela inicial todos os itens devem ser preenchidos.
         If Alltrim(Work->ZX2_DESM) == ""
            lProbDesm:=.F.
         EndIf  
      EndIf
      
       // Todos os armazens devem ser preenchidos.
      If Alltrim(Work->ZX2_LOCAL) ==""  
         lProbArm:=.F.
      EndIf        
  
      Work->(DbSkip())   
   
   EndDo   

   If lRet 
                                                                                                          
                    //   TIPO ,              CODIGO,          QTD,      VLR UNI,      VLR TOT,        CUSTO,        ITEM,        EMISSAO,		 UM	     Armazem
      Aadd(aSistema,{"Sistema",Alltrim(SD1->D1_COD),SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_TOTAL,SD1->D1_CUSTO,SD1->D1_ITEM,SD1->D1_EMISSAO,SD1->D1_UM,SD1->D1_LOCAL}) 

      Work->(DbGoTop())  
     
      While Work->(!EOF()) 
           
         If lFirst
      
            If Work->ZX2_DESM=="2" 
               RecLock("Work",.F.)                                   
               Aadd(aNsistema,{Work->ZX2_ITEM,Alltrim(Work->ZX2_PRODUT)})
               DbDelete() 
               Work->(MsUnlock())
               Work->(DbSkip()) 
               Loop
            EndIf
            
         EndIf  
                                                    
         RecLock("Work",.F.)                   
         If Work->ZX2_QTD_D > 0      
                    
                             //   TIPO ,                   CODIGO,            QTD,         VLR UNI,VLR TOT,       CUSTO,          ITEM,        EMISSAO,	         UM,       Armazem
            Aadd(aSistema,{"Componente",Alltrim(Work->ZX2_PRODUT),Work->ZX2_QTD_D,Work->ZX2_PRECUN,cBar,Work->ZX2_TOTAL,Work->ZX2_ITEM,Work->ZX2_DT_NF,Work->ZX2_UM,Work->ZX2_LOCAL})  
            
            cLog+= "Componente  "+Alltrim(Work->ZX2_PRODUT)+" Qtd :  "+Alltrim(Str(Work->ZX2_QTD_D))+" Valor Unitario :  "+Alltrim(Str(Work->ZX2_PRECUN))+ ;
                  " Valor Total :  "+Alltrim(Str(Work->ZX2_TOTAL))+CHR(13)+CHR(10) 
            
            nTotal+=Work->ZX2_TOTAL                         
         EndIf
         If Work->ZX2_QTD_U==Work->ZX2_QTD   // Retira o item que usou todo o saldo.
            DbDelete()
         Else 
            Work->ZX2_PRECUN:=0  // Zera o valor do unitário para o próximo sistema
            Work->ZX2_TOTAL :=0  // Zera o valor do total para o próximo sistema
            Work->ZX2_QTD_D :=0  // Zera a quantidade digitada para o próximo sistema.
         EndIf 
              
         Work->(MsUnlock())       
         Work->(DbSkip())   
   
      EndDo                        
   
      If nTotal<>0
         Aadd(aSistema,{"","","","","",""}) // Adiciona linha em branco
         Aadd(aSistema,{"","","","TOTAL","COMPONENTE",nTotal}) // Adiciona o Total ao final de cada Sistema 
         Aadd(aSistema,{cBar,cBar,cBar,cBar,cBar,cBar}) // Adiciona linha em branco
      EndIf
      
      If nTotal<>SD1->D1_CUSTO
         Aadd(aDivVal ,{Alltrim(SD1->D1_COD),SD1->D1_CUSTO," - ",nTotal,SD1->D1_CUSTO-nTotal}) //  Sistema com divergência de valor
         Aadd(aDivVal ,{cBar,cBar,cBar,cBar,cBar+cBar}) // Adiciona linha em branco          
      EndIf 
      
      nTotRomaneio+=nTotal       
       
       
      nCol:=1390 // Ajusta a tela pra ser mostrado os sistemas
                                        
   EndIf  
   
   Work->(DbGoTop())
  
                                               
Return lRet


            
// Prepara para gerar pedido, movimentação e atualização de custo e saldo.
*-----------------------------* 
  User Function SGerarXC()
*-----------------------------*

Local nCountItens :=1  
Local cNum    
Local aSays   :={} 
Local aButtons:={}
Local cText   :={}  
Local cEmail  :="" 

Begin Sequence
                        
   If cEmpAnt $ "KX/XC" 
        
      If ZX3->ZX3_VINC=="G"
         MsgStop("Esse romaneio gerou o pedido: "+ZX3->ZX3_MOVIM+" ,necessário estornar o pedido","Veraz")  
         Return .F.
      EndIf 
     
      IF !(MsgNoYes("Será gerado um pedido de venda desse romaneio","Veraz"))
         Return .F.       
      EndIf  
           
      cNum:=BuscaCodPed(xFilial("SC5"))   
        
      //Grava dados no SC5            		        
      RecLock("SC5",.T.)
      SC5->C5_FILIAL :=xFilial("SC5")
      SC5->C5_NUM    :=StrZero(cNum,6,0) 
      cNum:=SC5->C5_NUM         
      SC5->C5_TIPO   :=ZX3->ZX3_TIPO          
      SC5->C5_CLIENTE:=ZX3->ZX3_CLIENT  
      SC5->C5_CLIENT :=ZX3->ZX3_CLIENT
      SC5->C5_LOJACLI:=ZX3->ZX3_LOJA
      SC5->C5_LOJAENT:=ZX3->ZX3_LOJA
      SC5->C5_TIPOCLI:=ZX3->ZX3_TP_CLI
      SC5->C5_MOEDA  :=ZX3->ZX3_MOEDA           
      SC5->C5_EMISSAO:=Date()      
      SC5->C5_CONDPAG:=ZX3->ZX3_CONPAG
      SC5->C5_TPFRETE:=ZX3->ZX3_TP_F   
      SC5->C5_USERLGI:=alltrim(cUserName) 
      SC5->C5_USERLGA:=alltrim(cUserName) 
      SC5->C5_MENNOTA:=ZX3->ZX3_OBS  
      
      If SC5->(FieldPos("C5_P_ROM")) > 0
         SC5->C5_P_ROM:=ZX3->ZX3_NUM  
      EndIf    
      
      If SC5->(FieldPos("C5_P_DLRY")) > 0
         SC5->C5_P_DLRY:=ZX3->ZX3_DLRY
      EndIf
      
      SC5->(dbunlock())
      
      RecLock("ZX3",.F.)
      ZX3->ZX3_MOVIM:=SC5->C5_NUM
      ZX3->ZX3_VINC :="G"
      ZX3->(dbunlock()) 
      
      cEmail += '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
      cEmail += '<title>Nova pagina 1</title></head><body>'
	  cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
 	  cEmail += 'PEDIDO DE VENDA VERAZ</b></u></font></p>'
	  cEmail += '<p><font face="Courier New" size="2">Pedido de Venda: '+SC5->C5_NUM
	  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Romaneio&nbsp;&nbsp;&nbsp;&nbsp; : '+SC5->C5_P_ROM+'<br>'    
	  cEmail += 'Cliente&nbsp;&nbsp;&nbsp;&nbsp; : '+SC5->C5_CLIENTE+'/'+SC5->C5_LOJACLI
	  cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(ZX3->ZX3_NOMEF)+'<br><p>'   
	  cEmail += 'Usuário&nbsp;&nbsp;&nbsp;&nbsp; : '+alltrim(cUserName)+'<br>'     
	  cEmail += 'Data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Dtoc(date())+'<br>'
	  cEmail += 'Horario&nbsp;&nbsp;&nbsp;&nbsp; : '+Time()+'<br>'
	  cEmail += '<p><p>ESTRUTURA<p>'
	  cEmail += '<table border="1" width="1200" style="padding: 0"><tr>'
 	  cEmail += '<td width="40"><font face="Courier New" size="2">Item</font></td>'
	  cEmail += '<td width="113"><font face="Courier New" size="2">Produto</font></td>'
	  cEmail += '<td width="378"><font face="Courier New" size="2">Descrição</font></td>'
	  cEmail += '<td width="111" align="right">'
      cEmail += '<p align="right"><font face="Courier New" size="2">Quantidade</font></td>'
      cEmail += '<td align="right" width="122"><font face="Courier New" size="2">Val.Unitário</font></td>'
	  cEmail += '<td align="right" width="119"><font face="Courier New" size="2" size="2">Valor TotaL</font></td>'
	  cEmail += '<td align="center"><font size="2" face="Courier New">Tipo do Produto</font></td></tr>'
     
      //Informar a TES
	     
	  ZX4->(DbSetOrder(1))
	  
      If ZX4->(DbSeek(xFilial("ZX3")+ZX3->ZX3_NUM+ZX3->ZX3_DLRY ))
         While ZX4->(!EOF()) .And. ZX3->ZX3_NUM+ZX3->ZX3_DLRY==ZX4->ZX4_NUM+ZX4->ZX4_DLRY  
         
            If Alltrim(ZX4->ZX4_TIPO)=='SISTEMA' .Or. Alltrim(ZX4->ZX4_TIPO)=="COMP. P/ VENDA" .Or. Alltrim(ZX4->ZX4_TIPO)=="ITEM P/ NF SERVIÇO"  .Or. Alltrim(ZX4->ZX4_TIPO)=="COMP. SISTEMA"
			   RecLock("SC6",.T.)
			   SC6->C6_FILIAL  := xFilial("SC6")
			   SC6->C6_NUM     := SC5->C5_NUM 
			   SC6->C6_PRODUTO := ZX4->ZX4_PRODUT 
			   SC6->C6_ITEM    := substr(ZX4->ZX4_ITEM,2,2) //StrZero(nCountItens,3-Len(Alltrim(str(nCountItens))),0)
			   SC6->C6_DESCRI  := ZX4->ZX4_PROD_D
			   SC6->C6_UM      := ZX4->ZX4_UM
			   SC6->C6_QTDVEN  := ZX4->ZX4_QTD
			   
			   //Moeda em reais
			   If SC5->C5_MOEDA == 1 
			      SC6->C6_PRCVEN  := ZX4->ZX4_PRECUN
			      SC6->C6_VALOR   := ZX4->ZX4_TOTAL
			   Else
			      //Dollar
			      SC6->C6_PRCVEN  := ZX4->ZX4_PRC_US
			      SC6->C6_VALOR   := ZX4->ZX4_TOT_US 
			   EndIf
			   
			   //SC6->C6_TES
			   SC6->C6_LOCAL   := ZX4->ZX4_LOCAL 
			   //SC6->C6_CF    
			   //SC6->C6_PEDCLI  := ZX3->ZX3_PEDCLI
			   SC6->C6_USERLGI := alltrim(cUserName)  
			   SC6->C6_USERLGA := alltrim(cUserName) 
			   SC6->C6_P_COD   := ZX4->ZX4_COD_C
			   SC6->C6_P_DESC  := ZX4->ZX4_DESCC
               SC6->(dbunlock()) 
                          
               nCountItens++               
            
               RecLock("ZX4",.F.)
               ZX4->ZX4_MOVIM:=SC5->C5_NUM
               ZX4->(dbunlock())  
            EndIf 
            
            cEmail += '	<tr>'
			cEmail += '		<td width="40"><font face="Courier New" size="2">'+ZX4->ZX4_ITEM+'</font></td>'
			cEmail += '		<td width="113"><font face="Courier New" size="2">'+AllTrim(ZX4->ZX4_PRODUT)+'</font></td>'
			cEmail += '		<td width="378"><font face="Courier New" size="2">'+AllTrim(ZX4->ZX4_PROD_D)+'</font></td>'
			cEmail += '		<td width="111" align="right">'
			cEmail += '		<p align="right"><font face="Courier New" size="2">'+Transform(ZX4->ZX4_QTD,PesqPict("ZX4","ZX4_QTD"))+'</font></td>'
			cEmail += '		<td align="right" width="122"><font face="Courier New" size="2">'+Transform(ZX4->ZX4_PRECUN,PesqPict("ZX4","ZX4_PRECUN"))+'</font></td>'
			cEmail += '		<td align="right" width="119"><font face="Courier New" size="2">'+Transform(ZX4->ZX4_TOTAL,PesqPict("ZX4","ZX4_TOTAL"))+'</font></td>'
			cEmail += '		<td align="center"><font size="2" face="Courier New">'+AllTrim(ZX4->ZX4_TIPO)+'</font></td>'
			cEmail += '	</tr>'    

			ZX4->(DBSkip())
		 EndDo  
		 
		 cEmail += '</table>'
	     cEmail += '<br>'
         cEmail += '<br>'
         cEmail += '<br>'
         cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
         cEmail += '<p align="center">www.grantthornton.com.br</p>'
         cEmail += '</body></html>'
		 				   
      EndIf
      
      SC5->(dbSeek(cNum))
      cFile := "\SYSTEM\"+cNum+".html"
      nHdl := FCreate( cFile )
      FWrite( nHdl,  cEmail, Len( cEmail ) )
      FClose( nHdl )      
         
      oEmail            :=  DEmail():New()
      oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
      oEmail:cTo		:=  AllTrim(GetMv("MV_P_EMAIL"))   // Ex: "tiago.mendonca@pryor.com.br;vitor.bedin@pryor.com.br"
      oEmail:cSubject	:=	"Pedido de Venda gerado: " + cNum
      oEmail:cBody   	:= 	cEmail
      oEmail:cAnexos    :=  cFile
      oEmail:Envia()
      
      cText:="Geração de Pedido"     
      Aadd(aSays,"Pedido "+Alltrim(cNum)+" gerado com sucesso. ") 
      Aadd(aSays," ")
      Aadd(aButtons, { 1,.T.,{|o| o:oWnd:End() }} )
      //Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
   
      FormBatch( cText, aSays, aButtons,,150,350  ) 
      
      FErase(cFile)      
              
   EndIf 
          
End Sequence          
                        
Return .T.	     


*----------------------------------*
   Static Function GeraMov(cNumR)                                                                                              
*----------------------------------*  
   
Local cNumR,nNumSD3,cNumSD3,aSD1,nVal,cData,nCusComp,dData
Local lRet:=.T.
Local i:=1   
Local cLocal,cProduto,cTipo
Local nPos:=nSeq:=0 
               
Begin Sequence  
            
   ZX1->(DbSetOrder(1))
   ZX1->(DbSeek(xFilial("ZX1")+cNumR))
   If Alltrim(ZX1->ZX1_NOTA) == ''
      MsgStop("Romaneio não possui vinculo a nota","Veraz")      
      Return .F.  
   EndIf  
   
   If Alltrim(ZX1->ZX1_MOVIM) <> ''
      MsgStop("Romaneio já gerado. Movimentação : "+Alltrim(ZX1->ZX1_MOVIM),"Veraz") 
      Return .F.
   EndIf
               
   If !(Empty(aDivSaldo))
      If !(Alltrim(aDivSaldo[1][1])=="Ok")  
         MsgStop("Existe divergência de Saldo, acerte antes de gerar a movimentação","Veraz") 
         Return .F. 
      EndIf    
   EndIF
   
   If !(Empty(aDivVal)) 
      If !(Alltrim(aDivVal[1][1])=="Ok")
         MsgStop("Existe divergência de Valor, acerte antes de gerar a movimentação","Veraz") 
         Return .F.
      EndIf     
   EndIF
      
   If Round(nTotRomaneio,0) <> Round(nTotSD1,0)
      MsgStop("Existe divergência no total da Nota e o Romaneio","Veraz") 
      Return .F. 
   EndIf
   
   If lRet
   
      If !(MsgNoYes("Será gerado movimentação do romaneio, deseja prosseguir ?","Veraz"))
         Return .F.
      EndIf  

      
      nNumSD3    :=BuscaNumSD3(xFilial("SD3"))
      cNumSD3    :=StrZero(nNumSD3,10-Len(Alltrim(str(nNumSD3))),0) 
      nSeq       :=BuscaSeqSD3(xFilial("SD3")) 
      nTotCusSD3 := 0 
                      
      DbSelectArea("SD3")
      Work->(DbGoTop()) 
        
        // TIPO[1], CODIGO[2], QTD[3], VLR UNI[4], VLR TOT[5], CUSTO[6], ITEM[7], DATA[8], UM[9], LOCAL[10] 
      For i:=1 to Len(aSistema)

         If Alltrim(aSistema[i][1]) =="Sistema"  .Or. Alltrim(aSistema[i][1]) =="Componente"    
            
         DbSelectArea("SB2")  
         SB2->(DbSetOrder(1))                  
         cProduto:=aSistema[i][2]+space(15-Len(aSistema[i][2])) //Acerta o tamanho do produto para Seek
         cLocal  :=aSistema[i][10]
      
         
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial("SB1")+cProduto))
            cTipo :=SB1->B1_TIPO     
         EndIf 
         
            
            If SB2->(DbSeek(xFilial("SB2")+cProduto+cLocal)) 
               RecLock("SB2",.F.) 
               
               If Alltrim(aSistema[i][1]) =="Sistema"  
                  If SB2->B2_QATU-aSistema[i][3] < 0    
                     MsgStop("Saldo do item :"+aSistema[i][2]+" ficará negativo no armazem : "+cLocal+" , verificar.","Veraz")
                     Return .F.
                  EndIf
                  SB2->B2_QATU  -= aSistema[i][3]   
                  nVal          :=  SB2->B2_VATU1 - aSistema[i][6]                 
                  SB2->B2_VATU1 :=  SB2->B2_VATU1 - aSistema[i][6] 
                  If SB2->B2_QATU <> 0
                     SB2->B2_VATU1 := nVal
                     SB2->B2_CM1   := nVal / SB2->B2_QATU                 
                  Else
                     SB2->B2_VATU1 :=0
                     SB2->B2_CM1   :=0     
                  EndIf                                     
               ElseIf Alltrim(aSistema[i][1])=="Componente"
                  SB2->B2_QATU  += aSistema[i][3]
                  nVal          := (aSistema[i][4]*aSistema[i][3]) + SB2->B2_VATU1    
                  SB2->B2_VATU1 := nVal
                  SB2->B2_CM1   := nVal / SB2->B2_QATU                        
               EndIf
               SB2->(MsUnlock())           
            Else 
               RecLock("SB2",.T.)  
               SB2->B2_FILIAL:=xFilial("SB2")
               SB2->B2_COD   :=cProduto
               SB2->B2_LOCAL :=cLocal
               SB2->B2_CM1   :=aSistema[i][6]/aSistema[i][3]            
               SB2->B2_QATU  :=aSistema[i][6] 
               SB2->B2_VATU1 :=aSistema[i][6]             
               SB2->(MsUnlock())                
            EndIf
            
            If Alltrim(aSistema[i][1]) =="Componente"
            
               ZX2->(DbSetOrder(2))              //Romaneio+Item+Codigo
               If ZX2->(DbSeek(xFilial("ZX2")+cNumR+aSistema[i][7]+aSistema[i][2]))
                  RecLock("ZX2",.F.)
                  ZX2->ZX2_PRECUN:=aSistema[i][3]
                  ZX2->ZX2_TOTAL :=aSistema[i][6]
                  ZX2->ZX2_MOVIM :=cNumSD3
                  ZX2->ZX2_QTD_U :=ZX2->ZX2_QTD 
                  ZX2->ZX2_DESM  :="1" // Desmonta SIM   
                  ZX2->(MsUnlock())  
                  ZX1->(DbSetOrder(1))
                  If ZX1->(DbSeek(xFilial("ZX1")+cNumR))
                     RecLock("ZX1",.F.)
                     ZX1->ZX1_MOVIM:=cNumSD3
                     ZX1->ZX1_VINC :='G'
                     ZX1->(MsUnlock())    
                  EndIf
               EndIf                                
               
               //Gera a movimentação de entrada                                      
               RecLock("SD3",.T.)   
               SD3->D3_FILIAL  := xFilial("SD3") 
               SD3->D3_TM      := '499'  //401
               SD3->D3_COD     := aSistema[i][2] 
               SD3->D3_UM      := aSistema[i][9] 
               SD3->D3_QUANT   := aSistema[i][3] 
               SD3->D3_CF      := "DE7"  
               SD3->D3_LOCAL   := cLocal
               SD3->D3_EMISSAO := aSistema[i][8]
               SD3->D3_CUSTO1  := aSistema[i][6] 
               //SD3->D3_NUMSEQ  := nSeq 
               SD3->D3_DOC     := cNumSD3      
               SD3->D3_CHAVE   :="E9"   
               SD3->D3_TIPO    :=cTipo
               SD3->D3_USUARIO :=cUserName  
               
               If SD3->(FieldPos("D3_P_ROM")) > 0
                  SD3->D3_P_ROM:=ZX1->ZX1_NUM  
               EndIf
               
               SD3->(MsUnlock()) 
         
               //nCusComp+= SD3->D3_CUSTO1 
            
            ElseIf Alltrim(aSistema[i][1])=="Sistema"
               
               RecLock("SD3",.T.)   
               SD3->D3_FILIAL  :=xFilial("SD3") 
               SD3->D3_TM      :='999' //
               SD3->D3_COD     :=aSistema[i][2]
               SD3->D3_UM      :=aSistema[i][9]
               SD3->D3_QUANT   :=aSistema[i][3]
               SD3->D3_CF      :="RE7"  
               SD3->D3_LOCAL   :=cLocal
               SD3->D3_EMISSAO :=aSistema[i][8]
               SD3->D3_CUSTO1  :=aSistema[i][6] 
               //SD3->D3_NUMSEQ  :=nSeq
               SD3->D3_DOC     :=cNumSD3 
               SD3->D3_CHAVE   :="E0"
               SD3->D3_TIPO    :=cTipo
               SD3->D3_USUARIO :=cUserName
               SD3->(MsUnlock())                
                                 
            EndIf   
         
         EndIf
         
         nSeq++
         
      Next     
      
      For i:=1 to len(aNsistema) //Itens que não foram desmontados
         If ZX2->(DbSeek(xFilial("ZX2")+cNumR+aNsistema[i][1]))
            RecLock("ZX2",.F.) 
            ZX2->ZX2_DESM:="2"
            SD3->(MsUnlock()) 
         EndIf
      Next
                   
   EndIf       
   
   MsgAlert("Movimentação gerada com sucesso.","Veraz") 

End Sequence   
   
Return lRet   
                
//Estorna a movimentação de entrada 
*-------------------------------*
   User Function eEstXC()
*-------------------------------*

                                   
  
   If Alltrim(ZX1->ZX1_MOVIM) == ''  .And.  Alltrim(ZX1->ZX1_ORIGEM) <> 'LOC'
      MsgStop("Romaneio não possui movimentação, não pode ser estornado","Veraz") 
      Return .F.
   EndIf  
   
   If Alltrim(ZX1->ZX1_ORIGEM) == 'LOC'
      MsgStop("Necessário estornar a nota, essa rotina gerou PRE-NOTA","Veraz") 
      Return .F.
   EndIf 
         
   If !(MsgNoYes("Deseja estornar essa movimentação ?","Veraz"))
      Return .F.
   EndIf  
   
   SD3->(DbSetOrder(2))
   If SD3->(DbSeek(xFilial("SD3")+ZX1->ZX1_MOVIM))
      While SD3->(!Eof()) .And. ZX1->ZX1_MOVIM == SD3->D3_DOC 
         
         DbSelectArea("SB2")  
         SB2->(DbSetOrder(1))
         If SB2->(DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)) 
            
            RecLock("SB2",.F.)
            If SD3->D3_TM == '499'  //401
               If (SB2->B2_QATU-SD3->D3_QUANT) < 0
                  MsgStop("Saldo do item :"+Alltrim(SB2->B2_COD)+" ficará negativo no armazem : "+SD3->D3_LOCAL+" , verificar.","Veraz")   
                  Return .F.
               EndIf 
               SB2->B2_QATU  -= SD3->D3_QUANT
               nVal          := SB2->B2_VATU1 - (SD3->D3_CUSTO1)     
               If SB2->B2_QATU <> 0 
                  SB2->B2_VATU1 := nVal
                  SB2->B2_CM1   := nVal / SB2->B2_QATU
               Else 
                  SB2->B2_VATU1 := 0
                  SB2->B2_CM1   := 0
               EndIf                                        
            Else 
               SB2->B2_QATU  += SD3->D3_QUANT
               nVal          :=  SB2->B2_VATU1 + (SD3->D3_CUSTO1)     
               SB2->B2_VATU1 := nVal
               SB2->B2_CM1   := nVal / SB2->B2_QATU                                  
            EndIf
            SB2->(MsUnlock())
                                             
         EndIf  
         
         RecLock("SD3",.F.)                    
         DbDelete()
         SD3->(MsUnlock())
         
         SD3->(DbSkip())
      EndDo
   EndIf

   ZX2->(DbSetOrder(1))
   If ZX2->(DbSeek(xFilial("ZX2")+ZX1->ZX1_NUM))   
      While ZX2->(!Eof()) .And. ZX2->ZX2_NUM == ZX1->ZX1_NUM  
         RecLock("ZX2",.F.) 
         ZX2->ZX2_MOVIM:=''
         ZX2->ZX2_DESM:='' 
         ZX2->ZX2_QTD_U :=0
         SX2->(MsUnlock())
         ZX2->(DbSkip())   
      EndDo
   EndIf
   
   RecLock("ZX1",.F.)                    
   ZX1->ZX1_MOVIM:='' 
   ZX1->ZX1_VINC :='V'
   ZX1->(MsUnlock()) 
     
   MsgAlert("Movimentação estornada com sucesso.","Veraz")  
   
   ZX1->(DbGoTop())
   
Return                 
           


