#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function 65011VCFO()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VALRESULT")       
                       
_valResult:=0

If EMPTY(SD1->D1_CONHEC)
   _valResult:= SD1->D1_VALIMP5
EndIf

RETURN(_valResult)
