#include "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE03NFESEFAZ ºAutor ³Eduardo C. Romaniniº  Data ³  20/01/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada do fonte NfeSefaz, responsavel pela        º±±
±±º          ³transmissão de Notas Fiscais Eletronicas.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------*
User Function PE03NFESEFAZ()
*--------------------------*   
Local cMensFis := ParamIXB
Local cMsgIni  := ""
Local cCodEmp  := AllTrim(SM0->M0_CODIGO)

Local nAt := 0

//Shiseido
If cCodEmp == "R7"
	
	//Apaga a mensagem padrão, para que seja substituida pela customizada.
	If !Empty(cMensFis)		
		nAt := At("Imposto Recolhido por Substituição - Contempla os artigos 273, 313 do RICMS.",cMensFis)	
			
		//Guarda a parte antes da mensagem que serEapagada.
		If nAt > 1
			cMsgIni := Substr(cMensFis,1,nAt-1)
		EndIf
			
		While nAt > 0
			cMensFis := Substr(cMensFis,nAt+154)
			nAt := At("Imposto Recolhido por Substituição - Contempla os artigos 273, 313 do RICMS.",cMensFis)
		EndDo
			
		cMensFis := cMsgIni + cMensFis
			
	EndIf

EndIf

Return cMensFis
