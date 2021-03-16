#INCLUDE 'TOTVS.CH'
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥()∫Autor   ≥ Francisco F S Neto        ∫ Data ≥ 02/02/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ RelatÛrio de Folha de Pagamento em excel                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Clientes HLB BRASIL                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

USER FUNCTION GTGPE023()   


	Private cPerg     := "GTGPE023  "
	private cAliqicms := "  "  
	private aDes := {}
	private aDescop := {}
	
	private	cTotalVenR := 0
	private	cTotalVRF := 0			
	private	cTotalDesR := 0
	private	cTotalDRF := 0			 
	private	cTotalVenV := 0
	private	cTotalVVF := 0			
	private	cTotalDesV := 0
	private	cTotalDVF := 0		 
	private cTES := {}
	
	private cNOMECOM := space(40)
	private cCGC     := space(20)
	private cCNPJ    := space(20)

	x_Codigo := space(2)
	x_CodFi  := space(2)

	private Cmes := getmv("MV_FOLMES")
	
	//private nmeses := 0
	//datahum := ctod("01/12/2015")
	//datadois := ctod("20/02/2017")	
	//nmeses := DateDiffMonth( datahum , datadois ) 

	cNOMECOM := SM0->M0_NOMECOM
	cCGC     := SM0->M0_CGC
	cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)

	x_Codigo := SM0->M0_CODIGO
	x_codFi  := SM0->M0_CODFIL

	CriaSX1(cPerg)
	
	SET DECIMALS TO 2
	
	If Pergunte(cPerg,.T.)
		If SimNao("Folha Pagamento em Excel?") == "S"
			Processa({ |lEnd| geracom(@lEnd),OemToAnsi("Criando cabeÁalho, aguarde...")}, OemToAnsi("Aguarde..."))
		Else
			Return
		EndIf
	Else
		Return
	EndIf
	
RETURN



STATIC FUNCTION geracom()
	
	cQuery := ' '
	lLoop  := .T.
	cOrdm  := "01"
	nArq   := Nil

	nCont  := 01
	cHtml  := ' '
	cText := ''
	nRegua := 0
	nContArq := 0

	cTotalVenR := 0
	cTotalVRF := 0			
	cTotalDesR := 0
	cTotalDRF := 0			 
	cTotalVenV := 0
	cTotalVVF := 0			
	cTotalDesV := 0
	cTotalDVF := 0	
	cTotalLiq := 0

	cPath  := AllTrim(GetTempPath())
		
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	While lLoop
		If File(cPath+"GTGPE023"+x_Codigo+cOrdm+".html")
			cOrdm := AllTrim(Soma1(cOrdm))
		Else
			lLoop := .F.
		EndIf
	End
	
	IF MV_PAR02 == 1
		cText  := "RelatÛrio de Folha Pagamento - RESUMO - Data: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
		RESUMO()  
		RETURN
	ELSEIF MV_PAR02 == 2
		cText  := "RelatÛrio de Folha Pagamento - por Filial  - Data: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
	    FILIAL()
		RETURN
	ELSEIF MV_PAR02 == 3
		cText  := "RelatÛrio de Folha Pagamento - por C.Custo  - Data: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
		CCUSTO()
		RETURN
	ELSEIF MV_PAR02 == 4
		cText  := "RelatÛrio de Folha Pagamento - Detalhado por funcion·rio  - Data: " + substr(DTOS(MV_PAR01),7,2)+"/"+substr(DTOS(MV_PAR01),5,2)+"/"+substr(DTOS(MV_PAR01),1,4)
		DETALHE()
		RETURN
	ENDIF

RETURN


//=========================================+
//FUNCAO PARA GERAR CABE«ALHO DO HTML      +
//=========================================+
STATIC FUNCTION HtmlCab()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Folha Pagamento </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+x_Codigo+' '+x_CodFi+' '+cNOMECOM+'</B></TD>'	
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
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.CC       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>MATRICULA		</B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>NOME 	        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.VERBA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>REFERENCIA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR         </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)


//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodap()

	local cHtml := ' '
	
	cHtml += CRLF +'<br><br><br>'
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
	cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>Dados da Emiss„o</b></td> 
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Data:&nbsp;</td> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="left">&nbsp;'+DtoC(Date())+'</td> 
	cHtml += CRLF +' 	</TR> 
	
    //// RESUMO DE TOTAIS
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVenV-cTotalDesV),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaSX1   ∫Autor  ≥Francisco F S Neto  ∫ Data ≥02/02/2017   ∫±±
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
//             GRUPO/ORDEM/PERGUNT/PERSPA/PERENG   /VARIAV /TIPO/TAM/DEC/PRESEL/GSC/VALID/VAR01/DEF01/DEFSPA1/DEFENG1/CNT01/VAR02/DEF02/DEFSPA2/DEFENG2/CNT02/VAR03/DEF03/DEFSPA3/DEFENG3/CNT03/VAR04/DEF04/DEFSPA4/DEFENG4/CNT04/VAR05/DEF05/DEFSPA5/DEFENG5/CNT05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
	
	Aadd(aRegs,{cPerg,'01','Data Base                             ','','','MV_CH1','D',08,0,0,'G','','MV_PAR01','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','T=Total/F=Filial/C=C.Custo/D=Detalhe: ','','','MV_CH2','N',01,0,1,'C','','MV_PAR02','Total','','','','','Filial','','','','','C.Custo','','','','','Detalhe','','','','','','','','','   ','D','','','',''})
	Aadd(aRegs,{cPerg,'03','Da Filial:                            ','','','MV_CH3','C',02,0,0,'G','','MV_PAR03','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','XM0',' ','','','',''})
	Aadd(aRegs,{cPerg,'04','AtÅEa Filial:                         ','','','MV_CH4','C',02,0,0,'G','','MV_PAR04','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','XM0',' ','','','',''})
	Aadd(aRegs,{cPerg,'05','Do C.Custo    :                       ','','','MV_CH5','C',10,0,0,'G','','MV_PAR05','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','CTT',' ','','','',''})
	Aadd(aRegs,{cPerg,'06','AtÅEo C.Custo :                       ','','','MV_CH6','C',10,0,0,'G','','MV_PAR06','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','CTT',' ','','','',''})
	Aadd(aRegs,{cPerg,'07','Da Matricula  :                       ','','','MV_CH7','C',10,0,0,'G','','MV_PAR07','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','SRA',' ','','','',''})
	Aadd(aRegs,{cPerg,'08','AtÅEMatricula :                       ','','','MV_CH8','C',10,0,0,'G','','MV_PAR08','     ','','','','','      ','','','','','       ','','','','','       ','','','','','','','','','SRA',' ','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return


STATIC FUNCTION DETALHE()

////------------  DETALHES
	IF cMes = SUBSTRING(DTOS(MV_PAR01),1,6)
		cQuery := CRLF +" SELECT  "  
		cQuery += CRLF +" RC_FILIAL AS FILIAL,RC_CC AS CC,CTT_DESC01 AS DESCCC,RC_MAT AS MATRICULA,RA_NOME AS NOME,SUBSTRING(RC_DATA,5,2) AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RC_PD AS VERBA,RV_DESC AS DESCVERBA,RC_HORAS AS REF,RC_VALOR AS VALOR  "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' '  "
		cQuery += CRLF +" AND SUBSTRING(RC_DATA,1,6) = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RC_FILIAL = RA_FILIAL AND RC_CC = RA_CC AND RC_MAT = RA_MAT  "
		cQuery += CRLF +" AND RC_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RC_PD = RV_COD " 
		cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RC_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "		
		cQuery += CRLF +" ORDER BY RC_FILIAL,RC_CC,RC_MAT,RV_TIPOCOD,RC_PD "
	Else
		cQuery := CRLF +" SELECT  "  
		cQuery += CRLF +" RD_FILIAL AS FILIAL,RD_CC AS CC,CTT_DESC01 AS DESCCC,RD_MAT AS MATRICULA,RA_NOME AS NOME,RD_MES AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCVERBA,RD_HORAS AS REF,RD_VALOR AS VALOR  "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' '  "
		cQuery += CRLF +" AND RD_DATARQ = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_CC = RA_CC AND RD_MAT = RA_MAT  "
		cQuery += CRLF +" AND RD_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RD_PD = RV_COD "
		cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RD_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RD_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "				
		cQuery += CRLF +" ORDER BY RD_FILIAL,RD_CC,RD_MAT,RV_TIPOCOD,RD_PD "	
	Endif
	    

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE023"+x_Codigo+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	cHtmlOk := HtmlCab(cText,'Data: ', MV_PAR01,'  ', ' ', '') 	// cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTit(aStruFim)	//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotalVenR := 0
	cTotalVRF := 0			
	cTotalDesR := 0
	cTotalDRF := 0			 
	cTotalVenV := 0
	cTotalVVF := 0			
	cTotalDesV := 0
	cTotalDVF := 0	
	cTotalLiq := 0
	
	ProcRegua(nRegua)
	
	_V := 1
	Qfunc := ' ' 

	WHILE ENF->(!EOF())

		//CALCULO PARA VERIFICAR A LINHA, GERA FORMATO DE TABELA - LINHA BRANCA E LINHA AZUL.
		nCont ++

		IF 	Qfunc <> ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[4][1])) 
	        QUEBFUN()
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'    // CCUSTO
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'    // DESCCC
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'    // MATRICULA
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'    // NOME 
		ELSE
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // CCUSTO
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // DESCCC
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // MATRICULA
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // NOME		
		ENDIF
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[8][1]))+'&nbsp</td>'    // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[9][1]))+'&nbsp</td>'    // DESCVERBA
		cValor := &("ENF->"+aStruFim[10][1])
		IF ENF->TIPO = '1'
			cTotalVenR := cTotalVenR + cValor 
			cTotalVRF := cTotalVRF + cValor 			
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesR := cTotalDesR + cValor
			cTotalDRF := cTotalDRF + cValor 			 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 99,999.99")+'&nbsp</TD>' // REFERENCIA
		cValor := &("ENF->"+aStruFim[11][1])
		IF ENF->TIPO = '1'
			cTotalVenV := cTotalVenV + cValor 
			cTotalVVF := cTotalVVF + cValor 			
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesV := cTotalDesV + cValor
			cTotalDVF := cTotalDVF + cValor			 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>' // VALOR
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
		_V := _V + 1
		ENF->(DBSKIP())  
	END 
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 

    QUEBFUN()
	
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


STATIC FUNCTION CCUSTO()
///------------  AGRUPADO POR FILIAL, C.CUSTO, VERBA  (TOTAL POR C.CUSTO)
	IF cMes = SUBSTRING(DTOS(MV_PAR01),1,6)
		cQuery := CRLF +" SELECT FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM(  "
		cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_CC AS CC,CTT_DESC01 AS DESCCC,RC_MAT AS MATRICULA,RA_NOME AS NOME,SUBSTRING(RC_DATA,5,2) AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RC_PD AS VERBA,RV_DESC AS DESCVERBA,RC_HORAS AS REF,RC_VALOR AS VALOR  "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +" AND SUBSTRING(RC_DATA,1,6) = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RC_FILIAL = RA_FILIAL AND RC_CC = RA_CC AND RC_MAT = RA_MAT "
		cQuery += CRLF +" AND RC_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RC_PD = RV_COD "
		cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RC_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"				
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA  "
		cQuery += CRLF +" ORDER BY FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA  "
	Else
		cQuery := CRLF +" SELECT FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM(  "
		cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_CC AS CC,CTT_DESC01 AS DESCCC,RD_MAT AS MATRICULA,RA_NOME AS NOME,RD_MES AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCVERBA,RD_HORAS AS REF,RD_VALOR AS VALOR  "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +" AND RD_DATARQ = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_CC = RA_CC AND RD_MAT = RA_MAT "
		cQuery += CRLF +" AND RD_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RD_PD = RV_COD "
		cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RD_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RD_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"						
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA  "
		cQuery += CRLF +" ORDER BY FILIAL,CC,DESCCC,TIPO,VERBA,DESCVERBA  "
	ENDIF

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE023"+x_Codigo+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+                
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	cHtmlOk := HtmlCabCC(cText,'Data: ', MV_PAR01,'  ', ' ', '') 	// cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitCC(aStruFim)	//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotalVenR := 0
	cTotalVenV := 0
	cTotalDesR := 0
	cTotalDesV := 0
	cTotalLiq := 0
	cTotalVCR := 0
	cTotalVCV := 0
	cTotalDCR := 0
	cTotalDCV := 0
	cTotalLiqC := 0
	_V := 1
	QCUSTO := ' ' 

	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMATO DE TABELA - LINHA BRANCA E LINHA AZUL.
		nCont ++

		IF 	QCUSTO <> ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[2][1])) 
			QUEBCUST()
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'    // CCUSTO
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'    // DESCCC
		ELSE
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // FILIAL
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // CCUSTO
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // DESCCC
		ENDIF			
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[5][1]))+'&nbsp</td>'    // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[6][1]))+'&nbsp</td>'    // DESCVERBA
		cValor := &("ENF->"+aStruFim[7][1])
		IF ENF->TIPO = '1'
			cTotalVenR := cTotalVenR + cValor 
			cTotalVCR := cTotalVCR + cValor 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesR := cTotalDesR + cValor 
			cTotalDCR := cTotalDCR + cValor 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 99,999.99")+'&nbsp</TD>' // REFERENCIA
		cValor := &("ENF->"+aStruFim[8][1])
		IF ENF->TIPO = '1'
			cTotalVenV := cTotalVenV + cValor
			cTotalVCV := cTotalVCV + cValor			 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesV := cTotalDesV + cValor 
			cTotalDCV := cTotalDCV + cValor 			
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>' // VALOR
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
		_V := _V + 1
		ENF->(DBSKIP())  
	END 
	
    cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' ' 

    QUEBCUST()
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlRodapCC()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabCC()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Folha Pagamento Resumo por CC </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+x_Codigo+' '+x_CodFi+' '+cNOMECOM+'</B></TD>'			
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
STATIC FUNCTION HtmlTitCC()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>C.CUSTO       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.CC       </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.VERBA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>REFERENCIA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR         </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapCC()

	
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
	
    //// RESUMO DE TOTAIS
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVenV-cTotalDesV),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)



STATIC FUNCTION FILIAL()

////------------  AGRUPADO POR FILIAL, VERBA   (TOTAL POR FILIAL)

	IF cMes = SUBSTRING(DTOS(MV_PAR01),1,6)
		cQuery := CRLF +" SELECT FILIAL,TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM( "
		cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_CC AS CC,CTT_DESC01 AS DESCCC,RC_MAT AS MATRICULA,RA_NOME AS NOME,SUBSTRING(RC_DATA,5,2) AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RC_PD AS VERBA,RV_DESC AS DESCVERBA,RC_HORAS AS REF,RC_VALOR AS VALOR "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' '  "
		cQuery += CRLF +" AND SUBSTRING(RC_DATA,1,6) = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RC_FILIAL = RA_FILIAL AND RC_CC = RA_CC AND RC_MAT = RA_MAT "
		cQuery += CRLF +" AND RC_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RC_PD = RV_COD "
		cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RC_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"						
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY FILIAL,TIPO,VERBA,DESCVERBA "
		cQuery += CRLF +" ORDER BY FILIAL,TIPO,VERBA,DESCVERBA "
	Else
		cQuery := CRLF +" SELECT FILIAL,TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM( "
		cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_CC AS CC,CTT_DESC01 AS DESCCC,RD_MAT AS MATRICULA,RA_NOME AS NOME,RD_MES AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCVERBA,RD_HORAS AS REF,RD_VALOR AS VALOR "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' '  "
		cQuery += CRLF +" AND RD_DATARQ = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' "
		cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_CC = RA_CC AND RD_MAT = RA_MAT "
		cQuery += CRLF +" AND RD_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RD_PD = RV_COD "
		cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RD_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RD_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"						
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY FILIAL,TIPO,VERBA,DESCVERBA "
		cQuery += CRLF +" ORDER BY FILIAL,TIPO,VERBA,DESCVERBA "
	ENDIF

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE023"+x_Codigo+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+                
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	cHtmlOk := HtmlCabFI(cText,'Data: ', MV_PAR01,'  ', '', '') 	// cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitFI(aStruFim)	//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotalVenR := 0
	cTotalVenV := 0
	cTotalDesR := 0
	cTotalDesV := 0
	cTotalLiq := 0
	cTotalVFR := 0
	cTotalVFV := 0
	cTotalDFR := 0
	cTotalDFV := 0
	cTotalLiqF := 0
	_V := 1
	QFILIAL := ' ' 
	
	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMATO DE TABELA - LINHA BRANCA E LINHA AZUL.
		nCont ++


		IF 	QFILIAL <> ALLTRIM(&("ENF->"+aStruFim[1][1]))
			QUEBFIL()
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[1][1]))+'&nbsp</td>'    // FILIAL
		ELSE
			IF nCont%2 == 0
				cBgColor := "#FFFFFF"
			ELSE
				cBgColor := "#CAE4FF"
			ENDIF
			cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
			cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
			cHtml += CRLF +'<TD align="left">'+" "+'&nbsp</td>'    // FILIAL
		ENDIF			

		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'    // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[4][1]))+'&nbsp</td>'    // DESCVERBA
		cValor := &("ENF->"+aStruFim[5][1])
		IF ENF->TIPO = '1'
			cTotalVenR := cTotalVenR + cValor 
			cTotalVFR := cTotalVFR + cValor 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesR := cTotalDesR + cValor 
			cTotalDFR := cTotalDFR + cValor 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 99,999.99")+'&nbsp</TD>' // REFERENCIA
		cValor := &("ENF->"+aStruFim[6][1])
		IF ENF->TIPO = '1'
			cTotalVenV := cTotalVenV + cValor
			cTotalVFV := cTotalVFV + cValor			 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesV := cTotalDesV + cValor 
			cTotalDFV := cTotalDFV + cValor 			
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>' // VALOR
						  	
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

	QUEBFIL()
	
	cHtml += CRLF +'<br><br><br>'
	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlRodapFI()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabFI()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Folha Pagamento Resumo por FILIAL </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+x_Codigo+' '+x_CodFi+' '+cNOMECOM+'</B></TD>'			
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
STATIC FUNCTION HtmlTitFI()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>FILIAL        </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.VERBA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>REFERENCIA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR         </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapFI()

	
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
	
    //// RESUMO DE TOTAIS
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVenV-cTotalDesV),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)

      
STATIC FUNCTION RESUMO()
///------------  AGRUPADO POR VERBA (TOTAL GERAL)  

	IF cMes = SUBSTRING(DTOS(MV_PAR01),1,6)
		cQuery := CRLF +" SELECT TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM( "
		cQuery += CRLF +" SELECT RC_FILIAL AS FILIAL,RC_CC AS CC,CTT_DESC01 AS DESCCC,RC_MAT AS MATRICULA,RA_NOME AS NOME,SUBSTRING(RC_DATA,5,2) AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RC_PD AS VERBA,RV_DESC AS DESCVERBA,RC_HORAS AS REF,RC_VALOR AS VALOR "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRC")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +" AND SUBSTRING(RC_DATA,1,6) = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' " 
		cQuery += CRLF +" AND RC_FILIAL = RA_FILIAL AND RC_CC = RA_CC AND RC_MAT = RA_MAT "
		cQuery += CRLF +" AND RC_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RC_PD = RV_COD "
		cQuery += CRLF +" AND RC_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RC_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RC_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"						
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY TIPO,VERBA,DESCVERBA "
		cQuery += CRLF +" ORDER BY TIPO,VERBA,DESCVERBA "
	Else
		cQuery := CRLF +" SELECT TIPO,VERBA,DESCVERBA,SUM(REF) AS REF,SUM(VALOR) AS VALOR "
		cQuery += CRLF +" FROM( "
		cQuery += CRLF +" SELECT RD_FILIAL AS FILIAL,RD_CC AS CC,CTT_DESC01 AS DESCCC,RD_MAT AS MATRICULA,RA_NOME AS NOME,RD_MES AS MES, "
		cQuery += CRLF +" RV_TIPOCOD AS TIPO,RD_PD AS VERBA,RV_DESC AS DESCVERBA,RD_HORAS AS REF,RD_VALOR AS VALOR "
		cQuery += CRLF +" FROM " + RETSQLNAME("SRD")+" A, " + RETSQLNAME("SRA")+" B, " + RETSQLNAME("CTT")+" C, " + RETSQLNAME("SRV")+" D " 		
		cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' '  AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' AND D.D_E_L_E_T_ = ' ' "
		cQuery += CRLF +" AND RD_DATARQ = '" + SUBSTRING(DTOS(MV_PAR01),1,6)+"' " 
		cQuery += CRLF +" AND RD_FILIAL = RA_FILIAL AND RD_CC = RA_CC AND RD_MAT = RA_MAT "
		cQuery += CRLF +" AND RD_CC = CTT_CUSTO "
		cQuery += CRLF +" AND RD_PD = RV_COD "
		cQuery += CRLF +" AND RD_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += CRLF +" AND RD_CC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cQuery += CRLF +" AND RD_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )"						
		cQuery += CRLF +" AS AGRUPADO "
		cQuery += CRLF +" GROUP BY TIPO,VERBA,DESCVERBA "
		cQuery += CRLF +" ORDER BY TIPO,VERBA,DESCVERBA "
	ENDIF

	cQuery := ChangeQuery(cQuery)
	
	IF SELECT("ENF") > 0
		ENF->(DBCLOSEAREA())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ENF",.F.,.F.)
	
	cArq   := cPath+"GTGPE023"+x_Codigo+cOrdm+".html"
	nArq   := fCreate(cArq,0)
	
	aStruFim := ENF->(DbStruct())
	
	//=========================================================+                
	// GERA HTML PARA EXECUTAR O EXCEL                         +
	//=========================================================+
	
	
	ENF->(DBGOTOP())
	
	cHtmlOk := HtmlCabRE(cText,'Data: ', MV_PAR01,'  ', '', '') 	// cabeÁalho do relatorio 
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	
	cHtmlOk := HtmlTitRE(aStruFim)		//CAMPOS DO RELATORIO QUE ESTAO NA QUERY
	fWrite(nArq,cHtmlOk,Len(cHtmlOK))
	
	cTotalVenR := 0
	cTotalVenV := 0
	cTotalDesR := 0
	cTotalDesV := 0
	cTotalLiq := 0
	
	ProcRegua(nRegua)
	
	WHILE ENF->(!EOF())
		
		//CALCULO PARA VERIFICAR A LINHA, GERA FORMATO DE TABELA - LINHA BRANCA E LINHA AZUL.
		nCont ++
		IF nCont%2 == 0
			cBgColor := "#FFFFFF"
		ELSE
			cBgColor := "#CAE4FF"
		ENDIF
		
		cHtml += CRLF+' <TABLE border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">
		cHtml += CRLF+' <TR bgcolor='+cBgColor+' valign="middle" align="center" style=" font-family:Arial; font-size:10px"> '
	
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[2][1]))+'&nbsp</td>'    // VERBA
		cHtml += CRLF +'<TD align="left">'+ALLTRIM(&("ENF->"+aStruFim[3][1]))+'&nbsp</td>'    // DESCVERBA
		cValor := &("ENF->"+aStruFim[4][1])
		IF ENF->TIPO = '1'
			cTotalVenR := cTotalVenR + cValor 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesR := cTotalDesR + cValor 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 99,999.99")+'&nbsp</TD>' // REFERENCIA
		cValor := &("ENF->"+aStruFim[5][1])
		IF ENF->TIPO = '1'
			cTotalVenV := cTotalVenV + cValor 
		ELSEIF 	ENF-> TIPO = '2'
			cTotalDesV := cTotalDesV + cValor 
		ENDIF
		cHtml += CRLF +'<TD align="RIGHT">'+TRANSFORM(cValor,"@E 999,999,999.99")+'&nbsp</TD>' // VALOR
				  	
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
	
	cHtmlOk := HtmlRodapRE()   // chama o rodapÅEdo relatorio
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
STATIC FUNCTION HtmlCabRE()

	Local cHtml := " "
	
	cHtml += CRLF +''
	cHtml += CRLF +'<HTML>'
	cHtml += CRLF +'<HEAD><TITLE>RelatÛrio de Folha Pagamento Resumo </TITLE></HEAD>'
	cHtml += CRLF +'<BODY bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" link="#000000" vlink="#000000" alink="#000000">'
	
	cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="0" width="780" cellpadding="0" cellspacing="0">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:18px">'
	cHtml += CRLF +'		<TD height="35" colspan="16"  align="center" valign="middle"><B>'+x_Codigo+' '+x_CodFi+' '+cNOMECOM+'</B></TD>'			
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
STATIC FUNCTION HtmlTitRE()
	
	Local cHtml := " "
	 
	cHtml += CRLF +'<TABLE Bgcolor="#FFFFFF" border="1" cellpadding="0" cellspacing="0" bordercolorlight="#000000" bordercolordark="#FFFFFF">'
	cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Calibri; font-size:16px">'
	cHtml += CRLF +'	</TR>'
	cHtml += CRLF + '	<TR>
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VERBA         </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>DESC.VERBA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>REFERENCIA    </B></TD>'
	cHtml += CRLF + '		<TD align="left" bgcolor="#00BFFF"><B>VALOR         </B></TD>'

	cHtml += CRLF +		'</TR>'
	cHtml += CRLF +'</TABLE>'

Return(cHtml)

//========================================+
// RODAPE DO HTML                         +
//========================================+
Static Function HtmlRodapRE()

	
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
	
    //// RESUMO DE TOTAIS
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVenV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesR,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDesV,"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 

	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
	cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVenV-cTotalDesV),"@E 999,999,999,999.99")+'&nbsp</TD>'
	cHtml += CRLF +' 	</TR> 
	 	
	cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="right">Usu·rio:&nbsp;</td> 
	cHtml += CRLF +'		<td height="20" width="12.5%" align="left">&nbsp;'+cNomeUser+'</td> 
	cHtml += CRLF +' 	</TR> 
	cHtml += CRLF +'</TABLE>
	
	cHtml += CRLF +'<br><br>'
	cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
	
	cHtml += CRLF+' </body> '
	cHtml += CRLF+' </html> '
	
	
Return(cHtml)


Static Function QUEBFUN()

	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' '

	if _v <> 1
	
		cHtml += CRLF +'<br><br><br>'
		cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
		cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
		cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS FUNCIONARIO</b></td> 
		cHtml += CRLF +' 	</TR> 
		 	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVRF,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVVF,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDRF,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDVF,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVVF-cTotalDVF),"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	 
		cHtml += CRLF +'</TABLE>	
		
		cHtml += CRLF +'<br><br>'
		cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
		
		cHtmlOk := cHtml
		FWrite(nArq,cHtmlOk,Len(cHtmlOk))
		cHtml := ' '
	    
	endif
	

	Qfunc := ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[4][1]))

	cTotalVRF := 0
	cTotalVVF := 0
	cTotalDRF := 0
	cTotalDVF := 0
	cTotalLiqF := 0

Return


Static Function QUEBCUST()

	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' '

	if _v <> 1
	
		cHtml += CRLF +'<br><br><br>'
		cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
		cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
		cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS CENTRO DE CUSTO</b></td> 
		cHtml += CRLF +' 	</TR> 
		 	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVCR,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVCV,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDCR,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDCV,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVCV-cTotalDCV),"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	 
		cHtml += CRLF +'</TABLE>	
		
		cHtml += CRLF +'<br><br>'
		cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
		
		cHtmlOk := cHtml
		FWrite(nArq,cHtmlOk,Len(cHtmlOk))
		cHtml := ' '
	    
	endif
	

	QCUSTO := ALLTRIM(&("ENF->"+aStruFim[1][1])) + ALLTRIM(&("ENF->"+aStruFim[2][1]))

	cTotalVCR := 0
	cTotalVCV := 0
	cTotalDCR := 0
	cTotalDCV := 0
	cTotalLiqC := 0

Return



Static Function QUEBFIL()

	cHtmlOk := cHtml
	FWrite(nArq,cHtmlOk,Len(cHtmlOk))
	cHtml := ' '

	if _v <> 1
	
		cHtml += CRLF +'<br><br><br>'
		cHtml += CRLF +'<TABLE bgcolor="#FFFFFF" border="1" width="780" cellpadding="0" cellspacing="0">	
		cHtml += CRLF +'	<TR valign="top" width="10%" style=" font-family:Arial; font-size:16px">
		cHtml += CRLF +' 		<td height="20" width="10%" colspan="2" align="center"><b>TOTAIS POR FILIAL</b></td> 
		cHtml += CRLF +' 	</TR> 
		 	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVFR,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Vencimentos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalVFV,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Ref Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDFR,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Total Descontos :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM(cTotalDFV,"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	
		cHtml += CRLF +'	<TR valign="top" width="100%" style=" font-family:Arial; font-size:16px"> 
		cHtml += CRLF +' 		<td height="20" width="12.5%" align="right">Valor Liquido :&nbsp;</td> 
		cHtml += CRLF +'        <TD align="RIGHT">'+TRANSFORM((cTotalVFV-cTotalDFV),"@E 999,999,999,999.99")+'&nbsp</TD>'
		cHtml += CRLF +' 	</TR> 
	 
		cHtml += CRLF +'</TABLE>	
		
		cHtml += CRLF +'<br><br>'
		cHtml += CRLF +'Siga/GTGPE023'+x_Codigo
		
		cHtmlOk := cHtml
		FWrite(nArq,cHtmlOk,Len(cHtmlOk))
		cHtml := ' '
	    
	endif
	
	_v := _v + 1    

	QFILIAL := ALLTRIM(&("ENF->"+aStruFim[1][1])) 

	cTotalVFR := 0
	cTotalVFV := 0
	cTotalDFR := 0
	cTotalDFV := 0
	cTotalLiqF := 0

Return

