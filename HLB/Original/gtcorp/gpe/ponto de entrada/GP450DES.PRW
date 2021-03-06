#include "protheus.ch"

/*
Funcao      : GP450DES
Parametros  : 
Retorno     : lRet
Objetivos   : Ponto de entrada para tratar os tipos de opera��es na gera��o do SISPAG de folha
Autor       : Jo�o Silva
Data/Hora   : 26/07/2012 
TDN         : Ponto de Entrada para desprezar funcion�rio, caso retorne .F., na gera��o de l�quidos para o SISPAG..
Revis�o     : 
Data/Hora   : 
M�dulo      : Gest�o de Pessoal.
*/

User Function GP450DES
Local lRet:=.T.
//GT TECHNOLOGY - ITAU - 26/07/2012 - Joao Silva  

If cEmpAnt $ "CH" 	

	//trata somente banco ITAU credito em conta
	If AllTrim(UPPER(cArqent))==UPPER("KCH341CC.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SubStr(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		EndIf 
	//trata DOC - outros bancos	
	ElseIf AllTrim(UPPER(cArqent))==UPPER("KCH341DOC.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)=="341" .OR. SubStr(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		ElseIf NVALOR>=5000
			lRet:=.F.	
		EndIf
	EndIf
	
EndIf 
/*
AOA- 21/03/2016 - N�o mais utilizado, ser� tratado todas empresas com o mesmo arquivo           
If cEmpAnt $ "4K" 	

	//Trata somente banco ITAU credito em conta
	If AllTrim(UPPER(cArqent))==UPPER("K4K341CC.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)<>"341" 
			lRet:=.F.	
		EndIf 
	//trata DOC - outros bancos	
	ElseIf AllTrim(UPPER(cArqent))==UPPER("K4K341DOC.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)=="341" .OR. SubStr(SRA->RA_BCDEPSA,1,3)=="033"
			lRet:=.F.	
		EndIf
	EndIf
	
EndIf
*/

//AOA - 21/03/2016 - Tratamento SISPAG de tranferencia e TED
If cEmpAnt $ "RH/ZF/ZG/4K/Z4/Z8/ZB/ZP" 	

	//trata somente banco ITAU credito em conta
	If AllTrim(UPPER(cArqent))==UPPER("ITAUFOLHA.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SubStr(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		EndIf 
	//trata TED - outros bancos	
	ElseIf AllTrim(UPPER(cArqent))==UPPER("ITAUFOLHATED.PAG")
		If SubStr(SRA->RA_BCDEPSA,1,3)=="341" .OR. SubStr(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		EndIf
	EndIf
	
EndIf 

Return(lRet)