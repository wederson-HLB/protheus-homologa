#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFAT001 
Parametros  : aEmp,aCabecSA1,cCodCli,cLoja,cCGC
Retorno     : aRet
Objetivos   : Processar Integração de Clientes  - Solaris Web Service
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 25/11/2016
*/
*--------------------------------------------------------------* 
 User Function HHFAT001( aEmp,aCabecSA1,cCodCli,cLoja,cCGC )
*--------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.

Local cArqLog	:= ""
Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= cCodCli+cLoja

Local aRet		:= {}
Local aCabec	:= {}

Local nR		:= 0
Local nPos		:= 0

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

conout("entrou hhfat001")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT" MODULO "FAT"
conout("preparou hhfat001")

//Procurando cliente no sistema
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1") + cCodCli + cLoja ))
	lInclui := .F.
EndIf

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cCodCli).OR.Empty(cLoja)
	lErro:= .T.	
	If Empty(cCodCli)
		cArqLog += "Campo Chave nao preenchido A1_COD"+ Chr( 13 ) + Chr( 10 )
	EndIf
	If Empty(cLoja)	
		cArqLog += "Campo Chave nao preenchido A1_LOJA"+ Chr( 13 ) + Chr( 10 )	
	EndIf	
EndIf

//Monta bloco para comparação exata
nPos := aScan(aCabecSA1,{|aCpos| Upper(AllTrim(aCpos[1])) == "A1_EST"})

//Validando se já existe o CNPJ cadastrado na inclusão
If !Empty(cCGC) .AND. lInclui .AND. Alltrim(aCabecSA1[nPos][2]) <> "EX"
	//Tentando achar por CGC
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1") + cCGC ))
		lErro:= .T.
		cArqLog += "CNPJ/CPF ja Cadastrado"+ Chr( 13 ) + Chr( 10 )
	EndIf
EndIf

For nR:= 1 to Len(aCabecSA1)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		cContInt += aCabecSA1[nR][1]+": "
		cContInt += Alltrim(aCabecSA1[nR][2])+ Chr( 13 ) + Chr( 10 )
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabecSA1[nR][2])=="C"
		aCabecSA1[nR][2]:= UPPER(FwNoAccent(DecodeUTF8(aCabecSA1[nR][2])))
	EndIf

	//Populando campos obrigatorios nao preenchidos
	If Empty(aCabecSA1[nR][2]) .AND. aCabecSA1[nR][1] == "A1_NATUREZ" .AND. lInclui
		aCabecSA1[nR][2] := "1004"	
	EndIf
	If Empty(aCabecSA1[nR][2]) .AND. aCabecSA1[nR][1] == "A1_CONTA" .AND. lInclui
		aCabecSA1[nR][2] := "11211001"	
	EndIf

	//Alteração Preenchendo Array com o que esta no Banco. (Alteração de Clientes)
	If Empty(aCabecSA1[nR][2]) .AND. !lInclui
		aCabecSA1[nR][2] := SA1->&(aCabecSA1[nR][1])
	EndIf

	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aCabecSA1[nR][2]) .OR. nR ==1
		AADD(aCabec,aCabecSA1[nR])
	EndIf
	
	//Campos obrigatórios
	If x3Obrigat(aCabecSA1[nR][1]) .AND. Empty(aCabecSA1[nR][2]) .AND. lInclui 
		lErro:= .T.
		cArqLog += "Campo: "+aCabecSA1[nR][1]+" obrigatorio nao preenchido."+ Chr( 13 ) + Chr( 10 )	
	EndIf
	//Final do tratamento
	//-------------------------------
Next nR

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SA1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

MSExecAuto({ |x,y| Mata030(x,y) } , aCabec ,If(lInclui,3,4))

//Erro ao cadastrar/alterar o cliente 
If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nR := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nR])+CHR(13)+CHR(10)
	Next nR
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SA1",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Cliente cadastrado/alterado com sucesso
Else
	If lInclui
		cArqLog 	:= "Cliente cadastrado com sucesso!"
		cResultInt	:= "INC001"
	Else
		cArqLog 	:= "Cliente Alterado com sucesso!"
		cResultInt	:= "ALT001"
	EndIf
	//Grava na Tabela de Log	
	u_HHGEN001("SA1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet