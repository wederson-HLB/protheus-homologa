#Include "Protheus.ch"

/*
Funcao      : GTCORP37
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z81 (Cadastro de Serviços)
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
Local cTitulo := "Cadastro de Serviço"
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return