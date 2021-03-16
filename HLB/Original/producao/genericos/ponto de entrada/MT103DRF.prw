#INCLUDE "PROTHEUS.CH"
/*
Funcao      : MT103DRF()
Objetivos	: O ponto de entrada MT103DRF, pertence ao MATA103X (funções de validação e controle de interface de entrada) e é executado na rotina de validação do código do fornecedor, NFEFORNECE(), para nota de entrada padrão.
  			  Também é executado na rotina A103NFiscal do MATA103 quando da classificação de pré-nota de entrada.
			  Permite alterar o combobox com a informação de geração da DIRF, e o código de retenção. Disponível para IRPF, ISS, PIS, Cofins e CSLL.
Autor		: João Silva
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
