	#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar o estorno da baixa de adiantamento.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 12/05/2010
*/                         

User Function LP9509VAL()       

Local nValDesp:=0
     
IF alltrim(SD1->D1_TIPO) == "C"
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))    
      If SWD->(DbSeek(xFilial("SWD")+SWN->WN_HAWB+"901"))
         nValDesp:=SWD->WD_VALOR_R      
      Endif 
      
      //Tratamento Harris despesa infraero
      If SWD->(DbSeek(xFilial("SWD")+SWN->WN_HAWB+"509"))
         nValDesp:= nValDesp - SWD->WD_VALOR_R      
      Endif
      
   EndIf                                                                                                                                                              
EndIf


Return(nValDesp)