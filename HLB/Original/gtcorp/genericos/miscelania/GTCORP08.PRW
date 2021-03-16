#include "protheus.ch"

/*
Funcao      : GTCORP08
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela para visualização da tabela Z91, logs de registros de inclusão/exclusão de notas automáticas no sistema.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 02/04/2012    17:36
Módulo      : Genérico
*/

/*
Funcao      : GTCORP08()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Gerar tela padrão Axcadastro
Autor       : Matheus Massarotto
Data/Hora   : 02/04/2012
*/

User Function GTCORP08()

Local cAlias := "Z91"

Private cCadastro := "Log de inclusão de Fat/Nd GT"
Private aRotina := {}

	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(6,1,22,75,cAlias)

Return Nil