#include 'Protheus.ch'  

/*
Funcao      : CTA100MNU
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Inclus�o de bot�o referente defini��o de itens da nota de d�bito
Autor       : 
TDN         : Function CNTA100 - Rotina respons�vel pela Manuten��o de Contratos. Antes de montar a tela do browser. Para adicionar bot�es no menu principal da rotina.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Contratos.
*/ 

*-------------------------*
 User Function CTA100MNU()    
*-------------------------*

Private cAlias := GetArea()

AADD(aRotina,{ "N.Deb. Reembolsavel" , "U_CADZZ9()", 0 ,6 })  //"Browse do Contrato - Nota de Debito"

Return


