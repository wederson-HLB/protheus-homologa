#include "totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE03NFESEFAZ �Autor �Eduardo C. Romanini�  Data �  20/01/12 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada do fonte NfeSefaz, responsavel pela        ���
���          �transmiss�o de Notas Fiscais Eletronicas.                   ���
�������������������������������������������������������������������������͹��
���Uso       � HLB BRASIL                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*--------------------------*
User Function PE03NFESEFAZ()
*--------------------------*   
Local cMensFis := ParamIXB
Local cMsgIni  := ""
Local cCodEmp  := AllTrim(SM0->M0_CODIGO)

Local nAt := 0

//Shiseido
If cCodEmp == "R7"
	
	//Apaga a mensagem padr�o, para que seja substituida pela customizada.
	If !Empty(cMensFis)		
		nAt := At("Imposto Recolhido por Substitui��o - Contempla os artigos 273, 313 do RICMS.",cMensFis)	
			
		//Guarda a parte antes da mensagem que ser�Eapagada.
		If nAt > 1
			cMsgIni := Substr(cMensFis,1,nAt-1)
		EndIf
			
		While nAt > 0
			cMensFis := Substr(cMensFis,nAt+154)
			nAt := At("Imposto Recolhido por Substitui��o - Contempla os artigos 273, 313 do RICMS.",cMensFis)
		EndDo
			
		cMensFis := cMsgIni + cMensFis
			
	EndIf

EndIf

Return cMensFis
