#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6109val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VRETORNO,_CTES1")


_vRetorno:=0

_cTes1 :=          "50K/51K/52K/53K/55K/56K/57K/58K/59K/88K/"    //tes de devolu豫o
_cTes1 := _cTes1 + "60K/61K/68K/69K/"
_cTes1 := _cTes1 + "70K/71K/72K/80K/"
_cTes1 := _cTes1 + "52R/53R/54R/59R/"

	IF SD2->D2_TES$(_cTes1)
		
			_vRetorno:=(SD2->D2_VALIPI)
	
	ELSE
	    	_vRetorno:=0
	
	ENDIF



RETURN(_vRetorno)


