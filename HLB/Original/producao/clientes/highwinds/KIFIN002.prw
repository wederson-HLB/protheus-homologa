#Include "rwmake.ch"    
#INCLUDE "Protheus.Ch"

/*
Funcao      : KIFIN002
Parametros  : cCodBan,cAgen,cConta,cSub
Retorno     : cRet
Objetivos   : Retorna Nosso Número.
Autor       : Anderson Arrais
TDN         : 
OBS			: Nosso Número boleto HSBC/CNAB 400 cobrança
Revisão     : Anderson Arrais
Data/Hora   : 02/03/2016
Módulo      : Financeiro.
Empresa		: HIGNWINDS
*/

*-------------------------------------------------*
 User Function KIFIN002(cCodBan,cAgen,cConta,cSub)
*-------------------------------------------------*    
LOCAL cRet		:= ""
LOCAL nRange   	:= "22212"

IF EMPTY(SE1->E1_NUMBCO)
	SEE->(DbSetOrder(1))

	If  SEE->(DbSeek(xFilial("SEE")+PADR(cCodBan,TamSX3("EE_CODIGO")[1],'')+PADR(cAgen,TamSX3("EE_AGENCIA")[1],'')+;
		PADR(cConta,TamSX3("EE_CONTA")[1],'')+PADR(cSub,TamSX3("EE_SUBCTA")[1],'')))
		
		SEE->(Reclock('SEE',.F.))
		cRet			:= SUBSTR(AllTrim(SEE->EE_FAXATU),8,5)
		SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU),8)      
		SEE->(Msunlock())
	EndIf
	
	DbSelectArea("SE1")
	RecLock("SE1",.f.)

	snn   := nRange+cRet             // Nosso Numero
	dvnn  := Alltrim(Str(mod117(snn)))  // Digito verificador no Nosso Numero  
	cNN   := snn + dvnn

	SE1->E1_NUMBCO 	:= cNN	//cRet   // Nosso número (Ver fórmula para calculo)
	SE1->E1_PORTADO := SA6->A6_COD
	SE1->E1_AGEDEP  := SA6->A6_AGENCIA
	SE1->E1_CONTA   := SA6->A6_NUMCON
	MsUnlock()
	
	cRet 	:= cNN
Else
	cRet 	:= ALLTRIM(SE1->E1_NUMBCO)
EndIf

//Retorno Nosso Numero
Return(cRet)

//Funcao MODULO11() 
STATIC FUNCTION Mod117(cData)
LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 7
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 )
	D := 0	             
ELSE
	D := 11 - (mod(D,11))	
ENDIF 

RETURN(D) 
