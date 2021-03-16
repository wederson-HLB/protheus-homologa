#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "XmlXFun.Ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


/*/{Protheus.doc} GMGETXML
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0


@example
(examples)

@see (links_or_references)
/*/
User Function GMGETXML()
	
	Local	 lPrintDf	:= .F.
	Local	 oDlgExp
	Private cSchemaTss	:= GetNewPar("XM_SCHMTSS","")
	Private oCancela
	Private oDadosCliente
	Private cDadosCliente := ""
	Private oEmail
	Private cEmail := Space(TamSX3("A1_EMAIL")[1])
	Private oEmpresa
	Private cEmpresa
	Private nSelEmp	
	Private nLenEmp	:= Len(cEmpAnt)
	Private nLenFil	:= Len(cFilAnt)
	Private oNumero
	Private cNumero := Space(TamSX3("F2_DOC")[1])
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSendMail
	Private oSerie
	Private cSerie := Space(TamSX3("F2_SERIE")[1])
	Private oSetMail
	Private oVisualDanfe
	Private	cCodCli	:=	""
	Private	cLojCli	:=  ""
	Private	dDataEmis	:= dDataBase
	Private cModalidade	:= ""
	Private cEntId		:= ""
	Private cF2_TIPO	:= ""
	Private cChvNfe		:= Space(44)
	Private oChvNfe
	Private cIdCCe		:= Space(TamSX3("F2_IDCCE")[1])
	Private cExtArq		:= ""
	Private LUSACOLAB		:= .F.
	
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbGotop()
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbGotop()
	
	DEFINE MSDIALOG oDlgExp TITLE "Atualização de Email e Envio de XML ao Cliente" FROM 000, 000  TO 240, 430 COLORS 0, 16777215 PIXEL
	
	@ 007, 054 COMBOBOX oEmpresa VAR cEmpresa ITEMS sfGetBox() SIZE 145, 010 OF oDlgExp COLORS 0, 16777215 PIXEL
	oEmpresa:bChange := {|| sfZeraGet() }
	@ 022, 008 SAY oSay1 PROMPT "Informe a Série" SIZE 044, 008 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 020, 054 MSGET oSerie VAR cSerie SIZE 024, 010 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 033, 054 MSGET oNumero VAR cNumero SIZE 038, 010 OF oDlgExp VALID sfGetMail() COLORS 0, 16777215 PIXEL
	@ 035, 008 SAY oSay2 PROMPT "Informe o Número" SIZE 045, 007 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 008, 008 SAY oSay3 PROMPT "Informe Empresa" SIZE 025, 007 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 047, 008 SAY oSay4 PROMPT "Dados do Cliente" SIZE 048, 007 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 045, 054 MSGET oDadosCliente VAR cDadosCliente SIZE 145, 010 OF oDlgExp COLORS 0, 16777215 READONLY PIXEL
	@ 060, 008 SAY oSay5 PROMPT "Email do Cliente" SIZE 045, 007 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 058, 054 MSGET oEmail VAR cEmail SIZE 145, 010 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 075, 008 SAY oSay6 PROMPT "Chave Eletrônica" SIZE 045, 007 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 073, 054 MSGET oChvNfe VAR cChvNfe SIZE 145, 010 OF oDlgExp COLORS 0, 16777215 PIXEL
	@ 090, 049 BUTTON oSetMail PROMPT "Atualizar Email" SIZE 047, 012 OF oDlgExp ACTION sfSetMail() PIXEL
	@ 090, 099 BUTTON oVisualDanfe PROMPT "Visualizar Danfe" SIZE 047, 012 OF oDlgExp Action sfViewNfe(.T.) PIXEL
	@ 105, 099 BUTTON oPrtDanfe PROMPT "Danfe Sistema" SIZE 047, 012 OF oDlgExp Action (lPrintDf := .T.,oDlgExp:End()) PIXEL
	@ 105, 149 BUTTON oPrtCCe PROMPT "Imp.CCe" SIZE 047, 012 OF oDlgExp Action (U_PRTCCE(cChvNfe,.T.,Substr(cEmpresa,1,6),,cSchemaTss),oDlgExp:End()) PIXEL
	@ 090, 149 BUTTON oSendMail PROMPT "Enviar XML p/Email" SIZE 058, 012 OF oDlgExp ACTION (sfSendMail(),) PIXEL
	@ 090, 008 BUTTON oCancela PROMPT "Cancelar" SIZE 037, 012 OF oDlgExp ACTION oDlgExp:End() PIXEL
	
	
	ACTIVATE MSDIALOG oDlgExp CENTERED On Init ( Eval({|| oEmpresa:Select(nSelEmp),oEmpresa:Refresh()}) )
	
	If lPrintDf
		sfPrtDanfe()
	Endif
	
Return


/*/{Protheus.doc} sfGetBox
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0


@example
(examples)

@see (links_or_references)
/*/
Static Function sfGetBox()
	
	Local	cQry		:= ""
	Local	aItemsBox   := {}
	Local	aAreaOld	:= GetArea()
	Local	aEmpFils	:= {}
	Local	nRecSm0		:= SM0->(Recno())
	Local	nPosFil		:= 0
	
	DbSelectArea("SM0")
	DbGotop()
	While !Eof()
		aadd(aEmpFils,{SM0->M0_CGC,SM0->M0_NOMECOM,Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL),SM0->M0_CODIGO,SM0->M0_CODFIL})
		SM0->(DbSkip())
	Enddo
	DbSelectArea("SM0")
	DbGoto(nRecSm0)
	
	cQry += "SELECT ID_ENT,CNPJ "
	cQry += "  FROM "+cSchemaTss+"SPED001 "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND ENTATIV ='S' "
	cQry += " ORDER BY ID_ENT "
	
	TCQUERY cQry NEW ALIAS "QSP"
	
	While !Eof()
		nPosFil	:= ascan(aEmpFils,{|x| x[1] == QSP->CNPJ})
		If nPosFil > 0
			aadd(aItemsBox,QSP->ID_ENT + "|"+aEmpFils[nPosFil,4]+"/"+aEmpFils[nPosFil,5]+"="+aEmpFils[nPosFil,3])
			If aEmpFils[nPosFil,4] == cEmpAnt .And. aEmpFils[nPosFil,5] == cFilAnt
				nSelEmp	:= Len(aItemsBox)
			Endif
		Endif
		DbSelectArea("QSP")
		DbSkip()
	Enddo
	QSP->(DbCloseArea())
	RestArea(aAreaOld)
	
Return aItemsBox


/*/{Protheus.doc} sfGetMail
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0


@example
(examples)

@see (links_or_references)
/*/
Static Function sfGetMail()
	
	Local	lChgTbl	:= .F.
	Local	nOrderF2 := SF2->(IndexOrd())
	Local	nOrderA1 := SA1->(IndexOrd())
	Local	nOrderA2 := SA2->(IndexOrd())
	
	
	
	If !(EqualFullName("SF2",Substr(cEmpresa,8,nLenEmp),cEmpAnt))
		//...Abre a Tabela da Nova Empresa
		If EmpChangeTable("SF2",Substr(cEmpresa,8,nLenEmp),cEmpAnt,nOrderF2 )
			lChgTbl	:= .T.
		EndIF
	Endif
	If !(EqualFullName("SA1",Substr(cEmpresa,8,nLenEmp),cEmpAnt))
		//...Abre a Tabela da Nova Empresa
		If EmpChangeTable("SA1",Substr(cEmpresa,8,nLenEmp),cEmpAnt,nOrderA1 )
			lChgTbl	:= .T.
		EndIF
	Endif
	
	If !(EqualFullName("SA2",Substr(cEmpresa,8,nLenEmp),cEmpAnt))
		//...Abre a Tabela da Nova Empresa
		If EmpChangeTable("SA2",Substr(cEmpresa,8,nLenEmp),cEmpAnt,nOrderA2 )
			lChgTbl	:= .T.
		EndIF
	Endif
	
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(Substr(cEmpresa,8+nLenEmp+1,nLenFil)+cNumero+cSerie)
		cF2_TIPO	:= SF2->F2_TIPO
		cChvNfe		:= SF2->F2_CHVNFE
		cIdCCe		:= Substr(SF2->F2_IDCCE,3)
		If SF2->F2_TIPO $ "B#D"
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			cDadosCliente	:= SA2->A2_COD + '/' + SA2->A2_LOJA + '-' + SA2->A2_NOME
			cEmail			:= SA2->A2_EMAIL
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			cDadosCliente	:= SA1->A1_COD + '/' + SA1->A1_LOJA + '-' + SA1->A1_NOME
			cEmail			:= SA1->A1_EMAIL
		Endif
		cCodCli			:= SF2->F2_CLIENTE
		cLojCli			:= SF2->F2_LOJA
		dDataEmis		:= IIf(!Empty(SF2->F2_DAUTNFE),SF2->F2_DAUTNFE,SF2->F2_EMISSAO)
	Else
		cDadosCliente	:= ""
		cEmail			:= ""
		cCodCli			:= ""
		cLojCli			:= ""
		dDataEmis		:= dDataBase
		cChvNfe			:= Space(44)
		cIdCCe			:= Space(TamSX3("F2_IDCCE")[1])
		MsgAlert("Não houveram dados para a Empresa/Série e Número de Nota Fiscal informados. Verifique novamente a numeração!","A T E N Ç Ã O!!!")
	Endif
	
	If lChgTbl
		//Restaura a Tabela da Empresa Atual
		EmpChangeTable("SF2",cEmpAnt,Substr(cEmpresa,8,nLenEmp),nOrderF2 )
		EmpChangeTable("SA1",cEmpAnt,Substr(cEmpresa,8,nLenEmp),nOrderA1 )
		EmpChangeTable("SA2",cEmpAnt,Substr(cEmpresa,8,nLenEmp),nOrderA2 )
	Endif
	
	oDadosCliente:Refresh()
	oEmail:Refresh()
	oChvNfe:Refresh()
	
Return


/*/{Protheus.doc} sfZeraGet
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0


@example
(examples)

@see (links_or_references)
/*/
Static Function sfZeraGet()
	
	cDadosCliente	:= ""
	cEmail			:= Space(TamSX3("A1_EMAIL")[1])
	cSerie			:= Space(TamSX3("F2_SERIE")[1])
	cNumero			:= Space(TamSX3("F2_DOC")[1])
	cCodCli			:= ""
	cLojCli			:= ""
	
	oDadosCliente:Refresh()
	oEmail:Refresh()
	oSerie:Refresh()
	oNumero:Refresh()
	
Return

Static Function sfSetMail()
	
	Local	lChgTbl	:= .F.
	Local	nOrderA1 := SA1->(IndexOrd())
	Local	nOrderA2 := SA2->(IndexOrd())
	
	
	
	If !(EqualFullName("SA1",Substr(cEmpresa,8,nLenEmp),cEmpAnt))
		//...Abre a Tabela da Nova Empresa
		If EmpChangeTable("SA1",Substr(cEmpresa,8,nLenEmp),cEmpAnt,nOrderA1 )
			lChgTbl	:= .T.
		EndIF
	Endif
	
	If !(EqualFullName("SA2",Substr(cEmpresa,8,nLenEmp),cEmpAnt))
		//...Abre a Tabela da Nova Empresa
		If EmpChangeTable("SA2",Substr(cEmpresa,8,nLenEmp),cEmpAnt,nOrderA2 )
			lChgTbl	:= .T.
		EndIF
	Endif
	
	If cF2_TIPO	$ "B#D"
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+cCodCli+cLojCli)
		RecLock("SA2",.F.)
		SA2->A2_EMAIL	:= cEmail
		MsUnlock()
		MsgAlert("Atualização efetuada!")
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+cCodCli+cLojCli)
		RecLock("SA1",.F.)
		SA1->A1_EMAIL	:= cEmail
		MsUnlock()
		MsgAlert("Atualização efetuada!")
	Endif
	
	If lChgTbl
		//Restaura a Tabela da Empresa Atual
		EmpChangeTable("SA1",cEmpAnt,Substr(cEmpresa,8,nLenEmp),nOrderA1 )
		EmpChangeTable("SA2",cEmpAnt,Substr(cEmpresa,8,nLenEmp),nOrderA2 )
	Endif
	
	
	
Return



/*/{Protheus.doc} sfViewNfe
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0

@param lOnlyView, logico, (Descrição do parâmetro)
@param lExpCce, logico, (Descrição do parâmetro)

@example
(examples)

@see (links_or_references)
/*/
Static Function sfViewNfe(lOnlyView,lExpCce)
	
	Local	cLocDir		:= GetTempPath() //"C:\NF-e\"
	Local	cSerDir		:= "\NF-e\"
	Local	cDirDest	:= cSerDir
	Local	lEnd		:= .F.
	Default	lExpCce		:= .F.
	
	MakeDir(cLocDir)
	
	cIdEnt	:= Substr(cEmpresa,1,6)
	
	cAviso	:= ""
	cErro	:= ""
	
	aNotas	:= {}
	
	aadd(aNotas,{})
	aadd(Atail(aNotas),.F.)
	aadd(Atail(aNotas),"S")
	aadd(Atail(aNotas),dDataEmis)
	aadd(Atail(aNotas),cSerie)
	aadd(Atail(aNotas),cNumero)
	aadd(Atail(aNotas),cCodCli)
	aadd(Atail(aNotas),cLojCli)
	
	aXml := StaticCall(DanfeII,GetXml,cIdEnt,aNotas,@cModalidade)
	
	//xParam1 := NomeDoPrograma (sem aspas), onde se encontra a Static Function
	//xParam2 := NomeDaStaticFunction (sem aspas), a ser executada
	//xParam3 := A partir desse espaço são definidos os parametros que são passados
	If Len(aXML) <= 0
		Return
	Endif
	
	If Empty(cErro) .And. Empty(cAviso)
		cChave 	:= SubStr(NfeIdSPED(aXML[1][2],"Id"),4)
		cExtArq	:= Substr(NfeIdSPED(aXML[1][2],"Id"),1,3)
		If lExpCCE
			cExtArq		:= "CCe"
		Endif
		
		If lOnlyView .Or. lExpCCe
			cDirDest	:= cLocDir
			cAnexo	  	:= cLocDir+Iif(lExpCCe,cIdCCe+"-CCe.xml",cChave+"-"+cExtArq+".xml")
		Else
			cDirDest	:= cSerDir
			cAnexo    	:= cSerDir+Iif(lExpCce,cIdCCe+"-Cce.xml",cChave+"-"+cExtArq+".xml")
		Endif
		//	cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml")
	EndIf
	//         cIdEnt,cSerie    ,cNotaIni  ,cNotaFim  ,cDirDest  ,lEnd, dDataDe  ,dDataAte                                   ,cCnpjDIni,cCnpjDFim,nTipo
	//                 SpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],lEnd,aParam[05]  ,IIF(Empty(aParam[06]),dDataBase,aParam[06]),         ,         ,nTipo)
	StaticCall(SPEDNFE,SpedPExp,cIdEnt,cSerie    ,cNumero   ,cNumero   ,cDirDest  ,lEnd,Iif(lExpCce,CtoD("  /  /  "),dDataEmis),Iif(lExpCCe,CtoD("  /  /  "),dDataEmis)," "/*cCnpjDIni*/,"ZZZZ"/*cCnpjDFim*/,Iif(lExpCce,2,1))
	
	
	If lOnlyView
		ShellExecute("open",cAnexo,"",cDirDest,1)
	Endif
	
	//MsgAlert(cAnexo)
	
Return {cAnexo,cChave}


/*/{Protheus.doc} sfSendMail
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0


@example
(examples)

@see (links_or_references)
/*/
Static Function sfSendMail()
	
	Local 	oServer
	Local 	oMessage
	Local 	oDlgEmail
	Local	aAreaOld	:= GetArea()
	
	
	cTo			:= cEmail
	cSubject    := "NFe Nacional"
	cBody		:= "Envio de Arquivo XML de Maneira Manual:  "+Chr(13)+Chr(10)
	
	lSend	:= .F.
	
	DEFINE MSDIALOG oDlgEmail Title OemToAnsi("Enviar email da Nota Fiscal Eletrônica") FROM 001,001 TO 380,620 PIXEL
	@ 010,010 Say "Para: " Pixel of oDlgEmail
	@ 010,050 MsGe cTo Size 150,10 Pixel Of oDlgEmail
	@ 025,010 Say "Assunto" Pixel of oDlgEmail
	@ 025,050 MsGet cSubject Size 250,10 Pixel Of oDlgEmail
	@ 040,050 Get cBody of oDlgEmail MEMO Size 250,100 Pixel
	@ 160,030 BUTTON "Confirma" Size 70,10 Action (lSend := .T.,oDlgEmail:End())	Pixel Of oDlgEmail
	@ 160,120 BUTTON "Cancela" Size 70,10 Action (oDlgEmail:End())	Pixel Of oDlgEmail
	
	ACTIVATE MsDialog oDlgEmail Centered
	
	If lSend
		
		//Crio a conexão com o server STMP ( Envio de e-mail )
		oServer := TMailManager():New()
		// Usa SSL na conexao
		If GetMv("XM_SMTPSSL")
			oServer:setUseSSL(.T.)
		Endif
		// Usa TLS na conexao
		If GetNewPar("XM_SMTPTLS")
			oServer:SetUseTLS(.T.)
		Endif
		
		//oServer:Init( "", "mail.gmeyer.com.br", "nfexml@gmeyer.com.br", "nfegmxml4601", 0, 25 )
		oServer:Init( ""		,Alltrim(GetMv("XM_SMTP")), Alltrim(GetMv("XM_SMTPUSR"))	,Alltrim(GetMv("XM_PSWSMTP")),	0			, GetMv("XM_SMTPPOR") )
		
		//seto um tempo de time out com servidor de 1min
		If oServer:SetSmtpTimeOut( GetMv("XM_SMTPTMT")) != 0
			Conout( "Falha ao setar o time out" )
			Return .F.
		EndIf
		
		//realizo a conexão SMTP
		If oServer:SmtpConnect() != 0
			Conout( "Falha ao conectar" )
			Return .F.
		EndIf
		// Realiza autenticacao no servidor
		If GetMv("XM_SMTPAUT")
			nErr := oServer:smtpAuth(Alltrim(GetMv("XM_SMTPUSR")), Alltrim(GetMv("XM_PSWSMTP")))
			If nErr <> 0
				ConOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
				Alert("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
				oServer:smtpDisconnect()
				RestArea(aAreaOld)
				Return .F.
			Endif
		Endif
		
		//Apos a conexão, crio o objeto da mensagem
		oMessage := TMailMessage():New()
		//Limpo o objeto
		oMessage:Clear()
		//Populo com os dados de envio
		oMessage:cFrom 		:= GetMv("XM_SMTPDES")
		oMessage:cTo 		:= cTo
		oMessage:cCc 		:= UsrRetMail(__cUserId)
		oMessage:MsgBodyType( "text/html" )
		oMessage:cSubject 	:= cSubject
		//oMessage:MsgBodyType( "text" )
		oMessage:cBody 		:= cBody
		
		cAviso	:= ""
		cErro	:= ""
		
		aArqAttach	:= sfViewNfe(.F.)
		
		
		
		//Adiciono um attach
		If oMessage:AttachFile(aArqAttach[1]) < 0
			Conout( "Erro ao atachar o arquivo" )
			MsgAlert("Não foi possível anexar o arquivo.","Erro" )
			Return .F.
		Else
			//adiciono uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+aArqAttach[2]+'-'+cExtArq+'.xml')
		EndIf
		
		//Envio o e-mail
		If oMessage:Send( oServer ) != 0
			Conout( "Erro ao enviar o e-mail" )
			Return .F.
		Else
			MsgAlert("Email enviado com sucesso!","Concluído")
		EndIf
		
		//Disconecto do servidor
		If oServer:SmtpDisconnect() != 0
			Conout( "Erro ao disconectar do servidor SMTP" )
			Return .F.
		EndIf
	Endif
	
Return




/*/{Protheus.doc} sfPrtDanfe
@author Administrator
@since 21/04/2017
@version undefined

@type function
/*/
Static Function sfPrtDanfe()
	
	Local	aAreaOld	:= GetArea()
	
	cIdEnt	:= Substr(cEmpresa,1,6)
	
	
	If cIdEnt <>  StaticCall(SPEDNFE,GetIdEnt)
		MsgAlert("O Danfe que você quer imprimir não pertence a Empresa atualmente Logada!","Empresa/Filial Errada")
		RestArea(aAreaOld)
		Return
	Endif
	
	
	oPrintSetup	:= FWPrintSetup():New(0,"Impressão de DAnfe")
	oPrintSetup:aOptions[PD_DESTINATION]    := AMB_CLIENT
	oPrintSetup:aOptions[PD_PRINTTYPE]	 	:= IMP_SPOOL
	oPrintSetup:aOptions[PD_ORIENTATION]	:= PORTRAIT
	oPrintSetup:aOptions[PD_PAPERSIZE]		:= DMPAPER_A4
	oPrintSetup:aOptions[PD_PREVIEW]		:= .T.
	//			oPrintSetup:aOptions[PD_VALUETYPE]		:= "PDF_Printer"
	oPrintSetup:aOptions[PD_MARGIN]			:= {60,60,60,60}
	//#DEFINE PD_MARGIN				7
	
	
	oDanfe 	:= FWMSPrinter():New("DANFE_"+cIdEnt+DTOS(dDataBase)+Alltrim(Str(Randomize(1,10000))),oPrintSetup:aOptions[PD_PRINTTYPE]/*nDevice*/,.F./*lAdjustToLegacy]*/,/*cPathInServer*/,.F./*lDisabeSetup*/,.T./*lTReport*/,@oPrintSetup,oPrintSetup:aOptions[PD_VALUETYPE]/*cPrinter*/,.F./*lServer*/)
	oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
	oDanfe:SetPortrait()
	oDanfe:SetPaperSize(DMPAPER_A4)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:lServer := oPrintSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
	oDanfe:Setup()
	
	If oDanfe:nDevice == IMP_PDF
		oPrintSetup:aOptions[PD_PRINTTYPE]	:= oDanfe:nDevice
		oPrintSetup:aOptions[PD_VALUETYPE]	:= oDanfe:cPathPDF
	ElseIf oDanfe:nDevice == IMP_SPOOL
		oPrintSetup:aOptions[PD_VALUETYPE]	:= oDanfe:cPrinter
	Endif
	
	cArqDel	:= Alltrim(oDanfe:cFilePrint)
	FreeObj(oDanfe)
	oDanfe := Nil
	fErase(cArqDel)
	
	oDanfe 	:= FWMSPrinter():New("DANFE_"+cIdEnt+DTOS(dDataBase)+Alltrim(Str(Randomize(1,10000))),oPrintSetup:aOptions[PD_PRINTTYPE]/*nDevice*/,.F./*lAdjustToLegacy]*/,/*cPathInServer*/,.F./*lDisabeSetup*/,.F./*lTReport*/,@oPrintSetup,oPrintSetup:aOptions[PD_VALUETYPE]/*cPrinter*/,.F./*lServer*/)
	
	If oPrintSetup:aOptions[PD_VALUETYPE] == Nil
		RestArea(aAreaOld)
		Return
	Endif
	
	If !Empty(cNumero)
		// Grava as perguntas 
		DbSelectArea("SX1")
		DbSetOrder(1)
		cPerg := "NFSIGW"
		cPerg :=  PADR(cPerg,Len(SX1->X1_GRUPO))
		
		U_GravaSX1(cPerg,"01",cNumero)
		U_GravaSX1(cPerg,"02",cNumero)
		U_GravaSX1(cPerg,"03",cSerie)
		U_GravaSX1(cPerg,"04",2)
		
	Endif
	
	U_PrtNfeSef(cIdEnt,,,oDanfe,oPrintSetup)
	
	RestArea(aAreaOld)
	
Return
