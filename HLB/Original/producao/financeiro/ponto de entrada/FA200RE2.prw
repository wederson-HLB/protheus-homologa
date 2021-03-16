#include 'protheus.ch'

/*
Funcao      : FA200RE2 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : O ponto de entrada FA200RE2 � executado antes da grava��o dos dados quando um registro � rejeitado.
Autor       : Anderson Arrais
Data/Hora   : 22/03/2017
Obs         :
Revis�o     :                                  	
M�dulo      : Financeiro
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