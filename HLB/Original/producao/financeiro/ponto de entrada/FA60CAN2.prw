#Include "rwmake.ch"    

/*
Funcao      : FA60CAN2
Parametros  : 
Retorno     : 
Objetivos   : Limpa campo de código de barras ao estornar o borderô
Autor		: Anderson Arrais
Data/Hora   : 12/12/2016
Módulo      : Financeiro.
*/                      

*-----------------------*
 User Function FA60CAN2()   
*-----------------------*   
If cEmpAnt $ "HH/HJ"

	dbSelectArea("SE1")
	RecLock("SE1",.F.)			
		SE1->E1_CODBAR  := ""
		SE1->E1_CODDIG  := ""
		SE1->E1_P_RETBA := ""
		SE1->E1_P_DTRET := CTOD("//")
		SE1->E1_P_RETWS := ""
	SE1->(MsUnLock())
	
EndIf

//AOA - 05/07/2018 - Tratamento para Les Mills
If cEmpAnt $ "QN"

	dbSelectArea("SE1")
	RecLock("SE1",.F.)			
		SE1->E1_P_CONV := ""
		U_QNGEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,SE1->E1_P_CONV,"F590CAN: estorno bordero")	
	SE1->(MsUnLock())
	
EndIf

Return