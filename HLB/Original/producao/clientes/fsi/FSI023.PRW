#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF 
                   
/*
Funcao      : FSI023
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : VENDAS NO PERIODO POR NOTA FISCAL. 
Autor     	: FRANCISCO F.S. NETO  
Data     	: 27/10/03
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 18/07/2012
Módulo      : Faturamento
Cliente     : FSI
*/

*----------------------*
 User Function FSI023()
*----------------------*

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
SetPrvt("AC_CUSTO_U,AC_CUSTO_U1,_FIMS1,_FIMS2,_FIMS3,_FIMS4,_FIMS5")
SetPrvt("AC_QUANT1,AC_MERC_R1,AC_ICMS_R1,AC_IPI_R1,AC_PIS_R1,AC_COFIN_R1")
SetPrvt("AC_CUSTO_R1,AC_MERC_U1,AC_ICMS_U1,AC_IPI_U1,AC_PIS_U1,AC_COFIN_U1")


/*/
----------+-------------------------------------------------------------
Programa  |³FSI023    | Autor | FRANCISCO F.S. NETO    | Data | 27.10.03
----------|-------------------------------------------------------------
Descri‡…o | VENDAS NO PERIODO POR NOTA FISCAL.                  
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente FSI do Brasil
----------+-------------------------------------------------------------
/*/
//--------------------------------------------------------------
// Define Variaveis
//--------------------------------------------------------------

CbTxt  :=""
CbCont :=""
nOrdem :=0
limite :=220
tamanho:="G"
nTipo  := 0
m_pag  := 1
lin    := 220
_TxLiq := 0.9535
_NTIPO  := 1
_TESTE := ""

_MES := "  "
_QVEN := SPACE(6)
_QNOME := SPACE(50)
_ACUM  := SPACE(10)
_QPRO  := SPACE(16)
_QCLI  := SPACE(6)
_QCODQC := SPACE(6)
_CODQ  := SPACE(16)
_QDESC := SPACE(50)
_QRAZAO := SPACE(50)
_VALMOEDA := 0.00
_DIA   := CTOD("  /  /    ")
_dataver := space(10)

ac_TOT := ARRAY(14)
ac_TOC := ARRAY(14)
ac_TOV := ARRAY(14)

AC_VEN := ARRAY(14)
AC_CUS := ARRAY(14)
AC_IMP := ARRAY(14)
AC_DEV := ARRAY(14)
AC_MAR := ARRAY(14)

TQUANT  := 0
TCUSTO  := 0
TMARGEM := 0
TLIQ    := 0

TQUANTNF  := 0
TCUSTONF  := 0
TMARGEMNF := 0
TLIQNF    := 0

TQUANTCL  := 0
TCUSTOCL  := 0
TMARGEMCL := 0
TLIQCL    := 0

TQUANTPR  := 0
TCUSTOPR  := 0
TMARGEMPR := 0
TLIQPR    := 0


_QNOTA := SPACE(6)
_QCLIE := SPACE(6)
_QPROD := SPACE(15)



FOR X = 1 TO 13
	AC_VEN[X] := 0.00
	AC_TOC[X] := 0.00
	AC_CUS[X] := 0.00
	AC_IMP[X] := 0.00
	AC_DEV[X] := 0.00
	AC_MAR[X] := 0.00
NEXT X

if !u_versm0("EF")    // VERIFICA EMPRESA
   return
endif

_CNAT := "1"

titulo :="VENDAS DO EXERCICIO "

cDesc1 :="Vendas do Exercicio.                                                   "
cDesc2 :="                                                                       "
cDesc3 :="                                                                       "
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
wcabec := .t.

//--------------------------------------------------------------
// Variaveis padrao de todos os relatorios
//--------------------------------------------------------------
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

aLinha   := {}
nomeprog :="FSI023"
nLastKey := 0
cPerg    :="FSI023"
nPagina  := 1
nivel    := 1


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
// mv_par02             // ate Data
// mv_par03             // (F)isica /(J)uridica / (T)udo
//--------------------------------------------------------------
//--------------------------------------------------------------
// Envia controle para a funcao SETPRINT
//--------------------------------------------------------------
cString  :="SD2"
wnrel:="FSI023"   // nome default do relatorio em disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)


SetDefault(aReturn,cString)

RptStatus({|| FSI023BImp()},titulo)

Return


// Rotina para impressao
Static Function FSI023BImp()

	_NTIPO  := 1
	LIN := 66
   if mv_par04 <> "2"
   	IF MV_PAR03 = 1
   		IF MV_PAR05 = "N" 
				titulo :="RESUMO DE VENDAS DO PERIODO POR NOTA FISCAL - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 11
			ELSEIF MV_PAR05 = "C"
				titulo :="RESUMO DE VENDAS DO PERIODO POR CLIENTE - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 21			
			ELSEIF MV_PAR05 = "P"
				titulo :="RESUMO DE VENDAS DO PERIODO POR PRODUTO - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 31
			ENDIF
		ELSE
   		IF MV_PAR05 = "N" 
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR NOTA FISCAL - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 12
			ELSEIF MV_PAR05 = "C"
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR CLIENTE - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 22			
			ELSEIF MV_PAR05 = "P"
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR PRODUTO - VALORES EM R$ SEM IMPOSTOS  "
				_NTIPO := 32
			ENDIF
		ENDIF
   else
   	IF MV_PAR03 = 1
   		IF MV_PAR05 = "N" 
				titulo :="RESUMO DE VENDAS DO PERIODO POR NOTA FISCAL - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 13
			ELSEIF MV_PAR05 = "C"
				titulo :="RESUMO DE VENDAS DO PERIODO POR CLIENTE - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 23			
			ELSEIF MV_PAR05 = "P"
				titulo :="RESUMO DE VENDAS DO PERIODO POR PRODUTO - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 33
			ENDIF
		ELSE
   		IF MV_PAR05 = "N" 
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR NOTA FISCAL - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 14
			ELSEIF MV_PAR05 = "C"
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR CLIENTE - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 24			
			ELSEIF MV_PAR05 = "P"
				titulo :="LISTAGEM DE VENDAS DO PERIODO POR PRODUTO - VALORES EM US$ SEM IMPOSTOS  "
				_NTIPO := 34
			ENDIF
		ENDIF
   endif
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)

//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------
cString  :="SD2"

IF _NTIPO = 11   // RESUMO POR NF - R$
	cabec1  := "            D O C U M E N T O            C  L  I  E  N  T  E                                 V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " DATA       TIPO  N.FISCAL  SERIE  CODIGO   RAZAO SOCIAL                      QUANTIDADE       C U S T O        V E N D A      M A R G E M               "
ELSEIF _NTIPO = 12    // LISTAGEM POR NF - R$
	cabec1  := "           D O C U M E N T O            C  L  I  E  N  T  E                      P  R  O  D  U  T  O                                                V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO   RAZAO SOCIAL                    CODIGO           DESCRICAO                           QUANTIDADE      C U S T O        V E N D A      M A R G E M               "
ELSEIF _NTIPO = 13    // RESUMO POR NF - US$
	cabec1  := "            D O C U M E N T O            C  L  I  E  N  T  E                                 V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " DATA       TIPO  N.FISCAL  SERIE  CODIGO   RAZAO SOCIAL                      QUANTIDADE       C U S T O        V E N D A      M A R G E M               "
ELSEIF _NTIPO = 14    // LISTAGEM POR NF - US$
	cabec1  := "           D O C U M E N T O            C  L  I  E  N  T  E                      P  R  O  D  U  T  O                                                V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO   RAZAO SOCIAL                    CODIGO           DESCRICAO                           QUANTIDADE      C U S T O        V E N D A      M A R G E M               "
ELSEIF _NTIPO = 21    // RESUMO POR CLIENTE - R$
	cabec1  := " C  L  I  E  N  T  E                                        V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " CODIGO   RAZAO SOCIAL                        QUANTIDADE        C U S T O        V E N D A    M A R G E M               "
ELSEIF _NTIPO = 22    // LISTAGEM POR CLIENTE - R$
	cabec1  := " C  L  I  E  N  T  E                                  D O C U M E N T O            P  R  O  D  U  T  O                                                 V A L O R  DO    V A L O R  DA    V A L O R  DA           "
	cabec2  := " CODIGO   RAZAO SOCIAL                      DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO           DESCRICAO                         QUANTIDADE         C U S T O        V E N D A      M A R G E M             "
ELSEIF _NTIPO = 23    // RESUMO POR CLIENTE - US$ 
	cabec1  := " C  L  I  E  N  T  E                                        V A L O R  DO    V A L O R  DA    V A L O R  DA             "
	cabec2  := " CODIGO   RAZAO SOCIAL                        QUANTIDADE        C U S T O        V E N D A    M A R G E M               "
ELSEIF _NTIPO = 24    // LISTAGEM POR CLIENTE US$
	cabec1  := " C  L  I  E  N  T  E                                  D O C U M E N T O            P  R  O  D  U  T  O                                                 V A L O R  DO    V A L O R  DA    V A L O R  DA           "
	cabec2  := " CODIGO   RAZAO SOCIAL                      DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO           DESCRICAO                         QUANTIDADE         C U S T O        V E N D A      M A R G E M             "
ELSEIF _NTIPO = 31    // RESUMO POR PRODUTO - R$
	cabec1  := " P  R  O  D  U  T  O                                                 V A L O R  DO    V A L O R  DA    V A L O R  DA            "
	cabec2  := " CODIGO           DESCRICAO                             QUANTIDADE     C U S T O        V E N D A      M A R G E M              "
ELSEIF _NTIPO = 32    // LISTAGEM POR PRODUTO - R$
	cabec1  := " P  R  O  D  U  T  O                              D O C U M E N T O                      C  L  I  E  N  T  E                                         V A L O R  DO    V A L O R  DA    V A L O R  DA           "
	cabec2  := " CODIGO           DESCRICAO                       DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO   RAZAO SOCIAL                         QUANTIDADE     C U S T O        V E N D A      M A R G E M              "
ELSEIF _NTIPO = 33    // RESUMO POR PRODUTO - US$
	cabec1  := " P  R  O  D  U  T  O                                                 V A L O R  DO    V A L O R  DA    V A L O R  DA            "
	cabec2  := " CODIGO           DESCRICAO                             QUANTIDADE     C U S T O        V E N D A      M A R G E M              "
ELSEIF _NTIPO = 34    // LISTAGEM POR PRODUTO - US$
	cabec1  := " P  R  O  D  U  T  O                              D O C U M E N T O                      C  L  I  E  N  T  E                                         V A L O R  DO    V A L O R  DA    V A L O R  DA           "
	cabec2  := " CODIGO           DESCRICAO                       DATA      TIPO  N.FISCAL  SERIE  ITEM  CODIGO   RAZAO SOCIAL                         QUANTIDADE     C U S T O        V E N D A      M A R G E M              "
ENDIF


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

_dataini := mv_par01
_datafim := mv_par02       

Processa({||ATUALIZA()})
if wcabec
	SomaLin()
	Roda(nCntImpr,cRodaTxt,Tamanho)
endif


//--------------------------------------------------------------
// Restaura Ambiente
//--------------------------------------------------------------
//dbSelectArea("TRB")
//DbCloseArea("TRB")
// Erase &_cNome+".DBF"
Set Device To Screen
SetPgEject(.F.)
#IFNDEF WINDOWS
	RestScreen(3,0,24,79,cSavScr1)
#ENDIF
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

Return .T.


Static Function ATUALIZA()

	IF MV_PAR05 = "N"
		_fSELVENNF()      	// Select para Vendas por Nota Fiscal
		_fIMPDETNF()         // Impressao por Nota Fiscal
		_fIMPTOTNF()         // Totaliza por Nota Fiscal
   ELSEIF MV_PAR05 = "C"
		_fSELVENCL()      	// Select para Vendas por Cliente
		_fIMPDETCL()         // Impressao por Cliente
		_fIMPTOTCL()         // Totaliza por Cliente   
   ELSEIF MV_PAR05 = "P"
		_fSELVENPR()      	// Select para Vendas por Produto
		_fIMPDETPR()         // Impressao por Produto
		_fIMPTOTPR()         // Totaliza por Produto 
   ENDIF

RETURN

	
	//// _fIMPRES()       // RESUMO


	dbCloseArea()			
	
RETURN .T.


Static Function Somalin()
	lin := lin + 1
	if lin > 55 .and. wcabec
		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		lin := 10
	endif
Return

Static Function ValidPerg()

	_sAlias := Alias()
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,6)
	aRegs := {}
	
	// Grupo       /Ordem  /Pergunta  /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","De data de Emissao  ?","","","mv_ch1","D",08,0,0,"G","      ","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"02","Ate data de Emissao ?","","","mv_ch2","D",08,0,0,"G","      ","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"03","Imprimir Sintetico  ?","","","mv_ch3","N",01,0,1,"C","      ","mv_par03","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"04","1=Real / 2=Dolar    ?","","","mv_ch4","C",01,0,1,"G","      ","mv_par04","1"  ,"","","","","2"  ,"","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"05","NOTA/CLIENTE/PROD.  ?","","","mv_ch5","C",01,0,1,"G","      ","mv_par05","N"  ,"","","","","C"  ,"","","","","P","","","","","","","","","","","","","","",   ""})
	
	
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


STATIC FUNCTION _fSELVENNF()           // VENDAS POR NOTA FISCAL

	DbSelectArea("SD2")
	_xAliasSiga := "SD2"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQuery:=  " SELECT D2_EMISSAO,D2_CLIENTE,D2_LOJA,A1_NOME,D2_COD,B1_DESC,D2_DOC,D2_SERIE,D2_TES,D2_CF, D2_QUANT, " 
	///// cQUERY:= cQUERY + " (D2_QUANT - D2_QTDEDEV) AS QUANT, "
	cQUERY:= cQUERY + " ((D2_TOTAL*.9535)-D2_VALICM) AS VALLIQ,D2_VALICM,D2_CUSTO1,D2_VALIPI,D2_ITEM,D2_TIPO,  "
	cQUERY:= cQUERY + " (D2_TOTAL*.0465) AS PISCOF, (((D2_TOTAL*.9535)-D2_VALICM)- D2_CUSTO1) AS MARGEM "
	cQUERY:= cQUERY + " FROM  SD2EF0, SB1EF0, SA1EF0 "
	cQuery:=	cQUERY + " WHERE  D2_COD = B1_COD AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) AND "
	cQUERY:= cQUERY + " (D2_EMISSAO >= " +_DataDe+" AND D2_EMISSAO<= " + _DataAte + ") AND (D2_QUANT - D2_QTDEDEV)>0 " 
	cQUERY:= cQUERY + " AND D2_TIPO = 'N' AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D')"
	cQUERY:= cQUERY + " AND (SD2EF0.D_E_L_E_T_<>'*' AND SB1EF0.D_E_L_E_T_<>'*' AND SA1EF0.D_E_L_E_T_<>'*') " 
	cQUERY:= cQUERY + " ORDER BY D2_EMISSAO + D2_DOC + D2_ITEM "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN


STATIC FUNCTION _fIMPDETNF()              /// impressao por Nota Fiscal

	SetRegua(lastrec())
	PROCREGUA(7)

   dbselectarea("TRB")
   DBGOTOP()

	_QNOTA := TRB->D2_DOC

	do while !eof()                                

		INCPROC("Data : " + TRB->D2_EMISSAO + " / " + TRB->D2_DOC )

		IF TRB->D2_DOC <> _QNOTA .AND. MV_PAR03 = 1
			_fRESNF()
		ENDIF

		_DIA := CTOD(SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2))
      VALMOEDA := RECMOEDA(_DIA,"2")
		IF MV_PAR03 <> 1

	      SomaLin()
			@ LIN,001 PSAY SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2)
		  	@ LIN,013 PSAY SUBSTR(TRB->D2_TIPO,1,2)
		  	@ LIN,017 PSAY SUBSTR(TRB->D2_DOC,1,6)
		  	@ LIN,029 PSAY substr(TRB->D2_SERIE,1,3)
		  	@ LIN,036 PSAY substr(TRB->D2_ITEM,1,2)
		  	@ LIN,040 PSAY substr(TRB->D2_CLIENTE,1,6)
		  	@ LIN,049 PSAY substr(TRB->A1_NOME,1,30)
		  	@ LIN,081 PSAY substr(TRB->D2_COD,1,15)
		  	@ LIN,098 PSAY substr(TRB->B1_DESC,1,30)
			@ LIN,130 PSAY TRB->D2_QUANT     picture "@E 999,999,999.99"
         IF MV_PAR04 = '2'
				@ LIN,147 PSAY (TRB->D2_CUSTO1/VALMOEDA)     picture "@E 999,999,999.99"
			  	@ LIN,164 PSAY (TRB->VALLIQ/VALMOEDA)     	picture "@E 999,999,999.99"
				@ LIN,181 PSAY (TRB->MARGEM/VALMOEDA)		  	picture "@E 999,999,999.99"
         ELSE
				@ LIN,147 PSAY TRB->D2_CUSTO1    picture "@E 999,999,999.99"
			  	@ LIN,164 PSAY TRB->VALLIQ     	picture "@E 999,999,999.99"
				@ LIN,181 PSAY TRB->MARGEM		  	picture "@E 999,999,999.99"
         ENDIF
      ELSE

			TQUANTNF := TQUANTNF + TRB->D2_QUANT
			IF MV_PAR04 = '2'
				TCUSTONF := TCUSTONF + (TRB->D2_CUSTO1/VALMOEDA)
				TMARGEMNF:= TMARGEMNF + (TRB->MARGEM/VALMOEDA)
				TLIQNF   := TLIQNF + (TRB->VALLIQ/VALMOEDA)      			
			ELSE
				TCUSTONF := TCUSTONF + TRB->D2_CUSTO1
				TMARGEMNF:= TMARGEMNF + TRB->MARGEM
				TLIQNF   := TLIQNF + TRB->VALLIQ      
	      ENDIF
      ENDIF
      
		TQUANT  := TQUANT + TRB->D2_QUANT
		IF MV_PAR04 = '2'
			TCUSTO  := TCUSTO + (TRB->D2_CUSTO1/VALMOEDA)
			TMARGEM := TMARGEM + (TRB->MARGEM/VALMOEDA)
			TLIQ    := TLIQ + (TRB->VALLIQ/VALMOEDA)
		ELSE
			TCUSTO  := TCUSTO + TRB->D2_CUSTO1
			TMARGEM := TMARGEM + TRB->MARGEM
			TLIQ    := TLIQ + TRB->VALLIQ
      ENDIF

      dbskip()

   enddo

RETURN

STATIC FUNCTION _fRESNF()              /// RESUMO NOTA FISCAL
   SomaLin()
	@ LIN,001 PSAY SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2)
  	@ LIN,013 PSAY SUBSTR(TRB->D2_TIPO,1,2)
  	@ LIN,018 PSAY SUBSTR(TRB->D2_DOC,1,6)
  	@ LIN,028 PSAY substr(TRB->D2_SERIE,1,3)
  	@ LIN,035 PSAY substr(TRB->D2_CLIENTE,1,6)
  	@ LIN,044 PSAY substr(TRB->A1_NOME,1,28)
	@ LIN,074 PSAY TQUANTNF    picture "@E 999,999,999.99"
	@ LIN,092 PSAY TCUSTONF    picture "@E 999,999,999.99"
	@ LIN,109 PSAY TLIQNF      picture "@E 999,999,999.99"
	@ LIN,126 PSAY TMARGEMNF 	picture "@E 999,999,999.99"

	_QNOTA := TRB->D2_DOC
   TQUANTNF := 0
   TCUSTONF := 0
   TLIQNF   := 0
   TMARGEMNF:= 0

RETURN


STATIC FUNCTION _fIMPTOTNF()           /// TOTAIS POR NOTA FISCAL

      SomaLin()
      SomaLin()
		IF _NTIPO = 12 .OR. _NTIPO = 14
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,130 PSAY TQUANT     picture "@E 999,999,999.99"
			@ LIN,147 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,164 PSAY TLIQ     	picture "@E 999,999,999.99"
			@ LIN,181 PSAY TMARGEM		  	picture "@E 999,999,999.99"
      ELSE
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,074 PSAY TQUANT     picture "@E 999,999,999.99"
			@ LIN,092 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,109 PSAY TLIQ     	picture "@E 999,999,999.99"
			@ LIN,126 PSAY TMARGEM		  	picture "@E 999,999,999.99"      
      ENDIF
      
		TQUANT  := 0
		TCUSTO  := 0
		TMARGEM := 0
		TLIQ    := 0

		DBCLOSEAREA()   

RETURN


STATIC FUNCTION _fSELVENCL()           // VENDAS POR Cliente

	DbSelectArea("SD2")
	_xAliasSiga := "SD2"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQuery:=  " SELECT D2_EMISSAO,D2_CLIENTE,D2_LOJA,A1_NOME,D2_COD,B1_DESC,D2_DOC,D2_SERIE,D2_TES,D2_CF, D2_QUANT, " 
	///// cQUERY:= cQUERY + " (D2_QUANT - D2_QTDEDEV) AS QUANT, "
	cQUERY:= cQUERY + " ((D2_TOTAL*.9535)-D2_VALICM) AS VALLIQ,D2_VALICM,D2_CUSTO1,D2_VALIPI,D2_ITEM,D2_TIPO,  "
	cQUERY:= cQUERY + " (D2_TOTAL*.0465) AS PISCOF, (((D2_TOTAL*.9535)-D2_VALICM)- D2_CUSTO1) AS MARGEM "
	cQUERY:= cQUERY + " FROM  SD2EF0, SB1EF0, SA1EF0 "
	cQuery:= cQUERY + " WHERE  D2_COD = B1_COD AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) AND "
	cQUERY:= cQUERY + " (D2_EMISSAO >= " +_DataDe+" AND D2_EMISSAO<= " + _DataAte + ") AND (D2_QUANT - D2_QTDEDEV)>0 " 
	cQUERY:= cQUERY + " AND D2_TIPO = 'N' AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D')"
	cQUERY:= cQUERY + " AND (SD2EF0.D_E_L_E_T_<>'*' AND SB1EF0.D_E_L_E_T_<>'*' AND SA1EF0.D_E_L_E_T_<>'*') " 
	cQUERY:= cQUERY + " ORDER BY D2_CLIENTE + D2_DOC + D2_ITEM "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN


STATIC FUNCTION _fIMPDETCL()             /// impressao por cliente

	SetRegua(lastrec())
	PROCREGUA(7)

   dbselectarea("TRB")
   DBGOTOP()

	_QCLIE := TRB->D2_CLIENTE

	do while !eof() 

		INCPROC("CLIENTE : " + TRB->D2_CLIENTE + " / " + TRB->D2_DOC )

		IF TRB->D2_CLIENTE <> _QCLIE .AND. MV_PAR03 = 1
			_fRESCL()
		ENDIF

		_DIA := CTOD(SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2))
      VALMOEDA := RECMOEDA(_DIA,"2")

		IF MV_PAR03 <> 1
	      SomaLin()
		  	@ LIN,001 PSAY substr(TRB->D2_CLIENTE,1,6)
		  	@ LIN,010 PSAY substr(TRB->A1_NOME,1,30)
			@ LIN,044 PSAY SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2)
		  	@ LIN,054 PSAY SUBSTR(TRB->D2_TIPO,1,2)
		  	@ LIN,060 PSAY SUBSTR(TRB->D2_DOC,1,6)
		  	@ LIN,070 PSAY substr(TRB->D2_SERIE,1,3)
		  	@ LIN,077 PSAY substr(TRB->D2_ITEM,1,2)
		  	@ LIN,083 PSAY substr(TRB->D2_COD,1,15)
		  	@ LIN,100 PSAY substr(TRB->B1_DESC,1,28)
			@ LIN,130 PSAY TRB->D2_QUANT     picture "@E 999,999,999.99"
         IF MV_PAR04 = '2'
				@ LIN,150 PSAY (TRB->D2_CUSTO1/VALMOEDA)     picture "@E 999,999,999.99"
			  	@ LIN,167 PSAY (TRB->VALLIQ/VALMOEDA)     	picture "@E 999,999,999.99"
				@ LIN,184 PSAY (TRB->MARGEM/VALMOEDA)		  	picture "@E 999,999,999.99"
         ELSE
				@ LIN,150 PSAY TRB->D2_CUSTO1    picture "@E 999,999,999.99"
			  	@ LIN,167 PSAY TRB->VALLIQ     	picture "@E 999,999,999.99"
				@ LIN,184 PSAY TRB->MARGEM		  	picture "@E 999,999,999.99"
         ENDIF
	
      ELSE
			TQUANTCL  := TQUANTCL + TRB->D2_QUANT
         IF MV_PAR04 = '2'
				TCUSTOCL  := TCUSTOCL + (TRB->D2_CUSTO1/VALMOEDA)
				TMARGEMCL := TMARGEMCL + (TRB->MARGEM/VALMOEDA)
				TLIQCL    := TLIQCL + (TRB->VALLIQ/VALMOEDA)      
	   	ELSE
				TQUANTCL  := TQUANTCL + TRB->D2_QUANT
				TCUSTOCL  := TCUSTOCL + TRB->D2_CUSTO1
				TMARGEMCL := TMARGEMCL + TRB->MARGEM
				TLIQCL    := TLIQCL + TRB->VALLIQ             
         ENDIF
		ENDIF
		TQUANT  := TQUANT + TRB->D2_QUANT
      IF MV_PAR04 = '2'
			TCUSTO  := TCUSTO + (TRB->D2_CUSTO1/VALMOEDA)
			TMARGEM := TMARGEM + (TRB->MARGEM/VALMOEDA)
			TLIQ    := TLIQ + (TRB->VALLIQ/VALMOEDA)
      ELSE
			TCUSTO  := TCUSTO + TRB->D2_CUSTO1
			TMARGEM := TMARGEM + TRB->MARGEM
			TLIQ    := TLIQ + TRB->VALLIQ      
      ENDIF
      
      dbskip()

   enddo

RETURN


STATIC FUNCTION _fRESCL()              /// TOTAL DO CLIENTE
   SomaLin()
  	@ LIN,001 PSAY substr(TRB->D2_CLIENTE,1,6)
  	@ LIN,010 PSAY substr(TRB->A1_NOME,1,30)
	@ LIN,042 PSAY TQUANTCL    picture "@E 999,999,999.99"
	@ LIN,059 PSAY TCUSTOCL    picture "@E 999,999,999.99"
	@ LIN,076 PSAY TLIQCL      picture "@E 999,999,999.99"
	@ LIN,093 PSAY TMARGEMCL 	picture "@E 999,999,999.99"

	_QCLIE := TRB->D2_CLIENTE
   TQUANTCL := 0
   TCUSTOCL := 0
   TLIQCL   := 0
   TMARGEMCL:= 0

RETURN


STATIC FUNCTION _fIMPTOTCL()         /// TOTAIS POR CLIENTE

      SomaLin()
      SomaLin()
		IF _NTIPO = 22 .OR.  _NTIPO = 24
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,130 PSAY TQUANT     picture "@E 999,999,999.99"
			@ LIN,150 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,167 PSAY TLIQ     	picture "@E 999,999,999.99"
			@ LIN,184 PSAY TMARGEM		  	picture "@E 999,999,999.99"
      ELSE
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,042 PSAY TQUANT     picture "@E 999,999,999.99"
			@ LIN,059 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,076 PSAY TLIQ     	picture "@E 999,999,999.99"
			@ LIN,093 PSAY TMARGEM		  	picture "@E 999,999,999.99"
      ENDIF
		TQUANT  := 0
		TCUSTO  := 0
		TMARGEM := 0
		TLIQ    := 0

		DBCLOSEAREA()   

RETURN


STATIC FUNCTION _fSELVENPR()           // VENDAS POR PRODUTO

	DbSelectArea("SD2")
	_xAliasSiga := "SD2"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQuery:=  " SELECT D2_EMISSAO,D2_CLIENTE,D2_LOJA,A1_NOME,D2_COD,B1_DESC,D2_DOC,D2_SERIE,D2_TES,D2_CF, D2_QUANT, " 
	///// cQUERY:= cQUERY + " (D2_QUANT - D2_QTDEDEV) AS QUANT, "
	cQUERY:= cQUERY + " ((D2_TOTAL*.9535)-D2_VALICM) AS VALLIQ,D2_VALICM,D2_CUSTO1,D2_VALIPI,D2_ITEM,D2_TIPO,  "
	cQUERY:= cQUERY + " (D2_TOTAL*.0465) AS PISCOF, (((D2_TOTAL*.9535)-D2_VALICM)- D2_CUSTO1) AS MARGEM "
	cQUERY:= cQUERY + " FROM  SD2EF0, SB1EF0, SA1EF0 "
	cQuery:=	cQUERY + " WHERE  D2_COD = B1_COD AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) AND "
	cQUERY:= cQUERY + " (D2_EMISSAO >= " +_DataDe+" AND D2_EMISSAO<= " + _DataAte + ") AND (D2_QUANT - D2_QTDEDEV)>0 " 
	cQUERY:= cQUERY + " AND D2_TIPO = 'N' AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D')"
	cQUERY:= cQUERY + " AND (SD2EF0.D_E_L_E_T_<>'*' AND SB1EF0.D_E_L_E_T_<>'*' AND SA1EF0.D_E_L_E_T_<>'*') " 
	cQUERY:= cQUERY + " ORDER BY D2_COD + D2_DOC + D2_ITEM "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN


STATIC FUNCTION _fIMPDETPR()          /// IMPRESSAO POR PRODUTO

	SetRegua(lastrec())
	PROCREGUA(7)

   dbselectarea("TRB")
   DBGOTOP()

	_QPROD := TRB->D2_COD

	do while !eof() 

		INCPROC("PRODUTO : " + TRB->D2_COD + TRB->D2_DOC )

		IF TRB->D2_COD <> _QPROD .AND. MV_PAR03 = 1
			_fRESPR()
		ENDIF

		_DIA := CTOD(SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2))
      VALMOEDA := RECMOEDA(_DIA,"2")

		IF MV_PAR03 <> 1

	      SomaLin()

		  	@ LIN,001 PSAY substr(TRB->D2_COD,1,15)
		  	@ LIN,018 PSAY substr(TRB->B1_DESC,1,30)
			@ LIN,050 PSAY SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2)
		  	@ LIN,060 PSAY SUBSTR(TRB->D2_TIPO,1,2)
		  	@ LIN,066 PSAY SUBSTR(TRB->D2_DOC,1,6)
		  	@ LIN,076 PSAY substr(TRB->D2_SERIE,1,3)
		  	@ LIN,083 PSAY substr(TRB->D2_ITEM,1,2)
		  	@ LIN,089 PSAY substr(TRB->D2_CLIENTE,1,6)
		  	@ LIN,098 PSAY substr(TRB->A1_NOME,1,30)
			@ LIN,131 PSAY TRB->D2_QUANT     picture "@E 999,999,999.99"
         IF MV_PAR04 = '2'
				@ LIN,148 PSAY (TRB->D2_CUSTO1/VALMOEDA)     picture "@E 999,999,999.99"
			  	@ LIN,165 PSAY (TRB->VALLIQ/VALMOEDA)     	picture "@E 999,999,999.99"
				@ LIN,182 PSAY (TRB->MARGEM/VALMOEDA)		  	picture "@E 999,999,999.99"
         ELSE
				@ LIN,148 PSAY TRB->D2_CUSTO1    picture "@E 999,999,999.99"
			  	@ LIN,165 PSAY TRB->VALLIQ     	picture "@E 999,999,999.99"
				@ LIN,182 PSAY TRB->MARGEM		  	picture "@E 999,999,999.99"
         ENDIF
	      
		ELSE

			TQUANTPR  := TQUANTPR + TRB->D2_QUANT
			IF MV_PAR04 = '2'
				TCUSTOPR := TCUSTOPR + (TRB->D2_CUSTO1/VALMOEDA)
				TMARGEMPR:= TMARGEMPR + (TRB->MARGEM/VALMOEDA)
				TLIQPR   := TLIQPR + (TRB->VALLIQ/VALMOEDA)      			
			ELSE
				TCUSTOPR := TCUSTOPR + TRB->D2_CUSTO1
				TMARGEMPR:= TMARGEMPR + TRB->MARGEM
				TLIQPR   := TLIQPR + TRB->VALLIQ      
	      ENDIF
      ENDIF
      
		TQUANT  := TQUANT + TRB->D2_QUANT
		IF MV_PAR04 = '2'
			TCUSTO  := TCUSTO + (TRB->D2_CUSTO1/VALMOEDA)
			TMARGEM := TMARGEM + (TRB->MARGEM/VALMOEDA)
			TLIQ    := TLIQ + (TRB->VALLIQ/VALMOEDA)
		ELSE
			TCUSTO  := TCUSTO + TRB->D2_CUSTO1
			TMARGEM := TMARGEM + TRB->MARGEM
			TLIQ    := TLIQ + TRB->VALLIQ
      ENDIF

      dbskip()

   enddo

RETURN


STATIC FUNCTION _fIMPTOTPR()          /// TOTAIS POR PRODUTO

      SomaLin()
      SomaLin()
		IF _NTIPO = 32 .OR. _NTIPO = 34
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,131 PSAY TQUANT    picture "@E 999,999,999.99"
			@ LIN,148 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,165 PSAY TLIQ      picture "@E 999,999,999.99"
			@ LIN,182 PSAY TMARGEM	 picture "@E 999,999,999.99"
      ELSE
			@ LIN,001 PSAY "TOTAIS DO PERIODO ======>   "
			@ LIN,052 PSAY TQUANT    picture "@E 999,999,999.99"
			@ LIN,068 PSAY TCUSTO    picture "@E 999,999,999.99"
		  	@ LIN,085 PSAY TLIQ      picture "@E 999,999,999.99"
			@ LIN,102 PSAY TMARGEM	 picture "@E 999,999,999.99"
      ENDIF
      
		TQUANT  := 0
		TCUSTO  := 0
		TMARGEM := 0
		TLIQ    := 0

		DBCLOSEAREA()   

RETURN


STATIC FUNCTION _fRESPR()              /// TOTAL DO PRODUTO

   SomaLin()
  	@ LIN,001 PSAY substr(TRB->D2_COD,1,15)
  	@ LIN,018 PSAY substr(TRB->B1_DESC,1,30)
	@ LIN,052 PSAY TQUANTPR    picture "@E 999,999,999.99"
	@ LIN,068 PSAY TCUSTOPR    picture "@E 999,999,999.99"
	@ LIN,085 PSAY TLIQPR      picture "@E 999,999,999.99"
	@ LIN,102 PSAY TMARGEMPR 	picture "@E 999,999,999.99"

	_QPROD := TRB->D2_COD
   TQUANTPR := 0
   TCUSTOPR := 0
   TLIQPR   := 0
   TMARGEMPR:= 0

RETURN



STATIC FUNCTION _fDETCLI()              /// RESUMO CLIENTE
   SomaLin()

  	@ LIN,001 PSAY substr(TRB->D2_CLIENTE,1,6)
  	@ LIN,010 PSAY substr(TRB->A1_NOME,1,30)
	@ LIN,044 PSAY SUBSTR(TRB->D2_EMISSAO,7,2) + "/" + SUBSTR(TRB->D2_EMISSAO,5,2) + "/" + SUBSTR(TRB->D2_EMISSAO,3,2)
  	@ LIN,056 PSAY SUBSTR(TRB->D2_TIPO,1,2)
  	@ LIN,060 PSAY SUBSTR(TRB->D2_DOC,1,6)
  	@ LIN,072 PSAY substr(TRB->D2_SERIE,1,3)
  	@ LIN,079 PSAY substr(TRB->D2_ITEM,1,2)
  	@ LIN,083 PSAY substr(TRB->D2_COD,1,15)
  	@ LIN,0100 PSAY substr(TRB->B1_DESC,1,30)
	@ LIN,132 PSAY TQUANTCL    picture "@E 999,999,999.99"
	@ LIN,149 PSAY TCUSTOCL    picture "@E 999,999,999.99"
	@ LIN,166 PSAY TLIQCL      picture "@E 999,999,999.99"
	@ LIN,183 PSAY TMARGEMCL 	picture "@E 999,999,999.99"

	_QCLIE := TRB->D2_CLIENTE
   TQUANTCL := 0
   TCUSTOCL := 0
   TLIQCL   := 0
   TMARGEMCL:= 0

RETURN


