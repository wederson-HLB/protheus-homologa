#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTBAUD01  ºAutor  ³Rafael Rosa da Silvaº Data ³  07/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Usuários X Grupos							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GTBAUD01()

Local oReport				//Objeto do relatorio
Local cNomeprog	:= "GTBAUD01"
Local cPerg		:= "GTBAUD0101"
Local cTitulo	:= "Relatório de Usuários X Grupos"

ValidPerg(cPerg)

If Pergunte(cPerg,.T.)
	oReport := RunReport(cPerg,cNomeprog,cTitulo)
	oReport:PrintDialog()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunReport ºAutor  ³Rafael Rosa da Silvaº Data ³  07/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a estrutura do relatorio							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunReport(cPerg,cNomeprog,cTitulo)

Local oReport													// Objeto do relatorio
Local oSection1													// Objeto da secao 1
Local aOrdem	:= {}											// Ordens disponiveis para escolha do usuario

oReport := TReport():New(cNomeprog,cTitulo,cPerg,{|oReport| GTBAUDRpt(@oReport)},"Imprime o Relatório de Usuários X Grupos" )
oReport:SetLandscape()			//Define orientecao do relatorio como Paisagem 
oReport:nFontBody 	:= 5		//Define o tamanho da fonte do relatorio
oReport:lParamPage	:= .F.		//Nao imprime pafina de paramentros

oSection1 := TRSection():New(oReport,"Secao 1")	// Detalhes do Relatorio
TRCell():New(oSection1,"CODIGO"	,"","Código"		,"@!",6	)
TRCell():New(oSection1,"USUARIO","","Usuário"		,"@!",25)
TRCell():New(oSection1,"NOME"	,"","Nome Completo"	,"@!",40)
TRCell():New(oSection1,"USRBLQ"	,"","Usr Bloq"		,"@!",3	)
TRCell():New(oSection1,"EMAIL"	,"","E-Mail"		,"@!",50)
TRCell():New(oSection1,"DEPART"	,"","Departamento"	,"@!",40)
TRCell():New(oSection1,"CARGO"	,"","Cargo"			,"@!",40)
TRCell():New(oSection1,"GRUPO"	,"","Grupo"			,"@!",6	)
TRCell():New(oSection1,"NOMGRP"	,"","Nome do Grupo"	,"@!",30)
TRCell():New(oSection1,"PRIOR"	,"","Prioriza"		,"@!",3	)
TRCell():New(oSection1,"GRPBLQ"	,"","Grp Bloq"		,"@!",3	)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTBAUDRpt ºAutor  ³Rafael Rosa da Silvaº Data ³  07/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra as informacoes e monta os detalhes do relatorio	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GTBAUDRpt(oReport)

Local oSection	:= oReport:Section(1)		//Associa o Section1 com um objeto local
Local aUsers	:= AllUsers(.F.,.T.)		//Busca todos os usuarios
Local aGroups	:= {}						//Busca os dados do grupo do usuario
Local nI		:= 0						//contador
Local nY		:= 0						//Contador

For nI := 1 to Len(aUsers)
	If oReport:Cancel()
		Exit
	Endif

	oSection:Init()
	oReport:IncMeter()

	If Len(aUsers[nI][1][10]) > 0
		For nY := 1 to Len(aUsers[nI][1][10])
			If Alltrim(aUsers[nI][1][10][nY]) >= Alltrim(MV_PAR01) .And. Alltrim(aUsers[nI][1][10][nY]) <= Alltrim(MV_PAR02)
				aGroups := FWGrpParam(aUsers[nI][1][10][nY])
				oSection:Cell("CODIGO"	):SetBlock( { || Alltrim(aUsers[nI][1][01])				} )
				oSection:Cell("USUARIO"	):SetBlock( { || Alltrim(aUsers[nI][1][02])				} )
				oSection:Cell("NOME"	):SetBlock( { || Alltrim(aUsers[nI][1][04])				} )
				oSection:Cell("USRBLQ"	):SetBlock( { || IIF(aUsers[nI][1][17],"Sim","Não")		} )
				oSection:Cell("EMAIL"	):SetBlock( { || Alltrim(aUsers[nI][1][14])				} )
				oSection:Cell("DEPART"	):SetBlock( { || Alltrim(aUsers[nI][1][12])				} )
				oSection:Cell("CARGO"	):SetBlock( { || Alltrim(aUsers[nI][1][13])				} )
				oSection:Cell("GRUPO"	):SetBlock( { || Alltrim(aGroups[1][1])					} )
				oSection:Cell("NOMGRP"	):SetBlock( { || Alltrim(aGroups[1][2])					} )
				oSection:Cell("PRIOR"	):SetBlock( { || IIF(aUsers[nI][2][11],"Sim","Não")		} )
				oSection:Cell("GRPBLQ"	):SetBlock( { || IIF(aGroups[1][3] == "1","Sim","Não")	} )
				oSection:PrintLine()
			EndIf
		Next nY
	Else
		If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
			oSection:Cell("CODIGO"	):SetBlock( { || Alltrim(aUsers[nI][1][01])			} )
			oSection:Cell("USUARIO"	):SetBlock( { || Alltrim(aUsers[nI][1][02])			} )
			oSection:Cell("NOME"	):SetBlock( { || Alltrim(aUsers[nI][1][04])			} )
			oSection:Cell("USRBLQ"	):SetBlock( { || IIF(aUsers[nI][1][17],"Sim","Não")	} )
			oSection:Cell("EMAIL"	):SetBlock( { || Alltrim(aUsers[nI][1][14])			} )
			oSection:Cell("DEPART"	):SetBlock( { || Alltrim(aUsers[nI][1][12])			} )
			oSection:Cell("CARGO"	):SetBlock( { || Alltrim(aUsers[nI][1][13])			} )
			oSection:Cell("GRUPO"	):SetBlock( { || ""									} )
			oSection:Cell("NOMGRP"	):SetBlock( { || ""									} )
			oSection:Cell("PRIOR"	):SetBlock( { || IIF(aUsers[nI][2][11],"Sim","Não")	} )
			oSection:Cell("GRPBLQ"	):SetBlock( { || ""									} )
			oSection:PrintLine()
		EndIf
	EndIf
Next nI

oSection:Finish()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que cria o grupo de perguntas na tabela SX1		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eletrozema												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg(_cPerg)

Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }

//			  {X1_GRUPO	,X1_ORDEM,X1_PERGUNT			  ,X1_PERSPA			   ,X1_PERENG			  	,X1_VARIAVL	,X1_TIPO,X1_TAMANHO	,X1_DECIMAL	,X1_PRESEL	,X1_GSC	,X1_VALID,X1_VAR01  ,X1_DEF01,X1_DEFSPA1,X1_DEFENG1	,X1_CNT01,X1_VAR02	,X1_DEF02,X1_DEFSPA2,X1_DEFENG2	,X1_CNT02,X1_VAR03	,X1_DEF03,X1_DEFSPA3,X1_DEFENG3	,X1_CNT03,X1_VAR04,X1_DEF04	,X1_DEFSPA4	,X1_DEFENG4	,X1_CNT04,X1_VAR05,X1_DEF05	,X1_DEFSPA5	,X1_DEFENG5	,X1_CNT05,X1_F3	,X1_PYME,X1_GRPSXG	,X1_HELP,X1_PICTURE	,X1_IDFIL}
aAdd( aDados, {_cPerg	,'01'	 ,'Grupo de Usuário De: ?','Grupo de Usuário De: ?','Grupo de Usuário De: ?','MV_CH1'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR01',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GRP'	,''		,''			,''		,''			,''		 } )
aAdd( aDados, {_cPerg	,'02'	 ,'Grupo de Usuário Ate:?','Grupo de Usuário Ate:?','Grupo de Usuário Ate:?','MV_CH2'	,'C'	,6			,0			,2			,'G'	,''		 ,'MV_PAR02',''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''		,''		 ,''		,''			,''		 ,''	  ,''		,''			,''			,''		 ,''	  ,''		,''			,''			,''		 ,'GRP'	,''		,''			,''		,''			,''		 } )

//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

RestArea( aAreaDic )
RestArea( aArea )

Return