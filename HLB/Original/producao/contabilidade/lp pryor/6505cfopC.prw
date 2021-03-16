#include "rwmake.ch"

User Function 6505cfopC()        // Alteração do LP 650 05 (CONTA CONTABIL)17/07/08

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_cntCRED,")

_cntCred:=0      //space(9)

_cCFOP1 :=  "1151/1152/1912/1913"

_cCFOP2 :=  "3101/3102"

_cCFOP3 :=  "1911/1949/2949"

_cCFOP4 :=  "1351/1352/1353/2351/2352/2353/1253/1556/1303/1407"



IF SD1->D1_CF $ (_cCFOP1)
	_cntCred:="121110006"
	
ELSEIF SD1->D1_CF $ (_cCFOP2)
	_cntCred:="112224001"
	
ELSEIF SD1->D1_CF $ (_cCFOP3)
	_cntCred:="511136365"
	
ELSEIF SD1->D1_CF $ (_cCFOP4)
	_cntCred:="211240002"
	
	
ENDIF


RETURN(_cntCred)
