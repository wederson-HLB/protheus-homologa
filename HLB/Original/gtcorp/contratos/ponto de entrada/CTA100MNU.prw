#include 'Protheus.ch'  

/*
Funcao      : CTA100MNU
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Inclusão de botão referente definição de itens da nota de débito
Autor       : 
TDN         : Function CNTA100 - Rotina responsável pela Manutenção de Contratos. Antes de montar a tela do browser. Para adicionar botões no menu principal da rotina.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/ 

*-------------------------*
 User Function CTA100MNU()    
*-------------------------*

Private cAlias := GetArea()

AADD(aRotina,{ "N.Deb. Reembolsavel" , "U_CADZZ9()", 0 ,6 })  //"Browse do Contrato - Nota de Debito"

Return


