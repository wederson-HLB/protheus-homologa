#include "protheus.ch"

/*
Funcao      : MT103ISS
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para alimentar as informações do ISS no momento da criação do titulo no ativo fixo.
TDN			: Este PE é chamado no momento de gravação do título da nota fiscal, onde seu retorno atribui valores a serem alterados nas variáveis CFORNISS, CLOJAISS, CDIRF, CCODRET e DVENCISS que serão transportados no título de ISS caso exista para esta NF.
Autor       : João Silva
Módulo      : Estoque Custos  
Empresa     : Todos
*/

*------------------------*
User Function MT103ISS
*------------------------*

Local cFornIss  := PARAMIXB[1]      // Código do fornecedor de ISS atual para gravação.
Local cLojaIss  := PARAMIXB[2]      // Loja do fornecedor de ISS atual para gravação.
Local cDirf     := PARAMIXB[3]      // Indicador de gera dirf atual para gravação.
Local cCodRet   := PARAMIXB[4]      // Código de retenção do título de ISS atual para gravação.
Local dVcIss    := PARAMIXB[5]      // Data de vencimento do título de ISS atual para gravação.
Local aRet      := {}

	aAdd( aRet , 'MUNIC')  //Cod Forn ISS
	aAdd( aRet , '00')     //Cod Loja Forn ISS
	aAdd( aRet , '1')      //Gera Dirf ? - 1=Sim, 2=Nao
	aAdd( aRet , '4206')   //Codigo de Receita
	aAdd( aRet , dVcIss)   //Vencimento ISS

Return (aRet)
