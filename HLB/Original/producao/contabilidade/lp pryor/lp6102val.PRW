#include "rwmake.ch"             // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6102val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CTES1,_CTES2,_CTES3")


_vRetorno:=0

_cTes1 :=          "78V/"
_cTes1 := _cTes1 + "75T/76T/77T/78T/79T/"
_cTes1 := _cTes1 + "66V/69V/63V/58X/72X/74X/81X/82X/56Z/60O/80V/75V/73V/60X/74V/76X/77X/"
_cTes1 := _cTes1 + "59A/61A/62A/79A/82A/91A/63X/83V/72V/77V/76V/64V/79V/"
_cTes1 := _cTes1 + "83B/89C/90C/69D/90D/92E/81F/51F/69T/63V/68T/77T/89X/57Z/"
_cTes1 := _cTes1 + "53Z/55U/56Z/57Z/58V/59V/63O/63U/64O/65O/65U/66U/66X/67O/67U/68U/69U/69X/70U/70V/72U/73U/"
_cTes1 := _cTes1 + "74U/75U/76U/77U/78X/84X/88V/90V/90X/91O/91T/95O/95V/99V/50G/52L/88N/"


_cTes2 :=          "50K/51K/52K/54K/55K/56K/58K/59K/60K/61K/68K/69K/70K/53K/57K/71K/72K/57R/88K/" //tes de devolução
_cTes2 := _cTes2 + "52R/54R/59R/53R/" //tes de devolução
_cTes2 := _cTes2 + "51I/67I/56O/"   // tes de transferencia

_cTes3:=   "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/"


IF SD2->D2_TES$"56V/91X/52X/53X/" .or. SD2->D2_TES$(_cTes2+_cTes3) .or. SD2->D2_CF$("5151/5152/6151/6152/7151/7152")
	
	_vRetorno:=0
	
ELSEIF (SD2->D2_TES$(_cTes1))
	
	_vRetorno:=SD2->D2_VALICM+SD2->D2_VALIPI
	
ELSE
	_vRetorno:=SD2->D2_VALICM
	
ENDIF


RETURN(_vRetorno)


