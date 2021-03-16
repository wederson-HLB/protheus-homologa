/*
Funcao      : KZL479
Parametros  : Nenhum
Retorno     : nConCorr
Objetivos   : Tratamento para a Conta Corrente do fornecedor   
Autor     	: José Ferreira 
Data     	: 25/05/06 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Financeiro.
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