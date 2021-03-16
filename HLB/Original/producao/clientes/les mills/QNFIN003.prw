#Include "Protheus.Ch"
#Include "TopConn.Ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Funcao      : QNFIN003
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Cadastro de mensagem para envio de email do boleto
Autor       : Anderson Arrais
Data	    : 21/05/2019
*/
*---------------------*
User Function QNFIN003
*---------------------*
Local oBrowse

Private aRotina		 := MenuDef() 
Private cCadastro	 := 'Cadastro de Mensagens'


oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'ZX2' )
//oBrowse:SetOnlyFields( { 'ZX2_COD', 'ZX2_TITULO' } )
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
               { "Excluir"      ,"AxDeleta" , 0, 5}}               
               
Return aRotina 