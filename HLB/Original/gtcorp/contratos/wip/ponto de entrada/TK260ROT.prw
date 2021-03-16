#Include "Protheus.ch"

/*
Funcao      : TK260ROT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de entrada para adi��o de itens ao aRotina
TDN			: Esse ponto de entrada � executado antes da montagem do submenu da rotina e tem como objetivo a inclus�o de novas op��es de rotinas do submenu.
Autor       : Matheus Massarotto
Data/Hora   : 26/08/2013    10:14
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gest�o de Contratos/Faturamento
*/

*---------------------*
User function TK260ROT
*---------------------*
Local aRotina:={}

aAdd(aRotina,{ "Empresas","U_GTCORP80", 0 , 4 , , .T. })  

Return(aRotina)