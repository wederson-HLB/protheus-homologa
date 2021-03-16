#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFAT002 
Parametros  : aEmp,aCabecSA2,cCodTransp,cCGC
Retorno     : aRet
Objetivos   : Processar Integração de Transportadora  - Solaris Web Service
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 05/12/2016
*/
*--------------------------------------------------------------* 
 User Function HHFAT002( aEmp,aCabecSA4,cCodTransp,cCGC )
*--------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.

Local cArqLog	:= ""
Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= cCodTransp

Local aRet		:= {}
Local aCabec	:= {}

Local nR		:= 0

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

conout("Entrou no Fonte HHFAT002")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA4" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"
conout("Preparou Ambiente HHFAT002")

//Procurando transportadora no sistema
DbSelectArea("SA4")
SA4->(DbSetOrder(1))
If SA4->(DbSeek(xFilial("SA4") + cCodTransp ))
	lInclui := .F.
EndIf

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cCodTransp)
	lErro:= .T.	
	cArqLog += "Campo Chave nao preenchido A4_COD"+ Chr( 13 ) + Chr( 10 )
EndIf

//Validando se já existe o CNPJ cadastrado na inclusão
If !Empty(cCGC).AND.lInclui
	//Tentando achar por CGC
	SA4->(DbSetOrder(3))
	If SA4->(DbSeek(xFilial("SA4") + cCGC ))
		lErro:= .T.
		cArqLog += "CNPJ/CPF ja Cadastrado"+ Chr( 13 ) + Chr( 10 )
	EndIf
EndIf

For nR:= 1 to Len(aCabecSA4)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		cContInt += aCabecSA4[nR][1]+": "
		cContInt += Alltrim(aCabecSA4[nR][2])+ Chr( 13 ) + Chr( 10 )
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabecSA4[nR][2])=="C"
		aCabecSA4[nR][2]:= UPPER(FwNoAccent(DecodeUTF8(aCabecSA4[nR][2])))
	EndIf
    
	//Alteração Preenchendo Array com o que esta no Banco. (Alteração de Transportadora)
	If Empty(aCabecSA4[nR][2]) .AND. !lInclui
		aCabecSA4[nR][2] := SA4->&(aCabecSA4[nR][1])
	EndIf

	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aCabecSA4[nR][2]) .OR. nR ==1
		AADD(aCabec,aCabecSA4[nR])
	EndIf
	
	//Campos obrigatórios
	If x3Obrigat(aCabecSA4[nR][1]) .AND. Empty(aCabecSA4[nR][2]) .AND. lInclui 
		lErro:= .T.
		cArqLog += "Campo: "+aCabecSA4[nR][1]+" obrigatorio nao preenchido."+ Chr( 13 ) + Chr( 10 )	
	EndIf
	//Final do tratamento
	//-------------------------------
Next nR

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SA4",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

MSExecAuto({ |x,y| Mata050(x,y) } , aCabec ,If(lInclui,3,4))

//Erro ao cadastrar/alterar o fornecedor 
If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nR := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nR])+CHR(13)+CHR(10)
	Next nR
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SA4",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Fornecedor cadastrado/alterado com sucesso
Else
	If lInclui
		cArqLog 	:= "Transportadora cadastrada com sucesso!"
		cResultInt	:= "INC001"
	Else
		cArqLog 	:= "Transportadora Alterada com sucesso!"
		cResultInt	:= "ALT001"
	EndIf
	//Grava na Tabela de Log	
	u_HHGEN001("SA4",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet 