
/*
Funcao      : MT415AUT 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetiva��o do pedido
Autor       : Tiago Luiz Mendon�a 
Data/Hora   : 16/09/2014     
Obs         : 
TDN         : P.E. Executado apos a efitava��o do or�amento
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/02/2012
Obs         : 
M�dulo      : Faturamento.
Cliente     : Victaulic
*/

*-------------------------*
 User Function MT415AUT()
*-------------------------*
           
Local lRet:=.T.        
        
If cEmpAnt == "TM"

	If SCJ->CJ_P_REV  <> "S" 
    	MsgStop("Esse or�amento ainda n�o foi revisado, n�o pode ser efetivado.","Victaulic")                    
        lRet:=.F. 
	EndIf

Endif   

Return lRet