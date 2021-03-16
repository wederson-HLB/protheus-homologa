/*
Funcao      : K487457
Parametros  : Nenhum
Retorno     : cReturno
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
 User Function K487457()
*-----------------------* 

Local cReturno

	//cReturno:=If(AllTrim(SE2->E2_TIPOPAG)$ "072",StrZero(Val(AllTrim(SA2->A2_NUMCON)),10),Replicate("0",10)) 
	cReturno := If(SEA->EA_MODELO $ "01",STRZERO(VAL(SA2->A2_NUMCON),10),Replicate("0",10)) //AOA - 02/12/2015 - Alteração para tratar o modelo do CNAB chamado: 030784

Return(cReturno)