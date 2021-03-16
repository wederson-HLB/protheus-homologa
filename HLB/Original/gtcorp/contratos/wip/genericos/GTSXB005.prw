#Include "Protheus.ch"

/*
Funcao      : GTSXB005
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte para validar o S�cio ou Gerente no cadastro de proposta
			: 
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 15/10/2014    17:36
M�dulo      : Gen�rico
*/

*-----------------------------------*
User Function GTSXB005(cTipo,lItem)
*-----------------------------------*
Local lRet:= .T.

DEFAULT lItem := .F.

if !lItem
	if cTipo=="1" //S�cio
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !DbSeek(xFilial("Z42")+"1"+M->Z55_SOCIO)
			Alert("S�cio n�o encontrado no cadastro de al�ada!")
			lRet:= .F.
		endif
	elseif cTipo=="2" //Gerente
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !empty(M->Z55_GERENT)
			if !DbSeek(xFilial("Z42")+"2"+M->Z55_GERENT)
				Alert("Gerente n�o encontrado no cadastro de al�ada!")
				lRet:= .F.
			endif
		endif
	endif
else
	if cTipo=="1" //S�cio
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !DbSeek(xFilial("Z42")+"1"+M->Z29_SOCIO)
			Alert("S�cio n�o encontrado no cadastro de al�ada!")
			lRet:= .F.
		endif
	elseif cTipo=="2" //Gerente
		DbSelectARea("Z42")
		DbSetOrder(4)
		if !empty(M->Z29_GERENT)
			if !DbSeek(xFilial("Z42")+"2"+M->Z29_GERENT)
				Alert("Gerente n�o encontrado no cadastro de al�ada!")
				lRet:= .F.
			endif
		endif
	endif
endif

	
Return(lRet)