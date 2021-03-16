#include 'protheus.ch'

/*
Funcao      : F060SEA2
Parametros  : Nenhum
Retorno     : Nil
Chamada		: Altera antes de gravar, ou grava informações adicionais na tabela SEA na geração do Borderô.
Autor       : Anderson Arrais	
Data/Hora   : 15/01/2019
Módulo      : Financeiro     
*/

*-----------------------*
 User Function F060SEA2()
*-----------------------*   

If cEmpAnt $ "O5"
	cLog := "ROTINA: F060SEA2 - Criacao do Bordero"
	U_O5GEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SEA->EA_NUMBOR,cLog)	               	

EndIf      

Return