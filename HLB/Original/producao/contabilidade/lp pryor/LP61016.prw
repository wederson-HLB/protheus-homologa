#include "rwmake.ch"        // incluido em 22/09/09

User Function lp61016()     // LP 610-016 CONTA DEBITO



SetPrvt("_CNTCRED,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CTES")


_cntCred:=SPACE(15)


IF SM0->M0_CODIGO = 'R7'

	_cntCred:= "311105055"
	
ELSEIF  SM0->M0_CODIGO = 'EQ' //SALTON  

	_cntCred:= "311105060"
	 
ELSEIF  SM0->M0_CODIGO $ 'IL/JM' //HARRIS / THERMO FISHER JSS-20140724  

	_cntCred:= "311105051"

ELSE                      

	_cntCred:= "311105056"

Endif


RETURN(_cntCred)

