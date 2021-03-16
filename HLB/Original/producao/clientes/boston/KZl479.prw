/*
Funcao      : KZL479
Parametros  : Nenhum
Retorno     : nAgencia
Objetivos   : Cnab Boston - Tratamento para a agencia do fornecedor   
Autor     	: José Ferreira 
Data     	: 25/05/06 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Financeiro.
*/

*-----------------------*
 User Function KZL479()   
*-----------------------* 

	IF SE2->E2_TIPOPAG $"DOC/CC /TED/"
		nAgencia	:=SA2->A2_AGENCIA
	else
		nAgencia := Repl("0",7)
	endif

Return(StrZero(VAL(nAgencia),7))