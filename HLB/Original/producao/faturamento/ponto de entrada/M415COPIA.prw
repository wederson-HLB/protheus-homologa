#include "TOTVS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'

/*
Funcao      : M415COPIA
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Não permite copia de orçamento
Autor       : Tiago Luiz Mendonça
Data        : 17/09/2014        
TND         : Criado ponto de entrada M415COPIA na função A415Copia para permitir ou não a cópia de um orçamento
Revisão     :        
Data        : 
Módulo      : Faturamento.
Empresa     : Victaulic
*/                        
*----------------------*
User Function M415COPIA()   
*----------------------*    

Local lRet:=.T.
                 

	If cEmpAnt $ "TM"     
		If SCJ->CJ_P_REV=="S"  
			MsgStop("Opção COPIA não pode ser executada, pois esse orçamento está revisado","Victaulic")			
			lRet:=.F.     	
		EndIf
	EndIf         


Return lRet