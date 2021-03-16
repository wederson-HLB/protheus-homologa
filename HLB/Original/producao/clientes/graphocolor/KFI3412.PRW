
/*
Funcao      : KFI3412
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Covit - Itaú
Autor     	: Wederson L. Santana  
Data     	: 14/09/05 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/

*-----------------------*
 User Function KFI3412()
*-----------------------*
     
_nValCof:=_nValCsl:=_nValPis:=_nValIr:=0        
_nValor :=(SE1->E1_VALOR	- SE1->E1_IRRF)

SE1->(DbSetOrder(1))           
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"CF-"))
   _nValCof:=SE1->E1_VALOR
Endif   
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"CS-"))
   _nValCsl:=SE1->E1_VALOR
Endif      
If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"PI-"))
   _nValPis:=SE1->E1_VALOR
Endif      

_nValor-=(_nValCof+_nValCsl+_nValPis)

Return(StrZero(_nValor*100,13))