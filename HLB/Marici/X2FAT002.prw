//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 06/01/2021
//---------------------------------------------------------------------------------------------------------------------------------------------
// Faturamento - Relatório Pedidos à faturar
//---------------------------------------------------------------------------------------------------------------------------------------------

#include "PROTHEUS.CH"

User Function X2FAT002()

Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return

//--------------------------

Static Function ReportDef()

Local oReport
Local oCabec
Local oPedaFat
Local oTemp
Local cVends    := "" 
Local cItem     := "" 
Local cProduto  := "" 
Local cDescricao:= "" 
Local nTotLocal	:= 0
Local nQtdVen	:= 0
Local nQtdEnt	:= 0
Local nQtLib	:= 0
Local nQtBloq	:= 0
Local nValDesc	:= 0
Local nPrcVen	:= 0
//Local nImpLinha	:= 0
Local nTFat		:= 0
Local dEntreg	:= dDataBAse
Local cOP		:= ""
Local cDescTab	:= ""
Local nTamData  := Len(DTOC(MsDate()))
Local cAliasSC5  := ""
Local cAliasSC6  := "" 
Local cAliasSC9  := "" 
Local cAliasSF4  := ""
Local cTes       := ""
Local cTesDesc   := ""

cAliasSF4 := GetNextAlias()	
cAliasSC9 := cAliasSF4
cAliasSC6 := cAliasSC9
cAliasSC5 := cAliasSC6

oReport := TReport():New("X2FAT002","Relacao de Pedidos de Vendas","MTR700", {|oReport| ReportPrint(oReport,oCabec,oPedaFat,oTemp,cAliasSC5,cAliasSC6,cAliasSC9,cAliasSF4)},"Este programa ira emitir a relacao  dos Pedidos de Vendas" + " " + "Sera feita a pesquisa no armazem e verificado" + " " + "se a quantidade esta disponivel")	// #########
oReport:SetLandscape() 
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao de Cabecalho - Section(1)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCabec := TRSection():New(oReport,"Relacao de Pedidos de Vendas",{"SC6","SC5"},{"Pedido","Produto","Data de Entrega"},/*Campos do SX3*/,/*Campos do SIX*/)	// ######
oCabec:SetTotalInLine(.F.)
oCabec:SetReadOnly() 

TRCell():New(oCabec,"C5_NUM"		,/*Tabela*/,RetTitle("C5_NUM") 	     ,PesqPict("SC5","C5_NUM")		,TamSx3("C5_NUM"		)[1]	,/*lPixel*/,{|| SC5->C5_NUM														})
TRCell():New(oCabec,"C5_CLIENTE"	,/*Tabela*/,RetTitle("C5_CLIENTE")   ,PesqPict("SC5","C5_CLIENTE")	,16								,/*lPixel*/,{|| IIF( SC5->C5_TIPO$"BD","Fornecedor ","Cliente ") + SC5->C5_CLIENTE	})
TRCell():New(oCabec,"C5_LOJA"		,/*Tabela*/,RetTitle("C5_LOJACLI")	 ,PesqPict("SC5","C5_LOJACLI")	,TamSx3("C5_LOJACLI"	)[1]	,/*lPixel*/,{|| SC5->C5_LOJACLI 													})
TRCell():New(oCabec,"CNOME"		    ,/*Tabela*/,RetTitle("A1_NOME")	     ,PesqPict("SA1","A1_NOME")		,TamSx3("A1_NOME"		)[1]	,/*lPixel*/,{|| IIF(SC5->C5_TIPO$"BD",SA2->A2_NOME,SA1->A1_NOME) 				})
TRCell():New(oCabec,"CUF"		    ,/*Tabela*/,RetTitle("A1_EST")	     ,PesqPict("SA1","A1_EST")		,TamSx3("A1_EST"		)[1]	,/*lPixel*/,{|| IIF(SC5->C5_TIPO$"BD",SA2->A2_EST,SA1->A1_EST) 				})
TRCell():New(oCabec,"C5_EMISSAO"	,/*Tabela*/,RetTitle("C5_EMISSAO")	 ,PesqPict("SC5","C5_EMISSAO")	,nTamData    ,/*lPixel*/,{|| SC5->C5_EMISSAO},,,,,,.F.)
TRCell():New(oCabec,"C5_TRANS"	    ,/*Tabela*/,RetTitle("C5_TRANSP")	 ,PesqPict("SC5","C5_TRANSP")	,TamSx3("C5_TRANSP"	)[1]        ,/*lPixel*/,{|| SC5->C5_TRANSP														})
TRCell():New(oCabec,"C5_TPFRETE"    ,/*Tabela*/,RetTitle("C5_TPFRETE")	 ,PesqPict("SC5","C5_TPFRETE")	,25                             ,/*lPixel*/,{|| IIF(SC5->C5_TPFRETE=="C","CIF",IIF(SC5->C5_TPFRETE=="F","FOB",IIF(SC5->C5_TPFRETE=="T","Por conta de terceiros",IIF(SC5->C5_TPFRETE=="R","Por conta remetente",IIF(SC5->C5_TPFRETE=="D","Por conta destinatário","Sem frete")))))													})
TRCell():New(oCabec,"CVENDS"		,/*Tabela*/,RetTitle("C5_VEND1")	 ,PesqPict("SC5","C5_VEND1")	,34							    ,/*lPixel*/,{|| cVends																		})
TRCell():New(oCabec,"C5_CONDPAG"	,/*Tabela*/,RetTitle("C5_CONDPAG")	 ,PesqPict("SC5","C5_CONDPAG")	,TamSx3("C5_CONDPAG"	)[1]    ,/*lPixel*/,{|| SC5->C5_CONDPAG													})
TRCell():New(oCabec,"C5_XTIPO"	    ,/*Tabela*/,RetTitle("C5_XTIPO")	 ,PesqPict("SC5","C5_XTIPO")	,TamSx3("C5_XTIPO"	)[1]    ,/*lPixel*/,{|| IIF(SC5->C5_XTIPO=="1","Produto",IIF(SC5->C5_XTIPO=="2","Projeto",IIF(SC5->C5_XTIPO=="3","Garantia",IIF(SC5->C5_XTIPO=="4","Desenvolvimento","Doação"))))													})
TRCell():New(oCabec,"C5_XORDEM"	    ,/*Tabela*/,RetTitle("C5_XORDEM")	 ,PesqPict("SC5","C5_XORDEM")	,TamSx3("C5_XORDEM"	)[1]    ,/*lPixel*/,{|| SC5->C5_XORDEM													})

oReport:Section(1):SetLineStyle(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao de Itens - Section(1):Section(1)                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPedaFat := TRSection():New(oCabec,"Relacao de Pedidos de Vendas",{"SC6"},/**/,/*Campos do SX3*/,/*Campos do SIX*/)	// ###"Pedido""Produto"###"Data de Entrega"
oPedaFat:SetTotalInLine(.F.)
oPedaFat:SetReadOnly() 

TRCell():New(oPedaFat,"CTES"		,/*Tabela*/,"TES"					,PesqPict("SC6","C6_TES"		),TamSx3("C6_TES"		)[1],/*lPixel*/,{|| cTes 			})	// 
TRCell():New(oPedaFat,"CTESDESC"	,/*Tabela*/,"Finalidade"			,PesqPict("SF4","F4_TEXTO"		),TamSx3("F4_TEXTO"		)[1],/*lPixel*/,{|| cTesDesc		})	// 

TRCell():New(oPedaFat,"CITEM"		,/*Tabela*/,"IT"					,PesqPict("SC6","C6_ITEM"		),TamSx3("C6_ITEM"		)[1],/*lPixel*/,{|| cItem 				})	// 
TRCell():New(oPedaFat,"CPRODUTO"	,/*Tabela*/,RetTitle("C6_PRODUTO")	,PesqPict("SC6","C6_PRODUTO"	),TamSx3("C6_PRODUTO"	)[1],/*lPixel*/,{|| cProduto 			})	// Codigo do Produto
TRCell():New(oPedaFat,"CDESCRICAO"	,/*Tabela*/,RetTitle("C6_DESCRI")	,PesqPict("SC6","C6_DESCRI"		),30						 ,/*lPixel*/,{|| cDescricao 		})	// Descricao do Produto
TRCell():New(oPedaFat,"NTOTLOCAL"	,/*Tabela*/,"Estoque Disponivel"	,PesqPict("SB2","B2_QATU"		),TamSx3("B2_QATU"		)[1],/*lPixel*/,{|| nTotLocal 			},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NQTDVEN"		,/*Tabela*/,"Vendido"   			,PesqPict("SC6","C6_PRCVEN"		),TamSx3("C6_PRCVEN"	)[1],/*lPixel*/,{|| nQtdVen 			},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NQTDENT"		,/*Tabela*/,"Atendido"				,PesqPict("SC6","C6_PRCVEN"		),TamSx3("C6_PRCVEN"	)[1],/*lPixel*/,{|| nQtdEnt 			},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NSALDO"		,/*Tabela*/,"Saldo"					,PesqPict("SC6","C6_PRCVEN"		),TamSx3("C6_PRCVEN"	)[1],/*lPixel*/,{|| nQtdVen-nQtdEnt		},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NQTLIB"		,/*Tabela*/,RetTitle("C6_QTDLIB")	,PesqPict("SC6","C6_PRCVEN"		),TamSx3("C6_PRCVEN"	)[1],/*lPixel*/,{|| nQtLib				},,,"RIGHT")	// Quantidade Liberada
TRCell():New(oPedaFat,"NQTBLOQ"		,/*Tabela*/,"Qtd.Bloqueada"			,PesqPict("SC6","C6_PRCVEN"		),TamSx3("C6_PRCVEN"	)[1],/*lPixel*/,{|| nQtBloq				},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NVALDESC"	,/*Tabela*/,RetTitle("C6_VALDESC")	,PesqPict("SC6","C6_VALDESC"	),TamSx3("C6_VALDESC"	)[1],/*lPixel*/,{|| nValDesc			},,,"RIGHT")	// Valor do Desconto
TRCell():New(oPedaFat,"NPRCVEN"		,/*Tabela*/,RetTitle("C6_PRCVEN")	,PesqPict("SC6","C6_VALDESC"	),TamSx3("C6_VALDESC"		)[1] ,/*lPixel*/,{|| nPrcVen				},,,"RIGHT")	// Preco Unitario
//TRCell():New(oPedaFat,"NIMPLINHA"	,/*Tabela*/,"Impostos"				,PesqPict("SC6","C6_VALDESC"	),TamSx3("C6_VALDESC"		)[1],/*lPixel*/ ,{|| nImpLinha			},,,"RIGHT")	// 
TRCell():New(oPedaFat,"NTFAT"		,/*Tabela*/,"Valor a Entregar"		,PesqPict("SC6","C6_VALOR"		),TamSx3("C6_VALOR"		)[1],/*lPixel*/ ,{|| nTFat 				},,,"RIGHT")	// 

TRCell():New(oPedaFat,"NCOFINS" 	,/*Tabela*/,"Cofins"         	    ,PesqPict("SD2","D2_VALIMP5"	),TamSx3("D2_VALIMP5"	)[1],/*lPixel*/,{|| nCofins 		})	// Cofins
TRCell():New(oPedaFat,"NPIS" 	    ,/*Tabela*/,"Pis"         	        ,PesqPict("SD2","D2_VALIMP6"	),TamSx3("D2_VALIMP6"	)[1],/*lPixel*/,{|| nPis 			})	// Pis
TRCell():New(oPedaFat,"NICMS" 	    ,/*Tabela*/,"ICMS"         	        ,PesqPict("SD2","D2_VALICM"	    ),TamSx3("D2_VALICM"	)[1],/*lPixel*/,{|| nIcms 			})	// icms
TRCell():New(oPedaFat,"NIPI" 	    ,/*Tabela*/,"IPI"         	        ,PesqPict("SD2","D2_VALIPI"	    ),TamSx3("D2_VALIPI"	)[1],/*lPixel*/,{|| nIpi 			})	// icms
TRCell():New(oPedaFat,"NISS" 	    ,/*Tabela*/,"ISS"         	        ,PesqPict("SD2","D2_VALISS"	    ),TamSx3("D2_VALISS"	)[1],/*lPixel*/,{|| nIss 			})	// icms

TRCell():New(oPedaFat,"NLIQUIDO"    ,/*Tabela*/,"Líquido"               ,PesqPict("SD2","D2_TOTAL"	    ),TamSx3("D2_TOTAL"	    )[1],/*lPixel*/,{|| nLiquido 		})	// icms

TRCell():New(oPedaFat,"NCUSTO" 	    ,/*Tabela*/,"Custo"         	    ,PesqPict("SB2","B2_CM1"	    ),TamSx3("B2_CM1"	)[1],/*lPixel*/,{|| nCusto 			})	// Codigo do Produto
TRCell():New(oPedaFat,"CCLVL"  	    ,/*Tabela*/,RetTitle("C6_CLVL")	    ,PesqPict("SC6","C6_CLVL"	    ),TamSx3("C6_CLVL"	)[1],/*lPixel*/,{|| cCLVL 			})	// Codigo do Produto


// Quando nome da celular nao e do SX3 e o campo for do tipo Data, o tamanho deve ser preenchido com
// Len(DTOC(MsDate())), para que nao haja problema na utilizacao de ano com 4 digitos.
TRCell():New(oPedaFat,"DENTREG"		,/*Tabela*/,RetTitle("C6_ENTREG")	,PesqPict("SC6","C6_ENTREG"		),nTamData				      ,/*lPixel*/ ,{|| dEntreg			},,,,,,.F.)	// Data de Entrega
TRCell():New(oPedaFat,"CDESCTAB"	,/*Tabela*/,"Situacao do Pedido"	,								 ,28						 ,/*lPixel*/,{|| cOP+"-"+cDescTab	})	// 


TRFunction():New(oPedaFat:Cell("NQTDVEN"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NQTDENT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NSALDO"		),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NQTLIB"		),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NQTBLOQ"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NVALDESC"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NPRCVEN"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
//TRFunction():New(oPedaFat:Cell("NIMPLINHA"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oPedaFat:Cell("NTFAT"		),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a quebra de linha para impressao da descricao do produto            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Section(1):SetLineBreak()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho no top da pagina                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Section(1):SetHeaderPage()
                                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao temporaria para receber filtro da tabela SC9.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTemp := TRSection():New(oReport,"",{"SC9"},{"Todos Pedidos","Relacao de Pedidos de Vendas","Pedido"},/*Campos do SX3*/,/*Campos do SIX*/) // ######"Produto"###"Data de Entrega"
oTemp:SetTotalInLine(.F.)
oTemp:SetReadOnly()

oReport:Section(2):SetEdit(.F.)

Return(oReport)

//----------------------------------------------

Static Function ReportPrint(oReport,oCabec,oPedaFat,oTemp,cAliasSC5,cAliasSC6,cAliasSC9,cAliasSF4)

Local cWhere := ""

Local cDescOrdem := ""
Local cTipo  	 := ""
Local cPedido    := ""
Local cFilter    := ""
Local cKey 	     := ""
Local cCampo     := ""
Local cVends     := ""
Local cNumero    := ""
Local cLocal     := ""
Local cTes       := ""
Local dC5Emissao := dDataBase
Local nOrdem 	 := oReport:Section(1):GetOrder()
Local nX	 	 := 1
Local nQtBloq	 := 0
Local nItem      := 0    
Local nC5Moeda   := 0    
Local nPos       := 0
Local nPrunit    := 0
Local nVldesc    := 0
Local nValIPI    := 0 
Local nAcresFin  := 0
Local nPacresFin := 0
Local nQuant     := 0
Local nCusto     := 0
Local aQuant 	 := {}
Local aCampos	 := {}
Local aTam   	 := {}
Local aImpostos  := MaFisRelImp("MTR700",{"SC5","SC6"})
Local lContInt   := .T. 
Local lFiltro	 := .T.
Local lCabPed    := .T.
Local lBarra     := .F.
Local lImp 		 := .F.
Local cQueryAdd  := ""
Local cFilUsuSC5 := oReport:Section(1):GetSqlExp("SC5")
Local cFilUsuSC6 := oReport:Section(1):GetSqlExp("SC6")
Local cClvl      := ""
Local nCofins	 := 0	
Local nPis		 := 0	
Local nIcms		 := 0
Local nIpi		 := 0	
Local nIss		 := 0	
Local nLiquido	 := 0	
Local cTes       := ""
Local cTesDesc   := ""

Private oTempTable := Nil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetBlock: faz com que as variaveis locais possam ser                   ³
//³ utilizadas em outras funcoes nao precisando declara-las                ³
//³ como private.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):Cell("CVENDS"):SetBlock({|| cVends			})
oReport:Section(1):Section(1):Cell("CITEM"			):SetBlock({|| cItem			})
oReport:Section(1):Section(1):Cell("CPRODUTO"		):SetBlock({|| cProduto			})
oReport:Section(1):Section(1):Cell("CDESCRICAO"	):SetBlock({|| cDescricao		})
oReport:Section(1):Section(1):Cell("NTOTLOCAL"		):SetBlock({|| nTotLocal		})
oReport:Section(1):Section(1):Cell("NQTDVEN"		):SetBlock({|| nQtdVen			})
oReport:Section(1):Section(1):Cell("NQTDENT"		):SetBlock({|| nQtdEnt			})
oReport:Section(1):Section(1):Cell("NSALDO"		):SetBlock({|| nQtdVen-nQtdEnt	})
oReport:Section(1):Section(1):Cell("NQTLIB"		):SetBlock({|| nQtLib			})
oReport:Section(1):Section(1):Cell("NQTBLOQ"		):SetBlock({|| nQtBloq			})
oReport:Section(1):Section(1):Cell("NVALDESC"		):SetBlock({|| nValDesc			})
oReport:Section(1):Section(1):Cell("NPRCVEN"		):SetBlock({|| nPrcVen			})
oReport:Section(1):Section(1):Cell("CDESCTAB"		):SetBlock({|| cOP+"-"+cDescTab	})
//oReport:Section(1):Section(1):Cell("NIMPLINHA"		):SetBlock({|| nImpLinha		})
oReport:Section(1):Section(1):Cell("NTFAT"			):SetBlock({|| nTFat	})
oReport:Section(1):Section(1):Cell("DENTREG"		):SetBlock({|| dEntreg			})
oReport:Section(1):Section(1):Cell("CCLVL"		    ):SetBlock({|| cClvl			})
oReport:Section(1):Section(1):Cell("NCUSTO"		    ):SetBlock({|| nCusto			})

oReport:Section(1):Section(1):Cell("CTES" 	):SetBlock({|| cTes		})
oReport:Section(1):Section(1):Cell("CTESDESC" 	):SetBlock({|| cTesDesc		})

oReport:Section(1):Section(1):Cell("NCOFINS" 	):SetBlock({|| nCofins		})
oReport:Section(1):Section(1):Cell("NPIS" 	    ):SetBlock({|| nPis			})
oReport:Section(1):Section(1):Cell("NICMS" 	    ):SetBlock({|| nIcms		})
oReport:Section(1):Section(1):Cell("NIPI" 	    ):SetBlock({|| nIpi			})
oReport:Section(1):Section(1):Cell("NISS" 	    ):SetBlock({|| nIss			})
oReport:Section(1):Section(1):Cell("NLIQUIDO"   ):SetBlock({|| nLiquido		})


cVends 		:= ""
cItem      	:= "" 
cProduto   	:= "" 
cDescricao 	:= "" 
nTotLocal	:= 0
nQtdVen		:= 0
nQtdEnt		:= 0
nQtLib		:= 0
nQtBloq		:= 0
nValDesc	:= 0
nPrcVen		:= 0
cOP			:= ""
cDescTab	:= ""
//nImpLinha	:= 0
nTFat		:= 0
dEntreg		:= dDataBAse
cClvl       := ""
cTes        := ""
cTesDesc    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array com base no SB2 e Monta arquivo de trabalho     ³
//³ para baixar estoque na listagem.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("B2_LOCAL")
AADD(aCampos,{ "TB_LOCAL" ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B2_COD")
AADD(aCampos,{ "TB_COD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B2_QATU")
AADD(aCampos,{ "TB_SALDO" ,"N",aTam[1],aTam[2] } )

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New( "STR" )

//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aCampos )
                                                           
oTempTable:AddIndex("1",{"TB_LOCAL","TB_COD"})

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

dbSelectArea("SC6")
dbSetOrder(nOrdem) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                        Filtros do Relatorio                            ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQueryAdd := ""
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                                           ³
	//³ Montagem das variaveis da Query                                                           ³
	//³                                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhere := "%"
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Trata o Relacionamento com C9 conforme a opcao do MV_PAR06 -> "IMPRIMIR PEDIDOS ?" ³
    //³ "IMPRIMIR PEDIDOS ?"                                                               ³
    //³ MV_PAR06 == 1 -> Pedidos Aptos a Faturar com C9 liberado.                          ³
    //³ MV_PAR06 == 2 -> Pedidos Nao Aptos a Faturar com C9 bloqueado no Credito ou Estoque³
    //³ MV_PAR06 == 3 -> Todos - pedidos liberados e bloqueados do C9 + os C6 sem os C9    ³
    //³ para MV_PAR06 == 3 o relacionamento com C9 na Query e feito atraves de UNION.      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
	If mv_par06 == 1
		cWhere += "SC9.C9_BLEST = '" + space(TamSx3("C9_BLEST")[1]) + "' AND "
		cWhere += "SC9.C9_BLCRED = '" + space(TamSx3("C9_BLCRED")[1]) + "' AND "
		cWhere += "SC9.C9_QTDLIB > 0 AND "
	ElseIf mv_par06 == 2
		cWhere += "(SC9.C9_BLEST <> '" + space(TamSx3("C9_BLEST")[1]) + "' OR "
		cWhere += "SC9.C9_BLCRED <> '" + space(TamSx3("C9_BLCRED")[1]) + "') AND "
	EndIf
	If mv_par09 == 1
		cWhere += "SF4.F4_DUPLIC = 'S' AND "
	ElseIf mv_par09 == 2
		cWhere += "SF4.F4_DUPLIC <> 'S' AND "
	EndIf
		
	If !Empty(cFilUsuSC5)
		cWhere += " (" + cFilUsuSC5 + ") AND"
	EndIf
	If !Empty(cFilUsuSC6)
		cWhere += " (" + cFilUsuSC6 + ") AND"
	EndIf
	cWhere += "%"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATENCAO !!!! ao manipular os campos do SELECT ou a ordem da Clausula ORDER BY verificar   ³
	//³ a concordancia entre os mesmos !!!!!!!!!                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrdem = 1
		cDescOrdem:= "Pedido"
		cOrder := "%C5_FILIAL,C5_NUM,C6_ITEM%"
	ElseIf nOrdem = 2
		cDescOrdem:= "Produto"
		cOrder :="%C6_FILIAL,C6_PRODUTO,C6_NUM%"
	ELSE
		cDescOrdem:= "Data de Entrega"
		cOrder := "%C6_FILIAL,C6_ENTREG,C5_NUM,C6_ITEM%"
	EndIf
	
	If mv_par06 == 3
		cWhere2 := "%"
		If mv_par09 == 1
			cWhere2 += "SF4.F4_DUPLIC = 'S' AND "
		ElseIf mv_par09 == 2
			cWhere2 += "SF4.F4_DUPLIC <> 'S' AND "
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento do filtro do usuario por PE.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(cQueryAdd) == "C" .AND. !Empty(cQueryAdd)
			cWhere2 += " ( " + cQueryAdd + ") AND"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento do filtro do usuario por personalização.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFilUsuSC5)
			cWhere2 += " (" + cFilUsuSC5 + ") AND"
		EndIf
		If !Empty(cFilUsuSC6)
			cWhere2 += " (" + cFilUsuSC6 + ") AND"
		EndIf	
		cWhere2 += "%"
	EndIf	
		
    If mv_par06 == 3

    	oReport:Section(1):BeginQuery()
    	BeginSql Alias cAliasSC5
		SELECT
		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,
		SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_XTIPO,SC5.C5_XORDEM,
		SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,SC6.C6_CLVL,
		SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,
		SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,
		SUM(SC9.C9_QTDLIB) C9_QTDLIB,SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO,SC5.C5_ACRSFIN
		FROM %Table:SC5% SC5 ,%Table:SC6% SC6 ,%Table:SC9% SC9 ,%Table:SF4% SF4
		WHERE
			SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM >= %Exp:mv_par01% AND SC5.C5_NUM <= %Exp:mv_par02% AND
			SC5.%notdel% AND SC6.C6_FILIAL = %xFilial:SC6% AND SC6.C6_NUM   = SC5.C5_NUM AND
			SC6.C6_PRODUTO >= %Exp:mv_par03% AND
			SC6.C6_PRODUTO <= %Exp:mv_par04% AND
			SC6.C6_ENTREG  >= %Exp:dtos(mv_par10)% AND
			SC6.C6_ENTREG  <= %Exp:dtos(mv_par11)% AND
			SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ <> 'R ' AND SC6.%notdel% AND
			SC9.C9_FILIAL = %xFilial:SC9% AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC6.C6_ITEM = SC9.C9_ITEM AND
			SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.C9_NFISCAL = ' ' AND SC9.%notdel% AND
			SF4.F4_FILIAL = %xFilial:SF4% AND
			SC6.C6_TES = SF4.F4_CODIGO AND
			%Exp:cWhere%    				
			SF4.%notdel%
	    GROUP BY
			SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,
			SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_XTIPO,SC5.C5_XORDEM,
			SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,SC6.C6_CLVL,
			SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,
			SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,
			SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO,SC5.C5_ACRSFIN
			
		UNION
		
		SELECT
		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,
		SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_XTIPO,SC5.C5_XORDEM,
		SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,SC6.C6_CLVL,
		SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,
		' ' C9_FILIAL,' ' C9_PEDIDO,' ' C9_ITEM,' ' C9_NFISCAL,' ' C9_BLEST,' ' C9_BLCRED,' ' C9_PRODUTO,0 C9_QTDLIB,
		SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO,SC5.C5_ACRSFIN
		FROM	%Table:SC5% SC5 ,%Table:SC6% SC6, %Table:SF4% SF4
		WHERE
			SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM >= %Exp:mv_par01% AND SC5.C5_NUM <= %Exp:mv_par02% AND 
			SC5.%notdel% AND SC6.C6_FILIAL = %xFilial:SC6% AND SC6.C6_NUM = SC5.C5_NUM AND
			SC6.C6_PRODUTO >= %Exp:mv_par03% AND
			SC6.C6_PRODUTO <= %Exp:mv_par04% AND
			SC6.C6_ENTREG  >= %Exp:dtos(mv_par10)% AND
			SC6.C6_ENTREG  <= %Exp:dtos(mv_par11)% AND
			SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ <> 'R ' AND SC6.%notdel% AND
			SF4.F4_FILIAL = %xFilial:SF4% AND SC6.C6_TES = SF4.F4_CODIGO AND 
			NOT EXISTS (SELECT SC9.C9_PEDIDO FROM %Table:SC9% SC9
			WHERE
	    		SC9.C9_FILIAL = %xFilial:SC9% AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC6.C6_ITEM = SC9.C9_ITEM AND
	    		SC9.C9_NFISCAL = ' ' AND
	    		SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.%notdel%) AND
	    		%Exp:cWhere2%		    		
	    		SF4.%notdel%
  		ORDER BY %Exp:cOrder%
		EndSql
		oReport:Section(1):EndQuery()

    Else

    	oReport:Section(1):BeginQuery()
    	BeginSql Alias cAliasSC5
		SELECT
		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,
		SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_XTIPO,SC5.C5_XORDEM,
		SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,SC6.C6_CLVL,
		SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,
		SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,
		SUM(SC9.C9_QTDLIB) C9_QTDLIB,SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO,SC5.C5_ACRSFIN
		FROM %Table:SC5% SC5 ,%Table:SC6% SC6 ,%Table:SC9% SC9 ,%Table:SF4% SF4
		WHERE
			SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM >= %Exp:mv_par01% AND SC5.C5_NUM <= %Exp:mv_par02% AND
			SC5.%notdel% AND SC6.C6_FILIAL = %xFilial:SC6% AND SC6.C6_NUM = SC5.C5_NUM AND
			SC6.C6_PRODUTO >= %Exp:mv_par03% AND
			SC6.C6_PRODUTO <= %Exp:mv_par04% AND
			SC6.C6_ENTREG  >= %Exp:dtos(mv_par10)% AND
			SC6.C6_ENTREG  <= %Exp:dtos(mv_par11)% AND
			SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND SC6.C6_BLQ <> 'R ' AND SC6.%notdel% AND
			SC9.C9_FILIAL = %xFilial:SC9% AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC6.C6_ITEM = SC9.C9_ITEM AND
			SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.C9_NFISCAL = ' ' AND
			SC9.%notdel% AND
			SF4.F4_FILIAL = %xFilial:SF4% AND
			SC6.C6_TES = SF4.F4_CODIGO AND
			%Exp:cWhere%    				
			SF4.%notdel%
	    GROUP BY
			SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_EMISSAO,
			SC5.C5_CONDPAG,SC5.C5_MOEDA,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,SC5.C5_XTIPO,SC5.C5_XORDEM,
			SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_OP,SC6.C6_TES,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,SC6.C6_CLVL,
			SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_PRCVEN,SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_LOCAL,SC6.C6_QTDENT,SC6.C6_BLQ,
			SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_NFISCAL,SC9.C9_BLEST,SC9.C9_BLCRED,SC9.C9_PRODUTO,
			SF4.F4_FILIAL,SF4.F4_DUPLIC,SF4.F4_CODIGO,SC5.C5_ACRSFIN
		ORDER BY %Exp:cOrder%
		EndSql
		oReport:Section(1):EndQuery()
    
    EndIf

If MV_PAR06 == 1
	cTipo := " Aptos a Faturar "
ELSEIf MV_PAR06 == 2
	cTipo := " nao Liberados  "
ELSE
	cTipo := ""
EndIf

TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial()+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA })
TRPosition():New(oReport:Section(1),"SA2",1,{|| xFilial()+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA })
TRPosition():New(oReport:Section(1),"SC5",1,{|| xFilial()+(cAliasSC6)->C6_NUM})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera titulo do relatorio de acordo com parametros          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(oReport:Title() + " " + cTipo +  "Relacao de Pedidos de Vendas" + cDescOrdem + " - " + GetMv("MV_MOEDA"+STR(mv_par08,1)))		// ###

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                        I M P R E S S A O                               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea(cAliasSC6)
oReport:SetMeter(SC6->(RecCount()))
oReport:Section(1):Init()
oReport:Section(1):Section(1):Init()
While !oReport:Cancel() .AND. !( cAliasSC6 )->( Eof() ) .AND. (cAliasSC6)->C6_FILIAL == xFilial("SC6")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao dos filtros do usuario e Parametros  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasSC6 ) 
	lFiltro := IIf(!(ValidMasc((cAliasSC6)->C6_PRODUTO,MV_PAR05)),.F.,.T.)
	       
	If lFiltro
		
		dbSelectArea(cAliasSC6)
		cNumero    := (cAliasSC6)->C6_NUM
		cItem      := (cAliasSC6)->C6_ITEM
		cProduto   := (cAliasSC6)->C6_PRODUTO
		cDescricao := (cAliasSC6)->C6_DESCRI
		
		If mv_par14 == 2
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+(cAliasSC6)->C6_PRODUTO))
				cDescricao := SB1->B1_DESC
			EndIf
		EndIf

		cLocal     := (cAliasSC6)->C6_LOCAL
		cOp        := (cAliasSC6)->C6_OP
		cTes       := (cAliasSC6)->C6_TES
		nQtdven    := (cAliasSC6)->C6_QTDVEN
		nQtdent    := (cAliasSC6)->C6_QTDENT
		nPrunit    := (cAliasSC6)->C6_PRUNIT
		nPrcven    := (cAliasSC6)->C6_PRCVEN
		nVldesc    := (cAliasSC6)->C6_VALDESC
		dEntreg    := (cAliasSC6)->C6_ENTREG
		cClvl      := (cAliasSC6)->C6_CLVL
 		
		cTes      := (cAliasSC6)->C6_TES
		cTesDesc  := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_TEXTO") 

		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2")+(cAliasSC6)->C6_PRODUTO+(cAliasSC6)->C6_LOCAL ))
		   nCusto   := SB2->B2_CM1 * nQtdven
		EndIf   
		
		aQuant 	 := {}
		nPos := Ascan(aQuant, {|x|x[1]== (cAliasSC9)->C9_PRODUTO})
		If (cAliasSC9)->C9_BLEST == space(TamSx3("C9_BLEST")[1]).AND.(cAliasSC9)->C9_BLCRED == space(TamSx3("C9_BLCRED")[1]).AND.(cAliasSC9)->C9_QTDLIB > 0
			If mv_par06 <> 2
				If nPos != 0
					aQuant[nPos,2]+= (cAliasSC9)->C9_QTDLIB
				Else
					Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0})
				EndIf
			EndIf
		ElseIf (cAliasSC9)->C9_BLEST <> space(TamSx3("C9_BLEST")[1]).OR.(cAliasSC9)->C9_BLCRED <> space(TamSx3("C9_BLCRED")[1])
			If mv_par06 <> 1
				If nPos != 0
					aQuant[nPos,3]+= (cAliasSC9)->C9_QTDLIB
				Else
					Aadd(aQuant,{(cAliasSC9)->C9_PRODUTO,0,(cAliasSC9)->C9_QTDLIB})
				EndIf
			EndIf
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Varre o Array aQuant e alimenta as variaveis nQtLib e nQtBloq com o conteudo.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aQuant)
			If mv_par06 == 2 .AND. aQuant[1,2] > 0 .OR. mv_par06 == 1 .AND. aQuant[1,3] > 0
				lContInt := .F.
			Else
				nQtlib += aQuant[nX,2]
				nQtBloq+= aQuant[nX,3]
			EndIf
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o cabecalho do pedido no relatorio.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lCabPed .AND. lContInt .AND. Len(aQuant)>0 .AND. mv_par06 <> 3) .OR. (lCabPed .AND. lContInt .AND. mv_par06 == 3)
			
			dbSelectArea(cAliasSC5)
			
			MaFisIni((cAliasSC5)->C5_CLIENTE,(cAliasSC5)->C5_LOJACLI,"C",(cAliasSC5)->C5_TIPO,(cAliasSC5)->C5_TIPOCLI,aImpostos,,,"SB1","MTR700")

			//Na argentina o calculo de impostos depende da serie.
			If cPaisLoc == 'ARG'
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial()+(cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI))
				MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
			Endif
			
			For nX:= 1 TO 5
				cCampo := "C5_VEND"+STR(nX,1)
				cCampo := (cAliasSC5)->(FieldGet(FieldPos(cCampo)))
				If !Empty(cCampo)
					cVends += If(lBarra,"/","") + cCampo
					lBarra :=.T.
				EndIf
			Next nX

			oReport:Section(1):PrintLine()
			
			cPedido     := (cAliasSC6)->C6_NUM
			nC5Moeda    := (cAliasSC5)->C5_MOEDA
			dC5Emissao  := (cAliasSC5)->C5_EMISSAO
			nPacresFin  := (cAliasSC5)->C5_ACRSFIN
			lCabPed     := .F.
			
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o Skip dos dados Validos do C6 e dado antes da impressao dos itens do relatorio por  ³
		//³ causa da compatibilizacao das logicas com Query e codbase onde a disposicao dos dados³
		//³ se deram de formas dIferentes.                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSC6)
		dbSkip()
		oReport:IncMeter()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os itens do pedido no relatorio.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  cNumero + cItem + cProduto <> (cAliasSC6)->C6_NUM + (cAliasSC6)->C6_ITEM + (cAliasSC6)->C6_PRODUTO
			
			If ( lContInt .AND. Len(aQuant)>0 .AND. mv_par06 <> 3 ) .OR. ( lContInt .AND. mv_par06 == 3 )
				
				If (nQtLib+nQtBloq)<> 0
					nQuant  := (nQtLib+nQtBloq)
					nTFat   := (nQtLib+nQtBloq) * nPrcven
				Else
					nQuant  := (nQtdven - nQtdent)
					nTFat   := (nQtdven - nQtdent) * nPrcVen
				Endif	
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o preco de lista                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( nPrUnit == 0 )
					nPrUnit := NoRound(nTFat/nQuant,TamSX3("C6_PRCVEN")[2])
				EndIf
				nAcresFin := A410Arred(nPrcVen*nPacresFin/100,"D2_PRCVEN")
				nTFat     += A410Arred(nQuant*nAcresFin,"D2_TOTAL")
				nValDesc  := a410Arred(nPrUnit*nQuant,"D2_DESCON")-nTFat
				nValDesc := IIf(nVlDesc==0,nVlDesc,nValDesc)
				nValDesc  := Max(0,nValDesc)
				nPrUnit   += nAcresFin

				MaFisAdd(cProduto,cTes,(nQtLib+nQtBloq),nPrunit,nValdesc,,,,0,0,0,0,(nTFat+nValDesc),0,0,0)
				
				nItem 		+= 1
				lImp 		:= .T.
				nTotLocal 	:= 0
				//nImpLinha	:= 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizacao do saldo disponivel em estoque com base no SB2 atraves de arquivo de trab³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("STR")
				If msSeek(cLocal+cProduto)
					nTotLocal := STR->TB_SALDO
					RecLock("STR",.F.)
				ELSE
					dbSelectArea("SB2")
					msSeek(xFilial()+cProduto+cLocal)
					nTotLocal := SaldoSB2()
					RecLock("STR",.T.)
					REPLACE TB_COD WITH cProduto,TB_LOCAL WITH cLocal,TB_SALDO WITH nTotLocal
				EndIf
				
				If nQtLib <= 0
					REPLACE TB_SALDO WITH TB_SALDO - (nQtdven - nQtdent)
				EndIf
				
				MsUnLock()
				
				If !Empty(cOp)
					dbSelectArea("SX5")
					msSeek(xFilial()+"E2"+cOp)
					cDescTab := X5Descri()
				Else
					cDescTab := ""
				EndIf

				nValIPI := MaFisRet(nItem,"IT_VALIPI")

				//nImpLinha := nValIPI
				
				//If MV_PAR13 == 2 .AND. cPaisLoc == "BRA"
				//   nImpLinha += ( MaFisRet(nItem,"IT_VALICM") + MaFisRet(nItem,"IT_VALISS") ) 
				//EndIf 				
				
								
				nValDesc  := xMoeda(nValDesc,nC5Moeda,mv_par08,IIf(mv_par12 == 1,dC5Emissao,dDataBase))
				nPrcVen   := xMoeda(nPrcVen ,nC5Moeda,mv_par08,IIf(mv_par12 == 1,dC5Emissao,dDataBase))
				//nImpLinha := xMoeda(nImpLinha,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase)) 
				nTFat     := xMoeda(nTFat,nC5Moeda,mv_par08,IIf(MV_PAR12 == 1,dC5Emissao,dDataBase))

                nCofins	  := MaFisRet(nItem,"IT_VALCF2")	//IT_VALCOF retido
                nPis	  := MaFisRet(nItem,"IT_VALPS2")	//IT_VALPIS retido		
 		        nIcms     := MaFisRet(nItem,"IT_VALICM")
 		        nIpi      := nValIpi
 		        nIss      := MaFisRet(nItem,"IT_VALISS")
 		        nLiquido  := nTFat - (nCofins + nPis + nIcms)

				oReport:Section(1):Section(1):PrintLine()
				
				nQtlib  	:= 0
				nQtBloq		:= 0 
				
			EndIf
			
		EndIf
	Else
		dbSelectArea(cAliasSC6)
		dbSkip()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o Rodape do pedido no relatorio.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC6)->C6_NUM  <> cPedido .AND. lImp 
	
		If nOrdem == 1
			oReport:Section(1):Section(1):SetTotalText("Total do Pedido-->")	// 
		ElseIf nOrdem == 2
			oReport:Section(1):Section(1):SetTotalText("Total do Produto-->")	// 		
		Else 
			oReport:Section(1):Section(1):SetTotalText("Total da Data-->")	// 		
		EndIf
		oReport:Section(1):Section(1):Finish()
		oReport:Section(1):Finish()
		oReport:Section(1):Init()
		oReport:Section(1):Section(1):Init()
		
		nQtlib 		:= 0
		nQtBloq 	:= 0
		nItem		:= 0
		cVends      := ""
		lCabPed     := .T.
		lBarra      := .F.
		lImp        := .F.
		
		MaFisEnd()
	EndIf
	
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza Relatorio                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetPageBreak()

If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

dbSelectArea(cAliasSC5)
dbCloseArea()
dbSelectArea("SC6")

Return(.T.)
