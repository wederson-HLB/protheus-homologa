#include "rwmake.ch" 

/*
Funcao      : CYYFAT04 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vinculo de TES x Empresas  
Autor       : 
Data/Hora   : 
Obs         : Validação
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 18/07/2012
Obs         :
Módulo      : Livros Fiscais.
Cliente     : Todas	
*/

*-------------------------*
 User Function CYYFAT04()
*-------------------------*

 //hfpok
_aArea:=getarea()

_cTES:=sz2->z2_tes

dbselectarea("SF4")
DBSETORDER(1)
IF DBSEEK(XFILIAL("SF4")+_CTES)
	A080SXBVISUAL()
ELSE
	ALERT("Codigo TES nao Encontrado, Contate Responsavel Setor Fiscal")
endif

restarea(_aArea)

Return
