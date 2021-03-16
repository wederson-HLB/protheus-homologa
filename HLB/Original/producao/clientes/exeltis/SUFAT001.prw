#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RelPedcDesº Autor ³ Infinit - João Vitorº Data ³  01/12/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório espelho pedido de venda com descontos em linha,  º±±
±±º          ³ que traz os 3 descontos aplicados.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Exeltis                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SUFAT001()	
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatorio de Pedido de Venda com Descontos"
	Local cPict          := ""
	Local titulo       := "Relatorio de Pedido de Venda com Descontos"
	Local nLin         := 80
	Local Cabec1       := "teste impressão"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Local cPerg := "RelPedcDes"
	Local _aPerg      := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 220
	Private tamanho          := "G"
	Private nomeprog         := "RelPedcDes" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString := ""
	
	
	aAdd(_aPerg,{"Do Documento?","C",9,0,"",})
	aAdd(_aPerg,{"Ate o Documento?","C",9,0,"",})
	aAdd(_aPerg,{"Do Cliente?","C",6,0,"SA1",})
	aAdd(_aPerg,{"Ate o Cliente?","C",6,0,"SA1",})
	/*	aAdd(_aPerg,{"Da Nota?","C",9,0,"",})
	aAdd(_aPerg,{"Ate a Nota?","C",9,0,"",})*/
	aAdd(_aPerg,{"Serie?","C",3,0,"",})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	INFPUTSX1(cPerg,_aPerg) // Programa para montar tela que ira buscar paramentros
	Pergunte(cPerg,.F.) 	//Chama a tela de parametros
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  01/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	
	Local nOrdem
	Local cQry	   := ""
	Local _pLin := chr(13)+ chr(10)
	Local cDeDoc := Alltrim(mv_par01)
	Local cAtDoc := Alltrim(mv_par02)
	Local cDeCli := Alltrim(mv_par03)
	Local cAteCli := Alltrim(mv_par04)
	Local cSerie := Alltrim(mv_par05)
	//	Local cDeNota:= Alltrim(mv_par05)
	//	Local cAteNota:= Alltrim(mv_par06)
	Local nDesc1 := 0
	Local nDesc2 := 0
	Local nDesc3 := 0
	Local nTotalB := 0
	Local nTotalL := 0
	Local cVal := ""
	Local nItem := 0
	
	
	//Select que monta pedido de venda vinculado a documento de saida
	cQry :=" SELECT C5_NUM,D2_DOC,F2_DOC,F2_SERIE,C5_CLIENT,A1_CGC,A1_NOME,A1_EST,C5_EMISSAO,C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_PRUNIT,C6_UM,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C6_TES, "+_pLin
	cQry +=" C6_XDESCO1,C6_VALDES1,C6_XDESCO2,C6_VALDES2,C6_DESCONT,C6_VALDESC "+_pLin
	cQry +=" FROM "+RetSqlName("SC5")+" C5 "+_pLin
	cQry +=" INNER JOIN "+RetSqlName("SC6")+" C6 ON C6.D_E_L_E_T_ != '*' AND C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "+_pLin
	cQry +=" INNER JOIN "+RetSqlName("SD2")+" D2 ON D2.D_E_L_E_T_ != '*' AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEM "+_pLin
	cQry +=" INNER JOIN "+RetSqlName("SF2")+" F2 ON F2.D_E_L_E_T_ != '*' AND C5_FILIAL = F2_FILIAL AND F2_DOC = D2_DOC "+_pLin
	//  cQry +=" INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.D_E_L_E_T_ != '*' AND A1_FILIAL = '"+xFilial()+"' AND C5_CLIENT = A1_COD "+_pLin
	cQry +=" INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.D_E_L_E_T_ != '*' AND C5_CLIENT = A1_COD "+_pLin
	cQry +=" WHERE C5.D_E_L_E_T_ !='*' "+_pLin
	cQry +=" AND C5_FILIAL = '"+xFilial("SC5")+"' "+_pLin
	cQry +=" AND D2_DOC BETWEEN '"+cDeDoc+"'AND '"+cAtDoc+"' "+_pLin
	cQry +=" AND C5_CLIENT BETWEEN '"+cDeCli+"'AND '"+cAteCli+"' "+_pLin
	//	cQry +=" AND F2_NFELETR BETWEEN '"+cDeNota+"'AND '"+cAteNota+"' "+_pLin
	cQry +=" AND F2_SERIE ='"+cSerie+"'"+_pLin
	cQry +=" ORDER BY C5_NUM,C6_ITEM"
	
	MemoWrit("c:\TEMP\RelPedcDes.sql",cQry)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry),"TMP", .F., .T.)
	
	TMP->(dbgotop())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SetRegua(TMP->(RecCount()))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
	//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
	//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
	//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
	//³                                                                     ³
	//³ dbSeek(xFilial())                                                   ³
	//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cVal := TMP->C5_NUM
	While !TMP->(EOF())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nLin > 55
			If cVal !=  TMP->C5_NUM // Salto de Página. Neste caso o formulario tem 55 linhas...
				nLin := 8
				Cabec1:= "Razão Social: "+Alltrim(TMP->A1_NOME)+" - CNPJ: "+TMP->A1_CGC+" - UF: "+TMP->A1_EST+" - NFe: "+Alltrim(TMP->F2_DOC);
					+" - N. Pedido: "+Alltrim(TMP->C5_NUM)
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				@nLin,00 PSAY "Item";@nLin,05 PSAY "Prduto";@nLin,37 PSAY "Uni";@nLin,42 PSAY "Preço Tab";@nLin,52 PSAY "Preço c/Desc"
				@nLin,67 PSAY "Qnt";@nLin,72 PSAY "%Desc Co";@nLin,83 PSAY "Valor Desc Co";@nLin,97 PSAY "%Desc OL";@nLin,109 PSAY "Valor Desc OL"
				@nLin,125 PSAY "%Repasse";@nLin,137 PSAY "Valor Repasse"; @nLin,152 PSAY "Total C/ Desconto"
				nLin ++
			ElseIf nLin = 80
				nLin := 8
				Cabec1:= "Razão Social: "+Alltrim(TMP->A1_NOME)+" - CNPJ: "+TMP->A1_CGC+" - UF: "+TMP->A1_EST+" - NFe: "+Alltrim(TMP->F2_DOC);
					+" - N. Pedido: "+Alltrim(TMP->C5_NUM)
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				@nLin,00 PSAY "Item";@nLin,05 PSAY "Prduto";@nLin,37 PSAY "Uni";@nLin,42 PSAY "Preço Tab";@nLin,52 PSAY "Preço c/Desc"
				@nLin,67 PSAY "Qnt";@nLin,72 PSAY "%Desc Co";@nLin,83 PSAY "Valor Desc Co";@nLin,97 PSAY "%Desc OL";@nLin,109 PSAY "Valor Desc OL"
				@nLin,125 PSAY "%Repasse";@nLin,137 PSAY "Valor Repasse"; @nLin,152 PSAY "Total C/ Desconto"
				nLin ++
			EndIf
		Endif
		
		
		nItem ++
		@nLin,00 PSAY nItem
		@nLin,05 PSAY Substr(TMP->C6_DESCRI,1,30)
		@nLin,37 PSAY TMP->C6_UM
		@nLin,40 PSAY TMP->C6_PRUNIT 	Picture "@E 999,999.99"
		@nLin,52 PSAY TMP->C6_PRCVEN 	Picture "@E 999,999.99"
		@nLin,67 PSAY TMP->C6_QTDVEN
		@nLin,75 PSAY TMP->C6_XDESCO1
		@nLin,80 PSAY TMP->C6_VALDES1 	Picture "@E 99,999,999.99"
		@nLin,100 PSAY TMP->C6_XDESCO2
		@nLin,108 PSAY TMP->C6_VALDES2 	Picture "@E 99,999,999.99"
		@nLin,127 PSAY TMP->C6_DESCONT
		@nLin,137 PSAY TMP->C6_VALDESC 	Picture "@E 99,999,999.99"
		@nLin,152 PSAY TMP->C6_VALOR 	Picture "@E 99,999,999.99"
		
		nDesc1 += TMP->C6_VALDES1
		nDesc2 += TMP->C6_VALDES2
		nDesc3 += TMP->C6_VALDESC
		nTotalB += TMP->C6_PRUNIT * TMP->C6_QTDVEN
		nTotalL += TMP->C6_VALOR
		nLin ++
		
		
		cVal := TMP->C5_NUM
		dbSkip()
		
		If 	cVal !=  TMP->C5_NUM
			@nLin,00 PSAY replicate("_",limite)
			nLin ++
			@nLin,00 PSAY "TOTAIS"
			nLin ++
			@nLin,00 PSAY replicate("_",limite)
			@nLin,45 PSAY "Valor Bruto";@nLin,90 PSAY "Desconto Co";@nLin,1115 PSAY "Desconto OL";@nLin,140 PSAY "Repasse";@nLin,155 PSAY "Valor Liquido"
			nLin ++
			@nLin,42 PSAY nTotalB Picture "@E 99,999,999.99";@nLin,87 PSAY nDesc1 Picture "@E 99,999,999.99";@nLin,112 PSAY nDesc2 Picture "@E 99,999,999.99"
			@nLin,137 PSAY nDesc3 Picture "@E 99,999,999.99";@nLin,152 PSAY nTotalL Picture "@E 99,999,999.99"
			nLin ++
			nItem := 0
			nDesc1 := 0
			nDesc2 := 0
			nDesc3 := 0
			nTotalB := 0
			nTotalL := 0
			nLin := 56
		EndIf
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	
	TMP->(dbclosearea())
Return




/*
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

*/


Static Function INFPUTSX1(_cGRP,_aPar)
	Local _I := 0
	Local _cSeq := "00"
	Local _cVrvl := "0"
	Local _lRec := .F.
	Local _cGSC := "G"
	_cGrp := Pad(_cGRP,Len(SX1->X1_GRUPO))
	SX1->(dbSetOrder(1))
	//Primeiro Cria ou Altera os registros
	For _I := 1 To Len(_aPar)
		_cSeq := Soma1(_cSeq)
		_cVrvl := Soma1(_cVrvl)
		_cGSC := "G"
		_lRec := !SX1->(dbSeek(_cGrp+_cSeq))
		RecLock("SX1",_lRec)
		SX1->X1_GRUPO		:= _cGrp
		SX1->X1_ORDEM		:= _cSeq
		SX1->X1_PERGUNT	:= _aPar[_I,01]
		SX1->X1_TIPO		:= _aPar[_I,02]
		SX1->X1_TAMANHO	:= _aPar[_I,03]
		SX1->X1_DECIMAL	:= _aPar[_I,04]
		SX1->X1_F3			:= _aPar[_I,05]
		If Len(_aPar[_I]) >= 6 .AND. _aPar[_I,6] <> Nil
			SX1->X1_DEF01		:= _aPar[_I,06,1]
			SX1->X1_DEF02		:= _aPar[_I,06,2]
			SX1->X1_DEF03		:= _aPar[_I,06,3]
			SX1->X1_DEF04		:= _aPar[_I,06,4]
			SX1->X1_DEF05		:= _aPar[_I,06,5]
			_cGSC := "C"
		Else
			SX1->X1_DEF01		:= ""
			SX1->X1_DEF02		:= ""
			SX1->X1_DEF03		:= ""
			SX1->X1_DEF04		:= ""
			SX1->X1_DEF05		:= ""
		EndIf
		If Len(_aPar[_I]) >= 7
			SX1->X1_VALID	:= _aPar[_I,07]
		EndIf
		SX1->X1_VAR01		:= ("MV_PAR"+_cSeq)
		SX1->X1_GSC		:= _cGSC
		SX1->X1_VARIAVL	:= ("MV_CH"+_cVrvl)
		SX1->(MsUnLock())
	Next _I
	
	SX1->(dbGoTop())
	If SX1->(dbSeek(_cGrp+"01"))
		While !SX1->(EOF()) .AND. SX1->X1_GRUPO == _cGrp
			If SX1->X1_ORDEM > _cSeq
				RecLock("SX1",_lRec)
				SX1->(dbDelete())
				SX1->(MsUnLock())
			EndIf
			SX1->(dbSkip())
		EndDo
	EndIf
	
Return
