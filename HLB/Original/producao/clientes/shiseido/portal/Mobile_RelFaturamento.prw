#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Fat
	WSDATA Status		As String
	WSDATA Cliente     	As String
	WSDATA Nome	       	As String
	WSDATA CodVend     	As String
	WSDATA Vendedor	   	As String
	WSDATA Data	       	As String
	WSDATA Pedido      	As String
	WSDATA TipoNF      	As String
	WSDATA NF      	   	As String
	WSDATA CFOP      	As String
	WSDATA CodProd		As String
	WSDATA Produto		As String
	WSDATA Brand		As String
	WSDATA Line			As String
	WSDATA CST			As String
	WSDATA NCM			As String
	WSDATA Armazem		As String
	WSDATA Qtd			As Float
	WSDATA Preco		As Float
	WSDATA NetSales 	As Float
	WSDATA GrossSales	As Float
	WSDATA COG			As Float
	WSDATA Fator		As Float
	WSDATA PercIPI		As Float
	WSDATA ValIPI		As Float
	WSDATA PercICMS		As Float
	WSDATA ValICMS		As Float
	WSDATA IVA			As Float
	WSDATA ICMSST		As Float
	WSDATA PercPIS		As Float
	WSDATA PIS			As Float
	WSDATA PercCOFINS	As Float
	WSDATA COFINS		As Float
ENDWSSTRUCT

WsService Mobile_RelFaturamento Description "LOGOS Mobile - Relatório de Faturamento"

   WsData DataDe    	As String
   WsData DataAte   	As String
   WsData ProdutoDe		As String
   WsData ProdutoAte	As String
   WsData ClienteDe		As String
   WsData ClienteAte	As String
   WsData ArmazemDe		As String
   WsData ArmazemAte	As String
   WsData Tipo			As String
   WsData DevVendas		As String

   WsData Retorno As Array of Fat
   
   WsMethod RetornaFaturamento Description "LOGOS Mobile - Relatório de Faturamento"

EndWsService

WsMethod RetornaFaturamento WsReceive DataDe, DataAte, ProdutoDe, ProdutoAte, ClienteDe, ClienteAte, ArmazemDe,;
									  ArmazemAte, Tipo, DevVendas WsSend Retorno WsService Mobile_RelFaturamento

Private cPerg		:= "R7FAT2"
Private cQuery		:= ""

Pergunte(cPerg,.F.)

mv_par01 := CtoD(DataDe)	  	//Data de 
mv_par02 := CtoD(DataAte)		//Data Até
mv_par03 := ProdutoDe		  	//Produto de
mv_par04 := ProdutoAte		 	//Produto Até
mv_par05 := Space(6)			//Marca de 
mv_par06 := "ZZZZZZ"			//Marca Até
mv_par07 := ClienteDe			//Cliente de 
mv_par08 := ClienteAte			//Cliente Até
mv_par09 := ArmazemDe			//Do Armazém 
mv_par10 := ArmazemAte			//Até Armazém
mv_par11 := Val(Tipo)			//Tipo Rel. Analítico / Sintético / Aglut. Cliente
mv_par12 := Val(DevVendas)		//Dev. Vendas Não / Sim

If mv_par11 == 1 .or. mv_par11 == 2
	GeraTMPAn()
ElseIf mv_par11 == 3
	GeraTMPAgl()
EndIf

nx := 0
::Retorno := {}

ConOut("Mobile Logos - Inicio da Geração do Relatório de Faturamento.")

ConOut("Mobile Logos - Carregando dados.")
If !TMP->(EOF())
	If mv_par11 == 1 
		While !TMP->(EOF())
			nX++
			aAdd(::Retorno, WSClassNew("Fat"))
			::Retorno[nX]:Status    	:= "1"
			::Retorno[nX]:Cliente		:= TMP->CLIENTE
			::Retorno[nX]:Nome			:= TMP->NOME
			::Retorno[nX]:CodVend		:= TMP->CODVEND
			::Retorno[nX]:Vendedor		:= TMP->VENDEDOR
			::Retorno[nX]:Data			:= TMP->DATA
			::Retorno[nX]:Pedido		:= TMP->PEDIDO
			::Retorno[nX]:TipoNF		:= TMP->TIPONF
			::Retorno[nX]:NF			:= TMP->NF
			::Retorno[nX]:CFOP			:= TMP->CFOP
			::Retorno[nX]:CodProd		:= TMP->CODPROD
			::Retorno[nX]:Produto		:= TMP->PRODUTO
			::Retorno[nX]:Brand			:= TMP->BRAND
			::Retorno[nX]:Line			:= TMP->LINE
			::Retorno[nX]:CST			:= TMP->CST
			::Retorno[nX]:NCM			:= TMP->NCM
			::Retorno[nX]:Armazem		:= TMP->ARMAZEM
			::Retorno[nX]:Qtd			:= TMP->QTD
			::Retorno[nX]:Preco			:= TMP->PRECO
			::Retorno[nX]:NetSales		:= TMP->NETSALES
			::Retorno[nX]:GrossSales	:= TMP->GROSSSALES
			::Retorno[nX]:Cog			:= TMP->COG
			::Retorno[nX]:Fator			:= TMP->FATOR
			::Retorno[nX]:PercIPI		:= TMP->PIPI
			::Retorno[nX]:ValIPI		:= TMP->VALIPI
			::Retorno[nX]:PercICMS		:= TMP->PICMS
			::Retorno[nX]:ValICMS		:= TMP->VALICMS
			::Retorno[nX]:IVA			:= TMP->IVA
			::Retorno[nX]:ICMSST		:= TMP->ICMSST
			::Retorno[nX]:PercPIS		:= TMP->PPIS
			::Retorno[nX]:PIS			:= TMP->PIS
			::Retorno[nX]:PercCOFINS	:= TMP->PCOFINS
			::Retorno[nX]:COFINS		:= TMP->COFINS
			TMP->(dbSkip())
		End
	ElseIf mv_par11 == 2
			::Retorno[nX]:Status    	:= "1"
			::Retorno[nX]:Cliente		:= TMP->CLIENTE
			::Retorno[nX]:Nome			:= TMP->NOME
			::Retorno[nX]:CodVend		:= TMP->CODVEND
			::Retorno[nX]:Vendedor		:= TMP->VENDEDOR
			::Retorno[nX]:Data			:= TMP->DATA
			::Retorno[nX]:Pedido		:= ""
			::Retorno[nX]:TipoNF		:= ""
			::Retorno[nX]:NF			:= TMP->NF
			::Retorno[nX]:CFOP			:= TMP->CFOP
			::Retorno[nX]:CodProd		:= TMP->CODPROD
			::Retorno[nX]:Produto		:= TMP->PRODUTO
			::Retorno[nX]:Brand			:= TMP->BRAND
			::Retorno[nX]:Line			:= TMP->LINE
			::Retorno[nX]:CST			:= TMP->CST
			::Retorno[nX]:NCM			:= TMP->NCM
			::Retorno[nX]:Armazem		:= TMP->ARMAZEM
			::Retorno[nX]:Qtd			:= TMP->QTD
			::Retorno[nX]:Preco			:= TMP->PRECO
			::Retorno[nX]:NetSales		:= TMP->NETSALES
			::Retorno[nX]:GrossSales	:= TMP->GROSSSALES
			::Retorno[nX]:Cog			:= TMP->COG
			::Retorno[nX]:Fator			:= TMP->FATOR
			::Retorno[nX]:PercIPI		:= 0
			::Retorno[nX]:ValIPI		:= 0
			::Retorno[nX]:PercICMS		:= 0
			::Retorno[nX]:ValICMS		:= 0
			::Retorno[nX]:IVA			:= 0
			::Retorno[nX]:ICMSST		:= 0
			::Retorno[nX]:PercPIS		:= 0
			::Retorno[nX]:PIS			:= 0
			::Retorno[nX]:PercCOFINS	:= 0
			::Retorno[nX]:COFINS		:= 0
	ElseIf mv_par11 == 3
			::Retorno[nX]:Status    	:= "1"
			::Retorno[nX]:Cliente		:= TMP->CLIENTE
			::Retorno[nX]:Nome			:= TMP->NOME
			::Retorno[nX]:CodVend		:= ""
			::Retorno[nX]:Vendedor		:= ""
			::Retorno[nX]:Data			:= ""
			::Retorno[nX]:Pedido		:= ""
			::Retorno[nX]:TipoNF		:= TMP->TIPONF
			::Retorno[nX]:NF			:= ""
			::Retorno[nX]:CFOP			:= ""
			::Retorno[nX]:CodProd		:= ""
			::Retorno[nX]:Produto		:= ""
			::Retorno[nX]:Brand			:= ""
			::Retorno[nX]:Line			:= ""
			::Retorno[nX]:CST			:= ""
			::Retorno[nX]:NCM			:= ""
			::Retorno[nX]:Armazem		:= ""
			::Retorno[nX]:Qtd			:= TMP->QTD
			::Retorno[nX]:Preco			:= TMP->PRECO
			::Retorno[nX]:NetSales		:= TMP->NETSALES
			::Retorno[nX]:GrossSales	:= TMP->GROSSSALES
			::Retorno[nX]:Cog			:= TMP->COG
			::Retorno[nX]:Fator			:= TMP->FATOR
			::Retorno[nX]:PercIPI		:= 0
			::Retorno[nX]:ValIPI		:= TMP->VALIPI
			::Retorno[nX]:PercICMS		:= 0
			::Retorno[nX]:ValICMS		:= TMP->VALICMS
			::Retorno[nX]:IVA			:= TMP->IVA
			::Retorno[nX]:ICMSST		:= TMP->ICMSST
			::Retorno[nX]:PercPIS		:= 0
			::Retorno[nX]:PIS			:= TMP->PIS
			::Retorno[nX]:PercCOFINS	:= 0
			::Retorno[nX]:COFINS		:= TMP->COFINS
	End
Else
	nX++
	aAdd(::Retorno, WSClassNew("Fat"))
	::Retorno[nX]:Status      := "0"
	::Retorno[nX]:Cliente		:= ""
	::Retorno[nX]:Nome			:= ""
	::Retorno[nX]:CodVend		:= ""
	::Retorno[nX]:Vendedor		:= ""
	::Retorno[nX]:Data			:= ""
	::Retorno[nX]:Pedido		:= ""
	::Retorno[nX]:TipoNF		:= ""
	::Retorno[nX]:NF			:= ""
	::Retorno[nX]:CFOP			:= ""
	::Retorno[nX]:CodProd		:= ""
	::Retorno[nX]:Produto		:= ""
	::Retorno[nX]:Brand			:= ""
	::Retorno[nX]:Line			:= ""
	::Retorno[nX]:CST			:= ""
	::Retorno[nX]:NCM			:= ""
	::Retorno[nX]:Armazem		:= ""
	::Retorno[nX]:Qtd			:= 0
	::Retorno[nX]:Preco			:= 0
	::Retorno[nX]:NetSales		:= 0
	::Retorno[nX]:GrossSales	:= 0
	::Retorno[nX]:Cog			:= 0
	::Retorno[nX]:Fator			:= 0
	::Retorno[nX]:PercIPI		:= 0
	::Retorno[nX]:ValIPI		:= 0
	::Retorno[nX]:PercICMS		:= 0
	::Retorno[nX]:ValICMS		:= 0
	::Retorno[nX]:IVA			:= 0
	::Retorno[nX]:ICMSST		:= 0
	::Retorno[nX]:PercPIS		:= 0
	::Retorno[nX]:PIS			:= 0
	::Retorno[nX]:PercCOFINS	:= 0
	::Retorno[nX]:COFINS		:= 0
EndIf
TMP->(dbCloseArea())
ConOut("Mobile Logos - WebService de Relatório de Faturamento finalizado.")

Return(.T.)

/*
Funcao      : GeraTMPAgl
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório Aglutinado
Autor     	: Renato Rezende  	 	
Data     	: 04/06/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraTMPAgl()
*------------------------------*

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf
cQuery		:= ""

cQuery:= "SELECT "  + CRLF 
cQuery+= "SD2.D2_CLIENTE  AS [Cliente] "  + CRLF
cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
cQuery+= ",SD2.D2_TIPO AS [TIPONF] "  + CRLF
cQuery+= ",SUM(SD2.D2_QUANT) AS [Qtd] "  + CRLF
cQuery+= ",SUM(SD2.D2_PRCVEN)  AS [Preco] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) AS [NetSales] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALBRUT) AS [GrossSales] "  + CRLF
cQuery+= ",SUM(SD2.D2_CUSTO1) AS COG "  + CRLF
//cQuery+= ",SUM((SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) / SD2.D2_VALBRUT) AS Fator
cQuery+= ", SUM(SD2.D2_TOTAL / (SD2.D2_TOTAL + SD2.D2_VALIPI +SD2.D2_VALICM+SD2.D2_ICMSRET+SD2.D2_VALIMP6+SD2.D2_VALIMP5)) AS Fator "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIPI) AS [ValIPI] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALICM) AS [ValICMS] "  + CRLF
cQuery+= ",SUM(SD2.D2_ICMSRET) AS [ICMSST] "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIMP6) AS PIS "  + CRLF
cQuery+= ",SUM(SD2.D2_VALIMP5) AS COFINS "  + CRLF
cQuery+= "FROM SD2R70 SD2 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SF2R70 Where D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SA1R70 Where D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD2.D2_FILIAL AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD2.D2_COD "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF 
cQuery+= "WHERE SD2.D_E_L_E_T_ <> '*' "  + CRLF
cQuery+= "	AND SD2.D2_TIPO = 'N' "  + CRLF
cQuery+= "	AND SD2.D2_CF in ('5102','6102','5405','5403','6108','6403','6109','6404') "  + CRLF
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND SD2.D2_EMISSAO >= '"+Dtos(mv_par01)+"' " + CRLF
	cQuery += " AND SD2.D2_EMISSAO <= '"+Dtos(mv_par02)+"' " + CRLF
EndIf
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND SD2.D2_COD >= '"+mv_par03+"' " + CRLF
	cQuery += " AND SD2.D2_COD <= '"+mv_par04+"' " + CRLF
EndIf
If !Empty(mv_par07) .OR. !Empty(mv_par08)
	cQuery += " AND SD2.D2_CLIENTE >= '"+mv_par07+"' " + CRLF
	cQuery += " AND SD2.D2_CLIENTE <= '"+mv_par08+"' " + CRLF
EndIf
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
	cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
EndIf 
If !Empty(mv_par09) .OR. !Empty(mv_par10)
	cQuery += " AND SD2.D2_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
	cQuery += " AND SD2.D2_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
EndIf
cQuery+= "	Group By SD2.D2_CLIENTE ,SD2.D2_TIPO,SA1.A1_NOME "  + CRLF 
//Impressão NF de devolução
If mv_par12 == 2
	cQuery+= "Union ALL "  + CRLF
	cQuery+= "SELECT "  + CRLF 
	cQuery+= "SD1.D1_FORNECE AS [Cliente] "  + CRLF
	cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
	cQuery+= ",SD1.D1_TIPO AS [TIPONF] "  + CRLF
	cQuery+= ",SUM(SD1.D1_QUANT*(-1)) AS [Qtd] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VUNIT)  AS [Preco] "  + CRLF
	cQuery+= ",SUM(SD1.D1_TOTAL*(-1)) AS [NetSales] "  + CRLF
	cQuery+= ",SUM((SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5)*(-1)) AS [GrossSales] "  + CRLF
	cQuery+= ",SUM(SD1.D1_CUSTO*(-1)) AS COG "  + CRLF
	cQuery+= ",SUM((SD1.D1_TOTAL / (SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5))*(-1)) AS Fator "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIPI*(-1)) AS [ValIPI] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALICM*(-1)) AS [ValICMS] "  + CRLF
	cQuery+= ",SUM(SD1.D1_ICMSRET*(-1)) AS [ICMSST] "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIMP6*(-1)) AS PIS "  + CRLF
	cQuery+= ",SUM(SD1.D1_VALIMP5*(-1)) AS COFINS "  + CRLF
	cQuery+= "FROM SD1R70 SD1 "  + CRLF
	cQuery+= "	Join (Select * From SD2R70) SD2 on SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_SERIE = SD1.D1_SERIORI "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF2R70 Where D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF1R70 Where D_E_L_E_T_ <> '*') SF1 on SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA1R70 Where D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD1.D1_FILIAL AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD1.D1_COD "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF
	cQuery+= "WHERE SD1.D_E_L_E_T_ <> '*' "  + CRLF
	cQuery+= "	and D1_TIPO = 'D' "  + CRLF
    //VYB - 19/17/2016 - Solicitado pelo cliente por email - retirar o filtro de CFOP
	//cQuery+= "	and D1_CF NOT IN ('1949','2949') "  + CRLF
	cQuery+= "	and D1_TP = 'ME' " + CRLF
	If !Empty(mv_par01) .OR. !Empty(mv_par02)
   		cQuery += " AND ((SD1.D1_EMISSAO BETWEEN '"+Dtos(mv_par01)+"'AND'"+Dtos(mv_par02)+"') OR (SD1.D1_DTDIGIT BETWEEN '"+Dtos(mv_par01)+"'AND'"+Dtos(mv_par02)+"')) " + CRLF 
	EndIf
	If !Empty(mv_par03) .OR. !Empty(mv_par04)
		cQuery += " AND SD1.D1_COD >= '"+mv_par03+"' " + CRLF
		cQuery += " AND SD1.D1_COD <= '"+mv_par04+"' " + CRLF
	EndIf
	If !Empty(mv_par07) .OR. !Empty(mv_par08)
		cQuery += " AND SD1.D1_FORNECE >= '"+mv_par07+"' " + CRLF
		cQuery += " AND SD1.D1_FORNECE <= '"+mv_par08+"' " + CRLF
	EndIf
	If !Empty(mv_par05) .OR. !Empty(mv_par06)
		cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
   		cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
	EndIf  
	If !Empty(mv_par09) .OR. !Empty(mv_par10)
   		cQuery += " AND SD1.D1_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
		cQuery += " AND SD1.D1_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
	EndIf	
	cQuery+= "Group By SD1.D1_FORNECE,SD1.D1_TIPO,SA1.A1_NOME "  + CRLF
EndIf
cQuery+= "ORDER BY [TIPONF] DESC,[Nome] "  + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) //execução da query

Return

/*
Funcao      : GeraTMPAn
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 29/05/2014
Módulo      : Faturamento.
Cliente     : Shiseido.
*/
*------------------------------*
 Static Function GeraTMPAn()
*------------------------------*

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf
cQuery		:= ""

//Início do Select
cQuery:= "SELECT "  + CRLF 
cQuery+= "SD2.D2_CLIENTE AS [Cliente] "  + CRLF
cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
cQuery+= ",SF2.F2_VEND1 AS [CodVend] "  + CRLF
cQuery+= ",SA3.A3_NOME AS [Vendedor] "  + CRLF
cQuery+= ",SD2.D2_EMISSAO AS [Data] "  + CRLF
cQuery+= ",SD2.D2_PEDIDO AS [PEDIDO] "  + CRLF //RRP - 30/07/2014 - Solicitado pela Sabrina
cQuery+= ",SD2.D2_TIPO AS [TIPONF] "  + CRLF
cQuery+= ",SD2.D2_DOC AS [NF] "  + CRLF
cQuery+= ",SD2.D2_CF AS [CFOP] "  + CRLF
cQuery+= ",SD2.D2_COD AS [CodProd] "  + CRLF
cQuery+= ",SB1.B1_DESC AS [Produto] "  + CRLF
cQuery+= ",ZX4.ZX4_NOME AS [BRAND] "  + CRLF
cQuery+= ",ZX5.ZX5_NOME AS [LINE] "  + CRLF
cQuery+= ",SD2.D2_CLASFIS AS [CST] "  + CRLF
cQuery+= ",SB1.B1_POSIPI AS [NCM] "  + CRLF
cQuery+= ",SD2.D2_LOCAL AS [Armazem] "  + CRLF                                      
cQuery+= ",SD2.D2_QUANT AS [Qtd] "  + CRLF
cQuery+= ",SD2.D2_PRCVEN  AS [Preco] "  + CRLF
cQuery+= ",SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 AS [NetSales] "  + CRLF
cQuery+= ",SD2.D2_VALBRUT AS [GrossSales] "  + CRLF
cQuery+= ",SD2.D2_CUSTO1 AS COG "  + CRLF
cQuery+= ",(SD2.D2_CUSTO1/ SD2.D2_TOTAL ) *100 AS [COGNet] "  + CRLF
//cQuery+= ",(SD2.D2_VALBRUT -SD2.D2_VALIPI - SD2.D2_VALICM - SD2.D2_ICMSRET - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) / SD2.D2_VALBRUT AS Fator
cQuery+= ", (SD2.D2_TOTAL / (SD2.D2_TOTAL + SD2.D2_VALIPI +SD2.D2_VALICM+SD2.D2_ICMSRET+SD2.D2_VALIMP6+SD2.D2_VALIMP5)) AS Fator "  + CRLF
cQuery+= ",SD2.D2_IPI AS [PIPI] "  + CRLF
cQuery+= ",SD2.D2_VALIPI AS [ValIPI] "  + CRLF
cQuery+= ",SD2.D2_PICM AS [PICMS] "  + CRLF
cQuery+= ",SD2.D2_VALICM AS [ValICMS] "  + CRLF
cQuery+= ",SD2.D2_MARGEM AS IVA "  + CRLF
cQuery+= ",SD2.D2_ICMSRET AS [ICMSST] "  + CRLF
cQuery+= ",SD2.D2_ALQIMP6 AS [PPIS] "  + CRLF
cQuery+= ",SD2.D2_VALIMP6 AS PIS "  + CRLF
cQuery+= ",SD2.D2_ALQIMP5 AS [PCOFINS] "  + CRLF
cQuery+= ",SD2.D2_VALIMP5 AS COFINS "  + CRLF
cQuery+= "FROM SD2R70 SD2 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SF2R70 WHERE D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
cQuery+= "	Left Outer Join(Select * From SA1R70 WHERE D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD2.D2_FILIAL AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA
cQuery+= "	Left Outer Join(Select * From SA3R70 WHERE D_E_L_E_T_ <> '*') SA3 on SA3.A3_COD = SF2.F2_VEND1 "  + CRLF
cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD2.D2_COD "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF 
cQuery+= "WHERE SD2.D_E_L_E_T_ <> '*' "  + CRLF
cQuery+= "	AND SD2.D2_TIPO = 'N' "  + CRLF
If !Empty(mv_par01) .OR. !Empty(mv_par02)
	cQuery += " AND SD2.D2_EMISSAO >= '"+Dtos(mv_par01)+"' " + CRLF
	cQuery += " AND SD2.D2_EMISSAO <= '"+Dtos(mv_par02)+"' " + CRLF
EndIf
If !Empty(mv_par03) .OR. !Empty(mv_par04)
	cQuery += " AND SD2.D2_COD >= '"+mv_par03+"' " + CRLF
	cQuery += " AND SD2.D2_COD <= '"+mv_par04+"' " + CRLF
EndIf
If !Empty(mv_par07) .OR. !Empty(mv_par08)
	cQuery += " AND SD2.D2_CLIENTE >= '"+mv_par07+"' " + CRLF
	cQuery += " AND SD2.D2_CLIENTE <= '"+mv_par08+"' " + CRLF
EndIf
If !Empty(mv_par05) .OR. !Empty(mv_par06)
	cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
	cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
EndIf 
If !Empty(mv_par09) .OR. !Empty(mv_par10)
	cQuery += " AND SD2.D2_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
	cQuery += " AND SD2.D2_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
EndIf
cQuery+= "	AND SD2.D2_CF in ('5102','6102','5405','5403','6108','6403','6109','6404') "  + CRLF 

//Impressão NF de devolução
If mv_par12 == 2
	cQuery+= "Union ALL "  + CRLF
	cQuery+= "SELECT "  + CRLF 
	cQuery+= "SD1.D1_FORNECE AS [Cliente] "  + CRLF
	cQuery+= ",SA1.A1_NOME AS [Nome] "  + CRLF
	cQuery+= ",SF2.F2_VEND1 AS [CodVend] "  + CRLF
	cQuery+= ",SA3.A3_NOME AS [Vendedor] "  + CRLF
	cQuery+= ",SD1.D1_DTDIGIT AS [Data] "  + CRLF  //VYB - 27/07/2016 - Carregar a data de Digitação, não a de emissão
	cQuery+= ",SD1.D1_PEDIDO AS [PEDIDO] "  + CRLF //RRP - 30/07/2014 - Solicitado pela Sabrina
	cQuery+= ",SD1.D1_TIPO AS [TIPONF] "  + CRLF
	cQuery+= ",SD1.D1_DOC AS [NF] "  + CRLF
	cQuery+= ",SD1.D1_CF AS [CFOP] "  + CRLF
	cQuery+= ",SD1.D1_COD AS [CodProd] "  + CRLF
	cQuery+= ",SB1.B1_DESC AS [Produto] "  + CRLF
	cQuery+= ",ZX4.ZX4_NOME AS [BRAND] "  + CRLF
	cQuery+= ",ZX5.ZX5_NOME AS [LINE] "  + CRLF
	cQuery+= ",SD1.D1_CLASFIS AS [CST] "  + CRLF
	cQuery+= ",SB1.B1_POSIPI AS [NCM] "  + CRLF
	cQuery+= ",SD1.D1_LOCAL AS [Armazem] "  + CRLF                                      
	cQuery+= ",SD1.D1_QUANT*(-1) AS [Qtd] "  + CRLF
	cQuery+= ",SD1.D1_VUNIT  AS [Preco] "  + CRLF
	cQuery+= ",SD1.D1_TOTAL*(-1) AS [NetSales] "  + CRLF
	//VYB - 21/17/2016 - Não incluir ICMS - PIS - COFINS no cálculo da coluna Gross Sales do relatório para bater com a NF
	//cQuery+= ",(SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5)*(-1) AS [GrossSales] "  + CRLF
	cQuery+= ",((SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) - (SD1.D1_VALDESC))*(-1) AS [GrossSales] "  + CRLF
	cQuery+= ",SD1.D1_CUSTO*(-1) AS COG "  + CRLF
	cQuery+= ",((SD1.D1_CUSTO/ SD1.D1_TOTAL ) *100)*(-1) AS [COGNet] "  + CRLF
	cQuery+= ",(SD1.D1_TOTAL / (SD1.D1_TOTAL + SD1.D1_VALIPI +SD1.D1_VALICM+SD1.D1_ICMSRET+SD1.D1_VALIMP6+SD1.D1_VALIMP5))*(-1) AS Fator "  + CRLF
	cQuery+= ",SD1.D1_IPI AS [PIPI] "  + CRLF
	cQuery+= ",SD1.D1_VALIPI*(-1) AS [ValIPI] "  + CRLF
	cQuery+= ",SD1.D1_PICM AS [PICMS] "  + CRLF
	cQuery+= ",SD1.D1_VALICM*(-1) AS [ValICMS] "  + CRLF
	cQuery+= ",SD1.D1_MARGEM AS IVA "  + CRLF
	cQuery+= ",SD1.D1_ICMSRET*(-1) AS [ICMSST] "  + CRLF
	cQuery+= ",SD1.D1_ALQIMP6 AS [PPIS] "  + CRLF
	cQuery+= ",SD1.D1_VALIMP6*(-1) AS PIS "  + CRLF
	cQuery+= ",SD1.D1_ALQIMP5 AS [PCOFINS] "  + CRLF
	cQuery+= ",SD1.D1_VALIMP5*(-1) AS COFINS "  + CRLF
	cQuery+= "FROM SD1R70 SD1 "  + CRLF
	cQuery+= "	Join (Select * From SD2R70) SD2 on SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_SERIE = SD1.D1_SERIORI "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF2R70 WHERE D_E_L_E_T_ <> '*') SF2 on SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SF1R70 WHERE D_E_L_E_T_ <> '*') SF1 on SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA1R70 WHERE D_E_L_E_T_ <> '*') SA1 on SA1.A1_FILIAL = SD1.D1_FILIAL AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SA3R70 WHERE D_E_L_E_T_ <> '*') SA3 on SA3.A3_COD = SF2.F2_VEND1 "  + CRLF
	cQuery+= "	Left Outer Join(Select * From SB1R70 WHERE D_E_L_E_T_ <> '*') SB1 on SB1.B1_COD = SD1.D1_COD "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX4R70 WHERE D_E_L_E_T_ <> '*') ZX4 on SB1.B1_P_MULTB = ZX4.ZX4_CODIGO "  + CRLF 
	cQuery+= "	Left Outer Join(Select * From ZX5R70 WHERE D_E_L_E_T_ <> '*') ZX5 on SB1.B1_P_SUBL = ZX5.ZX5_CODIGO "  + CRLF
	//AOA - 20/10/2016 - Ajuste para verificar se está deletado no SD2
	cQuery+= "WHERE SD1.D_E_L_E_T_ <> '*'  AND SD2.D_E_L_E_T_ <> '*' "  + CRLF
	If !Empty(mv_par01) .OR. !Empty(mv_par02)
   		cQuery += " AND SD1.D1_DTDIGIT >= '"+Dtos(mv_par01)+"' " + CRLF
		cQuery += " AND SD1.D1_DTDIGIT <= '"+Dtos(mv_par02)+"' " + CRLF
	EndIf
	If !Empty(mv_par03) .OR. !Empty(mv_par04)
		cQuery += " AND SD1.D1_COD >= '"+mv_par03+"' " + CRLF
		cQuery += " AND SD1.D1_COD <= '"+mv_par04+"' " + CRLF
	EndIf
	If !Empty(mv_par07) .OR. !Empty(mv_par08)
		cQuery += " AND SD1.D1_FORNECE >= '"+mv_par07+"' " + CRLF
		cQuery += " AND SD1.D1_FORNECE <= '"+mv_par08+"' " + CRLF
	EndIf
	If !Empty(mv_par05) .OR. !Empty(mv_par06)                          
		cQuery += " AND ZX4.ZX4_CODIGO >= '"+mv_par05+"' " + CRLF
   		cQuery += " AND ZX4.ZX4_CODIGO <= '"+mv_par06+"' " + CRLF
	EndIf  
	If !Empty(mv_par09) .OR. !Empty(mv_par10)
   		cQuery += " AND SD1.D1_LOCAL >= '"+Alltrim(mv_par09)+"' " + CRLF
		cQuery += " AND SD1.D1_LOCAL <= '"+Alltrim(mv_par10)+"' " + CRLF
	EndIf
	cQuery+= "	and D1_TIPO = 'D' "  + CRLF
	//VYB - 19/17/2016 - Solicitado pelo cliente por email - retirar o filtro de CFOP
	//cQuery+= "	and D1_CF NOT IN ('1949','2949') "  + CRLF
	cQuery+= "	and D1_TP = 'ME' " + CRLF
EndIf
cQuery+= "Order By [TIPONF] DESC, [Data], [NF] "  + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) //execução da query

Return