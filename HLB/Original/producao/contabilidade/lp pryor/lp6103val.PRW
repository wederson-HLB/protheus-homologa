#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6103val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_cTes2")

_vRetorno:=0
                      
_cTes2:="50K/51K/52K/54K/55K/56K/58K/59K/60K/61K/68K/69K/70K/53K/57K/71K/72K/52R/54R/59R/53R/57R/51F/88K/" //tes de devolução 

_cTes3:=   "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/50G/52L/5HT"
   
IF SD2->D2_TES$"56V/52X/53X/91X/" .or. SD2->D2_TES$(_cTes2+_cTes3).or. SD2->D2_CF$("5151/5152/6151/6152/7151/7152")
	_vRetorno:=0
ELSE
	_vRetorno:=SD2->D2_VALICM
ENDIF

RETURN(_vRetorno)

