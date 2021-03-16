#Include "Protheus.Ch"
#Include "TopConn.Ch"



/*
Função.............: GTFin014
Objetivo...........: Tela de Seleção de Documentos para impressao da Ordem de Pagamento
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 17/12/2015
Observações........:
*/                  

*--------------------------------------*
User Function GTFin014
*--------------------------------------*    
Local aArea	:= GetArea()
Local cPerg := PadR( 'GTFIN014' , Len( SX1->X1_GRUPO ) )
Local cSql  := ''

Local aSizeDlg		:= MsAdvSize()
Local bOk			:= { || lRet := .T. , oDlg:End() }
Local bCancel		:= { || lRet := .F. , oDlg:End() }

Local oDlg 
Local lRet			:= .F. 

Local cAliasTemp   
Local aDados		:= {}

Local oOK      := LoadBitmap( GetResources() , 'LBOK' )
Local oNO      := LoadBitmap( GetResources() , 'LBNO' ) 
Local oLbx

AjusSx1( cPerg )

If !Pergunte( cPerg )
	Return 
EndIf

If MV_PAR04 == 2 .Or. MV_PAR04 == 3
    
	//WFA - 26/01/2017 - Valida se está sendo utilizado Vencimento para Doc.Entrada
	If MV_PAR01 == 2
		MsgStop( 'Filtro de Vencimento não disponivel para Doc.Entrada.' )
		Return  	                                                     
	Else
	 	cSql := "SELECT 'Documento Entrada' AS TIPO,F1_DOC DOCUMENTO,F1_SERIE SERIE,'' PARCELA,F1_EMISSAO EMISSAO,A2_NREDUZ NOMEFOR,F1_VALBRUT TOTAL,F1.R_E_C_N_O_ REC "
	 	cSql += "FROM " + RetSqlName( 'SF1' ) + " F1 INNER JOIN " + RetSqlName( 'SA2' ) + " A2 ON "
	 	cSql += "F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA "
	 	cSql += "WHERE A2.D_E_L_E_T_ = '' AND A2_FILIAL = '" + xFilial( 'SA2' ) + "' AND "
	 	cSql += "F1.D_E_L_E_T_ = '' AND F1_FILIAL = '" + xFilial( 'SF1' ) + "' AND "
	 	cSql += "F1_EMISSAO BETWEEN '" + DtoS( MV_PAR02 ) + "' AND '" + DtoS( MV_PAR03 ) + "' " 	
	Endif
EndIf

If MV_PAR04 == 1 .Or. MV_PAR04 == 3  	
 	
 	If !Empty( cSql )
 		cSql += " UNION " 
 	EndIf
 		
 	cSql += "SELECT 'Contas Pagar' AS TIPO,E2_NUM DOCUMENTO,E2_PREFIXO SERIE,E2_PARCELA PARCELA,E2_EMISSAO EMISSAO,E2_NOMFOR NOMEFOR,E2_VALOR TOTAL,E2.R_E_C_N_O_ REC "
 	cSql += "FROM " + RetSqlName( 'SE2' ) + " E2 "
 	cSql += "WHERE E2.D_E_L_E_T_ = '' AND E2_FILIAL = '" + xFilial( 'SE2' ) + "' AND " 
 	
 	//WFA - 26/01/2017 - Verifica se o filtro será por emissão ou vencimento
 	If MV_PAR01 == 2
 		cSql += "E2_VENCREA BETWEEN '" + DtoS( MV_PAR02 ) + "' AND '" + DtoS( MV_PAR03 ) + "' AND "
 	Else
 		cSql += "E2_EMISSAO BETWEEN '" + DtoS( MV_PAR02 ) + "' AND '" + DtoS( MV_PAR03 ) + "' AND "
 	Endif
 	//WFA - 02/02/2017 - Retirada do filtro solicitado pela Haidee
 	cSql += "( ( E2_ORIGEM = 'FINA050' AND E2_FATURA = '' ) OR E2_ORIGEM = 'FINA290' )  "//AND E2_TIPO IN ( 'BOL' , 'DP ' , 'NF ', 'RED ' )"
EndIf  

cSql += " ORDER BY 1,5 "  
                                                   
cAliasTemp := GetNextAlias()

TCQuery cSql ALIAS ( cAliasTemp ) NEW   

( cAliasTemp )->( DbEval( { || Aadd( aDados , { TIPO, DOCUMENTO, SERIE, PARCELA, EMISSAO, NOMEFOR, TOTAL, REC, .F. } ) } ) )
( cAliasTemp )->( DbCloseArea() )  

DbSelectArea( 'SX3' )

If Len( aDados ) == 0
	MsgStop( 'Nao existem dados para exibição.' )
	Return
EndIf

Define MsDialog oDlg Title 'Impressao Ordem de Pagamento' From aSizeDlg[ 7 ] , aSizeDlg[ 1 ] TO aSizeDlg[ 6 ] , aSizeDlg[ 5 ] Of oMainWnd Pixel
        
      oLbx := TWBrowse():New( ,,,,, { ' ', 'Tipo', 'Numero Documento', 'Prefixo/Serie', 'Parcela', 'Emissao', 'Fornecedor', 'Total' } ,, oDlg ,,,,,,,,,,,, .F. ,, .T. )
	  oLbx:Align := CONTROL_ALIGN_ALLCLIENT

      oLbx:SetArray( aDados )
      oLbx:bLine := { || { If( aDados[ oLbx:nAt , 9  ],  oOK , oNO ),;
                           aDados[ oLbx:nAt , 1 ] ,;
                           aDados[ oLbx:nAt , 2 ] ,;
                           aDados[ oLbx:nAt , 3  ] ,;
                           aDados[ oLbx:nAt , 4 ] ,;
                           StoD( aDados[ oLbx:nAt , 5 ] ) ,;
                           aDados[ oLbx:nAt , 6  ] ,;
                           'R$  ' + AllTrim( Transf( aDados[ oLbx:nAt , 7  ] , X3Picture( 'E2_VALOR' ) ) ) } }
      oLbx:GoTop()
      oLbx:Refresh()
      oLbx:bLDblClick := { || aDados[ oLbx:nAt ][ 9 ] := !aDados[ oLbx:nAt ][ 9 ] }
      
Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel )

If lRet 
	If Ascan( aDados , { | x | x[ 9 ] } ) > 0 
		Processa( { || Imprime( aDados ) } , 'Imprimindo Documentos...' )
	Else
		MsgStop( 'Nenhum documento foi selecionado para impressão.' )
	EndIf	
EndIf

RestArea( aArea )

Return       

/*
Função.............: Imprime
Objetivo...........: Impressao da Ordem de Pagamento
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 17/12/2015
Observações........:
*/                  
*--------------------------------------*
Static Function Imprime( aDados )
*--------------------------------------*                                                                                             
Local cTipoDoc 
Local i 

ProcRegua( Len( aDados ) )

For i := 1 To Len( aDados )
	
	IncProc()
	
	If aDados[ i ][ 9 ]
		If ( AllTrim( aDados[ i ][ 1 ] ) == 'Contas Pagar'  )
			cTipoDoc := 'CP'
			SE2->( DbGoTo( aDados[ i ][ 8 ] ) )
		Else
			cTipoDoc := 'NF'
			SF1->( DbGoTo( aDados[ i ][ 8 ] ) )		
		EndIf 
		
		u_GtFin013( cTipoDoc )
		Sleep( 2000 )

	EndIf

Next

Return

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1( cPerg )
*-------------------------------------------------*

//WFA - 26/01/2017 - Inclusão da opção de filtrar por vencimento
PutSx1( cPerg ,'01' , 'Filtrar Por' ,'Filtrar Por'/*cPerSpa*/,'Filtrar Por'/*cPerEng*/,'mv_ch1','N' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/"Emissão",/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/"Vencimento",/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )  
PutSx1( cPerg ,'02' , 'De' ,'De'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
PutSx1( cPerg ,'03' , 'Ate' ,'Ate'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch3','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )  
PutSx1( cPerg ,'04' , 'Tipo Documento' ,'Tipo Documento'/*cPerSpa*/,'Tipo Documento'/*cPerEng*/,'mv_ch4','N' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,/*cDef01*/"Contas Pagar",/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/"Doc.Entrada",/*cDefSpa2*/,/*cDefEng2*/,"Ambos"/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )  


Return