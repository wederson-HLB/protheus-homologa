#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF  

/*
Funcao      : GSX0100
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
 User Function GSX0100()
*-----------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no CODIGO ³
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


/*/
----------+-------------------------------------------------------------
Programa  |³GSX0100   | Autor | FRANCISCO F.S. NETO    | Data | 19.08.03
----------|-------------------------------------------------------------
Descri‡…o |RETAIL SALES INFORMATION                                                
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS895SCR10_AAAAMMDD-S.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/


//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
//
// 
// multibrand_code       		C     3    0  "001"  - Conteudo fixo
// sales_company_code           C     3    0  "824"  - Conteudo fixo
// retailer_code                C    15    0  CODIGO do Produto 
// system_date                  C     8    0  Data do sistema
// business_record_date         C     8    0  Data de referencia
// global code                  C    15    0  ??? 
// currency                     C     3    0  "999"  - Fixo referente a Real
// sales_QUANTity               N     9    3  QUANTidade vendida
// monthly                      C     1    0  "1"    - Fixo
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

_MES := "  "

_TXPIS := GETMV("MV_TXPIS")
_TXCOFIN := GETMV("MV_TXCOFIN")
_TX := (100 - (_TXPIS + _TXCOFIN))/100

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
lMes := .F.
lDia := .F.

cPerg    :="GS0100    "

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
// mv_par02             // ate Data
// mv_par03             // (F)isica /(J)uridica / (T)udo
//--------------------------------------------------------------

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML0100 - Retail Sales "  
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

	if lDia = .F. .AND. lMes = .F.
		lDia := .T.
	elseif lDia = .T. .AND. lMes = .T.
		lMes := .F.
	endif
	if lDia = .T.
		wdir := 'C:\GINGA\GS780RTR10_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-0.XML'
	else
		wdir := 'C:\GINGA\GS780RTR10_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-1.XML'
	endif
	
	wdir :=alltrim(wdir)

	_CRETXT()           /// ABERTURA DE ARQUIVO TEXTO

	_fSELECTVEN()      // SELECT PARA VENDAS
	
	_fGRVTXT()         // GRAVACAO DE TEXTO


	if select("TRB")!=0
		TRB->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif
   if SELECT("TRF")!=0
		TRF->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif
   if SELECT("TRX")!=0
		TRX->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif

	FClose(nHdlChk)	 // FECHA ARQUIVO TEXTO
	
RETURN .T.


Static Function ValidPerg()
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs := {}
	
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","De data de Emissao ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
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

STATIC FUNCTION _fSELECTVEN()           // VENDAS

	if select("TRB")!=0
		TRB->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif
   if SELECT("TRF")!=0
		TRF->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif
   if SELECT("TRX")!=0
		TRX->(DBCLOSEAREA())      // FECHA ARQUIVO DE TRABALHO
   endif

	DbSelectArea("SD2")                  // VENDAS COM PIS/COFINS
	_xAliasSiga := "SD2"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT D2_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D2_QUANT) AS QUANT, SUM(((D2_TOTAL*" + str(_TX) + ")-D2_VALICM)) AS VALLIQ, D2_CLIENTE "
	cQUERY := cQUERY + "FROM SD2R70, SB1R70 "                                                   
	cQUERY := cQUERY + "WHERE D2_FILIAL ='"+xFilial("SD2")+"' AND D2_COD = B1_COD AND D2_TES IN ('56V','57D','69D','70D','73A','74A','92D','90A','91A') AND SD2R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D2_EMISSAO>=" + _DATADE + "AND D2_EMISSAO<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D2_CLIENTE, D2_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D2_CLIENTE "

	cQuery	:=	ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()

	_aCampos := {  {"CODIGO"  ,"C",15,0 } ,;
	               {"DESCRIC" ,"C",30,0 }  ,;
	               {"QUANT"  ,"N",12,2 } ,;
	               {"VALLIQ" ,"N",16,2 } ,;
	               {"D2_CLIENTE" ,"C",6,0 } }

	_cNome := CriaTrab(_aCampos,.t.)
	dbUseArea(.T.,, _cNome,"TRF",.F.,.F.)
	DbSelectArea("TRF")
	///Index on D2_CLIENTE + CODIGO + DESCRIC to &_cNome
	Index on D2_CLIENTE to &_cNome
	
	DbSelectArea("SD2")                /// VENDAS SEM PIS/COFINS
	_xAliasSiga := "SD2"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT DISTINCT D2_COD AS CODIGO, B1_DESCING AS DESCRIC, SUM(D2_QUANT) AS QUANT,  SUM((D2_TOTAL-D2_VALICM)) AS VALLIQ, D2_CLIENTE "
	cQUERY := cQUERY + "FROM SD2R70, SB1R70 "                                                     
	cQUERY := cQUERY + "WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND D2_COD = B1_COD AND D2_TES IN ('75A','87A','83A','79A','92A','93A','94A','95A') AND SD2R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + " AND B1_TIPO IN('ME','PP') AND (D2_EMISSAO>=" + _DATADE + "AND D2_EMISSAO<=" +_DATAATE + ")"
	cQUERY := cQUERY + "GROUP BY D2_CLIENTE, D2_COD,B1_DESCING " 
	cQUERY := cQUERY + "ORDER BY D2_CLIENTE "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRX',.F.,.T.)

	DBSELECTAREA("TRX")
	DBGOTOP()
   while !eof()
		dbselectarea("TRF")
		///dbseek(TRX->D2_CLIENTE + TRX->CODIGO + TRX->DESCRIC)
		dbseek(TRX->D2_CLIENTE)
		IF FOUND()
			reclock("TRF",.f.)
		   	TRF->QUANT := TRF->QUANT + TRX->QUANT
		   	TRF->VALLIQ := TRF->VALLIQ + TRX->VALLIQ	
		   msunlock()
		ELSE
			reclock("TRF",.t.)
				TRF->CODIGO := TRX->CODIGO
				//TRF->DESCRIC := TRX->DESCRIC
				TRF->QUANT := TRX->QUANT
				TRF->VALLIQ := TRX->VALLIQ
				TRF->D2_CLIENTE := TRX->D2_CLIENTE
			msunlock() 
		ENDIF
		dbselectarea("TRX")
		dbskip()   
   enddo

	DBSELECTAREA("TRB")
	DBGOTOP()
   while !eof()
		dbselectarea("TRF")
		///dbseek(TRB->D2_CLIENTE + TRB->CODIGO + TRB->DESCRIC)
		dbseek(TRB->D2_CLIENTE)
		IF FOUND()
			reclock("TRF",.f.)
		   	TRF->QUANT := TRF->QUANT + TRB->QUANT
		   	TRF->VALLIQ := TRF->VALLIQ + TRB->VALLIQ	
		   msunlock()
		ELSE
			reclock("TRF",.t.)
				TRF->CODIGO := TRB->CODIGO
				///TRF->DESCRIC := TRB->DESCRIC
				TRF->QUANT := TRB->QUANT
				TRF->VALLIQ := TRB->VALLIQ
				TRF->D2_CLIENTE := TRB->D2_CLIENTE
			msunlock() 
		ENDIF
		dbselectarea("TRB")
		dbskip()   
   enddo

RETURN

STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO

	IF lDia = .T. .AND. lMes = .F.       //// diario
		cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := "<data sales_company_code = '780' system_date=" + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
	   dbselectarea("TRF")                      /// VENDAS COM PIS/COFINS
	   DBGOTOP()
		PROCREGUA(7)
		do while !eof() 
			INCPROC("PRODUTO:   " + TRF->CODIGO)
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record business_record_date='" + "20" + SUBSTR(DTOC(MV_PAR02),7,2) + SUBSTR(DTOC(MV_PAR02),4,2) + SUBSTR(DTOC(MV_PAR02),1,2) + "' "
	      cREGISTRO := cREGISTRO + " retailer_code='ALL' "
	      cREGISTRO := cREGISTRO + " multibrand_code='001' "
	      cREGISTRO := cREGISTRO + " global_code='" + TRF->D2_CLIENTE + SPACE((15 - LEN(TRF->D2_CLIENTE))) + "' " 
	      cREGISTRO := cREGISTRO + " currency='025' "  + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	                    
	      cREGISTRO := space(20) + " <sales QUANTity='" + STRZERO(TRF->QUANT,9,3) + "' "
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQ,16,4) + "' /> "
			cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			TRF->(dbskip())
		enddo

		cREGISTRO := "</data>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    
		DBCLOSEAREA()
	ENDIF
	
	IF lDia = .F. .AND. lMes = .T.       //// mensal
		cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	
		cREGISTRO := "<data sales_company_code = '780' system_date=" + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))

		cREGISTRO := ""    	
		cREGISTRO := space(10) + "<monthly> " + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
		cREGISTRO := ""    	

	   dbselectarea("TRF")                      /// VENDAS COM PIS/COFINS                                
	   DBGOTOP()
		PROCREGUA(7)
		do while !eof() 
			INCPROC("PRODUTO:   " + TRF->CODIGO)
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(20) + " <record business_record_date='" + "20" + SUBSTR(DTOC(MV_PAR02),7,2) + SUBSTR(DTOC(MV_PAR02),4,2) + space(2) + "' "    /// + SUBSTR(DTOC(MV_PAR02),1,2) + "' "
//	      cREGISTRO := cREGISTRO + " retailer_code='" + TRF->D2_CLIENTE + SPACE((15 - LEN(TRB->D2_CLIENTE))) + "' " // Comentado por DP
	      cREGISTRO := cREGISTRO + " retailer_code='ALL' "
	      cREGISTRO := cREGISTRO + " multibrand_code='001' "
	      cREGISTRO := cREGISTRO + " global_code='" + TRF->D2_CLIENTE + SPACE((15 - LEN(TRB->D2_CLIENTE))) + "' " ///" global_code='" + TRB->CODIGO + SPACE((15 - LEN(TRB->CODIGO))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' "  + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	                    
	      cREGISTRO := space(30) + " <sales QUANTity='" + STRZERO(TRF->QUANT,9,3) + "' "
	      cREGISTRO := cREGISTRO + " amount='" + strzero(TRF->VALLIQ,16,4) + "' /> "
			cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(20) + " </record>" + ceol
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
		DBCLOSEAREA()
	ENDIF

RETURN



STATIC FUNCTION _CRETXT()
	cArqChk	:=	WDIR
	nHdlChk	:=	MsFCreate(cArqChk)
	If nHdlChk < 0
		Break
	EndIf
RETURN

