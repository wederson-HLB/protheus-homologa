#Include "Protheus.ch"
/*
Funcao      : LP53004D())
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retor conta de acorde com a regra.
Autor       : João Silva	
Data        : 05/10/2015
TDN         : 
Módulo      : Contabilidade.
*/     
*------------------------*
User Function LP53004D()   
*------------------------*
cConta:= ""    

If cEmpAnt $ "B1" .AND. SE2->E2_ACRESC > 0
	If SE2->E2_NATUREZ ="2908"
		cConta:= "11320014"
	ElseIf SE2->E2_NATUREZ = "2909"
		cConta :="11320015"
	Else
		cConta :="52111007"
	EndIf
Else
	cConta:= "52111001"
EndIf  

Return(cConta)
	
