#include "rwmake.ch"         // incluido pelo assistente de conversao do AP5 IDE em 15/01/03
                            
User Function lp5108val()   // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("_VRETORNO")

	_vRetorno:=0     
		
	//VALOR APURA플O COFINS  
    //Solicitado por Haidee
	IF SM0->M0_CODIGO $ "CH/RH/Z4/Z5/Z6/Z8/ZB/ZD/ZF/ZG/ZP/PL"  //EMPRESAS GRUPO PRYOR - PL = POLARIS (SOLICITADO POR JULIANE DALAQUA)
		IF SED->ED_APURCOF == 'C'
			_vApurCofins := ((SE2->E2_VALOR + SE2->E2_IRRF)/SED->ED_PCAPCOF)
 		ENDIF   
    ENDIF
   
RETURN(_vRetorno)