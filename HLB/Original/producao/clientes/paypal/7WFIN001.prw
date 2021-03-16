#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Fun��o..........: 7WFIN001
Objetivo........: Rela��o de Titulos a Pagar
Autor...........: Leandro Diniz de Brito - BRL Consulting
Data............: 17/04/2015
*/                          
*-------------------------------------------*
User Function 7WFIN001                                             
*-------------------------------------------*
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatorio imprime a Relatorio de Titulos a Pagar de acordo com o periodo informado."
Local   cReport   := "7WFIN001"

Local   cTitulo   := "Relatorio de Titulos a Pagar"
Local   oSection

Local   cAlias    := GetNextAlias()
Local   aFieldsReport

Private cPerg     := PADR( cReport , Len( SX1->X1_GRUPO ) )


AjusSx1( cPerg )

//���������������������
//� Cria objeto TReport�
//���������������������
oReport  := TReport():New( cReport, cTitulo , cPerg , { |oReport| ReportPrint( oReport , cAlias ) } , cDescri )

oReport:SetLandscape()

//������������������������
//�Cria se��o do Relat�rio�
//������������������������
oSection := TRSection():New( oReport, "Campos do relatorio" )

//��������������������������������������������������������������������������������������Ŀ
//�              Define c�lulas que ser�o pr� carregadas na impress�o�
//����������������������������������������������������������������������������������������

aFieldsReport := { "E2_PREFIXO" , "E2_NUM" , "E2_PARCELA" , "E2_TIPO" , "E2_FORNECE" , "E2_LOJA" , "E2_NOMFOR" , "E2_VALOR" , "E2_SALDO" , "E2_EMISSAO" , ;
					"E2_VENCREA" , "E2_BAIXA" , "E2_ISS" , "E2_IRRF" , "E2_INSS" , "E2_PIS" , "E2_COFINS" , "E2_HIST" , "E2_MULTA" , "E2_JUROS" , "E2_DESCONT" }

For nFields := 1 To Len( aFieldsReport )
	TRCell():New( oSection, aFieldsReport[ nFields ] , cAlias )
Next

If GetNewPar( "MV_CTLIPAG" , .F. )
	TRCell():New( oSection, "LIBERACAO" , cAlias ,  'Liberacao' , "@!" , 20 ,, { || If( Empty( ( cAlias )->E2_DATALIB ) .And. Empty( ( cAlias )->E2_BAIXA ) , 'Nao Autorizado' , 'Autorizado' ) } )
EndIf                                                                                                                                                

TRCell():New( oSection, "STATUS" , cAlias ,  'Status' , "@!" , 20 ,, { || If( ( cAlias )->E2_SALDO == ( cAlias )->E2_VALOR .And. Empty( ( cAlias )->E2_BAIXA ) , 'Aberto' ,;
																		 If( ( cAlias )->E2_SALDO == 0 .And. !Empty( ( cAlias )->E2_BAIXA ) , 'Baixado' ,;
																		If( ( cAlias )->E2_SALDO > 0 .And. ( cAlias )->E2_SALDO <> ( cAlias )->E2_VALOR , 'Parcial' , "" ) ) ) } )
																		

oReport:PrintDialog()


RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 04/2015
Objetivo.....: Funcao executada no bot�o OK na tela de parametriza��o ( impress�o )
Cliente......: 
Observa��es..:
Altera��es...:
*/
*---------------------------------------------------------*
Static Function ReportPrint( oReport , cAlias )
*---------------------------------------------------------*
Local oSection := oReport:Section( 1 ) 
Local cWhere 
Local cQuery


//�������������������������������������������������Ŀ
//�Carrega perguntas do SX1 sem tela para o usuario.�
//���������������������������������������������������
Pergunte( cPerg , .F. )


//������������������������������������������������������������
//Inicio Execu��o da Query
//������������������������������������������������������������
cQuery := "SELECT * FROM " + RetSqlName( 'SE2' ) + " WHERE D_E_L_E_T_ = '' AND E2_FILIAL = '" + xFilial( 'SE2' ) + "' AND "
cQuery += "E2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "' AND "
cQuery += "E2_VENCREA BETWEEN '" + DtoS( MV_PAR03 ) + "' AND '" + DtoS( MV_PAR04 ) + "' "
cQuery += "ORDER BY E2_EMISSAO"


TCQuery cQuery ALIAS ( cAlias ) NEW 

For i := 1 To SE2->( FCount() )
	If ValType( SE2->( FieldGet( i ) ) ) == 'D'  
		TCSetField( cAlias , SE2->( FieldName( i ) ) , 'D' , 8 )
	EndIf
Next

//�����������������������������������������������������������Ŀ
//                     �Imprime relatorio�
//�������������������������������������������������������������
TRPosition():New( oSection , "SE2" , 1 , { || xFilial( 'SE2' ) + ( cAlias )->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ) } )

//����������������������������������������������������������������������Ŀ
//�O m�todo 'Print()' se encarrega de efetuar a impress�o do relat�rio, �
//�controle de linhas, salto de pagina ...                       �
//������������������������������������������������������������������������

oSection:cAlias := cAlias
oSection:Print()

( cAlias )->( DbCloseArea() )

Return

/*
Fun��o..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1( cPerg )
*-------------------------------------------------*

U_PUTSX1(  cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1(  cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )  
U_PUTSX1(  cPerg ,'03' , 'Do Vencimento' ,'Do Vencimento'/*cPerSpa*/,'Do Vencimento'/*cPerEng*/,'mv_ch3','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1(  cPerg ,'04' , 'Ate Vencimento' ,'Ate Vencimento'/*cPerSpa*/,'Ate Vencimento'/*cPerEng*/,'mv_ch4','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )  

/*	
PutHelp("P." + Alltrim( cPerg ) + "01.",{ "" , "" } ,{},{},.T.)
*/
Return
