#include "apwebex.ch"
#include "totvs.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWRHO02  �Autor  �Tiago Luiz Mendon�a � Data �  10/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Solicita��o de ferias - confirma��o                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
                               
/*
Funcao      : GTWRHO02
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX para solicita��o de ferias - confirma��o
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 10/09/12
*/

*-----------------------*
User Function GTWRHO02()
*-----------------------*

Local cHtml	:= "" 

HttpSession->cDecimo := HttpPost->Dec1     		// Varival decimo terceiro - SIM/NAO
HttpSession->cAbono  := HttpPost->Dec2 		 	// Varival do abono        - SIM/NAO
HttpSession->cDtIni  := HttpPost->calendario1   // Varival data inicial    
HttpSession->cDtFim  := HttpPost->calendario2   // Varival data final    
 
WEB EXTENDED INIT cHtml

	cHtml := ExecInPage("GTWRHO02")

WEB EXTENDED END
	 
Return cHtml