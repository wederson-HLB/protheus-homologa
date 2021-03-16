#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 03/07/01

/*
Funcao      : 48PLAT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Manutencao do Cadastro Plataforma   
Autor     	: 
Data     	: 
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Faturamento.
*/

*-----------------------*
 User Function 48PLAT()   
*-----------------------*
     
If cEmpAnt $ "48/49"

   axcadastro("SZ8","Manutencao do Cadastro Plataforma",".t.",".t.")

Else
  
   MsgAlert("Essa rotina n�o pertence a essa empresa.","Aten��o ")

EndIf       

*-----------------------*
 User Function 48BRAND()       
*-----------------------*
   
If cEmpAnt $ "48/49"

   axcadastro("SZ9","Manutencao do Cadastro Brand",".t.",".t.")

Else
  
   MsgAlert("Essa rotina n�o pertence a essa empresa.","Aten��o ")

EndIf 


Return  
