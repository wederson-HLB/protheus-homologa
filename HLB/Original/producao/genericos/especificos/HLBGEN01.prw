#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : HLBGEN01
Parametros  : cOpc,cId,cDir,cExt,cPass
Retorno     : lRet
Objetivos   : Rotina de criptografia de arquivo PGP
Autor       : Anderson Arrais
Data/Hora   : 24/06/2019
*/
*-----------------------------------------------*
User Function HLBGEN01(cOpc,cId,cDir,cExt,cPass)
*-----------------------------------------------*
Local cCommand 	:= ""
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cBatGpg	:= "\gpgfile.bat"
Local lRet		:=.F.

Default cOpc	:= "" 	//E - Encripta, D - Desencripta
Default cId		:= ""	//Se encripta informar o ID da key publica, se desencripta informar o nome da key privada
Default cDir	:= ""	//Informar o caminho da pasta onde consta os arquivos para desincriptar ou encriptar
Default	cExt	:= ""	//Caso queira informar a extensão dos arquivos que devem ser lido ".txt" caso fique em branco aplica para toda pasta
Default cPass	:= ""	//usado apenas para desencriptar

If FILE(cBatGpg)
	fErase(cBatGpg)
EndIf

//Cria arquivo bat para criptografar ou descriptograr arquivo(s)
nHdl := FCREATE(cBatGpg,0,,.F. )  //Criação do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	//Return lRet
EndIf

If cOpc $ "E" //Encripta arquivo(s)
	cCommand :='@ECHO off '+CRLF 
	cCommand +='PUSHD "'+cDir+'" '+CRLF 
	cCommand +='FOR /F "tokens=*" %%F IN ' 
	cCommand +="('DIR *"+cExt+" /B') DO ( " +CRLF 
	//cCommand +='gpg --armor --batch --yes --recipient "'+cId+'" --encrypt %%F) '+CRLF 
	cCommand +='gpg --batch --yes --recipient "'+cId+'" --encrypt %%F) '+CRLF 
	cCommand +='POPD '+CRLF 
	cCommand +='EXIT '+CRLF 
ElseIf cOpc $ "D"//Desencripta arquivo(s)
	cCommand :='@ECHO off '+CRLF      
	cCommand +='PUSHD "'+cDir+'" '+CRLF
	cCommand +='FOR /F "tokens=*" %%F IN '
	cCommand +="('DIR *"+cExt+" /B') DO ( "+CRLF
	cCommand +='gpg --output %%~nF --pinentry-mode loopback --passphrase '+cPass+' --batch --yes -r '+cId+' --decrypt %%F)'+CRLF
	cCommand +='POPD '+CRLF
	cCommand +='EXIT '+CRLF
EndIf	

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatGpg , .T. , 'C:\Windows\System32\' )
Sleep(500)

fErase(cBatGpg)//Apaga o .Bat
   
Return(lRet)