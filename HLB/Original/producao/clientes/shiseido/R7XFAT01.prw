#include "RWMAKE.CH"

/*
Funcao      : R7XFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gatilho campo  C5_CONDPAG
Autor     	: Wederson L. Santana
Data     	: 12/05/05                       '
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Faturamento. 
Cliente     : Shiseido
*/

*--------------------------*
  User Function R7XFAT01()
*--------------------------*

If M->C5_TABELA $ "6".AND.M->C5_CONDPAG <> "***"
   MsgInfo("CLIENTE COM DESCONTO DE"+STR(M->C5_DESCTAB)+"%" ,"TABELA 6 - BRASIL")
ElseIf M->C5_TABELA $ "5".AND.M->C5_CONDPAG <> "***"    
   MsgInfo("CLIENTE COM DESCONTO DE"+STR(M->C5_DESCTAB)+"%","TABELA 5 - SP/RJ")
ElseIf M->C5_TABELA $ "4".AND.M->C5_CONDPAG <> "***"    
   MsgInfo("CLIENTE COM DESCONTO DE"+STR(M->C5_DESCTAB)+"%","TABELA 4 - SP/RJ")
ElseIf M->C5_TABELA $ "7".AND.M->C5_CONDPAG <> "***"    
   MsgInfo("UTILIZAR O TES 510 .","TABELA 7 - VENDA PARA FUNCIONARIOS")
Endif  
 

Return("")