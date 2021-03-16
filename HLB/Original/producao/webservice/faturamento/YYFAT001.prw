#Include "Protheus.Ch"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao      : YYFAT001 
Parametros  : aEmp,aCabec,aItens,cPedNum,cPedRef,cCodCli,cLoja,cCGC
Retorno     : aRet
Objetivos   : Processar Integração de Nota de Saída  - Web Service
Autor       : Renato Rezende
Cliente		: Todos 
Data/Hora   : 03/05/2017
*/
*--------------------------------------------------------------------------------* 
 User Function YYFAT001( aEmp,aCabec,aItem,cPedNum,cPedRef,cCodCli,cLoja,cCGC )
*--------------------------------------------------------------------------------*
Local lErro 	:= .F.
Local lInclui	:= .T.
Local lCGC		:= .F.
Local lUsouGetC5:= .F.

Local cContInt	:= ""
Local cResultInt:= ""
Local cChave	:= ""

Local aRet		:= {}
Local aCabecSC5	:= {}
Local aItensSC6	:= {}

Local nR		:= 0 
Local nE		:= 0
Local nZ		:= 0
Local nPos		:= 0

Local dBkpDtBase:= CtoD("//")

Private lMsHelpAuto		:= .T.
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T. //Caso queira utilizar a função MostraErro() deverá deixar esse parâmetro como .F.

Private cArqLog			:= ""

conout("Entrou YYFAT001")
conout(aEmp[1]+" "+aEmp[2])

RpcClearEnv()
RpcSetType( 3 )
PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA1" , "SF2" , "SD2" , "SB1" , "SF3" , "SFT", "SC5", "SC6" MODULO "FAT"
conout("Preparou YYFAT001")

dBkpDtBase:= dDataBase

//Validando campos chaves antes de chamar o ExecAuto
If Empty(cPedNum).AND.Empty(cPedRef)
	lErro:= .T.	
	cArqLog += "O campo C5_NUM ou o campo C5_P_REF deve ser preenchido!"+ CRLF
Else 
	//Validar numero do pedido	
	lErro:= VlNumPed(cPedNum,cPedRef) 
	//Pega do SXE o numero do pedido
	If Empty(cPedNum)
		cPedNum := GETSXENUM("SC5","C5_NUM")
		nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "C5_NUM"})
		aCabec[nPos][2] := cPedNum
		lUsouGetC5 := .T.
	EndIf
EndIf

//Validando Código do Cliente/Fornecedor
If !Empty(cCGC)
	cChave	:= cPedNum+cPedRef+cCGC
	lCGC	:= .T.
	
	//Notas de Devolução ou Beneficiamento	
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "C5_TIPO"})
	
	If !Alltrim(aCabec[nPos][2]) $ "D/B"
		DbSelectArea("SA1")
		//Tentando achar por CGC
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1")+cCGC))
			cCodCli:= SA1->A1_COD
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
			cCodCli:= SA2->A2_COD
			cLoja := SA2->A2_LOJA
		Else
			lErro:= .T.
			cArqLog += "Não encontrado Fornecedor com o CNPJ/CPF informado."+ CRLF
		EndIf
	EndIf
		
	//Atribuir os dados novos dos códigos de clientes/fornecedores
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "CNPJ"})
	aCabec[nPos][1] := "C5_CLIENTE"
	aCabec[nPos][2] := cCodCli		
	//Atribuir os dados novos das lojas de clientes/fornecedores
	nPos := aScan(aCabec,{|aCpos| Upper(AllTrim(aCpos[1])) == "LOJACNPJ"})
	aCabec[nPos][1] := "C5_LOJACLI"
	aCabec[nPos][2] := cLoja

Else
	cChave := cPedNum+cPedRef+cCodCli+cLoja
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
	If Alltrim(aCabec[nR][1])=="C5_EMISSAO"
		dDataBase:= aCabec[nR][2]
	EndIf

	//Array que será utilizado no ExecAuto
	AADD(aCabecSC5,aCabec[nR])

	
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
		
		//Tratamento para CFOP
		If Alltrim(aItem[nE][nN][1])=="C6_CF" .AND. Empty(aItem[nE][nN][2])
			nPos := aScan(aItem[nE],{|aCpos| Upper(AllTrim(aCpos[1])) == "C6_TES"})
			
			//Buscar CFOP na TES
			If Alltrim(aItem[nE][nPos][1]) == "C6_TES" .AND. !Empty(Alltrim(aItem[nE][nPos][2]))
				DbSelectArea("SF4")
				SF4->(DbSetOrder(1))
				If SF4->(DbSeek(xFilial("SF4")+Alltrim(aItem[nE][nPos][2])))
					aItem[nE][nN][2]:= SF4->F4_CF
				EndIf
			EndIf
		EndIf
		
		//Campos obrigatórios
		If x3Obrigat(aItem[nE][nN][1]) .AND. Empty(aItem[nE][nN][2]) .AND. lInclui 
			lErro:= .T.
			cArqLog += "Campo Item "+Alltrim(cValToChar(nE))+": "+aItem[nE][nN][1]+" obrigatorio nao preenchido."+ CRLF
		EndIf
		
	Next nN

	AADD(aItensSC6,aItem[nE])

	//Final do tratamento
	//-------------------------------
Next nE

If lErro
	//Grava na Tabela de Log
	u_HHGEN001("SC5",cChave,lInclui,cContInt,cArqLog)

	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
		
	Return aRet
EndIf

//Pedido de Compra
MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCabecSC5, aItem, If(lInclui,3,4))

//Erro ao cadastrar/alterar o cliente 
If lMsErroAuto
  	If lUsouGetC5
  		//RRP - 11/07/2017 - Ajuste para pedido que sao incluidos com erro.
  		If SC5->(DbSeek(xFilial("SC5")+SC5->C5_NUM))
  			Confirmsx8()	
  	   	Else
			ROLLBACKSXE()		  		
	  	EndIf
  	EndIf
	//Loop DoMostra() erro
	//------------------
	aLog := GetAutoGRLog()
	For nZ := 1 To Len(aLog)
		cArqLog+= Alltrim(aLog[nZ])+ CRLF
	Next nZ
	//------------------
	//Grava na Tabela de Log
	u_HHGEN001("SC5",cChave,lInclui,cContInt,cArqLog)
		 
	AADD(aRet,lErro)
	AADD(aRet,"ERR001")
	AADD(aRet,cArqLog)
	AADD(aRet,lInclui)
	
//Pedido cadastrado/alterado com sucesso
Else
  	If lUsouGetC5
		Confirmsx8()    
	EndIf

	//Gravar nota fiscal de saída	
	aLogRet := GravaNota(cPedNum,cPedRef)	
	
	//Grava na Tabela de Log	
	u_HHGEN001("SC5",cChave,lInclui,cContInt,aLogRet[1])

	AADD(aRet,lErro)
	AADD(aRet,aLogRet[2])
	AADD(aRet,aLogRet[1])
	AADD(aRet,lInclui)

EndIf

//Retorna a data base
dDataBase:= dBkpDtBase

Return aRet

/*
Funcao      : GravaNota 
Parametros  : cPedNum,cPedRef
Retorno     : aLogRet
Objetivos   : Gera Nota de Saída através do pedido de venda
Autor       : Renato Rezende
Data/Hora   : 04/05/2017
*/
*--------------------------------------------* 
 Static Function GravaNota(cPedNum,cPedRef)
*--------------------------------------------* 
Local aLogRet		:= Array(2)
Local aPvlNfs		:= {}
Local aBloqueio		:= {}

Local cNFSSer		:= ""
Local cNFSNum		:= ""

Local nR			:= 0

Local lContOnline	:= .F.
Local lMostraLan	:= .F.


SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+cPedNum ))
 
//Buscando número e série da nota
If AT("-",Alltrim(cPedRef)) > 0
	cNFSSer	:= SUBSTR(Alltrim(cPedRef),AT("-",alltrim(cPedRef))+1,3)
	cNFSNum	:= SUBSTR(Alltrim(cPedRef),1,AT("-",alltrim(cPedRef))-1) 
Else
	cNFSNum := Alltrim(cPedRef)
	cNFSSer := ""
Endif

aLogRet[1] := "Ped. de Venda "+Alltrim(cPedNum)+" inserido / NF "+cNFSNum+"-"+cNFSSer+" nao inserida!" + CRLF
aLogRet[2] := "INC001"

If !Empty(Alltrim(cPedRef))	
		                                                                                                                       
	If !Empty(Alltrim(cNFSSer))

		//Liberacao do Pedido de Venda
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		    
		If !Empty( aBloqueio )
			//Se houve algum bloqueio nao gera NF
			For nR := 1 To Len( aBloqueio )
				aLogRet[1] += "Pedido " + aBloqueio[ i ][ 1 ] + " - Produto " + aBloqueio[ i ][ 4 ] + " com bloqueio de credito."+ CRLF
			Next nR
		
		Else
			//Gera nota fiscal de saida.
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek( xFilial("SX5") + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cNFSSer , Len( SX5->X5_CHAVE ) ) ) )
		
				//Atualiza o numero para o enviado no campo de referencia.
				SX5->( RecLock( "SX5" , .F. ) )
				SX5->X5_DESCRI := AllTrim( cNFSNum )
				SX5->( MSUnlock() )
					
				cRet := MaPvlNfs( aPvlNfs ,;
						  cNFSSer ,;
			        	  lMostraLan ,; 	//Mostra Lancamentos Contabeis
				          .F. ,; 			//Aglutina Lancamentos
				          lContOnline ,; 	//Cont. On Line ?
				          .F. ,; 			//Cont. Custo On-line ?
				          .F. ,; 			//Reaj. na mesma N.F.?
				          3 ,; 				//Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
				          1,; 				//Arred.prc unit vist?  Sempre/Nunca/Consumid.final
				          .F.,;  			//Atualiza Cli.X Prod?
				          .F. ,,,,,,; 		//Ecf ?
				          dDataBase )
				
				aLogRet[1] := "Pedido de venda "+Alltrim(cPedNum)+" e NF "+cNFSNum+"-"+cNFSSer+" foi inserida." + CRLF
				aLogRet[2] := "INC002"
			Else
				aLogRet[1] += "Serie " + cNFSSer + " nao parametrizada no sistema." + CRLF
			EndIf
		Endif
               	
	Else
		aLogRet[1] += "Serie da nota nao informada." + CRLF
	Endif   

Else
	aLogRet[1] += "O campo C5_P_REF nao informado." + CRLF
Endif

Return aLogRet

/*
Funcao      : GetNumPed 
Parametros  : cPedNum,cPedRef
Retorno     : aPedRet
Objetivos   : Validar o número do Pedido de Venda
Autor       : Renato Rezende
Data/Hora   : 08/05/2017
*/
*----------------------------------------------*
 Static Function VlNumPed(cPedNum,cPedRef)
*----------------------------------------------*
Local lErro 	:= .F.

Local cQrC5Ref	:= ""

If !Empty(cPedRef)
	cQrC5Ref:=" SELECT C5_NUM,C5_P_REF FROM "+RetSqlName("SC5")+CRLF
	cQrC5Ref+="  WHERE D_E_L_E_T_='' AND C5_FILIAL='"+xFilial("SC5")+"' AND UPPER(C5_P_REF)=UPPER('"+alltrim(cPedRef)+"')"
	
	If Select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	
	QRYTEMP->(DbGoTop())
	        
	If nRecCount >0
		lErro:=.T.
		cArqLog+="Campo C5_P_REF: Ja existe referencia cadastrada: "+Alltrim(QRYTEMP->C5_P_REF)+"!" + CRLF 
	EndIf
EndIf

//Valida o numero do Pedido de Venda
If !Empty(cPedNum)
	//Verifica se o número já existe no Protheus
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5")+cPedNum ))
		lErro:=.T.
		cArqLog+="Pedido de venda "+Alltrim(cPedNum)+" ja cadastrado no Protheus." + CRLF
	EndIf
EndIf

Return lErro