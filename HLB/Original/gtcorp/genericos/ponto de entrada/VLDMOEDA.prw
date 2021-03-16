#INCLUDE "PROTHEUS.CH"
/*
Funcao      : VldMoeda()
Parametros  : Nenhum
Retorno     : lValido
Objetivos   : Ponto de entrada executado na a��o de confirmar quando � informado a taxa da moeda.
Autor       : Jo�o.silva
Data/Hora   : 11/08/2015
M�dulo      : Gen�rico.
*/
*----------------------*
User Function VldMoeda() 
*----------------------*
Local aValores := ParamIxb[1]
Local cModule	:= ParamIxb[2] 
Local lValido := .F. 

//N�o aceita nenhuma imput via tela.
MsgInfo("Usu�rio sem acesso para realizar altera��es de moedas por esta tela. Apenas op��o de 'Cancelar' esta ativa.","Grant Thornton")

Return lValido