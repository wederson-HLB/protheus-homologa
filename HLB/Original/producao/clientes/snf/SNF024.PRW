#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF     

/*
Funcao      : SNF024
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Resumo de vendas por vendedor
Autor     	: 
Data     	: 
Obs         : 
TDN         :
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 17/07/2012
M�dulo      : Faturamento
Cliente     : SNF
*/ 

*----------------------*
 User Function SNF024()
*----------------------*


//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

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

If !(cEmpAnt $ "BH" )  
   MsgStop("Rotina especifica SNF","Aten��o") 
   Return .F.
EndIf



/*/
----------+-------------------------------------------------------------
Programa  |�SNF024    | Autor | FRANCISCO F.S. NETO    | Data | 13.08.03
----------|-------------------------------------------------------------
Descri��o |RESUMO DE VENDAS POR VENDEDOR / COND.PAGTO. / CLIENTE                   
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

if !u_versm0("BH")    // VERIFICA EMPRESA
   return
endif

titulo :="VENDAS DO PERIODO"

cDesc1 :="Vendas do Exercicio por Vendedor / Cond. Pagto / Cliente                "
cDesc2 :="                                                                        "
cDesc3 :="                                                                        "
aOrd   := {}
nCntImpr := 0
cRodaTxt := "REGISTRO(S)"
wcabec := .t.

//--------------------------------------------------------------
// Variaveis padrao de todos os relatorios
//--------------------------------------------------------------
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

aLinha   := {}
nomeprog :="SNF024"
nLastKey := 0
cPerg    :="SNF024    "
nPagina  := 1
nivel    := 1


//--------------------------------------------------------------
// Variaveis utilizadas para Impressao do Cabecalho e Rodape
//--------------------------------------------------------------
cString  :="SD2"
cabec1  := "     P R O D U T O                                 Nota                             Valor       Valor         Valor        Valor       Valor          Valor       "                                              
cabec2  := "  Codigo           Descricao                       Fiscal  Emissao      Qtde.       Bruto       I.C.M.S.      I.P.I.       Frete       Pis/Cofins     Liquido     "
*            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
*                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        
*             XXXXXXXXXXXXXXXX AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  XXXXXX  XX/XX/XX  XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX XXXXXXXXX.XX  XXX,XXX,XXX.XX


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

wnrel:="SNF024"   // nome default do relatorio em disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)


SetDefault(aReturn,cString)

RptStatus({|| SNF024BImp()},titulo)

Return


// Rotina para impressao
Static Function SNF024BImp()

titulo :="VENDAS NO PERIODO POR VENDEDOR / COND.PAGTO. / CLIENTE - VALORES EM R$ "

IF MV_PAR04 <> "2"
	IF MV_PAR03 <> 1
		titulo :="VENDAS NO PERIODO POR VENDEDOR / COND.PAGTO. / CLIENTE - VALORES EM R$ "
	ELSE
		titulo :="RESUMO DE VENDAS POR VENDEDOR / COND.PAGTO. / CLIENTE - VALORES EM R$ "
	ENDIF
ELSE
	IF MV_PAR03 <> 1
		titulo :="VENDAS NO PERIODO POR VENDEDOR / COND.PAGTO. / CLIENTE - VALORES EM US$ "
	ELSE
		titulo :="RESUMO DE VENDAS POR VENDEDOR / COND.PAGTO. / CLIENTE - VALORES EM US$  "
	ENDIF
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
	
	_IMPDETNF()       // IMPRESSAO
	
	_IMPTOGE()         // TOTALIZA 
	
	DBCLOSEAREA()
	
RETURN .T.

Static Function Somalin()
	lin := lin + 1
	if lin > 58 .and. wcabec
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
/// aAdd(aRegs,{cPerg,"05","1=Valor / 2=Qtde.  ?","","","mv_ch5","C",01,0,1,"G","","mv_par05","1"  ,"","","","","2"  ,"","","","","","","","","","","","","","","","","","","",   ""})

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

STATIC FUNCTION _fSELECTVEN()           // VENDAS

	DbSelectArea("SD2")
	_xAliasSiga := "SD2"	
	SetRegua(lastrec())
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"
	cQUERY:=  "SELECT F2_VEND1, A3_NOME, F2_COND, E4_CODIGO, E4_DESCRI, D2_CLIENTE, A1_NOME, D2_DOC, D2_EMISSAO, D2_COD, "
	cQUERY:= cQUERY + "B1_DESC, D2_TES, D2_CF, D2_TOTAL, D2_QUANT,D2_VALFRE,((D2_TOTAL*.9535)-D2_VALICM) AS VALLIQ "
	cQuery:= cQUERY + " ,D2_VALICM,D2_VALIPI,(D2_TOTAL*.0465) AS PISCOF "
	cQUERY:= cQUERY + " FROM SF2BH0, SD2BH0, SE4BH0, SA3BH0, SA1BH0, SB1BH0 "
	cQuery:=	cQUERY + " WHERE  (F2_DOC = D2_DOC AND F2_COND = E4_CODIGO AND F2_VEND1 = A3_COD AND D2_CLIENTE = A1_COD AND "
	cQuery:=	cQUERY + " D2_COD = B1_COD) AND (D2_EMISSAO >= " +_DataDe+" AND D2_EMISSAO<= " + _DataAte + ")"
	cQUERY:= cQUERY + " AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D') "
	cQUERY:= cQUERY + " AND (SD2BH0.D_E_L_E_T_<>'*' AND SF2BH0.D_E_L_E_T_<>'*' AND SA3BH0.D_E_L_E_T_<>'*') "
	cQuery:=	cQUERY + " ORDER BY F2_VEND1 + E4_CODIGO + D2_CLIENTE + D2_DOC + D2_COD"

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN

STATIC FUNCTION _IMPDETNF()

	FOR X = 1 TO 13
		AC_TOPR[X] := 0.00
		AC_TOCP[X] := 0.00
		AC_TOCL[X] := 0.00
		AC_TOVE[X] := 0.00
		AC_TOGE[X] := 0.00
	NEXT X

   dbselectarea("TRB")
   DBGOTOP()
   
   _QPROD   :=  TRB->D2_COD
   _QCPAG   :=  TRB->F2_COND
   _QCLIE   :=  TRB->D2_CLIENTE
   _QVEND   :=  TRB->F2_VEND1
   
   _QDESCPR  := TRB->B1_DESC
   _QDESCCP  := TRB->E4_DESCRI
   _QDESCLI  := TRB->A1_NOME
   _QDESCVE  := TRB->A3_NOME
   
	_dataver := SUBSTR(TRB->D2_EMISSAO,7,2)+"/"+SUBSTR(TRB->D2_EMISSAO,5,2)+"/"+SUBSTR(TRB->D2_EMISSAO,1,4)
	_DIA  := CTOD(_dataver)

	SetRegua(lastrec())
	PROCREGUA(7)
	do while !eof() 

		
		INCPROC("VENDEDOR:   " + TRB->F2_VEND1 + TRB->D2_EMISSAO)
		_dataver := SUBSTR(TRB->D2_EMISSAO,7,2)+"/"+SUBSTR(TRB->D2_EMISSAO,5,2)+"/"+SUBSTR(TRB->D2_EMISSAO,1,4)
		_DIA  := CTOD(_dataver)

		_MES := SUBSTR(TRB->D2_EMISSAO,5,2)

      IF TRB->F2_VEND1 <> _QVEND
      	_IMPTOVE()
      ENDIF
      
      IF TRB->F2_COND <> _QCPAG
      	_IMPTOCP()
      ENDIF

      IF TRB->D2_CLIENTE <> _QCLIE
      	_IMPTOCL()
      ENDIF
      
      IF TRB->D2_COD <> _QPROD
      	_IMPTOPR()
      ENDIF
		IF MV_PAR04 <>"2"   
		   IF MV_PAR03 <> 1
				SomaLin()
				@ LIN,001 PSAY TRB->D2_COD PICTURE "@!"
		      @ LIN,018 PSAY SUBSTR(TRB->B1_DESC,1,30) //  PICTURE "@!"
		      @ LIN,050 PSAY TRB->D2_DOC      PICTURE "999999"
		      @ LIN,058 PSAY _DIA             PICTURE "99/99/99"
		      @ LIN,068 PSAY TRB->D2_QUANT    PICTURE "@E 999999999.99"
		      @ LIN,081 PSAY TRB->D2_TOTAL    PICTURE "@E 999999999.99"
		      @ LIN,094 PSAY TRB->D2_VALICM   PICTURE "@E 999999999.99"
		      @ LIN,107 PSAY TRB->D2_VALIPI   PICTURE "@E 999999999.99"  
		      @ LIN,120 PSAY TRB->D2_VALFRE   Picture "@E 999999999.99"
		  		@ LIN,133 PSAY TRB->PISCOF      picture "@E 999999999.99"
		  		@ LIN,147 PSAY TRB->VALLIQ      picture "@E 999,999,999.99"
	  		ENDIF
	  		
	  		AC_TOPR[1] := AC_TOPR[1] + TRB->D2_QUANT
	  		AC_TOPR[2] := AC_TOPR[2] + TRB->D2_TOTAL
	  		AC_TOPR[3] := AC_TOPR[3] + TRB->D2_VALICM
	  		AC_TOPR[4] := AC_TOPR[4] + TRB->D2_VALIPI
	  		AC_TOPR[5] := AC_TOPR[5] + TRB->D2_VALFRE
	  		AC_TOPR[6] := AC_TOPR[6] + TRB->PISCOF
	  		AC_TOPR[7] := AC_TOPR[7] + TRB->VALLIQ  		  		  		  		    		
      ELSE
			_VALMOEDA := RecMoeda(_dia,"2")
		   IF MV_PAR03 <> 1
				SomaLin()
				@ LIN,001 PSAY TRB->D2_COD PICTURE "@!"
		      @ LIN,018 PSAY SUBSTR(TRB->B1_DESC,1,30) //  PICTURE "@!"
		      @ LIN,050 PSAY TRB->D2_DOC      PICTURE "999999"
		      @ LIN,058 PSAY _DIA             PICTURE "99/99/99"
		      @ LIN,068 PSAY TRB->D2_QUANT    PICTURE "@E 999999999.99"
		      @ LIN,081 PSAY (TRB->D2_TOTAL/_VALMOEDA)    PICTURE "@E 999999999.99"
		      @ LIN,094 PSAY (TRB->D2_VALICM/_VALMOEDA)   PICTURE "@E 999999999.99"
		      @ LIN,107 PSAY (TRB->D2_VALIPI/_VALMOEDA)   PICTURE "@E 999999999.99"  
		      @ LIN,120 PSAY (TRB->D2_VALFRE/_VALMOEDA)   Picture "@E 999999999.99"
		  		@ LIN,133 PSAY (TRB->PISCOF/_VALMOEDA)      picture "@E 999999999.99"
		  		@ LIN,147 PSAY (TRB->VALLIQ/_VALMOEDA)      picture "@E 999,999,999.99"
	  		ENDIF
	  		
	  		AC_TOPR[1] := AC_TOPR[1] + TRB->D2_QUANT
	  		AC_TOPR[2] := AC_TOPR[2] + (TRB->D2_TOTAL/_VALMOEDA)
	  		AC_TOPR[3] := AC_TOPR[3] + (TRB->D2_VALICM/_VALMOEDA)
	  		AC_TOPR[4] := AC_TOPR[4] + (TRB->D2_VALIPI/_VALMOEDA)
	  		AC_TOPR[5] := AC_TOPR[5] + (TRB->D2_VALFRE/_VALMOEDA)
	  		AC_TOPR[6] := AC_TOPR[6] + (TRB->PISCOF/_VALMOEDA)
	  		AC_TOPR[7] := AC_TOPR[7] + (TRB->VALLIQ/_VALMOEDA)  		  		  		  		    		
      
      ENDIF
      
		dbskip()
			
	enddo
	
	// dbCloseArea()			
	
RETURN



STATIC FUNCTION _IMPTOPR()
		   
	   IF MV_PAR03 <> 1
			SomaLin()
			@ LIN,001 PSAY "         PRODUTO ==> "
	      @ LIN,026 PSAY SUBSTR(_QDESCPR,1,30) //  PICTURE "@!"
	      @ LIN,068 PSAY AC_TOPR[1]   PICTURE "@E 999999999.99"
	      @ LIN,081 PSAY AC_TOPR[2]   PICTURE "@E 999999999.99"
	      @ LIN,094 PSAY AC_TOPR[3]   PICTURE "@E 999999999.99"
	      @ LIN,107 PSAY AC_TOPR[4]   PICTURE "@E 999999999.99"  
	      @ LIN,120 PSAY AC_TOPR[5]   Picture "@E 999999999.99"
	  		@ LIN,133 PSAY AC_TOPR[6]   picture "@E 999999999.99"
	  		@ LIN,147 PSAY AC_TOPR[7]   picture "@E 999,999,999.99"
  		ENDIF
  		
  		AC_TOCL[1] := AC_TOCL[1] + AC_TOPR[1]
  		AC_TOCL[2] := AC_TOCL[2] + AC_TOPR[2]
  		AC_TOCL[3] := AC_TOCL[3] + AC_TOPR[3]
  		AC_TOCL[4] := AC_TOCL[4] + AC_TOPR[4]
  		AC_TOCL[5] := AC_TOCL[5] + AC_TOPR[5]
  		AC_TOCL[6] := AC_TOCL[6] + AC_TOPR[6]
  		AC_TOCL[7] := AC_TOCL[7] + AC_TOPR[7]
  		
  		FOR X = 1 TO 7
  			AC_TOPR[X] := 0.00
  		NEXT X

	   _QPROD   :=  TRB->D2_COD
	   _QDESCPR  := TRB->B1_DESC
	 
RETURN


STATIC FUNCTION _IMPTOCP()   

		_IMPTOCL()
		
		SomaLin()   
	
		@ LIN,001 PSAY "      C.PAGTO.  ===> "
      @ LIN,026 PSAY SUBSTR(_QDESCCP,1,30) //  PICTURE "@!"
      @ LIN,068 PSAY AC_TOCP[1]   PICTURE "@E 999999999.99"
      @ LIN,081 PSAY AC_TOCP[2]   PICTURE "@E 999999999.99"
      @ LIN,094 PSAY AC_TOCP[3]   PICTURE "@E 999999999.99"
      @ LIN,107 PSAY AC_TOCP[4]   PICTURE "@E 999999999.99"  
      @ LIN,120 PSAY AC_TOCP[5]   Picture "@E 999999999.99"
  		@ LIN,133 PSAY AC_TOCP[6]   picture "@E 999999999.99"
  		@ LIN,147 PSAY AC_TOCP[7]   picture "@E 999,999,999.99"
  		
  		AC_TOVE[1] := AC_TOVE[1] + AC_TOCP[1]
  		AC_TOVE[2] := AC_TOVE[2] + AC_TOCP[2]
  		AC_TOVE[3] := AC_TOVE[3] + AC_TOCP[3]
  		AC_TOVE[4] := AC_TOVE[4] + AC_TOCP[4]
  		AC_TOVE[5] := AC_TOVE[5] + AC_TOCP[5]
  		AC_TOVE[6] := AC_TOVE[6] + AC_TOCP[6]
  		AC_TOVE[7] := AC_TOVE[7] + AC_TOCP[7]
  		
  		FOR X = 1 TO 7
  			AC_TOCP[X] := 0.00
  		NEXT X

	   _QCPAG   :=  TRB->F2_COND
	   _QDESCCP  := TRB->E4_DESCRI

RETURN

STATIC FUNCTION _IMPTOCL   
      
		_IMPTOPR()
		
	   IF MV_PAR03 <> 1
			SomaLin()
			@ LIN,001 PSAY "      CLIENTE  ====> "
	      @ LIN,026 PSAY SUBSTR(_QDESCLI,1,30) //  PICTURE "@!"
	      @ LIN,068 PSAY AC_TOCL[1]   PICTURE "@E 999999999.99"
	      @ LIN,081 PSAY AC_TOCL[2]   PICTURE "@E 999999999.99"
	      @ LIN,094 PSAY AC_TOCL[3]   PICTURE "@E 999999999.99"
	      @ LIN,107 PSAY AC_TOCL[4]   PICTURE "@E 999999999.99"  
	      @ LIN,120 PSAY AC_TOCL[5]   Picture "@E 999999999.99"
	  		@ LIN,133 PSAY AC_TOCL[6]   picture "@E 999999999.99"
	  		@ LIN,147 PSAY AC_TOCL[7]   picture "@E 999,999,999.99"
      ENDIF
      
  		AC_TOCP[1] := AC_TOCP[1] + AC_TOCL[1]
  		AC_TOCP[2] := AC_TOCP[2] + AC_TOCL[2]
  		AC_TOCP[3] := AC_TOCP[3] + AC_TOCL[3]
  		AC_TOCP[4] := AC_TOCP[4] + AC_TOCL[4]
  		AC_TOCP[5] := AC_TOCP[5] + AC_TOCL[5]
  		AC_TOCP[6] := AC_TOCP[6] + AC_TOCL[6]
  		AC_TOCP[7] := AC_TOCP[7] + AC_TOCL[7]                           
  		
  		FOR X = 1 TO 7
  			AC_TOCL[X] := 0.00
  		NEXT X                                                                      
	   _QCLIE   :=  TRB->D2_CLIENTE
	   _QDESCLI  := TRB->A1_NOME
	
RETURN

STATIC FUNCTION _IMPTOVE()   
      
		_IMPTOCP()

		SomaLin()   
	
		@ LIN,001 PSAY "TOTAL VENDEDOR  ===> "
      @ LIN,026 PSAY SUBSTR(_QDESCVE,1,30) //  PICTURE "@!"
      @ LIN,068 PSAY AC_TOVE[1]   PICTURE "@E 999999999.99"
      @ LIN,081 PSAY AC_TOVE[2]   PICTURE "@E 999999999.99"
      @ LIN,094 PSAY AC_TOVE[3]   PICTURE "@E 999999999.99"
      @ LIN,107 PSAY AC_TOVE[4]   PICTURE "@E 999999999.99"  
      @ LIN,120 PSAY AC_TOVE[5]   Picture "@E 999999999.99"
  		@ LIN,133 PSAY AC_TOVE[6]   picture "@E 999999999.99"
  		@ LIN,147 PSAY AC_TOVE[7]   picture "@E 999,999,999.99"
  		
  		AC_TOGE[1] := AC_TOGE[1] + AC_TOVE[1]
  		AC_TOGE[2] := AC_TOGE[2] + AC_TOVE[2]
  		AC_TOGE[3] := AC_TOGE[3] + AC_TOVE[3]
  		AC_TOGE[4] := AC_TOGE[4] + AC_TOVE[4]
  		AC_TOGE[5] := AC_TOGE[5] + AC_TOVE[5]
  		AC_TOGE[6] := AC_TOGE[6] + AC_TOVE[6]
  		AC_TOGE[7] := AC_TOGE[7] + AC_TOVE[7]                           
  		
  		FOR X = 1 TO 7
  			AC_TOVE[X] := 0.00
  		NEXT X
	   _QVEND   :=  TRB->F2_VEND1
	   _QDESCVE  := TRB->A3_NOME
	   LIN := 60
	   SOMALIN()
RETURN

STATIC FUNCTION _IMPTOGE()   
      
		_IMPTOVE()
		
		SomaLin()   
	
		@ LIN,001 PSAY "TOTAL GERAL   =====> "
      @ LIN,026 PSAY SUBSTR(TRB->B1_DESC,1,30) //  PICTURE "@!"
      @ LIN,068 PSAY AC_TOGE[1]   PICTURE "@E 999999999.99"
      @ LIN,081 PSAY AC_TOGE[2]   PICTURE "@E 999999999.99"
      @ LIN,094 PSAY AC_TOGE[3]   PICTURE "@E 999999999.99"
      @ LIN,107 PSAY AC_TOGE[4]   PICTURE "@E 999999999.99"  
      @ LIN,120 PSAY AC_TOGE[5]   Picture "@E 999999999.99"
  		@ LIN,133 PSAY AC_TOGE[6]   picture "@E 999999999.99"
  		@ LIN,147 PSAY AC_TOGE[7]   picture "@E 999,999,999.99"
  		
  		FOR X = 1 TO 7
  			AC_TOGE[X] := 0.00
  		NEXT X

RETURN






