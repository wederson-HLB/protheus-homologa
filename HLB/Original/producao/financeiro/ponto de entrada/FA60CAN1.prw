#Include "rwmake.ch"    

/*
Funcao      : FA60CAN1
Parametros  : 
Retorno     : 
Objetivos   : Será executado antes da gravação do SE1 no estorno do borderô do contas a receber.
Autor		: Anderson Arrais
Data/Hora   : 15/01/2019
Módulo      : Financeiro.
*/                      

*-----------------------*
 User Function FA60CAN1()   
*-----------------------*   
If cEmpAnt $ "O5"
	cLog := "ROTINA: FA60CAN1 - Bordero estornado"
	U_O5GEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,cLog)	               	

EndIf   

Return .T.