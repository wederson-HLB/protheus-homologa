
#Include "Font.Ch"
#Include "FwPrintSetup.ch"
#Include "Protheus.ch"
#Include "RptDef.Ch"
#include "topconn.ch"
#include "tbiconn.ch"

#DEFINE ITENSSC6 300 

User Function X2FAT003()

Local aArea     := GetArea()
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aPosGet   := {}
Local aRegSC6   := {}
Local aRegSCV   := {}
Local aInfo     := {}
Local lLiber 	:= .F.
Local lTransf	:= .F.
Local lGrade	:= .F.
Local lBloqueio := .T.
Local lNaoFatur := .F.
Local lContrat  := .F.
Local lQuery    := .F.
Local lContinua := .T.
Local lMt410Alt := .F.
Local lM410Stts := .F.
Local lTM410Stts:= .F.
Local lM410Bar  := .F.
Local lFreeze   := .F.
Local lContTPV  := .F.
Local lAltPrcCtr:= .F.
Local lIntACD	:= .F.
Local lWmsNew	:= .F.
Local nOpcA		:= 0
Local nCntFor   := 0
Local nTotalPed := 0
Local nTotalDes := 0
Local nAux	    := 0
Local nNumDec   := TamSX3("C6_VALOR")[2]
Local nGetLin   := 0
Local nStack    := GetSX8Len()
Local nColFreeze:= .F.
Local cArqQry   := "SC6"
Local cCadastro := "AtualizaГЦo de Pedidos de Venda - Marici"
Local oDlg
Local oGetd
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local lMt410Ace := .F.
Local nX 		:= 0
//Gestao de Contratos
Local lGCT     := .F.
Local aPedCpo  := NIL

Local cSeek     	:= ""
Local aNoFields 	:= {}		// Campos que nao devem entrar no aHeader e aCols, NцO INCLUIR CAMPOS DIRETAMENTE AQUI
Local aYesFields	:= Nil		// Campos que devem entrar no aCols obrigatoriamente, em caso de execuГЦo automАtica
Local bWhile    	:= {|| }
Local cQuery    	:= ""
Local bCond     	:= {|| .T. }
Local bAction1  	:= {|| Mta410Alt(cArqQry,@nTotalPed,@nTotalDes,lGrade,@lBloqueio,@lNaoFatur,@lContrat,@aRegSC6) }	
Local bAction2  	:= {|| .T. }
Local aRecnoSE1RA	:= {} // Array com os titulos selecionados pelo Adiantamento   
Local aMTA177PER 	:= {}  // Array para carregar as perguntas de central de compras
Local aHeadAGG	:= {}
Local aColsAGG	:= {}
Local cRotAnt		:= ''
Local cOmsCplInt	:= SuperGetMv("MV_CPLINT",.F.,"2") //IntegraГЦo OMS x CPL
Local nPosTpCompl	:= 0
Local cAlias        := "SC5"
Local nReg          := 0
Local nOpc          := 4

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁArray para controlar relacionamento com SD4 (Remessa para Beneficiamento Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aColsBn := {}//A410CarBen(SC5->C5_NUM)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriar array PRIVATE p/ integracao com sistema de Distribuicao - NAO REMOVER Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aDistrInd:={}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas na LinhaOk                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aHeadFor   := {}
PRIVATE aColsFor   := {}
PRIVATE N          := 1
PRIVATE oGetPV		:= nil

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a entrada de dados do arquivo                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0],aGETS[0]

PRIVATE aGEMCVnd :={"",{},{}} //Template GEM - Condicao de Venda

// gravando o historico dos itens em caso de alteracao do tipo do produto e/ou codigo do produto
PRIVATE aColsHist := {}

//inclui campos no array para nЦo exibir
aNoFields := {"C6_LOTECTL","C6_NUMLOTE","C6_DTVALID","C6_NUMORC","C6_OP","C6_LOCAL","C6_SEGUM","C6_PRCVEN","C6_QTDVEN","C6_VALOR","C6_QTDLIB","C6_QTDLIB2","C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2","C6_RESERVA","C6_OP"}
,C6_CHASSI,C6_OPC,C6_LOCALIZ,C6_NUMSERI,C6_NUMOP,C6_ITEMOP,C6_CLASFIS
C6_QTDRESE
C6_CONTRAT
C6_NUMOS
C6_NUMOSFA
C6_CODFAB
C6_LOJAFA
C6_ITEMCON
C6_TPOP
C6_REVISAO
C6_SERVIC
C6_ENDPAD
C6_TPESTR
C6_CONTRT
C6_TPCONTR
C6_ITCONTR
C6_GEROUPV
C6_PROJPMS
C6_EDTPMS
C6_TASKPMS
C6_TRT
C6_QTDEMP
C6_QTDEMP2
C6_PROJET
C6_ITPROJ
C6_POTENCI
C6_LICITA
C6_REGWMS
C6_MOPC
C6_NUMCP
C6_NUMSC
C6_ITEMSC
C6_SUGENTR
C6_ITEMED
C6_ABSCINS
C6_ABATISS
C6_ABATMAT
C6_VLIMPOR
C6_FUNRURA
C6_FETAB
C6_CODROM
C6_PROGRAM
C6_TURNO
C6_PEDCOM
C6_ITPC
C6_FILPED
C6_DTFIMNT
C6_FCICOD
C6_DATAEMB
C6_CODLAN
C6_FORDED
C6_LOJDED
C6_NUMPCOM
C6_ORCGAR
C6_GCPIT
C6_GCPLT
C6_HORCPL
C6_HORENT
C6_ITEMPC
C6_ITEMGAR
C6_INTROT
C6_ITEMCTA
C6_ALMTERC
C6_BASVEIC
C6_CLVL
C6_CONTA
C6_CTVAR
C6_DATCPL
C6_ABATINS
C6_CATEG
C6_CC
C6_CCUSTO
C6_VDMOST
C6_VDOBS
C6_PENE
C6_PVCOMOP
C6_TNATREC
C6_SOLCOM
C6_PMSID
C6_PCDED
C6_MOTDED
C6_NFDED
C6_SERDED
C6_RATEIO
C6_VLDED
C6_TPDEDUZ
C6_VLNFD
C6_TPPROD
C6_TPREPAS
C6_REVPROD
C6_SDOC
C6_SDOCDED
C6_SDOCORI
C6_SDOCSD1
C6_PRODFIN
C6_NRSEQCQ
C6_PEDVINC
C6_ITLPRE
C6_GRPNATR
C6_IPITRF
C6_CSTPIS
C6_CULTRA
C6_D1DOC
C6_D1ITEM
C6_D1SERIE
C6_CNATREC
C6_CODLPRE
C6_CODINF


If ( Type("l410Auto") <> "U" .And. l410Auto )
	aYesFields := {}
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))	//X3_ARQUIVO + X3_ORDEM
	SX3->(DbSeek( "SC6" ))
	While ( SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SC6" )
		aAdd( aYesFields, AllTrim(SX3->X3_CAMPO) )
		SX3->(DbSkip())
	EndDo
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o usuario tem premissao para alterar o Ё
//Ёpedido de venda                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддды
If cPaisLoc <> "BRA" .AND. FieldPos("C5_CATPV") > 0 .AND. !Empty(SC5->C5_CATPV)
	If AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
		DBSelectArea("AGS")
		DBSetOrder(1)
		If DBSeek(xFilial("AGS") + __cUserId) //Se nЦo encontrar o usuАrio na tabela, permite ele alterar o pedido
			If !DBSeek(xFilial("AGS") + __cUserId + SC5->C5_CATPV) //Verifica se o usuario tem premissao
				MsgStop("Este usuario nao tem permissao para alterar pedidos de venda com essa categoria.")//
				lContinua := .F.
			EndIf
		EndIf
	EndIf
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o campo de codigo de lancamento cat 83 Ё
//Ёdeve estar visivel no acols                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддды
If !SuperGetMV("MV_CAT8309",,.F.)
	aAdd(aNoFields,"C6_CODLAN")
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Se o Pedido foi originado em uma indenizaГЦo - Nao Altera  |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
If !At650BlqPd(SC5->C5_NUM)
	lContinua  := .F.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para validar acesso do usuario na funcao Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lMt410Ace
	lContinua := Execblock("MT410ACE",.F.,.F.,{nOpc})
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Agroindustria  									                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FindFunction("OGXUtlOrig") 
	If OGXUtlOrig()
		If (FindFunction("OGX220"))
			lContinua := OGX220("A")
		EndIf
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria Ambiente/Objeto para tratamento de grade        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды        
If IsAtNewGrd()
	PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"C6_QTDVEN",,"a410GValid()",;
							{ 	{VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_LOCAL"})])}} },;
	  						{ 	{"C6_QTDVEN",.T., {{"C6_UNSVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) } }} },;
	  							{"C6_QTDLIB",NIL,NIL},;
	  							{"C6_QTDENT",NIL,NIL},;
	  							{"C6_ITEM"	,NIL,NIL},;
	  							{"C6_UNSVEN",NIL, {{"C6_QTDVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} },;
	  							{"C6_OPC",NIL,NIL},;
	  							{"C6_BLQ",NIL,NIL}})	  							

	//-- Inicializa grade multicampo
	A410InGrdM(.T.)
Else
	PRIVATE aColsGrade := {}
	PRIVATE aHeadgrade := {}	
EndIf
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCarrega perguntas do MTA177, MATA440 e MATA410                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte ("MTA177",.F.)
aAdd (aMTA177PER,{MV_PAR17,MV_PAR18} )
Pergunte("MTA440",.F.)
lLiber := MV_PAR02 == 1
lTransf:= MV_PAR01 == 1
Pergunte("MTA410",.F.)
//Carrega as variaveis com os parametros da execauto
Ma410PerAut()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variavel utilizada p/definir Op. Triangulares.       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
IsTriangular( MV_PAR03==1 )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva a integridade dos campos de Bancos de Dados    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea(cAlias)
IF ( (ExistTemplate("M410ALOK")) )
	If (! ExecTemplate("M410ALOK",.F.,.F.) )
		lContinua := .F.
	EndIf
EndIf

IF lContinua .And. ( (ExistBlock("M410ALOK")) )
	If (! ExecBlock("M410ALOK",.F.,.F.) )
		lContinua := .F.
	EndIf
EndIf

IF ( SC5->C5_FILIAL <> xFilial("SC5") )
	Help(" ",1,"A000FI")
	lContinua := .F.
EndIf
  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Se o Pedido foi originado de um EDITAL - Nao Altera  |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды             

If !Empty(SC5->C5_NUMPR) .Or. !Empty(SC5->C5_CODED)
	Help(" ",1,"A410EDITAL") //"Pedido de Venda pertence a um Edital, e nao podera ser alterado, copiado ou excluido"
	lContinua := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Se o Pedido foi originado no SIGAEEC - Nao Altera    |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
//| Somente altera se o parametro MV_EEC0023 estiver .T. |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SC5")
IF !GetMV("MV_EEC0023",,.F.) .AND. !Empty(SC5->C5_PEDEXP) .And. nModulo != 29 .And. ( Type("l410Auto") == "U" .OR. !l410Auto )
	Help(" ",1,"MTA410ALT")
	lContinua := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Se o Pedido foi originado no SIGATMS - Nao Altera    |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(SC5->C5_SOLFRE)
	Help(" ",1,"A410TMSNAO")
	lContinua := .F.
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Se o Pedido foi originado no SIGALOJA - Nao Altera    |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(SC5->C5_ORCRES) .AND. (Type("l410Auto") == "U" .OR. !l410Auto)
	//
	MsgAlert("Este Pedido foi gerado atravИs do mСdulo de Controle de Lojas, e nЦo poderА ser alterado.")
	lContinua := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Verifica se o pedido tem carga montada               |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FindFunction("A410VIAG") .And. cOmsCplInt == "1" .And. nOpc == 4
    lContinua := IIF(!A410VIAG(SC5->C5_NUM),.T.,.F.)
EndIf

If OmsHasCg(SC5->C5_NUM) .And. lContinua
	Help(" ",1,"A410CARGA")
Endif 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva a integridade dos campos de Bancos de Dados    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea(cAlias)
If !SoftLock(cAlias)
	lContinua := .F.
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa desta forma para criar uma nova instancia de variaveis private Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RegToMemory( "SC5", .F., .F. )

If lContinua
	lContinua := If(lGrade.And.MatOrigGrd()=="SB4",VldDocGrd(1,SC5->C5_NUM),.T.)
EndIf

//-- Como e alteracao so ira mostrar opcionais
//-- caso alterere algo na linha (controle na A410FldOk)
If Type("lShowOpc") == "L"
	lShowOpc := .F.
EndIf

If ( lContinua )
	dbSelectArea("SC6")
	dbSetOrder(1)
	#IFDEF TOP
		If TcSrvType()<>"AS/400" .And. !InTransact() .And. Ascan(aHeader,{|x| x[8] == "M"}) == 0
			lQuery  := .T.
			cQuery := "SELECT SC6.*,SC6.R_E_C_N_O_ SC6RECNO "
			cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
			cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
			cQuery += "SC6.C6_NUM='"+SC5->C5_NUM+"' AND "
			cQuery += "SC6.D_E_L_E_T_<>'*' "
			cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))

			dbSelectArea("SC6")
			dbCloseArea()
		EndIf	
	#ENDIF
	cSeek  := xFilial("SC6")+SC5->C5_NUM
	bWhile := {|| C6_FILIAL+C6_NUM }

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Montagem do aHeader e aCols                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FillGetDados(nOPc,"SC6",1,cSeek,bWhile,{{bCond,bAction1,bAction2}},aNoFields, aYesFields, /*lOnlyYes*/,cQuery,/*bMontCols*/,Inclui,/*aHeaderAux*/,/*aColsAux*/,/*{|| AfterCols(cArqQry) }*/,/*bBeforeCols*/,/*bAfterHeader*/,"SC6")	
	aColsHist := aClone(aCols)	

	If "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"") .And. lGrade
		aCols := aColsGrade(oGrade,aCols,aHeader,"C6_PRODUTO","C6_ITEM","C6_ITEMGRD",aScan(aHeader,{|x| AllTrim(x[2]) == "C6_DESCRI"}))
	EndIf

	//A410FRat(@aHeadAGG,@aColsAGG)	

	nTotalDes  += A410Arred(nTotalPed*M->C5_PDESCAB/100,"C6_VALOR")
	nTotalPed  -= A410Arred(nTotalPed*M->C5_PDESCAB/100,"C6_VALOR")
	nTotalPed  -= M->C5_DESCONT
	nTotalDes  += M->C5_DESCONT

	
	If ( lQuery )
		dbSelectArea(cArqQry)
		dbCloseArea()
		ChkFile("SC6",.F.)
		dbSelectArea("SC6")
	EndIf
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁInicializa ambiente de integraГЦo com Planilha Ё
//юддддддддддддддддддддддддддддддддддддддддддддддды
A410RvPlan("","",.T.)


//зддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta o array com as formas de pagamento do SX5Ё
//юддддддддддддддддддддддддддддддддддддддддддддддды
Ma410MtFor(@aHeadFor,@aColsFor,@aRegSCV)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso nao ache nenhum item , abandona rotina.         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua )
	//
	// Template GEM - Gestao de Empreendimentos Imobiliarios
	//
	// faz a copia da condicao de venda se a mesma tiver 
	// uma vinculacao com a condicao de pagamento
	//
	If ExistBlock("GEM410PV")
		aGEMCVnd := ExecBlock("GEM410PV",.F.,.F.,{ M->C5_NUM ,M->C5_CONDPAG ,M->C5_EMISSAO ,nTotalPed })
	ElseIf ExistTemplate("GEM410PV")
		// Copia a condicao de venda
		aGEMCVnd := ExecTemplate("GEM410PV",.F.,.F.,{ M->C5_NUM ,M->C5_CONDPAG ,M->C5_EMISSAO ,nTotalPed })
	EndIf

	If ( Len(aCols) == 0 )
		lContinua := .F.
		Help(" ",1,"A410S/ITEM")
	EndIf
	If ( (ExistBlock("M410GET")) )
		ExecBlock("M410GET",.F.,.F.)
	EndIf
	If ( lBloqueio )
		Help(" ",1,"A410ELIM")
		lContinua := .F.
	EndIf
	If (!(SuperGetMv("MV_ALTPED")=="S") .And. !lNaoFatur) .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
		Help(" ",1,"A410PEDFAT")
		lContinua := .F.
	EndIf
	If ( lContrat ) .And. !lAltPrcCtr
		Help(" ",1,"A410CTRPAR")
		lContinua := .F.
	EndIf
EndIf
If ( lContinua )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza com cliente original do pedido caso troque  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	A410ChgCli(M->C5_CLIENTE+M->C5_LOJACLI)

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Faz o calculo automatico de dimensoes de objetos     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSize := MsAdvSize()
		aObjects := {}
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 020, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]
		If lContTPV		
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOr( WS_VISIBLE,WS_POPUP )
		Else 
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL 
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Armazenar dados do Pedido anterior.                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		IF M->C5_TIPO $ "DB"
			aTrocaF3 := {{"C5_CLIENTE","SA2"}}
		Else
			aTrocaF3 := {}
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica campos especificos para edicao - SIGAGCT    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lGCT
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Adiciona campos padrЦo								    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aPedCpo := {{"C5_MENNOTA","C5_TRANSP", "C5_MENPAD", "C5_NATUREZ", "C5_ESTPRES", "C5_MUNPRES","C5_RECISS","C5_CONDPAG","C5_PARC1","C5_DATA1"},{"C6_TES","C6_ABATINS","C6_QTDLIB"}}
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Adiciona campos do usuАrio do cabeГalho			    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SX3")
			dbSetOrder(1)
			If SX3->( dbSeek( "SC5" ) )
			    While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "SC5"
			        If (Alltrim(SX3->X3_PROPRI) == "U") 
			            aAdd(aPedCpo[1],SX3->X3_CAMPO)
			        EndIf
			        SX3->( dbSkip() )
			    End
			EndIf
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Adiciona campos do usuАrio do item					    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SX3->( dbSeek( "SC6" ) )
			    While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "SC6"
			        If (Alltrim(SX3->X3_PROPRI) == "U") 
			            aAdd(aPedCpo[2],SX3->X3_CAMPO)
			        EndIf
			        SX3->( dbSkip() )
			    End
			EndIf
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de entrada para substituiГЦo dos campos	    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ExistBlock("GCTPEDCPO")
				aPedCpo := ExecBlock("GCTPEDCPO",.F.,.F.)
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Em cenАrio em que o Faturamento estА integrado com o Export, somente serЦo habilitados para  Ё
		//Ё ediГЦo os campos nЦo integrados quando o parametro MV_EEC0023 estiver habilitado             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		oGetPV:=MSMGet():New( "SC5", nReg, nOpc, , , , , aPosObj[1],If(lGCT,aPedCpo[1],If(!Empty(SC5->C5_PEDEXP) .AND. GetMV("MV_EEC0023",,.F.),FAT2CposInt("SC5"),NIL)),3,,,"A415VldTOk")
		//@ nGetLin,aPosGet[1,1]  SAY OemToAnsi(IIF(M->C5_TIPO$"DB",STR0008,STR0009)) SIZE 020,09 PIXEL	//"Fornec.:"###"Cliente: "
		@ nGetLin,aPosGet[1,2]  SAY oSAY1 VAR Space(40)						    SIZE 120,09 PICTURE "@!" OF oDlg PIXEL
		@ nGetLin,aPosGet[1,3]  SAY OemToAnsi("Total :")						SIZE 020,09 OF oDlg PIXEL	//"Total :"
		@ nGetLin,aPosGet[1,4]  SAY oSAY2 VAR 0 PICTURE IIf(cPaisloc=="CHI",Nil,TM(0,22,nNumDec))	SIZE 060,09 OF oDlg PIXEL
		@ nGetLin,aPosGet[1,5]  SAY OemToAnsi("Desc. :")						SIZE 030,09 OF oDlg PIXEL 	//"Desc. :"
		@ nGetLin,aPosGet[1,6]  SAY oSAY3 VAR 0 PICTURE IIf(cPaisloc=="CHI",Nil,TM(0,22,nNumDec))		SIZE 060,09 OF oDlg PIXEL RIGHT
		@ nGetLin+10,aPosGet[1,5]  SAY OemToAnsi("=")							SIZE 020,09 OF oDlg PIXEL
		If cPaisLoc == "BRA"
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 060,09 PICTURE TM(0,22,nNumDec) OF oDlg PIXEL RIGHT
		Else
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 050,09 PICTURE IIf(cPaisloc=="CHI",Nil,TM(0,22,nNumDec)) OF oDlg PIXEL RIGHT
		EndIf
		oDlg:Cargo	:= {|c1,n2,n3,n4| oSay1:SetText(c1),;
			oSay2:SetText(n2),;
			oSay3:SetText(n3),;
			oSay4:SetText(n4) }
		SetKey(VK_F4,{||A440Stok(NIL,"A410")})	
		oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"X2FATLinOk","X2FATTudOk","+C6_ITEM/C6_Local/C6_TES/C6_CF/C6_PEDCLI",.T.,If(lGCT,aPedCpo[2],If(!Empty(SC5->C5_PEDEXP) .AND. GetMV("MV_EEC0023",,.F.),FAT2CposInt("SC6"),NIL)),nColFreeze,,ITENSSC6*IIF(MaGrade(),1,3.33),"A410Blq()",,,"A410ValDel()",,lFreeze)	
	   		
		If lIntACD 
			For nX:=1  To len(oGetd:AINFO)
			   		oGetd:AINFO[nX,4]:=IIF(Empty(oGetd:AINFO[nX,4]),"CBM410ACDL()",Trim(oGetd:AINFO[nX,4])+" .AND. CBM410ACDL()")
			Next nX
		EndIf 
		
		Private oGetDad := oGetD
		If Type("lCodBarra") <> "U"
			oGetd:oBrowse:bGotFocus:={|| IIF(lCodBarra .And. !lM410Bar,a410EntraBarra(oGetD),IIF(lCodBarra .And. lM410Bar,Execblock("M410CODBAR",.F.,.F.,{nOpc,oGetD}),))}
		EndIf

		If cPaisLoc == "BRA"
			nPosTpCompl := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_TPCOMPL"})
			If nPosTpCompl > 0
				oGetPV:aEntryCtrls[nPosTpCompl]:lReadOnly := .T.
			EndIf	
		EndIf

		//A410Bonus(2)
		Ma410Rodap(oGetD,nTotalPed,nTotalDes)
		ACTIVATE MSDIALOG oDlg ON INIT (A410Limpa(.F.,M->C5_TIPO),Ma410Bar(oDlg,{||nOpcA:=1,if(A410VldTOk(nOpc, aRecnoSE1RA).And.oGetD:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||Iif( Ma410VldUs(nOpca), oDlg:End(),)},nOpc,oGetD,nTotalPed,@aRecnoSE1RA,@aHeadAGG,@aColsAGG))
		SetKey(VK_F4,)
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Permite alterar a data de entrega de um item do pedido, ou   Ё
		//Ё sugerir uma data de entrega a partir da analise do APS       Ё		
		//Ё que somente eh executado via webservice/rotina automatica.   Ё				
		//Ё Valido somente para Integracao APS DRUMMER.                  Ё						
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If SuperGetMv("MV_APS",.F.,"") == "DRUMMER"
			
			/* ---- LOGICA UTILIZADA EM PORTUGUES ESTRUTURADO PARA MAIOR ENTENDIMENTO -----
		
			SE ( NAO EXISTIR O CAMPO SUGERIDO PARA DATA DE ENTREGA) ENTAO
				PROCURA AS REFERENCIAS DO C6_ENTREG NOS ITENS E SE ACHAR APAGA
			SENAO SE ( PARAMETRO QUE INDICA ONDE SERA FEITA A ATUALIZACAO DE ENTREGA FOR INFORMADO FOR PARA GRAVAR NO CAMPO SUGERIDO C6_SUGENTR ) ENTAO
				PROCURA NOS ITEMS DE ARRAY AS REFERENCIAS DE C6_ENTREG E ALTERA PARA C6_SUGENTR
			FIM SE
		    
		    */
		
     		If SuperGetMv("MV_CPOPVEN",.F.,"C6_SUGENTR") == "C6_SUGENTR"
            	For nCntFor:= 1 To Len(aAutoItens)
					nPos := AsCan(aAutoItens[nCntFor],{|x| AllTrim(x[1])=="C6_ENTREG"})            		
					If ( nPos > 0 )
						aAutoItens[nCntFor][nPos,1] := "C6_SUGENTR"
					EndIf
            	Next nCntFor   				     			
			EndIf						
		EndIf
		 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё validando dados pela rotina automatica                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .And. MsGetDAuto(aAutoItens,"X2FATLinOk",{|| A410VldTOk(nOpc) .and. X2FATTudOk()},aAutoCab,aRotina[nOpc][4])
			nOpcA := 1
		EndIf 
	EndIf
	If ( nOpcA == 1 )                           
		//
		// Template GEM - Gestao de Empreendimentos Imobiliarios
		// Gera o contrato baseado nos dados do pedido de venda
		//   
		If HasTemplate("LOT") .AND. ExistTemplate("GEMXPV",,.T.)
			// atualiza o status do empreendimento  
			For nX := 1 to Len(aCols)
				ExecTemplate("GEMXPV",.F.,.F.,{ aCols[nX][Len(aCols[nX])] ,SC6->C6_CODEMPR, 1 })
			Next nX
		EndIf		
		//  Amarracao do Pedido de venda com o pedido de compras 
		//  para a Central de Compras.		
		If  !lWmsNew .and. nOpcA == 1   
			A410CCPed(aCols,aHeader,aMTA177PER,2)   
		EndIf
		A410Bonus(1)
		If Type("lOnUpDate") == "U" .Or. lOnUpdate
			If a410Trava()
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicializa a gravacao dos lancamentos do SIGAPCO          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PcoIniLan("000100")
				Begin Transaction
					If !X2FATGrava(lLiber,lTransf,2,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,aColsBn,aRecnoSE1RA,aHeadAGG,aColsAGG)
						Help(" ",1,"A410NAOREG")
					EndIf 				
				End Transaction
				// Gera execuГЦo das ordens de serviГo
				If IntWms()
					WmsAvalExe()
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Finaliza a gravacao dos lancamentos do SIGAPCO            Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PcoFinLan("000100")

				If lMt410Alt
					Execblock("MT410ALT",.F.,.F.)
				Endif

				If lTM410Stts
					ExecTemplate("M410STTS",.f.,.f.)
				Endif

				If lM410Stts
					ExecBlock("M410STTS",.f.,.f.)
				Endif
			EndIf
		Else
			aAutoCab := MsAuto2Ench("SC5")
			aAutoItens := MsAuto2Gd(aHeader,aCols)
		EndIf
	Else
		If ( (ExistBlock("M410ABN")) )
			ExecBlock("M410ABN",.f.,.f.)
		EndIf
	EndIf
	
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁLimpa cliente anterior para proximo pedido                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
a410ChgCli("")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDestrava Todos os Registros                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsUnLockAll()
RestArea(aArea)
Return( nOpcA )

//-------------------------------------

Static Function X2FATLinOk()


Return(.T.)

//--------------------------------------

Static Function X2FATTudOk()


Return(.T.)

//----------------------------------------

Static Function X2FATGrava(lLiber,lTransf,nOpcao,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,aEmpBn,aRecnoSE1,aHeadAGG,aColsAGG) 

Local aArea     := GetArea("SC5")
Local aRegLib   := {}
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local lTravou   := .F.
Local lTravou2  := .F.
Local lLiberou  := .F.
Local lLiberOk	:= .T.
Local lResidOk	:= .T.
Local lFaturOk	:= .F.
Local lGravou	:= .F.
Local lContinua := .F.
Local lXml      := .F.
Local lMta410I  := ExistBlock("MTA410I")
Local lMta410E  := ExistBlock("MTA410E")
Local cPedido   := ""
Local cMay      := ""
Local cArqQry   := "SC6"
Local cProdRef	:= "" 
//---------- Variavel existente somente para manter legado ate R4              
Local cMascara	:= SuperGetMv("MV_MASCGRD")                       
//------------------------------------------------------------------
Local nTamRef	:= If(IsAtNewGrd(),0,Val(Substr(cMascara,1,2)))
Local nMaxFor	:= Len(aCols)
Local nMaxFor2	:= 0
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nTpProd	 := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TPPROD"})
Local nVlrCred  := 0
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local xZ		:= 0
Local nDeleted  := Len(aHeader)+1
Local nDeleted2 := 0
Local nMoedaOri := 1
Local nCntForma := 0
Local nCount    := 0
Local aSaldoSDC := {} 
Local aRegStatus:= {}   
Local lCtbOnLine := .F.
Local lDigita 	 := .F.
Local lAglutina	 := .F.
Local cArqCtb    := ""       
Local nTotalCtb  := 0            
Local nHdlPrv    := 0
Local aAreaSX1   := {}
Local lMata410	 := IIF(FUNNAME()=="MATA410",.T.,.F.)
Local lAutomato	:= IsBlind()
Local lAtuSGJ	 := .F. //SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local nUsadoAGG  := 0
LOCAL cCondPOld  := ""
Local nTpCtlBN   := A410CtEmpBN()
Local aAreaAtu   := {} 
Local cQuery     := ""
Local cOmsCplInt := SuperGetMv("MV_CPLINT",.F.,"2") //IntegraГЦo OMS x CPL
//-- Gravacao de campos Memo por SYP no SC6
Local nI         := 0  
Local cCpoSC6    := '' 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Integracao SIGAFAT e SIGADPR                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aItemDPR		:= {}
Local lIFatDpr		:= .F.//SuperGetMV("MV_IFATDPR",.F.,.F.)
Local lBkpINCLUI	:= INCLUI
Local cChave		:= "" 
Local aAutoAO4Aux	:= {} 
Local aAutoAO4		:= {}
Local nOperation	:= MODEL_OPERATION_INSERT 
Local cSerieId  	:= ""
Local cCodUsr		:= ""
Local lRateio		:= .F.
Local cFilSC6		:= ""
Local cFilSCV		:= ""
Local lGeMxGrSol	:= .F.//ExistTemplate("GEMXGRSOL",,.T.)
Local lGeMxGrcVnd 	:= .F.//ExistBlock("GEMXGRCVND",,.T.)
Local lTGeMxGrcVnd 	:= .F.//ExistTemplate("GEMXGRCVND",,.T.)
Local lGeMxPv		:= .F.//ExistTemplate("GEMXPV",,.T.)
	
Private nValItPed   := 0
PRIVATE cCondPAdt   := "0" //Controle p/ cond. pgto. com aceite de Adt. 0=normal 1=Adt

DEFAULT nOpcao     := 0
DEFAULT aHeadFor   := {}
DEFAULT aColsFor   := {}
DEFAULT aRegSC6    := {}
DEFAULT aRegSCV    := {}
DEFAULT nStack     := 0 
DEFAULT aEmpBn	   := {}
DEFAULT aRecnoSE1  := {}
DEFAULT aHeadAGG   := {}
DEFAULT aColsAGG   := {} 

If ValType(nOpcao)=='N' .And. IsInCallStack("A410INCLUI")
	lBkpINCLUI := .T.
	If Type("INCLUI") == "L"
		INCLUI := lBkpINCLUI
	EndIf
EndIf

// limpa a static aUltResult 
Fat190DVerb()

If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt == 4
	cCondPOld := SC5->C5_CONDPAG
EndIf

nMaxFor2  := Len(aColsFor)
nDeleted2 := Len(aHeadFor)+1

aRegStatus := Array( Len( aRegSC6 ) )
AFill( aRegStatus, .T. )

// NЦo contabiliza a alteraГЦo - !ALTERA
If nOpcao <> 3
	aAreaSX1		:= SX1->(GetArea())
	SaveInter()
	Pergunte("MTA410",.F.)
	//Carrega as variaveis com os parametros da execauto
	Ma410PerAut()
	lCtbOnLine		:= ( lMata410 .Or. lAutomato ) .And. MV_PAR05==1 .And. !ALTERA .And. !Empty( SC5->( FieldPos( "C5_DTLANC" ) ) )
	lAglutina		:= MV_PAR06==1
	lDigita		    := MV_PAR07==1
	RestInter()
	RestArea(aAreaSX1)
Else
	aAreaSX1		:= SX1->(GetArea())
	SaveInter()
	Pergunte("MTA410",.F.)
	//Carrega as variaveis com os parametros da execauto
	Ma410PerAut()
	lCtbOnLine		:= ( lMata410 .Or. lAutomato )  .And. !ALTERA .And. !Empty( SC5->( FieldPos( "C5_DTLANC" ) ) )
	lAglutina		:= MV_PAR06==1
	lDigita		    := MV_PAR07==1
	RestInter()
	RestArea(aAreaSX1)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada antes de iniciar a manutencao do pedido               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("M410AGRV")
	ExecBlock("M410AGRV",.f.,.f.,{ nOpcao })
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para pegar os registros de SDC para reconstruir as    Ё
//Ё as liberaГУes na alteraГЦo dos Itens do Pedidos.                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( (ExistBlock("M410PSDC") ) )
	aSaldoSDC := ExecBlock("M410PSDC",.f.,.f.)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se Grade estiver ativa, grava Acols conf.AcolsGrade  para depois       Ё
//Ё continuar a gravar como um pedido comum.                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( MaGrade().And. If(IsAtNewGrd(),Type("oGrade")=="O",Type('aHeadGrade')<>'U') )
	Ma410GraGr()
	nMaxFor	:= Len(aCols)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se ha itens a serem gravados                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nX := 1 To nMaxFor
	If nOpcao == 3
		aCols[nX][nDeleted] := .T.
	EndIf
	If !aCols[nX][nDeleted]
		lGravou   := .T.
		lContinua := .T.
		Exit
	EndIf
Next nX

If !lGravou .And. !INCLUI
	nOpcao := 3
	lContinua := .T.
EndIf

If nOpcao == 3
	For nX := 1 To nMaxFor2
		aColsFor[nX][nDeleted2] := .T.
	Next nX
	lGravou := .T.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a gravacao via JOB XML esta ativa                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lContinua .And. nOpcao == 1 .And. GetNewPar("MV_MSPVXML",.F.)
	lXml := Ma410GrXml()
EndIf
If nOpcao == 4
	nOpcao :=1
EndIf

nMoedaOri := M->C5_MOEDA

//Montagem dos dados da execauto de rateio
If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt > 0 .And. Len(aRatCTBPC) > 0  
   aHeadAGG:={}
   aColsAGG:={}
   DbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("AGG")
	While !EOF() .And. (SX3->X3_ARQUIVO == "AGG")
		If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !AllTrim(SX3->X3_CAMPO)$"AGG_CUSTO#AGG_FILIAL"
			aAdd(aHeadAGG,{ TRIM(x3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	lRateio := .T.
	aColsAGG := M410AutRat(aRatCTBPC, aHeadAGG)	
Endif
nUsadoAGG := Len(aHeadAGG)

If lRateio .And. Len(aColsAGG[1][2][1]) <= nUsadoAGG
	nUsadoAGG -= Len(CtbEntArr()) * 2
EndIf
		
//Caso AlteraГЦo Automatica deleta os rateios
If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt==4 .And. Len(aRatCTBPC) > 0
	aAreaAGG := GetArea()
	AGG->(DbSetOrder(1)) //CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM
	If AGG->(MsSeek(xFilial("AGG")+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI)) .and. nX==1
		While !AGG->(EOF()).and. (SC5->C5_FILIAL+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI==;
			AGG->AGG_FILIAL+AGG->AGG_PEDIDO+AGG->AGG_FORNEC+AGG->AGG_LOJA)
			RecLock("AGG",.F.)
			AGG->(dbDelete()) 
			MsUnlock()
			AGG->(DbSkip())
		Enddo
	EndIf
	RestArea(aAreaAGG)
Endif 

If IsInCallStack("A410INCLUI")
	lBkpINCLUI := .T.
	If Type("INCLUI") == "L"
		INCLUI := lBkpINCLUI
	EndIf
EndIf

If !lXml
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica a Numeracao do pedido de venda                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SC5")
	cPedido := M->C5_NUM
	If ( INCLUI )
		cMay := "SC5"+ Alltrim(xFilial("SC5"))
		SC5->(dbSetOrder(1))
		While ( DbSeek(xFilial("SC5")+cPedido) .or. !MayIUseCode(cMay+cPedido) )
			cPedido := Soma1(cPedido,Len(M->C5_NUM))
		EndDo
	EndIf
	M->C5_NUM := cPedido
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁGuarda o numero do registro do itens que serao alterados                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Empty(aRegSC6) .And. !INCLUI
		dbSelectArea("SC6")
		dbSetOrder(1)

		cArqQry := "A410GRAVA"
		cQuery := "SELECT SC6.R_E_C_N_O_ SC6RECNO, SC6.C6_FILIAL, SC6.C6_NUM "
		cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
		cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
		cQuery += "SC6.C6_NUM='"+M->C5_NUM+"' AND "
		cQuery += "SC6.D_E_L_E_T_=' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
		
		cFilSC6 := xFilial("SC6")

		While ( (cArqQry)->( !Eof() ) .And. cFilSC6==(cArqQry)->C6_FILIAL .And.(cArqQry)->C6_NUM==M->C5_NUM )

			aAdd(aRegSC6,(cArqQry)->SC6RECNO)

			(cArqQry)->( DBSkip() )

		EndDo

	
		(cArqQry)->( DBCloseArea() )
		DBSelectArea("SC6")	
	EndIf
	
	If Empty(aRegSCV) .And. !INCLUI
		
		SCV->( DBSetOrder( 1 ) )
	
		cArqQry := "A410GRAVA"
		cQuery := "SELECT SCV.R_E_C_N_O_ SCVRECNO,SCV.CV_FILIAL,SCV.CV_PEDIDO "
		cQuery += "FROM "+RetSqlName("SCV")+" SCV "
		cQuery += "WHERE SCV.CV_FILIAL='"+xFilial("SCV")+"' AND "
		cQuery += "SCV.CV_PEDIDO='"+M->C5_NUM+"' AND "
		cQuery += "SCV.D_E_L_E_T_=' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
		cFilSCV := xFilial("SCV") 
		
		While ( (cArqQry)->( !Eof() ) .And. cFilSCV==(cArqQry)->CV_FILIAL .And.(cArqQry)->CV_PEDIDO=M->C5_NUM )

			aAdd(aRegSCV,(cArqQry)->(Recno()))

			(cArqQry)->( DBSkip() )

		EndDo
		
		(cArqQry)->( DBCloseArea() )
		dbSelectArea("SCV")	

	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza os dados do pedido do venda                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lContinua
		
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Prepara a contabilizacao On-Line do Pedido              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lCtbOnLine
			
			dbSelectArea("SX5")
			dbSetOrder(1)
			If MsSeek(xFilial()+"09FAT")          // Verifica o numero do lote contabil
				cLoteCtb := AllTrim(X5Descri())
			Else
				cLoteCtb := "FAT "
			EndIf
			
			If At(UPPER("EXEC"),X5Descri()) > 0   // Executa um execblock
				cLoteCtb := &(X5Descri())
			EndIf
			
			nHdlPrv:=HeadProva(cLoteCtb,"MATA410",Subs(cUsuario,7,6),@cArqCtb) // Inicializa o arquivo de contabilizacao
			
			If nHdlPrv <= 0
				HELP(" ",1,"SEM_LANC")
				lCtbOnLine := .F.
			EndIf
			
		Endif
		
	
		For nX := 1 To nMaxFor
				
			Begin Transaction
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё M_SER004_CRM019_IntegraГao_Faturamento_DPR                           Ё
			//Ё Verifica se o item eh do tipo "Desenvolvimento" e grava num Array    Ё
			//Ё	para incluir ou alterar uma pendencia de desenvolvimento.			   Ё
			//Ё Autor: Alexandre Felicio													   Ё
			//Ё Data: 06/05/2014															   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ( Type("lExAutoDPR") == "L" .And. !lExAutoDPR .Or. IsInCallStack("MaBxOrc") )  .And. ( lIFatDpr ) .And. ( SC6->(FieldPos("C6_TPPROD")) > 0 )  .And. ( AliasInDic("DGC") ) .And. ( AliasInDic("DGP") )
				If ( ( nOpcao == 3 ) .AND. aCols[nX][nTpProd] == "2" .AND. !IsInCallStack("MaBxOrc")  )
					If !l410Auto
						lContinua := MsgYesNo("Desenvolvimento?")
					EndIf
					If lContinua
						aItemDPR := {5, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto]}
					EndIf
				ElseIf ( nOpcao <> 3 .AND. !aCols[nX][nDeleted] )
					// se efetivaГЦo do orГamento o aItemDPR recebe tanto os dados do orГamento como do PD que estА sendo gerado
					If ( IsInCallStack("MaBxOrc") .And. aCols[nX][nTpProd] == "2" )
						aItemDPR := {7, xFilial("SC6"), SCK->CK_NUM, SCK->CK_ITEM, SCK->CK_PRODUTO, M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto]}
						// indica que eh um novo item do PV - insere dependencia de desenvolvimento
					ElseIf (Len(aRegSC6) < nX) .And. (aCols[nX][nTpProd] == "2")
						aItemDPR := {3, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
						// indica que nao eh um novo item, entao verifica se houve alteracao do codigo do produto ou tipo do produto
					Else
						If (Type("aColsHist") == "A") .And. (nX <= LEN(aColsHist))
							If (aColsHist[nX][nPProduto] <> aCols[nX][nPProduto])
								aItemDPR := {4, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], aColsHist[nX][nPPRoduto]}
							ElseIf ( (aColsHist[nX][nTpProd] == "1") .And. (aCols[nX][nTpProd] == "2") )
								aItemDPR := {3, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
							ElseIf ( (aColsHist[nX][nTpProd] == "2") .And. (aCols[nX][nTpProd] == "1") )
								aItemDPR := {5, xFilial("SC6"), M->C5_NUM, aCols[nX][nPItem], aCols[nX][nPPRoduto], ""}
							EndIf
						EndIf
					EndIf
				EndIf
				
				If Len(aItemDPR) > 0 .AND. lContinua
					lGravou := A410GrvDPR(aItemDPR)
					aItemDPR := {}
				EndIf
			EndIf
			
			If lGravou
				
				INCLUI := lBkpINCLUI
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se for o primeiro item e nao for exclusao, grava o cabecalho           Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nX == 1 .And. nOpcao <> 3
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Estorna  o cabecalho do pedido de venda                                Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !INCLUI
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Armazena a moeda original do pedido de venda                           Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nMoedaOri := SC5->C5_MOEDA
						MaAvalSC5("SC5",2,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,@nVlrCred)
					EndIf
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza o cabecalho do pedido de venda                                Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lGravou
						RecLock("SC5",INCLUI)

						For nY := 1 TO FCount()
							If ("FILIAL" $ FieldName(nY) )
								FieldPut(nY,xFilial("SC5"))
            				ElseIf ("SERSUBS" $ FieldName(nY) .Or. "C5_SDOCSUB" $ FieldName(nY) ) // Tratamento para gravar os campos C5_SERSUBS E C5_SDOCSUB
								 If FieldName(nY) <> "C5_SDOCSUB"
									// Monta o Id para o campo C5_SERSUBS
									cSerieId := SerieNfId("SC5",4,"C5_SERSUBS",dDataBase,A460Especie( AllTrim( M->&(EVAL(bCampo,nY))) ), AllTrim( M->&(EVAL(bCampo,nY)) ) ) 
									// grava os campos C5_SERSUBS E C5_SDOCSUB		
									SerieNfId("SC5",1,"C5_SERSUBS",,,, cSerieId ) 
								EndIf
							ElseIf (("TABELA" $ FieldName(nY)) .And. (M->&(EVAL(bCampo,nY)) == PadR("1",Len(DA0->DA0_CODTAB))))
								FieldPut(nY,"")
							Else
								FieldPut(nY,M->&(EVAL(bCampo,nY)))
							EndIf
						Next nY
						SC5->C5_BLQ := ""
						
						//
						// Template GEM - Gestao de Empreendimentos Imobiliarios
						// Gravacao dos solidarios do cliente do pedido de venda
						//
						If lGeMxGrSol
							ExecTemplate("GEMXGRSOL",.F.,.F.,{nOpcao ,M->C5_NUM})
						EndIf
						
						//
						// Template GEM - Gestao de Empreendimentos Imobiliarios
						// Gravacao da condicao de venda "personalizada"
						//
						If lGeMxGrcVnd
							ExecBlock("GEMXGRCVND",.F.,.F.,{nOpcao ,M->C5_NUM ,M->C5_CONDPAG})
						ElseIf lTGeMxGrcVnd
							ExecTemplate("GEMXGRCVND",.F.,.F.,{nOpcao ,M->C5_NUM ,M->C5_CONDPAG})
						EndIf
						
						// Contabiliza cabeГalho - LanГamento PadrЦo 621
						If lCtbOnLine
							nTotalCtb+=DetProva(nHdlPrv,"621","MATA410",cLoteCtb)
						EndIf
						
					EndIf
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza as formas de pagamento                                        Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If Len(aColsFor) >= 1 .And. !Empty(aColsFor[1][1])
						SC5->(FkCommit())
						For nY := 1 To nMaxFor2
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//ЁVerifica se sera alteracao ou inclusao                                  Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If ( Len(aRegSCV) >= nY )
								dbSelectArea("SCV")
								MsGoto(aRegSCV[nY])
								RecLock("SCV",.F.)
								lTravou2 := .T.
							Else
								If ( !aColsFor[nY][nDeleted2] )
									RecLock("SCV",.T.)
									lTravou2 := .T.
								Else
									lTravou2 := .F.
								EndIf
							EndIf
							If aColsFor[nY][nDeleted2]
								If lTravou2
									SCV->(dbDelete())
								EndIf
							Else
								For nZ := 1 To Len(aHeadFor)
									If aHeadFor[nZ][10] <> "V"
										SCV->(FieldPut(FieldPos(aHeadFor[nZ][2]),aColsFor[nY][nZ]))
									EndIf
								Next nZ
								SCV->CV_FILIAL := xFilial("SCV")
								SCV->CV_PEDIDO := M->C5_NUM
								SCV->(MsUnLock())
							EndIf
						Next nY
					EndIf
				
					//здддддддддддддддддддддддддддддддддддддддд©
					//ЁGrava o relacionamento com AdiantamentosЁ
					//юдддддддддддддддддддддддддддддддддддддддды
					If cPaisLoc $ "ANG|BRA" .and. Type( "nAutoAdt" ) == "N" .AND. (nAutoAdt==3 .OR. nAutoAdt==4) //.OR. nAutoAdt==5
						If A410UsaAdi( SC5->C5_CONDPAG )
							IF Len(aAdtPC) > 0
								If nAutoAdt==3
									If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt) > 0
										FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
										FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
									Endif
								Else
									If a410lCkAdtFR3(SC5->C5_NUM,nAutoAdt)==0
										If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt,0) > 0 //Verifica saldo sem apresentar HELP
											FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
											FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
										Else
											If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt,2) > 0 //Verifica se ao excluir ADT haverА saldo para nova inclusao
												FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
												If a410AdtSld(SC5->C5_NUM,aAdtPC,nAutoAdt) > 0
													FPedAdtGrv("R", 1, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
												Endif
											Endif
										Endif
									Else
										Help(" ",1,"A410ADTEMUSO") //"Pedido possui compensaГЦo por RA, nЦo pode ser alterado ou excluido!"
									Endif
								Endif
							Else
								If nAutoAdt==4
									If a410lCkAdtFR3(SC5->C5_NUM,nAutoAdt)==0
										aRecnoSE1 := FPedAdtPed("R",{SC5->C5_NUM}, .F.,0)
										If Len(aRecnoSE1)<>0
											FPedAdtGrv("P", 2, SC5->C5_NUM, aRecnoSE1)
										Endif
									Else
										Help(" ",1,"A410ADTEMUSO") //"Pedido possui compensaГЦo por RA, nЦo pode ser alterado ou excluido!"
									Endif
								Endif
							Endif
						Else
							If nAutoAdt==4
								If a410lCkAdtFR3(SC5->C5_NUM,nAutoAdt)==0
									If A410UsaAdi( cCondPOld )
										FPedAdtGrv("R", 2, SC5->C5_NUM, aRecnoSE1,,,,aAdtPC,nAutoAdt)
									Endif
								Else
									Help(" ",1,"A410ADTEMUSO") //"Pedido possui compensaГЦo por RA, nЦo pode ser alterado ou excluido!"
								Endif
							Endif
						Endif
					Else
						If cPaisLoc $ "ANG|BRA|MEX"
							If A410UsaAdi( SC5->C5_CONDPAG ) .AND. ((cPaisLoc == "MEX" .AND. !A410NatAdi(SC5->C5_NATUREZ)) .OR. cPaisLoc <> "MEX")
								FPedAdtGrv( "R", 1, SC5->C5_NUM, aRecnoSE1 )
							EndIf
						Endif
					EndIf
				EndIf
					
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza os itens do pedido de venda                                   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁVerifica se sera alteracao ou inclusao de um item do PV                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ( Len(aRegSC6) >= nX )
					
					
					If aRegStatus[ nX ]
						SC6->( MsGoto( aRegSC6[nX] ) )
					Endif
									
					If aRegStatus[ nX ]
					    If SC6->C6_GRADE=="S" .And. ( IsAtNewGrd() )
							cProdRef := aCols[nX][nPProduto]
							MatGrdPrRf(@cProdRef,.T.)
							nTamRef	:= Len(cProdRef)
						EndIf
						
						If ( aCols[nX][nPItem] <> SC6->C6_ITEM .Or. (aCols[nX][nPProduto] <> SC6->C6_PRODUTO .And. SubStr(aCols[nX][nPProduto],1,nTamRef) == SubStr(SC6->C6_PRODUTO,1,nTamRef)) .And.;
							SC6->C6_GRADE=="S" )
							If ( !aCols[nX][nDeleted] )
								RecLock("SC6",.T.)
								lTravou := .T.
							Else
								lTravou := .F.
							EndIf
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//ЁMove os Recnos do SC6 para posterior atualizacao                        Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							aAdd(aRegSC6,0)
							aAdd(aRegStatus,.T.)
							For nZ := Len(aRegSC6) To nX+1 STEP -1
								aRegSC6[nZ] := aRegSC6[nZ-1]
							Next nZ
						EndIf
					Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//ЁCaso o produto tenha sido trocado sera estornado o registro e incluido  Ё
						//Ёnovamente. Somsnte quando a troca for por produto de grade              Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						
						RecLock( "SC6", .T. )
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//ЁAtualiza os itens do pedido de venda                                    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						For nY := 1 to Len(aHeader)
							If aHeader[nY][10] <> "V"
								If AllTrim(aHeader[nY][2]) == "C6_SERIORI" .Or. AllTrim(aHeader[nY][2]) == "C6_SDOCORI"
									If AllTrim(aHeader[nY][2]) <> "C6_SDOCORI"
										SerieNfId("SC6",1,"C6_SERIORI",,,, aCols[nX][nY] )
									EndIf 	
								Else
									SC6->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
								EndIf
							EndIf
						Next nY
						If SC6->C6_QTDLIB > 0 .Or. IIf(cPaisLoc == "BRA",;
							(SC5->C5_TIPO $ "IP" .Or. (SC5->C5_TIPO $ "C" .And. SC5->C5_TPCOMPL == "1")),;
							SC5->C5_TIPO $ "CIP")
							lLiberou := .T.
						EndIf
						MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred)
						
						//Grava relacionamento entre SC6 e SD4,SDC
						If !Empty(aEmpBn)
							nY := aScan(aEmpBn, {|x| x[3] == SC6->C6_ITEM})
							While !Empty (nY) .AND. nY <= Len(aEmpBn) .And. aEmpBn[nY,3] == SC6->C6_ITEM
								(aEmpBn[nY,1])->(dbGoTo(aEmpBn[nY,2]))
								If nTpCtlBN == 1 // metodo antigo - unico envio: gravacao na SD4
									RecLock(aEmpBn[nY,1],.F.)
									If aEmpBn[nY,1] == "SD4"
										Replace D4_NUMPVBN With SC6->C6_NUM
										Replace D4_ITEPVBN With SC6->C6_ITEM
									Else
										Replace DC_PEDIDO With SC6->C6_NUM
										Replace DC_ITEM   With SC6->C6_ITEM
									EndIf
									MsUnLock()
								ElseIf nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
									If aEmpBn[nY,1] == "SDC"
										RecLock("SDC",.F.)
										Replace DC_PEDIDO With SC6->C6_NUM
										Replace DC_ITEM   With SC6->C6_ITEM
									ElseIf aEmpBn[nY,1] == "SD4"
										SGO->(dbSetOrder(2)) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
										If !(SGO->(dbSeek(xFilial("SGO")+SC6->C6_NUM+SC6->C6_ITEM+SD4->D4_OP+SD4->D4_COD+SD4->D4_LOCAL)))
											RecLock("SGO",.T.)
											Replace GO_FILIAL  With xFilial("SGO")
											Replace GO_OP      With SD4->D4_OP
											Replace GO_COD     With SD4->D4_COD
											Replace GO_LOCAL   With SD4->D4_LOCAL
											Replace GO_NUMPV   With SC6->C6_NUM
											Replace GO_ITEMPV  With SC6->C6_ITEM
											Replace GO_TRT     With SD4->D4_TRT
											Replace GO_RECNOD4 With SD4->(Recno())
										Else
											RecLock("SGO", .F.)
										EndIf
										Replace GO_QUANT   With SC6->C6_QTDVEN
										Replace GO_QTSEGUM With ConvUM(SD4->D4_COD, SC6->C6_QTDVEN, 0, 2)
									EndIf
									MsUnLock()
								EndIf
								nY++
							End
						EndIf
					Endif
				Else
					If ( !aCols[nX][nDeleted] )
						RecLock("SC6",.T.)
						lTravou := .T.
					Else
						lTravou := .F.
					EndIf
				EndIf
			
				
				If aCols[nX][nDeleted]
					
					If (lTravou)
						
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Grava os lancamentos nas contas orcamentarias SIGAPCO    Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						PcoDetLan("000100","02","MATA410")
						
						//-- Libera empenhos vinculados ao item do pedido
						If nTpCtlBN == 1 // metodo antigo - unico envio: gravacao na SD4
							dbSelectArea("SD4")
							dbSetOrder(6)
							If dbSeek(xFilial("SD4")+SC6->(C6_NUM+C6_ITEM))
								RecLock("SD4",.F.)
								Replace D4_NUMPVBN With CriaVar("D4_NUMPVBN",.F.)
								Replace D4_ITEPVBN With CriaVar("D4_ITEPVBN",.F.)
								MsUnLock()
							EndIf
							dbSelectArea("SDC")
							dbSetOrder(1)
							If dbSeek(xFilial("SDC")+SC6->(C6_PRODUTO+C6_LOCAL)+"SC2"+SC6->(C6_NUM+C6_ITEM))
								RecLock("SDC",.F.)
								Replace DC_PEDIDO With CriaVar("DC_PEDIDO",.F.)
								Replace DC_ITEM	With CriaVar("DC_ITEM",.F.)
								MsUnLock()
							EndIf
						ElseIf nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
							dbSelectArea("SGO")
							dbSetOrder(2) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
							dbSeek(xFilial("SGO")+SC6->C6_NUM+SC6->C6_ITEM)
							If ( GO_FILIAL+GO_NUMPV+GO_ITEMPV == SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM )
								RecLock("SGO", .F.)
								dbDelete()
								MsUnLock()
							EndIf
							dbSelectArea("SDC")
							dbSetOrder(1)
							If dbSeek(xFilial("SDC")+SC6->(C6_PRODUTO+C6_LOCAL)+"SC2"+SC6->(C6_NUM+C6_ITEM))
								RecLock("SDC",.F.)
								Replace DC_PEDIDO With CriaVar("DC_PEDIDO",.F.)
								Replace DC_ITEM	With CriaVar("DC_ITEM",.F.)
								MsUnLock()
							EndIf
						EndIf
						
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Executa a exclusao da tabela SGJ                    Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lAtuSGJ
							A650DelSGJ("I")		//Por Item
						Endif
						
						//зддддддддддддддддддддддддддд©
						//ЁEfetua a ExclusЦo do RateioЁ
						//юддддддддддддддддддддддддддды
						
						aAreaAGG := GetArea()
						If (nY	:= aScan(aColsAGG,{|x| AllTrim(x[1]) == AllTrim(SC6->C6_ITEM) })) > 0
							For nZ := 1 To Len(aColsAGG[nY][2])
								AGG->(DbSetOrder(1)) //AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM
								If AGG->(MsSeek(xFilial("AGG")+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_ITEM+GdFieldGet("AGG_ITEM",nz,NIL,aHeadAGG,ACLONE(aColsAGG[NY,2]))))
									RecLock("AGG",.F.)
									AGG->(dbDelete())
									MsUnlock()
								EndIf
							Next nZ
						EndIf
						RestArea(aAreaAGG)
						
						SC6->( DBDelete() )
						MsUnLock()
						
						// Verifica se o C5_DTLANC esta preenchido, se estiver preenchido contabiliza a exclusЦo dos itens.
						If lCtbOnLine
							If !Empty(SC5->C5_DTLANC)
								nTotalCtb+=DetProva(nHdlPrv,"632","MATA410",cLoteCtb)
							Endif
						EndIf
						
					EndIf
				Else
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁAtualiza os itens do pedido de venda                                    Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					For nY := 1 to Len(aHeader)
						If aHeader[nY][10] <> "V"
						    If cOmsCplInt == "1"
						        If (TRIM(aHeader[nY][2]) == "C6_INTROT") .And. SC6->C6_INTROT != aCols[nX][nY]
						            aCols[nX][nY] := IIF(Empty(SC6->C6_INTROT),"1",SC6->C6_INTROT)
						        EndIf
								If (TRIM(aHeader[nY][2]) == "C6_DATCPL")
									aCols[nX][nY] := SC6->C6_DATCPL
						        EndIf
								If (TRIM(aHeader[nY][2]) == "C6_HORCPL")
						            aCols[nX][nY] := SC6->C6_HORCPL
						        EndIf
						    EndIf
							If AllTrim(aHeader[nY][2]) == "C6_SERIORI" .Or. AllTrim(aHeader[nY][2]) == "C6_SDOCORI"
								If AllTrim(aHeader[nY][2]) <> "C6_SDOCORI"
									SerieNfId("SC6",1,"C6_SERIORI",,,, aCols[nX][nY] )
								EndIf
							Else
								SC6->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
							EndIf
						EndIf
					Next nY
												
					// Se for alteracao, e mudaram o cliente do pedido, nao considerar o valor o estorno
					// como um credito, pois o estorno considera um cliente e a gravacao considera outro.
					If nOpcao == 2 .And. (SC6->C6_CLI+SC6->C6_LOJA <> M->C5_CLIENTE+M->C5_LOJACLI)
						nVlrCred := 0
					EndIf
					SC6->C6_FILIAL	:= xFilial("SC6")
					SC6->C6_NUM		:= M->C5_NUM
					SC6->C6_CLI		:= M->C5_CLIENTE
					SC6->C6_LOJA 	:= M->C5_LOJACLI
					
					// Contabiliza itens do pedido de venda
					If lCtbOnLine
						nTotalCtb+=DetProva(nHdlPrv,"612","MATA410",cLoteCtb)
					EndIf
					
					If SC6->C6_QTDLIB > 0 .Or. IIf(cPaisLoc == "BRA",;
						(SC5->C5_TIPO $ "IP" .Or. (SC5->C5_TIPO $ "C" .And. SC5->C5_TPCOMPL == "1")),;
						SC5->C5_TIPO $ "CIP")
						lLiberou := .T.
					EndIf
					
					//Grava relacionamento entre SC6 e SD4,SDC
					If !Empty(aEmpBn)
						aAreaAtu := GetArea()
						nY := aScan(aEmpBn, {|x| x[3] == SC6->C6_ITEM})
						While !Empty (nY) .AND. nY <= Len(aEmpBn) .And. aEmpBn[nY,3] == SC6->C6_ITEM
							(aEmpBn[nY,1])->(dbGoTo(aEmpBn[nY,2]))
							If nTpCtlBN == 1 // metodo antigo - unico envio: gravacao na SD4
								RecLock(aEmpBn[nY,1],.F.)
								If aEmpBn[nY,1] == "SD4"
									Replace D4_NUMPVBN With SC6->C6_NUM
									Replace D4_ITEPVBN With SC6->C6_ITEM
								Else
									Replace DC_PEDIDO With SC6->C6_NUM
									Replace DC_ITEM   With SC6->C6_ITEM
								EndIf
								MsUnLock()
							ElseIf nTpCtlBN == 2 // metodo novo - multiplos envios: gravacao na SGO
								If aEmpBn[nY,1] == "SDC"
									RecLock("SDC",.F.)
									Replace DC_PEDIDO With SC6->C6_NUM
									Replace DC_ITEM   With SC6->C6_ITEM
								ElseIf aEmpBn[nY,1] == "SD4"
									SGO->(dbSetOrder(2)) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
									If !(SGO->(dbSeek(xFilial("SGO")+SC6->C6_NUM+SC6->C6_ITEM+SD4->D4_OP+SD4->D4_COD+SD4->D4_LOCAL)))
										RecLock("SGO",.T.)
										Replace GO_FILIAL  With xFilial("SGO")
										Replace GO_OP      With SD4->D4_OP
										Replace GO_COD     With SD4->D4_COD
										Replace GO_LOCAL   With SD4->D4_LOCAL
										Replace GO_NUMPV   With SC6->C6_NUM
										Replace GO_ITEMPV  With SC6->C6_ITEM
										Replace GO_TRT     With SD4->D4_TRT
										Replace GO_RECNOD4 With SD4->(Recno())
									Else
										RecLock("SGO", .F.)
									EndIf
									Replace GO_QUANT   With SC6->C6_QTDVEN
									Replace GO_QTSEGUM With ConvUM(SD4->D4_COD, SC6->C6_QTDVEN, 0, 2)
								EndIf
								MsUnLock()
							EndIf
							nY++
						End
						RestArea(aAreaAtu)
					EndIf
					
					If Type('aMemoSC6') <> 'U'
						For nI := 1 To Len(aMemoSC6)
							cCpoSC6 := aMemoSC6[nI,1]
							MSMM(&cCpoSC6,,,GDFieldGet( aMemoSC6[nI,2], nX ),1,,,'SC6',aMemoSC6[nI,1])
						Next nI
					EndIf
				
					MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,@nVlrCred)
						
					If lAtuSGJ
						A650AvalPV()
					Endif
					
					If (nY	:= aScan(aColsAGG,{|x| Alltrim(x[1]) == Alltrim(SC6->C6_ITEM) })) > 0
						For nZ := 1 To Len(aColsAGG[nY][2])
							If Type( "nAutoAdt" ) == "N" .AND. nAutoAdt == 0
								cItemSCH := GdFieldGet("AGG_ITEM",nz,NIL,aHeadAGG,ACLONE(aColsAGG[NY,2]))
							Else
								cItemSCH := aRatCTBPC[nY][2][nZ][aScan(aRatCTBPC[nY][2][nZ],{|x| x[1] == "AGG_ITEM"})][2]
							EndIf
							AGG->(DbSetOrder(1)) //AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM
							lAchou:=AGG->(MsSeek(xFilial("AGG")+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_ITEM+cItemSCH) )
							If !aColsAGG[nY][2][nZ][nUsadoAGG+1]
								RecLock("AGG",!lAchou)
								For nW := 1 To nUsadoAGG
									If aHeadAGG[nW][10] <> "V"
										AGG->(FieldPut(FieldPos(aHeadAGG[nW][2]),aColsAGG[nY][2][nZ][nW]))
									EndIf
								Next nW
								AGG->AGG_FILIAL	:= xFilial("AGG")
								AGG->AGG_PEDIDO	:= SC5->C5_NUM
								AGG->AGG_FORNEC:= SC5->C5_CLIENTE
								AGG->AGG_LOJA	:= SC5->C5_LOJACLI
								AGG->AGG_ITEMPD	:= SC6->C6_ITEM
								MsUnlock()
							ElseIf lAchou
								RecLock("AGG",.F.)
								AGG->(dbDelete())
								MsUnlock()
							EndIf
						Next nZ
					EndIf
				EndIf
				
				
				If SC5->C5_TIPLIB=="2" .And. !aCols[nX][nDeleted]
					aAdd(aRegLib,SC6->(RecNo()))
				EndIf
			EndIf
			
			CLOSETRANSACTION LOCKIN "SC5,SC6"
			
		Next nX
		
		Begin Transaction
		
		If ( lGravou )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁVerifica a liberacao por pedido de venda                                Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ( SC5->C5_TIPLIB=="2" .And. (lLiberou .Or. MaTesSel(SC6->C6_TES)) )
				MaAvalSC5("SC5",3,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,Nil,Nil,aRegLib,Nil,Nil,@nVlrCred)
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁAtualiza os acumulados do SC5                                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,Nil,Nil,Nil,Nil,Nil,Nil,@nVlrCred)
			If INCLUI
				While GetSX8Len() > nStack
					ConfirmSX8()
				EndDo
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Pontos de entrada para todos os itens do pedido.    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ExistTemplate("MTA410T")
				ExecTemplate("MTA410T",.F.,.F.)
			EndIf
			
			If nModulo == 72
				KEXF920()
			EndIf
			
			If nOpcao <> 3 .And. ExistBlock("MTA410T")
				ExecBlock("MTA410T",.F.,.F.)
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё  Processa Gatilhos                                   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			EvalTrigger()
						
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁEXECUTAR CHAMADA DE FUNCAO p/ integracao com sistema de Distribuicao - NAO REMOVER Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SuperGetMv("MV_FATDIST") == "S" // Apenas quando utilizado pelo modulo de Distribuicao
				D630Descon(cPedido)
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Envia os dados para o modulo contabil             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lCtbOnLine
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina)
				EndIf
			EndIf
			
			// Flag de contabilizaГЦo on-line.
			If lCtbOnLine
				RecLock("SC5")
				SC5->C5_DTLANC := dDataBase
				MsUnlock()
			Endif
			
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁAdiciona ou Remove o privilegios deste registro.  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддды
		If lGravou .And. (nOpcao == 1 .OR. nOpcao == 3)
			
			If !Empty(RetCodUsr())
				cCodUsr := RetCodUsr() //UsuАrio do protheus
			Else
				cCodUsr := UsrPrtErp() //Usuario do portal
			EndIf
			
			AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
			
			If AO3->(MsSeek(xFilial("AO3")+cCodUsr))
			
				nOperation	:= IIF(nOpcao==1,MODEL_OPERATION_INSERT,MODEL_OPERATION_DELETE)
				cChave 	:= PadR(xFilial("SC5")+M->C5_NUM,TAMSX3("AO4_CHVREG")[1])
				aAutoAO4	:= CRMA200PAut(nOperation,"SC5",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
			
				If nOperation == MODEL_OPERATION_INSERT
					If !Empty(M->C5_VEND1) .AND. AO3->AO3_VEND <> M->C5_VEND1
						AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
						If AO3->(DbSeek(xFilial("AO3")+M->C5_VEND1))
							aAutoAO4Aux := CRMA200PAut(nOperation,"SC5",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,cCodUsr,/*dDataVld*/)
							aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
						EndIf
					EndIf		
				EndIf
			
				CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
					
			EndIf
			
		EndIf
		
		End Transaction
	EndIf
Else
	lGravou := lXml
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Aciona integraГЦo via mensagem Зnica          				Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FWHasEAI("MATA410",.T.,,.T.) .And. lGravou
	If M->C5_TIPO == "N"
		FwIntegDef( 'MATA410' )
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para refazer as liberaГУes de estoque considerando o  Ё
//Ё os registros de SDC da liberaГЦo anterior...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( (ExistBlock("M410RLIB") ) )
	aSaldoSDC := ExecBlock("M410RLIB",.f.,.f.,aSaldoSDC)
EndIf

RestArea(aArea)

Return(lGravou) 
