#include "protheus.ch"

/*
Funcao      : MT100TOK
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para validar o preenchimento da chave da nota.
TDN			: Este P.E. � chamado na fun��o A103Tudok(). Pode ser usado para validar a inclusao da NF.
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 09/04/2012    18:25
M�dulo      : Estoque Custos
*/

User function MT100TOK
Local lRet:=.T.

if alltrim(CESPECIE) == "NFE" .OR. alltrim(CESPECIE) == "NF-E" .OR. alltrim(CESPECIE) == "CTE" .OR. alltrim(CESPECIE) == "CT-E"
 
	//SF1->F1_CHVNFE
	if empty(aNFEDanfe[13])
	    Alert("Campo Chave NFE(Aba Informa��es DANFE) n�o preenchido, obrigatoriedade devido ao EFD Contribui��es(PIS/COFINS)"+CRLF+"Em caso de d�vidas verificar com o departamento fiscal.")
		lRet:=.F.		
	endif

endif

Return(lRet)