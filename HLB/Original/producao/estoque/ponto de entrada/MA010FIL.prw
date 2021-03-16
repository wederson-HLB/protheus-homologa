
/*
Funcao      : MA010FIL
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. gravação do produto para validar a visualização do produto
Autor       : Tiago Luiz Mendonça
Data/Hora   : 04/04/2009     
Obs         : 
TDN         : Function MATA010 - Função principal do programa de inclusão, alteração e exclusão de Produtos. No início da Função, antes de montar a tela de browse dos produtos; deve ser usado para adicionar um FILTRO para os registros do cadastro de produtos.
Revisão     : 
Data/Hora   : 
Obs         : 
Módulo      : Estoque.
Cliente     : Shiseido  
*/

*--------------------------*     
  User Function MA010FIL()
*--------------------------*     

Local cRet:="" 
                
Local cUserEmp1 := GetMv("MV_P_EMP01",,"")  // Usuarios Nars
Local cUserEmp2 := GetMv("MV_P_EMP02",,"")  // Usuarios Bare


If cEmpAnt $ "R7" 
	If  alltrim(cUserName) $ cUserEmp1     // cUserEmp1  Usuários Nars
		cRet:="B1_P_MULTB == '054' "    	
	ElseIf alltrim(cUserName) $ cUserEmp2  // cUserEmp2  Usuários BM
      cRet:="B1_P_MULTB == '064' "
	EndIf
EndIf

         
         
Return cRet         