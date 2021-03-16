#Include 'Protheus.Ch'

/*
Fun��o.............: SF1100I
Objetivo...........: Ponto de Entrada ap�s grava��o da nota de entrada
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 18/12/2015
Observa��es........: Uso ambiente GTCorp
*/ 

*-------------------------------*                 
User Function SF1100I                             
*-------------------------------*                 

If ( SF1->F1_TIPO == 'N' ) .And. !Empty( SF1->F1_DUPL )
	u_GtFin013( 'NF' )	
EndIf

Return