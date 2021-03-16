#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
User Function LP53002CCD()  
_CCUSTO := " " 
IF cEmpAnt $ "M1"
	_CCUSTO:= "1100"
ELSEIF cEmpAnt $ "HO"   //ALPUNTO
	_CCUSTO:= "1101"
ELSE
	_CCUSTO:="1000"
ENDIF
Return(_CCUSTO)        