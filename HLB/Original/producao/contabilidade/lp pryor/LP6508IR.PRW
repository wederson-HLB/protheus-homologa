#include "rwmake.ch"     

/*
Funcao      : Lan�amento padr�o de entrada para estoque IR.
Objetivos   : Retornar a conta baseado no tipo do processo.
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 20/01/2011
*/

User Function LP6508IR()  
     
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
   nResult:=0     
Else
   nResult:=SD1->D1_VALIRR
EndIf
 

Return(nResult)

