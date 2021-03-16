#include "rwmake.ch"     

/*
Funcao      : Lançamento padrão de Importação(EIC).
Objetivos   : Retornar o estorno da Baixa de Adiantamento
Autor       : Tiago Luiz Mendonça
Data/Hora   : 03/07/08
*/

User Function LP9508VAL()       

Local nResult:=0
Local cCfoP,cTes
     
//cTes := "1B6/1B7/1B8/1C1/1C2/1C3/1C4/1C5/1C6/1C7/1C8/1C9"             
cCfoP:= "3101/3102/3949"

IF alltrim(SD1->D1_CF) $ (cCfoP) 
   If alltrim(SD1->D1_TIPO) == "C"
      SWN->(DbSetOrder(2))
      If SWN->(DbSeek(xFilial("SWN")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE))    
         While SWN->(!EOF()) .And. xFilial("SWN")+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE == SD1->D1_FILIAL+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE 
            nResult+=SWN->WN_VLDEVII+SWN->WN_VLDEIPI+SWN->WN_VL_ICM+SWN->WN_VLRPIS+SWN->WN_VLRCOF+SWN->WN_DESPADU+SWN->WN_DESPICM+SWN->WN_SEGURO+SWN->WN_FRETE+SWN->WN_VLACRES-SWN->WN_VLDEDUC
            //nResult+=SWN->WN_VLDEVII+SWN->WN_VLDEIPI+SWN->WN_VL_ICM+SWN->WN_VLRPIS+SWN->WN_VLRCOF+SWN->WN_DESPADU+SWN->WN_DESPICM+SWN->WN_VLACRES-SWN->WN_VLDEDUC
            SWN->(DbSkip())
         EndDo
      EndIf
   EndIf
EndIf

Return(nResult)

