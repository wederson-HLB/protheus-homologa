#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function 6503VCFO()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("_VALRESULT")       
                       
lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1 :=  "01E/02E/03E/04E/05E/06E/07E/08E/09E/10E/11E/12E/13E/08D/"
_cTes1 +=  "07M/08M/08D/01D/04D/05J/08D/"
_cTes1 +=  "11J/20M/21M/07A/11M/15M/12M/13M/24M/25M/26M/"   
_cTes2 := "12M/01M/"		// tes com diferencial de alíquota. Deve contabilizar o icms complementar
_cTes3 := "02I/07I/"

_valResult:=0

///////////  cfop ////////
/// 1352 -> COMPRA DE SERVICOS DE TRANSPORTE
/// 1556 -> COMPRA DE MATERIAL DE CONSUMO
/// 2556 -> COMPRA DE MATERIAL DE CONSUMO                                                                   
/// 3556 -> COMPRA DE MATERIAL DE CONSUMO  
/// 1403 -> COMPRA COMER..OPERACAO MER                                                                
//If ! lEasy
If EMPTY(SD1->D1_CONHEC) //17/03/2020 Adicionei a TES 2RW ( Validação da VICTORIA)
	If cEmpAnt $ "ZX/ZW/ZV/ZU/ZY/0B/0C/0E/UT" .and. SD1->D1_TES $ "2HM/2RW"//JVR - 027143 - Alteração Grupo de empresas TTG.
		_valResult:=0

	// PAULO SILVA - EMPRESA AMAZZONI - 11/03/2020 ( VALIDADO POR ALINE SONEGO).
    ELSEIf cEmpAnt $ "UT" .and. SD1->D1_TES $ "2TU/1QH/1XX/"
		_valResult:= SD1->D1_VALICM
    
	// PAULO SILVA - EMPRESA AMAZZONI - 11/03/2020 ( VALIDADO POR ALINE SONEGO).
	ELSEIf cEmpAnt $ "UT" .and. SD1->D1_TES $ "14I" 
		_valResult:= 0

	// PAULO SILVA - EMPRESA MONSTER - 07/04/2020 ( Validade por Jacqueline).
    ELSEIf cEmpAnt $ "JO" .and. SD1->D1_TES $ "1RY"
		_valResult:= 0

	ElseIf Alltrim(SD1->D1_CF)$ "1556/2556/3556/2551/2552/3551/3552/1551/1253/1303/1407/1403/2403" .OR.;
		  (Alltrim(SD1->D1_CF)$ '1911/2911/1353/2353/1933/2933' .And. SF4->F4_LFICM <> 'T') .OR.;
		  SD1->D1_TIPO $ "D/"//.OR.(SD1->D1_TES$_cTes1)) .AND. !(SD1->D1_TES$(_cTes2+_cTes3)) 
		_valResult:=0

	Else
		_valResult:=(SD1->D1_VALICM+SD1->D1_ICMSCOM)

	EndIf
EndIf


RETURN(_valResult)
