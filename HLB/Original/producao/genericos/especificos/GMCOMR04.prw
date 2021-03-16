//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} GMCOMR04
Relat�rio - Relatorio conferencia cega    
@author zReport
@since 17/08/2017
@version 1.0
@example
u_GMCOMR04()
@obs Fun��o gerada pelo zReport()
/*/

User Function GMCOMR04(cInChave)
	Local aArea   		:= GetArea()
	Local oReport
	Local lEmail  		:= .F.
	Local cPara   		:= ""
	Local lContinua		:= .F.
	Local cChvSF1		:= ""
	Default cInChave	:=Iif(Select("SF1") > 0,SF1->F1_CHVNFE,"") 
	Private cPerg 		:= ""

	U_DbSelArea("CONDORXML",.F.,1)
	If DbSeek(cInChave)
		If CONDORXML->XML_DEST == SM0->M0_CGC
			lContinua	:= .T.
			cChvSF1		:= CONDORXML->XML_KEYF1
		Else
			MsgAlert("Nota n�o pertence a empresa atual.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
	Else
		lContinua	:= MsgYesNo("Nota fiscal n�o encontrada na Central XML. Deseja imprimir mesmo assim?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		cChvSF1		:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
	Endif

	If lContinua
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(cChvSF1)
			If (Empty(SF1->F1_STATUS) .Or. (SF1->F1_STATUS == "B" .And. SuperGetMV("MV_RESTCLA",.F.,"2")=="2"))
				//Cria as defini��es do relat�rio
				oReport := fReportDef()

				//Ser� enviado por e-Mail?
				If lEmail
					oReport:nRemoteType := NO_REMOTE
					oReport:cEmail := cPara
					oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
					oReport:SetPreview(.F.)
					oReport:Print(.F., "", .T.)
					//Sen�o, mostra a tela
				Else
					oReport:PrintDialog()
				EndIf
			Else
				MsgAlert("Nota n�o est� apta para recebimento. Verifique se j� foi classificada ou est� bloqueada!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Endif
		Else
			MsgAlert("Nota n�o lan�ada",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif

	Endif


	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
| Func:  fReportDef                                                             |
| Desc:  Fun��o que monta a defini��o do relat�rio                              |
*-------------------------------------------------------------------------------*/

Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil

	//Cria��o do componente de impress�o
	oReport := TReport():New(	"GMCOMR04",;		//Nome do Relat�rio
	"Relat�rio Confer�ncia Cega",;		//T�tulo
	cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
	{|oReport| fRepPrint(oReport)},;		//Bloco de c�digo que ser� executado na confirma��o da impress�o
	)		//Descri��o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()

	//Criando a se��o de dados
	oSectCab := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
	"Cabe�alho",;		//Descri��o da se��o
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o

	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
	"Dados",;		//Descri��o da se��o
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Colunas do relat�rio
	TRCell():New(oSectCab, "F1_PLACA", "QRY_AUX", "Placa", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectCab, "F1_FORNECE", "QRY_AUX", "Fornecedor", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectCab, "F1_LOJA", "QRY_AUX", "Loja", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectCab, "A2_NOME", "QRY_AUX", "Raz�o Social", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectCab, "F1_DOC", "QRY_AUX", "N�mero", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectCab, "F1_SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "D1_COD", "QRY_AUX", "Produto", /*Picture*/, 15,.T. /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 55, .T./*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A5_XUNID", "QRY_AUX", "Unid Med.XML", /*Picture*/, 15,.T. /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A5_CODPRF", "QRY_AUX", "Cod.Prod.For", /*Picture*/, 32,.T. /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1QUANT", "QRY_AUX", "Quantidade", /*Picture*/, 15, .T./*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A5_XCONV", "QRY_AUX", "Conv.Unid Me", /*Picture*/, 15,.T. /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D1_LOTEFOR", "QRY_AUX", "Lote Fornec.", /*Picture*/, 18,.T. /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport

/*-------------------------------------------------------------------------------*
| Func:  fRepPrint                                                              |
| Desc:  Fun��o que imprime o relat�rio                                         |
*-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0

	//Pegando as se��es do relat�rio
	oSectCab := oReport:Section(1)
	oSectDad := oReport:Section(2)

	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT F1_PLACA,"		+ STR_PULA
	cQryAux += "       F1.F1_FORNECE,"		+ STR_PULA
	cQryAux += "       F1.F1_LOJA,"		+ STR_PULA
	cQryAux += "       A2_NOME,"		+ STR_PULA
	cQryAux += "       F1_DOC,"		+ STR_PULA
	cQryAux += "       F1_SERIE,"		+ STR_PULA
	cQryAux += "       D1_COD,"		+ STR_PULA
	cQryAux += "       B1_DESC,"		+ STR_PULA
	cQryAux += "       ' ' D1QUANT,"		+ STR_PULA
	cQryAux += "       COALESCE(A5.A5_CODPRF, ' ') A5_CODPRF,"		+ STR_PULA
	cQryAux += "       COALESCE(A5.A5_XUNID,' ') A5_XUNID,"		+ STR_PULA
	cQryAux += "       COALESCE(A5_XCONV,0) A5_XCONV,"		+ STR_PULA
	cQryAux += "       COALESCE(A5_XTPCONV,' ') A5_XTPCONV,"		+ STR_PULA
	cQryAux += "       D1.D1_LOTEFOR"		+ STR_PULA
	cQryAux += "  FROM "+RetSqlName("SF1")+" F1"		+ STR_PULA
	cQryAux += " INNER JOIN "+RetSqlName("SA2")+" A2"		+ STR_PULA
	cQryAux += "    ON A2_LOJA = F1_LOJA"		+ STR_PULA
	cQryAux += "   AND A2_COD = F1_FORNECE"		+ STR_PULA
	cQryAux += "   AND A2_FILIAL = '"+xFilial("SA2")+"'"		+ STR_PULA
	cQryAux += " INNER JOIN "+RetSqlName("SD1")+" D1"		+ STR_PULA
	cQryAux += "    ON D1_FORNECE = F1_FORNECE"		+ STR_PULA
	cQryAux += "   AND D1_LOJA = F1_LOJA"		+ STR_PULA
	cQryAux += "   AND D1_DOC = F1_DOC"		+ STR_PULA
	cQryAux += "   AND D1_SERIE = F1_SERIE"		+ STR_PULA
	cQryAux += "   AND D1_FILIAL = '"+xFilial("SD1")+"'"		+ STR_PULA
	cQryAux += " INNER JOIN "+RetSqlName("SB1")+" B1"		+ STR_PULA
	cQryAux += "    ON B1_COD = D1_COD"		+ STR_PULA
	cQryAux += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"		+ STR_PULA
	// Posiciona na SA5 mesmo se n�o tiver registro 
	cQryAux += " RIGHT JOIN "+RetSqlName("SA5")+" A5"		+ STR_PULA
	cQryAux += "    ON A5_PRODUTO = D1_COD"		+ STR_PULA
	cQryAux += "   AND A5_FORNECE = F1_FORNECE"		+ STR_PULA
	cQryAux += "   AND A5_LOJA = F1_LOJA"		+ STR_PULA
	cQryAux += "   AND A5_FILIAL = '"+xFilial("SA5")+"'"		+ STR_PULA
	cQryAux += "   AND A5.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += " WHERE F1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "   AND D1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "   AND B1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "   AND A2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "   AND F1_FILIAL = '"+SF1->F1_FILIAL+"'"		+ STR_PULA
	cQryAux += "   AND F1_DTDIGIT = '"+ DTOS(SF1->F1_DTDIGIT) + "'"		+ STR_PULA
	cQryAux += "   AND F1_DOC = '"+SF1->F1_DOC+"'"		+ STR_PULA
	cQryAux += "   AND F1_SERIE = '"+SF1->F1_SERIE+"'"		+ STR_PULA
	cQryAux += "   AND F1_LOJA = '"+SF1->F1_LOJA+"'"		+ STR_PULA
	cQryAux += "   AND F1_FORNECE = '"+SF1->F1_FORNECE+"'"		+ STR_PULA
	cQryAux += " ORDER BY D1_ITEM "

	cQryAux := ChangeQuery(cQryAux)

	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)

	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())

	If !Eof()
		oSectCab:Init()
		oSectCab:PrintLine()
		oSectCab:Finish()
		oReport:ThinLine ()
	Endif

	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		//Imprimindo a linha atual		
		oSectDad:PrintLine()
		oReport:ThinLine ()
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())

	oReport:SkipLine()
	oReport:SkipLine()

	oReport:PrintText("______________________ ",oReport:Row()/*nRow*/,10/*nCol*/)
	oReport:SkipLine()
	oReport:PrintText("CONFERENTE ",oReport:Row()/*nRow*/,10/*nCol*/)

	RestArea(aArea)
Return