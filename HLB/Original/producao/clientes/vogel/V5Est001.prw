#Include 'Protheus.Ch'
#Include 'Topconn.Ch'

/*
Função..........: V5Est001
Objetivo........: Processar Integração Pedido de Compras  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 29/08/2016
*/

*-----------------------------------------* 
User Function V5Est001( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpPed 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ' , 'EMP' , 'C7_FILIAL' , 'C7_P_REF' , 'C7_PRODUTO' , 'C7_NUM' , 'CAMPO' , 'VALOR' , 'STATUS' , 'MENSAGEM' , 'ARQUIVO' } 

Local cArquivo  	:= ''  
Local nDecTot		:= TamSx3( 'C7_TOTAL' )[ 2 ]

Local i				:= 1
Local nCampo 
Local aLog    		:= {}
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aCab 			:= {}
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cEst,cCGCFor
   
Local nQuant
Local nPreco
Local nTotal

Local cCodForn,lInclui
Local lSC7Exc		:= !Empty( xFilial( 'SC7' ) )

Local nPosRef 		:= GdFieldPos( 'WKC7_P_REF' , aHeader )
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local aValidCont    := {{ 'C7_P_REF' , { | x | ValPedRef( x ) } , { | x | 'Referencia ' + x + ' ja gravada anteriormente.' }  } ,;
						{ 'C7_COND' , { | x | SE4->( DbSetOrder( 1 ) , SE4->(DbSeek( xFilial("SE4") + PadR(x,Len(SE4->E4_CODIGO)) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;						
						{ 'A2_CGC' , { | x | Cgc( x ,, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																																				
						{ 'C7_ITEM' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																								 
						{ 'C7_PRODUTO' , { | x | SB1->( DbSetOrder( 1 ) , SB1->(DbSeek( xFilial("SB1") + PadR(x,Len(SB1->B1_COD)) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C7_LOCAL' , { | x | NNR->( DbSetOrder( 1 ) , NNR->(DbSeek( xFilial("NNR") + PadR(x,Len(NNR->NNR_CODIGO)) )) )  } , { | x | 'Conteudo ' + x + ' Invalido.' } },;
						{ 'C7_LOCAL' , { | x | SB2->( DbSetOrder( 1 ),SB2->(DbSeek( xFilial("SB2") + PadR( cProduto ,Len( SB2->B2_COD ) ) + x )) ) } , { | x | 'Armazem ' + x + ' invalido para o produto.' } },;
						{ 'C7_EMISSAO' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' } },; 																														
						{ 'C7_QUANT' , { | x | x > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' } } ,;																														
						{ 'C7_PRECO' , { | x | x > 0  } , { | x | 'Conteudo ' + x + ' Invalido.' } } ,;																														
						{ 'C7_TOTAL' , { | x | Round( x , nDecTot ) == Round( nQuant * nPreco , nDecTot ) } , { | x | 'Valor total difere do produto quantidade x preco' } } ,;
						{ 'C7_P_PROJ' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' } } ,;
						{ 'C7_P_REG' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' } } ,;
						{ 'C7_CC' , { | x | CTT->( DbSetOrder( 1 ),CTT->(DbSeek( xFilial("CTT") + PadR( x ,Len( SB2->B2_COD ) ) )) ) } , { | x | 'Centro de Custo ' + x + ' Invalido.' } } }  																														


aCols := ASort( aCols ,,, { | x , y | x[ nPosArq ]  + x[ nPosRef ] < y[ nPosArq ]  + y[ nPosRef ] } ) 

Aadd( aLog , { , aHeaderLog } )
While i <= Len( aCols )

	If aCols[ i ][1]:cName <> 'BR_BRANCO'
		i += 1
		Loop
	EndIf

	nSeq := 0
	If cArquivo <> aCols[ i ][ nPosArq ]
		cArquivo := aCols[ i ][ nPosArq ] 
		Aadd( aLog , { cArquivo , {} }  )
		nLen := Len( aLog )
	EndIf

	lContinua 	:= .T.
	cPedRef 	:= GdFieldGet( 'WKC7_P_REF' , i ,, aHeader , aCols )
	cEmpresa 	:= GdFieldGet( 'WKEMP' , i ,, aHeader , aCols )
	
	If Empty( cPedRef )
		lContinua := .F.
		nSeq ++   
		aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,'', '' , 'C7_P_REF' ,'','E','Campo chave nao informado',cArquivo }
						
		Aadd( aLog[ nLen ][ 2 ] , aAux )
		aCols[ i ][ 1 ] := oStsEr 	
	
	EndIf
	
	If !lContinua 
		i += 1 
		Loop
	EndIf	

	/*
		* Se a tabela de Pedidos for exclusivo, posiciona na filial correta
	*/
	If lSC7Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
    	cFilAnt := u_V5RetFil( cEmpresa )
	EndIf

	nPosIni := i
	
	cCodForn := ''
	cLoja   := ''
	cCGCFor := GdFieldGet( "WKA2_CGC" , i ,, aHeader , aCols )    
	SA2->( DbSetOrder( 3 ) )
	If SA2->( DbSeek( xFilial("SA2") + cCGCFor ) )
		cCodForn 	:= SA2->A2_COD
		cLoja 		:= SA2->A2_LOJA		
	EndIf	
	
	aCab := {}
	aItens := {}  
				
	Aadd( aCab ,{ "C7_NUM" , cPedRef } )
	Aadd( aCab ,{"C7_EMISSAO" ,GdFieldGet( "WKC7_EMISSAO" , i ,, aHeader , aCols )})
	Aadd( aCab ,{"C7_FORNECE" ,cCodForn})
	Aadd( aCab ,{"C7_LOJA"    ,cLoja})
	Aadd( aCab ,{"C7_COND"    ,GdFieldGet( "WKC7_COND" , i ,, aHeader , aCols )})
	Aadd( aCab ,{"C7_CONTATO" ,""})
	Aadd( aCab ,{"C7_FILENT"  ,cFilAnt})
	Aadd( aCab ,{"C7_MOEDA"   ,1}) 
	Aadd( aCab ,{"C7_TXMOEDA" ,1})
    				
				
	While i <= Len( aCols ) .And. ( cPedRef == GdFieldGet( 'WKC7_P_REF' , i ,, aHeader , aCols ) )

		cProduto := PadR( GdFieldGet( 'WKC7_PRODUTO' , i ,, aHeader , aCols ) , Len( SB1->B1_COD ) ) 
		cLocal   := GdFieldGet( 'WKC7_LOCAL' , i ,, aHeader , aCols )
		cTipoProd:= ""   
		
		nQuant := GdFieldGet( 'WKC7_QUANT' , i ,, aHeader , aCols )
		nPreco := GdFieldGet( 'WKC7_PRECO' , i ,, aHeader , aCols )		
		
		If SB1->( DbSeek( xFilial("SB1") + cProduto ) ) 
			cTipoProd:= SB1->B1_TIPO
			If Empty( cLocal )
				cLocal := SB1->B1_LOCPAD 
				GdFieldPut( 'WKC7_LOCAL' , cLocal , i , aHeader , aCols )
			EndIf			

			If !Empty( cLocal ) .And. SB2->( DbSetOrder( 1 ) , SB2->(!DbSeek( xFilial( 'SB2' ) + cProduto + cLocal )) )
				CriaSb2( cProduto , cLocal )
			EndIf
		
		EndIf  
 
		/*
			* Valida se todos campos obrigatórios estão preenchidos  - Itens
		*/  
		For nCampo := 1 To Len( aCmpObrigat ) 
			If Empty( GdFieldGet( "WK"+aCmpObrigat[ nCampo ] , i ,, aHeader , aCols ) )		
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,cEmpresa,'' ,cPedRef,cProduto,'',aCmpObrigat[ nCampo ] ,'','E','Conteudo obrigatorio nao informado',cArquivo }
									
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr 
			EndIf
		Next  
		
		cCGCFor := GdFieldGet( "WKA2_CGC" , i ,, aHeader , aCols )    
		If SA2->( !DbSeek( xFilial("SA2") + cCGCFor ) ) .And. Cgc( cCGCFor ,, .F. )
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,cProduto, '' , 'A2_CGC' ,cCGCFor,'E','Fornecedor nao cadastrado',cArquivo }
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsEr 	    	
		EndIf	
			
		aItemAux := {}
		/*
			* Valida Conteudo dos Campos - Itens
		*/
		For nCampo := 1 To Len( aCmpPed ) 

			If '_FILIAL' $ aCmpPed[ nCampo ]      
				Loop
			EndIf

			cConteudo := GdFieldGet( "WK"+aCmpPed[ nCampo ] , i ,, aHeader , aCols )			
							
			If !Empty( cConteudo )
				For j := 1 To Len( aValidCont )
					If aValidCont[ j ][ 1 ] == aCmpPed[ nCampo ] .And. !Eval( aValidCont[ j ][ 2 ] , cConteudo )
						lContinua := .F. 
						nSeq ++ 
						aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,cProduto,'',aCmpPed[ nCampo ] ,cValToChar(cConteudo),	'E',Eval( aValidCont[ j ][ 3 ] , cConteudo ),cArquivo }
										
						Aadd( aLog[ nLen ][ 2 ] , aAux )
						aCols[ i ][ 1 ] := oStsEr   
					EndIf
				Next
			EndIf  
			
			If Ascan( aCab , { | x | x[ 1 ] == aCmpPed[ nCampo ] } ) == 0
				Aadd( aItemAux , { aCmpPed[ nCampo ]  , cConteudo , Nil } )
			EndIf	
						
		Next 
		       
		Aadd( aItens , aItemAux )
    		
		i += 1 
    EndDo
    
	nPosFim := i - 1                                         
	
	/*
		* Grava Pedido somente se todos os campos da Capa e Itens estiverem ok
	*/
	If lContinua  
		Private lMsErroAuto := .F. 
		SA2->( DbSetOrder( 1 ) )
		MSExecAuto( { |x,y,z| Mata120(x,y,z) } ,, aCab ,aItens,3)  	
			
		
		If lMsErroAuto 
		    nSeq ++

			aAux := { StrZero( nSeq ,2 ) ,cEmpresa,'' ,cPedRef,'','','' ,'','E','Erro interno na gravacao do registro.',cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			
			For j := nPosIni To nPosFim
				aCols[ j ][ 1 ] := oStsEr 
			Next
	    Else  
				
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,cEmpresa,'' ,cPedRef,'',SC7->C7_NUM ,'','','S','Inserido Corretamente.',cArquivo }
							
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			For j := nPosIni To nPosFim
				aCols[ j ][ 1 ] := oStsok
			Next
		    
	    EndIf    
	Else
		For j := nPosIni To nPosFim
			aCols[ j ][ 1 ] := oStsEr
		Next	
	EndIf
EndDo 

/*
	*	Restaura SM0 e Filial 
*/
If lSC7Exc
	cFilAnt := cFilBak
	SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog
Return

/*
Função..............: ValPedRef
Objetivo............: Verificar se a referencia do pedido ja esta cadastrada
Autor...............: Leandro Brito
*/
*----------------------------------*
Static Function ValPedRef( cRef )   
*----------------------------------*
Local aArea := GetArea()
Local lRet
Local cQuery         
Local cAlias := '_PEDREF' 

cQuery := "SELECT COUNT(*) TOTAL FROM " +RetSqlName( 'SC7' ) 
cQuery += " WHERE D_E_L_E_T_ = '' AND C7_FILIAL = '" + xFilial( 'SC7' ) + "' AND C7_P_REF = '" + cRef + "' "

TCQuery cQuery ALIAS ( cAlias ) NEW

lRet := ( ( cAlias )->TOTAL = 0 ) 

If Select( cAlias ) > 0
	( cAlias )->( DbCloseArea() )
EndIf	

RestArea( aArea )

Return( lRet )