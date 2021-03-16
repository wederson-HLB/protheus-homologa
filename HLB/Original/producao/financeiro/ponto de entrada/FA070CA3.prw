#include "Protheus.ch"

/*
Funcao      : FA070CA3
Parametros  : 
Retorno     : Nil
Objetivos   : Ponto de entrada, no FINA070.
TDN			: O ponto de entrada FA070CA3 sera executado antes da entrada na rotina cancelamento de baixa do contas a receber, para verificar se esta pode ou nao ser cancelada.
Autor       : Matheus Massarotto
Data/Hora   : 23/04/2015    09:34
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/

*--------------------*
User function FA070CA3
*--------------------*
Private aArea		:= GetArea()
Private lRet		:= .T.
Private lValidExc	:= GetNewPar("MV_P_00051",.F.)

if cEmpAnt $ "TP" //Twitter
                                                      

	if lValidExc
		if SE1->(FieldPos("E1_P_ARQ"))>0
			if !empty(SE1->E1_P_ARQ)
				Msginfo("Esse título não pode ser excluído pois já foi enviado para o sistema Oracle – Tiwitter.","HLB BRASIL")
				lRet:=.F.
			endif
		endif
	endif
endif

RestArea(aArea)
return(lRet)

