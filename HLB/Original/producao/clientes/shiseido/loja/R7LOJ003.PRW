#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#include "msgraphi.ch"
/*
Funcao      : R7LOJ003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Painel de monitoramento de integrações com a loja.
Autor     	: Jean Victor Rocha	
Data     	: 22/10/2012
Cliente     : Shiseido
*/

*----------------------*
User Function R7LOJ003()
*----------------------*
Private nCOnWall	:= 0
Private lFechado	:= .F.

If cEmpAnt <> "R7"
	ALert("Empresa não autorizada para uso da rotina!")
	Return .T.
EndIf


//CArrega tabelas que estão no sql Totvs. - Nao necessario.
//Processa({|| LoadLocal()})

//Abre conexão com banco de interface
nConWall := TCLink("MSSQL7/DbWall","10.11.201.22",7890) 

//Testa conexão
If nConWall < 0
	MsgInfo("Erro ao conectar com o banco de dados DbWall(10.11.201.22) para integração com Microvix")
 	Return .F.
Else
	ConOut("Conectado no Dbwall...")
EndIf

Processa({|| LoadWork()})

Processa({|| Monitor()})

If !lFechado .and. TcUnlink(nConWall) 
	ConOut("Conexão com DbWall fechada...")
EndIf 

Return .T.

/*
Funcao      : LoadLocal
Parametros  : 
Retorno     : 
Objetivos   : Carrega tabelas do banco Totvs
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2012
TDN         : 
*/
*----------------------*
Static Function LoadLocal()
*----------------------*
//----CARREGA SL1 ---------------------------------------------------------------------------
If Select("LOCALSL1") > 0
	LOCALSL1->(DbCloseArea())	               
EndIf
	  
aStruSL1 := SL1->(dbStruct())
    
cQuery:=" SELECT * "
cQuery+=" FROM "+RetSQLname("SL1")
cQuery+=" WHERE  D_E_L_E_T_ <> '*'  " 
	
TCQuery cQuery ALIAS "LOCALSL1" NEW

For nX := 1 To Len(aStruSL1)
	If aStruSL1[nX,2]<>"C"
		TcSetField("LOCALSL1",aStruSL1[nX,1],aStruSL1[nX,2],aStruSL1[nX,3],aStruSL1[nX,4])
	EndIf
Next nX

cTMP := CriaTrab(NIL,.F.)
Copy To &cTMP
dbCloseArea()
dbUseArea(.T.,,cTMP,"LOCALSL1",.T.)  

//----CARREGA SFI ---------------------------------------------------------------------------
If Select("LOCALSFI") > 0
	LOCALSFI->(DbCloseArea())	               
EndIf
aStruSFI := SFI->(dbStruct())
    
//Cria temporario da redução que será integrada.                              
cQuery:=" SELECT * "
cQuery+=" FROM "+RetSQLname("SFI")
cQuery+=" WHERE  D_E_L_E_T_ <> '*'  "
cQuery+=" Order By FI_DTMOVTO"
	
TCQuery cQuery ALIAS "LOCALSFI" NEW

For nX := 1 To Len(aStruSFI)
	If aStruSFI[nX,2]<>"C"
		TcSetField("LOCALSFI",aStruSFI[nX,1],aStruSFI[nX,2],aStruSFI[nX,3],aStruSFI[nX,4])
	EndIf
Next nX

cTMP := CriaTrab(NIL,.F.)
Copy To &cTMP
dbCloseArea()
dbUseArea(.T.,,cTMP,"LOCALSFI",.T.)

Return .T.

/*
Funcao      : LoadWork
Parametros  : 
Retorno     : 
Objetivos   : Carrega Works que serão exibidas no monitors.
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2012
TDN         : 
*/
*----------------------*
Static Function LoadWork()
*----------------------*
Local nx := 0
Local cQuery	:= ""

Local cArqIndSL1:= ""
Local cArqTmpSL1:= ""
Local aStruSL1	:= SL1->(dbStruct())
Local aCamposSL1 :=	 {{"L1_FILIAL" 	,RETSX3("L1_FILIAL"	, "TIP"),RETSX3("L1_FILIAL"	, "TAM"),RETSX3("L1_FILIAL"	, "DEC")},;
					  {"L1_NOME" 	,"C",15,0},;
					  {"L1_DOC" 	,RETSX3("L1_DOC"	, "TIP"),RETSX3("L1_DOC"	, "TAM"),RETSX3("L1_DOC"	, "DEC")},;
					  {"L1_EMISSAO" ,RETSX3("L1_EMISSAO", "TIP"),RETSX3("L1_EMISSAO", "TAM"),RETSX3("L1_EMISSAO", "DEC")},;
					  {"L1_P_OBS"  	,RETSX3("L1_P_OBS"	, "TIP"),RETSX3("L1_P_OBS"	, "TAM"),RETSX3("L1_P_OBS"	, "DEC")}}

Local cArqIndSFI:= ""
Local cArqTmpSFI:= ""
Local aStruSFI	:= SFI->(dbStruct())
Local aCamposSFI :=	{{"FI_FILIAL" 	,RETSX3("F1_FILIAL"	, "TIP"),RETSX3("F1_FILIAL"	, "TAM"),RETSX3("F1_FILIAL"	, "DEC")},;
					  {"FI_NOME" 	,"C",15,0},;
					  {"FI_DTMOVTO" ,RETSX3("FI_DTMOVTO", "TIP"),RETSX3("FI_DTMOVTO", "TAM"),RETSX3("FI_DTMOVTO", "DEC")},;
					  {"FI_GTINI" 	,RETSX3("FI_GTINI"	, "TIP"),RETSX3("FI_GTINI"	, "TAM"),RETSX3("FI_GTINI"	, "DEC")},;
					  {"FI_GTFINAL" ,RETSX3("FI_GTFINAL", "TIP"),RETSX3("FI_GTFINAL", "TAM"),RETSX3("FI_GTFINAL", "DEC")},;
					  {"FI_NUMINI" 	,RETSX3("FI_NUMINI"	, "TIP"),RETSX3("FI_NUMINI"	, "TAM"),RETSX3("FI_NUMINI"	, "DEC")},;
					  {"FI_NUMFIM" 	,RETSX3("FI_NUMFIM"	, "TIP"),RETSX3("FI_NUMFIM"	, "TAM"),RETSX3("FI_NUMFIM"	, "DEC")},;
					  {"FI_P_OBS"  	,RETSX3("FI_P_OBS"	, "TIP"),RETSX3("FI_P_OBS"	, "TAM"),RETSX3("FI_P_OBS"	, "DEC")}}

If Select("QRY") > 0
	QRY->(DbCloseArea())	               
EndIf
If Select("WRKSL1") > 0
	WRKSL1->(DbCloseArea())	               
EndIf
If Select("WRKSFI") > 0
	WRKSFI->(DbCloseArea())	               
EndIf
                       
ProcRegua(3)//Carrega duas works
IncProc("Carregando informações...")	
cArqTmpSL1:=CriaTrab(aCamposSL1,.T.)
dbUseArea( .T.,,cArqTmpSL1,"WRKSL1",, .F. )
cArqIndSL1 := CriaTrab(,.F.)
IndRegua("WRKSL1",cArqIndSL1,"L1_FILIAL+L1_DOC",,,"Selecionando Registros...")
WRKSL1->(DbSetIndex(cArqIndSL1+OrdBagExt()))

BeginSql Alias 'QRY'
	SELECT *
	FROM %table:SL1%
	WHERE %notDel% AND (L1_P_INT = 'N' OR L1_P_INT = ' ')
EndSql

aOrd := SAveOrd({"SM0"})
QRY->(DbGoTop())
While QRY->(!EOF())
	WRKSL1->(DbAppend())
	WRKSL1->L1_FILIAL	:= QRY->L1_FILIAL
	WRKSL1->L1_DOC		:= STRZERO(VAL(QRY->L1_DOC),6)
	WRKSL1->L1_EMISSAO	:= STOD(QRY->L1_EMISSAO)
	SM0->(DBSEEK("R7"+QRY->L1_FILIAL))
	WRKSL1->L1_NOME		:= SM0->M0_FILIAL
 	If EMPTY(QRY->L1_P_OBS)
		WRKSL1->L1_P_OBS	:= "<Aguardando integração.>"
	Else
		WRKSL1->L1_P_OBS	:= QRY->L1_P_OBS
	EndIf
	QRY->(DbSkip())
EndDo
QRY->(DbCloseArea()) 
IncProc("Carregando informações...")

//------------------------------------------------------
cArqTmpSFI:=CriaTrab(aCamposSFI,.T.)
dbUseArea( .T.,,cArqTmpSFI,"WRKSFI",, .F. )
cArqIndSFI := CriaTrab(,.F.)
IndRegua("WRKSFI",cArqIndSFI,"FI_FILIAL+FI_NUMINI",,,"Selecionando Registros...")
WRKSFI->(DbSetIndex(cArqIndSFI+OrdBagExt()))

BeginSql Alias 'QRY'
	SELECT *
	FROM %table:SFI%
	WHERE %notDel% AND (FI_P_INT = 'N' OR FI_P_INT = ' ')
EndSql

QRY->(DbGoTop())
While QRY->(!EOF())
	WRKSFI->(DbAppend())
	WRKSFI->FI_FILIAL	:= QRY->FI_FILIAL
	WRKSFI->FI_DTMOVTO	:= STOD(QRY->FI_DTMOVTO)
	WRKSFI->FI_GTINI	:= QRY->FI_GTINI
	WRKSFI->FI_GTFINAL	:= QRY->FI_GTFINAL
	WRKSFI->FI_NUMINI	:= QRY->FI_NUMINI
	WRKSFI->FI_NUMFIM	:= QRY->FI_NUMFIM
	SM0->(DBSEEK("R7"+QRY->FI_FILIAL))
	WRKSFI->FI_NOME		:= SM0->M0_FILIAL
 	If EMPTY(QRY->FI_P_OBS)
		WRKSFI->FI_P_OBS	:= "<Aguardando integração.>"
	Else
		WRKSFI->FI_P_OBS	:= QRY->FI_P_OBS
	EndIf
	QRY->(DbSkip())
EndDo
QRY->(DbCloseArea())
RestOrd(aOrd)
IncProc("Carregando informações...")

Return .T.
 
/*
Funcao      : Monitor
Parametros  : 
Retorno     : 
Objetivos   : Tela do monitor de integrações com a loja.
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2012
TDN         : 
*/
*----------------------*
Static Function Monitor()
*----------------------*
Local i
Local nSerie	:= 0
LOcal nPos		:= 0
Local aTipos	:= {"N"," "}
Local cMarca	:= ""//GetMark()
Local aColor	:= {CLR_YELLOW,CLR_BLUE,CLR_GREEN,CLR_CYAN,CLR_RED,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,;
					CLR_GRAY,CLR_HBLUE,CLR_HGREEN,CLR_HCYAN,CLR_HRED,CLR_HMAGENTA,CLR_BLACK,CLR_WHITE}

Private oBrw1
Private oBrw2
Private nQtde := 0
Private cNome := ""
Private aErroData	:= {}
Private aErroSFI	:= {}
Private aCpsBrwSL1 :=	{{"L1_FILIAL"	,, "Filial"		,"@!"},;      
						{"L1_NOME"		,, "Nome Filial",""},;
				   		{"L1_DOC"		,, "Cupom"		,"@!"},;
				  		{"L1_EMISSAO"	,, "Dt. Emissao",""},;
				  		{"L1_P_OBS"		,, "Descrição"	,"@!"}}

Private aCpsBrwSFI :=	{{"FI_FILIAL"	,, "Filial"				,""},;
						{"FI_NOME"		,, "Nome Filial"		,""},;
						{"FI_DTMOVTO"	,, "Dt. Movim."			,""},;
				   		{"FI_GTINI"		,, "Vlr. Inicial"		,""},;
				   		{"FI_GTFINAL"	,, "Vlr. Final"			,""},;
				   		{"FI_NUMINI"	,, "Num Inicial"		,""},;
				   		{"FI_NUMFIM"	,, "Num Final"			,""},;
				  		{"FI_P_OBS"		,, "Descrição" 			,""}}

Private oDlg

ProcRegua(3)//Duas partes a tela.
IncProc("Carregando dados para interface...")	
oDlg := MSDialog():New( 091,200,680,1095,"HLB BRASIL - Monitor de Lojas",,,.F.,,,,,,.T.,,,.T. )
oPanel1 := TPanel():New( 004,004,,oDlg,,.F.,.F.,,,440,135,.T.,.F. )
oPanel2 := TPanel():New( 140,004,,oDlg,,.F.,.F.,,,440,135,.T.,.F. )

WRKSL1->(DbGoTop())
oBrw1 := MsSelect():New("WRKSL1",,"",aCpsBrwSL1,.F.,cMarca,{004,180,135,430},,,oPanel1)
oGraphic1 := TMSGraphic():New( 01,01,oPanel1,,,RGB(239,239,239),175,135)  
oGraphic1:SetTitle("Informações de Cupons","", CLR_HBLUE, A_LEFTJUST, GRP_TITLE )
oGraphic1:SetMargins(2,6,6,6)
nSerie := oGraphic1:CreateSerie( GRP_BAR )
For i:=1 to Len(aTipos)
	nQtde := BUSCAQTDE(aTipos[i],"SL1")
	Do Case
		Case aTipos[i] == "N"	 
			cNome := "Erro"
		Case aTipos[i] == " "	 
			cNome := "Aguardando integração"
		Otherwise
			cNome := aTipos[i]
	EndCAse
	oGraphic1:Add(nSerie,nQtde,cNome,aColor[1])
Next i
IncProc("Carregando dados para interface...")	

SFIERRO(DTOS(date()-30))
For i:=1 to Len(aErroData)
	WRKSFI->(DbAppend())
	WRKSFI->FI_FILIAL	:= aErroData[i][1]
	WRKSFI->FI_DTMOVTO	:= aErroData[i][2]
	WRKSFI->FI_GTINI	:= aErroData[i][3]
	WRKSFI->FI_GTFINAL	:= aErroData[i][4]
	WRKSFI->FI_NUMINI	:= aErroData[i][5]
	WRKSFI->FI_NUMFIM	:= aErroData[i][6]
	SM0->(DBSEEK("R7"+aErroData[i][1]))
	WRKSFI->FI_NOME		:= SM0->M0_FILIAL
	WRKSFI->FI_P_OBS	:= "REDUCAOZ - Sem informação para esta data"
Next i
WRKSFI->(DbGoTop())
oBrw2 := MsSelect():New("WRKSFI",,"",aCpsBrwSFI,.F.,cMarca,{004,180,135,430},,,oPanel2)
oGraphic2 := TMSGraphic():New( 01,01,oPanel2,,,RGB(239,239,239),175,135)  
oGraphic2:SetTitle("Informações de ReducaoZ - 30 dias.","", CLR_HBLUE, A_LEFTJUST, GRP_TITLE )
oGraphic2:SetMargins(2,6,6,6)
nSerie := oGraphic2:CreateSerie( GRP_BAR )
For i:=1 to Len(aTipos)
	nQtde := BUSCAQTDE(aTipos[i],"SFI")
	Do Case
		Case aTipos[i] == "N"	 
			nQTde := Len(aErroData)
			cNome := "Sem Inf./Dia"
		Case aTipos[i] == " "	 
			cNome := "Aguardando integração"
		Otherwise
			cNome := aTipos[i]
	EndCAse
	oGraphic2:Add(nSerie,nQtde,cNome,aColor[4])
Next i
IncProc("Carregando dados para interface...")	

//oBtn1 := TButton():New(276,095,"      Gera Integração",oDlg,{|| (CallInt(),oDlg:END()) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
//oBtn1:SetCss("QPushButton{ background-image:url(rpo:PMSRRFSH.png);background-repeat: none; margin: 2px }")//esquerda/superior do botão,

oBtn2 := TButton():New(276,008,"      Verifica ReducaoZ",oDlg,{|| (Processa({||U_LoadSFI()})) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn2:SetCss("QPushButton{ background-image:url(rpo:ENGRENAGEM.png);background-repeat: none; margin: 2px }")//esquerda/superior do botão,

oSBtn1 := SButton():New( 280,410,1,{|| oDlg:END()},oDlg,,"", )

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao      : CallInt
Parametros  : 
Retorno     : 
Objetivos   : chamada da integração
Autor       : Jean Victor Rocha
Data/Hora   : 23/10/2012
TDN         : 
*/
*-------------------------------------*
Static Function CallInt()
*-------------------------------------*

If !lFechado .and. TcUnlink(nConWall) 
	ConOut("Conexão com DbWall fechada...")
EndIf                                      
lFechado := .T.

U_R7LOJ001()

Return .T.

/*
Funcao      : BUSCAQTDE
Parametros  : 
Retorno     : 
Objetivos   : Busca quantidade de itens para grafico.
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2012
TDN         : 
*/
*-------------------------------------*
Static Function BUSCAQTDE(cTipo,cALias)
*-------------------------------------*
Local nRet := 0
Local cQuery := ""

If Select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf

cQuery:=" SELECT COUNT(*) as QTDE"
cQuery+=" FROM "+RetSQLname(cAlias)
cQuery+=" WHERE  D_E_L_E_T_ <> '*'  "
If cAlias == "SL1"
	cQuery+=" AND L1_P_INT = '"+cTipo+"' "
ElseIf cAlias == "SFI"
	cQuery+=" AND FI_P_INT = '"+cTipo+"' "
EndIf
	
TCQuery cQuery ALIAS "TEMP" NEW

nRet := TEMP->QTDE

TEMP->(DbCloseArea())

Return nRet    

/*
Funcao      : SFIERRO
Parametros  : 
Retorno     : 
Objetivos   : BUsca as informações de Erros SFI.
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2012
TDN         : 
*/
*----------------------------*
Static Function SFIERRO(cData)
*----------------------------*
Local cFilAux	:= ""
Local aDados	:= {}
Local lTodos	:= .F.

Default cData	:= ''


aErroData	:= {}
aErroSFI	:= {}

If EMPTY(cData)//FAzer o loop em toda a tabela a partir da primeira data encontrada.
	lTodos:=.T.
	BeginSql Alias 'QRY'
		SELECT *
		FROM %table:SFI%
		WHERE %notDel% 
		Order By FI_DTMOVTO
	EndSql     
	QRY->(DbGoTop())
	If QRY->(!EOF())
		cData := QRY->FI_DTMOVTO
	EndIF
	QRY->(DbCloseArea())
EndIf

BeginSql Alias 'QRY'
	SELECT *
	FROM %table:SFI%
	WHERE %notDel% 
	AND FI_DTMOVTO >= %exp:cData%
	Order By FI_DTMOVTO
EndSql

QRY->(DbGoTop())
While QRY->(!EOF())
	aAdd(aDados,{QRY->FI_FILIAL,STOD(QRY->FI_DTMOVTO),QRY->FI_GTINI,QRY->FI_GTFINAL,QRY->FI_NUMINI,QRY->FI_NUMFIM})	
	QRY->(DbSkip())
EndDo
QRY->(DbCloseArea())

aSort(aDados,,,{ |x, y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2])  })

cDataAux := cData
For i:=1 to Len(aDados)
	If EMPTY(cFilAux)
		cFilAux := aDados[i][1]
    EndIf
    If cFilAux == aDados[i][1]
		If cDataAux == DTOS(aDados[i][2])
			cDataAux:= DTOS(STOD(cDataAux)+1)
		Else
			BeginSql Alias 'QRY'
				SELECT *
				FROM %table:SL1%
				WHERE %notDel% 
				AND L1_FILIAL  = %exp:cFilAux%
				AND L1_EMISSAO = %exp:cDataAux%
			EndSql
			QRY->(DBGOTOP())
			IF QRY->(!EOF())
				If !lTodos
					aAdd(aErroData,{cFilAux,STOD(cDataAux),0,0,"",""})
				Else
					aAdd(aErroSFI,{cFilAux,STOD(cDataAux),0,0,"",""})
				EndIf
			EndIf
			cDataAux:= DTOS(STOD(cDataAux)+1)
			i--
			QRY->(DbCloseArea())
		EndIf
    Else
	    cDataAux	:= cData
	    cFilAux		:= aDados[i][1]
	    i--
    EndIf
Next i
aSort(aErroData,,,{ |x, y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2])  })
aSort(aErroSFI,,,{ |x, y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2])  })

Return .T.


*------------------------------------*
Static Function RETSX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
		Case cFuncao == "TIT"
			xRet := SX3->X3_TITULO
	EndCase
EndIf
RestOrd(aOrd)
Return xRet    

/*
Funcao      : LoadSFI
Parametros  : 
Retorno     : 
Objetivos   : Carrega todas as informações da SFI
Autor       : Jean Victor Rocha
Data/Hora   : 23/10/2012
TDN         : 
*/
*-----------------------*
User Function LoadSFI()
*-----------------------*
Local oDlg1
Local oPanel1
Local oGraphic2
Local oSBtn1
Local cArq	:= ""

Local cMarca	:= ""//GetMark()
Local aTipos	:= {"N"," "}
Local aColor	:= {CLR_YELLOW,CLR_BLUE,CLR_GREEN,CLR_CYAN,CLR_RED,CLR_MAGENTA,CLR_BROWN,CLR_HGRAY,;
					CLR_GRAY,CLR_HBLUE,CLR_HGREEN,CLR_HCYAN,CLR_HRED,CLR_HMAGENTA,CLR_BLACK,CLR_WHITE}
Local aCamposSFI :=	{{"FI_FILIAL" 	,RETSX3("F1_FILIAL"	, "TIP"),RETSX3("F1_FILIAL"	, "TAM"),RETSX3("F1_FILIAL"	, "DEC")},;
					  {"FI_NOME" 	,"C",15,0},;
					  {"FI_DTMOVTO" ,RETSX3("FI_DTMOVTO", "TIP"),RETSX3("FI_DTMOVTO", "TAM"),RETSX3("FI_DTMOVTO", "DEC")},;
					  {"FI_GTINI" 	,RETSX3("FI_GTINI"	, "TIP"),RETSX3("FI_GTINI"	, "TAM"),RETSX3("FI_GTINI"	, "DEC")},;
					  {"FI_GTFINAL" ,RETSX3("FI_GTFINAL", "TIP"),RETSX3("FI_GTFINAL", "TAM"),RETSX3("FI_GTFINAL", "DEC")},;
					  {"FI_NUMINI" 	,RETSX3("FI_NUMINI"	, "TIP"),RETSX3("FI_NUMINI"	, "TAM"),RETSX3("FI_NUMINI"	, "DEC")},;
					  {"FI_NUMFIM" 	,RETSX3("FI_NUMFIM"	, "TIP"),RETSX3("FI_NUMFIM"	, "TAM"),RETSX3("FI_NUMFIM"	, "DEC")},;
					  {"FI_P_OBS"  	,RETSX3("FI_P_OBS"	, "TIP"),RETSX3("FI_P_OBS"	, "TAM"),RETSX3("FI_P_OBS"	, "DEC")}}
Private aCps :=	{{"FI_FILIAL"	,, "Filial"				,""},;
				{"FI_NOME"		,, "Nome Filial"		,""},;
		 	 	{"FI_DTMOVTO"	,, "Dt. Movim."			,""},;
			  	{"FI_GTINI"		,, "Vlr. Inicial"		,""},;
			  	{"FI_GTFINAL"	,, "Vlr. Final"			,""},;
			  	{"FI_NUMINI"	,, "Num Inicial"		,""},;
			  	{"FI_NUMFIM"	,, "Num Final"			,""},;
				{"FI_P_OBS"		,, "Descrição" 			,""}}

IF !MSGYESNO("Este processamento pode demorar alguns minutos, deseja continuar?")
	Return .F.
EndIf         

If Select("WRK") > 0
	WRK->(DbCloseArea())	               
EndIf
cArq:=CriaTrab(aCamposSFI,.T.)
dbUseArea( .T.,,cArq,"WRK",, .F. )
cArqInd := CriaTrab(,.F.)
IndRegua("WRK",cArqInd,"FI_FILIAL+FI_NUMINI",,,"Selecionando Registros...")
WRK->(DbSetIndex(cArqInd+OrdBagExt()))

ProcRegua(4)
IncProc("Buscando dados para interface...")	
SFIERRO() 
aOrd := SAveOrd({"SM0"})
IncProc("Carregando dados para interface...")	
For i:=1 to Len(aErroSFI)
	WRK->(DbAppend())
	WRK->FI_FILIAL	:= aErroSFI[i][1]
	WRK->FI_DTMOVTO	:= aErroSFI[i][2]
	WRK->FI_GTINI	:= aErroSFI[i][3]
	WRK->FI_GTFINAL	:= aErroSFI[i][4]
	WRK->FI_NUMINI	:= aErroSFI[i][5]
	WRK->FI_NUMFIM	:= aErroSFI[i][6]
	SM0->(DBSEEK("R7"+aErroSFI[i][1]))
	WRK->FI_NOME	:= SM0->M0_FILIAL
	WRK->FI_P_OBS	:= "REDUCAOZ - Sem informação para esta data"
Next i
RestOrd(aOrd)
IncProc("Abrindo interface...")	

WRK->(DbGoTop())

oDlg1 := MSDialog():New( 004,200,593,1095,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oPanel1 := TPanel():New( 004,004,,oDlg1,,.F.,.F.,,,440,270,.T.,.F. )

oBrw2 := MsSelect():New("WRK",,"",aCps,.F.,cMarca,{004,180,270,430},,,oPanel1)
oGraphic2 := TMSGraphic():New( 01,01,oPanel1,,,RGB(239,239,239),175,270)  
oGraphic2:SetTitle("Informações de ReducaoZ - Completo","", CLR_HBLUE, A_LEFTJUST, GRP_TITLE )
oGraphic2:SetMargins(2,6,6,6)

nSerie := oGraphic2:CreateSerie( GRP_BAR )

For i:=1 to Len(aTipos)
	nQtde := BUSCAQTDE(aTipos[i],"SFI")
	Do Case
		Case aTipos[i] == "N"	 
			nQTde := Len(aErroSFI)
			cNome := "Sem Inf./Dia"
		Case aTipos[i] == " "	 
			cNome := "Aguardando integração"
		Otherwise
			cNome := aTipos[i]
	EndCAse
	oGraphic2:Add(nSerie,nQtde,cNome,aColor[4])
Next i    

oSBtn1 := SButton():New( 280,410,1,{|| oDlg1:END()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return .T.