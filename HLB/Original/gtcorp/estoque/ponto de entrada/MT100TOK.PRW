#include "protheus.ch"

/*
Funcao      : MT100TOK
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para validar o preenchimento da chave da nota.
TDN			: Este P.E. é chamado na função A103Tudok(). Pode ser usado para validar a inclusao da NF.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 09/04/2012    18:25
Módulo      : Estoque Custos
*/

User function MT100TOK
Local lRet:=.T.

if alltrim(CESPECIE) == "NFE" .OR. alltrim(CESPECIE) == "NF-E" .OR. alltrim(CESPECIE) == "CTE" .OR. alltrim(CESPECIE) == "CT-E"
 
	//SF1->F1_CHVNFE
	if empty(aNFEDanfe[13])
	    Alert("Campo Chave NFE(Aba Informações DANFE) não preenchido, obrigatoriedade devido ao EFD Contribuições(PIS/COFINS)"+CRLF+"Em caso de dúvidas verificar com o departamento fiscal.")
		lRet:=.F.		
	endif

endif

Return(lRet)