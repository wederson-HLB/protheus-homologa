#Include "Protheus.ch"

/*
Funcao      : AxCadZZK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro da tabela ZZK
Autor     	: 	 	
Data     	: 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Gestão Pessoal.
Cliente     : 
*/  

*-----------------------*
 User Function AxCadZZK
*-----------------------*

Private cAlias    := "ZZK"
Private aRotina   := {}
Private cCadastro := "De Para Interface RH"

AAdd( aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1})
AAdd( aRotina, {"Visualizar", "AxVisual"   , 0, 2})
AAdd( aRotina, {"Incluir"   , "AxInclui"   , 0, 3})
AAdd( aRotina, {"Alterar"   , "AxAltera"   , 0, 4})
AAdd( aRotina, {"Excluir"   , "AxDeleta"   , 0, 5})
AAdd( aRotina, {"Exportar txt"   , "U_DPZZKTXT"   , 0, 3})

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(,,,,cAlias)



Return