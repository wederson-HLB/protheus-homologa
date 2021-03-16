#Include 'Protheus.Ch'

/*
Funcao      : HHGEN001 
Parametros  : cAlias,cChave,lInclui,cContInt,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX1 arquivo de log a partir de qualquer rotina externa
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 20/11/2016
*/
*---------------------------------------------------------------*
 User Function HHGEN001(cAlias,cChave,lInclui,cContInt,cArqLog)
*---------------------------------------------------------------*
Local cIncAlt	:= ""

//Cria Tabela de Log
ChkFile("ZX1")

If lInclui
	cIncAlt:= "I"
Else
	cIncAlt:= "A"
EndIf

DbSelectArea("ZX1")
RecLock("ZX1",.T.)
	ZX1->ZX1_FILIAL := xFilial("ZX1")
	ZX1->ZX1_ALIAS	:= cAlias
	ZX1->ZX1_TIPO	:= cIncAlt 
	ZX1->ZX1_CHAVE	:= cChave
	ZX1->ZX1_DATA	:= Date()
	ZX1->ZX1_HORA	:= Time()  
	ZX1->ZX1_CONTEU	:= cContInt 
	ZX1->ZX1_ERRO	:= cArqLog
ZX1->(MsUnlock())

Return .T.