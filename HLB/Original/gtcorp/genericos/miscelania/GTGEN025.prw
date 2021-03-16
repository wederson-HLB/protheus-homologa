#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : GTGEN025
Parametros  : 
Retorno     : 
Objetivos   : Limpeza do server
Autor       : Jean Victor Rocha
Data/Hora   : 28/02/2014
Obs         : 
*/                 
*----------------------*
User Function GTGEN025() 
*----------------------*                         
Private cArqLog := "LOGDIR.TXT"

GrvLog(CHR(13)+CHR(10)+">>>>>>>>>>>>>>>>>>>>>>>> Limpeza de Server Iniciada <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"+CHR(13)+CHR(10)+DTOC(date())+"-"+TIME()) 
//GrvLog(ALLTRIM(STR(DiskSpace(4)/(1024^3)))+"Gb de espaço disponivel na Unidade D:")

Clean("MIGRACAO")
Clean("SYSTEM")
Clean("PSWBACKUP")
Clean("BKP")

//GrvLog(ALLTRIM(STR(DiskSpace(4)/(1024^3)))+"Gb de espaço disponivel na Unidade D:")
GrvLog(CHR(13)+CHR(10)+"Limpeza de Server Finalizada "+DTOC(date())+"-"+TIME()) 
Return .T.

/*
Funcao      : Clean
Parametros  : 
Retorno     : 
Objetivos   : Zipar os arquivos de acordo com os parametros
Autor       : Jean Victor Rocha
Data/Hora   : 28/02/2014
Obs         : 
*/                 
*--------------------------*
Static Function Clean(cOpc) 
*--------------------------*
Local cArqZip := DTOS(date())+".RAR"

GrvLog("Iniciado Clean '"+ALLTRIM(cOpc)+"' - "+TIME())

Do Case
	Case cOpc == "MIGRACAO"
		aDirMIG := Directory("\MIGRACAO\*.*","D")		
		For i:=1 to Len(aDirMIG)
			If !(aDirMIG[i][1] $ "./..") .And. !(SUBSTR(aDirMIG[i][1],RAT(".",aDirMIG[i][1]),LEN(aDirMIG[i][1])) $ ".RAR/.ZIP")
				compacta("\MIGRACAO\"+aDirMIG[i][1],"\MIGRACAO\BACKUP.RAR")
			EndIf
		Next i
		If File("\MIGRACAO\BACKUP.RAR")
			FErase("\MIGRACAO\BACKUP.RAR")
		EndIf
		If ExistDir("\MIGRACAO")
			DirRemove("\MIGRACAO") 
		EndIf
		If ExistDir("\MIGRAÇÃO")
			DirRemove("\MIGRAÇÃO")
		EndIf
		/*
		aDirMIG := Directory("\MIGRACAO\*.*","D")		
		While Len(aDirMIG) > 2
			If Len(aDirMIG) <= 2
				DirRemove("\MIGRACAO\"+aDirBKP[i][1])
			Else
				For i:=1 to Len(aDirMIG)
					If !(aDirMIG[i][1] $ "./..")
						DropDir("\MIGRACAO\"+aDirMIG[i][1],aDirMIG[i][5])
					EndIf
				Next i
			EndIf
			aDirMIG := Directory("\MIGRACAO\*.*","D")		
		EndDo
		*/
	Case cOpc == "PSWBACKUP"
		aDirPSW := Directory("\PSWBACKUP\*.*","D")
		For i:=1 to Len(aDirPSW)
			If !(aDirPSW[i][1] $ "./..") .And. !(SUBSTR(aDirPSW[i][1],RAT(".",aDirPSW[i][1]),LEN(aDirPSW[i][1])) $ ".RAR/.ZIP")
				compacta("\PSWBACKUP\"+aDirPSW[i][1],"\PSWBACKUP\PSWBACKUP.RAR")
			EndIf
		Next i	

		
	Case cOpc == "SYSTEM"
		aArqDel := {"*.AMT","*.BAK","*.LOG","*.#nu","*.LCK","*.#db","*.#fp","*.#cf"}
		For z:=1 to Len(aArqDel)
			aDirSYS := Directory("\SYSTEM\"+aArqDel[z],"D")
			For i:=1 to Len(aDirSYS)
				//If aDirSYS[i][5] == "A"
					FErase("\SYSTEM\"+aDirSYS[i][1])
				//EndIf
			Next i	
		Next z		
		
	Case cOpc == "BKP"
		aDirBKP := Directory("\BKP\*.*","D")
		For i:=1 to Len(aDirBKP)
			If !(aDirBKP[i][1] $ "./..") 
				If ExistDir("\BKP\"+aDirBKP[i][1])
					aDirBKPFol := Directory("\BKP\"+aDirBKP[i][1]+"\*.*","D")
					For j:=1 to Len(aDirBKPFol)
						If !(aDirBKPFol[j][1] $ "./..") .And. !(SUBSTR(aDirBKPFol[j][1],RAT(".",aDirBKPFol[j][1]),LEN(aDirBKPFol[j][1])) $ ".RAR/.ZIP")
							compacta("\BKP\"+aDirBKP[i][1]+"\"+aDirBKPFol[j][1],"\BKP\"+aDirBKP[i][1]+"\"+cArqZip)
						EndIf
					Next j
				EndIf
			EndIf
		Next i
EndCase

GrvLog("Finalizado Clean '"+ALLTRIM(cOpc)+"' - "+TIME())

Return .T.

/*
Funcao      : GrvLog
Parametros  : 
Retorno     : 
Objetivos   : Grava o arquivo com o conteudo passado
Autor       : Jean Victor Rocha
Data/Hora   : 28/02/2014
Obs         : 
*/                 
*----------------------------*
Static Function GrvLog(cTexto) 
*----------------------------*
Local nHandle := 0
Local cArquivo := "\BKP\"+cArqlog

If File(cArquivo)
	nHandle := Fopen(cArquivo,2)
Else
	nHandle := FCreate(cArquivo, 0)
EndIf
                
FSeek(nHandle,0,2)
FWRITE(nHandle, cTexto+CHR(13)+CHR(10) )
fclose(nHandle)

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : 
Data/Hora   : 
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet:=WaitRunSrv( cCommand , lWait , cPath )
/* COMANDOS RAR
    a       Adicionar arquivos ao arquivo.
            Exemplo:
            criar ou atualizar o arquivo existente myarch, adicionado todos os
            arquivos no diretório atual
            rar a myarch
   -ep1    Excluir diretório base dos nomes. Não salvar o caminho fornecido na
            linha de comandos.
            Exemplo:
            todos os arquivos e diretórios do diretório tmp serão adicionados
            ao arquivo 'pasta', mas o caminho não incluirá 'tmp\'
            rar a -ep1 -r pasta 'tmp\*'
            Isto é equivalente aos comandos:
            cd tmp
            rar a -r pasta
            cd ..
    -o+     Substituir arquivos existentes.
    m[f]    Mover para o arquivo [apenas arquivos]. Ao mover arquivos e
            diretórios irá resultar numa eliminação dos arquivos e
            diretórios após uma operação de compressão bem sucedida.
            Os diretórios não serão removidos se o modificador 'f' for
            utilizado e/ou o comando adicional '-ed' for aplicado.    */

Return(lRet)

/*
Funcao      : DropDir
Parametros  : 
Retorno     : lRet
Objetivos   : Função para Apagar diretorio, possibilidade de recursividade
Autor       : Jean Victor Rocha
Data/Hora   : 28/02/2014
*/
*----------------------------*
Static Function DropDir(cDest,cTipo)
*----------------------------*
Local x
Local aDirDrop := {}
Local cDestLocal := cDest


//If cTipo == "A" .and. File(cDestLocal)
If cTipo <> "D" .and. cTipo <> "AD" .and. File(cDestLocal)
	FErase(cDestLocal)
ElseIf ExistDir(cDestLocal)
	aDirDrop := Directory(cDestLocal+"\*.*","D")
	If Len(aDirDrop) <= 2
		DirRemove(cDestLocal)
	Else
		For x:=1 to len(aDirDrop)
			If !(aDirDrop[x][1] $ "./..")
				DropDir(cDestLocal+"\"+aDirDrop[x][1],aDirDrop[x][5])
			EndIf
		Next x
	EndIf
EndIf

Return .T.