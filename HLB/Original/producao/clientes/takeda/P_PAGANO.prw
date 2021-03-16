#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
 
/*
Funcao      : P_Pagano
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO TIVER TEM QUE SER COLOCADO "00"
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function P_Pagano()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_RETANO,")

////  PROGRAMA PARA SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB QUANDO NAO 
////  NAO TIVER TEM QUE SER COLOCADO "00"


IF SUBS(SE2->E2_CODBAR,01,3) != "237"
   _RETANO := "000"
Else
	if len(alltrim(SE2->E2_CODBAR))<=44
   		_RETANO := "0" + SUBS(SE2->E2_CODBAR,26,2)
    else 
    	_RETANO := "0" + SUBS(SE2->E2_CODBAR,12,2)
    endif
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_RETANO)
Return(_RETANO)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
