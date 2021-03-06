#include "protheus.ch"

/*
Funcao      : GTCORP08
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tela para visualiza��o da tabela Z91, logs de registros de inclus�o/exclus�o de notas autom�ticas no sistema.
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 02/04/2012    17:36
M�dulo      : Gen�rico
*/

/*
Funcao      : GTCORP08()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Gerar tela padr�o Axcadastro
Autor       : Matheus Massarotto
Data/Hora   : 02/04/2012
*/

User Function GTCORP08()

Local cAlias := "Z91"

Private cCadastro := "Log de inclus�o de Fat/Nd GT"
Private aRotina := {}

	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(6,1,22,75,cAlias)

Return Nil