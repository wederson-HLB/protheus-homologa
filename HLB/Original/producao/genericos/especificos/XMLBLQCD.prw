#Include 'Protheus.ch'

/*/{Protheus.doc} XMLBLQCD
(Fun��o para manuten��o dos motivos de Bloqueios de Lan�amentos autom�ticos - )
@type function
@author marce
@since 04/11/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XMLBLQCD()


	Local	aHeadConv	:= {}
	Local	aColsConv	:= {}
	Local	aSize 		:= MsAdvSize(,.F.,400)

	DEFINE MSDIALOG oDlgConv TITLE OemToAnsi("Cadastro e manuten��o de C�digos de Bloqueios de lan�amentos") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

	oDlgConv:lMaximized := .T.

	oPanel1 := TPanel():New(0,0,'',oDlgConv, oDlgConv:oFont, .T., .T.,, ,200,35,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlgConv, oDlgConv:oFont, .T., .T.,, ,200,40,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	Private nPxCodBlq   := 1
	Private nPxTipEnv 	:= 2
	Private nPxTipoDes	:= 3
	Private nPxDesBlq   := 4
	Private nPxEmail  	:= 6
	Private nPxBlqLco	:= 5
	
	Aadd(aHeadConv,{"C�d.Bloqueio"		,"XBLCODMOT"	 	,"@!"		,2				,0		,""		,	,"C"	,""				,"R",,,,"V"})
	Aadd(aHeadConv,{"Op��o Envio"		,"XBLTIPENV"	 	,"@!"     	,1				,0		,""		,	,"C"	,""				,"R","M=Bloqueios Lcto Manual;A=Bloqueios Lcto Autom�ticos;T=Ambos Lctos;N=N�o envia alerta","A"})
	AAdd(aHeadConv,{"Tipo Destinat�rio" ,"XBLOPMAIL" 		,"@!"		,1				,0		,""		,	,"C"	,""				,"R","C=Em C�pia;R=Novo remetente;M=Mant�m remetente original","M"})
	Aadd(aHeadConv,{"Descri��o"			,"XBLDESMOT"		,"@!"     	,120			,0		,""		,	,"C"	,""				,"R",,,,"V"})
	AAdd(aHeadConv,{"Bloqueia Lacto?"   ,"XBLBLQLCO" 		,"@!"		,1				,0		,""		,	,"C"	,""				,"R","1=Sim;2=N�o","1"})
	Aadd(aHeadConv,{"E-mail Destino"	,"XBLEMAILD"		,"@"     	,250			,0		,""		,	,"C"	,""				,"R"})
	
	sfMontaCols(@aColsConv)

	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD

	Private oConvGet := MsNewGetDados():New(034, 005, 226, 415,GD_UPDATE,"AllwaysTrue()"/*cLinhaOk*/,;
	"AllwaysTrue()"/*cTudoOk*/,"",;
	,0/*nFreeze*/,10000/*nMax*/,"U_XMLBLQCG()"/*cCampoOk*/,/*cSuperApagar*/,;
	/*cApagaOk*/,oPanel2,@aHeadConv,@aColsConv,)

	oConvGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	ACTIVATE MSDIALOG oDlgConv ON INIT (oConvGet:oBrowse:Refresh(),EnchoiceBar(oDlgConv,{|| Processa({||sfGravaConv(),},"Gravando dados..."),oDlgConv:End()},{|| oDlgConv:End()},,))

Return



/*/{Protheus.doc} sfMontaCols
(long_description)
@author MarceloLauschner
@since 29/06/2014
@version 1.0
@param aColsConv, array, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function sfMontaCols(aColsConv)

	Local	cQry	:= ""
	Local	cItem	:= "01"

	Local	nLenArr	:= 0
	Local	aArrMot	:= {}
	Local	iX		:= 0
	Local   lBlqEmp	:= GetNewPar("XM_BLQXEMP",.F.) 

	Aadd(aArrMot,{"A1","Emitente de nota fiscal n�o cadastrado como cliente                                                                     "})
	Aadd(aArrMot,{"A2","Emitente de nota fiscal n�o cadastrado como fornecedor                                                                  "})
	Aadd(aArrMot,{"A4","Transportada informada no Pedido de compra n�o coincide com transportadora informada na nota fiscal                     "})
	Aadd(aArrMot,{"A5","Cadastro de Produto X Fornecedor com mais de um cadastro                                                                "})
	Aadd(aArrMot,{"AL","Divergencia de aliquota de ICMS ao validar CTE                                                                          "})
	Aadd(aArrMot,{"B1","N�o h� Refer�ncia Protheus informada numa linha do Getdados                                                             "})
	Aadd(aArrMot,{"C7","Mais de um pedido de compra ou item de pedido de compra em aberto para o produto                                        "})
	Aadd(aArrMot,{"C8","Valida��o antes de gravar e com Saldo de pedido de compra insuficiente para um produto                                  "})
	Aadd(aArrMot,{"C9","Bloqueio de NFe por diverg�ncia de Tolerancia de recebimento de materiais                                               "})
	Aadd(aArrMot,{"CC","Recebida CCe para o XML                                                                                                 "})
	Aadd(aArrMot,{"CF","Diverg�ncia de CFOP 'De/Para'                                                                                           "})
	Aadd(aArrMot,{"CS","Ajuste de c�digo CEST/NCM via Plugin XMLCTE17                                                                           "})
	Aadd(aArrMot,{"CT","Conhecimento de frete vinculado � uma nota fiscal j� vinculada em outro CTe                                             "})
	Aadd(aArrMot,{"CW","Somente um Saldo de pedido de compra e insuficiente para vincular a quantidade total do produto                         "})
	Aadd(aArrMot,{"CY","Nenhum saldo de pedido de compra dispon�vel para vincular o produto                                                     "})
	Aadd(aArrMot,{"DI","Divergencia de impostos entre o lan�amento e o constante no XML                                                         "})
	Aadd(aArrMot,{"DF","Erro ao validar Ponto de entrada MT103DNF                                                                               "})
	Aadd(aArrMot,{"DP","Divergencia de duplicatas entre o lan�amento e o constante no XML                                                       "})
	Aadd(aArrMot,{"DT","Divergencia de impostos entre o lan�amento e o constante no XML por item ajustado na rotina Confer�ncia Impostos		"})
	Aadd(aArrMot,{"DV","Notas de Devolu��o de Venda e Beneficiamento n�o contepladas na rotina autom�tica                                       "})
	Aadd(aArrMot,{"E1","Erro ao ler XML para gravar a nota fiscal                                                                               "})
	Aadd(aArrMot,{"E2","Erro ao validar o schema Xml ao tentar lan�ar a nota                                                                    "})
	Aadd(aArrMot,{"E3","Empresa errada! Destinat�rio � diferente do CNPJ do XML                                                                 "})
	Aadd(aArrMot,{"E4","Nota fiscal informada j� foi lan�ada no sistema                                                                         "})
	Aadd(aArrMot,{"E5","Nota fiscal n�o foi conferida pela na Sefaz                                                                             "})
	Aadd(aArrMot,{"E6","O valor dos produtos constantes no xml � diferente do valor apurado pela aloca��o de produtos                           "})
	Aadd(aArrMot,{"E7","Erro ao validar schema xml de CTE para inclus�o frete sobre vendas                                                      "})
	Aadd(aArrMot,{"E8","N�o possivel ler o arquivo XML para lan�ar o Cte                                                                        "})
	Aadd(aArrMot,{"ED","N�o h� natureza padr�o no cadastro do fornecedor para lan�amento automatico do CTE                                      "})
	Aadd(aArrMot,{"ET","Nota fiscal de entrada emitida por terceiros                                                                            "})
	Aadd(aArrMot,{"FC","Lan�amento de Frete sobre entradas n�o dispon�vel na fun��o Autom�tica                                                  "})
	Aadd(aArrMot,{"F1","Erro ao validar Schema XML de CTe lan�amento de frete sobre compras                                                     "})
	Aadd(aArrMot,{"GR","Erro ao gravar a nota fiscal                                                                                            "})
	Aadd(aArrMot,{"IC","Aliquota de ICMS para CTe diferente do esperado                                                                         "})
	Aadd(aArrMot,{"IE","Inscri��o Estadual do Emitente diferente do cadastro do sistema                                                         "})
	Aadd(aArrMot,{"N1","Nfe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"N2","Nfe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"N3","Nfe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"NC","Produto com divergencia de NCM entre o cadastro do sistema e o que consta XML                                           "})
	Aadd(aArrMot,{"NN","NFe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"NO","NFe Bloqueado para lan�amento autom�tico                                                                                "})
	Aadd(aArrMot,{"OR","Produto com divergencia de Origem ou CST de ICMS                                                                        "})
	Aadd(aArrMot,{"P3","N�o h� saldo para poder de terceiros                                                                                    "})
	Aadd(aArrMot,{"PC","Pedido de compra obrigat�rio por�m n�o informado no produto                                                             "})
	Aadd(aArrMot,{"PN","NFe validada e liberada para escriturar como pr�-nota                                                                   "})
	Aadd(aArrMot,{"PR","Nem todos os itens tem o TES Preenchido for�ando a gera��o de Pr�nota. Por�m no autom�tico n�o est� habilitado          "})
	Aadd(aArrMot,{"RO","N�o permitido lan�ar NFe como pr�-nota quando documento contenha Nota de Origem para vincular.                          "})
	Aadd(aArrMot,{"RJ","Nota fiscal rejeitada                                                                                                   "})
	Aadd(aArrMot,{"SE","N�o condi��o de pagamento padr�o no cadastro do fornecedor para lan�amento CTE                                          "})
	Aadd(aArrMot,{"SN","Cadastro de Fornecedor com diferen�a na configura��o de Simples Nacional com rela��o ao Regime encontrado no XML        "})
	Aadd(aArrMot,{"T1","CTe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"T2","CTe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"T3","CTe na Fila de Processamento autom�tico                                                                                 "})
	Aadd(aArrMot,{"TF","Tipo de Frete divergente entre o Pedido de Compra e o XML                                                               "})
	Aadd(aArrMot,{"TO","CTe Bloqueado para lan�amento autom�tico                                                                                "})
	Aadd(aArrMot,{"TT","CTe na Fila de Processamento autom�tico                                                                                 "})
	
	U_DbSelArea("CONDORBLQAUTO",.F.,1)
	
	For iX 	:= 1 To Len(aArrMot)
		If lBlqEmp
			lExistChv := !DbSeek(cEmpAnt+aArrMot[iX,1])
		Else
			lExistChv := !DbSeek(aArrMot[iX,1])
		Endif
		RecLock("CONDORBLQAUTO",lExistChv)
		
		If lBlqEmp 
			CONDORBLQAUTO->XBL_CODMOT	:= cEmpAnt+aArrMot[iX,1]
		Else
			CONDORBLQAUTO->XBL_CODMOT	:= aArrMot[iX,1]		
		Endif
		If lExistChv
			CONDORBLQAUTO->XBL_DESMOT	:= aArrMot[iX,2]
		Endif
		// Atualiza para op��o Autom�tico em todos os casos que esteja em branco
		If Empty(CONDORBLQAUTO->XBL_TIPENV)
			CONDORBLQAUTO->XBL_TIPENV 	:= "T"
		Endif
		// Atualiza��o para op��o M-Mant�m Remetente em todos os casos que esteja em Branco
		If Empty(CONDORBLQAUTO->XBL_OPMAIL)
			CONDORBLQAUTO->XBL_OPMAIL 	:= IIf(Empty(CONDORBLQAUTO->XBL_EMAILD),"M","R")
		Endif
		MsUnlock()
	Next

	U_DbSelArea("CONDORBLQAUTO",.F.,1)
	If lBlqEmp 
		Set Filter To Substr(XBL_CODMOT,1,Len(cEmpAnt)) == cEmpAnt
	Else
		Set Filter To Empty(Substr(XBL_CODMOT,3,Len(cEmpAnt))) 
	Endif
	DbGotop()
	While !Eof()
		
			
		Aadd(aColsConv,Array(7))

		nLenArr	:= Len(aColsConv)

		aColsConv[nLenArr,nPxCodBlq]	:= Iif(lBlqEmp,Substr(CONDORBLQAUTO->XBL_CODMOT,Len(cEmpAnt)+1,2),CONDORBLQAUTO->XBL_CODMOT) 
		aColsConv[nLenArr,nPxTipEnv]	:= CONDORBLQAUTO->XBL_TIPENV 
		aColsConv[nLenArr,nPxDesBlq]	:= CONDORBLQAUTO->XBL_DESMOT 
		aColsConv[nLenArr,nPxEmail]		:= CONDORBLQAUTO->XBL_EMAILD 
		aColsConv[nLenArr,nPxTipoDes]	:= CONDORBLQAUTO->XBL_OPMAIL
		aColsConv[nLenArr,nPxBlqLco]	:= CONDORBLQAUTO->XBL_BLQLCO
		aColsConv[nLenArr,7]			:= .F. 
		
		DbSkip()
	Enddo
	Set Filter To 
	aSort(aColsConv,,,{|x,y| x[nPxCodBlq] < y[nPxCodBlq]})

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

	Local	nX
	Local   lBlqEmp	:= GetNewPar("XM_BLQXEMP",.F.) 
	
	For nX := 1 To Len(oConvGet:aCols)

		If !oConvGet:aCols[nX,Len(oConvGet:aHeader)+1]
			U_DbSelArea("CONDORBLQAUTO",.F.,1)
			If DbSeek(Iif(lBlqEmp,cEmpAnt,"")+oConvGet:aCols[nX,nPxCodBlq])
				RecLock("CONDORBLQAUTO",.F.)
				CONDORBLQAUTO->XBL_CODMOT	:= Iif(lBlqEmp,cEmpAnt,"")+oConvGet:aCols[nX,nPxCodBlq]
				CONDORBLQAUTO->XBL_TIPENV	:= oConvGet:aCols[nX,nPxTipEnv]
				CONDORBLQAUTO->XBL_DESMOT	:= oConvGet:aCols[nX,nPxDesBlq]
				CONDORBLQAUTO->XBL_EMAILD	:= oConvGet:aCols[nX,nPxEmail]
				CONDORBLQAUTO->XBL_OPMAIL	:= oConvGet:aCols[nX,nPxTipoDes]
				CONDORBLQAUTO->XBL_BLQLCO	:= oConvGet:aCols[nX,nPxBlqLco] 
				MsUnlock()
			Endif
		Endif
	Next

Return


/*/{Protheus.doc} XMLBLQCG
(Valida��o de campo do GetDados)
@type function
@author marce
@since 04/11/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XMLBLQCG()

	Local		lRet		:= .T.
	Local		nYQ			:= 0
	Local		cVarAux		:= ""
	Local		aArrAux		:= {}
	Local		aAreaOld	:= GetArea()

	If ReadVar() == "M->XBLEMAILD"
		cVarAux	:= M->XBLEMAILD
		aArrAux	:= StrTokArr(Alltrim(cVarAux)+";",";")
		cVArAux	:= ""
		For nYQ	:= 1 To Len(aArrAux)
			If IsEmail(Alltrim(Lower(aArrAux[nYQ])))
				If !Empty(cVarAux)
					cVarAux += ";"
				Endif
				If !Alltrim(Lower(aArrAux[nYQ])) $ cVarAux
					cVarAux	+= Alltrim(Lower(aArrAux[nYQ]))
				Endif
			Endif
		Next
		M->XBLEMAILD	:= Padr(cVarAux,250)
	Endif

	RestArea(aAreaOld)

Return lRet



