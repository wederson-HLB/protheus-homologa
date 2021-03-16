#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar a conta baseado no tipo do processo.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 21/07/10
*/

User Function LP9506B()       

Local nResult:=""
Local cCfoP,cTes
     
//cTes := "1B6/1B7/1B8 /1C1/1C2/1C3/1C4/1C5/1C6/1C7/1C8/1C9"             
cCfoP:= "3101/3102"

IF alltrim(SD1->D1_CF) $ (cCfoP) 
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))
      SW6->(DbSetOrder(1))  
      If SW6->(DbSeek(xFilial("SW6")+SWN->WN_HAWB)) 
         If SW6->(FieldPos("W6_P_AWB")) > 0
           // sem cobertura cambial
            If SW6->W6_P_AWB == "1"   
               nResult:="411112143"
            Else
               nResult:=SA2->A2_CONTA                                                                                                                                                                                           
            EndIf             
         EndIf
      EndIf   
   EndIf
EndIf


Return(nResult)

