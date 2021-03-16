#Include "Protheus.Ch"

/*
Função..........: MTA261MNU
Objetivo........: Ponto de Entrada na montagem das opções do Browse  ( Transferencia Mod. 2 )
Modulo..........: Estoque\Custos
Autor...........: Leandro Diniz de Brito ( BRL )
Data............: 22/01/2018
*/
*---------------------------------------*
User Function MTA261MNU                                
*---------------------------------------*
Local nPos

/*
	* Leandro Brito - Valida usuario que poderá incluir transferencia
*/                                                                   
If ( cEmpAnt == 'U2' )
	If ( nPos := Ascan( aRotina , { | x | Upper( x[ 2 ] ) == "A261INCLUI" } ) ) > 0 
		If !u_U2VldUser()
			aRotina[ nPos ][ 2 ] := "MsgStop('Usuario nao permitido para acessar esta rotina.' )"   	  //** Funcao u_U2VldUser fonte MTA260MNU.prw
		EndIf
	EndIf
EndIf

Return       