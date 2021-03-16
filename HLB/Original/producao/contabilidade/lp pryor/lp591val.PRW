#include "rwmake.ch" 
//--------------------------------//
//----José Ferreira - 03/07/06    //
//--------------------------------//
USER FUNCTION LP591val()
_vRetorno:=0
_Valor	:=0  
IF GetMv("MV_MCONTAB") $ "CON"   // SIGACON

	IF AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59102"
		_Valor:=SE2->E2_MULTA
	ELSEIF AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59103"
		_Valor:=SE2->E2_JUROS
	ELSEIF AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59104"
		_Valor:=SE2->E2_DESCONTO
	ELSEIF AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59105"
		_Valor:=SEF->EF_VALOR
	ELSEIF AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59106"
		_Valor:=SE2->E2_VRETPIS
	elseif AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59107"	
		_Valor:=SE2->E2_VRETCOF
	elseif AllTrim(SI5->I5_CODIGO)+Alltrim(SI5->I5_SEQUENC) $ "59108"	
		_Valor:=SE2->E2_VRETCSL
	ENDIF
	
	IF SEF->EF_NUM==SE2->E2_NUMBCO.AND.SEF->EF_FORNECE==SE2->E2_FORNECE .AND. SEF->EF_ORIGEM == "FINA080/FINA750"
		_vRetorno:= _Valor
	ELSEIF  SEF->EF_FORNECE==SE2->E2_FORNECE 
		_vRetorno:= _Valor
	ENDIF
else // contabilidade gerencial
ComparaEC:= paramixb
	IF AllTrim(ComparaEC) $ "591002"
		_Valor:=SE2->E2_MULTA
	ELSEIF AllTrim(ComparaEC) $ "591003"
		_Valor:=SE2->E2_JUROS
	ELSEIF AllTrim(ComparaEC) $ "591004"
		_Valor:=SE2->E2_DESCONTO
	ELSEIF AllTrim(ComparaEC) $ "591005"
		_Valor:=SE2->E2_VALOR
	ELSEIF AllTrim(ComparaEC) $ "591006"
		_Valor:=SE2->E2_VRETPIS
	elseif AllTrim(ComparaEC) $ "591007"	
		_Valor:=SE2->E2_VRETCOF
	elseif AllTrim(ComparaEC) $ "591008"	
		_Valor:=SE2->E2_VRETCSL
	ENDIF
	
	_vRetorno:= _Valor

endif	
RETURN   (_vRetorno)                                                                                                                       