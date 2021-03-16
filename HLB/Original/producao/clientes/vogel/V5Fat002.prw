#Include 'Protheus.Ch'

/*
Funcao      : V5FAT002
Parametros  : cTipoInt
Retorno     : Nil
Objetivos   : Processar Integração de produtos  - Projeto Vogel
Autor       : Renato Rezende
Data/Hora   : 28/07/2016
*/

*-----------------------------------------* 
 User Function V5FAT002( cTipoInt )
*-----------------------------------------*  
Local aCols 		:= &( "oArq" + cTipoInt ):aCols
Local aHeader 		:= &( "oArq" + cTipoInt ):aHeader
Local aObgtServ 	:= {}
Local aObgtMerc		:= u_V5RetCmp( cTipoInt , .T. )//Array com os campos obrigatorios para produtos
Local aCmpObrigat	:= {}   
Local aHeaderLog 	:= {'SEQ' , 'EMP' , 'B1_FILIAL' , 'B1_PRODUTO' , 'CAMPO' , 'VALOR' , 'STATUS' , 'MENSAGEM' , 'ARQUIVO'}
Local aLog    		:= {}
Local aCab 			:= {}
Local aCSB5			:= {}

Local cArquivo  	:= ""
Local cEmpresa		:= ""
Local cProduto		:= ""
Local cDescri		:= ""
Local cTipo			:= ""
Local cUnidad		:= ""
Local cLocPad  		:= ""
Local cCodIss 		:= ""
Local cPosIpi  		:= ""
Local cConta   		:= ""
Local cOrigem		:= ""
Local cImpor  		:= ""
Local cTip			:= ""
Local cGarant 		:= ""
Local cCofins		:= ""
Local cCsll			:= ""
Local cPis 			:= ""
Local cFilBkp		:= cFilAnt
Local cGrTrib		:= ""
Local cIRRF			:= ""
Local cTribMun		:= ""

Local nAliqIss		:= 0
Local nPicm			:= 0
Local nIpi			:= 0
Local nPCofins		:= 0
Local nPPis			:= 0

Local i,nCampo 

Local lContinua		:= .T.
Local lServico		:= .F.
Local lSB1Exc		:= !Empty(xFilial("SB1"))
Local lSB5Exc		:= !Empty(xFilial("SB5"))

Private lMsErroAuto := .F.
Private cModLog		:= OAPP:CMODNAME

//Array com os campos obrigatorios para Servicos
aObgtServ := {'B1_COD' 		,;
			  'B1_DESC' 	,;
			  'B1_TIPO' 	,;
			  'B1_UM' 		,;
			  'B1_IMPORT' 	,;
			  'B1_P_TIP' 	,;
			  'B1_GARANT'}

Aadd( aLog , { , aHeaderLog } )

For i := 1 To Len( aCols )
	//Validando se o arquivo deve ser processado
	If aCols[i][1]:CNAME == 'BR_BRANCO'
	
		nSeq := 0
		If cArquivo <> aCols[ i ][ 3 ]
			cArquivo := aCols[ i ][ 3 ] 
			Aadd( aLog , { cArquivo , {} }  )
			nLen := Len( aLog )
		EndIf
	    
		lContinua	:= .T.
		cFilAnt		:= cFilBkp
		SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior		
		cEmpresa	:= GdFieldGet( 'WKEMP' 			, i ,, aHeader , aCols )
		cProduto 	:= PadR( GdFieldGet( 'WKB1_COD' , i ,, aHeader , aCols ) , Len( SB1->B1_COD ) )
		cDescri		:= PadR( GdFieldGet( 'WKB1_DESC' 		, i ,, aHeader , aCols ) , Len( SB1->B1_DESC ) )
		cTipo		:= PadR( GdFieldGet( 'WKB1_TIPO' 		, i ,, aHeader , aCols ) , Len( SB1->B1_TIPO ) )
		cUnidad		:= PadR( GdFieldGet( 'WKB1_UM' 		, i ,, aHeader , aCols ) , Len( SB1->B1_UM ) )
		cLocPad		:= PadR( GdFieldGet( 'WKB1_LOCPAD' 	, i ,, aHeader , aCols ) , Len( SB1->B1_LOCPAD ) )
		nPicm		:= GdFieldGet( 'WKB1_PICM' 		, i ,, aHeader , aCols )
		nIpi		:= GdFieldGet( 'WKB1_IPI' 		, i ,, aHeader , aCols )
		cNcm		:= PadR( GdFieldGet( 'WKB1_POSIPI' 	, i ,, aHeader , aCols ) , Len( SB1->B1_POSIPI ) )
		cConta		:= PadR( GdFieldGet( 'WKB1_CONTA' 	, i ,, aHeader , aCols ) , Len( SB1->B1_CONTA ) )
		cOrigem		:= PadR( GdFieldGet( 'WKB1_ORIGEM' 	, i ,, aHeader , aCols ) , Len( SB1->B1_ORIGEM ) )
		cImpor		:= PadR( GdFieldGet( 'WKB1_IMPORT' 	, i ,, aHeader , aCols ) , Len( SB1->B1_IMPORT ) )
		cTip		:= PadR( GdFieldGet( 'WKB1_P_TIP' 	, i ,, aHeader , aCols ) , Len( SB1->B1_P_TIP ) )
		cGarant		:= PadR( GdFieldGet( 'WKB1_GARANT' 	, i ,, aHeader , aCols ) , Len( SB1->B1_GARANT ) )
		cCofins		:= PadR( GdFieldGet( 'WKB1_COFINS' 	, i ,, aHeader , aCols ) , Len( SB1->B1_COFINS ) )
		cCsll		:= PadR( GdFieldGet( 'WKB1_CSLL' 		, i ,, aHeader , aCols ) , Len( SB1->B1_CSLL ) )
		cPis		:= PadR( GdFieldGet( 'WKB1_PIS' 		, i ,, aHeader , aCols ) , Len( SB1->B1_PIS ) )
		nAliqIss	:= GdFieldGet( 'WKB1_ALIQISS' 	, i ,, aHeader , aCols )
		cCodIss		:= PadR( GdFieldGet( 'WKB1_CODISS' 	, i ,, aHeader , aCols ) , Len( SB1->B1_CODISS ) )
		cNbs		:= PadR( GdFieldGet( 'WKB5_NBS' 	, i ,, aHeader , aCols ) , Len( SB5->B5_NBS ) )
				
		//Verifica Filial que sera gravada o arquivo e se o CNPJ existe no SIGAMAT
		If lSB1Exc .And.  ( AllTrim( SM0->M0_CGC ) <> AllTrim( cEmpresa ) )
			cFilAnt := u_V5RetFil( cEmpresa )
			//Se o CNPJ não existir não faz nenhuma validacao a mais
			If Empty(cFilAnt)
				lLinhaOk := .F.
				cFilAnt := cFilBkp 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;  
							cEmpresa,;
							cFilAnt ,;
							cProduto,;
							'EMP' ,;
							'',;
							'E',;
							'CNPJ inexistente',;
							cArquivo }
								
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr
				Loop
			EndIf 	
		EndIf
	
		//Verifica se e Produto ou Servico
		If Alltrim(cTip)== '2'
	    	aCmpObrigat := aClone(aObgtServ)
	    	lServico	:= .T.
	    Else
	    	aCmpObrigat := aClone(aObgtMerc)
	    	lServico	:= .F.
	    EndIf
        //Valida se o código do produto foi preenchido
		If Empty( cProduto )
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;  
						cEmpresa,;
						cFilAnt ,;
						cProduto,;
						'B1_COD' ,;
						'',;
						'E',;
						'Campo chave nao informado',;
						cArquivo }
							
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsEr 	
		EndIf
		//Verifica se o produto ja existe
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))	
		If SB1->(DbSeek(xFilial("SB1")+cProduto))
			lContinua := .F. 
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						cFilAnt ,;
						cProduto,;
						'B1_COD' ,;
						'',;
						'E',;
						'Produto ja existe',;
						cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsPr
		//RRP - 24/03/2017 - Ajuste após atualização do sistema. Execauto Mata010 parou de incluir produtos.
		Else
			SB1->(DbGoTop())
		EndIf
	
	    //Verifica os campos obrigatorios preenchidos
		If lContinua
			For nCampo := 1 To Len( aCmpObrigat )
		   		//Produto do tipo SR deverao conter o codigo do iss preenchido 
				If Empty( GdFieldGet( "WK"+aCmpObrigat[ nCampo ] , i ,, aHeader , aCols ) ) 
					lContinua := .F. 
					nSeq ++ 
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								aCmpObrigat[ nCampo ] ,;
								'',;
								'E',;
								'Conteudo nao informado',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr 						
				EndIf
			Next 
		EndIf
		
		//Valida conteudo dos campos
		If lContinua
	   		//Verifica se a unidade de medida existe no Protheus
			DbSelectArea("SAH")
			SAH->(DbSetOrder(1))
			If !(SAH->(DbSeek(xFilial("SAH")+cUnidad)))
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							cFilAnt ,;
							cProduto,;
							'B1_UM' ,;
							'',;
							'E',;
							'Unidade nao cadastrada',;
							cArquivo }
							
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr
			EndIf 
			
			//Verifica se o tipo existe no Protheus
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1))
			If !(SX5->(DbSeek(xFilial("SX5")+"02"+cTipo)))
				lContinua := .F. 
				nSeq ++ 
				aAux := { StrZero( nSeq ,2 ) ,;
							cEmpresa,;
							cFilAnt ,;
							cProduto,;
							'B1_TIPO' ,;
							'',;
							'E',;
							'Tipo nao cadastrado',;
							cArquivo }
							
				Aadd( aLog[ nLen ][ 2 ] , aAux )
				aCols[ i ][ 1 ] := oStsEr
			EndIf
			
			//Verifica se o local existe no Protheus
			If !Empty(cLocPad)
				DbSelectArea("NNR")
				NNR->(DbSetOrder(1))
				If !(NNR->(DbSeek(xFilial("NNR")+cLocPad)))
					lContinua := .F. 
					nSeq ++ 
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B1_LOCPAD' ,;
								'',;
								'E',;
								'Local nao cadastrado',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			Else
				cLocPad:= "01" //Caso venha em branco preencher com 01
			EndIf
			
			//Verifica se o codigo do servico existe no Protheus
			If !Empty(cCodIss)
				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If !(SX5->(DbSeek(xFilial("SX5")+"60"+cCodIss)))
					lContinua := .F. 
					nSeq ++
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B1_CODISS' ,;
								'',;
								'E',;
								'Codigo nao cadastrado',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			EndIf	
			//Verifica se o codigo nbs existe no Protheus
			If !Empty(cNbs)
				DbSelectArea("CLK")
				CLK->(DbSetOrder(1))
				If !(CLK->(DbSeek(xFilial("CLK")+cNbs)))
					lContinua := .F. 
					nSeq ++
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B5_NBS' ,;
								'',;
								'E',;
								'Codigo nao cadastrado',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			EndIf		 
	
			//Verifica se o tipo existe no Protheus
			If !Empty(cOrigem) 
				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If !(SX5->(DbSeek(xFilial("SX5")+"S0"+cOrigem)))
					lContinua := .F. 
					nSeq ++ 
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B1_ORIGEM' ,;
								'',;
								'E',;
								'Origem nao cadastrada',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			Else
				cOrigem := "0" //Fixo Nacional	
			EndIf 
	
			//Verifica se a NCM existe no sistema
			If !Empty(cNcm) 
				DbSelectArea("SYD")
				SYD->(DbSetOrder(1))
				If !(SYD->(DbSeek(xFilial("SYD")+cNcm)))
					lContinua := .F. 
					nSeq ++ 
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B1_POSIPI' ,;
								'',;
								'E',;
								'NCM nao cadastrada',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			Else
				cNcm := "99999999" //Fixo	
			EndIf
	        
	        //Verifica de a conta contabil e valida
			If !Empty(cConta) 
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))
				If !(CT1->(DbSeek(xFilial("CT1")+cConta)))
					lContinua := .F. 
					nSeq ++ 
					aAux := { StrZero( nSeq ,2 ) ,;
								cEmpresa,;
								cFilAnt ,;
								cProduto,;
								'B1_CONTA' ,;
								'',;
								'E',;
								'Conta nao cadastrada',;
								cArquivo }
								
					Aadd( aLog[ nLen ][ 2 ] , aAux )
					aCols[ i ][ 1 ] := oStsEr
				EndIf
			Else
				cConta := "31113002" //Fixo	
			EndIf		
			 
		EndIf	
		
		If !lContinua 
			Loop
		EndIf 
		
		cCofins		:=IIF(Empty(cCofins),"1",cCofins)		//Caso venha em branco carregar com Sim
		cCsll		:=IIF(Empty(cCsll),"1",cCsll)			//Caso venha em branco carregar com Sim
		cPis		:=IIF(Empty(cPis),"1",cPis)				//Caso venha em branco carregar com Sim
		cGrTrib		:=IIF(Alltrim(cTipo)$"ST/SC","001","")	//Preencher o grupo de tributacao quando o tipo for ST ou SC
		nPCofins	:=IIF(Alltrim(cTipo)$"SR",7.6,IIF(Alltrim(cTipo)$"JR",4,0))
		nPPis		:=IIF(Alltrim(cTipo)$"SR",1.65,0)
		cIRRF		:=IIF(Alltrim(cTipo)$"ST/SC",'S',IIF(Alltrim(cTipo)$"SR".AND.cEmpAnt$'FA/G4','S','N'))
		cTribMun	:=IIF(Alltrim(cCodIss)=='1.07','010700100',cCodIss)
		
		//Montagem MSExecAuto
		aCab := {}                 
		aCab := {{"B1_FILIAL"	,cFilAnt							,NIL},;
				{"B1_COD"		,cProduto							,NIL},;
				{"B1_DESC"		,cDescri							,NIL},;
				{"B1_TIPO"		,cTipo								,Nil},;
				{"B1_UM"		,cUnidad 							,Nil},;
				{"B1_LOCPAD"	,cLocPad							,Nil},;
				{"B1_PICM"		,nPicm								,Nil},;
				{"B1_POSIPI"	,cNcm								,Nil},;
				{"B1_IPI"		,nIPI								,Nil},;
				{"B1_COFINS"	,cCofins   							,Nil},;
				{"B1_CSLL"		,cCsll	 							,Nil},;
				{"B1_PIS"		,cPis  								,Nil},;
				{"B1_ALIQISS"	,nAliqIss							,Nil},;
				{"B1_CONTRAT"	,"N"								,Nil},;
				{"B1_APROPRI"	,"D"								,Nil},;
				{"B1_LOCALIZ"	,"N"								,Nil},;
				{"B1_ORIGEM"	,cOrigem							,Nil},;
				{"B1_GRUPO"		,""									,Nil},;
				{"B1_CONTA"		,cConta								,Nil},;
				{"B1_GARANT"	,cGarant							,Nil},;
				{"B1_P_TIP"		,cTip								,Nil},;
				{"B1_IMPORT"	,cImpor								,Nil},;
				{"B1_CODISS"	,cCodIss							,Nil},;
				{"B1_GRTRIB"	,cGrTrib							,Nil},;
				{"B1_TRIBMUN"	,cTribMun							,Nil},;				
				{"B1_PCOFINS"	,nPCofins							,Nil},;
				{"B1_PPIS"		,nPPis								,Nil},;	
				{"B1_IRRF"		,cIRRF								,Nil},;							
				{"B1_TIPCONV"	,"M"								,Nil}}
	    
		if !empty(cNbs)
			aCSB5 := {}
	    	AADD(aCSB5,{"B5_FILIAL"	,cFilAnt			,Nil})
	   		AADD(aCSB5,{"B5_COD"	,cProduto			,Nil})
	   		AADD(aCSB5,{"B5_NBS"	,ALLTRIM(cNbs)		,Nil})
        endif
	
    
		MSExecAuto( { |x,y| Mata010(x,y) } , aCab ,3 ) //Inclusão  	
		
		
		If lMsErroAuto
			//MostraErro() 
			nSeq ++
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						cFilAnt ,;
						cProduto,;
						'' ,;
						'',;
						'E',;
						'Erro interno na gravacao do registro.',;
						cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsEr 
	    Else              

			//Complemento do produto
			if !empty(cNbs) .AND. cTipo == 'SR'
				MSExecAuto({|x,y| Mata180(x,y)},aCSB5,3)
	    	endif
			
			nSeq ++ 
			aAux := { StrZero( nSeq ,2 ) ,;
						cEmpresa,;
						cFilAnt ,;
						cProduto,;
						'' ,;
						'',;
						'S',;
						'Inserido Corretamente.',;
						cArquivo }
						
			Aadd( aLog[ nLen ][ 2 ] , aAux )
			aCols[ i ][ 1 ] := oStsok    
	    
			//Cria o produto no SB2    
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			If !(SB2->(DBSeek(xFilial("SB2")+cProduto+cLocPad)))
				CriaSB2(cProduto,cLocPad)	
			EndIf
	    
	    EndIf

	    
	EndIf
Next 

cFilAnt := cFilBkp
SM0->(DbSeek(cEmpAnt+cFilAnt)) //volta para a empresa anterior

&( "oArq" + cTipoInt ):aCols := aCols 
&( "oArq" + cTipoInt ):oBrowse:Refresh()
&( "aLog" + cTipoInt ) := aLog

SB1->(DbCloseArea())
SAH->(DbCloseArea())
SYD->(DbCloseArea())
CT1->(DbCloseArea())
SX5->(DbCloseArea())

Return