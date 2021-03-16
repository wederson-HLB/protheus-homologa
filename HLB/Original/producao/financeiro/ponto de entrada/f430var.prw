/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Rotina    � F430VAR.PRW                                                ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada para retornar Juros e Multa quando nao    ���
���          � tiver no arquivo de retorno do banco.                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Desenvolvi� Jo�o Vitor		                                          ���
���mento     � 13/05/2016	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
���                                                                       ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
*/

#INCLUDE 'RWMAKE.CH'

USER FUNCTION F430VAR()
LOCAL lAccesOK := SUPERGETMV("MV_P_00130",.F.,.F.)// SE A EMPRESA UTILIZA A ROTINA DA ACCESSTAGE DEVE VALIDAR OS CAMPOS DA TABELA SE2 (TITULOS A PAGAR)

If cEmpAnt $ "SU"
 	If ExistBlock("SUFIN007")
		U_SUFIN007()
	EndIf        
EndIf
	
//CAS - 24/06/2020 Ajustado Leiaute, tratar juros e multa no retorno do CNAB para Segmento N
IF lAccesOK
 	If ExistBlock("GTFIN038")
		U_GTFIN038(12,'PARAMIXB')
	EndIf
EndIf	
	
Return()
