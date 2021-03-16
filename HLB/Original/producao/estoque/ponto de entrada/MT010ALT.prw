/*
Funcao      : MT010ALT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. altera��o - cadastro de produtos
Autor     	: Wederson L. Santana 	
Data     	: 06/02/06
Obs         : 
TDN         : Ap�s alterar o Produto, este Ponto de Entrada nem confirma nem cancela a opera��o, deve ser utilizado para gravar arquivos/campos do usu�rio, complementando a altera��o.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/03/2012
M�dulo      : Faturamento.    
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
Objetivos   : Altera��o do produto limpar o campo B1_P_STATS
Autor       : Tiago Luiz Mendon�a
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