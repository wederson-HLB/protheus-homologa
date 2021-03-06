#include "protheus.ch"

/*
Funcao      : GP450DES
Parametros  : 
Retorno     : lRet
Objetivos   : Ponto de entrada para tratar os tipos de opera��es na gera��o do SISPAG de folha
Autor       : Anderson Arrais
Data/Hora   : 03/07/2015
TDN         : Ponto de Entrada para desprezar funcion�rio, caso retorne .F., na gera��o de l�quidos para o SISPAG..
Revis�o     : 
Data/Hora   : 
M�dulo      : Gest�o de Pessoal.
*/

*------------------------------*
User Function GP450DES
*------------------------------*
//Os arquivos CNAB na pasta system tem que ter o padr�o: Kxx341CC.PAG / Kxx341DC.PAG / Kxx341TD.PAG onde xx � o c�digo da empresa
Local lRet:=.T.

If cEmpAnt $ "9J/4Y/XR/U2/LV/OX/MR/7N/7G/N0/7J/SK/K2/N5/BF/2G/QU/BJ/0F/DY/F6/2B/73/41/FP/FM/JB/K1/J2/LO/"//C�digo das empresas que tem CNAB SISPAG de folha de pagamento 	

	//Trata somente banco ITAU credito em conta
	If AllTrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"341CC.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SubStr(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		EndIf 
	//Trata DOC - N�o carrega funcionario com arquivo de DOC
	ElseIf AllTrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"341DC.PAG") 
			lRet:=.F.
	//Trata TED - AOA 03/02/2016 - Alterado tratamento para todos diferentes de 341 gerar TED independente de valor.
	ElseIf AllTrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"341TD.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)=="341" .OR. SubStr(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		EndIf
	EndIf
	
EndIf
 
//AOA - 01/03/2016 - Inclus�o de valida��o para a empresa SHISEIDO, ela usa arquivo de configura��o diferente por j� ter contas a pagar
If cEmpAnt $ "R7"//SHISEIDO CNAB SISPAG de folha de pagamento 	

	//Trata somente banco ITAU credito em conta
	If AllTrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"341F.PAG")
		//AOA - 01/04/2016 - Inclus�o do CPF do CLAYTON para n�o carregar no CNAB, ele usa conta conjunta no nome da esposa
		If SubStr(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SubStr(SRA->RA_BCDEPSA,1,3)<>"409" .OR. alltrim(SRA->RA_CIC)=="14703959836"
			lRet:=.F.	
		EndIf 
	//Trata TED para todos diferentes de 341 independente de valor
	ElseIf AllTrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"341FT.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)=="341" .OR. SubStr(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		EndIf
	EndIf
	
EndIf 

Return(lRet)