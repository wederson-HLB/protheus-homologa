#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE ENTER CHR(13)+CHR(10)

*----------------------------------------------------------------*
WsService GTFLG001 Description "Integracao GT de Fluig x Protheus - Emer.C"
*----------------------------------------------------------------*
WsData cCodEmp		as String
WsData cCodAmb		as String
WsData cChave		as String
WsData cEstado		as String
WsData cNfsaida		as String  
WsData cSerie		as String
WsData cPedido		as String
WsData cTipo		as String
WsData cNumNF		as String
WsData cFornecedor	as String
WsData cLoja		as String
WsData cProduto		as String
WsData cPedVenda	as String
WsData cLocal		as String
WsData cValid		as String
WsData cCad			as String
WsData cReg			as String
WsData cCNPJ		as String

WsData aRetCusto	as Array of GETCUSTORET
WsData aRetAmb		as Array of GETAMBRET
WsData aRetIss		as Array of GETISSRET
WsData aRetTes		as Array of GETTESRET
WsData aRetPag		as Array of GETPAGRET
WsData aRetDest		as Array of GETDESTRET
WsData aRetEst		as Array of GETESTADRET
WsData aRetTrans	as Array of GETTRANSRET
WsData aRetPaiBC	as Array of GETPABCRET
WsData aRetPaiRF	as Array of GETPARFRET
WsData aRetCodMun	as Array of GETMUNRET
WsData aRetMensPad	as Array of GETMENPADRET
WsData aRetMensNF	as Array of GETMENSNFRET
WsData aRetNFEntr	as Array of GETNFENTRRET
WsData aRetNFSaid	as Array of GETNFSAIDRET
WsData aRetPed		as Array of GETPEDRET
WsData aRetArmaz	as Array of GETARMAZRET
WsData aRetLote		as Array of GETLOTERET
WsData aRetSts		as Array of SETSTSRET
WsData aRetCliente	as Array of GETCLIRET
WsData aRetFornece	as Array of GETFORRET
WsData aRetProd		as Array of GETPRDRET
WsData aRetCTES		as Array of GETCTESRET
WsData aRetCCont	as Array of GETCCONRET
WsData aRetCPag		as Array of GETCPGRET
WsData aRetCISS		as Array of GETCISSRET
WsData aRetCCT		as Array of GETCCTRET
WsData aRetTransp	as Array of GETTRSPRET
WsData aRetSeries	as Array of GETSERIRET
WsData aRetVldCad	as Array of GETVLDCADRET
WsData aRetImp		as Array of GETIMPRET

WsData DadosGet		as stDadosGet
WsData DadosSet		as stDadosSet

WsMethod GETCUSTO 	Description "Retorna a tabela de Centro de Custo."
WsMethod GETISS 	Description "Retorna a tabela de Codigos ISS disponivel."
WsMethod GETTES 	Description "Retorna a tabela TES para empresa."
WsMethod GETPAG 	Description "Retorna as condições de pagamentos."
WsMethod GETDEST 	Description "Retorna os destinatarios (Clientes da empresa)."
WsMethod GETTRANS 	Description "Retorna as transportadoras."
WsMethod GETMENPAD	Description "Retorna as mensagens padrões."
WsMethod SETCAN		Description "Define o processo como cancelado."
WsMethod SETFIM		Description "Define o processo como finalizado."

WsMethod GETAMB 	Description "Retorna ambiente, código e filial de acordo com o CNPJ da empresa."
WsMethod GETCADTES 	Description "Retorna o cadastro de TES de acordo com o CNPJ da empresa."
WsMethod GETCADTRP	Description "Retorna o cadastro de Transportadoras de acordo com o CNPJ da empresa."
WsMethod GETESTADO	Description "Retorna o cadastro de Estados de acordo com o CNPJ da empresa."
WsMethod GETPAIRF	Description "Retorna o cadastro de Países (Receita Federal) de acordo com o CNPJ da empresa."
WsMethod GETPAIBC	Description "Retorna o cadastro de Países (BACEN) de acordo com o CNPJ da empresa."
WsMethod GETMUNIC	Description "Retorna o cadastro de Municípios (IBGE) de acordo com o CNPJ da empresa."
WsMethod GETCLIENT	Description "Retorna o cadastro de Clientes de acordo com o CNPJ da empresa."
WsMethod GETFORNEC	Description "Retorna o cadastro de Fornecedores de acordo com o CNPJ da empresa."
WsMethod GETPRODUT	Description "Retorna o cadastro de Produtos de acordo com o CNPJ da empresa."
WsMethod GETCPGTOS	Description "Retorna o cadastro de Condição de pagamentos de acordo com o CNPJ da empresa."
WsMethod GETCADISS 	Description "Retorna o cadastro de ISS de acordo com o CNPJ da empresa."
WsMethod GETCADCCT 	Description "Retorna o cadastro de Centro de Custo de acordo com o CNPJ da empresa."
WsMethod GETCCONTA 	Description "Retorna o cadastro de Contas Contábeis de acordo com o CNPJ da empresa."
WsMethod GETSERIENF Description "Retorna a relação de séries disponíveis para geração de Nota Fiscal de Saída de acordo com o CNPJ da empresa."
WsMethod GETMENSNF	Description "Retorna a relação de mensagens padrão para geração de Nota Fiscal de Saída de acordo com o CNPJ da empresa."
WsMethod GETNFENTR	Description "Retorna as informações de Nota de Entrada para geração de Nota Fiscal de Devolução de Compra de acordo com o CNPJ da empresa."
WsMethod GETNFSAID	Description "Retorna a Nota Fiscal de Saída conforme Pedido de Venda de acordo com o CNPJ da empresa."
WsMethod GETPED		Description "Retorna o Pedido de de vendas de acordo com a Nota Fiscal de Saída e o CNPJ da empresa."
WsMethod GETLOTE	Description "Retorna a relação de lotes para Pedido de Venda de acordo com o CNPJ da empresa."
WsMethod GETARMAZ	Description "Retorna o cadastro de Armazens de acordo com o CNPJ da empresa."
WsMethod SETCLIENT	Description "Inclui um registro no cadastro de Clientes de acordo com o CNPJ da empresa."
WsMethod SETFORNEC	Description "Inclui um registro no cadastro de Fornecedores de acordo com o CNPJ da empresa."
WsMethod SETTRANSP	Description "Inclui um registro no cadastro de Transportadoras de acordo com o CNPJ da empresa."
WsMethod SETALTCLI	Description "Altera um registro no cadastro de Clientes de acordo com o CNPJ da empresa."
WsMethod SETALTFOR	Description "Altera um registro no cadastro de Fornecedores de acordo com o CNPJ da empresa."
WsMethod SETALTTRA	Description "Altera um registro no cadastro de Transportadoras de acordo com o CNPJ da empresa."
WsMethod SETNFSAID	Description "Gera um Pedido de vendas e uma Nota Fiscal de Saída de acordo com o CNPJ da empresa."
WsMethod SETPSEMNF	Description "Gera apenas Pedido de vendas de acordo com o CNPJ da empresa."
WsMethod SETNFSEMP	Description "Gera apenas Nota Fiscal de Saída (pedido já existente) de acordo com o CNPJ da empresa."
WsMethod GETIMP		Description "Retorna impostos do pedido informado de acordo com o CNPJ da empresa."

WsMethod GETVLDCAD	Description "Valida se o cadastro existe de acordo com cadastro selecionado e o CNPJ da empresa."

EndWsService
 
//Definição do Array Retorno
*------------------*
WSSTRUCT GETCUSTORET
*------------------*
WSDATA Codigo 		as String
WSDATA Descricao	as String
ENDWSSTRUCT

*------------------*
WSSTRUCT GETAMBRET
*------------------*
WSDATA Ambiente		as String
WSDATA Codigo 		as String
WSDATA Filial		as String
ENDWSSTRUCT

*----------------*
WSSTRUCT GETISSRET
*----------------*
WSDATA Codigo 		as String
WSDATA Descricao	as String
ENDWSSTRUCT

*----------------*
WSSTRUCT GETTESRET
*----------------*
WSDATA Tes	 		as String
WSDATA Descricao	as String
WSDATA CFOP			as String
WSDATA Finalidade	as String
ENDWSSTRUCT

*----------------*
WSSTRUCT GETPAGRET
*----------------*
WSDATA Codigo 		as String
WSDATA Descricao	as String
WSDATA Tipo			as String
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETDESTRET
*-----------------*
WSDATA Codigo 		as String
WSDATA Loja 		as String
WSDATA Nome			as String
WSDATA CNPJ			as String
ENDWSSTRUCT

*------------------*
WSSTRUCT GETTRANSRET
*------------------*
WSDATA Codigo 		as String
WSDATA Nome			as String
WSDATA CNPJ			as String
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETMENPADRET
*-------------------*
WSDATA Codigo 		as String
WSDATA Descricao	as String
ENDWSSTRUCT

*----------------*
WSSTRUCT SETSTSRET
*----------------*
WSDATA Codigo 		as String
WSDATA Descricao	as String
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETCTESRET
*-----------------*
WSDATA TES			as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETCCONRET
*-----------------*
WSDATA ContaContabil	as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETSERIRET
*-----------------*
WSDATA Serie			as String
WSDATA ProximoNumero	as String
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETTRSPRET
*-----------------*
WSDATA Transport		as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETPABCRET
*-----------------*
WSDATA PaisBacen		as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETPARFRET
*-----------------*
WSDATA PaisRecFederal	as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETMUNRET
*-----------------*
WSDATA Municipios	as Array of stDadoGet
ENDWSSTRUCT

*----------------*
WSSTRUCT GETCPGRET
*----------------*
WSDATA CondPag		as Array of stDadoGet
ENDWSSTRUCT

*----------------*
WSSTRUCT GETCLIRET
*----------------*
WSDATA Clientes		as Array of stDadoGet
ENDWSSTRUCT

*----------------*
WSSTRUCT GETFORRET
*----------------*
WSDATA Fornecedores	as Array of stDadoGet
ENDWSSTRUCT

*----------------*
WSSTRUCT GETPRDRET
*----------------*
WSDATA Produtos		as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETCISSRET
*-----------------*
WSDATA ISS			as Array of stDadoGet
ENDWSSTRUCT

*-----------------*
WSSTRUCT GETCCTRET
*-----------------*
WSDATA CentroCusto	as Array of stDadoGet
ENDWSSTRUCT

*------------------*
WSSTRUCT GETESTADRET
*------------------*
WSDATA Estados		as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETMENSNFRET
*-------------------*
WSDATA Mensagens	as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETNFENTRRET
*-------------------*
WSDATA NFEntrada	as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETNFSAIDRET
*-------------------*
WSDATA NFSaida		as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETPEDRET
*-------------------*
WSDATA Pedido		as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETARMAZRET
*-------------------*
WSDATA Armazens		as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETLOTERET
*-------------------*
WSDATA Lotes		as Array of stDadoGet
ENDWSSTRUCT

*-------------------*
WSSTRUCT GETVLDCADRET
*-------------------*
WSDATA Valida		as Array of stDadoGet
ENDWSSTRUCT

*----------------*
WSSTRUCT GETIMPRET
*----------------*
WSDATA Impostos		as Array of stDadoSet
ENDWSSTRUCT

*-----------------*
WSSTRUCT stDadoSet
*-----------------*
WSDATA Campo		as String
WSDATA Conteudo		as String
ENDWSSTRUCT

*------------------*
WSSTRUCT stDadosSet
*------------------*
WSDATA Dado			as Array of stDadoSet
ENDWSSTRUCT

*-----------------*
WSSTRUCT stDadoGet
*-----------------*
WSDATA Campo		as String
ENDWSSTRUCT

*------------------*
WSSTRUCT stDadosGet
*------------------*
WSDATA Dado			as Array of stDadoGet
ENDWSSTRUCT

*-----------------------------------------------------------------------------*
WsMethod GETCUSTO WsReceive cCodAmb,cCodEmp wsSend aRetCusto WsService GTFLG001
*-----------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)


cQry := " Select *
cQry += " From "+cCodAmb+".dbo.CTT"+cCdEmp+"0
cQry += " Where D_E_L_E_T_ <> '*'

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetCusto,WSClassNew("GETCUSTORET"))
	aTail(::aRetCusto):Codigo		:= ALLTRIM(TMP->CTT_CUSTO)
	aTail(::aRetCusto):Descricao	:= ALLTRIM(TMP->CTT_DESC01)
	TMP->(DbSkip())
EndDo
Return .T.

*----------------------------------------------------------------*
WsMethod GETAMB WsReceive cCNPJ wsSend aRetAmb WsService GTFLG001
*----------------------------------------------------------------*
Local cDbAlias := GetSrvProfString('DBALIAS','')
//Caso parametro esteja em branco encerra a rotina.
If EMPTY(cCNPJ)
	Return .F.
EndIf

cQry := " Select * "
If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	cQry += " From P11_01.dbo.TotvsSigamatAmb "
	cQry += " Where M0_CGC = '" + cCNPJ + "' "
	cQry += " AND AMB <> 'P11_TESTE' "
Else
    If! "HOM" $ cDbAlias
	    cQry += " From P12_01.dbo.TotvsSigamatAmb "
	    cQry += " Where M0_CGC = '" + cCNPJ + "' "
	    conout("GTFLG001 - Executando em ambiente: "+GetEnvServer())
	    cQry += " AND AMB <> 'P12_TESTE' "//produção
	Else 
	    cQry += " From P12_01_HOM.dbo.TotvsSigamatAmb "
	    cQry += " Where M0_CGC = '" + cCNPJ + "' "
	    conout("GTFLG001 - Executando em ambiente: "+GetEnvServer())
	    cQry += " AND AMB <> 'P12_TESTE' "//homologa��o
	EndIf 	
Endif

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetAmb,WSClassNew("GETAMBRET"))
	aTail(::aRetAmb):Ambiente	:= Iif("HOM" $ cDbAlias,ALLTRIM(TMP->AMB)+"_HOM",ALLTRIM(TMP->AMB))
	aTail(::aRetAmb):Codigo		:= ALLTRIM(TMP->M0_CODIGO)
	aTail(::aRetAmb):Filial		:= ALLTRIM(TMP->M0_CODFIL)
	TMP->(DbSkip())
EndDo

Return .T.

*-------------------------------------------------------------------------*
WsMethod GETISS WsReceive cCodAmb,cCodEmp wsSend aRetIss WsService GTFLG001
*-------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SX5"+cCdEmp+"0
cQry += " Where D_E_L_E_T_ <> '*'
cQry += "		AND X5_TABELA = '60'

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetIss,WSClassNew("GETISSRET"))
	aTail(::aRetIss):Codigo		:= ALLTRIM(TMP->X5_CHAVE)
	aTail(::aRetIss):Descricao	:= ALLTRIM(TMP->X5_DESCRI)
	TMP->(DbSkip())
EndDo
Return .T.

*----------------------------------------------------------------------------*
WsMethod GETTES WsReceive cCodAmb,cCodEmp wsSend aRetTes WsService GTFLG001
*----------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf  

//Empresa e filial                          
cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

//Tratamento para quando mandar o codigo da empresa no GTCORP.
If ALLTRIM(cCodAmb) == ALLTRIM(cCodEmp)
	cQry := "Select A1_P_BANCO,A1_P_CODIG,A1_P_CODFI 
	cQry += " From SQLTB717_P11.GTCORP_P11.dbo.SA1"+Left(cCodEmp,2)+"0 
	cQry += " Where D_E_L_E_T_ <> '*' AND A1_P_BANCO <> '' AND A1_COD = '"+SUBSTR(ALLTRIM(cCodEmp),3,6)+"' AND A1_LOJA = '"+Right(cCodEmp,2)+"' "
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)
	
	If TMP->(EOF())
		Return .F.
	EndIf
	cCodAmb:= ALLTRIM(TMP->A1_P_BANCO)
	cCdEmp := ALLTRIM(TMP->A1_P_CODIG)
	cCdfil := ALLTRIM(TMP->A1_P_CODFI)
EndIf            

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SZ2YY0
cQry += " Where D_E_L_E_T_ <> '*'
cQry += "		AND Z2_EMPRESA = '"+cCdEmp+cCdfil+"'
cQry += "  		AND Z2_TES in (Select F4_CODIGO From "+cCodAmb+".dbo.SF4YY0 Where D_E_L_E_T_ <> '*' AND F4_MSBLQL <> '1' )"        

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetTes,WSClassNew("GETTESRET"))
	aTail(::aRetTes):TES   		:= ALLTRIM(TMP->Z2_TES)
	aTail(::aRetTes):Descricao	:= ALLTRIM(TMP->Z2_DESCRI)
	aTail(::aRetTes):CFOP		:= ALLTRIM(TMP->Z2_CFOP)
	aTail(::aRetTes):Finalidade	:= ALLTRIM(TMP->Z2_FINALID)

	TMP->(DbSkip())
EndDo
Return .T.

*-------------------------------------------------------------------------*
WsMethod GETPAG WsReceive cCodAmb,cCodEmp wsSend aRetPag WsService GTFLG001
*-------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf    

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SE4"+cCdEmp+"0
cQry += " Where D_E_L_E_T_ <> '*'

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetPag,WSClassNew("GETPAGRET"))
	aTail(::aRetPag):Codigo		:= ALLTRIM(TMP->E4_CODIGO)
	aTail(::aRetPag):Descricao	:= ALLTRIM(TMP->E4_DESCRI)
	aTail(::aRetPag):Tipo		:= ALLTRIM(TMP->E4_TIPO)
	TMP->(DbSkip())
EndDo
Return .T.   
                                                                           
*---------------------------------------------------------------------------*
WsMethod GETDEST WsReceive cCodAmb,cCodEmp wsSend aRetDest WsService GTFLG001
*---------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf    

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SA1"+cCdEmp+"0
cQry += " Where D_E_L_E_T_ <> '*'

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetDest,WSClassNew("GETDESTRET"))
	aTail(::aRetDest):Codigo		:= ALLTRIM(TMP->A1_COD)
	aTail(::aRetDest):Loja  		:= ALLTRIM(TMP->A1_LOJA)
	aTail(::aRetDest):Nome			:= ALLTRIM(TMP->A1_NOME)
	aTail(::aRetDest):CNPJ			:= ALLTRIM(TMP->A1_CGC)
	TMP->(DbSkip())
EndDo
Return .T.

*-----------------------------------------------------------------------------*
WsMethod GETTRANS WsReceive cCodAmb,cCodEmp wsSend aRetTrans WsService GTFLG001
*-----------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf    

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SA4"+cCdEmp+"0
cQry += " Where D_E_L_E_T_ <> '*' " 

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetTrans,WSClassNew("GETTRANSRET"))
	aTail(::aRetTrans):Codigo	:= ALLTRIM(TMP->A4_COD)
	aTail(::aRetTrans):Nome		:= ALLTRIM(TMP->A4_NOME)
	aTail(::aRetTrans):CNPJ		:= ALLTRIM(TMP->A4_CGC)
	TMP->(DbSkip())
EndDo
Return .T.

*---------------------------------------------------------------------------------*
WsMethod GETMENPAD WsReceive cCodAmb,cCodEmp wsSend aRetMensPad WsService GTFLG001
*---------------------------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cCodAmb) .or. EMPTY(cCodEmp)
	Return .F.
EndIf    

cCdEmp := Left(cCodEmp,2)
cCdfil := Right(cCodEmp,2)

cQry := " Select *
cQry += " From "+cCodAmb+".dbo.SM4YY0
cQry += " Where D_E_L_E_T_ <> '*'

If Select("TMP") <> 0
	TMP->(DbCloseArea())
EndIf     

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

TMP->(DBGoTop())
While TMP->(!EOF())
	aAdd(::aRetMensPad,WSClassNew("GETMENPADRET"))
	aTail(::aRetMensPad):Codigo		:= ALLTRIM(TMP->M4_CODIGO)
	aTail(::aRetMensPad):Descricao	:= ALLTRIM(TMP->M4_DESCR)
	TMP->(DbSkip())
EndDo
Return .T.

*----------------------------------------------------------------*
WsMethod SETCAN WsReceive cChave wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cChave)
	Return .F.
EndIf    

cCdEmp	:= SubStr(cChave,1,2)
cCdfil	:= SubStr(cChave,3,2)
cCod	:= SubStr(cChave,5,10)

cUpd := " Update SQLTB717.Portal_Cliente.dbo.ZF0020 "        
cUpd += " Set ZF0_STATUS = 'C'
cUpd += " Where ZF0_CODEMP = '"+cCdEmp+"' AND ZF0_CODFIL = '"+cCdfil+"' AND ZF0_CODIGO = '"+cCod+"'

TCSQLEXEC(cUpd)

aAdd(::aRetSts,WSClassNew("SETSTSRET"))
aTail(::aRetSts):Codigo		:= "Ok"
aTail(::aRetSts):Descricao	:= "Cancelado!"

Return .T.

*----------------------------------------------------------------*
WsMethod SETFIM WsReceive cChave wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------*
//Caso um dos parametros estejam em branco encerra a rotina.
If EMPTY(cChave)
	Return .F.
EndIf    

cCdEmp	:= SubStr(cChave,1,2)
cCdfil	:= SubStr(cChave,3,2)
cCod	:= SubStr(cChave,5,10)

cUpd := " Update SQLTB717.Portal_Cliente.dbo.ZF0020 "        
cUpd += " Set ZF0_STATUS = 'S'

cUpd += " Where ZF0_CODEMP='"+cCdEmp+"' AND ZF0_CODFIL = '"+cCdfil+"' AND ZF0_CODIGO = '"+cCod+"'

TCSQLEXEC(cUpd)

aAdd(::aRetSts,WSClassNew("SETSTSRET"))
aTail(::aRetSts):Codigo		:= "Ok"
aTail(::aRetSts):Descricao	:= "Solucionado!"

Return .T.


*-----------------------------------------------------------------------------*
WsMethod GETCADTES WsReceive cChave,DadosGet wsSend aRetCTES WsService GTFLG001
*-----------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCTES,WSClassNew("GETCTESRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCTES):TES	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCTES,WSClassNew("GETCTESRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCTES):TES	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select *
	cQry += " From "+aEmp[3]+".dbo." + RetTabName("SZ2")
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += "		AND Z2_EMPRESA = '"+aEmp[1]+aEmp[2]+"'
	cQry += "  		AND Z2_TES in (Select F4_CODIGO From "+aEmp[3]+".dbo."+RetTabName("SF4")+" Where D_E_L_E_T_ <> '*' AND F4_MSBLQL <> '1' )   

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf
    
	Conout(cQry)

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCTES,WSClassNew("GETCTESRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCTES):TES	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCTES,WSClassNew("GETCTESRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCTES):TES	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE
Return .T.

*--------------------------------------------------------------------------------*
WsMethod GETCLIENT WsReceive cChave,DadosGet wsSend aRetCliente WsService GTFLG001
*--------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCliente,WSClassNew("GETCLIRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCliente):Clientes	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCliente,WSClassNew("GETCLIRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCliente):Clientes	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SA1") + " "
	cQry += " Where D_E_L_E_T_ <> '*' And A1_MSBLQL <> '1' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCliente,WSClassNew("GETCLIRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCliente):Clientes	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETCLIENT WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, oServ, aCpsObrig := {}
Private lMsErroAuto := .F.

aAdd(aCpsObrig,"A1_NOME")
aAdd(aCpsObrig,"A1_NREDUZ")
aAdd(aCpsObrig,"A1_TIPO")
aAdd(aCpsObrig,"A1_END")
aAdd(aCpsObrig,"A1_EST")
aAdd(aCpsObrig,"A1_MUN")
aAdd(aCpsObrig,"A1_COD_MUN")
//aAdd(aCpsObrig,"A1_CODPAIS")
//aAdd(aCpsObrig,"A1_NATUREZ")

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado n�o pertence a nenhuma empresa do sistema."
		Break
	EndIf
	
	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])

	RegToMemory("SA1",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata030(x,y)},aCab,3)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro incluido com sucesso. Registro: " + SA1->A1_COD)

	RPCDisconnect(oServ)
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETALTCLI WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, oServ, aCpsObrig := {}, cChSeek := ""
Private lMsErroAuto := .F.

aAdd(aCpsObrig,"A1_COD")
aAdd(aCpsObrig,"A1_LOJA")

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf
	
	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])

	RegToMemory("SA1",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
			If (nPos := aScan(aCpsObrig,::DadosSet:Dado[i]:Campo)) # 0
				cChSeek += AvKey(xConteudo,aCpsObrig[nPos])
			EndIf
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf

	SA1->(DbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1")+cChSeek))
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Registro não localizado."
		Break
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata030(x,y)},aCab,4)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro alterado com sucesso. Registro: " + SA1->A1_COD)

	RPCDisconnect(oServ)
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETALTFOR WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, oServ, aCpsObrig := {}, cChSeek := ""
Private lMsErroAuto := .F.

aAdd(aCpsObrig,"A2_COD")
aAdd(aCpsObrig,"A2_LOJA")

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf
	
	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2],,,"COM")

	RegToMemory("SA2",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
			If (nPos := aScan(aCpsObrig,::DadosSet:Dado[i]:Campo)) # 0
				cChSeek += AvKey(xConteudo,aCpsObrig[nPos])
			EndIf
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf

	SA2->(DbSetOrder(1))
	If !SA2->(DbSeek(xFilial("SA2")+cChSeek))
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Registro não localizado."
		Break
	EndIf

	If aScan(aCab,{|x| x[1] == "A2_ID_FBFN"}) == 0
		aAdd(aCab,{"A2_ID_FBFN", "3", NIL})
	EndIf
	If aScan(aCab,{|x| x[1] == "A2_FABRICA"}) == 0 .AND. (nPos := aScan(aCab,{|x| x[1] == "A2_ID_FBFN"})) # 0
		aAdd(aCab,{"A2_FABRICA", Left(aCab[nPos][2],1), NIL})
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata020(x,y)},aCab,4)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro alterado com sucesso. Registro: " + SA2->A2_COD)

	RPCDisconnect(oServ)
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETALTTRA WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, oServ, aCpsObrig := {}, cChSeek := ""
Private lMsErroAuto := .F.

aAdd(aCpsObrig,"A4_COD")

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf
	
	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])

	RegToMemory("SA4",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
			If (nPos := aScan(aCpsObrig,::DadosSet:Dado[i]:Campo)) # 0
				cChSeek += AvKey(xConteudo,aCpsObrig[nPos])
			EndIf
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf

	SA4->(DbSetOrder(1))
	If !SA4->(DbSeek(xFilial("SA4")+cChSeek))
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Registro não localizado."
		Break
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata050(x,y)},aCab,4)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro alterado com sucesso. Registro: " + SA4->A4_COD)

	RPCDisconnect(oServ)
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------------*
WsMethod GETPRODUT WsReceive cChave,DadosGet wsSend aRetProd WsService GTFLG001
*-----------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetProd,WSClassNew("GETPRDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetProd):Produtos	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetProd,WSClassNew("GETPRDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetProd):Produtos	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SB1") + " "
	cQry += " Where D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetProd,WSClassNew("GETPRDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetProd):Produtos	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetProd,WSClassNew("GETPRDRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetProd):Produtos	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------*
WsMethod GETFORNEC WsReceive cChave,DadosGet wsSend aRetFornece WsService GTFLG001
*--------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetFornece,WSClassNew("GETFORRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetFornece):Fornecedores	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetFornece,WSClassNew("GETFORRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetFornece):Fornecedores	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SA2") + " "
	cQry += " Where D_E_L_E_T_ <> '*' And A2_MSBLQL <> '1' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetFornece,WSClassNew("GETFORRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetFornece):Fornecedores	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetFornece,WSClassNew("GETFORRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetFornece):Fornecedores	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETFORNEC WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, aCpsObrig := {}
Private lMsErroAuto := .F.

aAdd(aCpsObrig,"A2_NOME")
aAdd(aCpsObrig,"A2_TIPO")
aAdd(aCpsObrig,"A2_CGC")
aAdd(aCpsObrig,"A2_NREDUZ")
aAdd(aCpsObrig,"A2_END")
aAdd(aCpsObrig,"A2_EST")
aAdd(aCpsObrig,"A2_MUN")
aAdd(aCpsObrig,"A2_COD_MUN")
aAdd(aCpsObrig,"A2_CODPAIS")
aAdd(aCpsObrig,"A2_CONTA")
//aAdd(aCpsObrig,"A2_PAIS")
//aAdd(aCpsObrig,"A2_ID_FBFN") - Preenchimento automatizado
//aAdd(aCpsObrig,"A2_FABRICA") - Preenchimento automatizado

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf

	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i
	
	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2],,,"COM")

	RegToMemory("SA2",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf

	If aScan(aCab,{|x| x[1] == "A2_ID_FBFN"}) == 0
		aAdd(aCab,{"A2_ID_FBFN", "3", NIL})
	EndIf
	If aScan(aCab,{|x| x[1] == "A2_FABRICA"}) == 0 .AND. (nPos := aScan(aCab,{|x| x[1] == "A2_ID_FBFN"})) # 0
		aAdd(aCab,{"A2_FABRICA", Left(aCab[nPos][2],1), NIL})
	EndIf
	If aScan(aCab,{|x| x[1] == "A2_PAIS"}) == 0 
		If (nPos := aScan(aCab,{|x| x[1] == "A2_CODPAIS"})) # 0
			aAdd(aCab,{"A2_PAIS", SubStr(aCab[nPos][2],2,3) , NIL})
		EndIf
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata020(x,y)},aCab,3)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro incluido com sucesso. Registro: " + SA2->A2_COD)
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------------*
WsMethod GETCPGTOS WsReceive cChave,DadosGet wsSend aRetCPag WsService GTFLG001
*-----------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCPag,WSClassNew("GETCPGRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCPag):CondPag	:= aDado
		Break
	EndIf
	
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCPag,WSClassNew("GETCPGRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado n�o pertence a nenhuma empresa do sistema."
		aTail(::aRetCPag):CondPag	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i
    
    //Cria a condição de pagamento TIPO 9 por porcentagem, caso não exista.
	cQry := " Select COUNT(*) as QTDETIPO "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SE4") + " "
	cQry += " Where D_E_L_E_T_ <> '*' AND E4_TIPO <> '9' "
	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf
	If TCSQLExec(cQry) < 0
		aAdd(::aRetCPag,WSClassNew("GETCPGRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados. "+cQry+"."
		aTail(::aRetCPag):CondPag	:= aDado
		Break
	Else
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)
		If TMP->QTDETIPO >= 1
			TCSQLEXEC("INSERT INTO " + aEmp[3] + ".dbo." + RetTabName("SE4") + " (E4_FILIAL,E4_CODIGO,E4_TIPO,E4_COND,E4_DESCRI,R_E_C_N_O_)"+;
						"VALUES('01','69',9,'%','A DEFINIR POR %',(SELECT ISNULL(MAX(R_E_C_N_O_)+1,1) FROM " + aEmp[3] + ".dbo." + RetTabName("SE4") + "))")
		EndIf
	EndIf

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SE4") + " "
	cQry += " Where D_E_L_E_T_ <> '*' AND (E4_TIPO <> '9' OR (E4_TIPO = '9' AND E4_COND = '%')) "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCPag,WSClassNew("GETCPGRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCPag):CondPag	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCPag,WSClassNew("GETCPGRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCPag):CondPag	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------------*
WsMethod GETCADISS WsReceive cChave,DadosGet wsSend aRetCISS WsService GTFLG001
*-----------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCISS,WSClassNew("GETCISSRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCISS):ISS	:= aDado
		Break
	EndIf
	
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCISS,WSClassNew("GETCISSRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCISS):ISS	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select X5_FILIAL, X5_TABELA, X5_CHAVE, X5_DESCRI, X5_DESCSPA, X5_DESCENG, D_E_L_E_T_, R_E_C_N_O_ "
	cQry += " From "+ aEmp[3] +".dbo.SX5"+ aEmp[1] +"0 "
	cQry += " Where D_E_L_E_T_ <> '*' "
	cQry += "		AND X5_TABELA = '60' "		
    If TCSQLExec("select * from "+aEmp[3]+"..CCQ"+aEmp[1]+"0") >= 0
		cQry += "UNION ALL"
		cQry += " SELECT '', '', CCQ_CODIGO AS X5_CHAVE, CCQ_DESC AS X5_DESCRI,'','', D_E_L_E_T_, R_E_C_N_O_ "
   		cQry += " From "+ aEmp[3] +".dbo.CCQ"+ aEmp[1] +"0 "
		cQry += " Where D_E_L_E_T_ <> '*' "
    EndIf 

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCISS,WSClassNew("GETCISSRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCISS):ISS	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCISS,WSClassNew("GETCISSRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCISS):ISS	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------------*
WsMethod GETCADCCT WsReceive cChave,DadosGet wsSend aRetCCT WsService GTFLG001
*-----------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCCT,WSClassNew("GETCCTRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCCT):CentroCusto	:= aDado
		Break
	EndIf
	
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCCT,WSClassNew("GETCCTRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCCT):CentroCusto	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("CTT") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "
	cQry += "		AND CTT_BLOQ <> '1'"
    conout(cQry)
	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCCT,WSClassNew("GETCCTRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCCT):CentroCusto	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCCT,WSClassNew("GETCCTRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCCT):CentroCusto	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*------------------------------------------------------------------------------*
WsMethod GETCCONTA WsReceive cChave,DadosGet wsSend aRetCCont WsService GTFLG001
*------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCCont,WSClassNew("GETCCONRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCCont):ContaContabil	:= aDado
		Break
	EndIf
	
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCCont,WSClassNew("GETCCONRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCCont):ContaContabil	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("CT1") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCCont,WSClassNew("GETCCONRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCCont):ContaContabil	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCCont,WSClassNew("GETCCONRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCCont):ContaContabil	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-------------------------------------------------------------------------------*
WsMethod GETCADTRP WsReceive cChave,DadosGet wsSend aRetTransp WsService GTFLG001
*-------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetTransp,WSClassNew("GETTRSPRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetTransp):Transport	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetTransp,WSClassNew("GETTRSPRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetTransp):Transport	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SA4") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetTransp,WSClassNew("GETTRSPRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetTransp):Transport	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetTransp,WSClassNew("GETTRSPRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetTransp):Transport	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-------------------------------------------------------------------------------*
WsMethod GETESTADO WsReceive cChave,DadosGet wsSend aRetEst WsService GTFLG001
*-------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetEst,WSClassNew("GETESTADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetEst):Estados	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetEst,WSClassNew("GETESTADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetEst):Estados	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SX5") + " "
	cQry += " Where X5_TABELA = '12' AND D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetEst,WSClassNew("GETESTADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetEst):Estados	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetEst,WSClassNew("GETESTADRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetEst):Estados	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-------------------------------------------------------------------------------*
WsMethod GETPAIBC WsReceive cChave,DadosGet wsSend aRetPaiBC WsService GTFLG001
*-------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetPaiBC,WSClassNew("GETPABCRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetPaiBC):PaisBacen	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetPaiBC,WSClassNew("GETPABCRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetPaiBC):PaisBacen	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("CCH") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetPaiBC,WSClassNew("GETPABCRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetPaiBC):PaisBacen	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetPaiBC,WSClassNew("GETPABCRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetPaiBC):PaisBacen	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-------------------------------------------------------------------------------*
WsMethod GETPAIRF WsReceive cChave,DadosGet wsSend aRetPaiRF WsService GTFLG001
*-------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetPaiRF,WSClassNew("GETPARFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetPaiRF):PaisRecFederal	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetPaiRF,WSClassNew("GETPARFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetPaiRF):PaisRecFederal	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SYA") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetPaiRF,WSClassNew("GETPARFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetPaiRF):PaisRecFederal	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetPaiRF,WSClassNew("GETPARFRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetPaiRF):PaisRecFederal	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------------*
WsMethod GETMUNIC WsReceive cChave,cEstado,DadosGet wsSend aRetCodMun WsService GTFLG001
*--------------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetCodMun,WSClassNew("GETMUNRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetCodMun):Municipios	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetCodMun,WSClassNew("GETMUNRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetCodMun):Municipios	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("CC2") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "
	If !Empty(cEstado)
		cQry += " AND CC2_EST = '" + cEstado + "' "
	EndIf

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetCodMun,WSClassNew("GETMUNRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetCodMun):Municipios	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetCodMun,WSClassNew("GETMUNRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetCodMun):Municipios	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------*
WsMethod GETSERIENF WsReceive cChave wsSend aRetSeries WsService GTFLG001
*-----------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSeries,WSClassNew("GETSERIRET"))
		aTail(::aRetSeries):Serie			:= "Erro"
		aTail(::aRetSeries):ProximoNumero	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SX5") + " "
	cQry += " Where X5_TABELA = '01' AND D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetSeries,WSClassNew("GETSERIRET"))
		aTail(::aRetSeries):Serie			:= "Erro"
		aTail(::aRetSeries):ProximoNumero	:= " Erro na busca de registros no Banco de Dados."
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetSeries,WSClassNew("GETSERIRET"))
		aTail(::aRetSeries):Serie			:= ALLTRIM(TMP->X5_CHAVE)
		aTail(::aRetSeries):ProximoNumero	:= ALLTRIM(TMP->X5_DESCRI)
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*---------------------------------------------------------------------------------*
WsMethod GETMENSNF WsReceive cChave,DadosGet wsSend aRetMensNF WsService GTFLG001
*---------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetMensNF,WSClassNew("GETMENSNFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetMensNF):Mensagens	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetMensNF,WSClassNew("GETMENSNFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetMensNF):Mensagens	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SM4") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetMensNF,WSClassNew("GETMENSNFRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetMensNF):Mensagens	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetMensNF,WSClassNew("GETMENSNFRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetMensNF):Mensagens	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------------------------*
WsMethod GETNFENTR WsReceive cChave,cFornecedor,cLoja,cProduto wsSend aRetNFEntr WsService GTFLG001
*--------------------------------------------------------------------------------------------------*
Local i, aDado := {}
Local aCampos := {"D1_DOC","D1_SERIE","D1_TIPO","D1_ITEM","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL"}
Local cDbAlias := GetSrvProfString('DBALIAS','')

BEGIN SEQUENCE
    conout("BuscaEmpresas")
	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetNFEntr,WSClassNew("GETNFENTRRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetNFEntr):NFEntrada	:= aDado
		Break
	EndIf

	cQry := "	SELECT	"
	cQry += "		SD1.R_E_C_N_O_ D1_REC_WT,	"
	cQry += "		SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO, SF1.F1_DOC, SF1.F1_SERIE,	"
	cQry += "		SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_TIPO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FILIAL, SD1.D1_FORNECE,	"
	cQry += "		SD1.D1_LOJA, SD1.D1_QTDEDEV, SD1.D1_VALDEV, SD1.D1_ORIGLAN, SD1.D1_TES,	"
	cQry += "		SD1.D1_ITEM, SD1.D1_UM, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL	"
	If Alltrim(cDbAlias) == Alltrim(aEmp[3])
		cQry += "		FROM	"  +RetTabName("SF1")+" SF1, "
		cQry +=  					RetTabName("SD1")+"	SD1	"			
	Else	
		cQry += "		FROM	"  +	aEmp[3] + ".dbo." + RetTabName("SF1")+" SF1, "
		cQry +=  						aEmp[3] + ".dbo." + RetTabName("SD1")+"	SD1	"			
	EndIf	
	cQry += "		WHERE "
	cQry += "			SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND	"
	cQry += "			SF1.F1_FORNECE = '"+cFornecedor+"' AND	"
	cQry += "			SF1.F1_LOJA = '"+cLoja+"' AND	"
	cQry += "			SF1.D_E_L_E_T_=' ' AND	"
	cQry += "			SD1.D1_FILIAL='"+xFilial("SD1")+"' AND	"
	cQry += "			SD1.D1_FORNECE=SF1.F1_FORNECE AND	"
	cQry += "			SD1.D1_LOJA=SF1.F1_LOJA AND	"
	cQry += "			SD1.D1_DOC=SF1.F1_DOC AND	"
	cQry += "			SD1.D1_SERIE=SF1.F1_SERIE AND	"
	cQry += "			SD1.D1_TIPO=SF1.F1_TIPO AND	"
	cQry += "			SD1.D1_COD='"+cProduto+"' AND	"
	cQry += "			SD1.D1_ORIGLAN<>'LF' AND	"
	cQry += "			SD1.D_E_L_E_T_=' ' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     
    //conout("..."+cQry)
	If TCSQLExec(cQry) < 0
	    conout("Erro na busca de registros no Banco de Dados.")
		aAdd(::aRetNFEntr,WSClassNew("GETNFENTRRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetNFEntr):NFEntrada	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQry)),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	If! TMP->(EOF())
		While TMP->(!EOF())
			aAdd(::aRetNFEntr,WSClassNew("GETNFENTRRET"))
			aDado := {}
			For i := 1 To Len(aCampos)
				aAdd(aDado,WSClassNew("stDadoGet"))
				aTail(aDado):Campo	:= ALLTRIM(cValToChar(TMP->&(aCampos[i])))
			Next i
			aTail(::aRetNFEntr):NFEntrada	:= aDado
			TMP->(DbSkip())
		EndDo
	Else
 		//conout("Dados n�o encontrados")
		aAdd(::aRetNFEntr,WSClassNew("GETNFENTRRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Verifique os par�metros informados. N�o foram encontrados registros para a pesquisa."
		aTail(::aRetNFEntr):NFEntrada	:= aDado
	EndIf 	

	
END SEQUENCE
conout("fim")
Return .T.

*-----------------------------------------------------------------------------------------------*
WsMethod GETLOTE WsReceive cChave,cFornecedor,cProduto,cLocal wsSend aRetLote WsService GTFLG001
*-----------------------------------------------------------------------------------------------*
Local i, aDado := {}
Local aCampos := {"D5_LOTECTL","D5_NUMSEQ"}

BEGIN SEQUENCE

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetLote,WSClassNew("GETLOTERET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetLote):Lotes	:= aDado
		Break
	EndIf
	
	cQry := " SELECT D5_FILIAL,  D5_PRODUTO, "
	cQry +=        " D5_LOCAL,   D5_LOTECTL, "
	cQry +=        " D5_NUMLOTE, D5_NUMSEQ,  "
	cQry +=        " D5_CLIFOR,  D5_LOJA,    "
	cQry +=        " D5_ORIGLAN, D5_DOC,     "
	cQry +=        " D5_SERIE,   "
	cQry +=        " SD5.R_E_C_N_O_ RECNOSD5 "
	cQry += " FROM " + aEmp[3] + ".dbo." + RetTabName('SD5') + ' SD5 '
	cQry += " WHERE "
	cQry +=         " SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
	cQry +=     " AND SD5.D5_PRODUTO = '"+cProduto+"'"
	cQry +=     " AND SD5.D5_LOCAL   = '"+cLocal+"'"
	cQry +=     " AND SD5.D5_ESTORNO  = ' '"
	cQry +=     " AND SD5.D5_ORIGLAN <> 'MAN'"
	cQry +=     " AND SD5.D5_ORIGLAN <= '500'"
	cQry +=     " AND SD5.D5_CLIFOR  <> '"+cFornecedor+"' "
	cQry +=     " AND SD5.D_E_L_E_T_  = ' '"

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetLote,WSClassNew("GETLOTERET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetLote):Lotes	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetLote,WSClassNew("GETLOTERET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetLote):Lotes	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*------------------------------------------------------------------------------*
WsMethod GETARMAZ WsReceive cChave,DadosGet wsSend aRetArmaz WsService GTFLG001
*------------------------------------------------------------------------------*
Local i, aCampos := {}, aDado := {}

BEGIN SEQUENCE
	If ValType(::DadosGet:Dado) <> "A"
		aAdd(::aRetArmaz,WSClassNew("GETARMAZRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Estrutura de dados não compatível."
		aTail(::aRetArmaz):Armazens	:= aDado
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetArmaz,WSClassNew("GETARMAZRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetArmaz):Armazens	:= aDado
		Break
	EndIf

	For i := 1 To Len(::DadosGet:Dado)
		If !Empty(::DadosGet:Dado[i]:Campo)
			aadd(aCampos,::DadosGet:Dado[i]:Campo)
		EndIf
	Next i

	cQry := " Select * "
	cQry += " From " + aEmp[3] + ".dbo." + RetTabName("NNR") + " "
	cQry += " Where D_E_L_E_T_ <> '*' "

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetArmaz,WSClassNew("GETARMAZRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetArmaz):Armazens	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetArmaz,WSClassNew("GETARMAZRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetArmaz):Armazens	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------*
WsMethod GETNFSAID WsReceive cChave,cPedVenda wsSend aRetNFSaid WsService GTFLG001
*--------------------------------------------------------------------------------*
Local i, aDado := {}
Local aCampos := {"D2_DOC","D2_SERIE"}

BEGIN SEQUENCE

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetNFSaid,WSClassNew("GETNFSAIDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetNFSaid):NFSaida	:= aDado
		Break
	EndIf

	cQry := "	SELECT * FROM	"  + aEmp[3] + ".dbo." + RetTabName("SD2")	
	cQry += "	WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND	"
	cQry += "	D2_PEDIDO = '"+cPedVenda+"' AND	"
	cQry += "	D_E_L_E_T_=' '	"

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetNFSaid,WSClassNew("GETNFSAIDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetNFSaid):NFSaida	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetNFSaid,WSClassNew("GETNFSAIDRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetNFSaid):NFSaida	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------*
WsMethod GETPED WsReceive cChave,cNfsaida,cSerie wsSend aRetPed WsService GTFLG001
*--------------------------------------------------------------------------------*
Local i, aDado := {}
Local aCampos := {"D2_PEDIDO"}

BEGIN SEQUENCE

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetPed,WSClassNew("GETPEDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetPed):Pedido	:= aDado
		Break
	EndIf

	cQry := "	SELECT * FROM	"  + aEmp[3] + ".dbo." + RetTabName("SD2")	
	cQry += "	WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND	"
	cQry += "	D2_DOC = '"+cNfsaida+"' AND D2_SERIE = '"+cSerie+"' AND	"
	cQry += "	D_E_L_E_T_=' '	"

	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf     

	If TCSQLExec(cQry) < 0
		aAdd(::aRetPed,WSClassNew("GETPEDRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca de registros no Banco de Dados."
		aTail(::aRetPed):Pedido	:= aDado
		Break
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)

	TMP->(DBGoTop())
	While TMP->(!EOF())
		aAdd(::aRetPed,WSClassNew("GETPEDRET"))
		aDado := {}
		For i := 1 To Len(aCampos)
			aAdd(aDado,WSClassNew("stDadoGet"))
			aTail(aDado):Campo	:= ALLTRIM(TMP->&(aCampos[i]))
		Next i
		aTail(::aRetPed):Pedido	:= aDado
		TMP->(DbSkip())
	EndDo
END SEQUENCE

Return .T.

*----------------------------------------------------------------------------*
WsMethod SETTRANSP WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*----------------------------------------------------------------------------*
Local aCab := {}, i, aCpsObrig := {}
Private lMsErroAuto := .F.

//aAdd(aCpsObrig,"A4_COD")
aAdd(aCpsObrig,"A4_NOME")

BEGIN SEQUENCE
	If ValType(::DadosSet:Dado) <> "A"
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
		Break
	EndIf

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
		Break
	EndIf
	
	For i := 1 To Len(aCpsObrig)
		If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
			aAdd(::aRetSts,WSClassNew("SETSTSRET"))
			aTail(::aRetSts):Codigo		:= "Erro"
			aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
			Break
		EndIf
	Next i

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])

	RegToMemory("SA4",.T.,.T.,.F.,,)

	For i := 1 To Len(::DadosSet:Dado)
		If !Empty(::DadosSet:Dado[i]:Campo)
			cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
			Do Case
				Case cTipo == "C"
					xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "D"
					xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
				Case cTipo == "N"
					xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
				End Case
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		EndIf
	Next i

	If Len(aCab) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
		Break
	EndIf
	
	If aScan(aCab,{|x| x[1] == "A4_COD"}) == 0
		//cQry := " Select COUNT(*) AS TOTREG "
		//cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SA4") + " "
		//cQry += " Where D_E_L_E_T_ <> '*' "	

		cQry := " Select TOP 1 A4_COD "
		cQry += " From " + aEmp[3] + ".dbo." + RetTabName("SA4") + " "
		cQry += " ORDER BY A4_COD DESC "

		If Select("TMP") <> 0
			TMP->(DbCloseArea())
		EndIf     

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)
		TMP->(DBGoTop())
		//xConteudo := StrZero(Val(Soma1(cValToChar(TMP->TOTREG))),TAMSX3("A4_COD")[1])		
		xConteudo := StrZero(Val(Soma1(cValToChar(TMP->A4_COD))),TAMSX3("A4_COD")[1])
		aAdd(aCab,{"A4_COD", xConteudo, NIL})
	EndIf

	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto({|x,y| Mata050(x,y)},aCab,3)
	END TRANSACTION

	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= If(lMsErroAuto,"Erro","Ok")
	aTail(::aRetSts):Descricao	:= If(lMsErroAuto,MostraErro(),"Registro incluido com sucesso. Registro: " + SA4->A4_COD)
END SEQUENCE

Return .T.

*-----------------------------------------------------------------------------------*
WsMethod SETNFSAID WsReceive cChave,cSerie,DadosSet wsSend aRetSts WsService GTFLG001
*-----------------------------------------------------------------------------------*
Local aCab := {}, aItem := {}, aItens := {}, aPVlNFs := {}, i, aCpsObrig := {}, cNumNota
Local cPedido := "", cNota := "", cErro := "", aTables := {"SD1","SD2","SD3"}
Local cNumNF := "", cNumNFBKP := ""
Private lMsErroAuto := .F.

conout("GTFLG001: SETNFSAID inicio")

aAdd(aCpsObrig,"C5_TIPO")
aAdd(aCpsObrig,"C5_TIPOCLI")
aAdd(aCpsObrig,"C5_CLIENTE")
aAdd(aCpsObrig,"C5_LOJACLI")
aAdd(aCpsObrig,"C5_CONDPAG")
aAdd(aCpsObrig,"C6_ITEM")
aAdd(aCpsObrig,"C6_PRODUTO")
aAdd(aCpsObrig,"C6_QTDVEN")
aAdd(aCpsObrig,"C6_PRCVEN")
aAdd(aCpsObrig,"C6_QTDLIB")
aAdd(aCpsObrig,"C6_TES")
/* Os campos abaixo são obrigatorios apenas para geração de NF Devolução.
=============================
aAdd(aCpsObrig,"C6_NFORI")
aAdd(aCpsObrig,"C6_SERIORI")
=============================
*/

If ValType(::DadosSet:Dado) <> "A"
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
	RETURN .T.
EndIf

If Len(aEmp := BuscaEmpresas(cChave)) == 0
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
	RETURN .T.
EndIf

For i := 1 To Len(aCpsObrig)
	If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Atenção"
		aTail(::aRetSts):Descricao	:= "Informe todos os itens abaixo das informações de capa. O sistema separará os itens quando o campo C6_ITEM for informado. " + ENTER +;
										"Desta forma, o primeiro campo a ser informado para cada item deve ser o campo C6_ITEM."
		RETURN .T.
	EndIf
Next i

conout("GTFLG001: SETNFSAID RpcClearEnv '"+aEmp[1]+"','"+aEmp[2]+"','"+aEmp[3]+"'")
RpcClearEnv()
RpcSetType(3)
RpcSetEnv(aEmp[1], aEmp[2])

//*****************************************************//
//*********** AJUSTE DO PARAMETRO MV_DOCSEQ ***********//
//*****************************************************//
conout("GTFLG001: SETNFSAID AJUSTE DO PARAMETRO MV_DOCSEQ")
cNumNota := SuperGetMv("MV_DOCSEQ")
For i := 1 To Len(aTables)
	If Select("NUM") # 0
		NUM->(DbCloseArea())
	EndIf
	
	cQry := " Select MAX(" + SubStr(aTables[i],2,3) +"_NUMSEQ) as NUMSEQ from " + RetTabName(aTables[i])
	
	TCQuery cQry ALIAS "NUM" NEW

	NUM->(DbGoTop())
	If NUM->(!Eof()) .AND. Val(NUM->NUMSEQ) > Val(cNumNota)
		cNumNota := NUM->NUMSEQ
	EndIf
Next i

SX6->(DbSetOrder(1))
If SX6->(DbSeek(xFilial("SX6")+"MV_DOCSEQ")) .AND. RecLock("SX6",.F.)
	SX6->X6_CONTEUD := Soma1(cNumNota)
	SX6->X6_CONTSPA := Soma1(cNumNota)
	SX6->X6_CONTENG := Soma1(cNumNota)
	SX6->(MsUnlock())
EndIf

//**********************************************//
//********* GERACAO DE PEDIDO DE VENDA *********//
//**********************************************//
conout("GTFLG001: SETNFSAID GERACAO DE PEDIDO DE VENDA")
RegToMemory("SC5",.T.,.T.,.F.,,)
RegToMemory("SC6",.T.,.T.,.F.,,)

For i := 1 To Len(::DadosSet:Dado)
	If !Empty(::DadosSet:Dado[i]:Campo)
		cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
		Do Case
			Case cTipo == "C"
				xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
			Case cTipo == "D"
				xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
			Case cTipo == "N"
				xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
		End Case
		If ::DadosSet:Dado[i]:Campo == "F2_DOC"
			cNumNF := xConteudo		
		ElseIf SubStr(::DadosSet:Dado[i]:Campo,1,2) == "C5"
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		Else
			If Len(aItem) # 0 .AND. ::DadosSet:Dado[i]:Campo == "C6_ITEM"
				If aScan(aItem,{|x| x[1] == "C6_PEDCLI"}) == 0
					aAdd(aItem,{"C6_PEDCLI", ".", NIL})
				EndIf
				aAdd(aItens,aItem)
				aItem := {}
			EndIf
			aAdd(aItem,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		EndIf
	EndIf
Next i

If aScan(aItem,{|x| x[1] == "C6_PEDCLI"}) == 0
	aAdd(aItem,{"C6_PEDCLI", ".", NIL})
EndIf
aAdd(aItens,aItem)

If Len(aCab) == 0 .OR. Len(aItens) == 0
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
	RETURN .T.
EndIf

BEGIN SEQUENCE

	GetSXENum("SC5","C5_NUM")
	ConfirmSX8()
	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCab, aItens, 3)
	END TRANSACTION

	If lMsErroAuto
		cErro += MostraErro()
		Break
	Else
		cPedido := SC5->C5_NUM
	EndIf

	//**********************************************//
	//*********** GERACAO DE NOTA FISCAL ***********//
	//**********************************************//
	conout("GTFLG001: SETNFSAID GERACAO DE NOTA FISCAL")
	SC9->(DbSetOrder(1))
	SC9->(DbSeek(xFilial("SC9")+cPedido))
	While SC9->(!EOF()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cPedido
		If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
			cTes := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
			cCondPag := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_CONDPAG")
			aAdd(aPvlNfs,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				SC9->C9_PRCVEN,;
				SC9->C9_PRODUTO,;
				SF4->F4_ISS=="S",;
				SC9->(RecNo()),;
				SC5->(Recno(Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,""))),;
				SC6->(Recno(Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,""))),;
				SE4->(Recno(Posicione("SE4",1,xFilial("SE4")+cCondPag,""))),;
				SB1->(Recno(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,""))),;
				SB2->(Recno(Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,""))),;
				SF4->(Recno(Posicione("SF4",1,xFilial("SF4")+cTes,""))),;
				Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,"B2_LOCAL"),;
				1,;
				SC9->C9_QTDLIB2})
		EndIf
		SC9->(DbSkip())
	EndDo

	If Len(aPvlNfs) > 0
		Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"")
		SX5->(DbSetOrder(1))
		If !(SX5->(DbSeek(xFilial("SX5")+"01"+cSerie)))
			cErro += "Série inválida."
			Break
		EndIF
		
		//Tratamento para reutilização de numeração de NOTA (quando é recebido por parametro o numero da NF)
		If !EMPTY(cNumNF)
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5") + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerie , Len( SX5->X5_CHAVE ) ) ) )
				cNumNFBKP := SX5->X5_DESCRI
				//Atualiza o numero para o enviado no campo de referencia.
				SX5->(RecLock("SX5",.F.))
				SX5->X5_DESCRI := AllTrim(cNumNF)
				SX5->(MSUnlock())
			Else
				 cErro += "Erro na reutilização do numero da NF ("+cNumNF+"/"+cSerie+")."
				Break
			EndIf
		EndIf			

    	DbSelectArea("SC9")
		cNota := MAPVLNFS(aPVlNFs,cSerie,.F.,.F.,.F.,.F.,.F.,1,1,.T.,.F.,,,)
        
		If !EMPTY(cNumNF)
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5") + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerie , Len( SX5->X5_CHAVE ) ) ) )
				//Retorna o Numero da NF de acordo com o BKP.
				SX5->(RecLock("SX5",.F.))
				SX5->X5_DESCRI := AllTrim(cNumNFBKP)
				SX5->(MSUnlock())
			EndIf
		EndIf
     
		If Empty(cNota)
			cErro += "Ocorreu um problema na geração da Nota Fiscal"
			Break
		EndIf  
	Else
		cErro += "Pedido com itens não liberados!"
		Break
	EndIf

END SEQUENCE

aAdd(::aRetSts,WSClassNew("SETSTSRET"))
aTail(::aRetSts):Codigo		:= If(!Empty(cErro),"Erro","Ok")
aTail(::aRetSts):Descricao	:= If(!Empty(cErro),cErro,"Nota Fiscal de Saída '" + cNota + "/" + cSerie + "' incluída com sucesso.")
                        
conout("GTFLG001: SETNFSAID Fim")

Return .T.        


*-----------------------------------------------------------------------------*
WsMethod SETPSEMNF WsReceive cChave,DadosSet wsSend aRetSts WsService GTFLG001
*-----------------------------------------------------------------------------*
Local aCab := {}, aItem := {}, aItens := {}, i, aCpsObrig := {}
Local cPedido := "", cErro := ""
Local nPosEmissao := 0
Local dBkpDtBase:= CtoD("//")
Local cArqLog :=""

Private lMsHelpAuto := .F. 
Private lMsErroAuto := .F. 
Private cPath       := GetSrvProfString("Startpath","") 

conout("GTFLG001: SETPSEMNF inicio...")

aAdd(aCpsObrig,"C5_TIPO")
aAdd(aCpsObrig,"C5_TIPOCLI")
aAdd(aCpsObrig,"C5_CLIENTE")
aAdd(aCpsObrig,"C5_LOJACLI")
aAdd(aCpsObrig,"C5_CONDPAG")
aAdd(aCpsObrig,"C6_ITEM")
aAdd(aCpsObrig,"C6_PRODUTO")
aAdd(aCpsObrig,"C6_QTDVEN")
aAdd(aCpsObrig,"C6_PRCVEN")
aAdd(aCpsObrig,"C6_QTDLIB")
aAdd(aCpsObrig,"C6_TES")

If ValType(::DadosSet:Dado) <> "A"
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "Estrutura de dados não compatível."
	RETURN .T.
EndIf

If Len(aEmp := BuscaEmpresas(cChave)) == 0
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
	RETURN .T.
EndIf

For i := 1 To Len(aCpsObrig)
	If aScan(::DadosSet:Dado,{|x| x:Campo == aCpsObrig[i] }) == 0
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Erro"
		aTail(::aRetSts):Descricao	:= "Campos obrigatórios não informados. Informar o conteudo para o campo: " + aCpsObrig[i]
		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
		aTail(::aRetSts):Codigo		:= "Atenção"
		aTail(::aRetSts):Descricao	:= "Informe todos os itens abaixo das informações de capa. O sistema separará os itens quando o campo C6_ITEM for informado. " + ENTER +;
										"Desta forma, o primeiro campo a ser informado para cada item deve ser o campo C6_ITEM."
		RETURN .T.
	EndIf
Next i

conout("GTFLG001: SETPSEMNF RpcClearEnv '"+aEmp[1]+"','"+aEmp[2]+"','"+aEmp[3]+"'")
RpcClearEnv()
RpcSetType(3)
RpcSetEnv(aEmp[1], aEmp[2])

//**********************************************//
//********* GERACAO DE PEDIDO DE VENDA *********//
//**********************************************//
conout("GTFLG001: SETPSEMNF GERACAO DE PEDIDO DE VENDA")
RegToMemory("SC5",.T.,.T.,.F.,,)
RegToMemory("SC6",.T.,.T.,.F.,,)

For i := 1 To Len(::DadosSet:Dado)
	If !Empty(::DadosSet:Dado[i]:Campo)
		cTipo := Posicione("SX3",2,::DadosSet:Dado[i]:Campo,"X3_TIPO")
		Do Case
			Case cTipo == "C"
				xConteudo := cValToChar(::DadosSet:Dado[i]:Conteudo)
			Case cTipo == "D"
				xConteudo := CTOD(::DadosSet:Dado[i]:Conteudo)
			Case cTipo == "N"
				xConteudo := Val(::DadosSet:Dado[i]:Conteudo)
		End Case
		If SubStr(::DadosSet:Dado[i]:Campo,1,2) == "C5"
			aAdd(aCab,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		Else
			If Len(aItem) # 0 .AND. ::DadosSet:Dado[i]:Campo == "C6_ITEM"
				If aScan(aItem,{|x| x[1] == "C6_PEDCLI"}) == 0
					aAdd(aItem,{"C6_PEDCLI", ".", NIL})
				EndIf
				aAdd(aItens,aItem)
				aItem := {}
			EndIf
			aAdd(aItem,{::DadosSet:Dado[i]:Campo, xConteudo, NIL})
		EndIf
	EndIf
Next i

dBkpDtBase:= dDataBase
                         
//Troca data base do sistema
If (nPosEmissao := aScan(aCab,{|x| x[1] == "C5_EMISSAO"}) ) <> 0
	dDataBase:= aCab[nPosEmissao][2]
EndIf

If aScan(aItem,{|x| x[1] == "C6_PEDCLI"}) == 0
	aAdd(aItem,{"C6_PEDCLI", ".", NIL})
EndIf
aAdd(aItens,aItem)

If Len(aCab) == 0 .OR. Len(aItens) == 0
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "Dados de entrada inválidos."
	RETURN .T.
EndIf

BEGIN SEQUENCE
	cSeqNumC5 := GetSXENum("SC5","C5_NUM")
	ConfirmSX8()
	aAdd( aCab, {"C5_NUM", cValToChar(cSeqNumC5), NIL} )
	BEGIN TRANSACTION
		lMsErroAuto := .F.
		MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCab, aItens, 3)
	END TRANSACTION

	If lMsErroAuto
		//cErro += "Erro na inclus�o do pedido de venda "+cSeqNumC5
	    cArqLog := "WS_PV_"+cSeqNumC5+"_"+DTOS(dDataBase) + Left(Time(),2) + Right(time(),2) + ".LOG" 
                                  
        MostraErro(cPath, cArqLog ) 
	    
		conout("GTFLG001: SETPSEMNF - Dados do pedido inv�lido(s). Detalhes em : "+cPath+cArqLog)

		aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	    aTail(::aRetSts):Codigo		:= "Erro"
	    aTail(::aRetSts):Descricao	:= "Dados do pedido inv�lidos. Detalhes em : "+cPath+cArqLog
      
        RETURN .T.
	Else
		cPedido := SC5->C5_NUM
		//Apagfa o conteudo do campo FCI quando esta em branco no Fluig.(quando em branco, o fluig envia um ponto apenas)
		TCSQLEXEC("UPDATE "+RetSqlName("SC6")+" SET C6_FCICOD='' WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+cPedido+"' AND C6_FCICOD='.'")
	EndIf

END SEQUENCE
                     
aAdd(::aRetSts,WSClassNew("SETSTSRET"))
aTail(::aRetSts):Codigo		:= If(!Empty(cErro),"Erro","Ok")
aTail(::aRetSts):Descricao	:= If(!Empty(cErro),cErro,"Pedido '" + cPedido + "' incluído com sucesso.")
                        
//Retorna a data base
dDataBase:= dBkpDtBase

conout("GTFLG001: SETPSEMNF Fim")

Return .T.       


*------------------------------------------------------------------------------------------*
WsMethod SETNFSEMP WsReceive cChave,cSerie,cPedido,cNumNF wsSend aRetSts WsService GTFLG001
*------------------------------------------------------------------------------------------*
Local aPVlNFs := {}, i, aCpsObrig := {}, cNumNota
Local cNota := "", cErro := "", aTables := {"SD1","SD2","SD3"}
Local cNumNFBKP := ""
Local dBkpDtBase:= CtoD("//")
Local dNewDbase := CtoD("//")

If Len(aEmp := BuscaEmpresas(cChave)) == 0
	aAdd(::aRetSts,WSClassNew("SETSTSRET"))
	aTail(::aRetSts):Codigo		:= "Erro"
	aTail(::aRetSts):Descricao	:= "CNPJ informado não pertence a nenhuma empresa do Sistema."
	RETURN .T.
EndIf

conout("GTFLG001: SETNFSEMP RpcClearEnv '"+aEmp[1]+"','"+aEmp[2]+"','"+aEmp[3]+"'")
RpcClearEnv()
RpcSetType(3)
RpcSetEnv(aEmp[1], aEmp[2])

//*****************************************************//
//*********** AJUSTE DO PARAMETRO MV_DOCSEQ ***********//
//*****************************************************//
conout("GTFLG001: SETNFSEMP AJUSTE DO PARAMETRO MV_DOCSEQ")
cNumNota := SuperGetMv("MV_DOCSEQ")
For i := 1 To Len(aTables)
	If Select("NUM") # 0
		NUM->(DbCloseArea())
	EndIf

	cQry := " Select MAX(" + SubStr(aTables[i],2,3) +"_NUMSEQ) as NUMSEQ from " + RetTabName(aTables[i])
	TCQuery cQry ALIAS "NUM" NEW

	NUM->(DbGoTop())
	If NUM->(!Eof()) .AND. Val(NUM->NUMSEQ) > Val(cNumNota)
		cNumNota := NUM->NUMSEQ
	EndIf
Next i

SX6->(DbSetOrder(1))
If SX6->(DbSeek(xFilial("SX6")+"MV_DOCSEQ")) .AND. RecLock("SX6",.F.)
	SX6->X6_CONTEUD := Soma1(cNumNota)
	SX6->X6_CONTSPA := Soma1(cNumNota)
	SX6->X6_CONTENG := Soma1(cNumNota)
	SX6->(MsUnlock())
EndIf

BEGIN SEQUENCE
	//**********************************************//
	//*********** GERACAO DE NOTA FISCAL ***********//
	//**********************************************//
	conout("GTFLG001: SETNFSEMP GERACAO DE NOTA FISCAL"+cPedido+" <")
	SC9->(DbSetOrder(1))
	SC9->(DbSeek(xFilial("SC9")+cPedido))
		
	//Troca data base do sistema
	dBkpDtBase:= dDataBase
	dNewDbase:=Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_EMISSAO")
	If !EMPTY(dNewDbase)
   		dDataBase:= dNewDbase
	EndIf
	
	While SC9->(!EOF()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cPedido
		If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
			cTes := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
			cCondPag := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_CONDPAG")
			aAdd(aPvlNfs,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				SC9->C9_PRCVEN,;
				SC9->C9_PRODUTO,;
				SF4->F4_ISS=="S",;
				SC9->(RecNo()),;
				SC5->(Recno(Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,""))),;
				SC6->(Recno(Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,""))),;
				SE4->(Recno(Posicione("SE4",1,xFilial("SE4")+cCondPag,""))),;
				SB1->(Recno(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,""))),;
				SB2->(Recno(Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,""))),;
				SF4->(Recno(Posicione("SF4",1,xFilial("SF4")+cTes,""))),;
				Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,"B2_LOCAL"),;
				1,;
				SC9->C9_QTDLIB2})
		EndIf
		SC9->(DbSkip())
	EndDo

	If Len(aPvlNfs) > 0
		Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"")
		SX5->(DbSetOrder(1))
		If !(SX5->(DbSeek(xFilial("SX5")+"01"+cSerie)))
			cErro += "Série inválida."
			Break
		EndIF
		
		//Tratamento para reutilização de numeração de NOTA (quando é recebido por parametro o numero da NF)
		If !EMPTY(cNumNF)
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5") + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerie , Len( SX5->X5_CHAVE ) ) ) )
				cNumNFBKP := SX5->X5_DESCRI
				//Atualiza o numero para o enviado no campo de referencia.
				SX5->(RecLock("SX5",.F.))
				SX5->X5_DESCRI := AllTrim(cNumNF)
				SX5->(MSUnlock())
			Else
				 cErro += "Erro na reutilização do numero da NF ("+cNumNF+"/"+cSerie+")."
				Break
			EndIf
		EndIf			

    	DbSelectArea("SC9")
		cNota := MAPVLNFS(aPVlNFs,cSerie,.F.,.F.,.F.,.F.,.F.,1,1,.T.,.F.,,,)
        
		If !EMPTY(cNumNF)
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5") + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerie , Len( SX5->X5_CHAVE ) ) ) )
				//Retorna o Numero da NF de acordo com o BKP.
				SX5->(RecLock("SX5",.F.))
				SX5->X5_DESCRI := AllTrim(cNumNFBKP)
				SX5->(MSUnlock())
			EndIf
		EndIf
     
		If Empty(cNota)
			cErro += "Ocorreu um problema na geração da Nota Fiscal"
			Break
		EndIf  
	Else
		cErro += "Pedido com itens não liberados!"
		Break
	EndIf

END SEQUENCE

aAdd(::aRetSts,WSClassNew("SETSTSRET"))
aTail(::aRetSts):Codigo		:= If(!Empty(cErro),"Erro","Ok")
aTail(::aRetSts):Descricao	:= If(!Empty(cErro),cErro,"Nota Fiscal de Saída '" + cNota + "/" + cSerie + "' incluída com sucesso.")

//Retorna a data base
dDataBase:= dBkpDtBase

conout("GTFLG001: SETNFSEMP Fim")

Return .T.        

*-------------------------------------------------------------------------------*
WsMethod GETIMP WsReceive cChave,cPedido,cTipo wsSend aRetImp WsService GTFLG001   
*-------------------------------------------------------------------------------*
Local aDado := {}, aImpostos := {}

BEGIN SEQUENCE

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetImp,WSClassNew("GETIMPRET"))
		aAdd(aDado,WSClassNew("stDadoSet"))
		aTail(aDado):Campo		:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(aDado):Conteudo	:= ""
		aTail(::aRetImp):Impostos	:= aDado
		Break
	EndIf

	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])
	
	aImpostos := U_GTGEN043(cPedido,cTipo)
    
	If cTipo $ "NF"
		For i := 1 To Len(aImpostos)
			aAdd(::aRetImp,WSClassNew("GETIMPRET"))
			aDado := {}
			aAdd(aDado,WSClassNew("stDadoSet"))
			aTail(aDado):Campo	 		:= aImpostos[i][1]
			aTail(aDado):Conteudo		:= cvaltochar(aImpostos[i][2])
			aTail(::aRetImp):Impostos	:= aDado
		Next i
	Else	
		For i := 1 To Len(aImpostos)
			For a := 1 To Len (aImpostos[i])
				aAdd(::aRetImp,WSClassNew("GETIMPRET"))
				aDado := {}
				aAdd(aDado,WSClassNew("stDadoSet"))
				aTail(aDado):Campo	 		:= aImpostos[i][a][1]
				aTail(aDado):Conteudo		:= cvaltochar(aImpostos[i][a][2])
				aTail(::aRetImp):Impostos	:= aDado
			Next a
		Next i
	EndIf
		
END SEQUENCE

Return .T.

*--------------------------------------------------------------------------------*
WsMethod GETVLDCAD WsReceive cChave,cCad,cReg wsSend aRetVldCad WsService GTFLG001
*--------------------------------------------------------------------------------*
Local i, aDado := {}
Local cTimeIni := TIME()

Conout("GETVLDCAD: cChave:'"+cChave+"',cCad:'"+cCad+"',cReg'"+cReg+"' - ElapTime="+ElapTime(cTimeIni,TIME()))

BEGIN SEQUENCE

	If Len(aEmp := BuscaEmpresas(cChave)) == 0
		aAdd(::aRetVldCad,WSClassNew("GETVLDCADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo 		:= "Erro: CNPJ informado não pertence a nenhuma empresa do Sistema."
		aTail(::aRetVldCad):Valida	:= aDado
		Break
	EndIf
    
    If EMPTY(cCad) .or. EMPTY(cReg)
    	aAdd(::aRetVldCad,WSClassNew("GETVLDCADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo 		:= "Erro: Campo(s) obrigatorios do metodo não informados (cCad e/ou cReg)"
		aTail(::aRetVldCad):Valida	:= aDado
    	Break
    EndIf                       
    
   	If Select("TMP") <> 0
		TMP->(DbCloseArea())
	EndIf  

	Conout("GETVLDCAD: Pre-Docase ElapTime="+ElapTime(cTimeIni,TIME()))
    
	cCad := UPPER(ALLTRIM(cCad))
	Do Case
		Case cCad == "CIDADE"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("CC2")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND CC2_EST = '"+cReg+"'"                      

		Case cCad == "ESTADO"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("SX5")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND X5_TABELA = '12'" 
			cQry += "		AND X5_CHAVE = '"+cReg+"'"                      

		Case cCad == "PAIS"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("CCH")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND CCH_CODIGO = '"+cReg+"'"                      

		Case cCad == "CONTA"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("CT1")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND CT1_CONTA = '"+cReg+"' AND CT1_BLOQ <> '1'"                      

		Case cCad == "PRODUTO"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("SB1")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND B1_COD = '"+cReg+"'  AND B1_MSBLQL <> '1'"

		Case cCad == "ISS"
			cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("SX5")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND X5_TABELA = '60'" 
			cQry += "		AND X5_CHAVE = '"+cReg+"'"                    

		Case cCad == "TES"
			cQry := " Select COUNT(*) as VALIDA
			cQry += " From "+aEmp[3]+".dbo." + RetTabName("SZ2")
			cQry += " Where D_E_L_E_T_=' '
			cQry += "		AND Z2_TES = '"+cReg+"'
			cQry += "		AND Z2_EMPRESA = '"+aEmp[1]+aEmp[2]+"'
			cQry += "  		AND Z2_TES in (Select F4_CODIGO From "+aEmp[3]+".dbo."+RetTabName("SF4")+" Where D_E_L_E_T_=' ' AND F4_MSBLQL <> '1' )   

		Case cCad == "CUSTO"          
	  		cQry := "	SELECT COUNT(*) as VALIDA FROM	"  + aEmp[3] + ".dbo." + RetTabName("CTT")	
			cQry += "	WHERE D_E_L_E_T_=' ' "
			cQry += "		AND CTT_BLOQ <> '1'" 
			cQry += "		AND CTT_CUSTO = '"+cReg+"'"                      

	End Case

	Conout("GETVLDCAD: cQry="+cQry)

	If TCSQLExec(cQry) < 0
		aAdd(::aRetVldCad,WSClassNew("GETVLDCADRET"))
		aAdd(aDado,WSClassNew("stDadoGet"))
		aTail(aDado):Campo	:= "Erro: Erro na busca no Banco de Dados para validação."
		aTail(::aRetVldCad):Valida	:= aDado
		Break
	EndIf
   	Conout("GETVLDCAD: After-TCSQLExec ElapTime="+ElapTime(cTimeIni,TIME()))

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP",.F.,.F.)          
	
	Conout("GETVLDCAD: After-DbUseArea ElapTime="+ElapTime(cTimeIni,TIME()))

	aAdd(::aRetVldCad,WSClassNew("GETVLDCADRET"))
	aAdd(aDado,WSClassNew("stDadoGet"))
	aTail(aDado):Campo	:= 'STATUS'     
	If TMP->VALIDA >= 1
		aTail(aDado):Campo	:= 'OK'
	Else                               
		aTail(aDado):Campo	:= 'NOK'
	EndIf
	aTail(::aRetVldCad):Valida	:= aDado

END SEQUENCE
       
Conout("GETVLDCAD: FIM ElapTime="+ElapTime(cTimeIni,TIME()))

Return .T.

*-----------------------------------*
Static Function BuscaEmpresas(cCNPJ)
*-----------------------------------*
Local aEmp := {}, nHandle := 0
Local cDbAlias := GetSrvProfString('DBALIAS','')
Begin Sequence

	If Empty(cCNPJ)
		Break
	EndIf

	If Select("EMP") <> 0
		EMP->(DbCloseArea())	
	EndIf

   	If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
		If (nHandle := TCLink("MSSQL7/P1108_01","10.0.30.5",7891)) < 0
			Break
		Endif
	//Else
		//If (nHandle := TCLink("MSSQL7/P12125","10.0.30.56",7891)) < 0
		//	Break
		//EndIf
	Endif	

	cQry := " Select * "
   	If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
		cQry += " From P11_01.dbo.TotvsSigamatAmb "
		cQry += " Where M0_CGC = '" + cCNPJ + "' "
		conout("GTFLG001 - Executando em ambiente: "+GetEnvServer())
		cQry += " AND AMB <> 'P11_TESTE' "//produção
	Else
	    If! "HOM" $ cDbAlias
    		cQry += " From P12_01.dbo.TotvsSigamatAmb "
    		cQry += " Where M0_CGC = '" + cCNPJ + "' "
    		conout("GTFLG001 - Executando em ambiente: "+GetEnvServer()+" - DB: "+cDbAlias)
    		cQry += " AND AMB <> 'P12_TESTE' "//homologa��o
		Else
		    cQry += " From P12_01_HOM.dbo.TotvsSigamatAmb "
		    cQry += " Where M0_CGC = '" + cCNPJ + "' "
		    conout("GTFLG001 - Executando em ambiente: "+GetEnvServer()+" - DB: "+cDbAlias)
		    cQry += " AND AMB <> 'P12_TESTE' "//homologa��o
		EndIf 	
	Endif	

	TCQuery cQry ALIAS "EMP" NEW

	EMP->(DBGoTop())
	If EMP->(!Eof())
		aAdd(aEmp,ALLTRIM(EMP->M0_CODIGO))
		aAdd(aEmp,ALLTRIM(EMP->M0_CODFIL))
		aAdd(aEmp,Iif("HOM" $ cDbAlias,ALLTRIM(EMP->AMB)+"_HOM",ALLTRIM(EMP->AMB)))
		aAdd(aEmp,ALLTRIM(EMP->SERV))
		aAdd(aEmp,ALLTRIM(EMP->PORTA))
	EndIf
	
	If nHandle > 0
		TCUnlink(nHandle)
	EndIf
	
End Sequence

Return aEmp

/*
Funcao      : RetTabName
Objetivos   : Retornar o nome da tabela no banco de dados.
Autor       : Jean Victor Rocha
Data        : 25/05/2017
*/
*--------------------------------*
Static Function RetTabName(cAlias)
*--------------------------------*
Local oServ
Local cTabela := ""
Local cQry := ""
//Wederson
//Verifica se possui a tabela de nomes do SX2 no banco de dados.
If Select("ID") <> 0
	ID->(DbCloseArea())	
EndIf

If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	TCQuery "Select OBJECT_ID('P11_01.dbo.GTFLG001SX2') as ID" ALIAS "ID" NEW   
Else
	TCQuery "Select OBJECT_ID('P12_01.dbo.GTFLG001SX2') as ID" ALIAS "ID" NEW   
Endif	
If ID->ID <= 0
	If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
		TCSQLEXEC("CREATE TABLE P11_01.dbo.GTFLG001SX2 (CODEMP varchar(2),X2_CHAVE varchar(3),X2_ARQUIVO varchar(6),DT_ATU varchar(8))")
    Else	
		TCSQLEXEC("CREATE TABLE P12_01.dbo.GTFLG001SX2 (CODEMP varchar(2),X2_CHAVE varchar(3),X2_ARQUIVO varchar(6),DT_ATU varchar(8))")
	Endif	
EndIf

If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
	cQry := " Select * From P11_01.dbo.GTFLG001SX2 where CODEMP='"+aEmp[1]+"' AND X2_CHAVE='"+cAlias+"' "
Else
	cQry := " Select * From P12_01.dbo.GTFLG001SX2 where CODEMP='"+aEmp[1]+"' AND X2_CHAVE='"+cAlias+"' "
Endif

If Select("TMPSX2") <> 0
	TMPSX2->(DbCloseArea())	
EndIf
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMPSX2",.F.,.F.)
TMPSX2->(DBGoTop())
If TMPSX2->(!EOF())
	If DateDiffDay(STOD(TMPSX2->DT_ATU),DATE() ) > 7
		If Subs(Upper(AllTrim(GetEnvServer())),1,3) == "P11"
			TCSQLExec("Delete P11_01.dbo.GTFLG001SX2 where CODEMP='"+aEmp[1]+"' AND X2_CHAVE='"+cAlias+"'")
		Else
			TCSQLExec("Delete P12_01.dbo.GTFLG001SX2 where CODEMP='"+aEmp[1]+"' AND X2_CHAVE='"+cAlias+"'")
		Endif	
	Else
		cTabela := TMPSX2->X2_ARQUIVO
	EndIf
EndIf        

If EMPTY(cTabela)
	conout("GTFLG001: RpcConnect - '"+aEmp[4]+"','"+aEmp[5]+"','"+ALLTRIM(aEmp[3])+"','"+aEmp[1]+"','"+aEmp[2]+"'")
	//AOA - 14/03/2018 - Alterado forma de acesso ao ambiente para gravar tabela
	//oServ := RpcConnect(aEmp[4],VAL(aEmp[5]),ALLTRIM(aEmp[3])+"D",aEmp[1],aEmp[2])
	RpcClearEnv()
	RpcSetType(2)
	RpcSetEnv(aEmp[1], aEmp[2])
	//If valtype(oServ) == 'O'  
		//cTabela := oServ:CALLPROC("U_GTGEN040",aEmp[1],cAlias)//executa a função
		cTabela := U_GTGEN040(aEmp[1],cAlias)  
		RpcDisconnect(oServ)
		conout("GTFLG001: RpcConnect - TABELA : '"+cTabela+"'")
	//EndIf          
EndIf
conout("Tabela --> "+ctabela)
Return ALLTRIM(cTabela)
