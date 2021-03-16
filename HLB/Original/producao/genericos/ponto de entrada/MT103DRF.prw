#INCLUDE "PROTHEUS.CH"
/*
Funcao      : MT103DRF()
Objetivos	: O ponto de entrada MT103DRF, pertence ao MATA103X (fun��es de valida��o e controle de interface de entrada) e � executado na rotina de valida��o do c�digo do fornecedor, NFEFORNECE(), para nota de entrada padr�o.
  			  Tamb�m � executado na rotina A103NFiscal do MATA103 quando da classifica��o de pr�-nota de entrada.
			  Permite alterar o combobox com a informa��o de gera��o da DIRF, e o c�digo de reten��o. Dispon�vel para IRPF, ISS, PIS, Cofins e CSLL.
Autor		: Jo�o Silva
Data  		: 09/09/2015
*/
*-----------------------*
User Function MT103DRF()
*-----------------------*

Local nCombo  := PARAMIXB[1]
Local cCodRet := PARAMIXB[2]
Local aImpRet := {}

nCombo  := 1
cCodRet := "1708"
aadd(aImpRet,{"IRR",nCombo,cCodRet})
nCombo  := 1
cCodRet := "5952"
aadd(aImpRet,{"PIS",nCombo,cCodRet})          
nCombo  := 1  
cCodRet := "5952"  
aadd(aImpRet,{"COF",nCombo,cCodRet})
nCombo  := 1
cCodRet := "5952"
aadd(aImpRet,{"CSL",nCombo,cCodRet})

Return aImpRet
