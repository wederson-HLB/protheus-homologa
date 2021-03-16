#include "rwmake.ch"
//LP PARA CONTA DÉBITO DE ACORDO COM O ARMAZEM DO PRODUTO
User Function LPARM_D()                

_Cta := " " 

If cEmpAnt $ "LP/K2"

if SD1->D1_LOCAL=="01"
	_Cta:="113110002"
elseif SD1->D1_LOCAL=="02"
	_Cta :="113110005"
elseif SD1->D1_LOCAL=="03"
	_Cta :="113110012"
elseif SD1->D1_LOCAL=="21"
	_Cta :="113110013"
elseif SD1->D1_LOCAL=="22"
	_Cta :="113110014"
endif

      
EndIf


Return(_Cta)

