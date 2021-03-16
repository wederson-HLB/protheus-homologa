#Include "rwmake.ch"    

/*
Funcao      : GTFIN020
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento valor de cobrança cnab
Autor       : Anderson Arrais
Data/Hora   : 10/10/2016
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN020(nOpc)   
*------------------------------*   
Local cRet 		:= 0
Local _nVlrAbat := 0
Local _nValor   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna valor liquido de cobrança 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1 
 	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    _nValor   := SE1->E1_SALDO - _nVlrAbat - SE1->E1_DECRESC + SE1->E1_ACRESC
    cRet      := STRZERO((_nValor*100),13,0)     
Endif

Return(cRet)