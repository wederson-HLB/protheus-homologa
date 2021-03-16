#include "rwmake.ch"   

/*
Funcao      : F560CPOS
Parametros  : Nenhum
Retorno     : cCampos
Objetivos   : INCLUSAO DE NOVOS CAMPOS NO ACOLS DO MOVIMENTO DO CAIXINHA (Presta��o de Contas)
Autor       : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Financeiro.
*/    

*------------------------*     
 User Function F560CPOS()  
*------------------------*      

Private cCampos   := ""

cCampos := "EU_P_NATUR|EU_P_CLIEN|EU_P_LOJA|EU_P_NOMCL|EU_CONTAD|EU_CCD|EU_ITEMD|"

Return cCampos

