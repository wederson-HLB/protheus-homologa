#include "protheus.ch"
#include "apwebsrv.ch"
#include "tbiconn.ch"

/*
Funcao      : HHWS004 
Parametros  : Nenhum
Retorno     : RetInt
Objetivos   : Processar Integração Web Service bloqueio e consulta de produto
Autor       : Anderson Arrais
Cliente		: Solaris
Data/Hora   : 05/09/2018
*/

//Log do bloqueio de produto
WSSTRUCT ResultProd
	WSDATA Numero		As String
	WSDATA Log    		As String 
ENDWSSTRUCT

//Log da consulta de produto
WSSTRUCT ResultRProd
	WSDATA RCodPr		As String
	WSDATA RArmaz  		As String 
	WSDATA RSaldo  		As String 
ENDWSSTRUCT

//Bloqueio de produto
WSSTRUCT CadProd
	WSDATA CodProd     		As String  				//B1_COD
	WSDATA Bloq			    As String  				//B1_MSBLQL
ENDWSSTRUCT

WSSTRUCT AProd
	WSDATA ListProd     AS Array Of CadProd
ENDWSSTRUCT

//Consulta de produto
WSSTRUCT ConsulProd
	WSDATA ConCodProd     		As String  				//B1_COD
	WSDATA CArmaz			    As String  				//B1_LOCPAD
ENDWSSTRUCT

WSSTRUCT AConsProd
	WSDATA ListConProd     AS Array Of ConsulProd
ENDWSSTRUCT

WSSERVICE HHWS004 Description "WS Protheus bloqueio/consulta de produto" 
	WSDATA oProd		As AProd
	WSDATA oConsProd	As AConsProd
	WSDATA NumCNPJ		As String
	//Retorno Log
	WSDATA RetInt    As Array of ResultProd
	WSDATA ReCons    As Array of ResultRProd
	//Metodo
	WSMETHOD BloqProduto Description "WS Protheus bloqueio de produto"
	WSMETHOD ConsulProduto Description "WS Protheus Consulta de produto"
ENDWSSERVICE

/*
Método.......: BloqProduto
Objetivo.....: Bloqueio de produto
Autor........: Anderson Arrais
Data.........: 05/09/2018
*/
*----------------------------------------------------------------------------*
 WSMETHOD BloqProduto WSRECEIVE oProd,NumCNPJ WSSEND RetInt WSSERVICE HHWS004
*----------------------------------------------------------------------------*
Local cArqLog		:= ""
Local cCodProd		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
Local aItens		:= {}
Local aEmp			:= {}

Local nR			:= 0

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::RetInt, WSClassNew("Result"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SB1","Produto",.T.,"",cArqLog)

	::RetInt[1]:Numero := "ERR001"
	::RetInt[1]:Log := cArqLog
	Return .T.
EndIf

For nR:= 1 to Len(::oProd:ListProd)
	AADD(aItens, {"B1_COD"		, PadR(::oProd:ListProd[nR]:CodProd,Len(SB1->B1_COD))			,Nil}) // Código do produto
	AADD(aItens, {"B1_MSBLQL"	, PadR(::oProd:ListProd[nR]:Bloq,Len(SB1->B1_MSBLQL)) 			,Nil}) // Bloqueio: 1-SIM / 2-NÃO
	
	cCodProd := PadR(::oProd:ListProd[nR]:CodProd,Len(SB1->B1_COD))
	cBloq	 := PadR(::oProd:ListProd[nR]:Bloq,Len(SB1->B1_MSBLQL)) 
	
	conout("Inicia o Start Job HHFAT003")
	//Chama função para executar empresa de acordo com o enviado
	aLog    := StartJob( "u_HHFAT003" , GetEnvServer() , .T. , aEmp , aItens, cCodProd , cBloq )
	
	conout("Finalizou o Start Job HHFAT003")
	
	If ValType(aLog)== "A"	
		AADD(::RetInt, WSClassNew("Result"))
	
		::RetInt[nR]:Numero	:= aLog[2]
		::RetInt[nR]:Log	:= aLog[3]
	Else
		AADD(::RetInt, WSClassNew("Result"))
	
		::RetInt[nR]:Numero	:= "ERR001"
		::RetInt[nR]:Log	:= "Erro interno, favor contatar o suporte!"
	EndIf
	
	aItens := {}
	
Next nR

Return .T.


/*
Método.......: ConsulProduto
Objetivo.....: Consulta de produto
Autor........: Anderson Arrais
Data.........: 10/09/2018
*/
*-----------------------------------------------------------------------------------*
 WSMETHOD ConsulProduto WSRECEIVE oConsProd,NumCNPJ WSSEND ReCons WSSERVICE HHWS004
*-----------------------------------------------------------------------------------*
Local cArqLog		:= ""
Local cCodProd		:= ""
Local cCNPJ			:= ::NumCNPJ

Local aLog			:= {}
//Local aItens		:= {}
Local aEmp			:= {}

Local nR			:= 0

//Verifica qual empresa deve ser logado
aEmp:= HHEmpLog(cCNPJ)

//Não achou no Sigamat retorna erro
If aEmp[1]== "YY"
	AADD(::ReCons, WSClassNew("ResultRProd"))
	cArqLog:= "CNPJ nao encontrado no ambiente."
	//Grava na Tabela de Log
	u_HHGEN001("SB1","ConsProduto",.T.,"",cArqLog)

	::ReCons[1]:RCodPr	 := cArqLog
	::ReCons[1]:RArmaz 	 := ""
	::ReCons[1]:RSaldo 	 := ""
	Return .T.
EndIf

For nR:= 1 to Len(::oConsProd:ListConProd)
	cCodProd := PadR(::oConsProd:ListConProd[nR]:ConCodProd,Len(SB1->B1_COD))
	cArmaz	 := PadR(::oConsProd:ListConProd[nR]:CArmaz,Len(SB1->B1_LOCPAD)) 
	
	conout("Inicia o Start Job HHFAT004")
	//Chama função para executar empresa de acordo com o enviado
	aLog    := StartJob( "u_HHFAT004" , GetEnvServer() , .T. , aEmp , cCodProd , cArmaz )
	
	conout("Finalizou o Start Job HHFAT004")
	
	If ValType(aLog)== "A"	
		AADD(::ReCons, WSClassNew("ResultRProd"))

		::ReCons[nR]:RCodPr		:= aLog[2]
		::ReCons[nR]:RArmaz		:= aLog[3]
		::ReCons[nR]:RSaldo		:= aLog[4]
	Else
		AADD(::ReCons, WSClassNew("ResultRProd"))
	
		::ReCons[nR]:RCodPr		:= "ERR001"
		::ReCons[nR]:RArmaz		:= "Erro interno, favor contatar o suporte!"
		::ReCons[nR]:RSaldo		:= ""
	EndIf
	
	//aItens := {}
	
Next nR

Return .T.

/*
Funcao      : HHEmpLog 
Parametros  : cCnpj
Retorno     : aEmp
Objetivos   : Busca qual empresa deve ser logado
Autor       : Renato Rezende
Data/Hora   : 02/05/2017
*/
*-------------------------------*
 Static Function HHEmpLog(cCnpj)
*-------------------------------*
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