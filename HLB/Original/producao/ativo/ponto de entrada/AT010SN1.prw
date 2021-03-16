#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : AT010SN1
Parametros  : Nenhum
Retorno     : aCposSN1
Objetivos   : P.E. Para alterar campos no SN1
Autor       : Renato Rezende
Data/Hora   : 01/08/2014
Obs         : 
TDN         : http://tdn.totvs.com/pages/releaseview.action?pageId=46075020
Obs         : 
Cliente     : Todos
*/                 
*--------------------------*
 User Function AT010SN1() 
*--------------------------*
Local aCposSN1 := paramixb [1]
 
AAdd(aCposSN1,"N1_P_OBS")

If cEmpAnt == 'XC'//Dialogic 
	//RRP - 30/10/2014 - Inclusão do campo para alterar. Chamado 021841.
	AAdd(aCposSN1,"N1_PRODUTO")

ElseIf cEmpAnt == '6W'//Yahoo
	//RRP - 27/01/2015 - Inclusão do campo para alterar. Chamado 023893.
	AAdd(aCposSN1,"N1_P_NFIMP")
EndIf
 
Return aCposSN1