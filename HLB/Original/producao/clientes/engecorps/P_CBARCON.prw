#INCLUDE "Protheus.ch"
     
/*
Funcao      : P_CBARCON
Parametros  : Nenhum
Retorno     : cBar
Objetivos   : Tratamento para codigo de barras, retirar o Digito Verificador da linha digitavel especifico Santander. Para pagamento de titulos de concecionárias
Autor     	: 
Data     	: 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*--------------------------*
 User Function P_CBARCON()
*--------------------------*

Local cBar:=""
Local cA:=""
Local cB:=""
Local cC:=""
Local cD:=""
Local cE:=""

cBar:=alltrim(SE2->E2_CODBAR)

If len(cBar)==48 

	cA:=SUBSTR(SE2->E2_CODBAR,1,11)
	cB:=SUBSTR(SE2->E2_CODBAR,13,11)
	cC:=SUBSTR(SE2->E2_CODBAR,25,11)
	cD:=SUBSTR(SE2->E2_CODBAR,37,11)
	
	//tratamento da ordem
	cBar:=cA+cB+cC+cD

Elseif len(cBar)<44

	cA:=SUBSTR(SE2->E2_CODBAR,1,3)
	cB:=SUBSTR(SE2->E2_CODBAR,4,1)
	cC:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)
	cD:=SUBSTR(SE2->E2_CODBAR,33,1)
	cE:=PADL(Alltrim(SUBSTR(SE2->E2_CODBAR,34,14)),14,"0")
	//tratamento da ordem
	cBar:=cA+cB+cD+cE+cC
	
Endif

Return cBar 