#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagban
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA SEPARAR O BANCO DO CODIGO DE BARRAS CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (96-98)
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*-------------------------* 
 User Function P_Pagban()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*-------------------------*

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_BANCO,")

//  PROGRAMA PARA SEPARAR O BANCO DO CODIGO DE BARRAS 
//  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (96-98)

IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "
   _BANCO := SUBSTR(SA2->A2_BANCO,1,3)
ELSE
   _BANCO := SUBSTR(SE2->E2_CODBAR,1,3)
ENDIF

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_BANCO)

Return(_BANCO)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
