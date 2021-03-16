#include "rwmake.ch"        
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF  


/*
Funcao      : REDFAT01
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Emissใo do Relatorio de Vendas por Produto
Autor     	: XIS INFORMATICA
Data     	: 16/04/04  
Obs         : 
TDN         :
Revisใo     : Tiago Luiz Mendon็a 
Data/Hora   : 17/07/2012
M๓dulo      : Faturamento
Cliente     : Okuma
*/ 

*------------------------*
 User Function REDFAT01() 
*------------------------*       

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis utilizadas no programa atraves da funcao    ณ
//ณ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ณ
//ณ identificando as variaveis publicas do sistema utilizadas no codigo ณ
//ณ Incluido pelo assistente de conversao do AP5 IDE                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetPrvt("CBTXT,CBCONT,NORDEM,LIMITE,TAMANHO,NTIPO")
SetPrvt("M_PAG,LIN,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("AORD,NCNTIMPR,CRODATXT,WCABEC,ARETURN,ALINHA")
SetPrvt("NOMEPROG,NLASTKEY,CPERG,NPAGINA,NIVEL,CSAVSCR1")
SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,_ACAMPOS,_CNOME")
SetPrvt("CSTRING,CABEC1,CABEC2,WNREL,TREGS,M_MULT")
SetPrvt("P_ANT,P_ATU,P_CNT,M_SAV20,M_SAV7,QUALQUER")
SetPrvt("_CINDF2,_DATAINI,_DATAFIM,VALMOEDA,STATNFORI,DIAVORIG")
SetPrvt("WCUSTO,AC_QUANT,AC_MERC_R,AC_ICMS_R,AC_IPI_R,AC_PIS_R")
SetPrvt("AC_COFIN_R,AC_CUSTO_R,AC_MERC_U,AC_ICMS_U,AC_IPI_U,AC_PIS_U")
SetPrvt("AC_COFIN_U,AC_CUSTO_U,")
SetPrvt("cCondicao2, cCondicao3, cCondicao4, cCondicao5, cArqTrb1, cArqTrd21, cArqTrd22, cArqTrd1")





/*/
----------+-------------------------------------------------------------
Programa  |ณREDFAT01    | Autor | XIS INFORMATICA | Data | 16.04.04
----------|-------------------------------------------------------------
Descri…o |Emisso do Relatorio de Vendas por Produto.
----------|-------------------------------------------------------------
 Uso      | OKUMA
----------+-------------------------------------------------------------
/*/
//--------------------------------------------------------------
// Define Variaveis
//--------------------------------------------------------------
#IFNDEF WINDOWS
// Movido para o inicio do arquivo ==>     #DEFINE PSAY SAY
#ENDIF

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=205
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 100
titulo :="Vendas e Devolucoes por Produto"
cDesc1 :="Relatorio de Vendas no perกodo, detalhando IPI, ICMS, COFINS e ,"
cDesc2 :="PIS, em Reais e Dolares, por Centro de Custo e por Produto."
cDesc3 :="                                       "
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
wcabec := .t.
nIndB1 := nIndD1 := nIndD2 := 0 


//--------------------------------------------------------------
// Variaveis padrao de todos os relatorios
//--------------------------------------------------------------
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

aLinha   := {}
//nomeprog :="ADV012"
nomeprog :="REDFAT01"
nLastKey := 0
cPerg    :="REDF01    "
nPagina  := 1
nivel    := 1

//--------------------------------------------------------------
// Salva a Integridade dos dados de Entrada
//--------------------------------------------------------------
#IFNDEF WINDOWS
   cSavScr1 := SaveScreen(3,0,24,79)
   cSavCur1 := SetCursor(0)
   cSavRow1 := ROW()
   cSavCol1 := COL()
   cSavCor1 := SetColor("bg+/b,,,")
#ENDIF
_aCampos := {  {"CCUSTO", "C",10,0 } ,;
               {"CODIGO", "C",25,0 } ,;
               {"EMISSAO","D",8,0 }  ,;
               {"QUANT",  "N",12,0 } ,;
               {"MERC_R", "N",12,2 } ,;
               {"ICMS_R" ,"N",12,2 } ,;
               {"IPI_R"  ,"N",12,2 } ,;
               {"PIS_R"  ,"N",12,2 } ,;
               {"COFIN_R","N",12,2 } ,;
               {"CUSTO_R","N",12,2 } ,;
               {"MERC_U", "N",12,2 } ,;
               {"ICMS_U", "N",12,2 } ,;
               {"IPI_U" , "N",12,2 } ,;
               {"PIS_U" , "N",12,2 } ,;
               {"COFIN_U","N",12,2 } ,;
               {"CUSTO_U","N",12,2 } ,;
               {"COT_USS" ,"N",12,4 } }
_cNome := CriaTrab(_aCampos,.t.)
dbUseArea(.T.,, _cNome,"XXX",.F.,.F.)


DbSelectArea("XXX")
_cIndex:=CriaTrab(Nil,.F.)
IndRegua("XXX",_cIndex,"CCUSTO+CODIGO+DTOS(EMISSAO)",,,"Selecionando Registro...")
//DbSetIndex(_cIndex+OrdBagExt())
DbSetOrder(1)


//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------
cString  :="XXX"
cabec1  := "                                           ------------------------------ REAIS -------------------------------------- ------------------------------ DOLARES ------------------------------------"
cabec2   := "Cขd.Produto               Emis. Quantidad Valor Produto   Valor ICMS    Valor IPI  Valor PIS  Vl.COFINS   Valor Custo Valor Produto   Valor ICMS    Valor IPI  Valor PIS  Vl.COFINS   Valor Custo    Cotacao"
*            01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
*                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//           1234567890123456789012345 12345 123456789 1234567890123 123456789012 123456789012 1234567890 1234567890 1234567890123 1234567890123 123456789012 123456789012 1234567890 1234567890 1234567890123 1234567890
//--------------------------------------------------------------
// Verifica as perguntas selecionadas
//--------------------------------------------------------------
VALIDPERG()
pergunte(cPerg,.T.)
//--------------------------------------------------------------
// Variaveis utilizadas para parametros
// mv_par01             // da  data
// mv_par02             // ate Data
//--------------------------------------------------------------
//--------------------------------------------------------------
// Envia controle para a funcao SETPRINT
//--------------------------------------------------------------

wnrel:="REDFAT01"   // nome default do relatorio em disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey()== 27 .Or. nLastKey==27
   #IFNDEF WINDOWS
      RestScreen(3,0,24,79,cSavScr1)
   #ENDIF
   dbSelectArea("XXX")
   DbCloseArea("XXX")
   Return
Endif

SetDefault(aReturn,cString)

If LastKey()==27 .or. nLastKey==27
   #IFNDEF WINDOWS
      RestScreen(3,0,24,79,cSavScr1)
   #ENDIF
   dbSelectArea("XXX")
   DbCloseArea("XXX")
   Return
Endif

#IFDEF WINDOWS
     RptStatus({|| REDEST03Imp()},titulo)  //     RptStatus({|| Execute(REDEST03Imp)},titulo)
     Return
     /// Function REDEST03Imp
Static Function REDEST03Imp()
#ENDIF

titulo := titulo + ", de "+dtoc(mv_par01) + " a "+dtoc(mv_par02)
//--------------------------------------------------------------
// Variaveis utilizadas na regua de processamento
//--------------------------------------------------------------
tregs 	:= RecCount()
m_mult 	:= IIf(tregs>0,70/tregs,1)
p_ant	:= 4
p_atu	:= 4
p_cnt	:= 0
#IFNDEF WINDOWS
   m_sav20 := dCursor(3)
   m_sav7  := SaveScreen(23,0,24,79)
#ENDIF

qualquer := "t"
_cIndF2 := CriaTrab(qualquer,.f.)


DbSelectArea("SF2")
_cIndex:=CriaTrab(Nil,.F.)
IndRegua("SF2",_cIndex,"dtos(F2_EMISSAO)+F2_VEND1+F2_CLIENTE+F2_LOJA",,,"Selecionando Registro...")
//DbSetIndex(_cIndex+OrdBagExt())
DbSetOrder(1)            //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
DbGoTop()


//Index on dtos(SF2->F2_EMISSAO)+SF2->(F2_VEND1+F2_CLIENTE+F2_LOJA) to &_cIndF2


if mv_par03 == 2
   wcabec := .f.
   lin := 0
   @ lin+1,00 PSAY CABEC2
   lin := 2
endif

_dataini := mv_par01
_datafim := mv_par02         

nTXPIS:=getmv("MV_TXPIS")/100

DbSelectArea("SB1")
SetRegua(lastrec())
//DbSetOrder(8)		// B1_FILIAL + B1_COD (1)
_CREINDB1()

DbGoTop()
do while !eof()
   IncRegua()
   DbSelectArea("SD2")
  // DbSetorder(12)			//D2_FILIAL + D2_COD + D2_LOCAL + DTOS(D2_EMISSAO)+ D2_NUMSEQ (6)
  _CREINDD21()
   DbSeek(xfilial("SD2")+SB1->B1_P_COD,.T.)
   do while SD2->D2_P_COD==SB1->B1_P_COD .and. !Eof()
      if SD2->D2_EMISSAO < _dataini .or. SD2->D2_EMISSAO > _datafim
         DbSkip()
         loop
      endif
		l75:=.t.      
		if subs(SD2->D2_CF,1,1)="7"
			IF ! subs(SD2->D2_CF,2,1)$"15"		
				DbSkip()
				loop    
			ENDIF			
			l75:=.f.
		ENDIF	
		if !(subs(SD2->D2_CF,2,1)$"1")
			if l75
				DbSkip()
				loop   
			endif	 
		endif

      ValMoeda     := RecMoeda(SD2->D2_EMISSAO,"2")
      // Posiciona no cliente da nota para achar o C.Custo
      SA1->(dbseek(xfilial()+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.))

      * Registro selecionado p/impressao
      DbSelectArea("XXX")
      DbSeek(SA1->A1_REGIAO+SPACE(7)+SD2->D2_P_COD+dtos(SD2->D2_EMISSAO),.T.)
      if found()
         if RecLock("XXX",.f.)
            XXX->QUANT   := SD2->D2_QUANT  + XXX->QUANT
            XXX->MERC_R  := SD2->D2_TOTAL  + XXX->MERC_R
            XXX->ICMS_R  := SD2->D2_VALICM + XXX->ICMS_R
            XXX->IPI_R   := SD2->D2_VALIPI + XXX->IPI_R
            XXX->PIS_R   := (SD2->D2_TOTAL * nTXPIS)+ XXX->PIS_R
            XXX->COFIN_R := (SD2->D2_TOTAL * 0.03  )+ XXX->COFIN_R
            XXX->CUSTO_R := SD2->D2_CUSTO1 + XXX->CUSTO_R
            XXX->MERC_U  := (SD2->D2_TOTAL /ValMoeda) + XXX->MERC_U
            XXX->ICMS_U  := (SD2->D2_VALICM/ValMoeda) + XXX->ICMS_U
            XXX->IPI_U   := (SD2->D2_VALIPI/ValMoeda) + XXX->IPI_U
            XXX->PIS_U   := ((SD2->D2_TOTAL * nTXPIS)/ValMoeda)+ XXX->PIS_U
            XXX->COFIN_U := ((SD2->D2_TOTAL * 0.03  )/ValMoeda)+ XXX->COFIN_U
            XXX->CUSTO_U := SD2->D2_CUSTO2 + XXX->CUSTO_U
            MsUnLock()
         endif
      else
         if RecLock("XXX",.T.)
            XXX->CCUSTO  := SA1->A1_REGIAO
            XXX->CODIGO  := SD2->D2_P_COD
            XXX->EMISSAO := SD2->D2_EMISSAO
            XXX->QUANT   := SD2->D2_QUANT
            XXX->MERC_R  := SD2->D2_TOTAL
            XXX->ICMS_R  := SD2->D2_VALICM
            XXX->IPI_R   := SD2->D2_VALIPI
            XXX->PIS_R   := SD2->D2_TOTAL * nTXPIS
            XXX->COFIN_R := SD2->D2_TOTAL * 0.03
            XXX->CUSTO_R := SD2->D2_CUSTO1
            XXX->COT_USS := ValMoeda
            XXX->MERC_U  := (SD2->D2_TOTAL /ValMoeda)
            XXX->ICMS_U  := (SD2->D2_VALICM/ValMoeda)
            XXX->IPI_U   := (SD2->D2_VALIPI/ValMoeda)
            XXX->PIS_U   := ((SD2->D2_TOTAL * nTXPIS)/ValMoeda)
            XXX->COFIN_U := ((SD2->D2_TOTAL * 0.03  )/ValMoeda)
            XXX->CUSTO_U := SD2->D2_CUSTO2
            MsUnLock()
         endif
      endif
      DbSelectArea("SD2")
      DbSkip()
   enddo
   DbSelectArea("SD1")
  // DbSetorder(11)  // xifilial+d1_P_cod+d1_local+dtos(d1_dtdigit)    ///D1_FILIAL + D1_COD + D1_LOCAL + D1_ DTOS(D1_DTDIGIT)+ D1_NUMSEQ (7)
 _CREINDD1()
   DbSeek(xfilial("SD1")+SB1->B1_P_COD,.T.)
   do while SD1->D1_P_COD==SB1->B1_P_COD .and. !Eof()
      if SD1->D1_DTDIGIT < _dataini .or. SD1->D1_DTDIGIT > _datafim
         DbSkip()
         loop
      endif
      if ! subs(SD1->D1_CF,2,2) $ "20"
         DbSkip()
         loop
      endif
      if SD1->D1_LOCAL=="10"
         DbSkip()
         loop
      endif
      DbSelectArea("SD2")
      //DbSetOrder(11)  // xfilial+d2_doc+d2_serie+d2_cliente+d2_loja+d2_P_cod /// D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM (3)
      _CREINDD22()
      DbSeek(xfilial("SD2")+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_P_COD),.F.)
      SA1->(dbseek(xfilial()+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.))
      if found()
         statnfori := "S"
         diavorig := SD2->D2_EMISSAO
      else
         statnfori := "N"
         diavorig := SD1->D1_DTDIGIT
      endif
      ValMoeda     := RecMoeda(diavorig,"2")
      * Registro selecionado p/impressao
      DbSelectArea("XXX")
      DbSeek(SA1->A1_REGIAO+SD1->D1_P_COD+DTOS(diavorig),.T.)
      if found()
         if RecLock("XXX",.f.)
            XXX->QUANT   := XXX->QUANT   - SD1->D1_QUANT
            XXX->MERC_R  := XXX->MERC_R  - SD1->D1_TOTAL
            XXX->ICMS_R  := XXX->ICMS_R  - SD1->D1_VALICM
            XXX->IPI_R   := XXX->IPI_R   - SD1->D1_VALIPI
            XXX->PIS_R   := XXX->PIS_R   - (SD1->D1_TOTAL * nTXPIS)
            XXX->COFIN_R := XXX->COFIN_R - (SD1->D1_TOTAL * 0.03 )
            if statnfori == "S"
               XXX->CUSTO_R := XXX->CUSTO_R - SD1->D1_CUSTO
               XXX->CUSTO_U := XXX->CUSTO_U - SD1->D1_CUSTO2
            endif
            XXX->MERC_U  := XXX->MERC_U  - (SD1->D1_TOTAL /ValMoeda)
            XXX->ICMS_U  := XXX->ICMS_U  - (SD1->D1_VALICM/ValMoeda)
            XXX->IPI_U   := XXX->IPI_U   - (SD1->D1_VALIPI/ValMoeda)
            XXX->PIS_U   := XXX->PIS_U   - ((SD1->D1_TOTAL * nTXPIS)/ValMoeda)
            XXX->COFIN_U := XXX->COFIN_U - ((SD1->D1_TOTAL * 0.03  )/ValMoeda)
            MsUnLock()
         endif
      else
         if RecLock("XXX",.T.)
            XXX->CCUSTO  := SA1->A1_REGIAO
            XXX->CODIGO  := SD1->D1_P_COD
            XXX->EMISSAO := SD1->D1_EMISSAO
            XXX->QUANT   := SD1->D1_QUANT  * -1
            XXX->MERC_R  := SD1->D1_TOTAL  * -1
            XXX->ICMS_R  := SD1->D1_VALICM * -1
            XXX->IPI_R   := SD1->D1_VALIPI * -1
            XXX->PIS_R   := SD1->D1_TOTAL * nTXPIS * -1
            XXX->COFIN_R := SD1->D1_TOTAL * 0.03   * -1
            if statnfori == "S"
               XXX->CUSTO_R := SD1->D1_CUSTO * -1
               XXX->CUSTO_U := SD1->D1_CUSTO2  * -1
            endif
            XXX->COT_USS := ValMoeda
            XXX->MERC_U  := (SD1->D1_TOTAL /ValMoeda) * -1
            XXX->ICMS_U  := (SD1->D1_VALICM/ValMoeda) * -1
            XXX->IPI_U   := (SD1->D1_VALIPI/ValMoeda) * -1
            XXX->PIS_U   := ((SD1->D1_TOTAL * nTXPIS)/ValMoeda) * -1
            XXX->COFIN_U := ((SD1->D1_TOTAL * 0.03  )/ValMoeda) * -1
            MsUnLock()
         endif
      endif
      DbSelectArea("SD1")
      DbSkip()
   enddo
   DbSelectArea("SB1")
   DbSkip()
enddo
DbSelectArea("XXX")
DbGoTop()
do while !Eof()
   wcusto := XXX->CCUSTO
   ac_QUANT   := 0
   ac_MERC_R  := 0
   ac_ICMS_R  := 0
   ac_IPI_R   := 0
   ac_PIS_R   := 0
   ac_COFIN_R := 0
   ac_CUSTO_R := 0
   ac_MERC_U  := 0
   ac_ICMS_U  := 0
   ac_IPI_U   := 0
   ac_PIS_U   := 0
   ac_COFIN_U := 0
   ac_CUSTO_U := 0
   if ! wcabec
      @ lin,000 PSAY 'C.CUSTO: ' + XXX->CCUSTO
      lin := lin+1
   else
      lin := 100
   endif
   do while XXX->CCUSTO == wcusto .and. ! eof()
      SomaLin()
      @ lin,000 PSAY XXX->CODIGO  // codigo
      @ lin,026 PSAY subs(dtoc(XXX->EMISSAO),1,5)
      @ lin,032 PSAY XXX->QUANT   picture "@E 9,999,999"
      @ lin,042 PSAY XXX->MERC_R  picture "@E 99,999,999.99"
      @ lin,056 PSAY XXX->ICMS_R  picture  "@E 9,999,999.99"
      @ lin,069 PSAY XXX->IPI_R   picture  "@E 9,999,999.99"
      @ lin,082 PSAY XXX->PIS_R   picture    "@E 999,999.99"
      @ lin,093 PSAY XXX->COFIN_R picture    "@E 999,999.99"
      @ lin,104 PSAY XXX->CUSTO_R picture "@E 99,999,999.99"
      @ lin,118 PSAY XXX->MERC_U  picture "@E 99,999,999.99"
      @ lin,132 PSAY XXX->ICMS_U  picture  "@E 9,999,999.99"
      @ lin,145 PSAY XXX->IPI_U   picture  "@E 9,999,999.99"
      @ lin,158 PSAY XXX->PIS_U   picture    "@E 999,999.99"
      @ lin,169 PSAY XXX->COFIN_U picture    "@E 999,999.99"
      @ lin,180 PSAY XXX->CUSTO_U picture "@E 99,999,999.99"
      @ lin,194 PSAY XXX->COT_USS picture    "@E 9,999.9999"
      ac_QUANT   := ac_QUANT    + XXX->QUANT
      ac_MERC_R  := ac_MERC_R  + XXX->MERC_R
      ac_ICMS_R  := ac_ICMS_R  + XXX->ICMS_R
      ac_IPI_R   := ac_IPI_R   + XXX->IPI_R
      ac_PIS_R   := ac_PIS_R   + XXX->PIS_R
      ac_COFIN_R := ac_COFIN_R + XXX->COFIN_R
      ac_CUSTO_R := ac_CUSTO_R + XXX->CUSTO_R
      ac_MERC_U  := ac_MERC_U  + XXX->MERC_U
      ac_ICMS_U  := ac_ICMS_U  + XXX->ICMS_U
      ac_IPI_U   := ac_IPI_U   + XXX->IPI_U
      ac_PIS_U   := ac_PIS_U   + XXX->PIS_U
      ac_COFIN_U := ac_COFIN_U + XXX->COFIN_U
      ac_CUSTO_U := ac_CUSTO_U + XXX->CUSTO_U
      DbSkip()
   enddo
   SomaLin()
   if wcabec
      @ lin,000 PSAY replicate("-",193)
      SomaLin()
   endif
   @ lin,000 PSAY "Totais"
   @ lin,032 PSAY ac_QUANT   picture "@E 9,999,999"
   @ lin,042 PSAY ac_MERC_R  picture "@E 99,999,999.99"
   @ lin,056 PSAY ac_ICMS_R  picture  "@E 9,999,999.99"
   @ lin,069 PSAY ac_IPI_R   picture  "@E 9,999,999.99"
   @ lin,082 PSAY ac_PIS_R   picture    "@E 999,999.99"
   @ lin,093 PSAY ac_COFIN_R picture    "@E 999,999.99"
   @ lin,104 PSAY ac_CUSTO_R picture "@E 99,999,999.99"
   @ lin,118 PSAY ac_MERC_U  picture "@E 99,999,999.99"
   @ lin,132 PSAY ac_ICMS_U  picture  "@E 9,999,999.99"
   @ lin,145 PSAY ac_IPI_U   picture  "@E 9,999,999.99"
   @ lin,158 PSAY ac_PIS_U   picture    "@E 999,999.99"
   @ lin,169 PSAY ac_COFIN_U picture    "@E 999,999.99"
   @ lin,180 PSAY ac_CUSTO_U picture "@E 99,999,999.99"
   if wcabec
      SomaLin()
      @ lin,000 PSAY replicate("-",193)
   endif
enddo
if wcabec
   Roda(nCntImpr,cRodaTxt,Tamanho)
endif

//--------------------------------------------------------------
// Restaura Ambiente
//--------------------------------------------------------------
dbSelectArea("XXX")
DbCloseArea("XXX")
Erase &_cNome+".DBF"
//Erase &_cNome+".NTX"
Set Device To Screen
///SetPgEject(.F.)
If aReturn[5] == 1
     Set Printer TO
     dbcommitAll()
     ourspool(wnrel)
Endif
Return

// ==> Function Somalin
Static Function Somalin()
lin := lin + 1
if lin > 58 .and. wcabec
   cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   lin := 8
   @ lin,000 PSAY 'C.CUSTO: ' + XXX->CCUSTO
   lin := 10
endif



Return(nil) 

STATIC FUNCTION _CREINDB1()
	dbSelectArea("SB1")
	cCondicao2 := ""
    /// dbSetOrder(1)             /// B1_FILIAL + B1_COD
	cArqTrb1 := CriaTrab("",.F.)
	#IFDEF TOP
//		IndRegua("SB1",cArqTrb1,"B1_FILIAL+B1_P_COD",,cCondicao2,STR0011)		//"Selecionando Registros..."
		IndRegua("SB1",cArqTrb1,"B1_FILIAL+B1_P_COD",,cCondicao2,"Selecionando Registros...")		//"Selecionando Registros..."
	#ELSE
		IndRegua("SB1",cArqTrb1,"B1_FILIAL+B1_P_COD",,cCondicao2,"Selecionando Registros...")		//"Selecionando Registros..."
	#ENDIF
	nIndB1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrb1+ordBagExt())
	#ENDIF
	dbSetOrder(nIndB1+1)
RETURN
      
 
 STATIC FUNCTION _CREINDD21()
	dbSelectArea("SD2")
	cCondicao3 := ""
    /// dbSetOrder(6)             /// D2_FILIAL + D2_COD + D2_LOCAL + DTOS(D2_EMISSAO)+ D2_NUMSEQ
	cArqTrd21 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SD2",cArqTrd21,"D2_FILIAL + D2_P_COD + D2_LOCAL + DTOS(D2_EMISSAO)+ D2_NUMSEQ",,cCondicao3,"Selecionando Registros...")		//"Selecionando Registros..."
	#ELSE
		IndRegua("SD2",cArqTrd21,"D2_FILIAL + D2_P_COD + D2_LOCAL + DTOS(D2_EMISSAO)+ D2_NUMSEQ",,cCondicao3,"Selecionando Registros...")		//"Selecionando Registros..."
	#ENDIF
	nIndD2 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrd21+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD2+1)
RETURN
          

STATIC FUNCTION _CREINDD22()
	dbSelectArea("SD2")
	cCondicao4 := ""
    /// dbSetOrder(3)             /// D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM 
	cArqTrd22 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SD2",cArqTrd22,"D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_P_COD + D2_ITEM",,cCondicao4,"Selecionando Registros...")		//"Selecionando Registros..."
	#ELSE
		IndRegua("SD2",cArqTrd22,"D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_P_COD + D2_ITEM",,cCondicao4,"Selecionando Registros...")		//"Selecionando Registros..."
	#ENDIF
	nIndD2 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrd22+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD2+1)
RETURN
        
 
 STATIC FUNCTION _CREINDD1()
	dbSelectArea("SD1")
	cCondicao5 := ""
    /// dbSetOrder(7)             /// D1_FILIAL + D1_COD + D1_LOCAL + D1_ DTOS(D1_DTDIGIT)+ D1_NUMSEQ
	cArqTrd1 := CriaTrab("",.F.)
	#IFDEF TOP
		IndRegua("SD1",cArqTrd1,"D1_FILIAL + D1_P_COD + D1_LOCAL + DTOS(D1_DTDIGIT)+ D1_NUMSEQ",,cCondicao5,"Selecionando Registros...")		//"Selecionando Registros..."
	#ELSE
		IndRegua("SD1",cArqTrd1,"D1_FILIAL + D1_P_COD + D1_LOCAL + DTOS(D1_DTDIGIT)+ D1_NUMSEQ",,cCondicao5,"Selecionando Registros...")		//"Selecionando Registros..."
	#ENDIF
	nIndD1 := RetIndex()
	#IFNDEF TOP
		dbSetIndex(cArqTrd1+ordBagExt())
	#ENDIF
	dbSetOrder(nIndD1+1)
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  21/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

///             X1_ORDEM	X1_PERGUNT        	    X1_PERSPA	            X1_PERENG            	VARIAVL	  TIP TAM  DEC PRE GSC VL  X1_VAR01	 X1_DEF01	       X1_DEFSPA1     	       X1_DEFENG1     	 X1_CNT01          X1_VAR02	  X1_DEF02	         X1_DEFSPA2	      X1_DEFENG2	      X1_CNT02       	X1_VAR03	    X1_DEF03	      X1_DEFSPA3	    X1_DEFENG3	      X1_CNT03	 X1_VAR04 X1_DEF04   X1_DEFSPA4  X1_DEFENG4	  X1_CNT04	   X1_VAR05	    X1_DEF05	X1_DEFSPA5	X1_DEFENG5	 X1_CNT05  X1_F3 X1_PYME   X1_GRPSXG   X1_HELP
AAdd( aRegs, { cPerg, "01","Data Inicial ?        ","?Data Inicial ?     ","Data Inicial ?         ","mv_ch1","D",8,0,0,"G","","MV_PAR01","			     ","					 ","			   ","'01/01/01'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "02","Data Final ?          ","?Data Final ?       ","Data Final ?           ","mv_ch2","D",8,0,0,"G","","MV_PAR02","			     ","	                 ","               ","'30/04/04'     ","        ","               ","               ","               ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","       ","        ","        "} )		
AAdd( aRegs, { cPerg, "03","Imprimir Cabecalho ?  ","?Imprimir Cabecalho?","Imprimir Cabecalho ?   ","mv_ch1","N",1,0,1,"C","","MV_PAR01","Sim   	     ","Sim	                 ","Sim            ","               ","        ","Nao            ","Nao            ","Nao            ","               ","               ","               ","               ","               ","       ","       ","        ","         ","          ","          ","          ","        ","         ","          ","        ","   ","       ","        ","        "} )		


For i:=1 to Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)

	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
