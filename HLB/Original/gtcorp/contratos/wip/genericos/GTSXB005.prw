#Include "Protheus.ch"

/*
Funcao      : GTSXB005
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte para validar o Sócio ou Gerente no cadastro de proposta
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 15/10/2014    17:36
Módulo      : Genérico
*/

*-----------------------------------*
User Function GTSXB005(cTipo,lItem)
*-----------------------------------*
Local lRet:= .T.

DEFAULT lItem := .F.

if !lItem
	if cTipo=="1" //Sócio
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !DbSeek(xFilial("Z42")+"1"+M->Z55_SOCIO)
			Alert("Sócio não encontrado no cadastro de alçada!")
			lRet:= .F.
		endif
	elseif cTipo=="2" //Gerente
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !empty(M->Z55_GERENT)
			if !DbSeek(xFilial("Z42")+"2"+M->Z55_GERENT)
				Alert("Gerente não encontrado no cadastro de alçada!")
				lRet:= .F.
			endif
		endif
	endif
else
	if cTipo=="1" //Sócio
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !DbSeek(xFilial("Z42")+"1"+M->Z29_SOCIO)
			Alert("Sócio não encontrado no cadastro de alçada!")
			lRet:= .F.
		endif
	elseif cTipo=="2" //Gerente
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !empty(M->Z29_GERENT)
			if !DbSeek(xFilial("Z42")+"2"+M->Z29_GERENT)
				Alert("Gerente não encontrado no cadastro de alçada!")
				lRet:= .F.
			endif
		endif
	endif
endif

	
Return(lRet)