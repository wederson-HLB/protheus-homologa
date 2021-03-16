
/*
Funcao      : MA010FIL
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. grava��o do produto para validar a visualiza��o do produto
Autor       : Tiago Luiz Mendon�a
Data/Hora   : 04/04/2009     
Obs         : 
TDN         : Function MATA010 - Fun��o principal do programa de inclus�o, altera��o e exclus�o de Produtos. No in�cio da Fun��o, antes de montar a tela de browse dos produtos; deve ser usado para adicionar um FILTRO para os registros do cadastro de produtos.
Revis�o     : 
Data/Hora   : 
Obs         : 
M�dulo      : Estoque.
Cliente     : Shiseido  
*/

*--------------------------*     
  User Function MA010FIL()
*--------------------------*     

Local cRet:="" 
                
Local cUserEmp1 := GetMv("MV_P_EMP01",,"")  // Usuarios Nars
Local cUserEmp2 := GetMv("MV_P_EMP02",,"")  // Usuarios Bare


If cEmpAnt $ "R7" 
	If  alltrim(cUserName) $ cUserEmp1     // cUserEmp1  Usu�rios Nars
		cRet:="B1_P_MULTB == '054' "    	
	ElseIf alltrim(cUserName) $ cUserEmp2  // cUserEmp2  Usu�rios BM
      cRet:="B1_P_MULTB == '064' "
	EndIf
EndIf

         
         
Return cRet         