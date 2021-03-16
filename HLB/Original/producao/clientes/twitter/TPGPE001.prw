#include "protheus.ch"

/*
Funcao      : TPGPE001
Parametros  :
Retorno     : xRet
Objetivos   : Parametros para CNAB 1024 citibank Twitter
TDN			:
Autor       : Anderson Arrais
Data/Hora   : 05/10/2015
Revisão		:
Data/Hora   :
Módulo      : Gestão de Pessoal
Cliente		: Twitter
*/

*--------------------------*
User Function TPGPE001(nOpc)
*--------------------------*
Local xRet:=""
Local nCont:=""

//Tipo de pagamento 
If nOpc == 1
	If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
		xRet:= "072"	
	ElseIf (NVALOR/100)<500
		xRet:= "071"
	Else
		xRet:= "083"
	EndIf
EndIf

//Verifica qual o banco 
If nOpc == 2
	If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
		xRet:= "000"
	Else
		xRet:= SUBSTR(SRA->RA_BCDEPSA,1,3)
	EndIf
EndIf

//Verifica qual a agencia outro banco
If nOpc == 3
	If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
		xRet:= "00000000"
	Else
		xRet:= SUBSTR(SRA->RA_BCDEPSA,4,4)
	EndIf
EndIf

//Verifica qual a conta outro banco
If nOpc == 4
	If SUBSTR(SRA->RA_BCDEPSA,1,3)='745'
		xRet:= REPLICATE('0',35)
	Else
		nCont := ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-",""))
		nCont := ALLTRIM(STRTRAN(nCont,"X","0"))
		xRet  := STRZERO(VAL(nCont),15,0)
	EndIf
EndIF     

//Verifica qual a conta mesmo banco
If nOpc == 5
	If SUBSTR(SRA->RA_BCDEPSA,1,3)<>'745'
		xRet:= REPLICATE('0',10)
	Else
		nCont := ALLTRIM(STRTRAN(SRA->RA_CTDEPSA,"-",""))
		nCont := ALLTRIM(STRTRAN(nCont,"/",""))
		xRet  := STRZERO(VAL(nCont),10,0)
	EndIf
EndIF  

Return(xRet)



