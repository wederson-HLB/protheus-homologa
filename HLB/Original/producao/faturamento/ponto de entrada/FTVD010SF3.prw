#include 'Protheus.ch'

/*
Funcao      : FTVD010SF3
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para gerar fiscal, usado nesse caso para evitar que fonte entre na função LjGrvFin e gere erro no SE1
Autor     	: Anderson Arrais
Data     	: 15/09/2016
Obs         : 
Módulo      : Faturamento
Cliente     : AESOP
*/

*-----------------------*
User Function FTVD010SF3 
*-----------------------*

// Altera o conteúdo da variavel padrão lPedFin para .T. assim evita de entrar na função LjGrvFin
If cEmpAnt $ "FG"
	lPedFin = .T.
EndIf

Return