#include "protheus.ch"

/*
Funcao      : PBGPE001
Parametros  :
Retorno     : lRet
Objetivos   :
TDN			:
Autor       :
Data/Hora   :
Revisão		:
Data/Hora   :
Módulo      : Gestão de Pessoal
Cliente		:
*/

*---------------------*
User Function PBGPE001(nOpc)
*---------------------*
Local xRet:=""

If nOpc == 1
	If cEmpAnt $ "PB/7W" ////Verifica qual o banco e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "072"	
		//AOA - 21/01/2016 - Não trata mais valores para DOC, vai ser pago tudo via TED - chamado 031698
		//ElseIf (NVALOR/100)<1000
		//	xRet:= "071"
		Else
			xRet:= "083"
		EndIf
	EndIf
EndIf

If nOpc == 2
	If cEmpAnt $ "PB/7W" ////Verifica qual o tipo e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "01"	
		//AOA - 21/01/2016 - Não trata mais valores para DOC, vai ser pago tudo via TED - chamado 031698
		//ElseIf (NVALOR/100)<1000
		//	xRet:= "71"
		Else
			xRet:= "83"
		EndIf
	EndIf
EndIf

If nOpc == 3
	If cEmpAnt $ "PB/7W" ////Verifica qual o banco 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "000"
		Else
			xRet:= SUBSTR(SRA->RA_BCDEPSA,1,3)
		EndIf
	EndIf
EndIf

If nOpc == 4
	If cEmpAnt $ "PB/7W" ////Verifica qual a conta 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "0000"
		Else
			xRet:= SUBSTR(SRA->RA_BCDEPSA,4,4)
		EndIf
	EndIf
EndIf

If nOpc == 5
	If cEmpAnt $ "PB/7W" ////Verifica qual a conta 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "000000000000000"
		Else
			xRet:= PADL(ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-")),15,"0")          
		EndIf
	EndIf
EndIF

If nOpc == 6
	If cEmpAnt $ "PB/7W" ////Verifica qual a conta 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)<>'745'
			xRet:= "000000000000000"
		Else
			xRet:= PADL(ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-")),10,"0")          
		EndIf
	EndIf
EndIF     

If nOpc == 7 //AOA - 21/01/2016 - Não trata mais valores para DOC, vai ser pago tudo via TED - chamado 031698
	If cEmpAnt $ "PB/7W" ////Verifica qual o banco e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= GRAVADATA(DDATAPGTO,.F.,4)
		//AOA - 21/01/2016 - Não trata mais valores para DOC, vai ser pago tudo via TED - chamado 031698
		//ElseIf (NVALOR/100)<1000
		//	xRet:= GRAVADATA((DDATAPGTO - 1),.F.,4)
		Else
			xRet:= GRAVADATA(DDATAPGTO,.F.,4)
		EndIf
	EndIf
EndIf    
Return(xRet)



