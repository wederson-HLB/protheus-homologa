#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHFIN005 
Parametros  : aEmp,aCabecSE1,cPrefi,cNum,cParc,cTipo
Retorno     : aRet
Objetivos   : Processar Alteração de Títulos contas a receber  - Solaris Web Service
Autor       : Anderson Arrais
Cliente		: Solaris 
Data/Hora   : 23/03/2017
*/
*---------------------------------------------------------------* 
 User Function HHFIN005( aEmp,aCabecSE1,cPrefi,cNum,cParc,cTipo)
*---------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .F.
Local lAltTit   := .F.
Local lAltErr   := .F.
Local lAltCob   := .F.

Local cArqLog	:= ""
Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= cPrefi+cNum+cParc+cTipo
Local cPortad   := ""
Local cNumBord  := ""

Local aRet		:= {}
Local aCabec	:= {}

Local nR		:= 0

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

conout("entrou hhfin005")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SE1" MODULO "FIN"
conout("preparou hhfin005")

//Validando campos chaves antes de gravar
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

For nR:= 1 to Len(aCabecSE1)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		cContInt += aCabecSE1[nR][1]+": "
		cContInt += Alltrim(cvaltochar(aCabecSE1[nR][2]))+ Chr( 13 ) + Chr( 10 )
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabecSE1[nR][2])=="C"
		aCabecSE1[nR][2]:= UPPER(DecodeUTF8(FwNoAccent(aCabecSE1[nR][2])))
	EndIf
    
	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aCabecSE1[nR][2]) .OR. nR ==1
		AADD(aCabec,aCabecSE1[nR])
	EndIf
	
	//Final do tratamento
	//-------------------------------
Next nR

//Como não usa execauto será feito replace na base
DbSelectArea("SE1")
SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1") + cPrefi+cNum+cParc+cTipo ))
	If !Empty(SE1->E1_NUMBOR) .AND. !Empty(SE1->E1_IDCNAB)
		If !Empty(aCabecSE1[6][2]) .AND. !Empty(aCabecSE1[6][2]) .AND. SE1->E1_SALDO > 0
			//Atualiza os campos com as informações enviadas 
			RecLock("SE1",.F.)
				SE1->E1_P_COBEX := cvaltochar(aCabecSE1[6][2])//E1_P_COBEX
				SE1->E1_P_DATEX := aCabecSE1[7][2]//E1_P_DATEX
			SE1->(MsUnlock())
		
			//Pega informação de bordero e portado caso tenha
			If !Empty(SE1->E1_NUMBOR)
				cNumBord  := SE1->E1_NUMBOR
				cPortad   := SE1->E1_PORTADO
			EndIf
			lAltTit := .T.
			lAltCob := .T.
		EndIf
		//Siatuação de instrução de cobrança
		lAltErr := .T.
	Else
		MsExecAuto( { |x,y| FINA040(x,y) } , aCabec, 4 ) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
		If !Empty(SE1->E1_NUMBOR)
			cNumBord  := SE1->E1_NUMBOR
			cPortad   := SE1->E1_PORTADO
		EndIf
		lAltTit := .T.
	EndIf
EndIf

If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nR := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nR])+CHR(13)+CHR(10)
	Next nR

ElseIf lAltTit
	If !Empty(cNumBord)
		cArqLog 	+= "Titulo Alterado com sucesso em bordero: "+cNumBord+" - Banco: "+cPortad
		cResultInt	:= "ALTF01"
	Else
		cArqLog 	+= "Titulo Alterado com sucesso!"
		cResultInt	:= "ALTF02"
	EndIf
ElseIf lAltErr
	cArqLog 	+= "Titulo nao alterado, enviado ao banco precisa de instrucao de cobranca."
	cResultInt	:= "ERRF01"
Else
	cArqLog 	+= "Titulo nao localizado!"
	cResultInt	:= "ERRF02"
EndIf

If lAltCob
	cArqLog 	+= "- Alterado apenas informacao de cobranca externa"
EndIf

//Grava na Tabela de Log	
u_HHGEN001("SE1",cChave,lInclui,cContInt,cArqLog)

AADD(aRet,lErro)
AADD(aRet,cResultInt)
AADD(aRet,cArqLog)
AADD(aRet,lInclui)

Return aRet