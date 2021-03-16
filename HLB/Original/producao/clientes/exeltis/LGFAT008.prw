#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fileio.ch"

/*
Funcao      : LGFAT008
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gravar pedidos enviados pela IMS na tabela ZX4
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 05/06/2018
*/
*------------------------*
 User Function LGFAT008()
*------------------------*
Local cTo			:= ""
Local cToOculto		:= ""
Local cSubject		:= ""
Local cMsg			:= ""

Private lJob		:= (Select("SX3") <= 0)
Private cDate		:= ""
Private cTime		:= ""
Private cUser		:= ""
Private cAnexos		:= ""
Private cRetProc	:= ""
Private cDirSrv		:= ""
Private nContOk		:= 0
Private aArquivos	:= {}

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","HLB BRASIL" )
	Return
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "LG" FILIAL "01" TABLES "SA1" , "SC5" , "SC6" , "SB1" MODULO "FAT" 

	cDate 		:= DtoC(Date())
	cTime 		:= SubStr(Time(),1,5)
	cUser 		:= UsrFullName(RetCodUsr())
	cSubject	:= "[EXELTIS] ERRO - Integração Pedidos IMS "+DtoC(Date())
	cTo			:= AllTrim(GetMv("MV_P_00040",," "))
	cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))
	cDirSrv		:= "\FTP\"+cEmpAnt+"\IMS\PEDIDOS"

	//Verifica pasta no servidor para salvar os arquivos
	If ExistDir("\FTP")
		If !ExistDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
	   		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		EndIf
	Else
		MakeDir("\FTP")
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\IMS")
		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
	EndIf
	
	If !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		conout("Fonte LGFAT008: Falha ao carregar diretório FTP no Servidor!")
	Else

		//Conecta no FTP e copia os arquivos txt dos pedidos
		lConecta := ConectaFtp("D")
		
		//Processa os arquivos do servidor
		If lConecta
			//Integra os pedidos
			IntPed()
		EndIf
		
		If !lConecta
			cMsg	:= HtmlPrc()
			//Envia e-mail após concluir o processo
			lEnvia	:= u_GTGEN045(cMsg,cSubject,"",cTo,cToOculto,cAnexos)
			
		Else	
			//Exclui os arquivos do FTP
			If Len(aArquivos)>0
				lConecta := ConectaFtp("E")
			EndIf
		EndIf
	EndIf
EndIf

Return nil

/*
Funcao      : ConectaFTP
Objetivo    : Conexão ao servidor FTP 
Autor       : Anderson Arrais
*/
*------------------------------------*
 Static Function ConectaFTP(cTipo)
*------------------------------------*  
Local lRet		:= .T. 
Local nTry		:= 3
Local nR		:= 0
Local nR3		:= 0
Local i			:= 0
Local cFtp		:= GetMV( "MV_P_FTPIM" ,, '' )//"162.44.221.132"//
Local cLogin	:= GetMV( "MV_P_USRIM" ,, '' )//"Exeltis"//
Local cPass		:= GetMV( "MV_P_PSWIM" ,, '' )//"Exel2017*"//
Local aArqInt 	:= {}
Local lDownload	:= .T.

Local aArqDel            


For i := 1 To nTry 
	If ( lRet := FTPConnect(cFtp,,cLogin,cPass) )
		Exit
	EndIf   
	Sleep(5000)
Next

If !lRet
	Conout("Falha ao conectar")
	Return lRet
EndIf	

FtpDirChange("PEDIDOS/")
//FtpDirChange("TESTE/")
	
//Download
If cTipo == "D"
	
	aArqInt := FtpDirectory("*.*")
	For nR3:=1 to Len(aArqInt)
		lDownload:= .F.
		//Download apenas de TXT
		If !(".TXT" $ Upper(aArqInt[nR3][1]))
			Loop
		EndIf

		//Verifica se o arquivo existe no servidor, se sim excluir e carregar o novo.
		If File(cDirSrv + "\" + aArqInt[nR3][1])
			FErase(cDirSrv + "\" + aArqInt[nR3][1])
		EndIf

		//Download do arquivo para o servidor processar 
		lDownload:= FtpDownload(cDirSrv+"\"+aArqInt[nR3][1], aArqInt[nR3][1])
		Aadd(aArquivos, aArqInt[nR3][1])
	Next nR3 
EndIf

//Excluir
If cTipo == "E"
                   	
	For nR := 1 To Len(aArquivos)  
				
		//Coloca o arquivo na pasta BKP do servidor
		If File(cDirSrv + "\" + aArquivos[nR])
			//Verifica se o arquivo existe no servidor, se sim excluir
			If File(cDirSrv + "\bkp\" + aArquivos[nR])
				FErase(cDirSrv + "\bkp\" + aArquivos[nR])
			EndIf
			//Copia para a pasta bkp
			fRename(cDirSrv + "\" + aArquivos[nR], cDirSrv + "\bkp\" + aArquivos[nR])
			
			//Compacta a pasta bkp
			Compacta( cDirSrv + "\bkp\*.txt" , cDirSrv + "\bkp\processados_"+GravaData(Date(),.F.,5)+".rar")

		EndIf
		//Excluir arquivo do FTP
		FTPErase(aArquivos[nR])
	Next nR

EndIf

FTPDisconnect()


Return(lRet)


/*
Função  : IntPed
Objetivo: Integra pedido de venda.
Autor   : Anderson Arrais
Data    : 23/10/2017
*/
*------------------------*
 Static Function IntPed()
*------------------------*
Local aConteudo	:= {}
Local aDadosSM0 := {}
Local aAllFilial:= FWAllFilial()
Local cFil		:= ""
Local cPryKey	:= ""
Local cLinha	:= ""
Local cCod		:= ""
Local i			:= 0
Local nR		:= 0

For i:=1 to Len(aArquivos)  
	cArqAtu := cDirSrv+"\"+aArquivos[i]
	
	FT_FUse(cArqAtu)	 // Abre o arquivo
	FT_FGOTOP()      	 // Posiciona no inicio do arquivo

	cPryKey			:= GETSXENUM("ZX4","ZX4_PRYKEY")
	
	If !Empty(cAnexos)
		cAnexos		+= ";"
	EndIf
	cAnexos			+= cDirSrv+"\"+aArquivos[i]
	
	While !FT_FEof()
	   	cLinha 	 	:= FT_FReadln()        // Le a linha
		cCod   		:= SUBSTR(cLinha,1,2)
				
		If cCod $ "01" //Header
			aConteudo:={}
			cFil:=""
            Aadd(aConteudo,SUBSTR(cLinha,17,14)) 												//[01]-CNPJ
			
			//Valida CNPJ se exsite no Sigamat
            For nR:= 1 to Len(aAllFilial)
            	aDadosSM0 := FWArrFilAtu(cEmpAnt,aAllFilial[nR])
            	If aDadosSM0[18]== aConteudo[1]
            		cFil:= aAllFilial[nR]
            	EndIf
            Next nR
            
		EndIf
		
		If cCod $ "02" //Capa
			Aadd(aConteudo,SUBSTR(cLinha,21,1))													//[02]-Tipo
            Aadd(aConteudo,SUBSTR(cLinha,22,6))													//[03]-Cliente
            Aadd(aConteudo,SUBSTR(cLinha,28,2))													//[04]-Loja Cli
            Aadd(aConteudo,Alltrim(SUBSTR(cLinha,38,3))) 										//[05]-Condição Pagamento
            Aadd(aConteudo,STRZERO(VAL(Alltrim(SUBSTR(cLinha,44,6))),6))						//[06]-Vendedor
            Aadd(aConteudo,StoD(SUBSTR(cLinha,54,4)+SUBSTR(cLinha,52,2)+SUBSTR(cLinha,50,2))) 	//[07]-Emissao
            Aadd(aConteudo,StoD(SUBSTR(cLinha,128,4)+SUBSTR(cLinha,126,2)+SUBSTR(cLinha,124,2)))//[08]-Data Entrada
			Aadd(aConteudo,Alltrim(SUBSTR(cLinha,58,60)))										//[09]-Mensagem Nota
			Aadd(aConteudo,Alltrim(SUBSTR(cLinha,11,10))) 										//[10]-Pedido IMS
			Aadd(aConteudo,STRZERO(VAL(Alltrim(SUBSTR(cLinha,41,3))),3))					 	//[11]-Tabela
			Aadd(aConteudo,SUBSTR(cLinha,118,2)) 												//[12]Codigo Operacao

	    EndIf
	        
		If cCod $ "03" //Itens         

			ZX4->(RecLock('ZX4',.T.))
				ZX4->ZX4_FILIAL := cFil
				ZX4->ZX4_PRYKEY	:= cPryKey 
				ZX4->ZX4_CLIENT := aConteudo[3]
				ZX4->ZX4_LOJACL := aConteudo[4]
				ZX4->ZX4_CONDPA := aConteudo[5]
				ZX4->ZX4_TIPO	:= aConteudo[2]
				ZX4->ZX4_TABELA := aConteudo[11]
				ZX4->ZX4_VEND1 	:= aConteudo[6]
				ZX4->ZX4_EMISSA := aConteudo[7]
				ZX4->ZX4_MENNOT := aConteudo[9]
				ZX4->ZX4_FECENT := aConteudo[8]
				ZX4->ZX4_P_REF 	:= aConteudo[10]
				ZX4->ZX4_ITEM 	:= SUBSTR(cLinha,5,2) 
				ZX4->ZX4_PRODUT := Alltrim(SUBSTR(cLinha,7,15)) 
				ZX4->ZX4_QTDVEN := Val(Alltrim(SUBSTR(cLinha,24,7))+"."+Alltrim(SUBSTR(cLinha,31,2)))
				ZX4->ZX4_PRCVEN := Val(Alltrim(SUBSTR(cLinha,41,10))+"."+Alltrim(SUBSTR(cLinha,51,8))) 
				ZX4->ZX4_OPER 	:= aConteudo[12]
				ZX4->ZX4_PEDCLI := Alltrim(SUBSTR(cLinha,82,12)) 
				ZX4->ZX4_XDESCO := Val(Alltrim(SUBSTR(cLinha,60,3))+"."+Alltrim(SUBSTR(cLinha,63,2)))
				ZX4->ZX4_VALDES := Val(Alltrim(SUBSTR(cLinha,65,12))+"."+Alltrim(SUBSTR(cLinha,77,2)))
				ZX4->ZX4_INTEGR := "N"
				ZX4->ZX4_ENVIMS := "N"
				ZX4->ZX4_DATA	:= dDatabase
				ZX4->ZX4_HORA 	:= Left(Time() , 5)
				ZX4->ZX4_ARQ	:= cArqAtu
				ZX4->ZX4_CGC	:= aConteudo[1] 
			
			ConfirmSx8()
			ZX4->(MSunlock())			
	
		EndIf
		
		FT_FSkip()	//Proxima linha	
		
	EndDo
	FT_FUSE() //Fecha arquivo

Next i

Return Nil

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

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
Autor       : Anderson Arrais
Data/Hora   : 12/06/2018
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
If !lConecta
	cHtml += '			<tr>
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">Erro na conexão com o FTP da IMS - LGFAT008</font></td>
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