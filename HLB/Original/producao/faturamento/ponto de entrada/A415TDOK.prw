#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : A415TDOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validar se o orçamento está ok
Autor       : Tiago Luiz Mendonça
Data        : 17/09/2014        
TND         : Este ponto de entrada é disparado na validação da tudook da rotina de orcamento de venda.
Revisão     :        
Data        : 
Módulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function A415TDOK()   
*----------------------*    

Local lRet:=.T.
                 

	If cEmpAnt $ "TM"     
		If M->CJ_P_REV=="S"  
			MsgStop("Esse orçamento não pode ser alterado pois já está revisado","Victaulic")			
			lRet:=.F.     	
		EndIf
	EndIf         


Return lRet