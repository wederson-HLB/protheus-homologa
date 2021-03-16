#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6109vl()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VRETORNO,_CFOP")


_vRetorno:=0

_CFOP    := "5201/6201/7201/5202/6202/7202/5205/6205/7205/5206/6206/7206/5207/6207/7207/5208/6208/5209/6209/5210/6210/7210/5556/5403" 
	
	//LOS - 17/07/2018 - Tratamento com CFOP 5403 para a empresa 41.
	If cEmpAnt $ "41"
	
		_CFOP    := "5201/6201/7201/5202/6202/7202/5205/6205/7205/5206/6206/7206/5207/6207/7207/5208/6208/5209/6209/5210/6210/7210/5556/" // LP 5403 Removido //
	
		IF ALLTRIM(SD2->D2_CF) $ _CFOP
		
			_vRetorno:=(SD2->D2_VALIPI)
	                                        
		ELSE
	    	_vRetorno:=0
	
		ENDIF

	ELSEIF ALLTRIM(SD2->D2_CF) $ _CFOP
		
			_vRetorno:=(SD2->D2_VALIPI)
	                                        
	ELSE
	    	_vRetorno:=0
	
	ENDIF



RETURN(_vRetorno)


