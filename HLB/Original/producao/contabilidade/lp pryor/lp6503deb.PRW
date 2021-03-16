#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function lp6503deb()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTDEB,")

//IIF(SD1->D1_TES$"01M/02M/03M/04M/05M/18M",131130001,211240001) 

_cntDeb:=space(9)
_cntDeb:="999999999"

_cTes1 :=          "01M/02M/03M/04M/05M/"
_cTes1 := _cTes1 + "18M/"

	IF (SD1->D1_TES $ "13I" .AND. SM0->M0_CODIGO$"FF")
	
			_cntDeb:="211240001"

	ELSEIF SD1->D1_TES $ (_cTes1)
	        _cntDeb:="131130001"
	        
	ELSE 
    	    _cntDeb:="211240001" 
    	    

ENDIF

RETURN(_cntDeb)
                                                                                                                                                                                                                   