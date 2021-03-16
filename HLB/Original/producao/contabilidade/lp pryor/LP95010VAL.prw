#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar saldo do adiantamento POSITIVO.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 12/05/2010
*/                         

User Function LP95010VAL()       

Local nValor:=nAdiant:=nTotDesp:=nSaldo:=0   
Local cHawb := ''

     
IF alltrim(SD1->D1_TIPO) == "C"
   SWN->(DbSetOrder(2))
   If SWN->(DbSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE))    
      If SWD->(DbSeek(xFilial("SWD")+SWN->WN_HAWB))
         While SWD->(!EOF()) .And. SWD->WD_HAWB==SWN->WN_HAWB 
            If !(SWD->WD_DESPESA $ "101/102/103") 
               
               If SWD->WD_DESPESA=="901"
                  nAdiant+=SWD->WD_VALOR_R
               Else   
                 nTotDesp+=SWD->WD_VALOR_R   
               EndIf
                 cHawb := SWD->WD_HAWB    
            Endif  
         
            SWD->(DbSkip())
         EndDo                           
         
         SWN->(DbGoTop())
         SWN->(DbSetOrder(3))
         //WN_FILIAL+WN_HAWB+WN_TIPO_NF                                                                                                                                    
         If SWN->(DbSeek(xFilial("SWN")+ cHawb + '1'))    
            nTotDesp += SWN->WN_VLACRES - SWN->WN_VLDEDUC
         EndIf
         
         nValor:= nAdiant - nTotDesp
                
      Endif
   EndIf                                                                                                                                                              
EndIf


Return(nValor)