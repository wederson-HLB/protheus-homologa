#Include "Protheus.ch"

/*
Funcao      : GTCORP84
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Ponto de entrada para filtro da query de sele��o dos t�tulos apresentados na tela do border�
TDN			: O ponto de entrada FA060QRY permite a inclus�o de uma condi��o adicional na consulta SQL (Query) de sele��o dos t�tulos a receber, para posterior marca��o em tela.
			: A condi��o adicionada deve seguir a sintaxe SQL e ir� interferir na sele��o dos t�tulos a receber que ser�o exibidos em tela.
Autor       : Matheus Massarotto
Data/Hora   : 12/02/2014    10:14
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gen�rico
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