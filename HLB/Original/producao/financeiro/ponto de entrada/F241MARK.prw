#Include "rwmake.ch"    

/*
Funcao      : F241MARK
Parametros  : 
Retorno     : cRet
Objetivos   : PONTO DE ENTRADA PARA ALTERAR A ORDEM DOS CAMPOS NA MARKBROWSE
TDN         : 
Autor       : Anderson Arrais
Data/Hora   : 28/10/2016
Módulo      : Financeiro.
*/                      

*------------------------*
 User Function F241MARK()   
*------------------------*   
Local cRet := paramixb

If cEmpAnt $ "V5/FA/FC"
	cRet[2][1] :="E2_FORNECE"
	cRet[3][1] :="E2_NOMFOR"  
	cRet[4][1] :="E2_NUM"
	cRet[5][1] :="E2_VALOR"                           
	cRet[6][1] :="E2_VENCREA"
	
	cRet[2][3] :="Fornecedor"
	cRet[3][3] :="Nome Fornece"  
	cRet[4][3] :="Num.Tit"
	cRet[5][3] :="Valor"  
	cRet[6][3] :="Venc.Real"
	
	cRet[2][4] :="@!"
	cRet[3][4] :="@!"  
	cRet[4][4] :="@!"
	cRet[5][4] :="@E 999,999,999,999.99"
	cRet[6][4] :=""
EndIf  

Return cRet