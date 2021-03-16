#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : FFNFAT03
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Nota Fiscal Sumitomo - Entrada e Saída 
Autor     	: José Augusto	
Data     	: 19/06/2007
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.
*/

*-------------------------*
 User Function NFFFAT03()
*-------------------------*

SetPrvt("_cDaNota,_cAtNota,_cSerie,_cTpMov,nPos,_cCanDuplo")
DbSelectArea("SM0")

If cEmpAnt $ "FF"
	If Pergunte("NFFF01    ",.T.)
		_cDaNota   := Mv_Par01
		_cAtNota   := Mv_Par02
		_cSerie    := Mv_Par03
		_cTpMov    := Mv_Par04
		_cCanDuplo := Mv_Par05
		fOkProc()
	Endif
Else
	MsgInfo("Especifico Sumitomo ","A T E N C A O")
Endif

Return

//------------------------------------------------------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

tamanho  :='G'
limite   :=220
titulo   :="Nota Fiscal - Entrada / Saida - Sumitomo"
cDesc1   :=' '
cDesc2   :=''
cDesc3   :='Impressao em formulario de 220 colunas.'
aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
lImprAnt := .F.
aLinha   := { }
nLastKey := 0
imprime  := .T.
cString  := 'SQL'
nLin     := 60
m_pag    := 1
aOrd     := {}
wnRel    := NomeProg := 'NFFFAT03'
cTipo    := ""

wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)

If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
	Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27
	Return
Endif

If _cTpMov == 1
	fGerSf1()
	RptStatus({|| fImpSF1()},"Nota de Entrada - Sumitomo")
Else
	fGerSf2()
	RptStatus({|| fImpSF2()},"Nota de Saida - Sumitomo")
Endif

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(wnrel)
Endif

Ms_Flush()

Return

//---------------------------------------------------- Emite Nota Fiscal de Entrada

Static Function fImpSF1()

DbSelectArea("SQL")
DbGoTop()
SetRegua(RecCount())
//Do While.Not.Eof() .and. AllTrim(cTipo)<> "C"
Do While.Not.Eof()
	
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+SQL->D1_TES))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SQL->F1_FORNECE+SQL->F1_LOJA))
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
	SA4->(DbSetOrder(1))
	SA4->(DbSeek(xFilial("SA4")+SQL->F1_TRANSP))
	
	SE2->(DbSetOrder(1))
	SE2->(DbSeek(xFilial("SE1")+SQL->F1_PREFIXO+SQL->F1_DUPL))
	
	//cMensTes := Formula(SF4->F4_FORMULA)
	SM4->(DbSetOrder(1))
	If SM4->(dbSeek(xFilial() + SF4->F4_FORMULA))
		cMensTes:=SM4->M4_FORMULA
	EndIf
	cNota    := F1_DOC
	cEmissao := F1_EMISSAO
	nValMerc := F1_VALMERC
	nValIpi  := F1_VALIPI
	nValIcm  := F1_VALICM
	nBaseIcm := F1_BASEICM
	nValBrut := F1_VALBRUT
	nDespesa := F1_DESPESA
	nFrete   := F1_FRETE
	nBrIcms  := F1_BRICMS
	nIcmsRet := F1_ICMSRET
	nSeguro  := F1_SEGURO
	cTipo    := F1_TIPO
	cCompara := F1_DOC+F1_SERIE
	nBsIcmRet:= F1_BRICMS
	nIcmsRet := F1_ICMSRET
	//cDadosA  := F1_DADOSA
	cPbruto  := F1_PBRUTO//F1_P_PESOB
	cPliquid := F1_PLIQUI//F1_PESOL
	cVolume  := F1_VOLUME1//F1_P_VOLUM
	cEspecie := F1_ESPECI1//F1_P_ESPV
	cOBS		:= ""
	cOBS2    := ""
	cSQLNF   := ""
	cSQLSR   := ""
	xTES     := {}
	aMensTes := {}
	cMensTes := ""
	cCfop    := ""
	cText		:= ""
	cMenNota := ""
	xMEN_TRIB:={}
	xCLAS_FIS:={}
	aValpag :={}
	aDatpag :={}
	
	//FATURA
	If! Empty(SQL->F1_PREFIXO+SQL->F1_DUPL)
		Do While.Not.Eof().And.SQL->F1_PREFIXO+SQL->F1_DUPL == SE2->E2_PREFIXO+SE2->E2_NUM
			Aadd(aValPag,{ transform(SE2->E2_VALOR,"@E 9,999,999.99")})
			Aadd(aDatPag,{ Dtoc(SE2->E2_VENCREA)})
			SE2->(DbSkip())
		EndDo
	Endif
	
	SD1->(DbSetOrder(1))
	IF SD1->(DbSeek(xFilial("SD1")+SQL->F1_DOC+SQL->F1_SERIE))
		Do While.Not.Eof().And.SQL->F1_DOC + SQL->F1_SERIE == SD1->D1_DOC + SD1->D1_SERIE
			If SD1->D1_ITEM == "0001"
				If !Empty(SQL->D1_OBS) .or. !Empty(SQL->D1_P_OBS2)
					cOBS += SQL->D1_OBS
					cOBS2+= SQL->D1_P_OBS2
					cMenNota:= cOBS+cOBS2
				Endif
			Endif
			SD1->(DbSkip())
		EndDo
	ENDIF
	
	//FR
	//Verifica os TES que existem na nf (seleção distinta)
	cSQLNF := SQL->D1_DOC
	cSQLSR := SQL->D1_SERIE
	xTES := fCallTESD1(cSQLNF,cSQLSR)
	If len(xTES) > 0
		For nt:= 1 to len(xTES)
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))
			If !Empty(SF4->F4_FORMULA)
				Aadd(aMensTes,SF4->F4_FORMULA)
			Endif
			If Empty(cText)
				cText := ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Else
				cText += ALLTRIM(SF4->F4_TEXTO)
				cText += "/"
			Endif
		Next
	Endif
	//Verifica os CFOPs correspondentes (distintos)
	xCFOP := fCallCFOPD1(cSQLNF,cSQLSR)
	If len(xCFOP) > 0
		For f:= 1 to len(xCFOP)
			cCfop += xCFOP[f] + "/"
		Next
	Endif
	
	//FR
	
	fCabSf1()
	nLin     :=28
	
	If  AllTrim(cTipo)= "N" .OR. AllTrim(cTipo)= "B" .OR. AllTrim(cTipo)= "D"
		While SQL->F1_DOC + SQL->F1_SERIE == cCompara
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SQL->D1_COD))
			SB5->(DbSetOrder(1))
			SB5->(DbSeek(xFilial("SB5")+SQL->D1_COD))
			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
				AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
			Endif
			@ nLin,001 pSay SB1->B1_COD                                      //Código Produto
			If LEN(SB1->B1_DESC) > 60
				@ nLin,015 pSay SUBSTR(SB1->B1_DESC,1,60)                        //Descrição Produto
				nLin+=1
				@ nLin,015 pSay SUBSTR(SB1->B1_DESC,61,60)                       //Descrição Produto
			Else
				@ nLin,015 pSay SB1->B1_DESC                                     //Descrição Produto
			EndIf
			
			@ nLin,086 pSay SB1->B1_POSIPI			                          //Classificação Fiscal
			@ nLin,105 pSay SQL->D1_CLASFIS		Picture "999"                //Situação Tributária
			@ nLin,112 pSay SB1->B1_UM				Picture "@!"                 //Unidade
			@ nLin,119 pSay SQL->D1_QUANT			Picture "@E 999,999.99"      //Quantidade
			@ nLin,135 pSay SQL->D1_VUNIT 		Picture "@E 999,999.999999"  //Preco Bruto
			//@ nLin,150 pSay D1_VUNIT		      Picture "@E@Z 9,999,999.99"     //Vlr Unitário
			@ nLin,165 pSay SQL->D1_TOTAL		   Picture "@E 9,999,999.99"    //Vlr Total
			@ nLin,192 pSay SQL->D1_PICM			Picture "99"              	  //% ICMS
			@ nLin,201 pSay SQL->D1_IPI			Picture "99"              	  //% IPI
			@ nLin,210 pSay SQL->D1_VALIPI		Picture "@E 99,999.99"       //Vlr IPI
			
			
			If !Empty(SQL->D1_LOTECTL)
				nLin +=1
				@ nLin,015 pSay " Lote: " + SQL->D1_LOTECTL
			EndIf
			nLin++
			If nLin > 51
				@ 54,013 PSAY "CONTINUA ..."
				
				@ 067,000 pSay Chr(18)
				If _cCanDuplo == 1
					@ 067,055 pSay cNota
				EndIf
				@ 067,125 pSay cNota
				@ 072,000 pSay ""
				SetPrc(0,0)
				
				fCabSf1()
				nLin	:=	28
			Endif
			
			
			//EndDo
			
			
			
			IncRegua(SQL->F1_SERIE +" "+ SQL->F1_DOC)
			DbSelectarea("SQL")
			SQL->(DbSkip())
			
		Enddo
		// CALCULO DO IMPOSTO
		@ 54,013  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
		@ 54,043  PSAY nVALICM	       Picture "@E 999,999,999.99"  // Valor do ICMS
		@ 54,075  PSAY nBsIcmRet	   Picture  "@E 999,999,999.99"  // Base ICMS Ret.
		@ 54,100  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
		@ 54,137  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
		@ 56,013  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
		@ 56,043  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
		@ 56,100  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
		@ 56,137  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
		
		
		@ 059,001 pSay SA4->A4_NOME
		@ 059,099 PSay "2"                                            //Tipo de frete definido como 2 a pedido do Cliente.
		@ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
		@ 061,001 pSay SA4->A4_END
		@ 061,075 pSay SA4->A4_MUN
		@ 061,118 pSay SA4->A4_EST
		
		If AllTrim(SA4->A4_INSEST) == "ISENTO"
			@ 061,125 pSay "ISENTO"
		Else
			@ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
		Endif
		
		@ 063,003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
		@ 063,017 PSAY cEspecie    Picture "@!"                        // Especie
		@ 063,055 PSAY " "                                             // Res para Marca
		@ 063,080 PSAY " "                                             // Res para Numero
		@ 063,124 PSAY cPbruto     Picture "@E 999,999.9999"           // Peso Bruto
		@ 063,143 PSAY cPliquid    Picture "@E 999,999.9999"
		
		@ 067,000 pSay Chr(18)
		If _cCanDuplo == 1
			@ 067,055 pSay cNota
		EndIf
		@ 067,125 pSay cNota
		@ 072,000 pSay " "
		SetPrc(0,0)
		
	ElseIf AllTrim(cTipo)= "C"
		@ nLin,017 pSay "Complemento de Importacao"
		@ nLin,165 pSay nVALBRUT  Picture "@E 999,999,999.99"   //Vlr Total
		// CALCULO DO IMPOSTO
		@ 54,013  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
		@ 54,043  PSAY nVALICM	       Picture "@E 999,999,999.99"  // Valor do ICMS
		@ 54,075  PSAY nBsIcmRet	   Picture  "@E 999,999,999.99"  // Base ICMS Ret.
		@ 54,100  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
		@ 54,137  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
		@ 56,013  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
		@ 56,043  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
		@ 56,100  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
		@ 56,137  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
		
		//Transportadora
		@ 059,001 pSay SA4->A4_NOME
		@ 059,099 PSay "2"                                            //Tipo de frete definido como 2 a pedido do Cliente.
		@ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
		@ 061,001 pSay SA4->A4_END
		@ 061,075 pSay SA4->A4_MUN
		@ 061,118 pSay SA4->A4_EST
		If AllTrim(SA4->A4_INSEST) == "ISENTO"
			@ 061,125 pSay "ISENTO"
		Else
			@ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
		Endif
		
		@ 63, 003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
		@ 63, 017 PSAY cEspecie    Picture "@!"                        // Especie
		@ 63, 055 PSAY " "                                             // Res para Marca
		@ 63, 080 PSAY " "                                             // Res para Numero
		@ 63, 124 PSAY cPbruto     Picture "@E 999,999.9999"           // Peso Bruto
		@ 63, 143 PSAY cPliquid    Picture "@E 999,999.9999"
		
		@ 067,000 pSay Chr(18)
		If _cCanDuplo == 1
			@ 067,055 pSay cNota
		EndIf
		@ 067,125 pSay cNota
		@ 072,000 pSay " "
		SetPrc(0,0)
		
		cCompara := SQL->F1_DOC + SQL->F1_SERIE
		IncRegua(SQL->F1_SERIE +" "+ SQL->F1_DOC)
		
		DbSelectarea("SQL")
		SQL->(DbSkip())
		If SQL->F1_DOC + SQL->F1_SERIE = cCompara
			While SQL->F1_DOC + SQL->F1_SERIE == cCompara
				SQL->(DbSkip())
			Enddo
		Endif
		
	Endif
EndDo
Return

//----------------------------------------------------------- Emite cabeçalho da nfe.

Static Function fCabSf1()
Local nNumLinhas
Local nLinhaCorrente:= 1
Local nTamanhoLinha := 60
Local nLc := 1
Local cConPagDesc:= ""
Local cMensTes := ""
//Local cOBS := ""
//Local cOBS2:= ""

@ 000,000 PSAY Chr(15)

//FR
If len(aMensTes) > 0
	For ms:=1 to len(aMensTes)
		DbSelectArea("SM4")
		SM4->(DbSetOrder(1))
		SM4->(DbSeek(xFilial("SM4")+aMensTes[ms]))
		//cMensTes += Alltrim(Formula(aMensTes[ms]))
		cMensTes += SM4->M4_FORMULA
		cMensTes += " / "
	Next
Endif



If !Empty(cOBS) .or. !Empty(cOBS2)
	
	For nLinhaCorrente:= 1 To 15
		
		//@ nLc,002 PSAY SUBSTR(cOBS,1,70)
		If Alltrim(cTipo) != "B" .and. Alltrim(cTipo) != "D"
			If nLc = 1
				@ 001,002 PSAY SUBSTR(cOBS,1,70)
				@ 001,190 pSay "X"
				@ 001,215 pSay cNota
			ElseIf nLc = 2
				@ 002,002 pSay SUBSTR(cOBS,71,70)
			ElseIf nLc = 3
				@ 003,002 pSay SUBSTR(cOBS,141,70)
			ElseIf nLc = 4
				@ 004,002 pSay SUBSTR(cOBS,211,70)
			ElseIf nLc = 5
				@ 005,002 pSay SUBSTR(cOBS,281,70)
				If (xFilial("SF1") = '03')
					@ 005,082 pSay "NOVO ENDERECO: ALAMEDA BOM PASTOR, 91 - SALA C"
				Endif
			ElseIf nLc = 6
				@ 006,002 pSay SUBSTR(cOBS,351,70)
			ElseIf nLc = 7
				@ 007,002 pSay SUBSTR(cOBS,421,70)
				@ 007,082 pSay cText
				@ 007,126 pSay cCfop
			ElseIf nLc = 8
				@ 008,002 pSay SUBSTR(cOBS,491,10)
				@ 008,012 pSay SUBSTR(cOBS2,1,58)
			ElseIf nLc = 9
				@ 009,002 pSay SUBSTR(cOBS2,59,70)
			ElseIf nLc = 10
				@ 010,002 pSay SUBSTR(cOBS2,129,70)
				@ 010,082 pSay Alltrim(SA2->A2_NOME)
				If Len(AllTrim(SA2->A2_CGC)) == 14
					@ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
				ElseIf Len(AllTrim(SA2->A2_CGC)) == 11
					@ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
				Else
					@ 010,170 pSay SA2->A2_CGC
				Endif
				@ 010,212 pSay Dtoc(cEMISSAO)
			ElseIf nLc = 11
				@ 011,002 pSay SUBSTR(cOBS2,199,70)
			ElseIf nLc = 12
				@ 012,002 pSay SUBSTR(cOBS2,269,71)
				@ 012,082 pSay Alltrim(SA2->A2_END)
				@ 012,150 pSay SA2->A2_BAIRRO
				@ 012,190 pSay Alltrim(SA2->A2_CEP)   Picture "@R 99.999-999"
				//ElseIf nLc = 13
				//@ 013,002 pSay SUBSTR(cOBS2,281,59)
			ElseIf nLc = 14
				@ 014,002 pSay SUBSTR(cMensTes,1,70)
				@ 014,082 pSay Alltrim(SA2->A2_MUN)
				@ 014,125 pSay Alltrim(SA2->A2_DDD)   Picture "@R (99)"
				@ 014,130 pSay Alltrim(SA2->A2_TEL)   Picture "@R 9999-9999"
				@ 014,160 pSay Alltrim(SA2->A2_EST)
				If AllTrim(SA2->A2_INSCR) == "ISENTO"
					@ 014,180 pSay "ISENTO"
				Else
					@ 014,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
				Endif
			Elseif nLc = 15
				@ 015,002 pSay SUBSTR(cMensTes,71,70)
			Elseif nLc = 16
				@ 016,002 pSay SUBSTR(cMensTes,141,70)
			Elseif nLc = 17
				@ 017,002 pSay SUBSTR(cMensTes,211,70)
				If len(aValPag) > 0
					For pg:=1 to len(aValPag)
						If pg = 1
							@017,115 pSay aValPag[pg]
							@017,135 pSay aDatPag[pg]
						Elseif pg = 2
							@017,165 pSay aValPag[pg]
							@017,185 pSay aDatPag[pg]
						ElseIf pg = 3
							@018,002 pSay SUBSTR(cMensTes,281,70)
							@018,115 pSay aValPag[pg]
							@018,135 pSay aDatPag[pg]
						Elseif pg = 4
							@018,165 pSay aValPag[pg]
							@018,185 pSay aDatPag[pg]
						Endif
					Next
				Else
					@018,002 pSay SUBSTR(cMensTes,281,70)
				Endif
			Elseif nLc = 19
				@019,002 pSay SUBSTR(cMensTes,351,70)
			Elseif nLc = 20
				@020,002 pSay SUBSTR(cMensTes,421,70)
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+SQL->F1_COND))
				If !Empty(SE4->E4_DESCRI)
					cConPagDesc := SE4->E4_DESCRI
					@ 020,095 pSay cConPagDesc picture "@!"
				Endif
			EndIf
			nLc ++
		Else
			If nLc = 1
				@ 001,002 PSAY SUBSTR(cOBS,1,70)
				@ 001,190 pSay "X"
				@ 001,215 pSay cNota
			Elseif nLc = 2
				@ 002,002 pSay SUBSTR(cOBS,71,70)
			ElseIf nLc = 3
				@ 003,002 pSay SUBSTR(cOBS,141,70)
			ElseIf nLc = 4
				@ 004,002 pSay SUBSTR(cOBS,211,70)
			ElseIf nLc = 5
				@ 005,002 pSay SUBSTR(cOBS,281,70)
			ElseIf nLc = 6
				@ 006,002 pSay SUBSTR(cOBS,351,70)
			ElseIf nLc = 7
				@ 007,002 pSay SUBSTR(cOBS,421,70)
				@ 007,082 pSay cText
				@ 007,126 pSay cCfop
			Elseif nLc = 8
				@ 008,002 pSay SUBSTR(cOBS,491,10)
				@ 008,012 pSay SUBSTR(cOBS2,1,58)
			ElseIf nLc = 9
				@ 009,002 pSay SUBSTR(cOBS2,59,70)
			ElseIf nLc = 10
				@ 010,002 pSay SUBSTR(cOBS2,129,70)
				@ 010,082 pSay Alltrim(SA1->A1_NOME)
				If Len(AllTrim(SA1->A1_CGC)) == 14
					@ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
				ElseIf Len(AllTrim(SA1->A1_CGC)) == 11
					@ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
				Else
					@ 010,170 pSay SA1->A1_CGC
				Endif
				@ 010,212 pSay Dtoc(cEMISSAO)
			ElseIf nLc = 11
				@ 011,002 pSay SUBSTR(cOBS2,199,70)
			ElseIf nLc = 12
				@ 012,002 pSay SUBSTR(cOBS2,269,71)
				@ 012,082 pSay Alltrim(SA1->A1_END)
				@ 012,150 pSay SA1->A1_BAIRRO
				@ 012,190 pSay Alltrim(SA1->A1_CEP)   Picture "@R 99.999-999"
			ElseIf nLc = 14
				@ 014,002 pSay SUBSTR(cMensTes,1,70)
				@ 014,082 pSay Alltrim(SA1->A1_MUN)
				@ 014,125 pSay Alltrim(SA1->A1_DDD)   Picture "@R (99)"
				@ 014,130 pSay Alltrim(SA1->A1_TEL)   Picture "@R 9999-9999"
				@ 014,160 pSay Alltrim(SA1->A1_EST)
				If AllTrim(SA1->A1_INSCR) == "ISENTO"
					@ 014,180 pSay "ISENTO"
				Else
					@ 014,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"
				Endif
			Elseif nLc = 15
				@ 015,002 pSay SUBSTR(cMensTes,71,70)
			Elseif nLc = 16
				@ 016,002 pSay SUBSTR(cMensTes,141,70)
			Elseif nLc = 17
				@ 017,002 pSay SUBSTR(cMensTes,211,70)
			Elseif nLc = 18
				@018,002 pSay SUBSTR(cMensTes,281,70)
			Elseif nLc = 19
				@019,002 pSay SUBSTR(cMensTes,351,70)
			Elseif nLc = 20
				@020,002 pSay SUBSTR(cMensTes,421,70)
			EndIf
			nLc ++
		Endif
	Next
ElseIf Alltrim(cTipo) != "B" .and. Alltrim(cTipo) != "D"
	
	@ 001,002 pSay SUBSTR(cMenNota,1,70)
	@ 001,190 pSay "X"
	@ 001,215 pSay cNota
	@ 002,002 pSay SUBSTR(cMenNota,71,70)
	@ 003,002 pSay SUBSTR(cMenNota,141,70)
	@ 004,002 pSay SUBSTR(cMenNota,211,70)
	@ 004,002 pSay SUBSTR(cMenNota,281,70)
	@ 007,082 pSay cText
	@ 007,126 pSay cCfop
	@ 010,082 pSay Alltrim(SA2->A2_NOME)
	If Len(AllTrim(SA2->A2_CGC)) == 14
		@ 010,170 pSay SA2->A2_CGC Picture "@R 99.999.999/9999-99"
	ElseIf Len(AllTrim(SA2->A2_CGC)) == 11
		@ 010,170 pSay SA2->A2_CGC Picture "@R 999.999.999-99"
	Else
		@ 010,170 pSay SA2->A2_CGC
	Endif
	@ 010,212 pSay Dtoc(cEMISSAO)
	@ 012,082 pSay Alltrim(SA2->A2_END)
	@ 012,150 pSay SA2->A2_BAIRRO
	@ 012,190 pSay Alltrim(SA2->A2_CEP)   Picture "@R 99.999-999"
	@ 014,082 pSay Alltrim(SA2->A2_MUN)
	@ 014,125 pSay Alltrim(SA2->A2_DDD)   Picture "@R (99)"
	@ 014,130 pSay Alltrim(SA2->A2_TEL)   Picture "@R 9999-9999"
	@ 014,160 pSay Alltrim(SA2->A2_EST)
	If AllTrim(SA2->A2_INSCR) == "ISENTO"
		@ 014,180 pSay "ISENTO"
	Else
		@ 014,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
	Endif
Else
	@ 001,190 pSay "X"
	@ 001,215 pSay cNota
	@ 007,082 pSay cText
	@ 007,126 pSay cCfop
	@ 010,082 pSay Alltrim(SA1->A1_NOME)
	If Len(AllTrim(SA1->A1_CGC)) == 14
		@ 010,170 pSay SA1->A1_CGC Picture "@R 99.999.999/9999-99"
	ElseIf Len(AllTrim(SA1->A1_CGC)) == 11
		@ 010,170 pSay SA1->A1_CGC Picture "@R 999.999.999-99"
	Else
		@ 010,170 pSay SA1->A1_CGC
	Endif
	@ 010,212 pSay Dtoc(cEMISSAO)
	@ 012,082 pSay Alltrim(SA1->A1_END)
	@ 012,150 pSay SA1->A1_BAIRRO
	@ 012,190 pSay Alltrim(SA1->A1_CEP)   Picture "@R 99.999-999"
	@ 014,082 pSay Alltrim(SA1->A1_MUN)
	@ 014,125 pSay Alltrim(SA1->A1_DDD)   Picture "@R (99)"
	@ 014,130 pSay Alltrim(SA1->A1_TEL)   Picture "@R 9999-9999"
	@ 014,160 pSay Alltrim(SA1->A1_EST)
	If AllTrim(SA1->A1_INSCR) == "ISENTO"
		@ 014,180 pSay "ISENTO"
	Else
		@ 014,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"
	Endif
Endif
/*
If !empty(cMensTes)
@ 018, 003 PSAY SUBSTR(cMensTes,1,40)
@ 019, 003 PSAY SUBSTR(cMensTes,41,40)
@ 020, 003 PSAY SUBSTR(cMensTes,81,40)
EndIf
*/
//FR

If Empty(aValPag)
	@ 020,095 pSay "LIVRE DE DEBITO"
ElseIf !Empty(SE4->E4_DESCRI)
	cConPagDesc := SE4->E4_DESCRI
	@ 020,095 pSay cConPagDesc picture "@!"
Endif

//FR



@ 21, 000 PSAY CHR(15)
@ 24, 000 PSAY CHR(18)
@ 25, 000 PSAY CHR(15)


Return

//----------------------------------------------------------- Emite nfs.
Static Function fImpSF2()
DbSelectArea("SQL")
DbGoTop()

//---Customização solicitada pela Sumitomo - Liberação de NF´s para emissão - documentação em \\rdmake\cliente\sumitomo\

//If Empty(SQL->F2_P_FLAG).And.!(__cUserId $ "000222/000236/000000/000119/000194/000486/000004")

If Empty(SQL->F2_P_FLAG).And.!(__cUserId $ "000266/000259/000126/000000/000254/000126/000257/000489/000503/000616")
	MsgInfo("Nota "+SQL->F2_SERIE+AllTrim(SQL->F2_DOC)+" nao liberada para emissao !","A T E N C A O")
ELse
	
	DbGoTop()
	Do While.Not.Eof()
		
		nBaseIcm := F2_BASEICM
		nValIcm  := F2_VALICM
		nValMerc := F2_VALMERC
		nIcmsRet := F2_ICMSRET
		nFrete   := F2_FRETE
		nSeguro  := F2_SEGURO
		nDespesa := F2_DESPESA
		nValIpi  := F2_VALIPI
		nValBrut := F2_VALBRUT
		cNota    := F2_DOC
		cEmissao := F2_EMISSAO
		nPbruto  := F2_PBRUTO
		nPliqui  := F2_PLIQUI
		nValIss  := F2_VALISS
		nBaseIss := F2_BASEISS
		nValCofi := F2_VALCOFI
		nValCsll := F2_VALCSLL
		nValPis  := F2_VALPIS
		nDescont := F2_DESCONT
		cTipo    := F2_TIPO
		cPbruto  := F2_PBRUTO
		cPliquid := F2_PLIQUI
		//cVolume  := SC5->C5_VOLUME1
		cEspecie := F2_ESPECI1
		nVlrIPI  := 0
		cCfop    := ""
		cMensTes := ""
		xMEN_TRIB :={}
		xCLAS_FIS :={}
		aMensTES  :={}
		nBsIcmRet :=0
		
		xCFOP:= {}
		cSQLNF  :=""
		cSQLSR  :=""
		
		
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+SQL->F2_CLIENTE+SQL->F2_LOJA))
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(xFilial("SA4")+SQL->F2_TRANSP))
		SC5->(dbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+SQL->D2_PEDIDO))
		cVolume  := SC5->C5_VOLUME1
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1")+SQL->F2_PREFIXO+SQL->F2_DUPL))
		SA3->(DbSetOrder(1))
		SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1))
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
		
		SD2->(DbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SQL->D2_DOC+SQL->D2_SERIE))
		
		//JAP - 28-06-07
		//cDadosR  := SC5->C5_DADOSR
		
		//cMensTes := Formula(SF4->F4_FORMULA)
		cMensTes := ""
		aVal :={}
		aVen :={}
		//FATURA
		If! Empty(SQL->F2_PREFIXO + SQL->F2_DUPL)
			Do While.Not.Eof().And.F2_PREFIXO+F2_DUPL == SE1->E1_PREFIXO+SE1->E1_NUM
				Aadd(aVal,{ transform(SE1->E1_VALOR,"@E 9,999,999.99")})
				Aadd(aVen,{ Dtoc(SE1->E1_VENCORI)})
				SE1->(DbSkip())
			EndDo
		Endif
		cText		:={}
		aMerc    :={}
		aServ    :={}
		nPerc		:={}
		ImpDupl	:= 0
		cCompara := SQL->F2_DOC + SQL->F2_SERIE
		
		//FR
		//Verifica os TES que existem na nf (seleção distinta)
		cSQLNF := SQL->D2_DOC
		cSQLSR := SQL->D2_SERIE
		xTES := fCallTES(cSQLNF,cSQLSR)
		If len(xTES) > 0
			For nt:= 1 to len(xTES)
				SF4->(DbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+ xTES[nt]))
				If !Empty(SF4->F4_FORMULA)
					Aadd(aMensTes,SF4->F4_FORMULA)
				Endif
				If Empty(cText)
					cText := ALLTRIM(SF4->F4_TEXTO)
					cText += "/"
				Else
					cText += ALLTRIM(SF4->F4_TEXTO)
					cText += "/"
				Endif
			Next
		Endif
		//Verifica os CFOPs correspondentes (distintos)
		xCFOP := fCallCFOP(cSQLNF,cSQLSR)
		If len(xCFOP) > 0
			For f:= 1 to len(xCFOP)
				cCfop += xCFOP[f] + "/"
			Next
		Endif
		//FR
		
		
		If len(aMensTes) > 0
			For ms:=1 to len(aMensTes)
				DbSelectArea("SM4")
				SM4->(DbSetOrder(1))
				SM4->(DbSeek(xFilial("SM4")+aMensTes[ms]))
				//cMensTes += Alltrim(Formula(aMensTes[ms]))
				cMensTes += SM4->M4_FORMULA
				cMensTes += " / "
			Next
		Endif
		
		cMensTes := Substr(cMensTes,1,Len(cMensTes)-3)
		
		While SQL->F2_DOC+SQL->F2_SERIE == cCompara
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
			SB5->(DbSetOrder(1))
			SB5->(DbSeek(xFilial("SB5")+SQL->D2_COD))
			SA7->(DbSetOrder(1))
			SA7->(DbSeek(xFilial("SA7")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->D2_COD))
			SF3->(DbSetOrder(4))
			SF3->(DbSeek(xFilial("SF3")+SA1->A1_COD+SA1->A1_LOJA+SQL->F2_DOC+SQL->F2_SERIE))
			
			If Ascan(xMEN_TRIB, SB1->B1_CLASFIS)==0
				AADD(xMEN_TRIB , ALLTRIM(SB1->B1_CLASFIS))
				AADD(xCLAS_FIS , ALLTRIM(SB1->B1_POSIPI))
			Endif
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SQL->D2_TES))
			SC6->(dbSetOrder(2))
			SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
			
			If AllTrim(SF4->F4_CF) $ "5949/5933" .and. SF4->F4_ISS $ "S"
				//Aadd(aServ,{AllTrim(SB1->B1_COD)," - "+AllTrim(SB1->B1_DESC),SB1->B1_UM,SQL->D2_QUANT,SQL->D2_PRCVEN,;
				//SQL->D2_TOTAL,SC6->C6_DESCRI})
				Aadd(aServ,{AllTrim(SQL->D2_COD),;    //01
				AllTrim(SC6->C6_DESCRI),;             //02
				SB1->B1_UM,;                          //03
				SQL->D2_QUANT,;                       //04
			    SQL->D2_PRCVEN,;                      //05  
				SQL->D2_TOTAL,;                       //06
				SQL->D2_PICM,;                        //07
				SQL->D2_DESCON,;                      //08
				SQL->D2_CLASFIS,;                     //09
     			SQL->D2_VALIMP6,;                     //10
				SQL->D2_VALIMP5	})                    //11
				
			Else
				Aadd(aMerc,{SB1->B1_COD,;  		  	 	//1
				AllTrim(SC6->C6_DESCRI),;               //2
				SB1->B1_POSIPI,;                        //3
				SQL->D2_CLASFIS,;                       //4
				SB1->B1_UM,;                            //5
				SQL->D2_QUANT,;                         //6
				SQL->D2_PRUNIT,;                        //7
				SQL->D2_PRCVEN,;                        //8
				SQL->D2_TOTAL,;                         //9
				SQL->D2_PICM,;                          //10
				SQL->D2_IPI,;                           //11
				SQL->D2_VALIPI,;                        //12
				SQL->D2_LOTECTL,;                       //13
				SQL->D2_DESCON,;                        //14
				SQL->D2_BASEICM,;                       //15
				SQL->D2_VALIMP6,;                       //16
				SQL->D2_VALIMP5	})                      //17				
			Endif
			
			nPosi := aScan(nPerc,{|_cCpo| _cCpo[1] == SQL->D2_PICM})
			
			If nPosi==0
				AADD(nPerc,{SQL->D2_PICM,SQL->D2_VALICM})
			ELSE
				nPerc[nposi,2]+=SQL->D2_VALICM
			endif
			
			
			If nIcmsRet > 0
				nBsIcmRet:=F3_VALOBSE
			Else
				nBsIcmRet:=0
			Endif
			
			//IncRegua(SQL->F2_SERIE+" "+SQL->F2_DOC)
			DBSELECTAREA("SQL")
			SQL->(DbSkip())
		Enddo
		
		
		
		ImpDupl	:= Len(aMerc)
		pTotal	:= (Len(aMerc)/30+0.47)
		pTotal	:= Round(pTotal,0)
		j			:= 1
		
		fCabSf2()
		
		
		nMerc :=1
		nServ :=1
		nLin  :=28
		nPos  :=1
		
		IF Alltrim(cTipo) = "I"
			@ nLin+3,017  PSAY "COMPLEMENTO DE I.C.M.S."
			@ nLin+3,165  PSAY nVALICM		  			  Picture "@E 99,999,999.99"
		ElseIf Alltrim(cTipo) = "P"
			@ nLin+3,017  PSAY "COMPLEMENTO DE I.P.I."
			@ nLin+3,115  PSAY aMerc[nMerc][10]		  Picture "99"
			@ nLin+3,210  PSAY nVALIPI		  			  Picture "@E 99,999,999.99"
		Else
			If Len(aServ) >0
				While nServ <= Len(aServ)
					@ nLin,001 pSay aServ[nServ][01]                              	//Código Produto
					@ nLin,015 pSay aServ[nServ][02]				                 //Descrição Produto  
					@ nLin,070 pSay aServ[nServ][10]				                 //Pis
     				@ nLin,080 pSay aServ[nServ][11]				                 //Cofins
					@ nLin,105 pSay aServ[nServ][09] Picture "999"                   //Situação Tributária
					@ nLin,112 pSay aServ[nServ][03]                                //Unidade
					@ nLin,119 pSay aServ[nServ][04] Picture "@E@Z 999,999.99"      //Quantidade
					@ nLin,135 pSay aServ[nServ][05] Picture "@E@Z 9,999,999.9999"		//Vlr Unitário
					@ nLin,165 pSay aServ[nServ][06]+ aServ[nServ][08] Picture "@E@Z 9,999,999.99"     	//Vlr Total
					@ nLin,192 pSay aServ[nServ][07] Picture "99"               	  					//% ICMS
					nServ++
					nLin++
					If nLin > 51
						@ 065,000 pSay Chr(18)      &&67
						@ 065,055 pSay cNota
						@ 065,125 pSay cNota
						@ 072,000 pSay " "
						SetPrc(0,0)
						fCabSf2()
						nLin	:=	30
					Endif
				Enddo
			Else
				While nMerc <= Len(aMerc)
					@ nLin,001 pSay aMerc[nMerc][01]                              	     //Código Produto
					IF LEN(aMerc[nMerc][02]) > 60
						@ nLin,015 pSay SUBSTR(aMerc[nMerc][02],1,60)                   //Descrição Produto
						nLin+=1
						@ nLin,015 pSay SUBSTR(aMerc[nMerc][02],61,60)                  //Descrição Produto
					ELSE
						@ nLin,015 pSay aMerc[nMerc][02]                                //Descrição Produto
					ENDIF
					@ nLin,070 pSay aMerc[nMerc][16]				                 //Pis
     				@ nLin,080 pSay aMerc[nMerc][17]				                 //Cofins
					@ nLin,090 pSay aMerc[nMerc][03]			                     //Classificação Fiscal
					@ nLin,105 pSay aMerc[nMerc][04] Picture "999"                   //Situação Tributária
					@ nLin,112 pSay aMerc[nMerc][05]                                 //Unidade
					@ nLin,115 pSay aMerc[nMerc][06] Picture "@E@Z 999,999.99"       //Quantidade
					//@ nLin,135 pSay aMerc[nMerc][07] Picture "@E@Z 999,999.99"     //Preco Bruto
					@ nLin,132 pSay ((aMerc[nMerc][08] * aMerc[nMerc][06]) + aMerc[nMerc][14]) / (aMerc[nMerc][06]) Picture "@E@Z 9,999,999.999999"     //Vlr Unitário
					@ nLin,150 pSay aMerc[nMerc][09] + aMerc[nMerc][14] Picture "@E@Z 9,999,999.99"     //Vlr Total
					@ nLin,168 pSay aMerc[nMerc][15] Picture "@E@Z 9,999,999.99"     //Base ICMS
					@ nLin,192 pSay aMerc[nMerc][10] Picture "99"               	  //% ICMS
					@ nLin,201 pSay aMerc[nMerc][11] Picture "99"               	  //% IPI
					@ nLin,208 pSay aMerc[nMerc][12] Picture "@E 99,999.99"          //Vlr IPI
					If !Empty(aMerc[nMerc][13])
						nLin +=1
						If !Empty(aMerc[nMerc][14])
							@nLin,015 pSay " Lote: " + aMerc[nMerc][13] + "/ Com Desconto"
							@nLin,165 pSay aMerc[nMerc][14] * (-1) Picture "@E@Z 9,999,999.99"
						Else
							@nLin,015 pSay " Lote: " + aMerc[nMerc][13]
						EndIf
					ElseIf !Empty(aMerc[nMerc][14])
						@nLin,015 pSay "Com Desconto"
						@nLin,165 pSay aMerc[nMerc][14] * (-1) Picture "@E@Z 9,999,999.99"
					EndIf
					nLin  +=1
					ImpDupl -= 1
					If nLin > 51
						@ 065,000 pSay Chr(18)      &&67
						@ 065,055 pSay cNota
						@ 065,125 pSay cNota
						@ 072,000 pSay " "
						SetPrc(0,0)
						fCabSf2()
						nLin	:=	30
					Endif
					nMerc +=1
				EndDO
			Endif
		Endif
		
		// Cálculo do Imposto
		If cTipo $"I"
			@ 54, 043  PSAY nVALICM		   Picture "@E 999,999,999.99"  // Valor do ICMS
		ElseIf cTipo == "P"
			@ 54, 013  PSAY nBASEICM       Picture "@E 999,999,999.99"  // Base do ICMS
			@ 54, 043  PSAY nVALICM        Picture "@E 999,999,999.99"  // Valor do ICMS
			@ 56, 137  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
		Else
			@ 54,013  PSAY nBASEICM        Picture "@E 999,999,999.99"  // Base do ICMS
			@ 54,043  PSAY nVALICM		   Picture "@E 999,999,999.99"  // Valor do ICMS
			@ 54,075  PSAY nBsIcmRet	   Picture "@E 999,999,999.99"  // Base ICMS Ret.
			@ 54,100  PSAY nIcmsRet        Picture "@E 999,999,999.99"  // Valor  ICMS Ret.
			@ 54,137  PSAY nVALMERC        Picture "@E 999,999,999.99"  // Valor Tot. Prod.
			@ 56,013  PSAY nFRETE          Picture "@E 999,999,999.99"  // Valor do Frete
			@ 56,043  PSAY nSEGURO         Picture "@E 999,999,999.99"  // Valor Seguro
			@ 56,100  PSAY nVALIPI	       Picture "@E 999,999,999.99"  // Valor do IPI
			@ 56,137  PSAY nVALBRUT        Picture "@E 999,999,999.99"  // Valor Total NF
		EndIf
		
		//Transportadora
		@ 059,001 pSay SA4->A4_NOME
		If (SC5->C5_TPFRETE  == "C") // .OR. (Alltrim(SC5->C5_TPFRETE) == "")
			@ 059,098 PSay "0"
		ElseIf SC5->C5_TPFRETE == "F"
			@ 059,098 PSay "1"
		Endif
		@ 059,125 pSay SA4->A4_CGC    Picture "@R 99.999.999/9999-99"
		@ 061,001 pSay SA4->A4_END
		@ 061,075 pSay SA4->A4_MUN
		@ 061,113 pSay SA4->A4_EST
		If AllTrim(SA4->A4_INSEST) == "ISENTO"
			@ 061,125 pSay "ISENTO"
		Else
			@ 061,125 pSay SA4->A4_INSEST Picture "@R 999.999.999.999"
		Endif
		
		@ 63, 003 PSAY cVolume     Picture "@E 999,999.99"             // Quant. Volumes
		@ 63, 017 PSAY cEspecie    Picture "@!"                        // Especie
		@ 63, 055 PSAY " "                                             // Res para Marca
		@ 63, 080 PSAY " "                                             // Res para Numero
		@ 63, 124 PSAY cPbruto     Picture "@E 999,999.9999"           // Res para Peso Bruto
		@ 63, 143 PSAY cPliquid    Picture "@E 999,999.9999"
		
		@ 067,000 pSay Chr(18)
		If _cCanDuplo == 1
			@ 067,055 pSay Alltrim(cNota)
		EndIf
		@ 067,125 pSay Alltrim(cNota)
		@ 072,000 pSay " "
		SetPrc(0,0)
		
		If! __cUserId $ "000266/000259/000126/000000/000257/000489/000503"
			cQuery :=""
			cQuery := "UPDATE SF2FF0 SET F2_P_FLAG = '2' "+Chr(10)
			cQuery += " WHERE F2_FILIAL = '"+xFilial("SF2")+"' "+Chr(10)
			cQuery += "AND F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
			cQuery += " F2_SERIE = '"+alltrim(_cSerie)+"' AND D_E_L_E_T_ <> '*'"
			TcSqlExec(cQuery)
		Endif
		
	EndDo
	
Endif

Return

//-----------------------------------------------------------Emite cabeçalho da nfs.

Static Function fCabSf2()
Local nNumLinhas
Local nLinhaCorrente
Local nTamanhoLinha := 60
Local nLc := 1
Local cEndCobFat := ""
Local cDesConPag := ""
Local cNome:= ""

@ 001, 001 PSAY Chr(15)

@ 001,002 pSay SUBSTR(SC5->C5_MENNOTA,1,70)
@ 001,178 pSay "X"
@ 001,215 pSay cNota
@ 002,002 pSay SUBSTR(SC5->C5_MENNOTA,71,70)
@ 003,002 pSay SUBSTR(SC5->C5_MENNOTA,141,70)
@ 004,002 pSay SUBSTR(SC5->C5_MENNOTA,211,70)
@ 005,002 pSay SUBSTR(SC5->C5_MENNOTA,281,70)
If (xFilial("SF2") = '03')
	@ 005,082 pSay "NOVO ENDERECO: ALAMEDA BOM PASTOR, 91 - SALA C"
Endif
@ 006,002 pSay SUBSTR(SC5->C5_MENNOTA,351,70)
@ 007,002 pSay SUBSTR(SC5->C5_MENNOTA,421,70)
nI:=1 //adicionar uma linha, soma mais um no nI


@ 007+nI,002 pSay SUBSTR(SC5->C5_MENNOTA,491,21)+SUBSTR(SC5->C5_P_MSGNF,1,49) //alterado para atender o aumento do campo C5_MENNOTA
@ 007+nI,082 pSay cText
@ 007+nI,126 pSay cCfop
//@ 007+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,1,49)
@ 008+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,50,70)
@ 009+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,120,70)
@ 010+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,190,70)

/*
@ 007,082 pSay cText
@ 007,126 pSay cCfop
@ 008,002 pSay SUBSTR(SC5->C5_P_MSGNF,1,70)
@ 009,002 pSay SUBSTR(SC5->C5_P_MSGNF,71,70)
@ 010,002 pSay SUBSTR(SC5->C5_P_MSGNF,141,70)
*/
IF Alltrim(cTipo) $ "B/D"
	@ 010+nI,082 pSay Alltrim(SA2->A2_NOME)
	If Len(AllTrim(SA2->A2_CGC)) == 14
		@ 010+nI,170 pSay AllTrim(SA2->A2_CGC)Picture "@R 99.999.999/9999-99"
	ElseIf Len(AllTrim(SA2->A2_CGC)) == 11
		@ 010+nI,170 pSay AllTrim(SA2->A2_CGC) Picture "@R 999.999.999-99"
	Else
		@ 010+nI,170 pSay AllTrim(SA2->A2_CGC)
	Endif
	@ 010+nI,212 pSay Dtoc(cEMISSAO)
	
	//If !Empty(SUBSTR(SC5->C5_P_MSGNF,211,70))
//	@ 011+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,211,70) 
	@ 011+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,260,70)
	//EndIf
	
	//If !Empty(SUBSTR(SC5->C5_P_MSGNF,281,70))
//	@ 012+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,281,69)
	@ 012+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,330,20)
	//EndIf
	
	@ 012+nI,082 pSay SA2->A2_END
	@ 012+nI,150 pSay SA2->A2_BAIRRO
	@ 012+nI,190 pSay SA2->A2_CEP   Picture "@R 99.999-999"
	If !Empty(SC5->C5_P_ENDEN)
		@ 013+nI,003 pSay "END.REC:"
		@ 013+nI,011 pSay SUBSTR(SC5->C5_P_ENDEN,1,59)
		@ 014+nI,003 pSay SUBSTR(SC5->C5_P_ENDEN,60,60)
	Endif
	@ 014+nI,082 pSay SA2->A2_MUN
	@ 014+nI,125 pSay Alltrim(SA2->A2_DDD)   Picture "@R (99)"
	@ 014+nI,130 pSay Alltrim(SA2->A2_TEL)   Picture "@R 9999-9999"
	@ 014+nI,160 pSay SA2->A2_EST
	If AllTrim(SA2->A2_INSCR) == "ISENTO"
		@ 014+nI,180 pSay "ISENTO"
	Else
		@ 014+nI,180 pSay SA2->A2_INSCR Picture "@R 999.999.999.999"
	Endif
	
ELSE
	
	cNome:=Alltrim(SA1->A1_NOME)
	
	@ 010+nI,050 PSAY Chr(15)
	@ 010+nI,082 pSay Alltrim(cNome)
	
	
	If Len(AllTrim(SA1->A1_CGC)) == 14
		@ 010+nI,170 pSay Alltrim(SA1->A1_CGC) Picture "@R 99.999.999/9999-99"
	ElseIf Len(AllTrim(SA1->A1_CGC)) == 11
		@ 010+nI,170 pSay Alltrim(SA1->A1_CGC) Picture "@R 999.999.999-99"
	ElseIf Empty(Alltrim(SA1->A1_CGC))
		@ 010+nI,170 pSay "            "
	Else
		@ 010+nI,170 pSay Alltrim(SA1->A1_CGC)
	Endif
	@ 010+nI,212 pSay Dtoc(cEMISSAO)
	
	//If !Empty(SUBSTR(SC5->C5_P_MSGNF,211,70))
//	@ 011+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,211,70)
	@ 011+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,260,70)
	//EndIf
	
	//If !Empty(SUBSTR(SC5->C5_P_MSGNF,281,70))
//	@ 012+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,281,69)
	@ 012+nI,002 pSay SUBSTR(SC5->C5_P_MSGNF,330,69)
	//EndIf
	
	
	cNome:=Alltrim(SA1->A1_END)
	
	@ 012+nI,082 pSay Alltrim(cNome)
	@ 012+nI,150 pSay SA1->A1_BAIRRO
	@ 012+nI,190 pSay SA1->A1_CEP   Picture "@R 99.999-999"
	If !Empty(SC5->C5_P_ENDEN)
		@ 013+nI,003 pSay "END.REC:"
		@ 013+nI,011 pSay SUBSTR(SC5->C5_P_ENDEN,1,59)  //ASK
		@ 014+nI,003 pSay SUBSTR(SC5->C5_P_ENDEN,60,60)
	Endif
	@ 014+nI,082 pSay SA1->A1_MUN
	@ 014+nI,125 pSay Alltrim(SA1->A1_DDD)   Picture "@R (99)"
	@ 014+nI,130 pSay Alltrim(SA1->A1_TEL)   Picture "@R 9999-9999"
	@ 014+nI,160 pSay SA1->A1_EST
	
	IF SA1->A1_TIPO == "L"
		@ 014+nI,180 pSay SA1->A1_INSCRUR
	Else
		If AllTrim(SA1->A1_INSCR) == "ISENTO"
			@ 014+nI,180 pSay "ISENTO"
		Else
			@ 014+nI,180 pSay SA1->A1_INSCR Picture "@R 999.999.999.999"
		Endif
	EndIf
	If !Empty(substr(cMensTes,1,70))
		@ 015+nI,003 PSAY SUBSTR(cMensTes,1,70)
	Endif
	If !Empty(substr(cMensTes,71,70))
		@ 016+nI,003 PSAY SUBSTR(cMensTes,71,70)
	Endif
	If !Empty(substr(cMensTes,141,70))
		@ 017+nI,003 PSAY SUBSTR(cMensTes,141,70)
	Endif
ENDIF
//Endif


//Imprime Fatura
IF ImpDupl <= 30
	nCol := 135
	nLin := 018
	If !Empty(aVen) .And. Len(aVen) <= 4
		For i:= 1 to Len(aVen)
			If i = 1
				@ 017+nI, 115           PSAY aVen[i][1]
				@ 017+nI, 135           PSAY aVal[i][1]
			ElseIf i = 2
				@ 017+nI, 165           PSAY aVen[i][1]
				@ 017+nI, 185           PSAY aVal[i][1]
			ElseIf i = 3
				@ 018+nI, 115           PSAY aVen[i][1]
				@ 018+nI, 135           PSAY aVal[i][1]
			ElseIf i = 4
				@ 018+nI, 165           PSAY aVen[i][1]
				@ 018+nI, 185           PSAY aVal[i][1]
			EndIf
		Next
		If !Empty(SE4->E4_DESCRI)
			cDesConPag := SE4->E4_DESCRI
		EndIf
		If !Empty(SA1->A1_ENDCOB)
			cEndCobFat := SA1->A1_ENDCOB
		EndIf
	Endif
EndIf

If ALLTRIM(SE4->E4_CODIGO) = '004'
	cDesConPag := SE4->E4_DESCRI
EndIf

If !Empty(substr(cMensTes,211,70))
	@ 018+nI,003 PSAY SUBSTR(cMensTes,211,70)
Endif
If !Empty(substr(cMensTes,281,70))
	@ 019+nI,003 PSAY SUBSTR(cMensTes,281,70)
Endif
If !Empty(substr(cMensTes,351,70))
	@ 020+nI,003 PSAY SUBSTR(cMensTes,351,70)
Endif
If !Empty(cDesConPag)
	@ 020+nI, 095 pSay AllTrim(cDesConPag)
EndIf
If !Empty(substr(cMensTes,421,70))
	@ 021+nI,003 PSAY SUBSTR(cMensTes,421,70)
Endif
If !Empty(substr(cMensTes,491,70))
	@ 022+nI,003 PSAY SUBSTR(cMensTes,491,70)
Endif
If !Empty(cEndCobFat)
	@ 022+nI, 095 pSay Alltrim(cEndCobFat)
EndIf
//IF !Empty(SA1->A1_ENDENT)
//   @ 023, 003 pSay "TESTE PARA IMPRESSÃO DE MENSAGEM PARA CLIENTE ENTREGA ARMAZEM!!!AAAAABBBBB"
// EndIf
Return

//-----------------------------------------------------------

Static Function fGerSf1()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF1 :={}
aStruSD1 :={}
aStruSF1:= SF1->(dbStruct())
aStruSD1:= SD1->(dbStruct())

cQuery := "SELECT SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_ITEM,SD1.D1_COD,SD1.D1_EMISSAO,SD1.D1_OBS,SD1.D1_P_OBS2,* "
cQuery += "FROM "+RetSqlName("SF1")+" SF1 , "+RetSqlName("SD1")+" SD1 WHERE "+Chr(10)
cQuery += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "+Chr(10)
cQuery += "SF1.F1_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
//cQuery += "SF1.F1_DOC >= '"+_cDaNota+"' AND SF1.F1_DOC <='"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF1.F1_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF1.F1_FORMUL = 'S' AND SD1.D1_FORMUL = 'S'"+Chr(10)
cQuery += " AND SF1.F1_DOC + SF1.F1_SERIE = SD1.D1_DOC + SD1.D1_SERIE AND "+Chr(10)
cQuery += "SF1.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF1.F1_DOC,SF1.F1_SERIE,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_ITEM"

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F1_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF1)
	If aStruSF1[nX,2]<>"C"
		TcSetField("SQL",aStruSF1[nX,1],aStruSF1[nX,2],aStruSF1[nX,3],aStruSF1[nX,4])
	EndIf
Next nX

For nX := 1 To Len(aStruSD1)
	If aStruSD1[nX,2]<>"C"
		TcSetField("SQL",aStruSD1[nX,1],aStruSD1[nX,2],aStruSD1[nX,3],aStruSD1[nX,4])
	EndIf
Next nX

cTMP := CriaTrab(NIL,.F.)
Copy To &cTMP
dbCloseArea()
dbUseArea(.T.,,cTMP,"SQL",.T.)

Return

//------------------------------------------------------------------

Static Function fGerSf2()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())

cQuery := "SELECT D2_DOC,D2_SERIE,D2_TES,D2_EST,D2_CF,F2_CLIENTE,F2_LOJA,F2_TRANSP,D2_PEDIDO,F2_PREFIXO,F2_DUPL,D2_COD,D2_ITEMPV,D2_PRCVEN,D2_TOTAL,D2_PICM,D2_VALICM,D2_BASEICM,D2_IPI,D2_VALIPI,D2_PRUNIT,D2_CLASFIS, "+Chr(10)+CHR(13)
cQuery += "D2_VALIMP5, D2_VALIMP6,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_DESCON,D2_PICM,D2_IPI,D2_VALIPI,D2_LOTECTL,F2_BASEICM,F2_VALICM,F2_VALMERC,F2_FRETE,F2_SEGURO,F2_DESPESA,F2_VALIPI,F2_VALBRUT,F2_DESCONT,"+Chr(10)+CHR(13)
cQuery += "F2_DOC,F2_SERIE,F2_EMISSAO,F2_PBRUTO,F2_PLIQUI,F2_VOLUME1,F2_ESPECI1,F2_VALISS,F2_BASEISS,F2_VALCOFI,F2_VALCSLL,F2_VALPIS,F2_DESCONT,F2_TIPO,F2_ICMSRET, F2_P_FLAG "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2 , "+RetSqlName("SD2")+" SD2 WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+_cDaNota+"' AND '"+_cAtNota+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+_cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_ITEM "

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F2_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF2)
	If aStruSF2[nX,2]<>"C"
		TcSetField("SQL",aStruSF2[nX,1],aStruSF2[nX,2],aStruSF2[nX,3],aStruSF2[nX,4])
	EndIf
Next nX

For nX := 1 To Len(aStruSD2)
	If aStruSD2[nX,2]<>"C"
		TcSetField("SQL",aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
	EndIf
Next nX

Return

/*-------------------------*/
Static Function fCallCFOPD1(cSQLNF,cSQLSR)
/*-------------------------*/
Local aCFOPdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPCF") > 0
	dbSelectArea("TEMPCF")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD1.D1_CF AS CFOPS"
cQryFR	+= " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"
cQryFR	+= " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
cQryFR   += " AND SD1.D1_DOC = '"+cNota+"'"
cQryFR   += " AND SD1.D1_SERIE = '"+cSerie+"'"
cQryFR   += " AND SD1.D1_FORMUL='S'
cQryFR	+= " AND SD1.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPCF"
dbSelectArea("TEMPCF")
dbGoTop()
While .not. eof()
	Aadd(aCFOPdif,TEMPCF->CFOPS)
	dbSelectArea("TEMPCF")
	TEMPCF->(Dbskip())
Enddo
TEMPCF->(DbCloseArea())

Return(aCFOPdif)

//****************************************************************************************
/*-------------------------*/
Static Function fCallCFOP(cSQLNF,cSQLSR)
/*-------------------------*/
Local aCFOPdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPCF") > 0
	dbSelectArea("TEMPCF")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD2.D2_CF AS CFOPS"
cQryFR	+= " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"
cQryFR	+= " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
cQryFR   += " AND SD2.D2_DOC = '"+cNota+"'"
cQryFR   += " AND SD2.D2_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD2.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPCF"
dbSelectArea("TEMPCF")
dbGoTop()
While .not. eof()
	Aadd(aCFOPdif,TEMPCF->CFOPS)
	dbSelectArea("TEMPCF")
	TEMPCF->(Dbskip())
Enddo
TEMPCF->(DbCloseArea())

Return(aCFOPdif)


//****************************************************************************************
/*-------------------------*/
Static Function fCallTES(cSQLNF,cSQLSR)
/*-------------------------*/
Local aTESdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPTES") > 0
	dbSelectArea("TEMPTES")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD2.D2_TES AS ITEMTES"
cQryFR	+= " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)"
cQryFR	+= " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
cQryFR   += " AND SD2.D2_DOC = '"+cNota+"'"
cQryFR   += " AND SD2.D2_SERIE = '"+cSerie+"'"
cQryFR	+= " AND SD2.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPTES"
dbSelectArea("TEMPTES")
dbGoTop()
While .not. eof()
	Aadd(aTESdif,TEMPTES->ITEMTES)
	dbSelectArea("TEMPTES")
	TEMPTES->(Dbskip())
Enddo
TEMPTES->(DbCloseArea())

Return(aTESdif)

/*-------------------------*/
Static Function fCallTESD1(cSQLNF,cSQLSR)
/*-------------------------*/
Local aTESdif:={}
Local cNota  := cSQLNF
Local cSerie := cSQLSR

If Select("TEMPTES") > 0
	dbSelectArea("TEMPTES")
	dbCloseArea()
EndIf
cQryFR	:= " SELECT DISTINCT SD1.D1_TES AS ITEMTES"
cQryFR	+= " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK)"
cQryFR	+= " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
cQryFR   += " AND SD1.D1_DOC = '"+cNota+"'"
cQryFR   += " AND SD1.D1_SERIE = '"+cSerie+"'"
cQryFR   += " AND SD1.D1_FORMUL='S'
cQryFR	+= " AND SD1.D_E_L_E_T_ <> '*'"

TCQUERY cQryFR NEW ALIAS "TEMPTES"
dbSelectArea("TEMPTES")
dbGoTop()
While .not. eof()
	Aadd(aTESdif,TEMPTES->ITEMTES)
	dbSelectArea("TEMPTES")
	TEMPTES->(Dbskip())
Enddo
TEMPTES->(DbCloseArea())

Return(aTESdif)



//-------------------------------------------------------------

Static Function CriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                        4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
//AADD(aRegistros,{cPerg,"01","Emissao de     		","","","mv_ch1","D",08,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
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

