#Include 'Protheus.ch'


/*/{Protheus.doc} GMCOMR03
(Relatório de Acompanhamento de Duplicatas de XMLs X Entrada X Contas a Pagar)
@type function
@author marce
@since 22/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function GMCOMR03()
	Local 	oReport
	Private cPerg1	  	:= ValidPerg("GMCOMR03")
	Private cAliasS1  	:= GetNextAlias()
	Private cAliasS2	:= GetNextAlias()
	Private cAliasS3	:= GetNextAlias()
	
	
	
	oReport	:= ReportDef()
	oReport:PrintDialog()
Return


/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author marce
@since 22/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
	
	Local oReport,oSection1
	Local clNomProg		:= "GMCOMR03"
	Local clTitulo 		:= "Relatório de Acompanhamento de Duplicatas de XMLs X Entrada X Contas a Pagar"
	Local clDesc   		:= "Relatório de Acompanhamento de Duplicatas de XMLs"
	
	Pergunte(cPerg1,.T.)
	//oReport  := TReport():New( cReport, cTitulo, "ATR210" , { |oReport| ATFR210Imp( oReport, cAlias1, cAlias2, aOrdem ) }, cDescri )
	
	If mv_par07 == 1  // Sped
		Processa({|| sfRefDuplN() } ,"Atualizando dados de duplicatas de NFe pendentes...")
	ElseIf mv_par07 == 2 // CTe
		Processa({|| sfRefDuplF() } ,"Atualizando dados de duplicatas de CTe pendentes...")
	Else // Ambos
		Processa({|| sfRefDuplN() } ,"Atualizando dados de duplicatas de NFe pendentes...")
		Processa({|| sfRefDuplF() } ,"Atualizando dados de duplicatas de CTe pendentes...")
	Endif
	
	oReport:=TReport():New(clNomProg,clTitulo,,{|oReport| ReportPrint(oReport)},clDesc)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage	:= .F.		// Não imprime pagina de parametros
	oReport:SetLandScape()
	
	oSection1 := TRSection():New(oReport,"",{},{})
	//TRSection():New( oReport, STR0014 ,{}, aOrd ) // "Entidade Contabil"
	oSection1:SetColSpace(0)
	oSection1:SetTotalInLine(.F.)
	
	//New (     < oParent>, < cName>    ,[ cAlias]	, [ cTitle]			, [ cPicture]			, [ nSize]				, [ lPixel]	, [ bBlock] ) --> TRCell
	TRCell():New(oSection1,"XML_EMIT" 	,			,"Emitente"			,						,TamSX3("A2_CGC")[1]+1	,.T.		,{|| (cAliasS1)->XML_EMIT })
	TRCell():New(oSection1,"XML_NOMEMT" ,			,"Nome"				,						,30						,.T.		,{|| (cAliasS1)->XML_NOMEMT })
	TRCell():New(oSection1,"XDP_CHAVE" 	,			,"Chave Eletrônica"	,						,TamSX3("F1_CHVNFE")[1]+1	,.T.		,{|| (cAliasS1)->XDP_CHAVE })
	TRCell():New(oSection1,"XDP_PARCEL"	,			,"Parcela"			,						,TamSX3("E2_PARCELA")[1],.T.		,{|| (cAliasS1)->XDP_PARCEL })
	TRCell():New(oSection1,"XML_EMISSA"	,			,"Emissão"			,						,10						,.T.		,{|| (cAliasS1)->XML_EMISSA })
	TRCell():New(oSection1,"XDP_VENCTO"	,			,"Vencto"			,						,10						,.T.		,{|| (cAliasS1)->XDP_VENCTO })
	TRCell():New(oSection1,"DIASAVENC"	,			,"Dias "			,						,4						,.T.		,{|| IIf(Empty((cAliasS1)->XDP_VENCTO),0,(cAliasS1)->XDP_VENCTO - Date())})
	TRCell():New(oSection1,"XDP_VALOR"	,			,"R$ Parcela"		,X3Picture("E2_VALOR")	,TamSX3("E2_VALOR")[1]	,.T.		,{|| (cAliasS1)->XDP_VALOR })
	TRCell():New(oSection1,"F1SERIE" 	,			,"Série"			,						,TamSX3("F1_SERIE")[1]	,.T.		,{|| (cAliasS1)->F1_SERIE })
	TRCell():New(oSection1,"F1DOC" 		,			,"Núm NF"			,						,TamSX3("F1_DOC")[1]	,.T.		,{|| (cAliasS1)->F1_DOC })
	TRCell():New(oSection1,"E2PREFIXO" 	,			,"Prf"				,						,TamSX3("E2_PREFIXO")[1],.T.		,{|| (cAliasS1)->E2_PREFIXO })
	TRCell():New(oSection1,"E2NUM" 		,			,"No.Título"		,						,TamSX3("E2_NUM")[1]	,.T.		,{|| (cAliasS1)->E2_NUM })
	TRCell():New(oSection1,"E2PARCELA" 	,			,"Parc"				,						,TamSX3("E2_PARCELA")[1],.T.		,{|| (cAliasS1)->E2_PARCELA })
	TRCell():New(oSection1,"E2EMISSAO" 	,			,"Emissão"			,						,10						,.T.		,{|| (cAliasS1)->E2_EMISSAO })
	TRCell():New(oSection1,"E2VALOR" 	,			,"R$ Valor"			,X3Picture("E2_VALOR")	,TamSX3("E2_VALOR")[1]	,.T.		,{|| (cAliasS1)->E2_VALOR })
	TRCell():New(oSection1,"E2VENCTO"	,			,"Vencto"			,						,10						,.T.		,{|| (cAliasS1)->E2_VENCTO })
	
	//TRCell():New(oSection1,"OBSERV",,"Observação","",80,.T.,{|| cObserv })
	
	//TRFunction():New(oSection1:Cell("F2_VALFAT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	
	
Return(oReport)



/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author marce
@since 22/05/2016
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint( oReport )
	
	Local 	oSection1 		:= oReport:Section(1)
	Local	cOrder			:= "%XML_EMISSA,XDP_CHAVE,XDP_PARCEL%
	
	
	oSection1:Init()
	
	BeginSql Alias cAliasS1
		COLUMN XML_EMISSA AS DATE
		COLUMN XDP_VENCTO AS DATE
		COLUMN E2_EMISSAO AS DATE
		COLUMN E2_VENCTO AS DATE
		SELECT XDP_CHAVE, XDP_PARCEL, XML_NOMEMT, XML_EMIT, XML_EMISSA,XDP_VENCTO,CASE WHEN XDP_VALOR = 0 THEN XML_VLRDOC ELSE XDP_VALOR END XDP_VALOR, 
		COALESCE(F1_DOC,' ') F1_DOC ,COALESCE(F1_SERIE,' ') F1_SERIE,
		E2_PREFIXO, E2_NUM, E2_PARCELA, E2_EMISSAO, COALESCE(E2_VALOR,0) E2_VALOR, E2_VENCTO
		FROM CONDORXMLDUPL
		LEFT JOIN %Table:SF1% F1
		ON F1_CHVNFE = XDP_CHAVE
		AND F1.%NotDel%
		AND F1_STATUS = 'A'
		AND F1_FILIAL = %xFilial:SF1%
		LEFT JOIN %Table:SE2% E2
		ON E2_NUM = F1_DUPL
		AND E2.%NotDel%
		AND E2_PREFIXO = F1_PREFIXO
		AND E2_PARCELA = XDP_PARCEL
		AND E2_FORNECE = F1_FORNECE
		AND E2_LOJA = F1_LOJA
		AND E2_FILIAL = %xFilial:SE2%
		INNER JOIN CONDORXML
		ON XML_CHAVE = XDP_CHAVE
		AND XML_EMIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND XML_EMISSA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND XML_DEST = %Exp:SM0->M0_CGC%
		WHERE ((%Exp:MV_PAR05% = 3 AND F1_DOC IS NOT NULL) OR (%Exp:MV_PAR05% = 2 AND F1_DOC IS NULL) OR %Exp:MV_PAR05% = 1) 
		AND ((%Exp:MV_PAR05% = 3 AND F1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR09)% AND %Exp:DTOS(MV_PAR10)%) OR (%Exp:MV_PAR05% < 3 ))
		AND ((%Exp:MV_PAR07% = 1 AND XML_TIPODC = 'N') OR (%Exp:MV_PAR07% = 2 AND XML_TIPODC IN('T','F')) OR %Exp:MV_PAR07% = 3) 
		AND ((%Exp:MV_PAR08% = 1 AND XDP_VALOR > 0) OR %Exp:MV_PAR08% <> 1) 
		AND XML_REJEIT = ' '
		ORDER BY  %Exp:cOrder%
	EndSql
	oReport:SetMeter(RecCount())
	
	While !Eof()
		
		oReport:IncMeter()

		If Empty((cAliasS1)->F1_DOC)
			If MV_PAR05 == 3 // Somente lançadas
				DbSelectArea(cAliasS1)
				(cAliasS1)->(DbSkip())
				Loop
			Endif
		Else
			If MV_PAR05 == 2 // Em aberto
				DbSelectArea(cAliasS1)
				(cAliasS1)->(DbSkip())
				Loop
			Endif
		Endif
		
		If ((cAliasS1)->XDP_VENCTO - Date()) > mv_par06
			DbSelectArea(cAliasS1)
			(cAliasS1)->(DbSkip())
			Loop
		Endif
		
		oSection1:PrintLine()
		DbSelectArea(cAliasS1)
		(cAliasS1)->(DbSkip())
	Enddo
	
	oSection1:Finish()
	
	
Return


/*/{Protheus.doc} ValidPerg
(Validação da pergunta)
@type function
@author marce
@since 22/05/2016
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
	
	//     "X1_GRUPO" 		,"X1_ORDEM"	,"X1_PERGUNT"    			,"X1_PERSPA"				,"X1_PERENG"			,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"		,"X1_DECIMAL"		,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID","X1_VAR01"	,"X1_DEF01"	,"X1_DEFSPA1"	,"X1_DEFENG1"	,"X1_CNT01","X1_VAR02","X1_DEF02"		,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02","X1_VAR03","X1_DEF03"	,"X1_DEFSPA3"	,"X1_DEFENG3"	,"X1_CNT03","X1_VAR04","X1_DEF04"	,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5"	,"X1_CNT05","X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"
	Aadd(aRegs,{cPerg1 ,"01"			,"Emissão de"				,"Emissão de "	 		,"Emissão de"			,"mv_ch1"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par01"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"02"			,"Emissão até"				,"Emissão até"			,"Emissão"				,"mv_ch2"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par02"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"03"			,"CNPJ De"					,"CNPJ De "		 		,"Fornecedor de"		,"mv_ch3"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par03"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"04"			,"CNPJ Até"					,"Fornecedor Até"		,"Fornecedor Até"		,"mv_ch4"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par04"	,"ZZZZZZ"		,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"05"	   		,"Qto ao Lancto"  		  	,"Qto ao Lacto"  	    ,"Qto ao Lancto"		,"mv_ch5" 		,"N"		,01		   			,0		 			,1		   		,"C"	  	,""	   		,"mv_par05"	,"Todas" 	    ,""        		,""	      		,""  	    ,""	     	,"Em Aberto"        ,""	      			,""        			,""	   		,""      	,"Apenas Lançadas"       ,""	,""	    		,""		  	,""	  	 	,"             ",""        		,""	       		,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1 ,"06"	   		,"No Dias a Vencer"		  	,"No Dias a Vencer"	    ,"No Dias a Vencer"		,"mv_ch6" 		,"N"		,04		   			,0		 			,0		   		,"G"	  	,""	   		,"mv_par06"	,"" 	   		,""        		,""	      		,""  	    ,""	     	,""        ,""	      			,""        			,""	   		,""      	,""       ,""	,""	    		,""		  	,""	  	 	,"             ",""        		,""	       		,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1 ,"07"	  		,"Listar Tipos"    			,"Listar Tipos"      	,"Listar tipos"       	,"mv_ch7" 		,"N"		,01		   			,0		 			,1		  	 	,"C"	  	,""	   		,"mv_par07"	,"SPED"         ,""       	 	,""	      		,""  	    ,""	     	,"CTE"             ,""	      ,""        ,""	   ,""      ,"Ambos"          ,""	     ,""	    ,""		  ,""	   ,"               ",""        ,""	       ,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1 ,"08"	  		,"Listar Zerado"   			,"Listar Zerado"      	,"Listar Zerado"       	,"mv_ch8" 		,"N"		,01		   			,0		 			,1		  	 	,"C"	  	,""	   		,"mv_par08"	,"Nao"          ,""        		,""	      		,""  	    ,""	     	,"Sim"             ,""	      ,""        ,""	   ,""      ,"Ambos"          ,""	     ,""	    ,""		  ,""	   ,"               ",""        ,""	       ,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1 ,"09"			,"Digitação de"				,"Digitação de " 		,"Digitação"			,"mv_ch9"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par09"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"10"			,"Digitação até"			,"Digitação até"		,"Digitação"			,"mv_chb"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par10"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	
	
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
			/*Else
			RecLock("SX1",.F.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next*/
			MsUnlock() 
		Endif
	Next
	
	RestArea(aAreaOld)
	
Return cPerg1


/*/{Protheus.doc} sfRefDuplN
(Refaz Duplicatas de Notas Normais na Tabela CONDORXMLDUPL )
@type function
@author marce
@since 22/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRefDuplN()

	Local	nForA	
	
	BeginSql Alias cAliasS2
		COLUMN XML_EMISSA AS DATE
		COLUMN XDP_VENCTO AS DATE
		COLUMN E2_EMISSAO AS DATE
		COLUMN E2_VENCTO AS DATE
		SELECT XML_CHAVE,XDP_CHAVE
		FROM CONDORXML
		LEFT JOIN CONDORXMLDUPL
		ON XDP_CHAVE = XML_CHAVE
		WHERE XDP_CHAVE IS NULL
		AND XML_TIPODC = 'N'
		AND XML_EMIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND XML_EMISSA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND XML_DEST = %Exp:SM0->M0_CGC%   
		AND XML_REJEIT = ' '
	EndSql
	
	aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
	Pergunte("XMLDCONDOR",.F.)
	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter To
	
	DbSelectArea(cAliasS2)
	While !Eof()
		
		
		cAviso	:= ""
		cErro	:= ""
		
		U_DbSelArea("CONDORXML",.F.,1)
		DbSeek((cAliasS2)->XML_CHAVE)
		
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
				U_DbSelArea("CONDORXMLDUPL",.F.,1)
				lExistParc := !DbSeek((cAliasS2)->XML_CHAVE)
				RecLock("CONDORXMLDUPL",lExistParc)
				CONDORXMLDUPL->XDP_CHAVE	:= (cAliasS2)->XML_CHAVE
				CONDORXMLDUPL->XDP_PARCEL	:= " "
				CONDORXMLDUPL->XDP_VENCTO	:= CTOD("")
				CONDORXMLDUPL->XDP_VALOR	:= 0
				MsUnlock()
				DbSelectArea(cAliasS2)
				(cAliasS2)->(DbSkip())
				Loop
			Endif
		Endif
		
		If Type("oNF:_InfNfe:_Cobr") <> "U"
			oCobr		:= oNF:_InfNfe:_Cobr
		Else
			U_DbSelArea("CONDORXMLDUPL",.F.,1)
			lExistParc := !DbSeek((cAliasS2)->XML_CHAVE)
			RecLock("CONDORXMLDUPL",lExistParc)
			CONDORXMLDUPL->XDP_CHAVE	:= (cAliasS2)->XML_CHAVE
			CONDORXMLDUPL->XDP_PARCEL	:= " "
			CONDORXMLDUPL->XDP_VENCTO	:= CTOD("")
			CONDORXMLDUPL->XDP_VALOR	:= 0
			MsUnlock()
			DbSelectArea(cAliasS2)
			(cAliasS2)->(DbSkip())
			Loop
		Endif
		oIdent     	:= oNF:_InfNfe:_IDE
		oEmitente  	:= oNF:_InfNfe:_Emit
		
		If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
			oNF 	:= oNFe:_NFeProc:_NFe
			cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
		Else
			cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
		Endif
		
		If Type("oCobr:_dup") <> "U"
			oDup  		:= oCobr:_dup
			oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
			lOnlyDup	:= Len(oDup) == 1
			cParcela 	:= " "
			For nForA := 1 To Len(oDup)
				nP	:= nForA 
				If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
					
					U_DbSelArea("CONDORXMLDUPL",.F.,1)
				
					If lOnlyDup
						cParcela := " "
					Else
						cParcela := IF(nP>1,MaParcela(cParcela),IIF(Empty(cParcela),"A",cParcela))
					Endif
					// Verificou que a chave j[a existe na base
				
					lExistParc := !DbSeek(cChave + cParcela)
					RecLock("CONDORXMLDUPL",lExistParc)
					CONDORXMLDUPL->XDP_CHAVE	:= cChave
					CONDORXMLDUPL->XDP_PARCEL	:= cParcela
					CONDORXMLDUPL->XDP_VENCTO	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
					CONDORXMLDUPL->XDP_VALOR	:= Val(oDup[nP]:_vDup:TEXT)
					MsUnlock()
				Endif
			Next nForA
		Endif
		
		DbSelectArea(cAliasS2)
		(cAliasS2)->(DbSkip())
	Enddo
	
	DbSelectArea(cAliasS2)
	(cAliasS2)->(DbCloseArea())
	StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
Return


/*/{Protheus.doc} sfRefDuplF
(Refaz duplicatas na tabela CONDORXMLDUPL de conhecimentos de frete)
@type function
@author marce
@since 22/05/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfRefDuplF()
	
	Local	nForA 
	
	BeginSql Alias cAliasS3
		COLUMN XML_EMISSA AS DATE
		COLUMN XDP_VENCTO AS DATE
		COLUMN E2_EMISSAO AS DATE
		COLUMN E2_VENCTO AS DATE
		SELECT XML_CHAVE,XDP_CHAVE
		FROM CONDORXML
		LEFT JOIN CONDORXMLDUPL
		ON XDP_CHAVE = XML_CHAVE
		WHERE XDP_CHAVE IS NULL
		AND XML_TIPODC IN('F','T')
		AND XML_EMIT BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND XML_EMISSA BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND XML_DEST = %Exp:SM0->M0_CGC%
		AND XML_REJEIT = ' '
		   
	EndSql
	aRestPerg	:= StaticCall(CRIATBLXML,RestPerg,.T./*lSalvaPerg*/,/*aPerguntas*/,/*nTamSx1*/)
	Pergunte("XMLDCONDOR",.F.)
	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter To
	
	DbSelectArea(cAliasS3)
		
	While !Eof()
		
		
		cAviso	:= ""
		cErro	:= ""
		
		U_DbSelArea("CONDORXML",.F.,1)
		DbSeek((cAliasS3)->XML_CHAVE)
		
		oNfe := XmlParser(CONDORXML->XML_ARQ,"_",@cAviso,@cErro)
	
	
		If Type("oNFe:_CTeProc")<> "U"
			oNF := oNFe:_CTeProc:_CTe
		ElseIf Type("oNFe:_CTe")<> "U"
			oNF := oNFe:_CTe
		ElseIf Type("oNFe:_enviCTe:_CTe")<> "U"
			oNF := oNFe:_enviCTe:_CTe
		ElseIf Type("oNFe:_cteProc")<> "U"
			oNF := oNFe:_cteProc:_CTe
		Else
			U_DbSelArea("CONDORXMLDUPL",.F.,1)
			lExistParc := !DbSeek((cAliasS3)->XML_CHAVE)
			RecLock("CONDORXMLDUPL",lExistParc)
			CONDORXMLDUPL->XDP_CHAVE	:= (cAliasS3)->XML_CHAVE
			CONDORXMLDUPL->XDP_PARCEL	:= " "
			CONDORXMLDUPL->XDP_VENCTO	:= CTOD("")
			CONDORXMLDUPL->XDP_VALOR	:= 0
			MsUnlock()
			DbSelectArea(cAliasS3)
			(cAliasS3)->(DbSkip())
			Loop
		Endif
		
		If Type("oInfCte:_cobr") <> "U"
			oCobr		:= oInfCte:_cobr
		Else
			U_DbSelArea("CONDORXMLDUPL",.F.,1)
			lExistParc := !DbSeek((cAliasS3)->XML_CHAVE)
			RecLock("CONDORXMLDUPL",lExistParc)
			CONDORXMLDUPL->XDP_CHAVE	:= (cAliasS3)->XML_CHAVE
			CONDORXMLDUPL->XDP_PARCEL	:= " "
			CONDORXMLDUPL->XDP_VENCTO	:= CTOD("")
			CONDORXMLDUPL->XDP_VALOR	:= 0
			MsUnlock()
			DbSelectArea(cAliasS3)
			(cAliasS3)->(DbSkip())
			Loop
		Endif
	
		If Type("oNFe:_CTeProc:_protCTe:_infProt:_chCTe")<> "U"
			cChave	:= oNFe:_CTeProc:_protCTe:_infProt:_chCTe:TEXT
		ElseIf Type("oNFe:_enviCTe:_protCTe:_infProt:_chCTe")<> "U"
			cChave	:= oNFe:_enviCTe:_protCTe:_infProt:_chCTe:TEXT
		Else
			cChave	:= oEmitente:_CNPJ:TEXT+Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nCT:TEXT)) )+oIdent:_nCT:TEXT,TamSX3("F1_DOC")[1])
		Endif
	
		If Type("oCobr:_dup") <> "U"
			oDup  		:= oCobr:_dup
			oDup 		:= IIf(ValType(oDup)=="O",{oDup},oDup)
			lOnlyDup	:= Len(oDup) == 1
			For nForA := 1 To Len(oDup)
				nP := nForA 
				If Type("oDup[nP]:_vDup") <> "U" .And. Type("oDup[nP]:_dVenc") <> "U"
					
					U_DbSelArea("CONDORXMLDUPL",.F.,1)
				
					If lOnlyDup
						cParcela := " "
					Else
						cParcela := IF(nP>1,MaParcela(cParcela),IIF(Empty(cParcela),"A",cParcela))
					Endif
					// Verificou que a chave j[a existe na base
				
					lExistParc := !DbSeek(cChave + cParcela)
					RecLock("CONDORXMLDUPL",lExistParc)
					CONDORXMLDUPL->XDP_CHAVE	:= cChave
					CONDORXMLDUPL->XDP_PARCEL	:= cParcela
					CONDORXMLDUPL->XDP_VENCTO	:= STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))
					CONDORXMLDUPL->XDP_VALOR	:= Val(oDup[nP]:_vDup:TEXT)
					MsUnlock()
				Endif
			Next nForA 
		Endif
		
		DbSelectArea(cAliasS3)
		(cAliasS3)->(DbSkip())
	Enddo
	
	DbSelectArea(cAliasS3)
	(cAliasS3)->(DbCloseArea())
	StaticCall(CRIATBLXML,RestPerg,/*lSalvaPerg*/,aRestPerg/*aPerguntas*/,/*nTamSx1*/)
	
Return
