#Include "Protheus.ch"

/*
Funcao      : GTGCT001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Retornar o nome do sócio para apresentação na proposta
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 24/10/2014    10:30
Módulo      : Genérico
*/

*--------------------------------*
User Function GTGCT001(cProposta)
*--------------------------------*
Local cRet:=""
Local cQry:=""

cQry+=" SELECT Z55_NOMESO FROM "+RETSQLNAME("Z55")
cQry+=" WHERE Z55_NUM='"+alltrim(cProposta)+"' AND D_E_L_E_T_='' AND Z55_REVATU='' AND Z55_STATUS='E'"
    
	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

	DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"QRYTEMP",.F.,.F.)
	
	count to nRecCount
	
	if nRecCount >0
		QRYTEMP->(DbGoTop())
		cRet:=QRYTEMP->Z55_NOMESO		
	endif

Return(cRet)