#Include "Protheus.ch"  

/*
Funcao      : P_NN237
Parametros  : 
Retorno     : 
Objetivos   : Retorna o n�mero do documento
Autor       : Matheus Massarotto
Data/Hora   : 27/07/2011
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/ 

*----------------------*
 User function P_NN237   
*----------------------*

Local cCart:="09"
Local cNroDoc:=""
Local cCartNN:=""
Local nSoma:=0
Local nB7:=2

	IF EMPTY(SE1->E1_NUMBCO)
		cNroDoc 	:= SUBSTR(NOSSONUM(),2,11)
		cCartNN:=alltrim(cCart)+alltrim(cNroDoc)
		
		for i:=len(cCartNN) to 1 STEP -1
			
			if nB7==8
				nB7:=2
			endif
			nSoma+= (val(substr(cCartNN,i,1)) * nB7)
		    nB7++
		next

		_RESTO  := INT(nSoma % 11)

		_DIGITO := 11 - _RESTO
		
		if _DIGITO==11 
			_RETDIG :="0"
		elseif _DIGITO==10 
			_RETDIG :="P"
		else
			_RETDIG :=alltrim(STR(_DIGITO))
		endif
		
		cNroDoc+=_RETDIG
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
			SE1->E1_NUMBCO 	:=	cNroDoc   // Nosso n�mero (Ver f�rmula para calculo)
		MsUnlock()
        

	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf                   
             


Return (cNroDoc)