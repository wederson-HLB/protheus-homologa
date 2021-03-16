//|=====================================================================|
//|Programa: F050IRF.PRW  |Autor: Jo�o Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar hist�rico no titulo de IRRF  |
//|           C�digo da Reten��o e Gera Dirf SIM.                       |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA050                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function F050IRF()
If cEmpAnt $ "SU"
 	If ExistBlock("SUFIN004")
		U_SUFIN004()
	EndIf        
EndIf

RETURN   