#INCLUDE "FINA130.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"   
 
#define ENTER CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinA130  ³ Autor ³ Wagner Xavier         ³ Data ³ 23/06/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualiza‡„o de Bancos - CNAB                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinA130()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UFinA130()

Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario

//Mensagem única
Private Inclui //Utilizo no adapter MATI070 quando for inclusão
Private Altera //Utilizo no adapter MATI070 quando for alteração
Private Exclui //Utilizo no adapter MATI070 quando for exclusão
Private aRotina := MenuDef()
PRIVATE cCadastro := OemtoAnsi(STR0009)  // "Atualiza Parƒmetros de Bancos-CNAB"

IF !U_GTFIN039(3,'')
    RETURN .F.
ENDIF

//VERIFICAR SE EXISTE O LAYOUT DA FEBRABAN NO SYSTEM, CASO CONTRARIO DEVE CHAMAR UMA FUNÇÃO PARA CRIAR ESSE ARQUIVO.
IF !FILE("FEBRABAN.2PE") .OR. !FILE("FEBRABAN.2RE") .OR. !FILE("FEBRABAN.2PR") .OR. !FILE("FEBRABAN.2RR")
    MsgAlert("Arquivos de layout não foram encontrados no driver e na pasta, e serão criados!")
    U_GTFIN038(4,'')//FUNÇÃO PARA CRIAR OS ARQUIVOS DE LAYOUT QUE NÃO EXISTIREM.
ENDIF

U_GTFIN038(9,'')//FUNÇÃO PARA CADASTRAR OS MODELOS DE BORDERO FALTANTES.

IF !TABDIR("SEE","","")
	RETURN
ENDIF

mBrowse( 6, 1,22,75,"SEE")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados		      ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aArea		:= GetArea()
PRIVATE aRotina := {{OemToAnsi(STR0004),"AxPesqui"	, 0 , 1,,.F.},;	// "Pesquisar"
					{OemToAnsi(STR0005),"AxVisual"	, 0 , 2},;		// "Visualizar"
					{OemToAnsi(STR0006),"U_FAINC130"	, 0 , 3},;		// "Incluir"
					{OemToAnsi(STR0007),"U_FAALT130"	, 0 , 4},;		// "Alterar"
					{OemToAnsi(STR0008),"U_FADel130"   , 0 , 5, 3},;  // "Excluir"
					{"DIRECT.CANB","U_DIRCNAB"   , 0 , 6}}
					
RestArea(aArea)
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FADel130³ Autor ³ Wagner Xavier         ³ Data ³ 23/06/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Parametros Bancarios - CNAB        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FADel130(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FinA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function FADel130(cAlias,nReg,nOpc)
LOCAL oDlg, nOpca, i, bCampo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]

Inclui := .F.
Altera := .F.
Exclui := .T.

GRAVALOG(cAlias,nReg,nOpc)// GRAVA LOG DA ALIAS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo est  realmente vazio ou se       ³
//³ est  posicionado em outra filial.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If EOF() .or. SEE->EE_FILIAL # xFilial("SEE")
	HELP(" " , 1 , "ARQVAZIO")
	Return Nil
Endif

While .T.
	nOpca := 0
	dbSelectArea( cAlias )
	bCampo := {|nCPO| Field(nCPO) }
	FOR i := 1 TO FCount()
		M->&(EVAL(bCampo,i)) := FieldGet(i)
	NEXT i

	nOpca := AxVisual(cAlias,nReg,2,,,,,)

	If nOpcA == 1
		//Chamada da IntegDef para mensagem única
		If FWHasEAI('FINA130',.T.,,.T.)
			FWIntegDef('FINA130')
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da protecao via TTS                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			dbSelectArea( cAlias )
			RecLock(cAlias,.F.,.T.)
			dbDelete()
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final  da protecao via TTS                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		MsUnlock( )
	Endif
	Exit
Enddo
dbSelectArea( cAlias )
Return

USER FUNCTION CPOTUDOK()
Local lRet := .T. 
LOCAL cMsgCpo := "Um ou mais campos obrigatórios não foram preenchidos." + ENTER + "Campo: "

IF !U_GTFIN039(3,'')//FILDPOS DE CAMPOS VERIFICANDO SE CAMPOS FORAM CRIADOS
	RETURN .F.
ENDIF 

	IF EMPTY(M->EE_P_EMAIL) .AND. M->EE_P_ACCES == '1'   
        lRet :=  .F.
        SX3->(DbSetOrder(2))
		SX3->(DbSeek("EE_P_EMAIL"))
        SXA->(DbSetOrder(1))
		SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1) 
	ELSEIF EMPTY(M->EE_CODEMP) .AND. M->EE_P_ACCES == '1'   
        lRet :=  .F.
        SX3->(DbSetOrder(2))
		SX3->(DbSeek("EE_CODEMP"))
        SXA->(DbSetOrder(1))
		SXA->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_FOLDER ))
        Help("",1,"CAMPO OBRIGATÓRIO",,cMsgCpo+" ("+SX3->X3_TITULO+")"+ENTER+"Pasta: ["+SXA->XA_DESCRIC+"] ",1)
    ENDIF 
    
RETURN lRet

//------------------------------------------------------------
// Função	| FAINC130()
// Autor	| Pedro Pereira Lima
// Data		| 26/03/2014
// Uso		| Encapsulamento do AxInclui para mensagem única
//------------------------------------------------------------
USER Function FAINC130(cAlias,nReg,nOpc)
Local nOpca
LOCAL aAreaAnt := GETAREA()
LOCAL lAccessOK := .F.
LOCAL mv00131 := ""

Inclui := .T.
Altera := .F.
Exclui := .F.

nOpca := AxInclui(cAlias,nReg,nOpc,,,,"(U_CPOTUDOK())")

If nOpca == 1 //Confirmou inclusao
	/*************************************
	PONTO RESPONSAVEL PARA VERIFICAR SE EXISTE ALGUM PARAMETRO DE BANCO 
	COM O CAMPO EE_P_ACCES COMO SIM DEIXANDO O PARAMETRO MV_P_00130 COMO .T.
	*************************************/
	SEE->(DbSetOrder(1))
    SEE->(DbGoTop( )) 
    While !SEE->(EOF())     
      IF SEE->EE_P_ACCES == '1'
	  	mv00131 :=  SEE->EE_P_EMAIL
        lAccessOK := .T.
      ENDIF 
      SEE->(DbSkip())
    EndDo

	IF !lAccessOK
		PUTMV("MV_P_00130",.F.)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE 
	ELSE
		PUTMV("MV_P_00130",.T.)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE
		PUTMV("MV_P_00131",mv00131)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE
	ENDIF
    RESTAREA(aAreaAnt)   // Retorna o ambiente anterior
	
	TABDIR(cAlias,nReg,nOpc)//GERA A TABELA COM OS DIRETORIOS QUE PRECISA EXISTIR
	GRAVALOG(cAlias,nReg,nOpc)// GRAVA LOG DA ALIAS

	FinaAtuSEB(SEE->EE_CODIGO)
	FinaAtuSEJ(SEE->EE_CODIGO)
Endif

//Chamada da IntegDef para mensagem única
If FWHasEAI('MATA070',.T.,,.T.)
	FWIntegDef('MATA070')
EndIf

Return

//------------------------------------------------------------
// Função	| FAALT130()
// Autor	| Pedro Pereira Lima
// Data		| 26/03/2014
// Uso		| Encapsulamento do AxAltera para mensagem única
//------------------------------------------------------------
USER Function FAALT130(cAlias,nReg,nOpc)
Local nOpca
LOCAL aAreaAnt := GETAREA()
LOCAL lAccessOK := .F.
LOCAL mv00131 := ""
//Local cCaminho := SEE->EE_XFOLDER

Inclui := .F.
Altera := .T.
Exclui := .F.

IF EMPTY(SEE->EE_P_NOEMP)
	SEE->EE_P_NOEMP := IF(AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))==0,ALLTRIM(LEFT(SM0->M0_NOME,30)),SUBSTR(STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),1, AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))-1))
ENDIF

nOpca := AxAltera(cAlias,nReg,nOpc,,,,,"(U_CPOTUDOK())")

If nOpca == 1
    /*************************************
	PONTO RESPONSAVEL PARA VERIFICAR SE EXISTE ALGUM PARAMETRO DE BANCO 
	COM O CAMPO EE_P_ACCES COMO SIM DEIXANDO O PARAMETRO MV_P_00130 COMO .T.
	*************************************/
    SEE->(DbSetOrder(1))
    SEE->(DbGoTop( )) 
    While !SEE->(EOF())     
      IF SEE->EE_P_ACCES == '1'
	    mv00131 :=  SEE->EE_P_EMAIL
        lAccessOK := .T.
      ENDIF 
      SEE->(DbSkip())
    EndDo

	IF !lAccessOK
		PUTMV("MV_P_00130",.F.)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE 
	ELSE
		PUTMV("MV_P_00130",.T.)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE
		PUTMV("MV_P_00131",mv00131)//PARAMETRO INFORMANDO QUE A EMPRESA UTILIZA ACCESSTAGE
	ENDIF
    RESTAREA(aAreaAnt)   // Retorna o ambiente anterior
	
	TABDIR(cAlias,nReg,nOpc)//GERA A TABELA COM OS DIRETORIOS QUE PRECISA EXISTIR
	GRAVALOG(cAlias,nReg,nOpc)// GRAVA LOG DA ALIAS
	FinaAtuSEB(SEE->EE_CODIGO)
	FinaAtuSEJ(SEE->EE_CODIGO)
	//Chamada da IntegDef para mensagem única
	If FWHasEAI('MATA070',.T.,,.T.)
		FWIntegDef('MATA070')
	EndIf
EndIf

Return


//------------------------------------------------------------
// Função	| IntegDef
// Autor	| Pedro Pereira Lima
// Data		| 26/03/2014
// Uso		| Integração via Mensagem Única
//------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg )
Local aReturn := {}

aReturn := MATI070( cXml, nType, cTypeMsg )

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} FA130RECEIVE
Função para gravação do complemento da configuração do banco.
(uso em mensagem única apenas)

@sample FA130Receive()
@author Pedro Pereira Lima
@since	29/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
static Function FA130Receive(cAction,cCod,cAgencia,cConta,cContractNo,aUpsert)
Local aArea		:= GetArea()

Default aUpsert := {}

DbSelectArea('SEE')
DbsetOrder(2)

If Len(aUpsert) > 0 .And. !Empty(aUpsert[1])
	If Upper(cAction) == 'UPSERT'
		If DbSeek(xFilial('SEE')+cCod+cAgencia+cConta+cContractNo)
			RecLock('SEE',.F.)
				SEE->EE_NUMCTR	:= aUpsert[01]
				SEE->EE_TIPCART	:= aUpsert[02]
				SEE->EE_CODCART	:= aUpsert[03]
				SEE->EE_TPCOBRA	:= aUpsert[04]
			MsUnlock()
		Else
			RecLock('SEE',.T.)
				SEE->EE_FILIAL	:= xFilial('SEE')
				SEE->EE_CODIGO	:= cCod
				SEE->EE_AGENCIA	:= cAgencia
				SEE->EE_CONTA	:= cConta
				SEE->EE_NUMCTR	:= aUpsert[01]
				SEE->EE_TIPCART	:= aUpsert[02]
				SEE->EE_CODCART	:= aUpsert[03]
				SEE->EE_TPCOBRA	:= aUpsert[04]
			MsUnlock()
		EndIf
	Else
		If DbSeek(xFilial('SEE')+cCod+cAgencia+cConta+cContractNo)
			RecLock('SEE',.F.)
				DbDelete()
			MsUnlock()
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return


//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuSEB
Função para popular tabela SEB na inicialização do SIGAFIN
Facilitador para uso do CNAB

@sample FinaAtuSEB()
@author Mauricio Pequim Jr
@since 17/05/13
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------

Static Function FinaAtuSEB(cBanco)
Local nI			:= 0
Local nJ			:= 0
Local aEstrut		:= {}
Local aSEB			:= {}
Local aArea		:= SEB->(GetArea())
Local cFilSEB		:= xFilial("SEB")
Local nTamFil		:= TamSx3("EB_FILIAL")[1]
Local nTamBco		:= TamSx3("EB_BANCO")[1]
Local nTamRefb	:= TamSx3("EB_REFBAN")[1]
Local nTamTipo	:= TamSx3("EB_TIPO")[1]

Default cBanco	:= ''

DbSelectArea("SEB")
SEB->(DbSetOrder(1)) //EB_FILIAL+EB_BANCO+EB_REFBAN+EB_TIPO+EB_MOTBAN
SEB->(DbGoTop())


	aEstrut := {"EB_FILIAL","EB_BANCO","EB_REFBAN","EB_TIPO","EB_OCORR","EB_DESCRI","EB_MOTSIS","EB_MOTBAN","EB_DESCMOT"}

	

	If cBanco == '001'
		aAdd(aSEB,{cFilSEB,'001','01','E','01','REGISTRO DE TITULOS','','',''})
		aAdd(aSEB,{cFilSEB,'001','02','E','02','SOLICITACAO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'001','03','E','31','PEDIDO DE DEBITO EM CONTA','','',''})
		aAdd(aSEB,{cFilSEB,'001','04','E','04','CONCESSAO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','05','E','05','CANCELAMENTO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','06','E','06','ALTERACAO VCTO. DE TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'001','07','E','07','ALT.NUMERO CONTROLE DO PARTIC.','','',''})
		aAdd(aSEB,{cFilSEB,'001','08','E','08','ALT.NUMERO TIT.DADO AO CEDENTE','','',''})
		aAdd(aSEB,{cFilSEB,'001','09','E','09','INSTRUCAO PARA PROTESTAR','','',''})
		aAdd(aSEB,{cFilSEB,'001','10','E','10','INSTRUCAO PARA SUSTAR PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','11','E','10','INSTRUCAO PARA DISPENSAR JUROS','','',''})
		aAdd(aSEB,{cFilSEB,'001','12','E','31','ALT.NOME E ENDERECO DO SACADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','16','E','','ALT JUROS DE MORA','','',''})
		aAdd(aSEB,{cFilSEB,'001','00','P','06','PAGAMENTO EFETUADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','01','P','03','INSUFICIENCIA DE FUNDOS','','',''})
		aAdd(aSEB,{cFilSEB,'001','02','P','03','DEBITO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','03','P','01','DEBITO AUTORIZADO PELA AGENCIA','','',''})
		aAdd(aSEB,{cFilSEB,'001','AA','P','03','CONTROLE INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AB','P','03','TIPO DE OPERACAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AC','P','03','TIPO DE SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AD','P','03','FORMA LANCAMENTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'001','AE','P','03','TIPO/NUM.INSCRICAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AF','P','03','CODIGO CONVENIO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AG','P','03','AGENCIA/CONTA INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AH','P','03','No SEQUENCIAL REG.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AI','P','03','CODIGO SEGMENTO DET.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AJ','P','03','TIPO MOVIMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AK','P','03','CODIGO CAMARA COMP.BANCO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AL','P','03','CODIGO BANCO FAVOR.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AM','P','03','AGENCIA MANTEDORA CONTA INVALI','','',''})
		aAdd(aSEB,{cFilSEB,'001','AN','P','03','CONTA/DV INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'001','AO','P','03','NOME FAVORECIDO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AP','P','03','DATA LANCAMENTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'001','AQ','P','03','TIPO/QUANT.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AR','P','03','VALOR LANCAMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AS','P','03','AVISO FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AT','P','03','NUM.INSCRICAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AU','P','03','ENDERECO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AV','P','03','NUMERO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AW','P','03','CIDADE FAVORECIDO NAO INFORMAD','','',''})
		aAdd(aSEB,{cFilSEB,'001','AX','P','03','CEP FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AY','P','03','SIGLA DO ESTADO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','AZ','P','03','CODIGO NOME BANCO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','BB','P','03','SEU NUMERO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','BD','P','03','CONFIRMACAO PAGAMENTO AGENDADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','CA','P','03','COD.BARRAS-BANCO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','CB','P','03','COD.BARRAS-MOEDA INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'001','CC','P','03','COD.BARRAS-DIG.VERIF.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','CD','P','03','COD.BARRAS-VALOR TITULO INVALI','','',''})
		aAdd(aSEB,{cFilSEB,'001','CE','P','03','COD.BARRAS-CAMPO LIVRE INVALID','','',''})
		aAdd(aSEB,{cFilSEB,'001','HA','P','03','LOTE NAO ACEITO','','',''})
		aAdd(aSEB,{cFilSEB,'001','HB','P','03','INSCR.EMPRESA INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'001','HC','P','03','CONVENIO EMPRESA INEXISTENTE','','',''})
		aAdd(aSEB,{cFilSEB,'001','HD','P','03','AG/CONTA INEXISTENTE','','',''})
		aAdd(aSEB,{cFilSEB,'001','HE','P','03','TIPO SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','HF','P','03','CONTA COM SALDO INSUFICIENTE','','',''})
		aAdd(aSEB,{cFilSEB,'001','HG','P','03','LOTE FORA DE SEQUENCIA','','',''})
		aAdd(aSEB,{cFilSEB,'001','HH','P','03','LOTE SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','TA','P','03','LOTE NAO ACEITO - TOTAIS DIFER','','',''})
		aAdd(aSEB,{cFilSEB,'001','02','R','02','CONFIMACAO ENTRADA DE TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','09','DATA DE VENC. INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','01','IDENTIFICACAO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','02','VARIACAO CART.INVALIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','03','VL. JUROS P/UM DIA INV'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','04','VALOR DESC.INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','05','ESP.TIT.INV.CART/VAR'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','07','PREF.AGEND.USUS.INV.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','06','ESP.VALOR VAR. INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','08','VL.TITULO/APOLICE INV.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','10','FORA PRAZO/SOM.CART.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','11','INEXIST.MARG.DESCONTO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','12','BCO.SEM AG. SACADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','13','RAZOES CADASTRAIS'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','14','SAC.INTERLIG.C/SACADOR'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','15','TIT.SAC.CONTRA ORG.PUB'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','16','TIT.PREENCH.IRREGULAR'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','17','TITULO RASURADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','18','ENDERECO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','19','COD.CEDENTE INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','20','NOME/END.CLIENT.INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','21','CARTEIRA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','22','QT.VALOR VARIAV.INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','23','FAIXA NUMERO EXCEDIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','24','VALOR ABAT.INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','25','NUM TIT. CEDENT.INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','26','VALOR IOF INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','27','NOME INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','28','DATA VENC. INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','29','ENDERECO NAO INFORMADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','30','REG.TITULO JA LIQUID.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','31','NUM.BORDERO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','32','NOME PES.AUT.INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','33','NUMERO JA EXISTENTE'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','34','NUM.PREST.CONTR.INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','35','PERC.DESCONTO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','36','DIAS PROTESTO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','37','DATA EMISSAO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','38','DATA VENC.ANT.DO TIT.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','39','COMAND.ALTER.INDEVIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','40','TIPO MOEDA INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','41','ABAT.NAO PERMITIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','42','CEP SACADO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','43','COD.UNID.VAR.INCOMPAT.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','44','DADOS P/DEBITO INVAL.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','45','CART./VAR/ ENCERRADA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','46','CONVENIO ENCERRADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','47','VAL.DIVERSO DO INFORM.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','48','MOTIVO BAIXA INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','49','ABATIMENTO NAO CONSTA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','50','COMAND.INCOMPATIVEL'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','51','COD.CONVENENTE INV.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','52','VALOR ABATIM.INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','53','TIT.COM SITUACAO PRET.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','54','TITULO FORA PRAZO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','55','VENC. FORA LIMITES'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','56','TIT.NAO PERT.CONVEN.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','57','VARIACAO INCOMPATIVEL'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','58','IMPOS.TRANSF.P/CART.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','59','TITULO VENCIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','60','PRAZO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','61','TIT.JA FICH.P/PROTEST.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','62','SITUACAO DEB.INVALIDA'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','63','DV. NOS.NUM.INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','64','NAO PASSIVEL DEB/BAIX.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','65','TIT.NAO ENC.CARTORIO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','67','TITULO/CARNE REJEITADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','80','NOSSO NUM. INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','81','DT.CONCESSAO DESC.INV.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','82','CEP SACADO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','83','CART/VAR.NAO LOCALIZ.'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','84','TITULO NAO LOCALIZADO'})
		aAdd(aSEB,{cFilSEB,'001','03','R','03','COMANDO RECUSADO','01','99','OUTROS MOTIVOS'})
		aAdd(aSEB,{cFilSEB,'001','06','R','06','LIQUIDACAO NORMAL','','',''})
		aAdd(aSEB,{cFilSEB,'001','07','R','06','LIQUIDACAO POR CONTA','','',''})
		aAdd(aSEB,{cFilSEB,'001','08','R','06','LIQUIDACAO POR SALDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','09','R','09','BAIXA DE TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'001','10','R','10','BAIXA SOLICITADA','','',''})
		aAdd(aSEB,{cFilSEB,'001','11','R','11','TITULOS EM SER','','',''})
		aAdd(aSEB,{cFilSEB,'001','12','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','13','R','13','ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','14','R','14','ALTERACAO VENCIMENTO DO TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'001','15','R','08','LIQUIDACAO EM CARTORIO','01','09','LIQUIDACAO EM CARTORIO'})
		aAdd(aSEB,{cFilSEB,'001','16','R','14','ALTERACAO DE JUROS MORA','','',''})
		aAdd(aSEB,{cFilSEB,'001','19','R','19','CONFIR.RECEB.INSTR..P/PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','20','R','30','DEBITO EM CONTA','','',''})
		aAdd(aSEB,{cFilSEB,'001','21','R','14','ALTERACAO DO NOME DO SACADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','22','R','14','ALTERACAO ENDERECO SACADO','','',''})
		aAdd(aSEB,{cFilSEB,'001','23','R','23','INDICACAO ENCAMIN. A CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'001','24','R','34','SUSTAR PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','25','R','25','DISPENSAR JUROS','','',''})
		aAdd(aSEB,{cFilSEB,'001','28','R','29','MANUTENCAO TITULO VENCIDO','','',''})
		aAdd(aSEB,{cFilSEB,'001','96','R','33','DESPESAS DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','97','R','33','DESPESAS DE SUSTACAO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'001','98','R','30','DEBITO DE CUSTAS ANTECIPADAS','','',''})

	ElseIf cBanco == '033'
		aAdd(aSEB,{cFilSEB,'033','01','E','01','REMESSA','','',''})
		aAdd(aSEB,{cFilSEB,'033','02','E','02','PEDIDO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'033','04','E','04','CONCESSAO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','05','E','05','CANCELAMENTO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','06','E','06','ALTERACAO DO VENCIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','07','E','07','ALT. NUMERO CONT.CEDENTE','','',''})
		aAdd(aSEB,{cFilSEB,'033','08','E','08','ALTERACAO DO SEU NUMERO','','',''})
		aAdd(aSEB,{cFilSEB,'033','09','E','09','PROTESTAR','','',''})
		aAdd(aSEB,{cFilSEB,'033','18','E','18','CANCELAR O PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','00','R','06','DEBITO EFETUADO','','',''})
		aAdd(aSEB,{cFilSEB,'033','01','R','03','TITULO NAO EXISTE','','',''})
		aAdd(aSEB,{cFilSEB,'033','02','R','02','ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'033','03','R','03','ENTRADA REJEITADA','','',''})
		aAdd(aSEB,{cFilSEB,'033','06','R','06','LIQUIDACAO NORMAL','','',''})
		aAdd(aSEB,{cFilSEB,'033','07','R','06','LIQ. POR CONTA','','',''})
		aAdd(aSEB,{cFilSEB,'033','08','R','08','LIQUIDACAO POR SALDO','','',''})
		aAdd(aSEB,{cFilSEB,'033','09','R','10','BAIXA AUTOMATICA','','',''})
		aAdd(aSEB,{cFilSEB,'033','10','R','10','TIT. BAIX. CONF. INSTRUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'033','12','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'033','13','R','13','ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'033','14','R','14','VENCIMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'033','15','R','23','CONFIRMACAO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','16','R','16','TIT. JA BAIXADO/LIQUIDADO','','',''})
		aAdd(aSEB,{cFilSEB,'033','17','R','08','PAGO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'033','21','R','23','TIT. ENVIADO A CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'033','22','R','21','TIT. RETIRADO DE CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'033','24','R','33','CUSTAS DE CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'033','25','R','19','PROTESTAR TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'033','26','R','21','SUSTAR PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'033','99','R','03','CANCELADO CONFORME SOLICITACAO','','',''})

	ElseIf cBanco == '104'
		aAdd(aSEB,{cFilSEB,'104','01','E','01','REMESSA','','',''})
		aAdd(aSEB,{cFilSEB,'104','02','E','02','PEDIDO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'104','03','E','04','CONCESSAO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','04','E','05','CANCELAMENTO DO ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','05','E','06','ALTERACAO DO VENCIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','06','E','07','ALTERACAO DO USO DA EMPRESA','','',''})
		aAdd(aSEB,{cFilSEB,'104','07','E','10','ALTERACAO PRAZO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','08','E','31','ALTERACAO PRAZO DE DEVOLUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','09','E','31','ALTERACAO DE OUTROS DADOS','','',''})
		aAdd(aSEB,{cFilSEB,'104','10','E','31','ALT DE DADOS C/ EMISSAO / BLOQ','','',''})
		aAdd(aSEB,{cFilSEB,'104','11','E','10','ALTER OPCAO PROTESTO P/DEVOLUC','','',''})
		aAdd(aSEB,{cFilSEB,'104','12','E','09','ALTER OPCAO DEVOLUCAO P/PROTES','','',''})
		aAdd(aSEB,{cFilSEB,'104','01','R','02','ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'104','02','R','06','BAIXA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'104','03','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'104','04','R','13','ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'104','05','R','14','VENCIMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'104','06','R','14','USO DA EMPRESA - ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'104','07','R','14','PRAZO DE PROTESTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'104','08','R','14','PRAZO DE DEVOLUCAO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'104','09','R','04','ALTERACAO CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'104','10','R','14','ALT. COM REEMISSAO DE BLOQUEIO','','',''})
		aAdd(aSEB,{cFilSEB,'104','11','R','21','ALT. OPCAO PROTESTO DEVOLUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','12','R','19','ALT. OPCAO DEVOLUCAO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','20','R','11','EM SER','','',''})
		aAdd(aSEB,{cFilSEB,'104','21','R','06','LIQUIDACAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','22','R','08','LIQUIDACAO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'104','23','R','10','BAIXA POR DEVOLUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','24','R','10','BAIXA POR FRANCO PAGAMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','25','R','32','BAIXA POR PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','26','R','23','TITULO ENVIADO PARA CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'104','27','R','21','SUSTACAO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','28','R','21','ESTORNO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','29','R','21','ESTORNO DE SUSTACAO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'104','30','R','04','ALTERACAO DE TITULO','','',''})
		aAdd(aSEB,{cFilSEB,'104','31','R','29','TARIFA SOBRE TITULO VENCIDO','','',''})
		aAdd(aSEB,{cFilSEB,'104','32','R','26','OUTRAS TARIFAS ALTERACAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','33','R','04','ESTORNO BAIXA/LIQUIDACAO','','',''})
		aAdd(aSEB,{cFilSEB,'104','34','R','04','TRANSF CART/ENTRADA','','',''})
		aAdd(aSEB,{cFilSEB,'104','35','R','','TRANSF CART/BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','01','MOVIMENTO SEM CEDENTE'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','02','MOVIMENTO SEM TITULO C'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','21','AGENCIA NAO ENCONTRADA'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','08','MOVIMENTO PARA TITULO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','09','NOSSO NUMERO NAO PERTE'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','10','INCLUSAO DE TITULO JA'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','22','AGENCIA CEDENTE'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','12','MOVIMENTO DUPLICADO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','13','ENTRADA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','20','CEP NAO ENCONTRADO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','45','DATA VENCIMENTO COM PR'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','49','MOVIMENTO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','50','MOVIMENTO INVALIDO CAR'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','54','FAIXA CEP DA AGENCIA C'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','55','TITULO OPCAO DE DEVOLU'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','56','PROCESSO DE PROTESTO E'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','57','TITULO OPCAO PROTESTO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','58','PROCESSO DEVOLUCAO EM'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','59','NOV PRZ PROTEST/DEV IN'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','76','ALT PRZ PROTEST INVALI'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','77','ALT PRZ DEVOLUC INVALI'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','81','CEP DO SACADO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','82','CGC/CPF DO SACADO INVA'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','83','NRO DOC (SEU NUM) INVA'})
		aAdd(aSEB,{cFilSEB,'104','99','R','03','REGISTRO REJEITADO','01','84','PROT INV P/ TIT SEM NR'})
		aAdd(aSEB,{cFilSEB,'237','01','E','01','REMESSA','','',''})

	ElseIf cBanco == '237'
		aAdd(aSEB,{cFilSEB,'237','02','E','02','PEDIDO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'237','04','E','04','CONCESSAO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','05','E','05','CANC ABAT CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','06','E','06','ALTERACAO DE VENCIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','07','E','07','ALT DO CONTROLE PARTICIPANTE','','',''})
		aAdd(aSEB,{cFilSEB,'237','08','E','08','ALTERACAO DE SEU NUMERO','','',''})
		aAdd(aSEB,{cFilSEB,'237','09','E','09','PEDIDO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','18','E','18','SUSTAR PROTESTO E BAIXAR TITUL','','',''})
		aAdd(aSEB,{cFilSEB,'237','19','E','18','SUSTAR PROT E MANTER EM CARTEI','','',''})
		aAdd(aSEB,{cFilSEB,'237','22','E','07','TRANSF CESSAO CRED ID PROD 10','','',''})
		aAdd(aSEB,{cFilSEB,'237','23','E','07','TRANSFERENCIA ENTRE CARTEIRAS','','',''})
		aAdd(aSEB,{cFilSEB,'237','24','E','07','DEV TRANSFERENCIA ENTRE CARTEI','','',''})
		aAdd(aSEB,{cFilSEB,'237','31','E','07','ALTERACAO DE OUTROS DADOS','','',''})
		aAdd(aSEB,{cFilSEB,'237','35','E','07','DESAGEND DO DEB AUTOMATICO','','',''})
		aAdd(aSEB,{cFilSEB,'237','68','E','07','ACERTO NOS DADOS RATEIO CREDIT','','',''})
		aAdd(aSEB,{cFilSEB,'237','69','E','07','CANC RATEIO DE CREDITO','','',''})
		aAdd(aSEB,{cFilSEB,'237','00','P','01','PAGAMENTO EFETUADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','01','P','03','INSUFICIENCIA DE FUNDOS','','',''})
		aAdd(aSEB,{cFilSEB,'237','02','P','03','DEBITO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','03','P','03','DEBITO AUTORIZADO PELA AGENCIA','','',''})
		aAdd(aSEB,{cFilSEB,'237','AA','P','03','CONTROLE INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AB','P','03','TIPO DE OPERACAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AC','P','03','TIPO DE SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AD','P','03','FORMA LANCAMENTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'237','AE','P','03','TIPO/NUM.INSCRICAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AF','P','03','CODIGO CONVENIO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AG','P','03','AGENCIA/CONTA INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AH','P','03','No SEQUENCIAL REG.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AI','P','03','CODIGO SEGMENTO DET.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AJ','P','03','TIPO MOVIMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AK','P','03','CODIGO CAMARA COMP.BANCO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AL','P','03','CODIGO BANCO FAVOR.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AM','P','03','AGENCIA MANTEDORA CONTA INVALI','','',''})
		aAdd(aSEB,{cFilSEB,'237','AN','P','03','CONTA/DV INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'237','AO','P','03','NOME FAVORECIDO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AP','P','03','DATA LANCAMENTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'237','AQ','P','03','TIPO/QUANT.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AR','P','03','VALOR LANCAMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AS','P','03','AVISO FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AT','P','03','NUM.INSCRICAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AU','P','03','ENDERECO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AV','P','03','NUMERO NAO INFORMADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AW','P','03','CIDADE FAVORECIDO NAO INFORMAD','','',''})
		aAdd(aSEB,{cFilSEB,'237','AX','P','03','CEP FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AY','P','03','SIGLA DO ESTADO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','AZ','P','03','CODIGO NOME BANCO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','BB','P','03','SEU NUMERO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','BD','P','03','CONFIRMACAO PAGAMENTO AGENDADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','CA','P','03','COD.BARRAS-BANCO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','CB','P','03','COD.BARRAS-MOEDA INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'237','CC','P','03','COD.BARRAS-DIG.VERIF.INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','CD','P','03','COD.BARRAS-VALOR TITULO INVALI','','',''})
		aAdd(aSEB,{cFilSEB,'237','CE','P','03','COD.BARRAS-CAMPO LIVRE INVALID','','',''})
		aAdd(aSEB,{cFilSEB,'237','HA','P','03','LOTE NAO ACEITO','','',''})
		aAdd(aSEB,{cFilSEB,'237','HB','P','03','INSCR.EMPRESA INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'237','HC','P','03','CONVENIO EMPRESA INEXISTENTE','','',''})
		aAdd(aSEB,{cFilSEB,'237','HD','P','03','AG/CONTA INEXISTENTE','','',''})
		aAdd(aSEB,{cFilSEB,'237','HE','P','03','TIPO SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','HF','P','03','CONTA COM SALDO INSUFICIENTE','','',''})
		aAdd(aSEB,{cFilSEB,'237','HG','P','03','LOTE FORA DE SEQUENCIA','','',''})
		aAdd(aSEB,{cFilSEB,'237','HH','P','03','LOTE SERVICO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','TA','P','03','LOTE NAO ACEITO - TOTAIS DIFER','','',''})
		aAdd(aSEB,{cFilSEB,'237','02','R','02','ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','',''})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','02','COD DO REG DETALHE INV'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','03','COD OCORRENCIA INVALID'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','04','OCORR NAO PERMITID CAR'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','05','COD OCORR NAO NUMERICO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','07','AG / CTA / DIG INVALID'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','08','NOSSO NRO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','09','NOSSO NRO DUPLICADO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','10','CARTEIRA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','13','ID EMISS DO BLOQ INVAL'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','16','DATA DE VENC INVALIDA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','18','VENC FORA DO PRZ OPERA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','20','VALOR DO TITULO INVALI'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','21','ESPECIE TITULO INVALID'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','22','ESP NAO PERM P/ CARTEI'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','24','DATA DE EMISS INVALIDA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','28','COD DE DESC INVALIDO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','38','PRZ PROTESTO INVALID'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','44','AG CEDENTE NAO PREVIST'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','45','NOME DO SACAD NAO INFO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','46','TP/NUM INSCR SAC INVAL'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','47','END SACADO NAO INFORMA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','48','CEP INVALIDO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','50','CEP IRREG - BCO CORRES'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','63','ENTR P/TIT JA CADASTRA'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','65','LIMITE EXCEDIDO'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','66','NRO AUTORIZ INEXISTENT'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','68','DEB NAO AGEND-ERR REME'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','69','DEB N AGEN-SACAD N AUT'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','70','DEB N AGEN-CEDEN N AUT'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','71','CEDEN N PARTIC DEB AUT'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','72','DEB N AGEN-MOED<> REAL'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','73','DEB N AG-DT VENC INVAL'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','74','DEB N AG-TIT N REG-PED'})
		aAdd(aSEB,{cFilSEB,'237','03','R','03','ENTRADA REJEITADA','','75','DEB N AG-TIP INSCR INV'})
		aAdd(aSEB,{cFilSEB,'237','06','R','06','LIQUIDACAO NORMAL','','',''})
		aAdd(aSEB,{cFilSEB,'237','09','R','06','BAIXADO AUTOM VIA ARQUIVO','','',''})
		aAdd(aSEB,{cFilSEB,'237','10','R','06','BAIXADO CONF INSTR DA AGENCIA','','',''})
		aAdd(aSEB,{cFilSEB,'237','11','R','11','EM SER (ARQ DE TIT PENDENTES)','','',''})
		aAdd(aSEB,{cFilSEB,'237','12','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'237','13','R','13','ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','14','R','14','VENCIMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','15','R','08','LIQUIDACAO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'237','16','R','06','TITULO PAGO EM CHEQUE','','',''})
		aAdd(aSEB,{cFilSEB,'237','17','R','06','LIQUID APOS BX / TIT NAO REGIS','','',''})
		aAdd(aSEB,{cFilSEB,'237','18','R','14','ACERTO DE DEPOSITARIA','','',''})
		aAdd(aSEB,{cFilSEB,'237','19','R','19','CONF RECEB INST DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','20','R','21','CONF RECEB INST SUST PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','21','R','14','ACERTO CONTROLE DO PARTICIPANT','','',''})
		aAdd(aSEB,{cFilSEB,'237','22','R','','TITULO COM PAGTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'237','23','R','19','ENTRADA DO TITULO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'237','24','R','40','ENTR REJEITADA POR CEP IRREGUL','','',''})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','',''})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','04','COD OCORR N PERM CARTE'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','07','AG / CONTA / DIG INVAL'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','08','NOSSO NRO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','10','CARTEIRA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','15','CART/AG/CTA/NO NRO INV'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','40','TIT COM ORD PROT EMIT'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','42','COD BXA/DEV TELEBRA IN'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','60','MOV P/ TIT NAO CADASTR'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','77','TRANS P/DSC N PERM CAR'})
		aAdd(aSEB,{cFilSEB,'237','27','R','15','BAIXA REJEITADA','','85','TIT COM PAGTO VINCULAD'})
		aAdd(aSEB,{cFilSEB,'237','28','R','30','DEB DE TARIFAS / CUSTAS','','',''})
		aAdd(aSEB,{cFilSEB,'237','30','R','17','ALT DE OUTROS DADOS REJEITADOS','','',''})
		aAdd(aSEB,{cFilSEB,'237','32','R','16','INSTR REJEITADA','','',''})
		aAdd(aSEB,{cFilSEB,'237','33','R','14','CONF PEDIDO ALTER OUTROS DADOS','','',''})
		aAdd(aSEB,{cFilSEB,'237','34','R','14','RETIRADO DE CART E MANUT CART','','',''})
		aAdd(aSEB,{cFilSEB,'237','35','R','14','DESAGEND DO DEB AUTOMATICO','','',''})
		aAdd(aSEB,{cFilSEB,'237','40','R','','ESTORNO DE PAGAMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'237','55','R','','SUSTADO JUDICIAL','','',''})
		aAdd(aSEB,{cFilSEB,'237','68','R','14','ACERTO DOS DADOS RATEIO CREDIT','','',''})
		aAdd(aSEB,{cFilSEB,'237','69','R','14','CANC DOS DADOS DO RATEIO','','',''})

	ElseIf cBanco == '341'
		aAdd(aSEB,{cFilSEB,'341','01','E','01','REMESSA','','',''})
		aAdd(aSEB,{cFilSEB,'341','02','E','02','PEDIDO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'341','04','E','04','CONCESSAO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','05','E','05','CANCELAMENTO DE ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','06','E','06','ALTERACAO DE VENCIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','07','E','07','ALTERACAO DO USO DA EMPRESA','','',''})
		aAdd(aSEB,{cFilSEB,'341','08','E','08','ALTERACAO DO SEU NUMERO','','',''})
		aAdd(aSEB,{cFilSEB,'341','09','E','09','PROTESTAR','','',''})
		aAdd(aSEB,{cFilSEB,'341','10','E','10','NAO PROTESTAR','','',''})
		aAdd(aSEB,{cFilSEB,'341','11','E','09','PROTESTO PARA FINS FALIMENTARE','','',''})
		aAdd(aSEB,{cFilSEB,'341','18','E','18','SUSTAR PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','30','E','','EXCLUSAO DE SACADOR AVALISTA','','',''})
		aAdd(aSEB,{cFilSEB,'341','31','E','31','ALTERACAO DE DADOS','','',''})
		aAdd(aSEB,{cFilSEB,'341','34','E','34','BAIXA POR SER PG AO CEDENTE','','',''})
		aAdd(aSEB,{cFilSEB,'341','35','E','','CANCELAMENTO DE INSTRUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'341','37','E','18','ALTERACAO DO VENCIMENTO E SUST','','',''})
		aAdd(aSEB,{cFilSEB,'341','38','E','','CEDENTE NAO CONCORDA COM ALEGA','','',''})
		aAdd(aSEB,{cFilSEB,'341','47','E','','CEDENTE SOLICITA DISPENSA DE J','','',''})
		aAdd(aSEB,{cFilSEB,'341','AE','P','03','DATA PAGAMENTO ALTERADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','AH','P','03','NUM SEQ LOTE INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','AJ','P','03','TIPO MOVIMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','AL','P','03','COD BANCO FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','AM','P','03','AGENCIA FAVORECIDO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'341','AN','P','03','CONTA CORRENTE FAVORECIDO INVA','','',''})
		aAdd(aSEB,{cFilSEB,'341','AO','P','03','NOME FAVORECIDO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','AP','P','03','DATA LANCAMENTO/PGTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'341','BC','P','03','NOSSO NUMERO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','BD','P','02','PAGAMENTO AGENDADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','BE','P','03','PGTO AGENDADO ALTERADA PARA OP','','',''})
		aAdd(aSEB,{cFilSEB,'341','CD','P','03','CNPJ/CPF DIVERGENTE CADASTRADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','CE','P','03','PAGAMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','CI','P','03','CNPJ/CPF INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','CN','P','03','CONTA NAO CADASTRADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','DV','P','03','DOC/BLOQUETO DEVOLVIDO BCO FAV','','',''})
		aAdd(aSEB,{cFilSEB,'341','EX','P','03','DEVOLUCAO OP NAO SACADA FAVORE','','',''})
		aAdd(aSEB,{cFilSEB,'341','IB','P','03','VALOR TITULO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IC','P','03','VALOR ABATIMENTO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IE','P','03','VALOR MORA INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IF','P','03','VALOR MULTA INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IG','P','03','VALOR DEDUCAO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IH','P','03','VALOR ACRESCIMO INVALIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','II','P','03','DATA VENCIMENTO INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'341','IM','P','03','TIPO X FORMA NAO COMPATIVEL','','',''})
		aAdd(aSEB,{cFilSEB,'341','IP','P','03','DIGITO VERIF CODIGO BARRAS INV','','',''})
		aAdd(aSEB,{cFilSEB,'341','IR','P','03','PAGAMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','IS','P','03','CONCESSIONARIA NAO CONVENIADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','LA','P','03','DATA PGTO UM LOTE ALTERADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','LC','P','03','LOTE PGTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','NA','P','03','PGTO CANCELADO FALTA AUTORIZAD','','',''})
		aAdd(aSEB,{cFilSEB,'341','NR','P','03','OPERACAO NAO REALIZADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','RJ','P','03','REGISTRO REJEITADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','SS','P','03','PGTO CANCELADO INSUF SALDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','TA','P','03','LOTE NAO ACEITO TOTAIS DIFEREN','','',''})
		aAdd(aSEB,{cFilSEB,'341','TI','P','03','TITULARIDADE INVALIDA','','',''})
		aAdd(aSEB,{cFilSEB,'341','00','R','06','PAGAMENTO EFETUADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','02','R','02','ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','03','CEP INVALIDO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','04','SIGLA ESTADO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','05','DATA VENCIMENTO INVALI'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','07','VALOR TITULO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','08','NOME NAO INFORMADO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','09','AGENCIA ENCERRADA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','10','LOGRADOURO NAO INFORMA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','11','CEP NAO NUMERICO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','12','NOME SACADOR NAO INFOR'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','13','CEP INCOMPATIVEL C/EST'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','14','NOSSO NUM. JA REGISTRA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','15','NOSSO NUMERO EM DUPLIC'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','18','DATA DE ENTRADA INVALI'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','19','OCORRENCIA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','21','CARTEIRA NAO ACEITA DE'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','22','CARTEIRA NAO PERMITIDA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','26','AGENCIA/CONTA NAO LIBE'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','27','CNPJ DO CEDENTE INAPTO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','29','CATEGORIA DA CONTA INV'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','30','ENTRADAS BLOQUEADAS, C'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','31','CONTA NAO TEM PERMISSA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','35','IOF MAIOR QUE 5%'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','36','QUANTIDADE DE MOEDA IN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','37','NAO NUMERICO OU IGUAL'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','42','NOSSO NUMERO FORA DE F'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','52','EMPRESA NAO ACEITA BAN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','53','EMPRESA NAO ACEITA BAN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','54','BANCO CORRESPONDENTE -'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','55','CEP NAO PERTENCE A DEP'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','56','VENCTO SUPERIOR A 180'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','57','CEP SO DEPOSITARIA BCO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','60','VALOR DO ABATIMENTO IN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','61','JUROS DE MORA MAIOR QU'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','63','VALOR DA IMPORTANCIA P'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','64','DATA DE EMISSAO DO TIT'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','65','TAXA INVALIDA (VENDOR)'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','66','INVALIDA/FORA DE PRAZO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','67','VALOR DO TITULO/QUANTI'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','68','CARTEIRA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','69','CARTEIRA INVALIDA PARA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','70','CEDENTE NAO CADASTRADO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','78','DUPLICIDADE DE AGENCIA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','80','QTD CTAS BENEFICIARIAS'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','81','CONTA PARA RATEIO DE C'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','82','DESCONTO/ABATIMENTO NA'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','83','VALOR DO TITULO MENOR'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','84','AGENCIA/CONTA BENEFICI'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','85','AGENCIA/CONTA DO CEDEN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','86','CODIGO DO TIPO DE VALO'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','87','REGISTRO TIPO 4 SEM IN'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','90','COBRANCA MENSAGEM - NU'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','97','COBRANCA MENSAGEM SEM'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','98','REGISTRO MENSAGEM SEM'})
		aAdd(aSEB,{cFilSEB,'341','03','R','03','REGISTRO REJEITADO','01','99','CONTA DE COBRANCA COM'})
		aAdd(aSEB,{cFilSEB,'341','04','R','04','ALTERACAO DE DADOS - REENTRADA','','',''})
		aAdd(aSEB,{cFilSEB,'341','05','R','05','ALTERACAO DADOS - BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'341','06','R','06','LIQUIDACAO NORMAL','','',''})
		aAdd(aSEB,{cFilSEB,'341','07','R','07','LIQUIDACAO PARCIAL - COB. B2B','','',''})
		aAdd(aSEB,{cFilSEB,'341','08','R','08','LIQUIDACAO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'341','09','R','09','BAIXA SIMPLES','','',''})
		aAdd(aSEB,{cFilSEB,'341','10','R','10','BAIXA POR TER SIDO LIQUIDADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','11','R','11','EM SER (SO RETORNO MENSAL)','','',''})
		aAdd(aSEB,{cFilSEB,'341','12','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','13','R','13','ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','14','R','14','VENCIMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','01','CART. NAO NUMERICO'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','04','NOSSO NUMERO EM DUPLIC'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','05','SOLICITACAO DE BAIXA P'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','06','SOLICITACAO DE BAIXA P'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','07','COBRANCA PRAZO CURTO û'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','08','SOLICITACAO DE BAIXA P'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','10','VALOR DO TITULO FAZ PA'})
		aAdd(aSEB,{cFilSEB,'341','15','R','15','BAIXAS REJEITADAS','01','11','PAGO ATRAVES DO SISPAG'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','01','INSTRUCAO/OCORRENCIA N'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','03','CONTA NAO TEM PERMISSA'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','06','NOSSO NUMERO IGUAL A Z'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','09','CNPJ/CPF DO SACADOR/AV'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','10','VALOR DO ABATIMENTO IG'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','11','SEGUNDA INSTRUCAO/OCOR'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','14','REGISTRO EM DUPLICIDAD'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','15','CNPJ/CPF INFORMADO SEM'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','19','VALOR DO ABATIMENTO MA'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','20','EXISTE SUSTACAO DE PRO'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','21','TITULO NAO REGISTRADO'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','22','TITULO BAIXADO OU LIQU'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','23','INSTRUCAO NAO ACEITA P'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','24','INSTRUCAO INCOMPATIVEL'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','25','INSTRUCAO INCOMPATIVEL'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','26','INSTRUCAO NAO ACEITA P'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','27','INSTRUCAO NAO ACEITA P'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','28','JA EXISTE UMA MESMA IN'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','29','VALOR LIQUIDO + VALOR'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','30','EXISTE UMA INSTRUCAO D'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','31','EXISTE UMA OCORRENCIA'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','32','DEPOSITARIA DO TITULO'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','33','ALT VENC IGUAL A REGIS'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','34','INSTRUCAO DE EMISSAO D'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','35','SOLICITACAO DE CANCELA'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','36','TITULO SOFRENDO ALTERA'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','37','INSTRUCAO NAO PERMITID'})
		aAdd(aSEB,{cFilSEB,'341','16','R','16','INSTRUCOES REJEITADAS','01','38','INSTRUCAO NAO PERMITID'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','02','AG. COBRADORA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','04','SIGLA DO ESTADO INVALI'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','05','DATA DE VENCIMENTO INV'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','06','VALOR DO TITULO COM OU'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','08','NOME DO SACADO COM O M'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','09','AGENCIA/CONTA INCORRET'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','11','CEP INVALIDO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','13','SEU NUMERO COM O MESMO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','16','ABATIMENTO/ALTERACAO D'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','20','ESPECIE INVALIDA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','21','AGENCIA COBRADORA NAO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','23','DATA DE EMISSAO DO TIT'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','41','CAMPO ACEITE INVALIDO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','42','ALTERACAO INVALIDA PAR'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','43','ALTERACAO BLOQUEADA û'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','53','INSTRUCAO COM O MESMO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','54','DATA VENCIMENTO PARA B'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','55','ALTERACOES IGUAIS PARA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','56','CNPJ/CPF INVALIDO NAO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','57','PRAZO DE VENCIMENTO IN'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','60','VALOR DE IOF û ALTERAC'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','61','TITULO JA BAIXADO OU L'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','66','ALTERACAO NAO PERMITID'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','72','ENDERECO INVALIDO û SA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','73','BAIRRO INVALIDO û SACA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','74','CIDADE INVALIDA û SACA'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','75','SIGLA ESTADO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','76','CEP INVALIDO û SACADOR'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','81','ALTERACAO BLOQUEADA û'})
		aAdd(aSEB,{cFilSEB,'341','17','R','17','ALTERACAO DE DADOS REJEITADOS','01','87','ALTERACAO BLOQUEADA û'})
		aAdd(aSEB,{cFilSEB,'341','18','R','17','COB CONTR INSTR/ALT REJEIT/PEN','','',''})
		aAdd(aSEB,{cFilSEB,'341','19','R','19','CONF. RECEB. INSTRUCAO PROTEST','','',''})
		aAdd(aSEB,{cFilSEB,'341','20','R','21','CONF. RECEB. INST. SUST. PROTE','','',''})
		aAdd(aSEB,{cFilSEB,'341','21','R','21','CONF. RECEB. INSTR. NAO PROTES','','',''})
		aAdd(aSEB,{cFilSEB,'341','23','R','23','PROTESTO ENVIADO AO CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'341','24','R','16','INSTRUCAO DE PROTESTO REJEITAD','','',''})
		aAdd(aSEB,{cFilSEB,'341','25','R','25','ALEGACAO DO SACADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','26','R','26','TARIFA AVISO DE COBRANCA','','',''})
		aAdd(aSEB,{cFilSEB,'341','27','R','27','TARIFA DE EXTRATO POSICAO','','',''})
		aAdd(aSEB,{cFilSEB,'341','28','R','28','TARIFA DE RELACAO DAS LIQUIDAC','','',''})
		aAdd(aSEB,{cFilSEB,'341','29','R','29','TAR. MANUT. TITULOS VENCIDOS','','',''})
		aAdd(aSEB,{cFilSEB,'341','30','R','30','DEBITO MENSAL TARIFAS','','',''})
		aAdd(aSEB,{cFilSEB,'341','32','R','32','BAIXA POR TER SIDO PROTESTADO','','',''})
		aAdd(aSEB,{cFilSEB,'341','33','R','33','CUSTAS DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','34','R','34','CUSTAS DE SUSTACAO','','',''})
		aAdd(aSEB,{cFilSEB,'341','35','R','35','CUSTAS DE CARTORIO DISTRIB.','','',''})
		aAdd(aSEB,{cFilSEB,'341','36','R','35','CUSTAS DE EDITAL','','',''})
		aAdd(aSEB,{cFilSEB,'341','37','R','26','TARIFA DE EMISSAO DE BOLETO','','',''})
		aAdd(aSEB,{cFilSEB,'341','38','R','26','TARIFA DE INSTRUCAO','','',''})
		aAdd(aSEB,{cFilSEB,'341','39','R','26','TARIFA DE OCORRENCIAS','','',''})
		aAdd(aSEB,{cFilSEB,'341','40','R','30','TARIFA MENSAL EMISSAO BOLETOS','','',''})
		aAdd(aSEB,{cFilSEB,'341','41','R','30','DEBITO MENSAL - EXTRATO','','',''})
		aAdd(aSEB,{cFilSEB,'341','42','R','30','DEBITO MENSAL - OUTROS','','',''})
		aAdd(aSEB,{cFilSEB,'341','43','R','29','DEB MENSAL TAR-MANUT TIT VENCI','','',''})
		aAdd(aSEB,{cFilSEB,'341','44','R','30','DEB MENSAL TAR-OUTRAS OCORRENC','','',''})
		aAdd(aSEB,{cFilSEB,'341','45','R','30','DEB MENSAL TAR-PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'341','46','R','34','DEB MENSAL TAR-SUSTACAO PROTES','','',''})
		aAdd(aSEB,{cFilSEB,'341','47','R','09','BAIXA COM TRANSF P/COB DESCONT','','',''})
		aAdd(aSEB,{cFilSEB,'341','48','R','34','CUSTAS DE SUSTACAO JUDICIAL','','',''})
		aAdd(aSEB,{cFilSEB,'341','51','R','30','TAR MENSAL REF ENTR BCOS CORRE','','',''})
		aAdd(aSEB,{cFilSEB,'341','52','R','30','DEBITO MENSAL TARIFA - BAIXAS','','',''})
		aAdd(aSEB,{cFilSEB,'341','53','R','30','TAR MENSAL BXS BCOS CORRESP CA','','',''})
		aAdd(aSEB,{cFilSEB,'341','54','R','30','DEBITO MENSAL TARIFA - LIQUID.','','',''})
		aAdd(aSEB,{cFilSEB,'341','55','R','30','TAR MENSAL LIQ BCOS CORRESP CA','','',''})
		aAdd(aSEB,{cFilSEB,'341','56','R','30','CUSTAS DE IRREGULARIDADE','','',''})
		aAdd(aSEB,{cFilSEB,'341','57','R','03','INSTRUCAO CANCELADA','01','11','CANCELADA'})
		aAdd(aSEB,{cFilSEB,'341','59','R','06','BAIXA POR CREDITO EM C/C ATRAV','','',''})
		aAdd(aSEB,{cFilSEB,'341','60','R','03','ENTRADA REJEITADA CARNE','','',''})
		aAdd(aSEB,{cFilSEB,'341','61','R','27','TARIFA EMISSAO AVISO DE MOVIME','','',''})
		aAdd(aSEB,{cFilSEB,'341','62','R','30','DEBITO MENSAL DE TARIFA - AVIS','','',''})
		aAdd(aSEB,{cFilSEB,'341','63','R','16','TITULO SUSTADO JUDICIALMENTE','','',''})
		aAdd(aSEB,{cFilSEB,'341','64','R','02','ENTRADA CONFIRMADA COM RATEIO','','',''})
		aAdd(aSEB,{cFilSEB,'341','69','R','16','CHEQUE DEVOLVIDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','71','R','02','ENTRADA REGISTRADA, AGUARDANDO','','',''})
		aAdd(aSEB,{cFilSEB,'341','72','R','06','BAIXA POR CREDITO EM C/C ATRAV','','',''})
		aAdd(aSEB,{cFilSEB,'341','73','R','02','CONFIRMACAO DE ENTRADA NA COBR','','',''})
		aAdd(aSEB,{cFilSEB,'341','76','R','36','CHEQUE COMPENSADO','','',''})

	ElseIf cBanco == '399'
		aAdd(aSEB,{cFilSEB,'399','01','E','01','HSBC REMESSA','','',''})
		aAdd(aSEB,{cFilSEB,'399','02','E','02','HSBC PEDIDO DE BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'399','04','E','04','HSBC CONCESSAO ABATIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','05','E','05','HSBC CANCELAM ABATIMEN CONSEDI','','',''})
		aAdd(aSEB,{cFilSEB,'399','06','E','06','HSBC PRORROGACAO VENCIMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','07','E','07','HSBC ALT.CONTR.PARTICIPANTE','','',''})
		aAdd(aSEB,{cFilSEB,'399','08','E','08','HSBC ALTERACAO SEU NUMERO','','',''})
		aAdd(aSEB,{cFilSEB,'399','09','E','09','HSBC PROTESTAR','','',''})
		aAdd(aSEB,{cFilSEB,'399','10','E','10','SUSTAR INSTRUCAO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','19','P','19','HSBC INSTR.AUTOM.PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','37','P','32','HSBC BAIXA TITULO PROTESTADO','','',''})
		aAdd(aSEB,{cFilSEB,'399','02','R','02','HSBC ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','01','VALOR DO DESCONTO NAO INFORMADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','02','AGENCIA INCORRETA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','03','CEP SACADO INCORRETO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','04','CADASTRO DO CEDENTE NAO ACEITA BANCO CORRESPONDENTE'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','05','TIPO MOEDA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','06','PRAZO DE PROTESTO INDEFINIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','07','DATA DE VENCIMENTO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','08','NOSSO NUMERO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','09','TAXA MENSAL DE MORA ACIMA DO PERMITIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','10','TAXA DE MULTA ACIMA DO PERMITIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','11','DATA LIMITE DE DESCONTO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','12','CEP INVALIDO/INEXISTENCIA DE AG. HSBC'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','13','TAXA DE MULTA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','14','VALOR DIARIO DE MULTA NA INFORMADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','15','QTD DIAS APOS VENCIMENTO PARA INCIDENCIA DA MULTA NAO INFORM'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','16','OUTRAS IRREGULARIDADES'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','17','DATA DE INICIO DA MULTA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','18','NOSSO NUMERO JA EXISTENTE'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','19','VALOR INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','20','AUSENCIA CDP/ENDERECO/CNPJ OU SACADOR AVALISTA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','21','TITULO SEM BORDERO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','22','NUMERO DA CONTA DO CEDENTE NAO CADASTRADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','24','CONDICAO DE DESCONTO NAO PERMITIDA PARA TITULO EM GARANTIA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','25','UTILIZADA MAIS DE UMA INSTRUCAO DE MULTA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','26','AUSENCIA DO ENDERECO DO SACADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','27','CEP INVALIDO DO SACADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','28','AUSENCIA DO CPF/CNPJ DO SACADO EM TITULO COM INSTRUCAO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','29','AGENCIA CEDENTE INFORMADO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','30','NUMERO DA CONTA DO CEDENTE INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','31','CONTRATO GARANTIA NAO CADASTRADO / INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','32','TIPO DE CARTEIRA INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','33','CONTA CORRENTE DO CEDENTE NAO COMPATIVEL'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','34','FAIXA DE APLICACAO NAO CADASTRADA/INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','35','NOSSO NUMERO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','36','DATA DE EMISSAO DO TITULO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','37','VALOR DO TITULO ACIMA DE CINCO MILHOES'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','38','DATA DESCONTA MENOR QUE DATA EMISSAO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','39','ESPECIE INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','40','AUSENCIA NOME SACADOR AVALISTA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','41','DATA DE INICIO MULTA MENOR QUE DATA DE EMISSAO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','42','QUANTIDADE DE MOEDA VARIAVEL INVALIDA'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','43','CONTROLE DO PARTICIPANTE INVALIDO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','44','NOSSO NUMERO DUPLICADO'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','45','TITULO NO ACEITO PARA COMPOR A CARTEIRA DE GARANTIAS'})
		aAdd(aSEB,{cFilSEB,'399','03','R','03','HSBC TITULOS REJEITADOS','01','23','INSTRUCAO NAO PERMITIDA'})
		aAdd(aSEB,{cFilSEB,'399','06','R','06','HSBC LIQUIDACAO NORMAL','','',''})
		aAdd(aSEB,{cFilSEB,'399','07','R','07','HSBC LIQUIDACAO POR CONTA','','',''})
		aAdd(aSEB,{cFilSEB,'399','09','R','09','HSBC BAIXA AUTOMATICA','','',''})
		aAdd(aSEB,{cFilSEB,'399','10','R','10','HSBC BAIXADO CONF.INSTR.','','',''})
		aAdd(aSEB,{cFilSEB,'399','11','R','11','HSBC TIT. EM SER','','',''})
		aAdd(aSEB,{cFilSEB,'399','12','R','12','HSBC ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'399','13','R','13','HSBC ABATIMENTO CANCELADO','','',''})
		aAdd(aSEB,{cFilSEB,'399','14','R','14','HSBC VENCTO. PRORROGADO','','',''})
		aAdd(aSEB,{cFilSEB,'399','15','R','08','LIQUIDACAO EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'399','17','R','23','ENTREGUE EM CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'399','18','R','19','INSTRUCAO DE PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','23','R','21','HSBC CANCELAMENTO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'399','31','R','36','HSBC LIQ NORMAL CH/COMP/...','','',''})
		aAdd(aSEB,{cFilSEB,'399','32','R','37','HSBC LIQ CARTORIO  EM CHEQUE','','',''})
		aAdd(aSEB,{cFilSEB,'399','33','R','38','HSBC LIQUID POR CONTA EM CHEQU','','',''})
		aAdd(aSEB,{cFilSEB,'399','37','R','32','HSBC BAIXA TITULO PROTESTADO','','',''})
		aAdd(aSEB,{cFilSEB,'399','39','R','32','HSBC BAIXA TITULO PROTESTADO','','',''})
		aAdd(aSEB,{cFilSEB,'399','69','R','35','HSBC CUSTAS DE CARTORIO','','',''})

	ElseIf cBanco == '745'
		aAdd(aSEB,{cFilSEB,'745','01','E','01','REMESSA','','',''})
		aAdd(aSEB,{cFilSEB,'745','04','E','04','ABATIMENTO','','','ABATIMENTO'})
		aAdd(aSEB,{cFilSEB,'745','06','E','06','ALTERACAO DE VENCIMENTO','','','ALTERACAO DE VENCIMENTO'})
		aAdd(aSEB,{cFilSEB,'745','09','E','09','PROTESTO IMEDIATO','','',''})
		aAdd(aSEB,{cFilSEB,'745','11','E','11','SUSTAR PROTESTO','11','11',''})
		aAdd(aSEB,{cFilSEB,'745','02','R','02','ENTRADA CONFIRMADA','','',''})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','09','NOSSO NUMERO DUPLICADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','11','FORMA DE CADASTRO DO TITULO INVALIDO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','15','CARACTERISTICA DE COBRANCA INCOMPLETA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','16','ID. REGISTRO DE DADOS DIFERENTE DE 1'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','18','VENCIMENTO FORA DO PRAZO DE OPERACAO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','19','REJEITADO POR PROCESSO DE CREDITO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','22','NUMERO BANCARIO INVALIDO (POS.63)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','23','NOSSO NUMERO JA VALIDADO ANTERIORMENTE'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','24','CODIGO DE CARTEIRABINVALIDO (POS.108)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','25','ID. OCORRENCIA INVALIDO (POS.109)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','26','SEU NUMERO INVALIDO (POS.111)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','27','DATA DE VENCIMENTO INVALIDA (POS 121)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','28','VALOR DO TITULO INVALIDO (POS.127)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','29','BANCO COBRADOR INVALIDO (POS.140)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','30','DESCONTO A CONCEDER NAO CONFERE'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','31','TIPO DE EMISSAO INVALIDA (POS.148)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','32','CODIGO DE ACEITE DIFERENTE DE N (POS.150)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','33','DATA DE EMISSAO INVALIDA (POS.151)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','34','COD. INSTRUCAO INVALIDO (POS.157)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','38','PRAZO PARA PROTESTO INVALIDO (TITULO A VENCER)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','39','PEDIDO DE PROTESTO NAO PERMITIDO PARA O TITULO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','41','TIPO OU N. INSCRICAO SACADA INVALIDA (POS.219)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','43','FALTA NOME SACADO (POS.235)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','44','FALTA ENDERECO DO SACADO (POS.275)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','46','CEP INVALIDO OU PRACA NAO COBERTA (POS.275)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','47','FALTA CIDADE DO SACADO (POS.335)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','48','FALTA SIGLA DA UF DO SACADO (POS.350)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','49','SIGLA UF INCOMPATIVEL COM O CEP'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','50','NUMERO DE SEQ. DE DADOS INVALIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','52','ID. DE TRAILLER DIFERENTE DE 9'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','56','PORTFOLIO DESTINO INEXISTENTE'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','57','CARTEIRA INCOMPATIVEL (POS.108)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','58','DIAS DE INSTRUCAO INVALIDOS (POS.159)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','62','VALOR DO DESCONTO/ IOF MAIOR QUE O VALOR DO TITULO OU ZERADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','63','DATA DO DESCONTO INVALIDA NA INCLUSAO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','68','ALTERACAO INVALIDA (TITULO CAUCIONADO)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','69','DATA DESCONTO INVALIDA NA ALTERACAO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','71','ALTERACAO PARA TITULO NAO CADASTRADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','74','ALTERACAO PARA TITULO JA BAIXADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','75','ALTERACAO PARA TITULO JA PAGO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','76','INSTRUCAO PARA PROTESTO DE TITULO JA EM CARTORIO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','78','ALTERACAO DE VENCIMENTO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','79','ALTERACAO PARA DESCONTO POR ANTECIPACAO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','80','DATA DE INSTRUCAO DE DESCONTO INVALIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','81','INCLUSAO DE TITULO JA CADASTRADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','84','CONTA INFORMADA INVALIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','86','ENDERECO DO SACADO NA WEB INVALIDO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','89','TIPO DE MOEDA INVALIDA (POS.394)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','90','PRORROGACAO NAO PERMITIDA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','91','DATA PARA PGTO. SEM JUROS INVALIDA (POS.386)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','92','PEDIDO SUSTACAO P/ TITULO S/ INSTRUCAO PROTESTO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','93','ALTERACAO PARA TITULO JA PROTESTADO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','94','ABATIMENTO MAIOR QUE O VALOR LIQUIDO (POS.206)'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','95','VENCIMENTO NAO INFORMADO NA ALTERACAO'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','96','ALTERACAO COM VENCIMENTO MENOR QUE A ATUAL'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','97','FALTA DATA DE DESCONTO EM ALTERACAO DESTA DATA'})
		aAdd(aSEB,{cFilSEB,'745','03','R','03','TRANSACAO REJEITADA','01','99','INSTRUCAO DE PROTESTO NAO EFETIVADA FALTA DE CARTA DE PROV.'})
		aAdd(aSEB,{cFilSEB,'745','06','R','06','LIQUIDACAO/PAGAMENTO','','',''})
		aAdd(aSEB,{cFilSEB,'745','07','R','04','DESCONTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','09','09','COMANDADA PELO BANCO'})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','10','10','COMANDADA CLIENTE/CNAB'})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','11','11','COMANDADA CLIENTE ON-LINE'})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','12','12','DECURSO DE PRAZO CLIENTE'})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','13','13','DECURSO DE PRAZO BANCO'})
		aAdd(aSEB,{cFilSEB,'745','10','R','09','BAIXA','14','14','PROTESTADO'})
		aAdd(aSEB,{cFilSEB,'745','11','R','11','EM SER (A VENCER)','','',''})
		aAdd(aSEB,{cFilSEB,'745','12','R','12','ABATIMENTO CONCEDIDO','','',''})
		aAdd(aSEB,{cFilSEB,'745','14','R','14','VENCIMENTO ALTERADO','','',''})
		aAdd(aSEB,{cFilSEB,'745','15','R','08','PAGO EM CARTORIO','08','08','EM CARTORIO'})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','','',''})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','02','02','POR CONTA'})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','03','03','NO PROPRIO BANCO'})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','04','04','COMPENSACAO ELETRONICA (CEL)'})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','05','05','COMPENSACAO CONVENCIONAL'})
		aAdd(aSEB,{cFilSEB,'745','17','R','10','LIQUIDACAO APOS BAIXA','07','07','APOS FERIADO LOCAL'})
		aAdd(aSEB,{cFilSEB,'745','19','R','19','RECEBIMENTO INSTR.PROTESTO.','','',''})
		aAdd(aSEB,{cFilSEB,'745','20','R','20','SUSTENTACAO PROTESTO','','',''})
		aAdd(aSEB,{cFilSEB,'745','23','R','23','ENVIADO AO CARTORIO','','',''})
		aAdd(aSEB,{cFilSEB,'745','34','R','20','TITULO RETIRADO DE CARTORIO','','',''})
	EndIf

	If Len(aSEB) > 0
		For nI := 1 To Len(aSEB)
			If !SEB->(DbSeek(PadR(aSEB[nI,1],nTamFil)+PadR(aSEB[nI,2],nTamBco)+PadR(aSEB[nI,3],nTamRefb)+PadR(aSEB[nI,4],nTamTipo)))
				SEB->(RecLock("SEB",.T.))
				For nJ:=1 to Len(aEstrut)
					If SEB->(FieldPos(aEstrut[nJ]))> 0
						SEB->(FieldPut(FieldPos(aEstrut[nJ]),aSEB[nI,nJ]))
					EndIf
				Next nJ
				SEB->(MsUnlock())
			EndIf
		Next nI
	EndIf

	aAdd(aSEB,{cFilSEB,cBanco,'00','P','06','Credito ou Debito Efetivado   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'01','P','03','Insuficiencia de Fundos       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'02','P','03','Credito ou Debito Cancelado   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'03','P','01','Debito Autorizado pela Agencia','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AA','P','03','Controle Invalido             ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AB','P','03','Tipo de Operacao Invalido     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AC','P','03','Tipo de Servico Invalido      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AD','P','03','Forma de Lancamento Invalida  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AE','P','03','Tipo/Num de Inscricao Invalido','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AF','P','03','Codigo de Convenio Invalido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AG','P','03','Agencia/Conta Invalido        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AH','P','03','Nº Seqüencial Reg. Invalido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AI','P','03','Cod Segmento Detalhe Invalido ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AJ','P','03','Tipo de Movimento Invalido    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AK','P','03','Cod Camara Comp.Bco Invalido  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AL','P','03','Cod Banco Favorecido Invalido ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AM','P','03','Age Mantenedora Conta Invalida','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AN','P','03','Conta/DV Invalido             ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AO','P','03','Nome do Favorecido Invalido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AP','P','03','Data Lancamento Invalido      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AQ','P','03','Tipo/Quantidade Moeda Invalido','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AR','P','03','Valor do Lancamento Invalido  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AS','P','03','Aviso ao Favorecido Invalida  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AT','P','03','Numero de Inscricao Invalido  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AU','P','03','Logradouro Nao Informado      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AV','P','03','Nº Nao Informado              ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AW','P','03','Cidade Nao Informada          ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AX','P','03','CEP Invalido                  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AY','P','03','Sigla do Estado Invalida      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'AZ','P','03','Codigo Nome Banco Invalido    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BA','P','03','Codigo Nome Age. Nao Informado','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BB','P','03','Seu Numero Invalido           ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BC','P','03','Nosso Numero Invalido         ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BD','P','02','Inclusao Efetuada com Sucesso ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BE','P','02','Alteracao Efetuada com Sucesso','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BF','P','02','Exclusao Efetuada com Sucesso ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BG','P','03','Age.Conta Impedida Legalmente ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BH','P','03','Empresa nao pagou salario     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BI','P','03','Falecimento do mutuario       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BJ','P','03','Remessa mutuario nao informado','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BK','P','03','Remessa vencimento n informado','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BL','P','03','Valor da parcela invalida     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BM','P','03','Contrato invalido             ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BN','P','02','Consignacao Inclu. com Sucesso','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BO','P','02','Consignacao Alter. com Sucesso','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BP','P','02','Consignacao Exclu. com Sucesso','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BQ','P','02','Consignacao Liqui. com Sucesso','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BR','P','02','Reativacao Efetuada           ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'BS','P','02','Suspensao Efetuada            ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CA','P','03','Cod.Bar. - Cod Bco invalido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CB','P','03','Cod.Bar. - Cod Moeda invalido ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CC','P','03','Cod.Bar. - DV Geral invalido  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CD','P','03','Cod.Bar. - Val invalido       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CE','P','03','Cod.Bar. - Cpo Livre invalido ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CF','P','03','Valor do Documento Invalido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CG','P','03','Valor do Abatimento Invalido  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CH','P','03','Valor do Desconto Invalido    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CI','P','03','Valor de Mora Invalido        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CJ','P','03','Valor da Multa Invalido       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CK','P','03','Valor do IR Invalido          ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CL','P','03','Valor do ISS Invalido         ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CM','P','03','Valor do IOF Invalido         ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CN','P','03','Valor Outras Deducoes Invalido','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CO','P','03','Valor Outros Acrescim Invalido','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'CP','P','03','Valor do INSS Invalido        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HA','P','03','Lote Nao Aceito               ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HB','P','03','Inscricao da Empresa Invalida ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HC','P','03','Convenio com a Empresa Inexist','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HD','P','03','Age/Conta Invalido            ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HE','P','03','Tipo de Servico Invalido      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HF','P','03','Conta com saldo Insuficiente  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HG','P','03','Lote Servico Fora de Sequencia','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HH','P','03','Lote de Servico Invalido      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HI','P','03','Arquivo nao aceito            ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HJ','P','03','Tipo de Registro Invalido     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HK','P','03','Codigo Rem/Ret Invalido       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HL','P','03','Versao de layout invalida     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HM','P','03','Mutuario nao identificado     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HN','P','03','Beneficio n permite emprestimo','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HO','P','03','Beneficio cessado/suspenso    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HP','P','03','Beneficio possui rep. legal   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HQ','P','03','Beneficio e do tipo PA        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HR','P','03','Quantidade contratos excedida ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HS','P','03','Beneficio nao pertence ao Bco ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HT','P','03','Inicio desconto ultrapassado  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HU','P','03','Numero da parcela invalida    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HV','P','03','Quantidade de parcela invalida','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HW','P','03','Margem excedida dentro prazo  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HX','P','03','Emprestimo ja cadastrado      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HY','P','03','Emprestimo inexistente        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'HZ','P','03','Emprestimo ja encerrado       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H1','P','03','Arquivo sem trailer           ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H2','P','03','Mutuario sem credito          ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H3','P','03','Nao descontado outros motivos ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H4','P','03','Retorno de Credito nao pago   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H5','P','03','Cancel. emprestimo retroativo ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H6','P','03','Outros Motivos de Glosa       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H7','P','03','Margem excedida acima do prazo','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H8','P','03','Mutuario desligado empregador ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'H9','P','03','Mutuario afastado por licenca ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IA','P','03','Primeiro nom mutuario difeente','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IB','P','03','Beneficio suspenso APS/Sisobi ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IC','P','03','Beneficio susp. depende calc  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ID','P','03','Beneficio susp. Insp/Audit    ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IE','P','03','Beneficio bloq emprestimo Bene','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IF','P','03','Beneficio bloq emprestimo TBM ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IG','P','03','Beneficio fase PA/desdobrament','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IH','P','03','Beneficio cessado por obito   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'II','P','03','Beneficio cessado por fraude  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IJ','P','03','Beneficio cessado por concessa','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IK','P','03','Beneficio cessado estatutario ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IL','P','03','Emprestimo suspenso pela APS  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IM','P','03','Emprestimo cancelado pelo bco ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IN','P','03','Credito transformado em PAB   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IO','P','03','Termino consignacao alterado  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IP','P','03','Fim emprestimo durante Suspens','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IQ','P','03','Emprestimo suspenso pelo banco','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'IR','P','03','Nao averbacao de contrato     ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'TA','P','03','Lote Nao Aceito Totais diferen','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YA','P','03','Titulo Nao Encontrado         ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YB','P','03','Identificador Registro Invalid','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YC','P','03','Codigo Padrao Invalido        ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YD','P','03','Codigo de Ocorrencia Invalido ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YE','P','03','Complemento Ocorrencia Invalid','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'YF','P','03','Alegacao ja Informada         ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZA','P','03','Age/Conta Favore Substituida  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZB','P','03','Divergencia nome beneficiario ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZC','P','02','Confirmacao Antecipacao Valor ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZD','P','02','Antecipacao parcial de valor  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZE','P','03','Titulo bloqueado na base      ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZF','P','03','Sis em contingencia vl maior  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZG','P','03','Sis em contingencia vencido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZH','P','03','Sis em contingencia indexado  ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZI','P','03','Beneficiario divergente       ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZJ','P','03','Limit pag parciais excedido   ','','',''})
	aAdd(aSEB,{cFilSEB,cBanco,'ZK','P','03','Boleto ja liquidado           ','','',''})

	If Len(aSEB) > 0
		For nI := 1 To Len(aSEB)
			If !SEB->(DbSeek(PadR(aSEB[nI,1],nTamFil)+PadR(aSEB[nI,2],nTamBco)+PadR(aSEB[nI,3],nTamRefb)+PadR(aSEB[nI,4],nTamTipo)))
				SEB->(RecLock("SEB",.T.))
				For nJ:=1 to Len(aEstrut)
					If SEB->(FieldPos(aEstrut[nJ]))> 0
						SEB->(FieldPut(FieldPos(aEstrut[nJ]),aSEB[nI,nJ]))
					EndIf
				Next nJ
				SEB->(MsUnlock())
			EndIf
		Next nI
	EndIf


SEB->(RestArea(aArea))
Return



//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuSEJ
Função para popular tabela SEJ na inicialização do SIGAFIN
Facilitador para uso do CNAB

@sample FinaAtuSEJ()
@author Mauricio Pequim Jr
@since 17/05/13
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Static Function FinaAtuSEJ(cBanco)
Local nI			:= 0
Local nJ			:= 0
Local aEstrut		:= {}
Local aSEJ			:= {}
Local aArea		:= SEJ->(GetArea())
Local cFilSEJ		:= xFilial("SEJ")
Local nTamFil		:= TamSx3("EJ_FILIAL")[1]
Local nTamBco		:= TamSx3("EJ_BANCO")[1]
Local nTamOcor	:= TamSx3("EJ_OCORBCO")[1]

Default cBanco	:= ""


DbSelectArea("SEJ")
SEJ->(DbSetOrder(1)) //EJ_FILIAL+EJ_BANCO+EJ_OCORBCO
SEJ->(DbGoTop())

If !(SEJ->(MsSeek(cFilAnt + cBanco)))

	aEstrut := {"EJ_FILIAL","EJ_BANCO","EJ_OCORBCO","EJ_OCORSIS","EJ_DESC","EJ_DEBCRE"}

	If cBanco == '001'
		aAdd(aSEJ,{cFilSEJ,'001','101','CHQ','CHEQUES','D'})
		aAdd(aSEJ,{cFilSEJ,'001','102','ENC','ENCARGOS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','103','EST','ESTORNOS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','104','LAV','LANCAMENTOS AVISADOS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','105','ENC','TARIFAS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','106','LAV','APLICACAO','D'})
		aAdd(aSEJ,{cFilSEJ,'001','107','LAV','EMPREST / FINANCIAM','D'})
		aAdd(aSEJ,{cFilSEJ,'001','108','LAV','CAMBIO','D'})
		aAdd(aSEJ,{cFilSEJ,'001','109','ENC','CPMF','D'})
		aAdd(aSEJ,{cFilSEJ,'001','110','ENC','IOF','D'})
		aAdd(aSEJ,{cFilSEJ,'001','111','ENC','IMPOSTO DE RENDA','D'})
		aAdd(aSEJ,{cFilSEJ,'001','112','COB','PAGAM FORNECEDORES','D'})
		aAdd(aSEJ,{cFilSEJ,'001','113','COB','PAGAM FUNCIONARIOS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','114','COB','SAQUE ELETRONICO','D'})
		aAdd(aSEJ,{cFilSEJ,'001','115','LAV','ACOES','D'})
		aAdd(aSEJ,{cFilSEJ,'001','116','LAV','SEGUROS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','117','LAV','TRANSF ENTRE CONTAS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','118','EST','DEVOL DA COMPENSACAO','D'})
		aAdd(aSEJ,{cFilSEJ,'001','119','DEV','DEVOLUCAO DE CHEQUES','D'})
		aAdd(aSEJ,{cFilSEJ,'001','120','LAV','TRANSF INTERBANCARIA','D'})
		aAdd(aSEJ,{cFilSEJ,'001','121','COB','DESCONTO DE DUPLICAT','D'})
		aAdd(aSEJ,{cFilSEJ,'001','122','LAV','OC/AEROPS','D'})
		aAdd(aSEJ,{cFilSEJ,'001','201','DEP','DEPOSITOS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','202','COB','COBRANCA','C'})
		aAdd(aSEJ,{cFilSEJ,'001','203','DEV','DEVOLUCAO DE CHEQUES','C'})
		aAdd(aSEJ,{cFilSEJ,'001','204','EST','ESTORNOS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','205','LAV','LANCAMENTOS AVISADOS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','206','LAV','RESGATE DE APLICACOE','C'})
		aAdd(aSEJ,{cFilSEJ,'001','207','LAV','EMPRESTIMO / FINANCI','C'})
		aAdd(aSEJ,{cFilSEJ,'001','208','LAV','CAMBIO','C'})
		aAdd(aSEJ,{cFilSEJ,'001','209','DEP','TRANSF INTERBANCARIA','C'})
		aAdd(aSEJ,{cFilSEJ,'001','210','LAV','ACOES','C'})
		aAdd(aSEJ,{cFilSEJ,'001','211','LAV','DIVIDENDOS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','212','LAV','SEGURO','C'})
		aAdd(aSEJ,{cFilSEJ,'001','213','DEP','TRANSF ENTRE CONTAS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','214','DEP','DEPOSITOS ESPECIAIS','C'})
		aAdd(aSEJ,{cFilSEJ,'001','215','EST','DEVOLUCAO COMPENSACA','C'})
		aAdd(aSEJ,{cFilSEJ,'001','216','DEP','OCT','C'})

	ElseIf cBanco == "237"
		aAdd(aSEJ,{cFilSEJ,'237','101','CHQ','CHEQUES','D'})
		aAdd(aSEJ,{cFilSEJ,'237','102','ENC','ENCARGOS','D'})
		aAdd(aSEJ,{cFilSEJ,'237','103','EST','ESTORNOS','D'})
		aAdd(aSEJ,{cFilSEJ,'237','104','LAV','LANCAMENTO AVISADO','D'})
		aAdd(aSEJ,{cFilSEJ,'237','105','ENC','TARIFAS','D'})
		aAdd(aSEJ,{cFilSEJ,'237','106','LAV','APLICACAO','D'})
		aAdd(aSEJ,{cFilSEJ,'237','107','LAV','EMPRESTIMO/FINANCIAM','D'})
		aAdd(aSEJ,{cFilSEJ,'237','108','LAV','CAMBIO','D'})
		aAdd(aSEJ,{cFilSEJ,'237','109','ENC','CPMF','D'})
		aAdd(aSEJ,{cFilSEJ,'237','110','ENC','IOF','D'})
		aAdd(aSEJ,{cFilSEJ,'237','111','ENC','IMPOSTO DE RENDA','D'})
		aAdd(aSEJ,{cFilSEJ,'237','112','COB','PAGAMENTO FORNECEDOR','D'})
		aAdd(aSEJ,{cFilSEJ,'237','113','LAV','PAGAMENTOS FUNCIONAR','D'})
		aAdd(aSEJ,{cFilSEJ,'237','114','LAV','SAQUE ELETRONICO','D'})
		aAdd(aSEJ,{cFilSEJ,'237','115','LAV','ACOES','D'})
		aAdd(aSEJ,{cFilSEJ,'237','117','LAV','TRANSF ENTRE CONTAS','D'})
		aAdd(aSEJ,{cFilSEJ,'237','118','DEV','DEVOLUCAO COMPENSACA','D'})
		aAdd(aSEJ,{cFilSEJ,'237','119','DEV','DEVOLUCAO CHEQUES','D'})
		aAdd(aSEJ,{cFilSEJ,'237','120','LAV','TRANSF INTERBANC DOC','D'})
		aAdd(aSEJ,{cFilSEJ,'237','121','LAV','ANTECIPACAO A FORNEC','D'})
		aAdd(aSEJ,{cFilSEJ,'237','122','LAV','OC / AEROPS','D'})
		aAdd(aSEJ,{cFilSEJ,'237','201','DEP','DEPOSITOS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','202','COB','LIQUIDO DE COBRANCA','C'})
		aAdd(aSEJ,{cFilSEJ,'237','203','DEV','DEVOLUCAO CHEQUES','C'})
		aAdd(aSEJ,{cFilSEJ,'237','204','EST','ESTORNOS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','205','LAV','LANCAMENTO AVISADO','C'})
		aAdd(aSEJ,{cFilSEJ,'237','206','LAV','RESGATE / APLICACAO','C'})
		aAdd(aSEJ,{cFilSEJ,'237','207','LAV','EMPRESTIMO/FINANCIAM','C'})
		aAdd(aSEJ,{cFilSEJ,'237','208','LAV','CAMBIO','C'})
		aAdd(aSEJ,{cFilSEJ,'237','209','LAV','TRANSF INTERBANC DOC','C'})
		aAdd(aSEJ,{cFilSEJ,'237','210','LAV','ACOES','C'})
		aAdd(aSEJ,{cFilSEJ,'237','211','LAV','DIVIDENDOS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','212','LAV','SEGUROS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','213','LAV','TRANFER.ENTRE CONTAS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','214','DEP','DEPOSITO ESPECIAIS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','215','DEV','DEVOLUCAO COMPENSACA','C'})
		aAdd(aSEJ,{cFilSEJ,'237','216','LAV','OCT','C'})
		aAdd(aSEJ,{cFilSEJ,'237','217','LAV','PAGAMENTO FORNECEDOR','C'})
		aAdd(aSEJ,{cFilSEJ,'237','218','LAV','PAGAMENTO DIVERSOS','C'})
		aAdd(aSEJ,{cFilSEJ,'237','219','LAV','PAGAMENTOS SALARIOS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','101','CHQ','CHEQUES','D'})

	ElseIf cBanco == "341"
		aAdd(aSEJ,{cFilSEJ,'341','102','ENC','ENCARGOS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','103','EST','ESTORNOS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','104','LAV','LANCAMENTOS AVISADOS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','105','ENC','TARIFAS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','106','LAV','APLICACAO','D'})
		aAdd(aSEJ,{cFilSEJ,'341','107','LAV','EMPREST / FINANCIAM','D'})
		aAdd(aSEJ,{cFilSEJ,'341','108','LAV','CAMBIO','D'})
		aAdd(aSEJ,{cFilSEJ,'341','109','ENC','CPMF','D'})
		aAdd(aSEJ,{cFilSEJ,'341','110','ENC','IOF','D'})
		aAdd(aSEJ,{cFilSEJ,'341','111','ENC','IMPOSTO DE RENDA','D'})
		aAdd(aSEJ,{cFilSEJ,'341','112','COB','PAGAM FORNECEDORES','D'})
		aAdd(aSEJ,{cFilSEJ,'341','113','COB','PAGAM FUNCIONARIOS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','114','COB','SAQUE ELETRONICO','D'})
		aAdd(aSEJ,{cFilSEJ,'341','115','LAV','ACOES','D'})
		aAdd(aSEJ,{cFilSEJ,'341','116','LAV','SEGUROS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','117','LAV','TRANSF ENTRE CONTAS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','118','EST','DEVOL DA COMPENSACAO','D'})
		aAdd(aSEJ,{cFilSEJ,'341','119','DEV','DEVOLUCAO DE CHEQUES','D'})
		aAdd(aSEJ,{cFilSEJ,'341','120','LAV','TRANSF INTERBANCARIA','D'})
		aAdd(aSEJ,{cFilSEJ,'341','121','COB','DESCONTO DE DUPLICAT','D'})
		aAdd(aSEJ,{cFilSEJ,'341','122','LAV','OC/AEROPS','D'})
		aAdd(aSEJ,{cFilSEJ,'341','201','DEP','DEPOSITOS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','202','COB','COBRANCA','C'})
		aAdd(aSEJ,{cFilSEJ,'341','203','DEV','DEVOLUCAO DE CHEQUES','C'})
		aAdd(aSEJ,{cFilSEJ,'341','204','EST','ESTORNOS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','205','LAV','LANCAMENTOS AVISADOS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','206','LAV','RESGATE DE APLICACOE','C'})
		aAdd(aSEJ,{cFilSEJ,'341','207','LAV','EMPRESTIMO / FINANCI','C'})
		aAdd(aSEJ,{cFilSEJ,'341','208','LAV','CAMBIO','C'})
		aAdd(aSEJ,{cFilSEJ,'341','209','DEP','TRANSF INTERBANCARIA','C'})
		aAdd(aSEJ,{cFilSEJ,'341','210','LAV','ACOES','C'})
		aAdd(aSEJ,{cFilSEJ,'341','211','LAV','DIVIDENDOS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','212','LAV','SEGURO','C'})
		aAdd(aSEJ,{cFilSEJ,'341','213','DEP','TRANSF ENTRE CONTAS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','214','DEP','DEPOSITOS ESPECIAIS','C'})
		aAdd(aSEJ,{cFilSEJ,'341','215','EST','DEVOLUCAO COMPENSACA','C'})
		aAdd(aSEJ,{cFilSEJ,'341','216','DEP','OCT','C'})
	EndIf

	If Len(aSEJ) > 0
		For nI := 1 To Len(aSEJ)
			If !SEJ->(DbSeek(PadR(aSEJ[nI,1],nTamFil)+PadR(aSEJ[nI,2],nTamBco)+PadR(aSEJ[nI,3],nTamOcor)))
				SEJ->(RecLock("SEJ",.T.))
				For nJ:=1 to Len(aEstrut)
					If SEJ->(FieldPos(aEstrut[nJ]))> 0
						SEJ->(FieldPut(FieldPos(aEstrut[nJ]),aSEJ[nI,nJ]))
					EndIf
				Next nJ
				SEJ->(MsUnlock())
			EndIf
		Next nI
	Endif

EndIf

SEJ->(RestArea(aArea))
Return

*=====================================================================================================================================*

/*/{Protheus.doc} GRAVALOG
//TODO GRAVAR INFORMAÇÕES NA TABELA LOG Z0E
@author Leosanlim
@since 30/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cTabAlias, characters, descricao
@param nReg, numeric, descricao
@type function
/*/
STATIC FUNCTION GRAVALOG(cTabAlias, nReg, nOpc)
	*=====================================================================================================================================*
	LOCAL cTable := AllTrim("Z0E")+SUBSTR(ALLTRIM(RetSqlName(cTabAlias)),4,LEN(ALLTRIM(RetSqlName(cTabAlias))))+"_LOG"
	Local cRDD := "TOPCONN"
	LOCAL aStru := {}
	Local cNamUser := LEFT(UsrFullName( RetCodUsr() ), 60)//Retorna o nome do usuario
	Local cQuery 

	if Select(cTable) > 0
		(cTable)->(DBCLOSEAREA())
	EndIf

	IF nOpc == 3

		//MSGINFO("Alias:"+cTable+" Registro"+cValToChar(nReg)+" Opção:"+cValToChar(nOpc),"Incluir")
		//MSGINFO("Alias:"+cTable+" Registro"+cValToChar(nReg)+" Opção:"+cValToChar(nOpc),"Alteração")
		AbreLogF(cTable,"")

		(cTabAlias)->(dbSetOrder(1))
		(cTabAlias)->(dbGoTo(nReg))

		SX3->(DbSetOrder(1))
		SX3->(DbSeek( cTabAlias))

		while SX3->(!eof()) .and. SX3->X3_ARQUIVO == cTabAlias	
			cQuery := " SELECT * FROM " +cTable 
			cQuery += " WHERE Z0E_CPO = '" + SX3->X3_CAMPO + "'"
			cQuery += " AND Z0E_RECNO = "+STR(nReg)+""
			cQuery += " ORDER BY Z0E_DT_LOG, Z0E_HR_LOG DESC"

			IF AbreQuery(cQuery,"QryLOG") 
					
					IF AllTrim(cValToChar((cTabAlias)->&(SX3->X3_CAMPO))) <> AllTrim(QryLOG->Z0E_VL_ATU)
						(cTable)->(dbAppend())
						(cTable)->Z0E_ALIAS  := cTabAlias						//ALIAS 
						(cTable)->Z0E_CPO    := SX3->X3_CAMPO 					// CAMPO
						(cTable)->Z0E_VL_ATU := AllTrim(cValToChar((cTabAlias)->&(SX3->X3_CAMPO)))  	// VALOR ATUAL
						(cTable)->Z0E_VL_ANT := QryLOG->Z0E_VL_ATU 				//VALOR ANTERIOR
						(cTable)->Z0E_DT_LOG := DATE()							//DATA QUE FOI REALIZADO A ALTERAÇÃO
						(cTable)->Z0E_HR_LOG := StrTran( TIME(),":","" ) 		//HORARIO DA ALTERAÇÃO
						(cTable)->Z0E_TP_LOG := cValToChar(nOpc)  				//TIPO DE OPERAÇÃO (ALTERAÇÃO)
						(cTable)->Z0E_US_LOG := cNamUser 						//NOME DO USUARIO QUE REALIZOU A ALTERAÇÃO
						(cTable)->Z0E_RECNO  := nReg				    //RECNO DO REGISTRO
						(cTable)->(dbUnlock())
					ENDIF
			
			ELSE				
				(cTable)->(dbAppend())
				(cTable)->Z0E_ALIAS  := cTabAlias						//ALIAS 
				(cTable)->Z0E_CPO    := SX3->X3_CAMPO 					//CAMPO
				(cTable)->Z0E_VL_ATU := cValToChar((cTabAlias)->&(SX3->X3_CAMPO))  	//VALOR ATUAL
				(cTable)->Z0E_VL_ANT := "" 								//VALOR ANTERIOR
				(cTable)->Z0E_DT_LOG := DATE()							//DATA QUE FOI REALIZADO A ALTERAÇÃO
				(cTable)->Z0E_HR_LOG := StrTran( TIME(),":","" ) 		//HORARIO DA ALTERAÇÃO
				(cTable)->Z0E_TP_LOG := cValToChar(nOpc)  				//TIPO DE OPERAÇÃO (ALTERAÇÃO)
				(cTable)->Z0E_US_LOG := cNamUser 						//NOME DO USUARIO QUE REALIZOU A ALTERAÇÃO
				(cTable)->Z0E_RECNO  := nReg				    //RECNO DO REGISTRO
				(cTable)->(dbUnlock())
			ENDIF
			SX3->(DbSkip())
		EndDo
		(cTable)->(DBCloseArea())

	ELSEIF nOpc == 4
		//MSGINFO("Alias:"+cTable+" Registro"+cValToChar(nReg)+" Opção:"+cValToChar(nOpc),"Alteração")
		AbreLogF(cTable,"")

		(cTabAlias)->(dbSetOrder(1))
		(cTabAlias)->(dbGoTo(nReg))

		SX3->(DbSetOrder(1))
		SX3->(DbSeek( cTabAlias))

		while SX3->(!eof()) .and. SX3->X3_ARQUIVO == cTabAlias	
			cQuery := " SELECT * FROM " +cTable 
			cQuery += " WHERE Z0E_CPO = '" + SX3->X3_CAMPO + "'"
			cQuery += " AND Z0E_RECNO = "+STR(nReg)+""
			cQuery += " ORDER BY Z0E_DT_LOG, Z0E_HR_LOG DESC"

			IF AbreQuery(cQuery,"QryLOG") 
					
					IF AllTrim(cValToChar((cTabAlias)->&(SX3->X3_CAMPO))) <> AllTrim(QryLOG->Z0E_VL_ATU)
						(cTable)->(dbAppend())
						(cTable)->Z0E_ALIAS  := cTabAlias						//ALIAS 
						(cTable)->Z0E_CPO    := SX3->X3_CAMPO 					// CAMPO
						(cTable)->Z0E_VL_ATU := AllTrim(cValToChar((cTabAlias)->&(SX3->X3_CAMPO)))  	// VALOR ATUAL
						(cTable)->Z0E_VL_ANT := QryLOG->Z0E_VL_ATU 				//VALOR ANTERIOR
						(cTable)->Z0E_DT_LOG := DATE()							//DATA QUE FOI REALIZADO A ALTERAÇÃO
						(cTable)->Z0E_HR_LOG := StrTran( TIME(),":","" ) 		//HORARIO DA ALTERAÇÃO
						(cTable)->Z0E_TP_LOG := cValToChar(nOpc)  				//TIPO DE OPERAÇÃO (ALTERAÇÃO)
						(cTable)->Z0E_US_LOG := cNamUser 						//NOME DO USUARIO QUE REALIZOU A ALTERAÇÃO
						(cTable)->Z0E_RECNO  := nReg				    //RECNO DO REGISTRO
						(cTable)->(dbUnlock())
					ENDIF
			
			ELSE				
				(cTable)->(dbAppend())
				(cTable)->Z0E_ALIAS  := cTabAlias						//ALIAS 
				(cTable)->Z0E_CPO    := SX3->X3_CAMPO 					//CAMPO
				(cTable)->Z0E_VL_ATU := cValToChar((cTabAlias)->&(SX3->X3_CAMPO))  	//VALOR ATUAL
				(cTable)->Z0E_VL_ANT := "" 								//VALOR ANTERIOR
				(cTable)->Z0E_DT_LOG := DATE()							//DATA QUE FOI REALIZADO A ALTERAÇÃO
				(cTable)->Z0E_HR_LOG := StrTran( TIME(),":","" ) 		//HORARIO DA ALTERAÇÃO
				(cTable)->Z0E_TP_LOG := cValToChar(nOpc)  				//TIPO DE OPERAÇÃO (ALTERAÇÃO)
				(cTable)->Z0E_US_LOG := cNamUser 						//NOME DO USUARIO QUE REALIZOU A ALTERAÇÃO
				(cTable)->Z0E_RECNO  := nReg				    //RECNO DO REGISTRO
				(cTable)->(dbUnlock())
			ENDIF
			SX3->(DbSkip())
		EndDo
		(cTable)->(DBCloseArea())

	ELSEIF nOpc == 5

		MSGINFO("Alias:"+cTable+" Registro"+cValToChar(nReg)+" Opção:"+cValToChar(nOpc),"Excluir")

	ENDIF

	RETURN
	*=====================================================================================================================================*

/*/{Protheus.doc} AbreLogF
//TODO Descrição auto-gerada.
@author Leosanlim
@since 25/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cTable, characters, Tabela de referencia a ser criada
@param aCampos, array, Campos que devem existir na tabela Padrão
@type function
/*/
Static Function AbreLogF(cTable) // Cria/abre as tabelas
	*=====================================================================================================================================*
	Local aStruLog := {} ,  aStruExist := {}, cCpNExist := "", lCpExiste := .T.
	Local lEstrucDif := .f. , i := 0 , j:= 0
	Local cAux := ""
	Local cRDD := "TOPCONN"

	if Select(cTable) > 0
		(cTable)->(DBCLOSEAREA())
	EndIf

	AADD(aStruLog,{"Z0E_ALIAS"   ,"C", 8,0})
	AADD(aStruLog,{"Z0E_CPO"     ,"C", 10,0})
	AADD(aStruLog,{"Z0E_VL_ATU"  ,"C", 250,0})
	AADD(aStruLog,{"Z0E_VL_ANT"  ,"C", 250,0})
	AADD(aStruLog,{"Z0E_DT_LOG"  ,"D", 8,0})
	AADD(aStruLog,{"Z0E_HR_LOG"  ,"C", 8,0})
	AADD(aStruLog,{"Z0E_TP_LOG"  ,"C", 1,0})
	AADD(aStruLog,{"Z0E_US_LOG"  ,"C",60,0})
	AADD(aStruLog,{"Z0E_RECNO"   ,"N",10,0})

	//cTable := AllTrim("Z0E")+SUBSTR(ALLTRIM(RetSqlName(cTable)),4,LEN(ALLTRIM(RetSqlName(cTable))))+"_LOG"

	// se a tabela não está aberta
	IF SELECT(cTable) == 0
		// verifica existência
		If !MsFile(cTable,,"TOPCONN")
			// se não existe CRIA
			dbCreate(cTable, aStruLog, "TOPCONN")
			//MSGINFO("Tabela ("+cTable+") criada")
			//dbUseArea(.T.,"TOPCONN",cTable,cTable,.F.)
			//(cTable)->(dbCreateIndex( cTable+'1' , "DT_LOG+HR_LOG" , {||DT_LOG+HR_LOG}) )
			//(cTable)->(dbCloseArea())
		Else
			//MSGINFO("Conferindo estrutura da tabela: "+cTable)
			// se existe confere a estrutura
			dbUseArea(.T.,"TOPCONN",(cTable),(cTable),.t.)
			aStruExist := (cTable)->(dbStruct())
			//MSGINFO("eXISTENTE:"+CVALTOCHAR(len(aStruExist))+" LOG"+STR(len(aStruLog)))
			if len(aStruExist)<len(aStruLog)
				lEstrucDif := .T.
			else
				for i:= 1 to len(aStruLog)
					j := aScan(aStruExist,{|x| x[1]= aStruLog[i,1]})
					if j = 0 // se o campo não existe
						lEstrucDif := .T.
					else     // Confere demais atributos
						lEstrucDif := if(aStruExist[j,2]<>aStruLog[i,2],.T.,lEstrucDif)
						lEstrucDif := if(aStruExist[j,3]<>aStruLog[i,3],.T.,lEstrucDif)
						lEstrucDif := if(aStruExist[j,4]<>aStruLog[i,4],.T.,lEstrucDif)
					endif
				next
			endif
			(cTable)->(dbCloseArea())
			if lEstrucDif // se a estrutrura estiver diferente atualiza
				cAux := Dtos(date())+StrTran(time(),":","")
				// faz bpk da tabela atual
				TCSqlExec("select * into "+cTable+cAux+" from "+cTable)
				// apaga a tabela atual
				TCSqlExec("drop table "+cTable)
				// cria nova
				dbCreate(cTable, aStruLog, "TOPCONN")              // cria a tabela
				dbUseArea(.T.,"TOPCONN",cTable,cTable,.F.)      // abre exclusiva e cria o indice
				//(cTable)->(dbCreateIndex( cTable+'1' , "DT_LOG+HR_LOG" , {||DT_LOG+HR_LOG}) )
				dbUseArea(.T.,"TOPCONN",cTable+cAux,cTable+cAux,.F.) // abre exclusiva para recuperar o BKP
				//Carrega o que estava em bkp
				while (cTable+cAux)->(!eof())
					(cTable)->(reclock(cTable,.t.))
					for i:= 1 to len(aStruLog)
						j := aScan(aStruExist,{|x| x[1]= aStruLog[i,1]})
						// se o campo existe e é do mesmo tipo
						if j > 0 .and. aStruExist[j,2]=aStruLog[i,2]
							(cTable)->&(aStruLog[i,1]):= (cTable+cAux)->&(aStruExist[j,1])
						end
					next
					(cTable+cAux)->(dbUnlock())
					(cTable+cAux)->(dbSkip())
				end
				(cTable+cAux)->(dbCloseArea())
				(cTable)->(dbCloseArea())
			endif
		EndIf
		dbUseArea(.T.,"TOPCONN",cTable,cTable,.T.)
		//(cTable)->( DBClearIndex() )
		//DbSetIndex(cTable+'1')
	ENDIF

	Return .T.
	*=====================================================================================================================================*


/*/{Protheus.doc} AbreQuery
//TODO Descrição auto-gerada.
@author Leosanlim
@since 30/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cQry, characters, descricao
@param cArea, characters, descricao
@type function
/*/
Static function AbreQuery(cQry,cArea)
	*=====================================================================================================================================*
	// fecha workarea se já existe
	if Select(cArea) > 0
		(cArea)->(DBCLOSEAREA())
	EndIf
	// executa a query
	DbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), cArea, .F., .T. )
	(cArea)->(dbGoTop())

	RETURN (cArea)->(! eof())
	*=====================================================================================================================================*



/*/{Protheus.doc} TABDIR
//TODO Descrição auto-gerada.
@author Leosanlim
@since 07/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cTabAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
STATIC FUNCTION TABDIR(cTabAlias,nReg,nOpc)
	*=====================================================================================================================================*
	LOCAL aStru := {}, cAlterado := "2", lRegistro
	LOCAL cTable := "Z0D"//RetSqlName("Z0D")
	LOCAL cCodEmp := SM0->M0_CODIGO//+"-"+
	LOCAL cNomEmp := FwCutOff(IF(AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))==0,ALLTRIM(LEFT(SM0->M0_NOME,30)),SUBSTR(STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),1, AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))-1)),.T.)
	LOCAL aFArq := {}
	//LOCAL cUnidade := IF(cCodEmp == "99","D:\ASTAGE\",ALLTRIM(SUPERGETMV("MV_P_00132",.F.,"\\SRVDCASTAGE01\E$\ASTAGE\")))
	LOCAL cUnidade := IF(cCodEmp == "99","D:\ASTAGE\",ALLTRIM(SUPERGETMV("MV_P_00132",.F.,"\\SRVDCASTAGE01\E$\FINNET\")))  //CAS - 04/11/2019 FINNET	
	LOCAL cCorpCli := IF(SUPERGETMV("MV_P_00122",.F.,.F.),"CORP","CLI")
    
	//CAS - 04/11/2019 FINNET
	AADD(aFArq,{cUnidade+"O0055FINNET\SAIDA\"       	,"01","P","REM"}) 	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"01","P","REM"})  
	AADD(aFArq,{cUnidade+"O0055FINNET\ENTRADA\"     	,"02","P","RET"}) 	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"02","P","RET"})
	AADD(aFArq,{cUnidade+"O0055FINNET\ENTRADA\BACKUP\"	,"03","P","BKP"}) 	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"03","P","BKP"})
	AADD(aFArq,{cUnidade+"O0055FINNET\SAIDA\"		 	,"04","R","REM"})	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"04","R","REM"})
	AADD(aFArq,{cUnidade+"O0055FINNET\ENTRADA\"		 	,"05","R","RET"}) 	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"05","R","RET"})
	AADD(aFArq,{cUnidade+"O0055FINNET\ENTRADA\BACKUP\"	,"06","R","BKP"}) 	//AADD(aFArq,{cUnidade+"CNAB\"+cCorpCli+"\"+cCodEmp,"06","R","BKP"})
	AADD(aFArq,{cUnidade+"O0055FINNET\ENTRADA\"		 	,"07","",""}) 		//AADD(aFArq,{cUnidade+"EXTRATO\"+cCorpCli+"\"+cCodEmp,"07","",""})
	AADD(aFArq,{cUnidade+"COMP\"+cCorpCli+"\"+cCodEmp	,"08","",""}) 		//AADD(aFArq,{cUnidade+"COMP\"+cCorpCli+"\"+cCodEmp,"08","",""})
    /*
	IF !MsFile(RetSqlName(cTable),,"TOPCONN")
		MSGALERT("NECESSARIO APLICAR UPDATE PARA CRIAÇÃO DO ALIAS:"+cTable+ENTER+" POR FAVOR INFORMAR O SUPORTE","NÃO EXISTE ALIAS: "+cTable)
		RETURN .F.
	ENDIF
    */
	IF SELECT(RetSqlName("Z0D")) == 0

		IF EMPTY(nOpc)
			DbSelectArea(cTabAlias)
			(cTabAlias)->(DbSetOrder(1))
			(cTabAlias)->(DbGoTop())

			DbSelectArea(cTable)
			(cTable)->(DbSetOrder(2))

			while !(cTabAlias)->(eof())
				IF  !EMPTY(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)))
					cNomEmp := FwCutOff(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)),.T.)
				ENDIF
				FOR c:= 1 to len(aFArq)
					IF !(cTable)->(dbSeek(xFilial(cTable) + (cTabAlias)->EE_CODIGO + (cTabAlias)->EE_AGENCIA + (cTabAlias)->EE_CONTA + (cTabAlias)->EE_SUBCTA + aFArq[c,2])) .AND. (cTabAlias)->EE_P_ACCES = "1"
						(cTable)->(dbAppend( .F. ))
						(cTable)->Z0D_FILIAL  := xFilial(cTable)
					    (cTable)->Z0D_DIR     := aFArq[c,1]+iif(AT("EXTRATO",aFArq[c,1])<>0,"-"+cNomEmp,"")+"\"+AllTrim((cTabAlias)->EE_CODIGO)+"\"+AllTrim(StrTran(StrTran((cTabAlias)->EE_CONTA,"-","" ),".","" ))+AllTrim((cTabAlias)->EE_DVCTA)+iif(EMPTY(aFArq[c,3]),"\",iif(!EMPTY(aFArq[c,4]),"\"+aFArq[c,3]+"\"+aFArq[c,4]+"\","\"+aFArq[c,3]+"\"))
						(cTable)->Z0D_OPERA   := aFArq[c,2]
						(cTable)->Z0D_BANCO   := (cTabAlias)->EE_CODIGO
						(cTable)->Z0D_AGE     := (cTabAlias)->EE_AGENCIA
						(cTable)->Z0D_CTA     := (cTabAlias)->EE_CONTA
						(cTable)->Z0D_SUBCTA  := (cTabAlias)->EE_SUBCTA
						(cTable)->Z0D_DTCRI   := DATE()
						(cTable)->Z0D_HRCRI   := StrTran( TIME(),":","" )
						(cTable)->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
						(cTable)->Z0D_ALTERA  := cAlterado
						(cTable)->(dbUnlock())
					ENDIF
				NEXT
				cAlterado := "2"
				cNomEmp := FwCutOff(IF(AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))==0,ALLTRIM(LEFT(SM0->M0_NOME,30)),SUBSTR(STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),1, AT("/",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"))-1)),.T.)
				(cTabAlias)->( dbSkip() )
			END
		ELSEIF nOpc == 3 // "Incluir"
			DbSelectArea(cTabAlias)
			(cTabAlias)->(DbSetOrder(1))
			(cTabAlias)->(DbGoTop())

			DbSelectArea(cTable)
			(cTable)->(DbSetOrder(2))
			while !(cTabAlias)->(eof())
				IF  !EMPTY(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)))
					cNomEmp := FwCutOff(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)),.T.)
				ENDIF
				FOR c:= 1 to len(aFArq)
					lRegistro := (cTable)->(dbSeek(xFilial(cTable)+(cTabAlias)->EE_CODIGO+(cTabAlias)->EE_AGENCIA+(cTabAlias)->EE_CONTA+(cTabAlias)->EE_SUBCTA+aFArq[c,2]))
					IF !lRegistro .AND. (cTabAlias)->EE_P_ACCES = "1"
						(cTable)->(dbAppend( .F. ))
						(cTable)->Z0D_FILIAL  := xFilial(cTable)
					  //(cTable)->Z0D_DIR     := aFArq[c,1]+iif(AT("EXTRATO",aFArq[c,1])<>0,"-"+cNomEmp,"")+"\"+AllTrim((cTabAlias)->EE_CODIGO)+"\"+AllTrim(StrTran(StrTran((cTabAlias)->EE_CONTA,"-","" ),".","" ))+AllTrim((cTabAlias)->EE_DVCTA)+iif(EMPTY(aFArq[c,3]),"\",iif(!EMPTY(aFArq[c,4]),"\"+aFArq[c,3]+"\"+aFArq[c,4]+"\","\"+aFArq[c,3]+"\"))
						(cTable)->Z0D_DIR     := aFArq[c,1]								//CAS - 04/11/2019
						(cTable)->Z0D_OPERA   := aFArq[c,2]
						(cTable)->Z0D_BANCO   := (cTabAlias)->EE_CODIGO
						(cTable)->Z0D_AGE     := (cTabAlias)->EE_AGENCIA
						(cTable)->Z0D_CTA     := (cTabAlias)->EE_CONTA
						(cTable)->Z0D_SUBCTA  := (cTabAlias)->EE_SUBCTA
						(cTable)->Z0D_DTCRI   := DATE()
						(cTable)->Z0D_HRCRI   := StrTran( TIME(),":","" )
						(cTable)->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
						(cTable)->Z0D_ALTERA  := cAlterado
						(cTable)->(dbUnlock())
					ENDIF
				NEXT
				(cTabAlias)->( dbSkip() )
			END
		ELSEIF nOpc == 4 // "Alterar"

			DbSelectArea(cTabAlias)
			(cTabAlias)->(DbGoTo(nReg))

			DbSelectArea(cTable)
			(cTable)->(DbSetOrder(2))
			IF !(cTabAlias)->(eof())
				FOR c:= 1 to len(aFArq)
					lRegistro := (cTable)->(dbSeek(xFilial(cTable)+(cTabAlias)->EE_CODIGO+(cTabAlias)->EE_AGENCIA+(cTabAlias)->EE_CONTA+(cTabAlias)->EE_SUBCTA+aFArq[c,2]))

					cNomEmp := FwCutOff(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)),.T.)
					IF lRegistro .AND. AT(ALLTRIM(LEFT((cTabAlias)->EE_P_NOEMP,30)),(cTable)->Z0D_DIR) == 0
						cAlterado := "1"
					ENDIF

					IF lRegistro .AND. (cTabAlias)->EE_P_ACCES = "1" .AND. (cTable)->Z0D_ALTERA != "1"
						(cTable)->(DBRLock())
					  //(cTable)->Z0D_DIR     := aFArq[c,1]+iif(AT("EXTRATO",aFArq[c,1])<>0,"-"+cNomEmp,"")+"\"+AllTrim((cTabAlias)->EE_CODIGO)+"\"+AllTrim(StrTran(StrTran((cTabAlias)->EE_CONTA,"-","" ),".","" ))+AllTrim((cTabAlias)->EE_DVCTA)+iif(EMPTY(aFArq[c,3]),"\",iif(!EMPTY(aFArq[c,4]),"\"+aFArq[c,3]+"\"+aFArq[c,4]+"\","\"+aFArq[c,3]+"\"))
					    (cTable)->Z0D_DIR     := aFArq[c,1]								//CAS - 04/11/2019
						(cTable)->Z0D_DTCRI   := DATE()
						(cTable)->Z0D_HRCRI   := StrTran( TIME(),":","" )
						(cTable)->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
						(cTable)->Z0D_ALTERA  := cAlterado
						(cTable)->(DBRUnlock(nReg))

					ELSEIF !lRegistro .AND. (cTabAlias)->EE_P_ACCES = "1"
						(cTable)->(dbAppend( .F. ))
						(cTable)->Z0D_FILIAL  := xFilial(cTable)
					  //(cTable)->Z0D_DIR     := aFArq[c,1]+iif(AT("EXTRATO",aFArq[c,1])<>0,"-"+cNomEmp,"")+"\"+AllTrim((cTabAlias)->EE_CODIGO)+"\"+AllTrim(StrTran(StrTran((cTabAlias)->EE_CONTA,"-","" ),".","" ))+AllTrim((cTabAlias)->EE_DVCTA)+iif(EMPTY(aFArq[c,3]),"\",iif(!EMPTY(aFArq[c,4]),"\"+aFArq[c,3]+"\"+aFArq[c,4]+"\","\"+aFArq[c,3]+"\"))
					    (cTable)->Z0D_DIR     := aFArq[c,1]								//CAS - 04/11/2019
						(cTable)->Z0D_OPERA   := aFArq[c,2]
						(cTable)->Z0D_BANCO   := (cTabAlias)->EE_CODIGO
						(cTable)->Z0D_AGE     := (cTabAlias)->EE_AGENCIA
						(cTable)->Z0D_CTA     := (cTabAlias)->EE_CONTA
						(cTable)->Z0D_SUBCTA  := (cTabAlias)->EE_SUBCTA
						(cTable)->Z0D_DTCRI   := DATE()
						(cTable)->Z0D_HRCRI   := StrTran( TIME(),":","" )
						(cTable)->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
						(cTable)->Z0D_ALTERA  := cAlterado
						(cTable)->(dbUnlock())
					ENDIF
				NEXT
			ENDIF
		ENDIF

		(cTabAlias)->(dbCloseArea())
		(cTable)->(dbCloseArea())


	ENDIF
            
	//CAS - 04/11/2019 Comentado para nao chamar mais a Funcao GERAFOLD
	/*
	IF !EMPTY(nOpc)
		GERAFOLD(cTabAlias,nReg,nOpc)//CRIAR OS DIRETORIOS PARA O BANCO
	ENDIF
    */
	RETURN .T.
	*=====================================================================================================================================*


/*/{Protheus.doc} GERAFOLD
//TODO CRIA AS PASTAS CASO NÃO EXISTA PARA EMPRESA/BANCO
@author Leosanlim
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cTabAlias, characters, Alias SEE
@param nReg, numeric, RECNO da SEE
@param nOpc, numeric, Opção realizada Altera/Inclui/Exclui
@type function
/*/
STATIC FUNCTION GERAFOLD(cTabAlias,nReg,nOpc)
	*=====================================================================================================================================*
	LOCAL lDir := .T., nCriada
	Local cRDD := "TOPCONN"
	Local nDir := 0 , cDir := ""
	LOCAL nDirS := 0, cDirS := ""
	LOCAL cUnidade := "", p := 0
	LOCAL cMsg := "", cMsgSTS :="" //cMsgSTS Mensagem Status
	LOCAL aArrBut := {{1, .T., {|| lExeFun := .T., U_DIRCNAB()},"VISUALIZAR"},;
	{2, .T., {|| lExeFun := .F., FechaBatch()}}}
	//AADD(aArrBut, {1, .T., {|| lExeFun := .T., FechaBatch()}})
	//AADD(aArrBut, {2, .T., {|| lExeFun := .F., FechaBatch()}})

	(cTabAlias)->(dbSetOrder(1))
	(cTabAlias)->(dbGoTo(nReg))

	DbSelectArea("Z0D")
	Z0D->(DbSetOrder(1))
	Z0D->(dbGoTop())

	WHILE !Z0D->(EOF())

		lDir := ExistDir(Z0D->Z0D_DIR)

		IF !lDir // SE NÃO EXISTIR DIRETORIO SERA CRIADO
			IF(AT( ":\", Z0D->Z0D_DIR )) <> 0
				//PEGANDO A UNIDADE EXEMPLO: "D:\"
				cUnidade := SUBSTR(Z0D->Z0D_DIR,1, AT( ":\", Z0D->Z0D_DIR)+1)
				//PEGANDO TODOS OS Dirs DENTRO DA UNIDADE EXEMPLO: "ACCESSTAGE\CNAB\CORPORATIVO\99-TESTE\104\99999991044\PAGAMENTO\BACKUP\"
				cDirS := ALLTRIM(SUBSTR(Z0D->Z0D_DIR,LEN(cUnidade)+1, len(Z0D->Z0D_DIR)))
				//PEGANDO O TAMANHO DA STRING
				nDirS := len(cDirS)+1
				//POSIÇÃO DA PRIMEIRA BARRA DOS Diretorios EXEMPLO: "10"
				nDir := AT("\",cDirS)
				FOR p := 1 TO nDirS
					cDir:= SUBSTR(cDirS,1, nDir-1)//PEGANDO O PRIMEIRO Diretorios
					//cMSGPRT := "Diretório: " + cDirS + ENTER + "Primeiro Diretório :"+ cDir + ENTER +  "Posição do \ nDir:" + CVALTOCHAR(nDir) + ENTER
					cUnidade += cDir+"\"
					p += len(cDir)//nDir
					lDir := ExistDir(cUnidade)
					//cMSGPRT += "Unidade: " + cUnidade + ENTER + "De P: " + CVALTOCHAR(p) + " Até nDirS:" + CVALTOCHAR(nDirS) + ENTER 
					//MSGINFO(cMSGPRT,"MSG")
					IF !lDir						
						nCriada := MakeDir(cUnidade)//CRIA DIRETORIO
						//MSGINFO(nCriada,"CRIA DIRETÓRIO LINHA 435")
						IF nCriada = 0
							lDir := ExistDir(cUnidade)
							cMsgSTS := "Diretório "+cUnidade+"  criado com SUCESSO"
						ELSE
							cMsgSTS := "Não foi possivel criar o diretório : "+cUnidade+" ERRO: "+cValToChar(FError())
						ENDIF
					ENDIF
					IF p <= nDirS
						cDirS := SUBSTR(cDirS,nDir+1, nDirS) //PEGANDO TODOS OS Diretorios DENTRO DE UM DIRETORIO
						nDir := AT("\",cDirS) //POSIÇÃO DA PRIMEIRA BARRA DOS Diretorios
					ENDIF
				NEXT

				Z0D->(DBRLock())
				Z0D->Z0D_DTCRI   := DATE()
				Z0D->Z0D_HRCRI   := StrTran( TIME(),":","" )
				Z0D->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
				Z0D->Z0D_STATUS  := IF(nCriada == 0,"1", "0")
				Z0D->Z0D_M_MSG   := cMsgSTS//MSMM(Z0D->Z0D_MSG,AVSX3("Z0D_M_MSG",3),,cMsgSTS,1)
				Z0D->(DBRUnlock())

				cMsg += cMsgSTS + ENTER
				//AADD(aMsg, cMsgSTS )

			ELSEIF (AT( "\\", Z0D->Z0D_DIR )) <> 0 .OR. (AT( "E$", Z0D->Z0D_DIR )) <> 0

				//PEGANDO A UNIDADE EXEMPLO: "\\SRVDCASTAGE01\E$\ASTAGE\99-TESTE\001\pagamento\remessa"
				cUnidade :=SUBSTR(Z0D->Z0D_DIR,1, AT( "E$", Z0D->Z0D_DIR)+2)//SUBSTR(SUBSTR(Z0D->Z0D_DIR,AT( "\\", Z0D->Z0D_DIR)+2, len(Z0D->Z0D_DIR)),1, AT( "\", SUBSTR(Z0D->Z0D_DIR,AT( "\\", Z0D->Z0D_DIR)+2, len(Z0D->Z0D_DIR))))
				cDirS := ALLTRIM(SUBSTR(Z0D->Z0D_DIR,LEN(cUnidade)+1, len(Z0D->Z0D_DIR)))//PEGANDO TODOS OS Dirs DENTRO DA UNIDADE EXEMPLO: "ACCESTAGE\99-TESTE\001\pagamento\remessa"
				nDirS := len(cDirS)+1//PEGANDO O TAMANHO DA STRING
				nDir := AT("\",cDirS)//POSIÇÃO DA PRIMEIRA BARRA DOS Diretorios EXEMPLO: "10"

				FOR p := 1 TO nDirS
					cDir:= SUBSTR(cDirS,1, nDir-1)//PEGANDO O PRIMEIRO Diretorios
					cUnidade += cDir+"\"
					p += len(cDir)//nDir
					lDir := ExistDir(cUnidade)
					//MSGINFO("Unidade: '"+cUnidade+" nDir: "+cValToChar(nDir)+" Posição: "+cValToChar(p)+" QTD registro: "+cValToChar(nDirS))
					IF !lDir
						//MSGINFO("sera criada a pasta: '"+cUnidade)
						nCriada := MakeDir(cUnidade)//CRIA DIRETORIO
						IF nCriada = 0
							lDir := ExistDir(cUnidade)
							cMsgSTS := "Diretório criado com SUCESSO"
						ELSE
							cMsgSTS := "NÃO FOI POSSIVEL CRIAR A PASTA: "+cUnidade+" ERRO: "+cValToChar(FError())
						ENDIF
					ENDIF
					IF p <= nDirS
						cDirS := SUBSTR(cDirS,nDir+1, nDirS) //PEGANDO TODOS OS Diretorios DENTRO DE UM DIRETORIO
						nDir := AT("\",cDirS) //POSIÇÃO DA PRIMEIRA BARRA DOS Diretorios
					ENDIF
				NEXT

				Z0D->(DBRLock())
				Z0D->Z0D_DTCRI   := DATE()
				Z0D->Z0D_HRCRI   := StrTran( TIME(),":","" )
				Z0D->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
				Z0D->Z0D_STATUS  := IF(nCriada == 0,"1", "0")
				Z0D->Z0D_M_MSG   := cMsgSTS//MSMM(Z0D->Z0D_MSG,AVSX3("Z0D_M_MSG",3),,cMsgSTS,1)
				Z0D->(DBRUnlock())

				cMsg += cMsgSTS + ENTER
				//AADD(aMsg, cMsgSTS )
			ENDIF
		ELSEIF (Z0D_STATUS =="0" .OR. EMPTY(Z0D_STATUS))
			Z0D->(DBRLock())
			Z0D->Z0D_DTCRI   := DATE()
			Z0D->Z0D_HRCRI   := StrTran( TIME(),":","" )
			Z0D->Z0D_USCRI   := LEFT(UsrFullName( RetCodUsr() ), 60)
			Z0D->Z0D_STATUS  := "1"//IF(nCriada == 0,"1", "0")
			Z0D->Z0D_M_MSG   := "Diretório criado com SUCESSO"//cMsgSTS//MSMM(Z0D->Z0D_MSG,AVSX3("Z0D_M_MSG",3),,cMsgSTS,1)
			Z0D->(DBRUnlock())
		ENDIF
		Z0D->( dbSkip() )
	ENDDO
	IF nDirS != 0
		//FormBatch('Importação SEDEX',aMsg , aArrBut,,,)
		cAux := Aviso( "Criação dos Diretórios" ,cMsg, {"OK","Consultar criação"}, 3 )
		if cAux = 2
			U_DIRCNAB()
		endif
	ENDIF
	RETURN lDir
	*=====================================================================================================================================*

/*/{Protheus.doc} U_DIRCNAB
//TODO FUNÇÃO QUE MONTA A TELA COM OS CAMINHOS ONDE OS ARQUIVOS BANCO/CNAB DEVEM SER SALVOS
@author Leosanlim
@since 01/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
USER FUNCTION DIRCNAB()
	*=====================================================================================================================================*
	//local aRotOld    := aClone(aRotina)
	LOCAL aCores  := {{ 'Z0D->Z0D_STATUS == "1"' , 'BR_VERDE'  },;    // CRIADO
	{ 'Z0D->Z0D_STATUS == "0"' , 'BR_VERMELHO' },;// ERRO NA CRIAÇÃO
	{ 'Z0D->Z0D_STATUS == " "' , 'BR_PRETO' }}    // NÃO CRIADO

	Private cCadastro := "DIRETORIO BANCO/CNAB"
	Private aRotina := {{"Visualizar" , "AxVisual" , 0, 2},;
	{"Incluir" , "AxInclui" , 0, 3},;
	{"Excluir" , "AxDeleta" , 0, 5},;
	{"Exportar Excel","U_RELDIREC", 0 , 6}}

	MBrowse(6,1,22,75,"Z0D",,,,,,aCores)
	RETURN
	*=====================================================================================================================================*

/*/{Protheus.doc} RELDIREC
//TODO GERA RELATÓRIO EM EXCEL DOS DIRETÓRIOS CRIADOS 
@author Leosanlim
@since 03/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
USER FUNCTION RELDIREC()
	*=====================================================================================================================================*
//Local aFontes := GetSrcArray("*")
Local nI 
Local oFWMsExcel := FWMSExcel():New() 
Local aDirec := {} 
Local oExcel 

oFWMsExcel:AddworkSheet("Extrato")
oFWMsExcel:AddworkSheet("Cobranca")
oFWMsExcel:AddworkSheet("Pagamento")
//Criando a Tabela
oFWMsExcel:AddTable("Extrato","Diretorio")  
oFWMsExcel:AddColumn("Extrato","Diretorio","Banco",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Fise",1)   
oFWMsExcel:AddColumn("Extrato","Diretorio","Empresa",1)   
oFWMsExcel:AddColumn("Extrato","Diretorio","Agencia",1)   
oFWMsExcel:AddColumn("Extrato","Diretorio","Conta",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Convenio",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Sender",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Receiver",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Doctype",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Nomenclatura",1)
oFWMsExcel:AddColumn("Extrato","Diretorio","Diretorio",1) 
oFWMsExcel:AddColumn("Extrato","Diretorio","Email",1) 

oFWMsExcel:AddTable("Cobranca","Diretorio")  
oFWMsExcel:AddColumn("Cobranca","Diretorio","Banco",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Fise",1)   
oFWMsExcel:AddColumn("Cobranca","Diretorio","Empresa",1)   
oFWMsExcel:AddColumn("Cobranca","Diretorio","Agencia",1)   
oFWMsExcel:AddColumn("Cobranca","Diretorio","Conta",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Convenio",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Sender",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Receiver",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Doctype",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Nomenclatura Envio",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Diretorio Envio",1)   
oFWMsExcel:AddColumn("Cobranca","Diretorio","Nomenclatura Retorno",1)
oFWMsExcel:AddColumn("Cobranca","Diretorio","Diretorio Retorno",1)  
oFWMsExcel:AddColumn("Cobranca","Diretorio","Diretorio Backup",1) 
oFWMsExcel:AddColumn("Cobranca","Diretorio","Email",1) 

oFWMsExcel:AddTable("Pagamento","Diretorio")  
oFWMsExcel:AddColumn("Pagamento","Diretorio","Banco",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Fise",1)   
oFWMsExcel:AddColumn("Pagamento","Diretorio","Empresa",1)   
oFWMsExcel:AddColumn("Pagamento","Diretorio","Agencia",1)   
oFWMsExcel:AddColumn("Pagamento","Diretorio","Conta",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Convenio",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Sender",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Receiver",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Doctype",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Nomenclatura Envio",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Diretorio Envio",1)   
oFWMsExcel:AddColumn("Pagamento","Diretorio","Nomenclatura Retorno",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Diretorio Retorno",1)
oFWMsExcel:AddColumn("Pagamento","Diretorio","Diretorio Backup",1)   
oFWMsExcel:AddColumn("Pagamento","Diretorio","Email",1)   

DbSelectArea("Z0D")
Z0D->(DbSetOrder(1))
Z0D->(dbGoTop())

	WHILE !Z0D->(EOF())
		AADD(aDirec,{Z0D->Z0D_DIR,Z0D->Z0D_OPERA,Z0D->Z0D_BANCO,Z0D->Z0D_AGE,Z0D->Z0D_CTA,Z0D->Z0D_SUBCTA})
		Z0D->( dbSkip() )
	ENDDO
    
nT := LEN(aDirec)
  If nT > 0  
    For nI := 1 to nT 
		//cBancoDir := IF(aDirec[nI,3])
		//MSGINFO(cvaltochar(nI))
		oFWMsExcel:AddRow("Pagamento","Diretorio",{aDirec[nI,3],"",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),aDirec[nI,4],aDirec[nI,5],"","","","",;
		"Exemplo: "+SM0->M0_CODIGO+"_PE_AAAAMMDD_HHMMSS.2PE ou .TXT ou .REM",aDirec[nI,1],;
		"Exemplo: "+SM0->M0_CODIGO+"_PR_AAAAMMDD_HHMMSS.2PR ou .TXT  ou .RET",aDirec[nI+1,1],aDirec[nI+2,1],SUPERGETMV("MV_P_00131",.F.,"log.accesstage@br.gt.com")})

		oFWMsExcel:AddRow("Cobranca","Diretorio",{aDirec[nI,3],"",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),aDirec[nI,4],aDirec[nI,5],"","","","",;
		"Exemplo: "+SM0->M0_CODIGO+"_RE_AAAAMMDD_HHMMSS.2RE ou .TXT ou .REM",aDirec[nI+3,1],;
		"Exemplo: "+SM0->M0_CODIGO+"_RR_AAAAMMDD_HHMMSS.2RR ou .TXT  ou .RET",aDirec[nI+4,1],aDirec[nI+5,1],SUPERGETMV("MV_P_00131",.F.,"log.accesstage@br.gt.com")})

		oFWMsExcel:AddRow("Extrato","Diretorio",{aDirec[nI,3],"",STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/"),aDirec[nI,4],aDirec[nI,5],"","","","","",aDirec[nI+6,1],SUPERGETMV("MV_P_00131",.F.,"")})     
		nI := nI+6
	Next  
  Else  
    MsgStop("Nenhum registro encontrado.")
  Endif

  
    //_cXLS:= "FONTES"   
    //cArqDir := "C:\TEMP\DIRETORIO_CNAB_EXTRATO_"+STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,30))," ","/")+".XLS"
	cArqDir := GetTempPath()+"\DIR_CNAB_"+STRTRAN(ALLTRIM(LEFT(SM0->M0_NOME,10))," ","_")+".XLS" 
	MSGINFO(cArqDir)
	oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArqDir)

	//SENDMAIL()
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArqDir)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas


RETURN .T.
*=====================================================================================================================================*
