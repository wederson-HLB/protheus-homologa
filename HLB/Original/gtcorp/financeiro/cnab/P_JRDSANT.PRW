#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

User Function P_JRDSANT

Local nValor:=0

_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
 //JSS - ALTERADO DE 0,02 PARA 0,05 PARA SOLUCIONAR O CASO 019604
 //AOA - 26/08/2016 - Alterado para 0.01 para sair correto no arquivo CNAB
nValor:=((SE1->E1_SALDO - _nVlrAbat)*0.01)/30

Return(nValor)