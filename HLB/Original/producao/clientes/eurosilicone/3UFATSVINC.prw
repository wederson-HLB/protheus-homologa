#Include "rwmake.ch"
#include "PROTHEUS.CH"

/*
Funcao      : 3UFATSVINC
Parametros  : 
Retorno     : 
Objetivos   : Vincular o pedido liberado aos numeros de serie.
Autor       : Tiago Luiz Mendonça 
Data        : 09/12/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Estoque/Faturamento.
*/ 


*----------------------------*
  User Function 3UFATSVINC() 
*----------------------------*  
         
Local  aCores:={}      

Private aRotina:={}                                        
Private cLeg:="S"    
Private lLote:=GetMv("MV_P_LOTE")

  If !(cEmpAnt $ "3U")
     MsgInfo("Especifico EUROSILICONE"," A T E N C A O ")  
     Return .F.
  Endif    

  DbSelectArea("ZX2")
  DbSetOrder(1)   
  ZX2->(DbGoTop()) 

  aRotina := {{ "Pesquisa"        ,"AxPesqui"    , 0 , 1},;
	          { "Visualizar"      ,"U_3USVIEW"   , 0 , 2},;  
	          { "Estornar "       ,"U_3USVIEW"   , 0 , 3},;
	          { "Incluir Serie"   ,"U_3USINSERT" , 0 , 3},;
	          { "Alterar"         ,"U_3USVIEW"   , 0 , 4},;
	          { "Legenda"         ,"U_3USLEG"    , 0 , 3}}  
	          
  aCores  := {{ "ZX2_STATUS=='PED'",'BR_AMARELO'},;	//Pedido vinculado c/ Serie. 
	          { "ZX2_STATUS=='NFS'",'BR_VERMELHO'}}  	//Nota gerada		    


  mBrowse(6,1,22,75,"ZX2",,,,,,aCores)	   
   
Return 

*----------------------------*
  User Function 3UESTEVINC() 
*----------------------------*  
         
Local  aCores:={}      

Private aRotina:={} 
Private cLeg:="E"    
Private lLote:=GetMv("MV_P_LOTE")

  If !(cEmpAnt $ "3U")
     MsgInfo("Especifico EUROSILICONE"," A T E N C A O ")  
     Return .F.
  Endif    

  DbSelectArea("ZX0")
  DbSetOrder(1)   
  ZX0->(DbGoTop()) 

  aRotina := {{ "Pesquisa"        ,"AxPesqui"    , 0 , 1},;
	          { "Visualizar"      ,"U_3UEVIEW"   , 0 , 2},;  
	          { "Estornar "       ,"U_3UEVIEW"   , 0 , 3},;
	          { "Incluir Serie"   ,"U_3UEINSERT" , 0 , 3},;
	          { "Legenda"         ,"U_3USLEG"    , 0 , 3}}  
	          
  aCores  := {{ "ZX0_STATUS=='SEM'",'BR_VERDE'   },;   //Nota sem vinculo c/ Serie.   
              { "ZX0_STATUS=='SER'",'BR_AMARELO' },;   //Nota com vinculo Serie
              { "ZX0_STATUS=='DEV'",'BR_AZUL'    },;   //Nota de devolução
	          { "ZX0_STATUS=='FAT'",'BR_VERMELHO'  }}  //Nota parcialmente faturada		    


  mBrowse(6,1,22,75,"ZX0",,,,,,aCores)	   
   
Return 


*-----------------------------* 
  User Function 3USLEG()
*-----------------------------*

Local aCores := {}    
                
If cLeg == "E" //Entrada  
   
   aCores := {{"BR_VERDE"   ,"Nota de entrada não vinculada com serie"},;   
              {"BR_AMARELO" ,"Nota de entrada vinculada com serie"},;  
              {"BR_AZUL"    ,"Nota de entrada - devolução"},;  
              {"BR_VERMELHO","Nota de entrada possui nota de saida - venda"}} 
     
   BrwLegenda("EUROSILICONE","Legenda",aCores) 
   
Else  //Saída
   aCores := {{"BR_AMARELO"   ,"Pedido vinculado com serie"},;  
              {"BR_VERMELHO"  ,"Pedido faturado"}} 
     
   BrwLegenda("EUROSILICONE","Legenda",aCores)  

EndIf
   

Return .T.    

//Tela para gravação da serie dos produtos.
*--------------------------------*
  Static Function GrvSnfs()
*--------------------------------*         

Local Odlg, oMain,Odlg1, oMain1 ,olbx, Odlg2,oMain2
Local cCliente,cNome,cProduto,cDesc,cQtd,cLocal,cUM,cLoteCtl,cDtVal,cOk:="OK"
Local lRefresh:=lFatExist:=.T.  
Local lCorrigi:=lErroLote:=lOK:=lErroSerie:=lEstExist:=.F.
Local cChr    := ""
Local cObs    :=Space(150)
Local cSerie  :=Space(24) 
Local cRef    :=Space(3) 
Local cSize   :=Space(5)  
Local cSn     :=Space(8)
Local cLote   :=Space(6)   
Local aItens  :={}
Local aItensErro:={}  
Local nPos,cEmail
Local cTransp  := Space(6)  
Local nPLiqui  := 0
Local nPBruto  := 0 
Local nQtd     := 0 
Local cEspec   := Space(15) 
Local dDtSaida := CTOD("")
Local cHrSaida := Space(10)
Local cConhec  := Space(60)

   ZX2->(DbSetOrder(1))
   If ZX2->(DbSeek(xFilial("ZX2")+SC9Temp->C9_PEDIDO))
      MsgStop("Esse pedido já foi incluído","EUROSILICONE") 
      Return .F.
   EndIF 
         
   SC9Temp->(DbGoTop())
   While SC9Temp->(!EOF()) 
      
      // Monta tela para leitura das series.
           
	  DEFINE MSDIALOG oDlg TITLE  "Item "+Alltrim(SC9Temp->C9_ITEM)+" do pedido "+Alltrim(SC9Temp->C9_PEDIDO)  From 1,10 To 22,080 OF oMain
   
         nLin1:=005 
         nCol1:=005           
         
         cCliente:=SC9Temp->C9_CLIENTE
         @ nLin1+8,nCol1+5 SAY "CLIENTE :"  PIXEL SIZE 80,30 OF oDlg  
         @ nLin1+6,nCol1+50 get cCliente WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 50,5 OF oDlg 
         
         @ nLin1+8,nCol1+100 SAY "NOME :"  PIXEL SIZE 100,10 OF oDlg 
         SA1->(DbSetOrder(1))
         If SA1->(DbSeek(xFilial("SA1")+SC9Temp->C9_CLIENTE))
            cNome:=Alltrim(SA1->A1_NOME)
            @ nLin1+6,nCol1+120 Get Alltrim(SA1->A1_NOME) COLOR CLR_HBLUE, CLR_WHITE  WHEN .F.   PIXEL SIZE 140,5 OF oDlg
         EndIf
         
         @ nLin1+24,nCol1+5 SAY "PRODUTO :"  PIXEL SIZE 80,10 OF oDlg  
         cProduto:=Alltrim(SC9Temp->C9_PRODUTO)
         @ nLin1+22,nCol1+50 Get cProduto  WHEN .F.  COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 50,10 OF oDlg 
         
         @ nLin1+24,nCol1+100 SAY "DESC. :"  PIXEL SIZE 80,10 OF oDlg          
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial("SB1")+SC9Temp->C9_PRODUTO)) 
            cDesc:=Alltrim(SB1->B1_DESC) 
            @ nLin1+22,nCol1+120 get cDesc WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 140,10 OF oDlg
         EndIf
         
         cQtd:=SC9Temp->C9_QTDLIB 
         @ nLin1+40,nCol1+5 SAY "QUANTIDADE :"  PIXEL SIZE 80,10 OF oDlg    
         @ nLin1+38,nCol1+50 get cQtd WHEN .F. PICTURE "9999.99" COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 32,10 OF oDlg 
                                                                      
         cLocal:=Alltrim(SC9Temp->C9_LOCAL)                               
         @ nLin1+40,nCol1+100 SAY "LOCAL:"  PIXEL SIZE 80,10 OF oDlg  
         @ nLin1+38,nCol1+120 get cLocal WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 10,10 OF oDlg  
         
         cUM:=Alltrim(SB1->B1_UM)
         @ nLin1+40,nCol1+150 SAY "UNIDADE :"  PIXEL SIZE 80,10 OF oDlg
         @ nLin1+38,nCol1+179 get cUM WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 10,10 OF oDlg   
         
         If lLote
         
            cLoteCTL:=Alltrim(SC9Temp->C9_LOTECTL)
            @ nLin1+57,nCol1+5  SAY "LOTE DO PEDIDO:"  PIXEL SIZE 80,10 OF oDlg   
            
            cDtVal:=SC9Temp->C9_DTVALID                  
            @ nLin1+57,nCol1+100 SAY "VALIDADE DO LOTE"  PIXEL SIZE 80,10 OF oDlg    
            @ nLin1+54,nCol1+155 get cDtVal WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 25,10 OF oDlg    
         
         EndIf
         
         If lLote          
        
            If lErroLote 
               @ nLin1+54,nCol1+50 get cLoteCTL WHEN .F. COLOR CLR_HRED, CLR_WHITE  PIXEL SIZE 25,10 OF oDlg  
            Else
               @ nLin1+54,nCol1+50 get cLoteCTL WHEN .F. COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 25,10 OF oDlg  
            EndIf 
        
         EndIf 
                                                               
         If lRefresh
            @ nLin1+75,nCol1+100 Get cSerie  PIXEL SIZE 100,10 OF oDlg  
         Else
            @ nLin1+75,nCol1+100 Get cSerie WHEN .F. PIXEL SIZE 100,10 OF oDlg
            If lErroSerie     
               cOk:="Error"
               @ nLin1+75,nCol1+205 Get cOk WHEN .F. COLOR CLR_HRED PIXEL SIZE 10,10 OF oDlg               
            Else
               @ nLin1+75,nCol1+205 Get cOk WHEN .F. COLOR CLR_HBLUE PIXEL SIZE 10,10 OF oDlg  
            EndIf
         EndIf
                  
         @ nLin1+90,nCol1+100 Get cRef  WHEN .F. PIXEL SIZE 15,10 OF oDlg 
         @ nLin1+103,nCol1+100  SAY "REF "  PIXEL SIZE 80,10 OF oDlg 
                  
         @ nLin1+90,nCol1+128 Get cSize WHEN .F. PIXEL SIZE 15,10 OF oDlg 
         @ nLin1+103,nCol1+128  SAY "SIZE "  PIXEL SIZE 80,10 OF oDlg  
                   
         @ nLin1+90,nCol1+160 Get cSN   WHEN .F. PIXEL SIZE 30,10 OF oDlg
         @ nLin1+103,nCol1+160  SAY "SN "  PIXEL SIZE 80,10 OF oDlg    
                  
         @ nLin1+103,nCol1+200  SAY "LOTE"  PIXEL SIZE 80,10 OF oDlg
     
         
         If lLote
            If lErroLote       
               @ nLin1+75,nCol1+5 TO nLin1+130,nCol1+90 LABEL "" OF oDlg PIXEL OF oDlg 
               @ nLin1+80,nCol1+35   SAY "ATENCAO " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
               @ nLin1+95,nCol1+08   SAY "  Lote do pedido diferente do  " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
               @ nLin1+105,nCol1+08  SAY "  em outro produto ou possui "   COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
               @ nLin1+115,nCol1+08  SAY "divergência no código (REF+SIZE)" COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
            Else    
               @ nLin1+78,nCol1+10  SAY "Informe o numero de serie : "  PIXEL SIZE 80,10 OF oDlg 
               @ nLin1+90,nCol1+200 Get cLote WHEN .F. PIXEL SIZE 40,10 OF oDlg
            EndIf 
         Else 
            If !(lErroSerie)
               @ nLin1+78,nCol1+10  SAY "Informe o numero de serie : "  PIXEL SIZE 80,10 OF oDlg 
            EndIf   
            @ nLin1+90,nCol1+200 Get cLote WHEN .F. PIXEL SIZE 40,10 OF oDlg              
         EndIf      
         
         If lErroSerie
            @ nLin1+75,nCol1+5 TO nLin1+130,nCol1+90 LABEL "" OF oDlg PIXEL OF oDlg 
            @ nLin1+80,nCol1+35   SAY "ATENCAO " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
            @ nLin1+95,nCol1+08   SAY "A serie informada já foi utilizada  " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
            @ nLin1+105,nCol1+08  SAY "  em outro produto ou possui "   COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
            @ nLin1+115,nCol1+08  SAY "divergência no código REF+SIZE" COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
         EndIf
        
         @ nLin1,nCol1 TO nLin1+145,nCol1+267 LABEL "" OF oDlg PIXEL OF oDlg         // Caixa do botao
                 
         @ 130,130 BUTTON "Proximo"    size 40,12 ACTION( Processa({|| lOk:=.T.,oDlg:End()})) of oDlg Pixel
         @ 130,210 BUTTON "Cancelar"   size 40,12 ACTION(lOK:=.F.,oDlg:End()) of oDlg Pixel 
         @ 130,170 BUTTON "Corrigir"   size 40,12 ACTION(lCorrigi:=.T.,lErroLote:=.F.,lErroSerie:=.F.,oDlg:End()) of oDlg Pixel  
         

      ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())   
         
      If lLote     
         If lErroLote  .And. lOK
            MsgStop("Numero do lote da leitura incopativel com o do pedido, necessário corrigi-lo.","EUROSILICONE")               
            Loop 
         EndIf
      EndIf        
      
      If lErroSerie .And. lOk 
         MsgStop("A serie informada já foi incluída.","EUROSILICONE")               
         Loop       
      EndIf
                            
      //Limpa a tela
      If lCorrigi    
      
         cSerie :=Space(24) 
         cRef   :=Space(3) 
         cSize  :=Space(5)  
         cSn    :=Space(9)
         cLote  :=Space(6)   
         
         cOk:="OK"
         
         lRefresh:=.T.
         lCorrigi:=.F.
         
         Loop         
      EndIf
      
      If (  Len(alltrim(cSerie)) == 24 .Or. Len(alltrim(cSerie)) == 23 .Or. Len(alltrim(cSerie)) == 22 )  .And. (lRefresh)       
                              
         lRefresh:=.F.               
         
         nPos:=At(".",Alltrim(cSerie))
         cChr := "."
         
         If nPos == 0
            nPos:=At("+",Alltrim(cSerie))
         	cChr := "+"
         EndIf 
         
         //Valida o "ponto" e o "mais"       
         If nPos == 0
            lErroSerie:=.T.
         EndIf
                         
         //Ajuste do tamanho das series.        
         If nPos == 6 
            If len(alltrim(cSerie))== 23  

               cRef  := substr(cSerie,1,2)
               cSize := substr(cSerie,3,3)+"cc"
               cSN   := substr(cSerie,8,9)
               cLote := substr(cSerie,18,6)        
            Else   

               cRef  := substr(cSerie,1,2)
               cSize := substr(cSerie,3,3)+"cc"
               cSN   := substr(cSerie,8,8)
               cLote := substr(cSerie,17,6)
            EndIf       
         Else
            If len(alltrim(cSerie))== 24  

               cRef  := substr(cSerie,1,3)
               cSize := substr(cSerie,4,3)+"cc"
               cSN   := substr(cSerie,9,9)
               cLote := substr(cSerie,19,6)        
            Else   
			   If cChr == "+" .and. IsAlpha(Substr(cSerie,nPos-1,1))
                  
                  cRef  := substr(cSerie,1,2) + substr(cSerie,6,1)
                  cSize := substr(cSerie,3,3)+"cc"
                  cSN   := substr(cSerie,9,8)
                  cLote := substr(cSerie,18,6)
               Else

                  cRef  := substr(cSerie,1,3)
                  cSize := substr(cSerie,4,3)+"cc"
                  cSN   := substr(cSerie,9,8)
                  cLote := substr(cSerie,18,6)
               EndIf
            EndIf        
         EndIf     
        
         //Tratamento de lote, não disponivel
         If lLote
            If cLote<>Alltrim(SC9Temp->C9_LOTECTL)
               lErroLote:=.T.
            EndIf
         EndIf   
         
         //Verifica se a mesma serie não foi incluída duas vezes
         If aScanX(aItens,{ |X,Y|  X[8] == Upper(cSerie)     }) > 0 
            lErroSerie:=.T.
         EndIf        
         
         //Valida a referência do produto.
         If Alltrim(SC9Temp->C9_PRODUTO)<> Alltrim(cRef)+Alltrim(Substr(cSize,1,3))
            lErroSerie:=.T.
         EndIf
         
         //Valida o espaço na inclusão da serie        
         If Substr(cRef,1,1)==" " .Or. Substr(cRef,1,1)=="  " 
            lErroSerie:=.T.
         EndIf
         
               
         Loop
      EndIf 
                  
      If !(lOk)
         If MsgYesNo("Tem certeza que deseja cancelar, todas as informações serão perdidas","EUROSILICONE")
            Return .F.
         Else  
            
            Loop
         EndIf    
      EndIf
      
      If lOk                            
      
         If Len(alltrim(cSerie)) == 24 .Or. Len(alltrim(cSerie)) == 23 .Or. Len(alltrim(cSerie)) == 22
            
             //If MsgYesNo("Deseja gravar o Produto: "+Alltrim(SC9Temp->C9_PRODUTO)+" Seq. "+Alltrim(SC9Temp->C9_ITEM)+" Pedido: "+Alltrim(SC9Temp->C9_PEDIDO),"EUROSILICONE")
            
               Aadd(aItens,{SC9Temp->C9_PEDIDO,SC9Temp->C9_ITEM,SC9Temp->C9_PRODUTO,SC9Temp->C9_QTDLIB,SC9Temp->C9_LOCAL,SC9Temp->C9_CLIENTE,SC9Temp->C9_LOJA,Upper(cSerie),Upper(cRef),Upper(cSize),Upper(cSn),Upper(cLote)}) 
         
               cSerie :=Space(24) 
			   cRef   :=Space(3) 
			   cSize  :=Space(5)  
			   cSn    :=Space(9)
			   cLote  :=Space(6)
               lRefresh:=.T.                
               SC9Temp->(DbSkip())
            // Else 
             //   loop            
            // EndIf
         Else
            MsgAlert("Numero de serie inválido, informe novamente","EUROSILICONE")  
            cSerie :=Space(24)
         EndIf           
      
      EndIf                

   EndDo      
   
   If len(aItens) > 0
               
      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+aItens[1][1])) 
         If Alltrim(SC5->C5_P_TIPO) =="S"  
            MsgStop("Esse pedido não deve conter series, por favor verificar 'Tipo venda EUROS' ","EUROSILICONE")
            Return .F.        
         ElseIf Alltrim(SC5->C5_P_TIPO) =="V"     
            ZX3->(DbSetOrder(3))
            For i:=1 to Len(aItens)
               If ZX3->(DbSeek(xFilial("ZX3")+aItens[i][8]))     
                  //If ZX3->ZX3_CF $ == "5102" .Or. ZX3->ZX3_CF $ == "6102"  // Venda  
                  //   Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][8],"|||||",ZX3->ZX3_PEDIDO,ZX3->ZX3_ITEM,ZX3->ZX3_COD,ZX3->ZX3_CODBAR})                  
                  //   lFatExist:=.T.
                  //EndIf
               EndIf
            Next
         EndIf   
      EndIf
      
      ZX1->(DbSetOrder(3))
      For i:=1 to Len(aItens)
         If !(ZX1->(DbSeek(xFilial("ZX1")+alltrim(aItens[i][8]))))
            Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][8],"ESSA SERIE NAO FOI ENCONTRADA EM NENHUMA NOTA FISCAL DE ENTRADA"})
            lEstExist:=.T.
         EndIf
        
         If Select("QRY") > 0
            QRY->(DbCloseArea())	               
         EndIf
               
         BeginSql Alias 'QRY'
            SELECT R_E_C_N_O_ AS 'RECNUM'
            FROM %Table:ZX1%
            WHERE %notDel%
              AND ZX1_FILIAL = %exp:xFilial("ZX1")% 
              AND ZX1_NFSAID = ' '
              AND ZX1_CODBAR = %exp:aItens[i][8]% 
         EndSql  
         

         QRY->(DbGoTop())
         If QRY->(!BOF() .and. !EOF())
            lFatExist :=.F.
             Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][8],}) 
         Else
            Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][8],"ESSA SERIE JA FOI UTILIZADA, VERIFIQUE RELATORIO DE RASTRO"})
         EndIf
                 
      Next
      
      /*
      If lFatExist 

         //aItens  - 1.Pedido   2.Item    3.Produto   4.Qtd   5.Local   6.Cliente   7.Loja   8.Serie   9.Ref   10.Size   11.Sn   12.Lote
                                                                                                
         MsgStop("Atenção existe serie(s) cadastrada(s) que já foi informada em outro pedido, clique em OK para ver analise.","EUROSILICONE")
      
         /*
         DEFINE MSDIALOG oDlg1 TITLE  "Produto(s) com problema(s) " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "PEDIDO ATUAL","SEQ","PRODUTO","SERIE","","PEDIDO GRAVADO","SEQ","PRODUTO","SERIE" COLSIZES 40,15,35,35,10,40,15,35,35  COLOR CLR_HRED,CLR_HRED SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItensErro)
            olbx:bLine:={|| {aItensErro[olbx:nAt,1],aItensErro[olbx:nAt,2],aItensErro[olbx:nAt,3],aItensErro[olbx:nAt,4],aItensErro[olbx:nAt,5],aItensErro[olbx:nAt,6],aItensErro[olbx:nAt,7],aItensErro[olbx:nAt,8],aItensErro[olbx:nAt,9] }}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())  
      
         MsgAlert("Nenhum vinculo foi gravado","EUROSILICONE")  
         
         
         Return .F.
        */
      If lEstExist .Or. lFatExist 
      
         If lEstExist 
            MsgStop("Atenção existe serie(s) cadastrada(s) não encontradas em NF de Entrada, clique em OK para ver analise.","EUROSILICONE")
         Else
            MsgStop("Atenção existe serie informada que pode já ter sido vendida, clique em OK para ver analise.","EUROSILICONE")
         EndIf 
      
      
         DEFINE MSDIALOG oDlg1 TITLE  "Produto(s) com problema(s) " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "PEDIDO ATUAL","SEQ","PRODUTO","SERIE","MENSAGEM" COLSIZES 40,15,35,35,10,40,15,35,35  COLOR CLR_HRED,CLR_HRED SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItensErro)
            olbx:bLine:={|| {aItensErro[olbx:nAt,1],aItensErro[olbx:nAt,2],aItensErro[olbx:nAt,3],aItensErro[olbx:nAt,4],aItensErro[olbx:nAt,5]}}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())  
      
         MsgAlert("Nenhum vinculo foi gravado","EUROSILICONE")  
                  
         Return .F.
      
      Else
      
         DEFINE MSDIALOG oDlg1 TITLE  "Produtos gravados " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "PEDIDO","SEQ","PRODUTO","QTD","ARM","CLIENTE","LOJA","SERIE","REF","SIZE","SN","LOTE" COLSIZES 35,15,35,15,15,35,20,35,20,20,20,20 SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItens)
            olbx:bLine:={|| {aItens[olbx:nAt,1],aItens[olbx:nAt,2],aItens[olbx:nAt,3],aItens[olbx:nAt,4],aItens[olbx:nAt,5],aItens[olbx:nAt,6],aItens[olbx:nAt,7],aItens[olbx:nAt,8],aItens[olbx:nAt,9],aItens[olbx:nAt,10],aItens[olbx:nAt,11],aItens[olbx:nAt,12] }}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())     

      EndIf       
      
      RecLock("ZX2",.T.)
      ZX2->ZX2_FILIAL   := xFilial("SF2")
      ZX2->ZX2_PEDIDO   := aItens[1][1]
      ZX2->ZX2_CLIENT   := aItens[1][6] 
      ZX2->ZX2_LOJA     := aItens[1][7] 
      ZX2->ZX2_USER     := Alltrim(cUserName)
    
      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+aItens[1][1]))         
         If SC5->C5_P_TIPO =="A"
            ZX2->ZX2_OBS  := "Pedido de amostra"
         Else                           
            ZX2->ZX2_OBS  := "Pedido de venda " 
         EndIf         
      EndIf
  
      SA1->(DbSetOrder(1))
      If SA1->(DbSeek(xFilial("SA1")+aItens[1][6]+aItens[1][7]))               
         ZX2->ZX2_CLIDES   :=SA1->A1_NOME
      EndIf
  
      ZX2->ZX2_EMISSA   := dDataBase
      ZX2->ZX2_STATUS   := "PED" 
      ZX2->(MsUnlock())
         
      For i:=1 to len(aItens)      
                               
         RecLock("ZX3",.T.)
         ZX3->ZX3_FILIAL  := xFilial("SF2") 
         ZX3->ZX3_PEDIDO  := aItens[i][1]
         ZX3->ZX3_ITEM    := aItens[i][2]  
         ZX3->ZX3_COD     := aItens[i][3]
         ZX3->ZX3_QTD     := aItens[i][4]
         ZX3->ZX3_LOCAL   := aItens[i][5]
         ZX3->ZX3_CLIENT  := aItens[i][6]
         ZX3->ZX3_LOJA    := aItens[i][7]
         ZX3->ZX3_CODBAR  := aItens[i][8]
         ZX3->ZX3_REF     := aItens[i][9]
         ZX3->ZX3_SIZE    := aItens[i][10] 
         ZX3->ZX3_SN      := aItens[i][11]
         ZX3->ZX3_LOTE    := aItens[i][12]
         ZX3->ZX3_STATUS  := "PED" 
         
         SC5->(DbSetOrder(1))
         If SC5->(DbSeek(xFilial("SC5")+ZX3->ZX3_PEDIDO))  
            ZX3->ZX3_P_MEDI  :=  SC5->C5_P_MEDIC
            ZX3->ZX3_P_DESM  :=  SC5->C5_P_DESCM
            ZX3->ZX3_P_PAC   :=  SC5->C5_P_PAC
            ZX3->ZX3_P_DESP  :=  SC5->C5_P_DESCP
         EndIf
                   
         SC6->(DbSetOrder(1))
         If SC6->(DbSeek(xFilial("SC6")+aItens[i][1]))
            ZX3->ZX3_TES:=SC6->C6_TES
            ZX3->ZX3_CF :=SC6->C6_CF   
            SF4->(DbSetOrder(1))
            If SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
               ZX3->ZX3_PODER3:=SF4->F4_PODER3
            EndIf
         EndIf
                  
         ZX3->(MsUnlock())
               
      Next      
      
    
   EndIf  
   
   ZX2->(DbGoTop())  


   DEFINE MSDIALOG oDlg2 TITLE  "WorkFlow para Faturamento"  From 1,10 To 22,080 OF oMain2   
   
      @ 010,010 SAY "Pedido: " + aItens[1][1] Pixel size 80,10 of oDlg2   
      @ 010,100 SAY "CLIENTE: " + aItens[1][6] Pixel        size 120,10 of oDlg2 
      @ 025,010 SAY "Cod. Transp.: "   Pixel of oDlg2
      @ 040,010 SAY "Peso Liquido: "  Pixel   of oDlg2
      @ 040,115 SAY "Peso Bruto: "   Pixel  of oDlg2
      @ 055,010 SAY "Qtd: " Pixel of oDlg2
      @ 055,115 SAY "Especie: " Pixel  of oDlg2
      @ 070,010 SAY "Data: " Pixel  of oDlg2
      @ 070,115 SAY "Hora: " Pixel  of oDlg2 
      @ 090,010 SAY "Conhecimento: " Pixel  of oDlg2 
      @ 105,012 SAY "Observação " Pixel size 10,10 of oDlg2
      @ 025,050 GET cTransp  PICTURE "@!" Valid .t. F3 "SA4"  size  40,10
      @ 040,050 GET nPLiqui  PICTURE "@E 99,999.99"          size 40,10 Pixel  of oDlg2
      @ 040,150 GET nPBruto  PICTURE "@E 99,999.99"          size 40,10 Pixel  of oDlg2
      @ 055,050 GET nQtd     PICTURE "@E 99999"              size 40,10 Pixel of oDlg2
      @ 055,150 GET cEspec                                   size 40,10 Pixel of oDlg2
      @ 070,050 GET dDtSaida PICTURE "99/99/99"              size 40,10 Pixel of oDlg2
      @ 070,150 GET cHrSaida PICTURE "99:99:99"              size 40,10 Pixel of oDlg2
      @ 090,050 GET cConhec  PICTURE "@!"                    size 80,10 Pixel of oDlg2
      @ 105,050 GET cObs     PICTURE "@!"                    size 150,10 Pixel of oDlg2

      @ 112,230 BMPBUTTON TYPE 1 ACTION Close(oDlg2)
   
   ACTIVATE DIALOG oDlg2 CENTERED 
      
   SC5->(DbSetOrder(1))
   If SC5->(DbSeek(xFilial("SC5")+aItens[1][1])) 
      If !Empty(cConhec)
         RecLock("SC5",.F.)
         SC5->C5_P_CONHE :=cConhec 
         SC5->C5_PESOL   :=nPLiqui
         SC5->C5_PBRUTO  :=nPBruto
         SC5->C5_TRANSP  :=cTransp
         SC5->C5_VOLUME1 :=nQtd 
         SC5->C5_ESPECI1 :=cEspec
         SC5->(MsUnlock())
      EndIf
   EndIf
      
   //E-mail 
      cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
      cEmail += '<title>Nova pagina 1</title></head><body>'
      cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
      cEmail += 'Dados da inclusão da serie</b></u></font></p>'   
      cEmail += '<p><font face="Courier New" size="2">Pedido de Venda: '+aItens[1][1]
      cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>' 
      cEmail += 'Cliente&nbsp;&nbsp;&nbsp;&nbsp; : '+aItens[1][6]       
      SA1->(DbSetOrder(1))
      If SA1->(DbSeek(xFilial("SA1")+aItens[1][6] ))
         cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(SA1->A1_NOME)+'<br>'   
      EndIf  
      cEmail += 'Codigo Transportadora&nbsp;&nbsp;&nbsp;&nbsp; : '+alltrim(cTransp)+'<br>'  
      cEmail += 'Peso Liquido&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(Str(nPLiqui))+'<br>'
      cEmail += 'Peso Bruto&nbsp;&nbsp;&nbsp; : '+Alltrim(Str(nPBruto))+'<br>'
      cEmail += 'Quantidade&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(Str(nQtd))+'<br>'
      cEmail += 'Especie&nbsp;&nbsp;&nbsp;&nbsp; : '+cEspec+'<br>'
      cEmail += 'Data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Dtoc(dDtSaida)+'<br>'
      cEmail += 'Horario&nbsp;&nbsp;&nbsp;&nbsp; : '+cHrSaida+'<br>'
      cEmail += '<br>' 
      cEmail += 'Conhecimento&nbsp;&nbsp;&nbsp;&nbsp; : '+cConhec+'<br>'
      cEmail += '<br>'                                             
      cEmail += 'Observação&nbsp;&nbsp;&nbsp;&nbsp; : '+cObs+'<br>'
      cEmail += '<br>'   
      cEmail += '<br>'   
      cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
      cEmail += '<p align="center">www.grantthornton.com.br</p>'
      cEmail += '</body></html>'
	  
      cFile := "\SYSTEM\"+aItens[1][1]+".html"
      nHdl := FCreate( cFile )
      FWrite( nHdl,  cEmail, Len( cEmail ) )
      FClose( nHdl )      
         
      oEmail           :=  DEmail():New()
      oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
      oEmail:cTo		:=  AllTrim(GetMv("MV_P_EXP"))   // Ex: "tiago.mendonca@pryor.com.br"
      oEmail:cSubject	:=	" Pedido " +aItens[1][1]+" liberado para faturamento - Expedicao"
      oEmail:cBody   	:= 	cEmail
      oEmail:cAnexos     :=  cFile
      oEmail:Envia()
        
      FErase(cFile) 	
                  
Return         

*--------------------------------------------*
  User Function 3USVIEW(cAlias,nReg,nOpcx)      
*--------------------------------------------*   

Local i   
Local nP
Local cTitulo        :="Serie de itens de pedidos"
Local cAliasEnchoice :="ZX2"
Local cAliasGetD     :="ZX3"
Local cLinOk         :="AllwaysTrue()"
Local cTudOk         :="AllwaysTrue()"
Local cFieldOk       :="AllwaysTrue()"
Local aAltEnchoice   :={}			    
Local nOpcE,nOpcG,cAux  
Local cPed   := ""
Local cItem  := ""
Local cCod   := ""
Local cSN    := ""

Local nPPed  := 0
Local nPItem := 0
Local nPCod  := 0
Local nPSN   := 0

If nOpcx==2      //Visualização
   nOpcE:=nOpcG:=2
ElseIf nOpcx==3  //Exclusão
   nOpcE:=nOpcG:=3  
ElseIf nOpcx==5  //Alteração
  nOpcE:=2
  nOpcG:=4      
EndIf   
     
If (ZX2->ZX2_STATUS == "NFS" .And. nOpcE==3  )
   MsgStop("Esse vinculo não pode ser excluído pois o pedido foi faturado, necessário estornar a nota.","EUROSILICONE")
   Return .F.    
EndIf

RegToMemory("ZX2",.F.)

nUsado:=i:=0

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ZX3")

aHeader:={}
aCols:={}
	
While !Eof() .And. (X3_ARQUIVO=="ZX3")

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      nUsado++
      Aadd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO  , X3_PICTURE    ,;
	                      X3_TAMANHO, X3_DECIMAL,If(Empty(X3_VALID),"AllwaysTrue()",X3_VALID),;
    	                  X3_USADO  , X3_TIPO   , X3_ARQUIVO    , X3_CONTEXT } )
   EndIf
   SX3->(DbSkip())
   
EndDo

DbSelectArea("ZX3")
DbSetOrder(2)
DbSeek(xFilial()+M->ZX2_PEDIDO)
	
While !(EOF()) .And. ( M->ZX2_PEDIDO == ZX3->ZX3_PEDIDO  )

   Aadd(aCols,Array(nUsado+1))
   For i:=1 to nUsado
      aCols[Len(aCols),i]:=FieldGet(FieldPos(aHeader[i,2]))
   Next 
   aCols[Len(aCols),nUsado+1]:=.F.
  
   ZX3->(DbSkip())

EndDo

If nOpcx==3
   If MsgYesNo("Deseja realmente excluir vinculo de pedido com serie ? ","EUROSILICONE")
      cAux:=M->ZX2_PEDIDO 
      RecLock("ZX2",.F.)                    
      DbDelete()
      ZX2->(MsUnlock()) 
              
      ZX3->(DbSetOrder(2))  
      If ZX3->(DbSeek(xFilial("ZX3")+cAux)) 
         While ZX3->(!Eof()) .And. cAux==ZX3->ZX3_PEDIDO 
            RecLock("ZX3",.F.)                    
            DbDelete()
            ZX3->(MsUnlock()) 
            
            ZX3->(DbSkip())  
         EndDo
      EndIF                              
   EndIf
   
   Return .F.

EndIf
  
If Len(aCols)>0                                                                                                                                     //Lin Col lin Col   Cab
   If Modelo3(cTitulo ,cAliasEnchoice,cAliasGetD ,     ,cLinOk  ,cTudOk ,nOpcE,nOpcG,cFieldOk,         ,        , aAltEnchoice ,          ,         ,{121,102,750,1400},250 )   
             //cTitulo,cAlias        ,cAlias2    ,aMy  ,cLinhaOk,cTudoOk,nOpcE,nOpcG,cFieldOk, lVirtual, nLinhas, aAltEnchoice , nFreeze , aButtons ,aCordW, nSizeHeader) 
      
   	  //Gravação
      If nOpcX == 5 //Alteração
        
         For i:=1 To Len(aCols)      
            
            //Verifica se não está deletado.
            If !aCols[i][nUsado+1]
               
               nPPed  := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_PEDIDO"})
               cPed   := aCols[i][nPPed]
               nPItem := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_ITEM"})
               cItem  := aCols[i][nPItem]
               nPCod  := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_COD"})
               cCod   := aCols[i][nPCod]
               nPSN   := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_SN"})
               cSN    := aCols[i][nPSN]
               
               //ZX3->(DbSetOrder(2))
               //If ZX3->(DbSeek(xFilial("ZX3")+aCols[i][nPPed]+aCols[i][nPItem]+aCols[i][nPCod]))
               If Select("QRY") > 0
                  QRY->(DbCloseArea())	               
               EndIf
               
               BeginSql Alias 'QRY'
                  SELECT R_E_C_N_O_ AS 'RECNUM'
                  FROM %Table:ZX3%
                  WHERE %notDel%
                    AND ZX3_FILIAL = %exp:xFilial("ZX3")%
                    AND ZX3_PEDIDO = %exp:cPed%
                    AND ZX3_ITEM   = %exp:cItem%
                    AND ZX3_COD    = %exp:cCod%
                    AND ZX3_SN     = %exp:cSN%
               EndSql
               
               QRY->(DbGoTop())
               If QRY->(!BOF() .and. !EOF())
                  
                  ZX3->(DbGoTo(QRY->RECNUM))		
               
                  ZX3->(RecLock("ZX3",.F.))
                    
                  nP := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_P_MEDI"})
                  ZX3->ZX3_P_MEDI := aCols[i][nP]

                  nP := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_P_DESM"})
                  ZX3->ZX3_P_DESM := aCols[i][nP]

                  nP := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_P_PAC"})
                  ZX3->ZX3_P_PAC  := aCols[i][nP]
               
                  nP := aScan(aHeader,{|a| AllTrim(a[2])=="ZX3_P_DESP"})
                  ZX3->ZX3_P_DESP := aCols[i][nP]

                  ZX3->(MsUnlock())
               EndIf   
               
               If Select("QRY") > 0
                  QRY->(DbCloseArea())	               
               EndIf
            
            EndIf
         Next
      EndIf 

   EndIf	
EndIf   

//ZX2->(DbGoTop()) 
 
Return  

*--------------------------------------------*
  User Function 3UEVIEW(cAlias,nReg,nOpcx)      
*--------------------------------------------*   

Local i   
Local cTitulo        :="Serie de itens de nota fiscal de entrada"
Local cAliasEnchoice :="ZX0"
Local cAliasGetD     :="ZX1"
Local cLinOk         :="AllwaysTrue()"
Local cTudOk         :="AllwaysTrue()"
Local cFieldOk       :="AllwaysTrue()"			    
Local nOpcE,nOpcG,cAux  
            
If nOpcx==2      //Visualização
   nOpcE:=nOpcG:=2
ElseIf nOpcx==3  //Exclusão
   nOpcE:=nOpcG:=3         
EndIf   
     
If ( nOpcE==3 .And. ZX0->ZX0_STATUS="SEM" )  
   MsgStop("Esse registro só será excluído caso a nota seja excluída em Movimentos Internos.","EUROSILICONE")
   Return .F.    
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
DbSetOrder(2)
DbSeek(xFilial()+M->ZX0_DOC+M->ZX0_SERIE)
	
While !(EOF()) .And. ( M->ZX0_DOC+M->ZX0_SERIE == ZX1->ZX1_DOC+ZX1->ZX1_SERIE )

   Aadd(aCols,Array(nUsado+1))
   For i:=1 to nUsado
      aCols[Len(aCols),i]:=FieldGet(FieldPos(aHeader[i,2]))
   Next 
   aCols[Len(aCols),nUsado+1]:=.F.
  
   ZX1->(DbSkip())

EndDo 

If nOpcx==3 
   
   If  ZX0->ZX0_STATUS=="FAT" 
      MsgStop("Essa nota não pode ser excluída pois possui faturamento","EUROSILICONE") 
      Return .F. 
   EndIf

   If MsgYesNo("Deseja realmente excluir vinculo da nota com as series ? ","EUROSILICONE")
      cAux:=M->ZX0_DOC+M->ZX0_SERIE
      RecLock("ZX0",.F.)                    
      ZX0->ZX0_STATUS:="SEM"
      ZX0->(MsUnlock()) 
              
      ZX1->(DbSetOrder(2))  
      If ZX1->(DbSeek(xFilial("ZX1")+cAux)) 
         While ZX1->(!Eof()) .And. cAux==ZX1->ZX1_DOC+ZX1->ZX1_SERIE
            
            RecLock("ZX1",.F.)                    
            ZX1->ZX1_STATUS:="SEM"  
            ZX1->ZX1_CODBAR:=""
            ZX1->ZX1_REF   :="" 
            ZX1->ZX1_SIZE  :=""  
            ZX1->ZX1_SN    :=""
            ZX1->ZX1_LOTE  :=""
            ZX1->(MsUnlock()) 
            
            ZX1->(DbSkip())  
         EndDo
      EndIF                              
   EndIf
   
   //ZX0->(DbGoTop())
   
   Return .F.

EndIf              
  
If Len(aCols)>0                                                                                                                                  //Lin Col lin Col   Cab
   Modelo3(cTitulo ,cAliasEnchoice,cAliasGetD ,     ,cLinOk  ,cTudOk ,nOpcE,nOpcG,cFieldOk,         ,        ,              ,          ,         ,{121,102,750,1400},250 )   
          //cTitulo,cAlias        ,cAlias2    ,aMy  ,cLinhaOk,cTudoOk,nOpcE,nOpcG,cFieldOk, lVirtual, nLinhas, aAltEnchoice , nFreeze , aButtons ,aCordW, nSizeHeader) 
EndIf   

ZX0->(DbGoTop())

Return 

//Tela para gravação da serie dos produtos / entrada.
*-----------------------------------------------*
  User Function 3UEINSERT(cAlias,nReg,nOpcx)
*-----------------------------------------------*         

Local Odlg, oMain,Odlg1, oMain1 ,olbx
Local cCliente,cCliDes,cNome,cProduto,cDesc,cQtd,cLocal,cUM,cLoteCtl,cDtVal,cOk:="OK"
Local lRefresh:=.T.  
Local lCorrigi:=lErroLote:=lOK:=lErroSerie:=lExist:=lSerieDif:=.F.
Local cAuxSerie:=Space(25)
Local cSerie :=Space(24) 
Local cRef   :=Space(3) 
Local cSize  :=Space(5)  
Local cSn    :=Space(9)
Local cLote  :=Space(6)   
Local aItens :={}
Local aItensErro:={}  
Local cChr    := ""

   If ZX0->ZX0_STATUS=="SER"
      MsgStop("Essa nota já possui serie informada.","EUROSILICONE") 
      Return .F.
   EndIF    
   
   
   If ZX0->ZX0_STATUS=="FAT"
      MsgStop("Essa nota já possui serie informada e nota de saida","EUROSILICONE") 
      Return .F.
   EndIF           
            
     
   ZX1->(DbGoTop())    
   ZX1->(DbSetOrder(2))
   If ZX1->(DbSeek(xFilial("ZX1")+ZX0->ZX0_DOC+ZX0->ZX0_SERIE))
      
      While ZX1->(!EOF()) .And. ZX0->ZX0_DOC+ZX0->ZX0_SERIE == ZX1->ZX1_DOC+ZX1->ZX1_SERIE
   
	     DEFINE MSDIALOG oDlg TITLE  "SEQ "+Alltrim(ZX1->ZX1_ITEM)+" Produto "+Alltrim(ZX1->ZX1_COD)+" Nota "+Alltrim(ZX1->ZX1_DOC)+" Serie "+Alltrim(ZX1->ZX1_SERIE)  From 1,10 To 22,080 OF oMain
   
            nLin1:=005 
            nCol1:=005           
         
            cCliente:=ZX0->ZX0_CLIENT
            @ nLin1+8,nCol1+5 SAY "CLIENTE :"  PIXEL SIZE 80,30 OF oDlg  
            @ nLin1+6,nCol1+50 get cCliente WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 50,5 OF oDlg 
         
            @ nLin1+8,nCol1+100 SAY "NOME :"  PIXEL SIZE 100,10 OF oDlg 
            cCliDes:=Alltrim(ZX0->ZX0_CLIDES)
            @ nLin1+6,nCol1+120 Get Alltrim(cCliDes) COLOR CLR_HBLUE, CLR_WHITE  WHEN .F.   PIXEL SIZE 140,5 OF oDlg
         
            @ nLin1+24,nCol1+5 SAY "PRODUTO :"  PIXEL SIZE 80,10 OF oDlg  
            cProduto:=Alltrim(ZX1->ZX1_COD)
            @ nLin1+22,nCol1+50 Get cProduto  WHEN .F.  COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 50,10 OF oDlg 
         
            @ nLin1+24,nCol1+100 SAY "DESC. :"  PIXEL SIZE 80,10 OF oDlg          
            SB1->(DbSetOrder(1))
            If SB1->(DbSeek(xFilial("SB1")+ZX1->ZX1_COD)) 
               cDesc:=Alltrim(SB1->B1_DESC) 
               @ nLin1+22,nCol1+120 get cDesc WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 140,10 OF oDlg
            EndIf
         
            cQtd:=ZX1->ZX1_QTD
            @ nLin1+40,nCol1+5 SAY "QUANTIDADE :"  PIXEL SIZE 80,10 OF oDlg    
            @ nLin1+38,nCol1+50 get cQtd WHEN .F. PICTURE "9999.99" COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 32,10 OF oDlg 
                                                                      
            cLocal:=Alltrim(ZX1->ZX1_LOCAL)                               
            @ nLin1+40,nCol1+100 SAY "LOCAL:"  PIXEL SIZE 80,10 OF oDlg  
            @ nLin1+38,nCol1+120 get cLocal WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 10,10 OF oDlg  
         
            cUM:=Alltrim(SB1->B1_UM)
            @ nLin1+40,nCol1+150 SAY "UNIDADE :"  PIXEL SIZE 80,10 OF oDlg
            @ nLin1+38,nCol1+179 get cUM WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 10,10 OF oDlg   
         
            If lLote
         
               cLoteCTL:=Alltrim(ZX1->ZX1_LOTE)
               @ nLin1+57,nCol1+5  SAY "LOTE DO PEDIDO:"  PIXEL SIZE 80,10 OF oDlg   
            
               //cDtVal:=SC9Temp->C9_DTVALID                  
               //@ nLin1+57,nCol1+100 SAY "VALIDADE DO LOTE"  PIXEL SIZE 80,10 OF oDlg    
               //@ nLin1+54,nCol1+155 get cDtVal WHEN .F. COLOR CLR_HBLUE, CLR_WHITE  PIXEL SIZE 25,10 OF oDlg    
         
            EndIf
         
            If lLote          
        
               If lErroLote 
                  @ nLin1+54,nCol1+50 get cLoteCTL WHEN .F. COLOR CLR_HRED, CLR_WHITE  PIXEL SIZE 25,10 OF oDlg  
               Else
                   @ nLin1+54,nCol1+50 get cLoteCTL WHEN .F. COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 25,10 OF oDlg  
               EndIf 
        
            EndIf 
                                                               
            If lRefresh
               @ nLin1+75,nCol1+100 Get cSerie  PIXEL SIZE 100,10 OF oDlg  
            Else
               @ nLin1+75,nCol1+100 Get cSerie WHEN .F. PIXEL SIZE 100,10 OF oDlg
               If lErroSerie     
                  cOk:="Error"
                  @ nLin1+75,nCol1+205 Get cOk WHEN .F. COLOR CLR_HRED PIXEL SIZE 10,10 OF oDlg               
               Else
                  @ nLin1+75,nCol1+205 Get cOk WHEN .F. COLOR CLR_HBLUE PIXEL SIZE 10,10 OF oDlg  
               EndIf
            EndIf
                  
            @ nLin1+90,nCol1+100 Get cRef  WHEN .F. PIXEL SIZE 15,10 OF oDlg 
            @ nLin1+103,nCol1+100  SAY "REF "  PIXEL SIZE 80,10 OF oDlg 
                  
            @ nLin1+90,nCol1+128 Get cSize WHEN .F. PIXEL SIZE 15,10 OF oDlg 
            @ nLin1+103,nCol1+128  SAY "SIZE "  PIXEL SIZE 80,10 OF oDlg  
                   
            @ nLin1+90,nCol1+160 Get cSN   WHEN .F. PIXEL SIZE 30,10 OF oDlg
            @ nLin1+103,nCol1+160  SAY "SN "  PIXEL SIZE 80,10 OF oDlg    
                  
            @ nLin1+103,nCol1+200  SAY "LOTE"  PIXEL SIZE 80,10 OF oDlg
     
         
            If lLote
               If lErroLote       
                  @ nLin1+75,nCol1+5 TO nLin1+130,nCol1+90 LABEL "" OF oDlg PIXEL OF oDlg 
                  @ nLin1+80,nCol1+35   SAY "ATENCAO " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
                  @ nLin1+95,nCol1+08   SAY "  Lote do pedido diferente do  " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
                  @ nLin1+105,nCol1+08  SAY "  em outro produto ou possui "   COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
                  @ nLin1+115,nCol1+08  SAY "divergência no código REF+SIZE" COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
               Else    
                  @ nLin1+78,nCol1+10  SAY "Informe o numero de serie : "  PIXEL SIZE 80,10 OF oDlg 
                  @ nLin1+90,nCol1+200 Get cLote WHEN .F. PIXEL SIZE 40,10 OF oDlg
               EndIf 
            Else 
               If !(lErroSerie)
                  @ nLin1+78,nCol1+10  SAY "Informe o numero de serie : "  PIXEL SIZE 80,10 OF oDlg 
               EndIf   
               @ nLin1+90,nCol1+200 Get cLote WHEN .F. PIXEL SIZE 40,10 OF oDlg              
            EndIf      
         
            If lErroSerie
               @ nLin1+75,nCol1+5 TO nLin1+130,nCol1+90 LABEL "" OF oDlg PIXEL OF oDlg 
               @ nLin1+80,nCol1+35   SAY "ATENCAO " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg  
               @ nLin1+95,nCol1+08   SAY "A serie informada já foi utilizada  " COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
               @ nLin1+105,nCol1+08  SAY "  em outro produto ou possui "   COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
               @ nLin1+115,nCol1+08  SAY "divergência no código (REF+SIZE)" COLOR CLR_HRED PIXEL SIZE 300,10 OF oDlg 
            EndIf
        
            @ nLin1,nCol1 TO nLin1+145,nCol1+267 LABEL "" OF oDlg PIXEL OF oDlg         // Caixa do botao
                 
            @ 130,130 BUTTON "Proximo"    size 40,12 ACTION( Processa({|| lOk:=.T.,oDlg:End()})) of oDlg Pixel
            @ 130,210 BUTTON "Cancelar"   size 40,12 ACTION(lOK:=.F.,oDlg:End()) of oDlg Pixel 
            @ 130,170 BUTTON "Corrigir"   size 40,12 ACTION(lCorrigi:=.T.,lErroLote:=.F.,lErroSerie:=.F.,oDlg:End()) of oDlg Pixel  
         

         ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())   
         
         If lLote     
            If lErroLote  .And. lOK
               MsgStop("Numero do lote da leitura incopativel com o do pedido venda/NF entrada, necessário corrigi-lo.","EUROSILICONE")               
               Loop 
            EndIf
         EndIf        
      
         If lErroSerie .And. lOk 
            MsgStop("A serie informada já foi incluída.","EUROSILICONE")               
            Loop       
         EndIf
                            
         If lCorrigi    
      
            cSerie :=Space(24) 
            cRef   :=Space(3) 
            cSize  :=Space(5)  
            cSn    :=Space(9)
            cLote  :=Space(6)   
         
            cOk:="OK"
         
            lRefresh:=.T.
            lCorrigi:=.F.
         
            Loop         
         EndIf
      
         If ( Len(alltrim(cSerie)) == 24 .Or.  Len(alltrim(cSerie)) == 23 .Or. Len(alltrim(cSerie)) == 22 ) .And. (lRefresh)       
                              
            lRefresh:=.F.   
         
            nPos:=At(".",Alltrim(cSerie)) 
            cChr := "."
            
            If nPos == 0
               nPos:=At("+",Alltrim(cSerie)) 
               cChr := "+"
            EndIf
            
            //Valida o "ponto" e o "mais"       
            If nPos == 0
               lErroSerie:=.T.
            EndIf     
           
            If nPos == 6 
               If len(alltrim(cSerie))== 23  
                  cRef  := substr(cSerie,1,2)
                  cSize := substr(cSerie,3,3)+"cc"
                  cSN   := substr(cSerie,8,9)
                  cLote := substr(cSerie,18,6)        
               Else   
                  cRef  := substr(cSerie,1,2)
                  cSize := substr(cSerie,3,3)+"cc"
                  cSN   := substr(cSerie,8,8)
                  cLote := substr(cSerie,17,6)
               EndIf       
            Else
               If len(alltrim(cSerie))== 24  
                  cRef  := substr(cSerie,1,3)
                  cSize := substr(cSerie,4,3)+"cc"
                  cSN   := substr(cSerie,9,9)
                  cLote := substr(cSerie,19,6)        
               Else 
               		If cChr == "+" .and. IsAlpha(Substr(cSerie,nPos-1,1))
                  		cRef  := substr(cSerie,1,2) + substr(cSerie,6,1)
                  		cSize := substr(cSerie,3,3)+"cc"
                  		cSN   := substr(cSerie,9,8)
                  		cLote := substr(cSerie,18,6)
               		Else
                  		cRef  := substr(cSerie,1,3)
                  		cSize := substr(cSerie,4,3)+"cc"
                  		cSN   := substr(cSerie,9,8)
                  		cLote := substr(cSerie,18,6)
                   EndIF
               EndIf      
            EndIf     
           
            If lLote
               If cLote<>Alltrim(SC9Temp->C9_LOTECTL)
                  lErroLote:=.T.
               EndIf
            EndIf   
         
            If aScanX(aItens,{ |X,Y|  X[9] == UPPER(cSerie)     }) > 0 
                lErroSerie:=.T.
            EndIf 
         
            If Alltrim(ZX1->ZX1_COD)<> Alltrim(cRef)+Alltrim(Substr(cSize,1,3))
                lErroSerie:=.T.
            EndIf 
            
            If Substr(cRef,1,1)==" " .Or. Substr(cRef,1,1)=="  " 
               lErroSerie:=.T.
            EndIf
         
         
            Loop
         EndIf 
                  
         If !(lOk)
            If MsgYesNo("Tem certeza que deseja cancelar, todas as informações serão perdidas","EUROSILICONE")
               Return .F.
            Else  
               Loop
            EndIf    
         EndIf
      
         If lOk                            
      
            If Len(alltrim(cSerie)) == 24 .Or. Len(alltrim(cSerie)) == 23 .Or. Len(alltrim(cSerie)) == 22 
            
               Aadd(aItens,{ZX1->ZX1_DOC,ZX1->ZX1_SERIE,ZX1->ZX1_ITEM,ZX1->ZX1_COD,ZX1->ZX1_QTD,ZX1->ZX1_LOCAL,ZX1->ZX1_CLIENTE,ZX1->ZX1_LOJA,UPPER(cSerie),UPPER(cRef),UPPER(cSize),UPPER(cSn),UPPER(cLote),ZX1->ZX1_TIPO,ZX1->ZX1_NFORI,ZX1->ZX1_SERIOR,ZX1->ZX1_LOCAL})
         
               cSerie :=Space(24) 
			   cRef   :=Space(3) 
			   cSize  :=Space(5)  
			   cSn    :=Space(9)
			   cLote  :=Space(6)
               lRefresh:=.T.                
               ZX1->(DbSkip())
           
            Else 
            
               MsgAlert("Numero de serie inválido, informe novamente","EUROSILICONE")  
               cSerie :=Space(24)
           
            EndIf           
      
         EndIf                

      EndDo      
   
   EndIf
   
   If len(aItens) > 0
      
      ZX1->(DbSetOrder(2))     
      For i:=1 to Len(aItens)
         If aItens[i][14] $ 'D/B'
            //Ajusta o tamanho da serie
            ZX3->(DbSetOrder(3)) 
            If Len(aItens[i][9]) == 23
               cAuxSerie:=aItens[i][9]+"  "
            ElseIf Len(aItens[i][9]) == 24
               cAuxSerie:=aItens[i][9]+" "
            EndIf        
            //Verifica se as series informadas existem na saída
            If ZX3->(DbSeek(xFilial("ZX3")+cAuxSerie+aItens[i][15]+aItens[i][16])) 
               ZX1->(DbSeek(xFilial("ZX1")+aItens[i][1]+aItens[i][2]))
               If Alltrim(ZX1->ZX1_NFORI) <> Alltrim(ZX3->ZX3_DOC)
                  Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][4],aItens[i][9],Alltrim(aItens[i][15]),Alltrim(aItens[i][16]),Alltrim(ZX3->ZX3_PEDIDO),Alltrim(ZX3->ZX3_DOC)})
                  lSerieDif:=.T.
               EndIf
            Else                    
               //If aItens[i][17] <> "03"
                  Aadd(aItensErro,{aItens[i][1],aItens[i][2],aItens[i][3],aItens[i][4],aItens[i][9],"||","Não encontrado","Não encontrado","Não encontrado","Não encontrado","Não encontrado"})                    
                  lExist:=.T. 
               //EndIf   
            EndIf 
         EndIf
      Next     
            
      If lSerieDif 
                                                                                                
         MsgStop("Atenção existe serie(s) cadastrada(s) que não foi entrada na nota de saída, clique em OK para ver analise.","EUROSILICONE")
      
         DEFINE MSDIALOG oDlg1 TITLE  "Produto(s) serie com problema(s) " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "NF ENT","SER","PROD","SERIE","NF ORIGEM","SER ORI","PEDIDO","NF ENCONTRADA" COLSIZES 20,20,20,20,20,20,20,20  COLOR CLR_HRED,CLR_HRED SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItensErro)
            olbx:bLine:={|| {aItensErro[olbx:nAt,1],aItensErro[olbx:nAt,2],aItensErro[olbx:nAt,3],aItensErro[olbx:nAt,4],aItensErro[olbx:nAt,5],aItensErro[olbx:nAt,6],aItensErro[olbx:nAt,7],aItensErro[olbx:nAt,8] }}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())  
      
         MsgAlert("Nenhum vinculo foi gravado","EUROSILICONE")  
         
         Return .F.
      
      ElseIf lExist  
         
         MsgStop("Atenção existe serie(s) cadastrada(s) que não foi entrada na nota de saída, clique em OK para ver analise.","EUROSILICONE")
      
         DEFINE MSDIALOG oDlg1 TITLE  "Produto(s) com problema(s) " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "NF ENT","SER","SEQ","PROD","SERIE","","NF ORIGEM","SER ORI","SEQ","PRODUTO","SERIE" COLSIZES 20,15,35,35,30,10,15,30,30,30,30  COLOR CLR_HRED,CLR_HRED SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItensErro)
            olbx:bLine:={|| {aItensErro[olbx:nAt,1],aItensErro[olbx:nAt,2],aItensErro[olbx:nAt,3],aItensErro[olbx:nAt,4],aItensErro[olbx:nAt,5],aItensErro[olbx:nAt,6],aItensErro[olbx:nAt,7],aItensErro[olbx:nAt,8],aItensErro[olbx:nAt,9],aItensErro[olbx:nAt,10],aItensErro[olbx:nAt,11] }}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())  
      
         MsgAlert("Nenhum vinculo foi gravado","EUROSILICONE")  
         
         Return .F.
            
      Else
      
         DEFINE MSDIALOG oDlg1 TITLE  "Produtos gravados " From 1,10 To 20,100 OF oMain1      
                          
            @ 5,5 ListBox olbx FIELDS HEADER "NOTA","SERIE","SEQ","PRODUTO","QTD","ARM","CLIENTE","LOJA","SERIE","REF","SIZE","SN","LOTE" COLSIZES 35,15,35,15,15,35,20,35,20,20,20,20 SIZE 346,135 of ODLG1 PIXEL
            olbx:SetArray(aItens)
            olbx:bLine:={|| {aItens[olbx:nAt,1],aItens[olbx:nAt,2],aItens[olbx:nAt,3],aItens[olbx:nAt,4],aItens[olbx:nAt,5],aItens[olbx:nAt,6],aItens[olbx:nAt,7],aItens[olbx:nAt,8],aItens[olbx:nAt,9],aItens[olbx:nAt,10],aItens[olbx:nAt,11],aItens[olbx:nAt,12],aItens[olbx:nAt,13] }}          
                 
         ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh())     

      EndIf
      
      RecLock("ZX0",.F.)             
      ZX0->ZX0_STATUS:="SER"
      ZX0->(MsUnlock())       
             
      ZX1->(DbSetOrder(4))
      For i:=1 to len(aItens)      
                         
         If ZX1->(DbSeek(xFilial("ZX1")+aItens[i][3]+aItens[i][4]+aItens[i][1]+aItens[i][2]))                
                             
            RecLock("ZX1",.F.)
            ZX1->ZX1_CODBAR  := aItens[i][9]
            ZX1->ZX1_REF     := aItens[i][10]
            ZX1->ZX1_SIZE    := aItens[i][11] 
            ZX1->ZX1_SN      := aItens[i][12]
            ZX1->ZX1_LOTE    := aItens[i][13]
            ZX1->ZX1_STATUS  := "SER"   
            ZX1->(MsUnlock())
            
         EndIf    
      
      Next  
                                            
      //E-mail
      cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
      cEmail += '<title>Nova pagina 1</title></head><body>'
      cEmail += '<p align="center"><font face="Courier New" size="2"><u><b>
      cEmail += 'Dados da inclusão da serie Ok</b></u></font></p>'   
      cEmail += '<p><font face="Courier New" size="2">Documento: '+ZX1->ZX1_DOC +' serie: '+ZX1->ZX1_SERIE 
      cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <br>' 
      
      If ZX1->ZX1_TIPO $ 'B/D'      
         cEmail += 'Cliente&nbsp;&nbsp;&nbsp;&nbsp; : '+ZX1->ZX1_CLIENT      
         SA1->(DbSetOrder(1))
         If SA1->(DbSeek(xFilial("SA1")+Alltrim(aItens[1][6]) ))
            cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(SA1->A1_NOME)+'<br>'   
         EndIf  
      Else
         cEmail += 'Fornecedor&nbsp;&nbsp;&nbsp;&nbsp; : '+ZX1->ZX1_CLIENT      
         SA2->(DbSetOrder(1))
         If SA2->(DbSeek(xFilial("SA2")+Alltrim(aItens[1][6]) ))
            cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    : '+Alltrim(SA2->A2_NOME)+'<br>'   
         EndIf 
      
      EndIf
      cEmail += '<br>'   
      cEmail += '<br>'   
      cEmail += '<p align="center">Essa mensagem foi gerada automaticamente e não pode ser respondida.</p> '
      cEmail += '<p align="center">www.grantthornton.com.br</p>'
      cEmail += '</body></html>'
	  
      cFile := "\SYSTEM\"+aItens[1][1]+".html"
      nHdl := FCreate( cFile )
      FWrite( nHdl,  cEmail, Len( cEmail ) )
      FClose( nHdl )      
         
      oEmail           :=  DEmail():New()
      oEmail:cFrom   	:= 	AllTrim(GetMv("MV_RELFROM"))
      oEmail:cTo		:=  AllTrim(GetMv("MV_P_EXP"))   // Ex: "tiago.mendonca@pryor.com.br" 
      oEmail:cSubject	:=	" Nota de entrada " +Alltrim(ZX1->ZX1_DOC)+' serie: '+ZX1->ZX1_SERIE+" liberado para transmissao - Expedicao"
      oEmail:cBody   	:= 	cEmail
      oEmail:cAnexos     :=  cFile
      oEmail:Envia()
        
      FErase(cFile) 	
      
      
     
   ZX0->(DbGoTop())
    
   EndIf    
      
Return         
                            
//Seleciona o pedido para inclusão de serie.
*--------------------------------------------*
  User Function 3USINSERT(cAlias,nReg,nOpcx)      
*--------------------------------------------*    

Local cItem  
Local oDlg,oMain
Local lOK:=.F.  
Local cGet   :=Space(6)  

   DEFINE MSDIALOG oDlg TITLE "Selecionar o pedido" From 1,7 To 10,39 OF oMain     
   
      @ 015,008 SAY "Escolha o pedido : "  PIXEL SIZE 60,30 OF oDlg 
      @ 015,070 Get cGet  F3 "SC5" 
      @ 035,040 BMPBUTTON TYPE 1 ACTION(lOk:=.T.,oDlg:End()) 
      @ 035,070 BMPBUTTON TYPE 2 ACTION(lOk:=.F.,oDlg:End()) 

   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
   
   
   If Alltrim(cGet) == "" .And. lOK 
      MsgStop("O pedido não pode ser em branco","EUROSILICONE")
   EndIf   
    
   If lOK .and. Alltrim(cGet) <> "" 
      SC9->(DbSetOrder(1))
      If SC9->(DbSeek(xFilial("SC9")+Alltrim(cGet)))     
         If Alltrim(SC9->C9_BLEST) == "" //.And. SC9->C9_OK == "" 
            SelectSC9(cGet)
            GrvSnfs()  
         ElseIf Alltrim(SC9->C9_NFISCAL) <> ""
            MsgStop("Pedido já faturado, verifique com o Dep. responsavel","EUROSILICONE")
         Else
            MsgStop("Pedido bloqueado em Credito ou Estoque, verifique com o Dep. responsavel","EUROSILICONE")        
         EndIf           
      Else  
         MsgStop("Pedido não liberado, verifique com o Dep. responsavel","EUROSILICONE")
      EndIf   
   EndIf 
   
   ZX2->(DbGoTop()) 
                  
Return 
                    
//Carrega dos dados pedidos.
*---------------------------------*
  Static Function SelectSC9(cPed)
*---------------------------------*

Local aStruSC9:= SC9->(DbStruct())      
Local cQuery  := ""        
Local nAux        

If Select("WORK")>0
   WORK->(DbCloseArea())    
EndIf

If Select("SC9TEMP") > 0
   SC9TEMP->(DbCloseArea())
EndIf  

cQuery:=" SELECT C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_LOCAL,C9_CLIENTE,C9_LOJA,C9_LOTECTL,C9_DTVALID,C9_QTDLIB  "
cQuery+=" FROM "+RetSqlName("SC9")+" 
cQuery+=" WHERE  D_E_L_E_T_ <> '*' AND C9_PEDIDO='"+Alltrim(cPed)+"'"
cQuery+=" AND C9_BLEST <> '10'  AND  C9_BLEST <> '02' AND  C9_BLEST <> '03' "
cQuery+=" ORDER BY C9_PEDIDO"    

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'WORK',.F.,.T.)

For nI := 1 To Len(aStruSC9)
	If aStruSC9[nI][2] <> "C" .and.  FieldPos(aStruSC9[nI][1]) > 0
		TcSetField("WORK",aStruSC9[nI][1],aStruSC9[nI][2],aStruSC9[nI][3],aStruSC9[nI][4])
	EndIf
Next nI


// Alterado para desagrupar os itens.
aCampos := {   {"C9_ITEM"   ,"C",3,0 } ,;
               {"C9_PEDIDO" ,"C",6,0 } ,;
               {"C9_PRODUTO","C",15,0} ,;
               {"C9_CLIENTE","C",06,0} ,;
               {"C9_LOJA"   ,"C",2,0 } ,;
               {"C9_QTDLIB" ,"N",10,2} ,;
               {"C9_LOCAL"  ,"C",02,0} ,;
               {"C9_LOTECTL","C",10,0} ,; 
               {"C9_DTVALID","D",08,0}} 
               
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,"SC9TEMP",.F.,.F.)

Work->(DbGoTop()) 
While Work->(!EOF()) 

   nAux:=Work->C9_QTDLIB
          
   For i:=1 to nAux
   
      RecLock("SC9TEMP",.T.)
      SC9Temp->C9_PEDIDO   :=Work->C9_PEDIDO
      SC9Temp->C9_ITEM     :=Work->C9_ITEM
      SC9Temp->C9_PRODUTO  :=Work->C9_PRODUTO
      SC9Temp->C9_QTDLIB   :=1
      SC9Temp->C9_LOCAL    :=Work->C9_LOCAL
      SC9Temp->C9_CLIENTE  :=Work->C9_CLIENTE
      SC9Temp->C9_LOJA     :=Work->C9_LOJA
      SC9Temp->C9_LOTECTL  :=Work->C9_LOTECTL
      SC9Temp->C9_DTVALID  :=Work->C9_DTVALID                        
      SC9TEMP->(MsUnlock())  
      
   Next
   
   Work->(DbSkip())
   
EndDo


/*
Funcao      : Cadastro de medicos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 16/12/2010
*/  

*----------------------------*
  User Function 3UFATMED()
*----------------------------*  

If cEmpAnt $ "3U"
   AxCadastro("ZX5","Cadastro de medicos",".T.",".T.")
Else
   MsgStop("Especifico EUROSILICONE","EUROSILICONE")
EndIf   
   
Return  


/*
Funcao      : Cadastro de endereço de entrega
Autor       : Tiago Luiz Mendonça
Data/Hora   : 22/12/2010
*/  

*----------------------------*
  User Function 3UFATENT()
*----------------------------*  

If cEmpAnt $ "3U"
   AxCadastro("ZX6","Cadastro de local de entrega",".T.",".T.")
Else
   MsgStop("Especifico EUROSILICONE","EUROSILICONE")
EndIf   
     
Return   

/*
Funcao      : Cadastro de de pacientes
Autor       : Tiago Luiz Mendonça
Data/Hora   : 22/12/2010
*/  

*----------------------------*
  User Function 3UPACIENT()
*----------------------------*  

If cEmpAnt $ "3U"
   AxCadastro("ZX7","Cadastro de pacientes",".T.",".T.")
Else
   MsgStop("Especifico EUROSILICONE","EUROSILICONE")
EndIf   
     
Return 


   
