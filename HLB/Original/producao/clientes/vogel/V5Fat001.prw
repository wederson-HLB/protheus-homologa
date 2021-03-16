#Include 'Protheus.Ch'

/*
Função..........: V5Fat001
Objetivo........: Processar Integração de Clientes  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 25/07/2016
*/

*-----------------------------------------* 
User Function V5Fat001( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpSA1 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ' , 'EMP' , 'A1_FILIAL' , 'A1_P_ID' , 'CAMPO' , 'VALOR' , 'STATUS' , 'MENSAGEM' , 'ARQUIVO' }
Local cArquivo  	:= ''

Local i,nCampo 
Local aLog    		:= {}
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aCab 			:= {}
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cEst

Local cCodCli,lInclui
Local lSA1Exc		:= !Empty( xFilial( 'SA1' ) )
//RRP - Ajuste no array campo endereco e natureza
Local aValidCont    := { { 'A1_P_ID' , { | x | !Empty( x )  } , { | x | 'ID ' + x + ' Invalido.' }  } ,;
						{ 'A1_NOME' , { | x | .T. } , { | x | 'Nome ' + x + ' Invalido.' }  } ,;						
						{ 'A1_PESSOA' , { | x | x $ 'F,J' } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;												
						{ 'A1_NREDUZ' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																		
						{ 'A1_TIPO' , { | x | x $ 'F,L,R,S,X' } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																								 
						{ 'A1_END' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_EST' , { | x | !Empty( SX5->( Tabela( '12' , x , .F. )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'A1_COMPLEM' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  },; 																														
						{ 'A1_BAIRRO' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_CEP' , { | x | ( Len( x ) == 8 .And. Val( x ) > 0 ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_CGC' , { | x | Cgc( x ,, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																													
						{ 'A1_NATUREZ' , { | x | SYD->( DbSetOrder( 1 ) , SYD->(DbSeek( xFilial("SYD") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'A1_COD_MUN' , { | x | CC2->( DbSetOrder( 1 ) , CC2->(DbSeek( xFilial("CC2") + cEst + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'A1_MUN' , { | x | .T. /* CC2->( DbSetOrder( 2 ) , CC2->(DbSeek( xFilial("CC2") + Upper( x ) )) )*/ } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'A1_CONTA' , { | x | CT1->( DbSetOrder( 1 ) , CT1->(DbSeek( xFilial("CT1") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_CODPAIS' , { | x | CCH->( DbSetOrder( 1 ) , CCH->(DbSeek( xFilial("CCH") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_EMAIL' , { | x | At( '@' , x ) > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A1_TPESSOA' , { | x | ( Len( x ) = 2 .And. x $ 'CC,CI,PF,OS,EP,AT,ER' ) } , { | x | 'Conteudo ' + x + ' Invalido.' } },;
						{ 'A1_INSCR' , { | x | IE( x , cEst, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } }																														

Aadd( aLog , { , aHeaderLog } )
For i := 1 To Len( aCols )

	If aCols[ i ][1]:cName <> 'BR_BRANCO'
		Loop
	EndIf

	nSeq := 0
	If cArquivo <> aCols[ i ][ nPosArq ]
		cArquivo := aCols[ i ][ nPosArq ] 
		Aadd( aLog , { cArquivo , {} }  )
		nLen := Len( aLog )
	EndIf

	/*
		* Valida se todos campos obrigatórios estão preenchidos 
	*/  
	lContinua := .T.

	cId := GdFieldGet( 'WKA1_P_ID' , i ,, aHeader , aCols )
	cEmpresa := GdFieldGet( 'WKEMP' , i ,, aHeader , aCols )
	If Empty( cId )
		lContinua := .F.
		nSeq ++ 
		aAux := { StrZero( nSeq ,2 ) ,;  
					cEmpresa,;
					'' ,;
					cId,;
					'A1_P_ID' ,;
					'',;
					'E',;
					'Campo chave nao informado',;
					cArquivo }
						
		Aadd( aLog[ nLen ][ 2 ] , aAux )
		aCols[ i ][ 1 ] := oStsEr 	
	
	EndIf
	
	If !lContinua 
		Loop
	EndIf	

	/*
		* Se o cadastro de clientes for exclusivo, posiciona na filial correta
	*/
	If lSA1Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
		cFilAnt := u_V5RetFil( cEmpresa )
	EndIf

	For nCampo := 1 To Len( aCmpObrigat ) 
		If Empty( GdFieldGet( "WK"+aCmpObrigat[ nCampo ] , i ,, aHeader , aCols ) )		
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						'' ,;
						cId,;
						aCmpObrigat[ nCampo ] ,;
						'',;
						'E',;
						'Conteudo obrigatorio nao informado',;
						cArquivo }
							
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsEr 
										
		EndIf
		
	Next 
	
	/*
		* Busca codigo do cliente pelo ID
	*/
	/*
	aCodCli := u_V5ClieTw( cId )
	lInclui := ( Len( aCodCli ) == 0 )
	*/
	
	SA1->( DbSetOrder( 1 ) ) 
	cCodCli := PadR( cId , Len( SA1->A1_COD ) )
	lInclui := SA1->( !DbSeek( xFilial("SA1") + cCodCli + '01' ) )	
	
	/*
		* Valida Conteudo dos Campos
	*/
	For nCampo := 1 To Len( aCmpSA1 ) 
		If ( nPos := Ascan( aValidCont , { | x | x[ 1 ] = aCmpSA1[ nCampo ] } ) ) > 0 
			cConteudo := GdFieldGet( "WK"+aCmpSA1[ nCampo ] , i ,, aHeader , aCols )
			cEst := GdFieldGet( "WKA1_EST" , i ,, aHeader , aCols )         
			
			//RRP - 04/08/2016 - Preenchendo com conteudo padrao caso esteja em branco
			If Empty(cConteudo) .And. lInclui
				If aCmpSA1[nCampo]=="A1_CONTA"
					cConteudo:= "11211001"
					GdFieldPut( "WK"+aCmpSA1[nCampo] , cConteudo , i , aHeader , aCols )
				ElseIf aCmpSA1[nCampo]=="A1_NATUREZ"
					cConteudo:= "1001"                                                  
					GdFieldPut( "WK"+aCmpSA1[nCampo] , cConteudo , i , aHeader , aCols )
				ElseIf aCmpSA1[nCampo]=="A1_MUN"
					cConteudo:= CC2->CC2_MUN
					GdFieldPut( "WK"+aCmpSA1[nCampo] , cConteudo , i , aHeader , aCols )
				EndIf
				
			EndIf
			
			If !lInclui .And. AllTrim( aCmpSA1[nCampo] ) $ "A1_CONTA\A1_NATUREZ"
				Loop
			EndIf
			
			If !Empty( cConteudo ) .And. !Eval( aValidCont[ nPos ][ 2 ] , cConteudo )
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							'' ,;
							cId,;
							aCmpSA1[ nCampo ] ,;
							'',;
							'E',;
							Eval( aValidCont[ nPos ][ 3 ] , cConteudo ),;
							cArquivo }
								
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr 
			EndIf	
		EndIf
	Next
		
	If !lContinua 
		Loop
	EndIf 

	/*
		* Montagem MSExecAuto
	*/
	
	aCab := {}  
	Aadd( aCab , { 'A1_FILIAL' , xFilial( 'SA1' ) , NIL } )	
	For nCampo := 1 To Len( aCmpSA1 )     
		If !lInclui .And. AllTrim( aCmpSA1[ nCampo ] ) $ "A1_CONTA\A1_NATUREZ"	
			Loop	
		EndIf
		cConteudo := GdFieldGet( "WK"+aCmpSA1[ nCampo ] , i ,, aHeader , aCols )
		If !Empty( cConteudo ) 		
			Aadd( aCab , { aCmpSA1[ nCampo ]  , cConteudo , Nil } )
		EndIf
		If AllTrim( aCmpSA1[ nCampo ] ) $ "A1_TPESSOA"
			cTPessoa := GdFieldGet( "WK"+aCmpSA1[ nCampo ] , i ,, aHeader , aCols )
		EndIf
			
	Next  
	
	Aadd( aCab , { 'A1_COD' 	, cCodCli 	, NIL } )		
	Aadd( aCab , { 'A1_LOJA' 	, '01' 		, NIL } )
	//RRP - 01/09/2016 - Ajuste para retencao
	Aadd( aCab , { 'A1_RECIRRF' , '1' 		, NIL } )
	If Alltrim(cTPessoa) == 'EP'
		Aadd( aCab , { 'A1_RECPIS' 	, 'P' 	, NIL } )		
		Aadd( aCab , { 'A1_RECCOFI' , 'P' 	, NIL } )
		Aadd( aCab , { 'A1_RECCSLL' , 'P'	, NIL } )
		Aadd( aCab , { 'A1_ABATIMP' , '1' 	, NIL } )		
	Else
		Aadd( aCab , { 'A1_RECPIS' 	, 'S' 	, NIL } )		
		Aadd( aCab , { 'A1_RECCOFI' , 'S' 	, NIL } )
		Aadd( aCab , { 'A1_RECCSLL' , 'S'	, NIL } )
		Aadd( aCab , { 'A1_ABATIMP' , '1' 	, NIL } )
	EndIf
	
	Private lMsErroAuto := .F. 
	CC2->( DbSetOrder( 1 ) )
	MSExecAuto( { |x,y| Mata030(x,y) } , aCab ,If( lInclui,3,4 ) )  	
	
	
	If lMsErroAuto 
		nSeq ++
		aAux := { StrZero( nSeq ,2 ) ,;
					cEmpresa,;
					'' ,;
					cId,;
					'' ,;
					'',;
					'E',;
					'Erro interno na gravacao do registro.',;
					cArquivo }
					
		Aadd( aLog[ nLen ][ 2 ] , aAux )
		aCols[ i ][ 1 ] := oStsEr 
    Else  
		
		nSeq ++ 
		aAux := { StrZero( nSeq ,2 ) ,;
					cEmpresa,;
					'' ,;
					cId,;
					'' ,;
					'',;
					'S',;
					If( lInclui , 'Inserido' , 'Alterado' ) + ' Corretamente.',;
					cArquivo }
					
		Aadd( aLog[ nLen ][ 2 ] , aAux )
		aCols[ i ][ 1 ] := oStsok    
    
    EndIf
Next 

/*
	*	Restaura SM0 e Filial 
*/
If lSA1Exc
	cFilAnt := cFilBak
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

Return

