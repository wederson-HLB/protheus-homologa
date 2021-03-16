#Include "Protheus.ch"

/*
Funcao      : GTEnchBar
Parametros  : oDlg,bOk,bCancel,lMessageDel,aButtons,nReg,cAlias,lTop
Retorno     : Nil
Objetivos   : 
TDN			: GTEnchBar( oDlg, bOk, bCancel, lMsgDel, aButtons, nRecno, cAlias,lTop)
				Parâmetros:
				oDlg	: Dialog onde irá criar a barra de botões
				bOk		: Bloco de código a ser executado no botão Ok
				bCancel	: Bloco de código a ser executado no botão Cancelar
				lMsgDel	: Exibe dialog para confirmar a exclusão
				aButtons: Array contendo botões adicionais.
						  aArray[n][1] -> Imagem do botão
						  aArray[n][2] -> bloco de código contendo a ação do botão
						  aArray[n][3] -> título do botão
				nRecno	: Registro a ser posicionado após a execução do botão Ok.
				cAlias	: Alias do registro a ser posicionado após a execução do botão
						  Ok. Se o parâmetro nRecno for informado, o cAlias passa ser
						  obrigatório.
				lTop	: .T. para exibição da barra em cima; .F. para exibição da barra em baixo
						  Default é .T.
Autor       : Matheus Massarotto
Data/Hora   : 10/01/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Todos
*/

//Definição de variáveis estáticas
Static __nNivelBar

*-----------------------------------------------------------------------------*
User Function GTEnchBar(oDlg,bOk,bCancel,lMessageDel,aButtons,nReg,cAlias,lTop)
*-----------------------------------------------------------------------------*
Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan,lOkOk,oBt1,oBt2,oBt3,oBt4,oBt6,oBt7
Local nLenButtons
Local nTamButtons := 0
Local nBar
Local oBtn
Local cAliasAtu := Alias()
Local lFlatMode := FlatMode()

DEFAULT lMessageDel := .F.
DEFAULT lTop		:= .T. //se for true aparece em cima, se for false aparece em baixo

DEFAULT __nNivelBar := -1

__nNivelBar++
nBar := __nNivelBar


If aButtons <> NIL
	nLenButtons:= Len(aButtons)
	nTamButtons := nLenButtons*50
EndIf

//Tratamento para definir se a barra será apresentada na parte superior ou parte inferior
if lTop
DEFINE BUTTONBAR oBar SIZE 50,50 3D TOP OF oDlg
else
DEFINE BUTTONBAR oBar SIZE 50,50 3D BOTTOM OF oDlg
endif

If IsPDA() .Or. oDlg:nWidth-nTamButtons > 150

	DEFINE BUTTON oBt1 RESOURCE "S4WB005N" OF oBar TOOLTIP OemToAnsi("Copiar") //RESOURCE "S4WB005N.PNG" // "Copiar"
	oBt1:cDefaultAct := "COPY"
	oBt1:cCaption:="" //Adicionado pois na versão 11 o nome fica na frente da imagem.
	//oBt1:cTitle := "Copiar"
	
EndIf

If IsPDA() .Or. oDlg:nWidth-nTamButtons > 200
	DEFINE BUTTON oBt2 OF oBar RESOURCE "S4WB006N" TOOLTIP OemToAnsi("Recortar") // "Recortar" RESOURCE "S4WB006N.PNG"
	oBt2:cDefaultAct := "CUT"
	oBt2:cCaption:=""
	//oBt2:cTitle := "Recortar"
EndIf

If IsPDA() .Or. oDlg:nWidth-nTamButtons > 250	
	DEFINE BUTTON oBt3 OF oBar RESOURCE "S4WB007N"  TOOLTIP OemToAnsi("Colar") // "Colar" RESOURCE "S4WB007N.PNG"
	oBt3:cDefaultAct := "PASTE"
	oBt3:cCaption:=""
	//oBt3:cTitle := "Colar"
EndIf
	
If ! IsPDA()
	DEFINE BUTTON oBt4 OF oBar GROUP RESOURCE "S4WB008N"  ACTION (Calculadora(),RetFocus(oBt4)) TOOLTIP OemToAnsi("Calculadora") // "Calculadora"
	oBt4:cCaption:=""
	//oBt4:cTitle := Subs("Calculadora",1,4)

	If oDlg:nWidth-nTamButtons > 400
		DEFINE BUTTON oBt6 OF oBar RESOURCE "impressao" ACTION (OurSpool(),RetFocus(oBt6)) TOOLTIP OemToAnsi("Spool") // "Spool"
		oBt6:cCaption:=""
	EndIf

	If oDlg:nWidth-nTamButtons > 450
		If CallWalkThru(.T.,.T.)
			DEFINE BUTTON oBt8 OF oBar RESOURCE "S4WB010N" ACTION ImpRelEnch(cAliasAtu) PROMPT "Imp.Cad." TOOLTIP OemToAnsi("Imprime Cadastro") // "Imprime Cadastro"
			oBt8:cCaption:=""
		EndIf
	EndIf
	
	If oDlg:nWidth-nTamButtons > 500
		If CallWalkThru(.T.)
			DEFINE BUTTON oBt9 OF oBar RESOURCE "walkthrough" ACTION Eval({ || CallWalkThru() }) TOOLTIP OemToAnsi("WalkThru") // "WalkThru"
			oBt9:cCaption:=""
		EndIf
	EndIf

	DEFINE BUTTON oBt7 OF oBar GROUP RESOURCE "S4WB016N" ACTION (HelProg(.t.),RetFocus(oBt7)) TOOLTIP OemToAnsi("Help") // "Help"
	oBt7:cCaption:=""
	
EndIf
If aButtons != Nil
   If IsPDA()          
	   oBar:nGroups += 3
   Else
		oBar:nGroups += 6
	EndIf	
	nLenButtons:= Len(aButtons)
	If nLenButtons > 0
		oBtn := TBtnBmp():NewBar(aButtons[1,1],,,,,{|This|(Eval(aButtons[1,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[1,3]), .F.,,,,,,,, )
		If Len(aButtons[1]) > 3
			//oBtn:cTitle := aButtons[1][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 1
		oBtn := TBtnBmp():NewBar(aButtons[2,1],,,,,{|This|(Eval(aButtons[2,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[2,3]), .F.,,,,,,,, )
		If Len(aButtons[2]) > 3
			//oBtn:cTitle := aButtons[2][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 2
		oBtn := TBtnBmp():NewBar(aButtons[3,1],,,,,{|This|(Eval(aButtons[3,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[3,3]), .F.,,,,,,,, )
		If Len(aButtons[3]) > 3
			//oBtn:cTitle := aButtons[3][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 3
		oBtn := TBtnBmp():NewBar(aButtons[4,1],,,,,{|This|(Eval(aButtons[4,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[4,3]), .F.,,,,,,,, )
		If Len(aButtons[4]) > 3
			//oBtn:cTitle := aButtons[4][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 4
		oBtn := TBtnBmp():NewBar(aButtons[5,1],,,,,{|This|(Eval(aButtons[5,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[5,3]), .F.,,,,,,,, )
		If Len(aButtons[5]) > 3
			//oBtn:cTitle := aButtons[5][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 5
		oBtn := TBtnBmp():NewBar(aButtons[6,1],,,,,{|This|(Eval(aButtons[6,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[6,3]), .F.,,,,,,,, )
		If Len(aButtons[6]) > 3
			//oBtn:cTitle := aButtons[6][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 6
		oBtn := TBtnBmp():NewBar(aButtons[7,1],,,,,{|This|(Eval(aButtons[7,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[7,3]), .F.,,,,,,,, )
		If Len(aButtons[7]) > 3
			//oBtn:cTitle := aButtons[7][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 7
		oBtn := TBtnBmp():NewBar(aButtons[8,1],,,,,{|This|(Eval(aButtons[8,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[8,3]), .F.,,,,,,,, )
		If Len(aButtons[8]) > 3
			//oBtn:cTitle := aButtons[8][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 8
		oBtn := TBtnBmp():NewBar(aButtons[9,1],,,,,{|This|(Eval(aButtons[9,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[9,3]), .F.,,,,,,,, )
		If Len(aButtons[9]) > 3
			//oBtn:cTitle := aButtons[9][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 9
		oBtn := TBtnBmp():NewBar(aButtons[10,1],,,,,{|This|(Eval(aButtons[10,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[10,3]), .F.,,,,,,,, )
		If Len(aButtons[10]) > 3
			//oBtn:cTitle := aButtons[10][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 10
		oBtn := TBtnBmp():NewBar(aButtons[11,1],,,,,{|This|(Eval(aButtons[11,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[11,3]), .F.,,,,,,,, )
		If Len(aButtons[11]) > 3
			//oBtn:cTitle := aButtons[11][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 11
		oBtn := TBtnBmp():NewBar(aButtons[12,1],,,,,{|This|(Eval(aButtons[12,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[12,3]), .F.,,,,,,,, )
		If Len(aButtons[12]) > 3
			//oBtn:cTitle := aButtons[12][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 12
		oBtn := TBtnBmp():NewBar(aButtons[13,1],,,,,{|This|(Eval(aButtons[13,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[13,3]), .F.,,,,,,,, )
		If Len(aButtons[13]) > 3
			//oBtn:cTitle := aButtons[13][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 13
		oBtn := TBtnBmp():NewBar(aButtons[14,1],,,,,{|This|(Eval(aButtons[14,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[14,3]), .F.,,,,,,,, )
		If Len(aButtons[14]) > 3
			//oBtn:cTitle := aButtons[14][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 14
		oBtn := TBtnBmp():NewBar(aButtons[15,1],,,,,{|This|(Eval(aButtons[15,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[15,3]), .F.,,,,,,,, )
		If Len(aButtons[15]) > 3
			//oBtn:cTitle := aButtons[15][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 15
		oBtn := TBtnBmp():NewBar(aButtons[16,1],,,,,{|This|(Eval(aButtons[16,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[16,3]), .F.,,,,,,,, )
		If Len(aButtons[16]) > 3
			//oBtn:cTitle := aButtons[16][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 16
		oBtn := TBtnBmp():NewBar(aButtons[17,1],,,,,{|This|(Eval(aButtons[17,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[17,3]), .F.,,,,,,,, )
		If Len(aButtons[17]) > 3
			//oBtn:cTitle := aButtons[17][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 17
		oBtn := TBtnBmp():NewBar(aButtons[18,1],,,,,{|This|(Eval(aButtons[18,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[18,3]), .F.,,,,,,,, )
	   	If Len(aButtons[18]) > 3
			//oBtn:cTitle := aButtons[18][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 18
		oBtn := TBtnBmp():NewBar(aButtons[19,1],,,,,{|This|(Eval(aButtons[19,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[19,3]), .F.,,,,,,,, )
		If Len(aButtons[19]) > 3
			//oBtn:cTitle := aButtons[19][4]
			oBtn:cCaption:=""
		EndIf
	EndIf

	If nLenButtons > 19
		oBtn := TBtnBmp():NewBar(aButtons[20,1],,,,,{|This|(Eval(aButtons[20,2]),RetFocus(This))}, .T., oBar, .F.,, OemToAnsi(aButtons[20,3]), .F.,,,,,,,, )
		If Len(aButtons[20]) > 3
			//oBtn:cTitle := aButtons[20][4]
			oBtn:cCaption:=""
		EndIf
	EndIf
EndIf
oBar:nGroups += 6

DEFINE BUTTON oBtOk OF oBar GROUP RESOURCE "OK" ACTION ( lOkOk:=If(lMessageDel,MSGYESNO("Confirma a Exclus„o ?","Aten‡„o"),.T.),lOk:=If(lOkOk,(Regoto(nReg,cAlias),SafeEval(bOk)),.F.),EvalRetOK(lOK,nBar),If(TYPE("INCLUI") = "L" .and. __nNivelBar == 0,__lLoop := INCLUI,)) TOOLTIP OemToAnsi("Ok - <Ctrl-O>") // "Confirma a Exclus„o ?" ### "Aten‡„o" RESOURCE "OK.PNG"
//oBtOk:cTitle := "OK"
oBtOk:cCaption:=""

DEFINE BUTTON oBtCan OF oBar RESOURCE "CANCEL" ACTION ( __lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP OemToAnsi("Cancelar - <Ctrl-X>") // "Cancelar - <Ctrl-X>" RESOURCE "CANCEL.PNG"
//oBtCan:cTitle := "Cancelar"	//"Cancelar"
oBtCan:cCaption:=""
oBtCan:lOutGet := .T.

SetKEY(15,{|| oBtOk:click()})
SetKEY(24,{|| oBtCan:click()})
oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction

oBar:bRClicked := {|| AllwaysTrue()}

Return

*---------------------------------*
Static Function Regoto(nreg,cAlias)
*---------------------------------*
IF cAlias != Nil
   (cAlias)->(dbGoto(nReg))
Endif
Return Nil                  

*---------------------------*
Static Function RetFocus(oBt)
*---------------------------*
Return .t.