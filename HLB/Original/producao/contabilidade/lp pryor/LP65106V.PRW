#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65106V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT")
     

_valResult:=0
lEasy     := SuperGetMV("MV_EASY") == "S"

//  TES :
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 12A ->IMPORTACAO PARA COMERCIALIZACAO - COMPLEMENTO                 ³
//³ 11B ->IMPORTACAO PARA COMERCIALIZACAO                               ³
//³ 20B ->IMPORTACAO COM REDUCAO DE BASE                                ³
//³ 21B ->IMPORTACAO COM REDUCAO DE BASE                                ³
//³ 28B ->IMPORTACAO                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


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