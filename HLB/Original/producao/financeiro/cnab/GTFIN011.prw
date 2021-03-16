#Include "rwmake.ch"    

/*
Funcao      : GTFIN011
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento de cnab Bradesco 500 contas pagar
Autor		: Anderson Arrais
Data/Hora   : 23/11/2015
MСdulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN011(nOpc)   
*------------------------------*   
Local cRet := 0
Local nBar := U_GTFIN007() //codigo de barras ja com 44 digitos
Local nBanco,nMULT,nRESUL,nRESTO,nDIGITO,nDIG1,nDIG2,nDIG3,nDIG4 := 0
Local nDIG5,nDIG6,nDIG7,nMod := 0
Local xAgencia,xCtaCed,xRETDIG,xNPOSDV := ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSepara o banco do codigo de baras 				   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 1 
	If SUBSTR(nBar,1,3) == ''
		cRet := SUBSTR(SA2->A2_BANCO,1,3)
	Else
		cRet := SUBSTR(nBar,1,3)
	EndIf
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValidar e separar agencia do codigo de barras	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 2 
	nBanco 	 := SUBSTR(nBar,1,3)

	If nBanco == "237"	// BRADESCO
		xAgencia  := "0" + SUBSTR(nBar,20,4)

		xRETDIG := " "
		nDIG1   := SUBSTR(nBar,20,1)
		nDIG2   := SUBSTR(nBar,21,1)
		nDIG3   := SUBSTR(nBar,22,1)
		nDIG4   := SUBSTR(nBar,23,1)

		nMULT   := (VAL(nDIG1)*5) +  (VAL(nDIG2)*4) +  (VAL(nDIG3)*3) +   (VAL(nDIG4)*2)
		nRESUL  := INT(nMULT /11 )
		nRESTO  := INT(nMULT % 11)
		nDIGITO := 11 - nRESTO

		xRETDIG := IF( nRESTO == 0,"0",IF(nRESTO == 1,"0",ALLTRIM(STR(nDIGITO))))

		cRet:= xAgencia + xRETDIG

	ElseIf nBanco <> '' //AOA - 09/05/2016 - Ajuste na validaГЦo do cСdigo de barras.
		cRet := "000000"
	Else
		If SUBSTR(SA2->A2_BANCO,1,3) $ "237"
			cRet := STRZERO(VAL(SA2->A2_AGENCIA),6)
		Else
			cRet := STRZERO(VAL(SA2->A2_AGENCIA),5)+"0"//AOA - 30/06/2016 - Ajuste no digito verificador da agencia.
	    EndIf
	EndIf
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValidar e separar C/C do codigo de barras	 	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 3 
	nBanco := SUBSTR(nBar,1,3)
	
	If nBanco == "237"	// BRADESCO
		xCtaCed  :=  STRZERO(VAL(SUBSTR(nBar,37,7)),13,0)
		
		xRETDIG := " "
		nDIG1   := SUBSTR(nBar,37,1)
		nDIG2   := SUBSTR(nBar,38,1)
		nDIG3   := SUBSTR(nBar,39,1)
		nDIG4   := SUBSTR(nBar,40,1)
		nDIG5   := SUBSTR(nBar,41,1)
		nDIG6   := SUBSTR(nBar,42,1)
		nDIG7   := SUBSTR(nBar,43,1)
		
		nMULT   := (VAL(nDIG1)*2) +  (VAL(nDIG2)*7) +  (VAL(nDIG3)*6) +   (VAL(nDIG4)*5) +  (VAL(nDIG5)*4) +  (VAL(nDIG6)*3)  + (VAL(nDIG7)*2)
		nRESUL  := INT(nMULT /11 )
		nRESTO  := INT(nMULT % 11)
		nDIGITO := STRZERO((11 - nRESTO),1,0)

		xRETDIG := IF( nRESTO == 0,"0",IF(nRESTO == 1,"P",nDIGITO))

		cRet := xCtaCed + xRETDIG
	   
	ElseIf nBanco <> ''
		cRet := "000000000000000"
	Else
		If SA2->A2_BANCO <> "399"
			cRet := cValToChar(STRZERO(VAL(SUBSTR(SA2->A2_NUMCON,1)),14,0)) + SPACE(1)
		Else 
			cRet := STRZERO(VAL(SUBSTR(SA2->A2_NUMCON,1)),15,0)
		EndIf
	EndIf
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSeleciona a carteira de acordo com o banco	 	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 4 
	If SUBS(nBar,1,3) != "237"
		cRet := "000"
	Else
		cRet := "0" + SUBS(nBar,24,2)
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSeleciona o ano do nosso numero CNAB			 	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 5 
	If SUBS(nBar,1,3) != "237"
	   cRet := "000000000000"
	Else
	   cRet := "0" + SUBS(nBar,26,11)
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValor do documento do codigo de barras ou saldo	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 6 
	If SUBSTR(nBar,1,3) == ''
	   cRet := STRZERO(((SE2->E2_SALDO)*100),15,0)
	Else
	   cRet 	:= "0" + SUBSTR(nBar,6,4) + SUBSTR(nBar,10,10)
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁInformacao complementar							   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 7 
	nMod := SUBSTR(SEA->EA_MODELO,1,2)
	DO CASE
	   CASE nMod == "03" .OR. nMod == "07" .OR. nMod == "08" .OR. nMod == "41"
			cRet := IIF(SA2->A2_CGC==SM0->M0_CGC,"D","C")+"000000"+"01"+"01"+SPACE(29)
	   CASE nMod == "31"
			cRet := SUBSTR(nBar,20,25)+SUBSTR(nBar,5,1)+SUBSTR(nBar,4,1)+SPACE(13)
	   CASE nMod == "30"
			cRet := SPACE(25)+"0"+SUBSTR(SM0->M0_CGC,1,14)
	   OTHERWISE
			cRet := SPACE(40)
	ENDCASE
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValidar e posicionar CNPJ ou CPF no arquivo		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 8 
	If SA2->A2_TIPO <> "J" 
		cRet := Left(SA2->A2_CGC,9)+"0000"+Substr(SA2->A2_CGC,10,2)
	Else 
		cRet := "0"+Left(SA2->A2_CGC,8)+Substr(SA2->A2_CGC,9,4)+Right(SA2->A2_CGC,2)
	Endif
		
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValidar data limete para desconto quando houver	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 9 
	If SE2->E2_DECRESC > 0        
		cRet := GRAVADATA(SE2->E2_VENCREA,.F.,8)
	Else 
		cRet := REPL("0",8)
	Endif
		
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValida se carregar decrecimo 						Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 10 
	If SUBSTR(nBar,1,3) == ''
	   cRet := STRZERO(SE2->E2_DECRESC*100,15)
	Else
	   cRet 	:= REPL("0",15)
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValida se carregar acrecimo 						Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 11 
	If SUBSTR(nBar,1,3) == ''
	   cRet := STRZERO(SE2->E2_ACRESC*100,15)
	Else
	   cRet 	:= REPL("0",15)
	EndIf
EndIf

Return(cRet)