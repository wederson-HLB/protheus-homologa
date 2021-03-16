#include 'totvs.ch'
/*
Funcao      : SUEST007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função que sobrepõem o cálculo do desconto do campo C6_DESCONT
Autor       : Consultoria Totvs
Data/Hora   : 10/11/2015
Obs         :
Revisão     : João Silva
Data/Hora   : 10/11/2015
Módulo      : Faturamento.
Cliente     : Exeltis
*/

User Function  SUEST007()
	
	Local nRet 		:= 0
	Local nX 		:= n
	Local nValBrut	:= 0
	Local nQtdVen	:= 0
	Local nPosPD1   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO1"})
	Local nPosD1	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALDES1"})
	Local nPosPD2   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_XDESCO2"})
	Local nPosPD3   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_DESCONT"})
	Local nPosQtdV 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_QTDVEN"})
	Local nPosVlTb 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRUNIT"})
	Local nDesc1	:= 0
	Local nDesc2	:= 0
	
	If !GdDeleted(nX) .and. !Empty(aCols[nX][nPosD1])
		nValBrut 	:= (aCols[nX][nPosQtdV])*(aCols[nX][nPosVlTb])
		nQtdVen  	:= aCols[nX][nPosQtdV]
		nDesc1 		:=  nValBrut * (((aCols[nX][nPosPD1])/100))
		nDesc2 		:= (nValBrut - nDesc1)*(((aCols[nX][nPosPD2])/100))
		nRet 		:= (nValBrut - nDesc1-nDesc2)*(((aCols[nX][nPosPD3])/100)) 
	Endif
	
Return (nRet)
