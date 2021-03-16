#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : M415COPIA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : N�o permite copia de or�amento
Autor       : Tiago Luiz Mendon�a
Data        : 17/09/2014        
TND         : Criado ponto de entrada M415COPIA na fun��o A415Copia para permitir ou n�o a c�pia de um or�amento
Revis�o     :        
Data        : 
M�dulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function M415COPIA()   
*----------------------*    

Local lRet:=.T.
                 

	If cEmpAnt $ "TM"     
		If SCJ->CJ_P_REV=="S"  
			MsgStop("Op��o COPIA n�o pode ser executada, pois esse or�amento est� revisado","Victaulic")			
			lRet:=.F.     	
		EndIf
	EndIf         


Return lRet