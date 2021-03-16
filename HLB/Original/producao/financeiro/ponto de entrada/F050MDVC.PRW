#INCLUDE "PROTHEUS.CH"

/*
Funcao      : F050MDVC
Parametros  : ParamIxb
Retorno     : dNextDay
Objetivos   : Alterar a data de vencimento dos títulos de PCC, para o dia 20 do próximo mês, caso não sendo dia útil, antecipar a data.
TDN			: O ponto de entrada F050MDVC possibilita que o cliente calcule sua própria data de vencimento de ímpostos.
Autor       : Matheus Massarotto
Revisão	    :
Data/Hora   : 01/07/2015  15:56
Módulo      : Financeiro
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

//Novas Regras de Retenção PIS-COFINS-CSLL - Lei 13.137/2015, publicado no DOU em 22/06/2015.
//A partir do dia 22/06 a data de apuração(vencimento) passa a ser o último dia útil do segundo descêndio do mês subsequente 

If cImposto $ "PIS,CSLL,COFINS"
	//Calcula data 20 do próximo mes 
	dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+; 
	Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2))

	//Acho o ultimo dia útil do periodo desejado 
	dNextday := DataValida(dNextday,.F.)
EndIf 

Return dNextDay