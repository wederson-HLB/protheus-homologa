#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

/*
Funcao      : P_NNZF033 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco Santander
Autor       : Flavio Novaes
Data        : 03/02/2005
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 07/05/2013
Módulo      : Financeiro
Cliente     : 
*/

*-----------------------*
User Function P_NNZF033
*-----------------------*

IF EMPTY(SE1->E1_NUMBCO)
	
	nTam := TamSx3("EE_FAXATU")[1]
	nTamE1 := TamSx3("E1_NUMBCO")[1]
	
	// Enquanto nao conseguir criar o semaforo, indica que outro usuario
	// esta tentando gerar o nosso numero.
	cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)
	
	While !MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
		cNumero := Soma1(cNumero)										// busca o proximo numero disponivel
	EndDo
	
	cNroDoc 	:= SUBSTR(cNumero,4,10)
	cNroDoc 	:= cNroDoc + AllTrim(Str(MODULO11(cNroDoc)))
	
	
	RecLock("SE1",.F.)
	Replace SE1->E1_NUMBCO With cNroDoc
	SE1->( MsUnlock( ) )
	
	RecLock("SEE",.F.)
	Replace SEE->EE_FAXATU With Soma1(cNumero, nTam)
	SEE->( MsUnlock() )
	
	
	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
	DbSelectArea("SE1")

Else
	cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
EndIf

cNroDoc:=SUBSTR(cNroDoc,len(cNroDoc)-7,8)

If Len(cNroDoc) < 8
	cNroDoc := StrZero(Val(cNroDoc),8)
EndIf


return(cNroDoc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

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
	IF P = 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 .Or. D == 10)
	IF (D == 0 .Or. D == 1)
		D := 0
	ELSEIF (D == 10)
		D := 1
	ENDIF
ELSE
	D := 11 - (mod(D,11))
ENDIF

RETURN(D)
