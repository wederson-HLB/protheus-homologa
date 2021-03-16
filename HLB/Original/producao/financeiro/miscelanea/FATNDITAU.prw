#include "rwmake.ch"
#include "topconn.ch"

/*
Funcao      : FatNDItau
Parametros  : 
Retorno     : 
Objetivos   : Impressão da Fatura ND Banco Itau.
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/    

User Function FatNDItau()

LOCAL	aPergs 		:= {}
Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := "RFIN02    "
Private sBarra

cPerg     :="FATITAU   "

Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Aadd(aPergs,{"Banco","","","mv_ch4","C",3,0,0,"G","","MV_PAR04","","","","341","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
//Aadd(aPergs,{"Agencia","","","mv_ch5","C",5,0,0,"G","","MV_PAR05","","","","0190 ","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Aadd(aPergs,{"Conta","","","mv_ch6","C",10,0,0,"G","","MV_PAR06","","","","193805    ","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Aadd(aPergs,{"Sub-Conta","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","001","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("FATITAU   ",aPergs)

If Pergunte (cPerg,.T.)
	Processa({||FokImp()},"Fatura ND Banco Itau")
Endif


Return

//-----------------------------------------

Static Function fOkImp()
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aDadosEmp
LOCAL cNumBco:=""

LOCAL aBolText  := {"Após o vencimento cobrar multa de R$ ",;
					"Mora Diaria de R$ ",;
					"Sujeito a Protesto apos 05 (cinco) dias do vencimento"}

LOCAL CB_RN_NN  := {}

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
Private lContinua  := .T.
Private cBanco     := space(3)
Private cAgencia   := space(5)
Private cConta     := space(10)
Private cSubConta  := space(3)

If Alltrim(SM0->M0_CODIGO)=="ZB"    // AUDITORES
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193805    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZF"    // CORPORATE 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193821    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZG"    // ASSESSORIA 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193847    "
	cSubConta := "001"	          
ElseIf Alltrim(SM0->M0_CODIGO)=="99"    // AUDITORES
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "385609    "
 	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "0506"  // CONSULTING
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "385609    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "010203"  // BPO
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "414730    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="CH"    // TECNOLOGY 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "301994    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="RH"    // RH
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "309849    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z8"    // CONSULTORES 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "387985    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZP"    // GESTAO 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "296103    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="99"    // teste
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "385609    "
	cSubConta := "001"	
EndIf
                              
//cBanco    := Iif(Empty(cBanco),Mv_Par04,cBanco)
//cAgencia  := Iif(Empty(cAgencia),Mv_Par05,cAgencia)
//cConta    := Iif(Empty(cConta),Mv_Par06,cConta)
cSubConta := If(Empty(cSubConta),"001",cSubConta) 

If !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta)
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
	cMoeda   :="9"	// Codigo da Moeda no Banco (sempre 9)
	nCont    :=0
	
	DbSelectArea ("SA6")
	SA6->(dbGoTop())
	SA6->(dbSetOrder(1))
	SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta+cSubConta,.T.))
	
	
	oPrn:Setup()
	
	dbSelectArea ("SE1")
	DbGotop()
	ProcRegua(RecCount())
	DbSetOrder(1)
	DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)
	While xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == MV_PAR01 .AND. SE1->E1_NUM <= Mv_Par03
		
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
				nMulta  := 0
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
				cTipo:=SE1->E1_TIPO
				
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
					Replace SE1->E1_NUMBCO  		With SUBSTR(SEE->EE_FAXATU,1,8)
					Replace SE1->E1_PORTADO 		With cBanco
					Replace SE1->E1_AGEDEP  		With cAgencia
					Replace SE1->E1_CONTA  			With cConta
					
					SE1->(MsUnLock())
					RecLock("SEE",.F.)
					Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,8)
					SEE->(MsUnlock())
					cNumBco := SubStr(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
				Else
					RecLock("SE1",.F.)
					SE1->(MsUnLock())
					cNumBco := Alltrim(SE1->E1_NUMBCO)
				Endif
				lOk:=.T.
			Endif
			DbSelectArea("SE1")
			IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)
			DbSkip()
		End
		
		IF EMPTY(SA1->A1_ENDCOB)
			aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
			AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;						// [2]Codigo
			AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereco
			AllTrim(SA1->A1_MUN),;												// [4]Cidade
			SA1->A1_EST,;															// [5]Estado
			SA1->A1_CEP,;															// [6]CEP
			SA1->A1_CGC}															// [7]CGC
		ELSE
			aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;						// [2]Codigo
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereco
			AllTrim(SA1->A1_MUNC),;												// [4]Cidade
			SA1->A1_ESTC,;															// [5]Estado
			SA1->A1_CEPC,;															// [6]CEP
			SA1->A1_CGC}															// [7]CGC
		ENDIF
		
		aDadosEmp := {SM0->M0_NOMECOM,;																					//[1]Nome da Empresa
		SM0->M0_ENDCOB,; 																					//[2]Endereço
		AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
		"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 					//[4]CEP
		"PABX/FAX: "+SM0->M0_TEL,; 																		//[5]Telefones
		"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;				//[6]
		Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;								//[6]
		Subs(SM0->M0_CGC,13,2),;																		//[6]CGC
		"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;					//[7]
		Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}
		
		aDadosBanco := {SA6->A6_COD ,;												// SA6->A6_COD //[1]Numero do Banco
		"BANCO ITAU SA",;										     		// [2]Nome do Banco
		SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
		SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
		SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
		"109"}     													// [6]Codigo da Carteira
		
		//	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNumBco,((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)),dVencto)
		CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNumBco,((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)),dVencto)
		
		aDadosTit := {	AllTrim(substr(cTitulo,4)),;	// [1] Numero do Titulo
		dEmissao,;										// [2] Data da Emissao do Titulo
		Date(),;											// [3] Data da Emissao do Boleto
		dVencto,;										// [4] Data do Vencimento
		(nValTot-nValCf-nValCs-nValPi-nValIr-nValIn),;						// [5] Valor do Titulo
		CB_RN_NN[3],;									// [6] Nosso Numero (Ver Formula para Calculo)
		AllTrim(substr(cTitulo,1,3)),;										// [7] Prefixo da NF
		cTipo}											// [8] Tipo do Titulo
		
		/* ALTERADO */
		If lOk
			fImprime(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		Endif
	End
    oPrn:Preview ()
    Ms_Flush ()
Else
    MsgAlert("Banco/Agencia/Conta nao encontratos","Alerta")
Endif

Return

//----------------------------------

Static Function fImprime(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

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

oPrn:Say (080,900,"Nota de Débito",oFont7,0)
//oPrn:SayBitmap (080,2050,"\REAL\BancoRealSantander.jpg", 220, 070)
oPrn:Say (140,10,"Recibo do Sacado",oFont2,0)
oPrn:Box (200,0,1900,2250)
oPrn:Say (205,0010,"Cedente", oFont1, 100)
oPrn:Say (205,0120,AllTrim(SM0->M0_NOMECOM), oFont4, 100)
oPrn:Say (245,0120,"CNPJ "+Transform(StrZero(Val(AllTrim(SM0->M0_CGC)),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Say (285,0120,AllTrim(SM0->M0_ENDCOB), oFont4, 100)
oPrn:Say (325,0120,Transform(AllTrim(SM0->M0_CEPCOB),"@R 99999-999")+"  "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB, oFont4, 100)
oPrn:Box (200,1060,380,1063)
oPrn:Say (205,1070,"Agência/Código Cedente", oFont1, 100)
oPrn:Say (250,1120,AllTrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]), oFont4, 100)
oPrn:Box (200,1460,380,1463)
oPrn:Say (205,1470,"Data do Documento", oFont1, 100)
oPrn:Say (250,1570,dtoc(aDadosTit[2]), oFont4, 100)
oPrn:Box (200,1860,380,1863)
oPrn:Say (205,1870,"Vencimento", oFont1, 100)
oPrn:Say (250,2060,dtoc(aDadosTit[4]), oFont4, 100)
oPrn:Box (380,0,383,2250) // Linha Horizontal 1
//l,c,l2,c2

oPrn:Say (385,0010,"Sacado", oFont1, 100)
oPrn:Say (385,0120,AllTrim(aDatSacado[1]), oFont4, 100)
oPrn:Say (425,0120,"CNPJ "+Transform(StrZero(Val(AllTrim(aDatSacado[7])),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Box (385,1060,535,1063)
oPrn:Say (385,1070,"Número do Documento", oFont1, 100)
oPrn:Say (445,1300,aDadosTit[7]+aDadosTit[1], oFont4, 100)
oPrn:Box (385,1660,535,1663)
oPrn:Say (385,1670,"Nosso Número", oFont1, 100)
oPrn:Say (445,1800,Space(03)+substr(CB_RN_NN[3],1,8)+"-"+substr(CB_RN_NN[3],9,1), oFont4, 100)
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
oPrn:Say (590,1250,Transform (aDadosTit[5], "@E 999,999,999,999.99"), oFont4, 100)
oPrn:Box (540,1660,675,1663)
oPrn:Say (540,1670,"Descontos/Abatimentos", oFont1, 100)
//oPrn:Say (590,1800,Transform (_nDescont, "@E 999,999,999,999.99"), oFont4, 100)
oPrn:Box (675,0,678,2250) // Linha Horizontal 3
oPrn:Say (680,10,"Observação", oFont1, 100)

fBuscaItens(aDadosTit[7],SubStr(aDadosTit[1],1,6))

dbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)

dbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SD2")+SD2->D2_PEDIDO)

oPrn:Say(720,0020,SubStr(AllTrim(SC5->C5_MENNOTA),1,115), oFont4, 100)

oPrn:Box (880,0010,1890,2240)
oPrn:Say (890,0020,"Resumo das Despesas", oFont8, 100)
oPrn:Say (950,0020,"Item       Descrição", oFont4, 100)
oPrn:Say (950,1930,"Valor Faturado", oFont4, 100)

nTotProd :=0
nImpostos:=0
nLinha   :=1010

//-------------------------------------------------------------------Itens
dbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
While xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE
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
//oPrn:Say(nLinha,0020,"Obs: "+SC5->C5_OBS, oFont8, 100) 
//-------------------------------------------------------------------Fim itens

oPrn:Say (1910,1930,"Autenticação Mecânica", oFont1, 100)

oPrn:Say (2000 , 0000, Replicate ("- ",79), oFont1, 100)

_nAjuste := 2100

//oPrn:SayBitmap (0000 + _nAjuste,0010,"\REAL\Santander.jpg", 220, 070)
oPrn:Box (0000 + _nAjuste,0600,0080 + _nAjuste,0603) // divisao  no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
oPrn:Say (0015 + _nAjuste,0650,aDadosBanco[1]+"-7",oFont7,100)
oPrn:Box (0000 + _nAjuste,0850,0080 + _nAjuste,0853) // divisao entre no. banco e texto "Recibo do Sacado"
oPrn:Say (0015 + _nAjuste,0870, CB_RN_NN[2], oFont6, 150)

oPrn:Box (0080 + _nAjuste,0000,0083 + _nAjuste,2250) // Linha Horizontal 1
oPrn:Say (0085 + _nAjuste,0010,"Local de Pagamento", oFont1, 100)
oPrn:Say (0085 + _nAjuste,0350,"ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU", oFont4, 100)
oPrn:Say (0110 + _nAjuste,0350,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU", oFont4, 100)
oPrn:Say (0120 + _nAjuste,0350,"", oFont4, 100)
oPrn:Box (0080 + _nAjuste,1660,0160 + _nAjuste,1663) // Divisao entre "Loc. Pag." e "Venc."
oPrn:Say (0085 + _nAjuste,1670,"Vencimento",oFont1,100)
//oPrn:Say (0120 + _nAjuste,2060,dtoc(aDadosTit[4]), oFont4, 100)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1800+(374-(len(cString)*22))
oPrn:Say (0120 + _nAjuste,nCol+2,cString, oFont4, 100)

oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
oPrn:Say (0165 + _nAjuste,0010,"Cedente", oFont1, 100)
oPrn:Say (0195 + _nAjuste,0010,alltrim(aDadosEmp[1])+" - "+alltrim(aDadosEmp[6]), oFont4, 100)
oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
//oPrn:Say (0195 + _nAjuste,1670,"        " + aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5], oFont4, 100)
cString  := aDadosBanco[3]+"/"+ aDadosBanco[4]+"-"+aDadosBanco[5]
nCol 	 := 1800+(374-(len(cString)*22))
oPrn:Say (0195 + _nAjuste,nCol, cString, oFont4, 100)

oPrn:Box (0240 + _nAjuste,0000,0243 + _nAjuste,2250) // Linha Horizontal 3
oPrn:Say (0245 + _nAjuste,0010,"Data do Documento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0010,dtoc(aDadosTit[2]), oFont4, 100)
oPrn:Box (0240 + _nAjuste,0350,0320 + _nAjuste,0353) // Divisao entre "Data do Doc." e "No. Doc."
oPrn:Say (0245 + _nAjuste,0360,"Nº do Documento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0360,aDadosTit[7]+aDadosTit[1], oFont4, 100)
oPrn:Box (0240 + _nAjuste,0770,0320 + _nAjuste,0773) // Divisao entre "No. Doc." e "Espec. Doc."
oPrn:Say (0245 + _nAjuste,0780,"Espécie Doc.", oFont1, 100)
oPrn:Say (0275 + _nAjuste,0780,aDadosTit[8], oFont4, 100)
oPrn:Box (0240 + _nAjuste,1060,0320 + _nAjuste,1063) // Divisao entre "Espec. Doc." e "Aceite"
oPrn:Say (0245 + _nAjuste,1070,"Aceite", oFont1, 100)
oPrn:Say (0275 + _nAjuste,1070,"N", oFont4, 100)
oPrn:Box (0240 + _nAjuste,1240,0320 + _nAjuste,1243) // Divisao entre "Aceite" e "Data Proc."
oPrn:Say (0245 + _nAjuste,1250,"Data do Processamento", oFont1, 100)
oPrn:Say (0275 + _nAjuste,1250,dtoc (aDadosTit[3]), oFont4, 100)
oPrn:Box (0240 + _nAjuste,1660,0320 + _nAjuste,1663) // Divisao entre "Data Proc.." e "Cart./N.Num."
oPrn:Say (0245 + _nAjuste,1670,"Cart./Nosso Número",oFont1,100)
//oPrn:Say (0275 + _nAjuste,1670,Space(03)+ALLTRIM(SUBSTR(aDadosTit[6],4)), oFont4, 100)
cString := aDadosBanco[6]+"/"+SUBSTR(CB_RN_NN[3],1,8)+"-"+SUBSTR(CB_RN_NN[3],9,1)
nCol 	 := 1800+(374-(len(cString)*22))
oPrn:Say (0275 + _nAjuste,nCol,cString, oFont4, 100)

oPrn:Box (0320 + _nAjuste,0000,0323 + _nAjuste,2250) // Linha Horizontal 4
oPrn:Say (0325 + _nAjuste,0010,"Uso do Banco", oFont1, 100)
oPrn:Say (0360 + _nAjuste,0010,"", oFont4, 100)
oPrn:Box (0320 + _nAjuste,0350,0400 + _nAjuste,0353) // Divisao entre "Uso do Banco" e "Carteira"
oPrn:Say (0325 + _nAjuste,0360,"Carteira", oFont1, 100)
oPrn:Say (0360 + _nAjuste,0470,aDadosBanco[6],oFont4, 100)
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
//oPrn:Say (0355 + _nAjuste,1850,Transform (aDadosTit[5], "@E 999,999,999,999.99"), oFont4, 100)
cString := Alltrim(Transform (aDadosTit[5], "@E 999,999,999,999.99"))
nCol 	 := 1800+(374-(len(cString)*22))
oPrn:Say (0355 + _nAjuste,nCol,cString, oFont4, 100)

oPrn:Box (0400 + _nAjuste,0000,0403 + _nAjuste,2250) // Linha Horizontal 5
oPrn:Say (0405 + _nAjuste,0010,"Instruções (Todas as informações deste bloqueto são de exclusiva responsabilidade do cedente)", oFont1, 100)

// *********************** Início das "Instrucoes" *********************
//If ! Empty (_cNFiscal)
//	oPrn:Say (0465 + _nAjuste,0010,"Nota Fiscal/Série", oFont5, 100)
//	oPrn:Say (0505 + _nAjuste,0010,_cNFiscal, oFont1, 100)
//EndIf
oPrn:Say (0555 + _nAjuste,0010, aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")), oFont5, 100)	
oPrn:Say (0605 + _nAjuste,0010, aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")), oFont5, 100)	
oPrn:Say (0655 + _nAjuste,0010, aBolText[3], oFont5, 100)	
//oPrn:Say (0585 + _nAjuste,0010, "APOS O VENCIMENTO COBRAR MORA DIÁRIA DE R$ "+Alltrim(Transform(nJuros, "@E 99,999,999.99")), oFont5, 100)

oPrn:Box (0400 + _nAjuste,1660,0800 + _nAjuste,1663) // Divisao Vertical entre as linhas 5 e 10
oPrn:Say (0405 + _nAjuste,1670,"(-) Desconto/Abatimento", oFont1, 100)
oPrn:Box (0480 + _nAjuste,1660,0483 + _nAjuste,2250) // Linha Horizontal 6

oPrn:Box (0560 + _nAjuste,1660,0563 + _nAjuste,2250) // Linha Horizontal 7
oPrn:Say (0565 + _nAjuste,1670,"(+) Mora/Multa", oFont1, 100)                                   
//oPrn:Say (0355 + _nAjuste,1850,Transform (nMulta, "@E 999,999,999,999.99"), oFont4, 100)

oPrn:Box (0640 + _nAjuste,1660,0643 + _nAjuste,2250) // Linha Horizontal 8

oPrn:Box (0720 + _nAjuste,1660,0723 + _nAjuste,2250) // Linha Horizontal 9
oPrn:Say (0725 + _nAjuste,1670,"(=) Valor Cobrado", oFont1, 100)

oPrn:Box (0800 + _nAjuste,0000,0803 + _nAjuste,2250) // Linha Horizontal 10
oPrn:Say (0805 + _nAjuste,0010,"Sacado:", oFont1, 100)
oPrn:Say (0805 + _nAjuste,0260,aDatSacado[1]+" ("+aDatSacado[2]+")", oFont4, 100)
oPrn:Say (0845 + _nAjuste,0260,aDatSacado[3], oFont4, 100)
oPrn:Say (0885 + _nAjuste,0260,"Cep: "+aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]+"      "+"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"), oFont4, 100)
oPrn:Say (0905 + _nAjuste,0010,"Sacador/Avalista", oFont1, 100) //945
oPrn:Say (0905 + _nAjuste,1700,"Código de Baixa ", oFont1, 100)
oPrn:Box (0940 + _nAjuste,0000,0943 + _nAjuste,2250) // Linha Horizontal 11 980
oPrn:Say (0945 + _nAjuste,1550,"Autenticação Mecânica - Ficha de Compensação", oFont1, 100)
//If mv_par04 == 1
	MsBar("INT25", 27.5, 0, Alltrim(CB_RN_NN[1]), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
//ElseIF mv_par04 = 2.Or.Mv_Par04 = 3
 //	MsBar("INT25", 27.0, 0, Alltrim(CB_RN_NN[1]), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
//EndIf	
//ElseIF mv_par08 == 3
//	MsBar("INT25", 30.4, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
//EndIf

//-Parametros - Geracao Cod. Barras - Wederson 30/03/05
// 09 nWidth	Numero do Tamanho da barra em centimetros
// 10 nHeigth	Numero da Altura da barra em milimetros

oPrn:Say (1040 + _nAjuste, 0000, Replicate ("- ", 79), oFont1, 100) //1080

nPag ++
oPrn:EndPage ()

Return


//--------------------------------------------

Static Function fCriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Prefixo        	","","","mv_ch1","C",03,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Do  Numero     	","","","mv_ch2","C",06,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Ate Numero         ","","","mv_ch3","C",06,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{cPerg,"04","Banco   		   ","","","mv_ch4","C",03,00,00,"G","","Mv_Par04","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","",""})
//AADD(aRegistros,{cPerg,"05","Agencia  		   ","","","mv_ch5","C",05,00,00,"G","","Mv_Par05","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{cPerg,"06","Conta    		   ","","","mv_ch6","C",10,00,00,"G","","Mv_Par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{cPerg,"07","SubConta 		   ","","","mv_ch7","C",03,00,00,"G","","Mv_Par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{cPerg,"08","Impressora	   ","","","mv_ch8","N",01,00,00,"C","","Mv_Par08","Laser 1100","","","","","Laser 4200","","","","","","","","","","","","","","","","","","","","","",""})

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
cQuery += "AND SE1.E1_FILIAL+SE1.E1_PREFIXO+SE1.E1_NUM=SF2.F2_FILIAL+SF2.F2_PREFIXO+SF2.F2_DUPL "+Chr(10)
cQuery += "AND SE1.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "+Chr(10)

TCQuery cQuery ALIAS "SSF2" NEW


/*cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SSD2",.T.)*/

Return()
/* ALTERADO 13/04/11 - Matheus */

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF
RETURN(D)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData)
LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 1
ELSE
	D := 11 - (mod(D,11))	
ENDIF 


RETURN(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
//Static Function Ret_cB    (cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

Local cCarteira    := "109"
LOCAL BlDocNuFinal := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
LOCAL blvalorfinal := Strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator       := Strzero(dVencto - ctod("07/10/1997"),4)

//Montagem DAC do NOSSO NUMERO

snn   := BlDocNuFinal  // Nosso Numero
dvnn  := Alltrim(Str(modulo10(snn)))  //Digito verificador no Nosso Numero
cNN   := Strzero(val(cNroDoc),8) + dvnn 
                                         
//Montagem DAC do campo agencia+conta+carteira+nossonumero
cCod  := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
dvCod := Alltrim(Str(modulo10(cCod)))    
     
//MONTAGEM DA LINHA DIGITAVEL 
// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 1 
campo1  := cBanco + cMoeda + cCarteira + substr(cNN,1,2) 
dvC1    := Alltrim(Str(modulo10(campo1)))                                  
cCampo1 := campo1 + dvC1

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 2 
campo2  := substr(cNN,3,6) + dvCod + substr(cAgencia,1,3)  
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2   //+ substr(cNroDoc+dvnn,3,7)

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 3 
campo3  := substr(cAgencia,4,1) + cConta + cDacCC + "000" 
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 //+ substr(cAgencia,4,1)

// Montagem das DACs do Codigo de Barras
//campo 4
campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000"
cDacCB  := Alltrim(Str(Modulo11(campo4)))
cCampo4 := cDacCB

// Montagem 
//campo 5
cCampo5  := cFator + blvalorfinal
////////////////////////////////////////////////////////////////////////////

cCB      := cBanco + cMoeda + cDacCB + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000" // codigo de barras

////////////////////////////////////////////////////////////////////////////
//MONTAGEM DA LINHA DIGITAVEL 

cRN := substr(cCampo1,1,5)+"."+substr(cCampo1,6,5)+space(2)+ substr(cCampo2,1,5)+"."+substr(cCampo2,6,6)+space(2)+ substr(cCampo3,1,5)+"."+substr(cCampo3,6,6)+space(2) + cCampo4 + space(2)+ cCampo5 

Return({cCB,cRN,cNN})
