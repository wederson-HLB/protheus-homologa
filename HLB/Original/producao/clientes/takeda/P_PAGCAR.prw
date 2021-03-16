#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagcar
Parametros  : 
Retorno     : 
Objetivos   : PROGRAMA PARA SELECIONAR A CARTEIRA NO CODIGO DE BARRAS QUANDO  NAO TIVER TEM QUE SER COLOCADO "00"
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function P_Pagcar()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
*------------------------*                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_RETCAR,")

////  PROGRAMA PARA SELECIONAR A CARTEIRA NO CODIGO DE BARRAS QUANDO  
////  NAO TIVER TEM QUE SER COLOCADO "00"

IF SUBS(SE2->E2_CODBAR,01,3) != "237"
   _Retcar := "000"
Else
   if len(alltrim(SE2->E2_CODBAR))<=44
		_Retcar := "0" + SUBS(SE2->E2_CODBAR,24,2)
   else
   		_Retcar := "0" + SUBS(SE2->E2_CODBAR,9,1)+SUBS(SE2->E2_CODBAR,11,1)
   endif
   
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_Retcar)
Return(_Retcar)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
