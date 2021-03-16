#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'

*-------------------------------------------------------------------------*
WsService GED Description "Realiza integrações para serem usadas pelo GED."
*-------------------------------------------------------------------------*
WsData cCliente	as String
WsData aRet		as Array of GEDRetorno

WsMethod GEDGETFORN Description "Retorna os dados do Fornecedor."

EndWsService

//Definição do Array Retorno
*-----------------*
WSSTRUCT GEDRetorno
*-----------------*
WSDATA Codigo 		as String
WSDATA Razao		as String
WSDATA CNPJ			as String
ENDWSSTRUCT

*----------------------------------------------------------------*
WsMethod GEDGETFORN WsReceive cCliente WsSend aRet WsService GED
*----------------------------------------------------------------*
Local i		:= 1

If Empty(cCliente)
	Return .T.
EndIf

//Define a tabela
cQry := "Select Codigo as CODIGO, Razao as RAZAO, CNPJ as CNPJ
cQry += " From Fluig_Aux.dbo.FK_FORNECEDOR
cQry += " Where Cliente = '"+Upper(AllTrim(cCliente))+"'

If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQry),"QRY",.F.,.F.)

QRY->(DBGoTop())
While QRY->(!EOF())
	aAdd(::aRet,WSClassNew("GEDRetorno"))
	::aRet[i]:Codigo		:= ALLTRIM(QRY->CODIGO)
	::aRet[i]:Razao			:= ALLTRIM(QRY->RAZAO)
	::aRet[i]:CNPJ			:= ALLTRIM(QRY->CNPJ)
	i++
	QRY->(DbSkip())
EndDo

Return .T.