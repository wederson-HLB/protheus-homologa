#Include "Protheus.Ch"

/*
Função.............: FA050CT
Objetivo...........: Ponto de Entrada após gravação do titulo no Contas a Pagar
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 18/12/2015
Observações........: Uso ambiente GTCorp
*/ 
*---------------------------*
User Function FA050CT       
*---------------------------*

If AllTrim( SE2->E2_ORIGEM ) == 'FINA050' .And.  !IsBlind()

	u_GtFin013( 'CP' )	
	
EndIf

Return