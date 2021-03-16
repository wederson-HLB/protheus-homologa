#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"


/*
** Definição das constantes - Tipo de layout a ser importado
*/
#DEFINE X291 'X291'
#DEFINE X292 'X292'
#DEFINE X300 'X300'
#DEFINE X310 'X310'
#DEFINE X320 'X320'
#DEFINE X330 'X330'
#DEFINE Y520 'Y520'
#DEFINE Y570 'Y570'

/*
Funcao      : GTTAF001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar importar planilha blocos X e Y - Sped ECF
Observações :
Autor       : Leandro Brito
Revisão		:
Data/Hora   : 03/08/2015
Módulo      : SigaTAF
*/

*-------------------------------------------*
User Function GTTAF001
*-------------------------------------------*
Local aArea      	:= GetArea()
Local chTitle    	:= "Grant Thornton"

Local chMsg      	:= "SPED ECF - Importação Planilha Blocos X e Y"
Local cTitle

Local cText     	:= "Este programa tem como objetivo importar planilha excel, no formato .csv, contendo as informações dos blocos X e Y do Sped ECF."
Local bFinish    	:= { || .T. }

Local cResHead

Local lNoFirst
Local aCoord

Local oProcesss

Private oWizard
Private oGetResult

Private cPlanilha   := Space( 200 )
Private cLayout   := Space( 200 )
Private aItensLay

Private oLbx , aDadosLog := {}

Private oBrwPlan

Private cResult     := ""



oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord )

oWizard:NewPanel ( "Selecao de Arquivo"               , "Informe o local da planilha e o layout a ser importado:" , { || .T. }/*bBack*/ , { || MsgYesNo( 'Confirma importação da planilha ?' ) .And. ( Processa( { || Import() } , 'Importando Planilha...' ) , .T. ) } ,bFinish ,, { || TelaArq() } /*bExecute*/  )
oWizard:NewPanel ( "Resultado"               , "Resultado do Processamento" , { || .T. }/*bBack*/ , { ||  .T.}  ,bFinish , .T. , { || ExibeLog() } /*bExecute*/  )

oWizard:Activate( .T. )

RestArea( aArea )

Return

/*
Função...............: TelaArq
Objetivo.............: Tela de Seleção da planilha e layout
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Agosto/2015
*/
*-----------------------------------------------*
Static Function TelaArq
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oCombo

aItensLay := { 	'X291 - Operaçoes com o Exterior - Pessoa Vinculada/Interposta/País com Tributação Favorecida' ,;
				'X292 - Operações com o Exterior - Pessoa Não Vinculada/Não Interposta/País sem Tributação Favorecida' ,;
				'X300/X310 - Operações com o Exterior - Exportações (Entradas de Divisas)' ,;
				'X320/X330 - Operações com o Exterior - Importações (Saída de Divisas)' ,;
				'Y520 - Pagamentos ou Rendimentos Recebidos do Exterior ou de Não Residentes' ,;
				'Y570 - Demonstrativo do Imposto de Renda, CSLL e Contribuição Previdenciária Retidos na Fonte' }

@10,10 Say "Arquivo:" Size 60,10 Of oPanel Pixel
@10,35 MSGet cPlanilha   Size 230,10  When .F. Of oPanel Pixel

@10,270 Button '...' Size 20,10 Action( cPlanilha := ChooseFile() ) Of oPanel Pixel

@25,10 Say "Layout:" Size 60,10 Of oPanel Pixel
@25,35 MSComboBox oCombo VAR cLayout ITEMS aItensLay Size 250,10 Of oPanel Pixel

@50,10 Button 'Gera Modelo' Size 35,15 Action( GeraModelo() ) Of oPanel Pixel

Return

/*
Funcao.........: ChooseFile
Objetivo.......: Selecionar arquivo .csv a ser importado
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ChooseFile
*-----------------------------------------*
Local cTitle        := "Selecione o arquivo"
Local cMask         := "Arquivos XLS (*.csv) |*.csv"
Local nDefaultMask  := 0
Local cDefaultDir   := "C:\"
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna caminho e arquivo selecionado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( PadR( cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions ) , 300 ) )


/*
Funcao.........: GeraModelo
Objetivo.......: Gerar Modelo de importação para os blocos X e Y do Sped ECF
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function GeraModelo
*-----------------------------------------*
Local oExcel


Local cFile 
Local nFile

Local cBuffer
Local nLinha   

Local i
Local aCamposLay := {}

Local cDescTipo

cLayout := Left( cLayout , 4 )                 
cFile := GetTempPath() + cLayout + '.csv'

If File( cFile )
	FErase( cFile )
	If FError() <> 0
		MsgStop( 'Erro arquivo ' + cFile + ' em uso.' )
		Return
	EndIf
EndIf

nFile := FCreate( cFile )

If FError() <> 0
	MsgStop( 'Erro na criação do arquivo. ' )
	Return
EndIf

Do Case
	
	Case ( cLayout == 'X291' )
		aAlias := { { 'CFT' , { 'CFT_PERIOD' , 'CFT_CODLAN' , 'CFT_VALOR' } } }     
		
	Case ( cLayout == 'X292' )
		aAlias := { { 'CFT' , { 'CFT_PERIOD' , 'CFT_CODLAN' , 'CFT_VALOR' } } }     
		
	Case ( cLayout == 'X300' )		
		aAlias := { { 'CAY' , {} } , { 'CAZ' , {} } } 
		
	Case ( cLayout == 'X320' )		
		aAlias := { { 'CFV' , {} } , { 'CFX' , {} } }		                        
		
	Case ( cLayout == 'Y520' )
		aAlias := { { 'CFQ' , {} } }     		 
		
	Case ( cLayout == 'Y570' )
		aAlias := { { 'CEX' , { 'CEX_PERIOD' , 'CEX_CNPJ' , 'CEX_NOMEMP' , 'CEX_ORGPUB' , 'CEX_CODREC' , 'CEX_RENDIM' , 'CEX_IRRET' , 'CEX_CSLLRE' } } }     				
	    
		
EndCase

/*
** Obtem informações do arquivo ( nome, tipo, tamanho ) para montar o cabecalho
*/

SX3->( DbSetOrder( 1 ) )
nLenSX3 := Len( SX3->X3_CAMPO )

For nLinha := 1 To 3

	cBuffer := ""
	For nAlias := 1 To Len( aAlias )	
		
		cAlias := aAlias[ nAlias ][ 1 ]
		
		SX3->( DbSeek( cAlias ) )
		While SX3->( !Eof() .And. X3_ARQUIVO == cAlias )
			
			If ( 'FILIAL' $ AllTrim( SX3->X3_CAMPO  ) .Or. '_ID' $ AllTrim( SX3->X3_CAMPO  ) )
				SX3->( DbSkip() )
				Loop
			EndIf
			
			If Len( aAlias[ nAlias ][ 2 ] )  > 0 .And. ( Ascan( aAlias[ nAlias ][ 2 ] , AllTrim( SX3->X3_CAMPO ) ) == 0 )
				SX3->( DbSkip() )
				Loop
			EndIf 
			
			If Len( aAlias[ nAlias ][ 2 ] ) == 0 .And. ( !X3Uso( SX3->X3_USADO ) .Or. SX3->X3_CONTEXT == 'V' )
				SX3->( DbSkip() )
				Loop
			EndIf 			
			
			
			If ( nLinha == 1  )
				cBuffer += AllTrim( SX3->X3_CAMPO ) + ";"
				
			ElseIf ( nLinha == 2  )
				cDescTipo := ""
				If SX3->X3_TIPO == 'C'
					cDescTipo := 'Alfanumerico'
				ElseIf SX3->X3_TIPO == 'N'
					cDescTipo := 'Numerico'
				ElseIf SX3->X3_TIPO == 'D'
					cDescTipo := 'Data ( AAAAMMDD )'
				EndIf
				cBuffer += '( Tipo : ' + cDescTipo + If( SX3->X3_TIPO <> 'D' , ' - Tamanho ' + StrZero( SX3->X3_TAMANHO , 3 ) , '' ) + ');'
				
			Else
				cBuffer += AllTrim( SX3->X3_TITULO )  + If( X3Obrigat( SX3->X3_CAMPO ) , "(OBRIGATORIO)" , "" ) +  ";"
				
			EndIf
			
			SX3->( DbSkip() )
			
		EndDo

	Next

	cBuffer += Chr( 13 ) + Chr( 10 )
	FWrite( nFile , cBuffer , Len( cBuffer ) )
Next

FClose( nFile )

oExcel:=MsExcel():New()
oExcel:WorkBooks:Open( cFile )
oExcel:SetVisible( .T. )

Return       

/*
Função...............: Import
Objetivo.............: Importação Planilha 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Agosto/2015
*/
*-----------------------------------------------*
Static Function Import
*-----------------------------------------------*       
Local nFile
Local nLinha 
               
Local aLog                                          
Local aLogAux 

Local aLinha
Local aCab                                

Local aCab,aDet     

cLayout := Left( cLayout , 4 )


Ft_Fuse( cPlanilha ) 

ProcRegua( Ft_FLastRec() )

/*
If FError() <> 0
	MsgStop( 'Erro na criação do arquivo. ' )
	Return
EndIf            
*/

CFU->( DbSetOrder( 2 ) )
CH6->( DbSetOrder( 2 ) )
CFT->( DbSetOrder( 2 ) )


Ft_FGoTop()
aDadosLog := {}  

Do Case
	
	Case ( cLayout $ 'X291,X292' )
		
		nLinha := 0
		While !Ft_FEof()
			
			IncProc()
			
			aLogAux := {}
			nLinha ++
			aLinha := Separa( Ft_FReadLn() , ";" )
			If ( nLinha == 1 )
				aFields := AClone( aLinha )
				If !ValidaLayout( 'CFT' , aFields )
					AAdd( aDadosLog , { '---' , 'Layout invalido.' } )
					Exit
				EndIf
			EndIf
			
			If nLinha < 4
				Ft_FSkip()
				Loop
			EndIf
			
			cRegEcf := cLayout
			dPeriodo 	:= RetFieldInfo( aFields , 'CFT_PERIOD' , aLinha )
			If Empty( dPeriodo )
				Aadd( aLogAux , { StrZero( nLinha ,3 ) , 'Campo CFT_PERIOD nao informado.' } )
			EndIf
			
			cCodLan := RetFieldInfo( aFields , 'CFT_CODLAN' , aLinha )
			If Empty( cCodLan )
				Aadd( aLogAux , { StrZero( nLinha ,3 ) , 'Campo CFT_CODLAN nao informado.' } )
			ElseIf CH6->( DbSetOrder( 2 ) , !DbSeek( xFilial() + PadR( cRegEcf , Len( CH6->CH6_CODREG ) ) + cCodLan ) )
				Aadd( aLogAux , { StrZero( nLinha ,3 ) , 'Campo CFT_CODLAN conteudo invalido.' } )
			EndIf
			
			nValor 	:= RetFieldInfo( aFields , 'CFT_VALOR' , aLinha )
			If Empty( nValor )
				Aadd( aLogAux , { StrZero( nLinha ,3 ) , 'Campo CFT_VALOR nao informado.' } )
			EndIf
			
			If Empty( aLogAux )
				
				
				aCab := {}
				nOper := 3
				CFU->( DbSetOrder( 2 ) )
				If CFU->( DbSeek( xFilial() + cRegEcf ) ) .And. ;
					CFT->( DbSetOrder( 2 ) , DbSeek( xFilial() + CFU->CFU_ID + DtoS( dPeriodo ) + CH6->CH6_ID ) )
					Aadd( aCab , { 'CFT_REGECF' , CFT->CFT_ID , } )
					nOper := 4
				EndIf
				
				Aadd( aCab , { 'CFT_REGECF' , cRegEcf , } )
				Aadd( aCab , { 'CFT_PERIOD' , dPeriodo , } )
				Aadd( aCab , { 'CFT_CODLAN' , cCodLan , } )
				Aadd( aCab , { 'CFT_IDCODL' , CH6->CH6_ID , } )
				Aadd( aCab , { 'CFT_VALOR' , nValor , } )
				
				
				cRetorno := GravaXY( 'CFT' ,, aCab ,, nOper )
				If !Empty( cRetorno )
					Aadd( aLogAux , { StrZero( nLinha ,3 ) , cRetorno } )
				EndIf
				
				
			EndIf
			
			AEVal( aLogAux , { | x | Aadd( aDadosLog , x ) } )
			
			Ft_FSkip()
			
		EndDo
		
	Case ( cLayout == 'X300' )
		
		nLinha := 3 
		                              
		aLinha := Separa( Ft_FReadLn() , ";" )
		
		aFields := AClone( aLinha )
		If !ValidaLayout( 'CAY' , aFields )
			AAdd( aDadosLog , { '---' , 'Layout invalido.' } )
			Return
		EndIf
		Ft_FSkip();Ft_FSkip();Ft_FSkip()   
		
		aLinha := Separa( Ft_FReadLn() , ";" ) 

		nPosPeriodo := Ascan( aFields , 'CAY_PERIOD' )
		nPosNumOrd :=  Ascan( aFields , 'CAY_NUMORD' )
					
		While !Ft_FEof()
			
			cPeriodo := aLinha[ nPosPeriodo ]
			cNumOrd  := aLinha[ nPosNumOrd ]
			
			aCab :={}
			aDet := {}
			
			CAZ->( DbSetOrder( 2 ) )
			CAY->( DbSetOrder( 2 ) )
			nOper := 3
			If CAY->( DbSeek( xFilial() + cPeriodo + PadR( cNumOrd , Len( CAY->CAY_NUMORD ) ) ) )
				nOper := 4
			EndIf	

			While ( !Ft_FEof() .And. aLinha[ nPosPeriodo ] + aLinha[ nPosNumOrd ] == cPeriodo + cNumOrd ) 
				
				IncProc()
				nLinha ++

				aAux := {}
				If Empty( aCab )    
				
					If ( nOper == 4 ) 
						Aadd( aCab , { 'CAY_ID' , CAY->CAY_ID , } ) 
					EndIf
				
					For i := 1 To Len( aFields )
						If Left( aFields[ i ] , 3 ) == 'CAY'
							Aadd( aCab , { aFields[ i ] , RetFieldInfo( aFields , aFields[ i ] , aLinha ) , } )
						EndIf
					Next
				EndIf
				
				For i := 1 To Len( aFields )
					If Left( aFields[ i ] , 3 ) == 'CAZ'
						xConteudo := RetFieldInfo( aFields , aFields[ i ] , aLinha )
						Aadd( aAux , { aFields[ i ] , xConteudo , } )
						If ( aFields[ i ] == 'CAZ_NOME' ) 
						    If ( nOper == 4 ) .And. CAZ->( DbSeek( xFilial() + xConteudo ) )
								Aadd( aAux , { 'CAZ_IDINC' , CAZ->CAZ_IDINC , } )
							Else
								Aadd( aAux , { 'CAZ_IDINC' , StrZero( nLinha , 3 ) , } )
							EndIf	
						EndIf
					EndIf
				Next
				
				Aadd( aDet , AClone( aAux ) )
				
				Ft_FSkip()   
				
				aLinha := Separa( Ft_FReadLn() , ";" )
				
			EndDo
            
 			If Len( aCab ) > 0  
				
				cRetorno := GravaXY( 'CAY' , 'CAZ' , aCab , aDet , nOper )
				
				If !Empty( cRetorno )
					Aadd( aDadosLog , { StrZero( nLinha ,3 ) , cRetorno } )
				EndIf				
 			
 			EndIf
 			
		EndDo 
		
	Case ( cLayout == 'X320' )
		
		nLinha := 3 
		                              
		aLinha := Separa( Ft_FReadLn() , ";" )
		
		aFields := AClone( aLinha )
		If !ValidaLayout( 'CFV' , aFields )
			AAdd( aDadosLog , { '---' , 'Layout invalido.' } )
			Return
		EndIf		
		
		Ft_FSkip();Ft_FSkip();Ft_FSkip()   
		
		aLinha := Separa( Ft_FReadLn() , ";" ) 

		nPosPeriodo := Ascan( aFields , 'CFV_PERIOD' )
		nPosNumOrd :=  Ascan( aFields , 'CFV_NUMORD' )
					
		While !Ft_FEof()
			
			cPeriodo := aLinha[ nPosPeriodo ]
			cNumOrd  := aLinha[ nPosNumOrd ]
			
			aCab :={}
			aDet := {}
			
			CFV->( DbSetOrder( 2 ) )
			CFX->( DbSetOrder( 2 ) )
			nOper := 3
			If CFV->( DbSeek( xFilial() + cPeriodo + PadR( cNumOrd , Len( CFV->CFV_NUMORD ) ) ) )
				nOper := 4
			EndIf	

			While ( !Ft_FEof() .And. aLinha[ nPosPeriodo ] + aLinha[ nPosNumOrd ] == cPeriodo + cNumOrd ) 
				
				IncProc()
				nLinha ++

				aAux := {}
				If Empty( aCab )    
				
					If ( nOper == 4 ) 
						Aadd( aCab , { 'CFV_ID' , CAY->CAY_ID , } ) 
					EndIf
				
					For i := 1 To Len( aFields )
						If Left( aFields[ i ] , 3 ) == 'CFV'
							Aadd( aCab , { aFields[ i ] , RetFieldInfo( aFields , aFields[ i ] , aLinha ) , } )
						EndIf
					Next
				EndIf
				
				For i := 1 To Len( aFields )
					If Left( aFields[ i ] , 3 ) == 'CFX'
						xConteudo := RetFieldInfo( aFields , aFields[ i ] , aLinha )
						Aadd( aAux , { aFields[ i ] , xConteudo , } )
						If ( aFields[ i ] == 'CFX_NOME' ) 
						    If ( nOper == 4 ) .And. CAZ->( DbSeek( xFilial() + xConteudo ) )
								Aadd( aAux , { 'CFX_IDINC' , CFX->CFX_IDINC , } )
							Else
								Aadd( aAux , { 'CFX_IDINC' , StrZero( nLinha , 3 ) , } )
							EndIf	
						EndIf
					EndIf
				Next
				
				Aadd( aDet , AClone( aAux ) )
				
				Ft_FSkip()   
				
				aLinha := Separa( Ft_FReadLn() , ";" )
				
			EndDo
            
 			If Len( aCab ) > 0  
				
				cRetorno := GravaXY( 'CFV' , 'CFX' , aCab , aDet , nOper )
				
				If !Empty( cRetorno )
					Aadd( aDadosLog , { StrZero( nLinha ,3 ) , cRetorno } )
				EndIf				
 			
 			EndIf
 			
		EndDo		          
		
	Case ( cLayout == 'Y520' )
		
		nLinha := 0
		While !Ft_FEof()
			
			IncProc()
			
			nLinha ++
			aLinha := Separa( Ft_FReadLn() , ";" )
			If ( nLinha == 1 )
				aFields := AClone( aLinha )
				If !ValidaLayout( 'CFQ' , aFields )
					AAdd( aDadosLog , { '---' , 'Layout invalido.' } )
					Exit
				EndIf
			EndIf
			
			If nLinha < 4
				Ft_FSkip()
				Loop
			EndIf
			
			aCab := {}
			nOper := 3
			dPeriodo := RetFieldInfo( aFields , 'CFQ_PERIOD' , aLinha )   
			cTipExt  := RetFieldInfo( aFields , 'CFQ_TIPEXT' , aLinha )
			cPais    := RetFieldInfo( aFields , 'CFQ_PAIS' , aLinha ) 
			cForma   :=   RetFieldInfo( aFields , 'CFQ_FORMA' , aLinha ) 
			cNatOpe  :=   RetFieldInfo( aFields , 'CFQ_NATOPE' , aLinha ) 
						
			CFQ->( DbSetOrder( 2 ) )
			If CFQ->( DbSetOrder( 2 ) , DbSeek( xFilial() + DtoS( dPeriodo ) + cTipExt + cPais + cForma + cNatOpe ) )
				Aadd( aCab , { 'CFQ_ID' , CFQ->CFQ_ID , } )
				nOper := 4
			EndIf
				
			For i := 1 To Len( aFields )
				Aadd( aCab , { aFields[ i ] , RetFieldInfo( aFields , aFields[ i ] , aLinha ) , } )
			Next
				
			cRetorno := GravaXY( 'CFQ' ,, aCab ,, nOper )
			If !Empty( cRetorno )
				Aadd( aDadosLog , { StrZero( nLinha ,3 ) , cRetorno } )
			EndIf
			
			Ft_FSkip()
			
		EndDo	 
		
	Case ( cLayout == 'Y570' )
		
		nLinha := 0
		While !Ft_FEof()
			
			IncProc()
			
			nLinha ++
			aLinha := Separa( Ft_FReadLn() , ";" )
			If ( nLinha == 1 )
				aFields := AClone( aLinha )
				If !ValidaLayout( 'CEX' , aFields )
					AAdd( aDadosLog , { '---' , 'Layout invalido.' } )
					Exit
				EndIf
			EndIf
			
			If nLinha < 4
				Ft_FSkip()
				Loop
			EndIf
			
			aCab := {}
			nOper := 3
			dPeriodo  := RetFieldInfo( aFields , 'CEX_PERIOD' , aLinha )   
			cIdCodREc := RetFieldInfo( aFields , 'CEX_CODREC' , aLinha )   
			cCnpj     := RetFieldInfo( aFields , 'CEX_CNPJ' , aLinha )   
			CEX->( DbSetOrder( 2 ) )
			CW9->( DbSetOrder( 2 ) )			
			If  CW9->( DbSeek( xFilial() + cIdCodREc ) ) .And. ;
				CEX->( DbSetOrder( 2 ) , DbSeek( xFilial() + DtoS( dPeriodo ) + cCnpj + CW9->CW9_ID ) )
				Aadd( aCab , { 'CEX_ID' , CEX->CEX_ID , } )
				nOper := 4
			EndIf
				
			For i := 1 To Len( aFields )
				Aadd( aCab , { aFields[ i ] , RetFieldInfo( aFields , aFields[ i ] , aLinha ) , } )
			Next
				
			cRetorno := GravaXY( 'CEX' ,, aCab ,, nOper )
			If !Empty( cRetorno )
				Aadd( aDadosLog , { StrZero( nLinha ,3 ) , cRetorno } )
			EndIf
			
			Ft_FSkip()
			
		EndDo			
			
		
	OtherWise
		Aadd( aDadosLog , 'Layout em desenvolvimento.' )
		
EndCase   


Ft_Fuse( cPlanilha )

Return

/*
Função...............: RetFieldInfo
Objetivo.............: Converte campo da planilha com o tipo de dados do dicionario
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Agosto/2015
*/
*-----------------------------------------------------------------*
Static Function RetFieldInfo( aFields , cField , aLinha )   
*-----------------------------------------------------------------*
Local nPos
Local xRet      := CriaVar( cField , .F. )

Local nLenSx3   := Len( SX3->X3_CAMPO )


nPos := Ascan( aFields , cField ) 
If nPos > 0 .And. !Empty( aLinha[ nPos ] )

	SX3->( DbSetOrder( 2 ) )
	SX3->( DbSeek( PadR( cField , nLenSx3 ) ) )
	If SX3->X3_TIPO == 'C'
		xRet := PadR( aLinha[ nPos ] , SX3->X3_TAMANHO )
	ElseIf SX3->X3_TIPO == 'N'
		xRet := Round( Val( StrTran( StrTran( aLinha[ nPos ] , '.' , '' ) , ',' , '.' ) ) , SX3->X3_DECIMAL )
	ElseIf SX3->X3_TIPO == 'D' 
		xRet := StoD( aLinha[ nPos ] )
	EndIf   
	
EndIf

Return( xRet )

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Agosto/2015
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local nMeter := 0
Local i

If Empty( aDadosLog )
	cResult := 'Processamento efetuado com sucesso !'
	@40,05 Get oGetResult Var cResult MEMO READONLY Size 295,145 Of oPanel Pixel
	oGetResult:Refresh()	
	
Else
	@04,05 Button 'Exportar Log' Size 50,10 Action( Exporta() ) Of oPanel Pixel
	oBrwPlan := TWBrowse():New( 15, 05, 295, 145,,,, oPanel ,,,,,,,,,,,, .F. ,, .T. )
	
	oBrwPlan:SetArray( aDadosLog )
	
	oBrwPlan:AddColumn( TCColumn():New( 'Linha'       , { || aDadosLog[oBrwPlan:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwPlan:AddColumn( TCColumn():New( 'Observacao'    , { || aDadosLog[oBrwPlan:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	
	oBrwPlan:GoTop()
	oBrwPlan:Refresh()
	oBrwPlan:bLDblClick := { || .T. }
	
EndIf


Return

/*
Função...............: GravaXY
Objetivo.............: Gravar blocos X e Y Sped ECF  
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Julho/2015
*/
*-------------------------------------------------*
Static Function GravaXY( cAliasH , cAliasD , aCab , aDet , nOper )         
*-------------------------------------------------*
Local  oModel, oAux, oStruct
Local  nI        := 0

Local  nPos      := 0
Local  lRet      := .T.

Local  aAux := {}
Local cModelo

Do Case 
	Case cAliasH == 'CFT'
		cModelo := 'TAFA332'
		
	Case cAliasH == 'CAY'
		cModelo := 'TAFA334'		 
		
	Case cAliasH == 'CFV'
		cModelo := 'TAFA335'				 
		
	Case cAliasH == 'CFQ'
		cModelo := 'TAFA329'						 
		
	Case cAliasH == 'CEX'
		cModelo := 'TAFA350'								

EndCase
                   
If aDet == Nil
	aDet := {}
EndIf	
	
oModel := FWLoadModel( cModelo )
// 3 – Inclusão / 4 – Alteração / 5 - Exclusão
oModel:SetOperation ( nOper )
oModel:Activate()
oAux    := oModel:GetModel( 'MODEL_' + cAliasH )

For nI := 1 To Len( aCab )
	oModel:SetValue( 'MODEL_' + cAliasH , aCab[nI][1], aCab[nI][2] )
Next nI   


/*
	**	Itens do cabeçalho
*/                        
If lRet .And. Len( aDet ) > 0
	// Instanciamos apenas a parte do modelo referente aos dados do item
	oAux     := oModel:GetModel( 'MODEL_' + cAliasD )
	nItErro  := 0
	
	For nI := 1 To Len( aDet )
		If nI > 1
			
			If  ( nItErro := oAux:AddLine() ) <> nI
				lRet    := .F.
				Exit
			EndIf
		EndIf
		
		For nJ := 1 To Len( aDet[nI] )
			
			lRet := oModel:SetValue( 'MODEL_' + cAliasD, aDet[nI][nJ][1], aDet[nI][nJ][2] )
		
			If !lRet
				Exit
			EndIf	
		Next

		If !lRet
			Exit
		EndIf
	Next
EndIf


If lRet
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
	EndIf
EndIf    


If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	aErro[ 6 ] := StrTran( aErro[ 6 ] , 'não foi preenchido', 'não foi preenchido ou invalido.' )
EndIf

Return( If( !lRet , 'Campo ' + aErro[ 4 ] + ' : ' + aErro[ 6 ] , '' ) )

/*              
Funcao..............: ValidaLayout
Autor...............: Leandro Brito
Data................: Agosto/2015
Objetivo............: Validar se os campos da planilha correspondem ao layout selecionado
*/
*------------------------------------------------*
Static Function ValidaLayout( cAlias , aFields )   
*------------------------------------------------*

Return( Ascan( aFields , { | x | Left( x ,3 ) == cAlias } ) > 0  )  

/*
Função...............: Exporta
Objetivo.............: Exportar Log de processamento para Excel
Autor................: Leandro Brito ( BRL Consulting )
Data.................: Julho/2015
*/        
*-----------------------------------* 
Static Function Exporta
*-----------------------------------*
Local oExcel, aAux     
Local cFile := GetTempPath() + 'log_' + DtoS( dDatabase ) + '.xml'


oExcel := FWMSEXCEL():New()
oExcel:AddWorkSheet("Log")
oExcel:AddTable ("Log","Log da Operacao")   

oExcel:AddColumn("Log","Log da Operacao","Linha",1,1,.F.)
oExcel:AddColumn("Log","Log da Operacao","Descricao",1,1,.F.)   

For i := 1 To Len( aDadosLog )
	oExcel:AddRow("Log","Log da Operacao",{ aDadosLog[ i ][ 1 ] , aDadosLog[ i ][ 2 ] } )
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

