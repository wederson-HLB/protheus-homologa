#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

/*
Funcao      : HHWS002 
Parametros  : Nenhum
Retorno     : RetInt
Objetivos   : Processar Integração Financeira via Web Service
Autor       : Anderson Arrais
Cliente		: Solaris 
Data/Hora   : 23/03/2017
*/

//Log do Processo
WSSTRUCT ResultFin
	WSDATA Numero		As String
	WSDATA Log    		As String 
ENDWSSTRUCT

//Objeto Titulo receber
WSSTRUCT oCReceber
	WSDATA Prefixo	  	As String
	WSDATA Numero 		As String
	WSDATA Parcela 		As String
	WSDATA Tipo 		As String
	WSDATA CobraEx 		As String
	WSDATA DataCEx 		As String
	WSDATA VencRel 		As String
	WSDATA ValAcre 		As String
	WSDATA ValDesc 		As String
	WSDATA Bol	 		As String
ENDWSSTRUCT

//Objeto Baixa receber
WSSTRUCT oBaixaRec
	WSDATA Prefixo	  	As String
	WSDATA Numero 		As String
	WSDATA Parcela 		As String
	WSDATA Tipo 		As String
	WSDATA MotBx 		As String
	WSDATA Banco 		As String
	WSDATA Agencia 		As String
	WSDATA Conta 		As String
	WSDATA DataBx 		As String
	WSDATA Histo 		As String
	WSDATA Multa 		As String
	WSDATA Juros 		As String
	WSDATA Descont 		As String
	WSDATA Valrec 		As String
ENDWSSTRUCT

WSSERVICE HHWS002 Description "WS Protheus Integração Financeiro Solaris" 
	WSDATA oCRe		As oCReceber
	WSDATA oBxRe	As oBaixaRec
	WSDATA NumCNPJ	As String
	//Retorno Log da Alteração CReceber
	WSDATA RetInt   As Array of ResultFin
	//Metodos
	WSMETHOD AlteraCReceber Description "WS Protheus Alterar Titulo SE1"
	WSMETHOD BaixaCReceber Description "WS Protheus Baixa de Titulo SE1"
ENDWSSERVICE

/*
Método.......: AlteraCReceber
Objetivo.....: Altera Títulos a Receber Protheus
Autor........: Anderson Arrais
Data.........: 23/03/2017
*/
*----------------------------------------------------------------------------------*
 WSMETHOD AlteraCReceber WSRECEIVE oCRe,NumCNPJ WSSEND RetInt WSSERVICE HHWS002
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cPrefi		:= PadR(::oCRe:Prefixo , Len(SE1->E1_PREFIXO) )
Local cNum			:= PadR(::oCRe:Numero  , Len(SE1->E1_NUM) )
Local cParc			:= PadR(::oCRe:Parcela , Len(SE1->E1_PARCELA) )
Local cTipo			:= PadR(::oCRe:Tipo    , Len(SE1->E1_TIPO) )
Local cArqLog		:= ""
Local cChave		:= cPrefi+cNum+cParc+cTipo
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aCabecSE1		:= {}
Local aEmp			:= {}

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SE1",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aCabecSE1,{"E1_FILIAL"		, xFilial("SE1")   											, Nil})
AADD(aCabecSE1,{"E1_PREFIXO"	, cPrefi , Nil})
AADD(aCabecSE1,{"E1_NUM" 		, cNum   , Nil})
AADD(aCabecSE1,{"E1_PARCELA" 	, cParc  , Nil})
AADD(aCabecSE1,{"E1_TIPO"		, cTipo  , Nil})
AADD(aCabecSE1,{"E1_P_COBEX"	, SubStr(Alltrim(::oCRe:CobraEx) ,1, Len(SE1->E1_P_COBEX))	, Nil})
AADD(aCabecSE1,{"E1_P_DATEX"	, StoD(cvaltochar(::oCRe:DataCEx))							, Nil})
AADD(aCabecSE1,{"E1_VENCREA"	, StoD(cvaltochar(::oCRe:VencRel))							, Nil})
AADD(aCabecSE1,{"E1_ACRESC"		, VAL(STRTRAN(::oCRe:ValAcre,',','.'))						, Nil})
AADD(aCabecSE1,{"E1_DECRESC"	, VAL(STRTRAN(::oCRe:ValDesc,',','.'))	   					, Nil})
//AOA - 20/10/2017 - Novo tratamento de cobrança ID46
AADD(aCabecSE1,{"E1_P_BOL"		, Alltrim(::oCRe:Bol)					   					, Nil})

//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHFIN005" , GetEnvServer() , .T. , aEmp , aCabecSE1 , cPrefi , cNum , cParc , cTipo )

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
Método.......: BaixaCReceber
Objetivo.....: Baixa Títulos a Receber Protheus
Autor........: Anderson Arrais
Data.........: 04/04/2017
*/
*----------------------------------------------------------------------------------*
 WSMETHOD BaixaCReceber WSRECEIVE oBxRe,NumCNPJ WSSEND RetInt WSSERVICE HHWS002
*----------------------------------------------------------------------------------*
Local lInclui		:= .T.
Local lErro			:= .F.

Local cPrefi		:= PadR(::oBxRe:Prefixo , TamSX3("E1_PREFIXO")[1] )
Local cNum			:= PadR(::oBxRe:Numero  , TamSX3("E1_NUM")[1] )
Local cParc			:= PadR(::oBxRe:Parcela , TamSX3("E1_PARCELA")[1] )
Local cTipo			:= PadR(::oBxRe:Tipo    , TamSX3("E1_TIPO")[1] )
Local cArqLog		:= ""
Local cChave		:= cPrefi+cNum+cParc+cTipo
Local cContInt		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aBaixSE1		:= {}
Local aEmp			:= {}

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SE1",cChave,lInclui,cContInt,cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

AADD(aBaixSE1,{"E1_FILIAL"		, xFilial("SE1")   											, Nil})
AADD(aBaixSE1,{"E1_PREFIXO"		, cPrefi, Nil})
AADD(aBaixSE1,{"E1_NUM" 		, cNum	, Nil})
AADD(aBaixSE1,{"E1_PARCELA" 	, cParc	, Nil})
AADD(aBaixSE1,{"E1_TIPO"		, cTipo	, Nil})
AADD(aBaixSE1,{"AUTMOTBX" 		, SubStr(Alltrim(::oBxRe:MotBx)   ,1, 3) 					, Nil})
AADD(aBaixSE1,{"AUTBANCO" 		, SubStr(Alltrim(::oBxRe:Banco)   ,1, Len(SE1->E1_PORTADO))	, Nil})
AADD(aBaixSE1,{"AUTAGENCIA"		, PadR(::oBxRe:Agencia  , TamSX3("E1_AGEDEP")[1] )			, Nil})
AADD(aBaixSE1,{"AUTCONTA"		, PadR(::oBxRe:Conta    , TamSX3("E1_CONTA")[1] ) 			, Nil})
AADD(aBaixSE1,{"AUTDTBAIXA"		, StoD(cvaltochar(::oBxRe:DataBx))						  	, Nil})
AADD(aBaixSE1,{"AUTDTCREDITO"	, StoD(cvaltochar(::oBxRe:DataBx))						  	, Nil})
AADD(aBaixSE1,{"AUTHIST"		, SubStr(Alltrim(::oBxRe:Histo)   ,1, Len(SE1->E1_HIST))	, Nil})
AADD(aBaixSE1,{"AUTMULTA"		, VAL(STRTRAN(::oBxRe:Multa,',','.'))						, Nil})
AADD(aBaixSE1,{"AUTJUROS"		, VAL(STRTRAN(::oBxRe:Juros,',','.')) 	   					, Nil})
AADD(aBaixSE1,{"AUTDESCONT"		, VAL(STRTRAN(::oBxRe:Descont,',','.'))	   					, Nil})
AADD(aBaixSE1,{"AUTVALREC"		, VAL(STRTRAN(::oBxRe:Valrec,',','.')) 	   					, Nil})

//Chama função para executar empresa de acordo com o enviado
aLog    := StartJob( "u_HHFIN006" , GetEnvServer() , .T. , aEmp , aBaixSE1 , cPrefi , cNum , cParc , cTipo )

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