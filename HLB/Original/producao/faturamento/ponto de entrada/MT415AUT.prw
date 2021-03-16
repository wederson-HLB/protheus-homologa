
/*
Funcao      : MT415AUT 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetivação do pedido
Autor       : Tiago Luiz Mendonça 
Data/Hora   : 16/09/2014     
Obs         : 
TDN         : P.E. Executado apos a efitavação do orçamento
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Faturamento.
Cliente     : Victaulic
*/

*-------------------------*
 User Function MT415AUT()
*-------------------------*
           
Local lRet:=.T.        
        
If cEmpAnt == "TM"

	If SCJ->CJ_P_REV  <> "S" 
    	MsgStop("Esse orçamento ainda não foi revisado, não pode ser efetivado.","Victaulic")                    
        lRet:=.F. 
	EndIf

Endif   

Return lRet