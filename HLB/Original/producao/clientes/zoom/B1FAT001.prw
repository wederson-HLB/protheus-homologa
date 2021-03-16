#INCLUDE "Protheus.ch"   
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
Função................: B1FAT001
Objetivo..............: Imprimir Fatura 
Autor.................: Leandro Diniz de Brito ( BRL Consulting )
Data..................: 16/10/2015
*/
*------------------------------------------------------------------------*
User Function B1FAT001( lPreview , cDoc , cSerie )
*------------------------------------------------------------------------*
Local oPrinter
Local cLocal          	:= GetTempPath() 

Local lAdjustToLegacy 	:= .F. 
Local lDisableSetup  	:= .T.

Local cNomeArq			:= 'Fatura_' + AllTrim( cDoc )
Local cLogo				:= "zoom.bmp"

Local nLinIni			:= 88
Local nColIni			:= 18
Local oFont8n 			:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)  
Local oFont8 			:= TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont7n 			:= TFont():New("Arial",9, 7,.T.,.T.,5,.T.,5,.T.,.F.)

Local oFont7 			:= TFont():New("Arial",9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont6n 			:= TFont():New("Arial",9, 6,.T.,.T.,5,.T.,5,.T.,.F.)

Local oFont6   			:= TFont():New("Arial",9, 6,.T.,.F.,5,.T.,5,.T.,.F.)
Local oBrush1 			:= TBrush():New( , CLR_WHITE)                         
Local oFont12n 			:= TFont():New("Arial",9, 12,.T.,.T.,5,.T.,5,.T.,.F.) 
Local oFont22n 			:= TFont():New("Arial",9, 22,.T.,.T.,7,.T.,7,.T.,.F.)  

Local cDirBol  			:= "\FTP\" + cEmpAnt + "\GTFAT001\" 
Local cFile    			:= ""

Local cPictVal 		:= X3Picture( 'F2_VALFAT' ) 
Local lDeposito
Local cProduto


SF2->( DbSetOrder( 1 ) , DbSeek( xFilial() + cDoc + cSerie ) ) 
SA1->( DbSetOrder( 1 ) , DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA ) ) 

SD2->( DbSetOrder( 3 ) , DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE ) ) 
SC5->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO ) )    
SC6->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO ) ) 


cProduto := AllTrim( SC6->C6_PRODUTO ) 
lDeposito  := ( SC5->C5_P_CP == '1' ) 


If ( cProduto $ 'MERC EXTERIOR,MERC EXTERNO' )
	Return( u_B1INV001( lPreview , cDoc , cSerie ) )
EndIf

//oPrinter := FWMSPrinter():New(cNomeArq, IMP_PDF, lAdjustToLegacy,, lDisableSetup)
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
oPrinter:Box( nLinIni, nColIni, nLinIni+58, nColIni+292, "-4")

/*
Segundo box
*/
oPrinter:Box( nLinIni, nColIni+298, nLinIni+58, nColIni+496, "-4")
                
/*
Informações do primeiro box
*/
oPrinter:SayBitmap( nLinIni+2, nColIni+2, cLogo, 73, 55)
oPrinter:Say( nLinIni+07,nColIni+72,AllTrim(SM0->M0_NOMECOM),oFont8n)
oPrinter:Say( nLinIni+16,nColIni+72,"CNPJ "+AllTrim( Transf( SM0->M0_CGC , "@R 99.999.999.9999-99" ) ),oFont7n)
oPrinter:Say( nLinIni+25,nColIni+72,"Insc. Municipal: "+AllTrim( Transf( SM0->M0_INSCM , "@R 9.999.999-9" ) ),oFont7n)
oPrinter:Say( nLinIni+36,nColIni+72,AllTrim(Capital(SM0->M0_ENDCOB))+"-"+AllTrim(Capital(SM0->M0_BAIRCOB)),oFont7)
oPrinter:Say( nLinIni+45,nColIni+72,AllTrim(Capital(SM0->M0_CIDCOB))+" - "+SM0->M0_ESTCOB,oFont7)
oPrinter:Say( nLinIni+54,nColIni+72,"financeiro@zoom.com.br - Tel.:" + AllTrim( SM0->M0_TEL ) ,oFont7)

/*
Informações do segundo box
*/
oPrinter:Say( nLinIni+07,nColIni+300,"FATURA DE SERVIÇOS",oFont7n)
oPrinter:Say( nLinIni+16,nColIni+300,cDoc,oFont7)
oPrinter:Say( nLinIni+25,nColIni+300,"DATA DE EMISSÃO",oFont7n)
oPrinter:Say( nLinIni+34,nColIni+300,DtoC( SF2->F2_EMISSAO ),oFont7)


nLinIni+=58+17

/*
Terceiro box
*/
oPrinter:Box( nLinIni, nColIni, nLinIni+73, nColIni+496, "-4")
oPrinter:Fillrect( {nLinIni-5, nColIni+10, nLinIni+5, nColIni+80 }, oBrush1, "-2")
oPrinter:Say( nLinIni+2,nColIni+12,"Tomador de Serviços",oFont7n)     

oPrinter:Say( nLinIni+12,nColIni + 2,"RAZAO SOCIAL:" ,oFont7n)
oPrinter:Say( nLinIni+12,nColIni + 70 , AllTrim( SA1->A1_NOME ) ,oFont7)	
	
cCnpj := AllTrim( SA1->A1_CGC )
If Len( cCnpj ) < 14
	oPrinter:Say( nLinIni+21,nColIni+2,"CPF:" ,oFont7n)
	oPrinter:Say( nLinIni+21,nColIni + 70 , Transf( cCnpj , "@R 999.999.999-99" ) ,oFont7)	
Else
	oPrinter:Say( nLinIni+21,nColIni+2,"CNPJ:" ,oFont7n)
	oPrinter:Say( nLinIni+21,nColIni + 70 , Transf( cCnpj , "@R 99.999.999.9999-99" ) ,oFont7)	
EndIf	

oPrinter:Say( nLinIni+21,nColIni + 190 ,"INSC.MUNICIPAL:" ,oFont7n)
oPrinter:Say( nLinIni+21,nColIni + 260 , AllTrim( SA1->A1_INSCRM ) ,oFont7)	 

oPrinter:Say( nLinIni+21,nColIni + 340 ,"INSC.ESTADUAL:" ,oFont7n)
oPrinter:Say( nLinIni+21,nColIni + 400 , AllTrim( SA1->A1_INSCR ) ,oFont7)	

oPrinter:Say( nLinIni+30,nColIni + 2,"ENDEREÇO:" ,oFont7n)
oPrinter:Say( nLinIni+30,nColIni + 70 , AllTrim( SA1->A1_END ) ,oFont7)	 

oPrinter:Say( nLinIni+30,nColIni + 340,"BAIRRO:" ,oFont7n)
oPrinter:Say( nLinIni+30,nColIni + 400 , AllTrim( SA1->A1_BAIRRO ) ,oFont7)	 

oPrinter:Say( nLinIni+39,nColIni + 2,"CIDADE:" ,oFont7n)
oPrinter:Say( nLinIni+39,nColIni + 70 , AllTrim( SA1->A1_MUN ) ,oFont7)	  

oPrinter:Say( nLinIni+39,nColIni + 190,"ESTADO:" ,oFont7n)
oPrinter:Say( nLinIni+39,nColIni + 260 , SA1->A1_EST ,oFont7)	  

oPrinter:Say( nLinIni+39,nColIni + 340,"CEP:" ,oFont7n)
oPrinter:Say( nLinIni+39,nColIni + 400 , Transf( SA1->A1_CEP , "@R 99999-999" ) ,oFont7)	 
                                                                          
oPrinter:Say( nLinIni+48,nColIni + 2,"EMAIL:" ,oFont7n)
oPrinter:Say( nLinIni+48,nColIni + 70 , AllTrim( SA1->A1_EMAIL ) ,oFont7)	  


nLinIni+=73+17


/*
Quarto box                                     
*/


oPrinter:Box( nLinIni, nColIni, nLinIni+163, nColIni+496, "-4")
oPrinter:Fillrect( {nLinIni-5, nColIni+10, nLinIni+5, nColIni+95 }, oBrush1, "-2")
oPrinter:Say( nLinIni+2,nColIni+12,"Discriminação de Serviços",oFont7n)

oPrinter:Say( nLinIni+12,nColIni+2,SC6->C6_DESCRI,oFont7) 

Do Case 
	Case cProduto == 'CPC-PREPAGO'
		oPrinter:Say( nLinIni+30,nColIni+2,'Boleto No.' + SC5->C5_P_NUMBO ,oFont7) 	
		oPrinter:Say( nLinIni+120,nColIni+220,'PAGO' ,oFont22n )
		 	
	Case cProduto == 'CPC-POSPAGO'                                                  
		If lDeposito
			oPrinter:Say( nLinIni+30,nColIni+2,'Dados bancarios:'+ Space( 5 ) + 'Banco Itau' + Space( 5 ) + 'Agencia:0911' + Space( 5 ) + 'Conta Corrente:00521-3' ,oFont7) 		
	   	EndIf  
	   	
	Case cProduto == 'CPC-PAYPAL'
		oPrinter:Say( nLinIni+30,nColIni+2,'Comprovante Paypal ' + SC5->C5_P_NUMBO ,oFont7) 	
		oPrinter:Say( nLinIni+120,nColIni+220,'PAGO' ,oFont22n )

	Case cProduto == 'PUB-PREPAGO'
		oPrinter:Say( nLinIni+30,nColIni+2,'Boleto No.' + SC5->C5_P_NUMBO ,oFont7) 	
		oPrinter:Say( nLinIni+120,nColIni+220,'PAGO' ,oFont22n )
		
	Case cProduto == 'PUB-POSPAGO'		
		oPrinter:Say( nLinIni+22,nColIni+2,"Veiculação:" + MesExtenso( SF2->F2_EMISSAO ) + "/" + Str( Year( SF2->F2_EMISSAO ) , 4 ) ,oFont8)      
		oPrinter:Say( nLinIni+32,nColIni+2,"PI no. " + SC5->C5_P_PI  ,oFont8)    
//		oPrinter:Say( nLinIni+42,nColIni+2,"Valor Bruto Negociado: R$ " + AllTrim( Transf( SF2->F2_VALFAT , cPictVal ) ) ,oFont8)
//		oPrinter:Say( nLinIni+52,nColIni+2,"Valor da Comissão da Agência: R$" + AllTrim( Transf( SF2->F2_VALFAT * 0.2 , cPictVal ) ) ,oFont8)
//		oPrinter:Say( nLinIni+62,nColIni+2,"Valor Líquido: R$ " + AllTrim( Transf( SF2->F2_VALFAT * 0.8 , cPictVal ) ) ,oFont8)	
		oPrinter:Say( nLinIni+42,nColIni+2,Memoline( SC5->C5_P_OBS , 80  , 1 ) ,oFont8)			
		oPrinter:Say( nLinIni+52,nColIni+2,Memoline( SC5->C5_P_OBS , 80  , 2 ) ,oFont8)			
		oPrinter:Say( nLinIni+62,nColIni+2,Memoline( SC5->C5_P_OBS , 80  , 3 ) ,oFont8)			
		oPrinter:Say( nLinIni+72,nColIni+2,Memoline( SC5->C5_P_OBS , 80  , 4 ) ,oFont8)			
		oPrinter:Say( nLinIni+82,nColIni+2,Memoline( SC5->C5_P_OBS , 80  , 5 ) ,oFont8)											
        
	Case cProduto == 'PUB-PAYPAL'
		oPrinter:Say( nLinIni+30,nColIni+2,'Comprovante Paypal ' + SC5->C5_P_NUMBO ,oFont7) 	
		oPrinter:Say( nLinIni+120,nColIni+220,'PAGO' ,oFont22n )
		
EndCase


nLinIni+=163+17

/*
Quinto box
*/
oPrinter:Box( nLinIni, nColIni, nLinIni+43, nColIni+292, "-4")
oPrinter:Fillrect( {nLinIni-5, nColIni+10, nLinIni+5, nColIni+80 }, oBrush1, "-2")
oPrinter:Say( nLinIni+2,nColIni+12,"Valor da Fatura",oFont7n)     
oPrinter:Say( nLinIni+12,nColIni+12,"R$ " + AllTrim( Transf( SF2->F2_VALFAT , cPictVal ) ),oFont8)  

cDescValor := Extenso( Round( SF2->F2_VALFAT , 2 ) )
oPrinter:Say( nLinIni+22,nColIni+12, MemoLine( cDescValor , 70 , 1 ) ,oFont7)  
oPrinter:Say( nLinIni+32,nColIni+12, MemoLine( cDescValor , 70 , 2 ) ,oFont7)

/*
Sexto box
*/
oPrinter:Box( nLinIni, nColIni+298, nLinIni+43, nColIni+496, "-4")
oPrinter:Fillrect( {nLinIni-5, nColIni+298+10, nLinIni+5, nColIni+298+80 }, oBrush1, "-2")
oPrinter:Say( nLinIni+2,nColIni+300+12,"Vencimento",oFont7n) 

cVencto:= ''
SE1->( DbSetOrder( 1 ) )
If SE1->( DbSeek( xFilial( "SE1" )+ SF2->F2_PREFIXO + SF2->F2_DUPL ) )
	cVencto:= DtoC( SE1->E1_VENCREA )
Endif                                                        

oPrinter:Say( nLinIni+12,nColIni+300,cVencto,oFont8) 

nLinIni+=43+17

/*
Sétimo box
*/
oPrinter:Box( nLinIni, nColIni, nLinIni+37, nColIni+496, "-4")
oPrinter:Fillrect( {nLinIni-5, nColIni+10, nLinIni+5, nColIni+80 }, oBrush1, "-2")
oPrinter:Say( nLinIni+2,nColIni+12,"Informações Adicionais",oFont7n)
oPrinter:Say( nLinIni+12,nColIni+12,SC5->C5_MENNOTA,oFont7)

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

/*
Função...........: GtEnvDoc()
Objetivo.........: Retornar se deve enviar boleto e/ou fatura
Autor............: Leandro Brito
Parametros.......: cPedido => Numero Pedido de Venda   
Data.............: 26/10/2015
*/                           
*--------------------------------* 
User Function GtEnvDoc( cPedido )
*--------------------------------*      
Local aConditions 	:= {}                                   
Local aRet        	:= { '' , .F. , .F. , '' }                                                                                         

Local nPos 			                                   
Local cProduto       
     

/*
	aConditions[ 1 ] - Produto 
	aConditions[ 2 ] - Envia Fatura 
	aConditions[ 3 ] - Envia Boleto
	aConditions[ 4 ] - Tipo de Mensagem no corpo do e-mail
	aConditions[ 5 ] - Deposito ou boleto
*/ 

SC5->( DbSetOrder( 1 ) )
SC6->( DbSetOrder( 1 ) )
SC5->( DbSeek( xFilial() + cPedido ) )
SC6->( DbSeek( xFilial() + cPedido ) )
cProduto := AllTrim( SC6->C6_PRODUTO )             

Aadd( aConditions , { 'CPC-PREPAGO' 	, .T. , .F.  					, { || u_GtGen037( 3 ) } } )  
Aadd( aConditions , { 'CPC-POSPAGO' 	, .T. , SC5->C5_P_CP == '2'  	, { || u_GtGen037( 1 ) } } )
Aadd( aConditions , { 'CPC-PAYPAL' 		, .T. , .F.  					, { || u_GtGen037( 3 ) } } )
Aadd( aConditions , { 'PUB-PREPAGO' 	, .T. , .F.  					, { || u_GtGen037( 4 ) } } ) 
Aadd( aConditions , { 'PUB-POSPAGO' 	, .T. , SC5->C5_P_CP == '2'  	, { || u_GtGen037( 2 ) } } )
Aadd( aConditions , { 'PUB-PAYPAL' 		, .T. , .F.  					, { || u_GtGen037( 4 ) } } )
Aadd( aConditions , { 'MERC EXTERIOR' 	, .T. , .F.  					, { || u_GtGen037( 5 ) } } )
Aadd( aConditions , { 'MERC EXTERNO' 	, .T. , .F.  					, { || u_GtGen037( 5 ) } } )

nPos := Ascan( aConditions , { | x | x[ 1 ] == cProduto } )

If nPos > 0
	aRet := { aConditions[ nPos ][ 1 ] , aConditions[ nPos ][ 2 ] , aConditions[ nPos ][ 3 ] , Eval( aConditions[ nPos ][ 4 ] ) } 
EndIf 

Return( aRet )

