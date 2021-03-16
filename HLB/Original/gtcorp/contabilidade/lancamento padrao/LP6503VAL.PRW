#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
#include "topconn.ch"

User Function LP6503VAL()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT")       
lEasy     := SuperGetMV("MV_EASY") == "S"
cQry:=""

_cTes1 :=         "01E/02E/03E/04E/05E/06E/07E/08E/09E/10E/11E/12E/13E/08D/1O7/1O8/"//JSS em 09/10/2012 - Adicionado TES 1O7 para atender o caso 0 //JSS em 28/02/2013 - Adicionado TES 1O7 para atender o caso010041
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
		_valResult:= SD1->D1_ICMSCOM
   ELSE                
    
    //_valResult:=SD1->D1_VALICM        
      If Empty(SD1->D1_CONHEC) 	// TLM - Importação ICMS de Entrada Lanc 950.  
	    _valResult:=SD1->D1_VALICM  
	  EndIf	   
	           
  ENDIF

EndIf 

/*
	tratamento para rateio SDE	
*/   

if SD1->D1_RATEIO=="1" .AND. cEmpAnt == "MN"

cQry:=" SELECT R_E_C_N_O_ FROM "+RETSQLNAME("SDE")+chr(13)+chr(10)
cQry+=" WHERE D_E_L_E_T_='*' AND RTRIM(DE_FILIAL)+RTRIM(DE_DOC)+RTRIM(DE_SERIE)+RTRIM(DE_FORNECE)+RTRIM(DE_LOJA)+RTRIM(DE_ITEMNF) ='"
cQry+=RTRIM(SD1->D1_FILIAL) + RTRIM(SD1->D1_DOC) + RTRIM(SD1->D1_SERIE) + RTRIM(SD1->D1_FORNECE) + RTRIM(SD1->D1_LOJA) + RTRIM(SD1->D1_ITEM)+"'"

	if select("QUERY")>0
		QUERY->(DbCloseArea())
	endif
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QUERY", .F., .T.)
	
	COUNT TO nRecCount
	
	if nRecCount>0
		_valResult:=""	
	endif
	
endif


/*
	tratamento para rateio SDE	
*/   

DbSelectArea("SDE")
DbSetOrder(1)

if cEmpAnt == "MN" .And. DbSeek(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM )
	_valResult:=""	
//DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
endif

                                        
RETURN(_valResult)
