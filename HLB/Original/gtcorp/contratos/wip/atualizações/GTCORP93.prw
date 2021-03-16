#Include "Protheus.ch"

/*
Funcao      : GTCORP93
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z28 (Cadastro de concorrentes) 
Autor       : Matheus Massarotto
Data/Hora   : 22/09/2014
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP93
*---------------------*
Local cAlias := "Z28"
Local cTitulo := "Cadastro de concorrentes"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return