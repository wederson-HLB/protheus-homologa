#INCLUDE "PROTHEUS.CH"

/*
Funcao      : F050MDVC
Parametros  : ParamIxb
Retorno     : dNextDay
Objetivos   : Alterar a data de vencimento dos t�tulos de PCC, para o dia 20 do pr�ximo m�s, caso n�o sendo dia �til, antecipar a data.
TDN			: O ponto de entrada F050MDVC possibilita que o cliente calcule sua pr�pria data de vencimento de �mpostos.
Autor       : Matheus Massarotto
Revis�o	    :
Data/Hora   : 01/07/2015  15:56
M�dulo      : Financeiro
*/                      

*----------------------*
User function F050MDVC()
*----------------------*
Local dNextDay := ParamIxb[1] 
//data calculada pelo sistema
Local cIMposto := ParamIxb[2]
Local dEmissao := ParamIxb[3]
Local dEmis1 := ParamIxb[4]
Local dVencRea := ParamIxb[5]
Local nNextMes := Month(dVencRea)+1

//Novas Regras de Reten��o PIS-COFINS-CSLL - Lei 13.137/2015, publicado no DOU em 22/06/2015.
//A partir do dia 22/06 a data de apura��o(vencimento) passa a ser o �ltimo dia �til do segundo desc�ndio do m�s subsequente 

If cImposto $ "PIS,CSLL,COFINS"
	//Calcula data 20 do pr�ximo mes 
	dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+; 
	Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2))

	//Acho o ultimo dia �til do periodo desejado 
	dNextday := DataValida(dNextday,.F.)
EndIf 

Return dNextDay