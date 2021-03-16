#include "rwmake.ch"   

/*
Funcao      : F560CPOS
Parametros  : Nenhum
Retorno     : cCampos
Objetivos   : INCLUSAO DE NOVOS CAMPOS NO ACOLS DO MOVIMENTO DO CAIXINHA (Prestação de Contas)
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/    

*------------------------*     
 User Function F560CPOS()  
*------------------------*      

Private cCampos   := ""

cCampos := "EU_P_NATUR|EU_P_CLIEN|EU_P_LOJA|EU_P_NOMCL|EU_CONTAD|EU_CCD|EU_ITEMD|"

Return cCampos

