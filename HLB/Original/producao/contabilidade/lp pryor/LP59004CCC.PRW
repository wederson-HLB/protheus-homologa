
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP59004CCC()  
_CCUSTO := " " 
IF cEmpAnt $ "M1"
	_CCUSTO:= "1100" 
ElseIf cEmpAnt $ "4Z" //RSB - 04/12/2017 - Centro de Custo fixado. Ticket #20348 
	_CCUSTO:= "900005" 
ELSE
	_CCUSTO:="1000"
ENDIF  

Return(_CCUSTO)        