#include "PROTHEUS.CH"

#define ENTER CHR(13)+CHR(10)
/*/{Protheus.doc} FIN420_1
//TODO (PE) PONTO DE ENTRADA LOOPING DO PROCESSAMENTO
@author Leosanlim
@since 15/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
USER FUNCTION FIN420_1()
	*=====================================================================================================================================*
	LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
	
	ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FIN420_1() "+Dtoc(Date())+" "+Time()+" LINHA: 17 *********")
	IF lAccesOK // SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)
		IF !EMPTY(cDirCnab)        	
			RecLock( "SEA", .F. )
			SEA->EA_P_ARQ := cDirCnab
			MsUnlock( ) 
		ENDIF 
		cDirCnab := cDirCnab
		ConOut("********* CUSTOMIZAÇÃO EZ4 (PE) FIN420_1() "+Dtoc(Date())+" "+Time()+" LINHA: 25 *********")
	ENDIF
RETURN 