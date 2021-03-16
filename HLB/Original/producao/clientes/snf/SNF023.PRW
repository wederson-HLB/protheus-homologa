#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF 


/*
Funcao      : SNF023
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Vendas no periodo por cliente	  
Autor     	: 
Data     	: 
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Faturamento
Cliente     : SNF
*/

*---------------------*
 User Function SNF023()
*---------------------* 

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

If !(cEmpAnt $ "BH" )  
   MsgStop("Rotina especifica SNF","Atenção") 
   Return .F.
EndIf



/*/
----------+-------------------------------------------------------------
Programa  |³SNF023    | Autor | FRANCISCO F.S. NETO    | Data | 08.07.03
----------|-------------------------------------------------------------
Descri‡…o | VENDAS NO PERIODO POR CLIENTE / PRODUTO.                  
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SNF do Brasil
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
_NREL  := 1


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

FOR X = 1 TO 13
	AC_VEN[X] := 0.00
	AC_TOC[X] := 0.00
	AC_CUS[X] := 0.00
	AC_IMP[X] := 0.00
	AC_DEV[X] := 0.00
	AC_MAR[X] := 0.00
NEXT X

if !u_versm0("BH")    // VERIFICA EMPRESA
   return
endif

static _CNAT := "1"

titulo :="VENDAS DO EXERCICIO POR CLIENTE / PRODUTO"

cDesc1 :="Vendas do Exercicio por Cliente / Produto.                             "
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
nomeprog :="SNF023"
nLastKey := 0
cPerg    :="SNF023    "
nPagina  := 1
nivel    := 1

/*

_aCampos := {  {"CODVEN"   ,"C",06,0 } ,;
					{"NOMVEN"   ,"C",30,2 } ,;
					{"VLRJAN"   ,"N",14,2 } ,;
					{"VLRFEV"   ,"N",14,2 } ,;
					{"VLRMAR"   ,"N",14,2 } ,;
					{"VLRABR"   ,"N",14,2 } ,;
					{"VLRMAI"   ,"N",14,2 } ,;
					{"VLRJUN"   ,"N",14,2 } ,;
					{"VLRJUL"   ,"N",14,2 } ,;
					{"VLRAGO"   ,"N",14,2 } ,;
					{"VLRSET"   ,"N",14,2 } ,;
					{"VLROUT"   ,"N",14,2 } ,;
					{"VLRNOV"   ,"N",14,2 } ,;
					{"VLRDEZ"   ,"N",14,2 } }


*----------------CRIARQ-----------------
_cNome := CriaTrab(_aCampos,.t.)
_cChave := "CODVEN"
dbUseArea(.T.,, _cNome,"VEN",.F.,.F.)
DbSelectArea("TCF")
Indregua("VEN",_cNome,_cChave,,,"Selecionando Regs...")

*/

//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------
cString  :="SD2"
cabec1  := "     P  r  o  d  u  t  o                                                                                                                                                                                                                                         "
cabec2  := "  Codigo    D e s c r i c a o                Janeiro    Fevereiro        Marco        Abril         Maio        Junho        Julho       Agosto     Setembro      Outubro     Novembro     Dezembro      Acumulado"
*            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
*                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        
*             XXXXXX AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXX,XXX,XXX.XX


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

wnrel:="SNF023"   // nome default do relatorio em disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)


SetDefault(aReturn,cString)

RptStatus({|| SNF023BImp()},titulo)

Return


// Rotina para impressao
Static Function SNF023BImp()
IF MV_PAR04 <> "2"
	titulo :="VENDAS NO EXERCICIO POR CLIENTE / PRODUTO - VALORES EM R$ SEM IMPOSTOS  "
ELSE
	titulo :="VENDAS NO EXERCICIO POR CLIENTE / PRODUTO - VALORES EM US$ SEM IMPOSTOS "
ENDIF
titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
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

	_fSELECTVEN()      // SELECT PARA VENDAS
	
	_fIMPRESST()       // IMPRESSAO
	
	_fIMPTOT()         // TOTALIZA

/// CUSTOS

	_NREL  := 2
	LIN := 66
   IF MV_PAR04 <> "2"
		titulo :="CUSTO DOS PRODUTOS VENDIDOS - VALORES EM R$ SEM IMPOSTOS  "
   ELSE
   	titulo :="CUSTO DOS PRODUTOS VENDIDOS - VALORES EM US$ SEM IMPOSTOS "
   ENDIF
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
	
	_fIMPRESST()       // IMPRESSAO
	
	_fIMPTOT()         // TOTALIZA


/// MARGEM DE LUCRO

	_NREL  := 6
	LIN := 66
   IF MV_PAR04 <> "2"
		titulo :="MARGEM DE LUCROS S/VENDAS   - VALORES EM R$ SEM IMPOSTOS  "
   ELSE
   	titulo :="MARGEM DE LUCROS S/VENDAS   - VALORES EM US$ SEM IMPOSTOS "
   ENDIF
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
	
	_fIMPRESST()       // IMPRESSAO
	
	_fIMPTOT()         // TOTALIZA

/// IMPOSTOS

	_NREL  := 3
	LIN := 66
   IF MV_PAR04 <> "2"
		titulo :="IMPOSTOS SOBRE VENDAS DE PRODUTOS - VALORES EM R$  "
   ELSE
   	titulo :="IMPOSTOS SOBRE VENDAS DE PRODUTOS - VALORES EM US$ "
   ENDIF
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
	
	_fIMPRESST()       // IMPRESSAO
	
	_fIMPTOT()         // TOTALIZA	

	dbCloseArea()			

	_fSELECTDEV()      // SELECT PARA DEVOLUCOES
	

	_NREL  := 4
	LIN := 66
   IF MV_PAR04 <> "2"
		titulo :="DEVOLUCOES DE VENDAS POR PRODUTOS - VALORES EM R$ SEM IMPOSTOS  "
   ELSE
   	titulo :="DEVOLUCOES DE VENDAS POR PRODUTOS - VALORES EM US$ SEM IMPOSTOS "
   ENDIF
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
	
	_fIMPRESST()       // IMPRESSAO
	
	_fIMPTOT()         // TOTALIZA	


	_NREL  := 5
	LIN := 66
   if mv_par04 <> "2"
		titulo :="RESUMO DE VENDAS DO PERIODO - VALORES EM R$ SEM IMPOSTOS  "
   else
   	titulo :="RESUMO DE VENDAS DO PERIODO - VALORES EM US$ SEM IMPOSTOS "
   endif
	titulo := titulo + "      "+dtoc(mv_par01) + "      "+dtoc(mv_par02)
	
	_fIMPRES()       // RESUMO


	dbCloseArea()			
	
RETURN .T.


STATIC FUNCTION _fIMPRESST()

	FOR X = 1 TO 13
		AC_TOV[X] := 0.00
		AC_TOC[X] := 0.00
		AC_TOT[X] := 0.00
	NEXT X

   dbselectarea("TRB")
   DBGOTOP()

	IF _NREL<>4
		_QPRO   := TRB->D2_COD
		_CODQ   := TRB->D2_COD
		_QCLI   := TRB->D2_CLIENTE
		_QCODQC := TRB->D2_CLIENTE
		_QRAZAO:= TRB->A1_NOME
		_dataver := SUBSTR(TRB->D2_EMISSAO,7,2)+"/"+SUBSTR(TRB->D2_EMISSAO,5,2)+"/"+SUBSTR(TRB->D2_EMISSAO,1,4)
		_DIA  := CTOD(_dataver)
	ELSE
		_QPRO   := TRB->D1_COD
		_CODQ   := TRB->D1_COD
		_QCLI   := TRB->D1_FORNECE
		_QCODQC := TRB->D1_FORNECE
		_QRAZAO:= TRB->A1_NOME
		_dataver := SUBSTR(TRB->D1_DTDIGIT,7,2)+"/"+SUBSTR(TRB->D1_DTDIGIT,5,2)+"/"+SUBSTR(TRB->D1_DTDIGIT,1,4)
		_DIA  := CTOD(_dataver)		
	ENDIF

   _QDESC:= TRB->B1_DESC
   _QRAZAO:= TRB->A1_NOME
	SetRegua(lastrec())
	PROCREGUA(7)
	do while !eof() 

		IF _NREL<>4
			_CODQ := TRB->D2_COD
			_QCLI := TRB->D2_CLIENTE
			INCPROC("CLIENTE : " + TRB->A1_COD + TRB->D2_COD + D2_EMISSAO)
			_MES  := SUBSTR(TRB->D2_EMISSAO,5,2)
		ELSE
			_CODQ := TRB->D1_COD
			_QCLI := TRB->D1_FORNECE
			INCPROC("CLIENTE : " + TRB->A1_COD + TRB->D1_COD + D1_DTDIGIT)
			_MES  := SUBSTR(TRB->D1_DTDIGIT,5,2)
		ENDIF

		IF _QCLI <> _QCODQC
			_fQCLIE()
		ENDIF
		
		IF _QPRO <> _CODQ
			_fQPROD()
		ENDIF

		// ACUMULA VALORES			
		IF MV_PAR04 <> "2"
			IF _NREL  == 1
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + TRB->VALLIQ
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + TRB->VALLIQ
				AC_VEN[VAL(_MES)] := AC_VEN[VAL(_MES)] + TRB->VALLIQ
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + TRB->VALLIQ
				AC_TOV[13] := AC_TOV[13] + TRB->VALLIQ
				AC_TOT[13] := AC_TOT[13] + TRB->VALLIQ
				AC_VEN[13] := AC_VEN[13] + TRB->VALLIQ
				AC_TOC[13] := AC_TOC[13] + TRB->VALLIQ			
			ELSEIF _NREL == 2
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + TRB->D2_CUSTO1
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + TRB->D2_CUSTO1
				AC_CUS[VAL(_MES)] := AC_CUS[VAL(_MES)] + TRB->D2_CUSTO1			
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + TRB->D2_CUSTO1				
				AC_TOV[13] := AC_TOV[13] + TRB->D2_CUSTO1
				AC_TOT[13] := AC_TOT[13] + TRB->D2_CUSTO1
				AC_CUS[13] := AC_CUS[13] + TRB->D2_CUSTO1
				AC_TOC[13] := AC_TOC[13] + TRB->D2_CUSTO1							
			ELSEIF _NREL == 3
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_IMP[VAL(_MES)] := AC_IMP[VAL(_MES)] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_TOV[13] := AC_TOV[13] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_TOT[13] := AC_TOT[13] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_IMP[13] := AC_IMP[13] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
				AC_TOC[13] := AC_TOC[13] + (TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)
			ELSEIF _NREL == 4
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + TRB->VALLIQ
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + TRB->VALLIQ
				AC_DEV[VAL(_MES)] := AC_DEV[VAL(_MES)] + TRB->VALLIQ
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + TRB->VALLIQ
				AC_TOV[13] := AC_TOV[13] + TRB->VALLIQ
				AC_TOT[13] := AC_TOT[13] + TRB->VALLIQ
				AC_DEV[13] := AC_DEV[13] + TRB->VALLIQ
				AC_TOC[13] := AC_TOC[13] + TRB->VALLIQ			
			ELSEIF _NREL == 6
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_MAR[VAL(_MES)] := AC_MAR[VAL(_MES)] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_TOV[13] := AC_TOV[13] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_TOT[13] := AC_TOT[13] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_TOC[13] := AC_TOC[13] + (TRB->VALLIQ - TRB->D2_CUSTO1)
				AC_MAR[13] := AC_MAR[13] + (TRB->VALLIQ - TRB->D2_CUSTO1)			
			ENDIF		
		ELSE
			_VALMOEDA := RecMoeda(_dia,"2")
			IF _NREL  == 1
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_VEN[VAL(_MES)] := AC_VEN[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_TOV[13] := AC_TOV[13] + (TRB->VALLIQ/_valmoeda)
				AC_TOT[13] := AC_TOT[13] + (TRB->VALLIQ/_valmoeda)
				AC_VEN[13] := AC_VEN[13] + (TRB->VALLIQ/_valmoeda)
				AC_TOC[13] := AC_TOC[13] + (TRB->VALLIQ/_valmoeda)		
			ELSEIF _NREL == 2
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + (TRB->D2_CUSTO1/_valmoeda)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + (TRB->D2_CUSTO1/_valmoeda)
				AC_CUS[VAL(_MES)] := AC_CUS[VAL(_MES)] + (TRB->D2_CUSTO1/_valmoeda)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + (TRB->D2_CUSTO1/_valmoeda)			
				AC_TOV[13] := AC_TOV[13] + (TRB->D2_CUSTO1/_valmoeda)
				AC_TOT[13] := AC_TOT[13] + (TRB->D2_CUSTO1/_valmoeda)
				AC_CUS[13] := AC_CUS[13] + (TRB->D2_CUSTO1/_valmoeda)
				AC_TOC[13] := AC_TOC[13] + (TRB->D2_CUSTO1/_valmoeda)			
			ELSEIF _NREL == 3
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_IMP[VAL(_MES)] := AC_IMP[VAL(_MES)] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)			
				AC_TOV[13] := AC_TOV[13] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_TOT[13] := AC_TOT[13] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_IMP[13] := AC_IMP[13] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)
				AC_TOC[13] := AC_TOC[13] + ((TRB->D2_VALICM + TRB->D2_VALIPI + TRB->PISCOF)/_valmoeda)	
			ELSEIF _NREL == 4
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_DEV[VAL(_MES)] := AC_DEV[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + (TRB->VALLIQ/_valmoeda)			
				AC_TOV[13] := AC_TOV[13] + (TRB->VALLIQ/_valmoeda)
				AC_TOT[13] := AC_TOT[13] + (TRB->VALLIQ/_valmoeda)
				AC_DEV[13] := AC_DEV[13] + (TRB->VALLIQ/_valmoeda)
				AC_TOC[13] := AC_TOC[13] + (TRB->VALLIQ/_valmoeda)
			ELSEIF _NREL == 6
				AC_TOV[VAL(_MES)] := AC_TOV[VAL(_MES)] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_TOT[VAL(_MES)] := AC_TOT[VAL(_MES)] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_TOC[VAL(_MES)] := AC_TOC[VAL(_MES)] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_MAR[VAL(_MES)] := AC_MAR[VAL(_MES)] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_TOV[13] := AC_TOV[13] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_TOT[13] := AC_TOT[13] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_TOC[13] := AC_TOC[13] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)
				AC_MAR[13] := AC_MAR[13] + ((TRB->VALLIQ - TRB->D2_CUSTO1)/_valmoeda)							
			ENDIF		
		ENDIF
		
		dbskip()
			
	enddo
	
RETURN


STATIC FUNCTION _fIMPTOT()

	// IMPRESSAO DE TOTAIS

   if mv_par03 <> 1

		_fQCLIE()

   endif


   if mv_par03 <> 1
      SomaLin()
      SomaLin()
		@ LIN,001 PSAY " TOTAL GERAL    ====>"
	  	@ LIN,039 PSAY AC_TOT[1]    PICTURE "@E 999999999.99"
	  	@ LIN,052 PSAY AC_TOT[2]    PICTURE "@E 999999999.99"
	  	@ LIN,065 PSAY AC_TOT[3]    PICTURE "@E 999999999.99"
	  	@ LIN,078 PSAY AC_TOT[4]    picture "@E 999999999.99"
	  	@ LIN,091 PSAY AC_TOT[5]    picture "@E 999999999.99"
	  	@ LIN,104 PSAY AC_TOT[6]    picture "@E 999999999.99"
	  	@ LIN,117 PSAY AC_TOT[7]    picture "@E 999999999.99"
	  	@ LIN,130 PSAY AC_TOT[8]    picture "@E 999999999.99"
		@ LIN,143 PSAY AC_TOT[9]    picture "@E 999999999.99"
		@ LIN,156 PSAY AC_TOT[10]   picture "@E 999999999.99"
	  	@ LIN,169 PSAY AC_TOT[11]   picture "@E 999999999.99"
		@ LIN,182 PSAY AC_TOT[12]   picture "@E 999999999.99"
		@ LIN,195 PSAY AC_TOT[13]   picture "@E 999,999,999.99"
	endif
	//ZERA SOMATORIA

	FOR X = 1 TO 13
		AC_TOV[X] := 0.00
		AC_TOC[X] := 0.00
		AC_TOT[X] := 0.00
	NEXT X

RETURN


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

cPerg := PADR(cPerg,10)
aRegs := {}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","De data de Emissao ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"02","Ate data de Emissao?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"03","Imprimir Sintetico ?","","","mv_ch3","N",01,0,1,"C","","mv_par03","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"04","1=Real / 2=Dolar   ?","","","mv_ch4","C",01,0,1,"G","","mv_par04","1"  ,"","","","","2"  ,"","","","","","","","","","","","","","","","","","","",   ""})


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

STATIC FUNCTION _fSELECTVEN()           // VENDAS / SERVICOS

	DbSelectArea("SD2")
	_xAliasSiga := "SD2"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQuery:=  " SELECT D2_CLIENTE,D2_LOJA,A1_COD,A1_NOME,D2_COD,B1_DESC,D2_DOC,D2_EMISSAO,D2_TES,D2_CF,D2_QUANT, "
	cQUERY:= cQUERY + " ((D2_TOTAL*.9535)-D2_VALICM) AS VALLIQ,D2_VALICM,D2_CUSTO1,D2_VALIPI,  "
	cQUERY:= cQUERY + " (D2_TOTAL*.0465) AS PISCOF "
	cQUERY:= cQUERY + " FROM  SD2BH0, SB1BH0, SA1BH0 "
	cQuery:=	cQUERY + " WHERE  D2_COD = B1_COD AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) AND "
	cQUERY:= cQUERY + " (D2_EMISSAO >= " +_DataDe+" AND D2_EMISSAO<= " + _DataAte + ")" 
	cQUERY:= cQUERY + " AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D')"
	cQUERY:= cQUERY + " AND (SD2BH0.D_E_L_E_T_<>'*' AND SB1BH0.D_E_L_E_T_<>'*' AND SA1BH0.D_E_L_E_T_<>'*') " 
	cQUERY:= cQUERY + " ORDER BY D2_CLIENTE + D2_LOJA + D2_COD + D2_EMISSAO"

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN


STATIC FUNCTION _fSELECTDEV()           // DEVOLUCAO DE VENDAS

	DbSelectArea("SD1")
	_xAliasSiga := "SD1"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQuery:=  " SELECT D1_FORNECE,D1_LOJA,A1_COD,A1_NOME,D1_COD,B1_DESC,D1_DOC,D1_DTDIGIT,D1_TES,D1_CF,D1_QUANT, "
	cQuery:= cQUERY + " ((D1_TOTAL*.9535)-D1_VALICM) AS VALLIQ,D1_VALICM,D1_CUSTO,D1_VALIPI,(D1_TOTAL*.0465) AS PISCOF "	
	cQUERY:= cQUERY + " FROM  SD1BH0, SB1BH0, SA1BH0 "
	cQuery:=	cQUERY + " WHERE  D1_COD = B1_COD AND (D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA) AND "
	cQuery:=	cQUERY + " (D1_DTDIGIT >= " +_DataDe+" AND D1_DTDIGIT<=" + _DataAte +") "
	cQUERY:= cQUERY + " AND D1_TES IN ('05E','06E','24E','31E')"
	cQUERY:= cQUERY + " AND (SD1BH0.D_E_L_E_T_<>'*' AND SB1BH0.D_E_L_E_T_<>'*' AND SA1BH0.D_E_L_E_T_<>'*')"
	cQUERY:= cQUERY + " ORDER BY D1_FORNECE + D1_LOJA + D1_COD + D1_DTDIGIT"
	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN


STATIC FUNCTION _fIMPRES()           // RESUMO

	SomaLin()
	SomaLin()

	@ LIN,001 PSAY " VENDAS NO PERIODO      ====>"
  	@ LIN,039 PSAY AC_VEN[1]    PICTURE "@E 999999999.99"
  	@ LIN,052 PSAY AC_VEN[2]    PICTURE "@E 999999999.99"
  	@ LIN,065 PSAY AC_VEN[3]    PICTURE "@E 999999999.99"
  	@ LIN,078 PSAY AC_VEN[4]    picture "@E 999999999.99"
  	@ LIN,091 PSAY AC_VEN[5]    picture "@E 999999999.99"
  	@ LIN,104 PSAY AC_VEN[6]    picture "@E 999999999.99"
  	@ LIN,117 PSAY AC_VEN[7]    picture "@E 999999999.99"
  	@ LIN,130 PSAY AC_VEN[8]    picture "@E 999999999.99"
	@ LIN,143 PSAY AC_VEN[9]    picture "@E 999999999.99"
	@ LIN,156 PSAY AC_VEN[10]   picture "@E 999999999.99"
  	@ LIN,169 PSAY AC_VEN[11]   picture "@E 999999999.99"
	@ LIN,182 PSAY AC_VEN[12]   picture "@E 999999999.99"
	@ LIN,195 PSAY AC_VEN[13]   picture "@E 999,999,999.99"  
	
	SomaLin()
	SomaLin()

	@ LIN,001 PSAY " CUSTOS NO PERIODO      ====>"
  	@ LIN,039 PSAY AC_CUS[1]    PICTURE "@E 999999999.99"
  	@ LIN,052 PSAY AC_CUS[2]    PICTURE "@E 999999999.99"
  	@ LIN,065 PSAY AC_CUS[3]    PICTURE "@E 999999999.99"
  	@ LIN,078 PSAY AC_CUS[4]    picture "@E 999999999.99"
  	@ LIN,091 PSAY AC_CUS[5]    picture "@E 999999999.99"
  	@ LIN,104 PSAY AC_CUS[6]    picture "@E 999999999.99"
  	@ LIN,117 PSAY AC_CUS[7]    picture "@E 999999999.99"
  	@ LIN,130 PSAY AC_CUS[8]    picture "@E 999999999.99"
	@ LIN,143 PSAY AC_CUS[9]    picture "@E 999999999.99"
	@ LIN,156 PSAY AC_CUS[10]   picture "@E 999999999.99"
  	@ LIN,169 PSAY AC_CUS[11]   picture "@E 999999999.99"
	@ LIN,182 PSAY AC_CUS[12]   picture "@E 999999999.99"
	@ LIN,195 PSAY AC_CUS[13]   picture "@E 999,999,999.99"  
	
	SomaLin()
	SomaLin()

	@ LIN,001 PSAY " MARGEM NO PERIODO      ====>"
  	@ LIN,039 PSAY AC_MAR[1]    PICTURE "@E 999999999.99"
  	@ LIN,052 PSAY AC_MAR[2]    PICTURE "@E 999999999.99"
  	@ LIN,065 PSAY AC_MAR[3]    PICTURE "@E 999999999.99"
  	@ LIN,078 PSAY AC_MAR[4]    picture "@E 999999999.99"
  	@ LIN,091 PSAY AC_MAR[5]    picture "@E 999999999.99"
  	@ LIN,104 PSAY AC_MAR[6]    picture "@E 999999999.99"
  	@ LIN,117 PSAY AC_MAR[7]    picture "@E 999999999.99"
  	@ LIN,130 PSAY AC_MAR[8]    picture "@E 999999999.99"
	@ LIN,143 PSAY AC_MAR[9]    picture "@E 999999999.99"
	@ LIN,156 PSAY AC_MAR[10]   picture "@E 999999999.99"
  	@ LIN,169 PSAY AC_MAR[11]   picture "@E 999999999.99"
	@ LIN,182 PSAY AC_MAR[12]   picture "@E 999999999.99"
	@ LIN,195 PSAY AC_MAR[13]   picture "@E 999,999,999.99"  
	
	SomaLin()
	SomaLin()


	@ LIN,001 PSAY " IMPOSTOS NO PERIODO    ====>"
  	@ LIN,039 PSAY AC_IMP[1]    PICTURE "@E 999999999.99"
  	@ LIN,052 PSAY AC_IMP[2]    PICTURE "@E 999999999.99"
  	@ LIN,065 PSAY AC_IMP[3]    PICTURE "@E 999999999.99"
  	@ LIN,078 PSAY AC_IMP[4]    picture "@E 999999999.99"
  	@ LIN,091 PSAY AC_IMP[5]    picture "@E 999999999.99"
  	@ LIN,104 PSAY AC_IMP[6]    picture "@E 999999999.99"
  	@ LIN,117 PSAY AC_IMP[7]    picture "@E 999999999.99"
  	@ LIN,130 PSAY AC_IMP[8]    picture "@E 999999999.99"
	@ LIN,143 PSAY AC_IMP[9]    picture "@E 999999999.99"
	@ LIN,156 PSAY AC_IMP[10]   picture "@E 999999999.99"
  	@ LIN,169 PSAY AC_IMP[11]   picture "@E 999999999.99"
	@ LIN,182 PSAY AC_IMP[12]   picture "@E 999999999.99"
	@ LIN,195 PSAY AC_IMP[13]   picture "@E 999,999,999.99"	
	
	SomaLin()
	SomaLin()

	@ LIN,001 PSAY " DEVOLUCOES NO PERIODO  ====>"
  	@ LIN,039 PSAY AC_DEV[1]    PICTURE "@E 999999999.99"
  	@ LIN,052 PSAY AC_DEV[2]    PICTURE "@E 999999999.99"
  	@ LIN,065 PSAY AC_DEV[3]    PICTURE "@E 999999999.99"
  	@ LIN,078 PSAY AC_DEV[4]    picture "@E 999999999.99"
  	@ LIN,091 PSAY AC_DEV[5]    picture "@E 999999999.99"
  	@ LIN,104 PSAY AC_DEV[6]    picture "@E 999999999.99"
  	@ LIN,117 PSAY AC_DEV[7]    picture "@E 999999999.99"
  	@ LIN,130 PSAY AC_DEV[8]    picture "@E 999999999.99"
	@ LIN,143 PSAY AC_DEV[9]    picture "@E 999999999.99"
	@ LIN,156 PSAY AC_DEV[10]   picture "@E 999999999.99"
  	@ LIN,169 PSAY AC_DEV[11]   picture "@E 999999999.99"
	@ LIN,182 PSAY AC_DEV[12]   picture "@E 999999999.99"
	@ LIN,195 PSAY AC_DEV[13]   picture "@E 999,999,999.99"	

		

RETURN



STATIC FUNCTION _fQPROD()

	   if mv_par03 <> 1
			SomaLin()
			@ LIN,001 PSAY SUBSTR(_QPRO,1,10) // PICTURE "@!"
      	@ LIN,012 PSAY SUBSTR(_QDESC,1,26) //  PICTURE "@!"
      	@ LIN,039 PSAY AC_TOV[1]    PICTURE "@E 999999999.99"
      	@ LIN,052 PSAY AC_TOV[2]    PICTURE "@E 999999999.99"
      	@ LIN,065 PSAY AC_TOV[3]    PICTURE "@E 999999999.99"
      	@ LIN,078 PSAY AC_TOV[4]    picture "@E 999999999.99"
      	@ LIN,091 PSAY AC_TOV[5]    picture "@E 999999999.99"
      	@ LIN,104 PSAY AC_TOV[6]    picture "@E 999999999.99"
      	@ LIN,117 PSAY AC_TOV[7]    picture "@E 999999999.99"
      	@ LIN,130 PSAY AC_TOV[8]    picture "@E 999999999.99"
	  		@ LIN,143 PSAY AC_TOV[9]    picture "@E 999999999.99"
	  		@ LIN,156 PSAY AC_TOV[10]   picture "@E 999999999.99"
      	@ LIN,169 PSAY AC_TOV[11]   picture "@E 999999999.99"
	  		@ LIN,182 PSAY AC_TOV[12]   picture "@E 999999999.99"
	  		@ LIN,195 PSAY AC_TOV[13]   picture "@E 999,999,999.99"
	   endif
		//ZERA SOMATORIA
		FOR X = 1 TO 13
			AC_TOV[X] := 0.00
		NEXT X
	

		IF _NREL<>4
			_QPRO := TRB->D2_COD
		ELSE
			_QPRO := TRB->D1_COD
		ENDIF
	   _QDESC:= TRB->B1_DESC
   			
RETURN


STATIC FUNCTION _fQCLIE()

	   if mv_par03 <> 1

			_fQPROD()

			SomaLin()
			SomaLin()
						
			@ LIN,001 PSAY "TOTAL DO CLIENTE:"  //// SUBSTR(_QCLI,1,10) // PICTURE "@!"
      	@ LIN,019 PSAY SUBSTR(_QRAZAO,1,19) //  PICTURE "@!"
      	@ LIN,039 PSAY AC_TOC[1]    PICTURE "@E 999999999.99"
      	@ LIN,052 PSAY AC_TOC[2]    PICTURE "@E 999999999.99"
      	@ LIN,065 PSAY AC_TOC[3]    PICTURE "@E 999999999.99"
      	@ LIN,078 PSAY AC_TOC[4]    picture "@E 999999999.99"   
      	@ LIN,091 PSAY AC_TOC[5]    picture "@E 999999999.99"
      	@ LIN,104 PSAY AC_TOC[6]    picture "@E 999999999.99"
      	@ LIN,117 PSAY AC_TOC[7]    picture "@E 999999999.99"
      	@ LIN,130 PSAY AC_TOC[8]    picture "@E 999999999.99"
	  		@ LIN,143 PSAY AC_TOC[9]    picture "@E 999999999.99"
	  		@ LIN,156 PSAY AC_TOC[10]   picture "@E 999999999.99"
      	@ LIN,169 PSAY AC_TOC[11]   picture "@E 999999999.99"
	  		@ LIN,182 PSAY AC_TOC[12]   picture "@E 999999999.99"
	  		@ LIN,195 PSAY AC_TOC[13]   picture "@E 999,999,999.99"
	  		
			SomaLin()
			SomaLin()	  		
	  		
	   endif
		//ZERA SOMATORIA
		FOR X = 1 TO 13
			AC_TOC[X] := 0.00
		NEXT X

		IF _NREL<>4
			_QCLI := TRB->D2_CLIENTE
			_QCODQC := TRB->D2_CLIENTE
		ELSE
			_QCLI := TRB->D1_FORNECE
			_QCODQC := TRB->D1_FORNECE
		ENDIF
	   _QRAZAO:= TRB->A1_NOME
   			
RETURN

