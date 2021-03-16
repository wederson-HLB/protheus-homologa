#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de entrada para estoque TOTAL - IR.
Objetivos   : Retornar a conta baseado no tipo do processo.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/01/2011
*/

User Function LP650_02VAL()       

Local aItens :={}
Local nTot      := 0
Local nResult   := 0
Local nLimite:=GETMV("MV_VLRETIR")  
Local cIt  :=aScan(aHeader,{|a| AllTrim(a[2])=="D1_VALIRR"})      
Local i := 0
                   
aItens:=aCols
For i:=1 to Len(aItens)
   nTot+=aItens[i][cIt]   
Next

If nLimite > nTot
   nResult:=SD1->D1_TOTAL-(SD1->D1_VALISS+SD1->D1_VALINS)   
Else
   nResult:=SD1->D1_TOTAL-(SD1->D1_VALIRR+SD1->D1_VALISS+SD1->D1_VALINS)
EndIf
 

Return(nResult)
 



