#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function lp64001deb()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CNTDEB,")


_cntDeb:=space(9)


IF SM0->M0_CODIGO $ "EQ/CD"
   If SD1->D1_P_REFAT == '1'//Salton Refaturamento
      _cntDeb:="311101002"
   Else 
      _cntDeb:= "311104041"
   EndIf
   
ELSE
	_cntDeb:= "311104041"

ENDIF


RETURN(_cntDeb)
