#Include "Protheus.ch"

/*
Funcao      : GTCORP34
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z84 (Cadastro de Responsável) 
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
Local cTitulo := "Cadastro de Responsável"
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return