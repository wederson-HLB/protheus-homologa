#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : YYEST001 
Parametros  : aEmp,aCabec,aItem,cNumDoc,cNumSerie,cCliFor,cLoja,cCGC
Retorno     : aRet
Objetivos   : Processar Integração de Nota de Entrada  - Web Service
Autor       : Renato Rezende
Cliente		: Todos 
Data/Hora   : 23/05/2017
*/
*--------------------------------------------------------------------------------* 
 User Function YYEST001( aEmp,aCabec,aItem,cNumDoc,cNumSerie,cCliFor,cLoja,cCGC )
*--------------------------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.
Local lCGC		:= .F.

Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= ""

Local aRet		:= {}
Local aCabecSF1	:= {}
Local aItensSD1	:= {}

Local nR		:= 0 
Local nE		:= 0
Local nZ		:= 0
Local nPos		:= 0

Local dBkpDtBase:= CtoD("//")

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

Private cArqLog			:= ""

conout("Entrou YYEST001")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA2" , "SF1" , "SD1" , "SB1" , "SF3" , "SFT" MODULO "EST"
conout("Preparou YYEST001")

dBkpDtBase:= dDataBase

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cNumDoc)
	lErro:= .T.	
	cArqLog += "O campo F1_DOC deve ser preenchido!"+ CRLF
EndIf

//Validando Código do Cliente/Fornecedor
If !Empty(cCGC)
	cChave	:= cNumDoc+cNumSerie+cCGC
	lCGC	:= .T.
	
	//Notas de Devolução ou Beneficiamento	
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "F1_TIPO"})
	
	If Alltrim(aCabec[nPos][2]) $ "D/B"
		DbSelectArea("SA1")
		//Tentando achar por CGC
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1")+cCGC))
			cCliFor:= SA1->A1_COD
			cLoja := SA1->A1_LOJA
		Else
			lErro:= .T.
			cArqLog += "Não encontrado Cliente com o CNPJ/CPF informado."+ CRLF
		EndIf
	Else
		DbSelectArea("SA2")
		//Tentando achar por CGC
		SA2->(DbSetOrder(3))
		If SA2->(DbSeek(xFilial("SA2")+cCGC))
			cCliFor:= SA2->A2_COD
			cLoja := SA2->A2_LOJA
		Else
			lErro:= .T.
			cArqLog += "Não encontrado Fornecedor com o CNPJ/CPF informado."+ CRLF
		EndIf
	EndIf
		
	//Atribuir os dados novos dos códigos de clientes/fornecedores
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "CNPJ"})
	aCabec[nPos][1] := "F1_FORNECE"
	aCabec[nPos][2] := cCliFor		
	//Atribuir os dados novos das lojas de clientes/fornecedores
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "LOJACNPJ"})
	aCabec[nPos][1] := "F1_LOJA"
	aCabec[nPos][2] := cLoja

Else
	cChave := cNumDoc+cNumSerie+cCliFor+cLoja
EndIf 

//Valida o numero do Documento de Entrada
If !Empty(cNumDoc)
	//Verifica se o número já existe no Protheus
	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(xFilial("SF1")+cNumDoc+cNumSerie+cCliFor+cLoja ))
		lErro:=.T.
		cArqLog+="Nota Fiscal "+Alltrim(cNumDoc)+" ja cadastrada no Protheus." + CRLF
	EndIf
EndIf

cContInt += "---Cabeçalho---" + CRLF
For nR:= 1 to Len(aCabec)

	//Monta a String que irá gravar no ZX1.
	cContInt += aCabec[nR][1]+": "

	If ValType(aCabec[nR][2])=="D"
		cContInt += DTOS(aCabec[nR][2]) + CRLF
		aCabec[nR][2] := STOD(DTOS(aCabec[nR][2]))
	ElseIf ValType(aCabec[nR][2])=="N"
		cContInt += Alltrim(cValToChar(aCabec[nR][2])) + CRLF
	Else
		cContInt += Alltrim(aCabec[nR][2])+ CRLF
	EndIf

	//Tratamento no conteúdo enviado
	//-------------------------------
	//Retira caractere especial, acento e deixar Capslock
	If ValType(aCabec[nR][2])=="C"
		aCabec[nR][2]:= UPPER(FwNoAccent(DecodeUTF8(aCabec[nR][2])))
	EndIf
	
	//Troca data base do sistema
	If Alltrim(aCabec[nR][1])=="F1_DTDIGIT"
		dDataBase:= aCabec[nR][2]
	EndIf

	//Array que será utilizado no ExecAuto
	AADD(aCabecSF1,aCabec[nR])
	
	//Campos obrigatórios
	If x3Obrigat(aCabec[nR][1]) .AND. Empty(aCabec[nR][2]) .AND. lInclui 
		lErro:= .T.
		cArqLog += "Campo: "+aCabec[nR][1]+" obrigatorio nao preenchido."+ CRLF
	EndIf
	//Final do tratamento
	//-------------------------------
Next nR

For nE:= 1 to Len(aItem)
	cContInt += "---Itens "+Alltrim(cValToChar(nE))+"---" + CRLF

	//Monta a String que irá gravar no ZX1.
	For nN:=1 to Len(aItem[nE])
	
		cContInt += aItem[nE][nN][1]+": "

		If ValType(aItem[nE][nN][2])=="D"
			cContInt += DTOS(aItem[nE][nN][2]) + CRLF
		ElseIf ValType(aItem[nE][nN][2])=="N"
			cContInt += Alltrim(cValToChar(aItem[nE][nN][2])) + CRLF
		Else
			cContInt += Alltrim(aItem[nE][nN][2])+ CRLF
		EndIf  
        
		//Tratamento no conteúdo enviado
		//-------------------------------
		//Retira caractere especial, acento e deixar Capslock
		If ValType(aItem[nE][nN][2])=="C"
			aItem[nE][nN][2]:= UPPER(FwNoAccent(DecodeUTF8(aItem[nE][nN][2])))
		EndIf
		
		//Campos obrigatórios
		If x3Obrigat(aItem[nE][nN][1]) .AND. Empty(aItem[nE][nN][2]) .AND. lInclui 
			lErro:= .T.
			cArqLog += "Campo Item "+Alltrim(cValToChar(nE))+": "+aItem[nE][nN][1]+" obrigatorio nao preenchido."+ CRLF
		EndIf
		
	Next nN
	
	//Array que será utilizado no ExecAuto
	AADD(aItensSD1,aItem[nE])

	//Final do tratamento
	//-------------------------------
Next nE

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SF1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

//Nota fiscal de entrada
MSExecAuto( {|X,Y| MATA103(X,Y)},aCabecSF1,aItensSD1,If(lInclui,3,4)) 

//Erro ao cadastrar/alterar o cliente 
If lMsErroAuto
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nZ := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nZ])+ CRLF
	Next nZ
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SF1",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Nota Fiscal gerada com sucesso
Else

	If lInclui
		cArqLog 	:= "Nota fiscal "+Alltrim(SF1->F1_DOC)+" foi inserida com sucesso!"
		cResultInt	:= "INC001"
	EndIf
	
	//Grava na Tabela de Log	
	u_HHGEN001("SF1",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,cResultInt)
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)

EndIf

//Retorna a data base
dDataBase:= dBkpDtBase

Return aRet