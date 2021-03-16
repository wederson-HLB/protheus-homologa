#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
/*
Funcao      : LVGPE001
Cliente     : COTTON
Parametros  : nIni = caracter inicial
			  nQtd = Quantidade caracter
Retorno     : Nenhum
Objetivos   : Função auxiliar para integração de hora extra.
Autor       : Renato Rezende
Data/Hora   : 16/10/2014
Revisao     :
Obs.        : 
*/
*-------------------------------*
User Function LVGPE001(nIni,nQtd)
*-------------------------------*
Local cCPF := ""

Default nIni := 3
Default nQtd := 11

cCPF := ALLTRIM(STR(VAL(SubStr( TXT, nIni,nQtd))))

SRA->(DbSetOrder(5))
If SRA->(DbSeek(xFilial("SRA")+cCPF))
	cRet := SRA->RA_MAT
Else
	cRet := cCPF
EndIf

Return cRet