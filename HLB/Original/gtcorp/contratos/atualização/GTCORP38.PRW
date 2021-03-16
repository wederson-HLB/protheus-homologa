#Include "Protheus.ch"

/*
Funcao      : GTCORP38
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z80 (Cadastro Departamento x Área x Serviço) 
Autor       : Matheus Massarotto
Data/Hora   : 13/08/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP38
*---------------------*
Local cAlias := "Z80"
Local cTitulo := "Cadastro de Departamento x Área x Serviço"
Local cVldExc := ".T." // Validação para Exclusão
Local cVldAlt := ".T." // Validação para Alteração

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return