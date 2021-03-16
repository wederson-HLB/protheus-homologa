#INCLUDE "PROTHEUS.CH"

/*
Funcao      : GTCORP70
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 15/07/2013    10:14
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gest�o de contratos
*/

*----------------------*
User Function GTCORP70()  
*----------------------*

Local cAlias := "Z57"
Local cTitulo := "Cadastro de natureza de servi�o"
Local cVldExc := ".T."
Local cVldAlt := ".T."

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return Nil