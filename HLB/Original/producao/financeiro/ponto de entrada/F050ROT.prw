#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : F050ROT
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : Ponto de Entrada que permite modificar os itens de menu do browse de sele��o de t�tulos a pagar, 
				por meio da edi��o da vari�vel aRotina (passada como par�metro no Ponto de Entrada). O retorno 
				deve conter a vari�vel aRotina customizada, com as op��es que podem ser selecionadas.
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
	If IsInCallStack("FINA050")
		//aAdd( aRet,	{"Imp. Capinha","U_6WEST001",0,3,,.F.})        //CAS - 17/02/2020 - Antiga do Financeiro
		  aAdd(aRet,    {'Imp Capinha', 'U_6WEST001()',0, 5})		   //CAS - 17/02/2020 - Copiada do Estoque - PE MA103OPC 
	EndIF
EndIf

Return aRet