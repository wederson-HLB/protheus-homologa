
/*
Funcao      : CTB102EXC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para validar a exclus�o do lan�amento contab�l 
Autor     	: Tiago Luiz Mendon�a
Data     	: 03/12/2012                       
Obs         : FUNCAO PADRAO CTBA102
TDN         :O ponto de entrada CTB102EXC ser� utilizado ap�s a exclus�o do lan�amento cont�bil.
Revis�o     : 
Data/Hora   : 
M�dulo      : Contabil. 
Cliente     : Paypal
*/

*-------------------------*
 User Function CTB102EXC()
*--------------------------* 

Local lRet := .T.
                                    
If cEmpAnt $ "PD/PB/7W"

	If Alltrim(CT2->CT2_P_ARQ ) <> ""
		MsgStop("Esse lan�amento n�o pode ser apagado, ele est� vinculado h� um arquivo gerado para o cliente.","Paypal")
		lRet:=.F.
	EndIf        

EndIf

Return lRet