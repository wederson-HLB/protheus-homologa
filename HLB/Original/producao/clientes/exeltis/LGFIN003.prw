#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

/*
Funcao      : LGFIN003
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento CNAB contas a receber banco Bradesco + código de barras
Autor       : Anderson Arrais
Data	    : 22/12/2016
Módulo      : Financeiro     
Alterado por: Leandro Brito ( Adaptado para Exeltis ) em 06/03/2018
Empresa		: Exeltis
*/
    
*------------------------------*
 User Function LGFIN003(nOpc)   
*------------------------------*
Local cRet := ""
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nosso numero						 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
	cBanco    := ALLTRIM(SE1->E1_PORTADO)
	cAgencia  := ALLTRIM(SE1->E1_AGEDEP)
	cConta    := ALLTRIM(SE1->E1_CONTA)
	cCartei   := "09"
	cFaxatu	:= POSICIONE("SEE",1,xFilial("SEE")+cBanco+cAgencia+Space(TamSX3("EE_AGENCIA")[1]-Len(cAgencia))+cConta+Space(TamSX3("EE_CONTA")[1]-Len(cConta))+"001","EE_FAXATU")
 	If Empty(SE1->E1_NUMBCO)
	 	cNroDoc:= StrZero(VAL(SEE->EE_FAXATU)+1,11)
 		RecLock("SE1",.F.)
        Replace SE1->E1_NUMBCO  With SUBSTR(cValToChar(cNroDoc),1,11)
        SE1->(MsUnLock())
        RecLock("SEE",.F.)	
        Replace	SEE->EE_FAXATU  With StrZero(Val(cFaxatu)+1,11)
        SEE->(MsUnlock())
        nDvnn  := Modulo117(cCartei+cvaltochar(cNroDoc),.F.)
        cRet   := cvaltochar(cNroDoc)+AllTrim(cvaltochar(nDvnn))
	Else
        cNroDoc:= ALLTRIM(SE1->E1_NUMBCO)
        nDvnn  := Modulo117(cCartei+cvaltochar(cNroDoc),.F.)
        cRet   := cvaltochar(cNroDoc)+AllTrim(cvaltochar(nDvnn))
    Endif 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Código de barras 				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 
	cBanco    := ALLTRIM(SE1->E1_PORTADO)
	cAgencia  := ALLTRIM(SE1->E1_AGEDEP)
	cConta    := ALLTRIM(SE1->E1_CONTA)
	cCartei   := "09"
	cNroDoc   := ALLTRIM(SE1->E1_NUMBCO)
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo    := (SE1->E1_SALDO - _nVlrAbat/*-SE1->E1_DECRESC*/+SE1->E1_ACRESC)   
	//Código de barras
	cRetCod	  := Ret_cBarra(cBanco,cAgencia,SUBSTR(cConta,1,Len(AllTrim(cConta))-1),SUBSTR(cConta,Len(AllTrim(cConta)),1),cNroDoc,nSaldo,SE1->E1_VENCREA,cCartei)
 	RecLock("SE1",.F.)
    Replace SE1->E1_CODBAR  With cValToChar(cRetCod[1])
    Replace SE1->E1_CODDIG  With cValToChar(cRetCod[2])
    SE1->(MsUnLock())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor nominal	 						   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := (SE1->E1_SALDO - _nVlrAbat/*-SE1->E1_DECRESC*/+SE1->E1_ACRESC)  
    cRet      := STRZERO((_nValor*100),13,0) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Multa			 				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    nValor  := (SE1->E1_SALDO - nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
    nLiq	:= (nValor*0.05)//Multa de 5%
    cRet    := STRZERO((nLiq*100),12,0) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Juros			 				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    nValor  := (SE1->E1_SALDO - nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
    nLiq	:= (nValor*0.01)/30 //Valor de juros diario para 1% mês
    cRet    := STRZERO((nLiq*100),13,0) 
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dt Limite Desconto			 				 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 6
    cRet    := If( SE1->E1_DECRESC > 0 , GRAVADATA(SE1->E1_VENCREA,.F.,1) , '000000' )                           
EndIf

Return (cRet)

/*
Funcao      : Modulo10
Objetivos   : Calculo do modulo 10
Autor	    : Anderson Arrais
Data		: 12/12/2016
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

/*
Funcao      : Modulo11
Objetivos   : Calculo do modulo 11 base 7
Autor	    : Anderson Arrais
Data		: 12/12/2016
*/
*------------------------------*
STATIC FUNCTION Modulo117(cData) 
*------------------------------*
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

IF (D == 1)
	D := "P"
ELSEIF D == 0
    D := 0
ELSE
	D := 11 - (mod(D,11))
ENDIF

RETURN(D)

/*
Funcao      : Modulo11
Objetivos   : Calculo do modulo 11 base 9
Autor	    : Anderson Arrais
Data		: 12/12/2016
*/
*------------------------------*
STATIC FUNCTION Modulo119(cData) 
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
	D := 1
ELSE
	D := 11 - (mod(D,11))
ENDIF

RETURN(D)

/*
Funcao      : Ret_cBarra
Objetivos   : Gera o código de barras do boleto
Autor	    : Anderson Arrais
Data		: 12/12/2016
*/
*------------------------------------------------------------------------------------------------*
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira) 
*------------------------------------------------------------------------------------------------*

Local cCarteira    := alltrim(cCarteira)
LOCAL blvalorfinal := Strzero((nValor)*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator       := Strzero(SE1->E1_VENCREA - ctod("07/10/1997"),4)

//Montagem Código barras 44
cCod  := cBanco + cMoeda + cFator + blvalorfinal + SUBSTR(cAgencia,1,4) + cCarteira + cvaltochar(cNroDoc) + STRZERO(VAL(cConta),7) + "0"
dvCod := Alltrim(Str(Modulo119(cCod)))
cCodf := cBanco + cMoeda + dvCod +cFator + blvalorfinal + SUBSTR(cAgencia,1,4) + cCarteira + cvaltochar(cNroDoc) + STRZERO(VAL(cConta),7) + "0" //Código 44 digitos

//MONTAGEM DA LINHA DIGITAVEL
//campo 1
campo1  := cBanco + cMoeda + substr(cCodf,20,5)
dvC1    := Alltrim(Str(modulo10(campo1)))
cCampo1 := campo1 + dvC1

//campo 2
campo2  := substr(cCodf,25,10)
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2

//campo 3
campo3  := substr(cCodf,35,10)
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 

//Campo 4
cCampo4  := dvCod

//campo 5
cCampo5  := cFator + blvalorfinal

//Montagem linha digitavel
cCB      := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5 

Return({cCodf,cCB})