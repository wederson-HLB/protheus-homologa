#Include "Protheus.ch"

/*
Funcao      : F200ABAT
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, utilizo para alterar o banco, agencia e titulo conforme o parametro informado na gera��o da baixa a receber autom�tica.
TDN			: Ponto de entrada para tratamento de abatimento e desconto 
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 03/05/2012  18:39
M�dulo      : Financeiro
*/                      

User Function F200ABAT
	if cEmpAnt $ "ZB" .AND. UPPER(ALLTRIM(FUNNAME()))=="FINA200"
		RecLock("SE1")
			Replace SE1->E1_PORTADO With MV_PAR06
			Replace SE1->E1_AGEDEP With MV_PAR07
			Replace SE1->E1_CONTA With MV_PAR08
		MsUnlock()
		//para alterar as vari�veis que ser�o gravadas na SE5.
		cBanco  := mv_par06
		cAgencia:= mv_par07
		cConta  := mv_par08
		cSubCta := mv_par09	
	endif	
Return