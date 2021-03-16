#include 'protheus.ch'

/*
Funcao      : F060SEA
Parametros  : Nenhum
Retorno     : Nil
Chamada		: O ponto de entrada F060SEA sera executado durante a grava��o dos dados do bordero (SEA) na transfer�ncia.
Autor       : Anderson Arrais	
Data/Hora   : 21/03/2017
Obs         :
Revis�o     :
M�dulo      : Financeiro     
*/

*-----------------------*
 User Function F060SEA()
*-----------------------*   
If cEmpAnt $ "HH/HJ" .AND. SEA->EA_SITUACA $ "0"
	RecLock("SE1",.F.)
		SE1->E1_CODBAR  := ""
		SE1->E1_CODDIG  := ""
	SE1->(MsUnlock())		
EndIf 

Return