//Irei incluir algumas bibliotecas
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : LGFAT011
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Envio de status para a IMS
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 29/08/2018
*/
*--------------------------------------*
 User Function LGFAT011(aEmp)
*--------------------------------------*                                       
Private lJob		:= (Select("SX3") <= 0)
Private cNomeArq	:= ""

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","HLB BRASIL" )
	Return nil
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA1" , "SC5" , "SC6" , "SB1" MODULO "FAT" 
	
   	lAtuZX4  := AtuZX4()
	lGeraArq := GeraArq()

EndIf

Return Nil 

/*
Função  	: GeraArq
Objetivo	: Monta arquivo TXT com status do pedido
*/
*------------------------------*
 Static Function GeraArq()
*------------------------------*
Local lRet		:= .T.
Local cConteudo	:= ""
Local cQuery	:= ""
Local cAliasZX4	:= "QRYZX4"
Local cFilAntBkp:= ""
Local cRetLog	:= ""
Local cUpdate	:= ""
Local cCodStatus:= ""
Local cDscStatus:= ""		
Local aArqs		:= {}
Local aLog		:= {}
Local aAtuStatus:= {}
Local aStatus	:= {}
Local nR		:= 0
Local nRecCount	:= 0
Local nNum		:= 0

cQuery:= "SELECT * FROM "+RetSqlName('ZX4')+" WHERE D_E_L_E_T_ <> '*' AND ZX4_ENVIMS = 'N' ORDER BY ZX4_PRYKEY "

If Select(cAliasZX4)>0
	(cAliasZX4)->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQuery), cAliasZX4, .F., .F. )

Count to nRecCount

(cAliasZX4)->(DbGoTop())

If nRecCount >0

	While (cAliasZX4)->(!EOF())

		cPryKey		:= (cAliasZX4)->ZX4_PRYKEY
		cPedidoIMS	:= (cAliasZX4)->ZX4_P_REF
		cFil		:= (cAliasZX4)->ZX4_FILIAL
		
		If !(cAliasZX4)->(EoF()) .And. (cAliasZX4)->ZX4_FILIAL = cFil .And.;
						 (cAliasZX4)->ZX4_P_REF == cPedidoIMS .AND. (cAliasZX4)->ZX4_PRYKEY == cPryKey  	
			
			nNum++
			cNomeArq	:= "PED_GST_Exeltis"+GravaData(Date(),.F.,8)+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+"_"+Alltrim((cAliasZX4)->ZX4_PRYKEY)+".TXT"
			Aadd( aLog , {cNomeArq })
			
			//Status do Pedido
			cCodStatus:= "" 
			
			cDscStatus:= "" 
			//Pedido gerado no protheus
			If (cAliasZX4)->ZX4_INTEGR = "S" 
			
		  		//Pedido não esta cancelado e não foi faturado(Nota Transmitida).
				If !((cAliasZX4)->ZX4_PEDCAN == 'T') .AND. !((cAliasZX4)->ZX4_PEDFAT == 'T')
					cCodStatus:= "08"
					cDscStatus:= "EM FATURAMENTO"
				
				//Pedido não foi cancelado e a nota foi faturado(Nota Transmitida).
		   		ElseIf !((cAliasZX4)->ZX4_PEDCAN == 'T') .AND. ((cAliasZX4)->ZX4_PEDFAT == 'T')
					cCodStatus:= "05"
					cDscStatus:= "FATURADO"  
					
				//Pedido cancelado.	
				ElseIf ((cAliasZX4)->ZX4_PEDCAN == 'T')
					cCodStatus:= "04"
					cDscStatus:= "CANCELADO" 					
		   		EndIf
			EndIf
			//Array para atualizar o status após envio do arquivo para o FTP
			Aadd( aAtuStatus,{ cFil, (cAliasZX4)->ZX4_P_REF, (cAliasZX4)->ZX4_PRYKEY, (cAliasZX4)->ZX4_DATA, (cAliasZX4)->ZX4_NUM })
		EndIf
		
		//Header
		cConteudo:= "H"
		cConteudo+=	"SITPEDGST"
		cConteudo+=	PADL((cAliasZX4)->ZX4_CGC,14)
		cConteudo+=	"0003"
		Aadd( aLog[nNum], cConteudo)
		
		//Corpo
		cConteudo:= "C"
		cConteudo+= PADL((cAliasZX4)->ZX4_P_REF,10)
		cConteudo+= PADL(cCodStatus,2) // Status do Pedido
		cConteudo+= PADL(cDscStatus,100) // Descrição do status do Pedido
		cConteudo+= PADL((cAliasZX4)->(ZX4_FILIAL+ZX4_NUM),20) // Gestor
		
		Aadd( aLog[nNum], cConteudo)
		
		//Item do Pedido
		//Percorre todos os itens
		While !(cAliasZX4)->(EoF()) .And. (cAliasZX4)->ZX4_FILIAL = cFil .And.;
			 (cAliasZX4)->ZX4_P_REF == cPedidoIMS .AND. (cAliasZX4)->ZX4_PRYKEY == cPryKey  
			
			//Detalhe
			cConteudo:= "D"
			cConteudo+= PADL((cAliasZX4)->ZX4_PRODUT,128)
			cConteudo+= PADL(Alltrim(TRANSFORM(Int((cAliasZX4)->ZX4_QTDVEN),"@R 9999999")),7, "0")
			cConteudo+= PADL(cCodStatus,2) // Status do Pedido
			cConteudo+= PADL(cDscStatus,100) // Descrição do status do Pedido
			cConteudo+= PADL(GravaData(Date(),.F.,8),8) // Data Status
			
			Aadd( aLog[nNum] , cConteudo)
			
			(cAliasZX4)->(DbSkip())	
		EndDo

	EndDo
	
	//Grava Arquivo
	cRetLog:= GerEnvLg(aLog)
	
	//Atualiza o status de envio para o FTP
	If cRetLog == "0"
		For nR:= 1 to Len(aAtuStatus)
			//Atualizar campos da ZX4
			cUpdate:= " UPDATE "+RetSqlName("ZX4")+" SET ZX4_ENVIMS = 'S' "
			cUpdate+= "  WHERE ZX4_FILIAL = '"+aAtuStatus[nR][1]+"' AND D_E_L_E_T_ <> '*' AND ZX4_PRYKEY = '"+aAtuStatus[nR][3]+"' " 
			cUpdate+= "	   AND ZX4_P_REF = '"+aAtuStatus[nR][2]+"' AND ZX4_DATA = '"+aAtuStatus[nR][4]+"' AND ZX4_NUM = '"+aAtuStatus[nR][5]+"' "
			TcSqlExec(cUpdate)
		Next nR		
	EndIf
	
EndIf

Return lRet

/*
Funcao      : GerEnvLg
Parametros  : 
Objetivos   : Gerar e enviar arquivo de log a partir de qualquer rotina externa 
Autor       : Renato Rezende
*/
*---------------------------------------------*
 Static Function GerEnvLg(aDadosLog)
*---------------------------------------------*
Private cPath 		:= GetMV( "MV_P_FTPIM" ,, '' )//"162.44.221.132"//
Private clogin		:= GetMV( "MV_P_USRIM" ,, '' )//Produção: "Exeltis"/ Teste: "Exeltis_T"/
Private cPass		:= GetMV( "MV_P_PSWIM" ,, '' )//Produção: "Exel2017*"/ Teste: "Exel123*"/
Private cDate		:= DtoC(Date())                                                            
Private cTime		:= SubStr(Time(),1,5)
Private cUser		:= UsrFullName(RetCodUsr())
Private cSubject	:= "[EXELTIS] ERRO - Status Integração Pedidos IMS "+DtoC(Date())
Private cTo			:= AllTrim(GetMv("MV_P_00040",," "))
Private cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))
Private cStatus		:= "0"
Private cMsgProc	:= ""

//Diretorios no FTP do cliente
Private cDirFtpout:= "ENTRADA/"

//Diretorio no Servido Protheus
Private cDirSrvOut := "\FTP\"+cEmpAnt+"\IMS\STATUS"

Private cExtZip := "ZIP"
Private aProcessados := {}

//Cria diretório no servidor
//Verifica pasta no servidor para salvar os arquivos
If !(lDiretorio:= CriaDir())
	cMsgProc	:= "Envio Status. Falha ao carregar diretório FTP no Servidor. Erro no processo."
	cStatus		:= "1"
Else
	GeraLog(aDadosLog)
	ManuArqFTP() 
EndIf

//Enviar email quando acontecer erro no processo
If cStatus == "1"
	cMsg	:= HtmlPrc()
	//Envia e-mail após concluir o processo
	lEnvia	:= u_GTGEN045(cMsg,cSubject,"",cTo,cToOculto,"")
EndIf

Return cStatus

/*
Funcao      : CriaDir
Retorno		: lRet
Objetivos   : Tratamento para pasta de migração;
*/
*---------------------------*
 Static Function CriaDir()
*---------------------------*
Local i				:= 0
Local cDir			:= ""
Local cPastaRaiz	:= "\FTP"
Local cPastaEmpr	:= "\"+cEmpAnt
Local cPastaIMS		:= "\IMS"
Local cPastaStat	:= "\STATUS" 
Local cPastaBkp		:= "\BKP"
Local lRet			:= .T.

Local aDir := {	cPastaRaiz,;//Acerto do diretorio raiz.
				cPastaEmpr,;//Diretorio da Empresa.
				cPastaIMS,;
				cPastaStat,;
				cPastaBkp}

For i:=1 to Len(aDir)
	If ValType(aDir[i]) == "C"
		cDir += aDir[i]
		If !File(cDir)
			If (nErro:=MakeDir(cDir)) <> 0
				lRet := .F.
				Return lRet
			EndIf
			lRet := .T.
		EndIf
	EndIf
Next i
  
Return lRet

/*
Funcao      : GeraLog
Parametros  : 
Retorno     :
Objetivos   : Função para a geração do arquivo de LOG na pasta Out do FTP no SERVER.
Autor       : Renato Rezende
*/
*--------------------------------------*
 Static Function GeraLog(aInfo)
*--------------------------------------*
Local j,k
Local nHdl		:= 0
Local cLinha	:= ""
Local cArqLog	:= "" 
Local cMsg		:= ""

Local aArquivos := aInfo 

For k:=1 to Len(aArquivos)

	cArqLog	:= aArquivos[k][1]
	cLinha	:= ""
	//Validação de arquivo não existente
	If File(cDirSrvOut+"\"+cArqLog)
		FErase(cDirSrvOut+"\"+cArqLog)
	EndIf
	
	nHdl := FCreate(cDirSrvOut+"\"+cArqLog,0 )
	
	For j:=2 to Len(aArquivos[k])
		cLinha := aArquivos[k][j]
		FWrite(nHdl, cLinha+Chr( 13 ) + Chr( 10 ))
	Next j

	FClose(nHdl)//Fecha o arquivo que foi gerado
	
	GrvTabLog(aArquivos[k][1])
	Aadd( aProcessados , { cArqLog , aArquivos[k][1] } ) //** Este array serve para apagar os arquivos processados e mover pra pasta OUT do FTP	
Next k

Return .T.

/*
Funcao      : ManuArqFTP()  
Objetivos   : Função responsavel por manipular os arquivos no FTP.
Autor       : Renato Rezende
*/
*-----------------------------------*
 Static Function ManuArqFTP()
*-----------------------------------*
Local i				:= 0
Local cDirFtpAtu	:= ""
Local cDirSrvAtu	:= ""
Local lConnect		:= .F.
Local aArqServer	:= {}

//Conexao com o FTP informado nos paramentros.
For i:=1 to 3// Tenta 3 vezes.
	If (lConnect := FTPConnect(cPath,,cLogin,cPass))
		Exit
	EndIf   
	Sleep(5000)//5 segundos
Next i

If !lConnect
	cMsgProc	:= "Envio Status. Falha ao conectar no FTP da IMS. Erro no processo."
	cStatus		:= "1"	
	Return .F.
EndIf   

cDirFtpAtu	:= cDirFtpOut
cDirSrvAtu	:= cDirSrvOut

//Monta o diretório do FTP.
FTPDirChange(cDirFtpAtu)

//Carrega para FTP somente os arquivos que foram processados, ou seja, que foram gravados na ZX5 atraves do array 'aProcessados'
aArqServer := aClone(aProcessados)

//Efetua o Upload do Arquivo do Server para o FTP.
For i:=1 to Len(aArqServer)

	If RIGHT(aArqServer[i][1],3) <> cExtZip

		//Muda pasta no FTP
		FTPDirChange(cDirFtpAtu)

		If FTPUpload(cDirSrvAtu+"\"+aArqServer[i][1],aArqServer[i][1]) 

			//Retira o arquivo de entrada do Ftp
			If File( cDirSrvAtu+"\"+aArqServer[i][1] )

				//Copia para a pasta bkp
				fRename(cDirSrvAtu + "\" + aArqServer[i][1], cDirSrvAtu + "\bkp\" + aArqServer[i][1])
				
				//Compacta a pasta bkp
				Compacta( cDirSrvAtu + "\bkp\*.txt" , cDirSrvAtu + "\bkp\processados_"+GravaData(Date(),.F.,5)+".rar")
			EndIf
		EndIf
		
	EndIf
Next i        

//Encerra conexão com FTP
FTPDisconnect()

Return Nil

/*
Funcao      : GrvTabLog
Parametros  : cNomeArq
Objetivos   : Função para a gravação da tabela de LOG.
Autor       : Renato Rezende
*/
*------------------------------------*
 Static Function GrvTabLog(cNomeArq)
*------------------------------------*
Local cUserName := UsrFullName(RetCodUsr())

If AliasInDic( 'ZX5' )
	ZX5->(DbSetOrder(1))
	ZX5->(RecLock("ZX5",.T.))
	ZX5->ZX5_FILIAL := FwxFilial("ZX5")
	ZX5->ZX5_COD := STRZERO(ZX5->(Recno()),9)
	ZX5->ZX5_ARQ := UPPER(cNomeArq)
	ZX5->ZX5_DATA := Date()
	ZX5->ZX5_HORA := Time()
	ZX5->ZX5_USER := IIF(Empty(ALLTRIM(cUserName)),"JOB", Alltrim(cUserName))
	ZX5->(MsUnlock())
EndIf

Return Nil

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Renato Rezende 
*/
*--------------------------------------------------*
 Static Function compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
*/
*----------------------------------------*
 Static Function HtmlPrc()
*----------------------------------------*
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
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">LOG DO PROCESSAMENTO:</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">'+cMsgProc+'</font></td>
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
Funcao      : AtuZX4
Parametros  : 
Retorno     : lRet
Objetivos   : Função para atualizar o status das notas
			  que foram transmitidas.
Autor       : Weden Alves
*/
*--------------------------------------------------*
 Static Function AtuZX4()
*--------------------------------------------------* 
Local cQuery 	:=	""
Local cAliasZX4	:=	"QRYZX4"
Local cUpdate 	:=	""

              
cQuery := "SELECT * FROM "+RetSqlName('ZX4')+" WHERE D_E_L_E_T_ <> '*' AND ZX4_INTEGR = 'S' AND ZX4_PEDCAN <> 'T' AND ZX4_PEDFAT <> 'T' AND ZX4_NUM IN ("
cQuery += 	"SELECT D2_PEDIDO FROM "+RetSqlName('SD2')+" WHERE D_E_L_E_T_ <> '*' AND D2_DOC IN ("
cQuery +=		" SELECT F2_DOC FROM "+RetSqlName('SF2')+" WHERE D_E_L_E_T_ <> '*' AND F2_CHVNFE <> ''))"
cQuery += " ORDER BY ZX4_PRYKEY "

If Select(cAliasZX4)>0
   		(cAliasZX4)->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQuery), cAliasZX4, .F., .F. )
(cAliasZX4)->( DbGotop() )
While (cAliasZX4)->(!EOF())
	If !(cAliasZX4)->(EoF()) 
		
		cUpdate:= " UPDATE "+RetSqlName("ZX4")+" SET ZX4_ENVIMS = 'N', ZX4_PEDFAT = 'T'"
		cUpdate+= "  WHERE ZX4_FILIAL = '"+(cAliasZX4)->ZX4_FILIAL+"' AND D_E_L_E_T_ <> '*' AND ZX4_PRYKEY = '"+(cAliasZX4)->ZX4_PRYKEY+"' " 
		cUpdate+= "	   AND ZX4_P_REF = '"+(cAliasZX4)->ZX4_P_REF+"' AND ZX4_DATA = '"+(cAliasZX4)->ZX4_DATA+"' AND ZX4_NUM = '"+(cAliasZX4)->ZX4_NUM+"' "
		TcSqlExec(cUpdate)
	
	EndIf 
	(cAliasZX4)->( dbSkip() )
EndDo	

Return Nil                         
