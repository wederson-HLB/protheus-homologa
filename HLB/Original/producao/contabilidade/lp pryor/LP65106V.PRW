#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65106V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VALRESULT")
     

_valResult:=0
lEasy     := SuperGetMV("MV_EASY") == "S"

//  TES :
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� 12A ->IMPORTACAO PARA COMERCIALIZACAO - COMPLEMENTO                 �
//� 11B ->IMPORTACAO PARA COMERCIALIZACAO                               �
//� 20B ->IMPORTACAO COM REDUCAO DE BASE                                �
//� 21B ->IMPORTACAO COM REDUCAO DE BASE                                �
//� 28B ->IMPORTACAO                                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


_cTes1 :=          "12A/"
_cTes1 := _cTes1 + "11B/"
_cTes1 := _cTes1 + "20B/21B/28B"
              
//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF (SF1->F1_TIPO=="C" .AND. SD1->D1_TES $ (_cTes1))

        _valResult:=(SDE->DE_CUSTO1)
   ELSE
		_valResult:=0

   ENDIF

EndIf

RETURN(_valResult)