#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6104val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CTES1")


_vRetorno:=0

_cTes1:=""
_cTes2:=""


_cTes1 :=          "50A/51A/59A/61A/62A/73A/74A/75A/79A/82A/83A/91A/85A/95A/"
_cTes1 := _cTes1 + "83B/"
_cTes1 := _cTes1 + "78C/89C/90C/"
_cTes1 := _cTes1 + "69D/90D/68D/70D/72D/92F/"
_cTes1 := _cTes1 + "92E/88N/"
_cTes1 := _cTes1 + "51F/53F/81F/"
_cTes1 := _cTes1 + "75T/78T/79T/"       // eliminado o TES 76T a pedido da haidee //Eliminado o TES 77T pedido por Haidee Chamado 19245
_cTes1 := _cTes1 + "63V/66V/69V/95B"
_cTes1 := _cTes1 + "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/91F/99F/"  
_cTes1 := _cTes1 + "51B/51C/57A/58A/50G/52L/"
_cTes2 := 		   "61L"
_cTes3 :=          "94T"	   				// FR 14/08/07 - Incluído a pedido de Valdomiro chamado 19092
_CTes4 :=		   "61C"

IF (SD2->D2_TES$(_cTes4)) .AND. SM0->M0_CODIGO='EF'

	_vRetorno:=SD2->D2_VALIPI

ElseIf (SD2->D2_TES$(_cTes2)) .AND. SM0->M0_CODIGO='R7'

	_vRetorno:=SD2->D2_VALIPI
	
ElseIf (SD2->D2_TES$(_cTes3)) .AND. SM0->M0_CODIGO='IZ'

	_vRetorno:=SD2->D2_VALIPI
	
ElseIf (SD2->D2_TES$(_cTes1))		

	_vRetorno:=SD2->D2_VALIPI

ELSE

	_vRetorno:=0
	
ENDIF


RETURN(_vRetorno)


