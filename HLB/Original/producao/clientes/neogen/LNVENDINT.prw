
/*
Funcao      : LNVendInt
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de vendendores internos
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 01/07/09
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 07/02/2012
M�dulo      : Faturamento.
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
