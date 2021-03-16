#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6402val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CTES1")
             
lEasy     := SuperGetMV("MV_EASY") == "S"

_vRetorno:=0

_cTes1 := "01E/02E/03E/04E/05E/06E/07E/08E/09E/"
_cTes1 := _cTes1 + "10E/11E/12E/13E/"
_cTes1 := _cTes1 + "24E/25E/26E/27E/28E/29E/"
_cTes1 := _cTes1 + "30E/"
_cTes1 := _cTes1 + "07M/08M/"
_cTes1 := _cTes1 + "07J/08J/08L"


//If !lEasy
If EMPTY(SD1->D1_CONHEC)

	IF SD1->D1_TES$(_cTes1)
		
			_vRetorno:=(SD1->D1_VALICM)
	
	ELSE
	    	_vRetorno:=0
	
	ENDIF

Endif

RETURN(_vRetorno)


