#Include "Protheus.ch"

/*
Funcao      : GTCORP37
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z81 (Cadastro de Servi�os)
Autor       : Matheus Massarotto
Data/Hora   : 13/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP37
*---------------------*
Local cAlias := "Z81"
Local cTitulo := "Cadastro de Servi�o"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return