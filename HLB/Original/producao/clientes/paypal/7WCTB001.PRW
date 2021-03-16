#Include 'Protheus.Ch'
#Include 'TopConn.Ch'


/*
Fun��o........: 7WCTB001
Objetivo......: Integrar arquivo .csv contendo lan�amentos contabeis da PayPal
Data..........: 16/01/2015
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
*/

*------------------------------------*
User Function 7WCTB001
*------------------------------------*

//����������������������������������Ŀ
//�Defini��o do escopo das variaveis �
//������������������������������������

Local oDlg   
Local cFile   := Space( 300 )   

Local nOpc    := 0
Local bOk     := { || If( File( cFile ) , If( MsgYesNo( 'Confirma leitura da planilha ?' ) , ( nOpc := 1 , oDlg:End() ) ,) , MsgStop( "Arquivo invalido!" ) ) }

Local bCancel := { || oDlg:End() }
Local cTitle  := "Importa��o Planilha FBO "

Local cTexto  := "Este programa tem como objetivo importar a planilha FBO e efetuar a " + Chr( 13 ) + Chr( 10 ) + ;
                 "grava��o dos lan�amentos contabeis dia a dia ."
                                


Local cArqTemp    
Local cAliasTemp

Local lExec 

/*
** Posicao das principais colunas no arquivo .csv
*/

Private nPosConta := 1
Private nPosData  := 6

Private nPosCC    := 10
Private nPosItemC := 11

Private nPosTpCt  := 8

Private nPosValor := 23
Private nPosHist  := 9

Private oFont   := TFont():New( 'Arial' )
Private aTotDia    := {}

Private cLoteFBO := PadR( '000001' , TamSx3( "CT2_LOTE" )[ 1 ] )
Private oProcess 

oFont:nHeight := 16 ; oFont:nWidth := 08

/*
   ** Estrutura do arquivo .csv ** 
   
   1 - Account;
   2 - Col2;
   3 - Company Code;
   4 - Assigment Number;
   5 - Year/Month;
   6 - Post. Date; ( YYYYMMDD )
   7 - Col6;
   8 - Debit/Credit;
   9 - Description;
   10 - Cost Center;
   11 - Profit Center;
   12 - Local Currency;
   13 - Assigment Number_1;
   14 - Col13;
   15 - Col14;
   16 - YEAR;
   17 - Col16;
   18 - Col17;
   19 - Transaction Type;
   20 - Col19;
   21 - Pstng. Date;
   22 - User Name; 
   23 - Local Currency Amount
*/


//�����������������������������������������
//�Inicializa tela para selecionar arquivo.�
//�����������������������������������������

Define MSDialog oDlg Title cTitle From 1 , 1 To 300 , 550 Of oMainWnd Pixel

   oPanel := TPanel():New( ,,, oDlg )      
   oPanel:Align := CONTROL_ALIGN_ALLCLIENT
   
   TGroup():New( 02 , 02 , 134 , 274 , "" , oPanel ,,, .T. )

   @12 , 05 Say oTexto Var cTexto Of oPanel Pixel FONT oFont Size 400 , 40  
   
   @60 , 05 Say "Selecione o arquivo:" Of oPanel Pixel 
   @70 , 05 MsGet oGet Var cFile Size 255 , 10 Of oPanel Pixel
   @70 , 260 Button "..." Size 10,10 Action ( cFile := AllTrim( ChooseFile() ) , oGet:Refresh() ) Of oPanel Pixel

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered    

	If ( nOpc == 1 )     

		cArqTemp   := CriaTrab( , .F. ) 
		cAliasTemp := GetNextAlias()

		//�����������������������Ŀ
		//�INICIO DO PROCESSAMENTO�
		//�������������������������
		Processa( { || lExec := CpyT2S( cFile , GetSrvProfString( "StartPath" , "" ) ) } , "Copiando planilha para o servidor..." )
            
		If !lExec 
			MsgStop( 'Erro na c�pia da planilha para o servidor.' )
			Return
		Endif
		//cFile := GetSrvProfString( "StartPath" , "" ) + RetFileName( cFile ) + ".csv"
		cFile := GetSrvProfString( "StartPath" , "" ) + SubStr( cFile , RAt( "\" , cFile ) + 1 )  
		
		Processa( { || lExec := ReadCSV( cFile , cArqTemp , cAliasTemp ) } , "Lendo Planilha..." )        
      
		If lExec
			oProcess := MsNewProcess():New( { || GravaCT2( cAliasTemp ) } , "Gravando Lancamentos" , "" )  
			oProcess:Activate()            
		EndIf
      
		If Select( cAliasTemp ) > 0 
			( cAliasTemp )->( DbCloseArea() )
			E_EraseArq( cArqTemp )
		EndIf
   
	EndIf

Return
                     
/*
Funcao.........: ChooseFile
Objetivo.......: Selecionar arquivo .Xls a ser importado
Autor..........: Leandro Diniz de Brito
*/
*-----------------------------------------*
Static Function ChooseFile
*-----------------------------------------*
Local cTitle        := "Selecione o arquivo"
Local cMask         := "Arquivos CSV (*.csv) |*.csv"
Local nDefaultMask  := 0
Local cDefaultDir   := "C:\"
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE

//��������������������������������������Ŀ
//�Retorna caminho e arquivo selecionado.�
//����������������������������������������
Return( PadR( cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions ) , 300 ) )

/*
Funcao.........: ReadCSV
Objetivo.......: Ler planilha no formato .csv e fazer critica no arquivo
Autor..........: Leandro Diniz de Brito
Data...........: 01/2015
*/
*-------------------------------------------------------*
Static Function ReadCSV( cFile , cArqTemp , cAliasTemp )
*-------------------------------------------------------*
Local lPlanOk       := .T.
Local aFieldsTmp := {}

Local aLinha   

Local nTotalDeb  := 0
Local nTotalCred := 0  

Local nValor
Local nPos

Local oOK      := LoadBitmap( GetResources() , 'BR_VERDE' )
Local oNO      := LoadBitmap( GetResources() , 'BR_VERMELHO' )

Local 	cCC    
Local  cItemC 	

Local	cConta  
Local 	nLenCC   := Len( CTT->CTT_CUSTO )

Local  nLenItemC  := Len( CTD->CTD_ITEM )
Local	nLenConta1  := Len( CT1->CT1_P_CONT )

Local  nLenConta2  := Len( CT1->CT1_CONTA )
Local  oLbx

Local nLinha, i 
Local aButtons     // := { { "HISTORIC" , { || SaveLog() } , "Salvar Log"  } }


Aadd( aFieldsTmp  , { 'CONTA1'    , 'C' , nLenConta1 , 0 } )
Aadd( aFieldsTmp  , { 'CONTA2'    , 'C' , nLenConta2 , 0 } )
Aadd( aFieldsTmp  , { 'TPLANC'   , 'C' , 1                      , 0 } )
Aadd( aFieldsTmp  , { 'DATALANC' , 'C' , 8                      , 0 } )
Aadd( aFieldsTmp  , { 'CC'       , 'C' , nLenCC  , 0 } )
Aadd( aFieldsTmp  , { 'ITEMC'    , 'C' , nLenItemC   , 0 } )
Aadd( aFieldsTmp  , { 'HIST'     , 'C' , Len( CT2->CT2_HIST )   , 0 } )
Aadd( aFieldsTmp  , { 'VALOR'    , 'N' , TamSX3( 'CT2_VALOR' )[ 1 ] , TamSX3( 'CT2_VALOR' )[ 2 ] } )


DbCreate( cArqTemp+'.dbf'  , aFieldsTmp ) 
dbUseArea( .T. ,, cArqTemp+'.dbf'  ,cAliasTemp , .T. , .F. )
IndRegua( cAliasTemp , cArqTemp + OrdBagExt() , "DATALANC+TPLANC" ) 

CTT->( DbSetOrder( 1 ) ) 
CTD->( DbSetOrder( 1 ) )
CT1->( DbOrderNickName( 'PCONT' ) ) //** CT1_FILIAL + CT1_P_CONT

Ft_Fuse( cFile )

ProcRegua( FT_FLastRec() )

Ft_FGotop()
Ft_FSkip() //** Pula Linha Cabe�alho

nTotalDeb  := 0
nTotalCred := 0
nLinha := 0
While !Ft_FEof()

	nLinha ++
	cLinha := StrZero( nLinha , 10 , 0 )
	
	IncProc()
	
	aLinha := Separa( Ft_FReadLn(), ";" )
	
	If Len( aLinha ) == 0 
		Ft_FSkip() 
   		Loop	
	EndIf
	
	cCC    := PadR( aLinha[ nPosCC ] , nLenCC )
	cItemC := PadR( aLinha[ nPosItemC ] , nLenItemC )	
	cConta1  := PadR( aLinha[ nPosConta ] , nLenConta1 )
	
	
	lCredito := (  aLinha[ nPosTpCt ] == 'H'  )

	nValor   := StrTran( aLinha[ nPosValor ] , "(" , "" )
	nValor   := StrTran( nValor , ")" , "" )	
	nValor   := StrTran( nValor , "." , "" )	
	nValor   := StrTran( nValor , "," , "." )
	nValor   := Round( Val( nValor ) , 2 )
	
	If ( nValor == 0 ) 
		Ft_FSkip() 
   		Loop
    EndIf 	
	
	If lCredito   //** Credito  
   		nValor := Abs( nValor )
   		nTotalCred += nValor
	Else
		nTotalDeb += nValor
	EndIf    
	
	If ( nPos := Ascan( aTotDia , { | x | x[ 1 ] == aLinha[ nPosData ] } ) ) == 0
		Aadd( aTotDia , { aLinha[ nPosData ] , If( !lCredito , nValor , 0 ) , If( lCredito , nValor , 0 ) , '' ,, 1 } )
		nPos := Len( aTotDia )
	Else
		aTotDia[ nPos ][ 2 ] += If( !lCredito , nValor , 0 )  //** Total Debito do Dia
		aTotDia[ nPos ][ 3 ] += If( lCredito , nValor , 0 )  //** Total Credito do Dia	
		aTotDia[ nPos ][ 6 ] += 1	
	EndIf
   
	If Empty( cConta1 ) .And. At( 'Linha sem conta informada' , aTotDia[ nPos ][ 4 ] ) == 0
		aTotDia[ nPos ][ 4 ] += "-Linha sem conta informada." + Chr( 13 ) + Chr( 10 )
	ElseIf !CT1->( DbSeek( xFilial() + cConta1 ) ) .And. At( cConta1 , aTotDia[ nPos ][ 4 ] ) == 0  
		aTotDia[ nPos ][ 4 ] += "-Conta " + cConta1 + " sem de/para no plano de contas."  + Chr( 13 ) + Chr( 10 )
	EndIf 
	
	If !Empty( cItemC ) .And. CTD->( !DbSeek( xFilial() + cItemC ) ) .And. At( cItemC , aTotDia[ nPos ][ 4 ] ) == 0  
		aTotDia[ nPos ][ 4 ] += "-Item Contabil " + cItemC + " sem cadastro." + Chr( 13 ) + Chr( 10 )
	EndIf 	
	
	If !Empty( cCC ) .And. CTT->( !DbSeek( xFilial() + cCC ) ) .And. At( cCC , aTotDia[ nPos ][ 4 ] ) == 0  
		aTotDia[ nPos ][ 4 ] += "-Centro de Custo " + cCC + " sem cadastro." + Chr( 13 ) + Chr( 10 )
	EndIf
	
	If !Empty( cConta1 ) .And. CT1->( Dbseek( xFilial() + cConta1 ) ) 
	
		If Empty( cCC ) .And. ( CT1->CT1_CCOBRG == '1' ) .And. At( "Centro de custo nao informado e conta contabil "+ cConta1 + " exige centro de custo" , aTotDia[ nPos ][ 4 ] ) == 0
			aTotDia[ nPos ][ 4 ] += "-Centro de custo nao informado e conta contabil "+ cConta1 + " exige centro de custo." + Chr( 13 ) + Chr( 10 )
		EndIf
		
		If Empty( cItemC ) .And. ( CT1->CT1_ITOBRG == '1' ) .And. At( "Item Conta nao informado e conta contabil " + cConta1 + " exige item conta" , aTotDia[ nPos ][ 4 ] ) == 0
			aTotDia[ nPos ][ 4 ] += "-Item Conta nao informado e conta contabil " + cConta1 + " exige item conta ." + Chr( 13 ) + Chr( 10 )
		EndIf		
	
	EndIf 		

   ( cAliasTemp )->( DbAppend() )
   ( cAliasTemp )->CONTA1 := aLinha[ nPosConta ] 	      	
   ( cAliasTemp )->CONTA2 := If( CT1->( !Eof() ) , CT1->CT1_CONTA , '' )
   ( cAliasTemp )->TPLANC := If( lCredito  , '2' , '1' )
   ( cAliasTemp )->DATALANC := aLinha[ nPosData ]
   ( cAliasTemp )->CC := aLinha[ nPosCC ]
   ( cAliasTemp )->ITEMC := aLinha[ nPosItemC ]
   ( cAliasTemp )->HIST  := If( Empty( aLinha[ nPosHist ] ) , 'Lancamento Contabil Automatico'  , NoAcento( aLinha[ nPosHist ] ) )
   ( cAliasTemp )->VALOR := nValor   

	Ft_FSkip()
	
EndDo


Asort( aTotDia ,,, { | x , y | x[ 1 ] < y[ 1 ] } ) 

nTotalDeb  := Round( nTotalDeb  , 2 ) 
nTotalCred := Round( nTotalCred , 2 )


/*
** Valida se ja existem lan�amentos FBO para cada dia
*/
CT2->( DbSetOrder( 1 ) )

For i := 1 To Len( aTotDia )
	CT2->( DbSeek( xFilial() + aTotDia[ i ][ 1 ] + cLoteFBO ) )
   
	While CT2->( !Eof() .And. CT2_FILIAL + DtoS( CT2_DATA ) + CT2_LOTE == xFilial( 'CT2' ) + aTotDia[ i ][ 1 ] + cLoteFBO )

		If AllTrim( CT2->CT2_ORIGEM ) == "FBO"     
			aTotDia[ i ][ 4 ] += "-Ja existe lancamento contabil planilha FBO para o dia " + DtoC( StoD( aTotDia[ i ][ 1 ] ) ) + Chr( 13 ) + Chr( 10 )
			Exit
		EndIf
		
		CT2->( DbSkip() )   
	EndDo 

Next 

AEval( aTotDia , { | x |  x[ 5 ] := Empty( x[ 4 ] ) } )

Ft_Fuse()

If File( cFile )
	FErase( cFile )   
EndIf

oMainWnd:CoorsUpdate()
                                    
Define MsDialog oDlg Title 'Integra��o Contabil - Planilha FBO ' ;
                     From oMainWnd:nTop + 075 , oMainWnd:nLeft + 75 To oMainWnd:nBottom - 60 , oMainWnd:nRight - 200 Of oMainWnd Pixel
      
   aPos := { 20 , 1 , oDlg:nHeight / 2 , oDlg:nWidth / 2 }
   
   @05,10 Say 'Total Credito: ' + Transf( nTotalCred , "@E 999,999,999,999,999.99" ) FONT oFont Size 150 , 15 Of oDlg Pixel  
   @25,10 Say 'Total Debito: ' + Transf( nTotalDeb , "@E 999,999,999,999,999.99" )    FONT oFont Size 150 , 15 Of oDlg Pixel
   
   @05,150 Say 'Nome do arquivo: ' + RetFileName( cFile ) FONT oFont Size 150 , 15 Of oDlg Pixel
   
   @22,150 Button 'Ver Mensagem'  Size 80 , 12 Of oDlg Pixel Action EECView( aTotDia[ oLbx:nAt , 4 ] )   
   @22,250 Button 'Exportar Mensagens'  Size 80 , 12 Of oDlg Pixel Action Eval( { || SaveLog() } )   
      
   oLbx := TWBrowse():New( aPos[ 1 ] + 15 ,aPos[ 2 ] , aPos[ 4 ] , aPos[ 3 ] - 50 ,, { 'Status', 'Data', 'Total Debito', 'Total Credito', 'Mensagem ( Duplo Clique )' } ,, oDlg ,,,,,,,,,,,, .F. ,, .T. )

   oLbx:SetArray( aTotDia )
   oLbx:bLine := { || { If( aTotDia[ oLbx:nAt , 5 ],  oOK , oNO ),;
                           StoD( aTotDia[ oLbx:nAt , 1 ] ) ,;
                           Transf( aTotDia[ oLbx:nAt , 2 ] , "@E 999,999,999,999.99" ) ,;
                           Transf( aTotDia[ oLbx:nAt , 3 ] , "@E 999,999,999,999.99" ) ,;
                           MemoLine( aTotDia[ oLbx:nAt , 4 ] , 50 , 1 ) + If( !Empty( aTotDia[ oLbx:nAt , 4 ] ) , "<< Ver botao Mensagens >>" , "" ) ;
                         } ;
                       }
   oLbx:GoTop()
   oLbx:Refresh()
   oLbx:bLDblClick := { || If( Empty( aTotDia[ oLbx:nAt ][ 4 ] ) , ( aTotDia[ oLbx:nAt ][ 5 ] := !aTotDia[ oLbx:nAt ][ 5 ] ) , ) }

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , ;
                                               { || lPlanOk := ( Ascan( aTotDia , { | x | x[ 5 ] } ) > 0 ) ,;
                                               	  If( lPlanOk .And. MsgYesNo( 'Confirma grava��o ?' ) , oDlg:End() , ) } ,;
                                               { || lPlanOk := .F. , oDlg:End() } ,,;
                                               aButtons  ) Centered


Return( lPlanOk )

/*
Funcao.........: GravaCT2
Objetivo.......: Efetivar lan�amento contabil via MSExecAuto
Autor..........: Leandro Diniz de Brito
Data...........: 01/2015 
*/
*-----------------------------------------*
Static Function GravaCT2( cAliasTemp )
*-----------------------------------------*
Local cDataLanc
Local aCab

Local aItem
Local aItens

Local cLinha
Local i 

Private lMsErroAuto
		

ProcRegua( ( cAliasTemp )->( LastRec() ) )

( cAliasTemp )->( DbGoTop() )
			
ConOut( 'Inicio Integracao FBO ' + Time() )

oProcess:SetRegua1( Len( aTotDia ) )

For i := 1 To Len( aTotDia )
   
   If !aTotDia[ i ][ 5 ]
      Loop
   EndIf
   
   oProcess:IncRegua1( 'Processando dia ' + DtoC( StoD( aTotDia[ i ][ 1 ] ) ) )
   
   ( cAliasTemp )->( DbSeek( aTotDia[ i ][ 1 ] ) )
      
   IncProc() 
   
   cDataLanc := ( cAliasTemp )->DATALANC

	aCab := {;
			{ "dDataLanc" , StoD( cDataLanc ) , NIL },;
			{ "cLote"	  , cLoteFBO , NIL } ,;
			{ "cSubLote"  , Padr( 'FBO' , TamSx3( "CT2_SBLOTE" )[ 1 ] ) , NIL };
			}  
   aItens := {}
   cLinha := StrZero( 0 , Len( CT2->CT2_LINHA ) )   

   oProcess:SetRegua2( aTotDia[ i ][ 6 ] ) 
   While ( cAliasTemp )->( !Eof() .And. DATALANC == cDataLanc ) 
   
		oProcess:IncRegua2()
		aItem := {}
		cLinha := Soma1( cLinha )		
		Aadd( aItem , { 'CT2_DC', ( cAliasTemp )->TPLANC , Nil } )
		Aadd( aItem , { 'CT2_TPSALD', '1', Nil } )
		Aadd( aItem ,{ 'CT2_MANUAL', '1', Nil } )
		Aadd( aItem ,{ 'CT2_ORIGEM', 'FBO', Nil } )
		Aadd( aItem ,{ 'CT2_AGLUT', '2', Nil } )
		Aadd( aItem ,{ 'CT2_P_GER', 'S', Nil } )                 
		Aadd( aItem ,{ 'CT2_MOEDLC', '01', Nil } )                 
		Aadd( aItem ,{ 'CT2_CTLSLD', '0', Nil } )
		Aadd( aItem ,{ 'CT2_LINHA', cLinha , Nil } )		
                 
		If ( ( cAliasTemp )->TPLANC == '1' )

			Aadd( aItem ,{ 'CT2_DEBITO', ( cAliasTemp )->CONTA2 , Nil } )
			If !Empty( ( cAliasTemp )->ITEMC )
			   Aadd( aItem ,{ 'CT2_ITEMD', ( cAliasTemp )->ITEMC , Nil } )
			EndIf

			If !Empty( ( cAliasTemp )->CC )    
				Aadd( aItem ,{ 'CT2_CCD', ( cAliasTemp )->CC , Nil } )
			EndIf	

		Else
			Aadd( aItem ,{ 'CT2_CREDIT', ( cAliasTemp )->CONTA2 , Nil } )	

			If !Empty( ( cAliasTemp )->CC )
				Aadd( aItem ,{ 'CT2_CCC', ( cAliasTemp )->CC , Nil } )
			EndIf

			If !Empty( ( cAliasTemp )->ITEMC ) 		
				Aadd( aItem ,{ 'CT2_ITEMC', ( cAliasTemp )->ITEMC , Nil } )
			EndIf	

		EndIf
                 
		Aadd( aItem ,{ 'CT2_HIST', ( cAliasTemp )->HIST , Nil } )                                                   
		Aadd( aItem ,{ 'CT2_VALOR', ( cAliasTemp )->VALOR , Nil } )
                
		Aadd( aItens , AClone( aItem ) )
                                 
      ( cAliasTemp )->( DbSkip() )
   
   EndDo   
   
 
	lMsErroAuto := .F. 
	Begin Transaction
		MSExecAuto( { | x , y , z | Ctba102( x , y , z ) } , aCab , aItens , 3 )
	End Transaction 
   
   If lMsErroAuto 
      MostraErro()
      MsgInfo( 'Ocorreram erros na efetiva��o do lan�amento, o processo ser� abortado.' )
      Exit
   EndIf
      

Next

ConOut( 'Fim Integracao FBO ' + Time() )

Return

/*
Funcao.........: SaveLog
Objetivo.......: Salvar Log de criticas 
Autor..........: Leandro Diniz de Brito
Data...........: 01/2015 
*/
*-----------------------------------------*
Static Function SaveLog
*-----------------------------------------*
Local oExcel
Local cFile  := AllTrim( GetTempPath() ) 

Local nHFile  := FCreate( cFile )
Local i

Local cBuffer := '' 


If Right( cFile , 1 ) <> "\"
	cFile += "\"
EndIf

cFile += CriaTrab( , .F. ) + '.csv'
nHFile  := FCreate( cFile )

If FError() <> 0
	MsgInfo( 'Erro na cria��o do arquivo de log.' )
	Return
EndIf

FWrite( nHFile , '*** Log Integracao Planilha FBO ***' + CRLF  )
FWrite( nHFile , 'Data do Log : ' + DtoC( dDataBase ) + CRLF + CRLF )
FWrite( nHFile , 'Mensagem' + CRLF  )

AEval( aTotDia , { | x | If( !Empty( x[ 4 ] ) .And. At( x[ 4 ] , cBuffer ) == 0 , cBuffer += x[ 4 ] , ) } )  
FWrite( nHFile , cBuffer )
FClose( nHFile )


oExcel:=MsExcel():New()
oExcel:WorkBooks:Open( cFile )  
oExcel:SetVisible(.T.)

Return