#include "Protheus.ch"

/*
Funcao      : GTCORP06
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Axcadastro da tabela Z93(Empresas Indicadoras)
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/03/2012    15:54
Módulo      : Gestão de Contratos
*/

User Function GTCORP06    

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "Z93"

if !cEmpAnt $ "ZB/ZF/Z8/ZH/4C/4K"
	Alert("Rotina não disponível para esta empresa!")
	Return()
endif

dbSelectArea(cString)
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Empresas Indicadoras",cVldExc,cVldAlt)

Return