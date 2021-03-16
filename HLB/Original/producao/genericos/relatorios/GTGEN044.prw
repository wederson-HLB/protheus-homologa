#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"

#define DLG_LIN_INI (oMainWnd:ReadClientCoords(),oMainWnd:nTop+If(SetMDIChild(),0,If("CLIENTAX"$UPPER(GETCLIENTDIR()),231.5,115) ))
#define DLG_COL_INI (oMainWnd:nLeft+5)
#define DLG_LIN_FIM (oMainWnd:nBottom-If(SetMDIChild(),70,If("CLIENTAX"$UPPER(GETCLIENTDIR()),(-55),60)))
#define DLG_COL_FIM (oMainWnd:nRight-If("CLIENTAX"$UPPER(GETCLIENTDIR()),5,10))

/*/{Protheus.doc} GTGEN044
@author Anderson Arrais
@since 23/05/2018
@type function
@description Central de Relatórios
@table Z17
/*/
*----------------------*
User Function GTGEN044()
*----------------------*
Local oWizArq, oPanel, oDlg
Private cArq, oBrowEmp, cWork
Private cAmb	:= "P12"

//AOA - 21/01/2019 - Ajuste para validar se está na versão 11 ou 12
If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	cAmb	:= "P11"
EndIf

GeraF3()
DEFINE DIALOG oDlg TITLE 'Central de Relatórios' PIXEL
	oDlg:nWidth := 602
	oDlg:nHeight := 580
	
	oPanel:= TPanel():New(0,0,"",oDlg,,,,,,300,280)
	
	oWizArq := FWWizardControl():New(oPanel)
	oWizArq:ActiveUISteps()
	
	oNewPag := oWizArq:AddStep("1")
	oNewPag:SetStepDescription("Boas-Vindas")
	oNewPag:SetConstruction({|oPanel| CriaPagina(1, oPanel)})
	oNewPag:SetNextAction({|| .T.})
	oNewPag:SetCancelAction({|| (oDlg:End(),.T.)})

	oNewPag := oWizArq:AddStep("2")
	oNewPag:SetStepDescription("Seleção de Relatórios")
	oNewPag:SetConstruction({|oPanel| CriaPagina(2, oPanel)})
	oNewPag:SetNextTitle("Gerar")
	oNewPag:SetNextAction({|| If(TMPZ17->(RecCount()) # 0 ,If(MsgYesNo("Deseja gerar o relatório selecionado?"),(Relatorio(),oDlg:End(),.T.),.F.),(Alert("Não há relatórios disponíveis para geração."),.F.))})
	oNewPag:SetCancelAction({|| (oDlg:End(),.T.)})
	
	oWizArq:Activate()

ACTIVATE DIALOG oDlg CENTER
oWizArq:Destroy()

If Select("WKMODU") # 0
	WKMODU->(DbCloseArea())
	FErase(cWork)
EndIf

Return NIL

*------------------------------------------*
Static Function CriaPagina(nPagina, oPanel)
*------------------------------------------*
Local oSay1, oSay2, oSay3
Local oFont := TFont():New("Arial",,16)
Local oFont1 := TFont():New("Arial",,20,,.T.)

Do Case
	Case nPagina == 1
		oSay1:= TSay():New(10,85,{||'Bem-vindo a Central de Relatórios'},oPanel,,oFont1,,,,.T.,,,250,20)
		oSay2:= TSay():New(40,10,{||'Aqui encontram-se os principais relatórios para utilização.'},oPanel,,oFont,,,,.T.,,,250,20)
		oSay3:= TSay():New(50,10,{||'Clique em "Avançar" para selecionar o relatório desejado.'},oPanel,,oFont,,,,.T.,,,250,20)
	
	Case nPagina == 2
	
		BuscaRegs()

		If FwIsAdmin()
			oPanel1 := TPanel():New(17,01,"",oPanel,,.T.,,,,295,158)
			oTButton1 := TButton():New( 01, 01, "Parâmetros",oPanel,{|| (ADM012CAD(),oBrowEmp:GoTop(.T.),oBrowEmp:Refresh()) }, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
		Else
			oPanel1 := TPanel():New(01,01,"",oPanel,,.T.,,,,295,175)
		EndIf
		oBrowEmp := FwBrowse():New()
		oBrowEmp:SetOwner(oPanel1)
		oBrowEmp:SetDataTable(.T.)
		oBrowEmp:SetAlias("TMPZ17")
		
		// Adiciona as colunas do Browse	
		oColumn := FWBrwColumn():New()
		oColumn:SetData({||Z17_COD})
		oColumn:SetTitle("Código")
		oColumn:SetSize(8)
		oBrowEmp:SetColumns({oColumn})
		 
		// Adiciona as colunas do Browse	
		oColumn := FWBrwColumn():New()
		oColumn:SetData({||Z17_DESCR})
		oColumn:SetTitle("Descrição")
		oColumn:SetSize(50)
		oBrowEmp:SetColumns({oColumn})
		
		oBrowEmp:cFilterDefault := "TMPZ17->Z17_MSBLQL <> '1' .AND. (AllTrim(StrZero(nModulo,2)) $ TMPZ17->Z17_AGRUP .OR. ('TODOS' $ TMPZ17->Z17_AGRUP))"
		oBrowEmp:bHeaderClick := {|| SetOrdem(), oBrowEmp:Refresh()}
		oBrowEmp:bLDBLClick := {|| MsgInfo(TMPZ17->Z17_DETALH,"Descrição Detalhada")}
		oBrowEmp:DisableConfig()
		oBrowEmp:DisableReport()
		oBrowEmp:Activate()

End Case

Return NIL

*-------------------------*
Static Function BuscaRegs()
*-------------------------*
Local cQuery := "", cArqTmp, FileWork1, FileWork2
Local lTemEmp := .F.
Local aCpEmp := {	{"Z17_COD"   ,"C",08,0},;
					{"Z17_AGRUP" ,"C",50,0},;
					{"Z17_VIEW"  ,"C",30,0},;
					{"Z17_SQL"   ,"M",80,0},;
					{"Z17_DESCR" ,"C",50,0},;
					{"Z17_MSBLQL","C",01,0},;
					{"Z17_DETALH","M",80,0}	}

//Valida se a empresa deve ser tratada com relatorios especificos.
If Select("QRY") > 0
	QRY->(DbClosearea())
EndIf
cQuery := " SELECT COUNT(*) as QTDE FROM "+cAmb+"_01.dbo.Z17YY0 WHERE D_E_L_E_T_ = '' AND Z17_EMP = '"+cEmpAnt+"' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
lTemEmp := QRY->QTDE <> 0
If Select("QRY") > 0
	QRY->(DbClosearea())
EndIf   
 
//Busca os relatorios disponiveis para empresa 
If Select("QRY") > 0
	QRY->(DbClosearea())
EndIf
cQuery := " SELECT * FROM "+cAmb+"_01.dbo.Z17YY0 "
cQuery += " WHERE D_E_L_E_T_ = '' "
If lTemEmp
	cQuery += " AND Z17_EMP = '"+cEmpAnt+"'"
Else
	cQuery += " AND Z17_EMP = ''"
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

If Select("TMPZ17") > 0
	TMPZ17->(DbClosearea())
EndIf     	      
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,,cArqTmp,"TMPZ17",.F.,.F.)                                                  
IndRegua("TMPZ17",cArqTmp+OrdBagExt(),"Z17_COD")
FileWork2 := CriaTrab(,.F.)                                                          
IndRegua("TMPZ17",FileWork2+OrdBagExt(),"Z17_DESCR")
SET INDEX TO (cArqTmp+OrdBagExt()),(FileWork2+OrdBagExt())

TMPZ17->(DbClearFilter())

QRY->(DbGoTop())
Do While QRY->(!Eof())
	If !Empty(QRY->Z17_COD)
		TMPZ17->(DbAppend())
		TMPZ17->Z17_COD		:= QRY->Z17_COD
		TMPZ17->Z17_AGRUP	:= QRY->Z17_AGRUP
		TMPZ17->Z17_VIEW	:= QRY->Z17_VIEW
		TMPZ17->Z17_SQL		:= LerMemo(1,QRY->Z17_SQL)
		TMPZ17->Z17_DESCR	:= QRY->Z17_DESCR
		TMPZ17->Z17_MSBLQL	:= QRY->Z17_MSBLQL
		TMPZ17->Z17_DETALH	:= LerMemo(1,QRY->Z17_DETALH)
	EndIf
	QRY->(DbSkip())
EndDo

TMPZ17->(DBSetFilter( {|| TMPZ17->Z17_MSBLQL <> "1" .AND. (AllTrim(StrZero(nModulo,2)) $ TMPZ17->Z17_AGRUP) .OR. ('TODOS' $ TMPZ17->Z17_AGRUP)}, 'TMPZ17->Z17_MSBLQL <> "1" .AND. (AllTrim(StrZero(nModulo,2)) $ TMPZ17->Z17_AGRUP .OR. ("TODOS" $ TMPZ17->Z17_AGRUP))'))

Return NIL

*-------------------------*
Static Function Relatorio()
*-------------------------*
Return Processa({|| GeraRel() } ,"Geração de Relatório","Processando registros...")

*-----------------------*
Static Function GeraRel()
*-----------------------*
Local cQuery := CriaVar("A1_HISTMK"),nTotRegs := 0

Begin Sequence

	If Select("RELZ17") > 0
		RELZ17->(DbClosearea())
	Endif	
	
	If !Empty(TMPZ17->Z17_SQL)
		cQuery := AllTrim(TMPZ17->Z17_SQL)

		//Tratamento para considerar variaveis na formula.		
		While AT("<|",cQuery) <> 0
			cQuery := STRTRAN(cQuery,SubStr(cQuery,AT("<|",cQuery),AT("|>",cQuery)-AT("<|",cQuery)+2),&(SubStr(cQuery,AT("<|",cQuery)+2,AT("|>",cQuery)-AT("<|",cQuery)-2)))
		EndDo
	Else
		cQuery := "SELECT * FROM "+cAmb+"_01.dbo." + AllTrim(TMPZ17->Z17_VIEW)
	EndIf
	
	If TCSQLEXEC(cQuery) # 0
		Alert("Erro na geração do relatório: '" + AllTrim(Upper(TMPZ17->Z17_DESCR)) + "'." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
		Break
	EndIf

	TCQuery cQuery ALIAS "RELZ17" NEW

	If RELZ17->(Bof()) .AND. RELZ17->(Eof())
		Alert("Nenhum registro localizado.")
		Break
	EndIf
	
	cArq := "Relatorio_" + AllTrim(TMPZ17->Z17_COD) + "_" + DTOS(Date()) + "_" + StrTran(Time(),":","") + ".xls"
	
	RELZ17->(DbGoTop())
	nTotRegs := Contar("RELZ17","!Eof()")
	RELZ17->(DbGoTop())
	
	ProcRegua(nTotRegs)
	GeraExcel()
	
	If CpyS2T("\SYSTEM\"+cArq, GetTempPath())
		FErase("\SYSTEM\"+cArq)
	EndIf

	If !File(GetTempPath()+cArq)
		Alert("Erro ao localizar arquivo gerado para este relatório.")
		Break
	EndIf
	
	If !ApOleClient('MsExcel')
		Alert('MsExcel não instalado.')
		Break
	EndIf

    SHELLEXECUTE("open",(GetTempPath()+cArq),"","",5)   // Gera o arquivo em Excel

End Sequence

Return

*-------------------------*
Static Function GeraExcel()
*-------------------------*
Local oExcel := FWMSEXCEL():New()
Local nCols := RELZ17->(FCount()), i

oExcel:AddWorkSheet(AllTrim(TMPZ17->Z17_DESCR))
oExcel:AddTable(AllTrim(TMPZ17->Z17_DESCR),AllTrim(TMPZ17->Z17_DESCR))

For i := 1 To nCols
	//oExcel:AddColumn(AllTrim(TMPZ17->Z17_AGRUP),AllTrim(TMPZ17->Z17_AGRUP),PADR(RELZ17->(Field(i)), 10),1,1,.F.)
	oExcel:AddColumn(AllTrim(TMPZ17->Z17_DESCR),AllTrim(TMPZ17->Z17_DESCR),RELZ17->(Field(i)),1,1,.F.)
Next i

RELZ17->(DbGoTop())
Do While RELZ17->(!Eof())
	IncProc()
	aRow := {}
	For i := 1 To nCols
		aAdd(aRow,RELZ17->(FieldGet(i)))
	Next i
	oExcel:AddRow(AllTrim(TMPZ17->Z17_DESCR),AllTrim(TMPZ17->Z17_DESCR),aRow)
	RELZ17->(DbSkip())
EndDo

oExcel:Activate()
oExcel:GetXMLFile(cArq)

Return

/*/{Protheus.doc} ADM012CAD
@author Guilherme Fernandes Pilan - GFP
@since 22/08/2017
@type function
@description Cadastro de Relatorios
@table Z17
/*/
*-------------------------*
Static Function ADM012CAD()
*-------------------------*
Local cQuery := "", nOp := 0, oDlg, aButtons := {}
Private oNewGetDb, aTELA[0], aGETS[0], aHeader := {}, aCols := {}

TMPZ17->(DbClearFilter())
TMPZ17->(DbGoTop())
Do While TMPZ17->(!Eof())
	aAdd(aCols,{TMPZ17->Z17_COD, TMPZ17->Z17_AGRUP, TMPZ17->Z17_VIEW, TMPZ17->Z17_DESCR, TMPZ17->Z17_SQL, TMPZ17->Z17_MSBLQL, TMPZ17->Z17_DETALH,.F.})
	TMPZ17->(DbSkip())
EndDo

aAdd(aButtons,{"SDUPROP", {|| ManutReg(2),oNewGetDb:Refresh()}, "Visualizar"})
aAdd(aButtons,{"SDUPROP", {|| ManutReg(3),oNewGetDb:Refresh()}, "Incluir"	})
aAdd(aButtons,{"SDUPROP", {|| ManutReg(4),oNewGetDb:Refresh()}, "Alterar"	})
aAdd(aButtons,{"SDUPROP", {|| ManutReg(5),oNewGetDb:Refresh()}, "Excluir"	})

//            cTitulo       , cCampo   	, cPicture  , nTamanho	, nDecimais	, cValidação	, cReservado, cTipo, xReservado1, xReservado2
Aadd(aHeader,{"Código"		,"Z17_COD"	, ""		, 8			, 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })
Aadd(aHeader,{"Módulos"		,"Z17_AGRUP", ""		, 100		, 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })
Aadd(aHeader,{"View/Tabela" ,"Z17_VIEW"	, ""		, 50		, 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })
Aadd(aHeader,{"Descrição"	,"Z17_DESCR", ""		, 150		, 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })
//Aadd(aHeader,{"Bloqueado?"	,"Z17_MSBLQL", ""		, 1			, 0 		, "!VAZIO()"	, NIL      	, "C"	, NIL 		, NIL   })

DEFINE MSDIALOG oDlg TITLE "Cadastro de Relatorios" FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM PIXEL

	oNewGetDb := MsNewGetDados():New(0,0,0,0,2,,,,{},,120,,,.F.,oDlg,aHeader,aCols)
	oNewGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	If Len(oNewGetDb:aCols) == 0 .OR. Empty(oNewGetDb:aCols[1][1])
		oNewGetDb:aCols := aClone(aCols)
	Else
		oNewGetDb:oBrowse:SetBlkBackColor({|| SetCores(oNewGetDb:aCols,oNewGetDb:nAt)})
	EndIf
	oNewGetDb:oBrowse:lUseDefaultColors := .F.
	oNewGetDb:OnChange()
	oNewGetDb:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| (nOp := 1, oDlg:End())},;
												 {|| If(MsgYesNo("Confirmar a saída da rotina?","HLB BRASIL"),(nOp := 0,oDlg:End()),)},,aButtons)) CENTERED
If nOp == 1
	Processa({|| GravaZ17() } ,"Gravação de Dados","Processando gravação dos registros...")
EndIf

TMPZ17->(DBSetFilter( {|| TMPZ17->Z17_MSBLQL <> "1" .AND. (AllTrim(StrZero(nModulo,2)) $ TMPZ17->Z17_AGRUP .OR. ('TODOS' $ TMPZ17->Z17_AGRUP))}, 'TMPZ17->Z17_MSBLQL <> "1" .AND. (AllTrim(StrZero(nModulo,2)) $ TMPZ17->Z17_AGRUP .OR. ("TODOS" $ TMPZ17->Z17_AGRUP))'))
Return

*---------------------------------*
Static Function SetCores(aCols,nAt)
*---------------------------------*
Local nCor1 := 13882323 //Cinza claro - rgb(211, 211, 211)
Local nCor2 := 2559971	//Vermelho claro - rgb(250, 97, 97)
Local nCor3 := 6617740  //Verde claro - rgb(100, 250, 140)

If aCols[nAt][8]
	nRet := nCor1
ElseIf AllTrim(aCols[nAt][6]) == "1"
     nRet := nCor2
Else
     nRet := nCor3
Endif
Return nRet

*----------------------------*
Static Function ManutReg(nOpc)
*----------------------------*
Local oDlg, oGroup1, nOp := 0, lWhen := .T., cTipo
Local oGet1, oGet2, oGet4, oGet5, oGet6
Private cCodZ17, cAgrpZ17, cViewZ17, mSQLCodeZ17, cDescZ17, cDetalheZ17, cBlq := "2"

If nOpc <> 3 .AND. Len(oNewGetDb:aCols) == 0
	Alert("Não é possível executar esta ação, pois não há registros disponíveis.")
	Return
EndIf

If nOpc == 3
	cCodZ17  := StrZero(Len(oNewGetDb:aCols)+1,8)
	cAgrpZ17  := "TODOS"
	cViewZ17 := Space(50)
	mSQLCodeZ17 := Space(50)
	cDetalheZ17 := Space(50)
	cDescZ17 := Space(150)
	cTipo := "Inclusão"
Else
	cCodZ17  := oNewGetDb:aCols[oNewGetDb:nAt][1]
	cAgrpZ17 := oNewGetDb:aCols[oNewGetDb:nAt][2]
	cViewZ17 := oNewGetDb:aCols[oNewGetDb:nAt][3]
	cDescZ17 := oNewGetDb:aCols[oNewGetDb:nAt][4]
	mSQLCodeZ17 := oNewGetDb:aCols[oNewGetDb:nAt][5]
	cBlq	 := oNewGetDb:aCols[oNewGetDb:nAt][6]
	cDetalheZ17 := oNewGetDb:aCols[oNewGetDb:nAt][7]
	lWhen :=  !(nOpc == 2 .OR. nOpc == 5)
	cTipo := If(nOpc == 2, "Visualização",If(nOpc == 4,"Alteração","Exclusão"))
EndIf

SETKEY(VK_F4,{|| GEN018F3(1)})

DEFINE MSDIALOG oDlg TITLE "Manutenção de Relatórios" FROM 000, 000  TO 450, 500 PIXEL
	
    @ 035, 010 SAY oSay0 PROMPT cTipo + " de registro:" SIZE 058, 007 OF oDlg PIXEL
    @ 045, 008 GROUP oGroup1 TO 210, 240 PROMPT " Relatório " OF oDlg PIXEL//241
    
    @ 060, 016 SAY		oSay1 PROMPT "Código Registro:"	SIZE 058, 007 OF oGroup1 PIXEL
    @ 059, 088 MSGET	oGet1 VAR cCodZ17 WHEN .F.	SIZE 140, 010 OF oGroup1 PIXEL
    
    @ 075, 016 SAY		oSay2 PROMPT "Módulos:"		SIZE 058, 007 OF oGroup1 PIXEL
    @ 074, 088 MSGET	oGet2 VAR cAgrpZ17 PICTURE "@!" VALID (GEN018VAL(2)) WHEN .F. SIZE 110, 010 OF oGroup1 PIXEL
    @ 076, 200 SAY		oSay2 PROMPT "<Clique F4>"		SIZE 058, 007 OF oGroup1 PIXEL
    
    @ 90, 016 SAY		oSay4 PROMPT "View:"	SIZE 058, 007 OF oGroup1 PIXEL
    @ 89, 088 MSGET	oGet4 VAR cViewZ17 PICTURE "@!" WHEN (lWhen .AND. Empty(mSQLCodeZ17)) SIZE 140, 010 OF oGroup1 PIXEL
    
    @ 105, 016 SAY		oSay5 PROMPT "SQL Code:"	SIZE 058, 007 OF oGroup1 PIXEL
    oGet5 := TMultiGet():New(104,088,{|u| if(PCount()==0,mSQLCodeZ17,mSQLCodeZ17 := u)},oGroup1,135,30,,,,,,.T.,,,{||lWhen .AND. Empty(cViewZ17)})
    oGet5:EnableVScroll(.T.)
    oGet5:GoTop()
        
    @ 140, 016 SAY		oSay7 PROMPT "Descrição:"				SIZE 058, 007 OF oGroup1 PIXEL
    @ 139, 088 MSGET	oGet7 VAR cDescZ17 WHEN lWhen SIZE 140, 010 OF oGroup1 PIXEL

    @ 155, 016 SAY		oSay6 PROMPT "Descrição Detalhada:"	SIZE 058, 007 OF oGroup1 PIXEL
    oGet6 := TMultiGet():New(154,088,{|u| if(PCount()==0,cDetalheZ17,cDetalheZ17 := u)},oGroup1,135,30,,,,,,.T.,,,{||lWhen})
    oGet6:EnableVScroll(.T.)
    oGet6:GoTop()
    
    @ 190, 016 SAY		oSay8 PROMPT "Bloqueado?"	SIZE 055, 007 OF oGroup1 PIXEL
    oCombo := TComboBox():Create(oGroup1,{|u|if(PCount()>0,cBlq := u,cBlq)},188,088,{"1=Sim","2=Não"},55,20,,,,,,.T.,,,,,,,,,'cBlq')
    oCombo:bWhen := {|| lWhen}
    
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| If( !(nOpc == 3 .OR. nOpc == 4) .OR. GEN018VAL(1),(nOp := 1, oDlg:End()),MsgInfo("Preencha todos os campos.","HLB BRASIL"))},{||nOp := 0, oDlg:End()})) CENTERED

SETKEY(VK_F4,{|| .T.})

If nOp == 1
	If nOpc == 3
		aAdd(oNewGetDb:aCols,{cCodZ17,cAgrpZ17,cViewZ17,cDescZ17,mSQLCodeZ17,cBlq,cDetalheZ17,.F.})
	ElseIf nOpc == 5
		oNewGetDb:aCols[oNewGetDb:nAt][8] := .T.
	Else
		oNewGetDb:aCols[oNewGetDb:nAt][1] := cCodZ17
		oNewGetDb:aCols[oNewGetDb:nAt][2] := cAgrpZ17
		oNewGetDb:aCols[oNewGetDb:nAt][3] := cViewZ17
		oNewGetDb:aCols[oNewGetDb:nAt][4] := cDescZ17
		oNewGetDb:aCols[oNewGetDb:nAt][5] := mSQLCodeZ17
		oNewGetDb:aCols[oNewGetDb:nAt][6] := cBlq
		oNewGetDb:aCols[oNewGetDb:nAt][7] := cDetalheZ17
	EndIf
	oNewGetDb:Refresh()
EndIf

Return

*----------------------------*
Static Function GEN018VAL(nOp)
*----------------------------*
Local lRet := .T., i

Do Case
	Case nOp == 1
		If Empty(cAgrpZ17) .OR. Empty(cDescZ17) .OR. Empty(cDetalheZ17) .OR. (Empty(cViewZ17) .AND. Empty(mSQLCodeZ17))
			lRet := .F.
		EndIf

	Case nOp == 2
		If !Empty(cAgrpZ17)
			aModulos := Separa(cAgrpZ17,";",.F.)
			For i := 1 To Len(aModulos)
				lRet := .F.
				WKMODU->(DbGoTop())
				Do While WKMODU->(!Eof())
					If WKMODU->WKCODIGO == AllTrim(aModulos[i])
						lRet := .T.
						Exit
					EndIf
					WKMODU->(DbSkip())
				EndDo
			Next i
			If !lRet
				Alert("Módulo inválido.")
			EndIf
			WKMODU->(DbGoTop())
		Else
			cAgrpZ17 := "TODOS"
		EndIf
End Case

Return lRet

*------------------------*
Static Function GravaZ17()
*------------------------*
Local cQuery := "", i, nRecno, cCodSQL, cCodDet

Begin Sequence

	If Select("QTDZ17") > 0
		QTDZ17->(DbClosearea())
	Endif	
	
	cQuery := "Select COUNT(*) AS QTDREG FROM "+cAmb+"_01.dbo.Z17YY0"
	TCQuery cQuery ALIAS "QTDZ17" NEW
	nRecno := QTDZ17->QTDREG
	
	ProcRegua(Len(oNewGetDb:aCols))
	
	cQuery += " DELETE FROM "+cAmb+"_01.dbo.SYPYY0 "
	If TCSQLEXEC(cQuery) # 0
		MsgAlert("Erro na exclusão de registros na tabela de Memos (SYP)'." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
	EndIf
	
	For i := 1 To Len(oNewGetDb:aCols)
		TMPZ17->(DbSetOrder(1))
		If !TMPZ17->(DbSeek(oNewGetDb:aCols[i][1]))
			nRecno++
			IncProc("Incluindo o relatório '" + AllTrim(oNewGetDb:aCols[i][3]) + "'...")
			cCodSQL := LerMemo(2,,"Z17_SQL",oNewGetDb:aCols[i][5])
			cCodDet := LerMemo(2,,"Z17_DETALH",oNewGetDb:aCols[i][7])
			cQuery := " INSERT INTO "+cAmb+"_01.dbo.Z17YY0"
			cQuery += "(Z17_COD, Z17_AGRUP, Z17_VIEW, Z17_DESCR, Z17_SQL , Z17_MSBLQL, Z17_DETALH, Z17_AUTOR, Z17_DTINC, R_E_C_N_O_) "
			cQuery += " VALUES("
			cQuery += "'" + oNewGetDb:aCols[i][1] + "', "
			cQuery += "'" + oNewGetDb:aCols[i][2] + "', "
			cQuery += "'" + oNewGetDb:aCols[i][3] + "', "
			cQuery += "'" + oNewGetDb:aCols[i][4] + "', "
			cQuery += "'" + cCodSQL + "', "
			cQuery += "'" + oNewGetDb:aCols[i][6] + "', "
			cQuery += "'" + cCodDet + "', "
			cQuery += "'" + UsrFullName(__cUserID) + "', "
			cQuery += "'" + DTOS(dDataBase) + "', "
			cQuery += cValToChar(nRecno) + ") "
		Else
			IncProc("Alterando o relatório '" + AllTrim(oNewGetDb:aCols[i][2]) + "'...")
			cCodSQL := LerMemo(2,,"Z17_SQL",oNewGetDb:aCols[i][5])
			cCodDet := LerMemo(2,,"Z17_DETALH",oNewGetDb:aCols[i][7])
			cQuery := " UPDATE "+cAmb+"_01.dbo.Z17YY0 "
			cQuery += " SET "
			If oNewGetDb:aCols[i][8]
				cQuery += " D_E_L_E_T_ = '*' "
			Else
				cQuery += " Z17_AGRUP = '"	+ oNewGetDb:aCols[i][2] + "', "
				cQuery += " Z17_VIEW = '"   + oNewGetDb:aCols[i][3] + "', "
				cQuery += " Z17_DESCR = '"  + oNewGetDb:aCols[i][4] + "', "
				cQuery += " Z17_SQL = '"	+ cCodSQL + "', "
				cQuery += " Z17_MSBLQL = '" + oNewGetDb:aCols[i][6] + "', "
				cQuery += " Z17_DETALH = '" + cCodDet + "' "
			EndIf
			cQuery += " WHERE D_E_L_E_T_ = '' "
			cQuery += " AND Z17_COD = '" + oNewGetDb:aCols[i][1] + "' "
		EndIf
		
		If TCSQLEXEC(cQuery) # 0
			MsgAlert("Erro na manutenção do registro: '" + AllTrim(oNewGetDb:aCols[i][1]) + "'." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
		EndIf
	Next i
	BuscaRegs()
	oBrowEmp:Refresh()

End Sequence

Return NIL

*---------------------------*
Static Function GEN018F3(nOp)
*---------------------------*
Local nOpc := 0, aButtons := {}, aCpoBro := {}
Private oMark, cMark := GetMark(), lInverte := .F.

If nOp == 1
	
	cAgrpZ17 := "TODOS"
	
	aAdd(aButtons,{"SDUPROP", {|| Mark(.T.),oMark:oBrowse:Refresh() }	, "Marcar Todos"	})
	
	aAdd(aCpoBro,{ "OK"		 	,, ""      		})
	aAdd(aCpoBro,{ "WKCODIGO"	,, "Código"		})
	aAdd(aCpoBro,{ "WKMODULO" 	,, "Módulo"  	})
	aAdd(aCpoBro,{ "WKNOME" 	,, "Descrição"  })
	
	WKMODU->(DbGoTop())
	Mark(.T.,.T.)
	WKMODU->(DbGoTop())
	
	DEFINE MSDIALOG oDlg TITLE "Seleção de Módulos" FROM 000, 000 TO 500, 1000 PIXEL
	
		oMark := MsSelect():New("WKMODU","OK","",aCpoBro,@lInverte,@cMark,PosDLG(oDlg))
		oMark:bAval := {|| Mark(), oMark:oBrowse:Refresh() }
		oMark:oBrowse:Refresh()
	
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nOpc := 1, oDlg:End()},{||nOpc := 0, oDlg:End()},,aButtons)) CENTERED

	If nOpc == 0
		cAgrpZ17 := "TODOS"
	Else
		cAgrpZ17 := ""
		WKMODU->(DbGoTop())
		Do While WKMODU->(!Eof())
			If !Empty(WKMODU->OK)
				cAgrpZ17 += WKMODU->WKCODIGO + ";"
			EndIf
			WKMODU->(DbSkip())
		EndDo
		cAgrpZ17 := If(Empty(cAgrpZ17),"TODOS",cAgrpZ17)
	EndIf
EndIf

Return .T.

*------------------------*
Static Function GeraF3()
*------------------------*
Local i
Local aDados := {}, lRet := .T., aSemSX3 := {}, aModulos := {}

Begin Sequence

	aAdd(aModulos,{"01","SIGAATF","Ativo Fixo"})
	aAdd(aModulos,{"02","SIGACOM","Compras"})
	aAdd(aModulos,{"04","SIGAEST","Estoque e Custos"})
	aAdd(aModulos,{"05","SIGAFAT","Faturamento"})
	aAdd(aModulos,{"06","SIGAFIN","Financeiro"})
	aAdd(aModulos,{"07","SIGAGPE","Gestão de Pessoal"})
	aAdd(aModulos,{"09","SIGAFIS","Livros Fiscais"})
	aAdd(aModulos,{"10","SIGAPCP","Planejamento e Controle da Produção"})
	aAdd(aModulos,{"11","SIGAVEI","Veículos"})
	aAdd(aModulos,{"12","SIGALOJA","Controle de Lojas"})
	aAdd(aModulos,{"13","SIGATMK","Call Center"})
	aAdd(aModulos,{"14","SIGAOFI","Oficina"})
	aAdd(aModulos,{"16","SIGAPON","Ponto Eletrônico"})
	aAdd(aModulos,{"17","SIGAEIC","Easy Import Control"})
	aAdd(aModulos,{"18","SIGATCF","Terminal de Consulta do Funcionário"})
	aAdd(aModulos,{"19","SIGAMNT","Manutenção de Ativos"})
	aAdd(aModulos,{"20","SIGARSP","Recrutamento e Seleção de Pessoal"})
	aAdd(aModulos,{"21","SIGAQIE","Inspeção de Entradas"})
	aAdd(aModulos,{"22","SIGAQMT","Metrologia"})
	aAdd(aModulos,{"23","SIGAFRT","Front Loja"})
	aAdd(aModulos,{"24","SIGAQDO","Controle de Documentos"})
	aAdd(aModulos,{"25","SIGAQIP","Inspeção de Processos"})
	aAdd(aModulos,{"26","SIGATRM","Treinamento"})
	aAdd(aModulos,{"28","SIGATEC","Gestão de Serviços"})
	aAdd(aModulos,{"29","SIGAEEC","Easy Export Control"})
	aAdd(aModulos,{"30","SIGAEFF","Easy Financing"})
	aAdd(aModulos,{"31","SIGAECO","Easy Accounting"})
	aAdd(aModulos,{"33","SIGAPLS","Plano de Saúde"})
	aAdd(aModulos,{"34","SIGACTB","Contabilidade Gerencial"})
	aAdd(aModulos,{"35","SIGAMDT","Medicina e Segurança do Trabalho"})
	aAdd(aModulos,{"36","SIGAQNC","Controle de Não-Conformidades"})
	aAdd(aModulos,{"37","SIGAQAD","Controle de Auditoria"})
	aAdd(aModulos,{"39","SIGAOMS","OMS - Gestão de Distribuição"})
	aAdd(aModulos,{"40","SIGACSA","Cargos e Salários"})
	aAdd(aModulos,{"41","SIGAPEC","Auto Peças"})
	aAdd(aModulos,{"42","SIGAWMS","WMS - Gestão de Armazenagem"})
	aAdd(aModulos,{"43","SIGATMS","TMS - Gestão de Transporte"})
	aAdd(aModulos,{"44","SIGAPMS","Gestão de Projetos"})
	aAdd(aModulos,{"45","SIGACDA","Controle de Direitos Autorais"})
	aAdd(aModulos,{"47","SIGAPPAP","PPAP"})
	aAdd(aModulos,{"48","SIGAREP","Réplica"})
	aAdd(aModulos,{"50","SIGAEDC","Easy Drawback Control"})
	aAdd(aModulos,{"51","SIGAHSP","Gestão Hospitalar"})
	aAdd(aModulos,{"53","SIGAAPD","Avaliação e Pesquisa de Desempenho"})
	aAdd(aModulos,{"55","SIGACRD","Sistema de Fidelização e Análise de Crédito"})
	aAdd(aModulos,{"56","SIGASGA","Gestão Ambiental"})
	aAdd(aModulos,{"57","SIGAPCO","Planejamento e Controle Orçamentário"})
	aAdd(aModulos,{"58","SIGAGPR","Gerenciamento de Pesquisa e Resultado"})
	aAdd(aModulos,{"64","SIGAAPT","Processos Trabalhistas"})
	aAdd(aModulos,{"66","SIGAICE","Gestão de Riscos"})
	aAdd(aModulos,{"67","SIGAAGR","Gestão Agroindústria"})
	aAdd(aModulos,{"69","SIGAGCT","Gestão de Contratos"})
	aAdd(aModulos,{"70","SIGAORG","Arquitetura Organizacional"})
	aAdd(aModulos,{"73","SIGACRM","CRM"})
	aAdd(aModulos,{"76","SIGAJURI","Gestão Jurídica"})
	aAdd(aModulos,{"77","SIGAPFS","Pré Faturamento de Serviço"})
	aAdd(aModulos,{"78","SIGAGFE","Gestão de Frete Embarcador"})
	aAdd(aModulos,{"79","SIGASFC","Chão de Fábrica"})
	aAdd(aModulos,{"80","SIGAACV","Acessibilidade Visual"})
	aAdd(aModulos,{"81","SIGALOG","Monitoramento de Desempenho Logístico"})
	aAdd(aModulos,{"84","SIGATAF","TOTVS Automação Fiscal"})
	aAdd(aModulos,{"85","SIGAESS","Easy Siscoserv"})
	aAdd(aModulos,{"90","SIGAGCV","Gestão Comercial do Varejo"})
	aAdd(aModulos,{"97","SIGAESP","Especificos"})
	aAdd(aModulos,{"99","SIGACFG","Configurador"})

	If Select("WKMODU") # 0
		WKMODU->(DbCloseArea())
		//FErase(cWork)
	EndIf

	aAdd(aSemSX3, {"OK"    		, "C"  , 2  , 0 })
	aAdd(aSemSX3, {"WKCODIGO"	, "C"  , 2  , 0 })
	aAdd(aSemSX3, {"WKMODULO"	, "C"  , 8  , 0 })
	aAdd(aSemSX3, {"WKNOME"		, "C"  , 30 , 0 })

	cWork := E_CriaTrab(NIL,aSemSx3, "WKMODU")
	IndRegua("WKMODU", cWork+OrdBagExt() ,"WKCODIGO+WKMODULO",,, "Processando arquivo temporário..." )
	
	For i := 1 To Len(aModulos)
		WKMODU->(DbAppend())
		WKMODU->OK		:=	Space(2)
		WKMODU->WKCODIGO:=	aModulos[i][1]
		WKMODU->WKMODULO:=	aModulos[i][2]
		WKMODU->WKNOME	:=	aModulos[i][3]
	Next i
	WKMODU->(DbGoTop())

End Sequence

Return lRet

*---------------------------------*
Static Function Mark(lTodos,lApaga)
*---------------------------------*
Local aOrd := SaveOrd("WKMODU")
Default lTodos := .F., lApaga := .F.

If lTodos
	WKMODU->(DbGoTop())
	Do While WKMODU->(!Eof())
		If lApaga
			WKMODU->OK := ""
		Else
			WKMODU->OK := If(Empty(WKMODU->OK),cMark,"")
		EndIf
		WKMODU->(DbSkip())
	EndDo
	WKMODU->(DbGoTop())
Else
	WKMODU->OK := If(Empty(WKMODU->OK),cMark,"")
EndIf

RestOrd(aOrd,.T.)
Return

*------------------------------------------------*
Static Function LerMemo(nOp,cCodSYP,cCampo,cMemo)
*------------------------------------------------*
Local i
Local xRet := "", cQuery := "", nRecno := 1, aMemoAux := {}, nInicio := 0, nFinal := 0
Default cCodSYP := "", cMemo := ""

Do Case
	Case nOp == 1		// LEITURA
		If !Empty(cCodSYP)
			If Select("QRYSYP") > 0
				QRYSYP->(DbClosearea())
			EndIf	
	
			cQuery := " SELECT YP_SEQ, YP_TEXTO FROM "+cAmb+"_01.dbo.SYPYY0 "
			cQuery += " WHERE YP_CHAVE = '" + cCodSYP + "' AND D_E_L_E_T_ = '' "
			cQuery += " ORDER BY YP_SEQ "
			TCQuery cQuery ALIAS "QRYSYP" NEW
			
			If !(QRYSYP->(Bof()) .AND. QRYSYP->(Eof()))
				QRYSYP->(DbGoTop())
				Do While QRYSYP->(!Eof())
					xRet += QRYSYP->YP_TEXTO
					QRYSYP->(DbSkip())
				EndDo	
			EndIf
		EndIf
	
	Case nOp == 2	//INCLUSÃO / ALTERAÇÃO
		If Select("QTDSYP") > 0
			QTDSYP->(DbClosearea())
		EndIf

		cQuery := " Select TOP 1 YP_CHAVE FROM "+cAmb+"_01.dbo.SYPYY0 GROUP BY YP_CHAVE ORDER BY YP_CHAVE DESC "
		TCQuery cQuery ALIAS "QTDSYP" NEW
		cQuery := ""
		nChave := Val(QTDSYP->YP_CHAVE)+1
		
		If Select("QTDSYP") > 0
			QTDSYP->(DbClosearea())
		EndIf
		
		cQuery := " Select Count(*) AS QTDREG FROM "+cAmb+"_01.dbo.SYPYY0 "
		TCQuery cQuery ALIAS "QTDSYP" NEW
		cQuery := ""
		nRecno := QTDSYP->QTDREG
		
		If Select("QTDSYP") > 0
			QTDSYP->(DbClosearea())
		EndIf
		
		cMemo := StrTran(cMemo,CHR(13)+CHR(10)," ")
		nTam := Len(cMemo)/80
		If nTam - Int(nTam) <> 0 
			nTam := Int(nTam)+1
		EndIf
		nInicio := 1
		nFinal := 80
		For i := 1 To nTam
			cLinha := SubStr(cMemo,nInicio,nFinal)
			cLinha := StrTran(cLinha,"'","''") 
			aAdd(aMemoAux,cLinha)
			nInicio := (nFinal*i)+1
		Next i
		
		For i := 1 To Len(aMemoAux)
			nRecno := nRecno+1
			cQuery := " INSERT INTO "+cAmb+"_01.dbo.SYPYY0"
			cQuery += "(YP_CHAVE, YP_SEQ, YP_TEXTO, YP_CAMPO, R_E_C_N_O_) "
			cQuery += " VALUES("
			cQuery += "'" + StrZero(nChave,6) + "', "
			cQuery += "'" + StrZero(i,3) + "', "
			cQuery += "'" + aMemoAux[i] + "', "
			cQuery += "'" + cCampo + "', "
			cQuery += cValToChar(nRecno) + ") "
		
			If TCSQLEXEC(cQuery) # 0
				MsgAlert("Erro na inclusão da chave Memo: '" + StrZero(nRecno,6) + "'." + CHR(13)+CHR(10) + "Erro SQL: " + TCSQLError())
			Else
				xRet := StrZero(nChave,6)
			EndIf
		Next i

End Case

If Select("QRYSYP") > 0
	QRYSYP->(DbClosearea())
EndIf
If Select("QTDSYP") > 0
	QTDSYP->(DbClosearea())
EndIf

Return AllTrim(xRet)

*------------------------*
Static Function SetOrdem()
*------------------------*
Do Case
	Case oBrowEmp:ColPos() == 1	//Código
		TMPZ17->(DbSetOrder(1))
	Case oBrowEmp:ColPos() == 2	//Descrição
		TMPZ17->(DbSetOrder(2))
End Case
oBrowEmp:Refresh(.T.)

Return .T.