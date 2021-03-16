#include "rwmake.ch"
//LP PARA CONTA DE ACORDO COM O ARMAZEM DO PRODUTO(item venda)
User Function LPARM_C2()                

_Cta := " " 

If cEmpAnt $ "LP/K2"

if SD2->D2_LOCAL=="01"
	_Cta:="113110002"
elseif SD2->D2_LOCAL=="02"
	_Cta :="113110005"
elseif SD2->D2_LOCAL=="03"
	_Cta :="113110012"
elseif SD2->D2_LOCAL=="21"
	_Cta :="113110013"
elseif SD2->D2_LOCAL=="22"
	_Cta :="113110014"
endif


      
EndIf


Return(_Cta)