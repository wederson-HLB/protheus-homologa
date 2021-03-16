/*
Funcao      : K487452
Parametros  : Nenhum
Retorno     : dData
Objetivos   : Cnab CitiBank   
Autor     	: Wederson L. Santana / José Ferreira
Data     	: 10/03/06
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro.
*/
   
*-----------------------*
 User Function K487452()
*-----------------------*

Local dData   

If SE1->E1_DESCFIN > 0
   dData :=GravaData(SE1->E1_VENCREA-SE1->E1_DIADESC)
Endif

If Empty(dData)
   dData := Replicate("0",6)
Endif    

Return(dData)