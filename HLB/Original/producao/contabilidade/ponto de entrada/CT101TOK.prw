#Include 'Protheus.ch'

/*
Funcao      : CT101TOK
Parametros  : 
Retorno     : Logico .F. interrompe .L. continua
Objetivos   : P.E. para controle de atualizacao/exclusao/estorno de lancamento contabil 
Autor       : Daniel Fonseca de Lira
Data        : 12/12/2012                       
Obs         : O P.E. padrao para lancamentos manuais
TDN         : Nao tem pagina para o ponto, consultar chamado TGFTSM
Revis�o     : 
Data/Hora   : 11:29
M�dulo      : Contabil 
Cliente     : Paypal
*/

*----------------------*
User Function CT101TOK()
*----------------------*
	Local lRet := .T.
	
	If cEmpAnt $ "PD/PB/7W"
		If AllTrim(Str(ParamIXB[11])) $ '4/5/6' // Alteracao, Exclusao, Estorno
			If Alltrim(CT2->CT2_P_GER) == "S"
				MsgStop("Esse lan�amento n�o pode ser manipulado, ele est� vinculado h� um arquivo gerado para o cliente.","Paypal")
				lRet:=.F.
			EndIf
		EndIf
	EndIf
Return lRet