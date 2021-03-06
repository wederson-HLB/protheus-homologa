#Include "Protheus.ch"

/*
Funcao      : GTCORP35
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z83 (Cadastro de Departamento)
Autor       : Matheus Massarotto
Data/Hora   : 13/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP35
*---------------------*
Local cAlias := "Z83"
Local cTitulo := "Cadastro de Departamento"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return