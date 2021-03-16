#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} XMLMT103
(Integração entre a Central XML e MATA103/MATA140   )

@author MarceloLauschner
@since 07/04/2012
@version 1.0

@param cChaveNfe, character, (Descrição do parâmetro)
@param aItems, array, (Descrição do parâmetro)
@param lVisual,logico, (Descrição do parâmetro)
@param lClassif, logico, (Descrição do parâmetro)
@param lExclui, logico, (Descrição do parâmetro)
@param lWhen, logico, (Descrição do parâmetro)

@return Sem retorno esperado

@example
(examples)

@see (links_or_references)
/*/
User Function XMLMT103(cChaveNfe,aItems,lVisual,lClassif,lExclui,lWhen,aCabSF1,lEstorna,lAltPreNF)

	Local		aAreaOld	:= GetArea()
	Local		cData
	Local		dData
	Local		nForA,nForB
	Default 	lVisual    	:= .F.
	Default 	lClassif	:= .F.
	Default		lExclui		:= .F.
	Default		lWhen		:= .T.
	Default		lEstorna	:= .F.
	Default 	aCabSF1		:= IIf(Type("aCabec") == "A",aCabec,{})
	Default 	lAltPreNF	:= .F. 

	Private		aColsBk		:= IIf(Type("aCols") == "A",aCols,{})
	Private		aHeaderBk	:= Iif(Type("aHeader") == "A",aHeader,{})
	Private		lXmlMt103   := !lVisual//.T.

	Private 	aSD1Cols   	:= aClone(aItems)
	//Private		aRateioCC	:= {}	

	If Type("aValCond") <> "A" 
		Private		aValCond	:= {}
	Endif

	If !lVisual
		Mata103(aClone(aCabSF1), aClone(aItems) , 3 , lWhen)
	Else
		U_DbSelArea("CONDORXML",.F.,1)

		If DbSeek(aArqXml[oArqXml:nAt,nPosChvNfe])
			If CONDORXML->XML_DEST == SM0->M0_CGC
				DbSelectArea("SF1")
				DbSetOrder(1)
				If DbSeek(CONDORXML->XML_KEYF1)
					If lAltPreNF
						aCabAuto :=  {}
						Aadd(aCabAuto,{"F1_TIPO"   	,SF1->F1_TIPO			,Nil,Nil})
						Aadd(aCabAuto,{"F1_FORMUL" 	,SF1->F1_FORMUL			,Nil,Nil})
						Aadd(aCabAuto,{"F1_DOC"    	,SF1->F1_DOC 			,Nil,Nil})
						Aadd(aCabAuto,{"F1_SERIE"   ,SF1->F1_SERIE			,Nil,Nil})
						Aadd(aCabAuto,{"F1_EMISSAO"	,SF1->F1_EMISSAO		,Nil,Nil})
						Aadd(aCabAuto,{"F1_FORNECE"	,SF1->F1_FORNECE		,Nil,Nil})
						Aadd(aCabAuto,{"F1_LOJA"   	,SF1->F1_LOJA			,Nil,Nil})
						Aadd(aCabAuto,{"F1_ESPECIE"	,SF1->F1_ESPECIE		,Nil,Nil})
						Aadd(aCabAuto,{"F1_EST"		,SF1->F1_EST			,Nil,Nil})

						aItensAuto := {}

						DbSelectArea("SD1")
						DbSetOrder(1)
						Set Filter To SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
						DbGotop()
						While !Eof()
							aLinha	:= {}
							// Zero a informação de TES somente se a nota não tiver sido classificada 
							If Empty(SF1->F1_STATUS)
								DbSelectArea("SD1")
								RecLock("SD1",.F.)
								If Empty(SD1->D1_TESACLA) .And. !Empty(SD1->D1_TES)
									SD1->D1_TESACLA	:= SD1->D1_TES
								Endif
								SD1->D1_TES 	:= "   "
								MsUnlock()
							Endif

							Aadd(aLinha,{"D1_FILIAL"	, SD1->D1_FILIAL		,Nil,Nil})
							Aadd(aLinha,{"D1_ITEM"		, SD1->D1_ITEM			,Nil,Nil})
							Aadd(aLinha,{"D1_COD"		, SD1->D1_COD			,Nil,Nil})
							Aadd(aLinha,{"D1_UM"		, SD1->D1_UM			,Nil,Nil})
							Aadd(aLinha,{"D1_QUANT"		, SD1->D1_QUANT			,Nil,Nil})
							Aadd(aLinha,{"D1_VUNIT"		, SD1->D1_VUNIT			,Nil,Nil})
							Aadd(aLinha,{"D1_LOCAL"		, SD1->D1_LOCAL			,Nil,Nil})

							Aadd(aLinha,{"D1_TES"		, SD1->D1_TES			,Nil,Nil})
							Aadd(aLinha,{"D1_TESACLA"	, SD1->D1_TESACLA		,Nil,Nil})
							Aadd(aLinha,{"D1_TOTAL"		, SD1->D1_TOTAL			,Nil,Nil})

							Aadd(aLinha,{"D1_RATEIO"	, SD1->D1_RATEIO		,Nil,Nil})

							//xRateio:= {}
							/*
							aadd(xRateio,{"CH_ITEMPD"	,StrZero(nIX,len(SC7->D1_ITEM)),Nil})
							aadd(xRateio,{"CH_ITEM"		,StrZero(nYY,len(SCH->CH_ITEM)),Nil})
							aadd(xRateio,{"CH_PERC"		,IIF(nYY==1,30,70),Nil})
							aadd(xRateio,{"DE_CC"		,IIF(nYY==2,"1","2"),Nil})
							aadd(xRateio,{"DE_CONTA"	,'',Nil})
							aadd(xRateio,{"DE_ITEMCTA"	,'',Nil})
							aadd(xRateio,{"DE_CLVL"		,'',Nil})
							*/
							//aadd(aRateioCC,xRateio)

							Aadd(aItensAuto,aLinha)

							DbSelectArea("SD1")
							DbSkip()
						Enddo
						DbSelectArea("SD1")
						DbSetOrder(1)
						Set Filter To


						If MsgYesNo("Deseja continuar?","Alteração")
							If Empty(SF1->F1_STATUS)
								DbSelectArea("SF1")
								Mata140(aCabAuto,aItensAuto, 4 , ,Iif(lWhen,1,0) )
							Endif
						Endif

					ElseIf !lClassif
						Mata103( , , 2 ,)
					ElseIf lExclui
						If Empty(SF1->F1_STATUS) .Or. (lEstorna .And. SF1->F1_STATUS == "A") // Somente pré nota ou pré-classificada
							aCabAuto :=  {}
							Aadd(aCabAuto,{"F1_TIPO"   	,SF1->F1_TIPO			,Nil,Nil})
							Aadd(aCabAuto,{"F1_FORMUL" 	,SF1->F1_FORMUL			,Nil,Nil})
							Aadd(aCabAuto,{"F1_DOC"    	,SF1->F1_DOC 			,Nil,Nil})
							Aadd(aCabAuto,{"F1_SERIE"   ,SF1->F1_SERIE			,Nil,Nil})
							Aadd(aCabAuto,{"F1_EMISSAO"	,SF1->F1_EMISSAO		,Nil,Nil})
							Aadd(aCabAuto,{"F1_FORNECE"	,SF1->F1_FORNECE		,Nil,Nil})
							Aadd(aCabAuto,{"F1_LOJA"   	,SF1->F1_LOJA			,Nil,Nil})
							Aadd(aCabAuto,{"F1_ESPECIE"	,SF1->F1_ESPECIE		,Nil,Nil})
							Aadd(aCabAuto,{"F1_EST"		,SF1->F1_EST			,Nil,Nil})

							aItensAuto := {}

							DbSelectArea("SD1")
							DbSetOrder(1)
							Set Filter To SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
							DbGotop()
							While !Eof()
								aLinha	:= {}
								// Zero a informação de TES somente se a nota não tiver sido classificada 
								If Empty(SF1->F1_STATUS)
									DbSelectArea("SD1")
									RecLock("SD1",.F.)
									If Empty(SD1->D1_TESACLA) .And. !Empty(SD1->D1_TES)
										SD1->D1_TESACLA	:= SD1->D1_TES
									Endif
									SD1->D1_TES 	:= "   "
									MsUnlock()
								Endif

								Aadd(aLinha,{"D1_FILIAL"	, SD1->D1_FILIAL		,Nil,Nil})
								Aadd(aLinha,{"D1_ITEM"		, SD1->D1_ITEM			,Nil,Nil})
								Aadd(aLinha,{"D1_COD"		, SD1->D1_COD			,Nil,Nil})
								Aadd(aLinha,{"D1_UM"		, SD1->D1_UM			,Nil,Nil})
								Aadd(aLinha,{"D1_QUANT"		, SD1->D1_QUANT			,Nil,Nil})
								Aadd(aLinha,{"D1_VUNIT"		, SD1->D1_VUNIT			,Nil,Nil})
								Aadd(aLinha,{"D1_LOCAL"		, SD1->D1_LOCAL			,Nil,Nil})

								Aadd(aLinha,{"D1_TES"		, SD1->D1_TES			,Nil,Nil})
								Aadd(aLinha,{"D1_TESACLA"	, SD1->D1_TESACLA		,Nil,Nil})
								Aadd(aLinha,{"D1_TOTAL"		, SD1->D1_TOTAL			,Nil,Nil})

								Aadd(aLinha,{"D1_RATEIO"	, SD1->D1_RATEIO		,Nil,Nil})

								//xRateio:= {}
								/*
								aadd(xRateio,{"CH_ITEMPD"	,StrZero(nIX,len(SC7->D1_ITEM)),Nil})
								aadd(xRateio,{"CH_ITEM"		,StrZero(nYY,len(SCH->CH_ITEM)),Nil})
								aadd(xRateio,{"CH_PERC"		,IIF(nYY==1,30,70),Nil})
								aadd(xRateio,{"DE_CC"		,IIF(nYY==2,"1","2"),Nil})
								aadd(xRateio,{"DE_CONTA"	,'',Nil})
								aadd(xRateio,{"DE_ITEMCTA"	,'',Nil})
								aadd(xRateio,{"DE_CLVL"		,'',Nil})
								*/
								//aadd(aRateioCC,xRateio)

								Aadd(aItensAuto,aLinha)

								DbSelectArea("SD1")
								DbSkip()
							Enddo
							DbSelectArea("SD1")
							DbSetOrder(1)
							Set Filter To


							If MsgYesNo("Deseja continuar?","Exclusão/Estorno")
								// Declara variável só para não dar erro de execução
								Private	l103GAuto	:= .T. 
								
								If Empty(SF1->F1_STATUS)
									Mata140(aCabAuto,aItensAuto, 5 , , )
								ElseIf SF1->F1_STATUS == "A"
									DbSelectArea("SF1")
									Mata140(aCabAuto,aItensAuto , 7 , , 1 )
								Endif
							Endif
						ElseIf SF1->F1_STATUS == "B"
							Mata103(, , 5 , )
							//MsgAlert("Documento Bloqueado! Utilize a Rotina padrão ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						Else
							aCabAuto :=  {}
							Aadd(aCabAuto,{"F1_TIPO"   	,SF1->F1_TIPO			,Nil,Nil})
							Aadd(aCabAuto,{"F1_FORMUL" 	,SF1->F1_FORMUL			,Nil,Nil})
							Aadd(aCabAuto,{"F1_DOC"    	,SF1->F1_DOC 			,Nil,Nil})
							Aadd(aCabAuto,{"F1_SERIE"   ,SF1->F1_SERIE			,Nil,Nil})
							Aadd(aCabAuto,{"F1_EMISSAO"	,SF1->F1_EMISSAO		,Nil,Nil})
							Aadd(aCabAuto,{"F1_FORNECE"	,SF1->F1_FORNECE		,Nil,Nil})
							Aadd(aCabAuto,{"F1_LOJA"   	,SF1->F1_LOJA			,Nil,Nil})
							Aadd(aCabAuto,{"F1_ESPECIE"	,SF1->F1_ESPECIE		,Nil,Nil})
							Aadd(aCabAuto,{"F1_EST"		,SF1->F1_EST			,Nil,Nil})

							aItensAuto := {}

							DbSelectArea("SD1")
							DbSetOrder(1)
							Set Filter To SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
							DbGotop()
							While !Eof()
								aLinha	:= {}
								
								Aadd(aLinha,{"D1_FILIAL"	, SD1->D1_FILIAL		,Nil,Nil})
								Aadd(aLinha,{"D1_ITEM"		, SD1->D1_ITEM			,Nil,Nil})
								Aadd(aLinha,{"D1_COD"		, SD1->D1_COD			,Nil,Nil})
								Aadd(aLinha,{"D1_UM"		, SD1->D1_UM			,Nil,Nil})
								Aadd(aLinha,{"D1_QUANT"		, SD1->D1_QUANT			,Nil,Nil})
								Aadd(aLinha,{"D1_VUNIT"		, SD1->D1_VUNIT			,Nil,Nil})
								Aadd(aLinha,{"D1_LOCAL"		, SD1->D1_LOCAL			,Nil,Nil})

								Aadd(aLinha,{"D1_TES"		, SD1->D1_TES			,Nil,Nil})
								Aadd(aLinha,{"D1_TOTAL"		, SD1->D1_TOTAL			,Nil,Nil})

								Aadd(aLinha,{"D1_RATEIO"	, SD1->D1_RATEIO		,Nil,Nil})

								//xRateio:= {}
								/*
								aadd(xRateio,{"CH_ITEMPD"	,StrZero(nIX,len(SC7->D1_ITEM)),Nil})
								aadd(xRateio,{"CH_ITEM"		,StrZero(nYY,len(SCH->CH_ITEM)),Nil})
								aadd(xRateio,{"CH_PERC"		,IIF(nYY==1,30,70),Nil})
								aadd(xRateio,{"DE_CC"		,IIF(nYY==2,"1","2"),Nil})
								aadd(xRateio,{"DE_CONTA"	,'',Nil})
								aadd(xRateio,{"DE_ITEMCTA"	,'',Nil})
								aadd(xRateio,{"DE_CLVL"		,'',Nil})
								*/
								//aadd(aRateioCC,xRateio)

								Aadd(aItensAuto,aLinha)

								DbSelectArea("SD1")
								DbSkip()
							Enddo
							DbSelectArea("SD1")
							DbSetOrder(1)
							Set Filter To
							
							Mata103(aCabAuto,aItensAuto , 5 , .T. )
						Endif
					ElseIf lClassif .And. (Empty(SF1->F1_STATUS) .Or. (SF1->F1_STATUS == "B" .And. SuperGetMV("MV_RESTCLA",.F.,"2")=="2")) 

						// Na classificação de nota foi necessário carregar algumas variáveis para permitir a validação do PE MT103DNF
						// Permtindo que haja a validação de Duplicatas e impostos ao Classificar uma Prenota
						// cCondicao 
						// aDupSE2
						// aDupAxSE2
						// aValCond
						cParcela	:= " "
						aDupSE2		:= {}
						aDupAxSE2	:= {}
						aValCond	:= {}
						cNumDoc		:= SF1->F1_DOC

						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)

						cCondicao	:= IIf(Empty(SF1->F1_COND),SA2->A2_COND,SF1->F1_COND)

						cAviso	:= ""
						cErro	:= ""
						oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)


						If Type("oNFe:_NfeProc:_NFe") <> "U"
							oNF := oNFe:_NFeProc:_NFe
						ElseIf Type("oNFe:_NFe")<> "U"
							oNF := oNFe:_NFe
						ElseIf Type("oNFe:_InfNfe")<> "U"
							oNF := oNFe
						ElseIf Type("oNFe:_NfeProc:_nfeProc:_NFe") <> "U"
							oNF := oNFe:_nfeProc:_NFeProc:_NFe
						Else
							cAviso	:= ""
							cErro	:= ""
							oNfe := XmlParser(CONDORXML->XML_ATT3,"_",@cAviso,@cErro)
							If Type("oNFe:_NfeProc")<> "U"
								oNF := oNFe:_NFeProc:_NFe
							ElseIf Type("oNFe:_Nfe")<> "U"
								oNF := oNFe:_NFe
							Else
								If !lAutoExec
									sfAtuXmlOk("E1")
									MsgAlert("Erro ao ler xml "+CONDORXML->XML_ATT3,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
								Else
									sfAtuXmlOk("E1")
								Endif
								ConOut("+"+Replicate("-",98)+"+")
								ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
								ConOut("+"+Replicate("-",98)+"+")

								Return .F.
							Endif
						Endif

						If !Empty(cErro)
							If !lAutoExec
								sfAtuXmlOk("E2")
								MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
							Else
								sfAtuXmlOk("E2")
							Endif
							ConOut("+"+Replicate("-",98)+"+")
							ConOut(ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
							ConOut("+"+Replicate("-",98)+"+")

							Return .F.
						Endif

						oIdent     	:= oNF:_InfNfe:_IDE
						oEmitente  	:= oNF:_InfNfe:_Emit
						oDestino   	:= oNF:_InfNfe:_Dest
						oTotal		:= oNF:_InfNfe:_Total
						oTransp		:= oNF:_InfNfe:_Transp
						If Type("oNF:_InfNfe:_Cobr") <> "U"
							oCobr		:= oNF:_InfNfe:_Cobr
						Endif

						If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
							oNF 	:= oNFe:_NFeProc:_NFe
							cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
						Else
							cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,nTmF1Ser) + Right(StrZero(0,(nTmF1Doc) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,nTmF1Doc)
						Endif

						If Type("oCobr:_dup") <> "U"
							// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
							nSumSE2		:= 0
							oDup  		:= oCobr:_dup
							oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
							lOnlyDup	:= Len(oDup) == 1
							For nForA  := 1 To Len(oDup)
								nP	:= nForA 
								If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
									dVencPXml	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
									If lMadeira
										// Se a data de vencimento do título for menor que a database irá assumir a database como vencimento
										If dVencPXml < dDataBase
											dVencPXml	:= DataValida(dDataBase)
										Endif
									Endif
									Aadd(aDupSE2,{	dVencPXml	,;	// Data Vencimento
									Val(oDup[nP]:_vDup:TEXT)})		// Valor da Duplicata})
									nSumSE2		+= Val(oDup[nP]:_vDup:TEXT)

									If lOnlyDup
										cParcela := " "
									Else
										cParcela := IF(nP>1,MaParcela(cParcela),IIF(Empty(cParcela),"A",cParcela))
									Endif
								Endif
							Next nForA
						Endif
						// Identifica novo formato de Data e Hora - Nota Versão 3.10
						If Type("oIdent:_dhEmi") <> "U"
							// <dhEmi>2014-04-15T12:02:46-03:00
							cData 	:=	Alltrim(Substr(oIdent:_dhEmi:TEXT,1,10))
						Else
							//<dEmi>2014-04-10
							cData	:=	Alltrim(oIdent:_dEmi:TEXT)
						Endif
						cData	:= 	StrTran(cData,"-","")
						dData	:=	STOD(cData) //CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
						// Variável aValCond é populada para validações em pontos de entrada de clientes 
						Aadd(aValCond,Val(oTotal:_ICMSTot:_vNF:TEXT))			// 1 - Valor Total
						Aadd(aValCond,Val(oTotal:_ICMSTot:_vIPI:TEXT))			// 2 - Valor IPI
						Aadd(aValCond,Val(oTotal:_ICMSTot:_vST:TEXT))			// 3 - Valor Solidário
						Aadd(aValCond,dData)									// 4 - Data emissão

						For nForB := 1 To Len(oMulti:aCols)
							nIX := nForB
							If !oMulti:aCols[nIX,Len(oMulti:aHeader)+1]
								If 	!Alltrim(oMulti:aCols[nIX][nPxCFNFe]) $ cCFOPNPED .And.;
								(IIf(!Empty(oMulti:aCols[nIX][nPxCF]),!Alltrim(oMulti:aCols[nIX][nPxCF]) $ cCFOPNPED,.T.)) .And.;
								(IIf(!Empty(oMulti:aCols[nIX][nPxD1Tes]),!Alltrim(oMulti:aCols[nIX][nPxD1Tes]) $ cTESNPED,.T.)) .And.;
								(!Empty(oMulti:aCols[nIX,nPxPedido]) .And.!Empty(oMulti:aCols[nIX,nPxItemPC]))
									DbSelectArea("SC7")
									DbSetOrder(1)
									If DbSeek(xFilial("SC7")+oMulti:aCols[nIX,nPxPedido]+oMulti:aCols[nIX,nPxItemPC]) .And. !Empty(SC7->C7_COND)
										cCondicao		:= SC7->C7_COND
									Endif
								Endif
							Endif
						Next nForB
						// 11/06/2017 - Criado ponto de entrada para permitir validações do cliente ou tratar variáveis 
						If ExistBlock("XMLCTE17")
							ExecBlock("XMLCTE17",.F.,.F.)
						Endif

						// Carrega variável para ser usada no PE MT103DNF
						If Type("aDupAxSE2") == "U"
							Private	aDupAxSE2	:= Condicao(aValCond[1]/*nValTot*/,cCondicao/*cCond*/,aValCond[2]/*nValIpi*/,aValCond[4]/*dData0*/,aValCond[3]/*nValSolid*/)
						Else
							aDupAxSE2	:= Condicao(aValCond[1]/*nValTot*/,cCondicao/*cCond*/,aValCond[2]/*nValIpi*/,aValCond[4]/*dData0*/,aValCond[3]/*nValSolid*/)
						Endif

						// Se o campo Chave estiver vazio por que a pre-nota foi incluida de forma manual
						If Empty(SF1->F1_CHVNFE)
							DbSelectArea("SF1")
							RecLock("SF1",.F.)
							SF1->F1_CHVNFE	:= cChave
							MsUnlock()
						Endif

						Mata103(, , 4 , )
					Else
						If SF1->F1_STATUS == "B" .And. SuperGetMV("MV_RESTCLA",.F.,"2")=="1"
							Help("  ",1,"A103BLCLA")
							//MsgAlert("Pré-nota com Bloqueio. Use a rotina padrão para dar continuidade!","Pré-nota")
						Else
							MsgAlert("Opção não permitida/desconhecida. Status '"+SF1->F1_STATUS+"'. Use a rotina padrão para dar continuidade!","A T E N Ç Ã O!!")
						Endif
					Endif
				Else
					MsgAlert("Nota fiscal não localizada!","A T E N Ç Ã O!!")
				Endif
			Else
				MsgAlert("Esta nota não pertence a empresa "+Capital(SM0->M0_NOMECOM),"Empresa errada!")
			Endif
		Endif

	Endif

	// Restauro variaveis
	aCols	:= aColsBk
	aHeader := aHeaderBk
	RestArea(aAreaOld)

Return





/*/{Protheus.doc} XmlXnucAcess
(Função que retorna os acessos permitidos do menu da função passada como parâmetro)
@type function
@author marce
@since 09/08/2016
@version 1.0
@param cInModulo, character, (Número do módulo. Exemplo: "02" para Compras )
@param cInNameFunc, character, (Nome da Função. Exemplo: "MATA103" )
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XmlXnucAcess(cInModulo,cInNameFunc,cInModName,lDebug)

	Local nX 			:= 0
	Local aLoad 		:= {}
	Local aRet 			:= {}

	//Static Function ValidMenu(aModulo,nRowPos,cID,cUser)
	Local aMenu 		:= {}
	Local aUserMenu 	:= {}
	Local aCopyMenu
	Local ni
	Local cMenuProfile
	Default	lDebug		:= .F. 
	Private aTmp
	Private nMenuProfile	:= 0
	Private aMenuProfile	:= {}

	
  
	PswOrder(1) 		// Ordena arquivo de senhas por ID do usuario
	PswSeek(__cUserID) 	// Pesquisa usuario corrente
	aMenus := PswRet ( 3 )
	nPosMenu := Ascan(aMenus[1],{|x| Substr(x,1,2) == cInModulo})

	//Leio menu
	If nPosMenu > 0
		aLoad := XNULOAD(Substr(aMenus[1,nPosMenu],4))
		If lDebug
			MsgAlert("Variável nPosMenu '"+cValToChar(nPosMenu) + "' Menu:'" + Substr(aMenus[1,nPosMenu],4)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))) )
		Endif
	Else
		If lDebug
			MsgAlert("Variável nPosMenu zerada",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif
	Endif

	aCopyMenu := Aclone(aLoad)

	If FindProfDef(__cUserID,cInModName,"MENU","ACBROWSE")
		cMenuProfile := RetProfDef(__cUserID,cInModName,"MENU","ACBROWSE")
		If lDebug
			MsgAlert("Variável cMenuProfile '"+cMenuProfile+"'" ,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
		Endif

		If !Empty(cMenuProfile)
			Aadd(aMenuProfile,{__cUserID,cInModName,Str2Array(cMenuProfile)})
			nMenuProfile := Len(aMenuProfile)
			If lDebug
				MsgAlert("Variável cMenuProfile '"+cMenuProfile+"' nMenuProfile '"+cValToChar(nMenuProfile) + "'"   ,ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
			Endif
		EndIf
	Endif

	For nX:= 1 To Len(aLoad)
		GetMenu( aLoad[nX][3], @aRet , cInNameFunc)
	Next nX


Return aRet


/*/{Protheus.doc} GetMenu
(Verifica os acessos do Menu Item e monta array)
@type function
@author marce
@since 09/08/2016
@version 1.0
@param aLoad, array, (Descrição do parâmetro)
@param aRet, array, (Descrição do parâmetro)
@param cInNameFunc, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetMenu( aLoad, aRet ,cInNameFunc )

	Local nX
	Local ni

	For nX:=1 To Len(aLoad)
		If ValType(aLoad[nX][3]) == "A" .AND. aLoad[nX][2] == "E"
			Getmenu( aLoad[nX][3], @aRet ,cInNameFunc)
		Else
			If nMenuProfile > 0
				aTmp := aMenuProfile[nMenuProfile][3]
				For ni := 1 To Len(aTmp)
					If ValType(aLoad[nX][3]) == "C" .And. ValType(aTmp[ni][3]) == "C"
						If aLoad[nX][3] == aTmp[ni][3]
							aLoad[nX][2] := aTmp[ni][2]
							aLoad[nX][4] := aTmp[ni][4]
							aLoad[nX][5] := aTmp[ni][4]
						EndIf
					Endif
				Next
			EndIf

			If aLoad[nX][2] == "E"
				//MsgAlert(Upper(aLoad[nX][3]),cInNameFunc)
				If Upper(aLoad[nX][3]) == cInNameFunc
					aAdd( aRet, { aLoad[nX][3], aLoad[nX][5],aLoad[nX][7] } )
					//MsgAlert(aLoad[nX][5])
				Endif
			EndIf
		EndIf
	Next

Return


User Function TesteXnu()

	Local aAcessUsr := u_XmlXnucAcess("02","MATA103","SIGACOM",.T.) 
	Local   ix 

	If Len(aAcessUsr) == 0
		MsgAlert("Sem retorno de valor para MATA103")
	Else
		For ix := 1 To Len(aAcessUsr)
			MsgAlert(aAcessUsr[ix,1],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 1")
			MsgAlert(aAcessUsr[ix,2],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 2" )
			MsgAlert(aAcessUsr[ix,3],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 3")
		Next
	Endif

	aAcessUsr := u_XmlXnucAcess("02","MATA140","SIGACOM",.T.) 

	If Len(aAcessUsr) == 0
		MsgAlert("Sem retorno de valor para MATA140 ",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
	Else
		For ix := 1 To Len(aAcessUsr)
			MsgAlert(aAcessUsr[ix,1],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 1")
			MsgAlert(aAcessUsr[ix,2],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 2" )
			MsgAlert(aAcessUsr[ix,3],ProcName(0)+"."+ Alltrim(Str(ProcLine(0)))+ " ix 3")
		Next
	Endif
Return