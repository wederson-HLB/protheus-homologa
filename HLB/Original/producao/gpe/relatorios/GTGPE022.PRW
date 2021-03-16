#include "PROTHEUS.CH"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 23/01/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelatÛrio de MÈdias: FER/13∫/Av. Previo                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Clientes HLB BRASIL                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE022()   

Private cPerg     := "GTGPE022  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotal := 0
private cTES := {}
private cNOMECOM := space(40)
private cCGC     := space(20)
private cCNPJ    := space(20)
private cPeriodo := space(6)
private cPerMov  := space(6)

PRIVATE cTotalBF := 0
PRIVATE cTotalMF := 0
PRIVATE cTotalB1 := 0
PRIVATE cTotalM1 := 0
PRIVATE cTotalBA := 0
PRIVATE cTotalMA := 0

cNOMECOM := SM0->M0_NOMECOM
cCGC     := SM0->M0_CGC
cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
cCodigo  := SM0->M0_CODIGO

private _cFilial := SM0->M0_CODFIL

CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("RelatÛrio de MÈdias ? ") == "S"
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
	cTotal := 0
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE022"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	IF MV_PAR04 == 2
		GERAVERB()  // resumo por funcionario e verba
		RETURN
	ENDIF
	IF MV_PAR04 == 3
		GERAFUN()  // resumo por funcionario
		RETURN
	ENDIF
	IF MV_PAR04 == 4
		GERAcc()  // resumo por c.custo
		RETURN
	ENDIF

	
	cText  := "RELA«√O DE M…DIAS - Anal˙ëico - Em: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)

	cPeriodo := left(DTOS(MV_PAR01),6)

	//------------- RELATORIO DE MEDIAS DETALHADO
	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE, ADMISSAO, "
 	cQuery += CRLF +" VERBA, DESCRIC, HORAS, VALOR, DATVERBA, PERAQUIS, FERVENC, FERPROP, BASFER, MEDFER, BAS13, MED13, BASAVI, MEDAVI "
 	cQuery += CRLF +" FROM( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RD_PD AS VERBA,RV_DESC AS DESCRIC,RD_HORAS AS HORAS, "
 	cQuery += CRLF +" RD_VALOR AS VALOR,RD_DATARQ AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RD_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RD_FILIAL = C.RA_FILIAL AND A.RD_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RD_FILIAL = D.RF_FILIAL AND A.RD_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND A.RD_DATARQ >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND A.RD_DATARQ <= '"+cPeriodo+"' " 
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" UNION "
 	cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RC_PD AS VERBA,RV_DESC AS DESCRIC,RC_HORAS AS HORAS, "
 	cQuery += CRLF +" RC_VALOR AS VALOR,LEFT(RC_DATA,6) AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RC_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RC_FILIAL = C.RA_FILIAL AND A.RC_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RC_FILIAL = D.RF_FILIAL AND A.RC_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND LEFT(A.RC_DATA,6) >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND left(A.RC_DATA,6) <= '"+cPeriodo+"' "  
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" ) "
 	cQuery += CRLF +" AS AGRUPADO "
 	cQuery += CRLF +" ORDER BY FILIAL, MATRICULA, NOME, VERBA, DESCRIC, DATVERBA "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE022"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCab(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTit(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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
	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // NOME
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // COD.CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // DESCR. CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // COD FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // DESCR.FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // NUM. CTPS
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // SERIE CTPS
		cValor := &("ENF->"+aStruFim[10][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SALARIO BASE
        cData :=&("ENF->"+aStruFim[11][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>'          // DATA ADMISSAO		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[12][1]))+'&nbsp</td>'  // COD VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[13][1]))+'&nbsp</td>'  // DESCR. VERBA
		cValor := &("ENF->"+aStruFim[14][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.99")+'&nbsp</TD>'		// HORAS
		cValor := &("ENF->"+aStruFim[15][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// VALOR
		cPerMov := &("ENF->"+aStruFim[16][1])
		cHtml += CRLF +'<TD align="left">'+substr(cPerMov,5,2)+'/'+substr(cPerMov,1,4)+'&nbsp</td>'  // PERIODO MOVTO
        cData :=&("ENF->"+aStruFim[17][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>'          // PER.AQUISITIVO
		cValor := &("ENF->"+aStruFim[18][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS VENCIDAS				
		cValor := &("ENF->"+aStruFim[19][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS PROPORC.		
		cValor := &("ENF->"+aStruFim[20][1])
		cTotalBF := cTotalBF + cValor		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA FER
		cValor := &("ENF->"+aStruFim[21][1])
		cTotalMF := cTotalMF + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA F…RIAS		
		cValor := &("ENF->"+aStruFim[22][1])
		cTotalB1 := cTotalB1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA 13∫
		cValor := &("ENF->"+aStruFim[23][1])
		cTotalM1 := cTotalM1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA 13∫	
		cValor := &("ENF->"+aStruFim[24][1])
		cTotalBA := cTotalBA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA AVISO
		cValor := &("ENF->"+aStruFim[25][1])
		cTotalMA := cTotalMA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA AV.PREVIO	

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
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE M…DIAS - Anal˙ëico  </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+' - '+_cFilial+'</B></TD>'	
	cHtml += CRLF +'	</TR>'

	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>

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
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR C.CUSTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>COD. FUN«AO  	   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR. FUN«√O    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NUMERO CTPS      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SERIE CTPS       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISSAO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>COD. VERBA       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR. VERBA     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>HORAS            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERIODO MOVTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERIODO AQUIS.   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS F…RIAS VENC </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS F…RIAS PROP </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA FER   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA F…RIAS     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA 13∫   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA 13∫        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA AVISO </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA AV.PREVIO  </B></TD>'
		
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
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalB1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalM1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE022'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥23/01/2017   ∫±±
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
	
	Aadd(aRegs,{cPerg,'01','Data Base:                ','','','MV_CH1','D',08,0,0,'G',' ','MV_PAR01','       ','','','','',''       ,'','','','',''      ,'','','','','' ,'','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','Filial de                 ','','','MV_CH2','C',02,0,0,'G',' ','MV_PAR02','       ','','','','',''       ,'','','','',''      ,'','','','','' ,'','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial AtÅE               ','','','MV_CH3','C',02,0,0,'G',' ','MV_PAR03','       ','','','','',''       ,'','','','',''      ,'','','','','' ,'','','','','','','','','',' ','','','',''})
	Aadd(aRegs,{cPerg,'04','D=Det/V=Verba/F=Fun/C=CC  ','','','MV_CH4','N',01,0,1,'C',' ','MV_PAR04','Detalhe','','','','','Verba','','','','','Funcion','','','','','C.Custo' ,'','','','','','','','','','D','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return


//// resumido POR VERBA

STATIC FUNCTION GERAVERB()
	
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
		If File(cPath+"GTGPE022"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	cText  := "RELA«√O DE M…DIAS - Por funcion·rio e verba - Em: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)

	cPeriodo := left(DTOS(MV_PAR01),6)

	//------------- RELATORIO DE MEDIAS por funcionario e verba
	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO,VERBA,DESCRIC, "
 	cQuery += CRLF +" SUM(BASFER) AS BASFER, SUM(MEDFER) AS MEDFER, SUM(BAS13) AS BAS13, SUM(MED13) AS MED13, SUM(BASAVI) AS BASAVI, SUM(MEDAVI) AS MEDAVI "
 	cQuery += CRLF +" FROM( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RD_PD AS VERBA,RV_DESC AS DESCRIC,RD_HORAS AS HORAS, "
 	cQuery += CRLF +" RD_VALOR AS VALOR,RD_DATARQ AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RD_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RD_FILIAL = C.RA_FILIAL AND A.RD_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RD_FILIAL = D.RF_FILIAL AND A.RD_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND A.RD_DATARQ >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND A.RD_DATARQ <= '"+cPeriodo+"' " 
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" UNION "
 	cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RC_PD AS VERBA,RV_DESC AS DESCRIC,RC_HORAS AS HORAS, "
 	cQuery += CRLF +" RC_VALOR AS VALOR,LEFT(RC_DATA,6) AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RC_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RC_FILIAL = C.RA_FILIAL AND A.RC_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RC_FILIAL = D.RF_FILIAL AND A.RC_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND LEFT(A.RC_DATA,6) >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND left(A.RC_DATA,6) <= '"+cPeriodo+"' "  
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" ) "
 	cQuery += CRLF +" AS AGRUPADO "
 	cQuery += CRLF +" GROUP BY FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO,VERBA,DESCRIC "
 	cQuery += CRLF +" ORDER BY FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO,VERBA,DESCRIC "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE022"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCabv(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitv(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // NOME
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // COD.CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // DESCR. CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // COD FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // DESCR.FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // NUM. CTPS
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // SERIE CTPS
		cValor := &("ENF->"+aStruFim[10][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SALARIO BASE
        cData :=&("ENF->"+aStruFim[11][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>'          // DATA ADMISSAO		
	   	cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[12][1]))+'&nbsp</td>'  // COD VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[13][1]))+'&nbsp</td>'  // DESCR. VERBA
		cValor := &("ENF->"+aStruFim[14][1])
		cTotalBF := cTotalBF + cValor		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA FER
		cValor := &("ENF->"+aStruFim[15][1])
		cTotalMF := cTotalMF + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA F…RIAS		
		cValor := &("ENF->"+aStruFim[16][1])
		cTotalB1 := cTotalB1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA 13∫
		cValor := &("ENF->"+aStruFim[17][1])
		cTotalM1 := cTotalM1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA 13∫	
		cValor := &("ENF->"+aStruFim[18][1])
		cTotalBA := cTotalBA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA AVISO
		cValor := &("ENF->"+aStruFim[19][1])
		cTotalMA := cTotalMA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA AV.PREVIO	
		
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
	
	cHtmlOk := HtmlRodapv()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabv()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE M…DIAS - Por funcion·rio e verba  </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+' - '+_cFilial+'</B></TD>'	
	cHtml += CRLF +'	</TR>'

	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>

	cHtml += CRLF +		'</TR>'
	
	cHtml += CRLF +'</TABLE>'
	cHtml += CRLF +'<br><br>'

RETURN(cHTML)

//=========================================+
//  TITULO DOS CAMPOS DO HTML              +
//=========================================+
STATIC FUNCTION HtmlTitv()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR C.CUSTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>COD. FUN«AO  	   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR. FUN«√O    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NUMERO CTPS      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SERIE CTPS       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISSAO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>COD. VERBA       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR. VERBA     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA FER   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA F…RIAS     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA 13∫   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA 13∫        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA AVISO </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA AV.PREVIO  </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapv()

	
	Local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalB1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalM1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE022'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)



//// resumido POR FUNCIONARIO

STATIC FUNCTION GERAFUN()
	
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
		If File(cPath+"GTGPE022"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	cText  := "RELA«√O DE M…DIAS - Por funcion·rio - Em: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)

	cPeriodo := left(DTOS(MV_PAR01),6)

	//------------- RELATORIO DE MEDIAS por funcionario
	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO, "
 	cQuery += CRLF +" SUM(BASFER) AS BASFER, SUM(MEDFER) AS MEDFER, SUM(BAS13) AS BAS13, SUM(MED13) AS MED13, SUM(BASAVI) AS BASAVI, SUM(MEDAVI) AS MEDAVI "
 	cQuery += CRLF +" FROM( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RD_PD AS VERBA,RV_DESC AS DESCRIC,RD_HORAS AS HORAS, "
 	cQuery += CRLF +" RD_VALOR AS VALOR,RD_DATARQ AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RD_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RD_FILIAL = C.RA_FILIAL AND A.RD_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RD_FILIAL = D.RF_FILIAL AND A.RD_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND A.RD_DATARQ >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND A.RD_DATARQ <= '"+cPeriodo+"' " 
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" UNION "
 	cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RC_PD AS VERBA,RV_DESC AS DESCRIC,RC_HORAS AS HORAS, "
 	cQuery += CRLF +" RC_VALOR AS VALOR,LEFT(RC_DATA,6) AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RC_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RC_FILIAL = C.RA_FILIAL AND A.RC_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RC_FILIAL = D.RF_FILIAL AND A.RC_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND LEFT(A.RC_DATA,6) >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND left(A.RC_DATA,6) <= '"+cPeriodo+"' "  
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" ) "
 	cQuery += CRLF +" AS AGRUPADO "
 	cQuery += CRLF +" GROUP BY FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO "
 	cQuery += CRLF +" ORDER BY FILIAL, MATRICULA, NOME, CC, DESCRCC, CODFUNC, DESCFUN, NUMCP, SERCP, SALARIOBASE,ADMISSAO "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE022"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCabF(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitF(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // NOME
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // COD.CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // DESCR. CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // COD FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // DESCR.FUNCAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // NUM. CTPS
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // SERIE CTPS
		cValor := &("ENF->"+aStruFim[10][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SALARIO BASE
        cData :=&("ENF->"+aStruFim[11][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>'          // DATA ADMISSAO		
		cValor := &("ENF->"+aStruFim[12][1])
		cTotalBF := cTotalBF + cValor		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA FER
		cValor := &("ENF->"+aStruFim[13][1])
		cTotalMF := cTotalMF + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA F…RIAS		
		cValor := &("ENF->"+aStruFim[14][1])
		cTotalB1 := cTotalB1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA 13∫
		cValor := &("ENF->"+aStruFim[15][1])
		cTotalM1 := cTotalM1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA 13∫	
		cValor := &("ENF->"+aStruFim[16][1])
		cTotalBA := cTotalBA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA AVISO
		cValor := &("ENF->"+aStruFim[17][1])
		cTotalMA := cTotalMA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA AV.PREVIO	
		
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
	
	cHtmlOk := HtmlRodapF()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabF()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE M…DIAS - Por funcion·rio </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+' - '+_cFilial+'</B></TD>'	
	cHtml += CRLF +'	</TR>'

	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>

	cHtml += CRLF +		'</TR>'
	
	cHtml += CRLF +'</TABLE>'
	cHtml += CRLF +'<br><br>'

RETURN(cHTML)

//=========================================+
//  TITULO DOS CAMPOS DO HTML              +
//=========================================+
STATIC FUNCTION HtmlTitF()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR C.CUSTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>COD. FUN«AO  	   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR. FUN«√O    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NUMERO CTPS      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SERIE CTPS       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISSAO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA FER   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA F…RIAS     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA 13∫   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA 13∫        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA AVISO </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA AV.PREVIO  </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapF()

	
	Local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalB1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalM1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE022'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)


//// resumido POR C.CUSTO

STATIC FUNCTION GERACC()
	
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
		If File(cPath+"GTGPE022"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	cText  := "RELA«√O DE M…DIAS - Por C. Custo - Em: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)

	cPeriodo := left(DTOS(MV_PAR01),6)

	//------------- RELATORIO DE MEDIAS por centro de custo
	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL, CC, DESCRCC, "
 	cQuery += CRLF +" SUM(BASFER) AS BASFER, SUM(MEDFER) AS MEDFER, SUM(BAS13) AS BAS13, SUM(MED13) AS MED13, SUM(BASAVI) AS BASAVI, SUM(MEDAVI) AS MEDAVI "
 	cQuery += CRLF +" FROM( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RD_PD AS VERBA,RV_DESC AS DESCRIC,RD_HORAS AS HORAS, "
 	cQuery += CRLF +" RD_VALOR AS VALOR,RD_DATARQ AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RD_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RD_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RD_FILIAL = C.RA_FILIAL AND A.RD_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RD_FILIAL = D.RF_FILIAL AND A.RD_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND A.RD_DATARQ >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND A.RD_DATARQ <= '"+cPeriodo+"' " 
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" UNION "
 	cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_MAT AS MATRICULA,RA_NOME AS NOME,RA_CC AS CC,CTT_DESC01 AS DESCRCC, "
 	cQuery += CRLF +" RA_CODFUNC AS CODFUNC,RJ_DESC AS DESCFUN,RA_NUMCP AS NUMCP,RA_SERCP AS SERCP, "
 	cQuery += CRLF +" RA_SALARIO AS SALARIOBASE,RA_ADMISSA AS ADMISSAO,RC_PD AS VERBA,RV_DESC AS DESCRIC,RC_HORAS AS HORAS, "
 	cQuery += CRLF +" RC_VALOR AS VALOR,LEFT(RC_DATA,6) AS DATVERBA,RF_DATABAS AS PERAQUIS,RF_DFERVAT AS FERVENC, RF_DFERAAT AS FERPROP, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDFER,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDFER, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BAS13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MED13,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MED13, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS BASAVI, "
	cQuery += CRLF +" CASE "
	cQuery += CRLF +" WHEN LEFT(RV_MEDAVI,1) NOT IN(' ','N') THEN RC_VALOR/12  "
	cQuery += CRLF +" else 0 end  "
	cQuery += CRLF +" AS MEDAVI  "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRV")+" B ON A.RC_PD = B.RV_COD AND B.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRA")+" C ON A.RC_FILIAL = C.RA_FILIAL AND A.RC_MAT = C.RA_MAT AND C.D_E_L_E_T_ <> '*' AND C.RA_SITFOLH <> 'D' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRF")+" D ON A.RC_FILIAL = D.RF_FILIAL AND A.RC_MAT = D.RF_MAT AND D.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("SRJ")+" E ON C.RA_CODFUNC = E.RJ_FUNCAO AND E.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" LEFT JOIN " + RETSQLNAME("CTT")+" F ON C.RA_CC = F.CTT_CUSTO AND F.D_E_L_E_T_ <> '*' "
 	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND LEFT(RV_MEDFER+RV_MED13+RV_MEDAVI,1) NOT IN(' ','N') "
 	cQuery += CRLF +" AND LEFT(A.RC_DATA,6) >= LEFT(D.RF_DATABAS,6) " 
 	cQuery += CRLF +" AND left(A.RC_DATA,6) <= '"+cPeriodo+"' "  
 	cQuery += CRLF +" AND C.RA_SITFOLH <> 'D' " 
 	cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR02+"' AND '" +MV_PAR03+"' "
 	cQuery += CRLF +" ) "
 	cQuery += CRLF +" AS AGRUPADO "
 	cQuery += CRLF +" GROUP BY FILIAL, CC, DESCRCC "
 	cQuery += CRLF +" ORDER BY FILIAL, CC, DESCRCC "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE022"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCabC(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitC(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // COD.CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // DESCR. CC
		cValor := &("ENF->"+aStruFim[4][1])
		cTotalBF := cTotalBF + cValor		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA FER
		cValor := &("ENF->"+aStruFim[5][1])
		cTotalMF := cTotalMF + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA F…RIAS		
		cValor := &("ENF->"+aStruFim[6][1])
		cTotalB1 := cTotalB1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA 13∫
		cValor := &("ENF->"+aStruFim[7][1])
		cTotalM1 := cTotalM1 + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA 13∫	
		cValor := &("ENF->"+aStruFim[8][1])
		cTotalBA := cTotalBA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// BASE M…DIA AVISO
		cValor := &("ENF->"+aStruFim[9][1])
		cTotalMA := cTotalMA + cValor				
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// M…DIA AV.PREVIO	

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
	
	cHtmlOk := HtmlRodapC()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabC()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE M…DIAS - Por C. Custo </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+' - '+_cFilial+'</B></TD>'	
	cHtml += CRLF +'	</TR>'

	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:12px">'
	cHtml += CRLF +'		<TD height="20" colspan="16" width="10%" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="left" valign="middle"><b>'+cText+'</b></TD>'
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF + '	<TR>

	cHtml += CRLF +		'</TR>'
	
	cHtml += CRLF +'</TABLE>'
	cHtml += CRLF +'<br><br>'

RETURN(cHTML)

//=========================================+
//  TITULO DOS CAMPOS DO HTML              +
//=========================================+
STATIC FUNCTION HtmlTitC()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR C.CUSTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA FER   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA F…RIAS     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA 13∫   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA 13∫        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BASE M…DIA AVISO </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>M…DIA AV.PREVIO  </B></TD>'

		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapC()

	
	Local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de FÈrias:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalB1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de 13∫:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalM1,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Base MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalBA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total MÈdias de Aviso:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalMA,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE022'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)





