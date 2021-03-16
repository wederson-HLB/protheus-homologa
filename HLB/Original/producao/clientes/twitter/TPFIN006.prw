#Include"Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  TPFIN006 () �Autor  �Jo�o Silva         � Data �  17/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada que valida o cancelamento/retirada de um   ���
���          � determinado t��ulo de um border�E              			  ���
�������������������������������������������������������������������������͹��
���Uso       �  AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function TPFIN006()

Local cNumBor	:= ''
Local lRet	:= .T.

If cEmpAnt = "TP"//Verifica se �Ea empresa Twitter.
	cNumBor := MV_PAR01//Pega po numero do Border�E  
	SE1->(DbSetOrder(5))//E1_FILIAL+E1_NUMBOR+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSeek(xFilial("SE1")+cNumBor))
	While SE1->E1_NUMBOR == cNumBor
		SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA))
			If SF2->F2_P_ENV = 'S'//Verifica se o titulo ja foi enviado ao cliente, se ja enviado n�o permite altera��es.    
				MsgInfo("O Bordero "+cNumBor+" n�o pode ser cancelado pois j�Eforam enviados boletos para os clientes. Favor entrar em contato com a T.I. (F2_P_ENV)","HLB BRASIL")
				lRet := .F.
				Return lRet
			EndIf
	DbSkip()
	EndDo	
EndIf	
Return lRet