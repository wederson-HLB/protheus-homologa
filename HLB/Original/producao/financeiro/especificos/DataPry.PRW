
/*
Funcao      : DataPry
Parametros  : dData, lBarra, nFormato
Retorno     : xData
Objetivos   : Determinado forma de grava‡„o para campo data,Modificado equipe pryor baseado no original para tratar as "/" by Hamilton/Francisco
Parametros  : ExpD1 := Data a ser convertida
			  ExpL1 := Tipo(Se .T. com Barra, se .F., sem Barra
			  ExpN1 := Formato (1,2,3)
			  Formato 1 := ddmmaa
			  2 := mmddaa
			  3 := aaddmm
			  4 := aammdd
			  5 := ddmmaaaa
			  6 := mmddaaaa
			  7 := aaaaddmm
			  8 := aaaammdd
Autor       : Wagner Xavier
Data/Hora   : 26/05/1992   10:52
Revisão		: Matheus Massarotto
Data/Hora   : 13/11/2012
Módulo      : Financeiro
*/


*-----------------------------------------------*
User Function DataPry ( dData, lBarra, nFormato )
*-----------------------------------------------*
Local lSepar
Local xData 	:= dData

dData   := Iif( dData==Nil,dDataBase,dData )
lBarra  := Iif( lBarra==Nil,.T.,lBarra )
nFormato:= Iif( nFormato==Nil,1,nFormato )
cSepar  := Iif( lBarra,"/","" )

//If !lBarra
	Do Case
		Case nFormato == 1
			xData := StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)+cSepar+SubStr(StrZero(Year(dData),4),3,2)
		Case nFormato == 2
			xData := StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)+cSepar+SubStr(StrZero(Year(dData),4),3,2)
		Case nFormato == 3
			xData := SubStr(StrZero(Year(dData),4),3,2)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)
		Case nFormato == 4
			xData := SubStr(StrZero(Year(dData),4),3,2)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)
		Case nFormato == 5
			xData := StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Year(dData),4)
		Case nFormato == 6
			xData := StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Year(dData),4)
		Case nFormato == 7
			xData := StrZero(Year(dData),4)+cSepar+StrZero(Day(dData),2)+cSepar+StrZero(Month(dData),2)
		OtherWise
			xData := StrZero(Year(dData),4)+cSepar+StrZero(Month(dData),2)+cSepar+StrZero(Day(dData),2)
	EndCase
//End
Return xData