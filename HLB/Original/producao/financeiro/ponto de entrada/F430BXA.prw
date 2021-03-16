#include 'protheus.ch'

/*
Funcao      : F430BXA
Parametros  : Nenhum
Retorno     : Nil
Rotina		: FINA430 / Retorno CNAB
Chamada		: O ponto de entrada F430BXA tem como finalidade gravar complemento das baixas CNAB a pagar do retorno bancario.
Autor       : Richard S. Busso	
Data/Hora   : 27/01/2017
Obs         :
Revisão     :
Módulo      : Financeiro     
*/

*------------------------*
 User Function F430BXA()
*------------------------*   
    // RSB - 30/01/2017 - Chamado 0038833
    // Alterar o historico da baixa no SE5 quando for via CNAB a pagar de "Valor pago s/ Titulo" para TIPO + PREFIXO + NUMERO + NATUREZA  
    if cEmpAnt $ "DW" 
		RecLock("SE5",.F.)
			Replace SE5->E5_HISTOR With SE5->E5_TIPO + " " + SE5->E5_PREFIXO + " " + SE5->E5_NUMERO + " " + Posicione("SED",1,xFilial("SED")+alltrim(SE5->E5_NATUREZ),"ED_DESCRIC") 
		SE5->(MsUnlock())
	endif	
    
	//AOA - 20/03/2017 - Alterar historico solaris
	If cEmpAnt $ "HH/HJ" .AND. ALLTRIM(SE5->E5_TIPODOC) $ "VL"
		RecLock("SE5",.F.)
			Replace SE5->E5_HISTOR With SE5->E5_NUMERO +" - "+ Posicione("SA2",1,xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A2_NOME")
		SE5->(MsUnlock())		
	EndIf
Return