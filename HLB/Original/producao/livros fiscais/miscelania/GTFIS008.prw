#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Funcao      : GTFIS008
Parametros  : Nil                      
Objetivos   : Cadastro anvisa para complemento fiscal de produto
Autor       : Anderson Arrais
Data	    : 27/09/2018
Módulo      : Genérico
*/
*---------------------*
User Function GTFIS008
*---------------------*
Local oBrowse

Private aRotina		 := MenuDef() 
Private cCadastro	 := 'Cadastro Anvisa complemento de produto'

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'F2Q' )
oBrowse:SetDescription( cCadastro )
oBrowse:Activate()

Return NIL

/*
Função		: MenuDef
Objetivo	: Criação do menu funcional
Autor		: Anderson Arrais
Data 		: 30/11/2016
*/
*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
               { "Visualizar"   ,"AxVisual" , 0, 2},;
               { "Incluir"      ,"AxInclui" , 0, 3},;
               { "Alterar"      ,"AxAltera" , 0, 4},;
               { "Excluir"      ,"AxDeleta" , 0, 5} }               
               
Return aRotina