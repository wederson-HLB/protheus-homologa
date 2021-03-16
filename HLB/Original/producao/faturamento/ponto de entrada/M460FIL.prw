#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M460FIL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : O ponto de entrada M460FIL será utilizado antes da execução da Indregua na seleção da Markbrowse.
			  Na versão DBAccess (Top Connect) deve ser utilizado o ponto de entrada M460QRY.
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function M460FIL
*-------------------------*
Local _cRet 	:= ''
Local _lConfFis := .F.

If cEmpAnt $ "SU/LG"
    // MSM - 06/01/2015 - Adicionado tratamento da consultoria da totvs - Chamado: 023393
	_lConfFis := GetMv("MV_CONFFIS") == "S"

	If _lConfFis
		_cRet := 'POSICIONE("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_P_STACO") $ " 3"'
	//RRP - 11/09/2017 - Ajuste pois se existe esse ponto de entrada o fonte padrão inclui um .AND.
	Else
		Return "1=1"
	EndIf

Else
	//RRP - 27/08/2014 - Ajuste pois se existe esse ponto de entrada o fonte padrão inclui um .AND.
	Return "1=1"
EndIf

Return(_cRet)