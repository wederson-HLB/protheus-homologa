#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função..........: LWFIS001
Objetivo........: Relação de ICMS
Autor...........: Leandro Diniz de Brito - BRL Consulting
Data............: 13/02/2015
*/                          
*-------------------------------------------*
User Function LWFIS001                                             
*-------------------------------------------*
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatório imprime a Relação de ICMS de acordo com o periodo informado."
Local   cReport   := "LWFIS001"

Local   cTitulo   := "Relatorio de ICMS"
Local   oSection

Local   cAlias    := GetNextAlias()

Private cPerg     := PADR( cReport , Len( SX1->X1_GRUPO ) )


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

TRCell():New( oSection, "M0_CODFIL" , cAlias ,  'Filial'    )
TRCell():New( oSection, "ORIGEM"    , cAlias ,  'Origem'     )
TRCell():New( oSection, "M0_CGC"    , cAlias ,  'CNPJ'         )
TRCell():New( oSection, "F3_ESTADO" , cAlias ,  'Destino'    )
TRCell():New( oSection, "A2_CGC"    , cAlias ,  'CNPJ_Forn'    )
TRCell():New( oSection, "A2_NOME"   , cAlias ,  'Nome_Forn'    )
TRCell():New( oSection, "A1_CGC"    , cAlias ,  'CNPJ_Cli'    )
TRCell():New( oSection, "A1_NOME"   , cAlias ,  'Nome_Cli'    )
TRCell():New( oSection, "F3_NFISCAL" , cAlias , )
TRCell():New( oSection, "F3_SERIE"   , cAlias ,  )
TRCell():New( oSection, "F3_ESPECIE"   , cAlias ,  )
TRCell():New( oSection, "F3_EMISSAO"   , cAlias ,  )
TRCell():New( oSection, "F3_ENTRADA"   , cAlias ,  )
TRCell():New( oSection, "F3_ALIQICM"   , cAlias ,  )
TRCell():New( oSection, "F3_VALCONT"   , cAlias ,  )
TRCell():New( oSection, "F3_BASEICM"   , cAlias ,  )
TRCell():New( oSection, "F3_VALICM"   , cAlias ,  )
TRCell():New( oSection, "ESTORNO"   , cAlias ,  )
TRCell():New( oSection, "F3_CFO"   , cAlias ,  )
TRCell():New( oSection, "F3_OBSERV"   , cAlias ,  )

oReport:PrintDialog()


RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 02/2015
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega perguntas do SX1 sem tela para o usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte( cPerg , .F. )

/*
If Empty( MV_PAR01 )
	MsgStop( 'CFOP obrigatório nos parametros do relatorio.' )
	Return
EndIf
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosL¿
//Inicio Execução da Query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosLÙ
cQuery := "SELECT M0_CODFIL,M0_ESTCOB AS 'ORIGEM',M0_CGC,F3_ESTADO,A2_CGC,A2_NOME,A1_CGC,A1_NOME,"
cQuery += "F3_NFISCAL,F3_SERIE,F3_ESPECIE,F3_EMISSAO,F3_ENTRADA,F3_ALIQICM,F3_VALCONT,F3_BASEICM,F3_VALICM,F3_VALICM/2 AS 'ESTORNO',F3_CFO, F3_OBSERV"
cQuery +=	" FROM " + RetSqlName( 'SF3' ) + " F3"
cQuery +=	" LEFT JOIN SIGAMAT ON M0_CODIGO='" + cEmpAnt + "' AND F3_FILIAL=M0_CODFIL"
cQuery +=	" LEFT JOIN " + RetSqlName( 'SA2' ) + " SA2 ON A2_COD=F3_CLIEFOR  AND A2_LOJA = F3_LOJA AND SA2.D_E_L_E_T_=''"
cQuery +=	" LEFT JOIN " + RetSqlName( 'SA1' ) + " SA1 ON A1_COD=F3_CLIEFOR  AND A1_LOJA = F3_LOJA AND SA1.D_E_L_E_T_=''"
//cQuery +=	" WHERE F3.D_E_L_E_T_ = '' AND F3_CFO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQuery +=	" WHERE F3.D_E_L_E_T_ = '' "

If !Empty( MV_PAR01 )
	cQuery += " AND F3_CFO IN " + FormatIn( AllTrim( MV_PAR01 ) , ";" )
EndIf

cQuery +=	" AND F3_ENTRADA BETWEEN '" + DtoS( MV_PAR02 ) + "' AND '" + DtoS( MV_PAR03 ) + "'"


TCQuery cQuery ALIAS ( cAlias ) NEW 

TCSetField( cAlias , 'F3_EMISSAO' , 'D' , 8 , 0 )
TCSetField( cAlias , 'F3_ENTRADA' , 'D' , 8 , 0 )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                     ³Imprime relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//TRPosition():New( oSection , "SF3" , 1 , { || xFilial( 'SB1' ) + ( cAlias )->D3_COD } )
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

U_PUTSX1(  cPerg ,'01' , 'CFO ?' ,'CFO ?'/*cPerSpa*/,'CFO ?'/*cPerEng*/,'mv_ch1','C' , 80 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
//PUTSX1(  cPerg ,'02' , 'Ao CFO' ,'Ao CFO'/*cPerSpa*/,'Ao CFO'/*cPerEng*/,'mv_ch2','C' ,Len( SF3->F3_CFO ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )   
U_PUTSX1(  cPerg ,'02' , 'Da Dt.Entrada' ,'Da Dt.Entrada'/*cPerSpa*/,'Da Dt.Entrada'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1(  cPerg ,'03' , 'Ate Dt.Entrada' ,'Ate Dt.Entrada'/*cPerSpa*/,'Ate Dt.Entrada'/*cPerEng*/,'mv_ch3','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )   
	
U_PUTHELP("P." + Alltrim( cPerg ) + "01.",{ "CFOPs separados por ponto-virgula." , "**(Vazio) sairá todos **" } ,{},{},.T.)

Return
