#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M521DNFS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : Consultoria Totvs
Data/Hora   : 26/08/2014     
Obs         : 
TDN         : O ponto de entrada M521DNFS existente na função MaDelNfs será disparado após o fechamento dos lançamentos
			  contábeis onde o retorno deverá ser uma variável lógica. O ponto possui como parâmetro o Array aPedido.  
Revisão     : Renato Rezende
Data/Hora   : 26/08/2014
Módulo      : Faturamento.
Cliente     : Exeltis
*/
*-------------------------*
User Function M521DNFS
*-------------------------*

Local _aArea,_aAreaC5,_aAreaC9,_aPeds
Local _I := 0

If cEmpAnt $ "SU/LG"

	_aArea := GetArea()
	_aAreaC5 := SC5->(GetArea())
	_aAreaC9 := SC9->(GetArea())
	_aPeds := ParamIXB[1]
	_I := 0

	SC5->(dbSetOrder(1))
	SC9->(dbSetOrder(1))
	For _I := 1 To Len(_aPeds)
		If SC5->(dbSeek(xFilial()+_aPeds[_I])) .AND. SC5->C5_TIPO == "N"
			RecLock("SC5",.F.)
			If MV_PAR02==1 //Pedido volta para carteira
				SC5->C5_P_STACO := ""
			ElseIf MV_PAR02==2 //Pedido se mantem apto a faturar
				SC5->C5_P_STACO := "3"
				If SC9->(dbSeek(xFilial()+_aPeds[_I]))
					While !SC9->(EOF()) .AND. SC9->C9_FILIAL = SC5->C5_FILIAL .AND. SC9->C9_PEDIDO = SC5->C5_NUM
						If Len(AllTrim(SC9->C9_BLEST)) <= 0 .AND. Len(AllTrim(SC9->C9_BLCRED)) <= 0
							RecLock("SC9",.F.)
							SC9->C9_P_QTDCO := SC9->C9_QTDLIB
							SC9->(MsUnLock())
						EndIf
						SC9->(dbSkip())
					EndDo
				EndIf
			EndIf
			SC5->(MsUnLock())
		EndIf
	Next _I

	RestArea(_aAreaC5)
	RestArea(_aAreaC9)
	RestArea(_aArea)
EndIf

Return
