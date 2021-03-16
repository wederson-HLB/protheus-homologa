
/*
Funcao      : LNVendInt
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de vendendores internos
Autor       : Tiago Luiz Mendonça
Data/Hora   : 01/07/09
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 07/02/2012
Módulo      : Faturamento.
*/ 


*----------------------------*
  User Function LNVENDINT()
*----------------------------*  

If cEmpAnt $ "40/LN/99"
   AxCadastro("ZZ1","Cadastro de vendendor interno",".T.",".T.")
Else
   MsgStop("Especifico Neogen","Pryor")
EndIf   
   
   
Return 
