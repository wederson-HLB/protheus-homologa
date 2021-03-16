#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"

#define VISUALIZAR 2
#define COMPLEMENTAR  3
#define RETORNAR   4
#define ENCERRAR   5
#define CANCELAR   6
#define ASSUMIR    7
#define PRIORIZAR  8
#define TRANSFERIR 9

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
#define MOV_TRANSFERENCIA "X"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTHDA003  ºAutor  ³Eduardo C. Romanini º Data ³  21/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de atendimento de chamados de help-desk.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                
/*
Funcao      : GTHDA003
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Browse da rotina de atendimento de chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 17:00
*/
*----------------------*
User Function GTHDA003()
*----------------------*
Local cAlias := "Z01"

Local aCores    := {{"Z01->Z01_PRIORI == '3'" ,"QMT_OK"   },; //Baixa
					{"Z01->Z01_PRIORI == '2'" ,"QMT_COND" },; //Média
					{"Z01->Z01_PRIORI == '1'" ,"QMT_NO"   }} //Alta

Private cCadastro  := "Help-Desk Grant Thornton"
Private cCondFil   := ""
Private cPastaAnexo:= "\DIRDOC\HD\"

Private aIndexZ01 := {}
Private aRotina	  := {{ "Pesquisar"    ,"PesqBrw"    , 0, 1},;
				   	  { "Visualizar"   ,"U_HDA003Man", 0, 2},;
  					  { "Complementar" ,"U_HDA003Man", 0, 4},;
					  { "Retornar"     ,"U_HDA003Man", 0, 4},;
					  { "Encerrar"     ,"U_HDA003Man", 0, 4},;
  					  { "Cancelar"     ,"U_HDA003Man", 0, 4},;
  					  { "Assumir"      ,"U_HDA003Man", 0, 4},;
  					  { "Priorizar"    ,"U_HDA003Man", 0, 4},;
  					  { "Transferir"   ,"U_HDA003Man", 0, 4},;
  					  { "Enviar Email" ,"U_HDE001Env" , 0, 6},;
					  { "Legenda"      ,"U_HDA003Leg", 0, 6}}

Private bFiltraBrw:= {}

//Verifica se o usuário possui permissão para acessar a rotina.
Private cTpAtend := ValLogin()

If EMPTY(cTpAtend)
	MsgInfo("Usuário não possui permissão para acessar essa rotina.","Atenção")
	Return
EndIf

Private aTpAten		:= &(ComboSX3("Z03_TIPO"))
Private cNivelAten	:= RIGHT(ALLTRIM(aTpAten[aScan(aTpAten, {|x| LEFT(x,1) == cTpAtend })]),2)

//Filtro para exibição dos chamados.
U_HD003Filtro(.F.,cAlias,@aIndexZ01)

DbSelectArea(cAlias)
DbSetOrder(2)

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_HD003Filtro(.T.,"Z01",@aIndexZ01)} )

aFixes := {}
SX3->(DbSetOrder(1))
SX3->(DbSeek("Z01"))
While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "Z01"
	If SX3->X3_BROWSE == "S"
		If SX3->X3_CAMPO == "Z01_CODATE" .or. SX3->X3_CAMPO == "Z01_CODAT2"
			
			If cNivelAten == "N1" .and. SX3->X3_CAMPO == "Z01_CODATE"
				aAdd(aFixes,{SX3->X3_TITULO,SX3->X3_CAMPO})
			ElseIf cNivelAten == "N2" .and. SX3->X3_CAMPO == "Z01_CODAT2"
				aAdd(aFixes,{SX3->X3_TITULO,SX3->X3_CAMPO})
			EndIf 
			
		Else
			aAdd(aFixes,{SX3->X3_TITULO,SX3->X3_CAMPO})
		EndIf
	EndIf
	SX3->(DbSkip())	
EndDo

//Exibe o browse.
mBrowse( 6,1,22,75,cAlias,aFixes,,,,,aCores)

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw(cAlias,aIndexZ01)

DbSelectArea(cAlias)

Return Nil

/*
Funcao      : HDA003Leg
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe a legenda do browse
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 17:00
*/
*-----------------------*
User Function HDA003Leg()
*-----------------------*
Local aLegenda := {	{"QMT_NO"  ,". Prioridade Alta" },;
					{""  ,"" },;
					{"QMT_COND",". Prioridade Média"},;
					{""  ,"" },;
					{"QMT_OK"  ,". Prioridade Baixa"},;
					{""  ,"" } }

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil
                        
/*
Funcao      : ValLogin
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Verifica se o usuário logado possui permissão
			  para acessar a rotina.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 17:00
*/
*------------------------*
Static Function ValLogin()
*------------------------*  
Local cRet := ""

Local cCodUsr := RetCodUsr()

Z03->(DbSetOrder(2))
If Z03->(DbSeek(xFilial("Z03")+cCodUsr))
	cRet := Z03->Z03_TIPO
EndIf

Return cRet

/*
Funcao      : HDA003Filtro
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 17:00
*/
*------------------------------------------------*
User Function HD003Filtro(lExibe,cAlias,aIndexZ01)
*------------------------------------------------*
Local cCondFil := ""
Local cCodUsr  := ""
Local cArea    := (cAlias)->(GetArea())

Z03->(DbSetOrder(2))
If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
	cCodUsr := Z03->Z03_CODIGO
EndIf

//Inicializa as variaveis de pergunta.
Pergunte("GTHD003",lExibe,"Filtro de exibição")

//Exibe apenas os chamados em aberto ou atendimento.
cCondFil += "(Z01_STATUS == '"+STATUS_ATENDIMENTO+"' .OR. Z01_STATUS == '"+STATUS_TOTVS+"')"

//Exibe apenas os chamados do usuário logado.
cCondFil += " .AND. "
cCondFil += " (Z01_CODATE == '"+cCodUsr+"' "
If mv_par07 <> 2
	If cNivelAten == "N1"
		cCondFil += " .OR. Z01_CODATE <> ''"
	ElseIf cNivelAten == "N2"
		cCondFil += " .OR. Z01_CODAT2 <> ''"
	EndIf
EndIf
cCondFil += " .OR. Z01_CODAT2 == '"+cCodUsr+"')"

//Filtro de data de abertura do chamado.
cCondFil += " .AND. "
cCondFil += "DtoS(Z01_DTABER) >= '" +DtoS(mv_par01)+"'" //Data Inicial
If !EMPTY(mv_par02)
	cCondFil += " .AND. "
	cCondFil += "DtoS(Z01_DTABER) <= '" +DtoS(mv_par02)+"'" //Data Final
EndIf

//Filtro de codigo da empresa
cCondFil += " .AND. "
cCondFil += "Z01_CODEMP >= '" +mv_par03+"'" //Empresa De:
If !EMPTY(mv_par04)
	cCondFil += " .AND. "
	cCondFil += "Z01_CODEMP <= '" +mv_par04+"'" //Empresa Ate:
EndIf
//Filtro de filial da empresa
cCondFil += " .AND. "
cCondFil += "Z01_FILEMP >= '" +mv_par05+"'" //Empresa De:
If !EMPTY(mv_par06)
	cCondFil += " .AND. "
	cCondFil += "Z01_FILEMP <= '" +mv_par06+"'" //Empresa Ate:
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

RestArea(cArea)

(cAlias)->(DbGoTop())

Return Nil   

/*
Funcao      : HDA003Man
Parametros  : cAlias: Alias da tabela
			  nReg  : Recno do registro posicionado
			  nOpc	: Posição do aRotina selecionado.
Retorno     : Nil
Objetivos   : Rotina de manutenção dos chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 13:10
*/
*---------------------------------------*
User Function HDA003Man(cAlias,nReg,nOpc)
*---------------------------------------*
Local cTitulo   := ""
Local cAuxGet   := ""
Local cAuxPanel := ""
Local cTitPanel := ""

Local nSup     := 0
Local nEsq     := 0
Local nDir     := 0
Local nInf     := 0
Local nInc     := 0
Local nOpcA    := 0
Local nTamBox  := 0
Local nSaveSx8 := GetSx8Len()

Local aSizeAut  := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aCpos	    := {}
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

Private cMGetNew   := ""
Private cItemZ02   := ""	
Private cDesTpMov  := ""
Private cTipoMov   := ""

Private aAnexos   := {}
Private aCposEdit := {}

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
ElseIf nOpc == RETORNAR
	cTitulo  := "Retorno de chamado"
	cTipoMov  := MOV_RETORNO
ElseIf nOpc == ENCERRAR
	cTitulo  := "Encerramento de chamado"
	cTipoMov  := MOV_SOLUCAO
ElseIf nOpc == CANCELAR
	cTitulo  := "Cancelamento de chamado"
	cTipoMov  := MOV_CANCELAMENTO
ElseIf nOpc == ASSUMIR
	cTitulo  := "Assumindo o chamado"
ElseIf nOpc == PRIORIZAR
	cTitulo  := "Priorizar o chamado"
ElseIf nOpc == TRANSFERIR
	cTitulo  := "Transferência de Chamado"
	cTipoMov  := MOV_TRANSFERENCIA
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
If nOpc <> CANCELAR .and. nOpc <> ASSUMIR .and. nOpc <> PRIORIZAR
	aAdd(aButtons,{"BONUS", {|| U_HDA001Anexo(nOpc)}, "Anexar Arquivo"} )
EndIf

//Define os campos que não serão exibidos na tela.
If nOpc == VISUALIZAR .or. nOpc <> ASSUMIR
	If Z01->Z01_STATUS <> STATUS_CANCELADO .and. Z01->Z01_STATUS <> STATUS_CONCLUIDO 
		aAdd(aCposNot,"Z01_PARECE")
		aAdd(aCposNot,"Z01_CLASSI")
		aAdd(aCposNot,"Z01_KNOW")
	EndIf
Else
	aAdd(aCposNot,"Z01_PARECE")
	aAdd(aCposNot,"Z01_CLASSI")
	aAdd(aCposNot,"Z01_KNOW")
EndIf

If nOpc <> ENCERRAR
	aAdd(aCposNot,"Z01_DT_ENC")
	//Campos para o TimeSheet
	aAdd(aCposNot,"Z01_TIMESH")
	aAdd(aCposNot,"Z01_HRGAST")
	aAdd(aCposNot,"Z01_TIMEOB")	

Else
	//Tipo da solicitação externa
	If Z01->Z01_TPSOLI == "E" 
		aAdd(aCposEdit,"Z01_TIMESH")
		aAdd(aCposEdit,"Z01_HRGAST")
		aAdd(aCposEdit,"Z01_TIMEOB")	
	EndIf

EndIf

If cNivelAten == "N1"
	aAdd(aCposNot,"Z01_CODAT2")	
ElseIf cNivelAten == "N2"
	aAdd(aCposNot,"Z01_CODATE")	
EndIf

//Campos de chamado da Totvs que sempre podem ser editados.
aAdd(aCposEdit,"Z01_CTOTVS")
aAdd(aCposEdit,"Z01_STOTVS")
aAdd(aCposEdit,"Z01_DTOTVS")	

If nOpc == PRIORIZAR
	aCposEdit := {}
	aAdd(aCposEdit,"Z01_PRIORI")
EndIf

If nOpc == TRANSFERIR
	aCposEdit := {}
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
RegToMemory(cAlias,.F.)

//Carrega as variaveis de texto das movimentações do chamado (itens)
Z02->(DbSetOrder(1))
If Z02->(DbSeek(xFilial("Z02")+M->Z01_CODIGO))
	While Z02->(!EOF()) .and. Z02->(Z02_FILIAL+Z02_CODIGO) == xFilial("Z02")+M->Z01_CODIGO
	    //Carrega as informações de item
	    Z02->(aAdd(aQtdItem,{Z02_ITEM,Z02_TIPO,Z02_DESCRI,Z02_CODUSR,Z02_DATA,Z02_HORA}))
        
		//Carrega os anexos
		If !Empty(Z02->Z02_ARQUIV)
			Z02->(aAdd(aAnexos,{Z02_ITEM,Z02_TIPO,Z02_DATA,Z02_HORA,Z02_ARQUIV}))
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
	If nOpc <> VISUALIZAR .and.  nOpc <> ASSUMIR .and. nopc <> PRIORIZAR
		oMGetNew := TMultiGet():New(03,03,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oScr,nDir-nEsq-5,1000,,.F.,,,,.T.)
		oMGetNew:EnableVScroll(.T.)
		
		//Adiciona o Painel criado no ToolBox	
		If nOpc == COMPLEMENTAR
			oTb:AddGroup(oMGetNew,"Complemento:")
		
		ElseIf nOpc == RETORNAR
			oTb:AddGroup(oMGetNew,"Retorno ao Solicitante:")		

		ElseIf nOpc == ENCERRAR
			oTb:AddGroup(oMGetNew,"Solução:")		

		ElseIf nOpc == CANCELAR
			oTb:AddGroup(oMGetNew,"Cancelamento:")

		ElseIf nOpc == TRANSFERIR
			oTb:AddGroup(oMGetNew,"Transferência:")

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
	
		//Envio do e-mail
		If nOpc <> ASSUMIR .and. nOpc <> PRIORIZAR
			U_GTHDW001(Z01->Z01_CODIGO,cTipoMov)
		EndIf
		Z01->(DbSetOrder(2))	
		
	Else
		While (GetSx8Len() > nSaveSx8 )
			RollBackSX8()
		EndDo
	EndIf
EndIf
	
Return

/*
Funcao      : GrvChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Gravar o chamado
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 16:10
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

Local nAt := 0
Local nP  := 0    
Local nI  := 0

If nopc == PRIORIZAR
	Z01->(RecLock("Z01",.F.))
	Z01->Z01_PRIORI := M->Z01_PRIORI
	Z01->(MsUnlock())     

ElseIf nOpc == ASSUMIR//Operação de assumir o chamado

	If (cNivelAten == "N1" .and. !EMPTY(Z01->Z01_CODAT2) ) .or.;
		(cNivelAten == "N2" .and. !EMPTY(Z01->Z01_CODATE) )
		MsgInfo("Ativado a Transferencia de nivel para o proprio atendente! "+IIF(cNivelAten="N1","N2","N1")+" -> "+IIF(cNivelAten="N1","N1","N2")+" ","Atenção")
	
	EndIf
	
	//Retorna o codigo do atendente que está logado.	
	Z03->(DbSetOrder(2))
	If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
		Z01->(RecLock("Z01",.F.))
		If cNivelAten == "N1"
			Z01->Z01_CODATE := Z03->Z03_CODIGO	
			Z01->Z01_CODAT2 := ""
		ElseIf cNivelAten == "N2"
	 		Z01->Z01_CODAT2 := Z03->Z03_CODIGO	
	 		Z01->Z01_CODATE := ""
		EndIf	

		Z01->(MsUnlock())
	EndIf

//Demais Operações
Else	
	//Monta o diretório principal
	If Right(cPastaAnexo,1) <> "\"
	    cPastaAnexo += "\" 
	EndIf
	
	If !ExistDir(cPastaAnexo)
		If !MontaDir(cPastaAnexo)
			MsgInfo("Não foi possivel criar o diretório principal de gravação de anexos","Atenção")
		Endif
	EndIf

	If nOpc == COMPLEMENTAR
		//Tratamento de descrição na vinculação de chamado da Totvs.
		If !Empty(M->Z01_CTOTVS)
			//Verifica se está preenchendo o chamado,
			If Empty(Z01->Z01_CTOTVS)
				If Empty(cMGetNew)
					cMGetNew := "Vinculação do chamado TOTVS de código: " + AllTrim(M->Z01_CTOTVS)
					If !Empty(M->Z01_DTOTVS)
						cMGetNew += " com data de previsão: " + DtoC(M->Z01_DTOTVS)
					EndIf
    			EndIf    	
			Else
				If AllTrim(Z01->Z01_STOTVS) <> AllTrim(M->Z01_STOTVS)
					If Empty(cMGetNew)
						cMGetNew := "Alteração no status do chamado TOTVS de: " + GetCBox(Z01->Z01_STOTVS,"Z01_STOTVS")
						cMGetNew += " para: " + GetCBox(M->Z01_STOTVS,"Z01_STOTVS")
					EndIf
				EndIf				
			EndIf
		EndIf
    EndIf
	
	//Gravação da tabela de capa do chamado
	Z01->(RecLock("Z01",.F.))
	
	For nI:=1 To Len(aCposEdit)
		Z01->&(aCposEdit[nI]) := M->&(aCposEdit[nI])
	Next
	
	//Tratamento do status do chamado	
	If nOpc == RETORNAR
		Z01->Z01_STATUS := STATUS_RETORNO
	
	ElseIf nOpc == ENCERRAR
		Z01->Z01_STATUS := STATUS_CONCLUIDO
		Z01->Z01_PARECE := "Solução: " + CRLF + AllTrim(cMGetNew)
		
		Z01->Z01_DT_ENC  := dDataBase
		Z01->Z01_CLASSIF := M->Z01_CLASSIF
		Z01->Z01_KNOW	 := M->Z01_KNOW
	
		If Z01->Z01_TIMESH == "1" 
			U_GTHDTSH(Z01->Z01_CODIGO)
		EndIf
		
		//Na solução do chamado, altera o status do chamado Totvs para Encerrado.
		If !Empty(M->Z01_CTOTVS) .and. AllTrim(M->Z01_STOTVS) <> "E"
        	Z01->Z01_STOTVS := "E" //Encerrado
		EndIf
		
	ElseIf nOpc == CANCELAR
		Z01->Z01_STATUS := STATUS_CANCELADO
		Z01->Z01_PARECE := "Cancelamento: " + CRLF + AllTrim(cMGetNew)

	ElseIf nOpc == COMPLEMENTAR
		//Verifica se o chamado está pendente para a Totvs.
		If !Empty(M->Z01_CTOTVS) 
		
			If AllTrim(M->Z01_STOTVS) = "T"
				Z01->Z01_STATUS := STATUS_TOTVS
			Else
				Z01->Z01_STATUS := STATUS_ATENDIMENTO
			EndIf
		EndIf

	ElseIf nOpc == TRANSFERIR                
		If cNivelAten == "N1"//Transferencia para N2
			Z01->Z01_CODAT2 := GetLastAtend("N2")//Retorna o Codigo do Ultimo atendente Valido e Ativo no chamado.
			Z01->Z01_CODATE := ""
			If EMPTY(Z01->Z01_CODAT2)
				Z01->Z01_STATUS := STATUS_ABERTON2
			Else
				Z01->Z01_STATUS := STATUS_ATENDIMENTO
			EndIf
		ElseIf cNivelAten == "N2"//ransferencia para N1.
			Z01->Z01_CODATE := GetLastAtend("N1")//Retorna o Codigo do Ultimo atendente Valido e Ativo no chamado.
			Z01->Z01_CODAT2 := ""
			If EMPTY(Z01->Z01_CODATE)
				Z01->Z01_STATUS := STATUS_ABERTON1
			Else
				Z01->Z01_STATUS := STATUS_ATENDIMENTO
			EndIf
		EndIf
	
	EndIf
		
	Z01->(MsUnlock())
		
	//Gravação da movimentação (itens) do chamado
	Z02->(RecLock("Z02",.T.))
	
	Z02->Z02_FILIAL := xFilial("Z02")
	Z02->Z02_CODIGO := M->Z01_CODIGO
	Z02->Z02_ITEM   := cItemZ02
	Z02->Z02_DATA   := dDataBase
	Z02->Z02_HORA   := Time()
	Z02->Z02_CODUSR := RetCodUsr()
	Z02->Z02_TIPO   := cTipoMov
	Z02->Z02_DESCRI := AllTrim(cMGetNew)
	
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

If nOpc == VISUALIZAR .or. nOpc == PRIORIZAR 
	Return .T.
EndIf
   
If nOpc == ASSUMIR
	If !MsgYesNo("Você está assumindo o chamado "+cNivelAten+", confirma?","Atenção")
		Return .F.
    EndIf
Else
	//Posiciona o registro
	If Z01->Z01_CODIGO <> M->Z01_CODIGO
		Z01->(DbSetOrder(1))
		Z01->(DbSeek(xFilial("Z01")+M->Z01_CODIGO))	
	EndIf	

	If !(nOpc == COMPLEMENTAR .and. (!Empty(M->Z01_CTOTVS) .and. Empty(Z01->Z01_CTOTVS)) .or. ;
	    (AllTrim(M->Z01_STOTVS) <> AllTrim(Z01->Z01_STOTVS))) .or.;
	    nOpc == TRANSFERIR

		If Empty(cMGetNew)
			MsgInfo("Favor preencher a descrição da movimentação do chamado.","Atenção")
			Return .F.	
		EndIf
	EndIf
	
	//Checa se é externo e encerrado.
	If Z01->Z01_TPSOLI == "E" .And. nOpc == ENCERRAR
		If Empty(M->Z01_TIMESH)
			MsgInfo("Preencher os dados do TimeSheet : SIM/NAO .","Atenção")
			Return .F. 
	    EndIf
	EndIf  
	
	//Lançamento timesheet SIM
	If M->Z01_TIMESH == "1"   
	 	//Checa horas gastas
		If Empty(M->Z01_HRGAST)
			MsgInfo("Preencher os dados do TimeSheet:  Hora/Minuto .","Atenção")
			Return .F.
		EndIf  

		//Checa Obs informada
		If Empty(M->Z01_TIMEOB)
			MsgInfo("Favor preencher a descrição do trabalho realizado para o TimeSheet .","Atenção")
			Return .F.
		EndIf                      
	Else      
		//Valida o conteúdo do campo hora/minuto
		If !Empty(M->Z01_HRGAST)
			MsgInfo("Hora/Minutos deve ser em branco para TimeSheet - Não.","Atenção")
			Return .F.	     
		EndIf
	EndIf
    
	//Tratamento para classificação do chamado.
	If nOpc == ENCERRAR
		If !TelaClass()
			Return.F.
		EndIf		
	EndIf	

	//Tratamento dos campos de chamado da Totvs
	If !Empty(M->Z01_CTOTVS)
		If Len(M->Z01_CTOTVS) < 6 
			MsgInfo("O chamado da Totvs deve possuir no minimo 6 caracteres.","Atenção")
			Return .F.		
		EndIf

	    If Empty(M->Z01_STOTVS)
			MsgInfo("Informe o Status do chamado da Totvs.","Atenção")
			Return .F.    
	    EndIf
				
	EndIf
EndIf
	
Return lRet            

/*
Funcao      : PreVldChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Valida as informações do chamado para exibir a tela de movimentação
Autor       : Eduardo C. Romanini
Data/Hora   : 05/08/11 15:20
*/
*---------------------------------*
Static Function PreVldChamado(nOpc)
*---------------------------------*
Local lRet := .T.

If nOpc == ASSUMIR
	//Verifica se o usuário já é o atendente.
	Z03->(DbSetOrder(2))
	If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
		If cNivelAten == "N1" .and. Z01->Z01_CODATE == Z03->Z03_CODIGO// .and. Z01->Z01_CODAT2 <> Z03->Z03_CODIGO
			MsgInfo("Você já é o atendente do chamado "+cNivelAten+".","Atenção")
			Return .F.
		ElseIf cNivelAten == "N2" .and. Z01->Z01_CODAT2 == Z03->Z03_CODIGO// .and. Z01->Z01_CODATE <> Z03->Z03_CODIGO
			MsgInfo("Você já é o atendente do chamado "+cNivelAten+".","Atenção")
			Return .F.

        //Tratamento caso seja nivel Diferente e não esteja com o proprio atendente.
		ElseIf cNivelAten == "N2" .and. !EMPTY(Z01->Z01_CODATE) .and. Z01->Z01_CODATE <> Z03->Z03_CODIGO     
			MsgInfo("Essa operação só pode ser realizada por atendente do "+IIF(cNivelAten="N2","N1","N2")+".","Atenção")
			Return .F.

		ElseIf cNivelAten == "N1" .and. !EMPTY(Z01->Z01_CODAT2) .and. Z01->Z01_CODAT2 <> Z03->Z03_CODIGO
			MsgInfo("Essa operação só pode ser realizada por atendente do "+IIF(cNivelAten="N1","N2","N1")+".","Atenção")
			Return .F.
			
		EndIf
	EndIf

ElseIf nOpc <> VISUALIZAR
	//Verifica se o usuário é o atendente do chamado.
	Z03->(DbSetOrder(2))
	If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
		If cNivelAten == "N1" .and. Z01->Z01_CODATE <> Z03->Z03_CODIGO .And. Z01->Z01_CODAT2 <> Z03->Z03_CODIGO
			MsgInfo("Essa operação só pode ser realizada pelo atendente do chamado ou esta no "+IIF(cNivelAten="N1","N2","N1")+".","Atenção")
			Return .F.
		ElseIf cNivelAten == "N2" .and. Z01->Z01_CODAT2 <> Z03->Z03_CODIGO .and. Z01->Z01_CODATE <> Z03->Z03_CODIGO
			MsgInfo("Essa operação só pode ser realizada pelo atendente do chamado ou esta no "+IIF(cNivelAten="N1","N2","N1")+".","Atenção")
			Return .F. 
		EndIf
	EndIf
EndIf

Return lRet                   

/*
Funcao      : GetCbox
Objetivos   : Retorna a descrição da opção selecionada em um campo do tipo Combo Box.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/01/12 13:50
*/
*------------------------------------*
Static Function GetCbox(cValor,cCampo)
*------------------------------------*
Local cRet  := ""
Local cCbox := ""
Local cAux  := ""

Local nAt  := 0
Local nPos := 0
Local aAux := {}

SX3->(DbSetOrder(2))
If SX3->(DbSeek(cCampo))
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
		
nPos := aScan(aAux,{|a| a[1]==cValor})					
If nPos > 0
	cRet:=aAux[nPos][2]
EndIf

Return cRet

/*
Funcao      : TelaClass
Objetivos   : Exibe tela de classificação do chamado pelo analista.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/01/12 15:05
*/
*-------------------------*
Static Function TelaClass()
*-------------------------*
Local lRet := .F.

Local cGetUsr  := ""
Local cCbox    := ""
Local cAux     := ""
Local cClassif := Space(2)

Local nAt  := 0
Local nPos := 0

Local aButtons := {}
Local aOpcao   := {}

Local bOk     := {|| If(!Empty(cClassif) .and. !Empty(cMGetNew),(lRet:=.T.,oDlg:End()),MsgInfo("Campos obrigatorios não preenchidos!","Atenção"))}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oGrp
Local oSay1,oSay2,oSay3
Local oGetUsr
Local oGetCla

Private cMGetNew := ""

//Retorna a descrição da opção selecionada pelo usuário.
cGetUsr := Tabela("Z1",M->Z01_OCORRE)

//Cria a tela de seleção
oDlg := MSDialog():New( 091,232,550,572,"Classificação / Banco de conhecimento",,,.F.,,,,,,.T.,,,.T. )
oDlg:bInit := {||EnchoiceBar(oDlg,bOk,bCancel,,aButtons)}

oGrp := TGroup():New( 016,004,068,164,"",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay1 := TSay():New( 024,008,{||"Classifique o chamado de acordo com a solução."},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)

oSay2   := TSay():New( 040,008,{||"Selecionado pelo Usuário:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,008)
oGetUsr := TGet():New( 040,084,{|| cGetUsr},oGrp,074,008,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"",cGetUsr)

oSay3   := TSay():New( 052,008,{||"Selecionado pelo Analista:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oGetCla := TGet():New( 052,084,{|u| if( Pcount()>0, cClassif:= u,cClassif )},oGrp,064,008,,{|| ExistCpo("SX5","Z3"+cClassif)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,cClassif)
oGetCla:cF3 := "Z3"

oGrp2 := TGroup():New( 072,004,226,164,"",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay5 := TSay():New( 076,008,{||"Informe o parecer Técnico de solução desse chamado."},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)

oMManGetNew := TMultiGet():New(088,008,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oGrp2,152,132,,.F.,,,,.T.,,,,,,.F.)
oMManGetNew:EnableVScroll(.T.)

oDlg:Activate(,,,.T.)

//Gravação do campo de classificação
If lRet
	M->Z01_CLASSI	:= cClassif
	M->Z01_KNOW		:= cMGetNew
EndIf

Return lRet    

/*
Funcao      : GetLastAtend
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retorna o Ultimo atendente ativo do chamado no nivel passado via parametro.
Autor       :
Data/Hora   :
*/
*----------------------------------*
Static Function GetLastAtend(cNivel)
*----------------------------------*
Local cCodAten := ""

If Select('QRY') <> 0 
	QRY->(DbCloseArea())
EndIf

cMOV_TRANS := MOV_TRANSFERENCIA 
cMOV_N1 := MOV_CHECKINN1 
cMOV_N2 := MOV_CHECKINN2 

If cNivel == "N1"
	BeginSql Alias 'QRY'
		Select Top 1 Z03.Z03_CODIGO
		From %table:Z02% Z02
			Left Join (Select * From %table:Z03% Where %notDel% AND Z03_ATIVO = 'S' AND Z03_TIPO in ('A','L')) as Z03 on Z03.Z03_ID_PSS = Z02.Z02_CODUSR
		Where Z02.%notDel%
			AND Z03.Z03_CODIGO <> %exp:''%
			AND Z02.Z02_CODIGO = %exp:M->Z01_CODIGO%
			AND Z02.Z02_TIPO <> %exp:cMOV_TRANS%
			AND Z02.Z02_TIPO <> %exp:cMOV_N1%
			AND Z02.Z02_TIPO <> %exp:cMOV_N2%
		order by Z02.Z02_ITEM desc
	EndSql

ElseIf cNivel == "N2"
	BeginSql Alias 'QRY'
		Select Top 1 Z03.Z03_CODIGO
		From %table:Z02% Z02
			Left Join (Select * From %table:Z03% Where %notDel% AND Z03_ATIVO = 'S' AND Z03_TIPO in ('B','M')) as Z03 on Z03.Z03_ID_PSS = Z02.Z02_CODUSR
		Where Z02.%notDel%
			AND Z03.Z03_CODIGO <> %exp:''%
			AND Z02.Z02_CODIGO = %exp:M->Z01_CODIGO% 
			AND Z02.Z02_TIPO <> %exp:cMOV_TRANS%
			AND Z02.Z02_TIPO <> %exp:cMOV_N1%
			AND Z02.Z02_TIPO <> %exp:cMOV_N2%
		order by Z02.Z02_ITEM desc
	EndSql

EndIf


QRY->(DbGoTop())
If QRY->(!EOF())
	cCodAten := QRY->Z03_CODIGO
EndIf

Return cCodAten

/*
Funcao      : ComboSX3
Parametros  : Nenhum
Retorno     : Nil
Objetivos   :
Autor       :
Data/Hora   :
*/
*----------------------------------*
Static Function ComboSX3(cCampo)
*----------------------------------*
Local cRet,cAux,nPos 
cRet:='{"","'

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))
   cAux:=SX3->X3_CBOX
Else
  cRet+='"}' 
EndIf     

nPos:=At(";",Alltrim(cAux))
While 0 < nPos                          
   cRet+=substr(cAux,1,nPos-1)+'"' 
   cAux:=substr(cAux,nPos+1,Len(cAux))                                     
   nPos:=At(";",Alltrim(cAux)) 
   If nPos>0 
      cRet+=',"'
   Else
      cRet+=',"'+Alltrim(cAux)+'"}'
   EndIf  
EndDo 

Return cRet