#INCLUDE "Protheus.ch"   
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
Função................: B1INV001
Objetivo..............: Imprimir Boleto Google 
Autor.................: Leandro Diniz de Brito ( BRL Consulting )
Data..................: 30/10/2015
*/
*------------------------------------------------------------------------*
User Function B1INV001( lPreview , cDoc , cSerie )
*------------------------------------------------------------------------*
Local oPrinter
Local cLocal          	:= GetTempPath() 

Local lAdjustToLegacy 	:= .F. 
Local lDisableSetup  	:= .T.

Local cNomeArq			:= 'Invoice_' + AllTrim( cDoc )
Local cLogo				:= "zoom.bmp"

Local nLinIni			:= 98
Local nColIni			:= 18
Local oFont8n 			:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)  
Local oFont8 			:= TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont7n 			:= TFont():New("Arial",9, 7,.T.,.T.,5,.T.,5,.T.,.F.)

Local oFont7 			:= TFont():New("Arial",9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont6n 			:= TFont():New("Arial",9, 6,.T.,.T.,5,.T.,5,.T.,.F.)

Local oFont6   			:= TFont():New("Arial",9, 6,.T.,.F.,5,.T.,5,.T.,.F.)
Local oBrush
Local oFont10 			:= TFont():New("Arial",9, 10,.T.,.F.,5,.T.,5,.T.,.F.)  
Local oFont10n 			:= TFont():New("Arial",9, 10,.T.,.T.,5,.T.,5,.T.,.F.)  

Local oFont12 			:= TFont():New("Arial",9, 12,.T.,.F.,5,.T.,5,.T.,.F.)  
Local oFont12n 			:= TFont():New("Arial",9, 12,.T.,.T.,5,.T.,5,.T.,.F.)  

Local cDirBol  			:= "\FTP\" + cEmpAnt + "\GTFAT001\" 
Local cFile    			:= ""

Local cPictVal 		:= X3Picture( 'D2_TOTAL' ) 
Local lDeposito
Local cProduto 
Local nSalto 		:= 12  
Local nTaxaUSD 		:= If( SC5->C5_P_TAXA == 0 , 1 , SC5->C5_P_TAXA ) 


SF2->( DbSetOrder( 1 ) , DbSeek( xFilial() + cDoc + cSerie ) ) 
SA1->( DbSetOrder( 1 ) , DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA ) ) 

SD2->( DbSetOrder( 3 ) , DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE ) ) 
SC5->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO ) )    
SC6->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO ) ) 


cProduto := AllTrim( SC6->C6_PRODUTO ) 
lDeposito  := ( SC5->C5_P_CP == '1' ) 


If !lPreview
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.F.,0)
Else
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)
EndIf

/*
Ordem obrigátoria de configuração do relatório
*/
oPrinter:SetResolution(72)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4) 
oPrinter:SetMargin(60,60,60,60) 

/*
nEsquerda, nSuperior, nDireita, nInferior 
*/
oPrinter:cPathPDF := cLocal

oPrinter:StartPage()

/*
Primeiro box 
*/
oPrinter:Box( nLinIni, nColIni, nLinIni+90, nColIni+330, "-4")

/*
Segundo box
*/
oPrinter:Box( nLinIni, nColIni+335, nLinIni+90, nColIni+496, "-4")

/*
Informações do primeiro box
*/
oPrinter:SayBitmap( nLinIni+7, nColIni+2, cLogo, 83, 60)
nLinIni += 17
oPrinter:Say( nLinIni,nColIni+92,AllTrim(SM0->M0_NOMECOM),oFont12n)
oPrinter:Say( nLinIni,nColIni+385,"INVOICE #",oFont12n)

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+92,"CNPJ "+AllTrim( Transf( SM0->M0_CGC , "@R 99.999.999.9999-99" ) ),oFont12n)
oPrinter:Say( nLinIni,nColIni+385,cDoc,oFont12)

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+92,"Insc. Municipal: "+AllTrim( Transf( SM0->M0_INSCM , "@R 9.999.999-9" ) ),oFont10n)

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+92,AllTrim(Capital(SM0->M0_ENDCOB))+"-"+AllTrim(Capital(SM0->M0_BAIRCOB)),oFont8)
oPrinter:Say( nLinIni,nColIni+385,"DATE OF ISSUE",oFont12n)

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+92,AllTrim(Capital(SM0->M0_CIDCOB))+" - "+SM0->M0_ESTCOB,oFont8)

cEmissao := DtoS( SF2->F2_EMISSAO ) 
oPrinter:Say( nLinIni,nColIni+385, Left( cEmissao , 4 ) + '.' + SubsTr( cEmissao , 5 , 2 ) + '.' + Right( cEmissao , 2 ) ,oFont12)

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+92,"financeiro@zoom.com.br - Tel.:" + AllTrim( SM0->M0_TEL ) ,oFont8)

nLinIni += ( nSalto * 4 )

oBrush := TBrush():New( , CLR_GRAY )
   
oPrinter:Fillrect( { nLinIni - 13 , nColIni , nLinIni + 10, 347 }, oBrush, "-2")
oPrinter:Say( nLinIni,nColIni+7, 'Service Description' ,oFont8n) 

oPrinter:Fillrect( { nLinIni - 13 , nColIni + 335 , nLinIni + 10, nColIni+496 }, oBrush, "-2")
oPrinter:Say( nLinIni,nColIni+337, 'Amount' ,oFont8n)


nLinIni += ( nSalto * 3 )
oPrinter:Say( nLinIni,nColIni+7, SC6->C6_DESCRI ,oFont8 )
oPrinter:Say( nLinIni,nColIni+385, "USD " + AllTrim( Transf( SC6->C6_VALOR / nTaxaUSD , cPictVal ) ) ,oFont8 )  

nLinIni += ( nSalto * 3 ) 

oPrinter:Fillrect( { nLinIni - 13 , nColIni , nLinIni + 10, 347 }, oBrush, "-2")
oPrinter:Say( nLinIni,nColIni+7, 'Customer' ,oFont8n)    
oPrinter:Fillrect( { nLinIni - 13 , nColIni + 335 , nLinIni + 10, nColIni+496 }, oBrush, "-2")
oPrinter:Say( nLinIni,nColIni+337, 'Due Date' ,oFont8n) 

nLinIni += ( nSalto * 2 )    

oPrinter:Say( nLinIni,nColIni+7, Capital( SA1->A1_NREDUZ ) ,oFont8 )
nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, Capital( SA1->A1_END ) ,oFont8 )
nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, Capital( SA1->A1_MUN ) ,oFont8 )
nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, Capital( SA1->A1_ESTADO ) ,oFont8 )
oPrinter:Say( nLinIni,nColIni+385, Left( cEmissao , 4 ) + '.' + SubsTr( cEmissao , 5 , 2 ) + '.' + Right( cEmissao , 2 ) ,oFont12)
nLinIni += nSalto      

SYA->( DbSetOrder( 1 ) )
SYA->( DbSeek( xFilial() + SA1->A1_PAIS ) )
oPrinter:Say( nLinIni,nColIni+7, SYA->YA_SIGLA ,oFont8 )    

nLinIni += ( nSalto * 2 )  

oPrinter:Fillrect( { nLinIni - 13 , nColIni , nLinIni + 10, 516 }, oBrush, "-2")
oPrinter:Say( nLinIni,nColIni+7, 'Bank Transfer Information' ,oFont8n)    

nLinIni += ( nSalto * 2 )  

oPrinter:Say( nLinIni,nColIni+7, 'BENEFICIARY BANK' ,oFont8 )   
oPrinter:Say( nLinIni,nColIni+92, 'BANCO ITAU BBA S.A' ,oFont8 )

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, 'ADDRESS' ,oFont8 )
oPrinter:Say( nLinIni,nColIni+92, 'SAO PAULO - BRAZIL' ,oFont8 )

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, 'SWIFT CODE' ,oFont8 )        
oPrinter:Say( nLinIni,nColIni+92, 'ITAUBRSPNHO' ,oFont8 )

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, 'FINAL BENEFICIARY' ,oFont8 )
oPrinter:Say( nLinIni,nColIni+92, AllTrim(SM0->M0_NOMECOM) ,oFont8 )

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, 'BRANCH #' ,oFont8 )               
oPrinter:Say( nLinIni,nColIni+92, '0911' ,oFont8 )

nLinIni += nSalto
oPrinter:Say( nLinIni,nColIni+7, 'ACCOUNT #' ,oFont8 ) 
oPrinter:Say( nLinIni,nColIni+92, '00521-3' ,oFont8 )


If File( cLocal+cNomeArq+".pdf" )
	FErase(cLocal+cNomeArq+".pdf")
EndIf
	
If lPreview
	oPrinter:Preview ()
Else
	oPrinter:Print()
	Sleep( 5000 )

	If CpyT2S( cLocal + cNomeArq + ".pdf" , cDirBol ,.T. )
		cFile := cDirBol + cNomeArq+".pdf"
	Else
		MsgStop( 'Erro na cópia para o servidor, boleto ' + cFileName+  ".pdf" )
	EndIf
	
EndIf


oPrinter:EndPage()
MS_FLUSH()

Return( cFile ) 