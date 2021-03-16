#Include "Rwmake.ch"
/*
	Matheus - 16/06/2011
	Criado para tratar múltiplas naturezas.
*/
User function LP51001_D
Local cRet:=""

if SE2->E2_MULTNAT#"2"
	cNat:=SEV->EV_NATUREZ
	
	DbSelectArea("SED")
	DbSetOrder(1)
	if DbSeek(xFilial("SED")+cNat)
		cRet:=SED->ED_CONTA	
	endif                  
	
else
	cRet:=SED->ED_CONTA
endif


return(cRet)