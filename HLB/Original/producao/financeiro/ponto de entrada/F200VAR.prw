#Include "rwmake.ch"  
#include 'protheus.ch' 

/*
Funcao      : F200VAR
Retorno     : Nenhum   
Objetivos   : CNAB a receber sera executado apos carregar os dados do arquivo de recepcao bancaria e sera utilizado para alterar os dados recebidos.
TDN        	: http://tdn.totvs.com/display/public/mp/F200VAR+-+CNAB+a+receber+--+11718
Autor     	: Anderson Arrais
Data     	: 06/10/2017  
Obs         : 
Módulo      : Financeiro
*/

*--------------------*
User Function F200VAR
*--------------------*     
Local aRecno      := SE1->(GetArea())

If cEmpAnt $ "R7"
	nValRec := nValRec + nJuros
EndIf   

//AOA - 20/05/2019 - grava o nosso numero retornado pelo banco para gerar boleto dentro do protheus (QN0001/2019)  
If cEmpAnt $ "QN"
	dbSelectArea("SE1")
	SE1->(dbSetOrder(16))
	If SE1->( DbSeek( xFilial("SE1") + cNumTit ) )	
		If EMPTY(SE1->E1_NUMBCO)
			Reclock("SE1")
				SE1->E1_NUMBCO := cvaltochar(Strzero(val(cNsNum),10))
			MsUnlock()
			U_QNGEN001(SE1->E1_NUMBCO,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,SE1->E1_NUMBOR,SE1->E1_P_CONV,"F200VAR: grava nosso numero do arquivo ret")
		EndIf
	EndIf
	SE1->(DbCloseArea())
EndIf 
RestArea(aRecno)

Return