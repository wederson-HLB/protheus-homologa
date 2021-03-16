#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function lp6501deb()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CNTDEB,")


_cntDeb:=space(9)


    IF SD1->D1_TES$"01B" .AND. (SM0->M0_CODIGO $ "XC")   
    
      		_cntDeb:="113170002"

	ELSEIF SD1->D1_TES$"48H" .AND. (SM0->M0_CODIGO $ "FF")//Solicitado por Pedro Marques - 004111

        	_cntDeb:="113110008"

	ELSEIF SD1->D1_TES$"09A/10A/11A/12A/08B/09B/10B/01B"

        	_cntDeb:="113170001"

	ELSEIF SD1->D1_TES$"28P"

        	_cntDeb:="113110002"                
        	
        	
	ELSEIF ((SD1->D1_TES $ "13I") .AND. (SM0->M0_CODIGO $ "FF"))
		
			_cntDeb := "113170001"             
        	
       	
	ELSEIF ((SD1->D1_TES $ "21L/1Z7/1GB/22A") .AND. (SM0->M0_CODIGO $ "FF"))
		
			_cntDeb := "113170002"      

	ELSE
	   		_cntDeb:=SB1->B1_CONTA

ENDIF


RETURN(_cntDeb)