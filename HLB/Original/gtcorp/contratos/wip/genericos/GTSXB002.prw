#Include "Protheus.ch"

/*
Funcao      : GTSXB002
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para retornar o nome do funcionário pesquisado pelo CPF
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 31/07/2013    10:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSXB002(cCPF)
*-------------------------*
Local cQry		:= ""
Local cQryAux	:= ""
Local aAllGroup	:= FWAllGrpCompany() //Empresas
Local cRet		:= ""
    
	//Verificação para não dar erro na query
	if AT("'",cCPF)>0 .OR. AT('"',cCPF)>0
		Return(cRet)
	endif 
	 
	if Empty(cCPF)
		Return(cRet)
	EndIf
            cQry+=" SELECT RA_NOME FROM 
			cQry+=" (
		    //Percorro todas as empresas
			For i:=1 to len(aAllGroup)
                if !TCCanOpen("SRA"+aAllGroup[i]+"0")
					Loop
				endif
				
				//Testando se a query tem problemas
				cTeste:=" SELECT '"+aAllGroup[i]+"' AS EMP,RA_NOME,RA_CIC,RA_MAT,R_E_C_N_O_ AS CRECNO FROM SRA"+aAllGroup[i]+"0 WHERE D_E_L_E_T_='' AND RA_SITFOLH NOT IN ('D','T')"
				
				if tcsqlexec(cTeste)<0
					cError		:= TCSQLError()
					cMensErro	+= "Empresa: "+cEmpAnt+": "+alltrim(cError)+CRLF+"----------------------------"+CRLF
					Loop
				endif
            	
            	if !empty(cQryAux)
				   cQryAux+=" UNION ALL "            	
				endif
				
				
				cQryAux+=" SELECT '"+aAllGroup[i]+"' AS EMP,RA_NOME,RA_CIC,RA_MAT,R_E_C_N_O_ AS CRECNO FROM SRA"+aAllGroup[i]+"0"
				cQryAux+=" WHERE D_E_L_E_T_='' " //AND RA_SITFOLH NOT IN ('D','T')"
            	

			
			Next
        
        cQry+=cQryAux
        cQry+=" ) AS TEMP
        cQry+=" WHERE RA_CIC='"+cCPF+"'"
        
		//Se a query n foi carregada
		if empty(cQryAux)
			return
		endif

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
	
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
		
		if nRecCount > 0
			
			QRYTEMP->(DbGoTop())
			
			cRet:= QRYTEMP->RA_NOME
			
		endif

Return(cRet)