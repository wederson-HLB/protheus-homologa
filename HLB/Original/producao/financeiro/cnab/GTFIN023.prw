#Include "rwmake.ch"    

/*
Funcao      : GTFIN023
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Trata banco e agencia cnab de cobranca Itau.
Autor       : 
TDN         : 
OBS			: Layout Itau de 400 posi��es contas a receber	
Revis�o     : Anderson Arrais
Data/Hora   : 26/10/2016
M�dulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN023(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cContaMV   := ""
Local cFaxatu	 := ""
Local _nVlrAbat  := 0
Local _nValor    := 0

//����������������������������������������������������Ŀ
//�Banco					   						   �
//������������������������������������������������������
If nOpc == 1
    cRet := Val(&(SuperGetMv("MV_P_00089"))[1])
Endif

//����������������������������������������������������Ŀ
//�Agencia											   �
//������������������������������������������������������
If nOpc == 2
    cRet := Val(&(SuperGetMv("MV_P_00089"))[2]) 
Endif

//����������������������������������������������������Ŀ
//�Conta		   							   		   �
//������������������������������������������������������
If nOpc == 3
	cRet 	:= val(&(SuperGetMv("MV_P_00089"))[3])
Endif 

//����������������������������������������������������Ŀ
//�DAC da Conta		 						   		   �
//������������������������������������������������������
If nOpc == 4
	cRet 	:= val(&(SuperGetMv("MV_P_00089"))[4])
Endif

//����������������������������������������������������Ŀ
//�Faixa atual nosso numero					   		   �
//������������������������������������������������������
If nOpc == 5
	cContaMV := ALLTRIM(&(SuperGetMv("MV_P_00089"))[3])+ALLTRIM(&(SuperGetMv("MV_P_00089"))[4])
	cFaxatu	:= POSICIONE("SEE",1,xFilial("SEE")+&(SuperGetMv("MV_P_00089"))[1]+&(SuperGetMv("MV_P_00089"))[2]+" "+cContaMV+Space(TamSX3("EE_CONTA")[1]-Len(cContaMV))+"001","EE_FAXATU")
 	If Empty(SE1->E1_NUMBCO)
 		RecLock("SE1",.F.)
        Replace SE1->E1_NUMBCO  With StrZero(VAL(cFaxatu)+1,8)
        SE1->(MsUnLock())
        RecLock("SEE",.F.)	
        Replace	SEE->EE_FAXATU  With StrZero(Val(cFaxatu)+1,8)
        SEE->(MsUnlock())
        cRet := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
	Else
        cRet := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
    Endif            
Endif

//����������������������������������������������������Ŀ
//�Valor nominal	 						   		   �
//������������������������������������������������������
If nOpc == 6
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := SE1->E1_SALDO - _nVlrAbat
    cRet      := STRZERO((_nValor*100),13,0) 
Endif

//����������������������������������������������������Ŀ
//�Juros			 				 				   �
//������������������������������������������������������
If nOpc == 7
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    nValor  := (SE1->E1_SALDO - nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
    nLiq	:= (nValor*0.01)/30 //Valor de juros diario para 1% m�s
    cRet    := STRZERO((nLiq*100),13,0) 
EndIf

//����������������������������������������������������Ŀ
//�Juros 2%  		 				 				   �
//������������������������������������������������������
If nOpc == 8
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    nValor  := (SE1->E1_SALDO - nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
    nLiq	:= (nValor*0.02)/30 //Valor de juros diario para 2% m�s
    cRet    := STRZERO((nLiq*100),13,0) 
EndIf

RestArea(aArea)
Return(cRet)