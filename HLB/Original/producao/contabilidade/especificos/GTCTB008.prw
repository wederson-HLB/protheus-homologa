#INCLUDE "Protheus.ch"

/*
Funcao      : GTCTB008                    
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualização de cabeçalho do ECD, ajustar a tabela CSA de acordo com a CSB.
Autor       : Jean Victor Rocha	
Data/Hora   : 18/06/2015
*/
*----------------------*
User Function GTCTB008()
*----------------------*
Private cRevisao	:= ""
Private cApuracao	:= ""
Private cAno		:= ""
Private cAliasWork  := "Work"        

//Busca a Revisão
If EMPTY(cRevisao:=GetRevisao())
	MsgInfo("Revisão Invalida!","HLB BRASIL")
	Return .T.
EndIf
If !MsgYesNo("Confirma o ajuste para a revisão '"+ALLTRIM(cRevisao)+"'?","HLB BRASIL")
	Return .T.
EndIf

//Busca a Apuração        
If EMPTY(cApuracao:=GetApuracao())
	MsgInfo("Apuração Invalida!","HLB BRASIL")
	Return .T.
EndIf

//Limpeza da tabela CSA
DelCSA()

//Criação dos novos registros na CSA
Processa({|lEnd| NewCSA(),"Calculando"})

//Ajuste do lançamento de apuração
ApuCSA()

Return .T.

/*
Funcao      : GetRevisao
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para seleção da revisão
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
Static Function GetRevisao()
*--------------------------*
Local cRet := ""
Local cQry := ""
Local nOpc := 0

Private cAliasWork := "Work"
private aCpos :=  {	{"MARCA"	,,""} ,;
					{"REVISAO"	,,"Revisao"	},;
					{"QTDLANC"	,,"Qtde. Lanc."},;
		   			{"VALTOT"	,,"Vlr Total"},;
		   			{"ANO" 		,,"Ano Lanc."}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"REVISAO"	,"C",6 ,0},;
						{"QTDLANC"	,"N",6 ,0},;
		   				{"VALTOT"	,"N",16,2},;
		   				{"ANO"		,"C",4 ,0}}

//Busca das revisões.
If Select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf     
/*JSS - 23/06/2015 - Alterado Select para não trazer as apurações do Fcont.
cQry := "Select CSA_CODREV,COUNT(CSA_CODREV) AS QTDLANC,CAST(SUM(CSA_VLLCTO) AS numeric(16,2)) AS VALTOT,LEFT(CSA_DTLANC,4) AS CSA_DTLANC 
cQry += " From "+RETSQLNAME("CSA")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " GROUP BY CSA_CODREV,LEFT(CSA_DTLANC,4)"
*/
cQry := "Select SA.CSA_CODREV,COUNT(SA.CSA_CODREV) AS QTDLANC,CAST(SUM(SA.CSA_VLLCTO) AS numeric(16,2)) AS VALTOT,LEFT(SA.CSA_DTLANC,4) AS CSA_DTLANC
cQry += " From "+RETSQLNAME("CSA")+" AS SA ,"+RETSQLNAME("CS0")+" AS S0"
cQry += " Where (SA.D_E_L_E_T_ <> '*' AND S0.D_E_L_E_T_ <> '*') AND S0.CS0_ECDREV='ECD' AND S0.CS0_CODREV=SA.CSA_CODREV
cQry += " GROUP BY SA.CSA_CODREV,LEFT(SA.CSA_DTLANC,4)"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TEMP",.F.,.T.)

//montagem da Tabela work
If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

TEMP->(DbGoTop())
While TEMP->(!EOF())
	(cAliasWork)->(RecLock(cAliasWork,.T.))
	(cAliasWork)->MARCA		:= ""
	(cAliasWork)->REVISAO	:= TEMP->CSA_CODREV
	(cAliasWork)->QTDLANC	:= TEMP->QTDLANC
	(cAliasWork)->VALTOT	:= TEMP->VALTOT
	(cAliasWork)->ANO  		:= TEMP->CSA_DTLANC
	(cAliasWork)->(MsUnlock())
	TEMP->(DbSkip())
EndDo
(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

oDlg1      := MSDialog():New( 100,200,420,568,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione a Revisão a ser ajustada"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{030,004,155,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.

oSBtn1     := SButton():New( 014,106,1,{|| (nOpc := 1, oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 014,142,2,{|| (nOpc := 2, oDlg1:END())},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

If nOpc == 1
	(cAliasWork)->(DbGoTop())
	While (cAliasWork)->(!EOF())
   		If !EMPTY((cAliasWork)->MARCA)
   			cRet := (cAliasWork)->REVISAO
   			cAno := (cAliasWork)->ANO
   			Exit
   		EndIf
   		(cAliasWork)->(DbSkip())
	EndDo
Else
	cRet := ""
EndIf

Return cRet

/*
Funcao      : GetApuracao
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para seleção da apuração
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetApuracao()
*---------------------------*
Local cRet := ""
Local cQry := ""
Local nOpc := 0

private aCpos :=  {	{"MARCA"   		,,""} ,;
					{"CSB_FILIAL"	,,"Revisao"	},;
					{"CSB_CODREV"	,,"Revisao"},;
		   			{"CSB_DTLANC"	,,"Dt. Lanc."},;
	   				{"CSB_LOTE"		,,"Lote"},;
	   				{"CSB_SBLOTE"	,,"SubLote"},;
	   				{"CSB_DOC"		,,"Doc."},;
	   				{"CSB_VLPART"	,,"Vlr. Lanc."},;
		   			{"CSB_NUMLOT"	,,"Chv.Lote"}}
		   				
private aCampos :=  {	{"MARCA"   		,"C",2 ,0} ,;
						{"CSB_FILIAL"	,"C",2 ,0},;
						{"CSB_CODREV"	,"C",6 ,0},;
						{"CSB_DTLANC"	,"D",8 ,0},;
						{"CSB_LOTE"		,"C",6 ,0},;
						{"CSB_SBLOTE"	,"C",3 ,0},;
						{"CSB_DOC" 		,"C",6 ,0},;
						{"CSB_VLPART"	,"N",16,2},;
						{"CSB_NUMLOT"	,"C",50,0}}

//Busca das revisões.
If Select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf     
cQry := "select CSB_FILIAL,CSB_CODREV,CSB_DTLANC,CSB_NUMLOT,CSB_INDDC,CAST(SUM(CSB_VLPART) AS NUMERIC(16,2)) AS CSB_VLPART
cQry += " From "+RETSQLNAME("CSB")       
//JSS- Inicio alteração para solução dos casos onde a apuração não era realizada no dia 31/12
If MsgYesNo("A data da apuração deste empresa esta em 31/12 ?","HLB BRASIL")
	cQry += " where D_E_L_E_T_ <> '*' AND CSB_CODREV = '"+cRevisao+"' AND CSB_INDDC = 'C' AND CSB_DTLANC = '"+cAno+"1231'
Else
	cQry += " where D_E_L_E_T_ <> '*' AND CSB_CODREV = '"+cRevisao+"' AND CSB_INDDC = 'C' AND CSB_DTLANC LIKE '"+cAno+"%'
EndIf 
//JSS Fim cQry += " where D_E_L_E_T_ <> '*' AND CSB_CODREV = '"+cRevisao+"' AND CSB_INDDC = 'C' AND CSB_DTLANC = '"+cAno+"1231'
cQry += " Group By CSB_FILIAL,CSB_CODREV,CSB_DTLANC,CSB_NUMLOT,CSB_INDDC

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TEMP",.F.,.T.)

//montagem da Tabela work
If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

TEMP->(DbGoTop())
While TEMP->(!EOF())
	(cAliasWork)->(RecLock(cAliasWork,.T.))
	(cAliasWork)->MARCA		:= ""
	(cAliasWork)->CSB_FILIAL	:= TEMP->CSB_FILIAL
	(cAliasWork)->CSB_CODREV	:= TEMP->CSB_CODREV
	(cAliasWork)->CSB_DTLANC	:= STOD(TEMP->CSB_DTLANC)
	(cAliasWork)->CSB_LOTE		:= SUBSTR(TEMP->CSB_NUMLOT,11,6)
	(cAliasWork)->CSB_SBLOTE	:= SUBSTR(TEMP->CSB_NUMLOT,17,3)
	(cAliasWork)->CSB_DOC		:= SUBSTR(TEMP->CSB_NUMLOT,20,6)
	(cAliasWork)->CSB_VLPART	:= TEMP->CSB_VLPART
	(cAliasWork)->CSB_NUMLOT	:= TEMP->CSB_NUMLOT
	(cAliasWork)->(MsUnlock())
	TEMP->(DbSkip())
EndDo
(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

oDlg1      := MSDialog():New( 100,100,420,1070,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione a apuração a ser considerada!"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{030,004,155,470},,, oDlg1 ) 
//oBrw1:bAval := {||cMark()} //JSS 23/06/2015 Foi comentado do fonte pois foi necessario utilizar mais do que uma apuração no mesmo SPED.
oBrw1:oBrowse:lHasMark := .F.
oBrw1:oBrowse:lCanAllmark := .F.

oSBtn1     := SButton():New( 001,406,1,{|| (nOpc := 1, oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 001,442,2,{|| (nOpc := 2, oDlg1:END())},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

If nOpc == 1
	(cAliasWork)->(DbGoTop())
	While (cAliasWork)->(!EOF())
   		If !EMPTY((cAliasWork)->MARCA)
   			cRet := (cAliasWork)->CSB_NUMLOT
   			Exit
   		EndIf
   		(cAliasWork)->(DbSkip())
	EndDo
Else
	cRet := ""
EndIf

Return cRet

/*
Funcao      : cMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : cMark para tela.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------*
Static Function cMark()
*---------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))
Local nRec := 0

If lDesmarca
	RecLock(cAliasWork, .F.)
	(cAliasWork)->MARCA := "  "
	(cAliasWork)->(MsUnlock())
Else
	nRec := (cAliasWork)->(RECNO())
	(cAliasWork)->(DbGoTop())
	While (cAliasWork)->(!EOF())
		RecLock(cAliasWork, .F.)
		(cAliasWork)->MARCA := "  "
		(cAliasWork)->(MsUnlock())
		(cAliasWork)->(DbSkip())
	EndDo
	(cAliasWork)->(DbGoTo(nRec))
	(cAliasWork)->MARCA := cMarca
Endif
oBrw1:oBrowse:Refresh()

Return

/*
Funcao      : cMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : cMark para tela.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function DelCSA()
*----------------------*
cUpdate := ""

cUpdate += " Update "+RETSQLNAME("CSA") 
cUpdate += " 	set D_E_L_E_T_ = '*'
cUpdate += " where D_E_L_E_T_ <> '*' AND CSA_CODREV = '"+cRevisao+"'"

TcSqlExec(cUpdate)

Return .T.

/*
Funcao      : cMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : cMark para tela.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function NewCSA()
*----------------------*
PROCREGUA(10000)

If Select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf     
cQry := "select CSB_FILIAL,CSB_CODREV,CSB_DTLANC,CSB_NUMLOT,CSB_INDDC,CAST(SUM(CSB_VLPART) AS NUMERIC(16,2)) AS CSB_VLPART,
cQry += " 'Insert "+RETSQLNAME("CSA")+" (CSA_FILIAL,CSA_CODREV,CSA_DTLANC,CSA_NUMLOT,CSA_INDTIP,CSA_VLLCTO,R_E_C_N_O_)
cQry += " Values('''+CSB_FILIAL+''','''+CSB_CODREV+''','''+CSB_DTLANC+''','''+CSB_NUMLOT+''',''N'',
cQry += " '+CAST(CAST(SUM(CSB_VLPART) AS NUMERIC(16,2)) AS varchar(30))+',
cQry += " (Select ISNULL(MAX(R_E_C_N_O_)+1,0) From "+RETSQLNAME("CSA")+"))	' AS UPDATE_CSA
cQry += " From "+RETSQLNAME("CSB")
cQry += " where D_E_L_E_T_ <> '*' AND CSB_CODREV = '"+cRevisao+"' AND CSB_INDDC = 'C'
cQry += " Group By CSB_FILIAL,CSB_CODREV,CSB_DTLANC,CSB_NUMLOT,CSB_INDDC

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TEMP",.F.,.T.)

TEMP->(DbGoTop())
While TEMP->(!EOF())
	TcSQLExec(TEMP->UPDATE_CSA)
	INCPROC()
	TEMP->(DbSkip())
EndDo

Return .T.

/*
Funcao      : cMark
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : cMark para tela.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function ApuCSA()
*----------------------*
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If !EMPTY((cAliasWork)->MARCA)
		cRet := (cAliasWork)->CSB_NUMLOT
		cUpdate := ""
		cUpdate += " Update "+RETSQLNAME("CSA")
		cUpdate += " 	set CSA_INDTIP = 'E'
		cUpdate += " where D_E_L_E_T_ <> '*' AND CSA_NUMLOT = '"+cRet+"'"
		TcSqlExec(cUpdate)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo

Return .T.