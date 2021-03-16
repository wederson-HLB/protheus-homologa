#Include "rwmake.ch"   
#INCLUDE "PROTHEUS.CH"

/*
Funcao      : GTFIN036
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento para nosso número cnab cobrança JP Morgan.
Autor     	: Anderson Arrais
Data     	: 07/06/2018
Módulo      : Financeiro
*/

*-------------------------------------------------*
 User Function GTFIN036(cCodBan,cAgen,cConta,cSub)
*-------------------------------------------------* 

Local cRet		:= ""
Local BaseNN	:= "" 
Local cContSemD := ""

IF EMPTY(SE1->E1_NUMBCO)
	dbSelectArea("SEE")
	SEE->(DbSetOrder(1)) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	dbGoTop()
	If SEE->(DbSeek(xFilial("SEE")+PADR(cCodBan,TamSX3("EE_CODIGO")[1],'')+PADR(cAgen,TamSX3("EE_AGENCIA")[1],'')+;
 	  PADR(cConta,TamSX3("EE_CONTA")[1],'')+PADR(cSub,TamSX3("EE_SUBCTA")[1],'')))
		RecLock("SEE",.F.)
		cNroDoc			:= StrZero(VAL(SEE->EE_FAXATU)+1,8)
		SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU),8)
		MsUnLock()
	EndIf
	
	DbSelectArea("SE1")
	RecLock("SE1",.f.)
	SE1->E1_NUMBCO 	:= cNroDoc   // Nosso número (Ver fórmula para calculo)
	SE1->E1_PORTADO := cCodBan
	SE1->E1_AGEDEP  := cAgen
	SE1->E1_CONTA   := cConta
	MsUnlock()
Else
	cNroDoc 		:= ALLTRIM(SE1->E1_NUMBCO)
EndIf
cContSemD	:= SUBSTR(cConta,1,Len(AllTrim(cConta))-1)  //Conta sem digito
BaseNN		:= cAgen + cContSemD + SEE->EE_CODCART + Strzero(val(cNroDoc),8)

cRet    := Strzero(val(cNroDoc),8) + Alltrim(Str(modulo10(BaseNN)))

Return(cRet)

/*
Funcao      : Modulo10
Parametros  : cData
Retorno     : D
Objetivos   : Calculo modulo 10.
Autor     	: Anderson Arrais
Data     	: 07/06/2018
Módulo      : Financeiro
*/
      
*------------------------------*
STATIC FUNCTION Modulo10(cData)
*------------------------------*

LOCAL L,D,P := 0
LOCAL B     := .F.

L := Len(cData)
B := .T.
D := 0

WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9   
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF    

RETURN(D)