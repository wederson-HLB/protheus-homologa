#INCLUDE "Protheus.ch"

/*
Funcao      : GTCORP11
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento do código de barras e linha digitável da AUDITORES banco ITAU.
Autor       : Matheus Massarotto
Data/Hora   : 18/04/2012    14:14
Revisão		: 
Data/Hora   : 
Módulo      : Financeiro
*/

User Function GTCORP11

Local cBar:=""
Local cA:=""
Local cB:=""
Local cC:=""
Local cD:=""
Local cE:=""

cBar:=alltrim(SE2->E2_CODBAR) 

if len(cBar)<=44

cA:=SUBSTR(SE2->E2_CODBAR,1,3)
cB:=SUBSTR(SE2->E2_CODBAR,4,1)
cC:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)
cD:=SUBSTR(SE2->E2_CODBAR,33,1)
cE:=PADL(alltrim(SUBSTR(SE2->E2_CODBAR,34,14)),14,"0")

cBar:=cA+cB+cD+cE+cC

else 

cA:=SUBSTR(SE2->E2_CODBAR,1,3)
cB:=SUBSTR(SE2->E2_CODBAR,4,1)
cC:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)
cD:=SUBSTR(SE2->E2_CODBAR,33,1)
cE:=SUBSTR(SE2->E2_CODBAR,34,14)
//tratamento da ordem
cBar:=cA+cB+cD+cE+cC
//para tratar outros boletos

endif

Return(cBar) 