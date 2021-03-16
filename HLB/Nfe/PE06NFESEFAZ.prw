#include "totvs.ch"

/*
Funcao      : PE06NFESEFAZ
Parametros  : Nenhum
Retorno     : aRet
Objetivos   : P.E. para tratamento do ICMSST - TAG vBCSTRet e vICMSSTRet
Autor       : Renato Rezende
Data/Hora   : 07/11/2017
Módulo      : Faturamento
Cliente		: Todos
*/
*------------------------------*
 User Function PE06NFESEFAZ()
*------------------------------*
Local aAreaSA1	:= {}
Local aRet		:= {}
Local cEntSai	:= ""
Local cQuery	:= ""

Local nBaseIcm	:= ParamIXB[01]
Local nValICM	:= ParamIXB[02]
Local aProd		:= ParamIXB[03]
Local aNota		:= ParamIXB[04] 


If AllTrim(aNota[4]) == "1"
	cEntSai := "S" //Saída
Else
	cEntSai := "E" //Entrada
EndIf

//Shiseido
If cEmpAnt == "R7"

	If cEntSai == "S" //Nf de Saida
        
		//Tratamento de ICMS ST
		aAreaSA1  := SA1->(GetArea())
		
		If Select("SQLD2") > 0 
			SQLD2->(DbCloseArea())
		EndIf

		//Posiciona no SA1, pois está desposicionado. 
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		
		cQuery:= "SELECT * FROM "+RetSqlName("SD2")+" WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '"+xFilial("SD2")+"' " +CRLF
		cQuery+= "   AND D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_LOTECTL = '"+aNota[2]+aNota[1]+SA1->A1_COD+SA1->A1_LOJA+aProd[2]+aProd[19]+"' " +CRLF
		cQuery+= "   AND D2_QUANT = "+Alltrim(cValToChar(aProd[9]))+" AND D2_ITEMPV = '"+aProd[39]+"' AND D2_PEDIDO = '"+aProd[38]+"'  " 
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "SQLD2", .F., .T.)
		
		//Contando resultado da Query
		Count to nRecCount
		
		SQLD2->(DbGoTop())
		
		//Retornou resultado na Query
		If nRecCount > 0
			//Verifica se os campos customizados existem
			If SD2->(FieldPos("D2_P_IVABS")) > 0 .And. SD2->(FieldPos("D2_P_IVAVL")) > 0
				If Alltrim(SQLD2->D2_CF) $ '5405'.and. SQLD2->D2_LOCAL <> '06'
					nBaseIcm	:= SQLD2->D2_P_IVABS/SQLD2->D2_QUANT
					nValICM		:= SQLD2->D2_P_IVAVL/SQLD2->D2_QUANT
				EndIf
			EndIf
		EndIf

		If Select("SQLD2") > 0 
			SQLD2->(DbCloseArea())
		EndIf
		
		RestArea(aAreaSA1)

	EndIf
EndIf

//Gravação do retorno
aadd(aRet,nBaseIcm)
aadd(aRet,nValICM)
aadd(aRet,aProd)
aadd(aRet,aNota)

Return aRet