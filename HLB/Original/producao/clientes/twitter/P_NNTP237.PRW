#Include "Protheus.ch"

/*
Funcao      : P_NN237
Parametros  :
Retorno     :
Objetivos   : Retorna o número do documento
Autor       : Joao Silva
Data/Hora   : 03/02/2015
TDN         :
Módulo      : Financeiro.
*/

*----------------------*
User function P_NNTP237
*----------------------*

Local cCart		:= "09"
Local cNroDoc	:= ""
Local cBanco    := "487"
Local cAgencia  := "23728"
Local cConta    := "76090     "    	
Local cSubConta := "001"       

If Empty(SE1->E1_NUMBCO)
	//Posiciona o SEE(Parametros banco)
	DbSelectArea("SEE")
	SEE->(DbSetOrder(1))//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SEE->(DbGoTop())
	
	If DbSeek (xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta)
		RecLock("SEE",.F.)
		cNroDoc			:= SUBSTR(AllTrim (SEE->EE_FAXATU),(LEN(AllTrim(SEE->EE_FAXATU))-7),8)
		SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
		MsUnLock()
	EndIf
	
	cDig := Alltrim(modulo11(AllTrim(cCart) + Strzero(val(AllTrim(cNroDoc)),11))) //digito verificador      
	
	DbSelectArea("SE1")
	RecLock("SE1",.f.)
	SE1->E1_NUMBCO 	:= STRZERO(Val(cNroDoc),11,0)+cDig  
	SE1->E1_PORTADO := SA6->A6_COD
	SE1->E1_AGEDEP  := SA6->A6_AGENCIA
	SE1->E1_CONTA   := SA6->A6_NUMCON    
	cNroDoc			:= SE1->E1_NUMBCO
	MsUnlock()
	
Else
	cNroDoc 	:= SE1->E1_NUMBCO
	
EndIf 

Return(cNroDoc)
*-------------------------------*
STATIC FUNCTION Modulo11(cData)
*-------------------------------*
Local L, D, P := 0

L := LEN(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	If P == 7
		P := 1
	EndIf
	L := L - 1
EndDo

D := (mod(D,11))

If ( D == 0 )//(D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	 D := '0'  //1                                              
ElseIf ( D == 1 )
 	 D := 'P'       
Else
	 D := STR(11 - (mod(D,11)))	
EndIf 

Return(D)
