#include "rwmake.ch"    

User Function LP610_16()  // LP 610-016 CONTA DEBITO



SetPrvt("_CNTCRED,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CTES")


_cntCred:=SPACE(15)


IF SM0->M0_CODIGO = 'R7'

	_cntCred:= "31213003"
	
ELSEIF  SM0->M0_CODIGO = 'EQ' //SALTON  

	_cntCred:= "311105060"

ELSE                      

	_cntCred:= "311105056"

Endif


RETURN(_cntCred)

