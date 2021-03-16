#INCLUDE "Protheus.CH"
#include "topconn.ch"
#include "tbiconn.ch"
                    
// Tela Cheia
#define DLG_LIN_INI (oMainWnd:ReadClientCoords(),oMainWnd:nTop+If(SetMDIChild(),0,If("CLIENTAX"$UPPER(GETCLIENTDIR()),231.5,115) ))
#define DLG_COL_INI (oMainWnd:nLeft+5)
#define DLG_LIN_FIM (oMainWnd:nBottom-If(SetMDIChild(),70,If("CLIENTAX"$UPPER(GETCLIENTDIR()),(-55),60)))
#define DLG_COL_FIM (oMainWnd:nRight-If("CLIENTAX"$UPPER(GETCLIENTDIR()),5,10))

//definicao para browser
#define PESQUISAR    1
#define VISUALIZAR   2
#define ALTERAR      4

/*                                                  
Funcao     : N6FAT005()           
Objetivo   : Cadastro de produtos substitutos
*/
*----------------------*
User Function N6FAT005() 
*----------------------*
Local lRet:=.T.
Local cOldArea:=select()
Local cAlias:="SB1"

Private cCadastro:= "Produtos Substitutos"
Private aRotina  := MenuDef()
Private aColors := {{"u_N6FAT05S('BRANCO')", "BR_BRANCO"	},;
                    {"u_N6FAT05S('AZUL'  )", "BR_AZUL"		}}

Private lProdAUTO := GETMV("MV_P_00121",,.T.)//Ativa geração de Prod. Substituto AUTO

Begin sequence
	(cAlias)->(DBSETORDER(1))
	mBrowse(,,,,cAlias,,,,,,aColors)
End sequence

dbselectarea(cOldArea)

Return lRet                                                                     

/*                                                  
Funcao     : MenuDef()
*/
*-----------------------*
Static Function MenuDef()
*-----------------------*
Local aRotina :=  {	{"Pesquisar"  , "AxPesqui"   ,0 ,PESQUISAR },;
					{"Visualizar" , "u_N6FAT05M" ,0 ,VISUALIZAR},;
					{"Manutenção" , "u_N6FAT05M" ,0 ,ALTERAR   },;
					{"Relatório"  , "u_N6FAT05R" ,0 ,VISUALIZAR},;
					{"Legenda"    , "u_N6FAT05L" ,0 ,VISUALIZAR} }
Return aRotina

/*                                                  
Funcao     : N6FAT05S() 
Objetivo   : Status do Browse
*/
*--------------------------*
User Function N6FAT05S(cCor)
*--------------------------*
Local lRet := .T. 
Local lTemSubst := .F. 

ZX5->(dbSetOrder(1)) //ZX5_FILIAL+ZX5_COD+ZX5_ORDEM
lTemSubst := ZX5->(DbSeek(xFilial("ZX5")+SB1->B1_COD))          

Do Case   
	Case cCor == "BRANCO"
		lRet := !lTemSubst

	Case cCor == "AZUL"
		lRet :=  lTemSubst
   EndCase

Return lRet

/*                                                  
Funcao     : N6FAT05L() 
Objetivo   : Janela de Legenda do browse
*/
*----------------------*
User Function N6FAT05L()
*----------------------*
Local aLegenda:={}

aAdd(aLegenda,{"BR_BRANCO"  ,"Sem produto substitulo"      })
aAdd(aLegenda,{"BR_AZUL"    ,"Possui produtos substitutos" })

BrwLegenda(cCadastro,"Legenda",aLegenda)

Return .T.

/*                                                  
Funcao     : N6FAT05M
Objetivo   : Tela principal de Manutençao e visualizacao 
*/
*--------------------------------------*
User Function N6FAT05M(cAlias,nReg,nOpc)
*--------------------------------------*
Local lRet:=.T.
Local cOldArea := Select()

Local lOkGrava:=.F.
Local oEnch
Local nInc
Local nOpcBrw

Local bOk
Local bCancel := {|| oDlg:End() }
Local aAltCampos := {"ZX5_PRODSU"}
Local cIniCpos := "+ZX5_ORDEM"
Local aCpoBrw := {"ZX5_ORDEM","ZX5_PRODSU","B1_DESC"}

Private oGtDados

Private aTela[0][0],aGets[0]
Private aHeader,aCols
Private aButtons := {}

//Verifica se é lProdAUTO
If nOpc <> VISUALIZAR .AND. lProdAUTO
	MsgInfo("Manutenção em produto substituto não permitido para tratamento automático habilitado.", "HLB BRASIL")
	Return .F.
EndIf

Begin Sequence
	For nInc := 1 TO (cAlias)->(FCount())
		M->&((cAlias)->(FieldName(nInc))) := (cAlias)->(FieldGet(nInc))
	Next nInc

	aHeader := {}                        
	SX3->(dbSetOrder(2))           

	For nInc := 1 to Len(aCpoBrw)
		SX3->(dbSeek(aCpoBrw[nInc]))
		aAdd(aHeader, {	X3Titulo(),;
						AllTrim(SX3->X3_CAMPO),;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT,;
						SX3->X3_CBOX,;
						SX3->X3_RELACAO,;
						SX3->X3_WHEN})
	Next nInc

	aCols    := {}
	Processa({|| CarregaCol() } , "Processando gravação...")
	     
	If Len(aCols) = 0                                     
		//Caso for o primeiro adciona em branco
		aAdd(aCols,{"01",Space(Len(SB1->B1_COD)),"",.f.})      
	EndIf
	
	nOpcBrw := GD_INSERT+GD_DELETE+GD_UPDATE
	bOk := {|| If(u_N6FAT05V("TELA"), (lOkGrava:=.T.,oDlg:End()) , ) }
	
	If nOpc == VISUALIZAR
		bOk := {|| lOkGrava:=.F. , oDlg:End() }
		nOpcBrw := nOpc
	Endif                          
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
		aPosEnch := PosDlgUp(oDlg)
		aPosBrw  := PosDlgDown(oDlg)
		
		oEnch := MsMget():New(cAlias,nReg,VISUALIZAR,,,,,aPosEnch,,3,,,,oDlg)  
		oEnch:oBox:Align:=CONTROL_ALIGN_TOP 
		//Monta o browser com inclusão, remoção e atualização         
		oGtDados := MsNewGetDados():New( aPosBrw[1],aPosBrw[2],aPosBrw[3]-8,aPosBrw[4],;
										nOpcBrw,"U_N6FAT05V('LINHA')", "AllwaysTrue", cIniCpos,;
										aAltCampos,1, 999, "AllwaysTrue", "", "AllwaysTrue",;
										oDlg, aHeader, aCols)
		oGtDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGtDados:oBrowse:SetFocus()
		oGtDados:SetArray(aCols,.T.) 
		oGtDados:Refresh() 
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

	If lOkGrava
		Begin Transaction   
			Processa({|| Grava() } , "Processando gravação...")
		End Transaction
	EndIf

End Sequence
dbSelectArea(cOldArea)

Return lRet

/*                                                  
Funcao     : CarregaCol
*/
*--------------------------*
Static Function CarregaCol()
*--------------------------*
Local nPos
Local aAux
Local aOrd := SaveOrd({"SB1"}) 

ZX5->(DbSetOrder(1)) //ZX5_FILIAL+ZX5_COD+ZX5_ORDEM
ZX5->(DbSeek(xFilial("ZX5")+M->B1_COD))
Do while ZX5->(!Eof()) .And.;
	ZX5->ZX5_FILIAL == xFilial("ZX5") .And.;
	ZX5->ZX5_COD    == M->B1_COD
	aAux := {}  
	For nPos := 1 To Len(aHeader) 
		If aHeader[nPos,2] == "B1_DESC"
	   		aAdd(aAux,Posicione('SB1',1,xFilial("SB1")+ZX5->ZX5_PRODSU,"B1_DESC"))         
		Else
			aAdd(aAux,ZX5->&(aHeader[nPos,2]))         
		EndIf
	Next nPos
	aAdd(aAux,.F. )      
	aAdd(aCols,aClone(aAux))
	ZX5->(dbSkip())
EndDo
RestOrd(aOrd,.t.)

Return 

/*                                                  
Funcao     : Grava
*/
*---------------------*
Static Function Grava()
*---------------------*
Local nPos , nCab
Local aAux 
Local cCampo
Local _Conteudo
Local nPosProd  := aScan(aHeader,{|x| x[2] == "ZX5_PRODSU"} )
Local nPosDesc  := aScan(aHeader,{|x| x[2] == "B1_DESC"} )
Local nPosOrdem := aScan(aHeader,{|x| x[2] == "ZX5_ORDEM"} )
Local cBusca

For nPos := 1 To Len(aCols)
	aAux   := aClone(aCols[nPos])         
	cBusca := xFilial("ZX5") + M->B1_COD + aAux[nPosOrdem]
	If aAux[Len(aAux)] //Verifica se esta deletado e existe na base
		If ZX5->(dbSeek(cBusca))
			ZX5->( RecLock("ZX5",.F.,.T.) ) 
			ZX5->(dbDelete())
			ZX5->(MsUnlock())         
		EndIf
		Loop
	EndIf  

	ZX5->( RecLock("ZX5",!ZX5->(dbSeek(cBusca))) )
	For nCab := 1 To Len(aHeader)
		cCampo    := aHeader[nCab][2]
		_Conteudo := aAux[nCab]       
		If ZX5->(FieldPos(cCampo)) > 0 
			ZX5->&(cCampo) := _Conteudo
		EndIf
	Next nCab
	ZX5->ZX5_FILIAL := xFilial("ZX5")
	ZX5->ZX5_COD    := M->B1_COD      
	ZX5->(MsUnlock())         

Next nPos

Return 

/*                                                  
Funcao     : N6FAT05V
Objetivo   : Validações em geral
*/
*---------------------------*
User Function N6FAT05V(cTipo)
*---------------------------*
Local lRet := .T.               
Local aOrd := SaveOrd({"SB1"}) 
Local nPosProd  := aScan(aHeader,{|x| x[2] == "ZX5_PRODSU"} )
Local nPosDesc  := aScan(aHeader,{|x| x[2] == "B1_DESC"} )
Local nPosOrdem := aScan(aHeader,{|x| x[2] == "ZX5_ORDEM"} )
Local nPos

Do Case
	Case cTipo == "ZX5_PRODSU"
		If M->ZX5_PRODSU == M->B1_COD
			MsgStop("Produto não pode ser substituto dele mesmo!","Atenção")
			lRet := .F. 
		ElseIf ExistCpo("SB1",M->ZX5_PRODSU)      
			If nPosDesc > 0 
				aCols[oGtDados:nAt][nPosDesc] := Posicione('SB1',1,xFilial("SB1")+M->ZX5_PRODSU,"B1_DESC")
				oGtDados:Refresh() 
			EndIf
		Else
			lRet := .f. 
		EndIf
	Case cTipo == "LINHA"
		//Verifica as outras linhas
		For nPos := 1 To Len(aCols)  
			If !aCols[nPos, Len(aCols[nPos]) ] //Verifica se esta deletado
				If nPos <> oGtDados:nAt //Linha Atual   
					If aCols[oGtDados:nAt][nPosProd] == aCols[nPos][nPosProd]
						MsgStop("Produto já incluido na ordem " + aCols[nPos][nPosOrdem] + " !","Atenção")
						lRet := .F.                      
					EndIf
				EndIf
			EndIf                 
		Next nPos
	Case cTipo == "TELA"
		aCols := aClone(oGtDados:aCols)
		//Verifica as outras linhas
		For nPos := 1 To Len(aCols)  
			If !aCols[nPos, Len(aCols[nPos]) ] //Verifica se esta deletado
				If nPos <> oGtDados:nAt //Linha Atual   
					If aCols[oGtDados:nAt][nPosProd] == aCols[nPos][nPosProd]
						MsgStop("Produto já incluido na ordem " + aCols[nPos][nPosOrdem] + " !","Atenção")
						lRet := .F.                      
					EndIf
				EndIf
			EndIf                 
		Next nPos
EndCase

RestOrd(aOrd,.t.)

Return lRet

/*                                                  
Funcao     : N6FAT05R
Objetivo   : Extração dos dados
*/
*----------------------*
User Function N6FAT05R()
*----------------------*
Local nOldArea := Select()
Local oDlg
Local nOpcao := 0
Local bOk    := {|| nOpcao := 1,oDlg:End() }
Local bCancel:= {|| nOpcao := 0,oDlg:End() }
Local nLin := 45 
Local nCol1 := 10 , nCol2 := 80
Local nPula := 17
Local nRadRel := 1     
Local cProdIni := Space(Len(SB1->B1_COD))
Local cProdFim := Space(Len(SB1->B1_COD))

oMainWnd:ReadClientCoords() 
Define MsDialog oDlg Title cCadastro From 1,1 To 320,420 Of oMainWnd Pixel
	@ nLin+2, nCol1 Say "Filtrar por Produto:" Of oDlg Pixel
	nLin += nPula
	@ nLin,nCol1 Radio nRadRel ITEMS "Principal","Substituto" Size 80,30 Of oDlg Pixel
	nLin += nPula

	@ nLin+2, nCol1 Say "Produto Inicial" Of oDlg Pixel
	@ nLin, nCol2 MsGet cProdIni Picture "@!" F3 "SB1" Size 60,08 Of oDlg Pixel
	nLin += nPula

	@ nLin+2, nCol1 Say "Produto Final" Of oDlg Pixel
	@ nLin, nCol2 MsGet cProdFim Picture "@!"  F3 "SB1" Size 60,08 Of oDlg Pixel
	nLin += nPula

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

If nOpcao = 1    
	oReport := ReportDef(nRadRel,cProdIni,cProdFim)
	oReport:PrintDialog()
EndIf

dbSelectArea(nOldArea)

Return                             

/*
Funcao     : ReportDef()
Objetivos  : Definições do relatório personalizável
*/
*--------------------------------------------------*
Static Function ReportDef(nRadRel,cProdIni,cProdFim)
*--------------------------------------------------*
Local nPos
Local cCampo, cTitulo, nTamanho, _Get

Local aTBRelZx5:=ArrayBrowse("ZX5")

Private cCadastro := "Produtos x Produtos substitutos"
Private cNome := "Produtos x Produtos substitutos"

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SB1"}  

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório ,Titulo   ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("N6FAT05",cCadastro,""       ,{|oReport| ReportPrint(oReport,nRadRel,cProdIni,cProdFim)})

//Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

TRPosition():New(oSecao1,"SB1",1,{|| xFilial("SB1") + ZX5->ZX5_PRODSU  }) 

For nPos := 1 To Len(aTBRelZx5)
	cCampo   := aTBRelZx5[nPos][1]
	cTitulo  := aTBRelZx5[nPos][3]
	
	If ValType(cCampo) = "B"
   		_Get     := Eval(cCampo)
	Else
   		_Get     := ZX5->&cCampo
	EndIf
	
	If ValType(_Get) = "N"
  		nTamanho := 20
	ElseIf ValType(_Get) = "D"
   		nTamanho := 8
	Else
  		nTamanho := Len(_Get)
	EndIf
	If Len(cTitulo) > nTamanho
   		nTamanho := Len(cTitulo)
	EndIf     
	
	If ValType(cCampo) = "C"
   		TRCell():New(oSecao1,cCampo,"ZX5",cTitulo,"@", nTamanho,)   
	ElseIf ValType(cCampo) = "B"
   		TRCell():New(oSecao1,'AAA',"ZX5",cTitulo,"@" , nTamanho, ,cCampo)   
	EndIf
Next nPos                     

Return oReport  

/*
Funcao     : ReportPrint()
Objetivos  : Impressao do relatorio
Autor      : Osman Medeiros Jr.
*/
*------------------------------------------------------------*
Static Function ReportPrint(oReport,nRadRel,cProdIni,cProdFim)
*------------------------------------------------------------*
Local nOldArea := Select()
Local lRet := .F. 
Local cQry, cSelect, oOrderBy, nRegistros

Private cNome := "Produtos x Produtos substitutos"

cSelect := "SELECT COUNT(*) AS NCOUNT "

cQry := " FROM " + RetSqlName("ZX5")+" ZX5"
cQry += " WHERE ZX5.D_E_L_E_T_ <> '*'"
cQry += " AND ZX5.ZX5_FILIAL  = '" + xFilial("ZX5") + "'"

If nRadRel = 1 //Produto Principal 
	If !Empty(cProdIni)
		cQry += " AND ZX5.ZX5_COD >= '" + cProdIni + "'"
	EndIf
	If !Empty(cProdFim)
		cQry += " AND ZX5.ZX5_COD <= '" + cProdFim + "'"
	EndIf
ElseIf nRadRel = 2 // Susbtituto
	If !Empty(cProdIni)
		cQry += " AND ZX5.ZX5_PRODSU >= '" + cProdIni + "'"
	EndIf
	If !Empty(cProdFim)
		cQry += " AND ZX5.ZX5_PRODSU <= '" + cProdFim + "'"
	EndIf
EndIf

TcQuery ChangeQuery(cSelect + cQry)  ALIAS "QRYZX5" NEW

nRegistros := QRYZX5->NCOUNT

QRYZX5->(dbCloseArea())

oReport:SetMeter ( nRegistros )

cSelect  := "SELECT R_E_C_N_O_  AS RECNO "
oOrderBy := " ORDER BY ZX5.ZX5_COD, ZX5.ZX5_ORDEM "

TcQuery ChangeQuery(cSelect + cQry + oOrderBy) ALIAS "QRYZX5" NEW

QRYZX5->(dbGoTop())

//Imprime os registros dessa mesma Filial
oReport:Section(cNome):Init()

Do While QRYZX5->(!Eof()) .And. !oReport:Cancel()
	ZX5->(dbGoTo(QRYZX5->RECNO))
	   
	oReport:Section(cNome):PrintLine() //Impressão da linha
	oReport:IncMeter()                 //Incrementa a barra de progresso
	
	QRYZX5->( dbSkip() )
EndDo

oReport:Section(cNome):Finish()

QRYZX5->(dbCloseArea())
dbSelectArea(nOldArea)  	
                           
Return .T.