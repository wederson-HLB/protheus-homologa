#Include 'Protheus.ch'


/*/{Protheus.doc} XMLCTE09
(Ponto de entrada Central XML - no lançamento de Frete sobre Vendas - permite customização)
@type function
@author Marcelo Alberto Lauschner 
@since 03/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XMLCTE09()

	// Variável aItem é Private dentro da Central XML e contém o vetor da SD1 para lançamento de cada CTE

	// Recebe o registro posicionada da SF2 
	Local	aNfOri		:= ParamIxb
	Local	aAreaOld	:= GetArea()
	Local	nPosTes		:=	aScan(aItem,{|x| AllTrim(x[1]) == "D1_TES"})
	Local	nPosOper	:= 	aScan(aItem,{|x| AllTrim(x[1]) == "D1_OPER"})
	Local	nLenItem	:= Len(aItem)
	Local	aTesOri		:= {}
	Local	nPxTes		:= 0
	// Variável aInfIcmsCte existe por causa da função sfVldAlqIcms que alimenta o array Private
	//aInfIcmsCte	:= {{"ICM","ICMS",nBaseIcms,nAliqIcms,nValIcms}}
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(aNfOri[1]+aNfOri[2]+aNfOri[3]+aNfOri[4]+aNfOri[5])
		
		// Percorre todos os itens da nota para montar um vetor somando por TES o valor das mercadorias 
		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
		While !Eof() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

			nPxTes	:= aScan(aTesOri,{|x| x[1] == SD2->D2_TES})

			If nPxTes == 0
				Aadd(aTesOri,{SD2->D2_TES,SD2->D2_TOTAL,SD2->D2_VALICM})
			Else
				aTesOri[nPxTes][2] += SD2->D2_TOTAL
				aTesori[nPxTes][3] += SD2->D2_VALICM
			Endif

			DbSelectArea("SD2")
			DbSkip()
		Enddo

		// Ordena por valor Decrescente, para assumir apenas uma TES com maior participação na nota 
		aSort(aTesOri,,,{|x,y| x[2] > y[2] })
		//VarInfo("aTesOri",aTesOri)
		If Len(aTesOri) > 0
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+aTesOri[1][1]) // Posiciona no primeiro registro de TES ordenado pelo maior valor 


			// Regra 1 - Se Houve destaque do ICMS no CTe 
			If aInfIcmsCTe[1,5] > 0 .And. SF4->(FieldPos("F4_XTECICM")) 
				If nPosTes <> 0
					aItem[nPosTes,2] := SF4->F4_XTECICM
				Else
					Aadd(aItem,{"D1_TES"	,SF4->F4_XTECICM,Nil})
				Endif
				// Regra 2 - Se Não Houve destaque do ICMS no CTe
			ElseIf  aInfIcmsCTe[1,5] == 0 .And. SF4->(FieldPos("F4_XTESICM")) 
				If nPosTes <> 0
					aItem[nPosTes,2] := SF4->F4_XTESICM
				Else
					Aadd(aItem,{"D1_TES",SF4->F4_XTESICM,Nil})
				Endif
			Endif
		Endif
	
		If nPosOper <> 0			
			aDel(aItem,nPosOper)
			aSize(aItem,nLenItem-1)
		Endif			
	Endif		
	
	RestArea(aAreaOld)
Return

