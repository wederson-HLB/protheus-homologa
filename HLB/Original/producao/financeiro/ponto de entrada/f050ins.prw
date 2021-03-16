//|=====================================================================|
//|Programa: F050INS.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|           titulo gerado de INSS.                                    |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA050                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function F050INS()

If cEmpAnt $ "SU"	
	If ExistBlock("SUFIN003")
		U_SUFIN003()
	EndIf
Endif
	
RETURN
