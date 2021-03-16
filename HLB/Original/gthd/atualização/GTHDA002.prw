#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include "msgraphi.ch"

#define VISUALIZAR 2
#define CHECKIN    3
#define RETORNAR   4
#define TRANSFERIR 5
#define CANCELAR   6
#define ENCERRAR   98

#define STATUS_ABERTON1 "1"
#define STATUS_CONCLUIDO "2"
#define STATUS_CANCELADO "3"
#define STATUS_ATENDIMENTO "4"
#define STATUS_RETORNO "5"
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
±±ºPrograma  ³GTHDA002  ºAutor  ³Eduardo C. Romanini º Data ³  21/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de check-in de chamados de help-desk.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grant Thornton                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Funcao      : GTHDA002
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Browse da rotina de check-in de chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 14:40
*/
*----------------------*
User Function GTHDA002()
*----------------------*
Local cAlias := "Z01"
Local aCores    := {{"Z01->Z01_PRIORI == '3'" ,"QMT_OK"   },; //Baixa
					{"Z01->Z01_PRIORI == '2'" ,"QMT_COND" },; //Média
					{"Z01->Z01_PRIORI == '1'" ,"QMT_NO"   }} //Alta

Private cTpAtend := ValLogin()
//Verifica se o usuário possui permissão para acessar a rotina.
If EMPTY(cTpAtend)
	MsgInfo("Usuário não possui permissão para acessar essa rotina.","Atenção")
	Return
EndIf

Private cCadastro  := "Help-Desk Grant Thornton"
Private cCondFil   := ""
Private cPastaAnexo:= "\DIRDOC\HD\"
Private aIndexZ01 := {}                             

Private aTpAten := &(ComboSX3("Z03_TIPO"))
Private cNivelAten := RIGHT(ALLTRIM(aTpAten[aScan(aTpAten, {|x| LEFT(x,1) == cTpAtend })]),2)

Private aRotina	  := {{ "Pesquisar"												,"PesqBrw"     , 0, 1},;
				   	  { "Visualizar"											,"U_HDA002Man" , 0, 2},;
					  { "Check-In "+cNivelAten									,"U_HDA002Man" , 0, 4},;
					  { "Retornar"												,"U_HDA002Man" , 0, 4},;
					  { "Transferir "+IIF(cNivelAten=="N1","N2","N1")			,"U_HDA002Man" , 0, 4},;
  					  { "Cancelar"												,"U_HDA002Man" , 0, 4},;
  					  { "Estatistica"											,"U_HDA002Disp", 0, 3},;
					  { "Legenda"												,"U_HDA002Leg" , 0, 6}}

Private bFiltraBrw:= {}

//Filtro para exibição dos chamados.
U_HD002Filtro(.F.,cAlias,@aIndexZ01)

DbSelectArea(cAlias)
DbSetOrder(2)

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_HD002Filtro(.T.,"Z01",@aIndexZ01)} )

//Exibe o browse.
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw(cAlias,aIndexZ01)

DbSelectArea(cAlias)

Return Nil

/*
Funcao      : HDA002Leg
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe a legenda do browse
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 17:30
*/
*-----------------------*
User Function HDA002Leg()
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
Data/Hora   : 21/07/11 14:55
*/
*------------------------*
Static Function ValLogin()
*------------------------*  
Local cRet := ""

Local cCodUsr := RetCodUsr()

Z03->(DbSetOrder(2))
If Z03->(DbSeek(xFilial("Z03")+cCodUsr)) .and. Z03->Z03_TIPO $ "L/M"
	cRet := Z03->Z03_TIPO
EndIf

Return cRet

/*
Funcao      : HDA002Filtro
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 15:20
*/
*------------------------------------------------*
User Function HD002Filtro(lExibe,cAlias,aIndexZ01)
*------------------------------------------------*
Local cCondFil := ""
Local cArea    := (cAlias)->(GetArea())

//Inicializa as variaveis de pergunta.
Pergunte("GTHD002",lExibe,"Filtro de exibição")

//Exibe apenas os chamados em aberto.
If cNivelAten == "N1"
	cCondFil := "Z01_STATUS == '"+STATUS_ABERTON1+"'"
ElseIf cNivelAten == "N2"
	cCondFil := "Z01_STATUS == '"+STATUS_ABERTON2+"'"
EndIf

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

//Vrifica se o filtro foi reformulado.                      
If lExibe
	// Deleta o filtro anterior utilizado na função FilBrowse
	EndFilBrw(cAlias,aIndexZ01)	
EndIf

//Determina o novo filtro
bFiltraBrw := {|| FilBrowse(cAlias,@aIndexZ01,@cCondFil)}

//Atualiza o MBrowse.
Eval(bFiltraBrw)

(cAlias)->(DbGoTop())

RestArea(cArea)

Return Nil   

/*
Funcao      : HDA002Man
Parametros  : cAlias: Alias da tabela
			  nReg  : Recno do registro posicionado
			  nOpc	: Posição do aRotina selecionado.
Retorno     : Nil
Objetivos   : Rotina de manutenção dos chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/07/11 15:30
*/
*---------------------------------------*
User Function HDA002Man(cAlias,nReg,nOpc)
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
Local nSaveSx8 := GetSx8Len()
Local nTamBox  := 0
Local nPosSol  := 0

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

//Define o título da janela.
If nOpc == VISUALIZAR
	cTitulo := "Visualização de chamado"
ElseIf nOpc == CHECKIN 
	cTitulo   := "Check-In "+cNivelAten+" de chamado"
	If cNivelAten == "N1"
		cTipoMov  := MOV_CHECKINN1
	ElseIf cNivelAten == "N2"
		cTipoMov  := MOV_CHECKINN2
	EndIf
	aCposEdit := {"Z01_PRIORI","Z01_CODATE","Z01_CODAT2","Z01_MODULO","Z01_OCORRE"}
ElseIf nOpc == RETORNAR
	cTitulo  := "Retorno de chamado"
	cTipoMov  := MOV_RETORNO
ElseIf nOpc == TRANSFERIR
	cTitulo  := "Transferência de Chamado"
	cTipoMov  := MOV_TRANSFERENCIA
ElseIf nOpc == CANCELAR
	cTitulo  := "Cancelamento de chamado"
	cTipoMov  := MOV_CANCELAMENTO
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

If nOpc == CHECKIN
	aAdd(aButtons,{"PCOCUBE", {|| U_HDA002Disp()}, "Consulta Disponibilidade"} )
EndIf

//Define os campos que não serão exibidos na tela.
If nOpc == VISUALIZAR
	If Z01->Z01_STATUS <> STATUS_CANCELADO .and. Z01->Z01_STATUS <> STATUS_CONCLUIDO 
		aAdd(aCposNot,"Z01_PARECE")
		aAdd(aCposNot,"Z01_KNOW")
		aAdd(aCposNot,"Z01_CLASSI")
	EndIf
Else
	aAdd(aCposNot,"Z01_PARECE")
	aAdd(aCposNot,"Z01_KNOW")
	aAdd(aCposNot,"Z01_CLASSI")
EndIf

If nOpc <> ENCERRAR
  	aAdd(aCposNot,"Z01_DT_ENC")	
	//Campos para o timesheet
	aAdd(aCposNot,"Z01_TIMESH")
	aAdd(aCposNot,"Z01_HRGAST")
	aAdd(aCposNot,"Z01_TIMEOB")	
EndIf

If cNivelAten == "N1"
	aAdd(aCposNot,"Z01_CODAT2")	
ElseIf cNivelAten == "N2"
	aAdd(aCposNot,"Z01_CODATE")	
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
	If nOpc <> VISUALIZAR
		oMGetNew := TMultiGet():New(03,03,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oScr,nDir-nEsq-5,1000,,.F.,,,,.T.)
		oMGetNew:EnableVScroll(.T.)
		
		//Adiciona o Painel criado no ToolBox	
		If nOpc == CHECKIN
			oTb:AddGroup(oMGetNew,"Check-In "+cNivelAten+":")

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
		U_GTHDW001(Z01->Z01_CODIGO,cTipoMov)
	
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
Z01->(RecLock("Z01",.F.))

For nI:=1 To Len(aCposEdit)
	Z01->&(aCposEdit[nI]) := M->&(aCposEdit[nI])
Next

//Tratamento do status do chamado	
If nOpc == CHECKIN
	Z01->Z01_STATUS := STATUS_ATENDIMENTO

ElseIf nOpc == RETORNAR
	Z01->Z01_STATUS := STATUS_RETORNO

ElseIf nOpc == ENCERRAR
	Z01->Z01_STATUS := STATUS_CONCLUIDO
	Z01->Z01_PARECE := "Solução: " + CRLF + AllTrim(cMGetNew)

	//Retorna o codigo do atendente que está logado.
	Z03->(DbSetOrder(2))
	If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
		Z01->Z01_CODATE := Z03->Z03_CODIGO	
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

ElseIf nOpc == CANCELAR
	Z01->Z01_STATUS := STATUS_CANCELADO
	Z01->Z01_PARECE := "Cancelamento: " + CRLF + AllTrim(cMGetNew)
	
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

Return Nil    

/*
Funcao      : ValChamado
Parametros  : nOpc: Opção Selecionada no MBrowse
Retorno     : Nil
Objetivos   : Valida as informações digitadas no chamado
Autor       : Eduardo C. Romanini
Data/Hora   : 14/07/11 16:00
Revisão     : Tiago Luiz Mendonça
Data/Hora   : 02/02/2013
*/
*------------------------------*
Static Function ValChamado(nOpc)
*------------------------------*
Local lRet := .T.
Local cCodAten := ""

If cNivelAten == "N1"
	cCodAten := M->Z01_CODATE
ElseIf cNivelAten == "N2"
	cCodAten := M->Z01_CODAT2
EndIf

If nOpc == VISUALIZAR
	Return .T.
EndIf

If Empty(cMGetNew)
	MsgInfo("Favor preencher a descrição da movimentação do chamado.","Atenção")
	Return .F.	
EndIf

If nOpc == CHECKIN
	If Empty(cCodAten)
		MsgInfo("Favor alocar o atendente do chamado.","Atenção")	
		Return .F.
	EndIf
EndIf 

If nOpc == CHECKIN   
	Z03->(DbSetOrder(1))
	If Z03->(DbSeek(xFilial("Z03")+cCodAten))
		If Z03->Z03_ATIVO <> "S"	
			MsgInfo("Atendente bloqueado no cadastro, favor informar outro.","Atenção")	
			Return .F.  
		EndIf	
	EndIf
EndIf


Return lRet       

/*
Funcao      : HDA002Disp
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe o painel de numeros dos chamados.
Autor       : Eduardo C. Romanini
Data/Hora   : 02/09/11 14:20
*/
*------------------------*
User Function HDA002Disp()     
*------------------------*
Local cArqTmp := ""
Local cArqTmp2 := ""
Local cArqInd := ""
Local cArqInd2 := ""
Local cMarca  := GetMark()
Local cSel := "% SELECT %"

Local nSerie    := 0
Local nTotal    := 0
Local nTotAte   := 0
Local nTotSol   := 0
Local nTotTotvs := 0
Local nTotCan   := 0
Local nTotRet   := 0

Local nTotalNvl    := 0
Local nTotAteNvl   := 0
Local nTotSolNvl   := 0
Local nTotTotvsNvl := 0
Local nTotCanNvl   := 0
Local nTotRetNvl   := 0

Local aCampos := {{"CATEND" ,"C",06,0},;
				  {"NATEND" ,"C",10,0},;
				  {"TRET"   ,"N",06,0},;
				  {"TATEN"  ,"N",06,0},;
				  {"TSOLIC" ,"N",06,0},;
				  {"TTOTVS" ,"N",06,0},;
				  {"TALOC"  ,"N",06,0},;
				  {"TOTAL"  ,"N",06,0}}

Local aCpsBrw := {{"NATEND",,"Nome"       ,"@!"},;
                  {"TATEN" ,,"Atend."     ,"@R"},;
                  {"TRET"  ,,"Retorno"    ,"@R"},;
				  {"TTOTVS",,"Totvs"      ,"@R"},;                  
				  {"TALOC" ,,"Alocado"    ,"@R"},;                  
                  {"TSOLIC",,"Soluc."     ,"@R"},;
                  {"TOTAL" ,,"Total"      ,"@R"}}

Private aColor := {}

Private oDlg
Private oPainel1
Private oPainel2
Private oPainel3
Private oBrw
Private oBrw2
Private oGraphic
Private oGraphic2

Z03->(DbSetOrder(1))
Z03->(DbGoTop())
While Z03->(!EOF())
	
	aAdd(aColor, RGB(Randomize(0,255),Randomize(0,255),Randomize(0,255)))
	
	Z03->(DbSkip())
EndDo

//Cria tabela temporária
If Select("TEMP") <> 0 
	TEMP->(DbCloseArea())
EndIf

//Cria a tabela temporaria para os resultados da pesquisa.
cArqTmp:=CriaTrab(aCampos,.T.)
dbUseArea( .T.,,cArqTmp,"TEMP",, .F. )

//Cria o indice da tabela temporaria
cArqInd := CriaTrab(,.F.)
IndRegua("TEMP",cArqInd,"NATEND",,,"Selecionando Registros...")

TEMP->(DbSetIndex(cArqInd+OrdBagExt()))

If Select('QRY') <> 0 
	QRY->(DbCloseArea())
EndIf

//Cria query para carregar a tabela temporaria.
IF cNivelAten == "N1"
	BeginSql Alias 'QRY'
		SELECT Z03_CODIGO,UPPER(Z03_NOME) [NOME],ATE.[NATEND] ,RET.[NRET],SOL.[NSOL],TOTVS.[NTOTVS],CAN.[CANC],TOT.[NTOTAL],Z03_ATIVO
		FROM %table:Z03% Z03
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[NTOTAL] FROM %table:Z01% WHERE					   %notDel% GROUP BY Z01_CODATE) TOT   ON TOT.Z01_CODATE   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[NTOTVS] FROM %table:Z01% WHERE Z01_STATUS = '6' AND %notDel% GROUP BY Z01_CODATE) TOTVS ON TOTVS.Z01_CODATE = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[NRET]   FROM %table:Z01% WHERE Z01_STATUS = '5' AND %notDel% GROUP BY Z01_CODATE) RET   ON RET.Z01_CODATE   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[NATEND] FROM %table:Z01% WHERE Z01_STATUS = '4' AND %notDel% GROUP BY Z01_CODATE) ATE   ON ATE.Z01_CODATE   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[CANC]   FROM %table:Z01% WHERE Z01_STATUS = '3' AND %notDel% GROUP BY Z01_CODATE) CAN   ON CAN.Z01_CODATE   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODATE,COUNT(Z01_CODIGO)[NSOL]   FROM %table:Z01% WHERE Z01_STATUS = '2' AND %notDel% GROUP BY Z01_CODATE) SOL   ON SOL.Z01_CODATE   = Z03_CODIGO		
		WHERE Z03.%notDel% AND Z03.Z03_TIPO in ('A','L')
		ORDER BY UPPER(Z03_NOME)
	EndSql
ElseIf cNivelAten == "N2"
	BeginSql Alias 'QRY'
		SELECT Z03_CODIGO,UPPER(Z03_NOME) [NOME],ATE.[NATEND] ,RET.[NRET],SOL.[NSOL],TOTVS.[NTOTVS],CAN.[CANC],TOT.[NTOTAL],Z03_ATIVO
		FROM %table:Z03% Z03
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[NTOTAL] FROM %table:Z01% WHERE %notDel% GROUP BY Z01_CODAT2) TOT   ON TOT.Z01_CODAT2   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[NTOTVS] FROM %table:Z01% WHERE Z01_STATUS = '6' AND %notDel% GROUP BY Z01_CODAT2) TOTVS ON TOTVS.Z01_CODAT2 = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[NRET]   FROM %table:Z01% WHERE Z01_STATUS = '5' AND %notDel% GROUP BY Z01_CODAT2) RET   ON RET.Z01_CODAT2   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[NATEND] FROM %table:Z01% WHERE Z01_STATUS = '4' AND %notDel% GROUP BY Z01_CODAT2) ATE   ON ATE.Z01_CODAT2   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[CANC]   FROM %table:Z01% WHERE Z01_STATUS = '3' AND %notDel% GROUP BY Z01_CODAT2) CAN   ON CAN.Z01_CODAT2   = Z03_CODIGO
			LEFT JOIN (SELECT Z01_CODAT2,COUNT(Z01_CODIGO)[NSOL]   FROM %table:Z01% WHERE Z01_STATUS = '2' AND %notDel% GROUP BY Z01_CODAT2) SOL   ON SOL.Z01_CODAT2   = Z03_CODIGO		
		WHERE Z03.%notDel% AND Z03.Z03_TIPO in ('B','M')
		ORDER BY UPPER(Z03_NOME)
	EndSql
EndIf 
                                               
//Adiciona o resultado na tabela temporaria.
QRY->(DbGoTop())
If QRY->(EOF())
	MsgInfo("Sem Dados para exibição!")
	Return .T.
EndIf

While QRY->(!EOF())
	If QRY->Z03_ATIVO = 'S'
		TEMP->(DbAppend())
		TEMP->CATEND := QRY->Z03_CODIGO
		TEMP->NATEND := QRY->NOME
		TEMP->TRET   := QRY->NRET
		TEMP->TATEN  := QRY->NATEND
		TEMP->TTOTVS := QRY->NTOTVS
		TEMP->TSOLIC := QRY->NSOL
		TEMP->TALOC  := QRY->NRET+QRY->NATEND+QRY->NTOTVS
		TEMP->TOTAL  := QRY->NRET+QRY->NATEND+QRY->NSOL+QRY->NTOTVS
	EndIf	
	nTotalNvl    += QRY->NTOTAL
	nTotAteNvl   += QRY->NATEND
	nTotTotvsNvl += QRY->NTOTVS
	nTotSolNvl   += QRY->NSOL
	nTotCanNvl   += QRY->CANC
	nTotRetNvl   += QRY->NRET
	
	QRY->(DbSkip())
EndDo
QRY->(DbCloseArea())

//Cria query para carregar os totais
BeginSql Alias 'TOT'
	SELECT TOP 1 
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel%) AS [TOTAL],
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel% AND Z01_STATUS = '2' ) AS [SOL],
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel% AND Z01_STATUS = '3' ) AS [CANC],
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel% AND Z01_STATUS = '4' ) AS [ATEN],
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel% AND Z01_STATUS = '5' ) AS [RET],
		(SELECT COUNT(Z01_CODIGO) FROM %table:Z01% WHERE %notDel% AND Z01_STATUS = '6' ) AS [TOTVS]
	FROM %table:Z01%
EndSql

TOT->(DbGoTop())
If TOT->(!EOF() .and. !BOF())
	nTotal    := TOT->TOTAL
	nTotAte   := TOT->ATEN
	nTotSol   := TOT->SOL
	nTotTotvs := TOT->TOTVS
	nTotCan   := TOT->CANC
	nTotRet   := TOT->RET
EndIf
TOT->(DbCloseArea())

//Tratamento de Estatistica por Atendente.
If Select("TEMP2") <> 0 //Cria tabela temporária
	TEMP2->(DbCloseArea())
EndIf

cArqTmp2:=CriaTrab(aCampos,.T.)//Cria a tabela temporaria para os resultados da pesquisa.
dbUseArea( .T.,,cArqTmp2,"TEMP2",, .F. )

cArqInd2 := CriaTrab(,.F.)//Cria o indice da tabela temporaria
IndRegua("TEMP2",cArqInd2,"NATEND",,,"Selecionando Registros...")
TEMP2->(DbSetIndex(cArqInd2+OrdBagExt()))

If Select('QRY2') <> 0 
	QRY2->(DbCloseArea())
EndIf

BeginSql Alias 'QRY2'
		SELECT Z03_CODIGO,UPPER(Z03_NOME) [NOME],ATE.[NATEND] ,RET.[NRET],SOL.[NSOL],TOTVS.[NTOTVS],CAN.[CANC],TOT.[NTOTAL],Z03_ATIVO
		FROM %table:Z03% Z03
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[NTOTAL] FROM %table:Z01% WHERE D_E_L_E_T_ <> '*'						 GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) TOT   ON TOT.[CODATE]   = Z03_CODIGO
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[NTOTVS] FROM %table:Z01% WHERE Z01_STATUS = '6' AND D_E_L_E_T_ <> '*' GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) TOTVS ON TOTVS.[CODATE] = Z03_CODIGO
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[NRET]   FROM %table:Z01% WHERE Z01_STATUS = '5' AND D_E_L_E_T_ <> '*' GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) RET   ON RET.[CODATE]   = Z03_CODIGO
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[NATEND] FROM %table:Z01% WHERE Z01_STATUS = '4' AND D_E_L_E_T_ <> '*' GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) ATE   ON ATE.[CODATE]   = Z03_CODIGO
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[CANC]   FROM %table:Z01% WHERE Z01_STATUS = '3' AND D_E_L_E_T_ <> '*' GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) CAN   ON CAN.[CODATE]   = Z03_CODIGO
			LEFT JOIN (SELECT RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2) as [CODATE],COUNT(Z01_CODIGO)[NSOL]   FROM %table:Z01% WHERE Z01_STATUS = '2' AND D_E_L_E_T_ <> '*' GROUP BY RTRIM(Z01_CODATE)+RTRIM(Z01_CODAT2)) SOL   ON SOL.[CODATE]   = Z03_CODIGO		
		WHERE Z03.%notDel% 
		ORDER BY UPPER(Z03_NOME)
	EndSql

QRY2->(DbGoTop())
If QRY2->(EOF())
	MsgInfo("Sem Dados para exibição!")
	Return .T.
EndIf
While QRY2->(!EOF())
		TEMP2->(DbAppend())
		TEMP2->CATEND := QRY2->Z03_CODIGO
		TEMP2->NATEND := QRY2->NOME
		TEMP2->TRET   := QRY2->NRET
		TEMP2->TATEN  := QRY2->NATEND
		TEMP2->TTOTVS := QRY2->NTOTVS
		TEMP2->TSOLIC := QRY2->NSOL
		TEMP2->TALOC  := QRY2->NRET+QRY2->NATEND+QRY2->NTOTVS
		TEMP2->TOTAL  := QRY2->NRET+QRY2->NATEND+QRY2->NSOL+QRY2->NTOTVS

	QRY2->(DbSkip())
EndDo
QRY2->(DbCloseArea())



//*****************************	
//* Criação da Tela principal *
//*****************************
oDlg := MSDialog():New( 061,200,628,1095,"Painel de Chamados "+cNivelAten,,,.F.,,,,,,.T.,,,.T. )

//Criação do painel com os números dos analistas
oPanel1 := TPanel():New( 004,004,,oDlg,,.F.,.F.,,,262,204,.T.,.F. )

TEMP->(DbSetOrder(1))
TEMP->(DbGoTop())
oBrw:= MsSelect():New("TEMP",,,aCpsBrw,,cMarca,{016,008,200,258},,,oPanel1)
oBrw:oBrowse:aColumns[2]:nWidth := 40
oBrw:oBrowse:aColumns[3]:nWidth := 40
oBrw:oBrowse:aColumns[4]:nWidth := 40
oBrw:oBrowse:aColumns[5]:nWidth := 50

TEMP2->(DbSetOrder(1))
TEMP2->(DbGoTop())
oBrw2:= MsSelect():New("TEMP2",,,aCpsBrw,,cMarca,{016,008,200,258},,,oPanel1)
oBrw2:oBrowse:aColumns[2]:nWidth := 40
oBrw2:oBrowse:aColumns[3]:nWidth := 40
oBrw2:oBrowse:aColumns[4]:nWidth := 40
oBrw2:oBrowse:aColumns[5]:nWidth := 50

oBrw2:OBROWSE:LVISIBLECONTROL := .F.

oBtn := TButton():New(004,210,"Area",oPanel1,{|| InverteBrw() },50,10,,,.F.,.T.,.F.,,.F.,,,.F. )           

//Criação do painel com o grafico
oPanel2 := TPanel():New( 004,268,,oDlg,,.F.,.F.,,,176,272,.T.,.F. )

// Cria o gráfico
oGraphic := TMSGraphic():New( 01,01,oPanel2,,,RGB(239,239,239),184,260)  
oGraphic:SetTitle('Atendimentos Nivel '+cNivelAten, "Data:" + dtoc(Date()), CLR_HBLUE, A_LEFTJUST, GRP_TITLE )
oGraphic:SetMargins(2,6,6,6)
oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
// Itens do Gráfico
nSerie := oGraphic:CreateSerie( GRP_PIE ) // GRP_PIE=10
nLoop := 1
TEMP->(DbGoTop())
While TEMP->(!EOF())
	TEMP->(oGraphic:Add(nSerie,TALOC,AllTrim(NATEND),aColor[nLoop]))
    nLoop++
	TEMP->(DbSkip())
EndDo

// Cria o gráfico Por Atendente
oGraphic2 := TMSGraphic():New( 01,01,oPanel2,,,RGB(239,239,239),184,260)  
oGraphic2:SetTitle('Por Atendente ', "Data:" + dtoc(Date()), CLR_HBLUE, A_LEFTJUST, GRP_TITLE )
oGraphic2:SetMargins(2,6,6,6)
oGraphic2:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)
// Itens do Gráfico
nSerie := oGraphic2:CreateSerie( GRP_PIE ) // GRP_PIE=10
nLoop := 1
TEMP2->(DbGoTop())
While TEMP2->(!EOF())
	TEMP2->(oGraphic2:Add(nSerie,TALOC,AllTrim(NATEND),aColor[nLoop]))
    nLoop++
	TEMP2->(DbSkip())
EndDo

oGraphic2:LVISIBLECONTROL := .F.

//Criação do painel com os números totais dos chamados.
oPanel3 := TPanel():New( 212,004,,oDlg,,.F.,.F.,,,262,064,.T.,.F. )
oFont:= TFont():New(,,-14,,.T.)
oSTTot := TSay():New(004,094,{|| "Total Geral / Total "+cNivelAten},oPanel3,,oFont,,,,.T.,CLR_BLUE)
oSTTot := TSay():New(012,004,{|| "Chamados:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotal := STRZERO(nTotal,8)+" / "+STRZERO(nTotalNvl,8)
oSNTot := TSay():New(012,100,{|| cTotal},oPanel3,,oFont,,,,.T.)
oSTAte  := TSay():New(020,004,{|| "Em Atendimento:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotAte := STRZERO(nTotAte,8)+" / "+STRZERO(nTotAteNvl,8)
oSNAte  := TSay():New(020,100,{|| cTotAte},oPanel3,,oFont,,,,.T.)
oSTTotvs := TSay():New(028,004,{|| "Com a Totvs:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotTotvs:= STRZERO(nTotTotvs,8)+" / "+STRZERO(nTotTotvsNvl,8)
oSNTotvs := TSay():New(028,100,{|| cTotTotvs},oPanel3,,oFont,,,,.T.)
oSTSol := TSay():New(036,004,{|| "Solucionado:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotSol := STRZERO(nTotSol,8)+" / "+STRZERO(nTotSolNvl,8)
oSNSol := TSay():New(036,100,{|| cTotSol},oPanel3,,oFont,,,,.T.)
oSTSol := TSay():New(044,004,{|| "Cancelado:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotCan := STRZERO(nTotCan,8)+" / "+STRZERO(nTotCanNvl,8)
oSNSol := TSay():New(044,100,{|| cTotCan},oPanel3,,oFont,,,,.T.)
oSTSol := TSay():New(052,004,{|| "Com o usuário:"},oPanel3,,oFont,,,,.T.,CLR_RED)
cTotRet := STRZERO(nTotRet,8)+" / "+STRZERO(nTotRetNvl,8)
oSNSol := TSay():New(052,100,{|| cTotRet},oPanel3,,oFont,,,,.T.)

TEMP->(DbGoTop())
TEMP2->(DbGoTop())

oDlg:Activate(,,,.T.)

//Apaga os arquivos utilizados.
FErase(cArqTmp+GetDBExtension())
FErase(cArqInd+OrdBagExt())

Return Nil

/*
Funcao      : InverteBrw
Parametros  : Nenhum
Retorno     : Nil
Objetivos   :
Autor       : Jean Victor Rocha
Data/Hora   : 20/02/2014
*/
*--------------------------*
Static Function InverteBrw()        
*--------------------------*

oBrw:OBROWSE:LVISIBLECONTROL	:= oBrw2:OBROWSE:LVISIBLECONTROL
oBrw2:OBROWSE:LVISIBLECONTROL	:= !oBrw2:OBROWSE:LVISIBLECONTROL
oGraphic2:LVISIBLECONTROL 		:= oBrw2:OBROWSE:LVISIBLECONTROL
If oBtn:CTITLE == "Area"
	oBtn:CTITLE := "Atendente"
Else
	oBtn:CTITLE := "Area"
EndIf

Return .T.

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