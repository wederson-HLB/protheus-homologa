#INCLUDE "rwmake.ch"  

/*
Funcao      : LWFAT002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de tabela De/Para TES
Autor     	: Jean Victor Rocha
Data     	: 19/02/2014
Obs         : 
TDN         : 
*/
*----------------------*
User Function LWFAT002()
*----------------------*

Private cAlias    := "ZX1"
Private aRotina   := {}
Private cCadastro := "Cadastro De/Para TES"

AAdd( aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1} )
AAdd( aRotina, {"Visualizar", "AxVisual"   , 0, 2} )
AAdd( aRotina, {"Incluir"   , "AxInclui"   , 0, 3} )
AAdd( aRotina, {"Alterar"   , "AxAltera"   , 0, 4} )
AAdd( aRotina, {"Excluir"   , "AxDeleta"   , 0, 5} )

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(,,,,cAlias)

Return Nil