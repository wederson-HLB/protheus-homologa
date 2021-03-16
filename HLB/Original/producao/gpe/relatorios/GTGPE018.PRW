#include "PROTHEUS.CH"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 04/01/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelatÛrio de Provis„o FÈrias em Excel                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Clientes HLB BRASIL                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE018()   

Private cPerg     := "GTGPE018  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotalE := 0
private cTotalS := 0
private cNe := 0

//private MV_PAR03 := 1

private	mesano :=  ""
private mesanoa := ""

private ACATU := {0,0,0,0,0,0,0,0,0}
private ACANT := {0,0,0,0,0,0,0,0,0}
private ACMES := {0,0,0,0,0,0,0,0,0}

	private cNOMECOM := space(40)
	private cCGC     := space(20)
	private cCNPJ    := space(20)

	cNOMECOM := SM0->M0_NOMECOM
	cCGC     := SM0->M0_CGC
	cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
	private cCodigo  := SM0->M0_CODIGO

CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("Gera RelatÛrio de Provisıes? ") == "S"
		Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
	Else
		Return
	EndIf
Else
	Return
EndIf

RETURN



STATIC FUNCTION geracom()
	
	Local cQuery := ' '
	Local lLoop  := .T.
	Local cOrdm  := "01"
	Local nArq   := Nil
	Local cPath  := AllTrim(GetTempPath())
	Local nCont  := 01
	Local cHtml  := ' '
	Local nRegua := 0
	Local nContArq := 0
	Local X := 0
	cTotalE := 0
	cTotalS := 0

	FOR X = 1 TO 9
		ACATU[X] := 0
	NEXT X

	FOR X = 1 TO 9
		ACATU[X] := 0
	NEXT X

	FOR X = 1 TO 9
		ACATU[X] := 0
	NEXT X	
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE018FER"+cOrdm+".xls")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	IF MV_PAR05 == 2
		GERARES()  // DECIMO TERCEIRO
		RETURN
	ENDIF


	cText  := "RelatÛrio de Provis„o de FÈrias - De: " + STRZERO(VAL(MV_PAR02),2)+"/"+STRZERO(VAL(MV_PAR01),4)
	
	mesano := STRZERO(VAL(MV_PAR01),4)+STRZERO(VAL(MV_PAR02),2)  

	IF VAL(MV_PAR02) = 1
		mesanoA := STRZERO((VAL(MV_PAR01)-1),4)+'12'
	ELSE
		mesanoA := STRZERO(VAL(MV_PAR01),4)+STRZERO((VAL(MV_PAR02)-1),2)	
	ENDIF

	cQuery := CRLF +" SELECT "
	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" NOME,FILIAL,CCUSTO,MATRICULA,TIPO,SALARIO,ADMISSA,"
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" FILIAL,CCUSTO,MATRICULA,TIPO,NOME,SALARIO,ADMISSA,"
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" FILIAL,CCUSTO,TIPO,"	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" FILIAL,TIPO,"	
	ENDIF
	cQuery += CRLF +" SUM(PROFER) AS PROFER,SUM(ADICPROFER) AS ADICPROFER,SUM(HUMTERCOPROFER) AS HUMTERCOPROFER, "
	cQuery += CRLF +" SUM(PROFER)+SUM(ADICPROFER)+SUM(HUMTERCOPROFER) AS TOTPROFER, "
	cQuery += CRLF +" SUM(INSSPROFER) AS INSSPROFER,SUM(FGTSPROFER) AS FGTSPROFER, "
	cQuery += CRLF +" SUM(INSSPROFER)+SUM(FGTSPROFER) AS TOTENC, "
	cQuery += CRLF +" SUM(PROFER)+SUM(ADICPROFER)+SUM(HUMTERCOPROFER)+SUM(INSSPROFER)+SUM(FGTSPROFER) AS TOTGER,SUM(BXPROFER) AS BXPROFER "

	cQuery += CRLF +" FROM ( "
	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'ATUAL' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0130') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0254') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0255') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS HUMTERCOPROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0131') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0132') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPROFER, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0233','0234','0235','0239','0240','0241','0258','0259','0260','0261','0262','0263','0264','0265','0266') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPROFER  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" UNION "

	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'ANTERIOR' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0130') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0254') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0255') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS HUMTERCOPROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0131') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0132') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPROFER, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0233','0234','0235','0239','0240','0241','0258','0259','0260','0261','0262','0263','0264','0265','0266') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPROFER  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" UNION "

	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'NO MES' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0130')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0130')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0254')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0254')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0255')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0255')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "	
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS HUMTERCOPROFER, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0131')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0131')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPROFER, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0132')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0132')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPROFER, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0233','0234','0235','0239','0240','0241','0258','0259','0260','0261','0262','0263','0264','0265','0266')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0233','0234','0235','0239','0240','0241','0258','0259','0260','0261','0262','0263','0264','0265','0266')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPROFER  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  IN('"+mesanoa+"','"+mesano+"') "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" ) "

	cQuery += CRLF +" AS AGRUPADO "

	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" GROUP BY NOME,FILIAL,CCUSTO,MATRICULA,TIPO,SALARIO,ADMISSA "
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" GROUP BY FILIAL,CCUSTO,MATRICULA,TIPO,NOME,SALARIO,ADMISSA "
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" GROUP BY FILIAL,CCUSTO,TIPO "	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" GROUP BY FILIAL,TIPO "	
	ENDIF

/*         
	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" ORDER BY NOME,FILIAL,CCUSTO,MATRICULA,TIPO "
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" ORDER BY FILIAL,CCUSTO,MATRICULA,TIPO,NOME "
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" ORDER BY FILIAL,CCUSTO,TIPO "	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" ORDER BY FILIAL,TIPO "	
	ENDIF
*/

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE018FER"+cOrdm+".xls"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCab(cText,'M S: ', MV_PAR02,' / ANO:  ', MV_PAR01, '') // cabeÁalho do relatorio "CIMCORP"
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTit(aStruFim)  //CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotalE := 0
	cTotalS := 0
	
	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMADO DE TABELA - LINHA BRANCA E LINHA AZUL.
		nCont ++
		IF nCont%2 == 0
			cBgColor := "#FFFFFF"
		ELSE
			cBgColor := "#CAE4FF"
		ENDIF
		
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
	
		IF MV_PAR06 == 1 .and. MV_PAR07 == 1
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // NOME
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // MATRICULA									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // TIPO									
			cValor := &("ENF->"+aStruFim[6][1])
			cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // salario 
	        cData :=&("ENF->"+aStruFim[7][1])
			cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// DATA admissao
			cNe := 7
		ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // MATRICULA									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // TIPO									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // NOME
			cValor := &("ENF->"+aStruFim[6][1])
			cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // salario 
	        cData :=&("ENF->"+aStruFim[7][1])
			cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// DATA admissao
			cNe := 7			
		ELSEIF MV_PAR06 == 2
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // TIPO									
			cNe := 3
		ELSEIF MV_PAR06 == 3
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // TIPO									
			cNe := 2
		ENDIF
        
		IF ALLTRIM(&("ENF->TIPO")) = "ATUAL"		
			FOR X = 1 TO 9
				ACATU[X] := ACATU[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X
		ELSEIF ALLTRIM(&("ENF->TIPO")) == "ANTERIOR" 
			FOR X = 1 TO 9
				ACANT[X] := ACANT[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X		
		ELSEIF ALLTRIM(&("ENF->TIPO")) = "NO MES"
			FOR X = 1 TO 9
				ACMES[X] := ACMES[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X
		ENDIF

		cValor := &("ENF->"+aStruFim[1+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // PROV.FERIAS 
		cValor := &("ENF->"+aStruFim[2+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // ADIC. PROV.FERIAS 	
		cValor := &("ENF->"+aStruFim[3+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // 1/3 PROV.FERIAS
		cValor := &("ENF->"+aStruFim[4+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL PROV.FERIAS
		cValor := &("ENF->"+aStruFim[5+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // INSS PROV.FERIAS
		cValor := &("ENF->"+aStruFim[6+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // FGTS PROV.FERIAS
		cValor := &("ENF->"+aStruFim[7+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOT. ENC. PROV.FERIAS
		cValor := &("ENF->"+aStruFim[8+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL GERAL PROV.FERIAS
		cValor := &("ENF->"+aStruFim[9+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL BAIXAS PROV.FER.NO MES

	  	nContArq++  
	
		cHtml += CRLF+' </tr> ' 
		
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF
		
		ENF->(DBSKIP())  
	END 
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlRodap()   // chama o rodapÅEdo relatorio
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	//Fecha Arquivo
	fClose(nArq)
	
	
	If ApOleClient("MsExcel")
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else
		ShellExecute("open",cArq,"","",1)
	EndIf
	
RETURN

//=========================================+
//FUNCAO PARA GERAR CABE«ALHO DO HTML      +
//=========================================+
STATIC FUNCTION HtmlCab()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELAT”RIO DE PROVIS√O F…RIAS </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+'  '+cCodigo+'</B></TD>'	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>
//	cHtml += CRLF + '		<TD colspan="16" width="10%" align="left" bgcolor="#00BFFF"><B>'+' '+'</B></TD>'
	cHtml += CRLF +		'</TR>'
	
	cHtml += CRLF +'</TABLE>'
	cHtml += CRLF +'<br><br>'

RETURN(cHTML)

//=========================================+
//  TITULO DOS CAMPOS DO HTML              +
//=========================================+
STATIC FUNCTION HtmlTit()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	//cHtml += CRLF +'		<TD height="25" colspan="3"  align="center" valign="middle"  bgcolor="#00BFFF"><B></B></TD>'
	//cHtml += CRLF +'		<TD height="25" colspan="5"  align="center" valign="middle" bgcolor="#87CEFA"><B></B></TD>'
	//cHtml += CRLF +'		<TD height="25" colspan="4"  align="center" valign="middle"  bgcolor="#00BFFF"><B></B></TD>'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>

	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                        </B></TD>'		
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA                   </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE                </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O               </B></TD>'
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA                   </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                        </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE                </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O               </B></TD>'
	ELSEIF MV_PAR06 == 2
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
	ELSEIF MV_PAR06 == 3
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
	ENDIF

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PROVIS√O F…RIAS             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ADIC. PROVIS√O F…RIAS       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>1/3 PROVIS√O F…RIAS         </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL PROV. F…RIAS          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>INSS PROV. F…RIAS           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FGTS PROV. F…RIAS           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL ENC. PROV. F…RIAS     </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL GERAL PROV. F…RIAS    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL BAIXAS PROV. F…RIAS   </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodap()

	
	Local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS ACUMULADO ATUAL ===> &nbsp;</td> 			
	FOR X =1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACATU[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS ACUMULADO ANTERIOR ===> &nbsp;</td> 			
	FOR X = 1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACANT[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS NO MES ===> &nbsp;</td> 			
	FOR X = 1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACMES[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE018FER'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥10/05/2013   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Insere novas perguntas ao sx1                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CriaSX1(cPerg)

	Local aRegs := {}
// GRUPO/ORDEM/PERGUNT/PERSPA/PERENG/VARIAV/TIPO/TAM/DEC/PRESEL/GSC/VALID/VAR01/DEF01/DEFSPA1/DEFENG1/CNT01/VAR02/DEF02/DEFSPA2/DEFENG2/CNT02/VAR03/DEF03/DEFSPA3/DEFENG3/CNT03/VAR04/DEF04/DEFSPA4/DEFENG4/CNT04/VAR05/DEF05/DEFSPA5/DEFENG5/CNT05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
	
	Aadd(aRegs,{cPerg,'01','Ano  (AAAA)              ','','','MV_CH1','C',04,0,0,'G',' ','MV_PAR01','       ','','','','','   '    ,'','','','','      ','','','','','','','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','MÍs: (MM)                ','','','MV_CH2','C',02,0,0,'G',' ','MV_PAR02','       ','','','','','   '    ,'','','','','      ','','','','','','','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial                   ','','','MV_CH3','C',02,0,0,'G',' ','MV_PAR03','       ','','','','','   '    ,'','','','','      ','','','','','','','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'04','Filial AtÅE              ','','','MV_CH4','C',02,0,0,'G',' ','MV_PAR04','       ','','','','','   '    ,'','','','','      ','','','','','','','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'05','Ferias/D.Terc            ','','','MV_CH5','N',01,0,1,'C',' ','MV_PAR05','F'      ,'','','','','D'      ,'','','','','      ','','','','','','','','','','','','','','','F','','','',''})
	Aadd(aRegs,{cPerg,'06','D=Det/C=C.Custo/F=Filial ','','','MV_CH6','N',01,0,1,'C',' ','MV_PAR06','Detalhe','','','','','C.Custo','','','','','Filial','','','','','','','','','','','','','','','D','','','',''})
	Aadd(aRegs,{cPerg,'07','Ordem Alfabet.?(S/N)     ','','','MV_CH7','N',01,0,1,'C',' ','MV_PAR07','Sim'    ,'','','','','Nao'    ,'','','','','      ','','','','','','','','','','','','','','','N','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return


Static Function gerares()

	Local cQuery := ' '
	Local lLoop  := .T.
	Local cOrdm  := "01"
	Local nArq   := Nil
	Local cPath  := AllTrim(GetTempPath())
	Local nCont  := 01
	Local cHtml  := ' '
	Local nRegua := 0
	Local nContArq := 0
	cTotal := 0
	
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]

	While lLoop
		If File(cPath+"GTGEP018DET"+cOrdm+".xls")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	
	cText  := "RelatÛrio de Provis„o de 13∫ Sal·rio  - De: " + STRZERO(VAL(MV_PAR02),2)+"/"+STRZERO(VAL(MV_PAR01),4)
	
	mesano := STRZERO(VAL(MV_PAR01),4)+STRZERO(VAL(MV_PAR02),2)  

	IF VAL(MV_PAR02) = 1
		mesanoA := STRZERO((VAL(MV_PAR01)-1),4)+'12'
	ELSE
		mesanoA := STRZERO(VAL(MV_PAR01),4)+STRZERO((VAL(MV_PAR02)-1),2)	
	ENDIF


	cQuery := CRLF +" SELECT "

	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" NOME,FILIAL,CCUSTO,MATRICULA,TIPO,SALARIO,ADMISSA,"
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" FILIAL,CCUSTO,MATRICULA,TIPO,NOME,SALARIO,ADMISSA,"
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" FILIAL,CCUSTO,TIPO,"	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" FILIAL,TIPO,"	
	ENDIF

	cQuery += CRLF +" SUM(PRO13) AS PRO13,SUM(ADICPRO13) AS ADICPRO13,SUM(PRIPARC) AS PRIPARC, "
	cQuery += CRLF +" SUM(PRO13)+SUM(ADICPRO13)+SUM(PRIPARC) AS TOTPRO13, "
	cQuery += CRLF +" SUM(INSSPRO13) AS INSSPRO13,SUM(FGTSPRO13) AS FGTSPRO13, "
	cQuery += CRLF +" SUM(INSSPRO13)+SUM(FGTSPRO13) AS TOTENC, "
	cQuery += CRLF +" SUM(PRO13)+SUM(ADICPRO13)+SUM(PRIPARC)+SUM(INSSPRO13)+SUM(FGTSPRO13) AS TOTGER,SUM(BXPRO13) AS BXPRO13 "
	cQuery += CRLF +" FROM ( "

	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'ATUAL ' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0136') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRO13, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0267') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0268') THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRIPARC, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0137') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0138') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPRO13, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0270','0271','0272','0273','0274','0275','0276','0277','0280','0284','0286','0287','0332','0333','0334','0335','0336') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPRO13  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" UNION "

	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'ANTERIOR ' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0136') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRO13, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0267') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0268') THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRIPARC, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0137') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0138') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPRO13, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0270','0271','0272','0273','0274','0275','0276','0277','0280','0284','0286','0287','0332','0333','0334','0335','0336') THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPRO13  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" UNION "

	cQuery += CRLF +" SELECT RT_FILIAL AS FILIAL,RT_CC AS CCUSTO,RT_MAT AS MATRICULA,'NO MES' AS TIPO,RA_NOME  AS NOME,RA_SALARIO AS SALARIO,RA_ADMISSA AS ADMISSA, "
	cQuery += CRLF +" RV_CODFOL AS CODFOL,RT_VERBA AS VERBA,RV_DESC AS DESCRIC, LEFT(RT_DATACAL,6) AS DTCALC, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0136')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0136')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRO13, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0267')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0267')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS ADICPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0268')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0268')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR*-1) "	
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS PRIPARC, "
	cQuery += CRLF +" CASE " 
	cQuery += CRLF +" WHEN RV_CODFOL IN('0137')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0137')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS INSSPRO13, "
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0138')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0138')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END "
	cQuery += CRLF +" AS FGTSPRO13, " 
	cQuery += CRLF +" CASE  "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0270','0271','0272','0273','0274','0275','0276','0277','0280','0284','0286','0287','0332','0333','0334','0335','0336')  AND LEFT(RT_DATACAL,6)  = '"+mesanoa+"'  THEN SUM(RT_VALOR*-1) "
	cQuery += CRLF +" WHEN RV_CODFOL IN('0270','0271','0272','0273','0274','0275','0276','0277','0280','0284','0286','0287','0332','0333','0334','0335','0336')  AND LEFT(RT_DATACAL,6)  = '"+mesano+"'  THEN SUM(RT_VALOR) "
	cQuery += CRLF +" ELSE SUM(0) END  "
	cQuery += CRLF +" AS BXPRO13  "
	cQuery += CRLF +" FROM "+ RETSQLNAME("SRT")+ " A, "	+ RETSQLNAME("SRV")+ " B, "+ RETSQLNAME("SRA")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND LEFT(RT_DATACAL,6)  IN('"+mesanoa+"','"+mesano+"') "
	cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL "  /////--------AND RT_CC = RA_CC  "
	//cQuery += CRLF +" AND RT_VERBA = RV_COD AND RT_MAT = RA_MAT AND RT_FILIAL = RA_FILIAL AND RT_CC = RA_CC  "
	cQuery += CRLF +" GROUP BY RT_FILIAL,RT_CC,RT_MAT,RA_NOME,RA_SALARIO,RA_ADMISSA,RV_CODFOL,RT_VERBA,RV_DESC,LEFT(RT_DATACAL,6) "

	cQuery += CRLF +" ) "

	cQuery += CRLF +" AS AGRUPADO "

	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" GROUP BY NOME,FILIAL,CCUSTO,MATRICULA,TIPO,SALARIO,ADMISSA "
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" GROUP BY FILIAL,CCUSTO,MATRICULA,TIPO,NOME,SALARIO,ADMISSA "
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" GROUP BY FILIAL,CCUSTO,TIPO "	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" GROUP BY FILIAL,TIPO "	
	ENDIF
         
/*
	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cQuery += CRLF +" ORDER BY NOME,FILIAL,CCUSTO,MATRICULA,TIPO "
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cQuery += CRLF +" ORDER BY FILIAL,CCUSTO,MATRICULA,TIPO,NOME "
	ELSEIF MV_PAR06 == 2
		cQuery += CRLF +" ORDER BY FILIAL,CCUSTO,TIPO "	
	ELSEIF MV_PAR06 == 3
		cQuery += CRLF +" ORDER BY FILIAL,TIPO "	
	ENDIF
*/

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"DETGEPRO"+cOrdm+".xls"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	

	cHtmlOk := HtmlCabR(cText,'De: ', MV_PAR02,' / ', MV_PAR01, '') // cabeÁalho do relatorio "HLB"
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitR(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotal := 0
	
	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMADO DE TABELA - LINHA BANCA E LINHA AZUL.
		nCont ++
		IF nCont%2 == 0
			cBgColor := "#FFFFFF"
		ELSE
			cBgColor := "#CAE4FF"
		ENDIF
		
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
	
		IF MV_PAR06 == 1 .and. MV_PAR07 == 1
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // NOME
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // MATRICULA									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // TIPO									
			cValor := &("ENF->"+aStruFim[6][1])
			cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // salario 
	        cData :=&("ENF->"+aStruFim[7][1])
			cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// DATA admissao
			cNe := 7
		ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // MATRICULA									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // TIPO									
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // NOME
			cValor := &("ENF->"+aStruFim[6][1])
			cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // salario 
	        cData :=&("ENF->"+aStruFim[7][1])
			cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// DATA admissao
			cNe := 7			
		ELSEIF MV_PAR06 == 2
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // CCUSTO		
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // TIPO									
			cNe := 3
		ELSEIF MV_PAR06 == 3
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // TIPO									
			cNe := 2
		ENDIF

		IF ALLTRIM(&("ENF->TIPO")) = "ATUAL"		
			FOR X = 1 TO 9
				ACATU[X] := ACATU[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X
		ELSEIF ALLTRIM(&("ENF->TIPO")) == "ANTERIOR" 
			FOR X = 1 TO 9
				ACANT[X] := ACANT[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X		
		ELSEIF ALLTRIM(&("ENF->TIPO")) = "NO MES"
			FOR X = 1 TO 9
				ACMES[X] := ACMES[X] + &("ENF->"+aStruFim[X+cNe][1])
			NEXT X
		ENDIF

		cValor := &("ENF->"+aStruFim[1+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // PROV.13
		cValor := &("ENF->"+aStruFim[2+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // ADIC. PROV.13 	
		cValor := &("ENF->"+aStruFim[3+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // 1. PARCELA
		cValor := &("ENF->"+aStruFim[4+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL PROV.13
		cValor := &("ENF->"+aStruFim[5+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // INSS PROV.13
		cValor := &("ENF->"+aStruFim[6+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // FGTS PROV.13
		cValor := &("ENF->"+aStruFim[7+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOT. ENC. PROV.13
		cValor := &("ENF->"+aStruFim[8+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL GERAL PROV.13
		cValor := &("ENF->"+aStruFim[9+cNe][1])
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>' // TOTAL BAIXAS PROV.13 NO MES
		
	  	nContArq++  
	
		cHtml += CRLF+' </tr> ' 
		
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF
		
		ENF->(DBSKIP())  
	END 
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlRodapR()   // chama o rodapÅEdo relatorio
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	//Fecha Arquivo
	fClose(nArq)
	
	If ApOleClient("MsExcel")
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else
		ShellExecute("open",cArq,"","",1)
	EndIf

return

//=========================================+
//FUNCAO PARA GERAR CABE«ALHO DO HTML      +
//=========================================+
STATIC FUNCTION HtmlCabR()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Provisıes de 13∫ Sal·rio </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+'  '+cCodigo+'</B></TD>'	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>
//	cHtml += CRLF + '		<TD colspan="16" width="10%" align="left" bgcolor="#00BFFF"><B>'+' '+'</B></TD>'
	cHtml += CRLF +		'</TR>'
	
	cHtml += CRLF +'</TABLE>'
	cHtml += CRLF +'<br><br>'

RETURN(cHTML)

//=========================================+
//  TITULO DOS CAMPOS DO HTML              +
//=========================================+
STATIC FUNCTION HtmlTitR()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	//cHtml += CRLF +'		<TD height="25" colspan="3"  align="center" valign="middle"  bgcolor="#00BFFF"><B></B></TD>'
	//cHtml += CRLF +'		<TD height="25" colspan="5"  align="center" valign="middle" bgcolor="#87CEFA"><B></B></TD>'
	//cHtml += CRLF +'		<TD height="25" colspan="4"  align="center" valign="middle"  bgcolor="#00BFFF"><B></B></TD>'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	IF MV_PAR06 == 1 .and. MV_PAR07 == 1
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                        </B></TD>'		
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA                   </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE                </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O               </B></TD>'
	ELSEIF MV_PAR06 == 1 .and. MV_PAR07 == 2
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA                   </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                        </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE                </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O               </B></TD>'
	ELSEIF MV_PAR06 == 2
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO CUSTO                </B></TD>'	
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
	ELSEIF MV_PAR06 == 3
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                      </B></TD>'
		cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T I P O                     </B></TD>'
	ENDIF

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PROVIS√O 13. SAL¡RIO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ADIC. PROVIS√O 13. SAL¡RIO     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PRIM. PARCELA 13. SAL¡RIO      </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL PROV. 13. SAL¡RIO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>INSS PROV. 13. SAL¡RIO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FGTS PROV. 13. SAL¡RIO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL ENC. PROV. 13. SAL¡RIO   </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL GERAL PROV. 13. SAL¡RIO  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TOTAL BAIXAS PROV. 13. SAL¡RIO </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapR()

	
	Local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS ACUMULADO ATUAL ===> &nbsp;</td> 			
	FOR X =1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACATU[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS ACUMULADO ANTERIOR ===> &nbsp;</td> 			
	FOR X = 1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACANT[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">TOTAIS NO MES ===> &nbsp;</td> 			
	FOR X = 1 TO 9
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(ACMES[X],"@E 999,999,999,999.99")+'&nbsp</TD>'
    NEXT X
	cHtml += CRLF +' 	</TR> 
	
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGEP018DET'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)

