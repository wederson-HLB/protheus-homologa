#Include "rwmake.ch"   

/*
Funcao      : GTFIN012
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento nosso n�mero e desconto para CNAB itau 400 de cobran�a
Autor     	: Anderson Arrais
Data     	: 30/11/2015
TDN         : 
M�dulo      : Financeiro
Cliente     : 
*/

*---------------------------*
 User Function GTFIN012(nOpc) 
*---------------------------* 

Local cRet	:= 0

//����������������������������������������������������Ŀ
//�Tratamento nosso n�mero		    				   �
//������������������������������������������������������ 
If nOpc == 1
	If Empty(SE1->E1_NUMBCO)
		RecLock("SE1",.F.)
		Replace SE1->E1_NUMBCO  With StrZero(VAL(SEE->EE_FAXATU)+1,8)
		SE1->(MsUnLock())
		RecLock("SEE",.F.)	
		Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,8)
		SEE->(MsUnlock())
		cRet := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
	Else
		cRet := SE1->E1_NUMBCO
	Endif    
EndIf

//����������������������������������������������������Ŀ
//�Agencia Conta Favorecido    				   �
//������������������������������������������������������
If nOpc == 2
	cRet := REPL("0",6)
	If! Empty(SE1->E1_DESCFIN)
		cRet :=GravaData(SE1->E1_VENCREA-SE1->E1_DIADESC)
	Endif
EndIf

//����������������������������������������������������Ŀ
//�Mora diaria 					    				   �
//������������������������������������������������������
If nOpc == 3
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	cRet:=((SE1->E1_SALDO - _nVlrAbat)*0.01)/30
EndIf


Return(cRet)