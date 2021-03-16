#include "rwmake.ch"        // incluido em 22/09/09

User Function lp61019()     // LP 610-016 CONTA DEBITO



SetPrvt("_CNTCRED,_CFOP1,_CFOP2,_CFOP3,_CFOP4,_CTES")


_cntCred:=SPACE(15)


IF  SM0->M0_CODIGO = 'EQ' //SALTON
	_cntCred:= "211220006"
EndIf    


RETURN(_cntCred)

