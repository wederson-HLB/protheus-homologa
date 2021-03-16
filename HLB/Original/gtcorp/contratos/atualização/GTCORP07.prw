#include "Protheus.ch"

/*
Funcao      : GTCORP07
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Axcadastro da tabela Z92(Indica��o)
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 15/03/2012    15:54
M�dulo      : Gest�o de Contratos
*/

User Function GTCORP07    

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "Z92"

if !cEmpAnt $ "ZB/ZF/Z8/ZH/4C/4K"
	Alert("Rotina n�o dispon�vel para esta empresa!")
	Return()
endif

dbSelectArea(cString)
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Pessoas Indicadoras",cVldExc,cVldAlt)

Return