#Include 'Protheus.Ch'

/*
Função.............: SF1100I
Objetivo...........: Ponto de Entrada após gravação da nota de entrada
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 18/12/2015
Observações........: Uso ambiente GTCorp
*/ 

*-------------------------------*                 
User Function SF1100I                             
*-------------------------------*                 

If ( SF1->F1_TIPO == 'N' ) .And. !Empty( SF1->F1_DUPL )
	u_GtFin013( 'NF' )	
EndIf

Return