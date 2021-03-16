#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*
Funcao      : GSX0050
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ginga 
Autor     	:                                
Data     	:                      
Obs         :  
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Generico. 
Cliente     : Shiseido
*/

*-----------------------*
 User Function GSX0050()
*-----------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CBTXT,CBCONT,NORDEM,LIMITE,TAMANHO,NTIPO")
SetPrvt("M_PAG,LIN,TITULO,CDESC1,CDESC2,CDESC3,_TpAnt")
SetPrvt("AORD,NCNTIMPR,CRODATXT,WCABEC,ARETURN,ALINHA")
SetPrvt("NOMEPROG,NLASTKEY,CPERG,NPAGINA,NIVEL,CSAVSCR1")
SetPrvt("CSAVCUR1,CSAVROW1,CSAVCOL1,CSAVCOR1,_ACAMPOS,_CNOME,_CNAT")
SetPrvt("CSTRING,CABEC1,CABEC2,WNREL,TREGS,M_MULT")
SetPrvt("P_ANT,P_ATU,P_CNT,M_SAV20,M_SAV7,QUALQUER")
SetPrvt("_CINDF2,_diaini,_diafim,_DATAINI,_DATAFIM,VALMOEDA,VALMOEDA1,VALMOEDA2,VALMOEDA3,VALMOEDA4,VALMOEDA5,STATNFORI,DIAVORIG")
SetPrvt("AC_QUANT,AC_MERC_R,AC_ICMS_R,AC_IPI_R,AC_PIS_R,AC_COFIN_R")
SetPrvt("cDESCR,cQWHUM,cQWDOIS,cQWTRES,cQWQUAT,cQWCINCO")
SetPrvt("cVRWHUM,cVRWDOIS,cVRWTRES,cVRWQUAT,cVRWCINCO,")
SetPrvt("cVUWHUM,cVUWDOIS,cVUWTRES,cVUWQUAT,cVUWCINCO,cDESCRI")
SetPrvt("AC_CUSTO_R,AC_MERC_U,AC_ICMS_U,AC_IPI_U,AC_PIS_U,AC_COFIN_U")
SetPrvt("AC_CUSTO_U,AC_CUSTO_U1,_FIMS1,_FIMS2,_FIMS3,_FIMS4,_FIMS5,X")
SetPrvt("AC_QUANT1,AC_MERC_R1,AC_ICMS_R1,AC_IPI_R1,AC_PIS_R1,AC_COFIN_R1")
SetPrvt("AC_CUSTO_R1,AC_MERC_U1,AC_ICMS_U1,AC_IPI_U1,AC_PIS_U1,AC_COFIN_U1,_TX")


cCod := ''
cLocal := ''
cSeeksd1 := ''
nSaldo := 0
nX := 0
aLocais := {}
aSaldo := {}


/*/
----------+-------------------------------------------------------------
Programa  |³GSX0050   | Autor | FRANCISCO F.S. NETO    | Data | 15.09.03
----------|-------------------------------------------------------------
Descri‡…o |SALES CO SHIP/RETURN/OUT OF STOCK                                             
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS780SCR05_AAAAMMDD.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/


//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
//
// 
// multibrand_code         		C     3    0  "001"  - Conteudo fixo
// sales_company_code           	C     3    0  "780"  - Codigo Companhia de Vendas
// system_date		             	C     8    0  (yyyymmdd) data do sistema 
// business_record_date         	C     4    0  (yyyymmdd)/(yyyymm)data do registro
// global_code				        	C    15    0  codigo do produto
// retailer_code			        	C    15    0  codigo do cliente ('ALL')
// currency			              	C     3    0  "999" codigo da moeda 
// wholesale_quantity           	C     9    3  Faturamento do periodo (Quantidade)
// wholesale_amount             	C    16    4  Faturamento do periodo (Valor)
// returns_quantity           	C     9    3  Devolucoes no periodo (quantidade)
// returns_amount             	C    16    4  Devolucoes no periodo (valor)
// out_of_stock_quantity        	C     9    3  Vendas nao efetuadas por falta de Estoque (quantidade)
// out_of_stock_amount          	C    16    4  Vendas nao efetuadas por falta de Estoque (valor)
// monthly					        	C     1    0  "1"
//
//
//--------------------------------------------------------------
// Define Variaveis
//--------------------------------------------------------------

nHdlChk := NIL
lflag1 := .F.
lflag2 := .F.
cCB := 0
cCN := 0
eNAO := {}
cEOL    := "CHR(13)+CHR(10)"
ceol := chr(13) + chr(10)

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=220
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 220
_TxLiq := 0.9535
_TXPIS := GETMV("MV_TXPIS")
_TXCOFIN := GETMV("MV_TXCOFIN")
_TX := (100 - (_TXPIS + _TXCOFIN))/100


_MES := "  "

_QPROD   :=  SPACE(20)
_QCPAG   :=  SPACE(20)
_QCLIE   :=  SPACE(20)
_QVEND   :=  SPACE(20)
   
_QDESCPR  := SPACE(50)
_QDESCCP  := SPACE(50)
_QDESCLI  := SPACE(50)
_QDESCVE  := SPACE(50)

_VALMOEDA := 0.00
_DIA   := CTOD("  /  /    ")
_dataver := space(10)

_ACUM  := SPACE(10)

AC_TOPR := ARRAY(14)
AC_TOCP := ARRAY(14)
AC_TOCL := ARRAY(14)
AC_TOVE := ARRAY(14)
AC_TOGE := ARRAY(14)
cPerg    :="GS0050    "

lMes := .F.
lDia := .F.

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

//--------------------------------------------------------------
// Valida as perguntas selecionadas
//--------------------------------------------------------------
Validperg()

//--------------------------------------------------------------
// Verifica as perguntas selecionadas
//--------------------------------------------------------------
pergunte(cPerg,.T.)
//--------------------------------------------------------------
// Variaveis utilizadas para parametros
// mv_par01             // da  data
//--------------------------------------------------------------

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML0050 - Sales Co Ship/Returns/Out of Stock "  
	@ 001,005 TO 090,200 
	@ 005,020 SAY " Especifico para Shiseido do Brasil !!! "                                           
	@ 020,020 CHECKBOX "Mensal  " var lMes
	@ 030,020 CHECKBOX "Diario  " var lDia

	@ 015,100 BUTTON "  OK    " SIZE 70,20 ACTION   Processa({|| ATUALIZA() },"Processando...") 
	@ 035,100 BUTTON "  SAIR  " SIZE 70,20 ACTION CLOSE(oDlg2)
	ACTIVATE DIALOG oDlg2 CENTER
	
Return(nil)	


Return



	Processa({||ATUALIZA()})


Return .T.


Static Function ATUALIZA()

	_aCampos := {  {"CODIGO"  ,"C",15,0 } ,;
	               {"DESCRIC" ,"C",30,0 }  ,;
	               {"QUANTF"  ,"N",12,2 } ,;
	               {"QUANTD"  ,"N",12,2 } ,;
	               {"QUANTV"  ,"N",12,2 } ,;
	               {"VALLIQF" ,"N",16,2 } ,;
	               {"VALLIQD" ,"N",16,2 } ,;
	               {"VALLIQV" ,"N",16,2 } }
	
	_cNome := CriaTrab(_aCampos,.t.)
	dbUseArea(.T.,, _cNome,"TRF",.F.,.F.)
	DbSelectArea("TRF")
	Index on CODIGO to &_cNome

	if lDia = .F. .AND. lMes = .F.
		lDia := .T.
	elseif lDia = .T. .AND. lMes = .T.
		lMes := .F.
	endif
	if lDia = .T.
		wdir := 'C:\GINGA\GS780scr05_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-0.XML'
	else
		wdir := 'C:\GINGA\GS780scr05_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-1.XML'
	endif
	
	wdir :=alltrim(wdir)

	_fSELECTREC()      // SELECT 
	
	_CRETXT()           /// ABERTURA DE ARQUIVO TEXTO
	
	_fGRVTXT()         // GRAVACAO DE TEXTO
	
	DBCLOSEAREA()      // FECHA ARQUIVO DE TRABALHO

	FClose(nHdlChk)	 // FECHA ARQUIVO TEXTO
	
RETURN .T.


Static Function ValidPerg()

	_sAlias := Alias()
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,10)
	aRegs := {}
	
	
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Data de Emissao    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"02","Ate data de Emissao?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	
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

STATIC FUNCTION _fSELECTREC()           

	DbSelectArea("SD2")                  // FATURAMENTO COM PIS/COFINS
	_xAliasSiga := "SD2"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
                                                                                                  //(D2_TOTAL*0.9535) Wederson 28/07/04
	cQUERY := "SELECT DISTINCT D2_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D2_QUANT) AS QUANT, SUM(((D2_TOTAL*" + str(_TX) + ")-D2_VALICM)) AS VALLIQ "
	cQUERY := cQUERY + "FROM SD2R70, SB1R70 "
	cQUERY := cQUERY + "WHERE D2_FILIAL ='"+xFilial("SD2")+"' AND D2_COD = B1_COD AND D2_TES IN ('56V','57D','69D','70D','73A','74A','92D','90A','91A') AND SD2R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D2_EMISSAO>=" + _DATADE + "AND D2_EMISSAO<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D2_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D2_COD "


	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
 
	while !eof()
		dbselectarea("TRF")
		dbseek(TRB->CODIGO + TRF->DESCRIC)
		if !found()
			reclock("TRF",.t.)
				TRF->CODIGO := TRB->CODIGO
				TRF->DESCRIC := TRB->DESCRIC
				TRF->QUANTF := TRB->QUANT
				TRF->VALLIQF := TRB->VALLIQ	
			msunlock()
		else
			reclock("TRF",.f.)
				TRF->QUANTF := TRF->QUANTF + TRB->QUANT
				TRF->VALLIQF += TRB->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRB")
		dbskip()	
	enddo
	dbclosearea("TRB")	







	DbSelectArea("SD2")                /// FATURAMENTO SEM PIS/COFINS
	_xAliasSiga := "SD2"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT D2_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D2_QUANT) AS QUANT,  SUM((D2_TOTAL-D2_VALICM)) AS VALLIQ "
	cQUERY := cQUERY + "FROM SD2R70, SB1R70 "
	cQUERY := cQUERY + "WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND D2_COD = B1_COD AND D2_TES IN ('75A','87A','83A','79A','92A','93A','94A','95A') AND SD2R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D2_EMISSAO>=" + _DATADE + "AND D2_EMISSAO<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D2_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D2_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRX',.F.,.T.)
	DBSELECTAREA("TRX")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		dbseek(TRX->CODIGO + TRX->DESCRIC)
		if !found()
			reclock("TRF",.t.)
				TRF->CODIGO := TRX->CODIGO
				TRF->DESCRIC := TRX->DESCRIC
				TRF->QUANTF := TRX->QUANT
				TRF->VALLIQF := TRX->VALLIQ	
			msunlock()
		else
			reclock("TRF",.f.)
				TRF->QUANTF  := TRF->QUANTF + TRX->QUANT
				TRF->VALLIQF += TRX->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRX")
		dbskip()	
	enddo
	dbclosearea("TRX")	







	DbSelectArea("SD1")                  // DEVOLUCAO DE VENDAS COM PIS/COFINS
	_xAliasSiga := "SD1"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
                                                                                                  //(D1_TOTAL*0.9535) Wederson 28/07/04
	cQUERY := "SELECT DISTINCT D1_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D1_QUANT) AS QUANT, SUM(((D1_TOTAL*" + str(_TX) + ")-D1_VALICM))  AS VALLIQ "
	cQUERY := cQUERY + "FROM SD1R70, SB1R70 "
	cQUERY := cQUERY + "WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D1_COD = B1_COD AND D1_TES IN ('05E','06E') AND SD1R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D1_DTDIGIT>=" + _DATADE + "AND D1_DTDIGIT<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D1_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D1_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRC',.F.,.T.)
	DBSELECTAREA("TRC")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		dbseek(TRC->CODIGO + TRC->DESCRIC)
		if !found()
			reclock("TRF",.t.)
				TRF->CODIGO := TRC->CODIGO
				TRF->DESCRIC := TRC->DESCRIC
				TRF->QUANTD := TRC->QUANT
				TRF->VALLIQD := TRC->VALLIQ	
			msunlock()
		else
			reclock("TRF",.f.)
				TRF->QUANTD := TRF->QUANTD + TRC->QUANT
				TRF->VALLIQD := TRF->VALLIQD + TRC->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRC")
		dbskip()	
	enddo
	dbclosearea("TRC")	





	DbSelectArea("SD1")                /// DEVOLUCAO DE VENDAS SEM PIS/COFINS
	_xAliasSiga := "SD1"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT D1_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D1_QUANT) AS QUANT, SUM((D1_TOTAL-D1_VALICM)) AS VALLIQ "
	cQUERY := cQUERY + "FROM SD1R70, SB1R70 "
	cQUERY := cQUERY + "WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND  D1_COD = B1_COD AND D1_TES IN ('25E','24E') AND SD1R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D1_DTDIGIT>=" + _DATADE + "AND D1_DTDIGIT<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D1_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D1_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRZ',.F.,.T.)
	DBSELECTAREA("TRZ")
	DBGOTOP()
  
	while !eof()
		dbselectarea("TRF")
		dbseek(TRZ->CODIGO + TRZ->DESCRIC) /////// Inserido por Daniel Pontes
		if !found()
			reclock("TRF",.t.)
		 		TRF->CODIGO := TRZ->CODIGO   
				TRF->DESCRIC := TRZ->DESCRIC
		 		TRF->QUANTD := TRZ->QUANT
				TRF->VALLIQD := TRZ->VALLIQ	
			msunlock()
		else
			reclock("TRF",.f.)
				TRF->QUANTD := TRF->QUANTD + TRZ->QUANT
				TRF->VALLIQD := TRF->VALLIQD + TRZ->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRZ")
		dbskip()	
	enddo
	dbclosearea("TRZ")	








	DbSelectArea("SC9")                  // VENDAS COM PIS/COFINS  ... Fora de Estoque
	_xAliasSiga := "SC9"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
                                                                                                          //(C6_VALOR*0.9535) Wederson 28/07/04
	cQUERY := "SELECT DISTINCT C9_PRODUTO AS CODIGO, B1_DESCING AS DESCRIC, SUM(C9_QTDLIB) AS QUANT, SUM(((C6_VALOR*" + str(_TX) + ")-(C6_VALOR*(B1_PICM/100)))) AS VALLIQ "
 	cQUERY := cQUERY + "FROM SC9R70, SC6R70, SB1R70 "
	cQUERY := cQUERY + "WHERE  C9_FILIAL = '"+xFilial("SC9")+"' AND (C9_PRODUTO = B1_COD) AND (C9_PRODUTO = C6_PRODUTO) AND (C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM) AND C6_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D') AND SC9R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (C9_BLEST <> '10' AND C9_BLEST <> '  ') AND (C6_ENTREG>=" + _DATADE + " AND C6_ENTREG<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY C9_PRODUTO,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY C9_PRODUTO "


	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRD',.F.,.T.)
	DBSELECTAREA("TRD")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		dbseek(TRD->CODIGO + TRD->DESCRIC)
		if !found()
			reclock("TRF",.T.)
				TRF->CODIGO := TRD->CODIGO
				TRF->DESCRIC := TRD->DESCRIC
				TRF->QUANTV := TRD->QUANT
				TRF->VALLIQV := TRD->VALLIQ	
			msunlock()
		else
			reclock("TRF",.F.)
				TRF->QUANTV := TRF->QUANTV + TRD->QUANT
				TRF->VALLIQV := TRF->VALLIQV + TRD->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRD")
		dbskip()	
	enddo
	dbclosearea("TRD")	







	DbSelectArea("SC9")                /// VENDAS SEM PIS/COFINS   ... fora de estoque
	_xAliasSiga := "SC9"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

//	cQUERY := "SELECT DISTINCT C9_PRODUTO AS CODIGO, B1_DESCING AS DESCRIC, SUM(C9_QTDLIB) AS QUANT,  SUM((C6_VALOR-(C6_VALOR*(B1_PICM/100)))) AS VALLIQ "
//	cQUERY := cQUERY + "FROM SC9R70, SC6R70, SB1R70 "
//	cQUERY := cQUERY + "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND (C9_PRODUTO = B1_COD) AND (C9_PRODUTO = C6_PRODUTO) AND (C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM) AND C6_TES IN ('83A','79A') AND SC9R70.D_E_L_E_T_<>'*' "   
//	cQUERY := cQUERY + " AND B1_TIPO IN('PA','PP') AND (C9_BLEST <> '10' AND C9_BLEST <> '  ') AND (C6_ENTREG>=" + _DATADE + "AND C6_ENTREG<=" +_DATAATE + ")"
//	cQUERY := cQUERY + "GROUP BY C9_PRODUTO,B1_DESCING " 
//	cQUERY := cQUERY + "ORDER BY C9_PRODUTO "


	cQUERY := "SELECT C6_PRODUTO AS CODIGO, B1_DESCING AS DESCRIC, SUM(C6_QTDVEN) AS QUANT, SUM(((C6_VALOR)-(C6_VALOR*(B1_PICM/100)))) AS VALLIQ  "
	cQUERY := cQUERY + " FROM SC6R70, SB1R70  "
	cQUERY := cQUERY + " WHERE  C6_FILIAL = '"+xFilial("SC9")+"'  "
	cQUERY := cQUERY + " AND C6_QTDENT<>C6_QTDVEN "
	cQUERY := cQUERY + " AND (C6_PRODUTO = B1_COD)  "
	cQUERY := cQUERY + " AND C6_TES IN ('75A','87A','83A','79A')  "
	cQUERY := cQUERY + " AND SC6R70.D_E_L_E_T_<>'*'  "
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP')  "
	cQUERY := cQUERY + " AND (C6_ENTREG>=" + _DATADE + " AND C6_ENTREG<=" +_DATAATE + ") "
	cQUERY := cQUERY + " GROUP BY C6_PRODUTO,B1_DESCING  "
	cQUERY := cQUERY + " ORDER BY C6_PRODUTO "




	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRZ',.F.,.T.)
	DBSELECTAREA("TRZ")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		dbseek(TRZ->CODIGO + TRZ->DESCRIC)
		if !found()
			reclock("TRF",.T.)
				TRF->CODIGO := TRZ->CODIGO
				TRF->DESCRIC := TRZ->DESCRIC
				TRF->QUANTV := TRZ->QUANT
				TRF->VALLIQV := TRZ->VALLIQ	
			msunlock()
		else
			reclock("TRF",.F.)
				TRF->QUANTV := TRF->QUANTV + TRZ->QUANT
				TRF->VALLIQV := TRF->VALLIQV + TRZ->VALLIQ	
			msunlock()
		endif
		dbselectarea("TRZ")
		dbskip()	
	enddo
	dbclosearea("TRZ")	
                                       
RETURN






STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO

	IF lDia = .T. .AND. lMes = .F.       //// diario   
		cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := "<data sales_company_code =" + "'780' " + "system_date= " + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
 		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
	   dbselectarea("TRF")                      
	   DBGOTOP()
		PROCREGUA(7)
		do while !eof() 
			INCPROC("PRODUTO:   " + TRF->CODIGO)
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record business_record_date ='" +"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRF->CODIGO + SPACE((15 - LEN(TRF->CODIGO))) + "' "
	      cREGISTRO := cREGISTRO + " retailer_code='ALL" + SPACE(12) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' "   + ">" + ceol
	     	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	                    
//	      cREGISTRO := space(20) + " <wholesale quantity='" + strzero(TRF->QUANTF-TRF->QUANTD,9,3) + "' "         /// Faturamento - Linha comentada por DP
	      cREGISTRO := space(20) + " <wholesale quantity='" + strzero(TRF->QUANTF,9,3) + "' "         /// Faturamento
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQF,16,4) + "' /> "
	      cREGISTRO := cREGISTRO + ceol
	      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	      cREGISTRO := ""
	      cREGISTRO := space(20) + " <returns quantity='" + strzero(TRF->QUANTD,9,3) + "' "           /// Devolucoes
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQD,16,4) + "' /> "
	      cREGISTRO := cREGISTRO + ceol
	      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	      cREGISTRO := ""
	      cREGISTRO := space(20) + " <out_of_stock quantity='" + strzero(TRF->QUANTV,9,3) + "' "       /// Vendas nao efetuadas
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQV,16,4) + "' /> " 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + "</record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
	
			TRF->(dbskip())
				
		enddo
	
		cREGISTRO := "</data>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    
	endif
	



	IF lDia = .F. .AND. lMes = .T.       //// mensal
		cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := "<data sales_company_code =" + "'780' " + "system_date= " + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))

		cREGISTRO := ""    	
		cREGISTRO := space(10) + "<monthly> " + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	

	   dbselectarea("TRF")                      
	   DBGOTOP()
		PROCREGUA(7)
		do while !eof() 
			INCPROC("PRODUTO:   " + TRF->CODIGO)
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(20) + " <record business_record_date ='" +"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + space(2) + "' "       ////// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRF->CODIGO + SPACE((15 - LEN(TRF->CODIGO))) + "' "
	      cREGISTRO := cREGISTRO + " retailer_code='ALL" + SPACE(12) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' "   + ">" + ceol
	     	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	      cREGISTRO := ""	      	                    
	      cREGISTRO := space(30) + " <wholesale quantity='" + strzero(TRF->QUANTF,9,3) + "' "         /// Faturamento
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQF,16,4) + "' /> "
	      cREGISTRO := cREGISTRO + ceol
	      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	      cREGISTRO := ""
	      cREGISTRO := space(30) + " <returns quantity='" + strzero(TRF->QUANTD,9,3) + "' "           /// Devolucoes
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQD,16,4) + "' /> "
	      cREGISTRO := cREGISTRO + ceol
	      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	      cREGISTRO := ""
	      cREGISTRO := space(30) + " <out_of_stock quantity='" + strzero(TRF->QUANTV,9,3) + "' "       /// Vendas nao efetuadas
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQV,16,4) + "' /> " 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(20) + "</record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
	
			TRF->(dbskip())
				
		enddo

		cREGISTRO := ""    	
		cREGISTRO := space(10) + "</monthly> " + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	

	
		cREGISTRO := "</data>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    

	endif
	
	
RETURN


STATIC FUNCTION _CRETXT()
	cArqChk	:=	WDIR
	nHdlChk	:=	MsFCreate(cArqChk)
	If nHdlChk < 0
		Break
	EndIf
RETURN

