#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : MA440GRLT
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :  
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : Este ponto de entrada pertence à rotina de gravacao da liberacao do pedido de Venda - FATXFUN. 
			  Ele permite que  se movimente o estoque antes da selecao Lote X Localização física.
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
 User Function MA440GRLT
*-------------------------* 
Local _aArea,_aAreaF4,_aAreaC6

If cEmpAnt $ "SU/LG"  
	
	_aArea := GetArea()
	_aAreaF4 := SF4->(GetArea())
	_aAreaC6 := SC6->(GetArea())	

	// MSM - 06/01/2015 - Adicionado tratamento da consultoria da totvs - Chamado: 023393
	If SC5->C5_TIPO == "N"
		SC6->(dbSetOrder(1))
		SF4->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial()+SC5->C5_NUM))
			If SF4->(dbSeek(xFilial()+SC6->C6_TES))
				If SF4->F4_ESTOQUE == 'S'
					SC5->C5_P_STACO := "1"
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(_aAreaC6)
	RestArea(_aAreaF4)
	RestArea(_aArea)	
	
EndIf

Return