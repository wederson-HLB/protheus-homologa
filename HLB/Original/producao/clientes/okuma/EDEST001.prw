#include "rwmake.ch"        

/*
Funcao      : EDEST001
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Impressão relatório de produtos sem movimentos   
Autor     	: Tiago Luiz Mendonça
Data     	: 01/06/2010
Revisão     : JVR - 16/01/2012
Objetivo    : Implementação de melhoria para mostrar a data da ulima movimentação para os produtos
Data/Hora   : 16/01/2012
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Estoque
Cliente     : Okuma
*/ 

*----------------------------*
User Function EDEST001()      
*----------------------------*    

                   
Private CbTxt:= CbCont:= cProdIni:= cProdFim:= cTipIni:= cTipFim:= cArmIni:=cArmFim:=cGrpIni:=cGrpFim:=cSemSaldo:=""
Private nOrdem:= nTipo:= nCntImpr :=lin:= 0   
Private nTotUni:=nTotal:=0
Private dDataIni,dDataFim 
Private nlimite   :=220
Private cTamanho  :="G"
Private M_PAG     := 1
Private nlin      := 100
Private cTitulo   :="Produtos sem Movimento "
Private cDesc1    :="Produtos sem Movimento"
Private cDesc2    :=""
Private cDesc3    :=""
Private aOrd      := {}
Private cRodaTxt  := "REGISTRO(S)"
Private aReturn   := { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
Private aLinha    := {}
Private nomeprog  :="EDEST001"
Private nLastKey  := 0
Private cPerg     :="PRYOR01"
Private nPagina   := 1
Private nivel     := 1  
Private wnrel     :="EDEST001"  
Private aCampos   :={}   

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf   

If Select("TRB") > 0
   TRB->(DbCloseArea())
EndIf   

CriaPerg()
       
aCampos := {   {"CODPROD" ,"C",15,0 } ,;
               {"DESPROD" ,"C",30,0 } ,;
               {"ARMAZEM" ,"C",02,0 } ,;
               {"TIPO"    ,"C",02,0 } ,;
               {"QTD"     ,"N",09,0 } ,;
               {"PRCUNI"  ,"N",12,4 } ,;
               {"TOTAL"   ,"N",17,2 } ,;
               {"DDATA"   ,"C",10,2 } ,;
               {"TIPOMOV" ,"C",01,2 } ,;
               {"DATAMOV" ,"C",10,2 }} 
               
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,"WORK",.F.,.F.)

DbSelectArea("WORK")
cIndex:=CriaTrab(Nil,.F.)
IndRegua("WORK",cIndex,"CODPROD+ARMAZEM",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)
          
          // Variaveis utilizadas para Impressao do Cabecalho e Rodape

cString  :="WORK"
cabec1   := " Produto         Descrição                     Armazem    Tipo       Quantidade Atual            Custo Unitário                Valor Total Estoque            Dt fechamento p/ custo       Tipo Mov.    Dt Ultima Mov.     "
//            0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28        29        30
cabec2:=""

IF pergunte(cPerg,.T.)

                    
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

  If aReturn[5] == 1  
     Set Printer TO
     dbcommitAll()
     ourspool(wnrel)
  Endif

  Ms_Flush()
  
Else
    
  Return .F.
  
EndIf  

Return .T.


*----------------------------*
  Static Function GeraDados()
*----------------------------*

  cTitulo := cTitulo

  cProdIni  := mv_par01
  cProdFim  := mv_par02  
  cTipIni   := mv_par03
  cTipFim   := mv_par04
  dDataIni  := mv_par05  
  dDataFim  := mv_par06
  cArmIni   := mv_par07
  cArmFim   := mv_par08   
  cGrpIni   := mv_par09 
  cGrpFim   := mv_par10
  cSemSaldo := mv_par11  

  If Empty(cArmIni) .Or. Empty(cArmFim)
     MsgAlert("O Armazem deve ser informado","Atenção")
     Return .F.
  EndIf

  MontaQry()                       

  If TRB->(Eof())
    MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
    TRB->(DbCloseArea())   
    WORK->(DbCloseArea())
    Return .F. 
  EndIf  

  lin += 100

TRB->(dbGoTop())

Do while TRB->(!Eof()) 

   RecLock("Work",.T.)
   
   SB1->(DbSetOrder(1))
   If SB1->(DbSeek(xFilial("SB1")+TRB->B2_COD))
      If !Empty(cGrpIni) .And. !Empty(cGrpFim) 
         If  !(Alltrim(SB1->B1_GRUPO) > Alltrim(cGrpIni)  .And. Alltrim(SB1->B1_GRUPO) < Alltrim(cGrpFim))
            TRB->(DbSkip())
      	    loop	
         EndIf   	    
      EndIf  
      If !Empty(cTipIni) .And. !Empty(cTipFim) 
         If  !(Alltrim(SB1->B1_TIPO) > Alltrim(cTipIni)  .And. Alltrim(SB1->B1_TIPO) < Alltrim(cTipFim))
            TRB->(DbSkip())
      	    loop	
         EndIf   	    
      EndIf        
   EndIf


  cTipIni   := mv_par03
  cTipFim   := mv_par04
  dDataIni  := mv_par05  
  dDataFim  := mv_par06
  cArmIni   := mv_par07
  cArmFim   := mv_par08   
  cGrpIni   := mv_par09 
  cGrpFim   := mv_par10   
   
   Work->CODPROD:=TRB->B2_COD 
   
   SB9->(DbSetOrder(1))
   If SB9->(DbSeek(xFilial("SB9")+TRB->B2_COD+TRB->B2_LOCAL))
      While SB9->(!EOF()) .And.  TRB->B2_COD+TRB->B2_LOCAL ==  SB9->B9_COD+SB9->B9_LOCAL 
         IF !Empty(SB9->B9_DATA)                   
            // pega o fechamento de acordo com a data
            If SubStr(dTos(SB9->B9_DATA),1,6)  $ SubStr(dTos(dDataFim),1,6)    
               Work->PRCUNI  := SB9->B9_VINI1 / SB9->B9_QINI   
               Work->TOTAL   := SB9->B9_VINI1 
               Work->DDATA   := Alltrim(DTOC(SB9->B9_DATA))  
               Exit  
            Else // Caso contrario pega o ultimo fechamento
               Work->PRCUNI  := SB9->B9_VINI1 / SB9->B9_QINI 
               Work->TOTAL   := SB9->B9_VINI1 
               Work->DDATA   := Alltrim(DTOC(SB9->B9_DATA))  
            EndIf
         EndIf 
         SB9->(DbSkip())
      EndDo  
   Else
      Work->PRCUNI :=TRB->B2_CM1
      Work->TOTAL  :=TRB->B2_VATU1 
      Work->DDATA   := Alltrim(DTOC(dDataFim)) 
   EndIf               
   
   SB1->(DbSetOrder(1))
   If SB1->(DbSeek(xFilial("SB1")+TRB->B2_COD))
      Work->DESPROD:=SB1->B1_DESC
      Work->TIPO   :=SB1->B1_TIPO
   EndIf
   
   Work->ARMAZEM:= TRB->B2_LOCAL
   Work->QTD    := TRB->B2_QATU 
   Work->TOTAL  := Work->QTD * Work->PRCUNI    
    
	//JVR - 16/01/2012
	If !EMPTY(TRB->D1_EMISSAO)
		If !EMPTY(TRB->D2_EMISSAO)
			If TRB->D1_EMISSAO > TRB->D2_EMISSAO
				Work->TIPOMOV := "S"
				Work->DATAMOV := Alltrim(DTOC(TRB->D1_EMISSAO))
			Else
				Work->TIPOMOV := "E"
				Work->DATAMOV := Alltrim(DTOC(TRB->D2_EMISSAO))
			EndIf
		Else
			Work->TIPOMOV := "S"
			Work->DATAMOV := Alltrim(DTOC(TRB->D1_EMISSAO))		
		EndIf
	ElseIf !EMPTY(TRB->D2_EMISSAO) 
		Work->TIPOMOV := "E"
		Work->DATAMOV := Alltrim(DTOC(TRB->D2_EMISSAO))
	EndIf

   Work->(MsUnlock()) 

   TRB->(dbskip())    
   
EndDo  


  Work->(dbGoTop())       

  Do while Work->(!Eof()) 

     SomaLin() 
   
     @ lin,001 PSAY Work->CODPROD
     @ lin,018 PSAY Work->DESPROD
     @ lin,050 PSAY Work->ARMAZEM
     @ lin,060 PSAY Work->TIPO
     @ lin,072 PSAY Work->QTD     Picture  "@E 99,999,999.99" 
     @ lin,096 PSAY Work->PRCUNI  Picture  "@E 99,999,999.9999" 
     @ lin,133 PSAY Work->TOTAL   Picture  "@E 99,999,999.99"  
     @ lin,166 PSAY CTOD(work->DDATA) 
     @ lin,192 PSAY work->TIPOMOV
     @ lin,204 PSAY CTOD(work->DATAMOV)      

     nTotUni += Work->PRCUNI
     nTotal  += Work->TOTAL
    
     Work->(dbskip())

  EndDo  
  
  SomaLin()  
  SomaLin()
       
  @ lin,000 PSAY replicate("_",220)    

  SomaLin() 
  SomaLin()   
 
  @ lin,000 PSAY "TOTAIS"
  @ lin,100 PSAY nTotUni  Picture "@E 99,999,999.99"  
  @ lin,139  PSAY nTotal  Picture "@E 99,999,999.99" 

  SomaLin()  
 
  @ lin,000 PSAY replicate("_",220)                          
 
  Roda(nCntImpr,cRodaTxt,cTamanho)  

  DbCloseArea("WORK") 

  If mv_par12==2     

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

  Erase &cNome+".DBF"


Return                      

           
*----------------------------*
  Static Function Somalin()
*----------------------------*

   lin := lin + 1
   
   if lin > 58
       cabec(ctitulo,cabec1,cabec2,wnrel,cTamanho,nTipo)
       lin := 8
   endif

Return(nil)      


*----------------------------*
Static Function MontaQry()
*----------------------------* 
Local i
Local cFil    := xFilial("SB2")
Local cCposSB2:= ""

aStruSB2:= SB2->(DbStruct())         

For i:=1 to Len(aStruSB2)
	cCposSB2 += aStruSB2[i][1] + ","
Next i                            
cCposSB2 := SUBSTR(cCposSB2, 1, Len(cCposSB2)-1)//Retira a ultima virgula.

cQuery := "SELECT MAX(D1.D1_EMISSAO) As D1_EMISSAO,MAX(D2.D2_EMISSAO) As D2_EMISSAO,"
cQuery += cCposSB2
cQuery += " FROM " + RetSqlName("SB2") + " B2"
cQuery += " LEFT JOIN " + RetSqlName("SD1") + " D1 ON D1_COD=B2.B2_COD AND D1.D_E_L_E_T_<>'*'"
cQuery += " LEFT JOIN " + RetSqlName("SD2") + " D2 ON D2_COD=B2.B2_COD AND D2.D_E_L_E_T_<>'*'"
cQuery += " WHERE B2.D_E_L_E_T_ <> '*' AND B2.B2_FILIAL = '" + cFil + "'"
If cSemSaldo == 2
	cQuery += " AND B2.B2_QATU <> 0 "
ElseIf cSemSaldo == 1
	cQuery += " AND B2.B2_QATU = 0 "   
EndIf    
cQuery += " AND B2.B2_LOCAL>='" + cArmIni + "'"
cQuery += " AND B2.B2_LOCAL<='" + cArmFim + "'"
cQuery += " AND B2.B2_COD>='" + cProdIni + "'"
cQuery += " AND B2.B2_COD<='" + cProdFim + "'"
cQuery += " AND (B2.B2_COD NOT IN (Select D1_COD From " + RetSqlName("SD1") + " Where D_E_L_E_T_<>'*' and D1_COD=B2.B2_COD and D1_EMISSAO >'" + dTos(dDataIni) + "' and D1_EMISSAO < '" + dTos(dDataFim) + "' group by D1_COD))"
cQuery += " AND (B2.B2_COD NOT IN (Select D2_COD From " + RetSqlName("SD2") + " Where D_E_L_E_T_<>'*' and D2_COD=B2.B2_COD and D2_EMISSAO >'" + dTos(dDataIni) + "' and D2_EMISSAO < '" + dTos(dDataFim) + "' group by D2_COD))"
//cQuery += " AND (B2.B2_COD NOT IN (Select D3_COD From " + RetSqlName("SD3") + " Where D_E_L_E_T_<>'*' and D3_COD=B2.B2_COD and D3_EMISSAO >'" + dTos(dDataIni) + "' and D3_EMISSAO < '" + dTos(dDataFim) + "' group by D3_COD))"
cQuery += " Group by "
cQuery += cCposSB2
cQuery += " Order BY B2.B2_COD,B2.B2_LOCAL"

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)

//Forçar atualização dos campos datas, que não possuem uma estrutura fisica em tabela.                  
TcSetField("TRB","D1_EMISSAO","D",,)
TcSetField("TRB","D2_EMISSAO","D",,)

For nI := 1 To Len(aStruSB2)
	If aStruSB2[nI][2] <> "C" .and.  FieldPos(aStruSB2[nI][1]) > 0
		TcSetField("TRB",aStruSB2[nI][1],aStruSB2[nI][2],aStruSB2[nI][3],aStruSB2[nI][4])
	EndIf
Next nI


Return .T.

*-----------------------------*
  Static Function CriaPerg()
*-----------------------------*

i:=j:=0
aRegistros:={}
       
SX1->(DbSetOrder(1))
lSX1:= SX1->(DbSeek(IncSpace("PRYOR01", Len(X1_GRUPO),.F.)+"01"))

IF !lSX1

   AADD(aRegistros,{cPerg,"01","Do Produto ?	          ","","","mv_ch1","C",15,00,00,"G","","mv_par01",""  ,"","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
   AADD(aRegistros,{cPerg,"02","Ate o Produto ?          ","","","mv_ch2","C",15,00,00,"G","","mv_par02",""   ,"","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","",""})
   AADD(aRegistros,{cPerg,"03","Do tipo ?                ","","","mv_ch3","C",02,00,00,"G","","mv_par03",""   ,"","","","","","","","","","","","","","","","","","","","","","","","02" ,"","","","",""})
   AADD(aRegistros,{cPerg,"04","Ate o Tipo ?             ","","","mv_ch4","C",02,00,00,"G","","mv_par04",""   ,"","","","","","","","","","","","","","","","","","","","","","","","02" ,"","","","",""})
   AADD(aRegistros,{cPerg,"05","Do Periodo ?             ","","","mv_ch5","D",08,00,00,"G","","mv_par05",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
   AADD(aRegistros,{cPerg,"06","Ate o Periodo ?      	  ","","","mv_ch6","D",08,00,00,"G","","mv_par06",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""  ,"","","","",""})
   AADD(aRegistros,{cPerg,"07","Do Armazem ?             ","","","mv_ch7","C",02,00,00,"G","","mv_par07",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
   AADD(aRegistros,{cPerg,"08","Ate Armazem ?            ","","","mv_ch8","C",02,00,00,"G","","mv_par08",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
   AADD(aRegistros,{cPerg,"09","Do Grupo ?               ","","","mv_ch9","C",04,00,00,"G","","mv_par09",""   ,"","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
   AADD(aRegistros,{cPerg,"10","Ate Grupo ?              ","","","mv_cha","C",04,00,00,"G","","mv_par10",""   ,"","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","",""})
   AADD(aRegistros,{cPerg,"11","Gera produtos com Saldo ?","","","mv_chb","N",01,00,00,"C","","mv_par11","Nao","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
   AADD(aRegistros,{cPerg,"12","Gera excel              ?","","","mv_chc","N",01,00,00,"C","","mv_par12","Nao","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","","","",""})
   

   For i := 1 to Len(aRegistros)
      If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
         While !RecLock("SX1",.T.)
		 End
		 For j:=1 to FCount()
            FieldPut(j,aRegistros[i,j])
		 Next
	     MsUnlock()
	  Endif
   Next i
   
EndIf

Return