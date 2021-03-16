#include "rwmake.ch"       

User Function 6401VLCFOP()

SetPrvt("_nRETORNO,_cCFOP")
  
_nRetorno:=0

//lEasy     := SuperGetMV("MV_EASY") == "S"

_cCFOP   := "1201/2201/3201/1202/2202/3202/1203/2203/3203/"
_cCFOP   += "1410/2410/3410/1411/2411/3411/1124/2949/1949"

//If !lEasy                                                        
If EMPTY(SD1->D1_CONHEC)

   IF SF1->F1_DOC == SD1->D1_DOC   
    
      IF ALLTRIM(SD1->D1_CF) $ _cCFOP .AND. SD1->D1_TIPO $ "D/B"
                                                                                

         //_nRetorno:=SF1->F1_VALMERC+SF1->F1_VALIPI-SF1->F1_FRETE+SF1->F1_ICMSRET
         //RRP - 01/09/2015 - Ajuste no cálculo do desconto. Chamado 029057 
         _nRetorno:=(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_VALFRE+SD1->D1_ICMSRET)-SD1->D1_VALDESC
   
      ENDIF
   
   ENDIF
   
EndIf

Return(_nRetorno)

