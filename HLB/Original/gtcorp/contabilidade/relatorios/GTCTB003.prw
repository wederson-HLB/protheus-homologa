#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.............: GTCTB003
Autor..............: Leandro Diniz de Brito ( LDB )
Objetivo...........: Gerar Relatório de Auditoria dos Lançamentos Contabeis ( CT2 )
Data...............: 08/05/2015
Alterações.........:
Modulo.............: SigaCTB
*/                          

*-----------------------------------------*
User Function GTCTB003
*-----------------------------------------*
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatório imprime os Lançamentos Contabeis de acordo com o periodo informado."
Local   cReport   := "GTCTB003"

Local   cTitulo   := "Relacao de Lancamentos Contabeis"
Local   oSection

Local   cAlias    := GetNextAlias()
Local   nFields

Private cPerg     := PADR( cReport , Len( SX1->X1_GRUPO ) )
Private aFieldsReport := {  "CT2_ORIGEM" , "CT2_FILIAL" , "CT2_DATA"  , "CT2_LOTE"  , "CT2_SBLOTE" ,;
       						"CT2_SEQLAN" , "CT2_DOC" 	, "CT2_LINHA" , "CT2_DC" 	, "CT2_DEBITO" , "CT2_CREDIT" , "CT2_VALOR" , "CT2_HIST" ,;
       						"CT2_MOEDLC" , "CT2_ROTINA" }

//RRP - 11/09/2015 - Validando os campos, pois gerava erro na tela.       						
CT2->(DbSetOrder(1))
If CT2->(FieldPos("CT2_USERGI")) == 0 .OR. CT2->(FieldPos("CT2_USERGA")) == 0
	MsgInfo('Relatório não pode ser gerado. Campo de Log inexistente!','Grant Thornton')
	Return
EndIf


AjusSx1( cPerg )                                                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Cria objeto TReport³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oReport  := TReport():New( cReport, cTitulo , cPerg , { |oReport| ReportPrint( oReport , cAlias ) } , cDescri )

oReport:SetLandscape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria seção do Relatório³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oSection := TRSection():New( oReport, "Campos do relatorio" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Define células que serão pré carregadas na impressão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


TRCell():New( oSection, "USER_INC" , cAlias ,  'Usuario Inclusao' , "@!" , 20 ,, { || UsrRetName( SubStr( Embaralha( ( cAlias )->CT2_USERGI , 1 ) , 3 , 6 ) ) } )
For nFields := 1 To Len( aFieldsReport )
	TRCell():New( oSection, aFieldsReport[ nFields ] , cAlias )
Next


oReport:PrintDialog()


RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 05/2015
Objetivo.....: Funcao executada no botão OK na tela de parametrização ( impressão )
Cliente......: 
Observações..:
Alterações...:
*/
*---------------------------------------------------------*
Static Function ReportPrint( oReport , cAlias )
*---------------------------------------------------------*
Local oSection := oReport:Section( 1 ) 
Local cWhere 
Local cQuery
Local cCampos  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega perguntas do SX1 sem tela para o usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte( cPerg , .F. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Inicio Execução da Query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      

Aeval( aFieldsReport , { | x , y | cCampos += "," + x } )

cQuery := "SELECT CT2_USERGI,CT2_USERGA" + cCampos 
cQuery += " FROM " + RetSqlName( 'CT2' )                   
cQuery += " WHERE D_E_L_E_T_ = '' AND CT2_DATA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "' "
cQuery += "ORDER BY CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC"


TCQuery cQuery ALIAS ( cAlias ) NEW 

TCSetField( cAlias , 'CT2_DATA' , 'D' , 8 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                     ³Imprime relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O método 'Print()' se encarrega de efetuar a impressão do relatório, ³
//³controle de linhas, salto de pagina ...                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection:cAlias := cAlias
oSection:Print()

( cAlias )->( DbCloseArea() )

Return

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1( cPerg )
*-------------------------------------------------*

PutSx1(  cPerg ,'01' , 'Data Inicial' ,'Data Inicial'/*cPerSpa*/,'Data Inicial'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
PutSx1(  cPerg ,'02' , 'Data Final' ,'Data Final'/*cPerSpa*/,'Data Final'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )   
	
PutHelp("P." + Alltrim( cPerg ) + "01.",{ "Data Inicial do Lancamento Contabil." } ,{},{},.T.)
PutHelp("P." + Alltrim( cPerg ) + "02.",{ "Data Final do Lancamento Contabil." } ,{},{},.T.)

Return