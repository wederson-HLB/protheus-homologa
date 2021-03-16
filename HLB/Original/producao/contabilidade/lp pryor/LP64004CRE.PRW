#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP64004CRE()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CCREDITO,")


_CCREDITO := " "


IF SM0->M0_CODIGO $"EQ/CD"
   
   If SD1->D1_P_REFAT == '1'//Salton Refaturamento
      _CCREDITO:="311105066"
   Else
      _CCREDITO:= "311105056"
   EndIf                 
   
ELSEIF SM0->M0_CODIGO $"R7"

    _CCREDITO:="311105055"  

ELSE

   _CCREDITO:="311105056"			

ENDIF
	
Return(_CCREDITO)        
