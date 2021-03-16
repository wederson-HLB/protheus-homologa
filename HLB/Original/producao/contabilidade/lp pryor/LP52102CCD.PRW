#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
User Function LP52102CCD()  
_CCUSTO := " " 
IF cEmpAnt $ "M1"
	_CCUSTO:= "1100"  
ELSEIF cEmpAnt $ "FI" //COVIT
	_CCUSTO:= "1600"  
ELSE
	_CCUSTO:="1000"
ENDIF
Return(_CCUSTO)        