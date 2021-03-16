#Include "Protheus.Ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE MAXLIN 794

/*
Função.............: GTFin013
Objetivo...........: Impressao da Ordem de Pagamento
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 07/12/2015
Observações........:
*/

*--------------------------------------*
User Function GTFin013( cPar )
*--------------------------------------*
Local cLocal          	:= GetTempPath()

Local lAdjustToLegacy 	:= .F.
Local lDisableSetup  	:= .T.

Local cNomeArq			:= 'Ordem_Pagamento_'
Local nLin

Local cPictVal			:= X3Picture( 'E1_VALOR' )
Local nValPrinc	    	:= 0

Local nValJur 	        := 0
Local nValAcresc        := 0
Local nValMulta         := 0

Local nValIRRF 	        := 0
Local nValPIS           := 0
Local nValCOF           := 0
Local nValCSLL          := 0
Local nValISS           := 0

Local nValAd 	        := 0
Local nValDecresc       := 0

Local nValLiq 			:= 0
Local nValIns			:= 0
Local cChave
Local cCCusto			:= ""

Local aCtDeb 			:= {}
Local nRecSE2

Local cPictCnpj			:= "@R 99.999.999/9999-99"
Local cPictCpf			:= "@R 999.999.999-99"

Private oFont8n 		:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont8 			:= TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont7n 		:= TFont():New("Arial",9, 7,.T.,.T.,5,.T.,5,.T.,.F.)

Private oFont7 			:= TFont():New("Arial",9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont6n 		:= TFont():New("Arial",9, 6,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont6   		:= TFont():New("Arial",9, 6,.T.,.F.,5,.T.,5,.T.,.F.)

Private oBrush  		:= TBrush():New( , CLR_GRAY )
Private oFont12n 		:= TFont():New("Arial",9, 12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont18n 		:= TFont():New("Arial",9, 18,.T.,.T.,7,.T.,7,.T.,.F.)

Private oFont22n 		:= TFont():New("Arial",9, 22,.T.,.T.,7,.T.,7,.T.,.F.)
Private oPrinter

Private nCol1 			:= 20
Private nCol2 			:= 110
Private nCol3 			:= 300

Private nCol4 			:= 430
Private nCol5 			:= 490
Private nColF 			:= 540

Private nSalto 			:= 12
Private cLogo			:= "logo"+cEmpAnt+".png"
Private nPage 			:= 0
Private cOrigem 		:= cPar


If ( cOrigem == 'CP' )   //** Contas a Pagar
	
	nRecSE2 := SE2->( Recno() )
	SA2->( DbSetOrder( 1 ) )
	SA2->( DbSeek( xFilial() + SE2->E2_FORNECE + SE2->E2_LOJA ) )
	
	cNomeArq += AllTrim( SE2->E2_NUM + SE2->E2_PARCELA )
	
	nValPrinc	:= SE2->E2_VLCRUZ + SE2->E2_IRRF + SE2->E2_ISS
	nValJur 	:= SE2->E2_JUROS
	nValAcresc 	:= SE2->E2_ACRESC
	nValMulta 	:= SE2->E2_MULTA
	nValIRRF 	:= SE2->E2_IRRF
	nValPIS     := SE2->E2_PIS
	nValCOF     := SE2->E2_COFINS
	nValCSLL    := SE2->E2_CSLL
	nValISS     := SE2->E2_ISS
	nValAd 		:= BuscaAd(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE_E2_LOJA))
	nValDecresc := SE2->E2_DECRESC
	//nValLiq 	:= ( SE2->E2_VLCRUZ + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_MULTA - SE2->E2_DECRESC - SE2->E2_PIS - SE2->E2_COFINS - SE2->E2_CSLL )
	nValLiq 	:= ( SE2->E2_VLCRUZ + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_MULTA - SE2->E2_DECRESC - SE2->E2_PIS - SE2->E2_COFINS - SE2->E2_CSLL - SE2->E2_INSS )	
	nValIns		:= SE2->E2_INSS //RRP - 10/07/2016 - Inclusão do INSS.
	
Else
	
	/*
	* Se a nota nao gerou titulo, aborta impressao da ordem de pagamento
	*/
	If Empty( SF1->F1_DUPL )
		Return
	EndIf
	
	cNomeArq += AllTrim( SF1->F1_DOC + SF1->F1_SERIE )
	SA2->( DbSetOrder( 1 ) )
	SA2->( DbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	
	/*
	* Acumula os valores de todos os titulos da NF
	*/
	SE2->( DbSetOrder( 6 ) ) //** E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM
	SE2->( DbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL ) )
	While SE2->( !Eof() .And. E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM == ;
		xFilial('SE2') + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO + SF1->F1_DUPL )
		
		
		If SE2->E2_TIPO <> 'NF'
			SE2->( DbSkip() )
			Loop
		EndIf
		
		nValPrinc	+= SE2->E2_VLCRUZ + SE2->E2_IRRF + SE2->E2_ISS
		nValJur 	+= SE2->E2_JUROS
		nValAcresc 	+= SE2->E2_ACRESC
		nValMulta 	+= SE2->E2_MULTA
		nValIRRF 	+= SE2->E2_IRRF
		nValPIS     += SE2->E2_PIS
    	nValCOF     += SE2->E2_COFINS
	    nValCSLL    += SE2->E2_CSLL
		nValISS     += SE2->E2_ISS
		nValAd 		+= BuscaAd(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE_E2_LOJA))
		nValDecresc += SE2->E2_DECRESC
		//nValLiq 	+= ( SE2->E2_VLCRUZ + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_MULTA - SE2->E2_DECRESC - SE2->E2_PIS - SE2->E2_COFINS - SE2->E2_CSLL )
		nValLiq 	+= ( SE2->E2_VLCRUZ + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_MULTA - SE2->E2_DECRESC - SE2->E2_PIS - SE2->E2_COFINS - SE2->E2_CSLL - SE2->E2_INSS )
		nValIns		+= SE2->E2_INSS //RRP - 10/07/2016 - Inclusão do INSS.
		
		nRecSE2 := SE2->( Recno() )
		
		SE2->( DbSkip() )
		
	EndDo
	
	
EndIf

SE2->( DbGoTo( nRecSE2 ) )

SED->( DbSetOrder( 1 ) , DbSeek( xFilial() + SE2->E2_NATUREZ ) )

oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)

/*
Ordem obrigátoria de configuração do relatório
*/
oPrinter:SetResolution(72)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(60,60,60,60)

ImpCabec( @nLin )

oPrinter:Fillrect( {nLin-8, nCol1-5, nLin+8, nColF }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"1. DADOS DA EMPRESA",oFont8n)

nLin += nSalto + 7
oPrinter:Say( nLin,nCol1,"Razão Social:",oFont8n)
oPrinter:Say( nLin,nCol2,SM0->M0_NOMECOM,oFont8)
oPrinter:Say( nLin,nCol4,"Código:",oFont8n)
oPrinter:Say( nLin,nCol5,SM0->M0_CODIGO,oFont8)

nLin += nSalto
oPrinter:Say( nLin,nCol1,"CNPJ:",oFont8n)
oPrinter:Say( nLin,nCol2,Transf( SM0->M0_CGC , cPictCnpj ),oFont8)
oPrinter:Say( nLin,nCol4,"Filial:",oFont8n)
oPrinter:Say( nLin,nCol5,SM0->M0_CODFIL,oFont8)

nLin += ( nSalto * 2 )
oPrinter:Fillrect( {nLin-8, nCol1-5, nLin+8, nColF }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"2. DADOS DO FORNECEDOR",oFont8n)

nLin += nSalto + 5
oPrinter:Say( nLin,nCol1,"Razão Social:",oFont8n)
oPrinter:Say( nLin,nCol2,SA2->A2_NOME,oFont8)
oPrinter:Say( nLin,nCol4,"Código:",oFont8n)
oPrinter:Say( nLin,nCol5,SA2->A2_COD + '-' + SA2->A2_LOJA,oFont8)

nLin += nSalto
oPrinter:Say( nLin,nCol1,"CNPJ:",oFont8n)
oPrinter:Say( nLin,nCol2,Transf( SA2->A2_CGC , If( Len( AllTrim( SA2->A2_CGC ) ) > 11 , cPictCnpj , cPictCpf ) ) ,oFont8)
oPrinter:Say( nLin,nCol3,"Banco:",oFont8n)
oPrinter:Say( nLin,nCol3+30,SA2->A2_BANCO,oFont8)
oPrinter:Say( nLin,nCol3+70,"Ag.:",oFont8n)
oPrinter:Say( nLin,nCol3+100,SA2->A2_AGENCIA,oFont8)
oPrinter:Say( nLin,nCol4,"Conta:",oFont8n)
oPrinter:Say( nLin,nCol5,SA2->A2_NUMCON,oFont8)

nLin += ( nSalto * 2 )
oPrinter:Fillrect( {nLin-8, nCol1-5, nLin+8, nColF }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"3. DADOS DO LANCAMENTO",oFont8n)

nLin += nSalto + 5

If cOrigem == 'CP'
	oPrinter:Say( nLin,nCol1,"Documento:",oFont8n)
	oPrinter:Say( nLin,nCol2+50,"Serie:",oFont8n)
	oPrinter:Say( nLin,nCol4,"Tipo:",oFont8n)
	oPrinter:Say( nLin,nCol5-30,"Contas a Pagar",oFont8)
	
Else
	oPrinter:Say( nLin,nCol1,"Documento:",oFont8n)
	oPrinter:Say( nLin,nCol2,SF1->F1_DOC,oFont8)
	oPrinter:Say( nLin,nCol2+50,"Serie:",oFont8n)
	oPrinter:Say( nLin,nCol2+80,SF1->F1_SERIE,oFont8)
	oPrinter:Say( nLin,nCol4,"Tipo:",oFont8n)
	oPrinter:Say( nLin,nCol5-30,"Documento de Entrada",oFont8)
	
EndIf


nLin += nSalto
oPrinter:Say( nLin,nCol1,"Titulo:",oFont8n)
If !Empty(SE2->E2_PREFIXO)
	oPrinter:Say( nLin,nCol2,SE2->E2_PREFIXO+"-"+SE2->E2_NUM,oFont8)
Else
	oPrinter:Say( nLin,nCol2,SE2->E2_NUM,oFont8)
EndIf
oPrinter:Say( nLin,nCol4,"Emissao:",oFont8n)
oPrinter:Say( nLin,nCol5,DtoC( SE2->E2_EMISSAO ),oFont8)

nLin += nSalto


oPrinter:Say( nLin,nCol1,"Histórico:",oFont8n)
If ( cOrigem == "CP" )
	oPrinter:Say( nLin,nCol2,AllTrim(SE2->E2_HIST),oFont8)
Else
	oPrinter:Say( nLin,nCol2,AllTrim(SED->ED_DESCRIC),oFont8)
EndIf

oPrinter:Say( nLin,nCol4,"Vencimento:",oFont8n)
oPrinter:Say( nLin,nCol5,DtoC( SE2->E2_VENCTO ),oFont8)

nLin += ( nSalto * 2 )
oPrinter:Fillrect( {nLin-8, nCol1-5, nLin+8, nColF }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"4. ITENS/APROPRIAÇÃO DE C.C",oFont8n)

nLin += ( nSalto * 2  )


oPrinter:Box( nLin, nCol1, nLin + nSalto + 2, nColF )

oPrinter:Say( nLin + 9,nCol1 + 3 ,"Item",oFont8n)

oPrinter:Line( nLin , nCol2-40, nLin + nSalto + 2, nCol2 -40 )
oPrinter:Say( nLin + 9,nCol2 -37  ,"Cód/Nat",oFont8n)

oPrinter:Line( nLin , nCol2 + 20, nLin + nSalto + 2 , nCol2 + 20 )
oPrinter:Say( nLin + 9,nCol2 + 23 ,"Descrição",oFont8n)

oPrinter:Line( nLin , nCol2 + 230, nLin + nSalto + 2, nCol2 + 230 )
oPrinter:Say( nLin + 9,nCol2 + 233 ,"C.C",oFont8n)

oPrinter:Line( nLin , nCol2 + 320, nLin + nSalto + 2, nCol2 + 320 )
oPrinter:Say( nLin + 9,nCol2 + 323 ,"%",oFont8n)

oPrinter:Line( nLin , nCol2 + 360, nLin + nSalto + 2, nCol2 + 360 )
oPrinter:Say( nLin + 9,nCol2 + 363 ,"Valor",oFont8n)


SomaLinha( @nLin )

/*
* IMPRESSAO DOS ITENS
*/

If ( cOrigem == 'CP' )
	
	SEZ->( DbSetOrder( 1 ) ) //* EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO
	SEV->( DbSetOrder( 1 ) )
	nSeq := 0
	
	If SEV->( DbSeek( xFilial() + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA ) )
		While SEV->( !Eof() .And. EV_FILIAL + EV_PREFIXO + EV_NUM + EV_PARCELA + EV_TIPO + EV_CLIFOR + EV_LOJA  == ;
			xFilial("SEZ") + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA )
			
			If SEZ->( DbSeek( xFilial() + SEV->EV_PREFIXO + SEV->EV_NUM + SEV->EV_PARCELA + SEV->EV_TIPO + SEV->EV_CLIFOR + SEV->EV_LOJA + SEV->EV_NATUREZ ) )
				While SEZ->( !Eof() .And. EZ_FILIAL + SEZ->EZ_PREFIXO + SEZ->EZ_NUM + SEZ->EZ_PARCELA + SEZ->EZ_TIPO + SEZ->EZ_CLIFOR + SEZ->EZ_LOJA + SEZ->EZ_NATUREZ == ;
					xFilial("SEV") + SEV->EV_PREFIXO + SEV->EV_NUM + SEV->EV_PARCELA + SEV->EV_TIPO + SEV->EV_CLIFOR + SEV->EV_LOJA + SEV->EV_NATUREZ )
					
					SomaLinha( @nLin )
					oPrinter:Say( nLin , nCol1 + 3 ,StrZero( ++nSeq , 2 ) ,oFont8)
					oPrinter:Say( nLin ,nCol2 - 37 ,SEZ->EZ_NATUREZ,oFont8)
					oPrinter:Say( nLin ,nCol2 + 23 ,AllTrim( Posicione( 'SED' , 1 , xFilial('SED') + SEZ->EZ_NATUREZ , 'ED_DESCRIC' ) ),oFont8)
					oPrinter:Say( nLin ,nCol2 + 233 ,Alltrim(SEZ->EZ_CCUSTO)+" - "+Alltrim(SubStr(AllTrim( Posicione('CTT',1,xFilial('CTT')+SEZ->EZ_CCUSTO ,'CTT_DESC01')),1,13)),oFont8)
					oPrinter:Say( nLin ,nCol2 + 323 ,Transf( SEZ->EZ_VALOR/SE2->E2_VALOR * 100, '@E 99.99' ) ,oFont8)
					oPrinter:Say( nLin ,nCol2 + 363 ,Transf( SEZ->EZ_VALOR , X3Picture( 'D1_TOTAL' ) ) ,oFont8)
					
					ImpTraco( nLin )
					
					If SED->( DbSeek( xFilial() + SEZ->EZ_NATUREZ ) ) .And. ( Ascan( aCtDeb , SED->ED_CONTA ) == 0 )
						Aadd( aCtDeb , SED->ED_CONTA )
					EndIf
					SEZ->( DbSkip() )
				EndDo
			Else
				SomaLinha( @nLin )
				oPrinter:Say( nLin , nCol1 + 3 ,StrZero( ++nSeq , 2 ) ,oFont8)
				oPrinter:Say( nLin ,nCol2 - 37 ,SEV->EV_NATUREZ,oFont8)
				oPrinter:Say( nLin ,nCol2 + 23 ,AllTrim( Posicione( 'SED' , 1 , xFilial('SED') + SEV->EV_NATUREZ , 'ED_DESCRIC' ) ),oFont8)
				oPrinter:Say( nLin ,nCol2 + 233 ,Alltrim(SE2->E2_CCD)+" - "+Alltrim(SubStr(AllTrim( Posicione('CTT',1,xFilial('CTT')+SE2->E2_CCD ,'CTT_DESC01')),1,13)),oFont8)
				oPrinter:Say( nLin ,nCol2 + 323 ,Transf( SEV->EV_VALOR/SE2->E2_VALOR * 100, '@E 99.99' ) ,oFont8)
				oPrinter:Say( nLin ,nCol2 + 363 ,Transf( SEV->EV_VALOR , X3Picture( 'D1_TOTAL' ) ) ,oFont8)
				
				ImpTraco( nLin )
				
				If SED->( DbSeek( xFilial() + SEV->EV_NATUREZ ) ) .And. ( Ascan( aCtDeb , SED->ED_CONTA ) == 0 )
					Aadd( aCtDeb , SED->ED_CONTA )
				EndIf
				
			EndIf
			
			SEV->( DbSkip() )
		EndDo
		
	Else
		cCCusto:=""
		cCCusto:=If(!Empty(SE2->E2_CCC),SE2->E2_CCC,SE2->E2_CCD)
		SomaLinha( @nLin )
		oPrinter:Say( nLin , nCol1 + 3 ,'01',oFont8)
		oPrinter:Say( nLin ,nCol2 - 37 ,SE2->E2_NATUREZ,oFont8)
		oPrinter:Say( nLin ,nCol2 + 23 ,AllTrim( Posicione( 'SED' , 1 , xFilial('SED') + SE2->E2_NATUREZ , 'ED_DESCRIC' ) ),oFont8)
		oPrinter:Say( nLin ,nCol2 + 233 ,Alltrim(cCCusto)+" - "+Alltrim(SubStr(AllTrim( Posicione('CTT',1,xFilial('CTT')+cCCusto ,'CTT_DESC01')),1,13)),oFont8)
		oPrinter:Say( nLin ,nCol2 + 323 ,"100,00%",oFont8)
		oPrinter:Say( nLin ,nCol2 + 363 ,Transf( SE2->E2_VALOR , X3Picture( 'E2_VALOR' ) ),oFont8)
		
		ImpTraco( nLin )
		
		Aadd( aCtDeb , SED->ED_CONTA )
		
	EndIf
Else
	
	Aadd( aCtDeb , SED->ED_CONTA )
	
	SDE->( DbSetOrder( 1 ) )
	SD1->( DbSetOrder( 1 ) , DbSeek( xFilial() + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	While SD1->( !Eof() .And. D1_FILIAL +D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
		
		/*
		* Verifica primeiro se existe rateio por CC
		*/
		If SDE->( DbSeek( xFilial() + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM ) )
			While SDE->( !Eof() .And. DE_FILIAL + DE_DOC + DE_SERIE + DE_FORNECE + DE_LOJA + DE_ITEMNF == ;
				xFilial("SDE") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM )
				
				SomaLinha( @nLin )
				oPrinter:Say( nLin , nCol1 + 3 ,SD1->D1_ITEM,oFont8)
				oPrinter:Say( nLin ,nCol2 - 37 ,SD1->D1_COD,oFont8)
				oPrinter:Say( nLin ,nCol2 + 23 ,AllTrim( Posicione( 'SB1' , 1 , xFilial('SB1') + SD1->D1_COD , 'B1_DESC' ) ),oFont8)
				oPrinter:Say( nLin ,nCol2 + 233 ,Alltrim(SDE->DE_CC)+" - "+Alltrim(SubStr(AllTrim( Posicione('CTT',1,xFilial('CTT')+SDE->DE_CC ,'CTT_DESC01')),1,13)),oFont8)
				oPrinter:Say( nLin ,nCol2 + 323 ,Transf( SDE->DE_PERC , '@E 99.99' ) ,oFont8)
				oPrinter:Say( nLin ,nCol2 + 363 ,Transf( Round( SDE->DE_CUSTO1 , 2 ) , X3Picture( 'D1_TOTAL' ) ) ,oFont8)
				
				ImpTraco( nLin )
				
				SDE->( DbSkip() )
			EndDo
			
		Else
			SomaLinha( @nLin )
			oPrinter:Say( nLin , nCol1 + 3 ,SD1->D1_ITEM,oFont8)
			oPrinter:Say( nLin ,nCol2 - 37 ,SD1->D1_COD,oFont8)
			oPrinter:Say( nLin ,nCol2 + 23 ,AllTrim( Posicione( 'SB1' , 1 , xFilial('SB1') + SD1->D1_COD , 'B1_DESC' ) ),oFont8)
			oPrinter:Say( nLin ,nCol2 + 233 ,Alltrim(SD1->D1_CC)+" - "+Alltrim(SubStr(AllTrim( Posicione('CTT',1,xFilial('CTT')+SD1->D1_CC ,'CTT_DESC01')),1,13)),oFont8)
			oPrinter:Say( nLin ,nCol2 + 323 ,"100,00%",oFont8)
			oPrinter:Say( nLin ,nCol2 + 363 ,Transf( Round( SD1->D1_TOTAL , 2 ) , X3Picture( 'D1_TOTAL' ) ),oFont8)
			
			
			ImpTraco( nLin )
			
		EndIf
		
		SD1->( DbSkip() )
	EndDo
	
EndIf

SomaLinha( @nLin , 2  )

oPrinter:Fillrect( {nLin-8, nCol1-3, nLin+8, nCol3 - 3  }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"5. DESCRIMINAÇÃO DOS VALORES DE PAGAMENTO",oFont8n)

oPrinter:Fillrect( {nLin-8, nCol3 + 3, nLin+8, nColF  }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol3+5,"6. APROPRIAÇÃO CONTÁBIL",oFont8n)

SomaLinha( @nLin , 2 )
oPrinter:Say( nLin ,nCol1 ,"Valor Principal R$",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValPrinc , cPictVal ),oFont8)

oPrinter:Say( nLin ,nCol3 +3 ,"Débito",oFont8n)

ImpConta( aCtDeb , 1 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,Replicate("-",100),oFont8n)

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(+)Juros",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValJur , cPictVal ),oFont8)

ImpConta( aCtDeb ,  2 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(+)Acréscimo",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValAcresc , cPictVal ),oFont8)

ImpConta( aCtDeb , 3 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)Multas/Tarifas",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValMulta , cPictVal ),oFont8)

ImpConta( aCtDeb , 4 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)IRRF",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValIRRF , cPictVal ),oFont8)

ImpConta( aCtDeb , 5 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)PIS",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValPIS , cPictVal ),oFont8)

ImpConta( aCtDeb , 6 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)COFINS",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValCOF , cPictVal ),oFont8)

ImpConta( aCtDeb , 7 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)CSLL",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValCSLL , cPictVal ),oFont8)

ImpConta( aCtDeb , 8 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)ISS",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValISS , cPictVal ),oFont8)

ImpConta( aCtDeb , 9 , nLin )

//RRP - 20/07/2016 - Inclusão do INSS
SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)INSS",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValIns , cPictVal ),oFont8)

ImpConta( aCtDeb , 10 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)Adiantamento",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValAD , cPictVal ),oFont8)

ImpConta( aCtDeb , 11 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"(-)Outros Descontos",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValDecresc , cPictVal ),oFont8)

ImpConta( aCtDeb , 12 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,Replicate("-",100),oFont8n)

ImpConta( aCtDeb , 13 , nLin )

SomaLinha( @nLin )
oPrinter:Say( nLin ,nCol1 ,"Vl.Liquido R$",oFont8n)
oPrinter:Say( nLin , nCol1+90 ,Transf( nValLiq , cPictVal ),oFont8)

ImpConta( aCtDeb , 14 , nLin )

/*
* Imprime demais contas se houver controlando quebra de pagina
*/
For i := 15 To Len( aCtDeb )
	ImpConta( aCtDeb , 15 , @nLin )
Next

/*
**	Imprime o ultimo bloco sem quebra
*/
If ( nLin + ( nSalto * 8 ) ) > MAXLIN
	ImpCabec( @nLin )
Else
	SomaLinha( @nLin , 2  )
EndIf

oPrinter:Fillrect( {nLin-8, nCol1-5, nLin+8, nColF }, oBrush, "-2")
oPrinter:Say( nLin+2,nCol1,"7. APROVAÇÕES",oFont8n)

SomaLinha( @nLin ,2 )
oPrinter:Say( nLin ,nCol1 ,"Digitação",oFont8n)
oPrinter:Say( nLin ,nCol1+130 ,"Aprovação1",oFont8n)
oPrinter:Say( nLin ,nCol1+260 ,"Aprovação2",oFont8n)
oPrinter:Say( nLin ,nCol1+390 ,"Financeiro",oFont8n)

SomaLinha( @nLin ,1 )

oPrinter:Box( nLin-8, nCol1, nLin+(nSalto*2), 130, "-4")
oPrinter:Line( nLin+8 , nCol1, nLin+8, 130 )

oPrinter:Box( nLin-8, nCol1+130, nLin+(nSalto*2), nCol1+250, "-4")
oPrinter:Line( nLin+8 , nCol1+130, nLin+8, nCol1+250 )

oPrinter:Box( nLin-8, nCol1+260, nLin+(nSalto*2),nCol1+380 , "-4")
oPrinter:Line( nLin+8 , nCol1+260, nLin+8, nCol1+380 )

oPrinter:Box( nLin-8, nCol1+390, nLin+(nSalto*2),nColF , "-4")
oPrinter:Line( nLin+8 , nCol1+390, nLin+8, nColF )

oPrinter:Say( nLin +1 ,nCol1+3   ,"Nome:",oFont8n)
oPrinter:Say( nLin +1 ,nCol1+35  ,FWLeUserlg("E2_USERLGI"),oFont8n)
oPrinter:Say( nLin +1 ,nCol1+132 ,"Nome:",oFont8n)
oPrinter:Say( nLin +1 ,nCol1+262 ,"Nome:",oFont8n)
oPrinter:Say( nLin +1 ,nCol1+392 ,"Nome:",oFont8n)

SomaLinha( @nLin , 1 )
oPrinter:Say( nLin +4 ,nCol1+3   ,"Data:",oFont8n)
oPrinter:Say( nLin +4 ,nCol1+35  ,FWLeUserlg("E2_USERLGI",2),oFont8n)
oPrinter:Say( nLin +4 ,nCol1+132 ,"Data:",oFont8n)
oPrinter:Say( nLin +4 ,nCol1+262 ,"Data:",oFont8n)
oPrinter:Say( nLin +4 ,nCol1+392 ,"Data:",oFont8n)

oPrinter:EndPage()
oPrinter:Preview ()

Return

*-------------------------------*
Static Function ImpCabec( nLin )
*-------------------------------*

oPrinter:StartPage()

nPage ++
nLin := 45

oPrinter:SayBitmap( nLin , 05 , cLogo, 244.5, 40)
nLin += nSalto
oPrinter:Say( nLin,nCol4,"ID:",oFont8n)
oPrinter:Say( nLin,nCol5,RetID(),oFont8)

nLin += nSalto
oPrinter:Say( nLin,nCol4,"Dt.Impressao:",oFont8n)
oPrinter:Say( nLin,nCol5,DtoC( dDataBase ),oFont8)

nLin += nSalto
oPrinter:Say( nLin,nCol4,"Página:",oFont8n)
oPrinter:Say( nLin,nCol5,StrZero( nPage , 2 ),oFont8)

nLin += ( nSalto * 4 )
oPrinter:Say( nLin,nCol2,"ORDEM DE PAGAMENTO E APROPRIAÇÃO CONTÁBIL",oFont18n)

nLin += ( nSalto * 3 )

Return

/*
Função...............: SomaLinha
Objetivo.............: Controlar quebra de pagina
Parametros...........: nLin => Numero da linha atual , nVez => Qtde de linhas
Retorno..............: Null
*/
*-----------------------------------------------------*
Static Function SomaLinha( nLin , nVez )
*-----------------------------------------------------*
Default nVez := 1

nLin += ( nSalto * nVez )

If nLin > MAXLIN
	oPrinter:EndPage()
	ImpCabec( @nLin )
EndIf

Return

/*
Função...............: ImpConta
Objetivo.............: Imprime Conta Contabil
Parametros...........: nConta
Retorno..............: Null
*/
*-----------------------------------------------------*
Static Function ImpConta( aCtDeb , nConta , nLin )
*-----------------------------------------------------*

If Len( aCtDeb ) >= nConta
	oPrinter:Say( nLin , nCol3+40 ,AllTrim( aCtDeb[ nConta ] ) + ' - ' + Posicione( 'CT1' , 1 , xFilial( 'CT1' ) + aCtDeb[ nConta ] , 'CT1_DESC01' ) ,oFont8)
	
	If Len( aCtDeb ) == nConta
		SomaLinha( @nLin )
		oPrinter:Say( nLin ,nCol3 +3 ,"Crédito",oFont8n)
		oPrinter:Say( nLin , nCol3+40 ,AllTrim( SA2->A2_CONTA ) + ' - ' + Posicione( 'CT1' , 1 , xFilial( 'CT1' ) + SA2->A2_CONTA , 'CT1_DESC01' ) ,oFont8)
	EndIf
	
EndIf

Return


/*
Função...............: RetID
Objetivo.............: Retorna ID de Impressao
Parametros...........: Nenhum
Retorno..............: cId => Codigo do Identificador
*/
*-----------------------------------------------------*
Static Function RetID
*-----------------------------------------------------*
Local cChave

If ( cOrigem == 'CP'   )
	cChave := 'CP' + SE2->( xFilial( 'SE2' ) + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO )
Else
	cChave := 'NF' + SF1->( xFilial( 'SF1' ) + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )
EndIf

cChave := PadR( cChave , Len( Z22->Z22_CHAVE ) )
Z22->( DbSetOrder( 1 ) )
If Z22->( !DbSeek( xFilial() + cChave ) )
	Z22->( RecLock( 'Z22' , .T. ) )
	Z22->Z22_FILIAL := xFilial( 'Z22' )
	Z22->Z22_ID 	:= GetSxeNum( 'Z22' , 'Z22_ID' )
	Z22->Z22_CHAVE  := cChave
	Z22->Z22_DATA	:= dDataBase
	Z22->( MSUnLock() )
	ConfirmSX8()
EndIf


Return( Z22->Z22_ID )

/*
Função............: ImpTraco
Objetivo..........: Imprime contorno da linha
*/
*------------------------------------------*
Static Function ImpTraco( nLin )
*------------------------------------------*

oPrinter:Line( nLin-nSalto+2 , nCol1, nLin+2, nCol1 )
oPrinter:Line( nLin-nSalto+2 , nCol2-40, nLin+2, nCol2 -40 )
oPrinter:Line( nLin-nSalto+2 , nCol2 + 20, nLin+2, nCol2 + 20 )
oPrinter:Line( nLin-nSalto+2 , nCol2 + 230, nLin+2, nCol2 + 230 )
oPrinter:Line( nLin-nSalto+2 , nCol2 + 320, nLin+2, nCol2 + 320 )
oPrinter:Line( nLin-nSalto+2 , nCol2 + 360, nLin+2, nCol2 + 360 )
oPrinter:Line( nLin-nSalto+2 , nColF, nLin+2, nColF )

oPrinter:Line( nLin+2 , nCol1, nLin + 2, nColF )

Return

/*
Função............: BuscaAd
Objetivo..........: Retorna o valor dos adiantamentos compensados para um título
*/
*------------------------------*
Static Function BuscaAd(cChave)
*------------------------------*
Local nRet := 0

Local aArea := SE5->(GetArea())

SE5->(DbSetOrder(7))
If SE5->(DbSeek(cChave))
	While SE5->(!EOF()) .and. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cChave
		If SE5->E5_TIPODOC == "CP"
			nRet += SE5->E5_VALOR	
		ElseIf SE5->E5_TIPODOC == "ES"
			nRet -= SE5->E5_VALOR	
		EndIf
		SE5->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return nRet