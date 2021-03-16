#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
Funcao      : SUEST005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de etiquetas
Autor       : Consultoria Totvs
Data/Hora   : 17/09/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 17/09/2014
Módulo      : Estoque.
Cliente     : Exeltis
*/

*-------------------------*
 User Function SUEST005
*-------------------------*
	Private oLote
	Private cLote := Space(Len(SB8->B8_LOTECTL))
	Private oProd
	Private oQtd
	Private nQtd := 0
	Private oTpEtiq
	Private nTpEtiq := 0
	Private oDesc
	Private cDesc := ""
	Private cProd := Space(Len(SB1->B1_COD))
	Private oPorta
	Private cPorta := "LPT2"
	
	Static oDlg
	
	DEFINE MSDIALOG oDlg TITLE "Etiquetas Avulsas" FROM 000, 000  TO 120, 530 COLORS 0, 16777215 PIXEL
	@ 005, 005 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 012, 005 MSGET oProd VAR cProd SIZE 050, 010 OF oDlg VALID bValProd() COLORS 0, 16777215 F3 "SB1" PIXEL
	@ 012, 060 MSGET oDesc VAR cDesc SIZE 200, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 030, 005 SAY oSay2 PROMPT "Lote" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 005 MSGET oLote VAR cLote SIZE 050, 010 OF oDlg VALID bValLote() COLORS 0, 16777215 PIXEL
	@ 030, 060 SAY oSay3 PROMPT "Tipo Etiqueta" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 060 RADIO oTpEtiq VAR nTpEtiq ITEMS "Caixa","Fracionada" SIZE 045, 023 OF oDlg COLOR 0, 16777215 PIXEL
	@ 030, 115 SAY oSay4 PROMPT "Quantidade" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 115 MSGET oQtd VAR nQtd SIZE 050, 010 OF oDlg PICTURE "@E 999999" COLORS 0, 16777215 PIXEL
	@ 030, 170 SAY oSay5 PROMPT "Porta" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 170 MSCOMBOBOX oPorta VAR cPorta ITEMS {"LPT1","LPT2","LPT3","LPT4"} SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 037, 230 TYPE 01 OF oDlg  ENABLE ACTION IIF(bOk(),oDlg:End(),oProd:SetFocus())
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return   

*-------------------------*
 Static Function bOk() 
*-------------------------*
	Local _lRet := .T.
	If Len(AllTrim(cProd)) <= 0 .OR. nQtd <= 0 .OR. Len(AllTrim(cLote)) <= 0 .OR.  nTpEtiq <= 0
		MsgStop("Preencha todos os campos corretamente.")
		Return(.F.)
	EndIf
	Begin Transaction
		bGetZX1()
		If nTpEtiq == 1
			For _I := 1 To nQtd
				U_SUGEN001(cPorta, "",AllTrim(Str(SB1->B1_CONV)),SB1->B1_UM,"",DToC(ZX1->ZX1_DTVAL),cProd,cLote,SB1->B1_DESC,ZX1->ZX1_CODETI)
			Next _I
		Else
			U_SUGEN002(cPorta, nQtd,DToC(ZX1->ZX1_DTVAL),cLote,SB1->B1_DESC,ZX1->ZX1_CODETI)
		EndIf
	End Transaction
	
Return(_lRet)

*-------------------------------*
 Static Function bValProd()
*-------------------------------*
	Local _lRet := .T.
	SB1->(dbSetOrder(1))
	If _lRet := SB1->(dbSeek(xFilial()+cProd))
		cDesc := SB1->B1_DESC
	Else
		MsgStop("Produto inválido.")
		cDesc := ""
	EndIf
	cLote := Space(Len(SB8->B8_LOTECTL))
	nQtd := 0
	nTpEtiq := 0
	oTpEtiq:Refresh()
	oDesc:Refresh()
	oLote:Refresh()
	oProd:Refresh()
	oQtd:Refresh()
Return(_lRet)

*-------------------------------*
 Static Function bValLote
*-------------------------------*
	Local _lRet := .T.
	SB8->(dbSetOrder(5))
	If !(_lRet := SB8->(dbSeek(xFilial()+cProd+cLote)))
		MsgStop("Lote inválido.")
	EndIf
Return(_lRet)

*---------------------------*
 Static Function bGetZX1()
*---------------------------*
	RecLock("ZX1",.T.)
	ZX1->ZX1_FILIAL := xFilial("ZX1")
	ZX1->ZX1_CODETI := GetSXENum("ZX1","ZX1_CODETI",,1)
	ZX1->ZX1_DOC    := "IMPAVULSO"
	ZX1->ZX1_SERIE  := ""
	ZX1->ZX1_FORNEC := ""
	ZX1->ZX1_LOJA   := ""
	ZX1->ZX1_ITEM   := ""
	ZX1->ZX1_PRODUT := cProd
	ZX1->ZX1_LOTECT := cLote
	ZX1->ZX1_LOTEFO := cLote
	ZX1->ZX1_DTVAL  := SB8->B8_DTVALID
	ZX1->(MsUnLock())
	ConfirmSX8()
Return


