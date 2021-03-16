#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : 33GPE002
Cliente     : GRACE
Parametros  : nIni = caracter inicial
			  nQtd = Quantidade caracter
Retorno     : Nenhum
Objetivos   : Função auxiliar para integração de hora extra.
Autor       : Jean Victor Rocha
Data/Hora   : 21/06/2012
Revisao     :
Obs.        : 
*/
*-------------------------------*
User Function 33GPE002(nIni,nQtd)
*-------------------------------*
Local cCracha := ""

Default nIni := 7
Default nQtd := 5  

cCracha := ALLTRIM(STR(VAL(SubStr( TXT, nIni,nQtd))))

SRA->(DbSetOrder(9))
If SRA->(DbSeek(cCracha))
	cRet := SRA->RA_MAT
Else
	cRet := cCracha
EndIf

Return cRet