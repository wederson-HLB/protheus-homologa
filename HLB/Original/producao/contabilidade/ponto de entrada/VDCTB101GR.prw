#include "rwmake.ch"
#include "protheus.ch"

/*
Funcao      : VDCTB101GR
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para validar a gravação do Lançamento.
Autor     	: Jean Victor Rocha
Data     	: 09/09/2015                     
Módulo      : Contabil. 
*/
*------------------------*
User Function VDCTB101GR()
*------------------------*
Local nOpcX     := ParamIXB[1]
Local dDataLanc := ParamIXB[2]
Local cLote     := ParamIXB[3]
Local cSubLote  := ParamIXB[4]
Local cDoc      := ParamIXB[5]

//Executa caso for Copia de lançamento
If nOpcX == 7
	M->CT2_ORIGEM := "CPY-"+M->CT2_LP+"-"+SUBS(CUSUARIO,7,15)
EndIf

Return .T.