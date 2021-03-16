#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#Include "tbiconn.ch"
#include 'DIRECTRY.CH'

/*
Funcao      :TPFIN008
Parametros  :Nenhum
Retorno     :Nenhum
Objetivos   :Gera tela de seleção de NFS que iram gerar boletos e envio de nf por email.
Autor       :Renato Rezende
Data        :18/04/2018
Módulo      :Faturamento
*/
*-------------------------*
 User Function TPFIN008()
*-------------------------*  
Local aCampos  :={}
Local aButtons :={}
Local aColors  :={}
Local lInverte :=.F.
Local aSize	   :={}
Local aObjects :={}

Private cPerg  :="TPFIN008"
Private cVer1  :='N'
Private aStruSF2 :={}
Private cMarca := GetMark()

//Validação de empresa
If cEmpAnt <> "TP" 
	Alert("Função desenvovida para empresa Twitter e não disponivel para esta empresa","HLB BRASIL")
	Return()
Endif

//Criando Pergunte
CriaPerg()

//Verifico se já  existe esta tabela
If Select ("Temp1")>0
	Temp1->(DbCloseArea())
EndIf

//Cor e regra das legendas
aAdd(aColors,{"AllTrim(Temp1->F2_P_ENV) =='S'","BR_VERMELHO"})
aAdd(aColors,{"AllTrim(Temp1->C5_P_EMAIL)<>''","BR_VERDE"})    
aAdd(aColors,{"AllTrim(Temp1->C5_P_EMAIL)==''","BR_AMARELO"})  

//Campos do MarkBrowse (Cabeçalho da tabela)
aAdd(aCampos,{"cEnvia"    	,"",               	 })
aAdd(aCampos,{"F2_DOC"		,"","Nota Fiscal"	,})
aAdd(aCampos,{"F2_SERIE"	,"","Serie Fiscal"	,})
aAdd(aCampos,{"C5_NUM"		,"","Pedido"		,})
aAdd(aCampos,{"F2_P_NUM"   	,"","IO_NUMBER"		,})
aAdd(aCampos,{"C5_P_EMAIL"	,"","Destinatário"	,})
aAdd(aCampos,{"F2_CLIENT"	,"","Cliente"		,})
aAdd(aCampos,{"A1_NOME" 	,"","Nome Cliente"	,})
aAdd(aCampos,{"F2_VALBRUT"  ,"","Total"			,})

//Estrutura da tabela
aAdd(aStruSF2,{"cEnvia"    			,"C"				 ,2  	  ,0})
aAdd(aStruSF2,{"A1_COD"		,AvSx3("A1_COD"	   ,2),AvSx3("A1_COD"		,3)   ,AvSx3("A1_COD"	 ,4)})
aAdd(aStruSF2,{"A1_NOME"	,AvSx3("A1_NOME"   ,2),AvSx3("A1_NOME"		,3)   ,AvSx3("A1_NOME"	 ,4)})
aAdd(aStruSF2,{"A1_NREDUZ"	,AvSx3("A1_NREDUZ" ,2),AvSx3("A1_NREDUZ"	,3)   ,AvSx3("A1_NREDUZ" ,4)})
aAdd(aStruSF2,{"A1_P_ID"	,AvSx3("A1_P_ID"   ,2),AvSx3("A1_P_ID"		,3)   ,AvSx3("A1_P_ID"	 ,4)})
aAdd(aStruSF2,{"A1_END"		,AvSx3("A1_END"	   ,2),AvSx3("A1_END"		,3)   ,AvSx3("A1_END"	 ,4)})
aAdd(aStruSF2,{"A1_ESTADO"	,AvSx3("A1_ESTADO" ,2),AvSx3("A1_ESTADO"	,3)   ,AvSx3("A1_ESTADO" ,4)})
aAdd(aStruSF2,{"A1_CEP"		,AvSx3("A1_CEP"    ,2),AvSx3("A1_CEP"		,3)   ,AvSx3("A1_CEP"	 ,4)})
aAdd(aStruSF2,{"A1_CODPAIS"	,AvSx3("A1_CODPAIS",2),AvSx3("A1_CODPAIS"	,3)	  ,AvSx3("A1_CODPAIS",4)})
aAdd(aStruSF2,{"A1_CGC"		,AvSx3("A1_CGC"	   ,2),AvSx3("A1_CGC"		,3)	  ,AvSx3("A1_CGC"	 ,4)})
aAdd(aStruSF2,{"B1_DESC"	,AvSx3("B1_DESC"   ,2),AvSx3("B1_DESC"		,3)   ,AvSx3("B1_DESC"	 ,4)})
aAdd(aStruSF2,{"C5_P_EMAIL"	,AvSx3("C5_P_EMAIL",2),AvSx3("C5_P_EMAIL"	,3)   ,AvSx3("C5_P_EMAIL",4)})
aAdd(aStruSF2,{"C5_P_EMAI1"	,AvSx3("C5_P_EMAI1",2),AvSx3("C5_P_EMAI1"	,3)   ,AvSx3("C5_P_EMAI1",4)})
aAdd(aStruSF2,{"C5_P_EMAI2"	,AvSx3("C5_P_EMAI2",2),AvSx3("C5_P_EMAI2"	,3)   ,AvSx3("C5_P_EMAI2",4)})
aAdd(aStruSF2,{"C5_P_EMAI3"	,AvSx3("C5_P_EMAI3",2),AvSx3("C5_P_EMAI3"	,3)   ,AvSx3("C5_P_EMAI3",4)})
aAdd(aStruSF2,{"C5_EMISSAO"	,AvSx3("C5_EMISSAO",2),AvSx3("C5_EMISSAO"	,3)   ,AvSx3("C5_EMISSAO",4)})
aAdd(aStruSF2,{"C5_P_PO"	,AvSx3("C5_P_PO"   ,2),AvSx3("C5_P_PO"		,3)   ,AvSx3("C5_P_PO" 	 ,4)})
aAdd(aStruSF2,{"C5_NUM"		,AvSx3("C5_NUM"    ,2),AvSx3("C5_NUM"		,3)   ,AvSx3("C5_NUM"	 ,4)})
aAdd(aStruSF2,{"C5_P_NUM"	,AvSx3("C5_P_NUM"  ,2),AvSx3("C5_P_NUM"		,3)   ,AvSx3("C5_P_NUM"	 ,4)})
aAdd(aStruSF2,{"E4_DESCRI"	,AvSx3("E4_DESCRI" ,2),AvSx3("E4_DESCRI"	,3)   ,AvSx3("E4_DESCRI" ,4)})
aAdd(aStruSF2,{"E4_COND"	,AvSx3("E4_COND"   ,2),AvSx3("E4_COND"		,3)   ,AvSx3("E4_COND"	 ,4)})
aAdd(aStruSF2,{"F2_DOC"		,AvSx3("F2_DOC"    ,2),AvSx3("F2_DOC"		,3)   ,AvSx3("F2_DOC"	 ,4)})
aAdd(aStruSF2,{"F2_SERIE"	,AvSx3("F2_SERIE"  ,2),AvSx3("F2_SERIE"		,3)   ,AvSx3("F2_SERIE"	 ,4)})
aAdd(aStruSF2,{"F2_P_ENV"	,AvSx3("F2_P_ENV"  ,2),AvSx3("F2_P_ENV"		,3)   ,AvSx3("F2_P_ENV"	 ,4)})
aAdd(aStruSF2,{"F2_P_NUM"	,AvSx3("F2_P_NUM"  ,2),AvSx3("F2_P_NUM"		,3)   ,AvSx3("F2_P_NUM"  ,4)})
aAdd(aStruSF2,{"F2_CLIENT"	,AvSx3("F2_CLIENT" ,2),AvSx3("F2_CLIENT"	,3)   ,AvSx3("F2_CLIENT" ,4)})
aAdd(aStruSF2,{"F2_LOJA"	,AvSx3("F2_LOJA"   ,2),AvSx3("F2_LOJA"		,3)   ,AvSx3("F2_LOJA"   ,4)})
aAdd(aStruSF2,{"F2_VALBRUT"	,AvSx3("F2_VALBRUT",2),AvSx3("F2_VALBRUT"	,3)   ,AvSx3("F2_VALBRUT",4)})
aAdd(aStruSF2,{"F2_EMISSAO"	,AvSx3("F2_EMISSAO",2),AvSx3("F2_EMISSAO"	,3)   ,AvSx3("F2_EMISSAO",4)})
aAdd(aStruSF2,{"F2_NFELETR"	,AvSx3("F2_NFELETR",2),AvSx3("F2_NFELETR"	,3)   ,AvSx3("F2_NFELETR",4)})
aAdd(aStruSF2,{"F2_EMINFE"	,AvSx3("F2_EMINFE" ,2),AvSx3("F2_EMINFE"	,3)	  ,AvSx3("F2_EMINFE" ,4)})
aAdd(aStruSF2,{"F2_CODNFE"	,AvSx3("F2_CODNFE" ,2),AvSx3("F2_CODNFE"	,3)   ,AvSx3("F2_CODNFE" ,4)})

//Cria tabela temporaria
cNome	:=	CriaTrab(aStruSF2, .T.)
DbUseArea(.T.,"DBFCDX",cNome,'Temp1',.F.,.F.)
 
//Select e Filtro da tela
Processa( {|| Filtro2() }, "Aguarde...", "Carregando os dados...",.F.)

//Criação de botões do ações relacionadas
aAdd(aButtons,{"PENDENTE",{|| MarcaTds("Temp1")},"Marcar/Desmarca","Marca/Desmarca",{|| .T.}})
aAdd(aButtons,{"VISUALIZAR",{||cVer1:='S',Email(cVer1)},"Preview","Preview",{|| .T.}})    
aAdd(aButtons,{"Legenda",{||Legenda()},"Legenda","Legenda",{|| .T.}})

SetKey(VK_F12,{|| Processa( {|| Filtro2() }, "Aguarde...", "Carregando os dados...",.F.)} )

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
	DEFINE MSDIALOG oDlg TITLE "NF SAIDA" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
	
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-20,aPosObj[1][4] LABEL "" OF oDlg PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+5 Say "Selecione as notas para envio de NFS e boletos." COLOR CLR_HBLUE, CLR_WHITE PIXEL SIZE 500,6 OF oDlg
	
	oMarkPrd:= MsSelect():New("Temp1","cEnvia",,aCampos,@lInverte,@cMarca,{aPosObj[2,1]-20,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,oDlg,,aColors)
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

aLegenda := {	{"BR_VERDE"  	,"NFS/Boleto não gerada." },;
				{"BR_VERMELHO"  ,"NFS/Boleto já gerada." },;
				{"BR_AMARELO"	,"E-mail não preenchido."}}

BrwLegenda("Legenda","Legenda",aLegenda)

Return()


// Função de envio de e-mail
*------------------------------------*
 Static Function Email(cVer1)
*------------------------------------*
Local cSubject		:= ""
Local cAnexos		:= ""
Local cEmail		:= ""
Local cDestinatario	:= ""
Local cFile2		:= ""
Local cLink			:= ""
Local nR			:= 0
Local aFile			:= {}

Private nSelecao	:= 3


//Selecionar o que será gerado Fatura/Boleto
nSelecao := bolfat(cVer1)

If cVer1 <> 'S'
	If nSelecao ==  4 .OR. !MsgYesNo("Deseja realmente enviar e-mail","HLB BRASIL")
		Return .F.
	EndIf
EndIf

Temp1->(DbGoTop())
While Temp1->(!EOF())
	cAnexos	:= ""
	If(!Empty(Alltrim(Temp1->cEnvia)))
		//Envio de NFS Boleto ou as duas opções
		If nSelecao == 1 .OR. nSelecao == 3
			//Gera Boleto
			U_TPFIN005( Temp1->F2_SERIE,;
			Temp1->F2_DOC,;
			cVer1,;
			Temp1->F2_EMISSAO )

			cFile2 := "\FTP\TP\TPFIN001\boleto"+AllTrim(Temp1->F2_DOC)+".pdf"
			cAnexos:= cFile2
			AADD(aFile,cFile2)
		EndIf
		//Envio de Campanha ou as duas opções
		If nSelecao == 2 .OR. nSelecao == 3 
			U_TPFAT008( Temp1->A1_NOME,;
			Temp1->A1_NREDUZ,;
			Temp1->A1_P_ID,;
			Temp1->A1_END,;
			Temp1->A1_ESTADO,;
			Temp1->A1_CEP,;
			Temp1->A1_CODPAIS,;
			Temp1->A1_CGC,;
			Temp1->C5_NUM,;
			Temp1->C5_P_NUM,;
			Temp1->C5_EMISSAO,;
			Temp1->C5_P_PO,;
			Temp1->F2_DOC,;
			Temp1->F2_SERIE,;
			Temp1->F2_P_ENV,;
			Temp1->F2_P_NUM,;
			Temp1->F2_CLIENT,;
			Temp1->F2_LOJA,;
			Temp1->F2_VALBRUT,;
			Temp1->F2_EMISSAO,;
			Temp1->E4_DESCRI,;
			Temp1->E4_COND,;
			cVer1 )

			cFile  := "\FTP\TP\TPFIN001\Campanha"+AllTrim(Temp1->F2_DOC)+".pdf" 
			If !Empty(cAnexos)
				cAnexos+= ";"
			EndIf
			cAnexos+= cFile
			AADD(aFile,cFile)
		EndIf
	
		If cVer1 =='N'
			DbSelectArea ("SC5")
			SC5->(DbGotop())
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(FwxFilial("SC5")+Temp1->C5_NUM,.T.))//C6_FILIAL+C5_NUM  
			
			IF !Empty(AllTrim(Temp1->C5_P_EMAIL))
				cDestinatario	:= AllTrim(Temp1->C5_P_EMAIL)
				IF !Empty(AllTrim(Temp1->C5_P_EMAI1))
					cDestinatario	+= +';'+AllTrim(Temp1->C5_P_EMAI1)       
					IF !Empty(AllTrim(Temp1->C5_P_EMAI2))
						cDestinatario	+= +';'+AllTrim(Temp1->C5_P_EMAI2)							
	  					IF !Empty(AllTrim(Temp1->C5_P_EMAI3))
							cDestinatario	+= +';'+AllTrim(Temp1->C5_P_EMAI3)
						EndIF
					EndIF
				EndIF
			EndIF
			
			       
			cEmail := '<html>'
			cEmail += '<body>'
			cEmail += '<p align="center"><font face="verdana" size="2">
			cEmail += '<b><u>Nota Fiscal de Serviço Gerada </u></b></p>'
			
			cSubject:= "Nota Fiscal/Boleto: "+AllTrim(Temp1->F2_DOC)
						
			cEmail += '<p align="left">Caso encontre alguma divergência nos documentos enviados, solicitamos que entre em contato através do e-mail (ARBrazil@twitter.com) para que qualquer inconcistência seja resolvida o mais rápido possível.</p> '
			cEmail += '<p align="left">Please find attached invoice from Twitter Brasil Rede de Informação Ltda for review and payment. If you have any question please let us know through the e-mail (ARBrazil@twitter.com) so we can clarify any doubt.</p>'
			cEmail += '<br />'
			cEmail += '<p align="left"><b>Nota Fiscal de Serviço/Boleto: </b>'+AllTrim(Temp1->F2_DOC)+' </p> '
			cEmail += '<p align="left"><b>Cliente: </b> '+Temp1->A1_P_ID+' - '+Temp1->A1_NOME+'('+Temp1->A1_COD +') </p> '
			cEmail += '<p align="left"><b>Valor: </b> '+AllTrim(Transform(Temp1->F2_VALBRUT,"@E 999,999,999.99"))+'</p> '
			cEmail += '<br />'

			//Envio do link da NFS
			If nSelecao == 2 .OR. nSelecao == 3 
				cLink := MontaLink(Temp1->F2_NFELETR,Temp1->F2_CODNFE)
				
				cEmail += 'Nesta mensagem encontra-se o link da Nota Fiscal de Servi&ccedil;os Eletr&ocirc;nica (NFS-e).<br>'
				cEmail += '<a href="'+Alltrim(cLink)+'">'+Alltrim(cLink)+'</a>'
				cEmail += '<br /><br />'
				cEmail += 'Caso n&atilde;o consiga visualizar a NFS-e atrav&eacute;s do link acima citado, acessar o site da prefeitura e digitar os dados abaixo:'
				cEmail += '<br />'
				cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&uacute;mero NF: '+AllTrim(Temp1->F2_NFELETR)+'<br>'
				cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C&oacute;digo Verificador: '+AllTrim(Temp1->F2_CODNFE)+'<br>'
				cEmail += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CNPJ do Prestador de Servi&ccedil;os: '+Transform(StrZero(Val(AllTrim(SM0->M0_CGC)),14),"@R 99.999.999/9999-99")+'<br>'			
	
				cEmail += '<br />'
				cEmail += '<p align="left">De acordo com a reforma tributária do ISS, o serviço prestado pelo Twitter se enquadra na obrigação da emissão da Nota Fiscal de Serviço.</p> '
				cEmail += '<br />'
				
				//Grava campo de nota enviada no SF2
				GrvNotaEnv(Temp1->F2_DOC,Temp1->F2_SERIE,Temp1->F2_CLIENT,Temp1->F2_LOJA)
				
			EndIf
			
			cEmail += '<p align="left">--</p> '
			cEmail += '<p align="left">Sincerely,</p> '
			cEmail += '<p align="left">AR Department</p> '
			cEmail += '<p align="left">Twitter Brazil</p></font> 
			cEmail += '<p align="center"><font face="verdana" size="2">
			cEmail += '<b><u> </u>Automatic message, no answer.</b></p>'
			cEmail += '</body></html>'
						
			//cTo := "renato.rezende@hlb.com.br"
			cTo			:= IIF (Empty(cDestinatario),AllTrim(GetMv("MV_P_00040")),cDestinatario)  //Para
			cToOculto	:= AllTrim(GetMv("MV_P_00041",.F.,"") ) //cópia oculta 
			//cToOculto:= ""
			EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
		EndIf
		
	EndIf
	Temp1->(DbSkip())
EndDo

//Limpa todos os arquivos gerados no servidor  
For nR:= 1 to Len(aFile)
	FErase(aFile[nR])
Next nR

Return .T.

//Marca todos
*-----------------------------------*
Static Function MarcaTds(PAlias)
*-----------------------------------*

DbSelectArea(PAlias)
(PAlias)->(DbGoTop())
While (PAlias)->(!EOF())
	RecLock(PAlias,.F.)
	If (PAlias)->cEnvia == cMarca
		(PAlias)->cEnvia:=Space(02)
	Else
		(PAlias)->cEnvia:= cMarca
	EndIf

	(PAlias)->(MsUnlock())
	(PAlias)->(DbSkip())
EndDo

(PAlias)->(DbGoTop())

Return


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
Autor     	: Renato Rezende
Data     	: 27/06/2014
*/

*------------------------*
Static Function CriaPerg()
*------------------------*
U_PUTSX1(cPerg,"01" ,"Emissao De: ? "					,"Emissao De: ?"  					,"Emissao De: ?"  					,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,"01012000"	,""		,""		,""		,"","","","","","","","","",{"Data Inicial de emissão"} 							,{},{})
U_PUTSX1(cPerg,"02" ,"Emissao Ate: ?"					,"Emissao Ate: ?" 					,"Emissao Ate: ?"	  				,"mv_ch2","D",08,0, 0,"G","","","","","mv_par02",""		,""		,""		,"01012030"	,""		,""		,""		,"","","","","","","","","",{"Data Final de emissão" }								,{},{})
U_PUTSX1(cPerg,"03" ,"Mostrar titulos já enviados ?" 	,"Mostrar titulos já enviados ?"	,"Mostrar titulos já enviados ?"	,"mv_ch3","N",01,0,01,"C","","","","","mv_par03","Não"	,"Não"	,"Não"	,"Não"		,"Sim"	,"Sim"	,"Sim"	,"Ambos","Ambos","Ambos","","","","","","",{"Informar se deja que aparecão so titulos ja enviados"},{},{})
U_PUTSX1(cPerg,"04" ,"Nota de: ? "					,"Nota de: ? "  					,"Nota de: ? "  					,"mv_ch4","C",09,0, 0,"G","","","","","mv_par04",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Numero da nota fiscal Inicial"} 						,{},{})
U_PUTSX1(cPerg,"05" ,"Nota Ate: ?"					,"Nota Ate: ?" 						,"Nota Ate: ?" 		  				,"mv_ch5","C",09,0, 0,"G","","","","","mv_par05",""		,""		,""		,"ZZZZZZZZZ",""		,""		,""		,"","","","","","","","","",{"Numero da nota fiscal Final" }						,{},{})
U_PUTSX1(cPerg,"06" ,"Série: ?"						,"Série: ?" 		 				,"Série: ?"	   		  				,"mv_ch6","C",03,0, 0,"G","","","","","mv_par06",""		,""		,""		,""			,""		,""		,""		,"","","","","","","","","",{"Série da nota fiscal" }								,{},{})

Return 


/*
Função  : bolfat
Objetivo: Janela da seleçãodo tipo que será enviado boleto/fatura
Autor   : Renato Rezende
Data    : 28/09/2017
*/
*-------------------------------*
 Static Function bolFat(cVer1) 
*-------------------------------*
Local aItens1	:={}
Local aMsg		:={}
Local cCombo1	:=""
Local nCtbl		:=0
Local oDlg2,oSay,oCbox,oSBtn,oSayHelp,oSBtn2
Local oTpNorDev

aItens1	:= {'Boleto','NF-s','NF-s/Boleto'}
aMsg	:= {"ATENÇÃO, Será enviado só a NF-s!","ATENÇÃO, Será gerado só o Boleto!","ATENÇÃO, Será gerado a NF-s/Boleto!"}

cCombo1	:= aItens1[1]

oDlg2		:= MSDialog():New( 249,407,425,731,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay		:= TSay():New( 008,004,{||"Selecionar o que será gerado:"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)

oCBox		:= TComboBox():New( 020,004,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,108,010,oDlg2 ,,{||},,,,.T.,,,,,,,,,'cCombo1')

//Atualizando o objeto oSayHelp quando o CBox é alterado
oCBox:bChange:={|| oSayHelp:Refresh()}

//Instrução no bloco de código para alterar conforme a opção selecionada no CBox
oSayHelp	:= TSay():New( 035,004,{|| IIF(cCombo1==aItens1[1],aMsg[1],IIF(cCombo1==aItens1[2],aMsg[2],aMsg[3]))},oDlg2,,,,,,.T.)

oSBtn		:= SButton():New( 008,124,1,{|| IIF(cCombo1==aItens1[1],nCtbl:=1,IIF(cCombo1==aItens1[2],nCtbl:=2,nCtbl:=3)),oDlg2:end() },oDlg2,,"", )
oSBtn2		:= SButton():New( 020,124,20,{|| nCtbl:=4,oDlg2:end() },oDlg2,,"", )

oDlg2:Activate(,,,.T.)

Return nCtbl

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
	cNome	:=	CriaTrab(aStruSF2, .T.)
	DbUseArea(.T.,"DBFCDX",cNome,'Temp1',.F.,.F.)
EndIf

//Qyery para pegar os dados que seram apresentados
cQuery1 := "	SELECT "
cQuery1 += "	A1.A1_COD, A1.A1_NOME,A1.A1_NREDUZ,A1.A1_P_ID,A1.A1_END,A1.A1_ESTADO,A1.A1_CEP,A1.A1_CODPAIS,A1.A1_CGC, "
cQuery1 += " 	C5.C5_P_EMAIL,C5.C5_P_EMAI1,C5.C5_P_EMAI2,C5.C5_P_EMAI3,C5.C5_EMISSAO,C5.C5_P_PO,C5.C5_NUM,C5.C5_P_NUM,	"
cQuery1 += "	E4.E4_DESCRI,E4.E4_COND, "
cQuery1 += "	F2.F2_DOC,F2.F2_SERIE,F2.F2_P_ENV,F2.F2_P_NUM,F2.F2_CLIENT,F2.F2_LOJA,F2.F2_VALBRUT,F2.F2_EMISSAO,F2_NFELETR, F2_EMINFE,F2_CODNFE	"
cQuery1 += "	FROM "+RETSQLNAME("SF2")+" F2"
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SC5")+" C5"
cQuery1 += "		ON			C5.C5_FILIAL = F2.F2_FILIAL	"
cQuery1 += "				AND C5.C5_NOTA   = F2.F2_DOC 	"
cQuery1 += "				AND C5.C5_CLIENTE= F2.F2_CLIENT "
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SA1")+" A1"
cQuery1 += "		ON			A1.A1_COD	 = F2.F2_CLIENT "
cQuery1 += "				AND A1.A1_LOJA	 = F2.F2_LOJA	"
cQuery1 += "		LEFT JOIN "+RETSQLNAME("SE4")+" E4		"
cQuery1 += "		ON		E4.E4_FILIAL = F2.F2_FILIAL     "
cQuery1 += "			 	AND E4.E4_CODIGO= F2.F2_COND    "
cQuery1 += "Where "
cQuery1 += "F2.D_E_L_E_T_='' AND C5.D_E_L_E_T_ <> '*' AND A1.D_E_L_E_T_ <> '*' AND E4.D_E_L_E_T_ <> '*'  "
//Filtrar apenas notas fiscais já transmitidas
cQuery1 += " AND F2.F2_NFELETR+F2.F2_EMINFE+F2.F2_CODNFE <> '' "

If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cQuery1 += "  AND (F2.F2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"') "  
EndIf
If !Empty(MV_PAR04) .OR. !Empty(MV_PAR05)
	cQuery1 += "  AND (F2.F2_DOC BETWEEN '"+Alltrim(MV_PAR04)+"' AND '"+Alltrim(MV_PAR05)+"') "  
EndIf
If !Empty(MV_PAR06)
	cQuery1 += "  AND F2.F2_SERIE = '"+Alltrim(MV_PAR06)+"' " 
EndIf
IF MV_PAR03 == 2
	cQuery1 += "  AND F2.F2_P_ENV = 'S' " 
ElseIf MV_PAR03 == 1 
	cQuery1 += "  AND F2.F2_P_ENV <> 'S'	
EndIf 
cQuery1 += "ORDER BY F2.F2_DOC+F2.F2_SERIE+F2.F2_EMISSAO"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery1),"QRY1",.F.,.T.)

//Coloco os dados da query na tabela temporaria
QRY1->(DbGoTop())
While QRY1->(!EOF())

	RecLock("Temp1",.T.)
	
	Temp1->A1_COD		:= QRY1->A1_COD
	Temp1->A1_NOME		:= QRY1->A1_NOME
	Temp1->A1_NREDUZ	:= QRY1->A1_NREDUZ
	Temp1->A1_P_ID		:= QRY1->A1_P_ID
	Temp1->A1_END		:= QRY1->A1_END
	Temp1->A1_ESTADO	:= QRY1->A1_ESTADO
	Temp1->A1_CEP	   	:= QRY1->A1_CEP
	Temp1->A1_CODPAIS	:= QRY1->A1_CODPAIS
	Temp1->A1_CGC		:= QRY1->A1_CGC
	Temp1->C5_NUM   	:= QRY1->C5_NUM
	Temp1->C5_P_NUM  	:= QRY1->C5_P_NUM
	Temp1->C5_P_EMAIL	:= QRY1->C5_P_EMAIL
	Temp1->C5_P_EMAI1	:= QRY1->C5_P_EMAI1
	Temp1->C5_P_EMAI2	:= QRY1->C5_P_EMAI2
	Temp1->C5_P_EMAI3	:= QRY1->C5_P_EMAI3
	Temp1->C5_EMISSAO	:= STOD(QRY1->C5_EMISSAO)
	Temp1->C5_P_PO		:= QRY1->C5_P_PO
	Temp1->E4_DESCRI	:= QRY1->E4_DESCRI
	Temp1->E4_COND		:= QRY1->E4_COND
	Temp1->F2_DOC  		:= QRY1->F2_DOC
	Temp1->F2_SERIE		:= QRY1->F2_SERIE
	Temp1->F2_P_ENV		:= QRY1->F2_P_ENV
	Temp1->F2_P_NUM  	:= QRY1->F2_P_NUM
	Temp1->F2_CLIENT	:= QRY1->F2_CLIENT
	Temp1->F2_LOJA 		:= QRY1->F2_LOJA
	Temp1->F2_VALBRUT	:= QRY1->F2_VALBRUT
	Temp1->F2_EMISSAO	:= STOD(QRY1->F2_EMISSAO)
	Temp1->F2_NFELETR	:= QRY1->F2_NFELETR
	Temp1->F2_EMINFE	:= STOD(QRY1->F2_EMINFE)
	Temp1->F2_CODNFE	:= QRY1->F2_CODNFE
	
	Temp1->(MsUnlock())
	QRY1->(DbSkip())
EndDO

Return

/*
Função  : GetLink
Objetivo: Monta o Link que será enviado no email
Autor   : Renato Rezende
Data    : 19/04/2018
*/
*--------------------------------------------*
 Static Function MontaLink(cNFELETR,cCODNFE)
*--------------------------------------------*
Local cLinkNFS := GetLink(AllTrim(SM0->M0_CODMUN)) 

cLinkNFS := STRTran(cLinkNFS,"[#NUMERO_NF]",AllTrim(cNFELETR))  
cLinkNFS := STRTran(cLinkNFS,"[#IM]",AllTrim(SM0->M0_INSCM)) 
//Rio de janeiro: 3304557
cLinkNFS := STRTran(cLinkNFS,"[#COD_VER]",If(SM0->M0_CODMUN == "3304557",StrTran(AllTrim(cCODNFE),"-",""),AllTrim(cCODNFE)))   

Return cLinkNFS

/*
Função  : GetLink
Objetivo: Tratamento da URL por municipio
Autor   : Renato Rezende
Data    : 19/04/2018
*/
*-----------------------------------*
 Static Function GetLink(cMunicipio) 
*-----------------------------------*
Local cLink := ""

Do Case
	Case cMunicipio == "3550308"	//"SAO PAULO"
		cLink := "https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?nf=[#NUMERO_NF]&inscricao=[#IM]&verificacao=[#COD_VER]"
	Case cMunicipio == "3304557"	//"RIO DE JANEIRO"
		cLink := "https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm=[#IM]&nf=[#NUMERO_NF]&cod=[#COD_VER]"
End Case

Return cLink

/*
Função  : GrvNotaEnv
Objetivo: Grava F2_P_ENV (Campo que trata se a nota já foi enviada)
Autor   : Renato Rezende
Data    : 19/04/2018
*/
*-----------------------------------------------------------*
 Static Function GrvNotaEnv(cDoc,cSerie,cCliente,cLoja) 
*-----------------------------------------------------------*

//Grava F2_P_ENV
SF2->(DbSetOrder(1))
SF2->(DbGoTop())
If SF2->(DbSeek(FwxFilial("SF2")+cDoc+cSerie+cCliente+cLoja))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENT+F2_LOJA+F2_FORMUL+F2_TIPO
	SF2->(RecLock("SF2",.F.))
		SF2->F2_P_ENV := "S"
	SF2->(MsUnlock())
EndIf
