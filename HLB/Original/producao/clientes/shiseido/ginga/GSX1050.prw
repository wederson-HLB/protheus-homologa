#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF 

/*
Funcao      : GSX1050
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
 User Function GSX1050()
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
SetPrvt("AC_CUSTO_R1,AC_MERC_U1,AC_ICMS_U1,AC_IPI_U1,AC_PIS_U1,AC_COFIN_U1")

cCod := ''
cLocal := ''
cSeeksd1 := ''
nSaldo := 0
nX := 0
aLocais := {}
aSaldo := {}

/*/
----------+-------------------------------------------------------------
Programa  |³GSX1050   | Autor | FRANCISCO F.S. NETO    | Data | 17.09.03
----------|-------------------------------------------------------------
Descri‡…o |WHOLESALE RETAIL PRICE MASTER                                    
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS780SCM05_AAAAMMDD.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/


//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
// 
// multibrand_code         		C     3    0  "001"  - Conteudo fixo
// sales_company_code           	C     3    0  "780"  - Codigo Companhia de Vendas
// shipping_destination_code    	C    15    0  (yyyymmdd) data do sistema 
// global_code				        	C    15    0  codigo do produto
// effective_date_start         	C     8    0  (yyyymmdd) data inicio de vigencia
// effective_date_end         	C     8    0  (yyyymmdd) data termino de validade 
// retail_currency              	N    16    4  ??????????????????????
// retail_unit_price             N    16    4  Preco unitario
// wholesale_currency           	C     3    0  "999" codigo da moeda 
// wholesale_unit_price          N    16    4  Preco unitario com desconto
// cog_currency		            N    16    4  ??????????????????????
// cog_unit_price             	N    16    4  custo medio ult.fechamento
// record_update              	C     8    0  (yyyymmdd) data de criacao 
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
cPerg    :="GS1050    "

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

wdir := 'C:\GINGA\GS780scm05_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '.XML'

wdir :=alltrim(wdir)


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

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML1050 - WholeSale Retail Price Master "  
	@ 001,005 TO 090,200 
	@ 005,020 SAY " Especifico para Shiseido do Brasil !!! "                                           
	@ 015,100 BUTTON "  OK    " SIZE 70,20 ACTION   Processa({|| ATUALIZA() },"Processando...") 
	@ 035,100 BUTTON "  SAIR  " SIZE 70,20 ACTION CLOSE(oDlg2)
	ACTIVATE DIALOG oDlg2 CENTER
	
Return(nil)	

Return

	Processa({||ATUALIZA()})


Return .T.


Static Function ATUALIZA()
/*
	_aCampos := {  {"CODIGO"  ,"C",15,0 } ,;
	               {"DESCRIC" ,"C",30,0 }  ,;
	               {"QUANTR"  ,"N",12,2 } ,;
	               {"QUANTV"  ,"N",12,2 } ,;
	               {"VALLIQR" ,"N",16,2 } ,;
	               {"VALLIQV" ,"N",16,2 } }
	
	_cNome := CriaTrab(_aCampos,.t.)
	dbUseArea(.T.,, _cNome,"TRF",.F.,.F.)
	DbSelectArea("TRF")
	Index on CODIGO to &_cNome
*/

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

	DbSelectArea("SB5")                  // PRECO DE VENDA
	_xAliasSiga := "SB5"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT B5_COD AS CODIGO, B1_DESCING AS DESCRIC, B5_DTREFP2 AS DATAPRC, B5_PRV2 AS PRECO, B2_CM1 AS CUSTO, "
	cQUERY := cQUERY + " Z4_SEDATE AS ENDDATE "
	cQUERY := cQUERY + "FROM SB5R70 AS A, SB2R70 AS B, SB1R70 AS C, SZ4R70 AS D "
	cQUERY := cQUERY + "WHERE  A.D_E_L_E_T_<>'*' AND (A.B5_COD = B.B2_COD AND A.B5_COD = C.B1_COD AND A.B5_COD = D.Z4_GCODE)  "   
	/////cQUERY := cQUERY + " AND (C7_DATPRF>=" + _DATADE + "AND C7_DATPRF<=" +_DATAATE + ")"
	/////cQUERY := cQUERY + "GROUP BY B5_COD " 
	cQUERY := cQUERY + "ORDER BY B5_COD "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
/* 
	while !eof()
		dbselectarea("TRF")
		dbseek(trb->codigo + trb->descric)
		if !found()
			reclock("trf",.t.)
				trf->codigo := trb->codigo
				trf->descric := trb->descric
				trf->quantR := trb->quant
				trf->valliqR := trb->valliq	
			msunlock()
		else
			reclock("trf",.f.)
				trf->quantR := trf->quantR + trb->quant
				trf->valliqR := trf->valliqR + trb->valliq	
			msunlock()
		endif
		dbselectarea("TRB")
		dbskip()	
	enddo
	dbclosearea("trb")	

	DbSelectArea("SC6")                /// PROJECAO DE VENDAS
	_xAliasSiga := "SC6"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT C6_PRODUTO AS CODIGO, C6_DESCRI AS DESCRIC, SUM(C6_QTDVEN - C6_QTDENT) AS QUANT, SUM(((C6_VALOR*0.9535)-(C6_VALOR*0.18))) AS VALLIQ "
	cQUERY := cQUERY + "FROM SC6R70 "
	cQUERY := cQUERY + "WHERE  C6_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D','83A') AND SC6R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND (C6_QTDVEN - C6_QTDENT) > 0 AND (C6_ENTREG>=" + _DATADE + "AND C6_ENTREG<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY C6_PRODUTO,C6_DESCRI " 
	cQUERY := cQUERY + "ORDER BY C6_PRODUTO "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRC',.F.,.T.)
	DBSELECTAREA("TRC")
	DBGOTOP()

	while !eof()
		dbselectarea("TRF")
		dbseek(trc->codigo + trc->descric)
		if !found()
			reclock("trf",.t.)
				trf->codigo := trc->codigo
				trf->descric := trc->descric
				trf->quantV := trc->quant
				trf->valliqV := trc->valliq	
			msunlock()
		else
			reclock("trf",.f.)
				trf->quantV := trf->quantV + trc->quant
				trf->valliqV := trf->valliqV + trc->valliq	
			msunlock()
		endif
		dbselectarea("TRC")
		dbskip()	
	enddo
	dbclosearea("trc")	
*/
                                       
RETURN


STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO
   
	cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	
	cREGISTRO := "<data record_created_by ="  + "'780" + "' >" + ceol     ////////// + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	

   dbselectarea("TRB")                      
   DBGOTOP()
   
	PROCREGUA(7)
	do while !eof() 

		INCPROC("PRODUTO:   " + TRB->CODIGO)

		cREGISTRO := ""           
   	cREGISTRO := SPACE(10) + " <record multibrand_code='001' " 
   	cREGISTRO := cREGISTRO + " sales_company_code='780' " 
      cREGISTRO := cREGISTRO + " shipping_destination_code='" + "780" + "' "
      cREGISTRO := cREGISTRO + " global_code='" + TRB->CODIGO + SPACE((15 - LEN(TRB->CODIGO))) + "' "
      cREGISTRO := cREGISTRO + " effective_date_start='" + TRB->DATAPRC + SPACE((8 - LEN(TRB->DATAPRC))) + "' "
      cREGISTRO := cREGISTRO + " effective_date_end='" + TRB->ENDDATE + SPACE((8 - LEN(TRB->ENDDATE))) + "' "
      cREGISTRO := cREGISTRO + " retail_currency='" + "025" + "' "
      cREGISTRO := cREGISTRO + " retail_unit_price='" +  STRZERO(TRB->PRECO,16,4) + "' "
      cREGISTRO := cREGISTRO + " wholesale_currency='" + "025" + "' "
      cREGISTRO := cREGISTRO + " wholesale_unit_price='" + STRZERO(TRB->PRECO,16,4) + "' "
      cREGISTRO := cREGISTRO + " cog_currency='" + "025" + "' "
      cREGISTRO := cREGISTRO + " cog_unit_price='" + STRZERO(TRB->CUSTO,16,4) + "' "
      cREGISTRO := cREGISTRO + " record_update='" + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + "' "
      cREGISTRO := cREGISTRO + ceol
		
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))

		cREGISTRO := ""
		cREGISTRO := SPACE(10) + "/>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""

		TRB->(dbskip())
			
	enddo

	cREGISTRO := "</data>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    

RETURN


STATIC FUNCTION _CRETXT()
	cArqChk	:=	WDIR
	nHdlChk	:=	MsFCreate(cArqChk)
	If nHdlChk < 0
		Break
	EndIf
RETURN

