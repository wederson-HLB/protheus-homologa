
    /*
Funcao      : KZ4356_J
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Pryor - Real 
Autor     	: Wederson L. Santana 
Data     	: 14/09/05 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 07/02/2012
Módulo      : Financeiro.
*/                           

*-------------------------*
 User Function KZ4356_J()    
*-------------------------*  
  
_nValCof:=_nValCsl:=_nValPis:=_nValIr:=0        
_nValor :=(SE1->E1_VALOR - SE1->E1_IRRF - SE1->E1_INSS)+SE1->E1_ACRESC && alterado por Claudio e Haidee em 18/02/10 para não gerar o valor do INSS no CNAB.

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

//alterado retorno para tratar juros - Matheus 16/08/11       

Return(round((_nValor*0.01)/30,2)*100)