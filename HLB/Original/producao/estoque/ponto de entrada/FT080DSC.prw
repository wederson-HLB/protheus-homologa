#include 'totvs.ch'
/*
Funcao      : FT080DSC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de Entrada que permite customizar o desconto aplicado com base nas informações provenientes do cabeçalho do pedido de vendas.
Autor       : Consultoria Totvs
Data/Hora   : 10/11/2015
Obs         :
Revisão     : João Silva
Data/Hora   : 10/11/2015
Módulo      : Faturamento.
Cliente     : Exeltis
*/
User Function FT080DSC()

Local nPrcVen 	:= ParamIXB[2]
Local nPrcLista := ParamIXB[1]
Local nVal 		:= 0
Local nVal1 	:= 0
Local nValBrut	:= 0
Local nQtdVen	:= 0
Local nValTotal := 0
Local nPerc1 	:= 0
Local nPerc2 	:= 0
Local nPerc3 	:= 0
local nDesc1 	:= 0
Local nDesc2 	:= 0
Local nPosVlUn  := 0
Local nPosVlTo  := 0
Local nPosQtdV 	:= 0
Local nPosVlTb 	:= 0
Local nPosPD3   := 0
Local nPosVD3   := 0

If cEmpAnt $ "SU/LG"
	
	nDesc1 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO1"})
	nDesc2 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO2"})
	nPosVlUn	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN"})
	nPosVlTo	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALOR"})
	nPosQtdV	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_QTDVEN"})
	nPosVlTb	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRUNIT"})
	nPosPD3 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_DESCONT"})
	nPosVD3 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALDESC"})
	
	If Len(aCols) != 0
		nX := n
	EndIf
	
	If Len(aCols) != 0
		nX := n
	EndIf
	
	IF M->C5_DESC1 == 0 .and. !Empty(aCols[nX][nDesc1]) .and. !GdDeleted(nX)
		If altera
			nQtdVen:= aCols[nX][nPosQtdV]
			nVal := nPrcLista * (1-(aCols[nX][nDesc1]/100))
			nVal1 := nVal * (1-(aCols[nX][nDesc2]/100))
			nPrcVen := nVal1* (1 -(aCols[nX][nPosPD3]/100))
		Else
			nQtdVen:= aCols[nX][nPosQtdV]
			nVal := nPrcLista * (1-(aCols[nX][nDesc1]/100))
			nVal1 := nVal * (1-(aCols[nX][nDesc2]/100))
			nPrcVen := nVal1* (1 -(aCols[nX][nPosPD3]/100))
		EndIf
	EndIf
	
EndIf

Return nPrcVen




