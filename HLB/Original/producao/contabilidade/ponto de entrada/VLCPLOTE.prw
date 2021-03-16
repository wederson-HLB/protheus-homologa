#Include 'Protheus.ch'

/*
Funcao      : VLCPLOTE
Parametros  : 
Retorno     : Logico .F. interrompe .L. continua
Objetivos   : P.E. para controle de atualizacao/exclusao/estorno de lancamento contabil automatico
Autor       : Daniel Fonseca de Lira
Data        : 12/12/2012 11:29
Obs         : O P.E. padrao para lancamentos automaticos
TDN         : O ponto de entrada VLCPLOTE é utilizado para verificar se o lançamento poderá ser alterado ou não.
Revisão     : Tiago Luiz Mendonça
Data/Hora   : 29/01/2013
Módulo      : Contabil
Cliente     : Paypal
*/

*----------------------*
User Function VLCPLOTE()
*----------------------*
	Local lRet := .T.
	
	If cEmpAnt $ "PD/PB/7W"
		If AllTrim(Str(ParamIXB[5])) $ '4/5/6' // Apenas exclusao e extorno lote
			If Alltrim(CT2->CT2_P_ARQ ) <> ""
				MsgStop("Esse lançamento não pode ser manipulado, ele está vinculado há um arquivo gerado para o cliente.","Paypal")
				lRet:=.F.
			EndIf
		EndIf
	EndIf
Return lRet