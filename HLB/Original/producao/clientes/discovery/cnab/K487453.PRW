/*
Funcao      : K487453
Parametros  : Nenhum
Retorno     : _cData
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
 User Function K487453() 
*-----------------------* 

Local _cData   

_cData :=SubStr(Dtos(SE2->E2_VENCREA),3,2)+SubStr(Dtos(SE2->E2_VENCREA),5,2)+SubStr(Dtos(SE2->E2_VENCREA),7,2)  

Return(_cData)