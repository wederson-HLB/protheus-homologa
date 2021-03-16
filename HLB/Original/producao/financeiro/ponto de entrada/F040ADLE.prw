#INCLUDE "PROTHEUS.CH"

/*
Funcao      : F040ADLE 
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : O ponto de Entrada F040ADLE adiciona Legenda na funçao FINA040.
Autor       : Anderson Arrais
Data/Hora   : 31/03/2017
Módulo      : Financeiro
*/
*-----------------------*
User Function F040ADLE()
*-----------------------*
Local aRet := {}              

If cEmpAnt $ "HH/HJ"
 
 	If FunName() $ "FINA040/FINA740"
		aAdd(aRet,{"BR_LARANJA","Título em Cobrança Externa"})
 	EndIf

EndIf

Return aRet