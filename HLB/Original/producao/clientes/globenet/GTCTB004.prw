#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.................: GTCTB004
Objetivo...............: Replicar lançamentos da moeda 1 para moeda 3 ( Funcional ) e moeda 5 ( conta resultado )
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 25/05/2015
Observações............:
*/
*----------------------------------*
User Function GTCTB004
*----------------------------------*
Local aArea      := GetArea()
Local oWizard
Local chTitle    := "HLB BRASIL"

Local chMsg      := "Copiar Lancamentos Moeda Funcional"
Local cTitle

Local cText      := "Este programa tem como objetivo copiar os lancamentos da moeda 1 para a moeda funcional e conta de resultado."
Local bNext      := { || .T. }

Local bFinish    := { || .T. }
Local lPanel

Local cResHead
Local bExecute   := { || .T. }

Local lNoFirst
Local aCoord

Local dDataIni   := CtoD( "" )
Local dDataFim   := CtoD( "" )

Local cContaCTA  := Space( Len( CT1->CT1_CONTA ) )
Local cContaIni  := Space( Len( CT1->CT1_CONTA ) )

Local cContaFim	 := Space( Len( CT1->CT1_CONTA ) )
Local bNext2      := { || If( ValidaTela( dDataIni , dDataFim , cContaCTA ) , ( MsgRun( 'Aguarde...Selecionando Registros.' , '' , { || ExecQuery( oGetResult , dDataIni , dDataFim , cContaCTA , cContaIni , cContaFim ) , oGetResult:Refresh() } ) , .T. ) , .F. ) }

Local oGetResult

Local cResult     := ''


oWizard := ApWizard():New ( chTitle , chMsg , cTitle , cText , bNext , /*bFinish*/ , lPanel , cResHead , /*bExecute*/ , lNoFirst , aCoord )

oWizard:NewPanel ( "Filtros" , "" , { || .T. }/*bBack*/ , bNext2  ,/*bFinish*/ , /*bExecute*/  )   //** Dialog

@10,10 Say "Data Inicial" Size 40,10 Of oWizard:oMPanel[ 2 ] Pixel
@10,52 MSGet dDataIni   Size 40,10 Of oWizard:oMPanel[ 2 ] Pixel

@25,10 Say "Data Final" Size 40,10 Of oWizard:oMPanel[ 2 ] Pixel
@25,52 MSGet dDataFim   Size 40,10 Of oWizard:oMPanel[ 2 ] Pixel

@42,10 Say "Conta Inicial" Size 60,10 Of oWizard:oMPanel[ 2 ] Pixel
@40,52 MSGet cContaIni  Size 70,10  F3( 'CT1' ) /*Valid( ExistCpo( 'CT1' , cContaIni , 1 ) )*/ Picture( X3Picture( "CT1_CONTA" ) )  Of oWizard:oMPanel[ 2 ] Pixel

@59,10 Say "Conta Final" Size 60,10 Of oWizard:oMPanel[ 2 ] Pixel
@57,52 MSGet cContaFim  Size 70,10  F3( 'CT1' ) /*Valid( ExistCpo( 'CT1' , cContaFim , 1 ) )*/ Picture( X3Picture( "CT1_CONTA" ) )  Of oWizard:oMPanel[ 2 ] Pixel

@76,10 Say "Conta Resultado" Size 60,10 Of oWizard:oMPanel[ 2 ] Pixel
@74,52 MSGet cContaCTA  Size 70,10  F3( 'CT1' ) Valid( ExistCpo( 'CT1' , cContaCTA , 1 ) ) Picture( X3Picture( "CT1_CONTA" ) )  Of oWizard:oMPanel[ 2 ] Pixel

oWizard:NewPanel ( "Resultado" , "" , { || .T. }/*bBack*/ , /*{ || .T. }*/  , bFinish )
@10,10 Get oGetResult Var cResult MEMO READONLY Size 295,145 Of oWizard:oMPanel[ 3 ] Pixel
oGetResult:bSetGet := { |x| If( x == Nil , cResult , cResult += x ) }

oWizard:Activate( .T. )

RestArea( aArea )

Return

/*
Função..............: ExecQuery
Objetivo............: Selecionar Registros deo banco de dados
*/
*------------------------------------------------------------------------*
Static Function ExecQuery( oGetResult , dDataIni , dDataFim , cContaCTA , cContaIni , cContaFim )
*------------------------------------------------------------------------*
Local cQuery
Local cAliasQ   := GetNextAlias()

Local nSetRegua


/*
** Exclui lancamentos da moeda 3 e 5 do periodo informado
*/


cQuery := "UPDATE " + RetSqlName( "CT2" ) + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE D_E_L_E_T_ = '' AND CT2_DATA BETWEEN '" + DtoS( dDataIni ) + "' AND '" + DtoS( dDataFim )
cQuery += "' AND CT2_MOEDLC IN ( '03' , '05' ) AND "
cQuery += "( ( CT2_CREDIT BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' ) OR "
cQuery += " ( CT2_DEBITO BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' )) AND "
cQuery += "CT2_FILIAL = '" + xFilial( 'CT2' ) + "' "


If TcSqlExec( cQuery ) <> 0
	Eval( oGetResult:bSetGet , 'Ocorreram erros ao apagar os lancamentos anteriores. Favor contatar a TI .' + Chr( 13 ) + Chr( 10 ) + TCSqlError())
	( cAliasQ )->( DbCloseArea() )
	Return
EndIf

cQuery := "SELECT CT21.R_E_C_N_O_ RECM1, CT22.R_E_C_N_O_  RECM2,"
cQuery += "CT21.CT2_VALOR VALORM1,CT22.CT2_VALOR VALORM2,CT21.CT2_DATA CT2_DATA,"
cQuery += "CT21.CT2_LOTE CT2_LOTE,CT21.CT2_SBLOTE CT2_SBLOTE,CT21.CT2_DC CT2_DC,"
cQuery += "CT21.CT2_CREDIT CT2_CREDIT,CT21.CT2_DEBITO CT2_DEBITO,"
cQuery += "COUNT(*) OVER ( PARTITION BY 1 ) TOTAL "
cQuery += "FROM " + RetSqlName( "CT2" ) + " CT21 INNER JOIN "
cQuery += RetSqlName( "CT2" ) + " CT22 ON "
cQuery += "CT21.CT2_FILIAL = CT22.CT2_FILIAL AND "
cQuery += "CT21.CT2_DOC = CT22.CT2_DOC AND "
cQuery += "CT21.CT2_DATA = CT22.CT2_DATA AND "
cQuery += "CT21.CT2_LOTE = CT22.CT2_LOTE AND "
cQuery += "CT21.CT2_SBLOTE = CT22.CT2_SBLOTE AND "
cQuery += "CT21.CT2_LINHA = CT22.CT2_LINHA AND "
cQuery += "CT21.CT2_CREDIT = CT22.CT2_CREDIT AND "
cQuery += "CT21.CT2_DEBITO = CT22.CT2_DEBITO AND "
cQuery += "CT21.CT2_DC = CT22.CT2_DC "
cQuery += "WHERE CT21.CT2_DC <> '4' AND "
cQuery += "CT21.CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND "
cQuery += "CT21.D_E_L_E_T_ = '' AND "
cQuery += "CT22.D_E_L_E_T_ = '' AND "
cQuery += "CT21.CT2_TPSALD = '1' AND "
cQuery += "CT21.CT2_MOEDLC = '01' AND "
cQuery += "CT22.CT2_MOEDLC = '02' AND "
cQuery += "CT21.CT2_DATA BETWEEN '" + DtoS( dDataIni ) + "' AND '" + DtoS( dDataFim ) + "' AND "
cQuery += "( ( CT21.CT2_CREDIT BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' ) OR "
cQuery += " ( CT21.CT2_DEBITO BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' ) ) "
cQuery += "ORDER BY CT21.CT2_FILIAL,CT21.CT2_DATA,CT21.CT2_LOTE,CT21.CT2_DOC,CT21.CT2_LINHA,CT21.CT2_DC"

TCQuery ( cQuery ) ALIAS ( cAliasQ ) NEW

If ( cAliasQ )->( Eof() )
	Eval( oGetResult:bSetGet , "Nao foram encontrados dados com esta selecao!" )
	( cAliasQ )->( DbCloseArea() )
	Return
EndIf

nSetRegua := ( cAliasQ )->TOTAL

Processa( { || ProcRegua( nSetRegua ) , GeraCT2( cAliasQ , oGetResult , dDataIni , dDataFim , cContaCTA , cContaIni , cContaFim ) } , 'Atualizando Lancamentos Moeda Funcional' )

( cAliasQ )->( DbCloseArea() )

Return

/*
/*
Função..............: GeraCT2
Objetivo............: Replicar lancamento da moeda 1 para as moedas 3 e 5
*/
*------------------------------------------------------------------------*
Static Function GeraCT2( cAliasQ , oGetResult , dDataIni , dDataFim , cContaCTA , cContaIni , cContaFim )
*------------------------------------------------------------------------*
Local nCount := 0
Local lAtualizou

Local nTaxa
Local aLog   := {}

Local aTaxas := {}
Local aRegCT2



Local i
Local nDecVal  := TamSx3( 'CT2_VALOR' )[ 2 ]

Local aItens,aItem,aCab
Local aCta  := {} , nPosConta

Private lMsErroAuto


Begin Transaction

lAtualizou := .F.

CT1->( DbSetOrder( 1 ) )
cSeq := StrZero( 0 , Len( CT2->CT2_SEQIDX ) )
While ( cAliasQ )->( !Eof() )
	
	IncProc()
	
	aConta := { ( cAliasQ )->CT2_DEBITO , ( cAliasQ )->CT2_CREDIT }
	
	For nConta := 1 To 2
		
		If Empty( aConta[ nConta ] )
			Loop
		EndIf
		
		/*
		** Quando partida dobrada processa somente as contas que estiverem dentro do filtro
		*/
		If ( ( cAliasQ )->CT2_DC == '3' ) .And. ( aConta[ nConta ] < cContaIni .Or. aConta[ nConta ] > cContaFim  )
			Loop
		EndIf
		
		/*
		** Grava todas as contas no array aCTA para apurar a moeda 5 no final do processamento
		*/
		If ( nPosConta := Ascan( aCta , aConta[ nConta ] )  ) == 0
			Aadd( aCta , aConta[ nConta ] )
		EndIf
		
		CT2->( DbGoTo( ( cAliasQ )->RECM2 ) )
		nValor  := CT2->CT2_VALOR
		
		cMesAno := SubStr( ( cAliasQ )->CT2_DATA , 5 , 2 ) + Left( ( cAliasQ )->CT2_DATA , 4 )
		cHist   := CT2->CT2_HIST
		
		If !Left( aConta[ nConta ] , 1 ) $ '3,4,5'
			nTaxa := BuscaTxM3( cMesAno , aConta[ nConta ] )
			
		Else
			nTaxa := 1
			
			/*
			** Se a taxa não for encontrada será copiado o valor encontrado na moeda 1
			*/
			CT2->( DbGoTo( ( cAliasQ )->RECM1 ) )
			nValor  := CT2->CT2_VALOR
			
		EndIf
		
		If ( nTaxa == 0 )
			nTaxa := RecMoeda( LastDay( StoD( ( cAliasQ )->CT2_DATA ) ) , 2 )
			If Ascan( aLog , { | x | x[ 1 ] == cMesAno + aConta[ nConta ] } ) == 0
				Aadd( aLog , { cMesAno + aConta[ nConta ] , 'AVISO : Taxa não encontrada para conta ' + aConta[ nConta ] + ' Mes/Ano ' + Transf( cMesAno , '@R 99/9999' ) + ' . Foi usado Dolar PTAX do dia ' + DtoC( LastDay( StoD( ( cAliasQ )->CT2_DATA ) ) ) + "."  } )
			EndIf    
			
		EndIf
		
		/*
		** Copia todos os campos para replicar os lancamentos
		*/
		aRegCT2 := {}
		For i := 1 To CT2->( FCount() )
			Aadd( aRegCT2 , CT2->( FieldGet( i ) ) )
		Next
		
		CT2->( RecLock( 'CT2' , .T. ) )
		For i := 1 To Len( aRegCT2 )
			CT2->( FieldPut( i , aRegCT2[ i ] ) )
		Next
		
		CT2->CT2_DC  	:= StrZero( nConta , 1 )
		
		If ( nConta == 1 )
			CT2->CT2_CREDIT	 := ""
			CT2->CT2_DEBITO  := aConta[ 1 ]
		Else
			CT2->CT2_DEBITO  := ""
			CT2->CT2_CREDIT	 := aConta[ 2 ]
		EndIf
		
		CT2->CT2_VALOR  := Round( nValor * nTaxa , nDecVal )
		CT2->CT2_ORIGEM := 'GTCTB004'
		CT2->CT2_MOEDLC := '03'
		CT2->CT2_DATATX := CT2->CT2_DATA
		CT2->CT2_TAXA   := nTaxa
		cSeq := Soma1( cSeq )
		CT2->CT2_SEQIDX := cSeq
		
		CT2->( MSUnlock() )
		
		lAtualizou := .T.
		
	Next
	
	( cAliasQ )->( DbSkip() )
EndDo

End Transaction

/*
**	Executa reprocessamento do saldo contabil na moeda 03
*/
CTBA190( .T. , dDataIni , dDataFim , '' , 'ZZ' , '1' , .T. , '03' )

/*
** Apuração da Moeda 5
*/
Processa( { || ApurM5( aCta , dDataFim , cContaCTA ) } , 'Apurando Moeda 5 - Até ' + DtoC( dDataFim )  )

/*
**	Executa reprocessamento do saldo contabil na moeda 05
*/
CTBA190( .T. , dDataIni , dDataFim , '' , 'ZZ' , '1' , .T. , '05' )

If lAtualizou
	Eval( oGetResult:bSetGet ,  "Termino do Processamento." + Chr( 13 ) + Chr( 10 ) )
	Eval( oGetResult:bSetGet ,  "** Favor verificar relatorio balancete contabil. **"  )
	AEval( aLog , { | x | Eval( oGetResult:bSetGet , Chr( 13 ) + Chr( 10 )  + x[ 2 ] ) } )
Else
	Eval( oGetResult:bSetGet , "Não foram gerados lancamentos na moeda funcional."  )
EndIf

Return

/*
Função.............: ValidaTela
Objetivo...........: Validar dados de entrada
*/
*--------------------------------------------------------------*
Static Function ValidaTela( dDataIni , dDataFim , cContaCTA )
*--------------------------------------------------------------*

If Empty( dDataFim )
	MsgStop( 'Data final nao informada .' )
	Return( .F. )
EndIf

If !Empty( dDataIni )  .And. ( dDataIni > dDataFim )
	MsgStop( 'Data inicial maior que a data final.' )
	Return( .F. )
EndIf

If Empty( cContaCTA )
	MsgStop( 'Conta de resultado não informada.' )
	Return( .F. )
EndIf

If !MsgYesNo( 'Confirma alteração?' )
	Return( .F. )
EndIf

Return( .T. )

/*
Função.............: BuscaTxM3
Objetivo...........: Retorna taxa da moeda funcional para a data e conta informada
Autor..............: Leandro Diniz de Brito ( LDB )
Data...............: 25/05/2015
*/
*-----------------------------------------*
Static Function BuscaTxM3( cMesAno , cConta )
*-----------------------------------------*
Local nRet := 0

If AliasInDic( 'Z26' )
	
	Z26->( DbSetOrder( 1 ) )  //** Z26_FILIAL, Z26_CONTA, Z26_DATA
	If Z26->( DbSeek( xFilial() + cConta + cMesAno ) )
		nRet := Z26->Z26_TAXA
	EndIf
	
EndIf

Return( nRet )

/*
Função.............: ApurM5
Objetivo...........: Apuração Moeda 5
Autor..............: Leandro Diniz de Brito ( LDB )
Data...............: 12/06/2015
*/
*-----------------------------------------*
Static Function ApurM5( aCta , dDataFim , cContaCTA )
*-----------------------------------------*
Local i
Local _cDocCtb

Local nSaldoM1
Local nSaldoM3        

Local cLoteM5    := AllTrim( GetNewPar( 'MV_GT99999' , Replicate( '9' , Len( CT2->CT2_LOTE ) ) ) )

ProcRegua( Len( aCta ) )

For i := 1 To Len( aCta )
	
	IncProc()
	
	nSaldoM1 := SaldoConta( aCta[ i ] , dDataFim , "01" , "1" , 1 )
	nSaldoM3 := SaldoConta( aCta[ i ] , dDataFim , "03" , "1" , 1 )
	
	nDif := Abs( nSaldoM1 - nSaldoM3 )
	
	If ( nDif  > 0.01 )
		
		/*
		** Grava CT2 da conta resultado somente na moeda 5 , nao pode ser MSExecAuto, pois a mesma grava obrigatoriamente também na moeda 1
		*/
		_cDocCtb := ''
		C102ProxDoc( dDataFim , '' , '001' , @_cDocCtb,,,,0 )
		FreeUsedCode()
		CT1->( DbSeek( xFilial() + aCta[ i ] ) )
		
		CT2->( RecLock( 'CT2' , .T. ) )
		CT2->CT2_FILIAL := xFilial( 'CT2' )
		CT2->CT2_DATA   := dDataFim
		CT2->CT2_DOC    := _cDocCtb
		CT2->CT2_LOTE   := cLoteM5
		CT2->CT2_SBLOTE := '001'
		CT2->CT2_LINHA  := StrZero( 1 , Len( CT2->CT2_LINHA ) )
		CT2->CT2_SEQLAN := StrZero( 1 , Len( CT2->CT2_SEQLAN ) )
		CT2->CT2_TPSALD := '1'
		CT2->CT2_MANUAL := '1'
		CT2->CT2_AGLUT  := '2'
		CT2->CT2_VALOR  := nDif
		CT2->CT2_ORIGEM := 'GTCTB004'
		CT2->CT2_MOEDLC := '05'
		CT2->CT2_DATATX := dDataFim
		CT2->CT2_DC		:= If( CT1->CT1_NORMAL == '1' , If( nSaldoM1 > nSaldoM3 , '1' , '2' ) , If( nSaldoM1 > nSaldoM3 , '2' , '1' ) )  //** 1 => Debito ; 2 => Credito
		
		lDebito := .F.
		If ( CT2->CT2_DC == '1' )
			lDebito := .T.
			CT2->CT2_DEBITO := aCta[ i ]
		Else
			CT2->CT2_CREDIT := aCta[ i ]
		EndIf
		CT2->CT2_HIST := 'Lancamento Resultado Moeda 5'
		
		CT2->( MSUnlock() )
		
		CT2->( RecLock( 'CT2' , .T. ) )
		CT2->CT2_FILIAL := xFilial( 'CT2' )
		CT2->CT2_DATA   := dDataFim
		CT2->CT2_DOC    := _cDocCtb
		CT2->CT2_LOTE   := cLoteM5
		CT2->CT2_SBLOTE := '001'
		CT2->CT2_LINHA  := StrZero( 2 , Len( CT2->CT2_LINHA ) )
		CT2->CT2_SEQLAN := StrZero( 2 , Len( CT2->CT2_SEQLAN ) )
		CT2->CT2_TPSALD := '1'
		CT2->CT2_MANUAL := '1'
		CT2->CT2_AGLUT  := '2'
		CT2->CT2_VALOR  := nDif
		CT2->CT2_ORIGEM := 'GTCTB004'
		CT2->CT2_MOEDLC := '05'
		CT2->CT2_DATATX := CT2->CT2_DATA
		CT2->CT2_DC		:= If( lDebito , '2' , '1' )  //** Faz o lancamento da contra partida , 'lDebito' indica o tipo de lancamento na conta resultado
		
		If ( CT2->CT2_DC == '1' )
			CT2->CT2_DEBITO := cContaCTA
		Else
			CT2->CT2_CREDIT := cContaCTA
		EndIf
		CT2->CT2_HIST := cHist
		CT2->( MSUnlock() )
		
	EndIf
	
Next

Return
