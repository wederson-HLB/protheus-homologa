#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP58
Parametros  : cAproResp,cTipo
Retorno     : Nil
Objetivos   : Função para filtro da consulta SB1Z85, e validação do campo Z79_RESPON, utilizada no cadastro de propostas
Autor       : Matheus Massarotto
Data/Hora   : 07/02/2013	14:44
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*-------------------------------------*
User Function GTCORP58(cAproResp,cTipo)
*-------------------------------------*
Local cRet  := "alltrim(Z65->Z65_IDDEPE)==''"
Local cQry	:= ""
Local nII	:= 0
Local aArea	:= GetArea()

DEFAULT cTipo		:= ""
DEFAULT cAproResp	:= ""

cQry:=" SELECT Z65_IDUSER FROM "+RETSQLNAME("Z65")+" Z65"
cQry+=" JOIN "+RETSQLNAME("Z66")+" Z66 ON Z66_IDUSER=Z65_IDUSER AND Z66_FILIAL=Z65_FILIAL"
cQry+=" WHERE Z65.D_E_L_E_T_='' AND Z66.D_E_L_E_T_='' AND Z65_IDDEPE='"+__cUserID+"'"

if cTipo=="MSG"
	if cAproResp=='RESPONSAVEL'
		cQry+=" AND Z65_IDUSER='"+alltrim(&(READVAR()))+"'"  //READVAR() - para retornar o campo no qual o está chamando
    elseif cAproResp=='APROVADOR'
	    cQry+=" AND Z65_IDUSER='"+alltrim(&(READVAR()))+"'" //READVAR() - para retornar o campo no qual o está chamando
    endif
endif

if cAproResp=='RESPONSAVEL'
	cQry+=" AND Z66_LRESPO='T'"
elseif cAproResp=='APROVADOR'
	cQry+=" AND Z66_LAPROV='T'"
endif

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .T., .F. )

	Count to nRecCount
        
	if nRecCount >0
		QRYTEMP->(DbGoTop())
		
		cRet:="alltrim(Z65->Z65_IDDEPE)=='"+__cUserID+"' .AND."
		cRet+="("
		While QRYTEMP->(!eof())                                   
			if nII>0
				cRet+=" .OR. "
			endif
			
			cRet+=" alltrim(Z65->Z65_IDUSER)== '"+alltrim(QRYTEMP->Z65_IDUSER)+"'"
			QRYTEMP->(DbSkip())
			
			nII+=1
		Enddo
		
		cRet+=")"	
	endif

    //exibi mensagem na tela do usuário, para validação dos campos Z79_RESPON e Z79_APROVA ou Z55_RESPON e Z55_APROVA
	if cTipo=="MSG"
		if nRecCount<=0
				
				if cAproResp=='RESPONSAVEL'
					msginfo("Não está permitido selecionar este responsável!")
				elseif cAproResp=='APROVADOR'
					msginfo("Não está permitido selecionar este aprovador!")
				endif
				
			cRet:=".F."
		else
			cRet:=".T."
		endif
	endif

	if select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	endif

RestArea(aArea)
Return &cRet