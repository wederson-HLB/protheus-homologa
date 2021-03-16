#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP65012CRE()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CCREDITO,")


_CCREDITO := " "


IF SM0->M0_CODIGO $"02/VB/F2/CY"         /// EMPRESAS DO GRUPO PRYOR
	_CCREDITO:="211230011"
//VYB - 15/08/2016 - Chamdo 035575 - CORRIGIR AS CONTAS CONTABEIS DE PIS, COFINS E CSLL.	
ELSEIF SM0->M0_CODIGO $ "4Y"
	_CCREDITO:="31213004"
//VYB - FIM	
ELSE
	_CCREDITO:="211230010"
ENDIF
	
Return(_CCREDITO)        
