#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
 
/*
Funcao      : P_Pagval
Parametros  : 
Retorno     : 
Objetivos   : VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19, NO ARQUIVO E DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE BARRA VAI O VALOR DO SE2
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function P_Pagval()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALOR,")

/// VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19, NO ARQUIVO E
/// DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE BARRA VAI O VALOR DO SE2

_VALOR :=Replicate("0",10)

IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "

    _VALOR   :=  STRZERO((SE2->E2_SALDO*100),10,0)

Else
    //tratamento do valor do cod de barras.
/*	if len(alltrim(SE2->E2_CODBAR))==48
	    _VALOR  :=SUBSTR(SE2->E2_CODBAR,38,10)
	else
	    _VALOR  :=SUBSTR(SE2->E2_CODBAR,10,10)
	endif	
*/
	if len(alltrim(SE2->E2_CODBAR))<=44
	    _VALOR  :=SUBSTR(SE2->E2_CODBAR,10,10)
	else
	    _VALOR  :=SUBSTR(SE2->E2_CODBAR,38,10)	   
	endif	
    
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_VALOR)
Return(_VALOR)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
