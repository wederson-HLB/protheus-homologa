#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65111V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VALRESULT,_CTES1,_CTES2,_CTES3,")


_valResult:=0

lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1 :=          "01A/02A/03A/04A/05A/06A/07A/08A/08B/09B/"
_cTes1 := _cTes1 + "13A/14A/16A/17A/18A/19A/20A/31A/"
_cTes1 := _cTes1 + "21A/"
_cTes1 := _cTes1 + "01B/02B/03B/04B/05B/06B/07B/"
_cTes1 := _cTes1 + "13B/15B/16B/17B/18B/26B/"
_cTes1 := _cTes1 + "05G/"
_cTes1 := _cTes1 + "02I/05I/"
_cTes1 := _cTes1 + "19M/"
_cTes1 := _cTes1 + "08P/49P/1BG"

_cTes2 :=          "22A/22B/23A/23Q/24A/25A/26A/"
_cTes2 := _cTes2 + "01G/02G/03G/04G/05G/06G/07G/08G/09G/10G/"
_cTes2 := _cTes2 + "11R/12G/13G/14G/15G/16G/"
_cTes2 := _cTes2 + "01H/02H/03H/04H/05H/06H/07H/"
_cTes2 := _cTes2 + "01I/"

_cTes3 :=          "02I/03I/04I/06I/07I/08I/09I/10I/11I/"
_cTes3 := _cTes3 + "01J/02J/03J/04J/05J/06J/11J/"
_cTes3 := _cTes3 + "01M/02M/03M/09M/10M/11M/12M/13M/23Q/"
_cTes3 := _cTes3 + "01O/40O/41O/42O/46O/48O/33B"


//If !lEasy
If EMPTY(SD1->D1_CONHEC)
   IF SD1->D1_TES$(_cTes1+_cTes2+_cTes3)
        _valResult:=(SD1->D1_VALIMP5*(SDE->DE_PERC/100))
   ENDIF
EndIf

RETURN(_valResult)

