#include "rwmake.ch"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"

/*
Funcao      : R7RFIN02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emissao Boleto do banco ITAU.  
Autor     	: Jos� Ferreira                            
Data     	: 17/10/2005                     
Obs         : Adaptado para Shiseido em 08/09/10 por Vitor Bedin
TDN         : 
Revis�o     : Tiago Luiz Mendon�a	
Data/Hora   : 17/07/12
M�dulo      : Financeiro. 
Cliente     : Shiseido
*/

*------------------------*
 User Function R7RFIN02()
*------------------------*

Private aReturn    := {OemToAnsi ('Zebrado'), 1, OemToAnsi ('Administracao'), 2, 2, 1, '', 1}
Private nLastKey   := 0
Private cPerg      := "RFIN02    "
Private sBarra

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Prefixo                               �
//� mv_par02            // Do numero                             �
//� mv_par03            // Ateh o numero                         �
//� mv_par04            // Banco (Say)                           �
//� mv_par05            // Agencia                               �
//� mv_par06            // Conta + DAC                           �
//� mv_par07            // Sub Conta                             �
//� mv_par08            // Impressora                            �
//����������������������������������������������������������������

If cEmpAnt $ "R7"
   fCriaPerg()
   If Pergunte (cPerg,.T.)
	  Processa({||FokImp()},"Boleto ITAU")
   Endif
Else
    MsgInfo("Especifico Shiseido  ","A T E N C A O ")
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
   nJuros  := Round( ((_nValor)*(3/100))/30,2)//AOA - 03/10/2016 - Alterado percentual de juros e multa //AOA - 27/11/2017 - Alterado percentual
   nMulta  := Round( ((_nValor)*(2/100)),2)//AOA - 27/11/2017 - Valor de multa
    	
	// ********************************************************************************//
	// ******************** Inicio da Criacao do Codigo de Barras *********************//
	// ********************************************************************************//
	// Composicao do codigo de barras:                                                 //
	//                                                                                 //
	// 44 posicoes, sendo:                                                             //
	// 01 a 03	-	03	-	C�digo do Banco na Camara de Compensacao = "341"           //
	// 04 a 04	-	01	-	C�digo da Moeda = "9"                                      //
	// 05 a 05	-	01	-	DAC do C�digo de Barras (ANEXO 2)                          //
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
	// Forma��o do codigo de Barras						//
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
			_nAjuste := 100
		ElseIf _nCont == 2
			_nAjuste := 1110 
		ElseIf _nCont == 3
			_nAjuste := 2160 
		EndIf
		_nColun  := 140
		
//      oPrn:SayBitmap (0000 + _nAjuste,0010,"ITAU.bmp", 220, 070)
		oPrn:Say (0015 + _nAjuste,0005 + _nColun,"Banco Ita� SA",oFont5,100)
		oPrn:Box (0000 + _nAjuste,0290 + _nColun,0080 + _nAjuste,0290 + _nColun) // divisao  no. banco	// LinhaIni, ColunaIni, LinhaFim, ColunaFim
		oPrn:Say (0005 + _nAjuste,0300 + _nColun,"341-7",oFont3,100)
		oPrn:Box (0000 + _nAjuste,0580 + _nColun,0080 + _nAjuste,0580 + _nColun) // divisao entre no. banco e texto "Recibo do Sacado"
		If _nCont == 1
			oPrn:Say (0015 + _nAjuste,1670,"Recibo do Sacado",oFont2,150)
		ElseIf _nCont == 3
			oPrn:Say (0015 + _nAjuste,0600 + _nColun, sDigit, oFont7, 100)
		EndIf

		oPrn:Box (0080 + _nAjuste,0000 + _nColun,0083 + _nAjuste,2250) // Linha Horizontal 1
		oPrn:Say (0085 + _nAjuste,0010 + _nColun,"Local de Pagamento", oFont1, 100)
		oPrn:Say (0085 + _nAjuste,0350 + _nColun,"At� o vencimento, preferencialmente no Ita�", oFont4, 100)
		oPrn:Say (0115 + _nAjuste,0350 + _nColun,"Ap�s o vencimento, somente no Ita� ", oFont4, 100)
		oPrn:Say (0120 + _nAjuste,0350 + _nColun,"", oFont4, 100)
		oPrn:Box (0080 + _nAjuste,1660 + _nColun,0160 + _nAjuste + _nColun,1663 + _nColun) // Divisao entre "Loc. Pag." e "Venc."
		oPrn:Say (0085 + _nAjuste,1670 + _nColun,"Vencimento",oFont1,100)
		oPrn:Say (0120 + _nAjuste,2000,dVencto, oFont4, 100)

		oPrn:Box (0160 + _nAjuste,0000 + _nColun,0163 + _nAjuste,2250) // Linha Horizontal 2
		oPrn:Say (0165 + _nAjuste,0010 + _nColun,"Cedente", oFont1, 100)

		oPrn:Say (0195 + _nAjuste,0010 + _nColun,"Shiseido do Brasil Ltda", oFont4, 100)

		oPrn:Box (0160 + _nAjuste,1660 + _nColun,0240 + _nAjuste,1663 + _nColun) // Divisao entre "Cedente" e "Agencia/Codigo Cedente"
		oPrn:Say (0165 + _nAjuste,1670 + _nColun,"Ag�ncia/C�digo Cedente",oFont1,100)
		oPrn:Say (0195 + _nAjuste,1960,AllTrim(cAgencia) + "/"+Substr(cContaEmp,1,5)+"-"+Substr(cContaEmp,6,1), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0000 + _nColun,0243 + _nAjuste,2250) // Linha Horizontal 3
		oPrn:Say (0245 + _nAjuste,0010 + _nColun,"Data do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0010 + _nColun,dtoc(dEmissao), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0350 + _nColun,0320 + _nAjuste,0353 + _nColun) // Divisao entre "Data do Doc." e "No. Doc."
		oPrn:Say (0245 + _nAjuste,0360 + _nColun,"N� do Documento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0360 + _nColun,cTitulo, oFont4, 100)
		oPrn:Box (0240 + _nAjuste,0770 + _nColun,0320 + _nAjuste ,0770 + _nColun) // Divisao entre "No. Doc." e "Espec. Doc."
		oPrn:Say (0245 + _nAjuste,0780 + _nColun,"Esp�cie Doc.", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,0780 + _nColun,"DM", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1060 + _nColun,0320 + _nAjuste ,1063 + _nColun) // Divisao entre "Espec. Doc." e "Aceite"
		oPrn:Say (0245 + _nAjuste,1070 + _nColun,"Aceite", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1070 + _nColun,"", oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1240 + _nColun,0320 + _nAjuste,1243 + _nColun) // Divisao entre "Aceite" e "Data Proc."
		oPrn:Say (0245 + _nAjuste,1250 + _nColun,"Data do Processamento", oFont1, 100)
		oPrn:Say (0275 + _nAjuste,1250 + _nColun,dtoc (dDataBase), oFont4, 100)
		oPrn:Box (0240 + _nAjuste,1660 + _nColun,0320 + _nAjuste ,1663 + _nColun) // Divisao entre "Data Proc.." e "Cart./N.Num."
		oPrn:Say (0245 + _nAjuste,1660 + _nColun,"Cart./Nosso N�mero",oFont1,100)
		oPrn:Say (0275 + _nAjuste,1880,Space(02)+"109/"+SUBSTR(cNumero,1,8)+"-"+Alltrim(cDig1), oFont4, 100)

		oPrn:Box (0320 + _nAjuste,0000 + _nColun,0323 + _nAjuste,2250) // Linha Horizontal 4
		oPrn:Say (0325 + _nAjuste,0010 + _nColun,"Uso do Banco", oFont1, 100)
		oPrn:Say (0360 + _nAjuste,0010 + _nColun,"", oFont4, 100)
		oPrn:Box (0320 + _nAjuste,0350 + _nColun,0400 + _nAjuste,0353 + _nColun) // Divisao entre "Uso do Banco" e "Carteira"
		oPrn:Say (0325 + _nAjuste,0360 + _nColun,"Carteira", oFont1, 100)
		oPrn:Box (0320 + _nAjuste,0550 + _nColun,0400 + _nAjuste,0553 + _nColun) // Divisao entre "Carteira" e "Esp�cie Moeda"
		oPrn:Say (0325 + _nAjuste,0560 + _nColun,"Espec. Moeda", oFont1, 100)
		oPrn:Say (0360 + _nAjuste,0630 + _nColun,"R$", oFont4, 100)
		oPrn:Box (0320 + _nAjuste,0770 + _nColun,0400 + _nAjuste,0773 + _nColun) // Divisao entre "Espe�cie Moeda" e "Quantidade"
		oPrn:Say (0325 + _nAjuste,0780 + _nColun,"Quantidade", oFont1, 100)
		oPrn:Box (0320 + _nAjuste,1240 + _nColun,0400 + _nAjuste,1243 + _nColun) // Divisao entre "Quantidade" e "Valor"
		oPrn:Say (0350 + _nAjuste,1100 + _nColun,"X", oFont4, 100)
		oPrn:Say (0325 + _nAjuste,1250 + _nColun,"Valor", oFont1, 100)
		oPrn:Box (0320 + _nAjuste,1660 + _nColun,0400 + _nAjuste,1663 + _nColun) // Divisao entre "Valor" e "Valor do Doc."
		oPrn:Say (0325 + _nAjuste,1670 + _nColun,"(=) Valor do Documento",oFont1,100)
		oPrn:Say (0355 + _nAjuste,1830,Transform (_nValor, "@E 999,999,999,999.99"), oFont4, 100)

		oPrn:Box (0400 + _nAjuste,0000 + _nColun,0403 + _nAjuste,2250) // Linha Horizontal 5
		oPrn:Say (0405 + _nAjuste,0010 + _nColun,"Instru��es (Todas as informa��es deste bloqueto s�o de exclusiva responsabilidade do cedente)", oFont1, 100)
		
		// *********************** In�cio das "Instrucoes" *********************
		If ! Empty (_cNFiscal)
			oPrn:Say (0465 + _nAjuste,0010 + _nColun,"Nota Fiscal/S�rie", oFont5, 100)
			oPrn:Say (0505 + _nAjuste,0010 + _nColun,_cNFiscal, oFont1, 100)
		EndIf    
		
		//AOA - 03/10/2016 - Alterado percentual de juros e multa //AOA - 27/11/2017 - alterado percentual de multa e juros
		//oPrn:Say (0555 + _nAjuste,0010, "Multa (Percentual)........: 2,00% ", oFont5, 100)
		//oPrn:Say (0595 + _nAjuste,0010, "Mora (Percentual).........: 3,00% a.m.", oFont5, 100)
		oPrn:Say (0595 + _nAjuste,0010 + _nColun, "Ap�s vencimento cobrar multa de: " + Alltrim (Transform (nMulta, "@E 99,999,999.99")), oFont5, 100)
		oPrn:Say (0635 + _nAjuste,0010 + _nColun, "Mora Di�ria de: " + Alltrim (Transform (nJuros, "@E 99,999,999.99")), oFont5, 100)
		
		
		If SE1->E1_DIADESC > 0.AND.nDescont > 0
		   oPrn:Say (0675 + _nAjuste,0010 + _nColun,"Valor Desconto............:   " + Alltrim (Transform (nDescont, "@E 99,999,999.99")) + " at� o dia "+Dtoc(SE1->E1_VENCREA-SE1->E1_DIADESC), oFont5, 100)
		Endif   
		
	    oPrn:Say (0715 + _nAjuste,0010 + _nColun, "O t�tulo ser� protestado ap�s 30 dias do vencimento.", oFont5, 100)   
	    
	    //	If nJuros > 0
	    //	   oPrn:Say (0555 + _nAjuste,0010, "AP�S O VENCIMENTO COBRAR JUROS DE R$ " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont5, 100)
	   //	   oPrn:Say (0655 + _nAjuste,0010, "ENVIAR AO CARTORIO 5� DIA DO VENCIMENTO", oFont5, 100)
	   //	Endif   

		// *********************** Fim das "Instrucoes" ************************

		oPrn:Box (0400 + _nAjuste,1660 + _nColun,0800 + _nAjuste,1663 + _nColun) // Divisao Vertical entre as linhas 5 e 10
		oPrn:Say (0405 + _nAjuste,1670 + _nColun,"(-) Desconto/Abatimento", oFont1, 100)
//		oPrn:Say (0440 + _nAjuste,1850,Transform (nAbatim, "@E@Z 999,999,999,999.99"), oFont4, 100)  //NAO USADO NA PRYOR
		oPrn:Box (0480 + _nAjuste,1660 + _nColun,0483 + _nAjuste,2250) // Linha Horizontal 6
		
		oPrn:Box (0560 + _nAjuste,1660 + _nColun,0563 + _nAjuste,2250) // Linha Horizontal 7
		oPrn:Say (0565 + _nAjuste,1670 + _nColun,"(+) Mora/Multa", oFont1, 100)
		
		oPrn:Box (0640 + _nAjuste,1660 + _nColun,0643 + _nAjuste,2250) // Linha Horizontal 8
		
		oPrn:Box (0720 + _nAjuste,1660 + _nColun,0723 + _nAjuste,2250) // Linha Horizontal 9
		oPrn:Say (0725 + _nAjuste,1670 + _nColun,"(=) Valor Cobrado", oFont1, 100)
		
		oPrn:Box (0800 + _nAjuste,0000 + _nColun,0803 + _nAjuste,2250) // Linha Horizontal 10
		oPrn:Say (0805 + _nAjuste,0010 + _nColun,"Sacado:", oFont1, 100)
		oPrn:Say (0805 + _nAjuste,0260 + _nColun,SA1 -> (Alltrim (A1_NOME) + " - " + A1_COD + "/" + A1_LOJA), oFont4, 100)
		oPrn:Say (0845 + _nAjuste,0260 + _nColun,SA1 -> (Alltrim (A1_END)), oFont4, 100)
		oPrn:Say (0845 + _nAjuste,1200 + _nColun,SA1 -> (Alltrim (A1_BAIRRO)), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,0260 + _nColun,SA1 -> (Transform (A1_CEP, "@R 99999-999")), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,0520 + _nColun,SA1 -> (Alltrim (A1_MUN)), oFont4, 100)
		oPrn:Say (0885 + _nAjuste,1200 + _nColun,SA1 -> (Alltrim (A1_EST)), oFont4, 100)
		oPrn:Say (0905 + _nAjuste,0010 + _nColun,"Sacador/Avalista", oFont1, 100) //945
		oPrn:Say (0905 + _nAjuste,1700 + _nColun,"C�digo de Baixa ", oFont1, 100)

		oPrn:Box (0940 + _nAjuste,0000 + _nColun,0943 + _nAjuste,2250) // Linha Horizontal 11 980
		If _nCont == 1 .or. _nCont == 2
			oPrn:Say (0945 + _nAjuste,1700 + _nColun,"Autentica��o Mec�nica", oFont1, 100)
		ElseIf _nCont == 3
			oPrn:Say (0945 + _nAjuste,1550 + _nColun,"Autentica��o Mec�nica - Ficha de Compensa��o", oFont1, 100)

			If mv_par08 == 1	
				MsBar("INT25", 25.7, 1.5, Alltrim(sBarra), oPrn, .F., , .T., 0.027, 1.4, , , , .F.)
			ElseIF mv_par08 == 2					   
				MsBar("INT25", 13.8, 1.5, Alltrim(sBarra), oPrn, .F., , .T., 0.014, 0.8, , , , .F.)
			ElseIF mv_par08 == 3					   
				MsBar("INT25", 26.5, 1.5, Alltrim(sBarra), oPrn, .F., , .T., 0.027, 1.4, , , , .F.)
			EndIf
		EndIf       

		If _nCont == 1 
		   oPrn:Say (1000 + _nAjuste, 0000 + _nColun, Replicate ("- ", 75), oFont1, 100) //1080
		ElseIf _nCont == 2 
			oPrn:Say (1020 + _nAjuste, 0000 + _nColun, Replicate ("- ", 75), oFont1, 100) //1080
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
