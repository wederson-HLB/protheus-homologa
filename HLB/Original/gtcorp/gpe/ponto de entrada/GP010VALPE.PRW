#INCLUDE "Protheus.ch"

/*
Funcao      : GP010VALPE
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Alterar valores após a alteração ou inclusão de funcionários 
TDN			: Ponto de Entrada para checar os dados de inclusão/alteração de funcionários.
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 04/09/2015    14:29
Módulo      : Gestão Pessoal
*/

*----------------------*
User function GP010VALPE
*----------------------*
Local cQuery:= ""
Local lRet	:= .T.

if !(cEmpAnt $ "ZB/ZF/ZG/Z4")
	Return(lRet)
endif

if SR7->(FieldPos("R7_P_WIPFU"))>0 .AND. SRA->(FieldPos("RA_P_WIPFU"))>0 .AND. SR7->(FieldPos("R7_P_WIPFD"))>0

	cQuery := "SELECT TOP 1 R_E_C_N_O_ "
	cQuery += "FROM "+ RetSqlName("SR7") + " SR7 "
	cQuery += "WHERE R7_FILIAL = '" + SRA->RA_FILIAL  + "' AND "
	cQuery += " R7_MAT =  '" + SRA->RA_MAT + "'"
	cQuery += " AND SR7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC
	
	If TCSQLExec(cQuery) < 0
		conout("ERRO - Gp010ValPE - "+TCSQLError())
		Return(lRet)
	Endif
	
		If Select("QSR7")>0
			DbSelectArea("QSR7")
			QSR7->(DbCloseArea())
		Endif
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSR7",.F.,.T.)
	
		count to nRecCount
		
		if nRecCount > 0
			QSR7->(DbGoTop())
	
			DbSelectArea("SR7")
			SR7->(DbGoTo(QSR7->R_E_C_N_O_))
			
			RecLock("SR7",.F.)
				SR7->R7_P_WIPFU:= SRA->RA_P_WIPFU
				SR7->R7_P_WIPFD:= POSICIONE("SX5", 1,"  ZW"+SRA->RA_P_WIPFU, "X5_DESCRI")   
			MsUnlock()
			
		endif
endif

Return(lRet)