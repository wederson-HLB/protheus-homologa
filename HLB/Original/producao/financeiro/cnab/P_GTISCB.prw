#include "Protheus.ch"      

/*
Funcao      : P_GTISCB
Parametros  : cTipo
Retorno     : cRet
Objetivos   : CNAB - Fonte para tratar o código de barras e retirar as informações necessárias
Autor       : Matheus Massarotto
Data/Hora   : 03/10/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/


/*
	A- DV do código de barras
	B- Fator de vencimento + valor do título
	C- Campo livre
*/

*------------------------------*
 User Function P_GTISCB(cTipo)  
*------------------------------*

Local cRet:=""

//AOA - 24/08/2015 - Ajuste na validação.
if len(Alltrim(SE2->E2_CODBAR))==44
	if cTipo=="A"
		cRet:=SUBSTR(SE2->E2_CODBAR,5,1)
	elseif cTipo=="B"
		cRet:=SUBSTR(SE2->E2_CODBAR,6,4)+SUBSTR(SE2->E2_CODBAR,10,10)	
	elseif cTipo=="C"
		cRet:=SUBSTR(SE2->E2_CODBAR,20,25)	
	endif		
else
	if cTipo=="A"
		cRet:=SUBSTR(SE2->E2_CODBAR,33,1)
	elseif cTipo=="B"
		cRet:=SUBSTR(SE2->E2_CODBAR,34,4)+PADL(Alltrim(SUBSTR(SE2->E2_CODBAR,38,10)),10,"0")
	elseif cTipo=="C"
		cRet:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)
	endif		
endif


Return(cRet)