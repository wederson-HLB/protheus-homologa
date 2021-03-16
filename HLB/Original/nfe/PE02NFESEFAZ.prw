#include "totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE02NFESEFAZ �Autor �Eduardo C. Romanini�  Data �  11/11/11 ���
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
User Function PE02NFESEFAZ()
*--------------------------*   
Local cOrd    := ParamIXB
Local cCodEmp := AllTrim(SM0->M0_CODIGO)

//Shiseido
If cCodEmp == "R7"
	
	//Ordena��o por C�digo do Produto.	
	cOrd := "%D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEM%"

EndIf

cOrd := Alltrim(cOrd)

If Left(cOrd,1) <> "%"
	cOrd := "%" + cOrd
EndIf

If Right(cOrd,1) <> "%"
	cOrd := cOrd + "%"
EndIf

Return cOrd
