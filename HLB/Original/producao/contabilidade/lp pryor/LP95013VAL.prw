#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar despesa 509
Autor       : Tiago Luiz Mendonça
Data/Hora   : 19/05/2010
*/                         

User Function LP95013VAL()       

Local nValDesp:=0
     
IF alltrim(SD1->D1_TIPO) == "N"
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))    

      //Tratamento Harris despesa infraero
      If SWD->(DbSeek(xFilial("SWD")+SWN->WN_HAWB+"509"))
         nValDesp:= SWD->WD_VALOR_R      
      Endif
      
   EndIf                                                                                                                                                              
EndIf


Return(nValDesp)