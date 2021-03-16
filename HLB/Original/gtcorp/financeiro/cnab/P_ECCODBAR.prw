#INCLUDE "Protheus.ch"

/*
Funcao      : P_ECCODBAR
Parametros  : Nenhum
Retorno     : cBar
Objetivos   : Tratamento para codigo de barras, retirar o Digito Verificador da linha digitavel - Especifico Santander;
Autor     	: 
Data     	: 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*--------------------------*
 User Function P_ECCODBAR()
*--------------------------*

Local cBar:=""
Local cA:=""
Local cB:=""
Local cC:=""
Local cD:=""
Local cE:=""

cBar:=alltrim(SE2->E2_CODBAR) 

If len(cBar)<=44

	cA:=SUBSTR(SE2->E2_CODBAR,1,3)
	cB:=SUBSTR(SE2->E2_CODBAR,4,1)
	cC:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)
	cD:=SUBSTR(SE2->E2_CODBAR,33,1)
	cE:=PADL(alltrim(SUBSTR(SE2->E2_CODBAR,34,14)),14,"0")
	//tratamento da ordem
	cBar:=cA+cB+cD+cE+cC

Else 

	cA:=SUBSTR(SE2->E2_CODBAR,1,3)
	cB:=SUBSTR(SE2->E2_CODBAR,4,1)
	cC:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)	
	cD:=SUBSTR(SE2->E2_CODBAR,33,1)
	cE:=SUBSTR(SE2->E2_CODBAR,34,14)
	//tratamento da ordem
	cBar:=cA+cB+cD+cE+cC
	//para tratar outros boletos

EndIf

Return cBar 


          