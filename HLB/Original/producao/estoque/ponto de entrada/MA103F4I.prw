#include "Rwmake.ch"   
#include "Protheus.ch"
   
/*
Funcao      : MA103F4I
Retorno     : aRet
Objetivos   : Inclusão de campo no browser da tela de pedido no documento de entrada
Autor       : Anderson Arrais
Data/Hora   : 26/08/2019
*/
*-----------------------*
User Function MA103F4I()      
*-----------------------*
Local aRet:= {}
	If cEmpAnt $ "ZJ"
		aRet:= {SC7->C7_P_PO}
	EndIf
return aRet