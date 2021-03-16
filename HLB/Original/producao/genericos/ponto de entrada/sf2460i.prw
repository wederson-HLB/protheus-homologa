#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/10/00
#Include "tbiconn.ch"  
#Include "TopConn.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?SF2460I  ?Autor ?HAMILTON               ?Data ?         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Ponto de Entrada Apos Geracao de Notas Fiscais Saida        ³±?
±±?         ?Tendo Diversos Objetivos:                                   ³±?
±±?         ?- alterar a data do venc. do titulo conf. parametros        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ?                                                            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/

Funcao      : SF2460I 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Manutencao arquivo SZ3 - grupos de clientes shiseido
Autor     	: Hamilton
Data     	: 19/02/03                       '
Obs         : Ponto de Entrada Apos Geracao de Notas Fiscais Saida, Tendo Diversos Objetivos:  - alterar a data do venc. do titulo conf. parametros   
TDN         : 
Revisão     : João Silva
Data/Hora   : 06/05/2013
Módulo      : Faturamento. 
Cliente     : Okuma
*/

User Function SF2460I()
// Variaveis especifico Salton
Local _cDoc			//Numero da Nota Fiscal
Local _cSerie		//Serie da Nota Fiscal
Local _cCliente		//Cliente do PV ou NF
Local _cLoja		//Loja do PV ou NF
Local _cPedido		//Numero do Pedido de Venda
Local _cNaturez		//Natureza do cliente
Local _cNomeCli		//Nome fatazia do cliente
Local _cCond		//Condicao de pagamento do pedido
Local bb, pp		//Controla for..next
Local _aBonific		:= {} //Array com os tipos de bonificacao encontrados para cada item da nf. sendo [1]=GRUPO, [2]=TIPO BONIFIC, [3]=PERCENT, [4]=Base para calculo
Local _aParc		:= {} //Arrya com as parcelas de cada bonificacao
Local _cPerfixo		:= &(GetMv("MV_1DUPREF"))
Local _nChr			:=	Asc(Alltrim(GetMv("MV_1DUP"))) - 1
Local _cParcela		:=	" "
Local cSQL     := ""
Local cAlias   := GetNextAlias()
Local aAreaSE1 := SE1->(GetArea()) 
Local cCod     := ""
Local cHist    := ""
Local cCartao  := ""

Private _nTotalOp

If SM0->M0_CODIGO == "BH"
	_cCond:= Getmv("MV_PYCOND")
	if sf2->f2_COND $ _cCond
		_cPer1 := Getmv("MV_PYPER1")
		_cPer2 := Getmv("MV_PYPER2")
		_cPer3 := Getmv("MV_PYPER3")
		//_cEmp  := Getmv("MV_PYEMP")
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xfilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
		While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
			_dVencto := SE1->E1_VENCTO
			_cDia := strzero(day(_dVencto),2)
			_cMes:=strzero(month(_dVencto),2)
			_cAno:=strzero(year(_dVencto),4)
			_Dia:=strzero(DAY(_dVencto),2)
			_Mes:=0
			_FLAG:=.F.
			///1
			if substr(_cPer1,1,2) > substr(_cPer1,4,2) .AND. !_FLAG// PERIODO1 MAOIR Q PERIODO2
				_Mes:=1
				_dia:=substr(_cPer1,7,2)
				_FLAG:=.T.
			else
				if _cDia >= substr(_cPer1,1,2) .and. _cDia <= substr(_cPer1,4,2) .AND. !_FLAG
					_dia:=substr(_cPer1,7,2)
					_FLAG:=.T.
				endif
			endif
			
			if substr(_cPer2,1,2) > substr(_cPer2,4,2) .AND. !_FLAG// PERIODO1 MAOIR Q PERIODO2
				_Mes:=1
				_dia:=substr(_cPer2,7,2)
				_FLAG:=.T.
			else
				if substr(_cPer2,1,2) <= substr(_cPer2,4,2) .and. _cDia >= substr(_cPer2,1,2) .and. _cDia <= substr(_cPer2,4,2).AND. !_FLAG
					_dia:=substr(_cPer2,7,2)
					_FLAG:=.T.
				endif
			endif
			///3
			if substr(_cPer3,1,2) > substr(_cPer3,4,2) .AND. !_FLAG // PERIODO1 MAOIR Q PERIODO2
				_Mes:=1
				_dia:=substr(_cPer3,7,2)
				_FLAG:=.T.
			else
				if substr(_cPer3,1,2) <= substr(_cPer3,4,2) .and. _cDia >= substr(_cPer3,1,2) .and. _cDia <= substr(_cPer3,4,2).AND. !_FLAG
					_dia:=substr(_cPer3,7,2)
					_FLAG:=.T.
				endif
			endif
			RecLock("SE1",.F.)
			if _cMes = "12" .and. _mes <> 0
				_cmes:="01"
				_mes:=0
				_cAno:=str(val(_cAno)+1,4)
			endif
			SE1->E1_VENCREA :=ctod(_dia+"/"+strzero(val(_cMes)+_mes,2)+"/"+_cAno)
			SE1->E1_VENCTO  :=ctod(_dia+"/"+strzero(val(_cMes)+_mes,2)+"/"+_cAno)
			MsUnLock()
			dbSkip()
		EndDo
	endif
Endif

///////// Especifico para identificacao de titulos de cartao de credito - Ferrosan
IF SM0->M0_CODIGO == "AJ"     // GRAVA IDENTIFICACAO DA COMPRA CARTAO CREDITO
	dbSelectArea("SF2")
	RECLOCK("SF2")
	SF2->F2_P_CCRE := SC5->C5_P_CCRE
	MSUNLOCK()
	_CCRED := SF2->F2_P_CCRE
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xfilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
	While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
		RecLock("SE1",.F.)
		SE1->E1_P_CCRE := _CCRED
		MsUnLock()
		dbSkip()
	EndDo
ENDIF

If cEmpAnt $ "DJ" //EMPRESA wfi
	
	cItCon    :=""   // vai armazenar a primeira ocorrencia do item contabil
	//cItPedFlag:="ZZ"  // vai pegar o primeiro item do pedido para buscar o item contabil
	cIcc      :=""
	xCALCISS  :=""
	TBISS     :=0.00
	biss      :=0.00
	TVISS     :=0.00
	viss      :=0.00
	aiss      :=0.00
	nTotVlInss:=0
	_cIss     := SC5->C5_P_REISS
	
	//---------------------------Corrente
	_cAlias := Alias()
	_nOrder := DbSetOrder()
	_nRecno := Recno()
	//---------------------------
	
	//---------------------------Itens da nota
	DbSelectArea("SD2")
	_nOrderSd2 := DbSetOrder()
	_nRecnoSd2 := Recno()
	//---------------------------
	
	//---------------------------Itens do Pedido
	DbSelectArea("SC6")
	_nOrderSc6 := DbSetOrder()
	_nRecnoSc6 := Recno()
	//---------------------------
	
	SF4->(DbSetOrder(1))
	SF4->(xFilial("SF4")+SD2->D2_TES)
	
	If AllTrim(SF4->F4_ISS) $ "S"
		SD2->(DbSetOrder(3))
		SD2->(DbSeek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		While !Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
			SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
				cIcc      := SC6->C6_P_CC
				cItCon    :=SC6->C6_P_ITCON
				aIss      := If(Empty(SC6->C6_P_ALIQ),aIss,SC6->C6_P_ALIQ)
				bIss      += SD2->D2_TOTAL
				nTotVlInss+=SC6->C6_P_VINSS
			Endif
			RecLock("SD2",.F.)
			Replace SD2->D2_CCUSTO  With cIcc                /// FRANCISCO
			Replace SD2->D2_P_ITCON With cItCon              /// GRAVA CC E ITEM CONTABIL DO PEDIDO DE VENDAS
			Replace SD2->D2_BASEISS With SD2->D2_TOTAL
			Replace SD2->D2_VALISS  With ((SD2->D2_TOTAL * AISS)/100)
			Replace SD2->D2_ALIQISS With AISS
			MsUnLock()
			tviss += ((SD2->D2_TOTAL * AISS)/100)
			tbiss += SD2->D2_TOTAL
			SD2->(DbSkip())
		EndDo
		
		Reclock("SF2",.F.)
		Replace SF2->F2_VALISS With tvIss
		MsUnlock()
		
		If _cIss $ "3"
			_cIss :="1"//"2"  2--> Devido para a cidade 1-->Retido
			SID->(DbSetOrder(1))                            //Wederson -04/03/05 ---> Pesquisa onde est?sendo executada a obra
			SID->(DbSeek(xFilial("SID")+cItCon))
			If AllTrim(SM0->M0_FILIAL) $ SID->ID_P_MUN
				_cIss := "1"
			Endif
		Endif
		
		Reclock("SF3",.F.)
		Replace SF3->F3_BASEICM With SF2->F2_BASEISS
		Replace SF3->F3_ALIQICM With aIss
		Replace SF3->F3_VALICM  With tvIss
		Replace SF3->F3_RECISS  With _cIss
		Replace SF3->F3_TIPO    With "S"
		Replace SF3->F3_CODISS  With "2828"
		MsUnlock()
		
		TBISS := 0.00
		TVISS := 0.00
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xfilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC))
		While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
			If SE1->E1_TIPO='NF ' .AND. SE1->E1_PARCELA $'A/ /'
				RecLock("SE1",.F.)
				SE1->E1_P_VINSS := SE1->E1_INSS   					//GUARDA O VALOR ORIGINAL DO CAMPO INSS
				SE1->E1_P_VLTIT := SE1->E1_SALDO  					//GUARDA O VALOR ORIGINAL DO SALDO
				SE1->E1_INSS    := SE1->E1_INSS   - nTotVlInss    // TIRA INSS INFORMADO
				SE1->E1_VALLIQ  := SE1->E1_VALOR - SE1->E1_INSS  /// + nTotVlInss    // SOMA INSS INFORMADO
				SE1->E1_P_ITCON := cItCon
				SE1->E1_P_CUSTO := cIcc
				MsUnLock()
			ELSEIF SE1->E1_TIPO='IN-'.AND. SE1->E1_PARCELA $'A/ /'
				RecLock("SE1",.F.)
				SE1->E1_VALOR  := SE1->E1_VALOR  - nTotVlInss
				SE1->E1_VLCRUZ := SE1->E1_VLCRUZ - nTotVlInss
				SE1->E1_P_VLTIT := SE1->E1_SALDO  					//GUARDA O VALOR ORIGINAL DO SALDO
				SE1->E1_SALDO   := SE1->E1_VALOR ///// - nTotVlInss   //MUDA E1_SALDO PARA DEWCONTAR O INSS DO VALOR DO TITULO
				MsUnLock()
			ENDIF
			SE1->(DbSkip())
		EndDo
	Endif
	
	DbSelectArea("SD2")
	DbSetOrder(_nOrderSd2)
	DbGoto(_nRecnoSd2)
	
	DbSelectArea("SC6")
	DbSetOrder(_nOrderSc6)
	DbGoto(_nRecnoSc6)
	
	DbSelectArea(_cAlias)
	DbSetOrder(_nOrder)
	DbGoto(_nRecno)
	
Endif

If SM0->M0_CODIGO $ "D1" //EMPRESA TELLABS
	
	// Matriz para Salvamento da Integridade do Sistema. {Area,Ordem,Registro}
	_aGetAreas := {{"SB1",{}},{"SED",{}},{"SC6",{}},{"SD2",{}},{"SE1",{}},{"SF2",{}}}
	
	// SALVA AREAS DIVERSAS
	For _nNum := 1 To Len(_aGetAreas)
		dbSelectArea(_aGetAreas[_nNum,1])
		_aGetAreas[_nNum,2] := GetArea()
	Next
	
	cItCon:=""   // vai armazenar a primeira ocorrencia do item contabil
	cItPedFlag:="ZZ"  // vai pegar o primeiro item do pedido para buscar o item contabil
	cIcc := ""
	_cTCOD:= ""
	xCALCISS := " "
	TBISS:= 0.00
	biss := 0.00
	TVISS:= 0.00
	viss := 0.00
	aiss := 0.00
	
	
	//POSICIONA D2 PARA CHEGAR AO SC6
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While !Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
		SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		
		// BUSCA SC6
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV)
			cIcc := SC6->C6_P_PRJ
			_cTCOD := SC6->C6_P_COD
		ENDIF
		dbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_P_PRJ := cIcc
		SD2->D2_P_COD := _cTCOD
		MsUnLock()
		dbSkip()
	EndDo
	
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xfilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC)
	While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
		//TROCA O TIPO NF - TITULO ORIGINAL
		IF SE1->E1_TIPO='NF ' .AND. SE1->E1_PARCELA $'A/ /'
			RecLock("SE1",.F.)
			SE1->E1_P_PRJ := cIcc
			MsUnLock()
			//TROCA O TIPO IN-  TITULO DO INSS
		ELSEIF SE1->E1_TIPO='IN-'.AND. SE1->E1_PARCELA $'A/ /'
			RecLock("SE1",.F.)
			SE1->E1_P_PRJ := cIcc
			MsUnLock()
		ENDIF
		dbSkip()
	EndDo
	//RESTAURA AS AREAS AOS ORIGINAIS
	For _nNum := 1 To Len(_aGetAreas)
		RESTAREA(_aGetAreas[_nNum,2])
	Next
ENDIF

// Especifico Okuma  -- Wederson 29/11/04

If cEmpAnt $ "ED"

	DbSelectArea("SD2")    
    //TLM 07/02/2011
   
    cDoc		:= SF2->F2_DOC
    cSerie		:= SF2->F2_SERIE
    cCliente	:= SC5->C5_CLIENTE
    cLoja		:= SC5->C5_LOJACLI
    cPedido  	:= SC5->C5_NUM    

    SD2->(DbSetOrder(3))
    SD2->(DbGotop())
    SD2->(DbSeek(xFilial("SD2")+cDoc+cSerie+cCliente+cLoja))
      
    While SD2->(!EOF()) .And. SD2->D2_DOC==cDoc .and. SD2->D2_SERIE==cSerie .and. SD2->D2_CLIENTE==cCliente .and. SD2->D2_LOJA==cLoja
    
       SC6->(DbSetOrder(2))
	   If SC6->(DbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	      Reclock("SD2",.F.)
	      SD2->D2_P_MAQUI:=SC6->C6_P_MAQUI     //Modelo da maquina
	      SD2->D2_P_SERIE:=SC6->C6_P_SERIE     //Numero de serie
	      MsUnlock() 		
	   EndIf
       
       SD2->(DbSkip())
       
    EndDo
	
	//JOSE
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While !Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
		SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV)
			_cTCOD := SC6->C6_P_COD
		ENDIF
		dbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_P_COD := _cTCOD
		MsUnLock()
		dbSkip()
	EndDo
	
Endif

//Especifico Salton
If cEmpAnt $ "EQ"
	_aArea    := GetArea()
	
	// Dados da Nota Fiscal de Saida
	_cDoc		:= SF2->F2_DOC
	_cSerie		:= SF2->F2_SERIE
	//Dados do Pedido de Venda
	_cCliente	:= SC5->C5_CLIENTE
	_cLoja		:= SC5->C5_LOJACLI
	_cPedido	:= SC5->C5_NUM
	_cCond		:= SC5->C5_CONDPAG
	_cNaturez	:= Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NATUREZ")
	_cNomeCli	:= Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NREDUZ")
	
	//Verifica os grupos dos produtos dos itens da nota fiscal e grava num array
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbGotop()
	dbSeek(xFilial("SD2")+_cDoc+_cSerie+_cCliente+_cLoja)
	While !eof() .and. SD2->D2_DOC=_cDoc .and. SD2->D2_SERIE=_cSerie .and. SD2->D2_CLIENTE=_cCliente .and. SD2->D2_LOJA=_cLoja
		dbSelectArea("SF4")
		dbSeek(xFilial("SF4")+SD2->D2_TES)
		If SF4->F4_DUPLIC=="N"
			dbSelectArea("SD2")
			dbSkip()
			Loop
		EndIf
		dbSelectArea("SZ1")
		dbSetOrder(1) //Filial+Cliente+Loja+Grupo+tipo
		If dbSeek(xFilial("SZ1")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_GRUPO,.T.) .or. dbSeek(xFilial("SZ1")+SD2->D2_CLIENTE+SD2->D2_LOJA+"****",.T.)
			While !eof() .and. SZ1->Z1_CLIENTE==SD2->D2_CLIENTE .and. SZ1->Z1_LOJA==SD2->D2_LOJA .and. (SZ1->Z1_GRUPO==SD2->D2_GRUPO .or. SZ1->Z1_GRUPO=="****")
				If SZ1->Z1_INICIO < dDatabase .and. SZ1->Z1_FIM>dDatabase
					_nPos := aScan(_aBonific,{ |x| x[2] == SZ1->Z1_TIPOBON})
					//				_nPos := aScan(_aBonific,{ |x| x[1] == SD2->D2_GRUPO .and. x[2] == SZ1->Z1_TIPOBON})
					If _nPos == 0
						If SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="N"
							Aadd(_aBonific,{SD2->D2_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*(SD2->D2_TOTAL-SD2->D2_VALICM)} )
						ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="N"
							Aadd(_aBonific,{SD2->D2_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALIPI)} )
						ElseIf SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="S"
							Aadd(_aBonific,{SD2->D2_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALICM)} )
						ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="S"
							Aadd(_aBonific,{SD2->D2_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALIPI+SD2->D2_VALICM)} )
						EndIf
					Else
						If SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="N"
							_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*(SD2->D2_TOTAL-SD2->D2_VALICM)
						ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="N"
							_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALIPI)
						ElseIf SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="S"
							_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALICM)
						ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="S"
							_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD2->D2_TOTAL-SD2->D2_VALICM)+SD2->D2_VALIPI+SD2->D2_VALICM)
						EndIf
					Endif
				EndIf
				dbSelectArea("SZ1")
				dbSkip()
			End
		EndIf
		dbSelectArea("SD2")
		dbSkip()
	End
	
	//Atualiza no Contas a Receber criando os titulos de bonificação em cada parcela
	dbSelectArea("SE1")
	For bb := 1 to Len(_aBonific)
		_aParc  := Condicao(_aBonific[bb][3],_cCond,,dDatabase)
		For pp := 1 to Len(_aParc)
			RecLock("SE1",.T.)
			Replace E1_FILIAL	With	xFilial("SE1")
			Replace E1_PREFIXO	With	_aBonific[bb][2]
			Replace E1_NUM		With	_cDoc
			Replace E1_PARCELA	With	Iif(Len(_aParc)>1,Chr(_nChr + pp),"")
			Replace E1_TIPO		With	"NCC"
			Replace E1_CLIENTE	With	_cCliente
			Replace E1_LOJA		With	_cLoja
			Replace E1_NATUREZ	With	_cNaturez
			Replace E1_EMISSAO	With	dDatabase
			Replace E1_VENCTO	With	_aParc[pp][1]
			Replace E1_VENCREA	With	DataValida(_aParc[pp][1])
			Replace E1_VALOR	With	_aBonific[bb][3]/Len(_aParc) //Valor
			Replace E1_NOMCLI	With	_cNomeCli
			Replace E1_EMIS1	With	dDataBase
			Replace E1_HIST		With	"DESC. BONIF. "+_aBonific[bb][2]//Grupo
			Replace E1_LA		With	"S"
			Replace E1_SITUACA	With	"0"
			Replace E1_SALDO	With	_aBonific[bb][3]/Len(_aParc) //Valor
			Replace E1_MOEDA	With	1
			Replace E1_PEDIDO	With	_cPedido
			Replace E1_VLCRUZ	With	_aBonific[bb][3]/Len(_aParc) //Valor
			Replace E1_NUMNOTA	With	_cDoc
			Replace E1_SERIE	With	_cSerie
			Replace E1_STATUS	With	"A"
			Replace E1_ORIGEM	With	"MATA460"
			Replace E1_VENCORI	With	_aParc[pp][1]
			Replace E1_FILORIG	With	xFilial("SE1")
			MsUnlock()
		Next
	Next
	
	RestArea(_aArea)
EndIf

//Especifico Intralox -- Wederson 14/07/05
/*
If cEmpAnt $ "U6"
	_cAlias:=Alias()
	_nRecno:=Recno()
	
	SD2->(DbSetOrder(8))
	SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+"01"))
	While SD2->D2_FILIAL+SD2->D2_PEDIDO == xFilial("SD2")+SC6->C6_NUM
		
		If AllTrim(SD2->D2_COD) == "99999" .Or. AllTrim(SD2->D2_COD) == '9999TDBELT'     
			If fGeraOp()
				fGeraMov()
			Endif
		Endif
		SD2->(DbSkip())
	End
	
	DbSelectArea(_cAlias)
	DbGoto(_nRecno)
Endif   
*/
If cEmpAnt $ "JQ" //Monster teste 

   _cDoc		:= SF2->F2_DOC
   _cSerie		:= SF2->F2_SERIE
   _cCliente	:= SC5->C5_CLIENTE
   _cLoja		:= SC5->C5_LOJACLI
   _cPedido  	:= SC5->C5_NUM    

   SD2->(DbSetOrder(3))
   SD2->(DbGotop())
   SD2->(DbSeek(xFilial("SD2")+_cDoc+_cSerie+_cCliente+_cLoja))
		
   While SD2->(!EOF()) .And. SD2->D2_DOC=_cDoc .and. SD2->D2_SERIE=_cSerie .and. SD2->D2_CLIENTE=_cCliente .and. SD2->D2_LOJA=_cLoja

      SF4->(DbSetOrder(1))
      SF4->(xFilial("SF4")+SD2->D2_TES)
      
      If SF4->F4_PODER3 $ "R" 
   
         RecLock("SB6",.T.)
         SB6->B6_FILIAL  := xFilial("SB6") 
         SB6->B6_CLIFOR  := SD2->D2_CLIENTE
         SB6->B6_LOJA    := SD2->D2_LOJA
         SB6->B6_PRODUTO := SD2->D2_COD
         SB6->B6_LOCAL   := "90"
         SB6->B6_DOC     := SD2->D2_DOC
         SB6->B6_SERIE   := SD2->D2_SERIE
         SB6->B6_EMISSAO := SD2->D2_EMISSAO
         SB6->B6_QUANT   := SD2->D2_QUANT
         SB6->B6_PRUNIT  := SD2->D2_PRCVEN
         SB6->B6_TES     := SD2->D2_TES
         SB6->B6_TIPO    := "E"
         SB6->B6_CUSTO1  := SD2->D2_CUSTO1
         //SB6->B6_IDENT   :=
         SB6->B6_TPCF    := "C"
         SB6->B6_SALDO   := SD2->D2_QUANT  
         SB6->B6_PODER3  := "R"
         SB6->B6_ESTOQUE := "S"
         SB6->(MsUnlock()) 
            
         SB2->(DbSetOrder(1))                  
         If SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+SB6->B6_LOCAL )) 
            RecLock("SB2",.F.) 
            SB2->B2_QATU  := SB2->B2_QATU  - SD2->D2_QUANT   
			SB2->B2_VATU1 := SB2->B2_VATU1 - SD2->D2_CUSTO1    
			SB2->B2_CM1   := SB2->B2_VATU1 / SB2->B2_QATU  
            SB2->(MsUnlock())           
         Else 
            RecLock("SB2",.T.)  
            SB2->B2_FILIAL:= xFilial("SB2")
            SB2->B2_COD   := SD2->D2_COD
            SB2->B2_LOCAL := SB6->B6_LOCAL
            SB2->B2_CM1   := - ( SD2->D2_CUSTO1/SD2->D2_QUANT  )          
            SB2->B2_QATU  :=  - SD2->D2_QUANT 
            SB2->B2_VATU1 :=  - SD2->D2_CUSTO1             
            SB2->(MsUnlock())                
         EndIf
        
      EndIf
      
   SD2->(DbSkip()) 
   EndDo

EndIf

//AOA - 20/10/2017 - Novo tratamento de cobrança ID46
If cEmpAnt $ "HH/HJ"
	
	cBol := alltrim(SC5->C5_P_BOL) 
	
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xfilial("SE1")+SE1->E1_PREFIXO+SF2->F2_DOC)
	While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
		If RecLock("SE1",.F.) 
			Replace SE1->E1_P_BOL With cBol 
			msUnLock() 
		Endif 
		
		DbSkip() 		
	EndDo 

EndIf

//AOA - 07/05/2019 - Tratamento para gerar não gerar boleto para determinada condicao de pagamento (QN0001/2019)
If cEmpAnt $ "QN"
	If alltrim(SC5->C5_CONDPAG) $ SUPERGETMV("MV_P_00135",.F.,"")
	
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xfilial("SE1")+SE1->E1_PREFIXO+SF2->F2_DOC)
		While !Eof() .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO
			If SE1->(FieldPos("E1_P_BOL"))>0
				If RecLock("SE1",.F.) 
					Replace SE1->E1_P_BOL With "N" 
					msUnLock() 
				Endif  
			EndIf
			
			DbSkip() 		
		EndDo
		 
    EndIf
EndIf

If cEmpAnt $ "N6"
	
	//Query de consulta
	cSQL := "SELECT SE1.R_E_C_N_O_ AS 'RECNOSE1',ROUND((SAE.AE_TAXA*SE1.E1_VALOR/100),2) AS 'TAXADM',SC5.C5_NUM,C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_P_WLDPA, "
	cSQL += "C5_P_BAND,SC5.C5_P_TIPAG,SC5.C5_P_DTRAX FROM " + RetSqlName( 'SC5' ) + " SC5 "
	cSQL += "INNER JOIN " + RetSqlName('SE1' ) + " SE1 ON SE1.E1_PEDIDO = SC5.C5_NUM AND SE1.E1_CLIENTE = SC5.C5_CLIENTE AND SE1.E1_LOJA = SC5.C5_LOJACLI AND SE1.D_E_L_E_T_ = '' " 
	cSQL += "INNER JOIN " + RetSqlName('SAE' ) + " SAE ON SAE.AE_COD    = SC5.C5_P_BAND AND SAE.AE_TIPO    = SC5.C5_P_TIPAG " 
	cSQL += "WHERE C5_NOTA = '"+SF2->F2_DOC+"' AND C5_SERIE = '"+SF2->F2_SERIE+"' AND C5_CLIENTE = '"+SF2->F2_CLIENTE+"' "
	cSQL += "AND C5_LOJACLI = '"+SF2->F2_LOJA+"' AND C5_FILIAL = '"+xFilial("SC5")+"' "
		
	TCQuery cSQL ALIAS ( cAlias ) NEW  
		
	While ( cAlias )->( !Eof() ) 
			If !Empty(( cAlias )->C5_P_DTRAX)
					DO CASE
						CASE ( cAlias )->C5_P_BAND == "01" .and. ( cAlias )->C5_P_TIPAG == "CC"  //VISA CREDITO
							 cCod     := "01"
							 cCartao  := "Visa Credito"
						
						CASE ( cAlias )->C5_P_BAND == "02" .and. ( cAlias )->C5_P_TIPAG == "CC"  //MASTERCARD CREDITO
							 cCod     := "02"
							 cCartao  := "Mastercard Credito"
							 
						CASE ( cAlias )->C5_P_BAND == "03"
							 cCod     := "03" //ELO CREDITO
							 cCartao  := "ELO Credito"
						
						CASE ( cAlias )->C5_P_BAND == "01" .and. ( cAlias )->C5_P_TIPAG == "DC"  //VISA DEBITO
							 cCod     := "04"
							 cCartao  := "Visa Debito"
						
						CASE ( cAlias )->C5_P_BAND == "02" .and. ( cAlias )->C5_P_TIPAG == "DC"  //MASTERCARD DEBITO 
							 cCod     := "05"
							 cCartao  := "Mastercard Credito"    
					ENDCASE		
					
					cHist := "Datatrax:" + ( cAlias )->C5_P_DTRAX
						
					//Query de update	 
					cSQL := "UPDATE " + RetSqlName( 'SE1' ) + " SET E1_SDDECRE = '"+cvaltochar(( cAlias )->TAXADM)+"', E1_DECRESC = '"+cvaltochar(( cAlias )->TAXADM)+"', E1_ADM = '"+cCod+"', E1_P_BAND = '"+cCod+"', E1_P_DTRAX = '"+( cAlias )->C5_P_DTRAX+"' , E1_P_WLDPA = '"+( cAlias )->C5_P_WLDPA+"',E1_P_TIPAG = '"+( cAlias )->C5_P_TIPAG+"', "
					cSQL += "E1_HIST = '"+cHist+"' WHERE R_E_C_N_O_= '"+cvaltochar(( cAlias )->RECNOSE1)+"' "  
				
					//atualizo as informa??es
					TCSqlExec(cSQL)
			EndIf 
		   ( cAlias )->(dbSkip())   	 
	Enddo

	( cAlias )->( DbCloseArea() )

	//SE1->(RestArea(aAreaSE1))
		
EndIf

Return

//-----------------------------------------------------------------------------------------------------------------------------//
//--Wederson L. Santana - Pryor Technology - 14/07/05                                                                          //
//-----------------------------------------------------------------------------------------------------------------------------//
//--Especifico Intralox - Faturamento                                                                                          //
//-----------------------------------------------------------------------------------------------------------------------------//
//--Geração das OP´s dos pedidos de venda importados.                                                                          //
//-----------------------------------------------------------------------------------------------------------------------------//

Static Function fGeraOp()
Local lOk :=.F.
SB2->(DbSetOrder(1))
SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+"01"))

SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))

SC2->(DbSetOrder(1))
If! SC2->(DbSeek(xFilial("SC2")+SC6->C6_NUMOP+SC6->C6_ITEMOP+StrZero(Val(SC6->C6_ITEMOP),3)))
	SZA->(DbSetOrder(1))
	If SZA->(DbSeek(xFilial("SZA")+SC6->C6_NUMOP+SC6->C6_ITEMOP+StrZero(Val(SC6->C6_ITEMOP),3)))
		RecLock("SC2",.T.)
		SC2->C2_FILIAL  := xFilial("SC2")
		SC2->C2_NUM     := SZA->ZA_NUM
		SC2->C2_ITEM    := SZA->ZA_ITEM
		SC2->C2_SEQUEN  := SZA->ZA_SEQUEN
		SC2->C2_PRODUTO := SZA->ZA_PRODUTO
		SC2->C2_LOCAL   := SZA->ZA_LOCAL
		SC2->C2_QUANT   := SZA->ZA_QUANT
		SC2->C2_UM      := SZA->ZA_NUM
		SC2->C2_DATPRI  := dDataBase
		SC2->C2_DATPRF  := dDataBase
		SC2->C2_EMISSAO := dDataBase
		SC2->C2_PRIOR   := SZA->ZA_PRIOR
		SC2->C2_QUJE    := SZA->ZA_QUJE
		SC2->C2_DATRF   := dDataBase
		SC2->C2_APRATU1 := SB2->B2_CM1
		SC2->C2_APRFIM1 := SB2->B2_CM1
		MsUnlock()
		
		lOk:=.T.
		
		Reclock("SD2",.F.)
		SD2->D2_OP:= SZA->ZA_NUM+SZA->ZA_ITEM+SZA->ZA_SEQUEN
		MsUnlock()
	Endif
Endif
Return(lOk)

//-------------------------------------Cria movimento com os componentes da OP pai
// Wederson L. Santana - 29/12/04

Static Function fGeraMov()

_nTotalOp :=0

SZB->(DbSetOrder(1))
If SZB->(DbSeek(xFilial("SZB")+SZA->ZA_NUM+SZA->ZA_ITEM+SZA->ZA_SEQUEN))
	While SZA->ZA_NUM+SZA->ZA_ITEM+SZA->ZA_SEQUEN == SZB->ZB_OP
		If! AllTrim(SZB->ZB_PARCTOT) $ "T"
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SZB->ZB_COD+"01"))
			RecLock("SD3",.T.)
			D3_FILIAL := xFilial("SD3")
			D3_TM     := SZB->ZB_P_TM
			D3_COD    := SZB->ZB_COD
			D3_UM     := SZB->ZB_UM
			D3_QUANT  := SZB->ZB_QUANT
			D3_CF     := SZB->ZB_CF
			D3_CONTA  := SZB->ZB_CONTA
			D3_OP     := SZB->ZB_OP
			D3_LOCAL  := SZB->ZB_LOCAL
			D3_DOC    := SZB->ZB_DOC
			D3_EMISSAO:= dDataBase
			D3_GRUPO  := SZB->ZB_GRUPO
			D3_TIPO   := SZB->ZB_TIPO
			D3_PARCTOT:= ""
			D3_CUSTO1 := SB2->B2_CM1*SZB->ZB_QUANT
			D3_NUMSEQ := ProxNum()
			_nTotalOp  += D3_CUSTO1
		Endif
		SZB->(DbSkip())
	End
	
	SZB->(DbSetOrder(1))
	If SZB->(DbSeek(xFilial("SZB")+SZA->ZA_NUM+SZA->ZA_ITEM+SZA->ZA_SEQUEN))
		While SZA->ZA_NUM+SZA->ZA_ITEM+SZA->ZA_SEQUEN == SZB->ZB_OP
			If AllTrim(SZB->ZB_PARCTOT) $ "T"
				SB2->(DbSetOrder(1))
				SB2->(DbSeek(xFilial("SB2")+SZB->ZB_COD+"01"))
				RecLock("SD3",.T.)
				SD3->D3_FILIAL := xFILIAL("SD3")
				SD3->D3_TM     :=	SZB->ZB_P_TM
				SD3->D3_COD    :=	SZB->ZB_COD
				SD3->D3_UM     :=	SZB->ZB_UM
				SD3->D3_QUANT  :=	SZB->ZB_QUANT
				SD3->D3_CF     :=	SZB->ZB_CF
				SD3->D3_CONTA  :=	SZB->ZB_CONTA
				SD3->D3_OP     :=	SZB->ZB_OP
				SD3->D3_LOCAL  :=	SZB->ZB_LOCAL
				SD3->D3_DOC    :=	SZB->ZB_DOC
				SD3->D3_EMISSAO:=	dDataBase                                  		
				SD3->D3_GRUPO  :=	SZB->ZB_GRUPO
				SD3->D3_TIPO   :=	SZB->ZB_TIPO
				SD3->D3_PARCTOT:=	SZB->ZB_PARCTOT
				SD3->D3_CUSTO1 :=	_nTotalOp                       //Soma do custo dos componentes da OP pai
				SD3->D3_NUMSEQ := ProxNum()
				MsUnlock()
			EndIf
			SZB->(DbSkip())
		End
	Endif
Endif


Return
