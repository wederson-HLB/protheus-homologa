#include "protheus.ch"

/*
Funcao      : 49GPE001
Parametros  :
Retorno     : lRet
Objetivos   : Filtrar as informações para o CNAB de folha.
TDN			:
Autor       : João Silva
Data/Hora   :
Revisão		: Anderson Arrais
Data/Hora   : 20/10/2015
Módulo      : Gestão de Pessoal
Cliente		: DISCOVERY
*/

*---------------------*
User Function 49GPE001(nOpc)
*---------------------*
Local xRet:=""

If nOpc == 1
	If cEmpAnt $ "49" ////Verifica qual o banco e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(cBANCO,1,3)='745'
			xRet:= "072"	
		
		//AOA 03/02/2016 - Alterado tratamento para todos diferentes de 745 gerar TED independente de valor.
		//ElseIf (NVALOR/100)<5000
			//xRet:= "071"
		Else
			xRet:= "083"
		EndIf
	EndIf
EndIf

If nOpc == 2
	If cEmpAnt $ "49" ////Verifica qual o tipo e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(cBANCO,1,3)='745'
			xRet:= "01"	
		
		//AOA 03/02/2016 - Alterado tratamento para todos diferentes de 745 gerar TED independente de valor.
		//ElseIf (NVALOR/100)<5000
			//xRet:= "71"
		Else
			xRet:= "83"
		EndIf
	EndIf
EndIf

If nOpc == 3
	If cEmpAnt $ "49" ////Verifica qual o banco 
		If SUBSTR(cBANCO,1,3)='745'
			xRet:= "000"
		Else
			xRet:= SUBSTR(cBANCO,1,3)
		EndIf
	EndIf
EndIf

If nOpc == 4
	If cEmpAnt $ "49" ////Verifica qual a conta 
		If SUBSTR(cBANCO,1,3)='745'
			xRet:= "0000"
		Else
			xRet:= SUBSTR(cBANCO,4,4)
		EndIf
	EndIf
EndIf

If nOpc == 5
	If cEmpAnt $ "49" ////Verifica qual a conta OUTRO BANCO
		If SUBSTR(cBANCO,1,3)='745'
			xRet:= "000000000000000"
		Else
			xRet:= STRZERO(VAL(ALLTRIM(STRTRAN(cCONTA,"-"))),15)          
		EndIf
	EndIf
EndIF     

If nOpc == 6
	If cEmpAnt $ "49" ////Verifica qual a conta MESMO BANCO
		If SUBSTR(cBANCO,1,3)<>'745'
			xRet:= "000000000000000"
		Else
			xRet:= PADL(ALLTRIM(STRTRAN(cCONTA,"-")),10,"0")          
		EndIf
	EndIf
EndIF  

Return(xRet)