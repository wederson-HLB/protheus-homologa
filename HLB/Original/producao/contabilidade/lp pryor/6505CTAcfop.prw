#include "rwmake.ch"        


User Function 6505CTAcfop()       // Incluído em 28/09/09


SetPrvt("_VALRESULT,")


_vConta:=0


_cCFOP1 :=  "1911/2911"

_cCFOP2 :=  "1911/2911/1912/2912/1917/2917/1949/2949"/*"1151/2151/1152/2152/3101/3102*/

_cCfop3 :=  "1351/2351/1352/2352/1353/2353"  

_cCfop4 :=  "1910/2910"        

_cCfop5 :=  "3101/3102"                                  //IMPORTAÇÃO


IF ALLTRIM(SD1->D1_CF) $ (_cCFOP1)

	_vConta:=511136365 
	
ELSEIF ALLTRIM(SD1->D1_CF) $ (_cCFOP2) .AND. SF4->F4_PODER3 == 'N'
	
    _vConta:=411112143        
    

ELSEIF ALLTRIM(SD1->D1_CF) $ (_cCFOP3) .And. SF4->F4_LFICM $ 'T'//.AND. SF4->F4_CREDICM == 'N'

	_vConta:=511128294    
	
	
ELSEIF ALLTRIM(SD1->D1_CF) $ (_cCFOP4) .And. SF4->F4_LFICM $ 'T'

	_vConta:=511136363    
	
ELSEIF ALLTRIM(SD1->D1_CF) $ (_cCFOP5) .AND. SF4->F4_PODER3 == 'N'
	
    _vConta:=112224007 	
    
ELSE    
    _vConta:=121110006
	
ENDIF


Return(_vConta)
