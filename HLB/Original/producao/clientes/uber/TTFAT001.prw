#Include "Protheus.Ch" 
#Include "Topconn.Ch"

/*
Função.............: TTFAT001
Autor..............: Leandro Diniz de Brito
Objetivo...........: Importar Xml e Txt de Notas de Prestação de Serviço
Cliente HLB........: Uber
Data...............: 23/09/2016
*/                             
*--------------------------------------* 
User Function TTFAT001( aParam )
*--------------------------------------*
Local aArea      	:= GetArea()
Local chTitle    	:= "HLB BRASIL"

Local nRecSM0Bak	:= SM0->( Recno() )    
Local cFilBak  	 	:= cFilAnt 

Local chMsg      	:= "Uber - Importação XML"
Local cTitle

Local cText     	:= "Este programa tem como objetivo importar xml de notas de prestação de serviços e gerar faturamento automatico no Protheus."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord   

Local dDtBkp 	:= dDataBase

Local oProcesss
Local nTpCtb 	

Private aArqInt		:= {}
Private aLog   		:= {}

Private cProduto  	:= PadR( GetMV( 'MV_P_00086' ,, '' )  , Len( SB1->B1_COD ) )
Private cNatureza 	:= PadR( GetMV( 'MV_P_00087' ,, '' )  , Len( SED->ED_CODIGO ) )    

Private cFtp 		:= GetMV( "MV_P_FTP" ,, '' )
Private cLogin		:= GetMV( "MV_P_USR" ,, '' ) 
Private cPass		:= GetMV( "MV_P_PSW" ,, '' ) 

Private oWizard
Private oGetResult

Private oLbx , aDadosLog := {}
Private oBrwPlan

Private cResult     := ""             
Private lJob 		:= ( aParam <> Nil )       

Private aFolderUF   := {}
Private aFilEmp := {}


Begin Sequence

If !lJob .And. ( !cEmpAnt $ '99,GY' )
	MsgStop( 'Empresa nao autorizada.' )
	Break
EndIf                          

If !ExistDir( "\FTP\GY" )
	MakeDir( "\FTP\GY"  )
EndIf 


SM0->( DbSeek( cEmpAnt ) )
While SM0->( !Eof() .And. SM0->M0_CODIGO == cEmpAnt ) 

	Aadd( aFilEmp , { SM0->M0_CGC , SM0->M0_CODFIL , SM0->( Recno() ) } )	

	If Ascan( aFolderUF , Upper( SM0->M0_ESTCOB ) ) ==  0
		Aadd( aFolderUF , Upper( SM0->M0_ESTCOB ) )
	EndIf
	
	SM0->( DbSkip() )
EndDo 

SM0->( DbGoTo( nRecSM0Bak ) )

//aFolderUF:= { 'SP' } //** TESTE

If !ConectaFtp( 'D' )
	If !lJob
		MsgStop( 'Nao foi possivel conectar ao servidor FTP . Favor contatar a TI.' )
	Else
		ConOut( 'Nao foi possivel conectar ao servidor FTP . Favor contatar a TI.' )	
	EndIf	
	Break
EndIf 


If !lJob
	oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord )
	
	oWizard:NewPanel ( ""  , "" , { || .T. }/*bBack*/ , { || ValidaTela() .And.  MsgYesNo( 'Confirma processamento do xml de notas fiscais ?' ) .And. ( Processa( { || Import() } , 'Importando Xml...' ) , .T. ) } ,bFinish ,, { || TelaParam() } /*bExecute*/  )
	oWizard:NewPanel ( "Resultado" , "Resultado do Processamento" , { || .T. }/*bBack*/ , { ||  .T.}  ,bFinish , .T. , { || ExibeLog() } /*bExecute*/  )
	
	oWizard:Activate( .T. )
Else
	Import()
EndIf 


End Sequence

If ( cFilAnt <> cFilBak )
	cFilAnt	:= cFilBak
	SM0->( DbGoTo( nRecSM0Bak ) )
EndIf


RestArea( aArea )
                     
Return

/*
Função...............: TelaParam
Objetivo.............: Tela de Parametros
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function TelaParam
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel ) 
Local oFont   := TFont():New( 'Arial' )    
Local i 
                                           
oFont:nHeight 	:= 16
oFont:Bold		:= .T. 


@10,10 Say "Total de Arquivos encontrados : " + AllTrim( Str( Len( aArqInt ) ) ) Font oFont COLOR CLR_BLUE Size 200,10 Of oPanel Pixel  

@130,10 Button 'Parametros' Size 50,12 Action( TelaSx6() ) Of oPanel Pixel

Return

/*
Função...............: Import
Objetivo.............: Leitura e Importação das notas fiscais XML\TXT Prestação de Serviços 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Outubro/2016
*/
*-----------------------------------------------*
Static Function Import
*-----------------------------------------------*        
Local cXml
Local oXml

Local aNotas
Local i   

Local cError
Local cWarning	

Local lXml

Local nTamArq
Local nLidos 

Local nHFile   
Local aDadosCli

Local aDadosNF             
Local nItem

Local aItensXml  
Local cMun

Local cCodMun
Local cUF

Local cDirSrv 	


Private cArquivo 
Private cCNPJ


aLog := {}

If !lJob
	ProcRegua( Len( aArqInt ) )
EndIf
	
For i := 1 To Len( aArqInt )
    
	cArquivo := aArqInt[ i ][ 1 ] 
	cDirSrv :=  "\FTP\GY\" + aArqInt[ i ][ 2 ]
	
	If !lJob
		IncProc( 'Lendo arquivo ' + cArquivo + ' .' )
	EndIf
	
	If !( '.XML' $ Upper( cArquivo ) ) .And. !( '.TXT' $ Upper( cArquivo ) )
		Loop
	EndIf
		
	lXml := ( '.XML' $ cArquivo )
	cLayout := ''

	If ( lXml )
		cError		:= '' 
		cWarning	:= ''  
		 
		oXml := XmlParserFile( cDirSrv + "\" + cArquivo , "_", @cError, @cWarning )
		
		If !Empty( @cError )  
			Aadd( aLog , { .F. , cArquivo  , '' , '' , 'Erro na leitura do arquivo.' + cError , '' , cFilAnt} )
			Loop	    	
		EndIf    
		
		/*
			* Busca o Layout a ser utilizado
		*/
		If XmlChildEx( oXml , '_NFEPROC' ) <> Nil    
			cUF := oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
			cCNPJ := oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT

			cLayout  := '1'

		ElseIf ( XmlChildEx( oXml , "_GERARNFSERESPOSTA" ) <> Nil  )  .And. ( XmlChildEx( oXml:_GERARNFSERESPOSTA , "_COMPNFSE" ) <> Nil  )  
			cUf := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
            oXml := oXml:_GERARNFSERESPOSTA:_COMPNFSE:_NFSE:_INFNFSE
			cLayout  := '2'  
			 
		ElseIf ( XmlChildEx( oXml , "_CONSULTARNFSERPSRESPOSTA" ) <> Nil  )  .And. ( XmlChildEx( oXml:_CONSULTARNFSERPSRESPOSTA , "_COMPNFSE" ) <> Nil  )  		
			
			cUf := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
			oXml := oXml:_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE
			cLayout  := '2'  
						
		ElseIf ( XmlChildEx( oXml , "_GERARNFSERESPOSTA" ) <> Nil  ) .And. ( XmlChildEx( oXml:_GERARNFSERESPOSTA , "_LISTANFSE" ) <> Nil  ) 
			cUf 	:= oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT
			cCNPJ 	:= oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT
            oXml := oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE
            
			cLayout  := '2'			
			
		EndIf    
	
	Else
		nHFile := FOpen( cDirSrv + "\" + cArquivo ) 
		
		nLidos := 0
		FSeek( nHFile , 0 , 0 ) 
		nTamArq := FSeek( nHFile , 0 , 2 ) 
		FSeek( nHFile , 0 , 0 ) 
		aLinha := LerLinhaTxt( nHFile , nTamArq )
		nLidos := aLinha[ 1 ]
		
		/*
			* Le primeira linha do arquivo para buscar o cnpj do Tomador de servicos
		*/
		If ( nLidos < nTamArq )
			aLinha := LerLinhaTxt( nHFile , nTamArq )
			nLidos := aLinha[ 1 ]
			cLinha := aLinha[ 2 ]
			cCNPJ  := SubStr( cLinha , 71 , 14 )
			
			cLayout := '3'

		EndIf
		
	EndIf
	
	If Empty( cLayout )
		Aadd( aLog , { .F. , cArquivo  , '' , '' , 'Layout nao encontrado.' , '' , cFilAnt } )	
	    Loop
	EndIf 
	
	cCNPJ := PadR( cCNPJ , Len( SM0->M0_CGC ) )
	
	If ( nPosCGC := Ascan( aFilEmp , { | x | x[ 1 ] == cCnpj } ) ) == 0 
		Aadd( aLog , { .F. , cArquivo  , '' , '' , 'CNPJ do Emitente (' + cCNPJ + ') nao encontrado no cadastro de empresas.' , cCNPJ , cFilAnt } )	
	    Loop		
	EndIf
	
	
	If ( cFilAnt <> aFilEmp[ nPosCGC ][ 2 ] )
		cFilAnt := aFilEmp[ nPosCGC ][ 2 ] 
		SM0->( DbGoTo( aFilEmp[ nPosCGC ][ 3 ]  ) )
	EndIf
    
	aDadosCli 	:= {}
	aDadosNF	:= {}
	 	
	Do Case 
		Case ( cLayout == '1' )   //** Ex. : DF
			oNodeCli := oXml:_NFEPROC:_NFE:_INFNFE:_DEST
			aDadosCli := {  SubStr( oNodeCli:_ENDERDEST:_CMUN:TEXT , 3 ) ,; // Codigo Municipio
							StrZero( Val( oNodeCli:_ENDERDEST:_CPAIS:TEXT ) , 5 ) ,; // Pais
							oNodeCli:_ENDERDEST:_NRO:TEXT ,; // Numero
							oNodeCli:_ENDERDEST:_UF:TEXT ,; // UF
							NoAcento( oNodeCli:_ENDERDEST:_XBAIRRO:TEXT ) ,; // Bairro
							NoAcento( oNodeCli:_ENDERDEST:_XLGR:TEXT ) ,; // Endereço 
							NoAcento( oNodeCli:_ENDERDEST:_XMUN:TEXT ) ,; // Nome Municipio
							PadR( NoAcento( oNodeCli:_XNOME:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oNodeCli, "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_CNPJ:TEXT )
			ElseIf XmlChildEx( oNodeCli, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oNodeCli:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli:_ENDERDEST, "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERDEST:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			If XmlChildEx( oNodeCli, "_IDESTRANGEIRO" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_IDESTRANGEIRO:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 						
			
			cChaveNFe := oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
			
			aItensXml := oXml:_NFEPROC:_NFE:_INFNFE:_DET
			If ValType( aItensXml ) <> 'A'			
				aItensXml := { aItensXml }
			EndIf
				
			For nItem := 1 To Len( aItensXml )
				Aadd( aDadosNF , { ;
									StrZero( Val( aItensXml[ nItem ]:_NITEM:TEXT ) , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
									cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
									NoAcento( aItensXml[ nItem ]:_PROD:_XPROD:TEXT ) ,; // Descricao
									Val( aItensXml[ nItem ]:_PROD:_QCOM:TEXT ) ,; // Quantidade  
									Val( aItensXml[ nItem ]:_PROD:_VUNCOM:TEXT ) ,; // Valor Unitario
									Val( aItensXml[ nItem ]:_PROD:_VPROD:TEXT ) ,; // Valor Total
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VALIQ:TEXT ) ,; // Aliq. ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VBC:TEXT ) ,; // Base Calculo ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_ISSQN:_VISSQN:TEXT ) ,;   // Valor ISS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_PIS:TEXT ) ,; // PIS
			                        Val( aItensXml[ nItem ]:_IMPOSTO:_COFINS:TEXT ) ,; // Cofins
			                        oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT ,;   // Chave NFE
			                        StrZero( Val( oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT ) , 9 ) ,; // Numero NF
			                        oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT ,; // Serie NF
			                        StoD( Left( StrTran( oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT , "-" , "" ) , 10 ));  // Emissao
			                        } )
			Next   

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
			
		Case ( cLayout == '2' )   //** Ex. : RJ        
		
			oNodeCli := oXml:_TOMADORSERVICO
			aDadosCli := { SubStr( oNodeCli:_ENDERECO:_CODIGOMUNICIPIO:TEXT , 3 ) ,; // Codigo Municipio
							If( oNodeCli:_ENDERECO:_UF:TEXT <> 'EX' , '01058' , '' ) ,; // Pais
							oNodeCli:_ENDERECO:_NUMERO:TEXT ,; // Numero
							oNodeCli:_ENDERECO:_UF:TEXT ,; // UF
							NoAcento( oNodeCli:_ENDERECO:_BAIRRO:TEXT ) ,; // Bairro
							NoAcento( oNodeCli:_ENDERECO:_ENDERECO:TEXT ) ,; // Endereço 
							'' ,; // Nome Municipio
							PadR( NoAcento( oNodeCli:_RAZAOSOCIAL:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT )
			ElseIf XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli:_ENDERECO, "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			If XmlChildEx( oNodeCli:_ENDERECO , "_IDESTRANGEIRO" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_IDESTRANGEIRO:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 						
			
			aItensXml := oXml:_SERVICO
			If ValType( aItensXml ) <> 'A'			
				aItensXml := { aItensXml }
			EndIf
			nItemNF := 0	
			For nItem := 1 To Len( aItensXml )
				nItemNF += 1
				Aadd( aDadosNF , { ;
									StrZero( nItemNF , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
									cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
									"" /* NoAcento( aItensXml[ nItem ]:_DISCRIMINACAO:TEXT ) */ ,; // Descricao
									1 ,; // Quantidade  
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Unitario
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Total
			                        Val( aItensXml[ nItem ]:_VALORES:_ALIQUOTA:TEXT )*100 ,; // Aliq. ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_BASECALCULO:TEXT ) ,; // Base Calculo ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_VALORISS:TEXT ) ,;   // Valor ISS
			                        0 ,; // PIS
			                        0 ,; // Cofins
			                        '' ,;   // Chave NFE
			                        StrZero( Val( oXml:_IDENTIFICACAORPS:_NUMERO:TEXT ) , 9 ) ,; // Numero NF
			                        oXml:_IDENTIFICACAORPS:_SERIE:TEXT ,; // Serie NF
			                        StoD( Left( StrTran( oXml:_DATAEMISSAO:TEXT , "-" , "" ) , 10 ));  // Emissao
			                        } )
			Next   		

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
			
		Case ( cLayout == '3' )	  //** Ex. : SP ( TXT )	
			
			
			lPrimeiro := .T.
			While nLidos < nTamArq

				If !lPrimeiro  //* Ja leu a primeira linha anteriormente para validar o CPNJ 
					aLinha := LerLinhaTxt( nHFile , nTamArq )
					nLidos := aLinha[ 1 ]
					cLinha := aLinha[ 2 ]
				EndIf 
				
				lPrimeiro := .F.  
				
				aDadosCli := {}
				aDadosNF := {}
				
				If ( SubStr( cLinha , 1 , 1 ) == '2' )

					cUF 	:= SubStr( cLinha , 801 , 2 )
					cMun	:= NoAcento( SubStr( cLinha , 751 , 50 ) )
					cCodMun := ""
					If !Empty( cUF ) .And. cUF <> 'EX' .And. !Empty( cMun ) .And. ;
						CC2->( DbSetOrder( 4 ) , DbSeek( xFilial() + cUF + PadR( cMun , Len( CC2->CC2_MUN ) ) ) )
						
						cCodMun := CC2->CC2_CODMUN
					EndIf   
					
					If Empty( cUF )
						cUF := 'EX' 
					EndIf
	
					aDadosCli := { cCodMun ,; // Codigo Municipio
									If( cUF <> 'EX' , '01058' , '' ) ,; // Pais
									AllTrim( SubStr( cLinha , 681 , 10 ) ) ,; // Numero
									cUF ,; // UF
									AllTrim( SubStr( cLinha , 721 , 30 ) ) ,; // Bairro
									AllTrim( SubStr( cLinha , 631 , 50 ) ) ,; // Endereço 
									cMun ,; // Nome Municipio
									AllTrim( SubStr( cLinha , 553 , 75 ) ) ,; // Nome Cliente     
									AllTrim( SubStr( cLinha , 519 , 14 ) ) ,; // CNPJ/CPF     
									AllTrim( SubStr( cLinha , 803 , 08 ) ) ,; // CEP     								
	                                ""; //** ID Estrangeiro
					               }
					               
					Aadd( aDadosNF , { ;
										StrZero( 1 , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
										cProduto ,; // Cod. Produto 
										"" /*NoAcento( AllTrim( SubStr( cLinha , 1373 , Len( SB1->B1_DESC ) ) )*/ ,; // Descricao
										1 ,; // Quantidade  
										Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Valor Unitario
										Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Valor Total
					                    Val( AllTrim( SubStr( cLinha , 483 , 04 ) ) ) / 100 ,; // Aliq. ISS
					                    Val( AllTrim( SubStr( cLinha , 448 , 15 ) ) ) / 100 ,; // Base Calculo ISS
					                    Val( AllTrim( SubStr( cLinha , 487 , 15 ) ) ) / 100 ,;   // Valor ISS
					                    Val( AllTrim( SubStr( cLinha , 1037 , 15 ) ) ) / 100 ,; // PIS
					                    Val( AllTrim( SubStr( cLinha , 1052 , 15 ) ) ) / 100 ,; // Cofins
					                    "" ,;   // Chave NFE
					                    StrZero( Val( SubStr( cLinha , 2 , 8 ) ) , 9 ) ,; // Numero NF
					                    'RPS' ,; // Serie NF
					                    StoD( SubStr( cLinha , 10 , 8 ) );  // Emissao
					                   } )
				EndIf						

				If Len( aDadosNF ) > 0
					GravaNF( aDadosCli , aDadosNF )
				EndIf				
			
			EndDo
			
			FClose( nHFile )						
					
		Case ( cLayout == '4' )   //** Ex. : MG        
		
			oNodeCli := oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_TOMADORSERVICO
			aDadosCli := { SubStr( oNodeCli:_ENDERECO:_CODIGOMUNICIPIO:TEXT , 3 ) ,; // Codigo Municipio
							If( oNodeCli:_ENDERECO:_UF:TEXT <> 'EX' , '01058' , '' ) ,; // Pais
							oNodeCli:_ENDERECO:_NUMERO:TEXT ,; // Numero
							oNodeCli:_ENDERECO:_UF:TEXT ,; // UF
							NoAcento( oNodeCli:_ENDERECO:_BAIRRO:TEXT ) ,; // Bairro
							NoAcento( oNodeCli:_ENDERECO:_ENDERECO:TEXT ) ,; // Endereço 
							'' ,; // Nome Municipio
							PadR( NoAcento( oNodeCli:_RAZAOSOCIAL:TEXT ) , Len( SA1->A1_NOME ) ) } // Nome Cliente     
							
			If XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CNPJ" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT )
			ElseIf XmlChildEx( oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ, "_CPF" ) <> Nil 
				AAdd( aDadosCli  , oNodeCli:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf  
			
			If XmlChildEx( oNodeCli:_ENDERECO, "_CEP" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_CEP:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 			 
			
			If XmlChildEx( oNodeCli:_ENDERECO , "_IDESTRANGEIRO" ) <> Nil	
				AAdd( aDadosCli  , oNodeCli:_ENDERECO:_IDESTRANGEIRO:TEXT )
			Else
				AAdd( aDadosCli , '' )
			EndIf 						
			
			aItensXml := oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_SERVICO
			If ValType( aItensXml ) <> 'A'			
				aItensXml := { aItensXml }
			EndIf
			nItemNF := 0	
			For nItem := 1 To Len( aItensXml )
				nItemNF += 1
				Aadd( aDadosNF , { ;
									StrZero( nItemNF , Len( SD2->D2_ITEM ) ) ,;  // Seq. Item
									cProduto /*aItensXml[ nItem ]:_PROD:_CPROD:TEXT*/ ,; // Cod. Produto 
									"" /* NoAcento( aItensXml[ nItem ]:_DISCRIMINACAO:TEXT ) */ ,; // Descricao
									1 ,; // Quantidade  
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Unitario
									Val( aItensXml[ nItem ]:_VALORES:_VALORSERVICOS:TEXT ) ,; // Valor Total
			                        Val( aItensXml[ nItem ]:_VALORES:_ALIQUOTA:TEXT )*100 ,; // Aliq. ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_BASECALCULO:TEXT ) ,; // Base Calculo ISS
			                        Val( aItensXml[ nItem ]:_VALORES:_VALORISS:TEXT ) ,;   // Valor ISS
			                        0 ,; // PIS
			                        0 ,; // Cofins
			                        '' ,;   // Chave NFE
			                        StrZero( Val( oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_IDENTIFICACAORPS:_NUMERO:TEXT ) , 9 ) ,; // Numero NF
			                        oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_IDENTIFICACAORPS:_SERIE:TEXT ,; // Serie NF
			                        StoD( Left( StrTran( oXml:_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAORPS:TEXT , "-" , "" ) , 10 ));  // Emissao
			                        } )
			Next   		

			If Len( aDadosNF ) > 0
				GravaNF( aDadosCli , aDadosNF )
			EndIf				
	
	EndCase

Next 

/*
	* Apaga os arquivos do servidor FTP e move para pasta processados ( [cEmpAnt]\[UF]\Processados )
*/                                                                                                  
ConectaFTP( 'E' )


Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oOK      := LoadBitmap( GetResources() , 'BR_VERDE' )
Local oNO      := LoadBitmap( GetResources() , 'BR_VERMELHO' )

If Len( aLog ) == 0 
	Aadd( aLog , { .T. , '' , '' , '' , 'Sem arquivos a processar.' , '' , cFilAnt } )
EndIf

@04,05 Button 'Exportar Log' Size 50,10 Action( Exporta() ) Of oPanel Pixel
oBrwPlan := TWBrowse():New( 15, 05, 295, 142,,,, oPanel ,,,,,,,,,,,, .F. ,, .T. )
	
aLog := ASort( aLog ,,, { | x , y | x[ 2 ] + x[ 3 ] < y[ 2 ] + y[ 3 ] } ) 
oBrwPlan:SetArray( aLog )
	
oBrwPlan:AddColumn( TCColumn():New( 'Status'       , { || If( aLog[oBrwPlan:nAt,01],  oOK , oNO )  },,,,"CENTER"  ,,.T.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Filial'    , { || aLog[oBrwPlan:nAt,07] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Arquivo'    , { || aLog[oBrwPlan:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Nota'    , { || aLog[oBrwPlan:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Serie'    , { || aLog[oBrwPlan:nAt,04] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'CNPJ'    , { || aLog[oBrwPlan:nAt,06] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Mensagem'       , { || aLog[oBrwPlan:nAt,05] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )

	
oBrwPlan:GoTop()
oBrwPlan:Refresh()
oBrwPlan:bLDblClick := { || .T. }

Return


/*
Função...............: Exporta
Objetivo.............: Exportar Log de processamento para Excel
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Setembro/2016
*/        
*-----------------------------------* 
Static Function Exporta
*-----------------------------------*
Local oExcel, aAux     
Local cFile := GetTempPath() + 'Log_NF_Xml_Ubber_' + DtoS( dDatabase ) + StrTran( Time() , ':' , '' ) + '.xml'
Local i

oExcel := FWMSEXCEL():New()
oExcel:AddWorkSheet("Log")
oExcel:AddTable ("Log","Log da Operacao")   

oExcel:AddColumn("Log","Log da Operacao","Arquivo",1,1,.F.)
oExcel:AddColumn("Log","Log da Operacao","Filial",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Nota",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Serie",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","CNPJ",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Mensagem",1,1,.F.)    


For i := 1 To Len( aLog )
	oExcel:AddRow("Log","Log da Operacao",{ aLog[ i ][ 2 ] ,;
											aLog[ i ][ 7 ] ,;
											aLog[ i ][ 3 ] ,;
											aLog[ i ][ 4 ] ,;
											aLog[ i ][ 6 ] ,;											
											aLog[ i ][ 5 ]  } )

Next   

oExcel:Activate()                                                                                                    

If File( cFile )
	FErase( cFile )
EndIf

oExcel:GetXMLFile( cFile )	

oExcel1:=MsExcel():New()
oExcel1:WorkBooks:Open( cFile )  
oExcel1:SetVisible(.T.)

Return

/*
Funcao.........: ValidaTela
Objetivo.......: Validar tela de parametros
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ValidaTela
*-----------------------------------------*  
  
If Empty( cProduto ) .Or. Empty( cNatureza ) 

	MsgStop( 'Favor preencher todos os parametros. ( Vide botão Parametros ).' )
	Return( .F. )

EndIf

Return( .T. )

/*
Funcao.........: ConectaFTP
Objetivo.......: Conexão ao servidor FTP   
Parametros.....: 'D' => Efetua conexao e download dos arquivos 
				'E' => Efetua conexao e apaga os arquivos do FTP  	 
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ConectaFTP( cOper )
*-----------------------------------------*  
Local lRet := .T.  
Local i,j
Local nTry := 3

Local cDirFtpIn
Local cDirSrv

Begin Sequence

	For i := 1 To nTry 
		If ( lRet := FTPConnect(cFtp,,cLogin,cPass) )
			Exit
		EndIf   
		Sleep( 5000 )
	Next
	
	If !lRet
		Break
	EndIf	 
	
	If ( cOper == 'D' ) //** Efetua download dos arquivos para pasta Protheus 
		
		aArqInt := {}
		For i := 1 To Len( aFolderUF )

			cDirSrv := 	"\FTP\GY\" + aFolderUF[ i ]
			cDirFtpIn	:= "/" + aFolderUF[ i ]
	
			If !ExistDir( cDirSrv )
				MakeDir( cDirSrv )
			EndIf

			FtpDirChange( cDirFtpIn )
			aArqFtp := FtpDirectory( "*.*" , )

			For j := 1 To Len( aArqFtp )  
				aArqFtp[ j ][ 1 ] := Alltrim( aArqFtp[ j ][ 1 ] ) 
				If File( cDirSrv + "\" + aArqFtp[ j ][ 1 ] )
					FErase( cDirSrv + "\" + aArqFtp[ j ][ 1 ] )
				EndIf
				FtpDownload( cDirSrv + "\" + aArqFtp[ j ][ 1 ], aArqFtp[ j ][ 1 ] )
				Aadd( aArqInt , {  aArqFtp[ j ][ 1 ] ,  aFolderUF[ i ] } )   		
			Next  
			

		Next       
		
		aArqInt := ASort( aArqInt ,,, { | x , y | x[ 2 ] + x[ 1 ] < y[ 2 ] + y[ 1 ] } )  
			
	ElseIf ( cOper == 'E' )                    
		
		cDirFtpIn := ''
		For i := 1 To Len( aArqInt )
			
			If ( cDirFtpIn <> aArqInt[ i ][ 2 ] )
		
				cDirSrv := "\FTP\GY\" + aArqInt[ i ][ 2 ]
				cDirFtpIn := "/" + aArqInt[ i ][ 2 ] 
				FtpDirChange( cDirFtpIn )
			
				If !ExistDir( cDirSrv + "\processados" )
					MakeDir( cDirSrv + "\processados" )
				EndIf
		
			EndIf
			
			If FTPErase( aArqInt[ i ][ 1 ] )
						
				/*
				** Move o arquivo de entrada para a pasta 'processado'
				*/
				If File( cDirSrv + "\" + aArqInt[ i ][ 1 ] )
					__COPYFILE( cDirSrv + "\" + aArqInt[ i ][ 1 ] , cDirSrv + "\processados\" + aArqInt[ i ][ 1 ] )
					FErase( cDirSrv + "\" + aArqInt[ i ][ 1 ] )                                                    
					
					/*
						** Compacta arquivos da pasta processados
					*/                                           
					Compacta( cDirSrv + "\processados\" + aArqInt[ i ][ 1 ] , cDirSrv + "\processados\processados.rar" )					
				EndIf  
	
			EndIf
		Next	   
	EndIf
		
	FTPDisconnect()

End Sequence   

Return( lRet )

/*
Funcao.........: TelaSx6
Objetivo.......: Tela de parametros
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function TelaSx6
*-----------------------------------------*     
Local oDlg                       
Local nOpc 		:= 0

Local bOk		:= { || nOpc := 1 , oDlg:End() }
Local bCancel	:= { || nOpc := 0 , oDlg:End() }    

Local cProd  	:= cProduto
Local cNat 		:= cNatureza

Define MSDialog oDlg Title 'Parametros' Of oDlg Pixel From 1,1 To 150,350    

	@10,05 Say 'Produto' Size 40,10 Of oDlg Pixel
	@10,50 MSGet cProd Valid( ExistCpo( 'SB1' , cProd, 1 ) ) F3( 'SB1' ) Size 60,10 Of oDlg Pixel	
	
	@25,05 Say 'Natureza' Size 40,10 Of oDlg Pixel
	@25,50 MSGet cNat Valid( ExistCpo( 'SED' , cNat , 1 ) ) F3( 'SED' ) Size 60,10 Of oDlg Pixel		

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered  

If ( nOpc == 1 )  
	cProduto := cProd
	cNatureza := cNat
	PutMV( 'MV_P_00086' , cProduto )	
	PutMV( 'MV_P_00087' , cNatureza )		
EndIf

Return

/*
Função........: LerLinhaTxt
Objetivo......: Ler linha do arquivo texto até CRLF
Autor.........: Leandro Diniz de Brito
Data..........: 03/10/2016
*/
*-------------------------------------------*
Static Function LerLinhaTxt( nHandle , nTamArq )       
*-------------------------------------------*
Local nBytes    
Local nBloco 	:= 500
Local cBuffer  	:= ""
Local cAux 		:= ""
Local nLidos 	:= FSeek( nHandle , 0 , 1 )

While nLidos < nTamArq
	cAux := ""
	nLidos += FRead( nHandle , @cAux , nBloco )
	
	cBuffer += cAux
	If ( nPos := At( CRLF , cBuffer ) ) > 0     
		nVolta := Len( SubStr( cBuffer , nPos + 2 ) )
		FSeek( nHandle , nVolta * - 1 , 1 )	

		nLidos 	:= FSeek( nHandle , 0 , 1 )
		cBuffer := SubStr( cBuffer , 1 , nPos - 1 )
 		Exit		      
	EndIf    
	
EndDo           

Return( { nLidos , cBuffer } )

/*
Funcao      : NoAcento
Parametros  : 
Retorno     :
Objetivos   : Retira caracteres invalidos da string
Autor       : Leandro Brito
Data/Hora   : 10/10/2016
*/
*-------------------------------*
Static Function NoAcento( cInfo )
*-------------------------------* 
Local i
Local cRet := ""

cRet := FwNoAccent( cInfo )

Return( Upper( AllTrim( cRet ) ) )       

/*
Função........: GravaNF
Objetivo......: Gravar cliente e nota fiscal
Autor.........: Leandro Diniz de Brito
Data..........: 10/10/2016
*/
*----------------------------------------------*
Static Function GravaNF( aDadosCli , aDadosNF )
*----------------------------------------------*
Local i
Local aCab			:= {}
Local aItem	    	:= {} 
Local aAutoItens    := {}
Local aAutoCab		:= {}   

Local cCli
Local cLoja      

Local cUFCli := aDadosCli[ 4 ]  
Local cNF
Local cSerie
Local cLog 

Private lMSErroAuto 

/*
aDadosCli => 	
	[ 1 ] = Codigo Municipio
	[ 2 ] = Codigo Pais
	[ 3 ] = Numero
	[ 4 ] = UF
	[ 5 ] = Bairro
	[ 6 ] = Endereço
	[ 7 ] = Nome Municipio
	[ 8 ] = Nome Cliente 
	[ 9 ] = CNPJ\CGC
	[ 10 ] = CEP 
	[ 11 ] = ID Estrangeiro		

aDadosNF =>
	[ 1 ] = Seq. Item
	[ 2 ] = Cod. Produto 
	[ 3 ] = Descricao
	[ 4 ] = Quantidade
	[ 5 ] = Valor Unitario
	[ 6 ] = Valor Total
	[ 7 ] = Aliq. ISS
	[ 8 ] = Base Calculo ISS
	[ 9 ] = Valor ISS
	[ 10 ] = PIS
	[ 11 ] = Cofins 
	[ 12 ] = Chave NFE
	[ 13 ] = Nota Fiscal
	[ 14 ] = Serie   
	[ 15 ] = Emissao

*/

cNF 	:= aDadosNF[ 1 ][ 13 ] 
cSerie 	:= aDadosNF[ 1 ][ 14 ]
                 
If !ExistCli( aDadosCli )						

	AAdd( aCab , { 'A1_NOME' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_PESSOA' , If( Len( AllTrim( aDadosCli[ 9 ] ) ) > 11 , 'J' , 'F' ) , Nil } )
	AAdd( aCab , { 'A1_NREDUZ' , aDadosCli[ 8 ] , Nil } )
	AAdd( aCab , { 'A1_TIPO' , 'F' , Nil } )
	AAdd( aCab , { 'A1_END' , aDadosCli[ 6 ] , Nil } )
	AAdd( aCab , { 'A1_BAIRRO' , aDadosCli[ 5 ] , Nil } )  
	
	If ( Val( aDadosCli[ 10 ] ) > 0 )
		AAdd( aCab , { 'A1_CEP' , aDadosCli[ 10 ] , Nil } ) 
	EndIf
		
	
	If ( Val( aDadosCli[ 9 ] ) > 0  )
		AAdd( aCab , { 'A1_CGC' , aDadosCli[ 9 ] , Nil } )
	EndIf
	
	AAdd( aCab , { 'A1_NATUREZ' , cNatureza , Nil } )
	AAdd( aCab , { 'A1_CONTA' , "11211001" , Nil } )
	
	AAdd( aCab , { 'A1_EST' , aDadosCli[ 4 ] , Nil } )
	
	If ( cUFCli <> 'EX' )                             
		AAdd( aCab , { 'A1_COD_MUN' , aDadosCli[ 1 ] , Nil } )	
		AAdd( aCab , { 'A1_CODPAIS' , aDadosCli[ 2 ] , Nil } )

	Else
		AAdd( aCab , { 'A1_MUN' , 'EXTERIOR' , Nil } )		
		
	EndIf         
	
	lMSErroAuto := .F.
	CC2->( DbSetOrder( 1 ) )
	MSExecAuto( { | x , y | Mata030( x , y ) } , aCab , 3 )
	
	
	If lMSErroAuto     
		//MostraErro()
		cLog := MemoRead( NomeAutoLog() )
		DisarmTransaction()	
		Aadd( aLog , { .F. , cArquivo  , cNF , cSerie , 'Erro na inclusao do cliente.' , cCNPJ , cFilAnt } )
		GravaLog( cNF, cSerie , cArquivo , cLog  )	
	    Return			
	EndIf 

EndIf

cCli  	:= SA1->A1_COD
cLoja	:= SA1->A1_LOJA

cNF 	:= aDadosNF[ 1 ][ 13 ] 
cSerie 	:= aDadosNF[ 1 ][ 14 ]

/* 
	* Gravação Nota Fiscal	
*/       

SB1->( DbSetOrder( 1 ) )
SB1->( DbSeek( xFilial() + cProduto ) )
              

SF2->( DbSetOrder( 1 ) )
IF SF2->( dbSeek(xFilial("SF2")+PadR(cNf,Tamsx3("F2_DOC")[1])+PadR(cSerie,Tamsx3("F2_SERIE")[1])+cCli+cLoja))
	Aadd( aLog , { .F. , cArquivo  , cNF , cSerie , 'Nota Fiscal ja integrada anteriormente .' , cCNPJ , cFilAnt } )	
	GravaLog( cNF, cSerie , cArquivo , 'Nota Fiscal ja integrada anteriormente .'  )		
    Return	
EndIf

cEspecie := "NFPS"
aAdd( aAutoCab , { "F2_FILIAL"  , xFilial('SF2')	, Nil } )
aAdd( aAutoCab , { "F2_TIPO"    , "N"				, Nil } )
aAdd( aAutoCab , { "F2_DOC"     , cNf			   	, Nil } )
aAdd( aAutoCab , { "F2_SERIE"   , cSerie			, Nil } )
aAdd( aAutoCab , { "F2_CLIENTE" , cCli				, Nil } )
aAdd( aAutoCab , { "F2_LOJA"    , cLoja				, Nil } )
aAdd( aAutoCab , { "F2_EMISSAO" , aDadosNf[ 1 ][ 15 ], Nil } ) 
aAdd( aAutoCab , { "F2_ESPECIE" , "NFPS"			, Nil } ) 
aAdd( aAutoCab , { "F2_CHVNFE" , aDadosNf[ 1 ][ 12 ], Nil } )
aAdd( aAutoCab , { "F2_COND" , "001"		    	, Nil } ) 
aAdd( aAutoCab , { "F2_DESCONT" , 0				, Nil } )
aAdd( aAutoCab , { "F2_FRETE" , 0				, Nil } )
aAdd( aAutoCab , { "F2_DESPESA" , 0				, Nil } )
aAdd( aAutoCab , { "F2_SEGURO" , 0				, Nil } )


For i := 1 To Len( aDadosNF )
	aItem := {}
	cCFOP := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
	
	If ( cUFCli == 'EX' )	
		cCFOP := '7' + SubsTr( cCFOP , 2 )
	ElseIf ( cUFCli	<> GetMV( 'MV_ESTADO' )  ) 
		cCFOP := '6' + SubsTr( cCFOP , 2 )
	EndIf	
	
	aAdd( aItem , { "D2_FILIAL"  , xFilial('SD2')		, Nil } )
	aAdd( aItem , { "D2_DOC"     , cNf					, Nil } )
	aAdd( aItem , { "D2_SERIE"   , cSerie				, Nil } )
	aAdd( aItem , { "D2_EMISSAO" , aDadosNF[ i ][ 15 ]	, Nil } )	
	aAdd( aItem , { "D2_CLIENTE" , cCli					, Nil } )
	aAdd( aItem , { "D2_LOJA"    , cLoja				, Nil } )
	aAdd( aItem , { "D2_COD"     , SB1->B1_COD			, Nil } )
	aAdd( aItem , { "D2_UM"      , SB1->B1_UM			, Nil } )
	aAdd( aItem , { "D2_QUANT"   , aDadosNF[ i ][ 4 ]	, Nil } )
	aAdd( aItem , { "D2_VUNIT"   , aDadosNF[ i ][ 5 ]	, Nil } )  
	aAdd( aItem , { "D2_PRCVEN"   , aDadosNF[ i ][ 5 ]	, Nil } )	
	aAdd( aItem , { "D2_TOTAL"   , Round( aDadosNF[ i ][ 4 ] * aDadosNF[ i ][ 5 ] , TamSX3( 'D2_TOTAL' )[ 2 ] ) /*aDadosNF[ i ][ 6 ]*/	, Nil } )
	aAdd( aItem , { "D2_TES"     , SB1->B1_TS			, Nil } )
	aAdd( aItem , { "D2_CF"      , cCFOP				, Nil } )
	aAdd( aItem , { "D2_LOCAL"   , SB1->B1_LOCPAD		, Nil } )
	aAdd( aItem , { "D2_ITEM"    , aDadosNF[ i ][ 4 ]	, Nil } )

	
	//->> Impostos -> ISS
	aAdd( aItem , { "D2_BASEISS" , aDadosNF[ i ][ 8 ] , Nil } )
	aAdd( aItem , { "D2_ALIQISS" , aDadosNF[ i ][ 7 ] , Nil } )
	aAdd( aItem , { "D2_VALISS"  , Round( aDadosNF[ i ][ 7 ] * aDadosNF[ i ][ 8 ] /100 , TamSX3( 'D2_VALISS' )[ 2 ] )/*aDadosNF[ i ][ 9 ]*/ , Nil } )
	
	aAdd( aAutoItens, aItem )

Next


lMsErroAuto := .F.
MsExecAuto( {|x,y,z| Mata920(x,y,z)}, aAutoCab, aAutoItens, 3)

If  lMsErroAuto 
	//MostraErro()
	cLog := MemoRead( NomeAutoLog() )	
	DisarmTransaction()
	Aadd( aLog , { .F. , cArquivo  , cNF , cSerie , 'Erro na inclusao da nota Fiscal .' , cCNPJ , cFilAnt} )
	GravaLog( cNF , cSerie , cArquivo , cLog  )				
	
Else
	Aadd( aLog , { .T. , cArquivo  , cNF , cSerie , 'Nota Fiscal incluida com sucesso.' , cCNPJ , cFilAnt } )	 
	GravaLog( cNF , cSerie , cArquivo , 'Nota Fiscal incluida com sucesso.'   )	
EndIf	

Return   

/*
Função..............: ExistCli
Objetivo............: Retornar se deve incluir o cliente
Autor...............: Leandro Diniz de Brito
Data................: 14/10/2016
*/                              
*----------------------------------------* 
Static Function ExistCli( aDadosCli )                  
*----------------------------------------* 
Local lRet  

If ( aDadosCli[ 4 ] == 'EX' )
	SA1->( DbSetOrder( 2 ) )
	lRet := SA1->( DbSeek( xFilial() + aDadosCli[ 8 ] ) ) 

Else
	SA1->( DbSetOrder( 3 ) )
	lRet := SA1->( DbSeek( xFilial() + aDadosCli[ 9 ] ) ) 

EndIf

Return( lRet )      

/*
Função..............: GravaLog
Objetivo............: Gravar Log da Integracao
Autor...............: Leandro Diniz de Brito
Data................: 21/10/2016
*/                              
*-----------------------------------------------------* 
Static Function GravaLog( cNF, cSerie , cArq , cLog )                  
*-----------------------------------------------------* 

ZX0->( RecLock( 'ZX0' , .T. ) )
ZX0->ZX0_FILIAL := xFilial( 'ZX0' )
ZX0->ZX0_USER 	:= cUserName
ZX0->ZX0_DATA	:= dDatabase
ZX0->ZX0_HORA 	:= Left( Time() , 5 )
ZX0->ZX0_ARQ	:= cArq
ZX0->ZX0_DOC	:= cNF
ZX0->ZX0_SERIE	:= cSerie
ZX0->ZX0_LOG 	:= cLog
ZX0->ZX0_CGC	:= cCNPJ
ZX0->( MSunlock() ) 

Return

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files (x86)\WinRAR\'

cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )


Return(lRet)