
/*
Funcao      : UMATA456()
Objetivos   : Controle Liberacao Cred/Est para empresa Monavie.
Autor       : Tiago Luiz Mendonça
Data/Hora   : 20/10/2009
*/      

*---------------------------*
  User Function UMATA456()    
*---------------------------*

Local lControle

If cEmpAnt $ "MV"                               
   
   lControle:= GETMV("MV_P_LIBER")   
   
   If !(lControle)
      MsgAlert("Liberação manual não permitida.","Monavie - FIFO ")
   Else
      MATA456()
   EndIf  
    
Else
   MATA456()
EndIf      


Return 

*---------------------------*
   User Function UMATA455()
*---------------------------*   

Local lControle

If cEmpAnt $ "MV"  
   
   lControle:= GETMV("MV_P_LIBER")   
   
   If !(lControle)
      MsgAlert("Liberação manual não permitida.","Monavie - FIFO ")
   Else
      MATA455()
   EndIf  
    
Else
  MATA455()
EndIf      

Return 

