#Include "Protheus.Ch"   
#Include "TopConn.Ch"


/*
Programa.............: GTCOM001
Objetivo.............: Gerar Relatorio de Compras Customizado
Autor................: Leandro Diniz de Brito 
Data.................: Agosto/2015
*/                                
*-------------------------------------*
User Function GTCOM001
*-------------------------------------*
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatório imprime a relação de compras, informando o status de cada item do pedido."
Local   cReport   := "GTCOM001"

Local   cTitulo   := "Relatorio de Compras - HLB BRASIL"
Local   oSection

Local   cAlias    := GetNextAlias()

Private cPerg     := PADR( cReport , Len( SX1->X1_GRUPO ) ) 
Private cFornDe   := CriaVar( 'A2_COD' , .F. )
Private cFornAte  := CriaVar( 'A2_COD' , .F. ) 

Private cLojaDe   := CriaVar( 'A2_LOJA' , .F. )
Private cLojaAte  := CriaVar( 'A2_LOJA' , .F. ) 

Private cPedDe    := CriaVar( 'C7_NUM' , .F. )
Private cPedAte   := CriaVar( 'C7_NUM' , .F. ) 

Private dDtIni    := CtoD( '' )
Private dDtFim    := dDataBase

Private cStatus   := Space( 30 )	 
Private aStatus   := { 	'1-Eliminado por Residuo' ,;
						'2-Bloqueado' ,;
						'3-Integracao com o Modulo de Gestao de Contratos' ,;
						'4-Pendente' ,;
						'5-Pedido Parcialmente Atendido' ,;
						'6-Pedido Atendido' ,;
						'7-Pedido Usado em Pre-Nota' ,;
						'8-Todos' }
						
Private aCondStatus := 	{ 	"C7_RESIDUO <> '' "  ,;
							"C7_CONAPRO = 'B' AND C7_QUJE < C7_QUANT  " ,;
							"C7_CONTRA <> '' AND C7_RESIDUO = '' " ,;  
							"C7_CONAPRO <> 'B' AND C7_QUJE = 0  AND C7_QTDACLA = 0 " ,;	 
							"C7_QUJE <> 0 AND C7_QUJE < C7_QUANT " ,;  
							"C7_QUJE >= C7_QUANT " ,;
							"C7_QTDACLA > 0 " } 							 																														
							 																		
						 

Begin Sequence


If !TelaParam()
	Return
EndIf     


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Cria objeto TReport³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oReport  := TReport():New( cReport, cTitulo , /*cPerg*/ , { |oReport| ReportPrint( oReport , cAlias ) } , cDescri )

oReport:SetLandscape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria seção do Relatório³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oSection := TRSection():New( oReport, "Campos do relatorio" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Define células que serão pré carregadas na impressão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


TRCell():New( oSection, "C7_NUM"  , cAlias , )

If SC7->( FieldPos( 'C7_P_NUM' ) ) > 0 
	TRCell():New( oSection, "C7_P_NUM"    , cAlias , )
EndIf	

lPort := ( __LANGUAGE == "PORTUGUESE" ) 

TRCell():New( oSection, "A2_NREDUZ"  , cAlias ,                  )
TRCell():New( oSection, "A2_COD" , cAlias ,                                  )
TRCell():New( oSection, "A2_LOJA"    , cAlias ,                  )
TRCell():New( oSection, "C7_ITEM"    , cAlias ,                  )
TRCell():New( oSection, "C7_PRODUTO" , cAlias ,                  )
TRCell():New( oSection, "C7_DESCRI"  , cAlias ,                  )
TRCell():New( oSection, "C7_UM"      , cAlias ,                  )
TRCell():New( oSection, "C7_QUANT"   , cAlias ,                   )
TRCell():New( oSection, "C7_PRECO"   , cAlias ,   )
TRCell():New( oSection, "C7_TOTAL"   , cAlias ,                   )
TRCell():New( oSection, "SALDO"      , cAlias ,  If( lPort , 'Saldo Pedido' , 'Order Balance'  ) )
TRCell():New( oSection, "C7_DATPRF"  , cAlias ,                  )   

TRCell():New( oSection, "C7_CC"      , cAlias ,                  ) 
oCell := TRCell():New( oSection, "C7DESC_CC"      , cAlias ,   If( lPort , 'Descr. CC' , 'Cost Center Description' ) )  
oCell:SetBlock( { || If( !Empty( ( cAlias )->C7_CC ) , Posicione( 'CTT' , 1 , xFilial( 'CTT' ) + ( cAlias )->C7_CC , 'CTT_DESC01' ) , '' ) } )

TRCell():New( oSection, "C1_SOLICIT" , cAlias ,                  )
oCell := TRCell():New( oSection, "C7_USER"    , cAlias ,    If( lPort , 'Comprador' , 'Buyer'  )  )
oCell:SetBlock( { || UsrRetName( ( cAlias )->C7_USER ) } )   

TRCell():New( oSection, "ULTAPROV"   , cAlias ,   If( lPort , 'Ultimo Aprovador' , 'Last Approver'  ) )
TRCell():New( oSection, "STATUS"   , cAlias ,   'PO Status' )
TRCell():New( oSection, "C7_EMISSAO"   , cAlias ,   )

If SC7->( FieldPos( 'C7_USERLGI' ) ) > 0 
	oCell := TRCell():New( oSection, "DATAINC"    , '' , If( lPort , 'Data Inclusao' , 'Typing Date'  ) )  
	oCell:SetBlock( { || SC7->( DbSetOrder( 1 ) , DbSeek( xFilial() + ( cAlias )->C7_NUM ) ) , FWLeUserlg("C7_USERLGI", 2 ) } )
EndIf	

TRCell():New( oSection, "D1_DOC"   , cAlias ,   )
TRCell():New( oSection, "D1_SERIE"     , cAlias ,                  )
TRCell():New( oSection, "F1_ESPECIE"     , cAlias ,                  )
TRCell():New( oSection, "D1_ITEM"   , cAlias ,                           )
TRCell():New( oSection, "D1_COD"   , cAlias ,                )
oCell := TRCell():New( oSection, "B1_DESC"   , '' ,                    ) 
oCell:SetBlock( { || If( !Empty( ( cAlias )->D1_COD ) , Posicione( 'SB1' , 1 , xFilial( 'SB1' ) + ( cAlias )->D1_COD , 'B1_DESC' ) , '' ) } )

TRCell():New( oSection, "D1_QUANT" , cAlias ,    )
TRCell():New( oSection, "D1_VUNIT"     , cAlias ,                  )
TRCell():New( oSection, "D1_TOTAL"     , cAlias ,                  )
TRCell():New( oSection, "D1_CF"     , cAlias ,                  ) 
TRCell():New( oSection, "D1_TES"     , cAlias ,                  )
TRCell():New( oSection, "D1_CC"     , cAlias ,                  )
oCell := TRCell():New( oSection, "D1DESC_CC"     , '' , If( lPort , 'Descr.CC' , 'Cost Center Description' )   )
oCell:SetBlock( { || If( !Empty( ( cAlias )->D1_CC ) , Posicione( 'CTT' , 1 , xFilial( 'CTT' ) + ( cAlias )->D1_CC , 'CTT_DESC01' ) , '' ) } )

TRCell():New( oSection, "F1_COND"     , cAlias ,                  )
oCell := TRCell():New( oSection, "DESCCOND"     , '' , If( lPort , 'Descr. Cond. Pagamento' , 'Payment Description' )  ) 
oCell:SetBlock( { || If( !Empty( ( cAlias )->F1_COND ) , Posicione( 'SE4' , 1 , xFilial( 'SE4' ) + ( cAlias )->F1_COND , 'E4_DESCRI' ) , '' ) } )

TRCell():New( oSection, "D1_EMISSAO"     , cAlias ,     )
TRCell():New( oSection, "D1_DTDIGIT"     , cAlias ,     )

//ECR - 28/10/2015 - Campos Específicos LinkedIn 
If SC7->( FieldPos( "C7_P_NREQ" ) ) > 0 
	TRCell():New( oSection, "C7_P_NREQ"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_PO' ) ) > 0 
	TRCell():New( oSection, "C7_P_PO"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_LOCAL' ) ) > 0 
	TRCell():New( oSection, "C7_P_LOCAL"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_COMP' ) ) > 0 
	TRCell():New( oSection, "C7_P_COMP"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_REQ' ) ) > 0 
	TRCell():New( oSection, "C7_P_REQ"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_SOL' ) ) > 0 
	TRCell():New( oSection, "C7_P_SOL"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_DESC' ) ) > 0 
	TRCell():New( oSection, "C7_P_DESC"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_END' ) ) > 0 
	TRCell():New( oSection, "C7_P_END"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_ST' ) ) > 0 
	TRCell():New( oSection, "C7_P_ST"     , cAlias ,     )
EndIf

If SC7->( FieldPos( 'C7_P_TIPO' ) ) > 0 
	TRCell():New( oSection, "C7_P_TIPO"     , cAlias ,     )
EndIf

////////////////////////////////////////////////

oReport:PrintDialog()

End Sequence

RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 02/2015
Objetivo.....: Funcao executada no botão OK na tela de parametrização ( impressão )
*/
*---------------------------------------------------------*
Static Function ReportPrint( oReport , cAlias )
*---------------------------------------------------------*
Local oSection := oReport:Section( 1 )     
Local cQuery   := ''


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosL¿
//Inicio Execução da Query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosLÙ

cQuery := "SELECT C7_NUM"

If SC7->( FieldPos( 'C7_P_NUM' ) ) > 0 
	cQuery += ",C7_P_NUM"
EndIf   

cQuery += ",A2_NREDUZ,A2_COD,A2_LOJA,C7_FILIAL,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_PRECO,C7_TOTAL,C7_QUANT-C7_QUJE SALDO,"
cQuery += "C7_DATPRF,C7_CC,C1_SOLICIT,C7_USER,C7_APROV,"
cQuery += "CASE WHEN C7_APROV <> '' THEN ( SELECT TOP 1 ISNULL( AL_NOME,'' ) FROM " + RetSqlName( 'SAL' ) + " AL INNER JOIN " + RetSqlName( 'SCR' ) + " CR "
cQuery += " ON AL_FILIAL =  '" + xFilial( 'SAL' ) + "' AND CR_FILIAL = C7_FILIAL  AND CR_NUM = C7_NUM AND AL.D_E_L_E_T_ = '' AND CR.D_E_L_E_T_ = '' AND AL_APROV = CR_APROV AND AL_COD = C7_APROV AND CR_DATALIB <> '' AND CR_NIVEL = "
cQuery += "( SELECT MAX( CR_NIVEL ) FROM " + RetSqlName( 'SCR' ) + " CR2 WHERE CR2.D_E_L_E_T_ = '' AND CR2.CR_FILIAL = CR.CR_FILIAL AND CR2.CR_NUM = CR.CR_NUM   ) ) "
cQuery += "ELSE '' END ULTAPROV,
cQuery += "CASE  "

For i := 1 To Len( aCondStatus ) 
	cQuery += "WHEN " + aCondStatus[ i ] + " THEN '" + aStatus[ i ] + "' "
Next
cQuery += "ELSE '' END STATUS," 
cQuery += "C7_EMISSAO,D1_TES,D1_DOC,D1_SERIE,F1_ESPECIE,D1_ITEM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_CF,D1_CC,D1_COD, F1_COND,D1_EMISSAO,D1_DTDIGIT " 

If SC7->( FieldPos( 'C7_USERLGI' ) ) > 0 
	cQuery += ",C7_USERLGI "
EndIf

//ECR - 28/10/2015 - Campos especificos do LinkedIn
If SC7->( FieldPos( 'C7_P_NREQ' ) ) > 0 
	cQuery += ",C7_P_NREQ "
EndIf

If SC7->( FieldPos( 'C7_P_PO' ) ) > 0 
	cQuery += ",C7_P_PO "
EndIf

If SC7->( FieldPos( 'C7_P_LOCAL' ) ) > 0 
	cQuery += ",C7_P_LOCAL "
EndIf

If SC7->( FieldPos( 'C7_P_COMP' ) ) > 0 
	cQuery += ",C7_P_COMP "
EndIf

If SC7->( FieldPos( 'C7_P_REQ' ) ) > 0 
	cQuery += ",C7_P_REQ "
EndIf

If SC7->( FieldPos( 'C7_P_SOL' ) ) > 0 
	cQuery += ",C7_P_SOL "
EndIf

If SC7->( FieldPos( 'C7_P_DESC' ) ) > 0 
	cQuery += ",C7_P_DESC "
EndIf

If SC7->( FieldPos( 'C7_P_END' ) ) > 0 
	cQuery += ",C7_P_END "
EndIf

If SC7->( FieldPos( 'C7_P_ST' ) ) > 0 
	cQuery += ",C7_P_ST "
EndIf

If SC7->( FieldPos( 'C7_P_TIPO' ) ) > 0 
	cQuery += ",C7_P_TIPO "
EndIf

//////////////////////////////////

cQuery += "FROM " + RetSqlName( 'SC7' ) + " C7 INNER JOIN "
cQuery += RetSqlName( 'SA2' ) + " A2 ON "
cQuery += "C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA "
cQuery += "LEFT JOIN " + RetSqlName( 'SC1' ) + " C1 "
cQuery += "ON C1.D_E_L_E_T_ = '' AND C1_FILIAL = C7_FILIAL AND "
cQuery += "C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC "
cQuery += "LEFT JOIN " + RetSqlName( 'SD1' ) + " D1 ON "
cQuery += "D1.D_E_L_E_T_ = '' AND D1_FILIAL = C7_FILIAL AND "
cQuery += "D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND "
cQuery += "D1_FORNECE = C7_FORNECE AND D1_LOJA = C7_LOJA "
cQuery += "LEFT JOIN " + RetSqlName( 'SF1' ) + " F1 ON "
cQuery += "F1.D_E_L_E_T_ = '' AND F1_FILIAL = D1_FILIAL AND "
cQuery += "F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND "
cQuery += "F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA "

cQuery += "WHERE C7_FILIAL = '" + xFilial( 'SC7' ) + "' AND "
cQuery += "C7.D_E_L_E_T_ = '' AND A2.D_E_L_E_T_ = '' AND A2_FILIAL = '" + xFilial( 'SA2' ) + "'" 

If Val( Left( cStatus , 1 ) ) <> Len( aStatus )
	cQuery += " AND " + aCondStatus[ Val( Left( cStatus , 1 ) ) ]
EndIf       

cQuery += " AND C7_FORNECE BETWEEN '" + cFornDe + "' AND '" + cFornAte + "' "
cQuery += " AND C7_LOJA BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "' "
cQuery += " AND C7_NUM BETWEEN '" + cPedDe + "' AND '" + cPedAte + "' " 
cQuery += " AND C7_EMISSAO BETWEEN '" + DtoS( dDtIni ) + "' AND '" + DtoS( dDtFim ) + "' "  
cQuery += "ORDER BY C7_NUM"
   

TCQuery cQuery ALIAS ( cAlias ) NEW 

TCSetField( cAlias , 'C7_DATPRF' , 'D' , 8 , 0 )
TCSetField( cAlias , 'D1_EMISSAO' , 'D' , 8 , 0 )
TCSetField( cAlias , 'D1_DTDIGIT' , 'D' , 8 , 0 )   
TCSetField( cAlias , 'C7_EMISSAO' , 'D' , 8 , 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                     ³Imprime relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection:cAlias := cAlias
oSection:Print()

( cAlias )->( DbCloseArea() )

Return

/*
Função...............: TelaParam
Objetivo.............: Informar os parametros do relatório
*/
*-------------------------------------*
Static Function TelaParam   
*-------------------------------------*
Local oDlg 
Local oCombo

Local bOk     	:= { || nOption := 1 , oDlg:End() }
Local bCancel	:= { || nOption := 0 , oDlg:End() }
Local nOption 	:= 0

cStatus := aStatus[ 1 ]
Define MSDialog oDlg Title 'Parametros Relatorio de Compras - HLB' From 1,1 To 280,370 Of oMainWnd Pixel

	@07,05 Say 'Do Fornecedor' Size 60,10 Of ODlg Pixel  
	@19,05 Say 'Ao Fornecedor' Size 60,10 Of ODlg Pixel  
	@31,05 Say 'Da Loja' Size 60,10 Of ODlg Pixel  
	@43,05 Say 'Ate Loja' Size 60,10 Of ODlg Pixel  
	@55,05 Say 'Do Pedido' Size 60,10 Of ODlg Pixel  
	@67,05 Say 'Ao Pedido' Size 60,10 Of ODlg Pixel 
	@79,05 Say 'Status' Size 60,10 Of ODlg Pixel  	 
	@91,05 Say 'Da Emissao' Size 60,10 Of ODlg Pixel  	
	@103,05 Say 'Ate Emissao' Size 60,10 Of ODlg Pixel  		
	
	
	@07,60 MsGet cFornDe F3( 'SA2' ) Size 60,10 Of oDlg Pixel	
	@19,60 MsGet cFornAte F3( 'SA2' ) Size 60,10 Of oDlg Pixel	
	@31,60 MsGet cLojaDe Size 60,10 Of oDlg Pixel	
	@43,60 MsGet cLojaAte Size 60,10 Of oDlg Pixel	
	@55,60 MsGet cPedDe  F3( 'SC7' )  Size 60,10 Of oDlg Pixel	
	@67,60 MsGet cPedAte  F3( 'SC7' )  Size 60,10 Of oDlg Pixel	
	@79,60 MSComboBox oCombo VAR cStatus ITEMS aStatus Size 120,10 Of oDlg Pixel
	@91,60 MsGet dDtIni   Size 60,10 Of oDlg Pixel		
	@103,60 MsGet dDtFim   Size 60,10 Of oDlg Pixel			
					

Activate MSDialog oDlg On Init EnchoiceBar( oDlg , bOk , bCancel ) Centered


Return( nOption == 1 )