#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ()บAutor   ณ Francisco F S Neto        บ Data ณ 15/02/2017  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de desconto de Seguro de Vida.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes HLB BRASIL                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION GTGPE026()   

Private cPerg     := "GTGPE026  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotalE := 0
private cTotalF := 0
private _TotCap := 0
private _TotPre := 0

private cNe := 0
private cPeriodo := ""

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
private _cFilial := SM0->M0_CODFIL
PRIVATE _cPerfin := ""

Private cPeriodo  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
  
Private cMesAno := ""

// monta periodo 5 final 
If subs(cPeriodo,1,2) $ "04/06/09/11"
	_cPerfin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"30"
Elseif subs(cPeriodo,1,2) $ "01/03/05/07/08/10/12"
	_cPerfin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"31"
Elseif subs(cPeriodo,1,2) $ "02"
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
		_cPerfin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"29"
	Else
		_cPerfin := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"28"
	Endif
Endif

CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("Relat๓rio de Seguro de Vida? ") == "S"
		Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabe็alho, aguarde...")}, OemToAnsi("Aguarde..."))
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

	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE026"+cOrdm+".xls")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cMesAno := subs(DTOS(MV_PAR01),5,2)+"/"+subs(DTOS(MV_PAR01),1,4)   

	cText  := "Listagem de Seguro de Vida - De: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	cText  += "  Ate: " + substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)	

	cQuery := CRLF +" SELECT "

	If cPeriodo == cMesAno

		cQuery += CRLF +"RC_FILIAL AS FILIAL,RC_MAT AS MATRICULA,RA_CIC AS CPF,RA_NOME AS NOME,RA_NASC AS NASCIMENTO, " 
		cQuery += CRLF +"RA_ADMISSA AS ADMISSAO,RA_SALARIO AS SALARIO, "
		cQuery += CRLF +"(CASE WHEN (RA_SALARIO * "+strzero(MV_PAR06)+") <= "+strzero(MV_PAR05)+" THEN (RA_SALARIO * "+strzero(MV_PAR06)+") ELSE "+strzero(MV_PAR05)+" END) AS CAPITAL, " 
		cQuery += CRLF +"(CASE WHEN (RA_SALARIO * "+strzero(MV_PAR06)+") <= "+strzero(MV_PAR05)+" THEN (RC_VALOR / (RA_SALARIO * "+strzero(MV_PAR06)+")*100) ELSE (RC_VALOR /"+strzero(MV_PAR05)+" * 100) END) AS PERCENTUAL, "
		cQuery += CRLF +"RC_VALOR AS PREMIO "
		cQuery += CRLF +"FROM " + RETSQLNAME("SRC")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("SRV")+" C " 
		cQuery += CRLF +"WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +"AND RC_FILIAL = RA_FILIAL AND RC_MAT = RA_MAT "
		cQuery += CRLF +"AND RC_PD = RV_COD "
		cQuery += CRLF +"AND RV_CODFOL IN('0153') "
	 	cQuery += CRLF +" AND RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' " 	
	 	cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " 
		cQuery += CRLF +"ORDER BY RC_FILIAL,RC_MAT "

	Else
	
		cQuery += CRLF +"RD_FILIAL AS FILIAL,RD_MAT AS MATRICULA,RA_CIC AS CPF,RA_NOME AS NOME,RA_NASC AS NASCIMENTO, " 
		cQuery += CRLF +"RA_ADMISSA AS ADMISSAO,RA_SALARIO AS SALARIO, "
		cQuery += CRLF +"(CASE WHEN (RA_SALARIO * "+strzero(MV_PAR06)+") <= "+strzero(MV_PAR05)+" THEN (RA_SALARIO * "+strzero(MV_PAR06)+") ELSE "+strzero(MV_PAR05)+" END) AS CAPITAL, " 
		cQuery += CRLF +"(CASE WHEN (RA_SALARIO * "+strzero(MV_PAR06)+") <= "+strzero(MV_PAR05)+" THEN (RD_VALOR / (RA_SALARIO * "+strzero(MV_PAR06)+")*100) ELSE (RD_VALOR /"+strzero(MV_PAR05)+" * 100) END) AS PERCENTUAL, "
		cQuery += CRLF +"RD_VALOR AS PREMIO "
		cQuery += CRLF +"FROM " + RETSQLNAME("SRD")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("SRV")+" C " 
		cQuery += CRLF +"WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +"AND RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT "
		cQuery += CRLF +"AND RD_PD = RV_COD "
		cQuery += CRLF +"AND RV_CODFOL IN('0153') "
	 	cQuery += CRLF +" AND RD_DATPGT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' " 	
	 	cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " 
		cQuery += CRLF +"ORDER BY RD_FILIAL,RD_MAT "
	
	Endif	

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE026"+cOrdm+".xls"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+


	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCab(cText,'MสS: ', MV_PAR02,' / ANO:  ', MV_PAR01, '') 
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

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  	 // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  	 // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  	 // CPF
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  	 // NOME						
        cData :=&("ENF->"+aStruFim[5][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 	   		 // DATA NASCIMENTO
        cData :=&("ENF->"+aStruFim[6][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 			 // DATA ADMISSAO
		cValor := &("ENF->"+aStruFim[7][1])												
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // SALARIO
		cValor := &("ENF->"+aStruFim[8][1])
		_TotCap := _TotCap + cValor												
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // CAPITAL
		cValor := &("ENF->"+aStruFim[9][1])												
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 99.999999")+'&nbsp</TD>'  		 // PERCENTUAL
		cValor := &("ENF->"+aStruFim[10][1])
		_TotPre := _TotPre + cValor															
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // PREMIO

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
		
		ENF->(DBSKIP())  
	END 
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlRodap()   // chama o rodapEdo relatorio
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
//FUNCAO PARA GERAR CABEวALHO DO HTML      +
//=========================================+
STATIC FUNCTION HtmlCab()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>Relat๓rio de Seguro de Vida </TITLE></HEAD>'
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

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL             </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B> C P F             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>N O M E            </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA NASCIMENTO    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISSรO      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CAPITAL SEGURADO   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERCENTUAL         </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR PREMIO       </B></TD>'

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
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emissใo</b></td> 
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 

    //// RESUMO DE TOTAIS
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Capital :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(_TotCap,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Premios :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(_TotPre,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
/*
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 	</TR> 
*/
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usuแrio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE026'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSX1   บAutor  ณFrancisco F S Neto  บ Data ณ15/02/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere novas perguntas ao sx1                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaSX1(cPerg)

	Local aRegs := {}
// GRUPO/ORDEM/PERGUNT/PERSPA/PERENG/VARIAV/TIPO/TAM/DEC/PRESEL/GSC/VALID/VAR01/DEF01/DEFSPA1/DEFENG1/CNT01/VAR02/DEF02/DEFSPA2/DEFENG2/CNT02/VAR03/DEF03/DEFSPA3/DEFENG3/CNT03/VAR04/DEF04/DEFSPA4/DEFENG4/CNT04/VAR05/DEF05/DEFSPA5/DEFENG5/CNT05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
	
	Aadd(aRegs,{cPerg,'01','Data de        ','','','MV_CH1','D',08,0,0,'G',' ','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'02','Data AtE      ','','','MV_CH2','D',08,0,0,'G',' ','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial         ','','','MV_CH3','C',02,0,0,'G',' ','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'04','Filial AtE    ','','','MV_CH4','C',02,0,0,'G',' ','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'05','Limite Capital ','','','MV_CH5','N',14,2,0,'G',' ','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	Aadd(aRegs,{cPerg,'06','Qtde Salแrios  ','','','MV_CH6','N',04,0,0,'G',' ','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return

