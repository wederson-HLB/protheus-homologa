#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function lp6505cre()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTCRED,")

_cntCred:=space(9)

_cTes1 :=          "19O/20O/21O/22O/28O/18P/01Q/14Q/41P/23O/09P/21P/11Q/13Q/15Q/18Q/28Q/"
_cTes1 := _cTes1 + "02P/10P/14P/16P/08Q/09Q/10Q/12Q/04D/45Q/30Q/" 
_cTes1 := _cTes1 + "05P/12P/13P/14Q/19P/19Q/21Q/23P/24O/26Q/27O/29O/29Q/30O/30Q/31Q/33P/40P/41P/42P/49O" //solicitação da haidee

_cTes2 :=          "09A/10A/"
_cTes2 := _cTes2 + "11A/12A/"
_cTes2 := _cTes2 + "27A/28A/29A/30A/"
_cTes2 := _cTes2 + "08B/09B/10B/11B/11R"
_cTes2 := _cTes2 + "03M/04M/05M/"
_cTes2 := _cTes2 + "14M/15M/18M/"
_cTes2 := _cTes2 + "43O/44O/45O/47O"

_cTes3 :=          "13O/14O/15O/16O/17O/18O/"
_cTes3 := _cTes3 + "41O/"

_cTes4 :=          "04N/"

_cTes5 :=          "05I/02I/07I/13I/"

_cTes6 :=          "23B/28P/17P/"    /// NF DESP.IMPORT. S/ESTOQUE

_cTes7 :=          "46T/37V/37T"  // solicitação da Haidde 37018 RM

  

IF SD1->D1_TES $ (_cTes1)   
   _cntCred:="121110006"
	
ELSEIF SD1->D1_TES $ (_cTes2)     

   _cntCred:="112224001"

ELSEIF SD1->D1_TES $ (_cTes3)   

   _cntCred:="511136365"       

ELSEIF SD1->D1_TES $ (_cTes4)

   _cntCred:="131130001"

ELSEIF SD1->D1_TES $ (_cTes5)
   
   If SM0->M0_CODIGO $ 'HO/R7'//EBF - 05/09/2013 - Inclusão da Shiseido.
   	  _cntCred:="511128294"
   Else
	  _cntCred:="211240002"
   EndIf
   	  
ELSEIF SD1->D1_TES $ (_cTes6)

	_cntCred:="411112143"   
ELSEIF SD1->D1_TES $ (_cTes7)

	If SM0->M0_CODIGO $ 'U6' 	//CAS - 03/04/2018 - Ajuste para a empresa INTRALOX, pegar a conta pelo Produto. Ticket #28506
   		_cntCred:= SD1->D1_CONTA
   	Else
    	_cntCred:="511128294"
    EndIF

ENDIF


RETURN(_cntCred)
