#INCLUDE "PROTHEUS.CH"

/*
Funcao      : GTCORP69
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : 
Autor       : Matheus Massarotto
Data/Hora   : 15/07/2013    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de contratos
*/

*----------------------*
User Function GTCORP69()  
*----------------------*

Local cAlias := "Z58"
Local cTitulo := "Cadastro de divisões"
Local cVldExc := ".T."
Local cVldAlt := ".T."

dbSelectArea(cAlias)
dbSetOrder(1)

AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return Nil