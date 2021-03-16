#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03
#include "topconn.ch"

User Function LP6504VAL()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,_CTES1,_cTes2")
     
_valResult:=0
cQry:=""
              
lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1 :=          "01A/02A/03A/04A/05A/06A/08A/09A/10A/32W/"
_cTes1 := _cTes1 + "11A/12A/08D/1O7/1O8/1OB/" //JSS em 09/10/2012 - Adicionado TES 1O7 para atender o caso 007323 //JSS em 28/02/2013 - Adicionado TES 1O8 para atender o caso 010041
_cTes1 := _cTes1 + "27A/28A/29A/30A/"
_cTes1 := _cTes1 + "05B/07B/08B/09B/10B/11B/23B/27B/30B/33B/37B/"
_cTes1 := _cTes1 + "03M/04M/05M/18M/14M/15M/16M/1HF"
_cTes1 := _cTes1 + "41O/43O/44O/45O/47O/"
_cTes1 := _cTes1 + "02P/10P/14P/32A/31A/01P/14P/01Q/14Q/41P/23O/10Q/11Q/13Q/15Q/18Q/"   
_cTes1 := _cTes1 + "05P/12P/13P/14Q/19P/19Q/21Q/23P/24O/26Q/27O/29O/29Q/30O/30Q/31Q/33P/40P/41P/42P/49O/11R" //solicitação da haidee

_cTes2 :=          "01A/16P/"
_cTes2 := _cTes2 + "02B/"
_cTes2 := _cTes2 + "19B/20B/21B/"
_cTes2 := _cTes2 + "25B/28B/"
_cTes2 := _cTes2 + "19M/"
_cTes2 := _cTes2 + "17P/26P/08R"

//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF SD1->D1_TES$(_cTes1+_cTes2)

        _valResult:=(SD1->D1_VALIPI)
   ELSE
		_valResult:=0

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

