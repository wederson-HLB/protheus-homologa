#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFAT003 
Parametros  : aEmp,aItens
Retorno     : aRet
Objetivos   : Processar bloqueio de produto  - Web Service
Autor       : Anderson Arrais 
Data/Hora   : 05/09/2018
*/
*---------------------------------------------------* 
 User Function HHFAT003( aEmp,aItens,cCodProd,cBloq )
*---------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.

Local cResultInt:= ""
Local cChave	:= cCodProd

Local aRet		:= {}

Local nR		:= 0 

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

Private cArqLog			:= ""

conout("Entrou HHFAT003")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SB1"  MODULO "FAT"
conout("Preparou HHFAT003")

MSExecAuto({ |x,y| Mata010(x,y) } , aItens ,4)

If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nR := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nR])+CHR(13)+CHR(10)
	Next nR
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SB1",cChave,lInclui,"",cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Produto bloqueado/desbloqueado com sucesso
Else
    If Alltrim(cValToChar(cBloq)) $ "1"
		cArqLog 	:= "Produto Bloqueado com sucesso!"
		cResultInt	:= cCodProd  
	Else
		cArqLog 	:= "Produto Desbloqueado com sucesso!"
		cResultInt	:= cCodProd  	
	EndIf
	//Grava na Tabela de Log	
	u_HHGEN001("SB1",cChave,lInclui,"",cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet