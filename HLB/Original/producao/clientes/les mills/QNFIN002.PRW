#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"
#include 'DIRECTRY.CH'

/*
Funcao      :QNFIN002
Parametros  :Nenhum
Retorno     :Nenhum
Objetivos   :Gera tela de seleção de boletos e envio de email.
Autor       :Anderson Arrais
Data        :15/05/2019
*/
*-------------------------*
 User Function QNFIN002()
*-------------------------*  
Local aButtons :={}
Local aSize	   :={}
Local aObjects :={}

Private cPerg  	:="QNFIN002"
Private cVer1  	:='N'
Private aStruSE1:={}
Private aaCampos:=  {'CHECKBOL','CODIGO'}
private aHeader := {} 
private aCols 	:= {}
private oMarkPrd  

Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")

Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
 
//Validação de empresa
If cEmpAnt <> "QN" 
	Alert("Função desenvovida para empresa Les Mills e não disponivel para esta empresa","HLB BRASIL")
	Return()
Endif

//Criando Pergunte
CriaPerg()

//Verifico se já  existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea())
EndIf

aadd(aHeader,{''		  ,"IMAGEM"     	,'@BMP', 3,0,,	             ,"C",     ,"V",,,})
aadd(aHeader,{''		  ,"CHECKBOL"    	,'@BMP', 2,0,,	             ,"C",     ,"V",,,'seleciona','V','S'})
aadd(aHeader,{"Prefixo"   ,"E1_PREFIXO"   	,"@!"  , 3,0,,"€€€€€€€€€€€€€€ ","C","","R"})	
aadd(aHeader,{"Título"    ,"E1_NUM"   		,"@!"  , 9,0,,"€€€€€€€€€€€€€€ ","C","","R"})	
aadd(aHeader,{"Vencimento","E1_VENCTO"		,"@!"  , 8,0,,"€€€€€€€€€€€€€€ ","D","","R"})	
aadd(aHeader,{"Cliente"   ,"A1_NOME"   		,"@!"  ,40,0,,"€€€€€€€€€€€€€€ ","C","","R"})	
aadd(aHeader,{"Email"     ,"A1_P_EMAIL"		,"@!"  ,40,0,,"€€€€€€€€€€€€€€ ","C","","R"})	
aadd(aHeader,{"Código"    ,"CODIGO"      	,"@!"  , 4,0,,"€€€€€€€€€€€€€€ ","C","ZX2","R"})	
	
//Estrutura da tabela
aAdd(aStruSE1,{"CHECKBOL"    			,"C"				 ,2  	  ,0})
aAdd(aStruSE1,{"A1_COD"		,AvSx3("A1_COD"	   ,2),AvSx3("A1_COD"		,3)   ,AvSx3("A1_COD"	 ,4)})
aAdd(aStruSE1,{"A1_NOME"	,AvSx3("A1_NOME"   ,2),AvSx3("A1_NOME"		,3)   ,AvSx3("A1_NOME"	 ,4)})
aAdd(aStruSE1,{"A1_P_EMAIL"	,AvSx3("A1_P_EMAIL",2),AvSx3("A1_P_EMAIL"	,3)	  ,AvSx3("A1_P_EMAIL",4)})
aAdd(aStruSE1,{"E1_NUM"		,AvSx3("E1_NUM"    ,2),AvSx3("E1_NUM"		,3)   ,AvSx3("E1_NUM"	 ,4)})
aAdd(aStruSE1,{"E1_PREFIXO"	,AvSx3("E1_PREFIXO",2),AvSx3("E1_PREFIXO"	,3)   ,AvSx3("E1_PREFIXO",4)})
aAdd(aStruSE1,{"E1_VENCTO"	,AvSx3("E1_VENCTO" ,2),AvSx3("E1_VENCTO"	,3)   ,AvSx3("E1_VENCTO",4)})
aAdd(aStruSE1,{"E1_P_ENV"	,AvSx3("E1_P_ENV"  ,2),AvSx3("E1_P_ENV"		,3)   ,AvSx3("E1_P_ENV"	 ,4)})
aAdd(aStruSE1,{"E1_CLIENTE"	,AvSx3("E1_CLIENTE",2),AvSx3("E1_CLIENTE"	,3)   ,AvSx3("E1_CLIENTE",4)})
aAdd(aStruSE1,{"E1_LOJA"	,AvSx3("E1_LOJA"   ,2),AvSx3("E1_LOJA"		,3)   ,AvSx3("E1_LOJA"   ,4)})
aAdd(aStruSE1,{"E1_SALDO"	,AvSx3("E1_SALDO"  ,2),AvSx3("E1_SALDO"	    ,3)   ,AvSx3("E1_SALDO"  ,4)})
aAdd(aStruSE1,{"E1_EMISSAO"	,AvSx3("E1_EMISSAO",2),AvSx3("E1_EMISSAO"	,3)   ,AvSx3("E1_EMISSAO",4)})
aAdd(aStruSE1,{"E1_P_CONV"	,AvSx3("E1_P_CONV" ,2),AvSx3("E1_P_CONV"	,3)   ,AvSx3("E1_P_CONV" ,4)})
aAdd(aStruSE1,{"E1_IDCNAB"	,AvSx3("E1_IDCNAB" ,2),AvSx3("E1_IDCNAB"	,3)   ,AvSx3("E1_IDCNAB" ,4)})

//Cria tabela temporaria
cNome	:=	CriaTrab(aStruSE1, .T.)
DbUseArea(.T.,__LOCALDRIVER,cNome,'Temp1',.F.,.F.)
 
//Select e Filtro da tela
Processa( {|| Filtro2() }, "Aguarde...", "Carregando os dados...",.F.)

//Criação de botões do ações relacionadas
aAdd(aButtons,{"PENDENTE",{|| seleciona()},"Marcar/Desmarca","Marca/Desmarca",{|| .T.}})
aAdd(aButtons,{"VISUALIZAR",{||cVer1:='S',Email(cVer1)},"Preview","Preview",{|| .T.}})    
aAdd(aButtons,{"Legenda",{||Legenda()},"Legenda","Legenda",{|| .T.}})

//SetKey(VK_F12,{|| Processa( {|| Filtro2() }, "Aguarde...", "Carregando os dados...",.F.)} )

Temp1->(DbGoTop())
If Temp1->(!BOF()) .AND. Temp1->(!EOF())
	
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
	DEFINE MSDIALOG oDlg TITLE "Boleto" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
	
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-20,aPosObj[1][4] LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+5 Say "Selecione os boletos." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 500,6 OF oDlg
	
	oMarkPrd:= MsNewGetDados():New(025,006,230,570, GD_INSERT+GD_DELETE+GD_UPDATE, , , , aaCampos, 1, 99, , , , oDlg, aHeader, aCols,{|| (oMarkPrd:Refresh())},)
	oMarkPrd:oBrowse:bLDblClick := {|| oMarkPrd:EditCell(), oMarkPrd:aCols[oMarkPrd:nAt,2] := iif(oMarkPrd:aCols[oMarkPrd:nAt,2] == 'LBOK','LBNO','LBOK')}

	oMarkPrd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 
	oMarkPrd:oBrowse:SetFocus()
	oMarkPrd:SetArray(aCols,.T.)      
	oMarkPrd :ForceRefresh()
    
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
											   {||cVer1:='N', lRet:=Email(cVer1),If(lret,oDlg:End(),)},;
											   {|| oDlg:End()},;
											   ,;
											   aButtons,;
											   oMarkPrd:oBrowse:Refresh()) CENTERED
	
Else
	MsgInfo("ATENÇÃO!Nenhum dado encontrado para geração do arquivo"," HLB BRASIL")
	Return .F.
EndIf

Return .T.

// Legenda
*---------------------------------*
 Static Function Legenda()
*---------------------------------*
Local:= aLegenda := {}

aLegenda := {	{"BR_VERDE"  	,"Boleto não enviado." },;
				{"BR_VERMELHO"  ,"Boleto já enviado." }}

BrwLegenda("Legenda","Legenda",aLegenda)

Return() 

*---------------------------------*
static function seleciona()        
*---------------------------------*
//percorre todas as linhas do oGetDados
for i := 1 to len(oMarkPrd:aCols)

	if oMarkPrd:aCOLS[i,2] = 'LBNO'
		oMarkPrd:aCOLS[i,2] := 'LBOK'                                               
	else
		oMarkPrd:aCOLS[i,2] := 'LBNO'
	endif	
next     
//executa refresh no getDados e na tela
//esses métodos Refresh() são próprio da classe MsNewGetDados e do dialog
//totalmente diferentes do método estático definido no corpo deste fonte
oMarkPrd:oBrowse:Refresh() 
oDlg:Refresh()

return
          
// Função de envio de e-mail
*------------------------------------*
 Static Function Email(cVer1)
*------------------------------------*
Local cSubject		:= ""
Local cAnexos		:= ""
Local cEmail		:= ""
Local cFile2		:= ""
Local cLink			:= ""
Local nR			:= 0
Local aFile			:= {}

If cVer1 <> 'S'
	If !MsgYesNo("Deseja realmente enviar e-mail","HLB BRASIL")
		Return .F.
	EndIf
EndIf

For iSeq := 1 to len(oMarkPrd:aCols)
	cAnexos	:= ""
	if oMarkPrd:aCOLS[iSeq,2] = 'LBOK'
		//Gera Boleto
		lSelAuto := .T.
		U_QNFIN001(lSelAuto,oMarkPrd:aCOLS[iSeq,3],oMarkPrd:aCOLS[iSeq,4],oMarkPrd:aCOLS[iSeq,5],cVer1 )

		cFile2 := "\FTP\QN\QNFIN002\Boleto_LesMills_"+AllTrim(oMarkPrd:aCOLS[iSeq,4])+".pdf"
		cAnexos:= cFile2
		AADD(aFile,cFile2)

		If cVer1 =='N'
			DbSelectArea ("SE1")
			SE1->(DbGotop())
			SE1->(DbSetOrder(1))
			SE1->(DbSeek(xFilial("SE1")+oMarkPrd:aCOLS[iSeq,3]+oMarkPrd:aCOLS[iSeq,4]))
			
			ZX2->(MsSeek(xFilial("ZX2")+oMarkPrd:aCOLS[iSeq,8]))
					       
			cSubject:= ZX2->ZX2_TITULO
			
			cEmail := '<html>'
			cEmail += '<body>'
			cEmail += '<font face="verdana" size="2">
			cEmail += ZX2->ZX2_MSG
			cEmail += '<br />'

			cEmail += '<p align="left">--</p> '
			cEmail += '<p align="left"></p></font> 
			cEmail += '</body></html>'
						
			cTo := oMarkPrd:aCOLS[iSeq,7]
			cToOculto:= ""
			EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
			GrvbolEnv(oMarkPrd:aCOLS[iSeq,3],oMarkPrd:aCOLS[iSeq,4])
		EndIf
		
	EndIf
Next

//Limpa todos os arquivos gerados no servidor  
For nR:= 1 to Len(aFile)
	FErase(aFile[nR])
Next nR

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
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk
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
	ENDIF
ENDIF

DISCONNECT SMTP SERVER

Return .T.

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
*/

*------------------------*
Static Function CriaPerg()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Vencimento De: ? "				,"Vencimento De: ?"  				,"Vencimento De: ?"  				,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial de vencimento"} 							,{},{})
U_PUTSX1(cPerg,"02" ,"Vencimento Ate: ?"				,"Vencimento Ate: ?" 				,"Vencimento Ate: ?"  				,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final de vencimento" }								,{},{})
U_PUTSX1(cPerg,"03" ,"Mostrar titulos já enviados ?" 	,"Mostrar titulos já enviados ?"	,"Mostrar titulos já enviados ?"	,"mv_ch3","N",01,0,01,"C","","","","","mv_par03","Não"	,"Não"	,"Não"	,"Não"		,"Sim"	,"Sim"	,"Sim"	,"Ambos","Ambos","Ambos","","","","","","",{"Informar se deseja que apareca so titulos ja enviados"},{},{})
U_PUTSX1(cPerg,"04" ,"Titulo de: ? "					,"Titulo de: ? "  					,"Titulo de: ? "  					,"mv_ch4","C",09,0, 0,"G","","","","","mv_par04",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Numero do Titulo Inicial"} 						,{},{})
U_PUTSX1(cPerg,"05" ,"Titulo Ate: ?"					,"Titulo Ate: ?" 					,"Titulo Ate: ?" 		  			,"mv_ch5","C",09,0, 0,"G","","","","","mv_par05",""		,""		,""		,"ZZZZZZZZZ",""		,""		,""		,"","","","","","","","","",{"Numero do Titulo Final" }						,{},{})
U_PUTSX1(cPerg,"06" ,"Prefixo: ?"						,"Prefixo: ?" 		 				,"Prefixo: ?"	 	  				,"mv_ch6","C",03,0, 0,"G","","","","","mv_par06",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Prefixo do Titulo fiscal" }								,{},{})
U_PUTSX1(cPerg,"07" ,"Mensagem: ?"						,"Mensagem ?" 		 				,"Mensagem ?"	 	  				,"mv_ch7","C",06,0, 0,"G","","ZX2","","","mv_par07",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Mensagem para Email" }								,{},{})

Return 

/*
Função  : Filtro2()
Objetivo: Filtro e select do conteúdo da tela
Autor   : Renato Rezende
Data    : 03/10/2017
*/
*----------------------------*
 Static Function Filtro2 ()
*----------------------------*

//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return  
EndIf

//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf 

//Verifico se já  existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea()) 
	
	//Cria tabela temporaria
	cNome	:=	CriaTrab(aStruSE1, .T.)
	DbUseArea(.T.,__LOCALDRIVER,cNome,'Temp1',.F.,.F.)
EndIf

//Qyery para pegar os dados que seram apresentados
cQuery1 := "	SELECT "
cQuery1 += "	A1.A1_COD, A1.A1_NOME,A1.A1_P_EMAIL, "
cQuery1 += " 	E1.E1_VENCTO,E1.E1_NUM,E1.E1_P_CONV,	"
cQuery1 += "	E1.E1_PREFIXO,E1.E1_P_ENV,E1.E1_CLIENTE,E1.E1_LOJA,E1.E1_SALDO,E1.E1_IDCNAB	"
cQuery1 += "	FROM "+RETSQLNAME("SE1")+" E1"
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SA1")+" A1		"
cQuery1 += "		ON			A1.A1_COD	 = E1.E1_CLIENTE "
cQuery1 += "				AND A1.A1_LOJA	 = E1.E1_LOJA	"
cQuery1 += " Where "
cQuery1 += " E1.D_E_L_E_T_='' AND  A1.D_E_L_E_T_ <> '*'  "
cQuery1 += " AND E1.E1_P_BOL   <> 'N'	  AND E1.E1_NUMBCO	 <>	''	  AND E1.E1_IDCNAB	 <> '' "
cQuery1 += " AND E1.E1_NUMBOR	 <>	'' 	  AND E1.E1_SALDO   >  0 	  AND E1.E1_P_CONV	 <>	'' "

If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cQuery1 += "  AND (E1.E1_VENCTO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"') "  
EndIf
If !Empty(MV_PAR04) .OR. !Empty(MV_PAR05)
	cQuery1 += "  AND (E1.E1_NUM BETWEEN '"+Alltrim(MV_PAR04)+"' AND '"+Alltrim(MV_PAR05)+"') "  
EndIf
If !Empty(MV_PAR06)
	cQuery1 += "  AND E1.E1_PREFIXO = '"+Alltrim(MV_PAR06)+"' " 
EndIf
IF MV_PAR03 == 2
	cQuery1 += "  AND E1.E1_P_ENV = 'S' " 
ElseIf MV_PAR03 == 1 
	cQuery1 += "  AND E1.E1_P_ENV <> 'S'	
EndIf 
cQuery1 += "ORDER BY E1.E1_PREFIXO+E1.E1_NUM+E1.E1_VENCTO "

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery1),"QRY1",.F.,.T.)

dbSelectArea("ZX2")
ZX2->(dbSetOrder(1))
ZX2->(dbgotop())

//Coloco os dados da query na tabela temporaria
QRY1->(DbGoTop())
While QRY1->(!EOF())

	RecLock("Temp1",.T.)
	
	Temp1->A1_COD		:= QRY1->A1_COD
	Temp1->A1_NOME		:= QRY1->A1_NOME
	Temp1->A1_P_EMAIL	:= QRY1->A1_P_EMAIL
	Temp1->E1_NUM   	:= QRY1->E1_NUM
	Temp1->E1_VENCTO	:= STOD(QRY1->E1_VENCTO)
	Temp1->E1_PREFIXO	:= QRY1->E1_PREFIXO
	Temp1->E1_P_ENV		:= QRY1->E1_P_ENV
	Temp1->E1_P_CONV	:= QRY1->E1_P_CONV
	Temp1->E1_CLIENTE	:= QRY1->E1_CLIENTE
	Temp1->E1_LOJA 		:= QRY1->E1_LOJA
	Temp1->E1_SALDO 	:= QRY1->E1_SALDO
	Temp1->E1_IDCNAB	:= QRY1->E1_IDCNAB
	
	Temp1->(MsUnlock())
	
	ZX2->(MsSeek(xFilial("ZX2")+Alltrim(MV_PAR07)))
	
	If Temp1->E1_P_ENV $ "S"
		aadd(aCols,{oVermelho,'LBNO', allTrim(Temp1->E1_PREFIXO), allTrim(Temp1->E1_NUM),Temp1->E1_VENCTO,;
		allTrim(Temp1->A1_NOME),allTrim(Temp1->A1_P_EMAIL),allTrim(ZX2->ZX2_COD),.F.})
	Else
		aadd(aCols,{oVerde,'LBNO', allTrim(Temp1->E1_PREFIXO), allTrim(Temp1->E1_NUM),Temp1->E1_VENCTO,;
		allTrim(Temp1->A1_NOME),allTrim(Temp1->A1_P_EMAIL),allTrim(ZX2->ZX2_COD),.F.})
	EndIf
	QRY1->(DbSkip())
EndDO

Return

/*
Função  : GrvBolEnv
Objetivo: Grava E1_P_ENV (Campo que trata se o boleto já foi enviado)
*/
*-----------------------------------------------------------*
 Static Function GrvBolEnv(cPrex,cNum) 
*-----------------------------------------------------------*

//Grava E1_P_ENV
SE1->(DbSetOrder(1))
SE1->(DbGoTop())
If SE1->(DbSeek(xFilial("SE1")+cPrex+cNum))
	SE1->(RecLock("SE1",.F.))
		SE1->E1_P_ENV := "S"
	SE1->(MsUnlock())
EndIf

Return