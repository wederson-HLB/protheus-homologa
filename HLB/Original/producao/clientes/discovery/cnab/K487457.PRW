/*
Funcao      : K487457
Parametros  : Nenhum
Retorno     : cReturno
Objetivos   : Cnab CitiBank   
Autor     	: Wederson L. Santana / Jos� Ferreira
Data     	: 10/03/06
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Financeiro.
*/
   
*-----------------------*
 User Function K487457()
*-----------------------* 

Local cReturno

	//cReturno:=If(AllTrim(SE2->E2_TIPOPAG)$ "072",StrZero(Val(AllTrim(SA2->A2_NUMCON)),10),Replicate("0",10)) 
	cReturno := If(SEA->EA_MODELO $ "01",STRZERO(VAL(SA2->A2_NUMCON),10),Replicate("0",10)) //AOA - 02/12/2015 - Altera��o para tratar o modelo do CNAB chamado: 030784

Return(cReturno)