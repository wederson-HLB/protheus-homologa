//SCR06

#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF 

/*
Funcao      : GSX0060
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
 User Function GSX0060()
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
Programa  |³GSX0060   | Autor | FRANCISCO F.S. NETO    | Data | 16.09.03
----------|-------------------------------------------------------------
Descri‡…o |SALES CO PROJECTIONS                                             
----------|-------------------------------------------------------------
Uso       |Especifico para o Cliente SHISEIDO DO BRASIL
          |Geracao do texto: GS780SCR06_AAAAMMDD.XML 
          |onde: AAMMDD = DATA E S = SEQUENCIA DO DIA  
----------+-------------------------------------------------------------
/*/

//--------------------------------------------------------------
// LAYOUT DO ARQUIVO A SER GERADO
//--------------------------------------------------------------
// 
// multibrand_code         		C     3    0  "001"  - Conteudo fixo
// sales_company_code           	C     3    0  "780"  - Codigo Companhia de Vendas
// system_date		             	C     8    0  (yyyymmdd) data do sistema 
// projection_month	         	C     8    0  (yyyymmdd)/(yyyymm)datadoregistro
// global_code			       	C    15    0  codigo do produto
// currency			      	C     3    0  "999" codigo da moeda 
// receipts_quantity           		C     9    3  Projecao de compras no periodo (Quantidade)
// receipts_amount             		C    16    4  Projecao de compras no periodo (Valor)
// wholesale_quantity        		C     9    3  Projecao de vendas no periodo (quantidade)
// wholesale_amount          		C    16    4  Projecao de vendas no periodo (valor)
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
_MESES := "JANFEVMARABRMAIJUNJULAGOSETOUTNOVDEZ"
_NPER  := 0

_QPROD   :=  SPACE(20)
_QCPAG   :=  SPACE(20)
_QCLIE   :=  SPACE(20)
_QVEND   :=  SPACE(20)
_mesini  :=  space(2)
_mesfim  :=  space(2)
_anoini  :=  space(4)
_anofim  :=  space(4)
   
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
cPerg    :="GS0060    "

if !u_versm0("R7")    // VERIFICA EMPRESA
   return
endif

wdir := 'C:\GINGA\GS780scr06_' + "20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2) + '-1.XML'

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

	@ 0,0 TO 120,400 DIALOG oDlg2 TITLE  "  Geracao do texto GSXML0060 - Sales Projections "  
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
//If SubStr(mv_par01,1,4) <> SubStr(mv_par02,1,4)
//   MsgInfo("As datas devem estar dentro do mesmo ano !!","A t e n c a o ")
//   Return
//Endif
CLOSE(oDlg2)
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
	aAdd(aRegs,{cPerg,"01","Inicio da Projecao  (AAAAMM) : ","","","mv_ch1","C",06,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	aAdd(aRegs,{cPerg,"02","Termino da Projecao (AAAAMM) : ","","","mv_ch2","C",06,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
	
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

	DbSelectArea("SZ7")                  // PROJECAO DE VENDAS
	_xAliasSiga := "SZ7"	
	PROCREGUA(7)
	INCPROC("SELECIONANDO REGISTROS...." + STR(LASTREC()))
	DbSetOrder(1)
	DbGoTop()
	/// _DataDe := "'"+"20" + substr(dtoc(mv_par01),7,2) + substr(dtoc(mv_par01),4,2) + substr(dtoc(mv_par01),1,2)+"'"
	/// _DataAte:= "'"+"20" + substr(dtoc(mv_par02),7,2) + substr(dtoc(mv_par02),4,2) + substr(dtoc(mv_par02),1,2)+"'"

	_mesini := substr(mv_par01,5,2)
	_mesfim := substr(mv_par02,5,2)
	_anoini := substr(mv_par01,1,4)
	_anofim := substr(mv_par02,1,4)

	cQUERY := " SELECT Z7_CODE AS CODIGO,Z7_ANO,Z7_DESC, Z7_JANVAL AS VALMES01, Z7_FEVVAL AS VALMES02, Z7_MARVAL AS VALMES03, Z7_ABRVAL AS VALMES04, Z7_MAIVAL AS VALMES05, Z7_JUNVAL AS VALMES06, "
	cQUERY += " Z7_JULVAL AS VALMES07, Z7_AGOVAL AS VALMES08, Z7_SETVAL AS VALMES09, Z7_OUTVAL AS VALMES10, Z7_NOVVAL AS VALMES11, Z7_DEZVAL AS VALMES12, "
	cQUERY += " Z7_JANQTD AS QTDMES01, Z7_FEVQTD AS QTDMES02, Z7_MARQTD AS QTDMES03, Z7_ABRQTD AS QTDMES04, Z7_MAIQTD AS QTDMES05, Z7_JUNQTD AS QTDMES06, "
	cQUERY += " Z7_JULQTD AS QTDMES07, Z7_AGOQTD AS QTDMES08, Z7_SETQTD AS QTDMES09, Z7_OUTQTD AS QTDMES10, Z7_NOVQTD AS QTDMES11, Z7_DEZQTD AS QTDMES12, "
	cQUERY += " Z8_JAN AS CQTDMES01, Z8_FEV AS CQTDMES02, Z8_MAR AS CQTDMES03, Z8_ABR AS CQTDMES04, Z8_MAI AS CQTDMES05, Z8_JUN AS CQTDMES06, "
	cQUERY += " Z8_JUL AS CQTDMES07, Z8_AGO AS CQTDMES08, Z8_SET AS CQTDMES09, Z8_OUT AS CQTDMES10, Z8_NOV AS CQTDMES11, Z8_DEZ AS CQTDMES12 "			
	cQUERY += " FROM SZ7R70, SZ8R70 "
	cQUERY += " WHERE  SZ7R70.D_E_L_E_T_ <>'*' AND  Z7_CODE = Z8_CODE "   
	cQuery += " AND Z7_ANO BETWEEN '"+_anoini+"' AND '"+_anofim+"'"+Chr(10)
   cQuery += " AND Z8_ANO BETWEEN '"+_anoini+"' AND '"+_anofim+"'"+Chr(10)	
	cQUERY += " ORDER BY Z7_CODE,Z7_ANO "
//	cQuery	:=	ChangeQuery(cQuery) --- Comentado por Daniel Pontes
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
                                       
RETURN


STATIC FUNCTION _fGRVTXT()           // GRAVACAO DE TEXTO
   
	cREGISTRO := "<?xml version = '1.0'   encoding = 'utf-8' ?>" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""    	
	cREGISTRO := "<data sales_company_code =" + "'780' " + "system_date= " + "'20" + SUBSTR(DTOC(dDATABASE),7,2) + SUBSTR(DTOC(dDATABASE),4,2) + SUBSTR(DTOC(dDATABASE),1,2)+ "' >" + ceol
	FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
	cREGISTRO := ""  
   cRegistro :="<clear projection_month='200504' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
   cRegistro :=Space(10)+"<clear projection_month='200505' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegistro :=Space(10)+"<clear projection_month='200506' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegustro :=Space(10)+"<clear projection_month='200507' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegistro :=Space(10)+"<clear projection_month='200508' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegistro :=Space(10)+"<clear projection_month='200509' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegistro :=Space(10)+"<clear projection_month='200510' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))         
   cRegistro :=Space(10)+"<clear projection_month='200511' /> "+ ceol
   FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
   
   dbselectarea("TRB")                      
   DBGOTOP()
   
	PROCREGUA(RecCount())//7
	do while !eof() 
      
	   IncProc("PRODUTO: "+TRB->CODIGO+" Ano : "+TRB->Z7_ANO)

		If TRB->Z7_ANO+"01" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"01" <= _anoFim+_mesFim
			// mes janeiro
	   	cRegistro :=""
	   	cREGISTRO := SPACE(10) + " <record projection_month ='" +TRB->Z7_ANO + "01" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES01,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES01*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES01,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES01,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
		endif

		if TRB->Z7_ANO+"02" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"02" <= _anoFim+_mesFim
			// mes fevereiro
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='" + TRB->Z7_ANO + "02" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES02,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES02*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES02,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES02,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"03" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"03" <= _anoFim+_mesFim
			// mes marco
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='" +TRB->Z7_ANO+ "03" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES03,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES03*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES03,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES03,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"04" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"04" <= _anoFim+_mesFim
			// mes abril
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"04" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES04,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES04*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES04,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES04,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"05" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"05" <= _anoFim+_mesFim
			// mes maio
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"05" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES05,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES05*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES05,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES05,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"06" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"06" <= _anoFim+_mesFim
			// mes junho
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"06" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES06,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES06*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES06,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES06,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"07" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"07" <= _anoFim+_mesFim
			// mes julho
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"07" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES07,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES07*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES07,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES07,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"08" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"08" <= _anoFim+_mesFim
			// mes agosto
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"08" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES08,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES08*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES08,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES08,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"09" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"09" <= _anoFim+_mesFim
			// mes setembro
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"09" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES09,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES09*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES09,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES09,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"10" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"10" <= _anoFim+_mesFim
			// mes outubro
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"10" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES10,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES10*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES10,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES10,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"11" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"11" <= _anoFim+_mesFim
			// mes novembro
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"11" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES11,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES11*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES11,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES11,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
      endif
      
      if TRB->Z7_ANO+"12" >= _anoIni+_mesIni .and. TRB->Z7_ANO+"12" <= _anoFim+_mesFim
			// mes dezembro
			cREGISTRO := ""           
	   	cREGISTRO := SPACE(10) + " <record projection_month ='"+TRB->Z7_ANO+"12" + "' "   //// + substr(dtoc(mv_par02),1,2)+"' " 
	   	cREGISTRO := cREGISTRO + " multibrand_code='001' " 
	      cREGISTRO := cREGISTRO + " global_code='" + TRB->codigo + SPACE((15 - LEN(TRB->codigo))) + "' "
	      cREGISTRO := cREGISTRO + " currency='025' " + ">" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	        
	      cREGISTRO := space(20) + " <receipts quantity='" + STRZERO(TRB->CQTDMES12,9,3) + "' "         /// Compra
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO((TRB->CQTDMES12*21),16,4) + "'" + "/>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""	      	              
	      cREGISTRO := space(20) + " <wholesale quantity='" + STRZERO(TRB->QTDMES12,9,3) + "' "           /// Venda
	      cREGISTRO := cREGISTRO + " amount='" + STRZERO(TRB->VALMES12,16,4) + "'" + "/>" 
	      cREGISTRO := cREGISTRO + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
			cREGISTRO := SPACE(10) + " </record>" + ceol
			FWrite(nHdlChk,cREGISTRO,Len(cREGISTRO))
			cREGISTRO := ""
	  	endif
      
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

