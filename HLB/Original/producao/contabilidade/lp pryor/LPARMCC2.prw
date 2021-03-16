#include "rwmake.ch"
//LP PARA CC DE ACORDO COM O ARMAZEM DO PRODUTO
User Function LPARMCC2()                

_CC := " " 

If cEmpAnt $ "LP/K2"

if SD2->D2_LOCAL=="01"
	_CC:="02"
elseif SD2->D2_LOCAL=="02"
	_CC:="02"
elseif SD2->D2_LOCAL=="03"
	_CC:="02"
elseif SD2->D2_LOCAL=="21"
	_CC:="01"
elseif SD2->D2_LOCAL=="22"
	_CC:="01"
endif

      
EndIf


Return(_CC)