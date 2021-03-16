//|=====================================================================|
//|Programa: F378GRV.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|titulo gerado de PIS/COFINS/CSLL pela rotina de aglutinacao de 		|
//|imposto (FINA378)							                        |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA378                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function F378GRV()
If cEmpAnt $ "SU"
 	If ExistBlock("SUFIN006")
		U_SUFIN006()
	EndIf        
EndIf
	
return