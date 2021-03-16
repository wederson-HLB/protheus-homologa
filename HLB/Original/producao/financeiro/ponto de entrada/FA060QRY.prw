#include "Totvs.ch"

/*
Funcao      : FA060QRY
Parametros  : Nenhum
Retorno     : cRet
Objetivos   : P.E. chamado para filtrar tipo de títulos que serão gerados no borderô
Autor       : Renato Rezende
Data/Hora   : 22/09/16     
Obs         : 
TDN         : O ponto de entrada FA060QRY permite a inclusão de uma condição adicional na consulta SQL (Query) de seleção dos títulos a receber, para posterior marcação em tela.
			  A condição adicionada deve seguir a sintaxe SQL e irá interferir na seleção dos títulos a receber que serão exibidos em tela.
Módulo      : Financeiro.
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

//AOA - 13/03/2017 - Tratamento para SOLARIS (validação pela natureza)
If cEmpAnt $ "HH/HJ"
	//cRet := "E1_NATUREZ <> '1005' " - AOA - 20/10/2017 - Novo tratamento de cobrança ID46
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