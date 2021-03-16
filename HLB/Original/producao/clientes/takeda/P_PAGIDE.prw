#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

/*
Funcao      : P_Pagide
Parametros  : 
Retorno     : _cCgc
Objetivos   : Programa que retorna o CGC
Autor       : Matheus Massarotto 
Data        : 26/09/00 ( adaptado )
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function P_Pagide()  
*------------------------*

_cCgc := "0"+PADL(Left(SA2->A2_CGC,8)+Substr(SA2->A2_CGC,9,4)+Right(SA2->A2_CGC,2),14,"0")

If SA2->A2_TIPO <> "J" 
   _cCgc := Left(SA2->A2_CGC,9)+"0000"+Substr(SA2->A2_CGC,10,2)
Endif

Return(_cCgc)

