#Include 'Protheus.Ch'

/*
Função..........: V5Est005
Objetivo........: Processar Integração de Recebimento  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 12/09/2016
*/

*-----------------------------------------* 
User Function V5Est005( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpZX0 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ','EMP','ZX0_FILIAL','ZX0_P_REF','ZX0_DOC','ZX0_SERIE','ZX0_EMISSA','CAMPO','VALOR','STATUS','MENSAGEM','ARQUIVO' }



Local cArquivo  	:= ''  
Local cDoc
Local cSerie
Local cEmissao

Local i,nCampo 
Local aLog    		:= {}
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aCab 			:= {}
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cEst                                      
Local nCount 	

Local cCodForn,lInclui
Local lZX0Exc		:= !Empty( xFilial( 'ZX0' ) )

Local aValidCont    := { { 'ZX0_P_REF' , { | x | ZX0->( DbSetOrder( 1 ) , ZX0->(!DbSeek( xFilial('ZX0') + cRef + cItem )) ) } , { | x | 'Referencia ja cadastrada para este item'  }  } ,;
						{ 'ZX0_ITEM' , { | x | Val( x ) > 0 } , { | x | 'Item ' + x + ' Invalido.' }  } ,;	 
						{ 'ZX0_PRODUT' , { | x | SB1->( DbSetOrder( 1 ) , SB1->(DbSeek( xFilial('SB1') + PadR( x , Len( SB1->B1_COD ) ) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																		
						{ 'ZX0_QUANT' , { | x | x > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																								 
						{ 'ZX0_CGC' , { | x | Cgc( x ,, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } }																								 


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
	cEmpresa := GdFieldGet( 'WKEMP' , i ,, aHeader , aCols )
	lContinua := .T.

	/*
		* Se o cadastro de clientes for exclusivo, posiciona na filial correta
	*/
	If lZX0Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
		cFilAnt := u_V5RetFil( cEmpresa )
	EndIf

	cRef := PadR( GdFieldGet( "WKZX0_P_REF" , i ,, aHeader , aCols ) , Len( ZX0->ZX0_P_REF ) )
	cItem := PadR( GdFieldGet( "WKZX0_ITEM" , i ,, aHeader , aCols ) , Len( ZX0->ZX0_ITEM ) )
	cDoc := PadR( GdFieldGet( "WKZX0_DOC" , i ,, aHeader , aCols ) , Len( ZX0->ZX0_DOC ) )
	cSerie := PadR( GdFieldGet( "WKZX0_SERIE" , i ,, aHeader , aCols ) , Len( ZX0->ZX0_SERIE ) )
	cEmissao := DtoC( GdFieldGet( "WKZX0_EMISSA" , i ,, aHeader , aCols ) ) 
		
		
	For nCampo := 1 To Len( aCmpObrigat ) 
		If Empty( GdFieldGet( "WK"+aCmpObrigat[ nCampo ] , i ,, aHeader , aCols ) )		
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						'' ,;
						cRef,;
						cDoc ,;
						cSerie,;
						cEmissao,;
						aCmpObrigat[ nCampo ],;
						'',;
						'E',;
						'Conteudo obrigatorio nao informado',;
						cArquivo }
							
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsEr 
		EndIf
		
	Next 
	
		
	/*
		* Valida Conteudo dos Campos
	*/
	For nCampo := 1 To Len( aCmpZX0 ) 
		If ( nPos := Ascan( aValidCont , { | x | x[ 1 ] = aCmpZX0[ nCampo ] } ) ) > 0 
			cConteudo := GdFieldGet( "WK"+aCmpZX0[ nCampo ] , i ,, aHeader , aCols )
		
			If !Empty( cConteudo ) .And. !Eval( aValidCont[ nPos ][ 2 ] , cConteudo )
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							'' ,;
							cRef,;
							cDoc ,;
							cSerie,;
							cEmissao,;
							aCmpZX0[ nCampo ] ,;
							cConteudo,;
							'E',;
							Eval( aValidCont[ nPos ][ 3 ] , cConteudo ),;
							cArquivo }
								
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr 
			EndIf	
		EndIf
	Next

	/*
		* Faz gravação do Registro se nao ocorreram erros na validação
	*/
	If lContinua
		
		If ZX0->( !DbSeek( xFilial("ZX0") + cRef + cItem ) )
			ZX0->( RecLock( 'ZX0' , .T. ) )
			
			ZX0->ZX0_FILIAL  := xFilial( 'ZX0' )
			For j := 1 To Len( aCmpZX0 )
				If '_FILIAL' $ aCmpZX0[ j ] 
					Loop
				EndIf	
				ZX0->&( aCmpZX0[ j ] )  := GdFieldGet( "WK"+aCmpZX0[ j ] , i ,, aHeader , aCols )
			Next
			ZX0->( MSUnlock() )

			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								'' ,;
								cRef,; 
								cItem,;
								'' ,;
								'',;
								'S',;
								'Inserido Corretamente.',;
								cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsok    
    	EndIf
    EndIf
Next 

/*
	*	Restaura SM0 e Filial 
*/
If lZX0Exc
	cFilAnt := cFilBak
	SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

Return

