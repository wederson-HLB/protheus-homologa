#Include "Totvs.ch" 
/*
Funcao      : LP610001() 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retor conta de acorde com a regra.
Autor       : João Silva	
Data        : 13/11/2015
TDN         : 
Módulo      : Contabilidade.
*/     
*-----------------------*
User Function LP610001()
*-----------------------*
Local cConta:= ''

If cEmpAnt $ 'BA/BB'//307 COMERCIO / AMANDA BRASIL
	If SD2->D2_COD = 'CAI0001'
		cConta := '11111001'
	ElseIf SD2->D2_COD = 'CAR0001'
		cConta := '11211002'
	ElseIf SD2->D2_COD = 'CHE0001'
		cConta := '11212001'
	Else
		cConta := '11211001'		
	EndIf
EndIf


Return(cConta)

