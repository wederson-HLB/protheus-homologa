#include "apwebex.ch"
#include "totvs.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWRHO05  �Autor  �Tiago Luiz Mendon�a � Data �  10/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controle de ferias - rejeitar                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
                               
/*
Funcao      : GTWRHO05
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX para controle de ferias - rejeitar
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 19/09/12
*/                                      	

*-----------------------*
User Function GTWRHO05()
*-----------------------*

Local cHtml	:= "" 

HttpSession->cSolicitacoes := HttpPost->solicitacoes   // Array com as solicitacoes rejeitadas
 
WEB EXTENDED INIT cHtml

	cHtml := ExecInPage("GTWRHO05")  


WEB EXTENDED END
	 
Return cHtml