#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#Include "tbiconn.ch"

/*
Funcao      : O5GEN001 
Parametros  : cAlias,cChave,lInclui,cContInt,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX1 arquivo de log
Autor       : Anderson Arrais
Data/Hora   : 10/01/2019
*/
*----------------------------------------------------*
 User Function O5GEN001(cNumBco,cNumTit,cNumBor,cLog)
*----------------------------------------------------*

DbSelectArea("ZX1")
RecLock("ZX1",.T.)
	ZX1->ZX1_FILIAL		:= xFilial("ZX1")
	ZX1->ZX1_DATA		:= DATE()
	ZX1->ZX1_HORA		:= TIME() 
	ZX1->ZX1_NOSNUM		:= cNumBco
	ZX1->ZX1_ID			:= AllTrim(RetCodUsr())
	ZX1->ZX1_USR		:= AllTrim(UsrRetName(RetCodUsr()))
	ZX1->ZX1_NUMTIT		:= cNumTit //E1_PREFIXO+E1_NUM+E1_PARCELA 
	ZX1->ZX1_NUMBOR		:= cNumBor
    ZX1->ZX1_HIST		:= cLog
ZX1->(MsUnlock())

Return .T.