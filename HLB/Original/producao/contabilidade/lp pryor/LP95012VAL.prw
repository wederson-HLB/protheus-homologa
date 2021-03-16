#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar a despesa PCC
Autor       : Tiago Luiz Mendonça
Data/Hora   : 12/05/2010
*/                         

User Function LP95012VAL()       

Local nResult:=0
     
IF alltrim(SD1->D1_TIPO) == "C"
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))    
      If SWD->(DbSeek(xFilial("SWD")+SWN->WN_HAWB+"507"))
         nResult:=SWD->WD_VALOR_R 
         
         If nResult < 0
            nResult :=nResult * (-1)   
         EndIf
         
      Endif
   EndIf                                                                                                                                                              
EndIf


Return(nResult)