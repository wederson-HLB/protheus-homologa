#Include"Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F590COK() �Autor  �Jo�o Silva         � Data �  17/02/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada que valida o cancelamento/retirada de um   ���
���          � determinado t��ulo de um border�E              			  ���
�������������������������������������������������������������������������͹��
���Uso       �  AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*----------------------*
User Function F590COK()
*----------------------*
Local cTipo 	:= PARAMIXB[1]
Local cNumBor 	:= PARAMIXB[2]
Local lRet 		:= .T.

If cEmpAnt = "TP"//Verifica se �Ea empresa Twitter.
	If cTipo=="R"//Verifica se �Eum bordero de contas a receber.
		SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA))
			If SF2->F2_P_ENV = 'S'//Verifica se o titulo ja foi enviado ao cliente, se ja enviado n�o permite altera��es.    
				MsgInfo("Titulo n�o pode ser retirado do bordero "+cNumBor+" pois j�Efoi enviado para o cliente. Favor entrar em contato com a T.I. (F2_P_ENV)","HLB BRASIL")
				lRet := .F.
			EndIF
	EndIf
EndIf	
Return lRet