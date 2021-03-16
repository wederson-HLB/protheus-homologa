#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.................: GTCTB006
Objetivo...............: Manutenção De\Para Plano de Contas x Plano de Contas Referencial
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 05/06/2015
Observações............:
*/
*----------------------------------*
User Function GTCTB006
*----------------------------------*
Local oDlg
Local oDlg2

Local nOption  := 0
Local bOk      := { || If( oNewGetDados:TudoOK() .And. MsgYesNo( 'Confirma gravação?' ) , ( nOption := 1 , oDlg:End() ) , ) }

Local bCancel  := { || nOption := 0 , oDlg:End() }
Local oNewGetDados

Local nStyle
Local aAlter      := { "CVD_CTAREF" , "CVD_ENTREF" , "CVD_CUSTO" , "CVD_TPUTIL" , "CVD_CLASSE" , "CVD_NATCTA" , "CVD_CTASUP" }

Local oGetConta
Local oFont1  := TFont():New( 'Courier New' ,, -16 , .T. )

Local oSay1
Local cDescCta

Local aSizeDlg		:= MsAdvSize()
Local nOpcTela

Local aBotoes   	:= { { "VERNOTA" , { || oDlg2:End() , nOpcTela := 1 , lExclui := .T. } , "Exclui De\Para" } }
Local aBotoes2   	:= { { "VERNOTA" , { || Processa( { || ImportaXLS( oNewGetDados ) } , 'Importando Dados da planilha Excel ...' ) } , "Importa XLS" } , { "VERNOTA" , { || Processa( { || ExportaXLS() } , 'Exportando Dados para Excel ...' )  } , "Exporta XLS" } }

Private aYesFields  := { "CVD_CONTA" , "CT1_DESC01" , "CVD_CODPLA" , "CVD_CTAREF" , "CVD_ENTREF" , "CVN_DSCCTA" ,  "CVD_CUSTO" , "CVD_TPUTIL" , "CVD_CLASSE" , "CVD_NATCTA" , "CVD_CTASUP" }
Private cCvdCodPla  := Space( Len( CVN->CVN_CODPLA ) )
Private aCols := {}

Private aHeader  := {}
Private lExclui := .F.

oFont1:Bold := .T.

nOpcTela := 0
Define MsDialog oDlg2 Title 'Plano Referencial' From 1,1 To 120,300 Of oMainWnd Pixel

@10+22,05 Say 'Plano Referencial' Size 70,10 Of oDlg2 Pixel
@10+22,80 MsGet cCvdCodPla Size 40,10 Of oDlg2 F3( 'CVN1' ) /*Valid ( ExistCpo( 'CVN' , cCvdCodPla , 1 ) )*/ Pixel

Activate MSDialog oDlg2 On Init EnchoiceBar( oDlg2 , { || nOpcTela := 1 , oDlg2:End() } , { || nOpcTela := 0 , oDlg2:End() } ,, aBotoes ) Centered


If ( nOpcTela == 0 )
	Return
EndIf

nStyle   := If( !lExclui , /*GD_INSERT +*/ GD_UPDATE + GD_DELETE , 0 )

MsgRun( 'Aguarde... Carregando plano referencial ...' , '' , { || LoadAcols() } )

aSort( aCols ,,, { | x , y | x[ 1 ] < y[ 1 ]  } )

Define MSDialog oDlg Title 'Amarração Plano de Contas x Plano Referencial - ' + If( lExclui , 'EXCLUSAO' , 'MANUTENCAO' ) From aSizeDlg[ 7 ] , aSizeDlg[ 1 ] TO aSizeDlg[ 6 ] , aSizeDlg[ 5 ] Of oMainWnd Pixel

oNewGetDados := MsNewGetDados():New( 0, 0, 0, 0, nStyle, 'u_Gt006lok' , /*cTudoOk*/, /*cIniCpos*/, aAlter /*aAlter*/, /*nFreeze*/ , /*nMax*/, 'u_Gt006FOk()' , /*cSuperDel*/, /*cDelOk*/, oDlg , aHeader, aCols , /*uChange]*/, /*cTela*/ )
oNewGetDados:ForceRefresh()
oNewGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ,, aBotoes2  ) Centered

If ( nOption == 1 )
	Processa( { || GravaCols( 'CVD' , oNewGetDados:aCols , oNewGetDados:aHeader ) } , 'Gravando tabela De\Para' ) 
EndIf


Return

/*
Função........: GravaCols
Objetivo......: Função generica para gravar acols criado pela função FillGetDados em uma tabela
Autor.........: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..........: 05/06/2015
*/
*---------------------------------------------------------------------------*
Static Function GravaCols( cAlias , aColsPar , aHeaderPar )
*---------------------------------------------------------------------------*
Local i,j
Local nRecno
Local lLock

Local nPosCta 	:= GDFieldPos( 'CVD_CONTA' )
Local nPosCtRef := GDFieldPos( 'CVD_CTAREF' ) 
Local nPosEnt   := GDFieldPos( 'CVD_ENTREF' ) 

CVD->( DbSetOrder( 1 ) )    // CVD_FILIAL+CVD_CONTA+CVD_ENTREF+CVD_CTAREF+CVD_CUSTO  

ProcRegua( Len( aColsPar ) )                                                                                                          

Begin Transaction

DbSelectArea( cAlias )
For i := 1 To Len( aColsPar )
	
	IncProc()
	nRecno := GDFieldGet( cAlias + '_REC_WT' , i ,, aHeaderPar , aColsPar )
	
	If Empty( aColsPar[ i ][ nPosCta ] ) .Or. Empty( aColsPar[ i ][ nPosCtRef ] )
		
		If ( nRecno ) > 0
			DbGoto( nRecno )
			RecLock( cAlias , .F. )
			DbDelete()
			MSUnlock()
		EndIf
		
		Loop
		
	EndIf
	
	lLock := .F.
	
	
	If CVD->( DbSeek( xFilial() + aColsPar[ i ][ nPosCta ] + aColsPar[ i ][ nPosEnt ] + aColsPar[ i ][ nPosCtRef ] ) )
		RecLock( cAlias , .F. )
		lLock := .T.
		If aColsPar[ i ][ Len( aHeaderPar ) + 1 ] .Or. ( lExclui )
			DbDelete()
			MSUnlock()
			Loop
		EndIf
			 
	ElseIf ( nRecno > 0 ) 
		DbGoto( nRecno )
		RecLock( cAlias , .F. )
		lLock := .T.
		If aColsPar[ i ][ Len( aHeaderPar ) + 1 ] .Or. ( lExclui )
			DbDelete()
			MSUnlock()
			Loop
		EndIf
	ElseIf !aColsPar[ i ][ Len( aHeaderPar ) + 1 ]
		RecLock( cAlias , .T. )
		lLock := .T.
	EndIf
	
	
	If ( lLock )
		
		Eval( FieldBlock( cAlias + '_FILIAL' ) , xFilial( cAlias ) )
		For j:=1 To Len( aHeaderPar )
			If ( aHeaderPar[ j ][ 10 ] ) <> 'V'
				Eval( FieldBlock( aHeaderPar[ j ][ 2 ] ) , aColsPar[ i ][ j ] )
			EndIf
		Next
		
		MSUnlock()
	EndIf
	
Next

End Transaction

Return

*--------------------------------------------*
User Function Gt006LOk
*--------------------------------------------*

If Empty( aCols[ n ][ GDFieldPos( 'CVD_CONTA' ) ] )
	MsgStop( 'Conta nao informada.' )
	Return( .F. )
EndIf


Return( .T. )

/*
Função.................: Gt006FOk
Objetivo...............: Validacao de campo no grid de dados
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 05/06/2015
Observações............:
*/
*--------------------------------------------*
User Function Gt006FOk
*--------------------------------------------*
Local cField := AllTrim( SubStr( ReadVar() , 4 ) )

If cField == 'CVD_CONTA'
	
	If Empty( M->CVD_CONTA )
		MsgStop( 'Conta Contabil nao informada.' )
		Return( .F. )
	EndIf
	
	CT1->( DbSetOrder( 1 ) )
	If CT1->( !DbSeek( xFilial() + M->CVD_CONTA ) )
		MsgStop( 'Conta Contabil nao encontrada.' )
		Return( .F. )
	EndIf
	
	//aCols[ n ][ GDFieldPos( 'CVD_CLASSE' ) ] := CT1->CT1_CLASSE
	
ElseIf cField == 'CVD_CODPLA'
	
	CVN->( DbSetOrder( 2 ) )
	If !Empty( M->CVD_CODPLA ) .And. !Empty( aCols[ n ][ GDFieldPos( 'CVD_CTAREF' ) ] ) .And. ;
		CVN->( DbSeek( xFilial() + M->CVD_CODPLA + aCols[ n ][ GDFieldPos( 'CVD_CTAREF' ) ] ) )
		
		aCols[ n ][ GDFieldPos( 'CVD_TPUTIL' ) ] := CVN->CVN_TPUTIL
		aCols[ n ][ GDFieldPos( 'CVD_CTASUP' ) ] := CVN->CVN_CTASUP
		
	EndIf
	
ElseIf cField == 'CVD_CTAREF'
	
	CVN->( DbSetOrder( 2 ) )
	If !Empty( M->CVD_CTAREF ) .And. !Empty( aCols[ n ][ GDFieldPos( 'CVD_CODPLA' ) ] ) .And. ;
		CVN->( DbSeek( xFilial() + aCols[ n ][ GDFieldPos( 'CVD_CODPLA' ) ] + M->CVD_CTAREF ) )
		
		CT1->( DbSeek( xFilial() + aCols[ n ][ GDFieldPos( 'CVD_CONTA' ) ] ) )
		aCols[ n ][ GDFieldPos( 'CVD_TPUTIL' ) ] := CVN->CVN_TPUTIL
		aCols[ n ][ GDFieldPos( 'CVD_CTASUP' ) ] := CVN->CVN_CTASUP
		aCols[ n ][ GDFieldPos( 'CVN_DSCCTA' ) ] := CVN->CVN_DSCCTA		   
		
	EndIf
	
EndIf


Return( .T. )

/*
Função.................: LoadAcols
Objetivo...............: Carrega aCols para MSNewGetdados
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 05/06/2015
Observações............:
*/
*--------------------------------------------*
Static Function LoadAcols
*--------------------------------------------*
Local aNoFields
Local nPosHCta                                    
Local nLenSx3   := Len( SX3->X3_CAMPO )

/*
** Carrega aCols e aHeader de acordo com o dicionario de dados
*/
CT1->( DbSetOrder( 1 ) )
//FillGetDados( 4 , 'CVD', 2 , xFilial( 'CVD' ) + cCvdCodPla , {|| CVD->CVD_FILIAL + CVD->CVD_CODPLA } ,{ || CT1->( DbSeek( xFilial() + CVD->CVD_CONTA ) ) } , aNoFields, /*aYesFields*/ ,,,, .F. ,,,,,,,,, aYesFields )

SX3->( DbSetOrder( 2 ) )
For i := 1 To Len( aYesFields )
	SX3->( DbSeek( PadR( aYesFields[ i ] , nLenSx3 ) ) )
	Aadd( aHeader, {	Rtrim( SX3->(X3Titulo())), ;
						SX3->X3_CAMPO,; 
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID, 	;
						SX3->X3_USADO,	;
						SX3->X3_TIPO, 	;
						SX3->X3_F3,;
						If(!"CVD"$aYesFields[ i ],"V",SX3->X3_CONTEXT),,,,If(!"CVD"$aYesFields[ i ],.F.,SX3->X3_VISUAL),;
						} )
Next                       

Aadd( aHeader, {	"Recno", ;
					"CVD_REC_WT",; 
					"@!",;
					10,;
					0,;
					"AllWaysTrue()", 	;
					"",	;
					"N", 	;
					""/*SX3->X3_F3*/,;
					"R",,,,, "AllWaysTrue()"  ;
					} )


nPosHCta := Ascan( aHeader , { | x | AllTrim( x[ 2 ] ) == 'CVD_CONTA' } )
If nPosHCta > 0
	aHeader[ nPosHCta ][ 9 ] := 'CT1'
EndIf

nPosDCT1 := Ascan( aHeader , { | x | AllTrim( x[ 2 ] ) == 'CT1_DESC01' } )
nPosDCVN := Ascan( aHeader , { | x | AllTrim( x[ 2 ] ) == 'CVN_DSCCTA' } )


aCols := {}

CT1->( DbSetOrder( 1 ) )
CVD->( DbSetOrder( 2 ) ) 
CVN->( DbSetOrder( 2 ) )  //CVN_FILIAL+CVN_CODPLA+CVN_CTAREF       
CVD->( DbSeek( xFilial() + cCvdCodPla ) )                                                                                                                         
While CVD->( !Eof() .And. CVD->CVD_FILIAL + CVD->CVD_CODPLA == xFilial( 'CVD' ) + cCvdCodPla ) 
	If !Empty( CVD->CVD_CONTA ) .And. CT1->( DbSeek( xFilial() + CVD->CVD_CONTA ) )
	    
	    Aadd( aCols , Array( Len( aHeader ) + 1 ) )
	    For i := 1 To Len( aHeader )
			
			If AllTrim( aHeader[ i ][ 2 ] ) == 'CT1_DESC01'
				aCols[ Len( aCols ) ][ i ] := Posicione( 'CT1' , 1 , xFilial( 'CT1' ) + CVD->CVD_CONTA , 'CT1_DESC01' )	
			ElseIf AllTrim( aHeader[ i ][ 2 ] ) == 'CVN_DSCCTA'
				aCols[ Len( aCols ) ][ i ] := Posicione( 'CVN' , 2 , xFilial( 'CVN' ) + CVD->CVD_CODPLA + CVD->CVD_CTAREF , 'CVN_DSCCTA' )				
			ElseIf AllTrim( aHeader[ i ][ 2 ] ) == 'CVD_REC_WT'
				aCols[ Len( aCols ) ][ i ] := CVD->( Recno() ) 			
			Else
				aCols[ Len( aCols ) ][ i ] := CVD->&( aHeader[ i ][ 2 ] ) 	    	
    		EndIf
    		
    		aCols[ Len( aCols ) ][ Len( aHeader ) + 1 ] := .F.		
	    Next
	EndIf
	CVD->( DbSkip() )
EndDo



/*
** Carrego CT1 sem amarração com o plano referencial  ( CVD )
*/

If !lExclui
	CT1->( DbSeek( xFilial() ) )
	While CT1->( !Eof() .And. CT1_FILIAL == xFilial() )
		
		If Ascan( aCols , { | x | x[ GDFieldPos( 'CVD_CONTA' ) ] + x[ GDFieldPos( 'CVD_CODPLA' ) ] == CT1->CT1_CONTA + cCvdCodPla } ) == 0
			AAdd( aCols , Array( Len( aHeader ) + 1 ) )
			For i := 1 To Len( aHeader )
				If AllTrim( aHeader[ i ][ 2 ] ) == "CVD_CONTA"
					aTail( aCols )[ i ] :=  CT1->CT1_CONTA
				
				ElseIf AllTrim( aHeader[ i ][ 2 ] ) == "CT1_DESC01"				
					aTail( aCols )[ i ] := 	CT1->CT1_DESC01	

				ElseIf AllTrim( aHeader[ i ][ 2 ] ) == "CVD_REC_WT"
					aTail( aCols )[ i ] := 0 
					
				ElseIf AllTrim( aHeader[ i ][ 2 ] ) == "CVD_CODPLA"
					aTail( aCols )[ i ] :=  cCvdCodPla
				Else
					aTail( aCols )[ i ] := CriaVar( aHeader[ i ][ 2 ] , .F. )
					
				EndIf
			Next
			aTail( aCols )[ i ] := .F.
		EndIf
		CT1->( DbSkip() )
	EndDo
EndIf
Return

/*
Função.................: ExportaXLS	
Objetivo...............: Exporta Grid de Dados para Excel
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 18/03/2016
Observações............:
*/
*--------------------------------------------*
Static Function ExportaXLS	
*--------------------------------------------*
Local oExcel, aAux     
Local cFile := GetTempPath() + 'PlanRef_' + DtoS( dDatabase ) + "_" + StrTran( Time() , ':' , '' ) + '.csv'
Local cBuffer := ''


If File( cFile )
	FErase( cFile )
EndIf

nHFile := FCreate( cFile )

For nVez := 1 To 2
	cBuffer := ''
	For i := 1 To Len( aHeader ) 
		
		If Alltrim( aHeader[ i ][ 2 ] ) == 'CVD_CODPLA'
			Loop
		EndIf
		
		If Ascan( aYesFields , { | x | Alltrim( aHeader[ i ][ 2 ] ) == AllTrim( x ) } ) == 0
			Loop
		EndIf
			
		If !Empty( cBuffer )
			cBuffer += ";"
		EndIf
		
		cBuffer += If( nVez == 1 , aHeader[ i ][ 2 ] , aHeader[ i ][ 1 ] )
	Next
	cBuffer += CRLF

	FWrite( nHFile , cBuffer , Len( cBuffer ) )

Next


ProcRegua( Len( aCols ) )
For i := 1 To Len( aCols )
	cBuffer := ""
	IncProc()
	For j := 1 To Len( aHeader ) 
		
		If Alltrim( aHeader[ j ][ 2 ] ) == 'CVD_CODPLA' .Or. Ascan( aYesFields , { | x | Alltrim( aHeader[ j ][ 2 ] ) == AllTrim( x ) } ) == 0
			Loop
		EndIf
			
		If !Empty( cBuffer )
			cBuffer += ";"
		EndIf
		cBuffer += cValToChar( aCols[ i ][ j ] )		
	Next
	cBuffer += CRLF
	FWrite( nHFile , cBuffer , Len( cBuffer ) )
Next   


FClose( nHFile )

oExcel1:=MsExcel():New()
oExcel1:WorkBooks:Open( cFile )  
oExcel1:SetVisible(.T.)

Return

/*
Função.................: ImportaXLS	
Objetivo...............: Importar Dados para Grid
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 18/03/2016
Observações............:
*/
*--------------------------------------------*
Static Function ImportaXLS( oNewGetDados )	
*--------------------------------------------*
Local cTitle        := "Selecione o arquivo"
Local cMask         := "Arquivos CSV (*.csv) |*.csv"
Local nDefaultMask  := 0
Local cDefaultDir   := "C:\"
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE
Local cPlanilha     
Local aLinha  		
Local nPosConta		:= Ascan( oNewGetDados:aHeader , { | x | AllTrim( x[ 2 ] ) == 'CVD_CONTA' } )
Local aDadosLog		:= {}
Local aAux			:= {}
Local oDlg

cPlanilha := cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions )

If Empty( cPlanilha )
	MsgStop( 'Planilha nao informada.' )
	Return
EndIf

If !MsgYesNo( 'Confirma importação da planilha ?' )
	Return
EndIf     

If !CpyT2S( cPlanilha , "\" + CurDir() )
	MsgStop( 'Erro na copia da planilha para servidor.' )
	Return
EndIf  

cPlanilha :=  "\" + CurDir() + SubStr( cPlanilha , RAt( "\" , cPlanilha ) + 1 )  

Ft_Fuse( cPlanilha ) 

aFields 	:= StrTokArr( Ft_FReadLn() , ";" )  

nPConta 	:= Ascan( aFields , "CVD_CONTA" )
nLenConta 	:= Len( CVD->CVD_CONTA )

nPCtaRef 	:= Ascan( aFields , "CVD_CTAREF" )
nLenCtaRef  := Len( CVD->CVD_CTAREF )

nPEntRef 	:= Ascan( aFields , "CVD_ENTREF" )
nLenEntRef  := Len( CVD->CVD_ENTREF )

nPCusto 	:= Ascan( aFields , "CVD_CUSTO" )
nLenCusto  	:= Len( CVD->CVD_CUSTO )

nPTpUtil 	:= Ascan( aFields , "CVD_TPUTIL" )
nLenTpUtil  := Len( CVD->CVD_TPUTIL )

nPClasse 	:= Ascan( aFields , "CVD_CLASSE" ) 
nLenClasse  := Len( CVD->CVD_CLASSE )

nPNat 		:= Ascan( aFields , "CVD_NATCTA" ) 
nLenNat   	:= Len( CVD->CVD_NATCTA )

nPCtaSup 	:= Ascan( aFields , "CVD_CTASUP" )
nLenSup   	:= Len( CVD->CVD_CTASUP )

Ft_FSkip();Ft_FSkip()

ProcRegua( FT_FLastRec() )

nLinha := 2   

CT1->( DbSetOrder( 1 ) )    //** CT1_FILIAL + CT1_CONTA
CTT->( DbSetOrder( 1 ) )	//** CTT_FILIAL + CTT_CUSTO    
CVD->( DbSetOrder( 4 ) ) 	//** CVD_FILIAL+CVD_ENTREF+CVD_CODPLA+CVD_CONTA+CVD_CUSTO
While !Ft_FEof()
	
	nLinha ++
	IncProc( 'Lendo Itens da Planilha' ) 
//    aLinha := StrTokArr( Ft_FReadLn() , ";" )   
    aLinha := Separa( Ft_FReadLn() , ";" )   
    
    cConta 	:= PadR( AllTrim( aLinha[ nPConta ] ) , nLenConta )
    
    cCtaRef := PadR( If( Len( aLinha ) >= nPCtaRef ,  aLinha[ nPCtaRef ] , '' ) , nLenCtaRef )
    cCusto 	:= PadR( If( Len( aLinha ) >= nPCusto , aLinha[ nPCusto ] , "" ) , nLenCusto ) 
    
    cEntRef := If( Len( aLinha ) >= nPEntRef .And. !Empty( aLinha[ nPEntRef ] ) , PadL( AllTrim( aLinha[ nPEntRef ] ) , nLenEntRef , '0' ) , '' )  
    cClasse := PadR( If( Len( aLinha ) >= nPClasse , aLinha[ nPClasse ] , '' ) , nLenClasse ) 
    
    cNatCta := If( Len( aLinha ) >= nPNat .And. !Empty( aLinha[ nPNat ] ) , PadL( AllTrim( aLinha[ nPNat ] ) , nLenNat , '0' ) , '' ) 
    cCtaSup := PadR( If( Len( aLinha ) >= nPCtaSup ,  aLinha[ nPCtaSup ] , "" ), nLenSup )  
    
    cTpUtil := PadR( If( Len( aLinha ) >= nPTpUtil , aLinha[ nPTpUtil ] , '' ) , nLenTpUtil )     
    
    aAux := {}
    
    /*
    	* Validação Conta Contabil
    */  
    If Empty( cConta ) 
		Ft_FSkip()
		Loop
	EndIf   
	
    If CT1->( !DbSeek( xFilial() + cConta ) )  
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Conta contabil invalida.' } )    
	EndIf     
	
    /*
    	* Validação Conta Referencial
    */  
    If !Empty( cCtaRef ) .And. CVN->( DbSetOrder( 2 ) , !DbSeek( xFilial() + cCvdCodPla+cCtaRef) )    //CAS - 17-05-2019 Ajuste no Indice: DbSetOrder(2) || + cCvdCodPla+cCtaRef
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Conta Referencial invalida.' } )    
	EndIf	
	
    /*
    	* Validação Entidade
    */  
    If !Empty( cEntRef ) .And. Empty( Tabela( "GP" , cEntRef , .F. ) )
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Codigo da Entidade invalido.' } )    
	EndIf	
	
    /*
    	* Validação Classe da Conta
    */  
    If !Empty( cClasse ) .And. !cClasse $  '1,2'
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Classe da conta invalida.' } )    
	EndIf			 
	
    /*
    	* Validação Natureza da Conta
    */  
    If !Empty( cNatCta ) .And. !cNatCta $  '01,02,03,04,05,09'
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Natureza da conta invalida.' } )    
	EndIf 
	
    /*
    	* Validação Centro Custo
    */  
    If !Empty( cCusto ) .And. CTT->( !DbSeek( xFilial() + cCusto ) )  
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Centro de Custo invalido.' } )    
	EndIf	 	
	
    /*
    	* Validação Tipo de Utilização
    */  
    If !Empty( cTpUtil ) .And. !cTpUtil $  'F,S,A'
		Aadd( aAux , { StrZero( nLinha  , 4 ) , 'Tipo de Utilização nao informado ou invalido.' } )    
	EndIf	
	
	/*
		** Somente atualiza se todos os principais campos forem preenchidos, caso contrario a linha será ignorada .
	*/
	If Empty( aAux ) .And. !Empty( cConta ) .And. !Empty( cCtaRef ) .And. !Empty( cEntRef ) .And. ;
		 !Empty( cClasse ) .And. !Empty( cNatCta )  .And. !Empty( cTpUtil ) 

		/*
			* Busca no aCols a Conta Contabil para atualização
		*/
		If ( nPos := Ascan( oNewGetDados:aCols , { | x | AllTrim( x[ nPosConta ] ) == AllTrim( cConta ) } ) ) > 0 
			GDFieldPut ( 'CVD_CTAREF' , cCtaRef, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_ENTREF' , cEntRef, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_CUSTO' , cCusto, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_TPUTIL' , cTpUtil, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_CLASSE' , cClasse, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_NATCTA' , cNatCta, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 		
			GDFieldPut ( 'CVD_CTASUP' , cCtaSup, nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 	   
			GDFieldPut ( 'CVN_DSCCTA' , Posicione( 'CVN' , 2 , xFilial( 'CVN' ) + cCvdCodPla + cCtaRef , 'CVN_DSCCTA' ), nPos , oNewGetDados:aHeader, oNewGetDados:aCols ) 																				
		EndIf
	
	
	ElseIf !Empty( aAux ) 
		Aadd( aDadosLog , AClone( aAux ) )	
	
	EndIf					
	
	Ft_FSkip()
	
EndDo 

Ft_Fuse()

If !Empty( aDadosLog )

	Define MsDialog oDlg Title 'Log Importação Planilha ECD' From 1 , 1 TO 400 , 600 Of oMainWnd Pixel

		oLbx := TWBrowse():New( ,,,,, { 'Linha da Planilha', 'Descricao do Erro                   ' } ,, oDlg ,,,,,,,,,,,, .F. ,, .T. )
   		oLbx:Align := CONTROL_ALIGN_ALLCLIENT

      	oLbx:SetArray( aDadosLog )
      	oLbx:bLine := { || {  	aDadosLog[ oLbx:nAt , 1 , 1 ] ,;
           		                aDadosLog[ oLbx:nAt , 1 , 2 ] ;
							} }
	    oLbx:GoTop()
    	oLbx:Refresh()
      	oLbx:bLDblClick := { || .T. }
      
	Activate MSDialog oDlg Centered On Init EnchoiceBar( oDlg , { || oDlg:End() } , { || oDlg:End() } )

Else
	MsgInfo( 'Dados atualizados !' )
	
EndIf


Return