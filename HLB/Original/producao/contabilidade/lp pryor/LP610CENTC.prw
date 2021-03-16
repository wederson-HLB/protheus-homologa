
/*
Funcao      : LP610CENTC
Objetivos   : Buscar centro de custo contabil no item do pedido 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 10/03/10
*/
           

*----------------------------*
  User Function LP610CENTC()
*----------------------------*   

local cRet:=""
                      
If cEmpAnt $ "48/49"   //DISCOVERY
   
   cRet:=SB1->B1_CC

EndIf    

Return cRet



