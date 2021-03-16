#include 'protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTFIN007() �Autor  �Anderson Arrais   � Data �  28/10/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte c�digo de barras de concessionaria com 48 d�gitos  ���
���          �e boleto banc�rio de 47 d�gitos para o padr�o febraban      ���
���          �de 44 d�gitos                                               ���
�������������������������������������������������������������������������͹��
���Uso       � 							                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*--------------------------*
User Function GTFIN007()
*--------------------------*        
Local cCodBar:= ""
Local cA:=""
Local cB:=""
Local cC:=""
Local cD:=""
    
	If LEN(ALLTRIM(SE2->E2_CODBAR))== 48 //C�digo de barras Concession�ria
		
		cCodBar:= SUBSTR(SE2->E2_CODBAR,1,11)+SUBSTR(SE2->E2_CODBAR,13,11)+SUBSTR(SE2->E2_CODBAR,25,11)+SUBSTR(SE2->E2_CODBAR,37,11)
		
	ElseIf LEN(ALLTRIM(SE2->E2_CODBAR))== 47 //C�digo de barras Boleto Banc�rio

		cA:=SUBSTR(SE2->E2_CODBAR,1,4)
		cB:=SUBSTR(SE2->E2_CODBAR,5,5)+SUBSTR(SE2->E2_CODBAR,11,10)+SUBSTR(SE2->E2_CODBAR,22,10)	
		cC:=SUBSTR(SE2->E2_CODBAR,33,1)
		cD:=SUBSTR(SE2->E2_CODBAR,34,14)
		//Tratamento da ordem
		cCodBar:=cA+cC+cD+cB
	
	Else
	
		cCodBar:= ALLTRIM(SE2->E2_CODBAR)
	
	EndIf
		
Return(cCodBar)