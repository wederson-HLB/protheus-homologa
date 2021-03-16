#INCLUDE "Protheus.ch"
                                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction  ³FSCAT17INIºAutor  ³                 º Data ³  13/03/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria arquivo temporario para geracao dos dados referentes a º±±
±±º          ³Portaria CAT 17                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 FISCAT17X                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} xFSCAT17INI.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Cria arquivo temporario para geracao dos dados referentes  Portaria CAT 17 para emissao do Excel
*/                           

User Function xFSCAT17INI(nModelo)

Local aCampos	:={}    

if nModelo == 1         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle de Estoque³
	//³Modelo 3           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aCampos,{"TMP_NUMSEQ"	,"C"	,006,0})	// Sequencial
	AADD(aCampos,{"TMP_CONTRI"	,"C"	,040,0})	// Contribuinte
	AADD(aCampos,{"TMP_INSCR"	,"C"	,014,0})	// Inscricao Estadual
	AADD(aCampos,{"TMP_MERCAD"	,"C"	,TamSX3("B1_COD")[1],0})	// Mercadoria
	AADD(aCampos,{"TMP_MES"		,"C"	,002,0})	// Mes de referencia
	AADD(aCampos,{"TMP_ANO"		,"C"	,004,0})	// Ano de referencia
	AADD(aCampos,{"TMP_ALIQ"	,"N"	,005,2})	// Aliquota interna do ICMS
	AADD(aCampos,{"TMP_UNID"	,"C"	,002,0})	// Unidade de medida
	AADD(aCampos,{"TMP_DATA"	,"D"	,008,0})	// Data de Entrada/Saida da mercadoria
	AADD(aCampos,{"TMP_TIPO"	,"C"	,001,0})	// Tipo da Nota Fiscal
	AADD(aCampos,{"TMP_NFENTR"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF de entrada
	AADD(aCampos,{"TMP_SERENT"	,"C"	,003,0})	// Serie da NF de Entrada
	AADD(aCampos,{"TMP_QTDENT"	,"N"	,018,2})	// Quantidade entrada
	AADD(aCampos,{"TMP_VTENTR"	,"N"	,018,2})	// Valor total da base de calculo da retencao
	AADD(aCampos,{"TMP_VTBPR"	,"N"	,018,2})	// Valor total da base de calculo da operacao propria
	AADD(aCampos,{"TMP_NFSAID"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF de saida
	AADD(aCampos,{"TMP_SERSAI"	,"C"	,003,0})	// Serie da NF de Saida
	AADD(aCampos,{"TMP_QTDSAI"	,"N"	,018,2})	// Quantidade da saida
	AADD(aCampos,{"TMP_COL05"	,"N"	,018,2})	// BC da retencao
	AADD(aCampos,{"TMP_COL09"	,"N"	,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]})	// Valor Unitario da saida
	AADD(aCampos,{"TMP_COL10"	,"C"	,001,0})	// Saida a consumidor ou usuario final
	AADD(aCampos,{"TMP_VAL10"	,"N"	,018,2})	// VALOR DA Saida a consumidor ou usuario final
	AADD(aCampos,{"TMP_COL11"	,"C"	,001,0})	// Fato gerador nao realizado
	AADD(aCampos,{"TMP_VAL11"	,"N"	,018,2})	// Valor do Fato gerador nao realizado
	AADD(aCampos,{"TMP_COL12"	,"C"	,001,0})	// Saida com isencao ou nao incidencia
	AADD(aCampos,{"TMP_VAL12"	,"N"	,018,2})	// VALOR DA Saida com isencao ou nao incidencia
	AADD(aCampos,{"TMP_COL13"	,"C"	,001,0})	// Saida para outro estado
	AADD(aCampos,{"TMP_VAL13"	,"N"	,018,2})	// VALOR DA Saida para outro estado
	AADD(aCampos,{"TMP_COL14"	,"C"	,001,0})	// Saida para comercializacao subsequente
	AADD(aCampos,{"TMP_VAL14"	,"N"	,018,2})	// VALOR DA Saida para comercializacao subsequente
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Conforme consulta na Secretaria da Fazenda abaixo, a coluna 15 do relatorio nao sera mais utilizada                                                                                                                                                                                                                                                                    ³
	//³                                                                                                                                                                                                                                                                                                                                                                       ³
	//³Primeiramente lembramos que com a edição da lei 13291/08 o comerciante substituído que realizar venda a consumidor final por valor inferior à                                                                                                                                                                                                                          ³
	//³presumida se tera direito a ressarcimento no caso previsto pelo artigo 28 de lei 6374/89 (preço final autorizado ou fixado por autoridade competente),                                                                                                                                                                                                                 ³
	//³situação que não ocorre atualmente. Desta forma, a Portaria 17/99, só será utilizada para ressarcimento ocasionado por: fato gerador presumido não                                                                                                                                                                                                                     ³
	//³realizado; saída subseqüente por isenção ou não-incidência; saída para estabelecimento de contribuinte situado em outro Estado. Assim,                                                                                                                                                                                                                                 ³
	//³a Portaria CAT 17/99 prevê alguns campos que podem não ser utilizados nos pedidos de ressarcimentos após a 23/12/2008.                                                                                                                                                                                                                                                 ³
	//³                                                                                                                                                                                                                                                                                                                                                                       ³
	//³Em relação ao valor da coluna 18, a forma de cálculo esta especificada no Art 4, inc V, letra b.                                                                                                                                                                                                                                                                       ³
	//³                                                                                                                                                                                                                                                                                                                                                                       ³
	//³As colunas 15 e 16 devem ser preenchidas conforme previsto no parágrafo 1 do Artigo 4. Apos 23/12/2008 a coluna 15 não será mais utilizada.                                                                                                                                                                                                                            ³
	//³O preenchimento da coluna 16 esta explicado no parágrafo 5 do Art 4o.                                                                                                                                                                                                                                                                                                  ³
	//³                                                                                                                                                                                                                                                                                                                                                                       ³
	//³Em relação ao ICMS retido por antecipação tributária, eles devem compor a ficha de controle de estoque, devendo-se considerar a quantidade e valor da base de calculo de retenção, calculada conforme legislação. Sugerimos a leitura do artigo 426-A, artigo 277 do RICMS/SP e Portaria CAT 15/2008, que prevê a forma de preenchimento no livro Registro de Entradas.³
	//³Atenciosamente,                                                                                                                                                                                                                                                                                                                                                        ³
	//³Secretaria da Fazenda do Estado de São Paulo                                                                                                                                                                                                                                                                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aCampos,{"TMP_COL15"	,"N"	,018,2})	// Base de calculo efetiva na saida a consumidor ou usuario final
	AADD(aCampos,{"TMP_COL16"	,"N"	,018,2})	// Base de calculo efetiva na entrada nas demais hipoteses
	AADD(aCampos,{"TMP_COL17"	,"N"	,018,2})	// Quantidade( Saldo )
	AADD(aCampos,{"TMP_COL18"	,"N"	,TamSX3("D2_TOTAL")[1],2})	// Valor unitario da base de calculo da retencao 
	AADD(aCampos,{"TMP_COL19"	,"N"	,018,2})	// Valor total da base de calculo da retencao
	AADD(aCampos,{"TMP_COL20"	,"N"	,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})	// Valor unitario da base de calculo da operacao propria
	AADD(aCampos,{"TMP_COL21"	,"N"	,018,2})	// Valor total da base de calculo da operacao propria
	AADD(aCampos,{"TMP_VTBST"	,"N"	,018,2})	// Valor total da base de calculo da operacao ST
	AADD(aCampos,{"TMP_ALIQS"	,"N"	,005,2})	// Aliquota interna do ICMS
	AADD(aCampos,{"TMP_SLD17"	,"N"	,018,2})	// Quantidade( Saldo )
	AADD(aCampos,{"TMP_SLD19"	,"N"	,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})	// Valor unitario da base de calculo da retencao  
	AADD(aCampos,{"TMP_SLD21"	,"N"	,018,2})	// Valor total da base de calculo da retencao
	AADD(aCampos,{"TMP_SLDALQ"	,"N"	,005,2})	// Aliquota interna do ICMS
	AADD(aCampos,{"TMP_MOVD1"	,"C"	,001,0})
	AADD(aCampos,{"TMP_MOVD2"	,"C"	,001,0})
	AADD(aCampos,{"TMP_MOVD3"	,"C"	,001,0})
	AADD(aCampos,{"TMP_CFO"		,"C"	,004,0})
	AADD(aCampos,{"TMP_CLI"		,"C"	,TamSX3("D2_CLIENTE")[1],0})
	AADD(aCampos,{"TMP_FOR"		,"C"	,TamSX3("D2_CLIENTE")[1],0})
	AADD(aCampos,{"TMP_LOJA"	,"C"	,TamSX3("D2_LOJA")[1],0})
	AADD(aCampos,{"TMP_FILIAL"	,"C"	,002,0})
	AADD(aCampos,{"TMP_BASMAN"	,"N"	,018,2})
	AADD(aCampos,{"TMP_BSPROE"	,"N"	,018,2})	// base de calculo da operacao propria proporcional a entrada
	AADD(aCampos,{"TMP_BSTRAN"	,"N"	,018,2})	// base de calculo da operacao de transferencia de saldos
	//Campos criados para contemplar modelo 5 - apuracao
	AADD(aCampos,{"TMP_APU02"	,"C"	,001,0})	// Entrada dentro do estado exceto devolucao e retorno
	AADD(aCampos,{"TMP_VAPU02"	,"N"	,018,2})	// Valor da entrada dentro do estado exceto devolucao e retorno
	AADD(aCampos,{"TMP_APU03"	,"C"	,001,0})	// Entrada fora do estado com recolhimento na entrada
	AADD(aCampos,{"TMP_VAPU03"	,"N"	,018,2})	// Valor da entrada fora do estado com recolhimento na entrada
	AADD(aCampos,{"TMP_APU04"	,"C"	,001,0})	// Devolucao de mercadorias recebidas
	AADD(aCampos,{"TMP_VAPU04"	,"N"	,018,2})	// Valor da devolucao de mercadorias recebidas
	AADD(aCampos,{"TMP_APU08"	,"C"	,001,0})	// Saida nao destinada a consumidor ou usuario final
	AADD(aCampos,{"TMP_VAPU08"	,"N"	,018,2})	// Valor da saida nao destinada a consumidor ou usuario final
	AADD(aCampos,{"TMP_VAPU10"	,"N"	,018,2})	// Base de calculo efetiva na saida a consumidor ou usuario final
	AADD(aCampos,{"TMP_VAPU11"	,"N"	,018,2})	// Base de calculo efetiva de devolucoes ou retornos de vendas efetuadas a consumidor ou usuario final
	AADD(aCampos,{"TMP_BSNDES"	,"N"	,018,2})    // Base ICMS ST Ant (D1_BASNDES)
	AADD(aCampos,{"TMP_VLMERC"	,"N"	,018,2})    // Valor da mecadoria
	AADD(aCampos,{"TMP_NFORI"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF original
	AADD(aCampos,{"TMP_NUMDOC"	,"C"	,TamSX3("F2_DOC")[1],0})    //Numero de documento para criar o indice da tabela temporaria
	AADD(aCampos,{"TMP_REDBC"	,"N"	,TamSX3("F4_BASEICM")[1],TamSX3("F4_BASEICM")[2]})
	AADD(aCampos,{"TMP_FLAG"	,"C"	,001,0})
	AADD(aCampos,{"TMP_DTFMST"	,"D"	,008,0})    //Data Final de controle de ressarcimento do ICMS-ST na CAT17
	AADD(aCampos,{"TMP_SERORI"	,"C"	,TamSX3("D2_SERIORI")[1],0})	// Série da NF original
	AADD(aCampos,{"TMP_SERIE"	,"C"	,TamSX3("D2_SERIORI")[1],0})	// Série da NF para criar o indice da tabela temporaria
	AADD(aCampos,{"TMP_CLIFOR"	,"C"	,TamSX3("D2_CLIENTE")[1],0})	// Cliente ou fornecedor para utilizar no indice da tabela temporaria
	AADD(aCampos,{"TMP_ENTSAI"	,"C"	,001,0})	// Recno da tabela SFT para os registros de SD1 e SD2, nos casos de movimento SD3 será preenchido com Zero
	
	cArqTMP	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqTMP,"RCA")
	IndRegua("RCA",cArqTMP,"TMP_MERCAD+TMP_MES+TMP_ANO+dtos(TMP_DATA)+TMP_ENTSAI+TMP_NUMDOC",,,"Indexando Arquivo" )
	dbClearIndex()	
	
	cIndRCA2 := CriaTrab(Nil,.F.)	
	IndRegua("RCA",cIndRCA2,"TMP_MERCAD+TMP_CLIFOR+TMP_LOJA+TMP_NUMDOC+TMP_SERIE",,,"Indexando Arquivo" )
	dbClearIndex()
	
	cIndRCA3 := CriaTrab(Nil,.F.)       
	IndRegua('RCA',cIndRCA3,"TMP_MERCAD+DTOS(TMP_DATA)+TMP_NUMDOC",,,"Indexando Arquivo") 
	dbClearIndex()
                                    
	dbSelectArea("RCA")
	dbSetIndex(cArqTMP+OrdBagExt())
	dbSetIndex(cIndRCA2+OrdBagExt())
	dbSetIndex(cIndRCA3+OrdBagExt())

	dbSetOrder(1)
	aCampos := {}

ElseIf nModelo == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle de estoque - Veiculos e Motos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aCampos,{"TMP_NUMSEQ"	,"C"	,006,0})					// Sequencial
	AADD(aCampos,{"TMP_CONTRI"	,"C"	,040,0})					// Contribuinte
	AADD(aCampos,{"TMP_INSCR"	,"C"	,014,0})					// Inscricao Estadual
	AADD(aCampos,{"TMP_MERCAD"	,"C"	,TamSX3("VV1_CHASSI")[1],0})// Chassi
	AADD(aCampos,{"TMP_PROD"	,"C"	,TamSX3("B1_COD")[1],0})	// Produto
	AADD(aCampos,{"TMP_MES"		,"C"	,002,0})					// Mes de referencia
	AADD(aCampos,{"TMP_ANO"		,"C"	,004,0})					// Ano de referencia
	AADD(aCampos,{"TMP_FILIAL"	,"C"	,002,0})                   	// Filial
	AADD(aCampos,{"TMP_DATA"	,"D"	,008,0})					// Data de Entrada/Saida da mercadoria
	AADD(aCampos,{"TMP_TIPO"	,"C"	,001,0})					// Tipo da Nota Fiscal
	AADD(aCampos,{"TMP_ALIQ"	,"N"	,005,2})					// Aliquota interna do ICMS
	AADD(aCampos,{"TMP_DATENT"	,"D"	,008,0})					// Data de Entrada da mercadoria
	AADD(aCampos,{"TMP_NFENTR"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF de entrada
	AADD(aCampos,{"TMP_SERENT"	,"C"	,003,0})					// Serie da NF de Entrada
	AADD(aCampos,{"TMP_VAL05"	,"N"	,018,2})					// BC Oper.Propria do substituto
	AADD(aCampos,{"TMP_VAL06"	,"N"	,018,2})					// BC da retencao
	AADD(aCampos,{"TMP_DATSAI"	,"D"	,008,0})					// Data de Saida da mercadoria
	AADD(aCampos,{"TMP_NFSAID"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF de saida
	AADD(aCampos,{"TMP_SERSAI"	,"C"	,003,0})					// Serie da NF de Saida
	AADD(aCampos,{"TMP_VAL10"	,"N"	,018,2})					// BC Saida comercializacao subsequente
	AADD(aCampos,{"TMP_VAL11"	,"N"	,018,2})					// BC Efetiva Saida a consumidor final
	AADD(aCampos,{"TMP_VAL12"	,"N"	,018,2})					// BC Efetiva da entrada nas demais hipoteses
	AADD(aCampos,{"TMP_VAL13"	,"N"	,018,2})					// BC Retencao do estoque remanescente
	AADD(aCampos,{"TMP_VAL14"	,"N"	,018,2})					// Para efeito de complementacao do imposto
	AADD(aCampos,{"TMP_VAL15"	,"N"	,018,2})					// Total excedente
	AADD(aCampos,{"TMP_VAL16"	,"N"	,018,2})					// Parcela para calculo do ressarcimento
	AADD(aCampos,{"TMP_BSNDES"	,"N"	,018,2})                    // Base ICMS ST Ant (D1_BASNDES)
	AADD(aCampos,{"TMP_NFORI"	,"C"	,TamSX3("F2_DOC")[1],0})	// Numero da NF original
	AADD(aCampos,{"TMP_NUMDOC"	,"C"	,TamSX3("F2_DOC")[1],0})    // Numero de documento para criar o indice da tabela temporaria 
	AADD(aCampos,{"TMP_DTFMST"	,"D"	,008,0})					//Data Final de controle de ressarcimento do ICMS-ST na CAT17	
	
	cArqTMP	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqTMP,"RCA")
	IndRegua("RCA",cArqTMP,"TMP_MERCAD+TMP_MES+TMP_ANO+dtos(TMP_DATA)+TMP_NUMSEQ+TMP_NUMDOC",,,"Indexando Arquivo" ) //	
EndIf
		
Return( cArqTMP )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction  ³FSCAT17CALºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incrementa o arquivo temporario com as notas fiscais de    º±±
±±º          ³ entrada e saida                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} xFSCAT17INI.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Incrementa o arquivo temporario com as notas fiscais de entrada e saida   
*/

User Function xFS17CAL(cArqTMP,dDtIni,dDtFim,nCDM,cProdIni,cProdFin,nModApur,lPautaOp)

LOCAL nPerICM	:= 0
LOCAL MV_ESTICM := GetMv("MV_ESTICM")
LOCAL MV_ESTADO := GetMv("MV_ESTADO")
LOCAL lCliRel   := GetNewPar("MV_CLIREL",.F.)   // Parametro criado para verificar se o tipo do Cliente sera gerado a partir do cadastro ou do pedido de venda
LOCAL lTabSB1   := GetNewPar("MV_TABSB1",.F.)   // Parametro criado para definir se a aliquota utilizada sera a do SB1 ou do SFK 
Local lGeraD3   := GetNewPar("MV_GERSD3",.T.)   // Parametro criado para verificar se as movimentacoes internas serao contabilizadas no relatorio
Local cMovSD3   := GetNewPar("MV_TMVSD3","")    // Parametro criado para definir quais cod. de tipos de movimentos da SD3 irao para a coluna 11

Local lConsFinal:= .F. 
Local lQuery    := .F.
Local cAliasSFK := "SFK"
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cAliasSD3 := "SD3"
Local cChaveSD3 := ""
Local cAliasCDM := "CDM"
Local cArqInd   := ""
Local cArmCT17  := GetNewPar("MV_ARMCT17","") 

Local aEstoque  := {}  
Local nPos 		:= 0  
Local ncont 	:= 0   
Local cMes		:= ''
Local cAno		:= ''
Local nItem		:=	0      
Local abase 	:= {}
Local nBaseIcm  := 0
Local cProdOrig := 0
Local aProdOrig := {}
Local cRastro   := GetMv("MV_RASTRO")

#IFDEF TOP
	Local nX        := 0
	Local cQuery    := ""
	Local aStruSFK  := {}
	Local aStruSD1  := {}
	Local aStruSD2  := {}
	Local aStruSD3  := {}
#ENDIF

Default nCDM		:= 0
Default dDtIni		:= MV_PAR01
Default dDtFim		:= MV_PAR02
Default cProdIni	:= MV_PAR03
Default cProdFin	:= MV_PAR04
Default nModApur	:= MV_PAR06
Default lPautaOp	:= (MV_PAR08 == 1)

cMes := StrZero(month(dDtIni),2)
cAno := StrZero(Year(dDtFim),4) 

nPerIcm := Val(Subs(MV_ESTICM,AT(MV_ESTADO,MV_ESTICM)+2,2))

//Processo pela CDM
If nCDM == 1 .and. AliasIndic("CDM")
	//Processo as Entradas da SFK e os Produtos que não existirem na SFK pego da SB1
	#IFDEF TOP
		If TcSrvType()<>"AS/400"  
        	lQuery 		:= .T.
			cAliasSFK	:= GetNextAlias()   

	    	BeginSql Alias cAliasSFK
	    	
	    		COLUMN FK_DATA AS DATE   
				SELECT SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_VLR_ICM,SFK.FK_DATA,SFK.FK_AICMS,SFK.FK_QTDE,
				SFK.FK_BRICMS,SFK.FK_BASEICM,SB1.B1_UM
			    FROM %table:SB1% SB1
			    LEFT JOIN %table:SFK% SFK ON
				SFK.FK_FILIAL = %xFilial:SFK%
				AND SFK.FK_PRODUTO = SB1.B1_COD 
				AND SFK.FK_DATA >= %Exp:dDtIni%
				AND SFK.FK_DATA <= %Exp:dDtFim%
				AND SFK.%NotDel%    
		        WHERE SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD >= %Exp:cProdIni%
				AND SB1.B1_COD <= %Exp:cProdFin%
				AND SB1.B1_CRICMS = '1'
				//AND SB1.B1_DTCRICM <= %Exp:dDtFim%
				//AND SB1.B1_DTCRICM <> ' '
				AND SB1.%NotDel%

				ORDER BY SB1.B1_COD

	        EndSql                       	               
		Else			                  
	#ENDIF                                                       	                       
	      	cArqInd  := CriaTrab(Nil,.F.)       
			cChave	   := CDM->(IndexKey(7))
			cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
			cCondicao  += "dtos(CDM_DTSAI) >= '" + dtos(dDtIni) + "' .AND. "	  	  	  
  			cCondicao  += "dtos(CDM_DTSAI) <= '" + dtos(dDtFim) + "' .AND. "
  			cCondicao  += "CDM_PRODUT>='" + cProdIni + "' .AND. "
			cCondicao  += "CDM_PRODUT<='" + cProdFin + "' .AND. "
			cCondicao  += "CDM_TIPO == 'S' .AND. "
          	cCondicao  += "CDM_DOCENT == 'ESTADO' .AND. "
          	cCondicao  += "CDM_SERIEE == 'CAT'"
			 
			IndRegua(cAliasCDM,cArqInd,cChave,,cCondicao,"Selecionando registros") //"Selecionado registros"  
	
	   		#IFNDEF TOP
				dbSetIndex(cArqInd+OrdBagExt())
		    #ENDIF 
		    dbselectarea(cAliasCDM)               
		    (cAliasCDM)->(dbGotop())			                            
	    
	#IFDEF TOP
	    Endif    
	#ENDIF 
		
	While (cAliasSFK)->(!Eof()) .and. (cAliasSFK)->B1_FILIAL == xFilial("SB1")
		//Saldo Inicial
		RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD	:=	(cAliasSFK)->B1_COD
		RCA->TMP_MES	:=	StrZero(month((cAliasSFK)->FK_DATA),2)
		RCA->TMP_ANO	:=	StrZero( Year((cAliasSFK)->FK_DATA),4)
		RCA->TMP_ALIQ	:=	if(!empty((cAliasSFK)->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		RCA->TMP_ALIQS	:=	if(!empty((cAliasSFK)->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		RCA->TMP_DATA	:=	(cAliasSFK)->FK_DATA
		RCA->TMP_NUMSEQ	:=	replicate("0",6)
		RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR	:=	SM0->M0_INSC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Coloca-se "saldo" na NF de entrada para saber que³
		//³ este registro refere-se ao saldo inicial        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RCA->TMP_NFENTR	:=	"SALDO"     
		RCA->TMP_COL17	:=	iif((cAliasSFK)->FK_QTDE	>= 0, (cAliasSFK)->FK_QTDE,0 )			                                   // Quantidade
		RCA->TMP_COL18	:= 	iif((cAliasSFK)->FK_QTDE	>= 0, noround((cAliasSFK)->FK_BRICMS/(cAliasSFK)->FK_QTDE,9),0 )	       // Valor Unitario ST
		RCA->TMP_COL19	:=	iif((cAliasSFK)->FK_QTDE	>= 0,(cAliasSFK)->FK_BRICMS,0)		  						               // Valor Total BC ST
		RCA->TMP_COL20	:=	iif((cAliasSFK)->FK_QTDE	>= 0,noround((cAliasSFK)->FK_BASEICM/(cAliasSFK)->FK_QTDE,9), 0)           //Vl Unit. da BC Oper. Propria
		RCA->TMP_COL21	:=	iif((cAliasSFK)->FK_QTDE	>= 0,(cAliasSFK)->FK_BASEICM,0)							                 	//  total da BC oper. Propria 
		RCA->TMP_UNID	:=  (cAliasSFK)->B1_UM
		RCA->(MsUnlock())


		//As entradas são inseridas na CDM como Tipo 'S' e quando não vem do Estoque o campo CDM_SERIEE é <> de 'CAT'
		//Processo todas as Entradas sem as que vieram do Estoque 
		#IFDEF TOP
			If TcSrvType()<>"AS/400"  
	        	lQuery 		:= .T.
				cAliasCDM	:= GetNextAlias()   
				
		    	BeginSql Alias cAliasCDM
		    		COLUMN CDM_DTSAI AS DATE
					COLUMN CDM_DTENT AS DATE
					SELECT CDM.CDM_FILIAL,CDM.CDM_DTENT,CDM.CDM_DTSAI,CDM.CDM_QTDENT,CDM.CDM_DOCENT,CDM.CDM_DOCSAI,CDM.CDM_SERIEE,CDM.CDM_TES,SF4.F4_LFICM,CDM.CDM_UFENT,
					       CDM.CDM_PRODUT,CDM.CDM_NSEQE,CDM.CDM_TIPO,CDM.CDM_BSERET,CDM.CDM_BSENT,CDM.CDM_ICMENT,CDM.CDM_CFENT,CDM.CDM_LJFOR,CDM.CDM_FORNEC,CDM.CDM_TIPODB,CDM.CDM_ALQENT
				    FROM %table:CDM% CDM, %table:SF4% SF4, %table:SB1% SB1
			        WHERE CDM.CDM_FILIAL = %xFilial:CDM% AND
   			        	  SF4.F4_FILIAL = %xFilial:SF4% AND
   			        	  SF4.F4_CODIGO = CDM.CDM_TES AND
   			        	  SF4.F4_PODER3 = 'N' AND
   			        	  SF4.%NotDel% AND
   			        	  SB1.B1_FILIAL = %xFilial:SB1% AND
   			        	  SB1.B1_COD = CDM.CDM_PRODUT AND
				          CDM.CDM_DTENT >= %Exp:dDtIni% AND
				          CDM.CDM_DTENT <= %Exp:dDtFim% AND
	   			          CDM.CDM_PRODUT = %Exp:(cAliasSFK)->B1_COD% AND
				          CDM.CDM_TIPO = 'S' AND
				          CDM.CDM_SERIEE <> 'CAT' AND
	 			          CDM.%NotDel%
					ORDER BY CDM.CDM_FILIAL,CDM.CDM_PRODUT,CDM.CDM_NSEQE
		        EndSql 
	      
			Else
		#ENDIF                                                       
		      	cArqInd  := CriaTrab(Nil,.F.)       
				cChave	   := CDM->(IndexKey(7))
				cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
				cCondicao  += "dtos(CDM_DTENT) >= '" + dtos(dDtIni) + "' .AND. "	  	  	  
	  			cCondicao  += "dtos(CDM_DTENT) <= '" + dtos(dDtFim) + "' .AND. "
	  			cCondicao  += "CDM_PRODUT>='" + cProdIni + "' .AND. "
				cCondicao  += "CDM_PRODUT<='" + cProdFin + "' .AND. "
				cCondicao  += "CDM_TIPO == 'S' "
//	          	cCondicao  += "CDM_DOCENT <> 'ESTADO'"
				 
				IndRegua(cAliasCDM,cArqInd,cChave,,cCondicao,"Selecionando registros") //"Selecionado registros"  
		
		   		#IFNDEF TOP
					dbSetIndex(cArqInd+OrdBagExt())
			    #ENDIF 
			    dbselectarea(cAliasCDM)               
			    (cAliasCDM)->(dbGotop())			                            
		    
		#IFDEF TOP
		    Endif    
		#ENDIF 
	
		RECLOCK("RCA",.F.)
		If (cAliasCDM)->(!EOF()) .And. (cAliasCDM)->CDM_FILIAL==xFilial("CDM") .And. (cAliasCDM)->CDM_DTENT <= dDtFim
			RCA->TMP_MOVD1 	:= "S"
			RCA->TMP_SLD17	:= 	0
			RCA->TMP_SLD19	:=	0
			RCA->TMP_SLD21	:=	0
			RCA->TMP_SLDALQ	:= 	0
		Else
			RCA->TMP_MOVD1 	:= "N"
			RCA->TMP_SLD17	:= 	RCA->TMP_COL17
			RCA->TMP_SLD19	:=	RCA->TMP_COL19
			RCA->TMP_SLD21	:=	RCA->TMP_COL21
			RCA->TMP_SLDALQ	:= 	RCA->TMP_ALIQ
		EndIf
		RCA->(MsUnlock())

		While (cAliasCDM)->(!Eof()) .and. (cAliasCDM)->CDM_FILIAL == xFilial("CDM")
	
			
			SB1->(MsSeek(xFilial("SB1")+(cAliasCDM)->CDM_PRODUT)) 
				RECLOCK("RCA",.T.)
				RCA->TMP_NUMSEQ		:=  (cAliasCDM)->CDM_NSEQE
				RCA->TMP_MERCAD		:=  (cAliasCDM)->CDM_PRODUT
				RCA->TMP_MES		:=	StrZero(month((cAliasCDM)->CDM_DTENT),2)
				RCA->TMP_ANO		:=	StrZero( Year((cAliasCDM)->CDM_DTENT),4)
				If lTabSB1
					RCA->TMP_ALIQ	:= if( !empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)
					RCA->TMP_ALIQS	:=	nPerICM
				Else
					RCA->TMP_ALIQ 	:= if(!empty((cAliasCDM)->CDM_ALQENT),(cAliasCDM)->CDM_ALQENT,nPerICM)
					RCA->TMP_ALIQS	:= if(!empty((cAliasCDM)->CDM_ALQENT),(cAliasCDM)->CDM_ALQENT,nPerICM)
				EndIf
				RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
				RCA->TMP_INSCR	:=	SM0->M0_INSC
				RCA->TMP_UNID	:=	SB1->B1_UM
				RCA->TMP_DATA	:=	(cAliasCDM)->CDM_DTENT
				RCA->TMP_NFENTR	:=	(cAliasCDM)->CDM_DOCENT	// Numero da NF de Entrada
				RCA->TMP_CFO	:=	(cAliasCDM)->CDM_CFENT
				RCA->TMP_FOR	:=	(cAliasCDM)->CDM_FORNEC
				RCA->TMP_FILIAL := 	(cAliasCDM)->CDM_FILIAL
				RCA->TMP_SERENT	:=	(cAliasCDM)->CDM_SERIEE
				RCA->TMP_QTDENT	:=	(cAliasCDM)->CDM_QTDENT
				RCA->TMP_VTENTR	:=	(cAliasCDM)->CDM_BSERET	//+CDM_BASMAN// Valor total da base de calculo da retencao
				RCA->TMP_VTBPR	:=	(cAliasCDM)->CDM_BSENT	// Valor total da base de calculo propria
				//RCA->TMP_COL21  :=  (cAliasCDM)->CDM_BSENT  // Valor total da base de calculo propria
				RCA->TMP_TIPO	:=	(cAliasCDM)->CDM_TIPODB

				//Tratar NF de Devolucao e Retorno
				If (cAliasCDM)->CDM_TIPODB $ "BD"
					SA1->(MsSeek(xFilial("SA1")+(cAliasCDM)->CDM_FORNEC+(cAliasCDM)->CDM_LJFOR))
					lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)
									
					If (cAliasCDM)->F4_LFICM $"IN" .and. !lConsFinal  .And. !(RCA->TMP_COL11 == "S")
						RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
					ElseIf lConsFinal	.And. !(RCA->TMP_COL11 == "S")
						RCA->TMP_COL10	:= 	"S" 	//Saida a Consumidor/ Usuario Final
						RCA->TMP_COL15	:=	0 // Base de calculo efetiva na saida a consumidor/usuario final ou saida isenta
						RCA->TMP_VAPU11 :=  (cAliasCDM)->CDM_BSENT
					ElseIf ((cAliasCDM)->CDM_UFENT <> MV_ESTADO) .AND. ((cAliasCDM)->CDM_UFENT <> "EX") .AND. !lConsFinal
						RCA->TMP_COL13	:= 	"S"		//Saida para outro Estado
					ElseIf !lConsFinal
						RCA->TMP_COL14	:=	"S"     //Saida para comercializacao subsequente
					Endif 
					
					If !lConsFinal .and. (cAliasCDM)->CDM_BSERET > 0       
						RCA->TMP_APU08 := "S"		//Saida nao destinada a consumidor ou usuario final
					EndIf
						
				ElseIf (cAliasCDM)->CDM_UFENT == MV_ESTADO
				      RCA->TMP_APU02	:=	"S"		//Entradas exceto devolucoes ou retornos dentro do estado						
				Else
				      RCA->TMP_APU03	:=	"S"		//	Entrada de mercadorias de outro estado								
				EndIf				
				
				RCA->(MsUnlock())
				(cAliasCDM)->(dbSkip())
		EndDo
		If lQuery
			dbSelectArea(cAliasCDM)
			dbCloseArea()
		EndIf

		//Processo todas as Saidas que estão relacionadas na CDM
		#IFDEF TOP
			If TcSrvType()<>"AS/400"  
	        	lQuery 		:= .T.
				cAliasCDM	:= GetNextAlias()   
				
		    	BeginSql Alias cAliasCDM
		    		COLUMN CDM_DTSAI AS DATE
					COLUMN CDM_DTENT AS DATE
					SELECT CDM.CDM_FILIAL,CDM.CDM_DTSAI,CDM.CDM_QTDVDS,CDM.CDM_DOCENT,CDM.CDM_DOCSAI,CDM.CDM_SERIES,CDM.CDM_LJCLI,CDM.CDM_UFSAI,CDM.CDM_TES,CDM_TIPODB,SF4.F4_LFICM,
					       CDM.CDM_PRODUT,CDM.CDM_NSEQS,CDM.CDM_TIPO,CDM.CDM_BSSRET,CDM.CDM_BSENT,CDM.CDM_BSSAI,CDM.CDM_ICMSAI,CDM.CDM_CFSAI,CDM.CDM_CLIENT,CDM.CDM_BASMAN,CDM.CDM_BSERET,CDM.CDM_ALQENT
				    FROM %table:CDM% CDM, %table:SF4% SF4, %table:SB1% SB1
			        WHERE CDM.CDM_FILIAL = %xFilial:CDM% AND
			        	  SF4.F4_FILIAL = %xFilial:SF4% AND
   			        	  SF4.F4_CODIGO = CDM.CDM_TES AND
   			        	  SF4.F4_PODER3 = 'N' AND
   			        	  SF4.%NotDel% AND
   			        	  SB1.B1_FILIAL = %xFilial:SB1% AND
   			        	  SB1.B1_COD = CDM.CDM_PRODUT AND
				          CDM.CDM_DTSAI >= %Exp:dDtIni% AND
				          CDM.CDM_DTSAI <= %Exp:dDtFim% AND
	   			          CDM.CDM_PRODUT = %Exp:(cAliasSFK)->B1_COD% AND
				          CDM.CDM_TIPO IN ('M','L') AND
	 			          CDM.%NotDel%
					ORDER BY CDM.CDM_FILIAL,CDM.CDM_PRODUT,CDM.CDM_NSEQS
					
		        EndSql                       
		               
			Else
				                  
		#ENDIF                                                       
		                       
		      	cArqInd  := CriaTrab(Nil,.F.)       
				cChave	   := CDM->(IndexKey(7))
				cCondicao  := "CDM_FILIAL == '"+xFilial("CDM")+"' .AND. "
				cCondicao  += "dtos(CDM_DTSAI) >= '" + dtos(dDtIni) + "' .AND. "	  	  	  
	  			cCondicao  += "dtos(CDM_DTSAI) <= '" + dtos(dDtFim) + "' .AND. "
	  			cCondicao  += "CDM_PRODUT>='" + cProdIni + "' .AND. "
				cCondicao  += "CDM_PRODUT<='" + cProdFin + "' .AND. "
				cCondicao  += "CDM_TIPO == 'M' .OR. CDM_TIPO == 'L' "
//	          	cCondicao  += "CDM_DOCENT <> 'ESTADO'"
				 
				IndRegua(cAliasCDM,cArqInd,cChave,,cCondicao,"Selecionando registros") //"Selecionado registros"  
		
		   		#IFNDEF TOP
					dbSetIndex(cArqInd+OrdBagExt())
			    #ENDIF 
			    dbselectarea(cAliasCDM)               
			    (cAliasCDM)->(dbGotop())			                            
		    
		#IFDEF TOP
		    Endif    
		#ENDIF 
		
			RECLOCK("RCA",.F.)
			If (cAliasCDM)->(!EOF()) .And. (cAliasCDM)->CDM_FILIAL==xFilial("CDM") .And. (cAliasCDM)->CDM_DTSAI <= dDtFim
				RCA->TMP_MOVD2 		:= "S"
				RCA->TMP_SLD17		:= 	0
				RCA->TMP_SLD19		:=	0
				RCA->TMP_SLD21		:=	0
				RCA->TMP_SLDALQ  	:= 	0
			Else
				RCA->TMP_MOVD2		:= "N"
				RCA->TMP_SLD17		:= 	RCA->TMP_COL17
				RCA->TMP_SLD19		:=	RCA->TMP_COL19
				RCA->TMP_SLD21		:=	RCA->TMP_COL21
				RCA->TMP_SLDALQ		:= 	RCA->TMP_ALIQ
			EndIf
			RCA->(MsUnlock())
		
		While (cAliasCDM)->(!Eof()) .and. (cAliasCDM)->CDM_FILIAL == xFilial("CDM")
		

			SB1->(MsSeek(xFilial("SB1")+(cAliasCDM)->CDM_PRODUT))
			//SF4->(MsSeek(xFilial("SF4")+(cAliasCDM)->CDM_TES))
			
			//Nao considero as notas de poder de terceiros
			//If SF4->F4_PODER3 <> "N"
			//	(cAliasCDM)->(dbSkip())
			//	Loop
			//Endif
			
			If (cAliasCDM)->CDM_TIPODB $ "DB"
				SA2->(MsSeek(xFilial("SA2")+(cAliasCDM)->CDM_CLIENT+(cAliasCDM)->CDM_LJCLI))
				lConsFinal	:= if( SA2->A2_TIPO=="F", .T.,.F.)
			Else
				If lCliRel
					SC6->(dbSetOrder(4))
					SC5->(dbSetOrder(1))
					If SC6->(MsSeek(xFilial("SC6")+(cAliasCDM)->CDM_DOCSAI+(cAliasCDM)->CDM_SERIES))
						If SC5->(MsSeek(xFilial("SC5")+SC6->C6_NUM))
							lConsFinal	:= if( SC5->C5_TIPOCLI=="F", .T.,.F.)
						EndIf
					Else
						SA1->(MsSeek(xFilial("SA1")+(cAliasCDM)->CDM_CLIENT+(cAliasCDM)->CDM_LJCLI))
						lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)
					EndIf
				Else
					SA1->(MsSeek(xFilial("SA1")+(cAliasCDM)->CDM_CLIENT+(cAliasCDM)->CDM_LJCLI))
					lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)
				EndIf
			EndIf
	
			
			RECLOCK("RCA",.T.)
			RCA->TMP_NUMSEQ	:=  (cAliasCDM)->CDM_NSEQS
			RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
			RCA->TMP_INSCR	:=	SM0->M0_INSC
			RCA->TMP_MERCAD	:=	(cAliasCDM)->CDM_PRODUT
			RCA->TMP_MES	:=	StrZero(month((cAliasCDM)->CDM_DTSAI),2)
			RCA->TMP_ANO	:=	StrZero( Year((cAliasCDM)->CDM_DTSAI),4)
			If lTabSB1
				RCA->TMP_ALIQ	:= if(!empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)
				RCA->TMP_ALIQS	:=	nPerICM
			Else
				//RCA->TMP_ALIQ	:= 	Iif(nAliqInt>0, nAliqInt,Iif((cAliasSD2)->D2_PICM>0,(cAliasSD2)->D2_PICM,nPerICM ))
				RCA->TMP_ALIQ	:= 	if(!empty((cAliasCDM)->CDM_ALQENT),(cAliasCDM)->CDM_ALQENT,nPerICM)
				RCA->TMP_ALIQS	:=	if(!empty((cAliasCDM)->CDM_ALQENT),(cAliasCDM)->CDM_ALQENT,nPerICM)
			EndIf
			RCA->TMP_UNID	:=	SB1->B1_UM
			RCA->TMP_DATA	:=	(cAliasCDM)->CDM_DTSAI
			RCA->TMP_NFSAID	:=	(cAliasCDM)->CDM_DOCSAI	// Numero da NF de saida
			RCA->TMP_SERSAI	:=	(cAliasCDM)->CDM_SERIES	// Serie da NF de Saida
			RCA->TMP_QTDSAI	:=	(cAliasCDM)->CDM_QTDVDS	// Quantidade da saida
			RCA->TMP_CFO	:=	(cAliasCDM)->CDM_CFSAI
			RCA->TMP_CLI	:=	(cAliasCDM)->CDM_CLIENT
			RCA->TMP_FILIAL := 	(cAliasCDM)->CDM_FILIAL
			RCA->TMP_VTBST	:=	(cAliasCDM)->CDM_BSSRET	// Valor total da base de calculo propria ST
			RCA->TMP_VTBPR	:=  (cAliasCDM)->CDM_BSSAI
			RCA->TMP_TIPO	:=	(cAliasCDM)->CDM_TIPODB
			RCA->TMP_BASMAN :=  (cAliasCDM)->CDM_BASMAN					
			//If AllTrim((cAliasCDM)->CDM_DOCENT)$"ESTADO" .AND. ((cAliasCDM)->CDM_UFSAI <> MV_ESTADO)//Venda para fora do estado de um estoque com documento igual a ESTADO
			//	RCA->TMP_COL21	:=	(cAliasCDM)->CDM_BSENT / (((cAliasCDM)->CDM_MVAENT/100)+1)
			//Else
				RCA->TMP_BSPROE	:=	(cAliasCDM)->CDM_BSENT	// Valor total da base de calculo propria
			//EndIf	
			
			If ((cAliasCDM)->F4_LFICM $"IN") .and. !lConsFinal .And. !(RCA->TMP_COL11 == "S") .And. !((cAliasCDM)->CDM_TIPODB$ "BD")
				RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
			ElseIf lConsFinal	.And. !(RCA->TMP_COL11 == "S") .And. !((cAliasCDM)->CDM_TIPODB$ "BD")
				RCA->TMP_COL10	:= 	"S" 	//Saida a Consumidor/ Usuario Final
				RCA->TMP_COL15	:=	0 // Base de calculo efetiva na saida a consumidor/usuario final ou saida isenta
				RCA->TMP_VAPU10 :=	(cAliasCDM)->CDM_BSSAI	// Base de calculo efetiva na saida a consumidor/usuario final		
			ElseIf ((cAliasCDM)->CDM_UFSAI <> MV_ESTADO) .AND. ((cAliasCDM)->CDM_UFSAI <> "EX") .And.!((cAliasCDM)->CDM_TIPODB$ "BD") .AND. !lConsFinal
				RCA->TMP_COL13	:= 	"S"		//Saida para outro Estado
			ElseIf !lConsFinal
				RCA->TMP_COL14	:=	"S"    //Saida para comercializacao subsequente
			Endif  
			
			If !lConsFinal .And.!((cAliasCDM)->CDM_TIPODB$ "BD") .and. (cAliasCDM)->CDM_BSERET > 0 
				RCA->TMP_APU08	:= "S"     //Saida nao destinada a consumidor ou usuario final
			EndIf			                                     
			If ((cAliasCDM)->CDM_TIPODB$ "D") .and. (cAliasCDM)->CDM_BSSRET > 0  
				RCA->TMP_APU04	:= "S"     //Devolucoes de mercadorias recebidas
			EndIf
			
			RCA->(MsUnlock())
			(cAliasCDM)->(dbSkip())
		EndDo
		If lQuery
			dbSelectArea(cAliasCDM)
			dbCloseArea()
		EndIf
		
		(cAliasSFK)->(dbSkip())
	EndDo
	If lQuery
		dbSelectArea(cAliasSFK)
		dbCloseArea()
	EndIf

Else

#IFDEF TOP
	lQuery := .T.
	cAliasSFK := "AliasSFK"
	aStruSFK  := SFK->(dbStruct())
	cQuery := "SELECT FK_FILIAL,FK_PRODUTO,FK_DATA,"
	cQuery += "FK_AICMS,FK_QTDE,FK_BRICMS,FK_BASEICM " 
	If SFK->(FieldPos("FK_CONPAUT")) > 0
		cQuery += ",FK_CONPAUT " 
	EndIf	
	cQuery += "FROM "+RetSqlName("SFK")+" "
	cQuery += "WHERE FK_FILIAL='"+xFilial("SFK")+"' AND "
	If nModApur == 2 .and. Alltrim(Upper(FunName()))<>"MATR930" .And. Alltrim(Upper(FunName()))<>"MATA950"
		cQuery += "FK_DATA>='"+Dtos(dDtIni)+"' AND "
		cQuery += "FK_DATA<='"+Dtos(dDtIni)+"' AND "   
	else
		cQuery += "FK_DATA>='"+Dtos(dDtIni)+"' AND "
		cQuery += "FK_DATA<='"+Dtos(dDtFim)+"' AND "   
	EndIf
	If Alltrim(Upper(FunName()))<>"MATR930" .And. Alltrim(Upper(FunName()))<>"MATA950"  //GERACAO DO ARQUIVO MAGNETICO
		cQuery += "FK_PRODUTO>='" + cProdIni + "' AND "
		cQuery += "FK_PRODUTO<='" + cProdFin + "' AND "    
	EndIf
	If SFK->(FieldPos("FK_DTFIMST")) > 0
		cQuery += "(FK_DTFIMST>=FK_DATA OR ISNULL(FK_DTFIMST,'')='') AND "   //Data Final de controle de ressarcimento do ICMS-ST na CAT17
	EndIf
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SFK->(IndexKey()))
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFK,.T.,.T.)
	
	For nX := 1 To Len(aStruSFK)
		If aStruSFK[nX][2] <> "C" .And. FieldPos(aStruSFK[nX][1])<>0
			TcSetField(cAliasSFK,aStruSFK[nX][1],aStruSFK[nX][2],aStruSFK[nX][3],aStruSFK[nX][4])
		EndIf
	Next nX
	dbSelectArea(cAliasSFK)	
#ELSE
	SFK->(dbSeek(xFilial("SFK")+Padr(cProdIni,TamSx3("FK_PRODUTO")[1])+dtos(dDtIni),.T.))
#ENDIF

ProcRegua( (cAliasSFK)->(RecCount() ) )

While (cAliasSFK)->(!Eof()) .and. (cAliasSFK)->FK_FILIAL == xFilial("SFK")

	dDtIni	:= (cAliasSFK)->FK_DATA
	dDtFim	:= CToD('01'+'/'+StrZero(Month((cAliasSFK)->FK_DATA + 32),2)+'/'+StrZero(Year((cAliasSFK)->FK_DATA + 32),4)) - 1
	
	If Dtos((cAliasSFK)->FK_DATA) < dtos(dDtIni) .Or. Dtos((cAliasSFK)->FK_DATA) > dtos(dDtFim)
		dbSelectArea(cAliasSFK)

		IncProc()
		
		dbSkip()
		Loop
	EndIf
        
	SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))
 	
	RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD	:=	(cAliasSFK)->FK_PRODUTO
		RCA->TMP_MES	:=	StrZero(month((cAliasSFK)->FK_DATA),2)
		RCA->TMP_ANO	:=	StrZero( Year((cAliasSFK)->FK_DATA),4)
		RCA->TMP_ALIQ	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		RCA->TMP_ALIQS	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		RCA->TMP_DATA	:=	(cAliasSFK)->FK_DATA
		RCA->TMP_NUMSEQ	:=	replicate("0",6)
		RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR	:=	SM0->M0_INSC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Coloca-se "saldo" na NF de entrada para saber que³
		//³ este registro refere-se ao saldo inicial        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RCA->TMP_NFENTR	:=	"SALDO"	 
		RCA->TMP_ENTSAI := "A"
		RCA->TMP_COL17	:=	iif((cAliasSFK)->FK_QTDE	>= 0,(cAliasSFK)->FK_QTDE,0)				                        	// Quantidade
		RCA->TMP_COL18	:= 	iif((cAliasSFK)->FK_QTDE	>= 0,	noround((cAliasSFK)->FK_BRICMS/(cAliasSFK)->FK_QTDE,9),0)	    // Valor Unitario ST
		RCA->TMP_COL19	:=	iif((cAliasSFK)->FK_QTDE	>= 0,	(cAliasSFK)->FK_BRICMS,0)		  					         	// Valor Total BC ST
		RCA->TMP_COL20	:=	iif((cAliasSFK)->FK_QTDE	>= 0,	noround((cAliasSFK)->FK_BASEICM/(cAliasSFK)->FK_QTDE,9) ,0)     //Vl Unit. da BC Oper. Propria
		RCA->TMP_COL21	:=	iif((cAliasSFK)->FK_QTDE	>= 0,(cAliasSFK)->FK_BASEICM,0)							             	//Valor total da BC oper. Propria   
		RCA->TMP_UNID	:= SB1->B1_UM	    
	RCA->(MsUnlock())

	SD1->(dbSetOrder(6))
	#IFDEF TOP
		lQuery := .T.
		cAliasSD1 := "AliasSD1"
		aStruSD1  := SD1->(dbStruct())
		cQuery := "SELECT SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_COD,SD1.D1_TOTAL, SD1.D1_BASNDES, "
		cQuery += "SD1.D1_NUMSEQ,SD1.D1_UM,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_QUANT,SD1.D1_BRICMS,SD1.D1_TIPO,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_TES,SD1.D1_BASEICM,SD1.D1_PICM, SD1.D1_CF, SD1.D1_NFORI, SD1.D1_LOCAL, SD1.D1_SERIORI, SD1.D1_ITEMORI "
		cQuery += "FROM "+RetSqlName("SD1")+" SD1, "+ RetSqlName("SF4")+ " SF4 "
		cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "   
		cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		cQuery += "SD1.D1_DTDIGIT>='"+Dtos(dDtIni)+"' AND "
		cQuery += "SD1.D1_DTDIGIT<='"+Dtos(dDtFim)+"' AND "
  		cQuery += "SD1.D1_COD = '"+(cAliasSFK)->FK_PRODUTO+"' AND "
  		cQuery += "SD1.D1_TES = SF4.F4_CODIGO AND "
  		cQuery += "SF4.F4_ESTOQUE = 'S' AND "
  		cQuery += "SF4.F4_PODER3 = 'N' AND "
    	cQuery += "SD1.D_E_L_E_T_=' ' AND "
    	cQuery += "SF4.D_E_L_E_T_=' ' " 
    	If ExistBlock("CAT17SD1")
			cQuery := ExecBlock("CAT17SD1",.F.,.F.,cQuery)
		EndIf

		cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		
		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD1)	
	#ELSE
		SD1->(dbSeek(xFilial("SD1")+dtos(dDtIni),.T.))
	#ENDIF   
	
	RECLOCK("RCA",.F.)
	If (cAliasSD1)->(!EOF()) .And. (cAliasSD1)->D1_FILIAL==xFilial("SD1") .And.(cAliasSD1)->D1_DTDIGIT <= dDtFim
		RCA->TMP_MOVD1 	:= "S"
   		RCA->TMP_SLD17	:= 	0
		RCA->TMP_SLD19	:=	0
		RCA->TMP_SLD21	:=	0		
   		RCA->TMP_SLDALQ	:= 	0   
	Else	       
		RCA->TMP_MOVD1 	:= "N"
		RCA->TMP_SLD17	:= 	RCA->TMP_COL17
		RCA->TMP_SLD19	:=	RCA->TMP_COL19
		RCA->TMP_SLD21	:=	RCA->TMP_COL21
		RCA->TMP_SLDALQ	:= 	RCA->TMP_ALIQ  
	EndIf                
	RCA->(MsUnlock())	




	While (cAliasSD1)->(!EOF()) .And. (cAliasSD1)->D1_FILIAL==xFilial("SD1") .And. (cAliasSD1)->D1_DTDIGIT <= dDtFim
	
		If (cAliasSD1)->D1_COD <> (cAliasSFK)->FK_PRODUTO .Or. (cAliasSD1)->D1_LOCAL $ cArmCT17
			dbSelectArea("SD1")
			(cAliasSD1)->(dbSkip())
			Loop
		Endif	

		nAliqInt	:= 0    
		cGrpTrib 	:= ""
				
		SB1->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
		SF4->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))	 
		SF1->(dbSetOrder(1))
	    SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))                                                                  
	
		//Nao considero as notas de poder de terceiros
		If SF4->F4_PODER3 <> "N"
			dbSelectArea("SD1")
			(cAliasSD1)->(dbSkip())
			Loop	
		Endif
		
		If (cAliasSD1)->D1_TIPO $ "BD"
		    SA1->(dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		   	cGrpTrib 	:= SA1->A1_GRPTRIB  
		   	lConsFinal	:= If( SA1->A1_TIPO=="F", .T.,.F.)
		Else
		    SA2->(dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		   	cGrpTrib 	:= SA2->A2_GRPTRIB   
		   	lConsFinal	:= If( SA2->A2_TIPO=="F", .T.,.F.)
		EndIf 
		// Loop abaixo retirado, pois já existe o tratamento para imprimir ou não o valor nas colunas que influenciam
		// no ressarcimento ou complemento do imposto, e não podemos somente não apresentar a movimentação, o que varia o estoque
		// ficar incorreto
		//Verifico se serao processados as notas para Consumidor Final que nao possuem Pauta  
		/*If SFK->(FieldPos("FK_CONPAUT")) > 0
			If lConsFinal .And. (cAliasSFK)->FK_CONPAUT== "1".And. SB1->B1_VLR_ICM == 0
				(cAliasSD1)->(dbSkip())
				Loop	
        	Endif
        EndIf*/
        			    
	  	If !Empty(SB1->B1_GRTRIB)
			dbSelectArea("SF7")
			SF7->(dbSetOrder(1))
			If SF7->(dbSeek(xFilial("SF7")+SB1->B1_GRTRIB+cGrpTrib))
				While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+SB1->B1_GRTRIB+cGrpTrib
					If (MV_ESTADO == SF7->F7_EST .Or. SF7->F7_EST == "**")
						nAliqInt	:= Iif(SF7->(FieldPos("F7_ALIQINT")) > 0,SF7->F7_ALIQINT,0)
						Exit
					Endif
					SF7->(dbSkip())
				End
			EndIf
		EndIf
	
		RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD		:=  (cAliasSD1)->D1_COD
		RCA->TMP_MES		:=	StrZero(month((cAliasSD1)->D1_DTDIGIT),2)
		RCA->TMP_ANO		:=	StrZero( Year((cAliasSD1)->D1_DTDIGIT),4)
		If lTabSB1
			RCA->TMP_ALIQ	:= if( !empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)
			RCA->TMP_ALIQS	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		Else
			RCA->TMP_ALIQ 	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
			RCA->TMP_ALIQS	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		EndIf
		RCA->TMP_NUMSEQ	:=	(cAliasSD1)->D1_NUMSEQ
		RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR	:=	SM0->M0_INSC
		RCA->TMP_UNID	:=	(cAliasSD1)->D1_UM
		RCA->TMP_DATA	:=	(cAliasSD1)->D1_DTDIGIT
		RCA->TMP_BSNDES	:=	(cAliasSD1)->D1_BASNDES			
		RCA->TMP_NFENTR	:=	(cAliasSD1)->D1_DOC
		RCA->TMP_CFO	:=	(cAliasSD1)->D1_CF 
		RCA->TMP_FOR	:=	(cAliasSD1)->D1_FORNECE 
		RCA->TMP_FILIAL := 	(cAliasSD1)->D1_FILIAL
		RCA->TMP_SERENT	:=	(cAliasSD1)->D1_SERIE
		RCA->TMP_QTDENT	:=	(cAliasSD1)->D1_QUANT
		RCA->TMP_VTENTR	:=	IIF((cAliasSD1)->D1_BRICMS>0,(cAliasSD1)->D1_BRICMS,(cAliasSD1)->D1_BASNDES)	// Valor total da base de calculo da retencao
		RCA->TMP_VTBPR	:=	(cAliasSD1)->D1_BASEICM	// Valor total da base de calculo propria
		RCA->TMP_LOJA   :=  (cAliasSD1)->D1_LOJA//LOJA
		RCA->TMP_VLMERC :=  (cAliasSD1)->D1_TOTAL
   		RCA->TMP_REDBC :=   SF4-> F4_BASEICM		
   		RCA->TMP_ENTSAI := "E"
		//Tratar NF de Devolucao e Retorno
		IF (cAliasSD1)->D1_TIPO $ "BD"
		    SA1->(dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		    lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)
		   	cGrpTrib 	:= SA1->A1_GRPTRIB
	
			If SF4->F4_LFICM $"IN" .and. !lConsFinal  .And. !(RCA->TMP_COL11 == "S")
				RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
         			If (SF1->F1_EST <> MV_ESTADO) .AND. (SF1->F1_EST <> "EX")
					RCA->TMP_COL13	:= 	"S"		//Saida para outro Estado  
				Endif	
			ElseIf lConsFinal	.And. !(RCA->TMP_COL11 == "S") .AND. Iif (lPautaOp ,((cAliasSFK)->FK_CONPAUT== "1".And. SB1->B1_VLR_ICM > 0),.T.)
				RCA->TMP_COL10	:= 	"S" 	//Saida a Consumidor/ Usuario Final
				RCA->TMP_COL15	:= 0 // Base de calculo efetiva na saida a consumidor/usuario final ou saida isenta
				RCA->TMP_VAPU11 :=  (cAliasSD1)->D1_TOTAL
			ElseIf (SF1->F1_EST <> MV_ESTADO) .AND. (SF1->F1_EST <> "EX") .AND. !lConsFinal
				RCA->TMP_COL13	:= 	"S"		//Saida para outro Estado
			ElseIf !lConsFinal
				RCA->TMP_COL14	:=	"S"     //Saida para comercializacao subsequente
			Endif	           
			RCA->TMP_TIPO		:=	(cAliasSD1)->D1_TIPO

			If !lConsFinal .and. ((cAliasSD1)->D1_BRICMS > 0 .OR. (cAliasSD1)->D1_BASNDES > 0)
				RCA->TMP_APU08 := "S"		// Saida nao destinada a consumidor ou usuario final
			EndIf
			
		ElseIf (SF1->F1_EST == MV_ESTADO)
			RCA->TMP_APU02	:=	"S"		//Entradas exceto devolucoes ou retornos						
		Else
			RCA->TMP_APU03	:=	"S"		//	Entrada de mercadorias de outro estado
		EndIf			
		
		RCA->TMP_CLIFOR	:=	(cAliasSD1)->D1_FORNECE
		RCA->TMP_NUMDOC	:=	(cAliasSD1)->D1_DOC
		RCA->TMP_SERIE	:=	(cAliasSD1)->D1_SERIE
		RCA->TMP_NFORI 	:=  (cAliasSD1)->D1_NFORI // Numero da Nf Original
		RCA->TMP_SERORI :=  (cAliasSD1)->D1_SERIORI // Série da Nf Original

		RCA->(MsUnlock())
	
		(cAliasSD1)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	EndIf
	
	
	SD2->(dbSetOrder(5))
	#IFDEF TOP
		lQuery := .T.
		cAliasSD2 := "AliasSD2"
		aStruSD2  := SD2->(dbStruct())
		cQuery := "SELECT SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_COD,SD2.D2_CF,SD2.D2_TOTAL, "
		cQuery += "SD2.D2_NUMSEQ,SD2.D2_UM,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_QUANT,SD2.D2_BRICMS,SD2.D2_TIPO,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_TES,SD2.D2_BASEICM,SD2.D2_PICM,SD2.D2_BRICMS,SD2.D2_NFORI, SD2.D2_LOCAL , SD2.D2_SERIORI, SD2.D2_ITEMORI "
		cQuery += "FROM "+RetSqlName("SD2")+" SD2, "+ RetSqlName("SF4")+ " SF4 "
		cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "   
		cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		cQuery += "SD2.D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
		cQuery += "SD2.D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
  		cQuery += "SD2.D2_COD = '"+(cAliasSFK)->FK_PRODUTO+"' AND "     
   		cQuery += "SD2.D2_TES = SF4.F4_CODIGO AND "
  		cQuery += "SF4.F4_ESTOQUE = 'S' AND  "
  		cQuery += "SF4.F4_PODER3 = 'N' AND "
    	cQuery += "SD2.D_E_L_E_T_=' ' AND "
    	cQuery += "SF4.D_E_L_E_T_=' ' "     
		If ExistBlock("CAT17SD2")
			cQuery := ExecBlock("CAT17SD2",.F.,.F.,cQuery)
		EndIf

		cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		
		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD2)	
	#ELSE
		(cAliasSD2)->(dbSeek(xFilial("SD2")+dtos(dDtIni),.T.))
	#ENDIF

   	RECLOCK("RCA",.F.) 
	If (cAliasSD2)->(!EOF()) .and. (cAliasSD2)->D2_EMISSAO <= dDtFim
		RCA->TMP_MOVD2 		:= "S"
  		RCA->TMP_SLD17		:= 	0
		RCA->TMP_SLD19		:=	0
		RCA->TMP_SLD21		:=	0		
   		RCA->TMP_SLDALQ  	:= 	0
	Else	
		RCA->TMP_MOVD2		:= "N"
		RCA->TMP_SLD17		:= 	RCA->TMP_COL17
		RCA->TMP_SLD19		:=	RCA->TMP_COL19
		RCA->TMP_SLD21		:=	RCA->TMP_COL21
		RCA->TMP_SLDALQ		:= 	RCA->TMP_ALIQ
	EndIf     
	RCA->(MsUnlock())
	
	
	
	
	While (cAliasSD2)->(!EOF()) .and. (cAliasSD2)->D2_EMISSAO <= dDtFim
		nAliqInt	:= 0    
		cGrpTrib 	:= ""
		cUF		 	:= ""
	
		If (cAliasSD2)->D2_COD <> (cAliasSFK)->FK_PRODUTO .Or. (cAliasSD2)->D2_LOCAL $ cArmCT17 
			dbSelectArea("SD2")
			(cAliasSD2)->(dbSkip())
			Loop
		Endif	
		
		SB1->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
	    SF4->(dbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
	    SF2->(dbSetOrder(4))
	    SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_SERIE+dtos((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		
		//Nao considero as notas de poder de terceiros
		If SF4->F4_PODER3 <> "N"
			dbSelectArea("SD2")
			(cAliasSD2)->(dbSkip())
			Loop	
		Endif

	    If (cAliasSD2)->D2_TIPO $ "DB"  			
		    SA2->(dbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		    lConsFinal	:= if( SA2->A2_TIPO=="F", .T.,.F.)                              
   			cGrpTrib 	:= SA2->A2_GRPTRIB
			cUF			:= SA2->A2_EST
	    Else 
	    	If lCliRel
				SC6->(dbSetOrder(4))
	   			SC5->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))    
	    			If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM))
		    		    lConsFinal	:= if( SC5->C5_TIPOCLI=="F", .T.,.F.)  
		    		EndIf
				Else  
					SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			    	lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)  
			       	cGrpTrib	:= SA1->A1_GRPTRIB
		   			cUF			:= SA1->A1_EST
				EndIf	
		    Else
		    	SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		    	lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)   
		    	cGrpTrib	:= SA1->A1_GRPTRIB   
		    	cUF			:= SA1->A1_EST
		    EndIf
		EndIf    
		// Loop abaixo retirado, pois já existe o tratamento para imprimir ou não o valor nas colunas que influenciam
		// no ressarcimento ou complemento do imposto, e não podemos somente não apresentar a movimentação, o que varia o estoque
		// ficar incorreto
		//Verifico se serao processados as notas para Consumidor Final que nao possuem Pauta 
		/*If SFK->(FieldPos("FK_CONPAUT")) > 0
			If lConsFinal .And. (cAliasSFK)->FK_CONPAUT== "1".And. SB1->B1_VLR_ICM == 0
				(cAliasSD2)->(dbSkip())
				Loop	
        	Endif
        EndIf*/
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento implementado para utilizacao da Excecao Fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      	If !Empty(SB1->B1_GRTRIB)
			dbSelectArea("SF7")
			SF7->(dbSetOrder(1))
			If SF7->(dbSeek(xFilial("SF7")+SB1->B1_GRTRIB+cGrpTrib))
				While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+SB1->B1_GRTRIB+cGrpTrib
					If (cUF == SF7->F7_EST .Or. SF7->F7_EST == "**")
						nAliqInt	:= Iif(SF7->(FieldPos("F7_ALIQINT")) > 0,SF7->F7_ALIQINT,0)
						Exit
					Endif
					SF7->(dbSkip())
				End
			EndIf
		EndIf
	
		RECLOCK("RCA",.T.)                   
		RCA->TMP_NUMSEQ	:=	(cAliasSD2)->D2_NUMSEQ
		RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR	:=	SM0->M0_INSC
		RCA->TMP_MERCAD	:=	(cAliasSD2)->D2_COD
		RCA->TMP_MES	:=	StrZero(month((cAliasSD2)->D2_EMISSAO),2)
		RCA->TMP_ANO	:=	StrZero( Year((cAliasSD2)->D2_EMISSAO),4)
		If lTabSB1
			RCA->TMP_ALIQ		:= if(!empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)  
			RCA->TMP_ALIQS	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		Else                      
			//RCA->TMP_ALIQ		:= 	Iif(nAliqInt>0, nAliqInt,Iif((cAliasSD2)->D2_PICM>0,(cAliasSD2)->D2_PICM,nPerICM ))	
			RCA->TMP_ALIQ		:= 	Iif(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
			RCA->TMP_ALIQS	:=	Iif(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		EndIf				
		RCA->TMP_UNID	:=	(cAliasSD2)->D2_UM
		RCA->TMP_DATA	:=	(cAliasSD2)->D2_EMISSAO
		RCA->TMP_NFSAID	:=	(cAliasSD2)->D2_DOC		// Numero da NF de saida
		RCA->TMP_SERSAI	:=	(cAliasSD2)->D2_SERIE	// Serie da NF de Saida
		RCA->TMP_QTDSAI	:=	(cAliasSD2)->D2_QUANT	// Quantidade da saida
		RCA->TMP_CFO	:=	(cAliasSD2)->D2_CF
		RCA->TMP_CLI	:=	(cAliasSD2)->D2_CLIENTE  
		RCA->TMP_LOJA   :=  (cAliasSD2)->D2_LOJA//LOJA
		RCA->TMP_FILIAL := 	(cAliasSD2)->D2_FILIAL
		RCA->TMP_VTBST	:=	(cAliasSD2)->D2_BRICMS	// Valor total da base de calculo propria ST  
		RCA->TMP_VTBPR	:=  (cAliasSD2)->D2_BASEICM	    
		RCA->TMP_TIPO	:=	(cAliasSD2)->D2_TIPO
		RCA->TMP_REDBC	:=	SF4->F4_BASEICM 
		RCA->TMP_ENTSAI := "S"
		
	   	IF SF4->F4_DESTRUI == "1" .And. SF4->F4_TIPO == "S"//GRAZI
			RCA->TMP_COL11 := "S"
		EndIf	
		
		If SF4->F4_BASEICM <> 0
			Do Case
				Case (SF4->F4_LFICM $"IN") .and. !lConsFinal .And. !(RCA->TMP_COL11 == "S").And. !((cAliasSD2)->D2_TIPO$ "BD") .And.;
						(SF2->F2_EST <> MV_ESTADO) .AND. (SF2->F2_EST <> "EX")
						
					RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
					RCA->TMP_COL13	:=	"S"		//Saida para outro Estado
					
				Case (SF4->F4_LFICM $"IN") .and. !(RCA->TMP_COL11 == "S").And. !((cAliasSD2)->D2_TIPO$ "BD")
				
					RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
					RCA->TMP_COL10	:= 	"S" 	//Saida a Consumidor/ Usuario Final
					
				Case (SF4->F4_LFICM $"IN") .and. !lConsFinal
				
					RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
					RCA->TMP_COL14	:=	"S"     //Saida para comercializacao subsequente
				
			EndCase
		
		Else
			Do Case
				Case (SF4->F4_LFICM $"IN") .and. !lConsFinal .And. !(RCA->TMP_COL11 == "S").And. !((cAliasSD2)->D2_TIPO$ "BD")
					
					RCA->TMP_COL12	:=	"S"  	//Saida com Isencao/Nao incidencia
				
				Case lConsFinal	.And. !(RCA->TMP_COL11 == "S") .And. !((cAliasSD2)->D2_TIPO$ "BD") .AND. Iif (lPautaOp ,((cAliasSFK)->FK_CONPAUT== "1".And. SB1->B1_VLR_ICM > 0),.T.)
				   
					RCA->TMP_COL10	:= 	"S" 	//Saida a Consumidor/ Usuario Final
					RCA->TMP_COL15	:=	0 // Base de calculo efetiva na saida a consumidor/usuario final ou saida isenta
					RCA->TMP_VAPU10	:=	(cAliasSD2)->D2_TOTAL
				
				Case (SF2->F2_EST <> MV_ESTADO) .AND. (SF2->F2_EST <> "EX") .And.!((cAliasSD2)->D2_TIPO$ "BD") .And. !lConsFinal
				
					RCA->TMP_COL13	:= 	"S"		//Saida para outro Estado
				
				Case !lConsFinal
				
					RCA->TMP_COL14	:=	"S"     //Saida para comercializacao subsequente
			
			EndCase
		Endif		         
		
		If !lConsFinal .And.!((cAliasSD2)->D2_TIPO$ "BD") .And.(cAliasSD2)->D2_BRICMS > 0  
			RCA->TMP_APU08	:= "S"		//Saida nao destinada a consumidor ou usuario final
        EndIf                                                                      
        
        If ((cAliasSD2)->D2_TIPO$ "D") .and. (cAliasSD2)->D2_BRICMS > 0  
			RCA->TMP_APU04	:= "S"     //Devolucoes de mercadorias recebidas
		EndIf

		RCA->TMP_CLIFOR	:=	(cAliasSD2)->D2_CLIENTE
		RCA->TMP_NUMDOC	:=	(cAliasSD2)->D2_DOC
		RCA->TMP_SERIE	:=	(cAliasSD2)->D2_SERIE
		RCA->TMP_NFORI 	:=  (cAliasSD2)->D2_NFORI // Numero da Nf Original
		RCA->TMP_SERORI :=  (cAliasSD2)->D2_SERIORI // Série da Nf Original
		
		RCA->(MsUnlock())
		dbSelectArea("SD2")
		(cAliasSD2)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacoes Internas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
 	If lGeraD3
		SD3->(dbSetOrder(6))
			#IFDEF TOP
				lQuery := .T.
				cAliasSD3 := "AliasSD3"
				aStruSD3  := SD3->(dbStruct())
				cQuery := "SELECT D3_FILIAL,D3_EMISSAO,D3_COD,D3_LOTECTL,"
				cQuery += "D3_NUMSEQ,D3_UM,D3_DOC,D3_QUANT,D3_ESTORNO,D3_CF,D3_LOCAL,D3_TM "
				cQuery += "FROM "+RetSqlName("SD3")+" "
				cQuery += "WHERE D3_FILIAL='"+xFilial("SD3")+"' AND "
				cQuery += "D3_EMISSAO>='"+Dtos(dDtIni)+"' AND "
				cQuery += "D3_EMISSAO<='"+Dtos(dDtFim)+"' AND "
		  		cQuery += "D3_COD = '"+(cAliasSFK)->FK_PRODUTO+"' AND "
		  		cQuery += "D3_ESTORNO = ' ' AND "    			    	
		    	cQuery += "D_E_L_E_T_=' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.T.)
				
				For nX := 1 To Len(aStruSD3)                
					If aStruSD3[nX][2] <> "C" .And. FieldPos(aStruSD3[nX][1])<>0
						TcSetField(cAliasSD3,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
					EndIf
				Next nX
				dbSelectArea(cAliasSD3)	
			#ELSE
				(cAliasSD3)->(dbSeek(xFilial("SD3")+dtos(dDtIni),.T.))
			#ENDIF

			RECLOCK("RCA",.F.)
			If (cAliasSD3)->(!EOF()) .and. (cAliasSD3)->D3_EMISSAO <= dDtFim  
				RCA->TMP_MOVD3 	:= "S"
		  		RCA->TMP_SLD17	:= 0
				RCA->TMP_SLD19	:=	0
				RCA->TMP_SLD21	:=	0		
			   	RCA->TMP_SLDALQ  :=	0
			Else	 
				RCA->TMP_MOVD3 	:= "N"
				RCA->TMP_SLD17	:=	RCA->TMP_COL17
				RCA->TMP_SLD19	:=	RCA->TMP_COL19
				RCA->TMP_SLD21	:=	RCA->TMP_COL21
				RCA->TMP_SLDALQ	:=	RCA->TMP_ALIQ
			EndIf	
	   		RCA->(MsUnlock()) 
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Loop para  verificar se possuo algum documento com mais        ³
			//³de um Numero de Sequencia, pois para as notas de transferen    ³
			//³cia de armazens sao geradas duas notas uma com RE4 e outra DE4.³
			//³E na impressao do relatorio nao devem ser apresentadas as notas³
			//³de transferencia.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			While (cAliasSD3)->(!EOF()) .and. (cAliasSD3)->D3_EMISSAO <= dDtFim
					// Incluida a verificacao referente ao estorno por orientacao do analista Marcos - Estoque.	
					If ( Alltrim((cAliasSD3)->D3_COD) <> Alltrim((cAliasSFK)->FK_PRODUTO)) .Or. (!Empty((cAliasSD3)->D3_ESTORNO)) .Or. (cAliasSD3)->D3_LOCAL $ cArmCT17
						(cAliasSD3)->(dbSkip())
						Loop
					Endif	                                             
					     
					If Substr((cAliasSD3)->D3_CF,1,3) == "RE4" .Or. Substr((cAliasSD3)->D3_CF,1,3) == "DE4"
				   		cChaveSD3 := (cAliasSD3)->(D3_NUMSEQ+D3_COD)
				   		nPos 	  := Ascan(aEstoque,{ |x| x[1] == cChaveSD3})
						If nPos >0
							nCont	:= nCont + 1  
						EndIF
			
						If nPos == 0
						nCont	:= 1
					    	aAdd(aEstoque,{cChaveSD3,nCont})          
					 	Else
					 		aEstoque[nPos,2]:=nCont
					 	EndIF
	   				EndIf
	   				 
	   				(cAliasSD3)->(dbSkip())
	   				Loop
	   		EndDo		 
	       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faco novamente o mesmo Looping,agora para gravar as notas que  ³
			//³ sao de tranferencia mas nao de armazens e para as demais      ³
			//³movimentacoes Internas.                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		  	(cAliasSD3)->(dbGotop())		    
	                                                     
			While (cAliasSD3)->(!EOF()) .and. (cAliasSD3)->D3_EMISSAO <= dDtFim
				// Incluida a verificacao referente ao estorno por orientacao do analista Marcos - Estoque.	
				If ( Alltrim((cAliasSD3)->D3_COD) <> Alltrim((cAliasSFK)->FK_PRODUTO)) .Or. (!Empty((cAliasSD3)->D3_ESTORNO))  .Or. (cAliasSD3)->D3_LOCAL $ cArmCT17
					(cAliasSD3)->(dbSkip())
					Loop
				Endif	
	
	            If Substr((cAliasSD3)->D3_CF,1,3) == "RE4" .Or. Substr((cAliasSD3)->D3_CF,1,3) == "DE4"
	                cChaveSD3 := (cAliasSD3)->(D3_NUMSEQ+D3_COD)
			   		nPos 	  := Ascan(aEstoque,{ |x| x[1] == cChaveSD3 })
					If nPos >0 
						If aEstoque[nPos,2]>1
							(cAliasSD3)->(dbSkip())
							Loop
						EndIf
					EndIf
				EndIf				   		                   
				
				SB1->(dbSeek(xFilial("SB1")+(cAliasSD3)->D3_COD))
			
				RECLOCK("RCA",.T.)    
				RCA->TMP_CONTRI		:=	SM0->M0_NOMECOM
				RCA->TMP_INSCR		:=	SM0->M0_INSC
				RCA->TMP_MES		:=	StrZero(month((cAliasSD3)->D3_EMISSAO),2)
				RCA->TMP_ANO		:=	StrZero( Year((cAliasSD3)->D3_EMISSAO),4)
				RCA->TMP_NUMSEQ		:=	(cAliasSD3)->D3_NUMSEQ
				RCA->TMP_MERCAD		:=	(cAliasSD3)->D3_COD 
				If lTabSB1
					RCA->TMP_ALIQ	:= if(!empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)  
					RCA->TMP_ALIQS	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
				Else                      
					RCA->TMP_ALIQ	:= 	Iif(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
					RCA->TMP_ALIQS	:=	Iif(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
				EndIf				
				RCA->TMP_UNID		:=	(cAliasSD3)->D3_UM
				RCA->TMP_DATA		:=	(cAliasSD3)->D3_EMISSAO
		
				// Numero da NF de saida
		
				//Somente leva para o Coluna 11 Movimentos cadastrados no parametro MV_TMVSD3
				If (cMovSD3 $ (cAliasSD3)->D3_TM .Or. Empty(cMovSD3))
					If Substr((cAliasSD3)->D3_CF,1,2) == "RE"  					// Se for uma requisição é considerado como saída.
						  RCA->TMP_NFSAID	:=	(cAliasSD3)->D3_DOC
						  RCA->TMP_QTDSAI	:=	(cAliasSD3)->D3_QUANT		// Quantidade da saida
						  RCA->TMP_ENTSAI 	:= "S"
					    If (cRastro) == "S"		    	
			  				cProdOrig := CAT17PrdOrg((cAliasSD3)->D3_DOC,(cAliasSD3)->D3_NUMSEQ,(cAliasSD3)->D3_CF)
							nBaseIcm  := CAT17Rastro(cProdOrig,(cAliasSD3)->D3_LOTECTL,"S")
							RCA->TMP_VTBST	:=	nBaseIcm				  
						   	RCA->TMP_BSTRAN	:=	nBaseIcm
		       	    	EndIf
					Else 
						   RCA->TMP_NFENTR	:=	(cAliasSD3)->D3_DOC			//Se for uma produção ou uma devolução é considerado como entrada.
						   RCA->TMP_QTDENT	:=	(cAliasSD3)->D3_QUANT		// Quantidade da entrada
						   RCA->TMP_ENTSAI  := "E"
					    If (cRastro) == "S"		    	
		  					cProdOrig := CAT17PrdOrg((cAliasSD3)->D3_DOC,(cAliasSD3)->D3_NUMSEQ,(cAliasSD3)->D3_CF)
					    	nBaseIcm := CAT17Rastro(cProdOrig,(cAliasSD3)->D3_LOTECTL,"E") 			    	
						   	RCA->TMP_VTENTR	:=	nBaseIcm
						   	RCA->TMP_BSTRAN	:=	nBaseIcm
		       	    	EndIf				
					Endif
			
					// Fato gerador nao realizado
					RCA->TMP_COL11	:=	"S"
				EndIf        
			
				RCA->(MsUnlock())
				(cAliasSD3)->(dbSkip())	
			EndDo

			If lQuery
				dbSelectArea(cAliasSD3)
				dbCloseArea()
			EndIf   
	Endif			

	IncProc()

	 dbSelectArea(cAliasSFK)                               
	(cAliasSFK)->(dbSkip())	
EndDo
If lQuery
	dbSelectArea(cAliasSFK)
	dbCloseArea()
EndIf

EndIf
Return                
               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction  ³FSCAT17TOTºAutor  ³                  º Data ³               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Totaliza os dados das notas fiscais e preenche as colunas   º±±
±±º          ³de apuracao dos valores                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} xT17TOT.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Montagem dos valores para o aArray - aMovimentos   

*/
User Function xT17TOT(cArqTMP,aApurMod1,nCDM,nModel,aApurMod5,dDtAp5Fim)

Local dData			:= ctod("")
Local cChave		:= ""
Local cChvTemp1		:= ""
Local cChvTemp2		:= ""
Local nCol09Ant		:= 	0
Local nCol17		:= 	0
Local nCol17Ant		:= 	0
Local nCol19		:=	0
Local nCol19Ant		:= 	0
Local nCol21Ant		:= 	0
Local nQuant		:= 	0
Local aTotais		:= 	array(19)
Local nColApur		:= 0
Local i 			:= 0
Local nAliq 		:= 0
Local nValor20 		:= 0
Local nValDev21 	:= 0
Local nValor21 		:= 0
Local z 			:=0
Local lPosic 		:= .F.
Local axAliq 		:= {}
Local aUnit 		:= {}
Local nX			:= 0
Local nY			:= 0
Local lBaseSaida	:= GetNewPar("MV_ATSBOP",.F.)    //Parametro utilizado para identificar se a base normal sera alterada referente a cada saida, nao utlizando a a ideia da base de calculo normal que inicialmente era atualizada referente a uma entrada
Local cInclProxM    := GetNewPar("MV_GERPRME",.F.)     
Local nSldCol17 	:= 0
Local nSldCol19 	:= 0
Local nSldCol21 	:= 0
Local nSldColAliq   := 0
Local nRedBC		:= 0
Local lMovSd1 		:= .F.
Local lMovSd2 		:= .F.
Local lMovSd3 		:= .F.
Local lLoop 		:= .F.
Local lCampD2		:= SD2->(Fieldpos("D2_09CAT17"))>0 .And. SD2->(Fieldpos("D2_16CAT17"))>0

Local dPData        := ctod("//")
Local nDtEstIni     := 0
Local nCol          := 0
Local nBasePr		:= 0
Local nCol16		:= 0
Local aStruRCA		:= {}
Local nW			:= 0 

Local cCodMult		:= 	""
Local cDescMarca	:= 	""
Local nPosMov		:= 0

Local nValCol4		:= 0
Local nValCol5		:= 0
Local nValCol6		:= 0
Local nValCol7		:= 0
Local nValCol8		:= 0
Local nValCol9		:= 0

Default nCDM 		:= 0
Default nModel		:= 0
Default aApurMod1 	:= array(15,5)
Default aApurMod5 	:= array(19,5)
Default dDtAp5Fim   := ctod("//")   

//Modelo 5
If nModel == 2
	afill(aTotais,0)
	Aeval(aApurMod5,{|x|aFill(x,0)})

	dbSelectArea("RCA")
	dbGoTop()
	
	
	ProcRegua(RCA->(RecCount()))
	
	While RCA->(!eof())
		if alltrim(RCA->TMP_NFENTR)	==	"TOTAIS"

			IncProc()
		
			RCA->(dbSkip())
			MsUnlock()
			loop
		endIf
		
		cChave		:= RCA->TMP_MERCAD+RCA->TMP_ANO
		nSldCol17 	:= RCA->TMP_SLD17
		nSldCol19 	:= RCA->TMP_SLD19
		nSldCol21 	:= RCA->TMP_SLD21
		nSldColAliq := RCA->TMP_SLDALQ
		lMovSD1 :=  Iif(RCA->TMP_MOVD1 == "S", .T.,.F.)
		lMovSD2 :=  Iif(RCA->TMP_MOVD2 == "S", .T.,.F.)
		lMovSD3 :=  Iif(RCA->TMP_MOVD3 == "S", .T.,.F.)
                                                                
		While RCA->(!eof()) .and. RCA->TMP_MERCAD+RCA->TMP_ANO == cChave

			If alltrim(RCA->TMP_NFENTR) == "SALDO"
				nCol17Ant	:= 	RCA->TMP_COL17
				nCol09Ant 	:= 	RCA->TMP_COL18
				nCol19Ant	:=	RCA->TMP_COL19
				nCol21Ant	:=	RCA->TMP_COL21
				nDtEstIni   := 	RCA->TMP_COL18

				IncProc()		

				RCA->(dbSkip())
				MsUnlock()
				loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valor da Base de Calculo da Retencao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Reclock("RCA",.F.)
			If ExistBlock("CAT17LOP") .And. !ExecBlock("CAT17LOP",.F.,.F.,{"RCA",nCol17Ant})
				RCA->(dbSkip())
				MsUnlock()
				loop
			EndIf
			
			If !empty(RCA->TMP_NFENTR) .And. !nCol09Ant > 0 .And. RCA->TMP_VTENTR > 0
				nCol09Ant := RCA->TMP_VTENTR /RCA->TMP_QTDENT
			ElseIf !empty(RCA->TMP_NFENTR) .And. !nCol09Ant > 0 .And. RCA->TMP_VTBPR > 0
				nCol09Ant := RCA->TMP_VTBPR /RCA->TMP_QTDENT
			EndIf
			RCA->TMP_COL09	:=	nCol09Ant
			
			
			If RCA->TMP_COL10 == "S" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³COL10 Saida a consumidor ou usuario final³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
					RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
				ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
					RCA->TMP_VAL10	:= 0
				else
					RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
				Endif
			Elseif RCA->TMP_COL11 == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³COL11 Fato gerador nao realizado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if RCA->TMP_TIPO $"BD" .Or. !empty(RCA->TMP_NFENTR)
					RCA->TMP_VAL11	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
				ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
					RCA->TMP_VAL11	:=	0
				else
					RCA->TMP_VAL11	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
				EndIf
			ElseIf RCA->TMP_APU02 == "S" .and. RCA->TMP_VTENTR > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Entradas estaduais com retencao exceto devolucoes ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				RCA->TMP_VAPU02 := noround(RCA->TMP_QTDENT * nCol09Ant,9)
			ElseIf RCA->TMP_APU03 == "S" .and. RCA->TMP_VTENTR > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Entradas intertaduais com recolhimento na entrada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				RCA->TMP_VAPU03 := noround(RCA->TMP_QTDENT * nCol09Ant,9)			
			ElseIf RCA->TMP_APU04 == "S"                                           
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Devolucao de mercadorias recebidas com imposto retido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RCA->TMP_VAPU04 := noround(RCA->TMP_QTDSAI * nCol09Ant,9)						
			ElseIf RCA->TMP_APU08 == "S"			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Operacoes de saida nao destinadas  a consumidor final³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If RCA->TMP_TIPO $"BD" .Or. !empty(RCA->TMP_NFENTR)
					RCA->TMP_VAPU08	:= noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
				Else
					RCA->TMP_VAPU08	:= noround(RCA->TMP_QTDSAI * nCol09Ant,9)
				EndIf
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³ Saldos  ³
			//ÀÄÄÄÄÄÄÄÄÄÙ
			RCA->TMP_COL17	:=	(nCol17Ant+RCA->TMP_QTDENT)- RCA->TMP_QTDSAI
			RCA->TMP_COL19	:=	nCol19Ant+IIF((RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14)==0,RCA->TMP_VTENTR,0)-IIF((RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14)<>0,(RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14),IIF((nCol19Ant/nCol17Ant)*RCA->TMP_QTDSAI>0,(nCol19Ant/nCol17Ant)*RCA->TMP_QTDSAI,RCA->TMP_VTBST))	
			RCA->TMP_COL18	:=	noround(RCA->TMP_COL19/RCA->TMP_COL17,9)	// Valor unitario da base de calculo da retencao
			
			If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR) //Devolucao de Compras (SD1)
				nValor21 	:= noround(nCol21Ant,9)
			ElseIf RCA->TMP_TIPO $"BD".And.!Empty(RCA->TMP_NFSAID)  // Devolucao de Venda (SD2)
				nValor21 	:= noround(nCol21Ant+(RCA->TMP_VTBPR*(-1)),9)
			Else
				nBasePr := IIF(RCA->TMP_VTBPR==0, RCA->TMP_VLMERC, RCA->TMP_VTBPR)
				nValor21 	:= noround(nCol21Ant+Iif(!Empty(RCA->TMP_NFENTR), nBasePr,0),9) //Agrega o valor da base de operacao propria nas movimentacoes de entrada
			EndIF
			nValor20 := nValor21/Iif(nCol17Ant==0,1,nCol17Ant) // Valor unitario da base de calculo da operacao propria
			
			nCol09Ant	:= RCA->TMP_COL18
			nCol17Ant	:= RCA->TMP_COL17
			nCol19Ant	:= RCA->TMP_COL19
			
			//Processo pela CDM
			If nCDM == 1
				If (RCA->TMP_COL13 == "S" .And. !(RCA->TMP_COL14 == "S")) .Or. (!RCA->TMP_COL11 == "S" .And. !RCA->TMP_COL14 == "S") .And.!(RCA->TMP_COL10 == "S")
					If RCA->TMP_BASMAN>0
						RCA->TMP_COL16:= RCA->TMP_VAL13
					Else
						RCA->TMP_COL16:= noround(((nvalor21/RCA->TMP_QTDENT) * RCA->TMP_QTDSAI),2)
					EndIf
					nCol21Ant	:=	nValor21 - RCA->TMP_COL16
				EndIf
			Else
				If lBaseSaida
					If RCA->TMP_TIPO $"BD"  .And. RCA->TMP_QTDENT>0
						nCol21Ant	:=	nValor21 - noround((nValor20 * RCA->TMP_QTDENT *(-1)),2)
					Elseif RCA->TMP_TIPO $"BD" .And.!Empty(RCA->TMP_NFSAID)
						nCol21Ant	:=	nValor21
					Else
						nCol21Ant	:=	nValor21 -  noround((nValor20 * RCA->TMP_QTDSAI),2)
					Endif
				Else
					nCol21Ant	:=	nValor21 - RCA->TMP_COL16
				EndIf
			EndIf
			RCA->TMP_COL21	:= nCol21Ant
			
			aTotais[01]	+= 	RCA->TMP_QTDENT
			If!RCA->TMP_TIPO$ "BD"
				aTotais[02]	+=	RCA->TMP_VTENTR
			ElseIf(RCA->TMP_TIPO $"BD".And.!Empty(RCA->TMP_NFSAID))
				aTotais[02]	+= RCA->TMP_VTBST*(-1)
			Else
				aTotais[02]	+= 0
			Endif
			aTotais[03]	+= 	RCA->TMP_QTDSAI
			aTotais[04]	+=	RCA->TMP_COL09
			aTotais[05]	+=	RCA->TMP_VAL10
			aTotais[06]	+=	RCA->TMP_VAL11
			aTotais[07]	+=	RCA->TMP_VAL12
			aTotais[08]	+=	RCA->TMP_VAL13
			aTotais[09]	+=	RCA->TMP_VAL14
			aTotais[10]	+=	RCA->TMP_COL15
			aTotais[11]	+=	RCA->TMP_COL16
			aTotais[12]	:=	nCol17Ant             //coluna 17 - quantidade
			aTotais[13]	:=	nCol19Ant             // coluna 19 - Base de St
			aTotais[14]	:=	nCol21Ant             // coluna 21 - Base OP
			aTotais[15]	:= RCA->TMP_ALIQS
			MsUnlock()
			
			if RCA->TMP_ALIQ ==12
				nColApur := 1
			elseif RCA->TMP_ALIQ ==18
				nColApur := 2
			elseif RCA->TMP_ALIQ ==25
				nColApur := 3
			else
				nColApur := 4
				nPos := Ascan(axAliq,{ |x| x[1] == RCA->TMP_ALIQ})
				If nPos == 0
					For nX := 1 to Len(aApurMod5)
						aAdd(aApurMod5[nX],0)
					Next
					aAdd(axAliq,{RCA->TMP_ALIQ,Len(aApurMod5[1])})
					nPos := Len(axAliq)
				Endif
				nColApur := axAliq[nPos,2]
			Endif
			aApurMod5[01,nColApur]	+= 	nDtEstIni  			//Base de calculo da retencao do estoque inicial
			aApurMod5[01,05]		+=	nDtEstIni
			aApurMod5[02,nColApur]	+= 	RCA->TMP_VAPU02  	//Base de calculo da retencao das entradas, exceto devolucoes ou retornos
			aApurMod5[02,05]		+=	RCA->TMP_VAPU02
			aApurMod5[03,nColApur]	+=	RCA->TMP_VAPU03  	//Base de calculo da retencao sobre mercadorias recebidas de outros estados
			aApurMod5[03,05]		+=	RCA->TMP_VAPU03
			aApurMod5[04,nColApur]	+= 	RCA->TMP_VAPU04  	//Base de calculo da retencao das devolucoes de mercadorias recebidas
			aApurMod5[04,05]		+=	RCA->TMP_VAPU04
			aApurMod5[05,nColApur]	+=	RCA->TMP_VAL11  	//Base de calculo da retencao das baixas de estoque pela nao ocorrencia do fato gerador nao realizado
			aApurMod5[05,05]		+= 	RCA->TMP_VAL11
			aApurMod5[06,nColApur]	:=  noround(nCol19Ant/nCol17Ant,9)//Base de calculo da retencao do estoque final
			aApurMod5[06,05]		:=	noround(nCol19Ant/nCol17Ant,9)
			aApurMod5[08,nColApur]	+= 	RCA->TMP_VAPU08  	//Base de calculo da retencao de mercadoria saida nao destinada a consumidor ou usuario final
			aApurMod5[08,05]		+=	RCA->TMP_VAPU08		
			aApurMod5[10,nColApur]	+=	RCA->TMP_VAPU10  	//Base de calculo efetiva bruta de mercadorias saidas destinadas a consumidor final
			aApurMod5[10,05]		+=	RCA->TMP_VAPU10
			aApurMod5[11,nColApur]	+=	RCA->TMP_VAPU11 	//Base de calculo efetiva das devolucoes ou retornos de vendas ou outras operacoes
			aApurMod5[11,05]		+=	RCA->TMP_VAPU11		
			nDtEstIni := 0

			IncProc()

			RCA->( dbSkip())
			MsUnlock()
		EndDo
		
		For i := 1 to Len(aApurMod5[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A coluna 4 nao deve ser somada pois sera utilizada para totalizar todas as aliquotas³
			//³diferentes de 12, 18 e 25                                                           ³
			//³A coluna 5 nao deve ser somada pois apresenta o total do relatorio                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If i <> 4  .And. i <> 5
				aApurMod5[07,i]	:=	aApurMod5[01,i]+aApurMod5[02,i]+aApurMod5[03,i]-aApurMod5[04,i]-aApurMod5[05,i]-aApurMod5[06,i]
				aApurMod5[09,i]	:=	aApurMod5[07,i]-aApurMod5[08,i]
				aApurMod5[12,i]	:=	aApurMod5[10,i]-aApurMod5[11,i]
			Endif
		Next
		aApurMod5[07,05]:=	aApurMod5[01,05]+aApurMod5[02,05]+aApurMod5[03,05]-aApurMod5[04,05]-aApurMod5[05,05]-aApurMod5[06,05]
		aApurMod5[09,05]:=	aApurMod5[07,05]-aApurMod5[08,05]
		aApurMod5[12,05]:=	aApurMod5[10,05]-aApurMod5[11,05]
		aApurMod5[13,05]:= 0
		aApurMod5[14,05]:= 0
		aApurMod5[15,05]:= 0
		aApurMod5[16,05]:= 0
		
		For i := 1 to Len(aApurMod5[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A coluna 4 nao deve ser somada pois sera utilizada para totalizar todas as aliquotas³
			//³diferentes de 12, 18 e 25                                                           ³
			//³A coluna 5 nao deve ser somada pois apresenta o total do relatorio                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If i <> 4  .And. i <> 5
				if i==1
					nAliq := 12
				elseif i ==2
					nAliq := 18
				elseif i == 3
					nAliq := 25
				else
					nPos 	:= Ascan(axAliq,{ |x| x[2] == i})
					nAliq 	:= axAliq[nPos,1]
				Endif
				aApurMod5[13,i]		:=	if(aApurMod5[12,i]-aApurMod5[09,i]>=0,aApurMod5[12,i]-aApurMod5[09,i],0)
				aApurMod5[13,05]	+=	aApurMod5[13,i]
				aApurMod5[14,i]		:=	if(aApurMod5[09,i]-aApurMod5[12,i]>=0,aApurMod5[09,i]-aApurMod5[12,i],0)
				aApurMod5[14,05]	+=	aApurMod5[14,i]
				aApurMod5[15,i]		:=	aApurMod5[13,i]*(nALIQ/100)
				aApurMod5[15,05]	+=	aApurMod5[15,i]
				aApurMod5[16,i]		:=	aApurMod5[14,i]*(nALIQ/100)
				aApurMod5[16,05]    +=	aApurMod5[16,i]
			Endif
		Next
		aApurMod5[17,05]:= if(aApurMod5[15,05]-aApurMod5[16,05]>=0,aApurMod5[15,05]-aApurMod5[16,05],0)
		aApurMod5[18,05]:= if(aApurMod5[16,05]-aApurMod5[15,05]>=0,aApurMod5[16,05]-aApurMod5[15,05],0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena todos os valores das colunas das aliquotas diferentes de 12, 18 e 25 na posicao 4 dp array³
		//³que sera utilizada para a impressao do relatorio.                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aApurMod5)
			For nY := 6 to Len(aApurMod5[nX])
				aApurMod5[nX,4] := aApurMod5[nX,nY]
			Next
		Next             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Registro do proximo periodo, caso parametro ³
		//³MV_GERPRME estiver configurado com .T.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cInclProxM
			dbSetOrder()
			dbSelectArea("SFK")
			dPData := LastDay(dDtAp5Fim)+1
			If SFK->(dbSeek(xFilial("SFK")+substr(cChave,1,TamSX3("B1_COD")[1])+Dtos(dPData),.T.))
				RecLock( "SFK", .F.)
				SFK->FK_QTDE  	:= Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[12],nSldCol17)
				SFK->FK_BRICMS 	:= Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[13],nSldCol19)
				SFK->FK_BASEICM := Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[14],nSldCol21)
				If SFK->(FieldPos("FK_DTFIMST")) > 0
					SFK->FK_DTFIMST	:= RCA->TMP_DTFMST //Data Final de controle de ressarcimento do ICMS-ST na CAT17 
				EndIf
			Else
				RecLock( "SFK", .T.)
				SFK->FK_FILIAL	:= xFilial("SFK")
	   			SFK->FK_DATA 	:= dPData
				SFK->FK_PRODUTO	:= substr(cChave,1,TamSX3("B1_COD")[1])
				SFK->FK_AICMS 	:= Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[15],nSldColAliq)
				SFK->FK_QTDE  	:= Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[12],nSldCol17)
				SFK->FK_BRICMS 	:= Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[13],nSldCol19)
				SFK->FK_BASEICM := Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[14],nSldCol21)
				If SFK->(FieldPos("FK_DTFIMST")) > 0
					SFK->FK_DTFIMST	:= RCA->TMP_DTFMST //Data Final de controle de ressarcimento do ICMS-ST na CAT17 
				EndIf
   			 EndIf
			SFK->(MsUnlock())
		EndIf		            
		afill(aTotais,0)		


		IncProc()

	EndDo
//modelo 1
Else 
	afill(aTotais,0)
	Aeval(aApurMod1,{|x|aFill(x,0)})
	dbSelectArea("SD2")
	SD2->( DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	dbSelectArea("RCA")
	RCA->(dbSetOrder(1))

	ProcRegua(RCA->(RecCount()))


	dbGoTop()
	While RCA->(!eof())

		if alltrim(RCA->TMP_NFENTR)	!=	"TOTAIS"
			//RCA->(dbSkip())
			//MsUnlock()
			//loop
		
			aUnit 		:= {}
			cChave		:= RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO
			nSldCol17 	:= RCA->TMP_SLD17
			nSldCol19 	:= RCA->TMP_SLD19
			nSldCol21 	:= RCA->TMP_SLD21
			nSldColAliq := RCA->TMP_SLDALQ
			lMovSD1 :=  Iif(RCA->TMP_MOVD1 == "S", .T.,.F.)
			lMovSD2 :=  Iif(RCA->TMP_MOVD2 == "S", .T.,.F.)
			lMovSD3 :=  Iif(RCA->TMP_MOVD3 == "S", .T.,.F.)
			
			While RCA->(!eof()) .and. RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO == cChave
			 	
				If RCA->TMP_FLAG == "S"

					IncProc()
		
					RCA->(dbSkip())
					MsUnlock()
					Loop
				EndIf	
					
				If alltrim(RCA->TMP_NFENTR) == "SALDO"
					nCol17Ant	:= 	RCA->TMP_COL17
					nCol09Ant 	:= 	RCA->TMP_COL18
					nCol19Ant	:=	RCA->TMP_COL19
					nCol21Ant	:=	RCA->TMP_COL21
	
					RCA->(dbSkip())
					Loop
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valor da Base de Calculo da Retencao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				If ExistBlock("CAT17LOP") .And. !ExecBlock("CAT17LOP",.F.,.F.,{"RCA",nCol17Ant})

					IncProc()		

					RCA->(dbSkip())
					MsUnlock()
					loop
				EndIf
	
				// tratamento para devoluções de venda onde o objetivo é estornar a saída original, utilizando o mesmo valor unitário
				nCol16 		:= 0
				aUnit 		:= {}
				cChvTemp1 	:= ""
				cChvTemp2 	:= ""
				
				If RCA->TMP_TIPO $"BD" .And. !empty(RCA->TMP_NFENTR) .And. Alltrim(RCA->TMP_NFORI+RCA->TMP_SERORI)<>""
	
					nRecno := ("RCA")->(Recno())
					
					cChvTemp1 := RCA->TMP_MERCAD + RCA->TMP_CLIFOR + RCA->TMP_LOJA + RCA->TMP_NFORI + RCA->TMP_SERORI
					cChvTemp2 := RCA->TMP_NFORI + RCA->TMP_SERORI + RCA->TMP_CLIFOR + RCA->TMP_LOJA + RCA->TMP_MERCAD
					
					RCA->(dbSetOrder(2))
					RCA->(DbGoTop())
					If RCA->(dbSeek(cChvTemp1))
	
						aUnit	:= {RCA->TMP_COL09,(RCA->TMP_COL16/RCA->TMP_QTDSAI)}     //{valor unitário original, Valor de próprio unitário original}
						
					Else
						If 	lCampD2 .And.;
							SD2->( MsSeek(xFilial("SD2")+cChvTemp2 ))
							
							aUnit := {SD2->D2_09CAT17, (SD2->D2_16CAT17/SD2->D2_QUANT)}					//{valor unitário original, Valor de próprio unitário original}
						Else
							aUnit := {}
						EndIf
					EndIf
	
					RCA->(dbSetOrder(1))
					RCA->(dbGoTo(nRecno))
					
					nRecno 		:= 0
					cChvTemp1 	:= ""
					cChvTemp2	:= ""
					
					If Len(aUnit)==2 .And. aUnit[2]>0
						//nCol16 := aUnit[2]*RCA->TMP_QTDENT
						nCol16 := noround(((aUnit[2]/RCA->TMP_QTDENT) * RCA->TMP_QTDSAI),2)
					EndIf
					
				EndIf
	            
				Reclock("RCA",.F.)
				
				// trecho retirado, pois na devolução de compra não é necessário utilizar o valor unitário atual, mais sim
				// a diretamente a base de ST, pois é dessa forma que a compra influencia o relatório
	/*			If RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
					RCA->TMP_VTBST := noround(RCA->TMP_QTDSAI * nCol09Ant ,9)
				EndIf*/
				
				If RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFENTR)
					If Len(aUnit)==2 .And. aUnit[1]>0
						RCA->TMP_VTENTR := noround(RCA->TMP_QTDENT * aUnit[1] ,9)
					Else
						RCA->TMP_VTENTR := noround(RCA->TMP_QTDENT * nCol09Ant ,9)
					EndIf
				EndIf
	
				If !empty(RCA->TMP_NFENTR) .And. !nCol09Ant > 0 .And. RCA->TMP_VTENTR > 0
					nCol09Ant := RCA->TMP_VTENTR /RCA->TMP_QTDENT
				ElseIf !empty(RCA->TMP_NFENTR) .And. !nCol09Ant > 0 .And. RCA->TMP_VTBPR > 0
					nCol09Ant := RCA->TMP_VTBPR /RCA->TMP_QTDENT
				EndIf
	
				//Ajuste qdo temos lancamentos de transferencia de saldos.
				nCol09Ant 	-= RCA->TMP_BSTRAN
				RCA->TMP_COL09	:=	nCol09Ant
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando houver reducao de base, calculo primeiramente o valor da coluna 12, que sempre tera valor.								³
				//³Depois verifico qual a outra coluna que tera o valor tributado.																	³
				//³Apos os calculos, aplico a porcentagem de reducao aos valores das colunas. Se nao houver reducao, efetuo calculos normalmente.	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If RCA->TMP_REDBC <> 0
				
					nRedBC	:=	100 - RCA->TMP_REDBC			
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³COL12 Saida com isencao ou nao incidencia³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
	
	                    If Len(aUnit)==2 .And. aUnit[1]>0
	                    	RCA->TMP_VAL12	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
	                    Else
							RCA->TMP_VAL12	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
						EndIf
						
						
					ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
						RCA->TMP_VAL12	:= 0
					Else
						RCA->TMP_VAL12	:= noround(RCA->TMP_QTDSAI * nCol09Ant,9)
					Endif
					RCA->TMP_VAL12	:=	RCA->TMP_VAL12 * nRedBC/100
					
					Do Case
						
						Case RCA->TMP_COL10 == "S" .And. RCA->TMP_COL12 == "S"
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL10 Saida a consumidor ou usuario final³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
								If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
								Else
									RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
								EndIf
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL10	:= 0
							else
								RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							Endif
							
							RCA->TMP_VAL10	:= RCA->TMP_VAL10 * RCA->TMP_REDBC/100
						
						Case RCA->TMP_COL13 == "S" .And. RCA->TMP_COL12 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL13 Saida para outro estado³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																								
							If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
	
							    If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL13	:= noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
							    Else
								    RCA->TMP_VAL13	:= noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
							    EndIf
							    
							ElseIf RCA->TMP_TIPO $"BD"  .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL13	:=0				
							Else																
							    RCA->TMP_VAL13	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							EndIf
							
							RCA->TMP_VAL13	:= RCA->TMP_VAL13 * RCA->TMP_REDBC/100 
						
						Case RCA->TMP_COL14 == "S" .And. RCA->TMP_COL12 == "S"
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL14 Saida para comercializacao subsequente³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
								If Len(aUnit)==2 .And. aUnit[1]>0
							   		RCA->TMP_VAL14	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
								Else
									RCA->TMP_VAL14	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
								EndIf
								
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL14	:=0
							else
								RCA->TMP_VAL14	:=	noround(RCA->TMP_QTDSAI * nCol09Ant ,9)
							Endif
							
							RCA->TMP_VAL14	:= RCA->TMP_VAL14 * RCA->TMP_REDBC/100
					EndCase														
				Else				
					Do Case     
					
						Case RCA->TMP_COL10 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL10 Saida a consumidor ou usuario final³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							if RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
								If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
								Else
									RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
								EndIf
								
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL10	:= 0
							else
								RCA->TMP_VAL10	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							Endif
							
						Case RCA->TMP_COL11 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL11 Fato gerador nao realizado³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							if RCA->TMP_TIPO $"BD" .Or. !empty(RCA->TMP_NFENTR)
								If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL11	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
								Else
									RCA->TMP_VAL11	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
								EndIf
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL11	:=	0
							else
								RCA->TMP_VAL11	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							EndIf
							
						Case RCA->TMP_COL12 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL12 Saida com isencao ou nao incidencia³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							if RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
								If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL12	:=	noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
								Else
									RCA->TMP_VAL12	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
								EndIf
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL12	:= 0
							else
								RCA->TMP_VAL12	:= noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							endIf
							
						Case RCA->TMP_COL13 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL13 Saida para outro estado³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														
							If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
	
							    If Len(aUnit)==2 .And. aUnit[1]>0
									RCA->TMP_VAL13	:= noround(RCA->TMP_QTDENT * aUnit[1]*(-1),9)
							    Else
								    RCA->TMP_VAL13	:= noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
							    EndIf
							    
							ElseIf RCA->TMP_TIPO $"BD"  .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL13	:=0				
							Else																
							    RCA->TMP_VAL13	:=	noround(RCA->TMP_QTDSAI * nCol09Ant,9)
							EndIf
						
						Case RCA->TMP_COL14 == "S"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³COL14 Saida para comercializacao subsequente³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR)
								RCA->TMP_VAL14	:=	noround(RCA->TMP_QTDENT * nCol09Ant*(-1),9)
							ElseIf RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID)
								RCA->TMP_VAL14	:=0
							else
								RCA->TMP_VAL14	:=	noround(RCA->TMP_QTDSAI * nCol09Ant ,9)
							Endif
						
					EndCase
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄ¿
				//³ Saldos  ³      // calculo das Colunas 17,18,19
				//ÀÄÄÄÄÄÄÄÄÄÙ
				RCA->TMP_COL17	:=	(nCol17Ant+RCA->TMP_QTDENT)- RCA->TMP_QTDSAI
				RCA->TMP_COL19	:=	nCol19Ant+IIF((RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14)==0,RCA->TMP_VTENTR,0)-IIF((RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14)<>0,(RCA->TMP_VAL10+RCA->TMP_VAL11+RCA->TMP_VAL12+RCA->TMP_VAL13+RCA->TMP_VAL14),IIF( RCA->TMP_TIPO $"BD" .And. !Empty(RCA->TMP_NFSAID),IIF(nCol19Ant > RCA->TMP_VTBST ,  RCA->TMP_VTBST,  nCol19Ant ),0))
				RCA->TMP_COL18	:=	noround(RCA->TMP_COL19/RCA->TMP_COL17,9)// Valor unitario da base de calculo da retencao
	
				If RCA->TMP_TIPO $"BD" .and. !empty(RCA->TMP_NFENTR) //Devolucao de Compras (SD1)
					nValor21 	:= noround(nCol21Ant,9)          
				ElseIf RCA->TMP_TIPO $"BD".And.!Empty(RCA->TMP_NFSAID)  // Devolucao de Venda (SD2)
					nValor21 	:= noround(nCol21Ant+(RCA->TMP_VTBPR*(-1)),9)
				Else
					nBasePr := IIF(RCA->TMP_VTBPR==0, RCA->TMP_VLMERC, RCA->TMP_VTBPR)
					nValor21 	:= noround(nCol21Ant+Iif(!Empty(RCA->TMP_NFENTR), nBasePr,0),9) //Agrega o valor da base de operacao propria nas movimentacoes de entrada
				EndIF
				
				nValor20	:= nValor21/Iif(nCol17Ant==0,1,nCol17Ant) // Valor unitario da base de calculo da operacao propria
				
				If (RCA->TMP_COL13 == "S" .And. !(RCA->TMP_COL14 == "S")) .Or. (!RCA->TMP_COL11 == "S" .And. !RCA->TMP_COL14 == "S") .And.!(RCA->TMP_COL10 == "S") //.And. !(RCA->TMP_COL12 == "S")
					If	RCA->TMP_TIPO $"BD"  .And. RCA->TMP_QTDENT>0
						If (RCA->TMP_VAL10 + RCA->TMP_VAL11 + RCA->TMP_VAL12 + RCA->TMP_VAL13 + RCA->TMP_VAL14) == 0
							RCA->TMP_COL16	:= 0
						Else
							If nCol16 <> 0 .And. RCA->TMP_TIPO $"BD"
								RCA->TMP_COL16	:= (nCol16*(-1))
						    Else
						    	//RCA->TMP_COL16	:=noround((nValor20 * RCA->TMP_QTDENT *(-1)),2)   // BC efetiva da entrada nas demais hipoteses
						    	RCA->TMP_COL16	:= noround((((nValor20 /RCA->TMP_QTDENT) * RCA->TMP_QTDSAI)*(-1)),2)
						    EndIf 																						
						EndIf
					Elseif RCA->TMP_TIPO $"BD" .And.!Empty(RCA->TMP_NFSAID)
						RCA->TMP_COL16	:=0
					Else
						If (RCA->TMP_VAL10 + RCA->TMP_VAL11 + RCA->TMP_VAL12 + RCA->TMP_VAL13 + RCA->TMP_VAL14) == 0
					   		RCA->TMP_COL16	:=0   // BC efetiva da entrada nas demais hipoteses
					    ElseIf	RCA->TMP_QTDSAI > 0			    					    					    	
							RCA->TMP_COL16	:=noround((nValor20 * RCA->TMP_QTDSAI),2) // BC efetiva da entrada nas demais hipoteses
					    Endif	
					EndIf
				Else
					If RCA->TMP_COL11 == "S" .And. !RCA->TMP_COL14 == "S" 
						If RCA->TMP_TIPO $"BD" .And.!Empty(RCA->TMP_NFSAID)
					   		RCA->TMP_COL16	:=0
				
						else 
							If(RCA->TMP_VAL10 + RCA->TMP_VAL11 + RCA->TMP_VAL12 + RCA->TMP_VAL13 + RCA->TMP_VAL14) == 0
					   	   		RCA->TMP_COL16	:=0   // BC efetiva da entrada nas demais hipoteses 
					  		Elseif RCA->TMP_TIPO $"BD" .Or. !empty(RCA->TMP_NFENTR)
								//RCA->TMP_COL16	:=	noround(nValor20 * RCA->TMP_QTDENT*(-1),2)
								RCA->TMP_COL16	:=	noround((((nValor20 /RCA->TMP_QTDENT) * RCA->TMP_QTDSAI)*(-1)),2) 
					    	else
					    		RCA->TMP_COL16	:=noround((nValor20 * RCA->TMP_QTDSAI),2)
					    	Endif
					    Endif	
					EndIf
				EndIf
				
				nCol09Ant	:= RCA->TMP_COL18
				nCol17Ant	:= RCA->TMP_COL17
				nCol19Ant	:= RCA->TMP_COL19
				
				//Processo pela CDM
				If nCDM == 1
					If (RCA->TMP_COL13 == "S" .And. !(RCA->TMP_COL14 == "S")) .Or. (!RCA->TMP_COL11 == "S" .And. !RCA->TMP_COL14 == "S") .And.!(RCA->TMP_COL10 == "S")
						If RCA->TMP_BASMAN>0
							RCA->TMP_COL16:= RCA->TMP_VAL13
						ElseIf RCA->TMP_QTDSAI > 0  .And. RCA->TMP_QTDENT > 0
							//RCA->TMP_COL16:= noround(((nvalor21/RCA->TMP_COL17) * RCA->TMP_QTDSAI),2)
							RCA->TMP_COL16:= noround(((nvalor21/RCA->TMP_QTDENT) * RCA->TMP_QTDSAI),2)
						EndIf
						
						nCol21Ant	:=	nValor21 - RCA->TMP_COL16
					Else
						If RCA->TMP_COL11 == "S" .And. !RCA->TMP_COL14 == "S"
							If RCA->TMP_BASMAN>0
						   		RCA->TMP_COL16:= RCA->TMP_VAL13
							Else
						   		//RCA->TMP_COL16:= noround(((nvalor21/  RCA->TMP_COL17) * RCA->TMP_QTDSAI),2)
						   		RCA->TMP_COL16:= noround(((nvalor21/  RCA->TMP_QTDENT) * RCA->TMP_QTDSAI),2)
							EndIf
						EndIf
					   		nCol21Ant	:=	nValor21 - RCA->TMP_COL16
					EndIf
				Else
					If lBaseSaida
						If	RCA->TMP_TIPO $"BD"  .And. RCA->TMP_QTDENT>0
							nCol21Ant	:=	nValor21 - noround((nValor20 * RCA->TMP_QTDENT *(-1)),2)
						Elseif RCA->TMP_TIPO $"BD" .And.!Empty(RCA->TMP_NFSAID)
							nCol21Ant	:=	nValor21
						Else
							nCol21Ant	:=	nValor21 -  noround((nValor20 * RCA->TMP_QTDSAI),2)
						Endif
					Else
						nCol21Ant	:=	nValor21 - RCA->TMP_COL16
					EndIf
				EndIf
				
				RCA->TMP_COL21	:= nCol21Ant
				
				
				aTotais[01]	+= 	RCA->TMP_QTDENT
				If!RCA->TMP_TIPO$ "BD"
					aTotais[02]	+=	RCA->TMP_VTENTR
				ElseIf(RCA->TMP_TIPO $"BD".And.!Empty(RCA->TMP_NFSAID))
					aTotais[02]	+= RCA->TMP_VTBST*(-1)
				Else
					aTotais[02]	+= 0
				Endif
				
				aTotais[03]	+= 	RCA->TMP_QTDSAI
				aTotais[04]	+=	RCA->TMP_COL09
				aTotais[05]	+=	RCA->TMP_VAL10
				aTotais[06]	+=	RCA->TMP_VAL11
				aTotais[07]	+=	RCA->TMP_VAL12
				aTotais[08]	+=	RCA->TMP_VAL13
				aTotais[09]	+=	RCA->TMP_VAL14
				aTotais[10]	+=	RCA->TMP_COL15
				aTotais[11]	+=	RCA->TMP_COL16
				aTotais[12]	:=	nCol17Ant             //coluna 17 - quantidade
				aTotais[13]	:=	nCol19Ant             // coluna 19 - Base de St
				aTotais[14]	:=	nCol21Ant             // coluna 21 - Base OP
				aTotais[15]	:= RCA->TMP_ALIQS
	
				RCA->( MsUnlock() )
				
				if RCA->TMP_ALIQ ==12
					nColApur := 1
				elseif RCA->TMP_ALIQ ==18
					nColApur := 2
				elseif RCA->TMP_ALIQ ==25
					nColApur := 3
				else
					nColApur := 4
					nPos := Ascan(axAliq,{ |x| x[1] == RCA->TMP_ALIQ})
					If nPos == 0
						For nX := 1 to Len(aApurMod1)
							aAdd(aApurMod1[nX],0)
						Next
						aAdd(axAliq,{RCA->TMP_ALIQ,Len(aApurMod1[1])})
						nPos := Len(axAliq)
					Endif
					nColApur := axAliq[nPos,2]
				Endif
				
				aApurMod1[01,nColApur]	+= 	RCA->TMP_VAL10  //Base de calculo da retencao nas saidas a consumidor final
				aApurMod1[01,05]		+=	RCA->TMP_VAL10
				aApurMod1[02,nColApur]	+=	RCA->TMP_VAL11  //Base de calculo da retencao nas baixas de estoque/fato gerador nao realizado
				aApurMod1[02,05]		+= 	RCA->TMP_VAL11
				aApurMod1[03,nColApur]	+=	RCA->TMP_VAL12  //Base de calculo nas saidas com isencao
				aApurMod1[03,05]		+=	RCA->TMP_VAL12
				aApurMod1[04,nColApur]	+=	RCA->TMP_VAL13  //Base de calculo nas saidas para outro estado
				aApurMod1[04,05]		+=	RCA->TMP_VAL13
				aApurMod1[06,nColApur]	+=	RCA->TMP_COL15  //Base de calculo efetiva nas saidas destinadas a consumidor final
				aApurMod1[06,05]		+=	RCA->TMP_COL15
				aApurMod1[07,nColApur]	+=	RCA->TMP_COL16  //Base de calculo efetiva nas demais hipoteses
				aApurMod1[07,05]		+=	RCA->TMP_COL16
	
				If lCampD2 .And. !Empty(RCA->TMP_NFSAID) .And. !(RCA->TMP_TIPO$"BD")
					If SD2->( MsSeek(xFilial("SD2")+RCA->TMP_NUMDOC+RCA->TMP_SERIE+RCA->TMP_CLIFOR+RCA->TMP_LOJA+RCA->TMP_MERCAD ))
						RECLOCK("SD2",.F.)
				   		SD2->D2_16CAT17 := RCA->TMP_COL16
				   		SD2->D2_09CAT17 := RCA->TMP_COL09
				   		SD2->( MsUnlock() )
				   	EndIf
				EndIf


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
				//³parte da rotina para gravar "n" registros e gerar a exibição³
				//³ do código do produto + descricao + marca + outros...       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
				cDescProd  	:= 	Posicione("SB1",1,xFilial("SB1")+RCA->TMP_MERCAD,"B1_DESC")

				cCodMult	:= 	Posicione("SB1",1,xFilial("SB1")+RCA->TMP_MERCAD,"B1_P_MULTB")				
				cDescMarca	:= 	Posicione("ZX4",1,xFilial("ZX4")+cCodMult,"ZX4_NOME")

				nPosMov		:= 	aScan(aMovimentos,{|x| Alltrim(x[1]) == Alltrim(RCA->TMP_MERCAD) })
                
				/* NORBERTO >>>>>>>>>>
				If nPosMov == 0
					aAdd(aMovimentos,{ 	RCA->TMP_MERCAD ,;                                             //1
										cDescProd		,;                                             //2
										cDescMarca		,;                                             //3
										Alltrim(Transform(RCA->TMP_VAL10,"@E 99,999,999,999.99")) ,;   //4
										Alltrim(Transform(RCA->TMP_VAL11,"@E 99,999,999,999.99")) ,;   //5
										Alltrim(Transform(RCA->TMP_VAL12,"@E 99,999,999,999.99")) ,;   //6
										Alltrim(Transform(RCA->TMP_VAL13,"@E 99,999,999,999.99")) ,;   //7
										Alltrim(Transform(RCA->TMP_COL15,"@E 99,999,999,999.99")) ,;   //8
										Alltrim(Transform(RCA->TMP_COL16,"@E 99,999,999,999.99")) })   //9
				Else
				                        
										aMovimentos[nPosMov][4]	:=	Alltrim(Transform(    Val( 	aMovimentos[nPosMov][4] ) + RCA->TMP_VAL10  ,"@E 99,999,999,999.99") )
										aMovimentos[nPosMov][5]	:= 	Alltrim(Transform(    Val( 	aMovimentos[nPosMov][5] ) +	RCA->TMP_VAL11  ,"@E 99,999,999,999.99") )                           
										aMovimentos[nPosMov][6]	:= 	Alltrim(Transform(    Val(  aMovimentos[nPosMov][6] ) +	RCA->TMP_VAL12  ,"@E 99,999,999,999.99") )   
										aMovimentos[nPosMov][7]	:= 	Alltrim(Transform(    Val(  aMovimentos[nPosMov][7] ) +	RCA->TMP_VAL13 	,"@E 99,999,999,999.99") )  
										aMovimentos[nPosMov][8]	:=  Alltrim(Transform(    Val(  aMovimentos[nPosMov][8] ) +	RCA->TMP_COL15	,"@E 99,999,999,999.99") ) 
										aMovimentos[nPosMov][9]	:=  Alltrim(Transform(    Val(  aMovimentos[nPosMov][9] ) + RCA->TMP_COL16	,"@E 99,999,999,999.99") ) 
				EndIf								
				*/
				nValCol4	:= (RCA->TMP_VAL10 + RCA->TMP_VAL11 + RCA->TMP_VAL12 + RCA->TMP_VAL13)
				nValCol5	:= (RCA->TMP_COL15 + RCA->TMP_COL16)
				nValCol6	:= If(nValCol4 <= nValCol5, nValCol5 - nValCol4, 0)
				nValCol7	:= If(nValCol4 >= nValCol5, nValCol4 - nValCol5, 0)
				nValCol8	:= 0
				nValCol9	:= (RCA->TMP_VAL13 + RCA->TMP_VAL10 - RCA->TMP_COL16) * (RCA->TMP_ALIQ / 100)
				
				If nPosMov == 0
					aAdd(aMovimentos,{ 	RCA->TMP_MERCAD ,;   //1
										cDescProd		,;   //2
										cDescMarca		,;   //3
										nValCol4        ,;   //4
										nValCol5        ,;   //5
										nValCol6        ,;   //6
										nValCol7        ,;   //7
										nValCol8        ,;   //8
										nValCol9        })   //9
				Else
										aMovimentos[nPosMov][4]	+=	nValCol4
										aMovimentos[nPosMov][5]	+= 	nValCol5
										aMovimentos[nPosMov][6]	+= 	nValCol6
										aMovimentos[nPosMov][7]	+= 	nValCol7
										aMovimentos[nPosMov][8]	+=  nValCol8
										aMovimentos[nPosMov][9]	+=  nValCol9
				EndIf								
				
				IncProc()		

				RCA->(dbSkip())
	
			EndDo
			
			For i := 1 to Len(aApurMod1[1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A coluna 4 nao deve ser somada pois sera utilizada para totalizar todas as aliquotas³
				//³diferentes de 12, 18 e 25                                                           ³
				//³A coluna 5 nao deve ser somada pois apresenta o total do relatorio                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If i <> 4  .And. i <> 5
					aApurMod1[05,i]	:=	aApurMod1[01,i]+aApurMod1[02,i]+aApurMod1[03,i]+aApurMod1[04,i]
					aApurMod1[08,i]	:=	aApurMod1[06,i]+aApurMod1[07,i]
				Endif
			Next
			
			aApurMod1[05,05]:=	aApurMod1[01,05]+aApurMod1[02,05]+aApurMod1[03,05]+aApurMod1[04,05]
			aApurMod1[08,05]:=	aApurMod1[06,05]+aApurMod1[07,05]
			aApurMod1[09,05]:= 0
			aApurMod1[10,05]:= 0
			aApurMod1[11,05]:= 0
			
			aApurMod1[12,05]:= 0
			
			For i := 1 to Len(aApurMod1[1])
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A coluna 4 nao deve ser somada pois sera utilizada para totalizar todas as aliquotas³
				//³diferentes de 12, 18 e 25                                                           ³
				//³A coluna 5 nao deve ser somada pois apresenta o total do relatorio                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If i <> 4  .And. i <> 5
					if i==1
						nAliq := 12
					elseif i ==2
						nAliq := 18
					elseif i == 3
						nAliq := 25
					else
						nPos 	:= Ascan(axAliq,{ |x| x[2] == i})
						nAliq 	:= axAliq[nPos,1]
					Endif
					
					aApurMod1[09,i]		:=	if(aApurMod1[08,i]-aApurMod1[05,i]>=0,aApurMod1[08,i]-aApurMod1[05,i],0)
					aApurMod1[09,05]	+=	aApurMod1[09,i]
					aApurMod1[10,i]		:=	if(aApurMod1[05,i]-aApurMod1[08,i]>=0,aApurMod1[05,i]-aApurMod1[08,i],0)
					aApurMod1[10,05]	+=	aApurMod1[10,i]
					aApurMod1[11,i]		:=	aApurMod1[09,i]*(nALIQ/100)
					aApurMod1[11,05]	+=	aApurMod1[11,i]
					aApurMod1[12,i]		:=	aApurMod1[10,i]*(nALIQ/100)
					aApurMod1[12,05]    +=	aApurMod1[12,i]
				Endif
			Next
			
			aApurMod1[13,05]:= if(aApurMod1[11,05]-aApurMod1[12,05]>=0,aApurMod1[11,05]-aApurMod1[12,05],0)
			aApurMod1[14,05]:= if(aApurMod1[12,05]-aApurMod1[11,05]>=0,aApurMod1[12,05]-aApurMod1[11,05],0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena todos os valores das colunas das aliquotas diferentes de 12, 18 e 25 na posicao 4 dp array³
			//³que sera utilizada para a impressao do relatorio.                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(aApurMod1)
				For nY := 6 to Len(aApurMod1[nX])
					aApurMod1[nX,4] := aApurMod1[nX,nY]
				Next
			Next
			
			RecLock( "RCA", .T.)
			RCA->TMP_MERCAD	:= substr(cChave,1,TamSX3("B1_COD")[1])	  //mercadoria
			RCA->TMP_MES		:=	substr(cChave,TamSX3("B1_COD")[1]+1,2)
			RCA->TMP_ANO		:=	substr(cChave,TamSX3("B1_COD")[1]+3,4)
			RCA->TMP_ALIQ		:=	99.99
			RCA->TMP_DATA		:= UltimoDia(ctod("01/"+substr(cChave,TamSX3("B1_COD")[1]+1,2)+"/"+substr(cChave,TamSX3("B1_COD")[1]+3,4)))
			RCA->TMP_NUMSEQ	:=	Replicate("Z",6)
			RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
			RCA->TMP_INSCR	:=	SM0->M0_INSC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Foi incluido o valor de "Z" no campo de numeracao da nota fiscal, pois quando      ³
			//³existia movimentacao no ultimo dia do mes o laco entrava em loop, pois existiam    ³
			//³duas linhas no arquivo temporario com o ultimo dia do mes (A primeira referente    ³
			//³ao movimento e a segunda referente ao totalizador), ao incluir "Z" o indice coloca ³
			//³o totalizador na ultima linha do arquivo temporario e gera corretamente o relatorio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RCA->TMP_NUMDOC     := Replicate("Z",TamSx3("F2_DOC")[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Coloca-se "TOTAIS" na NF de entrada para saber   ³
			//³que este registro refere-se ao saldo FINAL       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RCA->TMP_NFENTR	:=	"TOTAIS"
			RCA->TMP_ENTSAI :=	"Z"
			RCA->TMP_QTDENT := 	aTotais[01]
			RCA->TMP_VTENTR	:=	aTotais[02]
			RCA->TMP_QTDSAI	:=	aTotais[03]
			RCA->TMP_COL09	:= 	aTotais[04]
			RCA->TMP_VAL10	:=	aTotais[05]
			RCA->TMP_VAL11	:=	aTotais[06]
			RCA->TMP_VAL12	:=	aTotais[07]
			RCA->TMP_VAL13	:=	aTotais[08]
			RCA->TMP_VAL14	:=	aTotais[09]
			RCA->TMP_COL15	:=	aTotais[10]
			RCA->TMP_COL16	:=	aTotais[11]
			RCA->TMP_COL17	:=  Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[12],nSldCol17)
			RCA->TMP_COL19	:=  Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[13],nSldCol19)
			RCA->TMP_COL21	:=  Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[14],nSldCol21)
			RCA->TMP_ALIQS	:=  Iif(lMovSD1 .Or. lMovSD2 .Or. lMovSD3,aTotais[15],nSldColAliq)
			
			dbSelectArea("SFK")      //Data Final de controle de ressarcimento do ICMS-ST na CAT17
			SFK->(dbSetOrder(1))
			SFK->(dbGoTop())	   	
		   	If (DbSeek(xFilial("SFK")+RCA->TMP_MERCAD,.T.)) .AND. SFK->(FieldPos("FK_DTFIMST")) > 0
				RCA->TMP_DTFMST := SFK->FK_DTFIMST                                                  
			Else
				RCA->TMP_DTFMST := CToD("  /  /   ")
			Endif 
			SFK->(dbCloseArea())
			
			RCA->( MsUnlock() )
	
			dbSelectArea("RCA")
	
			afill(aTotais,0)
		Else

			IncProc()		

			RCA->(dbSkip())
		EndIf		
	EndDo
EndIf
Return
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction  ³U_xFsCatFimºAutor  ³                 º Data ³               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deleta os arquivos temporarios							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} xFsCatFim.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Deleta a tabela temporaria criada.   

*/                                                                       
User Function xFsCatFim(cArqTMP)
 
If File(cArqTMP+GetDBExtension())
	dbSelectArea("RCA")
	dbCloseArea()
	Ferase(cArqTMP+GetDBExtension())
	Ferase(cArqTMP+OrdBagExt())
Endif 

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CAT17PrdOrg³ Autor ³                      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para retornar o produto original atraves do campo    ³±±
±±³          ³D3_NUMSEQ                                                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CAT17PrdOrg                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Retorna													  ³±±
±±³ 		 |Produto original da tabela SD3                              ³±±
±±³ 		 |                                                            ³±±
±±³ 		 |                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} CAT17PrdOrg.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Funcao para retornar o produto original atraves do campo D3_NUMSEQ   
/*/                

Static Function CAT17PrdOrg(cDoc,nNumseq,cCf)  
Local cProd 	:= ""
Local aArea    	:= GetArea()
Local aAreaSD3 	:= SD3->(GetArea())
Local cChave	:= xFilial("SD3")+cDoc+nNumseq

Default cDoc	:= ""
Default nNumseq	:= ""
Default cCf		:= ""
            
If (cCf == "RE4")
	dbSelectArea ("SD3")
	dbSetOrder(8)
	If DbSeek(xFilial("SD3")+cDoc+nNumseq)  
		While SD3->(!Eof()) .And. cChave == xFilial("SD3")+cDoc+nNumseq
			If SD3->D3_CF == "DE4"
				cProd:= SD3->D3_COD
			Endif			
			SD3->(dbSkip())
			cChave	:= xFilial("SD3")+SD3->D3_DOC+SD3->D3_NUMSEQ
		Enddo	
	EndIf
Else
	dbSelectArea ("SD3")
	dbSetOrder(8)
	If DbSeek(xFilial("SD3")+cDoc+nNumseq)  
		While SD3->(!Eof()) .And. cChave == xFilial("SD3")+cDoc+nNumseq
			If SD3->D3_CF == "RE4"
				cProd:= SD3->D3_COD
			Endif			
			SD3->(dbSkip())
			cChave	:= xFilial("SD3")+SD3->D3_DOC+SD3->D3_NUMSEQ
		Enddo	
	EndIf
EndIf             

RestArea(aAreaSD3)
RestArea(aArea)

Return(cProd)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CAT17Rastro³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para retornar o rastro por lote e o sublote quando o ³±±
±±³          ³quando o produto possuir substituicao tributaria.           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CAT17Rastro                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Retorna													  ³±±
±±³ 		 |Lote da nota de entrada /saida                              ³±±
±±³ 		 |Produto da nota de entrada / saida                          ³±±
±±³ 		 |Documento da nota de entrada / saida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} CAT17Rastro.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Funcao para retornar o rastro por lote e o sublote quando o  quando o produto possuir substituicao tributaria.


/*/                
Static Function CAT17Rastro(cProduto,cLoteCtl,cEntSai)     
Local nBaseIcm 	:= 0
Local cSeek  	:= ""
Local cSeek1 	:= ""
Local aArea    	:= GetArea()
Local aAreaSB8 	:= SB8->(GetArea())
Local aAreaSD1 	:= SD1->(GetArea())
Local aAreaSD2 	:= SD2->(GetArea())

Default cProduto 	:= ""
Default cLoteCtl 	:= ""
Default cEntSai		:= ""

dbSelectArea("SB8")
dbSetOrder(5)
If DbSeek(xFilial("SB8")+cProduto+cLoteCtl)
	cSeek :=SB8->B8_DOC+SB8->B8_SERIE+SB8->B8_CLIFOR+SB8->B8_LOJA+cProduto
	cSeek1:=cProduto+SB8->B8_DOC+SB8->B8_SERIE+SB8->B8_CLIFOR+SB8->B8_LOJA
EndIf                                                                  

If cEntSai == "E"
	dbSelectArea("SD1")
	dbSetOrder(2)
	If MsSeek(xFilial("SD1")+cSeek1)
		If SD1->D1_BRICMS > 0
			nBaseIcm   := (SD1->D1_BRICMS / SB8->B8_QTDORI)
		Else
			nBaseIcm   := (SD1->D1_BASNDES / SB8->B8_QTDORI)
		EndIf
	EndIf
Else
	dbSelectArea("SD2")
	dbSetOrder(3)
	If MsSeek(xFilial("SD2")+cSeek)
		nBaseIcm   := (SD2->D2_BRICMS / SB8->B8_QTDORI) 
	EndIf
Endif

RestArea(aAreaSB8)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aArea)

Return(nBaseIcm)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FSCAT17VEIºAutor  ³                  º Data ³               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta temporario com os movimentos do controle de estoque  º±±
±±º          ³ para veiculos e motos novas com substituicao tributaria    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/* {Protheus.doc} xFSCATVEI.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Monta temporario com os movimentos do controle de estoque para veiculos e motos novas com substituicao tributaria 

*/

User Function xFSCATVEI(cArqTMP,dDtIni,dDtFim)
Local nPerICM	:= 0
Local nAliqInt	:= 0
Local MV_ESTICM := GetMv("MV_ESTICM")
Local MV_ESTADO := GetMv("MV_ESTADO")
Local cMvTpVei  := SuperGetMv("MV_TIPVEI",,"")
Local lGeraVei  := (!Empty(cMvTpVei) .And. AliasIndic("VV1") .And. VV1->(FieldPos("VV1_CHASSI")) > 0 .And. VV1->(FieldPos("VV1_ESTVEI")) > 0)
Local lConsFinal:= .F.
Local lRevenda  := .F.
Local lQuery    := .F.
Local cAliasSD1 := "SD1"
Local cAliasSD2 := "SD2"
Local cMes      := ""
Local cAno      := ""
Local cGrpTrib 	:= ""
Local 	cAliasSFK := "SFK"

#IFDEF TOP
	Local nX        := 0
	Local cQuery    := ""
	Local aStruSD1  := {}
	Local aStruSD2  := {}
#ENDIF

Default dDtIni := mv_par01
Default dDtFim := mv_par02

cMes := StrZero(month(dDtIni),2)
cAno := StrZero(Year(dDtFim),4)
nPerIcm := Val(Subs(MV_ESTICM,AT(MV_ESTADO,MV_ESTICM)+2,2))

// Para processamento eh necessario que exista a tabela VV1 - Veiculos
// e que o parametro "MV_TIPVEI" esteja preenchido com o tipo definido
// para veiculos.
If lGeraVei
	#IFDEF TOP
		lQuery := .T.
		cAliasSFK := "AliasSFK"
		aStruSFK  := SFK->(dbStruct())
		cQuery := "SELECT SFK.FK_FILIAL,SFK.FK_PRODUTO,SFK.FK_DATA,"
		cQuery += "SFK.FK_AICMS,SFK.FK_QTDE,SFK.FK_BRICMS,SFK.FK_BASEICM, VV1.VV1_CHASSI "
		cQuery += "FROM "+RetSqlName("SFK")+" SFK "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SFK.FK_PRODUTO AND SB1.B1_CODITE <> '' AND  SB1.B1_TIPO = '"+Alltrim(cMvTpVei)+"' AND SB1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = SB1.B1_CODITE AND VV1.VV1_ESTVEI = '0' AND VV1.D_E_L_E_T_=' ' "
		cQuery += "WHERE SFK.FK_FILIAL='"+xFilial("SFK")+"' AND "
		cQuery += "SFK.FK_DATA>='"+Dtos(dDtIni)+"' AND "
		cQuery += "SFK.FK_DATA<='"+Dtos(dDtFim)+"' AND "
		cQuery += "SFK.FK_PRODUTO>='"+MV_PAR03+"' AND "
		cQuery += "SFK.FK_PRODUTO<='"+MV_PAR04+"' AND "
		cQuery += "SFK.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY VV1.VV1_CHASSI, SFK.FK_DATA "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFK,.T.,.T.)
		
		For nX := 1 To Len(aStruSFK)
			If aStruSFK[nX][2] <> "C" .And. FieldPos(aStruSFK[nX][1])<>0
				TcSetField(cAliasSFK,aStruSFK[nX][1],aStruSFK[nX][2],aStruSFK[nX][3],aStruSFK[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSFK)
	#ELSE
		SFK->(dbSeek(xFilial("SFK")+Padr(MV_PAR03,TamSx3("FK_PRODUTO")[1])+dtos(dDtIni),.T.))
	#ENDIF
	cAliasSFK := "SFK"
	While (cAliasSFK)->(!Eof()) .and. (cAliasSFK)->FK_FILIAL == xFilial("SFK")	
		SB1->(dbSeek(xFilial("SB1")+(cAliasSFK)->FK_PRODUTO))	
		RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD	:=	(cAliasSFK)->VV1_CHASSI  
		RCA->TMP_PROD  	:=	(cAliasSFK)->FK_PRODUTO 
		RCA->TMP_MES	:=	cMes
		RCA->TMP_ANO	:=	cAno
		RCA->TMP_ALIQ	:=	if(!empty(SFK->FK_AICMS),(cAliasSFK)->FK_AICMS,nPerICM)
		RCA->TMP_DATA	:=	(cAliasSFK)->FK_DATA
		RCA->TMP_NUMSEQ	:=	replicate("0",6)
		RCA->TMP_CONTRI	:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR	:=	SM0->M0_INSC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Coloca-se "S" no tipo da nota fiscal para indicar³
		//³ que este registro refere-se a saldo inicial     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RCA->TMP_TIPO   := "S"
		RCA->TMP_DATENT := 	(cAliasSFK)->FK_DATA
		RCA->TMP_VAL05	:=	(cAliasSFK)->FK_BASEICM	 //Base de calculo propria
		RCA->TMP_VAL06	:=	(cAliasSFK)->FK_BRICMS	 //Base de calculo da retencao
		RCA->(MsUnlock())
		(cAliasSFK)->(dbSkip())
	EndDo	
	If lQuery
		dbSelectArea(cAliasSFK)
		dbCloseArea()
	EndIf	

	#IFDEF TOP
		lQuery := .T.
		cAliasSD1 := "AliasSD1"
		aStruSD1  := SD1->(dbStruct())
		cQuery := "SELECT SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_COD,SD1.D1_TOTAL,SD1.D1_BASNDES, "
		cQuery += "SD1.D1_NUMSEQ,SD1.D1_UM,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_QUANT,SD1.D1_BRICMS,SD1.D1_TIPO,SD1.D1_FORNECE, "
		cQuery += "SD1.D1_LOJA,SD1.D1_TES,SD1.D1_BASEICM,SD1.D1_PICM, SD1.D1_CF, VV1.VV1_CHASSI, SB1.B1_GRTRIB, SB1.B1_PICM "
		cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.B1_CODITE<>'' AND  SB1.B1_TIPO ='"+Alltrim(cMvTpVei)+"' AND SB1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.VV1_ESTVEI='0' AND VV1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_ESTOQUE='S' AND SF4.F4_PODER3='N' AND SF4.D_E_L_E_T_=' ' "
		cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery += "SD1.D1_DTDIGIT>='"+Dtos(dDtIni)+"' AND "
		cQuery += "SD1.D1_DTDIGIT<='"+Dtos(dDtFim)+"' AND "
		cQuery += "(SD1.D1_BRICMS>0 OR SD1.D1_BASNDES>0) AND "
		cQuery += "SD1.D1_COD>='"+MV_PAR03+"' AND "
		cQuery += "SD1.D1_COD<='"+MV_PAR04+"' AND "
		cQuery += "SD1.D_E_L_E_T_=' '  "
		cQuery += "ORDER BY VV1.VV1_CHASSI, SD1.D1_DTDIGIT, SD1.D1_NUMSEQ "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		
		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD1)
	#ELSE
		SD1->(dbSeek(xFilial("SD1")+dtos(dDtIni),.T.))
	#ENDIF
	
	While (cAliasSD1)->(!EOF()) .And. (cAliasSD1)->D1_FILIAL==xFilial("SD1") .And.;
		(cAliasSD1)->D1_DTDIGIT <= dDtFim
		
		nAliqInt	:= 0
		cGrpTrib 	:= ""
		lConsFinal  := .F.
		lRevenda    := .F.
		
		
		If !(cAliasSD1)->D1_TIPO $ "BD"
			SA2->(dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cGrpTrib 	:= SA2->A2_GRPTRIB
			lConsFinal	:= If( SA2->A2_TIPO=="F", .T.,.F.)
			lRevenda    := If( SA2->A2_TIPO=="J", .T.,.F.)
		else
			SA1->(dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			cGrpTrib 	:= SA1->A1_GRPTRIB
			lConsFinal	:= If( SA1->A1_TIPO=="F", .T.,.F.)
			lRevenda    := If( SA1->A1_TIPO=="R", .T.,.F.)
		EndIf
		
		//Verifica aliquota interna
		dbSelectArea("SF7")
		SF7->(dbSetOrder(1))
		If SF7->(dbSeek(xFilial("SF7")+ SB1->B1_GRTRIB +cGrpTrib))    //(cAliasSD1)->B1_GRTRIB 
			While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+  SB1->B1_GRTRIB +cGrpTrib  //(cAliasSD1)->B1_GRTRIB
				If (MV_ESTADO == SF7->F7_EST .Or. SF7->F7_EST == "**")
					nAliqInt	:= Iif(SF7->(FieldPos("F7_ALIQINT")) > 0,SF7->F7_ALIQINT,0)
					Exit
				Endif
				SF7->(dbSkip())
			EndDo
		EndIf
		
		RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD		:=  VV1->VV1_CHASSI    //(cAliasSD1)
		RCA->TMP_PROD      	:=	(cAliasSD1)->D1_COD  
		RCA->TMP_MES		:=	cMes
		RCA->TMP_ANO		:=	cAno
		RCA->TMP_ALIQ		:= if( !empty(SB1->B1_PICM),SB1->B1_PICM,nPerICM)
		RCA->TMP_NUMSEQ		:=	(cAliasSD1)->D1_NUMSEQ
		RCA->TMP_CONTRI		:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR		:=	SM0->M0_INSC
		RCA->TMP_FILIAL 	:= 	(cAliasSD1)->D1_FILIAL
		RCA->TMP_TIPO   	:=	(cAliasSD1)->D1_TIPO
		RCA->TMP_DATA		:=	(cAliasSD1)->D1_DTDIGIT
		RCA->TMP_DATENT    	:= 	(cAliasSD1)->D1_DTDIGIT
		RCA->TMP_NFENTR		:=	(cAliasSD1)->D1_DOC
		RCA->TMP_SERENT		:=	(cAliasSD1)->D1_SERIE
		RCA->TMP_BSNDES	    :=	(cAliasSD1)->D1_BASNDES
		
		//Devolucao de venda e Retorno
		If (cAliasSD1)->D1_TIPO $ "BD"
			SA1->(dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			lConsFinal	:= if( SA1->A1_TIPO=="F", .T.,.F.)
			lRevenda    := If( SA1->A1_TIPO=="R", .T.,.F.)
			
			If lRevenda
				RCA->TMP_VAL10		:=	(IIF((cAliasSD1)->D1_BRICMS>0,(cAliasSD1)->D1_BRICMS,(cAliasSD1)->D1_BASNDES) *(-1))	 //Base de calculo efetiva na Saida p/ comerc. subsequente
			ElseIf lConsFinal
				RCA->TMP_VAL11		:=	(IIF((cAliasSD1)->D1_BRICMS>0,(cAliasSD1)->D1_BRICMS,(cAliasSD1)->D1_BASNDES) *(-1))	 //Base de calculo efetiva na Saida a cons. usr final
			EndIf
		Else
			RCA->TMP_VAL05		:=	(cAliasSD1)->D1_BASEICM	 //Base de calculo propria
			RCA->TMP_VAL06		:=	IIF((cAliasSD1)->D1_BRICMS>0,(cAliasSD1)->D1_BRICMS,(cAliasSD1)->D1_BASNDES)	 //Base de calculo da retencao
		EndIf
		RCA->(MsUnlock())
		
		(cAliasSD1)->(dbSkip())
	EndDo
	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	EndIf
	
	#IFDEF TOP
		lQuery := .T.
		cAliasSD2 := "AliasSD2"
		aStruSD2  := SD2->(dbStruct())
		cQuery := "SELECT SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_COD,SD2.D2_CF,SD2.D2_TOTAL, "
		cQuery += "SD2.D2_NUMSEQ,SD2.D2_UM,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_QUANT,SD2.D2_BRICMS,SD2.D2_TIPO,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_TES, "
		cQuery += "SD2.D2_BASEICM,SD2.D2_PICM,SD2.D2_BRICMS, VV1.VV1_CHASSI, SB1.B1_GRTRIB, SB1.B1_PICM "
		cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_CODITE <> '' AND  SB1.B1_TIPO = '"+Alltrim(cMvTpVei)+"' AND SB1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = SB1.B1_CODITE AND VV1.VV1_ESTVEI = '0' AND VV1.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_ESTOQUE = 'S' AND SF4.F4_PODER3 = 'N' AND SF4.D_E_L_E_T_=' ' "
		cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
		cQuery += "SD2.D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
		cQuery += "SD2.D2_BRICMS>0 AND "           
		cQuery += "SD2.D2_COD>='"+MV_PAR03+"' AND "
		cQuery += "SD2.D2_COD<='"+MV_PAR04+"' AND "
		cQuery += "SD2.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY VV1_CHASSI, SD2.D2_EMISSAO, SD2.D2_NUMSEQ "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		
		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD2)
	#ELSE
		(cAliasSD2)->(dbSeek(xFilial("SD2")+dtos(dDtIni),.T.))
	#ENDIF
	
	While (cAliasSD2)->(!EOF()) .and. (cAliasSD2)->D2_FILIAL==xFilial("SD2") .and.;
		(cAliasSD2)->D2_EMISSAO <= dDtFim
		
		nAliqInt	:= 0
		cGrpTrib 	:= ""
		lConsFinal  := .F.
		lRevenda    := .F.
		
		//Verifica o tipo do cliente
		If !(cAliasSD2)->D2_TIPO $ "BD"
			SA1->(dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			cGrpTrib 	:= SA1->A1_GRPTRIB
			lConsFinal	:= If( SA1->A1_TIPO=="F", .T.,.F.)
			lRevenda    := If( SA1->A1_TIPO=="R", .T.,.F.)
		EndIf
		
		//Verifica aliquota interna
		dbSelectArea("SF7")
		SF7->(dbSetOrder(1))
		If SF7->(dbSeek(xFilial("SF7")+SB1->B1_GRTRIB  +cGrpTrib))  //(cAliasSD2)->B1_GRTRIB
			While !SF7->(Eof()) .And. SF7->F7_FILIAL+SF7->F7_GRTRIB+SF7->F7_GRPCLI == xFilial("SF7")+ SB1->B1_GRTRIB+cGrpTrib   //(cAliasSD2)->B1_GRTRIB
				If (MV_ESTADO == SF7->F7_EST .Or. SF7->F7_EST == "**")
					nAliqInt	:= Iif(SF7->(FieldPos("F7_ALIQINT")) > 0,SF7->F7_ALIQINT,0)
					Exit
				Endif
				SF7->(dbSkip())
			EndDo
		EndIf
		
		RECLOCK("RCA",.T.)
		RCA->TMP_MERCAD		:= (cAliasSD2)->VV1_CHASSI
		RCA->TMP_PROD      	:= (cAliasSD2)->D2_COD  
		RCA->TMP_MES		:=	cMes
		RCA->TMP_ANO		:=	cAno
		RCA->TMP_ALIQ		:= if( !empty((cAliasSD2)->B1_PICM),(cAliasSD2)->B1_PICM,nPerICM)
		RCA->TMP_NUMSEQ		:=	(cAliasSD2)->D2_NUMSEQ
		RCA->TMP_CONTRI		:=	SM0->M0_NOMECOM
		RCA->TMP_INSCR		:=	SM0->M0_INSC
		RCA->TMP_FILIAL 	:= 	(cAliasSD2)->D2_FILIAL
		RCA->TMP_TIPO   	:=	(cAliasSD2)->D2_TIPO
		RCA->TMP_DATA		:=	(cAliasSD2)->D2_EMISSAO
		RCA->TMP_DATSAI    	:= 	(cAliasSD2)->D2_EMISSAO
		RCA->TMP_NFSAID		:=	(cAliasSD2)->D2_DOC
		RCA->TMP_SERSAI		:=	(cAliasSD2)->D2_SERIE
		
		If lRevenda
			RCA->TMP_VAL10		:=	(cAliasSD2)->D2_BRICMS 	 //Base de calculo efetiva na Saida p/ comerc. subsequente
		ElseIf lConsFinal
			RCA->TMP_VAL11		:=	(cAliasSD2)->D2_BRICMS 	 //Base de calculo efetiva na Saida a cons. usr final
		EndIf
		
		//Devolucao de Compra e Retorno
		If (cAliasSD2)->D2_TIPO $ "BD"
			RCA->TMP_VAL05		:=	((cAliasSD2)->D2_BASEICM *(-1))	 //Base de calculo propria
			RCA->TMP_VAL06		:=	((cAliasSD2)->D2_BRICMS  *(-1))	 //Base de calculo da retencao
		EndIf
		RCA->(MsUnlock())
		(cAliasSD2)->(dbSkip())
	EndDo
	
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CAT17TTVEIºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta arquivo de trabalho de controle de estoque de       º±±
±±º          ³ veiculos                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 


/* {Protheus.doc} xCATVEI.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Ajusta arquivo de trabalho de controle de estoque de veiculos
*/   


User Function xCATVEI(cArqTMP,dDtIni,dDtFim)
Local cChave	:= ""
Local cArm      := ""       
Local cMerc     := ""
Local cProd     := ""       
Local nTCol05   := 0	
Local nTCol06 	:= 0
Local nTCol11 	:= 0
Local nTCol12 	:= 0    
Local ncol16    := 0
Local nQtd      := 0
Local nAliq     := 0
Local aSldEst   := {}
Local aTotais	:= 	array(17)

afill(aTotais,0)
dbSelectArea("RCA")
dbGoTop()
While RCA->(!eof())
	if alltrim(RCA->TMP_TIPO)==	"F"
		RCA->(dbSkip())
		loop
	ElseIf alltrim(RCA->TMP_TIPO)==	"E"
		RCA->(dbSkip())
		loop
	endIf

	cChave	:= RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO
	cMerc   := RCA->TMP_MERCAD
	cProd   := RCA->TMP_PROD
	nAliq   := RCA->TMP_ALIQ
	While RCA->(!eof()) .and. RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO == cChave
		if alltrim(RCA->TMP_TIPO)==	"F"
			RCA->(dbSkip())
			loop
		ElseIf alltrim(RCA->TMP_TIPO)==	"E"
			RCA->(dbSkip())
			loop
		endIf
		nTCol05 += RCA->TMP_VAL05
		nTCol06 += RCA->TMP_VAL06		
		nTCol11 += RCA->TMP_VAL11
		nTCol12 += RCA->TMP_VAL12
		RCA->( dbSkip())
		If RCA->(Eof()) .or. RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO <> cChave
			If SB1->(dbSeek(xFilial("SB1")+cProd))
				cArm    := SB1->B1_LOCPAD
				aSldEst := CalcEst(cProd, cArm, dDtFim)
				If len(aSldEst)>0
					nQtd := aSldEst[1]
				EndIf
			EndIf
			If nQtd > 0
				//Inclui registro final de estoque remanescente
				RCA->(Reclock("RCA",.T.))
				RCA->TMP_NUMSEQ	:= Replicate("9",6)
				RCA->TMP_CONTRI	:= SM0->M0_NOMECOM
				RCA->TMP_INSCR	:= SM0->M0_INSC				
				RCA->TMP_MERCAD	:= cMerc
				RCA->TMP_PROD	:= cProd			  
				RCA->TMP_MES   	:= Substr(cChave,TamSX3("VV1_CHASSI")[1]+1,2)
				RCA->TMP_ANO   	:= Substr(cChave,TamSX3("VV1_CHASSI")[1]+3,4)
				RCA->TMP_DATA  	:= UltimoDia(ctod("01/"+substr(cChave,TamSX3("VV1_CHASSI")[1]+1,2)+"/"+substr(cChave,TamSX3("VV1_CHASSI")[1]+3,4)))
				RCA->TMP_TIPO  	:= "E"    
				RCA->TMP_ALIQ   := nAliq
				RCA->TMP_VAL05 	:= nTCol05
				RCA->TMP_VAL13 	:= nTCol06
				RCA->(MsUnLock())				
			else
				//Inclui registro final quanto a complementacao/ ressarcimento do imposto
				RCA->(Reclock("RCA",.T.))
				RCA->TMP_NUMSEQ	:= Replicate("9",6)
				RCA->TMP_CONTRI	:= SM0->M0_NOMECOM
				RCA->TMP_INSCR	:= SM0->M0_INSC				
				RCA->TMP_MERCAD	:= cMerc             
				RCA->TMP_PROD	:= cProd			  
				RCA->TMP_MES   	:= Substr(cChave,TamSX3("VV1_CHASSI")[1]+1,2)
				RCA->TMP_ANO   	:= Substr(cChave,TamSX3("VV1_CHASSI")[1]+3,4)
				RCA->TMP_DATA  	:= UltimoDia(ctod("01/"+substr(cChave,TamSX3("VV1_CHASSI")[1]+1,2)+"/"+substr(cChave,TamSX3("VV1_CHASSI")[1]+3,4)))
				RCA->TMP_TIPO  	:= "F"                 
				RCA->TMP_VAL14 	:= Iif(((nTCol11+nTCol12)>nTCol06),((nTCol11+nTCol12)-nTCol06),0) 				
				RCA->TMP_VAL15 	:= Iif((nTCol06 >(nTCol11+nTCol12)),(nTCol06-(nTCol11+nTCol12)),0)
				ncol16 := (nTCol06 - nTCol05)
				RCA->TMP_VAL16 	:= Iif(RCA->TMP_VAL15 > ncol16, ncol16, RCA->TMP_VAL15)				
				//RCA->TMP_VAL17 	:= Iif((RCA->TMP_VAL15 - RCA->TMP_VAL16)>0,(RCA->TMP_VAL15 - RCA->TMP_VAL16),0)				  // ANALISAR 				
				RCA->(MsUnLock())								
			EndIf                                        
			cArm 	:= ""
			aSldEst	:= {}
			nQtd 	:= 0         
			nTCol05 := 0
			nTCol06 := 0
			nTCol11 := 0
			nTCol12 := 0
			ncol16	:= 0  
			cChave	:= RCA->TMP_MERCAD+RCA->TMP_MES+RCA->TMP_ANO
			cMerc   := RCA->TMP_MERCAD
			cProd   := RCA->TMP_PROD    
			nAliq   := RCA->TMP_ALIQ
		EndIf
	EndDo
	afill(aTotais,0) 
EndDo
Return()

