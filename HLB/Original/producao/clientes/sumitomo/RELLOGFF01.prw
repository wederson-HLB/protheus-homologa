#include "rwmake.ch"        
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF       


/*
Funcao      : RELLOGFF01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão relatório de Faturamento
Autor     	: Adriane Sayuri Kamiya 	
Data     	: 01/06/2010
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.
*/
 
*----------------------------*
  User Function RELLOGFF01()      
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
                

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=220
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 100
cTitulo :="Relatorio de Logística - Sumitomo"
cDesc1 :="Relatorio de Logística - Sumitomo"
cDesc2 :=""
cDesc3 :=""
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
aReturn:= { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
aLinha   := {}
nomeprog :="RELLOGFF01"
nLastKey := 0
cPerg    :="RELLOGFF01"
nPagina  := 1
nivel    := 1  
wnrel    :="RELLOGFF01"  

If Select("WORK") > 0
   Work->(DbCloseArea())
EndIf  


aCampos := {   {"ARM"       ,"C",02,0 },;
               {"DIVISAO"   ,"C",25,0 },;
               {"CODCLI"    ,"C",06,0 },;
               {"LOJACLI"   ,"C",02,0 },;
               {"NOMECLI"   ,"C",50,0 },;
               {"CFOP"      ,"C",05,0 },;
               {"SERIE"     ,"C",03,0 },;
               {"NF"        ,"C",09,0 },; 
               {"EMISSAO"   ,"C",10,0 },;
               {"PRODUTO"   ,"C",15,0 },;
               {"NOMEPROD"  ,"C",30,0 },;   
               {"LOTE"      ,"C",10,0 },;  
               {"QUANTIDADE","N",12,3 },;
               {"UNIDADE"   ,"C",02,0 },;
               {"PESOLIQ"   ,"N",11,4 },;               
               {"PESOBRU"   ,"N",11,4 },;               
               {"VLUNIT"    ,"N",14,2 },; 
               {"VLUNITUS"  ,"N",14,2 },;
               {"VLTOTAL"   ,"N",14,2 },; 
               {"VLTOTALUS" ,"N",14,2 },;
               {"VLRICMS"   ,"N",14,2 },;
               {"PIS"       ,"N",14,2 },;
               {"COFINS"    ,"N",14,2 },;
               {"CLASFIS"   ,"C",10,0 },;              
               {"NATUREZA"  ,"C",20,2 },;
               {"CCUSTO"    ,"C",09,2 },;               
               {"VLLIQUI"   ,"N",14,2 },;
               {"CUSTO"     ,"N",TamSX3("D2_CUSTO1")[1],2 },; //MSM - 15/07/2013 - Deixando dinâmico pois estava dando erro devido a mudança de tamanho do campo.
               {"CIDADE"    ,"C",30,0 },;
               {"UF"        ,"C",02,0 },; 
               {"SUMITOMO"  ,"C",10,2 },;
               {"MES"       ,"C",02,0 },;
               {"TRANSPORT" ,"C",40,2 },;
               {"VLFRETE"   ,"N",14,2 },;
               {"TPFRETE"   ,"C",03,0 }}
               
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

QRB->(DbGoTop())
                  
If QRB->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  QRB->(DbCloseArea())
  WORK->(DbCloseArea())
  Return .F.
EndIf 

DbSelectArea("SE1")
SE1->(DbSetOrder(2)) 
DbSelectArea("CTT")
CTT->(DbSetOrder(1))
DbSelectArea("SA4")
SA4->(DbSetOrder(1))

  
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
   Work->NOMECLI    := QRB->A1_NOME
   Work->CFOP       := QRB->D2_CF  
   Work->SERIE      := QRB->D2_SERIE
   Work->NF         := QRB->D2_DOC
   Work->EMISSAO    := Alltrim(DTOC(QRB->D2_EMISSAO))
   Work->PRODUTO    := QRB->D2_COD
   Work->NOMEPROD   := QRB->B1_DESC
   Work->LOTE       := QRB->D2_LOTECTL   
   Work->QUANTIDADE := QRB->D2_QUANT
   Work->UNIDADE    := QRB->D2_UM     
   Work->PESOLIQ    := QRB->B1_PESO
   Work->PESOBRU    := QRB->B1_PESBRU  
   Work->VLUNIT     := QRB->D2_PRUNIT 
   If SM2->(DbSeek(QRB->D2_EMISSAO))  
      Work->VLUNITUS   := QRB->D2_PRUNIT  / SM2->M2_MOEDA2
   EndIf
   Work->VLTOTAL    := (QRB->D2_PRUNIT * QRB->D2_QUANT  ) 
   If SM2->(DbSeek(QRB->D2_EMISSAO))  
      Work->VLTOTALUS  := (QRB->D2_PRUNIT * QRB->D2_QUANT ) / SM2->M2_MOEDA2
   EndIf
   Work->VLRICMS    := QRB->D2_VALICM
   Work->PIS        := QRB->D2_VALIMP5
   Work->COFINS     := QRB->D2_VALIMP6
   Work->CLASFIS    := QRB->B1_POSIPI
   Work->NATUREZA   := QRB->F4_TEXTO  
   Work->CCUSTO     := QRB->D2_CCUSTO
   Work->VLLIQUI    := (QRB->D2_PRUNIT /  QRB->C5_TXMOEDA ) * QRB->D2_QUANT
   Work->CUSTO      := QRB->D2_CUSTO1
   Work->CIDADE     := QRB->A1_MUN
   Work->UF         := QRB->A1_EST 
   Work->ARM        := QRB->D2_LOCAL

   If QRB->D2_FILIAL $ '03'
      Work->SUMITOMO   := "FILIAL"
   Else
      Work->SUMITOMO   := "MATRIZ"
   EndIf     
      
   Work->MES    := Alltrim(STR(MONTH(QRB->D2_EMISSAO)))
      
   If !EMPTY(QRB->C5_TRANSP)
      If SA4->(DBSEEK(XFILIAL("SA4")+QRB->C5_TRANSP))
         Work->TRANSPORT  := Alltrim(SA4->A4_NOME)
      EndIf
   Else
      Work->TRANSPORT  := ""
   EndIf
   
   Work->VLFRETE    := QRB->C5_FRETE

   If QRB->C5_TPFRETE $ 'C'
      Work->TPFRETE    :=  "CIF"
   ElseIf QRB->C5_TPFRETE $ 'F'
      Work->TPFRETE    :=  "FOB"
   Else 
      Work->TPFRETE    :=  "   "   
   EndIf
   Work->(MsUnLock())    
   QRB->(DbSkip())       
      
EndDo     
                                        
                   
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
   @ lin,130 PSAY Work->LOTE
   @ lin,142 PSAY Work->UNIDADE
   @ lin,148 PSAY Work->PESOLIQ
   @ lin,156 PSAY Work->PESOBRU
   @ lin,165 PSAY Work->CLASFIS         //picture    "@E 999.999.999"
   @ lin,176 PSAY Work->QUANTIDADE      picture    "@E 99999999.99"
   @ lin,182 PSAY Work->VLUNIT          picture    "@E 999,999,999.99"
   If nExcel = 1
     @ lin,189 PSAY Work->VLUNITUS        picture    "@E 999,999,999.99" 
   EndIf
   @ lin,200 PSAY Work->VLTOTAL         picture    "@E 999,999,999.99"
   If nExcel = 1
      @ lin,207 PSAY Work->VLTOTALUS       picture    "@E 999,999,999.99" 
   EndIf
   If nExcel = 1
      @ lin,220 PSAY Work->VLRICMS         picture    "@E 999,999,999.99"      
      @ lin,230 PSAY Work->PIS             picture    "@E 999,999,999.99"
      @ lin,187 PSAY Work->COFINS          picture    "@E 999,999,999.99"
      @ lin,210 PSAY Work->NATUREZA
      @ lin,210 PSAY Work->CCUSTO
      @ lin,220 PSAY Work->VLLIQUI         picture    "@E 999,999,999.99"
      @ lin,230 PSAY Work->CUSTO           picture    "@E 999,999,999.99"
      @ lin,240 PSAY Work->CIDADE
      @ lin,250 PSAY Work->UF
      @ lin,260 PSAY Work->SUMITOMO
      @ lin,300 PSAY Work->MES
      @ lin,310 PSAY Work->TRANSPORT
      @ lin,320 PSAY Work->VLFRETE         picture    "@E 999,999,999.99"
      @ lin,330 PSAY Work->TPFRETE
   EndIf
   
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
   
   if lin > 58
       cabec(ctitulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
       lin := 8
   endif

Return(nil)        

*----------------------------*  

  Static Function MontaQry1()
*----------------------------*

aStruSD2:= SD2->(DbStruct())      

cQuery:= "SELECT SD2.D2_FILIAL,SD2.D2_LOCAL,SD2.D2_DOC,SD2.D2_SERIE,  SD2.D2_EMISSAO, SD2.D2_PEDIDO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_TES,SD2.D2_COD,SD2.D2_QUANT, SD2.D2_LOTECTL, "  
cQuery+=" SD2.D2_UM, SD2.D2_PRUNIT, SD2.D2_TOTAL, SD2.D2_VALICM, SD2.D2_VALIMP5, SD2.D2_VALIMP6,SD2.D2_CF, SD2.D2_VALFRE,SD2.D2_CCUSTO,SD2.D2_CUSTO1, SC5.C5_TRANSP, "
cQuery+=" SC5.C5_CONDPAG, SC5.C5_VEND1, SC5.C5_TPFRETE,SC5.C5_FRETE,SC5.C5_TXMOEDA ,SB1.B1_POSIPI,SB1.B1_DESC,SF4.F4_TEXTO, SA1.A1_NOME, SA1.A1_MUN, SA1.A1_EST,"
cQuery+=" SF2.F2_DUPL, SF2.F2_PREFIXO,SB1.B1_PESO, SB1.B1_PESBRU " 
cQuery+=" FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SC5")+" SC5,"+RetSqlName("SB1")+" SB1,"+RetSqlName("SF4")+" SF4,"+RetSqlName("SA1")+" SA1,"+RetSqlName("SF2")+" SF2"
cQuery+=" WHERE SD2.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*'  AND SF4.D_E_L_E_T_ <> '*'AND SA1.D_E_L_E_T_ <> '*'AND SF2.D_E_L_E_T_ <> '*' "   
cQuery+=" and SD2.D2_PEDIDO = SC5.C5_NUM AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_TES=SF4.F4_CODIGO AND SD2.D2_CLIENTE+SD2.D2_LOJA = SA1.A1_COD+SA1.A1_LOJA"
cQuery+=" AND SD2.D2_DOC+SD2.D2_SERIE = SF2.F2_DOC+SF2.F2_SERIE  " 
cQuery+=" AND SC5.C5_FILIAL=SD2.D2_FILIAL"  

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
                                                         

cQuery	:=	ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'QRB',.F.,.T.)

For nI := 1 To Len(aStruSD2)
	If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
		TcSetField("QRB",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
	EndIf
Next nI




Return


