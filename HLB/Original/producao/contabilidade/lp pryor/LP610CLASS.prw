
/*
Funcao      : LP610ENTD
Objetivos   : Buscar classe de valor contabil no pedido 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 10/03/10
*/
           

*----------------------------*
  User Function LP610CLASS()
*----------------------------*   

local cRet:=""
                      
If cEmpAnt $ "48/49"   //DISCOVERY
  
   SC6->(DbSetOrder(1))

   If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
      If !Empty(SC6->C6_P_VLC_C) // Caso não encontre o item credito, pega o debito.
         cRet:=Alltrim(SC6->C6_P_VLC_C)  
      Else
         cRet:=Alltrim(SC6->C6_P_VLC_D)
      EndIf
   EndIf

EndIf    

Return cRet



