#include 'totvs.ch'
#include 'topconn.ch'

/*
Funcao      : SUGEN003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/

*----------------------------*
 User Function SUGEN003
*----------------------------*
	Local _cPortImp
	Local _I := _J := 0
	Local oBtnCanc
	Local oBtnOk
	Local oDtDigit
	Local dDtDigit := Date()
	Local oFornece
	Local cFornece := ""
	Local oNF
	Local cNF := SF1->F1_DOC+"/"+SF1->F1_SERIE
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oTpImp
	Local nTpImp := 0
	Local aLbxProd := {}
	Local oPortaImp
	Local cPortaImp := "LPT2"
	Local _aEtiqFr := {}
	Private _nOpc := 0
	Static oDlgEti
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA))
	cFornece := SA2->A2_COD+"/"+SA2->A2_LOJA+"-"+SA2->A2_NOME
	
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	dDtDigit := SD1->D1_DTDIGIT
	
	DEFINE MSDIALOG oDlgEti TITLE "Impressao Etiquetas" FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL
	
	@ 005, 005 SAY oSay1 PROMPT "Nota Fiscal" SIZE 050, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	@ 015, 005 MSGET oNF VAR cNF SIZE 060, 010 OF oDlgEti COLORS 0, 16777215 READONLY PIXEL
	
	@ 030, 005 SAY oSay2 PROMPT "Fornecedor" SIZE 050, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	@ 040, 005 MSGET oFornece VAR cFornece SIZE 200, 010 OF oDlgEti COLORS 0, 16777215 READONLY PIXEL
	
	@ 005, 075 SAY oSay3 PROMPT "Data Digitação" SIZE 050, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	@ 015, 075 MSGET oDtDigit VAR dDtDigit SIZE 060, 010 OF oDlgEti COLORS 0, 16777215 READONLY PIXEL
	
	@ 057, 005 SAY oSay4 PROMPT "Itens(s)" SIZE 025, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	fLbxProd(@aLbxProd)
	
	@ 005, 235 SAY oSay5 PROMPT "Tipo Impressão" SIZE 050, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	@ 015, 235 RADIO oTpImp VAR nTpImp ITEMS "Fracionada","Embalagem" SIZE 069, 023 OF oDlgEti COLOR 0, 16777215 PIXEL
	
	@ 005, 315 SAY oSay6 PROMPT "Porta Impressora" SIZE 050, 007 OF oDlgEti COLORS 0, 16777215 PIXEL
	@ 015, 315 MSCOMBOBOX oPortaImp VAR cPortaImp ITEMS {"LPT1","LPT2","LPT3","LPT4"} SIZE 050, 010 OF oDlgEti COLORS 0, 16777215 PIXEL
	
	DEFINE SBUTTON oBtnOk FROM 225, 135 TYPE 01 OF oDlgEti ENABLE ACTION (_nOpc := 1,oDlgEti:End())
	DEFINE SBUTTON oBtnCanc FROM 225, 235 TYPE 02 OF oDlgEti ENABLE ACTION oDlgEti:End()
	
	ACTIVATE MSDIALOG oDlgEti CENTERED VALID bValDlg(aLbxProd,nTpImp,@_nOpc)
	
	If _nOpc <> 1
		Return
	EndIf
	
	_cVolume := "0000"
	For _I := 1 To Len(aLbxProd)
		If aLbxProd[_I,1]
			If nTpImp == 1 //Fracionada
				_aEtiqFr := bEtiqFr(aLbxProd[_I])
				If Len(_aEtiqFr) > 0
					U_SUGEN002(cPortaImp, bCharToVal(aLbxProd[_I,10]),_aEtiqFr[1],_aEtiqFr[2],_aEtiqFr[3],_aEtiqFr[4])
				EndIf
			Else //Embalagem
				If bCharToVal(aLbxProd[_I,11]) > 0
					If bGetZX1(aLbxProd[_I])
						For _J := 1 To bCharToVal(aLbxProd[_I,11])
							_cVolume := Soma1(_cVolume)
							U_SUGEN001(cPortaImp,;
								_cVolume,;
								AllTrim(Str(bCharToVal(aLbxProd[_I,6]))),;
								aLbxProd[_I,5],;
								aLbxProd[_I,8],;
								aLbxProd[_I,9],;
								aLbxProd[_I,3],;
								aLbxProd[_I,7],;
								aLbxProd[_I,4],;
								ZX1->ZX1_CODETI)
						Next _J
					EndIf
				EndIf
			EndIf
		Else
			//Se houver quantidade embalagem
			//Soma volume mesmo que a linha nao tenha sido selecionada
			If bCharToVal(aLbxProd[_I,11]) > 0
				For _J := 1 To bCharToVal(aLbxProd[_I,11])
					_cVolume := Soma1(_cVolume)
				Next _J
			EndIf
		EndIf
	Next _I
	
Return

Static Function bValDlg(aLbxProd,nTpImp,_nOpc)
	Local _lRet := .T.
	Local _I
	Local _lSel := .F.
	If _nOpc == 1
		If nTpImp == 0
			MsgStop("Imforme o tipo de impressão.")
			_nOpc := 0
			Return(.F.)
		EndIf
		
		For _I := 1 To Len(aLbxProd)
			If aLbxProd[_I,1]
				
				If nTpImp == 1
					If bCharToVal(aLbxProd[_I,10]) <= 0
						MsgStop("Não ha etiquetas fracionadas para serem impressar para o item "+aLbxProd[_I,2])
						_nOpc := 0
						Return(.F.)
					EndIf
				Else
					If bCharToVal(aLbxProd[_I,11]) <= 0
						MsgStop("Não ha etiquetas de embalagem para serem impressar para o item "+aLbxProd[_I,2])
						_nOpc := 0
						Return(.F.)
					EndIf
				EndIf
				
				_lSel := .T.
			EndIf
		Next _I
		
		If !_lSel
			MsgStop("Selecine pelo menos um produto.")
			_nOpc := 0
			Return(.F.)
		EndIf
	EndIf
Return(_lRet)

Static Function fLbxProd(aLbxProd)
	Local _cQry := ""
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")
	Local oLbxProd
	
	_cQry += " SELECT D1_ITEM, D1_COD, B1_DESC, B1_UM, B1_CONV,"
	_cQry += " D1_LOTEFOR, D1_DFABRIC, D1_DTVALID"
	//_cQry += " , ((D1_QUANT/B1_CONV)-CAST(D1_QUANT/B1_CONV AS INTEGER))*B1_CONV QTDFR"
	//_cQry += " , CAST(D1_QUANT/B1_CONV AS INTEGER) QTDCX"
	//_cQry += " , ((D1_QUANT/B1_CONV)-TRUNC(D1_QUANT/B1_CONV))*B1_CONV QTDFR"
	//_cQry += " , TRUNC(D1_QUANT/B1_CONV) QTDCX"
	_cQry += " , ((D1_QUANT/CAST(B1_CONV AS FLOAT))-Round(D1_QUANT/B1_CONV,0,1))*B1_CONV QTDFR"
	_cQry += " , Round(D1_QUANT/B1_CONV,0,1) QTDCX"	
	_cQry += " FROM "+RetSQLName("SD1")+" D1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" B1 ON B1.D_E_L_E_T_ = ' ' AND B1_COD = D1_COD"
	_cQry += " WHERE D1.D_E_L_E_T_ = ' '"
	_cQry += " AND D1_FILIAL = '"+SD1->D1_FILIAL+"'"
	_cQry += " AND D1_DOC = '"+SD1->D1_DOC+"'"
	_cQry += " AND D1_SERIE = '"+SD1->D1_SERIE+"'	"
	_cQry += " ORDER BY D1_ITEM"
	TcQuery _cQry New Alias "QETI"
	
	While !QETI->(EOF())
		aAdd(aLbxProd,{.T.,;
			D1_ITEM,;
			D1_COD,;
			B1_DESC,;
			B1_UM,;
			AllTrim(Transform(B1_CONV,"@E 999,999.99")),;
			D1_LOTEFOR,;
			DToC(SToD(D1_DFABRIC)),;
			DToC(SToD(D1_DTVALID)),;
			Transform(QTDFR,"@E 9,999,999.99"),;
			Transform(QTDCX,"@E 9,999,999.99")})
		QETI->(dbSkip())
	EndDo
	QETI->(dbCloseArea())
	
	
	@ 065, 005 LISTBOX oLbxProd Fields HEADER "","Item","Produto","Descricao","U.M.","Qtd. Emb.","Lote","Dt. Fabricacao","Dt. Validade","Qtd. Fracionada","Qtd. Embalada" SIZE 490, 150 OF oDlgEti PIXEL ColSizes 5,15,30,150,15,30,40,40,35,45,35
	oLbxProd:SetArray(aLbxProd)
	oLbxProd:bLine := {|| {;
		If(aLbxProd[oLbxProd:nAT,1],oOk,oNo),;
		aLbxProd[oLbxProd:nAt,2],;
		aLbxProd[oLbxProd:nAt,3],;
		aLbxProd[oLbxProd:nAt,4],;
		aLbxProd[oLbxProd:nAt,5],;
		aLbxProd[oLbxProd:nAt,6],;
		aLbxProd[oLbxProd:nAt,7],;
		aLbxProd[oLbxProd:nAt,8],;
		aLbxProd[oLbxProd:nAt,9],;
		aLbxProd[oLbxProd:nAt,10],;
		aLbxProd[oLbxProd:nAt,11];
		}}
	oLbxProd:bLDblClick := {|| aLbxProd[oLbxProd:nAt,1] := !aLbxProd[oLbxProd:nAt,1],;
		oLbxProd:DrawSelect()}
	
Return

Static Function bCharToVal(_cPar)
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
Return(Val(_cPar))


Static Function bEtiqFr(_aLinha)
	Local _aRet := {}
	If bGetZX1(_aLinha)
		_aRet := {DtoC(ZX1->ZX1_DTVAL),ZX1->ZX1_LOTEFO,_aLinha[4],ZX1->ZX1_CODETI}
	EndIf
Return(_aRet)

Static Function bGetZX1(_aLinha)
	Local _lRet := .T.
	ZX1->(dbSetOrder(2))
	SD1->(dbSetOrder(1))
	If SD1->(dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+_aLinha[3]+_aLinha[2]))
		If !ZX1->(dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+_aLinha[2]))
			RecLock("ZX1",.T.)
			ZX1->ZX1_FILIAL := xFilial("ZX1")
			ZX1->ZX1_CODETI := GetSXENum("ZX1","ZX1_CODETI",,1)
			ZX1->ZX1_DOC    := SF1->F1_DOC
			ZX1->ZX1_SERIE  := SF1->F1_SERIE
			ZX1->ZX1_FORNEC := SF1->F1_FORNECE
			ZX1->ZX1_LOJA   := SF1->F1_LOJA
			ZX1->ZX1_ITEM   := _aLinha[2]
			ZX1->ZX1_PRODUT := SD1->D1_COD
			ZX1->ZX1_LOTECT := SD1->D1_LOTECTL
			ZX1->ZX1_LOTEFO := SD1->D1_LOTEFOR
			ZX1->ZX1_DTVAL  := SD1->D1_DTVALID
			ZX1->(MsUnLock())
			ConfirmSX8()
		EndIf
	Else
		_lRet := .F.
	EndIf
Return(_lRet)


