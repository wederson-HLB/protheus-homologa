#include "rwmake.ch"         // incluido pelo assistente de conversao do AP5 IDE em 15/01/03
                            
User Function lp5107val()   // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VRETORNO")

	_vRetorno:=0     

	//VALOR APURA플O PIS
	//Solicitado por Haidee
	IF SM0->M0_CODIGO $ "CH/RH/Z4/Z5/Z6/Z8/ZB/ZD/ZF/ZG/ZP/PL"  //EMPRESAS GRUPO PRYOR - PL = POLARIS (SOLICITADO POR JULIANE DALAQUA)
		IF SED->ED_APURPIS == 'C'
			_vRetorno := ((SE2->E2_VALOR + SE2->E2_IRRF)/SED->ED_PCAPPIS)
		ENDIF
	ENDIF
		
RETURN(_vRetorno)