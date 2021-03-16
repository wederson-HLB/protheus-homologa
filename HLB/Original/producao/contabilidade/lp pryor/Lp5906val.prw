#include "rwmake.ch"        
User Function Lp5906val()        

SetPrvt("_cValor")
_cValor  :=0
_cNumCheq:=SE2->E2_NUMBCO
SE5->(DbSetOrder(7))     
If SE5->(DbSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA))
   While xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA == SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA
        
        If AllTrim(SE5->E5_TIPODOC) $ "BA".AND.AllTrim(SE5->E5_LA) $ "S".AND._cNumCheq == SE5->E5_NUMCHEQ .AND. SE5->E5_PRETCOF==" " .AND. SE5->E5_PRETCSL==" " .AND. SE5->E5_PRETPIS==" "
           
           _cValor:= SE5->E5_VRETPIS 
                      
        Endif   
        SE5->(DbSkip())
   End     
Endif   

Return(_cValor) 
        
