#Include 'Protheus.Ch'

/*
Funcao      : HHGEN002 
Parametros  : cAlias,cChave,lInclui,cContInt,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX2 arquivo de log de consumo de webservive
Autor       : Anderson Arrais
Cliente		: Solaris 
Data/Hora   : 09/05/2017
*/
*---------------------------------------------------------------*
 User Function HHGEN002(cAlias,cChave,lInclui,cContInt,cArqLog)
*---------------------------------------------------------------*
Local cIncAlt	:= ""

//Cria Tabela de Log
ChkFile("ZX2")

If lInclui
	cIncAlt:= "I"
Else
	cIncAlt:= "A"
EndIf

DbSelectArea("ZX2")
RecLock("ZX2",.T.)
	ZX2->ZX2_FILIAL := xFilial("ZX2")
	ZX2->ZX2_ALIAS	:= cAlias
	ZX2->ZX2_TIPO	:= cIncAlt 
	ZX2->ZX2_CHAVE	:= cChave
	ZX2->ZX2_DATA	:= Date()
	ZX2->ZX2_HORA	:= Time()  
	ZX2->ZX2_CONTEU	:= cContInt 
	ZX2->ZX2_ERRO	:= cArqLog
ZX2->(MsUnlock())

Return .T.