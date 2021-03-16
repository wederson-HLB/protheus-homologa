#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65103V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT")       
lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1 :=         "01E/02E/03E/04E/05E/06E/07E/08E/09E/10E/11E/12E/13E/08D/"
_cTes1 := _cTes1 + "07M/08M/08D/01D/04D/05J/08D/"
_cTes1 := _cTes1 + "11J/20M/21M/07A/11M/15M/12M/13M/24M/25M/26M/"   


_cTes2 := "12M/01M/"		// tes com diferencial de alíquota. Deve contabilizar o icms complementar

_cTes3 := "02I/07I/"   

_valResult:=0

///////////  cfop ////////

/// 1352 -> COMPRA DE SERVICOS DE TRANSPORTE
/// 1556 -> COMPRA DE MATERIAL DE CONSUMO
/// 2556 -> COMPRA DE MATERIAL DE CONSUMO                                                                   
/// 3556 -> COMPRA DE MATERIAL DE CONSUMO                                                                     

//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF(Alltrim(SD1->D1_CF)$("1556/2556/3556/1151/1152/2551/2552/3551/3552/").OR.(SD1->D1_TES$_cTes1)) .AND. !(SD1->D1_TES$(_cTes2+_cTes3)) 
		_valResult:=0
   ELSEIF (SD1->D1_TES$(_cTes2))
		_valResult:= (SD1->D1_ICMSCOM*(SDE->DE_PERC/100))
   ELSE                
    
    //_valResult:=SD1->D1_VALICM        
      If Empty(SD1->D1_CONHEC) 	// TLM - Importação ICMS de Entrada Lanc 950.  
	    _valResult:=(SD1->D1_VALICM*(SDE->DE_PERC/100))
	  EndIf	   
	           
  ENDIF

EndIf
                                        
RETURN(_valResult)
