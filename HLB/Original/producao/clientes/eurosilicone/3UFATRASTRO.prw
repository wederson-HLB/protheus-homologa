#INCLUDE "PROTHEUS.CH"                                                    
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
    
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF

/*
Funcao      : 3UFATRASTRO
Parametros  : 
Retorno     : 
Objetivos   : Emitir relatório de vendas/remessa.
Autor       : Tiago Luiz Mendonça 
Data        : 28/12/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Estoque.
*/ 
      
                
*----------------------------*
  User Function 3UFATRASTRO()      
*----------------------------* 
      
Private aCampos:={}
Private cNome,cIndex,cSting,cCabec1,cCabec2,cTitulo,cArqOrig,cArqPath
Private dDataIni,dDataFim     
Private cCliIni,cCliFim,cLojaIni,cLojaFim,cLoteIni,cLoteFim,cMedIni,cMedFim,cPacIni,cPacFim
Private m_pag:= nivel:= nPagina:= 1
Private nTotSeg:=nTotFrete:=nTotQuant:=nTotUni:=nTotal:=nTotCus:=nTotCom1:=nTotCom2:=0	                                  
Private CbTxt:=CbCont :=""
Private nOrdem:= nTipo:= nCntImpr:= 0
Private limite   :=220
Private tamanho  :="G"
Private lin      := 100
Private cTitulo  :="Relatorio de movimentações por serie"
Private cDesc1   :="Relatorio de movimentações por serie"
Private cDesc2   :=""
Private cDesc3   :=""                                   	
Private aOrd     := {}
Private cRodaTxt := "REGISTRO(S)"
Private aReturn  := { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
Private aLinha   := {}
Private nomeprog :="3UFATREL"
Private nLastKey := 0
Private cPerg    :="3UFATREL"
Private wnrel    :="3UFATREL" 
Private nTot     :=0 
Private cTipoNf  :=0 
Private nTipoRel :=0 

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  

AjustaSX1(cPerg)
pergunte(cPerg,.T.)

cTitulo := cTitulo 

cSerie    := mv_par01
dDataIni  := mv_par02
dDataFim  := mv_par03  
cTipoNF   := mv_par04
cProdIni  := mv_par05
cProdFim  := mv_par06 
cCliIni   := mv_par07 
cLojaIni  := mv_par08
cCliFim   := mv_par09 
cLojaFim  := mv_par10 
cLoteIni  := mv_par11 
cLoteFim  := mv_par12 
cMedIni   := mv_par13
cMedFim   := mv_par14
cPacIni    := mv_par15
cPacFim   := mv_par16
cExcel    := mv_par17
nTipoRel  := mv_par18

If Empty(cSerie)

   //                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
   //           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   cabec1   := "Produto      Descrição                 QTD   NF Entrada Serie Emissao Local        Serie                   Medico                   Paciente                           Nota Saida Serie Emissao  Pedido   Tipo       CFOP  "
   cabec2   := ""

   aCampos := {   {"CODIGO"      , "C",15,0 } ,;
                  {"DESCRICAO"   , "C",20,0 } ,;
                  {"ARM"         , "C",02,0 } ,;
                  {"QTD"         , "N",09,2 } ,;
                  {"NOTA_E"      , "C",09,0 } ,;
                  {"E_SERIE"     , "C",03,0 } ,;
                  {"E_EMISSAO"   , "C",10,0 } ,; 
                  {"SERIE"       , "C",24,0 } ,;
                  {"CLIENTE"     , "C",35,0 } ,;
                  {"MEDICO"      , "C",25,0 } ,;
                  {"PACIENTE"    , "C",30,0 } ,;
                  {"NOTA_S"      , "C",09,0 } ,;  
                  {"S_SERIE"     , "C",03,0 } ,;
                  {"S_EMISSAO"   , "C",10,0 } ,; 
                  {"PEDIDO"      , "C",06,0 } ,;
                  {"ALIAS"       , "C",03,0 } ,;
                  {"TIPO"        , "C",11,0 } ,;
                  {"CF"          , "C",04,0 }}    
               
Else
                                                                                                                                   
   //                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
   //           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   cabec1   := "Tipo      Nota          Serie     Emissao                     Serie                      Pedido                Medico                           Paciente                       "
   cabec2   := ""  
    
   aCampos := {   {"ALIAS"       , "C",03,0 } ,;
                  {"TIPO"        , "C",09,0 } ,; 
                  {"ARM"         , "C",02,0 } ,;
                  {"NOTA_E"      , "C",09,0 } ,;
                  {"E_SERIE"     , "C",03,0 } ,;
                  {"E_EMISSAO"   , "C",10,0 } ,; 
                  {"SERIE"       , "C",24,0 } ,;
                  {"NOTA_S"      , "C",09,0 } ,;  
                  {"S_SERIE"     , "C",03,0 } ,;
                  {"S_EMISSAO"   , "C",10,0 } ,; 
                  {"PEDIDO"      , "C",06,0 } ,; 
                  {"CLIENTE"     , "C",35,0 } ,;
                  {"MEDICO"      , "C",25,0 } ,;
                  {"PACIENTE"    , "C",30,0 } ,; 
                  {"CF"          , "C",04,0 }}  

   If Empty(dDataIni)
      MsgStop("Data inicial deve ser informada","EUROSILICONE")
      Return .F. 
   EndIf  
   
   //Caso o número de serie esteja preenchido, será impresso o relatório em formato analitico.
   If nTipoRel == 2 //Sintetico
      nTipoRel := 1 //Analitico	
   EndIf
   

EndIf   

cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,"WORK",.F.,.F.)

cString  :="WORK"                                                                                                                                                                        
                    
wnrel:=SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.)


If LastKey()== 27 .or. nLastKey== 27 
	Return
Endif
         
SetDefault(aReturn,cString)

If LastKey()== 27 .Or. nLastKey==27
   dbSelectArea("WORK")
   DbCloseArea("WORK")
   Return
Endif

RptStatus({|| GeraDados()},cTitulo)

Set Device To Screen

If aReturn[5] == 1
     dbcommitAll()
     ourspool(wnrel)
Endif

Ms_Flush()
             
Return .T.   

*----------------------------*
  Static Function GeraDados()
*----------------------------*
       
Local cCLiAux:=""  
Local lFirst:=.T.    
Local nTotQuant:=0
Local nTotCli  := 0
    
MontaQry()  

QRB->(DbGoTop())

If QRB->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  QRB->(DbCloseArea())  
  WORK->(DbCloseArea())
  Return .F.
EndIf

ProcRegua(nTot) 
     
Do while QRB->(!Eof())  
                                                 
   IncProc()                
                   
   Work->(dbGoTop())
   
   If cTipoNf ==3 //Estoque + Devolução   
      
      RecLock("Work",.T.)           
      Work->CODIGO      := QRB->ZX1_COD
      Work->DESCRICAO   := QRB->ZX1_DESCOD   
      Work->QTD         := QRB->ZX1_QTD
      Work->ARM         := QRB->ZX1_LOCAL
      Work->NOTA_E      := QRB->ZX1_DOC
      Work->E_SERIE     := QRB->ZX1_SERIE
      Work->E_EMISSAO   := DTOC(QRB->ZX1_DTNF)
      Work->CF          := QRB->ZX1_CF 
      
      If nTipoRel == 1 //Analitico
         If Empty(Alltrim(QRB->ZX1_CODBAR))
            Work->SERIE       := "Não informado"
         Else
            Work->SERIE       := QRB->ZX1_CODBAR  
         EndIf
      EndIf
            
      If Alltrim(QRB->ZX1_TIPO) == "N" 
         
         SA2->(DbSetOrder(1))
         If SA2->(DbSeek(xFilial("SA2")+QRB->ZX1_CLIENT+QRB->ZX1_LOJA ))
            Work->CLIENTE  := "Fornecedor "+Alltrim(QRB->ZX1_CLIENT)+" "+Alltrim(SA2->A2_NOME)
         EndIf  
               
         If QRB->ZX1_LOCAL == "03"
            Work->NOTA_S      := "-" 
            Work->S_SERIE     := ""   
            Work->PEDIDO      := ""     
            Work->TIPO        := "Devolução"             
         Else 
            Work->NOTA_S      := "    -     "
            Work->S_SERIE     := " - "   
            Work->PEDIDO      := " - "     
            Work->TIPO        := "Estoque"     
         EndIf
        
         If nTipoRel == 1 //Analitico
        
            If Empty(QRB->ZX1_P_DESM)
               Work->MEDICO  := " - "
            Else 
               Work->MEDICO      := QRB->ZX1_P_DESM 
            EndIf 
         
            If Empty(QRB->ZX1_P_DESP)
               Work->PACIENTE    := " - "   
            Else
               Work->PACIENTE    := QRB->ZX1_P_DESP
            EndIf   
         EndIf
         
      Else
         
         SA1->(DbSetOrder(1))
         If SA1->(DbSeek(xFilial("SA1")+QRB->ZX1_CLIENT+QRB->ZX1_LOJA ))
            Work->CLIENTE  := "Cliente "+Alltrim(QRB->ZX1_CLIENT)+" - "+Alltrim(SA1->A1_NOME)
         EndIf  
      
         Work->TIPO        := "Devolução" 
         Work->NOTA_S      := QRB->ZX1_NFORI
         Work->S_SERIE     := QRB->ZX1_SERIE  
         ZX3->(DbSetOrder(1))
         If ZX3->(DbSeek(xFilial("ZX3")+QRB->ZX1_NFORI+QRB->ZX1_SERIE  ))
            Work->PEDIDO   := ZX3->ZX3_PEDIDO
         Else
            Work->PEDIDO   := " - " 
         EndIf  
         
         If nTipoRel == 1 //Analitico
        
            If Empty(QRB->ZX1_P_DESM)
               Work->MEDICO  := " - "
            Else 
               Work->MEDICO      := QRB->ZX1_P_DESM 
            EndIf 
         
            If Empty(QRB->ZX1_P_DESP)
               Work->PACIENTE    := " - "   
            Else
               Work->PACIENTE    := QRB->ZX1_P_DESP
            EndIf   
         
         EndIf
         
         
      EndIf
      Work->(MsUnLock())
   
   ElseIf cTipoNf == 6 //Serie
   
      RecLock("Work",.T.)           
      Work->ALIAS     := QRB->ALIAS
      Work->SERIE     := QRB->ZX1_CODBAR 
      Work->PEDIDO    := QRB->ZX1_PEDIDO 
      Work->ARM       := QRB->ZX1_LOCAL 
      
      If  QRB->ALIAS == 'ZX1'
       
         Work->NOTA_E    := QRB->ZX1_DOC
         Work->E_SERIE   := QRB->ZX1_SERIE
         Work->E_EMISSAO := QRB->ZX1_DTNF   
         Work->CF        := QRB->ZX1_CF 
              
         Work->MEDICO    := QRB->ZX1_P_DESM 
         Work->PACIENTE  := QRB->ZX1_P_DESP   
         
                   
         If QRB->ZX1_TIPO == "N"
            Work->TIPO      := "ENTRADA"  
            //SA2->(DbSetOrder(1))
            //If SA2->(DbSeek(xFilial("SA2")+QRB->ZX1_CLIENT)) 
            //   Work->CLIENTE:=Alltrim(QRB->ZX1_CLIENT)+" "+Alltrim(SA2->A2_NOME)    
            //EndIf  
         Else
            Work->TIPO      := "DEVOLUCAO"
            //SA1->(DbSetOrder(1))
            //If SA1->(DbSeek(xFilial("SA1")+QRB->ZX1_CLIENT)) 
            //   Work->CLIENTE:=Alltrim(QRB->ZX1_CLIENT)+" "+Alltrim(SA1->A1_NOME)    
            // EndIf  
         EndIF 
         
      Else     
        
         SC5->(DbSetOrder(1))
         If SC5->(DbSeek(xFilial("SC5")+QRB->ZX1_PEDIDO))
            
            SA1->(DbSetOrder(1))
            If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE)) 
              Work->CLIENTE:="Cliente "+Alltrim(SC5->C5_CLIENTE)+" - "+Alltrim(SA1->A1_NOME)    
            EndIf  
         
         EndIf
               
		 Work->MEDICO    := QRB->ZX1_P_DESM
         Work->PACIENTE  := QRB->ZX1_P_DESP
         
         Work->NOTA_S    := QRB->ZX1_DOC
         Work->S_SERIE   := QRB->ZX1_SERIE   
         Work->S_EMISSAO := QRB->ZX1_DTNF
         Work->CF        := QRB->ZX1_CF       
         
         If QRB->ZX1_CF $ "5912/6912"
            Work->TIPO      := "REMESSA"
         ElseIf QRB->ZX1_CF $ "5949/6949"     
            Work->TIPO      := "REM. P/ TROCA"
         Else 
            Work->TIPO      := "VENDA"        
         EndIf
      
      EndIf  
     
      RecLock("Work",.T.)  
      Work->(MsUnLock())
   
   Else   
     
      SC5->(DbSetOrder(1))  
      If SC5->(DbSeek(xFilial()+QRB->ZX3_PEDIDO)) 
          
         RecLock("Work",.T.)           
         Work->CODIGO      := QRB->ZX1_COD
         Work->DESCRICAO   := QRB->ZX1_DESCOD   
         Work->QTD         := QRB->ZX1_QTD
         Work->NOTA_E      := QRB->ZX1_DOC
         Work->E_SERIE     := QRB->ZX1_SERIE
         Work->E_EMISSAO   := QRB->ZX1_DTNF
         If nTipoRel == 1 //Analitico
            Work->SERIE       := QRB->ZX1_CODBAR
         EndIf
         Work->ARM         := QRB->ZX1_LOCAL       
         SA1->(DbSetOrder(1))
         If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE)) 
            Work->CLIENTE:="Cliente "+Alltrim(SC5->C5_CLIENTE)+" - "+Alltrim(SA1->A1_NOME)    
         EndIf
         
         ZX5->(DbSetOrder(1))
         If ZX5->(DbSeek(xFilial("ZX5")+QRB->ZX3_P_MEDI))
            Work->MEDICO := AllTrim(ZX5->ZX5_NOME)
         EndIf

         ZX7->(DbSetOrder(1))
         If ZX7->(DbSeek(xFilial("ZX7")+QRB->ZX3_P_PAC))
            Work->PACIENTE := AllTrim(ZX7->ZX7_NOME)
         EndIf
              
         If nTipoRel == 1 //Analitico
            Work->NOTA_S      := QRB->ZX1_NFSAID
            Work->S_SERIE     := QRB->ZX1_SESAID   
            Work->S_EMISSAO   := DTOC(QRB->ZX3_DTNF)
            Work->PEDIDO      := QRB->ZX1_PEDIDO  
            Work->CF          := QRB->ZX3_CF 
         EndIf 
      
         If QRB->ZX3_CF $ "5912/6912"   
            Work->TIPO        := "REMESSA" 
         ElseIf QRB->ZX3_CF $ "5949/6949" 
            Work->TIPO        := "REM. TROCA"      
         Else
            Work->TIPO        := "VENDA"
         EndIf
      
         Work->(MsUnLock())                     
      
      Else
         
         MsgStop("O Pedido "+QRB->ZX3_PEDIDO+" não foi encontrado, entre em contato com a equipe de suporte","EUROSILICONE") 
         Return .F.
      
      EndIf   
   
   EndIf
   
   QRB->(DbSkip())   
      
EndDo           
                   
lin += 100

Work->(dbGoTop())

Do while Work->(!Eof()) 

   SomaLin() 
                                  
   If cTipoNf == 6 //Serie 
      
      If Work->ALIAS == "ZX1"
        
         @ lin,000 PSAY Work->TIPO 
         //@ lin,035 PSAY Work->QTD  picture    "@E 99999.99"  
         @ lin,010 PSAY Work->NOTA_E 
         @ lin,025 PSAY Work->E_SERIE   
         If !Empty(Work->E_EMISSAO)
            @ lin,034 PSAY DTOC(STOD(Work->E_EMISSAO)) 
         EndIf
         @ lin,053 PSAY Work->SERIE 
         //@ lin,090 PSAY Work->PEDIDO 
         //@ lin,100 PSAY Work->CLIENTE 
         @ lin,108 PSAY Work->MEDICO 
         @ lin,150 PSAY Work->PACIENTE    
     
      ElseIf Work->ALIAS == "ZX3"
         
         @ lin,000 PSAY Work->TIPO
         If Empty(Work->NOTA_S) 
            @ lin,010 PSAY "Pedido/Serie incluido, mas não faturado"           
         Else
            @ lin,010 PSAY Work->NOTA_S    
            @ lin,025 PSAY Work->S_SERIE    
            If !Empty(Work->S_EMISSAO)
               @ lin,034 PSAY DTOC(STOD(Work->S_EMISSAO)) 
            EndIf 
         EndIf   
         @ lin,053 PSAY Work->SERIE    
         @ lin,090 PSAY Work->PEDIDO 
         @ lin,108 PSAY Work->MEDICO 
         @ lin,150 PSAY Work->PACIENTE      
     
      EndIf  
   
   Else
          
      If Alltrim(cCliAux) <> Alltrim(Work->CLIENTE)
         
         If !(lFirst)
                 
            //Imprime o total do cliente
            SomaLin()         
           
            @ lin,005 PSAY "Total " + AllTrim(cCliAux)
            @ lin,055 PSAY nTotCli  picture "@E 99,999,999.99"
            @ lin,070 PSAY "Movimento(s)"

            SomaLin()         
            @ lin,000 PSAY replicate("_",220)    
            SomaLin()         
         EndIf       
         
         lFirst:=.F.
      
         @ lin,005 PSAY Work->CLIENTE
         cCliAux :=Work->CLIENTE   
         
         SomaLin()
         SomaLin()       
         
         nTotCli := 0
     
      EndIf   
      
      @ lin,000 PSAY Work->CODIGO 
      @ lin,015 PSAY Work->DESCRICAO
      @ lin,035 PSAY Work->QTD  picture    "@E 99999.99"  
      @ lin,046 PSAY Work->NOTA_E 
      @ lin,058 PSAY Work->E_SERIE   
      @ lin,063 PSAY DTOC(STOD(Work->E_EMISSAO))  
      @ lin,073 PSAY Work->ARM
      @ lin,077 PSAY Work->SERIE  
      @ lin,102 PSAY Work->MEDICO 
      @ lin,132 PSAY Work->PACIENTE      
      @ lin,170 PSAY Work->NOTA_S    
      @ lin,181 PSAY Work->S_SERIE    
      @ lin,185 PSAY CTOD(Work->S_EMISSAO )  
      @ lin,194 PSAY Work->PEDIDO 
      @ lin,202 PSAY Work->TIPO 
      @ lin,214 PSAY Work->CF 
      
      nTotQuant += Work->QTD
      nTotCli   += Work->QTD
      
   EndIf
   
   Work->(dbskip())

EndDo  
   
If cTipoNf <> 6  
   
   //Imprime o total do cliente
   SomaLin()
   SomaLin()
          
   @ lin,005 PSAY "Total " + AllTrim(cCliAux)
   @ lin,055 PSAY nTotCli  picture "@E 99,999,999.99"
   @ lin,070 PSAY "Movimento(s)"
   
   //Imprime o total geral.
   SomaLin()  
   SomaLin()
       
   @ lin,000 PSAY replicate("_",220)    

   SomaLin() 
   SomaLin()   
 
   @ lin,005 PSAY "TOTAL GERAL"
   @ lin,055 PSAY nTotQuant  picture    "@E 99,999,999.99"
   @ lin,070 PSAY "Movimento(s)"
 
   SomaLin()  
 
   @ lin,000 PSAY replicate("_",220)                          

 
   Roda(nCntImpr,cRodaTxt,Tamanho)  

Else

   SomaLin()  
   SomaLin()
       
   @ lin,000 PSAY replicate("_",220)   
   
   Roda(nCntImpr,cRodaTxt,Tamanho)  

   
EndIf

dbSelectArea("WORK")
DbCloseArea("WORK") 

If cExcel=1     

   cArqOrig := "\SYSTEM\"+cNome+".DBF"
   cPath     := AllTrim(GetTempPath())                                                   
   CpyS2T( cArqOrig , cPath, .T. )
                           
   If ApOleClient("MsExcel")
      
      oExcelApp:=MsExcel():New()
      //oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
      oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
      oExcelApp:SetVisible(.T.)   
    
   Else 
   
      Alert("Excel não instalado") 
      
   EndIf


EndIf
 
dbSelectArea("QRB")
DbCloseArea("QRB") 

Erase &cNome+".DBF"


Return

*----------------------------*
  Static Function Somalin()
*----------------------------*

   lin := lin + 1
   
   If lin > 58
       cabec(ctitulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
       lin := 8
   Endif

Return        

*----------------------------*
  Static Function MontaQry()
*----------------------------*

aStruZX3:= ZX3->(DbStruct())  
aStruZX1:= ZX1->(DbStruct()) 
        
//Rastro por serie  - Caso a serie(SN) seja preenchida nenhum outro paramentro é verificado ( Rastreabilidade ) 
If !Empty(cSerie)

   cQuery:=  " Select 'ZX1' as ALIAS,ZX1_ITEM,ZX1_COD,ZX1_QTD,ZX1_CLIENT,ZX1_CODBAR,ZX1_DOC,ZX1_SERIE,ZX1_TIPO,ZX1_DTNF,ZX1_TES,ZX1_PEDIDO,ZX1_PODER3,ZX1_CF,ZX1_LOCAL,ZX1_P_DESM,ZX1_P_DESP"
   cQuery+=  " from "+RetSqlName("ZX1")+" where D_E_L_E_T_ <> '*' AND  ZX1_SN ='"+UPPER(cSerie)+"'
   cQuery+=  " UNION "
   cQuery+=  " Select 'ZX3' as ALIAS,ZX3_ITEM,ZX3_COD,ZX3_QTD,ZX3_CLIENT ,ZX3_CODBAR,ZX3_DOC,ZX3_SERIE,ZX3_TIPO,ZX3_DTNF,ZX3_TES,ZX3_PEDIDO,ZX3_PODER3,ZX3_CF,ZX3_LOCAL,ZX3_P_DESM,ZX3_P_DESP" 
   cQuery+=  " from "+RetSqlName("ZX3")+" where D_E_L_E_T_ <> '*' AND  ZX3_SN ='"+UPPER(cSerie)+"'
   cQuery+=  " Order by ZX1_DTNF "

   cQuery	:=	ChangeQuery(cQuery)
   DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.) 
   Count to nTot 

   For nI := 1 To Len(aStruZX3)
      If aStruZX3[nI][2] <> "C" .and.  FieldPos(aStruZX3[nI][1]) > 0
         TcSetField("QRB",aStruZX3[nI][1],aStruZX3[nI][2],aStruZX3[nI][3],aStruZX3[nI][4])
	  EndIf
   Next nI 
   
   cTipoNf:=6
     
Else  

	// Todos os tipos foram divididos opções para facilitar a manutenção.
		
   //Venda                        
   If cTipoNf == 1

      If nTipoRel == 1 //Analitico
         cQuery:= "SELECT E.ZX1_ITEM,E.ZX1_COD,E.ZX1_QTD,E.ZX1_LOCAL,E.ZX1_DESCOD,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_CODBAR,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_TIPO,E.ZX1_DTNF,"
         cQuery+= "E.ZX1_STATUS,E.ZX1_TES,E.ZX1_CF,E.ZX1_PODER3,E.ZX1_NFORI,E.ZX1_SERIOR,E.ZX1_SEQORI,E.ZX1_PEDIDO,E.ZX1_NFSAID,E.ZX1_SESAID,E.ZX1_ITEMSA,E.ZX1_P_DESM,E.ZX1_P_DESP,"
         cQuery+= "S.ZX3_ITEM,S.ZX3_PEDIDO,S.ZX3_ITEM,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_QTD,S.ZX3_LOCAL,S.ZX3_CODBAR,S.ZX3_DOC,S.ZX3_SERIE,S.ZX3_TIPO,S.ZX3_DTNF,"
         cQuery+= "S.ZX3_STATUS,S.ZX3_TES,S.ZX3_CF,S.ZX3_PODER3,S.ZX3_CF,S.ZX3_P_MEDI,S.ZX3_P_PAC "
      
      ElseIf nTipoRel == 2 //Sintetico
         cQuery:= "SELECT E.ZX1_COD,E.ZX1_DESCOD,SUM(ZX1_QTD) as ZX1_QTD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"	
      
      EndIF

      cQuery+=" FROM "+RetSqlName("ZX3")+" S "
      cQuery+=" LEFT JOIN "+RetSqlName("ZX1")+" E ON E.ZX1_NFSAID = S.ZX3_DOC AND E.ZX1_CODBAR = S.ZX3_CODBAR AND E.D_E_L_E_T_ <> '*'"
      cQuery+=" WHERE S.D_E_L_E_T_ <> '*'"

      If !Empty(cProdIni)
         cQuery+=" AND S.ZX3_COD>='"+cProdIni+"'"
         cQuery+=" AND S.ZX3_COD<='"+cProdFim+"'"
      EndIf      
      
      If !Empty(cCliIni)
         cQuery+=" AND S.ZX3_CLIENT>='"+cCliIni+"'"
         cQuery+=" AND S.ZX3_CLIENT<='"+cCliFim+"'"
      EndIf   
      
      If !Empty(cLoteIni)
         cQuery+=" AND S.ZX3_LOTE>='"+cLoteIni+"'"
         cQuery+=" AND S.ZX3_LOTE<='"+cLoteFim+"'"
      EndIf 
      
      If !Empty(cMedIni)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cMedFim)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
  
      If !Empty(cPacIni)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf
         
      If !Empty(cPacFim)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf

      cQuery+=" AND S.ZX3_CF IN ('5102','6102')  "
      cQuery+=" AND S.ZX3_DTNF >= '"+Dtos(dDataIni)+"'"+Chr(10)     
      cQuery+=" AND S.ZX3_DTNF <= '"+Dtos(dDataFim)+"'"+Chr(10) 

      If nTipoRel == 2 //Sintetico
         cQuery+= " GROUP BY E.ZX1_COD,E.ZX1_DESCOD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"
      EndIf

      cQuery+=" ORDER BY S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,S.ZX3_SERIE "    
  
      cQuery	:=	ChangeQuery(cQuery)
      DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.) 
      Count to nTot 

      For nI := 1 To Len(aStruZX3)
         If aStruZX3[nI][2] <> "C" .and.  FieldPos(aStruZX3[nI][1]) > 0
            TcSetField("QRB",aStruZX3[nI][1],aStruZX3[nI][2],aStruZX3[nI][3],aStruZX3[nI][4])
	     EndIf
      Next nI
  
   //Estoque + Devolução
   ElseIf cTipoNf == 3 
      
      If nTipoRel == 1 //Analitico
         cQuery:= "Select E.ZX1_ITEM,E.ZX1_COD,E.ZX1_QTD,E.ZX1_LOCAL,E.ZX1_DESCOD,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_CODBAR,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_TIPO,E.ZX1_DTNF,E.ZX1_P_DESM,E.ZX1_P_DESP,"
         cQuery+= "E.ZX1_STATUS,E.ZX1_TES,E.ZX1_CF,E.ZX1_PODER3,E.ZX1_NFORI,E.ZX1_SERIOR,E.ZX1_SEQORI,E.ZX1_PEDIDO,E.ZX1_NFSAID,E.ZX1_SESAID,E.ZX1_ITEMSA,E.ZX1_LOTE"
      ElseIf nTipoRel == 2 //Sintetico
         cQuery:= "SELECT E.ZX1_COD,E.ZX1_DESCOD,SUM(ZX1_QTD) AS ZX1_QTD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_PEDIDO,E.ZX1_CF,E.ZX1_TIPO,E.ZX1_NFORI"     
      EndIf

      cQuery+=" FROM "+RetSqlName("ZX1")+" E "
      cQuery+=" WHERE  E.D_E_L_E_T_ <> '*' And E.ZX1_PEDIDO =''  "
   
      If !Empty(cProdIni)
         cQuery+=" AND E.ZX1_COD>='"+cProdIni+"'"
         cQuery+=" AND E.ZX1_COD<='"+cProdFim+"'"
      EndIf 
          
      If !Empty(cLoteIni)
         cQuery+=" AND E.ZX1_LOTE>='"+cLoteIni+"'"
         cQuery+=" AND E.ZX1_LOTE<='"+cLoteFim+"'"
      EndIf 

      cQuery+=" AND E.ZX1_DTNF >= '"+Dtos(dDataIni)+"'"+Chr(10)     
      cQuery+=" AND E.ZX1_DTNF <= '"+Dtos(dDataFim)+"'"+Chr(10) 
           
      If !Empty(cMedIni)
         cQuery+=" AND E.ZX1_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND E.ZX1_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cMedFim)
         cQuery+=" AND E.ZX1_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND E.ZX1_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cPacIni)
         cQuery+=" AND E.ZX1_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND E.ZX1_P_PAC <='"+cPacFim+"'"      
      EndIf

      If !Empty(cPacFim)
         cQuery+=" AND E.ZX1_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND E.ZX1_P_PAC <='"+cPacFim+"'"      
      EndIf
 
     
     
      If nTipoRel == 2 //Sintetico
         cQuery+= " GROUP BY E.ZX1_COD,E.ZX1_DESCOD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_PEDIDO,E.ZX1_CF,E.ZX1_TIPO,E.ZX1_NFORI"
      EndIf
      
      cQuery+=" order by E.ZX1_CLIENT  "    
   
      cQuery	:=	ChangeQuery(cQuery)
      DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)
    
      For nI := 1 To Len(aStruZX1)
         If aStruZX1[nI][2] <> "C" .and.  FieldPos(aStruZX1[nI][1]) > 0
            TcSetField("QRB",aStruZX1[nI][1],aStruZX1[nI][2],aStruZX1[nI][3],aStruZX1[nI][4])
	     EndIf
      Next nI    
   
   //Remessa
   ElseIf cTipoNf == 2 
   
      
      If nTipoRel == 1 //Analitico
         cQuery:= "select E.ZX1_ITEM,E.ZX1_COD,E.ZX1_QTD,E.ZX1_LOCAL,E.ZX1_DESCOD,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_CODBAR,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_TIPO,E.ZX1_DTNF,E.ZX1_P_DESM,E.ZX1_P_DESP,"
         cQuery+= "E.ZX1_STATUS,E.ZX1_TES,E.ZX1_CF,E.ZX1_PODER3,E.ZX1_NFORI,E.ZX1_SERIOR,E.ZX1_SEQORI,E.ZX1_PEDIDO,E.ZX1_NFSAID,E.ZX1_SESAID,E.ZX1_ITEMSA,E.ZX1_LOTE,"
         cQuery+= "S.ZX3_ITEM,S.ZX3_PEDIDO,S.ZX3_ITEM,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_QTD,S.ZX3_LOCAL,S.ZX3_CODBAR,S.ZX3_DOC,S.ZX3_SERIE,S.ZX3_TIPO,S.ZX3_DTNF,"
         cQuery+= "S.ZX3_STATUS,S.ZX3_TES,S.ZX3_CF,S.ZX3_PODER3,S.ZX3_CF,S.ZX3_LOTE,S.ZX3_P_MEDI,S.ZX3_P_PAC"

      ElseIf nTipoRel == 2 //Sintetico
         cQuery:= "SELECT E.ZX1_COD,E.ZX1_DESCOD,SUM(ZX1_QTD) as ZX1_QTD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"	
      
      EndIF

      cQuery+=" FROM "+RetSqlName("ZX3")+" S "
      cQuery+=" LEFT JOIN "+RetSqlName("ZX1")+" E ON E.ZX1_NFSAID = S.ZX3_DOC AND E.ZX1_CODBAR = S.ZX3_CODBAR AND E.D_E_L_E_T_ <> '*'"
      cQuery+=" WHERE S.D_E_L_E_T_ <> '*'"
   
      If !Empty(cProdIni)
         cQuery+=" AND S.ZX3_COD>='"+cProdIni+"'"
         cQuery+=" AND S.ZX3_COD<='"+cProdFim+"'"
      EndIf  
      
      If !Empty(cCliIni)
         cQuery+=" AND S.ZX3_CLIENT>='"+cCliIni+"'"
         cQuery+=" AND S.ZX3_CLIENT<='"+cCliFim+"'"
      EndIf   
      
      If !Empty(cLoteIni)
         cQuery+=" AND S.ZX3_LOTE>='"+cLoteIni+"'"
         cQuery+=" AND S.ZX3_LOTE<='"+cLoteFim+"'"
      EndIf 

      If !Empty(cMedIni)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cMedFim)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
  
      If !Empty(cPacIni)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf
         
      If !Empty(cPacFim)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf

      cQuery+=" AND ( S.ZX3_CF = '5912' Or S.ZX3_CF = '6912' )"  // Or S.ZX3_CF = '5949' Or S.ZX3_CF = '6949' )   "
      cQuery+=" AND S.ZX3_DTNF >= '"+Dtos(dDataIni)+"'"+Chr(10)     
      cQuery+=" AND S.ZX3_DTNF <= '"+Dtos(dDataFim)+"'"+Chr(10) 

      If nTipoRel == 2 //Sintetico
         cQuery+= " GROUP BY E.ZX1_COD,E.ZX1_DESCOD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"
      EndIf

      //cQuery+=" order by S.ZX3_CLIENT,S.ZX3_COD  "    
      cQuery+=" ORDER BY S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,S.ZX3_SERIE "    
   
      cQuery	:=	ChangeQuery(cQuery)
      DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

      For nI := 1 To Len(aStruZX3)
         If aStruZX3[nI][2] <> "C" .and.  FieldPos(aStruZX3[nI][1]) > 0
            TcSetField("QRB",aStruZX3[nI][1],aStruZX3[nI][2],aStruZX3[nI][3],aStruZX3[nI][4])
	     EndIf
      Next nI
      
   //Remessa p/ Troca
   ElseIf cTipoNf == 4 
     
      If nTipoRel == 1 //Analitico
         cQuery:= "select E.ZX1_ITEM,E.ZX1_COD,E.ZX1_QTD,E.ZX1_LOCAL,E.ZX1_DESCOD,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_CODBAR,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_TIPO,E.ZX1_DTNF,E.ZX1_P_DESM,E.ZX1_P_DESP,"
         cQuery+= "E.ZX1_STATUS,E.ZX1_TES,E.ZX1_CF,E.ZX1_PODER3,E.ZX1_NFORI,E.ZX1_SERIOR,E.ZX1_SEQORI,E.ZX1_PEDIDO,E.ZX1_NFSAID,E.ZX1_SESAID,E.ZX1_ITEMSA,E.ZX1_LOTE,"
         cQuery+= "S.ZX3_ITEM,S.ZX3_PEDIDO,S.ZX3_ITEM,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_QTD,S.ZX3_LOCAL,S.ZX3_CODBAR,S.ZX3_DOC,S.ZX3_SERIE,S.ZX3_TIPO,S.ZX3_DTNF,"
         cQuery+= "S.ZX3_STATUS,S.ZX3_TES,S.ZX3_CF,S.ZX3_PODER3,S.ZX3_CF,S.ZX3_LOTE,S.ZX3_P_MEDI,S.ZX3_P_PAC"

      ElseIf nTipoRel == 2 //Sintetico
         cQuery:= "SELECT E.ZX1_COD,E.ZX1_DESCOD,SUM(ZX1_QTD) as ZX1_QTD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"	
      
      EndIf

      cQuery+=" FROM "+RetSqlName("ZX3")+" S "
      cQuery+=" LEFT JOIN "+RetSqlName("ZX1")+" E ON E.ZX1_NFSAID = S.ZX3_DOC AND E.ZX1_CODBAR = S.ZX3_CODBAR AND E.D_E_L_E_T_ <> '*'"
      cQuery+=" WHERE S.D_E_L_E_T_ <> '*'"  
      
      If !Empty(cProdIni)
         cQuery+=" AND S.ZX3_COD>='"+cProdIni+"'"
         cQuery+=" AND S.ZX3_COD<='"+cProdFim+"'"
      EndIf 

      If !Empty(cCliIni)
         cQuery+=" AND S.ZX3_CLIENT>='"+cCliIni+"'"
         cQuery+=" AND S.ZX3_CLIENT<='"+cCliFim+"'"
      EndIf   
      
      If !Empty(cLoteIni)
         cQuery+=" AND S.ZX3_LOTE>='"+cLoteIni+"'"
         cQuery+=" AND S.ZX3_LOTE<='"+cLoteFim+"'"
      EndIf 

      If !Empty(cMedIni)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cMedFim)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
  
      If !Empty(cPacIni)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"       
      Else
         cQuery+=" AND E.ZX1_CODBAR = S.ZX3_CODBAR   "      
      EndIf
         
      If !Empty(cPacFim)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf
   
      cQuery+=" AND ( S.ZX3_CF = '5949' Or S.ZX3_CF = '6949' )   "
      cQuery+=" AND S.ZX3_DTNF >= '"+Dtos(dDataIni)+"'"+Chr(10)     
      cQuery+=" AND S.ZX3_DTNF <= '"+Dtos(dDataFim)+"'"+Chr(10) 
      
      If nTipoRel == 2 //Sintetico
         cQuery+= " GROUP BY E.ZX1_COD,E.ZX1_DESCOD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"
      EndIf
 
      cQuery+=" ORDER BY S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,S.ZX3_SERIE "    
      //cQuery+=" order by S.ZX3_CLIENT,S.ZX3_COD  "    
   
      cQuery	:=	ChangeQuery(cQuery)
      DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

      For nI := 1 To Len(aStruZX3)
         If aStruZX3[nI][2] <> "C" .and.  FieldPos(aStruZX3[nI][1]) > 0
            TcSetField("QRB",aStruZX3[nI][1],aStruZX3[nI][2],aStruZX3[nI][3],aStruZX3[nI][4])
	     EndIf
      Next nI   

      //Venda + Remessas
   ElseIf cTipoNf == 5  

      If nTipoRel == 1 //Analitico
         cQuery:= "select E.ZX1_ITEM,E.ZX1_COD,E.ZX1_QTD,E.ZX1_LOCAL,E.ZX1_DESCOD,E.ZX1_CLIENT,E.ZX1_LOJA,E.ZX1_CODBAR,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_TIPO,E.ZX1_DTNF,E.ZX1_P_DESM,E.ZX1_P_DESP,"
         cQuery+= "E.ZX1_STATUS,E.ZX1_TES,E.ZX1_CF,E.ZX1_PODER3,E.ZX1_NFORI,E.ZX1_SERIOR,E.ZX1_SEQORI,E.ZX1_PEDIDO,E.ZX1_NFSAID,E.ZX1_SESAID,E.ZX1_ITEMSA,E.ZX1_LOTE,"
         cQuery+= "S.ZX3_ITEM,S.ZX3_PEDIDO,S.ZX3_ITEM,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_QTD,S.ZX3_LOCAL,S.ZX3_CODBAR,S.ZX3_DOC,S.ZX3_SERIE,S.ZX3_TIPO,S.ZX3_DTNF,"
         cQuery+= "S.ZX3_STATUS,S.ZX3_TES,S.ZX3_CF,S.ZX3_PODER3,S.ZX3_CF,S.ZX3_LOTE,S.ZX3_P_MEDI,S.ZX3_P_PAC"

      ElseIf nTipoRel == 2 //Sintetico
         cQuery:= "SELECT E.ZX1_COD,E.ZX1_DESCOD,SUM(ZX1_QTD) as ZX1_QTD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"	
      
      EndIf
  
      cQuery+=" FROM "+RetSqlName("ZX3")+" S "
      cQuery+=" LEFT JOIN "+RetSqlName("ZX1")+" E ON E.ZX1_NFSAID = S.ZX3_DOC AND E.ZX1_CODBAR = S.ZX3_CODBAR AND E.D_E_L_E_T_ <> '*'"
      cQuery+=" AND   E.ZX1_CODBAR = S.ZX3_CODBAR   "
      cQuery+=" WHERE S.D_E_L_E_T_ <> '*'"
      
      If !Empty(cProdIni)
         cQuery+=" AND S.ZX3_COD>='"+Alltrim(cProdIni)+"'"
         cQuery+=" AND S.ZX3_COD<='"+Alltrim(cProdFim)+"'"
      EndIf 
      
      If !Empty(cCliIni)
         cQuery+=" AND S.ZX3_CLIENT>='"+Alltrim(cCliIni)+"'"
         cQuery+=" AND S.ZX3_CLIENT<='"+Alltrim(cCliFim)+"'"
      EndIf   
      
      If !Empty(cLoteIni)
         cQuery+=" AND S.ZX3_LOTE>='"+Alltrim(cLoteIni)+"'"
         cQuery+=" AND S.ZX3_LOTE<='"+Alltrim(cLoteFim)+"'"
      EndIf 

      If !Empty(cMedIni)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
      
      If !Empty(cMedFim)
         cQuery+=" AND S.ZX3_P_MEDI >='"+cMedIni+"'"      
         cQuery+=" AND S.ZX3_P_MEDI <='"+cMedFim+"'"      
      EndIf
  
      If !Empty(cPacIni)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf
         
      If !Empty(cPacFim)
         cQuery+=" AND S.ZX3_P_PAC >='"+cPacIni+"'"      
         cQuery+=" AND S.ZX3_P_PAC <='"+cPacFim+"'"      
      EndIf
             
      cQuery+=" AND S.ZX3_CF NOT IN ('5949','6949')  "                
      cQuery+=" AND S.ZX3_DTNF >= '"+Dtos(dDataIni)+"'"+Chr(10)     
      cQuery+=" AND S.ZX3_DTNF <= '"+Dtos(dDataFim)+"'"+Chr(10) 
      
      If nTipoRel == 2 //Sintetico
         cQuery+= " GROUP BY E.ZX1_COD,E.ZX1_DESCOD,E.ZX1_DOC,E.ZX1_SERIE,E.ZX1_DTNF,E.ZX1_LOCAL,S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,ZX3_SERIE,S.ZX3_DTNF,E.ZX1_PEDIDO,S.ZX3_CF,S.ZX3_PEDIDO,S.ZX3_P_MEDI,S.ZX3_P_PAC"
      EndIf
 
      cQuery+=" ORDER BY S.ZX3_CLIENT,S.ZX3_COD,S.ZX3_DOC,S.ZX3_SERIE "    
      //cQuery+=" order by S.ZX3_CLIENT,S.ZX3_COD  "    
   
      cQuery	:=	ChangeQuery(cQuery)
      DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

      For nI := 1 To Len(aStruZX3)
         If aStruZX3[nI][2] <> "C" .and.  FieldPos(aStruZX3[nI][1]) > 0
            TcSetField("QRB",aStruZX3[nI][1],aStruZX3[nI][2],aStruZX3[nI][3],aStruZX3[nI][4])
	     EndIf
      Next nI   

   EndIf      
  
EndIf

Return

/*
Funcao      : AjustaSX1()
Parametros  : cPerg: Código da pergunta.
Retorno     : Nil
Objetivos   : Ajusta o dicionario de perguntas (SX1).
Autor       : Eduardo C. Romanini
Data/Hora   : 17/01/11 16:24
*/
*------------------------------*
Static Function AjustaSX1(cPerg)
*------------------------------*
       //cGrupo,cOrdem,cPergunt           ,cPerSpa            ,cPerEng            ,cVar    ,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg ,cPyme, cVar01    ,
U_PUTSX1(	cPerg  ,'14'  ,'Tipo de Relatorio','Tipo de Relatorio','Tipo de Relatorio','MV_CHE', 'N' ,1       ,0       ,1      ,'C' ,''    ,'' ,''      ,'S'  , 'mv_par14',;
	  ;// cDef01      ,cDefSpa1,cDefEng1,cCnt01,cDef02     ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5, cDefEng5
		  'Analitico' ,''      ,''      ,''    ,'Sintetico',''      ,''      ,''    ,''      ,''      ,''    ,''      ,''      ,''    ,''      ,''       )

Return Nil   
