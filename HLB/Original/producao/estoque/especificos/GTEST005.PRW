#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TBICONN.CH"

/*
Funcao      : GTEST005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Execução automatica da rotina Refaz Acumulados - Via JOB
Autor       : Weden Alves
Cliente		: Todos
Data/Hora   : 17/01/2019
*/
*------------------------*
User Function GTEST005(aEmp)
*------------------------*
Local PARAMIXB	:= .F.    
Private lJob	:= (Select("SX3") <= 0)       

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","HLB BRASIL" )
	Return nil
Else
	PREPARE ENVIRONMENT EMPRESA aEmp[1] Filial aEmp[2] TABLES "SA1","SB2","SC0","SC6","SC7","SC9","SD1","SD4","SE2","VCB" MODULO "EST"
	
	MSExecAuto({|x| mata215(x)},PARAMIXB)
	
	RESET ENVIRONMENT
Endif

Return Nil