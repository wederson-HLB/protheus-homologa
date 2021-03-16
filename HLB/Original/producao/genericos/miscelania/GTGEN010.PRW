#Include "rwmake.ch"
#include "fileio.ch"  
#include "protheus.ch"
/*
Funcao      : GTGEN010
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina para backup dos menus e do Sigapss.
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 25/01/2013
Módulo      : 
*/
*----------------------*
User function GTGEN010()
*----------------------*
Local i
Local cLog		:= ""
Local cDestino	:= 		"\SYSTEM\BKP_CFG"
Local aDir := Directory("\SYSTEM\*.XNU","D")

//Verifica pasta de bkp, caso nao exista, cria.
If !File(cDestino)
	MakeDir(cDestino)
EndIf

//Faz Backup dos arquivos.
If Len(aDir) > 0          
	cFolder := cDestino+"\"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")
	MAKEDIR(cFolder)//cria pasta do dia.
	For i:= 1 to len(aDir)
		__CopyFile( "\SYSTEM\"+aDir[i][1], cFolder+"\"+aDir[i][1] )
	Next i
EndIf

If FILE("\SYSTEM\SIGAPSS.SPF")
	__CopyFile( "\SYSTEM\SIGAPSS.SPF", cFolder+"\SIGAPSS.SPF" )
EndIf


Return .T.