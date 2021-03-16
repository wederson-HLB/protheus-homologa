#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

/*
Funcao      : YYWS001 
Parametros  : Nenhum
Retorno     : RetInt
Objetivos   : Processar Integração Web Service de Nota de Saída/Entrada
Autor       : Renato Rezende
Cliente		: Todos
Data/Hora   : 02/05/2017
*/

//Log do Processo
WSSTRUCT ResultNfs
	WSDATA Numero		As String
	WSDATA Log    		As String 
ENDWSSTRUCT

//Condição de Pagamento tipo 9
WSSTRUCT aPag
	WSDATA VlParc				As Float			OPTIONAL				//C5_PARC*
	WSDATA DataParc        		As Date   			OPTIONAL				//C5_DATA*
ENDWSSTRUCT

WSSTRUCT HeaderNFS
	WSDATA NumPedido 	        As String  									//C5_NUM
	WSDATA NumControle			As String									//C5_P_REF
	WSDATA ChaveNFe				AS String									//C5_P_CHVNF
	WSDATA TipoPed	            As String  									//C5_TIPO
	WSDATA DataNFS				As Date    									//C5_EMISSAO
	WSDATA CliForCGC			As String 									//A1_CGC/A2_CGC
	WSDATA CliFor				As String 									//A1_COD/A2_COD
	WSDATA CliForLoja			As String 									//A1_LOJA/A2_LOJA
	WSDATA Transporadora        As String									//C5_TRANSP
	WSDATA CondPag			    As String			 						//C5_CONDPAG
	WSDATA MenNota				As String									//C5_MENNOTA
	WSDATA Natureza				As String			OPTIONAL				//C5_NATUREZ
	WSDATA PlanoDePagamento     As Array Of aPag	OPTIONAL				//C5_PARC*+C5_DATA*
	WSDATA Bol			 	    As String			OPTIONAL				//C5_P_BOL
ENDWSSTRUCT

WSSTRUCT ItemsNFS
	WSDATA NumItem         		As String  									//C6_ITEM
	WSDATA CodigoDoProd		    As String  									//C6_PRODUTO
	WSDATA LocalProd			As String									//C6_LOCAL
	WSDATA DescrDoProduto   	As String  									//C6_DESCRI
	WSDATA QtdDoProduto			As Float   									//C6_QTDVEN
	WSDATA ValorUnitario        As Float   									//C6_PRCVEN
	WSDATA ValorTotal           As Float   								 	//C6_VALOR
	WSDATA Tes					AS String									//C6_TES
	WSDATA Cfop					AS String									//C6_CF
	WSDATA NotaOri				AS String			OPTIONAL				//C6_NFORI
	WSDATA SerieOri				AS String			OPTIONAL				//C6_SERIORI
	WSDATA ItemNfOri			AS String			OPTIONAL				//C6_ITEMORI
ENDWSSTRUCT

WSSTRUCT HeaderNFE
	WSDATA TipoNf 				As String									//F1_TIPO
	WSDATA FormProp 			As String									//F1_FORMUL
	WSDATA NumDoc 				As String									//F1_DOC
	WSDATA NumSerie 			As String									//F1_SERIE
	WSDATA DataNFE 				As Date										//F1_EMISSAO
	WSDATA DataDigit			As Date										//F1_DTDIGIT
	WSDATA CliForCGC			As String 									//A1_CGC/A2_CGC
	WSDATA CliFor				As String 									//A1_COD/A2_COD
	WSDATA CliForLoja			As String 									//A1_LOJA/A2_LOJA
	WSDATA EspecieNFE 			As String									//F1_ESPECIE
	WSDATA CondPag 				As String									//F1_COND
	WSDATA Natureza				As String									//E2_NATUREZ
	WSDATA ChaveNFe				AS String									//F1_CHVNFE
	WSDATA IdProcesso			AS Float			OPTIONAL				//F1_P_IDPRO - Customizado Solaris
ENDWSSTRUCT 

WSSTRUCT ItemsNFE
	WSDATA NumItem         		As String  									//D1_ITEM
	WSDATA CodigoDoProd 		As String									//D1_COD 
	WSDATA LocalProd			As String									//D1_LOCAL		
	WSDATA QtdDoProduto 		As Float									//D1_QUANT
	WSDATA ValorUnitario 		As Float									//D1_VUNIT
	WSDATA ValorTotal 			As Float									//D1_TOTAL
	WSDATA Tes 					As String									//D1_TES
	WSDATA Cfop					AS String									//D1_CF
	WSDATA NotaOri				AS String			OPTIONAL				//D1_NFORI
	WSDATA SerieOri				AS String			OPTIONAL				//D1_SERIORI
	WSDATA ItemNfOri			AS String			OPTIONAL				//D1_ITEMORI
	WSDATA TipoTrans			AS String			OPTIONAL				//D1_P_TPTRA - Customizado Solaris
ENDWSSTRUCT

//Saida
WSSTRUCT tNFS
	WSDATA NFSHeader   AS HeaderNFS
	WSDATA NFSItem     AS Array Of ItemsNFS
ENDWSSTRUCT

//Entrada
WSSTRUCT uNFE
	WSDATA NFEHeader   AS HeaderNFE
	WSDATA NFEItem     AS Array Of ItemsNFE
ENDWSSTRUCT

WSSERVICE YYWS001 Description "WS Protheus Integração NF Saída/Entrada" 
	WSDATA oNFS		As tNFS
	WSDATA oNFE		As uNFE
	WSDATA NumCNPJ	As String
	//Retorno Log da Inclusao Clientes
	WSDATA RetInt   As Array of ResultNfs
	//Metodos
	WSMETHOD InsereNfSaida Description "WS Protheus gravará NF Saída"
	WSMETHOD InsereNfEntrada Description "WS Protheus gravará NF Entrada"
ENDWSSERVICE

/*
Método.......: InsereNfSaida
Objetivo.....: Insere NF Saída Protheus
Autor........: Renato Rezende
Data.........: 02/05/2017
*/
*----------------------------------------------------------------------------------*
 WSMETHOD InsereNfSaida WSRECEIVE oNFS,NumCNPJ WSSEND RetInt WSSERVICE YYWS001
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.
Local lCGC			:= .F.

Local cPedNum		:= Right(::oNFS:NFSHeader:NumPedido , Len(SC5->C5_NUM) )
Local cPedRef		:= Alltrim(PadR(::oNFS:NFSHeader:NumControle , Len(SC5->C5_P_REF) ))
Local cCGC			:= Alltrim(PadR(::oNFS:NFSHeader:CliForCGC , Len(SA1->A1_CGC) ))
Local cCodCli		:= PadR(::oNFS:NFSHeader:CliFor , Len(SA1->A1_COD) )
Local cLoja			:= PadR(::oNFS:NFSHeader:CliForLoja , Len(SA1->A1_LOJA) )
Local cArqLog		:= ""
Local cChave		:= ""
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ
Local cSequen		:= "0"

Local aLog			:= {}
Local aCabec		:= {}
Local aItens		:= {}
Local aItem			:= {}
Local aEmp			:= {}

Local nR			:= 0
Local nE			:= 0

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Validando Código do Cliente/Fornecedor
If !Empty(cCGC)
	cChave	:= cPedNum+cPedRef+cCGC
	lCGC	:= .T.
Else
	cChave := cPedNum+cPedRef+cCodCli+cLoja
EndIf

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SC5",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

//Monta o cabecalho do Pedido de Vendas
AADD(aCabec, {"C5_NUM"   	 , cPedNum						 							,Nil}) // Numero do pedido
AADD(aCabec, {"C5_TIPO"		 , PadR(::oNFS:NFSHeader:TipoPed, Len(SC5->C5_TIPO))		,Nil}) // Tipo de pedido
AADD(aCabec, {"C5_P_REF"	 , PadR(Alltrim(cPedRef), Len(SC5->C5_P_REF))				,Nil}) // Numero de controle
If lCGC
	AADD(aCabec, {"CNPJ"		 , Alltrim(cCGC)										,Nil}) // Cgc do cliente / Fornecedor
	AADD(aCabec, {"LOJACNPJ"	 , ""													,Nil}) // Loja do cliente / Fornecedor
Else
	AADD(aCabec, {"C5_CLIENTE"	 , cCodCli 												,Nil}) // Cod do cliente / Fornecedor
	AADD(aCabec, {"C5_LOJACLI"	 , cLoja   												,Nil}) // Loja do cliente / Fornecedor
EndIf
AADD(aCabec, {"C5_EMISSAO"	 , ::oNFS:NFSHeader:DataNFS	 								,Nil}) // Data de emissao
AADD(aCabec, {"C5_CONDPAG"	 , PadR(::oNFS:NFSHeader:CondPag,Len(SC5->C5_CONDPAG))	 	,Nil}) // Codigo da condicao de pagamanto*
AADD(aCabec, {"C5_DESC1"  	 , 0											 			,Nil}) // Percentual de Desconto
AADD(aCabec, {"C5_MOEDA" 	 , 1			 								 			,Nil}) // Moeda
AADD(aCabec, {"C5_MENNOTA"	 , PadR(::oNFS:NFSHeader:MenNota,Len(SC5->C5_MENNOTA))	 	,Nil}) // Mensagem para nota
AADD(aCabec, {"C5_NATUREZ"	 , PadR(::oNFS:NFSHeader:Natureza,Len(SC5->C5_NATUREZ))	 	,Nil}) // Natureza Financeira
//Campo customizado da chave da nfs
If (SC5->(FieldPos("C5_P_CHVNF")) > 0)
	AADD(aCabec, {"C5_P_CHVNF"	 , PadR(::oNFS:NFSHeader:ChaveNFe,Len(SC5->C5_P_CHVNF))	 	,Nil}) // Chave eletronica
EndIf
//Condição de pagamento tipo 9
For nE:= 1 to Len(::oNFS:NFSHeader:PlanoDePagamento)
	cSequen := Soma1(cSequen)
	AADD(aCabec, {"C5_PARC"+cSequen  , ::oNFS:NFSHeader:PlanoDePagamento[nE]:VlParc			,Nil}) // Valor Parcela
	AADD(aCabec, {"C5_DATA"+cSequen	 , ::oNFS:NFSHeader:PlanoDePagamento[nE]:DataParc	 	,Nil}) // Data Vencimento
Next nE
//AOA - 20/10/2017 - Novo tratamento de cobrança ID46
If (SC5->(FieldPos("C5_P_BOL")) > 0)
	AADD(aCabec, {"C5_P_BOL"	     , Alltrim(::oNFS:NFSHeader:Bol)					 	,Nil}) // Se gera boleto
EndIf

//Monta o array com os itens do Pedido de Vendas
For nR:= 1 to Len(::oNFS:NFSItem)
	AADD(aItens, {"C6_ITEM"		, PadR(::oNFS:NFSItem[nR]:NumItem,Len(SC6->C6_ITEM))			,Nil}) // Numero do Item no Pedido
	AADD(aItens, {"C6_PRODUTO"	, PadR(::oNFS:NFSItem[nR]:CodigoDoProd,Len(SC6->C6_PRODUTO))	,Nil}) // Codigo do Produto
	AADD(aItens, {"C6_DESCRI"	, PadR(::oNFS:NFSItem[nR]:DescrDoProduto,Len(SC6->C6_DESCRI))	,Nil}) // Descrição do Produto
	AADD(aItens, {"C6_LOCAL"	, PadR(::oNFS:NFSItem[nR]:LocalProd,Len(SC6->C6_LOCAL))			,Nil}) // Local Item
	AADD(aItens, {"C6_QTDVEN"	, ::oNFS:NFSItem[nR]:QtdDoProduto								,Nil}) // Quantidade Vendida
	AADD(aItens, {"C6_PRCVEN"	, ::oNFS:NFSItem[nR]:ValorUnitario								,Nil}) // Preco Unitario Liquido
	AADD(aItens, {"C6_VALOR"	, ::oNFS:NFSItem[nR]:ValorTotal	   								,Nil}) // Valor Total do Item
	AADD(aItens, {"C6_TES"		, PadR(::oNFS:NFSItem[nR]:Tes,Len(SC6->C6_TES))					,Nil}) // Tipo de Entrada/Saida do Item
	AADD(aItens, {"C6_CF"		, PadR(::oNFS:NFSItem[nR]:Cfop,Len(SC6->C6_CF))					,Nil}) // Código fiscal  
	AADD(aItens, {"C6_NFORI"	, PadR(::oNFS:NFSItem[nR]:NotaOri,Len(SC6->C6_NFORI))			,Nil}) // Nota de origem
	AADD(aItens, {"C6_SERIORI"	, PadR(::oNFS:NFSItem[nR]:SerieOri,Len(SC6->C6_SERIORI))		,Nil}) // Serie da Nf de origem
	AADD(aItens, {"C6_ITEMORI"	, PadR(::oNFS:NFSItem[nR]:ItemNfOri,Len(SC6->C6_ITEMORI))		,Nil}) // Item da NF de origem
		
	aAdd( aItem , aItens )
	aItens := {}
Next nR
	
//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_YYFAT001" , GetEnvServer() , .T. , aEmp , aCabec, aItem , cPedNum, cPedRef, cCodCli, cLoja , cCGC )

conout("Finalizou o StartJob")

If ValType(aLog)== "A"	
	AADD(::RetInt, WSClassNew("Result"))

	::RetInt[1]:Numero	:= aLog[2]
	::RetInt[1]:Log		:= aLog[3]
Else
	AADD(::RetInt, WSClassNew("Result"))

	::RetInt[1]:Numero	:= "ERR001"
	::RetInt[1]:Log		:= "Erro interno, favor contatar o suporte!"
EndIf

Return .T.

/*
Funcao      : HHEmpLog 
Parametros  : cCnpj
Retorno     : aEmp
Objetivos   : Busca qual empresa deve ser logado
Autor       : Renato Rezende
Data/Hora   : 02/05/2017
*/
*---------------------------------------------------------------*
 Static Function HHEmpLog(cCnpj)
*---------------------------------------------------------------*
Local aEmp		:= {"YY","01"}
Local cIndex	:= "" 

DbSelectArea("SM0")
//Criando Index temporario
cIndex	:=CriaTrab(Nil,.F.)
IndRegua("SM0",cIndex,"M0_CGC")
SM0->(DbSetIndex(cIndex+OrdBagExt()))
SM0->(DbSetOrder(1))

If SM0->(DbSeek(cCnpj))//CNPJ
	aEmp[1]:= SM0->M0_CODIGO
	aEmp[2]:= SM0->M0_CODFIL
EndIf

Return aEmp

/*
Método.......: InsereNfEntrada
Objetivo.....: Insere NF Entrada Protheus
Autor........: Renato Rezende
Data.........: 15/05/2017
*/
*----------------------------------------------------------------------------------*
 WSMETHOD InsereNfEntrada WSRECEIVE oNFE,NumCNPJ WSSEND RetInt WSSERVICE YYWS001
*----------------------------------------------------------------------------------* 
Local lInclui		:= .T.
Local lErro			:= .F.
Local lCGC			:= .F.

Local cNumDoc		:= Right(::oNFE:NFEHeader:NumDoc , Len(SF1->F1_DOC) )
Local cNumSerie		:= Right(::oNFE:NFEHeader:NumSerie , Len(SF1->F1_SERIE) )
Local cCGC			:= Alltrim(PadR(::oNFE:NFEHeader:CliForCGC , Len(SA1->A1_CGC) ))
Local cCliFor		:= PadR(::oNFE:NFEHeader:CliFor , Len(SA2->A2_COD) )
Local cLoja			:= PadR(::oNFE:NFEHeader:CliForLoja , Len(SA2->A2_LOJA) )
Local cArqLog		:= ""
Local cChave		:= ""
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabec		:= {}
Local aItens		:= {}
Local aItem			:= {}
Local aEmp			:= {}

Local nR			:= 0

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Validando Código do Cliente/Fornecedor
If !Empty(cCGC)
	cChave	:= cNumDoc+cNumSerie+cCGC
	lCGC	:= .T.
Else
	cChave := cNumDoc+cNumSerie+cCliFor+cLoja
EndIf

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SF1",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

//Monta o cabecalho do Pedido de Vendas
AADD(aCabec,{"F1_TIPO"   	, PadR(::oNFE:NFEHeader:TipoNf,Len(SF1->F1_TIPO))				}) // Tipo da nota	
AADD(aCabec,{"F1_FORMUL" 	, PadR(::oNFE:NFEHeader:FormProp,Len(SF1->F1_FORMUL))			}) // Formulário próprio		
AADD(aCabec,{"F1_DOC"    	, PadR(::oNFE:NFEHeader:NumDoc,Len(SF1->F1_DOC))				}) // Número do documento	   
AADD(aCabec,{"F1_SERIE"  	, PadR(::oNFE:NFEHeader:NumSerie,Len(SF1->F1_SERIE)) 			}) // Série do documento		
AADD(aCabec,{"F1_EMISSAO"	, ::oNFE:NFEHeader:DataNFE										}) // Data da emissão
AADD(aCabec,{"F1_DTDIGIT"	, ::oNFE:NFEHeader:DataDigit									}) // Data da Digitação   	   
If lCGC
	AADD(aCabec,{"CNPJ"		, Alltrim(cCGC)											 		}) // Cgc do cliente / Fornecedor
	AADD(aCabec,{"LOJACNPJ"	, ""															}) // Loja do cliente / Fornecedor
Else
	AADD(aCabec,{"F1_FORNECE"	, cCliFor 													}) // Cod do cliente / Fornecedor
	AADD(aCabec,{"F1_LOJA"		, cLoja   													}) // Loja do cliente / Fornecedor
EndIf
AADD(aCabec,{"F1_ESPECIE"	, PadR(::oNFE:NFEHeader:EspecieNFE,Len(SF1->F1_ESPECIE))		}) // Espécie da nota
AADD(aCabec,{"F1_COND"		, PadR(::oNFE:NFEHeader:CondPag,Len(SF1->F1_COND))				}) // Codigo da condicao de pagamanto
AADD(aCabec,{"F1_CHVNFE"	, PadR(::oNFE:NFEHeader:ChaveNfe,Len(SF1->F1_CHVNFE))			}) // Chave eletronica
//Campo customizado Solaris
If (SF1->(FieldPos("F1_P_IDPRO")) > 0)
	AADD(aCabec,{"F1_P_IDPRO"	, ::oNFE:NFEHeader:IdProcesso								}) // Id Processo
EndIf
AADD(aCabec,{"E2_NATUREZ"	, PadR(::oNFE:NFEHeader:Natureza,Len(SE2->E2_NATUREZ))			}) // Natureza financeira

//Monta o array com os itens do Pedido de Vendas
For nR:= 1 to Len(::oNFE:NFEItem)
	AADD(aItens,{"D1_ITEM"		, PadR(::oNFE:NFEItem[nR]:NumItem,Len(SD1->D1_ITEM))	 		,Nil}) // Numero do Item no Pedido
	AADD(aItens,{"D1_COD"  		, PadR(::oNFE:NFEItem[nR]:CodigoDoProd,Len(SD1->D1_COD))		,Nil}) // Codigo do Produto
	AADD(aItens,{"D1_LOCAL"		, PadR(::oNFE:NFEItem[nR]:LocalProd,Len(SD1->D1_LOCAL))			,Nil}) // Local Item
	AADD(aItens,{"D1_QUANT"		, ::oNFE:NFEItem[nR]:QtdDoProduto								,Nil}) // Quantidade Vendida
	AADD(aItens,{"D1_VUNIT"		, ::oNFE:NFEItem[nR]:ValorUnitario								,Nil}) // Preco Unitario Liquido
	AADD(aItens,{"D1_TOTAL"		, ::oNFE:NFEItem[nR]:ValorTotal	   								,Nil}) // Valor Total do Item
	AADD(aItens,{"D1_TES"  		, PadR(::oNFE:NFEItem[nR]:Tes,Len(SD1->D1_TES))					,Nil}) // Tipo de Entrada/Saida do Item 
	AADD(aItens,{"D1_NFORI"		, PadR(::oNFE:NFEItem[nR]:NotaOri,Len(SD1->D1_NFORI))			,Nil}) // Nota de origem
	AADD(aItens,{"D1_SERIORI"	, PadR(::oNFE:NFEItem[nR]:SerieOri,Len(SD1->D1_SERIORI))		,Nil}) // Serie da Nf de origem
	AADD(aItens,{"D1_ITEMORI"	, PadR(::oNFE:NFEItem[nR]:ItemNfOri,Len(SD1->D1_ITEMORI))		,Nil}) // Item da NF de origem
	AADD(aItens,{"D1_CF"		, PadR(::oNFE:NFEItem[nR]:Cfop,Len(SD1->D1_CF))					,Nil}) // Código fiscal  
	//Campo customizado Solaris
	If (SD1->(FieldPos("D1_P_TPTRA")) > 0)
		AADD(aItens,{"D1_P_TPTRA"	, PadR(::oNFE:NFEItem[nR]:TipoTrans,Len(SD1->D1_P_TPTRA))	,Nil}) // Tipo da transação
	EndIf			
	AADD( aItem , aItens )
	aItens := {}
Next nR
	
//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_YYEST001" , GetEnvServer() , .T. , aEmp , aCabec, aItem , cNumDoc, cNumSerie, cCliFor, cLoja , cCGC )

conout("Finalizou o StartJob")

If ValType(aLog)== "A"	
	AADD(::RetInt, WSClassNew("Result"))

	::RetInt[1]:Numero	:= aLog[2]
	::RetInt[1]:Log		:= aLog[3]
Else
	AADD(::RetInt, WSClassNew("Result"))

	::RetInt[1]:Numero	:= "ERR001"
	::RetInt[1]:Log		:= "Erro interno, favor contatar o suporte!"
EndIf
Return .T.