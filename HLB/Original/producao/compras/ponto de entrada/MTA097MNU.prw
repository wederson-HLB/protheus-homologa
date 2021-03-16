#INCLUDE "PROTHEUS.CH"

/*
Funcao      : MTA097MNU
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para adiciona bot�es ao Menu Principal atrav�s do array aRotina
Autor       : Renato Rezende
Data/Hora   : 26/05/17     
Obs         : 
TDN         : Function MenuDef - Adiciona bot�es ao Menu Principal atrav�s do array aRotina
M�dulo      : Compras.
Cliente     : Todos
*/
*---------------------------------*
 User Function MTA097MNU()          
*---------------------------------*

If cEmpAnt == "49"
	aAdd(aRotina,{ "Conhecimento", "U_49COM001", 0 , 6, 0, Nil})	
EndIf

Return