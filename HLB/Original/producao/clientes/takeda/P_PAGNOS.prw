#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagnos
Parametros  : 
Retorno     : 
Objetivos   : RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E ZEROS QUANDO NAO TEM VALOR POSICAO ( 142 - 150 )
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*------------------------*
User Function P_Pagnos()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*                          

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_RETNOS,")

//// RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E ZEROS QUANDO NAO
//// TEM VALOR POSICAO ( 142 - 150 )

IF SUBS(SE2->E2_CODBAR,01,3) != "237"
    _RETNOS := "000000000"
Else
	if len(alltrim(SE2->E2_CODBAR))<=44
	   _RETNOS := SUBS(SE2->E2_CODBAR,28,9)
	else
	   _RETNOS := SUBS(SE2->E2_CODBAR,14,9)
	endif   
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_RETNOS)
Return(_RETNOS)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
