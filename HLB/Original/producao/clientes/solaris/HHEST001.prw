#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHEST001 
Parametros  : aEmp,aCabecSA2,cCodCli,cLoja,cCGC
Retorno     : aRet
Objetivos   : Processar Integração de Fornecedores  - Solaris Web Service
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 28/11/2016
*/
*--------------------------------------------------------------* 
 User Function HHEST001( aEmp,aCabecSA2,cCodCli,cLoja,cCGC )
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

conout("Entrou no Fonte HHEST001")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA2" , "SF1" , "SD1" , "SB1" , "SF3" , "SFT" MODULO "EST"
conout("Preparou Ambiente HHEST001")

//Procurando cliente no sistema
DbSelectArea("SA2")
SA2->(DbSetOrder(1))
If SA2->(DbSeek(xFilial("SA2") + cCodCli + cLoja ))
	lInclui := .F.
EndIf

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cCodCli).OR.Empty(cLoja)
	lErro:= .T.	
	If Empty(cCodCli)
		cArqLog += "Campo Chave nao preenchido A2_COD"+ Chr( 13 ) + Chr( 10 )
	EndIf
	If Empty(cLoja)	
		cArqLog += "Campo Chave nao preenchido A2_LOJA"+ Chr( 13 ) + Chr( 10 )	
	EndIf	
EndIf

//Monta bloco para comparação exata
nPos := aScan(aCabecSA2,{|aCpos| Upper(AllTrim(aCpos[1])) == "A2_EST"})

//Validando se já existe o CNPJ cadastrado na inclusão
If !Empty(cCGC) .AND. lInclui .AND. Alltrim(aCabecSA2[nPos][2]) <> "EX"
	//Tentando achar por CGC
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2") + cCGC ))
		lErro:= .T.
		cArqLog += "CNPJ/CPF ja Cadastrado"+ Chr( 13 ) + Chr( 10 )
	EndIf
EndIf

For nR:= 1 to Len(aCabecSA2)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		cContInt += aCabecSA2[nR][1]+": "
		cContInt += Alltrim(aCabecSA2[nR][2])+ Chr( 13 ) + Chr( 10 )
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabecSA2[nR][2])=="C"
		aCabecSA2[nR][2]:= UPPER(FwNoAccent(DecodeUTF8(aCabecSA2[nR][2])))
	EndIf

	//Populando campos obrigatorios nao preenchidos
	If Empty(aCabecSA2[nR][2]) .AND. aCabecSA2[nR][1] == "A2_CONTA" .AND. lInclui
		aCabecSA2[nR][2] := "21111001"	
	EndIf
    
	//Alteração Preenchendo Array com o que esta no Banco. (Alteração de Fornecedores)
	If Empty(aCabecSA2[nR][2]) .AND. !lInclui
		If aCabecSA2[nR][1] == "A2_ID_FBFN"
			aCabecSA2[nR][2] := SubStr(Alltrim(SA2->&(aCabecSA2[nR][1])),1,1)
		Else
			aCabecSA2[nR][2] := SA2->&(aCabecSA2[nR][1])
		EndIf
	EndIf

	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aCabecSA2[nR][2]) .OR. nR ==1
		AADD(aCabec,aCabecSA2[nR])
	EndIf
	
	//Campos obrigatórios
	If x3Obrigat(aCabecSA2[nR][1]) .AND. Empty(aCabecSA2[nR][2]) .AND. lInclui 
		lErro:= .T.
		cArqLog += "Campo: "+aCabecSA2[nR][1]+" obrigatorio nao preenchido."+ Chr( 13 ) + Chr( 10 )	
	EndIf
	//Final do tratamento
	//-------------------------------
Next nR

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SA2",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

MSExecAuto({ |x,y| Mata020(x,y) } , aCabec ,If(lInclui,3,4))

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
	u_HHGEN001("SA2",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Fornecedor cadastrado/alterado com sucesso
Else
	If lInclui
		cArqLog 	:= "Fornecedor cadastrado com sucesso!"
		cResultInt	:= "INC001"
	Else
		cArqLog 	:= "Fornecedor Alterado com sucesso!"
		cResultInt	:= "ALT001"
	EndIf
	//Grava na Tabela de Log	
	u_HHGEN001("SA2",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet 