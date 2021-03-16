 
/*
Funcao      : LP610ENTD
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Buscar item contabil no pedido -  Especifico WDF/ALPUNTO    
Autor     	: Tiago Luiz Mendonça
Data     	: 22/10/09 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Contabilidade.
*/
   
   
*----------------------------*
  User Function LP610ENTD()
*----------------------------*   

local cRet:=""
                      
If cEmpAnt $ "S8/S9/"   //WDF
  
   SC5->(DbSetOrder(1))

   If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
      cRet:=Alltrim(SC5->C5_P_REFNB)
   EndIf

EndIf 

If cEmpAnt $ "HO/LP/07"   //ALPUNTO, HARRIS, ENGECORPS
  
   SC5->(DbSetOrder(1))

   If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
      cRet:=Alltrim(SC5->C5_P_ITEMC)
   EndIf

EndIf 

If cEmpAnt $ "48/49/50"   //DISCOVERY         

   //If Substr(M->CT2_CREDIT,1,1) $ ("12") .OR. Substr(M->CT2_DEBITO,1,1) $ ("12")  
   //   cRet:="9910"
   //Else 
      SC6->(DbSetOrder(1))                    
      If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
         //If !Empty(SC6->C6_P_ITEMC) // Caso não encontre o item credito, pega o debito.
            cRet:=Alltrim(SC6->C6_P_ITEMC)  
         //Else
         //   cRet:=Alltrim(SC6->C6_P_ITEMD)
         //EndIf
      EndIf   
   //EndIf
EndIf  

If cEmpAnt $ "Z4"  // Pryor

   If Alltrim(SF2->F2_SERIE)== "ND" 
      cRet:=SA1->A1_COD
   EndIf       

EndIf


Return cRet



