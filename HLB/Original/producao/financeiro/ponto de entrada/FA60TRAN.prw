#include 'protheus.ch'

/*
Funcao      : FA60TRAN
Parametros  : Nenhum
Retorno     : Nil
Chamada		: O ponto de entrada FA60TRAN será executado ao final da rotina de transferência de contas a receber, ao remover de carteira. 
Autor       : Anderson Arrais	
Data/Hora   : 17/05/2017
Obs         :
Módulo      : Financeiro     
*/

*-----------------------*
 User Function FA60TRAN()
*-----------------------*   
If cEmpAnt $ "HH/HJ"
	RecLock("SE1",.F.)
		SE1->E1_CODBAR  := ""
		SE1->E1_CODDIG  := ""
		SE1->E1_P_RETBA := ""
		SE1->E1_P_DTRET := CTOD("//")
		SE1->E1_P_RETWS := ""
	SE1->(MsUnlock())		
EndIf 

//AOA - 05/07/2018 - Tratamento para Les Mills
If cEmpAnt $ "QN"
	RecLock("SE1",.F.)
		SE1->E1_P_CONV  := ""
	SE1->(MsUnlock())		
EndIf 

Return