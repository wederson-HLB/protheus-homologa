#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "colors.ch"

User Function LNFAT001()
	Private _cPerg :="LNFAT001"+Space(02)
	Private oReport
	Private cFilterUser
	Private oSection1
	Private oFont , oFontN
	Private cTitulo := "Pick-List (Expedicao)"
	Private _cPedVenDe
	Private _cPedVenAte
	Private _nTpPedVen

	fCriaPerg()
	// Variaveis utilizadas para parametros                      ³
	// mv_par01  De Pedido                                       ³
	// mv_par02  Ate Pedido                                      ³
	// mv_par03  Imprime pedidos ? 1 - Estoque                   ³
	//                             2 - Credito                   ³
	//                             3 - Estoque/Credito           ³

    // MENU --> FAT_LN_01

	If Pergunte(_cPerg,.T.)
		_cPedVenDe     := Mv_Par01
		_cPedVenAte    := Mv_Par02
		_nTpPedVen     := Mv_Par03

		oReport:=ReportDef()
		oReport:PrintDialog()
	EndIf

Return

//-----------------------------------

Static Function ReportDef()
	Local _cPictTit := "@E@Z 99999,999.99"
	Local _cPictTot := "@E 99,999,999.99"
	Local oSection1
	Local oSection2
	Local aOrdem    := {}

	//oFontN :=TFont():New("Courier New",,08,,.T.,,,,.T.,.F.)// Negrito
	oFont  :=TFont():New("Courier New",,10,,.F.,,,,.F.,.F.)

	oReport:=TReport():New("LNFAT001",cTitulo,""/*_cPerg*/,{|oReport| ReportPrint(oReport)},"Emissao de produtos a serem separados pela expedicao, para determinada faixa de pedidos.")

	oReport:SetLandScape()

	oSection1:=TRSection():New(oReport,"Emissao de produtos a serem separados pela expedicao, para determinada faixa de pedidos.","SC9",aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)

	TRCell():New(oSection1,"C9_PRODUTO"    ,,"Código"                        ,"@!"                         ,TAMSX3("C9_PRODUTO")[1],.F.,)
	TRCell():New(oSection1,"B1_DESC"       ,,OemToAnsi("Desc. do Material")  ,"@!"                         ,TAMSX3("B1_DESC")[1]   ,.F.,)
	TRCell():New(oSection1,"B1_UM"         ,,OemToAnsi("UM")                 ,"@!"                         ,TAMSX3("B1_UM")[1]     ,.F.,)
	TRCell():New(oSection1,"QUANTIDADE"    ,,OemToAnsi("Quantidade")         ,PesqPict("SC9","C9_QTDLIB")  ,TAMSX3("C9_QTDLIB")[1] ,.F.,)
	TRCell():New(oSection1,"C9_LOCAL"      ,,"Amz"                           ,                             ,TAMSX3("C9_LOCAL")[1]  ,.F.,)
	TRCell():New(oSection1,"ENDERECO"      ,,OemToAnsi("Endereço")           ,                             ,TAMSX3("DC_LOCALIZ")[1],.F.,)
	TRCell():New(oSection1,"C9_LOTECTL"    ,,OemToAnsi("Lote")               ,"@!"                         ,TAMSX3("C9_LOTECTL")[1],.F.,)
	TRCell():New(oSection1,"C9_NUMLOTE"    ,,OemToAnsi("SubLote")            ,"@!"                         ,TAMSX3("C9_NUMLOTE")[1],.F.,)
	TRCell():New(oSection1,"C9_DTVALID"    ,,OemToAnsi("Validade")           ,PesqPict("SC9","C9_DTVALID") ,TAMSX3("C9_DTVALID")[1],.F.,)
	TRCell():New(oSection1,"C9_POTENCI"    ,,OemToAnsi("Potencia")           ,PesqPict("SC9","C9_POTENCI") ,TAMSX3("C9_POTENCI")[1],.F.,)
	TRCell():New(oSection1,"C9_PEDIDO"     ,,OemToAnsi("Pedido")             ,"@!"                         ,TAMSX3("C9_PEDIDO")[1] ,.F.,)

	oSection1:Cell("C9_PRODUTO"):SetHeaderAlign("LEFT")
	oSection1:Cell("C9_PRODUTO"):SetAlign("LEFT")
	oSection1:Cell("C9_PRODUTO"):SetSize(TAMSX3("C9_PRODUTO")[1]+1)

	oSection1:Cell("B1_DESC"):SetHeaderAlign("LEFT")
	oSection1:Cell("B1_DESC"):SetAlign("LEFT")
	oSection1:Cell("B1_DESC"):SetSize(TAMSX3("B1_DESC")[1])

	oSection1:Cell("B1_UM"):SetHeaderAlign("LEFT")
	oSection1:Cell("B1_UM"):SetAlign("LEFT")
	oSection1:Cell("B1_UM"):SetSize(TAMSX3("B1_UM")[1])

	oSection1:Cell("QUANTIDADE"):SetHeaderAlign("RIGHT")
	oSection1:Cell("QUANTIDADE"):SetAlign("RIGHT")
	oSection1:Cell("QUANTIDADE"):SetSize(TAMSX3("DC_QUANT")[1])

	oSection1:Cell("C9_LOCAL"):SetHeaderAlign("LEFT")
	oSection1:Cell("C9_LOCAL"):SetAlign("LEFT")
	oSection1:Cell("C9_LOCAL"):SetSize(TAMSX3("C9_LOCAL")[1])

	oSection1:Cell("ENDERECO"):SetHeaderAlign("LEFT")
	oSection1:Cell("ENDERECO"):SetAlign("LEFT")
	oSection1:Cell("ENDERECO"):SetSize(TAMSX3("DC_LOCALIZ")[1])

	oSection1:Cell("C9_LOTECTL"):SetHeaderAlign("LEFT")
	oSection1:Cell("C9_LOTECTL"):SetAlign("LEFT")
	oSection1:Cell("C9_LOTECTL"):SetSize(TAMSX3("C9_LOTECTL")[1])

	oSection1:Cell("C9_NUMLOTE"):SetHeaderAlign("LEFT")
	oSection1:Cell("C9_NUMLOTE"):SetAlign("LEFT")
	oSection1:Cell("C9_NUMLOTE"):SetSize(TAMSX3("C9_NUMLOTE")[1])

	oSection1:Cell("C9_DTVALID"):SetHeaderAlign("RIGHT")
	oSection1:Cell("C9_DTVALID"):SetAlign("RIGHT")
	oSection1:Cell("C9_DTVALID"):SetSize(TAMSX3("C9_DTVALID")[1])

	oSection1:Cell("C9_POTENCI"):SetHeaderAlign("RIGHT")
	oSection1:Cell("C9_POTENCI"):SetAlign("RIGHT")
	oSection1:Cell("C9_POTENCI"):SetSize(TAMSX3("C9_POTENCI")[1])

	oSection1:Cell("C9_PEDIDO"):SetHeaderAlign("LEFT")
	oSection1:Cell("C9_PEDIDO"):SetAlign("LEFT")
	oSection1:Cell("C9_PEDIDO"):SetSize(TAMSX3("C9_PEDIDO")[1])

Return oReport

//------------------------------------------------------------------------

Static Function ReportPrint(oReport)
	Local oSection1    := Nil
	Local oSection2    := Nil
	Local _cOrder
	Local oBreak
	Local _nOrdem      := Nil
	Local cEndereco    := ""
	Local cPedido      := ""
	Local nQtde        := 0
	Local lUsaLocal    := (SuperGetMV("MV_LOCALIZ") == "S")
	Private _cAlias    := GetNextAlias()

	oReport:SetTitle(cTitulo)

	oSection1:=oReport:Section(1)

	oSection1:BeginQuery()

	If! lUsaLocal
		If _nTpPedVen == 1 .Or. _nTpPedVen == 3
			BeginSql Alias _cAlias
				SELECT SC9.R_E_C_N_O_ SC9REC,SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_QTDLIB,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_LOTECTL,SC9.C9_POTENCI,SC9.C9_NUMLOTE,SC9.C9_DTVALID,SC9.C9_NFISCAL
				FROM %table:SC9% SC9
				WHERE SC9.%notDel%
				AND SC9.C9_FILIAL = %Exp:xFilial("SC9")%
				AND SC9.C9_PEDIDO >= %Exp:_cPedVenDe%
				AND SC9.C9_PEDIDO <= %Exp:_cPedVenAte%
				AND SC9.C9_BLEST  = '  '
				ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SC9.C9_LOTECTL,SC9.C9_NUMLOTE,SC9.C9_DTVALID
			EndSql
		EndIf

		If _nTpPedVen == 2 .Or. _nTpPedVen == 3
			BeginSql Alias _cAlias
				SELECT SC9.R_E_C_N_O_ SC9REC,SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_QTDLIB,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_LOTECTL,SC9.C9_POTENCI,SC9.C9_NUMLOTE,SC9.C9_DTVALID,SC9.C9_NFISCAL
				FROM %table:SC9% SC9
				WHERE SC9.%notDel%
				AND SC9.C9_FILIAL = %Exp:xFilial("SC9")%
				AND SC9.C9_PEDIDO >= %Exp:_cPedVenDe%
				AND SC9.C9_PEDIDO <= %Exp:_cPedVenAte%
				AND SC9.C9_BLCRED = '  '
				ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SC9.C9_LOTECTL,SC9.C9_NUMLOTE,SC9.C9_DTVALID
			EndSql
		EndIf

	Else

		If _nTpPedVen == 1 .Or. _nTpPedVen == 3
			BeginSql Alias _cAlias
				SELECT SC9.R_E_C_N_O_ SC9REC,SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_QTDLIB,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_LOTECTL,SC9.C9_POTENCI,SC9.C9_NUMLOTE,SC9.C9_DTVALID,SC9.C9_NFISCAL
				,SDC.DC_LOCALIZ,SDC.DC_QUANT,SDC.DC_QTDORIG
				FROM %table:SC9% SC9
				LEFT JOIN %table:SDC% SDC 
				ON SDC.DC_PEDIDO=SC9.C9_PEDIDO AND SDC.DC_ITEM=SC9.C9_ITEM AND SDC.DC_SEQ=SC9.C9_SEQUEN AND SDC.D_E_L_E_T_ = ' '
				WHERE SC9.%notDel%
				AND SC9.C9_FILIAL = %Exp:xFilial("SC9")%
				AND SC9.C9_PEDIDO >= %Exp:_cPedVenDe%
				AND SC9.C9_PEDIDO <= %Exp:_cPedVenAte%
				AND SC9.C9_BLEST  = '  '
				ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SC9.C9_LOTECTL,SC9.C9_NUMLOTE,SC9.C9_DTVALID
			EndSql
		EndIf

		If _nTpPedVen == 2 .Or. _nTpPedVen == 3
			BeginSql Alias _cAlias
				SELECT SC9.R_E_C_N_O_ SC9REC,SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_QTDLIB,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_LOTECTL,SC9.C9_POTENCI,SC9.C9_NUMLOTE,SC9.C9_DTVALID,SC9.C9_NFISCAL
				,SDC.DC_LOCALIZ,SDC.DC_QUANT,SDC.DC_QTDORIG
				FROM %table:SC9% SC9
				LEFT JOIN %table:SDC% SDC 
				ON SDC.DC_PEDIDO=SC9.C9_PEDIDO AND SDC.DC_ITEM=SC9.C9_ITEM AND SDC.DC_SEQ=SC9.C9_SEQUEN AND SDC.D_E_L_E_T_ = ' '
				WHERE SC9.%notDel%
				AND SC9.C9_FILIAL = %Exp:xFilial("SC9")%
				AND SC9.C9_PEDIDO >= %Exp:_cPedVenDe%
				AND SC9.C9_PEDIDO <= %Exp:_cPedVenAte%
				AND SC9.C9_BLCRED = '  '
				ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SC9.C9_LOTECTL,SC9.C9_NUMLOTE,SC9.C9_DTVALID
			EndSql
		EndIf

	EndIf
	oSection1:EndQuery()

	If! lUsaLocal
		TcSetField(_cAlias,"C9_DTVALID"  ,"D",  8, 0)
		TcSetField(_cAlias,"C9_QTDLIB"   ,"N", 12, 2)
	Else
		TcSetField(_cAlias,"C9_DTVALID"  ,"D",  8, 0)
		TcSetField(_cAlias,"DC_QUANT"    ,"N", 12, 2)
	EndIf

	dbSelectArea(_cAlias)
	While !oReport:Cancel() .And. (_cAlias)->(!Eof())

        cPedido := (_cAlias)->C9_PEDIDO
        oSection1:Init()
        
        While !oReport:Cancel() .And. (_cAlias)->(!Eof()).And. cPedido == (_cAlias)->C9_PEDIDO 

		If oReport:Cancel()
			Exit
		EndIf

		If lUsaLocal
			cEndereco := (_cAlias)->DC_LOCALIZ
			nQtde     := (_cAlias)->DC_QUANT
		Else
			cEndereco := ""
			nQtde     := (_cAlias)->C9_QTDLIB
		EndIf

		SB1->(dbSeek(xFilial("SB1")+(_cAlias)->C9_PRODUTO))

		TReport():Say( oReport:Row() , oSection1:Cell("C9_PRODUTO"):ColPos() , (_cAlias)->C9_PRODUTO       , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("B1_DESC"):ColPos()    , SB1->B1_DESC                , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("B1_UM"):ColPos()      , SB1->B1_UM                  , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("QUANTIDADE"):ColPos() , nQtde                       , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_LOCAL"):ColPos()   , (_cAlias)->C9_LOCAL         , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("ENDERECO"):ColPos()   , cEndereco                   , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_LOTECTL"):ColPos() , (_cAlias)->C9_LOTECTL       , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_NUMLOTE"):ColPos() , (_cAlias)->C9_NUMLOTE       , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_DTVALID"):ColPos() , Dtoc((_cAlias)->C9_DTVALID) , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_POTENCI"):ColPos() , (_cAlias)->C9_POTENCI       , oFont )
		TReport():Say( oReport:Row() , oSection1:Cell("C9_PEDIDO"):ColPos()  , (_cAlias)->C9_PEDIDO        , oFont )

		/*oSection1:Cell("C9_PRODUTO"):SetValue((_cAlias)->C9_PRODUTO)
		oSection1:Cell("B1_DESC")   :SetValue(SB1->B1_DESC)
		oSection1:Cell("B1_UM")     :SetValue(SB1->B1_UM)
		oSection1:Cell("QUANTIDADE"):SetValue(nQtde)
		oSection1:Cell("C9_LOCAL")  :SetValue((_cAlias)->C9_LOCAL)
		oSection1:Cell("ENDERECO")  :SetValue(cEndereco)
		oSection1:Cell("C9_LOTECTL"):SetValue((_cAlias)->C9_LOTECTL)
		oSection1:Cell("C9_NUMLOTE"):SetValue((_cAlias)->C9_NUMLOTE)
		oSection1:Cell("C9_DTVALID"):SetValue((_cAlias)->C9_DTVALID)
		oSection1:Cell("C9_POTENCI"):SetValue((_cAlias)->C9_POTENCI)
		oSection1:Cell("C9_PEDIDO") :SetValue((_cAlias)->C9_PEDIDO)

		oSection1:PrintLine()/*
		oReport:SkipLine()

		/*oSection1:Cell("C9_PRODUTO"):SetValue("")
		oSection1:Cell("B1_DESC")   :SetValue("")
		oSection1:Cell("B1_UM")     :SetValue("")
		oSection1:Cell("QUANTIDADE"):SetValue(0)
		oSection1:Cell("C9_LOCAL")  :SetValue("")
		oSection1:Cell("ENDERECO")  :SetValue("")
		oSection1:Cell("C9_LOTECTL"):SetValue("")
		oSection1:Cell("C9_NUMLOTE"):SetValue("")
		oSection1:Cell("C9_DTVALID"):SetValue(Ctod("  /  /  "))
		oSection1:Cell("C9_POTENCI"):SetValue(0)
		oSection1:Cell("C9_PEDIDO") :SetValue("")*/

		dbSelectArea(_cAlias)
		dbSkip()
		oReport:IncMeter()
		End
		oSection1:SetPageBreak(.T.)
		oSection1:Finish() 

	End
	
	oReport:EndPage()

	If Select(_cAlias)>0
		dbSelectArea(_cAlias)
		dbCloseArea()
		dbSelectArea("SC9")
	EndIf
Return

//-----------------------------------------------------------

Static Function fCriaPerg()
	Local aHelpPor01 := {"Informe o numero do pedido inicial a ser ",    "considerado na selecao."}
	Local aHelpEng01 := {"Enter the initial order number to be taken in","consideration."}
	Local aHelpSpa01 := {"Digite el numero del pedido inicial que debe ","considerarse en la seleccion."}
	Local aHelpPor02 := {"Informe o numero do pedido final a ser ",    "considerado na selecao."}
	Local aHelpEng02 := {"Enter the final order number to be taken in","consideration."}
	Local aHelpSpa02 := {"Digite el numero del pedido final que debe ","considerarse en la seleccion."}
	Local aHelpPor03 := {"Seleciona a condicao do pedido de compras a",    "ser impressa."}
	Local aHelpEng03 := {"Select the purchase order terms to print.",      ""}
	Local aHelpSpa03 := {"Elija la condicion del pedido de compras que se","debe imprimir."}

	aSvAlias:={Alias(),IndexOrd(),Recno()}
	i:=j:=0
	aRegistros:={}
	//                1      2    3                            4                      5             6        7   8  9  10  11 12 13         14 15 16 17        18      19          20      21        22         23       24                25              26               27 28 29 30 31 32 33         34         35         36 37 38    39 40 41 42 43 

	AADD(aRegistros,{_cPerg,"01","De pedido ?"                ,"¿De pedido ?"       ,"From order ?","mv_ch1","C",6 ,0 ,0 ,"G","","Mv_Par01",""       ,""     ,""         ,"","",""       ,""       ,""      ,"","",""               ,""             ,""              ,"","","","","","","","","","","","SC5","","","","",""})
	AADD(aRegistros,{_cPerg,"02","Ate pedido ?"               ,"¿A pedido ?"        ,"To order ?"  ,"mv_ch2","C",6 ,0 ,0 ,"G","","Mv_Par02",""       ,""     ,""         ,"","",""       ,""       ,""      ,"","",""               ,""             ,""              ,"","","","","","","","","","","","SC5","","","","",""})
	AADD(aRegistros,{_cPerg,"03","Pedidos liberados ?"        ,"¿Pedidos Aprobados?","orders ?"    ,"mv_ch3","N",1 ,0 ,3 ,"C","","Mv_Par03","Estoque","Stock","Inventory","","","Credito","Credito","Credit","","","Credito/Estoque","Credito/Stock","Credit/Invent.","","","","","","","","","","","","","","","","",""})
  
	DbSelectArea("SX1")
	For i := 1 to Len(aRegistros)
		If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
			While !RecLock("SX1",.T.)
			End
			For j:=1 to FCount()
				FieldPut(j,aRegistros[i,j])
			Next
			MsUnlock()
		Endif
	Next i

	dbSelectArea(aSvAlias[1])
	dbSetOrder(aSvAlias[2])
	dbGoto(aSvAlias[3])
Return(Nil)