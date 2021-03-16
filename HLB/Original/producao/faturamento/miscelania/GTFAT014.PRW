
#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "Protheus.CH"
#Include "tbiconn.ch"

/*
Funcao      :GTFAT014()
Parametros  :MV_P_SEMAIL
Retorno     :
Objetivos   :Gera tela de seleção de titulos que iram gerar fatura e boletos.
Autor       :João Silva
Data        :25/11/2014
Revisão     :Leandro Brito - 02/10/2015 - Adaptação do fonte TPFIN001.PRW para padrão GT .
Data/Hora   :
Módulo      :Financeiro
*/

//Função Principal para geração da tela.
*-------------------------*
User Function GTFAT014()
*-------------------------*
Local oDlg
Local aCampos  :={}
Local aButtons :={}

Local aColors  :={}
Local lInverte :=.F.

Local aSize	   :={}
Local aObjects :={}  

Local lRet := .T.  
Local cDirBol  := "\FTP\" + cEmpAnt + "\GTFAT001\"

Private cPerg  :="GTFAT001" 
Private cVer1  :='N'

Private aStruSF2 :={}
Private cMarca := GetMark()

Private lExibe  := .F.
Private cAlias:= "Temp1"

Private aIndex:= {}
Private cNomeEmp := Capital( AllTrim( SM0->M0_NOMECOM ) )

Private cCO_Cli  := AllTrim(GetNewPar("MV_P_00054",""))   //** Copia Oculta Cliente
Private cCO_GT   := AllTrim(GetNewPar("MV_P_00055",""))  //** Copia Oculta GT

Private cFBoleto := AllTrim(GetNewPar("MV_P_00057",""))  //** Funcao para execucao do boleto
Private cFFatura := AllTrim(GetNewPar("MV_P_00058",""))  //** Funcao para execucao da fatura


Private bExec, lRetFun
Private cTpSel := ""

//Validação de empresa


If !( cEmpAnt $ "B1"  )
	Alert("Função não disponivel para esta empresa","HLB BRASIL")
	Return()
Endif

If Empty( cFFatura ) .And. Empty( cFBoleto )

	MsgStop( 'Obrigatório informar rotina para impressao do boleto ou fatura . Favor contatar a TI .' ,"HLB BRASIL" )	
	Return
	
EndIf	

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\GTFAT001\" )		
EndIf	



If cEmpAnt <> 'B1'
	SetKey(VK_F11,{|| Config() } )    
EndIf	


//Verifico que se existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea())
EndIf

//Cor e regra das legendas
aAdd(aColors,{"AllTrim(Temp1->F2_P_ENV) =='S'","BR_VERMELHO"})
aAdd(aColors,{"AllTrim(Temp1->A1_EMAIL)<>''.And.AllTrim(Temp1->F2_P_ENV) ==''","BR_VERDE"})
aAdd(aColors,{"AllTrim(Temp1->A1_EMAIL)==''","BR_AMARELO"})

//Campos do MarkBrowse (Cabeçalho da tabela)
aAdd(aCampos,{"cEnvia"    	,"",               	 })
aAdd(aCampos,{"F2_DOC"		,"","Nota Fiscal"	,})
aAdd(aCampos,{"F2_SERIE"	,"","Serie Fiscal"	,})
aAdd(aCampos,{"F2_EMISSAO"	,"","Emissao"	,})
aAdd(aCampos,{"C5_NUM"		,"","Pedido"		,})
aAdd(aCampos,{"F2_CLIENT"	,"","Cliente"		,})
aAdd(aCampos,{"F2_LOJA"	,"","Loja"		,})
aAdd(aCampos,{"A1_NOME" 	,"","Nome Cliente"	,})
aAdd(aCampos,{"F2_VALBRUT"  ,"","Total"			,})
aAdd(aCampos,{"A1_EMAIL"    ,"","Email"			,})

//Estrutura da tabela
aAdd(aStruSF2,{"cEnvia"    			,"C"				 ,2  	  ,0})
aAdd(aStruSF2,{"A1_COD"		,AvSx3("A1_COD"	   ,2),AvSx3("A1_COD"		,3)   ,AvSx3("A1_COD"	 ,4)})
aAdd(aStruSF2,{"A1_NOME"	,AvSx3("A1_NOME"   ,2),AvSx3("A1_NOME"		,3)   ,AvSx3("A1_NOME"	 ,4)})
aAdd(aStruSF2,{"A1_NREDUZ"	,AvSx3("A1_NREDUZ" ,2),AvSx3("A1_NREDUZ"	,3)   ,AvSx3("A1_NREDUZ" ,4)})
aAdd(aStruSF2,{"A1_END"		,AvSx3("A1_END"	   ,2),AvSx3("A1_END"		,3)   ,AvSx3("A1_END"	 ,4)})
aAdd(aStruSF2,{"A1_ESTADO"	,AvSx3("A1_ESTADO" ,2),AvSx3("A1_ESTADO"	,3)   ,AvSx3("A1_ESTADO" ,4)})
aAdd(aStruSF2,{"A1_CEP"		,AvSx3("A1_CEP"    ,2),AvSx3("A1_CEP"		,3)   ,AvSx3("A1_CEP"	 ,4)})
aAdd(aStruSF2,{"A1_CODPAIS"	,AvSx3("A1_CODPAIS",2),AvSx3("A1_CODPAIS"	,3)	  ,AvSx3("A1_CODPAIS",4)})
aAdd(aStruSF2,{"A1_CGC"		,AvSx3("A1_CGC"	   ,2),AvSx3("A1_CGC"		,3)	  ,AvSx3("A1_CGC"	 ,4)})
aAdd(aStruSF2,{"B1_DESC"	,AvSx3("B1_DESC"   ,2),AvSx3("B1_DESC"		,3)   ,AvSx3("B1_DESC"	 ,4)})
aAdd(aStruSF2,{"C5_EMISSAO"	,AvSx3("C5_EMISSAO",2),AvSx3("C5_EMISSAO"	,3)   ,AvSx3("C5_EMISSAO",4)})
aAdd(aStruSF2,{"C5_NUM"		,AvSx3("C5_NUM"    ,2),AvSx3("C5_NUM"		,3)   ,AvSx3("C5_NUM"	 ,4)})
aAdd(aStruSF2,{"E4_DESCRI"	,AvSx3("E4_DESCRI" ,2),AvSx3("E4_DESCRI"	,3)   ,AvSx3("E4_DESCRI" ,4)})
aAdd(aStruSF2,{"E4_COND"	,AvSx3("E4_COND"   ,2),AvSx3("E4_COND"		,3)   ,AvSx3("E4_COND"	 ,4)})
aAdd(aStruSF2,{"F2_DOC"		,AvSx3("F2_DOC"    ,2),AvSx3("F2_DOC"		,3)   ,AvSx3("F2_DOC"	 ,4)})
aAdd(aStruSF2,{"F2_SERIE"	,AvSx3("F2_SERIE"  ,2),AvSx3("F2_SERIE"		,3)   ,AvSx3("F2_SERIE"	 ,4)})
aAdd(aStruSF2,{"F2_P_ENV"	,AvSx3("F2_P_ENV"  ,2),AvSx3("F2_P_ENV"		,3)   ,AvSx3("F2_P_ENV"	 ,4)})
aAdd(aStruSF2,{"F2_CLIENT"	,AvSx3("F2_CLIENT" ,2),AvSx3("F2_CLIENT"	,3)   ,AvSx3("F2_CLIENT" ,4)})
aAdd(aStruSF2,{"F2_LOJA"	,AvSx3("F2_LOJA"   ,2),AvSx3("F2_LOJA"		,3)   ,AvSx3("F2_LOJA"   ,4)})
aAdd(aStruSF2,{"F2_VALBRUT"	,AvSx3("F2_VALBRUT",2),AvSx3("F2_VALBRUT"	,3)   ,AvSx3("F2_VALBRUT",4)})
aAdd(aStruSF2,{"F2_EMISSAO"	,AvSx3("F2_EMISSAO",2),AvSx3("F2_EMISSAO"	,3)   ,AvSx3("F2_EMISSAO",4)})
aAdd(aStruSF2,{"A1_EMAIL"	,AvSx3("A1_EMAIL"	   ,2),AvSx3("A1_EMAIL"		,3)   ,AvSx3("A1_EMAIL"	 ,4)})
aAdd(aStruSF2,{"F2_PREFIXO"	,AvSx3("F2_PREFIXO"   ,2),AvSx3("F2_PREFIXO"		,3)   ,AvSx3("F2_PREFIXO"   ,4)})
aAdd(aStruSF2,{"RECSF2"	,    "N",10   ,0})

//Cria tabela temporaria
cNome	:=	CriaTrab(aStruSF2, .T.)
DbUseArea(.T.,"DBFCDX",cNome,'Temp1',.F.,.F.)

IndRegua("Temp1", cNome, "F2_DOC", , , "Selecionando Registros...")

//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf

//Qyery para pegar os dados que seram apresentados
cQuery1 := "	SELECT "
cQuery1 += "	A1.A1_COD,		"
cQuery1 += "	A1.A1_NOME,		"
cQuery1 += "	A1.A1_NREDUZ,	"
cQuery1 += "	A1.A1_END,		"
cQuery1 += "	A1.A1_ESTADO,	"
cQuery1 += "	A1.A1_CEP,		"
cQuery1 += "	A1.A1_CODPAIS,	"
cQuery1 += "	A1.A1_CGC,		"
cQuery1 += "	C5.C5_EMISSAO,	"
cQuery1 += "	C5.C5_NUM,		"
cQuery1 += "	E4.E4_DESCRI,   "
cQuery1 += "	E4.E4_COND,	    "
cQuery1 += "	F2.F2_DOC,		"
cQuery1 += "	F2.F2_SERIE,	"
cQuery1 += " 	F2.F2_P_ENV,	"
cQuery1 += "	F2.F2_CLIENT,	"
cQuery1 += "	F2.F2_LOJA,		"
cQuery1 += "	F2.F2_VALBRUT,	"
cQuery1 += "	F2.F2_EMISSAO,	"
cQuery1 += "	F2.F2_PREFIXO,	"
cQuery1 += "	A1.A1_EMAIL,		"
cQuery1 += "	F2.R_E_C_N_O_ RECSF2 "
cQuery1 += "	FROM "+RETSQLNAME("SF2")+" F2"
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SC5")+" C5"
cQuery1 += "		ON			C5.C5_FILIAL = F2.F2_FILIAL	"
cQuery1 += "				AND C5.C5_NOTA   = F2.F2_DOC 	"
cQuery1 += "				AND C5.C5_CLIENTE= F2.F2_CLIENTE "
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SA1")+" A1"
cQuery1 += "		ON			A1.A1_COD	 = F2.F2_CLIENTE"
cQuery1 += "				AND A1.A1_LOJA	 = F2.F2_LOJA	"
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SE4")+" AS E4					"
cQuery1 += "		ON		E4.E4_FILIAL = F2.F2_FILIAL     "
cQuery1 += "			 	AND E4.E4_CODIGO= F2.F2_COND    "
cQuery1 += "Where "
cQuery1 += "F2.D_E_L_E_T_='' AND F2_FILIAL = '" + xFilial( 'SF2' ) + "' " 

TcQuery cQuery1 Alias "QRY1" New

//Coloco os dados da query na tabela tempararia
QRY1->(DbGoTop())
While QRY1->(!EOF())
	
	RecLock("Temp1",.T.)
	
	Temp1->A1_COD		:= QRY1->A1_COD
	Temp1->A1_NOME		:= QRY1->A1_NOME
	Temp1->A1_NREDUZ	:= QRY1->A1_NREDUZ
	Temp1->A1_END		:= QRY1->A1_END
	Temp1->A1_ESTADO	:= QRY1->A1_ESTADO
	Temp1->A1_CEP	   	:= QRY1->A1_CEP
	Temp1->A1_CODPAIS	:= QRY1->A1_CODPAIS
	Temp1->A1_CGC		:= QRY1->A1_CGC
	Temp1->C5_NUM   	:= QRY1->C5_NUM
	Temp1->C5_EMISSAO	:= STOD(QRY1->C5_EMISSAO)
	Temp1->E4_DESCRI	:= QRY1->E4_DESCRI
	Temp1->E4_COND		:= QRY1->E4_COND
	Temp1->F2_DOC  		:= QRY1->F2_DOC
	Temp1->F2_SERIE		:= QRY1->F2_SERIE
	Temp1->F2_P_ENV		:= QRY1->F2_P_ENV
	Temp1->F2_CLIENT	:= QRY1->F2_CLIENT
	Temp1->F2_LOJA 		:= QRY1->F2_LOJA
	Temp1->F2_VALBRUT	:= QRY1->F2_VALBRUT
	Temp1->F2_EMISSAO	:= STOD(QRY1->F2_EMISSAO)
	Temp1->A1_EMAIL 	:= QRY1->A1_EMAIL
	Temp1->F2_PREFIXO 	:= QRY1->F2_PREFIXO  
	Temp1->RECSF2		:= QRY1->RECSF2
	
	Temp1->(MsUnlock())
	QRY1->(DbSkip())
EndDO

//Cração de botões do ações relacionadas
//aAdd(aButtons,{"PENDENTE",{|| MarcaTds("Temp1")},"Marcar Todos","Marcar Todos",{|| .T.}})
aAdd(aButtons,{"VISUALIZAR",{||cVer1:='S',Email(cVer1)},"Preview","Preview",{|| .T.}})
aAdd(aButtons,{"Legenda",{||Legenda()},"Legenda","Legenda",{|| .T.}})

SetKey(VK_F12,{|| Filtro(.T.,"Temp1",@aIndex)} )

Temp1->(DbGoTop())
If Temp1->(!BOF() .AND. !EOF())
	
	// Faz o calculo automatico de dimensoes de objetos
	aSize := MsAdvSize()
	// Dados da Enchoice
	AAdd( aObjects, { 50, 30, .T., .T. } )
	// Dados da getdados
	AAdd( aObjects, { 50,180, .T., .T. } )
	// Dados da área de trabalho e separação
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	// Chama MsObjSize e recebe array e tamanhos
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	//Criação da janela
	DEFINE MSDIALOG oDlg TITLE "NF SAIDA" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
	
	//@ 04 , 01 TO 25,(aPosObj[1][4])-50 LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-20,aPosObj[1][4] LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+5 Say "Selecione as notas para geração de faturas e boletos." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 500,6 OF oDlg
	
	Filtro(.F.,"Temp1",@aIndex)
	
	oMarkPrd:= MsSelect():New("Temp1","cEnvia",,aCampos,@lInverte,@cMarca,{aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,oDlg,,aColors)
	oMarkPrd:bAval := { || If( !Empty( Temp1->cEnvia ) , Temp1->cEnvia := Space( 2 ) , If( !Empty( Temp1->A1_EMAIL ) , Temp1->cEnvia := ThisMark() , MsgInfo( 'Email nao informado!' ) ) ) , oMarkPrd:oBrowse:Refresh() }
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||cVer1:='N', Processa( { || lRet:=Email(cVer1) } , 'Gerando boleto\fatura ...' ),If(lret,oDlg:End(),)},{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED
	
Else
	MsgInfo("Nenhum dado encontrado para geração do arquivo"," Atenção")
	Return .F.
EndIf

Return

/*
Funcao      : Filtro
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de filtro para MsSelect.
Autor       : Joao Silva
Data/Hora   : 27/06/14
*/
*--------------------------------------------*
Static Function Filtro(lExibe,cAlias,aIndex)
*--------------------------------------------*
Local cFiltro := ""

//Criando Pergunte
CriaPerg()

//Inicializa as variaveis de pergunta. 

/*
	** A primeira vez que entrar na rotina força aparecer a função 'Pergunte()' para o usuario definir filtro
*/
If !lExibe
	Pergunte(cPerg,.f.) 
	If Empty( MV_PAR01 ) .And. Empty( MV_PAR02 )
		lExibe := .T.
	EndIf	
EndIf
	
If lExibe
	IF !(Pergunte(cPerg,lExibe,"Filtro de exibição"))
		Return .F.
	EndIf
Else
	Pergunte(cPerg,lExibe,"Filtro de exibição")
EndIf

//Filtro de data de aemissao.
//cFiltro += "DtoS(Temp1->F2_EMISSAO) >= '" +DtoS(mv_par01)+"'" //Data Inicial

//If EMPTY(mv_par02)
//	MsgInfo("O Parametro 'Ate' deve ser preenchido","HLB BRASIL")
//	Return(.F.)
If	mv_par01 > mv_par02
	MsgInfo("A data 'De' não pode ser maior que a data 'Ate'. ","HLB BRASIL")
	Return(.F.)
EndIf

bCondicao := {|| DtoS(Temp1->F2_EMISSAO) >= DToS(MV_PAR01) .AND. DtoS(Temp1->F2_EMISSAO) <= DToS(MV_PAR02) .AND. AllTrim(Temp1->F2_P_ENV) <> IIF(MV_PAR03 == 1,'S','A')}
cCondicao := "DtoS(Temp1->F2_EMISSAO) >= '"+DToS(MV_PAR01)+"' .AND. DtoS(Temp1->F2_EMISSAO) <= '" +DToS(MV_PAR02) +"' .AND. AllTrim(Temp1->F2_P_ENV) <> IIF(" +cValToChar(MV_PAR03)+ " == 1,'S','A')"
DbSelectArea("Temp1")
DbSetFilter(bCondicao,cCondicao)

Temp1->(DbGoTop())

Return()

// Legenda
*-------------------------------------------------*
Static Function Legenda()
*-------------------------------------------------*
Local:= aLegenda := {}

aLegenda := {	{"BR_VERDE"  	,"Fatura/Boleto não gerada." },;
{"BR_VERMELHO"  ,"Fatura/Boleto já gerada." },;
{"BR_AMARELO"	,"E-mail não preenchido no cadastro do cliente."}}

BrwLegenda("Legenda","Legenda",aLegenda)

Return()


// Função de envio de e-mail
*------------------------------------------------- *
Static Function Email(cVer1)
*-------------------------------------------------*
Local cSubject		:= ""
Local cAnexo		:= ""
Local cEmail		:= ""
Local cDestinatario	:= ""
Local cFile 		:= ""
Local cFile2		:= ""
Local nQtd          := 0   
Local lBoleto       :=  !Empty( cFBoleto ) .And. If( cEmpAnt <> 'B1' , ( Left( cTpSel , 1 ) <> '3' ) , .T. )
Local lFatura		:= 	!Empty( cFFatura ) .And. If( cEmpAnt <> 'B1' , ( Left( cTpSel , 1 ) <> '2' ) , .T. ) 
Local aRetorno      
Local bExec1 		:= &( "{ || " +  cFBoleto + " }" )    
Local bExec2 		:= &( "{ || " +  cFFatura + " }" )

If cVer1 <> 'S'
	If !MsgYesNo("Deseja realmente enviar e-mail","HLB BRASIL")
		Return .F.
	EndIf
EndIf
//Conta quantos registros foram selecionados
Temp1->(DbGoTop())
While Temp1->(!EOF())
	If!Empty(Alltrim(Temp1->cEnvia))
		nQtd += 1
	EndIf
	Temp1->(DbSkip())
EndDo
//Limite de 20 seleções por vez
If nQtd > 100
	MsgInfo("Favor selecionar um maximo de 20 Faturas por vez.","HLB BRASIL")
	Temp1->(DbGoTop())
	Return (.F.)
Else
	ProcRegua( nQtd )
	Temp1->(DbGoTop())
	While Temp1->(!EOF())
		
		
		If(!Empty(Alltrim(Temp1->cEnvia)))
			
			cEmail := ""
			IncProc()
			
			cSubject:="Fatura/Boleto: "+AllTrim(Temp1->F2_DOC)
			
			If ( cEmpAnt $ 'B1' )
				aRetorno := u_GtEnvDoc( Temp1->C5_NUM )  //** Função em B1FAT001.PRW
				lFatura := aRetorno[ 2 ]
				lBoleto := aRetorno[ 3 ] 
				cEmail  := aRetorno[ 4 ] 
				cSubject:= "Fatura " + AllTrim( Temp1->A1_NREDUZ ) + " x Zoom"
			EndIf                       
			
			cFile := ""
			If lBoleto
				cFile := Eval( bExec1 )
			EndIf

			cFile2 := ""
			If lFatura
				cFile2 := Eval( bExec2 )
			EndIf
			
			
			If cVer1 =='N'
				
				
				If Empty( cFile ) .And. Empty( cFile2 ) 
					Temp1->(DbSkip())
					Loop
				EndIf
				
				
				If Empty( cEmail )
				
					cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
					cEmail += '</head><body>'
					cEmail += '<p align="center"><font face="verdana" size="2">
					cEmail += '<b><u>Fatura Gerada </u></b></p>'
				
				
					cEmail += '<p align="left">Caso encontre alguma divergência nos documentos enviados, solicitamos que entre em contato através (' + AllTrim( GetMv( 'MV_P_00056' ,, '' ) ) + ') para que qualquer inconcistência seja resolvida o mais rápido possível.</p> '
					cEmail += '<p align="left">Please find attached invoice from ' + cNomeEmp +'  for review and payment. If you have any question please let us know through (' + AllTrim( GetMv( 'MV_P_00056' ,, '' ) ) + ') so we can clarify any doubt.</p>'
					cEmail += '<br />'
					cEmail += '<br />'
					cEmail += '<br />'
					cEmail += '<p align="left"><b>Fatura/Boleto: </b>'+AllTrim(Temp1->F2_DOC)+' </p> '
					cEmail += '<p align="left"><b>Cliente: </b> '+Temp1->A1_NOME+'('+Temp1->A1_COD +') </p> '
					cEmail += '<p align="left"><b>Valor: </b> '+AllTrim(Transform(Temp1->F2_VALBRUT,"@E 999,999,999.99"))+'</p> '
					cEmail += '<br />'
					cEmail += '<br />'
					cEmail += '<br />'
					cEmail += '<p align="left">--</p> '
					cEmail += '<p align="left">Sincerely,</p> '
					cEmail += '<p align="left">AR Department</p> '
					cEmail += '<p align="left">' + cNomeEmp +'</p></font>
					cEmail += '<p align="center"><font face="verdana" size="2">
					cEmail += '<b><u> </u>Automatic message, no answer.</b></p>'
					cEmail += '</body></html>'
				
				EndIf			
				
				cTo			:= AllTrim(Temp1->A1_EMAIL)
				cToOculto	:= cCO_Cli  //cópia oculta
				If !Empty( cToOculto ) .And. !Empty( cCO_GT )
					cToOculto += ";"
				EndIf
				cToOculto += cCO_GT
				cAnexos  	:= cFile+";"+cFile2

				If EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
					/*
						** Se conseguir enviar email, grava Log envio .
					*/
					GrvLGZ25( lBoleto , lFatura )				
					
					/*
						** Atualiza Flag de Envio Boleto\Fatura
					*/                                         
					SF2->( DbGoTo( Temp1->RECSF2 ) )
					SF2->( RecLock( 'SF2' , .F. ) )
					SF2->F2_P_ENV := 'S'
					SF2->( MSUnlock() )
					
				EndIf
			EndIf
			
			If File( cFile )
				FErase(cFile)
			EndIf
			If File( cFile2 )
				FErase(cFile2)
			EndIf
		EndIf
		Temp1->(DbSkip())
	EndDo
EndIf

Temp1->(DbGoTop())

Return .T.

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/01/2015 10:20
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF


cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo 		:= AvLeGrupoEMail(cTo)
cCC			:= ""
cFrom		:= AllTrim(GetMv("MV_RELFROM"))
cAttachment := cAnexos

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf
	IF !EMPTY(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ELSE
		SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ENDIF
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER

RETURN .T.
/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende
Data     	: 27/06/2014
*/

*------------------------*
Static Function CriaPerg()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Emissao De: ? "					,"Emissao De: ?"  					,"Emissao De: ?"  					,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial de emissão"} 							,{},{})
U_PUTSX1(cPerg,"02" ,"Emissao Ate: ?"					,"Emissao Ate: ?" 					,"Emissao Ate: ?"	  				,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final de emissão" }								,{},{})
U_PUTSX1(cPerg,"03" ,"Mostrar titulos já enviados ?" 	,"Mostrar titulos já enviados ?"	,"Mostrar titulos já enviados ?"	,"mv_ch3","N",01,0,01,"C","","","","","mv_par03","Não"	,"Não"	,"Não"	,"Não"		,"Sim"	,"Sim"	,"Sim"	,"","","","","","","","","",{"Informar se deja que aparecão so titulos ja enviados"}	,{},{})

Return 

/*
Funcao      : TipoEnv
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Selecionar o tipo de envio
Autor     	: Leandro Brito
Data     	: 19/10/2015
*/

*------------------------*
Static Function Config
*------------------------* 
Local oDlg                      
Local aItens := { "1-Ambos" , "2-Somente Boleto" , "3-Somente Fatura" }
Local oCombo 

If Empty( cTpSel )
	cTpSel := aItens[ 1 ] 
EndIf
	
Define MSDialog oDlg Title 'Configurações de Envio' From 1,1 To 110,250 Of oMainWnd Pixel

	@ 10,05 Say 'Gerar ' Size 30,10 Of oDlg Pixel
	@ 10,30 ComboBox oCombo Var cTpSel ITEMS aItens Size 70,10 Of oDlg Pixel 
	@ 30,05 Button 'Fechar' Action( oDlg:End() ) Size 40,10 Of oDlg Pixel 

Activate MSDialog oDlg Centered  

Return


/*
Função.......: GrvLgZ25
Autor........: Leandro Diniz de Brito
Objetivo.....: Gravar Log Envio Boleto\Fatura
Data.........: 23/10/2015
*/                       
*----------------------------------------------* 
Static Function GrvLgZ25( lBoleto , lFatura ) 
*----------------------------------------------* 

If AliasInDic( 'Z25' )

	Z25->( RecLock( 'Z25' , .T. ) )
	Z25->Z25_FILIAL := xFilial( 'Z25' )   
	Z25->Z25_ID		:= GetSxeNum( 'Z25' , 'Z25_ID' )
	Z25->Z25_USR	:= cUserName
	Z25->Z25_HOUR	:= Left( Time() , 5 )
	Z25->Z25_DATE	:= dDataBase
	Z25->Z25_KEY 	:= Temp1->( F2_DOC + F2_SERIE + DtoS( F2_EMISSAO ) )  
	Z25->Z25_OBS    := If( lBoleto , 'Boleto' , '' ) + If( lBoleto .And. lFatura , "+" , "" ) + If( lFatura ,'Fatura' , '' ) 
	Z25->( MSUnlock() )   
	ConfirmSx8()

EndIf

Return
