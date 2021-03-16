#Include 'Protheus.ch'
#Include 'Topconn.ch'
/*/{Protheus.doc} GMCOMR02
(Relatório de Acompanhamento de Manifestação de Destinatário X Entrada X Central XML)
@type function
@author marce
@since 17/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function GMCOMR02()

	Local 	oReport
	Private cPerg1	  := ValidPerg("GMCOMR02")
	Private cAliasS1  := GetNextAlias()

	oReport	:= ReportDef()
	oReport:PrintDialog()

Return



/*/{Protheus.doc} ReportDef
(Execução do relatório)
@type function
@author marce
@since 17/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()

	Local oReport,oSection1
	Local clNomProg		:= "GMCOMR02"
	Local clTitulo 		:= "Relatório de Acompanhamento de Manifestação Destinatário X Entrada X Central XML"
	Local clDesc   		:= "Relatório de Acompanhamento de Manifestação Destinatário"

	Pergunte(cPerg1,.T.)
	//oReport  := TReport():New( cReport, cTitulo, "ATR210" , { |oReport| ATFR210Imp( oReport, cAlias1, cAlias2, aOrdem ) }, cDescri )

	oReport:=TReport():New(clNomProg,clTitulo,,{|oReport| ReportPrint(oReport)},clDesc)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage	:= .F.		// Não imprime pagina de parametros
	oReport:SetLandScape()

	oSection1 := TRSection():New(oReport,"",{},{})
	//TRSection():New( oReport, STR0014 ,{}, aOrd ) // "Entidade Contabil"
	oSection1:SetColSpace(0)
	oSection1:SetTotalInLine(.F.)

	//New ( < oParent>, < cName>		, [ cAlias]		, [ cTitle]	, [ cPicture]	, [ nSize]	, [ lPixel], [ bBlock] ) --> TRCell
	TRCell():New(oSection1,"C00CHVNFE",,"Chave NFe",,44,.T.,{|| (cAliasS1)->C00_CHVNFE })
	TRCell():New(oSection1,"C00NUMNFE",,"Número Nf",,09,.T.,{|| (cAliasS1)->C00_NUMNFE })
	TRCell():New(oSection1,"C00SERNFE",,"Série"    ,,03,.T.,{|| (cAliasS1)->C00_SERNFE })
	TRCell():New(oSection1,"C00CNPJEM",,"CNPJ"     ,,14,.T.,{|| (cAliasS1)->C00_CNPJEM })

	TRCell():New(oSection1,"C00NOEMIT",,"Emitente" ,,35,.T.,{|| Alltrim((cAliasS1)->C00_NOEMIT) })
	TRCell():New(oSection1,"C00DTREC" ,,"Dt Recebida",,10,.T.,{|| (cAliasS1)->C00_DTREC })
	TRCell():New(oSection1,"C00DTEMI" ,,"Dt Emissão" ,,10,.T.,{|| (cAliasS1)->C00_DTEMI })
	TRCell():New(oSection1,"F1DTDIGIT",,"Dt Lançada" ,,10,.T.,{|| SF1->F1_DTDIGIT })

	TRCell():New(oSection1,"OBSERV",,"Observação","",70,.T.,{|| cObserv })

	//TRFunction():New(oSection1:Cell("F2_VALFAT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)


Return(oReport)


/*/{Protheus.doc} ReportPrint
(Impressão do relatório)
@type function
@author marce
@since 17/05/2016
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint( oReport )

	Local 	oSection1 		:= oReport:Section(1)
	Local	cOrder			:= "%C00_DTEMI,C00_CNPJEM,C00_NUMNFE%
	Local	lExistTblXml	:= .F. 
	Local	cQry 			:= ""
	Local	cC00SitDoc		:= ""

	cQry := "SELECT COUNT(*) EXISTXML "
	cQry += "  FROM TOP_FIELD "
	cQry += " WHERE FIELD_TABLE LIKE '%CONDORXML%' "

	TCQUERY cQry NEW ALIAS "QSXML"
	// Existir a tabela CONDORXML,irá validar a existencia da Chave na Base de dados
	If QSXML->EXISTXML > 0
		lExistTblXml	:= .T.
	Endif
	QSXML->(DbCloseArea())
	If lExistTblXml
		U_DbSelArea("CONDORXML",.F.,1)
		Set Filter To
	Endif

	oSection1:Init()

	BeginSql Alias cAliasS1
	COLUMN C00_DTREC AS DATE
	COLUMN C00_DTEMI AS DATE
	SELECT C00_CHVNFE,C00_NUMNFE,C00_SERNFE,C00_CNPJEM,C00_NOEMIT,C00_DTREC,C00_DTEMI,C00_SITDOC,C00_OK,C00_STATUS,C00_CODEVE
	FROM %Table:C00% C00
	WHERE C00.%NotDel%
	AND C00_CNPJEM BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND C00_DTEMI BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
	AND C00_FILIAL = %xFilial:C00%
	ORDER BY  %Exp:cOrder%
	EndSql
	oReport:SetMeter(RecCount())

	While !Eof()

		oReport:IncMeter()
		cObserv	:= ""
		cC00SitDoc	:= Alltrim((cAliasS1)->C00_SITDOC)

		DbSelectArea("SF1")
		DbSetOrder(8)
		If DbSeek(xFilial("SF1") + (cAliasS1)->C00_CHVNFE )
		Else
			// Verifica se a nota rejeitada na Central XML como Rejeitada 
			If cC00SitDoc $ "1"
				aAreaAux	:= GetArea()
				DbSelectArea("C00")
				DbsetOrder(1)
				If DbSeek( xFilial("C00") + (cAliasS1)->C00_CHVNFE)
					If lExistTblXml
						U_DbSelArea("CONDORXML",.F.,1)
						If DbSeek((cAliasS1)->C00_CHVNFE) 
							If !Empty(CONDORXML->XML_REJEIT)
								RecLock("C00",.F.)
								C00->C00_SITDOC   := "4" // Rejeitada Central XML
								MsUnLock()
								cC00SitDoc	:= "4"
							Endif
						Endif
					Endif
					
					If !(C00->C00_OK	$ "100#101#205")
						cRetSef := sfAutSefaz (( cAliasS1)->C00_CHVNFE )
						
						If cRetSef == "101"// Cancelamento autorizado
							DbSelectArea("C00")
							RecLock("C00",.F.)						
							C00->C00_OK		:= cRetSef 
							C00->C00_SITDOC := "3"
							MsUnlock()
							cC00SitDoc	:= "3"
						ElseIf cRetSef == "205" // Nfe Denegada
							DbSelectArea("C00")
							RecLock("C00",.F.)			
							C00->C00_OK		:= cRetSef
							C00->C00_SITDOC := "2"
							MsUnlock()
							cC00SitDoc	:= "2"
						Endif
					Endif
				Endif
				RestArea(aAreaAux)
			Endif
		Endif

		// 26/08/2017 - Melhoria para filtrar por status de Nota
		If cValToChar(mv_par06) <> "4"
			If cValToChar(mv_par06) <> cC00SitDoc
				DbSelectArea(cAliasS1)
				(cAliasS1)->(DbSkip())
				Loop
			Endif
		Endif

		If cC00SitDoc $ "1"
			cObserv	:= "1-Uso autorizado"			
		ElseIf cC00SitDoc $ "2"
			cObserv	:= "2-Uso denegado"
		ElseIf cC00SitDoc $ "3"
			cObserv	:= "3-NFe cancelada"
		ElseIf cC00SitDoc $ "4"
			cObserv := "4-NFe Rejeitada Central XML"
		Else
			cObserv	:= cC00SitDoc
		EndIf


		If lExistTblXml
			U_DbSelArea("CONDORXML",.F.,1)

			If DbSeek((cAliasS1)->C00_CHVNFE)
				If !Empty(CONDORXML->XML_REJEIT)
					cObserv	+= "/Nfe Rejeitada Central XML"
				Else
					cObserv	+= ""
				Endif
			Else
				cObserv	+= "/Falta XML"
			Endif
		Endif
		DbSelectArea("SF1")
		DbSetOrder(8)
		If DbSeek(xFilial("SF1") + (cAliasS1)->C00_CHVNFE )
			cObserv	+= ""	
			If MV_PAR05 == 2 // Em aberto
				DbSelectArea(cAliasS1)
				(cAliasS1)->(DbSkip())
				Loop
			Endif		
		Else
			If MV_PAR05 == 3 // Somente lançadas
				DbSelectArea(cAliasS1)
				(cAliasS1)->(DbSkip())
				Loop
			Endif
			cObserv	+= Iif(!Empty(cObserv),"/Sem Lcto","Sem Lcto") 
		Endif

		If (cAliasS1)->C00_OK == "XSEF"
			cObserv	+= "/Baixado Sefaz"
		Endif

		// 17/05/2016 - Adicionada informação sobre Operação vinculada
		//C00_CODEVE
		// 4-Evento rejeitado +msg rejeiçao
		// 3-Evento vinculado com sucesso 
		// 2-Envio de Evento realizado - Aguardando processamento
		// 1-Envio de Evento não realizado 
		If Alltrim((cAliasS1)->C00_CODEVE) $ "3"
			If  Alltrim((cAliasS1)->C00_STATUS) $ "1"  
				cObserv += "/210200-Confirmada"
			ElseIf  Alltrim((cAliasS1)->C00_STATUS) $ "2"
				cObserv += "/210220-Desconhecimento"
			ElseIf  Alltrim((cAliasS1)->C00_STATUS) $ "3"
				cObserv += "/210240-Não realizada"
			ElseIf  Alltrim((cAliasS1)->C00_STATUS) $ "4"
				cObserv += "/210210-Ciência"
			Else
				cObserv += "/Sem dados"
			Endif
		ElseIf Alltrim((cAliasS1)->C00_CODEVE) $ "4"
			cObserv += "/Evento rejeitado +msg rejeiçao"
		ElseIf Alltrim((cAliasS1)->C00_CODEVE) $ "2"
			cObserv += "/Envio de Evento realizado - Aguardando processamento"
		ElseIf Alltrim((cAliasS1)->C00_CODEVE) $ "1"
			cObserv += "/Envio de Evento não realizado"
		Endif

		oSection1:PrintLine()
		DbSelectArea(cAliasS1)
		(cAliasS1)->(DbSkip())
	Enddo

	oSection1:Finish()


Return



/*/{Protheus.doc} ValidPerg
(Validação de perguntas)
@type function
@author marce
@since 17/05/2016
@version 1.0
@param cPerg2, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidPerg(cPerg2)

	Local aAreaOld := GetArea()
	Local aRegs := {}
	Local i,j
	Local cPerg1

	dbSelectArea("SX1")
	dbSetOrder(1)
	// Este tratamanto é necessário pois para a versão 10, o protheus mudou o tamanho do grupo de perguntas de 6 para 10 digitos
	cPerg1 := PADR(cPerg2,Len(SX1->X1_GRUPO))
	//                               123456789012345                                                                                                                   123456789012345                                            123456789012345                                            123456789012345                                            123456789012345

	//     "X1_GRUPO" 		,"X1_ORDEM"	,"X1_PERGUNT"    			,"X1_PERSPA"			,"X1_PERENG"			,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"		,"X1_DECIMAL"		,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID"	,"X1_VAR01"	,"X1_DEF01"		,"X1_DEFSPA1"	,"X1_DEFENG1"	,"X1_CNT01"	,"X1_VAR02"	,"X1_DEF02"			,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02"	,"X1_VAR03"	,"X1_DEF03"	,"X1_DEFSPA3"		,"X1_DEFENG3"	,"X1_CNT03"	,"X1_VAR04"	,"X1_DEF04"		,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04"	,"X1_VAR05"	,"X1_DEF05"	,"X1_DEFSPA5"	,"X1_DEFENG5"	,"X1_CNT05"	,"X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"
	Aadd(aRegs,{cPerg1 ,"01"			,"Emissão de"				,"Emissão de "	 		,"Emissão de"			,"mv_ch1"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par01"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"02"			,"Emissão até"				,"Emissão até"			,"Emissão"				,"mv_ch2"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par02"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"03"			,"CNPJ De"					,"CNPJ De "		 		,"Fornecedor de"		,"mv_ch3"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par03"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"04"			,"CNPJ Até"					,"Fornecedor Até"		,"Fornecedor Até"		,"mv_ch4"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par04"	,"ZZZZZZ"		,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"05"	   		,"Qto ao Lancto"  		  	,"Qto ao Lacto"  	    ,"Qto ao Lancto"		,"mv_ch5" 		,"N"		,01		   			,0		 			,1		   		,"C"	  	,""	   		,"mv_par05"	,"Todas"		,""     		,""	      		,""  	    ,""	     	,"Em Aberto"        ,""	      			,""        			,""	   		,""      	,"Apenas Lançadas",""			,""	    		,""		  	,""	  	 	,""				,""        		,""	       		,""		 	,""	  		,""      	,""        		,"" 		 	,""	   		,""	 		,""	 		,""       		,""})
	Aadd(aRegs,{cPerg1 ,"06"	   		,"Situação NFe"	 		  	,"Situação NFe"	  	    ,"Situação NFe"			,"mv_ch6" 		,"N"		,01		   			,0		 			,4		   		,"C"	  	,""	   		,"mv_par06"	,"1-Uso Autorizado",""     		,""	      		,""  	    ,""	     	,"2-Uso Denegado"   ,""	      			,""        			,""	   		,""      	,"3-NFe Cancelada",""			,""	    		,""		  	,""			,"4-Todas"		,""        		,""	       		,""		 	,""	  		,""      	,""       		,"" 		 	,""	   		,""	 		,""	 		,""       		,"Situação da Nota fiscal"})


	dbSelectArea("SX1")
	dbSetOrder(1)

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg1+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		ElseIf aRegs[i,2] $ "XX"
			RecLock("SX1",.F.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock() 
		Endif
	Next

	RestArea(aAreaOld)

Return cPerg1



Static Function sfAutSefaz ( cInChave)
	
	Local	aAreaOld	:= GetArea()
	Local	cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	// Trecho para validar autorização da NF
	Local	cMensagem	:= ""
	Local	cRet		:= ""
	Local	oWs:= WsNFeSBra():New()
	
	// Verifico se a empresa em cursor tem TSS configurado
	cIdentSPED	:= Iif(GetNewPar("XM_TSSEXIS",.T.),StaticCall(SPEDNFE,GetIdEnt)," ")
	If !Empty(cIdentSPED)
		
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT    	 := cIdentSPED
		ows:cCHVNFE		 := cInChave
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
		
		If oWs:ConsultaChaveNFE()
			cRet := Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE)
		Endif
	Endif
	RestArea(aAreaOld)

Return cRet 
 
				