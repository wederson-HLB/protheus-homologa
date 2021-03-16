
/*
Funcao      : MTA130C8 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. compras
Autor       : Wederson L. Santana
Data/Hora   : 11/05/05      
Obs         : 
TDN         : P.E. Executado apos gravacao de cada item no SC8. A Tabela se encontra posicionada.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Compras.
Cliente     : Tellabs
*/

*-------------------------*
 User Function MTA130C8()
*-------------------------*

If cEmpAnt $ "D1"
   Reclock("SC8",.F.)
   Replace SC8->C8_P_COD With SC1->C1_P_COD
   Replace SC8->C8_P_PRJ With SC1->C1_P_PRJ
   MsUnlock()
Endif 
  
Return