#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : GYFAT002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Download XML do FTP e gravar na tabela.
Autor       : Renato Rezende
Cliente		: Uber
Data/Hora   : 20/10/2017
*/    
*-----------------------------*
 User Function GYFAT002()
*-----------------------------*
Private lJob	:= (Select("SX3") <= 0)

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","Grant Thornton" )
	Return
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "GY" FILIAL "01" TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"
EndIf

lConecta := ConectaFtp()

Return nil

/*
Funcao      : ConectaFTP
Objetivo    : Conexão ao servidor FTP 
Autor       : Renato Rezende
*/
*-----------------------------------------------*
Static Function ConectaFTP(cOper)
*-----------------------------------------------*  
Local lRet := .T. 
Local i,j
Local nTry := 3

Local cDirFtpIn	:= ""
Local cDirSrv	:= "\FTP\GY\GYFAT002"
Local cFtp		:= GetMV( "MV_P_FTP" ,, '' )//"10.0.30.34"//
Local cLogin	:= GetMV( "MV_P_USR" ,, '' )//"uber"//
Local cPass		:= GetMV( "MV_P_PSW" ,, '' )//"@QpjwqO4"//
Local cPastFTP	:= ""

Local aArqFtpP1 := {}
Local aArqFtpP2 := {}
Local aArqInt 	:= {}

Local lDownload	:= {}

Local aArqDel            
Local aArqServer := {}
Local aArqFolder := {}

//Criação das pastas no servidor
If ExistDir("\FTP")
	If !ExistDir("\FTP\GY")
		MakeDir("\FTP\GY")
		MakeDir("\FTP\GY\GYFAT002")
	ElseIf !ExistDir("\FTP\GY\GYFAT002")
		MakeDir("\FTP\GY\GYFAT002")     
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\GY")
	MakeDir("\FTP\GY\GYFAT002")
EndIf 

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

//Pesquisa a primeira cadeia de pastas do FTP
aArqFtpP1 := FtpDirectory("*.*" ,"D")

For nR:=1 to Len(aArqFtpP1)	
	//If !FtpDirChange("/"+aArqFtpP1[nR][1]) .OR. aArqFtpP1[nR][1] == "SP"
	If !FtpDirChange("/"+aArqFtpP1[nR][1]) .OR. aArqFtpP1[nR][1] <> "BRA"
		Loop
	EndIf
	
	//Pesquisa a segunda cadeia de pastas do FTP
	aArqFtpP2 := FtpDirectory("*.*" ,"D")
	For nR2:=1 to Len(aArqFtpP2)
		If !FtpDirChange("/"+aArqFtpP1[nR][1]+"/"+aArqFtpP2[nR2][1])
			Loop
		EndIf
		
		aArqInt := FtpDirectory("*.*" ,)
		cPastFTP:= "/"+aArqFtpP1[nR][1]+"/"+aArqFtpP2[nR2][1]
		For nR3:=1 to Len(aArqInt)
			lDownload:= .F.
			//Download apenas de XML
			If !(".XML" $ Upper(aArqInt[nR3][1]))
				Loop
			EndIf
			//Download do arquivo para o servidor processar 
			lDownload:= FtpDownload(cDirSrv+"\"+aArqInt[nR3][1], aArqInt[nR3][1])
			//Conseguiu fazer o download
			If lDownload
				lProcessa:= GvTabTmp(cDirSrv+"\",aArqInt[nR3][1],cPastFTP)

				//Exclui o arquivo do FTP e do Servidor
				If lProcessa
					FErase(cDirSrv+"\"+aArqInt[nR3][1])
					/*If !FTPErase(aArqInt[nR3][1])
						conout("Nao foi possivel excluir arquivo do FTP")
					EndIf*/
				EndIf
			EndIf
		Next nR3 
			
	Next nR2
	
Next nR   
	   
FTPDisconnect()

Return(lRet)

/*
Funcao		: GvTabTmp
Objetivo	: Grava XML na tabela Temporária de a processar
Autor     	: Renato Rezende
Data     	: 20/10/2017
*/
*-----------------------------------------------------*
 Static Function GvTabTmp(cDirSrv,cXMLInt,cPastFTP)
*-----------------------------------------------------*
Local lRet 		:= .T.
Local cLinha	:= ""

//Verifica se o arquivo existe
If !File(cDirSrv+cXMLInt)
	lRet:= .F.
Else
	FT_FUse(cDirSrv+cXMLInt)//Abre o arquivo
	FT_FGOTOP()// Posiciona no inicio do arquivo

	//Percorre o XML
	While !FT_FEof()
		//Le a linha
		cLinha += FT_FReadln()
		FT_FSkip()//Proxima linha
	EndDo
	FT_FUSE()//Fecha o Arquivo
	
	DbSelectArea("ZX1")
	ZX1->(DbSetOrder(1))
	ZX1->(RecLock('ZX1',.T.))
		ZX1->ZX1_FILIAL := xFilial('ZX1')
		ZX1->ZX1_USER 	:= Iif(Empty(cUserName),"JOB",cUserName)
		ZX1->ZX1_DATA	:= dDatabase
		ZX1->ZX1_HORA 	:= Left(Time() , 5)
		ZX1->ZX1_ARQ	:= cXMLInt
		ZX1->ZX1_XML	:= cLinha
		ZX1->ZX1_PFTP	:= cPastFTP
	ZX1->(MSunlock())
EndIf

Return lRet