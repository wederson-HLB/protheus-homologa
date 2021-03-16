
/*
Funcao      : CTB101EXC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para validar a exclusão do lançamento contabíl 
Autor     	: Tiago Luiz Mendonça
Data     	: 03/12/2012                       
Obs         : FUNCAO PADRAO CTBA101
TDN         :O ponto de entrada CTB101EXC será utilizado após a exclusão do lançamento contábil.
Revisão     : 
Data/Hora   : 
Módulo      : Contabil. 
Cliente     : Paypal
*/

*-------------------------*
 User Function CTB101EXC()
*--------------------------* 

Local lRet := .T.
                                    
If cEmpAnt $ "PD/PB/7W"

	If Alltrim(CT2->CT2_P_ARQ ) <> ""
		MsgStop("Esse lançamento não pode ser apagado, ele está vinculado há um arquivo gerado para o cliente.","Paypal")
		lRet:=.F.
	EndIf        

EndIf	


Return lRet