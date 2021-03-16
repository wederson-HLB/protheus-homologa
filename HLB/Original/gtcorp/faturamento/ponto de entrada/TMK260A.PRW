#Include "Protheus.ch"

/*
Funcao      : TMK260A
Parametros  : 
Retorno     : lRet
Objetivos   : Ponto de entrada na alteração de prospect, para não deixar alterar caso já tenha virado cliente 
Autor       : Matheus Massarotto
Data/Hora   : 06/07/2012
Modulo		: Faturamento
Revisao     : 
Data/Hora   :
Obs.        : 
Utilização  : GTCORP
*/

User function TMK260A
Local lRet:=.T.

if	alltrim(SUS->US_STATUS)='6' .AND. !empty(SUS->US_CODCLI)
	Alert("Não é possível alterar o prospect, quando o mesmo já é cliente!"+CRLF+"Para manutenção entre na rotina de clientes!")
	lRet:=.F.
endif

Return(lRet)