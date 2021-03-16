#include "Protheus.ch"

/*
Funcao      : GTCORP05
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Axcadastro da tabela Z94(Cadastro de Linha de Fluxo)
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/03/2012    15:54
Módulo      : Financeiro
*/

User Function GTCORP05    

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "Z94"

dbSelectArea(cString)
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Linha de Fluxo",cVldExc,cVldAlt)

Return