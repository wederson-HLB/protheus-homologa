#include "rwmake.ch"
//LP PARA CC DE ACORDO COM O ARMAZEM DO PRODUTO
User Function LPARMCC1()                

_CC := " " 

If cEmpAnt $ "LP/K2"

if SD1->D1_LOCAL=="01"
	_CC:="02"
elseif SD1->D1_LOCAL=="02"
	_CC:="02"
elseif SD1->D1_LOCAL=="03"
	_CC:="02"
elseif SD1->D1_LOCAL=="21"
	_CC:="01"
elseif SD1->D1_LOCAL=="22"
	_CC:="01"
endif

      
EndIf


Return(_CC)