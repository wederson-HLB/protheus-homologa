#Include "Protheus.ch"

/*
Funcao      : GTCORP90
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z32 (Cadastro de Ramo de atividade de cliente) 
Autor       : Matheus Massarotto
Data/Hora   : 28/04/2014
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP90
*---------------------*
Local cAlias := "Z32"
Local cTitulo := "Cadastro de Segmento/Ramo de Atividade"
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return