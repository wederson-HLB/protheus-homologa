#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.CH"

#define VISUALIZAR 2
#define INCLUIR 3
#define COMPLEMENTAR 4
#define CANCELAR 5
#define REABRIR 6

#define STATUS_ABERTON1 "1"
#define STATUS_CONCLUIDO "2"
#define STATUS_CANCELADO "3"
#define STATUS_ATENDIMENTO "4"
#define STATUS_RETORNO "5"
#define STATUS_TOTVS "6"   
#define STATUS_ABERTON2 "7"

#define MOV_ABERTURA "A"
#define MOV_COMPLEMENTO "C"
#define MOV_CANCELAMENTO "N"
#define MOV_CHECKINN1 "I"
#define MOV_CHECKINN2 "J"
#define MOV_RETORNO "R"
#define MOV_SOLUCAO "S"
#define MOV_REABERTURA "E"
#define MOV_TRANSFERENCIA "X"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDA001  ºAutor  ³Eduardo C. Romanini º Data ³  13/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de abertura de chamados de help-desk.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDA001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Browse da rotina de abertura de chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 13/07/11 16:16
*/
*--------------------*
User Function GTHDA001
*--------------------*
Local cAlias := "Z01"

Local aCores    := {{"Z01->Z01_STATUS == '1'","BR_VERDE"   },; //Aberto N1
					{"Z01->Z01_STATUS == '7'","BR_LARANJA" },; //Aberto N2.
					{"Z01->Z01_STATUS == '2'","BR_VERMELHO"},; //Concluido
				    {"Z01->Z01_STATUS == '3'","BR_PRETO"   },; //Cancelado
				    {"Z01->Z01_STATUS == '4'","BR_AMARELO" },; //Em Atendimento
				    {"Z01->Z01_STATUS == '5'","BR_BRANCO"  },; //Aguardando Retorno
				    {"Z01->Z01_STATUS == '6'","BR_AZUL"    } } //Pendente Totvs

Private cCadastro  := "Help-Desk Grant Thornton"
Private cCondFil   := ""
Private cPastaAnexo:= "\DIRDOC\HD\"

Private aIndexZ01 := {}
Private aRotina	  := {{ "Pesquisar"    ,"PesqBrw"    , 0, 1},;
				   	  { "Visualizar"   ,"U_HDA001Man", 0, 2},;
					  { "Incluir"      ,"U_HDA001Inc", 0, 3},;
					  { "Complementar" ,"U_HDA001Man", 0, 4},;				
					  { "Cancelar"     ,"U_HDA001Man", 0, 4},;
					  { "Legenda"      ,"U_HDA001Leg", 0, 6},;
					  { "Documentos"   ,"U_HDA001Doc", 0, 6}}
					  //{ "Reabrir"      ,"U_HDA001Man", 0, 4},;
Private bFiltraBrw:= {}

//Filtro para exibição dos chamados.
U_HD001Filtro(.F.,cAlias,@aIndexZ01)

DbSelectArea(cAlias)
DbSetOrder(1)

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_HD001Filtro(.T.,"Z01",@aIndexZ01)} )

//Exibe o browse.
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw(cAlias,aIndexZ01)

DbSelectArea(cAlias)

Return Nil

/*
Funcao      : HDA001Leg
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe a legenda do browse
Autor       : Eduardo C. Romanini
Data/Hora   : 14/07/11 18:30
*/
*-----------------------*
User Function HDA001Leg()
*-----------------------*
Local aLegenda := {	{"BR_VERDE"   ,"Aberto N1"},;
					{"BR_LARANJA" ,"Aberto N2"},;
					{"BR_VERMELHO","Encerrado"},;
					{"BR_PRETO"   ,"Cancelado"},;
					{"BR_AMARELO" ,"Em Atendimento"},;
					{"BR_BRANCO"  ,"Aguardando Retorno"},;
					{"BR_AZUL"    ,"Pendente Totvs"}} 

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil

/*
Funcao      : HDA001Inc
Parametros  : cAlias: Alias da tabela
			  nReg  : Recno do registro posicionado
			  nOpc	: Posição do aRotina selecionado.
Retorno     : Nil
Objetivos   : Rotina de inclusão dos chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 15/07/11 11:30
*/
*---------------------------------------*
User Function HDA001Inc(cAlias,nReg,nOpc)
*---------------------------------------*
Local nOpca := 0

Local aCpos     := {}
Local aCposEdit := {}
Local aCposNot  := {}
Local aButtons  := {{"BONUS", {|| U_HDA001Anexo()}, "Anexar Arquivo"}}
Local aParam    := {}

Private lInclui := .T.

Private cItemZ02  := "01"	
Private cDesTpMov := "Abertura do chamado"
Private cTipoMov  := MOV_ABERTURA

Private aAnexos := {}

//Apresentação de FAQ
If !ShowFaq()
	Return .F.	
EndIf


//Realiza a validação para exibir a tela.
If !PreVldChamado(nOpc)
	Return .F.	
EndIf

//Define os campos que não serão exibidos na tela
aCposNot := {"Z01_PARECE","Z01_KNOW","Z01_CODATE","Z01_CODAT2","Z01_NOMATE","Z01_TIMESH","Z01_HRGAST","Z01_TIMEOB",;
			"Z01_DT_ENC","Z01_CTOTVS","Z01_STOTVS","Z01_DTOTVS","Z01_CLASSI"}

//Carrega os campos que serão exibidos na tela (capa).
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !(SX3->X3_CAMPO $ Right(cAlias,2)+"_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		If aScan(aCposNot,AllTrim(SX3->X3_CAMPO)) == 0
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf
	EndIf		 
	SX3->(DbSkip())
EndDo

aAdd(aCpos,"NOUSER")

//Define os campos que serão editaveis
aCposEdit := aClone(aCpos)

//Adiciona codeblock a ser executado dentro da rotina AxInclui
aAdd( aParam,  {|| M->Z01_NOMUSR := UsrRetName(RetCodUsr()), M->Z01_MAILUS := UPPER(UsrRetMail(RetCodUsr())) })	//Antes da abertura da tela
aAdd( aParam,  {|| ValChamado(nOpc)})	//Ao clicar no botao ok
aAdd( aParam,  {|| GrvChamado(nOpc)})  	//Durante a transacao
aAdd( aParam,  {|| MsgInfo("O chamado "+Z01->Z01_CODIGO+" foi incluído com sucesso.","Atenção")})//Termino da transacao

//Exibe a tela de inclusão do chamado
nOpca := AxInclui(cAlias,,3,aCpos,,aCposEdit,,,,aButtons,aParam,,,.T.)

If nOpca == 1 //Botão OK
	//Envio do e-mail
	U_GTHDW001(Z01->Z01_CODIGO,MOV_ABERTURA)
EndIf

Return Nil

/*
Funcao      : HDA001Man
Parametros  : cAlias: Alias da tabela
			  nReg  : Recno do registro posicionado
			  nOpc	: Posição do aRotina selecionado.
Retorno     : Nil
Objetivos   : Rotina de manutenção dos chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 13/07/11 16:30
*/
*---------------------------------------*
User Function HDA001Man(cAlias,nReg,nOpc)
*---------------------------------------*
Local cTitulo   := ""
Local cAuxGet   := ""
Local cAuxPanel := ""
Local cTitPanel := ""

Local nSup     := 0
Local nEsq     := 0
Local nDir     := 0
Local nInf     := 0
Local nOpcA    := 0
Local nSaveSx8 := GetSx8Len()
Local nInc     := 0
Local nTamBox  := 0
Local nPosSol  := 0

Local aSizeAut  := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aCpos	    := {}
Local aCposEdit := {}
Local aCposNot  := {}
Local aButtons  := {}
Local aQtdItem  := {}

Local bOk     := {|| If(ValChamado(nOpc),(nOpcA:=1,oDlgHD:End()),)}
Local bCancel := {|| oDlgHD:End()}

Local oDlgHD
Local oScr
Local oTb
Local oPanelNew
Local oMGetNew

Private lInclui := .F.

Private cMGetNew   := ""
Private cItemZ02   := ""	
Private cDesTpMov  := ""
Private cTipoMov   := ""

Private aAnexos  := {}

Private oEnch

//Realiza a validação para exibir a tela.
If !PreVldChamado(nOpc)
	Return .F.	
EndIf

//Define o título da janela.
If nOpc == VISUALIZAR
	cTitulo := "Visualização de chamado"
ElseIf nOpc == COMPLEMENTAR
	cTitulo   := "Complemento de chamado"
	cTipoMov  := MOV_COMPLEMENTO
ElseIf nOpc == CANCELAR
	cTitulo  := "Cancelamento de chamado"
	cTipoMov := MOV_CANCELAMENTO
ElseIf nOpc == REABRIR
	cTitulo  := "Reabertura de chamado"
	cTipoMov := MOV_REABERTURA
Else
	cTitulo := "Manutenção de chamado"
EndIf

//Define a descrição da movimentação
cDesTpMov := cTitulo

//Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()

aAdd(aObjects,{100,060,.T.,.T.})
aAdd(aObjects,{100,040,.T.,.T.})

aInfo	:= {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj	:= MsObjSize(aInfo,aObjects)
nSup	:= aPosObj[2,1]
nEsq	:= aPosObj[2,2]
nInf	:= aPosObj[2,3]
nDir	:= aPosObj[2,4]

//Define os botões da enchoice bar.
If nOpc <> CANCELAR
	aAdd(aButtons,{"BONUS", {|| U_HDA001Anexo(nOpc)}, "Anexar Arquivo"} )
EndIf

//Define os campos que não serão exibidos na tela
If Z01->Z01_STATUS <> STATUS_CANCELADO .and. Z01->Z01_STATUS <> STATUS_CONCLUIDO 
	aAdd(aCposNot,"Z01_PARECE")
	aAdd(aCposNot,"Z01_CLASSI")
	aAdd(aCposNot,"Z01_KNOW")
EndIf

If Z01->Z01_STATUS == STATUS_ABERTON1 .or. Z01->Z01_STATUS == STATUS_CANCELADO
	aAdd(aCposNot,"Z01_CODATE")
	aAdd(aCposNot,"Z01_CODAT2")
	aAdd(aCposNot,"Z01_NOMATE")
EndIf

If nOpc == VISUALIZAR .Or. nOpc == INCLUIR .Or. nOpc == COMPLEMENTAR .Or. nOpc == CANCELAR  .Or. nOpc == REABRIR
  	aAdd(aCposNot,"Z01_TIMESH")
	aAdd(aCposNot,"Z01_HRGAST")
	aAdd(aCposNot,"Z01_TIMEOB")	
EndIf
//Carrega os campos que serão exibidos na tela (capa).
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !(SX3->X3_CAMPO $ Right(cAlias,2)+"_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		If aScan(aCposNot,AllTrim(SX3->X3_CAMPO)) == 0

			//Adiciona o campo para exibição
			aAdd(aCpos,SX3->X3_CAMPO)

			//Grava a posição do campo solicitação
			If AllTrim(SX3->X3_CAMPO) == "Z01_SOLICI"
				nPosSol := Len(aCpos)
			EndIf

		EndIf
	EndIf		 
	SX3->(DbSkip())
EndDo
aAdd(aCpos,"NOUSER")

//Carrega os campos para memória (capa).
RegToMemory(cAlias,If(nOpc==INCLUIR,.T.,.F.))

//Carrega as variaveis de texto das movimentações do chamado (itens)
Z02->(DbSetOrder(1))
If Z02->(DbSeek(xFilial("Z02")+M->Z01_CODIGO))
	
	While Z02->(!EOF()) .and. Z02->(Z02_FILIAL+Z02_CODIGO) == xFilial("Z02")+M->Z01_CODIGO

	    //Carrega as informações de item
	    Z02->(aAdd(aQtdItem,{Z02_ITEM,Z02_TIPO,Z02_DESCRI,Z02_CODUSR,Z02_DATA,Z02_HORA}))
        
		//Carrega os anexos
		If !Empty(Z02->Z02_ARQUIV)
			Z02->(aAdd(aAnexos,{Z02_ITEM,U_HDA001DesMov(Z02_TIPO),Z02_DATA,Z02_HORA,Z02_ARQUIV}))
		EndIf

		//Carrega o ultimo item de movimentação.
		cItemZ02 := Z02->Z02_ITEM
			
		Z02->(DbSkip())
	EndDo

EndIf

//Define a movimentação atual
cItemZ02 := Soma1(cItemZ02)

//Define o tamanho(altura) do crontrole ToolBox 
If Int(Len(aQtdItem)/3) <= 1
	nTamBox  := nInf-nSup
Else
	nTamBox  := (nInf-nSup) * Int(Len(aQtdItem)/3)
EndIf
                                 		
//Montagem da tela
DEFINE MSDIALOG oDlgHD FROM aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] TITLE cTitulo OF oMainWnd PIXEL

	//Enchoice da capa do chamado.
	oEnch := MsMGet():New(cAlias,nReg,nOpc,,,,aCpos,aPosObj[1],aCposEdit,,,,,oDlgHD,,.T.)

	//Altera o campo "Solicitação" para ser apenas visual.
	oEnch:oBox:aDialogs[1]:Cargo:Cargo[nPosSol]:lReadOnly := .T.
	oEnch:oBox:aDialogs[1]:Cargo:Cargo[nPosSol]:bWhen     := {|| .T.}

	//Cria o ScrollArea
	oScr := TScrollArea():New(oDlgHD,nSup,nEsq,nInf-nSup,nDir-nEsq,.T.,.F.,.T.) 
    
	// Cria a Toolbox
	oTb := TToolBox():New(01,01,oScr,nDir-nEsq,nTamBox)

    //Cria os painéis como historico de movimentação
    For nInc:=1 To Len(aQtdItem)
        
		cAuxGet := ""

		//Adiciona o usuario que realizou a movimentação.
		If aQtdItem[nInc][2] <> MOV_ABERTURA
			If !Empty(aQtdItem[nInc][4])
				cAuxGet	:=  "[" + Capital(AllTrim(UsrFullName(aQtdItem[nInc][4]))) +" em " + DtoC(aQtdItem[nInc][5])+ " as " +aQtdItem[nInc][6]+"]"+ CRLF
			EndIf
		EndIf

		&("cMGet"+AllTrim(aQtdItem[nInc][1])) := aQtdItem[nInc][3] //Descrição
		cAuxGet += &("cMGet"+AllTrim(aQtdItem[nInc][1]))

	    //Cria o objeto TPanel		
	    &("oPanel"+AllTrim(aQtdItem[nInc][1])) := TPanel():New(01,01,cAuxGet,oScr,,,,CLR_BLACK,CLR_LIGHTGRAY)
        cAuxPanel := "oPanel"+AllTrim(aQtdItem[nInc][1])

		//Define o título do painel
		cTitPanel := aQtdItem[nInc][1] + " - " + U_HDA001DesMov(aQtdItem[nInc][2])
        
		//Adiciona o Painel criado no ToolBox	
		oTb:AddGroup(&(cAuxPanel),cTitPanel,)
	Next	
    
    //Cria o painel que será editavel
	If nOpc <> VISUALIZAR
		oMGetNew := TMultiGet():New(03,03,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oScr,nDir-nEsq-5,1000,,.F.,,,,.T.)
		oMGetNew:EnableVScroll(.T.)
		
		//Adiciona o Painel criado no ToolBox	
		If nOpc == COMPLEMENTAR
			oTb:AddGroup(oMGetNew,"Complemento:")

		ElseIf nOpc == CANCELAR
			oTb:AddGroup(oMGetNew,"Cancelamento:")		

		ElseIf nOpc == REABRIR
			oTb:AddGroup(oMGetNew,"Reabertura:")		

		EndIf

		//Abre o painel selecionado.
		oTb:SetCurrentGroup(oMGetNew)
	EndIf

    oScr:SetFrame(oTb)

ACTIVATE MSDIALOG oDlgHD ON INIT EnchoiceBar(oDlgHD,bOk,bCancel,,aButtons) CENTERED

If nOpc <> VISUALIZAR
	If nOpcA == 1 //Gravação
		Begin Transaction
			GrvChamado(nOpc)
			While (GetSx8Len() > nSaveSx8 )
				ConfirmSX8()
			EndDo
			EvalTrigger()
		End Transaction  
	
		//Envia o e-mail
		U_GTHDW001(Z01->Z01_CODIGO,cTipoMov)
	Else
		While (GetSx8Len() > nSaveSx8 )
			RollBackSX8()
		EndDo
	EndIf
EndIf
	
Return Nil

/*
Funcao      : GrvChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Gravar o chamado
Autor       : Eduardo C. Romanini
Data/Hora   : 14/07/11 16:00
*/
*------------------------------*
Static Function GrvChamado(nOpc)
*------------------------------*
Local cCodigo    := ""
Local cPastaCod  := "" 
Local cPastaItem := ""
Local cPasta     := ""
Local cArquiv    := ""
Local cOrig      := ""
Local cDest      := ""
Local cDe        := ""
Local cPara      := ""

Local nAt := 0
Local nP  := 0    

//Monta o diretório principal
If Right(cPastaAnexo,1) <> "\"
    cPastaAnexo += "\" 
EndIf

If !ExistDir(cPastaAnexo)
	If !MontaDir(cPastaAnexo)
		MsgInfo("Não foi possivel criar o diretório principal de gravação de anexos","Atenção")
	Endif
EndIf

//Gravação da tabela de capa do chamado
If nOpc == INCLUIR
	Z01->Z01_STATUS := STATUS_ABERTON1
    Z01->Z01_DTABER := dDataBase
    Z01->Z01_HRABER := Time() 
    Z01->Z01_CODUSR := RetCodUsr()

Else	
	Z01->(RecLock("Z01",.F.))

	SX3->(DbSetOrder(1))
	SX3->(DbSeek("Z01"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "Z01"
		If AllTrim(SX3->X3_CAMPO) <> "Z01_FILIAL" .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
			If Alltrim(SX3->X3_CONTEXT) <> "V"
				Z01->&(SX3->X3_CAMPO) := M->&(SX3->X3_CAMPO)
			EndIf 
		EndIf
		SX3->(DbSkip())
	EndDo

	//Tratamento do status do chamado	
	If nOpc == CANCELAR
		Z01->Z01_STATUS := STATUS_CANCELADO
		Z01->Z01_PARECE := "Cancelamento: " + CRLF + AllTrim(cMGetNew)

	ElseIf nOpc == REABRIR
		Z01->Z01_STATUS := STATUS_ABERTON1
    	Z01->Z01_DT_ENC := CtoD("  /  /  ")
    	Z01->Z01_CLASSI := ""    
    
    ElseIf nOpc == COMPLEMENTAR
		If Z01->Z01_STATUS == STATUS_RETORNO
			If !Empty(Z01->Z01_CODATE) .or. !Empty(Z01->Z01_CODAT2)
				If !Empty(M->Z01_CTOTVS) .and. AllTrim(M->Z01_STOTVS) = "T"
					Z01->Z01_STATUS := STATUS_TOTVS
				Else			
					Z01->Z01_STATUS := STATUS_ATENDIMENTO
				EndIf
			Else
				Z01->Z01_STATUS := STATUS_ABERTON1
			EndIf

        EndIf
	EndIf
	
	Z01->(MsUnlock())
EndIf
	
//Gravação da movimentação (itens) do chamado
Z02->(RecLock("Z02",.T.))

Z02->Z02_FILIAL := xFilial("Z02")
Z02->Z02_CODIGO := M->Z01_CODIGO
Z02->Z02_ITEM   := cItemZ02
Z02->Z02_DATA   := dDataBase
Z02->Z02_HORA   := Time()
Z02->Z02_CODUSR := RetCodUsr()
Z02->Z02_TIPO   := cTipoMov

If nOpc == INCLUIR
	Z02->Z02_DESCRI := 	"Abertura do chamado: " + M->Z01_CODIGO 
Else
	Z02->Z02_DESCRI := AllTrim(cMGetNew)
EndIf

//Gravação do arquivo anexo
nP := aScan(aAnexos,{|a| a[1] == cItemZ02})
If nP > 0

	cPastaCod   := AllTrim(Z02->Z02_CODIGO) + "\"
	cPastaItem  := AllTrim(Z02->Z02_ITEM) + "\"

	cPasta := cPastaAnexo+cPastaCod+cPastaItem

	//Monta o diretório de gravação dos anexos.		
	If !ExistDir(cPasta)
		If !MontaDir(cPasta)
			MsgInfo("Não foi possivel criar o diretório especifico de gravação de anexos","Atenção")
        	Return
		EndIf
	EndIf		
	
	cArquiv := aAnexos[nP][5]
	nAt := 1
	While nAt > 0
       	nAt := At("\",cArquiv)
    	cArquiv := Substr(cArquiv,nAt+1,Len(cArquiv))
	EndDo
	        
	cOrig := AllTrim(aAnexos[nP][5])
	cDest := Alltrim(cPasta)
            
	//Realiza a copia para a pasta da proposta.
	If !Cpyt2s(cOrig,cDest,.F.)
       	MsgInfo("O arquivo anexo não foi copiado.","Atenção")
	Else
		//Grava o nome do arquivo
		Z02->Z02_ARQUIV := AllTrim(cArquiv)
	EndIf
EndIf

Z02->(MsUnlock())

//Gravação do e-mail e ramal.
Z05->(DbSetOrder(1))
If Z05->(DbSeek(xFilial("Z05")+AllTrim(UPPER(M->Z01_MAILUS))))

	If M->Z01_RAMAL <> Z05->Z05_RAMAL
		
		If MsgYesNo("Deseja atualizar o cadastro de seu ramal de "+AllTrim(Z05->Z05_RAMAL)+" para "+AllTrim(M->Z01_RAMAL)+" ?","Atenção")
			Z05->(RecLock("Z05",.F.))
		
			Z05->Z05_RAMAL := M->Z01_RAMAL
		
			Z05->(MsUnlock())
		EndIf
	EndIf

	If M->Z01_DEPTO <> Z05->Z05_DEPTO
		                                                       
		If SX5->(DbSeek(xFilial("SX5")+"Z2"+Z05->Z05_DEPTO))     
			cDe   := SX5->X5_DESCRI 
		EndIf          
		
		If SX5->(DbSeek(xFilial("SX5")+"Z2"+M->Z01_DEPTO))     
			cPara := SX5->X5_DESCRI
		EndIf
			
		
		If MsgYesNo("Deseja atualizar o cadastro de seu departamento de "+AllTrim(cDe)+" para "+alltrim(cPara)+" ?","Atenção")
			Z05->(RecLock("Z05",.F.))
			Z05->Z05_DEPTO := M->Z01_DEPTO
			Z05->(MsUnlock())  
		EndIf	
		
	EndIf
Else
	Z05->(RecLock("Z05",.T.))

	Z05->Z05_FILIAL := xFilial("Z05")
	Z05->Z05_EMAIL  := AllTrim(UPPER(M->Z01_MAILUS))
	Z05->Z05_RAMAL  := M->Z01_RAMAL
	Z05->Z05_NOME   := M->Z01_NOMUSR
	Z05->Z05_DEPTO  := M->Z01_DEPTO
	
	Z05->(MsUnlock())

EndIf

Return Nil    

/*
Funcao      : ValChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Valida as informações digitadas no chamado
Autor       : Eduardo C. Romanini
Data/Hora   : 14/07/11 16:00
*/
*------------------------------*
Static Function ValChamado(nOpc)
*------------------------------*
Local lRet := .T.

If nOpc == VISUALIZAR
	Return .T.
EndIf

If nOpc == INCLUIR     

	If M->Z01_TIPO == "C" //Especifico para cliente.
		If Empty(M->Z01_CODEMP) .and. Empty(M->Z01_FILEMP)
        	MsgInfo("Para o tipo de chamado Especifico, o codigo da empresa deve ser preenchido.","Atenção")
        	Return .F.
		EndIf	
	EndIf
	
	//Valida o preenchimento do ramal.
	If Empty(M->Z01_RAMAL)
		MsgInfo("Favor preencher o número do seu ramal.","Atenção")	
		Return .F.
	EndIf
	
	//Valida o tipo do usuário
	If M->Z01_TPSOLI == "E" //Externo
		If Empty(M->Z01_DDD)
			MsgInfo("Favor preencher o DDD de contato do cliente.","Atenção")
			Return .F.
		EndIf

		If Empty(M->Z01_TEL)
			MsgInfo("Favor preencher o telefone de contato do cliente.","Atenção")
			Return .F.
		EndIf

		If Empty(M->Z01_EMAIL)
			MsgInfo("Favor preencher o e-mail de contato do cliente.","Atenção")
			Return .F.
		EndIf

	EndIf
	
	//Valida o preenchimento do departamento.
	If Empty(M->Z01_DEPTO)
		MsgInfo("Favor preencher o seu departamento.","Atenção")	
		Return .F.
	EndIf
	
	
Else
	If Empty(cMGetNew)
		MsgInfo("Favor preencher a descrição da movimentação do chamado.","Atenção")
		Return .F.	
	EndIf
EndIf

Return lRet            

/*
Funcao      : PreVldChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Valida as informações do chamado para exibir a tela de movimentação
Autor       : Eduardo C. Romanini
Data/Hora   : 18/07/11 15:20
*/
*---------------------------------*
Static Function PreVldChamado(nOpc)
*---------------------------------*
Local lRet := .T.

If nOpc == INCLUIR
	If Empty(UsrRetMail(RetCodUsr()))
		MsgInfo("Você não possui endereço de e-mail cadastrado no sistema Help-Desk. Favor solicitar cadastro ao depto. de T.I.","Atenção")
		Return .F.
	EndIf

ElseIf nOpc == COMPLEMENTAR
	If Z01->Z01_STATUS == STATUS_CANCELADO
		MsgInfo("O chamado já foi cancelado. Não poderá ser complementado.","Atenção")
		Return .F.
	EndIf

	If Z01->Z01_STATUS == STATUS_CONCLUIDO
		MsgInfo("O chamado já foi solucionado. Não poderá ser complementado.","Atenção")
		Return .F.
	EndIf

	If AllTrim(RetCodUsr()) <> AllTrim(Z01->Z01_CODUSR)
		MsgInfo("O chamado foi incluído por outro usuário. Não poderá ser complementado.","Atenção")
		Return .F.
	EndIf

ElseIf nOpc == CANCELAR

	If Z01->Z01_STATUS == STATUS_CANCELADO
		MsgInfo("Esse chamado já se encontra no status cancelado.","Atenção")
		Return .F.
	EndIf

	If Z01->Z01_STATUS == STATUS_CONCLUIDO
		MsgInfo("O chamado já foi solucionado. Não poderá ser cancelado.","Atenção")
		Return .F.
	EndIf

	If AllTrim(RetCodUsr()) <> AllTrim(Z01->Z01_CODUSR)
		MsgInfo("O chamado foi incluído por outro usuário. Não poderá ser complementado.","Atenção")
		Return .F.
	EndIf

ElseIf nOpc == REABRIR

	If Z01->Z01_STATUS == STATUS_CANCELADO
		MsgInfo("Esse chamado está cancelado. Não poderá ser reaberto.","Atenção")
		Return .F.
	EndIf

	If Z01->Z01_STATUS <> STATUS_CONCLUIDO
		MsgInfo("Esse chamado ainda não foi solucionado. Não poderá ser reaberto.","Atenção")
		Return .F.
	EndIf
	
	If !Empty(Z01->Z01_DT_ENC)
		If (dDataBase - Z01->Z01_DT_ENC) >= 30
			MsgInfo("Esse chamado não poderá ser reaberto porque já se passaram 30 dias de seu encerramento.","Atenção")
			Return .F.		
        EndIf
  	EndIf
EndIf

Return lRet                   

/*
Funcao      : HDA001Dic
Parametros  : cCampo: Campo do dicionario de dados.
              cTipo : Tipo do campo do X3.
Retorno     : Nil
Objetivos   : Tratamento de dicionário para os campos da rotina.
Autor       : Eduardo C. Romanini
Data/Hora   : 18/07/11 17:00
*/
*-----------------------------------*
User Function HDA001Dic(cCampo,cTipo)
*-----------------------------------*
Local lInc := .F.

Local cRet  := ""
Local cCbox := ""

Local nAt := 0

Local aAux := {}

If Type("lInclui") == "L"
	lInc := lInclui
EndIf

If cTipo == "RELACAO"
	If cCampo == "Z01_EMPRES"

		If !lInc
			If !Empty(Z01->Z01_CODEMP)
				Z04->(DbSetOrder(1))
				If Z04->(DbSeek(xFilial("Z04")+Z01->Z01_CODEMP+Z01->Z01_FILEMP))
					cRet := AllTrim(Z04->Z04_NOME)+" / "+AllTrim(Z04->Z04_NOMFIL)
				EndIf
			EndIf
		EndIf
				
	ElseIf cCampo == "Z01_EMPAMB"
		
		If !lInc
			If !Empty(Z01->Z01_CODEMP)
				Z04->(DbSetOrder(1))
				If Z04->(DbSeek(xFilial("Z04")+Z01->Z01_CODEMP+Z01->Z01_FILEMP))
					cRet := AllTrim(Z04->Z04_AMB)
				EndIf
			EndIf
		EndIf

	ElseIf cCampo == "Z01_RAMAL"
	
		Z05->(DbSetOrder(1))
		If Z05->(DbSeek(xFilial("Z05")+UPPER(AllTrim(UsrRetMail(RetCodUsr())))))
	    	cRet := Z05->Z05_RAMAL
		EndIf

	ElseIf cCampo == "Z01_NOMATE"
		If !lInc
			If !Empty(Z01->Z01_CODATE)
				Z03->(DbSetOrder(1))
				If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODATE))
					cRet := AllTrim(Z03->Z03_NOME)
				EndIf
			ElseIf !Empty(Z01->Z01_CODAT2)
				Z03->(DbSetOrder(1))
				If Z03->(DbSeek(xFilial("Z03")+Z01->Z01_CODAT2))
					cRet := AllTrim(Z03->Z03_NOME)
				EndIf
			EndIf
		EndIf          

	ElseIf cCampo == "Z01_DEPTO"
		Z05->(DbSetOrder(1))
		If Z05->(DbSeek(xFilial("Z05")+UPPER(UsrRetMail(RetCodUsr())) ) )
			cRet := Z05->Z05_DEPTO
		EndIf		

	ElseIf cCampo == "Z01_DESC_D"

		If !lInc
			If !Empty(M->Z01_DEPTO)
				SX5->(DbSetOrder(1))
				If SX5->(DbSeek(xFilial("SX5")+"Z2"+M->Z01_DEPTO))
					cRet := SX5->X5_DESCRI
				EndIf
				
			EndIf
		Else 
			Z05->(DbSetOrder(1))
			If Z05->(DbSeek(xFilial("Z05")+UPPER(UsrRetMail(RetCodUsr()))))
				If SX5->(DbSeek(xFilial("SX5")+"Z2"+Z05->Z05_DEPTO))
					cRet := SX5->X5_DESCRI
				EndIf
		    EndIf
		EndIf
	EndIf

ElseIf cTipo == "GATILHO"

	If cCampo == "Z01_EMPAMB"
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek("Z04_AMB"))
		    cCbox := AllTrim(SX3->X3_CBOX)
			nAt := At(";",cCbox)
			While nAt > 0
				cAux  := Left(cCbox,nAt-1)
				aAdd(aAux,{Left(cAux,1),Substr(cAux,3)}) 
				cCbox := Substr(cCbox,nAt+1)
				nAt := At(";",cCbox)
			EndDo
			cAux  := cCbox
			aAdd(aAux,{Left(cAux,1),Substr(cAux,3)}) 			
		EndIf
		If lInc
			If !Empty(M->Z01_CODEMP)
				Z04->(DbSetOrder(1))
				If Z04->(DbSeek(xFilial("Z04")+M->Z01_CODEMP+M->Z01_FILEMP))
					cRet := AllTrim(Z04->Z04_AMB)
					nPos := aScan(aAux,{|a| a[1]==cRet})					
					If nPos > 0
						cRet:=aAux[nPos][2]
					EndIf
				EndIf
			EndIf
		EndIf
    ElseIf cCampo == "Z01_EMPRES"
		If !Empty(M->Z01_CODEMP)
			Z04->(DbSetOrder(1))
			If Z04->(DbSeek(xFilial("Z04")+M->Z01_CODEMP+M->Z01_FILEMP))
				cRet := AllTrim(Z04->Z04_NOME)+" / "+AllTrim(Z04->Z04_NOMFIL)
			EndIf
		EndIf
    Endif

EndIf

Return cRet

/*
Funcao      : HDA001Filtro
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Eduardo C. Romanini
Data/Hora   : 18/07/11 17:00
*/
*------------------------------------------------*
User Function HD001Filtro(lExibe,cAlias,aIndexZ01)
*------------------------------------------------*
Local cCondFil := ""

//Inicializa as variaveis de pergunta.
Pergunte("GTHD001",lExibe,"Filtro de exibição")

//Exibe apenas chamados do usuário logado.
cCondFil := "Z01_CODUSR == '"+RetCodUsr()+"'"

cCondFil += " .AND. "

//Filtro de data de abertura do chamado.
cCondFil += "DtoS(Z01_DTABER) >= '" +DtoS(mv_par01)+"'" //Data Inicial
cCondFil += " .AND. "
cCondFil += "DtoS(Z01_DTABER) <= '" +DtoS(mv_par02)+"'" //Data Final

//Verifica se exibe os cancelados.
If mv_par03 == 2 //Nao
	cCondFil += " .AND. "
	cCondFil += "Z01_STATUS <> '"+STATUS_CANCELADO+"'"
EndIf

//Verifica se exibe os encerrados.
If mv_par04 == 2 //Nao
	cCondFil += " .AND. "
	cCondFil += "Z01_STATUS <> '"+STATUS_CONCLUIDO+"'"
EndIf

//Verifica se o filtro foi reformulado.                      
If lExibe
	// Deleta o filtro anterior utilizado na função FilBrowse
	EndFilBrw(cAlias,aIndexZ01)	
EndIf

//Determina o novo filtro
bFiltraBrw := {|| FilBrowse(cAlias,@aIndexZ01,@cCondFil)}

//Atualiza o MBrowse.
Eval(bFiltraBrw)

(cAlias)->(DbGoTop())

Return Nil   

/*
Funcao      : HDA001Anexo
Parametros  : nOpc: Opção selecionada no MBrowse 
Retorno     : Nil
Objetivos   : Rotina para manutenção de anexos.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/07/11 14:50
*/
*-----------------------------*
User Function HDA001Anexo(nOpc)
*-----------------------------*
Local lRet := .F.

Local cArqAnexo := ""

Local nI := 0
Local nP := 0

Local aButtons := {}
Local aStru    := {	{"ARQUIVO","C",100,0},;
					{"DATAARQ","D",008,0},;
					{"HORAARQ","C",010,0}}

Local bOk     := {|| lRet:= .T.,oDlgAnexo:End()}
Local bCancel := {|| oDlgAnexo:End()}

Local oDlgAnexo

Private lRefresh := .T.

Private cLastPath := cPastaAnexo

Private aHeader     := {}
Private aCols       := {}
Private aColsAcento := {}

Private oMsGet

Begin Sequence

If nOpc <> VISUALIZAR
	aAdd(aButtons,{ "BMPINCLUIR" ,{ || AddFile() }, "Adicionar arquivo" + " <F3>", "Adicionar"})
	aAdd(aButtons,{ "BPMSDOCE"   ,{ || DelFile() }, "Remover arquivo"            , "Remover"  })
EndIf

aHeader := {{"Item"   ,"ITEM"   ,"@!",002,0,".t.",nil,"C",nil,nil } ,;
			{"Tipo"   ,"TIPO"   ,"@!",020,0,".t.",nil,"C",nil,nil } ,;			
            {"Data"   ,"DATAARQ","@D",008,0,".t.",nil,"D",nil,nil } ,;
            {"Hora"   ,"HORAARQ","@!",005,0,".t.",nil,"C",nil,nil } ,;
			{"Arquivo","ARQUIVO","@!",120,0,".t.",nil,"C",nil,nil }}

If Len(aAnexos) > 0
	For nI:=1 To Len(aAnexos)
		aAdd(aCols,{aAnexos[nI][1],aAnexos[nI][2],aAnexos[nI][3],aAnexos[nI][4],aAnexos[nI][5],.F.})
		AAdd(aColsAcento,aCols[nI][5])
	Next
Endif

DEFINE MSDIALOG oDlgAnexo TITLE "Seleção de arquivo" FROM 1,1 To 300,470 OF oMainWnd Pixel
                                             
	oMSGet:= MSGetDados():New(1, 1, 1, 1, 1,,,"",.F.,{})
 	oMsGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
	oMsGet:oBrowse:blDblClick := {|| AbreArq()}
	
	oMSGet:ForceRefresh()

	SetKey(VK_F3,{|| AddFile() })

Activate MsDialog oDlgAnexo ON INIT EnchoiceBar(oDlgAnexo,bOk,bCancel,,aButtons) Centered

SetKey(VK_F3,Nil)

If lRet
	For nI:=1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])] //Verifica se está deletado
        	If aScan(aAnexos,{|e| AllTrim(e[1]) == AllTrim(aCols[nI][1])}) == 0
	        	aAdd(aAnexos,{aCols[nI][1],aCols[nI][2],aCols[nI][3],aCols[nI][4],aCols[nI][5]})
	        EndIf
		Else
        
        	nP := aScan(aAnexos,{|e| AllTrim(e[1]) == AllTrim(aCols[nI][1])}) == 0
        	If nP > 0
        		aDel(aAnexos,nP)
        		ASize(aAnexos,Len(aAnexos)-1)
        	EndIf
        	
		EndIf
	Next	
EndIf

End Sequence

Return lRet

/*
Funcao      : DelFile
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Deleta o arquivo anexado.
Autor       : Eduardo C. Romanini
Data/Hora   : 20/07/11 10:50
*/
*-----------------------*
Static Function DelFile()
*-----------------------*
Local nP := 0

//Verifica se existe arquivo anexado.
nP := aScan(aCols,{|a| a[1] == cItemZ02})
If nP > 0
    
	If MsgYesNo("Confirma a exclusão do arquivo anexo?","Atenção")
		aDel(aCols,nP)
		aSize(aCols,Len(aCols)-1)

		aColsAcento := {}
	EndIf

	oMsGet:oBrowse:Refresh()
	
Else
	MsgAlert("Nenhum arquivo foi anexado para essa movimentação.","Atenção")
EndIf

Return .t.

/*
Funcao      : AddFile
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Adiciona o arquivo anexo.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/07/11 15:00
*/
*-----------------------*
Static Function AddFile()
*-----------------------*
Local oDlg
Local oFont
Local oSay

Local nP := 0

Local lOk := .f.
Local bOk     := {|| If(DocValid(),(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local aDir, i, j
Local bOld,oArquivo
Private bFileAction := {|| cArquivo := ChooseFile()}, cArquivo := Space(200)

//Verifica se existe arquivo anexado.
nP := aScan(aCols,{|a| a[1] == cItemZ02})
If nP > 0
	MsgInfo("Já existe arquivo anexado para essa movimentação.","Atenção")
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE "Seleção de arquivos" FROM 1,1 To 91,376 OF oMainWnd Pixel
      
	@ 14,4 to 43,185 Label "Escolha o arquivo a ser anexado:" PIXEL
      
	@ 25,12 MsGet oArquivo Var cArquivo Size 150,07 Pixel Of oDlg
      
	@ 25,162 Button "..." Size 10,10 Pixel Action .t. Of oDlg

	oDlg:aControls[3]:bAction := bFileAction

	Define Font oFont Name "Arial" SIZE 0,-10 //BOLD
	@ 26,173 Say oSay Var "(F3)" Size 10,10 Pixel Of oDlg Color CLR_GRAY
	oSay:oFont := oFont

	bOld := SetKey(VK_F3)
	SetKey(VK_F3,bFileAction)
      
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED
	
SetKey(VK_F3,bOld)

If !lOk
	Return
EndIf
   
If Type("aCols[1][1]") <> "U" .And. Empty(aCols[1][1])
	ADel(aCols,1)
	ASize(aCols,Len(aCols)-1)
EndIf
   
cArquivo := Upper(AllTrim(cArquivo))

cFolder  := If(Right(cArquivo,1) = "\",cArquivo,SubStr(cArquivo,1,RAt("\",cArquivo)))

cArquivo += If(!File(cArquivo),"*.ZIP","")
   
aDir := Directory(cArquivo)

Private cArq

For i := 1 to Len(aDir)
	cArq := AllTrim(Upper(cFolder+aDir[i][1]))
	lLoop := .f.
	For j := 1 To Len(aColsAcento)
		If aColsAcento[j] == cArq .And. !aCols[j][Len(aCols[j])]
			lLoop := .t.
			Exit
		EndIf
	Next
	If lLoop
		Loop
	EndIf
	aAdd(aCols, Array( Len(aHeader)+1 ) )
	n := Len(aCols)
	aCols[n][Len(aCols[n])] := .f.
	aCols[n][1] := cItemZ02                               //item
	aCols[n][2] := cDesTpMov                              //tipo
	aCols[n][3] := dDatabase                              //data
	aCols[n][4] := Time()                                 //hora
	aCols[n][5] := IncSpace(cArq,aHeader[5][4],.f.)       //nome do arquivo
	AAdd(aColsAcento,cArq)
Next
   
oMsGet:oBrowse:Refresh()

Return Nil         

/*
Funcao      : DocValid
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Validação da digitação do caminho do anexo.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/07/11 15:00
*/
*------------------------*
Static Function DocValid()
*------------------------*
Local cArq := AllTrim(Upper(cArquivo))
Local nAt := 0

If Empty(cArq)
   MsgInfo("Informe o caminho e o nome do arquivo","Aviso")
   Return .f.
EndIf

If Right(cArq,4) <> ".ZIP" .And. Right(cArq,1) <> "\"
   cArq += "\"
EndIf

If !File(cArq)
   If !lIsDir(cArq)
      MsgStop("O arquivo especificado não existe.","Aviso")
      Return .f.
   EndIf
   
   If Len(Directory(cArq+"*.ZIP")) = 0
      MsgStop("Não há arquivos no diretório especificado.","Aviso")
      Return .f.
   EndIf
EndIf

cArquivo := cArq

nAt := 1
While nAt > 0
	nAt := At("\",cArq)
    cArq := Substr(cArq,nAt+1,Len(cArq))
EndDo

//Valida o nome do arquivo.
If AllTrim(cArq) <> AllTrim(M->Z01_CODIGO)
	MsgStop("O nome do arquivo anexo deve ser igual ao codigo do chamado.","Aviso")
	Return .F.
EndIf

Return .t.

/*
Funcao      : ChooseFile
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela de seleção do arquivo anexo.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/07/11 15:00
*/
*--------------------------*
Static Function ChooseFile()
*--------------------------*
Local cTitle:= "Seleção de arquivos"
Local cMask := "Formato ZIP|*.zip"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_LOCALHARD

Local aArea := GetArea()

SetKey(VK_F3,Nil)

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.F.,nOptions,.F.)

If Empty(cFile)
   Return cArquivo
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

SetKey(VK_F3,bFileAction)

RestArea(aArea)

Return IncSpace(cFile,200,.f.)

/*
Funcao      : AbreArq
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Abre o arquivo anexo selecionado.
Autor       : Eduardo C. Romanini
Data/Hora   : 20/07/11 13:45
*/
*-----------------------*
Static Function AbreArq()
*-----------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local cPastaFrom  := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY
Local nAt := 0

Local aArea := GetArea()

//Define o arquivo
If Len(aCols) > 0
	cFile := aCols[n][5]
EndIf

//Verifica se existe arquivo a ser aberto.
If Empty(cFile)
	Return
EndIf

nAt := 1
While nAt > 0
	nAt := At("\",cFile)
    cFile := Substr(cFile,nAt+1,Len(cFile))
EndDo

//Exibe tela para gravar o arquivo.
cPastaTo := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

//Grava o arquivo no local selecionado.
If !Empty(cPastaTo)
	
	cPastaCod   := AllTrim(M->Z01_CODIGO) + "\"
	cPastaItem  := AllTrim(aCols[n][1]) + "\"

	cPastaFrom := cPastaAnexo+cPastaCod+cPastaItem
	
	cFile := cPastaFrom + AllTrim(cFile)
	
	If CpyS2T(cFile,cPastaTo,.F.)
		MsgInfo("Arquivo salvo com sucesso.","Atenção")
	Else
		MsgInfo("Erro ao salvar o arquivo.","Atenção")
	EndIf
	
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

RestArea(aArea)

Return Nil

/*
Funcao      : HDA001DesMov
Parametros  : nTpMov: Tipo da movimentação
Retorno     : cRet: Descrição da movimentação
Objetivos   : Retorna a descrição da movimentação
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 16:50
*/
*--------------------------------*
User Function HDA001DesMov(nTpMov)
*--------------------------------*
Local cRet := ""

If nTpMov == MOV_ABERTURA
	cRet := "Abertura do chamado"
ElseIf nTpMov == MOV_COMPLEMENTO
	cRet := "Complemento do chamado"
ElseIf nTpMov == MOV_CANCELAMENTO
	cRet := "Cancelamento do chamado"
ElseIf nTpMov == MOV_CHECKINN1
	cRet := "Check-In N1 do chamado"
ElseIf nTpMov == MOV_CHECKINN2
	cRet := "Check-In N2 do chamado"
ElseIf nTpMov == MOV_RETORNO
	cRet := "Solicitação de retorno do usuário"
ElseIf nTpMov == MOV_SOLUCAO
	cRet := "Solução do chamado"
ElseIf nTpMov == MOV_REABERTURA
	cRet := "Reabertura do chamado"
ElseIf nTpMov == MOV_TRANSFERENCIA
	cRet := "Transferência"	
EndIf

Return cRet
 

/*
Funcao      : ShowFaq
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Apresenta a opção de download da Faq
Autor       : Jean Victor Rocha
Data/Hora   : 18/04/2017
*/
*-----------------------*
Static Function ShowFaq()
*-----------------------*
Local i
Local lRet := .F.
Local cDir := "\documentos"
Local cFileFaq := ""
Local aFilesFaq := DIRECTORY(cDir+"\*.PDF","A")

If !ExistDir(cDir)
	MakeDir(cDir)
EndIf
If !ExistDir(cDir+"\lOG")
	MakeDir(cDir+"\lOG")
EndIf

//Busca o ultimo arquivo de FAQ disponivel no repositorio de arquivos. 
For i:=1 to len(aFilesFaq)
	If LEFT(UPPER(aFilesFaq[i][1]),3) == "FAQ"
		cFileFaq := cDir+"\"+aFilesFaq[i][1]
	EndIf
Next i
                       
cFileFaq := "\documentos\SERVICE DESK - Manual de utilização.pdf"
      
If EMPTY(cFileFaq)
	Return .T.
EndIf
               
oTFont1 := TFont():New('Arial',,-14,.T.,.T.)
oTFont2 := TFont():New('Arial',,-12,.T.,.F.)

SetPrvt("oDlg1","oCBox1","oBtn1")

//oDlg1      := MSDialog():New( 160,200,380,920,"Grant Thornton Brasil - FAQ",,,.F.,,,CLR_WHITE,,,.T.,,,.T. )
//oSay0      := TSay():New( 005,004,{||""},;
//										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay1      := TSay():New( 015,004,{||"Você já consultou nosso Banco de Conhecimento - FAQ? "},;
//										oDlg1,,oTFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay2      := TSay():New( 025,004,{||"Ainda não?! Faça o download e verifique se a solução do seu chamado já se encontra neste documento."},;
//										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay3      := TSay():New( 035,004,{||"Além disso, temos outras documentações disponíveis na opção Documentos que podem auxilia-los na solução do chamado."},;
//										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay4      := TSay():New( 045,004,{||""},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay5      := TSay():New( 055,004,{||"Caso a solução não esteja em nenhum documento, clique em 'Abrir Chamado'."},;
//										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
//oSay6      := TSay():New( 065,004,{||""},;
//										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oDlg1      := MSDialog():New( 160,200,380,920,"Grant Thornton Brasil - Service Desk",,,.F.,,,CLR_WHITE,,,.T.,,,.T. )
oSay0      := TSay():New( 005,004,{||""},;
										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay1      := TSay():New( 015,004,{||"Plataforma Service Desk"},;
										oDlg1,,oTFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay2      := TSay():New( 025,004,{||"A partir do dia 12 de julho de 2017, os chamados devem ser feitos unicamente  pela nova"},;
										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay3      := TSay():New( 035,004,{||"plataforma de Service Desk: https://servicedesk.grantthornton.com.br"},;
										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay4      := TSay():New( 045,004,{||""},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay5      := TSay():New( 055,004,{||"Para informações de acesso e detalhes da ferramenta, clique em Download para obter o passo a passo."},;
										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)
oSay6      := TSay():New( 065,004,{||""},;
										oDlg1,,oTFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008)

//oBtn0      := TButton():New( 90,200,"Abrir chamado",oDlg1,{|| lRet:=.T.,oDlg1:end()},070,012,,,,.T.,,"",,,,.F. )
oBtn1      := TButton():New( 90,280,"Download",oDlg1,{|| DownArq(cFileFaq),oDlg1:end()},070,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return lRet


/*
Funcao      : HDA001Doc
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Download de arquivos da pasta
Autor       : Jean Victor Rocha
Data/Hora   : 18/04/2017
*/
*-----------------------*
User Function HDA001Doc()
*-----------------------*
Local i
Local aItens := {}
Local cDir := "\documentos"
Local aFiles := DIRECTORY(cDir+"\*.*","A")
Local cGetDoc := ""

If !ExistDir(cDir)
	MakeDir(cDir)
EndIf
If !ExistDir(cDir+"\lOG")
	MakeDir(cDir+"\lOG")
EndIf
      
//Adiciona os arquivos no combobox
For i:=1 to len(aFiles)
	aAdd(aItens,aFiles[i][1])
Next i

If Len(aItens) > 0
	cGetDoc := aItens[1]
EndIf

SetPrvt("oDlg1","oCBox1","oBtn1")

oDlg1      := MSDialog():New( 157,257,252,810,"Repositório de arquivos",,,.F.,,,,,,.T.,,,.T. )
oCBox1     := TComboBox():New( 008,004,{|u|if(PCount()>0,cGetDoc:=u,cGetDoc)},aItens,268,010,oDlg1,,,,,,.T.,,,,,,,,,"cGetDoc" )
oBtn1      := TButton():New( 024,234,"Download",oDlg1,{|| DownArq(cDir+"\"+cGetDoc),oDlg1:end()},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return .T.

/*
Funcao      : DownArq
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Abre o arquivo anexo selecionado.
Autor       : Jean Victor Rocha
Data/Hora   : 18/04/2017
*/
*----------------------------*
Static Function DownArq(cFile)
*----------------------------*
Local cTitle:= "Salvar arquivo"
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "c:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY
Local cLog := cFile+"|"+cUserName+" - "+DTOC(Date())+" "+Time()

//Exibe tela para gravar o arquivo.
cPastaTo := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

//Grava o arquivo no local selecionado.
If !Empty(cPastaTo)
	If CpyS2T(cFile,cPastaTo,.F.)
		GrvLog(cLog)
		MsgInfo("Arquivo salvo com sucesso.","Atenção")
	Else
		MsgInfo("Erro ao salvar o arquivo.","Atenção")
	EndIf
EndIf

Return

/*
Funcao      : GrvLog
Parametros  : 
Retorno     : 
Objetivos   : Grava o arquivo com o conteudo passado
Autor       : Jean Victor Rocha
Data/Hora   : 18/04/2017
Obs         : 
*/                 
*----------------------------*
Static Function GrvLog(cTexto) 
*----------------------------*
Local nHandle := 0
Local cArquivo := "\documentos\lOG\LOGACESSOS.TXT"

If File(cArquivo)
	nHandle := Fopen(cArquivo,2)
Else
	nHandle := FCreate(cArquivo, 0)
EndIf
                
FSeek(nHandle,0,2)
FWRITE(nHandle, cTexto+CHR(13)+CHR(10) )
fclose(nHandle)

Return .T.