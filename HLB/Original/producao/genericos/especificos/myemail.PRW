#include "Protheus.ch"
#include "topconn.ch"
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
#define STR0414  "Sem manifestação"
#define STR0415  "Confirmada"
#define STR0416  "Desconhecida"
#define STR0417  "Não realizada"
#define STR0418  "Ciência"
#define STR0419  "210200 - Confirmação da Operação"
#define STR0420  "210210 - Ciência da Operação"
#define STR0421  "210220 - Desconhecimento da Operação"
#define STR0422  "210240 - Operação não Realizada"


/*/{Protheus.doc} myEMail
(Efetua leitura dos arquivos XML a partir de Email/pasta)

@author MarceloLauschner
@since 07/04/2012
@version 1.0

@param lConSefMan, logico, (Descrição do parâmetro)
@param lExecAuto, logico, (Descrição do parâmetro)
@param xCodEmp, variavel, (Descrição do parâmetro)
@param xCodFil, variavel, (Descrição do parâmetro)

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
User Function myEMail(aParam) //lConSefMan,lExecAuto)
	//User Function myEMail(lConSefMan,lExecAuto,xCodEmp,xCodFil)

	Private oServer
	Private	oMessage
	Private	lRetGrv 		:= .F.
	Private	lSave			:= .F.
	Private	cFileSave		:= ""
	Private	cXmlSave		:= ""
	Private cArqAttAch		:= ""
	Private	cAttachName		:= ""
	Private	cAttXmlName		:= ""
	Private	aAttInfo		:= {}
	Private	cReadWf			:= ""
	Private	cText			:= ""
	Private	cMsgRetMail		:= ""
	Private	aSize 			:= MsAdvSize( .T., .F., 400 )		// Size da Dialog
	Private nAltura 		:= aSize[6]/2.2
	Private	nNumMsg 		:= 0
	Private	nTam    		:= 0
	Private	cChave 			:= ""
	Private lAutoExec		:= .F.
	Private	lSefMan			:= .F.
	Private	lIsDebug		:= GetNewPar("XM_DBGRXML",.F.) // Debuga o recebimento de E-mails para mostrar alertas 
	Private	lMadeira		:= .F.//SM0->M0_CGC $ "10490181000135#10490181000216"
	Default aParam			:= {.F./*lConSefMan*/,;
	.F./*lExecAuto*/,;
	cEmpAnt,;
	cFilAnt,;
	__cUserId} //  array com os parâmetros passados no agendamento + Código Grupo Empresa + Código Filial + Código Usuário + Id da tarefa.



	// Atribui variavel para uso na rotina
	// Melhoria em 27/04/2013 para permitir a baixa de emails via Job.
	lSefMan			:= aParam[1]
	lAutoExec		:= aParam[2]

	If IsBlind()
		lAutoExec	:= .T.
	Endif

	Private	cLeftNil		:= GetNewPar("XM_LEFTNIL","0")
	Private	cBarLinx		:= IIf(IsSrvUnix(),"/","\")
	Private	cDirNfe    		:= IIf(IsSrvUnix(),StrTran( GetNewPar("XM_DIRXML",cBarLinx+"nf-e"+cBarLinx),"\","/"),GetNewPar("XM_DIRXML",cBarLinx+"nf-e"+cBarLinx))	//	IIf(IsSrvUnix(),"/nf-e/", "\Nf-e\"))
	Private	cDirMailNfe 	:= cDirNfe + "mail" + cBarLinx	//	IIf(IsSrvUnix(),cDirNfe+"mail/", cDirNfe+"Mail\")
	Private cDirXmlOld		:= cDirNfe + "importados" + cBarLinx + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+cBarLinx	//	Iif(isSrvUnix(),cDirNfe+"importados/",cDirNfe+"Importados\")+DTOS(Date())+IIf(IsSrvUnix(),"/","\")
	Private	cDirSchema 		:= IIf(IsSrvUnix(),"/schemas/", "\schemas\")
	Private	cTipoDoc		:= "N"	// Variavel para identificar o tipo de Nota fiscal N=Normal;B=Beneficiamento;D=Devolução
	Private cRootPath		:= GetSrvProfString ("RootPath","\indefinido")
	Private cCfopRet		:= GetMv("XM_CFOPRET")
	Private cCfopDev		:= GetMv("XM_CFOPDEV")
	// Atribui valor somente depois de existir a abertura de tabelas
	lMadeira		:= "10490181" == Substr(SM0->M0_CGC,1,8)


	If GetMv("XM_DIRPOP")
		sfRecMail()
		If GetNewPar("XM_DIRPOP1",.F.)
			sfRecDir()
		Endif
	ElseIf GetNewPar("XM_DIRPOP1",.F.)
		sfRecMail()
		sfRecDir()
	Else
		sfRecDir()
		If GetNewPar("XM_DIRPOP1",.F.)
			sfRecMail()
		Endif
	Endif

Return


/*/{Protheus.doc} sfRecMail
(long_description)
@author MarceloLauschner
@since 21/04/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRecMail()

	Local	y
	Local	nI,iH,iR
	Local	a
	Local	cSubjectAux		:= ""
	Local	cBodyAux		:= ""
	Local	cToAux			:= ""
	Local	cAttInfo		:= ""

	Local	nRet1			:= MakeDir(cDirNfe)
	Local	nRet2 			:= MakeDir(cDirMailNfe)
	Local	nRet3,nRet4,nRet5
	Local	cCorpoM
	Local	aArqZip			:= {}
	//Crio uma nova conexão, agora de POP
	oServer 	:= TMailManager():New()
	oMessage 	:= TMailMessage():New()
	// Usa SSL na conexao
	If GetMv("XM_POPSSL")
		oServer:setUseSSL(.T.)
	Endif


	oServer:Init( Alltrim(GetMv("XM_POP")),"", Alltrim(GetMv("XM_POPUSR"))	,Alltrim(GetMv("XM_PSWPOP")), GetMv("XM_POPPORT") ,0)

	If  Alltrim(GetNewPar("XM_TCPMAIL","POP3")) == "POP3"
		If oServer:SetPopTimeOut( 60 ) != 0
			Conout( "Falha ao setar o time out" )
			Return .F.
		EndIf

		If oServer:PopConnect() != 0
			Conout( "Falha ao conectar" )
			Return .F.
		EndIf
	Else

		If oServer:IMAPConnect() != 0
			Conout( "Falha ao conectar" )
			Alert("Falha ao conectar Imap")
			Return .F.
		Else
			//Alert("Conexão IMAP OK!")
		EndIf
	Endif

	//Recebo o número de mensagens do servidor
	oServer:GetNumMsgs( @nNumMsg )
	nTam := nNumMsg

	If nTam == 0
		If !lAutoExec
			MsgAlert("Não há e-mails a receber!")
		Endif
	Endif
	nContOk	:= 0
	// 14/03/2017 - Verifica se a quantidade e-mails é maior que o limite do parâmetro e seta limite
	If GetNewPar("XM_NRMAIL",nTam) < nTam
		nTam	:= GetNewPar("XM_NRMAIL",nTam) // Apesar de poder existir mais emails na caixa de Entrada, limito pelo parametro os emails para evitar sobre carga da rotina
	Endif

	// Só faço o controle de Semaforo
	If !stControle(.F.)
		Return
	Endif

	nRet5 := 0
	// Cria o Diretorio se precisar
	If !(ExistDir(cDirNfe + StrZero(Year(Date()),4)))
		nRet3	:= MakeDir(cDirNfe + StrZero(Year(Date()),4))
	Endif

	If !(ExistDir(cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) ))
		nRet4	:= MakeDir(cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) )
	Endif
	If !(ExistDir(cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)))
		nRet5	:= MakeDir(cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2))
		//cRootPath + cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx + cAttXmlName
	Endif

	If nRet5 <> 0
		If lAutoExec
			ConOut( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
		Else
			Aviso( "Não possível criar o diretório. "+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))), + cValToChar( FError() ) + Chr(13)+;
			cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2), { "Ok" }, 2 )
		Endif
	Else
		//Aviso( "Diretório. "+ProcName(0)+"."+ Alltrim(Str(ProcLine(0))), + cValToChar( FError() ) + Chr(13)+;
		//	cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2), { "Ok" }, 2 )
	Endif

	ProcRegua(nTam)
	For nI := 1 To nTam

		IncProc("Recebendo email "+Alltrim(Str(nI)) + " / " + Alltrim(Str(nTam))+ ". Aguarde!" )
		//Limpo o objeto da mensagem
		oMessage:Clear()
		//Recebo a mensagem do servidor
		oMessage:Receive( oServer, nI )
		cChave	:= " "



		// Declaro variavel para enviar retorno ou não
		cMsgRetMail	:= ""
		//Escrevo no server os dados do e-mail recebido


		nContOk++

		lRetGrv 	:= .T.
		lSave		:= .T.
		cFileSave	:= ""
		cXmlSave	:= ""
		cAttachName	:= ""
		cAttXmlName	:= ""

		For y := 1 to oMessage:getAttachCount()

			aAttInfo:= oMessage:getAttachInfo(y)
			// Analisa se há informaçaõ de anexo e se o arquivo anexo é um XML
			//Estrutura de retorno:
			//  Nome				Descrição
			//1 ShortName			O nome do attachment.
			//2 Type				O tipo do anexo, por exemplo, text/plain ou image/x-png.
			//3 Disposition			Tipo do arquivo.
			//4 DispositionName		Nome do tipo de arquivo.
			//5 ID					Identificação do anexo.
			//6 Location			Local físico do anexo.
			//7 *Size Tamanho do anexo.* Parâmetro Size só estará disponível em versão superior a 7.00.131227A.

			cAttInfo	:= 	aAttInfo[1]
			If lIsDebug
				For iH := 1 To Len(aAttInfo)
					MsgAlert(aAttInfo[iH],cValToChar(iH))
				Next
			Endif

			// Se o ShortName estiver em branco procura pelo DispositionName
			If Empty(cAttInfo)
				cAttInfo	:= aAttInfo[4]
			Endif
			// Se o ShortName e DispositionName estiverem em branco procura pelo Type
			If Empty(cAttInfo)
				cAttInfo	:= SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
			Endif

			If  At(".XML",UPPER(cAttInfo)) > 0
				cAttXmlName	:= cAttInfo
				cAttXmlName	:= Lower(cAttXmlName)
				// Removendo letras invalidas para o nome do arquivo
				cAttXmlName	:= StrTran(cAttXmlName,"<","")
				cAttXmlName	:= StrTran(cAttXmlName,">","")
				cAttXmlName	:= StrTran(cAttXmlName,"-","")
				cAttXmlName	:= StrTran(cAttXmlName,"/","")
				cAttXmlName	:= StrTran(cAttXmlName,"\","")
				cAttXmlName	:= StrTran(cAttXmlName,"(","")
				cAttXmlName	:= StrTran(cAttXmlName,")","")
				cAttXmlName := StrTran(cAttXmlName,'"','')
				cAttXmlName := StrTran(cAttXmlName,"'","")
				cAttXmlName := StrTran(cAttXmlName,"=","")
				cAttXmlName := StrTran(cAttXmlName,"name=","")
				cAttXmlName := NoAcento(cAttXmlName)
				cAttachName	:= cAttXmlName
				//cXmlSave		:= cRootPath+cDirNfe+DTOS(Date())+IIf(IsSrvUnix(),"/","\")+cAttXmlName
				cXmlSave		:= cRootPath + cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx + cAttXmlName
				cArqAttAch		:= cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx + cAttXmlName


				lSave 			:= oMessage:SaveAttach(y,cXmlSave)
				//Alert(cRootPath+cDirNfe+cAttInfo)

				cText 		:= oMessage:getAttach(y)

				cTextAux	:= cText

				// Se o anexo contiver tag de arquivo xml
				//              Autorizado o uso da NF-e
				//				     <cStat>100</cStat><xMotivo>Autorizado
				//				<xMotivo>Autorizado o uso de NF-e
				//<cStat>100</cStat><xMotivo>Autorizado o uso de NF-e</
				//<cStat>100</cStat><xMotivo>Autorizado o uso de NF-e
				If lSave
					//Aviso("Leitura do XML - Emailmar!",cText,{"Ok"},3)
					lRetGrv	:= .F.
					cTextAux	:= Upper(cTextAux)
					cTextAux	:= StrTran(cTextAux, Chr(13)+ Chr(10),"")
					cTextAux	:= StrTran(cTextAux, Chr(10),"")

					cTextDec	:= DecodeUTF8(cText, "iso8859-1")
					If cTextDec == Nil
						cTextDec	:= cText
					Endif

					// Verifica se é nota fiscal eletronica
					// Validação simplificada
					If ((At('<UF>EX</UF>',cTextAux) > 0) .And. At('<CNPJ>'+ SM0->M0_CGC+ '</CNPJ>',cTextAux) > 0 ) .Or. ;
						At("<NFEPROC",cTextAux) > 0 .And. (At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0)  
						//Aviso("Entrou para Gravar Xml NFe!",cTextAux,{"Ok"},3)
						Begin Transaction
							lRetGrv := sfGrvXmlNfe(cTextDec,.T.,oMessage,oServer)
						End Transaction
					Endif
					// Efetua tentativa de verificar se é CTEOS
					If !lRetGrv
						If At("<CTEOS",cTextAux) > 0 .And.;
						((At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0))
							//MsgAlert("Entrou para gravar sfgrvxmlcte "+cText,"154")
							Begin Transaction
								lRetGrv := sfGrvCTEOS(cTextDec,.T.,oMessage,oServer)
							End Transaction
						Endif
					Endif
					
					// Efetua tentativa de verificar se é CTE
					If !lRetGrv
						If At("<CTE",cTextAux) > 0 .And.;
						((At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0))
							//MsgAlert("Entrou para gravar sfgrvxmlcte "+cText,"154")
							Begin Transaction
								lRetGrv := sfGrvXmlCte(cTextDec,.T.,oMessage,oServer)
							End Transaction
						Endif
					Endif
					
					// Efetua tentativa de verificar se é CCe
					If !lRetGrv
						If At("<TPEVENTO>110110</TPEVENTO>",Upper(cTextAux)) > 0
							//MsgAlert("Entrou para gravar sfgrvxmlcce "+cText,"161")
							Begin Transaction
								lRetGrv := sfGrvCCe(cTextDec,.T.,oMessage,oServer)
							End Transaction
							If !lRetGrv
								cMsgRetMail	+= "Não validou CCe '" + cText +"'"
							Endif
						Endif
					Endif

					// Efetua tentativa de verificar se é um evento de cancelamento de NFe/Cte
					If !lRetGrv
						If (	At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or.;
						At("<DESCEVENTO>CANCELAMENTO</DESCEVENTO>",cTextAux) > 0)
							//MsgAlert("Entrou para gravar sfgrvxmlcce "+cText,"161")
							Begin Transaction
								lRetGrv := sfGrvCanc(cTextDec,.T.,oMessage,oServer)
							End Transaction
							If !lRetGrv
								cMsgRetMail	+= "Não validou evento de cancelamento '" + cText +"'"
							Endif
						Endif
					Endif
				ElseIf !Empty(cText)
					StaticCall(	XMLDCONDOR,;
					stSendMail,;
					GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Erro ao gravar o arquivo'"+cXmlSave+"'" ,'"'+cText+'"')
				Endif

				// 07/10/2016 - Melhoria que apaga os XMLs gravados e importados com sucesso para o Banco de Dados.
				If !GetNewPar("XM_CPYXMLD",.T.) .And. lRetGrv .And. Empty(cMsgRetMail)
					// Apago o arquivo
					Ferase(cArqAttAch)
				Endif
				// Adicionado em 21/10/2012 para permitir a opção de salvar o pdf também no rootpath 
			ElseIf GetNewPar("XM_SAVEPDF",.T.) .And. At(".PDF",UPPER(cAttInfo)) > 0
				cAttXmlPdf	:= cAttInfo
				cAttXmlPdf	:= Lower(cAttXmlPdf)
				// Removendo letras invalidas para o nome do arquivo
				cAttXmlPdf	:= StrTran(cAttXmlPdf,"<","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,">","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,"-","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,"/","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,"\","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,"(","")
				cAttXmlPdf	:= StrTran(cAttXmlPdf,")","")
				cAttXmlPdf 	:= StrTran(cAttXmlPdf,'"','')
				cAttXmlPdf 	:= StrTran(cAttXmlPdf,"'","")
				cAttXmlPdf 	:= StrTran(cAttXmlPdf,"=","")
				cAttXmlPdf 	:= StrTran(cAttXmlPdf,"name=","")
				cAttXmlPdf 	:= NoAcento(cAttXmlPdf)

				cFileSave		:= cRootPath + cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx + cAttXmlPdf
				oMessage:SaveAttach(y,cFileSave)


			ElseIf GetNewPar("XM_SAVEZIP",.T.) .And. At(".ZIP",UPPER(cAttInfo)) > 0 
				cAttXmlName	:= cAttInfo
				cAttXmlName	:= Lower(cAttXmlName)
				// Removendo letras invalidas para o nome do arquivo
				cAttXmlName	:= StrTran(cAttXmlName,"<","")
				cAttXmlName	:= StrTran(cAttXmlName,">","")
				cAttXmlName	:= StrTran(cAttXmlName,"-","")
				cAttXmlName	:= StrTran(cAttXmlName,"/","")
				cAttXmlName	:= StrTran(cAttXmlName,"\","")
				cAttXmlName	:= StrTran(cAttXmlName,"(","")
				cAttXmlName	:= StrTran(cAttXmlName,")","")
				cAttXmlName := StrTran(cAttXmlName,'"','')
				cAttXmlName := StrTran(cAttXmlName,"'","")
				cAttXmlName := StrTran(cAttXmlName,"=","")
				cAttXmlName := StrTran(cAttXmlName,"name=","")
				cAttXmlName := NoAcento(cAttXmlName)
				cAttachName	:= cAttXmlName

				cDirSave		:= cRootPath + cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx 
				oMessage:SaveAttach(y,cDirSave+cAttXmlName)
				cDirSave 		:= cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx
				cArqAttAch		:= cDirNfe + StrZero(Year(Date()),4) + cBarLinx + StrZero(Month(Date()),2) + cBarLinx + StrZero(Day(Date()),2)+ cBarLinx + cAttXmlName

				If lIsDebug
					MsgAlert(cDirSave+cAttXmlName,"cDirSave")
					MsgAlert(GetBuild() )      // Resultado: "7.00.131227A-20170626"
					MsgAlert(GetBuild( .T. ) ) // Resultado: "7.00.131227A-20170626"
				Endif
				If GetBuild() >= "7.00.131227A" .And. FindFunction("FListZip")
					nret := 10
					// http://tdn.totvs.com/display/tec/FUnZip
					// Função disponível apenas para builds superiores a 7.00.131227A
					__CopyFile(cDirSave+cAttachName,GetTempPath()+cAttachName)
					aArqZip	:= {}
					aRet := FListZip(GetTempPath()+cAttachName,@nret)
					If nret=0
						For ih := 1 To Len(aRet)
							//MsgAlert(aRet[ih,1])
							Aadd(aArqZip,aRet[ih,1])
						Next
					Else
						//MsgAlert("Erro: " + cvaltochar(nret))
					Endif
					// http://tdn.totvs.com/display/tec/FUnZip
					// Função disponível apenas para builds superiores a 7.00.131227A
					FUnzip( GetTempPath()+cAttachName,GetTempPath() )
					For iR := 1 To Len(aArqZip)
						If ".xml" $ Lower(aArqZip[iR])
							__CopyFile(GetTempPath()+aArqZip[iR],cDirNfe+aArqZip[iR])
						Endif
					Next iR 
					
				Else
					If !lAutoExec
						//MsgAlert("Tipo de Arquivo .Zip não permitido para recebimento de E-mails. Somente em versão superior a '7.00.131227A' Função FUnzip() estará disponível para processar arquivos Zipado. Versão atual Build "+GetBuild()+"",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
					Endif
					cMsgRetMail	+= "Tipo de Arquivo .Zip não permitido para recebimento de E-mails. Somente em versão superior a '7.00.131227A' Função FUnzip() estará disponível para processar arquivos Zipado. Versão atual Build "+GetBuild()+" " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))
					lRetGrv := .F. 
				Endif

			Endif
		Next y

		cBodyAux		:= oMessage:cBody
		cSubjectAux		:= oMessage:cSubject
		cToAux			:= oMessage:cTo

		oServer:DeleteMsg( nI )


		If !lRetGrv .And. !Empty(cMsgRetMail)


			//Crio a conexão com o server SMTP ( Envio de e-mail )
			oServer2 := TMailManager():New()

			// Usa SSL na conexao
			If GetMv("XM_SMTPSSL")
				oServer2:setUseSSL(.T.)
			Endif

			// Usa TLS na conexao
			If GetNewPar("XM_SMTPTLS",.F.)
				oServer2:SetUseTLS(.T.)
			Endif

			oServer2:Init( ""		,Alltrim(GetMv("XM_SMTP")), Alltrim(GetMv("XM_SMTPUSR"))	,Alltrim(GetMv("XM_PSWSMTP")),	0			, GetMv("XM_SMTPPOR") )

			//seto um tempo de time out com servidor de 1min
			If oServer2:SetSmtpTimeOut( GetMv("XM_SMTPTMT") ) != 0
				Conout( "Falha ao setar o time out" )
			EndIf

			//realizo a conexão SMTP
			If oServer2:SmtpConnect() != 0
				Conout( "Falha ao conectar" )
			EndIf

			// Realiza autenticacao no servidor
			If GetMv("XM_SMTPAUT")
				nErr := oServer2:smtpAuth(Alltrim(GetMv("XM_SMTPUSR")), Alltrim(GetMv("XM_PSWSMTP")))
				If nErr <> 0
					ConOut("[ERROR]Falha ao autenticar: " + oServer2:getErrorString(nErr))
					Alert("[ERROR]Falha ao autenticar: " + oServer2:getErrorString(nErr))
					oServer2:smtpDisconnect()
				Endif
			Endif
			//Apos a conexão, crio o objeto da mensagem
			oMessage2 := TMailMessage():New()
			//Limpo o objeto
			//Populo com os dados de envio
			oMessage2:cFrom 		:= GetMv("XM_SMTPDES")
			oMessage2:cTo 			:= GetNewPar("XM_MAILADM","marcelolauschner@gmail.com")
			// Efetua tratativa para avisar outros destinatários do email de que o email foi rejeitado
			//cCcEmail	:= StrTran(StrTran(cToAux,Alltrim(GetMv("XM_POPUSR")),""),";;",";")

			//If !Empty(Alltrim(cCcEmail))
			//	oMessage2:cCc 			:= cCcEmail
			//Endif
			If Type("lMadeira") == "L" .And. !lMadeira
				oMessage2:cBcc 		:= "contato@centralxml.com.br"
			Endif
			oMessage2:cSubject 		:= OemToAnsi("Resposta automática de rejeição do Email-> "+ cSubjectAux )

			cCorpoM	:= ""
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
			cCorpoM += "<br><br>"
			cCorpoM += AllTrim(OemToAnsi(cMsgRetMail)+ "<br><br>" + OemToAnsi(cBodyAux))
			cCorpoM += "<br>"
			cCorpoM += "<br>"
			cCorpoM += "Este email é disparado automaticamente pela rotina Central XML - Favor não Responder."
			cCorpoM += "<br>"
			cCorpoM += "________________________________________________________________________"
			cCorpoM += "<br>"


			cCorpoM += "Powered by Central XML. - " +"Versão : " + GetNewPar("XM_CTRLVRS","Central XML - 4.2017D-10A")
			cCorpoM += "</body> "
			cCorpoM += "</html>"

			oMessage2:MsgBodyType( "text/html" )
			oMessage2:cBody 		:= cCorpoM //OemToAnsi("Email de resposta automática. Não foi possível ler o XML de seu e-mail enviado." + Chr(13)+Chr(10)+cMsgRetMail+ Chr(13)+Chr(10)+cBodyAux + Chr(13)+Chr(10)+"'"+cText+"'")

			//Adiciono um attach
			If oMessage2:AttachFile( cArqAttAch) < 0
				Conout( "Erro ao atachar o arquivo " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
				//	MsgAlert("Não foi possível anexar o arquivo.","Erro" )
			Else
				//adiciono uma tag informando que é um attach e o nome do arq
				oMessage2:AddAtthTag( 'Content-Disposition: attachment; filename='+Alltrim(cAttachName))
			EndIf

			//Envio o e-mail
			If oMessage2:Send( oServer2 ) != 0
				Conout( "Erro ao enviar o e-mail " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
			EndIf

			//Disconecto do servidor
			If oServer2:SmtpDisconnect() != 0
				Conout( "Erro ao disconectar do servidor SMTP " + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
			EndIf

			FreeObj(oServer2)
			fErase(cArqAttAch)


		Endif



	Next nI

	// Libera o controle
	stControle(.T.)


	If  Alltrim(GetNewPar("XM_TCPMAIL","POP3")) == "POP3"
		//Diconecto do servidor POP
		oServer:POPDisconnect()
	Else
		//Diconecto do servidor IMAP
		oServer:IMAPDisconnect()
	Endif

Return

/*/{Protheus.doc} sfRecDir
(long_description)
@author MarceloLauschner
@since 01/11/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRecDir()

	Local	cDirImpXml	:= Alltrim(GetNewPar("XM_DIRMAPD",cDirNfe))
	Local	aFiles
	Local	nForA
	Local	cCorpoM

	If Empty(cDirImpXml)
		cDirImpXml	:= Alltrim(cDirNfe)
	Endif

	// Só faço o controle
	If !stControle(.F.)
		Return
	Endif
	cTipo    := "*.xml"
	aFiles   := Directory( cDirImpXml + cTipo)
	
	aFilesNFse	:= Directory(cDirImpXml+"*.csv")
	
	
	If Len(aFiles) <= 0
	
		If !lAutoExec
		//	MsgAlert("Não há arquivos no diretório '" + cDirImpXml + cTipo + "' ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
		Endif
		If Len(aFilesNFse) > 0
			aFiles := aFilesNFse
		Endif
		If Len(aFiles) <= 0
			// 08/03/2017
			// Se não encontrou arquivos no diretório mapeado - procura na pasta padrão \protheus_data\nf-e\
			cDirImpXml	:= Alltrim(cDirNfe)
			aFiles   := Directory( cDirImpXml + cTipo)
		Endif
	Endif

	//Incluindo criação de diretório - Old -> MakeDir(cDirXmlOld)
	If !(ExistDir(cDirNfe + "importados"))
		MakeDir(cDirNfe + "importados")
	Endif

	If !(ExistDir(cDirNfe + "importados" + cBarLinx +StrZero(Year(Date()),4)))
		MakeDir(cDirNfe + "importados" + cBarLinx + StrZero(Year(Date()),4))
	Endif

	If !(ExistDir(cDirNfe + "importados" + cBarLinx + StrZero(Year(Date()),4)+ cBarLinx + StrZero(Month(Date()),2) ))
		MakeDir(cDirNfe + "importados" + cBarLinx + StrZero(Year(Date()),4)+ cBarLinx + StrZero(Month(Date()),2) )
	Endif

	If Len(aFiles) > 0 //Verifica/Cria apenas se for importar arquivo
		If !(ExistDir(cDirXmlOld)) .And. GetNewPar("XM_CPYXMLD",.T.)
			MakeDir(cDirXmlOld)
		Endif
	Endif

	ProcRegua(Len(aFiles))

	For nForA := 1 To Len(aFiles)
		IncProc("Processando XML "+Alltrim(Str(nForA)) + " / " + Alltrim(Str(Len(aFiles)))+ ". Aguarde!" )

		cFile	:= Alltrim( cDirImpXml + aFiles[nForA][1])
		If !File(cFile)
			If !lAutoExec
				MsgAlert("Arquivo xml inexistente!!"+ cFile,"Atenção")
			Endif
		ElseIf ".csv" $ Lower(aFiles[nForA][1]) 
			If sfReadNFSe("",.F.,,,cFile)
				Ferase(cFile)
			Endif
		Else
			cAttachName		:= ""
			cArqAttAch		:= ""


			cMsgRetMail	:= ""
			// Abro o Arquivo
			nHdl    := fOpen(cFile)
			// Se foi possível abrir
			If nHdl <> -1
				// Leitura do Arquivo atribuindo o texto do xml a variavel cbuffer
				nTamFile := fSeek(nHdl,0,2)
				If nTamFile > 65535*8
					If !lAutoExec
						MsgAlert("Tamanho do arquivo '" + cFile + "' estourou limite de 524.280 caracteres. Número de Bytes " + cValToChar(nTamFile),ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
					Endif
					cMsgRetMail	+= "Tamanho do arquivo '" + cFile + "' estourou limite de 524.280 caracteres"
				Else
					fSeek(nHdl,0,0)
					cBuffer  := Space(nTamFile)
					nBtLidos := fRead(nHdl,@cBuffer,nTamFile)
					fClose(nHdl)
					// Gravo o Xml nas tabelas
					//If !sfGrvXmlNfe(cBuffer,.F.)
					//	lRetGrv := sfGrvXmlCte(cBuffer,.F.)
					//Endif
					cTextAux	:= cBuffer
					cTextAux	:= Upper(cTextAux)
					cTextAux	:= StrTran(cTextAux, Chr(13)+ Chr(10),"")
					cTextAux	:= StrTran(cTextAux, Chr(10),"")
					
					//cTextAux	:= DecodeUTF8(cTextAux, "iso8859-1")
					cTextDec	:= DecodeUTF8(cBuffer, "iso8859-1")
					If cTextDec == Nil
						cTextDec	:= cBuffer
					Endif
					
					//If (At("<NFEPROC",cTextAux) > 0 .And. (At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0 )) .Or. (At('<UF>EX</UF>',cTextAux) > 0 .And. At('<CNPJ>'+ SM0->M0_CGC+ '</CNPJ>',cTextAux) > 0)
					//Aviso("Entrou para Gravar Xml NFe!",cTextAux,{"Ok"},3)
					If ((At('<UF>EX</UF>',cTextAux) > 0) ).Or.;// .And. At('<CNPJ>'+ SM0->M0_CGC+ '</CNPJ>',cTextAux) > 0 ) .Or. ;
						At("<NFEPROC",cTextAux) > 0 .And. (At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0)  
						Begin Transaction
							lRetGrv := sfGrvXmlNfe(cTextDec,.F.)
						End Transaction
					Endif
					
					// Efetua tentativa de verificar se é CTEOS
					If At("<CTEOS",cTextAux) > 0 .And.(At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0)
						//MsgAlert("Entrou para gravar sfgrvxmlcte "+cText,"154")
						Begin Transaction
							lRetGrv := sfGrvCTEOS(cTextDec,.F.)
						End Transaction
					Endif
					
					
					// Efetua tentativa de verificar se é CTE
					If At("<CTE",cTextAux) > 0 .And.(At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or. At("<CSTAT>100</CSTAT>",cTextAux) > 0)
						//MsgAlert("Entrou para gravar sfgrvxmlcte "+cText,"154")
						Begin Transaction
							lRetGrv := sfGrvXmlCte(cTextDec,.F.)
						End Transaction
					Endif


					// Efetua tentativa de verificar se é CCe
					If At("<DESCEVENTO>CARTA DE CORRECAO</DESCEVENTO>",Upper(cTextAux)) > 0
						//MsgAlert("Entrou para gravar sfgrvxmlcce "+cText,"161")
						Begin Transaction
							lRetGrv := sfGrvCCe(cTextDec,.F.)
						End Transaction
						If !lRetGrv
							cMsgRetMail	+= "Não validou CCe '" + cBuffer +"'"
						Endif
					Endif


					// Efetua tentativa de verificar se é um evento de cancelamento de NFe/Cte
					If !lRetGrv
						If (	At("<CSTAT>101</CSTAT>",cTextAux) > 0 .Or.;
						At("<DESCEVENTO>CANCELAMENTO</DESCEVENTO>",cTextAux) > 0)
							//MsgAlert("Entrou para gravar sfgrvxmlcce "+cText,"161")
							Begin Transaction
								lRetGrv := sfGrvCanc(cTextDec,.F.)
							End Transaction
							If !lRetGrv
								cMsgRetMail	+= "Não validou evento de cancelamento '" + cBuffer +"'"
							Endif
						Endif
					Endif

					If !lRetGrv

						If At("WWW.BETHA.COM.BR",cTextAux) > 0
							Begin Transaction 
								lRetGrv	:= sfReadNFSe(cTextDec)
							End Transaction 
							If !lRetGrv 
								cMsgRetMail	+= "Não validou gravação de NFSe - Betha "
							Endif
						Else
							//MsgAlert(cTextAux)
						Endif
					Endif

				Endif
				If !Empty(cMsgRetMail)
					//Crio a conexão com o server STMP ( Envio de e-mail )
					oServer2 := TMailManager():New()


					// Usa SSL na conexao
					If GetMv("XM_SMTPSSL")
						oServer2:setUseSSL(.T.)
					Endif

					// Usa TLS na conexao
					If GetNewPar("XM_SMTPTLS",.F.)
						oServer2:SetUseTLS(.T.)
					Endif

					oServer2:Init( ""		,Alltrim(GetMv("XM_SMTP")), Alltrim(GetMv("XM_SMTPUSR"))	,Alltrim(GetMv("XM_PSWSMTP")),	0			, GetMv("XM_SMTPPOR") )

					//seto um tempo de time out com servidor de 1min
					If oServer2:SetSmtpTimeOut( GetMv("XM_SMTPTMT") ) != 0
						Conout( "Falha ao setar o time out" )
					EndIf

					//realizo a conexão SMTP
					If oServer2:SmtpConnect() != 0
						Conout( "Falha ao conectar" )
					EndIf

					// Realiza autenticacao no servidor
					If GetMv("XM_SMTPAUT")
						nErr := oServer2:smtpAuth(Alltrim(GetMv("XM_SMTPUSR")), Alltrim(GetMv("XM_PSWSMTP")))
						If nErr <> 0
							ConOut("[ERROR]Falha ao autenticar: " + oServer2:getErrorString(nErr))
							Alert("[ERROR]Falha ao autenticar: " + oServer2:getErrorString(nErr))
							oServer2:smtpDisconnect()
						Endif
					Endif
					//Apos a conexão, crio o objeto da mensagem
					oMessage2 := TMailMessage():New()
					//Limpo o objeto
					//Populo com os dados de envio
					oMessage2:cFrom 		:= GetMv("XM_SMTPDES")
					oMessage2:cTo 			:= GetNewPar("XM_MAILADM","marcelolauschner@gmail.com")//oMessage:cFrom

					oMessage2:cSubject 		:= OemToAnsi("Resposta automática de rejeição do Email")
					//						oMessage2:MsgBodyType( "text" )
					// Efetua tratativa para avisar outros destinatários do email de que o email foi rejeitado
					//cCcEmail	:= StrTran(StrTran(cToAux,Alltrim(GetMv("XM_POPUSR")),""),";;",";")

					//If !Empty(Alltrim(cCcEmail))
					//	oMessage2:cCc 			:= cCcEmail
					//Endif
					If Type("lMadeira") == "L" .And. !lMadeira
						oMessage2:cBcc 		:= "contato@centralxml.com.br"
					Endif
					oMessage2:cSubject 		:= OemToAnsi("Resposta automática de rejeição do Email"  )

					cCorpoM	:= ""
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
					cCorpoM += "<br><br>"
					cCorpoM += AllTrim(OemToAnsi(cMsgRetMail))
					cCorpoM += "<br>"
					cCorpoM += "<br>"
					cCorpoM += "Este email é disparado automaticamente pela rotina Central XML - Favor não Responder."
					cCorpoM += "<br>"
					cCorpoM += "________________________________________________________________________"
					cCorpoM += "<br>"


					cCorpoM += "Powered by Central XML. - " +"Versão : " + GetNewPar("XM_CTRLVRS","Central XML - 4.2017D-10A")
					cCorpoM += "</body> "
					cCorpoM += "</html>"

					oMessage2:MsgBodyType( "text/html" )
					oMessage2:cBody 		:= cCorpoM //OemToAnsi("Email de resposta automática. Não foi possível ler o XML de seu e-mail enviado." + Chr(13)+Chr(10)+cMsgRetMail+ Chr(13)+Chr(10)+cBodyAux + Chr(13)+Chr(10)+"'"+cText+"'")


					//Adiciono um attach
					If oMessage2:AttachFile( cFile) < 0
						Conout( "Erro ao atachar o arquivo" )
						MsgAlert("Não foi possível anexar o arquivo '" + cFile + "'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Erro ao anexar arquivo.")
					Else
						//adiciono uma tag informando que é um attach e o nome do arq
						oMessage2:AddAtthTag( 'Content-Disposition: attachment; filename='+Alltrim(aFiles[nForA][1])+"'")
					EndIf

					//Envio o e-mail
					If oMessage2:Send( oServer2 ) != 0
						Conout( "Erro ao enviar o e-mail" )
					EndIf

					//Disconecto do servidor
					If oServer2:SmtpDisconnect() != 0
						Conout( "Erro ao disconectar do servidor SMTP" )
					EndIf
				Endif
				If GetNewPar("XM_CPYXMLD",.T.)
					__CopyFile(cFile,cDirXmlOld + aFiles[nForA][1])
				Endif
				// Apago o arquivo
				Ferase(cFile)
			Endif
		Endif
	Next nForA

	stControle(.T.)

Return




/*/{Protheus.doc} sfGrvXmlNfe
(Trata o XML para efetuar a gravação de NFE(Mod.55) )

@author MarceloLauschner
@since 07/04/2012
@version 1.0

@param cText, character, (Descrição do parâmetro)
@param lMail, logico, (Descrição do parâmetro)
@param oMessage, objeto, (Descrição do parâmetro)
@param oServer, objeto, (Descrição do parâmetro)

@return logico, se gravou o Xml da NFe

@example
(examples)

@see (links_or_references)
/*/
Static Function sfGrvXmlNfe(cText,lMail,oMessage,oServer)

	Local	cTxtGrv		:= cText
	Local	cVldSch		:= cText
	Local	lRej101		:= .F.
	Local	lRejPrev101	:= .F. 
	Local	cAviso		:= ""
	Local	cErro		:= ""
	Local	cFileGr		:= ""
	Local	lAcept  	:= .F.
	Local 	cNumProt	:= ""
	Local	cParcela	:= " "
	Local   nForA,nForB,nForC,nForD,nForE
	Local	cEncoding	:= "ISO-8859-1"
	Local	oXML 		:= TXMLManager():New()
	Local	oXSD 		:= TXMLManager():New()

	Private oIdent   ,oEmitente,oDestino 
	Private iZ,nX 
	//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - NFe - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| Inicio: "+Time(),59)+"|")

	// 21/07/2017 - Adiciona um texto de tipo de Encode do XML
	If At('<?xml version=',cText) == 0 .And. At('encoding=',cText) == 0
		cText	:= '<?xml version="1.0" encoding="ISO-8859-1"?>'+ cText
	Endif
	
	// Avalia necessita de retirar caracteres
	cVldSch 	:= sfRemoveCrlf(cVldSch,.T.)
	cText		:= sfRemoveCrlf(cText,.T.)


	If !oXML:Read( cText, ,"UTF-8" , 0 )
		oXML:ResetErrors()
		If !oXML:Read( cText, ,"UTF-16" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cText, ,"UTF-16LE" , 0 )
				oXML:ResetErrors()	
				If !oXML:Read( cText, ,"UTF-16BE" , 0 )
					oXML:ResetErrors()
					If !oXML:Read( cText, ,"ISO-8859-1" , 0 )
						oXML:ResetErrors()	
						If !oXML:Read( cText, ,"ASCII" , 0 )
							oXML:ResetErrors()
							If !oXML:Read( cText, ,"US-ASCII" , 0 )
								//MsgAlert( "Warning on Parse " + oXML:Warning()  )
								//MsgAlert( "Error on Parse " + oXML:Error()  )
							Else
								//MsgAlert( "No errors on Parse! - US-ASCII" )
								oXML:ResetErrors()
								cEncoding	:= "US-ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! -ASCII" )
							cEncoding	:= "ASCII"
						Endif
					Else
						//MsgAlert( "No errors on Parse! - ISO-8859-1" )
						cEncoding	:= "ISO-8859-1"		
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16BE" )
					cEncoding	:= "UTF-16BE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16LE" )	
				cEncoding	:= "UTF-16LE"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-16" )
			cEncoding	:= "UTF-16"
		Endif
	Else
		//MsgAlert( "No errors on Parse! - UTF-8" )
		cEncoding	:= "UTF-8"
	Endif
	
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cText	:= StrTran(cText,'encoding="UTF-8"','encoding="'+cEncoding +'"')
	
//	Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	
	// Se o modelo de XML for 65 - NFC-e força a alteração do XML por causa da Tag <infNFeSupl><qrCode>
	If At("<mod>65</mod>",Lower(cText)) > 0
		nPxIniSupl := At("<infnfesupl>",Lower(cText))
		nPxFimSupl := At("</infnfesupl>",Lower(cText))

		//Eliminação - Se a expressão caracter 2 for uma cadeia de caracteres nula (“”), o número de caracteres especificados pela expressão numérica 2 será removido da expressão caracter 1.
		//STUFF( <expressão caracter 1>, <expressão numérica 1> , <expressão numérica 2> , <expressão caracter 2> )
		cText 	:= Stuff(cText,nPxIniSupl,nPxFimSupl-nPxIniSupl+13,"")
		//cRet 	:= StrTran(cRet,"<![CDATA[","") 
		//cRet 	:= StrTran(cRet,"<[CDATA[","") 
		//cRet 	:= StrTran(cRet,"]]>","")

		//cText := oXML:CanonicalC14N( cText, , 0, , 0 )
		If lIsDebug
			//sfDebugXml(oXML)
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
		Endif		
	Endif


	If lIsDebug
		sfDebugXml(oXML)
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	Endif
	// <nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe Id=
	//<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe"><NFe><infNFe Id=
	// Se encontrada apenas a tag <NFe> adiciona Atributo
	// Solução adicionada em 21/03/12 para resolver problema de validação de Schema do Microsiga
	If ( nPosIni := At("<NFe>",cVldSch)) > 0
		//<NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe
		cVldSch := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'+Substr(cVldSch,nPosINi+5)

		// Faz o ajuste do XML também para evitar erro de xml parser
		cTxtGrv := Substr(cTxtGrv,1,nPosIni-1)+cVldSch
		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Schema ajustado - sfGrvXmlNfe 002!",cVldSch,{"Ok"},3)
		Endif
	Endif

	If ( nPosIni := At("<NFe",cVldSch)) > 0
		//<NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe
		cVldSch := Substr(cVldSch,nPosINi)
		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cVldSch,{"Ok"},3)
		Endif
	Endif
	If ( nPosIni := At("</infNFe>",cVldSch)) > 0
		cVldSch := Substr(cVldSch,1,nPosINi+8)
		cVldSch += "</NFe>"
		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cVldSch,{"Ok"},3)
		Endif
	Endif

	If File(cDirSchema+"nfe_v"+NfeIdSPED(cVldSch,"versao")+".xsd")
		If oXSD:Read( cVldSch, ,cEncoding, 0 )
			If !oXSD:ParseSchemaFile( cDirSchema+"nfe_v"+NfeIdSPED(cVldSch,"versao")+".xsd" )
				//MsgAlert("erro ParseSchemaFile ")
			Else
				//	If !oXSD:SchemaValidate()
				//		MsgAlert( "Warning on validschema " + oXSD:Warning()  )
				//		MsgAlert( "Error on validschema " + oXSD:Error()  )
				//	Else
				//MsgAlert("Schema Validado")
				//	Endif
			Endif
		Endif
	Else
		//MsgAlert("no file " + cDirSchema+"nfe_v"+NfeIdSPED(cText,"versao")+".xsd")
	Endif


	cAviso	:= ""
	cErro	:= ""
	oNfe 	:= XmlParser(cText,"_",@cAviso,@cErro)

	If !Empty(cErro)
		cMsgRetMail	+= "Erro de XmlParser - '"+cErro+"' "
		ConOut(Padr("| Erro de XmlParser - '"+cErro+"'",59)+"|")
		ConOut("+"+Replicate("-",58)+"+")
		Return .F.
	Endif

	If !Empty(cAviso)
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
		cText,;//'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)
	Endif
	
	
		
	If Type("oNFe:_NfeProc:_nfeProc:_NFe") == "U" .And.;
	Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc")== "U" .And.;
	Type("oNFe:_InfNfe")== "U" .And.;
	Type("oNFe:_NfeProc:_NFe")== "U" .And.;
	Type("oNFe:_NFe")== "U" .And.;
	Type("oNFe") == "U"
		//( cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName )
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
		cText,;//'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)

		cErro		:= ""
		cAviso		:= ""
		cTxtGrv		:= sfDecodeUtf(cTxtGrv)
		cTxtGrv		:= sfRemoveCrlf(cTxtGrv)

		If At("UTF-8",Upper(cTxtGrv)) > 0
			//cTxtGrv := sfHTMLEnc(cTxtGrv)
		Endif
		cTxtGrv 	:= NoAcento(cTxtGrv)
		cTxtAux   	:= EnCodeUtf8(cTxtGrv)
		If Type("cTxtAux") <> "U"
			cTxtGrv	:= EnCodeUtf8(cTxtGrv)
		Endif
		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"EncodeUtf8",cTxtGrv,{"Ok"},3)
		Endif

		oNfe := XmlParser(cTxtGrv,"_",@cAviso,@cErro)

		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"XmlParser - sfGrvXmlNfe 005!",cTxtGrv,{"Ok"},3)
		Endif

		If !Empty(cErro)
			MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
			cMsgRetMail	+= "Erro XmlParser '"+cErro+"' "
			//StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - "+cErro ,'"'+cTxtGrv+'"')
			ConOut(Padr("| Erro de XmlParser - '"+cErro+"'",59)+"|")
			ConOut("+"+Replicate("-",58)+"+")
			Return .F.
		Endif

		If !Empty(cAviso)

			//Static Function stSendMail( cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName )
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml Aviso: "+ cAviso,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
		Endif

		cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(sfDecodeUtf(cVldSch),.T.)))

		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Schema ajustado - sfGrvXmlNfe 006!",cVldSch,{"Ok"},3)
		Endif
	Endif

	If File(cDirSchema+"nfe_v"+NfeIdSPED(cVldSch,"versao")+".xsd")
		//Aviso("Xml",Alltrim(EnCodeUtf8(NoAcento(sfDecodeUtf(cVldSch)))),{"Xml"},3           )
		//cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(sfDecodeUtf(cVldSch),.T.)))
		cVldSch		:= sfDecodeUtf(cVldSch)
		cVldSch 	:= NoAcento(cVldSch,.T.)
		cTxtAux   	:= EnCodeUtf8(cVldSch)
		If Type("cTxtAux") <> "U"
			cVldSch	:= EnCodeUtf8(cVldSch)
		Endif

		If lIsDebug
			Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cVldSch,{"Ok"},3)
		Endif
		cErro		:= ""
		cAviso		:= ""

		If 	At('<UF>EX</UF>',Upper(cText)) == 0 .And. !XmlSVldSchema( cVldSch, cDirSchema+"nfe_v"+NfeIdSPED(cVldSch,"versao")+".xsd", @cErro, @cAviso )

			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")

			// Adicionada exceção que permite importar XML´s de Sistema de Importação que Gera XML no Layout da NF-e porém sem ser autorizada e nem ter CHAVE
			If At('<UF>EX</UF>',Upper(cText)) == 0
				cNavegado	:= "http://www.sefaz.rs.gov.br/NFE/NFE-VAL.aspx"

				If !lAutoExec
					Aviso("XML com Schema Inválido! Copie o Texto abaixo e cole na próxima tela!",cText,{"Ok"},3)
					//Aviso("XML com Schema Inválido! Copie o Texto abaixo e cole na próxima tela!",cVldSch,{"Ok"},3)

					Define MsDialog oDlgWb1 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
					@ 005,010 Say "Xml" of oDlgWb1 Pixel
					@ 015,010 MsGet oNavegado Var cNavegado Size 300,05 Of oDlgWb1 Pixel
					oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb1 )

					// parametro que permite o aceite de xml fora do schema xsd
					If GetNewPar("XM_VLSCHFC",.T.)
						@ 010, 440 Button oBtnSair PROMPT "Aceitar" Size 40,10 Action(lAcept  := .T.,oDlgWb1:End()) Of oDlgWb1 Pixel
					Endif

					@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb1:End()) Of oDlgWb1 Pixel

					Activate MsDialog oDlgWb1 Centered

					oDlgWb1 := Nil
				Else
					lAcept	:= GetNewPar("XM_VLSCHFC",.T.)
				Endif

				cMsgRetMail	+= "Schema inválido do XML Aviso:'"+cAviso+"' - Erro :'"+cErro+"' "

				If !lAcept
					ConOut(Padr("| Schema inválido - '"+cAviso+"-"+cErro+"'",59)+"|")
					ConOut("+"+Replicate("-",58)+"+")
					Return .F.
				Endif

			Else
				If !lAutoExec
					If At('<UF>EX</UF>',Upper(cText)) > 0
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Nota com UF=Exterior",cText,{"Ok"},3)
					Else
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"XML sem ID da Chave !",cText,{"Ok"},3)
					Endif
				Endif
			Endif
		Else
			//Aviso("XML com Schema Validado!",cText,{"Ok"},3)
		Endif
	Endif


	If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
		oNF	:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_NFe
	ElseIf Type("oNFe:_NfeProc:_NFe") <> "U"
		oNF := oNFe:_NFeProc:_NFe
	ElseIf Type("oNFe:_nfeProc:_NFe") <> "U"
		oNF := oNFe:_nfeProc:_NFe
	ElseIf Type("oNFe:_NFe")<> "U"
		oNF := oNFe:_NFe
	ElseIf Type("oNFe:_InfNfe")<> "U"
		oNF := oNFe
	ElseIf Type("oNFe:_NfeProc:_nfeProc:_NFe") <> "U"
		oNF := oNFe:_nfeProc:_NFeProc:_NFe
	ElseIf Type("oNFe")<> "U"
		oNF := oNFe
	Else
		//MsgAlert("Não foi possível importar email do texto: "+cTxtGrv)
		//StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de oNFe " ,'"'+cTxtGrv+'"')
		cMsgRetMail	+= "Importação XML - Erro de oNFe "
		//Aviso("Erro de oNFe cText",cText,{"Ok"},3)
		//	Aviso("Erro de oNFe cTxtGrv",cTxtGrv,{"Ok"},3)

		ConOut(Padr("| Erro de oNfe - '"+cErro+"'",59)+"|")
		ConOut("+"+Replicate("-",58)+"+")
		Return .F.
	Endif

	If Type("oNF:_InfNFe") == "U"
		ConOut(Padr("| Ausencia de infNFe",59)+"|")
		cMsgRetMail	+= "Ausencia de infNFe "
		ConOut("+"+Replicate("-",58)+"+")
		Return .F.
	Endif

	oIdent     	:= oNF:_InfNfe:_IDE
	oEmitente  	:= oNF:_InfNfe:_Emit
	// Trata exceção de NFCE Mod 65 que não tem tag Destinatário na NFe 4.0
	If Type("oNF:_InfNfe:_Dest") <> "U"
		oDestino   	:= oNF:_InfNfe:_Dest
	Endif 

	// Procura a chave conforme o escopo da formatação do xml
	If Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
		cChave := oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_protNFe:_infProt:_chNFe:TEXT
	ElseIf Type("oNFe:_NfeProc:_protNFe") <> "U"
		cChave := oNFe:_NFeProc:_protNFe:_infProt:_chNFe:TEXT
	ElseIf Type("oNFe:_protNFe")<> "U"
		cChave := oNFe:_protNFe:_infProt:_chNFe:TEXT
	ElseIf Type("oNFe:_NfeProc:_nfeProc:_protNFe") <> "U"
		cChave := oNFe:_nfeProc:_NFeProc:_protNFe:_infProt:_chNFe:TEXT
	ElseIf !Empty( NfeIdSPED(cVldSch,"Id"))
		cChave	:= Substr(NfeIdSPED(cVldSch,"Id"),4,44)
	Else
		cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
	Endif

	ConOut(Padr("| "+cChave,59)+"|")

	cTipoDoc	:= "N"	// Atribuo Default N=Normal

	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter to

	lExistChv := !DbSeek(cChave)

	// Verificou que a chave já existe na base
	If !lExistChv
		// Identificou que a nota fiscal já esta lançada

		U_DbSelArea("CONDORXMLITENS",.F.,1)
		lAuxExistChv := DbSeek(Padr(cChave,Len(CONDORXMLITENS->XIT_CHAVE)) )

		If !Empty(CONDORXML->XML_KEYF1) .And. lAuxExistChv
			cMsgRetMail += "Chave eletrônica '"+cChave+"' já lançada como nota fiscal '"+CONDORXML->XML_KEYF1+"'. Não houve o recebimento do XML"
			ConOut(Padr("Já lançada como nota fiscal '"+CONDORXML->XML_KEYF1+"'. Não houve o recebimento do XML",59)+"|")
			ConOut("+"+Replicate("-",58)+"+")
			Return .T. // 08/01/2018 Alterado retorno para .T. para evitar envio desnecessário de mensagem. 
		Endif
		If !Empty(CONDORXML->XML_CONFCO) .And. lAuxExistChv
			cMsgRetMail += "Chave eletrônica '"+cChave+"' já conferida pelo Compras. Não houve o recebimento do XML"
			ConOut(Padr("Já conferida pelo compras. Não houve o recebimento do XML",59)+"|")
			ConOut("+"+Replicate("-",58)+"+")
			Return .T. // 08/01/2018 Alterado retorno para .T. para evitar envio desnecessário de mensagem. 
		Endif
	Endif

	RecLock("CONDORXML",lExistChv)
	If lMail
		CONDORXML->XML_CFROM 	:= oMessage:cFrom
		CONDORXML->XML_CTO		:= oMessage:cTo
		CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
		CONDORXML->XML_BODY		:= oMessage:cBody
		CONDORXML->XML_NROATT	:= oMessage:GetAttachCount()
	Else
		CONDORXML->XML_CFROM 	:= " "
		CONDORXML->XML_CTO		:= " "
		CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
		CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
		CONDORXML->XML_NROATT	:= 1
	Endif

	CONDORXML->XML_ARQ		:= cText
	CONDORXML->XML_ATT3		:= cTxtGrv

	If Type("oIdent:_tpNf") <> "U"
		CONDORXML->XML_TPNF		:= oIdent:_tpNf:Text // Tipo do Documento Fiscal (0 - entrada; 1 - saída)
	Endif

	// Melhoria em 21/05/2014 para contemplar a leitura do Protocolo de autorização
	// Fornecedores enviam PDF e XML com numero do Protocolo e não da Chave ou Numero da Nota
	cNumProt	:= ""
	If Type("oNFe:_NfeProc:_protNFe:_infProt:_nProt")<> "U"
		cNumProt	:= oNFe:_NfeProc:_protNFe:_infProt:_nProt:TEXT
	ElseIf Type("oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc") <> "U"
		cNumProt	:= oNFe:_NeoGridFiscalDoc:_Messages:_Message:_nfeProc:_protNFe:_infProt:_nProt:TEXT
	Endif

	nPxIniVlrTot	:= AT("</vOutro><vNF>",cText)
	nPxIniVlrTot	+= 14
	nPxFimVlrTot	:= AT("</vNF>",cText)

	If nPxIniVlrTot > 0 .And. nPxFimVlrTot > 0
		nXmlValNf 	:= Val(Substr(cText,nPxIniVlrTot,(nPxFimVlrTot-nPxIniVlrTot)))
		CONDORXML->XML_VLRDOC	:= nXmlValNf
	Endif

	// Se vier a partir de e-mail, permite que o arquivo PDF seja salvo na base também.
	If lMail
		For nForA := 1 To oMessage:getAttachCount()
			aAttInfo:= oMessage:getAttachInfo(nForA)

			// Analisa se há informaçaõd e anexo e se o arquivo anexo é um XML
			// 1 ShortName 		O nome do attachment.
			// 2 Type 				O tipo do anexo, por exemplo, text/plain ou image/x-png.
			// 3 Disposition		Tipo do arquivo.
			// 4 DispositionName	Nome do tipo de arquivo.
			// 5 ID				Identificação do anexo.
			// 6 Location			Local físico do anexo.
			// 7 * Size 			Tamanho do anexo.
			// *Parâmetro Size só estará disponível em versão superior a 7.00.131227A
			cAttInfo	:= aAttInfo[1]
			// Se o ShortName estiver em branco procura pelo DispositionName
			If Empty(cAttInfo)
				cAttInfo	:= aAttInfo[4]
			Endif
			// Se o ShortName e DispositionName estiverem em branco procura pelo Type
			If Empty(cAttInfo)
				cAttInfo	:= SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
			Endif
			If At(".PDF",UPPER(cAttInfo)) > 0 .And. ( At(cChave,UPPER(cAttInfo)) > 0 .Or. At(Trim(oIdent:_nNF:TEXT),UPPER(cAttInfo)) > 0 .Or.(!Empty(cNumProt) .And. At(cNumProt,cAttInfo) > 0 ))
				If Len(oMessage:getAttach(nForA)) < 1048576
					CONDORXML->XML_ATT2		:= oMessage:getAttach(nForA)
				Endif
			Endif
		Next nForA
	Endif

	CONDORXML->XML_CHAVE		:= cChave

	If Type("oDestino:_enderDest:_UF") <> "U" .And. Upper(oDestino:_enderDest:_UF:TEXT) == "EX"// At('<UF>EX</UF>',Upper(cText)) > 0
		CONDORXML->XML_EMIT			:= IIf(Type("oDestino:_CNPJ") <> "U",oDestino:_CNPJ:TEXT,IIf(Type("oDestino:_CPF") <> "U",oDestino:_CPF,""))
		CONDORXML->XML_INSCRI		:= IIf(Type("oDestino:_IE") <> "U",oDestino:_IE:TEXT,"ISENTO")
		CONDORXML->XML_NOMEMT		:= oDestino:_xNome:TEXT   // Nome emitente
		CONDORXML->XML_MUNMT		:= Upper(oDestino:_enderDest:_xMun:TEXT) + "/"+Upper(oDestino:_enderDest:_UF:TEXT) // Municipio Emitente
		CONDORXML->XML_DEST			:= oEmitente:_CNPJ:TEXT
		CONDORXML->XML_NOMEDT		:= oEmitente:_xNome:TEXT  // Nome Destinatario
		CONDORXML->XML_MUNDT		:= oEmitente:_enderEmit:_xMun:TEXT+"/"+oEmitente:_enderEmit:_UF:TEXT  // Municipio Destinatario
		CONDORXML->XML_TPNF 		:= "1"
	Else

		If Type("oEmitente:_CNPJ") <> "U"
			CONDORXML->XML_EMIT			:= oEmitente:_CNPJ:TEXT
		ElseIf Type("oEmitente:_CPF") <> "U"
			CONDORXML->XML_EMIT			:= oEmitente:_CPF:TEXT
		Endif
		CONDORXML->XML_INSCRI		:= IIf(Type("oEmitente:_IE") <> "U",oEmitente:_IE:TEXT,"ISENTO")
		CONDORXML->XML_NOMEMT		:= IIf(Type("oEmitente:_xNome") <> "U",oEmitente:_xNome:TEXT,"SEM IDENT") // Nome emitente
		CONDORXML->XML_MUNMT		:= IIf(Type("oEmitente:_enderEmit") <> "U",oEmitente:_enderEmit:_xMun:TEXT+"/"+oEmitente:_enderEmit:_UF:TEXT,"SEM CIDADE/UF") // Municipio Emitente
		If Type("oDestino:_CNPJ") <> "U"
			CONDORXML->XML_DEST			:= oDestino:_CNPJ:TEXT
		ElseIf Type("oDestino:_CPF") <> "U"
			CONDORXML->XML_DEST			:= oDestino:_CPF:TEXT
		Endif
		If Type("oDestino:_xNome") <> "U"
			CONDORXML->XML_NOMEDT		:= oDestino:_xNome:TEXT  // Nome Destinatario
		Endif
		If Type("oDestino:_enderDest:_xMun") <> "U"
			CONDORXML->XML_MUNDT		:= oDestino:_enderDest:_xMun:TEXT + "/"+oDestino:_enderDest:_UF:TEXT // Municipio Destinatario
		Endif
	Endif

	If cLeftNil $ " #0" 		// 0=Padrão(Soh Num c/zeros)
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "1" 	// 1=Num e Serie
		CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_SERIE")[1])-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Padr(oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
	Endif

	If Type("oIdent:_dhEmi") <> "U"
		// <dhEmi>2014-04-15T12:02:46-03:00
		cData 	:=	Alltrim(Substr(oIdent:_dhEmi:TEXT,1,10))
	Else
		//<dEmi>2014-04-10
		cData	:=	Alltrim(oIdent:_dEmi:TEXT)
	Endif
	cData	:= StrTran(cData,"-","")
	dData	:=	STOD(cData) //CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
	CONDORXML->XML_EMISSA		:= dData

	nPosCompra	:= At("<compra><xPed>",cTxtGrv)
	If nPosCompra > 0
		CONDORXML->XML_PCOMPR	:= Substr(cTxtGrv,nPosCompra+14,6)
	Endif

	CONDORXML->XML_RECEB		:= Date()
	CONDORXML->XML_HORREC		:= Time()
	CONDORXML->XML_USRREC		:= Padr(cUserName,30)



	If !Empty(cChave) .And. lSefMan .And. !lAutoExec

		cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))+cChave

		Define MsDialog oDlgWb2 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
		@ 005,010 Say "Chave da NF-e / Use CTRL+C para copiar, e depois colar na página abaixo" of oDlgWb2 Pixel
		@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgWb2 Pixel
		oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb2 )

		@ 010, 350 Button oBtnPrint PROMPT "Confirmar Consulta" Size 70,10 Action (CONDORXML->XML_CONFER := Date(),CONDORXML->XML_HORCON := Time(),CONDORXML->XML_USRCON := Padr(cUserName,30),oDlgWb2:End()) Of oDlgWb2 Pixel
		@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlgWb2 Pixel
		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb2:End()) Of oDlgWb2 Pixel
		Activate MsDialog oDlgWb2 Centered
	Else
		cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
		// Verifico se a empresa em cursor tem TSS configurado
		cIdentSPED	:= Iif(GetNewPar("XM_TSSEXIS",.T.),StaticCall(SPEDNFE,GetIdEnt)," ")

		If !Empty(cIdentSPED)

			// Trecho para validar autorização da NF
			cMensagem:= ""
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT    	 := cIdentSPED
			ows:cCHVNFE		 := cChave
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

			If At("<mod>65</mod>",cText) > 0
				CONDORXML->XML_CONFER := Date()
				CONDORXML->XML_HORCON := Time()
				CONDORXML->XML_USRCON := Padr("NFC-E Central Xml-"+cUserName,30)
				CONDORXML->XML_DTRVLD := Date()
			ElseIf oWs:ConsultaChaveNFE()
				cMensagem := ""
				If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
					cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
				EndIf
				cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
				cMensagem += "Cod.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
				cMensagem += "Msg.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
				If oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1 .And. !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
				EndIf
				// Nota fiscal Autorizada
				If Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
					CONDORXML->XML_CONFER := Date()
					CONDORXML->XML_HORCON := Time()
					CONDORXML->XML_USRCON := Padr("TSS-Central Xml-"+cUserName,30)
					// Nota fiscal Cancelada - Cancelamento autorizado
				ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
					// Se já existe o registro
					If !lExistChv
						// Se ainda não foi rejeitada a nota
						If Empty(CONDORXML->XML_REJEIT) 
							lRejPrev101	:= .T. 
						Endif
					Endif
					CONDORXML->XML_CONFER 	:= Date()
					CONDORXML->XML_HORCON 	:= Time()
					CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
					CONDORXML->XML_REJEIT	:= Date()
					CONDORXML->XML_USRREJ	:= Padr("TSS-Central Xml-"+cUserName,30)
					
					lRej101	:= .T.
				Else
					//Aviso(STR0107,cMensagem,{"Nota fiscal não Autorizada na SEFAZ"},3)
					If !lAutoExec
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ "Consulta NF",cMensagem+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
					Endif
				Endif
				//	Aviso(STR0107,cMensagem,{STR0114},3)
			Else
				// Adicionada melhoria em 13/09/2016
				// Permite que rejeição 526 - XML emitido há mais de 6 meses seja recebido
				If  "526 Rejeicao:" $ IIf(Empty(GetWscError(3)),"",GetWscError(3))
					CONDORXML->XML_DTRVLD := Date()
					If Empty(CONDORXML->XML_CONFER)
						CONDORXML->XML_CONFER := Date()
						CONDORXML->XML_HORCON := Time()
						CONDORXML->XML_USRCON := Padr("TSS-Central Xml-"+cUserName,30)
					Endif
				Else
					If !lAutoExec
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
					Endif
				Endif
			EndIf
		Else
			If !lAutoExec
				Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
			Endif
		Endif
	Endif

	MsUnlock()

	// 21/05/2016 - Melhoria para gravar vencimentos por XML
	If Type("oNF:_InfNfe:_Cobr") <> "U"
		oCobr		:= oNF:_InfNfe:_Cobr
	Endif

	If Type("oCobr:_dup") <> "U"
		// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
		oDup  		:= oCobr:_dup
		oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
		lOnlyDup	:= Len(oDup) == 1
		cParcela	:= " "
		For nForB := 1 To Len(oDup)
			nP := nForB
			If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
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
		Next nForB
	Endif

	// Se a NF-e foi rejeitada abra a tela de cancelamento para envio de email
	If lRej101 .And. !lRejPrev101
		If !lAutoExec
			If Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Nota fiscal '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{"Enviar EMail","Ok"},3) == 1
				StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,,lRej101)
			Endif
		Else
			StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,lAutoExec,lRej101,"101-Nota fiscal Cancelada - Cancelamento autorizado")
		Endif
	Endif

	oDet       	:= oNF:_InfNfe:_Det

	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)


	IIf(Type("oNFe:_InfNfe:_compra:_xPed")=="U",Nil,cPedCompra := oNF:_InfNfe:_compra:_xPed:TEXT)

	U_DbSelArea("CONDORXMLITENS",.F.,1)
	Set Filter To
	// Inicio loop nos itens da nota
	For nForC := 1 To Len(oDet)
		nX := nForC

		// Verifico se os 3 digitos finais do CFOP estão na lista de CFOPs que identificam a nota como nota de Beneficiamento
		If Substr(oDet[nX]:_Prod:_CFOP:TEXT,2,3) $ cCfopRet 
			cTipoDoc	:= "B"
			// Verifico se os 3 digitos finais do CFOP da nota estão na lista de CFOPs que identifica a nota como de Devolução
		ElseIf Substr(oDet[nX]:_Prod:_CFOP:TEXT,2,3) $ cCfopDev
			cTipoDoc	:= "D"
		Endif

		U_DbSelArea("CONDORXMLITENS",.F.,1)
		lExistChv := !DbSeek(Padr(cChave,Len(CONDORXMLITENS->XIT_CHAVE)) + Padr(oDet[nX]:_Prod:_cProd:TEXT,Len(CONDORXMLITENS->XIT_CODNFE)) + StrZero(nX,4))
		RecLock("CONDORXMLITENS",lExistChv)

		CONDORXMLITENS->XIT_CHAVE		:= cChave
		CONDORXMLITENS->XIT_ITEM		:= StrZero(nX,4)
		CONDORXMLITENS->XIT_CODNFE		:= oDet[nX]:_Prod:_cProd:TEXT
		CONDORXMLITENS->XIT_DESCRI		:= oDet[nX]:_Prod:_xProd:TEXT
		If Type("oDet[nX]:_Prod:_NCM") <> "U"
			CONDORXMLITENS->XIT_NCM			:= oDet[nX]:_Prod:_NCM:TEXT
		Endif
		CONDORXMLITENS->XIT_CFNFE		:= oDet[nX]:_Prod:_CFOP:TEXT
		CONDORXMLITENS->XIT_QTENFE		:= Val(oDet[nX]:_Prod:_qCom:TEXT)
		CONDORXMLITENS->XIT_PRCNFE		:= Val(oDet[nX]:_Prod:_vUnCom:TEXT)
		CONDORXMLITENS->XIT_UMNFE		:= oDet[nX]:_Prod:_uCom:TEXT
		CONDORXMLITENS->XIT_TOTNFE		:= Val(oDet[nX]:_Prod:_vProd:TEXT)


		If Type("oDet[nX]:_Prod:_vDesc")<> "U"
			CONDORXMLITENS->XIT_VALDES  := Val(oDet[nX]:_Prod:_vDesc:TEXT)
		Endif

		If Type("oDet[nX]:_Prod:_vFrete")<> "U"
			CONDORXMLITENS->XIT_VALFRE  := Val(oDet[nX]:_Prod:_vFrete:TEXT)
		Endif

		If Type("oDet[nX]:_Prod:_vOutro")<> "U"
			CONDORXMLITENS->XIT_DESPES  := Val(oDet[nX]:_Prod:_vOutro:TEXT)
		Endif

		If Type("oDet[nX]:_Prod:_vSeg")<> "U"
			CONDORXMLITENS->XIT_SEGURO  := Val(oDet[nX]:_Prod:_vSeg:TEXT)
		Endif

		If Type("oDet[nX]:_Prod:_DI:_nDI")<> "U"
			CONDORXMLITENS->XIT_NDI  	:= oDet[nX]:_Prod:_DI:_nDI:TEXT

			CONDORXMLITENS->XIT_DIDATA	 	:= STOD(StrTran(oDet[nX]:_Prod:_DI:_dDI:TEXT,"-",""))  // Data da DI
			//<dDI>2012-01-23</dDI>

			CONDORXMLITENS->XIT_DILOCD		:= oDet[nX]:_Prod:_DI:_xLocDesemb:TEXT	 // Local do Desembaraçõ
			//<xLocDesemb>INST. PORT. FLUVIAL DE USO PRIV. POLY TERMINAIS PORTUARIO</xLocDesemb>

			CONDORXMLITENS->XIT_DIUFDS		:= oDet[nX]:_Prod:_DI:_UFDesemb:TEXT // UF do Desembaraço
			//<UFDesemb>SC</UFDesemb>

			CONDORXMLITENS->XIT_DIDTDS		:= STOD(StrTran(oDet[nX]:_Prod:_DI:_dDesemb:TEXT,"-",""))// Data do Desembaraço
			//<dDesemb>2012-01-27</dDesemb>
			//<adi><nAdicao>33</nAdicao><nSeqAdic>20</nSeqAdic><cFabricante>Q247700</cFabricante><nDraw/></adi>
			//<DI><nDI>1708881931</nDI><dDI>2017-06-01</dDI><xLocDesemb>PORTO DE SANTOS</xLocDesemb><UFDesemb>SP</UFDesemb><dDesemb>2017-06-01</dDesemb>
			//<tpViaTransp>1</tpViaTransp><vAFRMM>0.00</vAFRMM><tpIntermedio>1</tpIntermedio><cExportador>Q247700</cExportador>
			//<adi><nAdicao>33</nAdicao><nSeqAdic>20</nSeqAdic><cFabricante>Q247700</cFabricante><nDraw/></adi><adi><nAdicao>33</nAdicao><nSeqAdic>21</nSeqAdic><cFabricante>Q247700</cFabricante><nDraw/></adi><adi><nAdicao>33</nAdicao><nSeqAdic>22</nSeqAdic><cFabricante>Q247700</cFabricante><nDraw/></adi>
			oaDI := Iif(Type("oDet[nX]:_Prod:_DI:_adi") <> "U",oDet[nX]:_Prod:_DI:_adi,Nil)
			oaDI := IIf(ValType(oDet)=="O",{oaDI},oaDI)

			//CONDORXMLITENS->XIT_DINADI		:= oDet[nX]:_Prod:_DI:_adi[1]:_nAdicao:TEXT //  Adicao

			If Type("oDet[nX]:_Prod:_DI:_adi:_nAdicao") <> "U"
				//<adi><nAdicao>2</nAdicao>
				CONDORXMLITENS->XIT_DINADI		:= oDet[nX]:_Prod:_DI:_adi:_nAdicao:TEXT //  Adicao
				CONDORXMLITENS->XIT_DISQAD		:= oDet[nX]:_Prod:_DI:_adi:_nSeqAdic:TEXT  // Sequencia da Adiçao
			ElseIf !Empty(oaDi)
				CONDORXMLITENS->XIT_DINADI		:= oaDI[1]:_nAdicao:TEXT //  Adicao
				CONDORXMLITENS->XIT_DISQAD		:= oaDI[1]:_nSeqAdic:TEXT  // Sequencia da Adiçao*/
			Endif


			//CONDORXMLITENS->XIT_DISQAD		:= oDet[nX]:_Prod:_DI:_adi[1]:_nSeqAdic:TEXT  // Sequencia da Adiçao
			//<nSeqAdic>1</nSeqAdic>

		Endif

		// Já carrega os dados do XML - Melhoria em 11/02/2014
		If Type("oDet[nX]:_Prod:_xPed") <> "U" .And. GetNewPar("XM_XSC7TAG",.T.)
			CONDORXMLITENS->XIT_PEDIDO			:= oDet[nX]:_Prod:_xPed:TEXT
		Endif
		If Type("oDet[nX]:_Prod:_nItemPed") <> "U" .And. GetNewPar("XM_XSC7TAG",.T.)
			CONDORXMLITENS->XIT_ITEMPC			:= oDet[nX]:_Prod:_nItemPed:TEXT
		Endif

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("D1_FCICOD")
			If Type("oDet[nX]:_Prod:_nFCI") <> "U"
				CONDORXMLITENS->XIT_FCICOD			:= oDet[nX]:_Prod:_nFCI:TEXT
			Endif
		Endif

		//# ID Campo Descrição Ele Pai Tipo Ocor. Tam. Observação
		// 152 K01  med Detalhamento de Medicamentos e de matérias-primas farmacêuticas     CG I90  1-500 Informar apenas quando se tratar de medicamentos ou de matérias-primas farmacêuticas, permite ocorrências.
		// 153 K02  nLote Número do Lote de medicamentos ou de matérias-primas farmacêuticas E K01 C 1-1 1-20
		// 154 K03 qLote Quantidade de produto no Lote de medicamentos ou de matérias-primas farmacêuticas E K01 N 1-1 8v3
		// 155 K04 dFab Data de fabricação E K01 D 1-1 Formato “AAAA-MM-DD”
		// 156 K05 dVal Data de validade E K01 D 1-1 Formato “AAAA-MM-DD”
		// 157 K06 vPMC Preço máximo consumidor E K01 N 1-1 13v2


		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("D1_LOTECTL")
			If Type("oDet[nX]:_Prod:_med:_nLote") <> "U"
				CONDORXMLITENS->XIT_LOTCTL			:= Padr(oDet[nX]:_Prod:_med:_nLote:TEXT,SX3->X3_TAMANHO)
			Endif
		Endif

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("D1_NUMLOTE")
			If Type("oDet[nX]:_Prod:_med:_dFab") <> "U"
				CONDORXMLITENS->XIT_NUMLOT			:= StrTran(oDet[nX]:_Prod:_med:_dFab:TEXT,"-","")
			Endif
		Endif

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("D1_LOTEFOR")
			If Type("oDet[nX]:_Prod:_med:_nLote") <> "U"
				CONDORXMLITENS->XIT_LOTFOR			:= oDet[nX]:_Prod:_med:_nLote:TEXT
			Endif
		Endif

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("D1_DTVALID")
			If Type("oDet[nX]:_Prod:_med:_dVal") <> "U"
				CONDORXMLITENS->XIT_DTVALD			:= STOD(StrTran(oDet[nX]:_Prod:_med:_dVal:TEXT,"-",""))
			Endif
		Endif

		// Tag Nova de Rastro		
		If Type("oDet[nX]:_prod:_rastro") <> "U"
			oRastro := Iif(Type("oDet[nX]:_prod:_rastro") <> "U",oDet[nX]:_Prod:_rastro,Nil)
			oRastro := IIf(ValType(oRastro)=="O",{oRastro},oRastro)
			
			For nForE := 1 To Len(oRastro)
				iZ	:= nForE
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek("D1_LOTECTL")
					If Type("oRastro[iZ]:_nLote") <> "U"
						CONDORXMLITENS->XIT_LOTCTL			:= Padr(oRastro[iZ]:_nLote:TEXT,SX3->X3_TAMANHO)
					Endif
				Endif
		
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek("D1_DFABRIC")
					If Type("oRastro[iZ]:_dFab") <> "U"
						CONDORXMLITENS->XIT_DFABRI			:= STOD(StrTran(oRastro[iZ]:_dFab:TEXT,"-",""))
					Endif
				Endif
		
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek("D1_LOTEFOR")
					If Type("oRastro[iZ]:_nLote") <> "U"
						CONDORXMLITENS->XIT_LOTFOR			:= Padr(oRastro[iZ]:_nLote:TEXT,SX3->X3_TAMANHO)
					Endif
				Endif
		
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek("D1_DTVALID")
					If Type("oRastro[iZ]:_dVal") <> "U"
						CONDORXMLITENS->XIT_DTVALD			:= STOD(StrTran(oRastro[iZ]:_dVal:TEXT,"-",""))
					Endif
				Endif
			Next
		Endif
		
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("A5_CODBAR")
			If Type("oDet[nX]:_Prod:_cEAN") <> "U"
				CONDORXMLITENS->XIT_CODBAR			:= oDet[nX]:_Prod:_cEAN:TEXT
			Endif
		Endif

		Do Case
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS00
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS10
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS20
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS30
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS40
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS51
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS60
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS70
			Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
			oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS90
		EndCase

		//	Efetua verificação pelas Tags do Simples Nacional
		If Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN101") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN101
		ElseIf Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN102") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN102
		ElseIf Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN201") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN201
		ElseIf Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN202") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN202
		ElseIf Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN500") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN500
		ElseIf Type("oDet[nX]:_Imposto:_ICMS:_ICMSSN900") <> "U"
			oICM	:= oDet[nX]:_Imposto:_ICMS:_ICMSSN900
		Endif

		If Type("oICM")<> "U"
			If Type("oICM:_vBC") <> "U"
				CONDORXMLITENS->XIT_BASICM		:= Val(oICM:_vBC:TEXT)
			Endif
			If Type("oICM:_pICMS") <> "U" .And. Val(oICM:_pICMS:TEXT) < 100
				CONDORXMLITENS->XIT_PICM		:= Val(oICM:_pICMS:TEXT)
			Endif
			If Type("oICM:_vICMS") <> "U"
				CONDORXMLITENS->XIT_VALICM		:= Val(oICM:_vICMS:TEXT)
			Endif
			If Type("oICM:_vBCST") <> "U"
				CONDORXMLITENS->XIT_BASRET		:= Val(oICM:_vBCST:TEXT)
			Endif
			If Type("oICM:_vBCSTRet") <> "U"
				CONDORXMLITENS->XIT_BRETAN		:= Val(oICM:_vBCSTRet:TEXT)
			Endif

			If Type("oICM:_pMVAST") <> "U"
				CONDORXMLITENS->XIT_PMVA		:= Val(oICM:_pMVAST:TEXT)
			Endif
			If Type("oICM:_pICMSST") <> "U"
				CONDORXMLITENS->XIT_PICMST		:= Val(oICM:_pICMSST:TEXT)
			Endif
			If Type("oICM:_vICMSST") <> "U"
				CONDORXMLITENS->XIT_VALRET		:= Val(oICM:_vICMSST:TEXT)
			Endif

			If Type("oICM:_vICMSSTRet") <> "U"
				CONDORXMLITENS->XIT_VRETAN		:= Val(oICM:_vICMSSTRet:TEXT)
			Endif

			If Type("oICM:_orig") <> "U" .And. Type("oICM:_CST") <> "U"
				CONDORXMLITENS->XIT_CLASFI		:= Padr(Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT),TamSX3("D1_CLASFIS")[1])
				CONDORXMLITENS->XIT_CSTORI		:= Padr(Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT),TamSX3("D1_CLASFIS")[1])
			Endif
			If Type("oICM:_orig") <> "U" .And. Type("oICM:_CSOSN") <> "U"
				//CONDORXMLITENS->XIT_CLASFI		:= Padr(Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CSOSN:TEXT),TamSX3("D1_CLASFIS")[1])
				CONDORXMLITENS->XIT_CSTORI		:= Alltrim(oICM:_orig:TEXT) + Alltrim(oICM:_CSOSN:TEXT)
			Endif


			If Type("oICM:_pCredSN") <> "U"
				CONDORXMLITENS->XIT_PICMSN		:= Val(oICM:_pCredSN:TEXT)
			Endif
			If Type("oICM:_vCredICMSSN") <> "U"
				CONDORXMLITENS->XIT_CICMSN		:= Val(oICM:_vCredICMSSN:TEXT)
			Endif
		Endif

		// Efetua a gravação dos dados referente ao IPI
		If Type("oDet[nX]:_Imposto:_IPI:_IPITRIB")<> "U"
			oIPI := oDet[nx]:_Imposto:_IPI:_IPITRIB
			CONDORXMLITENS->XIT_BASIPI		:= Iif(Type("oIPI:_vBC")<>"U",Val(oIPI:_vBC:TEXT),0)
			nPerIPI		:= Iif(Type("oIPI:_pIPI")<>"U",Val(oIPI:_pIPI:TEXT),0)
			If nPerIPI > 99.99
				//MsgAlert("IPI inválido encontrado e valor zerado!")
				nPerIPI 	:= 0
			Endif
			CONDORXMLITENS->XIT_PIPI		:= nPerIPI
			CONDORXMLITENS->XIT_VALIPI		:= Iif(Type("oIPI:_vIPI")<>"U",Val(oIPI:_vIPI:TEXT),0)
		Endif

		// Efetua a gravação dos dados referente ao PIS
		If Type("oDet[nX]:_Imposto:_PIS:_PISAliq")<> "U" .And. Val(oDet[nX]:_Imposto:_PIS:_PISAliq:_pPIS:TEXT) < 100
			oPIS:=oDet[nX]:_Imposto:_PIS:_PISAliq
			CONDORXMLITENS->XIT_BASPIS		:= Val(oPIS:_vBC:TEXT)
			CONDORXMLITENS->XIT_PPIS		:= Val(oPIS:_pPIS:TEXT)
			CONDORXMLITENS->XIT_VALPIS		:= Val(oPIS:_vPIS:TEXT)
		Endif

		// Efetua a gravação dos dados referente ao COFINS
		If Type("oDet[nX]:_Imposto:_COFINS:_COFINSAliq")<> "U" .And. Val(oDet[nX]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:TEXT) < 100
			oPIS:=oDet[nX]:_Imposto:_COFINS:_COFINSAliq
			CONDORXMLITENS->XIT_BASCOF		:= Val(oPIS:_vBC:TEXT)
			CONDORXMLITENS->XIT_PCOF		:= Val(oPIS:_pCOFINS:TEXT)
			CONDORXMLITENS->XIT_VALCOF		:= Val(oPIS:_vCOFINS:TEXT)
		Endif

		If Type("oDet[nX]:_Imposto:_PIS:_PISOutr")<> "U" .And. Type("oDet[nX]:_Imposto:_PIS:_PISOutr:_pPIS") <> "U" .And. Val(oDet[nX]:_Imposto:_PIS:_PISOutr:_pPIS:TEXT) < 100
			oPIS:=oDet[nX]:_Imposto:_PIS:_PISOutr
			CONDORXMLITENS->XIT_BASPIS		:= Val(oPIS:_vBC:TEXT)
			CONDORXMLITENS->XIT_PPIS		:= Val(oPIS:_pPIS:TEXT)
			CONDORXMLITENS->XIT_VALPIS		:= Val(oPIS:_vPIS:TEXT)
		Endif

		// Efetua a gravação dos dados referente ao COFINS
		If Type("oDet[nX]:_Imposto:_COFINS:_COFINSOutr")<> "U" .And. Type("oDet[nX]:_Imposto:_COFINS:_COFINSOutr:_pCOFINS") <> "U" .And. Val(oDet[nX]:_Imposto:_COFINS:_COFINSOutr:_pCOFINS:TEXT) < 100
			oPIS:=oDet[nX]:_Imposto:_COFINS:_COFINSOutr
			CONDORXMLITENS->XIT_BASCOF		:= Val(oPIS:_vBC:TEXT)
			CONDORXMLITENS->XIT_PCOF		:= Val(oPIS:_pCOFINS:TEXT)
			CONDORXMLITENS->XIT_VALCOF		:= Val(oPIS:_vCOFINS:TEXT)
		Endif

		// Efetua a gravação dos dados referente ao II
		If Type("oDet[nX]:_Imposto:_II")<> "U"
			oII	:=oDet[nX]:_Imposto:_II
			CONDORXMLITENS->XIT_DIBCIM		:= Val(oII:_vBC:TEXT)
			CONDORXMLITENS->XIT_DIBSPD		:= Val(oII:_vDespAdu:TEXT)
			CONDORXMLITENS->XIT_DIVLII		:= Val(oII:_vII:TEXT)
			CONDORXMLITENS->XIT_DIVLOF		:= Val(oII:_vIOF:TEXT)
		Endif

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("B1_CEST")
			If Type("oDet[nX]:_Prod:_CEST") <> "U"
				CONDORXMLITENS->XIT_CEST			:= oDet[nX]:_Prod:_CEST:TEXT
			Endif
		Endif

		MsUnlock()
	Next nForC

	// Gravo o tipo de Nota
	U_DbSelArea("CONDORXML",.F.,1)
	RecLock("CONDORXML",.F.)
	If At("<mod>65</mod>",cText) > 0
		CONDORXML->XML_TIPODC	:= "E" // NFC-e Cupom fiscal  
	Else
		CONDORXML->XML_TIPODC	:= Iif(CONDORXML->XML_TPNF	== "0" , "N" ,cTipoDoc)
	Endif
	MsUnlock()

	If !(cTipoDoc $ "T#F")
		U_DbSelArea("CONDORXMLITENS",.F.,1)
		lAuxExistChv := DbSeek(Padr(cChave,Len(CONDORXMLITENS->XIT_CHAVE)) )
		If !lAuxExistChv
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Erro ao gravar itens de Nota",cChave)
		Endif
	Endif
	ConOut(Padr("| Fim: "+Time(),59)+"|")
	ConOut("+"+Replicate("-",58)+"+")


Return .T.


/*/{Protheus.doc} stControle
(Efetua o bloqueio/desbloqueio do parametro que controla o recebimento de emails para ser rotina mono-usuária )

@author Marcelo Lauschner
@since 07/04/2012
@version 1.0

@param lLibera, logico, Se libera ou bloqueia processo de recebimento de xmls

@return logico, Se conseguiu bloquear acesso

@example
(examples)

@see (links_or_references)
/*/
Static Function stControle(lLibera)

	Local	nTentativas	:= 0
	//	Local	cXmlBlqpop	:= GetMv("XM_BLQPOP")
	//	Local	aXmlBlqPop	:= StrTokArr(cXmlBlqPop,";")
	Default lLibera 	:= .F.
	/*
	If !Empty(cXmlBlqpop) .And. !lLibera
	If Len(aXmlBlqPop) < 3
	aXmlBlqPop	:= {"","",""}
	Endif
	cXmlBlqPop := "Rotina bloqueada pelo usuário(a) "+ aXmlBlqPop[1] + " desde " + aXmlBlqPop[2] + " " + aXmlBlqPop[3] +". Caso haja algum erro solicite que o CPD limpe o paramêtro XM_BLQPOP"

	If !lAutoExec
	// 07/02/2016 - Verifica se o bloqueio de parametro aconteceu há 1 dia ou mais e permite se deixa fazer o recebimento de XMLs
	If CTOD(aXmlBlqPop[2]) < Date()
	Return .T.
	Endif
	MsgAlert(cXmlBlqPop)
	Return .F.
	Else
	// 07/02/2016 - Verifica se o bloqueio de parametro aconteceu há 1 dia ou mais e permite se deixa fazer o recebimento de XMLs
	If CTOD(aXmlBlqPop[2]) < Date()
	Return .T.
	Endif
	StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Rotina bloqueada XM_BLQPOP  "+ cEmpAnt + "/" + SM0->M0_NOME,cXmlBlqPop)
	Return .F.
	Endif

	ElseIf lLibera
	PutMv("XM_BLQPOP"," ")
	Else
	PutMv("XM_BLQPOP",Alltrim(cUserName)+";" + DTOC(Date())+ ";" +Time()+";")
	Endif
	*/


	If !lLibera
		While !LockByName("MYEMAIL",.F.,.F.,.T.)
			If lAutoExec
				Sleep(2000)
			Else
				MsAguarde({|| Sleep(1000) }, "Semaforo de processamento... tentativa "+ALLTRIM(STR(nTentativas)), "Aguarde, rotina sendo executada por outro usuário.")//"Semaforo de processamento... tentativa "##"Aguarde, arquivo sendo alterado por outro usuário."
			Endif
			nTentativas++

			If nTentativas > 5
				If lAutoExec
					Return (.F.)
				Else
					If PswAdmin( , ,RetCodUsr()) == 0 .Or. __cUserId $ GetNewPar("XM_USRLBWZ","000000")
						If !MsgYesNo("Não foi possível acesso exclusivo para o recebimento de e-mails.Deseja tentar novamente ?") //"Não foi possível acesso exclusivo para edição do Pré-Projeto da proposta. Deseja tentar novamente ?"
							Return(.F.)
						Else
							Return .T.
						EndIf
					Else
						If MsgYesNo("Não foi possível acesso exclusivo para o recebimento de e-mails.Deseja tentar novamente ?") //"Não foi possível acesso exclusivo para edição do Pré-Projeto da proposta. Deseja tentar novamente ?"
							nTentativas := 0
							Loop
						Else
							Return(.F.)
						EndIf
					Endif
				Endif
			EndIf
		EndDo
	Else
		UnLockByName("MYEMAIL",.F.,.F.,.T.)
	Endif

Return .T.



/*/{Protheus.doc} sfRemoveCrlf
(long_description)

@author MarceloLauschner
@since 04/03/2014
@version 1.0

@param cInXml, character, XML a ser reconstruido

@return character , Xml refeito sem as quebras de linha

@example
(examples)

@see (links_or_references)
/*/
Static Function sfRemoveCrlf(cInXml,lVldSchema)

	Local		cRet		:= ""
	Local		aXml		:= {}
	Local		ix
	Local		nCnt77		:= 0
	Local		nCnt75 		:= 0
	Local		nCnt74		:= 0
	Local		cVArAux		:= ""
	Local		nTamXml		:= 0 
	Local		cError		:= ""
	Local		cWarning	:= ""
	Default		lVldSchema	:= .F. 
	//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cInXml,{"Ok"},3)
	If lIsDebug
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cInXml,{"Ok"},3)
	Endif
	// 22/08/2017 - Corrige informação errada vindo de XMLs 
	//<infAdProd><[CDATA[<OC: 71096/>]]></infAdProd>
	//<infAdProd><[CDATA[<OC: 116131/>< FCI:3DE1CE21-9F05-4C25-8D46-9E5C093792FA/>]]></infAdProd>
	//cRet 	:= StrTran(cRet,"<[CDATA[<","") 
	//cRet 	:= StrTran(cRet,"/>]]>","") 
	//cRet 	:= StrTran(cRet,"/>]]>","")
	
	If "CDATA[" $ cInXml
		//cInXml := XmlC14N( cInXml, "", @cError , @cWarning  )
		cInXml 	:= StrTran(cInXml,"<[CDATA[<","") 
		cInXml 	:= StrTran(cInXml,"/>]]>","") 
		cInXml 	:= StrTran(cInXml,"<![CDATA[","")
		cInXml 	:= StrTran(cInXml,"]]>","")	
	Endif

	If lIsDebug	
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cInXml,{"Ok"},3)
	Endif
	aXml	:=	StrTokArr(cInXml,Chr(13))

	// Verifico primeiro para ver se o texto está formato com quebras de linhas forçadas
	For iX := 1 To Len(aXml)
		If Len(aXml[iX]) == 77
			nCnt77++
		Endif
		If Len(aXml[iX]) == 75
			nCnt75++
		Endif
		If Len(aXml[iX]) == 74
			nCnt74++
		Endif
	Next

	For iX := 1 To Len(aXml)
		If lVldSchema
			cRet += Alltrim(StrTran(aXml[iX],Chr(10),''))
		Else
			cRet += StrTran(aXml[iX],Chr(10),'')
		Endif
		// Se a quebra de linha for com menos de 77 colunas, adiciona um espaço no texto
		If (Len(aXml[iX]) < 77 .And. Len(StrTran(aXml[iX],Chr(10),'')) > 0 ) .And. nCnt77 > 15
			cRet += ' '
			// Se a quebra de linhas for com menos de 75 de colunas adiciona um espaço no texto
		ElseIf (Len(aXml[iX]) < 75) .And. Len(StrTran(aXml[iX],Chr(10),'')) > 0  .And. nCnt75 > 15 .And. nCnt77 == 0
			cRet += ' '
		ElseIf (Len(aXml[iX]) < 74) .And. Len(StrTran(aXml[iX],Chr(10),'')) > 0  .And. nCnt74 > 15 .And. nCnt77 == 0 .And. nCnt75 == 0
			cRet += ' '
		Endif

	Next
	// 19/03/2017 - Se não houve o ajuste forçado por quebra de linha com 77 caracteres, verifica se há outras quebras de linha
	If nCnt77 == 0 .And. nCnt75 == 0 .And. nCnt74 == 0
		cRet	:= ""
		aXml	:=	StrTokArr(cInXml,Chr(13))

		For iX := 1 To Len(aXml)
			cVarAux	:= aXml[iX] //!
			cVarAux := StrTran(cVarAux,"!",'') // Substitui sinal exclamação inserido no arquivo
			cVarAux := StrTran(cVarAux,Chr(13)+" ",'')		// Remove CRLF e espaço
			cVarAux := StrTran(cVarAux,Chr(10)+" ",'')		// Remove CRLF e espaço

			If Substr(cVArAux,1,1) == " "					// Se a linha tiver um espaço no começo, remove pois resultou de uma formatação errada.
				cRet += Substr(cVarAux,2)
			Else
				cRet += cVarAux
			Endif
		Next
	Endif

	// Caso não tenha havido nenhuma quebra de linha, retorna informação original.
	If Empty(cRet)
		cRet := cInXml
	Endif
	// 17/12/2014 - Melhoria a pedido da Concretomix para corrigir falha de xmls com espaço nas tags
	cRet	:= StrTran(cRet,"</ ","</")
	cRet	:= StrTran(cRet,"</Re ference>","</Reference>")
	cRet	:= StrTran(cRet,">< veicTransp","><veicTransp")
	cRet	:= StrTran(cRet,"<Dige stValue>","<DigestValue>")
	cRet	:= StrTran(cRet,">5 3<",">53<")
	cRet   	:= StrTran(cRet," & "," &amp; ")
	cRet  	:= StrTran(cRet,"T&A","T&amp;A")
	cRet	:= StrTran(cRet, Chr(195) + Chr(152),"0")
	cRet	:= StrTran(cRet, Chr(216) , "0" )
	cRet	:= StrTran(cRet, "?<?xml","<?xml")
	cRet	:= StrTran(cRet,"infModalversaoModal","infModal versaoModal")
	// 15/06/2017 - Corrige uma falha de arquivo XMLs enviados por um fornecedor TRANSMENDES TRANSPORTES RODOVIARIOS LTDA ME
	cRet	:= StrTran(cRet,"</xNome><UF/><tpProp>0</tpProp>","</xNome><tpProp>0</tpProp>")
	// 19/07/2017 - Corrige leitura de Tag não convertida

	// 25/07/2017
	cRet	:= StrTran(cRet,"</det><detnItem=","</det><det nItem=")

	// 10/08/2017 
	cRet	:= StrTran(cRet,"<vICMS>0>","")
	
	//01/03/2018
	cRet	:= StrTran(cRet,'xCampo="Lei da TransparC*ncia','xCampo="Lei da Transparencia')	
	// Adiciona uma tag de fechamento
	If At("</nfeProc",cRet) > 0 .And. At("</nfeProc>",cRet) == 0
		cRet += ">"
	Endif
	
	// 11/04/2018  
	// Adiciona uma tag de fechamento
	If At("</nfePro",cRet) > 0 .And. At("</nfeProc>",cRet) == 0
		cRet += "c>"
	Endif
	// Adiciona uma tag de fechamento
	If At("</cteProc",cRet) > 0 .And. At("</cteProc>",cRet) == 0
		cRet += ">"
	Endif
	// Adiciona uma tag de fechamento
	If At("</ctePro",cRet) > 0 .And. At("</cteProc>",cRet) == 0
		cRet += "c>"
	Endif
	
	// 23/05/2018 - Adiciona uma tag de fechamento
	If At("<procEventoNFe",cRet) > 0 .And. At("</procEventoNFe",cRet) > 0 .And. At("</procEventoNFe>",cRet) == 0
		cRet := Alltrim(cRet) + ">"
	Endif
	
	// 03/05/2018 - Adiciona uma tag de fechamento
	If At("<procEventoNFe",cRet) > 0 .And. At("</procEventoNFe>",cRet) == 0
		cRet := Alltrim(cRet) + "e>"
	Endif
	// 06/07/2018 - Adiciona uma tag de Fechamento
	If At("<procEventoCTe",cRet) > 0 .And. At("</procEventoCTe>",cRet) == 0
		cRet := Alltrim(cRet) + ">"
	Endif
	
	// 02/09/2017 - Corrige formato do XML para evitar Aviso do Xmlparser
	cRet	:= StrTran(cRet,"version='1.0'",'version="1.0"')
	cRet	:= StrTran(cRet,"encoding='UTF-8'",'encoding="UTF-8"')


	cRet	:= StrTran(cRet, Chr(13)+ Chr(10),"")
	cRet	:= StrTran(cRet, Chr(10),"")

	cRet	:= StrTran(cRet, "_"," ")
	cRet 	:= StrTran(cRet,"ï»¿","")
	If lIsDebug
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cRet,{"Ok"},3)
	Endif

Return cRet


/*/{Protheus.doc} NoAcento
(Remove vogais acentuadas Função copiada do NfeSefaz )
@author MarceloLauschner
@since 01/12/2011
@version 1.0
@param cString, character, (Descrição do parâmetro)
@param lVldSch, ${param_type}, (Descrição do parâmetro)
@return cBuffer, Texto formatado
@example
(examples)
@see (links_or_references)
/*/
Static Function NoAcento(cString,lVldSch)
	Local 		cChar  		:= ""
	Local 		nX     		:= 0
	Local 		nY     		:= 0
	Local 		cVogal 		:= "aeiouAEIOU"
	Local 		cAgudo 		:= "áéíóú"+"ÁÉÍÓÚ"
	Local 		cCircu 		:= "âêîôû"+"ÂÊÎÔÛ"
	Local 		cTrema 		:= "äëïöü"+"ÄËÏÖÜ"
	Local 		cCrase 		:= "àèìòù"+"ÀÈÌÒÙ"
	Local 		cTio   		:= "ãõÃÕ"
	Local 		cCecid 		:= "çÇ"
	Local		cOutros		:= "ºª"
	Local 		cCrlf	 	:= Chr(13)
	Local 		cRet		:= Chr(10)
	Local 		cBuffer		:= cString
	Default		lVldSch		:= .F.

	For nX:= 1 To Len(cString)
		cChar := SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cCrlf +cRet
			nY:= At(cChar,cAgudo)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTio)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr("aoAO",nY,1))
			EndIf
			nY:= At(cChar,cCecid)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,SubStr("cC",nY,1))
			EndIf
			nY:= At(cChar,cCrlf)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,"")
			EndIf
			nY:= At(cChar,cRet)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar,"")
			EndIf
			nY:= At(cChar,cOutros)
			If nY > 0
				cBuffer := StrTran(cBuffer,cChar," ")
			EndIf
		
		Endif

	Next
	/*If lVldSch
	For nX:=1 To Len(cBuffer)
	cChar := SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
	cString:=StrTran(cString,cChar,"")
	Endif
	Next nX
	Endif*/
	//If lIsDebug
	//	Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cBuffer,{"Ok"},3)
	//Endif

Return cBuffer


/*/{Protheus.doc} sfHTMLEnc
(Converte UTF8 para ASCII)
@type function
@author marce
@since 07/07/2012
@version 1.0
@param xString, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfHTMLEnc(xString)

	Local cBuffer := xString

	Do Case
		Case ValType(xString)=="C"

		cBuffer := Strtran(cBuffer, "&amp;","&" )
		cBuffer := Strtran(cBuffer, "&quot;",'"')
		cBuffer := Strtran(cBuffer, "&lt;","<")
		cBuffer := Strtran(cBuffer, "&gt;",">")

		//A maiúsculo com acento agudo	Á	&Aacute;
		//E maiúsculo com acento agudo	É	&Eacute;
		//I maiúsculo com acento agudo	Í	&Iacute;
		//O maiúsculo com acento agudo	Ó	&Oacute;
		//U maiúsculo com acento agudo	Ú	&Uacute;
		//A minúsculo com acento agudo	á	&aacute;
		//E minúsculo com acento agudo	é	&eacute;
		//I minúsculo com acento agudo	í	&iacute;
		//O minúsculo com acento agudo	ó	&oacute;
		//U minúsculo com acento agudo	ú	&uacute;
		//A maiúsculo com acento circunflexo	Â	&Acirc;
		//E maiúsculo com acento circunflexo	Ê	&Ecirc;
		//O maiúsculo com acento circunflexo	Ô	&Ocirc;
		//A minúsculo com acento circunflexo	â	&acirc;
		//E minúsculo com acento circunflexo	ê	&ecirc;
		//O minúsculo com acento circunflexo	ô	&ocirc;
		//A maiúsculo com crase	À	&Agrave;
		//A minúsculo com crase	à	&agrave;
		//U maiúsculo com trema	Ü	&Uuml;
		//U minúsculo com trema	ü	&uuml;
		//C cedilha maiúsculo	Ç	&Ccedil;
		//C cedilha minúsculo	ç	&ccedil;
		//A com til maiúsculo	Ã	&Atilde;
		//O com til maiúsculo	Õ	&Otilde;
		//A com til minúsculo	ã	&atilde;
		//O com til minúsculo	õ	&otilde;
		//N com til maiúsculo	Ñ	&Ntilde;
		//N com til minúsculo	ñ	&ntilde;
		//E comercial	&	&amp;
		//Aspa dupla	"	&quot;
		//Aspa simples	'	&#039;
		//Menor que	<	&lt;
		//Maior que	>	&gt;

		Case ValType(xString)=="N"
		cBuffer := Str(xString)
	EndCase

	If lIsDebug
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" sfHTMLEnc",cBuffer,{"Ok"},3)
	Endif

Return cBuffer


/*/{Protheus.doc} sfDecodeUtf
(Remover acentuação UTF-8 e manter formatação como o Windows interpreta o visual do XML)
@author MarceloLauschner
@since 26/04/2014
@version 1.0
@param xString, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfDecodeUtf(xString,lInverte)

	Local	cBuffer		:= ""  //Ã‰ Ã€ Ãü Ãë Ãç
	Local	aAcento		:= {"á" , "à", "â", "ã", "ä", "é", "è", "ê", "ë", "í", "ì", "î", "ï", "ó", "ò", "ô", "õ", "ö", "ú", "ù", "û", "ü", "ç","Á", "À", "Â", "Ã", "Ä", "É", "È", "Ê", "Ë" , "Í" ,"Í"			, "Ì" , "Î","Ï" ,"Ó", "Ò" , "Ô", "Õ", "Ö","Ú" ,"Ù" ,"Û", "Ü" ,"Ç"          , "Ç" ,"Á" ,"É" ,"Ç"	 ,"Á"				,"Ã"  ,"Õ" ,"Á"  ," "	}
	Local	aUtf8 		:= {"Ã¡","Ã ","Ã¢","Ã£","Ã¤","Ã©","Ã¨","Ãª","Ã«","Ã­","Ã¬","Ã®","Ã¯","Ã³","Ã²","Ã´","Ãµ","Ã¶","Ãº","Ã¹","Ã»","Ã¼","Ã§","Ã?","Ã€","Ã‚","Ãƒ","Ã„","Ã‰","Ãˆ","ÃŠ","Ã‹","Ã?" ,"Ã"+chr(141), "ÃŒ","ÃŽ","Ã?","Ã“","Ã’","Ã”","Ã•","Ã–","Ãš","Ã™","Ã›","Ãœ","Ç"+Chr(135) , "Ã‡","Ãü","Ãë","Ãç" ,"Ã"+chr(129)+"S"  ,"Ãâ", "Ãò","Ãü",""	}
	Local	iC,iU
	Local	lExistUtf8	:= .F.
	Default	lInverte	:= .F. 

	Aadd(aAcento,"É" )
	Aadd(aUtf8  ,"Ã‰")
	
	Aadd(aAcento,"º")
	Aadd(aUtf8	,"Âº")
	
	Aadd(aAcento,"Á")
	Aadd(aUtf8  ,"Ã" + Chr(129))

	Aadd(aAcento,"É")
	Aadd(aUtf8  ,"Â"+Chr(144))
	//0xA0 0x20 0x4b 0x4D

	Do Case
		Case ValType(xString) == "C"
		For iC := 1 To Len(xString)
			lExistUtf8		:= .F.
			For iU := 1 To Len(aAcento)
				If Substr(xString,iC,2) == aUtf8[iU]
					cBuffer	+= aAcento[iU]
					lExistUtf8		:= .T.
					iC++ // Acrescenta 1 ao contador por que são 2 caracteres substituidos
				Endif
			Next
			If !lExistUtf8
				cBuffer	+= Substr(xString,iC,1)
			Endif
		Next
		Case ValType(xString) == "N"
		cBuffer	:= Str(xString)
	EndCase
	If lIsDebug
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cBuffer,{"Ok"},3)
	Endif

Return cBuffer

/*/{Protheus.doc} sfGrvXmlCte
(Efetua a gravação dos dados do XML para CTE-Mod.57 )
@author MarceloLauschner
@since 07/04/2012
@version 1.0
@param cText, character, (Descrição do parâmetro)
@param lMail, ${param_type}, (Descrição do parâmetro)
@param oMessage, objeto, (Descrição do parâmetro)
@param oServer, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfGrvXmlCte(cText,lMail,oMessage,oServer)

	Local	cTxtGrv			:= cText
	Local	cVldSch			:= cText
	Local	lRej101			:= .F.
	Local	lRejPrev101		:= .F. 
	Local	cErro			:= ""
	Local	cAviso			:= ""
	Local	lAcept  		:= .F.
	Local	uY
	Local	nForA,nForB,nForC
	Local	lExistMalote
	Local	lExistParc		:= .F.
	Local	cParcela		:= " "
	Local	lOnlyDup		:= .F.
	Local	cEncoding	:= "UTF-8"

	Local	oXML := TXMLManager():New()
	
	// Avalia necessita de retirar caracteres
	cVldSch 	:= sfRemoveCrlf(cVldSch,.T.)
	cText		:= sfRemoveCrlf(cText,.T.)
	
	If !oXML:Read( cText, ,"UTF-8" , 0 )
		oXML:ResetErrors()
		If !oXML:Read( cText, ,"UTF-16" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cText, ,"UTF-16LE" , 0 )
				oXML:ResetErrors()	
				If !oXML:Read( cText, ,"UTF-16BE" , 0 )
					oXML:ResetErrors()
					If !oXML:Read( cText, ,"ISO-8859-1" , 0 )
						oXML:ResetErrors()	
						If !oXML:Read( cText, ,"ASCII" , 0 )
							oXML:ResetErrors()
							If !oXML:Read( cText, ,"US-ASCII" , 0 )
								//MsgAlert( "Warning on Parse " + oXML:Warning()  )
								//MsgAlert( "Error on Parse " + oXML:Error()  )
							Else
								//MsgAlert( "No errors on Parse! - US-ASCII" )
								oXML:ResetErrors()
								cEncoding	:= "US-ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! -ASCII" )
							cEncoding	:= "ASCII"
						Endif
					Else
						//MsgAlert( "No errors on Parse! - ISO-8859-1" )
						cEncoding	:= "ISO-8859-1"		
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16BE" )
					cEncoding	:= "UTF-16BE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16LE" )	
				cEncoding	:= "UTF-16LE"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-16" )
			cEncoding	:= "UTF-16"
		Endif
	Else
		//MsgAlert( "No errors on Parse! - UTF-8" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cText	:= StrTran(cText,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	If lIsDebug
		sfDebugXml(oXML)
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	Endif

	If At("<mod>57</mod>",cText) > 0
		// Se encontrada apenas a tag <CTe> adiciona Atributo
		// Solução adicionada em 22/11/2012 para resolver problema de validação de Schema do Microsiga
		If ( nPosIni := At("<CTe>",cVldSch)) > 0
			cVldSch := '<CTe xmlns="http://www.portalfiscal.inf.br/cte">'+Substr(cVldSch,nPosINi+5)
		Endif
	
	
		If ( nPosIni := At("<CTe",cVldSch)) > 0
			cVldSch := Substr(cVldSch,nPosINi)
		Endif
		If ( nPosIni := At("</infCte>",cVldSch)) > 0
			cVldSch := Substr(cVldSch,1,nPosINi+8)
			cVldSch += "</CTe>"
		Endif
		// Marcelo Lauschner - 25/05/2012 para permitir que XML com a tag Isento para IE passem na validação
		If (nPosIni := At("<IE>ISENTO</IE>",cVldSch)) > 0
			cVldSch := StrTran(cVldSch,"<IE>ISENTO</IE>","<IE></IE>")
		Endif
	Endif

	cAviso	:= ""
	cErro	:= ""

	//StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml" ,'"'+cTxtGrv+'"')

	oNfe := XmlParser(cText,"_",@cAviso,@cErro)

	If !Empty(cErro)
		//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
		cMsgRetMail	+= "Erro de XmlParser '"+cErro+"' "
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml - Erro: " + cErro ,;
		cTextGrv,;
		.F.,;
		cArqAttAch,;
		cAttachName)
		//stSendMail( cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName )
		Return .F.
	Endif


	If !Empty(cAviso) //.Or. At("UTF-8",Upper(cTxtGrv)) == 0
		//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")

		//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml "+IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,'"'+cTxtGrv+'"')
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)

		cErro	:= ""
		cAviso	:= ""
		cTxtGrv	:= sfDecodeUtf(cTxtGrv)
		If At("UTF-8",Upper(cTxtGrv)) > 0
			//cTxtGrv := sfHTMLEnc(cTxtGrv)
		Endif
		cTxtGrv 	:= NoAcento(cTxtGrv)
		cTxtAux   	:= EnCodeUtf8(cTxtGrv)
		If Type("cTxtAux") <> "U"
			cTxtGrv	:= EnCodeUtf8(cTxtGrv)
		Endif
		//cTxtGrv	:= StrTran(cTxtGrv,"&"," ")
		//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", cTxtGrv,{"Ok"},3)
		oNfe := XmlParser(cTxtGrv,"_",@cAviso,@cErro)
		//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", cTxtGrv,{"Ok"},3)

		If !Empty(cErro)
			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
			//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - "+cErro ,'"'+cTxtGrv+'"')
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml erro: " + cErro,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			Return .F.
		Endif

		If !Empty(cAviso)
			//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")
			//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml "+ cAviso ,'"'+cTxtGrv+'"')
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			//	Return .F.
		Endif
		cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(sfDecodeUtf(cVldSch),.T.)))
	Endif

	If File(cDirSchema+"cte_v"+NfeIdSPED(cVldSch,"versao")+".xsd")
		//Aviso("Xml",cVldSch,{"Xml"},3           )
		cVldSch		:= sfDecodeUtf(cVldSch)
		cVldSch 	:= NoAcento(cVldSch,.T.)
		cTxtAux   	:= EnCodeUtf8(cVldSch)
		If Type("cTxtAux") <> "U"
			cVldSch	:= EnCodeUtf8(cVldSch)
		Endif

		cAviso	:= ""
		cErro	:= ""
		If !XmlSVldSchema( cVldSch, cDirSchema+"cte_v"+NfeIdSPED(cVldSch,"versao")+".xsd", @cErro, @cAviso )

			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")

			cNavegado	:= "http://www.sefaz.rs.gov.br/cte/cte-VAL.aspx"
			If !lAutoExec
				If !Empty(cAviso) .Or. !Empty(cErro)
					Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", "Aviso:'"+cAviso+"' - Erro:'"+cErro+"'",{"Ok"},3)
				Endif
				Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" XML com Schema Inválido! Copie o Texto abaixo e cole na próxima tela!",cText,{"Ok"},3)

				Define MsDialog oDlgWb3 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
				@ 005,010 Say "Xml" of oDlgWb3 Pixel
				@ 015,010 MsGet oNavegado Var cNavegado Size 300,05 Of oDlgWb3 Pixel
				oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb3 )

				If GetNewPar("XM_VLSCHFC",.T.)
					@ 010, 440 Button oBtnSair PROMPT "Aceitar" Size 40,10 Action(lAcept  := .T.,oDlgWb3:End()) Of oDlgWb3 Pixel
				Endif

				@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb3:End()) Of oDlgWb3 Pixel

				Activate MsDialog oDlgWb3 Centered

				oDlgWb3 := Nil
			Else
				If GetNewPar("XM_VLSCHFC",.T.)
					lAcept := .T.
				Endif
			Endif

			cMsgRetMail	+= "Schema inválido do XML Aviso:'"+cAviso+"' - Erro :'"+cErro+"' "

			If !lAcept
				Return .F.
			Endif
		Else
			//Aviso("XML com Schema Validado!",cText,{"Ok"},3)
		Endif
	Endif


	If Type("oNFe:_CTeProc")<> "U"
		oNF := oNFe:_CTeProc:_CTe
	ElseIf Type("oNFe:_CTe")<> "U"
		oNF := oNFe:_CTe
	ElseIf Type("oNFe:_enviCTe:_CTe")<> "U"
		oNF := oNFe:_enviCTe:_CTe
	ElseIf Type("oNFe:_cteProc")<> "U"
		oNF := oNFe:_cteProc:_CTe
	ElseIf Type("oNFe:_procCTe:_CTe") <> "U"
		oNF	:= oNFe:_procCTe:_CTe
	Else
		//MsgAlert("Não foi possível importar email do texto: "+cTxtGrv)
		cMsgRetMail	+= "XML não possui Tag CTe "
		//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de oCTe " ,'"'+cTxtGrv+'"')
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml - Erro de oCTe ",;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)
		Return .F.
	Endif

	ConOut(Type("oNF:_InfCTe:_emit"))
	ConOut(oNF:_InfCTe:_emit)
	
	oIdent     	:= oNF:_InfCTe:_ide
	//oComple	:= oNF:_InfCTe:_compl // Não tem uso durante o recebimento
	oEmitente  	:= oNF:_InfCTe:_emit
	oRemetente	:= Iif(Type("oNF:_InfCTe:_rem") <> "U",oNF:_InfCTe:_rem,Nil)
	oExpedidor  := Iif(Type("oNF:_InfCTe:_exped") <> "U",oNF:_InfCTe:_exped,Nil)
	oDestino   	:= Iif(Type("oNF:_InfCTe:_Dest") <> "U",oNF:_InfCTe:_Dest,Nil)
	oValorPrest := oNF:_InfCTe:_vPrest
	oImposto	:= oNF:_InfCTe:_imp
	oInfCte		:= Iif(Type("oNF:_InfCTe:_infCTeNorm") <> "U",oNF:_InfCTe:_infCTeNorm,Nil)

	If Type("oNFe:_CTeProc:_protCTe:_infProt:_chCTe")<> "U"
		cChave	:= oNFe:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
	ElseIf Type("oNFe:_enviCTe:_protCTe:_infProt:_chCTe")<> "U"
		cChave	:= oNFe:_enviCTe:_protCTe:_infProt:_chCTe:TEXT
	ElseIf Type("oNFe:_procCTe:_protCTe:_infProt:_chCTE") <> "U"
		cChave := oNFe:_procCTe:_protCTe:_infProt:_chCTE:TEXT
	Else
		cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	Endif

	cTipoDoc	:= "T"	// Atribuo T=CT-e
	// Localizo Objetos das notas referenciadas
	oDetNfs 		:= Iif(Type("oRemetente:_infNf")<> "U",oRemetente:_infNf,IIf(Type("oRemetente:_infNfe") <> "U",oRemetente:_infNfe,{}))
	oDetNfs 		:= IIf(ValType(oDetNfs)=="O",{oDetNfs},oDetNfs)
	// Melhoria feita em 25/05/2014 para atender CTe 2.00
	If Empty(oDetNfs) .And. Type("oInfCte:_infDoc:_infNFe") <> "U"
		oDetNfs	:= oInfCte:_infDoc:_infNFe
		oDetNfs	:= IIf(ValType(oDetNfs)=="O",{oDetNfs},oDetNfs)
	Endif

	lExistMalote	:= .F.
	For nForB := 1 To Len(oDetNfs)
		xU := nForB
		// Procuro a referencia com as notas de saida do Sistema
		If Type("oDetNfs[xU]:_nCFOP") <> "U"
			If oDetNfs[xU]:_nCFOP:TEXT=="6359"
				lExistMalote := .T.
			Endif
		Endif

		If Type("oDetNfs[xU]:_chave") <> "U"
			//SF2->F2_CHVNFE == oDet[xU]:_chave:TEXT
		Endif
	Next

	// Tratativa especifica para ler CTe que informa Produto predominante como DOCUMENTOS
	// e outras categorias como ENVELOPE
	// Atende necessidade especifica da Athletic Way - 20/06/2014
	If Type("oInfCte:_infCarga:_proPred") <> "U" .And. Type("oInfCte:_infCarga:_xOutCat") <> "U"
		If "DOCUMENTO" $ Upper(oInfCte:_infCarga:_proPred:TEXT) .And. ;
		Upper(oInfCte:_infCarga:_xOutCat:TEXT) $ "ENVELOPE#MALOTE"
			lExistMalote	:= .T.
		Endif
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter to

	lExistChv := !DbSeek(cChave)
	// Verificou que a chave j[a existe na base
	If !lExistChv
		// Identificou que a nota fiscal já esta lancada
		If !Empty(CONDORXML->XML_KEYF1)
			cMsgRetMail += "Chave eletrönica '"+cChave+"' jã lançada como nota fiscal '"+CONDORXML->XML_KEYF1+"'. Não houve o recebimento do XML"
			Return .F.
		Endif
	Endif

	RecLock("CONDORXML",lExistChv)
	CONDORXML->XML_CHAVE		:= cChave
	If lMail
		CONDORXML->XML_CFROM 	:= oMessage:cFrom
		CONDORXML->XML_CTO		:= oMessage:cTo
		CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
		CONDORXML->XML_BODY		:= oMessage:cBody
		CONDORXML->XML_NROATT	:= oMessage:GetAttachCount()
	Else
		CONDORXML->XML_CFROM 	:= " "
		CONDORXML->XML_CTO		:= " "
		CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
		CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
		CONDORXML->XML_NROATT	:= 1
	Endif

	CONDORXML->XML_ARQ		:= cText
	CONDORXML->XML_ATT3		:= cTxtGrv

	If Type("oIdent:_tpCTe") <> "U"
		CONDORXML->XML_TPNF		:= oIdent:_tpCTe:Text // 0 - CT-e Normal;  1 - CT-e de Complemento de Valores;	2 - CT-e de Anulação;  3 - CT-e Substituto
	Endif

	// Melhoria em 21/05/2014 para contemplar a leitura do Protocolo de autorização
	// Fornecedores enviam PDF e XML com numero do Protocolo e não da Chave ou Numero da Nota
	nPxIniVlrTot	:= At("<vPrest><vTPrest>",CONDORXML->XML_ARQ)
	nPxIniVlrTot	+= 17
	nPxFimVlrTot	:= At("</vTPrest>",CONDORXML->XML_ARQ)

	If nPxIniVlrTot > 0 .And. nPxFimVlrTot > 0
		nXmlValNf 	:= Val(Substr(cText,nPxIniVlrTot,(nPxFimVlrTot-nPxIniVlrTot)))
		CONDORXML->XML_VLRDOC	:= nXmlValNf
	Endif


	// Se vier a partir de e-mail, permite que o arquivo PDF seja salvo na base também.

	If lMail
		For nForA := 1 To oMessage:getAttachCount()
			aAttInfo:= oMessage:getAttachInfo(nForA)
			// Analisa se há informaçaõd e anexo e se o arquivo anexo é um XML
			// 1 ShortName 			O nome do attachment.
			// 2 Type 				O tipo do anexo, por exemplo, text/plain ou image/x-png.
			// 3 Disposition		Tipo do arquivo.
			// 4 DispositionName	Nome do tipo de arquivo.
			// 5 ID					Identificação do anexo.
			// 6 Location			Local físico do anexo.
			// 7 * Size 			Tamanho do anexo.
			// *Parâmetro Size só estará disponível em versão superior a 7.00.131227A
			cAttInfo	:= aAttInfo[1]
			If Empty(cAttInfo)
				cAttInfo	:= SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
			Endif
			If At(".PDF",UPPER(cAttInfo)) > 0
				If Len(oMessage:getAttach(nForA)) < 1048576
					CONDORXML->XML_ATT2		:= oMessage:getAttach(nForA)
				Endif
			Endif

		Next
	Endif

	

	If Type("oEmitente:_CNPJ") <> "U"
		CONDORXML->XML_EMIT			:= oEmitente:_CNPJ:TEXT
	ElseIf Type("oEmitente:_CPF") <> "U"
		CONDORXML->XML_EMIT			:= oEmitente:_CPF:TEXT
	Endif
	CONDORXML->XML_INSCRI		:= IIf(Type("oEmitente:_IE") <> "U",oEmitente:_IE:TEXT,"ISENTO")

	CONDORXML->XML_NOMEMT		:= oEmitente:_xNome:TEXT // Nome emitente
	CONDORXML->XML_MUNMT		:= oEmitente:_enderEmit:_xMun:TEXT+"/"+oEmitente:_enderEmit:_UF:TEXT // Municipio Emitente

	// Avalia quem é o tomador do Servico
	If (Type("oIdent:_toma03:_toma") <> "U" .And. oIdent:_toma03:_toma:TEXT $ "0") .Or. ;
	(Type("oIdent:_toma3:_toma") <> "U" .And. oIdent:_toma3:_toma:TEXT $ "0")

		If Type("oRemetente:_CNPJ") <> "U"
			CONDORXML->XML_DEST			:= oRemetente:_CNPJ:TEXT
		ElseIf Type("oRemetente:_CPF") <> "U"
			CONDORXML->XML_DEST			:= oRemetente:_CPF:TEXT
		Endif
		If Type("oRemetente:_xNome") <> "U"
			CONDORXML->XML_NOMEDT		:= oRemetente:_xNome:TEXT  // Nome Remetente
			CONDORXML->XML_MUNDT		:= oRemetente:_enderReme:_xMun:TEXT + "/"+oRemetente:_enderReme:_UF:TEXT // Municipio Remetente
		Endif

	ElseIf (Type("oIdent:_toma03:_toma") <> "U" .And. oIdent:_toma03:_toma:TEXT $ "1") .Or.;
	(Type("oIdent:_toma3:_toma") <> "U" .And. oIdent:_toma3:_toma:TEXT $ "1")
		If Type("oExpedidor:_CNPJ") <> "U"
			CONDORXML->XML_DEST			:= oExpedidor:_CNPJ:TEXT
		ElseIf Type("oExpedidor:_CPF") <> "U"
			CONDORXML->XML_DEST			:= oExpedidor:_CPF:TEXT
		Endif
		CONDORXML->XML_NOMEDT			:= oExpedidor:_xNome:TEXT  // Nome Remetente
		CONDORXML->XML_MUNDT				:= oExpedidor:_enderExped:_xMun:TEXT + "/"+oExpedidor:_enderExped:_UF:TEXT // Municipio Remetente
	ElseIf (Type("oIdent:_toma03:_toma") <> "U".And. oIdent:_toma03:_toma:TEXT $ "2#3") .Or.;
	(Type("oIdent:_toma3:_toma") <> "U".And. oIdent:_toma3:_toma:TEXT $ "2#3")
		If Type("oDestino:_CNPJ") <> "U"
			CONDORXML->XML_DEST			:= oDestino:_CNPJ:TEXT
		ElseIf Type("oDestino:_CPF") <> "U"
			CONDORXML->XML_DEST			:= oDestino:_CPF:TEXT
		Endif
		If Type("oDestino:_xNome") <> "U"
			CONDORXML->XML_NOMEDT		:= oDestino:_xNome:TEXT  // Nome Destinatário
			CONDORXML->XML_MUNDT		:= oDestino:_enderDest:_xMun:TEXT + "/"+oDestino:_enderDest:_UF:TEXT // Municipio Destino
		Endif
		// Entendo que o Frete é por conta do destinatário FOB -
		cTipoDoc	:= "F"	// Atribuo T=CT-e

		// Melhoria em 06/03/2013 - Avalia se o Remetente é o Emitente sendo que o devedor é destinatário
		If Type("oEmitente:_CNPJ") <> "U" .And. Type("oRemetente:_CNPJ") <> "U"
			If oEmitente:_CNPJ:TEXT == oRemetente:_CNPJ:TEXT
				cTipoDoc := "T"
			Endif
		Endif
		// Se houver a incidência de CFOP que se caracteriza como Malote ou Envelope irá atribuir o CTE como CIF forçado
		// 06/09/2015 - Se for Madeiramadeira, irá atribuir todo CTE como CTEFOB = S
		If lExistMalote .Or. lMadeira
			cTipoDoc 				:= "T"
			CONDORXML->XML_CTEFOB 	:= "S"
		Endif
	ElseIf Type ("oIdent:_toma4:_toma") <> "U"

		If Type("oIdent:_toma4:_CNPJ") <> "U"
			CONDORXML->XML_DEST			:= oIdent:_toma4:_CNPJ:TEXT
		ElseIf Type("oIdent:_toma4:_CPF") <> "U"
			CONDORXML->XML_DEST			:= oIdent:_toma4:_CPF:TEXT
		Endif
		CONDORXML->XML_NOMEDT		:= oIdent:_toma4:_xNome:TEXT  // Nome Remetente
		CONDORXML->XML_MUNDT		:= oIdent:_toma4:_enderToma:_xMun:TEXT + "/"+ oIdent:_toma4:_enderToma:_UF:TEXT // oDestino:_enderDest:_UF:TEXT // Municipio Destino

		If Type("oDestino:_CNPJ") <> "U"
			If Alltrim(CONDORXML->XML_DEST) == Alltrim(oDestino:_CNPJ:TEXT)
				// Prevendo a descontinuidade da Tag forPag
				// Forma de pagamento do serviço *** TAG OBSOLETA - Será retirada em versão futura
				If Type("oIdent:_forPag") <> "U"
					If oIdent:_forPag:TEXT == "0"
						cTipoDoc	:= "T"	// Frete pago - por conta do remetente
					ElseIf oIdent:_forPag:TEXT == "1"
						cTipoDoc	:= "F"	// Frete FOB - por conta do destinatário
					Endif
				Else
					cTipoDoc	:= "T"	// Frete pago - por conta do remetente
				Endif
			Endif

		ElseIf Type("oDestino:_CPF") <> "U"
			If Alltrim(	CONDORXML->XML_DEST) == Alltrim(oDestino:_CPF:TEXT)
				// Prevendo a descontinuidade da Tag forPag
				// Forma de pagamento do serviço *** TAG OBSOLETA - Será retirada em versão futura
				If Type("oIdent:_forPag") <> "U"
					If oIdent:_forPag:TEXT == "0"
						cTipoDoc	:= "T"	// Frete pago - por conta do remetente
					ElseIf oIdent:_forPag:TEXT == "1"
						cTipoDoc	:= "F"	// Frete FOB - por conta do destinatário
					Endif
				Else
					cTipoDoc	:= "T"	// Frete pago - por conta do remetente
				Endif
			Endif
		Endif
	Endif

	If cLeftNil $ " #0" 	// 0=Padrão(Soh Num c/zeros)
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "1" 	// 1=Num e Serie
		CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_SERIE")[1])-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Padr(oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	Endif

	cData:=Alltrim(oIdent:_dhEmi:TEXT)
	dData:=CTOD(Substr(cData,9,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
	CONDORXML->XML_EMISSA		:= dData

	CONDORXML->XML_RECEB		:= Date()
	CONDORXML->XML_HORREC		:= Time()
	CONDORXML->XML_USRREC		:= Padr(cUserName,30)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - CTe - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| "+cChave,59)+"|")
	ConOut(Padr("| Variável lSefMan   = "+IIf(lSefMan,".T.",".F."),59)+"|")
	ConOut(Padr("| Variável lAutoExec = "+IIf(lAutoExec,".T.",".F."),59)+"|")
	ConOut("+"+Replicate("-",58)+"+")

	If !Empty(cChave) .And. lSefMan .And. !lAutoExec
		cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))+cChave

		Define MsDialog oDlgWb4 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
		@ 005,010 Say "Página de validação do CT-e" of oDlgWb4 Pixel
		@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgWb4 Pixel
		oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb4 )

		@ 010, 350 Button oBtnPrint PROMPT "Confirmar Consulta" Size 70,10 Action (CONDORXML->XML_CONFER := Date(),CONDORXML->XML_HORCON := Time(),CONDORXML->XML_USRCON := Padr(cUserName,30),oDlgWb4:End()) Of oDlgWb4 Pixel
		@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlgWb4 Pixel
		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb4:End()) Of oDlgWb4 Pixel
		Activate MsDialog oDlgWb4 Centered
	Else
		cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		// Verifico se a empresa em cursor tem TSS configurado
		cIdentSPED	:= Iif(GetNewPar("XM_TSSEXIS",.T.),StaticCall(SPEDNFE,GetIdEnt)," ")
		If !Empty(cIdentSPED)
			// Trecho para validar autorização da NF
			cMensagem:= ""
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT    := StaticCall(SPEDNFE,GetIdEnt)
			ows:cCHVNFE		 := cChave
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

			If oWs:ConsultaChaveNFE()
				cMensagem := ""
				If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
					cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
				EndIf
				cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
				cMensagem += "Cod.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
				cMensagem += "Msg.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
				If oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1 .And. !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
				EndIf
				// Nota fiscal Autorizada
				If Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
					CONDORXML->XML_CONFER 	:= Date()
					CONDORXML->XML_HORCON 	:= Time()
					CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
				// Nota fiscal não encontrada na base Sefaz 
				ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "217"
					//CONDORXML->XML_CONFER 	:= Date()
					//CONDORXML->XML_HORCON 	:= Time()
					//CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
				ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
					// Se já existe o registro
					If !lExistChv
						// Se ainda não foi rejeitada a nota
						If Empty(CONDORXML->XML_REJEIT) 
							lRejPrev101	:= .T. 
						Endif
					Endif
					
					CONDORXML->XML_CONFER 	:= Date()
					CONDORXML->XML_HORCON 	:= Time()
					CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
					CONDORXML->XML_REJEIT	:= Date()
					CONDORXML->XML_USRREJ	:= Padr("TSS-Central Xml-"+cUserName,30)
					lRej101	:= .T.
				Else
					//Aviso(STR0107,cMensagem,{"Nota fiscal não Autorizada na SEFAZ"},3)
					If !lAutoExec
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Consulta NF",cMensagem+Chr(13)+Chr(10)+"Conhecimento Eletrônico '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
					Endif
				Endif
				//	Aviso(STR0107,cMensagem,{STR0114},3)
			Else
				If !lAutoExec
					Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				Endif
			EndIf
		Endif
	Endif
	CONDORXML->XML_TIPODC	:= cTipoDoc

	MsUnlock()

	// 21/05/2016 - Melhoria para gravar vencimentos por XML
	If Type("oInfCte:_cobr") <> "U"
		oCobr		:= oInfCte:_cobr
	Endif

	If Type("oCobr:_dup") <> "U"
		// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
		oDup  		:= oCobr:_dup
		oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
		lOnlyDup	:= Len(oDup) == 1
		cParcela	:= " "
		For nForC := 1 To Len(oDup)
			nP := nForC
			If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
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

	// Se a NF-e foi rejeitada abra a tela de cancelamento para envio de email
	If lRej101 .And. !lRejPrev101
		If !lAutoExec
			If Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Conhecimento Eletrônico '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{"Enviar EMail","Ok"},3) == 1
				StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,,lRej101)
			Endif
		Else
			StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,lAutoExec,lRej101,"101-Conhecimento Eletronico Cancelado - Cancelamento autorizado")
		Endif
	Endif


Return .T.


Static Function sfGrvCTEOS(cText,lMail,oMessage,oServer)

	Local	cTxtGrv			:= cText
	Local	cVldSch			:= cText
	Local	lRej101			:= .F.
	Local	lRejPrev101		:= .F. 
	Local	cErro			:= ""
	Local	cAviso			:= ""
	Local	lAcept  		:= .F.
	Local	uY
	Local	nForA,nForB,nForC
	Local	lExistMalote
	Local	lExistParc		:= .F.
	Local	cParcela		:= " "
	Local	lOnlyDup		:= .F.
	Local	cEncoding	:= "UTF-8"

	Local	oXML := TXMLManager():New()
	// Avalia necessita de retirar caracteres
	cVldSch 	:= sfRemoveCrlf(cVldSch,.T.)
	cText		:= sfRemoveCrlf(cText,.T.)
	
	If !oXML:Read( cText, ,"UTF-8" , 0 )
		oXML:ResetErrors()
		If !oXML:Read( cText, ,"UTF-16" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cText, ,"UTF-16LE" , 0 )
				oXML:ResetErrors()	
				If !oXML:Read( cText, ,"UTF-16BE" , 0 )
					oXML:ResetErrors()
					If !oXML:Read( cText, ,"ISO-8859-1" , 0 )
						oXML:ResetErrors()	
						If !oXML:Read( cText, ,"ASCII" , 0 )
							oXML:ResetErrors()
							If !oXML:Read( cText, ,"US-ASCII" , 0 )
								//MsgAlert( "Warning on Parse " + oXML:Warning()  )
								//MsgAlert( "Error on Parse " + oXML:Error()  )
							Else
								//MsgAlert( "No errors on Parse! - US-ASCII" )
								oXML:ResetErrors()
								cEncoding	:= "US-ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! -ASCII" )
							cEncoding	:= "ASCII"
						Endif
					Else
						//MsgAlert( "No errors on Parse! - ISO-8859-1" )
						cEncoding	:= "ISO-8859-1"		
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16BE" )
					cEncoding	:= "UTF-16BE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16LE" )	
				cEncoding	:= "UTF-16LE"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-16" )
			cEncoding	:= "UTF-16"
		Endif
	Else
		//MsgAlert( "No errors on Parse! - UTF-8" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cText	:= StrTran(cText,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	If lIsDebug
		sfDebugXml(oXML)
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	Endif

	If At("<mod>67</mod>",cText) > 0
		// Se encontrada apenas a tag <CTe> adiciona Atributo
		// Solução adicionada em 22/11/2012 para resolver problema de validação de Schema do Microsiga
		If ( nPosIni := At("<CTeOS>",cVldSch)) > 0
			cVldSch := '<CTeOS xmlns="http://www.portalfiscal.inf.br/cte">'+Substr(cVldSch,nPosINi+5)
		Endif
	
	
		If ( nPosIni := At("<CTeOS",cVldSch)) > 0
			cVldSch := Substr(cVldSch,nPosINi)
		Endif
		If ( nPosIni := At("</infCte>",cVldSch)) > 0
			cVldSch := Substr(cVldSch,1,nPosINi+8)
			cVldSch += "</CTeOS>"
		Endif
		// Marcelo Lauschner - 25/05/2012 para permitir que XML com a tag Isento para IE passem na validação
		If (nPosIni := At("<IE>ISENTO</IE>",cVldSch)) > 0
			cVldSch := StrTran(cVldSch,"<IE>ISENTO</IE>","<IE></IE>")
		Endif
	Endif

	cAviso	:= ""
	cErro	:= ""

	//StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml" ,'"'+cTxtGrv+'"')

	oNfe := XmlParser(cText,"_",@cAviso,@cErro)

	If !Empty(cErro)
		//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
		cMsgRetMail	+= "Erro de XmlParser '"+cErro+"' "
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml - Erro: " + cErro ,;
		cTextGrv,;
		.F.,;
		cArqAttAch,;
		cAttachName)
		//stSendMail( cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName )
		Return .F.
	Endif


	If !Empty(cAviso) //.Or. At("UTF-8",Upper(cTxtGrv)) == 0
		//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")

		//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml "+IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,'"'+cTxtGrv+'"')
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)

		cErro	:= ""
		cAviso	:= ""
		cTxtGrv	:= sfDecodeUtf(cTxtGrv)
		If At("UTF-8",Upper(cTxtGrv)) > 0
			//cTxtGrv := sfHTMLEnc(cTxtGrv)
		Endif
		cTxtGrv 	:= NoAcento(cTxtGrv)
		cTxtAux   	:= EnCodeUtf8(cTxtGrv)
		If Type("cTxtAux") <> "U"
			cTxtGrv	:= EnCodeUtf8(cTxtGrv)
		Endif
		//cTxtGrv	:= StrTran(cTxtGrv,"&"," ")
		//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", cTxtGrv,{"Ok"},3)
		oNfe := XmlParser(cTxtGrv,"_",@cAviso,@cErro)
		//Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", cTxtGrv,{"Ok"},3)

		If !Empty(cErro)
			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
			//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - "+cErro ,'"'+cTxtGrv+'"')
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml erro: " + cErro,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			Return .F.
		Endif

		If !Empty(cAviso)
			//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml")
			//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml "+ cAviso ,'"'+cTxtGrv+'"')
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml " + IIf(!Empty(cAviso)," aviso="+cAviso,"forçou ajuste UTF-8") ,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			//	Return .F.
		Endif
		cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(sfDecodeUtf(cVldSch),.T.)))
	Endif

	If File(cDirSchema+"cteos_v"+NfeIdSPED(cVldSch,"versao")+".xsd")
		//Aviso("Xml",cVldSch,{"Xml"},3           )
		cVldSch		:= sfDecodeUtf(cVldSch)
		cVldSch 	:= NoAcento(cVldSch,.T.)
		cTxtAux   	:= EnCodeUtf8(cVldSch)
		If Type("cTxtAux") <> "U"
			cVldSch	:= EnCodeUtf8(cVldSch)
		Endif

		cAviso	:= ""
		cErro	:= ""
		If !XmlSVldSchema( cVldSch, cDirSchema+"cteos_v"+NfeIdSPED(cVldSch,"versao")+".xsd", @cErro, @cAviso )

			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")

			cNavegado	:= "http://www.sefaz.rs.gov.br/cte/cte-VAL.aspx"
			If !lAutoExec
				If !Empty(cAviso) .Or. !Empty(cErro)
					Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " Avisos e erros de validação de Schema!", "Aviso:'"+cAviso+"' - Erro:'"+cErro+"'",{"Ok"},3)
				Endif
				Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" XML com Schema Inválido! Copie o Texto abaixo e cole na próxima tela!",cText,{"Ok"},3)

				Define MsDialog oDlgWb3 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
				@ 005,010 Say "Xml" of oDlgWb3 Pixel
				@ 015,010 MsGet oNavegado Var cNavegado Size 300,05 Of oDlgWb3 Pixel
				oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb3 )

				If GetNewPar("XM_VLSCHFC",.T.)
					@ 010, 440 Button oBtnSair PROMPT "Aceitar" Size 40,10 Action(lAcept  := .T.,oDlgWb3:End()) Of oDlgWb3 Pixel
				Endif

				@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb3:End()) Of oDlgWb3 Pixel

				Activate MsDialog oDlgWb3 Centered

				oDlgWb3 := Nil
			Else
				If GetNewPar("XM_VLSCHFC",.T.)
					lAcept := .T.
				Endif
			Endif

			cMsgRetMail	+= "Schema inválido do XML Aviso:'"+cAviso+"' - Erro :'"+cErro+"' "

			If !lAcept
				Return .F.
			Endif
		Else
			//Aviso("XML com Schema Validado!",cText,{"Ok"},3)
		Endif
	Endif


	If Type("oNFe:_cteOSProc")<> "U"
		oNF := oNFe:_cteOSProc:_CTeOS
	ElseIf Type("oNFe:_enviCTe:_CTeOS")<> "U"
		oNF := oNFe:_enviCTe:_CTeOS
	ElseIf Type("oNFe")<> "U"
		oNF := oNFe:_CTeOS
	Else
		//MsgAlert("Não foi possível importar email do texto: "+cTxtGrv)
		cMsgRetMail	+= "XML não possui Tag CTe "
		//sfSendMail(GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de oCTe " ,'"'+cTxtGrv+'"')
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml - Erro de oCTe ",;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)
		Return .F.
	Endif

	ConOut(Type("oNF:_InfCTe:_emit"))
	ConOut(oNF:_InfCTe:_emit)
	
	oIdent     	:= oNF:_InfCTe:_ide
	oEmitente  	:= oNF:_InfCTe:_emit
	oValorPrest := oNF:_InfCTe:_vPrest
	oTomador	:= oNF:_InfCTe:_toma
	oImposto	:= oNF:_InfCTe:_imp
	oInfCte		:= Iif(Type("oNF:_InfCTe:_infCTeNorm") <> "U",oNF:_InfCTe:_infCTeNorm,Nil)

	If Type("oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe")<> "U"
		cChave	:= oNFe:_CTeOSProc:_protCTe:_infProt:_chCTe:TEXT
	Else
		cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	Endif

	cTipoDoc	:= "T"	// Atribuo T=CT-e
	
	
	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter to

	lExistChv := !DbSeek(cChave)
	// Verificou que a chave j[a existe na base
	If !lExistChv
		// Identificou que a nota fiscal já esta lancada
		If !Empty(CONDORXML->XML_KEYF1)
			cMsgRetMail += "Chave eletrönica '"+cChave+"' jã lançada como nota fiscal '"+CONDORXML->XML_KEYF1+"'. Não houve o recebimento do XML"
			Return .F.
		Endif
	Endif

	RecLock("CONDORXML",lExistChv)
	CONDORXML->XML_CHAVE		:= cChave
	If lMail
		CONDORXML->XML_CFROM 	:= oMessage:cFrom
		CONDORXML->XML_CTO		:= oMessage:cTo
		CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
		CONDORXML->XML_BODY		:= oMessage:cBody
		CONDORXML->XML_NROATT	:= oMessage:GetAttachCount()
	Else
		CONDORXML->XML_CFROM 	:= " "
		CONDORXML->XML_CTO		:= " "
		CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
		CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
		CONDORXML->XML_NROATT	:= 1
	Endif

	CONDORXML->XML_ARQ		:= cText
	CONDORXML->XML_ATT3		:= cTxtGrv

	If Type("oIdent:_tpCTe") <> "U"
		CONDORXML->XML_TPNF		:= oIdent:_tpCTe:Text // 0 - CT-e Normal; 1 - CT-e Complementar; 2 - Anulação; 3 - Substituição
	Endif

	// Melhoria em 21/05/2014 para contemplar a leitura do Protocolo de autorização
	// Fornecedores enviam PDF e XML com numero do Protocolo e não da Chave ou Numero da Nota
	nPxIniVlrTot	:= At("<vPrest><vTPrest>",CONDORXML->XML_ARQ)
	nPxIniVlrTot	+= 17
	nPxFimVlrTot	:= At("</vTPrest>",CONDORXML->XML_ARQ)

	If nPxIniVlrTot > 0 .And. nPxFimVlrTot > 0
		nXmlValNf 	:= Val(Substr(cText,nPxIniVlrTot,(nPxFimVlrTot-nPxIniVlrTot)))
		CONDORXML->XML_VLRDOC	:= nXmlValNf
	Endif


	// Se vier a partir de e-mail, permite que o arquivo PDF seja salvo na base também.

	If lMail
		For nForA := 1 To oMessage:getAttachCount()
			aAttInfo:= oMessage:getAttachInfo(nForA)
			// Analisa se há informaçaõd e anexo e se o arquivo anexo é um XML
			// 1 ShortName 			O nome do attachment.
			// 2 Type 				O tipo do anexo, por exemplo, text/plain ou image/x-png.
			// 3 Disposition		Tipo do arquivo.
			// 4 DispositionName	Nome do tipo de arquivo.
			// 5 ID					Identificação do anexo.
			// 6 Location			Local físico do anexo.
			// 7 * Size 			Tamanho do anexo.
			// *Parâmetro Size só estará disponível em versão superior a 7.00.131227A
			cAttInfo	:= aAttInfo[1]
			If Empty(cAttInfo)
				cAttInfo	:= SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
			Endif
			If At(".PDF",UPPER(cAttInfo)) > 0
				If Len(oMessage:getAttach(nForA)) < 1048576
					CONDORXML->XML_ATT2		:= oMessage:getAttach(nForA)
				Endif
			Endif

		Next
	Endif

	

	If Type("oEmitente:_CNPJ") <> "U"
		CONDORXML->XML_EMIT			:= oEmitente:_CNPJ:TEXT
	ElseIf Type("oEmitente:_CPF") <> "U"
		CONDORXML->XML_EMIT			:= oEmitente:_CPF:TEXT
	Endif
	CONDORXML->XML_INSCRI		:= IIf(Type("oEmitente:_IE") <> "U",oEmitente:_IE:TEXT,"ISENTO")

	CONDORXML->XML_NOMEMT		:= oEmitente:_xNome:TEXT // Nome emitente
	CONDORXML->XML_MUNMT		:= oEmitente:_enderEmit:_xMun:TEXT+"/"+oEmitente:_enderEmit:_UF:TEXT // Municipio Emitente

	// Avalia quem é o tomador do Servico
	If Type("oTomador:_CNPJ") <> "U"
		CONDORXML->XML_DEST			:= oTomador:_CNPJ:TEXT
	ElseIf Type("oTomador:_CPF") <> "U"
		CONDORXML->XML_DEST			:= oTomador:_CPF:TEXT
	Endif
	CONDORXML->XML_NOMEDT		:= oTomador:_xNome:TEXT  // Nome Remetente
	CONDORXML->XML_MUNDT		:= oTomador:_enderToma:_xMun:TEXT + "/"+ oTomador:_enderToma:_UF:TEXT // Municipio Destino

	If cLeftNil $ " #0" 	// 0=Padrão(Soh Num c/zeros)
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "1" 	// 1=Num e Serie
		CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_SERIE")[1])-Len(Trim(oIdent:_serie:TEXT)))+oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
		CONDORXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Padr(oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
	Endif

	cData:=Alltrim(oIdent:_dhEmi:TEXT)
	dData:=CTOD(Substr(cData,9,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
	CONDORXML->XML_EMISSA		:= dData

	CONDORXML->XML_RECEB		:= Date()
	CONDORXML->XML_HORREC		:= Time()
	CONDORXML->XML_USRREC		:= Padr(cUserName,30)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - CTe - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| "+cChave,59)+"|")
	ConOut(Padr("| Variável lSefMan   = "+IIf(lSefMan,".T.",".F."),59)+"|")
	ConOut(Padr("| Variável lAutoExec = "+IIf(lAutoExec,".T.",".F."),59)+"|")
	ConOut("+"+Replicate("-",58)+"+")

	If !Empty(cChave) .And. lSefMan .And. !lAutoExec
		cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))+cChave

		Define MsDialog oDlgWb4 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
		@ 005,010 Say "Página de validação do CT-e" of oDlgWb4 Pixel
		@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgWb4 Pixel
		oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb4 )

		@ 010, 350 Button oBtnPrint PROMPT "Confirmar Consulta" Size 70,10 Action (CONDORXML->XML_CONFER := Date(),CONDORXML->XML_HORCON := Time(),CONDORXML->XML_USRCON := Padr(cUserName,30),oDlgWb4:End()) Of oDlgWb4 Pixel
		@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlgWb4 Pixel
		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb4:End()) Of oDlgWb4 Pixel
		Activate MsDialog oDlgWb4 Centered
	Else
		cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		// Verifico se a empresa em cursor tem TSS configurado
		cIdentSPED	:= Iif(GetNewPar("XM_TSSEXIS",.T.),StaticCall(SPEDNFE,GetIdEnt)," ")
		If !Empty(cIdentSPED)
			// Trecho para validar autorização da NF
			cMensagem:= ""
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT    := StaticCall(SPEDNFE,GetIdEnt)
			ows:cCHVNFE		 := cChave
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

			If oWs:ConsultaChaveNFE()
				cMensagem := ""
				If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
					cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
				EndIf
				cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
				cMensagem += "Cod.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
				cMensagem += "Msg.Ret.NFe : "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
				If oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1 .And. !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
				EndIf
				// Nota fiscal Autorizada
				If Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
					CONDORXML->XML_CONFER 	:= Date()
					CONDORXML->XML_HORCON 	:= Time()
					CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
				// Nota fiscal não encontrada na base Sefaz 
				ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "217"
					//CONDORXML->XML_CONFER 	:= Date()
					//CONDORXML->XML_HORCON 	:= Time()
					//CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
				ElseIf Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
					// Se já existe o registro
					If !lExistChv
						// Se ainda não foi rejeitada a nota
						If Empty(CONDORXML->XML_REJEIT) 
							lRejPrev101	:= .T. 
						Endif
					Endif
					
					CONDORXML->XML_CONFER 	:= Date()
					CONDORXML->XML_HORCON 	:= Time()
					CONDORXML->XML_USRCON 	:= Padr("TSS-Central Xml-"+cUserName,30)
					CONDORXML->XML_REJEIT	:= Date()
					CONDORXML->XML_USRREJ	:= Padr("TSS-Central Xml-"+cUserName,30)
					lRej101	:= .T.
				Else
					//Aviso(STR0107,cMensagem,{"Nota fiscal não Autorizada na SEFAZ"},3)
					If !lAutoExec
						Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+"Consulta NF",cMensagem+Chr(13)+Chr(10)+"Conhecimento Eletrônico '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"'!",{"Ok"},3)
					Endif
				Endif
				//	Aviso(STR0107,cMensagem,{STR0114},3)
			Else
				If !lAutoExec
					Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				Endif
			EndIf
		Endif
	Endif
	CONDORXML->XML_TIPODC	:= cTipoDoc

	MsUnlock()

	// Se a NF-e foi rejeitada abra a tela de cancelamento para envio de email
	If lRej101 .And. !lRejPrev101
		If !lAutoExec
			If Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+" Consulta NF",cMensagem+Chr(13)+Chr(10)+"Chave Eletrônica: "+CONDORXML->XML_CHAVE+Chr(13)+Chr(10)+"Conhecimento Eletrônico '"+CONDORXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CONDORXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{"Enviar EMail","Ok"},3) == 1
				StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,,lRej101)
			Endif
		Else
			StaticCall(XMLDCONDOR,stRejeita,cChave,cMensagem,lAutoExec,lRej101,"101-Conhecimento Eletronico Cancelado - Cancelamento autorizado")
		Endif
	Endif


Return .T.

/*/{Protheus.doc} sfGrvCCe
(Efetua a gravação dos dados do XML para CCe )
@author MarceloLauschner
@since 29/08/2012
@version 1.0
@param cText, character, (Descrição do parâmetro)
@param lMail, ${param_type}, (Descrição do parâmetro)
@param oMessage, objeto, (Descrição do parâmetro)
@param oServer, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfGrvCCe(cText,lMail,oMessage,oServer)

	Local	cTxtGrv		:= cText
	Local	cVldSch		:= cText
	Local	lRej101		:= .F.
	Local	lRejPrev101	:= .F. 
	Local	cErro		:= ""
	Local	cAviso		:= ""
	Local	lCCeNFe		:= .F.
	Local	lCCeCTe		:= .F.
	Local	cMensagem	:= ""
	Local	cEncoding	:= "UTF-8"
	Local	oXML := TXMLManager():New()

	// Avalia necessita de retirar caracteres
	cVldSch 	:= sfRemoveCrlf(cVldSch,.T.)
	cText		:= sfRemoveCrlf(cText,.T.)
	
	
	If !oXML:Read( cText, ,"UTF-8" , 0 )
		oXML:ResetErrors()
		If !oXML:Read( cText, ,"UTF-16" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cText, ,"UTF-16LE" , 0 )
				oXML:ResetErrors()	
				If !oXML:Read( cText, ,"UTF-16BE" , 0 )
					oXML:ResetErrors()
					If !oXML:Read( cText, ,"ISO-8859-1" , 0 )
						oXML:ResetErrors()	
						If !oXML:Read( cText, ,"ASCII" , 0 )
							oXML:ResetErrors()
							If !oXML:Read( cText, ,"US-ASCII" , 0 )
								//MsgAlert( "Warning on Parse " + oXML:Warning()  )
								//MsgAlert( "Error on Parse " + oXML:Error()  )
							Else
								//MsgAlert( "No errors on Parse! - US-ASCII" )
								oXML:ResetErrors()
								cEncoding	:= "US-ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! -ASCII" )
							cEncoding	:= "ASCII"
						Endif
					Else
						//MsgAlert( "No errors on Parse! - ISO-8859-1" )
						cEncoding	:= "ISO-8859-1"		
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16BE" )
					cEncoding	:= "UTF-16BE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16LE" )	
				cEncoding	:= "UTF-16LE"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-16" )
			cEncoding	:= "UTF-16"
		Endif
	Else
		//MsgAlert( "No errors on Parse! - UTF-8" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cText	:= StrTran(cText,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	If lIsDebug
		sfDebugXml(oXML)
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	Endif



	cAviso	:= ""
	cErro	:= ""

	oCCe := XmlParser(cText,"_",@cAviso,@cErro)

	If !Empty(cErro)
		//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml 1329")
		cMsgRetMail	+= "Erro de XmlParser '"+cErro+"' "
		//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml CCe Erro: "+ cErro,;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)
		Return .F.
	Endif


	If !Empty(cAviso)
		//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml 1342")
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml CCe Aviso="+ cAviso ,'"'+cTxtGrv+'"')

		cErro	:= ""
		cAviso	:= ""
		cTxtGrv	:= sfDecodeUtf(cTxtGrv)
		If At("UTF-8",Upper(cTxtGrv)) > 0
			//cTxtGrv := sfHTMLEnc(cTxtGrv)
		Endif
		cTxtGrv := NoAcento(cTxtGrv)
		cTxtGrv	:= EnCodeUtf8(cTxtGrv)

		oCCe := XmlParser(cTxtGrv,"_",@cAviso,@cErro)

		If !Empty(cErro)
			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml 1351")
			//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml CCe Erro: "+ cErro,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			Return .F.
		Endif

		If !Empty(cAviso)
			//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml 1357")
			//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml CCe Aviso: "+ cAviso,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			//	Return .F.
		Endif
		cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(cVldSch,.T.)))

	Endif
	// Não será feita a validação do Schema XML da CCe por que o padrão Totvs não atende até o momento - 12/02/2013
	/*If File(cDirSchema+"leiautecce_v"+NfeIdSPED(cVldSch,"versao")+".xsd")

	//cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(cVldSch)))
	//Aviso("XML  Copie o Texto abaixo e cole na próxima tela!",cDirSchema+"envCCe_v"+NfeIdSPED(cVldSch,"versao")+".xsd" + "|"+cVldSch,{"Ok"},3)
	cErro	:= ""
	cAviso	:= ""
	If !XmlSVldSchema( cVldSch, cDirSchema+"leiautecce_v"+NfeIdSPED(cVldSch,"versao")+".xsd", @cErro, @cAviso )
	//TSSValidSchema(cXmlSig,cDirSchema+"envCCe_v"+SpedGetMv("MV_VEREVEN",cIdEnt,"1.00")+".xsd",@cErro,@cAviso)

	//TSSValidSchema(cXmlSig,cDirSchema+"envCCe_v"+SpedGetMv("MV_VEREVEN",cIdEnt,"1.00")+".xsd",@cErro,@cAviso)
	Aviso("XML com Schema Inválido! Copie o Texto abaixo e cole na próxima tela!",cVldSch,{"Ok"},3)

	cMsgRetMail	+= "Schema inválido do XML Aviso:'"+cAviso+"' - Erro :'"+cErro+"' "
	StaticCall(XMLDCONDOR,stSendMail,GetNewPar("XM_MAILADM","contato@centralxmlcom.br"),"Importação xml -Schema Cce Erro="+cErro+" Aviso="+cAviso  ,'"'+cTxtGrv+'"')

	If !GetNewPar("XM_VLSCHFC",.T.)
	Return .F.
	Endif

	Else
	Aviso("XML com Schema Validado!",cText,{"Ok"},3)
	Endif
	Endif*/

	
	If Type("oCCe:_procEventoNFe:_evento:_envEvento:_evento:_infEvento") <> "U"
		oEvento := oCCe:_procEventoNFe:_evento:_envEvento:_evento:_infEvento
	ElseIf Type("oCCe:_procEventoNFe:_envEvento:_evento:_infEvento") <> "U"
		oEvento := oCCe:_procEventoNFe:_envEvento:_evento:_infEvento
	ElseIf Type("oCCe:_procEventoNFe:_evento:_infEvento") <> "U"
		oEvento := oCCe:_procEventoNFe:_evento:_infEvento
	ElseIf Type("oCCe:_evento:_infEvento") <> "U"
		oEvento := oCCe:_evento:_infEvento
	ElseIf Type("oCCe:_procEventoCTe:_evento:_envEvento:_evento:_infEvento") <> "U"
		oEvento := oCCe:_procEventoCTe:_evento:_envEvento:_evento:_infEvento
	ElseIf Type("oCCe:_procEventoCTe:_eventoCTe:_infEvento") <> "U"
		oEvento := oCCe:_procEventoCTe:_eventoCTe:_infEvento
	ElseIf Type("oCCe:_envEvento:_evento:_infEvento") <> "U"
		oEvento := oCCe:_envEvento:_evento:_infEvento
	ElseIf Type("oCCe:_procCCeNFe:_envEvento:_evento:_infEvento") <> "U"
		oEvento := oCCe:_procCCeNFe:_envEvento:_evento:_infEvento
	ElseIf Type("oCCe:_procCCeCTe:_eventoCTe:_infEvento") <> "U"
		oEvento := oCCe:_procCCeCTe:_eventoCTe:_infEvento
	Else
		//MsgAlert("Não foi possível importar email do texto: "+cTxtGrv)
		cMsgRetMail	+= "XML não possui Tag CCe _procEventoNFe:_evento:_infEvento"
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de oCCe " ,'"'+cTxtGrv+'"')
		Return .F.
	Endif

	If Type("oEvento:_chNFe") <> "U"
		cChave	:= oEvento:_chNFe:TEXT
		lCCeNFe	:= .T.
	ElseIf Type("oEvento:_chCTe") <> "U"
		cChave	:= oEvento:_chCTe:TEXT
		lCCeCTe	:= .T.
	Else
		cMsgRetMail	+= "XML não possui Tag CCe _infEvento:_chCTe ou _infEvento:_chNFe"
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de oCCe " ,'"'+cTxtGrv+'"')
		Return .F.
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter to

	lExistChv := !DbSeek(cChave)

	RecLock("CONDORXML",lExistChv)
	// Somente uma carta de correção eletronica é permitida até o momento por nota fiscal
	// A nova CCe sempre irá substituir a anterior.
	// O número de Eventos da CCe é limitado a 20
	//If Empty(CONDORXML->XML_ATT4)
	CONDORXML->XML_ATT4		:= cText
	//Endif
	If lExistChv
		CONDORXML->XML_CHAVE		:= cChave
		If lMail
			CONDORXML->XML_CFROM 	:= oMessage:cFrom
			CONDORXML->XML_CTO		:= oMessage:cTo
			CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
			CONDORXML->XML_BODY		+= Alltrim(CONDORXML->XML_BODY)+oMessage:cBody
		Else
			CONDORXML->XML_CFROM 	:= " "
			CONDORXML->XML_CTO		:= " "
			CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
			CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
		Endif
	Else
		CONDORXML->XML_CHAVE		:= cChave
	Endif

	If !Empty(cChave) .And. !lAutoExec
		If lCCeNFe
			cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))+cChave
		ElseIf lCCeCTe
			cNavegado	:= Alltrim(GetMv("XM_URLSFZ2"))+cChave
		Endif

		Define MsDialog oDlgWb5 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser - Consulta NF-e para conferir existência do Evento da CC-e."
		@ 005,010 Say "Link de validação da NF-e " of oDlgWb5 Pixel
		@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgWb5 Pixel
		oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb5 )

		@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlgWb5 Pixel
		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb5:End()) Of oDlgWb5 Pixel
		Activate MsDialog oDlgWb5 Centered
	EndIf
	MsUnlock()
	If Type("oEvento:_detEvento:_xCorrecao") <> "U"
		cMensagem := "Texto da Carta de Correção: " + oEvento:_detEvento:_xCorrecao:TEXT
	ElseIf Type("oEvento:_detEvento:_evCCeCTe:_infCorrecao:_valorAlterado") <> "U"
		cMensagem := "Texto da Carta de Correção: " + oEvento:_detEvento:_evCCeCTe:_infCorrecao:_valorAlterado:TEXT
	ElseIf Type("oEvento:_detEvento:_evCCeNFe:_infCorrecao:_valorAlterado") <> "U"
		cMensagem := "Texto da Carta de Correção: " + oEvento:_detEvento:_evCCeNFe:_infCorrecao:_valorAlterado:TEXT
	Endif

	// Grava divergencia, forçando o lançamento semi-automático
	StaticCall(XMLDCONDOR,sfAtuXmlOk,"CC"/*cOkMot*/,/*lAtuItens*/,/*cItem*/,cMensagem/*cMsgAux*/,/*nLinXml*/,cChave/*cInChave*/)
	//sfAtuXmlOk("NC",.T.,oMulti:aCols[nInLinAtu,nPxItem],cMensagem,,,,cAssunto,cRecebe)

Return .T.


/*/{Protheus.doc} sfGrvCanc
(Efetua a gravação dos dados do XML para evento Cancelamento)
@author MarceloLauschner
@since 04/07/2013
@version 1.0
@param cText, character, (Descrição do parâmetro)
@param lMail, ${param_type}, (Descrição do parâmetro)
@param oMessage, objeto, (Descrição do parâmetro)
@param oServer, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfGrvCanc(cText,lMail,oMessage,oServer)

	Local	cTxtGrv		:= cText
	Local	cVldSch		:= cText
	Local	lRej101		:= .F.
	Local	lRejPrev101	:= .F. 
	Local	cErro		:= ""
	Local	cAviso		:= ""

	Local	cEncoding	:= "UTF-8"
	Local	oXML 		:= TXMLManager():New()

	
	// Avalia necessita de retirar caracteres
	cVldSch 	:= sfRemoveCrlf(cVldSch,.T.)
	cText		:= sfRemoveCrlf(cText,.T.)

	If !oXML:Read( cText, ,"UTF-8" , 0 )
		oXML:ResetErrors()
		If !oXML:Read( cText, ,"UTF-16" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cText, ,"UTF-16LE" , 0 )
				oXML:ResetErrors()	
				If !oXML:Read( cText, ,"UTF-16BE" , 0 )
					oXML:ResetErrors()
					If !oXML:Read( cText, ,"ISO-8859-1" , 0 )
						oXML:ResetErrors()	
						If !oXML:Read( cText, ,"ASCII" , 0 )
							oXML:ResetErrors()
							If !oXML:Read( cText, ,"US-ASCII" , 0 )
								//MsgAlert( "Warning on Parse " + oXML:Warning()  )
								//MsgAlert( "Error on Parse " + oXML:Error()  )
							Else
								//MsgAlert( "No errors on Parse! - US-ASCII" )
								oXML:ResetErrors()
								cEncoding	:= "US-ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! -ASCII" )
							cEncoding	:= "ASCII"
						Endif
					Else
						//MsgAlert( "No errors on Parse! - ISO-8859-1" )
						cEncoding	:= "ISO-8859-1"		
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16BE" )
					cEncoding	:= "UTF-16BE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16LE" )	
				cEncoding	:= "UTF-16LE"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-16" )
			cEncoding	:= "UTF-16"
		Endif
	Else
		//MsgAlert( "No errors on Parse! - UTF-8" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cText	:= StrTran(cText,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	If lIsDebug
		sfDebugXml(oXML)
		Aviso(ProcName(1)+ "." + ProcName(0)+"."+ Alltrim(Str(ProcLine(0))),cText,{"Ok"},3)
	Endif

	cAviso	:= ""
	cErro	:= ""

	oNfe := XmlParser(cText,"_",@cAviso,@cErro)

	If !Empty(cErro)
		//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml 1329")
		cMsgRetMail	+= "Erro de XmlParser '"+cErro+"' "
		//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml Prot.Cancelamento Erro: "+ cErro,;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)
		Return .F.
	Endif


	If !Empty(cAviso)
		//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml 1342")
		//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
		"Importação xml Prot.Cancelamento Aviso: "+ cAviso,;
		'"'+cTxtGrv+'"',;
		.F.,;
		cArqAttAch,;
		cAttachName)

		cErro	:= ""
		cAviso	:= ""
		cTxtGrv	:= sfDecodeUtf(cTxtGrv)
		If At("UTF-8",Upper(cTxtGrv)) > 0
			//cTxtGrv := sfHTMLEnc(cTxtGrv)
		Endif
		cTxtGrv := NoAcento(cTxtGrv)
		cTxtGrv	:= EnCodeUtf8(cTxtGrv)

		oNfe := XmlParser(cTxtGrv,"_",@cAviso,@cErro)

		If !Empty(cErro)
			//MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml 1351")
			//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml Prot.Cancelamento Erro: "+ cErro,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			Return .F.
		Endif

		If !Empty(cAviso)
			//MsgAlert(cErro+chr(13)+cAviso,"Aviso ao validar schema do Xml 1357")
			//cRecebe, cAssunto, cMensagem, lExibSend, cArqAttAch, cAttachName
			StaticCall(	XMLDCONDOR,;
			stSendMail,;
			GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),;
			"Importação xml Prot.Cancelamento Aviso: "+ cAviso,;
			'"'+cTxtGrv+'"',;
			.F.,;
			cArqAttAch,;
			cAttachName)
			//	Return .F.
		Endif
		cVldSch	:= Alltrim(EnCodeUtf8(NoAcento(cVldSch,.T.)))

	Endif

	// Vai exibir "book"
	//While .T. 
	//	MsgAlert( oXML:CNAME )
	//    If ! oXML:DOMHasChildNode() 
	//    	Exit
	//    Endif
	//    oXML:DOMChildNode()
	//Enddo
	// procCancNfe/cancNFe/infCanc/tpAmb/

	If Type("oNFe:_procEventoNFe:_evento:_envEvento:_evento:_infEvento") <> "U"
		oNF := oNFe:_procEventoNFe:_evento:_envEvento:_evento:_infEvento
	ElseIf Type("oNFe:_procEventoNFe:_envEvento:_evento:_infEvento") <> "U"
		oNF := oNFe:_procEventoNFe:_envEvento:_evento:_infEvento
	ElseIf Type("oNFe:_procEventoNFe:_evento:_infEvento") <> "U"
		oNF := oNFe:_procEventoNFe:_evento:_infEvento
	ElseIf Type("oNFe:_procCancCte:_cancCTe:_infCanc") <> "U"
		oNF := oNFe:_procCancCte:_cancCTe:_infCanc
	ElseIf Type("oNFe:_procCancNfe:_cancNFe:_infCanc") <> "U"
		oNF := oNFe:_procCancNfe:_cancNfe:_infCanc
	ElseIf Type("oNFe:_procEventoCTe:_eventoCTe:_infEvento") <> "U"
		oNF := oNFe:_procEventoCTe:_eventoCTe:_infEvento
	ElseIf Type("oNFe:_envEvento:_evento:_infEvento") <> "U"
		oNF := oNFe:_envEvento:_evento:_infEvento
	ElseIf Type("oNFe:_eventoCTe:_infEvento") <> "U"
		oNF := oNFe:_eventoCTe:_infEvento
	ElseIf Type("oNFe:_evento:_infEvento") <> "U"
		oNF := oNFe:_evento:_infEvento
	ElseIf Type("oNFe:_retConsSitNFe:_procEventoNFe:_evento:_infEvento") <> "U"
		oNF	:= oNFe:_retConsSitNFe:_procEventoNFe:_evento:_infEvento
	ElseIf Type("oNFe:_retConsSitCTe:_procEventoCTe:_eventoCTe:_infEvento") <> "U"
		oNF	:= oNFe:_retConsSitCTe:_procEventoCTe:_eventoCTe:_infEvento
	Else
		//MsgAlert("Não foi possível importar email do texto: "+cTxtGrv)
		cMsgRetMail	+= "XML não possui Tag CCe oNFe:_evento:_envEvento:_evento:_infEvento "
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de procEventoNfe " ,'"'+cTxtGrv+'"')
		Return .F.
	Endif

	cChave	:= IIf(Type("oNF:_chNFe") <> "U",oNF:_chNFe:TEXT,IIf(Type("oNF:_chCTe")<>"U",oNF:_chCTe:TEXT,""))

	If Empty(cChave)
		cMsgRetMail	+= "XML não possui chave eletrônica de CTe ou NFe "
		StaticCall(	XMLDCONDOR,;
		stSendMail,;
		GetNewPar("XM_MAILADM","marcelolauschner@gmail.com"),"Importação xml - Erro de Cancelamento " ,'"'+cTxtGrv+'"')
	Endif

	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter to

	lExistChv := !DbSeek(cChave)

	RecLock("CONDORXML",lExistChv)

	CONDORXML->XML_RECEB	:= Date()
	CONDORXML->XML_HORREC	:= Time()
	CONDORXML->XML_USRREC	:= Padr(cUserName,30)
	CONDORXML->XML_ATT5		:= cText

	If lExistChv
		CONDORXML->XML_CHAVE		:= cChave
		If lMail
			CONDORXML->XML_CFROM 	:= oMessage:cFrom
			CONDORXML->XML_CTO		:= oMessage:cTo
			CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
			CONDORXML->XML_BODY		+= Alltrim(CONDORXML->XML_BODY)+oMessage:cBody
		Else
			CONDORXML->XML_CFROM 	:= " "
			CONDORXML->XML_CTO		:= " "
			CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
			CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
		Endif
	Endif

	If !Empty(cChave) .And. !lAutoExec
		cNavegado	:= Iif(Type("oNF:_chNFe") <> "U",Alltrim(GetMv("XM_URLCSFZ"))+cChave,Alltrim(GetMv("XM_URLSFZ2"))+cChave)

		Define MsDialog oDlgWb6 From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser - Consulta NF-e/CT-e para conferir existência do Evento da CC-e ou Protocolo de Cancelamento."
		@ 005,010 Say "Link de validação da NF-e " of oDlgWb6 Pixel
		@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlgWb6 Pixel
		oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlgWb6 )

		@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlgWb6 Pixel
		@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlgWb6:End()) Of oDlgWb6 Pixel
		Activate MsDialog oDlgWb6 Centered
	EndIf

	MsUnlock()

	StaticCall(XMLDCONDOR,stRejeita,cChave,"Evento de Cancelamento de Documento Eletrônico Autorizado recebido.",lAutoExec)


Return .T.

/*/{Protheus.doc} sfDebugXml
//Efetua o debug do XML para saber se o mesmo é válido ou não
@author marce
@since 05/09/2017
@version 6
@param oXML, object, descricao
@type function
/*/
Static Function sfDebugXml(oXML)
	Local cTextOut	:= ""
	Local nI 

	lLoop := .T. 
	while lLoop
		cTextOut += "Name: " + oXML:CNAME + CRLF
		cTextOut += "Path: " + oXML:CPATH + CRLF
		cTextOut += "Value: " + oXML:CTEXT + CRLF

		xRet := oXML:DOMHasAtt() //Retorna verdadeiro (.T.) caso possua algum atributo. Caso contrário, falso (.F.).
		if !xRet
			cTextOut += "No attributes" + CRLF
		else
			If  oXML:DOMHasNextNode() //O método verifica na árvore do XML se existe um próximo nó no mesmo nível do nó atual
				xRet := oXML:DOMGetAttArray()
				nLen := Len( xRet )
				cTextOut += cValToChar( nLen ) + " attributes:" + CRLF
				for nI := 1 to nLen
					cTextOut += "Attribute " + cValToChar( nI ) + CRLF
					cTextOut += "Name: " + xRet[nI][1] + CRLF
					cTextOut += "Value: " + xRet[nI][2] + CRLF
					cTextOut += ""
				next nI
			Endif
		endif
		xRet := oXML:DOMHasNextNode() //O método verifica na árvore do XML se existe um próximo nó no mesmo nível do nó atual
		cTextOut += "Next node: " + IIf( xRet == .T., "Yes", "No" ) + CRLF

		xRet := oXML:DOMHasPrevNode()
		cTextOut += "Previous node: " + IIf( xRet == .T., "Yes", "No" ) + CRLF

		xRet := oXML:DOMHasParentNode()
		cTextOut += "Parent node: " + IIf( xRet == .T., "Yes", "No" ) + CRLF

		xRet := oXML:DOMHasChildNode()
		cTextOut += "Children node: " + IIf( xRet == .T., "Yes", "No" ) + CRLF

		xRet := oXML:DOMChildCount()
		cTextOut += "# of Children: " + cValToChar( xRet ) + CRLF

		if oXML:DOMHasChildNode()
			xRet := oXML:DOMChildNode()
		elseif oXML:DOMHasNextNode()
			xRet := oXML:DOMNextNode()
		else
			lRet1 := oXML:DOMParentNode()
			if lRet1
				lRet2 := oXML:DOMNextNode()

				while !lRet2
					lRet1 := oXML:DOMParentNode()
					lRet2 := oXML:DOMNextNode()

					if !lRet1 .And. !lRet2
						Aviso("Leitura do XML - Debug!",cTextOut,{"Ok"},3)
						return
					endif
				enddo

				loop
			else
				cTextOut += "Error not possible, once it came from a parent" + CRLF
				Aviso("Leitura do XML - Debug!",cTextOut,{"Ok"},3)
				return
			endif
		endif

		if xRet == .F.
			cTextOut += "Error: " + oXML:Error() + CRLF
			Aviso("Leitura do XML - Debug!",cTextOut,{"Ok"},3)
			return
		endif
	enddo
	Aviso("Leitura do XML - Debug!",cTextOut,{"Ok"},3)
Return 


Static Function sfReadNFSe(cInXmlNFse,lMail,oMessage,oServer,cInFile)
	
	Local	aAreaOld	:= GetArea()
	Local	lRet		:= .F. 
	Local	aRetDados	:= {}
	Local	nCb			:= 0
	Local	nIt			:= 0
	Local	cChave		:= ""
	Private	lIsXml		:= .F. 
	Default	cInXmlNFse	:= ""

	If At("www.betha.com.br",cInXmlNFSe) > 0
		sfReadBetha(@cInXmlNFSe,@aRetDados,@cChave)
		lIsXml	:= .T. 
		lRet	:= sfGrvNFSe(cChave,aRetDados,cInXMLNFse,lMail,oMessage,oServer)
	ElseIf At("http://www.abrasf.org.br/",cInXmlNFSe) > 0
		sfReadAbrasf(@cInXmlNFSe,@aRetDados,@cChave)
		lIsXml	:= .T. 
		lRet	:= sfGrvNFSe(cChave,aRetDados,cInXMLNFse,lMail,oMessage,oServer)	
	Else
		lRet	:= sfFileSP(cInFile,@aRetDados,lMail,oMessage,oServer)
	Endif

Return lRet 


Static Function sfGrvNFSe(cChave,aRetDados,cInXMLNFse,lMail,oMessage,oServer)
	
	Local	aAreaOld	:= GetArea()
	Local	lRet		:= .F. 
	Local	nCb			:= 0
	Local	nIt			:= 0
	Local	aUfOriDest	:= {"",""}
	
	//TODO - Criar aqui função para gravar os dados da NFSe
	For nCb := 1 To Len(aRetDados)

		If nCB == 1 
			U_DbSelArea("CONDORXML",.F.,1)
			Set Filter to

			lExistChv := !DbSeek(cChave)

			RecLock("CONDORXML",lExistChv)
			CONDORXML->XML_RECEB	:= Date()
			CONDORXML->XML_HORREC	:= Time()
			CONDORXML->XML_USRREC	:= Padr(cUserName,30)
			If lIsXml
				CONDORXML->XML_ARQ	:= cInXmlNFse				
			Endif
			CONDORXML->XML_CONFER := Date()
			CONDORXML->XML_HORCON := Time()
			CONDORXML->XML_USRCON := Padr("NFS-E Central Xml-"+cUserName,30)
			CONDORXML->XML_DTRVLD := Date()
			
			CONDORXML->XML_TIPODC 	:= "S"
			If lExistChv
				CONDORXML->XML_CHAVE		:= cChave
				If lMail
					CONDORXML->XML_CFROM 	:= oMessage:cFrom
					CONDORXML->XML_CTO		:= oMessage:cTo
					CONDORXML->XML_SUBJECT 	:= oMessage:cSubject
					CONDORXML->XML_BODY		+= oMessage:cBody
				Else
					CONDORXML->XML_CFROM 	:= " "
					CONDORXML->XML_CTO		:= " "
					CONDORXML->XML_SUBJECT 	:= "Xml via diretório"
					CONDORXML->XML_BODY		:= "Xml carregado através de Pasta/Diretório"
				Endif
			Endif

		Endif

		If aRetDados[nCb][1] == "NUMNF"
			If cLeftNil $ " #0" 	// 0=Padrão(Soh Num c/zeros)
				CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(aRetDados[nCB][2])) )+aRetDados[nCB][2],TamSX3("F1_DOC")[1])
			ElseIf cLeftNil == "1" 	// 1=Num e Serie
				CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(aRetDados[nCB][2])) )+aRetDados[nCB][2],TamSX3("F1_DOC")[1])
			ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
				CONDORXML->XML_NUMNF		:= Padr(aRetDados[nCB][2],TamSX3("F1_DOC")[1])
			Endif
		ElseIf aRetDados[nCb][1] == "RPSER"
			If cLeftNil $ " #0" 	// 0=Padrão(Soh Num c/zeros)
				CONDORXML->XML_NUMNF		:= Padr(aRetDados[nCB][2],TamSX3("F1_SERIE")[1]) + Alltrim(CONDORXML->XML_NUMNF)
			ElseIf cLeftNil == "1" 	// 1=Num e Serie
				CONDORXML->XML_NUMNF		:= Right(StrZero(0,(TamSX3("F1_SERIE")[1])-Len(Trim(aRetDados[nCB][2])))+aRetDados[nCB][2],TamSX3("F1_SERIE")[1]) + CONDORXML->XML_NUMNF
			ElseIf cLeftNil == "2"	// 2=Sem preencher zeros
				CONDORXML->XML_NUMNF		:= Padr(aRetDados[nCB][2],TamSX3("F1_SERIE")[1]) + CONDORXML->XML_NUMNF
			Endif
		ElseIf aRetDados[nCb][1] == "EMISS"
			CONDORXML->XML_EMISSA := aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "TMCGC"
			CONDORXML->XML_DEST		:= aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "TMNOM"
			CONDORXML->XML_NOMEDT := aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "TMMUN"
			CONDORXML->XML_MUNDT := aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "TMUF"
			CONDORXML->XML_MUNDT := Alltrim(CONDORXML->XML_MUNDT)+"/"+aRetDados[nCB][2]	
			aUfOriDest[2]		:= aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "PRCGC"
			CONDORXML->XML_EMIT	:= aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "PRNOM"
			CONDORXML->XML_NOMEMT := aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "PRMUN"
			CONDORXML->XML_MUNMT := aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "PRUF"
			CONDORXML->XML_MUNMT := Alltrim(CONDORXML->XML_MUNMT)+"/"+aRetDados[nCB][2]	
			aUfOriDest[1]		:= aRetDados[nCB][2]	
		ElseIf aRetDados[nCb][1] == "VLIQD"
			CONDORXML->XML_VLRDOC := aRetDados[nCB][2]	
		Endif
		If nCB == Len(aRetDados)
			CONDORXML->(MsUnlock())
		Endif
	Next 

	For nIt := 1 To Len(aRetDados)

		If nIt == 1	
			U_DbSelArea("CONDORXMLITENS",.F.,2)
			Set Filter To 
			lExistChv := !DbSeek(Padr(cChave,Len(CONDORXMLITENS->XIT_CHAVE)) + StrZero(nIt,4))
			RecLock("CONDORXMLITENS",lExistChv)

			CONDORXMLITENS->XIT_CHAVE		:= cChave
			CONDORXMLITENS->XIT_ITEM		:= StrZero(nIt,4)
			CONDORXMLITENS->XIT_NCM			:= "00000000"
			CONDORXMLITENS->XIT_QTENFE		:= 1
			// Força um CFOP de ISSQN fora ou dentro do estado pois não tem irformação disso no XML ou arquivo TXT
			CONDORXMLITENS->XIT_CFNFE		:= Iif(aUfOriDest[1]==aUfOriDest[2],"5933","6933") 
		Endif

		If aRetDados[nIt][1] == "SVCOD"
			CONDORXMLITENS->XIT_CODNFE := aRetDados[nIt][2]
		ElseIf aRetDados[nIt][1] == "SVDES"
			CONDORXMLITENS->XIT_DESCRI := aRetDados[nIt][2]	
		ElseIf aRetDados[nIt][1] == "VLIQD"	
			CONDORXMLITENS->XIT_PRCNFE := aRetDados[nIt][2]
			CONDORXMLITENS->XIT_TOTNFE := aRetDados[nIt][2]
		Endif
		If nIt == Len(aRetDados)
			CONDORXMLITENS->(MsUnlock())
			lRet	:= .T. 
		Endif
	Next 

	RestArea(aAreaOld)

Return lRet  

Static Function sfReadBetha(cInXmlNFSE,aRetDados,cInChave)

	Local	oXML 		:= TXMLManager():New()
	Local	cEncoding	:= "UTF-8"
	Local 	cTextOut	:= ""
	Local 	nI 
	Local	aUf			:= {}
	Local	aChvNFSe	:= {,,,"66",,,,}
	//Código	Descrição		Modelo
	//		1 	Nota Fiscal 	1/1ª
	//		1B 	Nota Fiscal Avulsa	-
	//		2 	Nota Fiscal de Venda a Consumidor	2
	//		2D	Cupom Fiscal	-
	//		2E	Cupom Fiscal Bilhete de Passagem	-
	//		4 	Nota Fiscal de Produtor	4
	//		6	Nota Fiscal/Conta de Energia Elétrica	6
	//		7 	Nota Fiscal de Serviço de Transporte	7
	//		8	Conhecimento de Transporte Rodoviário de Cargas	8
	//		8B	Conhecimento de Transporte de Cargas Avulso	-
	//		9	Conhecimento de Transporte Aquaviário de Cargas	9
	//		10	Conhecimento Aéreo	10
	//		11	Conhecimento de Transporte Ferroviário de Cargas	11
	//		13	Bilhete de Passagem Rodoviário	13
	//		14	Bilhete de Passagem Aquaviário	14
	//		15	Bilhete de Passagem e Nota de Bagagem	15
	//		17	Despacho de Transporte	17
	//		16	Bilhete de Passagem Ferroviário	16
	//		18	Resumo de Movimento Diário	18
	//		20	Ordem de Coleta de Cargas	20
	//		21 Nota Fiscal de Serviço de Comunicação	21
	//		22 Nota Fiscal de Serviço de Telecomunicação	22
	//		23	GNRE	23
	//		24	Autorização de Carregamento e Transporte	24
	//		25	Manifesto de Carga	25
	//		26	Conhecimento de Transporte Multimodal de Cargas 26
	//		27 Nota Fiscal De Transporte Ferroviário De Carga	-
	//		28	Nota Fiscal/Conta de Fornecimento de Gás Canalizado	-
	//		29	Nota Fiscal/Conta De Fornecimento D'água Canalizada	-
	//		55 Nota Fiscal Eletrônica	
	//		57	Conhecimento de Transporte Eletrônico - CT-e	-
	//		59	Cupom Fiscal Eletrônico CF-e-SAT	-
	//		59	Cupom Fiscal Eletrônico - CF-e	-
	//		60	Cupom Fiscal Eletrônico CF-e-ECF	60
	//		65 Nota Fiscal Eletrônica para Consumidor Final	65
	//		67 Nota de Serviço CTe - CTEOS 
	
	// 1- Código da UF Código da UF do emitente do Documento Fiscal (Tamanho 2 caracteres)
	// 2- Ano e Mês da Emissão (AAMM) Ano e Mês de emissão do NF-e/CT-e (Tamanho 4 caracteres)
	// 3- CNPJ CNPJ do emitente (Tamanho 14 caracteres)
	// 4- Modelo Modelo do Documento Fiscal (Tamanho 2 caracteres)
	// 5- Série Série do Documento Fiscal (Tamanho 3 caracteres)
	// 6- Numero do CTe Número do Documento Fiscal (Tamanho 9 caracteres)
	// 7- Código Numérico Código Numérico que compõe a Chave de Acesso (Tamanho 9 caracteres)
	// 8- Dígito Dígito Verificador da Chave de Acesso (Tamanho 1 caractere)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - NFSe - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| Inicio: "+Time(),59)+"|")

	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	// Avalia necessita de retirar caracteres
	cInXmlNFSE		:= sfRemoveCrlf(cInXmlNFSE,.T.)

	If !oXML:Read( cInXmlNFSE, , , 0 )
		If !oXML:Read( cInXmlNFSE, ,"UTF-8" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cInXmlNFSE, ,"UTF-16" , 0 )
				oXML:ResetErrors()
				If !oXML:Read( cInXmlNFSE, ,"UTF-16LE" , 0 )
					oXML:ResetErrors()	
					If !oXML:Read( cInXmlNFSE, ,"UTF-16BE" , 0 )
						oXML:ResetErrors()
						If !oXML:Read( cInXmlNFSE, ,"ISO-8859-1" , 0 )
							oXML:ResetErrors()	
							If !oXML:Read( cInXmlNFSE, ,"ASCII" , 0 )
								oXML:ResetErrors()
								If !oXML:Read( cInXmlNFSE, ,"US-ASCII" , 0 )
									MsgAlert( "Warning on Parse " + oXML:Warning()  )
									MsgAlert( "Error on Parse " + oXML:Error()  )
								Else
									//MsgAlert( "No errors on Parse! - US-ASCII" )
									oXML:ResetErrors()
									cEncoding	:= "US-ASCII"
								Endif
							Else
								//MsgAlert( "No errors on Parse! -ASCII" )
								cEncoding	:= "ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! - ISO-8859-1" )
							cEncoding	:= "ISO-8859-1"		
						Endif
					Else
						//MsgAlert( "No errors on Parse! - UTF-16BE" )
						cEncoding	:= "UTF-16BE"
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16LE" )	
					cEncoding	:= "UTF-16LE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16" )
				cEncoding	:= "UTF-16"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-8" )
			cEncoding	:= "UTF-8"
		Endif
	Else
		//MsgAlert( "No errors on Parse!" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cInXmlNFSE	:= StrTran(cInXmlNFSE,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	//Aviso("cInXmlNFSE ",cInXmlNFSE,{"Ok"},3)

	cAviso	:= ""
	cErro	:= ""
	oNfse 	:= XmlParser(cInXmlNFSE,"_",@cAviso,@cErro)

	If !Empty(cAviso) .Or. !Empty(cErro)
		MsgAlert(cAviso+"||"+cErro)
	Endif




	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_Numero") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_Numero:TEXT
		Aadd(aRetDados,{"NUMNF", xVar})
		aChvNFSe[6]	:= StrZero(Val(xVar),9)
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao:TEXT
		Aadd(aRetDados,{"CDVER", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DataEmissao") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DataEmissao:TEXT
		xVar := StrTran(Alltrim(Substr(xVar,1,10)),"-","") // 2017-06-10T09:23:55
		aChvNFSe[2]	:= Substr(xVar,3,4) // AAMM
		xVar := STOD(xVar)			
		Aadd(aRetDados,{"EMISS", xVar}) 
		
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OutrasInformacoes") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OutrasInformacoes:TEXT
		Aadd(aRetDados,{"OTINF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_BaseCalculo") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_BaseCalculo:TEXT
		Aadd(aRetDados,{"BASEC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_Aliquota") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_Aliquota:TEXT
		Aadd(aRetDados,{"ALQIS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_ValorIss") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_ValorIss:TEXT
		Aadd(aRetDados,{"VLRIS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_ValorLiquidoNfse") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_ValorLiquidoNfse:TEXT
		Aadd(aRetDados,{"VLIQD", Val(xVar)})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:TEXT
		Aadd(aRetDados,{"PRCGC", xVar})
		aChvNFSe[3]	:= StrZero(Val(xVar),14)
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_InscricaoMunicipal") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_InscricaoMunicipal:TEXT
		Aadd(aRetDados,{"PRINM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial:TEXT
		Aadd(aRetDados,{"PRNOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Endereco") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Endereco:TEXT
		Aadd(aRetDados,{"PREND", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Numero") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Numero:TEXT
		Aadd(aRetDados,{"PRNRO", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Bairro") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Bairro:TEXT
		Aadd(aRetDados,{"PRBAI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_CodigoMunicipio") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"PRMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Uf") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Uf:TEXT
		Aadd(aRetDados,{"PRUF", xVar})
		aChvNFSe[1]	:= aUF[aScan(aUF,{|x| x[1] == xVar})][02]
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Cep") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Cep:TEXT
		Aadd(aRetDados,{"PRCEP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_CodigoMunicipio") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"OGMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_Uf") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_Uf:TEXT
		Aadd(aRetDados,{"OGUF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Numero") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Numero:TEXT
		Aadd(aRetDados,{"RPNUM", xVar})
		aChvNFSe[7]	:= StrZero(Val(xVar),9)
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Serie") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Serie:TEXT
		Aadd(aRetDados,{"RPSER", xVar})
		aChvNFSe[5]	:= "001"
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Tipo") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_IdentificacaoRps:_Tipo:TEXT
		Aadd(aRetDados,{"RPTIP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_DataEmissao") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_DataEmissao:TEXT
		Aadd(aRetDados,{"RPEMI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_Status") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Rps:_Status:TEXT
		Aadd(aRetDados,{"RPSTS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Competencia") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Competencia:TEXT
		Aadd(aRetDados,{"RPREF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorServicos") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorServicos:TEXT
		Aadd(aRetDados,{"SVVLR", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorDeducoes") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorDeducoes:TEXT
		Aadd(aRetDados,{"SVDED", xVar})
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorIss") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_ValorIss:TEXT
		Aadd(aRetDados,{"SVISS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_Aliquota") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_Aliquota:TEXT
		Aadd(aRetDados,{"SVALQ", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_DescontoIncondicionado") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_DescontoIncondicionado:TEXT
		Aadd(aRetDados,{"SVDIC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_DescontoCondicionado") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Valores:_DescontoCondicionado:TEXT
		Aadd(aRetDados,{"SVDCO", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_IssRetido") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_IssRetido:TEXT
		Aadd(aRetDados,{"SVISR", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ResponsavelRetencao") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ResponsavelRetencao:TEXT
		Aadd(aRetDados,{"SVRRT", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ItemListaServico") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ItemListaServico:TEXT
		Aadd(aRetDados,{"SVCOD", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoCnae") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoCnae:TEXT
		Aadd(aRetDados,{"SVCNA", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Discriminacao") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Discriminacao:TEXT
		Aadd(aRetDados,{"SVDES", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoMunicipio") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"SVMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ExigibilidadeISS") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ExigibilidadeISS:TEXT
		Aadd(aRetDados,{"SVEXG", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_MunicipioIncidencia") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_MunicipioIncidencia:TEXT
		Aadd(aRetDados,{"SVINC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_CpfCnpj:_Cnpj") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_CpfCnpj:_Cnpj:TEXT
		Aadd(aRetDados,{"PRCGC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_InscricaoMunicipal") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_InscricaoMunicipal:TEXT
		Aadd(aRetDados,{"PRINM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:TEXT
		Aadd(aRetDados,{"TMCGC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_RazaoSocial") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_RazaoSocial:TEXT
		Aadd(aRetDados,{"TMNOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Endereco") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Endereco:TEXT
		Aadd(aRetDados,{"TMEND", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Numero") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Numero:TEXT
		Aadd(aRetDados,{"TMNRO", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Bairro") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Bairro:TEXT
		Aadd(aRetDados,{"TMBAI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_CodigoMunicipio") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"TMMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Uf") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Uf:TEXT
		Aadd(aRetDados,{"TMUF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Cep") <> "U"
		xVar := oNFse:_ConsultarNfseResposta:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_Endereco:_Cep:TEXT
		Aadd(aRetDados,{"TMCEP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif


	aChvNFSe[8]	:= Modulo11(aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7])

	cInChave := aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7]+ cValToChar(aChvNFSe[8])

Return 


Static Function sfReadAbrasf(cInXmlNFSE,aRetDados,cInChave)

	Local	oXML 		:= TXMLManager():New()
	Local	cEncoding	:= "UTF-8"
	Local 	cTextOut	:= ""
	Local 	nI 
	Local	aUf			:= {}
	Local	aChvNFSe	:= {,,,"66",,,,}
	Local	cMsgOutErr	:= ""
	// 1- Código da UF Código da UF do emitente do Documento Fiscal (Tamanho 2 caracteres)
	// 2- Ano e Mês da Emissão (AAMM) Ano e Mês de emissão do NF-e/CT-e (Tamanho 4 caracteres)
	// 3- CNPJ CNPJ do emitente (Tamanho 14 caracteres)
	// 4- Modelo Modelo do Documento Fiscal (Tamanho 2 caracteres)
	// 5- Série Série do Documento Fiscal (Tamanho 3 caracteres)
	// 6- Numero do CTe Número do Documento Fiscal (Tamanho 9 caracteres)
	// 7- Código Numérico Código Numérico que compõe a Chave de Acesso (Tamanho 9 caracteres)
	// 8- Dígito Dígito Verificador da Chave de Acesso (Tamanho 1 caractere)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - NFSe - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| Inicio: "+Time(),59)+"|")

	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	// Avalia necessita de retirar caracteres
	cInXmlNFSE		:= sfRemoveCrlf(cInXmlNFSE,.T.)

	If !oXML:Read( cInXmlNFSE, , , 0 )
		If !oXML:Read( cInXmlNFSE, ,"UTF-8" , 0 )
			oXML:ResetErrors()
			If !oXML:Read( cInXmlNFSE, ,"UTF-16" , 0 )
				oXML:ResetErrors()
				If !oXML:Read( cInXmlNFSE, ,"UTF-16LE" , 0 )
					oXML:ResetErrors()	
					If !oXML:Read( cInXmlNFSE, ,"UTF-16BE" , 0 )
						oXML:ResetErrors()
						If !oXML:Read( cInXmlNFSE, ,"ISO-8859-1" , 0 )
							oXML:ResetErrors()	
							If !oXML:Read( cInXmlNFSE, ,"ASCII" , 0 )
								oXML:ResetErrors()
								If !oXML:Read( cInXmlNFSE, ,"US-ASCII" , 0 )
									MsgAlert( "Warning on Parse " + oXML:Warning()  )
									MsgAlert( "Error on Parse " + oXML:Error()  )
								Else
									//MsgAlert( "No errors on Parse! - US-ASCII" )
									oXML:ResetErrors()
									cEncoding	:= "US-ASCII"
								Endif
							Else
								//MsgAlert( "No errors on Parse! -ASCII" )
								cEncoding	:= "ASCII"
							Endif
						Else
							//MsgAlert( "No errors on Parse! - ISO-8859-1" )
							cEncoding	:= "ISO-8859-1"		
						Endif
					Else
						//MsgAlert( "No errors on Parse! - UTF-16BE" )
						cEncoding	:= "UTF-16BE"
					Endif
				Else
					//MsgAlert( "No errors on Parse! - UTF-16LE" )	
					cEncoding	:= "UTF-16LE"
				Endif
			Else
				//MsgAlert( "No errors on Parse! - UTF-16" )
				cEncoding	:= "UTF-16"
			Endif
		Else
			//MsgAlert( "No errors on Parse! - UTF-8" )
			cEncoding	:= "UTF-8"
		Endif
	Else
		//MsgAlert( "No errors on Parse!" )
		cEncoding	:= "UTF-8"
	Endif
	// Identifica a real codificação do XML e força alteração para xmlparser rodar corretamente
	cInXmlNFSE	:= StrTran(cInXmlNFSE,'encoding="UTF-8"','encoding="'+cEncoding +'"')

	//Aviso("cInXmlNFSE ",cInXmlNFSE,{"Ok"},3)

	cAviso	:= ""
	cErro	:= ""
	oNfse 	:= XmlParser(cInXmlNFSE,"_",@cAviso,@cErro)

	If !Empty(cAviso) .Or. !Empty(cErro)
		MsgAlert(cAviso+"||"+cErro)
	Endif

	// NUMNF - Número da Nota 
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Numero") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Numero:TEXT
		Aadd(aRetDados,{"NUMNF", xVar})
		aChvNFSe[6]	:= StrZero(Val(xVar),9)
	Else
		cMsgOutErr += ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + "|NUMNF|oNFse:_CompNfse:_ListaNfse:_CompNfse:_Nfse:_InfNfse:_Numero"
	Endif

	// CDVER - Código de Verificação 
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao:TEXT
		Aadd(aRetDados,{"CDVER", xVar})
	Else
		cMsgOutErr += ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + "|CDVER|oNFse:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao"
	Endif

	// EMISS - Data de Emissão da Nota de Serviço 
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DataEmissao") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DataEmissao:TEXT
		xVar := StrTran(Alltrim(Substr(xVar,1,10)),"-","") // 2017-06-10T09:23:55
		aChvNFSe[2]	:= Substr(xVar,3,4) // AAMM
		xVar := STOD(xVar)			
		Aadd(aRetDados,{"EMISS", xVar}) 		
	Else
		cMsgOutErr += ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + "|EMISS|oNFse:_CompNfse:_Nfse:_InfNfse:_DataEmissao"
	Endif

	// RPNUM - Número do RPS
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:__IdentificacaoRps:_Numero") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Numero:TEXT
		Aadd(aRetDados,{"RPNUM", xVar})
		aChvNFSe[7]	:= StrZero(Val(xVar),9)
	Else
		cMsgOutErr += ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + "|RPNUM|oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Numero"
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Serie") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Serie:TEXT
		Aadd(aRetDados,{"RPSER", xVar})
		aChvNFSe[5]	:= "001"
	Else
		cMsgOutErr += ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) + "|RPSER|oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Serie"
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Tipo") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_IdentificacaoRps:_Tipo:TEXT
		Aadd(aRetDados,{"RPTIP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DataEmissaoRps") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DataEmissaoRps:TEXT
		Aadd(aRetDados,{"RPEMI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Competencia") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Competencia:TEXT
		Aadd(aRetDados,{"RPREF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorServicos") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorServicos:TEXT
		Aadd(aRetDados,{"SVVLR", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorIss") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorIss:TEXT
		Aadd(aRetDados,{"SVISS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorIss") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorIss:TEXT
		Aadd(aRetDados,{"VLRIS", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorLiquidoNfse") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_ValorLiquidoNfse:TEXT
		Aadd(aRetDados,{"VLIQD", Val(xVar)})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_Aliquota") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_Aliquota:TEXT
		Aadd(aRetDados,{"SVALQ", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_IssRetido") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_IssRetido:TEXT
		Aadd(aRetDados,{"SVISR", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Servico:_Valores:_BaseCalculo") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Valores:_BaseCalculo:TEXT
		Aadd(aRetDados,{"BASEC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	
	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cnpj") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cnpj:TEXT
		Aadd(aRetDados,{"PRCGC", xVar})
		aChvNFSe[3]	:= StrZero(Val(xVar),14)
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_InscricaoMunicipal") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_InscricaoMunicipal:TEXT
		Aadd(aRetDados,{"PRINM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial:TEXT
		Aadd(aRetDados,{"PRNOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Endereco") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Endereco:TEXT
		Aadd(aRetDados,{"PREND", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Numero") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Numero:TEXT
		Aadd(aRetDados,{"PRNRO", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Complemento") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Complemento:TEXT
		Aadd(aRetDados,{"PRCOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Bairro") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Bairro:TEXT
		Aadd(aRetDados,{"PRBAI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_CodigoMunicipio") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"PRMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Uf") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Uf:TEXT
		Aadd(aRetDados,{"PRUF", xVar})
		aChvNFSe[1]	:= aUF[aScan(aUF,{|x| x[1] == xVar})][02]
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Cep") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_Endereco:_Cep:TEXT
		Aadd(aRetDados,{"PRCEP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_CodigoMunicipio") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"OGMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_Uf") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_OrgaoGerador:_Uf:TEXT
		Aadd(aRetDados,{"OGUF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:TEXT
		Aadd(aRetDados,{"TMCGC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_RazaoSocial") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_RazaoSocial:TEXT
		Aadd(aRetDados,{"TMNOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Endereco") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Endereco:TEXT
		Aadd(aRetDados,{"TMEND", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Numero") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Numero:TEXT
		Aadd(aRetDados,{"TMNRO", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Complemento") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Complemento:TEXT
		Aadd(aRetDados,{"TMCOM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif
	
	If Type("oNFse:_CompNfse:_Nfse:_Tomador:_Endereco:_Bairro") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Bairro:TEXT
		Aadd(aRetDados,{"TMBAI", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_CodigoMunicipio") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"TMMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Uf") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Uf:TEXT
		Aadd(aRetDados,{"TMUF", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Cep") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_Tomador:_Endereco:_Cep:TEXT
		Aadd(aRetDados,{"TMCEP", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ResponsavelRetencao") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ResponsavelRetencao:TEXT
		Aadd(aRetDados,{"SVRRT", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ItemListaServico") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ItemListaServico:TEXT
		Aadd(aRetDados,{"SVCOD", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoCnae") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoCnae:TEXT
		Aadd(aRetDados,{"SVCNA", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Discriminacao") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Discriminacao:TEXT
		Aadd(aRetDados,{"SVDES", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoMunicipio") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_CodigoMunicipio:TEXT
		Aadd(aRetDados,{"SVMUN", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ExigibilidadeISS") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_ExigibilidadeISS:TEXT
		Aadd(aRetDados,{"SVEXG", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_MunicipioIncidencia") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_MunicipioIncidencia:TEXT
		Aadd(aRetDados,{"SVINC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_CpfCnpj:_Cnpj") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_CpfCnpj:_Cnpj:TEXT
		Aadd(aRetDados,{"PRCGC", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	If Type("oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_InscricaoMunicipal") <> "U"
		xVar := oNFse:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Prestador:_InscricaoMunicipal:TEXT
		Aadd(aRetDados,{"PRINM", xVar})
	Else
		MsgAlert(xVar,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Endif

	


	aChvNFSe[8]	:= Modulo11(aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7])

	cInChave := aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7]+ cValToChar(aChvNFSe[8])

Return 

Static Function sfFileSP(cFile,aRetDados,lMail,oMessage,oServer)

	Local 	cTextOut	:= ""
	Local 	nI 
	Local	aUf			:= {}
	Local	aChvNFSe	:= {,,,"66",,,,}
	Local	nX
	Local	aLinha		:= {}
	Local	aHeader		:= {}
	Local	cChave		:= ""
	Local   oFT   		:= FTXRead():New()
	Local	lRet		:= .T. 
	Local	aArrInf		:= {}
	Local	nList		:= 0
	
	// 1- Código da UF Código da UF do emitente do Documento Fiscal (Tamanho 2 caracteres)
	// 2- Ano e Mês da Emissão (AAMM) Ano e Mês de emissão do NF-e/CT-e (Tamanho 4 caracteres)
	// 3- CNPJ CNPJ do emitente (Tamanho 14 caracteres)
	// 4- Modelo Modelo do Documento Fiscal (Tamanho 2 caracteres)
	// 5- Série Série do Documento Fiscal (Tamanho 3 caracteres)
	// 6- Numero do CTe Número do Documento Fiscal (Tamanho 9 caracteres)
	// 7- Código Numérico Código Numérico que compõe a Chave de Acesso (Tamanho 9 caracteres)
	// 8- Dígito Dígito Verificador da Chave de Acesso (Tamanho 1 caractere)

	ConOut("+"+Replicate("-",58)+"+")
	ConOut(Padr("| Recebimento de XML - NFS-SP - Função MYEMAIL ",59)+"|")
	ConOut(Padr("| Inicio: "+Time(),59)+"|")

	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	BEGIN SEQUENCE
	
	 If ( oFT:ft_fUse( Alltrim(cFile) ) <= 0 ) 
	   Break 
	 EndIf
	 
	While !( oFT:ft_fEof() )
	  	cLinha := oFT:ft_fReadLn()
	    cLinha += ";"
	    cLinha := StrTran(cLinha,";;","; ;")
	    cLinha := StrTran(cLinha,";;","; ;")
	    //Prepara o Cabeçalho
	    If ( oFT:ft_fRecno() == 1 )
	    	aHeader := StrTokArr(cLinha,";")
	    ElseIf (oFT:ft_fRecno() < oFT:ft_fRecCount())
	    	Aadd(aLinha,StrTokArr(cLinha,";"))
	  	EndIf
	  	//MsgAlert(cValToChar( oFT:ft_fRecno() ) + "/" +cLinha,cValTochar(Len(aHeader)))
	    cLinha := "" 
	    oFT:ft_fSkip() 
	End While 
	oFT:ft_fUse() 
	End Sequence
	
	

	For nX := 1 to Len(aLinha)
		
		For nY := 1 to Len(aHeader)
			If Alltrim(aHeader[nY]) == "Nº NFS-e"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"NUMNF", xVar})
				aChvNFSe[6]	:= StrZero(Val(xVar),9)
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10) 
			ElseIf Alltrim(aHeader[nY]) == "Data Hora NFE"
				xVar := CtoD(Substr(aLinha[nX,nY],1,10)) // 06/07/2017 14:22
				Aadd(aRetDados,{"EMISS", xVar})
				aChvNFSe[2]	:= Substr( DTOS(xVar),3,4) // AAMM
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + Substr( DTOS(xVar),3,4) + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Código de Verificação da NFS-e"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"CDVER", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "CPF/CNPJ do Prestador"
				xVar := aLinha[nX,nY] // 61.099.008/0001-41
				xVar := StrTran(xVar,".","")
				xVar := StrTran(xVar,"/","")
				xVar := StrTran(xVar,"-","")	
				Aadd(aRetDados,{"PRCGC", xVar})
				aChvNFSe[3]	:= StrZero(Val(xVar),14)
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Número do RPS"
				xVar := aLinha[nX,nY]
				If Empty(xVar)
					xVar	:= "0"
				Endif
				Aadd(aRetDados,{"RPNUM", xVar})
				aChvNFSe[7]	:= StrZero(Val(xVar),9)
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "UF do Prestador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"PRUF", xVar})
				aChvNFSe[1]	:= aUF[aScan(aUF,{|x| x[1] == xVar})][02]				
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Série do RPS"
				xVar := aLinha[nX,nY]
				If Empty(xVar)
					xVar	:= "0"
				Endif
				Aadd(aRetDados,{"RPSER", xVar})
				aChvNFSe[5]	:= "001"
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Valor dos Serviços"
				xVar 	:= aLinha[nX,nY]
				xVar 	:= StrTran(xVar,".","")
				xVar 	:= StrTran(xVar,",",".")
				If Empty(xVar)
					xVar	:= "0"
				Endif
				Aadd(aRetDados,{"VLIQD", Val(xVar)})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + xVar + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Código do Serviço Prestado na Nota Fiscal"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"SVCOD", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Discriminação dos Serviços"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"SVDES", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "CPF/CNPJ do Tomador"
				xVar := aLinha[nX,nY] // 61.099.008/0001-41
				xVar := StrTran(xVar,".","")
				xVar := StrTran(xVar,"/","")
				xVar := StrTran(xVar,"-","")	
				Aadd(aRetDados,{"TMCGC", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Razão Social do Prestador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"PRNOM", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Cidade do Prestador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"PRMNU", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "UF do Prestador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"PRUF", xVar})
			ElseIf Alltrim(aHeader[nY]) == "Razão Social do Tomador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"TMNOM", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "Cidade do Tomador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"TMMUN", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			ElseIf Alltrim(aHeader[nY]) == "UF do Tomador"
				xVar := aLinha[nX,nY]
				Aadd(aRetDados,{"TMUF", xVar})
				cTextOut	+= aRetDados[Len(aRetDados)][1] + " : " + aRetDados[Len(aRetDados)][2] + Chr(13) + Chr(10)
			Endif
			//"Email do Prestador"
			//"Alíquota"
			//"ISS devido"
			//"Valor do Crédito"
		Next nY
		aChvNFSe[8]	:= Modulo11(aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7])

		cChave := aChvNFSe[1]+aChvNFSe[2]+aChvNFSe[3]+aChvNFSe[4]+aChvNFSe[5]+aChvNFSe[6]+aChvNFSe[7]+ cValToChar(aChvNFSe[8])
		
		If !sfGrvNFSe(cChave,aRetDados,"",lMail,oMessage,oServer)
			cObs := "Observações " + DTOC(DATE()) + " - " + TIME() + "h" + CRLF
			cObs += "Linha: "	+ cValToChar(nX + 1)	+ CRLF//Primeira linha é cabeçalho
			cObs += "Arquivo: "	+ cFile 				+ CRLF
			cObs += "Usuário: " 	+ CUSERNAME			+ CRLF
			MsgAlert(cObs)
			lRet	:= .F. 
		Else
			cObs := "Observações " + DTOC(DATE()) + " - " + TIME() + "h" + CRLF
			cObs += "Linha: "	+ cValToChar(nX + 1)	+ CRLF//Primeira linha é cabeçalho
			cObs += "Arquivo: "	+ cFile 				+ CRLF
			cObs += "Chave : " + cChave + CRLF
			cObs += cTextOut
			//MsgAlert(cObs)
		EndIf
		Aadd(aArrInf,cObs)
		
		// Zera valores
		aChvNFSe	:= {,,,"66",,,,}
		aRetDados	:= {}
		cTextOut	:= ""
			
	Next nX
	
	
	DEFINE MSDIALOG oNFSeFile FROM 001,001 TO 480,950 OF oMainWnd PIXEL TITLE OemToAnsi("Dados processados do arquivo "+cFile)
	
	oList := TListBox():Create(oNFSeFile,030,010,{|u|if(Pcount()>0,nList:=u,nList)},;
                           aArrInf,460,200,,,,,.T.)
    
	ACTIVATE MSDIALOG oNFSeFile ON INIT EnchoiceBar(oNFSeFile,{|| oNFSeFile:End()},{|| oNFSeFile:End()},,) CENTERED
	
	
	                       
Return lRet


