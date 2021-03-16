#include "rwmake.ch"       

User Function 65523ICMCFOP()//EXCLUSAO DE DEVOLUÇÃO (SALTON  JA UTILIZA)


SetPrvt("_nRETORNO,_cCFOP")
  
_nRetorno:=0

_cCFOP   := "1201/2201/3201/1202/2202/3202/1203/2203/3203/"
_cCFOP   += "1410/2410/3410/1411/2411/3411"
                                                        
IF SF1->F1_DOC == SD1->D1_DOC   

   IF ALLTRIM(SD1->D1_CF) $ _cCFOP .AND. SD1->D1_TIPO $ "D/"
   
       _nRetorno:=SD1->D1_VALICM
   
   ENDIF
   
ENDIF

Return(_nRetorno)