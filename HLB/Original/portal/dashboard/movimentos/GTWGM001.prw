#include "apwebex.ch"
#include "totvs.ch"
#include 'tbiconn.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTWGM001 �Autor  �Tiago Luiz Mendon�a  �  Data �  08/08/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � Movimenta��o por empresa - Dashboard.                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
������������������������������'�����������������������������������������������
�����������������������������������������������������������������������������
*/ 

/*
Funcao      : GTWGM001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina APWBEX de grafico de movimenta��o.
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 08/08/12 20:00
*/
                

*-----------------------*
User Function GTWGM001()
*-----------------------*

Local cHtml	:= ""

Local nCon  

WEB EXTENDED INIT cHtml

	If Select("SX2") == 0
		PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'FIN'
	EndIf

	//Verifica se a sess�o expirou.
	If  ValType(HttpSession->cLogin)<> "C" .or. Empty(HttpSession->cLogin);
	.or. ValType(HttpSession->cEmpresa)<> "C" .or. Empty(HttpSession->cEmpresa)
		cHtml := ExecInPage("GTWP007") //Pagina de sess�o expirada.
	Else     
		cHtml := U_GTWGM002()  //Pagina do grafico movimenta��o 001.
	EndIf
	
WEB EXTENDED END
	 
Return cHtml
