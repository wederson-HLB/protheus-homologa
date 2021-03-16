#INCLUDE "PROTHEUS.CH"
/*
	Matheus - LP Harris, para tratar classe de valor
	22/08/2011
*/
User Function LP610CLVL
Private cCLVL:=''

if !cEmpAnt $ "LP/K2"
	Return(cCLVL)
endif

DbSelectArea("SC5")
DbSetOrder(1)
if DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
	cCLVL:=SC5->C5_P_CLVL
endif

return(cCLVL)