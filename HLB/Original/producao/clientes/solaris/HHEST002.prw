#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : HHEST002 
Parametros  : aEmp,aCabecSB1,cCodProd
Retorno     : aRet
Objetivos   : Processar Integração de Produtos  - Solaris Web Service
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 28/11/2016
*/
*--------------------------------------------------------------* 
 User Function HHEST002( aEmp,aCabecSB1,cCodProd )
*--------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.

Local cArqLog	:= ""
Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= cCodProd

Local aRet		:= {}
Local aCabec	:= {}

Local nR		:= 0
Local nRi		:= 0
Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

conout("Entrou no Fonte HHEST002")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SB1" , "SF1" , "SD1" , "SF3" , "SFT" MODULO "EST"
conout("Preparou Ambiente HHEST002 ")

//Procurando produto no sistema
DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1") + cCodProd ))
	lInclui := .F.
//RRP - 24/03/2017 - Ajuste após atualização do sistema. Execauto Mata010 parou de incluir produtos.
Else
	SB1->(DbGoTop())
EndIf

//Validando campo chave antes de chamar o ExecAuto
If Empty(cCodProd)
	lErro:= .T.	
	If Empty(cCodProd)
		cArqLog += "Campo Chave nao preenchido B1_COD"+ Chr( 13 ) + Chr( 10 )
	EndIf
EndIf

For nR:= 1 to Len(aCabecSB1)
	//Não gravar campo Filial no Log
	//Monta a String que irá gravar no ZX1.
	If !nR==1
		cContInt += aCabecSB1[nR][1]+": "
		cContInt += Alltrim(aCabecSB1[nR][2])+ Chr( 13 ) + Chr( 10 )
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabecSB1[nR][2])=="C"
		aCabecSB1[nR][2]:= UPPER(FwNoAccent(DecodeUTF8(aCabecSB1[nR][2])))
	EndIf

	//Populando campos obrigatorios nao preenchidos
	If Empty(aCabecSB1[nR][2]) .AND. aCabecSB1[nR][1] == "B1_LOCPAD" .AND. lInclui
		aCabecSB1[nR][2] := "01"
	EndIf
	If Empty(aCabecSB1[nR][2]) .AND. aCabecSB1[nR][1] == "B1_CONTA" .AND. lInclui
		aCabecSB1[nR][2] := "11317001"
	EndIf
	If Empty(aCabecSB1[nR][2]) .AND. aCabecSB1[nR][1] == "B1_POSIPI" .AND. lInclui
		aCabecSB1[nR][2] := "99999999"
	EndIf
    
	//Alteração Preenchendo Array com o que esta no Banco. (Alteração de Produtos)
	If Empty(aCabecSB1[nR][2]) .AND. !lInclui
		aCabecSB1[nR][2] := SB1->&(aCabecSB1[nR][1])
	EndIf
    
	//Retirando do array caso esteja em branco
	//Array que será utilizado no ExecAuto
	If !Empty(aCabecSB1[nR][2]) .OR. nR ==1 
		//Valida se campo existe na base
		If FieldPos(aCabecSB1[nR][1]) > 0
			AADD(aCabec,aCabecSB1[nR])
		Else
			//Campo não existe, grava no log
			u_HHGEN001("SB1",cChave,lInclui,cContInt,"Campo "+aCabecSB1[nR][1]+" não existe.")
		EndIf
	EndIf
	//Campos obrigatórios
	If x3Obrigat(aCabecSB1[nR][1]) .AND. Empty(aCabecSB1[nR][2]) .AND. lInclui 
		lErro:= .T.
		cArqLog += "Campo: "+aCabecSB1[nR][1]+" obrigatorio nao preenchido."+ Chr( 13 ) + Chr( 10 )	
	EndIf
	//Final do tratamento
	//------------------------------
Next nR

//AOA - 03/12/2018 - Ajuste para incluir espaço no código do produto para o execauto seekar corretamente.
For nRi:= 1 to Len(aCabec)
	If aCabec[nRi][1] == "B1_COD"
		aCabec[nRi][2]:= aCabec[nRi][2]+Space(TamSX3("B1_COD")[1]-Len(aCabec[nRi][2]))
	EndIf
Next nRi

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SB1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERI001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

MSExecAuto({ |x,y| Mata010(x,y) } , aCabec ,If(lInclui,3,4))

//Erro ao cadastrar/alterar o produto 
If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nR := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nR])+CHR(13)+CHR(10)
	Next nR
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SB1",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERC001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Produto cadastrado/alterado com sucesso
Else
	If lInclui
		cArqLog 	:= "Produto cadastrado com sucesso!"
		cResultInt	:= "INC001"
	Else
		cArqLog 	:= "Produto Alterado com sucesso!"
		cResultInt	:= "ALT001"
	EndIf
	//Grava na Tabela de Log	
	u_HHGEN001("SB1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

Return aRet 
