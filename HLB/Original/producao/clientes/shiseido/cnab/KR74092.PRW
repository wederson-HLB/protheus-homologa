
/*
Funcao      : KR74092
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab  Pagar Shiseido - Unibanco  
Autor     	: José Ferreira de Sousa Neto                           
Data     	: 27/01/2006                     
Obs         : Rotina para buscao o Check Horizontal conforme layout Unibanco 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Financeiro. 
Cliente     : Shiseido
*/

*------------------------*
 User Function KR74092()
*------------------------*

_nCheq   := 0
_nCheq1  := 0
_nTama	:= 0
cBanco	:= ALLTRIM(SA2->A2_BANCO)
cAgencia := STRZERO(VAL(ALLTRIM(SA2->A2_AGENCIA)),4)
cConta	:= 0
_nValor  := SE2->E2_VALOR*100

if ALLTRIM(SA2->A2_BANCO)$"745"
cConta	:=  (ALLTRIM(SA2->A2_NUMCON))
else
cConta	:=  STRZERO(VAL(SUBSTR(ALLTRIM(SA2->A2_NUMCON),1,LEN(ALLTRIM(SA2->A2_NUMCON))-1)),10)
ENDIF

cDados   := (cBanco+cAgencia+cConta)

if SEA->EA_MODELO$"01"
	_nCheq   := somastr(cdados,str(_nvalor))
	_nCheq1  := multstr(_nCheq,str(5))
		
elseif SEA->EA_MODELO$"03"
	IF SE2->E2_VALOR < 5000.00   
	_nCheq   := somastr(cdados,str(_nvalor))
	_nCheq1  := multstr(_nCheq,str(5))	
	ELSE                                                      
	_nCheq   := somastr(cdados,str(_nvalor))
	_nCheq1  := multstr(_nCheq,str(7))
	ENDIF
elseif SEA->EA_MODELO$"31"
  cBanco	  := SUBSTR(SE2->E2_CODBAR,1,3)+"00000000000000"
  _nCheq   := somastr(cBanco,str(_nvalor))   
  _nCheq1  := multstr(_nCheq,str(5))   		
endif 

nTama := Len(_nCheq1)
nTama := 18 - nTama

IF nTama <= 0 
  _nCheq1 := right(_nCheq1,18)
else 
  _nCheq1 := left(STRZERO(nTama),nTama) + _nCheq1
endif  
  
Return(_nCheq1)