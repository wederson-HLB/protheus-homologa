#Include "Protheus.ch"

/*
Funcao      : GTSXB004
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para validação de campo da tabela Z29, utilizada no acols de um msnewgetdados
Autor       : Matheus Massarotto
Data/Hora   : 29/08/2014    15:27
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*-----------------------------*
User function GTSXB004(cCampo)
*-----------------------------*
Local lRet	:= .F.

Default cCampo := "" 

if UPPER(alltrim(cCampo))=='Z29_CODDIV'
	if oGetDadosZ29:aCols[oGetDadosZ29:oBrowse:nAt][Ascan(aHeaderZ29,{|x| alltrim(x[2]) = 'Z29_TPCTR'})]==Z58->Z58_TIPO
		lRet:=.T.		
	endif
endif

Return(lRet)