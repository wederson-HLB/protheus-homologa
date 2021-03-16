#include "Protheus.ch"

/*
Funcao      : F240CAN
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. no cancelamento de borderô(Borderô de pagamentos)
Autor     	: Matheus Massarotto
Data     	: 28/07/2011  
Obs         : 
TDN         : O ponto de entrada F240CAN sera utilizado no tratamento complementar do cancelamento do bordero e sera executado apos excluir o registro no arquivo de borderos (SEA).
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Financeiro
Cliente     : Takeda
*/

*----------------------*
 User function F240CAN
*----------------------*

If !cEmpAnt $ "TK/UZ/JO/46/VN/TM/KI/1F/HP/L1/4V/WA/N8/I2/VW/0F/M7/QU"
	Return .F.
Endif 

	RecLock("SE2",.F.)
		SE2->E2_IDCNAB:=""
	SE2->(MsUnlock())  
	
Return