#include "Protheus.ch"
#include "Rwmake.ch"
#include "TOPCONN.CH"
#Include "tbiconn.ch"

/*
Funcao      : QNGEN001 
Parametros  : cAlias,cChave,lInclui,cContInt,cConv,cArqLog
Retorno     : .T.
Objetivos   : Grava na ZX1 arquivo de log
Autor       : Anderson Arrais
Data/Hora   : 20/05/2019
*/
*----------------------------------------------------------*
 User Function QNGEN001(cNumBco,cNumTit,cNumBor,cConv,cLog)
*----------------------------------------------------------*

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
	ZX1->ZX1_CONV		:= AllTrim(cConv)
    ZX1->ZX1_HIST		:= cLog
ZX1->(MsUnlock())

Return .T.