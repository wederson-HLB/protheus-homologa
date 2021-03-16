#Include "Protheus.ch"

/*
Funcao      : GTCORP84
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Ponto de entrada para filtro da query de seleção dos títulos apresentados na tela do borderô
TDN			: O ponto de entrada FA060QRY permite a inclusão de uma condição adicional na consulta SQL (Query) de seleção dos títulos a receber, para posterior marcação em tela.
			: A condição adicionada deve seguir a sintaxe SQL e irá interferir na seleção dos títulos a receber que serão exibidos em tela.
Autor       : Matheus Massarotto
Data/Hora   : 12/02/2014    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*---------------------*
User function FA060QRY
*---------------------*
Local cAgenc	:= ALLTRIM(Paramixb[1])
Local cConta	:= ALLTRIM(Paramixb[2])
Local cQry		:= ""

If cEmpAnt $ "Z4/ZB/ZF/ZG/4K/8F/CH/Z8/ZA/ZP"
	cQry	:= "E1_AGEDEP='"+cAgenc+"' AND E1_CONTA='"+cConta+"'"
Else
	cQry	:= " D_E_L_E_T_ = ''"
EndIf

Return(cQry)