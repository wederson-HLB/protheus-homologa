#include "totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE05NFESEFAZ �Autor �Anderson Arrais�		 Data �  20/01/12 ���
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
User Function PE05NFESEFAZ()
*--------------------------* 
Local cString := ParamIXB 

dbSelectArea("SC5")
dbSetOrder(1)
If SC5->(FieldPos("C5_P_NPROC")) > 0 .And. !Empty(SC5->C5_P_NPROC) .And. SC5->(FieldPos("C5_P_IPROC")) > 0 .And. !Empty(SC5->C5_P_IPROC)
	cString += '<procRef>'
       cString += '<nProc>'+Alltrim(cvaltochar(SC5->C5_P_NPROC))+'</nProc>'
       cString += '<indProc>'+cvaltochar(SC5->C5_P_IPROC)+'</indProc>'
   cString += '</procRef>'
EndIf 
  
Return cString