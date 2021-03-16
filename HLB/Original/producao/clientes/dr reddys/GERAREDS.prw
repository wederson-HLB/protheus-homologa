#include "rwmake.ch"
#include "colors.ch"
#include "topconn.ch" 
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"

/*
Funcao      : REDS_ATIVA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Interface Dr. Red's / Ativa - Gerar arquivo TXT para o FTP da Ativa.
Autor     	: Tiago Luiz Mendon�a
Data     	: 08/09/08 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Faturamento.
*/

          
// Fun��o Principal.
*---------------------------*
  User Function REDS_ATIVA()  
*----------------------------*

Private Odlg, oCheck, oMain, cIdAux, cTemp, cIndex  
Private dUlDestin:=dUlProdut:=dUlNfEntr:=dUlLibqua:=dUlPedido:=dUlNfSaid:=dDtIni:=dDtFim:=CTOD("")  
Private tUlDestin:=tUlProdut:=tUlNfEntr:=tUlLibqua:=tUlPedido:=tUlNfSaid:=""  
Private cEmp,nOpc,cFil  
Private lDESTIN:=lPRODUT:=lNFENTR:=lLIBQUA:=lPEDIDO:=lNFSAID:=lAut:=.F. 
Private cIdDestin,cIdProdut,cIdNfEntr,cIdLibqua,cIdPedido,cIdNfSaid
Private cIdDestinProx,cIdProdutProx,cIdNfEntrProx,cIdLibquaProx,cIdPedidoProx,cIdNfSaidProx
Private lDest:=lProd:=lNfE:=lLib:=lPed:=lNfS:=lCheck:=.T.

If !(cEmpAnt $ "U2" .Or. cEmpAnt $ "99" )  
   MsgStop("Rotina especifica Dr Reddys","Aten��o") 
   Return .F.
EndIf

Private cDir:=GetMV("MV_RED_PAT") 
Private cDirDestin:=cDir+"CLI\"
Private cDirProdut:=cDir+"PRD\"
Private cDirNfEntr:=cDir+"NFE\"
Private cDirPedido:=cDir+"PED\"
Private cDirNfSaid:=cDir+"NFS\"
Private cImg:="\System\P10.bmp"
Private cImg1:="\System\PryorLogoTec.bmp" 
Private cImg2:="\System\Pryor"
Private cImg3:="\System\pryor.bmp"


DbSelectArea("SM0") 
ChkFile("ZRD")            
cFil:=Alltrim(SM0->M0_CODFIL)            
            
//lAut:=GetMv("MV_RED_AUT")  N�o testado em modo automatico com JOB para gera��o dos arquivos.

// Pega a numera�ao do �ltimo arquivo enviado, atrav�s do SX6            
If SX6->(DbSeek(XFilial()+"MV_RED_DES"))
   cIdDestin := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdDestin,2,08))
   cIdAux := cIdAux+1
   cIdDestinProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".CLI"
EndIf 

If SX6->(DbSeek(XFilial()+"MV_RED_PRO"))
   cIdProdut := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdProdut,2,08))               
   cIdAux := cIdAux+1 
   cIdProdutProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".PRD"
EndIf 

If SX6->(DbSeek(XFilial()+"MV_RED_NFE"))
   cIdNFEntr := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdNFEntr,2,08))
   cIdAux := cIdAux+1
   cIdNfEntrProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".NFE"
EndIf 

/*
If SX6->(DbSeek(XFilial()+"MV_RED_LIB"))
   cIdLibqua := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdLibqua,2,08))
   cIdLibquaProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux+1))+".LBQ"
EndIf */ 

If SX6->(DbSeek(XFilial()+"MV_RED_PED"))
   cIdPedido := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdPedido,2,08))
   cIdAux := cIdAux+1
   cIdPedidoProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".PED"
EndIf 

If SX6->(DbSeek(XFilial()+"MV_RED_NFS"))
   cIdNFSaid := Alltrim(SX6->X6_CONTEUD) 
   cIdAux := Val(Substr(cIdNFSaid,2,08))
   cIdAux := cIdAux+1
   cIdNfSaidProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".NFS"
EndIf    
         
If !(lAut)  // Caso a rotina seja autom�tica, a tela n�o deve ser executada.

   ZRD->(DbSetOrder(2))
   ZRD->(DbGoBottom()) 
 
   // Carrega a data e hora do ultimo arquivo enviado para DIALOG caso o envio seja manual.
   While ZRD->(!BOF()) .And. lCheck
        
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTDESTIN"+"Gravado FTP   " .And. lDest
         dUlDestin:=ZRD->ZRD_DATA
         tUlDestin:=ZRD->ZRD_HORA  
         lDest:=.F.
      EndIf
   
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTPRODUT"+"Gravado FTP   " .And. lProd
         dUlProdut:=ZRD->ZRD_DATA
         tUlProdut:=ZRD->ZRD_HORA
         lProd:=.F.
      EndIf
   
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTNFENTR"+"Gravado FTP   " .And. lNfE
         dUlNfEntr:=ZRD->ZRD_DATA
         tUlNfEntr:=ZRD->ZRD_HORA
         lNfE:=.F.
      EndIf
   
      /* Tratamento n�o disponivel.
   
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTLIBQUA"+"Gravado FTP   " .And. lLib
         dUlLibqua:=ZRD->ZRD_DATA
         tUlLibqua:=ZRD->ZRD_HORA
         lLib:=.F.
      EndIf
   
      */
   
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTPEDIDO"+"Gravado FTP   " .And. lPed
         dUlPedido:=ZRD->ZRD_DATA
         tUlPedido:=ZRD->ZRD_HORA
         lPed:=.F.
      EndIf
    
      If ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == SM0->M0_CODFIL+"TXTNFSAID"+"Gravado FTP   " .And. lNfS
         dUlNfSaid:=ZRD->ZRD_DATA
         tUlNfSaid:=ZRD->ZRD_HORA
        lNfS:=.F.
      EndIf
    
      // Caso a data e hora de todos os arquivos sejam preenchidos, sae do loop.       
      If !(lDest) .And. !(lProd) .And. !(lNfE) .And. !(lPed) .And. !(lNfs) // .And. !(lLib)      
         lCheck:=.F.
      EndIf
        
      ZRD->(DbSkip(-1))
   
   EndDo
                                                                             
   DEFINE MSDIALOG oDlg TITLE  "Exporta��o de Arquivo TXT - Dr. Reds / Ativa "  From 1,10 To 30,101 OF oMain
   
   nLin1:=010 
   nLin2:=122
   nCol1:=010
   nCol2:=105

   @ nLin1    ,nCol1     TO nLin2,   nCol2     LABEL " Selecione o arquivo para o envio " OF oDlg PIXEL
   @ nLin1    ,nCol1+098 TO nLin2   ,nCol2+142 LABEL " Data e Hora do �ltimo arquivo gravado FTP" OF oDlg PIXEL   
   @ nLin1    ,nCol1+240 TO nLin2   ,nCol2+243 LABEL " Numera��o do �ltimo arquivo gerado" OF oDlg PIXEL
   @ nLin1+115,nCol1     TO nLin2+55,nCol2+243 LABEL "" OF oDlg PIXEL  // Caixa do superior    
   @ nLin1+170,nCol1     TO nLin2+90,nCol1+195 LABEL "" OF oDlg PIXEL  // Caixa inferior   
   @ nLin1+170,nCol1+200 TO nLin2+90,nCol2+243 LABEL "" OF oDlg PIXEL  // Caixa do botao
 
   nLin:=028  
   nCol:=020
   
   @ nLin     ,nCol CHECKBOX lDESTIN Prompt "Destinat�rio ? "  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,3 OF oDlg
   @ nLin+=015,nCol CHECKBOX lPRODUT Prompt "Produto ? " SIZE 60,2 COLOR CLR_HBLUE, CLR_WHITE Of Odlg Pixel
   @ nLin+=015,nCol CHECKBOX lNFENTR Prompt "Nota Fiscal de Entrada  ? "  SIZE 80,2 COLOR CLR_HBLUE, CLR_WHITE Of Odlg Pixel
   //@ nLin+=015,nCol CHECKBOX lLIBQUA Prompt "Libera��o de Quarentena ? "  SIZE 80,2 COLOR CLR_HBLUE, CLR_WHITE Of Odlg Pixel
   @ nLin+=015,nCol CHECKBOX lPEDIDO Prompt "Pedido ? "  SIZE 60,2 COLOR CLR_HBLUE, CLR_WHITE Of Odlg Pixel
   @ nLin+=015,nCol CHECKBOX lNFSAID Prompt "Nota Fiscal de Sa�da ? "  SIZE 80,2 COLOR CLR_HBLUE, CLR_WHITE Of Odlg Pixel

 
   nLin:=029
   nCol:=118

   @ nLin     ,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   //@ nLin+=015,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Data " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
 
   nLin:=027
   nCol:=140

   @ nLin     ,nCol Get dUlDestin PIXEL SIZE 30,6 When .F. OF oDlg  
   @ nLin+=015,nCol Get dUlProdut PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get dUlNfEntr PIXEL SIZE 30,6 When .F. OF oDlg
   //@ nLin+=015,nCol Get dUlLibqua PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get dUlPedido PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get dUlNfSaid PIXEL SIZE 30,6 When .F. OF oDlg 
   
   nLin:=029
   nCol:=185

   @ nLin     ,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   //@ nLin+=015,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Hora " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
 
   nLin:=027
   nCol:=206

   @ nLin     ,nCol Get tUlDestin PIXEL SIZE 30,6 When .F. OF oDlg  
   @ nLin+=015,nCol Get tUlProdut PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get tUlNfEntr PIXEL SIZE 30,6 When .F. OF oDlg
   //@ nLin+=015,nCol Get tUlLibqua PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get tUlPedido PIXEL SIZE 30,6 When .F. OF oDlg
   @ nLin+=015,nCol Get tUlNfSaid PIXEL SIZE 30,6 When .F. OF oDlg  
  
   nLin:=029
   nCol:=270

   @ nLin     ,nCol SAY cIdDestin PIXEL SIZE 45,6  OF oDlg  
   @ nLin+=015,nCol SAY cIdProdut PIXEL SIZE 45,6  OF oDlg
   @ nLin+=015,nCol SAY cIdNfEntr PIXEL SIZE 45,6 OF oDlg
   //@ nLin+=015,nCol SAY cIdLibqua PIXEL SIZE 45,6  OF oDlg
   @ nLin+=015,nCol SAY cIdPedido PIXEL SIZE 45,6 OF oDlg
   @ nLin+=015,nCol SAY cIdNfSaid PIXEL SIZE 45,6  OF oDlg
                                                                  
   //oSBox:= TScrollBox():New( oDlg,000,000,290,508,.T.,.T.,.T. )
   oBmp:= TBitmap():New(  nLin+93,nCol1+002,192,28,,"",.F.,,,,.F.,.T.,,"",.T.,,.T.,,.F. )
   oBmp:cBmpFile     := cImg
   oBmp:lAutoSize     := .T.
   oBmp:lStretch     := .F.     
   
   @ 189,283 BUTTON "CANCELA" size 50,15 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
   @ 189,225 BUTTON "GERAR" size 50,15 ACTION Processa({|| ProcTxtRead()}) of oDlg Pixel

   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  

Else
   ProcTxtRead()
EndIf

Return .T.  

 // Fun��o de processamento para gerar o arquivo.          
*----------------------------------*
  Static Function ProcTxtRead() 
*----------------------------------*
                            
Local oMain1,nLin1,nLin2,nLinha,nCol1,nCol2,nColuna,oDlg1
Private lRetDestin:= lRetProdut:=lRetNfEntr:=lRetPedido:=lRetNfSaid:=lAtu:=.F.
Private cTxtDESTIN := cDirDestin+cIdDestinProx  
Private cTxtPRODUT := cDirProdut+cIdProdutProx
Private cTxtNFENTR := cDirNfEntr+cIdNfEntrProx
//Private cTxtLIBQUA := cDir+cIdLibquaProx
Private cTxtPEDIDO := cDirPedido+cIdPedidoProx
Private cTxtNFSAID := cDirNfSaid+cIdNfSaidProx  
Private cEOL       := "CHR(13)+CHR(10)"
Private aRegLogNfe := aRegLogPed := aRegLogNfs := aRegLogLOTE := {}
Private aRegLogCLIImprime:=aRegLogNfeImprime:=aRegLogPRDImprime:=aRegLogLibImprime:=aRegLogPedImprime:=aRegLogNfsImprime:={}   
Private aDetCLI:=aDetPRD:=aDetPED:=aDetLIB:=aDetNFE:=aDetNFS:=aDetLote:={}
Private cLogManual:= ""
Private nCountCLI:=nCountPRD:=nCountNFE:=nCountLBQ:=nCountPED:=nCountNFS:= nPos:=0
Private nHdlDESTIN,nHdlPRODUT,nHdlNFENTR,nHdlLIBQUA,nHdlPEDIDO,nHdlNFSAID   
Private n:=m:=1

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif
  
Aadd(aRegLogLOTE,"")  // Necessario inicializar o array para que na Odlg seja mostrado o conteudo ap�s atualiza��o.

Ferase(cTxtDESTIN)
Ferase(cTxtPRODUT)
Ferase(cTxtNFENTR)
//Ferase(cTxtLIBQUA)
Ferase(cTxtPEDIDO)
Ferase(cTxtNFSAID)    

If lAut  // Caso for atrav�s de JOB todos os arquivos ser�o gerados. 
   lDESTIN:=lPRODUT:=lNFENTR:=lLIBQUA:=lPEDIDO:=lNFSAID:=.T.
Else     // Sen�o ser� usado de acordo com as op��es marcadas. 
   If lDESTIN==.F. .And. lPRODUT==.F. .And. lNFENTR==.F. .And. lLIBQUA==.F. .And. lPEDIDO==.F.  .And. lNFSAID==.F. 
      MsgStop("Marque um dos arquivos para execu��o da rotina","Aten��o")     
      Return .F.
   EndIf   
EndIf  
          
aRegLogCLIImprime:={}
aDetCLI:={}  
  
If lDESTIN   
   SQLDESTIN()   // Monta Query Arquivo de Destinat�rio  
   If !(lAut)    // Verifica se a rotina � automatica.
      Processa({|| TXTDESTIN() },"Processando dados para o arquivo de destinat�rio ...")
   Else
      TXTDESTIN()        
   EndIf
Else
   Aadd(aRegLogCLIImprime,{"Nao executado","0", "N�o executado"})  
   Aadd(aDetCLI,{"Rotina de gera��o de arquivo de cliente.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado pois a rotina n�o foi marcada.",;
   "Quantidade de clientes : 0.","Usu�rio : "+alltrim(cUserName)+".","Data :"+ DTOC(Date())+"."})
EndIf 

aRegLogPRDImprime:={}
aDetPRD:={}  // Limpa o array 

If lPRODUT
   SQLPRODUT()   // Monta Query Arquivo de Produto     
   If !(lAut)    // Verifica se a rotina � automatica.  
      Processa({|| TXTPRODUT() },"Processando dados para o arquivo de Produto  ...") 
   Else
      TXTPRODUT()      
   EndIf 
Else
   Aadd(aRegLogPRDImprime,{"Nao executado","0","Nao executado"})  
   Aadd(aDetPRD,{"Rotina de gera��o de arquivo de produto.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado pois a rotina n�o foi marcada.",;
   "Quantidade de produtos : 0.","Usu�rio : "+alltrim(cUserName)+".","Data :"+DTOC(Date())+"."})
EndIf    

aRegLogNfeImprime:={}
aDetNFE:={}   

If lNFENTR 
   SQLNFENTR()   // Monta Query Arquivo de Nota Fiscal de Entrada  
   If !(lAut)    // Verifica se a rotina � automatica.  
      Processa({|| TXTNFENTR() },"Processando dados para o arquivo de Nota Fiscal de Entrada ...")
   Else
      TXTNFENTR()
   EndIf     
Else
   Aadd(aRegLogNfeImprime,{"Nao executado","0","Nao executado"}) 
   Aadd(aDetNFE,{"Rotina de gera��o de arquivo de Nota Fiscal de Entrada.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado pois a rotina n�o foi marcada.",;
   "Quantidade de movimentos : 0.","Usu�rio : "+alltrim(cUserName)+".","Data : "+ DTOC(Date())+"."})
EndIf    
  
/*
lLIBQUA:= .F.  // Rotina n�o ser� utilizada, sempre Falso. Libera��o de Quarentena 

If lLIBQUA  
   If select(TRBLIBQUA) > 0
      TRBLIBQUA>(dbCloseArea()) 
   EndIf 
   SQLLIBQUA()   // Monta Query Arquivo de Libera��o de Quarentena   
   nHdlLIBQUA:= fCreate(cTxtLIBQUA) 
   If !(lAut)    // Verifica se a rotina � automatica.  
      If nHdlLIBQUA == -1 // Testa se o arquivo foi gerado 
         MsgAlert("O arquivo "+cTxtLIBQUA+" nao pode ser executado!","Aten��o")
         Aadd(aRegLogLibImprime,{cIdLibQuaProx,"0","Erro na cria��o do arquivo)"})
      Else
         Processa({|| TXTLIBQUA() },"Processando dados para o arquivo de Libera��o de Quarentena ...") 
      EndIf
   Else 
      If !(nHdlLIBQUA == -1)
         TXTLIBQUA()
      EndIf      
   EndIf   
Else
   Aadd(aRegLogLibImprime,{"Nao executado","0","Nao executado"})
EndIf    
*/

aRegLogPedImprime:={}
aDetPED:={}    
If lPEDIDO
   SQLPEDIDO()   // Monta Query Arquivo de Pedido      
   If !(lAut)    // Verifica se a rotina � automatica.  
      Processa({|| TXTPEDIDO() },"Processando dados para o arquivo de Pedido ...")
   Else
      TXTPEDIDO()      
   EndIf      
Else
   Aadd(aRegLogPedImprime,{"Nao executado","0","Nao executado"})   
   Aadd(aDetPED,{"Rotina de gera��o de arquivo de Pedido.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado pois a rotina n�o foi marcada.",;
   "Quantidade de pedidos : 0.","Usu�rio : "+alltrim(cUserName)+".","Data : "+ DTOC(Date())+"."})
EndIf
                                                                  
aRegLogNfsImprime:={}
aDetNFS:= {} 
lNFSAID:=.F.    // ser� utilizado o DANFE para integra��o

If lNFSAID
   SQLNFSAID()   // Monta Query Arquivo de Nota Fiscal de Sa�da
   nHdlNFSAID:= fCreate(cTxtNFSAID)
   If !(lAut)    // Verifica se a rotina � automatica.  
      If nHdlNFSAID == -1  // Testa se o arquivo foi gerado
         MsgA`lert("O arquivo "+cTxtNFSAID+" nao pode ser executado!","Aten��o")  
         Aadd(aRegLogNfsImprime,{cIdNfSaidProx,"0","Erro na cria��o do arquivo)"})
      Else
         Processa({|| TXTNFSAID() },"Processando dados para o arquivo de Nota Fiscal de Sa�da ...")     
      EndIf
   Else
      If !(nHdlNFSaid == -1) 
         TXTNFSAID()
      EndIf   
   EndIf   
Else
   Aadd(aRegLogNfsImprime,{"Rotina n�o disponivel","0","Rotina n�o disponivel"})  
   Aadd(aDetNFS,{"Rotina de gera��o de arquivo de Nota fiscal de Sa�da.","Filial : "+Alltrim(SM0->M0_NOME)+".",;
   "Para integra��o de nota fiscal de sa�da ser� utilizado o DANFE.",;
   "Usu�rio : "+alltrim(cUserName)+".","Data : "+ DTOC(Date())+"."})
EndIf

 
If !(lAut)            
                 
   DEFINE MSDIALOG oDlg1 TITLE  "Resultado do processamento "  From 1,10 To 40,107 OF oMain1  
  
   nLin1:=010 
   nLin2:=045
   nCol1:=010
   nCol2:=375
         
   nLinha:=020 
   nColuna:=020        

   @ nLin1    ,nCol1     TO nLin2   ,   nCol2   LABEL " Arquivo de Destin�tario " OF oDlg1 PIXEL
   @ nLinha ,nColuna     Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha ,nColuna+120 Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha ,nColuna+180 Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1  
   @ nLinha ,nColuna+300 TO nLinha+20,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+05 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTDESTIN")}) of oDlg1 Pixel

   
   
   //If lDESTIN 
        
      @ nLinha+010 ,nColuna     Say aRegLogCLIImprime[1][1]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+010 ,nColuna+130 Say aRegLogCLIImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+010 ,nColuna+180 Say aRegLogCLIImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
         
   //EndIf
   
   @ nLin1+=40 ,nCol1          TO nLin2+=40,   nCol2  LABEL " Arquivo de Produto " OF oDlg1 PIXEL   
   @ nLinha+040  ,nColuna      Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+040  ,nColuna+120  Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+040   ,nColuna+180 Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+040 ,nColuna+300 TO nLinha+60,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+45 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTPRODUT")}) of oDlg1 Pixel
    
   //If  lPRODUT
       
      @ nLinha+050  ,nColuna     Say aRegLogPRDImprime[1][1]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+050  ,nColuna+130 Say aRegLogPRDImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+050  ,nColuna+180 Say aRegLogPRDImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
      
   //EndIf
   
   @ nLin1+=40 ,nCol1         TO nLin2+=40,   nCol2  LABEL " Arquivo de Nota Fiscal de Entrada " OF oDlg1 PIXEL  
   @ nLinha+080  ,nColuna     Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+080  ,nColuna+120 Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+080  ,nColuna+180 Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1 
   @ nLinha+080 ,nColuna+300 TO nLinha+100,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+085 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTNFENTR")}) of oDlg1 Pixel
    
   //If lNFENTR
   
      @ nLinha+090  ,nColuna     Say aRegLogNfeImprime[1][1]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+090  ,nColuna+130 Say aRegLogNfeImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+090  ,nColuna+180 Say aRegLogNfeImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
  
   //EndIf
          
   /* Tratamento n�o disponivel.       
                                     
   @ nLin1+=40 ,nCol1          TO nLin2+=40,   nCol2  LABEL " Arquivo de Libera��o de Quarentena " OF oDlg1 PIXEL 
   @ nLinha+120   ,nColuna     Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+120   ,nColuna+110 Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+120   ,nColuna+180 Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+120 ,nColuna+300 TO nLinha+140,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+125 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTLIBQUA")}) of oDlg1 Pixel
   
   If lLIBQUA 
   
      @ nLinha+130  ,nColuna     Say aRegLogLibImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+130  ,nColuna+120 Say aRegLogLibImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+130  ,nColuna+180 Say aRegLogLibImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
      
   EndIf */   
   
   @ nLin1+=40 ,nCol1             TO nLin2+=40,   nCol2  LABEL " Arquivo de Pedido " OF oDlg1 PIXEL      
   @ nLinha+120  ,nColuna         Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+120  ,nColuna+120     Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+120  ,nColuna+180     Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1    
   @ nLinha+120 ,nColuna+300 TO nLinha+140,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+125 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTPEDIDO")}) of oDlg1 Pixel
     
   //If lPEDIDO
   
      @ nLinha+130 ,nColuna      Say aRegLogPedImprime[1][1]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+130 ,nColuna+130  Say aRegLogPedImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+130 ,nColuna+180  Say aRegLogPedImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
      
   //EndIf
   
   @ nLin1+=40  ,nCol1       TO nLin2+=40,   nCol2  LABEL " Arquivo de Nota Fiscal de Sa�da" OF oDlg1 PIXEL           
   @ nLinha+160 ,nColuna     Say  "ARQUIVO "        PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+160 ,nColuna+120 Say  "Nr REGISTROS "   PIXEL SIZE 60,6 OF oDlg1
   @ nLinha+160 ,nColuna+180 Say  "MENSAGEM  "      PIXEL SIZE 60,6 OF oDlg1 
   @ nLinha+160 ,nColuna+300 TO nLinha+180,nColuna+350   LABEL ""  OF oDlg1 PIXEL
   @ nLinha+165 ,nColuna+308 BUTTON "Detalhes" size 35,10 ACTION Processa({|| DETALHES("TXTNFSAID")}) of oDlg1 Pixel          
   
   //If lNFSAID
   
      @ nLinha+170 ,nColuna      Say aRegLogNfsImprime[1][1]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 200,8 OF oDlg1
      @ nLinha+170 ,nColuna+130  Say aRegLogNfsImprime[1][2]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 100,8 OF oDlg1
      @ nLinha+170 ,nColuna+180  Say aRegLogNfsImprime[1][3]  COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 160,8 OF oDlg1
  
   //EndIF   
   
   @ nLinha+198 ,nColuna-3 Say SubStr(aRegLogLOTE[1],1,152) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 500,8 OF oDlg1   
   @ nLinha+208 ,nColuna-3 Say SubStr(aRegLogLOTE[1],153,152) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 500,8 OF oDlg1  
   @ nLinha+218 ,nColuna-3 Say SubStr(aRegLogLOTE[1],306,152) COLOR CLR_HRED, CLR_WHITE PIXEL SIZE 500,8 OF oDlg1
   
   oBmp:= TBitmap():New(  nLinha+236,nCol1+1,83,23,,"",.F.,,,,.F.,.T.,,"",.T.,,.T.,,.F. )  //Painel meio
   oBmp:cBmpFile     := cImg1
   oBmp1:= TBitmap():New(  nLinha+192,nCol1+1,363,38,,"",.F.,,,,.F.,.T.,,"",.T.,,.T.,,.F. )  //Painel Superior.
   oBmp1:cBmpFile     := cImg2
   oBmp2:= TBitmap():New(  284,nCol1+1,363,10,,"",.F.,,,,.F.,.T.,,"",.T.,,.T.,,.F. ) // Painel inferior
   oBmp2:cBmpFile     := cImg3

   @ nLinha+190,nCol1 TO 252,nCol2   LABEL ""  OF oDlg1 PIXEL    // caixa superior
   @ nLinha+235,nCol1 TO 280,95   LABEL ""  OF oDlg1 PIXEL // caixa meio esquerda 
   @ nLinha+235,100 TO 280,230   LABEL ""  OF oDlg1 PIXEL // caixa meio meio
   @ 282,nCol1 TO 295,nCol2   LABEL ""  OF oDlg1 PIXEL // caixa inferior
   @ 255,235 TO 280,nCol2   LABEL ""  OF oDlg1 PIXEL  // caixa do botao direita    
   
   /*
   @ nLinha+190,235 TO 252,nCol2   LABEL ""  OF oDlg1 PIXEL    // caixa superior
   @ nLinha+190,nCol1 TO 280,230   LABEL ""  OF oDlg1 PIXEL // caixa lateral 
   @ 282,nCol1 TO 295,nCol2   LABEL ""  OF oDlg1 PIXEL // caixa inferior
   @ 255,235 TO 280,nCol2   LABEL ""  OF oDlg1 PIXEL  // caixa do botao
   */                                                                                              
   @ 260,110 BUTTON "BUSCA LOTE" size 50,15 ACTION Processa({|| BUSCAFTP()}) of oDlg1 Pixel   
   @ 260,170 BUTTON "DETALHES "  size 50,15 ACTION Processa({|| DETALHES("LOTES")}) of oDlg1 Pixel
   @ 260,250 BUTTON "GRAVAR FTP" size 50,15 ACTION Processa({|| GERAFTP()}) of oDlg1 Pixel
   @ 260,310 BUTTON "SAIR"       size 50,15 ACTION Processa({|| oDlg1:End(),oDlg:End()}) of oDlg1 Pixel  
   

   
   ACTIVATE DIALOG oDlg1 CENTERED ON INIT(oDlg1:Refresh()) 
    
EndIf 
  

If lAut 
   GERAFTP()
EndIf


Return .T.          

*----------------------------*                                           
Static Function TXTDESTIN() 
*----------------------------*             

Begin Sequence  

If TRBDESTIN->(!EOF())     

   ProcRegua(RecCount()) // Numero de registros a processar     
   
   nHdlDESTIN:= fCreate(cTxtDESTIN)
   If !(lAut)    // Verifica se a rotina � automatica.
      If nHdlDESTIN == -1 // Testa se o arquivo foi gerado
         MsgAlert("O arquivo "+cTxtDESTIN+" nao pode ser executado!","Aten��o") 
         Aadd(aRegLogCLIImprime,{cIdDestinProx,"0","Erro na cria��o do arquivo"})  
         Aadd(aDetCLI,{cIdDestinProx,"0","Erro na cria��o do arquivo entre em contato com suporte."}) 
         TRBDESTIN->(dbCloseArea())
         Return .F.
      EndIf    
   EndIf

   nTamLin   := 220
   cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
    //        Cabe�alho         -----------       Coment�rios

   cCab  := Stuff(cCab,0,03,"HDR")            // Fixo com "HDR"

   cCab  := Stuff(cCab,04,03,"018")           // Informa��o passa pela ATIVA

   cCpo  := PADR(SPACE(208),208)  
   cCab  := Stuff(cCab,07,208,cCpo)           // Fixo em branco


   cCab := Stuff(cCab,215,6,"000001")        //  Fixo 000001
    
   nCountCLI:=0 // Quantidade de registros CLI

   If fWrite(nHdlDESTIN,cCab,Len(cCab)) != (Len(cCab))
      If !(lAut)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab). ","Atencao!")
            Aadd(aRegLogCLIImprime,{cIdDestinProx,nCountCLI,"Erro no cabe�alho HDR - CLI (cCab)"}) 
            Aadd(aDetCLI,{cIdDestinProx,nCountCLI,"Erro no cabe�alho HDR - CLI (cCab) - Entre em contato com suporte"})  
            TRBDESTIN->(dbCloseArea())     
            Return .F. 
         EndIf
      Else      
         Aadd(aRegLogCLIImprime,{cIdDestinProx,nCountCLI,"Erro no cabe�alho HDR - CLI (cCab)"})
         Return .F.
      Endif
   Endif 
    
   nSeq:=000002          // VERIFICAR
   
   Do While TRBDESTIN->(!EOF())	
	
      IncProc()
			 
	   cLin := Space(nTamLin)+cEOL                       // Variavel para criacao da linha do registros para gravacao 
	 
	   cLin := Stuff(cLin,0,03,"CLI")                    // Valor Fixo "CLI" 
		 		
	   cLin := Stuff(cLin,04,20,TRBDESTIN->A1_COD)       // C�digo do destinat�rio
	
	   cLin := Stuff(cLin,24,40,TRBDESTIN->A1_NOME)      // Raz�o Social
		
 	   cLin := Stuff(cLin,64,40,TRBDESTIN->A1_END)       // Endere�o      VERIFICAR   sistema tamanho 60
	   
	   cLin := Stuff(cLin,104,25,TRBDESTIN->A1_BAIRRO)   // Bairro        VERIFICAR   sistema tamanho 30
	                                                                                                 
	   cLin := Stuff(cLin,129,08,TRBDESTIN->A1_CEP)      // CEP     
   
   	   cLin := Stuff(cLin,137,25,TRBDESTIN->A1_MUN)      // Municipio       
	
	   cLin := Stuff(cLin,162,02,TRBDESTIN->A1_EST)      // Estado       
 	   
 	   cCpo:=Alltrim(TRBDESTIN->A1_TEL)
 	   
 	   cCpo := ClearVal(cCpo)
 	                                                 	   
	   cLin := Stuff(cLin,164,08,cCpo)                   // Telefone   
	  
	   cLin := Stuff(cLin,172,14,TRBDESTIN->A1_CGC)      // CNPJ  / CPF       
	
	   cLin := Stuff(cLin,186,18,TRBDESTIN->A1_INSCR)    // Inscri��o estadual / RG      
	
	   cCpo := If (TRBDESTIN->A1_PESSOA=="J","1","2")
	   cLin := Stuff(cLin,204,01,cCpo)   // Tipo de Pessoa       
	   
       cCpo := DTOS(Date())                             
                                               
 	   cCpo := Stuff(cCpo,5,0,"-")                       
       
       cCpo := Stuff(cCpo,8,0,"-")
	                                  
	   cLin := Stuff(cLin,205,10,cCpo)                   // Data da �ltima Altera��o   AAAA-MM-DD 
	    
	   cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq))))
	   cCpo := cCpo+Alltrim(STR(nSeq))
	   cLin := Stuff(cLin,215,06, cCpo)+cEOL     // Sequencia

	   // Gravacao no arquivo texto. Testa por erros durante a gravacao da linha montada.                                                      	
	   If fWrite(nHdlDESTIN,cLin,Len(cLin)) != (Len(cLin))
	      If !(lAut)
	         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Detalhe CLI (cLin). ","Atencao!")
                Aadd(aRegLogCLIImprime,{nCountCLI,"Erro no Detalhe CLI (cLin)"}) 
                Aadd(aDetCLI,{cIdDestinProx,nCountCLI,"Erro no Detalhe CLI (cLin) - Entre em contato com suporte."}) 
                TRBDESTIN->(dbCloseArea()) 
                Return .F.
             EndIf
          Else
             Aadd(aRegLogCLIImprime,{cIdDestinProx,nCountCLI ,"Erro no Detalhe CLI (cLin)"})
             Return .F.
		  Endif
   	   Endif  
    
       nSeq++	       
	   nCountCLI++
	   TRBDESTIN->(DbSkip())  
	
   EndDo

   // Finaliza��o do arquivo TXT         
   cFin := Space(nTamLin)+cEOL             // Variavel para criacao da linha do registros para gravacao 

   cFin := Stuff(cFin,00,3,"FTR")          // Fixo 'FTR'
   
   cCpo := Replicate("0",9-Len(Alltrim(STR(nCountCLI))))
   cCpo := cCpo+Alltrim(STR(nCountCLI))
   cFin := Stuff(cFin,04,09,cCpo)         // Quantidade de registros do tipo CLI

   cCpo := PAD(Space(202),202)             // Fixo em branco.
   cFin := Stuff(cFin,13,202,cCpo)
  
   cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
   cCpo := cCpo+Alltrim(STR(nSeq))
   cFin := Stuff(cFin,215,1,cCpo)          // Sequencia crescente do registro
   
     
   If fWrite(nHdlDESTIN,cFin,Len(cFin)) != (Len(cFin))
      If !(lAut)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, registro de finaliza��o FTR (cFin). ","Atencao!")
            Aadd(aRegLogCLIImprime,{cIdDestinProx, nCountCLI , "Erro na Finaliza��o FTR - CLI (cFin)"})   
            Aadd(aDetCLI,{cIdDestinProx, nCountCLI , "Erro na Finaliza��o FTR - CLI (cFin) - Entre em contato com suporte."}) 
            TRBDESTIN->(dbCloseArea())      
            Return .F.
         EndIf
      Else
         Aadd(aRegLogCLIImprime,{ cIdDestinProx, nCountCLI , "Erro na Finaliza��o FTR - CLI (cFin)"})
         Return .F.
      Endif
   Endif

   fClose(nHdlDESTIN)   
    
   TRBDESTIN->(DbGoTop())
   If !(TRBDESTIN->(EOF()))
      If SA1->(FieldPos("A1_P_STATS")) > 0
         // Atualiza a Base (A1_P_STATS) com os arquivos que foram enviados.
         SA1->(DbSetOrder(1))   
         While TRBDESTIN->(!EOF())
            SA1->(DbSeek(TRBDESTIN->A1_FILIAL+TRBDESTIN->A1_COD+TRBDESTIN->A1_LOJA))                    
            If SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA == TRBDESTIN->A1_FILIAL+TRBDESTIN->A1_COD+TRBDESTIN->A1_LOJA
               SA1->(RecLock("SA1",.F.))
               SA1->A1_P_STATS:="E"
               SA1->(MsUnlock())   
            EndIf
            TRBDESTIN->(DbSkip())
         EndDo           
         SX6->(DbSetOrder(1))                 
         // Atualiza o SX6 �ltima numera��o.
         If (SX6->(DbSeek(XFilial()+"MV_RED_DES")))  
            RecLock("SX6",.F.)
	        SX6->X6_CONTEUD := cIdDestinProx 	   
	        SX6->( MsUnlock())              
         EndIf
          
         // Grava LOG do Destinatario caso tenha sido gerado.  
         ZRD->(DbSetOrder(1))
         RecLock("ZRD",.T.)
         ZRD->ZRD_FILIAL := xFilial()
         ZRD->ZRD_COD    := Substr(cIdDestinProx,1,8)
         ZRD->ZRD_DATA   := Date()
         ZRD->ZRD_HORA   := Time()
         ZRD->ZRD_USER   := cUserName                     
         ZRD->ZRD_ROTINA := "TXTDESTIN"
         ZRD->ZRD_ARQUIV := Alltrim(cIdDestinProx)
         ZRD->ZRD_GERLOC := "Gerado Local"
         ZRD->ZRD_GERFTP := "Nao gerado FTP"
         ZRD->ZRD_QTDREG := nCountCLI
         ZRD->( MsUnlock()) 
                            
         Aadd(aRegLogCLIImprime,{" Arquivo gerado: "+cIdDestinProx, nCountCLI , "Gerado local"})
         Aadd(aDetCLI,{"Rotina de gera��o de arquivo de cliente","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo gerado: "+cIdDestinProx,;
         "Quantidade de clientes : "+Alltrim(Str(nCountCLI)),"Usu�rio : "+alltrim(cUserName),"Data : "+ DTOC(Date())})                     
        
         lRetDestin:=.T.         
     
      EndIf       

   EndIf  
               
Else    
   Aadd(aRegLogCLIImprime,{ " Arquivo n�o gerado: "+cIdDestinProx, nCountCLI , "Sem dados para gera��o"}) 
   Aadd(aDetCLI,{"Rotina de gera��o de arquivo de cliente","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo n�o foi gerado",;
   "Quantidade de clientes : 0","Usu�rio : "+alltrim(cUserName),"Data :"+ DTOC(Date())},"Verifique se houve altera��es ou inclus�o de clientes")
   Ferase(cTxtDESTIN)
EndIf    
       
TRBDESTIN->(dbCloseArea()) 

End Sequence
 
Return (lRetDestin)
                               
*----------------------------*                                          
Static Function TXTPRODUT() 
*----------------------------*             

Begin Sequence

IF TRBPRODUT->(!EOF())  

   SB5->(DbSetOrder(1))

   ProcRegua(RecCount()) // Numero de registros a processar   
   
   nHdlPRODUT:= fCreate(cTxtPRODUT)
   If !(lAut)    // Verifica se a rotina � automatica.  
      If nHdlPRODUT == -1 // Testa se o arquivo foi gerado 
         MsgAlert("O arquivo "+cTxtPRODUT+" nao pode ser executado!","Aten��o")
         Aadd(aRegLogPRDImprime,{cIdProdutProx,"0","Erro na cria��o do arquivo"})
         Aadd(aDetPRD,{cIdProdutProx,"0","Erro na cria��o do arquivo entre em contato com suporte."})  
         TRBPRODUT->(dbCloseArea()) 
         Return .F.   
      EndIf
   EndIf      

   nTamLin   := 200
   cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
    //        Cabe�alho         -----------       Coment�rios

   cCab  := Stuff(cCab,0,03,"HDR")            // Fixo com "HDR"

   cCab  := Stuff(cCab,04,03,"018")        // Informa��o passa pela ATIVA

   cCpo  := PADR(SPACE(188),188)  
   cCab  := Stuff(cCab,07,188,cCpo)           // Fixo em branco

   cCab := Stuff(cCab,195,6,"000001")          //  Fixo 000001
    
   nCountPRD:=0 // Quantidade de registros PRD

   If fWrite(nHdlPRODUT,cCab,Len(cCab)) != (Len(cCab))
      If !(lAut)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab). ","Atencao!")
            Aadd(aRegLogPRDImprime,{ cIdProdutProx, nCountPRD ,"Erro no cabe�alho HDR - PRD (cCab)"}) 
            Aadd(aDetPRD,{ cIdProdutProx, nCountPRD ,"Erro no cabe�alho HDR - PRD (cCab)- Entre em contato com suporte."}) 
            TRBPRODUT->(dbCloseArea())
            Return .F. 
         EndIf
      Else      
         Aadd(aRegLogPRDImprime,{cIdProdutProx, nCountPRD ,"Erro no cabe�alho HDR - PRD (cCab)"})
         Return .F.
      Endif
   Endif 
    
   nSeq:=000002          // VERIFICAR
   
   Do While TRBPRODUT->(!EOF())	
	
      IncProc()
			 
	   cLin := Space(nTamLin)+cEOL                       // Variavel para criacao da linha do registros para gravacao 
	 
	   cLin := Stuff(cLin,0,03,"PRD")                    // Valor Fixo "PRD" 
		 		
	   cLin := Stuff(cLin,04,20,TRBPRODUT->B1_COD)       // C�digo do produto
	
	   cLin := Stuff(cLin,24,35,Substr(TRBPRODUT->B1_DESC,1,35))      // Descri��o
		
       cCpo :=Substr(TRBPRODUT->B1_DESC,1,20) 
  	   cLin := Stuff(cLin,59,20,cCpo)                    // Descri�ao resumida
	   
	   cCpo := TRBPRODUT->B1_CODBAR
	   
	   cCpo := ClearVal(cCpo)	   	   
	   cLin := Stuff(cLin,79,14,cCpo)                    // C�digo de Barras
	   
	   If TRBPRODUT->B1_MSBLQL=='1'                        // Bloqueado 1- SIM / 2 - NAO
	      cCpo:="2"   // Liberado para venda
	   Else
	      cCpo:="1"  // Venda suspensa	   
	   EndIf 
	   
	   cLin := Stuff(cLin,93,01,cCpo)    
	                                                                                                 
	   cLin := Stuff(cLin,94,03,TRBPRODUT->B1_UM)        // Unidade     
                               
       If !Empty(TRBPRODUT->B1_SEGUM) 
          cLin := Stuff(cLin,97,03,TRBPRODUT->B1_SEGUM)  // Unidade de venda  
	   Else
	      cLin := Stuff(cLin,97,03,TRBPRODUT->B1_UM)
	   EndIf 
        
       If !Empty(TRBPRODUT->B1_POSIPI)  
          cCpo := ClearVal(TRBPRODUT->B1_POSIPI)
          cCpo := Substr(cCpo,1,4)+"."+Substr(cCpo,5,2)+"."+Substr(cCpo,7,2)
       Else
          cCpo := cCpo  := PADR(SPACE(10),10) 
       EndIf
       
       
   	   cLin := Stuff(cLin,100,10,cCpo )                  // Classifica��o Fiscal       
	
	   cCpo  := PADR(SPACE(01),01)  
  	   cLin := Stuff(cLin,110,01,cCpo)                   // Produto controlado       
 	
	   cLin := Stuff(cLin,111,02,TRBPRODUT->B1_TIPO)     // Classe de produto  
	  
	   cCpo := strzero(TRBPRODUT->B1_PESO,5,3)
	   cCpo := ClearVal(cCpo)   
	   cCpo := "0"+cCpo
	   cLin := Stuff(cLin,113,5,cCpo)                    // Peso do Item       
	
	   If SB5->(DbSeek(xFilial()+TRBPRODUT->B1_COD))
	      
	      //cCpo := Alltrim(Str(INT(SB5->B5_COMPR)))    
	      cCpo := strzero(SB5->B5_COMPR,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,118,03,cCpo)                 // Comprimento do item  
	
	      //cCpo := Alltrim(Str(INT(SB5->B5_ESPESS)))  
	      cCpo := strzero(SB5->B5_ESPESS,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,121,03,cCpo)                 // Altura do Item
	      
	      //cCpo := Alltrim(Str(INT(SB5->B5_LARG)))
	      cCpo := strzero(SB5->B5_LARG,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,124,03,cCpo)                   // larguta do item
	      
	      //cCpo := Alltrim(Str(SB5->B5_QE1))
	      cCpo := strzero(SB5->B5_P_QTDC ,4,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,127,04,cCpo)                 // Qtde unidadede por caixa fechada
	      
	      cCpo := strzero(SB5->B5_P_PESC,6,3)
	      cCpo := ClearVal(cCpo)    
	      cCpo := "0"+(cCpo)
	      cLin := Stuff(cLin,131,06,cCpo)                 // Peso por caixa fechada
	       
	      //cCpo := Alltrim(Str(INT(SB5->B5_COMPRLC)))
	      cCpo := strzero(SB5->B5_P_COMC,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,137,03,cCpo)                 // Comprimento da caixa fechada
	      
	      //cCpo := Alltrim(Str(INT(SB5->B5_ALTURLC)))
	      cCpo :=  strzero(SB5->B5_P_ALTC,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,140,03,cCpo)                 // Altura da caixa fechada
	       
	      //cCpo := Alltrim(Str(INT(SB5->B5_LARGLC)))
	      cCpo :=  strzero(SB5->B5_P_LARGC,3,0)
	      cCpo := ClearVal(cCpo)
	      cLin := Stuff(cLin,143,03,cCpo)                 // Largura da caixa fechada
	                                          
	   Else
	      
	      cLin := Stuff(cLin,118,03,"000")      // Comprimento do item  
	
	      cLin := Stuff(cLin,121,03,"000")      // Altura do Item
	   
	      cLin := Stuff(cLin,124,03,"000")      // larguta do item
	   
	      cLin := Stuff(cLin,127,04,"0000")      // Qtde unidadede por caixa fechada
	   
	      cLin := Stuff(cLin,131,06,"000000")      // Peso por caixa fechada
	   
	      cLin := Stuff(cLin,137,03,"000")      // Comprimento da caixa fechada
	   
	      cLin := Stuff(cLin,140,03,"000")      // Altura da caixa fechada
	   
	      cLin := Stuff(cLin,143,03,"000")      // Largura da caixa fechada
	   
	   EndIf
	   
	   
	   cLin := Stuff(cLin,146,03,"000")      // Qtde caixas por pallete      
	   
	   cLin := Stuff(cLin,149,07,"0000000")      // Peso do pallete
	   
	   cLin := Stuff(cLin,156,03,"000")      // Comprimento do pallete
	   
	   cLin := Stuff(cLin,159,03,"000")      // Altura do pallete 
	   
	   cLin := Stuff(cLin,162,03,"000")      // Largura do pallete
	   	                        	          
	   cCpo := DTOS(Date())                             
                                               
 	   cCpo := Stuff(cCpo,5,0,"-")                       
       
       cCpo := Stuff(cCpo,8,0,"-")
	                                  
	   cLin := Stuff(cLin,165,10,cCpo)        // Data da �ltima Altera��o   AAAA-MM-DD    	   
	   
	   cLin := Stuff(cLin,175,03,"000")       // Validade Minima em dias 
	  
	   cCpo := PAD(Space(17),17)             // Fixo em branco.
       cLin := Stuff(cLin,178,17,cCpo) 
	    	  	   	  
	   cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq))))
	   cCpo := cCpo+Alltrim(STR(nSeq))
	   cLin := Stuff(cLin,195,06,cCpo)+cEOL         // Sequencia

	   // Gravacao no arquivo texto. Testa por erros durante a gravacao da linha montada.                                                      	
	   If fWrite(nHdlPRODUT,cLin,Len(cLin)) != (Len(cLin))
	      If !(lAut)
	         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, Detalhe PRD (cLin). ","Atencao!")
                 Aadd(aRegLogPRDImprime,{cIdProdutProx, nCountPRD ,"Erro no Detalhe - PRD (cLin)"})
                 Aadd(aDetPRD,{cIdProdutProx, nCountPRD ,"Erro no Detalhe - PRD (cLin) - Entre em contato com suporte."})  
                 TRBPRODUT->(dbCloseArea())
                 Return .F.
             EndIf
          Else
             Aadd(aRegLogPRDImprime,{cIdProdutProx, nCountPRD ,"Erro no Detalhe - PRD (cLin)"})
             Return .F.
		  Endif
   	   Endif  
    
       nSeq++	       
	   nCountPRD++
	   TRBPRODUT->(DbSkip())  
	
   EndDo

   // Finaliza��o do arquivo TXT         
   cFin := Space(nTamLin)+cEOL             // Variavel para criacao da linha do registros para gravacao 

   cFin := Stuff(cFin,00,3,"FTR")          // Fixo 'FTR'
   
   cCpo := Replicate("0",6-Len(Alltrim(STR(nCountPRD))))
   cCpo := cCpo+Alltrim(STR(nCountPRD))
   cFin := Stuff(cFin,04,06,cCpo)          // Quantidade de registros do tipo CLI

   cCpo := PAD(Space(202),202)             // Fixo em branco.
   cFin := Stuff(cFin,13,202,cCpo)

   cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
   cCpo := cCpo+Alltrim(STR(nSeq))
   cFin := Stuff(cFin,195,1,cCpo)+cEOL    // Sequencia crescente do registro
     
   If fWrite(nHdlPRODUT,cFin,Len(cFin)) != (Len(cFin))
      If !(lAut)
         If !MsgAlert("Ocorreu um erro na gravacao do arquivo, registro de finaliza��o FTR (cFin). ","Atencao!")
            Aadd(aRegLogPRDImprime,{cIdProdutProx, nCountPRD , "Erro na Finaliza��o FTR - PRD(cFin)"}) 
            Aadd(aDetPRD,{cIdProdutProx, nCountPRD , "Erro na Finaliza��o FTR - PRD(cFin) - Entre em contato com suporte."}) 
            Return .F.
         EndIf
      Else
         Aadd(aRegLogPRDImprime,{cIdProdutProx, nCountPRD , "Erro na Finaliza��o FTR - PRD(cFin)"})
         Return .F.
      Endif
   Endif

   fClose(nHdlPRODUT)   
    
   TRBPRODUT->(DbGoTop())
   If !(TRBPRODUT->(EOF()))
      If SB1->(FieldPos("B1_P_STATS")) > 0
         // Atualiza a Base (B1_P_STATS) com os arquivos que foram enviados.
         SB1->(DbSetOrder(1))   
         While TRBPRODUT->(!EOF())
            SB1->(DbSeek(TRBPRODUT->B1_FILIAL+TRBPRODUT->B1_COD))                    
            If SB1->B1_FILIAL+SB1->B1_COD == TRBPRODUT->B1_FILIAL+TRBPRODUT->B1_COD
               SB1->(RecLock("SB1",.F.))
               SB1->B1_P_STATS:="E"
               SB1->(MsUnlock())   
            EndIf
            TRBPRODUT->(DbSkip())
         EndDo           
         SX6->(DbSetOrder(1))                 
         // Atualiza o SX6 �ltima numera��o.
         If (SX6->(DbSeek(XFilial()+"MV_RED_PRO")))  
            RecLock("SX6",.F.)
	        SX6->X6_CONTEUD := cIdProdutProx 	   
	        SX6->( MsUnlock())              
         EndIf
         
         // Grava LOG do Produto caso tenha sido gerado.  
         ZRD->(DbSetOrder(1))
         RecLock("ZRD",.T.)
         ZRD->ZRD_FILIAL := xFilial()
         ZRD->ZRD_COD    := Substr(cIdProdutProx,1,8)
         ZRD->ZRD_DATA   := Date()
         ZRD->ZRD_HORA   := Time()
         ZRD->ZRD_USER   := cUserName
         ZRD->ZRD_ROTINA := "TXTPRODUT"
         ZRD->ZRD_ARQUIVO:= Alltrim(cIdProdutProx)
         ZRD->ZRD_GERLOC := "Gerado Local"
         ZRD->ZRD_GERFTP := "Nao gerado FTP"
         ZRD->ZRD_QTDREG := nCountPRD 
         ZRD->( MsUnlock()) 
                      
         lRetProdut:=.T.   
         
         Aadd(aRegLogPRDImprime,{" Arquivo gerado: "+cIdProdutProx, nCountPRD , "Gerado local"})  
         Aadd(aDetPRD,{"Rotina de gera��o de arquivo de produto","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo gerado: "+cIdProdutProx,;
         "Quantidade de clientes : "+Alltrim(Str(nCountPRD)),"Usu�rio : "+alltrim(cUserName),"Data : "+ DTOC(Date())})      
                  
      EndIf       
    
   EndIf  
      
Else    
   Aadd(aRegLogPRDImprime,{" Arquivo n�o gerado: "+cIdProdutProx, nCountPRD , "Sem dados para gera��o"}) 
   Ferase(cTxtPRODUT) // Caso n�o tenha dados o arquivo ser� apagado.             
      
   Aadd(aDetPRD,{"Rotina de gera��o de arquivo de produto","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo n�o foi gerado",;
   "Quantidade de produtos : 0","Usu�rio : "+alltrim(cUserName),"Data :"+DTOC(Date())},"Verifique se houve altera��es ou inclus�o de produto.")
   Ferase(cTxtProdut)
EndIf   
 
End Sequence 

TRBPRODUT->(dbCloseArea())
 
Return (lRetProdut)  

// Monta arquivo de nota fiscal de entrada.
*----------------------------*                                          
Static Function TXTNFENTR() 
*----------------------------*             

Local cComparaNFE:=""
Local nCountItem:=nCountNota:=nValUnit:=nValTot:=nValTotNF:=0 
Local lNfe1:=.F.
Local nSeq,n,nAux 

Begin Sequence 

   If TRBNFENTR->(EOF())
      Aadd(aRegLogNfeImprime,{" Arquivo n�o gerado: "+cIdNfEntrProx,nCountNota,"Sem dados para gera��o"}) 
      Aadd(aDetNFE,{"Rotina de gera��o de arquivo de Nota Fiscal de Entrada.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado.",;
      "Quantidade de movimentos : 0 .","Usu�rio : "+alltrim(cUserName)+".","Data : "+ DTOC(Date())+".","Verifique se houve movimenta��o no sistema."}) 
      fClose(nHdlNFENTR)       
      TRBNFENTR->(dbCloseArea()) 
      Ferase(cTemp) 
      Ferase(cIndex+OrdBagExt())                                              
      Return .F.
   EndIf
                    
   Do While TRBNFENTR->(!EOF())
     
      ProcRegua(RecCount()) // Numero de registros a processar     
      
      nSeq:=1 
      
      If lNfe1   // Sera gerado um arquivo para cada nota, ap�s gerar a primeira ser� necess�rio criar outro TXT
         
         If SX6->(DbSeek(XFilial()+"MV_RED_NFE"))
            // Pega a proxima numera��o para nota
            cIdNFEntr := Alltrim(SX6->X6_CONTEUD) 
            cIdAux := Val(Substr(cIdNFEntr,2,08))
            cIdAux := cIdAux+1
            cIdNfEntrProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".NFE" 
            // Gera um novo TXT para a pr�xima nota
            cTxtNFENTR:=cDirNfEntr+cIdNfEntrProx
            nHdlNFENTR:=fCreate(cTxtNFENTR)         
         EndIf
      
      Else
            
         nHdlNFENTR:= fCreate(cTxtNFENTR)
         If !(lAut)    // Verifica se a rotina � automatica.  
            If nHdlNFENTR == -1 // Testa se o arquivo foi gerado
               MsgAlert("O arquivo "+cTxtNFENTR+" nao pode ser executado!","Aten��o")
               Aadd(aRegLogNfeImprime,{cIdNfEntrProx,"0","Erro na cria��o do arquivo"}) 
               Aadd(aDetNFE,{cIdNfEntrProx,"0","Erro na cria��o do arquivo do arquivo entre em contato com suporte"})
               Ferase(cTemp) 
               Ferase(cIndex+OrdBagExt()) 
            EndIf
         EndIf
 
      EndIf
      
      nTamLin   := 126
      cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
      //        Cabe�alho         -----------       Coment�rios

      cCab  := Stuff(cCab,0,03,"HDR")            // Fixo com "HDR"

      cCab  := Stuff(cCab,04,03,"018")        // Informa��o passa pela ATIVA

      cCpo  := PADR(SPACE(111),111)  
      cCab  := Stuff(cCab,07,111,cCpo)           // Fixo em branco
      
      cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab := Stuff(cCab,121,06,cCpo)                  // Sequencia crescente do registro
      
      nSeq++  
    
      If fWrite(nHdlNFENTR,cCab,Len(cCab)) != (Len(cCab))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab). ","Atencao!")
               Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab)"}) 
               Aadd(aDetNFE,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab) - Entre em contato com suporte."})  
               Ferase(cTemp)
               Ferase(cIndex+OrdBagExt())  
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab)"})              
            Return .F.
         Endif
      Endif 
                 
      nTamLin   := 126
   
      cCab2 := Space(nTamLin)                             // Variavel para criacao da linha do registros para gravacao 
	 
	  cCab2 := Stuff(cCab2,0,03,"NEC")                    // Valor Fixo "NEC" 
		 		
	  cCab2 := Stuff(cCab2,04,03,"   ")                    // Serie da nota fiscal - Transfer�ncia/movimenta��o n�o possui serie.
	
	  //cCab2 := Stuff(cCab2,05,02,"")                     // SubSerie nota fiscal  
	  
	  cCpo := Replicate("0",9-Len(Alltrim(TRBNFENTR->D3_DOC)))
      cCpo := alltrim(cCpo)+Alltrim(TRBNFENTR->D3_DOC)		                                			
  	  cCab2 := Stuff(cCab2,07,09,cCpo)                     // Numera��o da nota
	  
	  cCpo  := DTOS(TRBNFENTR->D3_EMISSAO)
	    	  	  	  
	  cCpo  := ClearVal(cCpo)
	  
	  cCpo  := Stuff(cCpo,5,0,"-")                        // Tratamento AAAA-MM-DD
                                                          
      cCpo  := Stuff(cCpo,8,0,"-")                        // Tratamento AAAA-MM-DD
	   	  
	  cCab2 := Stuff(cCab2,16,10,cCpo)                    // Data de emissao
	   	  	  
	  COUNTNFE(TRBNFENTR->D3_FILIAL,TRBNFENTR->D3_DOC)
	  
	  nCountItem:=QTD->QTD 
	  
	  QTD->(dbCloseArea())
      	   
	  cCab2 := Stuff(cCab2,26,03,StrZero(nCountItem,3,0))         // Quantidade de itens  
	  
	  SD3Compara:=TRBNFENTR->D3_FILIAL+TRBNFENTR->D3_DOC 
	     
	  nValTotNF:=0    	  
      While TRBNFENTR->(!EOF()) .And. (SD3Compara == TRBNFENTR->D3_FILIAL+TRBNFENTR->D3_DOC) 
	  	    
	     nValTotNF+=TRBNFENTR->D3_CUSTO1
	     TRBNFENTR->(DbSkip())
        
      EndDo
	          
	  cCpo := StrZero(nValTotNF ,16,4)
	  cCpo  := ClearVal(cCpo) 
	  cCpo  := "0"+cCpo 
	  cCab2 := Stuff(cCab2,29,16,cCpo)        // Valor da nota
	  
	  cCpo  := PADR(SPACE(76),76)  
      cCab2  := Stuff(cCab2,45,76,cCpo)           // Fixo em branco   	
	                                                                       
	  cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab2 := Stuff(cCab2,121,06,cCpo)+cEOL                    // Sequencia crescente do registro
      
      If fWrite(nHdlNFENTR,cCab2,Len(cCab2)) != (Len(cCab2))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab2). ","Atencao!")
               Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab2)"})
               Aadd(aDetNFE,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab2) - Entre em contato com suporte."})  
               Ferase(cTemp)              
               Ferase(cIndex+OrdBagExt()) 
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cCab2)"})    
            Return .F.
         Endif
      Endif 
                
      nSeq++ 
       
      TRBNFENTR->(DbGotop())
      TRBNFENTR->(DbSetOrder(1))     	  
	  TRBNFENTR->(DbSeek(SD3Compara))   
                    
      Do While TRBNFENTR->(!EOF())	.And. TRBNFENTR->D3_FILIAL+TRBNFENTR->D3_DOC == SD3Compara
	
      IncProc()			    	   	    	 		
			    	 					 
	     cLin := Space(nTamLin)                       // Variavel para criacao da linha do registros para gravacao 
	     
	     cLin := Stuff(cLin,0,03,"NEI")               // Valor Fixo "NEI" 
		 
	     cLin := Stuff(cLin,04,03,"   ")              // Serie da nota fiscal
	                                        
	     //cCpo := PADR(SPACE(2),2)
	     //cLin := Stuff(cLin,05,02,cCpo)             // SubSerie nota fiscal   
	     
	     cCpo := Replicate("0",9-Len(Alltrim(TRBNFENTR->D3_DOC)))
         cCpo := alltrim(cCpo)+Alltrim(TRBNFENTR->D3_DOC)			
  	     cLin := Stuff(cLin,07,09,cCpo )       // Numera��o da nota
	 	     		
	     cLin := Stuff(cLin,16,20,TRBNFENTR->D3_COD)       // Codigo do Item
	
	     cLin := Stuff(cLin,36,03,TRBNFENTR->D3_UM)        // Unidade do produto
		 
		 cCpo := StrZero(TRBNFENTR->D3_QUANT,6,0) 
		 cCpo := ClearVal(cCpo)
		 cLin := Stuff(cLin,39,06,cCpo)                    // Quantidade 

		 cLin := Stuff(cLin,45,03,"000")                   // Quantidade de caixas
		
		 cCpo := PADR(SPACE(20),20)
		 cLin := Stuff(cLin,48,20,TRBNFENTR->D3_LOTECTL)   // Numero do Lote
		   		 
	     cCpo := PADR(SPACE(10),10)
		 cLin := Stuff(cLin,68,10,cCpo)                    // Data de Fabrica��o		 
		 
		 If Empty(TRBNFENTR->D3_DTVALID)
		    cCpo := PADR(SPACE(10),10)
		 Else
		    cCpo  := DTOS(TRBNFENTR->D3_DTVALID)       
	     	 		     	
	     	cCpo  := ClearVal(cCpo) 
	     		     	     
	        cCpo  := Stuff(cCpo,5,0,"-")                   // Tratamento AAAA-MM-DD
       
            cCpo  := Stuff(cCpo,8,0,"-")                   // Tratamento AAAA-MM-DD
	   	 
	   	 EndIf 				                		        
		 
		 cLin := Stuff(cLin,78,10,cCpo)                    // Data de Validade       		           		 

         nValTot    := (TRBNFENTR->D3_CUSTO1)
         nValUnit   := (TRBNFENTR->D3_CUSTO1/TRBNFENTR->D3_QUANT)

		 cCpo := StrZero(nValUnit,16,4)	 
		 cCpo := ClearVal(cCpo)
		 cCpo := "0"+cCpo 	 
		 cLin := Stuff(cLin,88,16,cCpo)                    // Custo unit�rio  		

		 cCpo := StrZero(nValTot,16,4) 
		 cCpo := ClearVal(cCpo)
		 cCpo := "0"+cCpo        		 		 
		 cLin := Stuff(cLin,104,16,cCpo)                   // Custo total do item		 
		 	             
         cLin := Stuff(cLin,121,1,"2")                     // Indicador de quarentena
	   
	     cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
         cCpo  := cCpo+Alltrim(STR(nSeq))
         cLin := Stuff(cLin,121,06,cCpo)+cEOL                     // Sequencia crescente do registro
      
         If fWrite(nHdlNFENTR,cLin,Len(cLin)) != (Len(cLin))
            If !(lAut)
               If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cLin). ","Atencao!")
                  Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cLin)"})  
                  Aadd(aDetNFE,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cLin) - Entre em contato com suporte."})  
                  Ferase(cTemp)           
                  Ferase(cIndex+OrdBagExt()) 
                  Return .F. 
               EndIf
            Else      
               Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cLin)"})        
               Return .F.
            Endif
         Endif 
       
	     nSeq++
	     TRBNFENTR->(DbSkip())
	  
	  EndDo   
	     
	   
      // Finaliza��o do arquivo TXT    
      
      nTam := 120              
                  
      cFin := Space(nTam)+cEOL            // Variavel para criacao da linha do registros para gravacao      
      //cFin := Space(nTamLin)+cEOL            // Variavel para criacao da linha do registros para gravacao 

      cFin := Stuff(cFin,00,3,"FTR")          // Fixo 'FTR'
   
      cCpo := "000001"
      cFin := Stuff(cFin,04,06,cCpo)          // Quantidade de registros do tipo NFE  - Ser� gerado uma nota por arquivo
      
      cFin := Stuff(cFin,10,06,StrZero(nCountItem+1,6,0))    // Quantidade de itens da nota + cabe�ario ( NEC + NEI )

      cCpo := PAD(Space(105),105)             // Fixo em branco.
      cFin := Stuff(cFin,16,105,cCpo)
       
      cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo := cCpo+Alltrim(STR(nSeq))
      cFin := Stuff(cFin,121,1,substr(Alltrim(cCpo),1,6))   // Sequencia crescente do registro
     
      If fWrite(nHdlNFENTR,cFin,Len(cFin)) != (Len(cFin))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, registro de finaliza��o FTR (cFin). ","Atencao!")   
               Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cFin)"})   
               Aadd(aDetNFE,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cFin) - Entre em contato com suporte."})
               Ferase(cTemp)                 
               Ferase(cIndex+OrdBagExt()) 
               Return .F.
            EndIf
         Else
            Aadd(aRegLogNfeImprime,{cIdNfEntrProx,nCountNota,"Erro no cabe�alho HDR - NFE (cFin)"})
            Return .F.
         Endif
      Endif

      fClose(nHdlNFENTR)   
      
      If SD3->(FieldPos("D3_P_STATS")) > 0
         // Atualiza a Base (D3_P_STATS) com os arquivos que foram enviados.
         SD3->(DbSetOrder(2))   
         SD3->(DbSeek(SD3Compara))                    
         While SD3->D3_FILIAL+SD3->D3_DOC == SD3Compara
               
            If SD3->D3_LOCAL='03' .AND. SD3->D3_ESTORNO<>'S' .AND. SD3->D3_TM<'500' .AND. SD3->D3_CF='DE4'  
               SD3->(RecLock("SD3",.F.))
               SD3->D3_P_STATS:="E"
               SD3->(MsUnlock())   
            EndIf
               
            SD3->(DbSkip())
         EndDo   
              
         SX6->(DbSetOrder(1))                 
         // Atualiza o SX6 �ltima numera��o.
         If (SX6->(DbSeek(XFilial()+"MV_RED_NFE")))  
            RecLock("SX6",.F.)
	        SX6->X6_CONTEUD := cIdNfEntrProx 	   
	        SX6->( MsUnlock())              
         EndIf
            
         // Grava LOG da NFE caso tenha sido gerado.  
         ZRD->(DbSetOrder(1))
         RecLock("ZRD",.T.)
         ZRD->ZRD_FILIAL := xFilial()
         ZRD->ZRD_COD    := Substr(cIdNfEntrProx,1,8)
         ZRD->ZRD_DATA   := Date()
         ZRD->ZRD_HORA   := Time()
         ZRD->ZRD_USER   := cUserName
         ZRD->ZRD_ROTINA := "TXTNFENTR"
         ZRD->ZRD_ARQUIV := Alltrim(cIdNfEntrProx)
         ZRD->ZRD_GERLOC := "Gerado Local"
         ZRD->ZRD_GERFTP := "Nao gerado FTP"
         ZRD->ZRD_QTDREG := nCountItem
         ZRD->ZRD_OBS    := "Movimento de libera��o : "+Alltrim(substr(SD3Compara,3,9))
         ZRD->( MsUnlock()) 
             
         If !(lNfe1)  // Guarda o primeiro arquivo gerado                                     
            Aadd(aRegLogNfeImprime,{"De :"+cIdNfEntrProx,,"Gerado Local" })                 
         EndIf
                   
         Aadd(aDetNFE,{"Rotina de gera��o de arquivo de Nota Fiscal de Entrada","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo gerado: "+cIdNfEntrProx,;
         "Movimento de libera��o : "+Alltrim(substr(SD3Compara,3,9)),"Numero de itens  : "+Alltrim(Str(nCountItem)),;
         "Usu�rio : "+alltrim(cUserName),"Data : "+ DTOC(Date())})   
            
         lNfe1:=.T.
                           
         nCountNota++
     
      EndIf       
                     
      lRetNfEntr:=.T. 
             
   EndDo
       
   aRegLogNfeImprime[1][1]+="    At�    "+ Alltrim(cIdNfEntrProx)
   aRegLogNfeImprime[1][2]:= nCountNota
         
   
   TRBNFENTR->(dbCloseArea()) 
   Ferase(cTemp)
   Ferase(cIndex+OrdBagExt())                                                 
 
End Sequence
 
Return (lRetNfEntr)     


*----------------------------*                                          
Static Function TXTPEDIDO() 
*----------------------------*             

Local cComparaPed:=""
Local nCountItem:=nCountPED:=0 
Local lPed1:=.F.
Local nSeq
Local n  

Begin Sequence 

   If TRBPEDIDO->(EOF())
      Aadd(aRegLogPedImprime,{" Arquivo n�o gerado: "+cIdPedidoProx,nCountPed,"Sem dados para gera��o"}) 
      Aadd(aDetPED,{"Rotina de gera��o de arquivo de Pedido.","Filial : "+Alltrim(SM0->M0_NOME)+".","Arquivo n�o foi gerado.",;
      "Quantidade de pedidos : 0 ","Usu�rio : "+alltrim(cUserName)+".","Data : "+ DTOC(Date())+".","Verifique se houve inclus�o de pedidos no sistema."})   
      fClose(nHdlPedido)       
      TRBPEDIDO->(dbCloseArea())                                               
      Return .F.
   EndIf

   
   Do While TRBPEDIDO->(!EOF())
     
      ProcRegua(RecCount()) // Numero de registros a processar       
      
      nSeq:=1 
      
      If lPed1   // Sera gerado um arquivo para cada pedido, ap�s gerar o primeira ser� necess�rio criar outro TXT
         
         If SX6->(DbSeek(XFilial()+"MV_RED_PED"))
            // Pega a proxima numera��o para o pedido
            cIdPedido := Alltrim(SX6->X6_CONTEUD) 
            cIdAux := Val(Substr(cIdPedido,2,08)) 
            cIdAux := cIdAux+1
            cIdPedidoProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux))+".PED" 
            // Gera um novo TXT para a pr�xima nota
            cTxtPedido:=cDirPedido+cIdPedidoProx
            nHdlPedido:=fCreate(cTxtPedido)
         
         EndIf 
         
      Else
      
         nHdlPEDIDO:= fCreate(cTxtPEDIDO)  
         If !(lAut)    // Verifica se a rotina � automatica.  
            If nHdlPEDIDO == -1 // Testa se o arquivo foi gerado
               MsgAlert("O arquivo "+cTxtPEDIDO+" nao pode ser executado!","Aten��o")
               Aadd(aRegLogPedImprime,{cIdPedidoProx,"0","Erro na cria��o do arquivo"})
               Aadd(aDetPED,{cIdPedidoProx,"0","Erro na cria��o do arquivo entre em contato com suporte."}) 
               TRBPEDIDO->(dbCloseArea()) 
            EndIf  
         EndIf     
              
      EndIf
      
      nTamLin   := 85
      cCab  := Space(nTamLin) // Variavel para criacao da linha do registros para gravacao
 
      //        Cabe�alho         -----------       Coment�rios

      cCab  := Stuff(cCab,0,03,"HDR")            // Fixo com "HDR"

      cCab  := Stuff(cCab,04,03,"018")           // Informa��o passa pela ATIVA

      cCpo  := PADR(SPACE(73),73)  
      cCab  := Stuff(cCab,07,79,cCpo)           // Fixo em branco
      
      cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab := Stuff(cCab,80,06,cCpo)+cEOL           // Sequencia crescente do registro
                                                   
      nSeq++  
    
      If fWrite(nHdlPedido,cCab,Len(cCab)) != (Len(cCab))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab). ","Atencao!")
               Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab)"})
               Aadd(aDetPED,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab) - Entre em contato com suporte."})   
               TRBPEDIDO->(dbCloseArea()) 
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab)"})              
            Return .F.
         Endif
      Endif 
                 
      nTamLin   := 85
   
      cCab2 := Space(nTamLin)+cEOL                        // Variavel para criacao da linha do registros para gravacao 
	 
	  cCab2 := Stuff(cCab2,0,03,"PDC")                    // Valor Fixo "PDC" 
		 		
	  cCab2 := Stuff(cCab2,04,01,TRBPEDIDO->C5_NUM)       // Numero do Pedido
	
	  cCpo  := DTOS(TRBPEDIDO->C5_EMISSAO)
	    	  	  	  
	  cCpo  := ClearVal(cCpo)
	  
	  cCpo  := Stuff(cCpo,5,0,"-")                         // Tratamento AAAA-MM-DD
       
      cCpo  := Stuff(cCpo,8,0,"-")                         // Tratamento AAAA-MM-DD
	   	  
	  cCab2 := Stuff(cCab2,24,10,cCpo)                     // Data de emissao
	   	  	  
	  cCab2 := Stuff(cCab2,34,20,TRBPEDIDO->C5_CLIENTE)    // Codigo do cliente
	    
	  COUNTPED(TRBPEDIDO->C5_FILIAL,TRBPEDIDO->C5_NUM)
	  
	  nCountItem:=QTD->QTD 
	  
	  QTD->(dbCloseArea())
      	   
	  cCab2 := Stuff(cCab2,54,03,StrZero(nCountItem,3,0))   // Quantidade de itens
	 
	  cCab2 := Stuff(cCab2,57,01,"2")                      // Indicador de prioridade
	  
	  cCab2 := Stuff(cCab2,58,01,"1")                      // Criterio de Atendimento 
	  	  
      cCpo := PAD(Space(21),21)            
      cCab2 := Stuff(cCab2,59,21,cCpo)                        // Fixo em branco   
	                                                                       
	  cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab2 := Stuff(cCab2,80,06,cCpo)+cEOL                      // Sequencia crescente do registro
      
      If fWrite(nHdlPEDIDO,cCab2,Len(cCab2)) != (Len(cCab2))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab2). ","Atencao!")
               Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab2)"})  
               Aadd(aDetPED,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab2) - Entre em contato com suporte."})  
               TRBPEDIDO->(dbCloseArea()) 
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cCab2)"})    
            Return .F.
         Endif
      Endif 
                
      nSeq++ 
       
      cComparaPed:=TRBPEDIDO->C5_FILIAL+TRBPEDIDO->C5_NUM 
   
      Do While TRBPEDIDO->(!EOF())	.And. TRBPEDIDO->C5_FILIAL+TRBPEDIDO->C5_NUM == cComparaPed
	
      IncProc()
			 
	     cLin := Space(nTamLin)+cEOL                      // Variavel para criacao da linha do registros para gravacao 
	     
	     cLin := Stuff(cLin,0,03,"PDI")                    // Valor Fixo "PDI" 
		 
	     cLin := Stuff(cLin,04,20,TRBPEDIDO->C5_NUM)       // Numero do Pedido
	
	     cLin := Stuff(cLin,24,20,TRBPEDIDO->C6_PRODUTO)   // Codigo do Item
	 
		 cCpo := StrZero(TRBPEDIDO->C6_QTDVEN,6,0)
		 cCpo := ClearVal(cCpo)
		 cLin := Stuff(cLin,44,06,cCpo)                    // Quantidade 
			   		 
		 If Empty(TRBPEDIDO->C6_DTVALID)
		    
		    cCpo := PADR(SPACE(10),10)
		 
		 Else
		    
		    cCpo  := TRBPEDIDO->C6_DTVALID       
	     	 		     	
	     	cCpo  := ClearVal(cCpo) 
	     		     	     
	        cCpo  := Stuff(cCpo,5,0,"-")                   // Tratamento AAAA-MM-DD
       
            cCpo  := Stuff(cCpo,8,0,"-")                   // Tratamento AAAA-MM-DD
	   	 
	   	 EndIf 		
		 
		 cLin := Stuff(cLin,50,10,cCpo)                    // Data de Validade
		                                     		                               
		 nSpc := Len(alltrim(TRBPEDIDO->C6_LOTECTL))     
		 cCpo := PAD(Space(20-nSpc),20) 
		 cCpo := alltrim(TRBPEDIDO->C6_LOTECTL)+cCpo 
		 cLin := Stuff(cLin,60,20,cCpo)                    // Lote
		                         
	     //cCpo := PAD(Space(20),20)                         // Fixo em branco.
         //cLin := Stuff(cLin,60,20,cCpo)

	     cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
         cCpo  := cCpo+Alltrim(STR(nSeq))
         cLin := Stuff(cLin,80,06,cCpo)+cEOL                    // Sequencia crescente do registro
      
         If fWrite(nHdlPedido,cLin,Len(cLin)) != (Len(cLin))
            If !(lAut)
               If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cLin). ","Atencao!")
                  Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cLin)"})
                  Aadd(aDetPED,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cLin) - Entre em contato com suporte."})   
                  TRBPEDIDO->(dbCloseArea()) 
                  Return .F. 
               EndIf
            Else      
               Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cLin)"})        
               Return .F.
            Endif
         Endif 
       
	     nSeq++
	     TRBPEDIDO->(DbSkip())
	  
	  EndDo   
	     	   
      // Finaliza��o do arquivo TXT         
      cFin := Space(nTamLin)+cEOL             // Variavel para criacao da linha do registros para gravacao 

      cFin := Stuff(cFin,00,3,"FTR")          // Fixo 'FTR'
   
      cCpo := "001"
      cFin := Stuff(cFin,04,03,cCpo)          // Quantidade de registros do tipo PDC  - Ser� gerado uma nota por arquivo
      
      cFin := Stuff(cFin,07,06,StrZero(nCountItem+1,6,0))    // Quantidade de itens do pedido + cabe�ario

      cCpo := PAD(Space(67),67)               // Fixo em branco.
      cFin := Stuff(cFin,13,67,cCpo)
       
      cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo := cCpo+Alltrim(STR(nSeq))
      cFin := Stuff(cFin,80,06,cCpo)   // Sequencia crescente do registro
     
      If fWrite(nHdlPedido,cFin,Len(cFin)) != (Len(cFin))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, registro de finaliza��o FTR (cFin). ","Atencao!")   
               Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cFin)"})
               Aadd(aDetPED,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cFin) - Entre em contato com suporte."})
               TRBPEDIDO->(dbCloseArea()) 
               Return .F.
            EndIf
         Else
            Aadd(aRegLogPedImprime,{cIdPedidoProx,nCountPed,"Erro no cabe�alho HDR - PED (cFin)"})
            Return .F.
         Endif
      Endif

      fClose(nHdlPedido)   
    
      If SC5->(FieldPos("C5_P_STATS")) > 0
         // Atualiza a Base (C5_P_STATS) com os arquivos que foram enviados.
         SC5->(DbSetOrder(1))   
         SC5->(DbSeek(cComparaPed))                    
         If SC5->C5_FILIAL+SC5->C5_NUM == cComparaPed
            SC5->(RecLock("SC5",.F.))
            SC5->C5_P_STATS:="E"
            SC5->(MsUnlock())   
            
            SX6->(DbSetOrder(1))                 
            // Atualiza o SX6 �ltima numera��o.
            If (SX6->(DbSeek(XFilial()+"MV_RED_PED")))  
               RecLock("SX6",.F.)
	           SX6->X6_CONTEUD := cIdPedidoProx 	   
	          SX6->( MsUnlock())              
            EndIf
            
            // Grava LOG do Pedido caso tenha sido gerado.  
            ZRD->(DbSetOrder(1))
            RecLock("ZRD",.T.)
            ZRD->ZRD_FILIAL := xFilial()
            ZRD->ZRD_COD    := Substr(cIdPedidoProx,1,8)
            ZRD->ZRD_DATA   := Date()
            ZRD->ZRD_HORA   := Time()
            ZRD->ZRD_USER   := cUserName
            ZRD->ZRD_ROTINA := "TXTPEDIDO"
            ZRD->ZRD_ARQUIV := Alltrim(cIdPedidoProx)
            ZRD->ZRD_GERLOC := "Gerado Local"
            ZRD->ZRD_GERFTP := "Nao gerado FTP"
            ZRD->ZRD_QTDREG := nCountItem     
            ZRD->ZRD_OBS    := "Pedido : "+Alltrim(substr(cComparaPed,3,6))+" Quantidade de itens : "+Alltrim(STR(nCountItem)) 
            ZRD->ZRD_PEDIDO := Alltrim(substr(cComparaPed,3,6)) 
            ZRD->( MsUnlock()) 
             
            If !(lPed1)  // Guarda o primeiro arquivo gerado                                     
               Aadd(aRegLogPedImprime,{"De :"+cIdPedidoProx,,"Gerado Local" })                 
            EndIf 
            
             Aadd(aDetPED,{"Rotina de gera��o de arquivo de Pedido","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo gerado: "+cIdPedidoProx,;
             "Pedido : "+Alltrim(substr(cComparaPed,3,6))+".","Numero de itens  : "+Alltrim(Str(nCountItem))+".","Usu�rio : "+alltrim(cUserName)+".",;
             "Data : "+ DTOC(Date())+"."})   
            
            lPed1:=.T.
                     
         EndIf
         
         nCountPed++
     
      EndIf       
                     
      lRetPedido:=.T. 
             
   EndDo
       
   aRegLogPedImprime[1][1]+="    At�    "+ Alltrim(cIdPedidoProx)
   aRegLogPedImprime[1][2]:= nCountPed
   
   TRBPEDIDO->(dbCloseArea())                                                
 
End Sequence
 
Return (lRetPedido)     

// Monta arquivo de nota fiscal de saida.
*----------------------------*                                          
Static Function TXTNFSAID() 
*----------------------------*             

Local cComparaNFS:=""
Local nCountItem:=nCountNota:=0 
Local lNfs1:=.F.
Local nSeq
Local n  

Begin Sequence 

   If TRBNFSAID->(EOF())
      Aadd(aRegLogNfsImprime,{" Arquivo n�o gerado: "+cIdNfSaidProx,nCountNota,"Sem dados para gera��o"}) 
      fClose(nHdlNFSaid)       
      TRBNFSAID->(dbCloseArea())                                                `` 
      Return .F.
   EndIf

   
   Do While TRBNFSAID->(!EOF())
     
      ProcRegua(RecCount()) // Numero de registros a processar     
      
      nSeq:=1 
      
      If lNfs1   // Sera gerado um arquivo para cada nota, ap�s gerar a primeira ser� necess�rio criar outro TXT
         
         If SX6->(DbSeek(XFilial()+"MV_RED_NFS"))
            // Pega a proxima numera��o para nota
            cIdNFSaid := Alltrim(SX6->X6_CONTEUD) 
            cIdAux := Val(Substr(cIdNFSaid,2,08))
            cIdNfSaidProx:= "A"+Replicate("0",7-Len(Alltrim(STR(cIdAux))))+Alltrim(Str(cIdAux+1))+".NFS" 
            // Gera um novo TXT para a pr�xima nota
            cTxtNFSAID:=cDirNfSaid+cIdNfSaidProx
            nHdlNFSaid:=fCreate(cTxtNFSaid)
         
         EndIf
      
      EndIf
      
      nTamLin   := 2100
      cCab  := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
 
      //        Cabe�alho         -----------       Coment�rios

      cCab  := Stuff(cCab,0,03,"HDR")            // Fixo com "HDR"

      cCab  := Stuff(cCab,04,03,"018")        // Informa��o passa pela ATIVA

      cCpo  := PADR(SPACE(2061),2061)  
      cCab  := Stuff(cCab,07,2061,cCpo)           // Fixo em branco
      
      cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab := Stuff(cCab,118,06,cCpo)                    // Sequencia crescente do registro
      
      nSeq++  
    
      If fWrite(nHdlNFSaid,cCab,Len(cCab)) != (Len(cCab))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab). ","Atencao!")
               Aadd(aRegLogNfsImprime,{cIdNfDSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cCab)"})
               TRBNFSAID->(dbCloseArea())
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cCab)"})              
            Return .F.
         Endif
      Endif 
                 
      nTamLin   := 450
   
      cCab2 := Space(nTamLin)+cEOL                        // Variavel para criacao da linha do registros para gravacao 
	 
	  cCab2 := Stuff(cCab2,0,03,"NEC")                    // Valor Fixo "NEI" 
		 		
	  cCab2 := Stuff(cCab2,04,01,TRBNFSAID->F2_SERIE)     // Serie da nota fiscal
	
	  cCab2 := Stuff(cCab2,05,02,"")                      // SubSerie nota fiscal
		
  	  cCab2 := Stuff(cCab2,07,06,TRBNFSAID->F2_DOC)        // Numera��o da nota
	  
	  cCpo  := DTOS(TRBNFSAID->F2_EMISSAO)
	    	  	  	  
	  cCpo  := ClearVal(cCpo)
	  
	  cCpo  := Stuff(cCpo,5,0,"-")                         // Tratamento AAAA-MM-DD
       
      cCpo  := Stuff(cCpo,8,0,"-")                         // Tratamento AAAA-MM-DD
	   	  
	  cCab2 := Stuff(cCab2,13,10,cCpo)                      // Data de emissao
	   	  	  
	  COUNTNFS(TRBNFSAID->F2_FILIAL,TRBNFSAID->F2_DOC,TRBNFSAID->F2_SERIE,TRBNFSAID->F2_CLIENTE)
	  
	  nCountItem:=QTD->QTD 
	  
	  QTD->(dbCloseArea())
      	   
	  cCab2 := Stuff(cCab2,23,03,StrZero(nCountItem,3,0))         // Quantidade de itens
	  
	  cCpo  := StrZero(NoRound(TRBNFSAID->F2_VALMERC,4),16,4) 
	  cCpo  := ClearVal(cCpo)
	  cCab2 := Stuff(cCab2,26,16,cCpo)        // Valor da nota
	    
      cCab2 := Stuff(cCab2,42,76,"")                       // Fixo em branco
	                                                                       
	  cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo  := cCpo+Alltrim(STR(nSeq))
      cCab2 := Stuff(cCab2,118,06,cCpo)                    // Sequencia crescente do registro
      
      If fWrite(nHdlNFSAID,cCab2,Len(cCab2)) != (Len(cCab2))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cCab2). ","Atencao!")
               Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cCab2)"})
               TRBNFSAID->(dbCloseArea())
               Return .F. 
            EndIf
         Else  
            Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cCab2)"})    
            Return .F.
         Endif
      Endif 
                
      nSeq++ 
       
      cComparaNFS:=TRBNFSAID->F2_FILIAL+TRBNFSAID->F2_DOC+TRBNFSAID->F2_SERIE+TRBNFSAID->F2_CLIENTE 
   
      Do While TRBNFSAID->(!EOF())	.And. TRBNFSAID->F2_FILIAL+TRBNFSAID->F2_DOC+TRBNFSAID->F2_SERIE+TRBNFSAID->F2_CLIENTE == cComparaNFS
	
      IncProc()
			 
	     cLin := Space(nTamLin)+cEOL                       // Variavel para criacao da linha do registros para gravacao 
	     
	     cLin := Stuff(cLin,0,03,"NSI")                    // Valor Fixo "NEI" 
		 
	     cLin := Stuff(cLin,04,01,TRBNFSAID->D2_SERIE)     // Serie da nota fiscal
	
	     cCpo := PADR(SPACE(2),2)
	     cLin := Stuff(cLin,05,02,cCpo)                    // SubSerie nota fiscal
		
  	     cLin := Stuff(cLin,07,06,TRBNFSAID->D2_DOC)       // Numera��o da nota
	 	     		
	     cLin := Stuff(cLin,13,20,TRBNFSAID->D2_COD)       // Codigo do Item
	
	     cLin := Stuff(cLin,33,03,TRBNFSAID->D2_UM)        // Unidade do produto
		 
		 cCpo := StrZero(TRBNFSAID->D2_QUANT,6,0)
		 cCpo := ClearVal(cCpo)
		 cLin := Stuff(cLin,36,06,cCpo)                    // Quantidade 
		
		 cCpo := PADR(SPACE(03),03)
		 cLin := Stuff(cLin,42,03,cCpo)                    // Quantidade de caixas
		
		 cLin := Stuff(cLin,45,20,TRBNFSAID->D2_LOTECTL)   // Numero do Lote
		   		 
	     cCpo := PADR(SPACE(10),10)
		 cLin := Stuff(cLin,65,10,cCpo)                    // Data de Fabrica��o
		 
		 If Empty(TRBNFSAID->D2_DTVALID)
		    cCpo:=TRBNFSAID->D2_DTVALID
		 Else
		    cCpo  := TRBNFSAID->D2_DTVALID       
	     	 		     	
	     	cCpo  := ClearVal(cCpo) 
	     		     	     
	        cCpo  := Stuff(cCpo,5,0,"-")                   // Tratamento AAAA-MM-DD
       
            cCpo  := Stuff(cCpo,8,0,"-")                   // Tratamento AAAA-MM-DD
	   	 
	   	 EndIf 		
		 
		 cLin := Stuff(cLin,75,10,cCpo)                    // Data de Validade
		 
		 cCpo := StrZero(NoRound(TRBNFSAID->D2_VUNIT,4),16,4)
		 cCpo := ClearVal(alltrim(Str(cCpo)))
		 cLin := Stuff(cLin,85,16,cCpo)                    // Custo unit�rio
		        
		 cCpo := StrZero(NoRound(TRBNFSAID->D2_TOTAL,4),16,4)
		 cCpo := ClearVal(alltrim(Str(cCpo)))
		 cLin := Stuff(cLin,101,16,cCpo)                   // Custo total do item
         
         cLin := Stuff(cLin,59,20,"2")                     // Indicador de quarentena
	   
	     cCpo  := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
         cCpo  := cCpo+Alltrim(STR(nSeq))
         cLin := Stuff(cLin,118,06,cCpo)                    // Sequencia crescente do registro
      
         If fWrite(nHdlNFSaid,cLin,Len(cLin)) != (Len(cLin))
            If !(lAut)
               If !MsgAlert("Ocorreu um erro na gravacao do arquivo, cabe�alho HDR (cLin). ","Atencao!")
                  Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cLin)"})
                  TRBNFSAID->(dbCloseArea())
                  Return .F. 
               EndIf
            Else      
               Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cLin)"})        
               Return .F.
            Endif
         Endif 
       
	     nSeq++
	     TRBNFSAID->(DbSkip())
	  
	  EndDo   
	     
	   
      // Finaliza��o do arquivo TXT         
      cFin := Space(nTamLin)+cEOL             // Variavel para criacao da linha do registros para gravacao 

      cFin := Stuff(cFin,00,3,"FTR")          // Fixo 'FTR'
   
      cCpo := "000001"
      cFin := Stuff(cFin,04,06,cCpo)          // Quantidade de registros do tipo NFE  - Ser� gerado uma nota por arquivo
      
      cFin := Stuff(cFin,10,06,StrZero(nCountItem,6,0))    // Quantidade de itens da nota 

      cCpo := PAD(Space(102),102)             // Fixo em branco.
      cFin := Stuff(cFin,16,102,cCpo)
       
      cCpo := Replicate("0",6-Len(Alltrim(STR(nSeq)))) 
      cCpo := cCpo+Alltrim(STR(nSeq))
      cFin := Stuff(cFin,118,1,cCpo)   // Sequencia crescente do registro
     
      If fWrite(nHdlNFSAID,cFin,Len(cFin)) != (Len(cFin))
         If !(lAut)
            If !MsgAlert("Ocorreu um erro na gravacao do arquivo, registro de finaliza��o FTR (cFin). ","Atencao!")   
               Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cFin)"})    
               TRBNFSAID->(dbCloseArea())
               Return .F.
            EndIf
         Else
            Aadd(aRegLogNfsImprime,{cIdNfSaidProx,nCountNota,"Erro no cabe�alho HDR - NFS (cFin)"})
            Return .F.
         Endif
      Endif

      fClose(nHdlNFSAID)   
    
      If SF2->(FieldPos("F2_P_STATS")) > 0
         // Atualiza a Base (F2_P_STATS) com os arquivos que foram enviados.
         SF2->(DbSetOrder(1))   
         SF2->(DbSeek(cComparaNFS))                    
         If SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_FORNECE == cComparaNFS
            SF2->(RecLock("SF2",.F.))
            SF2->F2_P_STATS:="E"
            SF2->(MsUnlock())   
         
            SX6->(DbSetOrder(1))                 
            // Atualiza o SX6 �ltima numera��o.
            If (SX6->(DbSeek(XFilial()+"MV_RED_NFS")))  
               RecLock("SX6",.F.)
	           SX6->X6_CONTEUD := cIdNfSaidProx 	   
	           SX6->( MsUnlock())              
            EndIf
            
            // Grava LOG da NFE caso tenha sido gerado.  
            ZRD->(DbSetOrder(1))
            RecLock("ZRD",.T.)
            ZRD->ZRD_FILIAL := xFilial()
            ZRD->ZRD_COD    := Substr(cIdNfSaidProx,1,8)
            ZRD->ZRD_DATA   := Date()
            ZRD->ZRD_HORA   := Time()
            ZRD->ZRD_USER   := cUserName
            ZRD->ZRD_ROTINA := "TXTNFSAID"
            ZRD->ZRD_ARQUIV := Alltrim(cIdNfSaidProx)
            ZRD->ZRD_GERLOC := "Gerado Local"
            ZRD->ZRD_GERFTP := "Nao gerado FTP"
            ZRD->ZRD_QTDREG := nCountItem
            ZRD->( MsUnlock()) 
             
            If !(lNfs1)  // Guarda o primeiro arquivo gerado                                     
               Aadd(aRegLogNfsImprime,{"De :"+cIdNfSaidProx,,"Gerado Local" })                 
            EndIf 
            
            Aadd(aDetNFS,{"Rotina de gera��o de arquivo de Nota Fiscal de Saida","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo gerado: "+cIdNfSaidProx,;
            "Nota : "+Alltrim(TRBNFSAID->F2_DOC)+" Serie : "+Alltrim(TRBNFSAID->F2_SERIE),"Usu�rio : "+alltrim(cUserName),"Data : "+ DTOC(Date())})   
            
            lNfs1:=.T.
         
         Else
            Aadd(aDetNFS,{"Rotina de gera��o de arquivo de Nota Fiscal de Saida","Filial : "+Alltrim(SM0->M0_NOME),"Arquivo n�o foi gerado",;
            "Quantidade de notas : 0 ","Usu�rio : "+alltrim(cUserName),"Data : "+ DTOC(Date()),"Verifique se houve inclus�o de notas no sistema"})   
         
         EndIf
         
         nCountNota++
     
      EndIf       
                     
      lRetNfSaid:=.T. 
             
   EndDo
       
   aRegLogNfsImprime[1][1]+="    At�    "+ Alltrim(cIdNfSaidProx)
   aRegLogNfsImprime[1][2]:= nCountNota
   
   TRBNFSAID->(dbCloseArea())                                               
 
End Sequence
 
Return (lRetNfSaid)     

            
// Monta arquivo temporario com dados do cliente.
*-----------------------*
Static Function SQLDESTIN() 
*------------------------*
Local nSA1 := 0
    
aStruSA1  := SA1->(dbStruct())

cQuery:=" SELECT A1.A1_FILIAL,A1.A1_COD,A1.A1_LOJA,A1.*"
cQuery+=" FROM "+RetSqlName("SA1")+" A1"
cQuery+=" WHERE A1.D_E_L_E_T_ <> '*' "
cQuery+=" AND A1.A1_P_STATS <> 'E' "
cQuery+=" ORDER BY A1.A1_FILIAL,A1.A1_COD,A1.A1_LOJA"  // R_E_C_N_O_ 
                                                                
cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRBDESTIN',.F.,.T.)       

For nSA1 := 1 To Len(aStruSA1)
	If aStruSA1[nSA1][2] <> "C" .and.  FieldPos(aStruSA1[nSA1][1]) > 0
		TcSetField("TRBDESTIN",aStruSA1[nSA1][1],aStruSA1[nSA1][2],aStruSA1[nSA1][3],aStruSA1[nSA1][4])
	EndIf
Next  

TRBDESTIN->(DbGotop())

Return .T.
            

// Monta arquivo temporario com dados do produto.
*------------------------------*
Static Function SQLPRODUT()     
*------------------------------*

aStruSB1  := SB1->(dbStruct())

cQuery:=" SELECT B1.*"
cQuery+=" FROM "+RetSqlName("SB1")+" B1"
cQuery+=" WHERE B1.D_E_L_E_T_ <> '*' "  
cQuery+=" AND (B1.B1_COD like '001.%' OR B1.B1_COD like '002.%') "   //OR B1.B1_COD like 'MP%'
cQuery+=" AND B1.B1_P_STATS <> 'E' AND B1.B1_FILIAL ='"+cFil+"'" "
cQuery+=" ORDER BY (B1.B1_COD)"
                                                                
cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRBPRODUT',.F.,.T.)       

For nSB1 := 1 To Len(aStruSB1)
	If aStruSB1[nSB1][2] <> "C" .and.  FieldPos(aStruSB1[nSB1][1]) > 0
		TcSetField("TRBPRODUT",aStruSB1[nSB1][1],aStruSB1[nSB1][2],aStruSB1[nSB1][3],aStruSB1[nSB1][4])
	EndIf
Next  

TRBPRODUT->(DbGotop())

Return .T. 
            

// Monta arquivo temporario com dados da nota fiscal de entrada.
*------------------------------*
Static Function SQLNFENTR()     
*------------------------------*

aStruSD3  := SD3->(dbStruct())
    
cQuery:=" SELECT D3.*"
cQuery+=" FROM "+RetSqlName("SD3")+" D3 "
cQuery+=" WHERE  D3.D3_TM < '500'" 
cQuery+=" AND D3.D_E_L_E_T_ <> '*' AND D3.D3_CF='DE4'  "
cQuery+=" AND D3.D3_P_STATS <> 'E' AND D3.D3_FILIAL ='"+cFil+"'"
cQuery+=" AND (D3.D3_COD LIKE '001.%' OR D3.D3_COD like '002.%')"  //OR D3.D3_COD like 'MP%' 
cQuery+=" AND D3.D3_LOTECTL <> '' AND D3.D3_LOCAL='03' AND D3.D3_ESTORNO<>'S' "
cQuery+=" ORDER BY D3.D3_DOC,D3.D3_COD"                    

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),"TRB",.F.,.T.)       

For nSD3 := 1 To Len(aStruSD3)
	If aStruSD3[nSD3][2] <> "C" .and.  FieldPos(aStruSD3[nSD3][1]) > 0
		TcSetField("TRB",aStruSD3[nSD3][1],aStruSD3[nSD3][2],aStruSD3[nSD3][3],aStruSD3[nSD3][4])
	EndIf
Next      
                  
dbSelectArea("TRB")
Set Filter To 
If !Empty(cTemp)
   Ferase(cTemp) 
Else
   cTemp := "TRBNFENTR.dbf"
EndIf
Copy to &cTemp VIA "DBFCDXADS"
          
DBUSEAREA( .T.,"DBFCDX", "TRBNFENTR.DBF","TRBNFENTR", .T., .F. )
        
cIndex:=CriaTrab(,.F.)           
IndRegua("TRBNFENTR",cIndex+OrdBagExt(),"D3_FILIAL+D3_DOC+D3_COD")

DbSetIndex(cIndex+OrdBagExt())     

TRB->(DbCloseArea())
TRBNFENTR->(DbGotop()) 

Return .T.   


 // Monta arquivo temporario com dados da libera��o de quarentena
*------------------------------*
Static Function SQLLIBQUA()     
*------------------------------*         
  

Return .T.    


// Monta arquivo temporario com dados do pedido.
*------------------------------*
Static Function SQLPEDIDO()     
*------------------------------*         
                                   
aStruSC5  := SC5->(dbStruct())
    
cQuery:=" SELECT C5.*,C6.*"
cQuery+=" FROM "+RetSqlName("SC5")+" C5,"+RetSqlName("SC6")+" C6 "
cQuery+=" WHERE  C5.C5_NUM=C6.C6_NUM AND C5.C5_FILIAL ='"+cFil+"'"
cQuery+=" AND C5.D_E_L_E_T_ <> '*' AND C6.D_E_L_E_T_ <> '*' AND ( C6.C6_PRODUTO like '001.%' OR C6.C6_PRODUTO like '002.%' ) "   //OR C6.C6_PRODUTO like 'MP%'
cQuery+=" AND C5.C5_P_ENVIA='S' AND C5.C5_P_STATS <> 'E' AND C6.C6_FILIAL ='"+cFil+"'"
cQuery+=" ORDER BY C5.C5_FILIAL,C5.C5_NUM"                    


cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRBPEDIDO',.F.,.T.)       

For nSC5 := 1 To Len(aStruSC5)
	If aStruSC5[nSC5][2] <> "C" .and.  FieldPos(aStruSC5[nSC5][1]) > 0
		TcSetField("TRBPEDIDO",aStruSC5[nSC5][1],aStruSC5[nSC5][2],aStruSC5[nSC5][3],aStruSC5[nSC5][4])
	EndIf
Next  

TRBPEDIDO->(DbGotop()) 

Return .T.   
 
 // Monta arquivo temporario com dados da nota fiscal de sa�da.
*------------------------------*
Static Function SQLNFSAID()     
*------------------------------*

aStruSF2  := SF2->(dbStruct())
    
cQuery:=" SELECT F2.*,D2.*"
cQuery+=" FROM "+RetSqlName("SF2")+" F2,"+RetSqlName("SD2")+" D2 "
cQuery+=" WHERE  F2.F2_SERIE+F2.F2_DOC=D2.D2_SERIE+D2.D2_DOC " 
cQuery+=" AND F2.D_E_L_E_T_ <> '*' AND D2.D_E_L_E_T_ <> '*' AND D2.D2_COD like '001.%'"
cQuery+=" AND F2.F2_P_STATS <> 'E' AND D2.D2_FILIAL ='"+cFil+"' AND F2.F2_FILIAL ='"+cFil+"'"
cQuery+=" ORDER BY F2.F2_DOC,F2.F2_SERIE,F2.F2_CLIENTE"                    


cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRBNFSAID',.F.,.T.)       

For nSF2 := 1 To Len(aStruSF2)
	If aStruSF2[nSF2][2] <> "C" .and.  FieldPos(aStruSF2[nSF2][1]) > 0
		TcSetField("TRBNFSAID",aStruSF2[nSF2][1],aStruSF2[nSF2][2],aStruSF2[nSF2][3],aStruSF2[nSF2][4])
	EndIf                                            
Next  

TRBNFSAID->(DbGotop()) 

Return .T. 
                                              
// Conta quantos itens por nota fiscal de entrada
*---------------------------------------------------------*
 Static Function COUNTNFE(cChave1,cChave2)
*---------------------------------------------------------*

cQuery:=" SELECT Count(*) QTD "
cQuery+=" FROM "+RetSqlName("SD3")
cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
cQuery+=" AND D3_FILIAL = '"+cChave1+"' AND D3_DOC = '"+cChave2+"'
cQuery+=" AND D3_TM < '500' AND D3_ESTORNO <> 'S' AND D3_LOCAL='03' AND D3_CF='DE4' AND D3_ESTORNO <> 'S' AND D3_P_STATS <> 'E' "

cQuery	:=	ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTD",.T.,.T.)  

Return Nil
    
// Conta quantos itens tem por pedido
*--------------------------------------------*
  Static Function COUNTPED(cChave1,cChave2)
*--------------------------------------------*

cQuery:=" SELECT Count(*) QTD "
cQuery+=" FROM "+RetSqlName("SC6")
cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
cQuery+=" AND C6_FILIAL = '"+cChave1+"' AND C6_NUM = '"+cChave2+"'

cQuery	:=	ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTD",.T.,.T.)

Return Nil

// Conta quantos itens tem por nota fiscal de sa�da
*-------------------------------------------------------------*
   Static Function COUNTNFS(cChave1,cChave2,cChave3,cChave4)
*-------------------------------------------------------------*

cQuery:=" SELECT Count(*) QTD "
cQuery+=" FROM "+RetSqlName("SD2")
cQuery+=" WHERE  D_E_L_E_T_ <> '*' "
cQuery+=" AND D2_FILIAL = '"+cChave1+"' AND D2_DOC = '"+cChave2+"'
cQuery+=" AND D2_SERIE = '"+cChave3+"' AND D2_CLIENTE = '"+cChave4+"'

cQuery	:=	ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTD",.T.,.T.)  

Return Nil
       
// Fun��o para gravar no FTP
*------------------------------*
   Static Function GERAFTP()
*------------------------------*

Local cArqOri,cArqDest
Local cDirFTP:="/"    
Local lArqCheck:=.F.  
Local n:=1

Begin Sequence    

   For nAux:=1 to  10    // Tenta conectar no FTP 5 vezes.
                         
      lConect:=ConectaFTP()

      If lConect
         nAux:=10 
      Else
         If  !(MSGYESNO("N�o foi possivel conectar no FTP da Ativa, tentar novamente ? ","Aten��o"))
            Return .F. 
         EndIf   
      EndIf
   
    Next   

   If !(lConect) 
      MsgAlert("N�o foi possivel estabelecer conex�o.","Aten��o")   
      Return .F.
   EndIf   
          
   aRegLogCLIImprime:={}  // Limpa o array. 
     
   // Arquivo de destinat�rio grava��o FTP  
   If lDestin .And. lConect
           
      FTPDirChange(cDirFtp)  // Monta o diret�rio do FTP, ser� gravado na raiz "/"
      
      ZRD->(DbGoTop())
      ZRD->(DbSetOrder(2))
      IF ZRD->(DbSeek(xFilial()+"TXTDESTIN"+"Nao gerado FTP"))                                                                   
            
         // Grava no FTP arquivos que ainda n�o foram enviados da mesma rotina.
         While ZRD->(!EOF()) .And. ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == cFil+"TXTDESTIN"+"Nao gerado FTP"
                       
            cArqOri:=cDirDestin+ZRD->ZRD_ARQUIV
            cArqDest:=ZRD->ZRD_ARQUIV
                                         
            lArqCheck:=File(cArqOri)
         
            If lArqCheck
      
               // Grava Arquivo no FTP
               If !(FTPUpLoad(cArqOri,cArqDest))
         
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("N�o foi possivel gravar o arquivo " + cArqDest + " no FTP.","Aten��o")              
                  EndIf  
            
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogCLIImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "N�o gravado no FTP"})
           
               Else 
      
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("Arquivo " + ZRD->ZRD_ARQUIV + " gravado no FTP com sucesso.","Aten��o" ) 
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())    
                  Else
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())
                  Endif    
             
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogCLIImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "Gravado no FTP com sucesso."})
            
                  lExec:=.T.  // Seta a grava��o no FTP
      
               EndIf       
                            
            EndIf
         
            ZRD->(DbSkip()) 
         
         EndDo  
      
         If !(lExec) // Caso n�o tenha arquivo para ser gravado no FTP 
            Aadd(aRegLogCLIImprime,{"Sem arquivo para execu��o","0", "N�o gravado no FTP"}) 
         EndIf
      Else   
         If !(lAut) 
            Aadd(aRegLogCLIImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."})                                       
         EndIf
      EndIf   
   Else   
      If !(lAut) 
         If lConect
            Aadd(aRegLogCLIImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."}) 
         Else
            Aadd(aRegLogCLIImprime,{"-","-", "N�o foi possivel conectar no FTP"})                                       
         Endif
      EndIf
   EndIf 
                          
   lExec:=.F.  // Seta .F. novamente para execu��o do pr�ximo arquivo.
   
   aRegLogPRDImprime:={}  // Limpa o array. 
  
   // Arquivo de destinat�rio grava��o FTP  
   If lProdut .And. lConect
               
      FTPDirChange(cDirFtp)  // Monta o diret�rio do FTP, ser� gravado na raiz "/"
      
      ZRD->(DbGoTop())
      ZRD->(DbSetOrder(2))
      IF ZRD->(DbSeek(xFilial()+"TXTPRODUT"+"Nao gerado FTP"))
                          
         // Grava no FTP arquivos que ainda n�o foram enviados da mesma rotina.
         While ZRD->(!EOF()) .And. ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == cFil+"TXTPRODUT"+"Nao gerado FTP"
                       
            cArqOri:=cDirProdut+ZRD->ZRD_ARQUIV
            cArqDest:=ZRD->ZRD_ARQUIV
         
            lArqCheck:=File(cArqOri)  // Verifica se o arquivo existe.
         
            If lArqCheck
      
               // Grava Arquivo no FTP
               If !(FTPUpLoad(cArqOri,cArqDest))
         
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("N�o foi possivel gravar o arquivo " + cArqDest + " no FTP.","Aten��o")              
                  EndIf  
            
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogPRDImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "N�o gravado no FTP"})
           
               Else 
      
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("Arquivo " + ZRD->ZRD_ARQUIV + " gravado no FTP com sucesso.","Aten��o" ) 
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())    
                  Else
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())
                  Endif    
             
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogPRDImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "Gravado no FTP com sucesso."})
            
                  lExec:=.T.  // Seta a execu��o da grava��o no FTP
      
               EndIf       
         
            EndIf
         
            ZRD->(DbSkip())
         
         EndDo  
      
         If !(lExec) // Caso n�o tenha arquivo para ser gravado no FTP
            Aadd(aRegLogPRDImprime,{"Sem arquivo para execu��o","0", "N�o gravado no FTP"}) 
         EndIf
      Else   
         If !(lAut) 
            Aadd(aRegLogPRDImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."})                                       
         EndIf
      EndIf     
   Else   
      If !(lAut) 
         If lConect
            Aadd(aRegLogPRDImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."}) 
         Else
            Aadd(aRegLogPRDImprime,{"-","-", "N�o foi possivel conectar no FTP"})                                       
         Endif
      EndIf
   EndIf 

          
   lExec:=.F.  // Seta .F. novamente para execu��o do pr�ximo arquivo.
   
   aRegLogNFEImprime:={}  // Limpa o array.     
   // Arquivo de destinat�rio grava��o FTP  
   If lNfEntr .And. lConect
               
      FTPDirChange(cDirFtp)  // Monta o diret�rio do FTP, ser� gravado na raiz "/"
      
      ZRD->(DbGoTop())
      ZRD->(DbSetOrder(2))
      If ZRD->(DbSeek(xFilial()+"TXTNFENTR"+"Nao gerado FTP"))
                                                            
         n:=0 
            
         // Grava no FTP arquivos que ainda n�o foram enviados da mesma rotina.
         While ZRD->(!EOF()) .And. ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == cFil+"TXTNFENTR"+"Nao gerado FTP"
                       
            cArqOri:=cDirNfEntr+ZRD->ZRD_ARQUIV
            cArqDest:=ZRD->ZRD_ARQUIV 
         
            lArqCheck:=File(cArqOri)  // Verifica se o arquivo existe.
         
            If lArqCheck
        
               // Grava Arquivo no FTP
               If !(FTPUpLoad(cArqOri,cArqDest))
         
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("N�o foi possivel gravar o arquivo " + cArqDest + " no FTP.","Aten��o")              
                  EndIf  
            
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogNFEImprime,{" Arquivo : "+ cArqDest, n , "N�o gravado no FTP"})
           
               Else 
      
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("Arquivo " + ZRD->ZRD_ARQUIV + " gravado no FTP com sucesso.","Aten��o" ) 
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())    
                 Else
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())
                 Endif    
                     
             
                 If !(lExec) // Gravar Log do primeiro arquivo 
                    Aadd(aRegLogNFEImprime,{" Arquivo de : "+ cArqDest, n ,"Gravado no FTP com sucesso."})      
                 EndIf
      
                 lExec:=.T.  // Seta a execu��o da grava��o no FTP 
              
               EndIf 
               
               n++ 
     
            EndIf       
                            
         
            ZRD->(DbSkip())                        
         
         EndDo  
         
        aRegLogNFEImprime[1][1]+=" At� : "+cArqDest  // Grava o �ltimo gerado para imprimir na tela de log.
        aRegLogNFEImprime[1][2]:= n   
        
      Else   
         If !(lAut) 
            Aadd(aRegLogNFEImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."})                                       
         EndIf
      EndIf                       
   Else   
      If !(lAut) 
         If lConect
            Aadd(aRegLogNFEImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."}) 
         Else
            Aadd(aRegLogNFEImprime,{"-","-", "N�o foi possivel conectar no FTP"})                                       
         Endif
      EndIf
   EndIf 
 
   lExec:=.F.  // Seta .F. novamente para execu��o do pr�ximo arquivo.
   
   aRegLogPEDImprime:={}  // Limpa o array. 
     
   // Arquivo de destinat�rio grava��o FTP  
   If lPedido .And. lConect
               
      FTPDirChange(cDirFtp)  // Monta o diret�rio do FTP, ser� gravado na raiz "/" 
      
      n:=0
      
      ZRD->(DbGoTop())
      ZRD->(DbSetOrder(2))
      IF ZRD->(DbSeek(xFilial()+"TXTPEDIDO"+"Nao gerado FTP"))
                                                                              
         // Grava no FTP arquivos que ainda n�o foram enviados da mesma rotina.
         While ZRD->(!EOF()) .And. ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == cFil+"TXTPEDIDO"+"Nao gerado FTP"
                       
            cArqOri:=cDirPedido+ZRD->ZRD_ARQUIV
            cArqDest:=ZRD->ZRD_ARQUIV  
         
            lArqCheck:=File(cArqOri)  // Verifica se o arquivo existe.
         
            If lArqCheck
      
               // Grava Arquivo no FTP
               If !(FTPUpLoad(cArqOri,cArqDest))
         
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("N�o foi possivel gravar o arquivo " + cArqDest + " no FTP.","Aten��o")              
                  EndIf  
            
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogPEDImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "N�o gravado no FTP"})
           
               Else 
      
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("Arquivo " + ZRD->ZRD_ARQUIV + " gravado no FTP com sucesso.","Aten��o" ) 
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock()) 
                     n++   
                  Else
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock()) 
                     n++
                  Endif    
             
               EndIf
               
               If !(lExec) // Gravar Log do primeiro arquivo 
                    Aadd(aRegLogPEDImprime,{" Arquivo de : "+ cArqDest, n ,"Gravado no FTP com sucesso."})      
               EndIf
            
               lExec:=.T.  // Seta a execu��o da grava��o no FTP
      
            EndIf
               
            ZRD->(DbSkip())
         
         EndDo  
                    
         If !(lExec) // Caso n�o tenha arquivo para ser gravado no FTP
            Aadd(aRegLogPEDImprime,{"Sem arquivo para execu��o","0", "N�o gravado no FTP"}) 
         Else
            aRegLogPEDImprime[1][1]+=" At� : "+cArqDest  // Grava o �ltimo gerado para imprimir na tela de log.
            aRegLogPEDImprime[1][2]:= n
         EndIf
      Else   
         If !(lAut) 
            Aadd(aRegLogPEDImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."})                                       
         EndIf
      EndIf         
   Else   
      If !(lAut) 
         If lConect
            Aadd(aRegLogPEDImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."}) 
         Else
            Aadd(aRegLogPEDImprime,{"-","-", "N�o foi possivel conectar no FTP"})                                       
         Endif
      EndIf
   EndIf    
     
    
   lExec:=.F.  // Seta .F. novamente para execu��o do pr�ximo arquivo.
   
   aRegLogNFSImprime:={}  // Limpa o array. 
  
   // Arquivo de destinat�rio grava��o FTP  
   If lNfSaid .And. lConect 
   
      n:=1
               
      FTPDirChange(cDirFtp)  // Monta o diret�rio do FTP, ser� gravado na raiz "/"
      
      ZRD->(DbGoTop())
      ZRD->(DbSetOrder(2))
      If ZRD->(DbSeek(xFilial()+"TXTNFSAID"+"Nao gerado FTP"))
                                                                     
            
         // Grava no FTP arquivos que ainda n�o foram enviados da mesma rotina.
         While ZRD->(!EOF()) .And. ZRD->ZRD_FILIAL+ZRD->ZRD_ROTINA+ZRD->ZRD_GERFTP == cFil+"TXTNFSAID"+"Nao gerado FTP"
                       
            cArqOri:=cDirNfSaid+ZRD->ZRD_ARQUIV
            cArqDest:=ZRD->ZRD_ARQUIV
         
            lArqCheck:=File(cArqOri)  // Verifica se o arquivo existe.
         
            If lArqCheck
      
               // Grava Arquivo no FTP
               If !(FTPUpLoad(cArqOri,cArqDest))
         
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("N�o foi possivel gravar o arquivo " + cArqDest + " no FTP.","Aten��o")              
                  EndIf  
             
                  // Gravar Log para tela de impress�o.
                  Aadd(aRegLogNFSImprime,{" Arquivo : "+ cArqDest, ZRD->ZRD_QTDREG , "N�o gravado no FTP"})
           
               Else 
      
                  If !(lAut) // Verifica se est� automatico
                     MsgStop("Arquivo " + ZRD->ZRD_ARQUIV + " gravado no FTP com sucesso.","Aten��o" ) 
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())    
                  Else
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_GERFTP := "Gravado FTP"
                     ZRD->( MsUnlock())
                  Endif    
             
                  If !(lExec) // Gravar Log do primeiro arquivo
                     aRegLogNFSImprime[1][1]:=" Arquivo de : "+ cArqDest
                     aRegLogNFSImprime[1][2]:= n
                     aRegLogNFSImprime[1][3]:="Gravado no FTP com sucesso."
                  EndIf
            
                  lExec:=.T.  // Seta a execu��o da grava��o no FTP
      
               EndIf       
         
            EndIf
                   
            n++
         
            ZRD->(DbSkip())
         
         EndDo  
                    
         If !(lExec) // Caso n�o tenha arquivo para ser gravado no FTP
            Aadd(aRegLogNFSImprime,{"Sem arquivo para execu��o","0", "N�o gravado no FTP"}) 
         Else
            aRegLogNFSImprime[1][1]+=" At� : "+cArqDest  // Grava o �ltimo gerado para imprimir na tela de log.
            aRegLogNFSImprime[1][2]:= n
         EndIf
      Else   
         If !(lAut) 
            Aadd(aRegLogNFSImprime,{"-","-", "Conectado : Sem arquivos para ser gerado."})                                       
         EndIf
      EndIf           
   Else  
      If !(lAut) 
         If lConect
            Aadd(aRegLogNFSImprime,{"-","-", "Rotina n�o disponivel para envio do DANFE."}) 
         Else
            Aadd(aRegLogNFSImprime,{"-","-", "N�o foi possivel conectar no FTP"})                                       
         Endif
      EndIf
   EndIf 
    
   If lConect
      FTPDISCONNECT()
   Endif

End Sequence

Return .T.               


// Fun��o para buscar retorno do FTP 
*------------------------------*
  Static Function BUSCAFTP()
*------------------------------*

Local cArqOri,cArqDest,nHandle,cFil,cPedido,cTitulo,nPeditens
Local cDirFTP:="/" 
Local cResult:=""    
Local i,nAux,nTam,nLin,cTexto,aLinha,cLote,cItem    
Local lConect:=lEx:=.F.
Local aLinha:={} 

SC6->(DbSetOrder(1))

Begin Sequence    

   For i:=1 to  5    // Tenta conectar no FTP 5 vezes.
                                     
      lConect:=ConectaFTP()

      If lConect
         i:=5
      Else
         If  !(MSGYESNO("N�o foi possivel conectar no FTP da Ativa, tentar novamente ? ","Aten��o"))
            Return .F. 
         EndIf
      EndIf
   
    Next   

If !(lConect) 
   MsgAlert("N�o foi possivel estabelecer conex�o.","Aten��o")   
   Return .F.
EndIf  

If lPEDIDO     
  
 ZRD->(DbGoTop())
 ZRD->(DbSetOrder(2))
 If ZRD->(DbSeek(xFilial("ZRD")+"TXTPEDIDO"+"Gravado FTP   "+" "))  
      
   While ZRD->(!EOF()) .AND. ZRD->ZRD_ROTINA=="TXTPEDIDO" .AND. ZRD->ZRD_GERFTP=="Gravado FTP   " 
      
      IF ZRD->ZRD_RETOK<>"S" .AND. ZRD->ZRD_RETOK<>"N"  
                
         lEx:=.T.
         
         cFil    :=ZRD->ZRD_FILIAL 
         //cPedido :=Alltrim(substr(ZRD->ZRD_OBS,10,6))
         cPedido := ZRD->ZRD_PEDIDO    
         cArqOri :="P"+Alltrim(Substr(ZRD->ZRD_COD,2,11))+".PED"
         cArqDest:= cDir+"RETORNO\"+cArqOri
      
         If FTPDirChange(cDirFTP)
                      
            Ferase(cArqDest)
         
            If FTPDOWNLOAD(cArqDest,cArqOri) 
         
               If  !(MSGYESNO("Deseja atualizar o(s) lote(s) dos iten(s) do pedido: "+Alltrim(cPedido),"Aten��o"))
                  ZRD->(DbSkip())
                  loop
               EndIf  
            
               nHandle := fOpen(cArqDest)
               cTexto  := FREADSTR(nHandle,1000000)
               nTam    := Len(Alltrim(cTexto))
               nLin    := Int(nTam/302)                                                                                      
               
               nAux:=1
               aLinha:={}  // Necessario limpar o array para cada arquivo integrado.
            
               //Carrega o conte�do do retorno em um array
               For i:=1 to nLin   
                            //Linha , Conte�do.                         
                  Aadd(aLinha,{i,Substr(ctexto,nAux,302)})  
                  nAux := nAux + 302
            
               Next
               
               //CONTAR NUMERO DE LINHA DO PEDIDO E COMPARAR COM O RETORNO.
               
               COUNTPED(xFilial("SC5"),cPedido)     
               nPeditens:=QTD->QTD 
	           QTD->(dbCloseArea()) 
	           
	           cResult:="" 

               If Alltrim(Substr(aLinha[2][2],1,4)) == "ERRP"
                  
                  cResult:="Ocorreu um erro na integra��o da Ativa verifique o arquivo de retorno :"+Alltrim(cArqOri)
                  MSGALERT(cResult,"Aten��o")
                  
                  Aadd(aDetLOTE,{"Pedido : "+Alltrim(cPedido) ,"Ocorreu erro na integra��o da Ativa arquivo de retorno: " +Alltrim(cArqOri),;
                  "Mensagem :"+Alltrim(Substr(aLinha[2][2],10,100)) })      
                  
                  RecLock("ZRD",.F.)
                  ZRD->ZRD_RETPED := (Substr(cArqOri,1,8))   
                  ZRD->ZRD_RETOK  := "N"  
                  ZRD->ZRD_OBS  := "Problema com o retorno, verificar a mensagem da Ativa no arquivo "+Alltrim(cArqOri) 
                  ZRD->(MsUnlock())

                  aRegLogLOTE[1]+=("Verificar detalhes "+cPedido+" |   " )  

                  ZRD->(DbSkip())
                  loop  
                  
               Else
                        
                        
                  If Alltrim(Substr(aLinha[2][2],1,6)) == "CNFPDC"
                     //ATUALIZA O SC5
                     SC5->(DbSetOrder(1))
                     If SC5->(DbSeek(xFilial("ZRD")+ZRD->ZRD_PEDIDO))
                        RecLock("SC5",.F.)   
                        SC5->C5_VOLUME1:= Val(Substr(aLinha[2][2],36,3))
                        SC5->C5_PESOL  := Val(Substr(aLinha[2][2],39,5)+"."+Substr(aLinha[2][2],44,3))
                        SC5->C5_PBRUTO := Val(Substr(aLinha[2][2],39,5)+"."+Substr(aLinha[2][2],44,3))
                        SC5->(MsUnlock())    
                        
                        MSGINFO("Volume e Peso atualizado","Aten��o")  
                        
                        RecLock("ZRD",.F.)
                        ZRD->ZRD_VOLUME:= Val(Substr(aLinha[2][2],36,3))   
                        ZRD->ZRD_PESOL := Val(Substr(aLinha[2][2],39,5)+"."+Substr(aLinha[2][2],44,3))
                        ZRD->ZRD_PESOB := Val(Substr(aLinha[2][2],39,5)+"."+Substr(aLinha[2][2],44,3))
                        ZRD->(MsUnlock())
                  
                     EndIf       
                  EndIf 
                     
                   
                  If (nLin-3) <> nPeditens                                              
                  
                     cResult:="Numero de linhas do arquivo de retorno (Ativa) :"+alltrim(cArqOri)+CHR(13)+CHR(10)
                     cResult+="Diferente do numero da linha de itens do pedido (Microsiga):"+Alltrim(cPedido)
                     MSGALERT(cResult,"Aten��o")
                  
                     Aadd(aDetLOTE,{"O pedido: "+cPedido+" n�o foi atualizado.","Retorno possui "+Alltrim(Str(nLin-3))+" linhas de itens ( Numero de Itens - Retorno Ativa)"," Pedido possui ";
                     +Alltrim(Str(nPeditens))+" linhas de itens ( Numero de Itens - Pedido Microsiga)" })      
                  
                     RecLock("ZRD",.F.)
                     ZRD->ZRD_RETPED := (Substr(cArqOri,1,8))   
                     ZRD->ZRD_RETOK  := "N"  
                     ZRD->ZRD_OBS  := "Problema com numero de linhas pedido(Microsiga) x retorno(Ativa).  "
                     ZRD->(MsUnlock())

                     aRegLogLOTE[1]+=("Verificar detalhes "+cPedido+" |   " )  
                  
                     ZRD->(DbSkip())
                     loop                                           
                  
                  EndIf
                      
               EndIf
                       
               cResult:="" 
               nAux:=1
               //Atualiza o lote no SC6
               For i:=3 to (nLin-1)
                  // A numer��o do C6_ITEM deve ser sequencial comen�ando no 01, caso um dos itens seja DELETADO o retorno n�o ir� localizar o item.
                  cItem:="0"+Alltrim(Str(nAux))
                  If SC6->(DbSeek(cFil+cPedido+cItem+Alltrim(Substr(aLinha[i][2],27,20))))
                     If Alltrim(SC6->C6_PRODUTO) == Alltrim(Substr(aLinha[i][2],27,20))
                        RecLock("SC6",.F.)
                        SC6->C6_LOTECTL := Alltrim(Substr(aLinha[i][2],59,20))   
                        dData :=   Alltrim(Substr(aLinha[i][2],79,10))
                        dData :=   STOD(ClearVal(dData))
                        SC6->C6_DTVALID := dData
                        SC6->(MsUnlock())
                        cResult+="PRODUTO: "+Alltrim(SC6->C6_PRODUTO) + " |  QTD: " + Alltrim(STR(SC6->C6_QTDVEN)) + " |  LOTE: "+Alltrim(SC6->C6_LOTECTL)+CHR(13)+CHR(10)                                
                        lAtu:=.T.   
                        Aadd(aDetLOTE,{"Atualizado Pedido: "+cPedido, "PRODUTO: "+Alltrim(SC6->C6_PRODUTO) + " |  Quantidade: "+ Alltrim(STR(SC6->C6_QTDVEN)) ,;
                        "LOTE: "+Alltrim(SC6->C6_LOTECTL) + " |  Data Validade: "+alltrim(DTOC(dData)) })             
                     EndIf
                  EndIf 
                  nAux++                               
               Next  
                    
               fClose(cArqDest)
               
               If lAtu
                  RecLock("ZRD",.F.)
                  ZRD->ZRD_RETPED := (Substr(cArqOri,1,8))   
                  ZRD->ZRD_RETOK  := "S"  
                  ZRD->(MsUnlock())
                  
                  cTitulo:= "PEDIDO "+cPedido
                  MSGINFO(cResult,cTitulo)

                  aRegLogLOTE[1]+=("Atualizado Lote do Pedido: "+cPedido+" |   " )  
                     
               Else
                  MSGALERT("Lote n�o foi atualizado","Aten��o")
               EndIf   
            Else
               APMsgInfo("Problemas ao copiar ou com o nome arquivo :"+Alltrim(cArqOri),"Aten��o") 
               fClose(cArqDest)
            EndIf
         EndIF   
      EndIf
   ZRD->(DbSkip())
   EndDo    
   
   If !(lEx)
      APMsgInfo("N�o foi encontrado nenhum pedido para ser atualizado.","Aten��o")
   EndIf
 Else
    APMsgInfo("N�o foi encontrado nenhum pedido para ser atualizado.","Aten��o")
 EndIf   

Else
   APMsgInfo("Rotina de pedido n�o foi marcada.","Aten��o")
EndIf
 

If lConect
   FTPDISCONNECT()
Endif
           
End Sequence  

Return  


// Fun��o para conectar no FTP      
*--------------------------------*
   Static Function ConectaFTP()
*--------------------------------*

Local cPath := GETMV("MV_RED_FTP") // "200.196.242.81"
Local clogin:= GETMV("MV_RED_USE") // "drreddys"
Local cPass := GETMV("MV_RED_PSW") // "drr3dd4s" 
Local lRet:=.F.

cPath:=Alltrim(cPath)
cLogin:=Alltrim(cLogin)
cPass:=Alltrim(cPass) 

// Conecta no FTP
lRet:=FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)         


// Fun��o para mostras detalhes da integra��o   
*--------------------------------------*
   Static Function Detalhes(cArquivo)
*------------------------------------*  

Local cTExt:=""
Default cArquivo :=""

Do Case
   Case cArquivo == "TXTDESTIN"  
      For n:=1 to Len(aDetCLI[1])
         cTExt+=Alltrim(aDetCLI[1][n]+CHR(13)+CHR(10))
      Next 
      EECVIEW(cTExt,"Detalhes da gera��o do arquivo de clientes")   
      
      cTExt:=""
   
   Case cArquivo == "TXTPRODUT"  
      For n:=1 to Len(aDetPRD[1])
         cTExt+=Alltrim(aDetPRD[1][n]+CHR(13)+CHR(10))
      Next 
      EECVIEW(cTExt,"Detalhes da gera��o do arquivo de produtos")
      
      cTExt:=""
      
   Case cArquivo == "TXTNFENTR"  
      For n:=1 to Len(aDetNFE) 
         For i:=1 to Len(aDetNFE[n])
            cTExt+=Alltrim(aDetNFE[n][i]+CHR(13)+CHR(10))
         Next 
         cTExt+=CHR(13)+CHR(10)  
      Next 
      EECVIEW(cTExt,"Detalhes da gera��o do arquivo de notas fiscais de entrada")   
      
      cTExt:=""          
      
   Case cArquivo == "TXTPEDIDO"  
      For n:=1 to Len(aDetPED[1])
         cTExt+=Alltrim(aDetPED[1][n]+CHR(13)+CHR(10))
      Next 
      EECVIEW(cTExt,"Detalhes da gera��o do arquivo de pedidos")   
      
      cTExt:="" 
      
   Case cArquivo == "TXTNFSAID"  
      For n:=1 to Len(aDetNFS[1])
         cTExt+=Alltrim(aDetNFS[1][n]+CHR(13)+CHR(10))
      Next 
      EECVIEW(cTExt,"Detalhes da gera��o do arquivo de notas fiscais de sa�da")   
      
      cTExt:=""   
      
   Case cArquivo == "LOTES"  
      If !Empty(aDetLote)
         For n:=1 to Len(aDetLote)  
            cTExt+=CHR(13)+CHR(10)
            For i:=1 to Len(aDetLote[1]) 
               cTExt+=Alltrim(aDetLote[n][i]+CHR(13)+CHR(10)) 
            Next   
         Next 
         EECVIEW(cTExt,"Detalhes da atualiaza��o de lote.")   
      Else  
         cTExt:="N�o houve atualiza��o de lotes." 
         EECVIEW(cTExt,"Detalhes da atualiaza��o de lote.") 
      Endif 
      
      cTExt:=""        
      
EndCase   
      
Return 
 
// AxCadastro da tabela ZRD - Log das grava��es do FTP
*-----------------------------*
    User Function REDLOG()
*-----------------------------*      
                                    

If !(cEmpAnt $ "U2" .Or. cEmpAnt $ "99")  
   MsgStop("Rotina especifica Dr Reddys","Aten��o") 
   Return .F.
EndIf      

   AxCadastro("ZRD","Log de processamento da Ativa",".T.",".T.")

Return .T.             
   
// Fun��o para limpar as variaveis.
*----------------------------------*
  Static Function ClearVal(cCampo)
*----------------------------------*      

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
             
             
             
             
                   
