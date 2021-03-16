
/*
Funcao      : Validação do fornecedor
Autor       : Tiago Luiz Mendonça
Data/Hora   : 26/01/10
*/
 
 /*
Funcao      : MA020TOK
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada para validação do fornecedor
Autor     	: Tiago Luiz Mendonça
Data     	: 26/01/10
TDN         : Função de validação da digitação, na inclusão, alteração ou exclusão do Fornecedor.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Estoque.
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