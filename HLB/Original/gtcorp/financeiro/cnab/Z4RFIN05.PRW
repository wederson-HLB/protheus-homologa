#include "rwmake.ch"
#include "topconn.ch"  

//----------------------------------------------------------------------------------------------------------------//
// Eduardo C. Romanini  15/03/06                                                                                  //
// Pryor Technology							                                                                      //
//----------------------------------------------------------------------------------------------------------------//
// Especifico Pryor - Nota de Despesa sem boleto                                                                  //
//----------------------------------------------------------------------------------------------------------------//

User Function Z4RFIN05()

Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := "RFIN02    "
Private sBarra

If cEmpAnt $ "Z4/CH/Z8/Z6/ZP/ZB/RH/ZF/4C/4K/8F"  // Add Empresa 8F para solucionar o caso 029035
//	fCriaPerg()
	If Pergunte (cPerg,.T.)
		Processa({||FokImp()},"Boleto Banco Real")
	Endif
Else
	MsgInfo("Especifico Pryor Consulting ","A T E N C A O ")
Endif

Return

//-----------------------------------------

Static Function fOkImp()

Private nHeight    := 15
Private lBold      := .F.
Private lUnderLine := .F.
Private lPixel     := .T.
Private lPrint     := .F.
Private nPag       := 1
Private nTPag      := SE1 -> (FCount ())
Private nLin       := 0
Private oFont1     := TFont ():New ("Courier New", , 07, , .F., , , , , .f. )	// Nome do banco na 1a linha.
Private oFont2     := TFont ():New ("Courier New", , 14, , .t., , , , , .f. )
Private oFont3     := TFont ():New ("Courier New", , 16, , .t., , , , .t., .f. )
Private oFont4     := TFont ():New ("Courier New", , 10, , .t., , , , , .f. )
Private oFont5     := TFont ():New ("Courier New", , 09, , .F., , , , , .f. )	// Dados do campo "Instrucoes"
Private oFont6     := TFont ():New ("Courier New", , 11, , .t., , , , , .f. )	// Numeracao do Codigo de Barra no cabecalho do terceiro boleto da folha
Private oFont7     := TFont ():New ("Verdana", , 14, , .t., , , , , .f. )
Private oFont8     := TFont ():New ("Courier New", , 12, , .t., , , , , .f. )
Private oPrn       := TAvPrinter ():New ()
Private lContinua:= .T.


IF Alltrim(SM0->M0_CODIGO)=="CH" 
    cBanco     := "356"
    cAgencia   := "0853 "
    cConta     := "4725318-3 "
    cSubConta  := "000"
ElseIF Alltrim(SM0->M0_CODIGO)=="Z6" 
	cBanco    := "356"
	cAgencia  := "0853 "
	cConta    := "2728480-9 "                                                                   
	cSubConta := "001"
ElseIF Alltrim(SM0->M0_CODIGO)=="Z8" 
	cBanco    := "356"
	cAgencia  := "0853 "
	cConta    := "1728312-1 "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZP" 
	cBanco    := "356"
	cAgencia  := "0853 "
	cConta    := "5728470-1 "
	cSubConta := "001"		     
ElseIf Alltrim(SM0->M0_CODIGO)=="RH" 
	cBanco    := "356"
	cAgencia  := "0853 "
	cConta    := "1722082-1 "
	cSubConta := "001"		     
ElseIf Alltrim(SM0->M0_CODIGO)=="ZF" 
	cBanco    := "033"
	cAgencia  := "3853 "
	cConta    := "13005983-8"
	cSubConta := "001"		     
ElseIf Alltrim(SM0->M0_CODIGO)=="ZB" 
	cBanco    := "033"
	cAgencia  := "3853 "
	cConta    := "13005941-2"
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="4C"
	cBanco    := "033"
	cAgencia  := "3981 "
	cConta    := "130012594 "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO) $"8F"// Add Empresa 8F para solucionar o caso 029035
	cBanco    := "341"
	cAgencia  := "6381 "
	cConta    := "18753     "              
	cSubConta := "001"
ElseIf Alltrim(SM0->M0_CODFIL) $"01/03"
	cBanco    := "356"
	cAgencia  := "0853 "
	cConta    := "0.716016-4"              
	cSubConta := "001" 
Else
	cBanco    := "275"
	cAgencia  := "0853 "
	cConta    := "4.708549-3"
	cSubConta := "001"
EndIf

SEE->(dbSetOrder(1))
SEE->(dbGoTop())

NDigt  :=""
cNum	 :=""
If ! SEE->(dbSeek(xFilial("SEE")+AvKey(cBanco,"EE_CODIGO")+AvKey(cAgencia,"EE_AGENCIA")+AvKey(cConta,"EE_CONTA")+AvKey(cSubConta,"EE_SUBCTA"),.F.))
	MsgInfo ("Parametros do Banco/Agencia/Conta/Sub Conta nao encontrados." + Chr (13) + Chr (13) + "Por favor verifique.","A T E N C A O")
	Return
EndIf

DbSelectArea ("SEE")
SEE->(dbGoTop())
SEE->(dbSetOrder(1))
SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta,.T.))
cContaEmp:=SEE->EE_CODEMP
cDigCc   :=Right(AllTrim(SEE->EE_CODEMP),1)
cMoeda   :="9"	// Codigo da Moeda no Banco (sempre 9)
nCont    :=0

oPrn:Setup()

dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)
//While xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM <= SE1->E1_FILIAL+Mv_Par01+Mv_Par03
While xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO+SE1->E1_NUM <= Mv_Par01+Mv_Par03
	
	nValTot  :=0
	nValCf   :=0
	nValCs   :=0
	nValPi   :=0
	nValIr   :=0
	nValIn   :=0
	

	oPrn:StartPage ()
	nCont ++
	
	lOk:=.F.
	cNumTit:=SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
	While cNumTit == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
		If AllTrim(SE1->E1_TIPO) $ "CF-"
			nValCf += SE1->E1_VALOR
		Endif
		If AllTrim(SE1->E1_TIPO) $ "CS-"
			nValCs += SE1->E1_VALOR
		Endif
		If AllTrim(SE1->E1_TIPO) $ "PI-"
			nValPi += SE1->E1_VALOR
		Endif 
		If AllTrim(SE1->E1_TIPO) $ "NF"
			nValTot := SE1->E1_VALOR
			nValIr  := SE1->E1_IRRF
			nValIn  := SE1->E1_INSS
			nMulta  :=0
			If SE1->E1_PORCJUR <> 0
				nMora   :=SE1->E1_PORCJUR
			Else
				nMora   := 3
			EndIf
			nDescont:=(SE1->E1_VALOR*SE1->E1_DESCFIN)/100
			cFatVenc:=StrZero(SE1->E1_VENCREA - ctod ("07/10/1997"), 4)
			cTitulo :=SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
			dVencto :=SE1->E1_VENCREA
			dEmissao:=SE1->E1_EMISSAO
			
			_cNFiscal :=""
			_nDescont :=0
			_nValBrut :=0
			SF2->(dbSetOrder(1))
			SF2->(dbGoTop())
			If SF2->(dbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA), .F.))
				_cNFiscal := SF2->(F2_DOC+IIf(!Empty(SF2->F2_SERIE), "/" + F2_SERIE, ""))
				_nDescont := SF2->F2_DESCONT
				_nValBrut := SF2->F2_VALBRUT
			EndIf
			
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
			
			If Empty(SE1->E1_NUMBCO)
				RecLock("SE1",.F.)
				Replace SE1->E1_NUMBCO  		With SUBSTR(SEE->EE_FAXATU,1,7)
				Replace SE1->E1_PORTADO 		With cBanco
				Replace SE1->E1_AGEDEP  		With cAgencia
				Replace SE1->E1_CONTA  			With cConta
				
				SE1->(MsUnLock())
				RecLock("SEE",.F.)
				Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,7)
				SEE->(MsUnlock())
				cNumBco := SubStr(StrZero(Val(SE1->E1_NUMBCO),7),1,7)
			Else
				RecLock("SE1",.F.)
				SE1->(MsUnLock())
				cNumBco := SE1->E1_NUMBCO
			Endif
			lOk:=.T.
		Endif
		DbSelectArea("SE1")
		IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)
		DbSkip()
	End
	
	If lOk
		fImprime()
	Endif 
   	
End
oPrn:Preview ()
Ms_Flush ()
Return

//----------------------------------

Static Function fImprime()

_nValor := (nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)
//   nJuros  := Round (_nValor * (nMora/100), 2)
//nJuros  := Round( (_nValor/30)*(3/100),2)  //ASK 03/11/2008 - Alterado para 1% conforme solicitado por Cinthya 30373  
nJuros  := Round( (_nValor/30)*(1/100),2) 
nMultaMensal:= Round( (_nValor)*(2/100),2)  

// ********************************************************************************
// ******************** Inicio da Criacao do Codigo de Barras *********************
// ********************************************************************************
// Composicao do codigo de barras:
//
// 44 posicoes, sendo:
// 01 a 03	-	03	-	Código do Banco na Camara de Compensacao = "409"
// 04 a 04	-	01	-	Código da Moeda = "9"
// 05 a 05	-	01	-	DAC do Código de Barras (Módulo 11)
// 06 a 09	-	04	-	Fator de Vencimento
// 10 a 19	-	10	-	Valor - Picture 9(08)V(02)
// 20 a 21	-	02	-	Carteira
// 22 a 27	-	06	-	Data de vencimento (aammdd)
// 28 a 32	-	05	-	Codigo da agência + digito verificador
// 33 a 43	-	11	-	Nosso Numero
// 44 a 44 	-	01	-	Digito do Nosso Numero

cNumero  := cNumBco
cValor   := StrZero(100*(_nValor), 14)

//------------------------------------------- Digito Nosso Numero
Digitao()
//-------------------------------------------
cBanco:="356"
sBarra:= cBanco+cMoeda+cFatVenc+SUBSTR(cValor,5,14)+substr(cAgencia,1,4)+substr(cContaEmp,1,7)+AllTrim(STR(nDigT))+StrZero(val(cNumero),13)
//--------------------------------------------Digito Codigo Barras
cStrMult  := "4329876543298765432987654329876543298765432"
_nTam     :=Len(cStrMult)
_nBarra   :=Len(Alltrim(sBarra))
nBaseDiv  := 0
While _nBarra > 0
	nBaseDiv += Val(SubStr(Alltrim(sBarra),_nBarra,1)) * Val(SubStr(cStrMult,_nTam,1))
	_nTam   -=1
	_nBarra -=1
End
nResto  := nBaseDiv % 11		// Calcula Modulo 11
If nResto # 0
	cResto  := Alltrim (Str(11-nResto))
Else
	cResto:= "0"
Endif

If cResto == "0" .or. cResto == "10"
	cResto := "1"
EndIf

sBarra:= cBanco+cMoeda+cResto+cFatVenc+SUBSTR(cValor,5,14)+substr(cAgencia,1,4)+substr(cContaEmp,1,7)
sBarra+=AllTrim(STR(nDigT))+StrZero(val(cNumero),13)

//---------------------------------------------- Formacao da linha digitavel:

sDigit  :=""
sDigit1 :=cBanco+cMoeda+SUBSTR(cAgencia,1,4)+Alltrim(SUBSTR(cContaEmp,1,1))+Alltrim(CalcDig1())
sDigit  :=ALLTRIM(sDigit1)
sDigit2 :=substr(cContaEmp,2,6)+AllTrim(STR(nDigT))+"000"+Alltrim(CalcDig2())
sDigit  +=sDigit2
sDigit3 :=STRZERO(VAL(substr(cNumero,1,10)),10)+Alltrim(CalcDig3())
sDigit  +=sDigit3
sDigit4 :=Alltrim(cResto)+cFatVenc+SUBSTR(cValor,5,14)
sDigit  +=sDigit4
sDigit  :=Transform(sDigit, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")


cNossoNum:= SUBSTR(cNumero,1,7)+"-"+ALLTRIM(STR(nDigt))

oPrn:Say (080,900,"Nota de Débito",oFont7,0)
oPrn:SayBitmap (080,2050,"\REAL\BancoRealSantander.jpg", 220, 070)
oPrn:Say (140,10,"Recibo do Sacado",oFont2,0)
oPrn:Box (200,0,1900,2250)
oPrn:Say (205,0010,"Cedente", oFont1, 100)
oPrn:Say (205,0120,AllTrim(SM0->M0_NOMECOM), oFont4, 100)
oPrn:Say (245,0120,"CNPJ "+Transform(StrZero(Val(AllTrim(SM0->M0_CGC)),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Say (285,0120,AllTrim(SM0->M0_ENDCOB), oFont4, 100)
oPrn:Say (325,0120,Transform(AllTrim(SM0->M0_CEPCOB),"@R 99999-999")+"  "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB, oFont4, 100)
oPrn:Box (200,1060,380,1063)
oPrn:Say (205,1070,"Agência/Código Cedente", oFont1, 100)
oPrn:Say (250,1120,AllTrim(cAgencia)+"/"+ Left(cContaEmp,7)+"-"+cDigCc, oFont4, 100)
oPrn:Box (200,1460,380,1463)
oPrn:Say (205,1470,"Data do Documento", oFont1, 100)
oPrn:Say (250,1570,dtoc(dEmissao), oFont4, 100)
oPrn:Box (200,1860,380,1863)
oPrn:Say (205,1870,"Vencimento", oFont1, 100)
oPrn:Say (250,2060,dtoc(dVencto), oFont4, 100)
oPrn:Box (380,0,383,2250) // Linha Horizontal 1
//l,c,l2,c2

oPrn:Say (385,0010,"Sacado", oFont1, 100)
oPrn:Say (385,0120,AllTrim(SA1->A1_NOME), oFont4, 100)
oPrn:Say (425,0120,"CNPJ "+Transform(StrZero(Val(AllTrim(SA1->A1_CGC)),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Box (385,1060,535,1063)
oPrn:Say (385,1070,"Número do Documento", oFont1, 100)
oPrn:Say (445,1300,cTitulo, oFont4, 100)
oPrn:Box (385,1660,535,1663)
oPrn:Say (385,1670,"Nosso Número", oFont1, 100)
oPrn:Say (445,1800,Space(03)+AllTrim(cNumero), oFont4, 100)
oPrn:Box (535,0,538,2250) // Linha Horizontal 2

oPrn:Say (540,0010,"Espécie", oFont1, 100)
oPrn:Say (590,120,"FATURA", oFont4, 100)
oPrn:Box (540,300,675,303)
//oPrn:Say (540,310,"Quantidade", oFont1, 100)
//oPrn:Box (540,510,675,513)
oPrn:Say (540,310,"Valor", oFont1, 100) //540,520
oPrn:Say (590,310,"R$", oFont4, 100)    //590,540
oPrn:Box (540,1060,675,1063)
oPrn:Say (540,1070,"Valor do Documento", oFont1, 100)
oPrn:Say (590,1070,"R$", oFont4, 100)
oPrn:Say (590,1250,Transform (_nValor, "@E 999,999,999,999.99"), oFont4, 100)
oPrn:Box (540,1660,675,1663)
oPrn:Say (540,1670,"Descontos/Abatimentos", oFont1, 100)
//oPrn:Say (590,1800,Transform (_nDescont, "@E 999,999,999,999.99"), oFont4, 100)
oPrn:Box (675,0,678,2250) // Linha Horizontal 3
oPrn:Say (680,10,"Observação", oFont1, 100)

fBuscaItens(SubStr(cTitulo,1,3),SubStr(cTitulo,4,6))

SD2->(DbSetOrder(3))
SD2->(DbSeek(xFilial("SD2")+SSF2->F2_DOC+SSF2->F2_SERIE))
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))

oPrn:Say(720,0020,SubStr(AllTrim(SC5->C5_MENNOTA),1,115), oFont4, 100)

oPrn:Box (880,0010,1890,2240)
oPrn:Say (890,0020,"Resumo das Despesas", oFont8, 100)
oPrn:Say (950,0020,"Item       Descrição", oFont4, 100)
oPrn:Say (950,1930,"Valor Faturado", oFont4, 100)

nTotProd :=0
nImpostos:=0
nLinha   :=1010

//-------------------------------------------------------------------Itens
SD2->(DbSetOrder(3))
SD2->(DbSeek(xFilial("SD2")+SSF2->F2_DOC+SSF2->F2_SERIE))
While xFilial("SD2")+SSF2->F2_DOC+SSF2->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
	oPrn:Say(nLinha,0020,AllTrim(SD2->D2_COD)+"  -  "+AllTrim(SC6->C6_DESCRI)+" "+SubStr(SC6->C6_DESCRIC,1,50), oFont4, 100)
	oPrn:Say(nLinha,1930,Transform(SD2->D2_TOTAL+SD2->D2_DESCON,"@E 999,999,999.99"), oFont4, 100)
	nTotProd+=SD2->D2_TOTAL
	nLinha+=40
	SD2->(DbSkip())
EndDo
//oPrn:Say(nLinha,0020,"Total dos Serviços", oFont8, 100)
//oPrn:Say(nLinha,1882,Transform(nTotProd,"@E 999,999,999.99"), oFont8, 100)
nLinha+=40
If _nDescont>0
   nLinha+=20
   oPrn:Say(nLinha,0020,"Desconto Incondicional", oFont4, 100)
   oPrn:Say(nLinha,1930,Transform(_nDescont,"@E 999,999,999.99"), oFont4, 100)
   nLinha+=40
EndIf   
nImpostos:=nValCf+nValCs+nValPi+nValIr+nValIn
If nImpostos  > 0
	nLinha+=50
	oPrn:Say(nLinha,0020,"Impostos", oFont4, 100)
	nLinha+=40
	If nValCf > 0
		oPrn:Say(nLinha,0020,"Cofins 3,00%", oFont4, 100)
		//oPrn:Say(nLinha,0140,Transform((nValCf*100)/_nValBrut,"@E 999.99")+" %", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValCf,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValCs > 0
		oPrn:Say(nLinha,0020,"Csll 1,00%", oFont4, 100)
		//oPrn:Say(nLinha,0140,Transform((nValCs*100)/_nValBrut,"@E 999.99")+" %", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValCs,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValPi > 0
		oPrn:Say(nLinha,0020,"Pis 0,65%", oFont4, 100)
		//oPrn:Say(nLinha,0140,Transform((nValPi*100)/_nValBrut,"@E 999.99")+" %", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValPi,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValIr > 0
		oPrn:Say(nLinha,0020,"IR", oFont4, 100)
		oPrn:Say(nLinha,0140,Transform((nValIr*100)/_nValBrut,"@E 999.99")+" %", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValIr,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValIn > 0
		oPrn:Say(nLinha,0020,"INSS 11%", oFont4, 100)
		//oPrn:Say(nLinha,0140,Transform((nValIn*100)/_nValBrut,"@E 999.99")+" %", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValIn,"@E 999,999,999.99"), oFont4, 100)
   	nLinha+=40
	EndIf
	                                                              
	oPrn:Say(nLinha,0020,"Total Impostos", oFont8, 100)
	oPrn:Say(nLinha,1882,Transform(nImpostos,"@E 999,999,999.99"), oFont8, 100)
EndIf
nLinha+=100
oPrn:Say(nLinha,0020,"Total de Despesas", oFont8, 100)
oPrn:Say(nLinha,1882,Transform(nTotProd-nImpostos,"@E 999,999,999.99"), oFont8, 100)
nLinha+=400
oPrn:Say(nLinha,0020,"Obs: "+SC5->C5_OBS, oFont8, 100) 
//-------------------------------------------------------------------Fim itens
/*
oPrn:Say (1910,1930,"Autenticação Mecânica", oFont1, 100)

oPrn:Say (2000 , 0000, Replicate ("- ",79), oFont1, 100)

_nAjuste := 2100

oPrn:SayBitmap (0000 + _nAjuste,0010,"\REAL\BancoRealSantander.jpg", 220, 070)
oPrn:Box (0000 + _nAjuste,0600,0080 + _nAjuste,0603) // divisao  no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
oPrn:Say (0015 + _nAjuste,0650,"356-5",oFont7,100)
oPrn:Box (0000 + _nAjuste,0850,0080 + _nAjuste,0853) // divisao entre no. banco e texto "Recibo do Sacado"
oPrn:Say (0015 + _nAjuste,0870, sDigit, oFont6, 150)

oPrn:Box (0080 + _nAjuste,0000,0083 + _nAjuste,2250) // Linha Horizontal 1
oPrn:Say (0085 + _nAjuste,0010,"Local de Pagamento", oFont1, 100)
oPrn:Say (0085 + _nAjuste,0350,"ATÉ O VENCIMENTO PAGÁVEL EM QUALQUER BANCO", oFont4, 100)
oPrn:Say (0120 + _nAjuste,0350,"", oFont4, 100)
oPrn:Box (0080 + _nAjuste,1660,0160 + _nAjuste,1663) // Divisao entre "Loc. Pag." e "Venc."
oPrn:Say (0085 + _nAjuste,1670,"Vencimento",oFont1,100)
oPrn:Say (0120 + _nAjuste,2060,dtoc(dVencto), oFont4, 100)

oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
oPrn:Say (0165 + _nAjuste,0010,"Cedente", oFont1, 100)
oPrn:Say (0195 + _nAjuste,0010,AllTrim(SM0->M0_NOMECOM), oFont4, 100)
oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
oPrn:Say (0195 + _nAjuste,1670,"        " + AllTrim(cAgencia) + "/"+ Left(cContaEmp,7)+"-"+cDigCc, oFont4, 100)
oPrn:Box (0240 + _nAjuste,0000,0243 + _nAjuste,2250) // Linha Horizontal 3
oPrn:Say (0245 + _nAjuste,0010,"Data do Documento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0010,dtoc(dEmissao), oFont4, 100)
oPrn:Box (0240 + _nAjuste,0350,0320 + _nAjuste,0353) // Divisao entre "Data do Doc." e "No. Doc."
oPrn:Say (0245 + _nAjuste,0360,"Nº do Documento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0360,cTitulo, oFont4, 100)
oPrn:Box (0240 + _nAjuste,0770,0320 + _nAjuste,0773) // Divisao entre "No. Doc." e "Espec. Doc."
oPrn:Say (0245 + _nAjuste,0780,"Espécie Doc.", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0780,"RC", oFont4, 100)
oPrn:Box (0240 + _nAjuste,1060,0320 + _nAjuste,1063) // Divisao entre "Espec. Doc." e "Aceite"
oPrn:Say (0245 + _nAjuste,1070,"Aceite", oFont1, 100)
oPrn:Say (0275 + _nAjuste,1070,"N", oFont4, 100)
oPrn:Box (0240 + _nAjuste,1240,0320 + _nAjuste,1243) // Divisao entre "Aceite" e "Data Proc."
oPrn:Say (0245 + _nAjuste,1250,"Data do Processamento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,1250,dtoc (dDataBase), oFont4, 100)
oPrn:Box (0240 + _nAjuste,1660,0320 + _nAjuste,1663) // Divisao entre "Data Proc.." e "Cart./N.Num."
oPrn:Say (0245 + _nAjuste,1670,"Cart./Nosso Número",oFont1,100)
oPrn:Say (0275 + _nAjuste,1670,Space(03)+ALLTRIM(cNumero), oFont4, 100)

oPrn:Box (0320 + _nAjuste,0000,0323 + _nAjuste,2250) // Linha Horizontal 4
oPrn:Say (0325 + _nAjuste,0010,"Uso do Banco", oFont1, 100)
oPrn:Say (0360 + _nAjuste,0010,"Cliente", oFont4, 100)
oPrn:Box (0320 + _nAjuste,0350,0400 + _nAjuste,0353) // Divisao entre "Uso do Banco" e "Carteira"
oPrn:Say (0325 + _nAjuste,0360,"Carteira", oFont1, 100)
oPrn:Say (0360 + _nAjuste,0470,"20",oFont4, 100)
oPrn:Box (0320 + _nAjuste,0550,0400 + _nAjuste,0553) // Divisao entre "Carteira" e "Espécie Moeda"
oPrn:Say (0325 + _nAjuste,0560,"Espec. Moeda", oFont1, 100)
oPrn:Say (0360 + _nAjuste,0630,"R$", oFont4, 100)
oPrn:Box (0320 + _nAjuste,0770,0400 + _nAjuste,0773) // Divisao entre "Espeécie Moeda" e "Quantidade"
oPrn:Say (0325 + _nAjuste,0780,"Quantidade", oFont1, 100)
oPrn:Box (0320 + _nAjuste,1240,0400 + _nAjuste,1243) // Divisao entre "Quantidade" e "Valor"
oPrn:Say (0350 + _nAjuste,1100,"X", oFont4, 100)
oPrn:Say (0325 + _nAjuste,1250,"Valor", oFont1, 100)
oPrn:Box (0320 + _nAjuste,1660,0400 + _nAjuste,1663) // Divisao entre "Valor" e "Valor do Doc."
oPrn:Say (0325 + _nAjuste,1670,"(=) Valor do Documento",oFont1,100)
oPrn:Say (0355 + _nAjuste,1850,Transform (_nValor, "@E 999,999,999,999.99"), oFont4, 100)

oPrn:Box (0400 + _nAjuste,0000,0403 + _nAjuste,2250) // Linha Horizontal 5
oPrn:Say (0405 + _nAjuste,0010,"Instruções (Todas as informações deste bloqueto são de exclusiva responsabilidade do cedente)", oFont1, 100)

// *********************** Início das "Instrucoes" *********************
//If ! Empty (_cNFiscal)
//	oPrn:Say (0465 + _nAjuste,0010,"Nota Fiscal/Série", oFont5, 100)
//	oPrn:Say (0505 + _nAjuste,0010,_cNFiscal, oFont1, 100)
//EndIf
oPrn:Say (0555 + _nAjuste,0010, "APOS O VENCIMENTO COBRAR MULTA DE R$ "+Alltrim(Transform(nMultaMensal, "@E 99,999,999.99")) + " E MORA DIÁRIA DE R$ " + Alltrim(Transform(nJuros, "@E 99,999,999.99")), oFont5, 100)
//oPrn:Say (0585 + _nAjuste,0010, "APOS O VENCIMENTO COBRAR MORA DIÁRIA DE R$ "+Alltrim(Transform(nJuros, "@E 99,999,999.99")), oFont5, 100)
oPrn:Say (0755 + _nAjuste,0010, "Cliente do banco real: Pague atraves do disque real ou caixa rapido", oFont5, 100)

oPrn:Box (0400 + _nAjuste,1660,0800 + _nAjuste,1663) // Divisao Vertical entre as linhas 5 e 10
oPrn:Say (0405 + _nAjuste,1670,"(-) Desconto/Abatimento", oFont1, 100)
oPrn:Box (0480 + _nAjuste,1660,0483 + _nAjuste,2250) // Linha Horizontal 6

oPrn:Box (0560 + _nAjuste,1660,0563 + _nAjuste,2250) // Linha Horizontal 7
oPrn:Say (0565 + _nAjuste,1670,"(+) Mora/Multa", oFont1, 100)

oPrn:Box (0640 + _nAjuste,1660,0643 + _nAjuste,2250) // Linha Horizontal 8

oPrn:Box (0720 + _nAjuste,1660,0723 + _nAjuste,2250) // Linha Horizontal 9
oPrn:Say (0725 + _nAjuste,1670,"(=) Valor Cobrado", oFont1, 100)

oPrn:Box (0800 + _nAjuste,0000,0803 + _nAjuste,2250) // Linha Horizontal 10
oPrn:Say (0805 + _nAjuste,0010,"Sacado:", oFont1, 100)
oPrn:Say (0805 + _nAjuste,0260,SA1->(Alltrim (A1_NOME) + " - " + A1_COD + "/" + A1_LOJA), oFont4, 100)
oPrn:Say (0845 + _nAjuste,0260,SA1->(Alltrim (A1_END)+"-"+Alltrim(A1_BAIRRO)), oFont4, 100)
oPrn:Say (0885 + _nAjuste,0260,"Cep: "+SA1->(Transform (A1_CEP, "@R 99999-999"))+"  "+SA1->(Alltrim (A1_MUN)+" - "+AllTrim(A1_EST)), oFont4, 100)
oPrn:Say (0905 + _nAjuste,0010,"Sacador/Avalista", oFont1, 100) //945
oPrn:Say (0905 + _nAjuste,1700,"Código de Baixa ", oFont1, 100)
oPrn:Box (0940 + _nAjuste,0000,0943 + _nAjuste,2250) // Linha Horizontal 11 980
oPrn:Say (0945 + _nAjuste,1550,"Autenticação Mecânica - Ficha de Compensação", oFont1, 100)
If mv_par04 == 1
	MsBar("INT25", 27.5, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
ElseIF mv_par04 = 2.Or.Mv_Par04 = 3
	MsBar("INT25", 27.0, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
EndIf	
//ElseIF mv_par08 == 3
//	MsBar("INT25", 30.4, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
//EndIf

//-Parametros - Geracao Cod. Barras - Wederson 30/03/05
// 09 nWidth	Numero do Tamanho da barra em centimetros
// 10 nHeigth	Numero da Altura da barra em milimetros

oPrn:Say (1040 + _nAjuste, 0000, Replicate ("- ", 79), oFont1, 100) //1080
*/
nPag ++
oPrn:EndPage ()

Return

//------------------------------------------------------
// calculo digito bloco 1
//------------------------------------------------------
Static Function CalcDig1()

Local _nDigito, _cDigito
Local _cMult := "212121212"

nResto:= 0
nSoma1:=0
_nTam :=Len(_cMult)
nLinBlo:=cBanco+cMoeda+substr(cAgencia,1,4)+Alltrim(SUBSTR(cContaEmp,1,1))
_nBarra   :=Len(Alltrim(nLinBlo))

While _nBarra > 0
	nSoma:=0
	nSoma += Val(SubStr(Alltrim(nLinBlo),_nBarra,1)) * Val(SubStr(_cMult,_nTam,1))
	if nSoma > 9
		nSoma:= val(substr(STRZERO(nSoma),29,1))+val(substr(STRZERO(nSoma),30,1))
	endif
	nSoma1+=nSoma
	_nTam   -=1
	_nBarra -=1
End
nResto1:=nSoma1%10
nResto:=(10-nResto1)

If nResto = 10
	nDig1 := 0
Else
	nDig1:=nresto
Endif

Return (STR(nDig1))

//------------------------------------------------------------------------

Static Function CalcDig2()  //CALCULA DIGITO BLOCO 2

Local _nDigito, _cDigito
Local _cMult := "1212121212"

nSoma1	:=0
nResto1	:=0
nResto	:=0
_nTam :=Len(_cMult)
nLinBlo2:=substr(cContaEmp,2,6)+Alltrim(STR(nDigT))+"000"//substr(cNumero,1,3)
_nBarra   :=Len(Alltrim(nLinBlo2))


While _nBarra > 0
	nSoma:=0
	nSoma += Val(SubStr(Alltrim(nLinBlo2),_nBarra,1)) * Val(SubStr(_cMult,_nTam,1))
	if nSoma > 9
		nSoma:= val(substr(STRZERO(nSoma),29,1))+val(substr(STRZERO(nSoma),30,1))
	endif
	nSoma1+=nSoma
	_nTam   -=1
	_nBarra -=1
End

nResto1:=nSoma1%10
nResto:=(10-nResto1)

If nResto = 10
	nDig2 := 0
Else
	nDig2:=nresto
Endif

Return (STR(nDig2))

//---------------------------------------------------------------------------

Static Function CalcDig3()       //calcula digito do bloco 3

Local _nDigito, _cDigito
Local _cMult := "1212121212"
nSoma1	:=0
nResto1	:=0
nResto	:=0
_nTam :=Len(_cMult)
nLinBlo3:=StrZero(val(substr(cNumero,1,10)),10)
_nBarra   :=Len(Alltrim(nLinBlo3))

While _nBarra > 0
	nSoma:=0
	nSoma += Val(SubStr(Alltrim(nLinBlo3),_nBarra,1)) * Val(SubStr(_cMult,_nTam,1))
	if nSoma > 9
		nSoma:= val(substr(STRZERO(nSoma),29,1))+val(substr(STRZERO(nSoma),30,1))
	endif
	nSoma1+=nSoma
	_nTam   -=1
	_nBarra -=1
End

nResto1:=nSoma1%10
nResto:=(10-nResto1)

If nResto = 10
	nDig3 := 0
Else
	nDig3:=nresto
Endif

Return (STR(nDig3))

//----------------------------------------------------------------------------

Static Function Digitao()  //calcula o digitao da cobrança

_Digitao:=""
_nBarra:=0
_nTam:=0
_Digitao:=""
_nBarra:=0
_nTam:=0
chave := "121212121212121212121212"
nresto:=0
nResto1:=0
nsoma :=0
nsoma1:=0
nTot	:=0
_nTam :=Len(chave)
_Digitao:= StrZero(val(cNumero),13)+substr(cAgencia,1,4)+SUBSTR(cContaEmp,1,7)
_nBarra   :=Len(Alltrim(_Digitao))

While _nBarra > 0
	nSoma:=0
	nSoma += Val(SubStr(Alltrim(_Digitao),_nBarra,1)) * Val(SubStr(chave,_nTam,1))
	if nSoma > 9
		nSoma:= val(substr(STRZERO(nSoma),29,1))+val(substr(STRZERO(nSoma),30,1))
	endif
	nSoma1+=nSoma
	_nTam   -=1
	_nBarra -=1
End

nResto1:=nSoma1%10
nResto:=(10-nResto1)

If nResto = 10
	nDigT := 0
Else
	nDigT:=nresto
Endif

Return()

//--------------------------------------------

Static Function fCriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Prefixo        	","","","mv_ch1","C",03,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Do  Numero     	","","","mv_ch2","C",06,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Ate Numero      ","","","mv_ch3","C",06,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Banco   		   ","","","mv_ch4","C",03,00,00,"G","","Mv_Par04","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","",""})
AADD(aRegistros,{cPerg,"05","Agencia  		   ","","","mv_ch5","C",05,00,00,"G","","Mv_Par05","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Conta    		   ","","","mv_ch6","C",10,00,00,"G","","Mv_Par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","SubConta 		   ","","","mv_ch7","C",03,00,00,"G","","Mv_Par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"08","Impressora	   ","","","mv_ch8","N",01,00,00,"C","","Mv_Par08","Laser 1100","","","","","Laser 4200","","","","","","","","","","","","","","","","","","","","","",""})

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

//-------------------------------------------------

Static Function fBuscaItens(_cPrefixo,_cNumTit)

If Select("SSF2") > 0
	SSF2->(DbCloseArea())
EndIf

cQuery := "SELECT F2_SERIE,F2_DOC "+Chr(10)
cQuery += "FROM "+RetSqlName("SE1")+" SE1,"+RetSqlName("SF2")+" SF2 "+Chr(10)
cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"+Chr(10)
cQuery += "AND SE1.E1_PREFIXO+SE1.E1_NUM ='"+_cPrefixo+_cNumTit+"' "+Chr(10)
cQuery += "AND SE1.E1_TIPO='NF ' "
//AOA - 07/11/2017 - Alteração do select quando for ZB que tem financeiro compartilhado
If cEmpAnt $ "ZB/RH"
	cQuery += "AND SE1.E1_FILORIG+SE1.E1_PREFIXO+SE1.E1_NUM=SF2.F2_FILIAL+SF2.F2_PREFIXO+SF2.F2_DUPL "+Chr(10)
Else
	cQuery += "AND SE1.E1_FILIAL+SE1.E1_PREFIXO+SE1.E1_NUM=SF2.F2_FILIAL+SF2.F2_PREFIXO+SF2.F2_DUPL "+Chr(10)
EndIf
cQuery += "AND SE1.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "+Chr(10)

TCQuery cQuery ALIAS "SSF2" NEW


/*cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SSD2",.T.)*/

Return()
