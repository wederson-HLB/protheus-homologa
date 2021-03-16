#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65105V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,")


_valResult:=0

lEasy     := SuperGetMV("MV_EASY") == "S"

_cTes1 :=          "09A/09B/10A/11A/11R/12A/27A/28A/29A/30A/08Q/09Q/10Q/12Q/01Q/14Q/11Q/13Q/15Q/18Q/28Q/08D/"
_cTes1 := _cTes1 + "08B/09B/10B/11B/45Q/30Q/"
_cTes1 := _cTes1 + "05I/07I/"
_cTes1 := _cTes1 + "03M/04M/05M/18M/14M/16M/"
_cTes1 := _cTes1 + "13O/14O/15O/16O/17O/18O/19O/20O/02I/"
_cTes1 := _cTes1 + "21O/22O/27O/28O/23O/"
_cTes1 := _cTes1 + "43O/44O/45O/47O/"
_cTes1 := _cTes1 + "02P/09P/"
_cTes1 := _cTes1 + "10P/14P/16P/17P/18P/"
_cTes1 := _cTes1 + "22P/"
_cTes1 := _cTes1 + "30P/31P/41P/"  
_cTes1 := _cTes1 + "05P/12P/13P/14Q/19P/19Q/21Q/23P/24O/26Q/27O/29O/29Q/30O/30Q/31Q/33P/40P/41P/42P/49O" //solicitação da haidee


_cTes2 :=          "04N/13I/46T/37T/37V"

_cTes3 :=          "28P"

   
//If !lEasy        
If EMPTY(SD1->D1_CONHEC)

   IF SD1->D1_TES $ (_cTes1)

    	    //_valResult:=(SD1->D1_VALICM+SD1->D1_VALIPI+SD1->D1_II)  34176 
    	    _valResult:=((SD1->D1_VALICM+SD1->D1_VALIPI+SD1->D1_II+SD1->D1_VALIMP5+SD1->D1_VALIMP6)*(SDE->DE_PERC/100)) 

   ELSEIF SD1->D1_TES $ (_cTes2)
	
        	_valResult:=(SD1->D1_VALICM*(SDE->DE_PERC/100))       	

   ELSEIF SD1->D1_TES $ (_cTes3)
	
        	_valResult:=(SDE->DE_CUSTO1)       	



   ELSE
	        _valResult:=0

   ENDIF
   
EndIf

Return(_valResult)
