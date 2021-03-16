#Include "Protheus.Ch" 
#Include "Topconn.Ch"

/*
Função.............: GTEST004
Autor..............: Leandro Diniz de Brito
Objetivo...........: Importar Xml e gerar Pré-Nota\Nota de Entrada
Cliente HLB........: Todos
Data...............: 31/10/2016
*/                             
*-------------------------* 
  User Function GTEST004
*-------------------------*
Local aArea      	:= GetArea()
Local chTitle    	:= "HLB BRASIL"

Local nRecSM0Bak	:= SM0->( Recno() )    
Local cFilBak  	 	:= cFilAnt 

Local chMsg      	:= "Importação XML - Nota\Pre-Nota de Entrada"
Local cTitle

Local cText     	:= "Este programa tem como objetivo importar nota fiscal de fornecedores em layout .xml ( Danfe ), gerando nota fiscal de entrada ou pré nota." +;
						"Os códigos de fornecedores,produtos e amarração produto x fornecedor ja devem estar previamente cadastrados no sistema."
Local bFinish    	:= { || .T. }

Local cResHead
Local i 

Local lNoFirst
Local aCoord   

Local dDtBkp 	:= dDataBase
Local cMsg 

Local oProcesss
Local nTpCtb 	

Local aFieldsCustom	:= { 'A5_P_TE' , 'A5_P_CONV' , 'A5_P_UN' }

Private aArqInt		:= {}

Private oWizard
Private oGetResult

Private oLbx 
Private oBrwPlan

Private cResult     := ""             
Private aFilEmp 	:= {}   

Private cDirXml     := ""     
Private cDirSrv 	:= "\FTP\"+cEmpAnt+""

Private cIdInt 		
Private aNotas 	:= {}                                            	

Begin Sequence
//RSB - 06/06/2017 - Estava apontado para uma pasta fixa HB / agora esta dinamico.
If !ExistDir( cDirSrv )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
EndIf	
                         	
If !AliasIndic( 'Z21' )
	MsgStop( 'Tabela Z21 não encontrada. Favor contatar a TI.' )
	Return
EndIf


/*
	* Verifica a existencia de todos campos customizados na base de dados
*/
cMsg := ""
SX3->( DbSetOrder( 2 ) )
For i := 1 To Len( aFieldsCustom )
	If SX3->( !DbSeek( PadR( aFieldsCustom[ i ] , Len( SX3->X3_CAMPO ) ) ) )
		If !Empty( cMsg )
			cMsg += ","
		EndIf
		cMsg += aFieldsCustom[ i ]
	EndIf
Next 

If !Empty( cMsg )
	EECView( 'Os seguintes campos não existem na base de dados.' + Chr( 13 ) + Chr( 10 ) + 'A rotina será abortada . Favor contatar a TI .' + Chr( 13 ) + Chr( 10 ) + 'Campos => ' + cMsg )
	Return 
EndIf

SM0->( DbSeek( cEmpAnt ) )
While SM0->( !Eof() .And. SM0->M0_CODIGO == cEmpAnt ) 

	Aadd( aFilEmp , { SM0->M0_CGC , SM0->M0_CODFIL , SM0->( Recno() ) } )	
	
	SM0->( DbSkip() )
EndDo 

SM0->( DbGoTo( nRecSM0Bak ) )

oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , { || .T. } , /*bFinish*/ ,/*lPanel*/, cResHead , /*bExecute*/ , lNoFirst , aCoord )
	
oWizard:NewPanel ( ""  , "" , { || .T. }/*bBack*/ , { || ValidaTela() .And.  MsgYesNo( 'Confirma processamento do xml de notas fiscais ?' ) .And. ( Processa( { || Import() } , 'Importando Xml...' ) , .T. ) } ,bFinish ,, { || TelaParam() } /*bExecute*/  )
oWizard:NewPanel ( "Resultado" , "Resultado do Processamento" , { || .T. }/*bBack*/ , { ||  .T.}  ,bFinish , .T. , { || ExibeLog() } /*bExecute*/  )
	
oWizard:Activate( .T. )

End Sequence

If ( cFilAnt <> cFilBak )
	cFilAnt	:= cFilBak
	SM0->( DbGoTo( nRecSM0Bak ) )
EndIf

DbSelectArea( 'Z21' )
SET FILTER TO

RestArea( aArea )
                     
Return

/*
Função...............: TelaParam
Objetivo.............: Tela de Parametros
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 31/10/2016
*/
*-----------------------------------------------*
Static Function TelaParam
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel ) 
Local oFont   := TFont():New( 'Arial' )    
Local oGet                                  
Local cText   := ""  
Local oSayText
                                           
oFont:nHeight 	:= 16
oFont:Bold		:= .T. 

@10 , 05 Say oSayText Var cText Size 200,10 Of oPanel Pixel Font oFont

@45 , 05 Say "Selecione o diretório:" Of oPanel Pixel
@45 , 60 MsGet oGet Var cDirXml When .F. Size 210 , 10 Of oPanel Pixel
@45 , 280 Button "..." Size 20,10 Action ( cDirXml := AllTrim( ChooseDir( @cText , oSayText ) ) , oGet:Refresh() ) Of oPanel Pixel

Return

/*
Função...............: Import
Objetivo.............: Leitura e Importação das notas fiscais XML\TXT Prestação de Serviços 
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 31/10/2016
*/
*-----------------------------------------------*
Static Function Import
*-----------------------------------------------*        
Local cXml
Local oXml

Local i   

Local cError
Local cWarning	

Local aNf
Local nItem

Local cNf
Local cSerie

Local aItensXml  
Local cMun

Local cCodMun
Local cUF    

Local cProduto
Local cChaveNfe

Local cErroItem
Local cItem

Local cCnpjForn
Local lGravaNF

Local cPartN
Local cTesEnt
                                                                       	
Local cDescProd
Local nFator 

Local cUnFor

Private cArquivo 
Private cCNPJ

		
aNotas := {}


cIdInt := GetSxeNum( 'Z21' , 'Z21_ID' )   
ConfirmSX8()
	
ProcRegua( Len( aArqInt ) )
	
For i := 1 To Len( aArqInt )
	
	cArquivo := aArqInt[ i ][ 1 ]
	
	IncProc( 'Lendo arquivo ' + cArquivo + ' .' )
	
	If !CpyT2S( cDirXml + aArqInt[ i ][ 1 ] , cDirSrv )
		GravaLog( "" , "" , cArquivo , 'Erro na copia do arquivo para o servidor.' , 'R' )
		Loop
	EndIf
	
	cError		:= ''
	cWarning	:= ''
	
	oXml := XmlParserFile( cDirSrv + "\" + cArquivo , "_", @cError, @cWarning )
	
	If !Empty( @cError )
		GravaLog( "" , "" , cArquivo , 'Erro na leitura do arquivo.' + cError, 'R' )
		Loop
	EndIf
	
	If ( XmlChildEx( oXml , '_NFEPROC' ) <> Nil )    
		oXml := oXml:_NFEPROC 
	EndIf
		
	
	If ( XmlChildEx( oXml , '_NFE' ) == Nil )    
		GravaLog( "" , "" , cArquivo , 'Estrutura XML nao encontrada .' , 'R' )
		Loop
	EndIf
	
	cNf 	:= StrZero( Val( oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT ) , 9 )
	cSerie	:= 	oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT

	cCNPJ := oXml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
	cCNPJ := PadR( cCNPJ , Len( SM0->M0_CGC ) )
	
	lGravaNF := .T. 
	
	nPosCGC := 0
	
	//nPosCGC := 1  //** Para Testes sem avaliar o cnpj da empresa Protheus
	
	If ( nPosCGC == 0 )
		If ( nPosCGC := Ascan( aFilEmp , { | x | x[ 1 ] == cCnpj } ) ) == 0
			GravaLog( cNf , cSerie , cArquivo , 'CNPJ do Destinatario (' + cCNPJ + ') nao encontrado para esta empresa.' , 'R' )
			lGravaNF := .F.
		EndIf
		
		If ( nPosCGC > 0 ) .And. ( cFilAnt <> aFilEmp[ nPosCGC ][ 2 ] )
			cFilAnt := aFilEmp[ nPosCGC ][ 2 ]
			SM0->( DbGoTo( aFilEmp[ nPosCGC ][ 3 ]  ) )
		EndIf
    EndIf
			
	cCnpjForn := oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
	cChaveNFe := SubStr( oXml:_NFE:_SIGNATURE:_SIGNEDINFO:_REFERENCE:_URI:TEXT , 5 )
	
	aItensXml := oXml:_NFE:_INFNFE:_DET 
	
	If ValType( aItensXml ) <> 'A'
		aItensXml := { aItensXml }
	EndIf

	aNf		:= {}
	
	
	If ( lGravaNF )
	
		SA2->( DbSetOrder( 3 ) )
		If SA2->( !DbSeek( xFilial() + cCnpjForn ) )
			If !CadFor( oXml , cSerie , cNF )
				lGravaNf := .F.
			EndIf
		EndIf		
		
	EndIf 
	
	If ( lGravaNF )
	
		SF1->( DbSetOrder( 1 ) )
		IF SF1->( DbSeek( xFilial( "SF1" ) + PadR( cNf , Tamsx3("F1_DOC")[1])+PadR( cSerie , Tamsx3( "F1_SERIE " )[ 1 ] ) + SA2->A2_COD + SA2->A2_LOJA ))
			GravaLog( cNF, cSerie , cArquivo , 'Nota Fiscal ja integrada anteriormente .' , 'R' )		
			lGravaNf := .F.
		EndIf	

	EndIf	
	
	SA5->( DbSetOrder( 14 ) ) //** A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
	
	cErroItem := ""
	For nItem := 1 To Len( aItensXml )

		cPartN 	:= PadR( aItensXml[ nItem ]:_PROD:_CPROD:TEXT , Len( SA5->A5_CODPRF ) )
		cItem 	:= StrZero( Val( aItensXml[ nItem ]:_NITEM:TEXT ) , Len( SD1->D1_ITEM ) )

		cProduto 	:= ""     
		cTesEnt 	:= ""	
		cDescProd	:= NoAcento( aItensXml[ nItem ]:_PROD:_XPROD:TEXT )
		nFator 		:= 1    
		cUnFor 		:= aItensXml[1]:_PROD:_UCOM:TEXT
		If ( nPosCGC > 0 )  .And. lGravaNf
			If SA2->( !Eof() ) .And. SA5->( !DbSeek( xFilial() + SA2->A2_COD + SA2->A2_LOJA + cPartN ) )
				
				/*
					* Tela para cadastrar amarração no momento da integração
				*/
				
				If !TelaSA5( SA2->A2_COD , SA2->A2_LOJA , cPartN , cDescProd , cUnFor )
					cErroItem += 'Nao informado amarração produto x fornecedor ' + Chr( 13 ) + Chr( 10 )
					lGravaNf := .F.
				Else
					cProduto 	:= SA5->A5_PRODUTO
					cTesEnt		:= SA5->A5_P_TE
					nFator 		:= SA5->A5_P_CONV
				EndIf
				//cErroItem += 'Item ' + cItem +  ' ( PN : ' + AllTrim( cPartN ) + ' ) : Nao encontrado amarração Produto x Fornecedor.' + Chr( 13 ) + Chr( 10 )         			
			Else
				cProduto 	:= SA5->A5_PRODUTO
				cTesEnt		:= SA5->A5_P_TE   
				nFator 		:= SA5->A5_P_CONV
			EndIf	
		EndIf
		
		If ( nFator == 0 )
			nFator := 1
		EndIf          
		
		Aadd( aNf , { ;
							cItem  ,;  // Seq. Item
							If( Empty( cProduto ) , cPartN , cProduto ) ,; // Cod. Produto
							cDescProd ,; // Descricao
							Val( aItensXml[ nItem ]:_PROD:_QCOM:TEXT )*nFator ,; // Quantidade
							Val( aItensXml[ nItem ]:_PROD:_VUNCOM:TEXT ) ,; // Valor Unitario
							Val( aItensXml[ nItem ]:_PROD:_VPROD:TEXT ) ,; // Valor Total
							cChaveNFe ,;   // Chave NFE
							cNf ,; // Numero NF
						 	cSerie,; // Serie NF
						    StoD( Left( StrTran( If( XmlChildEx( oXml:_NFE:_INFNFE:_IDE , '_DEMI' ) <> Nil , oXml:_NFE:_INFNFE:_IDE:_DEMI:TEXT , oXml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT ) , "-" , "" ) , 10 )),;  // Emissao
						  	cTesEnt ;
						} )
	Next
	
	If !Empty( cErroItem )
		GravaLog( cNf , cSerie , cArquivo , cErroItem , 'R' )			
	EndIf

	If Len( aNf ) > 0 
		Aadd( aNotas , { cNf , cSerie , aNf } )
		If lGravaNf 
			GravaNF( aNf )
		EndIf
	EndIf

Next

Return

/*
Função...............: ExibeLog
Objetivo.............: Exibe Log da operação
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 31/10/2016
*/
*-----------------------------------------------*
Static Function ExibeLog
*-----------------------------------------------*
Local oPanel  := oWizard:GetPanel( oWizard:nPanel )
Local oOK      := LoadBitmap( GetResources() , 'BR_VERDE' )
Local oNO      := LoadBitmap( GetResources() , 'BR_VERMELHO' )


DbSelectArea( 'Z21' )
SET FILTER TO Z21_ID = cIdInt .And. Z21_FILIAL  = xFilial( 'Z21' )

@04,05 Button 'Exportar Log' Size 50,10 Action( Exporta() ) Of oPanel Pixel
@04,65 Button 'Itens da NF' Size 50,10 Action( VerItens() ) Of oPanel Pixel

oScr := TScrollBox():New(oPanel,15,05,140,295,.T.,.T.,.T.)
oBrwPlan := MsSelBr():New( 15 , 05 , 450 , 140 ,,,, oScr ,,,,,,,,,,,,.F.,'Z21 ' , .T.,,.F.,,, )      
	
	
oBrwPlan:AddColumn( TCColumn():New( 'Status'   , { || If( Z21->Z21_STATUS = 'A' ,  oOK , oNO )  },,,,"CENTER"  ,,.T.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Arquivo'  , { || Z21->Z21_ARQ },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Nota'     , { || Z21->Z21_DOC },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Serie'    , { || Z21->Z21_SERIE },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
oBrwPlan:AddColumn( TCColumn():New( 'Mensagem' , { || AllTrim( MemoLine( Z21->Z21_LOG , 100 , 1 ) ) + If( MLCount( Z21->Z21_LOG , 100 ) > 1 , ' ...<< Duplo Clique >>' , "" )} ,,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )

	
oBrwPlan:GoTop()
oBrwPlan:Refresh()
oBrwPlan:BLDBLCLICK := { || EECView( Z21->Z21_LOG ) }

Return


/*
Função...............: Exporta
Objetivo.............: Exportar Log de processamento para Excel
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 31/10/2016
*/        
*-----------------------------------* 
Static Function Exporta
*-----------------------------------*
Local oExcel, aAux     
Local cFile := GetTempPath() + 'Log_NF_Xml_' + DtoS( dDatabase ) + StrTran( Time() , ':' , '' ) + '.xml'
Local i

oExcel := FWMSEXCEL():New()
oExcel:AddWorkSheet("Log")
oExcel:AddTable ("Log","Log da Operacao")   

oExcel:AddColumn("Log","Log da Operacao","Status",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Arquivo",1,1,.F.)
oExcel:AddColumn("Log","Log da Operacao","Nota",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Serie",1,1,.F.)    
oExcel:AddColumn("Log","Log da Operacao","Mensagem",1,1,.F.)    


Z21->( DbGoTop() )
While Z21->( !Eof() )
	oExcel:AddRow("Log","Log da Operacao",{ Z21->Z21_STATUS	 ,;
											Z21->Z21_ARQ ,;
											Z21->Z21_DOC ,;
											Z21->Z21_SERIE ,;
											Z21->Z21_LOG } )											
	Z21->( DbSkip() )
EndDo   
Z21->( DbGoTop() )

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
 
If Len( aArqInt ) == 0 
	MsgStop( 'Nao existem arquivos a processar no diretorio informado .' )
	Return( .F. )
EndIf

Return( .T. )


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
Static Function GravaNF( aDadosNF )
*----------------------------------------------*
Local i
Local aCab			:= {}

Local aItem	    	:= {} 
Local aAutoItens    := {}

Local aAutoCab		:= {}   

Local cForn
Local cLoja      

Local cNF
Local cSerie  

Local cLog    



Private lMSErroAuto 

/*
aDadosNF =>
	[ 1 ] = Seq. Item
	[ 2 ] = Cod. Produto 
	[ 3 ] = Descricao
	[ 4 ] = Quantidade
	[ 5 ] = Valor Unitario
	[ 6 ] = Valor Total
	[ 7 ] = Chave NFE
	[ 8 ] = Nota Fiscal
	[ 9 ] = Serie   
	[ 10 ] = Emissao
	[ 11 ] = TES 	
*/

cNF 	:= aDadosNF[ 1 ][ 8 ] 
cSerie 	:= aDadosNF[ 1 ][ 9 ]
                 
cForn  	:= SA2->A2_COD
cLoja	:= SA2->A2_LOJA

/* 
	* Gravação Nota Fiscal	
*/       

cEspecie := "NF-E"
aAdd( aAutoCab , { "F1_FILIAL"  , xFilial('SF2')	, Nil } )
aAdd( aAutoCab , { "F1_FORMUL"    , "N"				, Nil } )
aAdd( aAutoCab , { "F1_TIPO"    , "N"				, Nil } )
aAdd( aAutoCab , { "F1_DOC"     , cNf			   	, Nil } )
aAdd( aAutoCab , { "F1_SERIE"   , cSerie			, Nil } )
aAdd( aAutoCab , { "F1_FORNECE" , cForn				, Nil } )
aAdd( aAutoCab , { "F1_LOJA"    , cLoja				, Nil } )
aAdd( aAutoCab , { "F1_EMISSAO" , aDadosNf[ 1 ][ 10 ], Nil } ) 
aAdd( aAutoCab , { "F1_ESPECIE" , cEspecie			, Nil } ) 
aAdd( aAutoCab , { "F1_CHVNFE" , aDadosNf[ 1 ][ 7 ], Nil } )


For i := 1 To Len( aDadosNF )

	aItem := {}
	
	aAdd( aItem , { "D1_ITEM"    , aDadosNF[ i ][ 1 ]	, Nil } )
	aAdd( aItem , { "D1_FILIAL"  , xFilial('SD1')		, Nil } )
	aAdd( aItem , { "D1_DOC"     , cNf					, Nil } )
	aAdd( aItem , { "D1_SERIE"   , cSerie				, Nil } )
	aAdd( aItem , { "D1_EMISSAO" , aDadosNF[ i ][ 10 ]	, Nil } )	
	aAdd( aItem , { "D1_FORNECE" , cForn				, Nil } )
	aAdd( aItem , { "D1_LOJA"    , cLoja				, Nil } )
	aAdd( aItem , { "D1_COD"     , aDadosNF[ i ][ 2 ]			, Nil } )
	If !Empty( aDadosNF[ i ][ 11 ] )
		aAdd( aItem , { "D1_TESACLA" , aDadosNF[ i ][ 11 ]	, Nil } )
	EndIf
	aAdd( aItem , { "D1_QUANT"   , aDadosNF[ i ][ 4 ]	, Nil } )
	aAdd( aItem , { "D1_VUNIT"   , aDadosNF[ i ][ 5 ]	, Nil } )  
	aAdd( aItem , { "D1_TOTAL"   , Round( aDadosNF[ i ][ 4 ] * aDadosNF[ i ][ 5 ] , TamSX3( 'D1_TOTAL' )[ 2 ] ) /*aDadosNF[ i ][ 6 ]*/	, Nil } )

	aAdd( aAutoItens, aItem )

Next


lMsErroAuto := .F.
MsExecAuto( {|x,y,z| Mata140(x,y,z)}, aAutoCab, aAutoItens, 3)

If  lMsErroAuto 
	//MostraErro()
	cLog := MemoRead( NomeAutoLog() )	
	DisarmTransaction()
	GravaLog( cNF , cSerie , cArquivo , 'Erro na inclusao da nota Fiscal .' + Chr( 13 ) + Chr( 10 ) + cLog , 'R' )				
	
Else  
	GravaLog( cNF , cSerie , cArquivo , 'Nota Fiscal incluida com sucesso.' , 'A'  )	
EndIf	

Return   

/*
Função..............: GravaLog
Objetivo............: Gravar Log da Integracao
Autor...............: Leandro Diniz de Brito
Data................: 21/10/2016
*/                              
*--------------------------------------------------------------* 
Static Function GravaLog( cNF, cSerie , cArq , cLog , cStatus )                  
*--------------------------------------------------------------* 

If AliasInDic( 'Z21' )
	Z21->( RecLock( 'Z21' , .T. ) )
	Z21->Z21_FILIAL := xFilial( 'Z21' )
	Z21->Z21_ID 	:= cIdInt
	Z21->Z21_USER 	:= cUserName
	Z21->Z21_DATA	:= dDatabase
	Z21->Z21_HORA 	:= Left( Time() , 5 )
	Z21->Z21_ARQ	:= cArq
	Z21->Z21_DOC	:= cNF
	Z21->Z21_SERIE	:= cSerie
	Z21->Z21_LOG 	:= cLog
	Z21->Z21_STATUS	:= cStatus
	Z21->( MSunlock() ) 
EndIf

Return

/*
Funcao.........: ChooseDir
Objetivo.......: Selecionar arquivo .Xls a ser importado
Autor..........: Leandro Diniz de Brito
*/
*---------------------------------------------*
Static Function ChooseDir( cText , oSayText )
*---------------------------------------------*
Local cTitle        := "Selecione o diretorio"
Local cMask         := "Arquivos (*.xml) |*.xml"
Local nDefaultMask  := 1
Local cDefaultDir   := If( Empty( cText ) , "C:\" , cText ) 
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
Local cDir 			

/*
	* Retorna diretorio selecionado
*/ 
cDir := cGetFile( cMask , cTitle , nDefaultMask , "C:\" , .F. , nOptions , .F. )
cText := ""                                                                     
aArqInt := {}

If !Empty( cDir )
	aArqInt := Directory( cDir + "\*.xml" , )
	cText 	:= "Total de arquivos encontrados :" + AllTrim( Str( Len( aArqInt ) ) )
EndIf

oSayText:Refresh()

Return( cDir )

/*
Função...............: VerItens
Objetivo.............: Mostrar Itens da Nota Fiscal
Autor................: Leandro Brito ( BRL Consulting )
Data.................: 31/10/2016
*/        
*-----------------------------------* 
Static Function VerItens
*-----------------------------------*
Local oDlg
Local nPosNF  	:= Ascan( aNotas , { | x | AllTrim( x[ 1 ] ) == AllTrim( Z21->Z21_DOC) .And. AllTrim( x[ 2 ] ) == AllTrim( Z21->Z21_SERIE ) } )   

Local aItens	
Local oBrwItens  

Local oPanel  := oWizard:GetPanel( oWizard:nPanel )

/*
aNotas =>
	[ 1 ] = Seq. Item
	[ 2 ] = Cod. Produto 
	[ 3 ] = Descricao
	[ 4 ] = Quantidade
	[ 5 ] = Valor Unitario
	[ 6 ] = Valor Total
	[ 7 ] = Chave NFE
	[ 8 ] = Nota Fiscal
	[ 9 ] = Serie   
	[ 10 ] = Emissao
*/   

If ( nPosNF == 0 )
	Return
EndIf
                                                                                           
aItens	:= AClone( aNotas[ nPosNF ][ 3 ] )		                                   

Define MSDialog oDlg Title 'Itens da Nota Fiscal ' + Z21->Z21_DOC + ' - Serie ' + Z21->Z21_SERIE  From 1,1 To 400,600 Of oPanel Pixel

	oBrwItens := TWBrowse():New(,,,,,,, oDlg ,,,,,,,,,,,, .F. ,, .T. )
	oBrwItens:Align:= CONTROL_ALIGN_ALLCLIENT
		
	aItens := ASort( aItens  ,,, { | x , y | x[ 1 ] < y[ 1 ] } ) 
	oBrwItens:SetArray( aItens )
		
	oBrwItens:AddColumn( TCColumn():New( 'Seq.Item'    , { || aItens[oBrwItens:nAt,01] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwItens:AddColumn( TCColumn():New( 'Cod.Produto\Part Number'    , { || aItens[oBrwItens:nAt,02] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwItens:AddColumn( TCColumn():New( 'Descricao'    , { || aItens[oBrwItens:nAt,03] },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwItens:AddColumn( TCColumn():New( 'Quantidade'    , { || Transf( aItens[oBrwItens:nAt,04] , X3Picture( 'D2_QUANT' ) ) },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwItens:AddColumn( TCColumn():New( 'Valor Unitario'    , { || Transf( aItens[oBrwItens:nAt,05] , X3Picture( 'D2_PRCVEN' ) ) },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	oBrwItens:AddColumn( TCColumn():New( 'Valor Total'       , { || Transf( aItens[oBrwItens:nAt,06] , X3Picture( 'D2_TOTAL' ) ) },,,,"LEFT"  ,,.F.,.T.,,,,.F.,) )
	
		
	oBrwItens:GoTop()
	oBrwItens:Refresh()
	oBrwItens:bLDblClick := { || .T. }

Activate MSDialog oDlg Centered 


Return

/*
Função...........: TelaSA5
Objetivo.........: Cadastrar amarração Produto x Fornecedor 
*/
*---------------------------------------------------------------*
Static Function TelaSA5( cForn , cLoja , cPN , cDesc , cUnFor )      
*---------------------------------------------------------------*        
Local cProd 
Local cTes 

Local lRet 		:= .F.

Local bOk 		:= { || If( ValTelaSA5( cProd ) , ( lRet := .T. , oDlg:End() ) , ) } 
Local bCancel 	:= { || If( MsgYesNo( 'Confirma saída? A nota nao será integrada!' ) , ( lRet := .F. , oDlg:End() ) , )}

Local oDlg                             
Local oFont   := TFont():New( 'Arial' )   

Local nFator 	:= 1	        
Local cUnProd 	:= Space( 2 )  

Local oUn                  
Local oProd
Local bSeek	:= { || If( SB1->( DbSetOrder( 1 ) , DbSeek( xFilial( 'SB1' ) + cProd ) ) , ( cUnProd := SB1->B1_UM , oUn:Refresh() ) , ( cUnProd := "" , Alert( 'Produto Invalido' ) ,  .F. ) )} 

Local nRegSA2

oFont:nHeight 	:= 14
oFont:Bold		:= .T.  

If ( cProd == Nil )
	cProd		:= CriaVar( 'B1_COD' , .F. )
	cTes 		:= CriaVar( 'F4_CODIGO' , .F. )     
EndIf


Define MSDialog oDlg Title 'Amarração Produto x Fornecedor' From 1,1 To 230,400 Of oMainWnd Pixel

	@34,05 Say 'Fornecedor :'  + SA2->A2_COD + " - " + SA2->A2_NREDUZ  Size 300,10 Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	@46,05 Say 'Part-Number : '  + AllTrim( cPN ) + " - " + cDesc	Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	@58,05 Say 'Un.Med.Fornecedor : '  + AllTrim( cUnFor ) Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	
	@71,05 Say 'TES: '  Size 40,10 Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	@71,55 MSGet cTes F3( 'SF4' ) Valid( Empty( cTes ) .Or. ExistCpo( 'SF4' , cTes , 1 ) ) Size 40,10 Of oDlg Pixel  
	
	@84,05 Say 'Produto: '  Size 60,10 Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	@84,55 MSGet oProd Var cProd F3( 'SB1' ) Size 60,10 Of oDlg Pixel 			 
    oProd:bValid := bSeek
    
	@84,117 MSGet oUn Var cUnProd When .F.  Size 20,10 Of oDlg Pixel 			 	
	
	@97,06 Say 'Fator Conversao: '  Size 60,10 Of oDlg Pixel COLOR CLR_BLUE FONT oFont
	@97,55 MsGet nFator Valid Positivo( nFator ) Size 40,10 Picture '@E 99999.9999'  Of oDlg Pixel
	

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered  

If ( lRet )                                     
	
	SA5->( DbSetOrder( 14 ) ) //** A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
	If SA5->( !DbSeek( xFilial() + cForn + cLoja + cPN ) )
		nRegSA2 := SA2->( Recno() )
		SA5->( RecLock( 'SA5' , .T. ) )
		SA5->A5_FILIAL := xFilial( 'SA5' )
		SA5->A5_FORNECE := cForn  
		SA2->(DbSetOrder(1))
  		If SA2->( DbSeek( xFilial() + cForn + cLoja) )	
  			SA5->A5_NOMEFOR:=SA2->A2_NOME
  		EndIf	
		SA5->A5_LOJA	:= cLoja 
		SA5->A5_CODPRF 	:= cPN
		SA5->A5_PRODUTO	:= cProd  
		SA2->(DbSetOrder(1))
  		If Sb1->(DbSeek( xFilial() + cProd ) )	
  			SA5->A5_NOMPROD:=SB1->B1_DESC  			
  		EndIf			
		SA5->A5_P_TE	:= cTes  
		SA5->A5_P_CONV	:= If( nFator == 0  , 1 , nFator )
		SA5->A5_REFGRD 	:= AllTrim( Str( SA5->( Recno() ) ) )  //** Usado somente para nao dar erro na constraint ( SA50XX_UNQ )   
		SA5->A5_UNID	:= cUnFor
		SA5->( MSUnlock() ) 
		SA2->( DbGoTo( nRegSA2 ) )
	EndIf
EndIf

Return( lRet )                                              

/*
Função...........: ValTelaSA5
Objetivo.........: Validação ao execuatr o botão confirmar na rotina TelaSA5()
*/
*---------------------------------------------------------------------*
Static Function ValTelaSA5( cProd )
*---------------------------------------------------------------------* 
Local lRet := .T.  

Begin Sequence 

If Empty( cProd )
	MsgStop( 'Obrigatorio preencher codigo do Produto.' )
	lRet := .F.
	Break
EndIf

End Sequence

Return( lRet )       

/*
Função........: CadFor
Objetivo......: Cadastrar fornecedor via MSExecAuto
Autor.........: Leandro Diniz de Brito
Data..........: 09/12/2016
*/
*----------------------------------------------*
Static Function CadFor( oXml , cSerie , cNf )
*----------------------------------------------*
Local aCab			:= {}
Local cLog    

Local lRet		:= .T.
Local cNum		:= ""


Private lMSErroAuto  

SA2->( DbSetOrder( 1 ) , DbGoBottom() )

If SA2->( Bof() .Or. Eof() )
	cNum := PadL( '0' , Len( SA2->A2_COD ) ) 
Else
	cNum := SA2->A2_COD
EndIf 

cNum := Soma1( cNum )


aAdd( aCab , { "A2_COD"  , cNum	, Nil } )
aAdd( aCab , { "A2_LOJA"  , '01'	, Nil } )
aAdd( aCab , { "A2_NOME"    , NoAcento( oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT )				, Nil } )
aAdd( aCab , { "A2_NREDUZ"    , NoAcento( oXml:_NFE:_INFNFE:_EMIT:_XFANT:TEXT )				, Nil } )
aAdd( aCab , { "A2_TIPO"     , 'J'			   	, Nil } )
aAdd( aCab , { "A2_END"   , NoAcento( oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT ) + ", " + AllTrim( oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT )			, Nil } )
aAdd( aCab , { "A2_EST" , oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT				, Nil } )
aAdd( aCab , { "A2_BAIRRO" , NoAcento( oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT ), Nil } ) 
aAdd( aCab , { "A2_CEP" , oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT			, Nil } ) 
aAdd( aCab , { "A2_INCR" , oXml:_NFE:_INFNFE:_EMIT:_IE:TEXT			, Nil } )  

If XmlChildEx( oXml:_NFE:_INFNFE:_EMIT , "_IM" ) <> Nil 
	aAdd( aCab , { "A2_INCRM" , oXml:_NFE:_INFNFE:_EMIT:_IM:TEXT			, Nil } ) 
EndIf

aAdd( aCab , { "A2_CGC" , oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT, Nil } ) 
//aAdd( aCab , { "A2_NATUREZ" , "", Nil } )
aAdd( aCab , { "A2_COD_MUN" , SubStr(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT,3), Nil } )
//aAdd( aCab , { "A2_CONTA" , "", Nil } )
aAdd( aCab , { "A2_CODPAIS" , '01058', Nil } )
aAdd( aCab , { "A2_PAIS" , '105' , Nil } )


lMsErroAuto := .F.
MsExecAuto( { | x ,y | Mata020( x , y ) }, aCab , 3)

If  lMsErroAuto 

	cLog := MemoRead( NomeAutoLog() )	
	DisarmTransaction()
	GravaLog( cNF , cSerie , cArquivo , 'Erro na inclusao do Fornecedor .' + Chr( 13 ) + Chr( 10 ) + cLog , 'R' )				

	lRet := .F.

EndIf	

Return( lRet )   

