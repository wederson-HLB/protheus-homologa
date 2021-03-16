#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M410PVNF
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Executado antes da rotina de geração de NF's 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : Executado antes da rotina de geração de NF's (MA410PVNFS()).
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function M410PVNF
*-------------------------*
Local _lRet 	:= .T.
Local _lConfFis := .F.

If cEmpAnt $ "SU/LG"

	// MSM - 06/01/2015 - Adicionado tratamento da consultoria da totvs - Chamado: 023393
	_lConfFis := GetMv("MV_CONFFIS") == "S"
	
	//1=Nao Conferido;2=Em Conferencia;3=Conferido;4=Com Divergencia
	If _lConfFis .AND. SC5->C5_TIPO == "N"
		If !(SC5->C5_P_STACO $ " 3")
			_lRet := .F.
			If SC5->C5_P_STACO == "1"
				MsgStop("Pedido aguardando conferencia.")
			ElseIf SC5->C5_P_STACO == "2"
				MsgStop("Pedido em processo conferencia.")
			ElseIf SC5->C5_P_STACO == "4"
				MsgStop("Pedido conferido com divergencias.")
			EndIf
		EndIf
	EndIf
	
EndIf

Return(_lRet)
