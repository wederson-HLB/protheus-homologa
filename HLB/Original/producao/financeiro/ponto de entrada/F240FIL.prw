/*/{Protheus.doc} F240FIL
@type function

@author Jo�o Vitor | InfinIT Tecnologia
@since 29/04/2016
@version P11 R8

Descri��o:
Ponto de entrada para filtro de titulos a serem inseridos em border�.

/*/
#Include "PROTHEUS.CH"
#Include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

*---------------------*
User Function F240FIL()
*---------------------*

local cCondicao

If cEmpAnt $ "SU"		
	If ExistBlock("SUFIN011")
		cCondicao := u_SUFIN011()
	EndIf
EndIf

//AOA - 28/08/2017 - Solaris inclus�o do campo modelo de pagamento
If cEmpAnt $ "HH/HJ"	
	cCondicao := "E2_P_MODEL='"+CMODPGTO+"'"
EndIf

Return(cCondicao)
