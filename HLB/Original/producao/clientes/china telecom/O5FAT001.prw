#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

#DEFINE MAXLIN 25
#DEFINE MAXLIN2 40

/*
Função..................: O5FAT001
Objetivo................: Tela para seleção dos documentos a serem impressos ( Fatura e Boleto )
Autor...................: Leandro Diniz de Brito ( LDB )  - BRL Consulting
Data....................: 01/04/2018
Cliente HLB.............: China Telecom ( O5 )
*/

*----------------------------------*
User Function O5FAT001
*----------------------------------*
Local cTitulo		:= 'China Telecom - Impressao Fatura\Boleto'
Local cDescription	:= 'Esta rotina permite imprimir as faturas e boletos para as notas fiscais selecionadas, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private aRotina 	:= MenuDef()
Private cPerg 	 	:= 'O5FAT001'
Private cExpAdvPL


/*
If ( cEmpAnt <> 'O5' )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf
*/

AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }
oProcess 	:= tNewProcess():New( "O5FAT001" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)

DbSelectArea( 'SF2' )
Set Filter To

Return

/*
Função..........: SelfNf
Objetivo........: Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelNf( oProcess )
*-------------------------------------------------*
Local oColumn
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade

Private oMarkB

Pergunte( cPerg , .F. )

SF2->( DbSetOrder( 1 ) )

cExpAdvPL     := "DtoS(F2_EMISSAO) >= '" + DtoS( MV_PAR01 ) + "' .And. DtoS(F2_EMISSAO) <= '" + DtoS( MV_PAR02 ) + ;
				"' .And. F2_TIPO = 'N' .And. F2_DOC >= '" + MV_PAR03 + "' .And. F2_DOC <= '" + MV_PAR04 + "'" 

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
ADD COLUMN oColumn DATA { || Transf( F2_VALIRRF , X3Picture( 'F2_VALIRRF' ) )   } 	TITLE "Valor IRRF"     SIZE  3 OF oMarkB
	

/*
* Filtro ADVPL
*/
oMarkB:SetFilterDefault( cExpAdvPL )

oMarkB:ForceQuitButton( .T. )
oMarkB:Activate()

Return


*-------------------------------------------------*
Static Function MenuDef()
*-------------------------------------------------*
Local aRotina 	:= {}

ADD OPTION aRotina TITLE 'Env.Email' ACTION 'u_O5FatImp(.F.)' OPERATION 10 ACCESS 0 
ADD OPTION aRotina TITLE 'Preview' ACTION 'u_O5FatImp(.T.)' OPERATION 11 ACCESS 0

Return aRotina

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1
*-------------------------------------------------*

U_PUTSX1( cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Inicial Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Final Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'03' , 'Da nota' ,'Da nota'/*cPerSpa*/,'Da nota'/*cPerEng*/,'mv_ch3','C' , Len( SF2->F2_DOC )  ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'04' , 'Ate nota' ,'Ate nota'/*cPerSpa*/,'Ate nota'/*cPerEng*/,'mv_ch4','C' , Len( SF2->F2_DOC ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return 

/*
Função..........: O5FatImp
Objetivo........: Imprimir Fatura
*/
*-------------------------------------------------*
User Function O5FatImp( lPreview  ); Return ( MsgRun( 'Gerando documentos.... favor aguarde' , '' , { || Imprime( lPreview ) } ) )
*-------------------------------------------------*

/*
Função..........: Imprime
Objetivo........: Imprimir Fatura
*/
*-------------------------------------------------*
Static Function Imprime( lPreview )
*-------------------------------------------------*    

If !MsgYesNo( 'Confirma geração dos documentos?' )
	Return
EndIf	
	
DbSelectArea( 'SF2' )
Set Filter To &( cExpAdvPL  )

SF2->( DbGotop() )
While SF2->( !Eof() )
	
	If oMarkB:IsMark()
		
		SD2->( DbSetOrder( 3 ) )
		SD2->( DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )		
		lFatura := AllTrim( SD2->D2_CF ) $ GetNewPar( "MV_O5_CF" , "5301/6301/5302/6302/5303/6303" )

		If lFatura
			/*
			* Imprime Fatura
			*/
			cAnexo := ImpFat( lPreview )
			
        Else
        	/*
        		* Imprime Nota de Debito
        	*/
			cAnexo := ImpND( lPreview ) 
			
        EndIf
        
		If !Empty( SF2->F2_DUPL )
			/*
			* Imprime Boleto
			*/
			If !Empty( cAnexo )
				cAnexo += ";"
			EndIf
			
			cAnexo += U_O5FIN001( .T. , lPreview )
		EndIf	

		Sleep( 2000 )        
        
		If !Empty( cAnexo ) .And. !lPreview
			SA1->( DbSetOrder( 1 ) , DbSeek( xFilial( 'SA1' ) + SF2->F2_CLIENTE + SF2->F2_LOJA ) ) 
			
			If !Empty( SA1->A1_EMAIL )
				cSubject := 'China Telecom - ' + If( lFatura , 'Nota Fiscal ' , 'Nota de Debito' )  + SF2->F2_DOC + '.'
				cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
				cEmail += '</head><body>'
				cEmail += '<p align="center"><font face="verdana" size="2">
				cEmail += '<b><u>' + cSubject + '</u></b></p>'
				
				
				cEmail += '<p align="left">Senhores(as)</p> '
				cEmail += '<p align="left">Segue anexo o(s) documento(s) referente a ' + If( lFatura , 'nota fiscal ' , 'nota de debito ' )  + SF2->F2_DOC + ' gerada pelo ERP Protheus Totvs.</p>'
				cEmail += '<br align="left">Cliente : ' + SA1->A1_NREDUZ  + ' .'
				cEmail += '<br align="left">Valor Total NF : R$ ' + AllTrim( Trans( SF2->F2_VALBRUT  , X3Picture( 'F2_VALBRUT' ) ) ) + ' .'
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<b><u> Mensagem automatica, favor nao responder.</u></b>'
				cEmail += '</body></html>'
				
				EnviaEma(cEmail,cSubject,AllTrim( SA1->A1_EMAIL ),,cAnexo)

			Else 
				MsgStop( 'Email do cliente ' + SA1->A1_COD + '- Loja ' + SA1->A1_LOJA + ' nao cadastrado. NF ' + SF2->F2_DOC + ' nao será enviada!' )
				
			EndIf
		EndIf
		
	EndIf
	
	SF2->( DbSkip() )
EndDo

MsgStop( 'Termino processamento.' )

Return 


/*
Função..........: ImpFat
Objetivo........: Impressao da Fatura
*/
*-------------------------------------------------*
Static Function ImpFat( lPreview )
*-------------------------------------------------*
Local cLocal          	:= GetTempPath()

Local lAdjustToLegacy 	:= .F.
Local lDisableSetup  	:= .T.

Local cNomeArq			
Local nLin

Local cPictVal 			:= X3Picture( 'F2_VALMERC' )
Local cDirBol  			:= "\FTP\" + cEmpAnt + "\" 
Local cFile
Local cEmail
Local cSubject
Local cFile				:= ""


Private cPictCnpj			:= "@R 99.999.999/9999-99"
Private cPictCpf		:= "@R 999.999.999-99"

Private oFont8n 		:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont8 			:= TFont():New("Arial",, -10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9 			:= TFont():New("Arial",, -12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New("Arial",, -12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont9in		:= TFont():New("Arial",, -12,.T.,.T.,5,.T.,5,.T.,.F.)
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

Private nCol1 			:= 05
Private nCol2 			:= 35
Private nCol3 			:= 175

Private nCol4 			:= 295
Private nCol5 			:= 380
Private nCol6 			:= 440
Private nCol7 			:= 480

Private nSalto 			:= 12
Private cLogo			:= "logo_o5.bmp"
Private nPage 			:= 0
Private cPedido
Private cCfop
Private nAliqIcm
Private nAliqPC

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
EndIf	


oFont9in:Italic := .T.
oFont9in:Underline := .T.

SA1->( DbSetOrder( 1 ) )
SA1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

SD2->( DbSetOrder( 3 ) )
SD2->( DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
cCfop := SD2->D2_CF
nAliqIcm := SD2->D2_PICM
nAliqPC  := SD2->( D2_ALQIMP5 + D2_ALQIMP6 )

SC5->( DbSetOrder( 1 ) )
SC5->( DbSeek( xFilial() + SD2->D2_PEDIDO ) )

/*
* Busca maior vencimento da NF
*/
dDtVenc := CtoD( '' )
SE1->( DbSetOrder( 2 ) ) //** E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
	xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )
	
	
	If AllTrim( SE1->E1_TIPO ) <> 'NF'
		SE1->( DbSkip() )
		Loop
	EndIf
	
	dDtVenc := Max( dDtVenc , SE1->E1_VENCREA )
	SE1->( DbSkip() )
	
EndDo  


cNomeArq := 'Fatura_' + Alltrim( SF2->F2_DOC ) 

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
oPrinter:SetMargin(70,70,70,70)
oPrinter:cPathPDF := cLocal   

ImpCabec1( @nLin ) 
ImpDetalhe( @nLin )

If File( cLocal+cNomeArq+".rel" )
	FErase(cLocal+cNomeArq+".rel")
EndIf

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
Função..........: ImpCabec1
Objetivo........: Imprimir Cabeçalho\Rodape da Fatura
*/
*-------------------------------*
Static Function ImpCabec1( nLin )
*-------------------------------*
Local nLin1,nLin2                  
Local nSalto := 12


oPrinter:StartPage()

nPage ++
nLin := 45

oPrinter:SayBitmap( nLin , 05 , cLogo, 140, 45)

oPrinter:Say( nLin,170,'Nota Fiscal de Serviços de Telecomunicações',oFont16n)
nLin += ( nSalto * 2 ) 

oPrinter:Say( nLin,250,'Modelo 22 - Serie ' + SF2->F2_SERIE ,oFont9n)
nLin += ( nSalto * 2 ) 

oPrinter:Say( nLin,200,'No. ' + SF2->F2_DOC + ' - Data de Emissão:' + DtoC( SF2->F2_EMISSAO )  ,oFont9n)
nLin += ( nSalto * 4 )

oPrinter:Say( nLin,05,SM0->M0_NOME  ,oFont9n )
nLin += nSalto  

oPrinter:Say( nLin,05,AllTrim( Capital( SM0->M0_ENDCOB ) ) + " - " + AllTrim( SM0->M0_COMPCOB ) + " - CEP:" + Transf( SM0->M0_CEPCOB , "@R 99.999-999" ) + " - " + ;
			AllTrim( Capital( SM0->M0_CIDCOB ) ) + "/" + SM0->M0_CIDCOB   ,oFont8 )
nLin += nSalto  

oPrinter:Say( nLin,05,"CNPJ:" + Transf( SM0->M0_CGC , "@R 99.999.999/9999-99" )  +  " * IE " + Transf( SM0->M0_INSC , "@R 999.999.999.999" ) ,oFont8 )
nLin += ( nSalto * 3 ) 

oPrinter:Box( nLin - 12 , 01 , nLin + ( nSalto * 4  ) + 15 , 555 )
oPrinter:Say( nLin,05,'Tomador dos Serviços'  ,oFont6)
nLin += nSalto 


oPrinter:Say( nLin,05,SA1->A1_NOME  ,oFont9n)
oPrinter:SayAlign( nLin - 8 , 350, "No. Terminal:", oFont8, 70, 15, /*[ nClrText]*/, 1 , 0 )	  
nLin += nSalto 

oPrinter:Say( nLin,05,AllTrim( Capital( SA1->A1_END ) )  + If( !Empty( SA1->A1_COMPLEM ) , " - " + SA1->A1_COMPLEM , "" )  ,oFont8)
oPrinter:SayAlign( nLin - 8 , 350, "CNPJ/CPF:", oFont8, 70,  12, /*[ nClrText]*/, 1 , 0 ) 
oPrinter:Say( nLin  ,430, Transf( SA1->A1_CGC , If( Len( AllTrim( SA1->A1_CGC ) ) < 14 , "@R 999.999.999-99" , "@R 99.999.999/9999-99" ) )  ,oFont8)
nLin += nSalto 

oPrinter:Say( nLin,05,AllTrim( Capital( SA1->A1_BAIRRO ) ) + " - " + AllTrim( Capital( SA1->A1_MUN ) ) + "/" + SA1->A1_EST + " - CEP:" + Transf( SA1->A1_CEP , "@R 99.999-999" )  ,oFont8)
oPrinter:SayAlign( nLin -8  , 350, "Inscrição Estadual:", oFont8, 70,  12, /*[ nClrText]*/, 1 , 0 ) 
oPrinter:Say( nLin ,430, If( !Empty( SA1->A1_INSCR ) , Transf( SA1->A1_INSCR , "@R 999.999.999.999" ) , "" )  ,oFont8)
nLin += nSalto                                                                                                          

oPrinter:SayAlign( nLin - 8 , 350, "CFOP:", oFont8, 70,  12, /*[ nClrText]*/, 1 , 0 ) 
oPrinter:Say( nLin  ,430, cCfop ,oFont8)

nLin += ( nSalto * 3 )  

oPrinter:Box( nLin - 10 , 01 , nLin + ( nSalto * 2  ) - 5  , 555 )                                                                                                       
oPrinter:Say( nLin   ,05 , "Assinante: Outros" ,oFont8)
oPrinter:SayAlign( nLin-8  , 350, "Competencia:", oFont8, 70, 10, /*[ nClrText]*/, 1 , 0 )	  
oPrinter:Say( nLin  ,430, MesExtenso( SF2->F2_EMISSAO ) + "/" + Left( DtoS( SF2->F2_EMISSAO ) , 4 )  ,oFont8)
nLin += nSalto                                                                                                          

oPrinter:Say( nLin  ,05 , "Utilização: Provimento de Acesso a Internet" ,oFont8)
oPrinter:SayAlign( nLin-8  , 350, "Vencimento:", oFont8, 70, 10, /*[ nClrText]*/, 1 , 0 )	  
oPrinter:Say( nLin  ,430, DtoC( dDtVenc )  ,oFont8)
nLin += ( nSalto * 2 )                                                                                                        

oPrinter:Box( nLin  , 01 , nLin + ( nSalto * 3  ) , 555 )                       
nLin += nSalto                                                                                                          
oPrinter:Say( nLin  ,05 , "Observações:" ,oFont8)	                                                                                

nLin += nSalto * 3

If ( nPage == 1 )
	oPrinter:Box( nLin , 01 , nLin + ( nSalto * MAXLIN  )  , 555 )
Else
	oPrinter:Box( nLin , 01 , nLin + ( nSalto * MAXLIN2  )  , 555 )
EndIf 

/*
	* Imprime rodapé na primeira pagina
*/
If ( nPage == 1 )      
	nSalto := 15
	nLin1 :=  nLin + ( nSalto * MAXLIN  ) - 30
	nLin2 :=  nLin1 + ( nSalto * 3  )  
	
	oPrinter:Box( nLin1 , 01 , nLin2 , 555 )
	oPrinter:Line(nLin1 + nSalto , 01 ,nLin1 + nSalto ,555 )
	oPrinter:Line(nLin1 + ( nSalto * 2 ) , 01 ,nLin1 + ( nSalto * 2 ) ,555 )	
	
	nTamH := 554
	nTamCel := Round( nTamH / 4 , 2 )                        
	
	oPrinter:Line( nLin1  , nTamCel  ,nLin1 + ( nSalto * 3 ) ,nTamCel )	 
	oPrinter:Line( nLin1  , nTamCel * 2   ,nLin1 + ( nSalto * 3 ) ,nTamCel * 2 )		
	oPrinter:Line( nLin1  , nTamCel * 3   ,nLin1 + ( nSalto * 3 ) ,nTamCel * 3 )		

	oPrinter:Say( nLin1 + 10 ,03 , "IMPOSTO" ,oFont8n)	
	oPrinter:Say( nLin1 + 10 ,nTamCel + 2 , "ALÍQUOTA(%)" ,oFont8n)	
	oPrinter:Say( nLin1 + 10 ,nTamCel*2 + 2 , "BASE DE CÁLCULO R$" ,oFont8n)	
	oPrinter:Say( nLin1 + 10 ,nTamCel*3 + 2 , "VALOR R$" ,oFont8n)				 
	
	oPrinter:Say( nLin1 + 25 ,03 , "ICMS" ,oFont8n)	
	oPrinter:Say( nLin1 + 25 ,nTamCel + 2 , AllTrim( Transf( nAliqIcm , X3Picture( 'D2_PICM' ) ) ) ,oFont8n)	
	oPrinter:Say( nLin1 + 25 ,nTamCel*2 + 2 , AllTrim( Transf( SF2->F2_BASEICM , X3Picture( 'F2_BASEICM' ) ) ) ,oFont8n)	
	oPrinter:Say( nLin1 + 25 ,nTamCel*3 + 2 , AllTrim( Transf( SF2->F2_VALICM , X3Picture( 'F2_VALICM' ) ) ) ,oFont8n)					 
	
	oPrinter:Say( nLin1 + 39 ,03 , "PIS\COFINS" ,oFont8n)	
	oPrinter:Say( nLin1 + 39 ,nTamCel + 2 , AllTrim( Transf( nAliqPC , X3Picture( 'D2_PICM' ) ) ) ,oFont8n)	
	oPrinter:Say( nLin1 + 39 ,nTamCel*2 + 2 , AllTrim( Transf( SF2->F2_BASIMP5  , X3Picture( 'F2_BASIMP5' ) ) ) ,oFont8n)	
	oPrinter:Say( nLin1 + 39 ,nTamCel*3 + 2 , AllTrim( Transf( SF2->( F2_VALIMP5 + F2_VALIMP6 ) , X3Picture( 'F2_VALIMP5' ) ) ) ,oFont8n)						
	
	oPrinter:Say( nLin2 + 17 ,01 , "Reservado ao Fisco" ,oFont7)						
	oPrinter:Box( nLin2 + 20 , 01 , nLin2 + ( nSalto * 3 ) , 555 )             
	
	If SF3->( DbSetOrder( 4 ) , DbSeek( xFilial() + SF2->( F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE ) ) )
		oPrinter:Say( nLin2 + 35 ,03 , Transf( Upper( SF3->F3_MDCAT79 ) , "@R XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX" ) ,oFont9n)						
	EndIf
	
	oPrinter:Line( nLin2 + ( nSalto * 3 ) + 20 , 01   ,nLin2 + ( nSalto * 3 ) + 20 ,555 )		
	oPrinter:Say( nLin2 + ( nSalto * 3 ) + 27 ,01 , "Contribuições FUST 1.00% e FUNTTEL 0.50% do Valor dos Serviços não repassadas às Tarifas " ,oFont7)							
	
EndIf 

nLin += nSalto
oPrinter:Say( nLin ,nCol1 	, "Item" 		,oFont9in)						
oPrinter:Say( nLin ,nCol2 	, "Descricao" 	,oFont9in)						
oPrinter:Say( nLin ,nCol3 	, "Designação" ,oFont9in)						
oPrinter:Say( nLin ,nCol4 	, "Capacidade" 	,oFont9in)						
oPrinter:Say( nLin ,nCol5	, "Valor" 		,oFont9in)						
oPrinter:Say( nLin ,nCol6	, "Aliquota" 	,oFont9in)						
oPrinter:Say( nLin ,nCol7 	, "ICMS" 		,oFont9in)						

Return



/*
Função..........: ImpDetalhe
Objetivo........: Imprimir Detalhe da Fatura
*/
*-------------------------------*
Static Function ImpDetalhe( nLin )
*-------------------------------*
Local nItem := 0 
Local i

While SD2->( !Eof() .And. D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == ;
				xFilial( 'SD2' ) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )

	SC6->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO + SD2->D2_ITEMPV ) ) 
		
	nItem ++
	If nItem > If( nPage = 1 , MAXLIN , MAXLIN2  )
		oPrinter:EndPage()
		ImpCabec1( @nLin ) 
	EndIf            
	
	nLin += nSalto

	nLinDescr := MLCount( AllTrim( SC6->C6_DESCRI ) , 35 )
	nLinDesi   := MLCount( AllTrim( SC6->C6_P_DESI ) , 20 ) 
	nLinCap   := MLCount( AllTrim( SC6->C6_P_CAP ) , 15 )                 
	
	nMax :=  Max( nLinDescr , nLinDesi )
	nMax :=  Max( nMax , nLinCap)	
	
	oPrinter:Say( nLin ,nCol1 	, SD2->D2_ITEM 		,oFont8)						
	oPrinter:Say( nLin ,nCol2 	, MemoLine( AllTrim( SC6->C6_DESCRI ) , 35 , 1 ) ,oFont8)						
	oPrinter:Say( nLin ,nCol3 	, MemoLine( AllTrim( SC6->C6_P_DESI ) , 20 , 1 ) ,oFont8)						
	oPrinter:Say( nLin ,nCol4 	, MemoLine( AllTrim( SC6->C6_P_CAP ) , 15 , 1 ) 	,oFont8)						
	oPrinter:Say( nLin ,nCol5	, Alltrim( Transf( SD2->D2_TOTAL , X3Picture( 'D2_TOTAL' ) ) ) ,oFont8)						
	oPrinter:Say( nLin ,nCol6	, Alltrim( Transf( SD2->D2_PICM , X3Picture( 'D2_PICM' ) ) ) ,oFont8)						
	oPrinter:Say( nLin ,nCol7 	,  Alltrim( Transf( SD2->D2_VALICM , X3Picture( 'D2_VALICM' ) ) ) ,oFont8)						
	

	For i := 2 To nMax 
		nLin += nSalto	
		nItem ++
		If nItem > If( nPage = 1 , MAXLIN , MAXLIN2  )
			oPrinter:EndPage()
			ImpCabec1( @nLin ) 
		EndIf            
		oPrinter:Say( nLin ,nCol2 	, MemoLine( AllTrim( SC6->C6_DESCRI ) , 35 , i ) ,oFont8)						
		oPrinter:Say( nLin ,nCol3 	, MemoLine( AllTrim( SC6->C6_P_DESI ) , 20 , i ) ,oFont8)						
		oPrinter:Say( nLin ,nCol4 	, MemoLine( AllTrim( SC6->C6_P_CAP ) , 15 , i ) 	,oFont8)							
	Next
	
				
	SD2->( DbSkip() )				
EndDo				

Return


/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
Local cToOculto     := "chinatelecom@hlb.com.br"

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
		SEND MAIL FROM cFrom TO cTo BCC cToOculto ;
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
Função..........: ImpND
Objetivo........: Impressao da Nota de Debito
*/
*-------------------------------------------------*
Static Function ImpND( lPreview )
*-------------------------------------------------*
Local cLocal          	:= GetTempPath()

Local lAdjustToLegacy 	:= .F.
Local lDisableSetup  	:= .T.

Local cNomeArq			
Local nLin

Local cPictVal 			:= X3Picture( 'F2_VALMERC' )
Local cDirBol  			:= "\FTP\" + cEmpAnt + "\" 
Local cFile
Local cEmail
Local cSubject
Local cFile				:= ""


Private cPictCnpj			:= "@R 99.999.999/9999-99"
Private cPictCpf		:= "@R 999.999.999-99"

Private oFont8n 		:= TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont8 			:= TFont():New("Arial",, -10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9 			:= TFont():New("Arial",, -12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New("Arial",, -12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont9in		:= TFont():New("Arial",, -12,.T.,.T.,5,.T.,5,.T.,.F.)
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

Private nCol1 			:= 05
Private nCol2 			:= 35
Private nCol3 			:= 195

Private nCol4 			:= 295
Private nCol5 			:= 380
Private nCol6 			:= 440
Private nCol7 			:= 480

Private nSalto 			:= 12
Private cLogo			:= "logo_o5.bmp"
Private nPage 			:= 0
Private cPedido
Private cCfop
Private nAliqIcm
Private nAliqPC

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
EndIf	


oFont9in:Italic := .T.
oFont9in:Underline := .T.

SA1->( DbSetOrder( 1 ) )
SA1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

SD2->( DbSetOrder( 3 ) )
SD2->( DbSeek( xFilial() + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
cCfop := SD2->D2_CF
nAliqIcm := SD2->D2_PICM
nAliqPC  := SD2->( D2_ALQIMP5 + D2_ALQIMP6 )

SC5->( DbSetOrder( 1 ) )
SC5->( DbSeek( xFilial() + SD2->D2_PEDIDO ) )

/*
* Busca maior vencimento da NF
*/
dDtVenc := CtoD( '' )
SE1->( DbSetOrder( 2 ) ) //** E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
	xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )
	
	
	If AllTrim( SE1->E1_TIPO ) <> 'NF'
		SE1->( DbSkip() )
		Loop
	EndIf
	
	dDtVenc := Max( dDtVenc , SE1->E1_VENCREA )
	SE1->( DbSkip() )
	
EndDo  


cNomeArq := 'Nota_Debito_' + Alltrim( SF2->F2_DOC ) 

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
oPrinter:SetMargin(70,70,70,70)
oPrinter:cPathPDF := cLocal   


ImpDoc( @nLin ) 

If File( cLocal+cNomeArq+".pdf" )
	FErase(cLocal+cNomeArq+".pdf")
EndIf

oPrinter:EndPage()

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
Função..........: ImpDoc
Objetivo........: Imprimir Nota de Debito
*/
*-------------------------------*
Static Function ImpDoc( nLin )
*-------------------------------*
Local nLin1,nLin2                  
Local nSalto := 12


oPrinter:StartPage()

nLin := 85

nPage ++
oPrinter:Box( nLin  , 50 , 800 , 510 )

nLin += 3
oPrinter:SayBitmap( nLin  , 65 , cLogo, 180, 60)
nLin += 15

oPrinter:Say( nLin , 420 	, "FATURA: " + SF2->F2_DOC ,oFont9n)						
nLin += nSalto                                                                      
oPrinter:Say( nLin , 410 	, "EMISSAO: " + DtoC( SF2->F2_EMISSAO ) ,oFont9n)						

nLin += ( nSalto * 4 )

oPrinter:Say( nLin,190,SM0->M0_NOME  ,oFont9n )
nLin += nSalto  

oPrinter:Say( nLin,150,"CNPJ:" + Transf( SM0->M0_CGC , "@R 99.999.999/9999-99" )  +  " - Insc.Municipal: 4.155.848-0 - " +  "Insc.Estadual: " + Transf( SM0->M0_INSC , "@R 999.999.999.999" ) ,oFont7n )
nLin += nSalto  

oPrinter:Say( nLin,160,AllTrim( Capital( SM0->M0_ENDCOB ) ) + " - " + AllTrim( SM0->M0_COMPCOB ) + " - " + AllTrim( Capital( SM0->M0_BAIRCOB ) ) + " - CEP " + Transf( SM0->M0_CEPCOB , "@R 99.999-999" )  ,oFont7n )
nLin += nSalto  

oPrinter:Say( nLin,220,AllTrim( Capital( SM0->M0_CIDCOB ) ) + "/" + SM0->M0_CIDCOB  , oFont7n )

nLin += ( nSalto * 1 ) 

oPrinter:Line( nLin , 50  ,nLin  ,510 )
nLin += nSalto 

oPrinter:Say( nLin,55,"Dados do Cliente"  ,oFont6n )
nLin += nSalto 

oPrinter:Say( nLin,55,SA1->A1_NOME  ,oFont9n)
nLin += nSalto 

oPrinter:Say( nLin  ,55, "CNPJ: " + Transf( SA1->A1_CGC , If( Len( AllTrim( SA1->A1_CGC ) ) < 14 , "@R 999.999.999-99" , "@R 99.999.999/9999-99" ) ) +;
			" - Insc.Estadual: " + If( !Empty( SA1->A1_INSCR ) , Transf( SA1->A1_INSCR , "@R 999.999.999.999" ) , "" )  ,oFont7)
nLin += nSalto 

oPrinter:Say( nLin,55,AllTrim( SA1->A1_END )  + If( !Empty( SA1->A1_COMPLEM ) , " - " + SA1->A1_COMPLEM , "" )  ,oFont7)
nLin += nSalto 

oPrinter:Say( nLin,55,"CEP:" + Transf( SA1->A1_CEP , "@R 99.999-999" ) + " - " + AllTrim( SA1->A1_BAIRRO ) ,oFont7)
nLin += nSalto 

oPrinter:Say( nLin,55, AllTrim( SA1->A1_MUN ) + "/" + SA1->A1_EST ,oFont7)
nLin += nSalto 

oPrinter:Line( nLin , 50  ,nLin  ,510 )
nLin += nSalto 

oPrinter:Say( nLin,55,"Dados sobre o Pagamento:"  ,oFont7n )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"Bank Of America Merril Lynch Banco Múltipo S.A"  ,oFont7n )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"Company Name: China Telecom do Brasil Participações Ltda"  ,oFont7 )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"Checking Account: 1057101-6"  ,oFont7 )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"CNPJ: " + Transf( SM0->M0_CGC , "@R 99.999.999/9999-99" )  ,oFont7 )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"Bank No. 755"  ,oFont7 )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"Branch: 1306"  ,oFont7 )
nLin += nSalto                                               

oPrinter:Say( nLin,55,"DATA DE VENCIMENTO: " + DtoC( dDtVenc )  ,oFont7n )
nLin += nSalto - 5                                             

oPrinter:Line( nLin , 50  ,nLin  ,510 )                      
oPrinter:Line( nLin , 435  ,800  ,435 )                      
oPrinter:Line( 800 - nSalto , 50 ,800 - nSalto ,510 )                     
oPrinter:Say( 795 ,440 	,  Alltrim( Transf( SF2->F2_VALMERC , X3Picture( 'F2_VALMERC' ) ) ) ,oFont8n)						
oPrinter:Say( 795 ,52	, "TOTAL" 	,oFont8n)						
		
nLin += 8                                                             

oPrinter:Say( nLin,240,"DESCRIÇÃO" ,oFont7n )
oPrinter:Say( nLin,450,"VALORES" ,oFont7n )
nLin += 3                                                            
oPrinter:Line( nLin , 50  ,nLin  ,510 )                     

nLIn += 10

While SD2->( !Eof() .And. D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == ;
				xFilial( 'SD2' ) + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )

	SC6->( DbSetOrder( 1 ) , DbSeek( xFilial() + SD2->D2_PEDIDO + SD2->D2_ITEMPV ) ) 

	oPrinter:Say( nLin ,52	, SC6->C6_DESCRI 	,oFont8)						
	oPrinter:Say( nLin ,440 	,  Alltrim( Transf( SD2->D2_TOTAL , X3Picture( 'D2_TOTAL' ) ) ) ,oFont8)						
	nLin += nSalto
				
	SD2->( DbSkip() )				
EndDo			

Return