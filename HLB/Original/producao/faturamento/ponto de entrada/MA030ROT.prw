#INCLUDE "Protheus.ch"

/*
Funcao      : MA030ROT
Parametros  : PARAMIXB
Retorno     : 
Objetivos   : P.E. no aRotina do cadastro de clientes
Autor     	: Marcus - EZ4
Data     	: 08/08/2018
Obs         : 
TDN         : aRotina do cadastro de clientes
Módulo      : Faturamento.    
*/
*----------------------*
User Function MA030ROT()
*----------------------*
Local aRetorno	:= {}

If cEmpAnt $ "N6"//doTerra
	Aadd( aRetorno, {"Endereço de entrega","U_N6FAT006()", 2, 0 })
EndIf

Return aRetorno