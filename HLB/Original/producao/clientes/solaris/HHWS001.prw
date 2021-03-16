#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

/*
Funcao      : HHWS001 
Parametros  : Nenhum
Retorno     : RetInt
Objetivos   : Processar Integração Web Service
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 07/11/2016
*/

//Log do Processo
WSSTRUCT Result
	WSDATA Numero		As String
	WSDATA Log    		As String 
ENDWSSTRUCT

//Objeto Cliente
WSSTRUCT oCliente
	WSDATA Codigo	  	As String
	WSDATA Loja 		As String
	WSDATA Nome 		As String
	WSDATA Pessoa 		As String
	WSDATA Reduz 		As String
	WSDATA Endereco 	As String
	WSDATA UF 			As String
	WSDATA CodMun 		As String
	WSDATA Municipio	As String
	WSDATA Bairro  		As String
	WSDATA CEP 	   		As String
	WSDATA DDI 			As String
	WSDATA DDD 			As String
	WSDATA Tel 			As String
	WSDATA Pais 		As String
	WSDATA CGC 			As String
	WSDATA Contato 		As String
	WSDATA InscrE 		As String
	WSDATA InscrM 		As String
	WSDATA Email 		As String
	WSDATA InscrR 		As String
	WSDATA Comple 		As String
	WSDATA Naturez 		As String
	WSDATA EndCob 		As String
	WSDATA EndRecb 		As String
	WSDATA CContab 		As String
	WSDATA CodPais 		As String
	WSDATA CodMunZF 	As String
	WSDATA RecINSS 		As String
	WSDATA RecCOF 		As String
	WSDATA RecCSLL 		As String
	WSDATA RecPIS 		As String
	WSDATA TPessoa 		As String
	WSDATA OptSimpl 	As String
	WSDATA RecIRRF 		As String
	WSDATA Tipo 		As String
ENDWSSTRUCT

//Objeto Fornecedor
WSSTRUCT oFornecedor
	WSDATA Codigo 		AS String
	WSDATA Loja 		AS String
	WSDATA Nome 		AS String
	WSDATA Tipo 		AS String
	WSDATA Reduz 		AS String
	WSDATA Endereco 	AS String
	WSDATA UF 			AS String
	WSDATA CodMun 		AS String
	WSDATA Municipio 	AS String
	WSDATA Bairro 		AS String
	WSDATA CEP 			AS String
	WSDATA DDI 			AS String
	WSDATA DDD 			AS String
	WSDATA Tel 			AS String
	WSDATA Pais 		AS String
	WSDATA CGC 			AS String
	WSDATA Contato 		AS String
	WSDATA InscrE 		AS String
	WSDATA InscrM 		AS String
	WSDATA Email 		AS String
	WSDATA CodPais 		AS String
	WSDATA Banco 		AS String
	WSDATA Agencia 		AS String
	WSDATA NumConta 	AS String
	WSDATA Comple 		AS String
	WSDATA Naturez 		AS String
	WSDATA CContab 		AS String
	WSDATA CodMunZF 	AS String
	WSDATA RecINSS 		AS String
	WSDATA RecCOF 		AS String
	WSDATA RecCSLL 		AS String
	WSDATA RecPIS 		AS String
	WSDATA RecIRRF 		AS String
	WSDATA TPessoa 		AS String
	WSDATA FabrForn 	AS String
	WSDATA FuncForn 	AS String
ENDWSSTRUCT

//Objeto Produto
WSSTRUCT oProduto
	WSDATA Descr		AS String
	WSDATA Tipo			AS String
	WSDATA Codigo		AS String
	WSDATA Unidade		AS String
	WSDATA LocPad		AS String
	WSDATA Grupo		AS String
	WSDATA AliqICM		AS String
	WSDATA AliqIPI		AS String
	WSDATA NCM			AS String
	WSDATA ExNCM		AS String
	WSDATA AliqISS		AS String
	WSDATA CodServ		AS String
	WSDATA Conta		AS String
	WSDATA Origem		AS String
	WSDATA RetIrrf		AS String
	WSDATA TipoProd		AS String
	WSDATA Import		AS String
	WSDATA RetInss		AS String
	WSDATA AliqCsll		AS String
	WSDATA AliqCof		AS String
	WSDATA AliqPis		AS String
	WSDATA RetPis		AS String
	WSDATA RetCof		AS String
	WSDATA RetCsll		AS String
	WSDATA Garant		AS String
	WSDATA Cest			AS String
ENDWSSTRUCT

//Objeto Transportadora
WSSTRUCT oTransportadora
	WSDATA Codigo 		AS String
	WSDATA Nome 		AS String
	WSDATA Endereco 	AS String
	WSDATA Bairro 		AS String
	WSDATA Municipio 	AS String
	WSDATA UF 			AS String
	WSDATA CEP 			AS String
	WSDATA DDI 			AS String
	WSDATA DDD 			AS String
	WSDATA Tel 			AS String
	WSDATA CGC 			AS String
	WSDATA InsEst 		AS String
	WSDATA Comple 		AS String
ENDWSSTRUCT

WSSERVICE HHWS001 Description "WS Protheus Integração Solaris" 
	WSDATA oForn	As oFornecedor	
	WSDATA oCli		As oCliente
	WSDATA oProd	As oProduto
	WSDATA oTransp	As oTransportadora
	WSDATA NumCNPJ	As String
	//Retorno Log da Inclusao Clientes
	WSDATA RetInt   As Array of Result
	//Metodos
	WSMETHOD InsereClientes Description "WS Protheus Insere conteúdo no SA1"
	WSMETHOD InsereFornecedor Description "WS Protheus Insere conteúdo no SA2"
	WSMETHOD InsereProdutos Description "WS Protheus Insere conteúdo no SB1"
	WSMETHOD InsereTransportadora Description "WS Protheus Insere conteúdo no SA4"
ENDWSSERVICE

/*
Método.......: InsereClientes
Objetivo.....: Insere Clientes Protheus
Autor........: Renato Rezende
Data.........: 07/11/2016
*/
*----------------------------------------------------------------------------------*
 WSMETHOD InsereClientes WSRECEIVE oCli,NumCNPJ WSSEND RetInt WSSERVICE HHWS001
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cCodCli		:= PadR(::oCli:Codigo , Len(SA1->A1_COD) )
Local cCGC			:= PadR(::oCli:CGC , Len(SA1->A1_CGC) )
Local cLoja			:= PadR(::oCli:Loja , Len(SA1->A1_LOJA) )
Local cArqLog		:= ""
Local cChave		:= cCodCli+cLoja
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabecSA1		:= {}
Local aEmp			:= {}

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SA1",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aCabecSA1,{"A1_FILIAL"		, xFilial("SA1")   											, Nil})
AADD(aCabecSA1,{"A1_COD"		, SubStr(Alltrim(cCodCli) ,1, Len(SA1->A1_COD)) 			, Nil})
AADD(aCabecSA1,{"A1_LOJA" 		, SubStr(Alltrim(::oCli:Loja) ,1, Len(SA1->A1_LOJA))		, Nil})
AADD(aCabecSA1,{"A1_NOME" 		, SubStr(Alltrim(::oCli:Nome) ,1, Len(SA1->A1_NOME))		, Nil})
AADD(aCabecSA1,{"A1_PESSOA"		, SubStr(Alltrim(::oCli:Pessoa) ,1, Len(SA1->A1_PESSOA))	, Nil})
AADD(aCabecSA1,{"A1_NREDUZ"		, SubStr(Alltrim(::oCli:Reduz) ,1, Len(SA1->A1_NREDUZ))		, Nil})
AADD(aCabecSA1,{"A1_END"	 	, SubStr(Alltrim(::oCli:Endereco) ,1, Len(SA1->A1_END))		, Nil})
AADD(aCabecSA1,{"A1_EST"	 	, SubStr(Alltrim(::oCli:UF) ,1, Len(SA1->A1_EST))			, Nil})
AADD(aCabecSA1,{"A1_COD_MUN"	, SubStr(Alltrim(::oCli:CodMun) ,1, Len(SA1->A1_COD_MUN)) 	, Nil})
AADD(aCabecSA1,{"A1_MUN"		, SubStr(Alltrim(::oCli:Municipio) ,1, Len(SA1->A1_MUN)) 	, Nil})
AADD(aCabecSA1,{"A1_BAIRRO" 	, SubStr(Alltrim(::oCli:Bairro) ,1, Len(SA1->A1_BAIRRO))	, Nil})
AADD(aCabecSA1,{"A1_CEP"		, SubStr(Alltrim(::oCli:CEP) ,1, Len(SA1->A1_CEP))			, Nil})
AADD(aCabecSA1,{"A1_DDI"		, SubStr(Alltrim(::oCli:DDI) ,1, Len(SA1->A1_DDI))			, Nil})
AADD(aCabecSA1,{"A1_DDD"		, SubStr(Alltrim(::oCli:DDD) ,1, Len(SA1->A1_DDD))			, Nil})
AADD(aCabecSA1,{"A1_TEL"		, SubStr(Alltrim(::oCli:Tel) ,1, Len(SA1->A1_TEL))			, Nil})
AADD(aCabecSA1,{"A1_PAIS"		, SubStr(Alltrim(::oCli:Pais) ,1, Len(SA1->A1_PAIS))		, Nil})
AADD(aCabecSA1,{"A1_CGC" 		, SubStr(Alltrim(::oCli:CGC) ,1, Len(SA1->A1_CGC))			, Nil})
AADD(aCabecSA1,{"A1_CONTATO"	, SubStr(Alltrim(::oCli:Contato) ,1, Len(SA1->A1_CONTATO))	, Nil})
AADD(aCabecSA1,{"A1_INSCR"		, SubStr(Alltrim(::oCli:InscrE) ,1, Len(SA1->A1_INSCR))		, Nil})
AADD(aCabecSA1,{"A1_INSCRM"		, SubStr(Alltrim(::oCli:InscrM) ,1, Len(SA1->A1_INSCRM))	, Nil})
AADD(aCabecSA1,{"A1_EMAIL"		, SubStr(Alltrim(::oCli:Email) ,1, Len(SA1->A1_EMAIL))		, Nil})
AADD(aCabecSA1,{"A1_INSCRUR"	, SubStr(Alltrim(::oCli:InscrR) ,1, Len(SA1->A1_INSCRUR))	, Nil})
AADD(aCabecSA1,{"A1_COMPLEM"	, SubStr(Alltrim(::oCli:Comple) ,1, Len(SA1->A1_COMPLEM))	, Nil})
AADD(aCabecSA1,{"A1_NATUREZ" 	, SubStr(Alltrim(::oCli:Naturez) ,1, Len(SA1->A1_NATUREZ))	, Nil})
AADD(aCabecSA1,{"A1_ENDCOB"	 	, SubStr(Alltrim(::oCli:EndCob) ,1, Len(SA1->A1_ENDCOB))	, Nil})
AADD(aCabecSA1,{"A1_ENDREC"	 	, SubStr(Alltrim(::oCli:EndRecb) ,1, Len(SA1->A1_ENDREC))	, Nil})
AADD(aCabecSA1,{"A1_CONTA" 		, SubStr(Alltrim(::oCli:CContab) ,1, Len(SA1->A1_CONTA))	, Nil})
AADD(aCabecSA1,{"A1_CODPAIS"	, SubStr(Alltrim(::oCli:CodPais) ,1, Len(SA1->A1_CODPAIS))	, Nil})
AADD(aCabecSA1,{"A1_CODMUN"		, SubStr(Alltrim(::oCli:CodMunZF) ,1, Len(SA1->A1_CODMUN)) 	, Nil})
AADD(aCabecSA1,{"A1_RECINSS"	, SubStr(Alltrim(::oCli:RecINSS) ,1, Len(SA1->A1_RECINSS)) 	, Nil})
AADD(aCabecSA1,{"A1_RECCOFI"	, SubStr(Alltrim(::oCli:RecCOF) ,1, Len(SA1->A1_RECCOFI))	, Nil})
AADD(aCabecSA1,{"A1_RECCSLL"	, SubStr(Alltrim(::oCli:RecCSLL) ,1, Len(SA1->A1_RECCSLL))	, Nil})
AADD(aCabecSA1,{"A1_RECPIS"		, SubStr(Alltrim(::oCli:RecPIS) ,1, Len(SA1->A1_RECPIS))	, Nil})
AADD(aCabecSA1,{"A1_TPESSOA"	, SubStr(Alltrim(::oCli:TPessoa) ,1, Len(SA1->A1_TPESSOA))	, Nil})
AADD(aCabecSA1,{"A1_SIMPLES"	, SubStr(Alltrim(::oCli:OptSimpl) ,1, Len(SA1->A1_SIMPLES))	, Nil})
AADD(aCabecSA1,{"A1_RECIRRF"	, SubStr(Alltrim(::oCli:RecIRRF) ,1, Len(SA1->A1_RECIRRF))	, Nil})
AADD(aCabecSA1,{"A1_TIPO"	 	, SubStr(Alltrim(::oCli:Tipo) ,1, Len(SA1->A1_TIPO))		, Nil})

//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHFAT001" , GetEnvServer() , .T. , aEmp , aCabecSA1 , cCodCli , cLoja , cCGC )

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
Método.......: InsereFornecedor
Objetivo.....: Insere Fornecedor Protheus
Autor........: Renato Rezende
Data.........: 24/11/2016
*/
*----------------------------------------------------------------------------------*
 WSMETHOD InsereFornecedor WSRECEIVE oForn,NumCNPJ WSSEND RetInt WSSERVICE HHWS001
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cCodForn		:= PadR(::oForn:Codigo , Len(SA2->A2_COD) )
Local cCGC			:= PadR(::oForn:CGC , Len(SA2->A2_CGC) )
Local cLoja			:= PadR(::oForn:Loja , Len(SA2->A2_LOJA) )
Local cArqLog		:= ""
Local cChave		:= cCodForn+cLoja
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabecSA2		:= {}
Local aEmp			:= {}

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SA2",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aCabecSA2,{"A2_FILIAL"		, xFilial("SA2")   											, Nil})
AADD(aCabecSA2,{"A2_COD"		, SubStr(Alltrim(cCodForn) ,1, Len(SA2->A2_COD)) 			, Nil})
AADD(aCabecSA2,{"A2_LOJA" 		, SubStr(Alltrim(::oForn:Loja) ,1, Len(SA2->A2_LOJA))		, Nil})
AADD(aCabecSA2,{"A2_NOME" 		, SubStr(Alltrim(::oForn:Nome) ,1, Len(SA2->A2_NOME))		, Nil})
AADD(aCabecSA2,{"A2_TIPO"	 	, SubStr(Alltrim(::oForn:Tipo) ,1, Len(SA2->A2_TIPO))		, Nil})
AADD(aCabecSA2,{"A2_NREDUZ"		, SubStr(Alltrim(::oForn:Reduz) ,1, Len(SA2->A2_NREDUZ))	, Nil})
AADD(aCabecSA2,{"A2_END"	 	, SubStr(Alltrim(::oForn:Endereco) ,1, Len(SA2->A2_END))	, Nil})
AADD(aCabecSA2,{"A2_EST"	 	, SubStr(Alltrim(::oForn:UF) ,1, Len(SA2->A2_EST))			, Nil})
AADD(aCabecSA2,{"A2_COD_MUN"	, SubStr(Alltrim(::oForn:CodMun) ,1, Len(SA2->A2_COD_MUN)) 	, Nil})
AADD(aCabecSA2,{"A2_MUN"		, SubStr(Alltrim(::oForn:Municipio) ,1, Len(SA2->A2_MUN)) 	, Nil})
AADD(aCabecSA2,{"A2_BAIRRO" 	, SubStr(Alltrim(::oForn:Bairro) ,1, Len(SA2->A2_BAIRRO))	, Nil})
AADD(aCabecSA2,{"A2_CEP"		, SubStr(Alltrim(::oForn:CEP) ,1, Len(SA2->A2_CEP))			, Nil})
AADD(aCabecSA2,{"A2_DDI"		, SubStr(Alltrim(::oForn:DDI) ,1, Len(SA2->A2_DDI))			, Nil})
AADD(aCabecSA2,{"A2_DDD"		, SubStr(Alltrim(::oForn:DDD) ,1, Len(SA2->A2_DDD))			, Nil})
AADD(aCabecSA2,{"A2_TEL"		, SubStr(Alltrim(::oForn:Tel) ,1, Len(SA2->A2_TEL))			, Nil})
AADD(aCabecSA2,{"A2_PAIS"		, SubStr(Alltrim(::oForn:Pais) ,1, Len(SA2->A2_PAIS))		, Nil})
AADD(aCabecSA2,{"A2_CGC" 		, SubStr(Alltrim(::oForn:CGC) ,1, Len(SA2->A2_CGC))			, Nil})
AADD(aCabecSA2,{"A2_CONTATO"	, SubStr(Alltrim(::oForn:Contato) ,1, Len(SA2->A2_CONTATO))	, Nil})
AADD(aCabecSA2,{"A2_INSCR"		, SubStr(Alltrim(::oForn:InscrE) ,1, Len(SA2->A2_INSCR))	, Nil})
AADD(aCabecSA2,{"A2_INSCRM"		, SubStr(Alltrim(::oForn:InscrM) ,1, Len(SA2->A2_INSCRM))	, Nil})
AADD(aCabecSA2,{"A2_EMAIL"		, SubStr(Alltrim(::oForn:Email) ,1, Len(SA2->A2_EMAIL))		, Nil})
AADD(aCabecSA2,{"A2_CODPAIS"	, SubStr(Alltrim(::oForn:CodPais) ,1, Len(SA2->A2_CODPAIS))	, Nil})
AADD(aCabecSA2,{"A2_BANCO" 		, SubStr(Alltrim(::oForn:Banco) ,1, Len(SA2->A2_BANCO))		, Nil})
AADD(aCabecSA2,{"A2_AGENCIA"	, SubStr(Alltrim(::oForn:Agencia) ,1, Len(SA2->A2_AGENCIA))	, Nil})
AADD(aCabecSA2,{"A2_NUMCON"		, SubStr(Alltrim(::oForn:NumConta) ,1, Len(SA2->A2_NUMCON))	, Nil})
AADD(aCabecSA2,{"A2_COMPLEM"	, SubStr(Alltrim(::oForn:Comple) ,1, Len(SA2->A2_COMPLEM))	, Nil})
AADD(aCabecSA2,{"A2_NATUREZ" 	, SubStr(Alltrim(::oForn:Naturez) ,1, Len(SA2->A2_NATUREZ))	, Nil})
AADD(aCabecSA2,{"A2_CONTA" 		, SubStr(Alltrim(::oForn:CContab) ,1, Len(SA2->A2_CONTA))	, Nil})
AADD(aCabecSA2,{"A2_CODMUN"		, SubStr(Alltrim(::oForn:CodMunZF) ,1, Len(SA2->A2_CODMUN)) , Nil})
AADD(aCabecSA2,{"A2_RECINSS"	, SubStr(Alltrim(::oForn:RecINSS) ,1, Len(SA2->A2_RECINSS)) , Nil})
AADD(aCabecSA2,{"A2_RECCOFI"	, SubStr(Alltrim(::oForn:RecCOF) ,1, Len(SA2->A2_RECCOFI))	, Nil})
AADD(aCabecSA2,{"A2_RECCSLL"	, SubStr(Alltrim(::oForn:RecCSLL) ,1, Len(SA2->A2_RECCSLL))	, Nil})
AADD(aCabecSA2,{"A2_RECPIS"		, SubStr(Alltrim(::oForn:RecPIS) ,1, Len(SA2->A2_RECPIS))	, Nil})
AADD(aCabecSA2,{"A2_CALCIRF"	, SubStr(Alltrim(::oForn:RecIRRF) ,1, Len(SA2->A2_CALCIRF))	, Nil})
AADD(aCabecSA2,{"A2_TPESSOA"	, SubStr(Alltrim(::oForn:TPessoa) ,1, Len(SA2->A2_TPESSOA))	, Nil})
AADD(aCabecSA2,{"A2_ID_FBFN"	, SubStr(Alltrim(::oForn:FabrForn) ,1, Len(SA2->A2_ID_FBFN)), Nil})
AADD(aCabecSA2,{"A2_FABRICA"	, SubStr(Alltrim(::oForn:FuncForn) ,1, Len(SA2->A2_FABRICA)), Nil})


//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHEST001" , GetEnvServer() , .T. , aEmp , aCabecSA2 , cCodForn , cLoja , cCGC )

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
Método.......: InsereProdutos
Objetivo.....: Insere Produtos Protheus
Autor........: Renato Rezende
Data.........: 28/11/2016
*/
*----------------------------------------------------------------------------------*
 WSMETHOD InsereProdutos WSRECEIVE oProd,NumCNPJ WSSEND RetInt WSSERVICE HHWS001
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cCodProd		:= PadR(::oProd:Codigo , Len(SB1->B1_COD) )
Local cArqLog		:= ""
Local cChave		:= cCodProd
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabecSB1		:= {}
Local aEmp			:= {}

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SB1",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aCabecSB1,{"B1_FILIAL"		, xFilial("SB1"), Nil})
AADD(aCabecSB1,{"B1_DESC"		, SubStr(::oProd:Descr ,1, Len(SB1->B1_DESC))		, Nil})
AADD(aCabecSB1,{"B1_TIPO"		, SubStr(::oProd:Tipo ,1, Len(SB1->B1_TIPO))		, Nil})
AADD(aCabecSB1,{"B1_COD"		, SubStr(Alltrim(cCodProd) ,1, Len(SB1->B1_COD))	, Nil})
AADD(aCabecSB1,{"B1_UM"			, SubStr(::oProd:Unidade ,1, Len(SB1->B1_UM))		, Nil})
AADD(aCabecSB1,{"B1_LOCPAD"		, SubStr(::oProd:LocPad ,1, Len(SB1->B1_LOCPAD))	, Nil})
AADD(aCabecSB1,{"B1_GRUPO"		, SubStr(::oProd:Grupo ,1, Len(SB1->B1_GRUPO))		, Nil})
AADD(aCabecSB1,{"B1_PICM"		, Val(::oProd:AliqICM)								, Nil})
AADD(aCabecSB1,{"B1_IPI"		, Val(::oProd:AliqIPI)								, Nil})
AADD(aCabecSB1,{"B1_POSIPI"		, SubStr(::oProd:NCM ,1, Len(SB1->B1_POSIPI))		, Nil})
AADD(aCabecSB1,{"B1_EX_NCM"		, SubStr(::oProd:ExNCM ,1, Len(SB1->B1_EX_NCM))		, Nil})
AADD(aCabecSB1,{"B1_ALIQISS"	, Val(::oProd:AliqISS)								, Nil})
AADD(aCabecSB1,{"B1_CODISS"		, SubStr(::oProd:CodServ ,1, Len(SB1->B1_CODISS))	, Nil})
AADD(aCabecSB1,{"B1_CONTA"		, SubStr(::oProd:Conta ,1, Len(SB1->B1_CONTA)) 		, Nil})
AADD(aCabecSB1,{"B1_ORIGEM"		, SubStr(::oProd:Origem ,1, Len(SB1->B1_ORIGEM))	, Nil})
AADD(aCabecSB1,{"B1_IRRF"		, SubStr(::oProd:RetIrrf ,1, Len(SB1->B1_IRRF))		, Nil})
AADD(aCabecSB1,{"B1_P_TIP"		, SubStr(::oProd:TipoProd ,1, Len(SB1->B1_P_TIP))	, Nil})
AADD(aCabecSB1,{"B1_IMPORT"		, SubStr(::oProd:Import ,1, Len(SB1->B1_IMPORT))	, Nil})
AADD(aCabecSB1,{"B1_INSS"		, SubStr(::oProd:RetInss ,1, Len(SB1->B1_INSS))		, Nil})
AADD(aCabecSB1,{"B1_PCSLL"		, Val(::oProd:AliqCsll)								, Nil})
AADD(aCabecSB1,{"B1_PCOFINS"	, Val(::oProd:AliqCof)								, Nil})
AADD(aCabecSB1,{"B1_PPIS"		, Val(::oProd:AliqPis)								, Nil})
AADD(aCabecSB1,{"B1_PIS"		, SubStr(::oProd:RetPis ,1, Len(SB1->B1_PIS))		, Nil})
AADD(aCabecSB1,{"B1_COFINS"		, SubStr(::oProd:RetCof ,1, Len(SB1->B1_COFINS))	, Nil})
AADD(aCabecSB1,{"B1_CSLL"		, SubStr(::oProd:RetCsll ,1, Len(SB1->B1_CSLL))		, Nil})
AADD(aCabecSB1,{"B1_GARANT"		, SubStr(::oProd:Garant ,1, Len(SB1->B1_GARANT))	, Nil})
AADD(aCabecSB1,{"B1_CEST"		, SubStr(::oProd:Cest ,1, Len(SB1->B1_CEST))		, Nil})//Cod. Especificador ST
AADD(aCabecSB1,{"B1_P_ORIG"		, "I"												, Nil})//Grava o campo informando que foi feito via Integração

//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHEST002" , GetEnvServer() , .T. , aEmp , aCabecSB1 , cCodProd )

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
Método.......: InsereTransportadora
Objetivo.....: Insere Transportadora Protheus
Autor........: Renato Rezende
Data.........: 05/12/2016
*/
*------------------------------------------------------------------------------------------*
 WSMETHOD InsereTransportadora WSRECEIVE oTransp,NumCNPJ WSSEND RetInt WSSERVICE HHWS001
*------------------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cCodTransp	:= PadR(::oTransp:Codigo , Len(SA4->A4_COD) )
Local cCGC			:= PadR(::oTransp:CGC , Len(SA4->A4_CGC) )
Local cArqLog		:= ""
Local cChave		:= cCodTransp
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabecSA4		:= {}
Local aEmp			:= {}

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SA4",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aCabecSA4,{"A4_FILIAL"		, xFilial("SA4")   												, Nil})
AADD(aCabecSA4,{"A4_COD"		, SubStr(Alltrim(cCodTransp) ,1, Len(SA4->A4_COD)) 				, Nil})
AADD(aCabecSA4,{"A4_NOME" 		, SubStr(Alltrim(::oTransp:Nome) ,1, Len(SA4->A4_NOME))			, Nil})
AADD(aCabecSA4,{"A4_END"	 	, SubStr(Alltrim(::oTransp:Endereco) ,1, Len(SA4->A4_END))		, Nil})
AADD(aCabecSA4,{"A4_BAIRRO" 	, SubStr(Alltrim(::oTransp:Bairro) ,1, Len(SA4->A4_BAIRRO))		, Nil})
AADD(aCabecSA4,{"A4_MUN"		, SubStr(Alltrim(::oTransp:Municipio) ,1, Len(SA4->A4_MUN)) 	, Nil})
AADD(aCabecSA4,{"A4_EST"	 	, SubStr(Alltrim(::oTransp:UF) ,1, Len(SA4->A4_EST))			, Nil})
AADD(aCabecSA4,{"A4_CEP"		, SubStr(Alltrim(::oTransp:CEP) ,1, Len(SA4->A4_CEP))			, Nil})
AADD(aCabecSA4,{"A4_DDI"		, SubStr(Alltrim(::oTransp:DDI) ,1, Len(SA4->A4_DDI))			, Nil})
AADD(aCabecSA4,{"A4_DDD"		, SubStr(Alltrim(::oTransp:DDD) ,1, Len(SA4->A4_DDD))			, Nil})
AADD(aCabecSA4,{"A4_TEL"		, SubStr(Alltrim(::oTransp:Tel) ,1, Len(SA4->A4_TEL))			, Nil})
AADD(aCabecSA4,{"A4_CGC" 		, SubStr(Alltrim(::oTransp:CGC) ,1, Len(SA4->A4_CGC))			, Nil})
AADD(aCabecSA4,{"A4_INSEST"		, SubStr(Alltrim(::oTransp:InsEst) ,1, Len(SA4->A4_INSEST))		, Nil})
AADD(aCabecSA4,{"A4_COMPLEM"	, SubStr(Alltrim(::oTransp:Comple) ,1, Len(SA4->A4_COMPLEM))	, Nil})


//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHFAT002" , GetEnvServer() , .T. , aEmp , aCabecSA4 , cCodTransp , cCGC )

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
Data/Hora   : 25/11/2016
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