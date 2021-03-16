#include "rwmake.ch"
#include "colors.ch"
#include "topconn.ch" 
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTTESPESQ  ºAutor  Tiago Luiz Mendonça  º Data ³  18/11/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa de TES                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*
Funcao      : GTTESPESQ
Objetivos   : Pesquisa de TES.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 18/11/10
*/
           
// Função Principal.
*---------------------------*
   User Function GTTESPESQ()  
*---------------------------* 
                        
//Geral
Local aTipo      :=  &(ComboSX3("F4_TIPO"))  //ComboSX3("F4_TIPO") //{"","Entrada","Saida"}
Local aAtivo     :=  &(ComboSX3("F4_ATUATF")) //{"","Sim","Nao"}
Local aDuplicata :=  &(ComboSX3("F4_DUPLIC")) //{"","Sim","Nao"} 
Local aPoderTerc :=  &(ComboSX3("F4_PODER3")) //{"","Remessa","Devolucao","Nao Controla"} 
Local aEstoque   :=  &(ComboSX3("F4_ESTOQUE")) //{"","Sim","Nao"}  
   
//ICMS 
Local aCalcICMS    := &(ComboSX3("F4_ICM")) // {"","Sim","Nao"}
Local aCredICMS    := &(ComboSX3("F4_CREDICM")) // {"","Sim","Nao"}
Local cRedICMS     := Space(5)
Local aCalcDifICMS := &(ComboSX3("F4_COMPL")) //{"","Sim","Nao"}  
Local aLFiscICMS   := &(ComboSX3("F4_LFICM")) //{"","Tributado","Isento","Outros","Nao","ICMS Zerado","Observação"}
Local aMkpICMSComp := &(ComboSX3("F4_MKPCMP")) //{"","Sim","Nao"}   

//IPI
Local aCalcIPI     := &(ComboSX3("F4_IPI")) //{"","Sim","Nao","Com.Nao Atac"}
Local aIPInaBase   := &(ComboSX3("F4_INCIDE")) //{"","Sim","Nao","Consumidor final"} 
Local aDestacaIPI  := &(ComboSX3("F4_DESTACA")) //{"","Sim","Nao"}
Local aCredIPI     := &(ComboSX3("F4_CREDIPI")) //{"","Sim","Nao"}
Local aLFiscIPI    := &(ComboSX3("F4_LFIPI")) //{"","Tributado","Isento","Outros","Nao","IPI Zerado","Vl.IPI Outr.ICM"}
Local aGeraIPIObs  := &(ComboSX3("F4_IPIOBS")) //{"","Sim","Nao"} 

//PIS/COFINS
Local aPisCof      := &(ComboSX3("F4_PISCOF")) //{"","PIS","COFINS","Ambos","Nao Considera"} 
Local aCredPisCof  := &(ComboSX3("F4_PISCRED")) //{"","Credita","Debita","Nao Calcula","Calcula"} 
Local aAgregPis    := &(ComboSX3("F4_AGRPIS")) //{"","Sim","Nao","Pis+Merc"} 
Local aAgregCof    := &(ComboSX3("F4_AGRCOF")) //{"","Sim","Nao","Pis+Merc"}  
Local aAgregCof    := &(ComboSX3("F4_AGRCOF")) //{"","Sim","Nao","Pis+Merc"} 
Local aRecDACON    := &(ComboSX3("F4_RECDAC"))

//Outros
Local aAgregValor  := &(ComboSX3("F4_AGREG")) //{"","ICMS","Sim","Nao","ICMS+Merc-EIC","ICMS-EIC","Ded ICMS Vl Ct","Ded ICMS Dup","Ded Vl Mer Dup","Vl Dup ICMS","ICMS ST","ICMS+Mer"}
Local aTpReg       := &(ComboSX3("F4_TPREG")) //{"","Nao Cumalativo","Cumulativos","Ambos"}    
Local aCalcISS     := &(ComboSX3("F4_ISS")) //{"","Sim","Nao"}  
Local aLFiscISS    := &(ComboSX3("F4_LFISS")) //{"","Tributado","Isento","Outros","Nao Calcula"}    
Local aRetISS      := &(ComboSX3("F4_RETISS")) //{"","Sim","Nao"}  
Local aLFiscCIAP   := &(ComboSX3("F4_CIAP")) //{"","Tributado","Isento","Outros","Nao Calcula"}

Private cCFOP      :=  Space(4)

Private Odlg, oMain, aRotina   
Private cTipo,cAtivo,cDuplicata,cPoderTerc,cEstoque 
Private cCalcICMS,cRedICMS,cCredICMS,cCalcDifICMS,cLFiscICMS,cMkpICMSComp  
Private cCalcIPI,cIPInaBase,cDestacaIPI,cCredIPI,cLFiscIPI,cGeraIPIObs 
Private cPisCof,cCredPisCof,cAgregPis,cAgregCof,cRecDACON  
Private cAgregValor,cTpReg,cCalcISS,cLFiscISS,cRetISS,cLFiscCIAP 


                                              
   DEFINE MSDIALOG oDlg TITLE  "Pesquisa de TES"  From 1,10 To 24,141 OF oMain
   
   nLin1:=010 
   nLin2:=116
   nCol1:=010
   nCol2:=130

   @ nLin1    ,nCol1     TO nLin2,   nCol2     LABEL " Geral"      OF oDlg PIXEL
   @ nLin1    ,nCol1+125 TO nLin2   ,nCol2+125 LABEL " ICMS"       OF oDlg PIXEL   
   @ nLin1    ,nCol1+250 TO nLin2   ,nCol2+250 LABEL " IPI"        OF oDlg PIXEL
   @ nLin1    ,nCol1+375 TO nLin2   ,nCol2+375 LABEL " PIS/COFINS" OF oDlg PIXEL
   @ nLin1+110,nCol1     TO nLin2+50,nCol1+370 LABEL " Outros" OF oDlg PIXEL  // Caixa inferior   
   @ nLin1+114,nCol1+375 TO nLin2+50,nCol2+376 LABEL "" OF oDlg PIXEL         // Caixa do botao
 
   nLin:=024  
   nCol:=018
         
   @ nLin     ,nCol Say "Tipo" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,10 OF oDlg  
   @ nLin+=015,nCol Say "CFOP " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Atualiza Ativo ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Gera Duplicata ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,10 OF oDlg
   @ nLin+=015,nCol Say "Poder Terceiros ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Atualiza Estoque ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,10 OF oDlg
   
   nLin:=024
   nCol:=065

   @ nLin     ,nCol COMBOBOX cTipo ITEMS  aTipo PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Get cCFOP PICTURE "9999" PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cAtivo ITEMS aAtivo PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cDuplicata ITEMS aDuplicata PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cPoderTerc ITEMS aPoderTerc PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cEstoque ITEMS aEstoque PIXEL SIZE 60,6 OF oDlg PIXEL SIZE 60,6 OF oDlg
   
   nLin:=024  
   nCol:=141
         
   @ nLin     ,nCol Say "Calcula ICMS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,6 OF oDlg  
   @ nLin+=015,nCol Say "Credita ICMS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Redução ICMS" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Calc. Dif ICMS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Livro. Fisc. ICMS " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Mkp ICMS Comp. ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
   
   nLin:=024
   nCol:=187

   @ nLin     ,nCol COMBOBOX cCalcICMS ITEMS  aCalcICMS PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cCredICMS  ITEMS aCredICMS  PIXEL SIZE 60,6 OF oDlg  
   @ nLin+=015,nCol Get cRedICMS  PICTURE "99.99" PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cCalcDifICMS ITEMS aCalcDifICMS PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cLFiscICMS ITEMS aLFiscICMS PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cMkpICMSComp ITEMS aMkpICMSComp PIXEL SIZE 60,6 OF oDlg PIXEL SIZE 60,6 OF oDlg  
   
   nLin:=024  
   nCol:=270
         
   @ nLin     ,nCol Say "Calcula IPI ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,6 OF oDlg  
   @ nLin+=015,nCol Say "IPI na Base ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Destaca IPI ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Credita IPI ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Livro. Fisc. IPI " COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Gera IPI Obs." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg  
   
   nLin:=024
   nCol:=310

   @ nLin     ,nCol COMBOBOX cCalcIPI ITEMS  aCalcIPI PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cIPInaBase ITEMS aIPInaBase  PIXEL SIZE 60,6 OF oDlg  
   @ nLin+=015,nCol COMBOBOX cDestacaIPI ITEMS aDestacaIPI  PIXEL SIZE 60,6 OF oDlg  
   @ nLin+=015,nCol COMBOBOX cCredIPI ITEMS aCredIPI PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cLFiscIPI ITEMS aLFiscIPI PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cGeraIPIObs ITEMS aGeraIPIObs PIXEL SIZE 60,6 OF oDlg PIXEL SIZE 60,6 OF oDlg  
   

   nLin:=024  
   nCol:=392
         
   @ nLin     ,nCol Say "PIS/COFINS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,6 OF oDlg  
   @ nLin+=015,nCol Say "Cred. PIS/COF ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol Say "Agrega COFINS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,10 OF oDlg
   @ nLin+=015,nCol Say "Agrega PIS  ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,10 OF oDlg
   @ nLin+=015,nCol Say "Rec. DACON ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg

   
   nLin:=024
   nCol:=442

   @ nLin     ,nCol COMBOBOX cPisCof ITEMS aPisCof PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cCredPisCof ITEMS aCredPisCof  PIXEL SIZE 60,6 OF oDlg  
   @ nLin+=015,nCol COMBOBOX cAgregCof ITEMS aAgregCof PIXEL SIZE 60,6 OF oDlg 
   @ nLin+=015,nCol COMBOBOX cAgregPis ITEMS aAgregPis  PIXEL SIZE 60,6 OF oDlg  
   @ nLin+=015,nCol COMBOBOX cRecDACON ITEMS aRecDACON PIXEL SIZE 60,6 OF oDlg 

   nLin:=134  
   nCol:=018
         
   @ nLin     ,nCol Say "Agrega Valor ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,10 OF oDlg  
   @ nLin+=015,nCol Say "Tp Reg?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,10 OF oDlg   
   
   nLin:=134
   nCol:=065

   @ nLin     ,nCol COMBOBOX cAgregValor ITEMS aAgregValor PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cTpReg ITEMS aTpReg  PIXEL SIZE 60,6 OF oDlg  

   nLin:=134 
   nCol:=141
         
   @ nLin     ,nCol Say "Calcula ISS ?" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,6 OF oDlg  
   @ nLin+=015,nCol Say "Livro. Fisc. ISS" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg
  
   nLin:=134
   nCol:=187

   @ nLin     ,nCol COMBOBOX cCalcISS   ITEMS  aCalcISS PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cLFiscISS  ITEMS aLFiscISS  PIXEL SIZE 60,6 OF oDlg  

   nLin:=134  
   nCol:=265
         
   @ nLin     ,nCol Say "Ret. ISS" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 40,6 OF oDlg  
   @ nLin+=015,nCol Say "Livro. Fisc. CIAP" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 60,6 OF oDlg

   nLin:=134
   nCol:=310
   
   @ nLin     ,nCol COMBOBOX cRetIss ITEMS  aRetIss PIXEL SIZE 60,6 OF oDlg
   @ nLin+=015,nCol COMBOBOX cLFiscCIAP ITEMS aLFiscCIAP  PIXEL SIZE 60,6 OF oDlg  
   
   @ 140,400 BUTTON "Cancela"   size 40,12 ACTION Processa({|| oDlg:End()}) of oDlg Pixel  
   @ 140,450 BUTTON "Localizar" size 40,12 ACTION Processa({|| Localiza()}) of oDlg Pixel

   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())  
      
   


Return 
                
*----------------------------------*
  Static Function Localiza()
*----------------------------------* 
     
Private oGetDB

aRotina := {{ "Pesquisa"             ,"AxPesqui"   , 0 , 1},;
            { "Visualizar"           ,"U_SViewXC"  , 0 , 2} }  
      

If Alltrim(cTipo)==""
   MsgStop("O tipo de entrada deve ser preenchido","HLB BRASIL")     
   Return .F.
EndIf 


If Select("Work")>0
   Work->(DbCloseArea())
EndIf  

If Select("QRB")>0
   QRB->(DbCloseArea())
EndIf  

MontaSF4()
MontaQry()
 
Return
                
*----------------------------*
  Static Function MontaQry()
*----------------------------* 

Local nUsado:=nAux:=0  
Local aStruct,oDlg1 
Local cSF4:=Space(1) 
Local i:=0

Private aHeader,aCols
          
aHeader      :={}
aStruct      :={}   
    

SX3->(DbSetOrder(1))
SX3->(DbSeek("SF4"))

nRec:=n:=1        
     
   While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO=="SF4")

      If X3USO(SX3->X3_USADO) //.And.cNivel>=X3_NIVEL
         
         nUsado++
                           
         If Alltrim(SX3->X3_CAMPO)=="F4_CODIGO"
            Aadd(aHeader,{ "TES",SX3->X3_CAMPO ,SX3->X3_PICTURE,SX3->X3_TAMANHO, SX3->X3_DECIMAL,"","", SX3->X3_TIPO   ,""   ,""} )   
            Aadd(aStruct,{ SX3->X3_CAMPO,SX3->X3_TIPO , SX3->X3_TAMANHO, SX3->X3_DECIMAL})  
         Else
            Aadd(aHeader,{ Substr(Alltrim(SX3->X3_TITULO),1,15),SX3->X3_CAMPO ,SX3->X3_PICTURE,SX3->X3_TAMANHO, SX3->X3_DECIMAL,"","", SX3->X3_TIPO   ,""   ,""} )   
    	    Aadd(aStruct,{ SX3->X3_CAMPO,SX3->X3_TIPO , SX3->X3_TAMANHO, SX3->X3_DECIMAL})                                        
         EndIf
      EndIf
     
      SX3->(DbSkip())
     
   EndDo           
        
   cNome:=CriaTrab(aStruct,.T.)                     
   DbUseArea(.T.,"DBFCDX",cNome,'Work',.F.,.F.)
        
   Indice1:=E_Create(,.F.)
   IndRegua("Work",Indice1+OrdBagExt(),"Work->F4_CODIGO")   
        
   SET INDEX TO (Indice1+OrdBagExt())           
                     
   QRB->(DbGoTop())
   While QRB->(!EOF())   
              
      RecLock("Work",.T.)  
      Work->F4_CODIGO   :=QRB->F4_CODIGO 
           
      For i:=n to Len(aStruct)     
         If (aStruct[i][n]) # NIL .And. (aStruct[i][n]) # NIL 
            &("Work->"+(aStruct[i][n]))   :=&("QRB->"+(aStruct[i][n]))
         EndIf               
      Next
           
      Work->(MsUnlock()) 
      n:=1
      QRB->(DbSkip()) 
           
   EndDo   
        
   DEFINE MSDIALOG oDlg1 TITLE "" FROM 000,000 TO 345,1033 PIXEL
   
                 oGetDB:= MsGetDB():New(5,;//1
                                        5,;//2
                                      150,;//3
                                      510,;//4
                                        2,;//5
	                                    ,;//06
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
                                     oDlg1,;//18
                                      .T.,;//19
                                      .F.,;//20
                                        ,;//21
                                        )

      @ 152   ,005    TO 174,   510 LABEL ""      OF oDlg1 PIXEL
      @ 160 ,300 Say "VISUALIZAR A TES NO CADASTRO PADRÃO" COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 150,6 OF oDlg1    
      @ 157 ,420 Get cSF4  F3 "SF4"  SIZE 1,1
      @ 157,465 BUTTON "Voltar"   size 40,12 ACTION Processa({|| oDlg1:End()}) of oDlg1 Pixel 
      
   Activate MSDIALOG oDlg1 Centered     
     

Return 

*----------------------------*
  Static Function MontaSF4()
*----------------------------* 

 Local nI := 0	                          
 Local aStruSF4  
 Local cQuery:=""

 aStruSF4:= SF4->(DbStruct())      

 cQuery:= "SELECT * FROM "+RetSqlName("SF4")+" 

 If !Empty(cTipo)  
    cQuery+=" Where F4_TIPO='"+cTipo+"'"
 EndIf  
 
 If !Empty(cCFOP)
    cQuery+=" and F4_CF='"+Alltrim(cCFOP)+"'"
 EndIf  
 
  If !Empty(cAtivo)
    cQuery+=" and F4_ATUATF='"+cAtivo+"'"
 EndIf   
 
  If !Empty(cDuplicata)
    cQuery+=" and F4_DUPLIC='"+cDuplicata+"'"
 EndIf 
 
 If !Empty(cPoderTerc)
    cQuery+=" and F4_PODER3='"+cPoderTerc+"'"
 EndIf 
 
 If !Empty(cEstoque)
    cQuery+=" and F4_ESTOQUE='"+cEstoque+"'"
 EndIf 
 
 If !Empty(cCalcICMS)
    cQuery+=" and F4_ICM='"+cCalcICMS+"'"
 EndIf 
 
 If !Empty(cCredICMS)
    cQuery+=" and F4_CREDICM='"+cCredICMS+"'"
 EndIf 
 
 If !Empty(cRedICMS)
    cQuery+=" and F4_BASEICM='"+Alltrim(cRedICMS)+"'"
 EndIf 
 
  If !Empty(cCalcDifICMS)
    cQuery+=" and F4_COMPL='"+cCalcDifICMS+"'"
 EndIf 
 
  If !Empty(cLFiscICMS)
    cQuery+=" and F4_LFICM='"+cLFiscICMS+"'"
 EndIf 
 
  If !Empty(cMkpICMSComp)
    cQuery+=" and F4_MKPCMP='"+cMkpICMSComp+"'"
 EndIf 
 
  If !Empty(cCalcIPI)
    cQuery+=" and F4_IPI='"+cCalcIPI+"'"
 EndIf 
 
  If !Empty(cIPInaBase)
    cQuery+=" and F4_INCIDE='"+cIPInaBase+"'"
 EndIf 
 
  If !Empty(cDestacaIPI)
    cQuery+=" and F4_DESTACA='"+cDestacaIPI+"'"
 EndIf 
 
  If !Empty(cCredIPI)
    cQuery+=" and F4_CREDIPI='"+cCredIPI+"'"
 EndIf 
 
 If !Empty(cLFiscIPI)
    cQuery+=" and F4_LFIPI='"+cLFiscIPI+"'"
 EndIf 
  
 If !Empty(cGeraIPIObs)
    cQuery+=" and F4_IPIOBS='"+cGeraIPIObs+"'"
 EndIf   
 
 If !Empty(cPisCof)
    cQuery+=" and F4_PISCOF='"+cPisCof+"'"
 EndIf  
 
 If !Empty(cCredPisCof)
    cQuery+=" and F4_PISCRED='"+cCredPisCof+"'"
 EndIf  
  
 If !Empty(cAgregPis)
    cQuery+=" and F4_AGRPIS='"+cAgregPis+"'"
 EndIf  
 
 If !Empty(cAgregCof)
    cQuery+=" and F4_AGRCOF='"+cAgregCof+"'"
 EndIf 
     
 DbSelectArea("SX3")  
 If FieldPos("F4_RECDAC") > 0
    If !Empty(cRecDACON)
       cQuery+=" and F4_RECDAC='"+cRecDACON+"'"
    EndIf 
 EndIf
   
 If !Empty(cAgregValor)
    cQuery+=" and F4_AGREG='"+cAgregValor+"'"
 EndIf
 
 If !Empty(cTpReg)
    cQuery+=" and F4_TPREG='"+cTpReg+"'"
 EndIf 
 
 If !Empty(cCalcISS)
    cQuery+=" and F4_ISS='"+cCalcISS+"'"
 EndIf
  
 If !Empty(cLFiscISS)
    cQuery+=" and F4_LFISS='"+cLFiscISS+"'"
 EndIf 
  
 If !Empty(cRetISS)
    cQuery+=" and F4_RETISS='"+cRetISS+"'"
 EndIf
   
 If !Empty(cLFiscCIAP)
    cQuery+=" and F4_CIAP='"+cLFiscCIAP+"'"
 EndIf  

 cQuery+= "AND F4_MSBLQL <> '1'"   //E que não esteja bloqueado 
  
 cQuery+= "ORDER BY F4_CODIGO"    

 cQuery	:=	ChangeQuery(cQuery)
 DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

 For nI := 1 To Len(aStruSF4)
    If aStruSF4[nI][2] <> "C" .and.  FieldPos(aStruSF4[nI][1]) > 0
	   TcSetField("QRB",aStruSF4[nI][1],aStruSF4[nI][2],aStruSF4[nI][3],aStruSF4[nI][4])
	EndIf
 Next nI  


 Return                                      
                
*----------------------------------*
  Static Function ComboSX3(cCampo)
*----------------------------------*
       
Local cRet,cAux,nPos 
cRet:='{"","'

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))
   cAux:=SX3->X3_CBOX
Else
  cRet+='"}' 
EndIf     

nPos:=At(";",Alltrim(cAux))
While 0 < nPos                          
   cRet+=substr(cAux,1,nPos-1)+'"' 
   cAux:=substr(cAux,nPos+1,Len(cAux))                                     
   nPos:=At(";",Alltrim(cAux)) 
   If nPos>0 
      cRet+=',"'
   Else
      cRet+=',"'+Alltrim(cAux)+'"}'
   EndIf  
EndDo 


Return cRet

