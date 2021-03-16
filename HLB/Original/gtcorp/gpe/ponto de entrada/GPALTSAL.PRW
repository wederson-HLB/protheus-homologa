#Include "Protheus.ch"

/*
Funcao      : GPALTSAL
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Após gravar a alteração do funcionário, gravar o código da função WIP no cadastro de histórico de alterações salariais
TDN			: Permite atualizar uma tabela personalizada quando o salário do funcionário for alterado.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 27/03/2014    14:28
Módulo      : Gestão Pessoal
*/

*---------------------*
User function GPALTSAL
*---------------------*

if !(cEmpAnt $ "ZB/ZF/ZG/Z4")
	Return()
endif

if SR7->(FieldPos("R7_P_WIPFU"))>0 .AND. SRA->(FieldPos("RA_P_WIPFU"))>0 .AND. SR7->(FieldPos("R7_P_WIPFD"))>0
	RecLock("SR7",.F.)
		SR7->R7_P_WIPFU:= SRA->RA_P_WIPFU
		SR7->R7_P_WIPFD:= POSICIONE("SX5", 1,"  ZW"+SRA->RA_P_WIPFU, "X5_DESCRI")   
	MsUnlock()
endif

Return()