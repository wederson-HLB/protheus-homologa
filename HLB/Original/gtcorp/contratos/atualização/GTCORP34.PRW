#Include "Protheus.ch"

/*
Funcao      : GTCORP34
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z84 (Cadastro de Respons�vel) 
Autor       : Matheus Massarotto
Data/Hora   : 13/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP34
*---------------------*
Local cAlias := "Z84"
Local cTitulo := "Cadastro de Respons�vel"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return