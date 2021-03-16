#Include "Protheus.Ch"

/*
Fun��o.............: FA050CT
Objetivo...........: Ponto de Entrada ap�s grava��o do titulo no Contas a Pagar
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 18/12/2015
Observa��es........: Uso ambiente GTCorp
*/ 
*---------------------------*
User Function FA050CT       
*---------------------------*

If AllTrim( SE2->E2_ORIGEM ) == 'FINA050' .And.  !IsBlind()

	u_GtFin013( 'CP' )	
	
EndIf

Return