#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6101val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VRETORNO,_CTES1,_CTES2,_CTES3,_CTES4,_CTES5")
SetPrvt("_CTES6,_CTES7,_CTES8,_CTES9,_CTES10")


	_vRetorno:=0

	_cTes1 :=          "50A/51A/52A/53A/54A/55A/56A/57A/58A/"
	_cTes1 := _cTes1 + "56M/66M/88N/"
	_cTes1 := _cTes1 + "60A/63A/64A/66A/67A/68A/69A/70A/"
	_cTes1 := _cTes1 + "71A/72A/73A/74A/75A/76A/77A/78A/80A/"
	_cTes1 := _cTes1 + "81A/83A/84A/85A/86A/87A/88A/90A/"
	_cTes1 := _cTes1 + "92A/93A/94A/95A/96A/97A/99F/"
	_cTes1 := _cTes1 + "50B/51B/52B/52L/53B/51G/"
	_cTes1 := _cTes1 + "74D/91D/99X/"
	                      
   _cTes2 :=          "98A/99A/"
   _cTes2 := _cTes2 + "54B/55B/56B/57B/58B/59B/60B/"
   _cTes2 := _cTes2 + "61B/62B/63B/64B/65B/66B/67B/68B/69B/70B/"
   _cTes2 := _cTes2 + "71B/72B/73B/74B/75B/76B/77B/78B/79B/80B/"
   _cTes2 := _cTes2 + "81B/82B/84B/86B/88B/89B/90B/"
   _cTes2 := _cTes2 + "91B/92B/93B/94B/95B/"
   _cTes2 := _cTes2 + "50C/51C/52C/53C/54C/55C/56C/57C/58C/59C/"  

   _cTes3 :=          "96B/97B/98B/99B/99X/"
   _cTes3 := _cTes3 + "88C/"
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
   _cTes4 := _cTes4 + "91E/93E/94E/95E/96E/97E/"
   _cTes4 := _cTes4 + "50F/50G/"
   _cTes4 := _cTes4 + "69F/"

   _cTes5 :=          "61C/62C/63C/64C/65C/66C/67C/68C/69C/70C/"
   _cTes5 := _cTes5 + "72C/73C/74C/75C/"
   _cTes5 := _cTes5 + "98E/99E/"
   _cTes5 := _cTes5 + "51F/52F/53F/54F/55F/56F/57F/58F/59F/60F/"
   _cTes5 := _cTes5 + "61F/62F/63F/64F/65F/66F/67F/68F/70F/"
   _cTes5 := _cTes5 + "71F/72F/73F/74F/75F/76F/77F/78F/79F/80F/"
   _cTes5 := _cTes5 + "82F/83F/84F/85F/86F/87F/88F/93F/"

   _cTes6 :=          "59A/61A/62A/79A/82A/91A/"
   _cTes6 := _cTes6 + "83B/"
   _cTes6 := _cTes6 + "50C/"
   _cTes6 := _cTes6 + "71C/76C/77C/78C/79C/80C/"
   _cTes6 := _cTes6 + "81C/82C/83C/84C/85C/86C/87C/89C/90C/"
   _cTes6 := _cTes6 + "91C/92C/"
   _cTes6 := _cTes6 + "69D/90D/"
   _cTes6 := _cTes6 + "92E/
   _cTes6 := _cTes6 + "81F/"         
   _cTes6 := _cTes6 + "81K/89K"
   _cTes6 := _cTes6 + "54O/91F/94F/61V"
	
	_cTes7 :=          "89A/"
	_cTes7 := _cTes7 + "89B/"
	_cTes7 := _cTes7 + "60C/71C/"
	_cTes7 := _cTes7 + "89F/90F/"
	_cTes7 := _cTes7 + "53Q/50Q/"		  
	_cTes7 := _cTes7 + "99D/"			
	_cTes7 := _cTes7 + "81K/83K"
	
	_cTes8 :=          "50R/51H/53H"
    
	_cTes9 :=          "85V/94V/"   // venda de sucata

    _cTes10:=          "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/"


IF SF2->F2_DOC = SD2->D2_DOC
	
	IF (SD2->D2_TES$(_cTes1+_cTes2+_cTes3+_cTes4+_cTes5+_cTes6+_cTes7+_cTes8+_cTes10).AND.(SD2->D2_TIPO$"N/C/P/D/B"))
		
	           
        _vRetorno:=SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_VALFRE+SD2->D2_DESPESA  
    	    
	       
	ENDIF
ENDIF


RETURN(_vRetorno)


