#include 'protheus.ch'

/*
Funcao      : FA200RE2 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : O ponto de entrada FA200RE2 é executado antes da gravação dos dados quando um registro é rejeitado.
Autor       : Anderson Arrais
Data/Hora   : 22/03/2017
Obs         :
Revisão     :                                  	
Módulo      : Financeiro
*/

*------------------------*
 User Function FA200RE2()
*------------------------*       
if cEmpAnt $ "HH/HJ"
	RecLock("SE1",.F.)
		Replace SE1->E1_P_RETBA With SEB->EB_REFBAN
		Replace SE1->E1_CODBAR  With ""
		Replace SE1->E1_CODDIG  With ""
	SE1->(MsUnlock())
Endif
	
Return