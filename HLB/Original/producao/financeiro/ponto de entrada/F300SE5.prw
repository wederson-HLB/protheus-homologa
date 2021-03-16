#include 'protheus.ch'

/*
Funcao      : F300SE5
Parametros  : Nenhum
Retorno     : Nil
Rotina		: FINA300 / Retorno SISPAG
Chamada		: O ponto de entrada F300SE5 tem como finalidade gravar complemento das baixas CNAB a pagar do retorno SISPAG.
Autor       : Anderson Arrais	
Data/Hora   : 20/03/2017
Obs         :
Revisão     :
Módulo      : Financeiro     
*/

*------------------------*
 User Function F300SE5()
*------------------------*   
If cEmpAnt $ "HH/HJ" .AND. ALLTRIM(SE5->E5_TIPODOC) $ "VL"
	RecLock("SE5",.F.)
		Replace SE5->E5_HISTOR With SE5->E5_NUMERO +" - "+ Posicione("SA2",1,xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A2_NOME")
	SE5->(MsUnlock())		
EndIf 

Return