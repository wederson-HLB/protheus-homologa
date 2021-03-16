#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"

#Define CRLF CHR(13)+CHR(10)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ GTGPE017() ≥ Autor ≥ Francisco Neto       ≥ Data ≥19/12/2016≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ GeraÁ„o de layout para Pedidos de Beneficios vt/vr/va/vc   ≥±±
±±≥            para os fornecedores: VB, TICKET, ALELO, SODEXO            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥Rotina customizada para a HLB BRASIL, gerada a partir              ≥±±
±±≥ do rdmake BENEFARQ da Totvs                                           ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/



//-------------------------------------------------------------------
/*/{Protheus.doc} BENEFARQ
INTEGRACAO DE BENEFICIOS COM EMPRESA DE SERVICOS

@author Marcelo Faria
@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GTGPE017()

	Private cVBPerg := 'BENEFARQ'
	
	VBOpcoes(cVBPerg)
	Pergunte(cVBPerg,.F.)
	
	TNewProcess():New("BENEARQ", STR0001, {|oSelf| ProcessBnf(oSelf)}, STR0002, "BENEFARQ", NIL, NIL, NIL, NIL, .T., .F.) 
	// "Exportacao dos arquivos de beneficios" - "Esta rotina processa e gera arquivo de beneficios para integracao"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc}

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessBnf(oProcess)
	Local nCount, nCount2
	Local nOldSet   := SetVarNameLen(255)
	Local aArea     := GetArea()
	Local aItems    := {}
	Local lCancel   := .F.
	
	Private nTotal  := 0
	Private nVlr    := 0
	Private nHdl    := 0
	Private nLin    := 0
	Private cReprocessa := IIf(MV_PAR03==2,"1","2")       	//*Reprocessamento - selecionar RG2_Pedido==2
	Private lImpLis := Iif(MV_PAR15 == 1,.T.,.F.) 			//Impressao Relatorio
	Private nOrd    := MV_PAR16                   			//Ordem Relatorio
	Private cArqOut   := ""
	Private lErrorImp := .F.
	Private cTipoV    := ""
	Private cEstCiv   := ""
	Private cDiastrab := ""
	Private cDepto := ""
	Private cFuncao := ""
	Private cPath  := "c:\Beneficios\ "
	Private cProduto := ""
	Private cForma := ""
	Private cOperadora := {"","","","",""}
	Private cLinha := {"","","","",""}
	Private cQtddia := {0,0,0,0,0}
	Private cVrval := {0,0,0,0,0}
	Private cMatricula := ""
	Private cNome := ""
	Private cQtdvaledia := 0
	Private cPedido := ""
	Private cOp01 := ""
	Private cOp02 := ""
	Private cOp03 := ""
	Private cOp04 := ""
	Private cOp05 := ""
	Private cLi01 := ""
	Private cLi02 := ""
	Private cLi03 := ""
	Private cLi04 := ""
	Private cLi05 := ""
	Private cQt01 := ""
	Private cQt02 := ""
	Private cQt03 := ""
	Private cQt04 := ""
	Private cQt05 := ""
	Private cVl01 := ""
	Private cVl02 := ""
	Private cVl03 := ""
	Private cVl04 := ""
	Private cVl05 := ""
	Private cVlXX := ""
	Private cTotheader := 0 
	Private cTottrailler := 0
	Private cTotreg3 := 0
	Private Ntotreg3:= 0
	Private cCliente := ""
	Private cNomeUser := ""
	Private cHora := ""
	Private nUsuario := ""
	Private nHora := ""
	Private nHeader := 0
	Private nTrailler := 0
	Private nDet := 0

	//Cria o diretorio caso nao exista
	If MAKEDIR(cPath) == 0
		Aviso( "Importante", "O DiretÛrio '" +cPath+ "' foi criado",{"Ok"})
	EndIf    

	//Dados do usu·rio do sistema
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]

	cHora := time()
	nUsuario := substr(cNomeUser,1,8)	
    nHora := substr(cHora,1,2)+"."+substr(cHora,4,2)+"."+substr(cHora,7,2)
    nHeader := 1
    nTrailler := 1

	dbSelectArea( "RG2" )
	//dbSetOrder( 8 )	//-RG2_FILIAL+RG2_MEIO+RG2_PERIOD+RG2_NROPGT+RG2_ROTEIR+RG2_TPVALE+RG2_CODIGO+RG2_MAT
	dbSetOrder(1)
	
	AAdd(aItems, {STR0003, { || ProcINI(oProcess) } }) //"Lendo arquivo INI"
	
	oProcess:SetRegua1(Len(aItems)) //Total de elementos da regua
	oProcess:SaveLog(STR0004)       //"Inicio de processamento"
	
	For nCount:= 1 to Len(aItems)
		If (oProcess:lEnd)
			Break
		EndIf
		
		oProcess:IncRegua1(aItems[nCount, 1])
		Eval(aItems[nCount, 2])
	Next
	
	SetVarNameLen(nOldSet)
	
	//Fecha Arquivo
	If nHdl > 0
		If !fClose(nHdl)
			MsgAlert(STR0005) //'Ocorreram problemas no fechamento do arquivo.'
		EndIf
	EndIf
	
	//Encerra o processamento
	If !oProcess:lEnd
		oProcess:SaveLog(STR0006) //"Fim do processamento"
		
		If lErrorImp
			fErase( cArqOut )
			Alert(STR0028)  //"Existe dados inv·lidos. Verifique o Log de Processos desta rotina!"
			
		ElseIf nLin > 0
			 Aviso(STR0007, STR0006, {STR0008}) //"Exportacao de arquivos de beneficios" - "Fim do processamento" - "Ok"
			
			 //Imprime Listagem
			 If lImpLis
				 fImpLis()
			 EndIf
	
	    //Atualizacao do status do historico RG2 
	    If cReprocessa == "1"
	      fAtuRG2()
	    EndIf
		Else
			Aviso(STR0009, STR0010 ,{STR0008}) //"Aviso" - "N„o existem registros a serem gravados." - "Ok"
		EndIf
	Else
		nLin := 0
		Aviso(STR0007, STR0011 , {STR0008}) //"Exportacao de arquivos de beneficios" - "Processamento cancelado pelo usuario!" - "Ok"
		oProcess:SaveLog(STR0011)
	EndIf
	
	RestArea(aArea)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcIni

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcINI(oProcess)
	Local cQuery    := ''
	Local cDemissa  := ''
	Local cTipo     := ''
	Local cFilDe    := ''
	Local cFilAte   := ''
	Local cCcDe     := ''
	Local cCcAte    := ''
	Local cMatDe    := ''
	Local cMatAte   := ''
	Local cArqIni   := ""
	Local cFuncVal  := ""
	Local nCount    := 0
	Local nPos      := 0
	Local dAdm      := cTod(" / / ")
	Local dRef      := cTod(" / / ")
	Local aTab      := {}
	Local lCont     := .T.
	Local cMyChave  := ""
	Local nAux      := 0
	Local nTp		     := 0
	Local aForn410  := {}
	Local nLinha
	Local cQryAux
	Local cAnoMesDe  := ""
	Local cAnoMesAte := ""
	
	Private cForn410 := {}
	Private cCodCli  := ''
	Private cSRA_End := ''
	Private cSRA_Num := ''
	Private cRGC_End := ''
	Private cRGC_Num := ''
	Private cItemCod  := ''
	Private cItemNome := ''
	Private nReg    := 0
	Private nSeq    := 0
	Private dCred   := cTod(" / / ")
	Private aStruct
	Private nTotReg     := 0	//-Qtd.Registros - no arquivo
	Private nTotRegTP1  := 0	//-Qtd.Registros - Tipo 1
	Private nTotRegTP2  := 0	//-Qtd.Registros - Tipo 2
	Private nTotRegTP3  := 0	//-Qtd.Registros - Tipo 3
	Private nTotRegTP4  := 0	//-Qtd.Registros - Tipo 4
	Private nTotRegTP5  := 0	//-Qtd.Registros - Tipo 5
	Private nQtdTotItem := 0
	Private nvlrTotItem := 0
	Private nPosEnd := 0
	Private nSeqEnd := 0
	Private aSeqEnd := {}
	
	//Carrega Perguntas
	cFornecedor := MV_PAR01                     //Fornecedor selecionado
	cTiposSel   := MV_PAR02                     //Tipos Selecionados
	cMesAnoDe   := MV_PAR04                     //De Mes-Ano
	cMesAnoAte  := MV_PAR05                     //Ate Mes-Ano
	cFilDe      := MV_PAR06                     //Da Filial
	cFilAte     := MV_PAR07                     //Ate a Filial
	cCcDe       := MV_PAR08                     //Do Centro Custo
	cCcAte      := MV_PAR09                     //Ate Centro de Custo
	cMatDe      := MV_PAR10                     //Da Matricula
	cMatAte     := MV_PAR11                     //Ate Matricula
	dRef        := MV_PAR12                     //Data de Referencia
	dCred       := MV_PAR13                     //Data Credito
	cAdm        := dToS(MV_PAR14)               //Consid.Admitido Ate
	cAnoMesDe   := SubStr( MV_PAR04 , 3 , 4 ) +  SubStr( MV_PAR04 , 1 , 2 )
	cAnoMesAte  := SubStr( MV_PAR05 , 3 , 4 ) +  SubStr( MV_PAR05 , 1 , 2 )
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica parametros                                                    ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	If Empty(cFornecedor)
	    Alert(STR0051) //"Par‚metro sobre fornecedor n„o preenchido!"
	    Return
	EndIf

	If Empty(cAdm)
	    Alert(STR0052) //"Par‚metro sobre data de admiss„o n„o preenchido!"
	    Return
	EndIf

	If Empty(cTiposSel)
	    Alert(STR0053) //"Par‚metro sobre tipos de beneficio n„o preenchido!"
	    Return
	EndIf
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica se foi informado os Arquivos .INI e de Saida                  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	nLinha  := FPOSTAB("S018", Alltrim(cFornecedor), "==", 4)

	If Empty( cArqIni := Alltrim(FTABELA("S018", nLinha, 08)) )
		Alert(STR0029) //"Arquivo .INI n„o informado na Tabela Auxiliar S018!"
		Return
	EndIf

	If Empty( cArqOut := Alltrim(FTABELA("S018", nLinha, 09)) )
		Alert(STR0030) //"Arquivo de Sa˙Åa n„o informado na Tabela Auxiliar S018"
		Return
	EndIf

	If Empty( cFuncVal := Alltrim(FTABELA("S018", nLinha, 10)) )
		Alert(STR0031) //"FunÁ„o de ValidaÁ„o n„o informada na Tabela Auxiliar S018"
		Return
	Else
	 If At("(", cFuncVal ) > 0
	    Alert(STR0056) //"FunÁ„o validadora com caracter -()- invalido, na tabela S018"
	    Return
	 EndIf   
	EndIf
	
	If !file( cArqIni )
	    Alert(STR0047 +' - ' +cArqIni) //"Arquivo de inicializaÁ„o n„o localizado: "
	    Return
	EndIf

	If File( cArqOut )
	   If Aviso(STR0013 , cArqOut +" - " +STR0048 ,{STR0049,STR0050}) == 1  //"ATENCAO" - "Arquivo JÅEExiste. Sobrepor?" - "N„o","Sim"
	      Return
	   EndIf
	EndIf
	
	if "01" $(ALLTRIM(MV_PAR02))
		cTipoV := '2'
	elseif "02" $(ALLTRIM(MV_PAR02))
		cTipoV := '6'
	elseif "03" $(ALLTRIM(MV_PAR02))
		cTipoV := '1'
	elseif "04" $(ALLTRIM(MV_PAR02))
		cTipoV := '5'
	elseif "05" $(ALLTRIM(MV_PAR02))
		cTipoV := '3'
	elseif "06" $(ALLTRIM(MV_PAR02))
		cTipoV := '4'
	endif
	
	nLinha  := FPOSTAB("S018", Alltrim(cFornecedor), "==", 4)
	cCliente := Alltrim(FTABELA("S018", nLinha, 06))
	
	//Executa funcao padrao para processar arquivo INI
	aStruct := RHProcessaIni(cArqIni)

	/* Estrutura do array de retorno
	aStruct[1] - Header
	aStruct[2] - Detalhes
	aStruct[3] - Trailler
	
	aStruct[1][1][1] - Header / Primeiro Campo / (1 campo: tipo do registro header)
	aStruct[1][1][2] - Header / Primeiro Campo / (2 campo: descricao do campo)
	aStruct[1][1][3] - Header / Primeiro Campo / (3 campo: tipo do dado)
	aStruct[1][1][4] - Header / Primeiro Campo / (4 campo: tamanho do campo)
	aStruct[1][1][5] - Header / Primeiro Campo / (5 campo: decimais campo numerico)
	aStruct[1][1][6] - Header / Primeiro Campo / (6 campo: valor e conteudo  para o campo)
	*/
	
	//Cria Arquivo de saida
	nHdl := fCreate(cArqOut)
	If nHdl == -1
		MsgAlert(STR0012,STR0013) //'O arquivo n„o pode ser criado! Verifique os parametros.' - 'AtenÁ„o!'
		Return
	Endif
	
	//-------------------------------------------------------------------------------------//
	// Codigo 0 - Header do Arquivo					                                       //
	//-------------------------------------------------------------------------------------//

	if  "TICKET" $UPPER(cArqIni) 
		fWrite( nHdl, RHGeraLinhas( aStruct[1], "00" ) )
		nSeq += 1
		cTotheader += 1 
		fWrite( nHdl, RHGeraLinhas( aStruct[1], "01" ) )
	else
		nSeq += 1
		cTotheader += 1 
		fWrite( nHdl, RHGeraLinhas( aStruct[1], ) )	
	endif

	
	//-------------------------------------------------------------------------------------//
	// Codigo 1 - Empresas							                                       //
	//-------------------------------------------------------------------------------------//
	nTotRegTP1 := 0
	
	//-Ajusta o conteudo da cTiposSel pra usar na Query
	cQryAux := ""
	cTiposSel := Alltrim(cTiposSel)
	For nTp := 1 to Len(cTiposSel) Step 2
		cQryAux += "'"+SubStr(cTiposSel, nTp, 2)+"'"
		If (nTp + 2) < Len(cTiposSel)
			cQryAux += ","
		EndIf
	Next nTp
	
	
	////// ENDERE«OS COM MOVIMENTO DE VT / VR
	
	cQuery  := "SELECT DISTINCT RA_LOCBNF, RA_FILIAL,RA_MAT,RA_NOME,RA_CIC,RA_RG,RA_TNOTRAB,RA_NASC,RA_CC,RA_CODFUNC,RA_RGUF "
	cQuery  += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery  += " WHERE "
	If TcSrvType() != "AS/400"
		cQuery += " SRA.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " SRA.@DELETED@ = ' ' "
	Endif
	cQuery  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
	cQuery  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
	cQuery  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
	cQuery  += " AND RA_ADMISSA <= '" + cAdm + "' AND RA_LOCBNF <> ' ' "
	cQuery  += " AND RA_FILIAL+RA_MAT IN(SELECT RG2_FILIAL+RG2_MAT FROM " + RetSqlName("RG2") + " WHERE "
	cQuery  += " D_E_L_E_T_ = ' ' "
	cQuery  += " AND RG2_TPBEN IN(" + cQryAux + ") "
	cQuery  += " AND RG2_PEDIDO = " + cReprocessa + " "
	cQuery  += " AND RG2_ANOMES >= '" + cAnoMesDe + "' AND RG2_ANOMES <= '" + cAnoMesAte + "') "
	cQuery  += " ORDER BY RA_LOCBNF,RA_FILIAL,RA_MAT "

	//Verifica Tabela Aberta
	If Select("QD01VB") > 0
		DbSelectArea("QD01VB")
		DbCloseArea("QD01VB")
	Endif
	
	//Abrir Tabela
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD01VB", .T., .F.)
	QD01VB->(DbGoTop())
	
	nSeqEnd := 0
	aSeqEnd := {}
	cMyChave := ""

	While QD01VB->(!Eof())

		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD01VB->RA_LOCBNF,.F.)

		if "SODEXO" $UPPER(cArqIni) 			
			If QD01VB->RA_LOCBNF == cMyChave 
				QD01VB->(dbSkip())
				Loop
			Else
				cMyChave := QD01VB->RA_LOCBNF
				nSeq += 1
				nTotRegTP1 += 1
				Ntotreg3 += 1				
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "03" ) )
			EndIf
		else
			If QD01VB->RA_LOCBNF == cMyChave 
				QD01VB->(dbSkip())
				Loop
			Else
				cMyChave := QD01VB->RA_LOCBNF
				nSeq += 1
				nTotRegTP1 += 1							
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "01" ) )
			EndIf
		endif

		QD01VB->(dbSkip())
	EndDo

	
	//-------------------------------------------------------------------------------------//
	// Codigo 2 - Enderecos de Entrega				                                       //
	//-------------------------------------------------------------------------------------//
	nTotRegTP2 := 0
	

	cQuery  := "SELECT DISTINCT RA_LOCBNF, RA_FILIAL,RA_MAT,RA_NOME,RA_CIC,RA_RG,RA_TNOTRAB,RA_NASC,RA_CC,RA_CODFUNC,RA_RGUF "
	cQuery  += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery  += " WHERE "
	If TcSrvType() != "AS/400"
		cQuery += " SRA.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " SRA.@DELETED@ = ' ' "
	Endif
	cQuery  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
	cQuery  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
	cQuery  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
	cQuery  += " AND RA_ADMISSA <= '" + cAdm + "' AND RA_LOCBNF <> ' '  "
	cQuery  += " AND RA_FILIAL+RA_MAT IN(SELECT RG2_FILIAL+RG2_MAT FROM " + RetSqlName("RG2") + " WHERE "
	cQuery  += " D_E_L_E_T_ = ' ' "
	cQuery  += " AND RG2_TPBEN IN(" + cQryAux + ") "
	cQuery  += " AND RG2_PEDIDO = " + cReprocessa + " "
	cQuery  += " AND RG2_ANOMES >= '" + cAnoMesDe + "' AND RG2_ANOMES <= '" + cAnoMesAte + "') "
	cQuery  += " ORDER BY RA_LOCBNF,RA_FILIAL,RA_MAT "

	//Verifica Tabela Aberta
	If Select("QD02VB") > 0
		DbSelectArea("QD02VB")
		DbCloseArea("QD02VB")
	Endif
	
	//Abrir Tabela
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD02VB", .T., .F.)
	QD02VB->(DbGoTop())
	
	nSeqEnd := 0
	aSeqEnd := {}
	cMyChave := ""
	While QD02VB->(!Eof())

		if "ALELOVR" $UPPER(cArqIni)  						
			//-Gera apenas 1 linha por Loc.Entrega
			If QD02VB->RA_LOCBNF == cMyChave .or. len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
			//If len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
				QD02VB->(dbSkip())
				Loop
			Else
				cMyChave := QD02VB->RA_LOCBNF
			EndIf
		elseif "ALELOVA" $UPPER(cArqIni)  						
			//-Gera apenas 1 linha por Loc.Entrega
			If QD02VB->RA_LOCBNF == cMyChave .or. len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
			//If len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
				QD02VB->(dbSkip())
				Loop
			Else
				cMyChave := QD02VB->RA_LOCBNF
			EndIf
		elseif "ALELOVC" $UPPER(cArqIni)  						
			//-Gera apenas 1 linha por Loc.Entrega
			If QD02VB->RA_LOCBNF == cMyChave .or. len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
			//If len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
				QD02VB->(dbSkip())
				Loop
			Else
				cMyChave := QD02VB->RA_LOCBNF
			EndIf
		ELSEIF !"ALELOVT" $UPPER(cArqIni)
		//ELSE
			//-Gera apenas 1 linha por Loc.Entrega
			//If len(alltrim(QD02VB->RA_LOCBNF)) = 0      // francisco
			If QD02VB->RA_LOCBNF == cMyChave .or. len(alltrim(QD02VB->RA_LOCBNF)) = 0      // 
				QD02VB->(dbSkip())
				Loop
			Else
				cMyChave := QD02VB->RA_LOCBNF
			EndIf
		ENDIF
	
		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD02VB->RA_LOCBNF,.F.)
		
		//Separa Numero do Endereco
		cRGC_End := ''
		cRGC_Num := ''
		If (nPos := Rat(",",RGC_ENDER,1,1)) > 0
			cRGC_End := Substr(RGC_ENDER,1,nPos - 1)
			cRGC_Num := Substr(RGC_ENDER,nPos + 1)
		Endif
		
		//-Cria sequencia de Enderecos
		nSeqEnd += 1
		aAdd(aSeqEnd, {QD02VB->RA_LOCBNF, nSeqEnd})

		cDiastrab := POSICIONE("SR6",1,XFILIAL("SR6")+QD02VB->RA_TNOTRAB,"R6_DIAVTRA")
		cDepto := POSICIONE("CTT",1,XFILIAL("CTT")+QD02VB->RA_CC,"CTT_DESC01")
		cFuncao := POSICIONE("SRJ",1,XFILIAL("SRJ")+QD02VB->RA_CODFUNC,"RJ_DESC")

		//Grava Detalhes
		if !"SODEXO" $UPPER(cArqIni)  .and. !"TICKET" $UPPER(cArqIni) 					
			nTotRegTP2 += 1
			nSeq += 1		
			fWrite( nHdl, RHGeraLinhas( aStruct[2], "02" ) )
		ENDIF
		
		QD02VB->(dbSkip())
	EndDo
		
	//---------------------------------------------------------------------------------//
	// Codigo 3 - Funcionarios						                                                //
	//--------------------------------------------------------------------------------//
	nTotRegTP3 := 0
	
	if "SODEXOVT" $UPPER(cArqIni) 
	
		///////// tratamento para VT SODEXO
		cQuery  := "SELECT R0_FILIAL,R0_MAT,R0_CODIGO,RN_DESC,R0_QDIAINF,R0_VLRVALE,RN_TPBEN, "
		cQuery  += " RFP_PRODSX,RFP_FORMSX,RFP_CDOPSX,RFP_LINHSX "
		cQuery  += " FROM " + RetSqlName("SR0") + " A, " + RetSqlName("SRN") + " B, " + RetSqlName("RFP") + " C " 
		cQuery  += " WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' ' "
		cQuery  += " AND R0_TPVALE = '0' AND RFP_TPVALE = '0' "
		cQuery  += " AND R0_CODIGO = RN_COD "
		cQuery  += " AND R0_CODIGO = RFP_CODIGO  "
		cQuery  += " ORDER BY R0_FILIAL,R0_MAT,R0_CODIGO  "
		
		//Verifica Tabela Aberta
		If Select("SODEXO") > 0
			DbSelectArea("SODEXO")
			DbCloseArea("SODEXO")
		Endif
		
		//Abrir Tabela
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "SODEXO", .T., .F.)
		
		SODEXO->(DbGoTop())
		
	endif
	
	cQuery  := "SELECT RG2.*, RA_FILIAL,RA_CC,RA_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_LOCBNF, "
	cQuery  += " RA_ENDEREC,RA_COMPLEM,RA_BAIRRO,RA_MUNICIP,RA_ESTADO,RA_ESTADO,RA_CEP,RA_TELEFON, "
	cQuery  += " RA_NASC,RA_CIC,RA_RG,RA_MAE,RA_EMAIL,RA_ESTCIVI,RA_SEXO,RA_PAI,RA_RGUF,RA_LOGRTP,RA_NUMENDE,RA_CODFUNC "
	cQuery  += " FROM " + RetSqlName("RG2") + " RG2 "
	cQuery  += " INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery  += " ON SRA.RA_MAT = RG2.RG2_MAT AND SRA.RA_FILIAL = RG2.RG2_FILIAL "
	cQuery  += " WHERE "
	If TcSrvType() != "AS/400"
		cQuery += " RG2.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " RG2.@DELETED@ = ' ' AND SRA.@DELETED@ = ' ' "
	Endif
	cQuery  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
	cQuery  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
	cQuery  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
	cQuery  += " AND RA_ADMISSA <= '" + cAdm + "' "
	cQuery  += " AND RG2_TPBEN IN(" + cQryAux + ") "
	cQuery  += " AND RG2_PEDIDO = " + cReprocessa + " "
	cQuery  += " AND RG2_ANOMES >= '" + cAnoMesDe + "' AND RG2_ANOMES <= '" + cAnoMesAte + "' "
	
	If nOrd == 1
		cQuery  += " ORDER BY SRA.RA_FILIAL,SRA.RA_MAT,RG2.RG2_CODIGO "
	ElseIf nOrd == 2
		cQuery  += " ORDER BY SRA.RA_FILIAL,SRA.RA_CC "
	ElseIf nOrd == 3
		cQuery  += " ORDER BY SRA.RA_FILIAL,SRA.RA_NOME "
	Else
	  cQuery  += " ORDER BY SRA.RA_FILIAL,SRA.RA_MAT,RG2.RG2_CODIGO "
	Endif
	
	//Verifica Tabela Aberta
	If Select("QD03VB") > 0
		DbSelectArea("QD03VB")
		DbCloseArea("QD03VB")
	Endif
	
	//Abrir Tabela
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD03VB", .T., .F.)
	
	//Atualiza regua
	oProcess:SetRegua2(QD03VB->(RecCount()))
	oProcess:IncRegua2("")
	QD03VB->(DbGoTop())
	
	//-Transforma campos em Numerico e/ou Data
	aSraStruct := SRA->(dbStruct())
	For nAux := 1 To Len(aSraStruct)
		If ( aSraStruct[nAux][2] <> "C" )
			TcSetField("QD03VB",aSraStruct[nAux][1],aSraStruct[nAux][2],aSraStruct[nAux][3],aSraStruct[nAux][4])
		EndIf
	Next nAux
	
	QD03VB->(DbGoTop())
	
	cMyChave := ""
	nCount   := 0
	While QD03VB->(!Eof())
	 /////////////////TRATAMENTO PARA SOMAR OPERADORAS VT
		//-Gera apenas 1 linha por funcionario
		If QD03VB->(RA_FILIAL+RA_MAT) == cMyChave 
			QD03VB->(dbSkip())
			Loop
		Else
			cMyChave := QD03VB->(RA_FILIAL+RA_MAT)
		EndIf
	
		if "SODEXOVT" $UPPER(cArqIni)
			aAreaAnt := GetArea()	
			dbSelectArea("SODEXO")          
		    _V := 1
			SODEXO->(DbGoTop())
			While SODEXO->(!Eof())
				IF cMyChave == SODEXO->(R0_FILIAL+R0_MAT) .AND. _V < 6
					cOperadora[_v] := SODEXO->RFP_CDOPSX
					cLinha[_v]     := SODEXO->RFP_LINHSX
					cQtddia[_v]    := SODEXO->R0_QDIAINF
					cVrval[_v]     := SODEXO->R0_VLRVALE 
				    _V := _V + 1
				ENDIF
		    	SODEXO->(dbSkip())
			END
			RestArea( aAreaAnt )
		endif

		if len(alltrim(cOperadora[1])) > 0
			cOp01 := replicate("0",(4-len(alltrim(cOperadora[1]))))+alltrim(cOperadora[1])
		else
			cOp01 := replicate(" ",(4-len(alltrim(cOperadora[1]))))+alltrim(cOperadora[1])		
		endif
		if len(alltrim(cOperadora[2])) > 0
			cOp02 := replicate("0",(4-len(alltrim(cOperadora[2]))))+alltrim(cOperadora[2])
		else
			cOp02 := replicate(" ",(4-len(alltrim(cOperadora[2]))))+alltrim(cOperadora[2])		
		endif
		if len(alltrim(cOperadora[3])) > 0
			cOp03 := replicate("0",(4-len(alltrim(cOperadora[3]))))+alltrim(cOperadora[3])
		else
			cOp03 := replicate(" ",(4-len(alltrim(cOperadora[3]))))+alltrim(cOperadora[3])		
		endif
		if len(alltrim(cOperadora[4])) > 0
			cOp04 := replicate("0",(4-len(alltrim(cOperadora[4]))))+alltrim(cOperadora[4])
		else
			cOp04 := replicate(" ",(4-len(alltrim(cOperadora[4]))))+alltrim(cOperadora[4])		
		endif
		if len(alltrim(cOperadora[5])) > 0
			cOp05 := replicate("0",(4-len(alltrim(cOperadora[5]))))+alltrim(cOperadora[5])
		else
			cOp05 := replicate(" ",(4-len(alltrim(cOperadora[5]))))+alltrim(cOperadora[5])		
		endif

		if len(alltrim(cLinha[1])) > 0
			cLi01 := replicate("0",(5-len(alltrim(cLinha[1]))))+alltrim(cLinha[1])
		else
			cLi01 := replicate(" ",(5-len(alltrim(cLinha[1]))))+alltrim(cLinha[1])		
		endif
		if len(alltrim(cLinha[2])) > 0
			cLi02 := replicate("0",(5-len(alltrim(cLinha[2]))))+alltrim(cLinha[2])
		else
			cLi02 := replicate(" ",(5-len(alltrim(cLinha[2]))))+alltrim(cLinha[2])		
		endif
		if len(alltrim(cLinha[3])) > 0
			cLi03 := replicate("0",(5-len(alltrim(cLinha[3]))))+alltrim(cLinha[3])
		else
			cLi03 := replicate(" ",(5-len(alltrim(cLinha[3]))))+alltrim(cLinha[3])		
		endif
		if len(alltrim(cLinha[4])) > 0
			cLi04 := replicate("0",(5-len(alltrim(cLinha[4]))))+alltrim(cLinha[4])
		else
			cLi04 := replicate(" ",(5-len(alltrim(cLinha[4]))))+alltrim(cLinha[4])		
		endif
		if len(alltrim(cLinha[5])) > 0
			cLi05 := replicate("0",(5-len(alltrim(cLinha[5]))))+alltrim(cLinha[5])
		else
			cLi05 := replicate(" ",(5-len(alltrim(cLinha[5]))))+alltrim(cLinha[5])		
		endif
        //TRANSFORM(cValor,"@E 999999999999.99")
		//cQt01 := IIF (cQtddia[1] > 0,STRZERO(cQtddia[1],4),SPACE(4))
		cQt01 := IIF (ALLTRIM(TRANSFORM(cQtddia[1],"@E 9999")) <> '0',STRTRAN(TRANSFORM(cQtddia[1],"@E 9999")," ","0"),SPACE(4))
		cQt02 := IIF (ALLTRIM(TRANSFORM(cQtddia[2],"@E 9999")) <> '0',STRTRAN(TRANSFORM(cQtddia[1],"@E 9999")," ","0"),SPACE(4))
		cQt03 := IIF (ALLTRIM(TRANSFORM(cQtddia[3],"@E 9999")) <> '0',STRTRAN(TRANSFORM(cQtddia[1],"@E 9999")," ","0"),SPACE(4))
		cQt04 := IIF (ALLTRIM(TRANSFORM(cQtddia[4],"@E 9999")) <> '0',STRTRAN(TRANSFORM(cQtddia[1],"@E 9999")," ","0"),SPACE(4))
		cQt05 := IIF (ALLTRIM(TRANSFORM(cQtddia[5],"@E 9999")) <> '0',STRTRAN(TRANSFORM(cQtddia[1],"@E 9999")," ","0"),SPACE(4))

		//cVl01 := IIF (cVrval[1] > 0,STRZERO(cVrval[1],11,2),SPACE(11))
		cVlXX := ""
		cVl01 := IIF (ALLTRIM(TRANSFORM(cVrval[1],"@E 999999999.99")) <> '0,00',STRTRAN(TRANSFORM(cVrval[1],"@E 999999999.99")," ","0"),SPACE(11))		 
		if len(alltrim(cVl01)) > 0 
			for x = 1 to len(cVl01)
				if substr(cVl01,x,1) $ "0123456789" 
					cVlXX := cVlXX + substr(cVl01,x,1)	
				endif
			next x
			cVl01 := cVlXX
			cVlXX := ""
		endif
		cVl02 := IIF (ALLTRIM(TRANSFORM(cVrval[2],"@E 999999999.99")) <> '0,00',STRTRAN(TRANSFORM(cVrval[2],"@E 999999999.99")," ","0"),SPACE(11))		 
		if len(alltrim(cVl02)) > 0 
			for x = 1 to len(cVl02)
				if substr(cVl02,x,1) $ "0123456789" 
					cVlXX := cVlXX + substr(cVl02,x,1)	
				endif
			next x
			cVl02 := cVlXX
			cVlXX := ""
		endif
		cVl03 := IIF (ALLTRIM(TRANSFORM(cVrval[3],"@E 999999999.99")) <> '0,00',STRTRAN(TRANSFORM(cVrval[3],"@E 999999999.99")," ","0"),SPACE(11))		 
		if len(alltrim(cVl03)) > 0 
			for x = 1 to len(cVl03)
				if substr(cVl03,x,1) $ "0123456789" 
					cVlXX := cVlXX + substr(cVl03,x,1)	
				endif
			next x
			cVl03 := cVlXX
			cVlXX := ""			
		endif
		cVl04 := IIF (ALLTRIM(TRANSFORM(cVrval[4],"@E 999999999.99")) <> '0,00',STRTRAN(TRANSFORM(cVrval[4],"@E 999999999.99")," ","0"),SPACE(11))		 
		if len(alltrim(cVl04)) > 0 
			for x = 1 to len(cVl04)
				if substr(cVl04,x,1) $ "0123456789" 
					cVlXX := cVlXX + substr(cVl04,x,1)	
				endif
			next x
			cVl04 := cVlXX
			cVlXX := ""			
		endif		
		cVl05 := IIF (ALLTRIM(TRANSFORM(cVrval[5],"@E 999999999.99")) <> '0,00',STRTRAN(TRANSFORM(cVrval[5],"@E 999999999.99")," ","0"),SPACE(11))		 
		if len(alltrim(cVl05)) > 0 
			for x = 1 to len(cVl05)
				if substr(cVl05,x,1) $ "0123456789" 
					cVlXX := cVlXX + substr(cVl05,x,1)	
				endif
			next x
			cVl05 := cVlXX
			cVlXX := ""			
		endif		
		
		//Separa Numero do Endereco
	    //Caso nao tenha sido possivel separar o numero do endereco
	    //os conteudos ser„o preenchidos por serem obrigatorios no layout
		cSRA_End := ''
		cSRA_Num := ''
		If (nPos := Rat(",",QD03VB->RA_ENDEREC,1,1)) > 0
			cSRA_End := Substr(QD03VB->RA_ENDEREC,1,nPos - 1)
			cSRA_Num := Substr(QD03VB->RA_ENDEREC,nPos + 1)
		Endif
		If Empty(cSRA_END)
		    cSRA_End := QD03VB->RA_ENDEREC
		    cSRA_Num := "0"
		 EndIf
	
		if ALLTRIM(QD03VB->RA_ESTCIVI) = "S"
			cEstCiv := '1'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) = "C"
			cEstCiv := '2'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) = "V"
			cEstCiv := '3'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) $("D/Q/")
			cEstCiv := '4'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) $("M/O/")
			cEstCiv := '5'
		endif
	
		//-Busca a Sequencia do Endereco
		//-aAdd(aSeqEnd, {QD02VB->RA_LOCBNF, nSeqEnd})
		if len(allTRIM(QD03VB->RA_LOCBNF)) > 0
			nPosEnd := aScan(aSeqEnd, {|x| x[1]==QD03VB->RA_LOCBNF })
			nSeqEnd := aSeqEnd[nPosEnd,02]
	    endif
		cPedido := " " ////QD03VB->RG2_PEDIDO
	
		//Posiciona o SRN / RFO para pegar o Cod.Beneficio do Fornecedor
	
		cItemCod  := ''
		cItemNome := ''
	
		If QD03VB->RG2_TPVALE = "0"   //VT
			dbSelectArea("SRN")
			dbSetOrder(1)	//-RN_FILIAL+RN_COD
			dbSeek(xFilial("SRN")+QD03VB->RG2_CODIGO,.F.)
			cItemCod  := RN_BNFFOR
			cItemNome := RN_DESC
		Else
			dbSelectArea("RFO")          // VR/VA
			dbSetOrder(1)	//-RFO_FILIAL+RFO_TPVALE+RFO_CODIGO
			dbSeek(xFilial("RFO")+QD03VB->RG2_TPVALE+QD03VB->RG2_CODIGO,.F.)
			cItemCod  := RFO_BNFFOR
			cItemNome := RFO_DESCR
		EndIf
	
		dbSelectArea("SR0")               // QTDE VALE POR DIA
		dbSetOrder(3)	//-R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO
		dbSeek(xFilial("SR0")+QD03VB->RG2_MAT+QD03VB->RG2_TPVALE+QD03VB->RG2_CODIGO,.F.)
		cQtdvaledia  := R0_QDIAINF
	
		//cMatricula := QD03VB->RA_MAT
		cMatricula := QD03VB->RA_CIC		
		cNome := QD03VB->RA_NOME
		cDepto := POSICIONE("CTT",1,XFILIAL("CTT")+QD03VB->RA_CC,"CTT_DESC01")
		cFuncao := POSICIONE("SRJ",1,XFILIAL("SRJ")+QD03VB->RA_CODFUNC,"RJ_DESC")
	
		IF QD03VB->RG2_TPVALE == "0"
			cProduto := "007"   //Vale Transporte
			cForma := "002"     // cart„o smart    
	    ELSE
			if "SODEXOVR" $UPPER(cArqIni)
				cProduto := "001"   			//refeiÁ„o pass
				cForma := "002"     			// cart„o smart
			elseif "SODEXOVA" $UPPER(cArqIni)
				cProduto := "002"   			//alimentaÁao pass
				cForma := "004"     			// cart„o magnetico
			elseif "SODEXOVC" $UPPER(cArqIni)
				cProduto := "030"   			//auto pass
				cForma := "004"     			// cart„o magnetico
	        else
				cProduto := "001"   			//refeiÁ„o pass
				cForma := "002"     			// cart„o smart
	        endif
		ENDIF
		
		//-Busca ESTADO do Local de Entrega
		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD03VB->RA_LOCBNF,.F.)
		
		If ( nPos := aScan(aForn410 , { |x| x[1] == RGC_ESTADO }) ) > 0
			cForn410 := aForn410[nPos, 2]
		Else
			cForn410 := "0"
		EndIf
	 
		if !"ALELO" $UPPER(cArqIni)
		
			//Grava Detalhes Funcionario
	
			if "SODEXO" $UPPER(cArqIni) 						
				nTotRegTP3 += 1
				nSeq += 1
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "04" ) )
				nLin += 1	//-Indica que pode imprimir o Relatorio Final			
			elseif "TICKET" $UPPER(cArqIni) 
				nTotRegTP3 += 1
				nTotReg3 += 1
				nDet += 1
				nSeq += 1		
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "03" ) )			
				nLin += 1	//-Indica que pode imprimir o Relatorio Final					
			ELSE
				nTotRegTP3 += 1
				nDet += 1
				nSeq += 1		
				Ntotreg3 += 1
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "03" ) )
				nLin += 1	//-Indica que pode imprimir o Relatorio Final			
			ENDIF
	
		else
			if "ALELOVT" $UPPER(cArqIni)
				nTotRegTP3 += 1
				nTotReg3 += 1
				nDet += 1
				nSeq += 1		
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "03" ) )			
				nLin += 1	//-Indica que pode imprimir o Relatorio Final				
		    endif
		endif
		
		//Totaliza Registros
		//nTotal += nVlr

		if !"ALELO" $UPPER(cArqIni)
			ntotal += QD03VB->RG2_VALCAL
		ENDIF			
		//IncProc("Processando...")
		QD03VB->(dbSkip())
		
	Enddo
	
	
	
	//-------------------------------------------------------------------------------------//
	// Codigo 4 - Beneficiarios	dos Funcionarios para a sodexo existe registo 4           //
	//-------------------------------------------------------------------------------------//

	
	
	//nTotRegTP4 := 0
	//nSeq += 1
	//fWrite( nHdl, RHGeraLinhas( aStruct[2], "04" ) )

	if "ALELOVT" $UPPER(cArqIni)

		dbSelectArea("QD03VB")
		QD03VB->(DbGoTop())
		
		cMyChave := ""
		While QD03VB->(!Eof())
		    
			//-Executa a Validacao dos Funcionarios ( 1x por funcionario )
			If QD03VB->(RA_FILIAL+RA_MAT) <> cMyChave
		   		oProcess:IncRegua2(QD03VB->RA_NOME)
			
				cMyChave := QD03VB->(RA_FILIAL+RA_MAT)
				
				//--??fValidVB(oProcess, "QD03VB")
				bAux := &( '{ || ' + Alltrim(cFuncVal) + '(oProcess, "QD03VB") } ' )
				EVal( bAux )
			EndIf

			cSRA_End := ''
			cSRA_Num := ''
			If (nPos := Rat(",",QD03VB->RA_ENDEREC,1,1)) > 0
				cSRA_End := Substr(QD03VB->RA_ENDEREC,1,nPos - 1)
				cSRA_Num := Substr(QD03VB->RA_ENDEREC,nPos + 1)
			Endif
			If Empty(cSRA_END)
			    cSRA_End := QD03VB->RA_ENDEREC
			    cSRA_Num := "0"
			 EndIf
			
			
			//Grava endereÁos Funcionario
		
				nTotRegTP5 += 1
				nTotal := QD03VB->RG2_VALCAL
				nSeq += 1
				fWrite( nHdl, RHGeraLinhas( aStruct[2], "04" ) )
				nLin += 1	//-Indica que pode imprimir o Relatorio Final
			
			//Totaliza Registros
			//nTotal += nVlr
		
			//IncProc("Processando...")
			QD03VB->(dbSkip())
			
		Enddo
	endif

	
	
	//-------------------------------------------------------------------------------------//
	// Codigo 5 - Insumos - Itens dos Funcionarios	                                       //
	//-------------------------------------------------------------------------------------//
	nTotRegTP5 := 0
	nQtdTotItem := 0
	nvlrTotItem := 0
	
	aForn410 := {}
	aAdd( aForn410, {"SE", "30"})
	aAdd( aForn410, {"PA", "26"})
	aAdd( aForn410, {"RR", "33"})
	aAdd( aForn410, {"DF", "11"})
	aAdd( aForn410, {"MS", "21"})
	aAdd( aForn410, {"MT", "22"})
	aAdd( aForn410, {"PR", "08"})
	aAdd( aForn410, {"SC", "23"})
	aAdd( aForn410, {"CE", "20"})
	aAdd( aForn410, {"GO", "06"})
	aAdd( aForn410, {"PB", "28"})
	aAdd( aForn410, {"AP", "35"})
	aAdd( aForn410, {"AL", "29"})
	aAdd( aForn410, {"AM", "25"})
	aAdd( aForn410, {"MG", "19"})
	aAdd( aForn410, {"RN", "18"})
	aAdd( aForn410, {"TO", "27"})
	aAdd( aForn410, {"RS", "09"})
	aAdd( aForn410, {"RO", "32"})
	aAdd( aForn410, {"PE", "13"})
	aAdd( aForn410, {"AC", "34"})
	aAdd( aForn410, {"RJ", "04"})
	aAdd( aForn410, {"ES", "07"})
	aAdd( aForn410, {"MA", "24"})
	aAdd( aForn410, {"SP", "01"})
	aAdd( aForn410, {"PI", "31"})
	
	aSort( aForn410,,,{ |x,y| x < y } )
	
	dbSelectArea("QD03VB")
	QD03VB->(DbGoTop())
	
	cMyChave := ""
	While QD03VB->(!Eof())
	    
		//-Executa a Validacao dos Funcionarios ( 1x por funcionario )
		If QD03VB->(RA_FILIAL+RA_MAT) <> cMyChave
	   		oProcess:IncRegua2(QD03VB->RA_NOME)
		
			cMyChave := QD03VB->(RA_FILIAL+RA_MAT)
			
			//--??fValidVB(oProcess, "QD03VB")
			bAux := &( '{ || ' + Alltrim(cFuncVal) + '(oProcess, "QD03VB") } ' )
			EVal( bAux )
		EndIf
		
		//Posiciona o SRN / RFO para pegar o Cod.Beneficio do Fornecedor
		cItemCod  := ''
		cItemNome := ''
	
		If QD03VB->RG2_TPVALE = "0"     //VT
			dbSelectArea("SRN")
			dbSetOrder(1)	//-RN_FILIAL+RN_COD
			dbSeek(xFilial("SRN")+QD03VB->RG2_CODIGO,.F.)
	
			cItemCod  := RN_BNFFOR
			cItemNome := RN_DESC
	
		Else
			dbSelectArea("RFO")          //VR / VA /VC
			dbSetOrder(1)	//-RFO_FILIAL+RFO_TPVALE+RFO_CODIGO
			dbSeek(xFilial("RFO")+QD03VB->RG2_TPVALE+QD03VB->RG2_CODIGO,.F.)\
			
			cItemCod  := RFO_BNFFOR
			cItemNome := RFO_DESCR
		EndIf
	
		dbSelectArea("SR0")               // QTDE VALE POR DIA
		dbSetOrder(3)	//-R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO
		dbSeek(xFilial("SR0")+QD03VB->RG2_MAT+QD03VB->RG2_TPVALE+QD03VB->RG2_CODIGO,.F.)
		cQtdvaledia  := R0_QDIAINF
	
		if ALLTRIM(QD03VB->RA_ESTCIVI) = "S"
			cEstCiv := '1'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) = "C"
			cEstCiv := '2'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) = "V"
			cEstCiv := '3'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) $("D/Q/")
			cEstCiv := '4'
		elseif ALLTRIM(QD03VB->RA_ESTCIVI) $("M/O/")
			cEstCiv := '5'
		endif
	
		
		//-Busca ESTADO do Local de Entrega
		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD03VB->RA_LOCBNF,.F.)
		
		If ( nPos := aScan(aForn410 , { |x| x[1] == RGC_ESTADO }) ) > 0
			cForn410 := aForn410[nPos, 2]
		Else
			cForn410 := "0"
		EndIf
		
		//Grava Detalhes Funcionario
	
	
		if !"SODEXO" $UPPER(cArqIni) .and. !"TICKET" $UPPER(cArqIni) 					
			nTotRegTP5 += 1
			nSeq += 1
			fWrite( nHdl, RHGeraLinhas( aStruct[2], "05" ) )
			nTotal += QD03VB->RG2_VALCAL
			nLin += 1	//-Indica que pode imprimir o Relatorio Final
		ENDIF
		
		//Totaliza Registros
		//nTotal += nVlr
	
		//IncProc("Processando...")
		QD03VB->(dbSkip())
		
	Enddo
	
	//-------------------------------------------------------------------------------------//
	// Codigo 9 - Trailler do Arquivo				                                       //
	//-------------------------------------------------------------------------------------//

	if  "TICKET" $UPPER(cArqIni) 
		fWrite( nHdl, RHGeraLinhas( aStruct[3], "01" ) )
		nSeq += 1
		cTotheader += 1 
		fWrite( nHdl, RHGeraLinhas( aStruct[3], "02" ) )
	else
		nTotReg := nSeq+1
		
		nSeq    += 1
		cTottrailler += 1
		fWrite( nHdl, RHGeraLinhas( aStruct[3] ) )
	endif
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas relatorio /*/
//-------------------------------------------------------------------
Static Function fImpLis()

	//Inicia Variaveis
	Private cString  := '' // Alias do Arquivo Principal
	Private aOrd     := {""}
	Private aReturn  := { STR0015, 1, STR0016, 1, 2, 2,'',1 } //"Especial" - "AdministraáÑo"
	Private nTamanho := 'P'
	Private cPerg    := ''
	Private wCabec0  := 2
	Private wCabec1  := STR0042 +space(02) +STR0043 +space(04) +STR0044 +space(30) +STR0045 +space(5) +STR0046
	                // 'Filial  Matricula  Nome                  TP Benef.  Valor Benef.'
	Private wCabec2  := ''
	Private NomeProg := 'BENEFARQ'
	Private nLastKey := 0
	Private m_pag    := 0
	Private Li       := 0
	Private ContFl   := 1
	Private nOrdem   := 0
	Private nChar    := 0
	Private lEnd     := .F.
	Private wnrel    := 'BENEFARQ'
	
	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,"",STR0017,STR0018,STR0019,,.F.,aOrd,.F.,nTamanho) //'LISTAGEM DE BENEFICIOS' - 'Emissao de Relatorio para avaliacao de Benef˙Äios. ' - 'Sera impresso de acordo com os parametros solicitados. '
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	//Processa Impressao
	RptStatus({|lEnd| fImpNota()},STR0021) //'Imprimindo...'
	
Return

Static Function fImpNota()
	//Inicia Variaveis
	Local cFilialAnt    := ''
	Local cCcAnt        := ''
	Local nTfunc        := 0
	Local nTccFunc      := 0
	Local nTFlFunc      := 0
	Local nTBen         := 0
	Local nTccBen       := 0
	Local nTFlBen       := 0
	Local lVez          := .T.
	
	// Posiciona Registro
	dbSelectArea("QD03VB")
	QD03VB->(DbGoTop())
	
	//Set Regua
	SetRegua(0)
	
	//Se Ordem Centro de Custo Imprime Nome Centro de Custo
	If nOrd == 2
		dbSelectArea("CTT")
		dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
		dbSeek(xFilial("CTT")+QD03VB->RA_CC,.F.)
		
		cDet := Space(5) + AllTrim(QD03VB->RA_CC) + " - " + CTT->CTT_DESC01
		Impr(cDet,'C')
	Endif
	
	//Carrega Filial
	cFilialAnt := QD03VB->RG2_FILIAL
	
	While !QD03VB->(Eof())
		//Abortado Pelo Operador
		If lAbortPrint
			cDet := STR0020 //'*** ABORTADO PELO OPERADOR ***'
			Impr(cDet,'C')
			Exit
		EndIF
		
		nVlr := QD03VB->RG2_VALCAL
		cDet := QD03VB->RG2_FILIAL + Space(2) + QD03VB->RG2_MAT + Space(2) + QD03VB->RA_NOME + Space(10) + QD03VB->RG2_TPBEN + Space(9) +Transform(nVlr,'@E 999,999.99')
		Impr(cDet,'C')
		
		QD03VB->(dbSkip())
		
		IncRegua(STR0021)
		
		//Totaliza
		nTfunc   += 1
		nTccFunc += 1
		nTFlFunc += 1
		nTBen    += nVlr
		nTccBen  += nVlr
		nTFlBen  += nVlr
		
		If nOrd == 2
			If cCcAnt != QD03VB->RA_CC .Or. cFilialAnt != QD03VB->RG2_FILIAL
				cCcAnt := QD03VB->RA_CC
				
				cDet := STR0022 + Space(10) + Transform(nTccBen,'@E 999,999,999.99') //'Valores Totais Centro de Custo: '
				Impr(cDet,'C')
				
				cDet := STR0023 + Space(10)  + Transform(nTccFunc, '@E 9,999') //'Quantidade de lanÁamentos Centro Custo: '
				Impr(cDet,'C')
				cDet := ''
				Impr(cDet,'C')
				
				nTccFunc := 0
				nTccBen  := 0
				
				If !QD03VB->(Eof()) .And. cFilialAnt == QD03VB->RG2_FILIAL
					dbSelectArea("CTT")
					dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
					dbSeek(xFilial("CTT")+QD03VB->RA_CC,.F.)
				
					cDet := Space(5) + AllTrim(QD03VB->RA_CC) + " - " + CTT->CTT_DESC01
					Impr(cDet,'C')
				Endif
				
			Endif
		Endif
		
		If cFilialAnt != QD03VB->RG2_FILIAL
			cFilialAnt := QD03VB->RG2_FILIAL
			
			//Imprime Totais
		   Impr('','C')
	   
			cDet := STR0024 + Space(10) + Transform(nTFlBen,'@E 999,999,999.99') //'Valores Totais da Filial: '
			Impr(cDet,'C')
			
			cDet := STR0025 + Transform(nTFlFunc, '@E 9,999') //'Quantidade de lancamentos da Filial: '
			Impr(cDet,'C')
			
			//Salta P·gina
			cDet := ''
			Impr(cDet,'F')
			
			nTFlFunc := 0
			nTFlBen  := 0
			
			If !QD03VB->(Eof())
				dbSelectArea("CTT")
				dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
				dbSeek(xFilial("CTT")+QD03VB->RA_CC,.F.)
				
				cDet := Space(5) + AllTrim(QD03VB->RA_CC) + " - " + CTT->CTT_DESC01
				Impr(cDet,'C')
			Endif
			
		Endif
		
	EndDo
	
	//Totaliza
	Impr('','C')
	
	cDet := STR0026 + Space(30) + Transform(nTBen,'@E 999,999,999.99') //'Valores Totais da Empresa: '
	Impr(cDet,'C')
	
	cDet := STR0027 + Transform(nTfunc, '@E 9,999') //'Quantidade de lanÁamentos da Empresa: '
	Impr(cDet,'C')
	
	cDet := ''
	Impr(cDet,'F')
	
	If aReturn[5] == 1
		Set Printer to
		Ourspool(wnrel)
	Endif
	
	MS_FLUSH()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
user Function BENEFOpcoes()
	Local MvPar
	Local MvParDef := ""
	Local aItens   := {}
	Local aArea    := GetArea()
	
	MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
	MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	dbSelectArea("RCC")
	dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
	dbSeek(xFilial("RCC")+"S011")
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S011"
		
		If Substr(RCC->RCC_CONTEU,33,3) == alltrim(MV_PAR01)
			aAdd(aItens, Substr(RCC->RCC_CONTEU,3,30))
			MvParDef += Substr(RCC->RCC_CONTEU,1,2)
		EndIf
		
		("RCC")->(dbSkip())
	End
	
	//         Retorno,Titulo,opcoes,Strin Ret,lin,col, Tipo Sel,tam chave , n. ele ret, Botao
	IF f_Opcoes(@MvPar, STR0017, aItens, MvParDef, 12, 49, .F., 2)  // "OpÁıes"
		&MvRet := MvPar                                      // Devolve Resultado
	EndIF
	
	RestArea(aArea)                                  // Retorna Alias

Return MvParDef


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
Static Function VBOpcoes()
	aRegs := {}
	cVBPerg := Left(cVBPerg,6)
	
	//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP
	aAdd(aRegs,{cVBPerg,"01","Fornecedor         ?","Fornecedor         ?","Fornecedor         ?","mv_ch1","C",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","S018","","",""})
	aAdd(aRegs,{cVBPerg,"02","Tipo de Beneficios ?","Tipo de Beneficios ?","Tipo de Beneficios ?","mv_ch2","C",08,0,0,"G","BENEFOpcoes()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"03","Reprocessamento    ?","Reprocessamento    ?","Reprocessamento    ?","mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"04","De Mes/Ano         ?","De Mes/Ano         ?","De Mes/Ano         ?","mv_ch4","C",08,0,0,"G","naovazio()","mv_par04","","","","00/0000","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"05","Ate Mes/Ano        ?","Ate Mes/Ano        ?","Ate Mes/Ano        ?","mv_ch5","C",08,0,0,"G","naovazio()","mv_par05","","","","99/9999","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"06","Da Filial          ?","Da Filial          ?","Da Filial          ?","mv_ch6","C",08,0,0,"G","","mv_par06","","","","0       ","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cVBPerg,"07","Ate a Filial       ?","Ate a Filial       ?","Ate a Filial       ?","mv_ch7","C",08,0,0,"G","","mv_par07","","","","ZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cVBPerg,"08","Do Centro Custo    ?","Do Centro de Custo ?","Do Centro de Custo ?","mv_ch8","C",09,0,0,"G","","mv_par08","","","","0        ","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
	aAdd(aRegs,{cVBPerg,"09","Ate Centro de Custo?","AtÅECentro de Custo?","AtÅECentro de Custo?","mv_ch9","C",09,0,0,"G","","mv_par09","","","","999999999","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
	aAdd(aRegs,{cVBPerg,"10","Da Matricula       ?","Da Matricula       ?","Da Matricula       ?","mv_cha","C",06,0,0,"G","","mv_par10","","","","0     ","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	aAdd(aRegs,{cVBPerg,"11","Ate Matricula      ?","Ate Matricula      ?","Ate Matricula      ?","mv_chb","C",06,0,0,"G","","mv_par11","","","","999999","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	aAdd(aRegs,{cVBPerg,"12","Data de Referencia ?","Data de Referencia ?","Data de Referencia ?","mv_chc","D",08,0,0,"G","naovazio()","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"13","Data Credito       ?","Data Credito       ?","Data Credito       ?","mv_chd","D",08,0,0,"G","naovazio()","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"14","Consid.Admitido Ate?","Consid.Admitido Ate?","Consid.Admitido Ate?","mv_che","D",08,0,0,"G","naovazio()","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"15","Imprime Listagem   ?","Imprime Listagem   ?","Imprime Listagem   ?","mv_chf","N",01,0,0,"C","","mv_par15","Yes","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cVBPerg,"16","Ordem Relatorio    ?","Ordem Relatorio    ?","Report Order       ?","mv_chg","N",01,0,0,"C","","mv_par16","Register","Matricula","EmployeeID","","","Centro Custo","Centro Custo","Cost Center","","","Nome","Nombre","Name","","","","","","","","","","","","","","",""})
	
	ValidPerg(aRegs,cVBPerg ,.F.)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
Static Function fFormatDate(dData)

	Local cRet:= Day2Str(dData) + "/" + Month2Str(dData) + "/" + Year2Str(dData)
	
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcao de Validacao dos Funcionarios            /*/
//-------------------------------------------------------------------
Static Function VBValida(oProcess, cMyAlias)

	Local lRetErr := .T.
	Default cMyAlias := "SRA"
	
	If Empty( (cMyAlias)->RA_CEP )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0034 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_CEP em branco."  
	EndIf
	If Empty( (cMyAlias)->RA_CIC )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0035 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_CIC em branco."
	EndIf
	If Empty( (cMyAlias)->RA_RG )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0036 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_RG em branco." 
	EndIf
	If Empty( (cMyAlias)->RA_MAE )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0037 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_MAE em branco."
	EndIf
	If Empty( (cMyAlias)->RA_ENDEREC )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0038 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_ENDEREC em branco." 
	EndIf
	///If Empty( (cMyAlias)->RA_COMPLEM )
	///	lRetErr := .F.
	///	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0039 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_COMPLEM em branco."
	///EndIf
	If Empty( (cMyAlias)->RA_MUNICIP )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0040 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_MUNICIP em branco." 
	EndIf
	If Empty( (cMyAlias)->RA_ESTADO )
		lRetErr := .F.
		oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0041 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com campo RA_ESTADO em branco."
	EndIf
	If Empty( (cMyAlias)->RA_LOCBNF )
	    lRetErr := .F.
	    oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0055 ) //"Filial: ", " - Matricula: ", " - Funcion·rio com o Codigo do Local de Entrega (RA_LOCBNF) em branco."
	EndIf
	
	If !lRetErr
		lImpLis   := .F.
		lErrorImp := .T.
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza status RG2                             /*/
//-------------------------------------------------------------------
Static Function fAtuRG2()
  // Posiciona Regitro
  dbSelectArea("QD03VB")
  QD03VB->(DbGoTop())

  While QD03VB->(!Eof())
    
     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //  Atualizar arquivo de histÛrico de benef˙Äios                                  
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     DbSelectArea("RG2")
     DbSetOrder ( RetOrder ("RG2", "RG2_FILIAL+RG2_MAT+RG2_ANOMES+RG2_TPVALE+RG2_CODIGO" ))
     If dbSeek( QD03VB->RG2_FILIAL + QD03VB->RG2_MAT + QD03VB->RG2_ANOMES + QD03VB->RG2_TPVALE + QD03VB->RG2_CODIGO )
         RecLock("RG2",.F.)
         RG2->RG2_PEDIDO := 2
         MsUnlock()
     EndIf
          
    QD03VB->(dbSkip())
  Enddo

Return
