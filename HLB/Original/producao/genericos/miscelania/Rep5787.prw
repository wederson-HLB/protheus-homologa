#include "PROTHEUS.CH"

/*
Funcao      : REP5787
Parametros  : cDir
Autor       : Anderson Arrais
Data/Hora   : 05/09/2019
*/
*--------------------------*
User Function REP5787()
*--------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cBatWscp	:= ""
Local cDir		:= ""
Private cPerg  	:="REP5787"

cBatWscp := "\copy.bat"

//Criando Pergunte
U_PUTSX1(cPerg,"01" ,"Qual RPO: ?"	,"Qual RPO: ?"  ,"Qual RPO: ?"	,"mv_ch1","C",01,0, 0,"G","","","","","mv_par01",""		,""		,""		,""	,""		,""		,""		,"","","","","","","","","",{"Informe qual RPO deve ser copiado"},{},{})

If !pergunte(cPerg,.T.)
	return()
endif

cDir	:= MV_PAR01

//Cria arquivo bat para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0 )  //Criação do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	cMsg:="O bat "+cBatWscp+" nao pode ser executado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'cd\	'+CRLF
cCommand+= 'set ORIGEM=D:\TOTVS12\Protheus12\apo_'+cDir +CRLF
cCommand+= 'set DESTINO=\\10.0.30.87\e$\TOTVS12\Protheus12\apo_'+cDir +CRLF
cCommand+= 'robocopy %ORIGEM% %DESTINO% /SEC'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cRootPath )

fErase(cBatWscp)//Apaga o .Bat
Alert("Copia do RPO '"+cDir+"' finalizada.")

Return