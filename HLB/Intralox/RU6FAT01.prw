//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//Wederson L. Santana - 15/10/2019                                                                                                                          //
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//Específico Intralox - Faturamento.                                                                                                                        //
//Relatório de Faturamento.                                                                                                                                 //
//----------------------------------------------------------------------------------------------------------------------------------------------------------//

#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "colors.ch"

User Function RU6FAT01()
	Private _cPerg :="RU6FAT01"+Space(02)
	Private oReport
	Private cFilterUser
	Private oSection1
	Private cTitulo
	Private _cFilDe
	Private _cFilAte
	Private _cPedDe
	Private _cPedAte
	Private _cNfDe
	Private _cNfAte
	Private _cInvDe
	Private _cInvAte
	Private _cCliDe
	Private _cCliAte
	Private _cTransDe
	Private _cTransAte

	If! SC6->(FieldPos("C6_P_INVOI"))>0
		MsgInfo("Favor verificar campo especifico 'C6_P_INVOI', antes de executar o processo. Tabela(SC6)."+Chr(10)+Chr(13)+" Processo interrompido.","A T E N Ç Ã O")
	Else
		fCriaPerg()

		If Pergunte(_cPerg,.T.)
			_cFilDe     := Mv_Par01
			_cFilAte    := Mv_Par02
			_cPedDe     := Mv_Par03
			_cPedAte    := Mv_Par04
			_cInvDe     := Mv_Par05
			_cInvAte    := Mv_Par06
			_cCliDe     := Mv_Par07
			_cLojDe     := Mv_Par08
			_cCliAte    := Mv_Par09
			_cLojAte    := Mv_Par10
			_dEmisDe    := Mv_Par11
			_dEmisAte   := Mv_Par12

			oReport:=ReportDef()
			oReport:PrintDialog()
		EndIf
	EndIf
Return

//-----------------------------------

Static Function ReportDef()
	Local _cPictTit := "@E@Z 99999,999.99"
	Local _cPictTot := "@E 99,999,999.99"
	Local oSection1
	Local oSection2
	Local aOrdem    := {}

	cTitulo:= "Relatório Específico de Faturamento - Intralox."
	//oFontN :=TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)// Negrito
	//oFont  :=TFont():New("Times New Roman",08,08,,.F.,,,,.F.,.F.)

	oFontN :=TFont():New("Courier New",,08,,.T.,,,,.T.,.F.)// Negrito
	oFont  :=TFont():New("Courier New",,08,,.F.,,,,.F.,.F.)

	oReport:=TReport():New("RU6FAT01",cTitulo,""/*_cPerg*/,{|oReport| ReportPrint(oReport)},"Este relatório exibirá o faturamento do período, conforme parametrização.")

	oReport:SetLandScape()

	oSection1:=TRSection():New(oReport,"Relatório Específico de Faturamento.","SC5",aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)

	TRCell():New(oSection1,"C5_FILIAL"    ,,"Filial"                      , ,TAMSX3("C5_FILIAL")[1],.F.,)
	TRCell():New(oSection1,"C5_NUM"       ,,OemToAnsi("Pedido")           , ,TAMSX3("C5_NUM")[1],.F.,)
	TRCell():New(oSection1,"C5_FATURA"    ,,OemToAnsi("Fatura")           , ,TAMSX3("C5_FATURA")[1],.F.,)
	TRCell():New(oSection1,"F2_DOC"       ,,OemToAnsi("NF")               , ,TAMSX3("F2_DOC")[1],.F.,)
	TRCell():New(oSection1,"F2_SERIE"     ,,OemToAnsi("Série")            , ,TAMSX3("F2_SERIE")[1],.F.,)
	TRCell():New(oSection1,"C6_P_INVOI"   ,,OemToAnsi("Número Invoice")   , ,TAMSX3("C6_P_INVOI")[1],.F.,)
	TRCell():New(oSection1,"F2_VALBRUT"   ,,OemToAnsi("Valor Bruto")      , ,TAMSX3("F2_VALBRUT")[1],.F.,)
	TRCell():New(oSection1,"F2_EMISSAO"   ,,OemToAnsi("Data Faturamento") , ,TAMSX3("F2_EMISSAO")[1],.F.,)
	TRCell():New(oSection1,"F2_CHVNFE"    ,,OemToAnsi("Chave NFe")        , ,TAMSX3("F2_CHVNFE")[1],.F.,)
	TRCell():New(oSection1,"A1_COD"       ,,OemToAnsi("Cliente")          , ,TAMSX3("A1_COD")[1],.F.,)
	TRCell():New(oSection1,"A1_LOJA"      ,,OemToAnsi("Loja")             , ,TAMSX3("A1_LOJA")[1],.F.,)
	TRCell():New(oSection1,"A1_NOME"      ,,OemToAnsi("Razão Social")     , ,TAMSX3("A1_NOME")[1],.F.,)
	TRCell():New(oSection1,"A1_P_COD"     ,,OemToAnsi("Código Oracle")    , ,TAMSX3("A1_P_COD")[1],.F.,)
	TRCell():New(oSection1,"A4_COD"       ,,OemToAnsi("Transportadora")   , ,TAMSX3("A4_COD")[1],.F.,)
	TRCell():New(oSection1,"A4_NOME"      ,,OemToAnsi("Descrição")        , ,TAMSX3("A4_NOME")[1],.F.,)

	oSection1:Cell("C5_FILIAL"):SetHeaderAlign("LEFT")
	oSection1:Cell("C5_FILIAL"):SetAlign("LEFT")
	oSection1:Cell("C5_FILIAL"):SetSize(TAMSX3("C5_FILIAL")[1])

	oSection1:Cell("C5_NUM"):SetHeaderAlign("LEFT")
	oSection1:Cell("C5_NUM"):SetAlign("LEFT")
	oSection1:Cell("C5_NUM"):SetSize(TAMSX3("C5_NUM")[1])

    oSection1:Cell("C5_FATURA"):SetHeaderAlign("LEFT")
	oSection1:Cell("C5_FATURA"):SetAlign("LEFT")
	oSection1:Cell("C5_FATURA"):SetSize(TAMSX3("C5_FATURA")[1])

	oSection1:Cell("F2_DOC"):SetHeaderAlign("LEFT")
	oSection1:Cell("F2_DOC"):SetAlign("LEFT")
	oSection1:Cell("F2_DOC"):SetSize(TAMSX3("F2_DOC")[1])

	oSection1:Cell("F2_SERIE"):SetHeaderAlign("LEFT")
	oSection1:Cell("F2_SERIE"):SetAlign("LEFT")
	oSection1:Cell("F2_SERIE"):SetSize(TAMSX3("F2_SERIE")[1])

	oSection1:Cell("C6_P_INVOI"):SetHeaderAlign("LEFT")
	oSection1:Cell("C6_P_INVOI"):SetAlign("LEFT")
	oSection1:Cell("C6_P_INVOI"):SetSize(TAMSX3("C6_P_INVOI")[1])

	oSection1:Cell("F2_VALBRUT"):SetHeaderAlign("RIGHT")
	oSection1:Cell("F2_VALBRUT"):SetAlign("RIGHT")
	oSection1:Cell("F2_VALBRUT"):SetSize(TAMSX3("F2_VALBRUT")[1])

	oSection1:Cell("F2_EMISSAO"):SetHeaderAlign("RIGHT")
	oSection1:Cell("F2_EMISSAO"):SetAlign("RIGHT")
	oSection1:Cell("F2_EMISSAO"):SetSize(TAMSX3("F2_EMISSAO")[1])

	oSection1:Cell("F2_CHVNFE"):SetHeaderAlign("LEFT")
	oSection1:Cell("F2_CHVNFE"):SetAlign("LEFT")
	oSection1:Cell("F2_CHVNFE"):SetSize(TAMSX3("F2_CHVNFE")[1])

	oSection1:Cell("A1_COD"):SetHeaderAlign("LEFT")
	oSection1:Cell("A1_COD"):SetAlign("LEFT")
	oSection1:Cell("A1_COD"):SetSize(TAMSX3("A1_COD")[1])

	oSection1:Cell("A1_LOJA"):SetHeaderAlign("LEFT")
	oSection1:Cell("A1_LOJA"):SetAlign("LEFT")
	oSection1:Cell("A1_LOJA"):SetSize(TAMSX3("A1_LOJA")[1])

	oSection1:Cell("A1_NOME"):SetHeaderAlign("LEFT")
	oSection1:Cell("A1_NOME"):SetAlign("LEFT")
	oSection1:Cell("A1_NOME"):SetSize(TAMSX3("A1_NOME")[1])

    oSection1:Cell("A1_P_COD"):SetHeaderAlign("LEFT")
	oSection1:Cell("A1_P_COD"):SetAlign("LEFT")
	oSection1:Cell("A1_P_COD"):SetSize(TAMSX3("A1_P_COD")[1])

	oSection1:Cell("A4_COD"):SetHeaderAlign("LEFT")
	oSection1:Cell("A4_COD"):SetAlign("LEFT")
	oSection1:Cell("A4_COD"):SetSize(TAMSX3("A4_COD")[1])

	oSection1:Cell("A4_NOME"):SetHeaderAlign("LEFT")
	oSection1:Cell("A4_NOME"):SetAlign("LEFT")
	oSection1:Cell("A4_NOME"):SetSize(TAMSX3("A4_NOME")[1])

Return oReport

//------------------------------------------------------------------------

Static Function ReportPrint(oReport)
	Local oSection1    := Nil
	Local oSection2    := Nil
	Local _cOrder
	Local oBreak
	Local _nOrdem      := Nil
	Private _cAlias    := "TMP"

	oReport:SetTitle(cTitulo)

	oSection1:=oReport:Section(1)

	oSection1:BeginQuery()
	BeginSql Alias _cAlias

		SELECT C5_FILIAL,C5_NUM,C5_FATURA,C5_CLIENTE,C5_LOJACLI,C5_TRANSP,C6_P_INVOI,C6_NOTA,C6_SERIE,A1_COD,A1_LOJA,A1_NOME,A1_P_COD
		FROM %table:SC5% SC5
		,%table:SC6% SC6
		,%table:SA1% SA1
		WHERE SC5.%notDel%
		AND SC6.%notDel%
		AND SA1.%notDel%
		AND C5_FILIAL = C6_FILIAL
		AND C5_NUM = C6_NUM
		AND C5_CLIENTE = A1_COD
		AND C5_LOJACLI = A1_LOJA
		AND C5_FILIAL >= %Exp:_cFilDe%
		AND C5_FILIAL <= %Exp:_cFilAte%
		AND C5_NUM >= %Exp:(_cPedDe)%
		AND C5_NUM <= %Exp:(_cPedAte)%
		AND C5_CLIENTE >= %Exp:(_cCliDe)%
		AND C5_CLIENTE <= %Exp:(_cCliAte)%
		AND C5_LOJACLI >= %Exp:(_cLojDe)%
		AND C5_LOJACLI <= %Exp:(_cLojAte)%
		AND C5_EMISSAO >= %Exp:(Dtos(_dEmisDe))%
		AND C5_EMISSAO <= %Exp:(Dtos(_dEmisAte))%
		AND C6_P_INVOI >= %Exp:(_cInvDe)%
		AND C6_P_INVOI <= %Exp:(_cInvAte)%

		ORDER BY C5_FILIAL,C5_NUM

	EndSql
	oSection1:EndQuery()

	oSection1:Init()

	dbSelectArea(_cAlias)
	While !oReport:Cancel() .And. (_cAlias)->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("C5_FILIAL"):SetValue((_cAlias)->C5_FILIAL)
		oSection1:Cell("C5_NUM"):SetValue((_cAlias)->C5_NUM)
        oSection1:Cell("C5_FATURA"):SetValue((_cAlias)->C5_FATURA)
		
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek((_cAlias)->C5_FILIAL+(_cAlias)->C6_NOTA+(_cAlias)->C6_SERIE+(_cAlias)->A1_COD+(_cAlias)->A1_LOJA))		

			oSection1:Cell("F2_DOC"):SetValue(SF2->F2_DOC)
			oSection1:Cell("F2_SERIE"):SetValue(SF2->F2_SERIE)
			oSection1:Cell("F2_VALBRUT"):SetValue(SF2->F2_VALBRUT)
			oSection1:Cell("F2_EMISSAO"):SetValue(SF2->F2_EMISSAO)
			oSection1:Cell("F2_CHVNFE"):SetValue(SF2->F2_CHVNFE)

		EndIf

		oSection1:Cell("C6_P_INVOI"):SetValue((_cAlias)->C6_P_INVOI)
		oSection1:Cell("A1_COD"):SetValue((_cAlias)->A1_COD)
		oSection1:Cell("A1_LOJA"):SetValue((_cAlias)->A1_LOJA)
		oSection1:Cell("A1_NOME"):SetValue((_cAlias)->A1_NOME)
        oSection1:Cell("A1_P_COD"):SetValue((_cAlias)->A1_P_COD)
		
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek((_cAlias)->C5_FILIAL+(_cAlias)->C5_TRANSP)) 
			oSection1:Cell("A4_COD"):SetValue(SA4->A4_COD)
			oSection1:Cell("A4_NOME"):SetValue(SA4->A4_NOME)
		EndIf

		oSection1:PrintLine()
		oReport:SkipLine()

		oSection1:Cell("C5_FILIAL"):SetValue("")
		oSection1:Cell("C5_NUM"):SetValue("")
		oSection1:Cell("F2_DOC"):SetValue("")
		oSection1:Cell("F2_SERIE"):SetValue("")
		oSection1:Cell("C6_P_INVOI"):SetValue("")
		oSection1:Cell("F2_VALBRUT"):SetValue(0)
		oSection1:Cell("F2_EMISSAO"):SetValue(Ctod("  /  /  "))
		oSection1:Cell("F2_CHVNFE"):SetValue("")
		oSection1:Cell("A1_COD"):SetValue("")
		oSection1:Cell("A1_LOJA"):SetValue("")
		oSection1:Cell("A1_NOME"):SetValue("")
		oSection1:Cell("A1_P_COD"):SetValue("")
		oSection1:Cell("A4_COD"):SetValue("")
		oSection1:Cell("A4_NOME"):SetValue("")

		dbSelectArea(_cAlias)
		dbSkip()
		oReport:IncMeter()

	End
	If Select((_cAlias))> 0
		(_cAlias)->(DbCloseArea())
	EndIf

	oSection1:Finish()
	oReport:EndPage()
Return

//-----------------------------------------------------------

Static Function fCriaPerg()
	aSvAlias:={Alias(),IndexOrd(),Recno()}
	i:=j:=0
	aRegistros:={}
	//                1      2    3                  4  5      6     7  8  9  10  11  12 13     14  15    16 17 18 19 20     21  22 23 24 25   26 27 28 29  30       31 32 33 34 35  36 37 38 39    40 41 42 43 44
	AADD(aRegistros,{_cPerg,"01","Filial de          ?","","","mv_ch1","C",02                          ,00,00,"G","" ,"mv_par01","" ,"","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegistros,{_cPerg,"02","Filial ate         ?","","","mv_ch2","C",02                          ,00,00,"G","" ,"mv_par02","" ,"","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegistros,{_cPerg,"03","Pedido de          ?","","","mv_ch3","C",Len(Criavar("C5_NUM"))      ,00,00,"G","" ,"mv_par03","" ,"","","","","","","","","","","","","","","","","","","","","","","","SC5","","","","",""})
	AADD(aRegistros,{_cPerg,"04","Pedido ate         ?","","","mv_ch4","C",Len(Criavar("C5_NUM"))      ,00,00,"G","" ,"mv_par04","" ,"","","","","","","","","","","","","","","","","","","","","","","","SC5","","","","",""})
	AADD(aRegistros,{_cPerg,"05","Invoice de         ?","","","mv_ch5","C",Len(Criavar("C6_P_INVOI"))  ,00,00,"G","" ,"mv_par05","" ,"","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"06","Invoice ate        ?","","","mv_ch6","C",Len(Criavar("C6_P_INVOI"))  ,00,00,"G","" ,"mv_par06","" ,"","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"07","Cliente de         ?","","","mv_ch7","C",Len(Criavar("C5_CLIENTE"))  ,00,00,"G","" ,"mv_par07","" ,"","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",""})
	AADD(aRegistros,{_cPerg,"08","Loja de            ?","","","mv_ch8","C",Len(Criavar("C5_LOJACLI"))  ,00,00,"G","" ,"mv_par08","" ,"","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"09","Cliente ate        ?","","","mv_ch9","C",Len(Criavar("C5_CLIENTE"))  ,00,00,"G","" ,"mv_par09","" ,"","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",""})
	AADD(aRegistros,{_cPerg,"10","Loja ate           ?","","","mv_cha","C",Len(Criavar("C5_LOJACLI"))  ,00,00,"G","" ,"mv_par10","" ,"","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"11","Emissao PV de      ?","","","mv_chb","D",08                          ,00,00,"G","" ,"mv_par11","" ,"","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",""})
	AADD(aRegistros,{_cPerg,"12","Emissao PV ate     ?","","","mv_chc","D",08                          ,00,00,"G","" ,"mv_par12","" ,"","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",""})

	//AADD(aRegistros,{_cPerg,"11","NF de         ?","","","mv_ch5","C",Len(Criavar("F2_DOC"))      ,00,00,"G","" ,"mv_par11","" ,"","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",""})
	//AADD(aRegistros,{_cPerg,"12","NF ate        ?","","","mv_ch6","C",Len(Criavar("F2_DOC"))      ,00,00,"G","" ,"mv_par12","" ,"","","","","","","","","","","","","","","","","","","","","","","","SF2","","","","",""})
	//AADD(aRegistros,{_cPerg,"13","Transportadora de  ?","","","mv_chB","C",Len(Criavar("C5_TRANSP"))   ,00,00,"G","" ,"mv_par13","" ,"","","","","","","","","","","","","","","","","","","","","","","","SA4","","","","",""})
	//AADD(aRegistros,{_cPerg,"14","Transportadora ate ?","","","mv_chC","C",Len(Criavar("C5_TRANSP"))   ,00,00,"G","" ,"mv_par14","" ,"","","","","","","","","","","","","","","","","","","","","","","","SA4","","","","",""})

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
