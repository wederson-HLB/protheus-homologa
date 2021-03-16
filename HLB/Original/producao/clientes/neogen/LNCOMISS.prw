#include "rwmake.ch"        
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF       

/*
Funcao      : COMISSLN
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão relatório de comissões
Autor       : Tiago Luiz Mendonça
Data/Hora   : 08/07/10
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 07/02/2012
Módulo      : Faturamento.
*/ 

*----------------------------*
  User Function ComissLN()      
*----------------------------*      
 
      
SetPrvt("CBTXT,CBCONT,NORDEM,LIMITE,TAMANHO,NTIPO")
SetPrvt("M_PAG,LIN,CDESC1,CDESC2,CDESC3")
SetPrvt("AORD,NCNTIMPR,CRODATXT,ARETURN,ALINHA")
SetPrvt("NOMEPROG,NLASTKEY,CPERG,NPAGINA,NIVEL,CSAVSCR1")
SetPrvt("CSTRING,CABEC1,CABEC2,WNREL,TREGS,M_MULT")

If !(cEmpAnt $ "LN/99")
   MsgAlert("Rotina não disponivel para essa empresa","Atenção")
   Return .F.
EndIf  
      
//Private cTes:=GetMv("MV_P_TESRE")
Private aCampos  := {} 
Private cPass    := Space(10) 
Private lOk      := .F.
Private cNome,cIndex,cSting,cCabec1,cCabec2,cTitulo,cFil,cArqOrig,cArqPath
Private dDataIni,dDataFim
Private nTotal:=nTotCus:=nTotCom:=0
Private oDlg,oMain
                

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=220
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 100
cTitulo :="Comissões por Vendedor "
cDesc1 :="Relatorio de Comissões por Periodo"
cDesc2 :=""
cDesc3 :=""
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
aReturn:= { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
aLinha   := {}
nomeprog :="LNCOMISS"
nLastKey := 0
cPerg    :="LNCOMISS    "
nPagina  := 1
nivel    := 1  
wnrel    :="LNCOMISS"  

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  


aCampos := {   {"VENDEDOR"  ,"C",06,0 } ,;
               {"NOME"      ,"C",30,0 } ,;
               {"PEDIDO"    ,"C",6 ,0 } ,;
               {"NOTA"      ,"C",09,0 } ,;
               {"SERIE"     ,"C",03,0 } ,;
               {"EMISSAO"   ,"C",10,0 } ,;
               {"BAIXA"     ,"C",10,0 } ,;
               {"PARCELA"   ,"C",03,0 } ,; 
               {"CODIGO"    ,"C",06,0 } ,;
               {"DESCLIENTE","C",20,0 } ,; 
               {"CIDADE"    ,"C",25,0 } ,;
               {"ESTADO"    ,"C",02,0 } ,;             
               {"VLRTOT"    ,"N",12,2 } ,;
               {"VLRSEMIMP" ,"N",12,2 } ,;
               {"COMISS"    ,"N",05,2 } ,;
               {"VLRCOMISS"    ,"N",12,2 }} 
               
//cNome := CriaTrab(aCampos,.t.)
//RRP - 08/03/2019 - Ajuste para gerar em DBF o relatorio
cNome  := CriaTrab(Nil,.F.)
dbCreate(cNome,aCampos,"DBFCDXADS" ) 
dbUseArea(.T.,"DBFCDXADS",cNome,"WORK",.F.,.F.)


DbSelectArea("WORK")
cIndex:=CriaTrab(Nil,.F.)
IndRegua("WORK",cIndex,"EMISSAO+NOTA+SERIE",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)
                                                                             	

//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------

cString  :="WORK"
cabec1   := " Vendedor                   Pedido      Nota      Serie Emissao  Baixa   Parc.  Cliente                                Cidade        Estado     Valor Total       Valor Sem Imposto          (%)        Vlr.Comissao "
//            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
cabec2:=""
             

DEFINE MSDIALOG oDlg TITLE "Neogen" From 1,7 To 10,35 OF oMain     
   
   @ 015,008 SAY "Senha "
   @ 015,045 GET cPass PASSWORD  size 50,10        
   @ 030,025 BMPBUTTON TYPE 1 ACTION(lOk:=.T.,oDlg:End()) 
   @ 030,055 BMPBUTTON TYPE 2 ACTION(lOk:=.F.,oDlg:End()) 
    
ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())
                                          
If !(lOk)
   Return .F.     
EndIf        

If !(Alltrim(cPass)=="sales") .Or.  Empty(alltrim(cPass))  .And. lOK
    MsgStop("Senha inválida","NEOGEN") 
    Return .F.
EndIf


pergunte(cPerg,.T.)

                    
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

//Set Device To Screen

If aReturn[5] == 1  
     Set Printer TO
     dbcommitAll()
     ourspool(wnrel)
Endif

Ms_Flush()
             
Return .T.   

*----------------------------*
  Static Function GeraDados()
*----------------------------* 

Local cChave:="" 
Local nParcelas:=0

cTitulo := cTitulo + ", de "+dtoc(mv_par01) + " a "+dtoc(mv_par02)

dDataIni  := mv_par01
dDataFim  := mv_par02  
cVendIni  := mv_par03
cVendFim  := mv_par04

cFil:=CFILANT       

If Empty(cVendIni) .And. Empty(cVendFim)
    MsgAlert("Necessário informar vendedor.","Atenção")
   Return .F.
EndIf
                    
MontaQry()  
QRB->(DbGoTop())
                  
If QRB->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  QRB->(DbCloseArea())
  WORK->(DbCloseArea())
  Return .F.
EndIf 
     
Do while QRB->(!Eof())  
                   
   // Execeções para TES
      
   //If !(QRB->D2_TES $ cTES)
   //   QRB->(DbSkip())
   //   loop
   //Endif 
   
	//RRP - 19/06/2013 - Verificar se são notas de saída de devolução. 
   If Select("TempSD1A") > 0
		TempSD1A->(DbCloseArea())	               
	EndIf
    
    BeginSql Alias 'TempSD1A' 
                        	
    	SELECT D1_NFORI,D1_SERIORI 
     	FROM %Table:SD1%
      	WHERE %notDel%
        AND D1_FILIAL = %exp:xFilial("SD1")%   
        AND D1_NFORI = %exp:QRB->F2_DOC%
        AND D1_SERIORI = %exp:QRB->F2_SERIE%
 	
 	EndSql
	//Verificando se o Select retornou algum resultado.
	count to nRecCount
	If nRecCount > 0
 		QRB->(DbSkip())
		loop
	Endif
 	//RRP - 19/06/2013 - Final da Verificação.
 	
   IF  QRB->F2_VEND1 <> ' ' //.And. !Empty(SC5->C5_COMIS1)
         
      RecLock("Work",.T.)  
                            
      If cChave <> Alltrim(QRB->F2_DOC)+Alltrim(QRB->F2_SERIE)
         cChave:=Alltrim(QRB->F2_DOC)+Alltrim(QRB->F2_SERIE)          
         nParcelas := ContParcelas()
      EndIf
           
      Work->VENDEDOR := QRB->F2_VEND1
                                        
      SA3->(DbSetOrder(1))
      SA3->(DbSeek(xFilial("SA3")+QRB->F2_VEND1)) 
      Work->NOME         := SA3->A3_NREDUZ
   
      Work->NOTA         := QRB->F2_DOC                          
      Work->SERIE        := QRB->F2_SERIE
      Work->EMISSAO      := Alltrim(DTOC(QRB->F2_EMISSAO))      
      Work->BAIXA        := Alltrim(DTOC(STOD(QRB->E1_BAIXA)))
      Work->PARCELA      := QRB->E1_PARCELA  
      Work->CODIGO       := QRB->F2_CLIENTE       
      Work->DESCLIENTE   := QRB->A1_NOME  
      Work->CIDADE       := QRB->A1_MUN
      Work->ESTADO       := QRB->A1_EST 
   
      SC9->(DbSetOrder(6))
      SC9->(DbSeek(xFilial("SC9")+QRB->F2_SERIE+QRB->F2_DOC)) 
      Work->PEDIDO       :=SC9->C9_PEDIDO
   
      SC5->(DbSetOrder(1))
      SC5->(DbSeek(xFilial("SC5")+Work->PEDIDO)) 
      Work->COMISS       := SC5->C5_COMIS1  
   
   
      Work->VLRTOT       := (QRB->F2_VALBRUT)/nParcelas
      Work->VLRSEMIMP    := (QRB->F2_VALBRUT - QRB->F2_VALICM-QRB->F2_VALIPI-QRB->F2_VALIMP5-QRB->F2_VALIMP6 - QRB->F2_ICMSRET )/nParcelas
      Work->VLRCOMISS    := (Work->COMISS/100) * Work->VLRSEMIMP       
 
      Work->(MsUnLock())    
      
   EndIf  
      
   QRB->(DbSkip())       
     
         
EndDo     
                                        
                   
lin += 100

Work->(dbGoTop())

Do while Work->(!Eof()) 

   SomaLin() 
   
   @ lin,001 PSAY Alltrim(Work->VENDEDOR)
   @ lin,009 PSAY Alltrim(Work->NOME)
   @ lin,029 PSAY Work->PEDIDO
   @ lin,040 PSAY Work->NOTA  
   @ lin,051 PSAY Work->SERIE 
   @ lin,055 PSAY work->EMISSAO
   @ lin,065 PSAY work->BAIXA 
   @ lin,076 PSAY work->PARCELA
   @ lin,080 PSAY Work->CODIGO
   @ lin,088 PSAY Work->DESCLIENTE 
   @ lin,120 PSAY Work->CIDADE
   @ lin,137 PSAY Work->ESTADO
   @ lin,141 PSAY Work->VLRTOT     picture    "@E 9,999,999.99"
   @ lin,162 PSAY Work->VLRSEMIMP  picture    "@E 9,999,999.99"
   @ lin,188 PSAY Work->COMISS     picture    "@E 999.99"
   @ lin,200 PSAY Work->VLRCOMISS  picture    "@E 999,999.99"


   nTotal   +=Work->VLRTOT
   nTotCus  +=Work->VLRSEMIMP
   nTotCom  +=Work->VLRCOMISS                                   
   Work->(dbskip())

EndDo  
 
 SomaLin()  
 SomaLin()
       
@ lin,000 PSAY replicate("_",220)    

 SomaLin() 
 SomaLin()   
 
@ lin,000 PSAY "TOTAIS"

@ lin,139 PSAY nTotal     picture    "@E 999,999,999.99"
@ lin,159 PSAY nTotCus    picture    "@E 999,999,999.99"
@ lin,196 PSAY nTotCom    picture    "@E 999,999,999.99"


 SomaLin()  
 
@ lin,000 PSAY replicate("_",220)                          

 
Roda(nCntImpr,cRodaTxt,Tamanho)  

dbSelectArea("WORK")
DbCloseArea("WORK") 

If mv_par05=1     

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
   EndIf

Return(nil)            


*-------------------------------*
  Static Function ContParcelas()
*-------------------------------*

Local nParcelas:=1
Local nPos:=0              
Local cCampo:=""
   
   SE4->(DbSetOrder(1))
   If SE4->(DbSeek(xFilial("SE4")+QRB->F2_COND)) 
     
      cCampo := SE4->E4_COND	
      nPos:=At(",",Alltrim(cCampo))
      While 0 < nPos                          
         cCampo:=Stuff(cCampo,nPos,1,"")
         nPos:=At(",",Alltrim(cCampo))
         nParcelas++                                                  
         
      EndDo 
           
   EndIf   
    
Return nParcelas   

*----------------------------*
  Static Function MontaQry()
*----------------------------*

aStruSF2:= SF2->(DbStruct())      

cQuery:= "SELECT E1.*,F2.*,A1.*"
cQuery+=" FROM "+RetSqlName("SF2")+" F2,"+RetSqlName("SE1")+" E1, "+RetSqlName("SA1")+" A1 "
cQuery+=" WHERE  F2.F2_SERIE+F2.F2_DOC+F2.F2_CLIENTE=E1.E1_PREFIXO+E1.E1_NUM+E1.E1_CLIENTE "
cQuery+=" AND A1.A1_COD+A1.A1_LOJA = F2.F2_CLIENTE+F2.F2_LOJA " 
If !Empty(cVendFim)
   cQuery+=" AND F2.F2_VEND1>='"+cVendIni+"'"
   cQuery+=" AND F2.F2_VEND1<='"+cVendFim +"'"  
EndIf      
cQuery+=" AND F2.F2_FILIAL ='"+cFil+"'"  
cQuery+=" AND E1.E1_FILIAL ='"+cFil+"'"    
//Solcitado por Josue - 06/10/2010
//cQuery+=" AND F2.F2_EMISSAO >= '"+Dtos(dDataIni)+"'"+Chr(10)     
//cQuery+=" AND F2.F2_EMISSAO <= '"+Dtos(dDataFim)+"'"+Chr(10)   
cQuery+=" AND E1.E1_BAIXA >= '"+Dtos(dDataIni)+"'"+Chr(10)     
cQuery+=" AND E1.E1_BAIXA <= '"+Dtos(dDataFim)+"'"+Chr(10) 
cQuery+=" AND A1.D_E_L_E_T_ <> '*' AND E1.E1_SALDO=0 AND E1_ORIGEM='MATA460 '  "
cQuery+=" AND F2.D_E_L_E_T_<>'*' AND E1.D_E_L_E_T_<>'*' "
cQuery+=" ORDER BY F2.F2_VEND1,E1.E1_BAIXA "    
                                                         
cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

For nI := 1 To Len(aStruSF2)
	If aStruSF2[nI][2] <> "C" .and.  FieldPos(aStruSF2[nI][1]) > 0
		TcSetField("QRB",aStruSF2[nI][1],aStruSF2[nI][2],aStruSF2[nI][3],aStruSF2[nI][4])
	EndIf
Next nI

  


Return

