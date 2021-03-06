#Include "Protheus.ch"

/*
Funcao      : GTCORP38
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z80 (Cadastro Departamento x �rea x Servi�o) 
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
Local cTitulo := "Cadastro de Departamento x �rea x Servi�o"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return