#Include "Protheus.ch"

/*
Funcao      : GTCORP36
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z82 (Cadastro de Área)
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
Local cTitulo := "Cadastro de Área
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return