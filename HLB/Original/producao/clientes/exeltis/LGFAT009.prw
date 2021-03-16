//Irei incluir algumas bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : LGFAT009
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processar pedidos gravados na tabela ZX2.
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 29/05/2018
*/
*-----------------------------*
 User Function LGFAT009()
*-----------------------------*
Local lImport		:= .F.
Local cMsgEmail		:= ""
Local cSubject		:= ""
Local cAnexos		:= ""
Local cTo			:= ""
Local cToOculto		:= ""

Private lJob		:= (Select("SX3") <= 0)
Private aIntZX3		:= {}
Private cDate 		:= ""
Private cTime 		:= ""
Private cUser 		:= ""
Private cDirFtp 	:= ""

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","HLB BRASIL" )
	Return
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "LG" FILIAL "01" TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"

	cDate 		:= DtoC(Date())
	cTime 		:= SubStr(Time(),1,5)
	cUser 		:= UsrFullName(RetCodUsr())
	cSubject	:= "[EXELTIS] Geração de Nota Fiscal "+DtoC(Date())
	cTo			:= AllTrim(GetMv("MV_P_00040",," "))
	cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))

	//Importar pedidos aprovados na ZX2
	lImport := Import()
	
	//Dispara email de processamento com erro ou não
	If Len(aIntZX3) > 0 
	
		//Monta html da mensagem do email
		cMsgEmail := HtmlPrc()
		//Envia email de processamento
		lEnvia:= EnviaEma(cMsgEmail,cSubject,cTo,cToOculto,cAnexos)
	
	EndIf

	//Encerra o PREPARE ENVIRONMENT
	RpcClearEnv()
EndIf

Return nil

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
Autor       : Renato Rezende
Data/Hora   : 28/05/2018
*/
*--------------------------------------------*
 Static Function HtmlPrc()
*--------------------------------------------*
Local cHtml := ""
Local nR	:= 0

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
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
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
//Download de pedidos aprovados
If Len(aIntZX3) > 0
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">LOG DO PROCESSAMENTO:</font></td>
	cHtml += '			</tr>
	//Log gerado do processamento
	For nR:= 1 to Len(aIntZX3)
		cHtml += '			<tr>
		cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">
		cHtml += '				Mensagem: '+Alltrim(aIntZX3[nR][3])+' <br/>
		cHtml += '				Nota: '+Alltrim(aIntZX3[nR][1])+' / Serie: '+Alltrim(aIntZX3[nR][2])+' /Pedido: '+Alltrim(aIntZX3[nR][5])+' <br/>
		cHtml += '				------------------</font></td>
		cHtml += '			</tr>
	Next nR
EndIf
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
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : lRet
Objetivos   : Conecta e envia e-mail
Autor     	: Renato Rezende
*/
*----------------------------------------------------------------*
 Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*----------------------------------------------------------------*
Local cFrom			:= AllTrim(GetMv("MV_RELFROM"	,,""))
Local cPassword 	:= AllTrim(GetMv("MV_RELPSW"	,,""))
Local cUserAut  	:= Alltrim(GetMv("MV_RELAUSR"	,,""))//Usuário para Autenticação no Servidor de Email 
Local cPassAut  	:= Alltrim(GetMv("MV_RELAPSW"	,,""))//Senha para Autenticação no Servidor de Email
Local cServer		:= AllTrim(GetMv("MV_RELSERV"	,,""))//Nome do Servidor de Envio de Email
Local cAccount		:= AllTrim(GetMv("MV_RELACNT"	,,""))//Conta para acesso ao Servidor de Email
Local cAttachment	:= cAnexos
Local cCC      		:= ""
Local cTo			:= AvLeGrupoEMail(cTo)

Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local lRet			:= .T.

If Empty(cServer)
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	lRet := .F.
EndIf

If Empty(cAccount)
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	lRet := .F.
EndIf

If lRet
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK
	
	If !lOK
		MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
		lRet := .F.
	Else
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				MsgInfo("Falha na Autenticacao do Usuario","HLB BRASIL")
				DISCONNECT SMTP SERVER RESULT lOk
				lRet := .F.
			EndIf
		EndIf
		IF !EMPTY(cCC)
			SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		Else
			SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
			SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		EndIf
		If !lOK
			ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
			lRet := .F.
		ENDIF
	ENDIF
	
	DISCONNECT SMTP SERVER
Else
	MsgInfo("Falha na Conexão com Servidor de E-Mail","HLB BRASIL")
EndIf

Return lRet

/*
Funcao      : Import
Retorno     : lRet
Objetivos   : Leitura e Importação dos pedidos da tabela ZX2
Autor     	: Renato Rezende
*/
*-----------------------------*
Static Function Import()
*-----------------------------*
Local lRet			:= .T.  
Local cFilAntBkp	:= ""
Local cCodAGV		:= ""//Código da Exeltis na AGV
Local cCCAGV		:= ""//Centro de Custo da Exeltis na AGV
Local nPos			:= 0
Local aAllFilial	:= FWAllFilial()
Local aFilAgv		:= {}

DbSelectArea("SX6")
SX6->(DbSetOrder(1))

//Codigo da empresa Protheus x AGV
For nR:= 1 to Len(aAllFilial)
	cCodAGV	:= ""
	cCCAGV	:= ""
	If SX6->(DbSeek(aAllFilial[nR] + "MV_P_CDAGV"))
		cCodAGV:= Alltrim(SX6->X6_CONTEUD)
	EndIf
	If SX6->(DbSeek(aAllFilial[nR] + "MV_P_CCADV"))
		cCCAGV:= Alltrim(SX6->X6_CONTEUD)
	EndIf
	
	Aadd(aFilAgv,{aAllFilial[nR],cCCAGV,cCodAGV})

Next nR

DbSelectArea("ZX2")
ZX2->(DbSetOrder(1))

//Volta primeiro registro
ZX2->(DbGoTop())

If ZX2->(!EOF())

	//Percorre tabela ZX2
	While ZX2->(!EOF())
		nPos:= aScan(aFilAgv,{|x| AllTrim(x[2])+AllTrim(x[3]) == AllTrim(ZX2->ZX2_CCAGV)+Alltrim(ZX2->ZX2_CODAGV)})
		If nPos > 0
			cFilAntBkp:= cFilAnt
			//Troca Filial conforme código enviado pela AGV
			cFilAnt:= aFilAgv[nPos][1] 
		 
			//Processa o Pedido liberado
			lAtuPed := RecPedido(ZX2->(Recno()))	 
			
			cFilAnt := cFilAntBkp
		Else
			//Erro, codigo da empresa nao encontrado no parametro da AGV.
			cStatus	:= "4"
			cMsg	:= "Empresa não encontrada no SIGAMAT"
			GravaLog(cMsg, ZX2->(Recno()), cStatus)
			
			Aadd(aIntZX3,{"","",cMsg,cStatus,ZX2->ZX2_PEDNUM})
		
		EndIf
		ZX2->(DbSkip())
	EndDo
Else
	lRet:= .F.		
EndIf

//Fecha área aberta
ZX2->(DbCloseArea())

Return lRet

/*
Funcao      : RecPedido
Retorno     : lRet
Objetivos   : Atualiza pedido para faturamento da nota
Autor     	: Renato Rezende
*/
*---------------------------------*
Static Function RecPedido(nRecno)
*---------------------------------*
Local aArea		:= GetArea()
Local aAreaC5	:= SC5->(GetArea())
Local aAreaZX2	:= ZX2->(GetArea())
Local aPedido	:= {}
Local lRet		:= .T.
Local cConteudo	:= ""
Local cNumPed	:= ""
Local cEspecie1	:= ""
Local cRet		:= ""
Local cSerieNf	:= AllTrim(GetMv("MV_P_SRNFS"	,,""))
Local nPesol	:= 0
Local nPbruto	:= 0
Local nVolume	:= 0

DbSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
SC5->(DbGoTop())
     
DbSelectArea("ZX2")
ZX2->(DbSetOrder(1))
ZX2->(DbGoTo(nRecno))

cConteudo	:= ZX2->ZX2_TXT
cNumPed		:= ZX2->ZX2_PEDNUM

//Separa o conteudo do campo memo no array
aPedido := StrTokArr(cConteudo,CRLF)

If Len(aPedido) > 0
	cEspecie1	:= Alltrim(SubStr(Alltrim(aPedido[1]),39,2))
	nPesol		:= Val(SubStr(Alltrim(aPedido[1]),83,11))
	nPbruto		:= Val(SubStr(Alltrim(aPedido[1]),83,11))
	nVolume		:= Val(SubStr(Alltrim(aPedido[1]),77,6))

	//Se conseguir posicionar no pedido
	If SC5->(DbSeek(FWxFilial("SC5") + cNumPed))
	    
	    If Empty(SC5->C5_NOTA)
		
			SC5->(RecLock('SC5',.F.))
				SC5->C5_ESPECI1 := cEspecie1
				SC5->C5_PESOL	:= nPesol
				SC5->C5_PBRUTO	:= nPesol
				SC5->C5_VOLUME1 := nVolume
			SC5->(MSunlock())
		    
			//Carrega o array aPvlNfs
			aPvlNfs:={} ;aBloqueio:={}
			Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
			Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
			 //Gera Nota Fiscal de Saida		
			cRet := MaPvlNfs(aPvlNfs ,;
							cSerieNf ,;
							.F. ,; //** Mostra Lancamentos Contabeis
							.F. ,; //** Aglutina Lanuamentos
							.F. ,; //** Cont. On Line ?
							.F. ,; //** Cont. Custo On-line ?
							.F. ,; //** Reaj. na mesma N.F.?
							3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
							1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
							.F.,;  //** Atualiza Cli.X Prod?
							.F. ,,,,,,; //** Ecf ?
							dDataBase )   
			
			//Erro na geração da nota fiscal
			If Empty(cRet)
					cStatus	:= "4"
					cMsg	:= "Problema na geração da nota fiscal."
					GravaLog(cMsg, nRecno, cStatus)

					Aadd(aIntZX3,{"","",cMsg,cStatus,cNumPed})

					lRet	:= .F.
			Else
				cStatus	:= "5"
				cMsg	:= "Faturado com sucesso. Nota:" + Alltrim(cRet) + " Serie: " + Alltrim(cSerieNf)
				GravaLog(cMsg, nRecno, cStatus)
	
				//Pedido Faturado, atualiza o status do C5_P_ENV1 (5)Pedido Faturado
				TcSqlExec("UPDATE " + RetSqlName("SC5") + " SET C5_P_ENV1 = '5' WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND " +;
						  "C5_NUM = '" +SC5->C5_NUM+ "' AND C5_NOTA = '" +SC5->C5_NOTA+ "' ")
				
				Aadd(aIntZX3,{cRet,cSerieNf,cMsg,cStatus,cNumPed})
			EndIf	
		Else
            //Pedido já faturado.
			cStatus	:= "4"
			cMsg	:= "Nota não pode ser gerada. Pedido já foi faturado."
			GravaLog(cMsg, nRecno, cStatus)
			
			Aadd(aIntZX3,{SC5->C5_NOTA,cSerieNf,cMsg,cStatus,cNumPed})
		
		EndIf
	Else
		//Pedido não encontrato
		cStatus	:= "4"
		cMsg	:= "Pedido não encontrado no Protheus."
		GravaLog(cMsg, nRecno, cStatus)
		
		Aadd(aIntZX3,{"","",cMsg,cStatus,cNumPed})
		
		lRet	:= .F.
	EndIf
Else
	//Array sem conteudo
	cStatus	:= "4"
	cMsg	:= "Problema na leitura da linha ZX2_TXT, sem conteudo."
	GravaLog(cMsg, nRecno, cStatus)
	
	Aadd(aIntZX3,{"","",cMsg,cStatus,cNumPed})
	
	lRet	:= .F.
EndIf

RestArea(aAreaZX2)
RestArea(aAreaC5)
RestArea(aArea)

Return lRet

/*
Funcao      : GravaLog
Objetivo    : Gravar Log da Integracao
Autor     	: Renato Rezende
*/
*-------------------------------------------------------* 
 Static Function GravaLog(cMsg, nRecno, cStatus)
*-------------------------------------------------------* 
Local cQuery	:= ""
Local aArea		:= GetArea()
Local aAreaZX2	:= ZX2->(GetArea())
Local aAreaZX3	:= ZX3->(GetArea())

DbSelectArea("ZX3")
ZX3->(DbSetOrder(1))

DbSelectArea("ZX2")
ZX2->(DbSetOrder(1))
ZX2->(DbGoTo(nRecno))

ZX3->(RecLock('ZX3',.T.))
	ZX3->ZX3_FILIAL	:= FwxFilial('ZX3')
	ZX3->ZX3_USER	:= Iif(Empty(cUserName),"JOB",cUserName)
	ZX3->ZX3_DATA	:= dDatabase
	ZX3->ZX3_HORA	:= Left(Time() , 5)
	ZX3->ZX3_ARQ	:= ZX2->ZX2_ARQ
	ZX3->ZX3_TXT	:= ZX2->ZX2_TXT
	ZX3->ZX3_PFTP	:= ZX2->ZX2_PFTP
	ZX3->ZX3_PEDNUM	:= ZX2->ZX2_PEDNUM
	ZX3->ZX3_CODAGV	:= ZX2->ZX2_CODAGV
	ZX3->ZX3_CCAGV	:= ZX2->ZX2_CCAGV
	ZX3->ZX3_MSG	:= cMsg
	ZX3->ZX3_STATUS	:= cStatus
ZX3->(MSunlock())

//Arquivo processado retirar da ZX2
cQuery:= "DELETE "+RetSqlName("ZX2")+" WHERE R_E_C_N_O_ = "+Alltrim(Str(nRecno))+" "

TcSqlExec(cQuery)

RestArea(aAreaZX3)
RestArea(aAreaZX2)
RestArea(aArea)

Return Nil