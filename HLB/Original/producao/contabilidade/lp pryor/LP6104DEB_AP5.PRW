#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function LP6104DEB()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTDEB,_CTES1,_CTES2,_CTES3,_CTES4,_CTES5")
SetPrvt("_CTES6,_CTES7,_CTES8,_CTES9,_CTES10,_CTES11,_CTES12")


_cntDeb:=SPACE(15) 
_cntDeb:="999999999"

_cTes1 :=          "50A/51A/52A/53A/54A/55A/56A/57A/58A/59A/"
_cTes1 := _cTes1 + "60A/61A/63A/64A/65A/74D/66A/67A/68A/69A/"
_cTes1 := _cTes1 + "70A/71A/72A/73A/74A/75A/76A/77A/78A/79A/"
_cTes1 := _cTes1 + "80A/82A/83A/84A/85A/56A/87A/88A/"
_cTes1 := _cTes1 + "90A/91A/92A/93A/94A/96A/97A/"
_cTes1 := _cTes1 + "50B/51B/52B/53B/"
_cTes1 := _cTes1 + "50K/99F/71O/54O/88N/"

_cTes2 :=          "98A/99A/"
_cTes2 := _cTes2 + "54B/55B/57B/58B/59B/60B/61B/62B/63B/64B/65B/66B/67B/68B/69B/70B/"
_cTes2 := _cTes2 + "71B/73B/74B/75B/76B/77B/78B/79B/80B/81B/82B/83B/84B/85B/86B/"
_cTes2 := _cTes2 + "88B/89B/90B/91B/93B/94B/95B/"
_cTes2 := _cTes2 + "50C/51C/52C/53C/54C/55C/56C/57C/57C/58C/59C/50G/"

_cTes3 :=          "96B/97B/98B/99B/99X/"
_cTes3 := _cTes3 + "88C/89C/94C/95C/96C/97C/98C/99C/"
_cTes3 := _cTes3 + "50D/51D/52D/53D/54D/55D/56D/57D/58D/59D/"
_cTes3 := _cTes3 + "60D/61D/62D/63D/64D/65D/67D/68D/69D/"
_cTes3 := _cTes3 + "70D/72D/73D/75D/76D/77D/78D/79D/"
_cTes3 := _cTes3 + "80D/81D/82D/83D/84D/85D/87D/88D/89D/"
_cTes3 := _cTes3 + "91D/92D/"
_cTes3 := _cTes3 + "50E/92F/"

_cTes4 :=          "93D/95D/96D/97D/98D/"
_cTes4 := _cTes4 + "51E/52E/53E/54E/55E/56E/57E/58E/59E/"
_cTes4 := _cTes4 + "60E/61E/62E/63E/64E/65E/66E/67E/68E/69E/"
_cTes4 := _cTes4 + "70E/71E/72E/73E/74E/75E/76E/77E/78E/79E/"
_cTes4 := _cTes4 + "80E/81E/82E/84E/85E/86E/87E/88E/89E/"
_cTes4 := _cTes4 + "90E/91E/92E/93E/94E/95E/96E/97E/"
_cTes4 := _cTes4 + "50F/"
_cTes4 := _cTes4 + "69F/"

_cTes5 :=          "61C/62C/63C/64C/65C/66C/67C/"
_cTes5 := _cTes5 + "98E/99E/91F/"
_cTes5 := _cTes5 + "51F/52F/53F/54F/55F/56F/57F/58F/59F/"
_cTes5 := _cTes5 + "60F/61F/62F/63F/64F/65F/66F/67F/68F/"
_cTes5 := _cTes5 + "70F/71F/72F/73F/74F/75F/76F/77F/78F/79F/"
_cTes5 := _cTes5 + "80F/81F/82F/83F/84F/85F/86F/87F/88F/"

_cTes6 :=          "68C/69C/"
_cTes6 := _cTes6 + "70C/71C/72C/73C/74C/75C/76C/77C/78C/79C/"
_cTes6 := _cTes6 + "80C/81C/82C/83C/84C/85C/86C/87C/"
_cTes6 := _cTes6 + "90C/91C/62C/93C/"
_cTes6 := _cTes6 + "50O/51B/51C/57A/58A/94F/" // 61V solicitação da Haidde 37016 RM

_cTes7 :=          "80T/81T/82T/83T/84T/87T/88T/89T/"
_cTes7 := _cTes7 + "90T/91T/92T/94T/95T/96T/97T/98T/99T/"
_cTes7 := _cTes7 + "50U/51U/52U/53U/54U/56U/57U/58U/59U/"
_cTes7 := _cTes7 + "60U/61U/62U/72X/56X/79V/57Z/"    
_cTes7 := _cTes7 + "53Z/55U/56Z/57Z/58V/59V/63O/63U/64O/65O/65U/66U/66X/67O/67U/68U/"  // solicitação da haidee
_cTes7 := _cTes7 + "69U/69X/70U/70V/72U/73U/74U/75U/76U/77U/78X/84X/88V/90V/90X/91O/91T/95O/95V/99V/"// solicitação da haidee

_cTes8  := 	 "76X/77X/78X"

_cTes9  :=   "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/"

_cTes10 :=   "61L"

_cTes11 := "61L/75T/76T/73V/72V/82V/74V/89V/64X"
	
_cTes12 := "63V/78T" 	// Retirado o TES 77T por solicitação de Haidee - Chamado 19245

If! cEmpAnt $ "EG/JN/"	
	IF SF2->F2_DOC = SD2->D2_DOC
		IF SD2->D2_TES$(_cTes1+_cTes2+_cTes3+_cTes4+_cTes5+_cTes6)      
		
			IF cEmpAnt <>'AJ'
				_cntDeb:="311105052"
			ELSE
				aArea:=getarea()  // salva a area atual
				//aAreaD2:=getarea("SD2")  // salva a area atual
                If SD2->D2_TIPO<>'D'
				   dbselectarea("SA1")
				   DBSETORDER(1)
				   dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			       IF FOUND()
						IF SA1->A1_TIPO="R"
							_cntDeb:="311105057"
						ELSE
							_cntDeb:="311105052"	
					   ENDIF
				   ELSE
				      _cntDeb:="000000000"
				   ENDIF
				   RESTAREA(aArea)  //RESTAURA AREA SD2
			    Else
				      _cntDeb:="111111111"
			    EndIf
			ENDIF
		
		ELSEIF SD2->D2_TES$_cTes7
			_cntDeb:="121110006"
  	
		ELSEIF SD2->D2_TES$_cTes8
			_cntDeb:="411112143"

		ELSEIF SD2->D2_TES$_cTes9
			_cntDeb:="211410001"
			
		ELSEIF SD2->D2_TES$_cTes10 .AND. SM0->M0_CODIGO='R7'
			_cntDeb:="511136367"
      ENDIF

ELSE
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
    _cntDeb := SB1->B1_CONTA
Endif 

ENDIF	
 If cEmpAnt $ "JN"
 	_cntDeb := "311105057"
 EndIf
 
 	If cEmpAnt $ 'R7' 
		IF	SD2->D2_TES $ _cTes11
 			_cntDeb := "511136366"
		ELSEIF SD2->D2_TES $ _cTes12	 		
 			_cntDeb := "511136365"	
		EndIf
	endif		

RETURN(_cntDeb)
