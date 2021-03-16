/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Empresa  � AKRON Projetos e Sistemas                                  ���
���          � Av Celso Garcia, 3977 - Tatuape - Sao Paulo/SP - Brasil    ���
���          � Fone: +55 11 3853-6470                                     ���
���          � Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
# Include "Protheus.ch"                         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �KPMEsDSai � Autor �Marcelo Celi Marques� Data �  01/02/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Alimenta Estoque nas notas de saida geradas pelos programas���
���          � de importa��o via XML, ja que o mata920 nao trata estoque. ���
�������������������������������������������������������������������������͹��
���Uso       � KPMG		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function KPMEsDSai()
Local _aAreaSD2 := SD2->(GetArea()) 
Local _aAreaSF4 := SF4->(GetArea())

SF4->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
Do While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)		  	
	If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
		KPMEsDSai(SD2->(D2_NUMLOTE),SD2->(D2_LOTECTL),SD2->(D2_DTVALID),SD2->(D2_POTENCI))		  	
	EndIf
	SD2->(dbSkip())
EndDo

SF4->(RestArea(_aAreaSF4))		  
SD2->(RestArea(_aAreaSD2))		  

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �KPMEsDSai � Autor �Marcelo Celi Marques� Data �  01/02/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Alimenta Estoque nas notas de saida geradas pelos programas���
���          � de importa��o via XML, ja que o mata920 nao trata estoque. ���
�������������������������������������������������������������������������͹��
���Uso       � KPMG		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function KPMEsDSai(cNumLote,cLoteCtl,dValidad,nPotenc)

Local cCalcImpV := GetMV("MV_GERIMPV")
Local aCusto	:= {}    
Local aCM		:= {}
Local aEnvCus	:= {}
Local nFretUnit := SD2->D2_TOTAL / SF2->F2_FRETE

If SF4->F4_ESTOQUE == "S"		
	If cCalcImpV == "S"
		aEnvCus:={SD2->D2_TOTAL+nFretUnit,{},0.00,;
					" "," ",SD2->D2_NFORI,SD2->D2_SERIORI,;
					SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_QUANT,0.00}				
	Else
		aEnvCus:={SD2->D2_TOTAL+nFretUnit,0+0/*nItemIpi+nFreteIpi*/,0+0 /*nItemIcm+nFreteIcm*/,;
					 SF4->F4_CREDIPI,SF4->F4_CREDICM,SD2->D2_NFORI,SD2->D2_SERIORI,;
					 SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_QUANT,If(SF4->F4_BASEIPI>0,0/*nItemIPI+nFreteIPI*/,0)}
	Endif
	
	IF SF4->F4_PODER3 == "D"
		aCM	 := PegaCMAtu(SD2->D2_COD,SD2->D2_LOCAL,"D", aEnvCus)
	Else
		aCM	 := PegaCMAtu(SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_TIPO, aEnvCus)
	EndIf

	//���������������������������������������������������Ŀ
	//� Grava o custo da nota fiscal de entrada           �
	//�����������������������������������������������������
	aCusto := GravaCusD2(aCM,IIF(SF4->F4_PODER3 == "D","D",SD2->D2_TIPO))

	//���������������������������������������������������Ŀ
	//� Atualiza lotes                                    �
	//�����������������������������������������������������
	If Rastro(SD2->D2_COD) .And. SF4->F4_ESTOQUE == "S" .And. !(SF2->F2_TIPO $ "CIP")
		RecLock("SD2",.F.)
		Replace SD2->D2_NUMLOTE With cNumLote
		Replace SD2->D2_LOTECTL With cLoteCtl
		Replace SD2->D2_DTVALID With dValidad
		Replace SD2->D2_POTENCI With nPotenc
	Endif                                              
	
	B2AtuComD2(aCusto)    

EndIf

Return





