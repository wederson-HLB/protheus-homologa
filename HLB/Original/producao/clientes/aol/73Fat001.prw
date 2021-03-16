#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

#DEFINE MAXLIN 790

/*
Função..................: 73Fat001
Objetivo................: Tela para seleção dos documentos a serem impressos ( Fatura e Boleto )
Autor...................: Leandro Diniz de Brito ( LDB )  - BRL Consulting
Data....................: 29/01/2016
Cliente HLB.............: AOL
*/

*----------------------------------*
User Function 73Fat001
*----------------------------------*                                               
Local cTitulo		:= 'OATH - Impressao Fatura\Boleto'
Local cDescription	:= 'Esta rotina permite imprimir as faturas e boletos para as notas fiscais selecionadas, dentro do periodo informado .'

Local oProcess
Local bProcesso

//Private aRotina 	:= MenuDef()
Private cPerg 	 	:= '73FAT001'

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )
Private cTpSel    


If ( cEmpAnt <> '73' )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf


AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }
oProcess 	:= tNewProcess():New( "73FAT001" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)


Return

/*
Função..........: SelfNf
Objetivo........: Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelNf( oProcess )
*-------------------------------------------------*
Local cExpAdvPL
Local oColumn
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade


Private oMarkB
Private cMailTo 	:= GetNewPar( 'MV_P_00064' , '' ) 
Private cMailCob 	:= GetNewPar( 'MV_P_00068' , '' )
Private nMesCob 

Pergunte( cPerg , .F. )

dDtIni 	:= MV_PAR01
dDtFim 	:= MV_PAR02
cTpSel 	:= MV_PAR03
dMesCob := MV_PAR04
 


If ( cTpSel == 1 )

	SetKey( VK_F12 , { || Pergunte( '73FAT002' , .T. ) } )

	SF2->( DbSetOrder( 1 ) )
	cExpAdvPL     := 'F2_EMISSAO >= dDtIni .And. F2_EMISSAO <= dDtFim .And. F2_TIPO = "N" '
	oMarkB := FWMarkBrowse():New()
	oMarkB:SetOnlyFields( { "F2_COND" } )
	oMarkB:SetAlias( 'SF2' )
	oMarkB:SetFieldMark( 'F2_OK' )
	oMarkB:SetValid( bValid )
	
	/*
	* Definição das colunas do browse
	*/
	ADD COLUMN oColumn DATA { || F2_DOC   } 	TITLE "Nota Fiscal"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F2_SERIE   } 	TITLE "Serie"     		SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F2_CLIENTE   } TITLE "Cliente"     	SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F2_LOJA  } 	TITLE "Loja"     		SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F2_EMISSAO   } TITLE "Emissao"     	SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALBRUT + F2_DESCONT , X3Picture( 'F2_VALBRUT' ) )   } 	TITLE "Valor Bruto"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALICM , X3Picture( 'F2_VALICM' ) )   } 	TITLE "Valor Icms"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALISS , X3Picture( 'F2_VALISS' ) )   } 	TITLE "Valor ISS"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALPIS , X3Picture( 'F2_VALPIS' ) )   } 	TITLE "Valor Pis"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALCOFI , X3Picture( 'F2_VALCOFI' ) )   } 	TITLE "Valor Cofins"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALCSLL , X3Picture( 'F2_VALCSLL' ) )   } 	TITLE "Valor CSLL"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F2_VALIRRF , X3Picture( 'F2_VALIRRF' ) )   } 	TITLE "Valor IRRF"     SIZE  4 OF oMarkB	
	
Else
	SF1->( DbSetOrder( 1 ) )
	
	cExpAdvPL     := 'F1_EMISSAO >= dDtIni .And. F1_EMISSAO <= dDtFim .And. F2_TIPO = "D"'
	oMarkB := FWMarkBrowse():New()
	oMarkB:SetOnlyFields( { "F1_COND" } )
	oMarkB:SetAlias( 'SF1' )
	oMarkB:SetFieldMark( 'F1_OK' )
	oMarkB:SetValid( bValid )
	
	/*
	* Definição das colunas do browse
	*/
	ADD COLUMN oColumn DATA { || F1_DOC   } 	TITLE "Nota Fiscal"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F1_SERIE   } 	TITLE "Serie"     		SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F1_FORNECE   } TITLE "Fornecedor"     	SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F1_LOJA  } 	TITLE "Loja"     		SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || F1_EMISSAO   } TITLE "Emissao"     	SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_VALBRUT , X3Picture( 'F1_VALBRUT' ) )   }  TITLE "Valor Bruto"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_VALICM , X3Picture( 'F1_VALICM' ) )   } 	TITLE "Valor Icms"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_ISS , X3Picture( 'F1_ISS' ) )   }			 TITLE "Valor ISS"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_VALPIS , X3Picture( 'F1_VALPIS' ) )   } TITLE "Valor Pis"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_VALCOFI , X3Picture( 'F1_VALCOFI' ) )   } TITLE "Valor Cofins"     SIZE  3 OF oMarkB
	ADD COLUMN oColumn DATA { || Transf( F1_VALCSLL , X3Picture( 'F1_VALCSLL' ) )   } TITLE "Valor CSLL"     SIZE  3 OF oMarkB
	
	
Endif

//WFA - 03/08/2018 - Alterado o método de criação dos botões Processar e Preview. Ticket: #38629
oMarkB:AddButton("Processar"			, { || MsgRun( 'Gerando e transmitindo documentos.... favor aguarde' , '' , { || Imprime(.F.) } )},,,, .F., 2 )
oMarkB:AddButton("Preview"				, { || MsgRun( 'Gerando e transmitindo documentos.... favor aguarde' , '' , { || Imprime(.T.) } )},,,, .F., 2 )

/*
* Filtro ADVPL
*/
oMarkB:SetFilterDefault( cExpAdvPL )

oMarkB:ForceQuitButton( .T. )
oMarkB:Activate()

Return

/*
Função..........: Imprime
Objetivo........: Imprimir Fatura
*/
*-------------------------------------------------*
Static Function Imprime( lPreview )
*-------------------------------------------------*
Local lmpBol                            
Local lImpNF       
Local cAnexo
Local cMailToPar := cMailTo //RSB - 09/11/2017 - Informação do parametro Fatura.
Private cLocal    := "" //RSB - 08/06/2017 - Impressão dos boletos na maquina do usuário.
Private nValImp	:= 0 

//RSB - 08/06/2017 - Impressão dos boletos na maquina do usuário.
If lPreview
	cLocal := ChooseDir()
Else
	cLocal := GetTempPath()
Endif		

Pergunte( '73FAT002' , .F. )
lImpBol := ( MV_PAR01 == 2 .Or. MV_PAR01 == 1 )  
lImpNF := ( MV_PAR01 == 3 .Or. MV_PAR01 == 1 )
        
/*
* Imprime Fatura ou Nota de Crédito
*/
If ( cTpSel == 1 )
	
	SF2->( DbGotop() )
	While SF2->( !Eof() )
		
		If ( SF2->F2_OK == oMarkB:Mark() )
			
			/*
			* Imprime Ambos ou Fatura
			*/
			
			cMailTo := cMailToPar  //RSB - 09/11/2017 - Informação do parametro Fatura.
			cAnexo := ""
			If ( lImpNF )
				cAnexo := ImpFat( .T. , lPreview )
				Sleep( 2000 )
			EndIf
			
			/*
			* Imprime Ambos ou Boleto
			*/
			If !Empty( cAnexo )
				cAnexo += ";"
			EndIf
			
			If ( lImpBol )
				cAnexo += U_73FIN001(.T. , lPreview )
				Sleep( 2000 )
			EndIf
			
			If !Empty( cAnexo )
				cSubject := 'Fatura\Boleto OATH - Nota de Débito ' + SF2->F2_DOC + '.'
				cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
				cEmail += '</head><body>'
				cEmail += '<p align="center"><font face="verdana" size="2">
				cEmail += '<b><u>' + cSubject + '</u></b></p>'
				
				
				cEmail += '<p align="left">Prezado Cliente</p> '
				cEmail += '<p align="left">Anexo o(s) documento(s) da nota ' + SF2->F2_DOC + ', referente a veiculação da OATH.</p>'
				cEmail += '<br align="left">Agência : ' + Posicione( 'SA1' , 1 , xFilial( 'SA1' ) + SF2->F2_CLIENT + SF2->F2_LOJENT , 'A1_NREDUZ' )  + ' .' 				
				cEmail += '<br align="left">Cliente : ' + Posicione( 'SA1' , 1 , xFilial( 'SA1' ) + SF2->F2_CLIENTE + SF2->F2_LOJA , 'A1_NREDUZ' )  + ' .'				
				cEmail += '<br align="left">Contrato : '+CodEmpresa(xFilial( 'SF2' ),SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA) 
				cEmail += '<br align="left">Valor Total ND : R$ ' + AllTrim( Trans( SF2->F2_VALBRUT - nValImp , X3Picture( 'F2_VALBRUT' ) ) ) + ' .'								
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<p align="left">Dúvidas ou solicitação de prorrogação, por favor, entrar em contato com o e-mail: oath-cobranca@hpe.com</p> '
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<b><u> Mensagem automatica, favor nao responder.</u></b>'
				cEmail += '</body></html>'
				
				//RSB - 05/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.
				cCliEmail := Alltrim(Posicione( 'SA1' , 1 , xFilial( 'SA1' ) + SF2->F2_CLIENTE + SF2->F2_LOJA , 'A1_EMAIL' ))

				If !Empty(cCliEmail)				
			   		cMailTo += ";" + cCliEmail
				Endif
				
				EnviaEma(cEmail,cSubject,cMailTo,,cAnexo)			
			
			EndIf      
			
		EndIf
		
		SF2->( DbSkip() )
	EndDo
	
Else

	SF1->( DbGotop() )
	While SF1->( !Eof() )
		
		If ( SF1->F1_OK == oMarkB:Mark() )

			/*
			* Imprime Nota de Credito
			*/
			cMailTo := cMailToPar  //RSB - 09/11/2017 - Informação do parametro Fatura.
			cAnexo := ImpFat( .F. , lPreview ) 
			
			If !Empty( cAnexo )
				cSubject := 'Nota de Crédito OATH - ' + SF1->F1_DOC + '.'
				cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
				cEmail += '</head><body>'
				cEmail += '<p align="center"><font face="verdana" size="2">
				cEmail += '<b><u>' + cSubject + '</u></b></p>'
				
				
				cEmail += '<p align="left">Senhores(as)</p> '
				cEmail += '<p align="left">Segue anexo o(s) documento(s) referente a nota de crédito ' + SF1->F1_DOC + ' gerada pelo ERP Protheus Totvs</p>'
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<b><u> Mensagem automatica, favor nao responder.</u></b>'
				cEmail += '</body></html>'
				
				//RSB - 05/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.
				//WFA - 06/08/2018 - Posicione estava buscando o campo F1_CLIENTE, alterado para F1_FORNECE. Ticket: #38629
				cCliEmail := Alltrim(Posicione( 'SA1' , 1 , xFilial( 'SA1' ) + SF1->F1_FORNECE + SF1->F1_LOJA , 'A1_EMAIL' ))
				
				If !Empty(cCliEmail)				
			   		cMailTo += ";" + cCliEmail
				Endif
				
				EnviaEma(cEmail,cSubject,cMailTo,,cAnexo)			

			EndIf      			
		                        
		Endif	
	    
		SF1->( DbSkip() )
		
	EndDo	

EndIf

//RSB - 05/10/2017 - Projeto E-mail de Vendas - Buscar o e-mail do cliente no cadastro de clientes.
cMailTo := cMailToPar

Return


/*
Função..........: ImpFat
Objetivo........: Impressao da Fatura
*/
*-------------------------------------------------*
Static Function ImpFat( lFat , lPreview )
*-------------------------------------------------*
//Local cLocal          	:= GetTempPath()

Local lAdjustToLegacy 	:= .F.
Local lDisableSetup  	:= .T.

Local cNomeArq			
Local nLin

Local cPictVal 			:= X3Picture( 'F2_VALMERC' )
Local cDirBol  			:= "\FTP\" + cEmpAnt + "\73FAT001\" 
Local cFile
Local cEmail
Local cSubject
Local cFile				:= ""


Private cPictCnpj		:= "@R 99.999.999/9999-99"
Private cPictCpf		:= "@R 999.999.999-99"

Private oFont8n 		:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont8 			:= TFont():New("Arial",, -10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9 			:= TFont():New("Arial",, -12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New("Arial",, -12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont7n 		:= TFont():New("Arial",9, 7,.T.,.T.,5,.T.,5,.T.,.F.)

Private oFont7 			:= TFont():New("Arial",9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont6n 		:= TFont():New("Arial",9, 6,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont6   		:= TFont():New("Arial",9, 6,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont16   		:= TFont():New("Arial",, -16,,.F.)
Private oFont16n 		:= TFont():New("Arial",, 16,,.T.)


Private oBrush  		:= TBrush():New( , CLR_GRAY )
Private oFont12n 		:= TFont():New("Arial",9, 12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont18n 		:= TFont():New("Arial",9, 18,.T.,.T.,7,.T.,7,.T.,.F.)

Private oFont22n 		:= TFont():New("Arial",9, 22,.T.,.T.,7,.T.,7,.T.,.F.)
Private oPrinter

Private nCol1 			:= 20
Private nCol2 			:= 200
Private nCol3 			:= 270

Private nCol4 			:= 350
Private nCol5 			:= 490
Private nColF 			:= 540

Private nSalto 			:= 12
Private cLogo			:= "aol.png"
Private nPage 			:= 0
Private cPedido
Private lFatura			:= lFat          

//RSB - 08/06/2017 - Impressão dos boletos na maquina do usuário.
If Type("cLocal") <> "C" 
	cLocal := GetTempPath()	                     	
Endif

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\73FAT001\" )		
EndIf	



If ( !lFatura )
	SD1->( DbSetOrder( 1 ) , DbSeek( xFilial() + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	SF2->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA ) )
EndIf

SA1->( DbSetOrder( 1 ) )
SA1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

SD2->( DbSetOrder( 3 ) )
SD2->( DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

SC5->( DbSetOrder( 1 ) )
SC5->( DbSeek( xFilial() + SD2->D2_PEDIDO ) )

cNomeArq := If( lFatura , 'Fatura_' + Alltrim( SF2->F2_DOC ) , 'Nota_Credito_' + Alltrim( SF1->F1_DOC ) ) + "_" + Alltrim( SC5->C5_P_REF ) 

cPedido := SD2->D2_PEDIDO

If !lPreview
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.F.,0)
Else
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)
EndIf


/*
* Ordem obrigátoria de configuração do relatório
*/
oPrinter:SetResolution(72)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(60,60,60,60)
oPrinter:cPathPDF := cLocal   


ImpCabec( @nLin )

nLin += ( nSalto * 2 )

oPrinter:Say( nLin,nCol1, 'Cobrar de: ',oFont9)
oPrinter:Say( nLin,nCol3, 'Vendido para: ',oFont9)

nLin += nSalto

oPrinter:Say( nLin,nCol1, 'ID de cliente: ' + SF2->F2_CLIENT ,oFont9n)
oPrinter:Say( nLin,nCol3, 'ID de cliente: ' + SF2->F2_CLIENTE ,oFont9n)


SA1->( DbSetOrder( 1 ) )
SA1->( DbSeek( xFilial() + SF2->F2_CLIENT + SF2->F2_LOJENT ) )
aDadosCob := { SA1->A1_NOME , AllTrim( SA1->A1_END ) + AllTrim( SA1->A1_BAIRRO ) , AllTrim( SA1->A1_MUN ) + " " +  AllTrim( SA1->A1_EST ) + " " + AllTrim( Trans( SA1->A1_CEP , "@R 99999-999" ) ) , SA1->A1_CGC , SA1->A1_CODPAIS }

SA1->( DbSeek( xFilial() + SF2->F2_CLIENTE+ SF2->F2_LOJA ) )
aDadosEnt := { SA1->A1_NOME , AllTrim( SA1->A1_END ) + AllTrim( SA1->A1_BAIRRO ) , AllTrim( SA1->A1_MUN ) + " " +  AllTrim( SA1->A1_EST ) + " " + AllTrim( Trans( SA1->A1_CEP , "@R 99999-999" ) ) , SA1->A1_CGC , SA1->A1_CODPAIS }

//AOA - 18/10/2016 - Ajuste para trazer o nome do pais corretamente.
CCH->( DbSetOrder( 1 ) )
CCH->( DbSeek( xFilial() + aDadosCob[5] ) )
aDadoPCob := CCH->CCH_PAIS

CCH->( DbSeek( xFilial() + aDadosEnt[5] ) )
aDadoPEnt := CCH->CCH_PAIS

nLin += nSalto

oPrinter:Say( nLin,nCol1, aDadosCob[ 1 ] ,oFont9)
oPrinter:Say( nLin,nCol3, aDadosEnt[ 1 ] ,oFont9)

nLin += nSalto

oPrinter:Say( nLin,nCol1, aDadosCob[ 2 ] ,oFont9)
oPrinter:Say( nLin,nCol3, aDadosEnt[ 2 ] ,oFont9)

nLin += nSalto

oPrinter:Say( nLin,nCol1, aDadosCob[ 3 ] ,oFont9)
oPrinter:Say( nLin,nCol3, aDadosEnt[ 3 ] ,oFont9)

nLin += nSalto

oPrinter:Say( nLin,nCol1, aDadoPCob ,oFont9)
oPrinter:Say( nLin,nCol3, aDadoPEnt ,oFont9)

nLin += ( nSalto * 2 )
oPrinter:Say( nLin,nCol1, 'CNPJ: ' + Transf( aDadosCob[ 4 ] , cPictCNPJ ) ,oFont9)
oPrinter:Say( nLin,nCol3, 'CNPJ: ' + Transf( aDadosEnt[ 4 ] , cPictCNPJ ) ,oFont9)

nLin += nSalto * 0.5
oPrinter:Line( nLin , nCol1, nLin , nColF )

nLin += ( nSalto * 2 )
oPrinter:Say( nLin,nCol1, 'Informações de cobranças importantes' ,oFont9)

oBrush1  		:= TBrush():New( , Rgb( 190,190,190 ) )
oBrush2  		:= TBrush():New( , Rgb( 211,211,211 ) )

oPrinter:Fillrect( {nLin-10, nCol3-5, nLin+5, nColF }, oBrush1, "-2")
oPrinter:Fillrect( {nLin+5, nCol3-5, nLin+( nSalto * If( lFatura , 2 , 1 ) ) + 5, nColF }, oBrush2, "-2")
oPrinter:Say( nLin,nCol3, 'Resumo' ,oFont9n)

nLin += nSalto
oPrinter:Say( nLin,nCol1, 'Deseja receber faturas eletrônicas ou precisa atualizar suas ' ,oFont8)


/*
* Busca maior vencimento da NF
*/
nValImp := 0
If ( lFatura )  
	
	dDtVenc := CtoD( '' )
	SE1->( DbSetOrder( 2 ) ) //** E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE1->( DbSeek( xFilial() + SF2->F2_CLIENT + SF2->F2_LOJENT + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
	While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
		xFilial('SE1') + SF2->F2_CLIENT + SF2->F2_LOJENT + SF2->F2_PREFIXO + SF2->F2_DUPL )
		
		
		If AllTrim( SE1->E1_TIPO ) <> 'NF'
			SE1->( DbSkip() )
			Loop
		EndIf
		
		//dDtVenc := Max( dDtVenc , SE1->E1_VENCREA )
		dDtVenc := Max( dDtVenc , SE1->E1_VENCTO )
		//nValImp += SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		
		SE1->( DbSkip() )
		
	EndDo  
	
	If Empty( dDtVenc )
		SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
		While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
			xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )
			
			
			If AllTrim( SE1->E1_TIPO ) <> 'NF'
				SE1->( DbSkip() )
				Loop
			EndIf
			
			//dDtVenc := Max( dDtVenc , SE1->E1_VENCREA ) 
			dDtVenc := Max( dDtVenc , SE1->E1_VENCTO )
			//nValImp += SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			
			SE1->( DbSkip() )
			
		EndDo  	
	EndIf
	
	oPrinter:Say( nLin,nCol3, 'Total Devido :' ,oFont9n)
	oPrinter:Say( nLin,nCol3 + 80, 	'R$ ' + AllTrim( Transf( SF2->F2_VALBRUT /*- nValImp*/ , cPictVal ) ) + ' (BRL)',oFont9n)
	

Else
	oPrinter:Say( nLin,nCol3, 'Valor de Crédito Líquido :' ,oFont9n)
	oPrinter:Say( nLin,nCol3 + 120, 	'R$ ' + AllTrim( Transf( SF1->F1_VALBRUT * -1 , cPictVal ) ) + ' (BRL)',oFont9n)

EndIf


nLin += nSalto
oPrinter:Say( nLin,nCol1, 'informações de cobrança?' , oFont8) 

If ( lFatura )
	oPrinter:Say( nLin,nCol3, 'Vencimento do pagamento em : '  ,oFont9)
	oPrinter:Say( nLin,nCol4 + 60 , DtoC( dDtVenc )  ,oFont9)
EndIf

nLin += nSalto
oPrinter:Say( nLin,nCol1, 'Enviar um email para ' + Alltrim( cMailCob ) , oFont8)

nLin += ( nSalto * 2 )
oPrinter:Say( nLin,nCol1, 'Nome da campanha: ' + If( SC5->( FieldPos( 'C5_P_CAMP' ) ) > 0 , SC5->C5_P_CAMP , "" )   ,oFont9 )

nLin += nSalto * 0.5
oPrinter:Line( nLin , nCol1, nLin , nColF )

nLin += nSalto
oPrinter:Say( nLin,nCol1, 'Descrição do Posicionamento do Anúncio'  ,oFont8)
oPrinter:Say( nLin,nCol3-80, 'Nr.It.Pedido'  ,oFont8)
oPrinter:Say( nLin,nCol3-20, 'Data de Início'  ,oFont8)
oPrinter:Say( nLin,nCol3+40, 'Data de Termino'  ,oFont8)
oPrinter:Say( nLin,nCol3+110, 'Impressões'  ,oFont8)
oPrinter:Say( nLin,nCol3+160, 'Unidade'  ,oFont8)
oPrinter:Say( nLin,nColF-65, 'Fatura'  ,oFont8)

nLin += nSalto * 0.5
oPrinter:Line( nLin , nCol1, nLin , nColF )
SC6->( DbSetOrder( 1 ) )
If ( lFatura )
	
	nCont := 0
	While SD2->( !Eof() .And. D2_FILIAL + D2_DOC + D2_SERIE == xFilial( 'SD2' ) + SF2->F2_DOC + SF2->F2_SERIE )
		
		SC6->( DbSeek( xFilial() + SD2->D2_PEDIDO + SD2->D2_ITEMPV ) )
		
		nCont ++
		
		SomaLinha( @nLin )

	    //MSM - 17/06/2016 - Tratamento para quebra de linha quando texto for muito grande
		cDescPro:=alltrim(SC6->C6_DESCRI)
		aDescPro:={}
		if len(cDescPro)>36
			While len(cDescPro)>0
				AADD(aDescPro,substr(cDescPro,1,36))
				cDescPro:=alltrim(substring(cDescPro,37,len(cDescPro))) 
		    enddo
		endif
		
		nLinF:=5
		If Mod( nCont , 2 ) <> 0
			if len(aDescPro)>0
				nLinF:=(7*len(aDescPro))
			endif
			oPrinter:Fillrect( {nLin-nSalto+1, nCol1, nLin+nLinF, nColF }, oBrush2, "-2")
		EndIf
		
		if len(aDescPro)==0
			oPrinter:Say( nLin,nCol1, cDescPro   ,oFont8)
		else
			for nIPro:=1 to len(aDescPro)
				oPrinter:Say( nLin,nCol1, aDescPro[nIPro]   ,oFont8)
				if nIPro<>len(aDescPro)
			   		SomaLinha( @nLin , 0.8 )
			 	endif
			next
		endif

		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nCol3-80, SD2->D2_ITEM  ,oFont8)
		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nCol3-20, DtoC( SC6->C6_P_DTINI )  ,oFont8)
		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nCol3+40, DtoC( SC6->C6_P_DTFIM )  ,oFont8)
		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nCol3+110, AllTrim( Str( SC6->C6_P_VAL01 ) )  ,oFont8)
		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nCol3+160, SC6->C6_P_UMIMP  ,oFont8)		
		oPrinter:Say( nLin-((nSalto*0.8)/len(aDescPro)),nColF-65, Alltrim( Transf( SD2->D2_TOTAL + SD2->D2_DESCON , cPictVal ) ) ,oFont8)
				
		SomaLinha( @nLin , 0.5 )
		oPrinter:Line( nLin , nCol1, nLin , nColF )
		
		SD2->( DbSkip() )
	EndDo
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Subtotal Bruto: R$ ' + AllTrim( Transf( SF2->F2_VALBRUT + SF2->F2_DESCONT  , cPictVal ) ) + ' (BRL)'  ,oFont9)
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Desconto da Agência : R$ ' + AllTrim( Transf( SF2->F2_DESCONT , cPictVal ) ) + ' (BRL)'  ,oFont9 ) 
	
	/*
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Impostos: R$ ' + AllTrim( Transf( nValImp , cPictVal ) ) + ' (BRL)'  ,oFont9 )	
	*/
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Total devido: R$ ' + AllTrim( Transf( SF2->F2_VALBRUT /*- nValImp*/ , cPictVal ) ) + ' (BRL)'  ,oFont9n )
	
	SomaLinha( @nLin )
	cMenNota:= alltrim(SC5->C5_MENNOTA)
	aMenNota:= {}
	nTotMen:=  85

    //MSM - 17/06/2016 - Tratamento para quebra de linha quando texto for muito grande	
	oPrinter:Say( nLin,nCol1, 'Comentários:' ,oFont9 )

	if len(cMenNota)>85
		While len(cMenNota)>0
			if len(aMenNota)==0
				nTotMen:=85
			else
				nTotMen:=85+5
			endif
			
			AADD(aMenNota,substr(cMenNota,1,nTotMen))
			cMenNota:=alltrim(substring(cMenNota,nTotMen+1,len(cMenNota))) 
			
	    Enddo
	else
		oPrinter:Say( nLin,nCol1,space(23)+ SC5->C5_MENNOTA  ,oFont9 )
	endif
	
	for nIMen:=1 to len(aMenNota)
		if nIMen==1
			oPrinter:Say( nLin,nCol1, space(23)+aMenNota[nIMen]  ,oFont9 )
		else
			oPrinter:Say( nLin,nCol1, aMenNota[nIMen]  ,oFont9 )
		endif
		if nIMen <> len(aMenNota)
			SomaLinha( @nLin )
		endif
	next
		
	/*
	ImpRodape()
	ImpCabec( @nLin )
    */
    
    If ( nLin + ( nSalto * 10 ) )  > MAXLIN
		ImpRodape()
		ImpCabec( @nLin )    
    EndIf
    
	SomaLinha( @nLin , 2 )
	oPrinter:Fillrect( {nLin-nSalto, nCol1, nLin+5, nColF }, oBrush2, "-2")
	oPrinter:Say( nLin,nCol3-50, 'Instruções de pagamento' ,oFont16 )
	
	SomaLinha( @nLin , 1.5 )
	oPrinter:Say( nLin,nCol2-30, 'Favorecido: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, SM0->M0_NOME ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'OATH CNPJ: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, Alltrim( Transf( SM0->M0_CGC , cPictCnpj ) ) ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Banco: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, 'Banco Santander' ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Nº do banco: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, '033' ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Código SWIFT: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, 'BRCHBRSP' ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Número da conta: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, '13005882-0' ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Nº da agência: ' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, '3853' ,oFont9 )
	
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol2-30, 'Endereço:' ,oFont9 )
	oPrinter:Say( nLin,nCol2+50, 'Banco Santander, Rua Sampaio Viana,22,Paraiso - SP, 04004-000' ,oFont9 )
	
	SomaLinha( @nLin , 3 )
	oPrinter:Say( nLin,nCol1, 'Por favor, informar o CNPJ se o pagamento for realizado via depósito bancário.' ,oFont8 )
	SomaLinha( @nLin , 1 )
	oPrinter:Say( nLin,nCol1, 'Operação não tributada pelo ISSQN, conforme lei complementar n° 116 de 31/07/2003 DOU de 01/08/2003.' ,oFont8 )
	
Else
	nCont := 0  
	nLenItem := Len( SC6->C6_ITEM )   
	nPerc := 0
	While SD1->( !Eof() .And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA  == xFilial( 'SF1' ) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
		
		SD2->( DbSeek( xFilial() + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI ) )
		SC6->( DbSeek( xFilial() + SD2->D2_PEDIDO + Left( SD2->D2_ITEMPV , nLenItem ) ) )
		
		nCont ++
		SomaLinha( @nLin )
		nPerc := Max( nPerc , SD1->D1_DESC ) 

		If Mod( nCont , 2 ) <> 0
			oPrinter:Fillrect( {nLin-nSalto+1, nCol1, nLin+5, nColF }, oBrush2, "-2")
		EndIf

		oPrinter:Say( nLin,nCol1, SC6->C6_DESCRI   ,oFont8)
		oPrinter:Say( nLin,nCol3-80, SC6->C6_ITEM  ,oFont8)
		oPrinter:Say( nLin,nCol3-20, DtoC( SC6->C6_P_DTINI )  ,oFont8)
		oPrinter:Say( nLin,nCol3+40, DtoC( SC6->C6_P_DTFIM )  ,oFont8)
		oPrinter:Say( nLin,nCol3+120, Alltrim( Transf( SC6->C6_P_VAL01 , cPictVal ) )  ,oFont8)
		oPrinter:Say( nLin,nColF-80, Alltrim( Transf( SD1->D1_TOTAL * -1 , cPictVal ) ) ,oFont8)
		
		SomaLinha( @nLin , 0.5 )
		oPrinter:Line( nLin , nCol1, nLin , nColF )
		
		SD1->( DbSkip() )
	EndDo
	

/*
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Subtotal Bruto: R$ ' + AllTrim( Transf( SF1->F1_VALBRUT * -1 , cPictVal ) ) + ' (BRL)'  ,oFont9)
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Desconto da Agência 20.00%: R$ ' + AllTrim( Transf( SF1->F1_VALBRUT * 0.2 * -1 , cPictVal ) ) + ' (BRL)'  ,oFont9 )
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Total devido: R$ ' + AllTrim( Transf( SF1->F1_VALBRUT * 0.8 * -1 , cPictVal ) ) + ' (BRL)'  ,oFont9n )
*/
	                                                                                                                                    
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Subtotal Bruto: R$ ' + AllTrim( Transf( SF1->F1_VALMERC * -1 , cPictVal ) ) + ' (BRL)'  ,oFont9)
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Desconto da Agência ' + StrZero( nPerc , 5 , 2 ) + '%: R$ ' + AllTrim( Transf( SF1->F1_DESCONT * -1 , cPictVal ) ) + ' (BRL)'  ,oFont9 )
	
	SomaLinha( @nLin )
	oPrinter:Say( nLin,nCol4-30, 'Total devido: R$ ' + AllTrim( Transf( SF1->F1_VALBRUT * -1  , cPictVal ) ) + ' (BRL)'  ,oFont9n )
		
EndIf

SomaLinha( @nLin , 0.5 )
oPrinter:Line( nLin , nCol1, nLin , nColF )

SomaLinha( @nLin , 1 )
oPrinter:Say( nLin,nCol1, 'Obrigado' ,oFont9n )

SomaLinha( @nLin , 1 )
oPrinter:Say( nLin,nCol1, 'Sua empresa é realmente importante para nós.' ,oFont9 )


ImpRodape()

If File( cLocal+cNomeArq+".pdf" )
	FErase(cLocal+cNomeArq+".pdf")
EndIf


If lPreview
	oPrinter:Preview()
Else
	oPrinter:Print()
	If CpyT2S( cLocal + cNomeArq + ".pdf" , cDirBol ,.T. )
		cFile := cDirBol + cNomeArq+".pdf"
		
	Else
		
		MsgStop( 'Erro na cópia para o servidor, boleto ' + cNomeArq+  ".pdf" )
	EndIf
EndIf



Return( cFile )

/*
Função..........: ImpCabec
Objetivo........: Imprimir Cabeçalho
*/
*-------------------------------*
Static Function ImpCabec( nLin )
*-------------------------------*
Local cMesCob := ""
Local cDtPed  := ""
Local cPedDt  := ""

//VYB - 28;07/2016 - Alteração da data do documento, para faturas deve buscar a data do pedido de venda
DbselectArea("SC5")
SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
   cDtPed := Alltrim(DtoC(SC5->C5_P_DATA))
   cPedDt := AllTrim(DtoC(SC5->C5_EMISSAO))
EndIf 
//FIM
oPrinter:StartPage()

nPage ++
nLin := 45

oPrinter:SayBitmap( nLin , 05 , cLogo, 140, 37)

nLin += ( nSalto * 2.5 )

If ( lFatura )
	oPrinter:Say( nLin,nCol3, 'No. da Fatura : ',oFont9n)
	oPrinter:Say( nLin,nCol4, SF2->F2_DOC ,oFont9n)
Else
	oPrinter:Say( nLin,nCol3, 'Nota de Crédito : ',oFont9n)
	oPrinter:Say( nLin,nCol4, SF1->F1_DOC ,oFont9n)
EndIf

nLin += nSalto
oPrinter:Say( nLin,nCol3,'No. do Pedido : ',oFont9n)
oPrinter:Say( nLin,nCol4,SC5->C5_P_REF/*cPedido*/,oFont9n)

nLin += nSalto

If ( lFatura )
	//If (nMesCob  == 1 )
	If !Empty(dMesCob)
		//cMesCob := StrZero( Month( SF2->F2_EMISSAO ) , 2 ) + "/" + Str( Year( SF2->F2_EMISSAO ) , 4 ) VYB - 28/07/2016 - Mes de Cobrança aberto para digitação
		cMesCob := StrZero( Month( dMesCob ) , 2 ) + "/" + Str( Year( dMesCob ) , 4 )
	Else
		dDtAux := FirstDay( SF2->F2_EMISSAO ) - 1
		cMesCob := StrZero( Month( dDtAux ) , 2 ) + "/" + Str( Year( dDtAux ) , 4 )
	EndIf
	
Else
 //	If ( Day( SF1->F1_EMISSAO ) <= 15 )
 //		dDtAux := FirstDay( SF1->F1_EMISSAO ) - 1
 //		cMesCob := StrZero( Month( dDtAux ) , 2 ) + "/" + Str( Year( dDtAux ) , 4 )
 //	Else
		cMesCob := StrZero( Month( SF1->F1_EMISSAO ) , 2 ) + "/" + Str( Year( SF1->F1_EMISSAO ) , 4 )
//	EndIf
	
EndIf


oPrinter:Say( nLin,nCol1,SM0->M0_NOMECOM,oFont9)
oPrinter:Say( nLin,nCol3,'Mes da Cobrança:',oFont9)
oPrinter:Say( nLin,nCol4, cMesCob ,oFont9)
nLin += nSalto
oPrinter:Say( nLin,nCol1,AllTrim(SM0->M0_ENDCOB)+","+AllTrim(SM0->M0_BAIRCOB),oFont9)
//oPrinter:Say( nLin,nCol1,'Rua Bernadino de Campos,98|Paraiso|Sobreloja-Sala2',oFont9) //RSB - 14/11/2017 - Alteração de dados fixos - #18250
oPrinter:Say( nLin,nCol3,'Data do Documento:',oFont9)

If ( !lFatura )
	oPrinter:Say( nLin,nCol4+10,DtoC( SF1->F1_EMISSAO ),oFont9)
Else
	//oPrinter:Say( nLin,nCol4+10,DtoC( SF2->F2_EMISSAO ),oFont9)
	oPrinter:Say( nLin,nCol4+10, cDtPed ,oFont9)
EndIf
nLin += nSalto
oPrinter:Say( nLin,nCol1,'CEP: ' + AllTrim(SM0->M0_CEPCOB)+" "+AllTrim(SM0->M0_CIDCOB) + " " + AllTrim(SM0->M0_ESTCOB) + "/Brasil" ,oFont9)
//oPrinter:Say( nLin,nCol1,'CEP: 04004-040 São Paulo SP/Brasil' ,oFont9) //RSB - 14/11/2017 - Alteração de dados fixos - #18250
//oPrinter:Say( nLin,nCol3,'Contato de Vendas:',oFont9)
//oPrinter:Say( nLin,nCol4,SA1->A1_CONTATO,oFont9)
oPrinter:Say( nLin,nCol3,'Data do Pedido: ',oFont9)
oPrinter:Say( nLin,nCol4, cPedDt ,oFont9)

nLin += nSalto
oPrinter:Say( nLin,nCol1,'CNPJ: '+Transf( SM0->M0_CGC , cPictCnpj ),oFont9)
oPrinter:Say( nLin,nCol3,'Nº de pedido de inserção da empresa: ' + If( SC5->( FieldPos( 'C5_P_NREMP' ) ) == 0 .Or. Empty( SC5->C5_P_NREMP ) , 'NA' , SC5->C5_P_NREMP )  ,oFont9)

nLin += nSalto
oPrinter:Say( nLin,nCol3,'Nº do pedido de inserção da agência: ' + If( SC5->( FieldPos( 'C5_P_NRAGE' ) ) == 0 .Or. Empty( SC5->C5_P_NRAGE ) , 'NA' , SC5->C5_P_NRAGE ),oFont9)


nLin += nSalto * 0.5
oPrinter:Line( nLin , nCol1, nLin , nColF ) 

nLin += nSalto


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
	ImpRodape()
	ImpCabec( @nLin )
EndIf

Return

/*
Função..........: ImpRodape
Objetivo........: Imprimir Rodape do Documento
*/
*-------------------------------*
Static Function ImpRodape
*-------------------------------*

oPrinter:Say( 805 ,nCol1,'Atendimento ao cliente: ',oFont8)
oPrinter:Say( 805 + nSalto,nCol1,'Email:' + cMailCob ,oFont8)
oPrinter:Say( 805 + nSalto,nCol3,'Pagina ' + AllTrim( Str( nPage , 3 ) ) ,oFont8)
oPrinter:Say( 805 + ( nSalto * 2 ),nCol1,'Telefone: +55 11 5504-2483' /*+ SM0->M0_TEL*/ ,oFont8)

oPrinter:EndPage()

Return


/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1
*-------------------------------------------------*

U_PUTSX1( cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Inicial Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Final Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'03' , 'Tipo Documento' ,'Tipo Documento'/*cPerSpa*/,'Tipo Documento'/*cPerEng*/,'mv_ch3','N' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/"Fatura",/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/"Nota de Crédito",/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'04' , 'Mes Cobrança' ,'Mes Cobrança'/*cPerSpa*/,'Mes Cobrança'/*cPerEng*/,'mv_ch4','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Mes de cobrança ( valido somente " , "para opcao Fatura )" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )


U_PUTSX1( '73FAT002' ,'01' , 'Imprimir' ,'Imprimir'/*cPerSpa*/,'Imprimir'/*cPerEng*/,'mv_ch1','N' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/"Ambos",/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/"Boleto",/*cDefSpa2*/,/*cDefEng2*/,'Fatura'/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/01/2015 10:20
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""


IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF


cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo 		:= AvLeGrupoEMail(cTo)
cCC			:= ""
cFrom		:= AllTrim(GetMv("MV_RELFROM"))
cAttachment := cAnexos

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf
	IF !EMPTY(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ELSE
		SEND MAIL FROM cFrom TO cTo  ;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ENDIF
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. )                                   

/*
Funcao.........: ChooseDir
Objetivo.......: Selecionar arquivo .Xls a ser importado
Autor..........: Richard Steinhauser Busso
*/
*---------------------------------------------*
Static Function ChooseDir
*---------------------------------------------*
Local cTitle        := "Selecione o diretorio"
Local cMask         := "Arquivos (*.txt) |*.txt"
Local nDefaultMask  := 1
Local cDefaultDir   := 'C:\'
Local nOptions      := nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY )
Local cDir 			
Local aNomeArq	:= {}
/*
	* Retorna diretorio selecionado
*/ 
//cDir := cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions , .F. )

cDir := cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions ,.T. , .T. )

Return( cDir )

/*
Funcao.........: C5NREMP
Objetivo.......: Selecionar o numero da Empresa AOL
Autor..........: Richard Steinhauser Busso
*/

Static Function CodEmpresa(cFil,cNum,cSerie,cCliente,cLoja)
Local aArea := GetArea()  
Local cStrSql := ""
Local cC5REMP := ""
Local cRet := ""

cStrSql := " SELECT C5_P_NREMP FROM SC5730 WHERE D_E_L_E_T_ = '' AND C5_FILIAL = '"+cFil+"' AND C5_NOTA = '"+cNum+"' AND C5_SERIE = '"+cSerie+"' AND C5_CLIENTE = '"+cCliente+"' AND C5_LOJACLI = '"+cLoja+"' "	
dbUseArea(.T., "TOPCONN", TcGenQry(,,cStrSql), "XSC5", .T., .F.)     

DBSelectArea("XSC5")
XSC5->(DbGoTop())

cRet := XSC5->C5_P_NREMP

XSC5->(dbCloseArea())  

RestArea(aArea)
	       
Return(cRet)
