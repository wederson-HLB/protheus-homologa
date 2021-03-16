#include 'totvs.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Eduardo C. Romanini ∫ Data ≥  12/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Ponto de Entrada na validaÁ„o da tela de pedido de venda.   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*--------------------*
User Function MTA410()
*--------------------*
Local lRet  	:= .T.
Local lForn 	:= .F.

Local nPCF 		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF"})
Local nI   		:= 0
Local i    		:= 0
Local j    		:= 0
Local k			:= 0

Local aBkpCols 	:= {}

Local cDescrTxt := ""
Local cValdQtd  := ""
Local cCodEmp   := AllTrim(SM0->M0_CODIGO)
Local cChave	:= ""
Local aLinhas 	:= {}

//Grava o aCols para backup
aBkpCols := aClone(aCols)

//Verifica o CFOP informado
For nI:=1 to Len(aCols)
	If AllTrim(aCols[nI][nPCF]) $ "5901|5905|5915"
		lForn := .T.
	EndIf
Next

//Valida se o tipo do pedido estÅEcorreto para o CFOP selecionado.
If lForn
	If Alltrim(M->C5_TIPO) <> "B"
    	If !(MsgYesNo("Para os CFOPs 5901, 5905 e 5915 ÅEaconselhavel que o tipo do pedido seja 'Utiliza Fornecedor'. Confirma a inclus„o assim mesmo?"))
			Return .F.
		EndIf
	EndIf
EndIf

//Restaura o backup do aCols
aCols := aClone(aBkpCols)

//RRP - 28/01/2013 - Tratamento para empresa IS Informatica - RPS
If cCodEmp == "4Z"
	
cDescrTxt := M->C5_P_DESCR

cValdQtd  := Len(Alltrim(cDescrTxt))
//Separa por entrar o conte˙do cDescrTxt em cada posiÁ„o um vetor
aLinhas 	:= SEPARA(cDescrTxt,(Chr(13)+Chr(10)))
	
	//Verifica se existem mais de 95 caracteres por linha.
	//Len(aLinha) retorna as linhas e o Len(aLinha[j]) retorna as colunas do vetor.
	For j:= 1 To Len(aLinhas)
		//Valida se contÈm mais de 95 caracteres por linhas.
    	If Len(aLinhas[j]) > 95
			MsgInfo("O campo Desc. NF-s (C5_P_DESCR) contÈm "+cValToChar(Len(aLinhas[j]))+" caracteres na linha "+cValToChar(j)+" e o permitido s„o atÅE95 caracteres por linha, favor corrigir","AtenÁ„o")
			lRet := .F.
			Return(lRet)
		EndIf
	Next j

	//Verificando os caracteres atÅEfinal do campo.      
	For i := 1 To Len(Alltrim(cDescrTxt))
		If Alltrim(Substr(cDescrTxt,i,1)) $ '<>®&"∞∫{}[]™ß¢£¨|' .OR. Alltrim(Substr(cDescrTxt,i,1)) $ "'"
			MsgInfo("O campo Desc. NF-s (C5_P_DESCR) contÈm caracteres especiais, favor corrigir","AtenÁ„o")
			lRet := .F.
			Return(lRet)
		Else
			lRet := .T.
		EndIf
	Next i
 
	//Valida se contÈm mais de 999 caracteres.
	If cValdQtd > 999
		MsgInfo("O campo Desc. NF-s (C5_P_DESCR) contÈm mais de 1000 caracteres, favor corrigir","AtenÁ„o")
		lRet := .F.
		Return(lRet)
	//Valida se contÈm mais de 24 linhas.
	ElseIf Len(aLinhas) > 24
		MsgInfo("O campo Desc. NF-s (C5_P_DESCR) contÈm "+cValToChar(Len(aLinhas))+" linhas e o permitido s„o 24 linhas, favor corrigir","AtenÁ„o")
		lRet := .F.
		Return(lRet)
	EndIf
EndIf
//RRP - 28/01/2013 - Final do tratamento para empresa IS Informatica - RPS

//RRP - 27/08/2013 - Inclus„o do tratamento que a Shiseido possuia
If cEmpAnt $ "R7" //Shiseido
	aSort(aCols,,,{|x,y| x[2] > y[2] })
	cChave := ""
	For k:=1 to Len(aCols)
		If cChave == aCols[k][aScan( aHeader, { |x| alltrim(x[2]) == "C6_PRODUTO"} )]
			//Validando se a linha do produto n„o estÅEdeletada 
	    	If !(aCols[k][Len(aCols[k])])
				lRet:=.F.
				Exit	
			EndIf
		Else
			If !(aCols[k][Len(aCols[k])])
				cChave := aCols[k][aScan( aHeader, { |x| alltrim(x[2]) == "C6_PRODUTO"} )]
			EndIf 
	    EndIf
	Next                
	If !lRet
		MsgInfo("Favor n„o reper o mesmo produto no pedido, "+Chr(10)+Chr(13)+"aglutine as quantidades em uma unica linha. ","A T E N C A O")
	Endif   
Endif      
aSort(aCols,,,{|x,y| x[1] < y[1] })

//JSS - 09/11/2015 - Inclus„o do tratamneto para identificar se a transportadora esta preenchida e o campo frete esta preenchido como sem frete.
If cEmpAnt $ "P3" //Pronokal
	If M->C5_TPFRETE == 'S' .And. !Empty(M->C5_TRANSP) 
		MsgInfo("O campo 'Transportadora' esta preenchido e o campo tipo de frete esta preebchido como 'Sem frete'."+Chr(10)+Chr(13)+"Favor avaliar se deve ou n„o ter frete. ","A T E N C A O")
		lRet:= .F.
	Endif   
Endif


Return lRet