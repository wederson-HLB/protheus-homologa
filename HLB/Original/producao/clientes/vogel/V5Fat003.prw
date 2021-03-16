#Include 'Protheus.Ch'     
#Include 'TopConn.Ch'

/*
Função..........: V5Fat003
Objetivo........: Processar Integração de Pedidos de Venda  - Projeto Vogel
Autor...........: Leandro Diniz de Brito ( LDB )
Cliente.........: Vogel               
Data............: 30/07/2016
*/

*-----------------------------------------* 
User Function V5Fat003( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
 
Local aCmpObrigat 	:= u_V5RetCmp( cTipoInt , .T. ) //** Retorna campos obrigatórios   
Local aCmpPed 		:= u_V5RetCmp( cTipoInt ) //** Retorna todos os campos da integração

Local aHeaderLog 	:= { 'SEQ' ,'EMP' , 'C5_FILIAL' , 'C5_P_REF' , 'C6_PRODUTO' , 'C5_NUM' , 'CAMPO' , 'VALOR' , 'STATUS' , 'MENSAGEM' , 'ARQUIVO' }

Local cArquivo  	:= ''

Local i,nCampo,j 
Local aLog    		:= {}

Local aCab 			 
Local aItens        
      
Local lContinua 	

Local cFilBak		:= cFilAnt
Local cTipoProd		:= ""
Local aAux

Local i := 1     
Local cCGCCli, cCli, cLoja

Local nPosRef 		:= GdFieldPos( 'WKC5_P_REF' , aHeader )
Local nPosArq 		:= GdFieldPos( 'ARQ_ORI' , aHeader )

Local lSC5Exc		:= !Empty( xFilial( 'SC5' ) )
Local aValidCont    := { { 'C5_TIPO' , { | x | x $ 'N,C,I,P' } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;
						{ 'C5_TIPOCLI' , { | x | x $ 'F,L,R,S,X' } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;						
						{ 'C5_CONDPAG' , { | x | SE4->( DbSetOrder( 1 ) , SE4->(DbSeek( xFilial("SE4") + PadR(x,Len(SE4->E4_CODIGO)) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;												
						{ 'C5_EMISSAO' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																		
						{ 'C5_MENNOTA' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																								 
						{ 'C5_P_REF' , { | x | ValPedRef( x ) } , { | x | 'Referencia ' + x + ' ja gravada anteriormente.' }  } ,;																														
						{ 'C5_P_CONSU' , { | x | x $ 'S,N' } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'A1_CGC' , { | x | Cgc( x ,, .F. ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																													
						{ 'C5_P_BOL' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C5_P_DTINI' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C5_P_DTFIM' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C5_P_AM' , { | x | At( "/" , x ) > 0 .And. Val( Left( x , 2 ) ) <= 12  .And. Val( Right( x , 2 ) ) > 0  } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C5_P_CONTA' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C5_P_AM' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																																										
						{ 'C5_P_REF' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' } } ,;																													
						{ 'C6_ITEM' , { | x | !Empty( x ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  },; 																														
						{ 'C6_PRODUTO' , { | x | SB1->( DbSetOrder( 1 ) , SB1->(DbSeek( xFilial("SB1") + PadR(x,Len(SB1->B1_COD)) )) ) } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_DESCRI' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_QTDVEN' , { | x | x  > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_PRCVEN' , { | x | x  > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  },;																														
						{ 'C6_VALDESC' , { | x | .T. } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_VALOR' , { | x | x  > 0 } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_TES' , { | x | SF4->( DbSetOrder( 1 ) , SF4->(DbSeek( xFilial("SF4") + x )) )  } , { | x | 'Conteudo ' + x + ' Invalido.' }  } ,;																														
						{ 'C6_TES' , { | x | SZ2->( DbSetOrder( 3 ) , SZ2->(DbSeek( xFilial("SZ2") + cEmpAnt + cFilAnt + x )) )  } , { | x | 'TES ' + x + ' nao amarrada a empresa ' + cEmpAnt + ' .' }  } ,;																																				
						{ 'C6_LOCAL' , { | x | NNR->( DbSetOrder( 1 ) , NNR->(DbSeek( xFilial("NNR") + PadR(x,Len(NNR->NNR_CODIGO)) )) )  } , { | x | 'Conteudo ' + x + ' Invalido.' } },;
						{ 'C6_LOCAL' , { | x | SB2->( DbSetOrder( 1 ),SB2->(DbSeek( xFilial("SB2") + PadR( cProduto ,Len( SB2->B2_COD ) ) + x )) ) } , { | x | 'Armazem ' + x + ' invalido para o produto.' } } }																																																															

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

	lContinua := .T.
	cPedRef := GdFieldGet( 'WKC5_P_REF' , i ,, aHeader , aCols )
	cEmpresa := GdFieldGet( 'WKEMP' , i ,, aHeader , aCols )
	
	If Empty( cPedRef )
		lContinua := .F.
		nSeq ++ 
		aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,'',	'C5_P_REF' ,'',	'E','Campo chave nao informado',cArquivo }
						
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
	If lSC5Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
    	cFilAnt := u_V5RetFil( cEmpresa )
	EndIf
	
	aCab := {}
	aItens := {}  

	nPosIni := i
	SB1->( DbSetOrder( 1 ) )
	SB2->( DbSetOrder( 1 ) )	
	While i <= Len( aCols ) .And. ( cPedRef == GdFieldGet( 'WKC5_P_REF' , i ,, aHeader , aCols ) )

		cProduto := PadR( GdFieldGet( 'WKC6_PRODUTO' , i ,, aHeader , aCols ) , Len( SB1->B1_COD ) ) 
		cLocal   := GdFieldGet( 'WKC6_LOCAL' , i ,, aHeader , aCols )
		cTipoProd:= ""
		If SB1->( DbSeek( xFilial("SB1") + cProduto ) ) 
			cTipoProd:= SB1->B1_TIPO
			If Empty( cLocal )
				cLocal := SB1->B1_LOCPAD 
				GdFieldPut( 'WKC6_LOCAL' , cLocal , i , aHeader , aCols )
			EndIf
		EndIf 
		
		If !Empty( cLocal ) .And. SB2->( !DbSeek( xFilial( 'SB2' ) + cProduto + cLocal ) )
			CriaSb2( cProduto , cLocal )
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


		aItemAux := {}
		aCabAux := {}

		/*
			* Valida Conteudo dos Campos - Itens
		*/
		For nCampo := 1 To Len( aCmpPed ) 
			If '_FILIAL' $ aCmpPed[ nCampo ] 
				Loop
			EndIf

			cConteudo := GdFieldGet( "WK"+aCmpPed[ nCampo ] , i ,, aHeader , aCols )			
			If Empty( cConteudo ) .And. aCmpPed[ nCampo ] == 'C6_TES' 
				//RRP - 24/08/2016 - Ajuste para utilizar uma TES para cada tipo de produto.
				cCGCCli := GdFieldGet( "WKA1_CGC" , i ,, aHeader , aCols )
				cConteudo := VldTES(cProduto,cLocal,cCGCCli)//'999'
				//Inclusão do novo conteúdo no array
				GdFieldPut( "WK"+aCmpPed[nCampo] , cConteudo , i , aHeader , aCols )
			EndIf
							
			If !Empty( cConteudo )
				For j := 1 To Len( aValidCont )
					If aValidCont[ j ][ 1 ] == aCmpPed[ nCampo ] .And. !Eval( aValidCont[ j ][ 2 ] , cConteudo )
						lContinua := .F. 
						nSeq ++ 
						aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,cProduto,'',aCmpPed[ nCampo ] ,'',	'E',Eval( aValidCont[ j ][ 3 ] , cConteudo ),cArquivo }
										
						Aadd( aLog[ nLen ][ 2 ] , aAux )
						aCols[ i ][ 1 ] := oStsEr   
					EndIf
				Next
			EndIf  
			
			If Left( aCmpPed[ nCampo ] , 3 ) = 'C6_'
				If ValType(cConteudo)=="C"
					cConteudo:=Alltrim(cConteudo)
				EndIf
				Aadd( aItemAux , { aCmpPed[ nCampo ]  , cConteudo , Nil } )
			EndIf

			If Left( aCmpPed[ nCampo ] , 3 ) == 'C5_'         
				If ( aCmpPed[ nCampo ] == 'C5_CONDPAG' ) 
				    cCli := ''
				    cLoja   := ''
			    	cCGCCli := GdFieldGet( "WKA1_CGC" , i ,, aHeader , aCols )
	
				   	SA1->( DbSetOrder( 3 ) )
				   	If SA1->( !DbSeek( xFilial("SA1") + cCGCCli ) )
						lContinua := .F. 
						nSeq ++ 
						aAux := { StrZero( nSeq ,2 ) ,cEmpresa,	'' ,cPedRef,cProduto,'','A1_CGC'          ,	'',	'E','Cliente nao cadastrado.'              ,cArquivo }
						Aadd( aLog[ nLen ][ 2 ] , aAux )
						aCols[ i ][ 1 ] := oStsEr
				   	Else
				   		cCli 	:= SA1->A1_COD
				   		cLoja 	:= SA1->A1_LOJA	
				   	EndIf		    						
					Aadd( aCabAux , { 'C5_CLIENTE'	, cCli	 	, NIL } )	
					Aadd( aCabAux , { 'C5_LOJA' 	, cLoja	 	, NIL } )
					
					//Adicionar natureza no array
					If !cTipoProd $ 'MT/JR'
						Aadd( aCabAux , { 'C5_NATUREZ'	, getNat(cProduto,cLocal,cCGCCli)	, NIL } )
					EndIf
					
					//Nota de Serviço preencher campo do Município de prestação
					If Alltrim(SM0->M0_ESTCOB)=="RS" .AND. cTipoProd == 'SR'
						CC2->(DbSetOrder(1))
						If CC2->(DbSeek(xFilial("CC2")+SM0->M0_ESTCOB+Alltrim(SubStr(SM0->M0_CODMUN,3,5))))
							Aadd( aCabAux , { 'C5_ESTPRES'	, CC2->CC2_EST				, NIL } )
							Aadd( aCabAux , { 'C5_MUNPRES'	, Alltrim(CC2->CC2_CODMUN)	, NIL } )
							Aadd( aCabAux , { 'C5_DESCMUN'	, Alltrim(CC2->CC2_MUN)		, NIL } )
						EndIf
					EndIf
				EndIf
					
				If !Empty( cConteudo )
					Aadd( aCabAux , { aCmpPed[ nCampo ]  , cConteudo , Nil } )			
				EndIf
			EndIf 
						
		Next 
		
		Aadd( aItens , aItemAux )
		
		If Len( aCab ) == 0
    		aCab := aClone( aCabAux )
    	EndIf
    		
		i += 1 
    EndDo
    
	nPosFim := i - 1 
	/*
		* Grava Pedido somente se todos os campos da Capa e Itens estiverem ok
	*/
	If lContinua  
		Private lMsErroAuto := .F. 
		SA1->( DbSetOrder( 1 ) )
		MSExecAuto( { |x,y,z| Mata410(x,y,z) } , aCab ,aItens,3)  	
			
		
		If lMsErroAuto 
		    nSeq ++

			aAux := { StrZero( nSeq ,2 ) ,cEmpresa,'' ,cPedRef,'','','' ,'','E','Erro interno na gravacao do registro.',cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			
			For j := nPosIni To nPosFim
				aCols[ j ][ 1 ] := oStsEr 
			Next
	    Else  
				
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,cEmpresa,'' ,cPedRef,'',SC5->C5_NUM ,'','','S','Inserido Corretamente.',cArquivo }
							
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
If lSC5Exc
	cFilAnt := cFilBak
EndIf

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

Return

/*
Função..............: 
*/
*----------------------------------*
Static Function ValPedRef( cRef )   
*----------------------------------*
Local aArea := GetArea()
Local lRet
Local cQuery         
Local cAlias := '_PEDREF' 

cQuery := "SELECT COUNT(*) TOTAL FROM " +RetSqlName( 'SC5' ) 
cQuery += " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = '" + xFilial( 'SC5' ) + "' AND C5_P_REF = '" + cRef + "' "

TCQuery cQuery ALIAS ( cAlias ) NEW

lRet := ( ( cAlias )->TOTAL = 0 ) 

If Select( cAlias ) > 0
	( cAlias )->( DbCloseArea() )
EndIf	

RestArea( aArea )

Return( lRet )

/*
Função  : getNat
Retorno : cNatu
Objetivo: Retorna a Natureza 
Autor   : Renato Rezende
Data    : 01/09/2016
*/
*------------------------------------------------*
 Static Function getNat(cProduto,cLocal,cCGCCli)
*------------------------------------------------*
Local lSeekSb1 	:= .F.
Local lSeekSa1 	:= .F.
Local cNatu		:= ""

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(DbSeek( xFilial("SB1") + cProduto + cLocal ))
	lSeekSb1 :=.T.
EndIf

DbSelectArea("SA1")
SA1->(DbSetOrder(3))
If SA1->(DbSeek( xFilial("SA1") + cCGCCli ))
	lSeekSa1 :=.T.
EndIf

If lSeekSb1 .AND. lSeekSa1
	If Alltrim(SB1->B1_TIPO) ==	"SR"
		If cEmpAnt $ 'FC/FE/V5'
			If Alltrim(SB1->B1_CODISS) == '07285' .AND. Alltrim(SA1->A1_TPESSOA) == "ER"
				cNatu:= '1098'			
			ElseIf Alltrim(SB1->B1_CODISS) == '07498' .AND. Alltrim(SA1->A1_TPESSOA) == "ER"
				cNatu:= '1096'		    
			Else
				cNatu:= '14.06'
			EndIf
		Else
			cNatu:= '1.05'
		EndIf
	ElseIf Alltrim(SB1->B1_TIPO) $ "ST/SC" .AND. Alltrim(SA1->A1_TPESSOA) == "ER"
		cNatu:= '1098'
	Else
		cNatu:= '1000'
	EndIf
Else
	cNatu:= '1000'
EndIf 

Return cNatu

/*
Função  : VldTES
Retorno : cTES
Objetivo: Retorna a TES que deverá 
Autor   : Renato Rezende
Data    : 23/08/2016
*/
*------------------------------------------------*
 Static Function VldTES(cProduto,cLocal,cCGCCli)
*------------------------------------------------*
Local lSeekSb1 	:= .F.
Local lSeekSa1 	:= .F.
Local cTES		:= ""

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(DbSeek( xFilial("SB1") + cProduto + cLocal ))
	lSeekSb1 :=.T.
EndIf

DbSelectArea("SA1")
SA1->(DbSetOrder(3))
If SA1->(DbSeek( xFilial("SA1") + cCGCCli ))
	lSeekSa1 :=.T.
EndIf 

/*
SR - SERVICO
ST - TELECOMUNICACAO
SF - FATURA
JR - JUROS (antigo CO)
MT - MULTA (antigo CO)
*/

If lSeekSb1 .AND. lSeekSa1
	If Alltrim(SB1->B1_TIPO) ==	"SR"
		If Alltrim(SA1->A1_EST) == "EX" 
			cTES := "6BN" 
		Else
			cTES := "56V"
		EndIf
	ElseIf Alltrim(SB1->B1_TIPO) $ "ST/SC"
		If Alltrim(SA1->A1_TPESSOA) == "CI"//Industria 
			cTES := "82K" 
		ElseIf Alltrim(SA1->A1_TPESSOA) $ "EP/ER"//Empresa Publica
			cTES := "83K"
		ElseIf Alltrim(SA1->A1_TPESSOA) == "CC"//Comercio
			cTES := "83K"
		ElseIf Alltrim(SA1->A1_TPESSOA) == "OS"//Servicos
			cTES := "84K"
		ElseIf Alltrim(SA1->A1_TPESSOA) == "AT"//Ato Cotepe
			cTES := "5JA"
		Else
			cTES:= "999"
		EndIf
	ElseIf Alltrim(SB1->B1_TIPO) == "SF"
		cTES:= "5QI"
	ElseIf Alltrim(SB1->B1_TIPO) == "JR"
		cTES:= "5JA"
	ElseIf Alltrim(SB1->B1_TIPO) == "MT"
		cTES:= "5JA"	
	Else
		cTES:= "999"
	EndIf                     
Else
	cTES:= "999"
EndIf

Return cTES