#Include "rwmake.ch"   

/*
Funcao      : GTFIN017
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento código de barras de boleto de cartão de credito para completar data e valor de pagamento.
Autor     	: Anderson Arrais
Data     	: 04/05/2016
Módulo      : Financeiro
Cliente     : 
*/

*---------------------------*
 User Function GTFIN017(nOpc) 
*---------------------------* 

Local cRet		:=""
Local cA		:=""
Local cB		:=""
Local cC		:=""
Local cD		:=""
Local cFator	:=""
Local cValFinal	:="" 
Local cCodBar	:=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento Itau      		    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If nOpc == 1
	If LEN(ALLTRIM(SE2->E2_CODBAR)) < 40 .OR. VAL(SUBSTR(SE2->E2_CODBAR,38,10)) < 1
		cA			:= SUBSTR(SE2->E2_CODBAR,1,4) //Banco + Moeda
		cB			:= SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10) //Campo livre
		
		If VAL(SUBSTR(SE2->E2_CODBAR,34,4)) < 1
			cFator	:= SUBSTR(Strzero(SE2->E2_VENCREA - ctod("07/10/97"),4),1,4) //Converte data - Bacen
		Else
			cFator	:= SUBSTR(SE2->E2_CODBAR,34,4) 
		EndIf
		
		cValFinal	:= SUBSTR(strzero((SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100),10),1,10) //AOA - 10/11/2016 - Ajustado para considerar acrescimo e decrescimo
		cD			:= cFator+cValFinal //Fator de vencimento + valor
		cCodBar		:= cA+cD+cB
		cC			:= cValToChar(Modulo11(cCodBar)) //Calculo DV geral
		cRet		:= cA+cC+cD+cB //Código de barras final	
	Else 
		cRet		:= U_GTFIN007()
	EndIf
EndIf

//AOA - 29/09/2017 - Pega data de vencimento do código de barras
If nOpc == 2
	cRet	:= GravaData(ctod("07/10/97")+val(subStr(U_GTFIN017(1),6,4)),.F.,5)     
EndIf  

Return(cRet)

/*
Funcao      : Modulo11
Parametros  : cData
Retorno     : D
Objetivos   : Calculo modulo 11.
Autor     	: Anderson Arrais
Data     	: 04/05/2016
Módulo      : Financeiro
*/
      
*------------------------------*
STATIC FUNCTION Modulo11(cData) 
*------------------------------*

LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 1
ELSE
	D := 11 - (mod(D,11))	
ENDIF 

RETURN(D)