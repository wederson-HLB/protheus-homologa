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
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return