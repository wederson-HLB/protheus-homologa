#Include "Protheus.ch"

/*
Funcao      : GTCORP36
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z82 (Cadastro de �rea)
Autor       : Matheus Massarotto
Data/Hora   : 13/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP36
*---------------------*
Local cAlias := "Z82"
Local cTitulo := "Cadastro de �rea
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return