#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MTA140MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : Adicionar bot�es ao Menu Principal atrav�s do array aRotina.
Revis�o     : Renato Rezende
Data/Hora   : 26/08/2014
M�dulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MTA140MNU
*-------------------------*

If cEmpAnt $ "SU"
	aAdd(aRotina,{"Impr. Etiquetas", "U_SUGEN003", 0 , 6, 0, nil})
EndIf

Return