#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
Funcao      : SUEST001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina para Conferencia Entrada/Saida
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*-------------------------*
 User Function SUEST001()
*-------------------------*
	Private oBtnFim
	Private oBtnIni
	Private oEntidade
	Private oEtiq
	Private cEtiq := Space(100)
	Private cEntidade := Space(6)
	Private cLoja := Space(2)
	Private cNome := ""
	Private oLblEnti
	Private oLblEtiq
	Private oLoja
	Private oNf
	Private cNf := Space(9)
	Private oNome
	Private oTpconf
	Private nTpConf := 0
	Private oLblNF
	Private oLblSerie
	Private oSay1
	Private oSerie
	Private cSerie := Space(3)
	Private oPnlConf
	Private _lConfere := .F.
	Static oDlg
	
	DEFINE MSDIALOG oDlg TITLE "Conferencia" FROM 000, 000  TO 180, 500 COLORS 0, 16777215 PIXEL
	
	@ 005, 005 SAY oSay1 PROMPT "Tipo Conferencia" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 013, 005 RADIO oTpconf VAR nTpConf ITEMS "Entrada","Saida" SIZE 048, 024 OF oDlg COLOR 0, 16777215 ON CHANGE bTpConf() PIXEL
	
	@ 040, 005 SAY oLblEnti PROMPT "Fornecedor" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 005 MSGET oEntidade VAR cEntidade SIZE 050, 010 OF oDlg VALID bValEnt() COLORS 0, 16777215 F3 "SA2" HASBUTTON  PIXEL
	@ 047, 060 MSGET oLoja VAR cLoja SIZE 020, 010 OF oDlg VALID bValEnt() COLORS 0, 16777215  PIXEL
	@ 047, 085 MSGET oNome VAR cNome SIZE 160, 010 OF oDlg COLORS 0, 16777215 READONLY  PIXEL
	
	@ 062, 005 SAY oLblNF PROMPT "Nota Fiscal" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 005 MSGET oNf VAR cNf SIZE 050, 010 OF oDlg VALID bValNf() COLORS 0, 16777215  PIXEL
	
	@ 062, 060 SAY oLblSerie PROMPT "Serie" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 060 MSGET oSerie VAR cSerie SIZE 025, 010 OF oDlg VALID bValNf() COLORS 0, 16777215  PIXEL
	
	@ 067, 100 BUTTON oBtnIni PROMPT "Inicia Conferencia" SIZE 075, 012 OF oDlg ACTION bInicia() PIXEL
	
	@ 000, 001 MSPANEL oPnlConf SIZE 245, 082 OF oDlg COLORS 0, 16777215
	@ 015, 015 SAY oLblEtiq PROMPT "Etiqueta" SIZE 025, 007 OF oPnlConf COLORS 0, 16777215 PIXEL
	@ 022, 015 MSGET oEtiq VAR cEtiq SIZE 125, 010 OF oPnlConf VALID bValEtiq() COLORS 0, 16777215 PIXEL
	//@ 053, 160 BUTTON oBtnFim PROMPT "Finaliza Conferencia" SIZE 075, 012 OF oPnlConf ACTION bFim() PIXEL
	
	oLblEnti:Hide()
	oEntidade:Hide()
	oLoja:Hide()
	oNome:Hide()
	oLblNF:Hide()
	oNf:Hide()
	oLblSerie:Hide()
	oSerie:Hide()
	oBtnIni:Hide()
	
	oPnlConf:Hide()
	
	ACTIVATE MSDIALOG oDlg CENTERED VALID bFim()
Return

Static Function bInicia()
	If nTpConf == 1
		RecLock("SF1",.F.)
		SF1->F1_STATCON := "3"
		SF1->(MsUnLock())
	Else
		RecLock("SC5",.F.)
		SC5->C5_P_STACO := "2"
		SC5->(MsUnLock())
	EndIf
	_lConfere := .T.
	oPnlConf:Show()
	oEtiq:SetFocus()
Return

Static Function bFim()
	Local _lDiverg := .F.
	Local _lRet := .T.
	If _lConfere
		If MsgYesNo("Confirma Saida?")
			If MsgYesNo("Finaliza conferencia?")
				If nTpConf == 1
					SD1->(dbSetOrder(1))
					SD1->(dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
					While !SD1->(EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
						If SD1->D1_QUANT <> SD1->D1_QTDCONF
							MsgStop("Nota Fiscal com divergencia!")
							RecLock("SF1",.F.)
							SF1->F1_STATCON := "2"
							SF1->(MsUnLock())
							_lDiverg := .T.
							Exit
						EndIf
						SD1->(dbSkip())
					EndDo
					If !_lDiverg
						RecLock("SF1",.F.)
						SF1->F1_STATCON := "1"
						SF1->(MsUnLock())
					EndIf
				Else
					SC9->(dbSetOrder(1))
					SC9->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
					While !SC9->(EOF()) .AND. SC9->(C9_FILIAL+C9_PEDIDO) == SC5->(C5_FILIAL+C5_NUM)
						If SC9->C9_QTDLIB <> SC9->C9_P_QTDCO
							MsgStop("Pedido com divergencia!")
							RecLock("SC5",.F.)
							SC5->C5_P_STACO := "4"
							SC5->(MsUnLock())
							_lDiverg := .T.
							Exit
						EndIf
						SC9->(dbSkip())
					EndDo
					If !_lDiverg
						RecLock("SC5",.F.)
						SC5->C5_P_STACO := "3"
						SC5->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Else
			cEtiq := Space(100)
			oEtiq:Refresh()
			oEtiq:SetFocus()
			_lRet := .F.
		EndIf
	EndIf
Return(_lRet)

Static Function bValEtiq()
	Local _lRet := .T.
	Local _cCodEti := ""
	Local _nQtd := 0
	Local _cAux := AllTrim(Upper(cEtiq))
	Local _nPos := 0
	If Len(AllTrim(_cAux)) > 0
		If Len(_cAux) > 10
			If (_nPos := At("-",_cAux)) > 0
				_cCodEti := SubStr(_cAux,1,_nPos-1)
				_cAux := SubStr(_cAux,_nPos+1)
			EndIf
			If (_nPos := At("-",_cAux)) > 0
				_nQtd := Val(SubStr(_cAux,1,_nPos-1))
			EndIf
		Else
			_cCodEti := _cAux
			_nQtd :=  1
		EndIf
		ZX1->(dbSetOrder(1))
		If _nQtd > 0 .AND. ZX1->(dbSeek(xFilial()+_cCodEti))
			If nTpConf == 1
				SD1->(dbSetOrder(1))
				SD1->(dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
				_lContinua := .T.
				While _lContinua .AND. !SD1->(EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
					If SD1->D1_COD == ZX1->ZX1_PRODUT .AND. SD1->D1_LOTEFOR == ZX1->ZX1_LOTEFO .AND. SD1->D1_ITEM == ZX1->ZX1_ITEM
						RecLock("SD1",.F.)
						SD1->D1_QTDCONF += _nQtd
						SD1->(MsUnLock())
						RecLock("CBE",.T.)
						CBE->CBE_FILIAL	:= xFilial("CBE")
						CBE->CBE_CODETI	:= ZX1->ZX1_CODETI
						CBE->CBE_NOTA		:= SF1->F1_DOC
						CBE->CBE_SERIE	:= SF1->F1_SERIE
						CBE->CBE_FORNEC	:= SF1->F1_FORNECE
						CBE->CBE_LOJA		:= SF1->F1_LOJA
						CBE->CBE_CODPRO	:= SD1->D1_COD
						CBE->CBE_CODUSR	:= __cUserId
						CBE->CBE_DATA		:= Date()
						CBE->CBE_HORA		:= Time()
						CBE->CBE_QTDE		:= _nQtd
						CBE->CBE_LOTECT	:= ZX1->ZX1_LOTEFO
						CBE->CBE_DTVLD	:= ZX1->ZX1_DTVAL
						CBE->(MsUnLock())
						_lContinua := .F.
					EndIf
					SD1->(dbSkip())
				EndDo
			Else
				
				_cQry := " SELECT R_E_C_N_O_ RECNO"
				_cQry += " FROM "+RetSQLName("SC9")
				_cQry += " WHERE D_E_L_E_T_ = ' '"
				_cQry += " AND C9_FILIAL = '"+SC5->C5_FILIAL+"'"
				_cQry += " AND C9_PEDIDO = '"+SC5->C5_NUM+"'"
				_cQry += " AND C9_PRODUTO = '"+ZX1->ZX1_PRODUT+"'"
				_cQry += " AND C9_BLEST = ''"
				_cQry += " AND C9_BLCRED = ''"
				_cQry += " AND C9_LOTECTL = '"+ZX1->ZX1_LOTECT+"'"
				_cQry += " ORDER BY R_E_C_N_O_"
				TcQuery _cQry New Alias "QPED"
				While !QPED->(EOF()) .AND. _nQtd > 0
					SC9->(dbGoTo(QPED->RECNO))
					If SC9->C9_FILIAL == SC5->C5_FILIAL .AND. SC9->C9_PEDIDO == SC5->C5_NUM .AND.SC9->C9_PRODUTO == ZX1->ZX1_PRODUT .AND. SC9->C9_LOTECTL == ZX1->ZX1_LOTECT
						RecLock("SC9",.F.)
						If (SC9->C9_QTDLIB-SC9->C9_P_QTDCO) >=_nQtd
							SC9->C9_P_QTDCO += _nQtd
							_nQtd := 0
						Else
							_nQtd -= SC9->C9_QTDLIB-SC9->C9_P_QTDCO
							SC9->C9_P_QTDCO := SC9->C9_QTDLIB
						EndIf
						SC9->(MsUnLock())
					EndIf
					QPED->(dbSkip())
				EndDo
				If _nQtd > 0.AND. SC9->C9_FILIAL == SC5->C5_FILIAL .AND. SC9->C9_PEDIDO == SC5->C5_NUM .AND.SC9->C9_PRODUTO == ZX1->ZX1_PRODUT .AND. SC9->C9_LOTECTL == ZX1->ZX1_LOTECT
					RecLock("SC9",.F.)
					SC9->C9_P_QTDCO += _nQtd
					SC9->(MsUnLock())
				EndIf
				QPED->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	cEtiq := Space(100)
	oEtiq:Refresh()
	oEtiq:SetFocus()
Return(_lRet)

Static Function bTpConf()
	If nTpConf == 1
		cNf := Space(9)
		oLblSerie:Show()
		oSerie:Show()
		oLblEnti:SetText("Fornecedor")
		oLblNF:SetText("Nota Fiscal")
		oEntidade:cF3 := "SA2"
	Else
		oLblSerie:Hide()
		oSerie:Hide()
		cNf := Space(6)
		oLblEnti:SetText("Cliente")
		oLblNF:SetText("Pedido")
		oEntidade:cF3 := "SA1"
	EndIf
	oBtnIni:Hide()
	cEntidade := Space(6)
	cLoja := Space(2)
	cNome := ""
	cSerie := Space(3)
	oLblEnti:Show()
	oEntidade:Show()
	oLoja:Show()
	oNome:Show()
	oLblNF:Show()
	oNf:Show()
	oEntidade:Refresh()
	oLoja:Refresh()
	oNome:Refresh()
	oNf:Refresh()
	oSerie:Refresh()
Return


Static Function bValEnt()
	Local _lRet := .T.
	oBtnIni:Hide()
	If nTpConf == 1
		SA2->(dbSetOrder(1))
		If _lRet := ( (SA2->A2_COD == cEntidade .AND. Len(AllTrim(cLoja)) <= 0) .OR.  SA2->(dbSeek(xFilial()+cEntidade+AllTrim(cLoja))))
			cLoja := SA2->A2_LOJA
			cNome := SA2->A2_NOME
		Else
			MsgStop("Fornecedor inválido.")
		EndIf
	Else
		SA1->(dbSetOrder(1))
		If _lRet := ( (SA1->A1_COD == cEntidade .AND. Len(AllTrim(cLoja)) <= 0) .OR.  SA1->(dbSeek(xFilial()+cEntidade+AllTrim(cLoja))))
			cLoja := SA1->A1_LOJA
			cNome := SA1->A1_NOME
		Else
			MsgStop("Cliente inválido.")
		EndIf
	EndIf
	If !_lRet
		cNome := ""
	EndIf
	cNf := Space(9)
	cSerie := Space(3)
	oNf:Refresh()
	oSerie:Refresh()
	oEntidade:Refresh()
	oLoja:Refresh()
	oNome:Refresh()
Return(_lRet)

Static Function bValNf()
	Local _lRet := .T.
	oBtnIni:Hide()
	If Len(AllTrim(cNF)) > 0 .AND. IIf(nTpConf == 1,Len(AllTrim(cSerie)) > 0,.T.)
		If nTpConf == 1
			SF1->(dbSetOrder(1))
			If _lRet := SF1->(dbSeek(xFilial()+cNF+cSerie+cEntidade+cLoja))
				Do Case
				Case SF1->F1_STATCON $ "1 "
					MsgStop("Nota Fiscal já conferida.")
					_lRet := .F.
				Case SF1->F1_STATCON == "2"
					MsgStop("Nota fiscal já conferida, porém com divergencias.")
					_lRet := .F.
				Case SF1->F1_STATCON == "3"
					_lRet:= MsgYesNo("Nota Fiscal em processo de conferencia. Deseja continuar com a conferencia?")
				EndCase
			Else
				MsgStop("Nota Fiscal inválida.")
			EndIf
		Else
			SC5->(dbSetOrder(1))
			If _lRet := SC5->(dbSeek(xFilial()+cNF))
				Do Case
				Case SC5->C5_P_STACO $ "3 "
					MsgStop("Pedido já conferido.")
					_lRet := .F.
				Case SC5->C5_P_STACO == "4"
					If _lRet := MsgYesNo("Nota fiscal já conferida, porém com divergencias. Deseja reconferir?")
						bLimpCnf("PED")
					EndIf
				Case SC5->C5_P_STACO == "2"
					_lRet:= MsgYesNo("Pedido processo de conferencia. Deseja continuar com a conferencia?")
				EndCase
			Else
				MsgStop("Nota Fiscal inválida.")
			EndIf
		EndIf
		If _lRet
			oBtnIni:Show()
		EndIf
	EndIf
Return(_lRet)

Static Function bLimpCnf(_cTp)
	If _cTp == "PED"
		If SC5->(dbSeek(xFilial()+cNf))
			RecLock("SC5",.F.)
			SC5->C5_P_STACO := "1"
			SC5->(MsUnLock())
			If SC9->(dbSeek(xFilial()+SC5->C5_NUM))
				While !SC9->(EOF()) .AND. SC9->C9_FILIAL = SC5->C5_FILIAL .AND. SC9->C9_PEDIDO = SC5->C5_NUM
					If Len(AllTrim(SC9->C9_BLEST)) <= 0 .AND. Len(AllTrim(SC9->C9_BLCRED)) <= 0
						RecLock("SC9",.F.)
						SC9->C9_P_QTDCO := 0
						SC9->(MsUnLock())
					EndIf
					SC9->(dbSkip())
				EndDo
			EndIf
		EndIf
	Else
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		While !SD1->(EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			RecLock("SD1",.F.)
			SD1->D1_QTDCONF := 0
			SD1->(MsUnLock())
			SD1->(dbSkip())
		EndDo
		
		Reclock("SF1",.F.)
		SF1->F1_STATCON := "0"
		SF1->(msUnlock())
		
		CBE->(dbsetOrder(2))
		CBE->(dbSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While !CBE->(eof()) .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
				CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA
			If RecLock("CBE",.F.)
				CBE->(dbDelete())
				CBE->(MsUnlock())
			EndIf
			CBE->(dbSkip())
		EndDo
	EndIf
Return
