#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função................: GTCORP96
Objetivo..............: Gerar Relatorio de Despesas em Propostas
Autor.................: Leandro Diniz de Brito ( LDB ) - BRL Consulting
Data..................: 15/06/2015
Observações...........:
Alterações............:
*/                     

*-------------------------------------------*           
User Function GTCORP96                                 
*-------------------------------------------*           
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatório exibe as despesas cadastradas nas propostas da divisão ATA ."
Local   cReport   := "GTCORP96"

Local   cTitulo   := "Relatorio de Despesas - Em Propostas"
Local   oSection

Local   cAlias    := GetNextAlias()

Private cPerg     := PADR( cReport , Len( SX1->X1_GRUPO ) )


If !( cEmpAnt $ 'ZB,ZF' )
	MsgStop( 'Empresa não permitida para executar este relatório.' )
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

TRCell():New( oSection, "Z55_NUM"       , cAlias , )
TRCell():New( oSection, "Z55_REVISA"    , cAlias , )
TRCell():New( oSection, "Z55_TPCTR "    , cAlias , )
TRCell():New( oSection, "Z55_CLIENT"    , cAlias , )
TRCell():New( oSection, "Z55_LOJA"      , cAlias , )
TRCell():New( oSection, "A1_NOME"       , cAlias , 'Cliente' )
TRCell():New( oSection, "A1_CGC"        , cAlias , 'CNPJ_Cliente' )
TRCell():New( oSection, "A1_NOME"       , cAlias , 'Nome_Cli' )
TRCell():New( oSection, "SOCIO"         , cAlias , 'Socio'  )
TRCell():New( oSection, "GERENTE"       , cAlias , 'Gerente' )
TRCell():New( oSection, "Z52_ITEM"      , cAlias ,  )
TRCell():New( oSection, "Z52_DESCDE"    , cAlias ,  )
TRCell():New( oSection, "Z52_DEREEM"    , cAlias ,  )

oReport:PrintDialog()


RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 06/2015
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosL¿
//Inicio Execução da Query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄntosLÙ
cQuery := "SELECT Z55_FILIAL,Z55_NUM,Z55_REVISA,Z55_TPCTR,Z55_CLIENT,Z55_LOJA,A1_NOME,A1_CGC,Z42A.Z42_NOMEFU 'SOCIO',Z42B.Z42_NOMEFU 'GERENTE',Z52_ITEM,Z52_DESCDE,Z52_DEREEM "
cQuery += "FROM " + RetSqlName( 'Z55') + " Z55 INNER JOIN " + RetSqlName( 'Z52') + " Z52 ON " 
cQuery += "Z55_FILIAL = Z52_FILIAL AND "
cQuery += "Z55_NUM = Z52_NUMPRO AND " 
cQuery += "Z55_REVISA = Z52_REVISA " 
cQuery += "INNER JOIN " + RetSqlName( 'SA1') + " A1 ON "
cQuery += "A1_FILIAL = '' AND "
cQuery += "Z55_CLIENT = A1_COD AND "
cQuery += "Z55_LOJA = A1_LOJA INNER JOIN " + RetSqlName( 'Z42') + " Z42A ON "
cQuery += "Z42A.Z42_FILIAL = '' AND "
cQuery += "Z42A.Z42_CPF = Z55_SOCIO INNER JOIN " + RetSqlName( 'Z42') + " Z42B ON "
cQuery += "Z42B.Z42_FILIAL = '' AND " 
cQuery += "Z42B.Z42_CPF = Z55_GERENT "
cQuery += "WHERE A1.D_E_L_E_T_ = '' AND " 
cQuery += "Z55.D_E_L_E_T_ = '' AND " 
cQuery += "Z52.D_E_L_E_T_ = '' AND "  
cQuery += "Z42A.D_E_L_E_T_ = ''  AND " 
cQuery += "Z42B.D_E_L_E_T_ = ''   AND " 
cQuery += "Z55_STATUS = 'E' " 

If !Empty( MV_PAR01 )
	cQuery += " AND Z55_NUM = '" + MV_PAR01 + "' "
EndIf

If !Empty( MV_PAR02 )
	cQuery += " AND Z55_CLIENT = '" + MV_PAR02 + "' AND Z55_LOJA = '" + MV_PAR03 + "' "
EndIf 

If ( MV_PAR04 > 1 )
	cQuery += " AND Z52_DEREEM = " + If( MV_PAR04 == 2 , "'1'" , "'2'" ) 
EndIf


TCQuery cQuery ALIAS ( cAlias ) NEW 


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

PutSx1(  cPerg ,'01' , 'Proposta' ,'Proposta'/*cPerSpa*/,'Proposta'/*cPerEng*/,'mv_ch1','C' , Len( Z55->Z55_NUM ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,'u_GT96VGet()'/*cValid*/, 'Z55GAN' /*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
PutSx1(  cPerg ,'02' , 'Cliente' ,'Cliente'/*cPerSpa*/,'Cliente'/*cPerEng*/,'mv_ch2','C' , Len( SA1->A1_COD ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,'u_GT96VGet()'/*cValid*/, 'SA1'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
PutSx1(  cPerg ,'03' , 'Loja' ,'Loja'/*cPerSpa*/,'Loja'/*cPerEng*/,'mv_ch3','C' , Len( SA1->A1_LOJA ) ,0 ,0/*nPresel*/,'G'/*cGSC*/,'u_GT96VGet()'/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
PutSx1(  cPerg ,'04' , 'Tipo da Despesa' ,'Tipo da Despesa'/*cPerSpa*/,'Tipo da Despesa'/*cPerEng*/,'mv_ch4','N' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,'Todos'/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/, 'Reembolsavel'	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,'Nao-Reembolsavel'/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )   
	
PutHelp("P." + Alltrim( cPerg ) + "01.",{ "Numero da Proposta." , "**(Vazio) sairá todos **" } ,{},{},.T.)
PutHelp("P." + Alltrim( cPerg ) + "02.",{ "Codigo do Cliente ." , "**(Vazio) sairá todos **" } ,{},{},.T.)

Return


/*
Função..........: GT96VGet
Objetivo........: Validar parametros de entrada
Autor...........: Leandro Diniz de Brito ( LDB )
*/                                             
*-------------------------------------------------*
User Function GT96VGet                                                  
*-------------------------------------------------*
Local cOrigem := AllTrim( ReadVar() )


If ( cOrigem == 'MV_PAR01' ) .And. !Empty( MV_PAR01 )
	Z55->( DbSetOrder( 2 ) )
	If Z55->( !DbSeek( xFilial() + MV_PAR01 ) )
		MsgStop( 'Numero Proposta Invalido!' )
		Return( .F. )
	EndIf
EndIf

If ( cOrigem == 'MV_PAR02' ) .And. !Empty( MV_PAR02 )
	SA1->( DbSetOrder( 1 ) )
	If SA1->( !DbSeek( xFilial() + MV_PAR02 + MV_PAR03 ) )
		MsgStop( 'Cliente+Loja Invalido!' )
		Return( .F. )
	EndIf
EndIf 

If ( cOrigem == 'MV_PAR03' ) .And. ( !Empty( MV_PAR02 ) .Or. !Empty( MV_PAR03 ) )
	SA1->( DbSetOrder( 1 ) )
	If SA1->( !DbSeek( xFilial() + MV_PAR02 + MV_PAR03 ) )
		MsgStop( 'Cliente+Loja Invalido!' )
		Return( .F. )
	EndIf
EndIf

Return( .T. )