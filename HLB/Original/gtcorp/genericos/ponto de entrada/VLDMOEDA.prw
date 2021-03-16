#INCLUDE "PROTHEUS.CH"
/*
Funcao      : VldMoeda()
Parametros  : Nenhum
Retorno     : lValido
Objetivos   : Ponto de entrada executado na ação de confirmar quando é informado a taxa da moeda.
Autor       : João.silva
Data/Hora   : 11/08/2015
Módulo      : Genérico.
*/
*----------------------*
User Function VldMoeda() 
*----------------------*
Local aValores := ParamIxb[1]
Local cModule	:= ParamIxb[2] 
Local lValido := .F. 

//Não aceita nenhuma imput via tela.
MsgInfo("Usuário sem acesso para realizar alterações de moedas por esta tela. Apenas opção de 'Cancelar' esta ativa.","Grant Thornton")

Return lValido