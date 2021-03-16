//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} GMCOMR05
//Relatório de auditoria Central XML
@author Marcelo Alberto Lauschner
@since 17/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function GMCOMR05()

	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := "GMCOMR05"
	 
	ValidPerg("GMCOMR05")

	//Cria as definições do relatório
	oReport := fReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail 		:= cPara
		oReport:nDevice 	:= 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
| Func:  fReportDef                                                             |
| Desc:  Função que monta a definição do relatório                              |
*-------------------------------------------------------------------------------*/

Static Function fReportDef()
	
	Local oReport
	Local oSectDad 	:= Nil
	Local oSectPrd	:= Nil
	Local oSectMot	:= Nil 
	Local oBreak 	:= Nil
	
	Pergunte(cPerg,.T.)
	
	//Criação do componente de impressão
	oReport := TReport():New(	"GMCOMR05",;		//Nome do Relatório
	"Relatorio Auditoria Central XM",;		//Título
	cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
	{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
	)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .T.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetLineHeight(60)
	oReport:nFontBody := 11

	oSectMot := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Motivo",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectMot:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	oSectPrd := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Produto",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectPrd:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Dados",;		//Descrição da seção
	{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectMot, "XLG_CODMOT"	, "QRY_AUX"	, "Cód.Motivo"		, /*Picture*/, 4, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectMot, "XBL_DESMOT"	, "QRY_AUX"	, "Descrição Motivo", /*Picture*/, 120, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectPrd, "XLG_CODPRD"	, "QRY_AUX"	, "Produto"			, /*Picture*/, 15, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectPrd, "B1_DESC"	, 			, "Descrição"		, /*Picture*/, TamSX3("B1_DESC")[1], /*lPixel*/,{|| SB1->B1_DESC },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectDad, "XLGCHAVE"	, 			, "Chave NFe/Cte"	, /*Picture*/, 44, .T. /*lPixel*/	,{|| QRY_AUX->XLG_CHAVE },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_DATA"	, 			, "Data Evento"		, /*Picture*/, 11, .T./*lPixel*/	,{|| CONDORLOGBLQ->XLG_DATA},/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_HORA"	, 			, "Hora Evento"		, /*Picture*/, 8, .T. /*lPixel*/	,{|| CONDORLOGBLQ->XLG_HORA},/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_USER"	, "QRY_AUX"	, "Usuário"			, /*Picture*/, 15, .T./*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_CPOALT"	, "QRY_AUX"	, "Campo Validado"	, /*Picture*/, 10, .T. /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_VLANTI"	, 			, "Valor Antigo"	, /*Picture*/, 18, /*lPixel*/		,{|| CONDORLOGBLQ->XLG_VLANTI},/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XLG_VLNEW"	, 			, "Valor Novo"		, /*Picture*/, 18, /*lPixel*/		,{|| CONDORLOGBLQ->XLG_VLNEW },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	
Return oReport

/*-------------------------------------------------------------------------------*
| Func:  fRepPrint                                                              |
| Desc:  Função que imprime o relatório                                         |
*-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
	
	Local aArea    	:= GetArea()
	Local cQryAux  	:= ""
	Local oSectDad 	:= Nil
	Local oSectPrd 	:= Nil
	Local oSetcMot	:= Nil
	Local nAtual   	:= 0
	Local nTotal   	:= 0
	Local cMot		:= ""
	Local cPrd		:= ""

	//Pegando as seções do relatório
	oSectMot := oReport:Section(1)
	oSectPrd := oReport:Section(2)
	oSectDad := oReport:Section(3)
	
	U_DbSelArea("CONDORLOGBLQ",.F.,1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT XLG_CHAVE,XLG_CODMOT,BLQ.XBL_DESMOT,XLG_INFO,XLG_DATA,XLG_HORA,XLG_USER,"+ STR_PULA
	cQryAux += "       XLG_EMAIL,XLG_CPOALT,XLG_CODPRD,LOG.R_E_C_N_O_ XLGRECNO "		+ STR_PULA
	cQryAux += "  FROM CONDORLOGBLQ LOG,CONDORXML CXM ,CONDORBLQAUTO BLQ"		+ STR_PULA
	cQryAux += " WHERE XLG_CHAVE = XML_CHAVE"		+ STR_PULA
	cQryAux += "   AND XLG_CODMOT = BLQ.XBL_CODMOT"		+ STR_PULA
	cQryAux += "   AND CXM.XML_DEST = '"+SM0->M0_CGC+"'"		+ STR_PULA
	cQryAux += "   AND XLG_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"		+ STR_PULA
	cQryAux += "   AND XLG_CODMOT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"		+ STR_PULA
	cQryAux += "   AND XLG_CODPRD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"		+ STR_PULA
	cQryAux += " ORDER BY XLG_CODMOT,XLG_CODPRD"
	cQryAux := ChangeQuery(cQryAux)

	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)

	//Enquanto houver dados
	
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		If cMot <> QRY_AUX->XLG_CODMOT 
	
			If !Empty(cMot)
				oSectDad:Finish()
				oSectPrd:Finish()
				oSectMot:Finish()
				oReport:ThinLine ()
			Endif
			
			
			oSectMot:Init()
			oSectPrd:Init()
			oSectDad:Init()
			
			oSectMot:PrintLine()
			
			If Empty(cPrd)
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+QRY_AUX->XLG_CODPRD)
				oSectPrd:PrintLine()
			Endif
		ElseIf cPrd <> QRY_AUX->XLG_CODPRD
			
			oSectDad:Finish()
			oSectPrd:Finish()								
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+QRY_AUX->XLG_CODPRD)
				
			oSectPrd:Init()
			oSectPrd:PrintLine()
			
			oSectDad:Init()
		Endif
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		CONDORLOGBLQ->(DbGoto(QRY_AUX->XLGRECNO))
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		cPrd	:= QRY_AUX->XLG_CODPRD
		cMot	:= QRY_AUX->XLG_CODMOT
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	oSectPrd:Finish()
	QRY_AUX->(DbCloseArea())

	RestArea(aArea)
Return




/*/{Protheus.doc} ValidPerg
///Cria as perguntas na SX1 
@author Marcelo Alberto Lauschner
@since 17/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ValidPerg()

	Local	aSx1Cab		:= {"X1_GRUPO",;	//1
							"X1_ORDEM",;	//2
							"X1_PERGUNT",;	//3	
							"X1_VARIAVL",;	//4
							"X1_TIPO",;		//5
							"X1_TAMANHO",;	//6
							"X1_DECIMAL",;	//7
							"X1_PRESEL",;	//8
							"X1_GSC",;		//9
							"X1_VAR01",;	//10	
							"X1_F3"}		//11
							
	Local	aSX1Resp	:= {}
	
	Aadd(aSX1Resp,{	cPerg,;					//1
					'01',;					//2
					'Motivo De?',;			//3
					'mv_ch1',;				//4
					'C',;					//5
					2,;						//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par01',;			//10
					''})					//11
	
    						
	Aadd(aSX1Resp,{	cPerg,;					//1
					'02',;					//2
					'Motivo Até?',;			//3
					'mv_ch2',;				//4
					'G',;					//5
					2,;						//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par02',;			//10
					''})					//11
	
	Aadd(aSX1Resp,{	cPerg,;					//1
					'03',;					//2
					'Data De?'	,;			//3
					'mv_ch3',;				//4
					'D',;					//5
					8,;						//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par03',;			//10
					''})					//11
	
	Aadd(aSX1Resp,{	cPerg,;					//1
					'04',;					//2
					'Data Até?'	,;			//3
					'mv_ch4',;				//4
					'D',;					//5
					8,;						//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par04',;			//10
					''})					//11
	Aadd(aSX1Resp,{	cPerg,;					//1
					'05',;					//2
					'Produto De?',;			//3
					'mv_ch5',;				//4
					'C',;					//5
					15,;					//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par05',;			//10
					''})					//11
	
    						
	Aadd(aSX1Resp,{	cPerg,;					//1
					'06',;					//2
					'Produto Até?',;		//3
					'mv_ch6',;				//4
					'G',;					//5
					15,;					//6
					0,;						//7
					0,;						//8
					'G',;					//9	
					'mv_par06',;			//10
					''})					//11
					
	// Grava Perguntas				
    U_XPUTSX1(aSx1Cab,aSX1Resp,.F./*lForceAtuSx1*/)
    
	
	
Return