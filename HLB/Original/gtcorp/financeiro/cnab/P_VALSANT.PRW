#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

User Function P_VALSANT

Local nValor:=0
_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)


nValor:=SE1->E1_SALDO - _nVlrAbat

Return(nValor)