#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function LP6102CRE()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTDEB,_CTES1,_CTES2,_CTES3,_CTES4,_CTES5")
SetPrvt("_CTES6,_CTES7,_CTES8,_CTES9,_CTES9,_CTES10,")
SetPrvt("_CTES11,_CTES12,_CTES13,_CTES14,_CTES15,_CTES16,_CTES17,_CTES18")

_cntDeb:=SPACE(15)
_cntDeb:="999999999"

_cTes1 :=          "50A/51A/52A/53A/54A/55A/56A/57A/58A/59A/"
_cTes1 := _cTes1 + "60A/61A/63A/64A/65A/66A/67A/68A/69A/70A/"
_cTes1 := _cTes1 + "71A/72A/73A/74A/75A/76A/77A/78A/80A/"
_cTes1 := _cTes1 + "81A/82A/83A/84A/85A/86A/87A/88A/90A/"
_cTes1 := _cTes1 + "91A/92A/93A/94A/95A/96A/97A/"
_cTes1 := _cTes1 + "50B/51B/52B/53B/"
_cTes1 := _cTes1 + "74D/99F/99X/"
_cTes1 := _cTes1 + "56M/66M/88N/07D/05D/03D/"

_cTes2 :=          "98A/99A/"
_cTes2 := _cTes2 + "54B/55B/56B/57B/58B/59B/60B/"
_cTes2 := _cTes2 + "61B/62B/63B/64B/65B/66B/67B/68B/69B/70B/"
_cTes2 := _cTes2 + "71B/72B/73B/74B/75B/76B/77B/78B/79B/80B/"
_cTes2 := _cTes2 + "81B/82B/83B/84B/85B/86B/88B/89B/90B/"
_cTes2 := _cTes2 + "91B/92B/93B/94B/95B/"
_cTes2 := _cTes2 + "50C/51C/52C/53C/54C/55C/56C/57C/58C/59C/"

_cTes3 :=          "96B/97B/98B/99B/99X/"
_cTes3 := _cTes3 + "88C/89C/"
_cTes3 := _cTes3 + "94C/95C/96C/97C/98C/99C/"
_cTes3 := _cTes3 + "50D/51D/52D/53D/54D/55D/56D/57D/58D/59D/60D/"
_cTes3 := _cTes3 + "61D/62D/63D/64D/65D/66D/67D/68D/70D/69D/92F/"
_cTes3 := _cTes3 + "71D/72D/73D/75D/76D/77D/78D/79D/80D/"
_cTes3 := _cTes3 + "81D/82D/83D/84D/85D/87D/88D/89D/"
_cTes3 := _cTes3 + "91D/92D/"
_cTes3 := _cTes3 + "50E/"

_cTes4 :=          "93D/95D/96D/97D/98D/"
_cTes4 := _cTes4 + "51E/52E/53E/54E/55E/56E/57E/58E/59E/60E/"
_cTes4 := _cTes4 + "61E/62E/63E/64E/65E/66E/67E/68E/69E/70E/"
_cTes4 := _cTes4 + "71E/72E/73E/74E/75E/76E/77E/78E/79E/80E/"
_cTes4 := _cTes4 + "81E/82E/83E/84E/85E/86E/87E/88E/89E/90E/"
_cTes4 := _cTes4 + "91E/92E/93E/94E/95E/96E/97E/"
_cTes4 := _cTes4 + "50F/57Z/"
_cTes4 := _cTes4 + "69F/"

_cTes5 :=          "61C/62C/63C/64C/65C/66C/67C/68C/69C/70C/"
_cTes5 := _cTes5 + "72C/73C/74C/75C/"
_cTes5 := _cTes5 + "98E/99E/"
_cTes5 := _cTes5 + "51F/52F/53F/54F/55F/56F/57F/58F/59F/60F/"
_cTes5 := _cTes5 + "61F/62F/63F/64F/65F/66F/67F/68F/70F/"
_cTes5 := _cTes5 + "71F/72F/73F/74F/75F/76F/77F/78F/79F/80F/"
_cTes5 := _cTes5 + "81F/82F/83F/84F/85F/86F/87F/88F/93F/50G/"

_cTes6 :=          "59A/61A/62A/79A/82A/91A/"
_cTes6 := _cTes6 + "83B/"
_cTes6 := _cTes6 + "50C/62C/68C/69C/70C/"
_cTes6 := _cTes6 + "71C/72C/73C/74C/75C/76C/77C/78C/79C/80C/"
_cTes6 := _cTes6 + "81C/82C/83C/84C/85C/86C/87C/89C/90C/"
_cTes6 := _cTes6 + "91C/92C/93C/"
_cTes6 := _cTes6 + "69D/90D/"
_cTes6 := _cTes6 + "92E/
_cTes6 := _cTes6 + "81F/"
_cTes6 := _cTes6 + "81K/50O/"
_cTes6 := _cTes6 + "54O/91F/94F/"  // 61V solicitação da Haidde 37016 RM

_cTes7 :=          "75T/69V"
_cTes7 := _cTes7 + "89A/"
_cTes7 := _cTes7 + "89B/"
_cTes7 := _cTes7 + "60C/71C/71V/"
_cTes7 := _cTes7 + "89F/90F/"
_cTes7 := _cTes7 + "53Q/"
_cTes7 := _cTes7 + "99D/"
_cTes7 := _cTes7 + "81K/83K"

_cTes8 :=          "77T/78T/79T/66V/69T/77T"

_cTes9 :=          "80T/81T/82T/83T/84T/87T/88T/89T/90T/"
_cTes9 := _cTes9 + "91T/92T/94T/95T/96T/97T/98T/99T/"
_cTes9 := _cTes9 + "50U/51U/52U/53U/54U/56U/57U/58U/59U/60U/72V/77V/76V/64V/79V/"
_cTes9 := _cTes9 + "61U/62U/78V/72X/56X/58X/74X/81X/82X/56E/60O/78V/80V/"
_cTes9 := _cTes9 + "53Z/55U/56Z/57Z/58V/59V/63O/63U/64O/65O/65U/66U/66X/67O/67U/68U/"  // solicitação da haidee
_cTes9 := _cTes9 + "69U/69X/70U/70V/72U/73U/73Y/74U/75U/76U/77U/78X/84X/88V/90V/90X/91O/91T/" // solicitação da haidee
_cTes9 := _cTes9 + "95O/95V/99V/94V/60Z/68I/97I/"		// solicitação da haidee


_cTes10:=" "

_cTes11:="67V/63V"

_cTes12:="76X/77X/78X/75V/73V/60X/74V/76X/77X/63X/83X/"

_cTes13 := "76T"

_cTes14 := "68T"

_cTes15 := "89X"

_cTes16 := "08D/94D"

_cTes17 := "61L/75T/76T/73V/72V/82V/74V/89V/64X"

_cTes18 := "63V/77T/78T"

_cTes19 := "67I"   								//Incluído por solict. Haidee - chamado 19245

// IIOO
//If! cEmpAnt $ "EG/JN/" (COMENTADO A PEDIDO DA HAIDEE NO CHAMADO 4588)
IF SF2->F2_DOC = SD2->D2_DOC
	IF SD2->D2_TES$(_cTes1+_cTes2+_cTes3+_cTes4+_cTes5+_cTes6)
		//			IF SM0->M0_CODIGO<>'AJ'
		_cntDeb:="311105051"
	ELSE
		aArea:=getarea()  // salva a area atual
		//aAreaD2:=getarea("SD2")  // salva a area atual
		IF SD2->D2_TIPO<>'D'
			dbselectarea("SA1")
			DBSETORDER(1)
			dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			IF FOUND()
				IF SA1->A1_TIPO="R"
					_cntDeb:="311105056"
				ELSE
					_cntDeb:="311105051"
				ENDIF
			ELSE
				_cntDeb:="000000000"
			ENDIF
		Else
			_cntDeb:="111111111"
		EndIf
		RESTAREA(aArea)  //RESTAURA AREA SD2
	ENDIF
ELSEIF SD2->D2_TES$(_cTes7+_cTes13) .AND. SM0->M0_CODIGO<>'EQ'
	IF SM0->M0_CODIGO$'AJ'
		_cntDeb:="411112145"
	ELSE
		_cntDeb:="511136363"
	ENDIF
IF SD2->D2_TES$_cTes8
	_cntDeb:="511136365"
ELSEIF SD2->D2_TES$_cTes9
	_cntDeb:="121110006"
ELSEIF SD2->D2_TES$_cTes11 .AND. SM0->M0_CODIGO='R7'
	_cntDeb:="511136367"
ELSEIF SD2->D2_TES$_cTes11 .AND. SM0->M0_CODIGO<>'EQ'
	_cntDeb:="411112145"
ELSEIF SD2->D2_TES$_cTes11 .AND. SM0->M0_CODIGO='EQ'
	_cntDeb:="511136365"
ELSEIF SD2->D2_TES$_cTes10
	_cntDeb:="411112144"
ELSEIF SD2->D2_TES$_cTes12
	_cntDeb:="411112143"
ELSEIF SD2->D2_TES$_cTes13 .AND. SM0->M0_CODIGO='EQ'
	_cntDeb:="511136366"
ELSEIF SD2->D2_TES$_cTes14
	_cntDeb:="511128306"
ELSEIF SD2->D2_TES$_cTes15 .AND.  SM0->M0_CODIGO='EQ'
	_cntDeb:="511136365"
ELSEIF SD2->D2_TES$_cTes15
	_cntDeb:="511136367"
ELSEIF SD2->D2_TES$_cTes16
	_cntDeb:="311105051"
ELSEIF SD2->D2_TES$_cTes19
	_cntDeb:="211240001"   
ENDIF
ENDIF
If SM0->M0_CODIGO $ "JN"
	_cntDeb := "311105056"
EndIf

If SM0->M0_CODIGO $ 'R7'
	IF	SD2->D2_TES $ _cTes17
		_cntDeb := "511136366"
	ELSEIF SD2->D2_TES $ _cTes18
		_cntDeb := "511136365"
	EndIf
endif

//ELSE
//SB1->(DbSetOrder(1))
//SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
//_cntDeb := SB1->B1_CONTA
//Endif
RETURN(_cntDeb)
