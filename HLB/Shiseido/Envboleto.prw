#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE ENTER CHR(13)+CHR(10)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnvBoleto.
 envia o boleto para SFTP Shiseido
@author  Sandro
@version   
@since    23/07/2020
/*/
//-------------------------------------------------------------------------------------------------------------
User Function EnvBoleto() 

Local cRootPath := GetSrvProfString("RootPath", "\undefined")   											   
Local cINTBOLn  := '/boleto/'
Local cLocArq   := '\FtpIDL\'
Local cLocRet   := '\FtpIDL\'                                                                          
Local cLocLogs  := '\FtpIDL\logs\'
Local cLocLgEr  := '\FtpIDL\logs\erro\'
Local nR        := 0  
Local cArq

Private lRet

If !ExistDir('\FtpIDL\')
	MakeDir('\FtpIDL\')
EndIf
	
If !ExistDir(cLocArq)
	MakeDir(cLocArq)
EndIf 

If !ExistDir(cLocRet)
	MakeDir(cLocRet)
Endif                                                                                                                                        

If !ExistDir(cLocLogs)
   MakeDir(cLocLogs)
EndIf
    
If !ExistDir(cLocLgEr)
   MakeDir(cLocLgEr)
EndIf

aFileRet := {}
aDir(cLocRet+"*.pdf",aFileRet,,,,,.F.) //Carrega os arquivos encriptados na pasta retorno 
cArq := ''

If Len(aFileRet) = 0
   MsgInfo("Não há arquivos para processar !!'")   
   Return
EndIf

For nR := 1 To Len(aFileRet)
    cArq := aFileRet[nR]
    U_UplSFTP('PUT',cArq,cLocRet,cINTBOLn,cLocLogs,cLocLgEr)  //Envia os arquivos para a pasta no SFTP. 
    If lRet
       U_IDLLOG("FTP",substr(cArq,1,Rat(".pdf",cArq)-1), "DOCUMENTOS", "1",cLocArq+cArq,"Arquivo enviado com sucesso.")   
       fRename(cLocRet+cArq,cLocRet+substr(cArq,1,Rat(".pdf",cArq))+'out',,.F.)    //Renomeia o arquivo criptografado da pasta retorno apï¿½s envio ao SFTP.      	                  
    Else   
       U_IDLLOG("FTP",substr(cArq,1,Rat(".pdf",cArq)-1), "DOCUMENTOS", "0",cLocArq+cArq,"Arquivo não enviado.") 
    EndIf   
Next nR	        

MsgInfo("Envio boleto finalizado com sucesso.","Envio de Boleto.")

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} UplSFTP.
Realiza a conexï¿½o com SFTP Shiseido
 
@author    
@version   
@since     24/07/2020
/*/
//------------------------------------------------------------------------------------------
User Function UplSFTP(cOper,cArqSFPT,cDirSRV,cDirSFTP,cLocLogs,cLocLgEr)

Local cCommando := ""
Local lWait     := .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cRootPath := GetSrvProfString("RootPath", "\undefined")
Local cBat      := ""                                            
Local cArqLog   := ""
Local cBatWscpS := "" 
Local cDataLog  := StrTran(dTos(dDataBase), '/', '-')+StrTran(Time(), ':','')
Local nR        := 0

lRet := .F.

cBatWscpS := "\WiscpconnectS.bat"
 
//Cria arquivo bat para subir arquivo no FTP.
nHdl := FCREATE(cBatWscpS,0 )  //Criaï¿½ï¿½o do Arquivo txt.                                                  
If nHdl == -1 // Testa se o arquivo foi gerado
   cMsg :="O bat "+cBatWscpS+" nao pode ser executado."
   conout(cMsg)
   Return lRet
EndIf  
cCommando:= '@echo off'+ENTER
cCommando+= ENTER
cCommando+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+ENTER
cCommando+= '  /log="'+cRootPath+cLocLogs+'WinSCPconnect.log" /ini=nul ^'+ENTER   
cCommando+= '  /command ^'+ENTER
cCommando+= ' "open sftp://shiseido:Sh1%%24IDL20@177.47.18.54:2201/ -hostkey=""ssh-rsa 2048 ZLSRR368So0OwmX+EooAa8iNnlO1YpxMsJPymbVZtzg=""" ^'+ENTER
If cOper = 'GET' .Or. cOper = 'DEL' 
   cCommando+= '    "cd '+cDirSFTP+'" ^'+ENTER       
EndIf 
If cOper = 'GET'  
   cCommando+= '    "'+cOper+' *.pgp '+cRootPath+cDirSRV+'" ^'+ENTER
ElseIf cOper = 'DEL'  
   cCommando+= '    "get -delete '+Alltrim(cArqSFPT)+'" ^'+ENTER   
ElseIf cOper = 'PUT'
   cCommando+= '    "lcd '+cRootPath+cDirSRV+'" ^'+ENTER   
   cCommando+= '    "cd '+cDirSFTP+'" ^'+ENTER
   cCommando+= '    "'+cOper+' '+cRootPath+cDirSRV+Alltrim(cArqSFPT)+'" ^'+ENTER
EndIf                 
cCommando+= '    "exit"' +ENTER
cCommando+= ENTER
cCommando+= 'set WINSCP_RESULT=%ERRORLEVEL%'+ENTER
cCommando+= 'if %WINSCP_RESULT% equ 0 ('+ENTER
cCommando+= '  echo Success'+ENTER
cCommando+= ') else ('+ENTER
cCommando+= '  echo Error'+ENTER
cCommando+= '  Move '+cRootPath+cLocLogs+'WinSCPconnect.log '+cRootPath+cLocLgEr+'WinSCPconnect.log'+ENTER  
cCommando+= ')'+ENTER
cCommando+= ENTER
cCommando+= 'exit /b %WINSCP_RESULT%'+ENTER
fWrite(nHdl,cCommando)//Escreve no arquivo 
fclose(nHdl)//Fecha o arquivo
lRet := WaitRunSrv( @cRootPath+cBatWscpS , @lWait , @cPath )
fErase(cBatWscpS)//Apaga o .Bat
Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IDLLOG
Rotina para gravaï¿½ï¿½o de logs.
@param		cTabela		- Tabela Principal, exemplo: "SF1"
			cChaveDoc		- Chave de pesquisa, exemplo F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA "123456789UNI00123401"
			cProcesso	- Nome da rotina	
			cStatus		- 0=Com Erro / 1=Com Sucesso / 3= Atencao / 4= Aprovaï¿½ï¿½o
			cArquivo	- Nome do arquivo que estï¿½ sendo processado
			cMensagem	- Se "ok" vï¿½zio, Se Erro, apresenta error.log
@author    	Marcio Martins Pereira
@version   	1.xx
@since     	15/07/2019
/*/
//------------------------------------------------------------------------------------------
User Function IDLLOG(cTabela, cChaveDoc, cProcesso, cStatus, cArquivo, cMensagem)

	Local   _aArea 	 := GetArea()
	Default cMensagem  := ""

	Z0G->(DBSelectArea("Z0G"))
	RecLock("Z0G", .T.)
	Z0G->Z0G_FILIAL := xFilial("Z0G")
	Z0G->Z0G_DATA	 := Date()
	Z0G->Z0G_HORA	 := Time()
	Z0G->Z0G_USER	 := SubStr(cUsuario, 7, 15)
	Z0G->Z0G_TABELA := cTabela
	Z0G->Z0G_CHAVE	 := cChaveDoc
	Z0G->Z0G_PROCES := cProcesso
	Z0G->Z0G_STATUS := cStatus
	Z0G->Z0G_ARQUIV := cArquivo
	Z0G->Z0G_MENSAG := cMensagem
	Z0G->(MSUnLock())

	RestArea(_aArea)

Return


