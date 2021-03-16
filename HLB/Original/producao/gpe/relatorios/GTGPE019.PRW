#include "PROTHEUS.CH"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 18/01/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelatÛrio de Beneficios para a Uber                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Clientes HLB BRASIL                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE019()   

Private cPerg     := "GTGPE019  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotalE := 0
private cTotalF := 0
private cNe := 0
private cPeriodo := ""


private x_Codigo := ""
private x_CodFi := ""
private cNOMECOM := ""

private	_cFilial := ""
private	_cMat 	 := ""
private	_cValor  := 0
private _cCusto  := ""


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
	//private _cFilial := SM0->M0_CODFIL

	private datadois := ""  //ctod("  /  /  ")
	private datamov  := ctod("  /  /  ")
	
CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("Gera RelatÛrio de Benef˙Äios? ") == "S"
		Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
	Else
		Return
	EndIf
Else
	Return
EndIf

RETURN



STATIC FUNCTION geracom()
	
	private cQuery := ' '
	private lLoop  := .T.

	private nArq   := Nil

	private nCont  := 01
	private cHtml  := ' '
	private nRegua := 0
	private nContArq := 0
	private X := 0

	private cPath  := AllTrim(GetTempPath())
	private cOrdm  := "01"

	cTotalE := 0
	cTotalS := 0

	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE019"+cOrdm+".xls")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	cText  := "Listagem de Benef˙Äios - De: " + STRZERO(VAL(MV_PAR02),2)+"/"+STRZERO(VAL(MV_PAR01),4)
	
	mesano := STRZERO(VAL(MV_PAR01),4)+STRZERO(VAL(MV_PAR02),2)  

	IF MV_PAR08 == 1
		cText  := "Resumo de Benef˙Äios - De: " + STRZERO(VAL(MV_PAR02),2)+"/"+STRZERO(VAL(MV_PAR01),4)
		RESUMO()  
		if MV_PAR09 == 1
			If SimNao("Executa IntegraÁ„o com a Folha(Verbas: 266 e 706)? ") == "S"
				Processa({ |lEnd| INTFOL(@lEnd),OemToAnsi("Integrando com a Folha, aguarde...")}, OemToAnsi("Aguarde..."))
			EndIf
	  	endif
		RETURN
	ENDIF


	cQuery := CRLF +" SELECT "
	cQuery += CRLF +" RG2_FILIAL,RG2_MAT,RA_ADMISSA,RA_NOME,RA_CIC,SUBSTRING(RA_BCDEPSA,1,3) AS BANCO,SUBSTRING(RA_BCDEPSA,4,5) AS AGENCIA,RA_CTDEPSA AS CONTA, "
	cQuery += CRLF +" RG2_PERIOD,RG2_DIAPRO,RG2_VTDUTE,RG2_VTDNUT,RG2_DUTILM,RG2_DIACAL,RG2_VALCAL,RG2_CUSUNI,RG2_CUSFUN,RG2_CUSEMP, "
	cQuery += CRLF +" RG2_SALBSE,RG2_CC,RG2_TPBEN,SUBSTRING(RCC_CONTEU,3,25) AS DESCRIC,RG2_PERC "
	cQuery += CRLF +" FROM "+ RETSQLNAME("RG2")+ " A, "	+ RETSQLNAME("SRA")+ " B, "+ RETSQLNAME("RCC")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
	cQuery += CRLF +" AND LEFT(RG2_PERIOD,6)  = '"+mesano+"'  "
 	cQuery += CRLF +" AND RG2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"' " 
 	cQuery += CRLF +" AND RG2_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06 +"' " 
 	cQuery += CRLF +" AND RA_ADMISSA BETWEEN '"+DTOS(MV_PAR10)+"' AND '"+DTOS(MV_PAR11) +"' " 
	cQuery += CRLF +" AND RG2_TPBEN = '"+MV_PAR07+"'  "
	cQuery += CRLF +" AND RG2_FILIAL = RA_FILIAL AND RG2_MAT = RA_MAT "
	cQuery += CRLF +" AND RCC_CODIGO = 'S011' AND SUBSTRING(RCC_CONTEU,1,2) = RG2_TPBEN "
	cQuery += CRLF +" ORDER BY RG2_FILIAL,RG2_MAT,RG2_PERIOD "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE019"+cOrdm+".xls"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCab(cText,'M S: ', MV_PAR02,' / ANO:  ', MV_PAR01, '') 
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

		cPeriodo := substr(ENF->RG2_PERIOD,5,2)+"/"+substr(ENF->RG2_PERIOD,1,4)
		
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // MATRICULA
        cData :=&("ENF->"+aStruFim[3][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA ADMISSAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // NOME									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // CIC									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // BANCO									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // AGENCIA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // CONTA		
		cHtml += CRLF +'<TD align="left">'+cPeriodo+'&nbsp</td>'  // PERIODO
		cValor := &("ENF->"+aStruFim[11][1])
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999")+'&nbsp</TD>'// QTDE VT DIAS UTEIS
		cValor := &("ENF->"+aStruFim[13][1])			
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999")+'&nbsp</TD>'  // DIAS UTEIS NO MES
		cValor := &("ENF->"+aStruFim[15][1])												
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // VR T0TAL CALCULADO
		cValor := &("ENF->"+aStruFim[16][1])			
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // CUSTO UNITARIO
		cValor := &("ENF->"+aStruFim[17][1])
		cTotalF := cTotalF + cValor												
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // CUSTO DO FUNCIONARIO
		cValor := &("ENF->"+aStruFim[18][1])												
		cTotalE := cTotalE + cValor	
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // CUSTO EMPRESA
		cValor := &("ENF->"+aStruFim[19][1])			 
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // SALARIO BASE
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[20][1]))+'&nbsp</td>'  // CENTRO DE CUSTO		
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[21][1]))+'&nbsp</td>'  // TIPO DO BENEFICIO									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[22][1]))+'&nbsp</td>'  // DESCRI«√O BENEF.
		cValor := &("ENF->"+aStruFim[23][1])
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.99")+'&nbsp</TD>'   // PERCENTUAL BENEF. 									

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
	cHtml += CRLF +'<HEAD><TITLE>Listagem de Benef˙Äios </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	//cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+' - '+_cFilial+'</B></TD>'	
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+cNOMECOM+' - '+cCodigo+'</B></TD>'	

	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'
	
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

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                 </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA              </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DT ADMISS√O            </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.P.F.                 </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BANCO                  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGENCIA                </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CONTA CORR             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERIODO                </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>QTDE VT DIAS UTEIS     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS UTEIS NO MES      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VR T0TAL CALCULADO     </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CUSTO UNITARIO         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CUSTO DO FUNCIONARIO   </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CUSTO EMPRESA          </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SALARIO BASE           </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CENTRO DE CUSTO        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>TIPO DO BENEFICIO      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCRI«√O BENEF.       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERCENTUAL BENEF.      </B></TD>'
	
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
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Beneficio :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Beneficio (Empresa):&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalE,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">&nbsp;</td> 
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE019DET'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥18/01/2017   ∫±±
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
	
	Aadd(aRegs,{cPerg,'01','Ano  (AAAA)          ','','','MV_CH1','C',04,0,0,'G','','MV_PAR01','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','MÍs: (MM)            ','','','MV_CH2','C',02,0,0,'G','','MV_PAR02','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial               ','','','MV_CH3','C',02,0,0,'G','','MV_PAR03','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})
	Aadd(aRegs,{cPerg,'04','Filial AtÅE          ','','','MV_CH4','C',02,0,0,'G','','MV_PAR04','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})
	Aadd(aRegs,{cPerg,'05','Matricula de         ','','','MV_CH5','C',06,0,0,'G','','MV_PAR05','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','SRA' ,' ','','','',''})
	Aadd(aRegs,{cPerg,'06','Matricula AtÅE       ','','','MV_CH6','C',06,0,0,'G','','MV_PAR06','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','SRA' ,' ','','','',''})
	Aadd(aRegs,{cPerg,'07','Tipo de Beneficio    ','','','MV_CH7','C',02,0,0,'G','','MV_PAR07','      ','','','01','','       ','','','','','','','','','','','','','','','','','','','S011',' ','','','',''})
	Aadd(aRegs,{cPerg,'08','R=Resumo/D=Detalhe:  ','','','MV_CH8','N',01,0,1,'C','','MV_PAR08','Resumo','','','  ','','Detalhe','','','','','','','','','','','','','','','','','','','    ','R','','','',''})
	Aadd(aRegs,{cPerg,'09','Integra com a Folha? ','','','MV_CH9','N',01,0,1,'C','','MV_PAR09','Sim'   ,'','','  ','','N„o'    ,'','','','','','','','','','','','','','','','','','','    ','S','','','',''})
	Aadd(aRegs,{cPerg,'10','Data Admiss„o de :   ','','','MV_CHA','D',08,0,0,'G','','MV_PAR10','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})
	Aadd(aRegs,{cPerg,'11','Data Admiss„o AtÅE:  ','','','MV_CHB','D',08,0,0,'G','','MV_PAR11','      ','','','  ','','       ','','','','','','','','','','','','','','','','','','','    ',' ','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return


STATIC FUNCTION RESUMO()
///------------  AGRUPADO POR VERBA (TOTAL GERAL)  

	cQuery := CRLF +" SELECT "
	cQuery += CRLF +" FILIAL,MAT,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO,SUM(TOTAL) AS TOTAL "
	cQuery += CRLF +" FROM( "
	cQuery += CRLF +" SELECT RG2_FILIAL AS FILIAL,RG2_MAT AS MAT,RA_NOME AS NOME,RA_CIC AS CPF,RA_ADMISSA AS ADMISSAO,SUBSTRING(RA_BCDEPSA,1,3) AS BANCO,SUBSTRING(RA_BCDEPSA,4,5) AS AGENCIA,"
	cQuery += CRLF +" RA_CTDEPSA AS CONTA, RG2_PERIOD AS PERIODO,RG2_VALCAL AS TOTAL "
	cQuery += CRLF +" FROM "+ RETSQLNAME("RG2")+ " A, "	+ RETSQLNAME("SRA")+ " B, "+ RETSQLNAME("RCC")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' '  "
	cQuery += CRLF +" AND LEFT(RG2_PERIOD,6)  = '"+mesano+"'  "
 	cQuery += CRLF +" AND RG2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"' " 
 	cQuery += CRLF +" AND RG2_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06 +"' " 
 	cQuery += CRLF +" AND RA_ADMISSA BETWEEN '"+DTOS(MV_PAR10)+"' AND '"+DTOS(MV_PAR11) +"' " 
	cQuery += CRLF +" AND RG2_TPBEN = '"+MV_PAR07+"'  "
	cQuery += CRLF +" AND RG2_FILIAL = RA_FILIAL AND RG2_MAT = RA_MAT "
	cQuery += CRLF +" AND RCC_CODIGO = 'S011' AND SUBSTRING(RCC_CONTEU,1,2) = RG2_TPBEN ) "
	cQuery += CRLF +" AS AGRUPADO "
	cQuery += CRLF +" GROUP BY FILIAL,MAT,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO "
	cQuery += CRLF +" ORDER BY FILIAL,MAT,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE019"+x_Codigo+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+                
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	
	cHtmlOk := HtmlCabR(cText,'M S: ', MV_PAR02,' / ANO:  ', MV_PAR01, '') 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitR(aStruFim)  //CAMPOS DO RELATORIO QUE ESTAO NA QUERY
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

		cPeriodo := substr(ENF->PERIODO,5,2)+"/"+substr(ENF->PERIODO,1,4)
		
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'  // FILIAL
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // NOME									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // CIC									
        cData :=&("ENF->"+aStruFim[5][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		  	// DATA ADMISSAO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // BANCO									
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[7][1]))+'&nbsp</td>'  // AGENCIA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'  // CONTA		
		cValor := &("ENF->"+aStruFim[10][1])												
		cTotalF := cTotalF + cValor		
   		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999999999999.99")+'&nbsp</TD>'  // VR T0TAL CALCULADO
 
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
	
RETURN


//=========================================+
//FUNCAO PARA GERAR CABE«ALHO DO HTML      +
//=========================================+
STATIC FUNCTION HtmlCabR()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Folha Pagamento Resumo </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+x_Codigo+' '+x_CodFi+' '+cNOMECOM+'</B></TD>'			
	cHtml += CRLF +'	</TR>'
	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16" align="center" valign="middle">CNPJ:   '+cCNPJ+'</TD>'	
	
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

	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL                 </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA              </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME                   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.P.F.                 </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DT ADMISS√O            </B></TD>'	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>BANCO                  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>AGENCIA                </B></TD>'		
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CONTA CORR             </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VR T0TAL CALCULADO     </B></TD>'

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
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Beneficio (Funcion·rio):&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalF,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE019RES'+x_Codigo
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)

STATIC FUNCTION INTFOL()

	mesano := STRZERO(VAL(MV_PAR01),4)+STRZERO(VAL(MV_PAR02),2)  

	If subs(mesano,5,2) $ "04/06/09/11"
		datadois := subs(mesano,1,4)+subs(mesano,5,2)+"30"
	Elseif subs(mesano,5,2) $ "01/03/05/07/08/10/12"
		datadois := subs(mesano,1,4)+subs(mesano,5,2)+"31"
	Elseif subs(mesano,5,2) $ "02"
		If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0) // ano bissexto
			datadois := subs(mesano,1,4)+subs(mesano,5,2)+"29"
		Else
			datadois := subs(mesano,1,4)+subs(mesano,5,2)+"28"
		Endif
	Endif

	cQuery := CRLF +" SELECT "
	cQuery += CRLF +" FILIAL,MAT,CCUSTO,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO,SUM(TOTAL) AS TOTAL "
	cQuery += CRLF +" FROM( "
	cQuery += CRLF +" SELECT RG2_FILIAL AS FILIAL,RG2_MAT AS MAT,RA_NOME AS NOME,RA_CIC AS CPF,RA_ADMISSA AS ADMISSAO,SUBSTRING(RA_BCDEPSA,1,3) AS BANCO,SUBSTRING(RA_BCDEPSA,4,5) AS AGENCIA,"
	cQuery += CRLF +" RA_CTDEPSA AS CONTA,RA_CC AS CCUSTO, RG2_PERIOD AS PERIODO,RG2_VALCAL AS TOTAL "
	cQuery += CRLF +" FROM "+ RETSQLNAME("RG2")+ " A, "	+ RETSQLNAME("SRA")+ " B, "+ RETSQLNAME("RCC")+ " C "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' '  "
	cQuery += CRLF +" AND LEFT(RG2_PERIOD,6)  = '"+mesano+"'  "
 	cQuery += CRLF +" AND RG2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"' " 
 	cQuery += CRLF +" AND RG2_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06 +"' " 
 	cQuery += CRLF +" AND RA_ADMISSA BETWEEN '"+DTOS(MV_PAR10)+"' AND '"+DTOS(MV_PAR11) +"' " 
	cQuery += CRLF +" AND RG2_TPBEN = '"+MV_PAR07+"'  "
	cQuery += CRLF +" AND RG2_FILIAL = RA_FILIAL AND RG2_MAT = RA_MAT "
	cQuery += CRLF +" AND RCC_CODIGO = 'S011' AND SUBSTRING(RCC_CONTEU,1,2) = RG2_TPBEN ) "
	cQuery += CRLF +" AS AGRUPADO "
	cQuery += CRLF +" GROUP BY FILIAL,MAT,CCUSTO,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO "
	cQuery += CRLF +" ORDER BY FILIAL,MAT,CCUSTO,NOME,CPF,ADMISSAO,BANCO,AGENCIA,CONTA,PERIODO "

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+                
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	cTotalE := 0
	cTotalS := 0
	
	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())

		INCPROC(nRegua)

 		_cChaveA :=  ENF->FILIAL+"266"+ENF->MAT+""
	
		_cFilial := ENF->FILIAL
		_cMat 	 := ENF->MAT
		_cValor  := ENF->TOTAL
		_cCusto  := ENF->CCUSTO
		//datamov  := datadois

	    //if left(ENF->ADMISSAO,6) =  left(mesano,6)
	    
			aArea	:= GetArea()     
	
			dbselectarea("SRC")
			nOrdem := RetOrder( "SRC" , "RC_FILIAL+RC_PD+RC_MAT+RC_SEQ" , .T. )
			SRC->( dbSetOrder( nOrdem )	)
	
	 		IF !DBSEEK(_cChaveA)
	 			RECLOCK("SRC",.T.)
				RC_FILIAL :=	_cFilial
				RC_MAT    :=	_cMat
				RC_PD     :=	"266"
				RC_TIPO1  := 	"V"
				RC_VALOR  :=	_cValor
				RC_CC     :=	_cCusto
				RC_TIPO2  := 	"G"
				RC_DATA   :=	STOD(datadois)	
	 			MSUNLOCK()				
			ELSE
	 			RECLOCK("SRC",.F.)
				RC_FILIAL :=	_cFilial
				RC_MAT    :=	_cMat
				RC_PD     :=	"266"
				RC_TIPO1  := 	"V"
				RC_VALOR  :=	_cValor
				RC_CC     :=	_cCusto
				RC_TIPO2  := 	"G"
				RC_DATA   :=	STOD(datadois)				
	 			MSUNLOCK()								
			ENDIF
			
	 		_cChaveA :=  _cFilial+"706"+_cMat+""
	
	 		IF !DBSEEK(_cChaveA)
	 			RECLOCK("SRC",.T.)
				RC_FILIAL :=	_cFilial
				RC_MAT    :=	_cMat
				RC_PD     :=	"706"
				RC_TIPO1  := 	"V"
				RC_VALOR  :=	_cValor
				RC_CC     :=	_cCusto
				RC_TIPO2  := 	"G"
				RC_DATA   :=	STOD(datadois)				
	 			MSUNLOCK()				
			ELSE
	 			RECLOCK("SRC",.F.)
				RC_FILIAL :=	_cFilial
				RC_MAT    :=	_cMat
				RC_PD     :=	"706"
				RC_TIPO1  := 	"V"
				RC_VALOR  :=	_cValor
				RC_CC     :=	_cCusto
				RC_TIPO2  := 	"G"
				RC_DATA   :=	STOD(datadois)		
	 			MSUNLOCK()								
			ENDIF
	
			RestArea(aArea)
		
		//ENDIF
		
    	ENF->(DBSKIP())
	END
	

RETURN






