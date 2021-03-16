#include "rwmake.ch"

/*
Funcao      : R7RFIN01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emissao Boleto 
Autor     	: Renato Mendonça                          
Data     	: 14/12/2006                     
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Financeiro. 
Cliente     : Shiseido
*/

*------------------------*
 User Function R7RFIN01()
*------------------------*

Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := "RFIN01    "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Prefixo                               ³
//³ mv_par02            // Do numero                             ³
//³ mv_par03            // Ateh o numero                         ³
//³ mv_par04            // Banco (Say)                           ³
//³ mv_par05            // Agencia                               ³
//³ mv_par06            // Conta + DAC                           ³
//³ mv_par07            // Sub Conta                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If cEmpAnt $ "R7"
//   fCriaPerg()
   If Pergunte (cPerg,.T.)
	   fOkImp()
   Endif
Else
    MsgInfo("Especifico Shiseido ","A T E N C A O ")
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
Private oPrn       := TAvPrinter ():New ()
Private lContinua:= .T.

cBanco    := "409"					
cAgencia  := mv_par07
cConta    := mv_par08				
cSubConta := mv_par09				
sBarra    := cNossoNum :=cNumBco := cNossoDig :=cNossoNum2 :=0

oPrn:Setup ()
SEE->(dbSetOrder(1))
SEE -> (dbGoTop ())
If ! SEE -> (dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta,.F.))
	MsgInfo ("Parametros do Banco/Agencia/Conta/Sub Conta nao encontrados." + Chr (13) + Chr (13) + "Por favor verifique.")
	Return
EndIf

cCart    := "4"
cMoeda   := "9"								// Codigo da Moeda no Banco (sempre 9)
cAgencia := "04774"

dbSelectArea ("SE1")
dbSetOrder (1)
dbSeek (xFilial("SE1")+mv_par01+mv_par02+mv_par04, .T.)

nCont := 0

Do While !Eof().and.xFilial("SE1") == SE1->E1_FILIAL.and.lContinua ;
	.and.SE1->E1_PREFIXO == Mv_Par01 .and. SE1->E1_NUM <= Mv_Par03 ;
	.And.SE1->E1_PARCELA >= Mv_Par04 .And. SE1->E1_PARCELA <= Mv_Par05
	
	oPrn:StartPage ()
	nCont := nCont + 1

	_nValor := SE1->E1_SALDO
	nAbatim := SE1->E1_DECRESC
	nMulta  := 3
	nMora   := 0.10
	nJuros  := Round (_nValor * (nMora/100), 2) 
	nDescont:= (SE1->E1_VALOR*SE1->E1_DESCFIN)/100
	
	If Empty(SE1->E1_NUMBCO)
	   RecLock("SE1",.F.)
	   Replace SE1->E1_NUMBCO  With SEE->EE_FAXATU
	   SE1->(MsUnLock())
	   RecLock("SEE",.F.)	
	   Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,10)
	   SEE->(MsUnlock())
	   cNumBco := SE1->E1_NUMBCO
	Else
	   cNumBco := SE1->E1_NUMBCO
	Endif   

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
	cFatVenc := StrZero(SE1->E1_VENCREA - ctod ("07/10/1997"), 4)
	cValor   := StrZero(100*(_nValor), 10)

	//------------------------------------------- Digito Nosso Numero
   nBaseDiv := 0
	cStrMult := "3298765432"
	_nTam    := Len(cstrMult)
	_nNumBco := Len(Alltrim(cNumBco))
   While _nNumBco > 0
		nBaseDiv += Val(SubStr(cNumBco,_nNumBco,1)) * Val(SubStr(cStrMult,_nTam,1))
		_nNumBco -=1
		_nTam    -=1
	End

	nResto  := (nBaseDiv*10)%11		// Calcula Modulo 11
	cResto  := Alltrim (Str(nResto))
		
	If cResto == "10" 
		cResto := "0"
	EndIf
   cNossoNum  :="1/"+Alltrim(cNumBco)+"-"+cResto    
  	cNossoNum2 :="1"+AllTrim(cNumBco)+cResto
   cNossoDig  :=SubStr(AllTrim(cNumBco),3,8)+cResto
  	//--------------------------------------------Super Digito Nosso Numero
   nBaseDiv   := 0
	cStrMult   := "543298765432"
	_nTam    := Len(cStrMult)
	_nNumBco := Len(cNossoNum2)
   While _nNumBco > 0
		nBaseDiv += Val(SubStr(cNossoNum2,_nNumBco,1)) * Val(SubStr(cStrMult,_nTam,1))
		_nNumBco -=1
		_nTam    -=1
	End
	nResto  := (nBaseDiv*10)%11		// Calcula Modulo 11
	cResto  := Alltrim (Str(nResto))
		
	If cResto == "10" 
		cResto := "0"
	EndIf
   
	cNossoNum +="/"+cResto
	cDig      := cResto
	sBarra    := cBanco+cMoeda+cFatVenc+cValor+"0"+cCart+SubStr(Dtos(SE1->E1_VENCREA),3,2)+StrZero(Month(SE1->E1_VENCREA),2)+StrZero(Day(SE1->E1_VENCREA),2)+cAgencia+AllTrim(cNumero)+SubStr(cNossoDig,Len(cNossoDig),1)+cDig

	//--------------------------------------------Digito Codigo Barras
	cStrMult  := "4329876543298765432987654329876543298765432"
	_nTam     :=Len(cStrMult)
	_nBarra   :=Len(sBarra)
	nBaseDiv  := 0
   While _nBarra > 0
		nBaseDiv += Val(SubStr(sBarra,_nBarra,1)) * Val(SubStr(cStrMult,_nTam,1))
	   _nTam   -=1
	   _nBarra -=1
	End
	nResto  := (nBaseDiv*10)%11		// Calcula Modulo 11
	cResto  := Alltrim (Str(nResto))
	
	If cResto == "0" .or. cResto == "1" .or. cResto == "10" 
		cResto := "1"
	EndIf
	//----------------------------------------------
 	sBarra  := cBanco+cMoeda+cResto+cFatVenc+cValor+"0"+cCart+SubStr(Dtos(SE1->E1_VENCREA),3,2)+StrZero(Month(SE1->E1_VENCREA),2)+StrZero(Day(SE1->E1_VENCREA),2)+cAgencia+AllTrim(cNumero)+SubStr(cNossoDig,Len(cNossoDig),1)+cDig

	// Formacao da linha digitavel:
	sDigit  :=""
	sDigit1 :=cBanco+cMoeda+StrZero(Val(cCart),2)+SubStr(Dtos(SE1->E1_VENCREA),3,2)+SubStr(StrZero(Month(SE1->E1_VENCREA),2),1,1)
	sDigit  :=sDigit1+CalcDig(sDigit1)
	sDigit2 :=SubStr(StrZero(Month(SE1->E1_VENCREA),2),2,1)+StrZero(Day(SE1->E1_VENCREA),2)+AllTrim(cAgencia)+SubStr(cNossoNum,3,2)
	sDigit  +=sDigit2+CalcDig(sDigit2)
	sDigit3 :=cNossoDig+cDig
	sDigit  +=sDigit3+CalcDig(sDigit3)
	sDigit  +=cResto+cFatVenc+cValor
	sDigit  := Transform (sDigit, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")
	
	// ********************************************************************************
	// ********************** Fim da Criacao da Linha Digitavel ***********************
	// ********************************************************************************
	
	dbSelectArea ("SE1")
	
	SF2->(dbSetOrder(1))
	SF2->(dbGoTop())
	_cNFiscal := ""
	If SF2->(dbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA), .F.))
		_cNFiscal := SF2->(F2_DOC+IIf(!Empty(SF2->F2_SERIE), "/" + F2_SERIE, ""))
	EndIf
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
	
	For _nCont := 1 to 3
		If _nCont == 1
			_nAjuste := 0
		ElseIf _nCont == 2
			_nAjuste := 1060 //1090
		ElseIf _nCont == 3
			_nAjuste := 2100 //2180
		EndIf
		
		oPrn:Say (0015 + _nAjuste,0010,"UNIBANCO ",oFont3,100)	// LinhaIni, ColunaIni
		oPrn:Box (0000 + _nAjuste,0600,0080 + _nAjuste,0603) // divisao entre Itau e no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
		oPrn:Say (0015 + _nAjuste,0650,"409-0",oFont2,100)
		oPrn:Box (0000 + _nAjuste,0850,0080 + _nAjuste,0853) // divisao entre no. banco e texto "Recibo do Sacado"
		If _nCont == 1
			oPrn:Say (0015 + _nAjuste,1670,"Recibo do Sacado",oFont2,150)
		ElseIf _nCont == 2
			oPrn:Say (0015 + _nAjuste,1670,"Ficha de Caixa",oFont2,150)                                                         
			
		ElseIf _nCont == 3
			oPrn:Say (0015 + _nAjuste,0870, sDigit, oFont6, 150)
		EndIf
		oPrn:Box (0080 + _nAjuste,0000,0083 + _nAjuste,2250) // Linha Horizontal 1
		oPrn:Say (0085 + _nAjuste,0010,"Local de Pagamento", oFont1, 100)
		oPrn:Say (0085 + _nAjuste,0350,"ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO UNIBANCO", oFont4, 100)
		oPrn:Say (0120 + _nAjuste,0350,"APÓS O VENCIMENTO PAGUE SOMENTE NO UNIBANCO", oFont4, 100)
		oPrn:Box (0080 + _nAjuste,1660,0160 + _nAjuste,1663) // Divisao entre "Loc. Pag." e "Venc."
		oPrn:Say (0085 + _nAjuste,1670,"Vencimento",oFont1,100)
		oPrn:Say (0120 + _nAjuste,2060,dtoc (SE1 -> E1_VENCREA), oFont4, 100)
		
		oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
		oPrn:Say (0165 + _nAjuste,0010,"Cedente", oFont1, 100)
		oPrn:Say (0195 + _nAjuste,0010,"Shiseido do Brasil Ltda", oFont4, 100)
		oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
		oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
		oPrn:Say (0195 + _nAjuste,1670,"        " + Transform(cAgencia,"@R 9999-9") + " / " + cConta, oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0000,0243 + _nAjuste,2250) // Linha Horizontal 3
		oPrn:Say (0245 + _nAjuste,0010,"Data do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0010,dtoc (SE1 -> E1_EMISSAO), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0350,0320 + _nAjuste,0353) // Divisao entre "Data do Doc." e "No. Doc."
		oPrn:Say (0245 + _nAjuste,0360,"Nº do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0360,SE1 -> (E1_NUM + "-" + E1_PARCELA), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0770,0320 + _nAjuste,0773) // Divisao entre "No. Doc." e "Espec. Doc."
		oPrn:Say (0245 + _nAjuste,0780,"Espécie Doc.", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0780,"DM", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1060,0320 + _nAjuste,1063) // Divisao entre "Espec. Doc." e "Aceite"
		oPrn:Say (0245 + _nAjuste,1070,"Aceite", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1070,"Não", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1240,0320 + _nAjuste,1243) // Divisao entre "Aceite" e "Data Proc."
		oPrn:Say (0245 + _nAjuste,1250,"Data do Processamento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1250,dtoc (dDataBase), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1660,0320 + _nAjuste,1663) // Divisao entre "Data Proc.." e "Cart./N.Num."
		oPrn:Say (0245 + _nAjuste,1670,"Cart./Nosso Número",oFont1,100)
		oPrn:Say (0275 + _nAjuste,1670,Space(03)+cNossoNum, oFont4, 100)
		
		oPrn:Box (0320 + _nAjuste,0000,0323 + _nAjuste,2250) // Linha Horizontal 4
		oPrn:Say (0325 + _nAjuste,0010,"Uso do Banco", oFont1, 100)
		oPrn:Box (0320 + _nAjuste,0350,0400 + _nAjuste,0353) // Divisao entre "Uso do Banco" e "Carteira"
		oPrn:Say (0325 + _nAjuste,0360,"Carteira", oFont1, 100)
        oPrn:Say (0360 + _nAjuste,0470,cCart,oFont4, 100)		
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
		oPrn:Say (0465 + _nAjuste,0010,"Após o Vencimento:", oFont5, 100)
		If ! Empty (_cNFiscal)
			oPrn:Say (0465 + _nAjuste,1150,"Nota Fiscal/Série", oFont5, 100)
			oPrn:Say (0500 + _nAjuste,1150,_cNFiscal, oFont1, 100)
		EndIf
		
		oPrn:Say (0555 + _nAjuste,0010, "Multa (Percentual)........: " + Transform (nMulta, "@E 999.99") + "%", oFont5, 100)
		oPrn:Say (0595 + _nAjuste,0010, "Mora Diária (Percentual)..: " + Transform (nMora, "@E 999.99") + "%", oFont5, 100)
		oPrn:Say (0635 + _nAjuste,0010, "Valor Mora................:   " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont5, 100)
		
		If SE1->E1_DIADESC > 0.AND.nDescont > 0
		   oPrn:Say (0675 + _nAjuste,0010,"Valor Desconto............:   " + Alltrim (Transform (nDescont, "@E 99,999,999.99")) + " até o dia "+Dtoc(SE1->E1_VENCREA-SE1->E1_DIADESC), oFont5, 100)
		Endif   
		
		oPrn:Say (0715 + _nAjuste,0010, "O título será protestado 10 dias após o vencimento.", oFont5, 100)
		// *********************** Fim das "Instrucoes" ************************
		
		oPrn:Box (0400 + _nAjuste,1660,0800 + _nAjuste,1663) // Divisao Vertical entre as linhas 5 e 10
		oPrn:Say (0405 + _nAjuste,1670,"(-) Desconto/Abatimento", oFont1, 100)
		oPrn:Say (0440 + _nAjuste,1850,Transform (nAbatim, "@E@Z 999,999,999,999.99"), oFont4, 100)
		oPrn:Box (0480 + _nAjuste,1660,0483 + _nAjuste,2250) // Linha Horizontal 6
		
		oPrn:Box (0560 + _nAjuste,1660,0563 + _nAjuste,2250) // Linha Horizontal 7
		oPrn:Say (0565 + _nAjuste,1670,"(+) Mora/Multa", oFont1, 100)
		
		oPrn:Box (0640 + _nAjuste,1660,0643 + _nAjuste,2250) // Linha Horizontal 8
		
		oPrn:Box (0720 + _nAjuste,1660,0723 + _nAjuste,2250) // Linha Horizontal 9
		oPrn:Say (0725 + _nAjuste,1670,"(=) Valor Cobrado", oFont1, 100)
		
		oPrn:Box (0800 + _nAjuste,0000,0803 + _nAjuste,2250) // Linha Horizontal 10
		oPrn:Say (0805 + _nAjuste,0010,"Sacado:", oFont1, 100)
		oPrn:Say (0805 + _nAjuste,0260,SA1 -> (Alltrim (A1_NOME) + " - " + A1_COD + "/" + A1_LOJA), oFont4, 100)
		oPrn:Say (0845 + _nAjuste,0260,SA1 -> (Alltrim (A1_END)), oFont4, 100)
		oPrn:Say (0845 + _nAjuste,1200,SA1 -> (Alltrim (A1_BAIRRO)), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,0260,SA1 -> (Transform (A1_CEP, "@R 99999-999")), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,0520,SA1 -> (Alltrim (A1_MUN)), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,1200,SA1 -> (Alltrim (A1_EST)), oFont4, 100)
		oPrn:Say (0905 + _nAjuste,0010,"Sacador/Avalista", oFont1, 100) //945
		oPrn:Say (0905 + _nAjuste,1700,"Código de Baixa CVT:5539-5", oFont1, 100)
		
		oPrn:Box (0940 + _nAjuste,0000,0943 + _nAjuste,2250) // Linha Horizontal 11 980
		If _nCont == 1 .or. _nCont == 2
			oPrn:Say (0945 + _nAjuste,1700,"Autenticação Mecânica", oFont1, 100)
		ElseIf _nCont == 3
			oPrn:Say (0945 + _nAjuste,1550,"Autenticação Mecânica - Ficha de Compensação", oFont1, 100)
			If mv_par10 == 1	// Impressora Laser
				MsBar("INT25", 26.4, 0, sBarra, oPrn, .F., , .T., 0.026, 1.3, , , , .F.)
			Else				   // Impressora DeskJet
				MsBar("INT25", 13.5, 0, sBarra, oPrn, .F., , .T., 0.013, 0.8, , , , .F.)
			EndIf
		EndIf       
		
//-Parametros - Geracao Cod. Barras - Wederson 30/03/05
// 09 nWidth	Numero do Tamanho da barra em centimetros      
// 10 nHeigth	Numero da Altura da barra em milimetros        

		If _nCont == 1 
		   oPrn:Say (1040 + _nAjuste, 0000, Replicate ("- ", 75), oFont1, 100) //1080
		ElseIf _nCont == 2 
			oPrn:Say (1020 + _nAjuste, 0000, Replicate ("- ", 75), oFont1, 100) //1080
		EndIf
	Next
	nPag ++
	
	SE1->(dbSkip())
	If! SE1->(Eof()) .and. ( xFilial("SE1") == SE1->E1_FILIAL ;
	.and. SE1->E1_PREFIXO == Mv_Par01 .and. SE1->E1_NUM <= Mv_Par03)
		oPrn:EndPage ()
	EndIf
Enddo

oPrn:Setup ()	  // Para configurar impressora.
oPrn:Preview ()  // Exibe impressao em disco e permite enviar para a impressora.
// oPrn:Print () // Descomentar esta linha para imprimir diretamente para a impressora (sem tela).

Ms_Flush ()

oPrn:SaveAllAsJpeg ("\sigaadv\unibanco", 2048, 2048)

Return (.T.)

//------------------------------------------------------

Static Function CalcDig(cBase)

Local _nDigito, _cDigito
Local _cMult := "1212121212"

_nDigito := 0
_nCbase  := Len(cBase)                
_nTam    := Len(_cMult) 
While _nCbase > 0 
	 _nSoma   := Val(Subs(cBase,_nCbase,1)) * Val(Subs(_cMult,_nTam,1))
	 _nDigito += Val(SubStr(StrZero(_nSoma,2),1,1))+Val(SubStr(StrZero(_nSoma,2),2,1))
    _nCbase -=1  
    _nTam   -=1
End          

_nDigito := 10 - (_nDigito % 10)	// Calcula Modulo 10
_cDigito := Alltrim (Str (_nDigito))  

If _cDigito == "10"
	_cDigito := "0"
EndIf

Return (_cDigito)         

//--------------------------------------------

Static Function fCriaPerg()

aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0
aRegistros:={}
//               1      2    3                 4  5  6        7   8  9  1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegistros,{cPerg,"01","Prefixo           ","","","mv_ch1","C",03,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Do  Numero        ","","","mv_ch2","C",09,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Ate Numero        ","","","mv_ch3","C",09,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Da Parcela 	   ","","","mv_ch4","C",01,00,00,"G","","Mv_Par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Ate Parcela	   ","","","mv_ch5","C",01,00,00,"G","","Mv_Par05","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Banco   		   ","","","mv_ch6","C",03,00,00,"G","","Mv_Par06","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","",""})
AADD(aRegistros,{cPerg,"07","Agencia  		   ","","","mv_ch7","C",05,00,00,"G","","Mv_Par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"08","Conta    		   ","","","mv_ch8","C",10,00,00,"G","","Mv_Par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"09","SubConta 		   ","","","mv_ch9","C",03,00,00,"G","","Mv_Par09","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","Impressora	       ","","","mv_cha","N",01,00,00,"C","","Mv_Par10","Laser","","","","","Deskjet","","","","","","","","","","","","","","","","","","","","","",""})

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
