#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

User Function P_VALPAD

Local nValor:=0    

If cEmpAnt $ "0F" 

	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	nValor:=(SE1->E1_SALDO - _nVlrAbat)*100
EndIf

Return(nValor)