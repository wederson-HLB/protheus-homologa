#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : F050ROT
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : Ponto de Entrada que permite modificar os itens de menu do browse de seleção de títulos a pagar, 
				por meio da edição da variável aRotina (passada como parâmetro no Ponto de Entrada). O retorno 
				deve conter a variável aRotina customizada, com as opções que podem ser selecionadas.
Autor       : Jean Victor Rocha
Data/Hora   : 30/01/2015
TDN         : http://tdn.totvs.com/display/public/mp/F050ROT+-+Inclui+itens+de+menu+--+107531;jsessionid=9A94C085D37AFFF217C859748BE40D1C
Modulo      : 
*/
*---------------------*
User Function F050ROT()
*---------------------*
Local aRet := ParamIXB

If cEmpAnt $ "6W"
	aAdd( aRet,	{"Imp. Capinha","U_6WEST001",0,3,,.F.})
EndIf

Return aRet