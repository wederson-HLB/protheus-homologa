#INCLUDE "PROTHEUS.CH"

/*
Funcao      : F040URET 
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : O ponto de entrada F040URET inclui a condição para nova legenda para as rotinas FINA040, FINA050.
Autor       : Anderson Arrais
Data/Hora   : 31/03/2017
Módulo      : Financeiro
*/
*-----------------------*
User Function F040URET()
*-----------------------*

Local aRet := {}                      

If cEmpAnt $ "HH/HJ"

	If FunName() $ "FINA040/FINA740"
		aAdd(aRet,{"!Empty(E1_P_COBEX)","BR_LARANJA"})
	Endif

EndIf

Return aRet