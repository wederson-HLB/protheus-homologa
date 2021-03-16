#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : A415TDOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validar se o or�amento est� ok
Autor       : Tiago Luiz Mendon�a
Data        : 17/09/2014        
TND         : Este ponto de entrada � disparado na valida��o da tudook da rotina de orcamento de venda.
Revis�o     :        
Data        : 
M�dulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function A415TDOK()   
*----------------------*    

Local lRet:=.T.
                 

	If cEmpAnt $ "TM"     
		If M->CJ_P_REV=="S"  
			MsgStop("Esse or�amento n�o pode ser alterado pois j� est� revisado","Victaulic")			
			lRet:=.F.     	
		EndIf
	EndIf         


Return lRet