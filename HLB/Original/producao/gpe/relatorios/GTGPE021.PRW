#include "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ()บAutor   ณ Francisco F S Neto        บ Data ณ 23/01/2017  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio de Programa็ใo de F้rias                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes HLB BRASIL                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION GTGPE021()   


Private cPerg     := "GTGPE021  "
private cAliqicms := "  "  
private aDes := {}
private aDescop := {}
private cTotal := 0
//private MV_PAR03 := 1

private cTES := {}

private cNOMECOM := space(40)
private cCGC     := space(20)
private cCNPJ    := space(20)

cNOMECOM := SM0->M0_NOMECOM
cCGC     := SM0->M0_CGC
cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
cCodigo  := SM0->M0_CODIGO

private _cFilial := SM0->M0_CODFIL

CriaSX1(cPerg)

SET DECIMALS TO 2

If Pergunte(cPerg,.T.)
	If SimNao("Relat๓rio Prog. de F้rias?") == "S"
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
	cTotal := 0
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE021"+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End

	
	cText  := "RELAวรO DE PROGRAMAวรO DE FษRIAS - Em: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)

	cQuery := CRLF +" SELECT  "  
 	cQuery += CRLF +" RF_FILIAL,RA_CC,CTT_DESC01,RF_MAT,RA_NOME,RA_SITFOLH,RA_ADMISSA,RF_DATABAS,RF_IVENPEN,RF_FVENPEN, "
 	cQuery += CRLF +" RF_DFERVAT,RF_DFERAAT,RF_DFERANT,RF_DVENPEN,RF_FERCOLE,RF_PAR13AT, "
 	cQuery += CRLF +" CASE " 	
	cQuery += CRLF +" WHEN RF_DFERVAT = 30 AND RF_DFERAAT >= 25 THEN 'Aten็ใo!! Funcionแrio deverEsair de F้rias!!!!!' "
	cQuery += CRLF +" when RF_DFERVAT > 30  THEN 'Aten็ใo !! Funcionแrio receberEf้rias em dobro!!!!!!' "
	cQuery += CRLF +" WHEN RF_DFERVAT = 30 AND RF_DFERAAT < 25 THEN 'Primeiro per๚do aquisitivo vencido!!' "
	cQuery += CRLF +" ELSE ' ' END "
	cQuery += CRLF +" AS MENSAGEM "
	cQuery += CRLF +" FROM " + RETSQLNAME("SRF")+" A,"+ RETSQLNAME("SRA")+" B," + RETSQLNAME("CTT")+" C " 
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' "
	cQuery += CRLF +" AND RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RA_CC = CTT_CUSTO "							
	cQuery += CRLF +" ORDER BY RF_FILIAL,RA_CC,RF_MAT "
	
	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE021"+cOrdm+".html"
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
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'  // C.CUSTO
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'  // DESCR.CC
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'  // MATRICULA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'  // NOME
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'  // SITUACAO
        cData :=&("ENF->"+aStruFim[7][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// ADMISSAO
        cData :=&("ENF->"+aStruFim[8][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// PERIODO AQUIS
        cData :=&("ENF->"+aStruFim[9][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// INICIO FER VENC PEND
        cData :=&("ENF->"+aStruFim[10][1])
		cHtml += CRLF +'<TD align="left">'+TRANSFORM(stod(cData),"@d")+'&nbsp</td>' 		// FIM FER VENC PEND
		cValor := &("ENF->"+aStruFim[11][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS VENCIDAS
		cValor := &("ENF->"+aStruFim[12][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS PROPORC.
		cValor := &("ENF->"+aStruFim[13][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS VENCIDAS ANTEC
		cValor := &("ENF->"+aStruFim[14][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999.9")+'&nbsp</TD>'		// DIAS DE FERIAS VENCIDAS PEND
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[15][1]))+'&nbsp</td>'  	// CALC FER COL		
		cValor := &("ENF->"+aStruFim[16][1])		
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>'	// VALOR PRIM PARCELA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[17][1]))+'&nbsp</td>'  	// MENSAGEM					
		
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
	cHtml += CRLF +'<HEAD><TITLE>RELAวรO DE PROGRAMAวรO DE FษRIAS </TITLE></HEAD>'
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
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL              </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C. CUSTO            </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESCR.C.CUSTO       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA		      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME      	      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>SITUAวรO  	      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DATA ADMISSAO       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>PERIODO AQUIS.      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DT.INI.FER.VEN.PEN  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DT.FIM FER.VEN.PEN  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS FER VENC.      </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS FER PROPORC    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS F.VENC.ANTEC   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DIAS F.VENC.PEND.   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>CALCULO FERIAS COL  </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VR. PRIMEIRA PARC   </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MENSAGEM            </B></TD>'

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
	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usuแrio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE021'
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
Return(cHtml)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSX1   บAutor  ณFrancisco F S Neto  บ Data ณ23/01/2017   บฑฑ
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
	
	Aadd(aRegs,{cPerg,'01','Data:        ','','','MV_CH1','D',8,0,0,'G',' ','MV_PAR01','   ','','','   ','','   ','','','','','','','','','','','','','','','','','','','   ',' ','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return


