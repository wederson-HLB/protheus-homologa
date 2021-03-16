//Irei incluir algumas bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH" 

/*
Funcao      : LGFAT007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Download dos pedidos liberar da AGV no FTP e gravar na tabela.
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 25/05/2018
*/
*-----------------------------*
 User Function LGFAT007()
*-----------------------------*
Local lExFTP		:= .F.
Local lDownload		:= .F.
Local cMsg			:= ""
Local cSubject		:= ""
Local cAnexos		:= ""
Local cTo			:= ""
Local cToOculto		:= ""

Private lJob		:= (Select("SX3") <= 0)
Private aArqInt		:= {}
Private aIntZX2		:= {}
Private cDirServ	:= ""
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
	cDirServ	:= "\FTP\"+cEmpAnt+"\AGV\WMS06"
	cSubject	:= "[EXELTIS] Aprovação de pedidos enviados: "+DtoC(Date())
	cTo			:= AllTrim(GetMv("MV_P_00040",," "))
	cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))
	cDirFtp 	:= GetNewPar('MV_P_WMS06' , '/TEST/WMS06/')

	//Verifica pasta no servidor para salvar o arquivo
	If ExistDir("\FTP")
		If !ExistDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt+"\AGV")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\AGV")
			MakeDir("\FTP\"+cEmpAnt+"\AGV")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\AGV\WMS06")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
			MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")	 
		EndIf
	Else
		MakeDir("\FTP")
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\AGV")
		MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06")
		MakeDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
	EndIf
	
	If !ExistDir("\FTP\"+cEmpAnt+"\AGV\WMS06\bkp")
		conout("Fonte LGFAT007: Falha ao carregar diretório FTP no Servidor!")
	Else
 
		//Download arquivos do FTP
		lDownload := DW2SRV("D")
		
		If lDownload
			//Grava arquivo na tabela temporária
			aIntZX2 := GvTabTmp()
			
			If Len(aIntZX2) > 0
				lExFTP:= DW2SRV("E")
			EndIf
		
		EndIf
		
		//Dispara email de processamento com erro ou não
		If !lDownload .OR. Len(aIntZX2) > 0 
		
			//Monta html da mensagem do email
			cMsg := HtmlPrc(lDownload)
			//Envia email de processamento
			lEnvia:= EnviaEma(cMsg,cSubject,cTo,cToOculto,cAnexos)
		
		EndIf
		
	EndIf
	//Encerra o PREPARE ENVIRONMENT
	RpcClearEnv()
EndIf

Return nil

/*
Função  	: DW2SRV
Objetivo	: Carregar arquivo do FTP da AGV
*/
*------------------------------------------------*
 Static Function DW2SRV(cTipo)
*------------------------------------------------*  
Local lRet		:= .T.
Local aArqFtp	:= {}
Local nR		:= 0

//Conecta no FTP
If ConectaFTP()

	If !FtpDirChange(cDirFtp)
		Conout("Erro na mudança de pasta do Ftp ( WMS06 )", "HLB BRASIL")
		lRet := .F.
	Else
	    
		//Download
		If cTipo == "D"
		
			aArqFtp := FtpDirectory( "*.*", )
			
			For nR := 1 To Len(aArqFtp)  
				aArqFtp[nR][1] := Alltrim(aArqFtp[nR][1]) 
				
				//Verifica se o arquivo existe no servidor, se sim excluir e carregar o novo.
				If File(cDirServ + "\" + aArqFtp[nR][1])
					FErase(cDirServ + "\" + aArqFtp[nR][1])
				EndIf
				//Download dos arquivos 
				FtpDownload(cDirServ + "\" + aArqFtp[nR][1], aArqFtp[nR][1])
				Aadd(aArqInt, aArqFtp[nR][1])
			Next
		
		//Exclusão
		ElseIf cTipo == "E"
		
			For nR := 1 To Len(aIntZX2)  
						
				//Coloca o arquivo na pasta BKP do servidor
				If File(cDirServ + "\" + aIntZX2[nR])
					//Copia para a pasta bkp
					fRename(cDirServ + "\" + aIntZX2[nR], cDirServ + "\bkp\" + aIntZX2[nR])
		
					//Compacta a pasta bkp
					Compacta( cDirServ + "\bkp\*.txt" , cDirServ + "\bkp\processados.rar" )	
					
					//FErase(cDirServ + "\" + aIntZX2[nR])
				EndIf
				//Excluir arquivo do FTP
				FTPErase(aIntZX2[nR])
			Next nR
		EndIf
	    //Desconecta do FTP
		FTPDisconnect()
	EndIf
Else
	Conout("Erro na conexao com o Ftp ( WMS06 )", "HLB BRASIL")
	lRet:= .F.
EndIf

Return(lRet)

/*
Função  	: ConectaFTP
Objetivo	: Conexão ao servidor FTP
*/
*---------------------------------*
 Static Function ConectaFTP()
*---------------------------------*  
Local lRet 		:= .T.  
Local i
Local nTry 		:= 3 
Local cFtp 		:= GETMV("MV_P_FTP",,'ftp.agv.com.br') 
Local cLogin	:= GETMV("MV_P_USR",,'exeltis') 
Local cPass		:= GETMV("MV_P_PSW",,'7Tp@ex3lt!s') 

For i := 1 To nTry 
	If (lRet := FTPConnect(cFtp,,cLogin,cPass))
		Exit
	EndIf   
	Sleep(5000)//5 segundos
Next

Return(lRet)

/*
Funcao		: GvTabTmp
Objetivo	: Grava TXT na tabela Temporária de a processar
Autor     	: Renato Rezende
Data     	: 28/05/2018
*/
*----------------------------------*
 Static Function GvTabTmp()
*----------------------------------*
Local nR,nE		:= 0
Local cNumPed	:= ""
Local cLinha	:= ""
Local cNumPedAnt:= ""
Local cChvAGV	:= ""
Local cChvAGVAnt:= ""
Local cLinhaAux	:= ""
Local oFile

//Cria a tabela
ChkFile("ZX2")
DbSelectArea("ZX2")
ZX2->(DbSetOrder(1))

For nR:= 1 to Len(aArqInt)

	If File(cDirServ + "\" + aArqInt[nR])
		oFile := FWFileReader():New(cDirServ + "\" + aArqInt[nR])
		//Verifica se o arquivo foi aberto corretamente
		If (oFile:Open()) 
		    
			cNumPed		:= ""
			cNumPedAnt	:= ""
			cLinha		:= ""
			cLinhaAux	:= ""
			cChvAGV		:= ""
			cChvAGVAnt	:= ""
			aLinha		:= {}//oFile:GetAllLines() //Separa em um array o arquivo TXT por linha
			lGravou		:= .F.
			
			//Transforma o TXT em um array
			While (oFile:hasLine())
				cLinhaAux:= oFile:GetLine()
				If !Empty(Alltrim(cLinhaAux))	
					Aadd(aLinha,cLinhaAux)
				EndIf
			EndDo
			
			//Percorre o TXT
			For nE:= 1 to Len(aLinha)
				//Le a linha
				cNumPed := Alltrim(SubStr(Alltrim(aLinha[nE]),1,10))
				//Codigo Cliente + Centro de Custo (Na AGV)
				cChvAGV := Alltrim(SubStr(Alltrim(aLinha[nE]),72,5))+Alltrim(SubStr(Alltrim(aLinha[nE]),61,11))
				lGravou	:= .F.
				
				If !Empty(cLinha) .AND. cNumPed <> cNumPedAnt .AND. cChvAGV == cChvAGVAnt .AND. nE > 1   
						
					ZX2->(RecLock('ZX2',.T.))
						ZX2->ZX2_FILIAL := FwxFilial('ZX2')
						ZX2->ZX2_USER 	:= Iif(Empty(cUserName),"JOB",cUserName)
						ZX2->ZX2_DATA	:= dDatabase
						ZX2->ZX2_HORA 	:= Left(Time() , 5)
						ZX2->ZX2_ARQ	:= aArqInt[nR]
						ZX2->ZX2_TXT	:= cLinha
						ZX2->ZX2_PFTP	:= cDirFtp
						ZX2->ZX2_PEDNUM	:= Alltrim(SubStr(Alltrim(aLinha[nE-1]),1,10))
						ZX2->ZX2_CODAGV	:= Alltrim(SubStr(Alltrim(cChvAGV),1,5)) 
						ZX2->ZX2_CCAGV	:= Alltrim(SubStr(Alltrim(cChvAGV),6,11))
					ZX2->(MSunlock())
					
					nE--
					lGravou	:= .T.
					cLinha	:= ""
									
				Else
					If !Empty(cLinha)
						cLinha	+= CRLF
					EndIf
					cLinha	+= aLinha[nE]
				EndIf
				
				cNumPedAnt	:= cNumPed
				cChvAGVAnt	:= cChvAGV
			Next nE
			//Fecha o Arquivo
			oFile:Close()
			
			//Garantir que sera gravado quando chegar no final de arquivo
			If (!Empty(cLinha)) .AND. !lGravou

				ZX2->(RecLock('ZX2',.T.))
					ZX2->ZX2_FILIAL := FwxFilial('ZX2')
					ZX2->ZX2_USER 	:= Iif(Empty(cUserName),"JOB",cUserName)
					ZX2->ZX2_DATA	:= dDatabase
					ZX2->ZX2_HORA 	:= Left(Time() , 5)
					ZX2->ZX2_ARQ	:= aArqInt[nR]
					ZX2->ZX2_TXT	:= cLinha
					ZX2->ZX2_PFTP	:= cDirFtp
					ZX2->ZX2_PEDNUM	:= Alltrim(SubStr(Alltrim(aLinha[nE-1]),1,10))
					ZX2->ZX2_CODAGV	:= Alltrim(SubStr(Alltrim(cChvAGV),1,5)) 
					ZX2->ZX2_CCAGV	:= Alltrim(SubStr(Alltrim(cChvAGV),6,11))
				ZX2->(MSunlock()) 
			
			EndIf 
			
			//Array que gravou corretamente
			Aadd(aIntZX2, aArqInt[nR])
		
		EndIf
	EndIf

Next nR

Return aIntZX2

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
Autor       : Renato Rezende
Data/Hora   : 28/05/2018
*/
*--------------------------------------------*
 Static Function HtmlPrc(lDownload)
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
If lDownload
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVOS DE APROVAÇÃO RECEBIDOS COM SUCESSO!</font></td>
	cHtml += '			</tr>
	//Nome dos arquivos gravados na ZX2
	For nR:= 1 to Len(aIntZX2)
		cHtml += '			<tr>
		cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">'+Alltrim(aIntZX2[nR])+'</font></td>
		cHtml += '			</tr>
	Next nR
Else
	//Falha ao conectar no FTP
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">FALHA AO CONECTAR NO FTP, FAVOR VERIFICAR!!</font></td>
	cHtml += '			</tr>
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
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Renato Rezende
Data/Hora   : 
*/
*------------------------------------------*
 Static Function compacta(cArquivo,cArqRar)
*------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)