#Include "Protheus.ch"

/*
Funcao      : GTFIN021()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acrescimo e decrescimo no contas a pagar
Autor       : Matheus
Cliente		: Vogel
Data/Hora   : 13/10/2016
*/

*----------------------------*
 User Function GTFIN021(nTipo)
*----------------------------*
Local nRet:=0

Default nTipo := 0

if nTipo==1
	nRet:=(ABS(SE1->E1_ACRESC-SE1->E1_DECRESC))*100
elseif nTipo==2

	if (VAL(SUBSTR(U_GTFIN017(1),10,10))/100)<SE2->E2_VALOR
		nRet:=(ABS(SE2->E2_ACRESC))*100
	elseif (VAL(SUBSTR(U_GTFIN017(1),10,10))/100)>SE2->E2_VALOR
		nRet:=(ABS(SE2->E2_DECRESC))*100	
	endif
	
endif

Return(nRet)