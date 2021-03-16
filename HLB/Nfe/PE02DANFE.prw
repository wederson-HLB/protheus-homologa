#INCLUDE "PROTHEUS.CH"

/*
Funcao      : PE02DANFE
Parametros  : {aAuxCabec, aAux, oDanfe, oFont08N:oFont, oFont07:oFont}
Retorno     : lRet
Objetivos   : P.E. para Customização do fonte padrão DanfeIII, altera tamanho das colunas dos itens
Autor       : Renato Rezende
Data/Hora   : 01/08/2018       	
Obs         : 
Módulo      : Faturamento.
Cliente     : Todos
*/

#DEFINE MAXBOXH   800 // Tamanho maximo do box Horizontal - DEFINE do fonte DANFEIII

*--------------------------*
 User Function PE02DANFE()
*--------------------------*
Local aCabec	:= ParamIXB[01]
Local aValores	:= ParamIXB[02]
Local oPrinter  := ParamIXB[03]
Local oFontCabec:= ParamIXB[04]
Local oFont		:= ParamIXB[05]

Local nAux		:= 0
Local nX		:= 0
Local nY		:= 0
Local aTamCol	:= {}
Local aRet		:= {}
Local lExterno	:= IsBlind()
Local lAltera	:= .F. 

If cEmpAnt $ "LG|N6"
	If lExterno
		lAltera:= lExterno
		For nX := 1 To Len(aCabec)
			
			AADD(aTamCol, {})
			aTamCol[nX] := Round(oPrinter:GetTextWidth(aCabec[nX], oFontCabec) * nConsNeg + 2, 0)
		Next nX
		
		For nX := 1 To Len(aValores[1])
			
			nAux := 0
			
			For nY := 1 To Len(aValores[1][nX])
				
				If (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 2) > nAux
					nAux := Round(oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 2, 0)
				EndIf
				
			Next nY
			
			If aTamCol[nX] < nAux
				aTamCol[nX] := nAux
			EndIf
			
		Next nX
		
		// Workaround para o método FWMSPrinter:GetTextWidth() na coluna UN
		aTamCol[6] += 5
		
		// Checa se os campos completam a página, senão joga o resto na coluna da
		//   descrição de produtos/serviços
		nAux := 0
		For nX := 1 To Len(aTamCol)
			
			nAux += aTamCol[nX]
			
		Next nX
		If nAux < MAXBOXH
			aTamCol[2] += MAXBOXH - 30 - nAux
		EndIf
		   	If nAux > MAXBOXH               
			aTamCol[2] -= nAux - MAXBOXH - 30
		EndIf
	EndIf
EndIf

//Gravação do retorno
aadd(aRet,aTamCol)
aadd(aRet,lAltera)

Return aRet