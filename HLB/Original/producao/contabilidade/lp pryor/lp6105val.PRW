#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6105val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_cTes1")

_cTes1 :=          "50K/51K/52K/53K/54K/55K/56K/57K/58K/59K/88K/"    //tes de devolução
_cTes1 := _cTes1 + "60K/61K/68K/69K/"
_cTes1 := _cTes1 + "70K/71K/72K/"
_cTes1 := _cTes1 + "52R/53R/54R/59R/50G/52L/"

_cTes2:=   "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/"

_vRetorno:=0

IF SD2->D2_TES$"56V" .or. SD2->D2_TES$(_cTes1)

	_vRetorno:=0

ELSE

	_vRetorno:=SD2->D2_VALIPI

ENDIF

RETURN(_vRetorno)

