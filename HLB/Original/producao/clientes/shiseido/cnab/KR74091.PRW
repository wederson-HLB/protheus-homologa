
/*
Funcao      : KR74091
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cnab Shiseido - Unibanco 
Autor     	: Wederson L. Santana
Data     	: 24/08/05                        '
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Financeiro. 
Cliente     : Shiseido
*/

*------------------------*
 User Function KR74091()
*------------------------*

Local dDataDesc :=Replicate("0",6)

If! Empty(SE1->E1_DESCFIN)
    dDataDesc :=GravaData(SE1->E1_VENCREA-SE1->E1_DIADESC)
Endif

Return(dDataDesc)