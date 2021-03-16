#Include "Protheus.Ch" 
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : JBEST001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Integração via FTP de movimentação interna
Autor       : Renato Rezende 
Cliente		: Perdue
Data/Hora   : 23/07/2017
*/                          
*-------------------------*
 User Function JBEST001()
*-------------------------*
Local aTables		:= {"SA2","SA1","SD3","SB1","SB2","SF1","SD1"}
Local nR			:= 0
Local lProcessa		:= .F.
Local lLog			:= .F.

Private lConecta	:= .F.
Private lJob		:= Select("SX3")<=0 
Private aDownload	:= {}
Private cArqLog		:= ""
Private cDirServ	:= ""
Private cDirSOut	:= ""
Private cLogArq		:= ""
Private nCtbl		:= 2
Private xPreSel

//Fonte para utilizar via Job também
If lJob
	RpcClearEnv()//Limpa o ambiente, liberando a licença e fechando as conexões
	RpcSetType(3)
	RpcSetEnv( "JB","01", , ,"EST", "JBEST001" ,aTables, , , , )
Else
	If cEmpAnt $ "JB"
		MsgInfo("Empresa não autorizada para utilizar a rotina.","HLB BRASIL")
		Return
	EndIf
EndIf

//Conexão com o FTP
lConecta := ConectaFtp()

If lConecta
	//Download do Arquivo
	aDownload:= DownloadFtp("D")
	
	//Arquivo está no servidor para processamento
	For nR:=1 to Len(aDownload)
		If aDownload[nR][1]
			lProcessa:=.T.
			//Processar arquivo
			GravMov(aDownload[nR])
		EndIf
	Next nR
	
EndIf

//Encerra conexão com FTP
If lConecta
	FTPDisconnect()
EndIf
//Conexão com o FTP
lConecta := ConectaFtp()

If lConecta
	If lProcessa
   		//Gera aquivo de log
  		lLog:= GeraLog()
	
   		//Envio de email do processamento.
		MailLog()

		//Deleta arquivo no ftp
		DownloadFtp("E")
		
		//Manipulação dos arquivos
		ProcArq()
		
	EndIf
EndIf

//Encerra conexão com FTP
If lConecta
	FTPDisconnect()
EndIf

If lJob
	RpcClearEnv()
EndIf

Return

/*
Funcao		: ConectaFTP
Objetivo	: Conexão ao servidor FTP
Autor		: Renato Rezende
*/
*--------------------------------*
 Static Function ConectaFTP()
*--------------------------------*  
Local lRet 		:= .T.
 
Local nR		:= 0
Local nTry 		:= 3

Local cFtp		:= AllTrim(SuperGetMv("MV_P_FTP" , .F. , ""	, ))
Local cLogin	:= AllTrim(SuperGetMv("MV_P_USR" , .F. , ""	, ))
Local cPass		:= AllTrim(SuperGetMv("MV_P_PSW" , .F. , ""	, ))//he7RU&ra

For nR := 1 To nTry 
	If (lRet := FTPConnect(cFtp,,cLogin,cPass))
		Exit
	EndIf   
	Sleep(5000)
Next nR

If !lRet
	If lJob
		Conout("Fonte JBEST001: Falha ao conectar no FTP")
	Else
		MsgInfo("Falha ao conectar ao FTP.","HLB BRASIL")
	EndIf
EndIf

Return(lRet)

/*
Funcao		: DownloadFTP
Parâmetro	: cTipo D - Download / E - Exclusão
Objetivo	: Download no FTP do arquivo para processamento
Retorno		: aRet 
Autor		: Renato Rezende
*/
*------------------------------------*
 Static Function DownloadFTP(cTipo)
*------------------------------------*  
Local aRet 		:= {}
Local aArqFTP	:= {}
Local nR		:= 0

//Diretorios no FTP do cliente
Local cDirFtpIn := "/IN"
Local cDirFtpout:= "/OUT"

cDirServ	:= "\FTP\"+cEmpAnt+"\JBEST001\IN\"

//Verifica pasta no servidor para salvar o arquivo
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir(cDirServ) 	
	ElseIf !ExistDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir(cDirServ)	
	ElseIf !ExistDir(cDirServ)
   		MakeDir(cDirServ)
 	ElseIf !ExistDir(cDirServ+"processados")
 		MakeDir(cDirServ+"processados")
	EndIf	
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
	MakeDir("\FTP\"+cEmpAnt+"\JBEST001")	
	MakeDir(cDirServ)
	MakeDir(cDirServ+"processados")
EndIf

If !ExistDir(cDirServ)
	conout("Fonte JBEST001: Falha ao carregar diretório FTP IN no Servidor!")
	AaDD(aRet,{ .F.})
	Return aRet
EndIf

//Download dos arquivos
If cTipo == "D"
	FtpDirChange(cDirFtpIn)
	
	aArqFTP:= FtpDirectory( "*.*" , )
	
	//Sem arquivo no FTP
	If Empty(aArqFTP)
		conout("Fonte JBEST001: Não possui arquivo no FTP! "+cTipo)
		AaDD(aRet,{ .F.})
		Return aRet
	EndIf
	For nR:= 1 to Len(aArqFTP)
		FtpDownload( cDirServ+aArqFTP[nR][1] ,aArqFTP[nR][1] )
		AaDD(aRet,{.T., cDirServ, aArqFTP[nR][1]})
	Next nR

//Exclusão dos arquivos
ElseIf cTipo == "E"
	FtpDirChange(cDirFtpIn)
	For nR:= 1 to Len(aDownload)
		If !FTPErase(aDownload[nR][3])
			conout("Fonte JBEST001: Nao foi possivel excluir arquivo do FTP. "+cTipo)
		EndIf
	Next nR
	
	//Envia Log para pasta out do FTP
	FtpDirChange(cDirFtpOut)
	If !FTPUpload(cDirSOut+cLogArq,cLogArq)
		conout( "Fonte JBEST001: Nao foi possivel realizar o upload. "+cTipo)
	EndIf
EndIf

Return aRet

/*
Funcao		: GravMov
Parametros  : aMov
Objetivo	: Executa Movimentação Interna
Autor		: Renato Rezende
*/
*--------------------------------*
 Static Function GravMov(aMov)
*--------------------------------*
Local cLinha	:= ""
Local cArquivo	:= aMov[2]+aMov[3]
Local cCampos	:= "" 
Local cChvNfe	:= ""

Local nLin		:= 0
Local nR		:= 0
Local nRe		:= 0
Local nNa		:= 0
Local nQtdOri	:= 0
Local nQtdFim	:= 0
Local nValor	:= 0
Local nDescont	:= 0
Local nValCusto	:= 0

Local aLinhas	:= {}
Local aCpoObg	:= {}
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local aConteudo	:= {}

Local lExecuta	:= {}
Local lErro		:= .F.
Local lGrvInt	:= .T.
Local lGrvFin	:= .T.

Local dDtArq	:= CtoD("//")

Private lMsHelpAuto		:= .T. //Se .T. direciona as mensagens de help
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .F. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

/*
aMov[1] - Encontrou Arquivo
aMov[2] - Caminho Servidor
aMov[3] - Nome do Arquivo
*/

//Verifica se o arquivo existe
If !File(cArquivo)
	Return
EndIf

//Verifica se o arquivo já foi processado
If ViewZX1(aMov[3])
	cArqLog+= "Arquivo já processado: "+Alltrim(aMov[3]) + Chr( 13 ) + Chr( 10 )                                                     
	GravaLog("SD3",aMov[3],cArqLog)
	Return
EndIf

FT_FUse(cArquivo)//Abre o arquivo
FT_FGOTOP()// Posiciona no inicio do arquivo

While !FT_FEof()
	nLin++
	If nLin>=3
		cLinha := FT_FReadln()// Le a linha
		aLinha := Separa(UPPER(cLinha),";")// Sepera para vetor
		If !Empty(aLinha)
			AaDD(aConteudo,aLinha)
		EndIf	
	EndIf
	FT_FSkip()//Proxima linha
EndDo

FT_FUse()//Fecha o arquivo

//Arquivo possui linha para integração
If !Empty(aConteudo)
		
	For nRe:= 1 to Len(aConteudo)
	
		//Limpando variáveis
		cChvNfe		:= ""
		nQtdOri		:= 0
		nQtdFim		:= 0
		nValor		:= 0
		nDescont	:= 0
		aCpoObg		:= {}
		lErro		:= .F.
		dDataBase	:= Date()
		dDtArq		:= CtoD("//")
		lMsErroAuto := .F.

		//Valida linha do arquivo
		cChvNfe		:= Alltrim(SubStr(StrTran(aConteudo[nRe][7],'"',""),4,44))
		nQtdOri		:= Val(StrTran((StrTran(aConteudo[nRe][12],'"',"")),",","."))
		nQtdFim		:= Val(StrTran(StrTran(aConteudo[nRe][11],'"',""),",","."))
		nValor		:= Val(StrTran(StrTran(StrTran(aConteudo[nRe][15],'"',""),",",""),"$",""))
		nDescont	:= (nQtdOri-nQtdFim)*nValor
		dDtArq		:= CtoD(StrTran(aConteudo[nRe][1],'"',""))
		
		AaDD(aCpoObg,{"Chave Nfe"	,cChvNfe})
		AaDD(aCpoObg,{"Qtd. Ori."	,nQtdOri})
		AaDD(aCpoObg,{"Qtd. Fim"	,nQtdFim})
		AaDD(aCpoObg,{"Valor"		,nValor})
		AaDD(aCpoObg,{"Ticket Data"	,dDtArq})
		
		//Valida campos obrigatorios do arquivo
		For nNa:= 1 to Len(aCpoObg)
			If Empty(aCpoObg[nNa][2])
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+", campo "+aCpoObg[nNa][1]+" obrigatorio em branco." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
		Next nNa

		//Busca nota fiscal pela chave e retorna o alias TEMP
		lExecuta:= ConsNFE(cChvNfe)
        
		If lExecuta
			//Altera data base do sistema
			If dDtArq >= StoD(TEMP->F1_DTDIGIT)
				dDataBase:= dDtArq
			Else
				dDataBase:= StoD(TEMP->F1_DTDIGIT)
			EndIf
			
			If nQtdOri < TEMP->D1_QUANT
				//Convertendo Tonelada para KG
				nQtdOri:= nQtdOri*1000
				nQtdFim	:= nQtdFim*1000
				nValor	:= nValor/1000
				nDescont:= Round((nQtdOri-nQtdFim)*nValor, TamSx3("E2_DECRESC")[2])
			EndIf
			If nQtdOri < TEMP->D1_QUANT
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+" com quantidade original diferente da nota fiscal." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
			If nQtdOri > TEMP->D1_QUANT 
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+" com quantidade original diferente da nota fiscal." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
			If !(nQtdOri == TEMP->D1_QUANT)
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+" com quantidade original diferente da nota fiscal." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
			//Diferenca nao pode ser maior
			If nQtdOri < nQtdFim
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+" com quantidade maior a original do arquivo." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
			//Arquivo sem diferença 
			If nQtdOri == nQtdFim
				cArqLog+= "Linha: "+ Alltrim(cValToChar(nRe))+" com quantidade igual a original do arquivo." + Chr( 13 ) + Chr( 10 )
				lErro:= .T.
			EndIf
		EndIf
				
		//Encontrou erro vai para proxima linha
		If lErro
			Loop
		EndIf     
		
		If TEMP->(!Eof()) .AND. lExecuta
			
			aCabec		:= {}
			aItem		:= {}
			aItens		:= {}
			nValCusto	:= 0
			
			//Tipo da Movimentação
			cTM:= "503"
			//cTM:= "501"
			
			nValCusto:= Round((nQtdOri-nQtdFim)*TEMP->CUSTO, TamSx3("D3_CUSTO1")[2])
			
			//Ajuste do Array para o execauto
			AaDD(aCabec,{"D3_FILIAL"	,TEMP->F1_FILIAL		, NIL})
			AaDD(aCabec,{"D3_TM" 		,cTM					, NIL})
			AaDD(aCabec,{"D3_DOC" 		,Alltrim(TEMP->F1_DOC)	, NIL})
			AaDD(aCabec,{"D3_EMISSAO" 	,dDataBase				, NIL})
		    
			AaDD(aItem,{"D3_COD"	,Alltrim(TEMP->D1_COD)			,NIL})
			AaDD(aItem,{"D3_UM"		,Alltrim(TEMP->D1_UM)			,NIL})
			AaDD(aItem,{"D3_QUANT"	,nQtdOri-nQtdFim 				,NIL})
			AaDD(aItem,{"D3_CUSTO1"	,nValCusto						,NIL})
			AaDD(aItem,{"D3_LOCAL"	,TEMP->D1_LOCAL					,NIL})
			AaDD(aItem,{"D3_LOTECTL",TEMP->D1_LOTECTL				,NIL})
			AaDD(aItem,{"D3_DTVALID",StoD(TEMP->D1_DTVALID)			,NIL})

			AaDD(aItens,aItem)   
			
			//Garante a Contabilizao On-Line na Inclusao da movimentacao
			GrvProfSX1("MTA240","01",nCtbl)	
			BEGIN Transaction
				//Chama o execauto
				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aItens,3)
				
				If lMsErroAuto 
		        	//MostraErro()
		        	cArqLog+= "Nota não processada: "+ Alltrim(TEMP->F1_DOC)+", erro interno favor contatar o suporte." + Chr( 13 ) + Chr( 10 )
		        	DisarmTransaction()
				Else
					//Chama função para gravar o desconto no financeiro
					lGrvFin:= GrvFin(nDescont)
					//Reclock F1_P_INT
					lGrvInt:= GrvInt()
					cArqLog+= "Nota processada: "+ Alltrim(TEMP->F1_DOC) + Chr( 13 ) + Chr( 10 )
					
					//Troca o nome da rotina MATA240 para CTBA102 no CT2.(Custo médio deleta os lançamentos da rotina MATA240)
					TcSqlExec("UPDATE "+RETSQLNAME("CT2")+" SET CT2_ROTINA='CTBA102' WHERE CT2_ROTINA = 'MATA240' AND D_E_L_E_T_ <> '*' AND CT2_DATA='"+DtoS(dDataBase)+"' ")
				EndIf
			END Transaction  
	 		//Restaura o parametro da Contabilizacao selecionado anteriormente
			GrvProfSX1("MTA240","01",xPreSel)
       	EndIf
	Next nRe
	
	//Grava na Tabela de Log	
	GravaLog("SD3",aMov[3],cArqLog)
Else
	cArqLog+= "Arquivo não possui linha para processamento: "+Alltrim(aMov[3]) + Chr( 13 ) + Chr( 10 )
	//Grava na Tabela de Log	
	GravaLog("SD3",aMov[3],cArqLog)
EndIf

Return

/*
Funcao      : GravaLog 
Parametros  : cAlias,cNomeArq,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX1 arquivo de log
Autor       : Renato Rezende
*/
*-----------------------------------------------------*
 Static Function GravaLog(cAlias,cNomeArq,cArqLog)
*-----------------------------------------------------*
Local cIncAlt	:= ""

//Cria Tabela de Log
ChkFile("ZX1")

DbSelectArea("ZX1")
ZX1->(DbSetOrder(1))
ZX1->(RecLock("ZX1",.T.))
	ZX1->ZX1_FILIAL := xFilial("ZX1")
	ZX1->ZX1_ALIAS	:= cAlias 
	ZX1->ZX1_DATA	:= Date()
	ZX1->ZX1_TIME	:= Time()  
	ZX1->ZX1_ARQ	:= cNomeArq 
	ZX1->ZX1_ERRO	:= cArqLog
ZX1->(MsUnlock())

Return .T.

/*
Funcao      : ConsNFE 
Parametros  : cChave
Retorno		: lRet
Objetivos   : Consulta Nota no sistema
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function ConsNFE(cChave)
*------------------------------------*
Local cQuery	:= ""
Local cChvnfe	:= cChave
Local cTMP		:= ""
Local aStruSF1	:= SF1->(DbStruct())
Local aStruSD1	:= SD1->(DbStruct())
Local nX		:= 0
Local lRet		:= .T.

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

cQuery := " SELECT F1_FORNECE,F1_LOJA,F1_EMISSAO,F1_DTDIGIT,F1_DUPL,F1_EST,F1_FRETE,F1_MENNOTA,F1_COND,F1_DOC,F1_SERIE,F1_FILIAL,F1_COND,F1_TIPO,F1_PREFIXO,F1_P_INT, " + CRLF
cQuery += " 	   D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_PEDIDO,D1_QUANT,D1_TOTAL,D1_VUNIT,D1_COD,D1_UM,D1_ITEM,D1_LOCAL,D1_LOTECTL,D1_DTVALID, " + CRLF
cQuery += "		   (Case When D1_CUSTO = 0 Then D1_CUSTO Else D1_CUSTO/D1_QUANT End) AS CUSTO " + CRLF
cQuery += "   FROM "+RETSQLNAME("SF1")+" AS SF1 "+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD1")+" AS SD1 ON SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE+SD1.D1_FORNECE+SD1.D1_LOJA=SF1.F1_FILIAL+SF1.F1_DOC+SF1.F1_SERIE+SF1.F1_FORNECE+SF1.F1_LOJA " + CRLF
cQuery += "  WHERE SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' AND SF1.F1_CHVNFE = '"+Alltrim(cChvnfe)+"'" + CRLF

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

//Verifica quantos registros retornaram na consulta
Count to nRecCount

//Volta primeiro registro
QRY->(DbGoTop())

//Caso a nota tenha mais de 1 item não será processado
If nRecCount >= 2
	cArqLog+= "Nota não processada: "+ Alltrim(QRY->F1_DOC)+", possui mais de 1 item na nota." + Chr( 13 ) + Chr( 10 )
	lRet:= .F.
ElseIf nRecCount <= 0
	cArqLog+= "Nota não processada: "+ Alltrim(QRY->F1_DOC)+", chave da nota não encontrada." + Chr( 13 ) + Chr( 10 )
	lRet:= .F.
EndIf

//Validando nota
If lRet
	//Nota já processada anteriormente
	If QRY->F1_P_INT == "S"
		cArqLog+= "Nota não processada: "+ Alltrim(QRY->F1_DOC)+", nota já processada anteriormente." + Chr( 13 ) + Chr( 10 )
		lRet:= .F.		
	EndIf
EndIf

If Select("TEMP") > 0
	TEMP->(DbCloseArea())
EndIf

//Criando tabela temporária com o retorno do alias QRY
cTMP := CriaTrab(NIL,.F.)
//Copia os registros para a tabela temporaria 
Copy To &cTMP  
DbUseArea(.T.,,cTMP,"TEMP",.F.,.F.)

TEMP->(DbGoTop())

Return lRet

/*
Funcao      : ViewZX1
Parametros  : cArq
Retorno     : lRet
Objetivos   : Verifica se o arquivo ja consta no Log de processados.
Autor       : Renato Rezende
*/
*------------------------------*
 Static Function ViewZX1(cArq)
*------------------------------*
Local lRet 		:= .F.
Local cQuery	:= ""

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

cQuery := " SELECT COUNT(*) AS COUNT"
cQuery += "  FROM "+RETSQLNAME("ZX1")
cQuery += " WHERE UPPER(ZX1_ARQ) = '"+ALLTRIM(UPPER(cArq))+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : Compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Renato Rezende
*/
*--------------------------------------------------*
 Static Function Compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : MailLog
Objetivos   : Envia email de processamento
Autor       : Renato Rezende
*/
*-----------------------------*
 Static Function MailLog()
*-----------------------------*
Local cFrom			:= AllTrim(SuperGetMv("MV_RELFROM",.F., ""))//Email de origem
Local cPassword 	:= AllTrim(SuperGetMv("MV_RELPSW" ,.F., ""))
Local lAutentica	:= SuperGetMv("MV_RELAUTH",.F.,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local cUserAut  	:= Alltrim(SuperGetMv("MV_RELAUSR",.F., ""))//Usuário para Autenticação no Servidor de Email
Local cPassAut  	:= Alltrim(SuperGetMv("MV_RELAPSW",.F., ""))//Senha para Autenticação no Servidor de Email
Local cAccount		:= AllTrim(SuperGetMv("MV_RELACNT",.F.,	""))
Local cServer		:= AllTrim(SuperGetMv("MV_RELSERV",.F.,	""))
Local cTo 			:= AllTrim(SuperGetMv("MV_P_00106",.F., ""))//Email que será enviado o log de processamento.
Local cCC			:= ""
Local cToOculto		:= ""
Local cAttachment 	:= ""
Local cArqMail 		:= ""
Local cSubject		:= "Processamento Arquivo - PERDUE "+DtoC(Date())

Private cMsg  := ""
Private cDate := DtoC(Date())
Private cTime := SubStr(Time(),1,5)
Private cUser := UsrFullName(RetCodUsr())

If Empty(cServer)
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	Return .F.
EndIf

If Empty(cAccount)
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	Return .F.
EndIf

cAttachment	:= UPPER(cDirSOut+cLogArq) 

//Corpo do Email
cMsg := Email()

//Conexão com o servidor de email
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	Return .F.
Else
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			Return .F.
		EndIf
	EndIf
	
	//Envio do email
	SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
	SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK

	If !lOK
		ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
		DISCONNECT SMTP SERVER
		Return .F.
	EndIf
EndIf

DISCONNECT SMTP SERVER

Return .T.

/*
Funcao      : Email
Retorno     : cHtml
Objetivos   : Criar corpo do email de notificação
Autor       : Renato Rezende
*/
*-------------------------*
 Static Function Email()
*-------------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>WORKFLOW PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">QTD. ARQS.: '+AllTrim( Str( Len( aDownload ) ) )+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml

/*
Funcao      : GrvFin 
Parametros  : nValor
Retorno     : lRet
Objetivos   : Altera título no financeiro incluindo desconto
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function GrvFin(nValor)
*------------------------------------*
Local lRet	:= .T.
Local cQryUp:= ""
Local cQry	:= ""
Local nExec	:= 0

If Select("TSE2") > 0
	TSE2->(DbCloseArea())
EndIf

cQry	:= " SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_BAIXA, E2_EMISSAO, E2_DECRESC,E2_NUMBOR  " + CRLF
cQry	+= "   FROM "+RETSQLNAME("SE2") + CRLF
cQryUp	:= "  WHERE E2_FILORIG+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_TIPO = '"+TEMP->F1_FILIAL+TEMP->F1_FORNECE+TEMP->F1_LOJA+TEMP->F1_PREFIXO+TEMP->F1_DOC+"NF'  " + CRLF
cQryUp	+= "   AND D_E_L_E_T_ <> '*' " + CRLF

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry+cQryUp),"TSE2",.F.,.T.)

Count to nRecCount
TSE2->(DbGoTop())

If nRecCount == 1
	If Empty(TSE2->E2_BAIXA)
		If Empty(TSE2->E2_NUMBOR)
			nExec:= TcSqlExec("UPDATE "+RETSQLNAME("SE2")+" SET E2_DECRESC=E2_DECRESC+"+Alltrim(cValToChar(nValor))+",E2_SDDECRE=E2_DECRESC+"+Alltrim(cValToChar(nValor))+cQryUp)
			//nExec:= TcSqlExec("UPDATE "+RETSQLNAME("SE2")+" SET E2_DECRESC="+Alltrim(cValToChar(nValor))+",E2_SDDECRE="+Alltrim(cValToChar(nValor))+cQryUp)
			If !(nExec < 0)
				cArqLog+= "Gravou desconto, título "+Alltrim(TSE2->E2_NUM)+" encontrado." + Chr( 13 ) + Chr( 10 )
			Else
				cArqLog+= "Não gravou desconto no título "+Alltrim(TSE2->E2_NUM)+", erro interno." + Chr( 13 ) + Chr( 10 )		
			EndIf
		Else
			cArqLog+= "Não gravou desconto no título "+Alltrim(TSE2->E2_NUM)+", título em bordeirô." + Chr( 13 ) + Chr( 10 )
		EndIf
	Else
		cArqLog+= "Não gravou desconto no título "+Alltrim(TSE2->E2_NUM)+", título baixado." + Chr( 13 ) + Chr( 10 )				
	EndIf
ElseIf nRecCount <=0
	cArqLog+= "Não gravou desconto, título "+Alltrim(TSE2->E2_NUM)+" não encontrado." + Chr( 13 ) + Chr( 10 )
EndIF

Return lRet 

/*
Funcao      : GeraLog
Retorno     : lRet
Objetivos   : Gera arquivo de log no servidor
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function GeraLog()
*------------------------------------*
Local nHdl	:= 0
Local lRet	:= .T.

cDirSOut	:= "\FTP\"+cEmpAnt+"\JBEST001\OUT\"

//Verifica pasta no servidor para salvar o arquivo de log
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir(cDirSOut) 	
	ElseIf !ExistDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir("\FTP\"+cEmpAnt+"\JBEST001")
		MakeDir(cDirSOut)	
	ElseIf !ExistDir(cDirSOut)
   		MakeDir(cDirSOut)
 	ElseIf !ExistDir(cDirSOut+"processados")
 		MakeDir(cDirSOut+"processados")
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
	MakeDir("\FTP\"+cEmpAnt+"\JBEST001")	
	MakeDir(cDirSOut)   
	MakeDir(cDirSOut+"processados")
EndIf

If !ExistDir(cDirSOut)
	conout("Fonte JBEST001: Falha ao carregar diretório FTP OUT no Servidor!")
	lRet:= .F.
	Return lRet
EndIf

cLogArq	:= "Log_SD3_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".txt"

nHdl := FCREATE(cDirSOut+cLogArq,0 )  //Criação do Arquivo txt.

//Testa se o arquivo foi gerado 
If nHdl == -1
	conout("Fonte JBEST001: O arquivo "+cLogArq+" nao pode ser criado.")
	lRet:= .F.
	Return lRet
EndIf

//Escreve o log do arquivo
fWrite(nHdl,cArqLog)
//Fecha o Arquivo que foi Gerado
fClose(nHdl)

Return lRet

/*
Funcao      : ProcArq
Objetivos   : Movimenta arquivos para pasta processados
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function ProcArq()
*------------------------------------* 
Local nR:= 0

//IN - Copia para a pasta processados
For nR:= 1 to Len(aDownload)
	__COPYFILE(cDirServ+Alltrim(aDownload[nR][3]), cDirServ+"processados\" + Alltrim(aDownload[nR][3]))
	//Exclui da raiz	
	FERASE(cDirServ+Alltrim(aDownload[nR][3]))
Next nR

//Compacta a pasta processados IN
If Compacta(cDirServ+"processados\*.csv" , cDirServ+"processados\processados.rar")
	conout("Fonte JBEST001: Pasta Zipada "+cDirServ+"processados\")
EndIf 

//OUT - Copia para a pasta processados
__COPYFILE(cDirSOut+cLogArq, cDirSOut+"processados\"+cLogArq)
//Exclui da raiz	
FERASE(cDirSOut+cLogArq)

//Compacta a pasta processados OUT
If Compacta(cDirSOut+"processados\*.txt" , cDirSOut+"processados\processados.rar")
	conout("Fonte JBEST001: Pasta Zipada "+cDirSOut+"processados\")
EndIf 

Return Nil

/*
Função  	: GrvProfSX1()
Parametros  : cGrupo,cPerg,xValor
Objetivo	: Altera o valor do pergunte no SX1
Autor  		: Renato Rezende
Data   		: 30/07/2017
*/
*-------------------------------------------------*
 Static Function GrvProfSX1(cGrupo,cPerg,xValor)
*-------------------------------------------------*
Local cUserName := ""
Local cMemoProf := ""
Local cLinha    := ""

Local nLin := 0

Local aLinhas := {}

cGrupo := PadR(cGrupo,Len(SX1->X1_GRUPO)," ")

SX1->(DbSetOrder(1))
If SX1->(DbSeek(cGrupo+cPerg,.F.))

	If Type("__cUserId") == "C" .and. !Empty(__cUserId)
		PswOrder(1)
  		PswSeek(__cUserID)
		cUserName := cEmpAnt+PswRet(1)[1,2]
	    
		//Pesquisa o pergunte no Profile
		If FindProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")
            
			//Armazena o memo de parametros do pergunte
			cMemoProf := RetProfDef(cUserName,cGrupo,"PERGUNTE","MV_PAR")

			//Gera array com todas as linhas dos parametros	        
			For nLin:=1 To MlCount(cMemoProf)
				aAdd(aLinhas,AllTrim(MemoLine(cMemoProf,,nLin))+ CHR(13) + CHR(10))
			Next
			
			//Guarda o back-up do valor do parâmetro selecionado
			xPreSel := Substr(aLinhas[Val(cPerg)],5,1) 
			
			//Monta uma linha com o novo conteudo do parametro atual.
			// Pos 1 = tipo (numerico/data/caracter...)
			// Pos 2 = '#'
			// Pos 3 = GSC
			// Pos 4 = '#'
			// Pos 5 em diante = conteudo.
            cLinha = SX1->X1_TIPO + "#" + SX1->X1_GSC + "#" + If(SX1->X1_GSC == "C", cValToChar(xValor),AllTrim(Str(xValor)))+ CHR(13) + CHR(10)
			
			//Grava a linha no array
			aLinhas[Val(cPerg)] = cLinha
			
			//Monta o memo atualizado
			cMemoProf := ""
			For nLin:=1 To Len(aLinhas)
   				cMemoProf += aLinhas[nLin]
       		Next
            
			//Grava o profile com o novo memo
			WriteProfDef(cUserName,cGrupo,"PERGUNTE", "MV_PAR", ; 	// Chave antiga
                    	 cUserName,cGrupo, "PERGUNTE", "MV_PAR", ; 	// Chave nova
     					 cMemoProf) 								// Novo conteudo do memo.
			
		//Caso não exista Profile alterar o SX1
		Else
			//Gravando conteudo antigo
			xPresel:= SX1->X1_PRESEL
			Do Case
				Case SX1->X1_GSC == "C"
					Reclock ("SX1",.F.)
					SX1->X1_PRESEL := Val(cValToChar(xValor))
					SX1->(MsUnlock())
			EndCase
		EndIf
	EndIf
EndIf

Return Nil

/*
Funcao      : GrvInt
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Reclock no campo F1_P_INT
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function GrvInt()
*------------------------------------*
Local lRet	:= .T.

DbSelectArea("SF1")
SF1->(DbSetOrder(1))
If SF1->(DbSeek(xFilial("SF1")+TEMP->F1_DOC+TEMP->F1_SERIE+TEMP->F1_FORNECE+TEMP->F1_LOJA)) 
	RecLock("SF1",.F.)
		SF1->F1_P_INT := "S"
	SF1->(MsUnLock())
Else
	lRet:= .F.
EndIf

Return lRet