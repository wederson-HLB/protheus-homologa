#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6107val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CTES1")


_vRetorno:=0

_cTes1 :=          "51K/52K/53K/55K/56K/57K/58K/59K/"    //tes de devolução S/IPI NA BASE
_cTes1 := _cTes1 + "60K/61K/68K/69K/"
_cTes1 := _cTes1 + "70K/71K/72K/80K/90K/"
_cTes1 := _cTes1 + "52R/53R/54R/59R/"


_cTes3 := "57R/"             // devolucao de material de consumo        

_cTes4 := "50K/88K/"

_cTes5 := "54K"              // DEVOLUÇÃO COMERCIALIZAÇÃO             

	IF SD2->D2_TES$(_cTes1)
		
			_vRetorno:=(SD2->D2_CUSTO1 - SD2->D2_VALIPI)
	

	ELSEIF SD2->D2_TES$(_cTes3)
	
			_vRetorno:=(SD2->D2_TOTAL)   
			
	ELSEIF SD2->D2_TES$(_cTes4)

			_vRetorno := (SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP5 - SD2->D2_VALIMP6) 
		

	ELSEIF SD2->D2_TES$(_cTes5)

			_vRetorno := (SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP5 - SD2->D2_VALIMP6 + SD2->D2_VALIPI) 

		
	ELSE	
	    	_vRetorno:=0
	
	ENDIF



RETURN(_vRetorno)


