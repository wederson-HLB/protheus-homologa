#Include 'Protheus.Ch'

/*
Função..........: V5Est002
Objetivo........: Processar Integração de Fornecedores  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 29/08/2016
*/

*-----------------------------------------* 
User Function V5Est002( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpSA2 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ' , 'EMP' , 'A2_FILIAL' , 'A2_P_ID' , 'CAMPO' , 'VALOR' , 'STATUS' , 'MENSAGEM' , 'ARQUIVO' }
Local cArquivo  	:= ''

Local i,nCampo 
Local aLog    		:= {}
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aCab 			:= {}
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cEst   

Local cCodForn,lInclui
Local lSA2Exc		:= !Empty( xFilial( 'SA2' ) )
//RRP - Ajuste no array campo endereco e natureza
Local aValidCont    := { { 'A2_P_ID' , { | x | Val( x ) > 0 } , { | x | 'ID ' + x + ' Invalido.' }  } ,;
						{ 'A2_NOME' , { | x | .T. } , { | x | 'Nome ' + x + ' Invalido.' }  } ,;						
						{ 'A2_NREDUZ' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																		
						{ 'A2_TIPO' , { | x | x $ 'F,J' } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																								 
						{ 'A2_END' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_EST' , { | x | !Empty( SX5->( Tabela( '12' , x , .F. )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'A2_COMPLEM' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  },; 																														
						{ 'A2_BAIRRO' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_CEP' , { | x | ( Len( x ) == 8 .And. Val( x ) > 0 ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_CGC' , { | x | Cgc( x ,, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																													
						{ 'A2_NATUREZ' , { | x | SYD->( DbSetOrder( 1 ) , SYD->(DbSeek( xFilial("SYD") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'A2_COD_MUN' , { | x | CC2->( DbSetOrder( 1 ) , CC2->(DbSeek( xFilial("CC2") + cEst + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'A2_MUN' , { | x | .T. /*CC2->( DbSetOrder( 2 ) , CC2->(DbSeek( xFilial("CC2") + Upper( x )) ) )*/ } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'A2_CONTA' , { | x | CT1->( DbSetOrder( 1 ) , CT1->(DbSeek( xFilial("CT1") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_CODPAIS' , { | x | CCH->( DbSetOrder( 1 ) , CCH->(DbSeek( xFilial("CCH") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_EMAIL' , { | x | At( '@' , x ) > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'A2_PAIS' , { | x | SYA->( DbSetOrder( 1 ) , SYA->(DbSeek( xFilial("SYA") + x )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'A2_TPESSOA' , { | x | ( Len( x ) = 2 .And. x $ 'CC,CI,PF,OS,EP,AT,ER' ) } , { | x | 'Conteudo ' + x + ' Invalido.' } } }																														

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

	cId := GdFieldGet( 'WKA2_P_ID' , i ,, aHeader , aCols )
	cEmpresa := GdFieldGet( 'WKEMP' , i ,, aHeader , aCols )
	If Empty( cId )
		lContinua := .F.
		nSeq ++ 
		aAux := { StrZero( nSeq ,2 ) ,;  
					cEmpresa,;
					'' ,;
					cId,;
					'A2_P_ID' ,;
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
	If lSA2Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
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
	
	SA2->( DbSetOrder( 1 ) ) 
	cCodForn := PadR( cId , Len( SA2->A2_COD ) )
	lInclui := SA2->( !DbSeek( xFilial("SA2") + cCodForn + '01' ) )
	
	/*
		* Valida Conteudo dos Campos
	*/
	For nCampo := 1 To Len( aCmpSA2 ) 
		If ( nPos := Ascan( aValidCont , { | x | x[ 1 ] = aCmpSA2[ nCampo ] } ) ) > 0 
			cConteudo := GdFieldGet( "WK"+aCmpSA2[ nCampo ] , i ,, aHeader , aCols )
			cEst := GdFieldGet( "WKA2_EST" , i ,, aHeader , aCols )         
			
			//RRP - 04/08/2016 - Preenchendo com conteudo padrao caso esteja em branco
			If Empty(cConteudo) .And. lInclui
				If aCmpSA2[nCampo]=="A2_CONTA"
					cConteudo:= "21111001"
					GdFieldPut( "WK"+aCmpSA2[nCampo] , cConteudo , i , aHeader , aCols )
				ElseIf aCmpSA2[nCampo]=="A2_NATUREZ"
					cConteudo:= "1001"                                                  
					GdFieldPut( "WK"+aCmpSA2[nCampo] , cConteudo , i , aHeader , aCols )
				ElseIf aCmpSA2[nCampo]=="A2_MUN"
					cConteudo:= CC2->CC2_MUN
					GdFieldPut( "WK"+aCmpSA2[nCampo] , cConteudo , i , aHeader , aCols )
				EndIf
				
			EndIf  
			
			If !lInclui .And. AllTrim( aCmpSA2[nCampo] ) $ "A2_CONTA\A2_NATUREZ"
				Loop
			EndIf
			
			If !Empty( cConteudo ) .And. !Eval( aValidCont[ nPos ][ 2 ] , cConteudo )
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							'' ,;
							cId,;
							aCmpSA2[ nCampo ] ,;
							cConteudo,;
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
	Aadd( aCab , { 'A2_FILIAL' , xFilial( 'SA2' ) , NIL } )	
	For nCampo := 1 To Len( aCmpSA2 )     
		If !lInclui .And. AllTrim( aCmpSA2[ nCampo ] ) $ "A2_CONTA\A2_NATUREZ"	
			Loop	
		EndIf
		cConteudo := GdFieldGet( "WK"+aCmpSA2[ nCampo ] , i ,, aHeader , aCols )
		If !Empty( cConteudo ) 		
			Aadd( aCab , { aCmpSA2[ nCampo ]  , cConteudo , Nil } )
		EndIf	
	Next  
	
	Aadd( aCab , { 'A2_ID_FBFN' , '3' 			, NIL } )		
	Aadd( aCab , { 'A2_FABRICA' , '3' 			, NIL } )			
	
	Aadd( aCab , { 'A2_COD' 	, cCodForn		, NIL } )		
	Aadd( aCab , { 'A2_LOJA' 	, '01'			, NIL } )
	Aadd( aCab , { 'A2_CALCIRF' , '1'			, NIL } )			
	
	Private lMsErroAuto := .F. 
	CC2->( DbSetOrder( 1 ) )
	MSExecAuto( { |x,y| Mata020(x,y) } , aCab ,If( lInclui,3,4 ) )  	
	
	
	If lMsErroAuto
		MostraErro() 
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
If lSA2Exc
	cFilAnt := cFilBak
	SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

Return

