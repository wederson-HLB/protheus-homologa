#include "Totvs.ch"

/*
Funcao      : FA060QRY
Parametros  : Nenhum
Retorno     : cRet
Objetivos   : P.E. chamado para filtrar tipo de t�tulos que ser�o gerados no border�
Autor       : Renato Rezende
Data/Hora   : 22/09/16     
Obs         : 
TDN         : O ponto de entrada FA060QRY permite a inclus�o de uma condi��o adicional na consulta SQL (Query) de sele��o dos t�tulos a receber, para posterior marca��o em tela.
			  A condi��o adicionada deve seguir a sintaxe SQL e ir� interferir na sele��o dos t�tulos a receber que ser�o exibidos em tela.
M�dulo      : Financeiro.
Cliente     : Todos
*/
   
*------------------------*
 User Function FA060QRY()
*------------------------*
Local cRet:= Nil

//Empresas Vogel
If cEmpAnt $ u_EmpVogel()
    
	If SE1->(FieldPos("E1_P_BOL")) > 0
		cRet := " E1_P_BOL <> 'N' "
	EndIf
	
EndIf

//AOA - 13/03/2017 - Tratamento para SOLARIS (valida��o pela natureza)
If cEmpAnt $ "HH/HJ"
	//cRet := "E1_NATUREZ <> '1005' " - AOA - 20/10/2017 - Novo tratamento de cobran�a ID46
	cRet := "E1_P_BOL = 'S' "
EndIf

//AOA - 07/
If cEmpAnt $ "K1"
	cRet := "E1_NATUREZ = '1001' "
EndIf

//AOA - 07/05/2019 - valida se deve aparecer para gerar bordero (QN0001/2019)
If cEmpAnt $ "QN"
	cRet := "E1_P_BOL <> 'N' " 
EndIf

Return cRet