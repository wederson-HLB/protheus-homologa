#include 'Protheus.ch'

/*
Funcao      : FTVD010SF3
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para gerar fiscal, usado nesse caso para evitar que fonte entre na fun��o LjGrvFin e gere erro no SE1
Autor     	: Anderson Arrais
Data     	: 15/09/2016
Obs         : 
M�dulo      : Faturamento
Cliente     : AESOP
*/

*-----------------------*
User Function FTVD010SF3 
*-----------------------*

// Altera o conte�do da variavel padr�o lPedFin para .T. assim evita de entrar na fun��o LjGrvFin
If cEmpAnt $ "FG"
	lPedFin = .T.
EndIf

Return