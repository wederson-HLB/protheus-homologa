//SCR04
#INCLUDE "topconn.ch"
#include "rwmake.ch"
#include "colors.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF  

/*
Funcao      : GSX0040
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
User Function GSX0040()
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
SetPrvt("AC_CUSTO_R1,AC_MERC_U1,AC_ICMS_U1,AC_IPI_U1,AC_PIS_U1,AC_COFIN_U1,cTxDol,cTxIen")  
Private cCombo :="Mensal"
Private aItens := {"Mensal","Diario"}

cCod := ''
cLocal := ''
cSeeksd1 := ''
nSaldo := 0
nX := 0
aLocais := {}
aSaldo := {}

/*/
----------+-------------------------------------------------------------
Programa  |³GSX0040   | Autor | FRANCISCO F.S. NETO    | Data | 12.09.03
----------|-------------------------------------------------------------
Descri‡…o |SALES CO RECEIPTS / INVENTORY                                                 
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS780SCR04_AAAAMMDD.XML 
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
// currency			              	C     3    0  "999" codigo da moeda 
// receipts_quantity            	C     9    3  Quantidade recebida (acumulado do mes)
// receipts_amount              	C    16    4  Valor recebido (acumulado do mes)
// inventory_quantity           	C     9    3  Saldo quantidade (ultimo fechamento)
// inventory_amount             	C    16    4  Saldo valor(ultimo fechamento)
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
cTxDol  := Space(10)
cTxIen  := Space(10)
cPerg    :="GS0040    "
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

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "GSXML0040 - Sales Co Receipts/Inventory "
	@ 001,001 TO 060,200 
	@ 005,020 SAY  " Especifico para Shiseido do Brasil !!! "  COLOR CLR_HRED, CLR_WHITE 
	//@ 020,020 CHECKBOX "Mensal  " var lMes
	//@ 030,020 CHECKBOX "Diario  " var lDia   
	@ 015,020 ComboBox cCombo Items aItens Size 50,50
   @ 035,005 Say "Dolar"
   @ 030,020 Get cTxDol Size 040,040 Picture "@E 999.9999"

   @ 045,005 Say "Iene"
   @ 045,020 Get cTxIen Size 040,040 Picture "@E 999.9999"

	@ 015,100 BUTTON "  OK    " SIZE 70,20 ACTION   Processa({|| ATUALIZA() },"Processando...") 
	@ 035,100 BUTTON "  SAIR  " SIZE 70,20 ACTION CLOSE(oDlg2)
	ACTIVATE DIALOG oDlg2 CENTER
	
Return(nil)	


Return

	Processa({||ATUALIZA()})

Return .T.


Static Function ATUALIZA()

	_aCampos := {  {"CODIGO"  ,"C",15,0 } ,;
	               {"DESCRIC" ,"C",30,0 } ,;
	               {"QUANT"   ,"N",12,2 } ,;
	               {"QTDENT"  ,"N",12,2 } ,;
	               {"QUANTS"  ,"N",12,2 } ,;
	               {"VALCUS"  ,"N",12,2 } ,;
	               {"VALLIQ"  ,"N",16,2 } ,;
	               {"VALTRAN" ,"N",16,2 } }
	
	_cNome := CriaTrab(_aCampos,.t.)
	dbUseArea(.T.,, _cNome,"TRF",.F.,.F.)
	DbSelectArea("TRF")
	Index on CODIGO to &_cNome

	//if lDia = .F. .AND. lMes = .F.
	//	lDia := .T.
	//elseif lDia = .T. .AND. lMes = .T.
	//	lMes := .F.
	//endif
	if cCombo="Diario"//lDia = .T.
		wdir := 'C:\GINGA\GS780scr04_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-0.XML'
	else
		wdir := 'C:\GINGA\GS780scr04_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-1.XML'
	endif
	
	wdir :=alltrim(wdir)

	_CRETXT()           /// ABERTURA DE ARQUIVO TEXTO

	_fSELECTREC()      // SELECT PARA RECEBIMENTOS
	
	_fGRVTXT()         // GRAVACAO DE TEXTO
	
	dbselectarea("TRF")
	DBCLOSEAREA()      

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

STATIC FUNCTION _fSELECTREC()           // Entradas

	DbSelectArea("SD1")                  // COMPRAS
	_xAliasSiga := "SD1"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REG. COMPRAS. " + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT D1_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D1_QUANT) AS QUANT, SUM(((D1_TOTAL*" + str(_TX) + ")-D1_VALICM))  AS VALLIQ "
	cQUERY := cQUERY + "FROM SD1R70, SB1R70 "
	cQUERY := cQUERY + " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D1_COD = B1_COD AND D1_TES IN ('01A','01B','02B','05B','07B','08A','32B','35B','36B') AND SD1R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D1_DTDIGIT>=" + _DATADE + "AND D1_DTDIGIT<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D1_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D1_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		INCPROC("GRAVANDO ARQ.TRAB. COMPRAS...." + STR(LASTREC()))
		trf->(dbseek(trb->codigo))
		if !found()
			reclock("trf",.t.)
				trf->codigo := trb->codigo
				trf->descric := trb->descric
				trf->quant := trb->quant
				trf->valliq := trb->valliq
				trf->quants := 0
				trf->valcus := 0				
			msunlock()
		else
			reclock("trf",.f.)
				trf->quant := trf->quant + trb->quant
				trf->valliq := trf->valliq + trb->valliq	
			msunlock()
		endif
		dbselectarea("TRB")
		dbskip()	
	enddo
	dbclosearea("TRB")	

	DbSelectArea("SC7")                  // PEDIDOS DE COMPRAS (Mercadorias em Transito)
	_xAliasSiga := "SC7"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO PED. COMPRAS. " + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"   

	//_nVar:=TcSqlExec("ShiseidoRetornaCotacao(C7_MOEDA, C7_EMISSAO)")
                                                                                                         
//	cQUERY :=           "SELECT DISTINCT C7_PRODUTO AS CODIGO
//	cQuery := cQUERY + " , B1_DESCING AS DESCRIC
//	cQuery := cQUERY + " , SUM(C7_QTDENT) AS QTDENT
//	cQuery := cQUERY + " , SUM(((((C7_PRECO*C7_QTDENT)*" + str(_TX) + ")-((C7_PRECO*C7_QTDENT)*C7_PICM)/100)) * "+Str(_nVar)+") AS VALTRAN "
//	cQuery := cQUERY + " , SUM(C7_QUANT) AS QUANT 
//	cQUERY := cQUERY + " , SUM(((C7_TOTAL *"+STR(_TX)+")-C7_VALICM)*"+Str(_nVar)+") AS VALLIQ "
//	cQUERY := cQUERY + " FROM SC7R70, SB1R70 "
//	cQUERY := cQUERY + " WHERE C7_FILIAL = '"+xFilial("SC7")+"' 
//	cQUERY := cQUERY + " AND C7_PRODUTO = B1_COD 
//	cQUERY := cQUERY + " AND C7_ENCER <> 'E' 
//	cQUERY := cQUERY + " AND SC7R70.D_E_L_E_T_<>'*' "   
//	cQUERY := cQUERY + " AND B1_TIPO IN('PA','PP') "
//	cQUERY := cQUERY + " GROUP BY C7_PRODUTO,B1_DESCING " 
//	cQUERY := cQUERY + " ORDER BY C7_PRODUTO "

	cQUERY :=           "SELECT DISTINCT C7_PRODUTO AS CODIGO "
	cQuery := cQUERY + " , B1_DESCING AS DESCRIC "
	cQuery := cQUERY + " , SUM(C7_QTDENT) AS QTDENT "
	cQuery := cQUERY + " , SUM((C7_TOTAL)* "+cTxDol+") AS VALTRAN "
	cQuery := cQUERY + " , SUM(C7_QUANT) AS QUANT "
	cQUERY := cQUERY + " , SUM(((C7_TOTAL *"+STR(_TX)+")-C7_VALICM)*"+cTxDol+") AS VALLIQ "
	cQUERY := cQUERY + " FROM SC7R70, SB1R70 "
	cQUERY := cQUERY + " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
	cQUERY := cQUERY + " AND C7_PRODUTO = B1_COD "
	cQUERY := cQUERY + " AND C7_ENCER <> 'E' "
	cQUERY := cQUERY + "  AND C7_QTDENT <> 0"
	cQUERY := cQUERY + " AND SC7R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND SC7R70.C7_MOEDA = '2' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') "
	cQUERY := cQUERY + " GROUP BY C7_PRODUTO,B1_DESCING " 
	cQuery := cQUERY + " union"
	cQuery := cQUERY + " SELECT DISTINCT C7_PRODUTO AS CODIGO "
	cQuery := cQUERY + " , B1_DESCING AS DESCRIC "
	cQuery := cQUERY + " , SUM(C7_QTDENT) AS QTDENT "
	cQuery := cQUERY + " , SUM((C7_TOTAL)* "+cTxIen+") AS VALTRAN "
	cQuery := cQUERY + " , SUM(C7_QUANT) AS QUANT " 
	cQUERY := cQUERY + " , SUM(((C7_TOTAL *"+STR(_TX)+")-C7_VALICM)*"+cTxIen+") AS VALLIQ "
	cQUERY := cQUERY + " FROM SC7R70, SB1R70 "
	cQUERY := cQUERY + " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
	cQUERY := cQUERY + " AND C7_PRODUTO = B1_COD "
	cQUERY := cQUERY + " AND C7_ENCER <> 'E' "
	cQUERY := cQUERY + "  AND C7_QTDENT <> 0"
	cQUERY := cQUERY + " AND SC7R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND SC7R70.C7_MOEDA = '5' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') "
	cQUERY := cQUERY + " GROUP BY C7_PRODUTO,B1_DESCING "
	cQuery := cQUERY + " union"
	cQuery := cQUERY + " SELECT DISTINCT C7_PRODUTO AS CODIGO "
	cQuery := cQUERY + " , B1_DESCING AS DESCRIC "
	cQuery := cQUERY + " , SUM(C7_QTDENT) AS QTDENT "
	cQuery := cQUERY + " , SUM(C7_TOTAL) AS VALTRAN "
	cQuery := cQUERY + " , SUM(C7_QUANT) AS QUANT " 
	cQUERY := cQUERY + " , SUM(((C7_TOTAL *"+STR(_TX)+")-C7_VALICM)) AS VALLIQ "
	cQUERY := cQUERY + " FROM SC7R70, SB1R70 "
	cQUERY := cQUERY + " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
	cQUERY := cQUERY + " AND C7_PRODUTO = B1_COD " 
	cQUERY := cQUERY + " AND C7_ENCER <> 'E' " 
	cQUERY := cQUERY + "  AND C7_QTDENT <> 0"
	cQUERY := cQUERY + " AND SC7R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND SC7R70.C7_MOEDA = '1' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') "
	cQUERY := cQUERY + " GROUP BY C7_PRODUTO,B1_DESCING " 
	cQUERY := cQUERY + " ORDER BY C7_PRODUTO "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRG',.F.,.T.)
	DBSELECTAREA("TRG")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		INCPROC("GRAVANDO ARQ.TRAB. COMPRAS...." + STR(LASTREC()))
		trf->(dbseek(trg->codigo))
		if !found()
			reclock("trf",.t.)
				trf->codigo := trg->codigo
				trf->descric:= trg->descric
				//trf->quant  := trg->quant
				//trf->valliq := trg->valliq
				trf->qtdent := trg->qtdent    // Wederson 27/10/2004
				trf->valtran:= trg->valtran   // Wederson 27/10/2004
				trf->quants := 0
				trf->valcus := 0				
			msunlock()
		else
			reclock("trf",.f.)
				//trf->quant   := trf->quant + trg->quant
				//trf->valliq  := trf->valliq + trg->valliq	
				trf->qtdent  += trg->qtdent         // Wederson 27/10/2004
				trf->valtran += trg->valtran        // Wederson 27/10/2004
								

		   msunlock()
		endif
		dbselectarea("TRG")
		dbskip()	
	enddo
	dbclosearea("TRG")	

	DbSelectArea("SB2")                  // SALDOS FISICOS/FINANCEIROS DOS PRODUTOS
	_xAliasSiga := "SB2"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REG. CAD. PROD. " + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT B1_COD AS CODIGO, B1_DESCING AS DESCRIC, B1_LOCPAD AS LOCPAD, "
	cQUERY := cQUERY + "B2_QATU AS SALDO, B2_VATU1 AS CUSTO " //Wederson --> 30/08/2004 B2_CM1 = B2_VATU1
	cQUERY := cQUERY + "FROM SB1R70, SB2R70 "
//	cQUERY := cQUERY + " WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND B2_FILIAL = '"+xFilial("SB2")+"' AND SB1R70.D_E_L_E_T_<>'*' AND SB2R70.D_E_L_E_T_<>'*'"   // Comentado por DP 28/12/2004
	cQUERY := cQUERY + " WHERE B2_FILIAL = '"+xFilial("SB2")+"' AND SB1R70.D_E_L_E_T_<>'*' AND SB2R70.D_E_L_E_T_<>'*'"   
	cQUERY := cQUERY + " AND SB1R70.B1_TIPO IN('ME','PP') AND B2_QATU<>0 AND SB1R70.B1_COD = SB2R70.B2_COD " // DP 19/01/2005
	cQUERY := cQUERY + " ORDER BY SB1R70.B1_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRC',.F.,.T.)
	DBSELECTAREA("TRC")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		INCPROC("GRAVANDO ARQ.TRAB. SALDOS " + STR(LASTREC()))
		//cLocal     := TRC->B1_LOCPAD
		//aSaldo     := CalcEst(TRC->CODIGO, cLocal, mv_par02)       /////// CtoD('31/12/49'))
		//nSaldo     := aSaldo[1]

		dbseek(trc->codigo)
		if !found()
			reclock("trf",.t.)
				trf->codigo := trc->codigo
				trf->descric := trc->descric
				trf->quant := 0
				trf->valliq := 0	
				//trf->quants := aSaldo[1]
				//trf->valcus := aSaldo[2]	
				trf->quants := trc->saldo
				trf->valcus += trc->custo	

			msunlock()
		else
			reclock("trf",.f.)
				trf->quants := trf->quants + trc->saldo
				IF trc->custo # 0
					trf->valcus += trc->custo
				ENDIF	
			msunlock()		
		endif
		dbselectarea("TRC")
		dbskip()	
	enddo
	dbclosearea("TRC")	

RETURN

STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO

	If cCombo="Diario"//lDia = .T. .AND. lMes = .F.       //// diario
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

			INCPROC("GRAVANDO PRODUTO: " + ALLTRIM(TRF->CODIGO))
/*
			dbSelectArea('SD1')
			DBSETORDER(2)
			DBGOTOP()
			cCod := TRF->CODIGO     //////// D1_COD                             ///filtra locais de entrada.
	      IF TRF->QUANT <> 0
				If dbSeek(cSeekSD1:=xFilial('SD1')+cCod, .F.)
					Do While !Eof() .And. cSeekSD1==D1_FILIAL+D1_COD
						If aScan(aLocais, D1_LOCAL)==0
							aAdd(aLocais, D1_LOCAL)
						EndIf
						dbSkip()
					EndDo
				EndIf	
				aSort(aLocais,,, {|x, y| x < y})
				For nX := 1 to Len(aLocais)
					cLocal     := aLocais[nX]
					aSaldo     := CalcEst(cCod, cLocal, mv_par02)       /////// CtoD('31/12/49'))
					nSaldo     := aSaldo[1]
			   Next
			ENDIF
			DBSELECTAREA("TRF")
*/
			cREGISTRO := ""           
//	      IF TRF->QUANT <> 0
		   	cREGISTRO := SPACE(20) + "<record business_record_date = '" + "20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"' " 
		   	cREGISTRO := cREGISTRO + " multibrand_code='001'" 
		      cREGISTRO := cREGISTRO + " global_code='" + TRF->codigo + SPACE((15 - LEN(TRF->codigo))) + "' "
		      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      	      
		      cREGISTRO := SPACE(30) + " <receipts quantity='" + STRZERO(TRF->quant,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRF->VALLIQ,16,4) + "'/>" //+ ceol 
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      	      
		      cREGISTRO := SPACE(30) + " <inventory quantity='" + STRZERO(trf->quants,9,3) + "'"   		                          //Wederson 28/08/2004 --> STRZERO((trf->valcus * trf->quants),16,4)
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO((trf->valcus ),16,4) + "'/>" 
		      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      	      
		      cRegistro += " <transit quantity='"+ STRZERO(TRF->QTDENT,9,3)+"' amount='"+ STRZERO(TRF->VALTRAN,16,4) +"'/>"  //Wederson 27/10/2004 --> Nova tag
		      cRegistro += " <consignment quantity='0.000' amount='0.0000'/>"                                                     //Wederson 27/10/2004 --> Nova tag
		      cREGISTRO := cREGISTRO + ceol
/*
	      ELSE
		   	cREGISTRO := SPACE(20) + "<record business_record_date = '" + "20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"' " 
		   	cREGISTRO := cREGISTRO + " multibrand_code='001'" 
		      cREGISTRO := cREGISTRO + " global_code='" + TRF->codigo + SPACE((15 - LEN(TRF->codigo))) + "' "
		      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      
		      cREGISTRO := SPACE(30) + " <receipts quantity='" + STRZERO(TRF->quant,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRF->VALLIQ,16,4) + "'" + "/>" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      
		      cREGISTRO := SPACE(30) + " <inventory quantity='" + STRZERO(trf->quants,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(trf->valcus,16,4) + "'" + "/>" 
		      cREGISTRO := cREGISTRO + ceol
			ENDIF
*/
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(20) + "</record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			TRF->(dbskip())
		enddo
		cREGISTRO := "</data>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    
	ENDIF

	If cCombo ="Mensal" //lDia = .F. .AND. lMes = .T.       //// mensal   
		cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := "<data sales_company_code =" + "'780' " + "system_date= " + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := space(10) + "<monthly>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
	   dbselectarea("TRF")                      
	   DBGOTOP()
		PROCREGUA(7)
		do while !eof() 
			INCPROC("GRAVANDO PRODUTO: " + ALLTRIM(TRF->CODIGO))
/*
			dbSelectArea('SD1')
			DBSETORDER(2)
			DBGOTOP()
			cCod := TRF->CODIGO     //////// D1_COD 
	      IF TRF->QUANT <> 0
				If dbSeek(cSeekSD1:=xFilial('SD1')+cCod, .F.)
					Do While !Eof() .And. cSeekSD1==D1_FILIAL+D1_COD
						If aScan(aLocais, D1_LOCAL)==0
							aAdd(aLocais, D1_LOCAL)
						EndIf
						dbSkip()
					EndDo
				EndIf	
				aSort(aLocais,,, {|x, y| x < y})
				For nX := 1 to Len(aLocais)
					cLocal     := aLocais[nX]
					aSaldo     := CalcEst(cCod, cLocal, mv_par02)       /////// CtoD('31/12/49'))
					nSaldo     := aSaldo[1]
			   Next
			ENDIF
			DBSELECTAREA("TRF")
*/
			cREGISTRO := ""           
//	      IF TRF->QUANT <> 0
		   	cREGISTRO := SPACE(20) + "<record business_record_date = '" + "20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + space(2) + "' "  /////+ substr(dtoc(mv_par02),1,2)+"' " 
		   	cREGISTRO := cREGISTRO + " multibrand_code='001'" 
		      cREGISTRO := cREGISTRO + " global_code='" + TRF->codigo + SPACE((15 - LEN(TRF->codigo))) + "' "
		      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      	      
		      cREGISTRO := SPACE(30) + " <receipts quantity='" + STRZERO(TRF->quant,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRF->VALLIQ,16,4) + "'/>" //+ ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      	      
		      cREGISTRO := SPACE(30) + "  <inventory quantity='" +  STRZERO(trf->quants + TRF->QTDENT,9,3) + "'"  		                            // Wederson 28/08/2004 -->STRZERO((trf->valcus * trf->quants),16,4)
		      cREGISTRO := cREGISTRO + "  amount='" + STRZERO((trf->valcus+TRF->VALTRAN),16,4) + "'/> "
		      FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		      cRegistro := ""
		      cRegistro += " <transit quantity='"+ STRZERO(TRF->QTDENT,9,3)+"' amount='"+ STRZERO(TRF->VALTRAN,16,4) +"'/>"       // Wederson 27/10/2004 --> Nova tag
		      cRegistro += " <consignment quantity='0.000' amount='0.0000' />"                                                          // Wederson 27/10/2004 --> Nova tag
		      cREGISTRO := cREGISTRO + ceol
/*
	      ELSE
		   	cREGISTRO := SPACE(20) + "<record business_record_date = '" + "20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + space(2) + "' "  /////+ substr(dtoc(mv_par02),1,2)+"' " 
		   	cREGISTRO := cREGISTRO + " multibrand_code='001'" 
		      cREGISTRO := cREGISTRO + " global_code='" + TRF->codigo + SPACE((15 - LEN(TRF->codigo))) + "' "
		      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      
		      cREGISTRO := SPACE(30) + " <receipts quantity='" + STRZERO(TRF->quant,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRF->VALLIQ,16,4) + "'" + "/>" + ceol
				FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
				cREGISTRO := ""	      
		      cREGISTRO := SPACE(30) + " <inventory quantity='" + STRZERO(trf->quants,9,3) + "' "
		      cREGISTRO := cREGISTRO + " amount='" + STRZERO(trf->valcus,16,4) + "'" + "/>" 
		      cREGISTRO := cREGISTRO + ceol
			ENDIF
*/
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(20) + "</record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			TRF->(dbskip())
		enddo
		cREGISTRO := SPACE(10) + "</monthly>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""
		cREGISTRO := "</data>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    
	ENDIF

RETURN



STATIC FUNCTION _CRETXT()
	cArqChk	:=	WDIR
	nHdlChk	:=	MsFCreate(cArqChk)
	If nHdlChk < 0
		Break
	EndIf
RETURN

