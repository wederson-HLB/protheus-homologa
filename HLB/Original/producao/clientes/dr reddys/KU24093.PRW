
/*
Funcao      : KU24093
Parametros  : Nenhum
Retorno     : dDataDesc
Objetivos   : Cnab Dr. Reddy�s - Unibanco  
Autor     	: Wederson L. Santana 
Data     	: 12/04/05
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Financeiro.
*/

*------------------------*
 User Function KU24093()  
*------------------------*

Local dDataDesc :=Replicate("0",6)

If! Empty(SE1->E1_DESCFIN)
    dDataDesc :=GravaData(SE1->E1_VENCREA-SE1->E1_DIADESC)
Endif

Return(dDataDesc)