#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "VKEY.CH"
#include "tbiconn.ch"
#INCLUDE "XmlXFun.Ch"
//#include "spednfe.ch"
#define STR0035  "Ambiente"
#define STR0039  "O primeiro passo é configurar a conexão do Protheus com o serviço."
#define STR0050  "Protocolo"
#define STR0056  "Produção"
#define STR0057  "Homologação"
#define STR0068  "Cod.Ret.NFe"
#define STR0069  "Msg.Ret.NFe"
#define STR0114  "Ok"
#define STR0107  "Consulta NF"
#define STR0129  "Versão da mensagem"
#define STR0160  "1-Preço"
#define STR0161  "2-Quantidade"
#define STR0162  "3-Frete"
#define STR0414  "Sem manfifestação"
#define STR0415  "Confirmada"
#define STR0416  "Desconhecida"
#define STR0417  "Não realizada"
#define STR0418  "Ciência"
#define STR0419  "210200 - Confirmação da Operação"
#define STR0420  "210210 - Ciência da Operação"
#define STR0421  "210220 - Desconhecimento da Operação"
#define STR0422  "210240 - Operação não Realizada"



/*/{Protheus.doc} MATA103
// Criado o ponto de entrada genérico MATA103 para atender as situações de lançamentos de notas via Central XML que precisam gerar GNRE por causa da validação padrão
@author marce
@since 28/06/2017
@version 6

@type function
/*/
User Function MATA103()

	// Verifica se a função foi acionada pela rotina padrão Mata103
	If IsInCallStack("MATA103")
		Return
	Endif

	// Verifica se a função foi acionada pela rotina xmldcondor para evitar recursividade
	If IsInCallStack("U_XMLDCONDOR")
		Return 
	Endif

Return U_XMLDCONDOR()

/*/{Protheus.doc} XmlDcondor
(Rotina de interface para gerenciamento de Arquivos XML )

@author Marcelo Alberto Lauschner
@since 19/08/2011
@version 1.0

@param xCodEmp, variavel, (Descrição do parâmetro)
@param xCodFil, variavel, (Descrição do parâmetro)
@param cInIdUser, character, (Descrição do parâmetro)
@param lInExeAuto, logico, (Descrição do parâmetro)

@return Sem retorno

@example
(examples
§
@see (links_or_references)
/*/

User Function XmlDcondor(xCodEmp,xCodFil,cInIdUser,lInExeAuto,cInChave,lSetEnv) 

	Local  		aTmSize		:= MsAdvSize( .F., .F., 400 )
	Private 	cPergXml	:= "XMLDCONDOR"
	Private 	cBuildXML	:= Alltrim("Central XML - 4.2018G-25A")
	Private     cCondXML	:= "" //<-Leonardo Perrella Variável que será tratado no MT100TOK
	Private		lCondVacc 	:= .F.//<-Leonardo Perrella Variável que será tratado no MT100TOK
	Private 	l103Auto	:= .F. // Declara variável para usa na interface da rotina
	Private		lExecFilChv	:= .F.
	Private		cChvFiltro	:= ""
	Private		lAutoExec	:= .F. 
	Default		lInExeAuto	:= .F.
	Default 	cInIdUser	:= "000000"
	Default		cInChave	:= ""
	Default		lSetEnv		:= .F.


	cChvFiltro	:= cInChave
	lExecFilChv	:= !Empty(cInChave)

	If lSetEnv
		// Atribui variavel para																	 uso na rotina
		// Melhoria em 28/04/2013 para permitir o lançamento de nota via schedule
		RPCSetEnv(xCodEmp,xCodFil)

		If !Empty(cInIdUser)
			__cUserId	:= cInIdUser
		Endif

		lAutoExec	:= .T.
		BatchProcess(cBuildXML,OemToAnsi(cBuildXML),cPergXml,{ || sfExec()})

	ElseIf Select("SM0") == 0
		If File("scheduler.wf")
			cReadWf	:= MemoRead("scheduler.wf")
			xCodEmp	:= Iif(xCodEmp<>Nil .And. !Empty(xCodEmp),xCodEmp,Substr(cReadWf,1,At(",",cReadWf)-1))
			cReadWf := Substr(cReadWf,At(",",cReadWf)+1,Len(cReadWf)-Len(xCodEmp)+1)
			xCodFil	:= Iif(xCodFil <> Nil .And. !Empty(xCodFil),xCodFil,Substr(cReadWf,1,At(",",cReadWf)-1))
			RpcSetType(3)
			//RpcSetEnv - Abertura do ambiente em rotinas automáticas ( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
			RPCSetEnv(xCodEmp,xCodFil)
			// Atribui variavel para uso na rotina
			// Melhoria em 28/04/2013
			lAutoExec	:= .T.
			aTmSize 	:= MsAdvSize( .F., .F., 1024 )		// Size da Dialog
			__cUserId	:= cInIdUser
		Else
			Return .F.
		Endif



		DEFINE WINDOW oMainWnd FROM aTmSize[1],aTmSize[2] TO aTmSize[3] , aTmSize[4] TITLE OemToAnsi("Atualização do Dicionário")

		ACTIVATE WINDOW oMainWnd  ON INIT sfExec()


	Else
		// Atribui variavel para uso na rotina
		// Melhoria em 28/04/2013 para permitir o lançamento de nota via schedule
		lAutoExec	:= lInExeAuto
		If !IsBlind()
			sfExec()
		Else
			If !Empty(cInIdUser)
				__cUserId	:= cInIdUser
			Endif
			// Verifica se existe o rdmake Grava Perguntas no APO
			If ExistBlock("GRAVASX1")
				// Verifica se o Ponto de entrada está no APO
				If ExistBlock("XMLCTE03")
					ExecBlock("XMLCTE03",.F.,.F.)
				Endif
				// Exemplo de uso do ponto de entrada XMLCTE03 - Somente estas perguntas são consideradas no filtro e que precisam ser modificadas
				//u_gravasx1("XMLDCONDOR","02","000468")
				//u_gravasx1("XMLDCONDOR","04","000468")
				//u_gravasx1("XMLDCONDOR","06",CTOD("15/05/2013"))
				//u_gravasx1("XMLDCONDOR","07",CTOD("23/06/2013"))

			Endif

			lAutoExec	:= .T.
			MsgAlert("passei batch")
			BatchProcess(cBuildXML,OemToAnsi(cBuildXML),cPergXml,{ || sfExec()})
		EndIf

	Endif

Return


/*/{Protheus.doc} sfExec
(Função principal para criação da Interface)

@author Marcelo A Lauschner
@since 23/06/2013
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function sfExec()

	Local	 nAddBtn		:= 002
	Local	 aButton		:= {}			// Monta botões na barra de tarefas
	Local	 aCabXml		:= {" ",;    		// 1
	"Série/Nº NF-e",;      			// 2
	"Emissão",;    		   			// 3
	" ",;							// 4
	"Fornecedor/Loja-Nome",;   	 	// 5
	" ",;							// 6
	"Chave NF-e",;             	 	// 7
	"Destinatário",;            	// 8
	"Conf.Fiscal",;					// 9
	"Conf.Sefaz",;					// 10
	"Lançada em" ,;					// 11
	"Conf.Compras",;				// 12
	"Recebida em",;					// 13
	"Rev.Sefaz",;					// 14
	"Tipo Nota",;					// 15
	"R$ Total",;					// 16
	"Ok"}
	Local	 aTamCabXml		:= {5,20,10,5,80,5,140,50,10,10,10,10,10,10,10,10,10}
	Local	lXnuVldAc		:= GetNewPar("XM_XNUVLDA",.T.) // Valida Acesso as rotinas MATA103/MATA140/CTBA102 
	Private oDlgXDc
	Private aTmSize 		:= MsAdvSize( .T., .F., 400 )		// Size da Dialog
	Private oVermelho		:= LoaDbitmap( GetResources(), "BR_VERMELHO" )
	Private oAzul 			:= LoaDbitmap( GetResources(), "BR_AZUL" )
	Private oAzuCla   		:= LoadBitmap( GetResources(), "BR_AZUL_CLARO" )
	Private oAmarelo		:= LoaDbitmap( GetResources(), "BR_AMARELO" )
	Private oVerde			:= LoaDbitmap( GetResources(), "BR_VERDE" )
	Private oPreto			:= LoaDbitmap( GetResources(), "BR_PRETO" )
	Private oPink			:= LoaDbitmap( GetResources(), "BR_PINK" )
	Private oVioleta		:= LoaDbitmap( GetResources(), "BR_VIOLETA" )
	Private oLaranja		:= LoadBitmap( GetResources(), "BR_LARANJA" )
	Private oGrey			:= LoadBitmap( GetResources(), "BR_CINZA" )
	Private oMarrom			:= LoadBitmap( GetResources(), "BR_MARROM" )
	Private oColorCTe		:= LoadBitmap( GetResources(), "BR_CANCEL" )
	Private oBranco  		:= LoadBitmap( GetResources(), "BR_BRANCO" )
	Private oCinza   		:= LoadBitmap( GetResources(), "BR_CINZA" )
	Private oNoMarked  		:= LoadBitmap( GetResources(), "LBNO" )
	Private oMarked    		:= LoadBitmap( GetResources(), "LBOK" )
	Private oNFSeCor		:= LoadBitMap( GetResources(), "PMSEDT2")
	Private aCampos   		:= {}
	Private aArqXml			:= {}
	Private cNota			:= ""
	Private nTmF1Doc		:= TamSX3("F1_DOC")[1]
	Private nTmF1Ser		:= TamSX3("F1_SERIE")[1]
	Private cVarPesq		:= Space(TamSX3("F1_CHVNFE")[1])// Space(nTmF1Ser+nTmF1Doc)
	Private aHeadXml		:= {}
	Private aColsXml		:= {}
	Private n				:= 1
	Private cCodForn		:= Space(TamSX3("A2_COD")[1])
	Private cLojForn    	:= Space(TamSX3("A2_LOJA")[1])
	Private aOpcForn		:= {}

	Private oCgcDest,oCgcEmit,oNomEmit,oNomDest,oMunEmit,oMunDest,oMsgNfe,oPesqNf,oNumCte,oSumCte
	Private cMsgNfe			:= ""
	Private nTotalNfe		:= 0
	Private nTotalXml		:= 0
	Private nNumCte			:= nSumCte		:= 0
	Private oTotalNfe,oTotalXml
	Private bRefrXmlT		:= {|| Iif(Pergunte(cPergXml,.T.),(Processa({|| stRefresh() },"Aguarde, procurando registros ...."),Processa({|| stRefrItem() },"Aguarde carregando itens...."),SetFocus(nFocus1)),Nil)}
	Private bRefrXmlF		:= {|| Pergunte(cPergXml,.F.),(Processa({|| stRefresh() },"Aguarde, procurando registros ...."),Processa({|| stRefrItem() },"Aguarde carregando itens...."),SetFocus(nFocus1))}
	Private bRefrPerg		:= {|| Pergunte(cPergXml,.F.),sfSetKeys() }
	Private bRefrItem		:= {|| Pergunte(cPergXml,.F.),(Processa({|| stXMLRefres()},"Aguarde, procurando registros ...."),Processa({|| stRefrItem() },"Aguarde carregando itens...."),nMVPAR12 := MV_PAR12,SetFocus(nFocus1))}
	Private bRefrItAut		:= {|| Pergunte(cPergXml,.F.),(Processa({|| stXMLRefres()},"Aguarde, procurando registros ...."),Processa({|| stRefrItem(.T.) },"Aguarde carregando itens...."),SetFocus(nFocus1))}
	Private lSuperUsr		:= __cUserId $ Iif(File("xmusrxmln_"+cEmpAnt+".usr"),MemoRead("xmusrxmln_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLN","") )  // Verifica usuarios Escrita Fiscal ou Superiores
	Private lComprUsr 		:= __cUserId $ Iif(File("xmusrxmlc_"+cEmpAnt+".usr"),MemoRead("xmusrxmlc_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLC","") )	// Verifica Usuarios habilitados a marcar XML como conferido para lançamento
	Private nAlertPrc		:= 1	// 1-Chama a Pergunta  2-Exibe alerta 3-Nao Exibe alerta no primeiro preço divergente e pergunta se continua para todos
	Private aAlter			:= {}	// Lista de campos com permissão de edição
	Private lSortOrd		:= .F.
	Private lMVXPCNFE		:= GetNewPar("XM_XPCNFE","")
	Private lXMSC7AUT		:= GetNewPar("XM_XSC7AUT",.T.)
	Private cCFOPNPED		:= GetNewPar("XM_CFNPCNF","5906") // Lista de CFOPs de notas de saida recebidas que não precisam de Pedido de Compra
	Private cTESNPED		:= GetNewPar("MV_TESPCNF","") // Lista de TES que não precisam de pedido de compra para lançamento de nota
	Private aRetPoder3		:= &(GetNewPar("XM_RETPOD3",'{{"5906","308"},{"6906","308"}}'))
	Private cOper			:= Padr(GetNewPar("XM_FMPADCP"," "),TamSX3("FM_TIPO")[1])
	Private lAddOper		:= GetNewPar("XM_ADDOPER",.T.) // 16/06/2017 - Parâmetro que permite definer se deve levar o código do TES inteligente ou não para a D1_OPER 
	Private aDupSE2			:= {}
	Private aDupAxSE2		:= {} // Variável para auxilio na validação da condição de pagamento
	Private lDupSE4			:= .F.
	Private nSumSE2			:= 0
	Private aChvNfes		:= {}	// Chaves de Nfe de origem conforme tag refNFE do Xml
	Private lAllPoder3		:= .F.
	Private nFocus1,nFocus2
	Private oBtnDesmbPrd
	Private oBtnSC7
	Private oBtnPrtNf
	Private nPosDtEmis		:= 3
	Private nPosChvNfe		:= 7
	Private nPosOkCte		:= 4
	Private	nPosConfCp		:= 12	// Posição data Conferência compras
	Private nPosTpNota		:= 15
	Private nPosVlrCte		:= 16
	// Variavel especifica para verificar se a empresa em uso é a MadeiraMadeira - devido algumas especificações da rotina
	Private lMadeira		:= "10490181" == Substr(SM0->M0_CGC,1,8) //$ "10490181000135#10490181000216"
	Private nC00Cont		:= GetNewPar("XM_MDFEC00",0) // 0=Start 1=Existe C00 2=Não Existe C00

	// Adicionado em 09/06/2014 - Contemplar opções de numeração de notas com zeros a esquerda ou não
	Private cLeftNil		:= GetNewPar("XM_LEFTNIL","0")
	// Adicionada a chamada de aRotina para os casos de precisar incluir produto via F3
	Private aRotina := StaticCall(MATA010,MenuDef)

	// Verifico se a empresa em cursor tem TSS configurado
	Private cIdentSPED	:= Iif(GetNewPar("XM_TSSEXIS",.T.),StaticCall(SPEDNFE,GetIdEnt)," ")
	// Crio variaveis de uso do Mata103 para validações na tela da Central
	Private cTipo			:= "X"
	Private cA100For		:= Space(TamSX3("F1_FORNECE")[1])
	Private cLoja			:= Space(TamSX3("F1_LOJA")[1])
	Private cEspecie		:= Space(TamSX3("F1_ESPECIE")[1])
	Private dDemissao		:= dDataBase
	Private cFormul			:= "N" //Space(TamSX3("F1_FORMUL")[1])
	Private c103Form		:= "N"

	Private cDirNfe    		:= GetNewPar("XM_DIRXML",IIf(IsSrvUnix(),"/nf-e/", "\Nf-e\"))
	Private cC7OPER			:= GetNewPar("XM_C7OPER","C7_OPER")
	Private lFirstRefIt		:= .T.  // Primeiro refreshe de Itens
	Private	nMVPAR12		:= 1//MV_PAR12
	Private lConsLoja		:= .F. // 15/08/2017 - Adicionado filtro para considerar Loja do fornecedor ou não conforme pergunta MTA103 MV_PAR07 
	
	If !lExecFilChv
		//If !U_CriaTblXml(cBuildXML)// .And. MsgNoYes("Diferença de versão entre o Wizard e o Dicionário de dados da Central XML. Caso continue podem haver erros!")
		If !U_ZCntCTbl(cBuildXML)
			Return
		Endif
	Endif

	
	ValidPerg()
	
	sfPergM103(.F.)
	
	// Forço a criação da pasta caso não exista
	MakeDir(cDirNfe)

	If !lAutoExec
		// Forço a criação de uma pasta local
		MakeDir("C:\Temp_NF-e\")

		If !Pergunte(cPergXml,.T.)
			REturn
		Endif
	Else
		Pergunte(cPergXml,.F.)
		//stSendMail( "marcelolauschner@gmail.com", "Executando processo automático filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" " )
	Endif
	// Seto o valor da variável
	nMVPAR12		:= MV_PAR12

	// Forço o fechamento da Tabela temporaria vindo de erro de outras rotinas.
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	Endif
	
	DbSelectArea("SC7")
	DbSetOrder(1)



	Define MsDialog oDlgXDc From aTmSize[1],aTmSize[2] TO aTmSize[6] , aTmSize[5]  Of oMainWnd Pixel Title OemToAnsi(cBuildXML+ " - Gerenciamento e importação de NF-e/CT-e " + SM0->M0_NOMECOM)

	// Se não for via Schedule	
	If !IsBlind()
		oDlgXDc:lMaximized 	:= .T.
	Endif

	Private oPaneMenu := TPanel():New(0,0,"",oDlgXDc,,.F.,.F.,,,75,200,.T.,.F.)
	oPaneMenu:align := CONTROL_ALIGN_RIGHT

	Private oPaneDados := TPanel():New(0,0,"",oDlgXDc,,.F.,.F.,,,200,200,.T.,.F.)
	oPaneDados:align := CONTROL_ALIGN_ALLCLIENT

	// Cria painel
	Private oPaneRodape := TPanel():New(0,0,"",oDlgXDc,,.F.,.F.,,,680,70,.T.,.F.)
	oPaneRodape:align := CONTROL_ALIGN_BOTTOM


	@ 002,002 SAY "Pesquisar Nº/Chave" of oPaneMenu Pixel
	nAddBtn += 12
	@ nAddBtn,002 MsGet oPesqNf Var cVarPesq Valid stPesquisa(.T./*lPesqManual*/) Size 70,10 of oPaneMenu pixel
	nAddBtn += 12

	// Cria botões do Grupo 'Dados' ( Receber Emails; Filtra dados )
	Private oBtnDad00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnDad01 := TMenuItem():New(oBtnDad00, "Filtra Dados"		 , , , ,{|| (ValidPerg(),Eval(bRefrXmlT)) }, , , , , , , , , .T. )
	Private oBtnDad02 := TMenuItem():New(oBtnDad00, IIf(GetNewPar("XM_DIRPOP",.T.),"Receber Emails","Importar XML/Pasta") , , , ,{||(Processa({|| U_MYEMAIL({mv_par11==1,.F.})},"Aguarde recebendo emails ...."),Eval(bRefrXmlF))}, , , , , , , , , .T.)
	Private oBtnDad03 := TMenuItem():New(oBtnDad00, "Cad.Bloqueios" , , , ,{|| U_XMLBLQCD() }, , , , , , , , , .T.)

	oBtnDad00:add(oBtnDad01)
	Aadd(aButton,{"PRETO"	,oBtnDad01:bAction , "&Filtrar"})
	// Verifica se o botão de Receber e-mails deve ser exibido ao usuário ou não.
	If GetNewPar("XM_EXBBTNP",.T.) .Or. PswAdmin( , ,RetCodUsr()) == 0
		oBtnDad00:add(oBtnDad02)
		Aadd(aButton,{"PRETO"	,oBtnDad02:bAction , "Receber"})
	Endif
	// Adiciona botão de cadastro de bloqueios
	If PswAdmin( , ,RetCodUsr()) == 0
		oBtnDad00:add(oBtnDad03)
		Aadd(aButton,{"PRETO"	,oBtnDad03:bAction , "Cad.Bloqueios"})
	Endif
	@ nAddBtn, 002 Button oBtnDados PROMPT "Dados" Size 70,10 Of oPaneMenu Pixel
	nAddBtn += 12
	oBtnDados:setPopupMenu(oBtnDad00)

	// Cria botções do Grupo 'Danfe/Dacte/CCe'
	Private oBtnView00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnView01 := TMenuItem():New(oBtnView00, "Danfe/Dacte Pdf Original" , , , ,{||( stViewNfe(1),Eval(bRefrPerg),SetFocus(nFocus1))}, , , , , , , , , .T.)
	Private oBtnView02 := TMenuItem():New(oBtnView00, "Danfe/Dacte via XML"		 , , , ,{||( stViewNfe(2),Eval(bRefrPerg),SetFocus(nFocus1))}, , , , , , , , , .T. )
	Private oBtnView03 := TMenuItem():New(oBtnView00, "Impressão Carta CCe"		 , , , ,{||( stViewNfe(3),Eval(bRefrPerg),SetFocus(nFocus1))}, , , , , , , , , .T. )
	Private oBtnView04 := TMenuItem():New(oBtnView00, "Ver XML Estruturado"		 , , , ,{||( stViewNfe(4),Eval(bRefrPerg),SetFocus(nFocus1))}, , , , , , , , , .T. )
	oBtnView00:add(oBtnView01)
	Aadd(aButton,{"PRETO"	,oBtnView01:bAction , "Pdf Orig"})
	oBtnView00:add(oBtnView02)
	Aadd(aButton,{"PRETO"	,oBtnView02:bAction , "&Danfe"})
	oBtnView00:add(oBtnView03)
	Aadd(aButton,{"PRETO"	,oBtnView03:bAction , "CCe"})
	oBtnView00:add(oBtnView04)
	Aadd(aButton,{"PRETO"	,oBtnView04:bAction , "XML"})
	@ nAddBtn, 002 Button oBtnView PROMPT "Danfe/Dacte/CCe" Size 70,10  of oPaneMenu Pixel
	nAddBtn += 12
	oBtnView:setPopupMenu(oBtnView00)

	
	
	// Melhoria 08/08/2016 - Função que verifica se o usuário tem acessos pelo Menu Padrão do módulo Compras as rotina de Documento de entrada. 
	aAcessUsr	:= u_XmlXnucAcess("02","MATA103","SIGACOM")
	// Se não tem módulo Compras, ainda tenta módulo Estoque/Custos
	If Len(aAcessUsr) == 0
		aAcessUsr	:= u_XmlXnucAcess("04","MATA103","SIGAEST")
	Endif

	aAcessUsr1	:= u_XmlXnucAcess("02","MATA140","SIGACOM")
	// Se não tem módulo Compras, ainda tenta módulo Estoque/Custos
	If Len(aAcessUsr1) == 0
		aAcessUsr1	:= u_XmlXnucAcess("04","MATA140","SIGAEST")
	Endif
	
	/*MsgAlert(MPUserHasAccess("MATA103",;//cFunction - Nome da função(de menu) que deseja verificar o acesso, por exemplo MATA030
					3,;//nOpc - Código da posição do array do arotina que será avaliado 
					,;//cCodUser - Código do usuario, caso não seja informado, sera avaliado o usuario corrente logado.
					.T.,;//lShowMsg - Indica se deve apresentar mensagem padrão quando o usuário não possuir acesso
					.F.))//lAudit - Indica se deve logar na auditoria caso o usuário não tenha acesso.)
	*/ 

	// Cria botões do Grupo 'Documento Entrada'
	Private oBtnDoc00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnDoc01 := TMenuItem():New(oBtnDoc00, "Gerar/Incluir"	, , , ,{|| ( If(stGeraNfe(),Eval(bRefrItem),Eval(bRefrPerg)))  }, , , , , , , , , .T. )
	Private oBtnDoc02 := TMenuItem():New(oBtnDoc00, "Classif.Pré-nota" , , , ,{||(U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],{},.T.,.T.) ,Eval(bRefrItem))}, , , , , , , , , .T.)
	Private oBtnDoc03 := TMenuItem():New(oBtnDoc00, "Visualizar" 	, , , ,{||(U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],{},.T.),Eval(bRefrPerg))}, , , , , , , , , .T.)
	Private oBtnDoc04 := TMenuItem():New(oBtnDoc00, "Excluir" 	, , , ,{||(Iif(sfMata116(.T.),.T.,U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],{},.T.,.T.,.T.)) ,Eval(bRefrItem))}, , , , , , , , , .T.)
	Private oBtnDoc05 := TMenuItem():New(oBtnDoc00, "Imprimir" 	, , , ,{||sfPrintSF1() }, , , , , , , , , .T.)
	Private oBtnDoc06 := TMenuItem():New(oBtnDoc00, "Conv.CFOP" , , , ,{|| U_XMLCNVCF() }, , , , , , , , , .T.)
	//																						        cChaveNfe,                      aItems,lVisual,lClassif,lExclui,lWhen,aCabSF1,lEstorna)
	Private oBtnDoc07 := TMenuItem():New(oBtnDoc00, "Estorna Classif." , , , ,{|| U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],{}    ,.T.    ,.T.     ,.T.    ,     ,       ,.T.) ,Eval(bRefrItem) }, , , , , , , , , .T.)

	Private oBtnDoc08 := TMenuItem():New(oBtnDoc00, "Lancto Contabil" 	, , , ,{||( sfConCT2(.F.), Eval(bRefrPerg))}, , , , , , , , , .T.)

	Private oBtnDoc09 := TMenuItem():New(oBtnDoc00, "Alterar Pré-nota" , , , ,{||(U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],{},.T.,.F.,.F.,.T.,{},.F.,.T.) ,Eval(bRefrItem))}, , , , , , , , , .T.)
																				//XMLMT103(cChaveNfe,aItems,lVisual,lClassif,lExclui,lWhen,aCabSF1,lEstorna,lAltPreNF)

	If lSuperUsr
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],3,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc01)
			Aadd(aButton,{"PRETO"	,oBtnDoc01:bAction , "&Incluir"})
		Endif
		//If FWChkFuncAccess( "MATA103", 3, .T.)
		//	MsgAlert("Permissão Mata103")
		//Endif
		
		//If MPUserHasAccess("MATA103",3,__cUserId,.F.,.F.)
		//	MsgAlert("Permissão mata103 - função mpuserhasaccess")
		//Endif
		
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],4,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc02)
			Aadd(aButton,{"PRETO"	,oBtnDoc02:bAction , "Classif"})
		Endif
		
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],4,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc09)
			Aadd(aButton,{"PRETO"	,oBtnDoc09:bAction , "Altera"})
		Endif

		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],7,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc07)
			Aadd(aButton,{"PRETO"	,oBtnDoc07:bAction , "Estorna"})
		Endif

		oBtnDoc00:add(oBtnDoc03)
		Aadd(aButton,{"PRETO"	,oBtnDoc03:bAction , "&Visual"})
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],6,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc04)
			Aadd(aButton,{"PRETO"	,oBtnDoc04:bAction , "Excluir"})
		Endif
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],7,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc05)
			Aadd(aButton,{"PRETO"	,oBtnDoc05:bAction , "Imprimir"})
		Endif
		oBtnDoc00:add(oBtnDoc06)
		Aadd(aButton,{"PRETO"	,oBtnDoc06:bAction , "Conv.CFOP"})

		// Verifica se o usuário tem acesso ao Módulo CTB e rotina de Lançamento contábil
		aAcessUsr	:= u_XmlXnucAcess("34","CTBA102","SIGACTB")

		If (Len(aAcessUsr) > 0) .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc08)
			Aadd(aButton,{"PRETO"	,oBtnDoc08:bAction , "Lcto Contabil"})
		Endif

	ElseIf lComprUsr .And. GetNewPar("XM_MSGPRNF",.T.)
		oBtnDoc00:add(oBtnDoc01)
		Aadd(aButton,{"PRETO"	,oBtnDoc01:bAction , "&Incluir"})
		oBtnDoc00:add(oBtnDoc03)
		Aadd(aButton,{"PRETO"	,oBtnDoc03:bAction , "&Visual"})
		If (Len(aAcessUsr) > 0 .And. Upper(Substr(aAcessUsr[1,2],7,1)) == "X") .Or. !lXnuVldAc
			oBtnDoc00:add(oBtnDoc05)
			Aadd(aButton,{"PRETO"	,oBtnDoc05:bAction , "Imprimir"})
		Endif
	Else
		oBtnDoc00:add(oBtnDoc03)
		Aadd(aButton,{"PRETO"	,oBtnDoc03:bAction , "&Visual"})
		oBtnDoc00:add(oBtnDoc05)
		Aadd(aButton,{"PRETO"	,oBtnDoc05:bAction , "Imprimir"})

	Endif
	@ nAddBtn, 002 Button oBtnDoc PROMPT "Documento Entrada" Size 70,10 Of oPaneMenu Pixel
	nAddBtn += 12
	oBtnDoc:setPopupMenu(oBtnDoc00)




	// Cria botões do Grupo 'Compras'
	Private oBtnCom00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnCom01 := TMenuItem():New(oBtnCom00, "Gravar Alterações [F5]" , , , ,{|| Processa({|| stGrvItens() },"Aguarde gravação...") }, , , , , , , , , .T. )
	Private oBtnCom02 := TMenuItem():New(oBtnCom00, "Concluir Conferência"		 , , , ,{|| (sfConferid(),Eval(bRefrItem)) }, , , , , , , , , .T. )
	Private oBtnCom03 := TMenuItem():New(oBtnCom00, "Gerar Ped.Compra"		 , , , ,{|| (sfMata120()) }, , , , , , , , , .T. )
	Private oBtnCom04 := TMenuItem():New(oBtnCom00, "Ped.Nf/Origem [F6] "		 , , , ,{|| (U_VldItemPc(,,,,,.T.),SetFocus(nFocus2)) }, , , , , , , , , .T. )
	Private oBtnCom05 := TMenuItem():New(oBtnCom00, "Fracionar Quantidade[F7]" , , , ,{|| sfFracQte() }, , , , , , , , , .T. )
	Private oBtnCom06 := TMenuItem():New(oBtnCom00, "Cadastrar Fornecedor" , , , ,{|| sfCadSA2() }, , , , , , , , , .T. )
	Private oBtnCom07 := TMenuItem():New(oBtnCom00, "Recarregar Itens [F8]" , , , ,{|| sfRefItens() }, , , , , , , , , .T. )

	If lComprUsr
		oBtnCom00:add(oBtnCom01)
		Aadd(aButton,{"PRETO"	,oBtnCom01:bAction , "Salvar"})
		oBtnCom00:add(oBtnCom02)
		Aadd(aButton,{"PRETO"	,oBtnCom02:bAction , "Confere"})

		If GetNewPar("XM_GERASC7",.F.)
			oBtnCom00:add(oBtnCom03)
			Aadd(aButton,{"PRETO"	,oBtnCom03:bAction , "Gera.PC"})
		Endif
		oBtnCom00:add(oBtnCom04)
		Aadd(aButton,{"PRETO"	,oBtnCom04:bAction , "Vincular"})
		oBtnCom00:add(oBtnCom05)
		Aadd(aButton,{"PRETO"	,oBtnCom05:bAction , "Fraciona"})
		oBtnCom00:add(oBtnCom06)
		Aadd(aButton,{"PRETO"	,oBtnCom06:bAction , "Fornecedor"})

		oBtnCom00:add(oBtnCom07)
		Aadd(aButton,{"PRETO"	,oBtnCom07:bAction , "Refresh Itens"})
	Else
		oBtnCom00:add(oBtnCom04)
		Aadd(aButton,{"PRETO"	,oBtnCom04:bAction , "Vincular"})
	Endif
	@ nAddBtn, 002 Button oBtnCompras PROMPT "Compras" Size 70,10 Of oPaneMenu Pixel
	nAddBtn += 12
	oBtnCompras:setPopupMenu(oBtnCom00)


	// Cria botões do Grupo 'Fiscal'
	Private oBtnFis00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnFis01 := TMenuItem():New(oBtnFis00, "Consultar Sefaz"		 , , , ,{|| (stConSefaz(aArqXml[oArqXml:nAt,nPosChvNfe]),Eval(bRefrItem)) }, , , , , , , , , .T. )
	Private oBtnFis02 := TMenuItem():New(oBtnFis00, "Edi Conemb"		 , , , ,{|| (sfEdiCTRC(),Eval(bRefrXmlF)) }, , , , , , , , , .T. )
	Private oBtnFis03 := TMenuItem():New(oBtnFis00, "Rejeitar XML "		 , , , ,{|| (stRejeita(aArqXml[oArqXml:nAt,nPosChvNfe]),Eval(bRefrItem)) }, , , , , , , , , .T. )
	Private oBtnFis04 := TMenuItem():New(oBtnFis00, "Alterar Tipo Documento" , , , ,{|| (sfAltTipDC(),Eval(bRefrItem)) }, , , , , , , , , .T. )
	Private oBtnFis05 := TMenuItem():New(oBtnFis00, "Rel.Auditoria"		 , , , ,{|| (U_GMCOMR05(),Eval(bRefrPerg)) }, , , , , , , , , .T. )
	
	If lSuperUsr
		oBtnFis00:add(oBtnFis01)
		Aadd(aButton,{"PRETO"	,oBtnFis01:bAction , "&Sefaz"})
		oBtnFis00:add(oBtnFis02)
		Aadd(aButton,{"PRETO"	,oBtnFis02:bAction , "Conemb"})
		oBtnFis00:add(oBtnFis03)
		Aadd(aButton,{"PRETO"	,oBtnFis03:bAction , "Rejeita"})
		oBtnFis00:add(oBtnFis04)
		Aadd(aButton,{"PRETO"	,oBtnFis04:bAction , "Troca Tipo"})
		oBtnFis00:add(oBtnFis05)
		Aadd(aButton,{"PRETO"	,oBtnFis05:bAction , "Auditoria"})
		@ nAddBtn, 002 Button oBtnFis PROMPT "Fiscal" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnFis:setPopupMenu(oBtnFis00)
	ElseIf lComprUsr .And. GetNewPar("XM_MSGPRNF",.T.) .And. !lSuperUsr
		oBtnFis00:add(oBtnFis03)
		Aadd(aButton,{"PRETO"	,oBtnFis03:bAction , "Rejeita"})
		@ nAddBtn, 002 Button oBtnFis PROMPT "Fiscal" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnFis:setPopupMenu(oBtnFis00)
	Endif

	// Cria botões do Grupo 'Manifesto'
	Private oBtnMan00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnMan01 := TMenuItem():New(oBtnMan00, "Rotina Padrão"    , , , ,{|| (IIf(nC00Cont==1,SPEDMANIFE(),Nil),Eval(bRefrItem))}, , , , , , , , , .T. )
	Private oBtnMan02 := TMenuItem():New(oBtnMan00, "Manifestar"		 , , , ,{|| (IIf(nC00Cont==1,U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/aArqXml[oArqXml:nAt,nPosChvNfe]),Nil),U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/aArqXml[oArqXml:nAt,nPosChvNfe]),Eval(bRefrItem))}, , , , , , , , , .T. )
	Private oBtnMan03 := TMenuItem():New(oBtnMan00, "Sincronizar"		 , , , ,{|| (Iif(nC00Cont==1,u_XMLMDFE2(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*cInChave*/aArqXml[oArqXml:nAt,nPosChvNfe],.T.),Nil),Eval(bRefrItem))}, , , , , , , , , .T. )
	Private oBtnMan04 := TMenuItem():New(oBtnMan00, "Monitorar"		     , , , ,{|| (Iif(nC00Cont==1,U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/aArqXml[oArqXml:nAt,nPosChvNfe]),Nil),Eval(bRefrItem))}, , , , , , , , , .T. )
	Private oBtnMan05 := TMenuItem():New(oBtnMan00, "Baixar XML"	     , , , ,{|| (Iif(nC00Cont==1 .And. FindFunction("GzStrDecomp") ,sfBxXml(),Nil),Eval(bRefrItem))}, , , , , , , , , .T. )
	Private oBtnMan06 := TMenuItem():New(oBtnMan00, "Manifesto"		     , , , ,{|| (Iif(nC00Cont==1,U_XMLMDFE(),Nil),Eval(bRefrItem))}, , , , , , , , , .T. )

	//MonitEven(cChvIni,cChvFin,cCodEve)
	If lSuperUsr
		oBtnMan00:add(oBtnMan01)
		Aadd(aButton,{"PRETO"	,oBtnMan01:bAction , "Manifesto"})
		oBtnMan00:add(oBtnMan02)
		Aadd(aButton,{"PRETO"	,oBtnMan02:bAction , "Manifestar"})
		oBtnMan00:add(oBtnMan03)
		Aadd(aButton,{"PRETO"	,oBtnMan03:bAction , "Sinc.Dados"})
		oBtnMan00:add(oBtnMan04)
		Aadd(aButton,{"PRETO"	,oBtnMan04:bAction , "&Monitorar"})
		oBtnMan00:add(oBtnMan05)
		Aadd(aButton,{"PRETO"	,oBtnMan05:bAction , "Baixar XML"})
		oBtnMan00:add(oBtnMan06)

		@ nAddBtn, 002 Button oBtnMan PROMPT "Manifestos" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnMan:setPopupMenu(oBtnMan00)
	ElseIf lComprUsr
		oBtnMan00:add(oBtnMan01)
		Aadd(aButton,{"PRETO"	,oBtnMan01:bAction , "Manifesto"})
		@ nAddBtn, 002 Button oBtnMan PROMPT "Manifestos" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnMan:setPopupMenu(oBtnMan00)
	Endif


	// Cria botões do Grupo 'Exportar'
	Private oBtnExp00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnExp01 := TMenuItem():New(oBtnExp00, "Exportar Xml´s"	 , , , ,{|| Processa({||stExpXml(1),"Gerando exportação dos dados...."})}, , , , , , , , , .T. )
	Private oBtnExp02 := TMenuItem():New(oBtnExp00, "Lista NFe/CTe"	 , , , ,{|| Processa({||stExpXml(2,aCabXml),"Gerando exportação dos dados...."}) }, , , , , , , , , .T. )
	Private oBtnExp03 := TMenuItem():New(oBtnExp00, "Itens NFe"		 	 , , , ,{|| stExpExcel() }, , , , , , , , , .T. )

	If lSuperUsr
		oBtnExp00:add(oBtnExp01)
		Aadd(aButton,{"PRETO"	,oBtnExp01:bAction , "Exp.XMLs"})
		oBtnExp00:add(oBtnExp02)
		Aadd(aButton,{"PRETO"	,oBtnExp02:bAction , "Excel NFes"})
		oBtnExp00:add(oBtnExp03)
		Aadd(aButton,{"PRETO"	,oBtnExp03:bAction , "Excel Itens"})

		@ nAddBtn, 002 Button oBtnExp PROMPT "Exportar" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnExp:setPopupMenu(oBtnExp00)
	Else
		oBtnExp00:add(oBtnExp02)
		Aadd(aButton,{"PRETO"	,oBtnExp02:bAction , "Excel NFes"})
		oBtnExp00:add(oBtnExp03)
		Aadd(aButton,{"PRETO"	,oBtnExp03:bAction , "Excel Itens"})

		@ nAddBtn, 002 Button oBtnExp PROMPT "Exportar" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnExp:setPopupMenu(oBtnExp00)
	Endif

	// Cria botões do Grupo 'Consultar'
	Private oBtnCon00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnCon01 := TMenuItem():New(oBtnCon00, "Histórico Produto"		 , , , ,{|| sfConProd(1)}, , , , , , , , , .T. )
	Private oBtnCon02 := TMenuItem():New(oBtnCon00, "Cadastro Produto"	 , , , ,{|| sfConProd(2) }, , , , , , , , , .T. )
	Private oBtnCon03 := TMenuItem():New(oBtnCon00, "NF X CTe"		 , , , ,{|| sfViewCteXNf() }, , , , , , , , , .T. )
	Private oBtnCon04 := TMenuItem():New(oBtnCon00, "Cadastro Fornecedor"	 , , , ,{|| sfConForn(2) }, , , , , , , , , .T. )
	
	If lSuperUsr .Or. lComprUsr
		oBtnCon00:add(oBtnCon01)
		Aadd(aButton,{"PRETO"	,oBtnCon01:bAction , "&Hist.Prod"})
		oBtnCon00:add(oBtnCon02)
		Aadd(aButton,{"PRETO"	,oBtnCon02:bAction , "Cad.&Prod"})
		oBtnCon00:add(oBtnCon03)
		Aadd(aButton,{"PRETO"	,oBtnCon03:bAction , "CTe X NFe"})
		oBtnCon00:add(oBtnCon04)
		Aadd(aButton,{"PRETO"	,oBtnCon04:bAction , "Cad.Fornecedor"})
		
		@ nAddBtn, 002 Button oBtnCon PROMPT "Consulta" Size 70,10 Of oPaneMenu Pixel
		nAddBtn += 12
		oBtnCon:setPopupMenu(oBtnCon00)
	Endif


	// Cria botões do Grupo 'Relatórios'
	Private oBtnRel00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnRel01 := TMenuItem():New(oBtnRel00, "Rel.Controle"		 , , , ,{|| (U_GMCOMR01(),Eval(bRefrPerg)) }, , , , , , , , , .T. )
	Private oBtnRel02 := TMenuItem():New(oBtnRel00, "Rel.Divergência" , , , ,{|| sfReport() }, , , , , , , , , .T. )
	Private oBtnRel03 := TMenuItem():New(oBtnRel00, "Rel.Manifestacao"		 , , , ,{|| (U_GMCOMR02(),Eval(bRefrPerg)) }, , , , , , , , , .T. )
	Private oBtnRel04 := TMenuItem():New(oBtnRel00, "Rel.Duplicatas"		 , , , ,{|| (U_GMCOMR03(),Eval(bRefrPerg)) }, , , , , , , , , .T. )
	Private oBtnRel05 := TMenuItem():New(oBtnRel00, "Rel.Conf.Cega"		 , , , ,{|| (U_GMCOMR04(aArqXml[oArqXml:nAt,nPosChvNfe]),Eval(bRefrPerg)) }, , , , , , , , , .T. )
	
	oBtnRel00:add(oBtnRel01)
	Aadd(aButton,{"PRETO"	,oBtnRel01:bAction , "Rel.XMLs"})
	oBtnRel00:add(oBtnRel02)
	Aadd(aButton,{"PRETO"	,oBtnRel02:bAction , "Rel.PCxNF"})
	oBtnRel00:add(oBtnRel03)
	Aadd(aButton,{"PRETO"	,oBtnRel03:bAction , "Rel.Manif"})
	oBtnRel00:add(oBtnRel04)
	Aadd(aButton,{"PRETO"	,oBtnRel04:bAction , "Rel.Duplic"})
	oBtnRel00:add(oBtnRel05)
	Aadd(aButton,{"PRETO"	,oBtnRel05:bAction , "Conf.Cega"})
	
	@ nAddBtn, 002 Button oBtnRela PROMPT "Relatórios" Size 70,10 Of oPaneMenu Pixel
	nAddBtn += 12
	oBtnRela:setPopupMenu(oBtnRel00)

	// Cria botões do Grupo 'Legendas'
	Private oBtnLeg00 := tMenu():new(0, 0, 0, 0, .T.,"",Nil)
	Private oBtnLeg01 := TMenuItem():New(oBtnLeg00, "Legenda NFe´s"		 , , , ,{|| sfLegenda() }, , , , , , , , , .T. )
	Private oBtnLeg02 := TMenuItem():New(oBtnLeg00, "Legenda Itens" , , , ,{|| sfLegItens() }, , , , , , , , , .T. )
	Private oBtnLeg03 := TMenuItem():New(oBtnLeg00, "Legenda Manifesto", , , ,{|| sfLegManif() }, , , , , , , , , .T. )


	oBtnLeg00:add(oBtnLeg01)
	Aadd(aButton,{"PRETO"	,oBtnLeg01:bAction , "Leg.NFe"})
	oBtnLeg00:add(oBtnLeg02)
	Aadd(aButton,{"PRETO"	,oBtnLeg02:bAction , "Leg.Itens"})
	oBtnLeg00:add(oBtnLeg03)
	Aadd(aButton,{"PRETO"	,oBtnLeg03:bAction , "Leg.Manif"})

	@ nAddBtn, 002 Button oBtnLeg PROMPT "Legendas" Size 70,10 Of oPaneMenu Pixel
	nAddBtn += 12
	oBtnLeg:setPopupMenu(oBtnLeg00)

	// Adição de ponto de entrada que permite Adicionar/Remover/Alterar dados da variável aButton
	If ExistBlock("XMLCTE07")
		aBtnUsr := ExecBlock("XMLCTE07",.F.,.F.,{aClone(aButton)})
		If Type("aBtnUsr")== "A" .And. Len(aBtnUsr) > 0
			aButton	:= aClone(aBtnUsr)
		Endif
	Endif


	@ nAddBtn, 002 Button oBtnSair PROMPT "Sair" Size 70,10 Action(oDlgXDc:End()) Of oPaneMenu Pixel
	nAddBtn += 12


	/*A ordem para montar o aHeader é essa:

	aAdd(aColunas, "SX3->X3_TITULO")
	aAdd(aColunas, "SX3->X3_CAMPO")
	aAdd(aColunas, "SX3->X3_PICTURE")
	aAdd(aColunas, "SX3->X3_TAMANHO")
	aAdd(aColunas, "SX3->X3_DECIMAL")
	aAdd(aColunas, "SX3->X3_VALID")
	aAdd(aColunas, "SX3->X3_USADO")
	aAdd(aColunas, "SX3->X3_TIPO")
	aAdd(aColunas, "SX3->X3_F3")
	aAdd(aColunas, "SX3->X3_CONTEXT")
	aAdd(aColunas, "SX3->X3_CBOX")
	aAdd(aColunas, "SX3->X3_RELACAO")
	aAdd(aColunas, "SX3->X3_WHEN")
	aAdd(aColunas, "SX3->X3_VISUAL")
	aAdd(aColunas, "SX3->X3_VLDUSER")
	aAdd(aColunas, "SX3->X3_PICTVAR")
	aAdd(aColunas, "IIf(!Empty(SX3->X3_OBRIGAT),.T.,.F.)")

	Eu gosto de utilizar a função apBuildHeader quando o aHeader é baseado no dicionário de dados. Essa função monta o aHeader automaticamente conforme o dicionário!

	aHeader := apBuildHeader(<cTabela>)

	Att.

	Gilberto Rafael de Souza
	*/
	//Aadd(aHeadXml	,{ 						 SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	// 1
	Aadd(aHeadXml		,{"Ok"					,"OK"		   		,"@BMP"     		,1					,0					,""					,				,"C"			,""				,""})
	// 2
	Aadd(aHeadXml		,{"Item"				,"XIT_ITEM"		,"@!"     			,04					,0					,"AllwaysFalse()"	,				,"C"		 	,""				,"V"})
	Private nPxItem    	:= Len(aHeadXml)
	// 3
	Aadd(aHeadXml		,{"Ref.Fornecedor"	,"XIT_CODNFE"		,"@!"	 			,20					,0					,"AllwaysTrue()" 	,				,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_CODNFE")
	Private nPxCodNfe 	:= Len(aHeadXml)

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("D1_COD")
	// 4 - Código Produto no Protheus
	Aadd(aHeadXml		,{"Ref.Protheus"		,"D1_COD"			,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"U_VldSA5(oMulti:aCols[oMulti:nAt,nPxCodNfe],cCodForn,cLojForn,oMulti:aCols[oMulti:nAt,nPxDescri]) .And. U_XmlVldTt(5)",,"C",GetNewPar("XM_F3SB1","SB1"),""})
	Aadd(aAlter,"D1_COD")
	Private nPxProd	    := Len(aHeadXml)

	// 5 - Descrição Produto no Xml
	Aadd(aHeadXml		,{"Descrição NF-e"	,"XIT_DESCRI"		,"@!"	 			,50					,0					,"AllwaysTrue()"					,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_DESCRI")
	Private nPxDescri  	:= Len(aHeadXml)

	// 6 - Quantidade no Xml
	DbSeek("D1_QUANT")
	Aadd(aHeadXml		,{"Qte NFe"			,"XIT_QTENFE"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"AllwaysTrue()"	,				,"N"			,""				,"V"})
	Aadd(aAlter,"XIT_QTENFE")
	Private nPxQteNfe  	:= Len(aHeadXml)

	// 7 - Unidade Medida no Xml
	Aadd(aHeadXml		,{"UM NFe"				,"XIT_UMNFE"		,"@!"	 			,15					,0					,"AllwaysTrue()"	,				,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_UMNFE")
	Private nPxUMNFe   	:= Len(aHeadXml)

	// 8 - Preço Unitário XML
	DbSeek("D1_VUNIT")
	Aadd(aHeadXml		,{"R$ Unit.NFe"		,"XIT_PRCNFE"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"AllwaysTrue()"	,				,"N"			,""				,"V"})
	Aadd(aAlter,"XIT_PRCNFE")
	Private nPxPrcNfe		:= Len(aHeadXml)

	// 9 - Preço Total XML
	DbSeek("D1_TOTAL")
	Aadd(aHeadXml		,{"R$ Tot.NFe"  		,"XIT_TOTAL"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"AllwaysTrue()"	,				,"N"			,""				,"V"})
	Aadd(aAlter,"XIT_TOTAL")
	Private nPxTotNfe  	:= Len(aHeadXml)

	// 10 - Quantidade
	DbSeek("D1_QUANT")
	Aadd(aHeadXml		,{"Quantidade"		,"D1_QUANT"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"U_XmlVldTt(1)"	,				,"N"			,""				,"V"})
	Aadd(aAlter,"D1_QUANT")
	Private nPxQte		:= Len(aHeadXml)

	// 11 - Unidade Medida
	DbSeek("D1_UM")
	Aadd(aHeadXml		,{"Unid.Medida"		,"D1_UM"			,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,""					,				,"C"			,""				,"V"})
	Aadd(aAlter,"D1_UM")
	Private nPxUm			:= Len(aHeadXml)

	// 12 - Preço Unitário
	DBseek("D1_VUNIT")
	Aadd(aHeadXml		,{"Preço Unitário"	,"D1_VUNIT"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO,	SX3->X3_DECIMAL	,"U_XmlVldTt(2)"	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO ,        ,         ,          ,          , /*IIf(!Empty(SX3->X3_OBRIGAT),.T.,.F.)*/})
	Aadd(aAlter,"D1_VUNIT")
	Private nPxPrunit  	:= Len(aHeadXml)

	// 13 - Valor Total do Item
	DbSeek("D1_TOTAL")
	Aadd(aHeadXml		,{"Total Item"		,"D1_TOTAL "		,SX3->X3_PICTURE	,SX3->X3_TAMANHO,	SX3->X3_DECIMAL	,"U_XmlVldTt(3)"	,				,"N"			,""				,"V"})
	Aadd(aAlter,"D1_TOTAL")
	Private nPxTotal   	:= Len(aHeadXml)

	// 14 - Tipo de Operação
	DbSeek("D1_OPER")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,"XIT_OPER"		,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"U_XmlVldTt(4)"	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Aadd(aAlter,"XIT_OPER")
	Private nPxD1Oper     := Len(aHeadXml)

	// 15 - Código do TES X3Obrigat("D1_TES")
	DbSeek("D1_TES")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"Vazio() .Or. (ExistCpo('SF4',M->D1_TES) .And. U_VlsSF4())",SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO ,        ,         ,          ,          , .F. /*IIf(!Empty(SX3->X3_OBRIGAT),.T.,.F.)*/})
	Aadd(aAlter,"D1_TES")
	Private nPxD1Tes     := Len(aHeadXml)

	// 16 - Código do CFOP XML
	Aadd(aHeadXml		,{"CFOP NF-e"			,"XIT_CFNFE"		,"@!"	 			,05					,0					,"AllwaysTrue()"	,				,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_CFNFE")
	Private nPxCFNFe   	:= Len(aHeadXml)

	// 17 - Código do CFOP
	Aadd(aHeadXml		,{"CFOP Entrada"		,"D1_CF"			,"@!"	 			,05					,0					,"AllwaysTrue()"	,				,"C"			,""				,"V"})
	Aadd(aAlter,"D1_CF")
	Private nPxCF	   		:= Len(aHeadXml)

	// 18 - Código do NCM
	Aadd(aHeadXml		,{"NCM"				,"XIT_NCM"			,"@!"	 			,10					,0					,"AllwaysFalse()",				,"C"			,""				,"V"})
	Private nPxNcm		:= Len(aHeadXml)

	// 19 - Número Pedido Compra
	Aadd(aHeadXml		,{"Pedido Compra"		,"XIT_PEDIDO"		,"@!"	 			,06					,0					,"U_VldItemPc(oMulti:nAt)",		,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_PEDIDO")
	Private nPxPedido		:= Len(aHeadXml)

	// 20 - Item pedido compra
	Aadd(aHeadXml		,{"Item PC"			,"XIT_ITEMPC"		,"@!"	 			,04					,0					,""					,				,"C"			,""				,"V"})
	Aadd(aAlter,"XIT_ITEMPC")
	Private nPxItemPc		:= Len(aHeadXml)

	// 21 - Valor do Desconto
	Aadd(aHeadXml		,{"R$ Desconto"		,"XIT_VALDES"		,"@E 99,999.99" 	,09					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxValDesc 	:= Len(aHeadXml)

	// 22 - Base Calculo Icms
	Aadd(aHeadXml		,{"Base ICMS"			,"XIT_BASICM"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBasIcm  	:= Len(aHeadXml)

	// 23 - Percentual Icms
	Aadd(aHeadXml		,{"% ICMS"				,"XIT_PICM  "		,"@E 999.99"		,05					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPicm		:= Len(aHeadXml)

	// 24 - Valor do Icms
	Aadd(aHeadXml		,{"R$ ICMS"			,"XIT_VALICM"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxValIcm		:= Len(aHeadXml)

	// 25 - Valor do Icms Simples Nacion
	Aadd(aHeadXml		,{"% CrdICMS SN"		,"XIT_PICMSN"		,"@E 999.99"		 ,5					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPIcmSN	:= Len(aHeadXml)

	// 26 - Valor do Icms Simples Nacion
	Aadd(aHeadXml		,{"CrdICMS Simp.Nac.","XIT_CICMSN"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxCrdIcmSN	:= Len(aHeadXml)

	// 27 - Base Calculo IPI
	Aadd(aHeadXml		,{"Base IPI"			,"XIT_BASIPI"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBasIpi		:= Len(aHeadXml)

	// 28 - Percentual IPI
	Aadd(aHeadXml		,{"% IPI"				,"XIT_PIPI  "		,"@E 999.99"		,05					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPIpi		:= Len(aHeadXml)

	// 29 - Valor do IPI
	Aadd(aHeadXml		,{"R$ IPI"				,"XIT_VALIPI"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxValIpi		:= Len(aHeadXml)

	// 30 - Base Calculo PIS
	Aadd(aHeadXml		,{"Base PIS"			,"XIT_BASPIS"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBasPis		:= Len(aHeadXml)

	// 31 - Percentual PIS
	Aadd(aHeadXml		,{"% PIS"				,"XIT_PPIS"		,"@E 999.99"		,05					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPPis		:= Len(aHeadXml)

	// 32 - Valor do PIS
	Aadd(aHeadXml		,{"R$ PIS"				,"XIT_VALPIS"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxValPis		:= Len(aHeadXml)

	// 33 - Base Calculo Cofins
	Aadd(aHeadXml		,{"Base Cofins"		,"XIT_BASCOF"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBasCof		:= Len(aHeadXml)

	// 34 - Percentual Cofins
	Aadd(aHeadXml		,{"% Cofins"			,"XIT_PCOF"		,"@E 999.99"		,05					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPCof		:= Len(aHeadXml)

	// 35 - Valor do Cofins
	Aadd(aHeadXml		,{"R$ Cofins"			,"XIT_VALCOF"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxValCof		:= Len(aHeadXml)

	// 36 - Base Calculo Icms Retido
	Aadd(aHeadXml		,{"Base Retido"		,"XIT_BASRET"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBasRet		:= Len(aHeadXml)

	// 37 - Percentual Icms Retido
	Aadd(aHeadXml		,{"Aliq.Sol"			,"XIT_PICMST"		,"@E 999.99"		,07					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxPICMSST	:= Len(aHeadXml)

	// 38 - Percentual MVA
	Aadd(aHeadXml		,{"% MVA"				,"XIT_PMVA"		,"@E 999.99"		,07					,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxMva		:= Len(aHeadXml)

	// 39 - Valor do Icms Retido
	Aadd(aHeadXml		,{"R$ ICMS ST"		,"XIT_VALRET"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxIcmRet		:= Len(aHeadXml)

	// 40 - Classificação fiscal
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("D1_CLASFIS")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"AllwaysFalse()",SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO ,        ,         ,          ,          , .F. /*IIf(!Empty(SX3->X3_OBRIGAT),.T.,.F.)*/})
	Private nPxCST		:= Len(aHeadXml)

	// 41 - Nota fiscal de Origem
	DbSeek("D1_NFORI")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxNfOri   := Len(aHeadXml)
	Aadd(aAlter,"D1_NFORI")

	// 42 - Série Nota de Origem
	DbSeek("D1_SERIORI")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxSerOri  := Len(aHeadXml)
	Aadd(aAlter,"D1_SERIORI")

	// 43 - Item Nota de Origem
	DbSeek("D1_ITEMORI")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxItemOri := Len(aHeadXml)
	Aadd(aAlter,"D1_ITEMORI")

	// 44 - Armazém
	DbSeek("D1_LOCAL")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxLocal := Len(aHeadXml)
	Aadd(aAlter,"D1_LOCAL")

	// 45 - Valor Desconto
	DbSeek("D1_VALDESC")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxVlDesc := Len(aHeadXml)
	Aadd(aAlter,"D1_VALDESC")

	// 46 - Percentual Desconto
	DbSeek("D1_DESC")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VALID	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxDesc    := Len(aHeadXml)

	// 47 - Id Poder Terceiros
	DbSeek("D1_IDENTB6")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxIdentB6    := Len(aHeadXml)

	// 48 - Base Imposto Importação
	Aadd(aHeadXml		,{"R$ Base II"		,"XIT_DIBCIM"		,"@E 9,999,999.99",12				,4					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private	nPxDiBc    := Len(aHeadXml)

	// 49 - Aliquota Imposto Importação
	DbSeek("D1_ALIQII")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxDiAlq   := Len(aHeadXml)

	// 50 - Valor Imposto Importação
	DbSeek("D1_II")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3	,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxDiVII   := Len(aHeadXml)

	// 51 - Lote
	DbSeek("D1_LOTECTL")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxLoteCtl   := Len(aHeadXml)
	Aadd(aAlter,"D1_LOTECTL")

	// 52 - Sub-lote
	DbSeek("D1_NUMLOTE")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxNumLote   := Len(aHeadXml)
	Aadd(aAlter,"D1_NUMLOTE")

	// 53 - Lote Fornecedor
	DbSeek("D1_LOTEFOR")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxLoteFor   := Len(aHeadXml)
	Aadd(aAlter,"D1_LOTEFOR")

	// 54 - Validade do Lote Fornecedor
	DbSeek("D1_DTVALID")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxVldLtFor   := Len(aHeadXml)
	Aadd(aAlter,"D1_DTVALID")

	// 55 - Data de Fabricação
	DbSeek("D1_DFABRIC")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxDtFabric   := Len(aHeadXml)
	Aadd(aAlter,"D1_DFABRIC")

	// 56 - FCI
	// Tratativa para evitar erro do campo
	Private	nPxFciCod  := 0
	If DbSeek("D1_FCICOD")
		Aadd(aHeadXml	,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
		nPxFciCod  := Len(aHeadXml)
		Aadd(aAlter,"D1_FCICOD")
	Else
		//MsgAlert("O Campo 'D1_FCICOD' não foi encontrado no Dicionário de Dados. Será necessário atualizar a base com UPDSIGAFIS para criação deste campo por compatibilizador para usar esta funcionalidade","Ausência de campo")
		Aadd(aHeadXml,{"FCI"					,"XITFCICOD"		,"@!"	 				,	10,	0,"AllwaysFalse()",,	"C","","V"})	//Código do NCM
	Endif

	// 57 - CST Xml
	Aadd(aHeadXml		,{"CST Xml"		,	"XIT_CSTORI"	,	"@!"	,	04 , 0,"AllwaysFalse()",,	"C","","V"})	// Origem+CST Origem do XML
	Private	nPxXITCST  := Len(aHeadXml)

	// 58 - Key SD1
	Aadd(aHeadXml		,{"Chave SD1"		,	"XIT_KEYSD1"	,	"@!"	,	50 , 0,"AllwaysFalse()",,	"C","","V"})	// Chave SD1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	Private	nPxKeySD1  := Len(aHeadXml)

	// 59 - Codigo Barra
	Private	nPxCodBar  := 0
	If DbSeek("A5_CODBAR")
		Aadd(aHeadXml	,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
		nPxCodBar  := Len(aHeadXml)
	Endif

	// 60 - Valor Frete Rateio
	DbSeek("D1_VALFRE")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,"XIT_VALFRE"	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxValFre   := Len(aHeadXml)

	// 61 - Valor Outros Rateio (Despesa)
	DbSeek("D1_DESPESA")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,"XIT_DESPES"	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxValDesp   := Len(aHeadXml)
	Aadd(aAlter,"XIT_DESPES")

	// 62 - Valor Outros Rateio (Seguro)
	DbSeek("D1_SEGURO")
	Aadd(aHeadXml		,{TRIM(X3Titulo())	,"XIT_SEGURO"	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
	Private	nPxValSeg   := Len(aHeadXml)
	Aadd(aAlter,"XIT_SEGURO")

	// 63 - Codigo CEST
	Private	nPxCodCest  := 0
	If DbSeek("B1_CEST")
		Aadd(aHeadXml	,{TRIM(X3Titulo())	,SX3->X3_CAMPO	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,SX3->X3_VLDUSER	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO })
		nPxCodCest  := Len(aHeadXml)
	Endif

	// 64 - Base Calculo Icms Retido Anteriormente
	Aadd(aHeadXml		,{"B.Retido Ant."		,"XIT_BRETAN"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxBRetAnt		:= Len(aHeadXml)
	Aadd(aAlter,"XIT_BRETAN")

	// 65 - Valor do Icms Retido
	Aadd(aHeadXml		,{"ST Ret.Ant."		,"XIT_VRETAN"		,"@E 9,999,999.99",12				,2					,"AllwaysFalse()",				,"N"			,""				,"V"})
	Private nPxVRetAnt		:= Len(aHeadXml)
	Aadd(aAlter,"XIT_VRETAN")

	Private	aElemNumChg	:= {nPxQteNfe,nPxTotNfe,nPxQte,nPxTotal,nPxValDesc,nPxBasIcm,nPxValIcm,nPxBasIpi,nPxValIpi,nPxBasPis,nPxValPis,;
	nPxBasCof,nPxValCof,nPxBasRet,nPxIcmRet,nPxDiBc,nPxDiVII,nPxCrdIcmSN,nPxVlDesc,nPxValFre,nPxValDesp,nPxValSeg,nPxBRetAnt,nPxVRetAnt}



	Private bChangeXIT	:= {|| stLinOk() }
	U_DbSelArea("CONDORXMLITENS",.F.,1)

	//@ nMetade+20, 005 To nAltura-45, aTmSize[5]/2.01 Multiline Modify Valid stLinOk() Object oMulti
	aColsXml	:= {Array(Len(aHeadXml)+1)}
	aColsXml[Len(aColsXml),Len(aHeadXml)+1]	:= .F.
	aColsXml[Len(aColsXml),1]	:= oVermelho


	Private oMulti := MsNewGetDados():New(005,005,100,100,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue()"/*cLinhaOk*/,"AllwaysTrue()"/*cTudoOk*/,"+XIT_ITEM",;
	aAlter,1/*nFreeze*/,10000/*nMax*/,"U_XMLVLEDT()"/*cCampoOk*/,"AllwaysTrue()"/*cSuperApagar*/,"U_XMLVLEDT()"/*cApagaOk*/,oPaneDados,@aHeadXml,@aColsXml,bChangeXIT)
	oMulti:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	@ 025,258 Say "Vlr.Merc.NFe" of oPaneRodape Pixel
	@ 024,290 MsGet oTotalXml Var nTotalXml Picture "@E 99,999,999.99" Size 50,10 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel
	@ 036,258 Say "Vlr Produtos" of oPaneRodape Pixel
	@ 035,290 MsGet oTotalNfe Var nTotalNfe Picture "@E 99,999,999.99" Size 50,10 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel

	//CONDORXMLITENS->(DbCloseArea())
	Private oArqXml	:= TWBrowse():New( 	001/*<nRow>*/,;
	001/* <nCol>*/,;
	100/*<nWidth>*/,;
	100/* <nHeigth>*/,;
	/*[\{|| \{<Flds> \} \}]*/, ;
	aCabXml/*[\{<aHeaders>\}]*/,;
	aTamCabXml/* [\{<aColSizes>\}]*/, ;
	oPaneDados/*<oDlg>*/,;
	/* <(cField)>*/,;
	/* <uValue1>*/, ;
	/*<uValue2>*/,;
	/*[<{uChange}>]*/,;
	{|| sfMark()}/*[\{|nRow,nCol,nFlags|<uLDblClick>\}]*/,;
	/*[\{|nRow,nCol,nFlags|<uRClick>\}]*/,;
	/*<oFont>*/,;
	/* <oCursor>*/,;
	/* <nClrFore>*/,;
	/* <nClrBack>*/,;
	/* <cMsg>*/,;
	/*<.update.>*/,;
	/*<cAlias>*/,;
	.T./* <.pixel.>*/,;
	/* <{uWhen}>*/,;
	/*<.design.>*/,;
	/* <{uValid}>*/,;
	/*<{uLClick}>*/,;
	/*[\{<{uAction}>\}]*/)

	/*@ 000,000 ListBox oArqXml ;
	Fields HEADER " ",;    		// 1
	"Série/Nº NF-e",;      			// 2
	"Emissão",;    		   			// 3
	" ",;								// 4
	"Fornecedor/Loja-Nome",;   	 	// 5
	" "									// 6
	"Chave NF-e",;             	 	// 7
	"Destinatário",;            	// 8
	"Recebida em",;					// 9
	"Conf.Sefaz",;					// 10
	"Lançada em" ,;					// 11
	"Conf.Compras",;					// 12
	"Rev.Sefaz",;						// 13
	"Tipo Nota",;						// 14
	"R$ Total";						// 15
	SIZE aTmSize[5]/2.01,nMetade-35;
	ON DBLClick (sfMark()) Of oPaneDados Pixel*/
	oArqXml:Align := CONTROL_ALIGN_TOP

	oArqXml:bChange := {|| Pergunte(cPergXml,.F.),Processa({|| stRefrItem() },"Aguarde carregando itens....")}

	oArqXml:bHeaderClick := {|| cVarPesq := aArqXml[oArqXml:nAt,2],nColPos :=oArqXml:ColPos,lSortOrd := !lSortOrd, IIf(nColPos <> nPosOkCte,( aSort(aArqXml,,,{|x,y| Iif(lSortOrd,x[nColPos] > y[nColPos],x[nColPos] < y[nColPos]) }),stPesquisa()),sfMark(.T.))}
	oArqXml:bRClicked := {|| sfTracker() }

	U_DbSelArea("CONDORXML",.F.,1)

	@ 007,005 To 62,130 of oPaneRodape Pixel
	@ 001,005 Say "Dados Emitente" of oPaneRodape Pixel
	@ 012,008 Say "CNPJ:" of oPaneRodape Pixel
	@ 010,028 MsGet oCgcEmit Var CONDORXML->XML_EMIT Size 60,10 Picture "@R 99.999.999/9999-99" READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel
	@ 022,008 Say "Nome:" of oPaneRodape Pixel
	@ 020,028 MsGet oNomEmit Var CONDORXML->XML_NOMEMT Size 102,10 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel
	@ 032,008 Say "Cidade:" of oPaneRodape Pixel
	@ 030,028 MsGet oMunEmit Var CONDORXML->XML_MUNMT Size 102,10 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel

	@ 007,130 To 62,255  of oPaneRodape Pixel
	@ 001,130 Say "Dados Destinatário" of oPaneRodape Pixel
	@ 012,133 Say "CNPJ:" of oPaneRodape Pixel
	@ 010,153 MsGet oCgcDest Var CONDORXML->XML_DEST Size 60,10 Picture "@R 99.999.999/9999-99" READONLY COLOR CLR_RED NOBORDER of oPaneRodape Pixel
	@ 022,133 Say "Nome:" of oPaneRodape Pixel
	@ 020,153 MsGet oNomDest Var CONDORXML->XML_NOMEDT Size 102,10 READONLY COLOR CLR_RED noborder of oPaneRodape Pixel
	@ 032,133 Say "Cidade:" of oPaneRodape Pixel
	@ 030,153 MsGet oMunDest Var CONDORXML->XML_MUNDT Size 102,10 READONLY COLOR CLR_RED noborder of oPaneRodape Pixel

	@ 002,258 Say "Nº CTEs" of oPaneRodape Pixel
	@ 001,290 MsGet oNumCte Var nNumCte Picture "@E 999,999" Size 25,08 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel
	@ 013,258 Say "R$ CTEs" of oPaneRodape Pixel
	@ 012,290 MsGet oSumCte Var nSumCte Picture "@E 999,999.99" Size 30,10 READONLY COLOR CLR_BLUE noborder of oPaneRodape Pixel

	@ 001,350 Say "Mensagens da Danfe" of oPaneRodape Pixel
	@ 007,350 Get oMsgNfe Var cMsgNfe of oPaneRodape MEMO Size ( (oDlgXDc:nWidth-740) / 2  ),55 Pixel READONLY

	oArqXml:SetFocus()
	nFocus1	:= GetFocus()
	oMulti:oBrowse:SetFocus()
	nFocus2	:= GetFocus()
	SetFocus(nFocus1)

	// Se não for via Schedule
	If !IsBlind()

		//StaticCall(XMLDCONDOR,stSendMail,"contato@centralxml.com.br","sfExec XMLDCONDOR ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )

		Processa({|| stRefresh() },"Aguarde procurando registros ....")

		// Se for usuário Fiscal sempre irá iniciar a rotina forçando a sincronização da Manifestação
		If lSuperUsr .And. nC00Cont==1
			//U_XMLMDFE2(.T.)
			StartJob("U_XMLMDFE2",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*cInChave*/,.T./*lInAuto*/,/*aInChaves*/,cEmpAnt,cFilAnt,.T./*lSetEnv*/)
		Endif

	Endif

	Activate MsDialog oDlgXDc Centered On Init (sfStartInit(oDlgXDc,aButton),IIf(lAutoExec,oDlgXDc:End(),Nil))

	If lAutoExec .And. Type("oMainWnd") == "O"
		oMainWnd:End()
	Endif

Return


/*/{Protheus.doc} sfPergM103
(Monta pergunta do MATA103 para permitir configurações )

@author Marcelo Lauschner
@since 17/07/2012
@version 1.0

@return Sem retorno esperado

@example
(examples)

@see (links_or_references)
/*/
Static Function sfPergM103(lExibe)
	
	Default	lExibe	:= .T.
	
	Pergunte("MTA103",lExibe)
	
	lConsLoja   := (mv_par07==1)// 15/08/2017 - Adicionado filtro para considerar Loja do fornecedor ou não conforme pergunta MTA103 MV_PAR07 
	
	Pergunte(cPergXml,.F.)

Return



/*/{Protheus.doc} sfConProd
(Consulta Histório de produto - Facilita consulta por atalho)

@author MarceloLauschner
@since 08/12/2012
@version 1.0

@return Sem retorno esperado

@example
(examples)

@see (links_or_references)
/*/

Static Function sfConProd(nOpcSb1)

	//Local	nOpcSb1	:= Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha uma opção","Selecione uma opção",{"Histórico","Cadastro"})
	Local	aAreaOld	:= GetArea()
	Local	nOpc		:= 0

	If nOpcSB1	== 1
		If Len(oMulti:aCols) > 0 .And. !Empty(oMulti:aCols[oMulti:nAt,nPxProd])
			If Type("aRotina") <> "A"
				aRotina   := {{ ,"A103NFiscal", 0, 2}}
			Endif
			MaComView(oMulti:aCols[oMulti:nAt][nPxProd])
		Else
			MsgAlert("Não há produto digitado!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem referência!")
		Endif
	ElseIf nOpcSB1 == 2
		If Len(oMulti:aCols) > 0 .And. !Empty(oMulti:aCols[oMulti:nAt,nPxProd])
			DbSelectArea("SB1")
			Set Filter To B1_COD == oMulti:aCols[oMulti:nAt,nPxProd]
			If MV_PAR13 == 1
				Mata010()
			ElseIf MV_PAR13 == 2
				Loja110()
			Endif
			// Restaura sem filtro
			DbSelectArea("SB1")
			Set Filter To
			RestArea(aAreaOld)
		Else
			DbSelectArea("SB1")
			Set Filter To
			If MV_PAR13 == 1
				Mata010()
			ElseIf MV_PAR13 == 2
				Loja110()
			Endif
			// Restaura sem filtro
			DbSelectArea("SB1")
			Set Filter To
			RestArea(aAreaOld)
		Endif
	Endif

Return Nil




Static Function sfConForn(nOpcSb1)

	//Local	nOpcSb1	:= Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha uma opção","Selecione uma opção",{"Histórico","Cadastro"})
	Local	aAreaOld	:= GetArea()
	Local	nOpc		:= 0

	If nOpcSB1	== 1
		
	ElseIf nOpcSB1 == 2
		DbSelectArea("SA2")
		Set Filter To A2_COD == cCodForn .And. A2_LOJA == cLojForn
		
		MATA020()
		// Restaura sem filtro
		DbSelectArea("SA2")
		Set Filter To
		RestArea(aAreaOld)
		
	Endif

Return Nil


/*/{Protheus.doc} sfLegenda
(Legenda das cores da rotina   )

@author MarceloLauschner
@since 24/032012
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function sfLegenda()

	Local	aCores := {	;
	{"BR_VERDE"		,"Documento Lançado"},;
	{"BR_CANCEL"		,"CTe em aberto"},;
	{"BR_VERMELHO"		,"NFe Normal em aberto"},;
	{"BR_AMARELO"		,"NFe/CTe Rejeitados"},;
	{"BR_AZUL_CLARO"	,"Documento Bloqueado"},;
	{"BR_AZUL"			,"NFe lançada Pré-Nota"},;
	{"BR_PRETO"			,"NFe/CTe Outra Empresa"},;
	{"BR_PINK"			,"NFe Devolução em aberto"},;
	{"BR_VIOLETA"		,"NFe Beneficiamento em aberto"},;
	{"BR_MARROM"		,"NFe Compl.ICMS em aberto"},;
	{"BR_CINZA"			,"NFe Compl.IPI em aberto"},;
	{"BR_LARANJA"		,"NFe Compl.Preço/Frete em aberto"},;
	{"LBNO"				,"Doc.Entrada Resp.Terceiros"},;
	{"BR_BRANCO"		,"NFC-e em Aberto"},;
	{"PMSEDT2"			,"NFS-e em Aberto"}}


	BrwLegenda(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Central XML NFE/CTE","Legenda",aCores)

	SetFocus(nFocus1)


Return (.T.)


/*/{Protheus.doc} sfLegItens
(Legenda das cores da rotina  )

@author Marcelo Alberto Lauschner
@since 24/03/2012
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function sfLegItens()

	Local	aCores := {	{"BR_VERDE"		,"Preço confere com pedido de Compra"},;
	{"BR_VERMELHO"	,"Não tem pedido de Compra"},;
	{"BR_AZUL"		,"Quantidade divergente do pedido de compra"},;
	{"BR_AMARELO"	,"Preço divergente do pedido de compra"},;
	{"BR_PRETO"		,"Nota Devolução/Retorno sem NF Origem"},;
	{"BR_LARANJA"	,"Quantidade e Preço Divergente"}}

	BrwLegenda(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Central XML NFE/CTE","Legenda",aCores)

	SetFocus(nFocus1)

Return (.T.)


/*/{Protheus.doc} sfLegManif
(Legenda para Manifestação Destinatário)
@author MarceloLauschner
@since 14/05/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfLegManif()

	Local aLegenda:= {}

	AADD(aLegenda, {"BR_BRANCO"		,STR0414})//Sem manifestação
	AADD(aLegenda, {"ENABLE"			,STR0415})//Confirmada
	AADD(aLegenda, {"BR_CINZA"		,STR0416})//Desconhecida
	AADD(aLegenda, {"DISABLE"		,STR0417})//Não realizada
	AADD(aLegenda, {"BR_AZUL"		,STR0418})//Ciência
	AADD(aLegenda, {"BR_LARANJA"	,"Confirmada com Evento não vinculado"})//Ciência
	Aadd(aLegenda, {"BR_CANCEL"		,"Não há dados"})
	BrwLegenda(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Central XML NFE/CTE","Legenda",aLegenda)

	SetFocus(nFocus1)

Return (.T.)




/*/{Protheus.doc} sfSetKeys
(Seta teclas de atalho )
@type function
@author marce
@since 16/05/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfSetKeys()

	Set Key VK_F5 To stGrvItens()
	Set Key VK_F6 TO U_VldItemPc(,,,,,.T.)
	Set Key VK_F7 To sfFracQte()
	Set Key VK_F8 To sfRefItens()
	Set Key VK_F12 To sfPergM103()


Return

/*/{Protheus.doc} stRefresh
( Efetua a carga de dados do Listbox de notas  )

@author MarceloLauschner
@since 20/02/2012
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stRefresh(lAtuOnlyOne,cInChaveAtu,lFirst)

	Local	cFornece	:= ""
	Local	aDestino	:= {}
	Local	nRecSM0		:= 0
	Local	lExistSF1	:= .F.
	Local	cF1Status	:= ""
	Local	nLimLinha	:= Iif(!Empty(MV_PAR18),5000,1000)
	Local  	cChvAtu		:= ""
	Local	lRemoveArr	:= .F. // Se for atualização de um XML deve verificar se o registro cai fora do critério de filtro para ser removido do array
	Local	nTmArray	:= Len(aArqXml)
	Local	nStatLeg	:= 0
	Local   nCC
	Local   lBlqEmp		:= GetNewPar("XM_BLQXEMP",.F.) 
	Default lAtuOnlyOne	:= .F.
	Default	cInChaveAtu	:= ""
	Default lFirst		:= .F.
	Private	aChvManif	:= {}
	Private	aChvMonit	:= {}
	Private	aChvSinc	:= {}

	// Seto as teclas de atalho a cada refresh da tela
	sfSetKeys()

	// Não Zero quando for apenas atualização de um registro
	If !lAtuOnlyOne
		aArqXml := {}
	Endif

	// Zero contador na tela
	nSumCte	:= nNumCte	:= 0
	If !lAutoExec
		oSumCte:Refresh()
		oNumCte:Refresh()
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter To
	//ConOut("Passou 1210 xmldcondor ")
	If lAtuOnlyOne
		lRemoveArr	:= .T.
		Set Filter To XML_CHAVE == cInChaveAtu
	ElseIf !Empty(MV_PAR17)
		Set Filter to Alltrim(MV_PAR17) $ XML_CHAVE 
	ElseIf !Empty(MV_PAR18)
		Set Filter to MV_PAR18 == XML_NROFAT 
	ElseIf lExecFilChv
		Set Filter to XML_CHAVE == cChvFiltro
	ElseIf lAutoExec // Se for rotina automatica
		//stSendMail( "contato@centralxml.com.br", "Set filter to filial "+cFilAnt, DTOC(MV_PAR06) + " " + DTOC(MV_PAR07) + " " + MV_PAR09 + " " + MV_PAR10 + " " +Alltrim(SM0->M0_CGC)+" "+ ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
		Set Filter to Empty(XML_OK) .And. Empty(XML_REJEIT) .And. Empty(XML_KEYF1) .And. XML_TIPODC $ "N#F#T" .And. MV_PAR06 <= XML_EMISSA .And. MV_PAR07 >= XML_EMISSA .And. Alltrim(CONDORXML->XML_EMIT) >= MV_PAR09 .And. Alltrim(CONDORXML->XML_EMIT) <= MV_PAR10 .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	ElseIf MV_PAR08==1
		If MV_PAR01 == 1
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. Empty(XML_KEYF1) .And. !Empty(XML_CONFCO) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC) .And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Else
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. Empty(XML_KEYF1)  .And. !Empty(XML_CONFCO) .And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Endif
	ElseIf MV_PAR08==2
		If MV_PAR01 == 1
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. Empty(XML_KEYF1) .And.  Empty(XML_CONFCO) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC) .And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Else
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. Empty(XML_KEYF1) .And.  Empty(XML_CONFCO).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Endif
	ElseIf MV_PAR08==3
		If MV_PAR01 == 1
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. !Empty(XML_REJEIT) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Else
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. !Empty(XML_REJEIT).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Endif
	ElseIf MV_PAR08==4
		If MV_PAR01 == 1
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And.  Empty(XML_CONFER) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Else
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And.  Empty(XML_CONFER).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Endif
	Else
		If MV_PAR01 == 1
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC).And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Else
			Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_REJEIT) .And. CONDORXML->XML_EMIT >= MV_PAR09 .And. CONDORXML->XML_EMIT <= MV_PAR10
		Endif
	Endif


	If !lAutoExec .And. !lFirst
		Count to nRegXml
		ProcRegua(nRegXml)
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	DbGotop()

	While CONDORXML->(!Eof())

		lExistSF1	:= .F.
		cF1Status	:= ""

		cFornece := "      /  - Destinatário não pertence a Empresa atual"

		If !lAutoExec
			If !lFirst
				IncProc("Processando NF-e" + CONDORXML->XML_NUMNF)
			Endif
		Else
			If !Empty(CONDORXML->XML_OK)
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		Endif

		cChvAtu	:= CONDORXML->XML_CHAVE

		// ------------------------------------------------------------------
		// - Trecho especifico para filtrar CTes sem vinculo CONDORCTEXNFS
		//cQry := ""
		//cQry += "SELECT COUNT(*) NEXIST "
		//cQry += "  FROM CONDORCTEXNFS "
		//cQry += " WHERE XCN_CHVCTE = '"+ Alltrim(cChvAtu) +"' "
		//cQry += "   AND XCN_EMP = '"+cEmpAnt+"' "
		//cQry += "   AND XCN_FIL = '"+cFilAnt+"' "
		//cQry += "   AND D_E_L_E_T_ =' ' "

		//TCQUERY cQry NEW ALIAS "QXCN"

		//If QXCN->NEXIST > 0
		//	IncProc()
		//	QXCN->(DbCloseArea())
		//	DbSelectArea("CONDORXML")
		//	DbSkip()
		//	Loop	
		//Endif	
		//If Select("QXCN") > 0
		//	QXCN->(DbCloseArea())
		//Endif
		//---------------------------------------------------------------			
		//stSendMail( "contato@centralxml.com.br", "Loop XMLCTE10 filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
		//ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + " Chave "+ cChvAtu)

		If ExistBlock("XMLCTE10")
			If !ExecBlock("XMLCTE10",.F.,.F.)
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		Endif

		If Empty(MV_PAR17) .And. Empty(MV_PAR18)
			If MV_PAR08==1 // Apenas Conf. Compras
				If Empty(CONDORXML->XML_CONFCO)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			ElseIf MV_PAR08==2 // Sem Conf.Compras
				If !Empty(CONDORXML->XML_CONFCO)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			ElseIf MV_PAR08==3
				If Empty(CONDORXML->XML_REJEIT)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			ElseIf MV_PAR08==4
				If !Empty(CONDORXML->XML_CONFER)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			Endif
			// Filtro Cnpj de emitentes
			If CONDORXML->XML_EMIT < MV_PAR09 .Or. CONDORXML->XML_EMIT > MV_PAR10
				//stSendMail( "contato@centralxml.com.br", "Loop XML_EMIT filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif

			If MV_PAR15 == 3 .And.  !CONDORXML->XML_TIPODC $ "T#F"
				//stSendMail( "contato@centralxml.com.br", "Loop XML_TIPODC filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif

			If MV_PAR15 == 5 .And.  !CONDORXML->XML_TIPODC $ "D#B"
				//stSendMail( "contato@centralxml.com.br", "Loop XML_TIPODC filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif

			If MV_PAR15 == 4 .And.  !CONDORXML->XML_TIPODC $ "N#C#I#P#D#B#S"
				//stSendMail( "contato@centralxml.com.br", "Loop XML_TIPODC filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		Endif
		//stSendMail( "contato@centralxml.com.br", "Executando processo automático filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )

		If Alltrim(CONDORXML->XML_DEST) == Alltrim(SM0->M0_CGC) //.Or. Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
			If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
				If Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
					cQry := "SELECT A2_COD,A2_LOJA,A2_NOME "
					cQry += "  FROM "+RetSqlName("SA2")
					cQry += " WHERE D_E_L_E_T_ = ' ' "
					cQry += "   AND A2_NOME = '"+Alltrim(Upper(CONDORXML->XML_NOMEMT))+"' "
					cQry += "   AND A2_FILIAL = '"+xFilial("SA2")+"' "
					TCQUERY cQry NEW ALIAS "QSA2"
					If !Eof()
						cFornece := QSA2->A2_COD+"/"+QSA2->A2_LOJA + "-" +QSA2->A2_NOME
						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek(xFilial("SA2")+QSA2->A2_COD+QSA2->A2_LOJA)
						cCodForn	:= SA2->A2_COD
						cLojForn	:= SA2->A2_LOJA
					Endif
					QSA2->(DbCloseArea())
				Else
					// Novo procedimento que permite especificar qual Código e Loja
					If !Empty(CONDORXML->XML_CODLOJ)
						DbSelectArea("SA2")
						DbSetOrder(1)
						If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
							cCodForn	:= SA2->A2_COD
							cLojForn	:= SA2->A2_LOJA
							cFornece 	:= SA2->A2_COD+"/"+SA2->A2_LOJA + "-" +SA2->A2_NOME
							// Verifica se não houve um erro de atribuição de Código/Loja e força nova verificação
							If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
								DbSelectArea("SA2")
								DbSetOrder(3)
								DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
								cCodForn	:= SA2->A2_COD
								cLojForn	:= SA2->A2_LOJA
								sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
								DbSelectArea("SA2")
								DbSetOrder(1)
								DbSeek(xFilial("SA2")+cCodForn+cLojForn)
								cFornece := cCodForn+"/"+cLojForn + "-" +SA2->A2_NOME	
							Endif
						Else
							DbSelectArea("SA2")
							DbSetOrder(3)
							DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
							cCodForn	:= SA2->A2_COD
							cLojForn	:= SA2->A2_LOJA
							sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
							DbSelectArea("SA2")
							DbSetOrder(1)
							DbSeek(xFilial("SA2")+cCodForn+cLojForn)
							cFornece := cCodForn+"/"+cLojForn + "-" +SA2->A2_NOME
						Endif
					Else
						DbSelectArea("SA2")
						DbSetOrder(3)
						If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
							cCodForn	:= SA2->A2_COD
							cLojForn	:= SA2->A2_LOJA
							sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
							DbSelectArea("SA2")
							DbSetOrder(1)
							DbSeek(xFilial("SA2")+cCodForn+cLojForn)
							cFornece := cCodForn+"/"+cLojForn + "-" +SA2->A2_NOME
						Endif
					Endif
				Endif
				lExistSF1	:= .T.

				If Empty(MV_PAR17) .And. Empty(MV_PAR18) .And.( SA2->A2_COD < MV_PAR02 .Or. SA2->A2_LOJA < MV_PAR03 .Or. SA2->A2_COD > MV_PAR04 .Or. SA2->A2_LOJA > MV_PAR05)
					//stSendMail( "contato@centralxml.com.br", "Loop A2_COD A2_LOJA filial "+cFilAnt, "A2_COD="+SA2->A2_COD +"-MV_PAR02="+ MV_PAR02 +"-"+ SA2->A2_LOJA +"-"+ MV_PAR03 +"-"+ SA2->A2_COD +"-"+ MV_PAR04 +"-"+ SA2->A2_LOJA +"-"+ MV_PAR05 +"-"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			Else
				// Novo procedimento que permite especificar qual Código e Loja
				If !Empty(CONDORXML->XML_CODLOJ)
					DbSelectArea("SA1")
					DbSetOrder(1)
					If DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
						cFornece 	:= SA1->A1_COD+"/"+SA1->A1_LOJA + "-" +SA1->A1_NOME
						cCodForn	:= SA1->A1_COD
						cLojForn	:= SA1->A1_LOJA
						
						If Alltrim(SA1->A1_CGC) <> Alltrim(CONDORXML->XML_EMIT)
							DbSelectArea("SA1")
							DbSetOrder(3)
							If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
								cCodForn	:= SA1->A1_COD
								cLojForn	:= SA1->A1_LOJA
								sfVldCliFor('SA1', @cCodForn, @cLojForn ,SA1->A1_NOME,.T.,CONDORXML->XML_TIPODC)
								DbSelectArea("SA1")
								DbSetOrder(1)
								DbSeek(xFilial("SA1")+cCodForn+cLojForn)
								cFornece := cCodForn+"/"+cLojForn + "-" +SA1->A1_NOME
							Endif
						Endif	
					Else
						DbSelectArea("SA1")
						DbSetOrder(3)
						If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
							cCodForn	:= SA1->A1_COD
							cLojForn	:= SA1->A1_LOJA
							sfVldCliFor('SA1', @cCodForn, @cLojForn ,SA1->A1_NOME,.T.,CONDORXML->XML_TIPODC)
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial("SA1")+cCodForn+cLojForn)
							cFornece := cCodForn+"/"+cLojForn + "-" +SA1->A1_NOME
						Endif			
					Endif
				Else
					DbSelectArea("SA1")
					DbSetOrder(3)
					If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
						cCodForn	:= SA1->A1_COD
						cLojForn	:= SA1->A1_LOJA
						sfVldCliFor('SA1', @cCodForn, @cLojForn ,SA1->A1_NOME,.T.,CONDORXML->XML_TIPODC)
						DbSelectArea("SA1")
						DbSetOrder(1)
						DbSeek(xFilial("SA1")+cCodForn+cLojForn)
						cFornece := cCodForn+"/"+cLojForn + "-" +SA1->A1_NOME
					Endif
				Endif

				lExistSF1	:= .T.

				If Empty(MV_PAR17).And. Empty(MV_PAR18) .And.( SA1->A1_COD < MV_PAR02 .Or. SA1->A1_LOJA < MV_PAR03 .Or. SA1->A1_COD > MV_PAR04 .Or. SA1->A1_LOJA > MV_PAR05)
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			Endif
		Else
			If Empty(MV_PAR17).And. Empty(MV_PAR18) .And. MV_PAR01 == 1
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		Endif
		If lExistSF1
			// -- Valido se Nota Fiscal já existe na base ?
			If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
				cTipoDC 	:= sfVldTpCTE()
				DbSelectArea("SF1")
				DbSetOrder(8)
				If DbSeek(XFilial("SF1") + Padr(CONDORXML->XML_CHAVE,Len(SF1->F1_CHVNFE)))
					If SF1->F1_EMISSAO >= CONDORXML->XML_EMISSA
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
						//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
						CONDORXML->XML_LANCAD	:= SF1->F1_DTDIGIT
						CONDORXML->XML_NUMNF	:= SF1->F1_SERIE+SF1->F1_DOC
						If CONDORXML->XML_TIPODC $ "N#D#B"
							CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
						Endif 
						MsUnlock()
					Else
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1	:= ""
						CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
						MsUnlock()
					Endif
				Else
					DbSelectArea("SF1")
					DbSetOrder(1)
					If DbSeek(XFilial("SF1")+;
					Right("000000000"+Alltrim(Substr(CONDORXML->XML_NUMNF,nTmF1Ser+1,nTmF1Doc)),nTmF1Doc)+;
					Padr(Alltrim(Substr(CONDORXML->XML_NUMNF,1,nTmF1Ser)),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+ 	Padr(Substr(CONDORXML->XML_NUMNF,4,6),nTmF1Doc)+;
					Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
					SA2->A2_COD+;
					SA2->A2_LOJA+;
					cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+ 	Padr(Substr(CONDORXML->XML_NUMNF,6,7),nTmF1Doc)+;
					Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
					SA2->A2_COD+;
					SA2->A2_LOJA+;
					cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+ 	Padr(Substr(CONDORXML->XML_NUMNF,5,8),nTmF1Doc)+;
					Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
					SA2->A2_COD+;
					SA2->A2_LOJA+;
					cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+ 	Padr(Substr(CONDORXML->XML_NUMNF,7,6),nTmF1Doc)+;
					Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
					SA2->A2_COD+;
					SA2->A2_LOJA+;
					cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(Substr(CONDORXML->XML_NUMNF,nTmF1Ser+1,nTmF1Doc)),nTmF1Doc)+;
					Right("000"+Alltrim(Substr(CONDORXML->XML_NUMNF,1,nTmF1Ser)),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or.;
					DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,4,6),nTmF1Doc)+Right("000"+Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or. ;
					DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,4,6),nTmF1Doc)+Right("000"+Substr(CONDORXML->XML_NUMNF,1,1),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or. ;
					DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,7,6),nTmF1Doc)+Right("000"+Substr(CONDORXML->XML_NUMNF,1,1),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or. ;
					DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,7,6),nTmF1Doc)+Padr("0"+Substr(CONDORXML->XML_NUMNF,1,1),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or. ;
					DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,7,6),nTmF1Doc)+Padr(" ",nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC) .Or. ;
					DbSeek(XFilial("SF1")+Padr(cValToChar(Val(Substr(CONDORXML->XML_NUMNF,4,9))),nTmF1Doc)+Padr(cValToChar(Val(Substr(CONDORXML->XML_NUMNF,1,3))),nTmF1Ser)+;
					SA2->A2_COD+SA2->A2_LOJA+cTipoDC)


						If SF1->F1_EMISSAO >= CONDORXML->XML_EMISSA
							RecLock("CONDORXML",.F.)
							CONDORXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
							//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
							CONDORXML->XML_LANCAD	:= SF1->F1_DTDIGIT
							CONDORXML->XML_NUMNF	:= SF1->F1_SERIE+SF1->F1_DOC
							If CONDORXML->XML_TIPODC $ "N#D#B"
								CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
							Endif 
							MsUnlock()
						Else
							RecLock("CONDORXML",.F.)
							CONDORXML->XML_KEYF1		:= ""
							CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
							MsUnlock()
						Endif
					Else
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1		:= ""
						CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
						MsUnlock()
					Endif
				Endif
			Else
				DbSelectArea("SF1")
				DbSetOrder(1)
				If DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(Substr(CONDORXML->XML_NUMNF,nTmF1Ser+1,nTmF1Doc)),nTmF1Doc)+;
				Padr(Alltrim(Substr(CONDORXML->XML_NUMNF,1,nTmF1Ser)),nTmF1Ser)+;
				SA1->A1_COD+SA1->A1_LOJA+CONDORXML->XML_TIPODC) .Or.;
				DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,4,6),nTmF1Doc)+Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
				SA1->A1_COD+SA1->A1_LOJA+CONDORXML->XML_TIPODC) .Or. ;
				DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,7,6),nTmF1Doc)+Padr(Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
				SA1->A1_COD+SA1->A1_LOJA+CONDORXML->XML_TIPODC) .Or. ;
				DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(Substr(CONDORXML->XML_NUMNF,nTmF1Ser+1,nTmF1Doc)),nTmF1Doc)+;
				Right("000"+Alltrim(Substr(CONDORXML->XML_NUMNF,1,nTmF1Ser)),nTmF1Ser)+;
				SA1->A1_COD+SA1->A1_LOJA+CONDORXML->XML_TIPODC) .Or.;
				DbSeek(XFilial("SF1")+Padr(Substr(CONDORXML->XML_NUMNF,4,6),nTmF1Doc)+Right("000"+Substr(CONDORXML->XML_NUMNF,1,3),nTmF1Ser)+;
				SA1->A1_COD+SA1->A1_LOJA+CONDORXML->XML_TIPODC)
					If SF1->F1_EMISSAO >= CONDORXML->XML_EMISSA
						DbSelectArea("CONDORXML")
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
						//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
						CONDORXML->XML_LANCAD	:= SF1->F1_DTDIGIT
						CONDORXML->XML_NUMNF		:= SF1->F1_SERIE+SF1->F1_DOC
						If CONDORXML->XML_TIPODC $ "N#D#B"
							CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
						Endif 
		
						MsUnlock()
					Else
						DbSelectArea("CONDORXML")
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1		:= ""
						CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
						MsUnlock()
					Endif
				Else
					DbSelectArea("SF1")
					DbSetOrder(8)
					If DbSeek(XFilial("SF1") + Padr(CONDORXML->XML_CHAVE,Len(SF1->F1_CHVNFE)))
						If SF1->F1_EMISSAO >= CONDORXML->XML_EMISSA
							RecLock("CONDORXML",.F.)
							CONDORXML->XML_KEYF1		:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
							//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
							CONDORXML->XML_LANCAD		:= SF1->F1_DTDIGIT
							CONDORXML->XML_NUMNF		:= SF1->F1_SERIE+SF1->F1_DOC
							If CONDORXML->XML_TIPODC $ "N#D#B"
								CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
							Endif 
							MsUnlock()
						Else
							RecLock("CONDORXML",.F.)
							CONDORXML->XML_KEYF1		:= ""
							CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
							MsUnlock()
						Endif
					Else
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1		:= ""
						CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
						MsUnlock()
					Endif
				Endif
			EndIf

			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(CONDORXML->XML_KEYF1)
				cF1Status	:= SF1->F1_STATUS

				// Adicionada tratativa de filtrar somente Prenotas baseada na condição da pergunta 15
				// 22/05/2013 por solicitação Leandro - Isolucks
				If Empty(MV_PAR17).And. Empty(MV_PAR18) .And. MV_PAR15 == 2 .And. !SF1->F1_STATUS $ " #B#C" // !Empty(SF1->F1_STATUS)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif

				If Empty(MV_PAR17).And. Empty(MV_PAR18) .And. (SF1->F1_DTDIGIT < MV_PAR19 .Or. SF1->F1_DTDIGIT > MV_PAR20)
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif

			Else
				// Adicionada tratativa de filtrar somente Prenotas baseada na condição da pergunta 15
				// 22/05/2013 por solicitação Leandro - Isolucks
				If Empty(MV_PAR17).And. Empty(MV_PAR18) .And. MV_PAR15 == 2
					IncProc()
					DbSelectArea("CONDORXML")
					DbSkip()
					Loop
				Endif
			Endif
		Endif

		nPxHora	:= AT("</chNFe><dhRecbto>",CONDORXML->XML_ARQ)
		If nPxHora <= 0
			nPxHora	:= AT("</chCTe><dhRecbto>",CONDORXML->XML_ARQ)
			If nPxHora > 0
				cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+18,20),"-","")
			Endif
		Else
			cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+18,20),"-","")
		Endif
		If nPxHora <= 0
			nPxHora	:= AT("<dhRecbto>",CONDORXML->XML_ARQ)
			If nPxHora > 0
				cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+10,20),"-","")
			Endif
		Endif

		//If Empty(CONDORXML->XML_DTRVLD) .And. CONDORXML->XML_EMISSA <=  (Date() - (GetMv("XM_SPEDEXC")/24)) .And. Empty(CONDORXML->XML_REJEIT)
		If nPxHora > 0 .And. (Empty(CONDORXML->XML_CONFER) .Or. Empty(CONDORXML->XML_DTRVLD)) .And. (cDtHora <=  DTOS(Date()-(Int(GetMv("XM_SPEDEXC")/24)))+"T"+Time()) .And. Empty(CONDORXML->XML_REJEIT)
			If !Empty(cIdentSPED)

				cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
				// Trecho para validar autorização da NF
				cMensagem:= ""
				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT    	 := cIdentSPED
				ows:cCHVNFE		 := Alltrim(CONDORXML->XML_CHAVE)
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

				If oWs:ConsultaChaveNFE()
					cMensagem := ""
					If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
						cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
					EndIf
					cMensagem += STR0035 +": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
					cMensagem += "Cod.Ret.NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF 
					cMensagem += "Msg.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
					If oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1 .And. !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
						cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
					EndIf
					If Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
						DbSelectArea("CONDORXML")
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_DTRVLD := Date()
						If Empty(CONDORXML->XML_CONFER)
							CONDORXML->XML_CONFER := Date() 
							CONDORXML->XML_HORCON := Time()
							CONDORXML->XML_USRCON := Padr(cUserName,30)
						Endif
						MsUnLock()
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
						stRejeita(CONDORXML->XML_CHAVE,cMensagem,,.T.)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "410"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "217" .And. lSuperUsr
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE,,.T.,cMensagem)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "003"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "678"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "239"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
					ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "526"
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
						stConSefaz(CONDORXML->XML_CHAVE)
					Else
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
					Endif
					//	Aviso(STR0107,cMensagem,{STR0114},3)
				Else
					If "003 - Falha no retorno da SEFAZ" $  GetWscError()
						stConSefaz(CONDORXML->XML_CHAVE)
					Else
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+"SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{STR0114},3)
					Endif
				EndIf
			Endif
		Endif

		If lAutoExec
			//stSendMail( "contato@centralxml.com.br", "Antes validar MV_PAR16 filial "+cFilAnt, cValToChar(MV_PAR16) + " " +CONDORXML->XML_KEYF1+" "+ ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
		Endif

		If Empty(MV_PAR17) .And. MV_PAR16 == 2 // Somente lançado
			If Empty(CONDORXML->XML_KEYF1)
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		ElseIf Empty(MV_PAR17) .And. MV_PAR16 == 3 // Somente não lançado
			If !Empty(CONDORXML->XML_KEYF1)
				IncProc()
				DbSelectArea("CONDORXML")
				DbSkip()
				Loop
			Endif
		Endif
		//stSendMail( "contato@centralxml.com.br", "Executando processo automático filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+cChvAtu )
		U_DbSelArea("CONDORBLQAUTO",.F.,1)
		DbSeek(Iif(lBlqEmp,cEmpAnt,"")+CONDORXML->XML_OK)
		
		If lAtuOnlyOne
			lRemoveArr	:= .F. // Determina que não deve removido do array
			If CONDORXML->XML_TPNF == "0" .And. !CONDORXML->XML_TIPODC $ "T#F"
				nStatLeg	:= 12
			ElseIf !lExistSF1
				nStatLeg	:= 5
			ElseIf !Empty(CONDORXML->XML_REJEIT)
				nStatLeg	:= 3
			ElseIf Empty(CONDORXML->XML_KEYF1)
				If CONDORXML->XML_TIPODC == "D"
					nStatLeg	:= 6
				ElseIf CONDORXML->XML_TIPODC=="B"
					nStatLeg	:= 7
				ElseIf CONDORXML->XML_TIPODC=="I"
					nStatLeg	:= 8
				ElseIf CONDORXML->XML_TIPODC=="P"
					nStatLeg	:= 9
				ElseIf CONDORXML->XML_TIPODC=="C"
					nStatLeg	:= 10
				ElseIf CONDORXML->XML_TIPODC $ "T#F"
					nStatLeg	:= 11
				ElseIf CONDORXML->XML_TIPODC=="E"
					nStatLeg	:= 13
				ElseIf CONDORXML->XML_TIPODC=="S"
					nStatLeg	:= 14
				Else
					nStatLeg	:= 1
				Endif
			Else
				If !cF1Status $ " #B#C"
					nStatLeg	:= 2
				Else
					nStatLeg	:= 4
				Endif
			Endif
			aArqXML[oArqXml:nAt,1]	:= nStatLeg
			aArqXML[oArqXml:nAt,2]	:= CONDORXML->XML_NUMNF
			aArqXML[oArqXml:nAt,3]	:= CONDORXML->XML_EMISSA
			//aArqXML[oArqXml:nAt,4]	:=
			aArqXML[oArqXml:nAt,5]	:= Alltrim(cFornece)
			aArqXML[oArqXml:nAt,6]	:= sfCC0Sts(Alltrim(CONDORXML->XML_CHAVE),!Empty(CONDORXML->XML_KEYF1),cF1Status)
			aArqXML[oArqXml:nAt,7]	:= Alltrim(CONDORXML->XML_CHAVE)
			aArqXML[oArqXml:nAt,8]	:= Alltrim(Transform(CONDORXML->XML_DEST,"@R 99.999.999/9999-99")+" - " +Capital(CONDORXML->XML_NOMEDT))
			aArqXML[oArqXml:nAt,9]	:= CONDORXML->XML_CONFIS
			aArqXML[oArqXml:nAt,10]	:= CONDORXML->XML_CONFER
			aArqXML[oArqXml:nAt,11]	:= CONDORXML->XML_LANCAD
			aArqXML[oArqXml:nAt,12]	:= CONDORXML->XML_CONFCO
			aArqXML[oArqXml:nAt,13]	:= CONDORXML->XML_RECEB
			aArqXML[oArqXml:nAt,14]	:= CONDORXML->XML_DTRVLD
			aArqXML[oArqXml:nAt,15]	:= CONDORXML->XML_TIPODC
			aArqXML[oArqXml:nAt,16]	:= CONDORXML->XML_VLRDOC
			aArqXML[oArqXml:nAt,17]	:= CONDORXML->XML_OK + "-" + CONDORBLQAUTO->XBL_DESMOT
			oArqXml:Refresh()

		Else
			If CONDORXML->XML_TPNF == "0" .And. !CONDORXML->XML_TIPODC $ "T#F"
				nStatLeg	:= 12
			ElseIf !lExistSF1
				nStatLeg	:= 5
			ElseIf !Empty(CONDORXML->XML_REJEIT)
				nStatLeg	:= 3
			ElseIf Empty(CONDORXML->XML_KEYF1)
				If CONDORXML->XML_TIPODC == "D"
					nStatLeg	:= 6
				ElseIf CONDORXML->XML_TIPODC=="B"
					nStatLeg	:= 7
				ElseIf CONDORXML->XML_TIPODC=="I"
					nStatLeg	:= 8
				ElseIf CONDORXML->XML_TIPODC=="P"
					nStatLeg	:= 9
				ElseIf CONDORXML->XML_TIPODC=="C"
					nStatLeg	:= 10
				ElseIf CONDORXML->XML_TIPODC $ "T#F"
					nStatLeg	:= 11
				ElseIf CONDORXML->XML_TIPODC=="E"
					nStatLeg	:= 13
				ElseIf CONDORXML->XML_TIPODC=="S"
					nStatLeg	:= 14
				Else
					nStatLeg	:= 1
				Endif
			Else
				If !cF1Status $ " #B#C"
					nStatLeg	:= 2
				Else
					nStatLeg	:= 4
				Endif
			Endif
			If CONDORXML->XML_VLRDOC <= 0
				nPxIniVlrTot	:= AT("</vOutro><vNF>",CONDORXML->XML_ARQ)
				nPxIniVlrTot	+= 14
				nPxFimVlrTot	:= AT("</vNF>",CONDORXML->XML_ARQ)

				//><vPrest><vTPrest>137.33</vTPrest>							
				If nPxIniVlrTot == 14 //.And. nPxFimVlrTot == 0
					nPxIniVlrTot	:= At("<vPrest><vTPrest>",CONDORXML->XML_ARQ)
					nPxIniVlrTot	+= 17
					nPxFimVlrTot	:= At("</vTPrest>",CONDORXML->XML_ARQ)
				Endif


				If nPxIniVlrTot > 14 .And. nPxFimVlrTot > nPxIniVlrTot
					nXmlValNf 	:= Val(Substr(CONDORXML->XML_ARQ,nPxIniVlrTot,(nPxFimVlrTot-nPxIniVlrTot)))

					RecLock("CONDORXML",.F.)
					CONDORXML->XML_VLRDOC	:= nXmlValNf
					MsUnlock()

				Endif
			Endif

			Aadd(aArqXML,{nStatLeg,;				// 1 Status
			CONDORXML->XML_NUMNF,;				// 2 "Nº NF-e/Série",;
			CONDORXML->XML_EMISSA,;				// 3 "Emissão",;
			.F.,;								// 4 Selecionar Notas p/Lanc em Lotes
			Alltrim(cFornece),	;			   	// 5 "Fornecedor/Loja-Nome",;
			sfCC0Sts(Alltrim(CONDORXML->XML_CHAVE),!Empty(CONDORXML->XML_KEYF1),cF1Status),;	// 6 Status Manifesto
			Alltrim(CONDORXML->XML_CHAVE),;		//	7 "Chave NF-e",;
			Alltrim(Transform(CONDORXML->XML_DEST,"@R 99.999.999/9999-99")+" - " +Capital(CONDORXML->XML_NOMEDT)),;		//	"Destinatário",;            // 7
			CONDORXML->XML_CONFIS,; 				//	9 "Recebida em",;
			CONDORXML->XML_CONFER,;				//	10 "Conferida em",;
			CONDORXML->XML_LANCAD,;				//	11 "Lançada em" ;
			CONDORXML->XML_CONFCO,; 			//	12 Conf.Compras
			CONDORXML->XML_RECEB,;				//  13 Conferência Fiscal
			CONDORXML->XML_DTRVLD,;				//	14 Data Reconsulta Sefaz
			CONDORXML->XML_TIPODC,;				// 	15 Tipo de Documento
			CONDORXML->XML_VLRDOC,;				// 	16 Valor da NFe/CTe
			CONDORXML->XML_OK + "-" + CONDORBLQAUTO->XBL_DESMOT})					// 	17 Ok
		Endif
		If Len(aArqXML) > nLimLinha .And. !lAtuOnlyOne
			MsgAlert("Limite de " + cValToChar(nLimLinha)+ " linhas de notas fiscais. Favor especificar condições mais especificas nos parametros para otimizar a consulta",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Limite de linhas")
			Exit
		Endif

		DbSelectArea("CONDORXML")
		DbSkip()
	Enddo

	If lRemoveArr
		aDel(aArqXml,oArqXML:nAt)
		aSize(aArqXml,nTmArray-1)
	Endif

	If Len(aArqXml) == 0
		If !lAutoExec
			MsgAlert("Não houveram registros para este filtro!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem registros!")
		Else
			//stSendMail( "contato@centralxml.com.br", "Não houveram registros para este filtro! filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
		Endif
		Aadd(aArqXml,{1,;	// 	1 Status
		"",;			//	2 "Nº NF-e/Série",;
		CTOD(""),;	//	3 "Emissão",;
		.F.,;		//	4 Selecionar Notas p/Lanc em Lotes
		"",;			// 	5 Fornecedor/Loja-Nome",;
		oColorCte,;	//	6 Status Manifesto
		" ",;			//	7 "Chave NF-e"
		" ",;			//	8 "Destinatário",;            // 7
		CTOD(""),;		//	9 Conf.Fiscal
		CTOD(""),;		//	10 "Conferida em"
		CTOD(""),;		//	11 "Lançada em"
		CTOD(""),;		//	12 Conf.Compras
		CTOD(""),;		//	13 "Recebida em"
		CTOD(""),;		//	14 Data Reconsulta Sefaz
		" ",;			//	15 Tipo de Documento
		0,;				// 	16 Valor da NFe/CTe
		""})			//  17 Ok
		If Type("oArqXml") <> "U"
			oArqXml:nAt := 1
		Else
			stSendMail( "marcelolauschner@gmail.com", "Erro ao atribuir objeto", ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Não houveram registros" )
		Endif
		sfCC0Sts(""/* cInChave*/ ,/*lInKeySF1*/,/*cF1Status*/)
	Endif

	If oArqXml:nAt > Len(aArqXml)
		oArqXml:nAt := Len(aArqXml)
	Endif

	oArqXml:SetArray(aArqXml)
	oArqXml:bLine:={ ||{stLegenda(),;
	aArqXml[oArqXml:nAT,02],;
	aArqXml[oArqXml:nAT,03],;
	Iif(aArqXml[oArqXml:nAt,4],oMarked,oNoMarked),;
	aArqXml[oArqXml:nAT,05],;
	aArqXml[oArqXml:nAT,06],;
	aArqXml[oArqXml:nAT,07],;
	aArqXml[oArqXml:nAT,08],;
	aArqXml[oArqXml:nAT,09],;
	aArqXml[oArqXml:nAT,10],;
	aArqXml[oArqXml:nAt,11],;
	aArqXml[oArqXml:nAt,12],;
	aArqXml[oArqXml:nAt,13],;
	aArqXml[oArqXml:nAt,14],;
	aArqXml[oArqXml:nAt,15],;
	aArqXml[oArqXml:nAt,16],;
	aArqXML[oArqXML:nAt,17]}}
	oArqXml:Refresh()

	U_DbSelArea("CONDORXML",.F.,1)
	If lAtuOnlyOne
		Set Filter To
	Endif
	DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
	oCgcDest:Refresh()
	oCgcEmit:Refresh()
	oMunEmit:Refresh()
	oMunDest:Refresh()
	oNomEmit:Refresh()
	oNomDest:Refresh()
	cMsgNfe := Substr(CONDORXML->XML_ARQ,At("<infCpl",CONDORXML->XML_ARQ)+8,At("</infCpl>",CONDORXML->XML_ARQ)-At("<infCpl",CONDORXML->XML_ARQ)-7)
	oMsgNfe:Refresh()

	// Efetua a manifestação em Multithread quando com interface do usuário afins de otimizar trabalho do mesmo
	If nC00Cont==1 .And. lSuperUsr .And. Len(aChvManif) > 0
		//StartJob("U_XMLMDFE3",GetEnvServer(),.F., ,.T./*lAutoManif*/,"210200"/*cInOper*/,cEmpAnt,cFilAnt,aChvManif)//210200 - Confirmação da Operação"
		//U_XMLMDFE3(,.T./*lAutoManif*/,"210200"/*cInOper*/,,,aChvManif)//210200 - Confirmação da Operação"
		aChvAux	:= {}
		If Len(aChvManif) < 20
			If !lAutoExec
				StartJob("U_XMLMDFE3",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,cEmpAnt,cFilAnt,aChvManif,,.T./*lSetEnv*/)//210200 - Confirmação da Operação"
			Else
				U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,,,aChvManif,100)//210200 - Confirmação da Operação"
			Endif
		Else
			aChvAux	:= {}
			For nCC := 1 To Len(aChvManif)
				Aadd(aChvAux,aChvManif[nCc])
				If Mod(nCC,20) == 0
					If !lAutoExec
						StartJob("U_XMLMDFE3",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,cEmpAnt,cFilAnt,aChvAux,,.T./*lSetEnv*/)//210200 - Confirmação da Operação"
					Else
						U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,,,aChvAux,(nCC/Len(aChvManif))*100)//210200 - Confirmação da Operação"
					Endif
					aChvAux	:= {}
				Endif
			Next
			If Len(aChvAux) > 0
				If !lAutoExec
					StartJob("U_XMLMDFE3",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,cEmpAnt,cFilAnt,aChvAux,,.T./*lSetEnv*/)//210200 - Confirmação da Operação"
				Else
					U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,,,aChvAux,100)//210200 - Confirmação da Operação"
				Endif
			Endif
		Endif
	Endif

	// Efetua o monitoramento em Multithread
	If nC00Cont==1 .And. lSuperUsr .And. Len(aChvMonit) > 0 .And. !Empty(GetNewPar("XM_MDFEVPD","210200"))
		If !lAutoExec
			StartJob("U_XMLMDFE4",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lInAuto*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,cEmpAnt,cFilAnt,aChvMonit,.T./*lSetEnv*/)
		Else
			U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lInAuto*/,GetNewPar("XM_MDFEVPD","210200")/*cInOper*/,,,aChvMonit)
		Endif
	Endif

	If nC00Cont==1 .And. lSuperUsr .And. Len(aChvSinc) > 0
		If 	!lAutoExec
			StartJob("U_XMLMDFE2",GetEnvServer(),.F.,/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*cInChave*/,.T./*lInAuto*/,aChvSinc/*aInChaves*/,cEmpAnt,cFilAnt,.T./*lSetEnv*/)
		Else
			U_XMLMDFE2(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*cInChave*/,.T.,aChvSinc)
		Endif
	Endif


	// Caso seja necessária uma atualização forçada da CONDORCTEXNFS
	//For iZ := 1 To Len(aArqXml)
	//	oArqXml:nAt := iz
	//	If aArqXml[iz,14] $ "T#F"
	//		// Efetua uma query para localicar registros que não estejam atualizados 
	//		cQry := ""
	//		cQry += "SELECT COUNT(*) NEXIST "
	//		cQry += "  FROM CONDORCTEXNFS "
	//		cQry += " WHERE XCN_CHVCTE = '"+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+"' "
	//		cQry += "   AND XCN_EMP = '"+cEmpAnt+"' "
	//		cQry += "   AND XCN_FIL = '"+cFilAnt+"' "
	//		cQry += "   AND D_E_L_E_T_ =' ' "
	//	
	//		TCQUERY cQry NEW ALIAS "QXCN"

	//		If QXCN->NEXIST == 0
	//			sfGrvCte(.T.)
	//		Endif
	//		QXCN->(DbCloseArea())
	//	Endif
	//Next

	If lAutoExec // Se for rotina automatica
		sfMark(.T.)
	Endif


Return

Static Function stXMLRefres()

	Local	cChvAtu	:= Padr(aArqXml[oArqXml:nAt,nPosChvNfe],Len(CONDORXML->XML_CHAVE))

	//aDel(aArqXML,nRegDel)
	//aSize(aArqXML,nTamArq-1)

	stRefresh(.T.,cChvAtu)


Return

/*/{Protheus.doc} sfBxXml
(long_description)
@author MarceloLauschner
@since 13/01/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfBxXml()

	Local		cQry		:= ""
	Local		aChvManif	:= {}
	Local		aChavAux	:= {}
	Local		iWa 
	Local 		nCC
	
	//C00_STATUS
	//cStatusAtu	:= "0"
	//If "210200" == Substr(aMonitor[nX]:cId_Evento,3,6)
	//	cStatusAtu	:= "1"
	//ElseIf "210210" == Substr(aMonitor[nX]:cId_Evento,3,6)
	//	cStatusAtu	:= "4"
	//ElseIf "210220" == Substr(aMonitor[nX]:cId_Evento,3,6)
	//	cStatusAtu	:= "2"
	//ElseIf "210240" == Substr(aMonitor[nX]:cId_Evento,3,6)
	//	cStatusAtu	:= "3"
	//Endif
	
	//cOpcUpd := "0"
	//C00_CODEVE
	//If aListBox[nX][5]	== "3" .Or. aListBox[nX][5] == "5"
	//	cOpcUpd :=	"4"  //Evento rejeitado +msg rejeiçao
	//ElseIf aListBox[nX][5] == "6"
	//	cOpcUpd := "3"  //Evento vinculado com sucesso
	//ElseIf aListBox[nX][5] == "1"
	//	cOpcUpd := "2"  //Envio de Evento realizado - Aguardando processamento
	//EndIF
					
	If nC00Cont<>1 .Or. !lSuperUsr
		Return
	Endif
	cQry += "SELECT C00_CHVNFE,C00_STATUS "
	cQry += "  FROM "+RetSqlName("C00") + " C00 "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND C00_FILIAL = '"+xFilial("C00")+"' "
	cQry += "   AND NOT EXISTS (SELECT XML_CHAVE "
	cQry += "                     FROM CONDORXML "
	cQry += "                    WHERE XML_DEST = '"+SM0->M0_CGC+"' "
	cQry += "   					   AND XML_CHAVE = C00_CHVNFE) "
	cQry += "   AND C00_DTEMI >='"+ DTOS(dDataBase - GetNewPar("XM_NDC00DW",720))+"' "	// Somente últimos 15 dias
	cQry += "   AND C00_CODEVE IN('2') " //1-Envio de Evento não realizado 2-Envio de Evento realizado - Aguardando processamento
	cQry += "   AND C00_SITDOC = '1' " // Somente notas autorizadas

	TCQUERY cQry NEW ALIAS "QMANIF"

	While !Eof()
		DbSelectArea("C00")
		DbSetOrder(1)
		If DbSeek(xFilial("C00")+QMANIF->C00_CHVNFE)
			If (C00->C00_STATUS $ "0")
				U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lInAuto*/,"210200" /*cInOper*/,,,{QMANIF->C00_CHVNFE})
				For iWa := 1 To 10
					MsAguarde({|| Sleep( 1 * 1000) }, "Monitoranto "  + C00->C00_NUMNFE, "Aguarde " + cValToChar(10-iWa) + " segundos, monitorando evento 210200!")
				Next
				DbSelectArea("C00")
				If (C00->C00_STATUS $ "0")
					U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lInAuto*/,"210210" /*cInOper*/,,,{QMANIF->C00_CHVNFE})
					For iWa := 1 To 10
						MsAguarde({|| Sleep( 1 * 1000) }, "Monitoranto "  + C00->C00_NUMNFE, "Aguarde " + cValToChar(10-iWa) + " segundos, monitorando evento 210210!")
					Next
				Endif
				DbSelectArea("C00")

			Endif
		Endif
		DbSelectArea("QMANIF")
		DbSkip()
	Enddo
	QMANIF->(DbCloseArea())


	aChvManif	:= {}
	aChavAux	:= {}
	cQry := ""
	cQry += "SELECT C00_CHVNFE,C00_STATUS "
	cQry += "  FROM "+RetSqlName("C00") + " C00 "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND C00_FILIAL = '"+xFilial("C00")+"' "
	cQry += "   AND NOT EXISTS (SELECT XML_CHAVE "
	cQry += "                     FROM CONDORXML "
	cQry += "                    WHERE XML_DEST = '"+SM0->M0_CGC+"' "
	cQry += "   					   AND XML_CHAVE = C00_CHVNFE) "
	cQry += "   AND C00_STATUS IN('0','1','4') "	// 0=sem manifesto "210200"=1 Confirmada  "210210"=4 Ciência	"210220"=2  Desconhecimento 	"210240"=3 Nao realizada
	cQry += "   AND C00_CODEVE NOT IN('3','2','4') " //3-Evento vinculado com sucesso 1-Envio de Evento não realizado 2-Envio de Evento realizado - Aguardando processamento
	cQry += "   AND C00_DTEMI >='"+ DTOS(dDataBase - GetNewPar("XM_NDC00DW",720))+"' "	// Somente últimos 15 dias
	CqRY += "   AND C00_SITDOC = '1' " // Somente notas autorizadas

	TCQUERY cQry NEW ALIAS "QMANIF"

	While !Eof()
		Aadd(aChvManif,QMANIF->C00_CHVNFE)
		DbSelectArea("QMANIF")
		DbSkip()
	Enddo
	QMANIF->(DbCloseArea())

	aChvAux	:= {}
	If Len(aChvManif) < 20
		If Len(aChvManif) > 0
			U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,"210210"/*cInOper*/,,,aChvManif,100)//210210 - Ciência da operação
			aChvAux	:= aClone(aChvManif)
		Endif
	Else
		aChvAux	:= {}
		For nCC := 1 To Len(aChvManif)
			Aadd(aChvAux,aChvManif[nCc])
			If Mod(nCC,20) == 0
				U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,"210210"/*cInOper*/,,,aChvAux,(nCC/Len(aChvManif))*100)//210210 - Ciência da operação
				aChvAux	:= {}
			Endif
		Next
		If Len(aChvAux) > 0
			U_XMLMDFE3(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lAutoManif*/,"210210"/*cInOper*/,,,aChvAux,100)//"210210" - Ciência da operação
		Endif
	Endif
	// Monitora evento
	If Len(aChvAux) > 0
		For iWa := 1 To 30
			MsAguarde({|| Sleep( 1 * 1000) }, "Monitoranto "  + cValToChar(Len(aChvAux)) +" Notas", "Aguarde " + cValToChar(30-iWa) + " segundos, monitorando notas!")
		Next
		U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/,.T./*lInAuto*/,"210210" /*cInOper*/,,,aChvAux)		
	Endif
	// 28/01/2018 - Verifica notas que já vincular manifestação mas ainda não foram baixadas
	cQry := ""
	cQry += "SELECT C00_CHVNFE,C00_STATUS "
	cQry += "  FROM "+RetSqlName("C00") + " C00 "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND C00_FILIAL = '"+xFilial("C00")+"' "
	cQry += "   AND NOT EXISTS (SELECT XML_CHAVE "
	cQry += "                     FROM CONDORXML "
	cQry += "                    WHERE XML_DEST = '"+SM0->M0_CGC+"' "
	cQry += "   					   AND XML_CHAVE = C00_CHVNFE) "
	cQry += "   AND C00_STATUS IN('1','4') "	// 0=sem manifesto "210200"=1 Confirmada  "210210"=4 Ciência	"210220"=2  Desconhecimento 	"210240"=3 Nao realizada
	cQry += "   AND C00_CODEVE IN('3') " //3-Evento vinculado com sucesso 1-Envio de Evento não realizado 2-Envio de Evento realizado - Aguardando processamento
	cQry += "   AND C00_DTEMI >='"+ DTOS(dDataBase - GetNewPar("XM_NDC00DW",720))+"' "	// Somente últimos 15 dias
	CqRY += "   AND C00_SITDOC = '1' " // Somente notas autorizadas

	TCQUERY cQry NEW ALIAS "QMANIF"

	While !Eof()
		Aadd(aChvManif,QMANIF->C00_CHVNFE)
		DbSelectArea("QMANIF")
		DbSkip()
	Enddo
	QMANIF->(DbCloseArea())
	
	// Baixa xml
	If Len(aChvManif)  > 0
		U_XMLMDFE5(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,aChvManif )
	Endif

Return

/*/{Protheus.doc} stLegenda
(Retorna a legenda do listbox  )

@author Marcelo Lauschner
@since 20/02/2012
@version 1.0

@return oRet, Bitmap da cor conforme case

@example
(examples)

@see (links_or_references)
/*/
Static Function stLegenda()

	Local	oRet	:= oVermelho

	If Len(aArqXml) <= 0
		Return oRet
	Endif

	If	aArqXml[oArqXml:nAt,1] == 1
		oRet	:= oVermelho
	ElseIf	aArqXml[oArqXml:nAt,1] == 2
		oRet	:= oVerde
	ElseIf	aArqXml[oArqXml:nAt,1] == 3
		oRet	:= oAmarelo
	ElseIf	aArqXml[oArqXml:nAt,1] == 4
		If Posicione("SF1",8,xFilial("SF1")+aArqXml[oArqXml:nAt,7],"F1_STATUS") == "B"
			oRet 	:= oAzuCla
		Else
			oRet	:= oAzul
		EndIf
		//oRet	:= oAzul
	ElseIf	aArqXml[oArqXml:nAt,1] == 5
		oRet 	:= oPreto
	ElseIf	aArqXml[oArqXml:nAt,1] == 6
		oRet 	:= oPink
	ElseIf	aArqXml[oArqXml:nAt,1] == 7
		oRet 	:= oVioleta
	ElseIf	aArqXml[oArqXml:nAt,1] == 8
		oRet 	:= oMarrom
	ElseIf	aArqXml[oArqXml:nAt,1] == 9
		oRet 	:= oGrey
	ElseIf	aArqXml[oArqXml:nAt,1] == 10
		oRet 	:= oLaranja
	ElseIf	aArqXml[oArqXml:nAt,1] == 11
		oRet 	:= 	oColorCTe
	ElseIf aArqXml[oArqXml:nAt,1] == 12
		oRet 	:= oNoMarked
	ElseIf aArqXml[oArqXml:nAt,1] == 13
		oRet 	:= oBranco
	ElseIf aArqXml[oArqXml:nAt,1] == 14
		oRet	:= oNFseCor	
	EndIf

Return(oRet)



/*/{Protheus.doc} sfCC0Sts
(Retorna a legenda para a Manifestação de destinatário por nota fiscal)
@author MarceloLauschner
@since 16/05/2014
@version 1.0
@param cInChave, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static function sfCC0Sts( cInChave ,lInKeySF1,cF1Status)

	Local 		oClrRet
	Default	lInKeySF1	:= .F.
	Default cF1Status	:= "X"

	// Primeiro acesso
	If nC00Cont == 0 // 0=Start 1=Existe C00 2=Não Existe C00
		DbSelectArea("SX2")
		DbSetOrder(1)
		If DbSeek("C00")
			nC00Cont		:= 1 // 0=Start 1=Existe C00 2=Não Existe C00
		Else
			nC00Cont		:= 2 // 0=Start 1=Existe C00 2=Não Existe C00
			If !lAutoExec .And. PswAdmin( , ,RetCodUsr()) == 0
				Aviso("Manifesto","Execute o compatibilizador NFEP11R1 (Id. NFE11R122) para o Manifesto do destinatário" ,{STR0114},3)
			Endif
		Endif
	Endif
	// Caso não exista a tabela, retorna sem legenda
	If nC00Cont == 2
		Return oBranco
	Endif

	If Empty(cInChave) 
		Return oBranco
	Endif

	DbSelectArea("C00")
	DbSetOrder(1)
	If DbSeek(xFilial("C00")+cInChave)

		// Caso a nota fiscal já esteja lançada considera
		// E a nota não tenha sido manifestada ou somente
		If lInKeySF1 .And.;
		   !(cF1Status $ " #B#C#X") .And.;
		   (C00->C00_STATUS $ "0" .Or. (C00->C00_STATUS == "4" .And. Alltrim(GetNewPar("XM_MDFEVPD","210200")) == "210200"))
			Aadd(aChvManif,cInChave)
			// Efetua adição da chave também na verificação de Monitorar para ver se há algum evento já vinculado e não tenha atualizado o status da C00 Corretamente
			If C00->C00_CODEVE == "1  "
				Aadd(aChvMonit,cInChave)
			Endif

		Endif

		If (  C00->C00_STATUS == "0" )
			oClrRet := oBranco
			// Evento vinculado com sucesso e
		Elseif ( C00->C00_CODEVE == "3  " .And. C00->C00_STATUS == "1" )
			oClrRet := oVerde
		Elseif ( C00->C00_STATUS == "2" )
			oClrRet := oCinza
		Elseif ( C00->C00_STATUS == "3" )
			oClrRet := oVermelho
		Elseif ( C00->C00_STATUS == "4" )
			oClrRet := oAzul
			// Força a verificação do Monitorar caso o registro não esteja atualizado
			If Alltrim(C00->C00_CODEVE) $ "0#1"
				U_XMLMDFE4(/*cAlias*/, /*nReg*/, /*nOpc*/,/*cMarca*/,/*lInverte*/,/*cInChave*/cInChave,.T./*lInAuto*/,"210210"/*cInOper*/,,,)
			Endif
			// Confirmada Operação / Envio de evento realizado - Aguardando processamento
		Elseif (  C00->C00_STATUS == "1" .And. C00->C00_CODEVE $ "2  #0  " )
			Aadd(aChvMonit,cInChave)
			oClrRet	:= oLaranja
		Else
			oClrRet	:= oLaranja
		Endif
	Else
		// Efetua a manifestação como Ciência da Operação de cada nota
		If lInKeySF1 .And. ;
		   !(cF1Status $ " #B#C#X") 
			DbSelectArea("SF1")
			DbSetOrder(8)
			If DbSeek(XFilial("SF1")+cInChave)
				If SF1->F1_FORMUL <> "S" .and. !Empty(SF1->F1_CHVNFE) .and. Alltrim(SF1->F1_ESPECIE) == "SPED"
					sfMDeMata103(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SF1->F1_VALBRUT,SF1->F1_TIPO,SF1->F1_CHVNFE,Iif(SF1->(FieldPos("F1_DAUTNFE")) > 0 , SF1->F1_DAUTNFE,CTOD("")))
				Endif
			Endif
		Endif

		If Substr(cInChave,21,2) == "55" // Se for NFe e ainda não estiver com registro na C00
			Aadd(aChvSinc,cInChave)
		Endif
		oClrRet := oColorCTe
	Endif

return oClrRet



/*/{Protheus.doc} sfMDeMata103
//TODO Descrição auto-gerada.
@author marce
@since 02/07/2017
@version 6
@param cNumNFe, characters, descricao
@param cSerie, characters, descricao
@param cClieFor, characters, descricao
@param cLoja, characters, descricao
@param dDtEmis, date, descricao
@param nValNFe, numeric, descricao
@param cTipoNFe, characters, descricao
@param cChave, characters, descricao
@param dDtAut, date, descricao
@type function
/*/
Static Function sfMDeMata103 (cNumNFe,cSerie,cClieFor,cLoja,dDtEmis,nValNFe,cTipoNFe,cChave,dDtAut)

	Local aArea	:= GetArea()
	Local aAreaSA1:= SA1->(GetArea())
	Local aAreaSA2:= SA2->(GetArea())

	Local cRazao	:= ""
	Local cCNPJEM	:= ""
	Local cIEemit	:= ""

	Default cNumNFe	:= ""
	Default cSerie	:= ""
	Default cClieFor	:= ""
	Default cLoja		:= ""
	Default cTipoNFe	:= ""
	Default cChave	:= ""

	Default nValNFe	:= 0
	Default dDtEmis	:= CtoD("  /  /    ")
	Default dDtAut	:= CtoD("  /  /    ")

	cSerie := substr(cChave,23,3)
	cNumNfe:= substr(cChave,26,9)

	// Validar se o emitente da NF-e a ser manifestada é o cliente ou fornecedor
	If (!Empty(cClieFor) .and. !Empty(cLoja) .and. !Empty(cTipoNFe))
		If cTipoNFe $ "DB" 
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+cClieFor+cLoja)
			cRazao  := Alltrim(SA1->A1_NOME)
			cCNPJEM := AllTrim(SA1->A1_CGC)
			cIEemit := Alltrim(SA1->A1_INSCR)
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)  				
			MsSeek(xFilial("SA2")+cClieFor+cLoja)
			cRazao  := Alltrim(SA2->A2_NOME)
			cCNPJEM := AllTrim(SA2->A2_CGC)
			cIEemit := Alltrim(SA2->A2_INSCR)
		EndIf
	EndIf
	// Evita de incluir manualmente notas na C00 com emissão a mais de 180 dias. 
	If (Date() - dDtEmis) < 180 .And. FindFunction("MDeManual")
		MDeManual(1,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit)
	Endif
	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)

Return 

/*/{Protheus.doc} stPesquisa
(Permite localizar uma nota pelo get de pesquisa   )

@author MarceloLauschner
@since 20/02/2012
@version 1.0

@param lPesqManual,logico, (Descrição do parâmetro)

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stPesquisa(lPesqManual)

	Local		lFind		:= .F.
	Local		lExistFind	:= !Empty(cVarPesq)
	Local		nQ

	Default		lPesqManual	:= .F.

	For nQ := 1 To Len(aArqxml)
		If Alltrim(cVarPesq) $ aArqXml[nQ,2]
			oArqXml:nAT 	:= nQ
			oArqXml:Refresh()
			lFind	:= .T.
			Exit
		Endif
	Next


	If lFind
		Eval(oArqXml:bChange)
		oArqXml:SetFocus()
	ElseIf lExistFind .And. !lFind .And. lPesqManual
		// Força o preenchimento do campo que se deseja pesquisar
		u_gravasx1("XMLDCONDOR","17",cVarPesq)
		MsAguarde({|| Pergunte(cPergXml,.F.),stRefresh(), stRefrItem(),oArqXml:SetFocus() }, "Aguarde. Filtrando registros", "Aguarde a localização dos dados informados!")
		//MsgAguard Eval({|| Pergunte(cPergXml,.F.),stRefresh(), stRefrItem(),oArqXml:SetFocus()})			
	ElseIf !lExistFind .And. !lFind .And. lPesqManual
		// Força o preenchimento do campo que se deseja pesquisar
		u_gravasx1("XMLDCONDOR","17",cVarPesq)
		MsAguarde({|| Pergunte(cPergXml,.F.),stRefresh(), stRefrItem(),oArqXml:SetFocus() }, "Aguarde. Filtrando registros", "Aguarde a localização dos dados informados!")
	Else
		oArqXml:SetFocus()
	Endif
	cVarPesq		:= Space(TamSX3("F1_CHVNFE")[1])//Space(nTmF1Ser+nTmF1Doc)

Return (.T.)




/*/{Protheus.doc} stConSefaz
(Efetua a consulta da Chave na Sefaz  )

@author Marcelo Lauschner
@since 20/02/2012
@version 1.0

@param cChave, character, (Descrição do parâmetro)
@param lExterna, logico, (Descrição do parâmetro)

@return logico, consulta ok

@example
(examples)

@see (links_or_references)
/*/
Static Function stConSefaz(cChave,lExterna,lRejeita,cMensagem)

	Local	oDlgChv
	Local	lConsulta	:= .F.
	Local	lCte		:= .F.
	Local	aAreaold	:= GetArea()
	Local	lRet		:= .F.
	Local  	aTmSize		:= MsAdvSize( .F., .F., 400 )
	Default	lRejeita	:= .F.
	Default	cMensagem	:= ""
	Default	lExterna	:= .F.

	If Substr(cChave,21,2) == "65"
		MsgInfo("Por se tratar de uma NFC-e não há consulta on-line ainda disponível desenvolvida. ", ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Return .T. 
	Endif

	If !Empty(cChave)
		// Se a chamada da rotina aconteceu por StaticCall, força a atualização da pergunta para não dar erro de filtro na tabela CONDORXML
		If lExterna
			aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
			Pergunte("XMLDCONDOR",.F.)
		Endif

		cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))
		cNavegado  	+= cChave
		If Alltrim(GetMv("XM_URLCSFZ")) <> "http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe="
			If MsgYesNo("Há um novo endereço URL para consulta do NF-e via Browse Microsiga. Deseja atualizar?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Nova URL NF-e Sefaz ")
				PutMv("XM_URLCSFZ","http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe=")
				cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))
				cNavegado 	+= cChave
			Endif
		Endif
		
		U_DbSelArea("CONDORXML",.F.,1)
		If DbSeek(cChave)
			If CONDORXML->XML_TIPODC $ "T#F"
				//cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))
				cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))

				If Alltrim(GetMv("XM_URLSFZ2")) <> "http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte="
					If MsgYesNo("Há um novo endereço URL para consulta do CT-e via Browse Microsiga. Deseja atualizar?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Nova URL CT-e Sefaz ")
						PutMv("XM_URLSFZ2","http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte=")
						//                  http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=
						cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))
						cNavegado 	+= cChave
					Else
						lCte		:= .T.
					Endif

				Else
					cNavegado += cChave
				Endif

			Endif
		Else
			//41160412397676000140570010000016311777319562
			If Substr(cChave,21,2) == "57"
				cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))
				cNavegado += cChave
			Endif
		Endif
		Define MsDialog oDlgChv From 0,0 TO aTmSize[6] , aTmSize[5]  Pixel Title (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Web Browser")

		If lCte
			@ 005,010 Say "Chave do CT-e / Use CTRL+C para copiar, e depois colar na página abaixo" of oDlgChv Pixel
			@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgChv Pixel
		Else
			@ 005,010 Say "Endereço URL da Consulta" of oDlgChv Pixel
			@ 015,010 MsGet oNavegado var cNavegado Size 300,05 Of oDlgChv Pixel
		Endif
		oTIBrowser:= TIBrowser():New(025,010, aTmSize[5]/2.04,aTmSize[6]/2.2, cNavegado, oDlgChv)

		If __cUserId $ Iif(File("xmusrxmln_"+cEmpAnt+".usr"),MemoRead("xmusrxmln_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLN","") )
			@ 010, 350 Button oBtnSefaz PROMPT "Confirmar Consulta" Size 70,10 Action (lConsulta := .T.,lRejeita := .F. ,oDlgChv:End()) Of oDlgChv Pixel

			@ 010, 440 Button oBtnPrtSf PROMPT "Rejeitar" Size 40,10 Action  (lConsulta := .T.,lRejeita := .T., oDlgChv:End())  Of oDlgChv Pixel //oTIBrowser:Print() Of oDlg Pixel
		Endif

		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgChv:End()) Of oDlgChv Pixel

		Activate MsDialog oDlgChv Centered

		If lConsulta .And. MsgYesNo("Confirma que foi consultada a nota digitando o Captcha e a Situação Atual do Documento Eletrônico? ","Confirmação! " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			U_DbSelArea("CONDORXML",.F.,1)
			If DbSeek(cChave)

				lRet	:= .T.
				//MsgAlert(lRejeita,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				If lRejeita
					lRet := stRejeita(cChave,cMensagem,lAutoExec,lRejeita)
				Endif
				If lRet
					RecLock("CONDORXML",.F.)
					If Empty(CONDORXML->XML_CONFER)
						CONDORXML->XML_CONFER := Date()
						CONDORXML->XML_HORCON := Time()
						CONDORXML->XML_USRCON := Padr(cUserName,30)
					Endif
					// Efetuo verificação se a Nota não validou pelo padrão do Webservice a consulta, grava a consulta manual na Sefaz
					// Verifico se a nota ainda não foi revalidada e se o prazo de horas para reconferencia já expirou o parametro
					nPxHora	:= AT("</chNFe><dhRecbto>",CONDORXML->XML_ARQ)
					If nPxHora <= 0
						nPxHora	:= AT("</chCTe><dhRecbto>",CONDORXML->XML_ARQ)
						If nPxHora > 0
							cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+18,20),"-","")
						Endif
					Else
						cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+18,20),"-","")
					Endif
					If nPxHora <= 0
						nPxHora	:= AT("<dhRecbto>",CONDORXML->XML_ARQ)
						If nPxHora > 0
							cDtHora := StrTran(Substr(CONDORXML->XML_ARQ,nPxHora+10,20),"-","")
						Endif
					Endif
					If nPxHora > 0 .And. Empty(CONDORXML->XML_DTRVLD) .And. (cDtHora <=  DTOS(Date()-(Int(GetMv("XM_SPEDEXC")/24)))+"T"+Time()) .And. Empty(CONDORXML->XML_REJEIT)
						//If Empty(CONDORXML->XML_DTRVLD) .And. CONDORXML->XML_EMISSA <=  (Date() - (GetMv("XM_SPEDEXC")/24)) .And. Empty(CONDORXML->XML_REJEIT)
						CONDORXML->XML_DTRVLD	:= Date()
					Endif
					MsUnlock()
				Endif
			Endif
		Endif
		// Restauro as perguntas para evitar erro de posicionamento anterior
		If lExterna
			StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
		Endif
	Endif

	RestArea(aAreaOld)

Return lRet




/*/{Protheus.doc} ValidPerg
(Cria e valida perguntas da rotina    )

@author MarceloLauschner
@since 02/12/2013
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function ValidPerg()

	Local	aAreaOld	:= GetArea()
	Local 	aRegs := {}
	Local 	i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPergXml :=  PADR(cPergXml,Len(SX1->X1_GRUPO))

	DbSelectArea("SX3")
	DbSetOrder(2)

	//     "X1_GRUPO" 		,"X1_ORDEM"	,"X1_PERGUNT"    			,"X1_PERSPA"				,"X1_PERENG"			,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"		,"X1_DECIMAL"		,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID","X1_VAR01"	,"X1_DEF01"			,"X1_DEFSPA1"		,"X1_DEFENG1"	,"X1_CNT01"	,"X1_VAR02"		,"X1_DEF02"			,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02"	,"X1_VAR03"	,"X1_DEF03"		,"X1_DEFSPA3"		,"X1_DEFENG3"	,"X1_CNT03"		,"X1_VAR04"	,"X1_DEF04"		,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04"		,"X1_VAR05"	,"X1_DEF05","X1_DEFSPA5"	,"X1_DEFENG5"	,"X1_CNT05"	,"X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"
	Aadd(aRegs,{cPergXml ,"01"			,"Apenas NF-e Empresa"  	,"Apenas NF-e Empresa"		,"Apenas NF-e"			,"mv_ch1"	 	,"N"		,1					,0					,1				,"C"		,""			,"mv_par01"	,"Apenas Empresa"	,"Apenas"			,"Apenas esa"	,""			,""				,"Todas Empresas"	,"Todas Empresas"	,"Todas Empresas"	,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,""			,""			,""				,""})
	DbSeek("A2_COD")
	Aadd(aRegs,{cPergXml ,"02"			,"Fornecedor de"			,"Fornecedor de "	 		,"Fornecedor de"		,"mv_ch2"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par02"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"SA2" 		,"S"		,"001"			,""})
	DbSeek("A2_LOJA")
	Aadd(aRegs,{cPergXml ,"03"			,"Loja "					,"Loja "					,"Loja "				,"mv_ch3"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par03"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	DbSeek("A2_COD")
	Aadd(aRegs,{cPergXml ,"04"			,"Fornecedor Até"			,"Fornecedor Até"	 		,"Fornecedor Até"		,"mv_ch4"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par04"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"SA2" 		,"S"		,"001"			,""})
	DbSeek("A2_LOJA")
	Aadd(aRegs,{cPergXml ,"05"			,"Loja "					,"Loja "					,"Loja Até"				,"mv_ch5"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par05"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"06"			,"Emissão de"				,"Emissão de "	 			,"Emissão de"			,"mv_ch6"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par06"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"07"			,"Emissão até"				,"Emissão até"				,"Emissão"				,"mv_ch7"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par07"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"08"			,"Status da Nota"       	,"Status"           		,"Status"	        	,"mv_ch8"		,"N"		,1					,0					,1				,"C"		,""			,"mv_par08"	,"Apenas Conf.Compras","Conf."			,"Conf."		,""  		,""				,"Sem Conf.Compras","Sem Conf.pras","Sem Conf.Compras" 		,""			,""       	,"Rejeitadas"	,"Rejeitad"			,"Rejeitadas"	,""				,""			,"Sem Conf.SEFAZ","Sem Conf."	,"Sem Conf.AZ"	,""				,""			,"Todos XML","Todos XML" 	,"Todos XML"	,""			,""			,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"09"			,"CNPJ Forn.de"				,"Fornecedor de "	 		,"Fornecedor de"		,"mv_ch9"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par09"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"10"			,"CNPJ Forn.Até"			,"Fornecedor Até"	 		,"Fornecedor Até"		,"mv_cha"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par10"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"11"			,"Conf.Sefaz Manual?"   	,"Conf.Sefaz?"      		,"Confere Sefaz?"   	,"mv_chb"		,"N"    	,1					,0					,2				,"C"		,""			,"mv_par11"	,"Manual Browse"	,"Sim"				,"Sim"			,""			,""				,"Aut.WebService"	,"Não" 				,"Não"				,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"12"			,"Total Impostos XML?" 		,"Totais Impostos XML?"		,"Totais Impostos XML?"	,"mv_chc"		,"N"    	,1					,0					,2				,"C"		,""			,"mv_par12"	,"Cab+Itens"		,"Cab+Itens"		,"Cab+Itens"	,""			,""				,"Despesa/Frete/Desc.","Despesa/Frete/D","Despesa/Frete/D."	,""			,""			,"Cabecalho"	,"Cabecalho"		,"Cabecalho"	,""				,""			,"Nao leva Totais","Nao leva To","Nao leva Tots",""				,""			,"So itens"	,"So itens"		,"So itens"		,"" 		,""			,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"13"			,"Opção Cadastro Produto" 	,"DOpção Cadastro Produto"	,"Opção Cadastro Produt","mv_chd"		,"N"		,1					,0					,1				,"C"		,""			,"mv_par13"	,"Mata010-Compras" 	,"Mata010"			,"Mata010"		,""  		,""				,"Loja110-Sigaloja"	,"Loja110"			,"Loja110"			,""			,""			,""				,""					,"" 			,""				,""			,""				,""				,""				,""				,""			,""			,"" 			,""				,""			,""			,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"14"			,"Exibir Vinculo PC/NF?"	,"Exibir Vinculo PC/NF?"	,"Exibir Vinculo?"		,"mv_che"		,"N"    	,1					,0					,1				,"C"		,""			,"mv_par14"	,"Exibe Pergunta"	,"Exibe Pergunta"	,"Exibe Pergunta",""		,""				,"Vinculo Automático","Vinculo Automáti","Vinculo Automátic",""			,""			,"Vínculo Manual","Vínculo Manual"	,"Vínculo"		,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"15"			,"Filtro de Notas?"			,"Fitro de Notas"    		,"Filtro de Notas"  	,"mv_chf"		,"N"    	,1					,0					,1				,"C"		,""			,"mv_par15"	,"Todas"    		,"Todas"      		,"Todas"	    ,""	   		,""				,"Pre-notas"    	,"Pre-Notas"     	,"Pre-Notas"     	,""	       	,""			,"Tipo CTe" 	,"Tipo CTe"     	,"Tipo CTe"		,""				,""			,"Tipo SPED"	,"Tipo SPED"	,"Tipo SPED"	,""				,""			,"Devolução/Benef.","Devolução"	,"Devolução"	,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"16"			,"Doc.Lançado?"       		,"Doc.Lançado?"     		,"Doc.Lançado?"	   		,"mv_chg"		,"N"		,1					,0					,1				,"C"		,""			,"mv_par16"	,"Ambos" 	   		,"Ambos"			,"Ambos"		,""  		,""				,"Lançado"			,"Lançado"			,"Lançado"			,""			,""			,"Em Aberto"	,"Em Aberto"		,"Em Aberto" 	,""				,""			,""				,""				,""				,""				,""			,""			,"" 			,""				,""			,""			,"S"		,""				,""})
	DbSeek("F1_CHVNFE")
	Aadd(aRegs,{cPergXml ,"17"			,"Somente Chave Eletrônica?"	,"Chave Eletrônica"		,"Chave Eletrônica"		,"mv_chh"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par17"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"18"			,"Somente Número Fatura CTe?"	,"Fatura CTe"			,"Fatura CTe"			,"mv_chi"		,"C"		,09					,0					,0				,"G"		,""			,"mv_par18"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})

	Aadd(aRegs,{cPergXml ,"19"			,"Se lançado/Digitação de"	,"Se lançado/Digitação de"	,"Se lançado/Digitação ","mv_chj"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par19"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPergXml ,"20"			,"Se lançado/Digitação Até"	,"Se lançado/Digitação Até"	,"Se lançado/Digitação"	,"mv_chk"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par20"	,""					,""					,""				,""			,""				,""					,""					,""					,""			,""			,""				,""					,""				,""				,""			,""				,""				,""				,""				,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})



	dbSelectArea("SX1")
	dbSetOrder(1)

	For i:=1 to Len(aRegs)
		If !dbSeek(cPergXml+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Else
			// Corrige bug da descriçaõ da pergunta 11 = Consulta sefaz para versões para mais antigas da rotina
			// Adicionada alteração da pergunta 15 que permite filtrar tipos de nota e pre-notas
			// 12/05/2016 Corrige a pergunta 13 para ser uma opção entre MATA010 ou LOJA110 
			If 	(aRegs[i,2] == "11" .And. Alltrim(SX1->X1_PERGUNT) <> aRegs[i,3]) .Or.  ;
			(aRegs[i,2] == "12" .And. Alltrim(SX1->X1_PERGUNT) <> aRegs[i,3]) .Or.  ;
			(aRegs[i,2] == "15" .And. Alltrim(SX1->X1_PERGUNT) <> aRegs[i,3]) .Or. ;
			(aRegs[i,2] == "03" .And. SX1->X1_TAMANHO <> aRegs[i,8]) .Or.  ;
			(aRegs[i,2] == "13" .And. SX1->X1_TAMANHO <> aRegs[i,8]) .Or.  ;
			(aRegs[i,2] == "05" .And. SX1->X1_TAMANHO <> aRegs[i,8]) .Or. ;
			(aRegs[i,2] == "17" .And. Alltrim(SX1->X1_PERGUNT) <> aRegs[i,3]).Or. ;
			(aRegs[i,2] == "12" .And. Alltrim(SX1->X1_PERGUNT) <> aRegs[i,3])

				RecLock("SX1",.F.)
				For j:=1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
				MsUnlock()
			Endif
		Endif
	Next

	RestArea(aAreaOld)

Return



Static Function sfRefItens()

	Processa({|| stRefrItem(.T.) },"Aguarde carregando itens....")

Return

/*/{Protheus.doc} stRefrItem
(Atualiza os itens da nota em cursor no listbox)

@author MarceloLauschner
@since 02/12/2013
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stRefrItem(lRecarrega)

	Local	cQry		:= ""
	Local	cAviso		:= ""
	Local	cErro		:= ""
	Local	nFocusLost	:= GetFocus()
	Local	aAuxCols	:= {}
	Local	cLocPad		:= GetNewPar("XM_B1LOCPD","  ") // Se existir o parametro de Armazém Padrão
	Local	cAuxLoc		:= cLocPad
	Local	nC7PRECO	:= 0
	Local	nI,iR
	Local	cMvTesPcnf	:= GetNewPar("MV_TESPCNF","") 
	Local	cRetNewTes	:= ""
	Local	nNewLin		:= 0
	Local	nForA
	Local	nRecXIT		:= 0
	Local 	cChvNfe		:= Padr(Iif(Len(aArqXml) > 0 .And. oArqXml:nAt <= Len(aArqXml) , aArqXml[oArqXml:nAt,nPosChvNfe]," "),Len(CONDORXMLITENS->XIT_CHAVE))
	Default	lRecarrega	:= .F.
	Private lConvProd	:= .F.
	Private oNfe
	Private oCte

	cCodForn		:= Space(TamSX3("F1_FORNECE")[1])
	cLojForn    	:= Space(TamSX3("F1_LOJA")[1])
	// Botão para cadastrar Fornecedor automaticamente sempre será desabilitado primeiro
	oBtnCom06:lActive		:= .F.


	U_DbSelArea("CONDORXML",.F.,1)
	If Len(aArqXml) == 0 .Or. !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe]) .Or. Empty(aArqXml[oArqXml:nAt,nPosChvNfe])

		nTotalNfe	:= 0
		nTotalXml   := 0

		aAuxCols	:= {}
		Aadd(aAuxCols,Array(Len(oMulti:aHeader)+1))

		aAuxCols[Len(aAuxCols)][Len(oMulti:aHeader)+1]	:= .F.
		For nI := 1 To Len(oMulti:aHeader)
			If oMulti:aHeader[nI,8]	== "C"
				aAuxCols[Len(aAuxCols)][nI] :=	" "
			ElseIf oMulti:aHeader[nI,8]	== "D"
				aAuxCols[Len(aAuxCols)][nI] := CTOD("")
			ElseIf oMulti:aHeader[nI,8]	== "N"
				aAuxCols[Len(aAuxCols)][nI] :=	0
			ElseIf oMulti:aHeader[nI,8]	== "L"
				aAuxCols[Len(aAuxCols)][nI] :=	.F.
			Endif
			If oMulti:aHeader[nI,2] == "XIT_ITEM"
				aAuxCols[Len(aAuxCols)][nI] :=	StrZero(1,oMulti:aHeader[nI,4])
			Endif
		Next

		oMulti:aCols	:= aClone(aAuxCols)

		oMulti:oBrowse:Refresh()
		nTotalNFe 	:= 0
		nTotalXml	:= 0
		oTotalNfe:Refresh()
		oTotalXml:Refresh()

		oBtnView01:lActive 	:= .F.
		oBtnView02:lActive 	:= .F.
		oBtnView03:lActive 	:= .F.
		oBtnView04:lActive 	:= .F.

		oCgcDest:Refresh()
		oCgcEmit:Refresh()
		oMunEmit:Refresh()
		oMunDest:Refresh()
		oNomEmit:Refresh()
		oNomDest:Refresh()

		cMsgNfe := ""
		oMsgNfe:Refresh()
		SetFocus(nFocusLost)
		Return
	Endif
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	Endif
	cTipo		:= aArqXml[oArqXml:nAt,nPosTpNota]
	If cTipo $ "S" 
		cTipo	:= "N"
	Endif 
	cEspecie	:= IIf(cTipo $ "F#T",Padr("CTE",TamSX3("F1_ESPECIE")[1]),Padr("SPED",TamSX3("F1_ESPECIE")[1]))
	cTipo		:= sfVldTpCTE()
	dDemissao	:= CONDORXML->XML_EMISSA
	
	IncProc("Validando dados do cabeçalho da nota.")
	
	cQry += "SELECT XML_DEST,XML_CHAVE,XML_TIPODC,XML_CODLOJ,A2_COD,A2_LOJA,A2_CGC,XML_NOMEMT "
	cQry += "  FROM CONDORXML XM, "+RetSqlName("SA2") + " A2 "
	cQry += " WHERE A2.D_E_L_E_T_ = ' ' "
	cQry += "   AND A2_CGC = XML_EMIT "
	cQry += "   AND XML_EMIT != ' ' "
	cQry += "   AND A2_FILIAL = '"+xFilial("SA2")+"' "
	cQry += "   AND XM.D_E_L_E_T_ = ' ' "
	cQry += "   AND XML_TIPODC IN('N','C','I','P','T','F') "
	cQry += "   AND XML_CHAVE = '"+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+"' "
	cQry += "   AND XML_DEST = '"+SM0->M0_CGC+"' "
	cQry += "UNION ALL "
	cQry += "SELECT XML_DEST,XML_CHAVE,XML_TIPODC,XML_CODLOJ,A1_COD A2_COD,A1_LOJA A2_LOJA,A1_CGC A2_CGC,XML_NOMEMT "
	cQry += "  FROM CONDORXML XM, "+RetSqlName("SA1") + " A1 "
	cQry += " WHERE A1.D_E_L_E_T_ = ' ' "
	cQry += "   AND A1_CGC = XML_EMIT "
	cQry += "   AND A1_FILIAL = '"+xFilial("SA2")+"' "
	cQry += "   AND XML_EMIT != ' ' "
	cQry += "   AND XM.D_E_L_E_T_ = ' ' "
	cQry += "   AND XML_TIPODC IN('D','B') "
	cQry += "   AND XML_CHAVE = '"+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+"' "
	cQry += "   AND XML_DEST = '"+SM0->M0_CGC+"' "
	cQry += " UNION ALL "
	cQry += "SELECT XML_DEST,XML_CHAVE,XML_TIPODC,XML_CODLOJ,A2_COD,A2_LOJA,A2_CGC,XML_NOMEMT "
	cQry += "  FROM CONDORXML XM, "+RetSqlName("SA2") + " A2 "
	cQry += " WHERE A2.D_E_L_E_T_ = ' ' "
	cQry += "   AND RTRIM(A2_NOME) = RTRIM(UPPER(XML_NOMEMT)) "
	cQry += "   AND A2_FILIAL = '"+xFilial("SA2")+"' "
	cQry += "   AND XM.D_E_L_E_T_ = ' ' "
	cQry += "   AND XML_TIPODC IN('N','C','I','P','T','F') "
	cQry += "   AND XML_CHAVE = '"+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+"' "
	cQry += "   AND XML_DEST = '"+SM0->M0_CGC+"' "

	TCQUERY cQry NEW ALIAS "QRY"
	DbSelectArea("QRY")
	If !Empty(QRY->XML_DEST)
		lConvProd	:= .T.
		If QRY->XML_TIPODC $ "N#C#I#P#T#F#S"
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
					cCodForn    := SA2->A2_COD
					cLojForn    := SA2->A2_LOJA
					// Verifica se não houve um erro de atribuição de Código/Loja e força nova verificação
					If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
						DbSelectArea("SA2")
						DbSetOrder(3)
						DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
						cCodForn	:= SA2->A2_COD
						cLojForn	:= SA2->A2_LOJA
						sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek(xFilial("SA2")+cCodForn+cLojForn)
						cFornece := cCodForn+"/"+cLojForn + "-" +SA2->A2_NOME
					Endif
				Endif
			Else
				DbSelectArea("SA2")
				DbSetOrder(3)
				If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA

					sfVldCliFor('SA2', @cCodForn, @cLojForn ,QRY->XML_NOMEMT,.T.,CONDORXML->XML_TIPODC)

					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+cCodForn+cLojForn)
				Else
					// CNPJ não encontrado no cadastro de fornecedores, habilita funcão de cadastro
					oBtnCom06:lActive		:= .T.
				Endif
			Endif
		Else
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
					cCodForn	:= SA1->A1_COD
					cLojForn	:= SA1->A1_LOJA
				Endif
			Else
				DbSelectArea("SA1")
				DbSetOrder(3)
				If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
					cCodForn	:= SA1->A1_COD
					cLojForn	:= SA1->A1_LOJA
					sfVldCliFor('SA1', @cCodForn, @cLojForn ,QRY->XML_NOMEMT,.T.,CONDORXML->XML_TIPODC)

					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1")+cCodForn+cLojForn)
					cCodForn	:= SA1->A1_COD
					cLojForn	:= SA1->A1_LOJA
				Endif
			Endif
		Endif
	Else
		oBtnCom06:lActive		:= .T.
	Endif
	QRY->(DbCloseArea())
	// Atribui variável para evitar erros de gatilho
	cA100For	:= cCodForn
	cLoja		:= cLojForn

	// Notas que não estejam pendentes de serem lançadas não serão validados os itens.
	If aArqXml[oArqXml:nAt,1] > 1 .And. aArqXml[oArqXml:nAt,1] < 6
		lConvProd 	:= .F.
	Endif


	nTotalNfe	:= 0
	nTotalXml   := 0


	oCgcDest:Refresh()
	oCgcEmit:Refresh()
	oMunEmit:Refresh()
	oMunDest:Refresh()
	oNomEmit:Refresh()
	oNomDest:Refresh()
	oMulti:oBrowse:Refresh()
	oTotalXml:Refresh()
	oTotalNfe:Refresh()
	cMsgNfe := Substr(CONDORXML->XML_ARQ,At("<infCpl",CONDORXML->XML_ARQ)+8,At("</infCpl>",CONDORXML->XML_ARQ)-At("<infCpl",CONDORXML->XML_ARQ)-8)
	oMsgNfe:Refresh()

	oBtnView01:lActive := !Empty(CONDORXML->XML_ATT2)
	oBtnView02:lActive := .T.
	oBtnView03:lActive := !Empty(CONDORXML->XML_ATT4)
	oBtnView04:lActive := .T.

	// Desabilita botão caso não haja como lancar o documento
	If !Empty(CONDORXML->XML_KEYF1) .Or. !Empty(CONDORXML->XML_REJEIT) .Or. CONDORXML->XML_TIPODC $ "T#F"
		oBtnCom04:lActive := .F.
		If lComprUsr .And. GetNewPar("XM_GERASC7",.F.)
			oBtnCom02:lActive := .F.
		Endif
		oBtnCom01:lActive := .F.
	Else
		oBtnCom04:lActive := .T.
		If lComprUsr .And. GetNewPar("XM_GERASC7",.F.)
			oBtnCom02:lActive := .T.
		Endif
		oBtnCom01:lActive := .T.
	Endif

	oBtnCon03:lActive	:= .F.
	
	IncProc("Verificando se há CTes relacionados.")
	
	// Desabilita botão para exibir CTe X NF
	// Melhoria desenvolvida em 11/01/2013
	cQry := ""
	cQry += "SELECT COUNT(*) NEXIST "
	cQry += "  FROM CONDORCTEXNFS "
	cQry += " WHERE XCN_CHVCTE = '"+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+"' "
	cQry += "   AND XCN_EMP = '"+cEmpAnt+"' "
	cQry += "   AND XCN_FIL = '"+cFilAnt+"' "
	cQry += "   AND D_E_L_E_T_ =' ' "

	TCQUERY cQry NEW ALIAS "QXCN"

	If QXCN->NEXIST > 0
		oBtnCon03:lActive := .T.
		//sfGrvCte(.T.)
	ElseIf aArqXml[oArqXml:nAt,nPosTpNota] $ "F#T"
		sfGrvCte(.T.)
	Endif

	If Select("QXCN") > 0
		QXCN->(DbCloseArea())
	Endif

	DbSelectArea("SF8")
	DbSetOrder(1) // F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA
	cChvSF1	:= Substr(CONDORXML->XML_KEYF1,1,Len(SF8->F8_FILIAL) + Len(SF8->F8_NFDIFRE) + Len(SF8->F8_SEDIFRE))
	If DbSeek(cChvSF1)//
		oBtnCon03:lActive := .T.
	Endif


	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(CONDORXML->XML_KEYF1)
		oBtnDoc05:lActive := .T.
	Else
		oBtnDoc05:lActive := .F.
	Endif

	// Melhoria implementa em 09/06/2012 afins de permitir ao usuário decidir que não quer vincular aquela nota fiscal pois posicionou por engano
	// Desta forma agora, quando ele quer amarrar uma nota fiscal
	If lConvProd .And. CONDORXML->XML_TIPODC $ "D#B#N"
		// Sempre pergunta
		If lAutoExec
			lConvProd	:= .T.
		ElseIf !Empty(CONDORXML->XML_TPNF) .And. CONDORXML->XML_TPNF == "0" 
			lConvProd	:= .F.
		ElseIf !Empty(CONDORXML->XML_CONFCO)
			lConvProd	:= .T.
		ElseIf lFirstRefIt
			lConvProd	:= .F.
		ElseIf lRecarrega
			lConvProd	:= .T.
		ElseIf MV_PAR14 == 1
			If Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha vinculo automático ou manual",;
			"Conversão Produto X Fornecedor/Cliente e Vinculo com Pedido/Nota Origem. Esta pergunta visa a evitar todas as amarrações obrigatórias, caso esteja apenas posicionando sobre uma nota sem querer validar ela. Mas caso posicionar na nota e não confirmar a opção 'Automático', será necessário validar item a item a conversão de Produto X Fornecedor/Cliente e vinculo com Pedido/Doc.Origem se quiser validar a mesma.",;
			{"&Automático","&Manual"},3) <> 1
				lConvProd	:= .F.
			Endif
			// Automatico
		ElseIf MV_PAR14 == 2
			lConvProd	:= .T.
		ElseIf MV_PAR14 == 3
			lConvProd	:= .F.
		Endif
	Endif
	// Primeiro refresh de itens já aconteceu. 
	lFirstRefIt := .F.

	aChvNfes := {}
	// Tratativa adicionada que localiza se Existe a Tag de Chaves eletronicas referenciadas na Nota fiscal e as exibe na tela
	// e alimenta array para futuro uso da mesma.
	If At("<NFref><refNFe>",CONDORXML->XML_ARQ) > 0
		cAviso	:= ""
		cErro	:= ""
		oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)

		If !Empty(cErro)
			MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
		Endif

		If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
			oNF	:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_NFe
		ElseIf Type("oNFe:_NfeProc:_NFe") <> "U"
			oNF := oNFe:_NFeProc:_NFe
		ElseIf Type("oNFe:_NFe")<> "U"
			oNF := oNFe:_NFe
		ElseIf Type("oNFe:_InfNfe")<> "U"
			oNF := oNFe
		ElseIf Type("oNFe:_NfeProc:_nfeProc:_NFe") <> "U"
			oNF := oNFe:_nfeProc:_NFeProc:_NFe
		Else
			cAviso	:= ""
			cErro	:= ""
			oNfe := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)
			If Type("oNFe:_NfeProc")<> "U"
				oNF := oNFe:_NFeProc:_NFe
			ElseIf Type("oNFe:_Nfe")<> "U"
				oNF := oNFe:_NFe
			Else
				If !lAutoExec
					sfAtuXmlOk("E1")
					MsgAlert("Erro ao ler xml "+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Else
					sfAtuXmlOk("E1")
				Endif
				ConOut("+"+Replicate("-",98)+"+")
				ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				ConOut("+"+Replicate("-",98)+"+")

				Return .F.
			Endif
		Endif


		oIdent     	:= oNF:_InfNfe:_IDE


		If Type("oIdent:_NFref") <> "U"
			oChv	:= oIdent:_NFref

			oChv  := IIf(ValType(oChv)=="O",{oChv},oChv)

			For nForA := 1 To Len(oChv)
				nP := nForA
				If Type("oChv[nP]:_refNFe") <> "U"
					Aadd(aChvNfes,oChv[nP]:_refNFe:TEXT)
					cMsgNfe += Chr(13)+Chr(10)+"Chave Nfe Origem:"+oChv[nP]:_refNFe:TEXT
				Endif
				oMsgNfe:Refresh()
			Next
		Endif
	Endif
	oMulti:aCols	:= {}

	// Adicionada uma verificação, que se estiver vazia a informação da chave eletronica, sem faz a consulta para montar os itens
	// 25/06/2013
	If Empty(aArqXml[oArqXml:nAt,nPosChvNfe])
				
		aAuxCols	:= {}
		Aadd(aAuxCols,Array(Len(oMulti:aHeader)+1))

		aAuxCols[Len(aAuxCols)][Len(oMulti:aHeader)+1]	:= .F.
		For nI := 1 To Len(oMulti:aHeader)
			If oMulti:aHeader[nI,8]	== "C"
				aAuxCols[Len(aAuxCols)][nI] :=	" "
			ElseIf oMulti:aHeader[nI,8]	== "D"
				aAuxCols[Len(aAuxCols)][nI] := CTOD("")
			ElseIf oMulti:aHeader[nI,8]	== "N"
				aAuxCols[Len(aAuxCols)][nI] :=	0
			ElseIf oMulti:aHeader[nI,8]	== "L"
				aAuxCols[Len(aAuxCols)][nI] :=	.F.
			Endif
			If oMulti:aHeader[nI,2] == "XIT_ITEM"
				aAuxCols[Len(aAuxCols)][nI] :=	StrZero(1,oMulti:aHeader[nI,4])
			Endif
		Next

		
		oMulti:aCols	:= aClone(aAuxCols)

		oMulti:oBrowse:Refresh()
		nTotalNFe 	:= 0
		nTotalXml	:= 0
		oTotalNfe:Refresh()
		oTotalXml:Refresh()
		SetFocus(nFocusLost)
		Return
	Endif
	// Seta valor padrão da variável conforme parâmetro original do sistema
	cTESNPED	:= cMvTesPcnf

	IncProc("Selecionando itens da nota.Aguarde!")
	
	//DbSelectArea("CONDORXMLITENS")
	cQryIt	:= "SELECT R_E_C_N_O_ XITRECNO,XIT_CHAVE,XIT_ITEM,XIT_CODNFE,D_E_L_E_T_ DELREC "
	cQryIt  += "  FROM CONDORXMLITENS "
	cQryIt  += " WHERE XIT_CHAVE = '"+cChvNfe+"'"
	cQryIt  += " ORDER BY XIT_ITEM"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryIt),"QRYXIT",.T.,.T.)
	
	While !Eof() //.And. CONDORXMLITENS->XIT_CHAVE == cChvNfe //Padr(aArqXml[oArqXml:nAt,nPosChvNfe],Len(CONDORXMLITENS->XIT_CHAVE))

		Set Dele Off
		U_DbSelArea("CONDORXMLITENS",.F.,2)
		// Efetua dbssek direto e o While ocorre enquanto houver registros de itens para a NFe
		//DbSeek(cChvNfe)// aArqXml[oArqXml:nAt,nPosChvNfe])
		DbGoto(QRYXIT->XITRECNO)
	
		IncProc("Processando item "+CONDORXMLITENS->XIT_ITEM)

		nRecXIT	:= CONDORXMLITENS->(Recno())	
		
		Set Dele On 
		
		cAuxLoc	:= sfRetLocPad(CONDORXMLITENS->XIT_CODPRD,cLocPad,CONDORXMLITENS->XIT_LOCAL)
		If !Empty(CONDORXMLITENS->XIT_PEDIDO)
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek(xFilial("SC7")+CONDORXMLITENS->XIT_PEDIDO+CONDORXMLITENS->XIT_ITEMPC)
			nC7PRECO	:= sfxMoeda()
		Else
			nC7PRECO	:= 0
		Endif
		Aadd(oMulti:aCols,Array(Len(oMulti:aHeader)+1))
		nNewLin := Len(oMulti:aCols)

		oMulti:aCols[nNewLin][1]	:= 	Iif(Empty(CONDORXMLITENS->XIT_PEDIDO),oVermelho,Iif(CONDORXMLITENS->XIT_PRUNIT <> nC7PRECO,oAmarelo,oVerde))
		oMulti:aCols[nNewLin][nPxItem]		:=	CONDORXMLITENS->XIT_ITEM      			// 2
		oMulti:aCols[nNewLin][nPxCodNfe]	:=	Alltrim(CONDORXMLITENS->XIT_CODNFE) 	// 3
		oMulti:aCols[nNewLin][nPxProd]		:=	Iif(lConvProd .And. Empty(CONDORXML->XML_KEYF1) .And. Empty(CONDORXMLITENS->XIT_CODPRD),stValidSA5(CONDORXMLITENS->XIT_CODNFE,cCodForn,cLojForn,CONDORXMLITENS->XIT_DESCRI,IIf(CONDORXML->XML_TIPODC$"N#C#I#P#T#F#S",Nil,CONDORXMLITENS->XIT_CODPRD),CONDORXMLITENS->XIT_UMNFE,CONDORXML->XML_TIPODC,CONDORXMLITENS->XIT_NCM,CONDORXMLITENS->XIT_QTENFE,CONDORXMLITENS->XIT_PRCNFE,Iif(nPxCodBar > 0 ,CONDORXMLITENS->XIT_CODBAR,""),CONDORXMLITENS->XIT_PIPI),CONDORXMLITENS->XIT_CODPRD)	// 4 Código Produto no Protheus
		oMulti:aCols[nNewLin][nPxDescri]	:=	CONDORXMLITENS->XIT_DESCRI				// 5  Descrição Produto no Xml
		oMulti:aCols[nNewLin][nPxQteNfe]	:=	CONDORXMLITENS->XIT_QTENFE				// 6  Quantidade no Xml
		oMulti:aCols[nNewLin][nPxUMNFe]		:=	CONDORXMLITENS->XIT_UMNFE				// 7  Unidade Medida no Xml
		oMulti:aCols[nNewLin][nPxPrcNfe]	:=	CONDORXMLITENS->XIT_PRCNFE				// 8  Preço Unitário
		oMulti:aCols[nNewLin][nPxTotNfe]	:=	CONDORXMLITENS->XIT_TOTNFE				// 9  Valor Total do Item Xml
		oMulti:aCols[nNewLin][nPxQte]		:=	CONDORXMLITENS->XIT_QTE					// 10  Quantidade
		oMulti:aCols[nNewLin][nPxUm]		:=	CONDORXMLITENS->XIT_UM					// 11 Unidade Medida
		oMulti:aCols[nNewLin][nPxPrunit]	:=	CONDORXMLITENS->XIT_PRUNIT				// 12 Preço Unitário
		oMulti:aCols[nNewLin][nPxTotal]		:=	CONDORXMLITENS->XIT_TOTAL				// 13 Valor Total do Item
		oMulti:aCols[nNewLin][nPxD1Oper]	:=	Iif(Empty(CONDORXMLITENS->XIT_OPER),sfRetOper(CONDORXMLITENS->XIT_CFNFE),CONDORXMLITENS->XIT_OPER)		// 14 Tipo de Operação
		oMulti:aCols[nNewLin][nPxD1Tes]		:=	CONDORXMLITENS->XIT_TES					// 15 Código do TES
		oMulti:aCols[nNewLin][nPxCFNFe]		:=	CONDORXMLITENS->XIT_CFNFE				// 16 Código do CFOP no Xml
		oMulti:aCols[nNewLin][nPxCF]		:=	CONDORXMLITENS->XIT_CF					// 17 Código do CFOP
		oMulti:aCols[nNewLin][nPxNCM]		:=	CONDORXMLITENS->XIT_NCM					// 18 Código do NCM
		oMulti:aCols[nNewLin][nPxPedido]	:=	CONDORXMLITENS->XIT_PEDIDO				// 19 Número Pedido Compra
		oMulti:aCols[nNewLin][nPxItemPc]	:=	CONDORXMLITENS->XIT_ITEMPC				// 20 Item pedido compra
		oMulti:aCols[nNewLin][nPxValDesc]	:=	CONDORXMLITENS->XIT_VALDES				// 21 Valor do Desconto
		oMulti:aCols[nNewLin][nPxBasIcm]	:=	CONDORXMLITENS->XIT_BASICM				// 22 Base Calculo Icms
		oMulti:aCols[nNewLin][nPxPicm]		:=	CONDORXMLITENS->XIT_PICM  			 	// 23 Percentual Icms
		oMulti:aCols[nNewLin][nPxValIcm]	:=	CONDORXMLITENS->XIT_VALICM				// 24 Valor do Icms
		oMulti:aCols[nNewLin][nPxPIcmSN]	:=	CONDORXMLITENS->XIT_PICMSN				// 25 % Crédito do Icms Simples Nacional
		oMulti:aCols[nNewLin][nPxCrdIcmSN]	:=	CONDORXMLITENS->XIT_CICMSN				// 26  Credito Icms Simples Nacional
		oMulti:aCols[nNewLin][nPxBasIpi]	:=	CONDORXMLITENS->XIT_BASIPI				// 27 Base Calculo IPI
		oMulti:aCols[nNewLin][nPxPIpi]		:=	CONDORXMLITENS->XIT_PIPI 				// 28 Percentual IPI
		oMulti:aCols[nNewLin][nPxValIpi]	:=	CONDORXMLITENS->XIT_VALIPI				// 29 Valor do IPI
		oMulti:aCols[nNewLin][nPxBasPis]	:=	CONDORXMLITENS->XIT_BASPIS				// 30 Base Calculo PIS
		oMulti:aCols[nNewLin][nPxPPis]		:=	CONDORXMLITENS->XIT_PPIS				// 31 Percentual PIS
		oMulti:aCols[nNewLin][nPxValPis]	:=	CONDORXMLITENS->XIT_VALPIS				// 32 Valor do PIS
		oMulti:aCols[nNewLin][nPxBasCof]	:=	CONDORXMLITENS->XIT_BASCOF				// 33 Base Calculo Cofins
		oMulti:aCols[nNewLin][nPxPCof]		:=	CONDORXMLITENS->XIT_PCOF 				// 34 Percentual Cofins
		oMulti:aCols[nNewLin][nPxValCof]	:=	CONDORXMLITENS->XIT_VALCOF				// 35 Valor do Cofins
		oMulti:aCols[nNewLin][nPxBasRet]	:=	CONDORXMLITENS->XIT_BASRET				// 36 Base Calculo Icms Retido
		oMulti:aCols[nNewLin][nPxPICMSST]	:=	CONDORXMLITENS->XIT_PICMST  			// 37 Percentual Icms Retido
		oMulti:aCols[nNewLin][nPxMVA]		:=	CONDORXMLITENS->XIT_PMVA				// 38 Percentual MVA
		oMulti:aCols[nNewLin][nPxIcmRet]	:=	CONDORXMLITENS->XIT_VALRET				// 39 Valor do Icms Retido
		oMulti:aCols[nNewLin][nPxCST]		:=	CONDORXMLITENS->XIT_CLASFI			   	// 40 Classificação fiscal
		oMulti:aCols[nNewLin][nPxNfOri]		:=	CriaVar(oMulti:aHeader[nPxNfOri][2],.T.)	// 41 Nf Origem
		oMulti:aCols[nNewLin][nPxSerOri]	:=	CriaVar(oMulti:aHeader[nPxSerOri][2],.T.)// 42 Serie Origem
		oMulti:aCols[nNewLin][nPxItemOri]	:=	CriaVar(oMulti:aHeader[nPxItemOri][2],.T.)// 43 Item Origem
		oMulti:aCols[nNewLin][nPxLocal]		:=	cAuxLoc									// 44 Armazém
		oMulti:aCols[nNewLin][nPxVlDesc]	:=	CONDORXMLITENS->XIT_VALDES				// 45 Valor do Desconto
		oMulti:aCols[nNewLin][nPxDesc]		:=	0										// 46 Perc.Desconto
		oMulti:aCols[nNewLin][nPxIdentB6]	:=	""										// 47 Identificação SB6 Retorno
		oMulti:aCols[nNewLin][nPxDiBc]		:=	CONDORXMLITENS->XIT_DIBCIM				// 48 Base Imposto Importacao
		oMulti:aCols[nNewLin][nPxDiAlq]		:=	Round(CONDORXMLITENS->XIT_DIVLII/CONDORXMLITENS->XIT_DIBCIM * 100,2)	// 49 Percentual Aliquota importacao
		oMulti:aCols[nNewLin][nPxDiVii]		:=	CONDORXMLITENS->XIT_DIVLII				// 50 Valor Imposto Importacao
		oMulti:aCols[nNewLin][nPxLoteCtl]	:=	CONDORXMLITENS->XIT_LOTCTL				// 51 Lote do produto
		oMulti:aCols[nNewLin][nPxNumLote]	:=	CONDORXMLITENS->XIT_NUMLOT				// 52 Sub Lote
		oMulti:aCols[nNewLin][nPxLoteFor]	:=	CONDORXMLITENS->XIT_LOTFOR			 	// 53 Lote Fornecedor
		oMulti:aCols[nNewLin][nPxDtFabric]	:=	CONDORXMLITENS->XIT_DFABRI			 	// 54 Data de Fabricação
		oMulti:aCols[nNewLin][nPxVldLtFor]	:=	CONDORXMLITENS->XIT_DTVALD			 	// 55 Data de Validade
		If nPxFciCod > 0
			oMulti:aCols[nNewLin][nPxFciCod]	:=	Iif(nPxFciCod > 0 ,CONDORXMLITENS->XIT_FCICOD,"")	// 56 Codigo FCI
		Endif
		oMulti:aCols[nNewLin][nPxXITCST]	:=	Iif(Empty(CONDORXMLITENS->XIT_CSTORI),CONDORXMLITENS->XIT_CLASFI,CONDORXMLITENS->XIT_CSTORI)	// 57 Classificação Fiscal
		oMulti:aCols[nNewLin][nPxKeySD1]	:=	Iif(Empty(CONDORXML->XML_KEYF1)," ",CONDORXMLITENS->XIT_KEYSD1)	//	58 Chave SD1
		If nPxCodBar > 0
			oMulti:aCols[nNewLin][nPxCodBar]	:=	CONDORXMLITENS->XIT_CODBAR			// 59 Codigo Barras
		Endif
		oMulti:aCols[nNewLin][nPxValFre]	:=	CONDORXMLITENS->XIT_VALFRE				// 60 Valor Frete
		oMulti:aCols[nNewLin][nPxValDesp]	:=	CONDORXMLITENS->XIT_DESPES				// 61 Valor Outros
		oMulti:aCols[nNewLin][nPxValSeg]	:=	CONDORXMLITENS->XIT_SEGURO				// 62 Valor Seguro
		If nPxCodCest > 0
			oMulti:aCols[nNewLin][nPxCodCest]	:=	CONDORXMLITENS->XIT_CEST			// 63 Código CEST
		Endif	
		If nPxBRetAnt > 0
			oMulti:aCols[nNewLin][nPxBRetAnt]	:=	CONDORXMLITENS->XIT_BRETAN			// 64 Base St Retido anteriormente
		Endif	
		If nPxVRetAnt > 0
			oMulti:aCols[nNewLin][nPxVRetAnt]	:=	CONDORXMLITENS->XIT_VRETAN			// 65 Valor St Retido Anteriomente
		Endif	

		oMulti:aCols[nNewLin][Len(oMulti:aHeader)+1]	:=	QRYXIT->DELREC == "*" //.F.

		// Garante que a chave de cada item será zerada se a nota ainda não constar como lançada no sistema
		If  Empty(CONDORXML->XML_KEYF1) .And. !Empty(CONDORXMLITENS->XIT_KEYSD1)
			DbSelectArea("CONDORXMLITENS")
			RecLock("CONDORXMLITENS",.F.)
			CONDORXMLITENS->XIT_KEYSD1	:= " "
			MsUnlock()
		Endif


		// 10/11/2016 - Criado ponto XMLCTE13 para atender situação em que é necessário customizar a situação que não precisa de Pedido de compra conforme o TES  
		If ExistBlock("XMLCTE13")			
			cRetNewTes	:= ExecBlock("XMLCTE13",.F.,.F.,)
			If ValType(cRetNewTes) == "C"
				If !(cRetNewTes $ cTESNPED)
					cTESNPED	+= cRetNewTes
				Endif
			Endif
			//MsgAlert(cTESNPED,cRetNewTes)
		Endif

		If oMulti:aCols[nNewLin][Len(oMulti:aHeader)+1]
		// Se a nota for da empresa em uso, já valido o pedido de compra por item automatico
		ElseIf lConvProd .And. Empty(CONDORXMLITENS->XIT_PEDIDO) .And. Empty(CONDORXML->XML_KEYF1)
			If nAlertPrc == 1
				If 	CONDORXML->XML_TIPODC == "N" .And.;
				lMVXPCNFE .And.;
				!Alltrim(CONDORXMLITENS->XIT_CFNFE) $ cCFOPNPED .And.;
				(IIf(!Empty(CONDORXMLITENS->XIT_CF),!Alltrim(CONDORXMLITENS->XIT_CF) $ cCFOPNPED,.T.)) .And.;
				(IIf(!Empty(CONDORXMLITENS->XIT_TES),!Alltrim(CONDORXMLITENS->XIT_TES) $ cTESNPED,.T.))
					nAlertPrc	:= 2

				ElseIf CONDORXML->XML_TIPODC $ "B#D"
					If !MsgNoYes("Exibir a amarração com Nota Original se existir?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!! ")
						nAlertPrc := 3
					Else
						nAlertPrc := 2
					Endif
				Else
					nAlertPrc := 3
				Endif
			Endif
			U_VldItemPc(nNewLin,.T.)
		ElseIf lConvProd .And. !Empty(CONDORXMLITENS->XIT_PEDIDO) .And. Empty(CONDORXML->XML_KEYF1) .And. CONDORXML->XML_TIPODC == "N"
			U_VldItemPc(Len(oMulti:aCols),.T.,CONDORXMLITENS->XIT_PEDIDO,CONDORXMLITENS->XIT_ITEMPC ,          ,          ,Empty(CONDORXMLITENS->XIT_CODPRD))
			//VldItemPc(nLinha,           lAutoSC7,cNumC7,               cItemC7                    ,lConfFinal,lConManual,lxPed)
		Else
			sfRefLeg(Len(oMulti:aCols))
		Endif


		//DbSelectArea("CONDORXMLITENS")
		//DbGoto(nRecXIT) // Reposiciona o registro para evitar erros
		DbSelectArea("QRYXIT") 
		DbSkip()
	Enddo
	QRYXIT->(DbCloseArea())
	
	nAlertPrc	:= 1
	oMulti:oBrowse:Refresh()

	nTotalNFe 	:= 0
	nTotalXml	:= 0
	For iR := 1 To Len(oMulti:aCols)
		If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]

			// Se for o automatico, não tiver sido lançada a nota ainda e for tipo normal
			If lAutoExec .And. Empty(CONDORXML->XML_KEYF1) .And. CONDORXML->XML_TIPODC == "N"
				//U_VldItemPc(iR,.T.,oMulti:aCols[iR,nPxPedido],oMulti:aCols[iR,nPxItemPC])
			Endif
			nTotalNfe += Round(oMulti:aCols[iR,nPxTotal] +  Iif(!Empty(Alltrim(oMulti:aCols[iR,nPxIdentB6])) .Or. !Empty(Alltrim(oMulti:aCols[iR,nPxNfOri])),oMulti:aCols[iR,nPxValDesp],0) - oMulti:aCols[iR,nPxVlDesc] ,2)
			nTotalXml += Round(oMulti:aCols[iR,nPxTotNfe] - oMulti:aCols[iR,nPxValDesc],2)
		Endif
	Next

	If aArqXml[oArqXml:nAt,nPosTpNota]$"T#F"

		//cMsgNfe 	:= Iif(Type("oComple:_xObs:TEXT")<>"U",oComple:_xObs:TEXT,"")
		nPxVlr1	:= At("<xObs>",CONDORXML->XML_ARQ)
		nPxVlr2 := At("</xObs>",CONDORXML->XML_ARQ)
		If nPxVlr1 > 0
			cMsgNfe := Substr(CONDORXML->XML_ARQ,nPxVlr1+6,nPxVlr2-nPxVlr1-7)
		Endif
		nTotalXml	:= aArqXml[oArqXml:nAt,nPosVlrCte] 
		oMsgNfe:Refresh()

	Endif

	oTotalNfe:Refresh()
	oTotalXml:Refresh()

	U_DbSelArea("CONDORXMLITENS",.F.,2)
	Set Filter to
	SetFocus(nFocusLost)
Return



/*/{Protheus.doc} stLinOk
(Valida a linha do Getdados  )

@author MarceloLauschner
@since 20/02/2012
@version 1.0
@return logico
@example
(examples)

@see (links_or_references)
/*/
Static Function stLinOk(nInLinAtu)

	Local	iW
	Local	iR
	Local	lVdlNcm		:= GetNewPar("XM_VLDNCM",.T.)
	Default	nInLinAtu	:= oMulti:nAt

	// Se a posição da linha que perdeu o foco é menor que o array aCols, retorna falso na validação do change line
	If oMulti:nAt > Len(oMulti:aCols)
		oMulti:nAt := Len(oMulti:aCols)
		Return .T.	
	Endif
	
	If oMulti:aCols[nInLinAtu,Len(oMulti:aHeader)+1]
		Return .T. 
	Endif
	
	If Empty(oMulti:aCols[nInLinAtu,nPxItem]) 
		Return .F.
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+oMulti:aCols[nInLinAtu,nPxProd]) .And. !Empty(oMulti:aCols[nInLinAtu,nPxProd])

		If lVdlNcm .And. !Empty(oMulti:aCols[nInLinAtu,nPxNCM])
			// Efetua a atualização do NCM do produto
			If Empty(SB1->B1_POSIPI) .and. !Empty(oMulti:aCols[nInLinAtu,nPxNCM]) .and. oMulti:aCols[nInLinAtu,nPxNCM] != '00000000'
				RecLock("SB1",.F.)
				Replace B1_POSIPI with oMulti:aCols[nInLinAtu,nPxNCM]
				MSUnLock()
			Endif

			// Efetuo validação que envia email ao Departamento Fiscal informando sobre diferença no cadastro do NCM do Produto
			If  Alltrim(SB1->B1_POSIPI) <> "00000000" .And. Alltrim(SB1->B1_POSIPI) <> Alltrim( oMulti:aCols[nInLinAtu,nPxNCM] ) 

				//cRecebe		:= Alltrim(GetMv("XM_MAILXML"))	// Destinatarios de email do lançamento da nota
				// Mudança de destinatários criado em 26/07/2013
				// Todas as pessoas com perfil de escrita fiscal irão receber o aviso de divergencia de NCM.
				cRecebe	:= ""
				cRecebe	:= StrTran(Iif(File("xmusrxmln_"+cEmpAnt+".usr"),MemoRead("xmusrxmln_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLN","")),"/","#")	// Muda pra #
				cRecebe	:= StrTran(cRecebe,";","#")
				cRecebe	:= StrTran(cRecebe,"|","#")
				cRecebe	:= StrTran(cRecebe," ","#")
				cRecebe	:= StrTran(cRecebe,"-","#")
				cRecebe	:= StrTran(cRecebe,"\","#")
				aOutMails	:= StrTokArr(cRecebe,"#")
				cRecebe	:= ""
				For iW := 1 To Len(aOutMails)
					If iW > 1
						cRecebe += ";"
					Endif
					cRecebe	+= Alltrim(UsrRetMail(aOutMails[iW]))
				Next
				// Regra para enviar ao cliente notificação sobre diferença no cadastro do NCM em relação ao sistema da Empresa

				cAssunto 	:= "Divergência NCM do Produto '"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC)+" na Empresa:" + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM)
				cMensagem	:= "Produto  :"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC) + CRLF
				cMensagem	+= "Empresa  :" + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM) + CRLF
				cMensagem	+= "NCM Atual:"+Alltrim(SB1->B1_POSIPI) + CRLF
				cMensagem	+= "NCM XML  :"+oMulti:aCols[nInLinAtu,nPxNCM] + CRLF
				cMensagem	+= "NF-e Nº  :"+Alltrim(aArqXml[oArqXml:nAt,2]) + CRLF

				If aArqXml[oArqXml:nAt,nPosTpNota]=="D"

					U_DbSelArea("CONDORXML",.F.,1)
					If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
						MsgAlert("Erro ao localizar registro")
						Return
					Endif
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
					If SA1->(FieldPos(GetNewPar("XM_CA1MAIL",""))) > 0
						If !Empty(&("SA1->"+GetNewPar("XM_CA1MAIL","")))
							cRecebe	+= ";"+&("SA1->"+GetNewPar("XM_CA1MAIL",""))
						Endif
					ElseIf !Empty(SA1->A1_EMAIL)
						cRecebe += ";"+SA1->A1_EMAIL
					Endif
					cMensagem	+= "Devolução do Cliente :"+SA1->A1_COD+"/"+SA1->A1_LOJA+" "+Capital(SA1->A1_NOME) + CRLF
				Endif





				U_DbSelArea("CONDORXML",.F.,1)
				DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
				// Bloqueio de NCM em notas normais somente o fornecedor permitir
				If aArqXml[oArqXml:nAt,nPosTpNota] == "N"
					DbSelectArea("SA2")
					DbSetOrder(1)
					If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
						// Criar campo A2_BLQNCM - Caracter Tamanho 1 - Bloq.NFe p/NCM Divergente  1=Sim;2=Não
						If SA2->(FieldPos("A2_BLQNCM")) > 0
							// Se o fornecedor estiver diferente de 2=Não irá validar, mas aceitando tolerância de 4 digitos iniciais iguais
							If SA2->A2_BLQNCM $ "1# "
								If Alltrim( Substr(SB1->B1_POSIPI,1,4 ) ) <> Alltrim(Substr(oMulti:aCols[nInLinAtu,nPxNCM],1,4 ) )
									sfAtuXmlOk("NC",.T.,oMulti:aCols[nInLinAtu,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nInLinAtu,nPxNCM])
									//sfAtuXmlOk(/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,/*cInCpoAlt*/,/*cInVlAnt*/,/*cInVlNew*/)
								ElseIf Alltrim( Substr(SB1->B1_POSIPI,1,6 ) ) <> Alltrim(Substr(oMulti:aCols[nInLinAtu,nPxNCM],1,6 ) )
									sfAtuXmlOk("NC",.T.,oMulti:aCols[nInLinAtu,nPxItem],cMensagem,,,.F.,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nInLinAtu,nPxNCM])
									//cOkMot,lAtuItens,cItem,cMsgAux,nLinXml,cInChave,lAtuOk
									//stSendMail( cRecebe, cAssunto, cMensagem )
								Endif
							Endif
						Else
							sfAtuXmlOk("NC",.T.,oMulti:aCols[nInLinAtu,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nInLinAtu,nPxNCM])
							//stSendMail( cRecebe, cAssunto, cMensagem )
						Endif
						cMensagem	+= "Fornecedor :"+SA2->A2_COD+"/"+SA2->A2_LOJA+" "+Capital(SA2->A2_NOME) + CRLF
					Endif
				Else
					sfAtuXmlOk("NC",.T.,oMulti:aCols[nInLinAtu,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nInLinAtu,nPxNCM])
					//stSendMail( cRecebe, cAssunto, cMensagem )
				Endif
				// Atribuo o valor do NCM do cadastro do Produto ao conteudo para evitar que a mensagem seja enviada varias vezes
				oMulti:aCols[nInLinAtu,nPxNCM]  := Alltrim(SB1->B1_POSIPI)
				cMensagem	+= "Validação de stLinOk"
			Endif
		Endif
	Endif


	nTotalNFe 	:= 0
	nTotalXml	:= 0
	For iR := 1 To Len(oMulti:aCols)
		If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]
			//nTotalNfe += Round(oMulti:aCols[iR,nPxTotal] - oMulti:aCols[iR,nPxVlDesc] + oMulti:aCols[iR,nPxValDesp] ,2)
			nTotalNfe += Round(oMulti:aCols[iR,nPxTotal] +  Iif(!Empty(Alltrim(oMulti:aCols[iR,nPxIdentB6])) .Or. (!Empty(Alltrim(oMulti:aCols[iR,nPxNfOri])) .And. aArqXml[oArqXml:nAt,nPosTpNota] == "B"),oMulti:aCols[iR,nPxValDesp],0) - oMulti:aCols[iR,nPxVlDesc] ,2)
			nTotalXml += Round(oMulti:aCols[iR,nPxTotNfe] -  oMulti:aCols[iR,nPxValDesc],2)
		Endif
	Next
	oTotalNfe:Refresh()
	oTotalXml:Refresh()


Return .T.

/*/{Protheus.doc} VldSA5
(Efetua a conversão Produto X Fornecedor)
@author MarceloLauschner
@since 20/02/2012
@version 1.0
@param cCodProd, character, (Descrição do parâmetro)
@param cInCodForn, character, (Descrição do parâmetro)
@param cInLojForn, character, (Descrição do parâmetro)
@param cInDescForn, character, (Descrição do parâmetro)
@return logico, se validou ou não
@example
(examples)
@see (links_or_references)
/*/
User Function VldSA5(cCodProd,cInCodForn,cInLojForn,cInDescForn)
	Local	lRet	:= .F.
	Local	cRetA5	:= ""

	// Evita que abra a tela de validação de Produto X Fornecedor quando não houver item digitado
	If Empty(oMulti:aCols[oMulti:nAt,nPxItem])
		Return .F.
	Endif
	If oMulti:aCols[oMulti:nAt,Len(oMulti:aHeader)+1]
		Return .T. 
	Endif
	
	// Alteração na rotina para contemplar parametro que permite que produtos diferentes da nota possam ser lançados no mesmo codigo protheus
	If !Empty(M->D1_COD) .And. GetNewPar("XM_RPTPPRO",.F.)
		cRetA5	:= M->D1_COD
	Else
		cRetA5	:= stValidSA5(cCodProd,cInCodForn,cInLojForn,cInDescForn,M->D1_COD,oMulti:aCols[oMulti:nAt,nPxUMNFe],aArqXml[oArqXml:nAt,nPosTpNota],oMulti:aCols[oMulti:nAt,nPxNcm],oMulti:aCols[oMulti:nAt,nPxQteNfe],oMulti:aCols[oMulti:nAt,nPxPrcNfe],Iif(nPxCodBar > 0 ,oMulti:aCols[oMulti:nAt,nPxCodBar],""),oMulti:aCols[oMulti:nAt][nPxPIpi])
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cRetA5 )
		M->D1_COD	:= SB1->B1_COD
		oMulti:aCols[oMulti:nAt,nPxProd]	:= SB1->B1_COD
		// Efetua a chamada direta amarrando ao pedido de compra e demais preenchimentos do produto
		U_VldItemPc()
		lRet := .T.
	Endif

	// Adicionado retorno verdadeiro se o código do produto não foi preenchido 
	If Empty(M->D1_COD) .And. GetNewPar("XM_RPTPPRO",.F.)
		lRet := .T.
	Endif

Return lRet

/*/{Protheus.doc} VlsSF4
(Preenchimento do Campo CF baseado no TES informado)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@param cInCodTes, character, (Descrição do parâmetro)
@param nInLinha, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function VlsSF4(cInCodTes,nInLinha)
	Default	nInLinha	:= oMulti:nAt
	Default	cInCodTes	:= Iif(ReadVar() == "M->D1_TES",M->D1_TES,oMulti:aCols[nInLinha,nPxD1Tes])

	If aArqXml[oArqXml:nAt,nPosTpNota]	$ "B#D"
		cRetCF	:= "1"
		If !Empty(CONDORXML->XML_CODLOJ)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
		Else
			DbSelectArea("SA1")
			DbSetOrder(3)
			DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
		Endif

		If SA1->A1_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Else
		cRetCF	:= "1"
		If Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
			cRetCF	:= "3"
		Else
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			Else
				DbSelectArea("SA2")
				DbSetOrder(3)
				DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
			Endif

			If SA2->A2_EST == SuperGetMv("MV_ESTADO")
				cRetCF := "1"
			Else
				cRetCF := "2"
			EndIf
		Endif
	Endif

	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4")+cInCodTes)
		oMulti:aCols[nInLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
	Endif

Return .T.



/*/{Protheus.doc} stValidSA5
(Valida os dados de Produto X Fornecedor/Cliente)
@author MarceloLauschner
@since 20/02/2012
@version 1.0
@param cCodProd, character, (Descrição do parâmetro)
@param cInCodForn, character, (Descrição do parâmetro)
@param cInLojForn, character, (Descrição do parâmetro)
@param cInDescForn, character, (Descrição do parâmetro)
@param cRefProtheus, character, (Descrição do parâmetro)
@param cInUnidForn, character, (Descrição do parâmetro)
@param cTipoDoc, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function stValidSA5(cCodProd,cInCodForn,cInLojForn,cInDescForn,cRefProtheus,cInUnidForn,cTipoDoc,cInNcm,nQteXml,nPrcXml,cInCodBar,nInPIPI)

	
	Local		lPergAtu		:= .T.
	Local		lAtuSA5			:= .F.
	Local		lAtuSA7			:= .F.
	Local		cTpConv			:= "D"
	Local		nQteConv		:= 0
	Local		aAreaOld		:= GetArea()
	Local		lB1Msblql		:= .F.
	Local		lB1CodPrf		:= .F.
	Local		lMT103PBLQ		:= .F. 
	Local		xZ
	Local		i7
	Local		lExistA5Prod	:= .F.
	Local		cQry			:= ""
	Local		cQryAux			:= ""
	Local		nRecSA5			:= 0	
	Local   	lExistPe18		:= ExistBlock("XMLCTE18")
	Local		aPrdBlq			:= {}
	Default 	cRefProtheus	:= Padr(" ",TamSX3("B1_COD")[1])
	Default		cTipoDoc		:= "N"
	Default		cInNcm			:= ""
	Default		nQteXml			:= 0
	Default		nPrcXml			:= 0
	Default 	cInCodBar		:= ""
	Default		nInPIPI			:= 0
	Private		cUnidForn		:= cInUnidForn
	Private		cVar			:= Padr(" ",TamSX3("B1_COD")[1])

	lB1Msblql	:= 	SB1->(FieldPos('B1_MSBLQL')) > 0
	lB1CodPrf	:=  SB1->(FieldPos('B1_CODPRF')) > 0
	
	// 09/05/2018 - Melhoria a pedido da Salonline para permitir validar produtos Bloqueados
	If ExistBlock("MT103PBLQ")  
		Aadd(aPrdBlq,cCodProd)
		lMT103PBLQ:=ExecBlock("MT103PBLQ",.F.,.F.,{aPrdBlq})
		If ValType(lMT103PBLQ) == 'L'
			lB1Msblql	:=lMT103PBLQ
		EndIf		
	Endif
		
	// Devolução de venda e Beneficiamento não contemplado no automático
	If cTipoDoc $ "D#B" .And. lAutoExec
		sfAtuXmlOk("DV")
		Return ""
	Endif

	If cTipoDoc $ "N#C#P#I#S"
		
		If Len(Alltrim(cCodProd)) >  TamSX3("A5_CODPRF")[1]
			MsgAlert("O tamanho do código do produto do fornecedor é maior que o limite do campo 'A5_CODPRF'.O valor do XML '"+cCodProd+"' será alterado para '"+Padr(cCodProd,TamSX3("A5_CODPRF")[1])+"'.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
			cCodProd	:= Padr(cCodProd,TamSX3("A5_CODPRF")[1])
		Endif
		
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		Endif
		DbSelectArea("SB1")
		DbSetOrder(1)

		cQry := "SELECT A5_CODPRF,A5_PRODUTO,A5_NOMPROD,B1_DESC "
		cQry += "  FROM " + RetSqlName("SA5") + " A5," + RetSqlName("SB1") + " B1 "
		cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
		If lB1Msblql
			cQry += "   AND B1_MSBLQL <> '1' "
		Endif
		cQry += "   AND B1_COD = A5_PRODUTO "
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry += "   AND A5.D_E_L_E_T_ =' ' "
		cQry += "   AND A5_FORNECE = '"+ cInCodForn+ "' "
		cQry += "   AND A5_LOJA = '"+cInLojForn+"' "
		cQry += "   AND A5_CODPRF ='" + Alltrim(cCodProd) + "' "
		cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "

		// Ponto de entrada criado em 07/09/2016 para permitir que o cliente customize a query para retornar o código de produto 
		If ExistBlock("XMLCTE11")
			cQryAux := ExecBlock("XMLCTE11",.F.,.F.,{cQry,cInCodForn,cInLojForn,cCodProd})
			If ValType(cQryAux) == "C"
				TCQUERY cQryAux NEW ALIAS "QRY"

				Count to nCountA5
				// Se o retorno do PE for de 1 linha, assume o valor do campo A5_PRODUTO que obrigatoriamente precisa estar no select do PE
				If nCountA5 == 1
					DbSelectArea("QRY")
					DbGotop()
					cVar := QRY->A5_PRODUTO
					cRefProtheus	:= cVar
					QRY->(DbCloseArea())
					Return cVar
				Endif
				QRY->(DbCloseArea())
			Endif
			cQryAux := ""		

		Endif

		TCQUERY cQry NEW ALIAS "QRY"

		Count to nCountA5

		If nCountA5 > 0                    // Abre 05

			If nCountA5 > 1

				DbSelectArea("QRY")
				DbGotop()
				While !Eof()
					If Alltrim(Upper(QRY->A5_NOMPROD)) == Alltrim(Upper(cInDescForn))
						lExistA5Prod	:= .T.
						Exit
					Endif
					DbSelectArea("QRY")
					DbSkip()
				Enddo

				aStrDesc	:= StrTokArr(cInDescForn," ")
				// Mudança na forma de buscar a descrição do produto - 17/07/2014
				// Caso exista a descrição exata, monta o sql somente com a descrição exata
				If lExistA5Prod .And. Len(aStrDesc) > 0
					cQryAux += "   AND A5_NOMPROD = '" + Alltrim(Upper(StrTran(cInDescForn,"'","''")))+"' "
				Else
					For xZ := 1 To Len(aStrDesc)
						If xZ == 1
							cQryAux += " AND ("
						Else
							cQryAux += "   OR "
						Endif
						cQryAux += "  A5_NOMPROD LIKE '%"+StrTran(aStrDesc[xZ],"'","''")+"%' "
						If xZ == Len(aStrDesc)
							//	cQry += " OR A5_NOMPROD LIKE '%"+Alltrim(StrTran(Upper(cInDescForn),"'","''"))+"%' "
							cQryAux += " )"
						Endif
					Next
				Endif
				// Se encontrar o caractere
				If At("#",CONDORXML->XML_BODY) > 0
					cListSC7	:= CONDORXML->XML_BODY+"#"
					aListSC7	:= StrTokArr(cListSC7,"#")
					lAddSC7		:= .F.
					cQryAux += "   AND B1_COD IN(SELECT C7_PRODUTO "
					cQryAux += "                   FROM "+RetSqlName("SC7") + " C7 "
					cQryAux += "                  WHERE C7.D_E_L_E_T_ = ' ' "
					cQryAux += "                    AND C7_FILIAL = '"+xFilial("SC7")+"' "
					For i7 := 1 To Len(aListSC7)
						If !Empty(aListSC7[i7])
							DbSelectArea("SC7")
							DbSetOrder(1)
							If DbSeek(xFilial("SC7")+Alltrim(aListSC7[i7]))
								If !lAddSC7
									cQryAux += "   AND C7_NUM IN('"+SC7->C7_NUM+"'"
								Else
									cQryAux += ",'"+SC7->C7_NUM+"'"
								Endif
								lAddSC7	:= .T.
							Endif
						Endif
					Next
					If lAddSC7
						cQryAux += ") "
					Else
						cQryAux += "   AND C7_FORNECE = '"+ cInCodForn+ "' "
						cQryAux += "   AND C7_LOJA = '"+cInLojForn+"' "
					Endif
					cQryAux += ")"
				Endif

				// Fecho a tabela aberta anteriormente para recriar ela agora com os novos filtros
				If Select("QRY") > 0
					QRY->(DbCloseArea())
				Endif

				TCQUERY (cQry+cQryAux) NEW ALIAS "QRY"

				Count to nCountA5

				// Se a consulta com os filtros adicionais retornar nenhum registro
				// Restaura consulta para a opção padrão com filtro somente do produto x fornecedor
				If nCountA5 == 0

					// Fecho a tabela aberta anteriormente para recriar ela agora com os novos filtros
					If Select("QRY") > 0
						QRY->(DbCloseArea())
					Endif

					TCQUERY cQry NEW ALIAS "QRY"

					Count to nCountA5
				Endif
			Endif

			If nCountA5 > 0
				aCampos := {}
				aTam:=TamSX3("A5_CODPRF")
				AADD(aCampos,{"CODPRF" ,"C",aTam[1],aTam[2]})
				aTam:=TamSX3("A5_PRODUTO")
				AADD(aCampos,{"PRODUTO" ,"C",aTam[1],aTam[2]})
				aTam:=TamSX3("A5_NOMPROD")
				AADD(aCampos,{"NOMPROD" ,"C",aTam[1],aTam[2]})
				aTam:=TamSX3("B1_DESC")
				AADD(aCampos,{"DESC" ,"C",aTam[1],aTam[2]})
				aTam:=TamSX3("A5_NOMPROD")
				AADD(aCampos,{"A5NOMPR" ,"C",aTam[1],aTam[2]})

				cArqTra  := CriaTrab(aCampos,.T.)
				dbUseArea(.T.,,cArqTra,"_SA5", .T. , .F. )
				DbSelectArea("QRY")
				DbGotop()
				While !Eof()
					DbSelectArea("_SA5")
					RecLock("_SA5",.T.)
					_SA5->CODPRF	:= QRY->A5_CODPRF
					_SA5->PRODUTO	:= QRY->A5_PRODUTO
					_SA5->NOMPROD	:= cInDescForn
					_SA5->DESC		:= QRY->B1_DESC	//Posicione("SB1",1,xFilial("SB1")+QRY->A5_PRODUTO,"B1_DESC")
					_SA5->A5NOMPR 	:= QRY->A5_NOMPROD
					MsUnlock()
					DbSelectArea("QRY")
					DbSkip()
				Enddo
				If Select("QRY") > 0
					QRY->(DbCloseArea())
				Endif

				aCpos := {}
				AADD(aCpos   , {"CODPRF" , "Cod.Fornecedor" })
				AADD(aCpos   , {"PRODUTO", "Referência Protheus" })
				AADD(aCpos   , {"NOMPROD", "Descrição XML" })
				AADD(aCpos   , {"DESC"   , "Descrição Cad.SB1" })
				AADD(aCpos   , {"A5NOMPR", "Descrição Cad.SA5" })

				If nCountA5 > 1
					If !lAutoExec
						DEFINE MSDIALOG oDlg Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Produtos X Fornecedor") FROM 001,001 TO 380,810 PIXEL
						// Ajustar casas decimais conforme SC7  				
						@ 05  ,4   SAY OemToAnsi("Cód/UM/Descrição") Of oDlg PIXEL SIZE 50 ,9 //"Produto"
						@ 04  ,60  MSGET cCodProd PICTURE PesqPict('SA5','A5_CODPRF') When .F. Of oDlg PIXEL SIZE 60,9
						@ 04  ,125 MSGET cInUnidForn When .F. Of oDlg PIXEL SIZE 40,9
						@ 04  ,170 MSGET cInDescForn PICTURE PesqPict('SB1','B1_DESC') When .F. Of oDlg PIXEL SIZE 220,9
						@ 19  ,4   SAY OemToAnsi("Quant/Preço XML") Of oDlg PIXEL SIZE 47 ,9 //"Produto"
						@ 18  ,60  MSGET nQteXml PICTURE PesqPict('SD1','D1_QUANT') When .F. Of oDlg PIXEL SIZE 60,9
						@ 18  ,125 MSGET nPrcXml PICTURE PesqPict('SD1','D1_VUNIT') When .F. Of oDlg PIXEL SIZE 60,9

						DbSelectArea("_SA5")
						DbGoTop()
						iw_browse(30,10,150,395,"_SA5",,,aCpos)

						@ 165,020 BUTTON "Loc.Prod P.Compra" Size 70,10 Action (IIf(sfFindSC7(@cVar,cCodProd,cInCodForn,cInLojForn,cInDescForn,cInUnidForn,nQteXml,nPrcXml,_SA5->PRODUTO),oDlg:End(),Nil))	Pixel Of oDlg

						@ 165,100 BUTTON "&Confirma" Action(cVar := _SA5->PRODUTO,oDlg:End())	Pixel Of oDlg
						@ 165,180 Button "&Aborta" Action (oDlg:End())  Pixel Of oDlg

						Activate MsDialog oDlg Centered

						If cVar <> _SA5->PRODUTO
							U_DbSelArea("CONDORXML",.F.,1)
							DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
							sfAtuXmlOk("A5")
						Endif
					Else
						U_DbSelArea("CONDORXML",.F.,1)
						DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
						sfAtuXmlOk("A5")
						DbSelectArea("_SA5")
						DbCloseArea()
						FErase(cArqTra + GetDbExtension()) // Deleting file
						FErase(cArqTra+ OrdBagExt()) // Deleting index
						RestArea(aAreaOld)
						Return ""
					Endif
				Else
					cVar := _SA5->PRODUTO
				Endif

				DbSelectArea("_SA5")
				DbCloseArea()
				FErase(cArqTra + GetDbExtension()) // Deleting file
				FErase(cArqTra+ OrdBagExt()) // Deleting index
			Endif
		ElseIf lAutoExec
			If Select("QRY") > 0
				QRY->(DbCloseArea())
			Endif
			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
			sfAtuXmlOk("A5")
			RestArea(aAreaOld)
			Return ""
		Endif
		//MsgAlert(cVar,"cVar")
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		Endif


		cQry := "SELECT COALESCE(MAX(B1_COD), ' ')  B1_COD,COUNT(*) NVEZES "
		cQry += "  FROM " + RetSqlName("SB1")
		cQry += " WHERE D_E_L_E_T_ = ' '  "
		cQry += "   AND B1_PROC = '"+cInCodForn + "' "
		If lB1CodPrf
			cQry += "   AND (B1_FABRIC = '"+Alltrim(cCodProd)+ "' "
			cQry += "        OR B1_CODPRF = '"+Alltrim(cCodProd)+ "') "
		Else
			cQry += "   AND B1_FABRIC = '"+Alltrim(cCodProd)+ "' "
		Endif

		If lB1Msblql
			cQry += "   AND B1_MSBLQL <> '1' "
		Endif
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1") +"' "

		TCQUERY cQry NEW ALIAS "_SB1"		
		If !Eof()
			If _SB1->NVEZES > 1
				If !lAutoExec
					MsgInfo("Foram encontrados " + cValToChar(_SB1->NVEZES) + " produtos com a referência " + Alltrim(cCodProd) + ".",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Aviso!")
				Endif
			ElseIf _SB1->NVEZES == 1
				cRefProtheus	:= _SB1->B1_COD
				lPergAtu		:= ReadVar() == "M->D1_COD" 
			Endif
		Endif
		_SB1->(DbCloseArea())

		cQry := "SELECT A5_PRODUTO,A5_NOMPROD,R_E_C_N_O_ A5RECNO "
		cQry += "  FROM " + RetSqlName("SA5")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += "   AND A5_CODPRF = '"+cCodProd+"' "
		cQry += "   AND A5_PRODUTO != '  ' "
		cQry += "   AND A5_LOJA = '"+cInLojForn+"' "
		cQry += "   AND A5_FORNECE = '"+  cInCodForn  + "' "
		cQry += "   AND A5_PRODUTO ='" + Padr(cVar,TamSX3("A5_PRODUTO")[1])+ "' "
		cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "


		TCQUERY cQry NEW ALIAS "_SA5"

		//Count to nCountA5

		If EoF() //nCountA5 == 0
			lAtuSA5		:= .T.
		ElseIf !Empty(cRefProtheus)
			If  lPergAtu .And. !lAutoExec .And. lComprUsr 
				If MsgYesNo("Força atualização da Conversão de Produto X Fornecedor?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")
					lAtuSA5	:= .T.
					// 14/10/2014 - Mando posicionar no SA5 corretamente para retornar informações do produto x fornecedor corretamente
					nRecSA5	:= _SA5->A5RECNO
					DbSelectArea("SA5")
					DbGoto(nRecSA5)
					cRefProtheus := _SA5->A5_PRODUTO
				Endif
			Endif
		ElseIf GetNewPar("XM_SA5REFR",.T.) // Verifica se o cliente desativa a opção ou não
			// Força a atualização de informações 
			nRecSA5	:= _SA5->A5RECNO
			DbSelectArea("SA5")
			DbGoto(nRecSA5)
			// Força a abertura de tela cadastro de Produto X fornecedor para atualizar SA5 com dados oriundos do XML
			If SA5->(FieldPos("A5_XUNID")) > 0 .And. !Empty(cInUnidForn) .And. Alltrim(SA5->A5_XUNID) <>  Alltrim(cInUnidForn) 
				lAtuSA5	:= .T.
			Endif
			If SA5->(FieldPos("A5_DESREF")) > 0 .And. !Empty(cInDescForn) .And. Alltrim(SA5->A5_DESREF) <>  Alltrim(Padr(cInDescForn,Len(SA5->A5_DESREF)))
				lAtuSA5	:= .T. 
			Endif
			If SA5->(FieldPos("A5_XTPCONV")) > 0 .And. Empty(SA5->A5_XTPCONV)
				lAtuSA5	:= .T. 
			Endif
			If SA5->(FieldPos("A5_XCONV")) > 0 .And. Empty(SA5->A5_XCONV)
				lAtuSA5	:= .T.
			Endif
			If SA5->(FieldPos("A5_NCMPRF")) > 0 .And. !Empty(cInNcm) .And. Alltrim(SA5->A5_NCMPRF) <> Alltrim(cInNcm) 
				lAtuSA5	:= .T.
			Endif
			If SA5->(FieldPos("A5_CODBAR")) > 0 .And. !Empty(cInCodBar) .And. Alltrim(SA5->A5_CODBAR) <> Alltrim(cInCodBar)
				lAtuSA5	:= .T. 
			Endif
			cRefProtheus := _SA5->A5_PRODUTO
		Endif
		_SA5->(DbCloseArea())
		
		// 02/11/2017 - Permite customizar validação de acesso a rotina de Atualização do Produto X Fornecedor
		If lExistPE18
			lExistPE18	:= ExecBlock("XMLCTE18",.F.,.F.,{cInCodForn,cInLojForn,cCodProd,cInDescForn,cVar,lComprUsr,lSuperUsr})
			// Protege conteúdo para evitar erro Type Mistach
			If Type("lExistPE18") == "L"
				lAtuSA5 := lExistPE18
			Endif
		Endif
			
		If lAtuSA5 .And. !lAutoExec	.And. lComprUsr 
			If nRecSA5 > 0
				DbSelectArea("SA5")
				DbGoto(nRecSA5)
			Else
				DbSelectArea("SA5")
				DbSetOrder(2)
				DbSeek(xFilial("SA5")+cRefProtheus+cInCodForn+cInLojForn)
			Endif
			
			cCodAux		:= cCodProd
			lAtuA5 		:= .F.
			cVar		:= Padr(cRefProtheus,TamSX3("B1_COD")[1])

			DEFINE MSDIALOG oDlgA5 Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualizar Produto X Fornecedor") FROM 001,001 TO 240,450 PIXEL
			@ 010,010 Say ("Informe os códigos para conversão das Referências'") Pixel of oDlgA5
			@ 022,010 Say "'"+ cCodProd+"-"+cInDescForn+"'" Pixel Of oDlgA5
			@ 032,010 Say "Referência Fornecedor" Pixel of oDlgA5
			@ 032,080 MsGet oCodAux Var cCodAux Size 80,10 Picture "@!" Pixel Of oDlgA5
			// 23/02/2018 - Adiciona botão se existir o ponto de entrada para facilitar o cadastro de produtos
//TODO Adicionar passagem de IPI 
			If ExistBlock("XMLCTE12")		
				@ 032,170 BUTTON "Cad.Produto" Size 40,10 Action (ExecBlock("XMLCTE12",.F.,.F.,{cCodProd,cInDescForn,cInUnidForn,cInNcm,cInCodBar,nInPIPI}))	Pixel Of oDlgA5
			Endif
			
			@ 045,010 Say "Código Protheus" Pixel of oDlgA5
			// A consulta Padrão pode ser alterada conforme Parametro XM_F3SB1 
			@ 045,080 MsGet oCod Var cVar Valid ExistCpo("SB1",cVar,1) F3 GetNewPar("XM_F3SB1","SB1") Size 50,10 Picture "@!" Pixel Of oDlgA5
			@ 046,140 BUTTON "Loc.Prod P.Compra" Size 70,10 Action sfFindSC7(@cVar,cCodProd,cInCodForn,cInLojForn,cInDescForn,cInUnidForn,nQteXml,nPrcXml)	Pixel Of oDlgA5

			
			@ 057,010 Say "2ª Unidade/Med.Fornecedor" Pixel of oDlgA5
			@ 057,080 MsGet oUnidFor Var cUnidForn Valid ExistCpo("SAH",cUnidForn,1) F3 "SAH" Size 50,10 Picture "@!" Pixel Of oDlgA5

			If SA5->(FieldPos("A5_XTPCONV")) > 0
				@ 070,010 Say "Tipo de Conversão" Pixel of oDlgA5
				cTpConv		:= SA5->A5_XTPCONV
				@ 070,080 MsComboBox oTpConv Var cTpConv Items {"D=Divisor","M=Multiplicador"} Size 60,10 Pixel Of oDlgA5
			Endif
			If SA5->(FieldPos("A5_XCONV")) > 0
				@ 083,010 Say "Fator Conversão" Pixel of oDlgA5
				nQteConv	:= SA5->A5_XCONV
				@ 083,080 MsGet oQteConv Var nQteConv Size 80,10 Picture PesqPict("SA5","A5_XCONV") Pixel Of oDlgA5
			Endif
			
			@ 099,025 BUTTON "Confirma" Size 50,10 Action (ExistCpo("SB1",cVar,1),lAtuA5 := .T.,oDlgA5:End())	Pixel Of oDlgA5
			@ 099,080 BUTTON "Cancela" Size 50,10 Action (oDlgA5:End())	Pixel Of oDlgA5
			@ 099,135 Button "Cancela Todos" Size 60,10 Action(lConvProd	:= .F.,oDlgA5:End()) Pixel Of oDlga5

			ACTIVATE MsDialog oDlgA5 Centered
			
			If lAtuA5 .And. !Empty(cVar) .And. ExistCpo("SB1",cVar,1)
				cQry := "SELECT A5_PRODUTO,A5_NOMPROD,R_E_C_N_O_ A5RECNO "
				cQry += "  FROM " + RetSqlName("SA5")
				cQry += " WHERE D_E_L_E_T_ = ' ' "
				cQry += "   AND A5_CODPRF = '"+cCodAux+"' "
				cQry += "   AND A5_PRODUTO != '  ' "
				If SA5->(FieldPos("A5_REFGRD")) > 0 
					cQry += "  AND A5_REFGRD IN('  ','"+Padr(cCodAux,Len(SA5->A5_REFGRD))+"') "
				Endif
				cQry += "   AND A5_LOJA = '"+cInLojForn+"' "
				cQry += "   AND A5_FORNECE = '"+  cInCodForn  + "' "
				cQry += "   AND A5_PRODUTO ='" + Padr(cVar,TamSX3("A5_PRODUTO")[1])+ "' "
				cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
				If SA5->(FieldPos("A5_REFGRD")) > 0 
					cQry += "  ORDER BY A5_REFGRD DESC "
				Endif
				TCQUERY cQry NEW ALIAS "_SA5"
				
				If !EoF()
					DbSelectArea("SA5")
					DbGoto(_SA5->A5RECNO)
					//DbSetOrder(2)
					//If DbSeek(xFilial("SA5")+cVar+cInCodForn+cInLojForn)
					RecLock("SA5",.F.)
					SA5->A5_CODPRF  	:=	cCodAux
					SA5->A5_NOMPROD		:=  cInDescForn
					SA5->A5_NOMEFOR		:=	Posicione("SA2",1,xFilial("SA2")+cInCodForn+cInLojForn,"A2_NOME")
					SA5->A5_NOMPROD		:=  cInDescForn
					SA5->A5_UNID		:=  cUnidForn
					If SA5->(FieldPos("A5_XUNID")) > 0
						SA5->A5_XUNID	:= cInUnidForn
					Endif
					If SA5->(FieldPos("A5_DESREF")) > 0
						SA5->A5_DESREF	:= cInDescForn
					Endif
					If SA5->(FieldPos("A5_XTPCONV")) > 0
						SA5->A5_XTPCONV	:= cTpConv
					Endif
					If SA5->(FieldPos("A5_XCONV")) > 0
						SA5->A5_XCONV	:= nQteConv
					Endif
					// 19/11/2015 - Atualiza NCM conforme informação do Fornecedor
					If SA5->(FieldPos("A5_NCMPRF")) > 0
						SA5->A5_NCMPRF 	:= cInNcm
					Endif
					// 20/09/2016 - Atualiza Código de barra conforme XML
					If SA5->(FieldPos("A5_CODBAR")) > 0 .And. !Empty(cInCodBar)
						SA5->A5_CODBAR 	:= cInCodBar
					Endif
					// 15/08/2017 - Grava o Código Referência Grade para permitir repetição de A5_PRODUTO com A5_CODPRF diferentes
					If SA5->(FieldPos("A5_REFGRD")) > 0 
						If Len(Alltrim(cCodAux)) > Len(SA5->A5_REFGRD)
							ShowHelpDlg(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),;
							{"O tamanho do Código do Produto do Fornecedor",;
							"excede o tamanho do campo da tabela de Produto",;
							"X Fornecedor "},;
							5,;
							{"Aumentar o tamanho do campo 'A5_REFGRD' para"," ao menos "+ cValToChar(Len(Alltrim(cCodAux))) +" caracteres."},;
							5) 
						Else
							SA5->A5_REFGRD 	:= cCodAux
						Endif
					Endif
					MsUnlock()
					
					// Pula registro e se ainda encontrar outro registro para o mesmo produto x fornecedor deleta o registro
					DbSelectArea("_SA5")
					DbSkip()
					If !Eof()
						DbSelectArea("SA5")
						DbGoto(_SA5->A5RECNO)
						RecLock("SA5",.F.)
						DbDelete()
						MsUnlock()
					Endif	
				Else
					RecLock("SA5",.T.)
					SA5->A5_FILIAL 	:=	xFilial("SA5")
					SA5->A5_FORNECE	:= 	cInCodForn
					SA5->A5_LOJA	:= 	cInLojForn
					SA5->A5_NOMEFOR	:=	Posicione("SA2",1,xFilial("SA2")+cInCodForn+cLojForn,"A2_NOME")
					SA5->A5_PRODUTO	:=  cVar
					SA5->A5_NOMPROD	:=  cInDescForn
					SA5->A5_CODPRF	:=  cCodAux
					SA5->A5_UNID	:=  cUnidForn
					If SA5->(FieldPos("A5_XUNID")) > 0
						SA5->A5_XUNID	:= cInUnidForn
					Endif
					If SA5->(FieldPos("A5_DESREF")) > 0
						SA5->A5_DESREF	:= cInDescForn
					Endif
					If SA5->(FieldPos("A5_XTPCONV")) > 0
						SA5->A5_XTPCONV	:= cTpConv
					Endif
					If SA5->(FieldPos("A5_XCONV")) > 0
						SA5->A5_XCONV	:= nQteConv
					Endif
					// 19/11/2015 - Atualiza NCM conforme informação do Fornecedor
					If SA5->(FieldPos("A5_NCMPRF")) > 0
						SA5->A5_NCMPRF 	:= cInNcm
					Endif
					// 20/09/2016 - Atualiza Código de barra conforme XML
					If SA5->(FieldPos("A5_CODBAR")) > 0 .And. !Empty(cInCodBar)
						SA5->A5_CODBAR 	:= cInCodBar
					Endif
					// 15/08/2017 - Grava o Código Referência Grade para permitir repetição de A5_PRODUTO com A5_CODPRF diferentes
					If SA5->(FieldPos("A5_REFGRD")) > 0 
						If Len(Alltrim(cCodAux)) > Len(SA5->A5_REFGRD)
							ShowHelpDlg(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),;
							{"O tamanho do Código do Produto do Fornecedor",;
							"excede o tamanho do campo da tabela de Produto",;
							"X Fornecedor "},;
							5,;
							{"Aumentar o tamanho do campo 'A5_REFGRD' para"," ao menos "+ cValToChar(Len(Alltrim(cCodAux))) +" caracteres."},;
							5) 
						Else
							SA5->A5_REFGRD 	:= cCodAux
						Endif
					Endif
					MsUnlock()
				Endif
				_SA5->(DbCloseArea())
			Endif
		Endif
	Else
		If !lSuperUsr
			RestArea(aAreaOld)
			Return cRefProtheus
		Endif

		//A7_FILIAL    CHAR(2)           '  '
		//A7_CLIENTE   CHAR(6)           '      '
		//A7_LOJA      CHAR(2)           '  '
		//A7_PRODUTO   CHAR(15)          '               '
		//A7_CODCLI    CHAR(15)          '               '
		//A7_DESCCLI   CHAR(30)          '                              '

		cQry := "SELECT B1_COD "
		cQry += "  FROM " + RetSqlName("SB1")
		cQry += " WHERE D_E_L_E_T_ = ' '  "
		If lB1Msblql
			cQry += "   AND B1_MSBLQL <> '1' "
		Endif
		cQry += "   AND B1_COD IN('"+Alltrim(cRefProtheus)+"') "
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1") +"' "

		TCQUERY cQry NEW ALIAS "_SB1"

		If !Eof()
			cRefProtheus	:= _SB1->B1_COD
			lPergAtu		:= ReadVar() == "M->D1_COD"
		Endif

		_SB1->(DbCloseArea())

		If Select("QRY") > 0
			QRY->(DbCloseArea())
		Endif

		cQry := "SELECT A7_PRODUTO,A7_CODCLI,A7_DESCCLI,B1_DESC "
		cQry += "  FROM " + RetSqlName("SA7") + " A7, "+ RetSqlName("SB1")+ " B1 "
		cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
		If lB1Msblql
			cQry += "   AND B1_MSBLQL <> '1' "
		Endif
		cQry += "   AND B1_COD = A7_PRODUTO "
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry += "   AND A7.D_E_L_E_T_ = ' ' "
		cQry += "   AND A7_CLIENTE = '"+ cInCodForn+ "' "
		cQry += "   AND A7_LOJA = '"+cInLojForn+"' "
		cQry += "   AND A7_CODCLI ='" + Alltrim(cCodProd) + "' "
		cQry += "   AND A7_FILIAL = '" + xFilial("SA7") + "' "

		TCQUERY cQry NEW ALIAS "QRY"

		Count to nCountA7


		If nCountA7 == 0 .And. lPergAtu .And. !lAutoExec                  // Abre 05
			cQry := "SELECT DISTINCT D2_COD A7_PRODUTO,' ' A7_CODCLI,' ' A7_DESCCLI,B1_DESC  "
			cQry += "  FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SB1") + " B1 "
			cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
			aStrDesc	:= StrTokArr(cInDescForn," ")
			For xZ := 1 To Len(aStrDesc)
				If xZ == 1
					cQry += "   AND ( B1_DESC LIKE '%"+StrTran(aStrDesc[xZ],"'","''")+"%' "
				Else
					cQry += "   OR B1_DESC LIKE '%"+StrTran(aStrDesc[xZ],"'","''")+"%' "
				Endif
				If xZ == Len(aStrDesc)
					cQry += " )"
				Endif
			Next
			If lB1Msblql
				cQry += "   AND B1_MSBLQL <> '1' "
			Endif
			cQry += "   AND B1_COD = D2_COD "
			cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
			cQry += "   AND D2.D_E_L_E_T_ = ' ' "
			cQry += "   AND D2_QTDEDEV < D2_QUANT "
			cQry += "   AND D2_LOJA = '"+cInLojForn+"' "
			cQry += "   AND D2_CLIENTE = '"+cInCodForn+"' "
			cQry += "   AND D2_FILIAL = '"+xFilial("SD2")+"' "
			cQry += " ORDER BY 4,1 "

			QRY->(DbCloseArea())

			TCQUERY cQry NEW ALIAS "QRY"

			Count to nCountA7

		Endif

		If nCountA7 > 0                    // Abre 05

			aCampos := {}
			aTam:=TamSX3("A7_CODCLI")
			AADD(aCampos,{"CODPRF" ,"C",aTam[1],aTam[2]})
			aTam:=TamSX3("A7_PRODUTO")
			AADD(aCampos,{"PRODUTO" ,"C",aTam[1],aTam[2]})
			aTam:=TamSX3("A7_DESCCLI")
			AADD(aCampos,{"NOMPROD" ,"C",aTam[1],aTam[2]})
			aTam:=TamSX3("B1_DESC")
			AADD(aCampos,{"DESC" ,"C",aTam[1],aTam[2]})

			cArqTra  := CriaTrab(aCampos,.T.)
			dbUseArea(.T.,,cArqTra,"_SA7", .T. , .F. )
			DbSelectArea("QRY")
			DbGotop()
			While !Eof()
				DbSelectArea("_SA7")
				RecLock("_SA7",.T.)
				_SA7->CODPRF	:= QRY->A7_CODCLI
				_SA7->PRODUTO	:= QRY->A7_PRODUTO
				_SA7->NOMPROD	:= cInDescForn
				_SA7->DESC		:= QRY->B1_DESC
				MsUnlock()
				DbSelectArea("QRY")
				DbSkip()
			Enddo

			aCpos := {}
			AADD(aCpos   , {"CODPRF" , "Cod.Fornecedor" })
			AADD(aCpos   , {"PRODUTO", "Referência Protheus" })
			AADD(aCpos   , {"NOMPROD", "Descrição Fornecedor" })
			AADD(aCpos   , {"DESC"   , "Descrição Interno" })

			If nCountA7 > 1

				DEFINE MSDIALOG oDlg Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Produtos X Cliente") FROM 001,001 TO 380,810 PIXEL
				DbSelectArea("_SA7")
				DbGoTop()
				iw_browse(10,10,160,390,"_SA7",,,aCpos)
				@ 165,060 BUTTON "&Confirma" Action(cVar := _SA7->PRODUTO,oDlg:End())	Pixel Of oDlg
				@ 165,180 Button "&Aborta" Action (oDlg:End())  Pixel Of oDlg
				ACTIVATE MsDialog oDlg Centered
			Else
				cVar := _SA7->PRODUTO
			Endif

			DbSelectArea("_SA7")
			DbCloseArea()
			FErase(cArqTra + GetDbExtension()) // Deleting file
			FErase(cArqTra+ OrdBagExt()) // Deleting index

		Endif

		QRY->(DbCloseArea())


		cQry := "SELECT A7_PRODUTO,A7_DESCCLI "
		cQry += "  FROM " + RetSqlName("SA7")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += "   AND A7_CODCLI = '"+cCodProd+"' "
		cQry += "   AND A7_PRODUTO != '  ' "
		cQry += "   AND A7_LOJA = '"+cInLojForn+"' "
		cQry += "   AND A7_CLIENTE = '"+  cInCodForn  + "' "
		cQry += "   AND A7_PRODUTO ='" + Padr(cVar,TamSX3("A7_PRODUTO")[1])+ "' "
		cQry += "   AND A7_FILIAL = '" + xFilial("SA7") + "' "

		TCQUERY cQry NEW ALIAS "_SA7"

		Count to nCountA7

		If nCountA7 == 0
			lAtuSA7		:= .T.
		ElseIf !Empty(cRefProtheus)
			If nCountA7 == 0
				lAtuSA7 	:= .T.
			Else
				If lPergAtu
					If MsgYesNo("Força atualização da Conversão de Produto X Cliente?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")
						lAtuSA7	:= .T.
					Endif
				Endif
			Endif
		Endif
		_SA7->(DbCloseArea())

		If lAtuSA7 .And. !lAutoExec

			cCodAux	:= cCodProd
			lAtuA7 := .F.

			cVar		:= Padr(Iif(Empty(cRefProtheus),cVar,cRefProtheus),TamSX3("B1_COD")[1])

			DEFINE MSDIALOG oDlgA5 Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualizar Produto X Cliente") FROM 001,001 TO 240,450 PIXEL
			@ 010,010 Say ("Informe os códigos para conversão das Referências'") Pixel of oDlgA5
			@ 022,010 Say "'"+ cCodProd+"-"+cInDescForn+"'" Pixel Of oDlgA5
			@ 032,010 Say "Referência Cliente" Pixel of oDlgA5
			@ 032,080 MsGet oCodAux Var cCodAux Size 80,10 Picture "@!" Pixel Of oDlgA5
			@ 045,010 Say "Código Protheus" Pixel of oDlgA5
			@ 045,080 MsGet oCod Var cVar Valid ExistCpo("SB1",cVar,1) F3 "SB1" Size 50,10 Picture "@!" Pixel Of oDlgA5
			// 13/10/2016 - Adiciona botão se existir o ponto de entrada para facilitar o cadastro de produtos
			If ExistBlock("XMLCTE12")		
				@ 045,160 BUTTON "Cad.Produto" Size 40,10 Action (ExecBlock("XMLCTE12",.F.,.F.,{cCodProd,cInDescForn,cInUnidForn,cInNcm,cInCodBar,nInPIPI}))	Pixel Of oDlgA5
			Endif
			
			If SA7->(FieldPos("A7_XTPCONV")) > 0
				@ 057,010 Say "Tipo de Conversão" Pixel of oDlgA5
				cTpConv		:= SA7->A7_XTPCONV
				@ 057,080 MsComboBox oTpConv Var cTpConv Items {"D=Divisor","M=Multiplicador"} Size 60,10 Pixel Of oDlgA5
			Endif
			If SA7->(FieldPos("A7_XCONV")) > 0
				@ 070,010 Say "Fator Conversão" Pixel of oDlgA5
				nQteConv	:= SA7->A7_XCONV
				@ 070,080 MsGet oQteConv Var nQteConv Size 80,10 Picture PesqPict("SA7","A7_XCONV") Pixel Of oDlgA5
			Endif
			
			@ 099,010 BUTTON "Confirma" Size 70,10 Action (ExistCpo("SB1",cVar,1),lAtuA7 := .T.,oDlgA5:End())	Pixel Of oDlgA5
			
			@ 099,090 BUTTON "Cancela" Size 70,10 Action (oDlgA5:End())	Pixel Of oDlgA5

			ACTIVATE MsDialog oDlgA5 Centered

			If lAtuA7
				DbSelectArea("SA7")
				DbSetOrder(2)
				If DbSeek(xFilial("SA7")+cVar+cInCodForn+cInLojForn)
					RecLock("SA7",.F.)
					SA7->A7_CODCLI  	:=	cCodAux
					SA7->A7_DESCCLI		:=  cInDescForn
					If SA7->(FieldPos("A7_XUNID")) > 0
						SA7->A7_XUNID	:= cInUnidForn
					Endif
					If SA7->(FieldPos("A7_XTPCONV")) > 0
						SA7->A7_XTPCONV	:= cTpConv
					Endif
					If SA7->(FieldPos("A7_XCONV")) > 0
						SA7->A7_XCONV	:= nQteConv
					Endif
					MsUnlock()
				Else
					RecLock("SA7",.T.)
					SA7->A7_FILIAL 	:=	xFilial("SA7")
					SA7->A7_CLIENTE	:= 	cInCodForn
					SA7->A7_LOJA	:= 	cInLojForn
					SA7->A7_PRODUTO	:=  cVar
					SA7->A7_DESCCLI	:=  cInDescForn
					SA7->A7_CODCLI	:=  cCodAux
					If SA7->(FieldPos("A7_XUNID")) > 0
						SA7->A7_XUNID	:= cInUnidForn
					Endif
					If SA7->(FieldPos("A7_XTPCONV")) > 0
						SA7->A7_XTPCONV	:= cTpConv
					Endif
					If SA7->(FieldPos("A7_XCONV")) > 0
						SA7->A7_XCONV	:= nQteConv
					Endif
					MsUnlock()
				Endif
			Endif
		Endif
	Endif
	RestArea(aAreaOld)

Return cVar



/*/{Protheus.doc} sfFindSC7
(Localiza produtos sem vinculo de Produto X Fornecedor em pedidos de compra em Aberto do Fornecedor do XML em questão)
@type function
@author marce
@since 24/11/2015
@version 1.0
@param cInVar, character, (Descrição do parâmetro)
@param cInCodProd, character, (Descrição do parâmetro)
@param cInCodForn, character, (Descrição do parâmetro)
@param cInLojForn, character, (Descrição do parâmetro)
@param cInDescForn, character, (Descrição do parâmetro)
@param cInUnidForn, character, (Descrição do parâmetro)
@param nQteXml, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfFindSC7(cInVar,cInCodProd,cInCodForn,cInLojForn,cInDescForn,cInUnidForn,nQteXml,nPrcXml,cInA5Produto)

	Local	aAreaOld	:= GetArea()
	Local	cQry		:= ""
	Local	aX3C7		:= {"C7_PRODUTO","B1_DESC","C7_NUM","C7_ITEM","C7_UM","C7_QUANT","C7_PRECO","C7_QUJE","C7_TIPO","C7_LOCAL","C7_EMISSAO","C7_DATPRF","C7_OBS","C7_QTSEGUM","C7_QTDACLA","C7_DESCRI"}
	Local	aStruSC7	:= {}
	Local	aCab		:= {}
	Local	aCampos		:= {}
	Local	aTamCab		:= {}
	Local	aArrayF4	:= {}
	Local	nOpca		:= 0
	Local	nSavQual	:= 0
	Local 	lRet		:= .F.
	Local	iX
	Local	nForA,nForB
	Local	oPanelDlg
	Default cInA5Produto	:= ""

	dbSelectArea("SC7")
	cAliasSC7 := "QRYSC7"
	cQry 	:= "SELECT C7.R_E_C_N_O_ C7RECNO "

	DbSelectArea("SX3")
	dbSetOrder(2)
	For iX	:= 1 To Len(aX3C7)
		DbSelectArea("SX3")
		dbSetOrder(2)
		If DbSeek(aX3C7[iX])
			If ( SX3->X3_CONTEXT <> "V" )
				cQry += ","+SX3->X3_CAMPO
				Aadd(aStruSC7,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				Aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
			Endif
		Endif
	Next

	cQry += "  FROM "+ RetSqlName("SC7") + " C7, " + RetSqlName("SB1") + " B1 "
	cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
	cQry += "   AND B1_COD = C7_PRODUTO "
	cQry += "   AND B1_FILIAL = '" + xFilial("SB1")+ "'"
	If !Empty(cInA5Produto)
		cQry += " AND C7_PRODUTO = '"+cInA5Produto+"' "
	Else
		cQry += "   AND NOT EXISTS (SELECT A5_PRODUTO "
		cQry += "                     FROM "+ RetSqlName("SA5") + " A5 "
		cQry += "                    WHERE D_E_L_E_T_ =' ' "
		cQry += "                      AND A5_FORNECE = C7_FORNECE "
		cQry += "                      AND A5_LOJA = C7_LOJA "
		cQry += "                      AND A5_PRODUTO = C7_PRODUTO "
		cQry += "                      AND A5_CODPRF ='" + cInCodProd + "' "
		cQry += "                      AND A5_FILIAL = '" +xFilial("SA5")+ "' )" // Verifica que não existe amarração SA5 ainda para o produto do Fornecedor
	Endif

	If !Empty(cInVar)
		cQry += " AND C7_PRODUTO = '"+cInVar+"' "
	Endif
	cQry += "   AND C7.D_E_L_E_T_ = ' ' "
	cQry += "   AND C7_RESIDUO = ' ' "
	cQry += "   AND C7_QUJE < C7_QUANT "
	cQry += "   AND C7_LOJA = '" + cInLojForn + "'"
	cQry += "   AND C7_FORNECE = '"+cInCodForn+"' "
	cQry += "   AND C7_FILIAL = '"+xFilial("SC7") + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSC7,.T.,.T.)

	For nForA := 1 To Len(aStruSC7)
		If aStruSC7[nForA,2]<>"C"
			TcSetField(cAliasSC7,aStruSC7[nForA,1],aStruSC7[nForA,2],aStruSC7[nForA,3],aStruSC7[nForA,4])
		EndIf
	Next nForA

	bWhile := {|| (cAliasSC7)->(!Eof())}

	If (cAliasSC7)->(!Eof())

		dbSelectArea(cAliasSC7)
		While Eval(bWhile)
			nFreeQT := 0

			If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
				Aadd(aArrayF4,Array(Len(aCampos)))
				For nForB := 1 to Len(aCampos)
					If aCampos[nForB][3] != "V"
						If aCampos[nForB][2] == "N"
							If Alltrim(aCampos[nForB][1]) == "C7_QUANT"
								aArrayF4[Len(aArrayF4)][nForB] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nForB][1]))
							Else
								aArrayF4[Len(aArrayF4)][nForB] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nForB][1]))),PesqPict("SC7",aCampos[nForB][1]))
							Endif
						Else
							aArrayF4[Len(aArrayF4)][nForB] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nForB][1])))
						Endif
					Else
						aArrayF4[Len(aArrayF4)][nForB] := CriaVar(aCampos[nForB][1],.T.)
					Endif
				Next nForB
			EndIf

			DbSelectArea(cAliasSC7)
			DbSkip()
		EndDo
	Endif
	dbSelectArea(cAliasSC7)
	dbCloseArea()


	If !Empty(aArrayF4)
		DEFINE MSDIALOG oDlgC7 FROM 30,20  TO 565,1251 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecionar produto ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"
		
		oPanelDlg := TPanel():New(0,0,'',oDlgC7, oDlgC7:oFont, .T., .T.,, ,200,65,.T.,.T. )
		oPanelDlg:Align := CONTROL_ALIGN_ALLCLIENT
	
		oQual := TWBrowse():New( 31,4,611,224,,aCab,aTamCab,oPanelDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
		OQual:nFreeze := 1
		// Ajustar casas decimais conforme SC7  				
		@ 05  ,4   SAY OemToAnsi("Cód/UM/Descrição") Of oPanelDlg PIXEL SIZE 50 ,9 //"Produto"
		@ 04  ,60  MSGET cInCodProd PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanelDlg PIXEL SIZE 60,9
		@ 04  ,125  MSGET cInUnidForn When .F. Of oPanelDlg PIXEL SIZE 40,9
		@ 04  ,170  MSGET cInDescForn PICTURE PesqPict('SB1','B1_DESC') When .F. Of oPanelDlg PIXEL SIZE 260,9
		@ 19  ,4   SAY OemToAnsi("Quant/Preço XML") Of oPanelDlg PIXEL SIZE 47 ,9 //"Produto"
		@ 18  ,60  MSGET nQteXml PICTURE PesqPict('SD1','D1_QUANT') When .F. Of oPanelDlg PIXEL SIZE 60,9
		@ 18  ,125  MSGET nPrcXml PICTURE PesqPict('SD1','D1_VUNIT') When .F. Of oPanelDlg PIXEL SIZE 60,9

		ACTIVATE MSDIALOG oDlgC7 CENTERED ON INIT EnchoiceBar(oDlgC7,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlgC7:End()},{||oDlgC7:End()},,)

		If nOpca == 1
			cInVar	:= aArrayF4[nSavQual,1]
			lRet	:= .T.
		Endif
	Else
		If !Empty(cInA5Produto)
			MsgAlert("Não foram encontrados Pedido de Compra em Aberto!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Não há dados!")
		Else
			MsgAlert("Não foram encontrados produtos sem Referência de Produto X Fornecedor e com Pedido de Compra em Aberto!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Não há dados!")
		Endif
	Endif

	RestArea(aAreaOld)

Return lRet

/*/{Protheus.doc} VldItemPc
(long_description)
@author MarceloLauschner
@since 06/08/2010
@version 1.0
@param nLinha, numérico, (Descrição do parâmetro)
@param lAutoSC7, logico, (Descrição do parâmetro)
@param cNumC7, character, (Descrição do parâmetro)
@param cItemC7, character, (Descrição do parâmetro)
@param lConfFinal, logico, (Descrição do parâmetro)
@param lConManual, logico, (Descrição do parâmetro)
@param lxPed, logico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function VldItemPc(nLinha,lAutoSC7,cNumC7,cItemC7,lConfFinal,lConManual,lxPed)

	Local 		nOpca      		:= 0
	Local 		aAreaItOld   	:= GetArea()
	Local 		aStruSC7   		:= SC7->(dbStruct())
	Local 		aCab       		:= {}
	Local 		aCampos    		:= {}
	Local 		aArrSldo		:= {}
	Local 		aArrayF4		:= {} 
	Local 		aTamCab     	:= {}
	Local 		lMt103Vpc  		:= ExistBlock("MT103VPC")
	Local		lQuery    		:= .F.
	Local 		aButtons		:= { {'PESQUISA',{|| U_XmlAltPC(aArrSldo[oQual:nAt][2],2),Pergunte(cPergXml,.F.)},OemToAnsi("Visualiza Pedido"),OemToAnsi("Visualiza pedido")},;
	{'ALTERA',{|| U_XmlAltPC(aArrSldo[oQual:nAt][2],4)},OemToAnsi("Altera Pedido"),OemToAnsi("Altera pedido")}}
	Local 		nFreeQt     	:= 0
	Local 		cVar        	:= ""
	Local 		cQuery      	:= ""
	Local 		cAliasSC7   	:= "SC7"
	Local 		cCpoObri    	:= ""
	Local 		nSavQual
	Local 		nPed        	:= 0
	Local 		nIX         	:= 0
	Local 		nAuxCNT     	:= 0
	Local 		lRet103Vpc  	:= .T.
	Local 		lContinua   	:= .T.
	Local 		oQual
	Local 		oDlg
	Local 		bWhile
	Local 		lFirstUM 		:= .F.
	Local		cItemPc			:= ""
	Local		cPedido     	:= ""
	Local		nPosSF4			:= 0
	Local		lRet			:= .T.
	Local		i7
	Local		iR
	Default 	nLinha			:= oMulti:nAt
	Default 	lAutoSC7		:= .F.
	Default 	cNumC7			:= ""
	Default 	cItemC7			:= ""
	Default 	lConfFinal		:= .F.
	Default 	lConManual		:= .F.
	Default 	lxPed			:= .F.
	PRIVATE 	nTipo 			:= 1
	PRIVATE 	cCadastro		:= OemToAnsi("Visualização de Pedido de Compra")
	PRIVATE 	l120Auto		:= .F.
	PRIVATE 	nTipoPed    	:= 1 // 1 - Ped. Compra 2 - Aut. Entrega
	Private 	INCLUI			:= .F.
	Private 	ALTERA			:= .T.
	PRIVATE 	lPedido     	:= .T.
	PRIVATE 	lGatilha    	:= .T.                          // Para preencher aCols em funcoes chamadas da validacao (X3_VALID)
	PRIVATE 	lVldHead    	:= GetNewPar( "MV_VLDHEAD",.T. )// O parametro MV_VLDHEAD e' usado para validar ou nao o aCols (uma linha ou todo), a partir das validacoes do aHeader -> VldHead()
	Private 	aRotina			:= StaticCall(MATA103,MenuDef)

	If Len(oMulti:aCols) == 0
		Return .F.
	Endif
	cVar	:=	oMulti:aCols[nLinha][nPxProd]

	// Faço o preenchimento do armazém
	If Empty(oMulti:aCols[nLinha][nPxLocal])
		oMulti:aCols[nLinha][nPxLocal]   := sfRetLocPad(oMulti:aCols[nLinha,nPxProd],GetNewPar("XM_B1LOCPD","  "),oMulti:aCols[nLinha][nPxLocal])
		//Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_LOCPAD")
	Endif
	If Empty(oMulti:aCols[nLinha][nPxUm])
		oMulti:aCols[nLinha][nPxUm]			:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_UM")
	Endif

	// Alimenta campo Prazo validade 
	If Empty(oMulti:aCols[nLinha][nPxVldLtFo])
		oMulti:aCols[nLinha][nPxVldLtFo]   := DaySum( dDataBase , Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_PRVALID") )
	EndIf

	If aArqXml[oArqXml:nAt,nPosTpNota]	$ "B#D"
		If nAlertPrc == 3
			Return .T.
		Endif
		cRetCF	:= "1"

		// Novo procedimento que permite especificar qual Código e Loja
		If !Empty(CONDORXML->XML_CODLOJ)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
				If SA1->A1_EST == SuperGetMv("MV_ESTADO")
					cRetCF := "1"
				Else
					cRetCF := "2"
				EndIf
			Endif
		Else
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
				If SA1->A1_EST == SuperGetMv("MV_ESTADO")
					cRetCF := "1"
				Else
					cRetCF := "2"
				EndIf
			Endif
		Endif
		
		If (aArqXml[oArqXml:nAt,nPosTpNota] $ "D" .And. Empty(oMulti:aCols[nLinha][nPxQte])) .Or. aArqXml[oArqXml:nAt,nPosTpNota]	$ "B"
			
			DbSelectArea("SA7")
			DbSetOrder(2)
			DbSeek(xFilial("SA7")+cVar+cCodForn+cLojForn)
				
			cTpConv		:= ""
			nQteConv    := 0
			nQtdConvNf	:= oMulti:aCols[nLinha,nPxQteNfe]
			If SA7->(FieldPos("A7_XTPCONV")) > 0
				cTpConv	:= SA7->A7_XTPCONV
			Endif
			If SA7->(FieldPos("A7_XCONV")) > 0
				nQteConv	:= SA7->A7_XCONV
			Endif
			//MsgAlert(nQteconv,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			If Empty(nQteConv)
				nQteConv	:= 1
			ElseIf nQteConv > 1
				nQtdConvNf	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1))
			Endif
			//MsgAlert(nQtdConvNf,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))					
			oMulti:aCols[nLinha][nPxUm]			:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_UM")
			oMulti:aCols[nLinha][nPxQte]       	:=  nQtdConvNf //oMulti:aCols[nLinha,nPxQteNfe]
			oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
			oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]
		Endif
		If aArqXml[oArqXml:nAt,nPosTpNota]	$ "B"
			// Efetuo a conversão de CFOP de retorno de Terceiros conforme parametro
			If aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }) > 0
				oMulti:aCols[nLinha][nPxD1Tes]	:=  aRetPoder3[aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }),2]

				DbSelectArea("SF4")
				DbSetOrder(1)
				If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
					oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
				Endif
			Else
				U_XmlVldTt(4,nLinha)
			Endif


		Endif
		oMulti:oBrowse:Refresh()

		If oMulti:aCols[nLinha,nPxQte] > 0

			// Verifica se o CFOP encontrado se trata de Poder de terceiros
			If lConManual .And. aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }) > 0
				lAllPoder3	:=  MsgNoYes("Exibir todas notas do retorno de Poder de Terceiros?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Poder de Terceiros!")
			Endif
			aCols		:= aClone(oMulti:aCols)
			aHeader		:= aClone(oMulti:aHeader)
			aHeadBk		:= aClone(aHeader)
			n			:= nLinha
			nRecSD2		:= 0
			nRegistro	:= 0

			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])

			If aArqXml[oArqXml:nAt,nPosTpNota]	$ "B" .And. SF4->F4_PODER3 == "D"
				// Customização para atender a Logistock - Retorno armazenagem
				If lConManual
					F4Poder3(cVar,,"B","E",cCodForn,cLojForn,@nRegistro,)
				Else
					sfF4Poder3(cVar,,"B","E",cCodForn,cLojForn,@nRegistro,,,nLinha)
					//F4Poder3(cProduto,cLocal,M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
					lAllPoder3	:= .T.
				Endif
				nRecSD2	:= nRegistro
				//  F4Poder3(cProduto,cLocal                  ,cTpNF,cES,cCliFor ,cLoja   ,nRegistro,oque,cNumPV)
				//  F4Poder3(cProduto,cLocal,                 M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
			Endif

			If aArqXml[oArqXml:nAt,nPosTpNota]	$ "D"
				//TODO validar se a variável cCodForn/cLojForn estão populadas ao passar a chamada da função			
				F4NFORI(       ,      ,"_NFORI",cCodForn,cLojForn,cVar    ,"A100",oMulti:aCols[nLinha][nPxLocal] , @nRecSD2 )
				//F4NFORI(,,"M->D1_NFORI",cA100For,cLoja,aCols[n][nPosCod],"A100",aCols[n][nPLocal],@nRecSD2) .And. nRecSD2<>0
				lAllPoder3	:= .T.
			Endif
			// xunxo....
			oMulti:aCols[nLinha] := aCols[nLinha]
			// Verifico se o retorno tem quantidade menor que a quantidade constante na nota fiscal
			If oMulti:aCols[nLinha][nPxQteNfe] > oMulti:aCols[nLinha][nPxQte]
				MsgAlert("Saldo insuficiente do Produto '"+SB1->B1_COD+"-"+SB1->B1_DESC+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Favor conferir")
			Endif

			// Alteração feita em 24/02/2012 para forçar o preenchimento do valor de desconto
			If lAllPoder3
				If oMulti:aCols[nLinha][nPxTotal] > oMulti:aCols[nLinha][nPxTotNfe] //.And. oMulti:aCols[nLinha][nPxQteNfe] <= oMulti:aCols[nLinha][nPxQte]
					oMulti:aCols[nLinha][nPxVlDesc]	:= oMulti:aCols[nLinha][nPxTotal] - oMulti:aCols[nLinha][nPxTotNfe]
				ElseIf oMulti:aCols[nLinha][nPxTotal] < oMulti:aCols[nLinha][nPxTotNfe] //.And. oMulti:aCols[nLinha][nPxQteNfe] <= oMulti:aCols[nLinha][nPxQte]
					oMulti:aCols[nLinha][nPxValDesp]	:=  oMulti:aCols[nLinha][nPxTotNfe] - oMulti:aCols[nLinha][nPxTotal]
				EndIf
			Endif

			// Efetuo ajuste do TES correto conforme TES de Devolução no Cadastro
			If nRecSD2 > 0
				DbSelectArea("SD2")
				DbGoto(nRecSD2)
				If !Empty(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV"))
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV")
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif
				Endif
			Endif

			// Ponto de entrada criado em 09/05/2014 para permitir adaptações do cliente quanto aos dados de retorno da nota de origem.
			If ExistBlock("XMLCTE05")
				ExecBlock("XMLCTE05",.F.,.F.,{nLinha})
			Endif

			oMulti:oBrowse:Refresh()

			stLinOk(nLinha)

			Return .T.
		Else
			MsgAlert("Não há como buscar histórico da devolução se não tiver quantidade digitada!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida")
			Return .F.
		Endif
	ElseIf aArqXml[oArqXml:nAt,nPosTpNota]	$ "CPI"
		If nAlertPrc == 3
			Return .T.
		Endif

		cRetCF	:= "1"
		If Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
			cRetCF	:= "3"
		Else
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			Else
				DbSelectArea("SA2")
				DbSetOrder(3)
				DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
			Endif

			If SA2->A2_EST == SuperGetMv("MV_ESTADO")
				cRetCF := "1"
			Else
				cRetCF := "2"
			EndIf
		Endif

		oMulti:aCols[nLinha][nPxUm]			:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_UM")
		oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
		oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]

		oMulti:oBrowse:Refresh()

		aCols		:= aClone(oMulti:aCols)
		aHeader		:= oMulti:aHeader
		aHeadBk		:= aClone(aHeader)
		n			:= nLinha
		nRecSD1		:= 0

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])

		//F4NFORI(       ,      ,"_NFORI",cCodForn,cLojForn,cVar    ,"A100","01" , @nRecSD2 )
		If F4COMPL(,,,cCodForn,cLojForn,cVar,"A100",@nRecSD1,"M->D1_NFORI") .And. nRecSD1<>0
			// xunxo....
			oMulti:aCols[nLinha] := aCols[nLinha]
		Endif
		oMulti:oBrowse:Refresh()
		Return .T.
	Else

		// Se for acionado pelo botão "Ped.Nf/Origem" e já estiver lançada a nota, visualiza o pedido de compra
		// Mudança feita em 13/10/2013
		If !Empty(CONDORXML->XML_KEYF1) 
			DbSelectArea("SC7")
			DbSetOrder(1)
			If DbSeek(xFilial("SC7")+oMulti:aCols[nLinha][nPxPedido]+oMulti:aCols[nLinha][nPxItemPc])
				U_XmlAltPC(SC7->(Recno()),2)
			Endif
			RestArea(aAreaItOld)
			Return .T.
		Endif


		cRetCF	:= "1"
		If Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
			cRetCF	:= "3"
		Else
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			Else
				DbSelectArea("SA2")
				DbSetOrder(3)
				DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
			Endif

			If SA2->A2_EST == SuperGetMv("MV_ESTADO")
				cRetCF := "1"
			Else
				cRetCF := "2"
			Endif
		Endif
		// Atribuo valor default
		oMulti:aCols[nLinha,1]	:= oVermelho


		DbSelectArea("SB1")
		DbSetOrder(1)
		If ! DbSeek(xFilial("SB1")+cVar)
			MsgAlert("Não há Referência Protheus válida digitada na Coluna "+Alltrim(Str(nPxProd)) + " na linha "+Alltrim(Str(nLinha)) ,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Return .F.
		Endif

		// Se Tiver o campo TES preenchido mas não tiver sido conferido no compras ainda
		If !(!Empty(oMulti:aCols[nLinha,nPxD1Tes]).And. Empty(aArqXml[oArqXml:nAt,nPosConfCp]))
			oMulti:aCols[nLinha][nPxD1Tes]	:= sfRetTes(oMulti:aCols[nLinha,nPxD1Tes],oMulti:aCols[nLinha,nPxItem],oMulti:aCols[ nLinha,nPxProd ],oMulti:aCols[ nLinha,nPxD1Oper ],lConManual)
		Endif

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])


		// Efetuo a conversão de CFOP de retorno de Terceiros conforme parametro
		If aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }) > 0 .Or. SF4->F4_PODER3 == "D"
			nPosSF4	:=  aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) })
			If nPosSF4 > 0
				//oMulti:aCols[nLinha][nPxD1Tes]		:=  aRetPoder3[nPosSF4,2]
				oMulti:aCols[nLinha][nPxD1Tes]	:= sfRetTes(aRetPoder3[nPosSF4,2],oMulti:aCols[nLinha,nPxItem],oMulti:aCols[nLinha,nPxProd],oMulti:aCols[nLinha,nPxD1Oper],lConManual)
				//sfRetTes(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE"),oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO,Iif(SC7->(FieldPos(cC7OPER)) <> 0 ,&("SC7->"+cC7OPER),oMulti:aCols[nLinha,nPxD1Oper]))) //SC7->C7_TES
			Endif
			DbSelectArea("SF4")
			DbSetOrder(1)
			If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
				oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
			Endif
			oMulti:aCols[nLinha][nPxUm]			:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxProd],"B1_UM")
			oMulti:aCols[nLinha][nPxQte]       	:=  oMulti:aCols[nLinha,nPxQteNfe]
			oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
			oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]
			oMulti:oBrowse:Refresh()

			aCols			:= aClone(oMulti:aCols)
			aHeader			:= oMulti:aHeader
			aHeadBk			:= aClone(aHeader)
			n				:= nLinha
			nRegistro		:= 0

			If lConManual .And. SF4->F4_PODER3 == "D"
				If !sfF4Poder3(cVar,,"N","E",cCodForn,cLojForn,@nRegistro,,,nLinha,.T.)
					F4Poder3(cVar,,"N","E",cCodForn,cLojForn,@nRegistro,)
				Endif
			ElseIf SF4->F4_PODER3 == "D"
				If !sfF4Poder3(cVar,,"N","E",cCodForn,cLojForn,@nRegistro,,,nLinha)
					If lAutoExec
						sfAtuXmlOk("P3",.T.,oMulti:aCols[nLinha,nPxItem])
					Endif
				Endif
			Endif
			//F4Poder3(cVar,,"N","E",cCodForn,cLojForn,@nRegistro,)
			//  F4Poder3(cProduto,cLocal                  ,cTpNF,cES,cCliFor ,cLoja   ,nRegistro,oque,cNumPV)
			//  F4Poder3(cProduto,cLocal,                 M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
			// xunxo....
			oMulti:aCols[nLinha] := aCols[nLinha]
			If !Empty(oMulti:aCols[nLinha,nPxNfOri])
				If oMulti:aCols[nLinha][nPxTotal] > oMulti:aCols[nLinha][nPxTotNfe] //.And. oMulti:aCols[nLinha][nPxQteNfe] <= oMulti:aCols[nLinha][nPxQte]
					oMulti:aCols[nLinha][nPxVlDesc]	:= oMulti:aCols[nLinha][nPxTotal] - oMulti:aCols[nLinha][nPxTotNfe]
					oMulti:aCols[nLinha][nPxValDesp] := 0
				ElseIf oMulti:aCols[nLinha][nPxTotal] < oMulti:aCols[nLinha][nPxTotNfe] //.And. oMulti:aCols[nLinha][nPxQteNfe] <= oMulti:aCols[nLinha][nPxQte]
					oMulti:aCols[nLinha][nPxValDesp]	:=  oMulti:aCols[nLinha][nPxTotNfe] - oMulti:aCols[nLinha][nPxTotal]
					oMulti:aCols[nLinha][nPxVlDesc]	 := 0
				EndIf
				oMulti:aCols[nLinha,1]	:= oPreto
			Endif
			// Uso o TES de Devolução para os casos de retorno também
			// Efetuo ajuste do TES correto conforme TES de Devolução no Cadastro
			If nRegistro > 0
				DbSelectArea("SD2")
				DbGoto(nRegistro)
				If !Empty(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV"))
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV")
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif
				Endif
			Endif

			oMulti:oBrowse:Refresh()
			//Endif
			lContinua	:= .F.
		Endif

		If lContinua 	// Abre 01
			dbSelectArea("SC7")
			cAliasSC7 := "QRYSC7"
			aStruSC7	:= {}
			lQuery    	:= .T.
			cQuery 	:= "SELECT C7_PRODUTO"
			cCpoObri 	:= "C7_LOJA|C7_QTSEGUM|C7_QUANT|C7_PRECO|C7_QUJE|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS|C7_ITEM|C7_CONAPRO|C7_TPOP|C7_ITEM|C7_NUM|C7_QUANT|C7_QUJE|C7_QTDACLA|"
			dbSelectArea("SX3")
			dbSetOrder(1)
			DbSeek("SC7")
			While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
				IF ( SX3->X3_CONTEXT <> "V" .And. SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM").Or.;
				(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
					cQuery += ","+SX3->X3_CAMPO
					Aadd(aStruSC7,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				Endif
				dbSelectArea("SX3")
				dbSkip()
			Enddo
			cQuery += "        ,R_E_C_N_O_ RECSC7 "
			cQuery += "  FROM "+ RetSqlName("SC7") + " SC7 "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			If !Empty(cVar)
				cQuery += "AND C7_PRODUTO = '"+cVar+"' "
			Endif
			cQuery += "   AND C7_RESIDUO = ' '"
			cQuery += "   AND C7_QUJE < C7_QUANT "

			If !Empty(cNumC7)
				// Se o número do pedido não existir zera a variável
				DbSelectArea("SC7")
				DbSetOrder(1)
				If !DbSeek(xFilial("SC7")+cNumC7+cItemC7)
					cNumC7		:= ""
					cItemC7		:= ""
				Else
					cQuery += "   AND C7_NUM = '" + StrTran(cNumC7,"'","") + "' "
					cQuery += "   AND C7_ITEM = '" + StrTran(cItemC7,"'","") + "' "
				Endif
				// Somente no automático e se houver ordem de compra no XML
			ElseIf lAutoSC7
				// Se encontrar o caractere
				If At("#",CONDORXML->XML_BODY) > 0
					cListSC7	:= CONDORXML->XML_BODY+"#"
					aListSC7	:= StrTokArr(cListSC7,"#")
					lAddSC7		:= .F.
					For i7 := 1 To Len(aListSC7)
						If !Empty(aListSC7[i7])
							DbSelectArea("SC7")
							DbSetOrder(1)
							If DbSeek(xFilial("SC7")+Alltrim(aListSC7[i7]))
								If !lAddSC7
									cQuery += "   AND C7_NUM IN('"+SC7->C7_NUM+"'"
								Else
									cQuery += ",'"+SC7->C7_NUM+"'"
								Endif
								lAddSC7	:= .T.
							Endif
						Endif
					Next
					If lAddSC7
						cQuery += ") "
					Endif

				ElseIf !Empty(CONDORXML->XML_PCOMPR) .And.!Empty(cVar)
					DbSelectArea("SC7")
					DbSetOrder(4) // Produto + Pedido + Item
					If DbSeek(xFilial("SC7")+Padr(cVar,Len(SC7->C7_PRODUTO)) + Padr(Alltrim(CONDORXML->XML_PCOMPR),Len(SC7->C7_NUM))) 
						cQuery += "   AND C7_NUM LIKE '%"+Alltrim(CONDORXML->XML_PCOMPR)+"%' "
					Endif
				Endif
			Endif
			// 15/08/2017 - Adicionado filtro para considerar Loja do fornecedor ou não conforme pergunta MTA103 MV_PAR07 
			If lConsLoja
				cQuery += "   AND C7_LOJA = '"+cLojForn+"' "
			Endif
			cQuery += "   AND C7_FORNECE = '"+cCodForn+"' "
			cQuery += "   AND C7_FILIAL = '"+xFilial("SC7") + "' "

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

			For nIX := 1 To Len(aStruSC7)
				If aStruSC7[nIX,2]<>"C"
					TcSetField(cAliasSC7,aStruSC7[nIX,1],aStruSC7[nIX,2],aStruSC7[nIX,3],aStruSC7[nIX,4])
				EndIf
			Next nIX
			// 10/11/2016 - Adicionado condição para não considerar Pedido de compra para CFOPs de saída que estejam na exceção cCFOPNPED			 
			bWhile := {|| (cAliasSC7)->(!Eof()) .And. !Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED }

			cCpoObri := "C7_LOJA|C7_QTSEGUM|C7_QUANT|C7_PRECO|C7_TOTAL|C7_QUJE|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS|C7_DATPRF"

			aCampos := {}
			If (cAliasSC7)->(!Eof())

				dbSelectArea("SX3")
				dbSetOrder(2)
				DbSeek("C7_NUM")
				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
				dbSelectArea("SX3")
				dbSetOrder(1)
				DbSeek("SC7")
				While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
					IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM").Or.;
					(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
						AAdd(aCab,x3Titulo())
						Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
						aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
					EndIf
					dbSelectArea("SX3")
					dbSkip()
				Enddo
			Endif

			dbSelectArea(cAliasSC7)
			While Eval(bWhile)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra os Pedidos Bloqueados e Previstos.                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (SuperGetMV("MV_RESTNFE") == "S" .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. (cAliasSC7)->C7_TPOP == "P"
					DbSelectArea(cAliasSC7)
					DbSkip()
					Loop
				EndIf
				nFreeQT := 0

				// Melhoria implementada em 29/04/2012 para filtrar pedidos de compra já vinculados em outras notas
				cItemPc		:= (cAliasSC7)->C7_ITEM
				cPedido     := (cAliasSC7)->C7_NUM
				BeginSql Alias "QXIT"

				SELECT XIT_QTE
				FROM CONDORXMLITENS XI,CONDORXML XM
				WHERE XM.%NotDel%
				AND XML_KEYF1 = '  '
				AND XML_CONFCO <> '  '
				AND XML_REJEIT = '  '
				AND XML_CHAVE = XIT_CHAVE
				AND XIT_CHAVE <> %Exp:aArqXml[oArqXml:nAt,nPosChvNfe]%
				AND XIT_CODPRD = %Exp:cVar%
				AND XIT_ITEMPC = %Exp:cItemPc%
				AND XIT_PEDIDO = %Exp:cPedido%
				AND XI.%NotDel%
				EndSql

				While !Eof()
					nFreeQT += QXIT->XIT_QTE
					QXIT->(DbSkip())
				Enddo
				QXIT->(DbCloseArea())

				For nAuxCNT := 1 To Len( oMulti:aCols )
					If (nAuxCNT # nLinha) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxProd ] == (cAliasSC7)->C7_PRODUTO) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxPedido ] == (cAliasSC7)->C7_NUM) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxItemPc ] == (cAliasSC7)->C7_ITEM) .And. ;
					!ATail( oMulti:aCols[ nAuxCNT ] ) .And. !oMulti:aCols[nAuxCNT,Len(oMulti:aHeader)+1]
						nFreeQT += oMulti:aCols[ nAuxCNT,nPxQte ]
					EndIf
				Next

				lRet103Vpc := .T.
				// Permite uso do ponto de entrada padrão do sistema
				// 10/06/2014
				If lMt103Vpc
					If lQuery
						('SC7')->(dbGoto((cAliasSC7)->RECSC7))
					EndIf
					lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
				Endif

				If lRet103Vpc
					If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
						Aadd(aArrayF4,Array(Len(aCampos)))
						For nIX := 1 to Len(aCampos)
							If aCampos[nIX][3] != "V"
								If aCampos[nIX][2] == "N"
									If Alltrim(aCampos[nIX][1]) == "C7_QUANT"
										aArrayF4[Len(aArrayF4)][nIX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nIX][1]))
									ElseIf Alltrim(aCampos[nIX][1]) == "C7_TOTAL"
										aArrayF4[Len(aArrayF4)][nIX] :=Transform(nFreeQt * (cAliasSC7)->(FieldGet(FieldPos("C7_PRECO"))),PesqPict("SC7",aCampos[nIX][1]))
									Else
										aArrayF4[Len(aArrayF4)][nIX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nIX][1]))),PesqPict("SC7",aCampos[nIX][1]))
									Endif
								Else
									aArrayF4[Len(aArrayF4)][nIX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nIX][1])))
								Endif
							Else
								aArrayF4[Len(aArrayF4)][nIX] := CriaVar(aCampos[nIX][1],.T.)
								If Alltrim(aCampos[nIX][1]) == "C7_CODGRP"
									SB1->(dbSetOrder(1))
									SB1->(DbSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))
									aArrayF4[Len(aArrayF4)][nIX] := SB1->B1_GRUPO
								EndIf
								If Alltrim(aCampos[nIX][1]) == "C7_CODITE"
									SB1->(dbSetOrder(1))
									SB1->(DbSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))
									aArrayF4[Len(aArrayF4)][nIX] := SB1->B1_CODITE
								EndIf
							Endif
						Next
						AAdd( aArrSldo,{nFreeQT,(cAliasSC7)->RECSC7} )
					EndIf
				Endif
				DbSelectArea(cAliasSC7)
				DbSkip()
			EndDo
			dbSelectArea(cAliasSC7)
			dbCloseArea()


			If !Empty(aArrayF4) .And. !lAutoSC7 .And. (lMVXPCNFE .Or. (lXMSC7AUT .And. !lMVXPCNFE))
				DEFINE MSDIALOG oDlg FROM 30,20  TO 285,951 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecionar pedido de compra ( por item ) ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

				oPanelPC := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,200,40,.T.,.T. )
				oPanelPC:Align := CONTROL_ALIGN_ALLCLIENT

				oQual := TWBrowse():New( 29,4,461,76,,aCab,aTamCab,oPanelPC,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oQual:SetArray(aArrayF4)
				oQual:bLine := { || aArrayF4[oQual:nAT] }
				OQual:nFreeze := 1

				// Ajustar casas decimais conforme SC7  				
				@ 15  ,4   SAY OemToAnsi("Produto") Of oPanelPC PIXEL SIZE 47 ,9 //"Produto"
				@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanelPC PIXEL SIZE 60,9
				@ 15  ,95  SAY OemToAnsi("Qte XML") Of oPanelPC PIXEL SIZE 25 ,9
				@ 14  ,120  MsGet oMulti:aCols[nLinha][nPxQteNfe] Picture PesqPict("SD1","D1_QUANT") When .F. Of oPanelPC Pixel Size 35,09
				@ 15  ,170 SAY OemToAnsi("R$ XML") Of oPanelPC PIXEL SIZE 25 ,9
				@ 14  ,198  MsGet oMulti:aCols[nLinha][nPxPrcNfe] Picture PesqPict("SD1","D1_VUNIT") When .F. Of oPanelPC Pixel Size 45,09
				@ 15  ,255 Say OemToAnsi("Ord.Compra") Of oPanelPC PIXEL SIZE 35 ,9
				@ 14  ,295  MsGet CONDORXML->XML_PCOMPR When .F. Of oPanelPC Pixel Size 30,09

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)

				If nOpca == 1
					dbSelectArea("SC7")
					MsGoto(aArrSldo[nSavQual][2])

					nC7Preco	:= sfxMoeda()
						
					DbSelectArea("SA5")
					// Se a segunda unidade de medida for igual a do xml
					cQry := "SELECT R_E_C_N_O_ A5RECNO "
					cQry += "  FROM " + RetSqlName("SA5")
					cQry += " WHERE D_E_L_E_T_ = ' ' "
					cQry += "   AND A5_CODPRF = '"+oMulti:aCols[nLinha,nPxCodNfe]+"' "
					cQry += "   AND A5_PRODUTO = '"+SC7->C7_PRODUTO+"' "
					cQry += "   AND A5_LOJA = '"+cLojForn+"' "
					cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
					cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
					If SA5->(FieldPos("A5_REFGRD")) > 0 
						cQry += " AND A5_REFGRD IN(' ','"+oMulti:aCols[nLinha,nPxCodNfe]+"')"
					Endif
		
					TCQUERY cQry NEW ALIAS "_SA5"
					
					DbSelectArea("SA5")
					DbSetOrder(2)
					DbGoto(_SA5->A5RECNO)
					_SA5->(DbCloseArea())
					
					//DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)

					cTpConv		:= ""
					nQteConv    := 0

					If SA5->(FieldPos("A5_XTPCONV")) > 0
						cTpConv	:= SA5->A5_XTPCONV
					Endif
					If SA5->(FieldPos("A5_XCONV")) > 0
						nQteConv	:= SA5->A5_XCONV
					Endif

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
					If Empty(cTpConv)
						cTpConv	:= SB1->B1_TIPCONV
					Endif
					If Empty(nQteConv)
						// Adicionado em 01/07/2013 para forçar 1 = 1
						If lMadeira .And. Empty(nQteConv)
							nQteConv	:= 1
							oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
						Else
							nQteConv	:= SB1->B1_CONV
						Endif
					Endif

					aNewLine	:= {}

					lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)
					If lFirstUM .Or. ;
					Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_SEGUM)) $ (SB1->B1_SEGUM+"#"+SA5->A5_UNID ) .Or.;
					(IIf(SA5->(FieldPos("A5_XUNID")) > 0,oMulti:aCols[nLinha,nPxUMNFe] == SA5->A5_XUNID,.F.))

						nQtdConvNf	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))

						aRetMaAval := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,nQtdConvNf,aArrSldo[nSavQual][1],oMulti:aCols[nLinha][nPxPrunit], nC7Preco ,.F.,.T.,.F.)
						// 			  MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,aCols[nx][nPosQtd]+SC7->C7_QUJE+SC7->C7_QTDACLA-IIf(l103Class,SD1->D1_QUANT,0),SC7->C7_QUANT,aCols[nx][nPosVlr],xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,,M->dDEmissao,nDecimalPC,SC7->C7_TXMOEDA,))[1]

						/*
						±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
						±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
						±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
						±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
						±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
						±±³          ³ ExpN3 = Preco a receber                                      ³±±
						±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
						±±³          ³ ExpL1 = Exibir Help                                          ³±±
						±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
						±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
						±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
						/*/
						//Return({lBloqueio,nPQtde, nPPreco})

						If (aArrSldo[nSavQual][1])  < nQtdConvNf .And. aRetMaAval[1]
							If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja fracionar a quantidade automaticamente?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência Pedido de Compra!")
								aNewLine := sfFracQte((aArrSldo[1][1]/nQtdConvNf)*oMulti:aCols[nLinha,nPxQteNfe],nLinha,.T.)
								nLinha   := aNewLine[1]
								oMulti:aCols[nLinha][nPxQte]	:= 	aArrSldo[nSavQual][1]
								//U_XmlAltPC(aArrSldo[nSavQual][2])
								//oMulti:aCols[nLinha][nPxPedido]	:=	""
								//oMulti:aCols[nLinha][nPxItemPc]	:= 	""
							Endif

							nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] *Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
							nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,TamSX3("D1_VUNIT")[2])
							oMulti:aCols[nLinha][nPxPrunit]		:= 	nPrunitAux
							oMulti:aCols[nLinha][nPxTotal]		:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] , TamSX3("D1_TOTAL")[2])	//aCols[nLinha,nPxTotNfe]

						Else
							oMulti:aCols[nLinha][nPxQte]      	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
							oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
							oMulti:aCols[nLinha][nPxTotal]		:= 	oMulti:aCols[nLinha,nPxTotNfe]
						Endif

						If oMulti:aCols[nLinha][nPxPrunit] <> nC7Preco
							If nAlertPrc == 2
								MsgAlert("Para o produto "+ SC7->C7_PRODUTO + SC7->C7_DESCRI+" foi encontrada divergência de preço. Favor conferir!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência de preço!")
							Endif
						Endif
					Else
						oMulti:aCols[nLinha][nPxQte]	:= 	aArrSldo[nSavQual][1]
						oMulti:aCols[nLinha][nPxPrunit]	:= 	nC7Preco
						oMulti:aCols[nLinha][nPxTotal]	:= 	Round((aArrSldo[nSavQual][1])*nC7Preco,TamSX3("D1_TOTAL")[2])
					Endif
					oMulti:aCols[nLinha][nPxUm]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_UM"))
					oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
					oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM

					If Empty(cNumC7)
						oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES) .And. Empty(aArqXml[oArqXml:nAt,nPosConfCp]),SC7->C7_TES,sfRetTes(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE"),oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO,Iif( SC7->(FieldPos(cC7OPER)) <> 0 ,&("SC7->"+cC7OPER),oMulti:aCols[nLinha,nPxD1Oper]),lConManual))

						If SC7->(FieldPos(cC7OPER)) <> 0
							oMulti:aCols[nLinha,nPxD1Oper]	:= &("SC7->"+cC7OPER)
						Endif
					Endif
					// Verifica se é bonificação e força conversão da TES
					If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910" .And. Empty(cNumC7)
						oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
						//oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE"),oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO)) //SC7->C7_TES
					Endif

					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif

					// Adicionado o preenchimento do campo Armazem´em 29/11/2012
					If !Empty(SC7->C7_LOCAL)
						oMulti:aCols[nLinha][nPxLocal]	:= SC7->C7_LOCAL
					Endif
					oMulti:oBrowse:Refresh()
					If !Empty(aNewLine) .And. Len(aNewLine) > 1
						// Melhoria adicionada em 23/06/2013 a pedido de MadeiraMadeira
						// Permite que haja o fracionamento do produto conforme os pedidos de compra
						// Recupera a area de dados
						aAreaRest	:= GetArea()
						// Executa a verificação de pedido para a linha com o saldo da nota que ainda não tem pedido
						U_VldItemPc(aNewLine[2],.T.)
						// Restaura a area anterior
						RestArea(aAreaRest)
					Endif
				Else
					// Se a segunda unidade de medida for igual a do xml
					DbSelectArea("SA5")
					DbSetOrder(2)
					DbSeek(xFilial("SA5")+cVar+cCodForn+cLojForn)

					cTpConv		:= ""
					nQteConv    := 0

					If SA5->(FieldPos("A5_XTPCONV")) > 0
						cTpConv	:= SA5->A5_XTPCONV
					Endif
					If SA5->(FieldPos("A5_XCONV")) > 0
						nQteConv	:= SA5->A5_XCONV
					Endif

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+cVar)
					If Empty(cTpConv)
						cTpConv	:= SB1->B1_TIPCONV
					Endif
					If Empty(nQteConv)
						// Adicionado em 01/07/2013 para forçar 1 = 1
						If lMadeira .And. Empty(nQteConv)
							nQteConv	:= 1
							oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
						Else
							nQteConv	:= SB1->B1_CONV
						Endif
					Endif

					lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)

					oMulti:aCols[nLinha][nPxQte]      	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
					oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
					oMulti:aCols[nLinha][nPxTotal]		:= 	oMulti:aCols[nLinha,nPxTotNfe]
					oMulti:aCols[nLinha][nPxUm]			:= 	SB1->B1_UM
					oMulti:aCols[nLinha][nPxPedido]		:=	" "
					oMulti:aCols[nLinha][nPxItemPc]		:= 	" "
					oMulti:aCols[nLinha][nPxD1Tes]		:= 	sfRetTes(SB1->B1_TE,oMulti:aCols[nLinha,nPxItem],cVar,oMulti:aCols[nLinha,nPxD1Oper],lConManual)

					// Verifica se é bonificação e força conversão da TES
					If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910"
						oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
					Endif

					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif

					oMulti:oBrowse:Refresh()
				EndIf
			Elseif lAutoSC7 .And. !Empty(aArrayF4) .And. (lMVXPCNFE .Or. (lXMSC7AUT .And. !lMVXPCNFE))
				If Len(aArrayF4) > 1
					If !lAutoExec


						DEFINE MSDIALOG oDlg FROM 30,20  TO 285,951 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecionar pedido de compra ( por item ) ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"
						oPanelPC := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,200,40,.T.,.T. )
						oPanelPC:Align := CONTROL_ALIGN_ALLCLIENT

						oQual := TWBrowse():New( 29,4,461,76,,aCab,aTamCab,oPanelPC,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
						oQual:SetArray(aArrayF4)
						oQual:bLine := { || aArrayF4[oQual:nAT] }
						OQual:nFreeze := 1
						@ 15  ,4   SAY OemToAnsi("Produto") Of oPanelPC PIXEL SIZE 47 ,9 //"Produto"
						@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanelPC PIXEL SIZE 60,9
						@ 15  ,95  SAY OemToAnsi("Qte XML") Of oPanelPC PIXEL SIZE 25 ,9
						@ 14  ,120  MsGet oMulti:aCols[nLinha][nPxQteNfe] Picture PesqPict("SD1","D1_QUANT") When .F. Of oPanelPC Pixel Size 35,09
						@ 15  ,170 SAY OemToAnsi("R$ XML") Of oPanelPC PIXEL SIZE 25 ,9
						@ 14  ,198  MsGet oMulti:aCols[nLinha][nPxPrcNfe] Picture PesqPict("SD1","D1_VUNIT") When .F. Of oPanelPC Pixel Size 45,09
						@ 15  ,255 Say OemToAnsi("Ord.Compra") Of oPanelPC PIXEL SIZE 35 ,9
						@ 14  ,295  MsGet CONDORXML->XML_PCOMPR When .F. Of oPanelPC Pixel Size 30,09
						ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:= 1,oDlg:End()},{||oDlg:End()},,aButtons)

						If nOpca == 1
							
							dbSelectArea("SC7")
							MsGoto(aArrSldo[nSavQual][2])

							nC7Preco	:= sfxMoeda()

							// 15/06/2017 - Chamado 176 Centralxml
							// Solução para permitir que um pedido selecionado num item da nota que tenha mais de um pedido, seja atribuído o 
							// número do pedido como Ordem de compra no campo XML_PCOMPR para que os próximos itens já filtrem por este número
							If CONDORXML->XML_PCOMPR <> SC7->C7_NUM .And.  MsgYesNo("Deseja atribuir este número de pedido '" + SC7->C7_NUM + "' como filtro para os demais itens desta nota? ",ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
								U_DbSelArea("CONDORXML",.F.,1)
								RecLock("CONDORXML",.F.)
								CONDORXML->XML_PCOMPR	:= SC7->C7_NUM
								MsUnlock()								
							Endif
							
							DbSelectArea("SA5")
							// Se a segunda unidade de medida for igual a do xml
							cQry := "SELECT R_E_C_N_O_ A5RECNO "
							cQry += "  FROM " + RetSqlName("SA5")
							cQry += " WHERE D_E_L_E_T_ = ' ' "
							cQry += "   AND A5_CODPRF = '"+oMulti:aCols[nLinha,nPxCodNfe]+"' "
							cQry += "   AND A5_PRODUTO = '"+SC7->C7_PRODUTO+"' "
							cQry += "   AND A5_LOJA = '"+cLojForn+"' "
							cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
							cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
							If SA5->(FieldPos("A5_REFGRD")) > 0 
								cQry += " AND A5_REFGRD IN(' ','"+oMulti:aCols[nLinha,nPxCodNfe]+"')"
							Endif
				
							TCQUERY cQry NEW ALIAS "_SA5"
							
							DbSelectArea("SA5")
							DbSetOrder(2)
							DbGoto(_SA5->A5RECNO)
							_SA5->(DbCloseArea())
							
							//DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)
							
							cTpConv		:= ""
							nQteConv    := 0

							If SA5->(FieldPos("A5_XTPCONV")) > 0
								cTpConv	:= SA5->A5_XTPCONV
							Endif
							If SA5->(FieldPos("A5_XCONV")) > 0
								nQteConv	:= SA5->A5_XCONV
							Endif

							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
							If Empty(cTpConv)
								cTpConv	:= SB1->B1_TIPCONV
							Endif
							If Empty(nQteConv)
								// Adicionado em 01/07/2013 para forçar 1 = 1
								If lMadeira .And. Empty(nQteConv)
									nQteConv	:= 1
									oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
								Else
									nQteConv	:= SB1->B1_CONV
								Endif
							Endif

							aNewLine	:= {}
							
							// Se a segunda unidade de medida for igual a do xml
							lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)
							If lFirstUM .Or. ;
							Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_SEGUM)) $ (SB1->B1_SEGUM +"#"+SA5->A5_UNID) .Or.;
							(IIf(SA5->(FieldPos("A5_XUNID")) > 0,oMulti:aCols[nLinha,nPxUMNFe] == SA5->A5_XUNID,.F.))
								// Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
								nQtdConvNf	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
								aRetMaAval := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,nQtdConvNf,aArrSldo[nSavQual][1],oMulti:aCols[nLinha][nPxPrunit], nC7Preco ,.F.,.T.,.F.)
								/*
								±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
								±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
								±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
								±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
								±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
								±±³          ³ ExpN3 = Preco a receber                                      ³±±
								±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
								±±³          ³ ExpL1 = Exibir Help                                          ³±±
								±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
								±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
								±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
								/*/
								//Return({lBloqueio,nPQtde, nPPreco})


								If (aArrSldo[nSavQual][1])  < nQtdConvNf .And. aRetMaAval[1]
									If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja fracionar a quantidade automaticamente?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência Pedido de Compra!")
										aNewLine := sfFracQte((aArrSldo[1][1]/nQtdConvNf)*oMulti:aCols[nLinha,nPxQteNfe],nLinha,.T.)
										nLinha   := aNewLine[1]
										oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[nSavQual][1]

										//U_XmlAltPC(aArrSldo[nSavQual][2])
										//oMulti:aCols[nLinha][nPxPedido]		:=	""
										//oMulti:aCols[nLinha][nPxItemPc]		:= 	""
									Endif
									nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxPrunit]			:= 	nPrunitAux
									oMulti:aCols[nLinha][nPxTotal]			:= Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] , TamSX3("D1_TOTAL")[2])//	aCols[nLinha,nPxTotNfe]
								Else
									oMulti:aCols[nLinha][nPxQte]      		:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									oMulti:aCols[nLinha][nPxPrunit]			:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxTotal]			:= 	oMulti:aCols[nLinha,nPxTotNfe]
								Endif
								oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
								oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM
								If oMulti:aCols[nLinha][nPxPrunit] <> nC7Preco
									If nAlertPrc == 2
										MsgAlert("Para o produto "+ SC7->C7_PRODUTO + SC7->C7_DESCRI+" foi encontrada divergência de preço. Favor conferir!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência de preço!")
									Endif
								Endif
							Else
								
								oMulti:aCols[nLinha][nPxQte]	:= 	aArrSldo[nSavQual][1]
								oMulti:aCols[nLinha][nPxPrunit]	:= 	nC7Preco
								oMulti:aCols[nLinha][nPxTotal]	:= 	Round((aArrSldo[nSavQual][1]) * nC7Preco,TamSX3("D1_TOTAL")[2])
							Endif

							oMulti:aCols[nLinha][nPxUm]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,SB1->B1_UM)
							If Empty(cNumC7)
								//oMulti:aCols[nLinha][nPxD1Tes]		:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,SB1->B1_TE) //SC7->C7_TES
								oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,sfRetTes(SB1->B1_TE,oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO,Iif(SC7->(FieldPos(cC7OPER)) <> 0 ,&("SC7->"+cC7OPER),oMulti:aCols[nLinha,nPxD1Oper]),lConManual)) //SC7->C7_TES
								If SC7->(FieldPos(cC7OPER)) <> 0
									oMulti:aCols[nLinha,nPxD1Oper]	:= &("SC7->"+cC7OPER)
								Endif
							Endif
							// Verifica se é bonificação e força conversão da TES
							If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910"	.And. Empty(cNumC7)
								oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
							Endif
							DbSelectArea("SF4")
							DbSetOrder(1)
							If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
								oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
							Endif

							// Adicionado o preenchimento do campo Armazem´em 29/11/2012
							If !Empty(SC7->C7_LOCAL)
								oMulti:aCols[nLinha][nPxLocal]	:= SC7->C7_LOCAL
							Endif

							oMulti:oBrowse:Refresh()
							If !Empty(aNewLine) .And. Len(aNewLine) > 1
								// Melhoria adicionada em 23/06/2013 a pedido de MadeiraMadeira
								// Permite que haja o fracionamento do produto conforme os pedidos de compra
								// Recupera a area de dados
								aAreaRest	:= GetArea()
								// Executa a verificação de pedido para a linha com o saldo da nota que ainda não tem pedido
								U_VldItemPc(aNewLine[2],.T.)
								// Restaura a area anterior
								RestArea(aAreaRest)
							Endif
						Endif
					Else
						If Empty(cNumC7)
							dbSelectArea("SC7")
							MsGoto(aArrSldo[1][2])

							nC7Preco	:= sfxMoeda()
							DbSelectArea("SA5")
							// Se a segunda unidade de medida for igual a do xml
							cQry := "SELECT R_E_C_N_O_ A5RECNO "
							cQry += "  FROM " + RetSqlName("SA5")
							cQry += " WHERE D_E_L_E_T_ = ' ' "
							cQry += "   AND A5_CODPRF = '"+oMulti:aCols[nLinha,nPxCodNfe]+"' "
							cQry += "   AND A5_PRODUTO = '"+SC7->C7_PRODUTO+"' "
							cQry += "   AND A5_LOJA = '"+cLojForn+"' "
							cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
							cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
							If SA5->(FieldPos("A5_REFGRD")) > 0 
								cQry += " AND A5_REFGRD IN(' ','"+oMulti:aCols[nLinha,nPxCodNfe]+"')"
							Endif
				
							TCQUERY cQry NEW ALIAS "_SA5"
							
							DbSelectArea("SA5")
							DbSetOrder(2)
							DbGoto(_SA5->A5RECNO)
							_SA5->(DbCloseArea())
							
							//DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)

							cTpConv		:= ""
							nQteConv    := 0

							If SA5->(FieldPos("A5_XTPCONV")) > 0
								cTpConv	:= SA5->A5_XTPCONV
							Endif
							If SA5->(FieldPos("A5_XCONV")) > 0
								nQteConv	:= SA5->A5_XCONV
							Endif

							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
							If Empty(cTpConv)
								cTpConv	:= SB1->B1_TIPCONV
							Endif
							If Empty(nQteConv)
								// Adicionado em 01/07/2013 para forçar 1 = 1
								If lMadeira .And. Empty(nQteConv)
									nQteConv	:= 1
									oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
								Else
									nQteConv	:= SB1->B1_CONV
								Endif
							Endif
							aNewLine	:= {}

							lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)

							// Se a unidade de medida do fornecedor for igual a primeira do produto ou se a segunda unidade de medida for igual a do xml
							If lFirstUM .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_SEGUM)) $ (SB1->B1_SEGUM + "#"+SA5->A5_UNID) .Or.;
							(IIf(SA5->(FieldPos("A5_XUNID")) > 0,oMulti:aCols[nLinha,nPxUMNFe] == SA5->A5_XUNID,.F.))

								// Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
								nQtdConvNf	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))

								aRetMaAval := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,nQtdConvNf,aArrSldo[1][1],oMulti:aCols[nLinha][nPxPrunit], nC7Preco ,.F.,.T.,.F.)
								/*
								±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
								±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
								±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
								±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
								±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
								±±³          ³ ExpN3 = Preco a receber                                      ³±±
								±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
								±±³          ³ ExpL1 = Exibir Help                                          ³±±
								±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
								±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
								±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
								/*/
								//Return({lBloqueio,nPQtde, nPPreco})


								If aArrSldo[1][1]  < nQtdConvNf .And. aRetMaAval[1]
									aNewLine := sfFracQte((aArrSldo[1][1]/nQtdConvNf)*oMulti:aCols[nLinha,nPxQteNfe],nLinha,.T.)
									nLinha   := aNewLine[1]
									oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
									oMulti:aCols[nLinha][nPxItemPC]	:= 	SC7->C7_ITEM
									oMulti:aCols[nLinha][nPxQte]	:= 	aArrSldo[1][1]
									nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
									oMulti:aCols[nLinha][nPxTotal]	:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] ,TamSX3("D1_TOTAL")[2])//	aCols[nLinha,nPxTotNfe]
								Else
									oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
									oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM
									oMulti:aCols[nLinha][nPxQte]   	:=  nQtdConvNf // oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
								Endif
							Else
								oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[1][1]
								oMulti:aCols[nLinha][nPxPrunit]		:= 	nC7Preco
								oMulti:aCols[nLinha][nPxTotal]		:= 	Round((aArrSldo[1][1]) * nC7Preco,TamSX3("D1_TOTAL")[2])
							Endif
							oMulti:aCols[nLinha][nPxUm]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_UM"))
							oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,sfRetTes(RetFldProd(SC7->C7_PRODUTO,"B1_TE"),oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO,Iif(SC7->(FieldPos(cC7OPER)) <> 0 ,&("SC7->"+cC7OPER),oMulti:aCols[nLinha,nPxD1Oper]),lConManual)) //SC7->C7_TES
							If SC7->(FieldPos(cC7OPER)) <> 0
								oMulti:aCols[nLinha,nPxD1Oper]	:= &("SC7->"+cC7OPER)
							Endif
							// Verifica se é bonificação e força conversão da TES
							If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910"
								oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
							Endif
							DbSelectArea("SF4")
							DbSetOrder(1)
							If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
								oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
							Endif

							// Adicionado o preenchimento do campo Armazem´em 29/11/2012
							If !Empty(SC7->C7_LOCAL)
								oMulti:aCols[nLinha][nPxLocal]	:= SC7->C7_LOCAL
							Endif
							oMulti:oBrowse:Refresh()

							If !Empty(aNewLine) .And. Len(aNewLine) > 1
								// Melhoria adicionada em 23/06/2013 a pedido de MadeiraMadeira
								// Permite que haja o fracionamento do produto conforme os pedidos de compra
								// Recupera a area de dados
								aAreaRest	:= GetArea()
								// Executa a verificação de pedido para a linha com o saldo da nota que ainda não tem pedido
								U_VldItemPc(aNewLine[2],.T.)
								// Restaura a area anterior
								RestArea(aAreaRest)
							Endif
						Endif
					EndIf
				Else
					If Empty(cNumC7) .Or. lxPed
						dbSelectArea("SC7")
						MsGoto(aArrSldo[1][2])
						oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
						oMulti:aCols[nLinha][nPxItemPC]	:= 	SC7->C7_ITEM

						nC7Preco	:= sfxMoeda()
						
						DbSelectArea("SA5")
						// Se a segunda unidade de medida for igual a do xml
						cQry := "SELECT R_E_C_N_O_ A5RECNO "
						cQry += "  FROM " + RetSqlName("SA5")
						cQry += " WHERE D_E_L_E_T_ = ' ' "
						cQry += "   AND A5_CODPRF = '"+oMulti:aCols[nLinha,nPxCodNfe]+"' "
						cQry += "   AND A5_PRODUTO = '"+SC7->C7_PRODUTO+"' "
						cQry += "   AND A5_LOJA = '"+cLojForn+"' "
						cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
						cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
						If SA5->(FieldPos("A5_REFGRD")) > 0 
							cQry += " AND A5_REFGRD IN(' ','"+oMulti:aCols[nLinha,nPxCodNfe]+"')"
						Endif
				
						TCQUERY cQry NEW ALIAS "_SA5"
						
						DbSelectArea("SA5")
						DbSetOrder(2)
						DbGoto(_SA5->A5RECNO)
						_SA5->(DbCloseArea())
							
						//DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)

						cTpConv		:= ""
						nQteConv    := 0

						If SA5->(FieldPos("A5_XTPCONV")) > 0
							cTpConv	:= SA5->A5_XTPCONV
						Endif
						If SA5->(FieldPos("A5_XCONV")) > 0
							nQteConv	:= SA5->A5_XCONV
						Endif

						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
						If Empty(cTpConv)
							cTpConv	:= SB1->B1_TIPCONV
						Endif
						If Empty(nQteConv)
							// Adicionado em 01/07/2013 para forçar 1 = 1
							If lMadeira .And. Empty(nQteConv)
								nQteConv	:= 1
								oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
							Else
								nQteConv	:= SB1->B1_CONV
							Endif
						Endif
						lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)
						// Se a segunda unidade de medida for igual a do xml
						If lFirstUM .Or.;
						Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_SEGUM)) $ (SB1->B1_SEGUM + "#"+SA5->A5_UNID) .Or.;
						(IIf(SA5->(FieldPos("A5_XUNID")) > 0,oMulti:aCols[nLinha,nPxUMNFe] == SA5->A5_XUNID,.F.))
							// Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
							nQtdConvNf	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))

							aRetMaAval := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,nQtdConvNf,aArrSldo[1][1],oMulti:aCols[nLinha][nPxPrunit], nC7Preco ,.F.,.T.,.F.)
							/*
							±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
							±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
							±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
							±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
							±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
							±±³          ³ ExpN3 = Preco a receber                                      ³±±
							±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
							±±³          ³ ExpL1 = Exibir Help                                          ³±±
							±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
							±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
							±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
							/*/
							//Return({lBloqueio,nPQtde, nPPreco})


							If aArrSldo[1][1]  < nQtdConvNf .And. aRetMaAval[1] //.And. GetNewPar("XM_VLDTOLE","N") $ "A#B"
								If lAutoExec
									aNewLine := sfFracQte((aArrSldo[1][1]/nQtdConvNf)*oMulti:aCols[nLinha,nPxQteNfe],nLinha,.T.)
									nLinha   := aNewLine[1]
									oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
									oMulti:aCols[nLinha][nPxItemPC]	:= 	SC7->C7_ITEM
									oMulti:aCols[nLinha][nPxQte]	:= 	aArrSldo[1][1]
									nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
									oMulti:aCols[nLinha][nPxTotal]	:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] ,TamSX3("D1_TOTAL")[2])//	aCols[nLinha,nPxTotNfe]
								Else
									oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
									oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM
									oMulti:aCols[nLinha][nPxQte]   	:=  nQtdConvNf // oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
									oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
									oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
								Endif


								/*
								oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[1][1]
								If lAutoExec
								oMulti:aCols[nLinha][nPxQte]		:= 	0
								oMulti:aCols[nLinha][nPxPedido]		:=	""
								oMulti:aCols[nLinha][nPxItemPc]		:= 	""
								sfAtuXmlOk("CW",.T.,oMulti:aCols[nLinha,nPxItem])
								Else

								sfAtuXmlOk("CW",.T.,oMulti:aCols[nLinha,nPxItem])

								If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja alterar o pedido de compra?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência Pedido de Compra!")
								oMulti:aCols[nLinha][nPxQte]		:= 0
								U_XmlAltPC(aArrSldo[1][2],4)
								oMulti:aCols[nLinha][nPxPedido]		:=	""
								oMulti:aCols[nLinha][nPxItemPc]		:= 	""
								Endif
								Endif
								nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
								nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,TamSX3("D1_VUNIT")[2])
								oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
								oMulti:aCols[nLinha][nPxTotal]	:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] ,TamSX3("D1_TOTAL")[2])//	aCols[nLinha,nPxTotNfe]
								*/
							Else
								oMulti:aCols[nLinha][nPxQte]   	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
								oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
								oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
							Endif
						Else
							oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[1][1]
							oMulti:aCols[nLinha][nPxPrunit]		:= 	nC7Preco
							oMulti:aCols[nLinha][nPxTotal]		:= 	Round((aArrSldo[1][1]) * nC7Preco,TamSX3("D1_TOTAL")[2])
						Endif
						oMulti:aCols[nLinha][nPxUm]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,SB1->B1_UM)
						If Empty(cNumC7)
							//oMulti:aCols[nLinha][nPxD1Tes]		:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE")) //SC7->C7_TES
							oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,sfRetTes(RetFldProd(SC7->C7_PRODUTO,"B1_TE"),oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO,Iif(SC7->(FieldPos(cC7OPER)) <> 0 ,&("SC7->"+cC7OPER),oMulti:aCols[nLinha,nPxD1Oper]),lConManual)) //SC7->C7_TES
							If SC7->(FieldPos(cC7OPER)) <> 0
								oMulti:aCols[nLinha,nPxD1Oper]	:= &("SC7->"+cC7OPER)
							Endif
						Endif
						// Verifica se é bonificação e força conversão da TES
						If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910" .And. Empty(cNumC7)
							oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
						Endif
						DbSelectArea("SF4")
						DbSetOrder(1)
						If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
							oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
						Endif

						// Adicionado o preenchimento do campo Armazem´em 29/11/2012
						If !Empty(SC7->C7_LOCAL)
							oMulti:aCols[nLinha][nPxLocal]	:= SC7->C7_LOCAL
						Endif

						oMulti:oBrowse:Refresh()
					Endif
				Endif
			Else
				// Se a segunda unidade de medida for igual a do xml
				DbSelectArea("SA5")
				// Se a segunda unidade de medida for igual a do xml
				cQry := "SELECT R_E_C_N_O_ A5RECNO "
				cQry += "  FROM " + RetSqlName("SA5")
				cQry += " WHERE D_E_L_E_T_ = ' ' "
				cQry += "   AND A5_CODPRF = '"+oMulti:aCols[nLinha,nPxCodNfe]+"' "
				cQry += "   AND A5_PRODUTO = '"+oMulti:aCols[nLinha,nPxProd]+"' "
				cQry += "   AND A5_LOJA = '"+cLojForn+"' "
				cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
				cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
				If SA5->(FieldPos("A5_REFGRD")) > 0 
					cQry += " AND A5_REFGRD IN(' ','"+oMulti:aCols[nLinha,nPxCodNfe]+"')"
				Endif
				
				TCQUERY cQry NEW ALIAS "_SA5"
							
				DbSelectArea("SA5")
				DbSetOrder(2)
				DbGoto(_SA5->A5RECNO)
				_SA5->(DbCloseArea())
							
				cTpConv		:= ""
				nQteConv    := 0

				If SA5->(FieldPos("A5_XTPCONV")) > 0
					cTpConv	:= SA5->A5_XTPCONV
				Endif
				If SA5->(FieldPos("A5_XCONV")) > 0
					nQteConv	:= SA5->A5_XCONV
				Endif

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+oMulti:aCols[nLinha,nPxProd])
				If Empty(cTpConv)
					cTpConv	:= SB1->B1_TIPCONV
				Endif
				If Empty(nQteConv)
					// Adicionado em 01/07/2013 para forçar 1 = 1
					If lMadeira .And. Empty(nQteConv)
						nQteConv	:= 1
						oMulti:aCols[nLinha,nPxUMNFe]	:= SB1->B1_UM
					Else
						nQteConv	:= SB1->B1_CONV
					Endif
				Endif

				If !lAutoSC7 .Or. !Empty(cNumC7)
					If lMVXPCNFE .And.;
					!Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED .And.;
					(IIf(!Empty(oMulti:aCols[nLinha][nPxCF]),!Alltrim(oMulti:aCols[nLinha][nPxCF]) $ cCFOPNPED,.T.)) .And.;
					(IIf(!Empty(oMulti:aCols[nLinha][nPxD1Tes]),!Alltrim(oMulti:aCols[nLinha][nPxD1Tes]) $ cTESNPED,.T.))
						If lAutoExec
							sfAtuXmlOk("CY",.T.,oMulti:aCols[nLinha,nPxItem])
						Else
							sfAtuXmlOk("CY",.T.,oMulti:aCols[nLinha,nPxItem])
							MsgAlert("Não há saldo de pedido de compra em aberto para o item '"+oMulti:aCols[nLinha,nPxItem]+"'/Produto '"+oMulti:aCols[nLinha,nPxProd]+oMulti:aCols[nLinha,nPxDescri]+"' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem Pedido Compra!")
						Endif
						oMulti:aCols[nLinha][nPxPedido]	:=	""
						oMulti:aCols[nLinha][nPxItemPc]	:= 	""
						oMulti:oBrowse:Refresh()
					Endif

					oMulti:aCols[nLinha][nPxUm]			:= SB1->B1_UM
					lFirstUM 	:= Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SB1->B1_UM)) $ SB1->B1_UM .And. (lMadeira .Or. Padr(oMulti:aCols[nLinha,nPxUMNFe],Len(SA5->A5_UNID)) $ SA5->A5_UNID)
					oMulti:aCols[nLinha][nPxQte]    	:=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(lFirstUM,1,Iif(cTpConv =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
					oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
					oMulti:aCols[nLinha][nPxTotal]		:= 	oMulti:aCols[nLinha,nPxTotNfe]
					//oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,sfRetTes(SB1->B1_TE,oMulti:aCols[nLinha,nPxItem],SC7->C7_PRODUTO)) //SC7->C7_TES
					oMulti:aCols[nLinha][nPxD1Tes]		:= 	sfRetTes(SB1->B1_TE,oMulti:aCols[nLinha,nPxItem],SB1->B1_COD,oMulti:aCols[nLinha,nPxD1Oper],lConManual) //SC7->C7_TES
					//oMulti:aCols[nLinha][nPxD1Tes]	:= 	SB1->B1_TE

					// Verifica se é bonificação e força conversão da TES
					If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910" .And. !(Alltrim(oMulti:aCols[nLinha][nPxCF]) $ "1910#2910")
						oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
					Endif
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif

					oMulti:oBrowse:Refresh()

				ElseIf lAutoSC7	.And. !lConfFinal

					If !lMVXPCNFE .And.;
					!Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED .And.;
					(IIf(!Empty(oMulti:aCols[nLinha][nPxCF]),!Alltrim(oMulti:aCols[nLinha][nPxCF]) $ cCFOPNPED,.T.)) .And.;
					(IIf(!Empty(oMulti:aCols[nLinha][nPxD1Tes]),!Alltrim(oMulti:aCols[nLinha][nPxD1Tes]) $ cTESNPED,.T.))
						oMulti:aCols[nLinha][nPxPedido]	:=	""
						oMulti:aCols[nLinha][nPxItemPc]	:= 	""
					Endif
					oMulti:aCols[nLinha][nPxUm]		:= 	SB1->B1_UM
					lFirstUM 	:= Alltrim(oMulti:aCols[nLinha,nPxUMNFe]) $ SB1->B1_UM .And. (lMadeira .Or. Alltrim(oMulti:aCols[nLinha,nPxUMNFe]) $ SA5->A5_UNID)
					oMulti:aCols[nLinha][nPxQte]       :=  oMulti:aCols[nLinha,nPxQteNfe]*Iif(lFirstUM,1,Iif(cTpConv  =="D",Iif(nQteConv<>0,nQteConv,1),Iif(nQteConv<>0,1/nQteConv,1)))
					oMulti:aCols[nLinha][nPxPrunit]		:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],TamSX3("D1_VUNIT")[2])
					oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]
					oMulti:aCols[nLinha][nPxD1Tes]		:= 	sfRetTes(SB1->B1_TE,oMulti:aCols[nLinha,nPxItem],SB1->B1_COD,oMulti:aCols[nLinha,nPxD1Oper],lConManual) //SC7->C7_TES
					//oMulti:aCols[nLinha][nPxD1Tes]		:= 	SB1->B1_TE

					// Verifica se é bonificação e força conversão da TES
					If SF4->(FieldPos("F4_TESBONI")) > 0 .And. Padr(oMulti:aCols[nLinha][nPxCFNFe],4) $ "5910#6910" .And. !(Alltrim(oMulti:aCols[nLinha][nPxCF]) $ "1910#2910")
						oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
					Endif
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
						oMulti:aCols[nLinha,nPxCF]		:= 	cRetCF+Substr(SF4->F4_CF,2,3)
					Endif
					oMulti:oBrowse:Refresh()

				Endif
			Endif

			sfRefLeg(nLinha)

			dbSelectArea("SC7")

		Endif
	Endif

	nTotalNFe := 0
	For iR := 1 To Len(oMulti:aCols)
		If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]
			//nTotalNfe += oMulti:aCols[iR,nPxTotal] - oMulti:aCols[iR,nPxVlDesc] + oMulti:aCols[iR,nPxValDesp]
			nTotalNfe += Round(oMulti:aCols[iR,nPxTotal] +  Iif(!Empty(Alltrim(oMulti:aCols[iR,nPxIdentB6])) .Or. (!Empty(Alltrim(oMulti:aCols[iR,nPxNfOri])) .And. aArqXml[oArqXml:nAt,nPosTpNota] == "B"),oMulti:aCols[iR,nPxValDesp],0) - oMulti:aCols[iR,nPxVlDesc] ,2)
		Endif
	Next
	oTotalNfe:Refresh()

	RestArea(aAreaItOld)

Return lRet


/*/{Protheus.doc} sfRetLocPad
(Função que retorna o Armazém padrão para o produto)
@type function
@author marce
@since 12/05/2016
@version 1.0
@param cInCodPrd, character, (Descrição do parâmetro)
@param cInLocPd, character, (Descrição do parâmetro)
@param cInLocGrv, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRetLocPad(cInCodPrd,cInLocPd,cInLocGrv)

	Local	cRetLoc		:= cInLocPd
	Local	aAreaOld	:= GetArea()
	Local	lDefPrd		:= GetNewPar("XM_B1LOCDF",.T.)
	If Empty(cInLocGrv)
		If Empty(cInCodPrd)
			cAuxLoc	:= "  "
		Else
			cAuxLoc		:= RetFldProd(cInCodPrd,"B1_LOCPAD")
			If Empty(cAuxLoc)
				cAuxLoc	:= Posicione("SB1",1,xFilial("SB1")+cInCodPrd,"B1_LOCPAD") 
			Endif
			// Se o endereço padrão do Produto estiver vazio ou não for o Default usar do Produto, usa o valor passado 
			If Empty(cAuxLoc) .Or. !lDefPrd
				cAuxLoc	:= cInLocPd
			Endif
		Endif
		cRetLoc	:= Padr(cAuxLoc,TamSX3("D1_LOCAL")[1])
	Else
		cRetLoc	:= Padr(cInLocGrv,TamSX3("D1_LOCAL")[1])
	Endif

	RestArea(aAreaOld)

Return cRetLoc



/*/{Protheus.doc} sfRetTes
(Retorna o TES já gravado para o item caso exista)
@author MarceloLauschner
@since 08/12/2012
@version 1.0
@param cInTes, character, (Descrição do parâmetro)
@param cInItem, character, (Descrição do parâmetro)
@param cProduto, character, (Descrição do parâmetro)
@param cTpOper, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRetTes(cInTes,cInItem,cProduto,cTpOper,lConManual)

	Local		aAreaOld1	:= GetArea()
	Local		cTesRet		:= cInTes
	Private		aHeader		:= oMulti:aHeader
	Default 	cInItem		:= ""
	Default		cTpOper		:= cOper
	Default		lConManual	:= .F.

	// Garanto que a variavel sempre tenha um valor, ou via passagem de parametro ou atribuição default
	If Empty(cTpOper)
		cTpOper	:= cOper
	Endif

	U_DbSelArea("CONDORXMLITENS",.F.,2)
	If DbSeek(Padr(aArqXml[oArqXml:nAt,nPosChvNfe],Len(CONDORXMLITENS->XIT_CHAVE))+cInItem)
		// Chamado 7 - Vaccinar - 
		If !Empty(CONDORXMLITENS->XIT_TES) .And. (!lConManual .Or. !Empty(aArqXml[oArqXml:nAt,nPosConfCp]))
			cTesRet	:= CONDORXMLITENS->XIT_TES
		Else
			// Adicionada melhoria em 04/05/2013 que retorna o TES baseado no Tes inteligente
			// O tipo de operação padrão é definido por parametro a ser configurado no Wizard
			cTesRet := MaTesInt(1/*nEntSai*/,cTpOper,cCodForn,cLojForn,If(CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S","F","C")/*cTipoCF*/,cProduto)
			If Empty(cTesRet)
				cTesRet	:= cInTes
			Endif
		Endif
	Else
		// Adicionada melhoria em 04/05/2013 que retorna o TES baseado no Tes inteligente
		// O tipo de operação padrão é definido por parametro a ser configurado no Wizard
		cTesRet := MaTesInt(1/*nEntSai*/,cTpOper,cCodForn,cLojForn,If(CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S","F","C")/*cTipoCF*/,cProduto)
		If Empty(cTesRet)
			cTesRet	:= cInTes
		Endif
	Endif

	RestArea(aAreaOld1)

Return cTesRet


/*/{Protheus.doc} sfRetOper
(Retorna o tipo de operação conforme o cfop do xml)
@author MarceloLauschner
@since 02/08/2015
@version 1.0
@param cInCfopXml, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRetOper(cInCfopXml)

	Local	aAreaOld	:= GetArea()
	Local	cOperRet	:= cOper
	Local	aCF_Oper	:= &(GetNewPar("XM_CFXTPOP","{}"))
	Local	iM
	// Percorre array em busca de Cfop X tipo de operação
	For iM := 1 To Len(aCF_Oper)
		If Alltrim(cInCfopXml) == Alltrim(aCF_Oper[iM,1])
			cOperRet	:= aCF_Oper[iM,2]
			Exit
		Endif
	Next
	RestArea(aAreaOld)

Return cOperRet


/*/{Protheus.doc} sfxMoeda
(Retorna o valor do pedido )
@type function
@author marce
@since 04/05/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfxMoeda(cInCampo)

	Local	aAreaOld	:= GetArea()
	Local	nDecimais	:= TamSx3("C7_PRECO")[2]
	Local	nTaxaMoed	:= RecMoeda(dDataBase,SC7->C7_MOEDA)
	Local	nPrcCompra	:= SC7->C7_PRECO
	Local	cOpcDtMoeda	:= GetNewPar("XM_DTXMOED","3") // 1=DataBase;2=Emissão Pedido;3=Emissão Nota
	Local	dDtXMoeda	:= aArqXml[oArqXml:nAt,nPosDtEmis]
	Default	cInCampo	:= "C7_PRECO"
	
	If cInCampo <> "C7_PRECO"
		nDecimais	:= TamSx3(cInCampo)[2]
	Endif
	If cOpcDtMOeda == "1"
		dDtXMoeda	:= dDataBase
	ElseIf cOpcDtMoeda == "2"
		dDtXMoeda	:= SC7->C7_EMISSAO
	Endif
	
	nTaxaMoed	:= RecMoeda(dDtXMoeda,SC7->C7_MOEDA)
	nPrcCompra 	:= xMoeda(SC7->(&(cInCampo)),SC7->C7_MOEDA,1,dDtXMoeda,nDecimais,Iif(nTaxaMoed==0,SC7->C7_TXMOEDA,0))
	//nPreco := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,M->dDEmissao,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA)

	RestArea(aAreaOld)

Return nPrcCompra



/*/{Protheus.doc} sfRefLeg
(Atualiza o status do item conforme vinculo com pedido de compra)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@param nLinha, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRefLeg(nLinha)

	Local	nPrcDecArd	:= GetNewPar("XM_ARC7PRC",TamSX3("C7_PRECO")[2])
	Local	nQteDecArd	:= GetNewPar("XM_ARC7QTE",TamSX3("C7_QUANT")[2])
	Local	lQteTolNeg	:= GetNewPar("XM_TLC7QTE",.T.) 	// Considera quantidade a menos como divergência  
	Local	lVlrTolNeg	:= GetNewPar("XM_TLC7PRC",.T.) 	// Considera preço a menos como divergência
	// Correção de bug 17/07/2013 - posicionamento de registro do browse além do existente no acols.
	If oMulti:nAt > Len(oMulti:aCols)
		oMulti:nAt	:= Len(oMulti:aCols)
	Endif
	If nLinha > Len(oMulti:aCols)
		oMulti:oBrowse:Refresh()
		Return
	Endif

	If !Empty(oMulti:aCols[nLinha][nPxPedido])
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+oMulti:aCols[nLinha][nPxPedido]+oMulti:aCols[nLinha][nPxItemPc])

			nC7Preco	:= Round(sfxMoeda(),nPrcDecArd)
			nFreeQT 	:= SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA+ Iif(Empty(oMulti:aCols[nLinha,nPxKeySD1]),0,oMulti:aCols[nLinha,nPxQte])
			
			If ((lVlrTolNeg .And. Round(oMulti:aCols[nLinha][nPxPrunit],nPrcDecArd) <> nC7Preco) .Or.;
				(!lVlrTolNeg .And. Round(oMulti:aCols[nLinha][nPxPrunit],nPrcDecArd) > nC7Preco)) .And.;
			  ((lQteTolNeg .And. Round(oMulti:aCols[nLinha,nPxQte],nQteDecArd) <> Round(nFreeQT,nQteDecArd)) .Or.;
			   (!lQteTolNeg .And. Round(oMulti:aCols[nLinha,nPxQte],nQteDecArd) > Round(nFreeQT,nQteDecArd)))
				oMulti:aCols[nLinha,1]	:= oLaranja
			Elseif ((lVlrTolNeg .And. Round(oMulti:aCols[nLinha][nPxPrunit],nPrcDecArd) <> nC7Preco) .Or.;
				(!lVlrTolNeg .And. Round(oMulti:aCols[nLinha][nPxPrunit],nPrcDecArd) > nC7Preco))
				oMulti:aCols[nLinha,1]	:= oAmarelo
			ElseIf ((lQteTolNeg .And. Round(oMulti:aCols[nLinha,nPxQte],nQteDecArd) <> Round(nFreeQT,nQteDecArd)) .Or.;
			   (!lQteTolNeg .And. Round(oMulti:aCols[nLinha,nPxQte],nQteDecArd) > Round(nFreeQT,nQteDecArd)))
				oMulti:aCols[nLinha,1]	:= oAzul
			Else
				oMulti:aCols[nLinha,1]	:= oVerde
			Endif

			/*
			±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
			±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
			±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
			±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
			±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
			±±³          ³ ExpN3 = Preco a receber                                      ³±±
			±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
			±±³          ³ ExpL1 = Exibir Help                                          ³±±
			±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
			±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
			±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
			/*/
			//Return({lBloqueio,nPQtde, nPPreco})
			
			
			aRetAvalTol := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,oMulti:aCols[nLinha,nPxQte],nFreeQT, oMulti:aCols[nLinha][nPxPrunit], nC7Preco)
			If aRetAvalTol[1]
				If GetNewPar("XM_VLDTOLE","N") $ "A"

				ElseIf GetNewPar("XM_VLDTOLE","N") $"B"
					If Empty(CONDORXML->XML_KEYF1)
						sfAtuXmlOk("C9",.T.,oMulti:aCols[nLinha,nPxItem],"%Tolerância Quantidade: "+Transform(aRetAvalTol[2],"@E 999.99")+ CRLF + "%Tolerância Preço: "+Transform(aRetAvalTol[3],"@E 999.99")+ CRLF)
					Endif
				Endif

				If lMadeira .And. Empty(CONDORXML->XML_KEYF1)
					sfAtuXmlOk("C9",.T.,oMulti:aCols[nLinha,nPxItem],"%Tolerância Quantidade: "+Transform(aRetAvalTol[2],"@E 999.99")+ CRLF + " %Tolerância Preço: "+Transform(aRetAvalTol[3],"@E 999.99")+ CRLF)
				Endif
			Endif
		Else
			oMulti:aCols[nLinha,1]	:= oVermelho
		Endif
	Else
		If Empty(oMulti:aCols[nLinha,nPxNfOri])
			oMulti:aCols[nLinha,1]	:= oVermelho
		Else
			oMulti:aCols[nLinha,1]	:= oPreto
		Endif
	Endif
	oMulti:oBrowse:Refresh()
Return


/*/{Protheus.doc} XmlAltPC
(Efetua a chamada da alteração do Pedido de Compra )
@author MarceloLauschner
@since 13/10/2013
@version 1.0
@param nRecSC7, numérico, (Descrição do parâmetro)
@param nOpcSC7, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/

User Function XmlAltPC(nRecSC7,nOpcSC7)

	Local aArea			:= GetArea()
	Local aAreaSC7		:= SC7->(GetArea())
	Local nSavNF		:= MaFisSave()
	Local nBack         := n
	PRIVATE nTipo 		:= 1

	MaFisEnd()

	dbSelectArea("SC7")
	MsGoto(nRecSC7)

	//If nOpcSC7 == 2
	//	A103VisuPC(nRecSC7)
	//Else
	Mata120(1	,/*aCabec*/		,/*aItens*/		, nOpcSC7 	,.T.,/*aRateio*/)
	//Endif
	n := nBack

	MaFisRestore(nSavNF)

	// Seto as teclas de atalho a cada refresh da tela
	sfSetKeys()



	Pergunte(cPergXml,.F.)

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.


/*/{Protheus.doc} stGrvItens
(Efetua a gravaçaõ dos dados de itens na tabela XMLCONDORITENS)
@author MarceloLauschner
@since 20/02/2012
@version 1.0
@param lConfComp, ${param_type}, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function stGrvItens(lConfComp,cInChave)

	Local	aAreaOld		:= GetArea()
	Local	lRetGrv			:= .T.
	Local	nYY,nAuxCNT
	Local 	cTolent			:= GetMV("MV_TOLENT" , .F.,"") 
	Local 	lTolerNeg 		:= GetNewPar("MV_TOLENEG",.F.)
	Local	cMsgTol			:= ""
	Default	lConfComp		:= .F.
	Default	cInChave		:= aArqXml[oArqXml:nAt,nPosChvNfe]

	ProcRegua(Len(oMulti:aCols))

	For nYY	:= 1 To Len(oMulti:aCols)
		IncProc()
		If !oMulti:aCols[nYY][Len(oMulti:aHeader)+1]
			U_DbSelArea("CONDORXMLITENS",.F.,1)

			If DbSeek(Padr(cInChave,Len(CONDORXMLITENS->XIT_CHAVE)) + Padr(oMulti:aCols[nYY][nPxCodNfe],Len(CONDORXMLITENS->XIT_CODNFE)) + Padr(oMulti:aCols[nYY][nPxItem],Len(CONDORXMLITENS->XIT_ITEM)))
				RecLock("CONDORXMLITENS",.F.)
			Else
				RecLock("CONDORXMLITENS",.T.)
				CONDORXMLITENS->XIT_CHAVE		:= cInChave	//aArqXml[oArqXml:nAt,nPosChvNfe]
				CONDORXMLITENS->XIT_ITEM		:= oMulti:aCols[nYY][nPxItem]
				CONDORXMLITENS->XIT_CODNFE		:= oMulti:aCols[nYY][nPxCodNfe]
				CONDORXMLITENS->XIT_DESCRI		:= oMulti:aCols[nYY][nPxDescri]
			Endif


			CONDORXMLITENS->XIT_CODPRD	:= oMulti:aCols[nYY,nPxProd]
			CONDORXMLITENS->XIT_QTE		:= oMulti:aCols[nYY,nPxQte]
			CONDORXMLITENS->XIT_UM		:= oMulti:aCols[nYY,nPxUm]
			CONDORXMLITENS->XIT_PRUNIT	:= oMulti:aCols[nYY,nPxPrunit]
			CONDORXMLITENS->XIT_TOTAL	:= oMulti:aCols[nYY,nPxTotal]
			CONDORXMLITENS->XIT_TES		:= oMulti:aCols[nYY,nPxD1Tes]
			CONDORXMLITENS->XIT_CF		:= oMulti:aCols[nYY,nPxCF]
			CONDORXMLITENS->XIT_PEDIDO	:= oMulti:aCols[nYY,nPxPedido]
			CONDORXMLITENS->XIT_ITEMPC	:= oMulti:aCols[nYY,nPxItemPc]
			CONDORXMLITENS->XIT_LOCAL	:= oMulti:aCols[nYY,nPxLocal]
			// Gravação dos demais campos da tabela adicionado em 10/12/2012 por causa da melhoria que permite fracionar uma quantidade
			CONDORXMLITENS->XIT_QTENFE  := oMulti:aCols[nYY,nPxQteNfe]
			CONDORXMLITENS->XIT_UMNFE   := oMulti:aCols[nYY,nPxUMNFe]
			CONDORXMLITENS->XIT_PRCNFE  := oMulti:aCols[nYY,nPxPrcNfe]
			CONDORXMLITENS->XIT_TOTNFE  := oMulti:aCols[nYY,nPxTotNfe]
			CONDORXMLITENS->XIT_OPER	:= oMulti:aCols[nYY,nPxD1Oper]
			CONDORXMLITENS->XIT_CFNFE   := oMulti:aCols[nYY,nPxCFNFe]
			CONDORXMLITENS->XIT_VALDES  := oMulti:aCols[nYY,nPxValDesc]
			CONDORXMLITENS->XIT_BASICM  := oMulti:aCols[nYY,nPxBasIcm]
			CONDORXMLITENS->XIT_PICM    := oMulti:aCols[nYY,nPxPicm]
			CONDORXMLITENS->XIT_VALICM  := oMulti:aCols[nYY,nPxValIcm]
			CONDORXMLITENS->XIT_BASIPI  := oMulti:aCols[nYY,nPxBasIpi]
			CONDORXMLITENS->XIT_PIPI    := oMulti:aCols[nYY,nPxPIpi]
			CONDORXMLITENS->XIT_VALIPI  := oMulti:aCols[nYY,nPxValIpi]
			CONDORXMLITENS->XIT_BASPIS  := oMulti:aCols[nYY,nPxBasPis]
			CONDORXMLITENS->XIT_PPIS    := oMulti:aCols[nYY,nPxPPis]
			CONDORXMLITENS->XIT_VALPIS  := oMulti:aCols[nYY,nPxValPis]
			CONDORXMLITENS->XIT_BASCOF  := oMulti:aCols[nYY,nPxBasCof]
			CONDORXMLITENS->XIT_PCOF    := oMulti:aCols[nYY,nPxPCof]
			CONDORXMLITENS->XIT_VALCOF  := oMulti:aCols[nYY,nPxValCof]
			CONDORXMLITENS->XIT_BASRET  := oMulti:aCols[nYY,nPxBasRet]
			CONDORXMLITENS->XIT_PMVA    := oMulti:aCols[nYY,nPxMva]
			CONDORXMLITENS->XIT_PICMST	:= oMulti:aCols[nYY,nPxPICMSST]
			CONDORXMLITENS->XIT_VALRET  := oMulti:aCols[nYY,nPxIcmRet]
			CONDORXMLITENS->XIT_CLASFI  := oMulti:aCols[nYY,nPxCST]
			CONDORXMLITENS->XIT_NCM     := oMulti:aCols[nYY,nPxNcm]
			CONDORXMLITENS->XIT_DIBCIM  := oMulti:aCols[nYY,nPxDiBc]
			CONDORXMLITENS->XIT_DIVLII  := oMulti:aCols[nYY,nPxDiVII]
			CONDORXMLITENS->XIT_CSTORI	:= oMulti:aCols[nYY,nPxXITCST]
			CONDORXMLITENS->XIT_LOTCTL	:= oMulti:aCols[nYY,nPxLoteCtl]
			CONDORXMLITENS->XIT_NUMLOT	:= oMulti:aCols[nYY,nPxNumLote]
			CONDORXMLITENS->XIT_LOTFOR	:= oMulti:aCols[nYY,nPxLoteFor]
			CONDORXMLITENS->XIT_DFABRI	:= oMulti:aCols[nYY,nPxDtFabric]
			CONDORXMLITENS->XIT_DTVALD	:= oMulti:aCols[nYY,nPxVldLtFor]
			If nPxFciCod > 0
				CONDORXMLITENS->XIT_FCICOD	:= oMulti:aCols[nYY,nPxFciCod]
			Endif
			CONDORXMLITENS->XIT_KEYSD1	:= oMulti:aCols[nYY,nPxKeySD1]
			CONDORXMLITENS->XIT_CICMSN	:= oMulti:aCols[nYY,nPxCrdIcmSN]
			CONDORXMLITENS->XIT_PICMSN	:= oMulti:aCols[nYY,nPxPIcmSN]
			CONDORXMLITENS->XIT_VALFRE	:= oMulti:aCols[nYY,nPxValFre]
			CONDORXMLITENS->XIT_DESPES	:= oMulti:aCols[nYY,nPxValDesp]
			CONDORXMLITENS->XIT_SEGURO	:= oMulti:aCols[nYY,nPxValSeg]
			If nPxCodBar > 0
				CONDORXMLITENS->XIT_CODBAR	:= oMulti:aCols[nYY,nPxCodBar]				// 58 Codigo Barras
			Endif
			If nPxCodCest > 0
				CONDORXMLITENS->XIT_CEST	:= oMulti:aCols[nYY,nPxCodCest]			// 62 Código CEST
			Endif	
			If nPxBRetAnt > 0
				CONDORXMLITENS->XIT_BRETAN	:= oMulti:aCols[nYY,nPxBRetAnt]			// 63 Base St Retido anteriormente
			Endif	
			If nPxVRetAnt > 0
				CONDORXMLITENS->XIT_VRETAN	:= oMulti:aCols[nYY,nPxVRetAnt]			// 64 Valor St Retido Anteriomente
			Endif	
			
			MsUnLock()

			// Melhoria implementada em 12/07/2012 para analisar durante a Conf.compras se há produtos sem pedido de compra vinculado
			/*If  lConfComp .And.;
			lMVXPCNFE .And.;
			aArqXml[oArqXml:nAt,nPosTpNota] == "N" .And.;
			!Alltrim(oMulti:aCols[nYY][nPxCFNFe]) $ cCFOPNPED .And.;
			(IIf(!Empty(oMulti:aCols[nYY][nPxCF]),!Alltrim(oMulti:aCols[nYY][nPxCF]) $ cCFOPNPED,.T.))	.And.;
			(IIf(!Empty(oMulti:aCols[nYY][nPxD1Tes]),!Alltrim(oMulti:aCols[nYY][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
			(Empty(oMulti:aCols[nYY,nPxPedido]) .Or. Empty(oMulti:aCols[nYY,nPxItemPC]) )
			lRetGrv	:= .F.
			If lAutoExec
			sfAtuXmlOk("C8",.T.,oMulti:aCols[nYY,nPxItem])
			Else
			sfAtuXmlOk("C8",.T.,oMulti:aCols[nYY,nPxItem])
			MsgAlert("Não há pedido de compra vinculado para o Item/Produto '"+oMulti:aCols[nYY][nPxItem]+"/"+oMulti:aCols[nYY,nPxProd]+"' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pedido obrigatório")
			Endif
			Endif*/

			If lConfComp .And.;
			lMVXPCNFE .And. ;
			!Alltrim(oMulti:aCols[nYY][nPxCFNFe]) $ cCFOPNPED .And.;
			(IIf(!Empty(oMulti:aCols[nYY][nPxCF]),!Alltrim(oMulti:aCols[nYY][nPxCF]) $ cCFOPNPED,.T.)) .And.;
			(IIf(!Empty(oMulti:aCols[nYY][nPxD1Tes]),!Alltrim(oMulti:aCols[nYY][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
			!CONDORXML->XML_TIPODC $ "C#I#P"
				DbSelectArea("SC7")
				DbSetOrder(1)
				If DbSeek(xFilial("SC7")+oMulti:aCols[nYY][nPxPedido]+oMulti:aCols[nYY][nPxItemPc])

					// Verifica saldo do item real
					nFreeQT		:= 0
					cVar		:= SC7->C7_PRODUTO
					cItemPc		:= SC7->C7_ITEM
					cPedido     := SC7->C7_NUM
					BeginSql Alias "QXIT"

					SELECT XIT_QTE
					FROM CONDORXMLITENS XI,CONDORXML XM
					WHERE XM.%NotDel%
					AND XML_KEYF1 = '  '
					AND XML_CONFCO <> '  '
					AND XML_CHAVE = XIT_CHAVE
					AND XIT_CHAVE <> %Exp:aArqXml[oArqXml:nAt,nPosChvNfe]%
					AND XIT_CODPRD = %Exp:cVar%
					AND XIT_ITEMPC = %Exp:cItemPc%
					AND XIT_PEDIDO = %Exp:cPedido%
					AND XI.%NotDel%
					EndSql

					While !Eof()
						nFreeQT += QXIT->XIT_QTE
						QXIT->(DbSkip())
					Enddo
					QXIT->(DbCloseArea())

					For nAuxCNT := 1 To Len( oMulti:aCols )
						If (nAuxCNT # nYY) .And. ;
						(oMulti:aCols[ nAuxCNT,nPxProd ] == SC7->C7_PRODUTO) .And. ;
						(oMulti:aCols[ nAuxCNT,nPxPedido ] == SC7->C7_NUM) .And. ;
						(oMulti:aCols[ nAuxCNT,nPxItemPc ] == SC7->C7_ITEM) .And. ;
						!ATail( oMulti:aCols[ nAuxCNT ] ) .And. !oMulti:aCols[nAuxCNT,Len(oMulti:aHeader)+1]
							nFreeQT += oMulti:aCols[ nAuxCNT,nPxQte ]
						EndIf
					Next
					/*
					±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
					±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
					±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
					±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
					±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
					±±³          ³ ExpN3 = Preco a receber                                      ³±±
					±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
					±±³          ³ ExpL1 = Exibir Help                                          ³±±
					±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
					±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
					±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
					/*/
					nC7Preco	:= sfxMoeda()
					nFreeQT := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA-nFreeQT
					aMaAval := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,oMulti:aCols[nYY,nPxQte],nFreeQT,oMulti:aCols[nYY][nPxPrunit],nC7Preco,.F./*lHelp*/,.T./* lQtde*/, .T./*lPreco*/)
					If aMaAval[1]
						// 16/07/2017 - Melhoria feita para avisar sobre o prazo de tolerância de entrega
						If cTolent $ "1#2#3" 
							cMsgTol := CRLF + "Tolerância Entrega: " 
							If cTolent == "1"
								cMsgTol += "(1) Atrasos"
							ElseIf cTolent == "2" 
								cMsgTol	+= "(2)Antecipacoes "
							ElseIf cTolent == "3"
								cMsgTol	+= "(3)Ambos"
							Endif
							cMsgTol += " Data Prevista: " + DTOC(SC7->C7_DATPRF) + CRLF 
						Endif
						If lTolerNeg
							cMsgTol	+= "Parâmetro 'MV_TOLENEG' ativado!" 
						Endif
						
						If GetNewPar("XM_VLDTOLE","N") $ "A"
							MsgAlert("A Quantidade ou Preço digitados estão divergentes com o pedido de compra." + CRLF +;
							"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nYY][nPxDescri] + "'" + CRLF +;
							"Qte disponível no pedido: " + Transform(nFreeQT,PesqPict("SC7","C7_QUANT"))  + CRLF +;
							"Qte na nota: " + Transform(oMulti:aCols[nYY,nPxQteNfe],PesqPict("SD1","D1_QUANT"))  + CRLF +;
							"Qte Convertida: " + Transform(oMulti:aCols[nYY,nPxQte],PesqPict("SD1","D1_QUANT"))  + CRLF +;
							"Preço no pedido: " + Transform(nC7Preco,PesqPict("SC7","C7_PRECO"))  + CRLF +;
							"Preço na nota: " + Transform(oMulti:aCols[nYY,nPxPrcNfe],PesqPict("SD1","D1_VUNIT"))  + CRLF +;
							"Preço Convertido: " + Transform(oMulti:aCols[nYY,nPxPrunit],PesqPict("SD1","D1_VUNIT"))  + CRLF +;
							"% Tolerância Quantidade: " + Transform(aMaAval[2],"@E 999.99") + CRLF +;
							"% Tolerância Preço: " + Transform(aMaAval[3],"@E 999.99") + ;
							cMsgTol,;
							ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")
							// Somente
						ElseIf GetNewPar("XM_VLDTOLE","N") $"B"
							MsgAlert("A Quantidade ou Preço digitados estão divergentes com o pedido de compra." + CRLF +;
							"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nYY][nPxDescri] + "'" + CRLF +;
							"Qte disponível no pedido: " + Transform(nFreeQT,PesqPict("SC7","C7_QUANT"))  + CRLF +;
							"Qte na nota: " + Transform(oMulti:aCols[nYY,nPxQteNfe],PesqPict("SD1","D1_QUANT"))  + CRLF +;
							"Qte Convertida: " + Transform(oMulti:aCols[nYY,nPxQte],PesqPict("SD1","D1_QUANT"))  + CRLF +;
							"Preço no pedido: " + Transform(nC7Preco,PesqPict("SC7","C7_PRECO"))  + CRLF +;
							"Preço na nota: " + Transform(oMulti:aCols[nYY,nPxPrcNfe],PesqPict("SD1","D1_VUNIT"))  + CRLF +;
							"Preço Convertido: " + Transform(oMulti:aCols[nYY,nPxPrunit],PesqPict("SD1","D1_VUNIT"))  + CRLF +;
							"% Tolerância Quantidade: " + Transform(aMaAval[2],"@E 999.99") + CRLF +;
							"% Tolerância Preço: " + Transform(aMaAval[3],"@E 999.99")+;
							cMsgTol,;
							ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")
							lRetGrv	:= .F.
						Endif
					Endif


				Else
					lRetGrv	:= .F.
					If lAutoExec
						sfAtuXmlOk("C8",.T.,oMulti:aCols[nYY,nPxItem])
					Else
						sfAtuXmlOk("C8",.T.,oMulti:aCols[nYY,nPxItem])
						MsgAlert("Não há pedido de compra vinculado para o Item/Produto '"+oMulti:aCols[nYY][nPxItem]+"/"+oMulti:aCols[nYY,nPxProd]+"' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pedido obrigatório")
					Endif
				Endif
			Endif
		Else
			U_DbSelArea("CONDORXMLITENS",.F.,1)
			If DbSeek(Padr(cInChave,Len(CONDORXMLITENS->XIT_CHAVE)) + Padr(oMulti:aCols[nYY][nPxCodNfe],Len(CONDORXMLITENS->XIT_CODNFE)) + Padr(oMulti:aCols[nYY][nPxItem],Len(CONDORXMLITENS->XIT_ITEM)))
				RecLock("CONDORXMLITENS",.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif
	Next
	If lConfComp .And. !lAutoExec
		MsgAlert("Gravação dos itens concluída!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Processo concluído")
	Endif

	RestArea(aAreaOld)

Return lRetGrv


/*/{Protheus.doc} stGeraNfe
(Efetua a carga dos vetores para o lançamento do Doc Entrada)

@author Marcelo Lauschner
@since 15/01/2014
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stGeraNfe()

	Local		aAreaOld		:= GetArea()
	Local		lPreNfe			:= .F.
	Local		cItemD1			:= StrZero(1,TamSX3("D1_ITEM")[1])
	Local		cTipoBox		:= "N"
	Local		lContinua		:= 	.F.
	Local		lExistSC7		:= .F.
	Local		lGrvCte			:= .F.	// Flag que diferencia se a rotina terá gravação de CTE´s
	Local		cAviso			:= ""
	Local		cErro			:= ""
	Local		lCheck 			:= .T.
	Local		lForcePreNf		:= .F. 	// Força o lançamento como pré-nota se a nota fiscal não possuir TES alocada para qualquer item
	Local		lExistB1		:= .T.
	Local		nTotDespesa		:= 0
	Local		nTotSeguro		:= 0
	Local		nTotFrete		:= 0
	Local	 	cTpFretePed		:= ""
	Local		cC7Transp		:= ""
	Local		cF1Transp		:= ""
	Local		cInscricao		:= ""
	Local		cUfCad			:= ""
	Local		cVldCfop		:= ""
	Local		nSumF1Descont	:= 0
	Local		nSumF1Seguro	:= 0
	Local		nSumF1Despesa	:= 0
	Local		nSumF1Frete		:= 0
	Local		cD1Descri		:= GetNewPar("XM_CPD1DES","D1_DESCRI")
	Local		cD1BRetAnt		:= GetNewPar("XM_CPD1BRT","") // Campo para informar a Base do ST retido Anteriormente
	Local		cD1VRetAnt		:= GetNewPar("XM_CPD1VRT","") // Campo para informar o Valor do ST retido anteriormente
	Local		lAddD1Descri	:= .F.
	Local		lVdlNcm			:= GetNewPar("XM_VLDNCM",.F.)
	Local		cParcela		:= " "
	Local		iW,nX
	Local		nForA,nForB,nForC,nForD,nForE,nForF,nForG,nForH		
	Local		lTemNFOri		:= .F. 
	Local		lAtuIECad		:= .F.
	Private 	nIX
	Private		cChave			:= ""
	Private		oNfe
	Private		aCabec 			:= {}
	Private		aItems 			:= {}
	Private 	aLinha			:= {}
	Private		lMsErroAuto		:=.F.
	Private		lMsHelpAuto		:= lAutoExec	//.F.
	Private 	cCondicao		:= Space(TamSX3("F1_COND")[1])
	Private 	aValCond		:= {0,0,0,CTOD(""),""} // 1 - Valor Total , 2 - Valor IPI , 3 - Valor Solidário , 4 - Emissão NF , 5 - Numero Nota
	Private 	cNatFin			:= Space(TamSX3("E2_NATUREZ")[1])
	Private 	cNumDoc			:= ""
	Private 	cSerDoc			:= ""
	Private 	dData
	Private 	aInfIcmsCte		:= {}
	Private 	cF1Placa		:= Space(TamSX3("F1_PLACA")[1]) // 17/07/2017 cria variável para uso em PE SF1140I alimentar Placa Veículo


	//Fields HEADER " ",;    		// 1
	//"Série/Nº NF-e",;      		// 2
	//"Emissão",;    		   		// 3
	//"Fornecedor/Loja-Nome",;    	// 4
	//"Chave NF-e",;              	// 5
	//"Destinatário",;            	// 6
	//"Recebida em",;				// 7
	//"Conferida em",;				// 8
	//"Lançada em" ;				// 9

	If !Empty(CONDORXML->XML_TPNF) .And. (CONDORXML->XML_TPNF == "0" .And. !aArqXml[oArqXml:nAt,nPosTpNota] $ "F#T")
		If !lAutoExec
			//MsgAlert("Nota fiscal do tipo 0=Entrada e emitida pelo fornecedor. Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
			ShowHelpDlg(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!",;
			{"Nota fiscal do tipo 0=Entrada e emitida pelo",;
			 "fornecedor/cliente.Não é permitido lançar!"},;
			5,;
			{"XML de Documento de Entrada emitido por ",;
			 "terceiros. XML apenas para arquivamento!"},;
			5) 
			
			sfAtuXmlOk("ET")
		Else
			sfAtuXmlOk("ET")
		Endif
		Return .F.
	Endif


	// Efetua validação impedindo que produto não cadastrado tenha continuidade
	For nForA := 1 To Len(oMulti:aCols)
		nI := nForA
		If Type("oMulti:aCols[nI,nPxProd]") =="C"
		 	// Se a linha estiver deletada não valida
		 	If oMulti:aCols[nI,Len(oMulti:aHeader)+1]
		 		Loop
		 	Endif
		 	
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SB1")+oMulti:aCols[nI,nPxProd])
				If !lAutoExec
					sfAtuXmlOk("B1",.T.,oMulti:aCols[nI,nPxItem])
					MsgAlert("Não há Referência Protheus informada para a linha "+Str(nI),ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação de dados antes do lançamento")
				Else
					sfAtuXmlOk("B1",.T.,oMulti:aCols[nI,nPxItem])
				Endif
				lExistB1  := .F.
			Else

				If lVdlNcm .And. !Empty(oMulti:aCols[nI,nPxNCM]) .And. !Empty(oMulti:aCols[nI,nPxProd])
					// Efetua a atualização do NCM do produto
					If Empty(SB1->B1_POSIPI) .and. !Empty(oMulti:aCols[nI,nPxNCM]) .and. oMulti:aCols[nI,nPxNCM] != '00000000'
						RecLock("SB1",.F.)
						Replace B1_POSIPI with oMulti:aCols[nI,nPxNCM]
						MSUnLock()
					Endif

					// Efetuo validação que envia email ao Departamento Fiscal informando sobre diferença no cadastro do NCM do Produto
					If Alltrim(SB1->B1_POSIPI)  <> "00000000" .And. Alltrim(SB1->B1_POSIPI) <> Alltrim( oMulti:aCols[nI,nPxNCM] )

						//cRecebe		:= Alltrim(GetMv("XM_MAILXML"))	// Destinatarios de email do lançamento da nota
						// Mudança de destinatários criado em 26/07/2013
						// Todas as pessoas com perfil de escrita fiscal irão receber o aviso de divergencia de NCM.
						cRecebe	:= ""
						cRecebe	:= StrTran(Iif(File("xmusrxmln_"+cEmpAnt+".usr"),MemoRead("xmusrxmln_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLN","")),"/","#")	// Muda pra #
						cRecebe	:= StrTran(cRecebe,";","#")
						cRecebe	:= StrTran(cRecebe,"|","#")
						cRecebe	:= StrTran(cRecebe," ","#")
						cRecebe	:= StrTran(cRecebe,"-","#")
						cRecebe	:= StrTran(cRecebe,"\","#")
						aOutMails	:= StrTokArr(cRecebe,"#")
						cRecebe	:= ""
						For iW := 1 To Len(aOutMails)
							If iW > 1
								cRecebe += ";"
							Endif
							cRecebe	+= Alltrim(UsrRetMail(aOutMails[iW]))
						Next
						// Regra para enviar ao cliente notificação sobre diferença no cadastro do NCM em relação ao sistema da Empresa

						cAssunto 	:= "Divergência NCM do Produto '"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC)+" na Empresa:"+ cEmpAnt+"/"+cFilAnt+" " +Capital(SM0->M0_NOMECOM)
						cMensagem	:= "Produto  :"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC) + CRLF
						cMensagem	:= "Validação de stGeraNFe" + CRLF
						cMensagem	+= "Empresa  :"+cEmpAnt+"/"+cFilAnt+" " +Capital(SM0->M0_NOMECOM) + CRLF
						cMensagem	+= "NCM Atual:"+Alltrim(SB1->B1_POSIPI) + CRLF
						cMensagem	+= "NCM XML  :"+oMulti:aCols[nI,nPxNCM] + CRLF
						cMensagem	+= "NF-e Nº  :"+Alltrim(aArqXml[oArqXml:nAt,2]) + CRLF

						If aArqXml[oArqXml:nAt,nPosTpNota]=="D"

							U_DbSelArea("CONDORXML",.F.,1)
							If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
								MsgAlert("Erro ao localizar registro",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
								ConOut("+"+Replicate("-",98)+"+")
								ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
								ConOut("+"+Replicate("-",98)+"+")

								Return .F.
							Endif
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
							If SA1->(FieldPos(GetNewPar("XM_CA1MAIL",""))) > 0
								If !Empty(&("SA1->"+GetNewPar("XM_CA1MAIL","")))
									cRecebe	+= ";"+&("SA1->"+GetNewPar("XM_CA1MAIL",""))
								Endif
							ElseIf !Empty(SA1->A1_EMAIL)
								cRecebe += ";"+SA1->A1_EMAIL
							Endif
							cMensagem	+= "Devolução do cliente  :"+ SA1->A1_COD+"/"+SA1->A1_LOJA + " " +Capital(SA1->A1_NOME) + CRLF

						Endif




						U_DbSelArea("CONDORXML",.F.,1)
						DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])

						If aArqXml[oArqXml:nAt,nPosTpNota] == "N"
							DbSelectArea("SA2")
							DbSetOrder(1)
							If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
								// Criar campo A2_BLQNCM - Caracter Tamanho 1 - Bloq.NFe p/NCM Divergente  1=Sim;2=Não
								If SA2->(FieldPos("A2_BLQNCM")) > 0
									If SA2->A2_BLQNCM $ "1# "
										If Alltrim( Substr(SB1->B1_POSIPI,1,4 ) ) <> Alltrim(Substr(oMulti:aCols[nI,nPxNCM],1,4 ) )
											sfAtuXmlOk("NC",.T.,oMulti:aCols[nI,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nI,nPxNCM])
											//stSendMail( cRecebe, cAssunto, cMensagem )
										ElseIf Alltrim( Substr(SB1->B1_POSIPI,1,6 ) ) <> Alltrim(Substr(oMulti:aCols[nI,nPxNCM],1,6 ) )
											sfAtuXmlOk("NC",.T.,oMulti:aCols[nI,nPxItem],cMensagem,,,.F.,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nI,nPxNCM])
											//stSendMail( cRecebe, cAssunto, cMensagem )
										Endif
									Endif
								Else
									sfAtuXmlOk("NC",.T.,oMulti:aCols[nI,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nI,nPxNCM])
									//stSendMail( cRecebe, cAssunto, cMensagem )
									If lAutoExec
										lExistB1	:= .F.
									Endif
								Endif
							Endif
							cMensagem	+= "Fornecedor :"+ SA2->A2_COD+"/"+SA2->A2_LOJA + " " +Capital(SA2->A2_NOME) + CRLF
						Else
							sfAtuXmlOk("NC",.T.,oMulti:aCols[nI,nPxItem],cMensagem,,,,cAssunto,cRecebe,"B1_POSIPI",SB1->B1_POSIPI,oMulti:aCols[nI,nPxNCM])
							//stSendMail( cRecebe, cAssunto, cMensagem )
							If lAutoExec
								lExistB1	:= .F.
							Endif
						Endif

						// Atribuo o valor do NCM do cadastro do Produto ao conteudo para evitar que a mensagem seja enviada varias vezes
						oMulti:aCols[nI,nPxNCM]  := Alltrim(SB1->B1_POSIPI)

					Endif
				Endif
			Endif
		Endif
	Next nForA 

	// Atribui o erro só no final, permitindo que se há vários itens com erro de produto, todos sejam notificados
	// Melhoria feita em 13/10/2013
	If !lExistB1
		RestArea(aAreaOld)
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		ConOut("+"+Replicate("-",98)+"+")

		Return .F.
	Endif



	If Len(aArqXml) <= 0
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		ConOut("+"+Replicate("-",98)+"+")

		Return .F.
	Endif

	U_DbSelArea("CONDORXML",.F.,1)

	If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
		If !lAutoExec
			MsgAlert("Erro ao localizar registro",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		ConOut("+"+Replicate("-",98)+"+")

		Return .F.
	Endif

	// Verifica se está ativa a validação de CFOPs ( DE/PARA )
	// Adicionado em 07/11/2013
	If GetNewPar("XM_VLDCFOP",.F.)
		// Chama função que valida CFOPs
		If !sfVldCfop(@cVldCfop)
			If !lAutoExec
				MsgAlert("Existe um erro de conversão de CFOPs do XML com o CFOP de entrada que impede a continuação do lançamento! "+ Chr(13)+cVldCfop,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Paramêtro 'XM_VLDCFOP' ativado")
			Endif
			ConOut("+"+Replicate("-",98)+"+")
			ConOut("|Parametro 'XM_VLDCFOP' ativado" + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			ConOut("+"+Replicate("-",98)+"+")

			Return .F.
		Endif
	Else
		If !sfVldCfop(@cVldCfop)
			If !lAutoExec
				MsgAlert("Existe um erro de conversão de CFOPs do XML com o CFOP de entrada!"+ Chr(13)+cVldCfop,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência de CFOP!")
			Endif
		Endif
	Endif



	// Garante que se o XML tem algum bloqueio não será lançada
	// 31/10/2013
	If lAutoExec .And. !Empty(CONDORXML->XML_OK)
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		ConOut("+"+Replicate("-",98)+"+")
		Return .F.
	Endif

	If !Empty(CONDORXML->XML_REJEIT)
		If !lAutoExec
			MsgAlert("Nota fiscal rejeitada em "+DTOC(CONDORXML->XML_REJEIT)+". Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
			sfAtuXmlOk("RJ")
		Else
			sfAtuXmlOk("RJ")
		Endif
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(Padr("|Nota fiscal rejeitada em "+DTOC(CONDORXML->XML_REJEIT)+". Não é permitido lançar!" + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) ,59)+"|",)
		ConOut("+"+Replicate("-",98)+"+")
		Return .F.
	Endif



	// Se estiver selecionada para a forma de lançamento em Lote, chama o ExecAuto para gravação dos CTEs
	For nForB := 1 To Len(aArqxml)
		If aArqXml[nForB,nPosOkCte]
			lGrvCte	:= .T.
		Endif
	Next nForB

	If lGrvCte
		If !lAutoExec
			If MsgYesNo("Deseja realmente efetuar o lançamento dos CTE´s selecionados?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Inclusão por lote")
				Processa( {|| sfGrvCte()} ,"Gerando documentos")
				Eval(bRefrXmlF)
			Endif
		Else
			sfGrvCte()
			Eval(bRefrXmlF)
		Endif

		Return .T.
	Endif


	// Se passou pela leitura de CTE sobre Vendas, irá avaliar se é CTE sobre compras
	If aArqXml[oArqXml:nAt,nPosTpNota] $ "F#T"
		If !lAutoExec
			sfMata116()
			Return .T.
		Else
			// Garante reposicionamento
			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
			sfAtuXmlOk("FC")  		 // Frete sobre compras ainda não gera automatico
		Endif
		ConOut("+"+Replicate("-",98)+"+")
		ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		ConOut("+"+Replicate("-",98)+"+")

		Return .F.
	Endif

	If CONDORXML->XML_TIPODC <> "S"
		cAviso	:= ""
		cErro	:= ""
		oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)
	
	
		If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
			oNF	:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_NFe
		ElseIf Type("oNFe:_NfeProc:_NFe") <> "U"
			oNF := oNFe:_NFeProc:_NFe
		ElseIf Type("oNFe:_NFe")<> "U"
			oNF := oNFe:_NFe
		ElseIf Type("oNFe:_InfNfe")<> "U"
			oNF := oNFe
		ElseIf Type("oNFe:_NfeProc:_nfeProc:_NFe") <> "U"
			oNF := oNFe:_nfeProc:_NFeProc:_NFe
		Else
			cAviso	:= ""
			cErro	:= ""
			oNfe := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)
			If Type("oNFe:_NfeProc")<> "U"
				oNF := oNFe:_NFeProc:_NFe
			ElseIf Type("oNFe:_Nfe")<> "U"
				oNF := oNFe:_NFe
			Else
				If !lAutoExec
					sfAtuXmlOk("E1")
					MsgAlert("Erro ao ler xml "+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Else
					sfAtuXmlOk("E1")
				Endif
				ConOut("+"+Replicate("-",98)+"+")
				ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				ConOut("+"+Replicate("-",98)+"+")
	
				Return .F.
			Endif
		Endif
	
		If !Empty(cErro)
			If !lAutoExec
				sfAtuXmlOk("E2")
				MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Else
				sfAtuXmlOk("E2")
			Endif
			ConOut("+"+Replicate("-",98)+"+")
			ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			ConOut("+"+Replicate("-",98)+"+")
	
			Return .F.
		Endif
	
		oIdent     	:= oNF:_InfNfe:_IDE
		oEmitente  	:= oNF:_InfNfe:_Emit
		If  Type("oNF:_InfNfe:_Dest") <> "U"
			oDestino   	:= oNF:_InfNfe:_Dest
		Endif
		oTotal		:= oNF:_InfNfe:_Total
		oTransp		:= oNF:_InfNfe:_Transp
		If Type("oNF:_InfNfe:_Cobr") <> "U"
			oCobr		:= oNF:_InfNfe:_Cobr
		Endif
	
		If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_protNFe:_infProt:_chNFe") <> "U"
			cChave := oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_protNFe:_infProt:_chNFe:TEXT
		ElseIf Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
			oNF 	:= oNFe:_NFeProc:_NFe
			cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
		ElseIf !Empty( NfeIdSPED(CONDORXML->XML_ARQ,"Id"))
			cChave	:= Substr(NfeIdSPED(CONDORXML->XML_ARQ,"Id"),4,44)
		Else
			cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,nTmF1Ser) + Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
		Endif
	
		// Zero variável mesmo que não tenha a tag de cobrança no xml
		aDupSE2		:= {}
		aDupAxSE2	:= {}
		lDupSE4		:= .F.
	
		If Type("oCobr:_dup") <> "U"
			// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
			nSumSE2		:= 0
			oDup  		:= oCobr:_dup
			oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
			lOnlyDup	:= Len(oDup) == 1
			For nForC := 1 To Len(oDup)
				nP := nForC
				If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
					dVencPXml	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
					If lMadeira
						// Se a data de vencimento do título for menor que a database irá assumir a database como vencimento
						If dVencPXml < dDataBase
							dVencPXml	:= DataValida(dDataBase)
						Endif
					Endif
					Aadd(aDupSE2,{	dVencPXml	,;	// Data Vencimento
					Val(oDup[nP]:_vDup:TEXT)})		// Valor da Duplicata})
					nSumSE2		+= Val(oDup[nP]:_vDup:TEXT)
					U_DbSelArea("CONDORXMLDUPL",.F.,1)
	
					If lOnlyDup
						cParcela := " "
					Else
						cParcela := IF(nP>1,MaParcela(cParcela),IIF(Empty(cParcela),"A",cParcela))
					Endif
					// Verificou que a chave j[a existe na base
	
					lExistParc := !DbSeek(cChave + cParcela)
					RecLock("CONDORXMLDUPL",lExistParc)
					CONDORXMLDUPL->XDP_CHAVE	:= cChave
					CONDORXMLDUPL->XDP_PARCEL	:= cParcela
					CONDORXMLDUPL->XDP_VENCTO	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
					CONDORXMLDUPL->XDP_VALOR	:= Val(oDup[nP]:_vDup:TEXT)
					MsUnlock()
				Endif
			Next nForC
		Endif
	Else
		cChave	:= CONDORXML->XML_CHAVE
	Endif
	
	// Valido se esta empresa/filial certa conforme destinatário do XML
	If SM0->M0_CGC <> CONDORXML->XML_DEST
		If !lAutoExec
			sfAtuXmlOk("E3")
			MsgAlert("Empresa errada! Destinatário é diferente do CNPJ do XML("+CONDORXML->XML_DEST+").",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Destinatário errado!")
			ConOut("+"+Replicate("-",98)+"+")
			ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			ConOut("+"+Replicate("-",98)+"+")

			Return .F.
		Else
			sfAtuXmlOk("E3")
			Return .T.
		Endif
	Endif
	// Verifica se o campo Inscrição Estadual está preenchido
	If Empty(CONDORXML->XML_INSCRI) .And. CONDORXML->XML_TIPODC <> "S"
		RecLock("CONDORXML",.F.)
		CONDORXML->XML_INSCRI	:= IIf(Type("oEmitente:_IE") <> "U", oEmitente:_IE:TEXT,"ISENTO")
		MsUnlock()
	Endif




	If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
		If Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX"
			cQry := "SELECT A2_COD ,A2_LOJA "
			cQry += "  FROM "+RetSqlName("SA2")
			cQry += " WHERE D_E_L_E_T_ = ' ' "
			cQry += "   AND A2_NOME = '"+Alltrim(Upper(CONDORXML->XML_NOMEMT))+"' "
			cQry += "   AND A2_FILIAL = '"+xFilial("SA2")+"' "
			TCQUERY cQry NEW ALIAS "QSA2"
			If !Eof()
				cFornece := QSA2->A2_COD+QSA2->A2_LOJA
			Endif
			QSA2->(DbCloseArea())
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			Else
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xfilial("SA2")+cFornece)
			Endif
			cCodForn	:= SA2->A2_COD
			cLojForn	:= SA2->A2_LOJA
			cCondicao	:= SA2->A2_COND
			cNatFin		:= SA2->A2_NATUREZ
			cInscricao	:= SA2->A2_INSCR
			cUfCad		:= SA2->A2_EST
			DbSelectArea("SA2")
			DbSetOrder(1)
		Else
			// Novo procedimento que permite especificar qual Código e Loja
			If !Empty(CONDORXML->XML_CODLOJ)
				DbSelectArea("SA2")
				DbSetOrder(1)
				If !DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
					If !lAutoExec
						sfAtuXmlOk("A2")
						MsgAlert("Não há cadastro de fornecedor para este CNPJ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						Return .F.
					Else
						sfAtuXmlOk("A2")
						Return .T.
					Endif
				Endif
			Else
				DbSelectArea("SA2")
				DbSetOrder(3)
				If !DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
					If !lAutoExec
						sfAtuXmlOk("A2")
						MsgAlert("Não há cadastro de fornecedor para este CNPJ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						Return .F.
					Else
						sfAtuXmlOk("A2")
						Return .T.
					Endif
				Endif
			Endif

			cCodForn	:= SA2->A2_COD
			cLojForn	:= SA2->A2_LOJA
			cCondicao	:= SA2->A2_COND
			cNatFin		:= SA2->A2_NATUREZ
			cInscricao	:= SA2->A2_INSCR
			cUfCad		:= SA2->A2_EST
			DbSelectArea("SA2")
			DbSetOrder(1)
		Endif
		// Forço a gravação dos itens para eventual esquecimento de quem lançar a NF
		stGrvItens(,CONDORXML->XML_CHAVE)
	Else
		// Forço a gravação dos itens para eventual esquecimento de quem lançar a NF
		stGrvItens(,CONDORXML->XML_CHAVE)

		// Novo procedimento que permite especificar qual Código e Loja
		If !Empty(CONDORXML->XML_CODLOJ)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+CONDORXML->XML_CODLOJ)
				cCodForn	:= SA1->A1_COD
				cLojForn	:= SA1->A1_LOJA
			Else
				If !lAutoExec
					sfAtuXmlOk("A1")
					MsgAlert("Não há cadastro de cliente para este CNPJ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
					Return .F.
				Else
					sfAtuXmlOk("A1")
					Return .T.
				Endif
			Endif
		Else
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+CONDORXML->XML_EMIT)
				cCodForn	:= SA1->A1_COD
				cLojForn	:= SA1->A1_LOJA
				sfVldCliFor('SA1', @cCodForn, @cLojForn ,SA1->A1_NOME,.T.,CONDORXML->XML_TIPODC)
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+cCodForn+cLojForn)
			Else
				If !lAutoExec
					sfAtuXmlOk("A1")
					MsgAlert("Não há cadastro de cliente para este CNPJ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
					ConOut("+"+Replicate("-",98)+"+")
					ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
					ConOut("+"+Replicate("-",98)+"+")

					Return .F.
				Else
					sfAtuXmlOk("A1")
					Return .T.
				Endif
			Endif
		Endif

		cCondicao	:= SA1->A1_COND
		cNatFin		:= SA1->A1_NATUREZ
		cInscricao	:= SA1->A1_INSCR
		cUfCad		:= SA1->A1_EST

	Endif

	// Efetua validação da Inscrição estadual contida no emitente com o que está no cadastro do cliente ou fornecedor
	If !sfVldIE(CONDORXML->XML_INSCRI/*cInIEXml*/,cInscricao/*cInIECad*/,cUfCad)
		//!Empty(cInscricao) .And. Alltrim(CONDORXML->XML_INSCRI) <> Alltrim(cInscricao)
		If !lAutoExec
			//sfAtuXmlOk("IE")
			sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
			//MsgAlert("Inscrição estadual contida no XML '"+Alltrim(CONDORXML->XML_INSCRI)+"' difere do cadastro que contém '"+Alltrim(cInscricao)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
			
			DEFINE MSDIALOG oDlgSA2 Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualizar Inscrição Estadual") FROM 001,001 TO 180,310 PIXEL
			// Ajustar casas decimais conforme SC7  				
			@ 05  ,4   SAY OemToAnsi("Insc.Estadual no XML") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
			@ 04  ,90  MSGET CONDORXML->XML_INSCRI PICTURE PesqPict('SA2','A2_INSCR') When .F. Of oDlgSA2 PIXEL SIZE 60,9
			@ 19  ,4   SAY OemToAnsi("Insc.Estadual Cadastro") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
			@ 20  ,90  MSGET cInscricao PICTURE PesqPict('SA2','A2_INSCR') When .T. Of oDlgSA2 PIXEL SIZE 60,9
			
			@ 045,030 BUTTON "&Confirma" Size 35,10 Action(lAtuIECad := .T.,oDlgSA2:End())	Pixel Of oDlgSA2
			@ 045,070 Button "&Aborta" Size 35,10 Action (oDlgSA2:End())  Pixel Of oDlgSA2

			Activate MsDialog oDlgSA2 Centered
			
			If lAtuIECad
				If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+cCodForn+cLojForn)
					aFornec := {{"A2_COD"  	,cCodForn        	,Nil},; //
					{"A2_LOJA"  	  		,cLojForn        	,Nil},; //
					{"A2_INSCR"  	  		,cInscricao        	,Nil}} 	// 
					
					lMsHelpAuto := .T.
					lMsErroAuto := .F.
				
					Begin Transaction
						INCLUI	:= .F.
						ALTERA	:= .T.
						MSExecAuto({|x,y,z| mata020(x,y,z)},aFornec,4)//Alteração
				
					End Transaction
				
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						Return .F.
					Endif
					
				Else
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1")+cCodForn+cLojForn)
					aFornec := {{"A1_COD"  	,cCodForn        	,Nil},; //
					{"A1_LOJA"  	  		,cLojForn        	,Nil},; //
					{"A1_INSCR"  	  		,cInscricao        	,Nil}} 	// 
					
					lMsHelpAuto := .T.
					lMsErroAuto := .F.
				
					Begin Transaction
						INCLUI	:= .F.
						ALTERA	:= .T.
						
						MSExecAuto({|x,y,z| mata030(x,y,z)},aFornec,4)//Alteração
				
					End Transaction
				
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						Return .F.
					Endif
				Endif
				//Restauro valor das variáveis para execução da inclusão da nota fiscal
				lMsErroAuto		:=.F.
				lMsHelpAuto		:= lAutoExec
			Endif			
			ConOut("+"+Replicate("-",98)+"+")
			ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			ConOut("+"+Replicate("-",98)+"+")

			
		Else
		//	sfAtuXmlOk("IE")
			sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
			Return .T.
		Endif
	Endif
	// -- Valido se Nota Fiscal já existe na base ?
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(CONDORXML->XML_KEYF1)

		If CONDORXML->XML_TIPODC $ "N#C#P#I#T#F#S"
			If !lAutoExec
				MsgAlert("Nota No.: "+SF1->F1_SERIE+"/"+SF1->F1_DOC+" do Fornecedor "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Já Existe. A Importação será interrompida!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
			Endif
		Else
			If !lAutoExec
				MsgAlert("Nota No.: "+SF1->F1_SERIE+"/"+SF1->F1_DOC+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Já Existe. A Importação será interrompida!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
			Endif
		Endif

		RecLock("CONDORXML",.F.)
		CONDORXML->XML_LANCAD		:= SF1->F1_DTDIGIT
		CONDORXML->XML_USRLAN		:= Padr("Manual- "+cUserName,30)
		CONDORXML->XML_KEYF1		:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
		CONDORXML->XML_NUMNF		:= SF1->F1_SERIE+SF1->F1_DOC
		If CONDORXML->XML_TIPODC $ "N#D#B"
			CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
		Endif 
		MsUnlock()
		sfAtuXmlOk("E4")
		
		Return .T.
	EndIf

	// Validação para impedir que notas com pedidos não vinculados corretamente sejam importadas
	For nForD := 1 To Len(oMulti:aCols)
		nR := nForD
		If 	CONDORXML->XML_TIPODC == "N" .And. lMVXPCNFE
			If !oMulti:aCols[nR,Len(oMulti:aHeader)+1]
				If !Alltrim(oMulti:aCols[nR][nPxCFNFe]) $ Alltrim(cCFOPNPED) .And.;
				!Alltrim(oMulti:aCols[nR][nPxCF]) $ Alltrim(cCFOPNPED) .And.;
				!Alltrim(oMulti:aCols[nR][nPxD1Tes]) $ Alltrim(cTESNPED)
					If Empty(oMulti:aCols[nR,nPxPedido]) .Or. Empty(oMulti:aCols[nR,nPxItemPC])
						lContinua	:= .F.
						If !lAutoExec
							MsgAlert("Pedido de Compra Obrigatório.Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
							sfAtuXmlOk("PC",.T.,oMulti:aCols[nR,nPxItem])
						Else
							sfAtuXmlOk("PC",.T.,oMulti:aCols[nR,nPxItem])
						Endif
						Return .T.
					Else
						U_VldItemPc(nR,.T.,oMulti:aCols[nR,nPxPedido],oMulti:aCols[nR,nPxItemPC],.T.)
					Endif
				Else
					lContinua	:= .T. // Senão o CFOP de Saida ou entrada estiver na exceção de CFOPS, permite continuar sem conferir o Compras
				Endif
			Endif
		Else
			lContinua	:= .T.
		Endif
	Next nForD

	If Empty(CONDORXML->XML_CONFCO) .And. CONDORXML->XML_TIPODC == "N" .And. !lContinua
		// Conferencia do compras será obrigatório somente para notas com interface
		If !lAutoExec
			MsgAlert("Nota fiscal ainda não foi conferida pelo Compras.Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
			Return .F.
		Else
			// Efetua conferencia do compras de forma forçada, pois o objetivo é justamente automatizar o processo de lançamento de notas
			If stGrvItens(.T.,CONDORXML->XML_CHAVE)

				// Garante que se o XML tem algum bloqueio não será lançada e nem marcada como conferida
				If !Empty(CONDORXML->XML_OK)
					Return .F.
				Endif

				RecLock("CONDORXML",.F.)
				CONDORXML->XML_CONFCO	:= Date()
				CONDORXML->XML_HORCCO	:= Time()
				CONDORXML->XML_USRCCO	:= Padr(cUserName,30)
				MsUnlock()

				If !lMadeira
					cRecebe		:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
					cAssunto 	:= "Nota Fiscal "+ aArqXml[oArqXml:nAt,2] + " - " + cEmpAnt+"/"+cFilAnt+" "  +Capital(SM0->M0_NOMECOM)
					cMensagem	:= "Nota Fiscal "+aArqXml[oArqXml:nAt,2	] + " conferida pelo Compras no dia " + Dtoc( Date() ) + " as " + Time() + " por " + cUserName
					cMensagem 	+= "-" + UsrFullName(__cUserId) +  Chr(13)+Chr(10)

					stSendMail( cRecebe, cAssunto, cMensagem ,.F.)
				Endif
			Else
				Return .F.
			Endif
		Endif
	Endif

	If Empty(CONDORXML->XML_CONFER) .And. !(CONDORXML->XML_TIPODC $ "S")
		If !lAutoExec
			If sfAtuXmlOk("E5")
				MsgAlert("Nota fiscal ainda não foi conferida na SEFAZ.Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
				Return .F.
			Endif
		Else
			If sfAtuXmlOk("E5")
				Return .T.
			Endif
		Endif
	Endif

	// Restauro o valor da variavel para continuar o uso da mesma para outro fim
	lContinua	:= .F.

	If nTotalNfe <> nTotalXml
		If !lAutoExec
			If sfAtuXmlOk("E6")
				MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra! Favor conferir novamente!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Conferência incompleta!")
				Return .F.
			Endif
		Else
			If sfAtuXmlOk("E6")
				Return .T.
			Endif
		Endif
	Endif


	//cNumDoc	:=  Right("000000000"+Alltrim(OIdent:_nNF:TEXT),nTmF1Doc)
	//cSerDoc	:= 	Padr(OIdent:_serie:TEXT,nTmF1Ser)
	If CONDORXML->XML_TIPODC <> "S"
		// Novo modelo de tratativa da modelagem do número da Nota fiscal
		If cLeftNil $ " #0" 		// 0=Padrão(Soh Num c/zeros)
			cSerDoc	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
			cNumDoc	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
		ElseIf cLeftNil == "1" 	// 1=Num e Serie
			cSerDoc	:= Right(StrZero(0,(nTmF1Ser)-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,nTmF1Ser)
			cNumDoc	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
		ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
			cSerDoc	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
			cNumDoc	:= Padr(oIdent:_nNF:TEXT,nTmF1Doc)
		Endif
	Else
		cSerDoc	:= Substr(CONDORXML->XML_NUMNF,1,nTmF1Ser)
		cNumDoc	:= Substr(CONDORXML->XML_NUMNF,nTmF1Ser+1,nTmF1Doc)
	Endif
	// Chamado 50 - Central XML - 
	// Alterar a série do documento quando o número do documento já existir na base do sistema
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(xFilial("SF1") + cNumDoc + cSerDoc + cCodForn  + cLojForn)
		If cLeftNil $ " #0#2"
			MsgAlert("Já encontrado lançamento do mesmo número de Nota e série para este fornecedor/loja. A série será alterada de '" + cSerDoc + "' para '" + ( cSerDoc	:= Right(StrZero(0,(nTmF1Ser)-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,nTmF1Ser)) + "' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Else
			MsgAlert("Já encontrado lançamento do mesmo número de Nota e série para este fornecedor/loja. A série será alterada de '" + cSerDoc + "' para '" + (cSerDoc	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)) + "' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
		// Efetua ajuste do campo para evitar erro na validação do PE MT103DNF que valida o número de nota e série 
		RecLock("CONDORXML",.F.)
		CONDORXML->XML_NUMNF	:= cSerDoc + cNumDoc
		MsUnlock()
	Endif

	Aadd(aCabec,{"F1_FILIAL"  	,xFilial("SF1")		,Nil,Nil})

	cTipoBox	:= CONDORXML->XML_TIPODC

	// Tratativa adicionada em 26/10/2012 para localizar a condição de pagamento tratada no pedido de compra
	If lMVXPCNFE .And. cTipoBox == "N"
		For nForE := 1 To Len(oMulti:aCols)
			nIX := nForE 
			If !oMulti:aCols[nIX,Len(oMulti:aHeader)+1]
				If 	!Alltrim(oMulti:aCols[nIX][nPxCFNFe]) $ cCFOPNPED .And.;
				(IIf(!Empty(oMulti:aCols[nIX][nPxCF]),!Alltrim(oMulti:aCols[nIX][nPxCF]) $ cCFOPNPED,.T.)) .And.;
				(IIf(!Empty(oMulti:aCols[nIX][nPxD1Tes]),!Alltrim(oMulti:aCols[nIX][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
				(!Empty(oMulti:aCols[nIX,nPxPedido]) .And.!Empty(oMulti:aCols[nIX,nPxItemPC]))
					DbSelectArea("SC7")
					DbSetOrder(1)
					If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC]) 
						If !Empty(SC7->C7_COND)
							cCondicao		:= SC7->C7_COND
						Endif
						// Verifica quais os tipos de Frete configurados nos pedidos de compra vinculados à nota para posterior conferência
						cTpFretePed		+= IIf(SC7->C7_TPFRETE $ cTpFretePed,"",SC7->C7_TPFRETE)
						cC7Transp		+= Iif(SC7->(FieldPos("C7_TRANSP")) <> 0 , Iif(SC7->C7_TRANSP $ cC7Transp  , "" ,SC7->C7_TRANSP),"")
						nTotDespesa		+= sfxMoeda("C7_DESPESA") 	//SC7->C7_DESPESA
						nTotFrete		+= sfxMoeda("C7_VALFRE")	//SC7->C7_VALFRE
						nTotSeguro		+= sfxMoeda("C7_SEGURO")	//SC7->C7_SEGURO
					Endif
				Endif
				If Empty(oMulti:aCols[nIX,nPxD1Tes])
					lForcePreNf	:= .T.
				Endif
			Endif
		Next nForE
	Endif

	// Ponto de entrada criado em 11/06/2017
	// Permite que o cliente customize qualquer interação antes de gerar o Doc.Entrada
	If ExistBlock("XMLCTE17")
		ExecBlock("XMLCTE17",.F.,.F.)
	Endif


	If !lAutoExec
		DEFINE MSDIALOG oDlgCond TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Continuar lançamento da Nota Fiscal?") FROM 001,001 TO 190,400 PIXEL
		@ 010,018 Say "Informe a Condicao de Pagamento" Pixel of oDlgCond
		@ 010,110 MsGet cCondicao F3 "SE4" Valid (Vazio() .Or. ExistCpo("SE4",cCondicao)) Size 30,10 Pixel of oDlgCond When (cTipoBox == "P" .Or. Empty(cCondicao) .Or. Empty(aDupSE2))
		@ 022,018 Say "Tipo de Nota fiscal" Pixel of oDlgCond
		@ 022,110 Combobox cTipoBox Items {"N=Normal","B=Beneficiamento","D=Devolução","C=Compl. Preço/Frete","P=Compl. IPI","I=Compl. ICMS","S=Serviço"} Pixel of oDlgCond When lSuperUsr
		// Melhoria implementada para atender obrigatoriedade da informação da Natureza Financeira
		If GetMv("MV_NFENAT") .And. !lForcePreNf
			@ 035,018 Say "Informe a Natureza" Pixel of oDlgCond
			@ 035,110 MsGet cNatFin F3 "SED" Valid ExistCpo("SED",cNatFin) Size 60,10 Pixel of oDlgCond
		Endif
		If lSuperUsr 
			@ 048,018 CHECKBOX oChk Var lCheck PROMPT "Gera com Interface se Nota Fiscal?" SIZE 100,12 Of oDlgCond Pixel
		Endif

		@ 063,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
		@ 063,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())

		ACTIVATE MSDIALOG oDlgCond CENTERED

		If !lContinua
			Return .F.
		Endif
	Else
		lCheck		:= .F.	// Evita que seja gerada a nota fiscal com interface ( parametro lWhen do Mata103 )
	Endif



	// Validação que permite que o tipo de documento seja alterado
	If cTipoBox <> CONDORXML->XML_TIPODC
		If MsgNoYes("Você alterou o tipo de nota fiscal de '"+CONDORXML->XML_TIPODC+"' para '"+cTipoBox+"'!"+Chr(13)+Chr(10)+;
		"Deseja realmente efetuar a troca do tipo de Nota para '"+cTipoBox+"'? ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca do Tipo de Documento de Entrada!")
			RecLock("CONDORXML",.F.)
			CONDORXML->XML_TIPODC 	:= cTipoBox
			CONDORXML->XML_CODLOJ 	:= ""
			CONDORXML->XML_INSCRI	:= ""
			MsUnlock()
			Return .T.
		Endif
		Return .F.
	Endif

	dData	:=	CONDORXML->XML_EMISSA
	// Variável aValCond é populada para validações em pontos de entrada de clientes 
	aValCond := 	{;
	IIf(nSumSE2 > 0 , nSumSE2,Iif(cTipoBox $ "S",CONDORXML->XML_VLRDOC,Val(oTotal:_ICMSTot:_vNF:TEXT))),;			// 1 - Valor Total
	IIf(nSumSE2>0,0,Iif(cTipoBox $ "S",0,Val(oTotal:_ICMSTot:_vIPI:TEXT))),;					// 2 - Valor IPI
	Iif(nSumSE2>0,0,Iif(cTipoBox $ "S",0,Val(oTotal:_ICMSTot:_vST:TEXT))),;					// 3 - Valor Solidário
	dData,;																// 4 - Data emissão
	cNumDoc}

	// 20/05/2016 - Melhoria projeto Drugovich 
	// Verifica se deve haver uma verificação da condição de pagamento do Pedido de Compra e as duplicatas do XML
	// e se o tipo de nota for N=Normal e o pedido de compra obrigatório na Central XML. 
	If GetNewPar("XM_CPVLDPC",.F.) .And. cTipoBox == "N" .And. lMVXPCNFE
		aCondPg		:= Condicao(aValCond[1]/*nValTot*/,cCondicao/*cCond*/,aValCond[2]/*nValIpi*/,aValCond[4]/*dData0*/,aValCond[3]/*nValSolid*/)
		If !StaticCall(MT103DNF,sfVldCond,aDupSE2,aCondPg,cChave)
			Return .F.
		Endif
	Endif

	If cTipoBox $ "N#C#I#P#S"
		// Alimenta variável com o valor do tipo
		cTipo	:= Iif(cTipoBox $ "S","N",cTipoBox)
		
		Aadd(aCabec,{"F1_TIPO"   	,cTipo				,Nil,Nil})

		// Verifica se o XML possui a tag de Versão do Processo contendo o valor CMX Lite
		If  Alltrim(CONDORXML->XML_MUNMT) $ "EXTERIOR/EX" //At('<verProc>CMX Lite 2.0</verProc>',CONDORXML->XML_ARQ) > 0
			Aadd(aCabec,{"F1_FORMUL" 	,"S"									,Nil,Nil})
			Aadd(aCabec,{"F1_DOC"    	,Space(nTmF1Doc)  		,Nil,Nil})
			Aadd(aCabec,{"F1_SERIE"     ,Space(nTmF1Ser)				 		,Nil,Nil})
		Else
			Aadd(aCabec,{"F1_FORMUL" 	,"N"									,Nil,Nil})
			Aadd(aCabec,{"F1_DOC"    	,cNumDoc								,Nil,Nil})
			Aadd(aCabec,{"F1_SERIE"     ,cSerDoc								,Nil,Nil})
		Endif
		Aadd(aCabec,{"F1_EMISSAO"	,dData										,Nil,Nil})
		Aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD								,Nil,Nil})
		Aadd(aCabec,{"F1_LOJA"   	,SA2->A2_LOJA								,Nil,Nil})
		// 29/01/2015 - Melhoria para considerar a séria 890 como espécie NFA - Solicitação CAAL
		If cSerDoc $ "890"
			If MsgYesNo("Encontrado documento com a série '890' equiparando-se a NFA ( Nota Fiscal Avulsa ). Deseja alterar a Espécie de 'SPED' para 'NFA' para o lançamento desta nota fiscal?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFA",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Else
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("SPED",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Endif
		ElseIf cTipoBox $ "S"
			nOpcSrv := Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha uma opção!","Selecione uma ESPÉCIE para o lançamento de nota de serviços.",{"NFPS","NFS","NFDS","RPS"})
			If nOpcSrv == 1 //{"NFPS","NFS","NFDS","RPS"}
 				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFPS",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			ElseIf nOpcSrv == 2 
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFS",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			ElseIf nOpcSrv == 3 
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFDS",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			ElseIf nOpcSrv == 4
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("RPS",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Endif
		Else
			If oIdent:_mod:TEXT == "65"
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFCE",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Else
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("SPED",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Endif
		Endif
		Aadd(aCabec,{"F1_EST"		,SA2->A2_EST								,Nil,Nil})
		Aadd(aCabec,{"F1_COND"		,cCondicao		    						,Nil,Nil})
		Aadd(aCabec,{"E2_NATUREZ"   ,cNatFin									,NIL,NIL})


		If !(cTipoBox $ "S")
			// Validação de valores de Despesa / Seguro e Frete  para confrontar com pedido de compra
			// Adicionada em 08/12/2013
			If (Val(oTotal:_ICMSTot:_vOutro:TEXT) > 0 .And. nTotDespesa > 0) .And. Round(Val(oTotal:_ICMSTot:_vOutro:TEXT),2) <> Round(nTotDespesa,2)
				stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
				"Validação Despesa - NF:"+ cSerDoc +"/"+cNumDoc ,;
				"Houve diferença no valor da Despesa informada na Nota Fiscal R$ "+ Transform(Round(Val(oTotal:_ICMSTot:_vOutro:TEXT),2),"@E 999,999.99") + " com a somatória dos itens dos pedidos de compra que foi de R$ "+ Transform(Round(nTotDespesa,2),"@E 999,999.99"))
			Endif
	
			If (Val(oTotal:_ICMSTot:_vSeg:TEXT) > 0 .And. nTotSeguro > 0) .And. Round(Val(oTotal:_ICMSTot:_vSeg:TEXT),2) <> Round(nTotSeguro,2)
				stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
				"Validação Seguro - NF:"+cSerDoc+"/"+cNumDoc ,;
				"Houve diferença no valor do Seguro informada na Nota Fiscal R$ "+ Transform(Round(Val(oTotal:_ICMSTot:_vSeg:TEXT),2),"@E 999,999.99" ) + " com a somatória dos itens dos pedidos de compra que foi de R$ "+ Transform(Round(nTotSeguro,2),"@E 999,999.99"))
			Endif
			// Efetua avaliação se o valor do frete na nota ou pedido de compra ao menos é maior que Zero
			If (Val(oTotal:_ICMSTot:_vFrete:TEXT) > 0 .And. nTotFrete > 0) .And. Round(Val(oTotal:_ICMSTot:_vFrete:TEXT),2) <> Round(nTotFrete,2)
				stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
				"Validação Frete - NF:"+cSerDoc+"/"+cNumDoc ,;
				"Houve diferença no valor do Frete informada na Nota Fiscal R$ "+ Alltrim(Transform(Round(Val(oTotal:_ICMSTot:_vFrete:TEXT),2),"@E 999,999,999.99"))+" com a somatória dos itens dos pedidos de compra que foi de R$ "+ Alltrim(Transform(Round(nTotFrete,2),"@E 999,999,999.99")))
			Endif
		Endif
	Else
		// Alimenta variável com o valor do tipo
		cTipo	:= cTipoBox
		
		DbSelectArea("SA1")
		Aadd(aCabec,{"F1_TIPO"   	,cTipoBox									,Nil,Nil})
		Aadd(aCabec,{"F1_FORMUL" 	,"N"										,Nil,Nil})
		Aadd(aCabec,{"F1_DOC"    	,cNumDoc									,Nil,Nil})
		Aadd(aCabec,{"F1_SERIE"     ,cSerDoc									,Nil,Nil})
		Aadd(aCabec,{"F1_EMISSAO"	,dData										,Nil,Nil})
		Aadd(aCabec,{"F1_FORNECE"	,SA1->A1_COD								,Nil,Nil})
		Aadd(aCabec,{"F1_LOJA"   	,SA1->A1_LOJA								,Nil,Nil})
		// 29/01/2015 - Melhoria para considerar a séria 890 como espécie NFA - Solicitação CAAL
		If cSerDoc $ "890"
			If MsgYesNo("Encontrado documento com a série '890' equiparando-se a NFA ( Nota Fiscal Avulsa ). Deseja alterar a Espécie de 'SPED' para 'NFA' para o lançamento desta nota fiscal?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("NFA",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Else
				Aadd(aCabec,{"F1_ESPECIE"	,Padr("SPED",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
			Endif
		Else
			Aadd(aCabec,{"F1_ESPECIE"	,Padr("SPED",TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
		Endif
		//Aadd(aCabec,{"F1_ESPECIE"	,Padr(IIf(cSerDoc$"890","NFA","SPED"),TamSX3("F1_ESPECIE")[1])	,Nil,Nil})
		Aadd(aCabec,{"F1_EST"		,SA1->A1_EST								,Nil,Nil})
		Aadd(aCabec,{"F1_COND"		,cCondicao									,Nil,Nil})
		Aadd(aCabec,{"E2_NATUREZ"   ,cNatFin									,NIL,NIL})
	Endif



	// Somente se estiver setado para considerar os impostos do XML, será forçada a digitação destes valores de impostos
	If !(cTipoBox $ "S") .And. (mv_par12 == 1 .Or. mv_par12 == 3 .Or. mv_par12 == 5)
		// Necessário somar numa variável por que não existe a tag de base de IPI no XML
		nBaseIpi	:= 0
		For nForF := 1 To Len(oMulti:aCols)
			If !oMulti:aCols[nForF,Len(oMulti:aHeader)+1]
				nBaseIpi	+= oMulti:aCols[nForF,nPxBasIpi]
			Endif
		Next nForF

		Aadd(aCabec,{"F1_BASEIPI"	,nBaseIpi								,Nil,Nil})
		Aadd(aCabec,{"F1_VALIPI"	,Val(oTotal:_ICMSTot:_vIPI:TEXT)		,Nil,Nil})
		Aadd(aCabec,{"F1_BASEICM"	,Val(oTotal:_ICMSTot:_vBC:TEXT)			,Nil,Nil})
		Aadd(aCabec,{"F1_VALICM"	,Val(oTotal:_ICMSTot:_vICMS:TEXT)		,Nil,Nil})
		Aadd(aCabec,{"F1_BRICMS" 	,Val(oTotal:_ICMSTot:_vBCST:TEXT)		,Nil,Nil})
		Aadd(aCabec,{"F1_ICMSRET"	,Val(oTotal:_ICMSTot:_vST:TEXT)			,Nil,Nil})
	Endif

	// Inicio loop nos itens da nota
	For nForG := 1 To Len(oMulti:aCols)
		nIX := nForG
		If !oMulti:aCols[nIX,Len(oMulti:aHeader)+1] .And. !Empty(oMulti:aCols[nIX,nPxProd])
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+oMulti:aCols[nIX,nPxProd])
			aLinha := {}

			Aadd(aLinha,{"D1_FILIAL"	, xFilial("SD1")						,Nil,Nil})
			Aadd(aLinha,{"D1_ITEM"		, cItemD1								,Nil,Nil})
			//Aadd(aLinha,{"D1_ITEM"		,oMulti:aCols[nIX,nPxItem]			,Nil,Nil})
			oMulti:aCols[nIX,nPxKeySD1]	:= xFilial("SD1") //Chave SD1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			oMulti:aCols[nIX,nPxKeySd1] += aCabec[aScan(aCabec,{|x| x[1] == "F1_DOC"}),2]
			oMulti:aCols[nIX,nPxKeySd1] += aCabec[aScan(aCabec,{|x| x[1] == "F1_SERIE"}),2]
			oMulti:aCols[nIX,nPxKeySd1] += aCabec[aScan(aCabec,{|x| x[1] == "F1_FORNECE"}),2]
			oMulti:aCols[nIX,nPxKeySd1] += aCabec[aScan(aCabec,{|x| x[1] == "F1_LOJA"}),2]
			oMulti:aCols[nIX,nPxKeySd1] += oMulti:aCols[nIX,nPxProd]
			oMulti:aCols[nIX,nPxKeySd1]	+= cItemD1

			// Zero variável que controla se houve adição da coluna descrição
			lAddD1Descri	:= .F.

			Aadd(aLinha,{"D1_COD"		, oMulti:aCols[nIX,nPxProd]			,Nil,Nil})
			Aadd(aLinha,{"D1_UM"		,oMulti:aCols[nIX,nPxUm]			,Nil,Nil})
			// Pedido de Compra Obrigatório
			If lMVXPCNFE
				// Tipo nota Normal
				If cTipoBox == "N"
					// CFOP Xml não está nas exceções
					If !Alltrim(oMulti:aCols[nIX][nPxCFNFe]) $ cCFOPNPED
						// Cfop da nota preenchido
						If !Empty(oMulti:aCols[nIX][nPxCF])
							// Cfop da nota não está nas exceções
							If !Alltrim(oMulti:aCols[nIX][nPxCF]) $ cCFOPNPED .And.;
							(IIf(!Empty(oMulti:aCols[nIX][nPxD1Tes]),!Alltrim(oMulti:aCols[nIX][nPxD1Tes]) $ cTESNPED,.T.))
								If !Empty(oMulti:aCols[nIX,nPxPedido])
									Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nIX,nPxPedido]	,Nil,Nil})
								Endif
								If !Empty(oMulti:aCols[nIX,nPxItemPC])
									Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nIX,nPxItemPC]	,Nil,Nil})
									lExistSC7	:= .T.
									// Se existe o campo Descrição na SD1
									If SD1->(FieldPos(cD1Descri)) > 0
										DbSelectArea("SC7")
										DbSetOrder(1)
										If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC])
											If !Empty(SC7->C7_DESCRI)
												Aadd(aLinha,{cD1Descri	,SC7->C7_DESCRI	,Nil,Nil})
												lAddD1Descri	:= .T.
											Endif
										Endif
									Endif
								Endif
							Else
								If !Empty(oMulti:aCols[nIX,nPxPedido])
									DbSelectArea("SC7")
									DbSetOrder(1)
									If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC])
										Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nIX,nPxPedido]	,Nil,Nil})
										Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nIX,nPxItemPC]	,Nil,Nil})
										lExistSC7	:= .T.
									Endif
								Endif
							Endif
						Else
							// Mesmo que não tenha Cfop de entrada, irá preencher pedido de compra se tiver informação do mesmo
							If !Empty(oMulti:aCols[nIX,nPxPedido])
								Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nIX,nPxPedido]	,Nil,Nil})
							Endif
							If !Empty(oMulti:aCols[nIX,nPxItemPC])
								Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nIX,nPxItemPC]	,Nil,Nil})
								lExistSC7	:= .T.
								// Se existe o campo Descrição na SD1
								If SD1->(FieldPos(cD1Descri)) > 0
									DbSelectArea("SC7")
									DbSetOrder(1)
									If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC])
										If !Empty(SC7->C7_DESCRI)
											Aadd(aLinha,{cD1Descri	,SC7->C7_DESCRI	,Nil,Nil})
											lAddD1Descri	:= .T.
										Endif
									Endif
								Endif
							Endif
						Endif
					Else
						If !Empty(oMulti:aCols[nIX,nPxPedido])
							Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nIX,nPxPedido]	,Nil,Nil})
						Endif
						If !Empty(oMulti:aCols[nIX,nPxItemPC])
							Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nIX,nPxItemPC]	,Nil,Nil})
							lExistSC7	:= .T.
							// Se existe o campo Descrição na SD1
							If SD1->(FieldPos(cD1Descri)) > 0
								DbSelectArea("SC7")
								DbSetOrder(1)
								If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC])
									If !Empty(SC7->C7_DESCRI)
										Aadd(aLinha,{cD1Descri	,SC7->C7_DESCRI	,Nil,Nil})
										lAddD1Descri	:= .T.
									Endif
								Endif
							Endif
						Endif
					Endif
				Endif
				// Melhoria adicionada em 26/10/2012 - Caso tenha sido selecionado um pedido de compra, mesmo não estando obrigaod, permite que seja levado para o lanaçmento do documento
			Else
				If cTipoBox == "N"
					If !Empty(oMulti:aCols[nIX,nPxPedido]) .And.!Empty(oMulti:aCols[nIX,nPxItemPC])
						Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nIX,nPxPedido]	,Nil,Nil})
						Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nIX,nPxItemPC]	,Nil,Nil})
						lExistSC7	:= .T.
						// Se existe o campo Descrição na SD1
						If SD1->(FieldPos(cD1Descri)) > 0
							DbSelectArea("SC7")
							DbSetOrder(1)
							If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC])
								If !Empty(SC7->C7_DESCRI)
									Aadd(aLinha,{cD1Descri	,SC7->C7_DESCRI	,Nil,Nil})
									lAddD1Descri	:= .T.
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
			// Se existe o campo Descrição na SD1
			If !lAddD1Descri .And. SD1->(FieldPos(cD1Descri)) > 0
				Aadd(aLinha,{cD1Descri	,SB1->B1_DESC		,Nil,Nil})
				lAddD1Descri	:= .T.
			Endif

			If cTipoBox $ "D#B"

				DbSelectArea("SD2")
				DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				DbSeek(xFilial("SD2")+oMulti:aCols[nIX,nPxNfOri]+oMulti:aCols[nIX,nPxSerOri]+SA1->A1_COD+SA1->A1_LOJA+oMulti:aCols[nIX,nPxProd]+oMulti:aCols[nIX,nPxItemOri])

				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4")+oMulti:aCols[nIX,nPxD1Tes])

				Aadd(aLinha,{"D1_QUANT"		,oMulti:aCols[nIX,nPxQte]		,Nil,Nil})
				If !Empty(oMulti:aCols[nIX,nPxD1Oper]) .And. lAddOper .And. ExistCpo("SX5","DJ"+oMulti:aCols[nIX,nPxD1Oper])
					Aadd(aLinha,{"D1_OPER"		,oMulti:aCols[nIX,nPxD1Oper],Nil,Nil})
				Endif
				If !Empty(oMulti:aCols[nIX,nPxD1Tes])
					Aadd(aLinha,{"D1_TES"		,oMulti:aCols[nIX,nPxD1Tes]		,Nil,Nil})
				Endif
				If !Empty(oMulti:aCols[nIX,nPxCF])
					Aadd(aLinha,{"D1_CF"		,oMulti:aCols[nIX,nPxCF]		,Nil,Nil})
				Endif
				If !Empty(oMulti:aCols[nIX,nPxNfOri])
					Aadd(aLinha,{"D1_NFORI"		,oMulti:aCols[nIX,nPxNfOri]		,Nil,Nil})
					Aadd(aLinha,{"D1_SERIORI"	,oMulti:aCols[nIX,nPxSerOri]	,Nil,Nil})
					Aadd(aLinha,{"D1_ITEMORI"	,oMulti:aCols[nIX,nPxItemOri]	,Nil,Nil})					
				Endif
				If !lTemNfOri .And. !Empty(oMulti:aCols[nIX,nPxNfOri])
					lTemNfOri	:= .T. 
				Endif 
				
				If SF4->F4_PODER3=="D"
					AAdd( aLinha, { "D1_IDENTB6", oMulti:aCols[nIX,nPxIdentB6], Nil,Nil } )
				Endif

				Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nIX,nPxPrunit]	,Nil,Nil})
				Aadd(aLinha,{"D1_LOCAL"		,oMulti:aCols[nIX,nPxLocal]		,Nil,Nil})

				Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nIX,nPxTotal]		,Nil,Nil})

				// Melhoria para levar dados de Lote/Sublote/Lote Fornecedor/Ficha Controle
				// Corrigido em 10/12/2014 para levar em casos de Devolução e Beneficiamento
				If Rastro(oMulti:aCols[nIX,nPxProd])
					If !Empty(oMulti:aCols[nIX,nPxLoteCtl])
						Aadd(aLinha,{"D1_LOTECTL"		,oMulti:aCols[nIX,nPxLoteCtl]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxNumLote])
						Aadd(aLinha,{"D1_NUMLOTE"		,oMulti:aCols[nIX,nPxNumLote]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxLoteFor])
						Aadd(aLinha,{"D1_LOTEFOR"		,oMulti:aCols[nIX,nPxLoteFor]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxVldLtFor])
						Aadd(aLinha,{"D1_DTVALID"		,oMulti:aCols[nIX,nPxVldLtFor]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxDtFabric])
						Aadd(aLinha,{"D1_DFABRIC"		,oMulti:aCols[nIX,nPxDtFabric] 	,Nil,Nil})
					Endif
				Endif
				If nPxFciCod > 0
					Aadd(aLinha,{"D1_FCICOD"			,oMulti:aCols[nIX,nPxFciCod]	,Nil,Nil})
				Endif
				If nPxCodCest > 0 .And. !Empty(oMulti:aCols[nIX,nPxCodCest])
					//Aadd(aLinha,{"D1_FCICOD"			,oMulti:aCols[nIX,nPxFciCod]	,Nil,Nil})
					// Ponto de entrada criado em 02/05/2017
					// Permite que o cliente customize a gravação do código CEST  
					If ExistBlock("XMLCTE16")
						ExecBlock("XMLCTE16",.F.,.F.,{oMulti:aCols[nIX,nPxProd],oMulti:aCols[nIX,nPxCodCest]})
					Endif
				Endif
			ElseIf cTipoBox == "I"
				DbSelectArea("SD2")
				DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				DbSeek(xFilial("SD2")+oMulti:aCols[nIX,nPxNfOri]+oMulti:aCols[nIX,nPxSerOri]+SA2->A2_COD+SA2->A2_LOJA+oMulti:aCols[nIX,nPxProd]+oMulti:aCols[nIX,nPxItemOri])

				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4")+oMulti:aCols[nIX,nPxD1Tes])

				Aadd(aLinha,{"D1_NFORI"		,oMulti:aCols[nIX,nPxNfOri]	,Nil,Nil})
				If !lTemNfOri .And. !Empty(oMulti:aCols[nIX,nPxNfOri])
					lTemNfOri	:= .T. 
				Endif 
				Aadd(aLinha,{"D1_SERIORI"	,oMulti:aCols[nIX,nPxSerOri]	,Nil,Nil})
				Aadd(aLinha,{"D1_ITEMORI"	,oMulti:aCols[nIX,nPxItemOri]	,Nil,Nil})

				Aadd(aLinha,{"D1_LOCAL"		,oMulti:aCols[nIX,nPxLocal]	,Nil,Nil})
				If oMulti:aCols[nIX,nPxValIcm] > 0
					Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nIX,nPxValIcm]	,Nil,Nil})

					Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nIX,nPxValIcm],Nil,Nil})
				ElseIf oMulti:aCols[nIX,nPxIcmRet] > 0
					Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nIX,nPxIcmRet]	,Nil,Nil})

					Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nIX,nPxIcmRet],Nil,Nil})
				Endif

				If !Empty(oMulti:aCols[nIX,nPxD1Tes])
					If !Empty(oMulti:aCols[nIX,nPxD1Oper]) .And. lAddOper .And. ExistCpo("SX5","DJ"+oMulti:aCols[nIX,nPxD1Oper])
						Aadd(aLinha,{"D1_OPER"		,oMulti:aCols[nIX,nPxD1Oper]	,Nil,Nil})
					Endif
					Aadd(aLinha,{"D1_TES"			,oMulti:aCols[nIX,nPxD1Tes]		,Nil,Nil})
					Aadd(aLinha,{"D1_CF"			,oMulti:aCols[nIX,nPxCF]		,Nil,Nil})
				Else
					lForcePreNf	:= .T.
				Endif
				If 	oMulti:aCols[nIX,nPxPIcm]	 > 0
					Aadd(aLinha,{"D1_PICM"	 	,oMulti:aCols[nIX,nPxPIcm]			,Nil,Nil})
				Endif
				// Não deve ser informado o valor do icms, pois o valor deve ser informado no campo Total 	
				//	Aadd(aLinha,{"D1_VALICM" 	,oMulti:aCols[nIX,nPxValIcm]		,Nil,Nil})

			Else
				DbSelectArea("SD2")
				DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				DbSeek(xFilial("SD2")+oMulti:aCols[nIX,nPxNfOri]+oMulti:aCols[nIX,nPxSerOri]+SA2->A2_COD+SA2->A2_LOJA+oMulti:aCols[nIX,nPxProd]+oMulti:aCols[nIX,nPxItemOri])

				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4")+oMulti:aCols[nIX,nPxD1Tes])

				If SF4->F4_PODER3=="D" .Or. cTipoBox $ "C#I#P"
					Aadd(aLinha,{"D1_NFORI"		,oMulti:aCols[nIX,nPxNfOri]	,Nil,Nil})
					If !lTemNfOri .And. !Empty(oMulti:aCols[nIX,nPxNfOri])
						lTemNfOri	:= .T. 
					Endif 
					Aadd(aLinha,{"D1_SERIORI"	,oMulti:aCols[nIX,nPxSerOri]	,Nil,Nil})
					Aadd(aLinha,{"D1_ITEMORI"	,oMulti:aCols[nIX,nPxItemOri]	,Nil,Nil})
					AAdd(aLinha,{"D1_IDENTB6"   ,oMulti:aCols[nIX,nPxIdentB6], Nil,Nil } )
				Endif

				Aadd(aLinha,{"D1_LOCAL"		,oMulti:aCols[nIX,nPxLocal]	,Nil,Nil})

				If cTipoBox $ "N#S"
					Aadd(aLinha,{"D1_QUANT"		,oMulti:aCols[nIX,nPxQte]		,Nil,Nil})
				Endif
				Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nIX,nPxPrunit]	,Nil,Nil})

				// Tratamento para Imposto IMportacao
				If oMulti:aCols[nIX,nPxDiVII] > 0 .And. SD1->(FieldPos("D1_II"))  > 0
					Aadd(aLinha,{"D1_TOTAL"  ,oMulti:aCols[nIX,nPxTotal]+oMulti:aCols[nIX,nPxDiVII]	,Nil,Nil})
				Else
					Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nIX,nPxTotal]	,Nil,Nil})
				Endif
				If!Empty(oMulti:aCols[nIX,nPxD1Tes])
					If !Empty(oMulti:aCols[nIX,nPxD1Oper]) .And. lAddOper .And. ExistCpo("SX5","DJ"+oMulti:aCols[nIX,nPxD1Oper])
						Aadd(aLinha,{"D1_OPER"		,oMulti:aCols[nIX,nPxD1Oper]	,Nil,Nil})
					Endif
					Aadd(aLinha,{"D1_TES"			,oMulti:aCols[nIX,nPxD1Tes]		,Nil,Nil})
					//D1_TESACLA
					Aadd(aLinha,{"D1_TESACLA"		,oMulti:aCols[nIX,nPxD1Tes]		,Nil,Nil})
					Aadd(aLinha,{"D1_CF"			,oMulti:aCols[nIX,nPxCF]		,Nil,Nil})
				Else
					lForcePreNf	:= .T.
				Endif
				// Melhoria para levar dados de Lote/Sublote/Lote Fornecedor/Ficha Controle
				If Rastro(oMulti:aCols[nIX,nPxProd])
					If !Empty(oMulti:aCols[nIX,nPxLoteCtl])
						Aadd(aLinha,{"D1_LOTECTL"		,oMulti:aCols[nIX,nPxLoteCtl]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxNumLote])
						Aadd(aLinha,{"D1_NUMLOTE"		,oMulti:aCols[nIX,nPxNumLote]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxLoteFor])
						Aadd(aLinha,{"D1_LOTEFOR"		,oMulti:aCols[nIX,nPxLoteFor]	,Nil,Nil})
					Endif
					If !Empty(oMulti:aCols[nIX,nPxVldLtFor]) .And. !Empty(oMulti:aCols[nIX,nPxLoteCtl])
						Aadd(aLinha,{"D1_DTVALID"		,oMulti:aCols[nIX,nPxVldLtFor]	,Nil,Nil})						
					Endif
					If !Empty(oMulti:aCols[nIX,nPxDtFabric])
						Aadd(aLinha,{"D1_DFABRIC"		,oMulti:aCols[nIX,nPxDtFabric] 	,Nil,Nil})
					Endif
				Endif

				If nPxFciCod > 0 .And. !Empty(oMulti:aCols[nIX,nPxFciCod])
					Aadd(aLinha,{"D1_FCICOD"			,oMulti:aCols[nIX,nPxFciCod]	,Nil,Nil})
					// Ponto de entrada criado em 20/12/2016
					// Permite que o cliente customize a gravação do código FCI 
					If ExistBlock("XMLCTE15")
						ExecBlock("XMLCTE15",.F.,.F.,{oMulti:aCols[nIX,nPxProd],oMulti:aCols[nIX,nPxFciCod]})
					Endif
				Endif

				If nPxCodCest > 0 .And. !Empty(oMulti:aCols[nIX,nPxCodCest])
					//Aadd(aLinha,{"D1_FCICOD"			,oMulti:aCols[nIX,nPxFciCod]	,Nil,Nil})
					// Ponto de entrada criado em 02/05/2017
					// Permite que o cliente customize a gravação do código CEST  
					If ExistBlock("XMLCTE16")
						ExecBlock("XMLCTE16",.F.,.F.,{oMulti:aCols[nIX,nPxProd],oMulti:aCols[nIX,nPxCodCest]})
					Endif
				Endif

			Endif

			Aadd(aLinha,{"D1_VALDESC"		,oMulti:aCols[nIX,nPxVlDesc]	,Nil,Nil})

			Aadd(aLinha,{"D1_SEGURO"		,oMulti:aCols[nIX,nPxValSeg]	,Nil,Nil})
			Aadd(aLinha,{"D1_DESPESA"		,oMulti:aCols[nIX,nPxValDesp]	,Nil,Nil})
			Aadd(aLinha,{"D1_VALFRE"		,oMulti:aCols[nIX,nPxValFre]	,Nil,Nil})

			nSumF1Descont	+= oMulti:aCols[nIX,nPxVlDesc]
			nSumF1Frete		+= oMulti:aCols[nIX,nPxValFre]
			nSumF1Seguro	+= oMulti:aCols[nIX,nPxValSeg]
			nSumF1Despesa	+= oMulti:aCols[nIX,nPxValDesp]

			// Conforme pergunta 12 - Considera ou não os impostos destacados no XML para fins de importação
			If mv_par12 == 1 .Or. mv_par12 == 5

				// nPxDiBc , nPxDiAlq , nPxDiVII
				If oMulti:aCols[nIX,nPxDiAlq] > 0 .And. SD1->(FieldPos("D1_ALIQII")) > 0
					Aadd(aLinha,{"D1_ALIQII"  ,oMulti:aCols[nIX,nPxDiAlq]			,Nil,Nil})
				Endif

				If oMulti:aCols[nIX,nPxDiVII] > 0 .And. SD1->(FieldPos("D1_II"))  > 0
					Aadd(aLinha,{"D1_II"  ,oMulti:aCols[nIX,nPxDiVII]				,Nil,Nil})
				Endif

				If oMulti:aCols[nIX,nPxBasIpi] > 0
					Aadd(aLinha,{"D1_BASEIPI"	,oMulti:aCols[nIX,nPxBasIpi]		,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxPIpi]	> 0
					Aadd(aLinha,{"D1_IPI"		,oMulti:aCols[nIX,nPxPIpi]			,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxValIpi]	> 0
					Aadd(aLinha,{"D1_VALIPI"	,oMulti:aCols[nIX,nPxValIpi]		,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxBasIcm] > 0
					Aadd(aLinha,{"D1_BASEICM"	,oMulti:aCols[nIX,nPxBasIcm]		,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxPIcm] > 0
					Aadd(aLinha,{"D1_PICM"	 	,oMulti:aCols[nIX,nPxPIcm]			,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxValIcm]	> 0
					Aadd(aLinha,{"D1_VALICM" 	,oMulti:aCols[nIX,nPxValIcm]		,Nil,Nil})
				Endif
				If oMulti:aCols[nIX,nPxBasRet] > 0 
					Aadd(aLinha,{"D1_BRICMS" 	,oMulti:aCols[nIX,nPxBasRet]		,Nil,Nil})
				Endif

				If oMulti:aCols[nIX,nPxMva] > 0
					Aadd(aLinha,{"D1_MARGEM" 	,oMulti:aCols[nIX,nPxMva]				,Nil,Nil})
				Endif

				If oMulti:aCols[nIX,nPxPICMSST] > 0
					Aadd(aLinha,{"D1_ALIQSOL" 	,oMulti:aCols[nIX,nPxPICMSST]			,Nil,Nil})
				Endif

				If oMulti:aCols[nIX,nPxIcmRet] > 0
					Aadd(aLinha,{"D1_ICMSRET"	,oMulti:aCols[nIX,nPxIcmRet]		,Nil,Nil})
				Endif

				If mv_par12 == 1
					If oMulti:aCols[nIX,nPxBasPis] > 0
						Aadd(aLinha,{"D1_BASIMP6"	,oMulti:aCols[nIX,nPxBasPis]		,Nil,Nil})
					Endif
					If oMulti:aCols[nIX,nPxPPis] > 0
						Aadd(aLinha,{"D1_ALQIMP6"	,oMulti:aCols[nIX,nPxPPis]			,Nil,Nil})
					Endif
					If oMulti:aCols[nIX,nPxValPis] > 0
						Aadd(aLinha,{"D1_VALIMP6"	,oMulti:aCols[nIX,nPxValPis]		,Nil,Nil})
					Endif
					If oMulti:aCols[nIX,nPxBasCof] > 0
						Aadd(aLinha,{"D1_BASIMP5"	,oMulti:aCols[nIX,nPxBasCof]		,Nil,Nil})
					Endif
					If oMulti:aCols[nIX,nPxPCof] > 0
						Aadd(aLinha,{"D1_ALQIMP5"	,oMulti:aCols[nIX,nPxPCof]			,Nil,Nil})
					Endif
					If oMulti:aCols[nIX,nPxValCof] > 0
						Aadd(aLinha,{"D1_VALIMP5"	,oMulti:aCols[nIX,nPxValCof]		,Nil,Nil})
					Endif
					Aadd(aLinha,{"D1_CLASFIS"	,oMulti:aCols[nIX,nPxCST]			,Nil,Nil})
				Endif
			Endif
			// 14/03/2017 - Melhoria solicitada por cliente para levar informação da base e valor do ST retidos anteriormente
			If nPxBRetAnt > 0 .And. SD1->(FieldPos(cD1BRetAnt)) > 0
				Aadd(aLinha,{cD1BRetAnt	,oMulti:aCols[nIX,nPxBRetAnt]		,Nil,Nil})
			Endif
			If nPxVRetAnt > 0 .And. SD1->(FieldPos(cD1VRetAnt)) > 0
				Aadd(aLinha,{cD1VRetAnt	,oMulti:aCols[nIX,nPxVRetAnt]		,Nil,Nil})
			Endif

			// Ponto de entrada criado em 22/02/2015
			// Permite que o cliente customize adição de novos campos no vetor de itens
			If ExistBlock("XMLCTE08")
				ExecBlock("XMLCTE08",.F.,.F.,)
			Endif

			Aadd(aItems,aLinha)
			cItemD1	:= Soma1(cItemD1)
		Endif
	Next nForG

	// Alterado em 07/10/2013 para que o valor do Desconto/Despesa/Frete/Seguro sempre sejam levados a partir dos dados do XML
	//
	If !(cTipoBox $ "S") .And. mv_par12 <> 4

		If Val(oTotal:_ICMSTot:_vDesc:TEXT) > 0 .And. nSumF1Descont <> Val(oTotal:_ICMSTot:_vDesc:TEXT)
			Aadd(aCabec,{"F1_DESCONT"	,Val(oTotal:_ICMSTot:_vDesc:TEXT)		,Nil,Nil})
		ElseIf nSumF1Descont > 0 
			Aadd(aCabec,{"F1_DESCONT"	,nSumF1Descont		,Nil,Nil})
		ElseIf Val(oTotal:_ICMSTot:_vDesc:TEXT) > 0 
			Aadd(aCabec,{"F1_DESCONT"	,Val(oTotal:_ICMSTot:_vDesc:TEXT)		,Nil,Nil})
		Endif

		If Val(oTotal:_ICMSTot:_vOutro:TEXT) > 0 .And. nSumF1Despesa <> Val(oTotal:_ICMSTot:_vOutro:TEXT)
			Aadd(aCabec,{"F1_DESPESA"	,Val(oTotal:_ICMSTot:_vOutro:TEXT)		,Nil,Nil})
		ElseIf nSumF1Despesa > 0 
			Aadd(aCabec,{"F1_DESPESA"	,nSumF1Despesa		,Nil,Nil})
		ElseIf Val(oTotal:_ICMSTot:_vOutro:TEXT) > 0
			Aadd(aCabec,{"F1_DESPESA"	,Val(oTotal:_ICMSTot:_vOutro:TEXT) 		,Nil,Nil})
		Endif

		If Val(oTotal:_ICMSTot:_vSeg:TEXT) > 0 .And. nSumF1Seguro <> Val(oTotal:_ICMSTot:_vSeg:TEXT)
			Aadd(aCabec,{"F1_SEGURO"	,Val(oTotal:_ICMSTot:_vSeg:TEXT)		,Nil,Nil})
		ElseIf nSumF1Seguro > 0
			Aadd(aCabec,{"F1_SEGURO"	,nSumF1Seguro		,Nil,Nil})
		ElseIf Val(oTotal:_ICMSTot:_vSeg:TEXT) > 0 
			Aadd(aCabec,{"F1_SEGURO"	,Val(oTotal:_ICMSTot:_vSeg:TEXT)		,Nil,Nil})
		Endif

		If Val(oTotal:_ICMSTot:_vFrete:TEXT) > 0 .And. nSumF1Frete <> Val(oTotal:_ICMSTot:_vFrete:TEXT)
			Aadd(aCabec,{"F1_FRETE"		,Val(oTotal:_ICMSTot:_vFrete:TEXT)		,Nil,Nil})
		ElseIf nSumF1Frete > 0 
			Aadd(aCabec,{"F1_FRETE"		,nSumF1Frete		,Nil,Nil})
		ElseIf Val(oTotal:_ICMSTot:_vFrete:TEXT) > 0 
			Aadd(aCabec,{"F1_FRETE"		,Val(oTotal:_ICMSTot:_vFrete:TEXT)		,Nil,Nil})
		Endif
	Endif

	// Se existe o campo Chave eletronica
	If SF1->(FieldPos("F1_CHVNFE")) > 0
		Aadd(aCabec,{"F1_CHVNFE"		,cChave		,Nil,Nil})
	Endif

	If SF1->(FieldPos("F1_MENNOTA")) > 0 .And. Type("oNF:_InfNfe:_infAdic:_infCpl") <> "U"
		Aadd(aCabec,{"F1_MENNOTA"	,oNF:_InfNfe:_infAdic:_infCpl:TEXT		,Nil,Nil})
	Endif


	// Adicão do campo tipo de frete
	If SF1->(FieldPos("F1_TPFRETE")) > 0 .And. Type("oTransp:_modFrete") <> "U" 
		If Alltrim(oTransp:_modFrete:TEXT)=="0"
			cModFrete := "C"
		ElseIf Alltrim(oTransp:_modFrete:TEXT)=="1"
			cModFrete := "F"
		ElseIf Alltrim(oTransp:_modFrete:TEXT)=="2"
			cModFrete := "T"
		ElseIf Alltrim(oTransp:_modFrete:TEXT)=="9"
			cModFrete := "S"
		Else
			cModFrete	:= ""
		Endif
		// Conforme fonte MATA103X caso haja pedido de compra vinculado na nota e for informado o tipo de frete não permite o lançamento
		//If SF1->(FieldPos("F1_TPFRETE"))>0 
		//IF Len(aNfeDanfe)>0
		//	If lPed .And. Len(Trim(aNFEDanfe[14]))>0   //Tem PC vinculado a Nota e Tipo de Frete esta preenchido
		//lRet:=.F.
		//	EndIf
		//EndIf
		//EndIf	
		// Somente se não houver pedido de compra informado 
		If !lExistSC7
			Aadd(aCabec,{"F1_TPFRETE"		,RetTipoFrete(cModFrete) 	,Nil,Nil})
		Endif

		// Faz a comparação do tipo de frete informado no pedido de compra com o tipo de frete informado no xml quando rotina de prenota automatica estiver ativado
		If lAutoExec .And. GetNewPar("XM_PRNFAUT",.F.)
			If cTpFretePed <> cModFrete
				sfAtuXmlOk("TF")
				Return .T.
			Endif
			// Verifica se o campo existe na SC7
			If SC7->(FieldPos("C7_TRANSP")) <> 0 .And. Type("oTransp:_transporta:_CNPJ") <> "U"
				DbSelectArea("SA4")
				DbSetOrder(3)
				DbSeek(xFilial("SA4")+oTransp:_transporta:_CNPJ:TEXT)
				cF1Transp	:= SA4->A4_COD
			Endif 
			// Somente se o Tipo Frete for FOB ou Terceiros e a transportadora não for igual ao do pedido
			If cModFrete $ "F#T" .And. cC7Transp <> cF1Transp
				//sfAtuXmlOk("A4")
				//Return .T.
			Endif
		Endif	
	Endif

	If SF1->(FieldPos("F1_PLACA")) > 0 .And. Type("oTransp:_veicTransp:_placa") <> "U"
		cF1Placa	:= oTransp:_veicTransp:_placa:TEXT
		Aadd(aCabec,{"F1_PLACA"		,	cF1Placa	,Nil,Nil})
	Endif

	If SF1->(FieldPos("F1_PBRUTO")) > 0 .And. Type("oTransp:_vol:_pesoB") <> "U"
		Aadd(aCabec,{"F1_PBRUTO"		,Val(oTransp:_vol:_pesoB:TEXT)	,Nil,Nil})
	Endif
	If SF1->(FieldPos("F1_PLIQUI")) > 0 .And. Type("oTransp:_vol:_pesoL") <> "U"
		Aadd(aCabec,{"F1_PLIQUI"		,Val(oTransp:_vol:_pesoL:TEXT)	,Nil,Nil})
	Endif

	// 25/09/2016 - Verifica rotina automática - Se ativado processo Prenota para automatico e se o documento tem nota de origem 
	If lAutoExec .And. GetNewPar("XM_PRNFAUT",.F.) .And. lTemNfOri
		sfAtuXmlOk("RO")
		Return .T.
	Endif
	//MsgAlert("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),aArqXml[oArqXml:nAt,nPosChvNfe])
	If Len(aItems) > 0

		nModBk		:= nModulo
		cModBk		:= cModulo
		nModulo		:= 02
		cModulo		:= "COM"

		lContinua	:= .F.


		If lAutoExec .And. GetNewPar("XM_PRNFAUT",.F.) .And. !lTemNfOri// Melhoria 24/09/2016 - Drugovich - Se o lançamento da nota não gera nenhuma restrição, aborta para gravar flag de Ok para lançar como pré-nota
			ConOut("+"+Replicate("-",98)+"+")
			ConOut("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+aArqXml[oArqXml:nAt,nPosChvNfe])
			ConOut("+"+Replicate("-",98)+"+")
			// Força alteração do valor da variável para sempre validar primeiro como NF e ver se tudo está Ok, para então gerar Prenota automaticamente
			//lCheck	:= .F. 

			DbSelectArea("SC7")
			DbSetOrder(1)
			DbGotop()

			U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],aItems,.F.,,,.F./*lCheck*/,aCabec)

			If CONDORXML->XML_OK == "PN"

				lMsErroAuto	:= .F. 

				DbSelectArea("SC7")
				DbSetOrder(1)
				DbGotop()
				// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
				Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
				lPreNfe	:= .T.
			Endif

			//MsgAlert("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),aArqXml[oArqXml:nAt,nPosChvNfe])
			// Adicionada validação que força o lançamento como Prenota caso algum item não tenha sido lançado um TES	
		Elseif lForcePreNf
			// Com interface
			If !lAutoExec
				If MsgYesNo("Nem todos os campos de TES foram preenchidos nos itens. Deseja continuar o lançamento como Prenota?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Lançamento de Pré-nota!")
					lContinua	:= .T.
					DbSelectArea("SC7")
					DbSetOrder(1)
					DbGotop()
					//Begin Transaction
					// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
					Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
					//MSExecAuto({|x,y,z|Mata140(x,y,z,w,q)},aCabec,aItems,3,,Iif(lCheck,1,0))
					lPreNfe	:= .T.
					//End Transaction
					sfAtuXmlOk("PR")
				Endif
			Else
				lContinua	:= .F.
				sfAtuXmlOk("PR")
			Endif
			//MsgAlert("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),aArqXml[oArqXml:nAt,nPosChvNfe])
		ElseIf lSuperUsr
			If GetNewPar("XM_MSGPRNF",.T.)
				ConOut("+"+Replicate("-",98)+"+")
				ConOut("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+aArqXml[oArqXml:nAt,nPosChvNfe])
				ConOut("+"+Replicate("-",98)+"+")

				If !lAutoExec
					If !MsgNoYes("Gerar lançamento de pré-nota? Sim=Pré-Nota; Não=Nota Fiscal",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")
						DbSelectArea("SC7")
						DbSetOrder(1)
						DbGotop()
						U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],aItems,.F.,,,lCheck)
						
						If GetNewPar("XM_PRNFAUT",.F.) .And. !lTemNfOri
							If CONDORXML->XML_OK == "PN"

								lMsErroAuto	:= .F. 

								DbSelectArea("SC7")
								DbSetOrder(1)
								DbGotop()
								// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
								Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
								lPreNfe	:= .T.
							Endif
						Endif
					Else
						DbSelectArea("SC7")
						DbSetOrder(1)
						DbGotop()
						//Begin Transaction
						// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
						Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
						//MSExecAuto({|x,y,z|Mata140(x,y,z,w,q)},aCabec,aItems,3,,Iif(lCheck,1,0))
						lPreNfe	:= .T.
						//End Transaction
					Endif
				Else
					U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],aItems,.F.,,,lCheck,aCabec)
					If GetNewPar("XM_PRNFAUT",.F.) .And. !lTemNfOri
						If CONDORXML->XML_OK == "PN"

							lMsErroAuto	:= .F. 
							DbSelectArea("SC7")
							DbSetOrder(1)
							DbGotop()
							// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
							Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
							lPreNfe	:= .T.
						Endif
					Endif
				Endif
			Else
				U_XMLMT103(aArqXml[oArqXml:nAt,nPosChvNfe],aItems,.F.,,,lCheck,aCabec)
			Endif
			//MsgAlert("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),aArqXml[oArqXml:nAt,nPosChvNfe])
		ElseIf lComprUsr
			ConOut("+"+Replicate("-",98)+"+")
			ConOut("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+aArqXml[oArqXml:nAt,nPosChvNfe])
			ConOut("+"+Replicate("-",98)+"+")
			If !lAutoExec
				If MsgYesNo("Deseja gerar Pré-Nota?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")
					lContinua	:= .T.
				Endif
			Else
				lContinua	:= .T.
			Endif
			If lContinua
				DbSelectArea("SC7")
				DbSetOrder(1)
				DbGotop()
				//Begin Transaction
				// nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
				Mata140(aCabec,aItems,3,,Iif(lCheck,1,0))
				//MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItems,3)
				lPreNfe	:= .T.
				//End Transaction
			Endif
			//MsgAlert("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),aArqXml[oArqXml:nAt,nPosChvNfe])
		Endif

		If lMsErroAuto

			// Valido que o documento realmente está lançado no sistema mesmo que tenha sido exibido algum erro
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(XFilial("SF1")+cNumDoc+cSerDoc+Iif(cTipoBox $"N#C#I#P#S",SA2->A2_COD+SA2->A2_LOJA+cTipoBox,SA1->A1_COD+SA1->A1_LOJA+cTipoBox))

				// Adicionada gravação dos itens para garantir que informações realmente sejam gravadas na CONDORXMLITENS
				// e para forçar a atualização do campo XIT_KEYSD1
				stGrvItens()
				//Reposiciona o registro da chave eletronica
				U_DbSelArea("CONDORXML",.F.,1)
				Set Filter To
				If DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
					RecLock("CONDORXML",.F.)
					CONDORXML->XML_KEYF1		:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
					CONDORXML->XML_LANCAD		:= SF1->F1_DTDIGIT
					CONDORXML->XML_HORLAN 		:= Time()
					CONDORXML->XML_USRLAN		:= Padr(cUserName,30)
					CONDORXML->XML_NUMNF		:= SF1->F1_SERIE+SF1->F1_DOC
					If CONDORXML->XML_TIPODC $ "N#D#B"
						CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
					Endif
					MsUnlock()
				Endif

				If Empty(SF1->F1_CHVNFE)
					DbSelectArea("SF1")
					RecLock("SF1",.F.)
					SF1->F1_CHVNFE	:= cChave
					MsUnlock()
				Endif
				
				// Melhoria adicionada em 15/07/2017 - Para gravar a placa do veículo da Transportadora na Prénota. 
				If SF1->(FieldPos("F1_PLACA")) > 0 .And. !Empty(cF1Placa) .And. Empty(SF1->F1_PLACA)
					DbSelectArea("SF1")
					RecLock("SF1",.F.)
					SF1->F1_PLACA	:= cF1Placa
					MsUnlock()
					
				Endif
				
				If !lAutoExec
					MsgAlert(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - DOC.GERADO ")
				Endif
				//			cRecebe		:= "marcelolauschner@gmail.com"
				cRecebe			:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
				cAssunto 		:= IIf(lPreNfe,"Pré-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " - " + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM)
				cMensagem		:= IIf(lPreNfe,"Pré-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " lançada no sistema no dia " + Dtoc( Date() ) + " as " + Time() + " por "+cUserName
				cMensagem 		+= "-" + UsrFullName(__cUserId) + Chr(13)+Chr(10)
				ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				ConOut(cMensagem)

				stSendMail( cRecebe, cAssunto, cMensagem )
				// Adicionado em 05/12/2014
				// Se existir o rdmake executa a função de liberação de estoque automática
				If ExistBlock("BFFATM23")
					StartJob("U_BFFATM23",GetEnvServer(),.F.,{cEmpAnt,cFilAnt,__cUserId},.T./*lAuto*/)
				Endif

			Else

				If !lAutoExec
					MostraErro()
					// Zero variavel de duplicatas
					aDupSE2		:= {}
					nSumSE2		:= 0
					lDupSE4		:= .F.
					aDupAxSE2	:= {}

					// Seto as teclas de atalho a cada refresh da tela
					sfSetKeys()


					RestArea(aAreaOld)
					Return .F. 
				Else
					aLog := GetAutoGRLog()
					cMensLog	:= ""
					For nX := 1 To Len(aLog)
						cMensLog += aLog[nX]+CHR(13)+CHR(10)
					Next nX
					aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
					Pergunte("XMLDCONDOR",.F.)
					//Reposiciona o registro da chave eletronica
					U_DbSelArea("CONDORXML",.F.,1)
					Set Filter To
					If DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
						sfAtuXmlOk("GR",,,cMensLog)
						StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
					Endif
				Endif
				DisarmTransaction()


			Endif

			ConOut("+"+Replicate("-",98)+"+")
			ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			ConOut("+"+Replicate("-",98)+"+")

		Else
			ConOut("+"+Replicate("-",98)+"+")
			ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Chave " + aArqXml[oArqXml:nAt,nPosChvNfe])
			ConOut("+"+Replicate("-",98)+"+")

			// Valido que o documento realmente está lançado no sistema
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(XFilial("SF1")+cNumDoc+cSerDoc+Iif(cTipoBox $"N#C#I#P#S",SA2->A2_COD+SA2->A2_LOJA+cTipoBox,SA1->A1_COD+SA1->A1_LOJA+cTipoBox))

				// Adicionada gravação dos itens para garantir que informações realmente sejam gravadas na CONDORXMLITENS
				// e para forçar a atualização do campo XIT_KEYSD1
				stGrvItens()
				//Reposiciona o registro da chave eletronica
				U_DbSelArea("CONDORXML",.F.,1)
				Set Filter To
				If DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
					RecLock("CONDORXML",.F.)
					CONDORXML->XML_KEYF1		:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
					CONDORXML->XML_LANCAD		:= SF1->F1_DTDIGIT
					CONDORXML->XML_HORLAN 		:= Time()
					CONDORXML->XML_USRLAN		:= Padr(cUserName,30)
					CONDORXML->XML_NUMNF		:= SF1->F1_SERIE+SF1->F1_DOC
					If CONDORXML->XML_TIPODC $ "N#D#B"
						CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
					Endif 
					MsUnlock()
				Endif
				If Empty(SF1->F1_CHVNFE)
					DbSelectArea("SF1")
					RecLock("SF1",.F.)
					SF1->F1_CHVNFE	:= cChave
					MsUnlock()
				Endif
				// Melhoria adicionada em 15/07/2017 - Para gravar a placa do veículo da Transportadora na Prénota. 
				If SF1->(FieldPos("F1_PLACA")) > 0 .And. !Empty(cF1Placa) .And. Empty(SF1->F1_PLACA)
					DbSelectArea("SF1")
					RecLock("SF1",.F.)
					SF1->F1_PLACA	:= cF1Placa
					MsUnlock()					
				Endif
				
				If !lAutoExec
					MsgAlert(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - DOC.GERADO ")
				Else
					//stSendMail( "marcelolauschner@gmail.com", "Executou processo stGeranNFe "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+CONDORXML->XML_CHAVE + " - " + Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - DOC.GERADO ")
				Endif

				//			cRecebe		:= "marcelolauschner@gmail.com"
				cRecebe			:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
				cAssunto 		:= IIf(lPreNfe,"Pre-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " - " + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM)
				cMensagem		:= IIf(lPreNfe,"Pre-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " lancada no sistema no dia " + Dtoc( Date() ) + " as " + Time() + " por "+cUserName
				cMensagem 		+= "-" + UsrFullName(__cUserId) + Chr(13)+Chr(10)
				ConOut(Padr("|"+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),98)+"|")
				ConOut(Padr("|"+cMensagem,98)+"|")
				stSendMail( cRecebe, cAssunto, cMensagem )
				// Adicionado em 05/12/2014
				// Se existir o rdmake executa a função de liberação de estoque automática
				If ExistBlock("BFFATM23")
					StartJob("U_BFFATM23",GetEnvServer(),.F.,{cEmpAnt,cFilAnt,__cUserId},.T./*lAuto*/)
				Endif

			Else
				RecLock("CONDORXML",.F.)
				CONDORXML->XML_KEYF1	:= " "
				CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
				CONDORXML->XML_HORLAN 	:= " "
				CONDORXML->XML_USRLAN	:= " "
				MsUnlock()
			Endif
			ConOut("+"+Replicate("-",98)+"+")

		Endif
		nModulo	:= nModBk
		cModulo	:= cModBk

	Endif

	// Zero variavel de duplicatas
	aDupSE2		:= {}
	nSumSE2		:= 0
	lDupSE4		:= .F.
	aDupAxSE2	:= {}

	// Seto as teclas de atalho a cada refresh da tela
	sfSetKeys()


	RestArea(aAreaOld)

Return .T.


/*/{Protheus.doc} sfConferid
(Atualiza status da nota como conferida pelo Compras)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfConferid()

	U_DbSelArea("CONDORXML",.F.,1)

	If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
		If !lAutoExec
			MsgAlert("Erro ao localizar registro",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
		Return
	Endif

	If !Empty(CONDORXML->XML_KEYF1)
		MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
		Return
	Endif

	If nTotalNfe <> nTotalXml
		MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra! Favor conferir novamente!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Conferência incompleta!")
		Return
	Endif

	If !Empty(CONDORXML->XML_CONFCO)
		If MsgYesNo("Nota fiscal já foi conferida em "+DTOC(CONDORXML->XML_CONFCO)+". Deseja limpar status de conferência do Compras?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")
			RecLock("CONDORXML",.F.)
			CONDORXML->XML_CONFCO	:= CTOD("  /  /  ")
			CONDORXML->XML_HORCCO	:= " "
			MsUnlock()
		Endif
	Else
		If MsgYesNo("Deseja marcar a Nota fiscal como conferida pelo Compras?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")

			// Se retorno verdadeiro da gravação dos itens.
			// A função valida se há obrigatoriedade de pedido de compra
			If stGrvItens(.T.,CONDORXML->XML_CHAVE)
				RecLock("CONDORXML",.F.)
				CONDORXML->XML_CONFCO	:= Date()
				CONDORXML->XML_HORCCO	:= Time()
				CONDORXML->XML_USRCCO	:= Padr(cUserName,30)
				MsUnlock()

				cRecebe		:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
				cAssunto 	:= "Nota Fiscal "+ aArqXml[oArqXml:nAt,2] + " - " + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM)
				cMensagem	:= "Nota Fiscal "+aArqXml[oArqXml:nAt,2	] + " conferida pelo Compras no dia " + Dtoc( Date() ) + " as " + Time() + " por "+cUserName
				cMensagem 	+= "-" + UsrFullName(__cUserId) + Chr(13)+Chr(10)

				stSendMail( cRecebe, cAssunto, cMensagem )
			Endif
		Endif
	Endif

Return


/*/{Protheus.doc} XMLVLEDT
(Valida a edição ou exclusão de registros do GetDados, entre outras opções)
@author MarceloLauschner
@since 05/06/2012
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function XMLVLEDT()

	Local	lRet		:= .T.
	Local	iX
	Local	lAlterLoc	:= .F.
	Local	cArmDig		:= "01"
	Local	cVarAux

	If !Empty(CONDORXML->XML_KEYF1)
		MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
		Return .F.
	Endif

	If ReadVar() == "M->D1_LOCAL"

		cArmDig	:= M->D1_LOCAL

		For iX := 1 To Len(oMulti:aCols)
			If !oMulti:aCols[iX,Len(oMulti:aHeader)+1]
				If cArmDig <> oMulti:aCols[iX,nPxLocal] .And. iX # oMulti:nAt
					lAlterLoc	:= .T.
					Exit
				Endif
			Endif
		Next

		If lAlterLoc
			If MsgYesNo("O armazém digitado é diferente  do armazém de outros itens desta nota. Deseja usar o novo armazém em todos os itens?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca de armazém!")
				For iX := 1 To Len(oMulti:aCols)
					If iX # oMulti:nAt
						oMulti:aCols[iX,nPxLocal]	:= cArmDig
					Endif
				Next
			Endif
		Endif
	ElseIf ReadVar() == "M->D1_LOTECTL"

		cVarAux	:= M->D1_LOTECTL

		For iX := 1 To Len(oMulti:aCols)
			If !oMulti:aCols[iX,Len(oMulti:aHeader)+1]
				If cVarAux <> oMulti:aCols[iX,nPxLoteCtl] .And. iX # oMulti:nAt
					lAlterLoc	:= .T.
					Exit
				Endif
			Endif
		Next

		If lAlterLoc
			If MsgYesNo("O Lote digitado é diferente do lote de outros itens desta nota. Deseja usar o novo lote em todos os itens?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca de Lote!")
				For iX := 1 To Len(oMulti:aCols)
					If iX # oMulti:nAt
						oMulti:aCols[iX,nPxLoteCtl]	:= cVarAux
					Endif
				Next
			Endif
		Endif
	ElseIf ReadVar() == "M->D1_LOTEFOR"

		cVarAux	:= M->D1_LOTEFOR

		For iX := 1 To Len(oMulti:aCols)
			If !oMulti:aCols[iX,Len(oMulti:aHeader)+1]
				If cVarAux <> oMulti:aCols[iX,nPxLoteFor] .And. iX # oMulti:nAt
					lAlterLoc	:= .T.
					Exit
				Endif
			Endif
		Next

		If lAlterLoc
			If MsgYesNo("O Lote Fornecedor digitado é diferente do lote fornecedor de outros itens desta nota. Deseja usar o novo lote em todos os itens?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca de Lote!")
				For iX := 1 To Len(oMulti:aCols)
					If iX # oMulti:nAt
						oMulti:aCols[iX,nPxLoteFor]	:= cVarAux
					Endif
				Next
			Endif
		Endif
	ElseIf ReadVar() == "M->D1_NUMLOTE"

		cVarAux	:= M->D1_NUMLOTE

		For iX := 1 To Len(oMulti:aCols)
			If !oMulti:aCols[iX,Len(oMulti:aHeader)+1]
				If cVarAux <> oMulti:aCols[iX,nPxNumLote] .And. iX # oMulti:nAt
					lAlterLoc	:= .T.
					Exit
				Endif
			Endif
		Next

		If lAlterLoc
			If MsgYesNo("O Sub-Lote digitado é diferente do Sub-loter de outros itens desta nota. Deseja usar o novo sub-lote em todos os itens?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca de Lote!")
				For iX := 1 To Len(oMulti:aCols)
					If iX # oMulti:nAt
						oMulti:aCols[iX,nPxNumLote]	:= cVarAux
					Endif
				Next
			Endif
		Endif

	Endif


Return lRet


/*/{Protheus.doc} stSendMail
(long_description)

@author MarceloLauschner
@since 15/01/2014
@version 1.0

@param cRecebe, character, (Descrição do parâmetro)
@param cAssunto, character, (Descrição do parâmetro)
@param cMensagem, character, (Descrição do parâmetro)
@param lExibSend, logico, Exibe mensagem de email enviado

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stSendMail( cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName )

	Local		aAreaOld	:= GetArea()
	Local		oMessageA1	
	Local		oSendSrv
	Local		cCorpoM		:= ""
	Local		lIsDebug	:= GetNewPar("XM_DBGRXML",.F.) 
	Default 	lExibSend	:= .F.
	Default		cArqAttAch	:= ""
	Default		cAttachName	:= ""

	If Empty(cRecebe)
		Return
	Endif

	//Crio a conexão com o server STMP ( Envio de e-mail )
	oSendSrv := TMailManager():New()


	// Usa SSL na conexao
	If GetMv("XM_SMTPSSL")
		oSendSrv:setUseSSL(.T.)
	Endif

	// Usa TLS na conexao
	If GetNewPar("XM_SMTPTLS",.F.)
		oSendSrv:SetUseTLS(.T.)
	Endif

	oSendSrv:Init( ""		,Alltrim(GetMv("XM_SMTP")), Alltrim(GetMv("XM_SMTPUSR"))	,Alltrim(GetMv("XM_PSWSMTP")),	0			, GetMv("XM_SMTPPOR") )

	//seto um tempo de time out com servidor de 1min
	If oSendSrv:SetSmtpTimeOut( GetMv("XM_SMTPTMT") ) != 0
		Conout( "Falha ao setar o time out" )
		RestArea(aAreaOld)
		Return .F.
	EndIf

	//realizo a conexão SMTP
	If oSendSrv:SmtpConnect() != 0
		Conout( "Falha ao conectar" )
		RestArea(aAreaOld)
		Return .F.
	EndIf

	// Realiza autenticacao no servidor
	If GetMv("XM_SMTPAUT")
		nErr := oSendSrv:smtpAuth(Alltrim(GetMv("XM_SMTPUSR")), Alltrim(GetMv("XM_PSWSMTP")))
		If nErr <> 0
			ConOut("[ERROR]Falha ao autenticar: " + oSendSrv:getErrorString(nErr))
			If lExibSend
				MsgAlert("[ERROR]Falha ao autenticar: " + oSendSrv:getErrorString(nErr),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Endif
			oSendSrv:smtpDisconnect()
			RestArea(aAreaOld)
			Return .F.
		Endif
	Endif
	//Apos a conexão, crio o objeto da mensagem
	oMessageA1 := TMailMessage():New()
	//Limpo o objeto
	oMessageA1:Clear()
	//Populo com os dados de envio
	oMessageA1:cFrom 		:= GetMv("XM_SMTPDES")
	oMessageA1:cTo 			:= Iif(lIsDebug,GetNewPar("XM_MAILADM","contato@centralxml.com.br"), cRecebe)
	If Type("lMadeira") == "L" .And. !lMadeira
		oMessageA1:cBcc 		:= "contato@centralxml.com.br"
	Endif
	oMessageA1:cSubject 	:= cAssunto
	cMensagem 		:= StrTran(cMensagem,Chr(13)+ Chr(10),"<br>")
	cMensagem		:= StrTran(cMensagem,Chr(13),"<br>")
	cMensagem		:= StrTran(cMensagem,CRLF,"<br>")

	cCorpoM += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "
	cCorpoM += "<html xmlns='www.w3.org/1999/xhtml'> "
	cCorpoM += "<head> "
	cCorpoM += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' /> "
	cCorpoM += "<style type='text/css'> "
	cCorpoM += "<!-- "
	cCorpoM += "body,td,th { "
	cCorpoM += "	font-family: Arial, Helvetica, sans-serif; "
	cCorpoM += "	font-size: 12pt; "
	cCorpoM += "} "
	cCorpoM += "--> "
	cCorpoM += "</style></head> "
	cCorpoM += "<body> "
	cCorpoM += "<br>"
	cCorpoM += AllTrim(cMensagem)
	cCorpoM += "<br>"
	cCorpoM += "<br>"
	cCorpoM += "<br>"
	cCorpoM += "<br>"
	cCorpoM += "Este email é disparado automaticamente pela rotina Central XML - Favor não Responder."
	cCorpoM += "<br>"
	cCorpoM += "________________________________________________________________________"
	cCorpoM += "<br>"


	cCorpoM += "Powered by Central XML. - " +"Versão : " + GetNewPar("XM_CTRLVRS","Central XML - 4.2017D-10A")
	cCorpoM += "</body> "
	cCorpoM += "</html>"

	oMessageA1:MsgBodyType( "text/html" )

	oMessageA1:cBody 		:= cCorpoM //cMensagem

	//Adiciono um attach
	If !Empty(cArqAttAch)
		If oMessageA1:AttachFile( cArqAttAch) < 0
			Conout( "Erro ao atachar o arquivo " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
			//	MsgAlert("Não foi possível anexar o arquivo.","Erro" )
		Else
			//adiciono uma tag informando que é um attach e o nome do arq
			oMessageA1:AddAtthTag( 'Content-Disposition: attachment; filename='+Alltrim(cAttachName))
		EndIf
	Endif

	//Envio o e-mail
	If oMessageA1:Send( oSendSrv ) != 0
		Conout( "Erro ao enviar o e-mail XMLDCONDOR.stSendMail " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) ) 
		Conout( "Erro ao enviar o e-mail XMLDCONDOR.stSendMail " + ProcName(1)+"."+ Alltrim(Str(ProcLine(1))) ) 
		Conout( "Erro ao enviar o e-mail XMLDCONDOR.stSendMail " + ProcName(2)+"."+ Alltrim(Str(ProcLine(2))) ) 
		RestArea(aAreaOld)
		Return .F.
	Else
		If lExibSend
			MsgAlert("Email enviado com sucesso!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Concluído")
		Endif
	EndIf

	//Disconecto do servidor
	If oSendSrv:SmtpDisconnect() != 0
		Conout( "Erro ao disconectar do servidor SMTP" )
		RestArea(aAreaOld)
		Return .F.
	EndIf

Return


/*/{Protheus.doc} stExpExcel
(Efetua a exportação do Getdados para excel   )

@author Marcelo Lauschner
@since 20/02/2012
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
Static Function stExpExcel()

	If FindFunction("RemoteType") .And. RemoteType() == 1
		DlgToExcel({{"GETDADOS","Importação de Arquivo XML",aHeadXml,oMulti:aCols}})
	EndIf

Return



/*/{Protheus.doc} stRejeita
(Interface para recusa da Nf-e com envio de email )

@author Marcelo Lauschner
@since 15/01/2014
@version 1.0

@param cChave, character, Chave eletronica
@param cMsgCanc, character, (Descrição do parâmetro)
@param lExecAuto, logico, (Descrição do parâmetro)
@param lRejSefaz, logico,
@param cRejSefaz, character, (Descrição do parâmetro)

@return logico,

@example
(examples)

@see (links_or_references)
/*/
Static Function stRejeita(cChave,cMsgCanc,lExecAuto,lRejSefaz,cRejSefaz)

	Local	oRejSrv
	Local 	oMessage
	Local	oDlgEmail
	Local	cMensagem	:= ""
	Local	cAssunto	:= ""
	Local	cRecebe		:= Space(100)
	Local 	aAreaOld	:= GetArea()
	Local	aAreaAux	
	Local	iW
	Local	cDirNfe    	:= GetNewPar("XM_DIRXML",IIf(IsSrvUnix(),"/Nf-e/", "\Nf-e\"))
	Local	lSendMail	:= .F.
	Local	cArqAttAch	:= ""
	Local 	cAttachName	:= ""
	Default	cMsgCanc	:= ""
	Default	lExecAuto	:= .F.
	Default	lRejSefaz	:= .F.
	Default	cRejSefaz	:= ""

	U_DbSelArea("CONDORXML",.F.,1)
	If DbSeek(cChave)
	
	Else
		RestArea(aAreaOld)
		Return .F.
	Endif
	
	// Se a nota já estiver rejeitada não executa novamente.
	If !Empty(CONDORXML->XML_REJEIT)
		RestArea(aAreaOld)
		Return .F.
	Endif
	

	If !Empty(CONDORXML->XML_KEYF1)
		If !lExecAuto
			MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Rejeição não permitida!")
		Endif

		// Melhoria de aviso de que a nota fiscal que se está tentando rejeitar, já consta como lançada no sistema
		cRecebe	:= ""
		cRecebe	:= StrTran(Iif(File("xmusrxmln_"+cEmpAnt+".usr"),MemoRead("xmusrxmln_"+cEmpAnt+".usr"),GetNewPar("XM_USRXMLN","") ),"/","#")	// Muda pra #
		cRecebe	:= StrTran(cRecebe,";","#")
		cRecebe	:= StrTran(cRecebe,"|","#")
		cRecebe	:= StrTran(cRecebe," ","#")
		cRecebe	:= StrTran(cRecebe,"-","#")
		cRecebe	:= StrTran(cRecebe,"\","#")
		aOutMails	:= StrTokArr(cRecebe,"#")
		cRecebe	:= ""
		For iW := 1 To Len(aOutMails)
			If iW > 1
				cRecebe += ";"
			Endif
			cRecebe	+= Alltrim(UsrRetMail(aOutMails[iW]))
		Next

		cRecebe += ";"+GetNewPar("XM_MAILREJ","")

		cAssunto 	:= "Rejeição não permitida de NFe/Cte já lançada  '"+CONDORXML->XML_NUMNF+"' na Empresa:" + cEmpAnt+"/"+cFilAnt+" "  + Capital(SM0->M0_NOMECOM)
		cMensagem	:= "A NF-e/CT-e já está lançada no sistema mas recebeu uma solicitação de rejeição" + CRLF
		If lRejSefaz
			cMensagem	+= 	cRejSefaz + CRLF
		Endif
		cMensagem	+= "Empresa  :" + cEmpAnt+"/"+cFilAnt+" " + Capital(SM0->M0_NOMECOM) + CRLF
		cMensagem	+= "Chave Sistema  :"+Alltrim(CONDORXML->XML_KEYF1) + CRLF
		cMensagem	+= "Chave eletrônica  :"+Alltrim(cChave) + CRLF

		stSendMail( cRecebe, cAssunto, cMensagem )

		RestArea(aAreaOld)

		Return .F.
	Endif
	// 26/08/2017 - Se for um Cancelamento identificado pelo TSS da Sefaz atualiza Status na tabela C00 
	
	If lRejSefaz
		aAreaAux	:= GetArea()
		DbSelectArea("C00")
		DbsetOrder(1)
		If DbSeek( xFilial("C00") + cChave)
			RecLock("C00",.F.)
			C00->C00_SITDOC   := "3"
			MsUnLock()
		Endif
		RestArea(aAreaAux)
	Endif
	
	If CONDORXML->XML_TIPODC $ "N#F#T#S"
		If !Empty(CONDORXML->XML_CODLOJ)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
				cRecebe 	:= Alltrim(SA2->A2_EMAIL)
				cCodForn	:= SA2->A2_COD
				cLojForn	:= SA2->A2_LOJA
				// Verifica se não houve um erro de atribuição de Código/Loja e força nova verificação
				If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
					DbSelectArea("SA2")
					DbSetOrder(3)
					DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA
					sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+cCodForn+cLojForn)
					cRecebe	:= Alltrim(SA2->A2_EMAIL)
				Endif
			Endif
		Else
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
				cCodForn	:= SA2->A2_COD
				cLojForn	:= SA2->A2_LOJA
				sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+cCodForn+cLojForn)
				cRecebe 	:= Alltrim(SA2->A2_EMAIL)
			Endif
		Endif
	Endif
	// Melhorado lista de destinatários da rejeição por causa de Cancelamento em virtude de informar o Fornecedor da rejeição
	// 28/11/2014 - Melhoria para evitar que CFROM seja a própria caixa postal da Central XML, evitando Loop
	cRecebe := IIf(!Empty(cRecebe),cRecebe+";","")
	cRecebe += GetNewPar("XM_MAILREJ","")

	aOutMails	:= StrTokArr(cRecebe,";")
	cRecebe	:= ""
	For iW := 1 To Len(aOutMails)
		If !Empty(cRecebe)
			cRecebe += ";"
		Endif
		If IsEmail(aOutMails[iW]) .And. !(Alltrim(Upper(GetMv("XM_POPUSR"))) $ Alltrim(Upper(aOutMails[iW])))
			cRecebe	+= aOutMails[iW]
		Endif
	Next


	cRecebe		:= Padr(cRecebe,250)


	cSubject    	:= "Rejeição de Nota fiscal Eletrônica:" +CONDORXML->XML_NUMNF

	cBody		:= "Motivo:  "+ CRLF
	cBody		+= cMsgCanc + CRLF
	cBody 		+= "Por meio deste email notificamos que estamos rejeitando"+Chr(13)+Chr(10)+"o recebimento da NF-e/CT-e : "+CONDORXML->XML_NUMNF + CRLF
	cBody 		+= "Chave: "+CONDORXML->XML_CHAVE + CRLF
	cBody 		+= "emitida em : "+DTOC(CONDORXML->XML_EMISSA)+ " para: "+Transform(CONDORXML->XML_DEST,"@R 99.999.999/9999-99")+"-"+CONDORXML->XML_NOMEDT + CRLF
	cBody		+= CONDORXML->XML_SUBJECT+ CRLF + CONDORXML->XML_BODY
	lSendMail	:= .F.

	If !lExecAuto
		DEFINE MSDIALOG oDlgEmail Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Enviar email de Rejeição da Nota Fiscal Eletrônica") FROM 001,001 TO 380,620 PIXEL
		@ 010,010 Say "Para: " Pixel of oDlgEmail
		@ 010,050 MsGet cRecebe Size 180,10 Pixel Of oDlgEmail
		@ 025,010 Say "Assunto" Pixel of oDlgEmail
		@ 025,050 MsGet cSubject Size 250,10 Pixel Of oDlgEmail
		@ 040,050 Get cBody of oDlgEmail MEMO Size 250,100 Pixel
		@ 160,050 BUTTON "Envia Email" Size 70,10 Action( lSendMail := .T.,oDlgEmail:End())	Pixel Of oDlgEmail
		@ 160,130 BUTTON "Cancela" Size 70,10 Action (oDlgEmail:End())	Pixel Of oDlgEmail

		ACTIVATE MsDialog oDlgEmail Centered
	Else
		lSendMail	:= .T.
	Endif

	If lSendMail
		DbSelectArea("CONDORXML")
		RecLock("CONDORXML",.F.)
		CONDORXML->XML_REJEIT	:= Date()
		CONDORXML->XML_BODY		:= cBody
		CONDORXML->XML_KEYF1	:= " "
		CONDORXML->XML_LANCAD	:= CTOD("  /  /  ")
		CONDORXML->XML_HORLAN 	:= " "
		CONDORXML->XML_USRREJ	:= Padr(cUserName,30)
		MsUnlock()
		// 11/04/2017 - Melhoria que usa função stSendmail para enviar a alerta sobre a rejeição da nota. 
		cArqAttAch	:=  cDirNfe+Alltrim(CONDORXML->XML_CHAVE)+".xml" 
		cAttachName	:=  Alltrim(CONDORXML->XML_CHAVE)+'.xml'

		MemoWrite(cArqAttAch,CONDORXML->XML_ARQ)

		stSendMail( cRecebe, cSubject, cBody, .T./*lExibSend*/, cArqAttAch, cAttachName )

		fErase(cArqAttAch)

	Endif
	RestArea(aAreaOld)

Return .T.




/*/{Protheus.doc} stViewNfe
(Exporta o xml e abre pelo SO )

@author Marcelo Lauschner
@since 02/12/2013
@version 1.0
@example
(examples)

@see (links_or_references)
/*/
Static Function stViewNfe(nOpcView,cInChve)

	Local		cTempPath 	:= GetTempPath(.T.)
	Local		cLocDir		:= cTempPath
	Local		a
	Local		aAreaOld	:= GetArea()
	Default	nOpcView		:= 1
	Default	cInChve			:= Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])

	U_DbSelArea("CONDORXML",.F.,1)
	If !DbSeek(cInChve)
		MsgAlert("Não há arquivo XML para esta chave eletrônica '" + cInChve + "' na Central XML!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem Arquivo!")
		RestArea(aAreaOld)
		Return
	Endif

	If nOpcView == 1 // Danfe PDF Original
		If !Empty(CONDORXML->XML_ATT2) .And. MsgYesNo("Deseja abrir o PDF original para DACTE/DANFE desta Chave Eletrônica? Podem ocorrer casos em que o PDF é de boletos e não correspondam a Chave Eletrônica em questão!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" PDF não encontrado!")

			//cLocDir	:= cGetFile("",OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione Diretório"),0,cTempPath,.t.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)

			// Efetua manutenção na pasta para limpar os arquivos se executada novamente a rotina
			// Somente o ultimo registro executado ficará na pasta
			If Alltrim(cLocDir) == "C:\Temp_NF-e\"
				aFiles   := Directory(Alltrim(cLocDir) +  "*.*")
				For a := 1 To Len(aFiles)
					If File(Alltrim(cLocDir) + aFiles[a][1])
						Ferase(Alltrim(cLocDir) + aFiles[a][1])
					Endif
				Next
			Endif
			If !Empty(cLocDir)
				MemoWrite(cLocDir+Alltrim(cInChve)+".pdf",CONDORXML->XML_ATT2)
				ShellExecute("open",cLocDir+Alltrim(cInChve)+'.pdf',"",cLocDir,1)
			Endif
		Else
			stViewNfe(2,cInChve)
		Endif
		RestArea(aAreaOld)
		Return 
	ElseIf nOpcView == 2 // Danfe via XML
		If CONDORXML->XML_TIPODC $ "T#F"//  aArqXml[oArqXml:nAt,nPosTpNota] $ "T#F"
			U_DACTE(cInChve)
		Else
			//cLocDir	:= cGetFile("",OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione Diretório"),0,cTempPath,.t.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)
			If !Empty(cLocDir)
				MemoWrite(cLocDir+Alltrim(cInChve)+".xml",CONDORXML->XML_ATT3)
				ShellExecute("open",cLocDir+Alltrim(cInChve)+'.xml',"",cLocDir,1)
			Endif
		Endif
		RestArea(aAreaOld)
		Return 
	ElseIf nOpcView == 3	// Carta de Correção
		If !Empty(CONDORXML->XML_ATT4)
			U_PRTCCE(cInChve,.F.)
		Else
			MsgAlert("Não foi encontrada Carta de Correção Eletrônica",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" CC-e não encontrada!")
		Endif
		RestArea(aAreaOld)
		Return
	ElseIf nOpcView == 4	// XML Estruturado
		cFile := cTempPath +Alltrim(cInChve)+'.xml'

		oDlgXml := TDialog():New(150,150,500,500,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+' Visualização XML estruturado' ,,,,,,,,,.T.)
		oDlgXml:lMaximized := .T.

		ofileXML := FCREATE(cFile)

		cContent := CONDORXML->XML_ATT3

		If ofileXML>0
			FWrite(ofileXML, cContent)
			FClose(ofileXML)
		EndIf

		oXml := TXMLViewer():New(10, 10, oDlgXml , cFile, 150, 150, .T. )
		oXml:Align := CONTROL_ALIGN_ALLCLIENT

		If oXml:setXML(cFile)
			Alert("Arquivo não encontrado")
		EndIf

		oDlgXml:Activate()
		RestArea(aAreaOld)
		Return
	Endif

	//WaitRun( '"%ProgramFiles%"\DanfeView\danfev.exe '+cLocDir+Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe])+'.xml"')

Return



/*/{Protheus.doc} XmlVldTt
(Validação de campos usados no MsNewGetDados da CentralXML)

@author MarceloLauschner
@since 13/10/2013
@version 1.0

@param nTipo, numérico, (Descrição do parâmetro)
@example
(examples)

@see (links_or_references)
/*/
User Function XmlVldTt(nTipo,nLinha)

	Local		lRet		:= .T.
	Local		nAuxCNT
	Local 		cTolent		:= GetMV("MV_TOLENT" , .F.,"") 
	Local 		lTolerNeg 	:= GetNewPar("MV_TOLENEG",.F.)
	Local		cMsgTol		:= ""
	
	Default 	nLinha		:= oMulti:nAt

	If nTipo == 1 // Quantidade
		If 	lMVXPCNFE .And. ;
		!Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED .And.;
		(IIf(!Empty(oMulti:aCols[nLinha][nPxCF]),!Alltrim(oMulti:aCols[nLinha][nPxCF]) $ cCFOPNPED,.T.)) .And.;
		(IIf(!Empty(oMulti:aCols[nLinha][nPxD1Tes]),!Alltrim(oMulti:aCols[nLinha][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
		!CONDORXML->XML_TIPODC $ "C#I#P"
			DbSelectArea("SC7")
			DbSetOrder(1)
			If DbSeek(xFilial("SC7")+oMulti:aCols[nLinha][nPxPedido]+oMulti:aCols[nLinha][nPxItemPc])

				// Verifica saldo do item real
				nFreeQT		:= 0
				cVar		:= SC7->C7_PRODUTO
				cItemPc		:= SC7->C7_ITEM
				cPedido     := SC7->C7_NUM
				BeginSql Alias "QXIT"

				SELECT XIT_QTE
				FROM CONDORXMLITENS XI,CONDORXML XM
				WHERE XM.%NotDel%
				AND XML_KEYF1 = '  '
				AND XML_CONFCO <> '  '
				AND XML_CHAVE = XIT_CHAVE
				AND XIT_CHAVE <> %Exp:aArqXml[oArqXml:nAt,nPosChvNfe]%
				AND XIT_CODPRD = %Exp:cVar%
				AND XIT_ITEMPC = %Exp:cItemPc%
				AND XIT_PEDIDO = %Exp:cPedido%
				AND XI.%NotDel%
				EndSql

				While !Eof()
					nFreeQT += QXIT->XIT_QTE
					QXIT->(DbSkip())
				Enddo
				QXIT->(DbCloseArea())

				For nAuxCNT := 1 To Len( oMulti:aCols )
					If (nAuxCNT # nLinha) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxProd ] == SC7->C7_PRODUTO) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxPedido ] == SC7->C7_NUM) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxItemPc ] == SC7->C7_ITEM) .And. ;
					!ATail( oMulti:aCols[ nAuxCNT ] ) .And. !oMulti:aCols[nAuxCNT,Len(oMulti:aHeader)+1]
						nFreeQT += oMulti:aCols[ nAuxCNT,nPxQte ]
					EndIf
				Next

				nFreeQT := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA-nFreeQT
				aMaAval	:= MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,M->D1_QUANT,nFreeQT,,,.F./*lHelp*/,.T./* lQtde*/, .F./*lPreco*/)
				If aMaAval[1]
					// 16/07/2017 - Melhoria feita para avisar sobre o prazo de tolerância de entrega
					If cTolent $ "1#2#3" 
						cMsgTol := CRLF + "Tolerância Entrega: " 
						If cTolent == "1"
							cMsgTol += "(1) Atrasos"
						ElseIf cTolent == "2" 
							cMsgTol	+= "(2)Antecipacoes "
						ElseIf cTolent == "3"
							cMsgTol	+= "(3)Ambos"
						Endif
						cMsgTol += " Data Prevista: " + DTOC(SC7->C7_DATPRF) + CRLF 
					Endif
					If lTolerNeg
						cMsgTol	+= "Parâmetro 'MV_TOLENEG' ativado!" 
					Endif
						
					If GetNewPar("XM_VLDTOLE","N") $ "A"
						MsgAlert("A Quantidade digitada está divergente com o pedido de compra." + CRLF +;
						"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nLinha][nPxDescri]+ "'" + CRLF +;
						"Qte disponível no pedido: " + Transform(nFreeQT,PesqPict("SC7","C7_QUANT"))  + CRLF +;
						"Qte na nota: " + Transform(M->D1_QUANT,PesqPict("SD1","D1_QUANT"))  + CRLF +;
						"% Tolerância Quantidade: " + Transform(aMaAval[2],"@E 999.99") +;
						cMsgTol,;
						ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")

						// Somente
					ElseIf GetNewPar("XM_VLDTOLE","N") $"B"
						MsgAlert("A Quantidade digitada está divergente com o pedido de compra." + CRLF +;
						"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nLinha][nPxDescri]+ "'" + CRLF +;
						"Qte disponível no pedido: " + Transform(nFreeQT,PesqPict("SC7","C7_QUANT"))  + CRLF +;
						"Qte na nota: " + Transform(M->D1_QUANT,PesqPict("SD1","D1_QUANT"))  + CRLF +;
						"% Tolerância Quantidade: " + Transform(aMaAval[2],"@E 999.99") + ;
						cMsgTol,;
						ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")
						lRet	:= .F.
					Endif
				Else
					lRet 	:= .T.
				Endif
			Endif
		ElseIf	CONDORXML->XML_TIPODC $ "C#I#P#T#F"
			If M->D1_QUANT > 0
				MsgAlert("Para notas fiscais de complemento não pode haver quantidade digitada!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Quantidade não permitida!")
				lRet	:= .F.
			Endif
		Endif
	ElseIf nTipo == 2
		If 	lMVXPCNFE .And.;
		!Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED .And.;
		(IIf(!Empty(oMulti:aCols[nLinha][nPxCF]),!Alltrim(oMulti:aCols[nLinha][nPxCF]) $ cCFOPNPED,.T.))  .And.;
		(IIf(!Empty(oMulti:aCols[nLinha][nPxD1Tes]),!Alltrim(oMulti:aCols[nLinha][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
		!CONDORXML->XML_TIPODC $ "C#I#P"
			DbSelectArea("SC7")
			DbSetOrder(1)
			If DbSeek(xFilial("SC7")+oMulti:aCols[nLinha][nPxPedido]+oMulti:aCols[nLinha][nPxItemPc])

				nC7Preco	:= sfxMoeda()

				If M->D1_VUNIT <> nC7Preco
					aMaAval	:= MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,,, M->D1_VUNIT, nC7Preco,.F./*lHelp*/,.F./* lQtde*/, .T./*lPreco*/)
					// 16/07/2017 - Melhoria feita para avisar sobre o prazo de tolerância de entrega
					If cTolent $ "1#2#3" 
						cMsgTol := CRLF + "Tolerância Entrega: " 
						If cTolent == "1"
							cMsgTol += "(1) Atrasos"
						ElseIf cTolent == "2" 
							cMsgTol	+= "(2)Antecipacoes "
						ElseIf cTolent == "3"
							cMsgTol	+= "(3)Ambos"
						Endif
						cMsgTol += " Data Prevista: " + DTOC(SC7->C7_DATPRF) + CRLF 
					Endif
					If lTolerNeg
						cMsgTol	+= "Parâmetro 'MV_TOLENEG' ativado!" 
					Endif
					
					If aMaAval[1]
						If GetNewPar("XM_VLDTOLE","N") $"A#B"
							MsgAlert("Preço digitado está divergente com o pedido de compra." + CRLF +;
							"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nLinha][nPxDescri]+ "'" + CRLF +;
							"Preço no pedido: " + Transform(nC7Preco,PesqPict("SC7","C7_PRECO"))  + CRLF +;
							"Preço na nota: " + Transform(M->D1_VUNIT,PesqPict("SD1","D1_VUNIT"))  + CRLF +;
							"% Tolerância Preço: " + Transform(aMaAval[3],"@E 999.99") +;
							cMsgTol,;
							ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")

							If GetNewPar("XM_VLDTOLE","N") $"B"
								lRet	:= .F.
							Endif
						Endif
					Else
						lRet 	:= .T.
						MsgAlert("Preço digitado está divergente com o pedido de compra." + CRLF +;
						"Produto: '" + SC7->C7_PRODUTO +"-" + oMulti:aCols[nLinha][nPxDescri]+ "'" + CRLF +;
						"Preço no pedido: " + Transform(nC7Preco,PesqPict("SC7","C7_PRECO"))  + CRLF +;
						"Preço na nota: " + Transform(M->D1_VUNIT,PesqPict("SD1","D1_VUNIT")) +;
						cMsgTol,;
						ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Divergência com pedido de compra!")
					Endif

				Endif
			Endif
		Endif
	Elseif nTipo == 3
		If Round(M->D1_TOTAL,2) <> Round(oMulti:aCols[nLinha,nPxTotNfe],2)
			MsgAlert("O Valor total do item digitado não confere com o valor total do item constante no XML",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			lRet	:= .F.
		Endif
	Elseif nTipo == 4
		If ReadVar() == "M->XIT_OPER"
			If Vazio()	
				lRet	:= .T.
			ElseIf !ExistCpo("SX5","DJ"+M->XIT_OPER)
				lRet	:= .F.
			Else
				oMulti:aCols[nLinha,nPxD1Tes]	:=  sfRetTes(oMulti:aCols[nLinha,nPxD1Tes],oMulti:aCols[nLinha,nPxItem],oMulti:aCols[ nLinha,nPxProd ],M->XIT_OPER,)
				U_VlsSF4(oMulti:aCols[nLinha,nPxD1Tes],nLinha)
			Endif
		Else
			oMulti:aCols[nLinha,nPxD1Tes]	:=  sfRetTes(oMulti:aCols[nLinha,nPxD1Tes],oMulti:aCols[nLinha,nPxItem],oMulti:aCols[ nLinha,nPxProd ],oMulti:aCols[nLinha,nPxD1Oper],)
			U_VlsSF4(oMulti:aCols[nLinha,nPxD1Tes],nLinha)
		Endif
	Elseif nTipo == 5
		oMulti:aCols[nLinha,nPxD1Tes]	:=  sfRetTes(oMulti:aCols[nLinha,nPxD1Tes],oMulti:aCols[nLinha,nPxItem],M->D1_COD,oMulti:aCols[nLinha,nPxD1Oper],)
		U_VlsSF4(oMulti:aCols[nLinha,nPxD1Tes],nLinha)
	Endif

Return lRet


/*/{Protheus.doc} sfReport
(Relatorio de divergencia entre NFe e Pedido de Compra)

@author Marcelo Lauschner
@since 02/12/2013
@version 1.0
@example
(examples)

@see (links_or_references)
/*/
Static Function sfReport()

	Local 	aStru 		:= {}
	Local 	cDesc1      := "Este programa tem como objetivo imprimir relatorio "
	Local 	cDesc2      := "de acordo com os parametros informados pelo usuario."
	Local 	cDesc3      := "Conferência de Nota fiscal Eletrônico X Pedido de Compra"
	Local 	cPict       := ""
	Local 	titulo      := "Conferência de Nota fiscal Eletrônica X Pedido de Compra"
	Local 	nLin        := 80
	//             012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                       1         2         3         4         5         6         7         8         9         10
	Local 	Cabec1      := "Ref Fornecedor   Código Protheus  Descrição                                            Qte XML  UM   R$ Unit.XML    R$ Total XML Quantidade UM     R$ Unit NF     R$ Total NF      R$ Pedido Observações          %Difer"

	Local 	Cabec2      := "CGC: " +Transform(CONDORXML->XML_EMIT,"@R 99.999.999/9999-99")  + " - " + Alltrim(CONDORXML->XML_NOMEMT) + " NFº " + CONDORXML->XML_NUMNF
	Local 	imprime     := .T.
	Local 	aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 220
	Private tamanho     := "G"
	Private nomeprog    := "XMLCONFNFE" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,"")

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


/*/{Protheus.doc} RunReport
(long_description)

@author MarceloLauschner
@since 02/12/2013
@version 1.0

@param Cabec1, ${param_type}, (Descrição do parâmetro)
@param Cabec2, ${param_type}, (Descrição do parâmetro)
@param Titulo, ${param_type}, (Descrição do parâmetro)
@param nLin, numérico, (Descrição do parâmetro)

@example
(examples)

@see (links_or_references)
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local	nTotXml	:= 0
	Local	nTotNfe	:= 0
	Local	nTotIpi	:= 0
	Local	nTotSt		:= 0
	Local	nI



	For nI := 1 To Len(oMulti:aCols)

		If oMulti:aCols[nI,Len(oMulti:aHeader)+1]
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nLin,000 Psay oMulti:aCols[nI,nPxCodNfe]
		@nLin,017 Psay oMulti:aCols[nI,nPxProd]
		@nLin,034 Psay Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nI,nPxProd],"B1_DESC")
		@nLin,085 Psay Transform(oMulti:aCols[nI,nPxQteNfe],"@E 99,999.99")
		@nLin,096 Psay oMulti:aCols[nI,nPxUMNFe]
		@nLin,099 Psay Transform(oMulti:aCols[nI,nPxPrcNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),(oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi])/oMulti:aCols[nI,nPxQteNfe],0),"@E 9,999,999.9999")
		@nLin,115 Psay Transform(oMulti:aCols[nI,nPxTotNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi],0),"@E 9,999,999.9999")
		@nLin,130 Psay Transform(oMulti:aCols[nI,nPxQte],"@E 999,999.99")
		@nLin,141 Psay oMulti:aCols[nI,nPxUm]
		@nLin,144 Psay Transform(oMulti:aCols[nI,nPxPrunit]-(oMulti:aCols[nI,nPxValDesc]/oMulti:aCols[nI,nPxQte])+IIf(GetNewPar("XM_PRCCIST",.T.),(oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi])/oMulti:aCols[nI,nPxQteNfe],0),"@E 9,999,999.9999")
		@nLin,160 Psay Transform(oMulti:aCols[nI,nPxTotal] - oMulti:aCols[nI,nPxValDesc] +IIf(GetNewPar("XM_PRCCIST",.T.),(oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi])/oMulti:aCols[nI,nPxQteNfe],0),"@E 9,999,999.9999")
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+oMulti:aCols[nI][nPxPedido]+oMulti:aCols[nI][nPxItemPc])
			@nLin,175 Psay Transform(SC7->C7_PRECO+IIf(GetNewPar("XM_PRCCIST",.T.),(SC7->C7_VALIPI+SC7->C7_ICMSRET)/SC7->C7_QUANT,0),"@E 9,999,999.9999")
			If oMulti:aCols[nI,nPxPrunit] <> SC7->C7_PRECO
				@nLin,190 Psay "Dif R$ " + Transform(SC7->C7_PRECO-(oMulti:aCols[nI,nPxPrunit]-(oMulti:aCols[nI,nPxValDesc]/oMulti:aCols[nI,nPxQte])),"@E 999,999.9999")
			Endif
			@nLin,210 Psay Transform(Round((oMulti:aCols[nI,nPxPrunit]-SC7->C7_PRECO)/SC7->C7_PRECO * 100,2),"@E 999.99%")
		Else
			@nLin,190 Psay "Não há pedido de compra"
		Endif
		If SB1->B1_VLR_IPI > 0 .And. SB1->B1_VLR_IPI <> Round(oMulti:aCols[nI,nPxValIpi]/oMulti:aCols[nI,nPxQte],TamSX3("B1_VLR_IPI")[2])
			nLin++
			@nLin,001 Psay "***Divergência Valor IPI de Pauta ***  Valor Cadastro: R$ " +Transform(SB1->B1_VLR_IPI,"@E 9,999.99") + " - Valor unitário NF: R$ "+Transform(Round(oMulti:aCols[nI,nPxValIpi]/oMulti:aCols[nI,nPxQte],TamSX3("B1_VLR_IPI")[2]),"@E 9,999.99")
		Endif
		nTotXml	+= oMulti:aCols[nI,nPxTotNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi],0)
		nTotNfe	+= oMulti:aCols[nI,nPxTotal] - oMulti:aCols[nI,nPxValDesc] +IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet]+oMulti:aCols[nI,nPxValIpi],0)
		nTotIpi += oMulti:aCols[nI,nPxValIpi]
		nTotSt	+= oMulti:aCols[nI,nPxIcmRet]
		nLin++ // Avanca a linha de impressao

	Next
	nLin++

	@nLin,115 Psay Transform(nTotXml,"@E 99,999,999.99")
	@nLin,160 Psay Transform(nTotNfe,"@E 99,999,999.99")
	nLin++
	@nLin,010 PSay "Valor Total IPI    : "+Transform(nTotIpi,"@E 999,999.99")
	nLin++
	@nLin,010 Psay "Valor Total ICMS ST: "+Transform(nTotSt,"@E 999,999.99")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return


Return



/*/{Protheus.doc} sfTracker
(Função que permite buscar o Historico do cliente e posição)

@author MarceloLauschner
@since 02/12/2013
@version 1.0
@example
(examples)

@see (links_or_references)
/*/
Static Function sfTracker()

	Local		aAreaOld		:= GetArea()
	Local		aHeadBk		:= {}
	Local		aColsBk		:= {}
	Local		aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
	Private 	aRotina		:= StaticCall(MATA410,MenuDef)
	Private	cCadastro  	:= "Posição do Cliente"
	Private	INCLUI			:= .F.
	Private	ALTERA			:= .T.
	If Type("aHeader") == "U"
		Private	aHeader		:= {}
	Else
		aHeadBk	:= aClone(aHeader)
	Endif
	If Type("aCols") == "U"
		Private	aCols			:= {}
	Else
		aColsBk	:= aClone(aCols)
	Endif

	Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Histórico da Nota",	"Enviado por:"+CONDORXML->XML_CFROM + Chr(13)+Chr(10) +;
	"Corpo Email:"+CONDORXML->XML_BODY + Chr(13)+Chr(10) +;
	"Data de Emissão:"+DTOC(CONDORXML->XML_EMISSA) + Chr(13)+Chr(10) +;
	"Data Recebimento:"+DTOC(CONDORXML->XML_RECEB) + " " +CONDORXML->XML_HORREC + " por:"+CONDORXML->XML_USRREC + Chr(13)+Chr(10)+ ;
	"Data Conf.Sefaz: "+DTOC(CONDORXML->XML_CONFER) + " " +CONDORXML->XML_HORCON + " por:"+CONDORXML->XML_USRCON + Chr(13)+Chr(10)+ ;
	"Data Lançamento: "+DTOC(CONDORXML->XML_LANCAD) + " " + CONDORXML->XML_HORLAN + " por:"+CONDORXML->XML_USRLAN + Chr(13)+Chr(10)+;
	"Data Rejeição XML:"+DTOC(CONDORXML->XML_REJEIT) + " por:"+CONDORXML->XML_USRREJ + Chr(13)+Chr(10)+ ;
	"Data Conf.Compras:"+DTOC(CONDORXML->XML_CONFCO) + " " + CONDORXML->XML_HORCCO + " por:"+CONDORXML->XML_USRCCO + Chr(13)+Chr(10)+  ;
	"Data Revalidação Sefaz: "+DTOC(CONDORXML->XML_DTRVLD)  + Chr(13)+Chr(10);
	,{"Ok"},3)

	DbSelectArea("SA1")
	DbSetOrder(1)

	If aArqXml[oArqXml:nAt,nPosTpNota] $ "B#D"
		a450F4Con()
		// Atualizo variavel de pesquisa e efetuo refresh
		cVarPesq := aArqXml[oArqXml:nAt,nPosChvNFe]
		stPesquisa()
	Endif
	aHeader	:= aClone(aHeadBk)
	aCols		:= aClone(aColsBk)

	StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)

	RestArea(aAreaOld)



Return

/*/{Protheus.doc} sfMark
(Permite marcar os CTes sobre Vendas para posterior inclusão em Lote)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@param lMarkAll, ${param_type}, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfMark(lMarkAll)

	Local	lSoma		:= .F.
	Local	cTextXml	:= ""
	Local	nB
	
	Default lMarkAll	:= .F.
	Private oCte
	// Zero variáveis
	nSumCte	:= nNumCte	:= 0
	oSumCte:Refresh()
	oNumCte:Refresh()

	If lMarkAll
		For nB := 1 To Len(aArqxml)
			// Somente CTE não lançados
			If aArqXml[nB,nPosTpNota]$"F#T"  .And. aArqXml[nB,1] == 11
				aArqXml[nB,nPosOkCte] := !aArqXml[nB,nPosOkCte]
			Endif
		Next
	Else
		// Somente CTE não lanaçdo
		If aArqXml[oArqXml:nAt,nPosTpNota]$"F#T" .And. aArqXml[oArqXml:nAt,1] == 11
			aArqXml[oArqXml:nAt,nPosOkCte] := !aArqXml[oArqXml:nAt,nPosOkCte]
		Endif
	Endif

	For nB := 1 To Len(aArqxml)
		If aArqXml[nB,nPosOkCte] .And. (nB == oArqXml:nAt .Or. aArqXml[nB,nPosVlrCte]  == 0 )

			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[nB,nPosChvNfe])

			cTextXml	:= CONDORXML->XML_ARQ
			lSoma		:= .F.

			// Valido que somente CTE do tipo que o Remetente é a propria empresa em Uso possa ser marcado para usar como CTE sobre Vendas
			nPxRem1	:= At("<rem><CNPJ>",cTextXml)
			nPxEmi1	:= At("<emit><CNPJ>",cTextXml)
			nPxTom4	:= At("<toma>4</toma><CNPJ>",cTextXml)
			nPosDes	:= At("<dest><CNPJ>",cTextXml)
			nPosExp	:= At("<exped><CNPJ>",cTextXml)

			//0-Remetente;
			//1-Expedidor;
			//2-Recebedor;
			//3-Destinatário
			nPxTom32	:= At("<toma03><toma>2</toma></toma03>",cTextXml)
			If nPxTom32 <= 0
				nPxTom32 := At("<toma3><toma>2</toma></toma3>",cTextXml)
			Endif
			nPxTom33	:= At("<toma03><toma>3</toma></toma03>",cTextXml)
			If nPxTom33 <= 0
				nPxTom33 	:= At("<toma3><toma>3</toma></toma3>",cTextXml)
			Endif
			nPxTom31	:= At("<toma03><toma>1</toma></toma03>",cTextXml)
			If nPxTom31 <= 0
				nPxTom31 := At("<toma3><toma>1</toma></toma3>",cTextXml)
			Endif
			//<toma03><toma>3 <rem><CNPJ>17227981000107 <emit><CNPJ>17227981000107 <dest><CNPJ>11090009000157

			// Se o emitente fofr o Remetente
			If Substr(cTextXml,nPxRem1+11,14) == Substr(cTextXml,nPxEmi1+12,14) .And. (nPxTom33 > 0 .Or. nPxTom32 > 0 )
				lSoma	:= .T.
			Endif


			// Se o Emitente for o Expedidor e não tiver dados de Remetente
			If Substr(cTextXml,nPxEmi1+12,14) == Substr(cTextXml,nPosExp+13,14) .And. nPxRem1 == 0 .And. (nPxTom33 > 0 .Or. nPxTom32 > 0 )
				lSoma	:= .T.
			Endif

			// Se o Tomador for o Expedidor e o remetente não é a empresa atual
			If (Substr(cTextXml,nPosExp+13,14)==SM0->M0_CGC .And. !lSoma )
				lSoma	:= .T.
			Endif

			// Se o Remetente for a empresa posicionada ou se for o Expedidor
			If Substr(cTextXml,nPxRem1+11,14) == SM0->M0_CGC 
				lSoma	:= .T.
				// Melhoria deste parametro adicionada em 01/05/2013 a pedido de Megaware
				If CONDORXML->XML_CTEFOB == "S"

					// Condição adicionada em 01/05/2013 a pedido da Megaware
					// Se o parametro de permitir CTe sobre vendas como FOB invés de CIF estiver habilitado, permite marcar
					// o CTe.
					// Se o registro em avaliação for a linha posicionada que foi marcada
					If nB == oArqXml:nAt .And. (nPxTom4 > 0  .Or. nPxTom33 > 0 .Or. nPxTom32 > 0 .Or. nPxTom31 > 0)
						If !lAutoExec
							MsgAlert("Paramêtro 'XM_VLCTEFB' ( Permite Frete s/vendas FOB ) está habilitado!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Marcação CTe s/Vendas FOB")
						Endif

						stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
						"Marcação de CTe s/Vendas FOB" ,;
						"Paramêtro 'XM_VLCTEFB' ( Permite Frete s/vendas FOB ) está habilitado! "+cEmpAnt+"/"+cFilAnt+" "+SM0->M0_NOMECOM)
					Endif
				Else
					If nPxTom4 > 0
						// mas se o tomador não for a empresa em questão
						If Substr(cTextXml,nPxTom4+20,14) <> SM0->M0_CGC
							lSoma	:= .F.
						Endif
					ElseIf nPxTom33 > 0 .Or. nPxTom32 > 0
						lSoma	:= .F.
					Endif
				Endif
			Endif

	
			// Se houver a tag de Tomador de serviço em Tomador 4 e for a empresa posicionada
			If nPxTom4 > 0  
				If Substr(cTextXml,nPxTom4+20,14) == SM0->M0_CGC
					lSoma	:= .T.
				ElseIf nPxTom4 > 0 .And.; // Tomador serviço é o Destinatário e o Destinatário é a empresa Atual e estive habilitado o Frete Fob
				 	CONDORXML->XML_DEST==SM0->M0_CGC .And. CONDORXML->XML_CTEFOB =="S"
				 	lSoma	:= .T.
				 	If !lAutoExec .And. !lMadeira
				 		MsgAlert("Paramêtro 'XM_VLCTEFB' ( Permite Frete FOB ) está habilitado!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Marcação CTe FOB")
				 	Endif
				 	If !lMadeira
				 		stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
				 		"Marcação de CTe FOB" ,;
				 		"Paramêtro 'XM_VLCTEFB' ( Permite Frete s/vendas FOB ) está habilitado! "+cEmpAnt+"/"+cFilAnt+" "+SM0->M0_NOMECOM)
				 	Endif
				 Endif
			Endif
			// Tomador serviço é o Destinatário e o Destinatário é a empresa Atual e estive habilitado o Frete Fob
			If (At("<toma03><toma>3</toma></toma03>",cTextXml) > 0 .Or. At("<toma3><toma>3</toma></toma3>",cTextXml) > 0 ) .And.;
			(Substr(cTextXml,nPosDes+12,14)==SM0->M0_CGC .Or. CONDORXML->XML_DEST==SM0->M0_CGC) .And. CONDORXML->XML_CTEFOB =="S"
				//			Substr(cTextXml,nPosDes+12,14)==SM0->M0_CGC .And. CONDORXML->XML_CTEFOB =="S"
				lSoma	:= .T.
				If !lAutoExec .And. !lMadeira
					MsgAlert("Paramêtro 'XM_VLCTEFB' ( Permite Frete FOB ) está habilitado!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Marcação CTe FOB")
				Endif
				If !lMadeira
					stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
					"Marcação de CTe FOB" ,;
					"Paramêtro 'XM_VLCTEFB' ( Permite Frete s/vendas FOB ) está habilitado! "+cEmpAnt+"/"+cFilAnt+" "+SM0->M0_NOMECOM)
				Endif
			Endif


			// Tomador serviço é o Remetente  e o Destinatário é a empresa Atual e estive habilitado o Frete Fob
			If (At("<toma03><toma>0</toma></toma03>",cTextXml) > 0 .Or. At("<toma3><toma>0</toma></toma3>",cTextXml) > 0 ).And.;
			(Substr(cTextXml,nPosDes+12,14)==SM0->M0_CGC .Or. CONDORXML->XML_DEST==SM0->M0_CGC) .And. CONDORXML->XML_CTEFOB =="S"
				lSoma	:= .T.
				If !lAutoExec
					MsgAlert("Paramêtro 'XM_VLCTEFB' ( Permite Frete FOB ) está habilitado!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Marcação CTe FOB")
				Endif
				If !lMadeira
					stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
					"Marcação de CTe FOB" ,;
					"Paramêtro 'XM_VLCTEFB' ( Permite Frete s/vendas FOB ) está habilitado! "+cEmpAnt+"/"+cFilAnt+" "+SM0->M0_NOMECOM)
				Endif
			Endif


			If Empty(CONDORXML->XML_CONFER)
				If !lAutoExec
					lSoma	:= .F.
					MsgAlert("Nota fiscal ainda não foi conferida na SEFAZ.Não é permitido marcar para lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação rejeitada!")
				Else
					lSoma	:= .F.
				Endif
			Endif

			If lSoma
				nSumCte	+= aArqXml[nB,nPosVlrCte]
				nNumCte++
			Else
				aArqXml[nB,nPosOkCte] := .F.
			Endif
		ElseIf aArqXml[nB,nPosOkCte] .And. nB <> oArqXml:nAt
			nNumCte++
			nSumCte	+= aArqXml[nB,nPosVlrCte]
		Endif
	Next

	If nNumCte > 0 .And. lAutoExec .And. !lMadeira
		stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Marcação CTes para gravação -" + cEmpAnt+"/"+cFilAnt+" " +SM0->M0_NOMECOM,"Total registros selecionados "+Alltrim(Str(nNumCte))+Chr(13) + " Valor selecionado R$ "+Transform(nSumCte,"@E 999,999,999.99"))
	Endif

	oNumCte:Refresh()
	oSumCte:Refresh()


	// Reposiciono o registro
	U_DbSelArea("CONDORXML",.F.,1)
	DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])

	oArqXml:Refresh()

Return

/*/{Protheus.doc} sfAltTipDC
(Interface para alterar o tipo de documento ou apropriar Frete Fob)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfAltTipDC()

	Local	aAreaOld	:= GetArea()
	Local	cTipoBox	:= "N=Normal"
	Local	cChgEmp		:= "2"
	Local	lContinua	:= 	.F.
	Local	cAviso		:= ""
	Local	cErro		:= ""
	Local	lLibChgEmp	:= __cUserId $ GetNewPar("XM_CHGEMPF","000000") .Or. PswAdmin( , ,RetCodUsr()) == 0 // Id de Usuários que podem alterar a empresa aonde a nota pode ser lançada
							// Melhoria solicitada pela Gertec para permitir incorporações e assumir XMLs 
	Private	oNfe

	U_DbSelArea("CONDORXML",.F.,1)
	If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
		If !lAutoExec
			MsgAlert("Erro ao localizar registro", ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
		Return
	Endif

	If !Empty(CONDORXML->XML_REJEIT)
		MsgAlert("Nota fiscal rejeitada em "+DTOC(CONDORXML->XML_REJEIT)+". Não é permitido fazer alterações!", ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Nota fiscal rejeitada!")
		Return
	Endif
	// -- Valido se Nota Fiscal já existe na base ?
	If !Empty(CONDORXML->XML_KEYF1)
		MsgAlert("Nota fiscal já está lançada no Sistema no dia "+DTOC(CONDORXML->XML_LANCAD)+". Não é permitido fazer alterações!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Nota fiscal já lançada!")
		Return
	Endif

	If CONDORXML->XML_TIPODC $ "T#F"

		If !GetNewPar("XM_VLCTEFB",.F.)
			MsgAlert("Paramêtro 'XM_VLCTEFB' está desabilitado para permitir alterar tomador de serviços de CT-e!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Alterar Tomador de Serviço")
			Return
		Endif
		//MsgAlert("Tipo de documento Classificado como CT-e não é permitido alterar!","CT-e não permite alteração!")
		//Return
		cTipoBox	:= "N=Não"
		DEFINE MSDIALOG oDlgCte TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Alterar Tomador do Serviço do Frete!") FROM 001,001 TO 170,400 PIXEL
		@ 010,018 Say "Tomador Serviço Empresa Atual?" Pixel of oDlgCte
		@ 010,110 Combobox cTipoBox Items {"N=Não","S=Sim"} Pixel of oDlgCte When lSuperUsr
		
		@ 035,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCte Action (lContinua	:= .T.,oDlgCte:End())
		@ 035,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCte Action (oDlgCte:End())

		ACTIVATE MSDIALOG oDlgCte CENTERED

		If !lContinua .Or. cTipoBox == "N"
			Return
		Endif

		RecLock("CONDORXML",.F.)
		CONDORXML->XML_CTEFOB 		:= "S"
		CONDORXML->XML_DEST			:= SM0->M0_CGC
		CONDORXML->XML_NOMEDT		:= SM0->M0_NOMECOM
		CONDORXML->XML_MUNDT		:= SM0->M0_CIDENT+"/"+SM0->M0_ESTENT
		MsUnlock()

		Return
	Endif
	// Atribui variável para valor antigo
	cTipoBox	:= "N=Normal"

	// Valido se esta empresa/filial certa conforme destinatário do XML
	If !lLibChgEmp .And. SM0->M0_CGC <> CONDORXML->XML_DEST
		MsgAlert("Empresa errada! Destinatário é diferente do CNPJ do XML("+CONDORXML->XML_DEST+").",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Destinatário errado!")
		Return
	Endif

	cTipoBox	:= CONDORXML->XML_TIPODC

	DEFINE MSDIALOG oDlgCond TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Alterar tipo de Documento!") FROM 001,001 TO 170,400 PIXEL
	@ 009,018 Say "Tipo de Nota fiscal" Pixel of oDlgCond
	@ 010,110 Combobox cTipoBox Items {"N=Normal","B=Beneficiamento","D=Devolução","C=Compl. Preço/Frete","P=Compl. IPI","I=Compl. ICMS"} Pixel of oDlgCond When lSuperUsr
	
	If lLibChgEmp
		@ 028,018 Say "Assume Tipo de Nota fiscal" Pixel of oDlgCond
		@ 029,110 Combobox cChgEmp Items {"1=Sim","2=Não"} Pixel of oDlgCond When lSuperUsr
	
	Endif
		
	@ 055,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
	@ 055,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())

	ACTIVATE MSDIALOG oDlgCond CENTERED

	If !lContinua
		Return
	Endif

	// Validação que permite que o tipo de documento seja alterado
	If cTipoBox <> CONDORXML->XML_TIPODC .Or. (lLibChgEmp .And.cChgEmp == "1" )
		If MsgNoYes("Você alterou o tipo de nota fiscal de '"+CONDORXML->XML_TIPODC+"' para '"+cTipoBox+"'!"+Chr(13)+Chr(10)+;
		"Deseja realmente efetuar a troca do tipo de Nota para '"+cTipoBox+"'? ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Troca do Tipo de Documento de Entrada!")
			RecLock("CONDORXML",.F.)
			CONDORXML->XML_TIPODC 	:= cTipoBox
			CONDORXML->XML_CODLOJ 	:= ""
			CONDORXML->XML_INSCRI	:= ""
			If cChgEmp == "1"
				CONDORXML->XML_DEST			:= SM0->M0_CGC
				CONDORXML->XML_NOMEDT		:= SM0->M0_NOMECOM
				CONDORXML->XML_MUNDT		:= SM0->M0_CIDENT+"/"+SM0->M0_ESTENT
			Endif
			MsUnlock()
		Endif
		Return
	Endif

Return



/*/{Protheus.doc} stExpXml
(Exportar para XML a lista de notas do array do Listbox)
@author MarceloLauschner
@since 08/03/2012
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function stExpXml(nOpcAviso,aCabXml)

	//Local	nOpcAviso	:= 	Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha uma opção","Selecione uma opção de exportação",{"Exp.XML´s","Exp.Excel"})
	Local	cLocDir		:= ""
	Local	nI
	Local	iQ

	If nOpcAviso == 2
		If FindFunction("RemoteType") .And. RemoteType() == 1
			aExpXml	:= aClone(aArqXml)
			For nI := 1 To Len(aExpXml)
				aExpXml[nI,nPosChvNfe]	+= "'" // Modifico a coluna da chave eletronica para que o Excel não converta em campo númerico
			Next
			DlgToExcel({{"ARRAY","Listar NFs Listbox",aCabXml,aExpXml}})
		EndIf
	ElseIf nOpcAviso == 1
		cLocDir	:= cGetFile("",OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione Diretório"),0,"",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD,,)

		If Empty(cLocDir)
			oArqXml:SetFocus()
			Return
		Endif

		If !MsgYesNo("Deseja realmente exportar os arquivos XML de todas as notas filtradas nesta tela para o diretório informado?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Exportação de XML´s")
			oArqXml:SetFocus()
			Return
		Endif

		ProcRegua(Len(aArqXml))

		For iQ := 1 To Len(aArqXml)

			IncProc("Exportanto "+Alltrim(Str(iQ))+" / "+Alltrim(Str(Len(aArqXml)) ) )

			U_DbSelArea("CONDORXML",.F.,1)
			If DbSeek(Alltrim(aArqXml[iQ,nPosChvNfe]))
				MemoWrite(cLocDir+Alltrim(aArqXml[iQ,nPosChvNfe])+".xml",CONDORXML->XML_ARQ)

				//If Len (oMulti:aCols) == 0
				//	MemoWrite(cDirNfe+Alltrim(aArqXml[iQ,nPosChvNfe])+".xml",CONDORXML->XML_ARQ)
				//Endif

				If !Empty(CONDORXML->XML_ATT2)
					MemoWrite(cLocDir+Alltrim(aArqXml[iQ,nPosChvNfe])+".pdf",CONDORXML->XML_ATT2)
				Endif
			Else
				MsgAlert("Não encontrou o arquivo da Chave '"+Alltrim(aArqXml[iQ,nPosChvNfe])+"' para gerar o arquivo XML",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" A T E N Ç Ã O!! ")
			Endif
		Next
		shellExecute("Open", cLocDir, "", cLocDir, 1 )

		U_DbSelArea("CONDORXML",.F.,1)
		DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
		oArqXml:SetFocus()
	Endif

Return






/*/{Protheus.doc} sfGrvCte
(Gera Doc.Entrada Complemento Preço do Frete S/Vendas )
@author MarceloLauschner
@since 04/07/2012
@version 1.0
@param lOnlyView, logico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfGrvCte(lOnlyView)

	Local		nValSeguro	:= 0
	Local		nValCompon	:= 0
	Local		cAviso		:= ""
	Local		cErro		:= ""
	Local		nQteLoop	:= Len(aArqXml)
	Local		lCheck 		:= .T.
	Local		aNfsXCte	:= {}
	Local		aNfOriCTE	:= {}
	Local		nTotMerc	:= 0
	Local		cNewOper	:= ""
	Local		cNewTes		:= ""
	Local		cInscricao	:= ""
	Local		cUfCad		:= ""
	Local		cCgcCli		:= ""
	Local		cNumNfs		:= ""
	Local		cSerNfs		:= ""
	Local		cChvCte		:= ""
	Local		lLoopNext	:= .F.
	Local		nRecSA1		:= 0

	Local		cSC7FRTD1	:= Space(TamSX3("D1_PEDIDO")[1])
	Local		cSC7FRTIT	:= Space(TamSX3("D1_ITEM")[1])
	Local		nSumC7D1	:= 0
	Local		lExistParc	:= .F.
	Local		cParcela	:= " "
	Local		lOnlyDup	:= .F.
	Local		dDtVctoCte	:= CTOD("")
	Local		lIsCompl	:= !(GetNewPar("XM_C7FRTD1",.F.)) .And. GetNewPar("XM_TPNFCTE","C") == "C" .And. SF1->(FieldPos("F1_TPCOMPL")) > 0 
	Local		cF1TpCompl	:= "3-Frete"
	Local 		nForA,nForB,nForC,nForD,nForE,nForF,nForG,nForH
	Local		lAddVlrPedg	:= .F.
	Local		lIsDebug	:= GetNewPar("XM_DBGRXML",.F.) 
	Local		cF1LOJDEST	:= Iif( SF1->(FieldPos("F1_LOJDEST")) > 0,Space(TamSX3("F1_LOJDEST")[1]),"")
	Local		cF1CLIDEST	:= Iif( SF1->(FieldPos("F1_CLIDEST")) > 0,Space(TamSX3("F1_CLIDEST")[1]),"")
	Local		cF1UFORITR 	:= Iif( SF1->(FieldPos("F1_UFORITR")) > 0,Space(TamSX3("F1_UFORITR")[1]),"")
	Local		cF1MUORITR  := Iif( SF1->(FieldPos("F1_MUORITR")) > 0,Space(TamSX3("F1_MUORITR")[1]),"")
	Local		cF1UFDESTR 	:= Iif( SF1->(FieldPos("F1_UFDESTR")) > 0,Space(TamSX3("F1_UFDESTR")[1]),"")
	Local		cF1MUDESTR 	:= Iif( SF1->(FieldPos("F1_MUDESTR")) > 0,Space(TamSX3("F1_MUDESTR")[1]),"")
	Local		lGrvF1Cli	:= SF1->(FieldPos("F1_LOJDEST")) > 0
	Private  	iX 
	Private		cUfOri		:= ""
	Private		cUfDes		:= ""
	Private		nValPedagio	:= 0
	Private		lDtVctoCte	:= .F.
	Private		cCCusto		:= ""
	Private		cContaC		:= ""
	Private		cItemCc		:= ""
	Private		cClasVlr	:= ""	
	Private	aItem			:= {}
	Default	lOnlyView 		:= .F.
	Private	cModFrete		:= ""
	Private cTpCte			:= ""
	Private cModalCte		:= ""
	Private	oCte
	Private cCondicao		:= Space(TamSX3("F1_COND")[1])
	Private cNatFin			:= Space(TamSX3("E2_NATUREZ")[1])

	If lOnlyView
		nQteLoop	:= 1
	Endif

	DbselectArea("SD1")
	DbSetOrder(1)

	DbSelectArea("SF1")
	DbSetOrder(1)

	ProcRegua(nQteLoop)


	For nForH := 1 To nQteLoop
		nB := nForH
		lLoopNext		:= .F.

		IncProc("Lendo registro "+Alltrim(Str(nB))+"/"+Alltrim(Str(Len(aArqXml))) )
		If lOnlyView .Or. aArqXml[nB,nPosOkCte]

			If lOnlyView
				nB	:= oArqXml:nAt
			Endif

			// Zera as variaveis para evitar que conflite com proximos CTEs
			aNfsXCte	:= {}
			cCCusto		:= ""
			cContaC		:= ""
			cItemCc		:= ""
			cClasVlr	:= ""
			aNfOriCTE	:= {}
			nTotMerc	:= 0
			cF1LOJDEST	:= Iif( SF1->(FieldPos("F1_LOJDEST")) > 0,Space(TamSX3("F1_LOJDEST")[1]),"")
			cF1CLIDEST	:= Iif( SF1->(FieldPos("F1_CLIDEST")) > 0,Space(TamSX3("F1_CLIDEST")[1]),"")
			
			cAviso 	:= ""
			cErro	:= ""

			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[nB,nPosChvNfe])

			oCte := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)

			If !Empty(cErro)
				If !lAutoExec
					sfAtuXmlOk("E7")
					MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Else
					sfAtuXmlOk("E7")
				Endif
				//Return .F.
				Loop
			Endif
			// Identificado situação em que os Ctes de outras filiais estão na tela da Central XML e acaba atribuindo o Código/Loja do SA2 quando exclusivo. 
			If Alltrim(CONDORXML->XML_DEST) <> Alltrim(SM0->M0_CGC)
				Loop
			Endif	
			
			If !Empty(cAviso)
				MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Aviso ao validar schema do Xml")
				stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE com aviso "+ cAviso ,'"'+CONDORXML->XML_ARQ+'"')
			Endif

			If Type("oCte:_CTeProc")<> "U"
				oNF 		:= oCte:_CTeProc:_CTe
				cChvCte	:= oCte:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
			ElseIf Type("oCte:_CTe")<> "U"
				oNF 		:= oCte:_CTe
				cChvCte	:= oCte:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
			ElseIf Type("oCte:_enviCTe:_CTe")<> "U"
				oNF			:= oCte:_enviCTe:_CTe
				cChvCte	:= oCte:_enviCTe:_protCTe:_infProt:_chCTe:TEXT
			ElseIf Type("oCte:_procCTe:_CTe") <> "U"
				oNF	:= oCte:_procCTe:_CTe
				cChvCte := oCte:_PROCCTE:_PROTCTE:_infProt:_chCTe:TEXT
			Else
				cAviso	:= ""
				cErro	:= ""
				oCte := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)

				If !Empty(cErro)
					If !lAutoExec
						sfAtuXmlOk("E7")
						MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
					Else
						sfAtuXmlOk("E7")
					Endif
					//Return .F.
					Loop
				Endif

				If !Empty(cAviso)
					MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Aviso ao validar schema do Xml")
					stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE om erro "+ cAviso ,'"'+CONDORXML->XML_ATT3+'"')
				Endif

				If Type("oCte:_CTeProc")<> "U"
					oNF 	:= oCte:_CTeProc:_CTe
					cChvCte	:= oCte:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
				ElseIf Type("oCte:_CTe")<> "U"
					oNF 	:= oCte:_CTe
					cChvCte	:= oCte:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
				ElseIf Type("oCte:_enviCTe:_CTe")<> "U"
					oNF		:= oCte:_enviCTe:_CTe
					cChvCte	:= oCte:_enviCTe:_protCTe:_infProt:_chCTe:TEXT
				ElseIf Type("oCte:_procCTe:_CTe") <> "U"
					oNF		:= oCte:_procCTe:_CTe
					cChvCte	:= oCte:_PROCCTE:_PROTCTE:_infProt:_chCTe:TEXT
				ElseIf Type("oNFe:_cteOSProc")<> "U"
					oNF := oNFe:_cteOSProc:_CTeOS
					If Type("oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe")<> "U"
						cChave	:= oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe:TEXT
					Endif
				ElseIf Type("oNFe:_enviCTe:_CTeOS")<> "U"
					oNF := oNFe:_enviCTe:_CTeOS
					If Type("oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe")<> "U"
						cChave	:= oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe:TEXT
					Endif
				Else
					If !lAutoExec
						sfAtuXmlOk("E8")
						MsgAlert("Não foi possível ler o arquivo xml:"+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						//			StaticCall(XMLDCONDOR,stSendMail,"marcelolauschner@gmail.com","Erro ao ler arquivo xml de CTE " ,'"'+CONDORXML->XML_ARQ+'"')
					Else
						sfAtuXmlOk("E8")
					Endif
					//Return .F.
					Loop
				Endif
			Endif


			oIdent     	:= oNF:_InfCTe:_ide
			//oComple	:= oNF:_InfCTe:_compl
			oEmitente  	:= oNF:_InfCTe:_emit
			oRemetente	:= Iif(Type("oNF:_InfCTe:_rem") <> "U",oNF:_InfCTe:_rem,Nil)
			oExpedidor  := Iif(Type("oNF:_InfCTe:_exped") <> "U",oNF:_InfCTe:_exped,Nil)
			oDestino   	:= Iif(Type("oNF:_InfCTe:_Dest") <> "U",oNF:_InfCTe:_Dest,Nil)
			oValorPrest := oNF:_InfCTe:_vPrest
			oImposto	:= oNF:_InfCTe:_imp
			oInfCte		:= Iif(Type("oNF:_InfCTe:_infCTeNorm") <> "U",oNF:_InfCTe:_infCTeNorm,Nil)
			
			
			cF1UFORITR 	:= Iif( SF1->(FieldPos("F1_UFORITR")) > 0,IIf(Type("oIdent:_UFIni") <> "U",oIdent:_UFIni:TEXT,Space(TamSX3("F1_UFORITR")[1])),"")
			cF1MUORITR  := Iif( SF1->(FieldPos("F1_MUORITR")) > 0,IIf(Type("oIdent:_cMunIni") <> "U",Substr(oIdent:_cMunIni:TEXT,3),Space(TamSX3("F1_MUORITR")[1])),"")
			cF1UFDESTR 	:= Iif( SF1->(FieldPos("F1_UFDESTR")) > 0,IIf(Type("oIdent:_UFFim") <> "U",oIdent:_UFFim:TEXT,Space(TamSX3("F1_UFDESTR")[1])),"")
			cF1MUDESTR	:= Iif( SF1->(FieldPos("F1_MUDESTR")) > 0,IIf(Type("oIdent:_cMunFim") <> "U",Substr(oIdent:_cMunFim:TEXT,3),Space(TamSX3("F1_MUDESTR")[1])),"")
			
			// Novo modelo de tratativa da modelagem do número da Nota fiscal
			If cLeftNil $ " #0" 		// 0=Padrão(Soh Num c/zeros)
				cSerCte	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
				cNumCte	:= Right(StrZero(0,(nTmF1Doc) - Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,nTmF1Doc)
			ElseIf cLeftNil == "1" 	// 1=Num e Serie
				cSerCte	:= Right(StrZero(0,(nTmF1Ser) - Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,nTmF1Ser)
				cNumCte	:= Right(StrZero(0,(nTmF1Doc) - Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,nTmF1Doc)
			ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
				cSerCte	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
				cNumCte	:= Padr(oIdent:_nCT:TEXT,nTmF1Doc)
			Endif

			// Verifica se o campo Inscrição Estadual está preenchido
			If Empty(CONDORXML->XML_INSCRI)
				RecLock("CONDORXML",.F.)
				CONDORXML->XML_INSCRI	:= IIf(Type("oEmitente:_IE") <> "U", oEmitente:_IE:TEXT,"ISENTO")
				MsUnlock()
			Endif
			// Verifica se existe a compatibização com centros de custos por Vendedor
			// Customização atender a necessidade vincular o Frete ao vendedor das Nfs vinculadas no CTE
			DbSelectArea("SA3")
			DbSetOrder(1)

			// Obtenho os nós com as notas fiscais do Frete
			oDet := Iif(Type("oRemetente:_infNf")<> "U",oRemetente:_infNf,IIf(Type("oRemetente:_infNfe") <> "U",oRemetente:_infNfe,{}))
			oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

			// Melhoria feita em 25/05/2014 para atender CTe 2.00
			If Empty(oDet) .And. Type("oInfCte:_infDoc:_infNFe") <> "U"
				oDet	:= oInfCte:_infDoc:_infNFe
				oDet	:= IIf(ValType(oDet)=="O",{oDet},oDet)
			Endif

			// Melhoria feita em 03/06/2014 para atender CTe 2.00
			If Empty(oDet) .And. Type("oInfCte:_infDoc:_infNF") <> "U"
				oDet	:= oInfCte:_infDoc:_infNF
				oDet	:= IIf(ValType(oDet)=="O",{oDet},oDet)
			Endif

			// Melhoria feita em 15/09/2015 para Logistica Reversa - Madeiramadeira
			If lMadeira
				If Type("oRemetente:_CNPJ") <> "U" .And. !(Substr(oRemetente:_CNPJ:TEXT,1,8) $ "10490181")
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek(xFilial("SA1")+oRemetente:_CNPJ:TEXT)
					cCgcCli	:= SA1->A1_CGC
				ElseIf Type("oRemetente:_CPF") <> "U" .And. !(Substr(oRemetente:_CPF:TEXT,1,8) $ "10490181")
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek(xFilial("SA1")+oRemetente:_CPF:TEXT)
					cCgcCli	:= SA1->A1_CGC
				ElseIf Type("oDestino:_CNPJ") <> "U"
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek(xFilial("SA1")+oDestino:_CNPJ:TEXT)
					cCgcCli	:= SA1->A1_CGC
				ElseIf Type("oDestino:_CPF") <> "U"
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek(xFilial("SA1")+oDestino:_CPF:TEXT)
					cCgcCli	:= SA1->A1_CGC
				Endif
			Else
				If Type("oDestino:_CNPJ") <> "U"
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek(xFilial("SA1")+oDestino:_CNPJ:TEXT)
					cCgcCli	:= SA1->A1_CGC
				ElseIf Type("oDestino:_CPF") <> "U"
					DbSelectArea("SA1")
					DbSetOrder(3)
					If DbSeek(xFilial("SA1")+oDestino:_CPF:TEXT ) .Or.;
					 	DbSeek(xFilial("SA1")+StrZero(Val(oDestino:_CPF:TEXT),14))
						cCgcCli	:= SA1->A1_CGC
					Else
						cCgcCli	:= Space(14)
					Endif
				Endif
			Endif
			nRecSA1	:= SA1->(Recno())

			// Novo procedimento que permite especificar qual Código e Loja
			If ! Empty(CONDORXML->XML_CODLOJ)
				//StaticCall(XMLDCONDOR,stSendMail,"marcelolauschner@gmail.com","Posicionou fornecedor "+CONDORXML->XML_CODLOJ ,'"'+CONDORXML->XML_ARQ+'"')
				DbSelectArea("SA2")
				DbSetOrder(1)
				If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA
					cInscricao	:= SA2->A2_INSCR
					cUfCad		:= SA2->A2_EST
					// Verifica se não houve um erro de atribuição de Código/Loja e força nova verificação
					If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
						DbSelectArea("SA2")
						DbSetOrder(3)
						DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
						cCodForn	:= SA2->A2_COD
						cLojForn	:= SA2->A2_LOJA
						sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek(xFilial("SA2")+cCodForn+cLojForn)
						cInscricao	:= SA2->A2_INSCR
						cUfCad		:= SA2->A2_EST
					Endif
				Endif
			Else
				//StaticCall(XMLDCONDOR,stSendMail,"marcelolauschner@gmail.com","Posicionou cnpj "+CONDORXML->XML_EMIT ,'"'+CONDORXML->XML_ARQ+'"')
				DbSelectArea("SA2")
				DbSetOrder(3)
				If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA
					sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+cCodForn+cLojForn)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA
					cInscricao	:= SA2->A2_INSCR
					cUfCad		:= SA2->A2_EST
				Endif
			Endif

			//MsgAlert(cCgcCli,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			// Percorro os nós e adiciono ao array a chave das notas no sistema
			For nForA := 1 To Len(oDet)
				iX := nForA
				If Type("oDet[ix]:_chave") <> "U"
					cQry := ""
					cQry += "SELECT F2.R_E_C_N_O_ F2RECNO "
					cQry += "  FROM " + RetSqlName("SF2") + " F2," + RetSqlName("SA1") + " A1 "
					cQry += " WHERE F2.D_E_L_E_T_ = ' ' "
					cQry += "   AND F2_CHVNFE = '" + oDet[ix]:_chave:TEXT + "'"
					cQry += "   AND F2_LOJA = A1_LOJA "
					cQry += "   AND F2_CLIENTE = A1_COD "
					cQry += "   AND F2_FILIAL = '" + xFilial("SF2")+ "'"
					cQry += "   AND A1.D_E_L_E_T_ =' ' "
					cQry += "   AND A1_CGC = '" + cCgcCli + "'"
					cQry += "   AND A1_FILIAL = '" + xFilial("SA1")+ "'"
					
					If lIsDebug
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cQry,{"Ok"},3)
					Endif
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QXF2",.T.,.F.)
					
					While !Eof()

						dbSelectArea("SF2")
						DbGoto(QXF2->F2RECNO)

						// Customizacao que permite levar o centro de custo do vendedor para o lançamento do documento
						DbSelectArea("SA3")
						DbSetOrder(1)
						If SA3->(FieldPos("A3_CC")) > 0
							cCCusto	:= Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_CC")
						Endif
						// Ponto de entrada criado em 27/01/2013
						// Novo centro de custo retornado para o item do frete
						If ExistBlock("XMLCTE04")
							cCCusto	:= ExecBlock("XMLCTE04",.F.,.F.,{cCCusto})
						Endif

						// Adicionada melhoria em 13/09/2013 para considerar Centro de Custo e Classe de Valor a partir da nota de saída
						DbSelectArea("SD2")
						DbSetOrder(3)  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
						If SD2->(FieldPos("D2_CCUSTO")) > 0
							// Somente se não estiver vazio o Centro de custo do Vendedor
							If !Empty(SD2->D2_CCUSTO) .And. Empty(cCCusto)
								cCCusto	:= SD2->D2_CCUSTO
							Endif
						Endif

						If SD2->(FieldPos("D2_CLVL")) > 0
							cClasVlr	:= SD2->D2_CLVL
						Endif

						If SD2->(FieldPos("D2_ITEMCC")) > 0
							cItemCc	:= SD2->D2_ITEMCC
						Endif

						If SD2->(FieldPos("D2_CONTA")) > 0
							cContaC	:= SD2->D2_CONTA
						Endif
						// Fim da Melhoria - 13/09/2013

						U_DbSelArea("CONDORCTEXNFS",.F.,1)
						//"XCN_CHVCTE+XCN_EMP+XCN_FIL+XCN_NUMNFS+XCN_SERNFS+XCN_CLINFS+XCN_LOJNFS"
						If !DbSeek(Padr(cChvCte,TamSX3("F1_CHVNFE")[1])+cEmpAnt+cFilAnt+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO)

							RecLock("CONDORCTEXNFS",.T.)
							CONDORCTEXNFS->XCN_CHVCTE	:= cChvCte
							CONDORCTEXNFS->XCN_EMP     	:= cEmpAnt
							CONDORCTEXNFS->XCN_FIL		:= cFilAnt
							CONDORCTEXNFS->XCN_NUMCTE	:= cNumCte
							CONDORCTEXNFS->XCN_SERCTE  	:= cSerCte
							CONDORCTEXNFS->XCN_FORCTE  	:= SA2->A2_COD
							CONDORCTEXNFS->XCN_LOJCTE 	:= SA2->A2_LOJA
							CONDORCTEXNFS->XCN_TIPCTE  	:= GetNewPar("XM_TPNFCTE","C")
							CONDORCTEXNFS->XCN_CHVNFS	:= SF2->F2_CHVNFE
							CONDORCTEXNFS->XCN_NUMNFS	:= SF2->F2_DOC
							CONDORCTEXNFS->XCN_SERNFS	:= SF2->F2_SERIE
							CONDORCTEXNFS->XCN_CLINFS	:= SF2->F2_CLIENTE
							CONDORCTEXNFS->XCN_LOJNFS	:= SF2->F2_LOJA
							CONDORCTEXNFS->XCN_TIPNFS	:= SF2->F2_TIPO
							CONDORCTEXNFS->XCN_TPFRET	:= "S"
							MsUnlock()
						Endif
						Aadd(aNfsXCte,{CONDORCTEXNFS->XCN_EMP+CONDORCTEXNFS->XCN_FIL+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+CONDORCTEXNFS->XCN_CLINFS+CONDORCTEXNFS->XCN_LOJNFS})
						Aadd(aNfOriCTE,{SF2->F2_FILIAL,;
						SF2->F2_DOC,;
						SF2->F2_SERIE,;
						SF2->F2_CLIENTE,;
						SF2->F2_LOJA,;
						SF2->F2_VALBRUT,;
						cCCusto,;
						cContaC,;
						cItemCc,;
						cClasVlr})
						nTotMerc += SF2->F2_VALBRUT
						// 23/11/2017 - Adiciona Cod.Cliente de entrega
						cF1LOJDEST	:= Iif( SF1->(FieldPos("F1_LOJDEST")) > 0,SF2->F2_LOJA,"")
						cF1CLIDEST	:= Iif( SF1->(FieldPos("F1_CLIDEST")) > 0,SF2->F2_CLIENTE,"")
						DbSelectArea("QXF2")
						DbSkip()
					Enddo
					QXF2->(DbCloseArea())


					// Inicia loop para procurar como Frete sobre Compras - FOB mas que será lançado como Despesas pela rotina Documento Entrada invés de Mata116
					dbSelectArea("SF1")
					dbSetOrder(8)
					If DbSeek(xFilial("SF1") + oDet[ix]:_chave:TEXT)
						cCCusto		:= ""
						cContaC		:= ""
						cItemCc		:= ""
						cClasVlr	:= ""
						// Ponto de entrada criado em 27/01/2013
						// Novo centro de custo retornado para o item do frete
						// Mantém compatibilidade de uso do ponto de entrada 
						If ExistBlock("XMLCTE04")
							cCCusto	:= ExecBlock("XMLCTE04",.F.,.F.,{cCCusto})
						Endif

						U_DbSelArea("CONDORCTEXNFS",.F.,1)
						//"XCN_CHVCTE+XCN_EMP+XCN_FIL+XCN_NUMNFS+XCN_SERNFS+XCN_CLINFS+XCN_LOJNFS"
						If !DbSeek(Padr(cChvCte,TamSX3("F1_CHVNFE")[1])+cEmpAnt+cFilAnt+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)

							RecLock("CONDORCTEXNFS",.T.)
							CONDORCTEXNFS->XCN_CHVCTE	:= cChvCte
							CONDORCTEXNFS->XCN_EMP     	:= cEmpAnt
							CONDORCTEXNFS->XCN_FIL		:= cFilAnt
							CONDORCTEXNFS->XCN_NUMCTE	:= cNumCte
							CONDORCTEXNFS->XCN_SERCTE  	:= cSerCte
							CONDORCTEXNFS->XCN_FORCTE  	:= SA2->A2_COD
							CONDORCTEXNFS->XCN_LOJCTE 	:= SA2->A2_LOJA
							CONDORCTEXNFS->XCN_TIPCTE  	:= GetNewPar("XM_TPNFCTE","C")
							CONDORCTEXNFS->XCN_CHVNFS	:= SF1->F1_CHVNFE
							CONDORCTEXNFS->XCN_NUMNFS	:= SF1->F1_DOC
							CONDORCTEXNFS->XCN_SERNFS	:= SF1->F1_SERIE
							CONDORCTEXNFS->XCN_CLINFS	:= SF1->F1_FORNECE
							CONDORCTEXNFS->XCN_LOJNFS	:= SF1->F1_LOJA
							CONDORCTEXNFS->XCN_TIPNFS	:= SF1->F1_TIPO
							CONDORCTEXNFS->XCN_TPFRET	:= "E"
							MsUnlock()
						Endif

						Aadd(aNfsXCte,{CONDORCTEXNFS->XCN_EMP+CONDORCTEXNFS->XCN_FIL+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+CONDORCTEXNFS->XCN_CLINFS+CONDORCTEXNFS->XCN_LOJNFS})
						Aadd(aNfOriCTE,{SF1->F1_FILIAL,;
						SF1->F1_DOC,;
						SF1->F1_SERIE,;
						SF1->F1_FORNECE,;
						SF1->F1_LOJA,;
						SF1->F1_VALBRUT,;
						cCCusto,;
						cContaC,;
						cItemCc,;
						cClasVlr})
						nTotMerc += SF1->F1_VALBRUT
					Endif
				Endif


				If Type("oDet[ix]:_nDoc") <> "U"
					//MsgAlert(oDet[iX]:_nDoc:TEXT,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))

					cQry := ""
					cQry += "SELECT F2.R_E_C_N_O_ F2RECNO "
					cQry += "  FROM " + RetSqlName("SF2") + " F2," + RetSqlName("SA1") + " A1 "
					cQry += " WHERE F2.D_E_L_E_T_ = ' ' "
					If Type("oDet[ix]:_serie") <> "U"
						cQry += "   AND F2_SERIE LIKE '%" + oDet[ix]:_serie:TEXT + "%' "
						cSerNfs	:= Padr(oDet[ix]:_serie:TEXT,Len(SF2->F2_SERIE))
					Endif
					cQry += "   AND F2_DOC LIKE '%" + oDet[ix]:_nDoc:TEXT + "%'"
					cQry += "   AND F2_LOJA = A1_LOJA "
					cQry += "   AND F2_CLIENTE = A1_COD "
					cQry += "   AND F2_FILIAL = '" + xFilial("SF2")+ "'"
					cQry += "   AND A1.D_E_L_E_T_ =' ' "
					cQry += "   AND A1_CGC = '" + cCgcCli + "'"
					cQry += "   AND A1_FILIAL = '" + xFilial("SA1")+ "'"
					
					If lIsDebug
						Aviso(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) ,cQry,{"Ok"},3)
					Endif
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QXF2",.T.,.F.)

					While !Eof()

						dbSelectArea("SF2")
						DbGoto(QXF2->F2RECNO)

						cNumNfs	:= Padr(StrZero(Val(oDet[ix]:_nDoc:TEXT),Len(Alltrim(SF2->F2_DOC))), TamSX3("F2_DOC")[1])
						cSerNfs	:= Padr(cSerNfs,Len(SF2->F2_SERIE))

						//MsgAlert(cNumNfs,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))

						// Customizacao que permite levar o centro de custo do vendedor para o lançamento do documento
						DbSelectArea("SA3")
						DbSetOrder(1)
						If SA3->(FieldPos("A3_CC")) > 0
							cCCusto	:= Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_CC")
						Endif
						// Ponto de entrada criado em 27/01/2013
						// Novo centro de custo retornado para o item do frete
						If ExistBlock("XMLCTE04")
							cCCusto	:= ExecBlock("XMLCTE04",.F.,.F.,{cCCusto})
						Endif


						// Adicionada melhoria em 13/09/2013 para considerar Centro de Custo e Classe de Valor a partir da nota de saída
						DbSelectArea("SD2")
						DbSetOrder(3)  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
						If SD2->(FieldPos("D2_CCUSTO")) > 0
							// Somente se não estiver vazio o Centro de custo do Vendedor
							If !Empty(SD2->D2_CCUSTO) .And. Empty(cCCusto)
								cCCusto	:= SD2->D2_CCUSTO
							Endif
						Endif

						If SD2->(FieldPos("D2_CLVL")) > 0
							cClasVlr	:= SD2->D2_CLVL
						Endif

						If SD2->(FieldPos("D2_ITEMCC")) > 0
							cItemCc	:= SD2->D2_ITEMCC
						Endif

						If SD2->(FieldPos("D2_CONTA")) > 0
							cContaC	:= SD2->D2_CONTA
						Endif
						// Fim da Melhoria - 13/09/2013

						U_DbSelArea("CONDORCTEXNFS",.F.,1)
						//"XCN_CHVCTE+XCN_EMP+XCN_FIL+XCN_NUMNFS+XCN_SERNFS+XCN_CLINFS+XCN_LOJNFS"
						If !DbSeek(Padr(cChvCte,TamSX3("F1_CHVNFE")[1])+cEmpAnt+cFilAnt+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_TIPO)
							RecLock("CONDORCTEXNFS",.T.)
							CONDORCTEXNFS->XCN_CHVCTE	:= cChvCte
							CONDORCTEXNFS->XCN_EMP     	:= cEmpAnt
							CONDORCTEXNFS->XCN_FIL		:= cFilAnt
							CONDORCTEXNFS->XCN_NUMCTE	:= cNumCte
							CONDORCTEXNFS->XCN_SERCTE  	:= cSerCte
							CONDORCTEXNFS->XCN_FORCTE  	:= SA2->A2_COD
							CONDORCTEXNFS->XCN_LOJCTE 	:= SA2->A2_LOJA
							CONDORCTEXNFS->XCN_TIPCTE  	:= GetNewPar("XM_TPNFCTE","C")
							CONDORCTEXNFS->XCN_CHVNFS	:= SF2->F2_CHVNFE
							CONDORCTEXNFS->XCN_NUMNFS	:= SF2->F2_DOC
							CONDORCTEXNFS->XCN_SERNFS	:= SF2->F2_SERIE
							CONDORCTEXNFS->XCN_CLINFS	:= SF2->F2_CLIENTE
							CONDORCTEXNFS->XCN_LOJNFS	:= SF2->F2_LOJA
							CONDORCTEXNFS->XCN_TIPNFS	:= SF2->F2_TIPO
							CONDORCTEXNFS->XCN_TPFRET	:= "S"
							MsUnlock()
						Endif
						Aadd(aNfsXCte,{CONDORCTEXNFS->XCN_EMP+CONDORCTEXNFS->XCN_FIL+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+CONDORCTEXNFS->XCN_CLINFS+CONDORCTEXNFS->XCN_LOJNFS})
						Aadd(aNfOriCTE,{SF2->F2_FILIAL,;
						SF2->F2_DOC,;
						SF2->F2_SERIE,;
						SF2->F2_CLIENTE,;
						SF2->F2_LOJA,;
						SF2->F2_VALBRUT,;
						cCCusto,;
						cContaC,;
						cItemCc,;
						cClasVlr})
						nTotMerc += SF2->F2_VALBRUT

						DbSelectArea("QXF2")
						DbSkip()
					Enddo
					QXF2->(DbCloseArea())
				Endif
			Next nForA


			// Melhoria implementada em 21/05/2013
			// Valida se a nota referenciada neste XML já existe em outro arquivo XML que tenha sido recebido pela Central XML.
			For nForB := 1 To Len(aNfsXCte)
				iT	:= nForB
				//Padr(oCte:_CTeProc:_protCTe:_infProt:_chCTe:TEXT,TamSX3("F1_CHVNFE")[1])
				U_DbSelArea("CONDORCTEXNFS",.F.,2)
				DbSeek(aNfsXCte[iT,1])
				While !Eof() .And. Alltrim(CONDORCTEXNFS->XCN_EMP+CONDORCTEXNFS->XCN_FIL+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+CONDORCTEXNFS->XCN_CLINFS+CONDORCTEXNFS->XCN_LOJNFS) == Alltrim(aNfsXCte[iT,1])
					If Alltrim(CONDORCTEXNFS->XCN_CHVCTE) <> Alltrim(cChvCte)
						// Posiciona no registro do xml para verificar se tem rejeição gravada
						U_DbSelArea("CONDORXML",.F.,1)
						If DbSeek(CONDORCTEXNFS->XCN_CHVCTE) .And. CONDORXML->XML_CTEFOB != "S"
							// Caso o outro CTe não esteja cancelado irá acusar a duplicidade
							If Empty(CONDORXML->XML_REJEIT)
								If !lAutoExec
									If sfAtuXmlOk("CT")
										If !lOnlyView
											If !MsgYesNo("Foi encontrada a nota fiscal '"+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+"' no CTe '"+CONDORCTEXNFS->XCN_NUMCTE+CONDORCTEXNFS->XCN_SERCTE+"' Deseja lançar assim mesmo?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Amarração de CTe s/Vendas em duplicidade")
												// Reposiciono o registro para garantir
												U_DbSelArea("CONDORXML",.F.,1)
												DbSeek(aArqXml[nB,nPosChvNfe])
												lLoopNext		:= .T.
												//Return
											Endif
										Endif
									Endif
								Else
									// Reposiciono o registro para garantir
									U_DbSelArea("CONDORXML",.F.,1)
									DbSeek(aArqXml[nB,nPosChvNfe])

									If sfAtuXmlOk("CT")
										Return
									Endif
								Endif
							Endif
						Endif

					Endif
					DbSelectArea("CONDORCTEXNFS")
					DbSkip()
				Enddo
			Next nForB



			If Type("oInfCte:_cobr") <> "U"
				oCobr		:= oInfCte:_cobr
			Endif
			// Zero o valor da variável para garantir que não leve valores inválidos para o ponto de entrada A103CND2
			aDupSE2		:= {}
			aDupAxSE2	:= {}
			lDupSE4		:= .F.
			cChave		:= Padr(aArqXml[nB,nPosChvNfe],44)
			If Type("oCobr:_dup") <> "U"
				// Zero a variavel Private, para evitar que venha com dados de outra nota
				// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
				oDup  		:= oCobr:_dup
				oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
				lOnlyDup	:= Len(oDup) == 1
				For nForC := 1 To Len(oDup)
					nP := nForC
					If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
						dVencPXml	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
						If lMadeira
							// Se a data de vencimento do título for menor que a database irá assumir a database como vencimento
							If dVencPXml < dDataBase
								dVencPXml	:= DataValida(dDataBase)
							Endif
						Endif
						Aadd(aDupSE2,{	dVencPXml	,;	// Data Vencimento
						Val(oDup[nP]:_vDup:TEXT)})		// Valor da Duplicata})
						nSumSE2		+= Val(oDup[nP]:_vDup:TEXT)
						U_DbSelArea("CONDORXMLDUPL",.F.,1)

						If lOnlyDup
							cParcela := " "
						Else
							cParcela := IF(nP>1,MaParcela(cParcela),IIF(Empty(cParcela),"A",cParcela))
						Endif
						// Verificou que a chave j[a existe na base

						lExistParc := !DbSeek(cChave + cParcela)
						RecLock("CONDORXMLDUPL",lExistParc)
						CONDORXMLDUPL->XDP_CHAVE	:= cChave
						CONDORXMLDUPL->XDP_PARCEL	:= cParcela
						CONDORXMLDUPL->XDP_VENCTO	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
						CONDORXMLDUPL->XDP_VALOR	:= Val(oDup[nP]:_vDup:TEXT)
						MsUnlock()
					Endif
				Next nForC
			Endif

			// Se for somente a atualização do registro em questão, aborta o processo de geração de nota
			// pois somente interessa que atualize a tabela de CTE x NFE
			// E atualize a tabela CONDORXMLDUPL - Duplicatas por xml 
			If lOnlyView
				Exit
			Endif
			If lLoopNext
				lLoopNext		:= .F.
				Loop
			Endif
			// Reposiciono o registro para garantir
			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[nB,nPosChvNfe])

			// Ponto de entrada para validar Frete sobre vendas
			// Criado em 27/05/2013 a pedido Isolucks
			If ExistBlock("XMLCTE02")
				// Caso o retorno do ponto de entrada seja falso, abandona o lançamento
				If !ExecBlock("XMLCTE02",.F.,.F.,{	Val(oValorPrest:_vTPrest:TEXT),;
				aNfsXCte,;
				Iif(Type("oEmitente:_CNPJ")<> "U",oEmitente:_CNPJ:TEXT,Iif(Type("oEmitente:_CPF") <> "U",oEmitente:_CPF:TEXT,""))})
					//Return
					Loop
				Endif
			Endif

			If !sfVldAlqIcms('V',SA1->A1_CGC,oImposto,oIdent,@cUfOri,@cUfDes, !(!lCheck .And. !Empty(cCondicao) .And. !Empty(dDtVctoCte)))
				Loop
				//Return
			Endif


			// Define variavel para os itens do Documento
			aTotItem		:= {}
			nValPedagio		:= 0
			nValSeguro		:= 0
			nValCompon		:= 0
			// Valida se o Fornecedor Existe

			// Reposiciono o registro para garantir
			U_DbSelArea("CONDORXML",.F.,1)
			DbSeek(aArqXml[nB,nPosChvNfe])

			If Empty(CONDORXML->XML_CONFER)
				If !lAutoExec
					If sfAtuXmlOk("E5")
						MsgAlert("Nota fiscal ainda não foi conferida na SEFAZ.Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						//Return
						Loop
					Endif
				Else
					If sfAtuXmlOk("E5")
						//Return
						Loop
					Endif
				Endif
			Endif



			// Efetua validação da Inscrição estadual contida no emitente com o que está no cadastro do cliente ou fornecedor
			//If Alltrim(CONDORXML->XML_INSCRI) <> Alltrim(cInscricao)
			If !sfVldIE(CONDORXML->XML_INSCRI/*cInIEXml*/,cInscricao/*cInIECad*/,cUfCad)
				If !lAutoExec
					sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
					//If sfAtuXmlOk("IE")
					//	MsgAlert("Inscrição estadual contida no XML '"+Alltrim(CONDORXML->XML_INSCRI)+"' difere do cadastro que contém '"+Alltrim(cInscricao)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						//Return
					//	Loop
					//Endif
					lAtuIECad	:= .F. 
					
					DEFINE MSDIALOG oDlgSA2 Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualizar Inscrição Estadual") FROM 001,001 TO 180,310 PIXEL
					// Ajustar casas decimais conforme SC7  				
					@ 05  ,4   SAY OemToAnsi("Insc.Estadual no XML") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
					@ 04  ,90  MSGET CONDORXML->XML_INSCRI PICTURE PesqPict('SA2','A2_INSCR') When .F. Of oDlgSA2 PIXEL SIZE 60,9
					@ 19  ,4   SAY OemToAnsi("Insc.Estadual Cadastro") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
					@ 20  ,90  MSGET cInscricao PICTURE PesqPict('SA2','A2_INSCR') When .T. Of oDlgSA2 PIXEL SIZE 60,9
					
					@ 045,030 BUTTON "&Confirma" Size 35,10 Action(lAtuIECad := .T.,oDlgSA2:End())	Pixel Of oDlgSA2
					@ 045,070 Button "&Aborta" Size 35,10 Action (oDlgSA2:End())  Pixel Of oDlgSA2
		
					Activate MsDialog oDlgSA2 Centered
					
					If lAtuIECad
						If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
							DbSelectArea("SA2")
							DbSetOrder(1)
							DbSeek(xFilial("SA2")+cCodForn+cLojForn)
							aFornec := {{"A2_COD"  	,cCodForn        	,Nil},; //
							{"A2_LOJA"  	  		,cLojForn        	,Nil},; //
							{"A2_INSCR"  	  		,cInscricao        	,Nil}} 	// 
							
							lMsHelpAuto := .T.
							lMsErroAuto := .F.
						
							Begin Transaction
								INCLUI	:= .F.
								ALTERA	:= .T.
								MSExecAuto({|x,y,z| mata020(x,y,z)},aFornec,4)//Alteração
						
							End Transaction
						
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Return .F.
							Endif
							
						Else
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial("SA1")+cCodForn+cLojForn)
							aFornec := {{"A1_COD"  	,cCodForn        	,Nil},; //
							{"A1_LOJA"  	  		,cLojForn        	,Nil},; //
							{"A1_INSCR"  	  		,cInscricao        	,Nil}} 	// 
							
							lMsHelpAuto := .T.
							lMsErroAuto := .F.
						
							Begin Transaction
								INCLUI	:= .F.
								ALTERA	:= .T.
								
								MSExecAuto({|x,y,z| mata030(x,y,z)},aFornec,4)//Alteração
						
							End Transaction
						
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Return .F.
							Endif
						Endif
						//Restauro valor das variáveis para execução da inclusão da nota fiscal
						lMsErroAuto		:=.F.
						lMsHelpAuto		:= lAutoExec
					Else
						Loop
					Endif			
					ConOut("+"+Replicate("-",98)+"+")
					ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
					ConOut("+"+Replicate("-",98)+"+")
					
				Else
					If 	sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
					//If sfAtuXmlOk("IE")
						//Return
						Loop
					Endif
				Endif
			Endif

			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(xFilial("SA2")+cCodForn+cLojForn)
				If Empty(cCondicao)
					cCondicao	:= SA2->A2_COND
				Endif
				lContinua	:= .F.

				If !lAutoExec
					If GetNewPar("XM_C7FRTD1",.F.)
						DEFINE MSDIALOG oDlgCond TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Continuar lançamento de notas") FROM 001,001 TO 260,400 PIXEL
						@ 005,018 Say "Nota Fiscal "+ StrZero(Val(oIdent:_nCT:TEXT),nTmF1Doc) + " - UF Fornecedor: "+SA2->A2_EST +" - "+SA2->A2_NREDUZ  Pixel Of oDlgCond
						@ 015,018 CHECKBOX oChk Var lCondVacc PROMPT "Condição do Pedido de Compras?" SIZE 100,12 On Change {|| IIF(lCondVacc,cCondicao := Space(6),.T.),oChk:SetFocus()} Of oDlgCond Pixel
						@ 030,018 Say "Informe a Condicao de Pagamento" Pixel of oDlgCond
						@ 030,110 MsGet cCondicao F3 "SE4" Valid (Vazio() .Or. ExistCpo("SE4",cCondicao)) Size 30,10 Pixel of oDlgCond When !lCondVacc
						If !(GetNewPar("XM_CTEUFA2",.F.))
							@ 045,018 Say "UF Origem Transporte" Pixel of oDlgCond
							//<-Leonardo Perrella Nao estava validando PE. Mudado a chave do ExistCPO//
							@ 044,110 MsGet cUfOri F3 "12" Valid ExistCpo("SX5","12"+cUfOri,1) Size 20,10 Pixel of oDlgCond
							If GetNewPar("XM_CTEUFA3",.F.)
								@ 045,150 Say "UF Destino" Pixel of oDlgCond
								@ 044,180 MsGet cUfDes F3 "12" Valid ExistCpo("SX5","12"+cUfDes,1) Size 20,10 Pixel of oDlgCond							
							Endif
						Endif
						// Melhoria implementada para atender obrigatoriedade da informação da Natureza Financeira

						If GetMv("MV_NFENAT")
							@ 061,018 Say "Informe a Natureza" Pixel of oDlgCond
							@ 060,110 MsGet cNatFin F3 "SED" Valid ExistCpo("SED",cNatFin) Size 60,10 Pixel of oDlgCond
						Endif

						@ 076,018 Say "Informe o Pedido Compra" Pixel of oDlgCond
						@ 091,018 Say "Item Pedido" Pixel of oDlgCond
						@ 075,115 MsGet cSC7FRTD1 F3 "SC7FT" Valid ExistCpo("SC7",cSC7FRTD1) Size 60,10 Pixel of oDlgCond
						@ 090,115 MsGet cSC7FRTIT Size 25,10 Pixel of oDlgCond
						
							

						If lSuperUsr
							@ 090,018 CHECKBOX oChk Var lCheck PROMPT "Gera com Interface se Nota Fiscal?" SIZE 100,12 Of oDlgCond Pixel
							@ 110,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
						Endif
						@ 110,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())

						ACTIVATE MSDIALOG oDlgCond CENTERED
					Else
						// Verifica se alguma condição ainda não foi atendida 
						If lCheck .Or. Empty(cCondicao) .Or. Empty(dDtVctoCte) .Or. (GetMv("MV_NFENAT") .And. Empty(cNatFin))
							DEFINE MSDIALOG oDlgCond TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Continuar lançamento de notas") FROM 001,001 TO 290,400 PIXEL
							@ 005,018 Say "Nota Fiscal "+ StrZero(Val(oIdent:_nCT:TEXT),nTmF1Doc) + " - UF Fornecedor: "+SA2->A2_EST +" - "+SA2->A2_NREDUZ  Pixel Of oDlgCond
							@ 020,018 Say "Informe a Condicao de Pagamento" Pixel of oDlgCond
							@ 019,110 MsGet cCondicao F3 "SE4" Valid (Vazio() .Or. ExistCpo("SE4",cCondicao)) Size 30,10 Pixel of oDlgCond
							If !(GetNewPar("XM_CTEUFA2",.F.))
								@ 035,018 Say "UF Origem Transporte" Pixel of oDlgCond
								@ 034,110 MsGet cUfOri F3 "12" Valid ExistCpo("SX5","12"+cUfOri,1) Size 20,10 Pixel of oDlgCond
								If GetNewPar("XM_CTEUFA3",.F.)
									@ 035,150 Say "UF Destino" Pixel of oDlgCond
									@ 034,180 MsGet cUfDes F3 "12" Valid ExistCpo("SX5","12"+cUfDes,1) Size 20,10 Pixel of oDlgCond							
								Endif
							Endif
							//@ 022,018 Say "Tipo de Nota fiscal" Pixel of oDlgCond
							// Melhoria implementada para atender obrigatoriedade da informação da Natureza Financeira

							If GetMv("MV_NFENAT")
								@ 051,018 Say "Informe a Natureza" Pixel of oDlgCond
								@ 050,110 MsGet cNatFin F3 "SED" Valid ExistCpo("SED",cNatFin) Size 60,10 Pixel of oDlgCond
							Endif

							If GetNewPar("XM_C7FRTD1",.F.)
								@ 066,018 Say "Informe o Pedido Compra" Pixel of oDlgCond
								@ 065,110 MsGet cSC7FRTD1 F3 "SC7" Valid ExistCpo("SC7",cSC7FRTD1) Size 60,10 Pixel of oDlgCond
							Else
								// 10/11/2016 - Se informada a data única - assume para todos os CTes
								@ 066,018 Say "Data Vcto Única" Pixel of oDlgCond
								@ 065,110 MsGet dDtVctoCte Valid (Empty(dDtVctoCte) .Or. dDtVctoCte >= dDataBase) Size 40,10 Pixel of oDlgCond					
							Endif
							If lIsCompl
								@ 079,018 Say "Informe o Tipo de Complemento!" Pixel of oDlgCond
								@ 080,110 MsComboBox oTpCompl Var cF1TpCompl Items {"",STR0160,STR0161,STR0162} Size 60,10 Pixel Of oDlgCond
							Endif
							
							If lGrvF1Cli
								If GetMv("MV_ESTADO") $ "SP#RJ"
									lGrvF1Cli	:= .F.
								Endif
								@ 110,018 CHECKBOX oChk Var lGrvF1Cli PROMPT "Grava Cliente/Loja Destino?" SIZE 100,12 Of oDlgCond Pixel
							Endif
							
							If lSuperUsr						
								@ 095,018 CHECKBOX oChk Var lCheck PROMPT "Gera com Interface se Nota Fiscal?" SIZE 100,12 Of oDlgCond Pixel
								@ 125,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
							Endif
							
							@ 125,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())

							ACTIVATE MSDIALOG oDlgCond CENTERED
						Else
							lCheck	:= .F.
							lContinua	:= .T.
						Endif
					Endif
				Else
					// Seta variavel para não gerar interface no Mata103
					lCheck	:= .F.
					lContinua	:= .T.

					// Se houver obrigatoriedade da Natureza, i´ra pegar do cadastro do fornecedor
					If GetMv("MV_NFENAT")
						cNatFin	:= SA2->A2_NATUREZ
						If Empty(cNatFin)
							lContinua	:= .F.
							sfAtuXmlOk("ED")
						Endif
					Endif
					If Empty(cCondicao)
						lContinua	:= .F.
						sfAtuXmlOk("SE")
					Endif
				Endif
				If !lContinua
					Eval(bRefrXmlF)
					Return
				Endif


				DbSelectArea("SE4")
				DbSetOrder(1)
				DbSeek(xFilial("SE4")+cCondicao)
				// Melhoria 10/11/2016 - Permite que todos os CTes gerem com o mesmo vencimento se informada a data
				If !Empty(dDtVctoCte)
					aDupSE2		:= {}
					aDupAxSE2	:= {}
					Aadd(aDupSE2,{	dDtVctoCte	,;							// Data Vencimento
					Val(oValorPrest:_vTPrest:TEXT)})		// Valor da Duplicata})
					lDtVctoCte	:= .T.						
				Endif
				aValCond := 	{;
				Iif(nSumSE2 > 0 , nSumSE2,Val(oValorPrest:_vTPrest:TEXT)),;		// 1 - Valor Total
				0,;																	// 2 - Valor IPI
				0,;																	// 3 - Valor Solidário
				STOD(AllTrim(StrTran(Substr(oIdent:_dhEmi:TEXT,1,10),"-",""))),;	// 4 - Data emissão
				StrZero(Val(oIdent:_nCT:TEXT),nTmF1Doc)}

				//aCondPg		:= Condicao(aValCond[1]/*nValTot*/,cCondicao/*cCond*/,aValCond[2]/*nValIpi*/,aValCond[4]/*dData0*/,aValCond[3]/*nValSolid*/)

				aCab := {{"F1_TIPO"	,IIf(GetNewPar("XM_C7FRTD1",.F.),"N",GetNewPar("XM_TPNFCTE","C"))	,Nil},;// Tipo de Documento - C=Complemento Preço/Frete
				{"F1_FORMUL"        	,"N"                  											,Nil},;// Tipo de Formulario
				{"F1_DOC"           	,cNumCte													    ,Nil},;// Numero do Documento
				{"F1_SERIE"         	,cSerCte					               						,Nil},;// Serie do Documento
				{"F1_EMISSAO"       	,STOD(AllTrim(StrTran(Substr(oIdent:_dhEmi:TEXT,1,10),"-",""))) ,Nil},;// Emissão do Documento
				{"F1_FORNECE"       	,SA2->A2_COD												    ,Nil},;// Codigo do Fornecedor
				{"F1_LOJA"          	,SA2->A2_LOJA          											,Nil},;// Loja do Fornecedor
				{"F1_COND"				,cCondicao														,Nil},;// Condicao de pagamento
				{"F1_ESPECIE"			,Padr("CTE",TamSX3("F1_ESPECIE")[1])							,Nil},;// Especie NF - - CTE-Conhecimento Transporte Eletronico
				{"F1_CHVNFE"			,cChvCte														,Nil}}// Chave Eletronica
				
				If !(GetNewPar("XM_CTEUFA2",.F.))
					Aadd(aCab,{"F1_EST"				,cUfOri												,Nil})// UF Origem
				Endif
				
				If lGrvF1Cli .And. !Empty(cF1LOJDEST) .And. !Empty(cF1CLIDEST)
					Aadd(aCab,{"F1_CLIDEST"				,cF1CLIDEST										,NIl})
					Aadd(aCab,{"F1_LOJDEST"				,cF1LOJDEST										,Nil})
				Endif
				
				If GetNewPar("XM_CTEUFA3",.F.)
					Aadd(aCab,{"F1_ESTDES",cUfDes	 													,Nil}) // UF Destino
				Endif
				
				//F1_UFORITR , F1_MUORITR , F1_UFDESTR , F1_MUDESTR
				If lGrvF1Cli .And. !Empty(cF1UFORITR)
					Aadd(aCab,{"F1_UFORITR", cF1UFORITR,Nil})
				Endif
				If lGrvF1Cli .And. !Empty(cF1MUORITR)
					Aadd(aCab,{"F1_MUORITR", cF1MUORITR,Nil})
				Endif
				If lGrvF1Cli .And. !Empty(cF1UFDESTR)
					Aadd(aCab,{"F1_UFDESTR" ,cF1UFDESTR,Nil})
				Endif
				If lGrvF1Cli .And. !Empty(cF1MUDESTR)
					Aadd(aCab,{"F1_MUDESTR"	,cF1MUDESTR,Nil})
				Endif
			
				
				Aadd(aCab,{"F1_FILIAL"        	,xFilial("SF1")       													,Nil})

				//StaticCall(XMLDCONDOR,stSendMail,"marcelolauschner@gmail.com","Posicionou array cod/loja "+aCab[6,2]+"-"+aCab[7,2] ,'"'+CONDORXML->XML_ARQ+'"')

				// Adicionado em 23/11/2013 o envio do campo Natureza para a geração de CTE sobre Vendas
				Aadd(aCab,{"E2_NATUREZ"   ,cNatFin			,NIL,NIL})

				If SF1->(FieldPos("F1_TPCTE")) > 0
					// N=Normal;C=Complem.Valores;A=Anula.Valores;S=Substituto
					If ( AllTrim(oIdent:_tpCTe:TEXT) == "0" )
						cTpCte	:=	"N"
					ElseIf ( AllTrim(oIdent:_tpCTe:TEXT) = "1" )
						cTpCte	:=	"C"
					ElseIf ( AllTrim(oIdent:_tpCTe:TEXT) == "2" )
						cTpCte	:=	"A"
					ElseIf ( AllTrim(oIdent:_tpCTe:TEXT) == "3" )
						cTpCte		:=	"S"
					Else
						cTpCte	:= " "
					Endif 
					Aadd(aCab,{"F1_TPCTE",	cTpCte		,Nil})

				Endif

				If SF1->(FieldPos("F1_MODAL")) > 0
					cModalCte	:=	AllTrim(oIdent:_modal:TEXT)					
					Aadd(aCab,{"F1_MODAL",	cModalCte			,Nil})
				Endif
				

				If SF1->(FieldPos("F1_TPFRETE")) > 0 .And. !GetNewPar("XM_C7FRTD1",.F.)
					// Adicão do campo tipo de frete
					If Type("oIdent:_forPag:TEXT") <> "U"
						If Alltrim(oIdent:_forPag:TEXT)=="0"
							cModFrete := "C"
						ElseIf Alltrim(oIdent:_forPag:TEXT)=="1"
							cModFrete := "F"
						ElseIf Alltrim(oIdent:_forPag:TEXT)=="2"
							cModFrete := "T"
						ElseIf Alltrim(oIdent:_forPag:TEXT)=="9"
							cModFrete := "S"
						Else
							cModFrete	:= " "
						Endif
						Aadd(aCab,{"F1_TPFRETE"		,cModFrete  ,Nil})
					Endif
				Endif
				// 30/09/2017 - Melhoria para comtemplar P12 que tem novo campo F1_TPCOMPL 
				If lIsCompl
					Aadd(aCab,{"F1_TPCOMPL"	,Substr(Alltrim(cF1TpCompl),1,1)					,Nil})	
				Endif
				
				// Por definição é necessário que haja o cadastro do Produto "FRETE" para que a rotina funcione
				DbSelectArea("SB1")
				DbSetOrder(1)
				If DbSeek(xFilial("SB1")+GetNewPar("XM_CDPFRET","FRETE")) // Código do produto pode ser diferente conforme parametro

					// Localizo Objetos componentes do Frete
					If Type("oValorPrest:_Comp") <> "U"
						oDetPrest := oValorPrest:_Comp
						oDetPrest := IIf(ValType(oDetPrest)=="O",{oDetPrest},oDetPrest)
						For nForD := 1 To Len(oDetPrest)
							xU := nForD 
							// Procuro pelo Pedagio pois não existe crédito de ICMS sobre este servico
							If Alltrim(Upper(StaticCall(MYEMAIL,NoAcento,oDetPrest[xU]:_xNome:TEXT))) == "PEDAGIO"
								nValPedagio	:= Val(oDetPrest[xU]:_vComp:TEXT)
							Endif
							If Alltrim(Upper(StaticCall(MYEMAIL,NoAcento,oDetPrest[xU]:_xNome:TEXT))) == "SEGURO"
								nValSeguro	:= Val(oDetPrest[xU]:_vComp:TEXT)
							Endif
							nValCompon	+= 	Val(oDetPrest[xU]:_vComp:TEXT)
						Next nForD
					Endif

					// Localizo Objetos das notas referenciadas
					oDetNfs 		:= Iif(Type("oRemetente:_infNf")<> "U",oRemetente:_infNf,IIf(Type("oRemetente:_infNfe") <> "U",oRemetente:_infNfe,{}))
					oDetNfs 		:= IIf(ValType(oDetNfs)=="O",{oDetNfs},oDetNfs)
					// Melhoria feita em 25/05/2014 para atender CTe 2.00
					If Empty(oDetNfs) .And. Type("oInfCte:_infDoc:_infNFe") <> "U"
						oDetNfs	:= oInfCte:_infDoc:_infNFe
						oDetNfs	:= IIf(ValType(oDetNfs)=="O",{oDetNfs},oDetNfs)
					Endif

					// Melhoria feita em 03/06/2014 para atender CTe 2.00
					If Empty(oDetNfs) .And. Type("oInfCte:_infDoc:_infNF") <> "U"
						oDetNfs	:= oInfCte:_infDoc:_infNF
						oDetNfs	:= IIf(ValType(oDetNfs)=="O",{oDetNfs},oDetNfs)
					Endif

					lExistMalote	:= .F.
					For nForE := 1 To Len(oDetNfs)
						xU := nForE
						// Procuro a referencia com as notas de saida do Sistema
						If Type("oDetNfs[xU]:_nDoc") <> "U"
							If (oDetNfs[xU]:_nDoc:TEXT == oIdent:_nCT:TEXT .And. oDetNfs[xU]:_serie:TEXT == oIdent:_serie:TEXT) .Or. oDetNfs[xU]:_nCFOP:TEXT=="6359"
								lExistMalote := .T.
							Endif
						Endif
					Next

					If Type("oInfCte:_infCarga:_proPred") <> "U" .And. Type("oInfCte:_infCarga:_xOutCat") <> "U"
						If "DOCUMENTO" $ Upper(oInfCte:_infCarga:_proPred:TEXT) .And. ;
						Upper(oInfCte:_infCarga:_xOutCat:TEXT) $ "ENVELOPE#MALOTE"
							lExistMalote	:= .T.
						Endif
					Endif

					// Caso tenha encontrado o mesmo numero de CTE e Serie para as notas referenciadas, assume que se trata de malote
					If lExistMalote
						DbSelectArea("SB1")
						DbSetOrder(1)
						If !DbSeek(xFilial("SB1")+GetNewPar("XM_CDPMALT","MALOTE")) // Código do produto pode ser diferente conforme parametro
							DbSeek(xFilial("SB1")+GetNewPar("XM_CDPFRET","FRETE")) // Código do produto pode ser diferente conforme parametro
						Endif
					Endif

					// Se existir a tag Valor a receber e
					If Type("oValorPrest:_vRec") <> "U" .And. Val(oValorPrest:_vTPrest:TEXT) < Val(oValorPrest:_vRec:TEXT)
						nValPrest := Val(oValorPrest:_vRec:TEXT) - nValPedagio
						//ElseIf Type("oValorPrest:_vRec") <> "U" .And. Val(oValorPrest:_vTPrest:TEXT) > Val(oValorPrest:_vRec:TEXT)
						//	nValPrest := Val(oValorPrest:_vRec:TEXT) - nValPedagio
					Else
						nValPrest 	:= Val(oValorPrest:_vTPrest:TEXT)- nValPedagio
					Endif
					// Mudança feita em 23/11/2013
					// Permite que gere várias linhas do mesmo item para relacionar a nota de origem no campo D1_NFORI fracionando conforme
					// o valor da nota dentro do total
					nSaldZero 	:= nValPrest
					nValSD1		:= 0
					nSaldPedg	:= nValPedagio

					// Mudança feita em 03/05/2016
					// So realiza o rateio e associacao das NF do frete se este nao for de 1 centavo 
					If nValPrest == 0.01
						aNfOriCTEO := aClone(aNfOriCTE)
						aNfOriCTE := {}
					Endif

					// Caso não tenha dados de notas vinculadas, cria uma linha para listar o produto
					If Len(aNfOriCTE) == 0
						Aadd(aNfOriCTE,{cFilAnt,;					// 	F2_FILIAL			1
						Replicate("9",TamSX3("D1_NFORI")[1]),; 		//	F2_DOC				2
						"999",;    									//	F2_SERIE			3
						"",;										// 	F2_CLIENTE     		4
						"",;										//	F2_LOJA,;          	5
						1,;											//	F2_VALBRUT,; 	    6
						cCCusto,;     					        	//						7
						cContaC,;             						//						8
						cItemCc,;             						//						9
						cClasVlr})  								//						10
						nTotMerc	:= 1
					Endif
					// Efetua a ordenação pelo valor da mercadoria 	
					aSort(aNfOriCTE,,,{|x,y| x[6] < y[6] })
					
					For nForF := 1 To Len(aNfOriCTE)
						iP := nForF

						/*	Aadd(aNfOriCTE,{SF2->F2_FILIAL,;  1
						SF2->F2_DOC,;         2
						SF2->F2_SERIE,;       3
						SF2->F2_CLIENTE,;     4
						SF2->F2_LOJA,;        5
						SF2->F2_VALBRUT,;     6
						cCCusto,;             7
						cContaC,;             8
						cItemCc,;             9
						cClasVlr})  10*/
						// Reposiciona o Código do produto FRETE para não repetir somente o pedágio.
						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek(xFilial("SB1")+GetNewPar("XM_CDPFRET","FRETE")) // Código do produto pode ser diferente conforme parametro
												
						aItem:={	{"D1_FILIAL"	,xFilial("SD1")	             	   						,Nil},;
						{"D1_COD"   	,SB1->B1_COD					                   	   			,Nil}}
						nValSD1	:= Round(aNfOriCTE[iP,6] / nTotMerc * nValPrest,2 )
						If nValSD1 < 0.01
							nValSD1	:= 0.01
						Endif
						// Efetua o calculo para evitar erro de soma de fracionamentos
						If iP < Len(aNfOriCTE)
							nSaldZero -= nValSD1
						Else
							nValSD1 	:= nSaldZero
						Endif
	
						If GetNewPar("XM_TPNFCTE","C") == "C"
							Aadd(aItem,{"D1_VUNIT" 		,nValSD1   		   								,Nil})
							Aadd(aItem,{"D1_TOTAL" 		,nValSD1											,Nil})
							Aadd(aItem,{"D1_TES"   		,SB1->B1_TE								 	   	,Nil})
						Else
							If Posicione("SF4",1,xFilial("SF4")+SB1->B1_TE,"F4_QTDZERO") <> "1"
								Aadd(aItem,{"D1_QUANT" 	,1													,Nil})
								Aadd(aItem,{"D1_VUNIT" 	,nValSD1   		   								,Nil})
							Endif
							Aadd(aItem,{"D1_TOTAL" 	,nValSD1										   		,Nil})
						Endif
	
						Aadd(aItem,{"D1_NFORI"   	,aNfOriCTE[iP,2]			             				,Nil})
						Aadd(aItem,{"D1_SERIORI" 	,aNfOriCTE[iP,3]		               				,Nil})
	
						cNewOper	:= GetNewPar("XM_FMPADCP",Space(TamSX3("FM_TIPO")[1]))
						If !Empty(cNewOper)
							// 06/02/2015 - Adicionada a busca pelo TES por erro na função A103INICPO do MATA103X.PRX
							// Procura por Tes Inteligente
							cNewTes	:= MaTesInt(1/*nEntSai*/,cNewOper,SA2->A2_COD,SA2->A2_LOJA,"F"/*cTipoCF*/,SB1->B1_COD)
							// Procura padrão do cadastro de produto
							If Empty(cNewTes)
								cNewTes	:= SB1->B1_TE
							Endif
							If !Empty(cNewTes) .And. GetNewPar("XM_TPNFCTE","C") <> "C"
								Aadd(aItem,{"D1_TES"  	,cNewTes  	,Nil})
							Endif
							If lAddOper 
								DbSelectArea("SX5")
								DbSetOrder(1)
								If DbSeek(xFilial("SX5")+"DJ"+cNewOper)
									Aadd(aItem,{"D1_OPER"	,cNewOper									,Nil})
								Endif
							Endif	
						Endif
	
						// 13/09/2013 Feito melhorias para contemplar os dados de Conta Contábil / Centro de Custo / Classe Valor e Item Conta
						If !Empty(aNfOriCTE[iP,8]) .And. GetNewPar("XM_LD1CONT",.F.)
							Aadd(aItem,{"D1_CONTA"		,aNfOriCTE[iP,8]/*cContaC*/						,Nil})
						Endif
	
						If !Empty(aNfOriCTE[iP,7]) .And. GetNewPar("XM_LD1CCUS",.F.)
							Aadd(aItem,{"D1_CC"		,aNfOriCTE[iP,7]/*cCCusto*/							,Nil})
						Endif
	
						If !Empty(aNfOriCTE[iP,10]) .And. GetNewPar("XM_LD1CLVL",.F.)
							Aadd(aItem,{"D1_CLVL"	,aNfOriCTE[iP,10]/*cClasVlr	*/						,Nil})
						Endif
	
						If !Empty(aNfOriCTE[iP,9]) .And. GetNewPar("XM_LD1ITCC",.F.)
							Aadd(aItem,{"D1_ITEMCTA",aNfOriCTE[iP,9]/*cItemCc		*/					,Nil})
						Endif
	
						// Customização que atende necessidade especifica da Studiotrama
						// 27/11/2013
						If SD1->(FieldPos("D1_NATUREZ")) > 0
							Aadd(aItem,{"D1_NATUREZ",	cNatFin											,Nil})
						Endif
						If SD1->(FieldPos("D1_DTREF")) > 0
							Aadd(aItem,{"D1_DTREF",	STOD(AllTrim(StrTran(Substr(oIdent:_dhEmi:TEXT,1,10),"-",""))),Nil})
						Endif
						
						// 13/08/2017 - Melhoria para verificar se o fracionamento do item ficou zerado
						If nValSD1 > 0
							// Ponto de entrada criado em 29/06/2015
							// Permite que o cliente customize adição de novos campos no vetor de itens
							If ExistBlock("XMLCTE09")
								ExecBlock("XMLCTE09",.F.,.F.,aClone(aNfOriCTE[iP]))
							Endif
	
							AADD(aTotItem,aItem)
						Endif
						
						If nValPedagio > 0
							// Por definicação é necessário que hája o cadastro do Produto "PEDAGIO" para que a rotina funcione
							DbSelectArea("SB1")
							DbSetOrder(1)
							If DbSeek(xFilial("SB1")+GetNewPar("XM_CDPEDAG","PEDAGIO")) // Código do produto pode ser diferente conforme parametro
								
								
								aItem:={	{"D1_FILIAL"	,xFilial("SD1")	 				            			,Nil},;
								{"D1_COD"     	,SB1->B1_COD  	                          	 			,Nil}}

								nValSD1	:= Round(aNfOriCTE[iP,6] / nTotMerc * nValPedagio,2 )
								// Efetua o calculo para evitar erro de soma de fracionamentos
								If iP < Len(aNfOriCTE)
									nSaldPedg -= nValSD1
								Else
									nValSD1 	:= nSaldPedg
								Endif

								If GetNewPar("XM_TPNFCTE","C") == "C"
									Aadd(aItem,{"D1_VUNIT" 		,nValSD1   		   								,Nil})
									Aadd(aItem,{"D1_TOTAL" 		,nValSD1   							 			,Nil})
									Aadd(aItem,{"D1_TES"   		,SB1->B1_TE								 	   	,Nil})
								Else
									If Posicione("SF4",1,xFilial("SF4")+SB1->B1_TE,"F4_QTDZERO") <> "1"
										Aadd(aItem,{"D1_QUANT" 	,1 													,Nil})
										Aadd(aItem,{"D1_VUNIT"  ,nValSD1    							 			,Nil})
									Endif
									Aadd(aItem,{"D1_TOTAL" 	,nValSD1    							 		   		,Nil})
								Endif

								Aadd(aItem,{"D1_NFORI"   	,aNfOriCTE[iP,2]			             				,Nil})
								Aadd(aItem,{"D1_SERIORI" 	,aNfOriCTE[iP,3]		               				,Nil})

								cNewOper	:= GetNewPar("XM_FMPADCP",Space(TamSX3("FM_TIPO")[1]))
								If !Empty(cNewOper)
									// 06/02/2015 - Adicionada a busca pelo TES por erro na função A103INICPO do MATA103X.PRX
									// Procura por Tes Inteligente
									cNewTes	:= MaTesInt(1/*nEntSai*/,cNewOper,SA2->A2_COD,SA2->A2_LOJA,"F"/*cTipoCF*/,SB1->B1_COD)
									// Procura padrão do cadastro de produto
									If Empty(cNewTes)
										cNewTes	:= SB1->B1_TE
									Endif
									If !Empty(cNewTes) .And. GetNewPar("XM_TPNFCTE","C") <> "C"
										Aadd(aItem,{"D1_TES"  	,cNewTes  	,Nil})
									Endif
									If lAddOper .And. ExistCpo("SX5","DJ"+cNewOper)
										Aadd(aItem,{"D1_OPER",	cNewOper												,Nil})
									Endif
								Endif

								// 13/09/2013 Feito melhorias para contemplar os dados de Conta Contábil / Centro de Custo / Classe Valor e Item Conta
								If !Empty(aNfOriCTE[iP,8]) .And. GetNewPar("XM_LD1CONT",.F.)
									Aadd(aItem,{"D1_CONTA"		,aNfOriCTE[iP,8]/*cContaC*/						,Nil})
								Endif

								If !Empty(aNfOriCTE[iP,7]) .And. GetNewPar("XM_LD1CCUS",.F.)
									Aadd(aItem,{"D1_CC"		,aNfOriCTE[iP,7]/*cCCusto*/							,Nil})
								Endif

								If !Empty(aNfOriCTE[iP,10]) .And. GetNewPar("XM_LD1CLVL",.F.)
									Aadd(aItem,{"D1_CLVL"	,aNfOriCTE[iP,10]/*cClasVlr	*/						,Nil})
								Endif

								If !Empty(aNfOriCTE[iP,9]) .And. GetNewPar("XM_LD1ITCC",.F.)
									Aadd(aItem,{"D1_ITEMCTA",aNfOriCTE[iP,9]/*cItemCc		*/					,Nil})
								Endif

								// Customização que atende necessidade especifica da Studiotrama
								// 27/11/2013
								If SD1->(FieldPos("D1_NATUREZ")) > 0
									Aadd(aItem,{"D1_NATUREZ",	cNatFin											,Nil})
								Endif
								If SD1->(FieldPos("D1_DTREF")) > 0
									Aadd(aItem,{"D1_DTREF",	STOD(AllTrim(StrTran(Substr(oIdent:_dhEmi:TEXT,1,10),"-",""))),Nil})
								Endif
								// Garante que somente valores positivos e não zerados serão adicionados
								If nValSD1 > 0
									// Ponto de entrada criado em 29/06/2015
									// Permite que o cliente customize adição de novos campos no vetor de itens	
									If ExistBlock("XMLCTE09")
										ExecBlock("XMLCTE09",.F.,.F.,aClone(aNfOriCTE[iP]))
									Endif
									//If nSaldPedg == 0
									DbSelectArea("SF4")
									DbSetOrder(1)
									DbSeek(xFilial("SF4")+cNewTes)

									If SF4->(FieldPos("F4_AGRPEDG")) > 0 .And. SF4->F4_AGRPEDG $ "1#2" //1=Agregar na base ICMS;2=Agregar somente no total NF;3=Nao considera 
										Aadd(aCab,{"F1_VALPEDG",	nValPedagio		,Nil})
										lAddVlrPedg	:= .T.
									Else
										lAddVlrPedg	:= .F.
										AADD(aTotItem,aItem)																			
									Endif
								Endif
							Endif
						Endif
					Next nForF

					If !lAddVlrPedg	
						nValPedagio	:= 0
					Endif

					// Ponto de entrada criado em 21/11/2016
					// Permite que o cliente customize antes da chamada da MATA103
					If ExistBlock("XMLCTE14")
						ExecBlock("XMLCTE14",.F.,.F.,{aClone(aCab),aClone(aTotItem)})
					Endif

					// Tratativa diferente para ler pedido de compra informado
					If GetNewPar("XM_C7FRTD1",.F.)
						If !lCondVacc
							cCondXML := cCondicao
						EndIf
						nSumC7D1		:= 0
						aTotItem		:= {} // Preciso zerar os itens anteriores
						DbSelectArea("SC7")
						DbSetOrder(1)
						DbSeek(xFilial("SC7")+cSC7FRTD1+cSC7FRTIT)
						While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM+SC7->C7_ITEM == xFilial("SC7")+cSC7FRTD1+cSC7FRTIT
							aItem	:=	{}
							Aadd(aItem,{"D1_FILIAL"	,xFilial("SD1")	 		          			,Nil})
							Aadd(aItem,{"D1_COD"    ,SC7->C7_PRODUTO               	 			,Nil})
							Aadd(aItem,{"D1_QUANT" 	,SC7->C7_QUANT								,Nil})

							cNewOper	:= GetNewPar("XM_FMPADCP",Space(TamSX3("FM_TIPO")[1]))
							If !Empty(cNewOper)
								// 02/07/2015 - Adicionada a busca pelo TES por erro na função A103INICPO do MATA103X.PRX
								// Procura por Tes Inteligente
								cNewTes	:= MaTesInt(1/*nEntSai*/,cNewOper,SC7->C7_FORNECE,SC7->C7_LOJA,"F"/*cTipoCF*/,SB1->B1_COD)
								// Procura padrão do cadastro de produto
								If Empty(cNewTes)
									cNewTes	:= SB1->B1_TE
								Endif
								If !Empty(cNewTes) .And. GetNewPar("XM_TPNFCTE","C") <> "C"
									Aadd(aItem,{"D1_TES"  	,cNewTes  	,Nil})
								Endif
								If lAddOper .And. ExistCpo("SX5","DJ"+cNewOper)
									Aadd(aItem,{"D1_OPER",	cNewOper												,Nil})
								Endif
							Else
								Aadd(aItem,{"D1_TES"  	,SC7->C7_TES  	,Nil})
							Endif

							Aadd(aItem,{"D1_VUNIT"  	,SC7->C7_PRECO								,Nil})
							Aadd(aItem,{"D1_TOTAL" 		,SC7->C7_TOTAL				 		   		,Nil})
							nSumC7D1	+= SC7->C7_TOTAL
							Aadd(aItem,{"D1_PEDIDO"		,SC7->C7_NUM								,Nil})
							Aadd(aItem,{"D1_ITEMPC"		,SC7->C7_ITEM								,Nil})
							Aadd(aItem,{"D1_CONTA"		,SC7->C7_CONTA								,Nil})
							Aadd(aItem,{"D1_CC"			,SC7->C7_CC									,Nil})
							Aadd(aItem,{"D1_CLVL"		,SC7->C7_CLVL								,Nil})
							Aadd(aItem,{"D1_ITEMCTA"	,SC7->C7_ITEMCTA							,Nil})
							AADD(aTotItem,aItem)
							DbSelectArea("SC7")
							DbSkip()
						Enddo
						//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
						//<-Leonardo Perrella - 16/09/15 Preenchimento da posição do array para D1_VUNIT e D1_TOTAL|--|--|
						//--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
						If nValPrest + nValPedagio < nSumC7D1
							aTotItem[Len(aTotItem),aScan(aTotItem[1],{|a| AllTrim(a[1]) == "D1_VUNIT"}),2]	-=  (nValPrest + nValPedagio - nSumC7D1 )
							aTotItem[Len(aTotItem),aScan(aTotItem[1],{|a| AllTrim(a[1]) == "D1_TOTAL"}),2]	-=  (nValPrest + nValPedagio - nSumC7D1 )
						ElseIf nValPrest + nValPedagio > nSumC7D1
							aTotItem[Len(aTotItem),aScan(aTotItem[1],{|a| AllTrim(a[1]) == "D1_VUNIT"}),2]	+=  (nValPrest + nValPedagio - nSumC7D1 )
							aTotItem[Len(aTotItem),aScan(aTotItem[1],{|a| AllTrim(a[1]) == "D1_TOTAL"}),2]	+=  (nValPrest + nValPedagio - nSumC7D1 )
						Endif

					Endif

					If Len(aTotItem) > 0
						// tira teima de valores montados no acols
						//For k := 1 To Len(aCab)
						//	Alert(aCab[k,1])
						//	Alert(aCab[k,2])
						//Next
						cSC7FRTD1 := Space(TamSX3("D1_PEDIDO")[1])
						cSC7FRTIT := Space(TamSX3("D1_ITEM")[1])

						Mata103(aCab, aTotItem , 3 , lCheck)

						Eval(bRefrPerg)
						// Adicionada melhoria que grava data e hora e usuario do lancamento do documento de frete
						DbSelectArea("SF1")
						DbSetOrder(1)
						If DbSeek(xFilial("SF1")+aCab[3,2]+Padr(aCab[4,2],nTmF1Ser)+aCab[6,2]+aCab[7,2]+aCab[1,2])
							U_DbSelArea("CONDORXML",.F.,1)
							If DbSeek(SF1->F1_CHVNFE)
								RecLock("CONDORXML",.F.)
								CONDORXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
								CONDORXML->XML_LANCAD	:= SF1->F1_DTDIGIT
								CONDORXML->XML_HORLAN 	:= Time()
								CONDORXML->XML_USRLAN	:= Padr(cUserName,30)
								CONDORXML->XML_NUMNF	:= SF1->F1_SERIE+SF1->F1_DOC
								MsUnlock()
								ConOut("+"+Replicate("-",98)+"+")
								ConOut(Padr("|Gravou CTe " +SF1->F1_CHVNFE + " " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) ,99)+"|")
								ConOut("+" + Replicate("-",98)+"+")
							Endif
						Endif
					Else
						sfAtuXmlOk("E7")
					Endif
				Endif
			Else
				If !lAutoExec
					MsgAlert("Fornecedor do CNPJ '"+Iif(Type("oEmitente:_CNPJ")<> "U",oEmitente:_CNPJ:TEXT,Iif(Type("oEmitente:_CPF") <> "U",oEmitente:_CPF:TEXT,"zzz"))+"' não cadastrado no Sistema!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Fornecedor inválido!")
				Else
					sfAtuXmlOk("A2")
				Endif
			Endif
		Endif
		// Zero variavel de duplicatas a cada registro de Frete
		aDupSE2		:= {}
		aDupAxSE2	:= {}
		lDupSE4		:= .F.
		nSumSE2		:= 0

	Next nForH
	// Zero variavel de duplicatas
	aDupSE2		:= {}
	aDupAxSE2		:= {}
	lDupSE4		:= .F.
	nSumSE2		:= 0

Return


/*/{Protheus.doc} sfVldTpCTE
(Verifica o tipo de CTe para posicionar na SF1)
@author MarceloLauschner
@since 13/10/2013
@version 1.0
@return cTipCte,Tipo de Frete Complemento preço/Normal
@example
(examples)
@see (links_or_references)
/*/
Static Function sfVldTpCTE()

	Local		cTipCte		:= CONDORXML->XML_TIPODC

	// Se não for frete s/vendas ou compras, retorna o proprio tipo
	If !CONDORXML->XML_TIPODC $ "F#T"
		Return CONDORXML->XML_TIPODC
	Else
		// Alterado em 15/05/2014 para retornar vazio para não validar F1_TIPO no Dbseek quando CTes
		// As validações abaixo começaram a criar problemas de posicionamento por causa do excesso de diversidade de formas de gerar um CTe
		Return ""
	Endif


Return cTipCte



/*/{Protheus.doc} sfMata116
(Efetua gravaão do Mata116 - Inclusão e Exclusão  )
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@param lExclui, lógico, (Descrição do parâmetro)
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function sfMata116(lExclui)

	Local		cCodTes		:= Space(TamSX3("F4_CODIGO")[1])
	Local		lContinua	:= .F.
	Local  		cAviso 		:= ""
	Local   	cErro		:= ""
	Local		cF1Fornece	:= ""
	Local		cF1Loja		:= ""
	Local		cF1Est		:= ""
	Local		nTipoNf		:= 1
	Local		cInscricao	:= ""
	Local		nDeduz		:= 0 //<--Leonardo Perrella Variável de Dedução do valor total do CTE para inclusão Complemento Frete//
	Local		dDtCteIni	:= dDataBase
	Local		dDtCteFim	:= dDataBase
	Local		iW , iY
	Local		nForA,nForB,nForC,nForD
	Local		cUfCad		:= ""
	Local		aCboAglut	:= {"Sim","Não"}
	Local		nCboAglut	:= 1
	Local		cCboAglut	:= "Sim"
	Local 		oCboAglut
	Default	lExclui			:= .F.
	Private	cCondPg			:= Space(TamSX3("E4_CODIGO")[1])
	Private	cModFrete		:= ""
	Private cTpCte			:= ""
	Private cModalCte		:= ""

	Private aNfsCte			:= {}
	Private oDet,oNotas
	Private lMsErroAuto 	:= .F.
	Private aItens			:= {}
	Private aCabec			:= {}
	Private oCte
	Private aHeader			:= oMulti:aHeader

	If!aArqXml[oArqXml:nAt,nPosTpNota] $ "F#T"
		Return .F.
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])

	oCte := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)

	If !Empty(cErro)
		If !lAutoExec
			MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
			stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE - "+cErro ,'"'+CONDORXML->XML_ARQ+'"')
		Else
			sfAtuXmlOk("F1")
		Endif
		Return .F.
	Endif

	If !Empty(cAviso)
		MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Aviso ao validar schema do Xml")
		stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE om erro "+ cAviso ,'"'+CONDORXML->XML_ARQ+'"')
	Endif

	If Type("oCte:_CTeProc")<> "U"
		oNF 	:= oCte:_CTeProc:_CTe
	ElseIf Type("oCte:_procCTe:_CTe") <> "U"
		oNF		:= oCte:_procCTe:_CTe
	ElseIf Type("oCte:_CTe")<> "U"
		oNF := oCte:_CTe
	Else
		cAviso	:= ""
		cErro	:= ""

		oCte := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)

		If !Empty(cErro)
			If !lAutoExec
				MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
				stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE - "+cErro ,'"'+CONDORXML->XML_ATT3+'"')
			Else
				sfAtuXmlOk("F1")
			Endif
			Return .F.
		Endif

		If !Empty(cAviso)
			MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")
			stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Marcação de CTE om erro "+ cAviso ,'"'+CONDORXML->XML_ATT3+'"')
		Endif

		If Type("oCte:_CTeProc")<> "U"
			oNF := oCte:_CTeProc:_CTe
		ElseIf Type("oCte:_CTe")<> "U"
			oNF := oCte:_CTe
		Else
			MsgAlert("Não foi possível ler o arquivo xml:"+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			//			StaticCall(XMLDCONDOR,stSendMail,"marcelolauschner@gmail.com","Erro ao ler arquivo xml de CTE " ,'"'+CONDORXML->XML_ARQ+'"')
			Return .F.
		Endif
	Endif

	If Empty(CONDORXML->XML_CONFER)
		If !lAutoExec
			lSoma	:= .F.
			MsgAlert("Nota fiscal ainda não foi conferida na SEFAZ.Não é permitido marcar para lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação Cancelada!")
		Else
			lSoma	:= .F.
		Endif
	Endif


	oIdent     	:= oNF:_InfCTe:_ide
	//oComple	:= oNF:_InfCTe:_compl
	oEmitente  	:= oNF:_InfCTe:_emit
	oRemetente	:= oNF:_InfCTe:_rem
	//oExpedidor  := Iif(Type("oNF:_InfCTe:_exped") <> "U",oNF:_InfCTe:_exped,Nil)
	oDestino   	:= oNF:_InfCTe:_Dest
	oValorPrest := oNF:_InfCTe:_vPrest
	oImposto	:= oNF:_InfCTe:_imp
	If Type("oNF:_InfCTe:_infCTeNorm") <> "U"
		oInfCte		:= oNF:_InfCTe:_infCTeNorm
	Endif

	// Novo modelo de tratativa da modelagem do número da Nota fiscal
	If cLeftNil $ " #0" 		// 0=Padrão(Soh Num c/zeros)
		cSerCte	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
		cNumCte	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,nTmF1Doc)
	ElseIf cLeftNil == "1" 	// 1=Num e Serie
		cSerCte	:= Right(StrZero(0,(nTmF1Ser)-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,nTmF1Ser)
		cNumCte	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,nTmF1Doc)
	ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
		cSerCte	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
		cNumCte	:= Padr(oIdent:_nCT:TEXT,nTmF1Doc)
	Endif

	// Verifica se o campo Inscrição Estadual está preenchido
	If Empty(CONDORXML->XML_INSCRI)
		RecLock("CONDORXML",.F.)
		CONDORXML->XML_INSCRI	:= IIf(Type("oEmitente:_IE") <> "U", oEmitente:_IE:TEXT,"ISENTO")
		MsUnlock()
	Endif

	// Parametro TIV_REMEMI mantido por compatibilidade de customização do cliente Vaccinar
	If (Type("oEmitente:_CNPJ") <> "U" .And. Type("oRemetente:_CNPJ") <> "U" .And. oEmitente:_CNPJ:TEXT == oRemetente:_CNPJ:TEXT .And. !SA2->A2_COD $ Alltrim(GetNewPar("TIV_REMEMI","zzzzzz"))) .Or.;
	(Type("oEmitente:_CPF") <> "U" .And. Type("oRemetente:_CPF") <>"U" .And. oEmitente:_CPF:TEXT == oRemetente:_CPF:TEXT .And. !SA2->A2_COD $ Alltrim(GetNewPar("TIV_REMEMI","zzzzzz")))
		If !lExclui
			If !MsgYesNo("Remetente do CTE é igual ao Emitente do CTE. Deseja continuar o lançamento? ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Remetente igual a Emitente!")
				Return .F. 
			Endif
		Endif
	ElseIf Type("oIdent:_toma03:_toma") <> "U" .And. oIdent:_toma03:_toma:TEXT <> "3"
		// Tomador for o Remetente e Frete Fob Ativado 
		If !(oIdent:_toma03:_toma:TEXT $ "0" .And. CONDORXML->XML_CTEFOB == "S" )//.And. oIdent:_forPag:TEXT == "0")
			If !lExclui
				MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma03="+oIdent:_toma03:_toma:TEXT)
			Endif
			Return .F.
		Endif
	ElseIf Type("oIdent:_toma03:_toma") <> "U" .And. oIdent:_toma03:_toma:TEXT == "3"
		If Type("oDestino:_CNPJ") <> "U"
			If (Alltrim(oDestino:_CNPJ:TEXT) <> SM0->M0_CGC .And. CONDORXML->XML_CTEFOB <> "S")
				If !lExclui
					MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma03="+oIdent:_toma03:_toma:TEXT)
				Endif
				Return .F.
			Endif
		ElseIf Type("oDestino:_CPF")
			If (Alltrim(oDestino:_CPF:TEXT) <> SM0->M0_CGC .And. CONDORXML->XML_CTEFOB <> "S")
				If !lExclui
					MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma03="+oIdent:_toma03:_toma:TEXT)
				Endif
			Endif
			Return .F.
		Endif
	ElseIf Type("oIdent:_toma3:_toma") <> "U" .And. oIdent:_toma3:_toma:TEXT <> "3"
		// Tomador for o Remetente e Frete Fob Ativado 
		If !(oIdent:_toma3:_toma:TEXT $ "0" .And. CONDORXML->XML_CTEFOB == "S" )//.And. oIdent:_forPag:TEXT == "0")
			If !lExclui
				MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma3="+oIdent:_toma3:_toma:TEXT)
			Endif
			Return .F.
		Endif
	ElseIf Type("oIdent:_toma3:_toma") <> "U" .And. oIdent:_toma3:_toma:TEXT == "3"
		If Type("oDestino:_CNPJ") <> "U"
			If (Alltrim(oDestino:_CNPJ:TEXT) <> SM0->M0_CGC .And. CONDORXML->XML_CTEFOB <> "S")
				If !lExclui
					MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma3="+oIdent:_toma3:_toma:TEXT)
				Endif
				Return .F.
			Endif
		ElseIf Type("oDestino:_CPF")
			If (Alltrim(oDestino:_CPF:TEXT) <> SM0->M0_CGC .And. CONDORXML->XML_CTEFOB <> "S")
				If !lExclui
					MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma3="+oIdent:_toma3:_toma:TEXT)
				Endif
			Endif
			Return .F.
		Endif
	ElseIf Type("oIdent:_toma4:_CNPJ") <> "U" .And. Alltrim(oIdent:_toma4:_CNPJ:TEXT) <> SM0->M0_CGC
		If !lExclui
			MsgAlert("Tomador de Serviço não é o Destinatário! Para lançamento de Frete sobre compras, o Tomador precisa ser o Destinatário",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Tomador de serviço inválido!! Toma04="+Alltrim(oIdent:_toma4:_CNPJ:TEXT))
		Endif
		Return .F.
		/*<toma4>
		<toma>4</toma>
		<CNPJ>04611035000118</CNPJ>
		<IE>254758100</IE>
		<xNome>SUPERLOG TRANSPORTES E LOGISTICA PROMOCIONAL LTDA ME</xNome>
		<xFant>SUPERLOG</xFant>
		<enderToma>
		<xLgr>R  BAHIA</xLgr>
		<nro>4601</nro>
		<xBairro>SALTO WEISSBACH</xBairro>
		<cMun>4202404</cMun>
		<xMun>BLUMENAU</xMun>
		<CEP>89032000</CEP>
		<UF>SC</UF>
		<cPais>1058</cPais>
		<xPais>BRASIL</xPais>
		</enderToma>
		</toma4>*/
	ElseIf Type("oIdent:_toma4:_CNPJ") <> "U" .And. Alltrim(oIdent:_toma4:_CNPJ:TEXT) == SM0->M0_CGC

	Else
		cCgcDevedor := Iif(Type("oRemetente:_CNPJ") <> "U" ,oRemetente:_CNPJ:TEXT,Iif(Type("oRemetente:_CPF") <>"U",oRemetente:_CPF:TEXT,"ZZ"))
		If cCgcDevedor <> SM0->M0_CGC
			MsgAlert("Tomador de Serviço não é a Empresa posicionada! O devedor deste frete é o CNPJ "+Transform(cCgcDevedor,"@r 99.999.999/9999-99") ,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Devedor do frete inválido")
			Return .F.
		Endif
	Endif

	// Novo procedimento que permite especificar qual Código e Loja
	If !Empty(CONDORXML->XML_CODLOJ)
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			cCodForn	:= SA2->A2_COD
			cLojForn	:= SA2->A2_LOJA
			cInscricao	:= SA2->A2_INSCR
			cUfCad		:= SA2->A2_EST
			If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
				DbSelectArea("SA2")
				DbSetOrder(3)
				DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
				cCodForn	:= SA2->A2_COD
				cLojForn	:= SA2->A2_LOJA
				sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+cCodForn+cLojForn)
				cInscricao	:= SA2->A2_INSCR
				cUfCad		:= SA2->A2_EST
			Endif
		Endif
	Else
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
			cCodForn	:= SA2->A2_COD
			cLojForn	:= SA2->A2_LOJA
			sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+cCodForn+cLojForn)
			cInscricao	:= SA2->A2_INSCR
			cUfCad		:= SA2->A2_EST
		Endif
	Endif

	// Efetua validação da Inscrição estadual contida no emitente com o que está no cadastro do cliente ou fornecedor
	//If Alltrim(CONDORXML->XML_INSCRI) <> Alltrim(cInscricao)
	If !sfVldIE(CONDORXML->XML_INSCRI/*cInIEXml*/,cInscricao/*cInIECad*/,cUfCad)
		If !lAutoExec
			//If sfAtuXmlOk("IE")
			sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
			//	MsgAlert("Inscrição estadual contida no XML '"+Alltrim(CONDORXML->XML_INSCRI)+"' difere do cadastro que contém '"+Alltrim(cInscricao)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação!")
			//	Return .F.
			//Endif
			lAtuIECad	:= .F. 
					
					DEFINE MSDIALOG oDlgSA2 Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualizar Inscrição Estadual") FROM 001,001 TO 180,310 PIXEL
					// Ajustar casas decimais conforme SC7  				
					@ 05  ,4   SAY OemToAnsi("Insc.Estadual no XML") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
					@ 04  ,90  MSGET CONDORXML->XML_INSCRI PICTURE PesqPict('SA2','A2_INSCR') When .F. Of oDlgSA2 PIXEL SIZE 60,9
					@ 19  ,4   SAY OemToAnsi("Insc.Estadual Cadastro") Of oDlgSA2 PIXEL SIZE 80 ,9 //"Produto"
					@ 20  ,90  MSGET cInscricao PICTURE PesqPict('SA2','A2_INSCR') When .T. Of oDlgSA2 PIXEL SIZE 60,9
					
					@ 045,030 BUTTON "&Confirma" Size 35,10 Action(lAtuIECad := .T.,oDlgSA2:End())	Pixel Of oDlgSA2
					@ 045,070 Button "&Aborta" Size 35,10 Action (oDlgSA2:End())  Pixel Of oDlgSA2
		
					Activate MsDialog oDlgSA2 Centered
					
					If lAtuIECad
						If CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S"
							DbSelectArea("SA2")
							DbSetOrder(1)
							DbSeek(xFilial("SA2")+cCodForn+cLojForn)
							aFornec := {{"A2_COD"  	,cCodForn        	,Nil},; //
							{"A2_LOJA"  	  		,cLojForn        	,Nil},; //
							{"A2_INSCR"  	  		,cInscricao        	,Nil}} 	// 
							
							lMsHelpAuto := .T.
							lMsErroAuto := .F.
						
							Begin Transaction
								INCLUI	:= .F.
								ALTERA	:= .T.
								MSExecAuto({|x,y,z| mata020(x,y,z)},aFornec,4)//Alteração
						
							End Transaction
						
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Return .F.
							Endif
							
						Else
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(xFilial("SA1")+cCodForn+cLojForn)
							aFornec := {{"A1_COD"  	,cCodForn        	,Nil},; //
							{"A1_LOJA"  	  		,cLojForn        	,Nil},; //
							{"A1_INSCR"  	  		,cInscricao        	,Nil}} 	// 
							
							lMsHelpAuto := .T.
							lMsErroAuto := .F.
						
							Begin Transaction
								INCLUI	:= .F.
								ALTERA	:= .T.
								
								MSExecAuto({|x,y,z| mata030(x,y,z)},aFornec,4)//Alteração
						
							End Transaction
						
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Return .F.
							Endif
						Endif
						//Restauro valor das variáveis para execução da inclusão da nota fiscal
						lMsErroAuto		:=.F.
						lMsHelpAuto		:= lAutoExec
					Else
						Return .F. 
					Endif
		Else
			//If sfAtuXmlOk("IE")
			If sfAtuXmlOk("IE"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"XML_INSCRI"/*cInCpoAlt*/,cInscricao/*cInVlAnt*/,CONDORXML->XML_INSCRI/*cInVlNew*/)
				Return .F.
			Endif
		Endif
	Endif
	DbSelectArea("SA2")
	DbSetOrder(3)
	If Dbseek(xFilial("SA2")+Iif(Type("oRemetente:_CNPJ") <> "U" ,oRemetente:_CNPJ:TEXT,Iif(Type("oRemetente:_CPF") <>"U",oRemetente:_CPF:TEXT,"ZZ"))   )
		cF1Fornece		:= SA2->A2_COD
		cF1Loja			:= SA2->A2_LOJA
		cF1Est			:= SA2->A2_EST

		sfVldCliFor('SA2', @cF1Fornece, @cF1Loja ,SA2->A2_NOME,.F.,CONDORXML->XML_TIPODC)

		If ! lExclui
			// Avalia se por um acaso o fornecedor tam´bem seja como cliente
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+Iif(Type("oRemetente:_CNPJ") <> "U" ,oRemetente:_CNPJ:TEXT,Iif(Type("oRemetente:_CPF") <>"U",oRemetente:_CPF:TEXT,"ZZ")))
				If MsgYesNo("O CNPJ '"+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+"' existe como Cliente(Devolução de Vendas/Beneficicamento) e Fornecedor(Normal). Deseja Lançar como Frete Sobre Devolução ou Beneficiamento?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Escolha de Entidade!")
					cF1Fornece		:= SA1->A1_COD
					cF1Loja			:= SA1->A1_LOJA
					cF1Est			:= SA1->A1_EST
					sfVldCliFor('SA1', @cF1Fornece, @cF1Loja ,SA1->A1_NOME,.F.,CONDORXML->XML_TIPODC)
					cInscricao		:= SA1->A1_INSCR
					nTipoNf			:= 2
				Endif
			Endif
		Endif
	Else
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+Iif(Type("oRemetente:_CNPJ") <> "U" ,oRemetente:_CNPJ:TEXT,Iif(Type("oRemetente:_CPF") <>"U",oRemetente:_CPF:TEXT,"ZZ")))
			cF1Fornece		:= SA1->A1_COD
			cF1Loja			:= SA1->A1_LOJA
			cF1Est			:= SA1->A1_EST
			sfVldCliFor('SA1', @cF1Fornece, @cF1Loja ,SA1->A1_NOME ,.F.,CONDORXML->XML_TIPODC)
			nTipoNf		:= 2
		Endif
	Endif


	If Empty(cF1Fornece)
		MsgAlert("Remetente deste CTE não cadastrado como Fornecedor ou Cliente!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Fornecedor/Cliente sem cadastro")
		Return .F.
	Endif

	// Obtenho os nós com as notas fiscais do Frete
	oDet := Iif(Type("oRemetente:_infNf")<> "U",oRemetente:_infNf,IIf(Type("oRemetente:_infNfe") <> "U",oRemetente:_infNfe,{}))
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	// Melhoria feita em 25/05/2014 para atender CTe 2.00
	If Empty(oDet) .And. Type("oInfCte:_infDoc:_infNFe") <> "U"
		oDet	:= oInfCte:_infDoc:_infNFe
		oDet	:= IIf(ValType(oDet)=="O",{oDet},oDet)
	Endif

	// Melhoria feita em 03/06/2014 para atender CTe 2.00
	If Empty(oDet) .And. Type("oInfCte:_infDoc:_infNF") <> "U"
		oDet	:= oInfCte:_infDoc:_infNF
		oDet	:= IIf(ValType(oDet)=="O",{oDet},oDet)
	Endif

	// Percorro os nós e adiciono ao array a chave das notas no sistema
	For nForA := 1 To Len(oDet)
		iX := nForA
		If Type("oDet[ix]:_chave") <> "U"
			dbSelectArea("SF1")
			dbSetOrder(8)
			If DbSeek(xFilial("SF1")+oDet[ix]:_chave:TEXT)
				Aadd(aNfsCte,{!SF1->F1_STATUS $ " #B#C",;
				IIf(SF1->F1_STATUS $ " #B#C","Pré-nota ","")+SF1->F1_DOC+"/"+SF1->F1_SERIE + " "+ Alltrim(Transform(SF1->F1_VALBRUT,"@E 999,999,999.99")) + " " +DTOC(SF1->F1_EMISSAO) ,;
				SF1->F1_STATUS,;
				SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO})
				If SF1->F1_DTDIGIT < dDtCteIni
					dDtCteIni	:= SF1->F1_DTDIGIT
				Endif
				If SF1->F1_DTDIGIT > dDtCteFim
					dDtCteFim	:=	SF1->F1_DTDIGIT
				Endif
				// Ajusta variável conforme identificação da nota referenciada, para otimizar MATA116 
				cF1Fornece	:= SF1->F1_FORNECE
				cF1Loja		:= SF1->F1_LOJA
				
				// 21/04/2018 - Melhoria para forçar o ajuste do tipo de nota mesmo que usuário tenha selecionado uma opção errada
				If SF1->F1_TIPO $ "D#B"
					nTipoNf			:= 2
				Else
					nTipoNf			:= 1
				Endif
				
			Else
				dbSelectArea("SF1")
				dbSetOrder(2)
				DbSeek(xFilial("SF1")+cF1Fornece+cF1Loja)
				While !Eof() .And. SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA == xFilial("SF1")+cF1Fornece+cF1Loja
					If SF1->F1_CHVNFE == oDet[ix]:_chave:TEXT
						Aadd(aNfsCte,{!SF1->F1_STATUS $ " #B#C",;
						IIf(SF1->F1_STATUS $ " #B#C","Pré-nota ","")+SF1->F1_DOC+"/"+SF1->F1_SERIE + " "+ Alltrim(Transform(SF1->F1_VALBRUT,"@E 999,999,999.99")) + " " +DTOC(SF1->F1_EMISSAO),;
						SF1->F1_STATUS,;
						SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO })
						If SF1->F1_DTDIGIT < dDtCteIni
							dDtCteIni	:= SF1->F1_DTDIGIT
						Endif
						If SF1->F1_DTDIGIT > dDtCteFim
							dDtCteFim	:= SF1->F1_DTDIGIT
						Endif
						// 21/04/2018 - Melhoria para forçar o ajuste do tipo de nota mesmo que usuário tenha selecionado uma opção errada
						If SF1->F1_TIPO $ "D#B"
							nTipoNf			:= 2
						Else
							nTipoNf			:= 1
						Endif
						
					Endif
					DbSelectArea("SF1")
					DbSkip()
				Enddo
			Endif
		Endif
		If Type("oDet[ix]:_nDoc") <> "U"
			cQry := ""
			cQry += "SELECT F1.R_E_C_N_O_ F1RECNO "
			cQry += "  FROM " + RetSqlName("SF1") + " F1 "
			cQry += " WHERE F1.D_E_L_E_T_ = ' ' "
			If Type("oDet[ix]:_serie") <> "U"
				cQry += "   AND F1_SERIE LIKE '%" + oDet[ix]:_serie:TEXT + "%' "				
			Endif
			cQry += "   AND F1_DOC LIKE '%" + oDet[ix]:_nDoc:TEXT + "%'"
			cQry += "   AND F1_LOJA = '" + cF1Loja + "' "
			cQry += "   AND F1_FORNECE = '" + cF1Fornece +"' "
			cQry += "   AND F1_FILIAL = '" + xFilial("SF1")+ "'"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QXF1",.T.,.F.)

			While !Eof()

				dbSelectArea("SF1")
				DbGoto(QXF1->F1RECNO)

				Aadd(aNfsCte,{!SF1->F1_STATUS $ " #B#C",;
				IIf(SF1->F1_STATUS $ " #B#C","Pré-nota ","")+SF1->F1_DOC+"/"+SF1->F1_SERIE + " "+ Alltrim(Transform(SF1->F1_VALBRUT,"@E 999,999,999.99")) + " " + DTOC(SF1->F1_EMISSAO),;
				SF1->F1_STATUS,;
				SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO })
				If SF1->F1_DTDIGIT < dDtCteIni
					dDtCteIni	:= SF1->F1_DTDIGIT
				Endif
				If SF1->F1_DTDIGIT > dDtCteFim
					dDtCteFim	:= SF1->F1_DTDIGIT
				Endif
				// 21/04/2018 - Melhoria para forçar o ajuste do tipo de nota mesmo que usuário tenha selecionado uma opção errada
				If SF1->F1_TIPO $ "D#B"
					nTipoNf			:= 2
				Else
					nTipoNf			:= 1
				Endif
				
				DbSelectArea("QXF1")
				DbSkip()
			Enddo
			QXF1->(DbCloseArea())
		Endif
	Next nForA
	
	dbSelectArea("SF1")
	DbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inclusao                                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lExclui
		Aadd(aCabec,{"",dDtCteIni})       					//		1 Data Inicial
		Aadd(aCabec,{"",dDtCteFim})          				// 		2 Data Final
		Aadd(aCabec,{"",Iif(lExclui,1,2)})   				//		3 2-Inclusao;1=Exclusao
		Aadd(aCabec,{"",cF1Fornece})        				//		4 Fornecedor do documento de Origem
		Aadd(aCabec,{"",cF1Loja})			       			//		5 Loja de origem
		Aadd(aCabec,{"",nTipoNf})           	   			//		6 Tipo da nota de origem: 1=Normal;2=Devol/Benef
		Aadd(aCabec,{"",1})                  				//		7 1=Aglutina;2=Nao aglutina
		Aadd(aCabec,{"F1_EST",cF1Est}) 		 				// 		8 Estado
		// Ajuste efetuado em 15/03/2015 
		// Erro reportado pela CAAL pois o valor a ser considerado é o Valor a Receber se o valor da prestação for menor que o valor a receber
		If Type("oValorPrest:_vRec") <> "U" .And. Val(oValorPrest:_vTPrest:TEXT) < Val(oValorPrest:_vRec:TEXT)
			Aadd(aCabec,{"",Val(oValorPrest:_vRec:TEXT)}) //		9 Valor do conhecimento
		Else
			Aadd(aCabec,{"",Val(oValorPrest:_vTPrest:TEXT)}) //		9 Valor do conhecimento
		Endif
		Aadd(aCabec,{"F1_FORMUL",1})         				// 		10
		Aadd(aCabec,{"F1_DOC",cNumCte  }) 			       // 		11 Numero Documento

		DbSelectArea("SA2")
		DbSetOrder(1)
		Dbseek(xFilial("SA2")+cCodForn+cLojForn)
		// 28/01/2017 - Atribui o estado do Emitente do CTe para os casos de CTE sobre compras
		cF1Est			:= SA2->A2_EST
		
		Aadd(aCabec,{"F1_SERIE"	, cSerCte	})				// 		12 Serie
		Aadd(aCabec,{"F1_FORNECE",cCodForn}) 				// 		13 Fornecedor
		Aadd(aCabec,{"F1_LOJA",cLojForn})		  			// 		14 Loja
		If Len(oDet) > Len(aNfsCTe)
			MsgAlert("A quantidade de notas relacionadas no CTE que é de '"+AllTrim(Str(Len(oDet)))+"', é maior que a quantidade de notas localizadas que é de '"+Alltrim(Str(Len(aNfsCte)))+"'! Favor conferir antes de continuar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" A T E N Ç Ã O!!")
		Endif
		cCondPg	:= SA2->A2_COND
		
		// Valido a aliquota e valor do ICMS //pICMS
		If !sfVldAlqIcms('C',SA2->A2_CGC,oImposto,oIdent,@cF1Est)
		//If !sfVldAlqIcms('V',SA1->A1_CGC,oImposto,oIdent,@cUfOri,@cUfDes, !(!lCheck .And. !Empty(cCondicao) .And. !Empty(dDtVctoCte)))
			Return .F.
		Endif
		
		// Tenta retornar um TES inteligente para o Fornecedor neste tipo de operação
		cCodTes := MaTesInt(1/*nEntSai*/,cOper,cCodForn,cLojForn,If(CONDORXML->XML_TIPODC $ "N#C#I#P#T#F#S","F","C")/*cTipoCF*/,"")

		DEFINE MSDIALOG oDlgTes TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Dados para lançamento do CTE") FROM 001,001 TO 260,600 PIXEL
		@ 010,018 Say "Informe o TES " Pixel of oDlgTes
		@ 010,110 MsGet cCodTes Size 30,10 F3 "SF4" Valid (ExistCpo("SF4",cCodTes) .And. cCodTes < "500") Pixel of oDlgTes
		@ 022,018 Say "Condição Pagamento" Pixel of oDlgTes
		@ 022,110 MsGet cCondPg	Size 30,10 F3 "SE4" Valid (Vazio() .Or. ExistCpo("SE4",cCondPg)) Pixel of oDlgTes
		@ 035,018 Say "Deduções" Pixel of oDlgTes
		@ 035,110 MsGet nDeduz	Size 45,10 Picture "@E 999,999.99" Pixel of oDlgTes
		
		@ 035,165 Say "Aglutina Produtos ?" Pixel Of oDlgTes 
		@ 035,225 MSCOMBOBOX oCboAglut VAR cCboAglut ITEMS {"Sim","Não"} SIZE 30 ,50 OF oDlgTes PIXEL When (nCboAglut==1) VALID (nCboAglut:=aScan({"Sim","Não"},cCboAglut))
	
		@ 050,018 Say "UF Origem" Pixel of oDlgTes
		@ 049,110 MsGet cF1Est F3 "12" Valid ExistCpo("SX5","12"+cF1Est,1) Size 20,10 Pixel of oDlgTes
		
		If Len(aNfsCTe) > 0
			For iy := 1 To Len(aNfsCTe)

				cChvSF1	:= aNfsCTe[iy,4]
				DbSelectArea("SF8")
				DbSetOrder(2) // F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA
				DbSeek(cChvSF1)//	:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
				While !Eof() .And. SF8->F8_FILIAL+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA+SF8->F8_TIPO == cChvSF1
					If SF8->F8_NFDIFRE+SF8->F8_SEDIFRE <> cNumCte+cSerCte
						If !MsgYesNo("Foi encontrado outro lançamento de CTe/CTRC para a nota fiscal '"+cChvSF1+"' no Frete '"+SF8->F8_NFDIFRE+"-"+SF8->F8_SEDIFRE+"' "+Chr(13)+"Deseja continuar assim mesmo?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Nota fiscal em outro Frete!")
							Return
						Endif
					Endif
					DbSelectArea("SF8")
					DbSkip()
				Enddo
			Next

			@ 065,004 ListBox oNotas Fields Header " ","Notas fiscais vinculadas","Status","Chave" Size 295,45 PIXEL
			oNotas:SetArray(aNfsCTe)
			oNotas:bLine := {|| {	Iif(aNfsCTe[oNotas:nAt,1],oMarked,oNoMarked),;
			aNfsCTe[oNotas:nAt,2],;
			aNfsCTe[oNotas:nAt,3],;
			aNfsCTe[oNotas:nAt,4]} }
			oNotas:bLDblClick := {|| IIf(!aNfsCTe[oNotas:nAt,3]  $ " #B#C",aNfsCTe[oNotas:nAt,1] := !aNfsCTe[oNotas:nAt,1],Nil) }

			If Len(aNfsCTe) > 0
				// Ponto de entrada antes da gravação do frete sobre compras
				// Criado por solicitação Isolucks 27/05/2013
				If !lExclui
					If ExistBlock("XMLCTE01")
						// Caso haja validação que impeça que o lançamento seja continuado pelo ponto de entrada
						If !ExecBlock("XMLCTE01",.F.,.F.,{	Val(oValorPrest:_vTPrest:TEXT),;
						aItens,;
						Iif(Type("oEmitente:_CNPJ")<> "U",oEmitente:_CNPJ:TEXT,Iif(Type("oEmitente:_CPF") <> "U",oEmitente:_CPF:TEXT,""))})
							Return
						Endif
					Endif
				Endif

				@ 112,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgTes Action (lContinua	:= .T.,oDlgTes:End())
			Endif
		Endif
		@ 112,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgTes Action (oDlgTes:End())

		ACTIVATE MSDIALOG oDlgTes CENTERED

		If !lContinua
			Return .F.
		Endif

		
		For iy := 1 To Len(aNfsCTe)
			// Se a nota do frete estiver marcada e não for Prenota
			If aNfsCTe[iy,1] .And. !aNfsCTe[iy,3] $ " #B#C"
				Aadd(aItens,{{"PRIMARYKEY",aNfsCTe[iy,4]}})
			Endif
		Next
		// Atualiza a opção de Aglutinar produtos		7 1=Aglutina;2=Nao aglutina
		aCabec[7][2] 	:= nCboAglut                				
		
		// Atualiza UF de origem
		aCabec[8][2]	:= cF1Est 
		
		Aadd(aCabec,{"",cCodTes})  	            	//		15 Tes usada para lançar o CTE

		If Type("oImposto:_ICMS:_CST00") <> "U" 	//	<xs:documentation>Prestação sujeito à tributação normal do ICMS</xs:documentation>
			Aadd(aCabec,{"F1_BASERET",0})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",0})		  	// 	17
		ElseIf Type("oImposto:_ICMS:_CST60") <> "U"
			Aadd(aCabec,{"F1_BASERET",Val(oImposto:_ICMS:_CST60:_vBCSTRet:TEXT)})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",Val(oImposto:_ICMS:_CST60:_vICMSSTRet:TEXT)})		  	// 	17
		ElseIf Type("oImposto:_ICMS:_CST90") <> "U"
			Aadd(aCabec,{"F1_BASERET",Val(oImposto:_ICMS:_CST90:_vBCSTRet:TEXT)})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",Val(oImposto:_ICMS:_CST90:_pICMS:TEXT)})		  		// 	17
		Else
			Aadd(aCabec,{"F1_BASERET",0})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",0})		  	// 	17
		Endif

		Aadd(aCabec,{"F1_COND",cCondPg})		  	// 	18 Condicão pagamento



	Else
		// Monta array para listar notas 
		For iy := 1 To Len(aNfsCTe)
			// Se a nota do frete estiver marcada e não for Prenota
			If aNfsCTe[iy,1] .And. !aNfsCTe[iy,3] $ " #B#C"
				Aadd(aItens,{{"PRIMARYKEY",aNfsCTe[iy,4]}})
			Endif
		Next

		DbSelectArea("SF1")
		DbSetOrder(1)
		DbSeek(CONDORXML->XML_KEYF1)
		Aadd(aCabec,{"",dDataBase-90})       		//		1 Data Inicial
		Aadd(aCabec,{"",dDataBase})          		// 		2 Data Final
		Aadd(aCabec,{"",1	})						//		3 2-Inclusao;1=Exclusao
		Aadd(aCabec,{"",SF1->F1_FORNECE})     		//		4 Fornecedor do documento de Origem
		Aadd(aCabec,{"",SF1->F1_LOJA})       		//		5 Loja de origem
		Aadd(aCabec,{"",nTipoNf})              		//		6 Tipo da nota de origem: 1=Normal;2=Devol/Benef
		Aadd(aCabec,{"",1})                  		//		7 1=Aglutina;2=Nao aglutina
		Aadd(aCabec,{"F1_EST",SF1->F1_EST})  		// 		8 Estado
		Aadd(aCabec,{"",0})  						//		9 Valor do conhecimento
		Aadd(aCabec,{"F1_FORMUL",1})         		// 		10
		Aadd(aCabec,{"F1_DOC",SF1->F1_DOC  }) 		// 		11 Numero Documento

		Aadd(aCabec,{"F1_SERIE",SF1->F1_SERIE	})	// 		12 Serie

		// Adição do posicionamente da SF8 devida a mudança na versão 11 não aceitar a exclusão sem a informação do fornecedor correlacionado
		DbSelectArea("SF8")
		DbSetOrder(3)
		DbSeek(xFilial("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

		Aadd(aCabec,{"F1_FORNECE",SF8->F8_TRANSP}) // 		13 Fornecedor
		Aadd(aCabec,{"F1_LOJA"	 ,SF8->F8_LOJTRAN})	// 		14 Loja

		//	Aadd(aCabec,{"F1_FORNECE",""}) 			// 		13 Fornecedor
		//	Aadd(aCabec,{"F1_LOJA",""})				// 		14 Loja
		Aadd(aCabec,{"",""})	              		//		15 Tes usada para lançar o CTE

		If Type("oImposto:_ICMS:_CST60") <> "U"
			Aadd(aCabec,{"F1_BASERET",Val(oImposto:_ICMS:_CST60:_vBCSTRet:TEXT)})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",Val(oImposto:_ICMS:_CST60:_vICMSSTRet:TEXT)})		  	// 	17
		ElseIf Type("oImposto:_ICMS:_CST90") <> "U"
			Aadd(aCabec,{"F1_BASERET",Val(oImposto:_ICMS:_CST90:_vBCSTRet:TEXT)})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",Val(oImposto:_ICMS:_CST90:_pICMS:TEXT)})		  		// 	17
		Else
			Aadd(aCabec,{"F1_BASERET",0})        	// 	16
			Aadd(aCabec,{"F1_ICMRET",0})		  	// 	17
		Endif

		Aadd(aCabec,{"F1_COND",SF1->F1_COND})		// 	18 Condicão pagamento
	Endif

	Aadd(aCabec,{"F1_EMISSAO",STOD(AllTrim(StrTran(Substr(oIdent:_dhEmi:TEXT,1,10),"-","")))})		  	//    19 Data emissão CTE
	Aadd(aCabec,{"F1_ESPECIE",Padr("CTE",TamSX3("F1_ESPECIE")[1])})	  									// 	20 Especie CTE

	//Aadd(aCabec,{"E2_NATUREZ",""})        
	//Aadd(acabec,{"F1_DESPESA",10})        
	//Aadd(acabec,{"F1_DESCONTO",20})  



	If Len(aItens)>0

		If (lExclui .And. MsgYesNo("Deseja realmente "+Iif(lExclui,"excluir","incluir")+" o lançamento deste CTE?",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pergunta!")) .Or. !lExclui

			//<-Leonardo Perrella - 16/09/15 Deduzir do total do Ct-e para incluir valores de pedágio|
			aCabec[9][2] -= nDeduz

			MATA116(aCabec,aItens)

			Eval(bRefrPerg)

			If !lExclui
				// Adicionada melhoria que grava data e hora e usuario do lancamento do docuemnto de frete
				DbSelectArea("SF1")
				DbSetOrder(1)
				If DbSeek(xFilial("SF1")+aCabec[11,2]+aCabec[12,2]+aCabec[13,2]+aCabec[14,2])

					U_DbSelArea("CONDORXML",.F.,1)
					If DbSeek(SF1->F1_CHVNFE)
						RecLock("CONDORXML",.F.)
						CONDORXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
						CONDORXML->XML_LANCAD	:= SF1->F1_DTDIGIT
						CONDORXML->XML_HORLAN 	:= Time()
						CONDORXML->XML_USRLAN	:= Padr(cUserName,30)
						CONDORXML->XML_NUMNF	:= SF1->F1_SERIE+SF1->F1_DOC
						If CONDORXML->XML_TIPODC $ "N#D#B"
							CONDORXML->XML_TIPODC 		:= SF1->F1_TIPO
						Endif
						MsUnlock()
					Endif
				Endif
			Endif
		Endif
		If !lMsErroAuto
			ConOut("Incluido com sucesso! ")
		Else
			MostraErro()
		EndIf
	Else
		If !lExclui
			MsgAlert("Não há notas para vincular o Frete sobre Compras!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Faltam dados!")
		Else
			Return .F.
		Endif
	EndIf

	// Zero variavel de duplicatas
	aDupSE2		:= {}
	aDupAxSE2	:= {}
	lDupSE4		:= .F.
	nSumSE2		:= 0

Return .T.

/*/{Protheus.doc} sfMata120
(Gerar Pedido de compra a partir do MsnewGetDados)
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfMata120()

	Local		aAreaOld	:= GetArea()
	Local		cItemC7		:= StrZero(1,TamSX3("C7_ITEM")[1])
	Local		cNumC7XE
	Local		lContinua	:= 	.F.
	Local		cAviso		:= ""
	Local		cErro		:= ""
	Local		nValXml		:= 0
	Local		nI
	Local		nIX
	Local		aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
	Private 	oNfe
	Private		aCabec 		:= {}
	Private		aItens 		:= {}
	Private 	aLinha		:= {}
	Private 	cCondicao	:= "001"
	Private 	cNumDoc		:= ""
	Private 	cSerDoc		:= ""
	Private 	dData
	Private		lMsErroAuto		:= .F.
	Private		lMsHelpAuto		:= .F.


	// Efetua validação impedindo que produto não cadastrado tenha continuidade
	For nI := 1 To Len(oMulti:aCols)
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SB1")+oMulti:aCols[nI,nPxProd])
			MsgAlert("Não há Referência Protheus informada para a linha "+Str(nI),"Validação de dados antes do lançamento")
			RestArea(aAreaOld)
			Return
		Endif
	Next

	U_DbSelArea("CONDORXML",.F.,1)

	If !DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
		If !lAutoExec
			MsgAlert("Erro ao localizar registro",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
		RestArea(aAreaOld)
		Return
	Endif

	If !Empty(CONDORXML->XML_REJEIT)
		MsgAlert("Nota fiscal rejeitada em "+DTOC(CONDORXML->XML_REJEIT)+". Não é permitido lançar!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
		RestArea(aAreaOld)
		Return
	Endif

	// Se a nota não for do tipo Normal cancela rotina pois não há pedido de compra sobre outros tipos de notas
	If aArqXml[oArqXml:nAt,nPosTpNota] <> "N"
		RestArea(aAreaOld)
		Return
	Endif

	cAviso	:= ""
	cErro	:= ""
	oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)


	If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
		oNF	:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_NFe
	ElseIf Type("oNFe:_NfeProc")<> "U"
		oNF := oNFe:_NFeProc:_NFe
	ElseIf Type("oNFe:_NFe")<> "U"
		oNF := oNFe:_NFe
	Else
		cAviso	:= ""
		cErro	:= ""
		oNfe := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)
		If Type("oNFe:_NfeProc")<> "U"
			oNF := oNFe:_NFeProc:_NFe
		ElseIf Type("oNFe:_Nfe")<> "U"
			oNF := oNFe:_NFe
		Else
			MsgAlert("Erro ao ler xml "+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			RestArea(aAreaOld)
			Return
		Endif
	Endif

	If !Empty(cErro)
		MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		RestArea(aAreaOld)
		Return
	Endif

	oIdent     	:= oNF:_InfNfe:_IDE
	oEmitente  	:= oNF:_InfNfe:_Emit
	If Type("oNF:_InfNfe:_Dest") <> "U"
		oDestino   	:= oNF:_InfNfe:_Dest
	Endif
	oTotal		:= oNF:_InfNfe:_Total
	oTransp		:= oNF:_InfNfe:_Transp
	If Type("oNF:_InfNfe:_Cobr") <> "U"
		oCobr		:= oNF:_InfNfe:_Cobr
	Endif

	// Valido se esta empresa/filial certa conforme destinatário do XML
	If SM0->M0_CGC <> CONDORXML->XML_DEST
		MsgAlert("Empresa errada! Destinatário é diferente do CNPJ do XML("+IIf( Type("oNF:_InfNfe:_Dest") <> "U", oDestino:_CNPJ:TEXT,"")+").",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Destinatário errado!")
		RestArea(aAreaOld)
		Return
	Endif

	If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
		oNF := oNFe:_NFeProc:_NFe
		cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
	Else
		cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,nTmF1Ser) + Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
	Endif

	If CONDORXML->XML_TIPODC $ "N"
		// Novo procedimento que permite especificar qual Código e Loja
		If !Empty(CONDORXML->XML_CODLOJ)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
				cCodForn	:= SA2->A2_COD
				cLojForn	:= SA2->A2_LOJA
				If Alltrim(SA2->A2_CGC) <> Alltrim(CONDORXML->XML_EMIT) 
					DbSelectArea("SA2")
					DbSetOrder(3)
					DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
					cCodForn	:= SA2->A2_COD
					cLojForn	:= SA2->A2_LOJA
					sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek(xFilial("SA2")+cCodForn+cLojForn)
				Endif
			Endif
		Else
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
				cCodForn	:= SA2->A2_COD
				cLojForn	:= SA2->A2_LOJA
				sfVldCliFor('SA2', @cCodForn, @cLojForn ,SA2->A2_NOME,.T.,CONDORXML->XML_TIPODC)
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+cCodForn+cLojForn)
			Endif
		Endif

		cCondicao	:= SA2->A2_COND

	Endif

	// -- Valido se Nota Fiscal já existe na base ?
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(CONDORXML->XML_KEYF1)

		If CONDORXML->XML_TIPODC $ "N#C#P#I#T#F#S"
			MsgAlert("Nota No.: "+SF1->F1_SERIE+"/"+SF1->F1_DOC+" do Fornecedor "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Já Existe. A Importação será interrompida!")
		Else
			MsgAlert("Nota No.: "+SF1->F1_SERIE+"/"+SF1->F1_DOC+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Já Existe. A Importação será interrompida!")
		Endif
		RestArea(aAreaOld)
		Return
	EndIf


	If !Empty(CONDORXML->XML_CONFCO) .And. CONDORXML->XML_TIPODC == "N"
		MsgAlert("Nota fiscal já foi conferida pelo Compras.Não é permitido gerar pedido de compras!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Operação não permitida!")
		RestArea(aAreaOld)
		Return
	Endif


	// Novo modelo de tratativa da modelagem do número da Nota fiscal
	If cLeftNil $ " #0" 		// 0=Padrão(Soh Num c/zeros)
		cSerDoc	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
		cNumDoc	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
	ElseIf cLeftNil == "1" 	// 1=Num e Serie
		cSerDoc	:= Right(StrZero(0,(nTmF1Ser)-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,nTmF1Ser)
		cNumDoc	:= Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
	ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
		cSerDoc	:= Padr(oIdent:_serie:TEXT,nTmF1Ser)
		cNumDoc	:= Padr(oIdent:_nNF:TEXT,nTmF1Doc)
	Endif

	DEFINE MSDIALOG oDlgCond TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Continuar lançamento para geração de pedido de compra?") FROM 001,001 TO 170,400 PIXEL
	@ 010,018 Say "Informe a Condicao de Pagamento" Pixel of oDlgCond
	@ 010,110 MsGet cCondicao F3 "SE4" Valid ExistCpo("SE4",cCondicao) Size 30,10 Pixel of oDlgCond When (Empty(cCondicao))

	@ 035,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
	@ 035,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())

	ACTIVATE MSDIALOG oDlgCond CENTERED

	If !lContinua
		RestArea(aAreaOld)
		Return
	Endif


	dData	:=	CONDORXML->XML_EMISSA

	If CONDORXML->XML_TIPODC $ "N"

		aCabec := {}
		aItens := {}
			
		cNumC7XE	:= CriaVar('C7_NUM', .T.)
		
		While ChkChaveSC7(cNumC7XE)
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cNumC7XE := GetSxENum("SC7","C7_NUM")
		EndDo
		
		Aadd(aCabec,{"C7_NUM" 	  ,cNumC7XE			})
		Aadd(aCabec,{"C7_EMISSAO" ,dData				})
		Aadd(aCabec,{"C7_FORNECE" ,SA2->A2_COD			})
		Aadd(aCabec,{"C7_LOJA"    ,SA2->A2_LOJA		})
		Aadd(aCabec,{"C7_COND"    ,cCondicao			})
		Aadd(aCabec,{"C7_CONTATO" ,SA2->A2_CONTATO	})
		Aadd(aCabec,{"C7_FILENT"  ,cFilAnt				})
		Aadd(aCabec,{"C7_MOEDA"   ,1					})
		Aadd(aCabec,{"C7_TXMOEDA" ,1					})

		cModFrete := "C"

		If Type("oTransp:_ModFrete")<>"U"
			cTipFrete	:= IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
			If cTipFrete =="0"
				cModFrete := "C"
			ElseIf cTipFrete =="1"
				cModFrete := "F"
			ElseIf cTipFrete=="2"
				cModFrete := "T"
			ElseIf cTipFrete=="9"
				cModFrete := "S"
			Endif
		EndIf

		aadd(aCabec,{"C7_FRETE  " ,Iif(Type("oTotal:_ICMSTot:_vFrete") <> "U" ,Val(oTotal:_ICMSTot:_vFrete:TEXT),0)	})
		aadd(aCabec,{"C7_DESPESA" ,Iif(Type("oTotal:_ICMSTot:_vOutro") <> "U",Val(oTotal:_ICMSTot:_vOutro:TEXT),0)	})
		aadd(aCabec,{"C7_SEGURO " ,Iif(Type("oTotal:_ICMSTot:_vSeg")<> "U",Val(oTotal:_ICMSTot:_vSeg:TEXT),0)		})
		aadd(aCabec,{"C7_DESC1  " ,Iif(Type("oTotal:_ICMSTot:_vDesc") <> "U", Val(oTotal:_ICMSTot:_vDesc:TEXT),0)	})
		aadd(aCabec,{"C7_DESC2  " ,0					})
		aadd(aCabec,{"C7_DESC3  " ,0					})

		nValXml		+=  Iif(Type("oTotal:_ICMSTot:_vFrete") <> "U" ,Val(oTotal:_ICMSTot:_vFrete:TEXT),0)
		nValXml		+=  Iif(Type("oTotal:_ICMSTot:_vOutro") <> "U",Val(oTotal:_ICMSTot:_vOutro:TEXT),0)
		nValXml		+=  Iif(Type("oTotal:_ICMSTot:_vSeg")<> "U",Val(oTotal:_ICMSTot:_vSeg:TEXT),0)
		nValXml		+=  Iif(Type("oTotal:_ICMSTot:_vDesc") <> "U", Val(oTotal:_ICMSTot:_vDesc:TEXT),0)

		aadd(aCabec,{"C7_MSG"     ,""}) //PED.AUT.NF:"+cNumDoc+"/"+cSerDoc	})
		aadd(aCabec,{"C7_REAJUST" ,""									})
		Aadd(aCabec,{"C7_TPFRETE" ,RetTipoFrete(cModFrete) 	})
	Endif

	// Inicio loop nos itens da nota
	For nIX := 1 To Len(oMulti:aCols)

		If !oMulti:aCols[nIX,Len(oMulti:aHeader)+1]
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+oMulti:aCols[nIX,nPxProd])
			aLinha := {}

			aLinha := {}
			If 	lMVXPCNFE .And.;
			CONDORXML->XML_TIPODC == "N" .And.;
			!Alltrim(oMulti:aCols[nIX][nPxCFNFe])$ cCFOPNPED .And.;
			(IIf(!Empty(oMulti:aCols[nIX][nPxCF]),!Alltrim(oMulti:aCols[nIX][nPxCF]) $ cCFOPNPED,.T.)) .And.;
			(IIf(!Empty(oMulti:aCols[nIX][nPxD1Tes]),!Alltrim(oMulti:aCols[nIX][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
			Empty(oMulti:aCols[nIX,nPxPedido]) .And. Empty(oMulti:aCols[nIX,nPxItemPC])

				Aadd(aLinha,{"C7_ITEM"   	,cItemC7							,Nil})
				Aadd(aLinha,{"C7_PRODUTO"  	,oMulti:aCols[nIX,nPxProd]			,Nil})
				Aadd(aLinha,{"C7_QUANT"		,oMulti:aCols[nIX,nPxQte]			,Nil})
				Aadd(aLinha,{"C7_PRECO"		,oMulti:aCols[nIX,nPxPrunit]			,Nil})
				Aadd(aLinha,{"C7_VLDESC"	,oMulti:aCols[nIX,nPxValDesc]		,Nil})
				Aadd(aLinha,{"C7_TES"		,oMulti:aCols[nIX,nPxD1Tes]			,Nil})
				Aadd(aLinha,{"C7_BASEIPI"	,oMulti:aCols[nIX,nPxBasIpi]			,Nil})
				Aadd(aLinha,{"C7_IPI"		,oMulti:aCols[nIX,nPxPIpi]			,Nil})
				Aadd(aLinha,{"C7_VALIPI"	,oMulti:aCols[nIX,nPxValIpi]			,Nil})
				Aadd(aLinha,{"C7_LOCAL"		,oMulti:aCols[nIX,nPxLocal]			,Nil})
				aadd(aLinha,{"C7_OBS"      	,"PED.AUT.NF:"+cNumDoc+"/"+cSerDoc	,Nil})

				Aadd(aItens,aLinha)

				cItemC7	:= Soma1(cItemC7)

			Endif
			/*For nYY:=1 to 2
			xRateio:= {}
			aadd(xRateio,{"CH_ITEMPD"	,StrZero(nIX,len(SC7->C7_ITEM)),Nil})
			aadd(xRateio,{"CH_ITEM"		,StrZero(nYY,len(SCH->CH_ITEM)),Nil})
			aadd(xRateio,{"CH_PERC"		,IIF(nYY==1,30,70),Nil})
			aadd(xRateio,{"CH_CC"		,IIF(nYY==2,"1","2"),Nil})
			aadd(xRateio,{"CH_CONTA"	,'',Nil})
			aadd(xRateio,{"CH_ITEMCTA"	,'',Nil})
			aadd(xRateio,{"CH_CLVL"		,'',Nil})
			aadd(aRateio,xRateio)
			Next nYY
			*/
		Endif
	Next nIX
	// Ponto de entrada para customização do cliente desenvolver rotina própria para gerar pedido
	If ExistBlock("XMLCTE06")
		lRet := ExecBlock("XMLCTE06",.F.,.F.,{aCabec,aItens,oMulti:aCols})
		If Type("lRet") == "L" .And. lRet
			StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
			Eval(bRefrXmlF)
			Return
		Endif
	Endif

	If Len(aItens) > 0


		Mata120(1		,aCabec		,aItens		,3			,.T.,/*aRateio*/)
		//  Mata120(nFuncao	,xAutoCab	,xAutoItens	,nOpcAuto	,lWhenGet)
		//MSExecAuto({|v,x,y,z,a,b| MATA120(v,x,y,z,a,b)},1		,aCabec		,aItens		,3			,.T.)
		If lMsErroAuto
			MostraErro()
			StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
			Return
		Endif
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
			
		StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+cNumC7XE)
			MsgAlert("Pedido de Compra '"+SC7->C7_NUM +"' gerado no Sistema! "+(Iif((SuperGetMV("MV_RESTNFE") == "S" .And. SC7->C7_CONAPRO == "B") .Or. SC7->C7_TPOP == "P","Pedido bloqueado! Precisa ser liberado para poder vincular!","")),ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Geração de pedido de Compra!")

			// Se o pedido não estiver bloqueado já processa a vinculação automática e chama rotina de conferência do compras
			If ((SuperGetMV("MV_RESTNFE") == "S" .And. SC7->C7_CONAPRO == "B") .Or. SC7->C7_TPOP == "P")
			
			Else
				Eval(bRefrItAut)

				sfConferid()

				Eval(bRefrItem)
			Endif
		Endif


		//MSExecAuto({|v,x,y,z,a,b| MATA120(v,x,y,z,a,b)},1,aCabec,aItens,3,,/*aRateio*/)
	Else
		MsgAlert("Não houveram dados que permitissem a geração de um pedido de compras! Verifique se já vinculo com pedido de compra ou se há produtos válidos para Referência Protheus!",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Pedido não gerado!")
	Endif
Return




/*/{Protheus.doc} sfF4Poder3
(Retorna o poder de Terceiro de forma mais eficaz e automática)
@author MarceloLauschner
@since 15/08/2012
@version 1.0
@param cProduto, character, (Descrição do parâmetro)
@param cLocal, character, (Descrição do parâmetro)
@param cTpNF, character, (Descrição do parâmetro)
@param cES, character, (Descrição do parâmetro)
@param cCliFor, character, (Descrição do parâmetro)
@param cLoja, character, (Descrição do parâmetro)
@param nRegistro, numérico, (Descrição do parâmetro)
@param cEstoque, character, (Descrição do parâmetro)
@param cNumPV, character, (Descrição do parâmetro)
@param nLinha, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfF4Poder3(cProduto,cLocal,cTpNF,cES,cCliFor,cLoja,nRegistro,cEstoque,cNumPV,nLinha,lExibeNfOri)

	Local aArea     := GetArea()
	Local aOrdem    := {AllTrim(RetTitle("F2_DOC"))+"+"+AllTrim(RetTitle("F2_SERIE")),AllTrim(RetTitle("F2_EMISSAO"))}
	Local aChave    := {"B6_DOC+B6_SERIE","B6_EMISSAO","B6_IDENT"}
	Local aPesq     := {{Space(Len(SD1->D1_DOC+SD1->D1_SERIE)),"@!"},{Ctod(""),"@!"},{Space(Len(SB6->B6_IDENT)),"@!"}}
	Local aHeadTrb  := {}
	Local aStruTrb  := {}
	Local aTmSize   := MsAdvSize( .F. )
	Local aObjects  := {}
	Local aInfo     := {}
	Local aPosObj   := {}
	Local aNomInd   := {}
	Local aSavHead  := aClone(aHeader)
	Local aRegSB6   := {}
	Local cTpCliFor := IIf((cES=="E" .And. !cTpNF$"DB").Or.(cES=="S" .And. cTpNF$"DB"),"F","C")
	Local cAliasSD1 := "SD1"
	Local cAliasSD2 := "SD2"
	Local cAliasSB6 := "SB6"
	Local cAliasTrb := "F4PODER3"
	Local cCampo    := ""
	Local cNomeTrb  := ""
	Local cQuery    := ""
	Local cQuery1   := ""
	Local cQuery2   := ""
	Local cQuery3   := ""
	Local cCombo    := ""
	Local cTexto1   := ""
	Local cTexto2   := ""
	Local cReadVar  := ReadVar()
	Local nHandle   := GetFocus()
	Local nIX        := 0
	Local nSldQtd   := 0
	Local nSldBru   := 0
	Local nSldLiq   := 0
	Local nOpcA     := 0
	Local nPNfOri   := 0
	Local nPSerOri  := 0
	Local nPItemOri := 0
	Local nPLocal   := 0
	Local nPPrUnit  := 0
	Local nPPrcVen  := 0
	Local nPQuant   := 0
	Local nPQuant2UM:= 0
	Local nPLoteCtl := 0
	Local nPNumLote := 0
	Local nPDtValid := 0
	Local nPPotenc  := 0
	Local nPValor   := 0
	Local nPValDesc := 0
	Local nPValAcrs	:= 0
	Local nPDesc    := 0
	Local nPIdentB6 := 0
	Local nPItem    := 0
	Local nPUnit    := 0
	Local nPTES     := 0
	Local nPosLocal := 0
	Local nPAlmTerc := 0
	Local nPE		:= 0
	Local lQuery    := .F.
	Local lRetorno  := .F.
	Local lProcessa := .T.
	Local lCria     := .F.
	Local xPesq     := ""
	Local cSeekSD7  := ""
	Local oDlg
	Local oPanel
	Local oCombo
	Local oGet
	Local oGetDB
	Local cLocalCQ   := GETMV("MV_CQ")
	Local aArmazensCQ:= {},aTextoCQ:={}
	Local aNew       := {}
	Local aNF        := {}
	Local cNF        := ""
	Local aValNFR    := {}
	Local aValNFD    := {}
	Local aValNf     := {}
	Local nYY        := 0
	Local nXZ         := 0
	Local aA440VCOL  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MV_VLDDATA - Valida data de emissao do documento de beneficiamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lVldData   := SuperGetMv("MV_VLDDATA",.F.,.T.)

	DEFAULT 	cNumPV := ""
	Default	lExibeNfOri	:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do arquivo temporario dos itens do SD1                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	DbSeek("SB6")
	While !Eof() .And. SX3->X3_ARQUIVO == "SB6"
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
		(IsTriangular() .Or. Trim(SX3->X3_CAMPO) <> "B6_CLIFOR") .And.;
		(IsTriangular() .Or. Trim(SX3->X3_CAMPO) <> "B6_LOJA") .And.;
		Trim(SX3->X3_CAMPO) <> "B6_PRODUTO" .And.;
		Trim(SX3->X3_CAMPO) <> "B6_QUANT" .And.;
		SX3->X3_CONTEXT<>"V" .And.;
		SX3->X3_TIPO<>"M" ) .Or.;
		Trim(SX3->X3_CAMPO) == "B6_DOC" .Or.;
		Trim(SX3->X3_CAMPO) == "B6_SERIE"  .Or.;
		Trim(SX3->X3_CAMPO) == "B6_EMISSAO" .Or.;
		Trim(SX3->X3_CAMPO) == "B6_TIPO"
			Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT,;
			IIf(AllTrim(SX3->X3_CAMPO)$"B6_DOC#B6_SERIE#B6_IDENT","00",SX3->X3_ORDEM) })
			aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"B6_DOC#B6_SERIE","00",SX3->X3_ORDEM)})
			If Trim(SX3->X3_CAMPO) == "B6_PRUNIT"
				Aadd(aHeadTrb,{ OemToAnsi("Valor Liquido"),;
				"B6_PRCVEN",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				SX3->X3_ORDEM})
				aadd(aStruTRB,{"B6_PRCVEN",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_ORDEM})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia do campo B6_LOTECLT para criar indice de pesq.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Trim(SX3->X3_CAMPO)=="B6_LOTECTL"
				aadd(aChave,"B6_LOTECTL")
				aadd(aOrdem,AllTrim(RetTitle("B6_IDENT")))
				aadd(aOrdem,AllTrim(RetTitle("B6_LOTECTL")))
				aadd(aPesq,{Space(Len(SB6->B6_LOTECTL)),""})
			EndIf
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo


	aadd(aStruTRB,{"B6_TOTALL","N",18,2,"99"})
	aadd(aStruTRB,{"B6_TOTALB","N",18,2,"99"})
	aadd(aStruTRB,{"D2_NUMLOTE","C", 6,0,""})
	aadd(aStruTRB,{"D2_LOTECTL","C",10,0,""})
	aadd(aStruTRB,{"D1_NUMLOTE","C", 6,0,""})
	aadd(aStruTRB,{"D1_LOTECTL","C",10,0,""})
	aadd(aStruTrb,{"SD2RECNO" ,"N",18,0,"99"})
	aadd(aStruTrb,{"SD1RECNO" ,"N",18,0,"99"})
	aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
	aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste das casas decimais conforme a rotina                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cES == "S"
		dbSelectArea("SX3")
		dbSetOrder(2)
		DbSeek("D1_VUNIT")
		nIX := aScan(aHeadTrb,{|x| AllTrim(x[2]) == "B6_PRUNIT"})
		If nIX > 0
			aHeadTrb[nIX][3] := SX3->X3_PICTURE
			aHeadTrb[nIX][4] := 	SX3->X3_TAMANHO
			aHeadTrb[nIX][5] := 	SX3->X3_DECIMAL
		EndIf
		nIX := aScan(aHeadTrb,{|x| AllTrim(x[2]) == "B6_PRCVEN"})
		If nIX > 0
			aHeadTrb[nIX][3] := SX3->X3_PICTURE
			aHeadTrb[nIX][4] := 	SX3->X3_TAMANHO
			aHeadTrb[nIX][5] := 	SX3->X3_DECIMAL
		EndIf
		If Rastro(cProduto)
			If DbSeek("D1_LOTECTL")
				Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
				"D1_LOTECTL",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				"98" })
			EndIf
			If DbSeek("D1_NUMLOTE")
				Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
				"D1_NUMLOTE",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				"99" })
			EndIf
		EndIf
	Else
		dbSelectArea("SX3")
		dbSetOrder(2)
		DbSeek("D2_PRCVEN")
		nIX := aScan(aHeadTrb,{|x| AllTrim(x[2]) == "B6_PRUNIT"})
		If nIX > 0
			aHeadTrb[nIX][3] := SX3->X3_PICTURE
			aHeadTrb[nIX][4] := SX3->X3_TAMANHO
			aHeadTrb[nIX][5] := SX3->X3_DECIMAL
		EndIf
		nIX := aScan(aHeadTrb,{|x| AllTrim(x[2]) == "B6_PRCVEN"})
		If nIX > 0
			aHeadTrb[nIX][3] := SX3->X3_PICTURE
			aHeadTrb[nIX][4] := SX3->X3_TAMANHO
			aHeadTrb[nIX][5] := SX3->X3_DECIMAL
		EndIf
		If Rastro(cProduto)
			If DbSeek("D2_LOTECTL")
				Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
				"D2_LOTECTL",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				"98" })
			EndIf
			If DbSeek("D2_NUMLOTE")
				Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
				"D2_NUMLOTE",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT,;
				"99" })
			EndIf
		EndIf
	EndIf

	cNomeTrb := CriaTrab(aStruTRB,.T.)
	dbUseArea(.T.,__LocalDrive,cNomeTrb,cAliasTRB,.F.,.F.)
	dbSelectArea(cAliasTRB)
	For nIX := 1 To Len(aChave)
		aadd(aNomInd,SubStr(cNomeTrb,1,7)+chr(64+nIX))
		IndRegua(cAliasTRB,aNomInd[nIX],aChave[nIX])
	Next nIX
	dbClearIndex()
	For nIX := 1 To Len(aNomInd)
		dbSetIndex(aNomInd[nIX])
	Next nIX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificacao do aHeader atual                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cES == "S"
		nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
		nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
		nPItem    := GDFieldPos( "C6_ITEM" )
		nPUnit    := GDFieldPos( "C6_PRCVEN" )
		nPTES     := GDFieldPos( "C6_TES" )
	Else
		nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
		nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
		nPTES     := GDFieldPos( "D1_TES" )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao do arquivo temporario com base nos itens do SD1         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB6")
	dbSetOrder(2)
	#IFDEF TOP
	If TcSrvType()<>"AS/400" .And. TcSrvType()<>"iSeries" .And. !("POSTGRES" $ TCGetDB())
		lQuery    := .T.
		cAliasSB6 := "F4PODER3_SQL"
		cAliasSD1 := "F4PODER3_SQL"
		cAliasSD2 := "F4PODER3_SQL"

		If cES == "E"
			cQuery := "SELECT DISTINCT(0) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,0 D1_VUNIT,0 D1_TOTAL,0 D1_VALDESC,SD2.R_E_C_N_O_ SD2RECNO,D2_PRCVEN,D2_TOTAL,D2_DESCON, D2_NUMLOTE NUMLOTE,D2_LOTECTL LOTECTL,D2_TIPO,'' D1_TIPO, "
		Else
			cQuery := "SELECT DISTINCT(SD1.R_E_C_N_O_) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,D1_VUNIT,D1_TOTAL,D1_VALDESC,0 SD2RECNO,0 D2_PRCVEN,0 D2_TOTAL,0 D2_DESCON,D1_NUMLOTE NUMLOTE,D1_LOTECTL LOTECTL,'' D2_TIPO,D1_TIPO, "
		EndIf
		If SB6->(FieldPos("B6_IDENTB6"))==0
			cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_TPCF,B6_QUANT,B6_QULIB "
		Else
			cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB "
		EndIf
		For nIX := 1 To Len(aHeadTRB)
			If aHeadTRB[nIX][2]<>"B6_PRCVEN"    .AND.;
			aHeadTRB[nIX][2]<>"D2_NUMLOTE"  .AND.;
			aHeadTRB[nIX][2]<>"D2_LOTECTL"  .And.;
			aHeadTRB[nIX][2]<>"D2_TIPO"     .And.;
			aHeadTRB[nIX][2]<>"D1_NUMLOTE"  .AND.;
			aHeadTRB[nIX][2]<>"D1_LOTECTL"  .And.;
			aHeadTRB[nIX][2]<>"D1_TIPO"     .And.;
			aHeadTRB[nIX][2]<>"B6_CLIFOR"   .And.;
			aHeadTRB[nIX][2]<>"B6_LOJA"     .And.;
			aHeadTRB[nIX][2]<>"B6_PODER3"   .And.;
			aHeadTRB[nIX][2]<>"B6_QULIB"
				cQuery += ","+aHeadTRB[nIX][2]+" "
			EndIf
		Next nIX
		cQuery1:= " FROM "+RetSqlName("SB6")+" SB6 ,"
		If cES=="S"
			cQuery1 += RetSqlName("SD1")+" SD1 "
		Else
			cQuery1 += RetSqlName("SD2")+" SD2 "
		EndIf
		cQuery1 += "WHERE SB6.B6_FILIAL='"+xFilial("SB6")+"' AND "
		cQuery1 += "SB6.B6_PRODUTO    = '"+cProduto+"' AND "
		If !IsTriangular()
			cQuery1 += "SB6.B6_CLIFOR = '"+cCliFor+"' AND "
			cQuery1 += "SB6.B6_LOJA   = '"+cLoja+"' AND "
		EndIf
		cQuery1 += "SB6.B6_PODER3  = 'R' AND "
		cQuery1 += "SB6.B6_TPCF    = '"+cTpCliFor+"' AND "
		cQuery1 += "SB6.D_E_L_E_T_ = ' ' AND "
		If cES=="S"
			cQuery1 += "SB6.B6_TIPO   = 'D' AND "
			cQuery1 += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery1 += "SD1.D1_NUMSEQ = SB6.B6_IDENT AND "
			If lVldData
				cQuery1 += "SD1.D1_DTDIGIT <= '" + DTOS(dDataBase) + "' AND "
			EndIf
			cQuery1 += "SD1.D_E_L_E_T_=' ' "
		Else
			cQuery1 += "SB6.B6_TIPO    = 'E' AND "
			cQuery1 += "SD2.D2_FILIAL  = '"+xFilial("SD2")+"' AND "
			cQuery1 += "SD2.D2_NUMSEQ  = SB6.B6_IDENT AND "
			If lVldData
				cQuery1 += "SD2.D2_EMISSAO <= '" + DTOS(dDataBase) + "' AND "
			EndIf
			cQuery1 += "SD2.D_E_L_E_T_=' ' "
		EndIf
		cQuery1 += "  AND EXISTS (SELECT B6_FILIAL,"
		cQuery1 += "                     B6_PRODUTO,"
		cQuery1 += "                     B6_IDENT,   "
		cQuery1 += "                     B6_PRUNIT,   "
		cQuery1 += "                     SUM(CASE WHEN B6_PODER3 = 'R' THEN B6_QUANT ELSE 0 END) REMESSA,"
		cQuery1 += "                     SUM(CASE WHEN B6_PODER3 = 'D' THEN B6_QUANT ELSE 0 END) DEVOLVIDO,"
		cQuery1 += "                     SUM(CASE WHEN B6_PODER3 = 'D' THEN -1 * B6_QUANT ELSE B6_QUANT END) SALDO"
		cQuery1 += "                FROM "+RetSqlName("SB6") + " B6A, "+RetSqlName("SF4")+" SF4 "
		cQuery1 += "               WHERE B6A.B6_FILIAL = '"+xFilial("SB6")+"' "
		cQuery1 += "                 AND B6A.D_E_L_E_T_ = ' '"
		cQuery1 += "                 AND B6A.B6_ATEND != 'S' "
		If !IsTriangular()
			cQuery1 += "             AND B6A.B6_CLIFOR = '"+cCliFor+"' "
			cQuery1 += "             AND B6A.B6_LOJA   = '"+cLoja+"' "
		EndIf
		cQuery1 += "                 AND B6A.B6_PRODUTO    = '"+cProduto+"' "
		// Adicionada tratativa do parametro que filtra poder de terceiros por preço unitario ou não
		If GetNewPar("XM_POD3ALL",.T.)
			cQuery1 += "                 AND B6A.B6_PRUNIT = "+AllTrim(Str(oMulti:aCols[nLinha,nPxPrcNfe]))
		Endif
		cQuery1 += "                 AND B6A.B6_IDENT = SB6.B6_IDENT "
		cQuery1 += "                 AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
		cQuery1 += "                 AND SF4.F4_CODIGO = B6A.B6_TES "
		cQuery1 += "                 AND SF4.D_E_L_E_T_ = ' ' "
		cQuery1 += "               GROUP BY B6_FILIAL,B6_PRODUTO,B6_IDENT,B6_PRUNIT "
		cQuery1 += "              HAVING SUM(CASE WHEN B6_PODER3 = 'D' THEN -1 * B6_QUANT ELSE B6_QUANT END) > 0)"

		cQuery += cQuery1 + " UNION ALL "
		If cES == "E"
			cQuery += "SELECT DISTINCT(SD1.R_E_C_N_O_) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,D1_VUNIT,D1_TOTAL,D1_VALDESC,0 SD2RECNO,0 D2_PRCVEN,0 D2_TOTAL,0 D2_DESCON, D1_NUMLOTE NUMLOTE,D1_LOTECTL LOTECTL,'' D2_TIPO, D1_TIPO, "
		Else
			cQuery += "SELECT DISTINCT(0) SD1RECNO,SB6.R_E_C_N_O_ SB6RECNO,0 D1_VUNIT,0 D1_TOTAL,0 D1_VALDESC,SD2.R_E_C_N_O_ SD2RECNO,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_NUMLOTE NUMLOTE,D2_LOTECTL LOTECTL, D2_TIPO,'' D1_TIPO, "
		EndIf
		If SB6->(FieldPos("B6_IDENTB6"))==0
			cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_TPCF,B6_QUANT,B6_QULIB "
		Else
			cQuery += "B6_FILIAL,B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_PODER3,B6_IDENTB6,B6_TPCF,B6_QUANT,B6_QULIB "
		EndIf
		For nIX := 1 To Len(aHeadTRB)
			If aHeadTRB[nIX][2]<>"B6_PRCVEN"    .AND.;
			aHeadTRB[nIX][2]<>"D2_NUMLOTE"  .AND.;
			aHeadTRB[nIX][2]<>"D2_LOTECTL"  .And.;
			aHeadTRB[nIX][2]<>"D2_TIPO"     .And.;
			aHeadTRB[nIX][2]<>"D1_NUMLOTE"  .AND.;
			aHeadTRB[nIX][2]<>"D1_LOTECTL"  .And.;
			aHeadTRB[nIX][2]<>"D1_TIPO"     .And.;
			aHeadTRB[nIX][2]<>"B6_CLIFOR"   .And.;
			aHeadTRB[nIX][2]<>"B6_LOJA"     .And.;
			aHeadTRB[nIX][2]<>"B6_PODER3"   .And.;
			aHeadTRB[nIX][2]<>"B6_QULIB"

				cQuery += ","+aHeadTRB[nIX][2]+" "
			EndIf
		Next nIX
		cQuery2:= " FROM "+RetSqlName("SB6")+" SB6 ,"
		If cES=="S"
			cQuery2 += RetSqlName("SD2")+" SD2 "
		Else
			cQuery2 += RetSqlName("SD1")+" SD1 "
		EndIf
		cQuery2 += "WHERE SB6.B6_FILIAL = '"+xFilial("SB6")+"' AND "
		cQuery2 += "SB6.B6_PRODUTO	   = '"+cProduto+"' AND "
		cQuery2 += "SB6.B6_PODER3	   = 'D' AND "
		cQuery2 += "SB6.B6_TPCF         = '"+cTpCliFor+"' AND "
		cQuery2 += "SB6.D_E_L_E_T_	   = ' ' AND "

		If !IsTriangular()
			cQuery2 += "SB6.B6_CLIFOR='"+cCliFor+"' AND "
			cQuery2 += "SB6.B6_LOJA='"+cLoja+"' AND "
		EndIf

		If cES=="S"
			cQuery2 += "SB6.B6_TIPO    ='D' AND "
			cQuery2 += "SD2.D2_FILIAL  ='"+xFilial("SD2")+"' AND "
			cQuery2 += "SD2.D2_DOC	  = SB6.B6_DOC AND "
			cQuery2 += "SD2.D2_SERIE   = SB6.B6_SERIE AND "
			cQuery2 += "SD2.D2_CLIENTE = SB6.B6_CLIFOR AND "
			cQuery2 += "SD2.D2_LOJA    = SB6.B6_LOJA AND "
			cQuery2 += "SD2.D2_COD     = SB6.B6_PRODUTO AND "
			cQuery2 += "SD2.D2_IDENTB6 = SB6.B6_IDENT AND "
			cQuery2 += "SD2.D2_QUANT	  = SB6.B6_QUANT AND "
			If lVldData
				cQuery2 += "SD2.D2_EMISSAO <= '" + DTOS(dDataBase) + "' AND "
			EndIf
			cQuery2 += "SD2.D_E_L_E_T_=' ' "
		Else
			cQuery2 += "SB6.B6_TIPO     = 'E' AND "
			cQuery2 += "SD1.D1_FILIAL   = '"+xFilial("SD1")+"' AND "
			cQuery2 += "SD1.D1_DOC	   = SB6.B6_DOC    AND "
			cQuery2 += "SD1.D1_SERIE	   = SB6.B6_SERIE  AND "
			cQuery2 += "SD1.D1_FORNECE  = SB6.B6_CLIFOR AND "
			cQuery2 += "SD1.D1_LOJA     = SB6.B6_LOJA   AND "
			cQuery2 += "SD1.D1_COD	   = SB6.B6_PRODUTO AND "
			cQuery2 += "SD1.D1_IDENTB6  = SB6.B6_IDENT   AND "
			cQuery2 += "SD1.D1_QUANT    = SB6.B6_QUANT   AND "
			If lVldData
				cQuery2 += "SD1.D1_DTDIGIT <= '" + DTOS(dDataBase) + "' AND "
			EndIf
			cQuery2 += "SD1.D_E_L_E_T_=' ' "
		EndIf

		cQuery2 += "  AND EXISTS (SELECT B6_FILIAL,"
		cQuery2 += "                     B6_PRODUTO,"
		cQuery2 += "                     B6_IDENT,   "
		cQuery2 += "                     B6_PRUNIT,   "
		cQuery2 += "                     SUM(CASE WHEN B6_PODER3 = 'R' THEN B6_QUANT ELSE 0 END) REMESSA,"
		cQuery2 += "                     SUM(CASE WHEN B6_PODER3 = 'D' THEN B6_QUANT ELSE 0 END) DEVOLVIDO,"
		cQuery2 += "                     SUM(CASE WHEN B6_PODER3 = 'D' THEN -1 * B6_QUANT ELSE B6_QUANT END) SALDO"
		cQuery2 += "                FROM "+RetSqlName("SB6") + " B6A, "+RetSqlName("SF4")+" SF4 "
		cQuery2 += "               WHERE B6A.B6_FILIAL = '"+xFilial("SB6")+"' "
		cQuery2 += "                 AND B6A.D_E_L_E_T_ = ' '"
		cQuery2 += "                 AND B6A.B6_ATEND != 'S' "
		If !IsTriangular()
			cQuery2 += "             AND B6A.B6_CLIFOR = '"+cCliFor+"' "
			cQuery2 += "             AND B6A.B6_LOJA   = '"+cLoja+"' "
		EndIf
		cQuery2 += "                 AND B6A.B6_PRODUTO    = '"+cProduto+"' "
		// Adicionada tratativa do parametro que filtra poder de terceiros por preço unitario ou não
		If GetNewPar("XM_POD3ALL",.T.)
			cQuery2 += "                 AND B6A.B6_PRUNIT = "+AllTrim(Str(oMulti:aCols[nLinha,nPxPrcNfe]))
		Endif
		cQuery2 += "                 AND B6A.B6_IDENT = SB6.B6_IDENT "
		cQuery2 += "                 AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
		cQuery2 += "                 AND SF4.F4_CODIGO = B6A.B6_TES "
		cQuery2 += "                 AND SF4.D_E_L_E_T_ = ' ' "
		cQuery2 += "               GROUP BY B6_FILIAL,B6_PRODUTO,B6_IDENT,B6_PRUNIT "
		cQuery2 += "              HAVING SUM(CASE WHEN B6_PODER3 = 'D' THEN -1 * B6_QUANT ELSE B6_QUANT END) > 0) "

		cQuery := cQuery + cQuery2
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.F.)

		For nIX := 1 To Len(aStruTRB)
			If aStruTRB[nIX][2] <> "C" .And. FieldPos(aStruTRB[nIX][1])<>0
				TcSetField(cAliasSB6,aStruTRB[nIX][1],aStruTRB[nIX][2],aStruTRB[nIX][3],aStruTRB[nIX][4])
			EndIf
		Next nIX

		TcSetField(cAliasSD1,"D1_TOTAL","N",TamSx3("D1_TOTAL")[1], TamSx3("D1_TOTAL")[2] )
		TcSetField(cAliasSD1,"D1_VALDESC","N",TamSx3("D1_VALDESC")[1], TamSx3("D1_TOTAL")[2] )
		TcSetField(cAliasSD1,"D2_TOTAL","N",TamSx3("D2_TOTAL")[1], TamSx3("D2_TOTAL")[2] )
		TcSetField(cAliasSD1,"D2_DESCON","N",TamSx3("D2_DESCON")[1], TamSx3("D2_DESCON")[2] )
		TcSetField(cAliasSD1,"SD1RECNO","N",12, 0 )
		TcSetField(cAliasSD1,"SD2RECNO","N",12, 0 )
	Else
		#ENDIF
		If IsTriangular()
			DbSeek(xFilial("SB6")+cProduto)
		Else
			DbSeek(xFilial("SB6")+cProduto+cCliFor+cLoja,.F.)
		EndIf
		#IFDEF TOP
	EndIf
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	 Esta rotina, verifica se existem Produtos com Códigos e Quantidades iguais na Nota      |
	//| para definir se irá gerar uma nova tabela através da montagem de um Array para          |
	//| obter os precos reais de movimentação na SD1                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		If cES=="E"
			cQuery3:="SELECT DISTINCT(SD1.R_E_C_N_O_),COUNT(*) REGISTROS "+cQuery2+" GROUP BY SD1.R_E_C_N_O_ HAVING COUNT(*)>1"
			cQuery3 := ChangeQuery(cQuery3)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery3),"REGISTROS",.T.,.F.)
			dbSelectArea("REGISTROS")
			If !EOF()
				lCria:=.T.
			EndIf
			dbCloseArea()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Esta rotina, ira gerar um Array com a mesma Estrutura da Query e buscar os registros    |
	//| com os valores de movimentações reais. Isto é necessário, pois em situações onde existe |
	//| o mesmo código do produto com quantidades iguais, porém com valores diferentes, a função|
	//| apontava o 1a registro encontrado gerando divergências de valores entre as funcoes      |
	//| F4PODER3 x CALCTERC 																	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery .And. lCria
		dbSelectArea(cAliasSB6)
		dbGotop()
		While !Eof()
			If (cAliasSB6)->B6_PODER3 == "D"
				dbSelectArea("SD1")
				dbSetOrder(1)
				DbSeek(xFilial("SD1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO)
				While !Eof() .And. ;
				(cAliasSB6)->B6_FILIAL    == SD1->D1_FILIAL  .And.;
				(cAliasSB6)->B6_DOC       == SD1->D1_DOC     .And.;
				(cAliasSB6)->B6_SERIE     == SD1->D1_SERIE   .And.;
				(cAliasSB6)->B6_CLIFOR    == SD1->D1_FORNECE .And.;
				(cAliasSB6)->B6_LOJA      == SD1->D1_LOJA    .And.;
				(cAliasSB6)->B6_PRODUTO   == SD1->D1_COD

					cNF:= SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM
					If (cAliasSB6)->B6_IDENT==SD1->D1_IDENTB6
						If Ascan(aNF,cNF) = 0 .And. Ascan(aValNFD,{|x| x[1] = (cAliasSB6)->SD1RECNO}) = 0 .And. Ascan(aValNFD,{|x| x[2] = (cAliasSB6)->SB6RECNO}) = 0
							aadd(aNF,cNF)
							dbSelectArea(cAliasSB6)
							aadd(aValNFD,Array(FCount()))
							For nXZ:=1 To Fcount()
								If FieldName(nXZ)$"SD2RECNO$D2_PRCVEN$D2_TOTAL$D2_DESCON"
									aValNFD[Len(aValNFD),nXZ]:=0
								Else
									aValNFD[Len(aValNFD),nXZ]:=&(FieldName(nXZ))
								EndIf
							Next nXZ
							dbSelectArea("SD1")
							Exit
						EndIf
					EndIf
					SD1->(dbSkip())
				EndDo
			Else
				dbSelectArea(cAliasSB6)
				aadd(aValNFR,Array(FCount()))
				For nXZ:=1 To Fcount()
					If FieldName(nXZ)$"D1_VUNIT$D1_TOTAL$D1_VALDESC"
						aValNFR[Len(aValNFR),nXZ]:=0
					Else
						aValNFR[Len(aValNFR),nXZ]:=&(FieldName(nXZ))
					EndIf
				Next nXZ
			EndIf
			dbSelectArea(cAliasSB6)
			dbSkip()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Cria arquivo de trabalho com os dados obtidos através do array que foi gerado  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStruSB6 := (cAliasSB6)->(dbStruct())
		DbSelectArea("SX3")
		DbSetOrder(2)

		For nIX = 1 To Len(aStruSB6)
			cCampo:=aStruSB6[nIX][1]
			nYY:=aScan(aStruTrb,{|x| AllTrim(x[1])==cCampo})
			If nYY>0
				aStruSB6[nIX][3]:=aStruTrb[nYY][3]
				aStruSB6[nIX][4]:=aStruTrb[nYY][4]
			Else
				If Rat("RECNO",cCampo)>0
					aStruSB6[nIX][3]:=18
					aStruSB6[nIX][4]:=0
				Else
					DbSeek(cCampo)
					If !Eof()
						aStruSB6[nIX][3]:=X3_TAMANHO
						aStruSB6[nIX][4]:=X3_DECIMAL
					EndIf
				EndIf
			EndIf
		Next nIX

		dbSelectArea(cAliasSB6)
		dbCloseArea()

		cNomeSb6 := CriaTrab(aStruSB6,.T.)
		dbUseArea(.T.,__LocalDrive,cNomeSb6,cAliasSB6,.F.,.F.)
		dbSelectArea(cAliasSB6)
		For nIX = 1 to 2
			aValNF:={}
			aValNF:=iif(nIX==1, aValNFR, aValNFD)
			For nYY :=1 To Len(aValNF)
				RecLock(cAliasSB6,.T.)
				For nXZ := 1 TO FCount()
					FieldPut(nXZ, aValNF[nYY,nXZ])
				Next nXZ
				MsUnlock()
			Next nYY
		Next nIX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inicia Processo de Calculo  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		dbSelectArea(cAliasSB6)
		dbGotop()
	EndIf
	While !Eof() .And. (cAliasSB6)->B6_FILIAL = xFilial("SB6") .And.;
	(cAliasSB6)->B6_PRODUTO == cProduto .And.;
	IIF(IsTriangular(),.T.,IIf(lQuery,.T.,(cAliasSB6)->B6_CLIFOR == cCliFor .And.;
	(cAliasSB6)->B6_LOJA == cLoja ))

		lProcessa	:= .T.

		If lProcessa

			If !lQuery
				lProcessa := aScan(aRegSB6,SB6->(RecNo()))==0
			Else
				lProcessa := aScan(aRegSB6,(cAliasSB6)->SB6RECNO)==0
			EndIf

		EndIf

		If lProcessa

			If ((cES == "E" .And. (cAliasSB6)->B6_TIPO == "E") .Or. (cES == "S" .And. (cAliasSB6)->B6_TIPO == "D") ) .And.;
			(cAliasSB6)->B6_TPCF==cTpCliFor
				If !lQuery
					aadd(aRegSB6,SB6->(RecNo()))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verificar qual eh a tabela de origem do poder de terceiros          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
						If (cAliasSB6)->B6_PODER3 == "R"
							dbSelectArea("SD1")
							dbSetOrder(4)
							DbSeek(xFilial("SD1")+(cAliasSB6)->B6_IDENT)
						Else
							dbSelectArea("SD1")
							dbSetOrder(1)
							DbSeek(xFilial("SD1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO)
							While !Eof() .And. xFilial("SD1") == SD1->D1_FILIAL .And.;
							(cAliasSB6)->B6_DOC       == SD1->D1_DOC .And.;
							(cAliasSB6)->B6_SERIE     == SD1->D1_SERIE .And.;
							(cAliasSB6)->B6_CLIFOR    == SD1->D1_FORNECE .And.;
							(cAliasSB6)->B6_LOJA      == SD1->D1_LOJA .And.;
							(cAliasSB6)->B6_PRODUTO   == SD1->D1_COD

								If (cAliasSB6)->B6_IDENT==SD1->D1_IDENTB6 .And. (cAliasSB6)->B6_QUANT=SD1->D1_QUANT
									Exit
								EndIf

								dbSelectArea("SD1")
								dbSkip()
							EndDo
						EndIf
					Else
						If (cAliasSB6)->B6_PODER3=="R"
							dbSelectArea("SD2")
							dbSetOrder(4)
							DbSeek(xFilial("SD2")+(cAliasSB6)->B6_IDENT)
						Else
							dbSelectArea("SD2")
							dbSetOrder(3)
							DbSeek(xFilial("SD2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO)
							While !Eof() .And. xFilial("SD2") == SD2->D2_FILIAL .And.;
							(cAliasSB6)->B6_DOC == SD2->D2_DOC .And.;
							(cAliasSB6)->B6_SERIE == SD2->D2_SERIE .And.;
							(cAliasSB6)->B6_CLIFOR == SD2->D2_CLIENTE .And.;
							(cAliasSB6)->B6_LOJA == SD2->D2_LOJA .And.;
							(cAliasSB6)->B6_PRODUTO == SD2->D2_COD
								If (cAliasSB6)->B6_IDENT==SD2->D2_IDENTB6 .And. (cAliasSB6)->B6_QUANT=SD2->D2_QUANT
									Exit
								EndIf
								dbSelectArea("SD2")
								dbSkip()
							EndDo
						EndIf
					EndIf
				Else
					aadd(aRegSB6,(cAliasSB6)->SB6RECNO)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculo do saldo em valor e quantidade para devolucao de terceiros  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSldQtd := 0
				nSldBru := 0
				nSldLiq := 0
				If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
					lProcessa := lProcessa .And. (cAliasSD1)->D1_TIPO<>"I"
				Else
					lProcessa := lProcessa .And. (cAliasSD2)->D2_TIPO<>"I"
				EndIf
				If lProcessa
					If (cAliasSB6)->B6_PODER3 == "R" .And. (SB6->(FieldPos("B6_IDENTB6"))==0 .Or. Empty((cAliasSB6)->B6_IDENTB6))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Na primeira remessa deve-se tirar os valores contidos na interface  ³
						//³ para evitar baixa de saldo maior que o disponivel                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cES == "E"
							For nIX := 1 To Len(aCols)
								If nIX <> N .And. !aCols[nIX][Len(aHeader)+1] .And. aCols[nIX][nPIdentB6]==(cAliasSB6)->B6_IDENT
									nSldQtd -= aCols[nIX][nPQuant]
									nSldBru -= aCols[nIX][nPValor]
								EndIf
							Next nIX
						Else
							For nIX := 1 To Len(aCols)
								If nIX <> N .And. !aCols[nIX][Len(aHeader)+1] .And. aCols[nIX][nPIdentB6]==(cAliasSB6)->B6_IDENT
									nSldQtd -= aCols[nIX][nPQuant]
									nSldLiq -= aCols[nIX][nPValor]

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Desconsidera a quantidade ja faturada                               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !Empty( cNumPV )
										SC6->( dbSetOrder( 1 ) )
										If SC6->( DbSeek( xFilial( "SC6" ) + cNumPv + aCols[nIX, nPItem ] ) )
											nSldQtd += SC6->C6_QTDENT
											nSldLiq += aCols[nIX,nPUnit] * SC6->C6_QTDENT
											nSldLiq := A410Arred( nSldLiq, "C6_VALOR" )
										EndIf
									EndIf

								EndIf
							Next nIX
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calculo do saldo do poder de terceiros                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nSldQtd  += (cAliasSB6)->B6_QUANT-(cAliasSB6)->B6_QULIB
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calculo do saldo do poder de terceiros                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nSldQtd  -= (cAliasSB6)->B6_QUANT-(cAliasSB6)->B6_QULIB
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verificar qual eh a tabela de origem do poder de terceiros e calcula³
					//³ o valor total do saldo de poder de/em terceiros                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ((cAliasSB6)->B6_TIPO=="D" .And. (cAliasSB6)->B6_PODER3 == "R" ) .Or. ((cAliasSB6)->B6_TIPO=="E" .And. (cAliasSB6)->B6_PODER3 == "D")
						If (cAliasSB6)->B6_PODER3 == "R"
							nSldLiq += (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
							nSldBru += nSldLiq+A410Arred(nSldLiq*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")
						Else
							nSldLiq -= (cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC
							nSldBru -= Abs(nSldLiq)+A410Arred(Abs(nSldLiq)*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")
						EndIf
					Else
						If (cAliasSB6)->B6_PODER3 == "R"
							nSldBru += (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
							nSldLiq += nSldBru-A410Arred(nSldBru*(cAliasSD2)->D2_DESCON/((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON),"C6_VALOR")
						Else
							nSldBru -= (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON
							nSldLiq -= Abs(nSldBru)-A410Arred(Abs(nSldBru)*(cAliasSD2)->D2_DESCON/((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON),"C6_VALOR")
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o arquivo temporario com os dados do poder de terceiro     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasTRB)
					dbSetOrder(3)
					If nSldQtd <> 0 .Or. nSldLiq <> 0
						If (cAliasSB6)->(FieldPos("B6_IDENTB6"))<>0 .And. !Empty((cAliasSB6)->B6_IDENTB6)
							(cAliasTRB)->(DbSeek((cAliasSB6)->B6_IDENTB6))
						Else
							(cAliasTRB)->(DbSeek((cAliasSB6)->B6_IDENT))
						EndIf
						If (cAliasTRB)->(!Found())
							RecLock(cAliasTRB,.T.)
							For nIX := 1 To Len(aStruTRB)
								If !AllTrim(aStruTRB[nIX][1])$"B6_SALDO#B6_TOTALL#B6_TOTALB#B6_QULIB"
									If (cAliasSB6)->(FieldPos(aStruTRB[nIX][1]))<>0 .And. (cAliasTrb)->(FieldPos(aStruTRB[nIX][1]))<>0
										(cAliasTRB)->(FieldPut(nIX,(cAliasSB6)->(FieldGet(FieldPos(aStruTRB[nIX][1])))))
									EndIf
								EndIf
							Next nIX
						Else
							RecLock(cAliasTRB)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o documento original para obter alguns dados posteriores   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSB6)->B6_PODER3 == "R" .And. (SB6->(FieldPos("B6_IDENTB6"))==0 .Or. Empty((cAliasSB6)->B6_IDENTB6))
							For nIX := 1 To Len(aStruTRB)
								If !AllTrim(aStruTRB[nIX][1])$"B6_SALDO#B6_TOTALL#B6_TOTALB#B6_QULIB"
									If (cAliasSB6)->(FieldPos(aStruTRB[nIX][1]))<>0 .And. (cAliasTrb)->(FieldPos(aStruTRB[nIX][1]))<>0
										(cAliasTRB)->(FieldPut(nIX,(cAliasSB6)->(FieldGet(FieldPos(aStruTRB[nIX][1])))))
									EndIf
								EndIf
							Next nIX
							If (cAliasSB6)->B6_TIPO=="D"
								(cAliasTRB)->SD1RECNO := IIf(lQuery,(cAliasSD1)->SD1RECNO,SD1->(RecNo()))
							Else
								(cAliasTRB)->SD2RECNO := IIf(lQuery,(cAliasSD2)->SD2RECNO,SD2->(RecNo()))
							EndIf
						EndIf
						(cAliasTRB)->B6_SALDO += a410Arred(nSldQtd,"C6_QTDVEN")
						(cAliasTRB)->B6_QULIB += a410Arred((cAliasSB6)->B6_QULIB,"C6_QTDVEN")
						(cAliasTRB)->B6_TOTALL+= nSldLiq
						(cAliasTRB)->B6_TOTALB+= nSldBru

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o valor unitario do poder de terceiros                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						(cAliasTRB)->B6_PRCVEN:= a410Arred((cAliasTRB)->B6_TOTALL/((cAliasTRB)->B6_SALDO+(cAliasTRB)->B6_QULIB),"D2_PRCVEN")

						(cAliasTRB)->B6_PRUNIT:= a410Arred((cAliasTRB)->B6_TOTALB/((cAliasTRB)->B6_SALDO+(cAliasTRB)->B6_QULIB),"D2_PRCVEN")
						If cES == "E"
							If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-(cAliasSD2)->D2_PRCVEN)<=.01
								(cAliasTRB)->B6_PRUNIT := A410Arred((cAliasSD2)->D2_PRCVEN,"C6_PRCVEN")
								(cAliasTRB)->B6_PRCVEN := A410Arred((cAliasSD2)->D2_PRCVEN,"C6_PRCVEN")
							EndIf
							(cAliasTRB)->D2_LOTECTL:= IIf(lQuery,(cAliasSD2)->LOTECTL,(cAliasSD2)->D2_LOTECTL)
							(cAliasTRB)->D2_NUMLOTE:= IIf(lQuery,(cAliasSD2)->NUMLOTE,(cAliasSD2)->D2_NUMLOTE)
						Else
							If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-(cAliasSD1)->D1_VUNIT)<=.01
								(cAliasTRB)->B6_PRUNIT := A410Arred((cAliasSD1)->D1_VUNIT,"C6_PRCVEN")
								(cAliasTRB)->B6_PRCVEN := A410Arred((cAliasSD1)->D1_VUNIT,"C6_PRCVEN")
							EndIf

							(cAliasTRB)->D1_LOTECTL:= IIf(lQuery,(cAliasSD1)->LOTECTL,(cAliasSD1)->D1_LOTECTL)
							(cAliasTRB)->D1_NUMLOTE:= IIf(lQuery,(cAliasSD1)->NUMLOTE,(cAliasSD1)->D1_NUMLOTE)
						EndIf

						MsUnLock()
					EndIf
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasSB6)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSB6)
		dbCloseArea()
		If Type("cNomeSb6") <> "U"
			FErase(cNomeSb6 + GetDbExtension()) // Deleting file
			FErase(cNomeSb6+ OrdBagExt()) // Deleting index
		Endif
		dbSelectArea("SB6")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira os documentos totalmente devolvidos                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	dbClearIndex()
	dbGotop()
	While !Eof()
		If (cAliasTRB)->B6_SALDO<oMulti:aCols[nLinha,nPxQteNfe] .Or. Round((cAliasTRB)->B6_PRCVEN,TamSX3("D1_VUNIT")[2]) > Round(oMulti:aCols[nLinha,nPxPrcNfe],TamSX3("D1_VUNIT")[2])
			dbDelete()
		EndIf
		dbSkip()
	EndDo
	Pack
	aNomInd := {}
	For nIX := 1 To Len(aChave)
		aadd(aNomInd,SubStr(cNomeTrb,1,7)+chr(64+nIX))
		IndRegua(cAliasTRB,aNomInd[nIX],aChave[nIX])
	Next nIX
	dbClearIndex()
	For nIX := 1 To Len(aNomInd)
		dbSetIndex(aNomInd[nIX])
	Next nIX
	dbSetOrder(1)
	dbGotop()
	PRIVATE aHeader := aHeadTRB
	xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona registros                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpCliFor == "C"
		dbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+cCliFor+cLoja)
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		DbSeek(xFilial("SA2")+cCliFor+cLoja)
	EndIf
	dbSelectArea("SB1")
	dbSetOrder(1)
	DbSeek(xFilial("SB1")+cProduto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as coordenadas da interface                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTmSize[1] /= 1.5
	aTmSize[2] /= 1.5
	aTmSize[3] /= 1.5
	aTmSize[4] /= 1.3
	aTmSize[5] /= 1.5
	aTmSize[6] /= 1.3
	aTmSize[7] /= 1.5

	AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
	AAdd( aObjects, { 100, 060,.T.,.T.} )
	AAdd( aObjects, { 100, 020,.T.,.F.} )
	aInfo   := { aTmSize[ 1 ], aTmSize[ 2 ], aTmSize[ 3 ], aTmSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Interface com o usuario                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cAliasTRB)->(Eof())
		If lExibeNfOri

			DEFINE MSDIALOG oDlg TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Documentos de Origem Customizado") FROM aTmSize[7],000 TO aTmSize[6],aTmSize[5] OF oMainWnd PIXEL //"Documentos de Origem"
			@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
			If !IsTriangular()
				If cTpCliFor == "C"
					cTexto1 := AllTrim(RetTitle("F2_CLIENTE"))+"/"+AllTrim(RetTitle("F2_LOJA"))+": "+SA1->A1_COD+"/"+SA1->A1_LOJA+"  -  "+RetTitle("A1_NOME")+": "+SA1->A1_NOME
				Else
					cTexto1 := AllTrim(RetTitle("F1_FORNECE"))+"/"+AllTrim(RetTitle("F1_LOJA"))+": "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME
				EndIf
			Else
				cTexto1 := "Operacao Triangular"
			EndIf

			@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
			cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
			@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL
			oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB,,,,,,.T.)

			DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg

			@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi("Pesquisar por:") PIXEL
			@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi("Localizar") PIXEL
			@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
			VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
			@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
			VALID ((cAliasTRB)->(DbSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)
			ACTIVATE MSDIALOG oDlg CENTERED

		Else
			nOpcA	:= 1
		Endif
	Else
		If !lAutoExec
			Help(" ",1,"F4NAONOTA")
		Endif
		lRetorno := .F.
	EndIf

	If nOpcA == 1
		lRetorno := .T.
		aHeader   := aClone(aSavHead)
		If cES == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os campos a serem atualizados                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
			nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_UNSVEN"})
			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DTVALID"})
			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_POTENCI"})
			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
			nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
			nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona registros                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD1->(MsGoto((cAliasTRB)->SD1RECNO))
			SF4->(dbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+aCols[n][nPTES]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche acols                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPIdentB6 <> 0
				aCols[N][nPIdentB6] := (cAliasTRB)->B6_IDENT
			EndIf
			If nPNfOri <> 0
				aCols[N][nPNfOri] := SD1->D1_DOC
			EndIf
			If nPSerOri <> 0
				aCols[N][nPSerOri] := SD1->D1_SERIE
			EndIf
			If nPItemOri <> 0
				aCols[N][nPItemOri] := SD1->D1_ITEM
			EndIf
			If nPPrUnit <> 0
				If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-SD1->D1_VUNIT)<=.01
					aCols[N][nPPrUnit] := 0
				Else
					aCols[N][nPPrUnit] := A410Arred((cAliasTRB)->B6_PRUNIT,"C6_PRUNIT")
				EndIf
			EndIf
			If nPPrcVen <> 0
				If (cAliasTRB)->B6_PRUNIT == (cAliasTRB)->B6_PRCVEN .And. Abs((cAliasTRB)->B6_PRCVEN-SD1->D1_VUNIT)<=.01
					aCols[N][nPPrcVen] := A410Arred(SD1->D1_VUNIT,"C6_PRCVEN")
				Else
					aCols[N][nPPrcVen] := A410Arred((cAliasTRB)->B6_PRCVEN,"C6_PRCVEN")
				EndIf
			EndIf
			If nPQuant <> 0 .And. (aCols[N][nPQuant] > (cAliasTRB)->B6_SALDO .Or. aCols[N][nPQuant] == 0 )
				aCols[N][nPQuant] := Min((cAliasTRB)->B6_SALDO,A410SNfOri(cCliFor,cLoja,SD1->D1_DOC,SD1->D1_SERIE,"",SD1->D1_COD,(cAliasTRB)->B6_IDENT,aCols[n][nPosLocal])[1])
				If nPQuant2UM <> 0
					aCols[N][nPQuant2UM] := ConvUm(cProduto,aCols[N][nPQuant],0,2)
				EndIf
			EndIf
			If Rastro(cProduto) .And. SF4->F4_ESTOQUE=="S"
				If nPLoteCtl <> 0
					aCols[N][nPLoteCtl] := SD1->D1_LOTECTL
				EndIf
				If nPNumLote <> 0
					aCols[N][nPNumLote] := SD1->D1_NUMLOTE
				EndIf
				If nPDtValid <> 0 .Or. nPPotenc <> 0
					dbSelectArea("SB8")
					dbSetOrder(3)
					If DbSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
						If nPDtValid <> 0
							aCols[n][nPDtValid] := SB8->B8_DTVALID
						EndIf
						If nPPotenc <> 0
							aCols[n][nPPotenc] := SB8->B8_POTENCI
						EndIf
					EndIf
				EndIf
			EndIf
			A410MultT("C6_QTDVEN",aCols[N,nPQuant])
			A410MultT("C6_PRCVEN",aCols[N,nPPrcVen])
			If nPValDesc <> 0 .And. nPPrUnit > 0
				If aCols[n][nPPrUnit]<>0
					aCols[n][nPValDesc] := a410Arred((aCols[n][nPPrUnit]-aCols[n][nPPrcVen])*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"C6_VALDESC")
					A410MultT("C6_VALDESC",aCols[n][nPValDesc])
				EndIf
			EndIf
			If nPLocal <> 0
				aCols[N][nPLocal] := SD1->D1_LOCAL
				// Pesquisa os armazens dos movimentos do controle de qualidade
				If SD1->D1_LOCAL == cLocalCQ
					// Monta array com os armazens tratados na movimentacao do CQ
					cSeekSD7   := xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL
					SD7->(dbSetOrder(1))
					SD7->(dbSeek(cSeekSD7))
					Do While !SD7->(Eof()) .And. cSeekSD7 == SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO+SD7->D7_LOCAL
						If SD7->D7_TIPO >= 1 .And. SD7->D7_TIPO <= 2 .And. SD7->D7_ESTORNO # 'S'
							If aScan(aArmazensCQ,SD7->D7_LOCDEST) == 0
								AADD(aArmazensCQ,SD7->D7_LOCDEST)
							EndIf
						EndIf
						SD7->(dbSkip())
					EndDo
					// Monta texto para apresentacao no combobox
					If Len(aArmazensCQ) > 1
						nOpca:=0
						For nIX:=1 to Len(aArmazensCQ)
							AADD(aTextoCQ,OemToAnsi("Armazem")+" "+aArmazensCQ[nIX])
						Next nIX
						DEFINE MSDIALOG oDlg TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecao de Armazens") From 130,70 To 270,360 OF oMainWnd PIXEL
						@ 05,13 SAY OemToAnsi("Selecione o armazem para devolucao") OF oDlg PIXEL SIZE 110,9
						@ 17,13 TO 42,122 LABEL "" OF oDlg  PIXEL
						@ 23,17 MSCOMBOBOX oCombo VAR cCombo ITEMS aTextoCQ SIZE 100,044 OF oDlg PIXEL ON CHANGE (cLocalCQ:=aArmazensCQ[oCombo:nAt])
						DEFINE SBUTTON FROM 50,072 TYPE 1 Action (nOpca:=1,oDlg:End()) ENABLE OF oDlg PIXEL
						DEFINE SBUTTON FROM 50,099 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
						ACTIVATE MSDIALOG oDlg
						// Utiliza armazem relacionado ao movimento do CQ
						If nOpca == 1
							aCols[N][nPLocal] := cLocalCQ
						EndIf
					ElseIf Len(aArmazensCQ) > 0
						aCols[N][nPLocal] := aArmazensCQ[1]
					EndIf
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os campos a serem atualizados                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QTSEGUM"})
			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTECTL"})
			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NUMLOTE"})
			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DTVALID"})
			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_POTENCI"})
			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
			nPValAcrs := aScan(aHeader,{|x| AllTrim(x[2])=="XIT_DESPES"}) // CAMPO CUSTOMIZADO
			nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESC"})
			nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
			If SD1->(FieldPos("D1_ALMTERC")) > 0 .And. SD2->(FieldPos("D2_ALMTERC")) > 0
				nPAlmTerc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ALMTERC"})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona registros                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD2->(MsGoto((cAliasTRB)->SD2RECNO))
			nRegistro := (cAliasTRB)->SD2RECNO
			SF4->(dbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+aCols[n][nPTES]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche acols                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPIdentB6 <> 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Libera a trava obtida                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cAntB6Ident := aCols[ n, nPIdentB6 ]
				If !Empty( cAntB6Ident ) .And. cAntB6Ident <> (cAliasTRB)->B6_IDENT
					Leave1Code( "SD1_D1_IDENTB6" + cAntB6Ident )
				EndIf
				aCols[N][nPIdentB6] := (cAliasTRB)->B6_IDENT
			EndIf
			If nPNfOri <> 0
				aCols[N][nPNfOri] := SD2->D2_DOC
			EndIf
			If nPSerOri <> 0
				aCols[N][nPSerOri] := SD2->D2_SERIE
			EndIf
			If nPItemOri <> 0
				aCols[N][nPItemOri] := SD2->D2_ITEM
			EndIf
			If nPLocal <> 0
				aCols[N][nPLocal] := SD2->D2_LOCAL
			EndIf
			If nPAlmTerc <> 0
				aCols[N][nPAlmTerc] := SD2->D2_ALMTERC
			EndIf
			If nPPrcVen <> 0
				aCols[N][nPPrcVen] := A410Arred((cAliasTRB)->B6_PRUNIT,"D1_VUNIT")
			EndIf

			// Força o ajuste da quantidade para o valor resultante da divisão do valor total do item pelo preço unitário retornado do Poder Terceiros
			//aCols[N][nPQuant]	:= aCols[n][nPValor] / aCols[N][nPPrcVen]

			If nPQuant <> 0 .And. ( aCols[N][nPQuant] > (cAliasTRB)->B6_SALDO .Or. aCols[N][nPQuant]==0 )
				aCols[N][nPQuant] := (cAliasTRB)->B6_SALDO
				If nPQuant2UM <> 0
					aCols[N][nPQuant2UM] := ConvUm(cProduto,aCols[N][nPQuant],0,2)
				EndIf
			EndIf

			If Rastro(cProduto) .And. SF4->F4_ESTOQUE=="S"
				If nPLoteCtl <> 0
					aCols[N][nPLoteCtl] := SD2->D2_LOTECTL
				EndIf
				If nPNumLote <> 0
					aCols[N][nPNumLote] := SD2->D2_NUMLOTE
				EndIf
				If nPDtValid <> 0 .Or. nPPotenc <> 0
					dbSelectArea("SB8")
					dbSetOrder(3)
					If DbSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
						If nPDtValid <> 0
							aCols[n][nPDtValid] := SB8->B8_DTVALID
						EndIf
						If nPPotenc <> 0
							aCols[n][nPPotenc] := SB8->B8_POTENCI
						EndIf
					EndIf
				EndIf
			EndIf
			If nPValDesc <> 0 .And. nPQuant <> 0 .And. nPDesc <> 0 .And. nPValAcrs <> 0
				//aCols[n][nPValDesc] := a410Arred(((cAliasTRB)->B6_PRUNIT-(cAliasTRB)->B6_PRCVEN)*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"D1_VALDESC")
				If aCols[n][nPxPrcNfe] < aCols[N][nPPrcVen]
					aCols[n][nPValDesc] := a410Arred((aCols[N][nPPrcVen]-aCols[n][nPxPrcNfe])*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"D1_VALDESC")
				ElseIf aCols[n][nPxPrcNfe] > aCols[N][nPPrcVen]
					aCols[n][nPValAcrs] := a410Arred((aCols[n][nPxPrcNfe]-aCols[N][nPPrcVen])*IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant]),"D1_DESPESA")
				Endif

			EndIf
			aCols[n][nPValor] := a410Arred(IIf(aCols[n][nPQuant]==0,1,aCols[n][nPQuant])*aCols[n][nPPrcVen],"D1_TOTAL")
		EndIf

		If !Empty(cReadVar)

			Do Case
				Case cReadVar $ "M->C6_QTDVEN"
				&(cReadVar) := aCols[n][nPQuant]
				Case cReadVar $ "M->C6_UNSVEN"
				&(cReadVar) := aCols[n][nPQuant2UM]
				Case cReadVar $ "M->D1_QUANT"
				&(cReadVar) := aCols[n][nPQuant]
			EndCase
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	dbCloseArea()
	FErase(cNomeTrb + GetDbExtension()) // Deleting file
	FErase(cNomeTrb+ OrdBagExt()) // Deleting index

	RestArea(aArea)
	SetFocus(nHandle)

Return(lRetorno)


/*/{Protheus.doc} sfFracQte
//Efetuar o fracionamento de um item para atender saldos de pedido de compra
@author Marcelo A Lauschner
@since 11/01/2013
@version 1.0
@param nInNewQte, numeric, descricao
@param nInLinAtu, numeric, descricao
@param lFracAuto, logical, descricao
@type function
/*/
Static Function sfFracQte(nInNewQte,nInLinAtu,lFracAuto)

	Local 		nQteOrig		:= 0
	Local		nOpca			:= 0
	Local		aButtons		:= {}
	Local		nNewQte			:= 0
	Local		nPercRed		:= 0		
	Local		cMaxItem		:= Iif(Len(oMulti:aCols) > 0 ,oMulti:aCols[Len(oMulti:aCols),nPxItem],0)
	Local   	cQry 			:= ""
	Local		nOutLin     	:= 0
	Local		aOutRet			:= {}
	Local		iP,iW
	Default 	nInNewQte   	:= 0
	Default 	nInLinAtu   	:= oMulti:nAt
	Default 	lFracAuto		:= lAutoExec


	nQteOrig	:= Iif(Len(oMulti:aCols) > 0 ,oMulti:aCols[nInLinAtu,nPxQte],0)
	nNewQte		:= Iif(Len(oMulti:aCols) > 0 ,oMulti:aCols[nInLinAtu,nPxQteNfe],0)

	If Len(oMulti:aCols) > 0
		If !lFracAuto
			DEFINE MSDIALOG oDlgDes FROM 30,20  TO 185,551 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Fracionar quantidade original em novas quantidades") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"
			oPanelFrc := TPanel():New(0,0,'',oDlgDes, oDlgDes:oFont, .T., .T.,, ,200,40,.T.,.T. )
			oPanelFrc:Align := CONTROL_ALIGN_ALLCLIENT

			@ 15  ,4   SAY OemToAnsi("Produto") Of oPanelFrc PIXEL SIZE 47 ,9 //"Produto"
			@ 14  ,35  MSGET oMulti:aCols[nInLinAtu,nPxProd] PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanelFrc PIXEL SIZE 60,9
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+oMulti:aCols[nInLinAtu,nPxProd])
			@ 14  ,95  MSGET SB1->B1_DESC PICTURE PesqPict('SB1','B1_DESC') When .F. Of oPanelFrc PIXEL SIZE 150,9

			@ 28  ,04  SAY OemToAnsi("Quantidade") Of oPanelFrc PIXEL SIZE 25 ,9
			@ 27  ,35  MsGet oMulti:aCols[nInLinAtu,nPxQteNfe] Picture PesqPict('SD1','D1_QUANT') When .F. Of oPanelFrc Pixel Size 50,09

			@ 28  ,095  SAY OemToAnsi("Nova Quant.") Of oPanelFrc PIXEL SIZE 40 ,9
			@ 27  ,140 MsGet nNewQte Picture PesqPict('SD1','D1_QUANT') Valid nNewQte <= oMulti:aCols[nInLinAtu,nPxQteNfe] When .T. Of oPanelFrc Pixel Size 50,09

			ACTIVATE MSDIALOG oDlgDes CENTERED ON INIT EnchoiceBar(oDlgDes,{|| nOpca:=1,oDlgDes:End()},{||oDlgDes:End()},,aButtons)
		Else

			// Verifico qual o último item da tabela de itens para permitir a adição fracioanda durante a carga automática.
			cQry := "SELECT COALESCE(MAX(XIT_ITEM),'0001') MAXITEM "
			cQry += "  FROM CONDORXMLITENS "
			cQry += " WHERE D_E_L_E_T_ = ' ' "
			cQry += "   AND XIT_CHAVE = '"+aArqXml[oArqXml:nAt,nPosChvNfe]+"' "

			TCQUERY cQry NEW ALIAS "QMAX"

			If !Eof()
				cMaxItem	:= Padr(QMAX->MAXITEM,TamSX3("D1_ITEM")[1])
			Endif
			QMAX->(DbCloseArea())

			For iW := 1 To Len(oMulti:aCols)
				cMaxItem	:= Iif(oMulti:aCols[iW,nPxItem] >= cMaxItem,oMulti:aCols[iW,nPxItem],cMaxItem)
			Next

			nOpca 	:= 1
			nNewQte	:= nInNewQte

		Endif

		If nOpca == 1 .And. nNewQte > 0 .And.  nNewQte  < oMulti:aCols[nInLinAtu,nPxQteNfe]

			aNewLin	:= 	aClone(oMulti:aCols[nInLinAtu])
			aLinBk	:=  aClone(oMulti:aCols[nInLinAtu])
			nPercRed	:= 	nNewQte / oMulti:aCols[nInLinAtu,nPxQteNfe]
			oMulti:aCols[nInLinAtu,Len(oMulti:aHeader)+1]	:= .T.
			oMulti:oBrowse:Refresh()

			For iP := 1 To Len(aElemNumChg)
				aNewLin[aElemNumChg[iP]]	:= Round(aLinBk[aElemNumChg[iP]] * nPercRed ,oMulti:aHeader[aElemNumChg[iP],5])
			Next
			cMaxItem	:= Soma1(cMaxItem)
			aNewLin[nPxItem]	:= cMaxItem
			// Adiciono a primeira linha com a quantidade quebrada
			Aadd(oMulti:aCols,aClone(aNewLin))

			oMulti:oBrowse:Refresh()
			// Atribui a nova linha a variável de retorno da função
			nOutLin	:= Len(oMulti:aCols)
			Aadd(aOutRet,nOutLin)
			aNewLin	:= 	aClone(aLinBk)
			For iP := 1 To Len(aElemNumChg)
				//aNewLin[aElemNumChg[iP]]	:= aLinBk[aElemNumChg[iP]] * (1-nPercRed)
				// 27/02/2017 - Corrigida a forma de retornar o valor da segunda linha, subtraindo o valor original pelo valor da fração atribuida na linha anterior
				aNewLin[aElemNumChg[iP]]	:= aLinBk[aElemNumChg[iP]] - oMulti:aCols[nOutLin,aElemNumChg[iP]] // oMulti:aCols[nInLinAtu

			Next
			// Melhoria adicionada em 17/11/2013 para não preecher dados de pedido e item de pedido de compras a nova linha criada
			// Por que na chamada do fracionamento, há uma recursividade da função U_VLDITEMPC que irá avaliar os pedidos disponíveis
			aNewLin[nPxPedido]	:= ""
			aNewLin[nPxItemPc]	:= ""

			cMaxItem	:= Soma1(cMaxItem)
			aNewLin[nPxItem]	:= cMaxItem
			Aadd(oMulti:aCols,aNewLin)

			// Atribui a nova linha a variável de retorno da função
			nOutLin	:= Len(oMulti:aCols)
			Aadd(aOutRet,nOutLin)

			oMulti:oBrowse:Refresh()
		Else
			Aadd(aOutRet,nInLinAtu)
		Endif
	Endif

Return aOutRet


/*/{Protheus.doc} sfViewCteXNf
(Visualiza notas fiscais X CTe    )
@author MarceloLauschner
@since 28/04/2013
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfViewCteXNf()

	Local		aAreaOld	:= GetArea()
	Local		lExistA3CC	:= .F.
	Local		cCCusto		:= ""
	Private 	oMovim
	Private		aMovim		:= {}

	// Customizacao que permite levar o centro de custo do vendedor para o lançamento do documento
	DbSelectArea("SA3")
	DbSetOrder(1)
	If SA3->(FieldPos("A3_CC")) > 0
		lExistA3CC	:= .T.
	Endif

	U_DbSelArea("CONDORCTEXNFS",.F.,1)
	If DbSeek(Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe]))
		While !Eof() .And. Alltrim(CONDORCTEXNFS->XCN_CHVCTE) == Alltrim(aArqXml[oArqXml:nAt,nPosChvNfe]) .And. CONDORCTEXNFS->XCN_EMP == cEmpAnt .And. CONDORCTEXNFS->XCN_FIL == cFilAnt
			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek(xFilial("SF2")+CONDORCTEXNFS->XCN_NUMNFS+CONDORCTEXNFS->XCN_SERNFS+CONDORCTEXNFS->XCN_CLINFS+CONDORCTEXNFS->XCN_LOJNFS)
				If lExistA3CC
					cCCusto	:= Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_CC")
				Endif

				If ExistBlock("XMLCTE04")
					cCCusto	:= ExecBlock("XMLCTE04",.F.,.F.,{cCCusto})
				Endif


				Aadd(aMovim,{	'Nota de Saída',;
				CONDORCTEXNFS->XCN_CHVNFS,;
				CONDORCTEXNFS->XCN_NUMNFS,;
				CONDORCTEXNFS->XCN_SERNFS,;
				CONDORCTEXNFS->XCN_CLINFS,;
				CONDORCTEXNFS->XCN_LOJNFS,;
				CONDORCTEXNFS->XCN_TIPNFS,;
				"S",;
				cCCusto})
			Endif

			DbSelectArea("SF1")
			DbSetOrder(8)
			If DbSeek(XFilial("SF1") + Padr(CONDORCTEXNFS->XCN_CHVNFS,Len(SF1->F1_CHVNFE)))

				Aadd(aMovim,{	'Nota de Entrada',;
				SF1->F1_CHVNFE,;		// 2
				SF1->F1_DOC,;			// 3
				SF1->F1_SERIE,;			// 4
				SF1->F1_FORNECE,;		// 5
				SF1->F1_LOJA,;			// 6
				SF1->F1_TIPO,;			// 7
				"E",;					// 8
				""})
			Endif
			DbSelectArea("CONDORCTEXNFS")
			DbSkip()
		Enddo
	Endif

	DbSelectArea("SF1")
	DbSetOrder(1)

	DbSelectArea("SF8")
	DbSetOrder(1) // F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA

	cChvSF1	:= Substr(CONDORXML->XML_KEYF1,1,Len(SF8->F8_FILIAL) + Len(SF8->F8_NFDIFRE) + Len(SF8->F8_SEDIFRE))

	If DbSeek(cChvSF1)//	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
		While !Eof() .And. SF8->F8_FILIAL+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE == cChvSF1
			If SF1->(DbSeek(xFilial("SF1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA))
				// Adiciona apenas notas que não foram encontradas ainda no Array por que pode ter havido a adição pela tabela CONDORCTEXNFS
				If aScan(aMovim,{|x| x[2] == SF1->F1_CHVNFE } ) == 0
					Aadd(aMovim,{	"Nota de Entrada",;	// 1
					SF1->F1_CHVNFE,;		// 2
					SF1->F1_DOC,;			// 3
					SF1->F1_SERIE,;			// 4
					SF1->F1_FORNECE,;		// 5
					SF1->F1_LOJA,;			// 6
					SF1->F1_TIPO,;			// 7
					"E" ,;					// 8
					""})					// 9
				Endif
			Endif
			DbSelectArea("SF8")
			DbSkip()
		Enddo
	Endif



	DEFINE MSDIALOG oDlgKd From 000,000 To 365,800 Of oMainWnd Pixel Title OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Notas fiscais vinculadas ao CTE ")
	If Len(aMovim) == 0
		aMovim := {{"","","","","","","",""}}
	Endif
	@ 005,005 LISTBOX oMovim FIELDS TITLE ;
	OemtoAnsi("Tipo Nota"),;
	OemToAnsi("Chave NFe"),;
	OemToAnsi("Num Nf"),;
	OemtoAnsi("Série"),;
	OemToAnsi("Cliente/Fornecedor"),;
	OemToAnsi("Loja"),;
	OemToAnsi("Tipo Doc"),;
	OemToAnsi("E/S"),;
	OemToAnsi("Centro Custo") SIZE 395,160 PIXEL
	oMovim:SetArray(aMovim)
	oMovim:bLine := {|| aMovim[oMovim:nAt] }

	@170,130 Button "Visualizar"  Size 40,10 Action sfViewNF() of oDlgKd Pixel
	@170,180 Button "Cancela" Size 40,10 Action oDlgKd:End() Of oDlgKd Pixel

	Activate MSDIALOG oDlgKd Centered

	Eval(bRefrPerg)

	RestArea(aAreaOld)

Return


/*/{Protheus.doc} sfCadSA2
(Cadastro automático de fornecedor com dados do XML)
@author MarceloLauschner
@since 29/06/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfCadSA2()

	Local 	aAreaOld	:= GetArea()
	Local	cEndEmit	:= ""
	Local	cVarAux		:= ""
	Private	aNaoExiste	:= {}
	Private	cAviso 		:= ""
	Private	cErro		:= ""
	Private	cCadastro	:= "Cadastro de Fornecedores[SA2]"
	Private	INCLUI		:= .T.
	Private	ALTERA		:= .F.
	Private l020Auto	:= .F.
	Private lCGCValido	:= .F. 

	// Evita cadastro de fornecedor se a função for acionada pelo botão da Enchoicebar
	If !oBtnCom06:lActive
		Return
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])

	oCte := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)

	If !Empty(cErro)
		MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
		stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Inclusão de fornecedor via XML com erro- "+cErro ,'"'+CONDORXML->XML_ARQ+'"')
		Return .F.
	Endif

	If !Empty(cAviso)
		MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Aviso ao validar schema do Xml")
		stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Inclusão de fornecedor via XML com aviso "+ cAviso ,'"'+CONDORXML->XML_ARQ+'"')
	Endif

	If Type("oCte:_CTeProc")<> "U"
		oNF 			:= oCte:_CTeProc:_CTe
		oEmitente  	:= oNF:_InfCTe:_emit
	ElseIf Type("oCte:_CTe")<> "U"
		oNF 			:= oCte:_CTe
		oEmitente  	:= oNF:_InfCTe:_emit
	Else
		cAviso	:= ""
		cErro	:= ""

		oCte := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)

		If !Empty(cErro)
			MsgAlert(cErro+chr(13)+cAviso,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao validar schema do Xml")
			stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Inclusão de fornecedor via XML com erro - "+cErro ,'"'+CONDORXML->XML_ATT3+'"')
			Return .F.
		Endif

		If !Empty(cAviso)
			MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")
			stSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Inclusão de fornecedor via XML com erro "+ cAviso ,'"'+CONDORXML->XML_ATT3+'"')
		Endif

		If Type("oCte:_CTeProc")<> "U"
			oNF 			:= oCte:_CTeProc:_CTe
			oEmitente  	:= oNF:_InfCTe:_emit
		ElseIf Type("oCte:_CTe")<> "U"
			oNF 			:= oCte:_CTe
			oEmitente  	:= oNF:_InfCTe:_emit
		Endif
	Endif

	If Type("oEmitente") == "U"
		oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)

		If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
			oNF 			:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_NFe
			oEmitente  		:= oNF:_InfNfe:_Emit
		ElseIf Type("oNFe:_NfeProc")<> "U"
			oNF 			:= oNFe:_NFeProc:_NFe
			oEmitente  		:= oNF:_InfNfe:_Emit
		ElseIf Type("oNFe:_NFe")<> "U"
			oNF 			:= oNFe:_NFe
			oEmitente  		:= oNF:_InfNfe:_Emit
		Else
			cAviso	:= ""
			cErro	:= ""
			oNfe := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)
			If Type("oNFe:_NfeProc")<> "U"
				oNF 			:= oNFe:_NFeProc:_NFe
				oEmitente  	:= oNF:_InfNfe:_Emit
			ElseIf Type("oNFe:_Nfe")<> "U"
				oNF 			:= oNFe:_NFe
				oEmitente  	:= oNF:_InfNfe:_Emit
			Else
				MsgAlert("Erro ao ler xml "+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				Return .F.
			Endif
		Endif

		If !Empty(cErro)
			MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Return .F.
		Endif
	Endif

	Aadd(aNaoExiste,{"A2_NOME"		,Padr(IIf(Type("oEmitente:_xNome") <> "U", Transform(oEmitente:_xNome:TEXT,PesqPict("SA2","A2_NOME")),""),TamSX3("A2_NOME")[1])})
	Aadd(aNaoExiste,{"A2_NREDUZ"	,Padr(IIf(Type("oEmitente:_xFant") <> "U", Transform(oEmitente:_xFant:TEXT,PesqPict("SA2","A2_NREDUZ")),""),TamSX3("A2_NREDUZ")[1])})

	cEndEmit	:= IIf(Type("oEmitente:_enderEmit:_xLgr") <> "U", Transform(oEmitente:_enderEmit:_xLgr:TEXT,PesqPict("SA2","A2_END")),"")
	// Existindo o campo Numero, concatena
	cEndEmit	+= IIf(Type("oEmitente:_enderEmit:_nro") <> "U", ", "+oEmitente:_enderEmit:_nro:TEXT,"")

	Aadd(aNaoExiste,{"A2_END"		,Padr(cEndEmit,TamSX3("A2_END")[1])})
	Aadd(aNaoExiste,{"A2_COMPLEM"	,Padr(IIf(Type("oEmitente:_enderEmit:_xCpl") <> "U", Transform(oEmitente:_enderEmit:_xCpl:TEXT,PesqPict("SA2","A2_COMPLEM")),""),TamSX3("A2_COMPLEM")[1])})

	Aadd(aNaoExiste,{"A2_BAIRRO"	,Padr(IIf(Type("oEmitente:_enderEmit:_xBairro") <> "U", Transform(oEmitente:_enderEmit:_xBairro:TEXT,PesqPict("SA2","A2_BAIRRO")),""),TamSX3("A2_BAIRRO")[1])})
	Aadd(aNaoExiste,{"A2_EST"		,IIf(Type("oEmitente:_enderEmit:_UF") <> "U", oEmitente:_enderEmit:_UF:TEXT,"")})

	cVarAux	:= Padr(IIf(Type("oEmitente:_enderEmit:_UF") <> "U", oEmitente:_enderEmit:_UF:TEXT,""),TamSX3("CC2_EST")[1])
	cVarAux	+= Padr(IIf(Type("oEmitente:_enderEmit:_xMun") <> "U", oEmitente:_enderEmit:_xMun:TEXT,""),TamSX3("CC2_CODMUN")[1])

	// 10/01/2017 - Verifica se o indice já existe na Tabela SIX 
	DbSelectArea("SIX")
	DbSetOrder(1)
	If DbSeek("CC24")
		DbSelectArea("CC2")
		DbSetOrder(4)
		If DbSeek(xFilial("CC2")+cVarAux)
			Aadd(aNaoExiste,{"A2_COD_MUN"	,CC2->CC2_CODMUN})
		Else
			cVarAux	:= IIf(Type("oEmitente:_enderEmit:_cMun") <> "U", oEmitente:_enderEmit:_cMun:TEXT,"")
			Aadd(aNaoExiste,{"A2_COD_MUN"	,Padr(Substr(cVarAux,3),TamSX3("A2_COD_MUN")[1])})
		Endif
	Else
		cVarAux	:= IIf(Type("oEmitente:_enderEmit:_cMun") <> "U", oEmitente:_enderEmit:_cMun:TEXT,"")
		Aadd(aNaoExiste,{"A2_COD_MUN"	,Padr(Substr(cVarAux,3),TamSX3("A2_COD_MUN")[1])})
	Endif

	cVarAux	:= Padr(IIf(Type("oEmitente:_enderEmit:_fone") <> "U", oEmitente:_enderEmit:_fone:TEXT,""),TamSX3("A2_TEL")[1])
	Aadd(aNaoExiste,{"A2_TEL"		,Padr(cVarAux,TamSX3("A2_TEL")[1])})

	Aadd(aNaoExiste,{"A2_MUN"		,Padr(IIf(Type("oEmitente:_enderEmit:_xMun") <> "U", Transform(oEmitente:_enderEmit:_xMun:TEXT,PesqPict("SA2","A2_MUN")),""),TamSX3("A2_MUN")[1])})

	Aadd(aNaoExiste,{"A2_CEP"		,IIf(Type("oEmitente:_enderEmit:_CEP") <> "U", oEmitente:_enderEmit:_CEP:TEXT,"")})
	Aadd(aNaoExiste,{"A2_TIPO"		,IIf(Type("oEmitente:_CNPJ") <> "U", "J",IIf(Type("oEmitente:_CPF") <> "U", "F",""))})
	Aadd(aNaoExiste,{"A2_CGC"		,IIf(Type("oEmitente:_CNPJ") <> "U", oEmitente:_CNPJ:TEXT,IIf(Type("oEmitente:_CPF") <> "U", oEmitente:_CPF:TEXT,""))})
	Aadd(aNaoExiste,{"A2_INSCR"		,Padr(IIf(Type("oEmitente:_IE") <> "U", oEmitente:_IE:TEXT,"ISENTO"),TamSX3("A2_INSCR")[1])})
	Aadd(aNaoExiste,{"A2_INSCRM"	,Padr(IIf(Type("oEmitente:_IM") <> "U", oEmitente:_IM:TEXT,""),TamSX3("A2_INSCRM")[1])})
	Aadd(aNaoExiste,{"A2_CNAE"		,Padr(IIf(Type("oEmitente:_CNAE") <> "U", oEmitente:_CNAE:TEXT,""),TamSX3("A2_CNAE")[1])})

	If SA2->(FieldPos("A2_SIMPNAC")) > 0
		// Opções do CRT
		//1 – Simples Nacional;
		//2 – Simples Nacional – excesso de sublimite de receita bruta;
		//3 – Regime Normal.
		// Opções do campo 1=Sim 2=Não
		Aadd(aNaoExiste,{"A2_SIMPNAC",IIf(Type("oEmitente:_CRT") <> "U", IIf(oEmitente:_CRT:TEXT == "3","2","1")," ")})
	Endif

	
	// Função nativa do MATA020
	A020WebbIc(aNaoExiste)

	// Se Encontrar o cadastro do fornecedor depois da inclusão, força a atualização da tela.
	DbSelectArea("SA2")
	DbSetOrder(3)
	If DbSeek(xFilial("SA2")+CONDORXML->XML_EMIT)
		Eval(bRefrItem)
	Endif

	RestArea(aAreaOld)

Return

/*/{Protheus.doc} sfViewNF
(Visualiza a nota de Entrada ou Saída)
@author MarceloLauschner
@since 01/11/2012
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfViewNF()

	Local	aAreaOld	:= GetArea()

	If Substr(aMovim[oMovim:nAt,8],1,1) == "E"
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(xFilial("SF1")+aMovim[oMovim:nAt,3]+aMovim[oMovim:nAt,4]+aMovim[oMovim:nAt,5]+aMovim[oMovim:nAt,6]+aMovim[oMovim:nAt,7])
			cBkMod	:= cModulo
			nBkMod	:= nModulo
			cModulo	:= "COM"
			nModulo	:= 02
			Mata103( , , 2 ,)
			cModulo	:= cBkMod
			nModulo := nBkMod
		Endif
	ElseIf Substr(aMovim[oMovim:nAt,8],1,1) == "S"
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek(xFilial("SF2")+aMovim[oMovim:nAt,3]+aMovim[oMovim:nAt,4]+aMovim[oMovim:nAt,5]+aMovim[oMovim:nAt,6])
			Mc090Visual("SF2",SF2->(Recno()),2)
		Endif
	Endif

	RestArea(aAreaOld)

Return

/*/{Protheus.doc} sfStartInit
(Função para executar ao startar rotina  )
@author MarceloLauschner
@since 03/06/2013
@version 1.0
@param oDlg, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfStartInit(oDlg,aButton)

	If lAutoExec

		Eval({|| Pergunte(cPergXml,.F.),stRefresh(), stRefrItem(),SetFocus(nFocus1)})

		// Executa função
		While .T.
			//stSendMail( "marcelolauschner@gmail.com", "Executando processo automático filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Não houveram registros" )
			//stSendMail( "contato@centralxml.com.br", "Executando processo automático filial "+cFilAnt, ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" "+aArqXml[oArqXml:nAt,nPosChvNfe] )
			//oBtnIncDoc:Click()
			//Eval(oBtnDoc01:bAction)
			//ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + " Chave "+ aArqXml[oArqXml:nAt,nPosChvNfe])
			If Len(aArqXml) == 1 .And. Empty(aArqXml[1,2]) // Somente uma linha vazia
				Exit
			Endif
			stGeraNfe()

			Eval({|| Pergunte(cPergXml,.F.),stRefresh(), stRefrItem(),SetFocus(nFocus1)})

			If Len(aArqXml) == 1 .And. Empty(aArqXml[1,2]) // Somente uma linha vazia
				Exit
			Endif

		Enddo

	Else
		EnchoiceBar(oDlg,{|| MsgInfo("Sem função o botão Confirma",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))},{|| oDlg:End()},,aButton)
	Endif

Return

/*/{Protheus.doc} sfAtuXmlOk
(Grava flag impedindo a entrada automática da nota)
@author MarceloLauschner
@since 03/06/2013
@version 1.0
@param cOkMot, character, (Descrição do parâmetro)
@param lAtuItens, logico, (Descrição do parâmetro)
@param cItem, character, (Descrição do parâmetro)
@param cMsgAux, character, (Descrição do parâmetro)
@param nLinXml, numérico, (Descrição do parâmetro)
@param cInChave, character, (Descrição do parâmetro)
@param lAtuOk, logico, Determina se o campo XML_OK será atualizado ou não. 
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function sfAtuXmlOk(cOkMot,lAtuItens,cItem,cMsgAux,nLinXml,cInChave,lAtuOk,cInAssunto,cDestMail,cInCpoAlt,cInVlAnt,cInVlNew,cInCodPrd)
	//sfAtuXmlOk(/*cOkMot*/,/*lAtuItens*/,/*cItem*/,/*cMsgAux*/,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,/*cInCpoAlt*/,/*cInVlAnt*/,/*cInVlNew*/)
	Local	aAreaOld	:= GetArea()
	Local	aAreaIts
	Local	cTxtItem	:= ""
	Local	cTxtAux		:= ""
	Local	cVarAux		:= ""
	Local	cMailSa2	:= GetNewPar("XM_A2RESDP","A2_XRESPDP")	// Campo SA2 com email do responsável para Alerta divergencia tipo DP
	Local	cAuxBody	:= ""
	Local   lBlqEmp		:= GetNewPar("XM_BLQXEMP",.F.) 
	Local	lRet		:= .T.
	Default	cInAssunto	:= "Mensagem de aviso Central XML - Motivo '" + cOkMot + "' -  " + cEmpAnt + "/" + cFilAnt + " " + SM0->M0_NOMECOM
	Default	cDestMail	:= ""
	Default	lAtuItens	:= .F.
	Default cMsgAux		:= " "
	Default	cItem		:= " "
	Default	nLinXml		:= Iif(Type("oArqXml") <> "U",oArqXml:nAt,IIf(Type("aArqXml") == "A",Len(aArqXml),1)) // Evita erro de objeto não existente
	Default cInChave	:= Iif(Type("aArqXml") == "A",aArqXml[nLinXml,nPosChvNfe],"")
	Default lAtuOk		:= .T.
	Default cInCpoAlt	:= ""
	Default cInVlAnt	:= ""
	Default cInVlNew	:= ""
	Default	cInCodPrd	:= ""
	U_DbSelArea("CONDORXML",.F.,1)
	
	If DbSeek(cInChave)

		// Melhoria adicionada em 10/10/2013 para atualizar flag por item
		If lAtuItens
			aAreaIts	:= CONDORXMLITENS->(GetArea())
			U_DbSelArea("CONDORXMLITENS",.F.,2)
			If DbSeek(CONDORXML->XML_CHAVE+cItem)
				RecLock("CONDORXMLITENS",.F.)
				CONDORXMLITENS->XIT_OK	:= cOkMot
				MsUnlock()
				If Empty(cInCodPrd)
					cInCodPrd	:= CONDORXMLITENS->XIT_CODPRD
				Endif
				cTxtItem	+= "Item:"+CONDORXMLITENS->XIT_ITEM + CRLF + "Cod.Fornecedor:"+CONDORXMLITENS->XIT_CODNFE + "-" + CONDORXMLITENS->XIT_DESCRI + CRLF
				// Melhoria 15/11/2014 - Solicitação Madeiramadeira
				// Descrever data de emissão Pedido Compra + Condição pagamento
				If cOkMot $ "DP"
					DbSelectArea("SC7")
					DbSetOrder(1)
					If DbSeek(xFilial("SC7")+CONDORXMLITENS->XIT_PEDIDO+CONDORXMLITENS->XIT_ITEMPC)
						DbSelectArea("SE4")
						DbSetOrder(1)
						DbSeek(xFilial("SE4")+SC7->C7_COND)
						cVarAux	:= "Pedido de Compra: "+SC7->C7_NUM + " / Emissão: "+DTOC(SC7->C7_EMISSAO) + " / Condição Pgto: "+SC7->C7_COND + "-"+SE4->E4_DESCRI
						If !(cVarAux $ cTxtAux)
							cTxtAux	+= cVarAux + CRLF
						Endif
					Endif
				Endif
			Endif
			RestArea(aAreaIts)
		Endif
		
		U_DbSelArea("CONDORBLQAUTO",.F.,1)
		DbSeek(IIf(lBlqEmp,cEmpAnt,"")+cOkMot)
		
		//C=Em Cópia ; R=Novo remetente;M=Mantém remetente original
		If CONDORBLQAUTO->XBL_OPMAIL $ " #M"
			cDestMail	+= IIf(Empty(cDestMail),"",";") +Iif(!Empty(CONDORBLQAUTO->XBL_EMAILD),Alltrim(CONDORBLQAUTO->XBL_EMAILD), GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"))
		ElseIf 	CONDORBLQAUTO->XBL_OPMAIL $ "R"  .And. !Empty(CONDORBLQAUTO->XBL_EMAILD)
			cDestMail	:= IIf(Empty(cDestMail),"",";") + Alltrim(CONDORBLQAUTO->XBL_EMAILD)		
		ElseIf CONDORBLQAUTO->XBL_OPMAIL $ "C" .And. !Empty(CONDORBLQAUTO->XBL_EMAILD)
			cDestMail	+= IIf(Empty(cDestMail),"",";") + Alltrim(CONDORBLQAUTO->XBL_EMAILD)		
		Endif
		
		lRet	:= CONDORBLQAUTO->XBL_BLQLCO $ " #1"
		
		//A2_MAILRESP - se motivo DP
		// Melhoria implementada em 28/09/2014 por solicitação Madeiramadeira
		// para que seja informado o email do responsável pelo fornecedor na divergencia de duplicatas
		If cOkMot $ "DP"
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+CONDORXML->XML_CODLOJ)
			If SA2->(FieldPos(cMailSa2)) > 0 .And. !Empty(&("SA2->"+cMailSa2))
				cDestMail	+= ";"+&("SA2->"+cMailSa2)
			Endif
		Endif
		cAuxBody	:= "Foi encontrado o erro: '"+cOkMot+"-"+CONDORBLQAUTO->XBL_DESMOT + "'" + CRLF +;
		"Tipo de lançamento " + IIf(lAutoExec,"Automático via agendamento","com interface de usuário") + CRLF +;
		"Enviado para :" +cDestMail + CRLF +;
		cTxtItem + CRLF + cMsgAux

		cAuxBody	+= Alltrim(CONDORXML->XML_BODY)
		RecLock("CONDORXML",.F.)
		If lAtuOk	// 19/06/2016 - Somente atualiza flag XML_OK se .T. pois poderão haver condições em que deverá ser avisado o erro mas mesmo assim permitir o lançamento da nota
			CONDORXML->XML_OK	:= cOkMot
		Endif
		CONDORXML->XML_BODY	:= cAuxBody
		// Quando o motivo é PN grava a data de Conferência Fiscal
		If cOkMot $ "PN"
			CONDORXML->XML_CONFIS 	:= Date()
		Endif
		MsUnlock()
		// 03/11/2016 - Apenas envia alertas conforme configuração de motivos
		// M=Bloqueios Lcto Manual;A=Bloqueios Lcto Automáticos;T=Ambos Lctos;N=Não envia alerta
		If (lAutoExec .And. CONDORBLQAUTO->XBL_TIPENV $ "A#T# ") .Or. (!lAutoExec .And. CONDORBLQAUTO->XBL_TIPENV $ "M#T")  

			stSendMail(cDestMail,;
			cInAssunto,;
			"Foi encontrado o erro: '"+cOkMot+"-"+CONDORBLQAUTO->XBL_DESMOT + "'" + CRLF +;
			"Tipo de lançamento " + IIf(lAutoExec,"Automático via agendamento","com interface de usuário") + CRLF+;
			"Nota: " + CONDORXML->XML_NUMNF + CRLF +;
			"Chave: " + CONDORXML->XML_CHAVE + CRLF +;
			"Fornecedor: "+CONDORXML->XML_CODLOJ + "-"+ CONDORXML->XML_NOMEMT + "'" + CRLF +;
			cTxtItem + CRLF + cMsgAux )
		Endif
		
		// 13/08/2017 - Melhoria que efetua a gravação de uma tabela de Logs de eventos
		U_DbSelArea("CONDORLOGBLQ",.F.,1)
		RecLock("CONDORLOGBLQ",.T.)
		CONDORLOGBLQ->XLG_CHAVE		:= cInChave
		CONDORLOGBLQ->XLG_ITEM		:= IIf(lAtuItens,cItem," ")
		CONDORLOGBLQ->XLG_CODMOT	:= cOkMot
		CONDORLOGBLQ->XLG_INFO		:= "Tipo de lançamento " + IIf(lAutoExec,"Automático via agendamento","com interface de usuário") + cMsgAux
		CONDORLOGBLQ->XLG_DATA		:= Date()
		CONDORLOGBLQ->XLG_HORA		:= Time()
		CONDORLOGBLQ->XLG_USER		:= cUserName
		CONDORLOGBLQ->XLG_EMAIL		:= cDestMail
		CONDORLOGBLQ->XLG_BLQLCO	:= CONDORBLQAUTO->XBL_BLQLCO
		CONDORLOGBLQ->XLG_CPOALT	:= cInCpoAlt
		CONDORLOGBLQ->XLG_VLANTI	:= cInVlAnt
		CONDORLOGBLQ->XLG_VLNEW		:= cInVlNew
		If CONDORLOGBLQ->(FieldPos("XLG_CODPRD")) > 0
			CONDORLOGBLQ->XLG_CODPRD 	:= cInCodPrd
		Endif
		MsUnlock()
		
		ConOut(Padr("|Chave:" +Alltrim(CONDORXML->XML_CHAVE) + " Erro: "+cOkMot+"-"+CONDORBLQAUTO->XBL_DESMOT ,99) + "|")

	Endif

	RestArea(aAreaOld)

Return lRet	


/*/{Protheus.doc} sfPrintSF1
(Chama impressão do documento de entrada padrão do sistema )
@author MarceloLauschner
@since 24/05/2013
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfPrintSF1()

	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(CONDORXML->XML_KEYF1)
		A103Impri( "SF1",SF1->(Recno()),4)
	Endif

	Eval(bRefrPerg)
Return




/*/{Protheus.doc} sfVldAlqIcms
(Valida aliquota de Icms para CTE)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@param cTipCte, character, (Descrição do parâmetro)
@param cInCNPJ, character, (Descrição do parâmetro)
@param oImposto, objeto, (Descrição do parâmetro)
@param oIdent, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfVldAlqIcms(cTipCte,cInCNPJ,oImposto,oIdent,cUfIni,cUfFim,lExibeMsg)

	Local	lRet			:= .T.
	Local	aAreaOld    	:= GetArea()
	Local	cMVESTICM 		:= SuperGetMV("MV_ESTICM")
	Local	nPerIcm 		:= GetMv("MV_ICMPAD")
	Local  cMVNORTE    		:= SuperGetMV("MV_NORTE")
	Local  cMVESTADO		:= GetMv("MV_ESTADO")
	//Local	cUfEnv			:= IIf(Type("oIdent:_UFEnv") <> "U",oIdent:_UFEnv:TEXT,cMVESTADO)

	Local	cTipoCST		:= ""
	Local	nBaseIcms		:= 0	//-- Base de Calculo
	Local	nBaseRet		:= 0	//-- Base ICMS Retido
	Local	nAliqIcms		:= 0	//-- Aliquota ICMS
	Local	nIcmsSt			:= 0	//-- ICMS ST
	Local	nValIcms		:= 0	//-- Valor ICMS
	Local	nRedBcCalc		:= 0	//-- "Red.Bc.Calc."
	Local	cTipoCli		:= ""
	Default	cUfFim			:= ""
	Default	cUfIni			:= ""
	Default lExibeMsg		:= .T. 

	cUfIni			:= IIf(Type("oIdent:_UFIni") <> "U",oIdent:_UFIni:TEXT,Iif(Empty(cUfIni),cMVESTADO,cUfIni))
	cUfFim			:= IIf(Type("oIdent:_UFFim") <> "U",oIdent:_UFFim:TEXT,cMVESTADO)
	//cUfIni	:= "SP"
	//cUfFim	:= "GO"
	//If GetNewPar("XM_CTEUFA3",.F.)
	//	cUfIni		:= cUfFim
	//Endif

	If Type("oImposto:_ICMS") <> "U"

		If Type("oImposto:_ICMS:_CST00") <> "U"
			cTipoCST	:= oImposto:_ICMS:_CST00:_CST:TEXT
			nBaseIcms	:= Val(oImposto:_ICMS:_CST00:_vBC:TEXT)	//-- Base de Calculo
			nAliqIcms	:= Val(oImposto:_ICMS:_CST00:_pICMS:TEXT)	//-- Aliquota ICMS
			nValIcms	:= Val(oImposto:_ICMS:_CST00:_vICMS:TEXT)	//-- Valor ICMS
			nBaseRet	:= 0			//-- Base ICMS Retido
			nRedBcCalc	:= 0	 		//-- "Red.Bc.Calc."
			nIcmsSt		:= 0			//-- ICMS ST
		ElseIf Type("oImposto:_ICMS:_CST20") <> "U"
			cTipoCST	:= oImposto:_ICMS:_CST20:_CST:TEXT
			nBaseIcms	:= Val(oImposto:_ICMS:_CST20:_vBC:TEXT)	//-- Base de Calculo
			nBaseRet	:= 0			//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_CST20:_pICMS:TEXT)	//-- Aliquota ICMS
			nValIcms	:= Val(oImposto:_ICMS:_CST20:_vICMS:TEXT)	//-- Valor ICMS
			nRedBcCalc	:= IIf(Type("oImposto:_ICMS:_CST20:_pRedBC") <> "U",Val(oImposto:_ICMS:_CST20:_pRedBC:TEXT),0)	//-- "Red.Bc.Calc."
			nIcmsSt		:= 0			//-- ICMS ST

		ElseIf Type("oImposto:_ICMS:_CST45") <> "U"
			cTipoCST	:= oImposto:_ICMS:_CST45:_CST:TEXT
			nBaseIcms	:= 0	//-- Base de Calculo
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= 0	//-- Aliquota ICMS
			nValIcms	:= 0	//-- Valor ICMS
			nRedBcCalc	:= 0	//-- "Red.Bc.Calc."
			nIcmsSt		:= 0	//-- ICMS ST
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ICMS Isento, nao Tributado ou diferido  ³
			//³ - 40: ICMS Isencao                      ³
			//³ - 41: ICMS Nao Tributada                ³
			//³ - 51: ICMS Diferido                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf Type("oImposto:_ICMS:_CST60") <> "U"
			cTipoCST	:= oImposto:_ICMS:_CST60:_CST:TEXT
			nBaseIcms	:= 0	//-- Base de Calculo
			nBaseRet	:= Val(oImposto:_ICMS:_CST60:_vBCSTRet:TEXT)	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_CST60:_pICMSSTRet:TEXT) //-- Aliquota ICMS
			nIcmsSt		:= Val(oImposto:_ICMS:_CST60:_vICMSSTRet:TEXT)	//-- ICMS ST
			nValIcms	:= 0	//-- Valor ICMS
			nRedBcCalc	:= 0	//-- "Red.Bc.Calc."

		ElseIf Type("oImposto:_ICMS:_CST90") <> "U"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ - 90: ICMS Outros                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTipoCST	:= oImposto:_ICMS:_CST90:_CST:TEXT
			nBaseIcms	:= Val(oImposto:_ICMS:_CST90:_vBC:TEXT)		//-- Base de Calculo
			nBaseRet	:= Val(oImposto:_ICMS:_CST90:_vBCSTRet:TEXT)	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_CST90:_pICMS:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_CST90:_vICMS:TEXT)		//-- Valor ICMS
			nRedBcCalc	:= IIf(Type("oImposto:_ICMS:_CST90:_pRedBC") <> "U",Val(oImposto:_ICMS:_CST90:_pRedBC:TEXT),0)		//-- "Red.Bc.Calc."
		ElseIf Type("oImposto:_ICMS:_ICMSOutraUF") <> "U"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ - 81: ICMS DEVIDOS A OUTRAS UF'S                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTipoCST	:= oImposto:_ICMS:_ICMSOutraUF:_CST:TEXT
			nBaseIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_vBCOutraUF:TEXT)		//-- Base de Calculo
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_pICMSOutraUF:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_vICMSOutraUF:TEXT)		//-- Valor ICMS
			nRedBcCalc	:= IIf(Type("oImposto:_ICMS:_ICMSOutraUF:_pRedBCOutraUF") <> "U",Val(oImposto:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT),0)	//-- "Red.Bc.Calc."

		ElseIf Type("oImposto:_ICMS:_ICMS00") <> "U" //Prestação sujeito à tributação normal do ICMS
			cTipoCST	:= oImposto:_ICMS:_ICMS00:_CST:TEXT  //classificação Tributária do Serviço 00 - tributação normal ICMS
			nBaseIcms	:= Val(oImposto:_ICMS:_ICMS00:_vBC:TEXT)		//-- Valor da BC do ICMS
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_ICMS00:_pICMS:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_ICMS00:_vICMS:TEXT)	//-- Valor ICMS
			nRedBcCalc	:= 0	//-- "Red.Bc.Calc."
		ElseIf Type("oImposto:_ICMS:_ICMS20") <> "U"	//Prestação sujeito à tributação com redução de BC do ICMS
			cTipoCST	:= oImposto:_ICMS:_ICMS20:_CST:TEXT  //classificação Tributária do Serviço 20 - tributação com BC reduzida do ICMS
			nBaseIcms	:= Val(oImposto:_ICMS:_ICMS20:_vBC:TEXT)		//-- Valor da BC do ICMS
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_ICMS20:_pICMS:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_ICMS20:_vICMS:TEXT)	//-- Valor ICMS
			nRedBcCalc	:= IIf(Type("oImposto:_ICMS:_ICMS20:_pRedBC") <> "U",Val(oImposto:_ICMS:_ICMS20:_pRedBC:TEXT),0)	//-- Percentual de redução da BC

		ElseIf Type("oImposto:_ICMS:_ICMS45") <> "U"	//ICMS  Isento, não Tributado ou diferido
			cTipoCST	:= oImposto:_ICMS:_ICMS45:_CST:TEXT  //Classificação Tributária do Serviço
			//40 - ICMS isenção;
			//41 - ICMS não tributada;
			//51 - ICMS diferido
			nBaseIcms	:= 0		//-- Valor da BC do ICMS
			nBaseRet	:= 0  		//-- Base ICMS Retido
			nAliqIcms	:= 0		//-- Aliquota ICMS
			nIcmsSt		:= 0		//-- ICMS ST
			nValIcms	:= 0 		//-- Valor ICMS
			nRedBcCalc	:= 0 		//-- Percentual de redução da BC

		ElseIf Type("oImposto:_ICMS:_ICMS60") <> "U"	//Tributação pelo ICMS60 - ICMS cobrado por substituição tributária.Responsabilidade do recolhimento do ICMS atribuído ao tomador ou 3º por ST
			cTipoCST	:= oImposto:_ICMS:_ICMS60:_CST:TEXT  //Classificação Tributária do Serviço     60 - ICMS cobrado anteriormente por substituição tributária
			If Type("oImposto:_ICMS:_ICMS60:_vBC") <> "U"
				nBaseIcms	:= Val(oImposto:_ICMS:_ICMS60:_vBC:TEXT)		//-- Valor da BC do ICMS
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_vBCSTRet") <> "U"
				nBaseRet	:= Val(oImposto:_ICMS:_ICMS60:_vBCSTRet:TEXT)	//-- Valor da BC do ICMS ST retido
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_pICMSSTRet") <> "U"
				nAliqIcms	:= Val(oImposto:_ICMS:_ICMS60:_pICMSSTRet:TEXT)		//-- Aliquota ICMS
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_vICMSSTReT") <> "U"
				nIcmsSt		:= Val(oImposto:_ICMS:_ICMS60:_vICMSSTReT:TEXT)	//-- Valor do ICMS ST retido
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_vICMS") <> "U"
				nValIcms	:= Val(oImposto:_ICMS:_ICMS60:_vICMS:TEXT)	//-- Valor ICMS
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_pRedBC") <> "U"
				nRedBcCalc	:= Val(oImposto:_ICMS:_ICMS60:_pRedBC:TEXT)	//-- Percentual de redução da BC
			Endif
			If Type("oImposto:_ICMS:_ICMS60:_vCred") <> "U"
				vCred		:= Val(oImposto:_ICMS:_ICMS60:_vCred:TEXT)	// Valor do Crédito outorgado/Presumido
			Endif
		ElseIf Type("oImposto:_ICMS:_ICMS90") <> "U"	//ICMS Outros
			cTipoCST	:= oImposto:_ICMS:_ICMS90:_CST:TEXT  //classificação Tributária do Serviço 90 - ICMS outros
			nBaseIcms	:= Val(oImposto:_ICMS:_ICMS90:_vBC:TEXT)		//-- Valor da BC do ICMS
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_ICMS90:_pICMS:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_ICMS90:_vICMS:TEXT)	//-- Valor ICMS
			nRedBcCalc	:= Iif(Type("oImposto:_ICMS:_ICMS90:_pRedBC") <> "U",Val(oImposto:_ICMS:_ICMS90:_pRedBC:TEXT),0)	//-- Percentual de redução da BC
			If Type("oImposto:_ICMS:_ICMS90:_vCred") <> "U"
				vCred		:= Val(oImposto:_ICMS:_ICMS90:_vCred:TEXT)	// Valor do Crédito outorgado/Presumido
			Endif
		ElseIf Type("oImposto:_ICMS:_ICMSOutraUF") <> "U"	//ICMS devido à UF de origem da prestação, quando  diferente da UF do emitente
			cTipoCST	:= oImposto:_ICMS:_ICMSOutraUF:_CST:TEXT  //classificação Tributária do Serviço 90 - ICMS outros
			nBaseIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_vBCOutraUF:TEXT)		//-- Valor da BC do ICMS
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_pICMSOutraUF:TEXT)		//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= Val(oImposto:_ICMS:_ICMSOutraUF:_vICMSOutraUF:TEXT)	//-- Valor do ICMS devido outra UF
			nRedBcCalc	:= IIf(Type("oImposto:_ICMS:_ICMSOutraUF:_predBCOutraUF") <> "U",Val(oImposto:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT),0)	//-- Percentual de redução da BC

		ElseIf Type("oImposto:_ICMS:_ICMSSN") <> "U"
			cTipoCST	:= ""
			nBaseIcms	:= 0	//-- Base de Calculo
			nBaseRet	:= 0	//-- Base ICMS Retido
			nAliqIcms	:= 0	//-- Aliquota ICMS
			nIcmsSt		:= 0	//-- ICMS ST
			nValIcms	:= 0	//-- Valor ICMS
			nRedBcCalc	:= 0	//-- "Red.Bc.Calc."
		Endif
	EndIf

	//contribuinte = PJ com inscrição estadual	ou seja, tem o numero de inscrição valido
	//não contribuinte = PJ sem inscrição estadual ou PF	ou seja: inscrição = "0" ou ISENTO


	//Destino	contribuinte %		Origem	não contribuinte%
	//Por padrão o Sistema aplica automaticamente as alíquotas interestaduais para contribuintes de ICMS. Caso a operação seja destinada a um não contribuinte de ICMS, será considerada a alíquota interna do estado de origem. Caso o padrão não atenda a sua necessidade, o Sistema realiza a seguinte verificação:
	// 1º) A primeira verificação é referente a Exceção Fiscal. Caso haja uma Exceção Fiscal amarrada a operação, o Sistema considera o campo Aliq.externa (F7_ALIQEXT) para contribuintes e não contribuintes de ICMS.
	// 2º) Após a primeira verificação, caso seja um não contribuinte, o Sistema aplica a alíquota  Aliq. ICMS (B1_PICM). Caso não esteja preenchido verifica o parâmetro MV_ICMPAD na saída e MV_ESTICM na entrada.
	// 3º) Caso seja contribuinte, o Sistema verifica o parâmetro MV_NORTE, e caso o estado de destino esteja preenchido no parâmetro, será considerada a alíquota de 7%.
	// 4º ) Caso não atenda as condições anteriores, são consideradas as alíquotas internas do Microsiga Protheus.
	//Observações:
	//O Sistema considera não contribuinte na saída, quando o cliente possui ou não Inscrição Estadual, porém o campo Contribuinte (A1_CONTRIB) deve ser informado como = NÃO.
	//Para entrada é considerado o parâmetro MV_SM0CONT = 2;

	If cTipCte == 'V'
		DbSelectArea("SA1")
		DbSetOrder(3)
		DbSeek(xFilial("SA1")+cInCNPJ)

		If SA1->A1_CONTRIB $ " #1" .And. Len(Alltrim(SA1->A1_CGC)) == 14 .And. !Alltrim(Upper(SA1->A1_INSCR)) $"ISENTO#ISENTA#0#.#0" .And. IE(SA1->A1_INSCR,SA1->A1_EST)
			// Se o estado de destino é igual a origem
			If cUfIni == cUfFim //SA1->A1_EST == cMVESTADO
				// Quando destinatário for do próprio estado
				If cUfIni $ GetNewPar("XM_CTEICMN","PR#RS")
					// e os estados tem isenção do ICMS sobre frete para destino no mesmo estado
					nPerIcm     := 0
				Else
					cMVESTICM	:= GetNewPar("XM_ICMCONT",cMVESTICM)
					nPerIcm 	:= Val(Substr(cMVESTICM,AT(cUfFim,cMVESTICM)+2,2))
				Endif
			Else
				// Icms para os estados do Norte
				If cUfFim $ cMVNORTE
					nPerIcm		:= 7
				Else
					nPerIcm 	:= 12
				Endif
			Endif

			cTipoCli	+= "Destinatário é Contribuinte: De '"+cUfIni+"' para '"+cUfFim+"' "
		Else
			cMVESTICM	:= GetNewPar("XM_ICMNCON",cMVESTICM)
			cTipoCli	+= "Destinatário não é Contribuinte: De '"+cUfIni+"' para '"+cUfFim+"' "

			// Quando destinatário for do próprio estado e os estados tem isenção do ICMS sobre frete para destino no mesmo estado
			If cUfFim == cUfIni .And. cUfIni $ GetNewPar("XM_CTEICMN","PR#RS")
				nPerIcm 	:= 0
			Else
				nPerIcm 	:= Val(Substr(cMVESTICM,AT(cUfIni,cMVESTICM)+2,2))
			Endif

		Endif
		// Se a mercadoria Transportada não tiver incidência de ICMS
		If !(cTipoCST $ "00/20/90/81")
			nPerIcm := 0
		Endif
	ElseIf cTipCte == 'C'
		DbSelectArea("SA2")
		DbSetOrder(3)
		DbSeek(xFilial("SA2")+cInCNPJ)

		If GetMv("MV_SM0CONT") == "1"
			// Se o estado de destino é igual a origem
			If cUfIni == cUfFim //SA1->A1_EST == cMVESTADO
				// Quando destinatário for do próprio estado
				If cUfIni $ GetNewPar("XM_CTEICMN","PR#RS")
					// e os estados tem isenção do ICMS sobre frete para destino no mesmo estado
					nPerIcm     := 0
				Else
					cMVESTICM	:= GetNewPar("XM_ICMCONT",cMVESTICM)
					nPerIcm 	:= Val(Substr(cMVESTICM,AT(cUfFim,cMVESTICM)+2,2))
				Endif
			Else
				If SA2->A2_EST $ cMVNORTE
					nPerIcm		:= 7
				Else
					nPerIcm 	:= 12
				Endif
			Endif
		Else
			cMVESTICM	:= GetNewPar("XM_ICMNCON",cMVESTICM)
			nPerIcm 	:= Val(Substr(cMVESTICM,AT(cUfIni,cMVESTICM)+2,2))
		Endif
		If !(cTipoCST $ "00/20/90/81")
			nPerIcm := 0
		Endif
	Endif
	// Alimenta um vetor que irá ser usado no PE MT103DNF para exibir o imposto do XML contra o imposto da NFe/CTe
	aInfIcmsCte	:= {}
	If nValIcms > 0 .Or. nBaseIcms > 0 
		Aadd(aInfIcmsCte,{"ICM","ICMS",nBaseIcms,nAliqIcms,nValIcms})
	Endif
	If nIcmsSt > 0 .Or. nBaseRet > 0
		Aadd(aInfIcmsCte,{"ICR","ICMS Retido",nBaseRet,nAliqIcms,nIcmsSt})
	Endif

	If !lAutoExec
		If lExibeMsg
			MsgAlert("Demonstrativo do CTe " +Chr(13)+Chr(10)+;
			"CST do ICMS: " +cTipoCST	+Chr(13)+Chr(10)+;
			"Base de Calculo :" +Transform(nBaseIcms ,"@E 999,999.99")	+Chr(13)+Chr(10)+;//-- Base de Calculo
			"Base ICMS Retido:" +Transform(nBaseRet  ,"@E 999,999.99")	+Chr(13)+Chr(10)+;//-- Base ICMS Retido
			"Aliquota ICMS   :" +Transform(nAliqIcms ,"@E 999,999.99")	+Chr(13)+Chr(10)+;	//-- Aliquota ICMS
			"ICMS ST         :" +Transform(nIcmsSt	  ,"@E 999,999.99")	+Chr(13)+Chr(10)+;	//-- ICMS ST
			"Valor ICMS      :" +Transform(nValIcms  ,"@E 999,999.99")	+Chr(13)+Chr(10)+;	//-- Valor ICMS
			"Red.Bc.Calculo  :" +Transform(nRedBcCalc,"@E 999,999.99")	+Chr(13)+Chr(10)+;	//-- "Red.Bc.Calc."
			"UF de Origem    :" +cUfIni		+Chr(13)+Chr(10)+;	
			"UF de Destino   :" +cUfFim	    +Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
			"Aliquota Calculada " +Transform(nPerIcm,"@E 999.99")+Chr(13)+Chr(10)+cTipoCli,ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Validação Icms no CTE")
		Endif
		lRet	:= .T.
	Else
		If nAliqIcms <> nPerIcm
			//lRet	:= .F.
			lRet	:= sfAtuXmlOk("AL") 
		Endif
	Endif
	RestArea(aAreaOld)

Return lRet

/*/{Protheus.doc} sfVldCliFor
(Localiza código e loja de cliente/fornecedor validos Caso tenha mais de um exibe tela para escolha   )
@author MarceloLauschner
@since 15/09/2013
@version 1.0
@param cAlias, character, (Descrição do parâmetro)
@param cCodigo, character, (Descrição do parâmetro)
@param cLoja, character, (Descrição do parâmetro)
@param cInNomFor, character, (Descrição do parâmetro)
@param lAtuGrvXml, ${param_type}, (Descrição do parâmetro)
@param cInTpDoc, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfVldCliFor(cAlias, cCodigo, cLoja,cInNomFor,lAtuGrvXml,cInTpDoc )

	Local		aAreaOld		:= GetArea()
	Local 		cSeek      	:= ""
	Local 		lRet       	:= .T.
	Local 		lMsBlqL    	:= .F.
	Local 		lMsBlqD    	:= .F.
	Local 		lBloqueado 	:= .F.
	Local		nOpcForn		:= 0
	Default	lAtuGrvXml		:= .T.


	// Zero variável
	aOpcForn	:= {}

	If cAlias == 'SA1'
		lMsBlqL := (SA1->(FieldPos("A1_MSBLQL")) > 0)
		lMsBlqD := (SA1->(FieldPos("A1_MSBLQD")) > 0)
		lBloqueado := .F.

		cSeek      := xFilial('SA1')+ SA1->A1_CGC
		DbSelectArea("SA1")
		DbSetOrder(3)
		DbSeek(cSeek)
		bWhile := {|| SA1->A1_FILIAL+SA1->A1_CGC == cSeek}

		While !Eof() .And. Eval(bWhile)

			If lMsBlqD .And. (!Empty(SA1->A1_MSBLQD) .And. SA1->A1_MSBLQD < dDataBase) // Esta com bloqueio temporal
				lBloqueado := .T.
				SA1->(dbSkip())
				Loop
			Else
				lBloqueado := .F.
			EndIf
			If lMsBlqL .And. SA1->A1_MSBLQL == '1' // Esta com bloqueio logico
				lBloqueado := .T.
				SA1->(dbSkip())
				Loop
			Else
				lBloqueado := .F.
			EndIf
			If !lBloqueado
				cCodigo := SA1->A1_COD
				cLoja   := SA1->A1_LOJA
				Aadd(aOpcForn,{cCodigo,cLoja,SA1->A1_NOME,SA1->A1_ULTCOM})
			EndIf
			SA1->(dbSkip())
		EndDo

		lRet := !lBloqueado

		// Se houver mais de um fornecedor e se tratar da customização da madeiramadeira, avalia fornecedor pelo pedido de compra do corpo do email
		If Len(aOpcForn) > 1 .And. Type("lMadeira") == "L" .And. lMadeira .And. !cInTpDoc $ "F#T"
			sfFindSA2(@cCodigo,@cLoja,@nOpcForn)
		ElseIf Len(aOpcForn) > 1

			DEFINE MSDIALOG oDlgA2 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione um código e loja de Cliente '"+cInNomFor+"'") FROM 09,00 TO 28,80

			@ 005,004 Say " Selecione um código e loja de Cliente para '"+cInNomFor+"'" Pixel Of oDlgA2
			@ 018,004 LISTBOX oOpcForn FIELDS TITLE OemtoAnsi("Código"),OemtoAnsi("Loja"),OemToAnsi("Razão Social"),OemToAnsi("Última Compra") SIZE 310,100 PIXEL Of oDlgA2
			oOpcForn:SetArray(aOpcForn)
			oOpcForn:bLine := {|| aOpcForn[oOpcForn:nAt] }


			DEFINE SBUTTON FROM 130 ,280 TYPE 1 PIXEL ACTION (nOpcForn	:= oOpcForn:nAt, oDlgA2:End()) ENABLE OF oDlgA2 Pixel

			ACTIVATE MSDIALOG oDlgA2 CENTERED

			If nOpcForn > 0
				cCodigo := aOpcForn[nOpcForn,1]
				cLoja   := aOpcForn[nOpcForn,2]
			Endif
		ElseIf Len(aOpcForn) == 1
			nOpcForn := 1
		Endif
		// Efetua gravação do conteúdo
		If lAtuGrvXml
			If nOpcForn > 0 .And. (Empty(CONDORXML->XML_CODLOJ) .Or. cCodigo+cLoja<>CONDORXML->XML_CODLOJ)
				DbSelectArea("CONDORXML")
				RecLock("CONDORXML",.F.)
				CONDORXML->XML_CODLOJ	:= cCodigo+cLoja
				MsUnlock()

			Endif
		Endif
	ElseIf cAlias == 'SA2'

		lMsBlqL := (SA2->(FieldPos("A2_MSBLQL")) > 0)
		lMsBlqD := (SA2->(FieldPos("A2_MSBLQD")) > 0)
		lBloqueado := .F.

		cSeek      := xFilial('SA2')+ SA2->A2_CGC
		DbSelectArea("SA2")
		DbSetOrder(3)
		DbSeek(cSeek)
		bWhile := {|| SA2->A2_FILIAL+SA2->A2_CGC == cSeek}

		While !Eof() .And. Eval(bWhile)

			If lMsBlqD .And. (!Empty(SA2->A2_MSBLQD) .And. SA2->A2_MSBLQD < dDataBase) // Esta com bloqueio temporal
				lBloqueado := .T.
				SA2->(dbSkip())
				Loop
			Else
				lBloqueado := .F.
			EndIf
			If lMsBlqL .And. SA2->A2_MSBLQL == '1' // Esta com bloqueio logico
				lBloqueado := .T.
				SA2->(dbSkip())
				Loop
			Else
				lBloqueado := .F.
			EndIf
			If !lBloqueado
				cCodigo := SA2->A2_COD
				cLoja   := SA2->A2_LOJA
				Aadd(aOpcForn,{cCodigo,cLoja,SA2->A2_NOME,SA2->A2_ULTCOM})
			EndIf
			SA2->(dbSkip())
		EndDo
		lRet := !lBloqueado

		// Se houver mais de um fornecedor e se tratar da customização da madeiramadeira, avalia fornecedor pelo pedido de compra do corpo do email
		If Len(aOpcForn) > 1 .And. Type("lMadeira") == "L" .And. lMadeira .And. !cInTpDoc $ "F#T"
			sfFindSA2(@cCodigo,@cLoja,@nOpcForn)
		ElseIf Len(aOpcForn) > 1

			DEFINE MSDIALOG oDlgA2 TITLE OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione um código e loja de Fornecedor '"+cInNomFor+"'") FROM 09,00 TO 28,80
			@ 005,004 Say " Selecione um código e loja de Fornecedor para '"+cInNomFor+"'" Pixel Of oDlgA2
			@ 018,004 LISTBOX oOpcForn FIELDS TITLE OemtoAnsi("Código"),OemtoAnsi("Loja"),OemToAnsi("Razão Social"),OemToAnsi("Última Compra") SIZE 310,100 PIXEL Of oDlgA2
			oOpcForn:SetArray(aOpcForn)
			oOpcForn:bLine := {|| aOpcForn[oOpcForn:nAt] }

			DEFINE SBUTTON FROM 130 ,280 TYPE 1 PIXEL ACTION (nOpcForn	:= oOpcForn:nAt, oDlgA2:End()) ENABLE OF oDlgA2 Pixel

			ACTIVATE MSDIALOG oDlgA2 CENTERED

			If nOpcForn > 0
				cCodigo := aOpcForn[nOpcForn,1]
				cLoja   := aOpcForn[nOpcForn,2]
			Endif

		ElseIf Len(aOpcForn) == 1
			nOpcForn := 1
		Endif
		// Efetua gravação do conteúdo
		If lAtuGrvXml
			DbSelectArea("CONDORXML")
			If nOpcForn > 0 .And. (Empty(CONDORXML->XML_CODLOJ) .Or. cCodigo+cLoja<>CONDORXML->XML_CODLOJ)
				RecLock("CONDORXML",.F.)
				CONDORXML->XML_CODLOJ	:= cCodigo+cLoja
				MsUnlock()
			Endif

			// Tratativa nova em 26/04/2014 para efetuar o ajuste do cadastro do fornecedor com dados sobre Simples Nacional ou não.
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(xFilial("SA2")+cCodigo+cLoja)
				// Se existir o campo
				If SA2->(FieldPos("A2_SIMPNAC")) > 0
					// Se 3 – Regime Normal. (v2.0)
					If At("<CRT>3</CRT>",CONDORXML->XML_ARQ) > 0
						// E encontrado com Simples Nacional 1=Sim
						If SA2->A2_SIMPNAC $"1"
							sfAtuXmlOk("SN"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,;
							"O fornecedor '"+SA2->A2_COD+"/"+SA2->A2_LOJA+"-"+ Alltrim(SA2->A2_NOME) + "' está cadastrado como Optante do Simples Nacional, porém consta na nota '"+CONDORXML->XML_NUMNF+"' que está enquadrado como 3-Regime Normal."/*cMsgAux*/,;
							/*nLinXml*/,CONDORXML->XML_CHAVE/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"A2_SIMPNAC"/*cInCpoAlt*/,SA2->A2_SIMPNAC/*cInVlAnt*/,"2"/*cInVlNew*/)
		
							If !lAutoExec .And. GetNewPar("XM_VLA2SMP",.T.) 
								If MsgYesNo("O fornecedor '"+SA2->A2_COD+"/"+SA2->A2_LOJA+"-"+ Alltrim(SA2->A2_NOME) + "' está cadastrado como Optante do Simples Nacional, porém consta na nota '"+CONDORXML->XML_NUMNF+"' que está enquadrado como 3-Regime Normal. Deseja fazer a atualização no cadastro do fornecedor agora?","'XMLDCONDOR.PRW.sfVldCliFor' - Simples Nacional")
									RecLock("SA2",.F.)
									SA2->A2_SIMPNAC	:= "2" // 2=Não
									MsUnlock()
								Endif
							Endif
						Endif
						// 1 – Simples Nacional / 2 – Simples Nacional – excesso de sublimite de receita bruta;
					ElseIf At("<CRT>2</CRT>",CONDORXML->XML_ARQ) > 0 .Or. At("<CRT>1</CRT>",CONDORXML->XML_ARQ) > 0
						// E encontrado como Normal
						If SA2->A2_SIMPNAC $" 2"
							sfAtuXmlOk("SN"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,;
							"O fornecedor '"+SA2->A2_COD+"/"+SA2->A2_LOJA+"-"+ Alltrim(SA2->A2_NOME) + "' está cadastrado como Regime Normal, porém consta na nota '"+CONDORXML->XML_NUMNF+"' que está enquadrado como Optante do Simples Nacional"/*cMsgAux*/,;
							/*nLinXml*/,CONDORXML->XML_CHAVE/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"A2_SIMPNAC"/*cInCpoAlt*/,SA2->A2_SIMPNAC/*cInVlAnt*/,"1"/*cInVlNew*/)
		
							If !lAutoExec .And. GetNewPar("XM_VLA2SMP",.T.) 
								If MsgYesNo("O fornecedor '"+SA2->A2_COD+"/"+SA2->A2_LOJA+"-"+ Alltrim(SA2->A2_NOME) + "' está cadastrado como Regime Normal, porém consta na nota '"+CONDORXML->XML_NUMNF+"' que está enquadrado como Optante do Simples Nacional. Deseja fazer a atualização no cadastro do fornecedor agora?","'XMLDCONDOR.PRW.sfVldCliFor' - Simples Nacional")
									RecLock("SA2",.F.)
									SA2->A2_SIMPNAC	:= "1" // 1=Sim
									MsUnlock()
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	EndIf

	RestArea(aAreaOld)

Return lRet


/*/{Protheus.doc} sfFindSA2
(Procura fornecedor único baseado em pedidos de compra informados no corpo do e-mail     )
@author MarceloLauschner
@since 15/09/2013
@version 1.0
@param cCodigo, character, (Descrição do parâmetro)
@param cLoja, character, (Descrição do parâmetro)
@param nOpcForn, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfFindSA2(cCodigo,cLoja,nOpcForn)

	Local		cListSC7    	:= ""
	Local		aListSC7    	:= {}
	Local		lAddSC7			:= .F.
	Local		cQry			:= ""
	Local		i7
	Local		iA2
	Local		iZ


	If At("#",CONDORXML->XML_BODY) > 0
		cListSC7	:= CONDORXML->XML_BODY+"#"
		aListSC7	:= StrTokArr(cListSC7,"#")
		lAddSC7		:= .F.
		cQry := "SELECT C7_FORNECE,C7_LOJA"
		cQry += "  FROM "+RetSqlName("SC7") + " C7 "
		cQry += " WHERE C7.D_E_L_E_T_ = ' ' "
		cQry += "   AND C7_FILIAL = '"+xFilial("SC7")+"' "
		For i7 := 1 To Len(aListSC7)
			If !Empty(aListSC7[i7])
				DbSelectArea("SC7")
				DbSetOrder(1)
				If DbSeek(xFilial("SC7")+Alltrim(aListSC7[i7]))
					If !lAddSC7
						cQry += "   AND C7_NUM IN('"+SC7->C7_NUM+"'"
					Else
						cQry += ",'"+SC7->C7_NUM+"'"
					Endif
					lAddSC7	:= .T.
				Endif
			Endif
		Next
		If lAddSC7
			cQry += ")"
		Endif
		lAddSC7	:= .F.
		For iA2 := 1 To Len(aOpcForn)
			If !lAddSC7
				If Upper(TcGetDb()) $ "MSSQL"
					cQry += "   AND C7_FORNECE+C7_LOJA IN('"+aOpcForn[iA2,1]+aOpcForn[iA2,2]+"'"
				Else
					cQry += "   AND (C7_FORNECE,C7_LOJA) IN(('"+aOpcForn[iA2,1]+"','"+aOpcForn[iA2,2]+"')"
				Endif
			Else
				If Upper(TcGetDb()) $ "MSSQL"
					cQry += ",'"+aOpcForn[iA2,1]+aOpcForn[iA2,2]+"'"
				Else
					cQry += ",('"+aOpcForn[iA2,1]+"','"+aOpcForn[iA2,2]+"')"
				Endif
			Endif
			lAddSC7	:= .T.
		Next
		If lAddSC7
			cQry += ")"
		Endif
		cQry += " GROUP BY C7_FORNECE,C7_LOJA"

		TcQuery cQry New Alias "QRA2"
		If !Eof()
			cCodigo 	:= QRA2->C7_FORNECE
			cLoja		:= QRA2->C7_LOJA
			For iZ := 1 To Len(aOpcForn)
				If aOpcForn[iZ,1]+aOpcForn[iZ,2] == cCodigo+cLoja
					nOpcForn	:= iZ
					Exit
				Endif
			Next
		Endif
		QRA2->(DbCloseArea())
	Endif

Return


/*/{Protheus.doc} sfVldCfop
(Auxilio na validação por CFOP Entrada X Saída )
@author MarceloLauschner
@since 07/11/2013
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfVldCfop(cVldCfop)

	Local	lRet		:= .F.
	Local	iX,iR
	Local	nContErr	:= 0
	Local	aCfoX_CF	:= {}
	Local	aCfoPad	:= {;
	{"5101","1102","Venda de produção do estabelecimento"},;
	{"5101","1101","Venda de produção do estabelecimento"},;
	{"6101","2102","Venda de produção do estabelecimento"},;
	{"5102","1102","Venda de mercadoria adquirida ou recebida de terceiros"},;
	{"5102","1403","Venda de mercadoria adquirida ou recebida de terceiros"},;
	{"6102","2102","Venda de mercadoria adquirida ou recebida de terceiros"},;
	{"5401","1403","Venda de produção do estabelecimento quando o produto esteja sujeito ao regime de substituição tributária"},;
	{"6401","2403","Venda de produção do estabelecimento quando o produto esteja sujeito ao regime de substituição tributária"},;
	{"5403","1403","Venda de mercadoria, adquirida ou recebida de terceiros, sujeita ao regime de substituição tributária, na condição de contribuinte-substituto"},;
	{"6403","2403","Venda de mercadoria, adquirida ou recebida de terceiros, sujeita ao regime de substituição tributária, na condição de contribuinte-substituto"},;
	{"5405","1403","Venda de mercadoria, adquirida ou recebida de terceiros, sujeita ao regime de substituição tributária, na condição de contribuinte-substituído"},;
	{"6404","2403","Venda de mercadoria sujeita ao regime de substituição tributária, cujo imposto já tenha sido retido anteriormente"},;
	{"5910","1910","Remessa em bonificação, doação ou brinde"},;
	{"6910","2910","Remessa em bonificação, doação ou brinde"},;
	{"5911","1911","Remessa de amostra grátis"},;
	{"6911","2911","Remessa de amostra grátis"},;
	{"5912","1912","Remessa de mercadoria ou bem para demonstração"},;
	{"6912","2912","Remessa de mercadoria ou bem para demonstração"},;
	{"5118","1403","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem "},;
	{"6118","2403","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem "},;
	{"5118","1102","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem "},;
	{"6118","2102","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem "},;
	{"5119","1403","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"6119","2403","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"5119","1102","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"6119","2102","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"5120","1118","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário pelo vendedor remetente, em venda à ordem"},;
	{"6120","2118","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário pelo vendedor remetente, em venda à ordem"},;
	{"5923","1923","Remessa de mercadoria por conta e ordem de terceiros, em venda à ordem ou em operações com armazém geral ou depósito fechado"},;
	{"6923","2923","Remessa de mercadoria por conta e ordem de terceiros, em venda à ordem ou em operações com armazém geral ou depósito fechado"},;
	{"5924","1924",""},;
	{"6924","2924",""},;
	{"5922","1922","Lançamento efetuado a título de simples faturamento decorrente de venda para entrega futura"},;
	{"6922","2922","Lançamento efetuado a título de simples faturamento decorrente de venda para entrega futura"},;
	{"5116","1117","Venda de produção do estabelecimento originada de encomenda para entrega futura"},;
	{"6116","2117","Venda de produção do estabelecimento originada de encomenda para entrega futura"},;
	{"5117","1117","Venda de mercadoria adquirida ou recebida de terceiros, originada de encomenda para entrega futura"},;
	{"6117","2117","Venda de mercadoria adquirida ou recebida de terceiros, originada de encomenda para entrega futura"},;
	{"5119","1119","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"6119","2119","Venda de mercadoria adquirida ou recebida de terceiros entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"5118","1117","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"6118","2117","Venda de produção do estabelecimento entregue ao destinatário por conta e ordem do adquirente originário, em venda à ordem"},;
	{"5949","1949","Outra saída de mercadoria ou prestação de serviço não especificado"},;
	{"6949","2949","Outra saída de mercadoria ou prestação de serviço não especificado"},;
	{"5917","1917","Remessa de mercadoria em consignação mercantil ou industrial"},;
	{"6917","2917","Remessa de mercadoria em consignação mercantil ou industrial"},;
	{"5907","1906",""},;
	{"5664","1664",""},;
	{"6652","2652",""},;
	{"5652","1652",""},;
	{"6655","2652","VENDA COMB/LUBRIFICANTE ADQ TERCEIROS DEST COMERCI."},;
	{"6659","2659",""},;
	{"5411","1411",""},;
	{"5202","1202",""},;
	{"5902","1902",""},;
	{"5906","1906",""},;
	{"5916","1916","RETORNO DE MERCADORIA OU BEM PARA CONSERTO OU REPARO   "},;
	{"6557","2557","TRANSFERENCIA DE MATERIAL DE USO OU CONSUMO "},;
	{"5663","1663","REMESSA PARA ARMAZENAGEM DE COMBUSTIVEIS/LUBRIFICANTES"},;
	{"6152","2152","TRANSF MERCADORIAS ADQUIRIDAS E/OU RECEBIDAS TERCEIROS "},;
	{"6101","2403",""},;
	{"5905","1905",""},;
	{"5655","1652","VENDA COMB/LUBRIFICANTE ADQ TERCEIROS DEST COMERCI."},;
	{"5402","1403","Venda de mercadoria, adquirida ou recebida de terceiros, sujeita ao regime de substituição tributária, na condição de contribuinte-substituto"},;
	{"6402","2403","Venda de mercadoria, adquirida ou recebida de terceiros, sujeita ao regime de substituição tributária, na condição de contribuinte-substituto"},;
	{"5112","1113","Venda de mercadoria adquirida ou recebida de terceiros remetida anteriormente em consignação industrial"},;
	{"6112","2113","Venda de mercadoria adquirida ou recebida de terceiros remetida anteriormente em consignação industrial"},;
	{"5113","1113","Venda de produção do estabelecimento remetida anteriormente em consignação mercantil"},;
	{"6113","2113","Venda de produção do estabelecimento remetida anteriormente em consignação mercantil"},;
	{"6102","2403","Tratamento especial RC"},;
	{"5118","1118","Venda a ordem"},;
	{"5901","1901","REMESSA PARA INDUSTRIALIZACAO POR ENCOMENDA            "},;
	{"5902","1902","RETORNO DE MERC. UTILIZ. INDUSTRIALIZACAO P/ ENCOMENDA "},;
	{"6118","2118","Venda a ordem"}}

	U_DbSelArea("CONDORCONVCFOP",.F.,1)
	DbGotop()
	While !Eof()
		Aadd(aCfoX_CF,{;
		CONDORCONVCFOP->XCF_CFSAI,;
		CONDORCONVCFOP->XCF_CFENT,;
		CONDORCONVCFOP->XCF_DESCS,;
		CONDORCONVCFOP->XCF_DESCE,;
		.F.})
		DbSelectArea("CONDORCONVCFOP")
		DbSkip()
	Enddo
	// Caso não existam dados vindos da Tabela, assume o array pré-configurado
	If Empty(aCfoX_CF)
		aCfoX_CF	:= aClone(aCfoPad)
	Endif

	// Percorre todas as linhas
	For iR := 1 To Len(oMulti:aCols)
		// 28/11/2014 - Adicionada condição se o CFOP de entrada estiver preenchido para validar - pois pré-nota não existe TES ainda para validar correlação
		If !oMulti:aCols[iR,Len(oMulti:aHeader)+1] .And. !Empty(oMulti:aCols[iR,nPxCF])
			lRet	:= .F.
			For iX := 1 To Len(aCfoX_CF)
				// Somente se o CFOP de entrada e o CFOP do XML estiverem na correlação
				If Alltrim(oMulti:aCols[iR,nPxCFNFe]) == Alltrim(aCfoX_CF[iX,1]) .And. Alltrim(oMulti:aCols[iR,nPxCF]) == Alltrim(aCfoX_CF[iX,2])
					lRet	:= .T.
					Exit
				Endif
			Next
			If !lRet
				cVldCfop	+= "CFOP XML:"+Alltrim(oMulti:aCols[iR,nPxCFNFe]) + " CFOP NFe:"+Alltrim(oMulti:aCols[iR,nPxCF])+ Chr(13)+ Chr(10)

				U_DbSelArea("CONDORXML",.F.,1)
				DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
				If sfAtuXmlOk("CF",.T.,oMulti:aCols[iR,nPxItem],"CFOP XML:"+Alltrim(oMulti:aCols[iR,nPxCFNFe]) + CRLF + "CFOP NFe:"+Alltrim(oMulti:aCols[iR,nPxCF]) + CRLF ,/*nLinXml*/,/*cInChave*/,/*lAtuOk*/,/*cInAssunto*/,/*cDestMail*/,"D1_CF"/*cInCpoAlt*/,Alltrim(oMulti:aCols[iR,nPxCFNFe])/*cInVlAnt*/,Alltrim(oMulti:aCols[iR,nPxCF])/*cInVlNew*/)		
					nContErr++
				Endif
			Endif
		Endif
	Next
	// Retorna verdadeiro se o número de erros for zero
Return (nContErr == 0)



/*/{Protheus.doc} sfVldIE
(Validação da inscrição estadual - Permite validar Exato/Contém/Somente números)
@author MarceloLauschner
@since 02/12/2014
@version 1.0
@param cInIEXml, character, (Descrição do parâmetro)
@param cInIECad, character, (Descrição do parâmetro)
@param cInUF, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfVldIE(cInIEXml,cInIECad,cInUF)

	Local		lRet		:= .T.
	Local		cVldInsc	:= GetNewPar("XM_VLDINSC","E")
	Local		cVarAux	:= ""
	Local		nQ

	If Substr(Upper(cInIECad),1,5) == "ISENT" .And. (Substr(Upper(cInIEXml),1,5) == "ISENT" .Or. Empty(cInIEXml))
		lRet	:= .T.
	// Se for exterior não valido IE
	ElseIf cInUF == "EX"
		lRet	:= .T.
		// E=Exatamente o conteúdo do XML com a IE do cadastro
	ElseIf  cVldInsc == "E"
		lRet	:= Alltrim(cInIEXml) == Alltrim(cInIECad)
		// S=Somente numeros da IE do cadastro ( /-. )  ( 002/24252627 fica 00224252627 )
	ElseIf cVldInsc == "S"
		For nQ := 1 To Len(cInIECad) Step 1
			If IsDigit(Substr(cInIECad,nQ,1))
				cVarAux += Substr(cInIECad,nQ,1)
			Endif
		Next
		lRet := IE(cVarAux,cInUF)
		If lRet
			lRet := Alltrim(cInIEXml) $ cVarAux
		Endif
		// C=Contém expressão do valor do XML dentro da IE do Cadastro ( xml=224252627 IE=00224252627 )
	ElseIf cVldInsc == "C"
		lRet	:= Alltrim(cInIEXml) $ Alltrim(cInIECAd)
		// 	X=Contém expressão da IE do Cadastro dentro do valor do XML ( IE=224252627 xml=00224252627 )
	ElseIf cVldInsc == "X"
		lRet	:= Alltrim(cInIEXml) $ Alltrim(cInIECAd)
	Endif

Return lRet



/*/{Protheus.doc} sfConCT2
(Consulta para abrir rotina de lançamento contábil baseado no rastreamento contábil)
@type function
@author marce
@since 19/06/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfConCT2(lExterno)

	Local	aRecSD1		:= {}
	Local	aAreaOld	:= GetArea()
	Local	lCont		:= .T.
	Local	aItens		:= {}
	Local	aCab		:= {}
	Local	aMenuUsr	:= {}
	Local	lAcessCtb	:= .F.
	Local	nTmRecOri	:= TamSX3("CTK_RECORI")[1]
	Local	iZ
	Default	lExterno	:= .T.

	PswOrder(1) 		// Ordena arquivo de senhas por ID do usuario
	PswSeek(__cUserID) 	// Pesquisa usuario corrente
	aMenuUsr	:= PswRet()

	For iZ := 1 To Len(aMenuUsr[3])
		If Substr(aMenuUsr[3,iZ],1,2) == "34"
			lAcessCtb	:= .T.
			Exit
			//[3]       A    Vetor contendo o módulo, o nível e o menu do usuário. 
			//Ex: [3][1] = "019\sigaadv\sigaatf.xnu"
			//[3][2] = "029\sigaadv\sigacom.xnu"
		Endif
	Next

	If !lAcessCtb
		MsgAlert("Usuário sem acesso módulo CTB - Contabilidade Gerencial",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem permissão!")
		RestArea(aAreaOld)
		Return
	Endif

	If !lExterno
		U_DbSelArea("CONDORXML",.F.,1)

		If DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
			If CONDORXML->XML_DEST == SM0->M0_CGC
				DbSelectArea("SF1")
				DbSetOrder(1)
				If DbSeek(CONDORXML->XML_KEYF1)
					If Empty(SF1->F1_DTLANC)
						MsgAlert("Nota fiscal não tem flag de data de lançamento contábil.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Sem registro de contabilização")
						RestArea(aAreaOld)
						Return
					Endif
				Else
					MsgAlert("Documento que não foi lançado não tem contabilização.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + " Sem registro de contabilização")
					lCont	:= .F.
				Endif
			Else
				MsgAlert("Documento não pertence a Empresa/Filial posicionada.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + " Sem registro de contabilização")
				lCont	:=	.F.
			Endif
		Else
			lCont	:= .F.
		Endif

		If !lCont
			RestArea(aAreaOld)
			Return
		Endif
	Endif

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !Eof() .And. xFilial("SD1") == SD1->D1_FILIAL .And. SD1->D1_DOC == SF1->F1_DOC .And. ;
	SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. ;
	SD1->D1_LOJA == SF1->F1_LOJA
		Aadd(aRecSD1,SD1->(Recno()))
		dbSelectArea("SD1")
		dbSkip()
	EndDo

	cQry := "SELECT CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_FILIAL,CT2_LINHA,CT2_MOEDLC,CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,"
	cQry += "        CT2_ORIGEM,CT2_HIST,CT2_CLVLDB,CT2_CLVLCR,CT2_CCC,CT2_CCD "
	cQry += "  FROM "+RetSqlName("CT2") + " CT2 "
	cQry += " WHERE (R_E_C_N_O_ IN(SELECT CTK_RECDES "
	cQry += "                       FROM "+RetSqlName("CTK") + " CTK "
	cQry += "                      WHERE CTK_LOTE = '8810' "
	cQry += "                        AND CTK_FILIAL = '"+xFilial("CTK")+"' "
	cQry += "                        AND CTK_DATA = '"+DTOS(SF1->F1_DTLANC)+"' "
	cQry += "                        AND D_E_L_E_T_ = ' ' "
	cQry += "                        AND CTK_RECDES != ' ' "
	cQry += "                        AND CTK_TABORI = 'SF1' "
	cQry += "                        AND CTK_RECORI = '"+ Padr(Alltrim(cValToChar(SF1->(Recno()))),nTmRecOri)+ "') "
	cQry += "    OR R_E_C_N_O_ IN(SELECT CTK_RECDES "
	cQry += "                       FROM "+RetSqlName("CTK") + " CTK "
	cQry += "                      WHERE CTK_LOTE = '8810' "
	cQry += "                        AND CTK_FILIAL = '"+xFilial("CTK")+"' "
	cQry += "                        AND CTK_DATA = '"+DTOS(SF1->F1_DTLANC)+"' "
	cQry += "                        AND D_E_L_E_T_ = ' ' "
	cQry += "                        AND CTK_RECDES != ' ' "
	cQry += "                        AND CTK_TABORI = 'SD1' "
	cQry += "                        AND CTK_RECORI IN( "

	For iZ := 1 To Len(aRecSD1)
		If iZ > 1
			cQry += ","
		Endif
		cQry += " '"+ Padr(Alltrim(cValToChar(aRecSD1[iZ])),nTmRecOri) +"' "
	Next
	cQry += "))"

	cQry += "  ) AND D_E_L_E_T_ = ' ' "

	TCQUERY cQry NEW ALIAS "QCTK"

	If !Eof()
		dCT2DATA	:= STOD(QCTK->CT2_DATA)
		cCT2LOTE	:= QCTK->CT2_LOTE
		cCT2SBLOTE	:= QCTK->CT2_SBLOTE
		cCT2DOC		:= QCTK->CT2_DOC
		cCT2FIL		:= xFilial("CT2")
		QCTK->(DbCloseArea())

		DbSelectArea("CT2")
		DbSetOrder(1)
		Set Filter To CT2_FILIAL == cCT2FIL .And. CT2_DATA == dCT2DATA .And. CT2_LOTE == cCT2LOTE .And. CT2_SBLOTE == cCT2SBLOTE .And. CT2_DOC == cCT2DOC

	Else
		QCTK->(DbCloseArea())
		MsgAlert("Não foi localizada informação de contabilização desta nota fiscal.","Sem registro de contabilização")
		RestArea(aAreaOld)
		Return .T.
	Endif


	// Guardo variaveis publicas
	nModBk	:= nModulo
	cModBk	:= cModulo
	cCadBk	:= Iif(Type("cCadastro") <> "U", cCadastro ,"")
	// Altero variaveis publicas
	nModulo	:= 34
	cModulo	:= "CTB"

	//CTBA101(2)	
	CTBA102()

	// Restauro as variaveis
	nModulo		:= nModBk
	cModulo		:= cModBk
	cCadastro	:= cCadBk

	DbSelectArea("CT2")
	DbSetOrder(1)
	Set Filter To
	RestArea(aAreaOld)

Return



/*/{Protheus.doc} sfEdiCTRC
(Efetua leitura dos arquivos EDI Conemb para atualizar XML para importar fatura de Transportadora)
@author MarceloLauschner
@since 20/12/2012
@version 1.0
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function sfEdiCTRC()

	Local		oDlgFat
	Local		lContinua	:= .F.
	Local		cLocDir
	Local		a
	Local		cFileImp	:= ""
	Private		cNumFat		:= Space(9)
	Private 	nValFatCte	:= 0
	Private 	nQteCte		:= 0
	Private 	nQteNoFind	:= 0

	DEFINE MSDIALOG oDlgFat TITLE (ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Dados da Fatura para atualizar arquivos XML") FROM 001,001 TO 170,400 PIXEL
	@ 010,018 Say "Informe a Número da Fatura" Pixel of oDlgFat
	@ 010,110 MsGet cNumFat Size 30,10 Pixel of oDlgFat
	@ 022,018 Say "Esta rotina irá procurar na Central XML os CTE´s contidos nos arquivos EDI" Pixel of oDlgFat
	@ 030,018 Say "para atribuir o número da fatura para posterior filtro nos paramêtros" Pixel of oDlgFat
	@ 039,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgFat Action (lContinua	:= .T.,oDlgFat:End())
	@ 039,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgFat Action (oDlgFat:End())

	ACTIVATE MSDIALOG oDlgFat CENTERED

	If !lContinua
		Return
	Endif
	cFileImp 		:= cGetFile("Arquivos .txt |*.txt",;
	OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione Arquivo"),;
	0,;
	"C:\edi\",;
	.T.,;
	GETF_LOCALHARD,;
	.T.,)
	//cGetFile ( [ cMascara], [ cTitulo], [ nMascpadrao], [ cDirinicial], [ lSalvar], [ nOpcoes], [ lArvore], [ lKeepCase] ) 
	//cGetFile("",OemToAnsi(ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Selecione Diretório"),0,"",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD,,)
	aCampos:={}
	AADD(aCampos,{ "LINHA" ,"C",680,0 })

	cNomArq := CriaTrab(aCampos)

	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	dbUseArea(.T.,,cNomArq,"TRB",nil,.F.)

	If !File(cFileImp)
		MsgInfo("Arquivo texto '"+cFileImp+"' não existente.Programa cancelado",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Informação!")
		Return
	Endif

	dbSelectArea("TRB")
	Append From (cFileImp) SDF

	Processa({|| sfAtuEdi() },"Processando...")

	//Ferase(cFileImp)
	u_gravasx1("XMLDCONDOR","18",cNumFat)	

	MsgAlert("Valor total R$ " + AllTrim(Transform(nValFatCte,"@E 999,999,999.99")) +;
	" dos '" + Alltrim(Str(nQteCte))+"' CTE´s atualizados!" + ;
	Iif(nQteNoFind > 0 , "'" + Alltrim(Str(nQteNoFind)) + "' CTE´s não foram localizados na Central XML!", ""),;
	ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Atualização Via Arquivo EDI")

Return


/*/{Protheus.doc} sfAtuEdi
(Atualiza registro com o número da fatura a partir do EDI)
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function sfAtuEdi()


	Local	lAchouSA2   	:= .F.
	Local	cCgc351			:= ""
	Local	cCgc551			:= ""
	Local	cNum552			:= ""
	Local	cCgc521			:= ""

	dbSelectArea("TRB")
	ProcRegua(RecCount()) // Numero de registros a processar
	dbGoTop()
	While !Eof()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		IncProc()
		//-----------------------------------------------------------------------------------
		// Arquivo de Faturas
		// Dados da Transportadora - Arquivo de Cobranças
		If Substr(TRB->LINHA,01,03) == "351"
			cCgc351		:= Substr(TRB->LINHA,04,14)
			lAchouSA2	:= sfSearchA2(cCgc351)

		Endif

		// Conhecimentos em Cobrança
		If lAchouSA2 .And. Substr(TRB->LINHA,01,03) == "353"
			sfAtuCTEXml(Substr(TRB->LINHA,14,3),;				// Série do Documento
			Substr(TRB->LINHA,19,12),;							// Número Conhecimento
			Val(Substr(TRB->LINHA,31,15))/100,;					// Valor Total Frete
			Substr(TRB->LINHA,46,8),;							// Data Emissão CTR
			"",		;											// CGC do Remetente
			"",		;											// CGC do Destinatário
			cCgc351)											// CGC do Emissor
		Endif

		//-----------------------------------------------------------------------------------
		// Arquivo Conemb Versão 3
		If Substr(TRB->LINHA,01,03) == "322"
			lAchouSA2	:= sfSearchA2(Substr(TRB->LINHA,205,14))

			sfAtuCTEXml(Substr(TRB->LINHA,14,3),;				// Série do Documento
			Substr(TRB->LINHA,19,12),;							// Número Conhecimento
			Val(Substr(TRB->LINHA,47,15))/100,;					// Valor Total Frete
			Substr(TRB->LINHA,31,8),;							// Data Emissão CTR
			"",;												// CGC do Remetente
			Substr(TRB->LINHA,219,14),;							// CGC da Embarcadora
			Substr(TRB->LINHA,205,14))							// CGC do Emissor
		Endif

		//-----------------------------------------------------------------------------------
		// Arquivo Conemb Versão 3
		If Substr(TRB->LINHA,01,03) == "329"
			lAchouSA2	:= sfSearchA2(Substr(TRB->LINHA,24,14))

			sfAtuCTEXml("",;									// Série do Documento
			"",;												// Número Conhecimento
			0,;													// Valor Total Frete
			"",;												// Data Emissão CTR
			"",;												// CGC do Remetente
			"",;												// CGC da Embarcadora
			"",;												// CGC do Emissor
			Substr(TRB->LINHA,18,44))							// Chave eletrônica CTe
		Endif

		//-----------------------------------------------------------------------------------
		// Arquivo Conemb Versão 4
		If Substr(TRB->LINHA,01,03) == "421"
			lAchouSA2	:= sfSearchA2(Substr(TRB->LINHA,04,14))
		Endif
		If lAchouSA2 .And. Substr(TRB->LINHA,01,03) == "422"

			sfAtuCTEXml(Substr(TRB->LINHA,14,3),;				// Série do Documento
			Substr(TRB->LINHA,19,12),;							// Número Conhecimento
			Val(Substr(TRB->LINHA,47,15))/100,;					// Valor Total Frete
			Substr(TRB->LINHA,31,8),;							// Data Emissão CTR
			"",;												// CGC do Remetente
			Substr(TRB->LINHA,219,14),;							// CGC do Destinatário
			Substr(TRB->LINHA,205,14))							// CGC do Emissor
		Endif
		//-----------------------------------------------------------------------------------


		// Arquivo Conemb Versão 5
		// 
		// Arquivo de Faturas
		// Dados da Transportadora - Arquivo de Cobranças
		If Substr(TRB->LINHA,01,03) == "551"
			cCgc551		:= Substr(TRB->LINHA,04,14)
			lAchouSA2	:= sfSearchA2(cCgc551)			
		Endif
		If Substr(TRB->LINHA,01,03) == "552"
			cNum552		:= Substr(TRB->LINHA,18,10)
			cNumFat		:= StrZero(Val(cNum552),9)
			MsgInfo("Encontrado tipo de registro '552' e o número da fatura informada é '"+cNumFat+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif

		// Conhecimentos em Cobrança
		If lAchouSA2 .And. Substr(TRB->LINHA,01,03) == "555"
			sfAtuCTEXml(Substr(TRB->LINHA,14,5),;				// Série do Documento
			Substr(TRB->LINHA,19,12),;							// Número Conhecimento
			Val(Substr(TRB->LINHA,31,15))/100,;					// Valor Total Frete
			Substr(TRB->LINHA,46,8),;							// Data Emissão CTR
			Substr(TRB->LINHA,54,14),;							// CGC do Remetente
			Substr(TRB->LINHA,68,14),;							// CGC do Destinatário
			Iif(Empty(Substr(TRB->LINHA,82,14)),cCgc551,Substr(TRB->LINHA,82,14)))// CGC do Emissor
		Endif


		// Arquivo de Conhecimentos Embarcados
		If Substr(TRB->LINHA,01,03) == "521"
			cCgc521		:= Substr(TRB->LINHA,04,14)
			lAchouSA2	:= sfSearchA2(cCgc521)			
		Endif
		If lAchouSA2 .And. Substr(TRB->LINHA,01,03) == "522"

			sfAtuCTEXml(Substr(TRB->LINHA,14,5),;				// Série do Documento
			Substr(TRB->LINHA,19,12),;							// Número Conhecimento
			0,;													// Valor Total Frete
			Substr(TRB->LINHA,31,8),;							// Data Emissão CTR
			Substr(TRB->LINHA,54,14),;							// CGC do Remetente
			Substr(TRB->LINHA,82,14),;							// CGC do Destinatário
			IIf(Empty(Substr(TRB->LINHA,40,14)),cCgc521,Substr(TRB->LINHA,40,14)))// CGC do Emissor
		Endif

		// Arquivo Conemb Versão 5
		// ----------------------------------------------------------------------------------
		dbSelectArea("TRB")
		dbSkip()
	EndDo

	TRB->(DbCloseArea())

Return

/*/{Protheus.doc} sfAtuCTEXml
(Localiza os dados na tabela e atualiza o número FATURA )
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@param cInSerie, character, (Série do Documento)
@param cInNumCTE, character, (Número Conhecimento)
@param nInValFre, numérico, (Valor Total Frete)
@param cInEmissao, character, (Data Emissão CTR)
@param cInCgcEmit, character, (CGC do Remetente)
@param cInCgcDest, character, (CGC do Destinatário)
@param cInCgcEmis, character, (CGC do Emissor)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfAtuCTEXml(cInSerie,cInNumCTE,nInValFre,cInEmissao,cInCgcEmit,cInCgcDest,cInCgcEmis,cInChave)

	Local	cQry
	Default	cInChave	:= ""

	cQry := "SELECT R_E_C_N_O_ AS NRECNO,XML_VLRDOC "
	cQry += "  FROM CONDORXML "
	If Empty(cInChave)
		cQry += " WHERE XML_CHAVE LIKE '%" + StrZero(Val(cInSerie),3) + StrZero(Val(cInNumCTE),9) + "%' " // Concatena a Serie e Numero do documento
		cQry += "   AND XML_CHAVE LIKE '%"+cInCgcEmis+"57%' " 		// Concatena com 57 para identificar somente Xml´s de CTE´s
		cQry += "   AND XML_EMIT = '"+cInCgcEmis+"' "
		cQry += "   AND XML_NROFAT <> '"+cNumFat+"' "  				// Somente titulos com numero de fatura diferente
	Else
		cQry += " WHERE XML_CHAVE = '" + cInChave+ "'"
	Endif

	TCQUERY cQry NEW ALIAS "QCOND"

	If !Eof()
		cQry := "UPDATE CONDORXML "
		cQry += "   SET XML_NROFAT = '"+cNumFat+"' "
		cQry += " WHERE R_E_C_N_O_ = "+AllTrim(Str(QCOND->NRECNO))

		TcSqlExec(cQry)
		nValFatCte	+= Iif(!Empty(QCOND->XML_VLRDOC),QCOND->XML_VLRDOC,nInValFre)
		nQteCte++
	Else
		nQteNoFind++
	Endif
	QCOND->(DbCloseArea())

Return

/*/{Protheus.doc} sfSearchA2
(Procura transportadora)
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@param cInCgcTransp, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function sfSearchA2(cInCgcTransp)

	DbSelectArea("SA2")
	DbSetOrder(3)
	If dbSeek(xFilial("SA2")+cInCgcTransp)
		DbSelectArea("SA4")
		DbSetOrder(3)
		If !DbSeek(xFilial("SA4")+SA2->A2_CGC)
			//MsgAlert("CNPJ '"+cInCgcTransp+"' do Fornecedor não consta na Base de dados como Transportadora.Solicitar ao setor de logistica o cadastro da mesma.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro!")
			Return .F.
		Endif
	Else
		//MsgAlert("CNPJ '"+cInCgcTransp+"' do Fornecedor não cadastrado na base de dados.",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro!")
		Return .F.
	Endif

Return .T.





User Function MYXMLEXEC()


	RpcSetType(3)
	//RpcSetEnv - Abertura do ambiente em rotinas automáticas ( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
	//RPCSetEnv("02","04")
	RPCSetEnv("02","04","marcelo alberto","senha" ,"COM"/*cEnvMod*/,/*cFunName*/,{"SX2","SM0"}/*aTables*/,/*lShowFinal*/,/*lAbend*/,.T./*lOpenSX*/)
	Sleep(5 * 1000) // Tempo para abertura
	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If SM0->M0_CODIGO == "02" .And. Alltrim(SM0->M0_CODFIL)== "04"
			Exit	
		EndIf
		DbSkip()
	EndDo

	u_gravasx1("XMLDCONDOR","02"," ")
	u_gravasx1("XMLDCONDOR","03"," ")
	u_gravasx1("XMLDCONDOR","04","ZZZ")
	u_gravasx1("XMLDCONDOR","05","ZZ")
	u_gravasx1("XMLDCONDOR","06",dDataBase-30)
	u_gravasx1("XMLDCONDOR","07",dDataBase)
	u_gravasx1("XMLDCONDOR","09","82481730000205")
	u_gravasx1("XMLDCONDOR","10","82481730000205")
	u_gravaSx1("XMLDCONDOR","15",4)// MV_PAR15 == 3 .And.  !CONDORXML->XML_TIPODC $ "T#F"
	u_gravaSx1("XMLDCONDOR","16",3)

	U_XMLDCONDOR("02"/*xCodEmp*/,"04"/*xCodFil*/,"000130"/*cInIdUser*/,.T./*lInExeAuto*/)

	RpcClearEnv()



Return
