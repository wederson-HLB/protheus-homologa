#include "Rwmake.ch"   
#include "Protheus.ch"
   
/*
Funcao      : MA103F4H
Retorno     : aRet
Objetivos   : Adiciona o titulo do campo informado no ponto de entrada MA103F4I
Autor       : Anderson Arrais
Data/Hora   : 26/08/2019
*/
*-----------------------*
User Function MA103F4H()
*-----------------------*
Local aRet:= {}
	If cEmpAnt $ "ZJ"
		aRet:= {"PO"}
	EndIf
return aRet