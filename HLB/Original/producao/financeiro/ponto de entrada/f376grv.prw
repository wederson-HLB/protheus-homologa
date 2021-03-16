//|=====================================================================|
//|Programa: F376GRV.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|titulo gerado de IRRF pela rotina de aglutinacao de imposto (FINA376)|
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA376                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function F376GRV()
If cEmpAnt $ "SU"
 	If ExistBlock("SUFIN005")
		U_SUFIN005()
	EndIf 
EndIf
	
return