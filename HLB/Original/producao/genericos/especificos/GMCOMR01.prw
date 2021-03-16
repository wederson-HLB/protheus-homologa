#INCLUDE 'PROTHEUS.CH'
#include 'totvs.ch'

/*/{Protheus.doc} GMCOMR01
(Analisar eficiencia escrituracao Notas X Central XML)

@author MarceloLauschner
@since 17/07/2013
@version 1.0

@return Sem retorno

@example
(examples)

@see (links_or_references)
/*/
User Function GMCOMR01()
	
	Local 	oReport
	Private cPerg1	  := ValidPerg("GMCOMR01")
	Private cAliasS1  := GetNextAlias()
	
	oReport	:= ReportDef()
	oReport:PrintDialog()
	
	
Return



/*/{Protheus.doc} ReportDef
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0

@return Nil, (Sem retorno)

@example
(examples)

@see (links_or_references)
/*/
Static Function ReportDef()
	
	Local oReport,oSection1
	Local clNomProg		:= "GMCOMR01"
	Local clTitulo 		:= "Relatório de Acompanhamento de Eficiência Central XML"
	Local clDesc   		:= "Relatório de Acompanhamento de Eficiência Central XML"
	If Type("lMadeira") == "L" .And. lMadeira
		clTitulo	:= "Ciclo de lançamento de NFe/CTe "+DTOC(dDataBase)
		clDesc		:= clTitulo
	Endif
	Pergunte(cPerg1,.T.)
	//oReport  := TReport():New( cReport, cTitulo, "ATR210" , { |oReport| ATFR210Imp( oReport, cAlias1, cAlias2, aOrdem ) }, cDescri )
	
	oReport:=TReport():New(clNomProg,clTitulo,,{|oReport| ReportPrint(oReport)},clDesc)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage	:= .F.		// Não imprime pagina de parametros
	oReport:SetLandScape()
	
	oSection1 := TRSection():New(oReport,"Data Emissão X Data Escrituração",{},{"Fornecedor+Documento","Emissão+Fornecedor","Dias=Digitação(-)Emissão","Documento","Digitação(-)Emissão Decresc."})
	//TRSection():New( oReport, STR0014 ,{}, aOrd ) // "Entidade Contabil"
	oSection1:SetColSpace(1)
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1,"FORNECE",,"Codigo","@!",6,.T.,{|| (cAliasS1)->F1_FORNECE })
	TRCell():New(oSection1,"LOJA",,"Lj","@!",2,.T.,{|| (cAliasS1)->F1_LOJA })
	TRCell():New(oSection1,"NOME",,"Razao Social","@!",35,.T.,{|| Alltrim((cAliasS1)->A2_NOME) })
	TRCell():New(oSection1,"TIPO",,"Tp","@!",1,.T.,{|| (cAliasS1)->F1_TIPO })
	TRCell():New(oSection1,"F1_DOC",,,,,,{|| (cAliasS1)->F1_DOC })
	TRCell():New(oSection1,"SERIE",,"Sr","@!",3,.T.,{|| (cAliasS1)->F1_SERIE })
	If MV_PAR03 == 1
		TRCell():New(oSection1,"F1_EMISSAO",,,,,,{|| (cAliasS1)->F1_EMISSAO })
		TRCell():New(oSection1,"HORA",,"Hora","",8,.T.,{|| cHora })
		TRCell():New(oSection1,"RECEBIDO",,"Recebido","",10,,{|| CONDORXML->XML_RECEB })
		TRCell():New(oSection1,"HORA",,"Hr Rec.","",8,.T.,{|| CONDORXML->XML_HORREC })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora })
		TRCell():New(oSection1,"F1_DTDIGIT",,,,,,{|| (cAliasS1)->F1_DTDIGIT })
		TRCell():New(oSection1,"HORA",,"Hr Lcto","",8,.T.,{|| CONDORXML->XML_HORLANC })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias1 })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora1 })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias2 })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora2 })
	ElseIf MV_PAR03 == 2
		TRCell():New(oSection1,"F1_EMISSAO",,,,,,{|| (cAliasS1)->F1_EMISSAO })
		TRCell():New(oSection1,"HORA",,"Hora","",8,.T.,{|| cHora })
		TRCell():New(oSection1,"RECEBIDO",,"Recebido","",10,,{|| CONDORXML->XML_RECEB })
		TRCell():New(oSection1,"HORA",,"Hr Rec.","",8,.T.,{|| CONDORXML->XML_HORREC })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora })
	ElseIf MV_PAR03 == 3
		TRCell():New(oSection1,"RECEBIDO",,"Recebido","",10,,{|| CONDORXML->XML_RECEB })
		TRCell():New(oSection1,"HORA",,"Hr Rec.","",8,.T.,{|| CONDORXML->XML_HORREC })
		TRCell():New(oSection1,"F1_DTDIGIT",,,,,,{|| (cAliasS1)->F1_DTDIGIT })
		TRCell():New(oSection1,"HORA",,"Hr Lcto","",8,.T.,{|| CONDORXML->XML_HORLANC })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias1 })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora1 })
	ElseIf MV_PAR03 == 4
		TRCell():New(oSection1,"F1_EMISSAO",,,,,,{|| (cAliasS1)->F1_EMISSAO })
		TRCell():New(oSection1,"HORA",,"Hora","",8,.T.,{|| cHora })
		TRCell():New(oSection1,"F1_DTDIGIT",,,,,,{|| (cAliasS1)->F1_DTDIGIT })
		TRCell():New(oSection1,"HORA",,"Hr Lcto","",8,.T.,{|| CONDORXML->XML_HORLANC })
		TRCell():New(oSection1,"DIFDIA",,"Dif.Dias","",5,.T.,{|| nDias2 })
		TRCell():New(oSection1,"DIFHORA",,"Horas","",5,.T.,{|| cDifHora2 })
	Endif
	TRCell():New(oSection1,"USRLAN",,"Usr.Lanc","",15,.T.,{|| CONDORXML->XML_USRLAN })
	TRCell():New(oSection1,"CHVNFE",,"Chave Eletronica","",44,.T.,{|| cChvNfe })
	TRCell():New(oSection1,"OBSERV",,"Observação","",20,.T.,{|| cObserv })
	
	//TRFunction():New(oSection1:Cell("F2_VALFAT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	
	
Return(oReport)


/*/{Protheus.doc} ReportPrint
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0

@param oReport, objeto, (Descrição do parâmetro)


@example
(examples)

@see (links_or_references)
/*/
Static Function ReportPrint( oReport )
	
	Local oSection1 	:= oReport:Section(1)
	Local cFilEspecie   := Iif(MV_PAR04==1,"SPED",Iif(MV_PAR04==2,"CTE","SPED','CTE"))
	Local cSelCol		:= "%F1_DTDIGIT,%"
	
	//	{"Fornecedor+Documento","Emissão+Fornecedor","Documento"}
	If  oSection1:GetOrder() == 1
		cOrder := "%F1_FORNECE,F1_LOJA,F1_DOC%"
	ElseIf oSection1:GetOrder() == 2
		cOrder := "%F1_EMISSAO,F1_FORNECE,F1_LOJA,F1_DOC%"
	ElseIf oSection1:GetOrder() == 3
		If Upper(TcGetDb()) $"ORACLE"
			cSelCol := "%TO_DATE(F1_DTDIGIT,'YYYYMMDD') - TO_DATE(F1_EMISSAO,'YYYYMMDD'),%"
			cOrder	:= "%1%"
		ElseIf Upper(TcGetDb()) $ "MSSQL"
			cSelCol := "%CONVERT(datetime,F1_DTDIGIT,112) - CONVERT(datetime,F1_EMISSAO,112),%
			cOrder	:= "%1%"
		Else
			cOrder	:= "%F1_DTDIGIT%
		Endif
	ElseIf oSection1:GetOrder() == 5
		If Upper(TcGetDb()) $"ORACLE"
			cSelCol := "%TO_DATE(F1_DTDIGIT,'YYYYMMDD') - TO_DATE(F1_EMISSAO,'YYYYMMDD'),%"
			cOrder	:= "%1 DESC%"
		ElseIf Upper(TcGetDb()) $ "MSSQL"
			cSelCol := "%CONVERT(datetime,F1_DTDIGIT,112) - CONVERT(datetime,F1_EMISSAO,112),%
			cOrder	:= "%1 DESC%"
		Else
			cOrder	:= "%F1_DTDIGIT%
		Endif
	Else
		cOrder := "%F1_DOC%"
	Endif
	
	U_DbSelArea("CONDORXML",.F.,1)
	Set Filter To
	
	oSection1:Init()
	
	BeginSql Alias cAliasS1
		COLUMN F1_EMISSAO AS DATE
		COLUMN F1_DTDIGIT AS DATE
		SELECT %Exp:cSelCol% F1_EMISSAO,F1_FORNECE,F1_LOJA,A2_NOME,F1_DOC,F1_SERIE,F1_TIPO,F1_HORA,F1_DTDIGIT,F1_CHVNFE,F1_FILIAL
		FROM %Table:SF1% SF1,%Table:SA2% SA2
		WHERE SF1.%NotDel%
		AND SA2.%NotDel%
		AND A2_CGC BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%
		AND A2_LOJA = F1_LOJA
		AND A2_COD = F1_FORNECE
		AND A2_FILIAL = %xFilial:SA2%
		AND F1_TIPO NOT IN('D','B')
		AND F1_ESPECIE IN( %Exp:cFilEspecie%)
		AND F1_DTDIGIT  BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND F1_EMISSAO BETWEEN %Exp:DTOS(MV_PAR09)% AND %Exp:DTOS(MV_PAR10)%
		AND F1_LOJA BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08%
		AND F1_FORNECE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
		AND F1_FILIAL = %xFilial:SF1%
		UNION ALL
		SELECT %Exp:cSelCol% F1_EMISSAO,F1_FORNECE,F1_LOJA,A1_NOME,F1_DOC,F1_SERIE,F1_TIPO,F1_HORA,F1_DTDIGIT,F1_CHVNFE,F1_FILIAL
		FROM %Table:SF1% SF1,%Table:SA1% SA1
		WHERE SF1.%NotDel%
		AND SA1.%NotDel%
		AND A1_CGC BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%
		AND A1_LOJA = F1_LOJA
		AND A1_COD = F1_FORNECE
		AND A1_FILIAL = %xFilial:SA1%
		AND F1_TIPO IN('D','B')
		AND F1_ESPECIE IN( %Exp:cFilEspecie%)
		AND F1_FORMUL <> 'S'
		AND F1_DTDIGIT  BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
		AND F1_EMISSAO BETWEEN %Exp:DTOS(MV_PAR09)% AND %Exp:DTOS(MV_PAR10)%
		AND F1_LOJA BETWEEN %Exp:MV_PAR14% AND %Exp:MV_PAR16%
		AND F1_FORNECE BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR15%
		AND F1_FILIAL = %xFilial:SF1%
		ORDER BY  %Exp:cOrder%
	EndSql
	oReport:SetMeter(RecCount())
	
	
	While !Eof()
		
		oReport:IncMeter()
		
		U_DbSelArea("CONDORXML",.F.,1)
		
		If !DbSeek((cAliasS1)->F1_CHVNFE)
			cChvNfe	:= (cAliasS1)->F1_CHVNFE
			cObserv	:= "FALTA XML"
			lExistChv	:= .F.
		Else
			cChvNfe	:= (cAliasS1)->F1_CHVNFE
			cObserv	:= ""
			lExistChv	:= .T.
		Endif
		If !lExistChv
			U_DbSelArea("CONDORXML",.F.,4)
			If !DbSeek((cAliasS1)->F1_FILIAL+(cAliasS1)->F1_DOC+(cAliasS1)->F1_SERIE+(cAliasS1)->F1_FORNECE+(cAliasS1)->F1_LOJA+(cAliasS1)->F1_TIPO)
				cObserv	:= "FALTA XML"
				cChvNfe	:= (cAliasS1)->F1_CHVNFE
				lExistChv	:= .F.
			Else
			
				cObserv	:= "TEM XML"
				cChvNfe	:= Alltrim(CONDORXML->XML_CHAVE)
				lExistChv	:= .T.
			Endif
		Endif
		// Calcula a diferença entre o recebimento e a emissão
		cHora 		:= Substr(CONDORXML->XML_ARQ,AT('</dhRecbto>',CONDORXML->XML_ARQ)-8,8)
		nDias		:= sfCalcDias(CONDORXML->XML_RECEB,(cAliasS1)->F1_EMISSAO)
		cDifHora	:= cHora
		
		If cDifHora < CONDORXML->XML_HORREC
			cDifHora	:= SubHoras(CONDORXML->XML_HORREC,cDifHora)
		Else
			cDifHora	:= SubHoras(CONDORXML->XML_HORREC,cDifHora)+24
			nDias--
		Endif
		If nDias < 0
			nDias	:= 0
			cDifHora	-= 24
		Endif
		If !lExistChv
			nDias 		:= ""
			cDifHora    := ""
		Endif
		
		// Calcula a diferença entre a escrituração e o recebimento do xml
		nDias1		:= sfCalcDias((cAliasS1)->F1_DTDIGIT,CONDORXML->XML_RECEB)
		cDifHora1	:= CONDORXML->XML_HORREC
		
		If cDifHora1 < CONDORXML->XML_HORLANC
			cDifHora1	:= SubHoras(CONDORXML->XML_HORLANC,cDifHora1)
		Else
			cDifHora1	:= SubHoras(CONDORXML->XML_HORLANC,cDifHora1)+24
			nDias1--
		Endif
		If nDias1 < 0
			nDias1	:= 0
			cDifHora1	-= 24
		Endif
		If !lExistChv
			nDias1 		:= ""
			cDifHora1    := ""
		Endif
		
		
		// Calcula a diferença entre a escrituração e emissão
		cHora2 		:= Substr(CONDORXML->XML_ARQ,AT('</dhRecbto>',CONDORXML->XML_ARQ)-8,8)
		nDias2		:= sfCalcDias((cAliasS1)->F1_DTDIGIT,(cAliasS1)->F1_EMISSAO)
		cDifHora2	:= cHora2
		
		If cDifHora2 < CONDORXML->XML_HORLANC
			cDifHora2	:= SubHoras(CONDORXML->XML_HORLANC,cDifHora2)
		Else
			cDifHora2	:= SubHoras(CONDORXML->XML_HORLANC,cDifHora2)+24
			nDias2--
		Endif
		If nDias2 < 0
			nDias2	:= 0
			cDifHora2	-= 24
		Endif
		
		If !lExistChv
			cDifHora2    := ""
		Endif
		
		oSection1:PrintLine()
		DbSelectArea(cAliasS1)
		(cAliasS1)->(DbSkip())
	Enddo
	
	oSection1:Finish()
	
Return


//---------------------------------------------------------------------------------------
// Analista   : Marcelo Alberto Lauschner - 01/10/2009
// Nome função: ValidPerg
// Parametros :
// Objetivo   : Validar a existência das perguntas necessárias para a rotina
// Retorno    :
// Alterações :
//---------------------------------------------------------------------------------------

/*/{Protheus.doc} ValidPerg
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0

@param cPerg2, character, (Descrição do parâmetro)


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
	//          X1_GRUPO,X1_ORDEM,X1_PERGUNT         ,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01  ,X1_DEF01         ,X1_DEFSPA1,X1_DEFENG1,X1_CONT01,X1_VAR02,X1_DEF02         ,X1_DEFSPA2,X1_DEFENG2,X1_CONT02,X1_VAR03,X1_DEF03         ,X1_DEFSPA3,X1_DEFENG3,X1_CONT03,X1_VAR04,X1_DEF04         ,X1_DEFSPA4,X1_DEFENG4,X1_CONT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CONT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP,X1_PICTURE,X1_IDFIL
	Aadd(aRegs,{cPerg1  ,"01"      ,"Data Inicial   ",""       ,""       ,"mv_ch1"  ,"D"    ,08        ,0		 ,0		   ,"G"	  ,""	   ,"mv_par01",""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""      ,""        ,""        ,""       ,""   ,""     ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1  ,"02"      ,"Data Final"     ,""       ,""       ,"mv_ch2"  ,"D"    ,08        ,0		 ,0		   ,"G"	  ,""	   ,"mv_par02",""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""               ,""        ,""        ,""       ,""      ,""      ,""        ,""        ,""       ,""   ,""     ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1  ,"03"	   ,"Listar Relatório",""       ,""       ,"mv_ch3" ,"N"	,01		   ,0		 ,1		   ,"C"	  ,""	   ,"mv_par03","Todos           ",""        ,""	      ,""  	    ,""	     ,"Emissao X Recebto",""	  ,""        ,""	   ,""      ,"Recebto X Lacto",""	     ,""	    ,""		  ,""	   ,"Emissao X Lacto",""        ,""	       ,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	Aadd(aRegs,{cPerg1  ,"04"	   ,"Listar Tipos"    ,""       ,""       ,"mv_ch4" ,"N"	,01		   ,0		 ,1		   ,"C"	  ,""	   ,"mv_par04","SPED"           ,""        ,""	      ,""  	    ,""	     ,"CTE"             ,""	      ,""        ,""	   ,""      ,"Ambos"          ,""	     ,""	    ,""		  ,""	   ,"               ",""        ,""	       ,""		 ,""	  ,""      ,""        ,"" 		 ,""	   ,""	 ,""	 ,""       ,""     ,""        ,""})
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	
//     "X1_GRUPO" 		,"X1_ORDEM"	,"X1_PERGUNT"    			,"X1_PERSPA"				,"X1_PERENG"			,"X1_VARIAVL"	,"X1_TIPO"	,"X1_TAMANHO"		,"X1_DECIMAL"		,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID","X1_VAR01"	,"X1_DEF01"	,"X1_DEFSPA1"	,"X1_DEFENG1"	,"X1_CNT01","X1_VAR02","X1_DEF02"		,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02","X1_VAR03","X1_DEF03"	,"X1_DEFSPA3"	,"X1_DEFENG3"	,"X1_CNT03","X1_VAR04","X1_DEF04"	,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5"	,"X1_CNT05","X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"
	DbSeek("A2_COD")
	Aadd(aRegs,{cPerg1 ,"05"			,"Fornecedor de"			,"Fornecedor de "	 		,"Fornecedor de"		,"mv_ch5"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par05"	," "				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"SA2" 	,"S"		,"001"			,""})
	DbSeek("A2_LOJA")
	Aadd(aRegs,{cPerg1 ,"06"			,"Loja "					,"Loja "					,"Loja "				,"mv_ch6"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par06"	," "				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	DbSeek("A2_COD")
	Aadd(aRegs,{cPerg1 ,"07"			,"Fornecedor Até"			,"Fornecedor Até"	 		,"Fornecedor Até"		,"mv_ch7"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par07"	,"ZZZZZZ"			,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"SA2" 	,"S"		,"001"			,""})
	DbSeek("A2_LOJA")
	Aadd(aRegs,{cPerg1 ,"08"			,"Loja "					,"Loja "					,"Loja Até"			,"mv_ch8"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par08"	,"ZZ"				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"09"			,"Emissão de"				,"Emissão de "	 		,"Emissão de"			,"mv_ch9"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par09"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"10"			,"Emissão até"			,"Emissão até"			,"Emissão"				,"mv_chA"		,"D"		,8					,0					,0				,"G"		,""			,"mv_par10"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"11"			,"CNPJ De"					,"CNPJ De "		 		,"Fornecedor de"		,"mv_chB"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par11"	,""				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	Aadd(aRegs,{cPerg1 ,"12"			,"CNPJ Até"				,"Fornecedor Até"	 		,"Fornecedor Até"		,"mv_chC"		,"C"		,14					,0					,0				,"G"		,""			,"mv_par12"	,"ZZZZZZ"				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	DbSeek("A1_COD")
	Aadd(aRegs,{cPerg1 ,"13"			,"Cliente de"				,"Cliente de "	 		,"Cliente de"		   ,"mv_chD"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par13"	," "				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"SA1" 	,"S"		,"001"			,""})
	DbSeek("A1_LOJA")
	Aadd(aRegs,{cPerg1 ,"14"			,"Loja "					,"Loja "					,"Loja "				,"mv_chE"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par14"	," "				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	DbSeek("A1_COD")
	Aadd(aRegs,{cPerg1 ,"15"			,"Cliente Até"			,"Cliente Até"	 		,"Cliente Até"		,"mv_chF"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par15"	,"ZZZZZZ"			,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"SA1" 	,"S"		,"001"			,""})
	DbSeek("A1_LOJA")
	Aadd(aRegs,{cPerg1 ,"16"			,"Loja "					,"Loja "					,"Loja "				,"mv_chG"		,"C"		,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,0				,"G"		,""			,"mv_par16"	," "				,""				,""				,""			,""			,""					,""					,""					,""			,""			,""			,""					,""				,""			,""			,""				,""				,""				,""			,""			,""			,""				,""				,""			,"" 		,"S"		,""				,""})
	
	
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
			Next
			MsUnlock() */
		Endif
	Next
	
	RestArea(aAreaOld)
	
Return cPerg1



/*/{Protheus.doc} sfCalcDias
(long_description)

@author MarceloLauschner
@since 01/12/2013
@version 1.0

@param dDtFim, data, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)

@example
(examples)

@see (links_or_references)
/*/
Static Function sfCalcDias(dDtFim,dDtIni)
	
	Local	nDiasDif	:= dDtFim - dDtIni
	Local	nDiasRet	:= nDiasDif
	Local	iX
	
	For iX := 1 To nDiasDif
		If Dow(dDtIni+iX) ==1 .Or. Dow(dDtIni+iX) == 7
			nDiasRet--	// Subtrai os dias de fim de seman
		Endif
	Next
	
Return nDiasRet
