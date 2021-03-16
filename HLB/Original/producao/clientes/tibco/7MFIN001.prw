#Include "rwmake.ch"    

/*
Funcao      : 7MFIN001
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento para gerar chave única de documento
Autor       : 
TDN         : 
Revisão     : Anderson Arrais
Data/Hora   : 23/09/2015
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function 7MFIN001(nOpc)   
*------------------------------*   
Local cRet := ""
Local cDat := ""
Local cHor := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna chave unica		         				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
	cDat := GRAVADATA(DATE(),.F.,1)
	cHor := STRTRAN(TIME(),":","")
	cRet := SRA->RA_FILIAL+SRA->RA_MAT+SUBSTR(cDat,1,4)+SUBSTR(cHor,1,4)
Endif

Return(cRet)