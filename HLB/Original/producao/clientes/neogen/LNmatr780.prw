#INCLUDE "LNMATR780.CH" 
#INCLUDE "FIVEWIN.CH"  


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MATR780  � Autor � Marco Bianchi         � Data � 19/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Vendas por Cliente, quantidade de cada Produto, ���
���          � Release 4.                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function LNMATR780()

Private oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	MATR780R3()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data � 19/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
#IFDEF TOP
	Local cAliasSD1 := GetNextAlias()
	Local cAliasSD2 := GetNextAlias()
	Local cAliasSA1 := GetNextAlias()
#ELSE 
	Local cAliasSD1	:= "SD1"
	Local cAliasSD2	:= "SD2"
	Local cAliasSA1 := "SA1"
#ENDIF	

Local cCodProd	:= ""
Local cDescProd	:= ""
Local cItemCC	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local dEmissao	:= ""
Local cUM		:= ""
Local nTotQuant	:= 0
Local nVlrUnit	:= 0
Local nVlrTot	:= 0
Local nVlrFre	:= 0
Local nVlrSeg   := 0
Local nVlrDesp  := 0
Local nVlrAcrs  := 0
Local nVlrPIS	:= 0
Local nVlrCOFIN	:= 0
Local nVlrICMS	:= 0
Local nVlrST	:= 0
Local nVlrIcCom	:= 0
Local nVlrIcDif	:= 0
Local nVlrFecp	:= 0
Local nVlrIPI	:= 0
Local nVlrNet	:= 0
//Local cVends	:= ""                          
//Local cNomVend	:= ""
Local cClieAnt	:= ""
Local cLojaAnt	:= ""
Local cNomeCli	:= ""
Local cGRPVEN   := ""
Local cDGRPVEN  := ""                  
Local cEstado   := ""
Local cNreduz   := ""
Local nTamData  := Len(DTOC(MsDate()))
 
Private cSD1, cSD2
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
// "Estatisticas de Vendas (Cliente x Produto)"###"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,
//"###"totalizando por produto e escolhendo a moeda forte para os Valores."
oReport := TReport():New("UMATR780",STR0018,"UMR780A", {|oReport| ReportPrint(oReport,cAliasSD1,cAliasSD2,cAliasSA1)},"" + " " + "")
oReport:SetPortrait() 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//� Secao 1 - Cliente                                                      �
//��������������������������������������������������������������������������
oCliente := TRSection():New(oReport,STR0027,{"SA1","SD2TRB"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Estatisticas de Vendas (Cliente x Produto)"
oCliente:SetTotalInLine(.F.)

TRCell():New(oCliente,"cGRPVEN"   ,/*Tabela*/,"Grupo"                 ,PesqPict("SA1","A1_GRPVEN"	),TamSx3("A1_GRPVEN"   )[1],/*lPixel*/,{|| cGRPVEN	             	})// "Grupo de vendas"
TRCell():New(oCliente,"cDGRPVEN"  ,/*Tabela*/,"Descricao Grupo"       ,PesqPict("ACY","ACY_DESCRI"	),TamSx3("ACY_DESCRI"  )[1],/*lPixel*/,{|| cDGRPVEN                })// "Grupo de vendas"
TRCell():New(oCliente,"CVENDS"	  ,/*Tabela*/,STR0024					 ,PesqPict("SF2","F2_VEND1"		),TamSx3("F2_VEND1")[1],/*lPixel*/,{|| cVends		})	// "Vendedor"
TRCell():New(oCliente,"CNOMVEND"  ,/*Tabela*/,RetTitle("A3_NOME"	) 	 ,PesqPict("SA3","A3_NOME"		),TamSx3("A3_NOME" )[1],/*lPixel*/,{|| CNOMVEND	})	
TRCell():New(oCliente,"CCLIEANT"  ,/*Tabela*/,RetTitle("D2_CLIENTE"	),PesqPict("SD2","D2_CLIENTE"	),08					 ,/*lPixel*/,{|| cClieAnt		        })
TRCell():New(oCliente,"CLOJA"	  ,/*Tabela*/,RetTitle("D2_LOJA"		),PesqPict("SD2","D2_LOJA"		),TamSx3("D2_LOJA" )[1],/*lPixel*/,{|| cLojaAnt				})
TRCell():New(oCliente,"cNomeCli"  ,/*Tabela*/,RetTitle("A1_NOME"		),PesqPict("SA1","A1_NOME"		),TamSx3("A1_NOME" )[1],/*lPixel*/,{|| cNomeCli	})
TRCell():New(oCliente,"cNreduz"   ,/*Tabela*/,RetTitle("A1_NREDUZ"	),PesqPict("SA1","A1_NREDUZ"	),TamSx3("A1_NREDUZ"   )[1],/*lPixel*/,{|| cNreduz                 })
TRCell():New(oCliente,"cEstado"   ,/*Tabela*/,RetTitle("A1_EST"	    ),PesqPict("SA1","A1_EST"		),TamSx3("A1_EST"	   )[1],/*lPixel*/,{|| cEstado              	})


// Imprimie Cabecalho no Topo da Pagina
oReport:Section(1):SetHeaderPage()                       

//������������������������������������������������������������������������Ŀ
//� Sub-Secao do Cliente - Produto                                         �
//��������������������������������������������������������������������������
oProduto := TRSection():New(oCliente,STR0028,{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Estatisticas de Vendas (Cliente x Produto)"
oProduto:SetTotalInLine(.F.)

TRCell():New(oProduto,"CCODPROD"	,/*Tabela*/,RetTitle("D2_COD"		),PesqPict("SD2","D2_COD"					),TamSx3("D2_COD"		)[1],/*lPixel*/,{|| cCodProd	})
TRCell():New(oProduto,"CDESCPROD"	,/*Tabela*/,RetTitle("B1_DESC"		),PesqPict("SB1","B1_DESC"					),TamSx3("B1_DESC"		)[1],/*lPixel*/,{|| cDescProd	})

TRCell():New(oProduto,"CITEMCC"		,/*Tabela*/,RetTitle("D2_ITEMCC"	),PesqPict("SD2","D2_ITEMCC"				),TamSx3("D2_ITEMCC"	)[1],/*lPixel*/,{|| cItemCC		})

TRCell():New(oProduto,"CDOC"		,/*Tabela*/,RetTitle("D2_DOC"		),PesqPict("SD2","D2_DOC"					),TamSx3("D2_DOC"		)[1],/*lPixel*/,{|| cDoc		})
TRCell():New(oProduto,"CSERIE" 		,/*Tabela*/,RetTitle("D2_SERIE"		),PesqPict("SD2","D2_SERIE"					),TamSx3("D2_SERIE"		)[1],/*lPixel*/,{|| cSerie		})
TRCell():New(oProduto,"DEMISSAO"	,/*Tabela*/,RetTitle("D2_EMISSAO"	),PesqPict("SD2","D2_EMISSAO"				),nTamData					,/*lPixel*/,{|| dEmissao	})
TRCell():New(oProduto,"CUM"			,/*Tabela*/,RetTitle("B1_UM"		),PesqPict("SB1","B1_UM"					),TamSx3("B1_UM"		)[1],/*lPixel*/,{|| cUM			})
TRCell():New(oProduto,"NTOTQUANT"	,/*Tabela*/,RetTitle("D2_QUANT"		),PesqPict("SD2","D2_QUANT"					),TamSx3("D2_QUANT"		)[1],/*lPixel*/,{|| nTotQuant	})
TRCell():New(oProduto,"NVLRUNIT"	,/*Tabela*/,RetTitle("D2_PRCVEN"	),PesqPict("SD2","D2_PRCVEN"				),TamSx3("D2_PRCVEN"	)[1],/*lPixel*/,{|| nVlrUnit	})
TRCell():New(oProduto,"NVLRTOT"		,/*Tabela*/,RetTitle("D2_TOTAL"		),PesqPict("SD2","D2_TOTAL"					),TamSx3("D2_TOTAL"		)[1],/*lPixel*/,{|| nVlrTot		})
TRCell():New(oProduto,"NVLRFRE"		,/*Tabela*/,RetTitle("D2_VALFRE"	),PesqPict("SD2","D2_VALFRE"				),TamSx3("D2_VALFRE"	)[1],/*lPixel*/,{|| nVlrFre		})
TRCell():New(oProduto,"NVLRSEG"		,/*Tabela*/,RetTitle("D2_SEGURO"	),PesqPict("SD2","D2_SEGURO"				),TamSx3("D2_SEGURO"	)[1],/*lPixel*/,{|| nVlrSeg		})
TRCell():New(oProduto,"NVLRDESP"	,/*Tabela*/,RetTitle("D2_DESPESA"	),PesqPict("SD2","D2_DESPESA"		   		),TamSx3("D2_DESPESA"	)[1],/*lPixel*/,{|| nVlrDesp	})
TRCell():New(oProduto,"NVLRACRS"	,/*Tabela*/,RetTitle("D2_VALACRS"	),PesqPict("SD2","D2_VALACRS"		   		),TamSx3("D2_VALACRS"	)[1],/*lPixel*/,{|| nVlrAcrs	})
TRCell():New(oProduto,"NVLRPIS"		,/*Tabela*/,RetTitle("D2_VALPIS"	),PesqPict("SD2","D2_VALPIS"				),TamSx3("D2_VALPIS"    )[1],/*lPixel*/,{|| nVlrPIS		})
TRCell():New(oProduto,"NVLRCOFIN"   ,/*Tabela*/,RetTitle("D2_VALCOF"	),PesqPict("SD2","D2_VALCOF"				),TamSx3("D2_VALCOF"	)[1],/*lPixel*/,{|| nVlrCOFIN   })
TRCell():New(oProduto,"NVLRICMS"	,/*Tabela*/,RetTitle("D2_VALICM"	),PesqPict("SD2","D2_VALICM"				),TamSx3("D2_VALICM"	)[1],/*lPixel*/,{|| nVlrICMS	})
TRCell():New(oProduto,"NVLRST"		,/*Tabela*/,RetTitle("D2_ICMSRET"	),PesqPict("SD2","D2_ICMSRET"			    ),TamSx3("D2_ICMSRET"	)[1],/*lPixel*/,{|| nVlrST		})
TRCell():New(oProduto,"NVLRICCOM"	,/*Tabela*/,RetTitle("D2_ICMSCOM"	),PesqPict("SD2","D2_ICMSCOM"				),TamSx3("D2_ICMSCOM"	)[1],/*lPixel*/,{|| nVlrIcCom	})
TRCell():New(oProduto,"NVLRICDIF"	,/*Tabela*/,RetTitle("D2_DIFAL"		),PesqPict("SD2","D2_DIFAL"			   		),TamSx3("D2_DIFAL"		)[1],/*lPixel*/,{|| nVlrIcDif	})
TRCell():New(oProduto,"NVLRIPI"		,/*Tabela*/,RetTitle("D2_VALIPI"	),PesqPict("SD2","D2_VALIPI"				),TamSx3("D2_VALIPI"	)[1],/*lPixel*/,{|| nVlrIPI		})
TRCell():New(oProduto,"NVLRFECP"	,/*Tabela*/,RetTitle("D2_VFCPDIF"	),PesqPict("SD2","D2_VFCPDIF"		   		),TamSx3("D2_VFCPDIF"	)[1],/*lPixel*/,{|| nVlrFecp	})
TRCell():New(oProduto,"NVLRNET"		,/*Tabela*/,"Net Sales"				 ,PesqPict("SD2","D2_TOTAL"			   		),TamSx3("D2_TOTAL"		)[1],/*lPixel*/,{|| nVlrNet		})


// Alinhamento a direita das colunas de valor
oProduto:Cell("NTOTQUANT"):SetHeaderAlign("RIGHT") 
oProduto:Cell("NVLRUNIT"):SetHeaderAlign("RIGHT") 
oProduto:Cell("NVLRTOT"):SetHeaderAlign("RIGHT") 

// Totalizador por Produto
oTotal1 := TRFunction():New(oProduto:Cell("NTOTQUANT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
oTotal2 := TRFunction():New(oProduto:Cell("NVLRTOT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

// Totalizador por Cliente
oTotal3 := TRFunction():New(oProduto:Cell("NTOTQUANT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oCliente)
oTotal4 := TRFunction():New(oProduto:Cell("NVLRTOT"	),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,oCliente)

// Imprimie Cabecalho no Topo da Pagina
oReport:Section(1):Section(1):SetHeaderPage()

//������������������������������������������������������������������������Ŀ
//� Secao 2 - Filtro das nota de devolucao                                 �
//��������������������������������������������������������������������������
oTemp1 := TRSection():New(oReport,STR0028,{"SD1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Estatisticas de Vendas (Cliente x Produto)"
oTemp1:SetTotalInLine(.F.)

//������������������������������������������������������������������������Ŀ
//� Secao 4 - Filtro das Notas de Saida                                    �
//��������������������������������������������������������������������������
oTemp3 := TRSection():New(oReport,STR0028,{"SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Estatisticas de Vendas (Cliente x Produto)"
oTemp3:SetTotalInLine(.F.) 

oReport:Section(2):SetEditCell(.F.)
oReport:Section(3):SetEditCell(.F.)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Marco Bianchi         � Data � 19/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasSD1,cAliasSD2,cAliasSA1,cVend)

Local  nV := 0
Local cProdAnt	  := "", cLojaAnt := "" 
Local lNewProd	  := .T.
Local nTamRef	  := Val(Substr(GetMv("MV_MASCGRD"),1,2))
Local cProdRef	  := ""
//Local cUM		  := ""
//Local nTotQuant	  := 0
Local nReg		  := 0
Local cFiltro	  := ""
Local cEstoq	  := If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ))
Local cDupli	  := If( (mv_par14 == 1),"S",If( (mv_par14 == 2),"N","SN" ))
Local cArqTrab1, cArqTrab2, cCondicao1
Local aDevImpr	  := {}
//Local cVends	  := ""
//Local cNomVend	  := ""
Local nVend		  := FA440CntVend()
Local nDevQtd	  := 0
Local nDevVal	  := 0
Local aDev		  := {}
Local nIndD2	  := 0
Local aStru
Local lNfD2Ori	  := .F. 
Local cVendedores := ""
Local lNewCli     := .T.


#IFDEF TOP
	Local nj	:= 0
	Local cWhere:= ""	
#ELSE
	Local cCondicao := ""	
#ENDIF
Private cNomVend:= ""
Private cVends  := ""
Private nIndD1  :=0
Private nDecs	:=msdecimais(mv_par09)
//VYB - 27/07/2016 - Sinal negativo para itens de devolu��o
Private nDevFre	  := 0
Private nDevSeg	  := 0
Private nDevDes	  := 0
Private nDevAcr	  := 0
Private nDevPis	  := 0
Private nDevCof	  := 0
Private nDevIcms  := 0
Private nDevIcRe  := 0
Private nDevIcCo  := 0
Private nDevDif	  := 0
Private nDevIpi	  := 0
Private nDevFecp  := 0
Private nDevNet   := 0    
Private nTotQuant := 0
//FIM

//��������������������������������������������������������������Ŀ
//� Define o bloco de codigo que retornara o conteudo de impres- �
//� sao da celula.                                               �
//����������������������������������������������������������������
oReport:Section(1):Cell("cGRPVEN" 	):SetBlock({|| cGRPVEN		})
oReport:Section(1):Cell("cDGRPVEN" 	):SetBlock({|| cDGRPVEN     })
oReport:Section(1):Cell("CVENDS" 	):SetBlock({|| cVends		})
oReport:Section(1):Cell("CNOMVEND" 	):SetBlock({|| cNomVend		})
oReport:Section(1):Cell("CCLIEANT" 	):SetBlock({|| cClieAnt		})
oReport:Section(1):Cell("CLOJA" 	):SetBlock({|| cLojaAnt		})
oReport:Section(1):Cell("cNomeCli" 	):SetBlock({|| cNomeCli		})
oReport:Section(1):Cell("cNreduz"   ):SetBlock({|| cNreduz		})
oReport:Section(1):Cell("cEstado" 	):SetBlock({|| cEstado		})
oReport:Section(1):Section(1):Cell("CCODPROD" 	):SetBlock({|| cCodProd		})
oReport:Section(1):Section(1):Cell("CDESCPROD" 	):SetBlock({|| cDescProd	})
oReport:Section(1):Section(1):Cell("CITEMCC" 	):SetBlock({|| CITEMCC		})
oReport:Section(1):Section(1):Cell("CDOC"		):SetBlock({|| cDoc			})
oReport:Section(1):Section(1):Cell("CSERIE" 	):SetBlock({|| cSerie 		})
oReport:Section(1):Section(1):Cell("DEMISSAO" 	):SetBlock({|| dEmissao		})
oReport:Section(1):Section(1):Cell("CUM"		):SetBlock({|| cUM			})
oReport:Section(1):Section(1):Cell("NTOTQUANT"	):SetBlock({|| nTotQuant	})
oReport:Section(1):Section(1):Cell("NVLRUNIT" 	):SetBlock({|| nVlrUnit		})
oReport:Section(1):Section(1):Cell("NVLRTOT" 	):SetBlock({|| nVlrTot		})
oReport:Section(1):Section(1):Cell("NVLRFRE" 	):SetBlock({|| nVlrFre		})
oReport:Section(1):Section(1):Cell("NVLRPIS" 	):SetBlock({|| nVlrPis		})
oReport:Section(1):Section(1):Cell("NVLRCOFIN"  ):SetBlock({|| nVlrCofin	})
oReport:Section(1):Section(1):Cell("NVLRICMS" 	):SetBlock({|| nVlrICMS		})
oReport:Section(1):Section(1):Cell("NVLRST" 	):SetBlock({|| nVlrST		})
oReport:Section(1):Section(1):Cell("NVLRICCOM" 	):SetBlock({|| nVlrIcCom	})
oReport:Section(1):Section(1):Cell("NVLRICDIF" 	):SetBlock({|| nVlrIcDif	})
oReport:Section(1):Section(1):Cell("NVLRFECP" 	):SetBlock({|| nVlrFecp		})
oReport:Section(1):Section(1):Cell("NVLRIPI" 	):SetBlock({|| nVlrIPI		})
oReport:Section(1):Section(1):Cell("NVLRNET" 	):SetBlock({|| nVlrNet		})
oReport:Section(1):Section(1):Cell("NVLRSEG" 	):SetBlock({|| nVLRSEG		})
oReport:Section(1):Section(1):Cell("NVLRDESP" 	):SetBlock({|| nVlrDesp		})
oReport:Section(1):Section(1):Cell("NVLRACRS" 	):SetBlock({|| nVlrAcrs		})

DbSelectArea("SA3")
//������������������������������������������������������������������������Ŀ
//� Seleciona ordem dos arquivos consultados no processamento    		   �
//��������������������������������������������������������������������������
SF1->(dbsetorder(1))
SF2->(dbsetorder(1))
SB1->(dbSetOrder(1))
SA7->(dbSetOrder(2))
SA3->(DbSetOrder(1))

//������������������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com parametros                             �
//��������������������������������������������������������������������������
oReport:SetTitle(oReport:Title() + " " + "" +GetMV("MV_SIMB"+Str(mv_par09,1)))		// "Estatisticas de Vendas (Cliente x Produto)"###"Valores em "

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)



//������������������������������������������������������������������������Ŀ
//�Filtra nota de devolucao                                                �
//��������������������������������������������������������������������������
dbSelectArea("SD1")
cArqTrab1  := CriaTrab( "" , .F. )
#IFDEF TOP
    If (TcSrvType()#'AS/400')//(TcSrvType()#'AS/400')
        cSD1   := "SD1TMP"
	    aStru  := dbStruct()
        cWhere := "%NOT ("+IsRemito(3,'SD1.D1_TIPODOC')+ ")%"
        oReport:Section(2):BeginQuery()
        BeginSql Alias cAliasSD1
        SELECT *
	    FROM %Table:SD1% SD1

	    LEFT JOIN %Table:SA1% SA1 on
		SA1.A1_COD+SA1.A1_LOJA = SD1.D1_FORNECE+SD1.D1_LOJA
	    
	    LEFT JOIN %Table:SB1% SB1 on
		SB1.B1_COD = SD1.D1_COD
		
	    WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
		    SD1.D1_FORNECE >= %Exp:mv_par01% AND SD1.D1_FORNECE <= %Exp:mv_par02% AND
		    SD1.D1_DTDIGIT >= %Exp:DtoS(mv_par03)% AND SD1.D1_DTDIGIT <= %Exp:DtoS(mv_par04)% AND
		    SA1.A1_GRPVEN BETWEEN %Exp:mv_par18% AND %Exp:mv_par19% AND
	    	SA1.A1_EST BETWEEN %Exp:mv_par22% AND %Exp:mv_par23% AND
	    	SB1.B1_GRUPO BETWEEN %Exp:mv_par20% AND %Exp:mv_par21% AND  
		    SD1.D1_COD >= %Exp:mv_par05% AND SD1.D1_COD <= %Exp:mv_par06% AND
		    SD1.D1_TIPO = 'D' AND
			%Exp:cWhere% AND		    
		    SD1.%NotDel%
	    ORDER BY SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_COD
	    EndSql
	    oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)

	    A780CriaTmp(cArqTrab1, aStru, cSD1, cALiasSD1 )
	    IndRegua(cSD1,cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD",,".T.",STR0026)		// "Selecionando Registros..."
	Else    
#ENDIF
	    cSD1	   := "SD1"
		dbSelectArea("SD1")
	    cCondicao1 := 'D1_FILIAL=="' + xFilial("SD1") + '".And.'
	    cCondicao1 += 'D1_FORNECE>="' + mv_par01 + '".And.'
	    cCondicao1 += 'D1_FORNECE<="' + mv_par02 + '".And.'
	    cCondicao1 += 'DtoS(D1_DTDIGIT)>="' + DtoS(mv_par03) + '".And.'
	    cCondicao1 += 'DtoS(D1_DTDIGIT)<="' + DtoS(mv_par04) + '".And.'
	    cCondicao1 += 'D1_COD>="' + mv_par05 + '".And.'
	    cCondicao1 += 'D1_COD<="' + mv_par06 + '".And.'
	    cCondicao1 += 'D1_TIPO=="D"'// .And. !('+IsRemito(2,'SD1->D1_TIPODOC')+')'		

	    cArqTrab1  := CriaTrab("",.F.)
	    IndRegua(cSD1,cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD",,cCondicao1,STR0026)		// "Selecionando Registros..."
	    nIndD1 := RetIndex()

        #IFNDEF TOP	    
	       dbSetIndex(cArqTrab1+ordBagExt())
        #ENDIF

	    dbSetOrder(nIndD1+1)
#IFDEF TOP
    Endif  	    
#ENDIF   


//��������������������������������������������������������������Ŀ
//� Monta filtro para processar as vendas por cliente            �
//����������������������������������������������������������������
DbSelectArea("SD2")
cFiltro := SD2->(dbFilter())
If Empty(cFiltro)
	bFiltro := { || .T. }
Else
	cFiltro := "{ || " + cFiltro + " }"
	bFiltro := &(cFiltro)
Endif

//��������������������������������������������������������������Ŀ
//� Monta filtro para p'rocessar as vendas por cliente            �
//����������������������������������������������������������������
DbSelectArea("SD2")
cArqTrab2  := CriaTrab( "" , .F. )
#IFDEF TOP            
    If (TcSrvType()#'AS/400')
	    cSD2   := "SD2TMP"
	    aStru  := dbStruct()
        cWhere := "%NOT ("+IsRemito(3,'SD2.D2_TIPODOC')+ ")%"
        oReport:Section(3):BeginQuery()
        BeginSql Alias cAliasSD2
	    SELECT * 
	    FROM %Table:SD2% SD2   
	    
	    LEFT JOIN %Table:SA1% SA1 on
		SA1.A1_COD+SA1.A1_LOJA = SD2.D2_CLIENTE+SD2.D2_LOJA
	    
	    LEFT JOIN %Table:SB1% SB1 on
		SB1.B1_COD = SD2.D2_COD
		
	    WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
	    	SD2.D2_CLIENTE BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	    	SA1.A1_GRPVEN BETWEEN %Exp:mv_par18% AND %Exp:mv_par19% AND
	    	SA1.A1_EST BETWEEN %Exp:mv_par22% AND %Exp:mv_par23% AND
	    	SB1.B1_GRUPO BETWEEN %Exp:mv_par20% AND %Exp:mv_par21% AND
	    	SD2.D2_EMISSAO BETWEEN %Exp:DTOS(mv_par03)% AND %Exp:DTOS(mv_par04)% AND
	    	SD2.D2_COD     BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
	    	SD2.D2_TIPO <> 'B' AND SD2.D2_TIPO <> 'D' AND
	    	%Exp:cWhere% AND
	    	SD2.%NotDel% AND    
	    	SA1.%NotDel% AND
	    	SB1.%NotDel% 
	    ORDER BY SD2.D2_FILIAL,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SD2.D2_ITEM
	    EndSql
	    oReport:Section(3):EndQuery()
	    
	    A780CriaTmp(cArqTrab2, aStru, cSD2, cAliasSD2)
	    IndRegua(cSD2,cArqTrab2,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_COD+D2_SERIE+D2_DOC+D2_ITEM",,".T.",STR0026)		// "Selecionando Registros..."
	    
    Else
#ENDIF                   
	    cSD2	   := "SD2"
	    cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
	    cCondicao += 'D2_CLIENTE >= "' + mv_par01 + '" .And. '
	    cCondicao += 'D2_CLIENTE <= "' + mv_par02 + '" .And. '
	    cCondicao += 'DTOS(D2_EMISSAO) >= "' + DTOS(mv_par03) + '" .And. '
	    cCondicao += 'DTOS(D2_EMISSAO) <= "' + DTOS(mv_par04) + '" .And. '
	    cCondicao += 'D2_COD >= "' + mv_par05 + '" .And. '
	    cCondicao += 'D2_COD <= "' + mv_par06 + '" .And. '
	    cCondicao += '!(D2_TIPO $ "BD")'
	    cCondicao += '.And. !('+IsRemito(2,'SD2->D2_TIPODOC')+')'		
 
	    IndRegua("SD2",cArqTrab2,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_COD+D2_SERIE+D2_DOC+D2_ITEM",,cCondicao,STR0026)		// "Selecionando Registros..."
	    nIndD2 := RetIndex()

        #IFNDEF TOP	    
	       dbSetIndex(cArqTrab2+ordBagExt())
        #ENDIF
        
	    dbSetOrder(nIndD2+1)
#IFDEF TOP	    
	Endif    
#ENDIF


dbSelectArea("SA1")
dbSetOrder(1)
#IFDEF TOP
    oReport:Section(1):BeginQuery()  
    BeginSql Alias cALiasSA1
    SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_OBSERV,A1_GRPVEN,A1_EST,A1_NREDUZ
    FROM %Table:SA1% SA1
    WHERE SA1.A1_FILIAL = %xFilial:SA1% AND
    SA1.A1_COD >= %Exp:MV_PAR01% AND
	SA1.A1_COD <= %Exp:MV_PAR02% AND
    SA1.%NotDel%
    ORDER BY A1_FILIAL,A1_COD
    EndSql
    oReport:Section(1):EndQuery()
#ENDIF

//��������������������������������������������������������������Ŀ
//� Verifica se aglutinara produtos de Grade                     �
//����������������������������������������������������������������
oReport:SetMeter(RecCount())		// Total de Elementos da regua

If ( (cSD2)->D2_GRADE=="S" .And. MV_PAR12 == 1)
	lGrade := .T.
	bGrade := { || Substr((cSD2)->D2_COD, 1, nTamref) }
Else
	lGrade := .F.
	bGrade := { || (cSD2)->D2_COD }
Endif

//��������������������������������������������������������������Ŀ
//� Procura pelo 1o. cliente valido                              �
//����������������������������������������������������������������
#IFNDEF TOP
	dbSeek(xFilial()+mv_par01, .t.)
#ENDIF
While !oReport:Cancel() .And. (cAliasSA1)->( ! EOF() .AND. A1_COD <= MV_PAR02 ) .And. (cAliasSA1)->A1_FILIAL == xFilial("SA1")
	                                                               
	
	//����������������������������������������������������������Ŀ
	//� Procura pelas saidas daquele cliente                     �
	//������������������������������������������������������������ 
	
	DbSelectArea(cSD2)
	If DbSeek(xFilial("SD2")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)
		lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
		
		//����������������������������������������������������������Ŀ
		//� Montagem da quebra do relatorio por  Cliente             �
		//������������������������������������������������������������
		cClieAnt := (cAliasSA1)->A1_COD
		cLojaAnt := (cAliasSA1)->A1_LOJA  
		cNomeCli := (cAliasSA1)->A1_NOME  
		cEstado  := (cAliasSA1)->A1_EST 
		cNreduz  := (cAliasSA1)->A1_NREDUZ
        
		If Empty((cAliasSA1)->A1_GRPVEN)
	   		cGRPVEN:="Vazio"
		Else
			cGRPVEN:=(cAliasSA1)->A1_GRPVEN
		EndIf
		
		ACY->(DbSetOrder(1))
		If ACY->(DbSeek(xFilial("ACY")+(cAliasSA1)->A1_GRPVEN ))     
			cDGRPVEN:=ACY->ACY_DESCRI	
		Else
			cDGRPVEN:="Nao encontrado grupo"			
		EndIf

		lNewProd := .T.
		lNewCli  := .T.  
		
		While !oReport:Cancel() .And.!Eof() .and. ;
			((cSD2)->(D2_FILIAL+D2_CLIENTE+D2_LOJA)) == (xFilial("SD2")+cClieAnt+cLojaAnt)
			
			//����������������������������������������������������������Ŀ
			//� Verifica Se eh uma tipo de nota valida                   �
			//� Verifica intervalo de Codigos de Vendedor                �
			//� Valida o produto conforme a mascara                      �
   			//������������������������������������������������������������
			lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
			If	! Eval(bFiltro)// .Or. !A780Vend(@cVends,nVend) .Or. !lRet //.or. SD2->D2_TIPO$"BD" ja esta no filtro
				dbSkip()
				Loop
			EndIf
			
			//����������������������������������������������������������Ŀ
			//� Impressao da quebra por produto e NF                     �
			//������������������������������������������������������������
			cProdAnt := Eval(bGrade)
			lNewProd := .T.
			oReport:Section(1):Section(1):Init()
			While !oReport:Cancel() .And. ! Eof() .And. ;
				(cSD2)->(D2_FILIAL + D2_CLIENTE + D2_LOJA  + EVAL(bGrade) ) == ;
				( xFilial("SD2") + cClieAnt   + cLojaAnt + cProdAnt )
				oReport:IncMeter()
				
				//����������������������������������������������������������Ŀ
				//� Avalia TES                                               �
				//������������������������������������������������������������
				lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
				If !AvalTes((cSD2)->D2_TES,cEstoq,cDupli) .Or. !Eval(bFiltro) .Or. !lRet
					dbSkip()
					Loop
				Endif
				
				If !A780Vend(@cVends,nVend)
					dbskip()
					Loop
				Endif
				
				SF2->(dbSeek(xFilial("SF2")+(cSD2)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
				If SA3->(DbSeek(xFilial("SA3")+SF2->F2_VEND1))
					cNomVend:=alltrim(SA3->A3_NOME)
				endif
				
				If lNewCli
					oReport:Section(1):Init()
					oReport:Section(1):PrintLine()
					lNewCli := .F.
				EndIf
				//����������������������������������������������������������Ŀ
				//� Se mesmo produto inibe impressao do codigo e descricao   �
				//������������������������������������������������������������
				oReport:Section(1):Section(1):Cell("CCODPROD"	):Show()
				oReport:Section(1):Section(1):Cell("CDESCPROD"	):Show()
								
				//����������������������������������������������������������Ŀ
				//� Caso seja grade aglutina todos produtos do mesmo Pedido  �
				//������������������������������������������������������������
				If lGrade  // Aglutina Grade
					cProdRef := Substr((cSD2)->D2_COD,1,nTamRef)
					cNumPed  := (cSD2)->D2_PEDIDO
					nReg     := 0
					nDevQtd  := 0
					nDevVal  := 0
					nDevFre  := 0 
					nDevSeg  := 0 
					nDevDes  := 0
					nDevAcr  := 0
					nDevPis  := 0
					nDevCof  := 0
					nDevIcms := 0
					nDevIcRe := 0
					nDevIcCo := 0
					nDevDif  := 0
					nDevIpi  := 0
					nDevFecp := 0
					nDevNet  := 0
					
					While !oReport:Cancel() .And. !Eof() .And. cProdRef == Eval(bGrade) .And.;
						(cSD2)->D2_GRADE == "S" .And. cNumPed == (cSD2)->D2_PEDIDO .And.;
						(cSD2)->D2_FILIAL == xFilial("SD2")
						
						nReg := Recno()
						//���������������������������������������������Ŀ
						//� Valida o produto conforme a mascara         �
						//�����������������������������������������������
						lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
						If !lRet .Or. !Eval(bFiltro)
							dbSkip()
							Loop
						EndIf
						
						//�����������������������������Ŀ
						//� Tratamento das Devolu�oes   �
						//�������������������������������
						If mv_par10 == 1 //inclui Devolucoes
							//SomaDev(@nDevQtd, @nDevVal , @aDev, cEstoq, cDupli)
						EndIf
						
						nTotQuant += (cSD2)->D2_QUANT
						dbSkip()
						
					EndDo
					
					//���������������������������������������������Ŀ
					//� Verifica se processou algum registro        �
					//�����������������������������������������������
					If nReg > 0
						dbGoto(nReg)
						nReg:=0
					EndIf
					
				Else
					//�����������������������������Ŀ
					//� Tratamento das devolucoes   �
					//�������������������������������
					nDevQtd :=0
					nDevVal :=0
					
					//If mv_par10 == 1 //inclui Devolucoes
					//SomaDev(@nDevQtd, @nDevVal , @aDev, cEstoq, cDupli)
					//EndIf
					
					nTotQuant := (cSD2)->D2_QUANT
					
				EndIf
				
				//����������������������������������������������������������Ŀ
				//� Imprime os dados da NF                                   �
				//������������������������������������������������������������
				SB1->(dbSeek(xFilial("SB1")+(cSD2)->D2_COD))
				If mv_par16 = 1
					cDescProd := SB1->B1_DESC
				Else
					If SA7->(dbSeek(xFilial("SA7")+(cSD2)->(D2_COD+D2_CLIENTE+D2_LOJA)))
						cDescProd := SA7->A7_DESCCLI
					Else
						cDescProd := SB1->B1_DESC
					Endif
				EndIf
				
				SF2->(dbSeek(xFilial("SF2")+(cSD2)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
				cUM      := (cSD2)->D2_UM
				cDoc     := (cSD2)->D2_DOC
				cItemCC	 := (cSD2)->D2_ITEMCC
				cSerie   := (cSD2)->D2_SERIE
				dEmissao := DtoC((cSD2)->D2_EMISSAO)
			
				//����������������������������������������������������������Ŀ
				//� Faz Verificacao da Moeda Escolhida e Imprime os Valores  �
				//������������������������������������������������������������
				nVlrUnit := xMoeda((cSD2)->D2_PRCVEN,SF2->F2_MOEDA,MV_PAR09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				If (cSD2)->D2_TIPO $ "CIP"
					nVlrTot:= nVlrUnit
				Else	
					If (cSD2)->D2_GRADE == "S" .And. MV_PAR12 == 1 // Aglutina Grade
						nVlrTot:= nVlrUnit * nTotQuant
					Else
						nVlrTot:=xmoeda((cSD2)->D2_TOTAL,SF2->F2_MOEDA,mv_par09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
					EndIf
				EndIf
				
				nVlrFre	 := (cSD2)->D2_VALFRE
				nVlrPIS  := (cSD2)->D2_VALIMP6
				nVlrCOFIN:= (cSD2)->D2_VALIMP5
				nVlrICMS := (cSD2)->D2_VALICM
				nVlrST   := (cSD2)->D2_ICMSRET
				nVlrIcCom:= (cSD2)->D2_ICMSCOM
				nVlrIcDif:= (cSD2)->D2_DIFAL
				nVlrFecp := (cSD2)->D2_VFCPDIF
				nVlrIPI  := (cSD2)->D2_VALIPI
				nVlrSeg  := (cSD2)->D2_SEGURO
				nVlrDesp := (cSD2)->D2_DESPESA
				nVlrAcrs := (cSD2)->D2_VALACRS	
				
				//nVlrNet  := nVlrTot - nVlrPIS - nVlrCOFIN - nVlrICMS - nVlrST - nVlrIcCom - nVlrIcDif - nVlrFecp
				//VYB - 26/07/2016 - Altera��o do c�lculo da coluna Net Sales - Solicitado por Rosi Baldini
				nVlrNet  := (nVlrTot + nVlrFre + nVlrSeg + nVlrDesp + nVlrAcrs + nVlrST + nVlrIPI) - ;
				            (nVlrPIS + nVlrCOFIN + nVlrICMS + nVlrIcCom + nVlrIcDif + nVlrFecp + nVlrIPI + nVlrST)                                                                                                 
				
				cCodProd 	:= Eval(bGrade)
				A780Vend(@cVends,nVend)                                                	
				cVendedores := cVends
				cVends 		:= Subs(cVendedores,1,7)

				oReport:Section(1):Section(1):PrintLine()
				
				//����������������������������������������������������������Ŀ
				//� Impressao dos Vendedores                                 �
				//������������������������������������������������������������
				oReport:section(1):section(1):Cell("CCODPROD"	):Hide()
				oReport:section(1):section(1):Cell("CDESCPROD"	):Hide()
				oReport:section(1):section(1):Cell("CITEMCC"	):Hide()

				oReport:section(1):section(1):Cell("CDOC"		):Hide()
				oReport:section(1):section(1):Cell("CSERIE"	)    :Hide()
				oReport:section(1):section(1):Cell("DEMISSAO"	):Hide()
				oReport:section(1):section(1):Cell("CUM"		):Hide()
				oReport:section(1):section(1):Cell("NTOTQUANT"	):Hide()
				oReport:section(1):section(1):Cell("NVLRUNIT"	):Hide()
				oReport:section(1):section(1):Cell("NVLRTOT"	):Hide()
				
				nTotQuant := 0		// Zera variaveis para que nao sejam somadas novamente nos totalizadores
				nVlrTot   := 0		// na impressao dos outros vendedores
				For nV := 8 to Len(cVendedores)
					cVends := Space(20)+Subs(cVendedores,nV,7)
				   	oReport:Section(1):Section(1):PrintLine()
					nV += 6
				Next
				
				oReport:section(1):section(1):Cell("CCODPROD"	):Show()
				oReport:section(1):section(1):Cell("CDESCPROD"	):Show()
				oReport:section(1):section(1):Cell("CITEMCC"	):Show()
				oReport:section(1):section(1):Cell("CDOC"		):Show()
				oReport:section(1):section(1):Cell("CSERIE"	    ):Show()
				oReport:section(1):section(1):Cell("DEMISSAO"	):Show()
				oReport:section(1):section(1):Cell("CUM"		):Show()
				oReport:section(1):section(1):Cell("NTOTQUANT"	):Show()
				oReport:section(1):section(1):Cell("NVLRUNIT"	):Show()
				oReport:section(1):section(1):Cell("NVLRTOT"	):Show()
				
				nTotQuant := 0

   			    //RSB - 28/05/2017 - NEOGEN - As devolu��es aparecem no relat�rio na linha de cima e depois n� aparecem.
				If mv_par10 == 1 //inclui Devolucoes
					SomaDev(@nDevQtd, @nDevVal , @aDev, cEstoq, cDupli,cAliasSA1)
				EndIf 
				
				(cSD2)->(dbSkip())
	   
			EndDo
			
	
			//����������������������������������������������������������Ŀ
			//� Imprime o total do produto selecionado                   �
			//������������������������������������������������������������
			oReport:Section(1):Section(1):SetTotalText(STR0022 + cProdAnt)	// "TOTAL DO PRODUTO - "
			oReport:Section(1):Section(1):Finish()
		EndDo
		
		oReport:Section(1):SetTotalText(STR0023 + cClieAnt)	// "TOTAL DO CLIENTE - "
	   
		If !lNewCli
			oReport:section(1):Finish()                                    '
		EndIf	
		cClieAnt := ""
		cLojaAnt := ""
		cNomeCli := ""
		cGRPVEN  := ""
		cDGRPVEN := ""  
		cEstado  := ""
		cNreduz  := ""
        cNomVend := ""
		
	EndIf
	//�������������������������������������������������������������Ŀ
	//� Procura pelas devolucoes dos clientes que nao tem NF SAIDA  �
	//���������������������������������������������������������������
	DbSelectArea(cSD1)
	If DbSeek(xFilial("SD1")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)
		lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
		//����������������������������������������������������������Ŀ
		//� Procura as devolucoes do periodo, mas que nao pertencem  �
		//� as NFS ja impressas do cliente selecionado               �
		//������������������������������������������������������������
		If mv_par10 == 1  // Inclui Devolucao
			
			//��������������������������Ŀ
			//� Soma Devolucoes          �
			//����������������������������
			oReport:Section(1):Init()
			While !oReport:Cancel() .And. (cSD1)->(D1_FILIAL + D1_FORNECE + D1_LOJA) == ;
				( xFilial("SD1") + (cAliasSA1)->A1_COD+ (cAliasSA1)->A1_LOJA)  .AND. ! Eof()
				lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
				
				//�������������������������������������Ŀ
				//� Verifica Vendedores da N.F.Original �
				//���������������������������������������
				
				CtrlVndDev := .F.
				lNfD2Ori   := .F.
				If AvalTes((cSD1)->D1_TES,cEstoq,cDupli)
					dbSelectArea("SD2")
					nSavOrd := IndexOrd()
					dbSetOrder(3)

					dbSeek(xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD))
					While !oReport:Cancel() .And. !Eof() .And. (xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD)) == ;
						D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
					
						lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
					
						If !Empty((cSD1)->D1_ITEMORI) .AND. AllTrim((cSD1)->D1_ITEMORI) != D2_ITEM .Or. !lRet .Or. !Eval(bFiltro)
							dbSkip()
							Loop
						Else
							CtrlVndDev := A780Vend(@cVends,nVend)
							If Ascan(aDev,D2_CLIENTE + D2_LOJA + D2_COD + D2_DOC + D2_SERIE + D2_ITEM) > 0
								lNfD2Ori := .T.
							EndIf
						Endif
						dbSkip()
					End
				
					dbSelectArea("SD2")
					dbSetOrder(nSavOrd)
					dbSelectArea(cSD1)
				
					If !(CtrlVndDev) .Or. lNfD2Ori
						dbSkip()
						Loop
					EndIf
				
					SF1->(dbSeek(xFilial("SF1")+(cSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
					cUM := (cSD1)->D1_UM
					cDoc := (cSD1)->D1_DOC
					cSerie := (cSD1)->D1_SERIE
					dEmissao := DtoC((cSD1)->D1_EMISSAO)
					nVlrTot:=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,(cSD1)->D1_DTDIGIT,nDecs,SF1->F1_TXMOEDA)
					oReport:Section(1):Section(1):PrintLine()
					//VYB
					
				Endif
				dbSkip()
			EndDo
		EndIf
		
	Endif
	
	DbSelectArea(cAliasSA1)
	(cAliasSA1)->(DbSkip())
EndDo

(cSD1)->(DbCloseArea())
(cSD2)->(DbCloseArea())

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR780R3� Autor � Gilson do Nascimento  � Data � 01.09.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Vendas por Cliente, quantidade de cada Produto  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR780(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Bruno        �05.04.00�Melhor�Acertar as colunas para 12 posicoes.    ���
��� Marcello     �29/08/00�oooooo�Impressao de casas decimais de acordo   ���
���              �        �      �com a moeda selecionada e conversao     ���
���              �        �      �(xmoeda)baseada na moeda gravada na nota���
��� Rubens Pante �04/07/01�Melhor�Utilizacao de SELECT nas versoes TOP    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Matr780R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL tamanho:=IIF(cPaisLoc=="MEX","G","M")
LOCAL titulo := OemToAnsi(STR0001)	//"Estatisticas de Vendas (Cliente x Produto)"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cString:= "SD2"

PRIVATE aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="UMATR780"
PRIVATE nLastKey := 0
PRIVATE cPerg   :="UMR780A"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("UMR780A   ",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // De Cliente                           �
//� mv_par02             // Ate Cliente                          �
//� mv_par03             // De Data                              �
//� mv_par04             // Ate a Data                           �
//� mv_par05             // De Produto                           �
//� mv_par06             // Ate o Produto                        �
//� mv_par07             // Do Vendedor                          �
//� mv_par08             // Ate Vendedor                         �
//� mv_par09             // Moeda                                �
//� mv_par10             // Inclui Devolu��o                     �
//� mv_par11             // Mascara do Produto                   �
//� mv_par12             // Aglutina Grade                       �
//� mv_par13	// Quanto a Estoque Movimenta/Nao Movta/Ambos    �
//� mv_par14	// Quanto a Duplicata Gera/Nao Gera/Ambos        �
//� mv_par15   // Quanto a Devolucao NF Original/NF Devolucao    �
//� mv_par16   // Quanto a Descricao  Produto  Prod x Cli.       �
//� mv_par17   // converte moeda da devolucao                    �
//� mv_par18             // De Grupo Cliente                     �
//� mv_par19             // Ate Grupo Cliente                    �
//� mv_par20             // De Grupo Produto                     �
//� mv_par21             // Ate Grupo Produto                    �


//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com o tipo de emissao            �
//����������������������������������������������������������������
titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := STR0007	//"CLIENTE   RAZAO SOCIAL"
Cabec2 := STR0008   //"PRODUTO         DESCRICAO                  NOTA FISCAL        EMISSAO   UN   QUANTIDADE    PRECO UNITARIO            TOTAL  VENDEDOR"
// 123456789012345 123456789012345678901234567890 123456/123 12/12/1234 123456789012 1234567890123456 1234567890123456 123456/123456/123456/123456/123456

wnrel:="UMATR780"

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.T.)

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C780Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C780IMP  � Autor � Rosane Luciane Chene  � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR780                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C780Imp(lEnd,WnRel,cString)

LOCAL CbTxt
LOCAL CbCont,cabec1,cabec2,cabec3
LOCAL nTotCli1:= 0,nTotCli2:=0,nTotGer1 := 0,nTotGer2 := 0
LOCAL nOrdem
LOCAL tamanho:= "M"
LOCAL limite := IIF(cPaisLoc=="MEX",144,132)
LOCAL titulo := OemToAnsi(STR0006)	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cMoeda
LOCAL nAcN1  := 0, nAcN2 := 0, nV := 0
LOCAL cClieAnt := "", cProdAnt := "", cLojaAnt := ""
LOCAL lContinua := .T. , lProcessou := .F. , lNewProd := .T.
LOCAL cMascara :=GetMv("MV_MASCGRD")
LOCAL nTamRef  :=Val(Substr(cMascara,1,2))
LOCAL nTamLin  :=Val(Substr(cMascara,4,2))
LOCAL nTamCol  :=Val(Substr(cMascara,7,2))
LOCAL cProdRef :=""
//Local cUM      :=""
LOCAL nTotQuant:=0
LOCAL nReg     :=0
LOCAL cFiltro  := ""
Local cEstoq := If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ))
Local cDupli := If( (mv_par14 == 1),"S",If( (mv_par14 == 2),"N","SN" ))
Local cArqTrab1, cArqTrab2, cCondicao1
Local aDevImpr := {}
//Local cVends   := ""
Local nVend    := FA440CntVend()
Local nDevQtd 	:= 0
Local nDevVal 	:= 0
Local aDev		:={}
Local nIndD2    := 0
Local cQuery, aStru
Local lNfD2Ori   := .F. 
// variaveis criadas para realinhamento das colunas para o Mexico (factura com 20 digitos)
Local aColuna   := IIf(cPaisLoc=="MEX",{46,71,82,86,99,116,135},{46,61,72,76,89,106,125})
#IFDEF TOP
	Local nj := 0
	Local cAliasSA1 := "SA1"
#ENDIF

Private cSD1, cSD2
Private nIndD1  :=0
Private nDecs:=msdecimais(mv_par09)
//��������������������������������������������������������������Ŀ
//� Seleciona ordem dos arquivos consultados no processamento    �
//����������������������������������������������������������������
SF1->(dbsetorder(1))
SF2->(dbsetorder(1))
SB1->(dbSetOrder(1))
SA7->(dbSetOrder(2))

//��������������������������������������������������������������Ŀ
//� Monta o Cabecalho de acordo com o tipo de emissao            �
//����������������������������������������������������������������
titulo := STR0006	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := STR0009	//"CLIENTE  RAZAO SOCIAL"

Cabec2 := STR0008   //"PRODUTO         DESCRICAO                  NOTA FISCAL        EMISSAO   UN   QUANTIDADE   PRECO UNITARIO             TOTAL  VENDEDOR"
If cPaisLoc=="MEX"
   Cabec2 := Substr(Cabec2,1,54)+space(10)+Substr(Cabec2,55)
EndIf

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cMoeda := STR0010+GetMV("MV_SIMB"+Str(mv_par09,1))		//"Valores em "
titulo := titulo+" "+cMoeda

//��������������������������������������������������������������Ŀ
//� Cria filtro para impressao das devolucoes                    �
//� *** este filtro possui 208 posicoes  ***                     �
//����������������������������������������������������������������
dbSelectArea("SD1")
cArqTrab1  := CriaTrab( "" , .F. )
#IFDEF TOP
    If (TcSrvType()#'AS/400')
        //��������������������������������Ŀ
        //� Query para SQL                 �
        //����������������������������������
	    cSD1   := "SD1TMP"
	    aStru  := dbStruct()
	    cQuery := "SELECT * FROM " + RetSqlName("SD1") + " SD1 "
	    cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
	    cQuery += "SD1.D1_FORNECE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
	    cQuery += "SD1.D1_DTDIGIT BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' AND "
	    cQuery += "SD1.D1_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
	    cQuery += "SD1.D1_TIPO = 'D' AND "
    	 cQuery += " NOT ("+IsRemito(3,'SD1.D1_TIPODOC')+ ") AND "
	    cQuery += "SD1.D_E_L_E_T_ <> '*' "
	    cQuery += " ORDER BY SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_COD"
	    cQuery := ChangeQuery(cQuery)
	    MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'SD1TRB', .F., .T.)},OemToAnsi(STR0011)) //"Seleccionado registros"
	    For nj := 1 to Len(aStru)
		    If aStru[nj,2] != 'C'
			   TCSetField('SD1TRB', aStru[nj,1], aStru[nj,2],aStru[nj,3],aStru[nj,4])
		    EndIf	
	    Next nj
	    A780CriaTmp(cArqTrab1, aStru, cSD1, "SD1TRB")
	    IndRegua(cSD1,cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD",,".T.",STR0011)		//"Selecionando Registros..."
	Else    
#ENDIF
	    cSD1	   := "SD1"
	    cCondicao1 := 'D1_FILIAL=="' + xFilial("SD1") + '".And.'
	    cCondicao1 += 'D1_FORNECE>="' + mv_par01 + '".And.'
	    cCondicao1 += 'D1_FORNECE<="' + mv_par02 + '".And.'
	    cCondicao1 += 'DtoS(D1_DTDIGIT)>="' + DtoS(mv_par03) + '".And.'
	    cCondicao1 += 'DtoS(D1_DTDIGIT)<="' + DtoS(mv_par04) + '".And.'
	    cCondicao1 += 'D1_COD>="' + mv_par05 + '".And.'
	    cCondicao1 += 'D1_COD<="' + mv_par06 + '".And.'
	    cCondicao1 += 'D1_TIPO=="D" .And. !('+IsRemito(2,'SD1->D1_TIPODOC')+')'		

	    cArqTrab1  := CriaTrab("",.F.)
	    IndRegua(cSD1,cArqTrab1,"D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD",,cCondicao1,STR0011)		//"Selecionando Registros..."
	    nIndD1 := RetIndex()

        #IFNDEF TOP	    
	       dbSetIndex(cArqTrab1+ordBagExt())
        #ENDIF

	    dbSetOrder(nIndD1+1)
#IFDEF TOP
    Endif  	    
#ENDIF   

dbSeek(xFilial("SD1"))

//��������������������������������������������������������������Ŀ
//� Monta filtro para processar as vendas por cliente            �
//����������������������������������������������������������������
DbSelectArea("SD2")
cFiltro := SD2->(dbFilter())
If Empty(cFiltro)
	bFiltro := { || .T. }
Else
	cFiltro := "{ || " + cFiltro + " }"
	bFiltro := &(cFiltro)
Endif
//��������������������������������������������������������������Ŀ
//� Monta filtro para processar as vendas por cliente            �
//����������������������������������������������������������������
cArqTrab2  := CriaTrab( "" , .F. )
#IFDEF TOP            
    If (TcSrvType()#'AS/400')
        //��������������������������������Ŀ
        //� Query para SQL                 �
        //����������������������������������
	    cSD2   := "SD2TMP"
	    aStru  := dbStruct()
	    cQuery := "SELECT * FROM " + RetSqlName("SD2") + " SD2 "
	    cQuery += "WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
	    cQuery += "SD2.D2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
	    cQuery += "SD2.D2_EMISSAO BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' AND "
	    cQuery += "SD2.D2_COD     BETWEEN '"+ mv_par05+"' AND '"+mv_par06+"' AND "
	    cQuery += "SD2.D2_TIPO <> 'B' AND SD2.D2_TIPO <> 'D' AND "
    	 cQuery += " NOT ("+IsRemito(3,'SD2.D2_TIPODOC')+ ") AND "
	    cQuery += "SD2.D_E_L_E_T_ <> '*' "
	    cQuery += "ORDER BY SD2.D2_FILIAL,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SD2.D2_ITEM"
	    cQuery := ChangeQuery(cQuery)
	    MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'SD2TRB', .F., .T.)},OemToAnsi(STR0011)) //"Seleccionado registros"
	    For nj := 1 to Len(aStru)
		    If aStru[nj,2] != 'C'
			    TCSetField('SD2TRB', aStru[nj,1], aStru[nj,2],aStru[nj,3],aStru[nj,4])
		    EndIf	
	    Next nj

	    A780CriaTmp(cArqTrab2, aStru, cSD2, "SD2TRB")
	    IndRegua(cSD2,cArqTrab2,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_COD+D2_SERIE+D2_DOC+D2_ITEM",,".T.",STR0011)		//"Selecionando Registros..."
    Else
#ENDIF                   
	    cSD2	  := "SD2"
	    cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .And. '
	    cCondicao += 'D2_CLIENTE >= "' + mv_par01 + '" .And. '
	    cCondicao += 'D2_CLIENTE <= "' + mv_par02 + '" .And. '
	    cCondicao += 'DTOS(D2_EMISSAO) >= "' + DTOS(mv_par03) + '" .And. '
	    cCondicao += 'DTOS(D2_EMISSAO) <= "' + DTOS(mv_par04) + '" .And. '
	    cCondicao += 'D2_COD >= "' + mv_par05 + '" .And. '
	    cCondicao += 'D2_COD <= "' + mv_par06 + '" .And. '
	    cCondicao += '!(D2_TIPO $ "BD")'
	    cCondicao += '.And. !('+IsRemito(2,'SD2->D2_TIPODOC')+')'		
 
	    IndRegua(cString,cArqTrab2,"D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_COD+D2_SERIE+D2_DOC+D2_ITEM",,cCondicao,STR0011)		//"Selecionando Registros..."
	    nIndD2 := RetIndex()

        #IFNDEF TOP	    
	       dbSetIndex(cArqTrab2+ordBagExt())
        #ENDIF
        
	    dbSetOrder(nIndD2+1)
#IFDEF TOP	    
	Endif    
#ENDIF


dbSelectArea("SA1")                       	
dbSetOrder(1)
#IFDEF TOP
    cAliasSA1 := GetNextAlias()
    aStru  := dbStruct()
    cQuery := "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_OBSERV "    
    cQuery += "FROM " + RetSqlName("SA1") + " SA1 "
    cQuery += "WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
    cQuery += "SA1.A1_COD >= '"        +MV_PAR01+"' AND "
	cQuery += "SA1.A1_COD <= '"        +MV_PAR02+"' AND "
    cQuery += "SA1.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY "+SqlOrder(SA1->(IndexKey()))
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSA1, .F., .T.)
#ELSE
	cAliasSA1 := "SA1"
#ENDIF

//��������������������������������������������������������������Ŀ
//� Verifica se aglutinara produtos de Grade                     �
//����������������������������������������������������������������
SetRegua(RecCount())		// Total de Elementos da regua

If ( (cSD2)->D2_GRADE=="S" .And. MV_PAR12 == 1)
	lGrade := .T.
	bGrade := { || Substr((cSD2)->D2_COD, 1, nTamref) }
Else
	lGrade := .F.
	bGrade := { || (cSD2)->D2_COD }
Endif
//��������������������������������������������������������������Ŀ
//� Procura pelo 1o. cliente valido                              �
//����������������������������������������������������������������
#IFNDEF TOP
	dbSeek(xFilial()+mv_par01, .t.)
#ENDIF

While (cAliasSA1)->( ! EOF() .AND. A1_COD <= MV_PAR02 ) .And. lContinua .And. (cAliasSA1)->A1_FILIAL == xFilial("SA1")
	
	If lEnd
		@Prow()+1,001 Psay STR0012	//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIf
	
	lNewCli := .T.
	
	//����������������������������������������������������������Ŀ
	//� Procura pelas saidas daquele cliente                     �
	//������������������������������������������������������������
	DbSelectArea(cSD2)
	If DbSeek(xFilial("SD2")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)
		lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
		
		//����������������������������������������������������������Ŀ
		//� Montagem da quebra do relatorio por  Cliente             �
		//������������������������������������������������������������
		cClieAnt := (cAliasSA1)->A1_COD
		cLojaAnt := (cAliasSA1)->A1_LOJA
		cNomeCli := (cAliasSA1)->A1_NOME
		lNewProd := .T.
		lNewCli  := .T.
		nTotCli1 := 0
		nTotCli2 := 0
		While !Eof() .and. ;
			((cSD2)->(D2_FILIAL+D2_CLIENTE+D2_LOJA)) == (xFilial("SD2")+cClieAnt+cLojaAnt)
			
			//����������������������������������������������������������Ŀ
			//� Verifica Se eh uma tipo de nota valida                   �
			//� Verifica intervalo de Codigos de Vendedor                �
			//� Valida o produto conforme a mascara                      �
			//������������������������������������������������������������
			lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
			If	! Eval(bFiltro) .Or. !A780Vend(@cVends,nVend) .Or. !lRet //.or. SD2->D2_TIPO$"BD" ja esta no filtro
				dbSkip()
				Loop
			EndIf
			
			//����������������������������������������������������������Ŀ
			//� Impressao do Cabecalho.                                  �
			//������������������������������������������������������������
			If Li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				lProcessou := .T.
			EndIf
			
			
			//����������������������������������������������������������Ŀ
			//� Impressao da quebra por produto e NF                   �
			//������������������������������������������������������������
			cProdAnt := Eval(bGrade)
			lNewProd := .T.
			
			While ! Eof() .And. ;
				(cSD2)->(D2_FILIAL + D2_CLIENTE + D2_LOJA  + EVAL(bGrade) ) == ;
				( xFilial("SD2") + cClieAnt   + cLojaAnt + cProdAnt )
				IncRegua()
				
				//����������������������������������������������������������Ŀ
				//� Avalia TES                                               �
				//������������������������������������������������������������
				lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
				If !AvalTes((cSD2)->D2_TES,cEstoq,cDupli) .Or. !Eval(bFiltro) .Or. !lRet
					dbSkip()
					Loop
				Endif
				
				If !A780Vend(@cVends,nVend)
					dbskip()
					Loop
				Endif
				
				//����������������������������������������������������������Ŀ
				//� Impressao  dos dados do Cliente                          �
				//������������������������������������������������������������
				If lNewCli
					
					If Li > 51
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
						lProcessou := .T.
					EndIf
					
					@ Li,000 Psay Repli('-',limite)
					Li++
					@ Li,000 Psay (cSD2)->D2_CLIENTE+"   "+(cAliasSA1)->A1_NOME
					If !Empty((cAliasSA1)->A1_OBSERV)
						Li++
						@ Li,000 Psay STR0013+(cAliasSA1)->A1_OBSERV		//"Obs.: "
					EndIf
					Li++
					lNewCli := .F.
				Endif
				
				//����������������������������������������������������������Ŀ
				//� Impressao do Cabecalho.                                  �
				//������������������������������������������������������������
				If li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					@ Li,000 Psay Repli('-',limite)
					Li++
					@ Li,000 Psay (cSD2)->D2_CLIENTE+"   "+(cAliasSA1)->A1_NOME
					If !Empty((cAliasSA1)->A1_OBSERV)
						Li++
						@ Li,000 Psay STR0013+(cAliasSA1)->A1_OBSERV		//"Obs.: "
					EndIf
					Li+=2
				EndIf
				
				//����������������������������������������������������������Ŀ
				//� Faz Impressao de Codigo e Descricao Do Produto.          �
				//������������������������������������������������������������
				If lNewProd
					lNewProd := .F.
					Li+=2
					@Li ,  0 Psay Eval(bGrade)
					SB1->(dbSeek(xFilial("SB1")+(cSD2)->D2_COD))
					If mv_par16 = 1
						@li , 16 Psay Substr(SB1->B1_DESC,1,28)
					Else
						If SA7->(dbSeek(xFilial("SA7")+(cSD2)->(D2_COD+D2_CLIENTE+D2_LOJA)))
							@li , 16 Psay Substr(SA7->A7_DESCCLI,1,30)
						Else
							@li , 16 Psay Substr(SB1->B1_DESC,1,28)
						Endif
					EndIf
				EndIf
				
				//����������������������������������������������������������Ŀ
				//� Caso seja grade aglutina todos produtos do mesmo Pedido  �
				//������������������������������������������������������������
				If lGrade  // Aglutina Grade
					cProdRef:= Substr((cSD2)->D2_COD,1,nTamRef)
					cNumPed := (cSD2)->D2_PEDIDO
					nReg    := 0
					nDevQtd :=0
					nDevVal :=0
					
					While !Eof() .And. cProdRef == Eval(bGrade) .And.;
						(cSD2)->D2_GRADE == "S" .And. cNumPed == (cSD2)->D2_PEDIDO .And.;
						(cSD2)->D2_FILIAL == xFilial("SD2")
						
						nReg := Recno()
						//���������������������������������������������Ŀ
						//� Valida o produto conforme a mascara         �
						//�����������������������������������������������
						lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
						If !lRet .Or. !Eval(bFiltro)
							dbSkip()
							Loop
						EndIf
						
						//�����������������������������Ŀ
						//� Tratamento das Devolu�oes   �
						//�������������������������������
						If mv_par10 == 1 //inclui Devolucoes
							//SomaDev(@nDevQtd, @nDevVal , @aDev, cEstoq, cDupli)
						EndIf
						
						nTotQuant += (cSD2)->D2_QUANT
						dbSkip()
						
					EndDo
					
					//���������������������������������������������Ŀ
					//� Verifica se processou algum registro        �
					//�����������������������������������������������
					If nReg > 0
						dbGoto(nReg)
						nReg:=0
					EndIf
					
				Else
					//�����������������������������Ŀ
					//� Tratamento das devolucoes   �
					//�������������������������������
					nDevQtd :=0
					nDevVal :=0
					
					If mv_par10 == 1 //inclui Devolucoes
						//SomaDev(@nDevQtd, @nDevVal , @aDev, cEstoq, cDupli)
					EndIf
					
					nTotQuant := (cSD2)->D2_QUANT
					
				EndIf
				
				//����������������������������������������������������������Ŀ
				//� Imprime os dados da NF                                   �
				//������������������������������������������������������������
				
				SF2->(dbSeek(xFilial("SF2")+(cSD2)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
				cUM := (cSD2)->D2_UM
				
				@Li , aColuna[1] Psay (cSD2)->(D2_DOC+'/'+D2_SERIE)
				@Li , aColuna[2] Psay (cSD2)->D2_EMISSAO
				@Li , aColuna[3] Psay cUM
				@Li , aColuna[4] Psay nTotQuant          PICTURE PesqPictqt("D2_QUANT",14)
				
				nAcN1 += nTotQuant
				
				//����������������������������������������������������������Ŀ
				//� Faz Verificacao da Moeda Escolhida e Imprime os Valores  �
				//������������������������������������������������������������
				nVlrUnit := xMoeda((cSD2)->D2_PRCVEN,SF2->F2_MOEDA,MV_PAR09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				@Li , aColuna[5] Psay nVlrUnit           PICTURE PesqPict("SD2","D2_PRCVEN",14,mv_par09)
				
				If (cSD2)->D2_TIPO $ "CIP"
					@Li ,aColuna[6] Psay nVlrUnit        PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					nAcN2 += nVlrUnit
				Else
					If (cSD2)->D2_GRADE == "S" .And. MV_PAR12 == 1 // Aglutina Grade
						nVlrTot:= nVlrUnit * nTotQuant
						@Li ,aColuna[6] Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					Else
						nVlrTot:=xmoeda((cSD2)->D2_TOTAL,SF2->F2_MOEDA,mv_par09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
						@Li ,aColuna[6] Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					EndIf
					nAcN2 += nVlrTot
				EndIf

				A780Vend(@cVends,nVend)
				@Li, aColuna[7] Psay Subs(cVends,1,7)
				For nV := 8 to Len(cVends)
					li ++
					@Li, aColuna[7] Psay Subs(cVends,nV,7)
					nV += 6
				Next

				//����������������������������������������������������������Ŀ
				//� Imprime as devolucoes do produto selecionado             �
				//������������������������������������������������������������
				/*
				If nDevQtd!=0
					Li++
					@Li,053 Psay STR0017 // "DEV"
					nVlrTot := nDevVal
					@Li,aColuna[3] Psay cUM
					@Li,aColuna[4] Psay nDevQtd          PICTURE "@)"+PesqPictqt("D2_QUANT",14)
					@Li,aColuna[6] Psay nVlrTot          PICTURE "@)"+PesqPict("SD2","D2_TOTAL",16,mv_par09)
					nAcN1+= nDevQtd
					nAcN2+= nVlrTot
				EndIf
				*/
				Li++
				nTotQuant := 0
				dbSkip()
				
			EndDo
			
			
			//����������������������������������������������������������Ŀ
			//� Acumula o total geral do relatorio                       �
			//������������������������������������������������������������
			nTotGer1 += nAcN1
			nTotGer2 += nAcN2
			
			//����������������������������������������������������������Ŀ
			//� Acumula o total por cliente                              �
			//������������������������������������������������������������
			nTotCli1 += nAcN1
			nTotCli2 += nAcN2
			
			//����������������������������������������������������������Ŀ
			//� Imprime o total do produto selecionado                   �
			//������������������������������������������������������������
			If nAcN1#0 .Or. nAcN2#0	.Or. nDevQtd#0
				Li++
				@Li ,  07 Psay STR0014+cProdAnt	//"TOTAL DO PRODUTO - "
				@Li ,  52 Psay "---->"
				@Li , aColuna[3] Psay cUM
				@Li , aColuna[4] Psay nAcN1 PICTURE PesqPictqt("D2_QUANT",14)
				@Li , aColuna[6] Psay nAcN2 PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
				nAcN1 := 0
				nAcN2 := 0
				cProdAnt := (cSD2)->D2_COD
			EndIf
			
		EndDo
		//����������������������������������������������������������Ŀ
		//� Ocorreu quebra por cliente                               �
		//������������������������������������������������������������
		If !(lNewCli)
			LI+=2
			@Li , 07 Psay STR0015+cClieAnt+'/'+cLojaAnt	//"TOTAL DO CLIENTE - "
			@Li , 52 Psay "---->"
			@Li ,aColuna[4] Psay nTotCli1 PICTURE PesqPictqt("D2_QUANT",16)
			@Li ,aColuna[6] Psay nTotCli2 PICTURE PesqPict("SD2","D2_TOTAL",18,mv_par09)
			LI++
		EndIf
		cClieAnt := ""
		cLojaAnt := ""
		cNomeCli := ""
		nTotCli1 := 0
		nTotCli2 := 0
		
	EndIf
	//�������������������������������������������������������������Ŀ
	//� Procura pelas devolucoes dos clientes que nao tem NF SAIDA  �
	//���������������������������������������������������������������
	nTotCli1 := 0
	nTotCli2 := 0
	DbSelectArea(cSD1)
	If DbSeek(xFilial("SD1")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)
		lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
		//����������������������������������������������������������Ŀ
		//� Procura as devolucoes do periodo, mas que nao pertencem  �
		//� as NFS ja impressas do cliente selecionado               �
		//������������������������������������������������������������
		If mv_par10 == 1  // Inclui Devolucao
			
			//��������������������������Ŀ
			//� Soma Devolucoes          �
			//����������������������������
			While (cSD1)->(D1_FILIAL + D1_FORNECE + D1_LOJA) == ;
				( xFilial("SD1") + (cAliasSA1)->A1_COD+ (cAliasSA1)->A1_LOJA)  .AND. ! Eof()
				lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
				
				//�������������������������������������Ŀ
				//� Verifica Vendedores da N.F.Original �
				//���������������������������������������
				
				CtrlVndDev := .F.
				lNfD2Ori   := .F.
				If AvalTes((cSD1)->D1_TES,cEstoq,cDupli)
					dbSelectArea("SD2")
					nSavOrd := IndexOrd()
					dbSetOrder(3)

					dbSeek(xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD))
					While !Eof() .And. (xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD)) == ;
						D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
					
						lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
					
						If !Empty((cSD1)->D1_ITEMORI) .AND. AllTrim((cSD1)->D1_ITEMORI) != D2_ITEM .Or. !lRet .Or. !Eval(bFiltro)
							dbSkip()
							Loop
						Else
							CtrlVndDev := A780Vend(@cVends,nVend)
							If Ascan(aDev,D2_CLIENTE + D2_LOJA + D2_COD + D2_DOC + D2_SERIE + D2_ITEM) > 0
								lNfD2Ori := .T.
							EndIf
						Endif
						dbSkip()
					End
				
					dbSelectArea("SD2")
					dbSetOrder(nSavOrd)
					dbSelectArea(cSD1)
				
					If !(CtrlVndDev) .Or. lNfD2Ori
						dbSkip()
						Loop
					EndIf
				
					lProcessou := .t.
				
					If li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					EndIf
				
					If lNewCli
					
						If li > 51
							cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
						EndIf
					
						@ Li,000 Psay Repli('-',limite)
					
						Li++
						@ Li,000 Psay (cAliasSA1)->A1_COD
						@ Li,009 Psay (cAliasSA1)->A1_NOME
						If !Empty((cAliasSA1)->A1_OBSERV)
							Li++
							@ Li,000 Psay STR0013+(cAliasSA1)->A1_OBSERV		//"Obs.: "
						EndIf
					
						Li+=2
					
						lNewCli := .F.
					
					EndIf
				
					LI++
					SF1->(dbSeek(xFilial("SF1")+(cSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
					cUM := (cSD1)->D1_UM
				
					@Li ,  0 Psay (cSD1)->D1_COD
					@li , 16 Psay STR0017 //"DEV"
					@Li , 46 Psay (cSD1)->(D1_DOC+'/'+D1_SERIE) // VERIFICAR PORQUE -
					nVlrTot:=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,(cSD1)->D1_DTDIGIT,nDecs,SF1->F1_TXMOEDA)
					@Li,aColuna[3] Psay cUM
					@Li,aColuna[4] Psay -(cSD1)->D1_QUANT PICTURE "@)"+PesqPictqt("D1_QUANT",14)
					@Li,aColuna[6] Psay -nVlrTot           PICTURE "@)"+PesqPict("SD1","D1_TOTAL",16,mv_par09)
					nTotCli1 -= (cSD1)->D1_QUANT
					nTotCli2 -= nVlrTot
					nTotGer1 -= (cSD1)->D1_QUANT
					nTotGer2 -= nVlrTot
				Endif
				dbSkip()
			EndDo
			
			If (nTotCli1 != 0) .or. (nTotCli2 != 0)
				LI+=2
				@Li , 07 Psay STR0015+(cAliasSA1)->A1_COD	//"TOTAL DO CLIENTE - "
				@Li , 52 Psay "---->"
				@Li ,aColuna[4] Psay nTotCli1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
				@Li ,aColuna[6] Psay nTotCli2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
				LI+=1
			EndIf
			
		EndIf
		
	Endif
	
	DbSelectArea(cAliasSA1)
	DbSkip()
EndDo

If lProcessou
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	Li+=2
	@Li , 07 Psay STR0016		//"T O T A L   G E R A L                        ---->"
    @Li ,aColuna[4] Psay nTotGer1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
    @Li ,aColuna[6] Psay nTotGer2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
	roda(cbcont,cbtxt,tamanho)
Endif

dbSelectArea("SD1")
dbClearFilter()
RetIndex("SD1")

dbSelectArea("SD2")
dbClearFilter()
RetIndex("SD2")

(cSD1)->(DbCloseArea())
(cSD2)->(DbCloseArea())
fErase(cArqTrab1+OrdBagExt())
fErase(cArqTrab2+OrdBagExt())
#IFDEF TOP
    fErase(cArqTrab1+GetDbExtension())
    fErase(cArqTrab2+GetDbExtension())
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A780Vend � Autor � Rogerio F. Guimaraes  � Data � 28.10.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica Intervalo de Vendedores                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR780			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A780Vend(cVends,nVend)
Local cAlias:=Alias(),sVend,sCampo
Local lVend, cVend, cBusca
Local nx
lVend  := .F.
cVends := ""
// Nao tem Alias na frente dos campos do SD2 para poder trabalhar em DBF e TOP
cBusca := xFilial("SF2")+(cSD2)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
dbSelectArea("SF2")
If dbSeek(cBusca)
	cVend := "1"
	For nx := 1 to nVend
		sCampo := "F2_VEND" + cVend
		sVend := FieldGet(FieldPos(sCampo))
		If (sVend >= mv_par07 .And. sVend <= mv_par08) .And. (!Empty(sVend))
			cVends += If(Len(cVends)>0,"/","") + sVend
		EndIf
		If (sVend >= mv_par07 .And. sVend <= mv_par08) .And. (nX == 1 .Or. !Empty(sVend))
			lVend := .T.
		EndIf
		cVend := Soma1(cVend, 1)
	Next
EndIf
dbSelectArea(cAlias)
Return(lVend)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SomaDev  � Autor � Claudecino C Leao     � Data � 28.09.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Soma devolucoes de Vendas                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR780			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SomaDev(nDevQtd, nDevVal, aDev, cEstoq, cDupli,cAliasSA1 )
//VYB - 27/07/2016 - Sinal negativo para itens de devolu��o / Imprimir notas devolvidas sem NF de sa�da
Local DtMoedaDev  := (cSD2)->D2_EMISSAO

(cSD1)->(DbGoTop())
//If (cSD1)->(dbSeek(xFilial("SD1")+(cSD2)->(D2_CLIENTE + D2_LOJA + D2_COD )))
//��������������������������Ŀ
//� Soma Devolucoes          �
//����������������������������
//While (cSD1)->(D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD) == (cSD2)->( xFilial("SD2")+D2_CLIENTE+D2_LOJA+D2_COD).AND.!(cSD1)->(Eof())
While (cSD1)->(!Eof())
//����������������������������������������������������������Ŀ
//� Avalia TES                                               �
//������������������������������������������������������������
	If !AvalTes((cSD1)->D1_TES,cEstoq,cDupli)             
    	(cSD1)->(dbSkip())
		Loop
	Endif

	DtMoedaDev  := IIF(MV_PAR17 == 1,(cSD1)->D1_DTDIGIT,(cSD2)->D2_EMISSAO)

	SF1->(dbSeek(xFilial("SF1")+(cSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))

	If (cSD1)->(D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)) == (cSD2)->(D2_DOC + D2_SERIE + D2_ITEM ) .and.;
		Ascan(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI))) == 0 

		Aadd(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)))
		nDevQtd  -= (cSD1)->D1_QUANT
		nDevVal  -= xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
		nDevFre   -= (cSD1)->D1_VALFRE
		nDevSeg   -= (cSD1)->D1_SEGURO
		nDevDes   -= (cSD1)->D1_DESPESA
		nDevAcr   -= (cSD1)->D1_VALACRS
		nDevPis   -= (cSD1)->D1_VALIMP5
		nDevCof   -= (cSD1)->D1_VALIMP6
		nDevIcms  -= (cSD1)->D1_VALICM
		nDevIcRe  -= (cSD1)->D1_ICMSRET
		nDevIcCo  -= (cSD1)->D1_ICMSCOM
		nDevDif   -= (cSD1)->D1_DIFAL
		nDevIpi   -= (cSD1)->D1_VALIPI
		nDevFecp  -= (cSD1)->D1_VFCPDIF
		nDevNet   -= (xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA) + ;
		(cSD1)->D1_VALFRE + (cSD1)->D1_SEGURO + (cSD1)->D1_DESPESA + (cSD1)->D1_VALACRS + (cSD1)->D1_ICMSRET + (cSD1)->D1_VALIPI) - ;
		((cSD1)->D1_VALIMP5 + (cSD1)->D1_VALIMP6 + (cSD1)->D1_VALICM + (cSD1)->D1_ICMSCOM + (cSD1)->D1_DIFAL + (cSD1)->D1_VFCPDIF + ;
		(cSD1)->D1_VALIPI + (cSD1)->D1_ICMSRET)   
	ElseIf mv_par15 == 2 .And. Ascan(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI))) == 0 

		Aadd(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)))
		NVLRUNIT  := (cSD1)->D1_VUNIT
		
		nDevQtd -= (cSD1)->D1_QUANT
		nDevVal -=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
		nDevFre   -= (cSD1)->D1_VALFRE
		nDevSeg   -= (cSD1)->D1_SEGURO
		nDevDes   -= (cSD1)->D1_DESPESA
		nDevAcr   -= (cSD1)->D1_VALACRS
		nDevPis   -= (cSD1)->D1_VALIMP5
		nDevCof   -= (cSD1)->D1_VALIMP6
		nDevIcms  -= (cSD1)->D1_VALICM
		nDevIcRe  -= (cSD1)->D1_ICMSRET
		nDevIcCo  -= (cSD1)->D1_ICMSCOM
		nDevDif   -= (cSD1)->D1_DIFAL
		nDevIpi   -= (cSD1)->D1_VALIPI
		nDevFecp  -= (cSD1)->D1_VFCPDIF
		nDevNet   -= (xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA) + ;
		(cSD1)->D1_VALFRE + (cSD1)->D1_SEGURO + (cSD1)->D1_DESPESA + (cSD1)->D1_VALACRS + (cSD1)->D1_ICMSRET + (cSD1)->D1_VALIPI) - ;
		((cSD1)->D1_VALIMP5 + (cSD1)->D1_VALIMP6 + (cSD1)->D1_VALICM + (cSD1)->D1_ICMSCOM + (cSD1)->D1_DIFAL + (cSD1)->D1_VFCPDIF + ;
		(cSD1)->D1_VALIPI + (cSD1)->D1_ICMSRET)

	EndIf
	//����������������������������������������������������������Ŀ
	//� Imprime as devolucoes do produto selecionado             �
	//������������������������������������������������������������
	If nDevQtd!=0
		cUM      := (cSD1)->D1_UM
		cDoc     := (cSD1)->D1_DOC
		cItemCC	 := (cSD1)->D1_ITEMCTA
   		cSerie   := (cSD1)->D1_SERIE
   		dEmissao := DtoC((cSD1)->D1_EMISSAO)
   		
   		DbSelectArea("SA1")
   		If DbSeek(xFilial("SA1")+(cSD1)->(D1_FORNECE + D1_LOJA ))
//����������������������������������������������������������Ŀ
//� Montagem da quebra do relatorio por  Cliente             �
//������������������������������������������������������������
			cClieAnt := SA1->A1_COD
			cLojaAnt := SA1->A1_LOJA  
			cNomeCli := SUBSTR(SA1->A1_NOME,1,40)
			cEstado  := SA1->A1_EST 
			cNreduz  := SA1->A1_NREDUZ
    	    cCodProd := (cSD1)->D1_COD
        
        	SB1->(dbSeek(xFilial("SB1")+(cSD1)->D1_COD))
			If mv_par16 = 1
		   		cDescProd := SB1->B1_DESC
	   		Else
		   		If SA7->(dbSeek(xFilial("SA7")+(cSD1)->(D1_COD+D1_FORNECE+D1_LOJA)))
					cDescProd := SA7->A7_DESCCLI
				Else
		  			cDescProd := SB1->B1_DESC
	   	   		Endif
   	  		EndIf    
   			If Empty(SA1->A1_GRPVEN)
   		 		cGRPVEN:="Vazio"
	   		Else
	   	   		cGRPVEN:=SA1->A1_GRPVEN
	   		EndIf
	
	   		ACY->(DbSetOrder(1))
	   		If ACY->(DbSeek(xFilial("ACY")+SA1->A1_GRPVEN ))     
	 			cDGRPVEN:=ACY->ACY_DESCRI	
	 		Else
	 			cDGRPVEN:="Nao encontrado grupo"			
	 		EndIf
  		EndIf
		If SF2->(dbSeek(xFilial("SF2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA)))
		 	If !Empty(SF2->F2_VEND1)
				SA3->(DbSeek(xFilial("SA3")+SF2->F2_VEND1))
				cVends   := Alltrim(SA3->A3_COD)
				cNomVend := alltrim(SA3->A3_NOME)
			Else
				cVends   := ""
				cNomVend := ""
			EndIf		
		EndIf						
		

		cSerie 	  := STR0025	// "DEV"
		nVlrTot   := nDevVal
		nTotQuant := nDevQtd   
		nVlrFre	  := nDevFre
		nVlrSeg   := nDevSeg
		nVlrDesp  := nDevDes
		nVlrAcrs  := nDevAcr
		nVlrPIS	  := nDevPis
		nVlrCOFIN := nDevCof
		nVlrICMS  := nDevIcms
		nVlrST	  := nDevIcRe
		nVlrIcCom := nDevIcCo                                                                  	
		nVlrIcDif := nDevDif
		nVlrIPI	  := nDevIpi
		nVlrFecp  := nDevFecp
		nVlrNet   := nDevNet
		
		oReport:section(1):section(1):Cell("NTOTQUANT"	):Show()
		oReport:Section(1):Section(1):Cell("NVLRUNIT"	):Show()
		oReport:Section(1):Section(1):Cell("CDOC"		):Show()
		oReport:Section(1):Section(1):Cell("DEMISSAO"	):Show()
		oReport:Section(1):Cell("CVENDS"	):Show()
		oReport:Section(1):Cell("cNomVend"	):Show()
		
		oReport:Section(1):PrintLine()
			
		oReport:Section(1):Section(1):PrintLine()
		
					
	EndIf
	nDevFre   := 0
	nDevSeg   := 0
	nDevDes   := 0
	nDevAcr   := 0
	nDevPis   := 0
	nDevCof   := 0
	nDevIcms  := 0
	nDevIcRe  := 0
	nDevIcCo  := 0
	nDevDif   := 0
	nDevIpi   := 0
	nDevFecp  := 0
	nDevNet   := 0
	nDevQtd   := 0
	nDevVal   := 0
	nVlrNet   := 0
	cVends   := ""
	cNomVend := ""	
	(cSD1)->(dbSkip())

EndDo
//RESTAREA(aAreaSA1)
//EndIf
Return .t.
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �A780CriaTmp� Autor � Rubens Joao Pante     � Data � 04/07/01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Cria temporario a partir da consulta corrente (TOP)          ���
��������������������������������������������������������������������������Ĵ��
��� Uso      �MATR780 (TOPCONNECT)                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function A780CriaTmp(cArqTmp, aStruTmp, cAliasTmp, cAlias)
	Local nI, nF, nPos
	Local cFieldName := ""
	nF := (cAlias)->(Fcount())
    dbCreate(cArqTmp,aStruTmp)
    DbUseArea(.T.,,cArqTmp,cAliasTmp,.T.,.F.)
	(cAlias)->(DbGoTop())
	While ! (cAlias)->(Eof())
        (cAliasTmp)->(DbAppend())
		For nI := 1 To nF 
			cFieldName := (cAlias)->( FieldName( ni ))
		    If (nPos := (cAliasTmp)->(FieldPos(cFieldName))) > 0
		   		    (cAliasTmp)->(FieldPut(nPos,(cAlias)->(FieldGet((cAlias)->(FieldPos(cFieldName))))))
            EndIf   		
		Next
		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())
    DbSelectArea(cAliasTmp)
Return Nil	

