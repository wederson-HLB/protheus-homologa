#Include "Protheus.Ch"

/*
Função..........: MTA260MNU
Objetivo........: Ponto de Entrada na montagem das opções do Browse  ( Transferencia )
Modulo..........: Estoque\Custos
Autor...........: Leandro Diniz de Brito ( BRL )
Data............: 22/01/2018
*/
*---------------------------------------*
User Function MTA260MNU                                
*---------------------------------------*
Local nPos

/*
	* Leandro Brito - Valida usuario que poderá incluir transferencia
*/                                                                   
If ( cEmpAnt == 'U2' )
	If ( nPos := Ascan( aRotina , { | x | Upper( x[ 2 ] ) == "A260INCLUI" } ) ) > 0 
		If !u_U2VldUser()
			aRotina[ nPos ][ 2 ] := "MsgStop('Usuario nao permitido para acessar esta rotina.' )"   	  //** Funcao u_U2VldUser fonte MTA260MNU.prw
		EndIf
	EndIf
EndIf

Return                                          

*---------------------------------------*
User Function U2VldUser
*---------------------------------------*
Local cUserAllow := GetMv( "MV_P_LIBTR" ,, "" ) 

If !( __cUserId $ cUserAllow )
	Return .F.
EndIf

Return( .T. )