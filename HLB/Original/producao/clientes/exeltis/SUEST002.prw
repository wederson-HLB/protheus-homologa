#Include "PROTHEUS.CH"

/*
Funcao      : SUEST002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina para fracionar etiquetas de caixas fechadas
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*-------------------------*
 User Function SUEST002()
*-------------------------*
	Local oBtnConf
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local _nOpc := 0
	Local oPrtImp
	Local cPrtImp := "LPT2"
	Private oDtValid
	Private oEtiqueta
	Private oLote
	Private oLtFor
	Private oProduto
	Private oQtd
	Private dDtValid	:= Date()
	Private cEtiqueta	:= Space(100)
	Private cLote		:= ""
	Private cLtFor	:= ""
	Private cProduto	:= ""
	Private cCodPro	:= ""
	Private nQtd := 0
	Static oDlg
	
	DEFINE MSDIALOG oDlg TITLE "Fracionamento - Abertura de Caixa" FROM 000, 000  TO 220, 420 COLORS 0, 16777215 PIXEL
	
	@ 005, 005 SAY oSay1 PROMPT "Etiqueta" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 015, 005 MSGET oEtiqueta VAR cEtiqueta SIZE 150, 010 OF oDlg COLORS 0, 16777215 ON CHANGE bValEtiq() PIXEL
	
	@ 035, 005 SAY oSay2 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 042, 005 MSGET oProduto VAR cProduto SIZE 200, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	
	@ 060, 005 SAY oSay3 PROMPT "Lote" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 005 MSGET oLote VAR cLote SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	
	@ 060, 075 SAY oSay5 PROMPT "Lote Fornecedor" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 075 MSGET oLtFor VAR cLtFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	
	@ 060, 145 SAY oSay6 PROMPT "Dt. Validade" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 067, 145 MSGET oDtValid VAR dDtValid SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	
	@ 082, 005 SAY oSay4 PROMPT "Quantidade" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, 005 MSGET oQtd VAR nQtd SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 READONLY PIXEL
	
	@ 082, 075 SAY oSay7 PROMPT "Porta Impr." SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, 075 MSCOMBOBOX oPrtImp VAR cPrtImp ITEMS {"LPT1","LPT2","LPT3","LPT4"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	
	DEFINE SBUTTON oBtnConf FROM 090, 165 TYPE 01 OF oDlg ENABLE ACTION (_nOpc := 1, oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If _nOpc == 1
		U_SUGEN002(cPrtImp, nQtd,DToC(dDtValid),cLtFor,SB1->B1_DESC,ZX1->ZX1_CODETI)
	EndIf
	
Return

Static Function bValEtiq
	Local _lRet := .T.
	Local _cAux := cEtiqueta
	Local _nPos := 0
	Local _cEtiq := ""
	cEtiqueta := Upper(cEtiqueta)
	If Len(_cAux) > 10
		If (_nPos := At("-",_cAux)) > 0
			_cEtiq := SubStr(_cAux,1,_nPos-1)
			_cAux := SubStr(_cAux,_nPos+1)
		EndIf
		If (_nPos := At("-",_cAux)) > 0
			nQtd := Val(SubStr(_cAux,1,_nPos-1))
		EndIf
	EndIf
	ZX1->(dbSetOrder(1))
	If ZX1->(dbSeek(xFilial()+_cEtiq))
		dDtValid	:= ZX1->ZX1_DTVAL
		cLote		:= ZX1->ZX1_LOTECT
		cLtFor		:= ZX1->ZX1_LOTEFO
		cCodPro	:= ZX1->ZX1_PRODUT
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial()+cCodPro))
			cProduto := AllTrim(SB1->B1_COD)+"-"+SB1->B1_DESC
		EndIf
	Else
		_lRet := .F.
		MsgStop("Etiqueta Inválida")
	EndIf
	oDtValid:Refresh()
	oEtiqueta:Refresh()
	oLote:Refresh()
	oLtFor:Refresh()
	oProduto:Refresh()
	oQtd:Refresh()
Return(_lRet)
