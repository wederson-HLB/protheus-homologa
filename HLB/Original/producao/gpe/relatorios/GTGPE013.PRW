#include "PROTHEUS.CH"


/*
‹‹‹‹‹
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 29/08/2016  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelaÁ„o de Afastamentos / Admissıes e Demissıes            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE013()   


Private cPerg     := "GTGPE013  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotal := 0

private cTES := {}

	private cNOMECOM := space(40)
	private cCGC     := space(20)
	private cCNPJ    := space(20)
	private cCodigo  := space(2)

	cNOMECOM := SM0->M0_NOMECOM
	cCGC     := SM0->M0_CGC
	cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
	cCodigo  := SM0->M0_CODIGO

CriaSX1(cPerg)

SET DECIMALS TO 2

	If Pergunte(cPerg,.T.)
		If SimNao("Gera RelatÛrio?") == "S"
			Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
		Else
			Return
		EndIf
	Else
		Return
	EndIf

RETURN


//////------------------------------------------------------
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
		If File(cPath+"RELAFAST"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	IF MV_PAR03 == 1
		demiss()  // Demitidos
		RETURN 
	ELSEIF 	MV_PAR03 == 2
		admiss()  // Admitidos
		RETURN 	
	ELSEIF 	MV_PAR03 == 4
		utransf()  // Transferidos
		RETURN 	

	ENDIF

//////-------------- afastamentos

	cText  := "RELA«√O DE AFASTAMENTOS DE FUNCION¡RIOS NO PERÕODO   - De: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	cText  += "  Ate: " + substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)

	cQuery := CRLF +" SELECT  "
 	cQuery += CRLF +" R8_FILIAL,R8_MAT, RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_SITFOLH,R8_DATA,R8_TIPO,R8_SEQ,X5_DESCRI,R8_DATAINI,R8_DATAFIM,R8_DURACAO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SR8")+" A,"+ RETSQLNAME("SRA")+" B," + RETSQLNAME("SX5")+" C " 
 	cQuery += CRLF +" WHERE "
 	cQuery += CRLF +" A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT "
 	cQuery += CRLF +" AND X5_TABELA = '30' AND X5_CHAVE = R8_TIPO "
 	cQuery += CRLF +" AND R8_DATAINI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' " 	
 	cQuery += CRLF +" ORDER BY R8_FILIAL,R8_MAT,R8_TIPO,R8_SEQ "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"RELAFAST"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCab(cText,'De: ', MV_PAR01,' Ate: ', MV_PAR02, '') // cabeÁalho do relatorio "HLB"
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTit(aStruFim)	//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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
	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  	// FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  	// MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  	// NOME 
        cData :=&("ENF->"+aStruFim[4][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA ADMISSAO
        cData :=&("ENF->"+aStruFim[5][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA DEMISSAO				
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'    	// SIT. FOLHA		
        cData :=&("ENF->"+aStruFim[7][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA ALTERA«√O	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  	// TIPO AFAST
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[10][1]))+'&nbsp</td>'  	// DESCRICAO AFAST
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  	// SEQ. AFAST				
        cData :=&("ENF->"+aStruFim[11][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA INICIO
        cData :=&("ENF->"+aStruFim[12][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA FIM
		cValor := &("ENF->"+aStruFim[13][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 9999")+'&nbsp</TD>'		  	// DURA«√O		

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
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE AFASTAMENTOS DE FUNCION¡RIOS </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cCodigo+' - '+cNOMECOM+'</B></TD>'	
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
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA 		</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME        		</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>ADMISS√O		   	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DEMISS√O 	   		</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SITUA«√O	   		</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ALTERA«√O   	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TIPO AFAST	   	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O     	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SEQUENCIA      	</B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA INICIO AFAST	</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA FIM AFAST    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DURA«√O AFAST     </B></TD>'
	
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
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/RELAFAST'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥19/02/2013   ∫±±
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
	
	Aadd(aRegs,{cPerg,'01','Data de        ','','','MV_CH1','D',8,0,0,'G',' ','MV_PAR01','   ','','','   ','','   ','','','','','','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','Data AtÅE      ','','','MV_CH2','D',8,0,0,'G',' ','MV_PAR02','   ','','','   ','','   ','','','','','','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'03','D=Demiss/A=Adm/F=Afast/T=Trans ','','','MV_CH3','N',1,0,1,'C',' ','MV_PAR03','Dem','','','','','Adm','','','','','aFast','','','','','Trans','','','','','','','','','   ','F','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return

//////////----------------------------- admitidos
Static Function admiss()

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
		If File(cPath+"RELADM"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cText  := "RELA«√O DE ADMISS’ES NO PERÕODO   - De: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	cText  += "  Ate: " + substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)

	cQuery := CRLF +" SELECT  "  
 	cQuery += CRLF +" RA_FILIAL,"
 	cQuery += CRLF +" RA_MAT,RA_CC,CTT_DESC01,RA_NOME,RA_ADMISSA,RA_DEMISSA, "
 	cQuery += CRLF +" RA_CODFUNC,RJ_DESC,RA_SALARIO,RA_CIC "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRA")+" A,"+ RETSQLNAME("CTT")+" B," + RETSQLNAME("SRJ")+" C " 
 	cQuery += CRLF +" WHERE RA_ADMISSA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' "
 	cQuery += CRLF +" AND RA_CC = CTT_CUSTO AND RA_CODFUNC = RJ_FUNCAO AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" ORDER BY RA_FILIAL,RA_NOME"

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"RELADM"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCabR(cText,'De: ', MV_PAR01,' Ate: ', MV_PAR02, '') // cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitR(aStruFim)	//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // COD. CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // DESCRICAO CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // NOME
        cData :=&("ENF->"+aStruFim[6][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA ADMISSAO
        cData :=&("ENF->"+aStruFim[7][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA DEMISSAO		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // COD. FUNCAO	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // DESCR. FUNCAO			
		cValor := &("ENF->"+aStruFim[10][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'// SALARIO
		cTotal := cTotal + cValor		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[11][1]))+'&nbsp</td>'  // CPF
			  	
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
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE ADMISS’ES </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cCodigo+' - '+cNOMECOM+'</B></TD>'	
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
STATIC FUNCTION HtmlTitR()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CODIGO CC		   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O CC	   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME  	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O	   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA DEMISS√O    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CODIGO FUN«√O    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O FUN«√O </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SAL¡RIO          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C P F            </B></TD>'
		
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
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total do Periodo:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotal,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/RELADM'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)




///////-------------------- demitidos
Static Function demiss()     // DEMITIDOS

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
		If File(cPath+"RELDEM"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cText  := "RELA«√O DE DEMISS’ES NO PERÕODO   - De: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	cText  += "  Ate: " + substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)

	cQuery := CRLF +" SELECT  "  
 	cQuery += CRLF +" RA_FILIAL,"
 	cQuery += CRLF +" RA_MAT,RA_CC,CTT_DESC01,RA_NOME,RA_ADMISSA,RA_DEMISSA, RG_DATAHOM, "
 	cQuery += CRLF +" RA_CODFUNC,RJ_DESC,RA_SALARIO,RA_CIC,RG_TIPORES,LEFT(RX_TXT,30) AS DESCRIC, "
 	cQuery += CRLF +" CASE "
 	cQuery += CRLF +" WHEN RG_RESCDIS = '0' THEN 'NORMAL' "
 	cQuery += CRLF +" WHEN RG_RESCDIS = '1' THEN 'COMPLEMENTAR' "
 	cQuery += CRLF +" WHEN RG_RESCDIS = '2' THEN 'POR DISSIDIO' "
 	cQuery += CRLF +" ELSE ' ' END " 
 	cQuery += CRLF +" AS TIPO, "
 	cQuery += CRLF +" RG_TPAVISO,RG_DAVISO,RG_DTAVISO "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRA")+" A,"+ RETSQLNAME("CTT")+" B," + RETSQLNAME("SRJ")+" C, " + RETSQLNAME("SRG")+" D, "
	cQuery += CRLF +" " + RETSQLNAME("SRX")+" E  "
 	cQuery += CRLF +" WHERE RA_SITFOLH = 'D' "
 	cQuery += CRLF +" AND RA_DEMISSA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02) +"' "
 	cQuery += CRLF +" AND RA_CC = CTT_CUSTO AND RA_CODFUNC = RJ_FUNCAO "
 	cQuery += CRLF +" AND A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' ' AND E.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF +" AND RA_FILIAL = RG_FILIAL AND RA_MAT = RG_MAT "
 	cQuery += CRLF +" AND RG_TIPORES = LEFT(RX_COD,2) AND RX_TIP = '32' AND SUBSTRING(RX_COD,3,1) = '1' " 	
 	cQuery += CRLF +" ORDER BY RA_FILIAL,RA_NOME"

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"RELDEM"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	

	
	cHtmlOk := HtmlCabA(cText,'De: ', MV_PAR01,' Ate: ', MV_PAR02, '') // cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitA(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // COD. CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // DESCRICAO CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // NOME
        cData :=&("ENF->"+aStruFim[6][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA ADMISSAO
        cData :=&("ENF->"+aStruFim[7][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA DEMISSAO		
        cData :=&("ENF->"+aStruFim[8][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA HOMOLOGA«√O	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // COD. FUNCAO	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[10][1]))+'&nbsp</td>'  // DESCR. FUNCAO			
		cValor := &("ENF->"+aStruFim[11][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'// SALARIO
		cTotal := cTotal + cValor		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[12][1]))+'&nbsp</td>'  // CPF
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[13][1]))+'&nbsp</td>'  // TIPO RESC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[14][1]))+'&nbsp</td>'  // DESCR.TP RESC		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[15][1]))+'&nbsp</td>'  // TIPO	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[16][1]))+'&nbsp</td>'  // TIPO AVISO
		cValor := &("ENF->"+aStruFim[17][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.99")+'&nbsp</TD>'// DIAS DE AVISO
        cData :=&("ENF->"+aStruFim[18][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA AVISO					  	
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
	
	cHtmlOk := HtmlRodapA()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabA()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE DEMISS’ES </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cCodigo+' - '+cNOMECOM+'</B></TD>'	
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
STATIC FUNCTION HtmlTitA()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL               </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CODIGO CC		       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O CC	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME  	           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISS√O	       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA DEMISS√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA HOMOLOGA«√O     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CODIGO FUN«√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O FUN«√O     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SAL¡RIO              </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C P F                </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TIPO RESCIS√O        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRIC√O TP RESC.   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>  T I P O            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TIPO AVISO PREV      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS DE AVISO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA AVISO           </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'
Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapA()

	
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
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total do Periodo:&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotal,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/RELDEM'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)


///////-------------------- transferencias
Static Function UTRANSF()     // transferencias

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
		If File(cPath+"RELTRA"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cText  := "RELA«√O DE TRANSFERENCIAS NO PERÕODO   - De: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	cText  += "  Ate: " + substr(DTOS(MV_PAR02),7,2)+"/"+substr(DTOS(MV_PAR02),5,2)+"/"+substr(DTOS(MV_PAR02),1,4)

	cQuery := CRLF +" SELECT  "  
 	cQuery += CRLF +" RE_DATA,RE_EMPP,RE_EMPD,RE_FILIALP,RE_FILIALD,RE_CCP,CTT_DESC01,RE_CCD,RE_MATP,RE_MATD,RA_NOME,RA_CIC "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRE")+" A,"+ RETSQLNAME("SRA")+" B," + RETSQLNAME("CTT")+" C " 
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
	cQuery += CRLF +" AND  RE_FILIALP = RA_FILIAL AND RE_MATP = RA_MAT AND RE_CCP = RA_CC "
	cQuery += CRLF +" AND RE_CCP = CTT_CUSTO "
	cQuery += CRLF +" ORDER BY RE_DATA,RE_EMPP,RE_FILIALP,RE_CCP,RE_MATP "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"RELTRA"+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	

	
	cHtmlOk := HtmlCabT(cText,'De: ', MV_PAR01,' Ate: ', MV_PAR02, '') // cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitT(aStruFim)//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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


        cData :=&("ENF->"+aStruFim[1][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  // DATA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // EMPRESA DESTINO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // EMPRESA ORIGEM
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // FILIAL DESTINO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // FILIAL ORIGEM
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // C.CUSTO DESTINO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // DESCR.C.CUSTO DESTINO		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // C.CUSTO ORIGEM
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'  // MATRICULA DESTINO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[10][1]))+'&nbsp</td>'  // MATRICULA ORIGEM
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[11][1]))+'&nbsp</td>'  // NOME FUNCIONARIO		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[12][1]))+'&nbsp</td>'  // CPF
					  	
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
	
	cHtmlOk := HtmlRodapT()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabT()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RELA«√O DE TRANSFER NCIAS </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cCodigo+' - '+cNOMECOM+'</B></TD>'	
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
STATIC FUNCTION HtmlTitT()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA                      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>EMPRESA DESTINO           </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>EMPRESA ORIGEM		    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL DESTINO	        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL ORIGEM  	        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO DESTINO	        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR.C.CUSTO DESTINO     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO ORIGEM            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA DESTINO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA ORIGEM          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME FUNCIONARIO          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C P F                     </B></TD>'
		
	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'
Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapT()

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
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/RELTRA'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)



