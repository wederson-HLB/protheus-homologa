#include "rwmake.ch"
//LP PARA CONTA CRÉDITO DE ACORDO COM O ARMAZEM DO PRODUTO
User Function LPARM_C1()                

_Cta := " " 

If cEmpAnt $ "LP/K2"

if SD1->D1_LOCAL=="01"
	_Cta:="113110003"
elseif SD1->D1_LOCAL=="02"
	_Cta :="113110023"
elseif SD1->D1_LOCAL=="03"
	_Cta :="113110024"
elseif SD1->D1_LOCAL=="21"
	_Cta :="113110025"
elseif SD1->D1_LOCAL=="22"
	_Cta :="113110026"
endif

      
EndIf


Return(_Cta)