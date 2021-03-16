#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6106val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_cTes1")


_vRetorno:=0 

_cTes1 :=          "50K/51K/52K/53K/54K/55K/56K/57K/58K/59K/88K/"    //tes de devolução S/IPI NA BASE
_cTes1 := _cTes1 + "60K/61K/68K/69K/90K"
_cTes1 := _cTes1 + "70K/71K/72K/"
_cTes1 := _cTes1 + "52R/53R/54R/59R/57R/"




IF SD2->D2_TES$(_cTes1)

	_vRetorno:=SD2->D2_TOTAL + SD2->D2_VALIPI
	

ELSE
	_vRetorno:=0
	
ENDIF

RETURN(_vRetorno)

