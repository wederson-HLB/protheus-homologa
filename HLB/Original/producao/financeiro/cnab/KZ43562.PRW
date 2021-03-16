
/*
Funcao      : KZ43562
Parametros  : Nenhum
Retorno     : StrZero(_nValor*100,13)
Objetivos   : Cnab Pryor - Real
Autor       : Wederson L. Santana
Data        : 14/09/05
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 07/05/2013
Módulo      : Financeiro
Cliente     : 
*/

*-----------------------*
User Function KZ43562()    
*-----------------------*

_nValCof:=_nValCsl:=_nValPis:=_nValIr:=0        
_nValor :=(SE1->E1_SALDO - SE1->E1_IRRF - SE1->E1_INSS)+SE1->E1_ACRESC-SE1->E1_DECRESC && alterado por Claudio e Haidee em 18/02/10 para não gerar o valor do INSS no CNAB.//JSS - Add campo SE1->E1_DECRESC chamado 022470

SE1->(DbSetOrder(1))           
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"CF-"))
   _nValCof:=SE1->E1_SALDO
Endif   
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"CS-"))
   _nValCsl:=SE1->E1_SALDO
Endif      
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"PI-"))
   _nValPis:=SE1->E1_SALDO
Endif                                                              

_nValor-=(_nValCof+_nValCsl+_nValPis)


Return(StrZero(_nValor*100,13))