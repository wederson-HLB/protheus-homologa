
/*
Funcao      : Valida��o do fornecedor
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 26/01/10
*/
 
 /*
Funcao      : MA020TOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada para valida��o do fornecedor
Autor     	: Tiago Luiz Mendon�a
Data     	: 26/01/10
TDN         : Fun��o de valida��o da digita��o, na inclus�o, altera��o ou exclus�o do Fornecedor.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 13/03/2012
M�dulo      : Estoque.
*/    



*---------------------------*
  User Function MA020TOK() 
*---------------------------*  

Local lRet:=.T. 

If cEmpAnt $ "SG"

   If M->A2_TIPO $ ("J/F") .Or. Empty(M->A2_TIPO)
      If Empty(M->A2_CGC) 
         MsgStop("Campo CNPJ/CPF deve ser preechido","Uniduto")   
         lRet:=.F. 
      Else
         lRet:=.T.           
      EndIf
   EnDIf   
                   
EndIf


Return lRet