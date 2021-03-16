#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6101cre()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


 SetPrvt("_CNTCRED,_CTES1,_CTES2,_CTES3,_CTES4,_CTES5")
 SetPrvt("_CTES6,_CTES7,_CTES8,_cTes9,_cTes10")
 
 _cntCred:=SPACE(15)
If! cEmpAnt $ "U6/EG/FF/JN/JG/"                                                                            
    _cTes1 :=         "50A/51A/52A/53A/54A/55A/56A/57A/58A/"
    _cTes1 := _cTes1 + "60A/63A/64A/66A/67A/68A/69A/"
    _cTes1 := _cTes1 + "70A/71A/72A/73A/74A/75A/76A/77A/78A/"
    _cTes1 := _cTes1 + "80A/81A/83A/84A/85A/86A/87A/88A/"
    _cTes1 := _cTes1 + "90A/92A/93A/94A/95A/96A/97A/99F/"
    _cTes1 := _cTes1 + "50B/51B/52B/53B/51G/"
    _cTes1 := _cTes1 + "74D/62A/99X/91A/"

    _cTes2 :=          "98A/99A/"
    _cTes2 := _cTes2 + "54B/55B/56B/57B/58B/59B/60B/"
    _cTes2 := _cTes2 + "61B/62B/63B/64B/65B/66B/67B/68B/69B/70B/"
    _cTes2 := _cTes2 + "71B/72B/73B/74B/75B/76B/77B/78B/79B/80B/"
    _cTes2 := _cTes2 + "81B/82B/84B/86B/88B/89B/90B/"
    _cTes2 := _cTes2 + "91B/92B/93B/94B/95B/"
    _cTes2 := _cTes2 + "50C/51C/52C/53C/54C/55C/56C/57C/58C/59C/"  

    _cTes3 :=         "96B/97B/98B/99B/99X/"
    _cTes3 := _cTes3 + "88C/"
    _cTes3 := _cTes3 + "94C/95C/96C/97C/98C/99C/"
    _cTes3 := _cTes3 + "50D/51D/52D/53D/54D/55D/56D/57D/58D/59D/60D/"
    _cTes3 := _cTes3 + "61D/62D/63D/64D/65D/66D/67D/68D/70D/69D/"
    _cTes3 := _cTes3 + "71D/72D/73D/75D/76D/77D/78D/79D/80D/"
    _cTes3 := _cTes3 + "81D/82D/83D/84D/85D/87D/88D/89D/"
    _cTes3 := _cTes3 + "91D/92D/92F/"
    _cTes3 := _cTes3 + "50E/"

    _cTes4 :=         "93D/95D/96D/97D/98D/"
    _cTes4 := _cTes4 + "51E/52E/53E/54E/55E/56E/57E/58E/59E/60E/"
    _cTes4 := _cTes4 + "61E/62E/63E/64E/65E/66E/67E/68E/69E/70E/"
    _cTes4 := _cTes4 + "71E/72E/73E/73E/74E/75E/76E/77E/78E/79E/80E/"
    _cTes4 := _cTes4 + "81E/82E/83E/84E/85E/86E/87E/88E/89E/90E/"
    _cTes4 := _cTes4 + "91E/93E/94E/95E/96E/97E/"
    _cTes4 := _cTes4 + "50F/"
    _cTes4 := _cTes4 + "69F/"

    _cTes5 :=          "61C/62C/63C/64C/65C/66C/67C/68C/69C/70C/"
    _cTes5 := _cTes5 + "72C/73C/74C/75C/"
    _cTes5 := _cTes5 + "98E/99E/"
    _cTes5 := _cTes5 + "51F/52F/53F/54F/55F/56F/57F/58F/59F/60F/"
    _cTes5 := _cTes5 + "61F/62F/63F/64F/65F/66F/67F/68F/70F/"
    _cTes5 := _cTes5 + "71F/72F/73F/74F/75F/76F/77F/78F/79F/80F/"
    _cTes5 := _cTes5 + "82F/83F/84F/85F/86F/87F/88F/93F/"

    _cTes6 :=          "50C/88N/"
    _cTes6 := _cTes6 + "71C/76C/77C/78C/79C/80C/"
    _cTes6 := _cTes6 + "81C/82C/83C/84C/85C/86C/87C/90C/"
    _cTes6 := _cTes6 + "91C/92C/"
    _cTes6 := _cTes6 + "81K/89K"
    _cTes6 := _cTes6 + "54O/91F/50G/52G/94F/"  // 61V solicitação da Haidde 37016 RM
 
    _cTes7 :=          "89A/"
    _cTes7 := _cTes7 + "89B/"
    _cTes7 := _cTes7 + "60C/"
    _cTes7 := _cTes7 + "89F/"
    _cTes7 := _cTes7 + "53Q/50Q/"    
    _cTes7 := _cTes7 + "99D/"   
 
    _cTes8 :=          "50R"
    
    _cTes9 :=          "85V/94V/"   // venda de sucata     
 
    _cTes10:=   "94U/73X/93U/92U/79U/80U/81U/82U/83U/84U/85U/86U/87U/88U/89U/90U/91U/"

    IF SM0->M0_CODIGO = 'MV'
  	  	 _cntCred:= SB1->B1_CONTA
    ELSEIF SM0->M0_CODIGO = '68' .and. alltrim(SD2->D2_CLIENTE) = '20570'
  	  	 _cntCred:= "311101002" 
    ELSEIF SD2->D2_TES$(_cTes1+_cTes2+_cTes3+_cTes4+_cTes5+_cTes6)
       _cntCred:="311101001"
    ELSEIF SD2->D2_TES$_cTes7
       _cntCred:="311102021"
    ELSEIF SD2->D2_TES$_cTes8
       _cntCred:="611150503"
    ELSEIF SD2->D2_TES$_cTes9
       _cntCred:="411112145" 
    ELSEIF SD2->D2_TES$_cTes10
       _cntCred:="211410001"  
    ENDIF
Else 
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
    _cntCred := SB1->B1_CONTA
Endif 
 
RETURN(_cntCred)

