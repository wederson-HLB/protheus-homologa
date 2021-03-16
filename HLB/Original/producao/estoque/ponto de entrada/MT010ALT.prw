/*
Funcao      : MT010ALT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. alteração - cadastro de produtos
Autor     	: Wederson L. Santana 	
Data     	: 06/02/06
Obs         : 
TDN         : Após alterar o Produto, este Ponto de Entrada nem confirma nem cancela a operação, deve ser utilizado para gravar arquivos/campos do usuário, complementando a alteração.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.    
Cliente     : Sector / Reddys
*/

*-------------------------*
  User Function MT010ALT()     
*--------------------------* 

If cEmpAnt $ "IZ"
   Reclock("SB1",.F.)
   Replace SB1->B1_P_LOG With ""
   MsUnlock()
Endif   


/*
Objetivos   : Alteração do produto limpar o campo B1_P_STATS
Autor       : Tiago Luiz Mendonça
Data/Hora   : 04/11/08
*/
           
If cEmpAnt $ "U2" 
   
   If SB1->(FieldPos("B1_P_STATS")) > 0  
      Reclock("SB1",.F.)
      SB1->B1_P_STATS := ""
      MSUnlock()
   EndIf
   
EndIf

Return