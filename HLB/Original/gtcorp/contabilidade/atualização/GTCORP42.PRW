#Include "Protheus.ch"

/*
Funcao      : GTCORP42
Parametros  : 
Retorno     : 
Objetivos   : AxCadastro da tabela Z76 (Cadastro de Centro de Custo X Empresa) 
Autor       : Matheus Massarotto
Data/Hora   : 03/09/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*---------------------*
User function GTCORP42
*---------------------*
Local cAlias := "Z76"
Local cTitulo := "Cadastro de Centro Custo X Empresa"
Local cVldExc := ".T." // Valida��o para Exclus�o
Local cVldAlt := ".T." // Valida��o para Altera��o

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return