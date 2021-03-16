#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF 

/*
Funcao      : GSX1010
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
 User Function GSX1010()
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


/*/
----------+-------------------------------------------------------------
Programa  |³GSX1010   | Autor | FRANCISCO F.S. NETO    | Data | 25.08.03
----------|-------------------------------------------------------------
Descri‡…o |GLOBAL MASTER                                                 
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS12DCM01_AAAAMMDD.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/


//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
//
// 
// multibrand_code         		C     3    0  "001"  - Conteudo fixo    // Z4_MBCODE
// global_code                  	C    15    0  Codigo do Produto         // Z4_GCODE
// item_description             	C    35    0  Descricao do Produto      // Z4_ITDESC
// line_group                  	C     4    0  Grupo do Produto          // Z4_LGROUP
// color_item_grouping         	C     3    0  color item group          // Z4_CIGROUP
// beauty_method_a              	C     1    0  method a                  // Z4_BMETA
// beauty_method_b              	C     2    0  method b                  // Z4_BMRTB
// item_type	               	C     1    0  Tipo do Produto           // Z4_ITTYPE
// harmonized_code              	C     20   0  CLASSIFICACAO FISCAL      // Z4_HCODE
// item_launch_date             	D     8    0  DDMMAA                    // Z4_ITLDATE
// item_discontinue_date        	D     8    0  DDMMAA                    // Z4_ITDDATE
// record_update              	D     8    0  DDMMAA                    // Z4_RECUPDT
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
cPerg    :="GS1010    "

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

wdir := 'C:\GINGA\GS780SCM01_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '.XML'

wdir :=alltrim(wdir)

_CRETXT()           /// ABERTURA DE ARQUIVO TEXTO


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

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML1010 - Global Master "  
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

	_fSELECTPRO()      // SELECT PARA VENDAS
	
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

STATIC FUNCTION _fSELECTPRO()           // Produtos

	DbSelectArea("SZ4")                  
	_xAliasSiga := "SZ4"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	_DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	cQUERY := "SELECT  Z4_GCODE AS CODIGO, SUBSTRING(Z4_ITDESC,1,35) AS DESCRIC, Z4_LGROUP AS GRUPO, Z4_ITTYPE AS TIPO, Z4_HCODE AS POSIPI,  "
	cQUERY := cQUERY + " Z4_MBCODE AS MBRAND, Z4_CIGROUP AS COLOR, Z4_BMETA AS BEAUTYA, Z4_BMETB AS BEAUTYB,  "
	cQUERY := cQUERY + " Z4_ITLDATE AS LAUNCH, Z4_ITDDATE AS DISCONT, Z4_RECUPDT AS _UPDATE, Z4_SSDATE AS SSDATE, Z4_SEDATE AS SEDATE  "
	cQUERY := cQUERY + "FROM SZ4R70 "
	cQUERY := cQUERY + "WHERE  Z4_MBCODE = '001' AND SZ4R70.D_E_L_E_T_<>'*' "   
	cQUERY := cQUERY + "ORDER BY Z4_MBCODE + Z4_GCODE "

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
	
RETURN

STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO
   
	cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	
	cREGISTRO := "<data record_created_by = " + "'780'" + ">" + ceol     //// "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "'>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	

   dbselectarea("TRB")                      
   DBGOTOP()
   
	PROCREGUA(7)
	do while !eof() 

		INCPROC("PRODUTO:   " + TRB->CODIGO)

		cREGISTRO := ""
		cREGISTRO := SPACE(10) + "<record " + ceol
		FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))

		cREGISTRO := ""           
      
   	cREGISTRO := SPACE(20) + " multibrand_code='001' "
      cREGISTRO := cREGISTRO + " global_code='" + SUBSTR(TRB->CODIGO,1,15) + SPACE((15 - LEN(TRB->CODIGO))) + "' "  //// + SPACE((15 - LEN(TRB->CODIGO))) + "'"
      cREGISTRO := cREGISTRO + " item_description='" + SUBSTR(TRB->DESCRIC,1,35) + SPACE((35 - LEN(TRB->DESCRIC))) + "' "
      cREGISTRO := cREGISTRO + " line_group='" + SUBSTR(TRB->GRUPO,1,4) + SPACE((4 - LEN(TRB->GRUPO))) + "' "
      cREGISTRO := cREGISTRO + " color_item_grouping='" + SUBSTR(TRB->COLOR,1,3) + SPACE((3 - LEN(TRB->COLOR))) +  "' "
      cREGISTRO := cREGISTRO + " beauty_method_a='" + SUBSTR(TRB->BEAUTYA,1,1) + SPACE((1 - LEN(TRB->BEAUTYA))) +  "' "
      cREGISTRO := cREGISTRO + " beauty_method_b='" + SUBSTR(TRB->BEAUTYB,1,2) + SPACE((2 - LEN(TRB->BEAUTYB))) +  "' "
      cREGISTRO := cREGISTRO + " item_type='" + SUBSTR(TRB->TIPO,1,1) + SPACE((1 - LEN(TRB->TIPO))) + "' "  
      cREGISTRO := cREGISTRO + " harmonized_code='" + SUBSTR(TRB->POSIPI,1,20) + SPACE((20 - LEN(TRB->POSIPI))) + "' "
      cREGISTRO := cREGISTRO + " item_launch_date='" + SUBSTR(TRB->LAUNCH,1,8) + SPACE((8 - LEN(TRB->LAUNCH))) + "' "
      cREGISTRO := cREGISTRO + " item_discontinue_date='" + SUBSTR(TRB->DISCONT,1,8) + SPACE((8 - LEN(TRB->DISCONT))) + "' "
      cREGISTRO := cREGISTRO + " record_update='" + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)  + "' "
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

