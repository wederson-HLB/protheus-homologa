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
TDN         : Adicionar botões ao Menu Principal através do array aRotina.
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MTA140MNU
*-------------------------*

If cEmpAnt $ "SU"
	aAdd(aRotina,{"Impr. Etiquetas", "U_SUGEN003", 0 , 6, 0, nil})
EndIf

Return