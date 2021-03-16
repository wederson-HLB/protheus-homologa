#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*
Funcao      : GSX1080
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
 User Function GSX1080()
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
Programa  |³GSX1080   | Autor | FRANCISCO F.S. NETO    | Data | 19.09.03
----------|-------------------------------------------------------------
Descri‡…o | Set Items Retail                                                
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS780SCM08_AAAAMMDD.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/


//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
// 
// record_created_by         		C     3    0  "780"  - Conteudo fixo
// multibrand_code         		C     3    0  "001"  - Conteudo fixo
// global_code				        	C    15    0  codigo do produto
// set_start_date	              	C     8    0  date de inicio de comercializacao (yyyymmdd) 
// set_end_date	              	C     8    0  date de final de comercializacao (yyyymmdd) 
// record_update	              	C     8    0  date de inicio de comercializacao (yyyymmdd) 
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
cPerg    :="GS1080    "

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

wdir := 'C:\GINGA\GS780scm08_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '.XML'

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

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML1080 - Set Items Retail "  
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

	DbSelectArea("SZ4")                  // PRODUTOS
	_xAliasSiga := "SZ4"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	///cQUERY := "SELECT Z4_GCODE AS CODIGO, Z4_ITDESC AS DESCRIC, Z4_ITLDATE AS DATASTART, Z4_ITDDATE AS DATAEND "
	cQUERY := "SELECT Z4_GCODE AS CODIGO, Z4_ITDESC AS DESCRIC, Z4_SSDATE AS DATASTART, Z4_SEDATE AS DATAEND "
	cQUERY := cQUERY + "FROM SZ4R70 "
	cQUERY := cQUERY + "WHERE Z4_MBCODE = '001' AND D_E_L_E_T_<>'*'  "      /////AND B1_TIPO IN('PA','PP')"   
	cQUERY := cQUERY + "ORDER BY Z4_GCODE "
	
	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
                                       
RETURN


STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO
   
	cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	
	cREGISTRO := "<data record_created_by =" + "'780" + "'>" + ceol  //// SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "'>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	

   dbselectarea("TRB")                      
   DBGOTOP()
   
	PROCREGUA(7)
	do while !eof() 

		INCPROC("PRODUTO:   " + TRB->CODIGO)

		cREGISTRO := ""           
   	cREGISTRO := SPACE(10) + " <record multibrand_code ='001' "    ///+ "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'" 
      cREGISTRO := cREGISTRO + " global_code='" + TRB->CODIGO + SPACE((15 - LEN(TRB->CODIGO))) + "' "
      cREGISTRO := cREGISTRO + " set_start_date='" + TRB->DATASTART + SPACE((8 - LEN(TRB->DATASTART))) + "' "
      cREGISTRO := cREGISTRO + " set_end_date='"  + TRB->DATAEND + SPACE((8 - LEN(TRB->DATAEND))) + "' "
      cREGISTRO := cREGISTRO + " sub_multibrand_code='001' "
      cREGISTRO := cREGISTRO + " sub_global_code='" + TRB->CODIGO + SPACE((15 - LEN(TRB->CODIGO))) + "' "
      cREGISTRO := cREGISTRO + " pieces_in_one_set='01' "
      cREGISTRO := cREGISTRO + " record_update='" + "20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2) + "' "     
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

