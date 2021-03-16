#Include "Protheus.Ch"
#Include "TopConn.Ch"



/*
Função.............: 28CTB001
Objetivo...........: Gerar arquivo texto contendo lançamentos contabeis para o sistema AutBank
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 28/03/2016
Observações........:
*/                  

Static cDirDest
*--------------------------------------*
User Function 28CTB001
*--------------------------------------*  
Local cTitulo		:= 'BBVA - Geração Lançamentos Contabeis Autbank'
Local cDescription	:= 'Esta rotina permite gerar arquivo texto contendo os lançamentos contabeis da empresa BBVA para o sistema AutBank .'

Local oProcess
Local bProcesso

Private aRotina 	:= {}//MenuDef()
Private cPerg 	 	:= '28CTB001'

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )
Private cTpSel    


If !( cEmpAnt $ '28,99' )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf


AjusSx1() 
AjusSxb()

bProcesso	:= { |oSelf| GeraArq( oSelf ) }
oProcess 	:= tNewProcess():New( "28CTB001" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.) 

Return

/*
Função.................: GeraArq
Objetivo...............: Função para executar seleção dos dados e gerar arquivo texto
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 01/04/2016
Observações............:
*/
*--------------------------------------------*
Static Function GeraArq	
*--------------------------------------------*
Local cAlias 
Local cQuery           
Local cDir
Local cFile    
Local nHFile
Local cHist          

Private nSeqArq := GetMV( 'MV_P_00070' )


Pergunte( cPerg , .F. )

If Empty( MV_PAR06 ) 
	MsgStop( 'Diretorio de destino nao informado.' )
	Return
EndIf 

If Empty( MV_PAR07 ) 
	MsgStop( 'Nome do arquivo nao informado.' )
	Return
EndIf

cDir 	:= AllTrim( MV_PAR06 )

If Right( cDir , 1 ) <> "\"
	cDir += "\"
EndIf

If !ExistDir( cDir )
	MsgStop( 'Diretorio informado invalido.' )
	Return
EndIf
 
cFile 	:= AllTrim( MV_PAR07 )

If At( "." , cFile ) == 0 
	cFile := cFile + '.Txt'
EndIf      

If File( cFile )
	FErase( cFile )
EndIf              

nHFile := FCreate( cFile )

If FError() <>  0
	MsgStop( 'Erro na criação do arquivo temporario.' )
	Return
EndIf

/*
cQuery := "SELECT R_E_C_N_O_ RECCT2,CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,CT2_LINHA,CT2_DC,CT2_VALOR,CT2_HP,CT2_HIST,CT2_CREDIT,CT2_DEBITO,CT2_SEQUEN "
cQuery += "FROM " + RetSqlName( 'CT2' ) + " WHERE D_E_L_E_T_ = '' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND "
cQuery += "CT2_DATA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" +  DtoS( MV_PAR02 ) + "' AND "
cQuery += "( ( CT2_DEBITO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) OR ( CT2_CREDIT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) ) AND " 
cQuery += "CT2_MOEDLC = '" + MV_PAR05 + "' AND "
cQuery += "CT2_TPSALD = '1' AND "
cQuery += "CT2_DC <> '4' "
cQuery += "ORDER BY CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA "
*/

cQuery := "SELECT R_E_C_N_O_ RECCT2,CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,CT2_LINHA,CT2_DC,CT2_VALOR,CT2_HP,CT2_HIST,CT2_CREDIT,CT2_DEBITO,CT2_SEQUEN "
cQuery += " FROM " + RetSqlName( 'CT2' ) + " WHERE D_E_L_E_T_ = '' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND "
cQuery += " CT2_DATA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" +  DtoS( MV_PAR02 ) + "' AND "
cQuery += " ( ( CT2_DEBITO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) OR ( CT2_CREDIT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) ) AND " 
cQuery += " CT2_MOEDLC = '" + MV_PAR05 + "' AND "
cQuery += " CT2_TPSALD = '1' AND "
cQuery += " CT2_DC IN ('1','2') "

cQuery += " UNION ALL

cQuery += " SELECT R_E_C_N_O_ RECCT2,CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,CT2_LINHA,'1' AS CT2_DC,CT2_VALOR,CT2_HP,CT2_HIST,'' AS CT2_CREDIT,CT2_DEBITO,CT2_SEQUEN "
cQuery += " FROM " + RetSqlName( 'CT2' ) + " WHERE D_E_L_E_T_ = '' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND "
cQuery += " CT2_DATA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" +  DtoS( MV_PAR02 ) + "' AND "
cQuery += " ( ( CT2_DEBITO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) OR ( CT2_CREDIT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) ) AND " 
cQuery += " CT2_MOEDLC = '" + MV_PAR05 + "' AND "
cQuery += " CT2_TPSALD = '1' AND "
cQuery += " CT2_DC IN ('3') "

cQuery += " UNION ALL

cQuery += " SELECT R_E_C_N_O_ RECCT2,CT2_DATA,CT2_LOTE,CT2_DOC,CT2_SBLOTE,CT2_LINHA,'2' AS CT2_DC,CT2_VALOR,CT2_HP,CT2_HIST,CT2_CREDIT,'' AS CT2_DEBITO,CT2_SEQUEN "
cQuery += " FROM " + RetSqlName( 'CT2' ) + " WHERE D_E_L_E_T_ = '' AND CT2_FILIAL = '" + xFilial( 'CT2' ) + "' AND "
cQuery += " CT2_DATA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" +  DtoS( MV_PAR02 ) + "' AND "
cQuery += " ( ( CT2_DEBITO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) OR ( CT2_CREDIT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' ) ) AND " 
cQuery += " CT2_MOEDLC = '" + MV_PAR05 + "' AND "
cQuery += " CT2_TPSALD = '1' AND "
cQuery += " CT2_DC IN ('3') "

cQuery += " ORDER BY CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA "


cAlias := GetNextAlias()
TCQuery cQuery ALIAS ( cAlias ) NEW   

TCSetField( cAlias , 'CT2_VALOR' , 'N' , 17 , 2 )


While ( cAlias )->( !Eof() )
    
	cChave := ( cAlias )->( CT2_DATA + CT2_LOTE + CT2_SBLOTE + CT2_DOC )
	nQtDeb  := 0
	nQtCred := 0 
	nQtDob := 0
	aAux := {}	   
	cHist := ''
	While ( cAlias )->( !Eof() .And. CT2_DATA + CT2_LOTE + CT2_SBLOTE + CT2_DOC == cChave ) 
		
		If ( cAlias )->CT2_DC == '1' 
			nQtDeb ++
		EndIf	  
		
		If ( cAlias )->CT2_DC == '2' 
			nQtCred ++
		EndIf  
		
		If ( cAlias )->CT2_DC == '3' 
			nQtDob ++
		EndIf 		
		
		cHist := MontaHist( ( cAlias )->RECCT2 ) 
		AAdd( aAux , { SubStr( ( cAlias )->CT2_DATA , 5 , 2 ) + "/" + SubStr( ( cAlias )->CT2_DATA , 7 , 2 ) + "/" + SubStr( ( cAlias )->CT2_DATA , 1 , 4 ),;
		                ( cAlias )->CT2_LOTE,;
		                ( cAlias )->CT2_SEQUEN,;
		                ( cAlias )->CT2_SBLOTE,;
		                ( cAlias )->CT2_LINHA,;
		                If( ( cAlias )->CT2_DC == '1' , 'D' , If( ( cAlias )->CT2_DC == '2' , 'C' , 'P' ) ) ,;
						( cAlias )->CT2_VALOR,;
						( cAlias )->CT2_HIST,;
						( cAlias )->CT2_HP,;
						 cHist,;
						( cAlias )->CT2_CREDIT ,;
						( cAlias )->CT2_DEBITO } )
		
		( cAlias )->( DbSkip() )  

	EndDo  
	
	If Len( aAux ) > 0 
	
		If ( nQtDeb == 1 .And. nQtCred == 1  )
		
			/*
				** Se houver somente 1 Debito e 1 Credito gera como Partida Dobrada
			*/
			nPosCred := 0
			nPosDeb := 0
			For i := 1 To Len( aAux )
				If aAux[ i ][ 06 ] = 'D'
					nPosDeb := i
				ElseIf aAux[ i ][ 06 ] = 'C'
					nPosCred := i
				EndIf 
				
				If nPosCred > 0 .And. nPosDeb > 0 
					Exit
				EndIf	 
			Next
			
			If nPosCred > 0 .And. nPosDeb > 0
				aAux[ nPosDeb ][ 06 ] := 'P'	
			    aAux[ nPosDeb ][ 11 ] :=  aAux[ nPosCred ][ 11 ]
			    aDel( aAux , nPosCred )
			    aSize( aAux , Len( aAux ) - 1 ) 
			EndIf

		EndIf
		cFormLcto := If( Len( aAux ) ==  1 , '11' , If( nQtDeb == 1 .And. nQtCred > 1 , '1N' , If( nQtDeb > 1 .And. nQtCred = 1 , 'N1' , 'NN' ) ) )   
		GravaLinha( nHFile , aAux , cFormLcto ) 
	EndIf

EndDo

If Select( cAlias ) > 0
	( cAlias )->( DbCloseArea() )
EndIf

FClose( nHFile )

If !CpyS2T( cFile , cDir ) 
	MsgStop( 'Erro na cópia do arquivo para diretorio de destino.' )
Else
	nSeqArq ++
	SetMV( 'MV_P_00070' , nSeqArq )
	MsgInfo( 'Arquivo gerado em ' + cDir + cFile )
EndIf

Return
                      

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1
*-------------------------------------------------*

U_PUTSX1( cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Inicial" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Final" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'03' , 'Da Conta' ,'Da Conta'/*cPerSpa*/,'Da Conta'/*cPerEng*/,'mv_ch3','C' , Len( CT1->CT1_CONTA ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'CT1'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Conta Contabil Inicial" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'04' , 'Ate Conta' ,'Ate Conta'/*cPerSpa*/,'Ate Conta'/*cPerEng*/,'mv_ch4','C' , Len( CT1->CT1_CONTA ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'CT1'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Conta Contabil Final" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'05' , 'Moeda' ,'Moeda'/*cPerSpa*/,'Moeda'/*cPerEng*/,'mv_ch5','C' , 2 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'CTO'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR05'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Moeda dos Lancamentos" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'06' , 'Salvar em ' ,'Salvar em '/*cPerSpa*/,'Salvar em '/*cPerEng*/,'mv_ch6','C' , 90 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'28CTB1'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR06'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Selecione Diretorio de Destino " , "Ex. C:\Temp" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'07' , 'Nome do arquivo' ,'Nome do Arquivo'/*cPerSpa*/,'Nome do arquivo'/*cPerEng*/,'mv_ch7','C' , 20 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR07'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Nome do arquivo a ser gerado" , "com extensão, Ex: Saida.Txt" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return
                                                   
  
/*
Função..........: AjustaSxb
Objetivo........: Cadastrar automaticamente consulta SXB
*/
*-------------------------------------------------*
Static Function AjusSXB
*-------------------------------------------------*  
Local cF3 := PadR( '28CTB1' , Len( SXB->XB_ALIAS ) )

If SXB->( !DbSeek( cF3 ) )

	SXB->( RecLock( 'SXB' , .T. ) )
	SXB->XB_ALIAS	:= cF3
	SXB->XB_TIPO 	:= '1'
	SXB->XB_SEQ		:= '01'
	SXB->XB_COLUNA	:= 'RE'
	SXB->XB_DESCRI	:= 'Selecione Diretorio'
	SXB->XB_DESCSPA	:= 'Selecione Diretorio'
	SXB->XB_DESCENG	:= 'Selecione Diretorio'		
	SXB->XB_CONTEM 	:= 'SX5'
	SXB->( MSUnlock() ) 
	
	SXB->( RecLock( 'SXB' , .T. ) )
	SXB->XB_ALIAS	:= cF3
	SXB->XB_TIPO 	:= '2'
	SXB->XB_SEQ		:= '01'
	SXB->XB_COLUNA	:= '01'
	SXB->XB_DESCRI	:= ''
	SXB->XB_DESCSPA	:= ''
	SXB->XB_DESCENG	:= ''		
	SXB->XB_CONTEM 	:= 'u_28SelFile()'
	SXB->( MSUnlock() )
	
	SXB->( RecLock( 'SXB' , .T. ) )
	SXB->XB_ALIAS	:= cF3
	SXB->XB_TIPO 	:= '5'
	SXB->XB_SEQ		:= '01'
	SXB->XB_COLUNA	:= ''
	SXB->XB_DESCRI	:= ''
	SXB->XB_DESCSPA	:= ''
	SXB->XB_DESCENG	:= ''		
	SXB->XB_CONTEM 	:= 'u_28RetFile()'
	SXB->( MSUnlock() )

EndIf

Return

/*
Função.................: 28SelFile
Objetivo...............: Selecionar Diretorio para salvar arquivo texto
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 01/04/2016
Observações............:
*/
*--------------------------------------------*
User Function 28SelFile	
*--------------------------------------------*
Local cTitle        := "Selecione o diretorio"
Local cMask         := "Arquivos *.* (*.*) |*.*"
Local nDefaultMask  := 0
Local cDefaultDir   := "C:\"
Local nOptions      := GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY

cDirDest := cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions )

Return( !Empty( cDirDest ) )  

/*
Função.................: 28RetFile
Objetivo...............: Retornar Diretorio Destino
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 01/04/2016
Observações............:
*/
*--------------------------------------------*
User Function 28RetFile	 ; Return ( cDirDest )
*--------------------------------------------*   

/*
Função.................: MontaHist
Objetivo...............: Retornar Historico Completo da linha do lançamento
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 01/04/2016
Observações............:
*/
*--------------------------------------------*
Static Function MontaHist( nRecCT2 )	
*--------------------------------------------*
Local cHist

CT2->( DbSetOrder( 1 ) )
CT2->( DbGoTo( nRecCT2 ) )
cHist := AllTrim( CT2->CT2_HIST )          

/*
	** Para montagem do historico, as linhas seguintes ao lançamento atual que são tipo 4, pertencem ao ultimo Debito\Credito\Partida dobrada
*/

CT2->( DbSkip() )
While CT2->( !Eof() .And. CT2_DC == '4' )
	cHist += " " + AllTrim( CT2->CT2_HIST )     
	CT2->( DbSkip() )	
EndDo

Return( cHist )      

/*
Função.................: GeraLinha
Objetivo...............: Retornar Historico Completo da linha do lançamento
Autor..................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data...................: 01/04/2016
Observações............:
*/
*-------------------------------------------------------*
Static Function GravaLinha( nHFile , aAux , cFormLcto ) 
*-------------------------------------------------------* 
Local cTxt      
Local i                                   
Local nItens := Len( aAux ) 
Local cDtAtu := DtoS( dDataBase ) 

CT1->( DbSetOrder( 1 ) )

If ( cFormLcto == '11' )
	nItens := 1
EndIf
       
cDtAtu := SubStr( cDtAtu , 5 , 2 ) + "/" + SubStr( cDtAtu , 7 , 2 ) + "/" + SubStr( cDtAtu , 1 , 4 )
For i := 1 To nItens             
	
	cTxt := cDtAtu// Data processamento - formato : MM/DD/AAAA
	cTxt += 'CC001   '  // Código do sistema a integrar
	cTxt += StrZero( nSeqArq , 6 ) //Número seqüencial de remessa
	cTxt += StrZero( Val( aAux[ i ][ 3 ] ) , 10 )  //Numero Seqüencial Único na Remessa   
	cTxt += StrZero( i , 02 ) //Numero de itens dentro do lançamento     
	cTxt += '001' //Código de empresa 
	cTxt += '00000' //CODAGENCIA
	cTxt += '00019' //Número da unidade contábil
	cTxt += Replicate( '0' , 20 ) //Nivel
	cTxt += aAux[ i ][ 01 ]  // Data lançamento
	cTxt += If( cFormLcto == '11' .Or. aAux[ i ][ 06 ] == 'P' , 'D' , aAux[ i ][ 06 ] )  // Debito Credito  
	cTxt += " " + StrTran( StrZero( aAux[ i ][ 07 ] , 19 , 2 ) , "." , "," ) // Valor
	cTxt += Replicate( '0' , 30 ) // Zeros
	cTxt += '0001' // Cod. Historico
	cTxt += PadR( MemoLine(  aAux[ i ][ 10 ] , 30 , 1 ) , 30 ) // Complemento 1 
	cTxt += PadR( MemoLine(  aAux[ i ][ 10 ] , 30 , 2 ) , 30 ) // Complemento 2 
	cTxt += PadR( MemoLine(  aAux[ i ][ 10 ] , 30 , 3 ) , 30 ) // Complemento 3 
	cTxt += PadR( MemoLine(  aAux[ i ][ 10 ] , 30 , 4 ) , 30 ) // Complemento 4 
	cTxt += PadR( MemoLine(  aAux[ i ][ 10 ] , 30 , 5 ) , 30 ) // Complemento 5 
	cTxt += cFormLcto // Forma de Lançamento
	cTxt += '1' // Tipo de Lançamento
	cTxt += Replicate( '0' , 35 ) //Zeros
	cTxt += '01' // TIPOCRÉDITO_DB 
	cTxt += '00000' //CODATIVIDADE_DB   
	cTxt += PadR( 'FAIXA' , 10 ) // TPOCONTA_DB     
	
	If aAux[ i ][ 06 ] == 'C'
		cTxt += Replicate( '0' , 15 )	
	Else
		CT1->( DbSeek( xFilial() + aAux[ i ][ 12 ] ) )
		cTxt += Left( CT1->CT1_P_CONT , 15 ) // CONTA_DB
	EndIf 
	
	cTxt += Replicate( '0' , 51 )  // Zeros
	cTxt += '01' //TIPOCRÉDITO_CR  
	cTxt += Replicate( '0' , 5 )//CODATIVIDADE_CR
	cTxt += PadR( 'FAIXA' , 10 ) //CODATIVIDADE_CR   

	If aAux[ i ][ 06 ] == 'D' 
		cTxt += Replicate( '0' , 15 )	
	Else
		CT1->( DbSeek( xFilial() + aAux[ i ][ 11 ] ) )
		cTxt += Left( CT1->CT1_P_CONT , 15 ) // CONTA_CR
	EndIf 

	cTxt += Replicate( '0' , 38 )  // Zeros
    cTxt += " " + Replicate( '0' , 19 )   // QTDDEMOEDA
    cTxt += " " + Replicate( '0' , 19 )   // VALORMOEDA    
    
    cTxt += Replicate( '0' , 18 ) // Zeros
	cTxt += aAux[ i ][ 01 ]  // Data lançamento
    cTxt += '000' // Zeros
    cTxt += Space( 80 ) // Brancos
	
	cTxt += CRLF
	FWrite( nHFile , cTxt , Len( cTxt ) )
	
Next



Return
