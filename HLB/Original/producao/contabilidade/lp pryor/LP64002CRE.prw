#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP64002CRE()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CCREDITO,")


_CCREDITO := " "


IF SM0->M0_CODIGO $"EQ/CD"
   If SD1->D1_P_REFAT == '1'//Salton Refaturamento
      _CCREDITO:="311105062"
   Else
      _CCREDITO:="311105051"
   EndIf
ELSE
   _CCREDITO:="311105051"			
ENDIF
	
Return(_CCREDITO)        
