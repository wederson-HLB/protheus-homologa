#Include "PROTHEUS.CH"
/*
Funcao      : SUEST006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ativacao/Desativa conferencia
Autor       : Consultoria Totvs
Data/Hora   : 30/12/2014     
Obs         : 
Revis„o     : Matheus Massarotto
Data/Hora   : 06/01/2015
MÛdulo      : Estoque
Cliente     : Exeltis
*/
*--------------------*
User Function SUEST006
*--------------------*
Local _lConfFis := GetMv("MV_CONFFIS") == "S"
Local oFont1 := TFont():New("Tahoma",,022,,.T.,,,,,.F.,.F.)
Local oRad
Local nRad := IIf(_lConfFis,1,2)
Local oSay1
Local oSButton1
Local oSButton2
Local _nOpc := 0
Static oDlg
	/*	
	If !(__cUserID $ GetNewPar("MV_P_USRSU","000474.000544"))
		MsgStop("Usu√°rio sem permiss√£o para acessar esta rotina.")
		Return
	EndIf
	*/
	 
	If !(AllTrim(cUserName) $ GetMV("MV_P_00042"))  
		MsgStop("Usu·rio sem permiss„o para acessar esta rotina.")
		Return
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Ativa/Desativa Conferencia" FROM 000, 000  TO 200, 240 COLORS 0, 16777215 PIXEL
	@ 020, 007 RADIO oRad VAR nRad ITEMS "Ativado","Desativado" SIZE 076, 037 OF oDlg COLOR 0, 16777215 PIXEL
	@ 005, 005 SAY oSay1 PROMPT "Conferencia Fisica" SIZE 100, 012 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 072, 020 TYPE 01 OF oDlg ENABLE ACTION (_nOpc:=1,oDlg:End())
	DEFINE SBUTTON oSButton2 FROM 072, 070 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED
	If _nOpc==1
		If nRad == 1
			PutMv("MV_CONFFIS","S")
		Else
			PutMv("MV_CONFFIS","N")
		EndIf
	EndIf

Return
