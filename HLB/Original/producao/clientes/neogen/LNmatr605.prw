#INCLUDE "FIVEWIN.CH"
#INCLUDE "MATR605.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR605  ³ Autor ³ Marco Bianchi         ³ Data ³ 01/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡Æo de Or‡amentos de Venda                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function LNMATR605()

Local oReport
Local aAreaSCK  := SCK->(GetArea())

Private lFirst := .T.

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	MATR605R3()
EndIf

RestArea(aAreaSCK)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³01/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oOrcVendas

#IFDEF TOP
	Local cAliasSCK := cAliasSCJ := GetNextAlias()
#ELSE	
	Local cAliasSCK := "SCK"
	Local cAliasSCJ := "SCJ"
#ENDIF	

Local aOrd		:= {STR0027,STR0028,STR0029}	//"Numero"###"Cliente"###"Produto " 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("LNMATR605",STR0024,"LNMTR605", {|oReport| ReportPrint(oReport,cAliasSCK,cAliasSCJ,oOrcVendas)},STR0025 + " " + STR0026)	// "Relacao dos Orcamentos de Venda"###"Este relatorio irá imprimir a relaçäo dos Orçamentos de Venda"###"conforme os parametros solicitados.                          "
oReport:SetLandscape(.T.) 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Secao Principal
oOrcVendas := TRSection():New(oReport,STR0038,{"SCK","SCJ","SCL","SA1","SB1"},aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oOrcVendas:SetTotalInLine(.F.)
TRCell():New(oOrcVendas,"CK_NUM"			,"SCK",STR0030						,/*Picture*/						,/*Tamanho*/				,/*lPixel*/,{|| (cAliasSCK)->CK_NUM + "-" + (cAliasSCK)->CK_ITEM })
TRCell():New(oOrcVendas,"CK_CLIENTE"	,"SCK",RetTitle("CK_CLIENTE")	,/*Picture*/						,09							,/*lPixel*/,{|| (cAliasSCK)->CK_CLIENTE + "-" + (cAliasSCK)->CK_LOJA })
TRCell():New(oOrcVendas,"A1_NOME"		,"SA1",RetTitle("A1_NOME")		,PesqPict("SA1","A1_NOME")		,TamSX3("A1_NOME")[1]		,/*lPixel*/,{|| SA1->A1_NOME })
TRCell():New(oOrcVendas,"CJ_P_VEND"		,"SCJ",RetTitle("CJ_P_VEND")    ,PesqPict("SCJ","CJ_P_VEND")    ,TamSX3("CJ_P_VEND")[1]		,/*lPixel*/,{|| (cAliasSCJ)->CJ_P_VEND })
TRCell():New(oOrcVendas,"CJ_P_DESCV"    ,"SCJ",RetTitle("CJ_P_DESCV")   ,PesqPict("SCJ","CJ_P_DESCV")   ,TamSX3("CJ_P_DESCV")[1]    ,/*lPixel*/,{|| (cAliasSCJ)->CJ_P_DESCV })
TRCell():New(oOrcVendas,"CK_PRODUTO"	,"SCK",RetTitle("CK_PRODUTO")	,PesqPict("SCK","CK_PRODUTO")	,TamSX3("CK_PRODUTO")[1]	,/*lPixel*/,{|| (cAliasSCK)->CK_PRODUTO })
TRCell():New(oOrcVendas,"B1_DESC"		,"SB1",RetTitle("B1_DESC")		,PesqPict("SB1","B1_DESC")		,TamSX3("B1_DESC")[1]		,/*lPixel*/,{|| SB1->B1_DESC })
TRCell():New(oOrcVendas,"CK_QTDVEN"		,"SCK",RetTitle("CK_QTDVEN")	,PesqPict("SCK","CK_QTDVEN")	,TamSX3("CK_QTDVEN")[1]		,/*lPixel*/,{|| (cAliasSCK)->CK_QTDVEN })
TRCell():New(oOrcVendas,"CK_PRCVEN"		,"SCK",RetTitle("CK_PRCVEN")	,PesqPict("SCK","CK_PRCVEN")	,TamSX3("CK_PRCVEN")[1]		,/*lPixel*/,{|| xMoeda((cAliasSCK)->CK_PRCVEN,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO) })
TRCell():New(oOrcVendas,"CK_VALOR"		,"SCK",RetTitle("CK_VALOR")	    ,PesqPict("SCK","CK_VALOR")  	,TamSX3("CK_VALOR")[1]		,/*lPixel*/,{|| xMoeda((cAliasSCK)->CK_VALOR,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO) })
TRCell():New(oOrcVendas,"CL_PRODUTO"	,"SCL",STR0031					,PesqPict("SCL","CL_PRODUTO")	,TamSX3("CL_PRODUTO")[1]	,/*lPixel*/,{|| SCL->CL_PRODUTO })
TRCell():New(oOrcVendas,"CL_DESCRI"		,"SCL",STR0032					,PesqPict("SCL","CL_DESCRI")	,TamSX3("CL_DESCRI")[1]		,/*lPixel*/,{|| SCL->CL_DESCRI })
TRCell():New(oOrcVendas,"CL_QUANT"		,"SCL",STR0039   				,PesqPict("SCL","CL_QUANT") 	,TamSX3("CL_QUANT")[1]		,/*lPixel*/,{|| SCL->CL_QUANT })
TRCell():New(oOrcVendas,"CL_TOTAL"		,"SCL",STR0033              	,PesqPict("SCK","CK_VALOR")	    ,TamSX3("CK_VALOR")[1]		,/*lPixel*/,{|| SCL->CL_QUANT * (cAliasSCK)->CK_QTDVEN })
TRCell():New(oOrcVendas,"CJ_STATUS"		,"SCJ",RetTitle("CJ_STATUS")	,PesqPict("SCJ","CJ_STATUS")	,TamSX3("CJ_STATUS")[1]		,/*lPixel*/,{|| (cAliasSCJ)->CJ_STATUS })

TRFunction():New(oOrcVendas:Cell("CK_QTDVEN") ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| IIf(	lFirst,(cAliasSCK)->CK_QTDVEN,0) },.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oOrcVendas:Cell("CK_PRCVEN") ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| IIf(	lFirst,xMoeda((cAliasSCK)->CK_PRCVEN,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO),0) },.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oOrcVendas:Cell("CK_VALOR")  ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| IIf(	lFirst,xMoeda((cAliasSCK)->CK_VALOR,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO),0) },.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasSCK,cAliasSCJ,oOrcVendas)

Local lQuery 	:= .F.
Local cOrder	:= ""
Local cQuebra 	:= ""
Local cTotalText:= ""

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

If mv_par11 == 1
   TRFunction():New(oOrcVendas:Cell("CL_TOTAL") ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oReport:Section(1):GetOrder() == 1
	// por Numero
	cOrder := "%CK_NUM,CK_ITEM%"
	cTotalText:= STR0036
ElseIf oReport:Section(1):GetOrder() == 2
	// por Cliente
	cOrder := "%CK_CLIENTE,CK_LOJA,CK_NUM,CK_ITEM%"
	cTotalText:= STR0034	
Else
	// por Produto
	cOrder := "%CK_PRODUTO,CK_NUM,CK_ITEM%"
	cTotalText:= STR0037	
EndIf

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lQuery := .T.

	oReport:Section(1):BeginQuery()	
	BeginSql Alias cAliasSCK
	SELECT CJ_FILIAL, CJ_CLIENTE, CJ_P_VEND, CJ_P_DESCV, CJ_LOJA, CJ_EMISSAO, CJ_NUM, CJ_STATUS, CK_FILIAL, CK_NUM, CK_PRODUTO,
	CK_ITEM, CK_CLIENTE, CK_LOJA, CK_QTDVEN, CK_PRCVEN, CK_VALOR
	FROM %table:SCJ% SCJ, %table:SCK% SCK
	WHERE SCJ.CJ_FILIAL = %xFilial:SCJ%
		AND SCJ.CJ_CLIENTE >= %Exp:mv_par01% AND SCJ.CJ_CLIENTE <= %Exp:mv_par02%
		AND SCJ.CJ_P_VEND >= %Exp:mv_par14% AND SCJ.CJ_P_VEND <= %Exp:mv_par15%
		AND SCJ.CJ_EMISSAO >= %Exp:DtoS(mv_par03)% AND SCJ.CJ_EMISSAO <= %Exp:DtoS(mv_par04)%
		AND SCJ.CJ_NUM >= %Exp:mv_par05% AND SCJ.CJ_NUM <= %Exp:mv_par06%
		AND SCJ.%notdel% 
		AND SCK.CK_FILIAL = %xFilial:SCK%
		AND SCK.CK_PRODUTO >= %Exp:mv_par07% AND SCK.CK_PRODUTO <= %Exp:mv_par08%
		AND SCK.CK_NUM = SCJ.CJ_NUM
		AND SCK.%notdel% 		
		ORDER BY %Exp:cOrder%
		EndSql 
		oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

#ELSE

	dbSelectArea("SCK")
	dbSetOrder(oReport:Section(1):GetOrder())
    
	cCondicao := "" 
	cCondicao += "CK_FILIAL='"      + xFilial("SCK") + "'.AND."
	cCondicao += "CK_CLIENTE >='"   + mv_par01       + "'.AND."
	cCondicao += "CK_CLIENTE <='"   + mv_par02+"'.AND."	
	cCondicao += "CK_NUM >='"      	+ mv_par05+"'.AND."
	cCondicao += "CK_NUM <='"      	+ mv_par06+"'.AND."
	cCondicao += "CK_PRODUTO >='"   + mv_par07+"'.AND."
	cCondicao += "CK_PRODUTO <='"   + mv_par08+"'

	oReport:Section(1):SetFilter(cCondicao,SCK->(IndexKey()))

#ENDIF		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatório.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³				
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial("SA1") + (cAliasSCK)->CK_CLIENTE + (cAliasSCK)->CK_LOJA})
TRPosition():New(oReport:Section(1),"SB1",1,{|| xFilial("SB1") + (cAliasSCK)->CK_PRODUTO})
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Init()
oReport:SetMeter((cAliasSCK)->(LastRec()))
dbSelectArea(cAliasSCK)
While !oReport:Cancel() .And. !(cAliasSCK)->(Eof())

	#IFNDEF TOP
		dbSelectArea(cAliasSCJ)
		dbSetOrder(1)
		dbSeek(xFilial("SCJ") + (cAliasSCK)->CK_NUM)
		If (Found() .And. (CJ_EMISSAO < mv_par03 .Or. CJ_EMISSAO > mv_par04)) .Or. !Found()
			dbSelectArea(cAliasSCK)
			dbSkip()
			If oReport:Section(1):GetOrder() <> 1 
				C605Quebra(oReport,cQuebra,cAliasSCK,cTotalText)
			EndIf
			Loop
		EndIf  
	#ENDIF
	
	If (mv_par12 == 2 .And. (cAliasSCJ)->CJ_STATUS <> "A") .Or. (mv_par12 == 3 .And. (cAliasSCJ)->CJ_STATUS <> "B") .Or. (mv_par12 == 4 .And. (cAliasSCJ)->CJ_STATUS <> "C")
		dbSelectArea(cAliasSCK)
		dbSkip()     
		If oReport:Section(1):GetOrder() <> 1 		
			C605Quebra(oReport,cQuebra,cAliasSCK,cTotalText)
		EndIf	
		Loop
	EndIf
	If mv_par11 == 1					// Lista Componentes = Sim
		dbSelectArea("SCL")
		dbSetOrder(1)
		dbSeek(xFilial("SCL") + (cAliasSCK)->CK_NUM + (cAliasSCK)->CK_ITEM)		
		If Found()
		   	lFirst := .T.
			While !Eof() .And. CL_FILIAL == xFilial("SCL") .And. (cAliasSCK)->CK_NUM == CL_NUM .And. (cAliasSCK)->CK_ITEM == CL_ITEMORC

				If CL_PRODUTO < mv_par09 .Or. CL_PRODUTO > mv_par10
					dbSkip()
					Loop
				EndIf	
		
				If lFirst
					oReport:Section(1):Cell("CK_NUM"		):Show()
					oReport:Section(1):Cell("CK_CLIENTE"	):Show()
					oReport:Section(1):Cell("A1_NOME"		):Show()
					oReport:Section(1):Cell("CK_PRODUTO"	):Show()
					oReport:Section(1):Cell("B1_DESC"		):Show()
					oReport:Section(1):Cell("CK_QTDVEN"		):Show()
					oReport:Section(1):Cell("CK_PRCVEN"		):Show()
					oReport:Section(1):Cell("CK_VALOR"		):Show()
					oReport:Section(1):Cell("CL_PRODUTO"	):Show()
					oReport:Section(1):Cell("CL_DESCRI"		):Show()
					oReport:Section(1):Cell("CL_QUANT"		):Show()
					oReport:Section(1):Cell("CL_TOTAL"		):Show()
				Else
 					oReport:Section(1):Cell("CK_NUM"		):Hide()
					oReport:Section(1):Cell("CK_CLIENTE"	):Hide()
					oReport:Section(1):Cell("A1_NOME"		):Hide()
					oReport:Section(1):Cell("CK_PRODUTO"	):Hide()
					oReport:Section(1):Cell("B1_DESC"		):Hide()
					oReport:Section(1):Cell("CK_QTDVEN"		):Hide()
					oReport:Section(1):Cell("CK_PRCVEN"		):Hide()
					oReport:Section(1):Cell("CK_VALOR"		):Hide()
					oReport:Section(1):Cell("CL_PRODUTO"	):Show()
					oReport:Section(1):Cell("CL_DESCRI"		):Show()
					oReport:Section(1):Cell("CL_QUANT"		):Show()
					oReport:Section(1):Cell("CL_TOTAL"		):Show()
				EndIf
				oReport:Section(1):PrintLine()			
				
				If lFirst
				   lFirst := .F.
				EndIf
		
			   dbSelectArea("SCL")
			   dbSkip()
			EndDo
		Else 

			oReport:Section(1):Cell("CK_NUM"		):Show()
			oReport:Section(1):Cell("CK_CLIENTE"	):Show()
			oReport:Section(1):Cell("A1_NOME"		):Show()
			oReport:Section(1):Cell("CK_PRODUTO"	):Show()
			oReport:Section(1):Cell("B1_DESC"		):Show()
			oReport:Section(1):Cell("CK_QTDVEN"		):Show()
			oReport:Section(1):Cell("CK_PRCVEN"		):Show()
			oReport:Section(1):Cell("CK_VALOR"		):Show()
			oReport:Section(1):Cell("CL_PRODUTO"	):Show()
			oReport:Section(1):Cell("CL_DESCRI"		):Show()
			oReport:Section(1):Cell("CL_QUANT"		):Show()
			oReport:Section(1):Cell("CL_TOTAL"		):Show()
			
			oReport:Section(1):PrintLine()					
		EndIf
	Else
		oReport:Section(1):Cell("CK_NUM"):Show()
		oReport:Section(1):Cell("CK_CLIENTE"):Show()
		oReport:Section(1):Cell("A1_NOME"):Show()
		oReport:Section(1):Cell("CK_PRODUTO"):Show()
		oReport:Section(1):Cell("B1_DESC"):Show()
		oReport:Section(1):Cell("CK_QTDVEN"):Show()
		oReport:Section(1):Cell("CK_PRCVEN"):Show()
		oReport:Section(1):Cell("CK_VALOR"):Show()
		oReport:Section(1):Cell("CL_PRODUTO"):Hide()
		oReport:Section(1):Cell("CL_DESCRI"):Hide()
		oReport:Section(1):Cell("CL_QUANT"):Hide()
		oReport:Section(1):Cell("CL_TOTAL"):Hide()
		oReport:Section(1):PrintLine()			
	EndIf

	// Identifica quebra
	If oReport:Section(1):GetOrder() == 1 
		cQuebra := (cAliasSCK)->CK_NUM
	ElseIf oReport:Section(1):GetOrder() == 2
		cQuebra := (cAliasSCK)->CK_CLIENTE+(cAliasSCK)->CK_LOJA
	Else	
		cQuebra := (cAliasSCK)->CK_PRODUTO
	EndIf	

	dbSelectArea(cAliasSCK)
	dbSkip()
	
	// Impressao da Secao 2: Totalizadores da Secao
	If (oReport:Section(1):GetOrder() == 1 .And. cQuebra <> (cAliasSCK)->CK_NUM) .Or.;
		(oReport:Section(1):GetOrder() == 2 .And. cQuebra <> (cAliasSCK)->CK_CLIENTE+(cAliasSCK)->CK_LOJA) .Or.;
		(oReport:Section(1):GetOrder() == 3 .And. cQuebra <> (cAliasSCK)->CK_PRODUTO)
		
		oReport:Section(1):SetTotalText(cTotalText)
		oReport:Section(1):Finish()			
		oReport:Section(1):Init()			
		
	EndIf
	oReport:IncMeter()

EndDo

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C605Quebra³ Autor ³ Marco Bianchi         ³ Data ³07/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quebra do relatorio.                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function C605Quebra(oReport,cQuebra,cAliasSCK,cTotalText)
        
// Impressao da Secao 2: Totalizadores da Secao
If (oReport:Section(1):GetOrder() == 1 .And. cQuebra <> (cAliasSCK)->CK_NUM) .Or.;
	(oReport:Section(1):GetOrder() == 2 .And. cQuebra <> (cAliasSCK)->CK_CLIENTE+(cAliasSCK)->CK_LOJA) .Or.;
	(oReport:Section(1):GetOrder() == 3 .And. cQuebra <> (cAliasSCK)->CK_PRODUTO)
	
	oReport:Section(1):SetTotalText(cTotalText)
	oReport:Section(1):Finish()
	oReport:Section(1):Init()
EndIf
// Identifica quebra
If oReport:Section(1):GetOrder() == 1
	cQuebra := (cAliasSCK)->CK_NUM
ElseIf oReport:Section(1):GetOrder() == 2
	cQuebra := (cAliasSCK)->CK_CLIENTE+(cAliasSCK)->CK_LOJA
Else
	cQuebra := (cAliasSCK)->CK_PRODUTO
EndIf

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR605R3³ Autor ³ Eduardo Riera         ³ Data ³ 14.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡Æo de Or‡amentos de Venda                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR605()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MATR605R3()

Local wnrel
Private cString := "SCJ" 
Private Limite  := 220
Private Titulo  := OemToAnsi(STR0001) //"Relacao dos Orcamento de Venda"
PRIVATE cDesc1  := OemToAnsi(STR0002) //"Este relatorio ir  imprimir a rela‡„o dos Or‡amentos de Venda"
PRIVATE cDesc2  := OemToAnsi(STR0003) //"conforme os parametros solicitados.                          "	
PRIVATE cDesc3  := OemToAnsi("")

PRIVATE Tamanho  := "G"
PRIVATE aOrdem   := {STR0004,STR0005,STR0006} //"Numero"###"Cliente"###"Produto"
PRIVATE cPerg    := "LNMTR605"
PRIVATE aReturn  := { STR0007,1,STR0008, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nomeprog := "LNMATR605"
PRIVATE nLastKey := 0

m_pag := 01
wnrel := "LNMATR605"            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("LNMTR605",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                              ³
//³ mv_par01            // Cliente de  ?                              ³
//³ mv_par02            // Cliente ate ?                              ³   
//³ mv_par03            // Emissao de  ?                              ³
//³ mv_par04            // Emissao ate ?                              ³
//³ mv_par05            // Numero  de  ?                              ³
//³ mv_par06            // Numero  ate ?                              ³
//³ mv_par07            // Produto de  ?                              ³
//³ mv_par08            // Produto ate ?                              ³   
//³ mv_par09            // Componente de  ?                           ³   
//³ mv_par10            // Componente ate ?                           ³   
//³ mv_par11            // Lista Componente ( Sim/N„o ) ?             ³   
//³ mv_par12            // Lista Quais ? Todos/Aberto/Baixado/Cancel. ³   
//³ mv_par13            // Qual moeda  ?                              ³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrdem,.F.,Tamanho)
If nLastKey = 27
	dbSelectArea(cString)
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey = 27
	dbSelectArea(cString)
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C605Imp(@lEnd,wnRel,cString)})

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CA605Imp ³ Autor ³ Eduardo Riera         ³ Data ³ 14.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MTR605                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C605Imp(lEnd,wnRel,cString)
Local nCntFor    := 0 
Local lImprimiu  := .F.
Local cCabec1    := ""
Local cCabec2    := ""
Local cbCont     := 0
Local Li         := 80
Local aSituaca   := { STR0009,STR0010,STR0011,STR0022,STR0023,STR0040 } //" ABERTO "###"BAIXADO "###"CANCEL." //"N.ORCADO"###"APROVADO"###"BLOQUEADO"
Local aComponent := {}
Local aTotal     := { {  0 , 0 , 0 ,0 } ,{  0 , 0 , 0 ,0 } }
Local aQuebra    := { Nil }
Local bQuebra    := bCond := {|| Nil }
Local aTamSXG    := TamSXG("001")
Local aTamSXG2   := TamSXG("002")
Local aCoord, aTam

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Cabecalho                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Titulo  += " ( "+STR0014+aOrdem[aReturn[8]]+")" + " - " + GetMv( "MV_MOEDA" + Str(MV_PAR13, 1)) //"Ordem: " "Moeda"
If (aTamSXG[1] == aTamSXG[3]) .And. (aTamSXG2[1] == aTamSXG2[3])
	cCabec1 := STR0012	//"          CLIENTE                                  PRODUTO                                                                              COMPONENTES"
	cCabec2 := STR0013	//"NUMERO IT CODIGO LJ RAZAO SOCIAL                   CODIGO          DESCRICAO                      QUANTIDADE PRECO VENDA          TOTAL CODIGO          DESCRICAO                         QUANTIDADE    NECESSIDADE SITUACAO"
								// 999999-XX 999999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999.99 9999,999.99 999,999,999.99 XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999,999.99 999,999,999.99 XXXXXXXX
								//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
								// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	aCoord  := {00, 10, 20, 51, 67, 98, 109, 121, 136, 152, 183, 197, 212}
	aTam    := {30, 30, 30}
Else
	cCabec1 := STR0020	//"          CLIENTE                                            PRODUTO                                                                         COMPONENTES"
	cCabec2 := STR0021	//"NUMERO IT CODIGO-LOJA               RAZAO SOCIAL             CODIGO          DESCRICAO                 QUANTIDADE PRECO VENDA          TOTAL CODIGO          DESCRICAO                    QUANTIDADE    NECESSIDADE SITUACAO"
								// 999999-XX 999999xxxxxxxxxxxxxx-99xx XXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXX 999,999.99 9999,999.99 999,999,999.99 XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXX 99,999,999.99 999,999,999.99 XXXXXXXX
								//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
								// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	aCoord  := {00, 10, 36, 61, 77, 103, 114, 126, 141, 157, 183, 197, 212}
	aTam    := {24, 25, 25}
EndIf
dbSelectArea("SCK")
SetRegua(RecCount())

Do Case 
	Case aReturn[8] == 1
		dbSetOrder(1)
		dbSeek(xFilial()+MV_PAR05,.T.)
		bCond := {||!Eof() .And. xFilial("SCK") == SCK->CK_FILIAL .And. ;
						SCK->CK_NUM >= MV_PAR05 .And.;
						SCK->CK_NUM <= MV_PAR06 }
		bQuebra := {|| SCK->CK_NUM }
	Case aReturn[8] == 2
		dbSetOrder(2)
		dbSeek(xFilial()+MV_PAR01,.T.)
		bCond := {||!Eof() .And. xFilial("SCK") == SCK->CK_FILIAL .And. ;
						SCK->CK_CLIENTE >= MV_PAR01 .And.;
						SCK->CK_CLIENTE <= MV_PAR02 }
		bQuebra := {||SCK->CK_CLIENTE+SCK->CK_LOJA }
	Case aReturn[8] == 3
		dbSetOrder(3)
		dbSeek(xFilial()+MV_PAR07,.T.)
		bCond := {||!Eof() .And. xFilial("SCK") == SCK->CK_FILIAL .And. ;
						SCK->CK_PRODUTO >= MV_PAR07 .And.;
						SCK->CK_PRODUTO <= MV_PAR08 }
		bQuebra := {|| SCK->CK_PRODUTO }
EndCase                 

While ( Eval(bCond) )
	If lEnd
		@PROW()+1,001 PSAY STR0015 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Cabecalho do Or‡amento de Venda                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SCJ")
	dbSetOrder(1)
	dbSeek(xFilial()+SCK->CK_NUM)
	
	If (  SCK->CK_CLIENTE >= MV_PAR01 .And. SCK->CK_CLIENTE <= MV_PAR02 .And.;
			SCJ->CJ_EMISSAO >= MV_PAR03 .And. SCJ->CJ_EMISSAO <= MV_PAR04 .And.;
			SCK->CK_NUM     >= MV_PAR05 .And. SCK->CK_NUM     <= MV_PAR06 .And.;
			SCK->CK_PRODUTO >= MV_PAR07 .And. SCK->CK_PRODUTO <= MV_PAR08 .And.;
			If(MV_PAR12 == 2,SCJ->CJ_STATUS=="A",.T.)                     .And.;
			If(MV_PAR12 == 3,SCJ->CJ_STATUS=="B",.T.)                     .And.;
			If(MV_PAR12 == 4,SCJ->CJ_STATUS=="C",.T.) )
			
		lImprimiu := .T.
		If ( MV_PAR11 == 1 ) // Lista Componente
			aComponent := {}
			dbSelectArea("SCL")
			dbSetOrder(1)
			dbSeek(xFilial()+SCK->CK_NUM+SCK->CK_ITEM,.T.)

			While (  !Eof() .And. xFilial("SCL") == SCL->CL_FILIAL .And. ;
						SCL->CL_NUM     == SCK->CK_NUM .And.;
						SCL->CL_ITEMORC == SCK->CK_ITEM )
				If (  SCL->CL_PRODUTO >= MV_PAR09 .And.;
						SCL->CL_PRODUTO <= MV_PAR10 )
					aadd(aComponent,{ SCL->CL_PRODUTO ,;
											SubStr(SCL->CL_DESCRI,1,30),;
											SCL->CL_QUANT ,;
											SCL->CL_QUANT * SCK->CK_QTDVEN })
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumulo Totais                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nCntFor := 1 To Len(aTotal)
						aTotal[nCntFor,4] += (SCL->CL_QUANT*SCK->CK_QTDVEN)
					Next											
				EndIf
				dbSelectArea("SCL")
				dbSkip()
			EndDo                
		EndIf
		If ( li > 56 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)
			li++
		Endif
		If ( aQuebra[1] != Eval(bQuebra) )
			aQuebra[1] := Eval(bQuebra)
		EndIf			
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SCK->CK_CLIENTE+SCK->CK_LOJA)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SCK->CK_PRODUTO)
		
		@ li,aCoord[1] PSAY SCK->CK_NUM+"-"+SCK->CK_ITEM 
		@ li,aCoord[2] PSAY SCK->CK_CLIENTE+"-"+SCK->CK_LOJA
		@ li,aCoord[3] PSAY Left(SA1->A1_NOME, aTam[1])
		@ li,aCoord[4] PSAY SCK->CK_PRODUTO  
		@ li,aCoord[5] PSAY Left(SB1->B1_DESC, aTam[2])
		@ li,aCoord[6] PSAY SCK->CK_QTDVEN													PICTURE TM(SCK->CK_PRCVEN,10,2)
		@ li,aCoord[7] PSAY xMoeda(SCK->CK_PRCVEN,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO)	PICTURE TM(SCK->CK_PRCVEN,11,2)
		@ li,aCoord[8] PSAY xMoeda(SCK->CK_VALOR,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO)		PICTURE TM(SCK->CK_VALOR ,14,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumulo Totais                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nCntFor := 1 To Len(aTotal)
			aTotal[nCntFor,1] += SCK->CK_QTDVEN
			aTotal[nCntFor,2] +=xMoeda(SCK->CK_PRCVEN,SCJ->CJ_MOEDA,MV_PAR13,SCJ->CJ_EMISSAO)
			aTotal[nCntFor,3] +=xMoeda(SCK->CK_VALOR,SCJ->CJ_MOEDA, MV_PAR13,SCJ->CJ_EMISSAO)
		Next
		For nCntFor := 1 To Len(aComponent)
			@ li,aCoord[9]  PSAY aComponent[nCntFor,1] 
			@ li,aCoord[10] PSAY Left(aComponent[nCntFor,2], aTam[3])
			@ li,aCoord[11] PSAY aComponent[nCntFor,3] PICTURE TM(aComponent[nCntFor,3],13,2)
			@ li,aCoord[12] PSAY aComponent[nCntFor,4] PICTURE TM(aComponent[nCntFor,4],14,2)
			If ( nCntFor == 1 )
				@ li,aCoord[13] PSAY aSituaca[Asc(SCJ->CJ_STATUS)-64] 
			EndIf
			li++
			If ( li > 56 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)
				li++
			Endif
		Next
		If ( Len(aComponent) == 0 )
			@ li,aCoord[13] PSAY aSituaca[Asc(SCJ->CJ_STATUS)-64] 
			li++
		EndIf	
	EndIf
	dbSelectArea("SCK")
	dbSkip()
	IncRegua()
	If ( aQuebra[1] != Eval(bQuebra) .And. aTotal[2,1] > 0 )
		li++
		If ( aReturn[8] == 1 )
			@ li,000 PSAY STR0016 //"Total do Orcamento: "
		EndIf	
		If ( aReturn[8] == 2 )
			@ li,000 PSAY STR0017 //"Total do Cliente: "
		EndIf	
		If ( aReturn[8] == 3 )
			@ li,000 PSAY STR0018 //"Total do Produto: "
		EndIf			
		@ li,aCoord[6] PSAY aTotal[2,1]       PICTURE TM(aTotal[2,1],10,2)
		@ li,aCoord[7] PSAY aTotal[2,2]       PICTURE TM(aTotal[2,2],11,2)
		@ li,aCoord[8] PSAY aTotal[2,3]       PICTURE TM(aTotal[2,3],14,2)
		If ( MV_PAR11 == 1 )
			@ li,aCoord[12] PSAY aTotal[2,4]    PICTURE TM(aTotal[2,4],14,2)
		EndIf
		li++
		@ li,000 PSAY Repl("-",Limite)
		li++
		aTotal[2,1] := 0
		aTotal[2,2] := 0
		aTotal[2,3] := 0
		aTotal[2,4] := 0
	EndIf				
EndDo       
If lImprimiu
	li+=2
	@ li,000 PSAY STR0019 //"T O T A L  G E R A L --> "
	@ li,aCoord[6] PSAY aTotal[1,1]			PICTURE TM(aTotal[1,1],10,2)
	@ li,aCoord[7] PSAY aTotal[1,2]			PICTURE TM(aTotal[1,2],11,2)
	@ li,aCoord[8] PSAY aTotal[1,3]			PICTURE TM(aTotal[1,3],14,2)
	If ( MV_PAR11 == 1 )
		@ li,aCoord[12] PSAY aTotal[1,4]		PICTURE TM(aTotal[1,4],14,2)
	EndIf	
	Roda(CbCont,"",Tamanho)
EndIf

If ( aReturn[5] = 1 )
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)
