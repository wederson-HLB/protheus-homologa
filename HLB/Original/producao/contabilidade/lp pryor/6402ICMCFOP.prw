#include "rwmake.ch"       

User Function 6402ICMCFOP()

SetPrvt("_nRETORNO,_cCFOP")
  
_nRetorno:=0   

lEasy     := SuperGetMV("MV_EASY") == "S"

_cCFOP   := "1201/2201/3201/1202/2202/3202/1203/2203/3203/"
_cCFOP   += "1410/2410/3410/1411/2411/3411/1949/2949"
                                                        
//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF SF1->F1_DOC == SD1->D1_DOC .AND. SD1->D1_ITEM == '0001'//AOA - 29/04/2016 - Comparar apenas o item 1 e assim não mutiplicar o valor.   

      IF ALLTRIM(SD1->D1_CF) $ _cCFOP .AND. SD1->D1_TIPO $ "D/"
   
         _nRetorno:=SF1->F1_VALICM
   
      ENDIF
   
   ENDIF   
   
EndIf

Return(_nRetorno)