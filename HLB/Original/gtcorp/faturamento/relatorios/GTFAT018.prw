#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE OP_ATA 1
#DEFINE OP_BPS 2

/*/{Protheus.doc} GTFAT018
@author Guilherme Fernandes Pilan - GFP
@since 11/08/2017
@version P11.8
@type function
@description Relação de Previsão de Faturamento
/*/
*----------------------*
User Function GTFAT018()
*----------------------*
Private nAcao := 1

If !TelaAcao()
	Return NIL
EndIf

Processa({|| ExecRelat(nAcao) } ,"Geração de Planilha","Processando geração de planilha...")

Return NIL

*------------------------*
Static Function TelaAcao()
*------------------------*
Local oDlg, oRadMenu, lRet := .T.
Local aItems := {"ATA - Grupo Auditores","BPS - Business Process Solutions"}

	DEFINE MSDIALOG oDlg TITLE "Ações" FROM 000, 000 TO 150, 300 PIXEL
		@ 005, 008 SAY oSay1 PROMPT "Informe o tipo de geração de Previsão de Faturamento:" SIZE 64, 007 OF oDlg PIXEL
		@ 015, 008 GROUP oGroup1 TO 50, 140 PROMPT "  Tipos disponíveis  " OF oDlg PIXEL
		@ 026, 014 RADIO oRadMenu VAR nAcao ITEMS aItems[1],aItems[2] SIZE 100, 020 OF oGroup1 PIXEL
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lRet := .T., oDlg:End()},{|| lRet := .F., oDlg:End()})) CENTERED

Return lRet

*------------------------------*
Static Function ExecRelat(nAcao)
*------------------------------*
Local cAcao, i, aEmpresas := {}
Private cDest := GetTempPath() + "\", cArq
Do Case
	Case nAcao == OP_ATA
		cAcao := "ATA - Grupo Auditores"
		aEmpresas := {"ZB","ZF","ZG"}
	Case nAcao == OP_BPS
		cAcao := "BPS - Business Process Solutions""
		aEmpresas := {"Z4","CH","RH","4K","Z8","ZP"}
End Case

cArq := "PosicaoFaturamento_" + cAcao + "_" + DTOS(Date()) + "_" + StrTran(Time(),":","") + ".xls"

ProcRegua(Len(aEmpresas))

CabecalhoXML()

For i := 1 To Len(aEmpresas)
	If !GeraRegs(aEmpresas[i])
		Loop
	EndIf
	CriaPasta(Posicione("SM0",1,aEmpresas[i],"M0_NOME"))
	CorpoXML()
	RodapeXML()
	IncProc()
Next i

FinalXML()

SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel

Return NIL

*-----------------------------*
Static Function CabecalhoXML()
*-----------------------------*
Local cXML := ""
// Tratamento de estilos da Planilha.
cXML += '<?xml version="1.0"?>'
cXML += '<?mso-application progid="Excel.Sheet"?>'
cXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'
cXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"'
cXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"'
cXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'
cXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">'
cXML += ' <Styles>'
cXML += '  <Style ss:ID="Default" ss:Name="Normal">'
cXML += '   <Alignment ss:Vertical="Bottom"/>'
cXML += '   <Borders/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'
cXML += '   <Interior/>'
cXML += '   <NumberFormat/>'
cXML += '   <Protection/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Cabecalho">'
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12.5" ss:Color="#7B68EE"'
cXML += '    ss:Bold="1"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Titulo">'
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"'
cXML += '    ss:Bold="1"/>'
cXML += '   <Interior ss:Color="#7B68EE" ss:Pattern="Solid"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha1">'	// Cor 1 - String
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="@"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha2">'	// Cor 2 - String
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="@"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha3">'	// Cor 1 - Data
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Short Date"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha4">'	// Cor 2 - Data
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Short Date"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha5">'	// Cor 1 - Numero (2 casas decimais)
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Standard"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha6">'	// Cor 2 - Numero (2 casas decimais)
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="Standard"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha7">'	// Cor 1 - Numero (Inteiro)
cXML += '   <Interior ss:Color="#C2C2DC" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="0"/>'
cXML += '  </Style>'
cXML += '  <Style ss:ID="Linha8">'	// Cor 2 - Numero (Inteiro)
cXML += '   <Interior ss:Color="#E6E6FA" ss:Pattern="Solid"/>'
cXML += '   <NumberFormat ss:Format="0"/>'
cXML += '  </Style>'
cXML += ' </Styles>'
cXML := GrvXML(cXML)

Return NIL

*------------------------------*
Static Function CriaPasta(cNome)
*------------------------------*
Local cXML := ""

// Criação de Pasta de Trabalho
cXML += ' <Worksheet ss:Name="' + AllTrim(cNome) + '">'
cXML += '  <Table ss:ExpandedColumnCount="14" ss:ExpandedRowCount="999999" x:FullColumns="1"'
cXML += '   x:FullRows="1" ss:DefaultRowHeight="15">'
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Codigo Empresa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Filial Empresa
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Contrato
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'	//Código Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Loja Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="250"/>'	//Nome Cliente
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Parcela
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="80"/>'	//Competencia
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Data Previsão Medição
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Data Vencimento
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="62"/>'	//Código Moeda
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Valor Previsto
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="100"/>'	//Proposta
cXML += '   <Column ss:AutoFitWidth="0" ss:Width="150"/>'	//Socio

//cXML += '   <Row ss:AutoFitHeight="0" ss:Height="15.75">'
//cXML += '    <Cell ss:MergeAcross="13" ss:StyleID="Cabecalho"><Data ss:Type="String">Posi&ccedil;&atilde;o de Faturamento</Data></Cell>'
//cXML += '   </Row>'
//cXML += '   <Row ss:AutoFitHeight="0">'
cXML += '   <Row>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Empresa</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Filial</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Contrato</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">C&oacute;digo Cliente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Loja Cliente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Nome Cliente</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Parcela</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Compet&ecirc;ncia</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Prev. Medi&#231;&atilde;o</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Data Vencimento</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Moeda</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Valor Previsto</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Proposta</Data></Cell>'
cXML += '    <Cell ss:StyleID="Titulo"><Data ss:Type="String">Socio</Data></Cell>'
cXML += '   </Row>'
cXML := GrvXML(cXML)

Return NIL

*--------------------------*
Static Function RodapeXML()
*--------------------------*
Local cXML := ""

cXML += '  </Table>'
cXML += ' </Worksheet>'
cXML := GrvXML(cXML)

Return NIL

*--------------------------*
Static Function FinalXML()
*--------------------------*
Return GrvXML(' </Workbook>')

*-------------------------*
Static Function CorpoXML()
*-------------------------*
Local cXML := "", i := 1

Do While QRY->(!Eof())
	cXML += '   <Row>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->EMPRESA			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->FILIAL				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->CONTRATO			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->CODCLIENTE			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->LOJACLI			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + CharXML(QRY->CLIENTE)	+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->PARCELA			+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->COMPETENCIA		+ '</Data></Cell>'
	If !Empty(QRY->DTPREVMED)
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DTPREVMED	+ '</Data></Cell>'
	Else
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"/>'
	EndIf
	If !Empty(QRY->DTVENC)
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"><Data ss:Type="DateTime">'+ QRY->DTVENC		+ '</Data></Cell>'
	Else
		cXML += '    <Cell ss:StyleID="' + DePara(0,"D",i) + '"/>'
	EndIf
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + cValToChar(QRY->MOEDA)				+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"N",i) + '"><Data ss:Type="Number">'  + AllTrim(cValToChar(QRY->VLPREV))	+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + QRY->PROPOSTA						+ '</Data></Cell>'
	cXML += '    <Cell ss:StyleID="' + DePara(0,"S",i) + '"><Data ss:Type="String">'  + CharXML(QRY->SOCIO)					+ '</Data></Cell>'
	cXML += '   </Row>'
	i++
	QRY->(DbSkip())
	
	If Len(cXML) >= 1000000		//Proximo a 1Mega
		cXML := GrvXML(cXML)
	EndIf
EndDo

cXML := GrvXML(cXML)
Return NIL

*-----------------------------*
Static Function CharXML(cData)
*-----------------------------*                         
Local i
Local aChar := {{"&","&amp;"},;
				{'Á','&Aacute;'},{'á','&aacute;'},{'Â','&Acirc;'} ,{'â','&acirc;'} ,{'À','&Agrave;'},{'à','&agrave;'},;
				{'Å','&Aring;'} ,{'å','&aring;'} ,{'Ã','&Atilde;'},{'ã','&atilde;'},{'Ä','&Auml;'}  ,{'ä','&auml;'}  ,;
				{'Æ','&AElig;'} ,{'æ','&aelig;'} ,{'É','&Eacute;'},{'é','&eacute;'},{'Ê','&Ecirc;'} ,{'ê','&ecirc;'} ,;
				{'È','&Egrave;'},{'è','&egrave;'},{'Ë','&Euml;'}  ,{'ë','&euml;'}  ,{'Ð','&ETH;'}   ,{'ð','&eth;'}   ,;
				{'Í','&Iacute;'},{'í','&iacute;'},{'Î','&Icirc;'} ,{'î','&icirc;'} ,{'Ì','&Igrave;'},{'ì','&igrave;'},;
				{'Ï','&Iuml;'}  ,{'ï','&iuml;'}  ,{'Ó','&Oacute;'},{'ó','&oacute;'},{'Ô','&Ocirc;'} ,{'ô','&ocirc;'} ,;
				{'Ò','&Ograve;'},{'ò','&ograve;'},{'Ø','&Oslash;'},{'ø','&oslash;'},{'Õ','&Otilde;'},{'õ','&otilde;'},;
				{'Ö','&Ouml;'}  ,{'ö','&ouml;'}  ,{'Ú','&Uacute;'},{'ú','&uacute;'},{'Û','&Ucirc;'} ,{'û','&ucirc;'} ,;
				{'Ù','&Ugrave;'},{'ù','&ugrave;'},{'Ü','&Uuml;'}  ,{'ü','&uuml;'}  ,{'Ç','&Ccedil;'},{'ç','&ccedil;'},;
				{'Ñ','&Ntilde;'},{'ñ','&ntilde;'},{'Ý','&Yacute;'},{'ý','&yacute;'},{'"','&quot;'}  ,{'<','&lt;'}    ,;
				{'>','&gt;'}    ,{'®','&reg;'}   ,{'©','&copy;'}  ,{'Þ','&THORN;'} ,{'þ','&thorn;'} ,{'ß','&szlig;'}	}

For i := 1 To Len(aChar)
	cData := STRTRAN(cData,aChar[i][1],aChar[i][2])
Next i

Return ALLTRIM(cData)

*---------------------------*
Static Function GrvXML(cMsg)
*---------------------------*
Local nHdl

If !File(cDest+cArq)
	nHdl := FCreate(cDest+cArq,0 )  	//Criação do Arquivo.
Else
	nHdl := FOpen(cDest+cArq)			//Abertura do Arquivo.
EndIf

FSeek(nHdl,0,2)
FWrite(nHdl, cMsg )
FClose(nHdl)

Return ""

*-------------------------------------*
Static Function DePara(nTipo,cCampo,i)
*-------------------------------------*
Local xRet

Do Case
	Case nTipo == 0	//Tratamento de tipo de celula
		/*******************************************************************************/
		/* Tratamento para definir cor da linha, mantendo o tipo de conteudo da celula */
		/*******************************************************************************/
		If cCampo == "S"		// String
			xRet :=  If(i % 2 == 0,"Linha1","Linha2")
		ElseIf cCampo == "D"	// Data
			xRet :=  If(i % 2 == 0,"Linha3","Linha4")
		ElseIf cCampo == "N"	// Numero com casas decimais
			xRet :=  If(i % 2 == 0,"Linha5","Linha6")
		ElseIf cCampo == "I"	// Numero inteiro
			xRet :=  If(i % 2 == 0,"Linha7","Linha8")
		EndIf
	
End Case

Return xRet

*--------------------------------*
Static Function GeraRegs(cEmpresa)
*--------------------------------*
Local cQuery := ""

cQuery += " select '" + cEmpresa + "' as [Empresa], "
cQuery += "        CNF_FILIAL as Filial, "
cQuery += "        CNF_CONTRA as Contrato, "
cQuery += "        CN9_CLIENT as [CODCLIENTE], "
cQuery += "    CN9_LOJACL as [LOJACLI], "
cQuery += "    RTRIM(SA1.A1_NOME) as Cliente, "
cQuery += "    CNF_PARCEL as Parcela, "
cQuery += "    CNF_COMPET as Competencia, "
//cQuery += "    Convert(varchar,Convert(Date,CNF_PRUMED),103) as [DTPREVMED], "
//cQuery += "    Convert(varchar,Convert(Date,CNF_DTVENC),103) as [DTVENC], "
cQuery += "    CONVERT(VARCHAR(10),CONVERT(DateTime, CNF_PRUMED,103),126) as [DTPREVMED], "
cQuery += "    CONVERT(VARCHAR(10),CONVERT(DateTime, CNF_DTVENC,103),126) as [DTVENC], "
cQuery += "    CN9_MOEDA as [MOEDA], "
cQuery += "    CNF_VLPREV as [VLPREV], "
cQuery += "    CN9_P_NUM as [Proposta], "
cQuery += "    Z55.NOMESOC as [Socio] "
cQuery += " from CNF" + cEmpresa + "0 CNF "
cQuery += " left join CN9" + cEmpresa + "0 CN9 on CN9_NUMERO = CNF_CONTRA "
cQuery += "                     and CN9_FILIAL = CNF_FILIAL "
cQuery += " and CN9_REVISA = CNF_REVISA "
cQuery += " and CN9_SITUAC = '05' "
cQuery += " left join SA1" + cEmpresa + "0 SA1 on A1_COD = CN9_CLIENT "
cQuery += "                     and A1_LOJA = CN9_LOJACL "
cQuery += " left join TOTVS_PROP_COMPLETA Z55 on Z55_NUM = CN9_P_NUM "
cQuery += "                     and M0_CODFIL = CN9_FILIAL "
cQuery += " and M0_CODIGO = '" + cEmpresa + "' "
cQuery += " where CNF.D_E_L_E_T_ <> '*' "
cQuery += "   and CN9.D_E_L_E_T_ <> '*' "
cQuery += "   and SA1.D_E_L_E_T_ <> '*' "
cQuery += "   and CNF_DTREAL = '' "
cQuery += " order by CNF_FILIAL,CNF_CONTRA,CNF_PARCEL "

If Select("QRY") # 0
	QRY->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
//TCSetField("QRY","DTPREVMED","D")
//TCSetField("QRY","DTVENC","D")

Return !(QRY->(Bof()) .AND. QRY->(Eof()))
