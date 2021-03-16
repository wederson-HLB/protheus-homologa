#include "rwmake.ch"

//----------------------------------------------------------------------------------------------------------------//
// José Ferreira               17/10/2005                                                                         //
// Pryor Technology - Adaptado para Eurosilicone em 04/01/11 por Vitor Bedin							                                                                           //
//----------------------------------------------------------------------------------------------------------------//
// Especifico Shiseido                                                                                               //  
// Financeiro - Emissao Boleto do banco ITAU.                                                                     //
//----------------------------------------------------------------------------------------------------------------//  

/*
Funcao      : 3URFIN01
Parametros  : 
Retorno     : 
Objetivos   : Emissao Boleto do banco ITAU. 
Autor       : José Ferreira - Adaptado para Eurosilicone em 04/01/11 por Vitor Bedin 
Data        : 04/01/11
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/ 

*------------------------*
 User Function 3URFIN01()  
*------------------------*

Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := "RFIN02    "
Private sBarra

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Prefixo                               ³
//³ mv_par02            // Do numero                             ³
//³ mv_par03            // Ateh o numero                         ³
//³ mv_par04            // Banco (Say)                           ³
//³ mv_par05            // Agencia                               ³
//³ mv_par06            // Conta + DAC                           ³
//³ mv_par07            // Sub Conta                             ³
//³ mv_par08            // Impressora                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cEmpAnt $ "3U"
   fCriaPerg()
   If Pergunte (cPerg,.T.)
	  Processa({||FokImp()},"Boleto ITAU")
   Endif
Else
    MsgInfo("Especifico Eurosilicone  ","A T E N C A O ")
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
Private oFont1     := TFont ():New ("Courier New", , 07, , .F., , , , , .f. )
Private oFont2     := TFont ():New ("Courier New", , 14, , .t., , , , , .f. )
Private oFont3     := TFont ():New ("Courier New", , 24, , .t., , , , .t., .f. )
Private oFont4     := TFont ():New ("Courier New", , 10, , .t., , , , , .f. )
Private oFont5     := TFont ():New ("Courier New", , 09, , .F., , , , , .f. )
Private oFont6     := TFont ():New ("Courier New", , 11, , .t., , , , , .f. )
Private oFont7     := TFont ():New ("Arial", , 16, , .f., , , , , .f. )	
Private oPrn       := TAvPrinter ():New ()
Private lContinua:= .T.

cBanco    := MV_PAR04
cAgencia  := mv_par05				
cConta    := mv_par06				
cSubConta := mv_par07				
cZeros	 := "000"
cBanco	 := "341"
cDigb		 := ""	
cDig1		 := ""	
cDig2		 := ""	
cDig3		 := ""	
cDig4		 := ""	

SEE->(dbSetOrder(1))
SEE->(dbGoTop())

NDigt  :="" 
cnum	 :=""
If ! SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta,.F.))
	MsgInfo ("Parametros do Banco/Agencia/Conta/Sub Conta nao encontrados." + Chr (13) + Chr (13) + "Por favor verifique.","A T E N C A O")
	Return
EndIf    

dbSelectArea ("SEE")
SEE->(dbGoTop())
SEE->(dbSetOrder(1))
SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta,.T.))
cContaEmp := SEE->EE_CODEMP

oPrn:Setup ()
cMoeda   := "9"								// Codigo da Moeda no Banco (sempre 9)

dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
dbSetOrder (1)
dbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

nCont    :=0

Do While !Eof().and.xFilial("SE1") == SE1->E1_FILIAL.and.lContinua ;
	.and.SE1->E1_PREFIXO == Mv_Par01 .and. SE1->E1_NUM <= Mv_Par03 .AND. !eof()
   
	nValTot  :=0
	nPisCofCs:=0  
	nValIr   :=0  
	nValIn   :=0
	oPrn:StartPage ()
	nCont ++             
	
	lOk:=.F.
	cNumTit:=SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
  	DbSelectArea("SE1")   
  	DbSetOrder(1)
  	While cNumTit == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
         If AllTrim(SE1->E1_TIPO) $ "CF-/CS-/PI-"
            nPisCofCs += SE1->E1_VALOR                              
         Endif   
         If AllTrim(SE1->E1_TIPO) $ "NF"
	         nValTot := SE1->E1_SALDO       	
            nValIr  := SE1->E1_IRRF	
	         nValIn  := SE1->E1_INSS
	         nMulta  :=0
	         nMora   :=SE1->E1_PORCJUR
	         nDescont:=(SE1->E1_SALDO*SE1->E1_DESCFIN)/100
	         cFatVenc:=StrZero(SE1->E1_VENCREA - ctod ("07/10/1997"), 4)//fator de vencimento -Anexo 6
	         //cTitulo :=SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
	         cTitulo :=SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA

	         dVencto :=SUBSTR(dtos(SE1->E1_VENCREA),7,2)+SUBSTR(dtos(SE1->E1_VENCREA),5,2)
	         dVencto +=SUBSTR(dtos(SE1->E1_VENCREA),1,4)
				dVencto :=Transform(dVencto, "@R 99/99/9999")

	         dEmissao:=SE1->E1_EMISSAO
	         SF2->(dbSetOrder(1))
	         SF2->(dbGoTop())
	         _cNFiscal := ""
	         If SF2->(dbSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA), .F.))
		         _cNFiscal := SF2->(F2_DOC+IIf(!Empty(SF2->F2_SERIE), "/" + F2_SERIE, ""))
	         EndIf
	
	         SA1->(dbSetOrder(1))
	         SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

	         If Empty(SE1->E1_NUMBCO)
	            RecLock("SE1",.F.)
	            Replace SE1->E1_NUMBCO  With StrZero(VAL(SEE->EE_FAXATU)+1,8)
	            SE1->(MsUnLock())
	            RecLock("SEE",.F.)	
	            Replace	SEE->EE_FAXATU  With StrZero(Val(SEE->EE_FAXATU)+1,8)
	            SEE->(MsUnlock())
	            cNumBco := SUBSTR(StrZero(Val(SE1->E1_NUMBCO),8),1,8)
	         Else
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
EndDo   
oPrn:Preview ()
Ms_Flush ()
Return

//----------------------------------

Static Function fImprime()

   _nValor := nValTot-nPisCofCs-nValIr-nValIn
   //nJuros  := Round (_nValor * (nMora/100), 2)
   nJuros  := Round( (_nValor/30)*(6/100),2)
    	
	// ********************************************************************************//
	// ******************** Inicio da Criacao do Codigo de Barras *********************//
	// ********************************************************************************//
	// Composicao do codigo de barras:                                                 //
	//                                                                                 //
	// 44 posicoes, sendo:                                                             //
	// 01 a 03	-	03	-	Código do Banco na Camara de Compensacao = "341"           //
	// 04 a 04	-	01	-	Código da Moeda = "9"                                      //
	// 05 a 05	-	01	-	DAC do Código de Barras (ANEXO 2)                          //
	// 06 a 09	-	04	-	Fator de Vencimento (Anexo 6)                              //
	// 10 a 19	-	10	-	Valor - Picture 9(08)V(02)                                 //
	// 20 a 22	-	02	-	Carteira                                                   //
	// 23 a 30	-	06	-	Nosso numero                                               //
	// 31 a 31	-	05	-	Dac[Agencia/c.c/Nosso Numero](Anexo 4)                     //
	// 32 a 35	-	11	-	Numero Agencia cedente                                     //
	// 36 a 40 	-	01	-	Numero Conta Corrente                                      //
	// 41 a 41 	-	01	-	Dac[Agencia/Conta corrente] (Anexo 3)                      //
	// 42 a 44 	-	01	-	zeros	                                                   //
    //*********************************************************************************//
	cNumero  := cNumBco	
	cValor   := StrZero(100*(_nValor), 14)

	CalcDig1() // Calcula digito do nosso numero  
	DigBarra() // Calcula digito do codigo de barras
	CalcDig2() // Calcula digito do campo 1 
	CalcDig3() // Calcula digito do campo 2
	CalcDig4() // Calcula digito do campo 3
	
	//----------------------------------------------//
	// Formação do codigo de Barras						//
	//----------------------------------------------//
	sBarra:= cBanco+cMoeda+Alltrim(cDigb)+cFatVenc+SUBSTR(cValor,5,14)+"109"+StrZero(val(cNumero),8)
	sBarra+=Alltrim(cDig1)+substr(cAgencia,1,4)+substr(cContaEmp,1,6)+Alltrim(cZeros)
	
	//----------------------------------------------// 
	// Formacao da linha digitavel:                 //
	//----------------------------------------------//

	sDigit  :=""              
	//sDigit1 :=cBanco+cMoeda+"109"+SUBSTR(cNumero,3,2)+Alltrim(cDig2)
	sDigit1 :=cBanco+cMoeda+"109"+SUBSTR(cNumero,1,2)+Alltrim(cDig2)  //vbm
	sDigit  :=ALLTRIM(sDigit1)
	//sDigit2 :=substr(cNumero,5,6)+Alltrim(cDig1)+substr(cAgencia,1,3)+Alltrim(cDig3) 
	sDigit2 :=substr(cNumero,3,6)+Alltrim(cDig1)+substr(cAgencia,1,3)+Alltrim(cDig3)  //VBM 10/05/10
	sDigit  +=Alltrim(sDigit2)
	sDigit3 :=substr(cAgencia,4,1)+substr(cContaEmp,1,6)+"000"+Alltrim(cDig4)
	sDigit  +=Alltrim(sDigit3)
	sDigit4 :=Alltrim(cDigb)+cFatVenc+SUBSTR(cValor,5,14)
	sDigit  +=Alltrim(sDigit4)
	sDigit  :=Transform(sDigit, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")

	// ********************************************************************************
	// ********************** Fim da Criacao da Linha Digitavel ***********************
	// ********************************************************************************
	
	For _nCont := 1 to 3
		If _nCont == 1
			_nAjuste := 0
		ElseIf _nCont == 2
			_nAjuste := 1060 
		ElseIf _nCont == 3
			_nAjuste := 2150 
		EndIf

//      oPrn:SayBitmap (0000 + _nAjuste,0010,"ITAU.bmp", 220, 070)
		oPrn:Say (0015 + _nAjuste,0005,"Banco Itaú SA",oFont5,100)
		oPrn:Box (0000 + _nAjuste,0290,0080 + _nAjuste,0293) // divisao  no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
		oPrn:Say (0005 + _nAjuste,0300,"341-7",oFont3,100)
		oPrn:Box (0000 + _nAjuste,0580,0080 + _nAjuste,0583) // divisao entre no. banco e texto "Recibo do Sacado"
		If _nCont == 1
			oPrn:Say (0015 + _nAjuste,1670,"Recibo do Sacado",oFont2,150)
		ElseIf _nCont == 3
			oPrn:Say (0015 + _nAjuste,0600, sDigit, oFont7, 100)
		EndIf

		oPrn:Box (0080 + _nAjuste,0000,0083 + _nAjuste,2250) // Linha Horizontal 1
		oPrn:Say (0085 + _nAjuste,0010,"Local de Pagamento", oFont1, 100)
		oPrn:Say (0085 + _nAjuste,0350,"Até o vencimento, preferencialmente no Itaú", oFont4, 100)
		oPrn:Say (0115 + _nAjuste,0350,"Após o vencimento, somente no Itaú ", oFont4, 100)
		oPrn:Say (0120 + _nAjuste,0350,"", oFont4, 100)
		oPrn:Box (0080 + _nAjuste,1660,0160 + _nAjuste,1663) // Divisao entre "Loc. Pag." e "Venc."
		oPrn:Say (0085 + _nAjuste,1670,"Vencimento",oFont1,100)
		oPrn:Say (0120 + _nAjuste,2000,dVencto, oFont4, 100)

		oPrn:Box (0160 + _nAjuste,0000,0163 + _nAjuste,2250) // Linha Horizontal 2
		oPrn:Say (0165 + _nAjuste,0010,"Cedente", oFont1, 100)

		oPrn:Say (0195 + _nAjuste,0010,"EUROSILICONE BRASIL IMPORT E EXPORT LTDA", oFont4, 100)

		oPrn:Box (0160 + _nAjuste,1660,0240 + _nAjuste,1663) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
		oPrn:Say (0165 + _nAjuste,1670,"Agência/Código Cedente",oFont1,100)
		oPrn:Say (0195 + _nAjuste,1960,AllTrim(cAgencia) + "/"+Substr(cContaEmp,1,5)+"-"+Substr(cContaEmp,6,1), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0000,0243 + _nAjuste,2250) // Linha Horizontal 3
		oPrn:Say (0245 + _nAjuste,0010,"Data do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0010,dtoc(dEmissao), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0350,0320 + _nAjuste,0353) // Divisao entre "Data do Doc." e "No. Doc."
		oPrn:Say (0245 + _nAjuste,0360,"Nº do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0360,cTitulo, oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0770,0320 + _nAjuste,0773) // Divisao entre "No. Doc." e "Espec. Doc."
		oPrn:Say (0245 + _nAjuste,0780,"Espécie Doc.", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0780,"DM", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1060,0320 + _nAjuste,1063) // Divisao entre "Espec. Doc." e "Aceite"
		oPrn:Say (0245 + _nAjuste,1070,"Aceite", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1070,"", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1240,0320 + _nAjuste,1243) // Divisao entre "Aceite" e "Data Proc."
		oPrn:Say (0245 + _nAjuste,1250,"Data do Processamento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1250,dtoc (dDataBase), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1660,0320 + _nAjuste,1663) // Divisao entre "Data Proc.." e "Cart./N.Num."
		oPrn:Say (0245 + _nAjuste,1660,"Cart./Nosso Número",oFont1,100)
		oPrn:Say (0275 + _nAjuste,1880,Space(02)+"109/"+SUBSTR(cNumero,1,8)+"-"+Alltrim(cDig1), oFont4, 100)

		oPrn:Box (0320 + _nAjuste,0000,0323 + _nAjuste,2250) // Linha Horizontal 4
		oPrn:Say (0325 + _nAjuste,0010,"Uso do Banco", oFont1, 100)
		oPrn:Say (0360 + _nAjuste,0010,"", oFont4, 100)
		oPrn:Box (0320 + _nAjuste,0350,0400 + _nAjuste,0353) // Divisao entre "Uso do Banco" e "Carteira"
		oPrn:Say (0325 + _nAjuste,0360,"Carteira", oFont1, 100)
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
		oPrn:Say (0355 + _nAjuste,1830,Transform (_nValor, "@E 999,999,999,999.99"), oFont4, 100)

		oPrn:Box (0400 + _nAjuste,0000,0403 + _nAjuste,2250) // Linha Horizontal 5
		oPrn:Say (0405 + _nAjuste,0010,"Instruções (Todas as informações deste bloqueto são de exclusiva responsabilidade do cedente)", oFont1, 100)
		
		// *********************** Início das "Instrucoes" *********************
		If ! Empty (_cNFiscal)
			oPrn:Say (0465 + _nAjuste,0010,"Nota Fiscal/Série", oFont5, 100)
			oPrn:Say (0505 + _nAjuste,0010,_cNFiscal, oFont1, 100)
		EndIf    
		
		oPrn:Say (0555 + _nAjuste,0010, "Multa (Percentual)........: 3,00%", oFont5, 100)
		oPrn:Say (0595 + _nAjuste,0010, "Mora Diária (Percentual)..: 0,10%", oFont5, 100)
		oPrn:Say (0635 + _nAjuste,0010, "Valor Mora................:   " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont5, 100)
		
		
		If SE1->E1_DIADESC > 0.AND.nDescont > 0
		   oPrn:Say (0675 + _nAjuste,0010,"Valor Desconto............:   " + Alltrim (Transform (nDescont, "@E 99,999,999.99")) + " até o dia "+Dtoc(SE1->E1_VENCREA-SE1->E1_DIADESC), oFont5, 100)
		Endif   
		
	    oPrn:Say (0715 + _nAjuste,0010, "O título será protestado 10 dias após o vencimento.", oFont5, 100)   
	    
	    //	If nJuros > 0
	    //	   oPrn:Say (0555 + _nAjuste,0010, "APÓS O VENCIMENTO COBRAR JUROS DE R$ " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont5, 100)
	   //	   oPrn:Say (0655 + _nAjuste,0010, "ENVIAR AO CARTORIO 5º DIA DO VENCIMENTO", oFont5, 100)
	   //	Endif   

		// *********************** Fim das "Instrucoes" ************************

		oPrn:Box (0400 + _nAjuste,1660,0800 + _nAjuste,1663) // Divisao Vertical entre as linhas 5 e 10
		oPrn:Say (0405 + _nAjuste,1670,"(-) Desconto/Abatimento", oFont1, 100)
//		oPrn:Say (0440 + _nAjuste,1850,Transform (nAbatim, "@E@Z 999,999,999,999.99"), oFont4, 100)  //NAO USADO NA PRYOR
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
		oPrn:Say (0905 + _nAjuste,1700,"Código de Baixa ", oFont1, 100)

		oPrn:Box (0940 + _nAjuste,0000,0943 + _nAjuste,2250) // Linha Horizontal 11 980
		If _nCont == 1 .or. _nCont == 2
			oPrn:Say (0945 + _nAjuste,1700,"Autenticação Mecânica", oFont1, 100)
		ElseIf _nCont == 3
			oPrn:Say (0945 + _nAjuste,1550,"Autenticação Mecânica - Ficha de Compensação", oFont1, 100)

			If mv_par08 == 1	
				MsBar("INT25", 27.7, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
			ElseIF mv_par08 == 2					   
				MsBar("INT25", 13.8, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.013, 0.8, , , , .F.)
			ElseIF mv_par08 == 3					   
				MsBar("INT25", 26.4, 0, Alltrim(sBarra), oPrn, .F., , .T., 0.026, 1.4, , , , .F.)
			EndIf
		EndIf       

		If _nCont == 1 
		   oPrn:Say (1040 + _nAjuste, 0000, Replicate ("- ", 75), oFont1, 100) //1080
		ElseIf _nCont == 2 
			oPrn:Say (1020 + _nAjuste, 0000, Replicate ("- ", 75), oFont1, 100) //1080
		EndIf
	Next

	nPag ++
oPrn:EndPage ()	

Return 

//------------------------------------------------------//
// Anexo 2 - Calcula DAC do codigo de Barras            //
//------------------------------------------------------//

Static Function DigBarra()       

	dBarra:= cBanco+cMoeda+cFatVenc+SUBSTR(cValor,5,14)+"109"+StrZero(val(cNumero),8)
	dBarra+=Alltrim(cDig1)+substr(cAgencia,1,4)+substr(cContaEmp,1,6)+Alltrim(cZeros)
	cStrMult  := "4329876543298765432987654329876543298765432"
	_nTam     :=Len(cStrMult)
	_nBarra   :=Len(Alltrim(dBarra))
	nBaseDiv  := 0
   While _nBarra > 0
		nBaseDiv += Val(SubStr(Alltrim(dBarra),_nBarra,1)) * Val(SubStr(cStrMult,_nTam,1))
	   _nTam   -=1
	   _nBarra -=1
	End         
	nResto  := nBaseDiv % 11
	cResto  := Alltrim (Str(11-nResto))               

	If cResto $ "0/10/11/"
		cResto := "1"
	EndIf  

	cDigb:=cResto

Return

//------------------------------------------------------//
// anexo 3 - Calcula DAC campo 1		                    //
//------------------------------------------------------//
Static Function CalcDig2()  

Local _nDigito, _cDigito
Local _cMult := "212121212"

nSoma1	:=0
nResto1	:=0
nResto	:=0
_nTam :=Len(_cMult)
nLinBlo2:=cBanco+"9"+"109"+SUBSTR(cNumBco,1,2)
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
   cDig2 := "0"
Else
   cDig2:=STR(nresto)
Endif	


Return 

//------------------------------------------------------//
// anexo 3 - Calcula DAC campo 2		                    //
//------------------------------------------------------//

Static Function CalcDig3()       

Local _nDigito, _cDigito
Local _cMult := "1212121212"
nSoma1	:=0
nResto1	:=0
nResto	:=0
_nTam :=Len(_cMult)
//nLinBlo3:=StrZero(val(substr(cNumero,5,6)),6)+Alltrim(cDig1)+substr(cAgencia,1,3) 
nLinBlo3:=StrZero(val(substr(cNumero,3,6)),6)+Alltrim(cDig1)+substr(cAgencia,1,3)  //vbm
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
   cDig3 := "0"
Else
   cDig3:=STR(nresto)
Endif	

Return 
//------------------------------------------------------//
// anexo 3 - Calcula DAC campo 3		                    //
//------------------------------------------------------//
Static Function CalcDig4()       

Local _nDigito, _cDigito
Local _cMult := "1212121212"
nSoma1	:=0
nResto1	:=0
nResto	:=0
_nTam :=Len(_cMult)
nLinBlo3:=substr(cAgencia,4,1)+substr(cContaEmp,1,6)+"000"
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
   cDig4 := "0"
Else
   cDig4:=STR(nresto)
Endif	

Return 
//------------------------------------------------------//
// anexo 4 - Calcula DAC Nosso Numero                   //
//------------------------------------------------------//
Static Function CalcDig1()    

Local _nDigito, _cDigito
Local _cMult := "12121212121212121212"

nResto:= 0
nSoma1:=0
_nTam :=Len(_cMult)
//nLinBlo:=substr(cAgencia,1,4)+Alltrim(SUBSTR(cContaEmp,1,5))+"109"+SUBSTR(cNumBco,3,8)
nLinBlo:=substr(cAgencia,1,4)+Alltrim(SUBSTR(cContaEmp,1,5))+"109"+SUBSTR(cNumBco,1,8)  //vbm
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
   cDig1 := "0"
Else
   cDig1:=STR(nresto)
Endif	

Return 

//--------------------------------------------------------//
//             CRIA PERGUNTA                              //
//--------------------------------------------------------//
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
