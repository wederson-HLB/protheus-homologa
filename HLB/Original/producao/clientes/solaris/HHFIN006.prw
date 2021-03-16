#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFIN006 
Parametros  : aEmp,aCabecSE1,cPrefi,cNum,cParc,cTipo
Retorno     : aRet
Objetivos   : Processar Baixa de Títulos contas a receber  - Solaris Web Service
Autor       : Anderson Arrais
Cliente		: Solaris 
Data/Hora   : 04/04/2017
*/
*--------------------------------------------------------------* 
 User Function HHFIN006(aEmp,aBaixSE1,cPrefi,cNum,cParc,cTipo)
*--------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.

Local cArqLog	:= ""
Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= cPrefi+cNum+cParc+cTipo

Local aRet		:= {}
Local aCabec	:= {}

Local nR		:= 0

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

conout("entrou hhfin006")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SE1" , "SE5" , "SEF" , "SED" , "SA6" , "SA1" , "SEV" , "SEZ" , "SX5" MODULO "FIN"
conout("preparou hhfin006")

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cPrefi).OR.Empty(cNum).OR.Empty(cTipo)
	lErro:= .T.	
	If Empty(cPrefi)
		cArqLog += "Campo Chave nao preenchido E1_PREFIXO"+ Chr( 13 ) + Chr( 10 )
	EndIf
	If Empty(cNum)	
		cArqLog += "Campo Chave nao preenchido E1_NUM"+ Chr( 13 ) + Chr( 10 )	
	EndIf	
	If Empty(cTipo)	
		cArqLog += "Campo Chave nao preenchido E1_TIPO"+ Chr( 13 ) + Chr( 10 )	
	EndIf	
EndIf

For nR:= 1 to Len(aBaixSE1)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		
		cContInt += aBaixSE1[nR][1]+": "
	
		If ValType(aBaixSE1[nR][2])=="D"
			cContInt += DTOS(aBaixSE1[nR][2]) + Chr( 13 ) + Chr( 10 )
		ElseIf ValType(aBaixSE1[nR][2])=="N"
			cContInt += cvaltochar(aBaixSE1[nR][2]) + Chr( 13 ) + Chr( 10 )
		Else
			cContInt += Alltrim(aBaixSE1[nR][2]) + Chr( 13 ) + Chr( 10 )
		EndIf  
		
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aBaixSE1[nR][2])=="C"
		aBaixSE1[nR][2]:= UPPER(DecodeUTF8(FwNoAccent(aBaixSE1[nR][2])))
	EndIf

	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aBaixSE1[nR][2]) .OR. nR ==1
		AADD(aCabec,aBaixSE1[nR])
	EndIf
	
	//Campos obrigatórios
	If x3Obrigat(aBaixSE1[nR][1]) .AND. Empty(aBaixSE1[nR][2])
		lErro:= .T.
		cArqLog += "Campo: "+aBaixSE1[nR][1]+" obrigatorio nao preenchido."+ Chr( 13 ) + Chr( 10 )	
	EndIf
	//Final do tratamento
	//-------------------------------
Next nR

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SE5",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf      

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
SE1->(DbSeek(xFilial("SE1") + cPrefi+cNum+cParc+cTipo ))

MSExecAuto({ |x,y| Fina070(x,y) } , aCabec , 3) 

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
	u_HHGEN001("SE5",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Cliente cadastrado/alterado com sucesso
Else
	cArqLog 	:= "Baixa realizada com sucesso!"
	cResultInt	:= "INC001"

	//Grava na Tabela de Log	
	u_HHGEN001("SE5",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet