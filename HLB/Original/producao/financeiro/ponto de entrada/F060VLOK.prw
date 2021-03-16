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
*------------------------*
User Function F060VLOK() 
*------------------------*

Local cPortado 	:= paramixb[2]
Local cAgencia	:= paramixb[3]
Local cConta 	:= paramixb[4]  
Local lRet		:= .T.

Local cDefbank 	:= ""//Banco padr�o.
Local cDefAgen	:= ""//Agencia padr�o.
Local cDefCont 	:= ""//Conta padr�o.

If cEmpAnt = "TP"//Verifica se �Ea empresa Twitter.   
	cDefbank 	:= SUPERGETMV("MV_P_00067",.F. )
	cDefAgen	:= SUPERGETMV("MV_P_00066",.F. ) 
	cDefCont 	:= SUPERGETMV("MV_P_00065",.F. ) 

	If	cConta	<> cDefCont .Or. cAgencia <> cDefAgen .Or. cPortado <> cDefbank	
		MsgInfo("Para gera��o dos border�s da empresa Twitter �Enecessario utilizar o Banco: "+cDefbank+" Agencia: "+cDefAgen+" Conta: "+cDefCont+" (MV_P_00065, MV_P_00066, MV_P_00067)","HLB BRASIL")
		lRet:=.F.
	EndIf
EndIf

Return (lRet)