#include "apwebex.ch"
#include "totvs.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWRHO04  �Autor  �Tiago Luiz Mendon�a � Data �  20/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controle de ferias - formulario                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
                               
/*
Funcao      : GTWRHO04
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX para controle de ferias - formulario
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 20/09/12
*/                                      	

*-----------------------*
User Function GTWRHO04()
*-----------------------*

Local cHtml	:= "" 

 
WEB EXTENDED INIT cHtml

	cHtml := ExecInPage("GTWRHO04")  


WEB EXTENDED END
	 
Return cHtml