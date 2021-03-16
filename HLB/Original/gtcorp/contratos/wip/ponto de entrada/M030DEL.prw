#include 'Totvs.ch'

*---------------------*
User Function M030DEL()
*---------------------*
Local lRet := .T.

Local cCodSA1 := SA1->A1_COD
Local cLojSA1 := SA1->A1_LOJA

BeginSql Alias 'TMPZ55'
	SELECT Z55_NUM,Z55_REVISA 
	FROM %table:Z55%
	WHERE %notDel%
	  AND Z55_CLIENT = %exp:cCodSA1%
	  AND Z55_LOJA = %exp:cLojSA1%
EndSql

TMPZ55->(DbGoTop())
If TMPZ55->(!EOF() .and. !BOF())
	MsgInfo("Esse cliente não pode ser excluído porque está vinculado a proposta: "+ Alltrim(TMPZ55->Z55_NUM))
	lRet := .F.
EndIf

TMPZ55->(DbCloseArea())

Return lRet
 