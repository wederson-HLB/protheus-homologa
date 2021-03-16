#INCLUDE "RWMAKE.CH"

/*
Funcao      : EXECSEQ
Parametros  : Nenhum
Retorno     : _cBanco
Objetivos   : Função de retorno para dados do CNAB
Autor     	: 
Data     	: 01/07/11
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function EXECSEQ()
*------------------------*

Local _cBanco
Public nSeqcnab
Public nValTot 

If cEmpAnt $ ("07")
	_cBanco:= "033"
	nSeqcnab := 0
	nValTot  := 0 
EndIf    

Return(_cBanco)

*-------------------------------*
 User Function EXECSEQ1(_cTipo)
*-------------------------------*

Local _cBanco

If cEmpAnt $ ("07")
	_cBanco:= "033" 
	nSeqcnab := nSeqcnab + 1
	IF !_cTipo $("B/W")
		nValTot :=  nValTot + SE2->E2_VALOR + SE2->E2_ACRESC
	Endif
EndIf    


Return(_cBanco)
