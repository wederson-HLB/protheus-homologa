#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp61013I()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������   



_itemCre:=SPACE(9)

   IF SM0->M0_CODIGO$'Z4' .AND. SM0->M0_CODFIL$'01' .AND. SD2->D2_SERIE$'ND'
   
   		_itemCre:= SA1_A1_COD
   ENDIF
                

Return(_itemCre)
