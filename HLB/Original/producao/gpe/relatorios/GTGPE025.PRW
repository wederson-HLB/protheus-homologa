#include "PROTHEUS.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 08/02/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelatÛrio de Ficha Financeira em excel                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Clientes HLB BRASIL                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE025()   

Private cPerg     := "GTGPE025  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotal := 0
private cHtml  := ' '
private nArq   := Nil
PRIVATE cArq := ""

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

Private aTIPOS := { "1", "2", "3"," "}
Private aTotTipos[4] 
Private aTotGer[4]

for i = 1 to 4
	aTottipos[i] := 0
	aTotGer[i] := 0
next i

PRIVATE	cTotalVRF := 0
PRIVATE	cTotalVVF := 0
PRIVATE	cTotalDRF := 0
PRIVATE	cTotalDVF := 0
PRIVATE	cTotalLiqF := 0
private x_codigo := ""

cNOMECOM := SM0->M0_NOMECOM
cCGC     := SM0->M0_CGC
cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
cCodigo  := SM0->M0_CODIGO

private _cFilial := SM0->M0_CODFIL

CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("Gera Ficha Financeira ? ") == "S"
		Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
	Else
		Return
	EndIf
Else
	Return
EndIf

RETURN



STATIC FUNCTION geracom()
	
	Private cQuery := ' '
	Private lLoop  := .T.
	Private cOrdm  := "01"
	Private cPath  := AllTrim(GetTempPath())
	Private nCont  := 01
	Private nRegua := 0
	Private nContArq := 0
	
	cTotal := 0
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE025"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cPeriodo := left(DTOS(MV_PAR01),4)
	
	cText  := "Ficha Financeira - Anal˙ëico - Exercicio: " + cPeriodo 

	cPeriodo01 := cPeriodo+"01"
	cPeriodo02 := cPeriodo+"02"
	cPeriodo03 := cPeriodo+"03"
	cPeriodo04 := cPeriodo+"04"
	cPeriodo05 := cPeriodo+"05"
	cPeriodo06 := cPeriodo+"06"
	cPeriodo07 := cPeriodo+"07"
	cPeriodo08 := cPeriodo+"08"
	cPeriodo09 := cPeriodo+"09"
	cPeriodo10 := cPeriodo+"10"
	cPeriodo11 := cPeriodo+"11"
	cPeriodo12 := cPeriodo+"12"

	IF MV_PAR04 == 1
		cText  := "Ficha Financeira - Resumo por Verba - Exercicio: " + cPeriodo
		RESUMO()  
		RETURN
	ELSEIF MV_PAR04 == 2
		cText  := "Ficha Financeira - Resumo por Filial - Exercicio: " + cPeriodo
		FILIAL()
		RETURN
	ELSEIF MV_PAR04 == 3
		cText  := "Ficha Financeira - Resumo por C.Custo - Exercicio: " + cPeriodo
		CCUSTO()
		RETURN
	ELSEIF MV_PAR04 == 4
		cText  := "Ficha Financeira - Anal˙ëico - Exercicio: " + cPeriodo 
	ENDIF


 	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL,MATRICULA,NOME,TIPO,VERBA,DESCRI,SUM(JANEIRO) JANEIRO, SUM(FEVEREIRO) FEVEREIRO, SUM(MARCO) MARCO, SUM(ABRIL) ABRIL, "
 	cQuery += CRLF +" SUM(MAIO) MAIO, SUM(JUNHO) JUNHO , SUM(JULHO) JULHO, SUM(AGOSTO) AGOSTO, "
 	cQuery += CRLF +" SUM(SETEMBRO) SETEMBRO, SUM(OUTUBRO) OUTUBRO , SUM(NOVEMBRO) NOVEMBRO, SUM(DEZEMBRO) DEZEMBRO, "
 	cQuery += CRLF +" SUM(JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO) TOTAL "
 	cQuery += CRLF +" FROM ( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL, RD_MAT AS MATRICULA,RA_NOME AS NOME,RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCRI, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo01+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JANEIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo02+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS FEVEREIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo03+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MARCO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo04+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS ABRIL, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo05+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MAIO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo06+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JUNHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo07+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JULHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo08+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS AGOSTO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo09+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS SETEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo10+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS OUTUBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo11+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS NOVEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo12+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS DEZEMBRO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, "+ RETSQLNAME("SRA")+" B, "+ RETSQLNAME("SRV")+" C "
 	cQuery += CRLF +" WHERE RD_VALOR > 0 "
 	cQuery += CRLF +" AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND RD_PD = RV_COD "
 	cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT AND RD_CC = RA_CC "
 	cQuery += CRLF +" GROUP BY RD_FILIAL,RD_MAT,RA_NOME,RV_TIPOCOD,RD_PD,RV_DESC,LEFT(RD_DATPGT,6) "
 	cQuery += CRLF +" ) AS AGRUPADO "
 	cQuery += CRLF +" WHERE JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO > 0 "
 	cQuery += CRLF +" GROUP BY FILIAL,MATRICULA,NOME,TIPO,VERBA,DESCRI "
 	cQuery += CRLF +" ORDER BY FILIAL,MATRICULA,NOME,TIPO,VERBA,DESCRI "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE025"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	nContArq := 0	
	nCont := 0
	cHtmlOk := ""

	cHtmlOk := HtmlCab(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtmlok := ""
	cHtml := ""	

	cHtmlOk := HtmlTit(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	cHtmlok := ""
	cHtml := ""	
	cTotal := 0
	
	ProcRegua(nRegua)

	_V := 1
	Qfunc := ' ' 
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMADO DE TABELA - LINHA BANCA E LINHA AZUL.
		nCont ++

		IF 	Qfunc <> ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[2][1])) 
	        QUEBFUN()
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'    // MATRICULA
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'    // NOME
		ELSE
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // MATRICULA
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // NOME

		ENDIF
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // DESCR
		nTipo := Ascan(aTIPOS,Alltrim(ENF->TIPO))
		cValor := &("ENF->"+aStruFim[7][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JANEIRO
		cValor := &("ENF->"+aStruFim[8][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// FEVEREIRO		
		cValor := &("ENF->"+aStruFim[9][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MARCO
		cValor := &("ENF->"+aStruFim[10][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// ABRIL	
		cValor := &("ENF->"+aStruFim[11][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MAIO
		cValor := &("ENF->"+aStruFim[12][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JUNHO		
		cValor := &("ENF->"+aStruFim[13][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JULHO
		cValor := &("ENF->"+aStruFim[14][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// AGOSTO	
		cValor := &("ENF->"+aStruFim[15][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SETEMBRO
		cValor := &("ENF->"+aStruFim[16][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// OUTUBRO		
		cValor := &("ENF->"+aStruFim[17][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// NOVEMBRO
		cValor := &("ENF->"+aStruFim[18][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// DEZEMBRO	
		cValor := &("ENF->"+aStruFim[19][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// TOTAL					
		cHtml += CRLF+' </tr> ' 

	  	nContArq++  
	
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF

		_V := _V + 1
		
		ENF->(DBSKIP())  
	END 

	QUEBFUN()
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
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

	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>Ficha Financeira - Anal˙ëico  </TITLE></HEAD>'
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
	
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JANEIRO  	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FEVEREIRO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAR«O            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ABRIL            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAIO             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JUNHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JULHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGOSTO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SETEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>OUTUBRO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOVEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DEZEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T O T A L        </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodap()

	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotGer[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotGer[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotGer[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	Atotger[1] := 0
	Atotger[2] := 0
	Atotger[3] := 0
 
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
	cHtml += CRLF +'Siga/GTGPE025'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '


Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥08/02/2017   ∫±±
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
	
	Aadd(aRegs,{cPerg,'01','Data Base do exerc˙Äio:            ','','','MV_CH1','D',08,0,0,'G',' ','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'02','Filial                             ','','','MV_CH2','C',02,0,0,'G',' ','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial AtÅE                        ','','','MV_CH3','C',02,0,0,'G',' ','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'04','V=Verba/F=Fil/C=C.C./A=Analit.:    ','','','MV_CH4','N',01,0,1,'C',' ','MV_PAR04','Verba','','','','','Fil','','','','','C.C.','','','','','Analit.','','','','','','','','','','V','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return



Static Function QUEBFUN()


	if _v <> 1

		cHtml += CRLF +'<br><br><br>'
		cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
		cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
		cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS FUNCIONARIO</b></td> 
		cHtml += CRLF +' 	</TR> 
		 	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotTipos[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 

		Atotger[1] := Atotger[1] + aTotTipos[1]
		Atotger[2] := Atotger[2] + aTotTipos[2]
		Atotger[3] := Atotger[3] + aTotTipos[3]
 
		aTotTipos[1] := 0
		aTotTipos[2] := 0
		aTotTipos[3] := 0

		cHtml += CRLF +'</TABLE>	
		
		cHtml += CRLF +'<br><br>'
		cHtml += CRLF +'Siga/GTGPE025'+x_Codigo
		
		cHtmlOk := cHtml
		FWrite(nArq,cHtmlOk,Len(cHtmlOk))
		cHtml := ""		
				
		cHtmlOk := HtmlTit(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
		fWrite(nArq,cHtmlOk,Len(cHtmlOK))
		cHtmlok := ""
		cHtml := ""			
		
	endif
	
	Qfunc := ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[2][1]))
	_v := _v + 1

	cTotalVRF := 0
	cTotalVVF := 0
	cTotalDRF := 0
	cTotalDVF := 0
	cTotalLiqF := 0

Return


STATIC FUNCTION RESUMO()  

 	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" TIPO,VERBA,DESCRI,SUM(JANEIRO) JANEIRO, SUM(FEVEREIRO) FEVEREIRO, SUM(MARCO) MARCO, SUM(ABRIL) ABRIL, "
 	cQuery += CRLF +" SUM(MAIO) MAIO, SUM(JUNHO) JUNHO , SUM(JULHO) JULHO, SUM(AGOSTO) AGOSTO, "
 	cQuery += CRLF +" SUM(SETEMBRO) SETEMBRO, SUM(OUTUBRO) OUTUBRO , SUM(NOVEMBRO) NOVEMBRO, SUM(DEZEMBRO) DEZEMBRO, "
 	cQuery += CRLF +" SUM(JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO) TOTAL "
 	cQuery += CRLF +" FROM ( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL, RD_MAT AS MATRICULA,RA_NOME AS NOME,RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCRI, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo01+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JANEIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo02+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS FEVEREIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo03+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MARCO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo04+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS ABRIL, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo05+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MAIO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo06+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JUNHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo07+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JULHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo08+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS AGOSTO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo09+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS SETEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo10+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS OUTUBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo11+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS NOVEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo12+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS DEZEMBRO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, "+ RETSQLNAME("SRA")+" B, "+ RETSQLNAME("SRV")+" C "
 	cQuery += CRLF +" WHERE RD_VALOR > 0 "
 	cQuery += CRLF +" AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND RD_PD = RV_COD "
 	cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT AND RD_CC = RA_CC "
 	cQuery += CRLF +" GROUP BY RD_FILIAL,RD_MAT,RA_NOME,RV_TIPOCOD,RD_PD,RV_DESC,LEFT(RD_DATPGT,6) "
 	cQuery += CRLF +" ) AS AGRUPADO "
 	cQuery += CRLF +" WHERE JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO > 0 "
 	cQuery += CRLF +" GROUP BY TIPO,VERBA,DESCRI "
 	cQuery += CRLF +" ORDER BY TIPO,VERBA,DESCRI "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE025"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	nContArq := 0	
	nCont := 0
	cHtmlOk := ""

	cHtmlOk := HtmlCabR(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtmlok := ""
	cHtml := ""	

	cHtmlOk := HtmlTitR(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	cHtmlok := ""
	cHtml := ""	
	cTotal := 0
	
	ProcRegua(nRegua)

	_V := 1
	
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

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // DESCR
		nTipo := Ascan(aTIPOS,Alltrim(ENF->TIPO))
		cValor := &("ENF->"+aStruFim[4][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JANEIRO
		cValor := &("ENF->"+aStruFim[5][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// FEVEREIRO		
		cValor := &("ENF->"+aStruFim[6][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MARCO
		cValor := &("ENF->"+aStruFim[7][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// ABRIL	
		cValor := &("ENF->"+aStruFim[8][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MAIO
		cValor := &("ENF->"+aStruFim[9][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JUNHO		
		cValor := &("ENF->"+aStruFim[10][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JULHO
		cValor := &("ENF->"+aStruFim[11][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// AGOSTO	
		cValor := &("ENF->"+aStruFim[12][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SETEMBRO
		cValor := &("ENF->"+aStruFim[13][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// OUTUBRO		
		cValor := &("ENF->"+aStruFim[14][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// NOVEMBRO
		cValor := &("ENF->"+aStruFim[15][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// DEZEMBRO	
		cValor := &("ENF->"+aStruFim[16][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// TOTAL					
		cHtml += CRLF+' </tr> ' 

	  	nContArq++  
	
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF

		_V := _V + 1
		
		ENF->(DBSKIP())  
	END 

    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
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

Return


STATIC FUNCTION HtmlCabR()

	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>Ficha Financeira - Resumo  </TITLE></HEAD>'
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

STATIC FUNCTION HtmlTitR()
	
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JANEIRO  	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FEVEREIRO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAR«O            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ABRIL            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAIO             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JUNHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JULHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGOSTO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SETEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>OUTUBRO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOVEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DEZEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T O T A L        </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapR()

	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotTipos[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	Atotger[1] := 0
	Atotger[2] := 0
	Atotger[3] := 0
 
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
	cHtml += CRLF +'Siga/GTGPE025'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '

Return(cHtml)


STATIC FUNCTION FILIAL()  

 	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL,TIPO,VERBA,DESCRI,SUM(JANEIRO) JANEIRO, SUM(FEVEREIRO) FEVEREIRO, SUM(MARCO) MARCO, SUM(ABRIL) ABRIL, "
 	cQuery += CRLF +" SUM(MAIO) MAIO, SUM(JUNHO) JUNHO , SUM(JULHO) JULHO, SUM(AGOSTO) AGOSTO, "
 	cQuery += CRLF +" SUM(SETEMBRO) SETEMBRO, SUM(OUTUBRO) OUTUBRO , SUM(NOVEMBRO) NOVEMBRO, SUM(DEZEMBRO) DEZEMBRO, "
 	cQuery += CRLF +" SUM(JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO) TOTAL "
 	cQuery += CRLF +" FROM ( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL, RD_MAT AS MATRICULA,RA_NOME AS NOME,RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCRI, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo01+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JANEIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo02+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS FEVEREIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo03+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MARCO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo04+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS ABRIL, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo05+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MAIO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo06+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JUNHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo07+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JULHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo08+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS AGOSTO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo09+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS SETEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo10+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS OUTUBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo11+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS NOVEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo12+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS DEZEMBRO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, "+ RETSQLNAME("SRA")+" B, "+ RETSQLNAME("SRV")+" C "
 	cQuery += CRLF +" WHERE RD_VALOR > 0 "
 	cQuery += CRLF +" AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND RD_PD = RV_COD "
 	cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT AND RD_CC = RA_CC "
 	cQuery += CRLF +" GROUP BY RD_FILIAL,RD_MAT,RA_NOME,RV_TIPOCOD,RD_PD,RV_DESC,LEFT(RD_DATPGT,6) "
 	cQuery += CRLF +" ) AS AGRUPADO "
 	cQuery += CRLF +" WHERE JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO > 0 "
 	cQuery += CRLF +" GROUP BY FILIAL,TIPO,VERBA,DESCRI "
 	cQuery += CRLF +" ORDER BY FILIAL,TIPO,VERBA,DESCRI "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE025"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	nContArq := 0	
	nCont := 0
	cHtmlOk := ""

	cHtmlOk := HtmlCabF(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtmlok := ""
	cHtml := ""	

	cHtmlOk := HtmlTitF(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	cHtmlok := ""
	cHtml := ""	
	cTotal := 0
	
	ProcRegua(nRegua)

	_V := 1
	Qfil := alltrim(ENF->FILIAL) 
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMADO DE TABELA - LINHA BANCA E LINHA AZUL.
		nCont ++

		IF qfil <> ALLTRIM(&("ENF->"+aStruFim[1][1]))
			QFILIAL()		
		ENDIF
  
		IF nCont%2 == 0
			cBgColor := "#FFFFFF"
		ELSE
			cBgColor := "#CAE4FF"
		ENDIF
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // DESCR
		nTipo := Ascan(aTIPOS,Alltrim(ENF->TIPO))
		cValor := &("ENF->"+aStruFim[5][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JANEIRO
		cValor := &("ENF->"+aStruFim[6][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// FEVEREIRO		
		cValor := &("ENF->"+aStruFim[7][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MARCO
		cValor := &("ENF->"+aStruFim[8][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// ABRIL	
		cValor := &("ENF->"+aStruFim[9][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MAIO
		cValor := &("ENF->"+aStruFim[10][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JUNHO		
		cValor := &("ENF->"+aStruFim[11][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JULHO
		cValor := &("ENF->"+aStruFim[12][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// AGOSTO	
		cValor := &("ENF->"+aStruFim[13][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SETEMBRO
		cValor := &("ENF->"+aStruFim[14][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// OUTUBRO		
		cValor := &("ENF->"+aStruFim[15][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// NOVEMBRO
		cValor := &("ENF->"+aStruFim[16][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// DEZEMBRO	
		cValor := &("ENF->"+aStruFim[17][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// TOTAL					
		cHtml += CRLF+' </tr> ' 

	  	nContArq++  
	
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF

		_V := _V + 1
		
		ENF->(DBSKIP())  
	END 

	QFILIAL()
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
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

Return


STATIC FUNCTION HtmlCabF()

	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>Ficha Financeira - Resumo por Filial  </TITLE></HEAD>'
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

STATIC FUNCTION HtmlTitF()
	
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JANEIRO  	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FEVEREIRO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAR«O            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ABRIL            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAIO             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JUNHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JULHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGOSTO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SETEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>OUTUBRO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOVEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DEZEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T O T A L        </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapF()

	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotger[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotger[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotger[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	Atotger[1] := 0
	Atotger[2] := 0
	Atotger[3] := 0
 
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
	cHtml += CRLF +'Siga/GTGPE025'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '

Return(cHtml)

Static Function QFILIAL()

		cHtml += CRLF +'<br><br><br>'
		cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
		cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
		cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS FILIAL </b></td> 
		cHtml += CRLF +' 	</TR> 
		 	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotTipos[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 

		Atotger[1] := Atotger[1] + aTotTipos[1]
		Atotger[2] := Atotger[2] + aTotTipos[2]
		Atotger[3] := Atotger[3] + aTotTipos[3]

		aTotTipos[1] := 0
		aTotTipos[2] := 0
		aTotTipos[3] := 0

		cHtml += CRLF +'</TABLE>	
		
		cHtml += CRLF +'<br><br>'
		cHtml += CRLF +'Siga/GTGPE025'+x_Codigo
		
		cHtmlOk := cHtml
		FWrite(nArq,cHtmlOk,Len(cHtmlOk))
		cHtml := ""		
				
		cHtmlOk := HtmlTitF(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
		fWrite(nArq,cHtmlOk,Len(cHtmlOK))
		cHtmlok := ""
		cHtml := ""			
		
	
	QFIL := ALLTRIM(&("ENF->"+aStruFim[1][1]))
	//_v := _v + 1

	cTotalVRF := 0
	cTotalVVF := 0
	cTotalDRF := 0
	cTotalDVF := 0
	cTotalLiqF := 0

Return

 
STATIC FUNCTION CCUSTO()  

 	cQuery := CRLF +" SELECT "
 	cQuery += CRLF +" FILIAL,CUSTO,TIPO,VERBA,DESCRI,SUM(JANEIRO) JANEIRO, SUM(FEVEREIRO) FEVEREIRO, SUM(MARCO) MARCO, SUM(ABRIL) ABRIL, "
 	cQuery += CRLF +" SUM(MAIO) MAIO, SUM(JUNHO) JUNHO , SUM(JULHO) JULHO, SUM(AGOSTO) AGOSTO, "
 	cQuery += CRLF +" SUM(SETEMBRO) SETEMBRO, SUM(OUTUBRO) OUTUBRO , SUM(NOVEMBRO) NOVEMBRO, SUM(DEZEMBRO) DEZEMBRO, "
 	cQuery += CRLF +" SUM(JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO) TOTAL "
 	cQuery += CRLF +" FROM ( "
 	cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL, RD_CC AS CUSTO, RD_MAT AS MATRICULA,RA_NOME AS NOME,RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCRI, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo01+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JANEIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo02+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS FEVEREIRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo03+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MARCO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo04+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS ABRIL, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo05+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS MAIO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo06+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JUNHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo07+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS JULHO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo08+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS AGOSTO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo09+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS SETEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo10+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS OUTUBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo11+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS NOVEMBRO, "
 	cQuery += CRLF +" (CASE WHEN LEFT(RD_DATPGT,6) = '"+cPeriodo12+"' "+" THEN SUM(RD_VALOR) ELSE 0 END) AS DEZEMBRO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, "+ RETSQLNAME("SRA")+" B, "+ RETSQLNAME("SRV")+" C "
 	cQuery += CRLF +" WHERE RD_VALOR > 0 "
 	cQuery += CRLF +" AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND RD_PD = RV_COD "
 	cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT AND RD_CC = RA_CC "
 	cQuery += CRLF +" GROUP BY RD_FILIAL,RD_CC,RD_MAT,RA_NOME,RV_TIPOCOD,RD_PD,RV_DESC,LEFT(RD_DATPGT,6) "
 	cQuery += CRLF +" ) AS AGRUPADO "
 	cQuery += CRLF +" WHERE JANEIRO+FEVEREIRO+MARCO+ABRIL+MAIO+JUNHO+JULHO+AGOSTO+SETEMBRO+OUTUBRO+NOVEMBRO+DEZEMBRO > 0 "
 	cQuery += CRLF +" GROUP BY FILIAL,CUSTO,TIPO,VERBA,DESCRI "
 	cQuery += CRLF +" ORDER BY FILIAL,CUSTO,TIPO,VERBA,DESCRI "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE025"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	nContArq := 0	
	nCont := 0
	cHtmlOk := ""

	cHtmlOk := HtmlCabC(cText,' ', MV_PAR01,' ', '', '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtmlok := ""
	cHtml := ""	

	cHtmlOk := HtmlTitC(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	cHtmlok := ""
	cHtml := ""	
	cTotal := 0
	
	ProcRegua(nRegua)

	_V := 1
	QCUSTO := alltrim(ENF->FILIAL)+alltrim(ENF->CUSTO) 
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMADO DE TABELA - LINHA BANCA E LINHA AZUL.
		nCont ++

		IF QCUSTO <> ALLTRIM(&("ENF->"+aStruFim[1][1]))+ALLTRIM(&("ENF->"+aStruFim[2][1]))
			QCCUSTO()		
		ENDIF
  
		IF nCont%2 == 0
			cBgColor := "#FFFFFF"
		ELSE
			cBgColor := "#CAE4FF"
		ENDIF
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // C.CUSTO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // DESCR
		nTipo := Ascan(aTIPOS,Alltrim(ENF->TIPO))
		cValor := &("ENF->"+aStruFim[6][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JANEIRO
		cValor := &("ENF->"+aStruFim[7][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// FEVEREIRO		
		cValor := &("ENF->"+aStruFim[8][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MARCO
		cValor := &("ENF->"+aStruFim[9][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// ABRIL	
		cValor := &("ENF->"+aStruFim[10][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// MAIO
		cValor := &("ENF->"+aStruFim[11][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JUNHO		
		cValor := &("ENF->"+aStruFim[12][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// JULHO
		cValor := &("ENF->"+aStruFim[13][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// AGOSTO	
		cValor := &("ENF->"+aStruFim[14][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// SETEMBRO
		cValor := &("ENF->"+aStruFim[15][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// OUTUBRO		
		cValor := &("ENF->"+aStruFim[16][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// NOVEMBRO
		cValor := &("ENF->"+aStruFim[17][1])		
		IF nTipo > 0 .AND. nTipo < 5
			aTotTipos[nTipo] += cValor 
        ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// DEZEMBRO	
		cValor := &("ENF->"+aStruFim[18][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// TOTAL					
		cHtml += CRLF+' </tr> ' 

	  	nContArq++  
	
		//======================================================+
		// UTILIZADO PARA NAO ULTRAPASSAR O TAMANHO DA VARIAVEL +
		//======================================================+
		IF nContArq >= 500
			
			cHtmlOk := cHtml
			FWrite(nArq,cHtmlOk,Len(cHtmlOk))
			cHtml := ' '
			nContArq := 0
			
		ENDIF

		_V := _V + 1
		
		ENF->(DBSKIP())  
	END 

	QCCUSTO()
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
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

Return


STATIC FUNCTION HtmlCabC()

	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>Ficha Financeira - Resumo por C.Custo  </TITLE></HEAD>'
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

STATIC FUNCTION HtmlTitC()
	
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JANEIRO  	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FEVEREIRO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAR«O            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ABRIL            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MAIO             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JUNHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>JULHO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGOSTO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SETEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>OUTUBRO		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOVEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DEZEMBRO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>T O T A L        </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapC()

	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotger[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotger[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotger[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	Atotger[1] := 0
	Atotger[2] := 0
	Atotger[3] := 0
 
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
	cHtml += CRLF +'Siga/GTGPE025'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '

Return(cHtml)

Static Function QCCUSTO()

	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS C.CUSTO </b></td> 
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[1],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(aTotTipos[2],"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Bases :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((aTotTipos[3]),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	Atotger[1] := Atotger[1] + aTotTipos[1]
	Atotger[2] := Atotger[2] + aTotTipos[2]
	Atotger[3] := Atotger[3] + aTotTipos[3]

	aTotTipos[1] := 0
	aTotTipos[2] := 0
	aTotTipos[3] := 0

	cHtml += CRLF +'</TABLE>	
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE025'+x_Codigo
	
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ""		
			
	cHtmlOk := HtmlTitC(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	cHtmlok := ""
	cHtml := ""			

	QCUSTO := ALLTRIM(&("ENF->"+aStruFim[1][1]))+ALLTRIM(&("ENF->"+aStruFim[2][1]))

	cTotalVRF := 0
	cTotalVVF := 0
	cTotalDRF := 0
	cTotalDVF := 0
	cTotalLiqF := 0

Return



