#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
#include "topconn.ch"

/*
Funcao      : LP6507VAL
Parametros  : Nenhum
Retorno     : cRet
Objetivos   : Lançamento Padrão
Autor       : 
TDN         : 
Revisão     : Renato de Rezende
Data/Hora   : 28/08/2013
Módulo      : Contabilidade.
*/    
   
*-------------------------*
User Function LP6507VAL()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
*-------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,_CTES1,_CTES2,_CTES3,")


_valResult:=0
cQry:=""

lEasy     := SuperGetMV("MV_EASY") == "S"
               

_cTes1 :=          "01A/02A/03A/04A/05A/06A/07A/08A/08B/09B/"
_cTes1 := _cTes1 + "13A/14A/16A/17A/18A/19A/20A/"
_cTes1 := _cTes1 + "21A/"
_cTes1 := _cTes1 + "01B/02B/03B/04B/05B/06B/07B/"
_cTes1 := _cTes1 + "13B/15B/16B/17B/18B/22B/26B/"
_cTes1 := _cTes1 + "05G/"
_cTes1 := _cTes1 + "02I/05I/"
_cTes1 := _cTes1 + "19M/"
_cTes1 := _cTes1 + "08P/49P/31A/1BG"

_cTes2 :=          "22A/23A/23Q/24A/25A/26A/"
_cTes2 := _cTes2 + "01G/02G/03G/04G/05G/06G/07G/08G/09G/10G/"
_cTes2 := _cTes2 + "11R/12G/13G/14G/15G/16G/"
_cTes2 := _cTes2 + "01H/02H/03H/04H/05H/06H/07H/"
_cTes2 := _cTes2 + "01I/"

_cTes3 :=          "02I/03I/04I/06I/07I/08I/09I/10I/11I/"
_cTes3 := _cTes3 + "01J/02J/03J/04J/05J/06J/11J/"
_cTes3 := _cTes3 + "01M/02M/03M/09M/10M/11M/12M/13M/"
_cTes3 := _cTes3 + "01O/40O/41O/42O/46O/48O/23Q/33B"
//EBF - 08/08/2013 - Inclusão de TES conforme chamado 013686 e 013523
_cTes3 += "1HA/1IP/1BH"

// RRP - 03/06/2013 - Inclusao da TES conforme chamado 011850.
If cEmpAnt $ "U6" // Intralox
	_cTes3 := _cTes3 + "37V"
EndIf

//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF SD1->D1_TES$(_cTes1+_cTes2+_cTes3)
      _valResult:=(SD1->D1_VALIMP6)
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

