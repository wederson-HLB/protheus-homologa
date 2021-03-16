#Include "rwmake.ch"    

/*
Funcao      : GTFIN005
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento de conta corrente e digito para cnab Bradesco 500
Autor       : 
TDN         : 
Revisão     : Anderson Arrais
Data/Hora   : 24/08/2015
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN005(nOpc)   
*------------------------------*   
Local cRet := ""
Local cTam := "" 
Local cAgen:= ""
Local cDig := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna apenas a conta sem o digito 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
	cTam := LEN(STRTRAN(ALLTRIM(SRA->RA_CTDEPSA),"-",""))-1
	cRet := STRZERO(VAL(SUBSTR(STRTRAN(ALLTRIM(SRA->RA_CTDEPSA),"-",""),1,cTam)),13)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna apenas o digito da conta	  				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 
	cRet := SUBSTR(STRTRAN(ALLTRIM(SRA->RA_CTDEPSA),"-",""),-1,1)+SPACE(1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna dados da agencia     	  				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	If SUBSTR(SRA->RA_BCDEPSA,1,3) == "237"
		cDig  := SUBSTR(SRA->RA_BCDEPSA,8,1)
		//AOA - 02/08/2016 - Acrecentado calculo do modulo 11 pra digito da agencia
		cAgen := SUBSTR(SRA->RA_BCDEPSA,4,4)
		If Empty(cDig)
			cDig := Modulo11(cAgen)
		Else
			cDig := SUBSTR(SRA->RA_BCDEPSA,8,1)
		EndIf
	Else
		cDig := "0"
	EndIf
	cRet := "0"+SUBSTR(SRA->RA_BCDEPSA,4,4)+cValToChar(cDig)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trata codigo para conta salario quando bradesco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//RPB - 03/10/2016 - Informar nº 0298 para conta salario e nº 00000 para conta corrente
If nOpc == 4
	If SUBSTR(SRA->RA_BCDEPSA,1,3) == "237"
		cRet  := "00298"
	Else
		cRet  := "00000"
	EndIf
		
EndIf	

Return(cRet)

/*
Funcao      : Modulo11
Parametros  : cData
Retorno     : D
Objetivos   : Calculo modulo 11.
Autor     	: Anderson Arrais
Data     	: 04/05/2016
Módulo      : Financeiro
*/
      
*------------------------------*
STATIC FUNCTION Modulo11(cData) 
*------------------------------*

LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 0
ELSE
	D := 11 - (mod(D,11))	
ENDIF 

RETURN(D)