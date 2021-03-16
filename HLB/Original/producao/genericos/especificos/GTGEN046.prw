#Include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#Include "tbiconn.ch"
#include "fwmvcdef.ch"
 
#Define CLR_AZUL      RGB(058,074,119)                  //Cor Azul

//Variaveis
Static COL_T1   := 001              //Primeira Coluna da tela
Static COL_T2   := 123              //Segunda Coluna da tela
Static COL_T3   := 245              //Terceira Coluna da tela
Static COL_T4   := 307              //Quarta Coluna da tela
Static ESP_CAMPO    := 038              //Espaçamento do campo para coluna
Static TAM_FILIAL   := FWSizeFilial()   //Tamanho do campo Filial

 
/*
Funcao      : GTGEN046 
Objetivos   : Permitir o usuário altear os parametros MV que forem liberados
Autor		: Anderson Arrais
Data		: 29/04/2019	
*/
*-----------------------*
User Function GTGEN046()
*-----------------------*
Local aList := {}
Local cParQRY,TEMPSM,cSQL := ""

If !FwIsAdmin() 
	If Select("TEMPSM")>0
		("TEMPSM")->(DbCloseArea())
	EndIf
	
	cSQL := " SELECT Z14_USER FROM P12_00..Z14YY0 
	cSQL += " WHERE Z14_USER = '"+AllTrim(UsrRetName(RetCodUsr()))+"'
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), "TEMPSM", .F., .T.)
	
	Count to nTotArq
	
	If !nTotArq > 0
		//Usuario sem permissão
		MsgStop( "Usuário sem permissão para utilizar essa rotina." )	
		Return 
	EndIf  
EndIf	

//Consulta tabela no ambiente P12_00
If Select("QRY00") > 0
	QRY00->(DbClosearea())
EndIf

cQuery := " SELECT TOP(1)Z16_PARMV1,Z16_PARMV2,Z16_PARMV3 FROM P12_00.dbo.Z16YY0 "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY00",.T.,.T.)  

cParQRY := "{"+QRY00->Z16_PARMV1+QRY00->Z16_PARMV2+QRY00->Z16_PARMV3+"}"

//Cria tabela de log
If !MsFile(RetSqlName("Z15"),,"TOPCONN")
	AtuTab()
	//MsgInfo("Tabela!")
EndIf  

aList	:= &(cParQRY) 

//Função que carrega a tela
zCadSX6(aList)  
                                                                                            
Return 

/*
Funcao      : zCadSX6                
Objetivos   : Lista parâmetros que podem ser alterados
Autor       : Anderson Arrais
*/                   
*-------------------------------*
Static Function zCadSX6(aParams)
*--------------------------------*
Local aArea   		:= GetArea()
Local aAreaX6 		:= SX6->(GetArea())
Local nAtual  		:= 0
Local nColuna 		:= 6
Default aParams 	:= {}
Private aParamsPvt  := {}
Private cParamsPvt  := ""

//Tamanho da Janela
Private aTamanho 	:= MsAdvSize()
Private nJanLarg 	:= aTamanho[5]
Private nJanAltu 	:= aTamanho[6]
Private nColMeio 	:= (nJanLarg)/4
Private nEspCols 	:= ((nJanLarg/2)-12)/4
COL_T1  := 003
COL_T2  := COL_T1+nEspCols
COL_T3  := COL_T2+nEspCols
COL_T4  := COL_T3+nEspCOls

//Objetos gráficos
Private oDlgSX6

//GetDados
Private oMsGet
Private aHeader     := {}
Private aCols       := {}

//Botões
Private aButtons    := {}

aAdd(aButtons,{"Log",    	 			"{|| ListaLog()}", 		"oBtnlog"})
aAdd(aButtons,{"Alterar",    			"{|| fAltera()}", 		"oBtnAltera"})
aAdd(aButtons,{"Visualizar", 			"{|| fVisualiza()}",	"oBtnVisual"})
aAdd(aButtons,{"Manutenção Usuarios", 	"{|| fManutUser()}",	"oBtnUser"})
aAdd(aButtons,{"Sair", 					"{|| oDlgSX6:End()}", 	"oBtnSair"})
 
//Se não tiver parâmetros
If Len(aParams) <= 0
	MsgStop("Parâmetros devem ser informados!", "Atenção")
	Return
Else
	aParamsPvt := aParams
	cParamsPvt := ""
	 
	//Percorrendo os parâmetros e adicionando
	For nAtual := 1 To Len(aParamsPvt)
		cParamsPvt += aParamsPvt[nAtual]+";"
	Next
EndIf
     
//Adicionando cabeçalho
aAdd(aHeader,{"Filial",     "ZZ_FILIAL",    "@!",   TAM_FILIAL, 	0,  ".F.",  ".F.",  "C",    "", ""  ,})
aAdd(aHeader,{"Parâmetro",  "ZZ_PARAME",    "@!",   010,            0,  ".F.",  ".F.",  "C",    "", ""  ,})
aAdd(aHeader,{"Tipo",       "ZZ_TIPO",      "@!",   001,            0,  ".F.",  ".F.",  "C",    "", ""  ,})
aAdd(aHeader,{"Descrição",  "ZZ_DESCRI",    "@!",   150,            0,  ".F.",  ".F.",  "C",    "", ""  ,})
aAdd(aHeader,{"Conteúdo",   "ZZ_CONTEU",    "@!",   250,            0,  ".F.",  ".F.",  "C",    "", ""  ,})
aAdd(aHeader,{"RecNo",      "ZZ_RECNUM",    "",     018,            0,  ".F.",  ".F.",  "N",    "", ""  ,})
 
//Atualizando o aCols
fAtuaCols(.T.)
     
//Criando a janela
DEFINE MSDIALOG oDlgSX6 TITLE "HLB BRASIL - Parâmetros" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	oMsGet := MsNewGetDados():New(  3,;                                     //nTop
										3,;                                     //nLeft
										(nJanAltu/2)-33,;                       //nBottom
										(nJanLarg/2)-3,;                        //nRight
										GD_INSERT+GD_DELETE+GD_UPDATE,;     	//nStyle
										"AllwaysTrue()",;                       //cLinhaOk
										,;                                      //cTudoOk
										"",;                                    //cIniCpos
										,;                                      //aAlter
										,;                                      //nFreeze
										999999,;                                //nMax
										,;                                      //cFieldOK
										,;                                      //cSuperDel
										,;                                      //cDelOk
										oDlgSX6,;                               //oWnd
										aHeader,;                               //aHeader
										aCols)                                  //aCols  
	oMsGet:lActive := .F.
 
	//Grupo Legenda
	@ (nJanAltu/2)-30, 003  GROUP oGrpLeg TO (nJanAltu/2)-3, (nJanLarg/2)-3     PROMPT "Ações: "        OF oDlgSX6 COLOR 0, 16777215 PIXEL
	//Adicionando botões
	For nAtual := 1 To Len(aButtons)
		@ (nJanAltu/2)-20, nColuna  BUTTON &(aButtons[nAtual][3]) PROMPT aButtons[nAtual][1]   SIZE 60, 014 OF oDlgSX6  PIXEL
		(&(aButtons[nAtual][3]+":bAction := "+aButtons[nAtual][2]))
		nColuna += 63
	Next
ACTIVATE MSDIALOG oDlgSX6 CENTERED
 
RestArea(aAreaX6)
RestArea(aArea)

Return

/*
Funcao      : ListaLog                
Objetivos   : Lista log de alteração dos parâmetros
Autor       : Anderson Arrais
*/
*------------------------* 
Static Function ListaLog()  
*------------------------* 
DbSelectArea("Z15")
Z15->(DbSetOrder(1)) 
Z15->(DbGoTop())

aBrowse:={}

While Z15->(!EOF())

	AADD(aBrowse,{Z15->Z15_FILIAL,Z15->Z15_DATA,Z15->Z15_HORA,Z15->Z15_PARMV,Z15->Z15_USR,Z15->Z15_INFOLD,Z15->Z15_INFNEW})
	Z15->(DbSkip())

Enddo

if empty(aBrowse)
	AADD(aBrowse,{"","","","","","",""})
endif
		
DEFINE DIALOG oDlg TITLE "Log" FROM 150,150 TO 552,950 PIXEL

	// Cria Browse
	oBrowse := TCBrowse():New( 01 , 01, 400, 200,, {'Filial','Data','Hora','Parâmetro','Usuário','Informação Anterior','Informação Nova'},{20,50,50,50}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowse:SetArray(aBrowse)

	// Monta a linha a ser exibina no Browse
	oBrowse:bLine := {||{	aBrowse[oBrowse:nAt,01],;
							aBrowse[oBrowse:nAt,02],;
							aBrowse[oBrowse:nAt,03],;
							aBrowse[oBrowse:nAt,04],;
							aBrowse[oBrowse:nAt,05],;
							aBrowse[oBrowse:nAt,06],;
							aBrowse[oBrowse:nAt,07]	} }

ACTIVATE DIALOG oDlg CENTERED
 
Return

/*
Funcao      : fAltera                
Objetivos   : Altera o conteúdo do parâmetro
Autor       : Anderson Arrais
*/
*------------------------*
Static Function fAltera()
*------------------------*
Local nAtual   := oMsGet:nAt
Local aColsAux := oMsGet:aCols
Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
 
//Se tiver recno válido
If aColsAux[nAtual][nPosRecNo] != 0
	fMontaTela(4, aColsAux[nAtual][nPosRecNo])
EndIf

Return
 
/*
Funcao      : fVisualiza                
Objetivos   : Visualiza o conteúdo do parâmetro
Autor       : Anderson Arrais
*/
*---------------------------*
Static Function fVisualiza()
*---------------------------*
Local nAtual   := oMsGet:nAt
Local aColsAux := oMsGet:aCols
Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
 
//Se tiver recno válido
If aColsAux[nAtual][nPosRecNo] != 0
	fMontaTela(2, aColsAux[nAtual][nPosRecNo])
EndIf

Return
 
/*
Funcao      : fAtuaCols                
Objetivos   : Atualiza os parâmetros
Autor       : Anderson Arrais
*/
*--------------------------------*
Static Function fAtuaCols(lFirst)
*--------------------------------*
Local aAreaSX6 := SX6->(GetArea())
aCols := {}
 
//Selecionando a tabela de parâmetros e indo ao topo
DbSelectArea("SX6")
SX6->(DbGoTop())
 
//Percorrendo os parâmetros, e adicionando somente os que estão na filtragem
While !SX6->(EoF())
	If Alltrim(SX6->X6_VAR) $ cParamsPvt
		aAdd( aCols, {  SX6->X6_FIL,;                                            //Filial
							SX6->X6_VAR,;                                        //Parâmetro
							SX6->X6_TIPO,;                                       //Tipo
							SX6->X6_DESCRIC+SX6->X6_DESC1+SX6->X6_DESC2,;        //Descrição
							SX6->X6_CONTEUD,;                                    //Conteúdo
							SX6->(RecNo()),;                                     //RecNo
							.F.})                                                //Excluído?
	EndIf
 
	SX6->(DbSkip())
EndDo
 
//Se tiver zerada, adiciona conteúdo em branco
If Len(aCols) == 0
	aAdd( aCols, {  "",;        //Filial
					"",;        //Parâmetro
					"",;        //Tipo
					"",;        //Descrição
					"",;        //Conteúdo
					0,;         //RecNo
					.F.})       //Excluído?
EndIf
 
//Senão for a primeira vez, atualiza grid
If !lFirst
	oMsGet:setArray(aCols)
EndIf

RestArea(aAreaSX6)

Return

/*
Funcao      : fMontaTela                
Objetivos   : Atualiza o aCols com os parâmetros
Autor       : Anderson Arrais
*/ 
*---------------------------------------*
Static Function fMontaTela(nOpcP, nRecP)
*---------------------------------------*
Local nColuna := 6
Local nEsp := 15
Private nOpcPvt := nOpcP
Private nRecPvt := nRecP
Private aOpcTip := {" ", "C - Caracter", "N - Numérico", "L - Lógico", "D - Data", "M - Memo"}
Private oFontNeg := TFont():New("Tahoma")
Private oDlgEdit
//Campos
Private oGetFil, cGetFil
Private oGetPar, cGetPar
Private oGetTip, cGetTip
Private oGetDes, cGetDes
Private oGetCon, cGetCon
Private oGetRec, nGetRec
//Botões
Private aBtnPar := {}
aAdd(aBtnPar,{"Confirmar",   "{|| fBtnEdit(1)}", "oBtnConf"})
aAdd(aBtnPar,{"Cancelar",    "{|| fBtnEdit(2)}", "oBtnCanc"})
 
//Se não for inclusão, pega os campos conforme array
If nOpcP != 3
	aColsAux := oMsGet:aCols
	nLinAtu  := oMsGet:nAt
	nPosFil  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_FILIAL" })
	nPosPar  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_PARAME" })
	nPosTip  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_TIPO" })
	nPosDes  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_DESCRI" })
	nPosCon  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_CONTEU" })
	nPosRec  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	//Atualizando gets
	cGetFil := aColsAux[nLinAtu][nPosFil]
	cGetPar := aColsAux[nLinAtu][nPosPar]
	cGetTip := aColsAux[nLinAtu][nPosTip]
	cGetDes := aColsAux[nLinAtu][nPosDes]
	cGetCon := aColsAux[nLinAtu][nPosCon]
	nGetRec := aColsAux[nLinAtu][nPosRec]

	//Caracter
	If cGetTip == "C"
		cGetTip := aOpcTip[2]
	//Numérico
	ElseIf cGetTip == "N"
		cGetTip := aOpcTip[3]
	//Lógico
	ElseIf cGetTip == "L"
		cGetTip := aOpcTip[4]
	//Data
	ElseIf cGetTip == "D"
		cGetTip := aOpcTip[5]
	//Memo
	ElseIf cGetTip == "M"
		cGetTip := aOpcTip[6]
	EndIf

//Senão, deixa os campos zerados
Else
 
	//Atualizando gets
	cGetFil := Space(TAM_FILIAL)
	cGetPar := Space(010)
	cGetTip := aOpcTip[1]
	cGetDes := Space(150)
	cGetCon := Space(250)
	nGetRec := 0
EndIf
 
oFontNeg:Bold := .T.
 
//Criando a janela
DEFINE MSDIALOG oDlgEdit TITLE "Dados:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	nLinAux := 6
		//Filial
		@ nLinAux    , COL_T1                       SAY             oSayFil PROMPT  "Filial:"                       SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL                           PIXEL
		@ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetFil VAR     cGetFil                     SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
		//Parâmetro
		@ nLinAux    , COL_T2                       SAY             oSayPar PROMPT  "Parâmetro:"                    SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL
		@ nLinAux-003, COL_T2+ESP_CAMPO         	MSCOMBOBOX      oGetPar VAR     cGetPar ITEMS aParamsPvt        SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
		//Tipo
		@ nLinAux    , COL_T3                       SAY             oSayTip PROMPT  "Tipo:"                     SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL
		@ nLinAux-003, COL_T3+ESP_CAMPO             MSCOMBOBOX      oGetTip VAR     cGetTip ITEMS aOpcTip       SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
		//RecNo
		@ nLinAux    , COL_T4                       SAY             oSayRec PROMPT  "RecNo:"                    SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL                           PIXEL
		@ nLinAux-003, COL_T4+ESP_CAMPO             MSGET           oGetRec VAR     nGetRec                     SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
	nLinAux += nEsp
		//Descrição
		@ nLinAux    , COL_T1                       SAY             oSayDes PROMPT  "Descrição:"                SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL
		@ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetDes VAR     cGetDes                     SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
	nLinAux += nEsp
		//Conteúdo
		@ nLinAux    , COL_T1                       SAY             oSayCon PROMPT  "Conteúdo:"                 SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL
		@ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetCon VAR     cGetCon                     SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
 
	//Grupo Legenda
	@ (nJanAltu/2)-30, 003  GROUP oGrpLegEdit TO (nJanAltu/2)-3, (nJanLarg/2)-3     PROMPT "Ações (Confirmação): "      OF oDlgEdit COLOR 0, 16777215 PIXEL
	//Adicionando botões
	For nAtual := 1 To Len(aBtnPar)
		@ (nJanAltu/2)-20, nColuna  BUTTON &(aBtnPar[nAtual][3]) PROMPT aBtnPar[nAtual][1]   SIZE 60, 014 OF oDlgEdit  PIXEL
		(&(aBtnPar[nAtual][3]+":bAction := "+aBtnPar[nAtual][2]))
		nColuna += 63
	Next
	 
	//Se for visualização todos os gets serão desabilitados
	If nOpcP == 2 .Or. nOpcP == 5
		oGetFil:lActive := .F.
		oGetPar:lActive := .F.
		oGetTip:lActive := .F.
		oGetDes:lActive := .F.
		oGetCon:lActive := .F.
	Else
		//Se for alteração, desabilita a Filial, Parâmetro, Tipo e descrição
		If nOpcP == 4
			oGetFil:lActive := .F.
			oGetPar:lActive := .F.
			oGetTip:lActive := .F.  
			oGetDes:lActive := .F.
		EndIf
	EndIf
	 
	//Campo de RecNo sempre será desabilitado
	oGetRec:lActive := .F.
ACTIVATE MSDIALOG oDlgEdit CENTERED

Return

/*
Funcao      : fBtnEdit                
Objetivos   : Função que confirma a tela 
Autor       : Anderson Arrais
*/ 
*------------------------------* 
Static Function fBtnEdit(nConf)
*------------------------------*
Local aAreaAux := GetArea()
Local cOld		:= ""
 
//Se for o Cancelar
If nConf == 2
	oDlgEdit:End()
//Se for o Confirmar
ElseIf nConf == 1
	//Se for visualizar
	If nOpcPvt == 2
		oDlgEdit:End()
		 
	//Senão for visualizar
	Else
		//Descrição ou conteúdo em branco?
		If Empty(cGetDes) .Or. Empty(cGetCon)
			If !MsgYesNo("O campo <b>Descrição</b> e/ou <b>Conteúdo</b> estão com conteúdo em branco!<br>Deseja continuar?", "Atenção")
				Return
			EndIf
		EndIf
	 
		//Alterar
		SX6->(DbGoTo(nRecPvt))
		cOld :=	SX6->X6_CONTEUD
		RecLock("SX6", .F.)
		X6_DESCRIC      := SubStr(cGetDes,001,50)
		X6_DESC1        := SubStr(cGetDes,051,50)
		X6_DESC2        := SubStr(cGetDes,101,50)
		X6_CONTEUD      := cGetCon
		SX6->(MsUnlock())
		 
		oDlgEdit:End()
		LOGGEN046(X6_VAR,cOld,cGetCon)
	
	EndIf
	 
	//Atualizando a grid
	fAtuaCols(.F.)
EndIf
 
RestArea(aAreaAux)

Return

*------------------------------*
Static Function AtuTab()
*------------------------------*
Local aSX3:= {}
Local aSX2:= {}
Local aSIX:= {}        
Local cTexto:=""

************************************************************************************************************************************
//{SIX} - Índice
//AADD(aSix,{INDICE,ORDEM,CHAVE,DESCRICAO,DESCSPA,DESCENG,PROPRI,F3,NICKNAME,SHOWPESQ})

AADD(aSix,{'Z15','1','Z15_FILIAL+Z15_DATA+Z15_HORA','Data + Hora','Data + Hora','Data + Hora','U','','','S'})

************************************************************************************************************************************
//{SX2} - Tabela
//AADD(aSX2,{X2_CHAVE,X2_PATH,X2_ARQUIVO,X2_NOME,X2_NOMESPA,X2_NOMEENG,X2_ROTINA,X2_MODO,X2_MODOUN,X2_MODOEMP,X2_DELET,X2_TTS,X2_UNICO,X2_PYME,X2_MODULO,X2_DISPLAY,X2_SYSOBJ,X2_USROBJ})

AADD(aSX2,{'Z15','\SYSTEM\','Z15'+cEmpAnt+'0','Log Alteracao Parametro','Log Alteracao Parametro','Log Alteracao Parametro','','C','C','C','','','','S','','','',''})

************************************************************************************************************************************
//{SX3} - Campos
//AADD(aSX3,{X3_ARQUIVO,X3_ORDEM,X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_TITSPA,X3_TITENG,X3_DESCRIC,X3_DESCSPA,X3_DESCENG,X3_PICTURE,X3_VALID,X3_USADO,X3_RELACAO,X3_F3,X3_NIVEL,X3_RESERV,X3_CHECK,X3_TRIGGER,X3_PROPRI,X3_BROWSE,X3_VISUAL,X3_CONTEXT,X3_OBRIGAT,X3_VLDUSER,X3_CBOX,X3_CBOXSPA,X3_CBOXENG,X3_PICTVAR,X3_WHEN,X3_INIBRW,X3_GRPSXG,X3_FOLDER,X3_PYME,X3_CONDSQL,X3_CHKSQL,X3_IDXSRV,X3_ORTOGRA,X3_IDXFLD,X3_TELA,X3_AGRUP})

AADD(aSX3,{'Z15','01','Z15_FILIAL'	,'C','2','','Filial','Filial','Filial','Filial','Filial','Filial','','','€€€€€€€€€€€€€€€','','','','™€','','','U','N','','','','','','','','','','','033','1','','','','','','','',''})
AADD(aSX3,{'Z15','02','Z15_DATA'	,'D','8','','Data','Data','Date','Data','Data','Date','@!','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','N','A','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z15','03','Z15_HORA'	,'C','8','','Hora','Hora','Time','Hora','Hora','Time','@!','','€€€€€€€€€€€€€€ ','','','','þA','','S','U','N','A','R','€','','','','','','','','','1','','','','','N','N','',''})
AADD(aSX3,{'Z15','04','Z15_PARMV'	,'C','10','','Nosso Numero','Nosso Numero','Nosso Numero','Nosso Numero','Nosso Numero','Nosso Numero','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z15','05','Z15_ID'		,'C','6','','Id Usuario','Id Usuario','Id Usuario','Id Usuario','Id Usuario','Id Usuario','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z15','06','Z15_USR'		,'C','15','','Nome Usuario','Nome Usuario','Nome Usuario','Nome Usuario','Nome Usuario','Nome Usuario','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z15','07','Z15_INFOLD'	,'C','250','','Inf. Anterior','Inf. Anterior','Inf. Anterior','Inf. Anterior','Inf. Anterior','Inf. Anterior','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})
AADD(aSX3,{'Z15','08','Z15_INFNEW'	,'C','250','','Inf. Nova','Inf. Nova','Inf. Nova','Inf. Nova','Inf. Nova','Inf. Nova','@!','','€€€€€€€€€€€€€€ ','','','','þA','','','U','N','A','R','','','','','','','','','','','','','','','N','N','',''})

****************************************************************************************************************************************** 

//<Chamada das funções para a criação dos dicionários -- **NÃO MEXER** >
CriaSx3(aSX3,@cTexto)

CriaSx2(aSX2,@cTexto)

CriaSix(aSIX,@cTexto) 

//<FIM - Chamada das funções para a criação dos dicionários >

Return(cTexto)

*-----------------------------------*
Static Function CriaSx3(aSX3,cTexto)
*-----------------------------------*

Local lIncSX3	:= .F.

For i:=1 to len(aSX3)
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	if SX3->(!DbSeek(aSX3[i][3]))
		lIncSX3:=.T.
	else
		lIncSX3:=.F.
	endif
	
	Reclock("SX3",lIncSX3)
	
		SX3->X3_ARQUIVO	:= aSX3[i][1]
		SX3->X3_ORDEM	:= aSX3[i][2]
		SX3->X3_CAMPO	:= aSX3[i][3]
		SX3->X3_TIPO    := aSX3[i][4]
		SX3->X3_TAMANHO := val(aSX3[i][5])
		SX3->X3_DECIMAL := val(aSX3[i][6])
	
		if FieldPos("X3_TITULO")>0
			SX3->X3_TITULO:= aSX3[i][7]
		endif
		if FieldPos("X3_TITSPA")>0
			SX3->X3_TITSPA:= aSX3[i][8]
		endif
		if FieldPos("X3_TITENG")>0
			SX3->X3_TITENG:= aSX3[i][9]
		endif
		if FieldPos("X3_DESCRIC")>0
			SX3->X3_DESCRIC:= aSX3[i][10]
		endif
		if FieldPos("X3_DESCSPA")>0
			SX3->X3_DESCSPA:= aSX3[i][11]
		endif
		if FieldPos("X3_DESCENG")>0
			SX3->X3_DESCENG:= aSX3[i][12]
		endif
	
		SX3->X3_PICTURE := aSX3[i][13]
		SX3->X3_VALID   := aSX3[i][14]
		SX3->X3_USADO   := aSX3[i][15]
		SX3->X3_RELACAO := aSX3[i][16]
		SX3->X3_F3      := aSX3[i][17]
		SX3->X3_NIVEL   := val(aSX3[i][18])
		SX3->X3_RESERV  := aSX3[i][19]
		SX3->X3_CHECK   := aSX3[i][20]
		SX3->X3_TRIGGER := aSX3[i][21]
		SX3->X3_PROPRI  := aSX3[i][22]
		SX3->X3_BROWSE  := aSX3[i][23]
		SX3->X3_VISUAL  := aSX3[i][24]
		SX3->X3_CONTEXT := aSX3[i][25]
		SX3->X3_OBRIGAT := aSX3[i][26]
		SX3->X3_VLDUSER := aSX3[i][27]
		SX3->X3_CBOX    := aSX3[i][28]
		SX3->X3_CBOXSPA := aSX3[i][29]
		SX3->X3_CBOXENG := aSX3[i][30]
		SX3->X3_PICTVAR := aSX3[i][31]
		SX3->X3_WHEN    := aSX3[i][32]
		SX3->X3_INIBRW  := aSX3[i][33]
		SX3->X3_GRPSXG  := aSX3[i][34]
		SX3->X3_FOLDER  := aSX3[i][35]
		SX3->X3_PYME    := aSX3[i][36]
		SX3->X3_CONDSQL := aSX3[i][37]
		SX3->X3_CHKSQL  := aSX3[i][38]
		SX3->X3_IDXSRV  := aSX3[i][39]
		SX3->X3_ORTOGRA := aSX3[i][40]
		SX3->X3_IDXFLD  := aSX3[i][41]
		SX3->X3_TELA    := aSX3[i][42]
		SX3->X3_AGRUP   := aSX3[i][43]
	
	SX3->(MsUnlock())
	
Next	

Return


*-----------------------------------*
Static Function CriaSx2(aSX2,cTexto)
*-----------------------------------*

Local lIncSX2	:= .F.

For i:=1 to len(aSX2)
	
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if SX2->(!DbSeek(aSX2[i][1]))
		lIncSX2:=.T.
	else
		lIncSX2:=.F.
	endif  
	
	Reclock("SX2",lIncSX2)

		SX2->X2_CHAVE	:= aSX2[i][1]
		SX2->X2_PATH	:= aSX2[i][2]
		SX2->X2_ARQUIVO	:= aSX2[i][3]
		SX2->X2_NOME	:= aSX2[i][4]
		if FieldPos("X2_NOMESPA")>0
			SX2->X2_NOMESPA	:= aSX2[i][5]
		endif
		
		if FieldPos("X2_NOMEENG")>0
			SX2->X2_NOMEENG	:= aSX2[i][6]
		endif
		SX2->X2_ROTINA	:= aSX2[i][7]
		SX2->X2_MODO	:= aSX2[i][8]
		SX2->X2_MODOUN	:= aSX2[i][9]
		SX2->X2_MODOEMP	:= aSX2[i][10]
		SX2->X2_DELET	:= val(aSX2[i][11])
		SX2->X2_TTS		:= aSX2[i][12]
		SX2->X2_UNICO	:= aSX2[i][13]
		SX2->X2_PYME	:= aSX2[i][14]
		SX2->X2_MODULO	:= val(aSX2[i][15])
		SX2->X2_DISPLAY	:= aSX2[i][16]
		SX2->X2_SYSOBJ	:= aSX2[i][17]
		SX2->X2_USROBJ	:= aSX2[i][18]
	
	SX2->(MsUnlock())

Next	

Return

*-----------------------------------*
Static Function CriaSix(aSix,cTexto)
*-----------------------------------*

Local lIncSix	:= .F.

For i:=1 to len(aSix)

	DbSelectArea("SIX")
	SIX->(DbSetOrder(1))
	if SIX->(!DbSeek(PADR(aSix[i][1],3)+aSix[i][2]))
		lIncSIX:=.T.
	else
		lIncSIX:=.F.
	endif
	
	Reclock("SIX",lIncSIX)
		
		SIX->INDICE		:= aSix[i][1]
		SIX->ORDEM		:= aSix[i][2]
		SIX->CHAVE  	:= aSix[i][3]
		SIX->DESCRICAO  := aSix[i][4]
		SIX->DESCSPA	:= aSix[i][5]
		SIX->DESCENG	:= aSix[i][6]
		SIX->PROPRI		:= aSix[i][7]
		SIX->&('F3')	:= aSix[i][8]
		SIX->NICKNAME	:= aSix[i][9]
		SIX->SHOWPESQ	:= aSix[i][10]

	SIX->(MsUnlock())	
	
Next

Return

/*
Funcao      : LOGGEN046 
Parametros  : (X6_VAR,X6_CONTEUD,cGetCon) 
Retorno     : .T.
Objetivos   : Grava na Z15 arquivo de log
*/
*---------------------------------------------------*
 Static Function LOGGEN046(cVar,cConteudo,cGetCon) 
*---------------------------------------------------*
//Cria Tabela de Log caso não exista
ChkFile("Z15")

DbSelectArea("Z15")
RecLock("Z15",.T.)
	Z15->Z15_FILIAL		:= xFilial("Z15")
	Z15->Z15_DATA		:= DATE()
	Z15->Z15_HORA		:= TIME() 
	Z15->Z15_PARMV		:= cVar
	Z15->Z15_ID			:= AllTrim(RetCodUsr())
	Z15->Z15_USR		:= AllTrim(UsrRetName(RetCodUsr()))
	Z15->Z15_INFOLD		:= cConteudo 
	Z15->Z15_INFNEW		:= cGetCon
Z15->(MsUnlock())

Return .T.  

/*
Funcao      : fManutUser                
Objetivos   : Faz manutenção nos usuarios que tem permissão para usar a rotina
Autor       : Anderson Arrais
*/
*---------------------------------------------------------------------------------------------------* 
Static Function fManutUser()  
*----------------------------------------------------------------------------------------------------* 
Local cQuery := "", nOp := 0, oDlg, aButtons := {}
Private oNewGetDb, aTELA[0], aGETS[0], aHeader := {}, aCols := {}

BuscaRegs()

TMPZ14->(DbClearFilter())
TMPZ14->(DbGoTop())
Do While TMPZ14->(!Eof())
	aAdd(aCols,{TMPZ14->Z14_USER,.F.})
	TMPZ14->(DbSkip())
EndDo

aAdd(aButtons,{"SDUPROP", {|| ManutReg(3),oNewGetDb:Refresh(),oDlg:End()}, "Incluir"	})
aAdd(aButtons,{"SDUPROP", {|| ManutReg(5),oNewGetDb:Refresh(),oDlg:End()}, "Excluir"	})

//            cTitulo       , cCampo   , cPicture  , nTamanho	, nDecimais	, cValidação	, cReservado, cTipo, xReservado1, xReservado2
Aadd(aHeader,{"Usuário"		,"Z14_USER", ""		   , 25		    , 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })

DEFINE MSDIALOG oDlg TITLE "Usuários" FROM 100,100 TO 500,700 PIXEL

	oNewGetDb := MsNewGetDados():New(01 , 01, 100, 50,2,,,,{},,120,,,.F.,oDlg,aHeader,aCols)
	oNewGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oNewGetDb:oBrowse:lUseDefaultColors := .F.
	oNewGetDb:OnChange()
	oNewGetDb:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| (oDlg:End())},{|| (oDlg:End())},,aButtons)) CENTERED
 
Return

*-------------------------*
Static Function BuscaRegs()
*-------------------------*
Local cQuery := "", cArqTmp, FileWork1
Local lTemEmp := .F.
Local aCpEmp := {	{"Z14_USER"   ,"C",25,0}}
					
If Select("QRY") > 0
	QRY->(DbClosearea())
EndIf
cQuery := " SELECT Z14_USER FROM P12_00.dbo.Z14YY0 "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

If Select("TMPZ14") > 0
	TMPZ14->(DbClosearea())
EndIf     	      
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,,cArqTmp,"TMPZ14",.F.,.F.)                                                  
IndRegua("TMPZ14",cArqTmp+OrdBagExt(),"Z14_USER")
SET INDEX TO (cArqTmp+OrdBagExt())

TMPZ14->(DbClearFilter())

QRY->(DbGoTop())
Do While QRY->(!Eof())
		TMPZ14->(DbAppend())
		TMPZ14->Z14_USER	:= QRY->Z14_USER
	QRY->(DbSkip())
EndDo

Return NIL       

*----------------------------*
Static Function ManutReg(nOpc)
*----------------------------*
Local oDlg, oGroup1, nOp := 0, cTipo
Local oGet1

If nOpc == 3
	oNewGetDb:aCols[oNewGetDb:nAt][1]  := SPACE(25)
	cTipo := "Inclusão"
ElseIf nOpc == 5
	cTipo := "Exclusão"
EndIf

DEFINE MSDIALOG oDlg TITLE "Manutenção de permissões" FROM 000, 000  TO 200, 315 PIXEL
	
    @ 035, 010 SAY oSay0 PROMPT cTipo + " de usuário:" SIZE 058, 007 OF oDlg PIXEL
    @ 045, 008 GROUP oGroup1 TO 90, 150 PROMPT " Usuário " OF oDlg PIXEL//241
    
    @ 060, 012 SAY		oSay1 PROMPT "Usuário:"	SIZE 038, 007 OF oGroup1 PIXEL
    @ 059, 048 MSGET	oGet1 VAR oNewGetDb:aCols[oNewGetDb:nAt][1] PICTURE "@"  SIZE 80, 010 OF oGroup1 PIXEL                       
	
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| (GravaZ14(nOpc), oDlg:End())},{||oDlg:End()})) CENTERED

Return         

*----------------------------*
Static Function GravaZ14(nOp)
*----------------------------*
Local cQuery := "", i, nRecno, cCodSQL, cCodDet

Begin Sequence
    
If nOp == 5
	cQuery := " DELETE FROM P12_00.dbo.Z14YY0 WHERE Z14_USER='"+oNewGetDb:aCols[oNewGetDb:nAt][1]+"'"
	If TCSQLEXEC(cQuery) # 0
		MsgAlert("Erro na exclusão de registros." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
	EndIf
ElseIf nOp == 3	
	cQuery := " INSERT INTO P12_00.dbo.Z14YY0"
	cQuery += "(Z14_USER) "
	cQuery += " VALUES("
	cQuery += " '"+oNewGetDb:aCols[oNewGetDb:nAt][1]+"' ) "
	
	If TCSQLEXEC(cQuery) # 0
		MsgAlert("Erro na inclusão: '" + AllTrim(oNewGetDb:aCols[i][1]) + "'." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
	EndIf
EndIf

BuscaRegs()
oNewGetDb:Refresh()

End Sequence

Return NIL