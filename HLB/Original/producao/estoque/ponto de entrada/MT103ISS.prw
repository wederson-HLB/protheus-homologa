#include "protheus.ch"

/*
Funcao      : MT103ISS
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para alimentar as informa��es do ISS no momento da cria��o do titulo no ativo fixo.
TDN			: Este PE � chamado no momento de grava��o do t�tulo da nota fiscal, onde seu retorno atribui valores a serem alterados nas vari�veis CFORNISS, CLOJAISS, CDIRF, CCODRET e DVENCISS que ser�o transportados no t�tulo de ISS caso exista para esta NF.
Autor       : Jo�o Silva
M�dulo      : Estoque Custos  
Empresa     : Todos
*/

*------------------------*
User Function MT103ISS
*------------------------*

Local cFornIss  := PARAMIXB[1]      // C�digo do fornecedor de ISS atual para grava��o.
Local cLojaIss  := PARAMIXB[2]      // Loja do fornecedor de ISS atual para grava��o.
Local cDirf     := PARAMIXB[3]      // Indicador de gera dirf atual para grava��o.
Local cCodRet   := PARAMIXB[4]      // C�digo de reten��o do t�tulo de ISS atual para grava��o.
Local dVcIss    := PARAMIXB[5]      // Data de vencimento do t�tulo de ISS atual para grava��o.
Local aRet      := {}

	aAdd( aRet , 'MUNIC')  //Cod Forn ISS
	aAdd( aRet , '00')     //Cod Loja Forn ISS
	aAdd( aRet , '1')      //Gera Dirf ? - 1=Sim, 2=Nao
	aAdd( aRet , '4206')   //Codigo de Receita
	aAdd( aRet , dVcIss)   //Vencimento ISS

Return (aRet)
