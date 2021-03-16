#include "protheus.ch"

/*
Funcao      : DTGPE001
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
User Function DTGPE002(nOpc)
*---------------------*
Local xRet:=""

If nOpc == 1
	If cEmpAnt $ "DT" ////Verifica qual o banco e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "072"	

		ElseIf (NVALOR/100)<5000
			xRet:= "071"
		Else
			xRet:= "083"
		EndIf
	EndIf
EndIf

If nOpc == 2
	If cEmpAnt $ "DT" ////Verifica qual o tipo e valor para informar se é um DOC, TED, ou transferencia
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "01"	

		ElseIf (NVALOR/100)<5000
			xRet:= "71"
		Else
			xRet:= "83"
		EndIf
	EndIf
EndIf

If nOpc == 3
	If cEmpAnt $ "DT" ////Verifica qual o banco 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "000"
		Else
			xRet:= SUBSTR(SRA->RA_BCDEPSA,1,3)
		EndIf
	EndIf
EndIf

If nOpc == 4
	If cEmpAnt $ "DT" ////Verifica qual a conta 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "0000"
		Else
			xRet:= SUBSTR(SRA->RA_BCDEPSA,4,4)
		EndIf
	EndIf
EndIf

If nOpc == 5
	If cEmpAnt $ "DT" ////Verifica qual a conta OUTRO BANCO
		If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
			xRet:= "000000000000000"
		Else
			xRet:= PADL(ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-")),10,"0")          
		EndIf
	EndIf
EndIF     


If nOpc == 6
	If cEmpAnt $ "DT" ////Verifica qual a conta MESMO BANCO
		If SUBSTR(SRA->RA_BCDEPSA,1,3)<>'745'
			xRet:= "000000000000000"
		Else
			xRet:= PADL(ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-")),10,"0")          
		EndIf
	EndIf
EndIF  


Return(xRet)



