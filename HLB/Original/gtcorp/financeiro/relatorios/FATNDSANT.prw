#include "rwmake.ch"
#include "topconn.ch"

/*
Funcao      : FatNDSant
Parametros  : 
Retorno     : 
Objetivos   : Impressão da Fatura ND Banco Santander.
Autor       : 
TDN         : 
Revisão     : João Silva
Data/Hora   : 25/06/2014
Módulo      : Financeiro.
*/    

User Function FatNDSant()

LOCAL	aPergs 	   := {}  
Private cTpND 	   := ""
Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := ""
Private sBarra 

cPerg     :="FATSANT   "

Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Tipo Fatura","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","GT","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("FATSANT   ",aPergs) 

If Pergunte (cPerg,.T.)
	Processa({||FokImp()},"Fatura ND Banco Santander")
Endif



Return

//-----------------------------------------

Static Function fOkImp()
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aDadosEmp
LOCAL cNroDoc:=""
Local nAcresc:=""
Local nDecres:=""   
LOCAL _nVlrAbat := 0

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
Private cCodEmp	   := ""

dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

cTpND 	:= SuperGetMv("MV_P_00013",.F.,MV_PAR01)

If Alltrim(SM0->M0_CODIGO)=="4K"   // Rio
	cBanco    := "033"
	cAgencia  := "3853 "
	cConta    := "130063879  "	
	cCodEmp	  := "6682260"
	cSubConta := "001"
EndIf
                              
cSubConta := If(Empty(cSubConta),"001",cSubConta) 

If MV_PAR01 $ cTpND
	
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
		 If FieldPos("A1_P_TPBOL") > 0
			SA1->(DbSetOrder(1))     //Inicio-> // JSS - Criado para tratamento das faturas KPMG
				If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE +SE1->E1_LOJA))
					nTipoBol:= Val(SA1->A1_P_TPBOL)
				EndIf
		    	If  (nTipoBol == 1 .OR. nTipoBol == 3).AND. MV_PAR04 == 2   
					SE1->(dbSkip())  //Fim-> // JSS - Criado para tratamento das faturas KPMG
	  			Loop
	    	Endif  
		 EndIF
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
				If AllTrim(SE1->E1_TIPO) $ "NF/ND"
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
					//RRP - 26/07/2013 - Acréscimo e Decréscimo.
					nAcresc:=SE1->E1_ACRESC
					nDecres:=SE1->E1_DECRESC
					
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
						Replace SE1->E1_NUMBCO  		With SUBSTR(SEE->EE_FAXATU,1,8)+ AllTrim(Str(MODULO11(SUBSTR(SEE->EE_FAXATU,1,8))))
						Replace SE1->E1_PORTADO 		With cBanco
						Replace SE1->E1_AGEDEP  		With cAgencia
						Replace SE1->E1_CONTA  			With cConta
						
						SE1->(MsUnLock())
						RecLock("SEE",.F.)
						Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,8)
						SEE->(MsUnlock())
						cNroDoc := SubStr(StrZero(Val(SE1->E1_NUMBCO),9),1,8)
					Else
						RecLock("SE1",.F.)
						SE1->(MsUnLock())
						cNroDoc := SubStr(Alltrim(SE1->E1_NUMBCO),1,8)
						
					Endif
					lOk:=.T.
				Endif
				DbSelectArea("SE1")
				IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)
				DbSkip()
			End
			
			IF EMPTY(SA1->A1_ENDCOB)
				aDatSacado := {	AllTrim(SA1->A1_NOME),;					// [1]Razao Social
				AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;					// [2]Codigo
				AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereco
				AllTrim(SA1->A1_MUN),;									// [4]Cidade
				SA1->A1_EST,;											// [5]Estado
				SA1->A1_CEP,;											// [6]CEP
				SA1->A1_CGC}											// [7]CGC
			ELSE
				aDatSacado := {	AllTrim(SA1->A1_NOME),;					// [1]Razao Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;				// [2]Codigo
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereco
				AllTrim(SA1->A1_MUNC),;									// [4]Cidade
				SA1->A1_ESTC,;											// [5]Estado
				SA1->A1_CEPC,;											// [6]CEP
				SA1->A1_CGC}											// [7]CGC
			ENDIF
			
			aDadosEmp := {SM0->M0_NOMECOM,;												//[1]Nome da Empresa
			SM0->M0_ENDCOB,; 															//[2]Endereço
			AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;//[3]Complemento
			"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			//[4]CEP
			"PABX/FAX: "+SM0->M0_TEL,; 													//[5]Telefones
			"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;			//[6]
			Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;						//[6]
			Subs(SM0->M0_CGC,13,2),;													//[6]CGC
			"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;			//[7]
			Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}
			
			aDadosBanco := {"033" ,;									// [1]Numero do Banco
			"BANCO SANTANDER",;										    // [2]Nome do Banco
			SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
			SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
			SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
			"101"}                                                     	// [6]Codigo da Carteira
			
			CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)+nAcresc-nDecres),dVencto)		
			//CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNumBco,((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)+nAcresc-nDecres),dVencto)
			
		    
			aDadosTit := {	AllTrim(substr(cTitulo,4)),;					// [1] Numero do Titulo
			dEmissao,;														// [2] Data da Emissao do Titulo
			Date(),;														// [3] Data da Emissao do Boleto
			dVencto,;														// [4] Data do Vencimento
			((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)+nAcresc-nDecres),;// [5] Valor do Titulo
			CB_RN_NN[3],;													// [6] Nosso Numero (Ver Formula para Calculo)
			AllTrim(substr(cTitulo,1,3)),;									// [7] Prefixo da NF
			cTipo,;															// [8] Tipo do Titulo  
			nDecres,;				            	                		// [9] Desconto
			nAcresc}              			    	            		//[10] Acrecimos
		    
		    //((nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)+nAcresc-nDecres)}	// [9] RRP - 26/07/2013 - Valor do Titulo com Acréscimo e Decréscimo
	         
	        /*
	        aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;//[1] Numero do Titulo
				E1_EMISSAO,;									// [2] Data da Emissao do Titulo
				Date(),;										// [3] Data da Emissao do Boleto
				E1_VENCTO,;										// [4] Data do Vencimento
				(E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC),;	// [5] Valor do Titulo
				CB_RN_NN[3],;									// [6] Nosso Numero (Ver Formula para Calculo)
				E1_PREFIXO,;									// [7] Prefixo da NF
				E1_TIPO,;										// [8] Tipo do Titulo  
				E1_DECRESC,;                            		// [9] Desconto
				E1_ACRESC}                              		//[10] Acrecimos
		     */
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
Else
	MsgInfo ("Este prefixo deve ser utilizado na rotina Boleto Itau ou Boleto Itau/Santander." + Chr (13) + Chr (13) + "Por favor, informe outro prefixo.","A T E N C A O")
	Return Nil
EndIf 
	
Return

//----------------------------------

Static Function fImprime(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
Local cSantLogo:="LOGO0331.bmp"


_nValor := (nValTot-nValCf-nValCs-nValPi-nValIr-nValIn)

//nJuros  := Round( (nValor/30)*(1/100),2) 
//nMultaMensal:= Round( (nValor)*(2/100),2)   

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
oPrn:Say (140,10,"Recibo do Pagador",oFont2,0)
oPrn:Box (200,0,1900,2250)
oPrn:Say (205,0010,"Cedente", oFont1, 100)
oPrn:Say (205,0150,AllTrim(SM0->M0_NOMECOM), oFont4, 100)
oPrn:Say (245,0150,"CNPJ "+Transform(StrZero(Val(AllTrim(SM0->M0_CGC)),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Say (285,0150,AllTrim(SM0->M0_ENDCOB), oFont4, 100)
oPrn:Say (325,0150,Transform(AllTrim(SM0->M0_CEPCOB),"@R 99999-999")+"  "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB, oFont4, 100)
oPrn:Box (200,1060,380,1063)
oPrn:Say (205,1070,"Agência/Código Cedente", oFont1, 100)
oPrn:Say (250,1120,AllTrim(aDadosBanco[3])+"/"+cCodEmp, oFont4, 100)
oPrn:Box (200,1460,380,1463)
oPrn:Say (205,1470,"Data do Documento", oFont1, 100)
oPrn:Say (250,1570,dtoc(aDadosTit[2]), oFont4, 100)
oPrn:Box (200,1860,380,1863)
oPrn:Say (205,1870,"Vencimento", oFont1, 100)
oPrn:Say (250,2060,dtoc(aDadosTit[4]), oFont4, 100)
oPrn:Box (380,0,383,2250) // Linha Horizontal 1

oPrn:Say (385,0010,"Pagador", oFont1, 100)
oPrn:Say (385,0150,AllTrim(aDatSacado[1]), oFont4, 100)
oPrn:Say (425,0150,"CNPJ "+Transform(StrZero(Val(AllTrim(aDatSacado[7])),15),"@R 999.999.999/9999-99"), oFont4, 100)
oPrn:Box (385,1060,535,1063)
oPrn:Say (385,1070,"Número do Documento", oFont1, 100)
oPrn:Say (445,1300,aDadosTit[7]+aDadosTit[1], oFont4, 100)
oPrn:Box (385,1660,535,1663)
oPrn:Say (385,1670,"Nosso Número", oFont1, 100)
//oPrn:Say (445,1800,Space(03)+substr(CB_RN_NN[3],1,8)+"-"+substr(CB_RN_NN[3],9,1), oFont4, 100)
oPrn:Say (445,1800,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'), oFont4, 100)
oPrn:Box (535,0,538,2250) // Linha Horizontal 2

oPrn:Say (540,0010,"Espécie", oFont1, 100)
oPrn:Say (590,0150,"FATURA", oFont4, 100)
oPrn:Box (540,300,675,303)
oPrn:Say (540,310,"Valor", oFont1, 100) //540,520
oPrn:Say (590,310,"R$", oFont4, 100)    //590,540
oPrn:Box (540,1060,675,1063)
oPrn:Say (540,1070,"Valor do Documento", oFont1, 100)
oPrn:Say (590,1070,"R$", oFont4, 100)
oPrn:Say (590,1250,Transform (aDadosTit[5], "@E 999,999,999,999.99"), oFont4, 100) 
oPrn:Box (540,1660,675,1663)
oPrn:Say (540,1670,"Descontos/Abatimentos", oFont1, 100)
oPrn:Say (590,1800,Transform (aDadosTit[9], "@E 999,999,999,999.99"), oFont4, 100) //RRP - 26/07/2013 - Acréscimo e Decréscimo.
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
		oPrn:Say(nLinha,1930,Transform(nValCf,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValCs > 0
		oPrn:Say(nLinha,0020,"Csll 1,00%", oFont4, 100)
		oPrn:Say(nLinha,1930,Transform(nValCs,"@E 999,999,999.99"), oFont4, 100)
		nLinha+=40
	EndIf
	If nValPi > 0
		oPrn:Say(nLinha,0020,"Pis 0,65%", oFont4, 100)
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
//--------------------------------------Inicio do corpo do boleto    

oPrn:SayBitmap (0000 + _nAjuste,0010,cSantLogo, 220, 070)
oPrn:Box (0000 + _nAjuste,0600,0080 + _nAjuste,0603)			 // divisao  no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
oPrn:Say (0015 + _nAjuste,0650,aDadosBanco[1]+"-7",oFont7,100)
oPrn:Box (0000 + _nAjuste,0850,0080 + _nAjuste,0853) 			// divisao entre no. banco e texto "Recibo do Sacado"
oPrn:Say (0015 + _nAjuste,0870, CB_RN_NN[2], oFont6, 150)

oPrn:Box (0080 + _nAjuste,0000,0083 + _nAjuste,2250) // Linha Horizontal 1
oPrn:Say (0085 + _nAjuste,0010,"Local de Pagamento", oFont1, 100)
oPrn:Say (0085 + _nAjuste,0350,"Qualquer banco até a data do vencimento", oFont4, 100)
//oPrn:Say (0110 + _nAjuste,0350,"APOS O VENCIMENTO PAGUE SOMENTE NO BANCO SANTANDER ", oFont4, 100)
oPrn:Say (0120 + _nAjuste,0350,"", oFont4, 100)
oPrn:Box (0080 + _nAjuste,1660,0160 + _nAjuste,1663) // Divisao entre "Loc. Pag." e "Venc."
oPrn:Say (0085 + _nAjuste,1670,"Vencimento",oFont1,100)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1800+(374-(len(cString)*22))
oPrn:Say (0120 + _nAjuste,nCol+2,cString, oFont4, 100)

If MV_PAR04 == 2
	oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
	oPrn:Say (0165 + _nAjuste,0010,"Cedente ", oFont1, 100)
	oPrn:Say (0195 + _nAjuste,0010,alltrim(aDadosEmp[1])+" - "+alltrim(aDadosEmp[6]), oFont4, 100)
	oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
	oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
	cString  := aDadosBanco[3]+"/"+cCodEmp
	nCol 	 := 1800+(374-(len(cString)*22))
	oPrn:Say (0195 + _nAjuste,nCol, cString, oFont4, 100)
Else
	oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
	oPrn:Say (0165 + _nAjuste,0010,"Cedente", oFont1, 100)
	oPrn:Say (0195 + _nAjuste,0010,alltrim(aDadosEmp[1])+" - "+alltrim(aDadosEmp[6]), oFont4, 100)
	oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
	oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
	cString  := aDadosBanco[3]+"/"+cCodEmp
	nCol 	 := 1800+(374-(len(cString)*22))
	oPrn:Say (0195 + _nAjuste,nCol, cString, oFont4, 100)
EndIf

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
//cString := aDadosBanco[6]+"/"+SUBSTR(CB_RN_NN[3],1,8)+"-"+SUBSTR(CB_RN_NN[3],9,1)   
cString := PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0') 
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
oPrn:Say (0355 + _nAjuste,1850,Transform (aDadosTit[5], "@E 999,999,999,999.99"), oFont4, 100)//JSS
cString := Alltrim(Transform (aDadosTit[9], "@E 999,999,999,999.99")) //RRP - 26/07/2013 - Acréscimo e Decréscimo.
nCol 	 := 1800+(374-(len(cString)*22))
//oPrn:Say (0355 + _nAjuste,nCol,cString, oFont4, 100)

oPrn:Box (0400 + _nAjuste,0000,0403 + _nAjuste,2250) // Linha Horizontal 5
oPrn:Say (0405 + _nAjuste,0010,"Instruções (Todas as informações deste bloqueto são de exclusiva responsabilidade do cedente)", oFont1, 100)

// *********************** Início das "Instrucoes" *********************

oPrn:Say (0555 + _nAjuste,0010, aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")), oFont5, 100)	

//oPrn:Say (0605 + _nAjuste,0010, aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")), oFont5, 100)	
//JSS - ALTERADO PARA SOLUCIONAR O CHAMADO 019604 
If Alltrim(SM0->M0_CODIGO)$("Z4/CH/PN/MP/MQ/MW/MY/RH/Z8/ZP/") 	
	oPrn:Say (_nAjuste+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont5)
Else 
   Alltrim(SM0->M0_CODIGO)$("ZB/ZF/") 
	oPrn:Say (_nAjuste+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont5)
EndIf

oPrn:Say (0655 + _nAjuste,0010, aBolText[3], oFont5, 100)	

oPrn:Box (0400 + _nAjuste,1660,0800 + _nAjuste,1663) // Divisao Vertical entre as linhas 5 e 10
oPrn:Say (0405 + _nAjuste,1670,"(-) Desconto/Abatimento", oFont1, 100)   
oPrn:Say (0435 + _nAjuste,1850,Transform (aDadosTit[9], "@E 999,999,999,999.99"), oFont4, 100)//JSS 
oPrn:Box (0480 + _nAjuste,1660,0483 + _nAjuste,2250) // Linha Horizontal 6

oPrn:Box (0560 + _nAjuste,1660,0563 + _nAjuste,2250) // Linha Horizontal 7
oPrn:Say (0590 + _nAjuste,1850,Transform (aDadosTit[10], "@E 999,999,999,999.99"), oFont4, 100)//JSS
oPrn:Say (0565 + _nAjuste,1670,"(+) Outros Acrecimos", oFont1, 100)                                   

oPrn:Box (0640 + _nAjuste,1660,0643 + _nAjuste,2250) // Linha Horizontal 8

oPrn:Box (0720 + _nAjuste,1660,0723 + _nAjuste,2250) // Linha Horizontal 9
oPrn:Say (0725 + _nAjuste,1670,"(=) Valor Cobrado", oFont1, 100)

oPrn:Box (0800 + _nAjuste,0000,0803 + _nAjuste,2250) // Linha Horizontal 10
oPrn:Say (0805 + _nAjuste,0010,"Sacador", oFont1, 100)
oPrn:Say (0805 + _nAjuste,0260,aDatSacado[1]+" ("+aDatSacado[2]+")", oFont4, 100)
oPrn:Say (0845 + _nAjuste,0260,aDatSacado[3], oFont4, 100)
oPrn:Say (0885 + _nAjuste,0260,"Cep: "+aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]+"      "+"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"), oFont4, 100)
oPrn:Say (0905 + _nAjuste,0010,"Sacador/Avalista", oFont1, 100) //945
oPrn:Say (0905 + _nAjuste,1870,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'), oFont4, 100)
oPrn:Box (0940 + _nAjuste,0000,0943 + _nAjuste,2250) // Linha Horizontal 11 980
oPrn:Say (0945 + _nAjuste,1550,"Autenticação Mecânica - Ficha de Compensação", oFont1, 100)

	MsBar("INT25", 27.5, 0, Alltrim(CB_RN_NN[1]), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)

//-Parametros - Geracao Cod. Barras - Wederson 30/03/05
// 09 nWidth	Numero do Tamanho da barra em centimetros
// 10 nHeigth	Numero da Altura da barra em milimetros   

//--------------------------------------Fim do corpo do boleto
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
STATIC FUNCTION Modulo11(cData,lCodBarra)
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

//Tratamento para digito verificador.
If lCodBarra //Codigo de Barras
	//Se o resto for 0,1 ou 10 o digito é 1
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		D := 1
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
Else //Nosso Numero
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		//Se o resto for 0 ou 1 o digito é 0
		IF (D == 0 .Or. D == 1)
			D := 0

		//Se o resto for 10 o digito é 1
		ELSEIF (D == 10)
			D := 1
		ENDIF
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
EndIf	


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
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,_nValor,dVencto)

Local cCart    := "101"
LOCAL BlDocNuFinal := cAgencia + cConta + cCart + Strzero(val(cNroDoc),8)
LOCAL cValorFinal 	:= strzero((_nValor*100),10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator       := Strzero(dVencto - ctod("07/10/1997"),4)

//-----------------------------                                      
// Definicao do NOSSO NUMERO
// ----------------------------
cS    := cNroDoc
nDvnn := modulo11(cS,.F.) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
cNN   := cCart + cNroDoc + '-' + AllTrim(Str(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + cNNSD + Strzero(Val(cConta),8) + "0"
cS		:= cBanco + cFator +  cValorFinal + "9"+SUBSTR(cCodEmp,1,4)+SUBSTR(cCodEmp,5,3)+cNNCD+"0"+cCart
nDvcb 	:= modulo11(cS,.T.)
cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		WWWDD.DDDDDY	FFFFF.FQQQQZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**CEDENTE
cCedente:=SUBSTR(cCodEmp,1,4)// "4806"
//cS    := cBanco + "9" + Substr(cLivre,1,4)
cS    := cBanco + "9" + cCedente
nDv   := modulo10(cS)  //DAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '


// 	CAMPO 2:
//	WWW =COD CEDENTE PADRAO
//	DDDDDDD = Posição 14 a 20 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Complemento Cedente
cCompCed:=SUBSTR(cCodEmp,5,3) //"301"   

cS 	:=cCompCed+Subs(cNNCD,1,7)
nDv	:= modulo10(cS)
cRN	+= Subs(cS,1,3)+substr(cNNCD,1,2) +'.'+ substr(cNNCD,3,5) + Alltrim(Str(nDv)) + '  

// 	CAMPO 3:
//	FFFFFF = Posição 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
cTipoMod:="0101" //Cobrança Simples Rápida COM Registro                   

cS 	:=substr(cNNCD,8,6)+cTipoMod
nDv	:= modulo10(cS)
cRN	+= substr(cNNCD,8,5) +'.'+ substr(cNNCD,13,1)+cTipoMod+ Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN  += cFator + StrZero((_nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})
