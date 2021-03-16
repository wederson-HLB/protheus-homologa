#Include "rwmake.ch"    

/*
Funcao      : GTFIN028
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Trata digito verificador nosso numero sofisa e valor 
Autor       : 
TDN         : 
OBS			: Feito para sofisa layout sntander
Revisão     : Anderson Arrais
Data/Hora   : 30/11/2016
Módulo      : Financeiro.
*/                      

*--------------------------------*
 User Function GTFIN028(nOpc,nPar)   
*--------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cFaxatu	 := ""
Local _nVlrAbat  := 0
Local _nValor    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faixa atual nosso numero					   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	cAgencia  := "3689"
	cConta    := "4845013"
	cFaxatu	:= POSICIONE("SEE",1,xFilial("SEE")+"033"+cAgencia+" "+cConta+Space(TamSX3("EE_CONTA")[1]-Len(cConta))+"001","EE_FAXATU")
 	If Empty(SE1->E1_NUMBCO)
	 	cNroDoc			:= VAL(SEE->EE_FAXATU)+1
 		RecLock("SE1",.F.)
        Replace SE1->E1_NUMBCO  With SUBSTR(cValToChar(cNroDoc),3,10)
        SE1->(MsUnLock())
        RecLock("SEE",.F.)	
        Replace	SEE->EE_FAXATU  With StrZero(Val(cFaxatu)+1,8)
        SEE->(MsUnlock())
        nDvnn := modulo11(cvaltochar(cNroDoc),.F.)
        cRet := cvaltochar(cNroDoc)+AllTrim(Str(nDvnn))
	Else
		cNroDoc:= "10"+ALLTRIM(SE1->E1_NUMBCO)
		nDvnn  := modulo11(cvaltochar(cNroDoc),.F.)
        cRet   := "10"+ALLTRIM(SE1->E1_NUMBCO)+AllTrim(Str(nDvnn))
    Endif            
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor nominal	 						   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := SE1->E1_SALDO - _nVlrAbat
    cRet      := STRZERO((_nValor*100),13,0) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor nominal - Desconto + Acrescimo		   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := (SE1->E1_SALDO - _nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
    cRet      := STRZERO((_nValor*100),13,0) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Código da empresa						   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4
	If cEmpAnt $ "Z4"
		cRet := "0000133648CVE033"	 
	ElseIf cEmpAnt $ "ZB"
		cRet := "0000142224CVE033"	
	ElseIf cEmpAnt $ "ZF"			// GFP - 31/03/2017 - Chamado 040073
		cRet := "0000147586CVE033"	
	ElseIf cEmpAnt $ "ZG"			// GFP - 31/03/2017 - Chamado 040073
		cRet := "0000147784CVE033"	
	ElseIf cEmpAnt $ "ZP"			// GFP - 31/03/2017 - Chamado 040073
		cRet := "0000148228CVE033"	
	EndIf	
Endif

RestArea(aArea)
Return(cRet)

*----------------------------------------*
STATIC FUNCTION Modulo11(cData) 
*----------------------------------------*
LOCAL L, D, P 		:= 0

L := LEN(cData)
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

IF (D == 0 .Or. D == 1 .Or. D == 10)
	//Se o resto for 0 ou 1 o digito é 0
	IF (D == 0 .Or. D == 1)
		D := 0

	//Se o resto for 10 o digito é 1
	ELSEIF (D == 10)
		D := 1
	ENDIF
ELSE
	D := 11 - (mod(D,11))	
ENDIF 

RETURN(D)