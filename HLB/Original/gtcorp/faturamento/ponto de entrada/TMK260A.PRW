#Include "Protheus.ch"

/*
Funcao      : TMK260A
Parametros  : 
Retorno     : lRet
Objetivos   : Ponto de entrada na altera��o de prospect, para n�o deixar alterar caso j� tenha virado cliente 
Autor       : Matheus Massarotto
Data/Hora   : 06/07/2012
Modulo		: Faturamento
Revisao     : 
Data/Hora   :
Obs.        : 
Utiliza��o  : GTCORP
*/

User function TMK260A
Local lRet:=.T.

if	alltrim(SUS->US_STATUS)='6' .AND. !empty(SUS->US_CODCLI)
	Alert("N�o � poss�vel alterar o prospect, quando o mesmo j� � cliente!"+CRLF+"Para manuten��o entre na rotina de clientes!")
	lRet:=.F.
endif

Return(lRet)