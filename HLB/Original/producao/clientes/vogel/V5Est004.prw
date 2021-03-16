#Include 'Protheus.Ch'

/*
Função..........: V5Est004
Objetivo........: Processar Integração de Requisicoes  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 09/09/2016
*/

*-----------------------------------------* 
User Function V5Est004( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpZX1 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ','EMP','ZX1_FILIAL','ZX1_P_REF','ZX1_ITEM','CAMPO','VALOR','STATUS','MENSAGEM','ARQUIVO' }

Local cArquivo  	:= ''

Local i,nCampo 
Local aLog    		:= {}
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aCab 			:= {}
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cEst                                      
Local nCount 	

Local cCodForn,lInclui
Local lZX1Exc		:= !Empty( xFilial( 'ZX1' ) )

Local aValidCont    := { { 'ZX1_P_REF' , { | x | ZX1->( DbSetOrder( 1 ) , ZX1->(!DbSeek( xFilial('ZX1') + cRef + cItem )) ) } , { | x | 'Referencia ja cadastrada para este item'  }  } ,;
						{ 'ZX1_ITEM' , { | x | Val( x ) > 0 } , { | x | 'Item ' + x + ' Invalido.' }  } ,;	 
						{ 'ZX1_PRODUTO' , { | x | SB1->( DbSetOrder( 1 ) , SB1->(DbSeek( xFilial('SB1') + PadR( x , Len( SB1->B1_COD ) ) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																		
						{ 'ZX1_QUANT' , { | x | x > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } }																								 


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
	If lZX1Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
		cFilAnt := u_V5RetFil( cEmpresa )
	EndIf

	cRef := PadR( GdFieldGet( "WKZX1_P_REF" , i ,, aHeader , aCols ) , Len( ZX1->ZX1_P_REF ) )
	cItem := PadR( GdFieldGet( "WKZX1_ITEM" , i ,, aHeader , aCols ) , Len( ZX1->ZX1_ITEM ) )
		
	For nCampo := 1 To Len( aCmpObrigat ) 
		If Empty( GdFieldGet( "WK"+aCmpObrigat[ nCampo ] , i ,, aHeader , aCols ) )		
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						'' ,;
						cRef,;
						cItem ,;
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
	For nCampo := 1 To Len( aCmpZX1 ) 
		If ( nPos := Ascan( aValidCont , { | x | x[ 1 ] = aCmpZX1[ nCampo ] } ) ) > 0 
			cConteudo := GdFieldGet( "WK"+aCmpZX1[ nCampo ] , i ,, aHeader , aCols )
		
			If !Empty( cConteudo ) .And. !Eval( aValidCont[ nPos ][ 2 ] , cConteudo )
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							'' ,;
							cRef,; 
							cItem,;
							aCmpZX1[ nCampo ] ,;
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
		
		If ZX1->( !DbSeek( xFilial("ZX1") + cRef + cItem ) )
			ZX1->( RecLock( 'ZX1' , .T. ) )
			
			ZX1->ZX1_FILIAL  := xFilial( 'ZX1' )
			For j := 1 To Len( aCmpZX1 )
				If '_FILIAL' $ aCmpZX1[ j ] 
					Loop
				EndIf	
				ZX1->&( aCmpZX1[ j ] )  := GdFieldGet( "WK"+aCmpZX1[ j ] , i ,, aHeader , aCols )
			Next
			ZX1->( MSUnlock() )

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
If lZX1Exc
	cFilAnt := cFilBak
	SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

Return

