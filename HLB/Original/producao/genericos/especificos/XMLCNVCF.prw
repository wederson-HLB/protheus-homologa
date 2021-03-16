#Include 'Protheus.ch'


/*/{Protheus.doc} XMLCNVCF
(Rotina de gravação das conversões de CFOP de entrada X saída)
@author MarceloLauschner
@since 02/07/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XMLCNVCF()
	
	
	
	Local	aHeadConv	:= {}
	Local	aColsConv	:= {}
	Local	aSize 		:= MsAdvSize(,.F.,400)
	
	DEFINE MSDIALOG oDlgConv TITLE OemToAnsi("Cadastro de Conversões de Códigos Fiscais de Operação - Saída X Entrada") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	
	oDlgConv:lMaximized := .T.
	
	oPanel1 := TPanel():New(0,0,'',oDlgConv, oDlgConv:oFont, .T., .T.,, ,200,35,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oDlgConv, oDlgConv:oFont, .T., .T.,, ,200,40,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	Private nPxCodSai    := 1
	Private nPxDescSai 	:= 2
	Private nPxCodEnt    := 3
	Private nPxDescEnt 	:= 4
	
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("F4_CF")
	Aadd(aHeadConv,{"Cód.Fiscal Saída"		,"CFSAI"	 	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"",,SX3->X3_TIPO	,SX3->X3_F3	,""})
	Aadd(aHeadConv,{"Descrição Saída"		,"XDESCSAI"		,"@!"     			,40					,0					,"",,"C"			,""			,"R"})
	Aadd(aHeadConv,{"Cód.Fiscal Entrada"	,"CFENT"	 	,SX3->X3_PICTURE	,SX3->X3_TAMANHO	,SX3->X3_DECIMAL	,"",,SX3->X3_TIPO	,SX3->X3_F3	,""})
	Aadd(aHeadConv,{"Descrição Entrada"		,"XDESCENT"		,"@!"     			,40					,0					,"",,"C"			,""			,"R"})
	
	sfMontaCols(@aColsConv)
	
	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD
	
	Private oConvGet := MsNewGetDados():New(034, 005, 226, 415,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue()"/*cLinhaOk*/,;
		"AllwaysTrue()"/*cTudoOk*/,"",;
		,0/*nFreeze*/,10000/*nMax*/,"U_XMLCNVCG()"/*cCampoOk*/,/*cSuperApagar*/,;
		/*cApagaOk*/,oPanel2,@aHeadConv,@aColsConv,)
	
	oConvGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	
	ACTIVATE MSDIALOG oDlgConv ON INIT (oConvGet:oBrowse:Refresh(),EnchoiceBar(oDlgConv,{|| Processa({||sfGravaConv(),},"Gravando dados..."),oDlgConv:End()},{|| oDlgConv:End()},,))
	
Return



/*/{Protheus.doc} sfMontaCols
(long_description)
@author MarceloLauschner
@since 29/06/2014
@version 1.0
@param aColsConv, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfMontaCols(aColsConv)
	
	Local	cQry	:= ""
	Local	cItem	:= "01"
	Local	aConvCF	:= {}
	Local	iX			:= 0
	
	
	Aadd(aConvCF,		{"5101","1102","",""})
	Aadd(aConvCF,		{"6101","2102","",""})
	Aadd(aConvCF,		{"5102","1102","",""})
	Aadd(aConvCF,		{"6102","2102","",""})
	Aadd(aConvCF,		{"5401","1403","",""})
	Aadd(aConvCF,		{"6401","2403","",""})
	Aadd(aConvCF,		{"5403","1403","",""})
	Aadd(aConvCF,		{"6403","2403","",""})
	Aadd(aConvCF,		{"5405","1403","",""})
	Aadd(aConvCF,		{"6404","2403","",""})
	Aadd(aConvCF,		{"5910","1910","",""})
	Aadd(aConvCF,		{"6910","2910","",""})
	Aadd(aConvCF,		{"5911","1911","",""})
	Aadd(aConvCF,		{"6911","2911","",""})
	Aadd(aConvCF,		{"5912","1912","",""})
	Aadd(aConvCF,		{"6912","2912","",""})
	Aadd(aConvCF,		{"5118","1403","",""})
	Aadd(aConvCF,		{"6118","2403","",""})
	Aadd(aConvCF,		{"5118","1102","",""})
	Aadd(aConvCF,		{"6118","2102","",""})
	Aadd(aConvCF,		{"5119","1403","",""})
	Aadd(aConvCF,		{"6119","2403","",""})
	Aadd(aConvCF,		{"5119","1102","",""})
	Aadd(aConvCF,		{"6119","2102","",""})
	Aadd(aConvCF,		{"5120","1118","",""})
	Aadd(aConvCF,		{"6120","2118","",""})
	Aadd(aConvCF,		{"5923","1923","",""})
	Aadd(aConvCF,		{"6923","2923","",""})
	Aadd(aConvCF,		{"5924","1924","",""})
	Aadd(aConvCF,		{"6924","2924","",""})
	Aadd(aConvCF,		{"5922","1922","",""})
	Aadd(aConvCF,		{"6922","2922","",""})
	Aadd(aConvCF,		{"5116","1117","",""})
	Aadd(aConvCF,		{"6116","2117","",""})
	Aadd(aConvCF,		{"5117","1117","",""})
	Aadd(aConvCF,		{"6117","2117","",""})
	Aadd(aConvCF,		{"5119","1119","",""})
	Aadd(aConvCF,		{"6119","2119","",""})
	Aadd(aConvCF,		{"5118","1117","",""})
	Aadd(aConvCF,		{"6118","2117","",""})
	Aadd(aConvCF,		{"5949","1949","",""})
	Aadd(aConvCF,		{"6949","2949","",""})
	Aadd(aConvCF,		{"5917","1917","",""})
	Aadd(aConvCF,		{"6917","2917","",""})
	Aadd(aConvCF,		{"5907","1906","",""})
	Aadd(aConvCF,		{"5664","1664","",""})
	Aadd(aConvCF,		{"6652","2652","",""})
	Aadd(aConvCF,		{"5652","1652","",""})
	Aadd(aConvCF,		{"6655","2652","",""})
	Aadd(aConvCF,		{"6659","2659","",""})
	Aadd(aConvCF,		{"5411","1411","",""})
	Aadd(aConvCF,		{"5202","1202","",""})
	Aadd(aConvCF,		{"5902","1902","",""})
	Aadd(aConvCF,		{"5906","1906","",""})
	Aadd(aConvCF,		{"6101","2403","",""})
	Aadd(aConvCF,		{"5655","1652","",""})
	Aadd(aConvCF,		{"5402","1403","",""})
	Aadd(aConvCF,		{"6402","2403","",""})
	Aadd(aConvCF,		{"5112","1113","",""})
	Aadd(aConvCF,		{"6112","2113","",""})
	Aadd(aConvCF,		{"5113","1113","",""})
	Aadd(aConvCF,		{"6113","2113","",""})
	Aadd(aConvCF,		{"5901","1901","",""})
	Aadd(aConvCF,		{"6901","2901","",""})
	Aadd(aConvCF,		{"5915","1915","",""})
	Aadd(aConvCF,		{"5552","1552","",""})
	Aadd(aConvCF,		{"5905","1905","",""})
	Aadd(aConvCF,		{"5663","1663","",""})
	Aadd(aConvCF,		{"6411","2411","",""})
	
	
	U_DbSelArea("CONDORCONVCFOP",.F.,1)
	DbGotop()
	While !Eof()
		Aadd(aColsConv,{;
			CONDORCONVCFOP->XCF_CFSAI,;
			CONDORCONVCFOP->XCF_DESCS,;
			CONDORCONVCFOP->XCF_CFENT,;
			CONDORCONVCFOP->XCF_DESCE,;
			.F.})
		DbSelectArea("CONDORCONVCFOP")
		DbSkip()
	Enddo
	
	If Empty(aColsConv)
		For iX 	:= 1 To Len(aConvCF)
			DbSelectArea("SX5")
			DbSetOrder(1)
			If DbSeek(xFilial("SX5")+"13"+aConvCF[iX,1])
				aConvCF[ix,3]	:= SX5->X5_DESCRI
			Endif
			If DbSeek(xFilial("SX5")+"13"+aConvCF[iX,2])
				aConvCF[ix,4]	:= SX5->X5_DESCRI
			Endif
			Aadd(aColsConv,{;
				aConvCF[ix,1],;
				aConvCF[ix,3],;
				aConvCF[ix,2],;
				aConvCF[ix,4],;
				.F.})
		Next
	Endif
	
	
	If Len(aColsConv) == 0
		AADD(aCols,Array(5))
		aCols[Len(aCols)][1]	:= Space(TamSX3("F4_CF")[1])
		aCols[Len(aCols)][2]	:= Space(120)
		aCols[Len(aCols)][3]	:= Space(TamSX3("F4_CF")[1])
		aCols[Len(aCols)][4]	:= Space(120)
		aCols[Len(aCols)][5]	:= .F.
	Endif
	
	aSort(aColsConv,,,{|x,y| x[1]+x[3] < y[1]+y[3]})
	
Return


/*/{Protheus.doc} sfGravaConv
(Grava os dados da tela)
@author MarceloLauschner
@since 02/07/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfGravaConv()
	
	Local	cQry := ""
	Local	nX	
	
	For nX := 1 To Len(oConvGet:aCols)
		
		If !oConvGet:aCols[nX,Len(oConvGet:aHeader)+1] .And.;
		 !Empty(oConvGet:aCols[nX,nPxCodSai]) .And.;
		 !Empty(oConvGet:aCols[nX,nPxCodEnt])
			U_DbSelArea("CONDORCONVCFOP",.F.,1)
			lExistChv := !DbSeek(oConvGet:aCols[nX,nPxCodSai]+oConvGet:aCols[nX,nPxCodEnt])
			RecLock("CONDORCONVCFOP",lExistChv)
			CONDORCONVCFOP->XCF_CFSAI	:= oConvGet:aCols[nX,nPxCodSai]
			CONDORCONVCFOP->XCF_CFENT	:= oConvGet:aCols[nX,nPxCodEnt]
			CONDORCONVCFOP->XCF_DESCS	:= oConvGet:aCols[nX,nPxDescSai]
			CONDORCONVCFOP->XCF_DESCE	:= oConvGet:aCols[nX,nPxDescEnt]
			MsUnlock()
		ElseIf oConvGet:aCols[nX,Len(oConvGet:aHeader)+1] .And. !Empty(oConvGet:aCols[nX,nPxCodSai]) .And. !Empty(oConvGet:aCols[nX,nPxCodEnt])
			U_DbSelArea("CONDORCONVCFOP",.F.,1)
			If DbSeek(oConvGet:aCols[nX,nPxCodSai]+oConvGet:aCols[nX,nPxCodEnt])
				RecLock("CONDORCONVCFOP",.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif
	Next
	
Return

/*/{Protheus.doc} XMLCNVCG
(Validação da digitação dos campos)
@author MarceloLauschner
@since 02/07/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XMLCNVCG()
	
	Local		lRet		:= .T.
	Local		aAreaOld	:= GetArea()
	Local		nX 
	
	If ReadVar() == "M->CFENT"
		If NaoVazio() .And. ExistCpo("SX5","13"+M->CFENT)
			If M->CFENT >= "500"
				MsgAlert("Informar somente códigos de operação de entrada",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				lRet	:= .F.
			Endif
		Else
			lRet	:= .F.
		Endif
		
		If lRet	
			// Procura por duplicidade de código SaídaXEntrada
			For nX := 1 To Len(oConvGet:aCols)
		
				If !oConvGet:aCols[nX,Len(oConvGet:aHeader)+1] .And. nX # oConvGet:nAt
					If oConvGet:aCols[nX,nPxCodSai] == oConvGet:aCols[oConvGet:nAt,nPxCodSai] .And.;
						oConvGet:aCols[nX,nPxCodEnt] == M->CFENT
						MsgAlert("Combinação de código Saída X Entrada já informado nesta tela na linha '"+cValToChar(nX)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						lRet	:= .F.
				 	Endif
				Endif
			Next
			If lRet
				oConvGet:aCols[oConvGet:nAt,nPxDescEnt]	:= Posicione("SX5",1,xFilial("SX5")+"13"+M->CFENT,"X5_DESCRI")
			Endif
		Endif
		
	ElseIf ReadVar() == "M->CFSAI"
		If NaoVazio() .And. ExistCpo("SX5","13"+M->CFSAI)
			If M->CFSAI < "500"
				MsgAlert("Informar somente códigos de operação de saída",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
				lRet	:= .F.
			Endif
		Else
			lRet	:= .F.
		Endif
		
		If lRet	
			// Procura por duplicidade de código SaídaXEntrada
			For nX := 1 To Len(oConvGet:aCols)
		
				If !oConvGet:aCols[nX,Len(oConvGet:aHeader)+1] .And. nX # oConvGet:nAt
					If oConvGet:aCols[nX,nPxCodSai] == M->CFSAI .And. ;
						oConvGet:aCols[nX,nPxCodEnt] == oConvGet:aCols[oConvGet:nAt,nPxCodEnt]
						MsgAlert("Combinação de código Saída X Entrada já informado nesta tela na linha '"+cValToChar(nX)+"'",ProcName(0)+"."+ Alltrim(Str(ProcLine(0))))
						lRet	:= .F.
				 	Endif
				Endif
			Next
			If lRet
				oConvGet:aCols[oConvGet:nAt,nPxDescSai]	:= Posicione("SX5",1,xFilial("SX5")+"13"+M->CFSAI,"X5_DESCRI")
			Endif
		Endif
		
	Endif
	
	RestArea(aAreaOld)
	
Return lRet



