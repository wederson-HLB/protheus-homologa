/*
Funcao      : K487454
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
 User Function K487454() 
*-----------------------* 

Local cReturno

	//cReturno:=If(AllTrim(SE2->E2_TIPOPAG)$ "071/083",StrZero(Val(SubStr(SA2->A2_AGENCIA,1,4)),4),"0000")
	cReturno := If(SEA->EA_MODELO $ "03/41",STRZERO(VAL(SUBSTR(SA2->A2_AGENCIA,1,4)),4),"0000") //AOA - 02/12/2015 - Alteração para tratar o modelo do CNAB chamado: 030784

Return(cReturno)