#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MT460EST
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : O ponto de Entrada é chamado antes do estorno do SC9. O arquivo posicionado no momento é o SC9.
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MT460EST
*-------------------------*
Local _aArea,_aAreaC5 

If cEmpAnt $ "SU/LG"
	_aArea := GetArea()
	_aAreaC5 := SC5->(GetArea())
	
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial()+SC9->C9_PEDIDO))
		RecLock("SC5",.F.)
		SC5->C5_P_STACO := ""
		SC5->(MsUnLock())
	EndIf
	RestArea(_aAreaC5)
	RestArea(_aArea)
EndIf

Return(.T.)