#include "rwmake.ch"        
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF       

/*
Funcao      : RELFINFF01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão relatório de Faturamento
Autor     	: Adriane Sayuri Kamiya 	
Data     	: 01/06/2010
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro.
*/

*----------------------------*
  User Function RELFINFF01()      
*----------------------------*      
SetPrvt("CBTXT,CBCONT,NORDEM,LIMITE,TAMANHO,NTIPO")
SetPrvt("M_PAG,LIN,CDESC1,CDESC2,CDESC3")
SetPrvt("AORD,NCNTIMPR,CRODATXT,ARETURN,ALINHA")
SetPrvt("NOMEPROG,NLASTKEY,CPERG,NPAGINA,NIVEL,CSAVSCR1")
SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1")
SetPrvt("CSTRING,CABEC1,CABEC2,WNREL,TREGS,M_MULT")
SetPrvt("P_ANT,P_ATU,P_CNT,M_SAV20,M_SAV7,QUALQUER")
SetPrvt("_CINDF2,VALMOEDA,STATNFORI,DIAVORIG") 

If !(cEmpAnt $ "FF")
   MsgAlert("Rotina não disponivel para essa empresa","Atenção")
   Return .F.
EndIf  
      
Private aCampos:={}
Private cNome,cIndex,cSting,cCabec1,cCabec2,cTitulo,cArqOrig,cArqPath
Private dDataIni,dDataFim 
Private cDocDe := cDocAte := cSerieDe := cSerieAte := cFilial := cCCusto :=  cExcel  := ''
Private nTOTQtde := nTVlUnit := nTVlUnitU := nTotal := nTotalUS := nTotIcms := nTotPIS := nTotCOFINS := nTotLiq := nTotCusto := nTotFrete := 0
//RRP - 06/02/2014 - Ajuste para as notas de Devoluções de Compras.
Private nIdenQry := 0

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=220
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 100
cTitulo :="Relatorio Financeiro - Sumitomo"
cDesc1 :="Relatorio Financeiro - Sumitomo"
cDesc2 :=""
cDesc3 :=""
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
aReturn:= { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
aLinha   := {}
nomeprog :="RELFINFF01"
nLastKey := 0
cPerg    :="RELFINFF01"
nPagina  := 1
nivel    := 1  
wnrel    :="RELFINFF01"  

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  

aCampos := {   {"DIVISAO"   ,"C",25,0 },;
               {"CODCLI"    ,"C",06,0 },;
               {"LOJACLI"   ,"C",02,0 },;
               {"NOMECLI"   ,"C",50,0 },;
               {"CFOP"      ,"C",05,0 },;
               {"SERIE"     ,"C",03,0 },;
               {"NF"        ,"C",09,0 },; 
               {"EMISSAO"   ,"C",10,0 },;
               {"PRODUTO"   ,"C",15,0 },;
               {"NOMEPROD"  ,"C",30,0 },;   
               {"QUANTIDADE","N",12,3 },;
               {"UNIDADE"   ,"C",02,0 },;
               {"VLUNIT"    ,"N",14,4 },; 
               {"VLTOTAL"   ,"N",14,2 },; 
               {"VLRICMS"   ,"N",14,2 },;
               {"PIS"       ,"N",14,2 },;
               {"COFINS"    ,"N",14,2 },;
               {"CLASFIS"   ,"C",10,0 },;              
               {"NATUREZA"  ,"C",20,2 },;
               {"CTCONTABIL","C",20,0 },;
               {"CCUSTO"    ,"C",09,2 },;               
               {"VLLIQUI"   ,"N",14,2 },;
               {"CUSTO"     ,"N",14,2 },;
               {"UF"        ,"C",02,0 },; 
               {"PISCOFINS" ,"N",14,2 },;      
               {"SUMITOMO"  ,"C",10,2 },;
               {"BPISCOFINS","N",14,2 },;
               {"NPARCELAS" ,"N", 1,0 },;
               {"VLPARC_UNI","N",14,2 },;
               {"VLPARC_A"  ,"N",14,2 },;
               {"VLPARC_B"  ,"N",14,2 },;
               {"VLPARC_C"  ,"N",14,2 },;
               {"VLPARC_D"  ,"N",14,2 },;
               {"VLPARC_E"  ,"N",14,2 },;
               {"VLPARC_F"  ,"N",14,2 },;
               {"VENCTOUNI" ,"C",10,0 },;
               {"VENCTOA"   ,"C",10,0 },;
               {"VENCTOB"   ,"C",10,0 },;
               {"VENCTOC"   ,"C",10,0 },;
               {"VENCTOD"   ,"C",10,0 },;
               {"VENCTOE"   ,"C",10,0 },;
               {"VENCTOF"   ,"C",10,0 },;
               {"PARUNICA"  ,"C",03,0 },;
               {"PRAZOA"    ,"C",03,0 },;
               {"PRAZOB"    ,"C",03,0 },;
               {"PRAZOC"    ,"C",03,0 },;
               {"PRAZOD"    ,"C",03,0 },;
               {"PRAZOE"    ,"C",03,0 },;
               {"PRAZOF"    ,"C",03,0 },;
               {"TAXASELIC" ,"N",10,8 },;                                                                  
               {"JUROSEMBUT","N",20,6 },;//RRP - 29/10/2014 - Ajuste pois 14 estava estourando o tamanho do campo.                                       
               {"PRAZOSN"   ,"C",01,0 },;                                                      
               {"MES"       ,"C",02,0 }}
               
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,"WORK",.F.,.F.)

DbSelectArea("WORK")
cIndex:=CriaTrab(Nil,.F.)
IndRegua("WORK",cIndex,"EMISSAO+NF+SERIE+PRODUTO",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------

cString  :="WORK"
cabec1   := "Divisao   Cliente   Nome Cliente                             CFOP Série  NF      Emissao  Codigo Produto                          LOTE       UM   P.Liq.  P.Bruto  Clas.Fiscal   Qtde       Vlr.Unit       Vlr.Total  "
//            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
cabec2:=""

pergunte(cPerg,.T.)

If mv_par09 = 2                    
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
Else
   RptStatus({|| GeraDados()},cTitulo)
EndIf
             
Return .T.   

*----------------------------*
Static Function GeraDados()
*----------------------------*
cTitulo := cTitulo + ", de "+dtoc(mv_par01) + " a "+dtoc(mv_par02)

dDataIni  := mv_par01
dDataFim  := mv_par02  
cDocDe    := mv_par03
cDocAte   := mv_par04
cSerieDe  := mv_par05
cSerieAte := mv_par06 
nFilial   := mv_par07  
cCCusto   := mv_par08
nExcel    := mv_par09        

MontaQry1()
MontaQry2()

Work->(DbGoTop())
If Work->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  Work->(DbCloseArea())
  Return .F.
EndIf 

lin += 100

Work->(dbGoTop())
Do while Work->(!Eof()) 

   SomaLin()             
   
   @ lin,000 PSAY Work->DIVISAO
   @ lin,011 PSAY Work->CODCLI
   @ lin,018 PSAY Work->LOJACLI
   @ lin,021 PSAY Substr(Work->NOMECLI,1,40)
   @ lin,062 PSAY Work->CFOP  
   @ lin,068 PSAY Work->SERIE
   @ lin,071 PSAY Work->NF 
   @ lin,081 PSAY CTOD(Work->EMISSAO) 
   @ lin,091 PSAY Work->PRODUTO
   @ lin,098 PSAY Work->NOMEPROD
   @ lin,142 PSAY Work->UNIDADE
   @ lin,176 PSAY Work->QUANTIDADE      picture    "@E 999999999.99"
   @ lin,182 PSAY Work->VLUNIT          picture    "@E 999,999,999.99"
   @ lin,200 PSAY Work->VLTOTAL         picture    "@E 999,999,999.99"
     
   nTOTQtde  +=Work->QUANTIDADE
   nTVlUnit  +=Work->VLUNIT
   nTotal    +=Work->VLTOTAL

   Work->(dbskip())

EndDo  
 
 SomaLin()  
 SomaLin()
@ lin,000 PSAY replicate("_",220)    
 SomaLin() 
 SomaLin()   
 
@ lin,000 PSAY "TOTAIS"
@ lin,170 PSAY nTOTQtde  picture    "@E 99,999,999.99"
@ lin,183 PSAY nTVlUnit  picture    "@E 999,999,999.99"
@ lin,200 PSAY nTotal    picture    "@E 99,999,999.99"

 SomaLin()  
 
@ lin,000 PSAY replicate("_",220)                          
 
Roda(nCntImpr,cRodaTxt,Tamanho)  

dbSelectArea("WORK")
DbCloseArea("WORK") 

If mv_par09 = 1     
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
EndIf

//dbSelectArea("QRB")
//DbCloseArea("QRB") 
Erase &cNome+".DBF"

Return

*-----------------------*
Static Function GravaWork()
*-----------------------*
DbSelectArea("CTT")
CTT->(DbSetOrder(1))
DBSELECTAREA("SZ1")
SZ1->(DbSetOrder(1))
DbSelectArea("SE1")
SE1->(DbSetOrder(2))
//RRP - 06/02/2014 - Ajuste para as notas de Devoluções de Compras.
DbSelectArea("SA2")
SA2->(DbSetOrder(1))

Do while QRB->(!Eof())  
   RecLock("Work",.T.)           
   If !EMPTY(QRB->D2_CCUSTO) 
      If CTT->(DBSEEK(XFILIAL("CTT")+QRB->D2_CCUSTO))
         Work->DIVISAO    := Alltrim(CTT->CTT_DESC01)
      EndIf   
   Else 
      Work->DIVISAO    := ""
   EndIf
  
   Work->CODCLI     := Alltrim(QRB->D2_CLIENTE)
   Work->LOJACLI    := Alltrim(QRB->D2_LOJA)
   //RRP - 06/02/2014 - Ajuste para as notas de Devoluções de Compras.
   If QRB->D2_TIPO == "D" .And. nIdenQry == 1  
   		If SA2->(DbSeek(xFilial("SA2")+QRB->D2_CLIENTE+QRB->D2_LOJA))
			Work->NOMECLI    := SA2->A2_NOME 
	   		Work->UF         := SA2->A2_EST
	  	EndIf
   Else 
		Work->NOMECLI    := QRB->A1_NOME
		Work->UF         := QRB->A1_EST
   EndIf
   Work->CFOP       := QRB->D2_CF  
   Work->SERIE      := QRB->D2_SERIE
   Work->NF         := QRB->D2_DOC
   Work->EMISSAO    := Alltrim(DTOC(QRB->D2_EMISSAO))
   Work->PRODUTO    := QRB->D2_COD
   Work->NOMEPROD   := QRB->B1_DESC
   Work->QUANTIDADE := QRB->D2_QUANT
   Work->UNIDADE    := QRB->D2_UM     
   Work->VLUNIT     := QRB->D2_PRUNIT 
   Work->VLTOTAL    := QRB->D2_PRUNIT * QRB->D2_QUANT 
   Work->VLRICMS    := QRB->D2_VALICM
   Work->PIS        := QRB->D2_VALIMP6
   Work->COFINS     := QRB->D2_VALIMP5
   Work->CLASFIS    := QRB->B1_POSIPI
   Work->NATUREZA   := QRB->F4_TEXTO 
   Work->CTCONTABIL := QRB->B1_CONTA
   Work->CCUSTO     := QRB->D2_CCUSTO
   Work->VLLIQUI    := ((QRB->D2_PRUNIT * QRB->D2_QUANT  ) - QRB->D2_VALICM - QRB->D2_VALIMP5 - QRB->D2_VALIMP6) 
   Work->CUSTO      := QRB->D2_CUSTO1
   //Work->UF         := QRB->A1_EST
   Work->PISCOFINS  := QRB->D2_VALIMP5 + QRB->D2_VALIMP6

   If QRB->D2_FILIAL $ '03'
      Work->SUMITOMO   := "FILIAL"
   Else
      Work->SUMITOMO   := "MATRIZ"
   EndIf     
   Work->BPISCOFINS    := QRB->D2_BASIMP5
   
   Work->MES    := Alltrim(STR(MONTH(QRB->D2_EMISSAO)))     
   If MONTH(QRB->D2_EMISSAO) < 10   
      Work->MES := '0'+ Work->MES
   EndIf
   
   If SZ1->(DbSeek(xFilial("SZ1") + Work->MES + '/' + Alltrim(STR(YEAR(QRB->D2_EMISSAO)))))   
      Work->TAXASELIC := SZ1->Z1_TAXA   
   EndIf

   Work->JUROSEMBUT    := 0
   //If Val(QRB->D2_ITEM) == 1
      If SE1->(DbSeek(xFilial("SE1")+QRB->D2_CLIENTE+QRB->D2_LOJA+QRB->F2_PREFIXO+QRB->F2_DUPL)) 
         Do While !SE1->(EOF()) .AND. SE1->E1_CLIENTE + SE1->E1_LOJA = QRB->D2_CLIENTE + QRB->D2_LOJA .AND. SE1->E1_NUM = QRB->F2_DUPL .AND. SE1->E1_PREFIXO = QRB->F2_PREFIXO
            If SE1->E1_TIPO = 'NF'
               If SE1->E1_VENCREA = QRB->D2_EMISSAO
                  Work->PRAZOSN := 'N'
               Else
                  Work->PRAZOSN := 'S'            
               EndIf

               If EMPTY(SE1->E1_PARCELA)
                  Work->NPARCELAS  := 1
                  Work->VENCTOUNI  := Alltrim(DTOC(SE1->E1_VENCREA))  
                  Work->VLPARC_UNI := SE1->E1_VALOR             
                  Work->PARUNICA   := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))     
                  Work->JUROSEMBUT += Work->VLPARC_UNI -(Work->VLPARC_UNI /( Work->TAXASELIC ^  (Val(Work->PARUNICA)/30) ))

               Else
                  Do Case
                  Case SE1->E1_PARCELA $ 'A'
                     Work->NPARCELAS  += 1
                     Work->VENCTOA    := Alltrim(DTOC(SE1->E1_VENCREA))
                     Work->VLPARC_A   := SE1->E1_VALOR// Work->NPARCELAS                    
                     Work->PRAZOA     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_A -(Work->VLPARC_A /( Work->TAXASELIC ^(Val(Work->PRAZOA)/30) ))
                  Case SE1->E1_PARCELA $ 'B'
                     Work->NPARCELAS  += 1
                     Work->VENCTOB    := Alltrim(DTOC(SE1->E1_VENCREA))
                     Work->VLPARC_B   := SE1->E1_VALOR// Work->NPARCELAS                           
                     Work->PRAZOB     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_B -(Work->VLPARC_B /( Work->TAXASELIC ^(Val(Work->PRAZOB)/30) ))
                  Case SE1->E1_PARCELA $ 'C'
                     Work->NPARCELAS  += 1
                     Work->VENCTOC    := Alltrim(DTOC(SE1->E1_VENCREA))            
                     Work->VLPARC_C   := SE1->E1_VALOR// Work->NPARCELAS                                 
                     Work->PRAZOC     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_C -(Work->VLPARC_C /( Work->TAXASELIC ^(Val(Work->PRAZOC)/30 ) ))
                  Case SE1->E1_PARCELA $ 'D'
                     Work->NPARCELAS  += 1
                     Work->VENCTOD    := Alltrim(DTOC(SE1->E1_VENCREA))              
                     Work->VLPARC_D   := SE1->E1_VALOR// Work->NPARCELAS                             
                     Work->PRAZOD     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_D -(Work->VLPARC_D /( Work->TAXASELIC ^ (Val(Work->PRAZOD)/30) ))
                  Case SE1->E1_PARCELA $ 'E'
                     Work->NPARCELAS  += 1
                     Work->VENCTOE    := Alltrim(DTOC(SE1->E1_VENCREA))              
                     Work->VLPARC_E   := SE1->E1_VALOR// Work->NPARCELAS                             
                     Work->PRAZOE     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_E -(Work->VLPARC_E /( Work->TAXASELIC ^ (Val(Work->PRAZOE)/30) ))
                  Case SE1->E1_PARCELA $ 'F'
                     Work->NPARCELAS  += 1
                     Work->VENCTOF    := Alltrim(DTOC(SE1->E1_VENCREA))              
                     Work->VLPARC_F   := SE1->E1_VALOR// Work->NPARCELAS                             
                     Work->PRAZOF     := Alltrim(STR(SE1->E1_VENCREA - QRB->D2_EMISSAO ))  
                     Work->JUROSEMBUT += Work->VLPARC_F -(Work->VLPARC_F /( Work->TAXASELIC ^ (Val(Work->PRAZOF)/30) ))

                  EndCase
               EndIf
               SE1->(DbSkip())
            Else 
               SE1->(DbSkip())
            EndIf
         EndDo   
      EndIf
   //EndIf   
   Work->(MsUnLock())    
   QRB->(DbSkip())
   SA2->(DbSkip())       
EndDo  

Return .T.

*----------------------------*
Static Function Somalin()
*----------------------------*
   lin := lin + 1
   If lin > 58
       cabec(ctitulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
       lin := 8
   EndIf

Return(nil)        

*----------------------------*  
Static Function MontaQry1()
*----------------------------*
aStruSD2:= SD2->(DbStruct()) 
nIdenQry := 1     

cQuery:= "SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,  SD2.D2_EMISSAO, SD2.D2_PEDIDO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_TES,SD2.D2_COD,SD2.D2_QUANT,SD2.D2_ITEM,SD2.D2_TIPO,  "  
cQuery+=" SD2.D2_UM, SD2.D2_PRUNIT, SD2.D2_TOTAL, SD2.D2_VALICM, SD2.D2_VALIMP5, SD2.D2_VALIMP6,SD2.D2_BASIMP5,SD2.D2_CF, SD2.D2_VALFRE,SD2.D2_CCUSTO,SD2.D2_CUSTO1, "
cQuery+=" SC5.C5_CONDPAG, SB1.B1_POSIPI,SB1.B1_DESC,SF4.F4_TEXTO, SA1.A1_NOME,  SA1.A1_EST,"
cQuery+=" SF2.F2_DUPL, SF2.F2_PREFIXO, SB1.B1_CONTA " 
cQuery+=" FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SC5")+" SC5,"+RetSqlName("SB1")+" SB1,"+RetSqlName("SF4")+" SF4,"+RetSqlName("SA1")+" SA1,"+RetSqlName("SF2")+" SF2 "
cQuery+=" WHERE SD2.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*'  AND SF4.D_E_L_E_T_ <> '*'AND SA1.D_E_L_E_T_ <> '*'AND SF2.D_E_L_E_T_ <> '*' "   
cQuery+=" and SD2.D2_PEDIDO = SC5.C5_NUM AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_TES=SF4.F4_CODIGO AND SD2.D2_CLIENTE+SD2.D2_LOJA = SA1.A1_COD+SA1.A1_LOJA "
cQuery+=" AND SD2.D2_DOC+SD2.D2_SERIE = SF2.F2_DOC+SF2.F2_SERIE  AND SD2.D2_FILIAL = SC5.C5_FILIAL " 

If !empty(dDataIni) .Or. !empty(dDataFim)
   cQuery+=" AND SD2.D2_EMISSAO >= '"+Dtos(dDataIni)+"'"+Chr(10)     
   cQuery+=" AND SD2.D2_EMISSAO <= '"+Dtos(dDataFim)+"'"+Chr(10) 
EndIf

If !empty(cDocDe) .Or. !empty(cDocAte)
   cQuery+=" AND SD2.D2_DOC >= '"+Alltrim(cDocDe)+"'"+Chr(10)     
   cQuery+=" AND SD2.D2_DOC <= '"+Alltrim(cDocAte)+"'"+Chr(10) 
EndIf

If !empty(cSerieDe) .Or. !empty(cSerieAte)
   cQuery+=" AND SD2.D2_SERIE >= '"+Alltrim(cSerieDe)+"'"+Chr(10)     
   cQuery+=" AND SD2.D2_SERIE <= '"+Alltrim(cSerieAte)+"'"+Chr(10) 
EndIf

If nFilial < 3            
   If nFilial = 1
      cQuery+=" AND SD2.D2_FILIAL <>'03'"
   Else                                  
      cQuery+=" AND SD2.D2_FILIAL = '03'"
   EndIf
EndIf

If !EMPTY(cCCusto)
   cQuery+=" AND SD2.D2_CCUSTO ='"+Alltrim(cCCusto)+"'"
EndIf
cQuery+=" Order by SD2.D2_EMISSAO+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_ITEM"

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

For nI := 1 To Len(aStruSD2)
	If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
		TcSetField("QRB",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
	EndIf
Next nI

GravaWork()
QRB->(DbCloseArea())
Return

*----------------------------*  
Static Function MontaQry2()
*----------------------------*
aStruSD2:= SD2->(DbStruct()) //Mantem como SD2 pois todos os campos foram renomeados para SD2 atraves da QUERY..           
nIdenQry := 2

cQuery:=" SELECT SD1.D1_FILIAL as D2_FILIAL,SD1.D1_TIPO as D2_TIPO,SD1.D1_DOC as D2_DOC,SD1.D1_SERIE as D2_SERIE, SD1.D1_DTDIGIT as D2_EMISSAO,"
cQuery+=" SD1.D1_PEDIDO as D2_PEDIDO,SD1.D1_FORNECE as D2_CLIENTE, SD1.D1_LOJA as D2_LOJA, SD1.D1_TES as D2_TES,SD1.D1_COD as D2_COD,"
cQuery+=" (SD1.D1_QUANT*(-1)) as D2_QUANT,SD1.D1_CUSTO as D2_P_CUSTO,SD1.D1_UM as D2_UM, SD1.D1_VUNIT as D2_PRUNIT, SD1.D1_TOTAL as D2_TOTAL,"
cQuery+=" (SD1.D1_VALICM*(-1)) as D2_VALICM, SD1.D1_VALIMP5 as D2_VALIMP5,SD1.D1_VALIMP6 as D2_VALIMP6,SD1.D1_CF as D2_CF, SD1.D1_VALFRE as D2_VALFRE,"
cQuery+=" SD1.D1_CC as D2_CCUSTO,SD1.D1_CUSTO as D2_CUSTO1,SD1.D1_LOCAL as D2_LOCAL,D1_BASIMP5 as D2_BASIMP5,"
cQuery+=" SF1.F1_TRANSP as C5_TRANSP, SF1.F1_COND as C5_CONDPAG, SF1.F1_MOEDA as C5_MOEDA, SF1.F1_TPFRETE as C5_TPFRETE, SF1.F1_FRETE as C5_FRETE,"
cQuery+=" SB1.B1_DESC,SB1.B1_POSIPI,SB1.B1_CONTA,"
cQuery+=" SF4.F4_TEXTO,"
cQuery+=" SA1.A1_NOME, SA1.A1_MUN, SA1.A1_EST,"
cQuery+=" SF1.F1_DUPL as F2_DUPL, SF1.F1_PREFIXO as F2_PREFIXO"
cQuery+=" FROM "+RetSqlName("SD1")+" SD1,"+RetSqlName("SB1")+" SB1,"+RetSqlName("SF4")+" SF4,"+RetSqlName("SA1")+" SA1,"+RetSqlName("SF1")+" SF1 "
cQuery+=" WHERE SD1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*'  AND SF4.D_E_L_E_T_ <> '*'AND SA1.D_E_L_E_T_ <> '*'AND SF1.D_E_L_E_T_ <> '*'"   
cQuery+="	AND SD1.D1_COD					= SB1.B1_COD
cQuery+="	AND SD1.D1_TES					= SF4.F4_CODIGO
cQuery+=" 	AND SD1.D1_FORNECE+SD1.D1_LOJA	= SA1.A1_COD+SA1.A1_LOJA
cQuery+=" 	AND SD1.D1_DOC+SD1.D1_SERIE		= SF1.F1_DOC+SF1.F1_SERIE
cQuery+=" 	AND SD1.D1_TIPO					= 'D' " 

If !empty(dDataIni) .Or. !empty(dDataFim)
	cQuery += " AND SD1.D1_EMISSAO >= '"+Dtos(dDataIni)+"' "
	cQuery += " AND SD1.D1_EMISSAO <= '"+Dtos(dDataFim)+"' "
EndIf
If !empty(cDocDe) .Or. !empty(cDocAte)
	cQuery += " AND SD1.D1_DOC >= '"+Alltrim(cDocDe)+ "' "
	cQuery += " AND SD1.D1_DOC <= '"+Alltrim(cDocAte)+"' "
EndIf
If !empty(cSerieDe) .Or. !empty(cSerieAte)
	cQuery += " AND SD1.D1_SERIE >= '"+Alltrim(cSerieDe)+ "' "
	cQuery += " AND SD1.D1_SERIE <= '"+Alltrim(cSerieAte)+"' "
EndIf
If nFilial < 3            
	If nFilial = 1
		cQuery+=" AND SD1.D1_FILIAL <>'03' "
	Else                                  
		cQuery+=" AND SD1.D1_FILIAL = '03' "
	EndIf
EndIf
If !EMPTY(cCCusto)
	cQuery+=" AND SD1.D1_CC ='"+Alltrim(cCCusto)+"' "
EndIf
cQuery+="  ORDER BY SD1.D1_EMISSAO+SD1.D1_DOC+SD1.D1_SERIE+SD1.D1_COD"

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

For nI := 1 To Len(aStruSD2)
	If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
		TcSetField("QRB",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
	EndIf
Next nI
GravaWork()
QRB->(DbCloseArea())

Return