#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"     

#DEFINE DS_MODALFRAME   128

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³															   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±³           ³ 														   ³±±
±±³           ³ Sandro Silva -EZ4 - 16/09/2020  						   ³±±
±±³           ³ 														   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß   
/*/

/*
Funcao      : LNFIN002 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco Santander com Codigo de Barras, Linha Digitavel e Nosso Numero. Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.
Autor     	: Sandro Silva -EZ4 -  
Data     	: 16/09/2020  
*/

*---------------------------------------------*
  USER FUNCTION LNFIN002(cSerie,cNota,cPasta)   
*---------------------------------------------*
Local lExec         := .T.

dbSelectArea("SE1")

If !cEmpAnt $ "LN"
   MsgInfo("Especifico NeoGen, verifique a empresa!","A T E N C A O ")
   return
Endif

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf

BeginSql Alias 'SQL'

	SELECT E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
	FROM %table:SE1%
	WHERE %notDel%
	  AND E1_FILIAL = %xfilial:SE1%
	  AND E1_SALDO > 0
	  AND E1_PREFIXO = %exp:cSerie% 
	  AND E1_NUM     = %exp:cNota% 
	  AND E1_TIPO = 'NF'
	ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO
EndSql
SQL->(dbGoTop())

If SQL->(EOF()) .or. SQL->(BOF())
	lExec := .F.
EndIf

If lExec
	MontaRel(cPasta)
Endif

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MONTAREL()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
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
STATIC FUNCTION MontaRel(cPasta)
Local oPrint
Local n         := 0
Local aBitmap   := {	MV_PAR19,;		// Banner Publicitario
						"LGRL.bmp"}		// Logo da Empresa
						Local aDadosEmp := {SM0->M0_NOMECOM,;																					//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 																					//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 					//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 																		//[5]Telefones
						"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;				//[6]
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;								//[6]
						Subs(SM0->M0_CGC,13,2),;																		//[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;					//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}									//[7]I.E
Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText  := {"Após o vencimento cobrar multa de R$ ",;
					"Mora Diaria de R$ ",;
					"",;
					""}
//					"Sujeito a Protesto apos 05 (cinco) dias do vencimento"}
Local aBMP      := aBitMap
Local i         := 1
Local CB_RN_NN  := {}
Local _nVlrAbat := 0

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""
Private cCodEmp		:= ""

If Alltrim(SM0->M0_CODIGO)=="LN" //ER - 14/09/11 Neogen
	cPortGrv    := "033"
	cAgeGrv     := "3853 "
	cContaGrv   := "13005866-2"
	cCodEmp		:= "3931781"
EndIf                                    

cFileName := "BL"+AllTrim(  SQL->E1_NUM ) + "_" + dToS(Date()) + "_" + cHora+".pdf"

oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T.,,.T.,.F.,,,,,,.F.,0)
oPrint:cPathPDF := cPasta
oPrint:SetPortrait()
oPrint:SetPaperSize(9)			// Seta para papel A4

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
Do While SQL->(!EOF())

	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))

	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO)
		DbSelectArea("SA6")
		DbSetOrder(1)
		IF DbSeek(xFilial("SA6") + cPortGrv + cAgeGrv + cContaGrv)
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnLock()
		EndIf
	EndIf

	SQL->(DbSkip())
EndDo

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
WHILE SQL->(!EOF())
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))
	
	If Empty(SE1->E1_PORTADO)		
		SQL->(DBSKIP())
		LOOP
	EndIf
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	aDadosBanco := {"033",;															//SA6->A6_COD [1]Numero do Banco
					"SANTANDER",;													// [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;									// [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;		// [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;			// [5]Digito da conta corrente
					"101"}															// [6]Codigo da Carteira
	IF EMPTY(SA1->A1_ENDCOB)
		aDatSacado := {	AllTrim(SA1->A1_NOME),;										// [1]Razao Social
						AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;						// [2]Codigo
						AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;			// [3]Endereco
						AllTrim(SA1->A1_MUN),;										// [4]Cidade
						SA1->A1_EST,;												// [5]Estado
						SA1->A1_CEP,;												// [6]CEP
						SA1->A1_CGC,;												// [7]CGC
						SA1->A1_PESSOA}												// [8]PESSOA
	ELSE
		aDatSacado := {	AllTrim(SA1->A1_NOME),;										// [1]Razao Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;					// [2]Codigo
						AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;		// [3]Endereco
						AllTrim(SA1->A1_MUNC),;										// [4]Cidade
						SA1->A1_ESTC,;												// [5]Estado
						SA1->A1_CEPC,;												// [6]CEP
						SA1->A1_CGC,;												// [7]CGC
						SA1->A1_PESSOA}												// [8]PESSOA
	ENDIF

	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	IF EMPTY(SE1->E1_NUMBCO) 
	
		nTam := TamSx3("EE_FAXATU")[1]
		nTamE1 := TamSx3("E1_NUMBCO")[1]

		// Enquanto nao conseguir criar o semaforo, indica que outro usuario
		// esta tentando gerar o nosso numero.
		cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)
		
		While !MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
			cNumero := Soma1(cNumero)										// busca o proximo numero disponivel 
		EndDo
		
		cNroDoc 	:= SUBSTR(cNumero,4,10)
		cNroDoc 	:= cNroDoc + AllTrim(Str(MODULO11(cNroDoc)))
						
		RecLock("SE1",.F.)
		Replace SE1->E1_NUMBCO With cNroDoc
		SE1->( MsUnlock( ) )
		
		RecLock("SEE",.F.)
		Replace SEE->EE_FAXATU With Soma1(cNumero, nTam)
		SEE->( MsUnlock() )
					
		Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
		DbSelectArea("SE1")
	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	
	//MSM - 06/07/2015 - Adicionado para tratar as mesagens de protesto, de acordo com o novo campo do cliente A1_P_PROTE
	if SA1->(FieldPos("A1_P_PROTE"))>0
		if UPPER(SA1->A1_P_PROTE)=="S"
			aBolText[3]:="Protestar após 7 dias do vencimento"
			aBolText[4]:="Depósito bancário não quita boleto"
		endif
	endif	
	
	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],substr(cNroDoc,1,len(cNroDoc)-1),(E1_VALOR-_nVlrAbat-E1_DECRESC+E1_ACRESC),E1_VENCTO)
    //CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,(E1_VALOR-_nVlrAbat),E1_VENCTO)
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;				// [1] Numero do Titulo
					E1_EMISSAO,;										// [2] Data da Emissao do Titulo
					Date(),;											// [3] Data da Emissao do Boleto
					E1_VENCTO,;											// [4] Data do Vencimento
					(E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC),;		// [5] Valor do Titulo
					CB_RN_NN[3],;										// [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;										// [7] Prefixo da NF
					E1_TIPO,;											// [8] Tipo do Titulo
					E1_DECRESC,;                    	        		// [9] Desconto
					E1_ACRESC}                          	    		//[10] Acrecimos


	IF .t. //aMarked[i]
		Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		n := n + 1
	ENDIF
	
	SQL->(dbSkip())
	SQL->(INCPROC())
	i := i + 1
ENDDO
oPrint:EndPage()	// Finaliza a Pagina.
oPrint:Preview()	// Visualiza antes de Imprimir.

SQL->(DbCloseArea())

RETURN nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ IMPRESS()   ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
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
STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

Local oFont13
Local oFont15
Local oFont16
Local oFont16n
Local oFont18n
Local oFont30
Local oFont 


Local i        := 0
Local _nLin    := 200
Local aCoords1 := {0150,1900,0550,2300}
Local aCoords2 := {0450,1050,0550,1900}
Local aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
Local aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
Local aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
Local aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
Local aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
Local aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
Local oBrush

Local cSantLogo:="santban10.bmp"

SET DATE FORMAT "dd/mm/yyyy"

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont   := TFont():New('Helvetica 65 Medium',,-16,.T.)
oFont13 := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15 := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont18n:= TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
oFont30 := TFont():New("Arial",9,30,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina

// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)

oPrint:SayBitmap(0050,0100,cSantLogo,430,90 )
oPrint:Say (00125,0567,aDadosBanco[1]+"-7",oFont30)				// [1] Numero do Banco
oPrint:Say (00130,1870,"Comprovante de Entrega",oFont15)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (0169,0100,"Cedente",oFont13)
oPrint:Say (0225,0100,aDadosEmp[1]	,oFont15)					// [1] Nome + CNPJ
oPrint:Say (0169,1060,"Agência/Código Cedente",oFont13)
oPrint:Say (0225,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont15)
oPrint:Say (0169,1510,"Nro.Documento",oFont13)
oPrint:Say (0225,1510,aDadosTit[7]+aDadosTit[1],oFont15)	    // [7] Prefixo + [1] Numero + Parcela
oPrint:Say (0280,0100,"Sacado",oFont13)
oPrint:Say (0330,0100,Substring(aDatSacado[1],1,36),oFont15)    // [1] Nome
oPrint:Say (0280,1060,"Vencimento",oFont13)
oPrint:Say (0330,1060,DTOC(aDadosTit[4]),oFont15)
oPrint:Say (0280,1510,"Valor do Documento",oFont13)
oPrint:Say (0330,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont15)
oPrint:Say (0400,0100,"Recebi(emos) o bloqueto/título",oFont15)
oPrint:Say (0450,0100,"com as características acima.",oFont15)
oPrint:Say (0370,1060,"Data",oFont13)
oPrint:Say (0370,1410,"Assinatura",oFont13)
oPrint:Say (0470,1060,"Data",oFont13)
oPrint:Say (0470,1410,"Entregador",oFont13)
oPrint:Line(0250,0100,0250,1900)
oPrint:Line(0350,0100,0350,1900)
oPrint:Line(0450,1050,0450,1900) //---
oPrint:Line(0550,0100,0550,2300)
oPrint:Line(0550,1050,0150,1050)
oPrint:Line(0550,1400,0350,1400)
oPrint:Line(0350,1500,0150,1500) //--
oPrint:Line(0550,1900,0150,1900)
oPrint:Say (0190,1910,"(  )Mudou-se",oFont13)
oPrint:Say (0230,1910,"(  )Ausente",oFont13)
oPrint:Say (0270,1910,"(  )Não existe nº indicado",oFont13)
oPrint:Say (0310,1910,"(  )Recusado",oFont13)
oPrint:Say (0350,1910,"(  )Não procurado",oFont13)
oPrint:Say (0390,1910,"(  )Endereço insuficiente",oFont13)
oPrint:Say (0430,1910,"(  )Desconhecido",oFont13)
oPrint:Say (0470,1910,"(  )Falecido",oFont13)
oPrint:Say (0500,1910,"(  )Outros(anotar no verso)",oFont13)
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+0490,i,_nLin+0490,i+30)
NEXT i

//1º BLOCO 
oPrint:Line(_nLin+0610,0100,_nLin+0610,2300)  //1ª linha do boleto
oPrint:Line(_nLin+0610,0560,_nLin+0510,0560)
oPrint:Line(_nLin+0610,0800,_nLin+0510,0800)
//---------------------------------------------------------------------------------------------------
oPrint:SayBitmap(_nLin+0510,0100,cSantLogo,0430,90 )
oPrint:Say (_nLin+0600,0570,aDadosBanco[1]+"-7",oFont30)	 //[1]Numero do Banco
oPrint:Say (_nLin+0590,1900,"Recibo do Sacado",oFont15)
oPrint:Line(_nLin+0610,1900,_nLin+0710,1900)  //divisor da data de vencimento

oPrint:Line(_nLin+0690,0100,_nLin+0690,2300)  //2ª linha do boleto
oPrint:Line(_nLin+0768,0100,_nLin+0768,2300)  //3ª linha do boleto
oPrint:Line(_nLin+0830,0100,_nLin+0830,2300)  //4ª linha do boleto
oPrint:Line(_nLin+0895,0100,_nLin+0895,2300)  //5ª linha do boleto

oPrint:Line(_nLin+0768,0500,_nLin+0895,0500)  // divisor da 1ª coluna 
oPrint:Line(_nLin+0830,0750,_nLin+0895,0750)  // divisor da 2ª coluna
oPrint:Line(_nLin+0768,1000,_nLin+0895,1000)  // divisor da 3ª coluna 
oPrint:Line(_nLin+0768,1350,_nLin+0830,1350)  // divisor da 4ª coluna 
oPrint:Line(_nLin+0768,1550,_nLin+0895,1550)  // divisor da 5ª coluna 
//---------------------------------------------------------------------------------------------------
oPrint:Say (_nLin+0630,0100,"Local de Pagamento",oFont13)
oPrint:Say (_nLin+0670,0100,"QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont15)
oPrint:Say (_nLin+0630,1910,"Vencimento",oFont13)
oPrint:Say (_nLin+0670,1950,DTOC(aDadosTit[4]),oFont15)

oPrint:Say (_nLin+0710,0100,"Cedente",oFont13)
oPrint:Say (_nLin+0750,0100,Substr(aDadosEmp[1],1,40)+"   - "+aDadosEmp[6],oFont15) //Nome + CNPJ
oPrint:Say (_nLin+0710,1910,"Agência/Código Cedente",oFont13)
oPrint:Say (_nLin+0750,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont15)

oPrint:Say (_nLin+0790,0100,"Data do Documento",oFont13)
oPrint:Say (_nLin+0825,0100,DTOC(aDadosTit[2]),oFont15) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+0790,0505,"Nro.Documento",oFont13)
oPrint:Say (_nLin+0825,0605,aDadosTit[7]+aDadosTit[1],oFont15) //Prefixo +Numero+Parcela
oPrint:Say (_nLin+0790,1005,"Espécie Doc.",oFont13)
oPrint:Say (_nLin+0825,1050,aDadosTit[8],oFont15) //Tipo do Titulo
oPrint:Say (_nLin+0790,1355,"Aceite",oFont13)
oPrint:Say (_nLin+0825,1455,"N",oFont15)
oPrint:Say (_nLin+0790,1555,"Data do Processamento",oFont13)
oPrint:Say (_nLin+0825,1655,DTOC(aDadosTit[3]),oFont15) // Data impressao
oPrint:Say (_nLin+0790,1910,"Nosso Número",oFont13) 
oPrint:Say (_nLin+0825,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont15)
//2º BLOCO 
oPrint:Say (_nLin+0855,0100,"Uso do Banco",oFont13)
oPrint:Say (_nLin+0855,0505,"Carteira",oFont13)
oPrint:Say (_nLin+0885,0555,aDadosBanco[6],oFont15)
oPrint:Say (_nLin+0855,0755,"Espécie",oFont13)
oPrint:Say (_nLin+0885,0805,"R$",oFont15)
oPrint:Say (_nLin+0855,1005,"Quantidade",oFont13)
oPrint:Say (_nLin+0855,1555,"Valor",oFont13)
oPrint:Say (_nLin+0855,1910,"Valor do Documento",oFont13)
oPrint:Say (_nLin+0885,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont15)
oPrint:Say (_nLin+0920,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont13)

oPrint:Say (_nLin+1020,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont15) 
oPrint:Say (_nLin+1060,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont15)
oPrint:Say (_nLin+1100,0100,aBolText[3],oFont15)
oPrint:Say (_nLin+1143,0100,aBolText[4],oFont15)

oPrint:Line(_nLin+0710,1900,_nLin+1245,1900)   //Linha Vertical do Boleto

oPrint:Say (_nLin+0920,1910,"(-)Desconto/Abatimento",oFont13)
oPrint:Say (_nLin+0950,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont15) //AOA 27/11/2015 - ADICONADO PARA SOLUCIONAR O CHAMADO 030817  

oPrint:Line(_nLin+0960,1900,_nLin+0960,2300)
oPrint:Say (_nLin+0990,1910,"(-)Outras Deduções",oFont13)

oPrint:Line(_nLin+1030,1900,_nLin+1030,2300)

oPrint:Say (_nLin+1055,1910,"(+)Mora/Multa",oFont13)
oPrint:Line(_nLin+1099,1900,_nLin+1099,2300)
oPrint:Say (_nLin+1125,1910,"(+)Outros Acréscimos",oFont13)
oPrint:Say (_nLin+1160,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont15) //AOA 27/11/2015 - ADICONADO PARA SOLUCIONAR O CHAMADO 030817  
oPrint:Line(_nLin+1170,1900,_nLin+1170,2300)

oPrint:Say (_nLin+1198,1910,"(=)Valor Cobrado",oFont13)

oPrint:Line(_nLin+1245,0100,_nLin+1245,2300)  //5ª linha do boleto

oPrint:Say (_nLin+1270,0100,"Sacado",oFont13)

oPrint:Say (_nLin+1300,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont15)
oPrint:Say (_nLin+1350,0400,aDatSacado[3],oFont15)
oPrint:Say (_nLin+1400,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont15) // CEP+Cidade+Estado
 
//RRP - 30/10/2014 - CNPJ ou CPF. Chamado 022287.
If Alltrim(aDatSacado[8]) == 'F'
	oPrint:Say (_nLin+1450,0400,"C.P.F.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont15) // CPF
Else
	oPrint:Say (_nLin+1450,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont15) // CGC
EndIf
 
oPrint:Say (_nLin+1450,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont15)
oPrint:Say (_nLin+1450,0100,"Sacador/Avalista",oFont13)
oPrint:Line(_nLin+1460,0100,_nLin+1460,2300)  //6ª linha do boleto

oPrint:Say (_nLin+1480,1500,"Autenticação Mecânica -",oFont13)

//3ª BLOCO 

FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+1620,i,_nLin+1620,i+30)
NEXT i

// Encerra aqui a alteracao para o novo layout - RAI
//3º BLOCO 
oPrint:SayBitmap(_nLin+1630,0100,cSantLogo,430,90 )
oPrint:Say (_nLin+1710,0567,aDadosBanco[1]+"-7",oFont30)	// [1] Numero do Banco
oPrint:Say (_nLin+1710,0820,CB_RN_NN[2],oFont18n)		// [2] Linha Digitavel do Codigo de Barras

oPrint:Line(_nLin+1730,0100,_nLin+1730,2300)
oPrint:Line(_nLin+1630,0560,_nLin+1730,0560)
oPrint:Line(_nLin+1630,0800,_nLin+1730,0800)

oPrint:Say (_nLin+1755,0100,"Local de Pagamento",oFont13)
oPrint:Say (_nLin+1795,0100,"QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont15)
oPrint:Say (_nLin+1755,1910,"Vencimento",oFont13)
oPrint:Say (_nLin+1795,1950,DTOC(aDadosTit[4]),oFont15)
oPrint:Line(_nLin+1810,0100,_nLin+1810,2300)

oPrint:Line(_nLin+1730,1900,_nLin+2365,1900)

oPrint:Line(_nLin+1890,0500,_nLin+2025,0500)
oPrint:Line(_nLin+1960,0750,_nLin+2025,0750)
oPrint:Line(_nLin+1890,1000,_nLin+2025,1000)
oPrint:Line(_nLin+1890,1350,_nLin+1960,1350)
oPrint:Line(_nLin+1890,1550,_nLin+2025,1550)

oPrint:Say (_nLin+1834,0100,"Cedente",oFont13)      
oPrint:Say (_nLin+1875,0100,Substr(aDadosEmp[1],1,40)+"   - "+aDadosEmp[6],oFont15) //Nome + CNPJ
oPrint:Say (_nLin+1834,1910,"Agência/Código Cedente",oFont13)
oPrint:Say (_nLin+1875,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5],oFont15)

oPrint:Line(_nLin+1890,0100,_nLin+1890,2300)

oPrint:Say (_nLin+1915,0100,"Data do Documento",oFont13)
oPrint:Say (_nLin+1950,0100,DTOC(aDadosTit[2]),oFont15)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+1915,0505,"Nro.Documento",oFont13)
oPrint:Say (_nLin+1950,0605,aDadosTit[7]+aDadosTit[1],oFont15)	//Prefixo + Numero + Parcela
oPrint:Say (_nLin+1915,1005,"Espécie Doc.",oFont13)
oPrint:Say (_nLin+1950,1050,aDadosTit[8],oFont15)					//Tipo do Titulo
oPrint:Say (_nLin+1915,1355,"Aceite",oFont13)
oPrint:Say (_nLin+1950,1455,"N",oFont15)
oPrint:Say (_nLin+1915,1555,"Data do Processamento",oFont13)
oPrint:Say (_nLin+1950,1655,DTOC(aDadosTit[3]),oFont15) // Data impressao
oPrint:Say (_nLin+1915,1910,"Nosso Número",oFont13) 
oPrint:Say (_nLin+1950,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont15)
oPrint:Line(_nLin+1960,0100,_nLin+1960,2300)


oPrint:Say (_nLin+1980,0100,"Uso do Banco",oFont13)
oPrint:Say (_nLin+1980,0505,"Carteira",oFont13)
oPrint:Say (_nLin+2015,0555,aDadosBanco[6],oFont15)
oPrint:Say (_nLin+1980,0755,"Espécie",oFont13)
oPrint:Say (_nLin+2015,0805,"R$",oFont15)
oPrint:Say (_nLin+1980,1005,"Quantidade",oFont13)
oPrint:Say (_nLin+1980,1555,"Valor",oFont13)
oPrint:Say (_nLin+1980,1910,"Valor do Documento",oFont13)
oPrint:Say (_nLin+2015,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont15)
oPrint:Line(_nLin+2025,0100,_nLin+2025,2300)
oPrint:Say (_nLin+2050,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont13)

oPrint:Say (_nLin+2125,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont15)
oPrint:Say (_nLin+2165,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont15)
oPrint:Say (_nLin+2205,0100,aBolText[3],oFont15)
oPrint:Say (_nLin+2245,0100,aBolText[4],oFont15)

oPrint:Say (_nLin+2050,1910,"(-)Desconto/Abatimento",oFont13)
oPrint:Say (_nLin+2083,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont15) //AOA 27/11/2015 - ADICONADO PARA SOLUCIONAR O CHAMADO 030817  
oPrint:Line(_nLin+2092,1900,_nLin+2092,2300)
oPrint:Say (_nLin+2120,1910,"(-)Outras Deduções",oFont13)
oPrint:Line(_nLin+2163,1900,_nLin+2163,2300)
oPrint:Say (_nLin+2185,1910,"(+)Mora/Multa",oFont13)
oPrint:Line(_nLin+2230,1900,_nLin+2230,2300)

oPrint:Say (_nLin+2253,1910,"(+)Outros Acréscimos",oFont13)
oPrint:Say (_nLin+2285,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont15) //AOA 27/11/2015 - ADICONADO PARA SOLUCIONAR O CHAMADO 030817  
oPrint:Line(_nLin+2298,1900,_nLin+2298,2300)

oPrint:Say (_nLin+2323,1910,"(=)Valor Cobrado",oFont13)
oPrint:Line(_nLin+2365,0100,_nLin+2365,2300)

oPrint:Say (_nLin+2390,0100,"Sacado",oFont13)
oPrint:Say (_nLin+2412,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont15)
oPrint:Say (_nLin+2455,0400,aDatSacado[3],oFont15)
oPrint:Say (_nLin+2495,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont15)	// CEP+Cidade+Estado
//RRP - 30/10/2014 - CNPJ ou CPF. Chamado 022287.
If Alltrim(aDatSacado[8]) == 'F'
	oPrint:Say (_nLin+2550,0400,"C.P.F.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont15) // CPF
Else
	oPrint:Say (_nLin+2550,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont15) // CGC
EndIf

oPrint:Say (_nLin+2550,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont15)
oPrint:Say (_nLin+2550,0100,"Sacador/Avalista",oFont13)
oPrint:Line(_nLin+2560,0100,_nLin+2560,2300)
oPrint:Say (_nLin+2580,1500,"Autenticação Mecânica -",oFont13)
oPrint:Say (_nLin+2583,1850,"Ficha de Compensação",oFont15)

oPrint:Int25(2880,150,CB_RN_NN[1],0.73,40,.F.,.F., oFont)  //04092020 10:28

oPrint:EndPage()	// Finaliza a Pagina
RETURN Nil
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
Local L,D,P := 0
Local B     := .F.
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
Local L, D, P := 0
Default lCodBarra := .F.


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
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

Local cValorFinal 	:= strzero((nValor*100),10)
Local nDvnn			:= 0
Local nDvcb			:= 0
Local nDv			:= 0
Local cNN			:= ''
Local cRN			:= ''
Local cCB			:= ''
Local cS			:= ''
Local cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
Local cCart			:= "101"
//-----------------------------                                      
// Definicao do NOSSO NUMERO
// ----------------------------
//cS    :=  cCart + cNroDoc //19 001000012
cS    := cNroDoc
nDvnn := modulo11(cS,.F.) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
cNN   := cCart + cNroDoc + '-' + AllTrim(Str(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + cNNSD + Strzero(Val(cConta),8) + "0"

//cS		:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
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
//cS 	:=Subs(cLivre,6,10)
cS 	:=cCompCed+Subs(cNNCD,1,7)
nDv	:= modulo10(cS)
cRN	+= Subs(cS,1,3)+substr(cNNCD,1,2) +'.'+ substr(cNNCD,3,5) + Alltrim(Str(nDv)) + '  

// 	CAMPO 3:
//	FFFFFF = Posição 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
cTipoMod:="0101" //Cobrança Simples Rápida COM Registro
//cS 	:=Subs(cLivre,16,10)
cS 	:=substr(cNNCD,8,6)+cTipoMod
nDv	:= modulo10(cS)
cRN	+= substr(cNNCD,8,5) +'.'+ substr(cNNCD,13,1)+cTipoMod+ Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN  += cFator + StrZero((nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})


//--------------------------------------------------------------
/*/{Protheus.doc} SELPORT
Description

@param xParam Parameter Description
@return xRet Return Description
@author  - Amedeo D. P. Filho
@since 02/03/2011
/*/
//--------------------------------------------------------------
Static Function SELPORT()

Local oFont1	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local nOpcA		:= 0

Private cGet1 	:= Space(TamSx3("A6_COD")[1])
Private cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
Private cGet3 	:= Space(TamSx3("A6_NUMCON")[1])

Private oGet1
Private oGet2
Private oGet3

Static oDlg

DEFINE MSDIALOG oDlg TITLE "Selecionar Portador" FROM 000, 000  TO 230, 200 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

oDlg:lEscClose	:= .F.

@ 011, 010 SAY oSay1 PROMPT "Selecione Portador" 	SIZE 080, 012 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 035, 010 SAY oSay2 PROMPT "Banco :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 050, 010 SAY oSay3 PROMPT "Agencia :" 			SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 065, 010 SAY oSay4 PROMPT "Conta :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 040 MSGET oGet1 VAR cGet1 SIZE 040, 010 OF oDlg COLORS 0, 16777215 F3 "SANTAN" PIXEL Valid(VALIDBCO())
@ 050, 040 MSGET oGet2 VAR cGet2 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.
@ 065, 040 MSGET oGet3 VAR cGet3 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.

DEFINE SBUTTON oSButton1 FROM 087, 020 TYPE 01 OF oDlg ENABLE Action (nOpcA := 1, oDlg:End())
DEFINE SBUTTON oSButton2 FROM 087, 051 TYPE 02 OF oDlg ENABLE Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	cPortGrv	:= cGet1
	cAgeGrv		:= cGet2
	cContaGrv	:= cGet3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Banco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDBCO()
Local lRetorno := .T.

DbSelectarea("SA6")
DbSetorder(1)
If DbSeek(xFilial("SA6") + cGet1)
	cGet2 := SA6->A6_AGENCIA
	cGet3 := SA6->A6_NUMCON
	oGet2:Refresh()
	oGet3:Refresh()
Else
	lRetorno := .F.
	Aviso("Aviso","Banco Inválido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno		
