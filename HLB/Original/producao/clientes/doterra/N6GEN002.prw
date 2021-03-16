#Include 'Protheus.Ch'

/*			  
Funcao      : N6GEN002 
Parametros  : aData
Retorno     : .T.
Objetivos   : Grava na ZX2 arquivo de log a partir de qualquer rotina externa
Autor       : William Souza
Cliente		: Solaris 
Data/Hora   : 20/11/2016
*/
*---------------------------------------------------------------*
 User Function N6GEN002(cAlias,cTipo,cSerWs,cFrom,cTo,cChave,cConteu,cErro)
*---------------------------------------------------------------*

DbSelectArea("ZX2")
RecLock("ZX2",.T.)
	ZX2->ZX2_FILIAL := xFilial("ZX2")
	ZX2->ZX2_ALIAS	:= cAlias
	ZX2->ZX2_TIPO	:= cTipo
    ZX2->ZX2_SERWS	:= cSerWs
	ZX2->ZX2_FROM   := cFrom
	ZX2->ZX2_TO     := cTo
	ZX2->ZX2_CHAVE	:= cChave
	ZX2->ZX2_DATA	:= Date()
	ZX2->ZX2_HORA	:= Time() 
	ZX2->ZX2_CONTEU	:= cConteu 
	ZX2->ZX2_ERRO	:= cErro
	ZX2->(MsUnlock())
Return .T.
