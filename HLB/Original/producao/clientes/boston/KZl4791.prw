/*
Funcao      : KZL479
Parametros  : Nenhum
Retorno     : nConCorr
Objetivos   : Tratamento para a Conta Corrente do fornecedor   
Autor     	: Jos� Ferreira 
Data     	: 25/05/06 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 13/03/2012
M�dulo      : Financeiro.
*/

*-----------------------*
 User Function KZL4791()    
*-----------------------*

	IF SE2->E2_TIPOPAG $"DOC/CC /TED/"
		nConCorr	:=SA2->A2_NUMCON
	else
		nConCorr := ""
	endif

Return(StrZero(VAL(nConCorr),10))