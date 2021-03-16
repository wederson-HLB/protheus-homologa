#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TRYEXCEPTION.CH'

//---------------------------------------------------------------------------
//?efinicao do Web Service                                                ?
//---------------------------------------------------------------------------

WSSTRUCT OrcamentoItens
	WSDATA CK_ITEM as String OPTIONAL
	WSDATA CK_PRODUTO as String OPTIONAL
	WSDATA CK_UM as String OPTIONAL
	WSDATA CK_QTDVEN as String OPTIONAL
	WSDATA CK_PRCVEN as String OPTIONAL
	WSDATA CK_VALOR as String OPTIONAL
	WSDATA CK_OPER as String OPTIONAL
	WSDATA CK_TES as String OPTIONAL
	WSDATA CK_LOCAL as String OPTIONAL
	WSDATA CK_DESCONT as String OPTIONAL
	WSDATA CK_VALDESC as String OPTIONAL
	WSDATA CK_PEDCLI as String OPTIONAL
	WSDATA CK_ITECLI as String OPTIONAL
	WSDATA CK_DESCRI as String OPTIONAL
	WSDATA CK_PRUNIT as String OPTIONAL
	WSDATA CK_OBS as String OPTIONAL
	WSDATA CK_ENTREG as String OPTIONAL
	WSDATA CK_CLASFIS as String OPTIONAL
	WSDATA CK_FILVEN as String OPTIONAL
	WSDATA CK_FILENT as String OPTIONAL
ENDWSSTRUCT

WSSTRUCT Orcamento
	WSDATA CJ_FILIAL as String OPTIONAL
	WSDATA CJ_NUM as String OPTIONAL
	WSDATA CJ_EMISSAO as String OPTIONAL
	WSDATA CJ_CLIENTE as String OPTIONAL
	WSDATA CJ_NOMCLI as String OPTIONAL
	WSDATA CJ_LOJA as String OPTIONAL
	WSDATA CJ_CLIENT as String OPTIONAL
	WSDATA CJ_LOJAENT as String OPTIONAL
	WSDATA CJ_CONDPAG as String OPTIONAL
	WSDATA CJ_DESCPG as String OPTIONAL
	WSDATA CJ_TABELA as String OPTIONAL
	WSDATA CJ_DESC1 as String OPTIONAL
	WSDATA CJ_DESC2 as String OPTIONAL
	WSDATA CJ_DESC3 as String OPTIONAL
	WSDATA CJ_DESC4 as String OPTIONAL
   	WSDATA CJ_COTCLI as String OPTIONAL
	WSDATA CJ_FRETE as String OPTIONAL
	WSDATA CJ_SEGURO as String OPTIONAL
	WSDATA CJ_DESPESA as String OPTIONAL
	WSDATA CJ_FRETAUT as String OPTIONAL
	WSDATA CJ_VALIDA as String OPTIONAL
	WSDATA CJ_TIPLIB as String OPTIONAL
	WSDATA CJ_TPCARGA as String OPTIONAL
	WSDATA CJ_DESCONT as String OPTIONAL
	WSDATA CJ_PDESCAB as String OPTIONAL
	WSDATA CK_Itens  As Array Of OrcamentoItens OPTIONAL
ENDWSSTRUCT

WSSTRUCT PedidoItens
    WSDATA C6_ITEM as String OPTIONAL
	WSDATA C6_PRODUTO as String OPTIONAL
    WSDATA C6_QTDVEN as String OPTIONAL
	WSDATA C6_PRCVEN as String OPTIONAL
	WSDATA C6_PRUNIT as String OPTIONAL
	WSDATA C6_VALOR as String OPTIONAL
	WSDATA C6_TES as String OPTIONAL
	WSDATA C6_NUMORC as String OPTIONAL
	WSDATA C6_PEDCLI as String OPTIONAL
ENDWSSTRUCT

WSSTRUCT Pedido
    WSDATA C5_TIPO as String OPTIONAL
    WSDATA C5_CLIENTE as String OPTIONAL
    WSDATA C5_LOJACLI as String OPTIONAL
    WSDATA C5_LOJAENT as String OPTIONAL
    WSDATA C5_CONDPAG as String OPTIONAL
    WSDATA C5_TABELA as String OPTIONAL
    WSDATA C5_MENNOTA as String OPTIONAL
    WSDATA C5_P_OBSB2 as String OPTIONAL
	WSDATA C5_TPOPVEN as String OPTIONAL
	WSDATA C5_VEND1 as String OPTIONAL
	WSDATA C5_CCUSTO as String OPTIONAL
	WSDATA C5_P_ITEMC as String OPTIONAL
	WSDATA C5_P_FLUIG as String OPTIONAL
    WSDATA C6_Itens as Array of PedidoItens OPTIONAL
ENDWSSTRUCT



WSSERVICE InterfaceEZ4  DESCRIPTION "Interface Protheus/Fluig desenvolvida pela <b>EZ4</b>""
   WSDATA InPut    AS String OPTIONAL
   WSDATA OutPut   AS String OPTIONAL
   WSDATA Tabela   AS Array of String OPTIONAL
   WSDATA NovoOrc  AS Orcamento OPTIONAL
   WSDATA aRetorno  AS Orcamento OPTIONAL
   WSDATA NovoPed  AS Pedido OPTIONAL

   WSMETHOD GetTime          DESCRIPTION "Retorna a hora do servidor. Usado para confirmação de conex?."
   WSMETHOD ExecQry          DESCRIPTION "Recebe uma query, executa e retorna conte?o. Para execução de 'Zoom'.<br> Atentar para a qtde de registros: pode provocar erro de TIME OUT"
   WSMETHOD InsereOrcamento  DESCRIPTION "Cria um or?mento no SIGAFAT. Utiliza o execauto para a função MATA415"
   WSMETHOD InserePedido  DESCRIPTION "Cria um pedido no SIGAFAT. Utiliza o execauto para a função MATA410"
ENDWSSERVICE

*=====================================================================================================================================*
// "Retorna a hora do servidor. Usado para confirmação de conex?."
*=====================================================================================================================================*
WSMETHOD GetTime WSRECEIVE InPut WSSEND OutPut WSSERVICE InterfaceEZ4
   self:output := Dtoc(date())+" "+time()
Return(.T.)


*=====================================================================================================================================*
// "Recebe uma query, executa e retorna conte?o. Para execução de 'Zoom'."
*=====================================================================================================================================*
WSMETHOD ExecQry WSRECEIVE InPut WSSEND Tabela WSSERVICE InterfaceEZ4
Local i:=0, astru:={}
Local lAchou:=.f.
Local cNome := "", ctipo := "", cTam := "", cDec := ""
Local cRegistro := "", nTamTotal := 0 , nTamMax := Val(AllTrim(SUPERGETMV("MV_P_00134",.F.,"2000000")))
Local cHora := Dtoc(date())+" "+time()+" =>"

conout(cHora+"***********  ExecQry     *********")
conout(cHora+"ExecQry - passo 1 - Inicialização de variáveis")
self:Tabela:={}

conout(cHora+"ExecQry - passo 2 - validação; só  executa SELECT")
If Left(Upper(AllTrim( self:InPut)),6) <> "SELECT"
   self:Tabela:={"Somente Select's s? permitidos"}
   self:output := Dtoc(date())+" "+time()
   Return(.T.)
end if

//COMENTADO PARA REMOVER A TENTATIVA DE CONEXAO COM O PROTHEUS, A FIM DE REDUZIR O TEMPO DE RESPOSTA DO SERVIDOR 12/09/2019 (LEO)
//conout(cHora+"ExecQry - passo 3 - validação; Inicia ambiente")
//If ! InicEnv('on')
//   self:Tabela:={"Ambiente não foi iniciado"}
//   self:output := Dtoc(date())+" "+time()
//   Return(.T.)
//end if

conout(cHora+"ExecQry - passo 4 - execução da query")
conout(cHora+self:InPut)
DBUseArea( .T.,"TOPCONN", TCGenQry(,,self:InPut), 'QTMP', .F., .F. )

conout(cHora+"ExecQry - passo 5 - informações de cabeçalho")
QTMP->( aStru := dBStruct() )
for i := 1 to len(aStru) // monta a estrutura retornada para a query
 	cNome += aStru[i,1] + " -||||-"
    cTipo += aStru[i,2] + " -||||-"
    cTam  += AllTrim(str(aStru[i,3])) + " -||||-"
    cDec  += AllTrim(str(aStru[i,4])) + " -||||-"
next i

cNome := left(cNome,len(cNome)-len("-||||-"))

conout(cHora+cNome)
AAdd( self:Tabela, cNome)
nTamTotal += len(cNome)

conout(cHora+"ExecQry - passo 6 - Conteudo da query")
QTMP->( dBGoTop() )
while QTMP->( ! eof() ) .and. nTamTotal < nTamMax
   cRegistro := ""
   for i := 1 to len(aStru)
 	   cRegistro += AllTrim(ToString( QTMP->&(aStru[i,1]) , aStru[i,3] )) + " -||||-"
   next i
   cRegistro := left(cRegistro,len(cRegistro)-len(" -||||-"))
   nTamTotal += len(cRegistro)
   if nTamTotal < nTamMax
      conout(cHora+cRegistro)
      AAdd( self:Tabela, cRegistro)
   endif
   QTMP->( dBSkip() )
end

conout(cHora+"ExecQry - passo 7 - Finalização com sucesso")
QTMP->( dBCloseArea() )
//InicEnv('off')
self:output := Dtoc(date())+" "+time()
conout(cHora+"**********   ExecQry     *********")
Return(.T.)

*=====================================================================================================================================*
// "Cria um or?mento no SIGAFAT. Utiliza o execauto para a função MATA415"
*=====================================================================================================================================*
WSMETHOD InsereOrcamento WSRECEIVE NovoOrc WSSEND OutPut WSSERVICE InterfaceEZ4
	Local aCab := {}, aItens := {},	aItem := {}
	Local aErro := {}, cErro := "", i := 0
	Local cHora := Dtoc(date())+" "+time()+" => "
	Local cStatus:= ''
	Local cTES := ""

	PRIVATE lMsErroAuto := .F.
	PRIVATE lAutoErrNoFile := .T.
	PRIVATE lMsHelpAuto := .T.

	conout(cHora+"***********  InsereOrcamento     *********")
	conout(cHora+"InsereOrcamento - passo 1 - Inicia ambiente")
	If ! InicEnv('on')
	   self:output += "Ambiente nao foi iniciado - "+ Dtoc(date())+" "+time()+ Chr(13) + Chr(10)
	   Return(.T.)
	end if

	conout(cHora+"InsereOrcamento - passo 2 - Inicialização de vari?eis - CAB")

	If ! Empty( self:NovoOrc:CJ_EMISSAO )
		aAdd(aCab,{"CJ_EMISSAO"	,CtoD(self:NovoOrc:CJ_EMISSAO)                        ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_CLIENTE )
	    aAdd(aCab,{"CJ_FILIAL"	,"01",})
		AAdd(aCab,{"CJ_CLIENTE"	,PadR(self:NovoOrc:CJ_CLIENTE,TAMSX3('CJ_CLIENTE')[1]),})
	else
	   self:output += "Cliente n? foi informado."+ Chr(13) + Chr(10)
	EndIf
	If ! Empty( self:NovoOrc:CJ_LOJA )
		AAdd(aCab,{"CJ_LOJA"	,PadR(self:NovoOrc:CJ_LOJA   ,TAMSX3('CJ_LOJA')[1])   ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_CLIENT )
		AAdd(aCab,{"CJ_CLIENT"	,PadR(self:NovoOrc:CJ_CLIENT ,TAMSX3('CJ_CLIENT')[1]) ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_LOJAENT )
		AAdd(aCab,{"CJ_LOJAENT"	,PadR(self:NovoOrc:CJ_LOJAENT,TAMSX3('CJ_LOJAENT')[1]),})
	EndIf
	If ! Empty( self:NovoOrc:CJ_CONDPAG )
		aAdd(aCab,{"CJ_CONDPAG"	,self:NovoOrc:CJ_CONDPAG                              ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_TABELA )
		aAdd(aCab,{"CJ_TABELA"	,self:NovoOrc:CJ_TABELA                               ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESC1 )
		aAdd(aCab,{"CJ_DESC1"	,self:NovoOrc:CJ_DESC1                                ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESC2 )
		aAdd(aCab,{"CJ_DESC2"	,self:NovoOrc:CJ_DESC2                                ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESC3 )
		aAdd(aCab,{"CJ_DESC3"	,self:NovoOrc:CJ_DESC3                                ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESC4 )
		aAdd(aCab,{"CJ_DESC4"	,self:NovoOrc:CJ_DESC4                                ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_COTCLI )
	   aAdd(aCab,{"CJ_COTCLI"	,self:NovoOrc:CJ_COTCLI                           ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_FRETE )
		aAdd(aCab,{"CJ_FRETE"	,Val(self:NovoOrc:CJ_FRETE)                           ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_SEGURO )
		aAdd(aCab,{"CJ_SEGURO"	,Val(self:NovoOrc:CJ_SEGURO)                          ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESPESA )
		aAdd(aCab,{"CJ_DESPESA"	,Val(self:NovoOrc:CJ_DESPESA)                         ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_FRETAUT )
		aAdd(aCab,{"CJ_FRETAUT"	,Val(self:NovoOrc:CJ_FRETAUT)                         ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_VALIDA )
		aAdd(aCab,{"CJ_VALIDA"	,CtoD(self:NovoOrc:CJ_VALIDA)                         ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_TIPLIB )
		aAdd(aCab,{"CJ_TIPLIB"	,self:NovoOrc:CJ_TIPLIB                               ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_TPCARGA )
		aAdd(aCab,{"CJ_TPCARGA"	,self:NovoOrc:CJ_TPCARGA                              ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_DESCONT )
		aAdd(aCab,{"CJ_DESCONT"	,Val(self:NovoOrc:CJ_DESCONT)                         ,})
	EndIf
	If ! Empty( self:NovoOrc:CJ_PDESCAB )
		aAdd(aCab,{"CJ_PDESCAB"	,Val(self:NovoOrc:CJ_PDESCAB)                         ,})
	EndIf


	conout(cHora+"InsereOrcamento - passo 3 - Inicialização de vari?eis - ITEM")

	if Len(self:NovoOrc:CK_Itens) > 0
	   For i := 1 To Len(self:NovoOrc:CK_Itens)
			aItem:= {}

			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_PEDCLI )
				aAdd(aItem,{"CK_PEDCLI"		,self:NovoOrc:CK_Itens[i]:CK_PEDCLI,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_ITECLI )
				aAdd(aItem,{"CK_ITECLI"		,self:NovoOrc:CK_Itens[i]:CK_ITECLI,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_OPER )
				aAdd(aItem,{"CK_OPER"		,self:NovoOrc:CK_Itens[i]:CK_OPER,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_ITEM )
				aAdd(aItem,{"CK_ITEM"		,self:NovoOrc:CK_Itens[i]:CK_ITEM,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_PRODUTO )
				aAdd(aItem,{"CK_PRODUTO"	,self:NovoOrc:CK_Itens[i]:CK_PRODUTO,nil})
		    else
		       self:output += "Produto do item "+self:NovoOrc:CK_Itens[i]:CK_ITEM+ " n? foi informado."+ Chr(13) + Chr(10)
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_UM )
				aAdd(aItem,{"CK_UM"			,self:NovoOrc:CK_Itens[i]:CK_UM,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_QTDVEN )
				aAdd(aItem,{"CK_QTDVEN"		,Val(self:NovoOrc:CK_Itens[i]:CK_QTDVEN),nil})
		    else
		       self:output += "Quantidade do item "+self:NovoOrc:CK_Itens[i]:CK_ITEM+ " n? foi informado."+ Chr(13) + Chr(10)
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_PRCVEN )
				aAdd(aItem,{"CK_PRCVEN"		,Val(self:NovoOrc:CK_Itens[i]:CK_PRCVEN),nil})
		    else
		       self:output += "Preco sugerido do item "+self:NovoOrc:CK_Itens[i]:CK_ITEM+ " n? foi informado."+ Chr(13) + Chr(10)
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_VALOR )
				aAdd(aItem,{"CK_VALOR"		,Val(self:NovoOrc:CK_Itens[i]:CK_VALOR)   ,nil})
			EndIf
			//aAdd(aItem,{"CK_LOCAL"		,"01"        ,nil})

			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_DESCONT )
				aAdd(aItem,{"CK_DESCONT"	,Val(self:NovoOrc:CK_Itens[i]:CK_DESCONT) ,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_VALDESC )
				aAdd(aItem,{"CK_VALDESC"	,Val(self:NovoOrc:CK_Itens[i]:CK_VALDESC) ,".T."})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_DESCRI )
				aAdd(aItem,{"CK_DESCRI"		,self:NovoOrc:CK_Itens[i]:CK_DESCRI       ,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_PRUNIT )
				aAdd(aItem,{"CK_PRUNIT"		,Val(self:NovoOrc:CK_Itens[i]:CK_PRUNIT)  ,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_OBS )
				aAdd(aItem,{"CK_OBS"		,self:NovoOrc:CK_Itens[i]:CK_OBS          ,nil})
			EndIf

			cTES := ""
			dbSelectArea("SA1")
			// De acordo com o arquivo SIX, a chave de pesquisa a A1_FILIAL + A1_COD + A1_LOJA
			dbSetOrder(1)
		    If dbSeek("01" + PadR(self:NovoOrc:CJ_CLIENTE,TAMSX3('CJ_CLIENTE')[1]) + PadR(self:NovoOrc:CJ_LOJA,TAMSX3('CJ_LOJA')[1]), .T.)     // Filial: 01 / Codigo: 000001 / Loja: 02
			cTES := MaTesInt( 2              ; //nEntSai               Numerico                   Documento de 1-Entrada / 2-Saida
		               ,"01"           ; //cTpOper               Caracter                  Tipo de Operação FM_TIPO
		               ,SA1->A1_COD    ; //cClieFor              Caracter                  Codigo do Cliente ou Fornecedor
		               ,SA1->A1_LOJA   ; //cLoja                 Caracter                  Loja do Cliente ou Fornecedor
		               ,"C"            ; //cTipoCF               Caracter                  Tipo C-Cliente / F-Fornecedor
		               ,self:NovoOrc:CK_Itens[i]:CK_PRODUTO    ; //cProduto              Caracter                  Codigo do Produto
		               ,               ; //cCampo                Caracter                  Alias utilizado na funcao
		               ,SA1->A1_TIPO   ; //cTipoCli              Caracter                  Tipo do Cliente F-Cons. Final / L - Prod.Rural / R - Revendedor / S - Solidario / X - Exportacao/Importacao
		               )
			EndIf

			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_TES )
				aAdd(aItem,{"CK_TES"		,self:NovoOrc:CK_Itens[i]:CK_TES          ,nil})
			EndIf

			aAdd(aItem,{"CK_ENTREG"		,DATE() + 2       ,nil})

			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_CLASFIS )
				aAdd(aItem,{"CK_CLASFIS"	,self:NovoOrc:CK_Itens[i]:CK_CLASFIS      ,nil})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_FILVEN )
				aAdd(aItem,{"CK_FILVEN"		,self:NovoOrc:CK_Itens[i]:CK_FILVEN       ,".T."})
			EndIf
			If ! Empty( self:NovoOrc:CK_Itens[i]:CK_FILENT )
				aAdd(aItem,{"CK_FILENT"		,self:NovoOrc:CK_Itens[i]:CK_FILENT       ,".T."})
			EndIf
			aAdd(aItens,aItem)
	  Next i
	else
	   self:output += "Nenhum item foi informado."+ Chr(13) + Chr(10) + "Falha na criação do orçamento."
	endif
	conout(cHora+"InsereOrcamento - passo 4 - Execução da MATA415 ( por execauto )")

	If EMPTY(self:output) != .T.
		Return(.T.)
	EndIf

	TRYEXCEPTION
	   conout(cHora+"Chama MATA415")
	   //MATA415(aCab,aItens,3)
	   aCab := FWVetByDic ( aCab, "SCJ", .F. )
	   aItens := FWVetByDic ( aItens, "SCK", .T. )
	   MSExecAuto({|x,y,z| mata415(x,y,z)},aCab,aItens,3) //Inclusao
	   if lMsErroAuto
	   	  //mostraerro("\system\", "erromata415.log")
	   endif
	CATCHEXCEPTION USING oErroTry
	   cErro := oErroTry:Description + Chr(13) + Chr(10)
	   cErro := oErroTry:ErrorStack + Chr(13) + Chr(10)
	   self:output += cErro
	ENDEXCEPTION NODELSTACKERROR

	conout(cHora+"InsereOrcamento - passo 5 - Tratamento de erro")
	If lMsErroAuto
		aErro := GetAutoGRLog()
		varinfo("Erro", aErro)
		For i := 1 To Len(aErro)
			cErro += aErro[i] + Chr(13) + Chr(10)
		Next i
		self:output += cErro
	    self:output += "Falha, nao foi possivel criar o orcamento."
	Else
	   if Empty(SCJ->CJ_NUM)
	      self:output += "Falha, nao foi possivel criar o orcamento."
	   else
	      self:output := "SUCESSO >>"+ SCJ->CJ_NUM + Chr(13) + Chr(10)
	      cStatus :=if(SCJ->CJ_STATUS=="A", 'ABERTO', 'criado')
	      cStatus :=if(SCJ->CJ_STATUS=="B", 'BAIXADO', cStatus)
	      cStatus :=if(SCJ->CJ_STATUS=="C", 'CANCELADO', cStatus)
	      cStatus :=if(SCJ->CJ_STATUS=="D", 'NAO ORCADO', cStatus)
	      cStatus :=if(SCJ->CJ_STATUS=="E", 'APROVADO', cStatus)
	      self:output += "Status " + cStatus +  " em " + Dtoc(date()) + " " + time() +":"
	   endif
	EndIf
	conout(cHora+"InsereOrcamento - passo 6 - Finalização")
	conout(cHora+"***********  InsereOrcamento     *********")

Return(.T.)



*=====================================================================================================================================*
// "Cria um pedido de venda no SIGAFAT. Utiliza o execauto para a função MATA410"
*=====================================================================================================================================*
WSMETHOD InserePedido WSRECEIVE NovoPed WSSEND OutPut WSSERVICE InterfaceEZ4
	Local aCab := {}, aAllItens := {{},{},{},{}}, aItens := {}, aItem := {}
	Local aErro := {}, cErro := "", i := 0
	Local cHora := Dtoc(date())+" "+time()+" => "
	Local cStatus:= ''
	Local cTES:=''
	Local cNumPed //:= //GETSXENUM("SC5","C5_NUM")
	Local cItem := ''

	PRIVATE lMsErroAuto := .F.
	PRIVATE lAutoErrNoFile := .T.
	PRIVATE lMsHelpAuto := .T.

	conout(cHora+"***********  InserePedido     *********")
	conout(cHora+"InserePedido - passo 1 - Inicia ambiente")

	conout(cHora+"InserePedido - valor EMP - 01")
	If ! InicEnv('on', "01")
	   self:output += "Ambiente nao foi iniciado - "+ Dtoc(date())+" "+time()+ Chr(13) + Chr(10)
	   Return(.T.)
	end if

	For i:= 1 to ("SC5")->(FCOUNT())
	   CriaVar(("SC5")->(FIELD(i)))
	Next i

	For i:= 1 to ("SC6")->(FCOUNT())
	   CriaVar(("SC6")->(FIELD(i)))
	Next i

	conout(cHora+"InserePedido - passo 2 - Inicialização de variáveis - CAB")
	//NUMERO DO PEDIDO RETORNADO DO GETSX8
	cNumPed := GETSXENUM("SC5","C5_NUM")
	//RollBackSx8()
	//cNumPed := GETSXENUM("SC5","C5_NUM")
	//self:output+= cNumPed+" antes do while"

	SC5->(dbSetOrder(1))
    WHILE SC5->(dbSeek(XFILIAL("SC5") + AVKey(cNumPed,'C5_NUM')))
    	cNumPed := cValToChar(VAL(cNumPed)+1)
    ENDDO
   	//self:output+= cNumPed
   	//return .t.
	//ConfirmSX8()
   	aadd(aCab,{"C5_NUM"   ,cNumPed,Nil})

	if ! Empty( self:NovoPed:C5_TIPO )
		M->C5_TIPO := "N"
		aadd(aCab,{"C5_TIPO" ,M->C5_TIPO,Nil})
	endIf
    if ! Empty( self:NovoPed:C5_CLIENTE )
    	M->C5_TIPO := PadR(self:NovoPed:C5_CLIENTE,TAMSX3('C5_CLIENTE')[1])
    	aadd(aCab,{"C5_CLIENTE",M->C5_TIPO,Nil})
    endIf
    if ! Empty( self:NovoPed:C5_LOJACLI )
    	M->C5_LOJACLI := PadR(self:NovoPed:C5_LOJACLI,TAMSX3('C5_LOJACLI')[1])
    	aadd(aCab,{"C5_LOJACLI",M->C5_LOJACLI,Nil})
    endIf
    if ! Empty( self:NovoPed:C5_LOJAENT )
    	M->C5_LOJAENT := self:NovoPed:C5_LOJAENT
    	aadd(aCab,{"C5_LOJAENT",M->C5_LOJAENT,Nil})
    endIf
    if ! Empty( self:NovoPed:C5_CONDPAG )
    	M->C5_CONDPAG := self:NovoPed:C5_CONDPAG
    	aadd(aCab,{"C5_CONDPAG",M->C5_CONDPAG,Nil})
    endIf

    if ! Empty( self:NovoPed:C5_TABELA )
    	M->C5_TABELA := self:NovoPed:C5_TABELA
    	aadd(aCab,{"C5_TABELA",M->C5_TABELA,Nil})
    endIf

    if ! Empty( self:NovoPed:C5_MENNOTA )
    	M->C5_MENNOTA := self:NovoPed:C5_MENNOTA
    	aadd(aCab,{"C5_MENNOTA",M->C5_MENNOTA,Nil})
    endIf
    if ! Empty( self:NovoPed:C5_P_OBSB2 )
    	M->C5_P_OBSB2 := self:NovoPed:C5_P_OBSB2
    	aadd(aCab,{"C5_P_OBSB2",M->C5_P_OBSB2,Nil})
    endIf
    if ! Empty( self:NovoPed:C5_VEND1 )
    	M->C5_VEND1 := self:NovoPed:C5_VEND1
    	aadd(aCab,{"C5_VEND1",M->C5_VEND1,Nil})
    endIf

	M->C5_CCUSTO := self:NovoPed:C5_CCUSTO
	aadd(aCab,{"C5_CCUSTO",M->C5_CCUSTO,Nil})

	M->C5_P_ITEMC := self:NovoPed:C5_P_ITEMC
	aadd(aCab,{"C5_P_ITEMC",M->C5_P_ITEMC,Nil})

    if ! Empty( self:NovoPed:C5_P_FLUIG )
    	M->C5_P_FLUIG := Val(self:NovoPed:C5_P_FLUIG)
    	aadd(aCab,{"C5_P_FLUIG",M->C5_P_FLUIG,Nil})
    endIf

    conout(cHora+"InserePedido - passo 3 - Inicialização de vari?eis - ITEM")
    if Len(self:NovoPed:C6_Itens) > 0
    	For i := 1 To Len(self:NovoPed:C6_Itens)
	        aItem := {}

			cItem := StrZero(i,2)
	        //if ! Empty( self:NovoPed:C6_Itens[i]:C6_ITEM )
	        	M->C6_ITEM := cItem
	        	aadd(aItem,{"C6_ITEM",M->C6_ITEM,Nil})
        	//endIf
        	if ! Empty( self:NovoPed:C6_Itens[i]:C6_PRODUTO )
	        	M->C6_PRODUTO := self:NovoPed:C6_Itens[i]:C6_PRODUTO
	        	aadd(aItem,{"C6_PRODUTO", M->C6_PRODUTO, Nil})
	        endIf
	        if ! Empty( self:NovoPed:C6_Itens[i]:C6_QTDVEN )
	        	M->C6_QTDVEN := Val(self:NovoPed:C6_Itens[i]:C6_QTDVEN)
	        	aadd(aItem,{"C6_QTDVEN", M->C6_QTDVEN, Nil})
	        endIf
	        if ! Empty( self:NovoPed:C6_Itens[i]:C6_PRCVEN )
	        	M->C6_PRCVEN := Round(Val(self:NovoPed:C6_Itens[i]:C6_PRCVEN),2)
	        	aadd(aItem,{"C6_PRCVEN", M->C6_PRCVEN, Nil})
        	endIf
        	if ! Empty( self:NovoPed:C6_Itens[i]:C6_PRUNIT )
	        	M->C6_PRUNIT := Round(Val(self:NovoPed:C6_Itens[i]:C6_PRUNIT),2)
	        	aadd(aItem,{"C6_PRUNIT", M->C6_PRUNIT, Nil})
        	endIf
        	if ! Empty( self:NovoPed:C6_Itens[i]:C6_VALOR )
	        	M->C6_VALOR := Round(Val(self:NovoPed:C6_Itens[i]:C6_VALOR),2)
	        	aadd(aItem,{"C6_VALOR", M->C6_VALOR, Nil})
	        endIf
        	if ! Empty( self:NovoPed:C5_TPOPVEN )
	        	M->C6_OPER := self:NovoPed:C5_TPOPVEN
	        	aadd(aItem,{"C6_OPER", M->C6_OPER, Nil})
	        endIf
	        
	        
        	if ! Empty( self:NovoPed:C6_Itens[i]:C6_PEDCLI )
	        	M->C6_PEDCLI := self:NovoPed:C6_Itens[i]:C6_PEDCLI
	        	aadd(aItem,{"C6_PEDCLI",M->C6_PEDCLI,Nil})
        	endIf
	        
	        //COMENTANDO PARA VALIDAR O CASOS ONDE O SISTEMA ESTA RETORNANDO MESAGEM DE TES INVALIDA ONDE O ERRO É O MESMO
	        cTES := ""
	        SA1->(dbSetOrder(1))
	        If SA1->(dbSeek(XFILIAL("SA1") + AVKey(self:NovoPed:C5_CLIENTE,'C5_CLIENTE') + AVKey(self:NovoPed:C5_LOJACLI,'C5_LOJACLI')))     // Filial: 01 / Codigo: 000001 / Loja: 02
			    cTES := MaTesInt( 2              ; //nEntSai               Numerico                   Documento de 1-Entrada / 2-Saida
		                   ,self:NovoPed:C5_TPOPVEN           ; //cTpOper               Caracter                  Tipo de Operação FM_TIPO
		                   ,SA1->A1_COD    ; //cClieFor              Caracter                  Codigo do Cliente ou Fornecedor
			               ,SA1->A1_LOJA   ; //cLoja                 Caracter                  Loja do Cliente ou Fornecedor
			               ,"C"            ; //cTipoCF               Caracter                  Tipo C-Cliente / F-Fornecedor
			               ,self:NovoPed:C6_Itens[i]:C6_PRODUTO    ; //cProduto              Caracter                  Codigo do Produto
			               ,               ; //cCampo                Caracter                  Alias utilizado na funcao
			               ,SA1->A1_TIPO   ; //cTipoCli              Caracter                  Tipo do Cliente F-Cons. Final / L - Prod.Rural / R - Revendedor / S - Solidario / X - Exportacao/Importacao
			               )
	        	aadd(aItem,{"C6_TES",cTES,Nil})
			EndIf
			conout(cHora+"InserePedido - CAMPO TES - "+ cTES)

	        aadd(aItens,aItem)

        Next i

    else
	   self:output += "Nenhum item informado." + Chr(13) + Chr(10) + "Falha na criação do pedido."
	   conout( cHora + " Nenhum item informado. Falha na criação do pedido.")
    endIf

    If ! EMPTY(self:output)
		Return(.T.)
	EndIf

	conout(cHora+"InserePedido - passo 4 - Execução da MATA410 ( por execauto )")

	bBlock := ErrorBlock(  {|oErroTry|cErro := oErroTry:Description + Chr(13) + Chr(10),cErro := oErroTry:ErrorStack + Chr(13) + Chr(10), self:output += cErro}   )
    begin sequence
	    conout(cHora+"Chama MATA410")
		MSExecAuto({|x,y,z| mata410(x,y,z)}, aCab, aItens, 3 ) //Inclusão
   		conout(cHora+" Rodou ExecAuto MATA410 ")
    end sequence
    ErrorBlock(bBlock)


    /*If ! EMPTY(self:output)
		Return(.T.)
	EndIf*/
    conout(cHora+"InserePedido - passo 5 - Tratamento de erro")
	If lMsErroAuto
		aErro := GetAutoGRLog()
		varinfo("Erro", aErro)
		For i := 1 To Len(aErro)
			cErro += aErro[i] + Chr(13) + Chr(10)
		Next i
		self:output += cErro
	    self:output += "Falha, nao foi possivel criar o pedido."
	    //RollBackSx8()
	Else

	   if Empty(SC5->C5_NUM)
	      self:output += "Falha, nao foi possivel criar o pedido."
	      //RollBackSx8()
	   else
	      self:output := "SUCESSO >>" + SC5->C5_NUM + Chr(13) + Chr(10)
	      cStatus := 'PEDIDO ABERTO'
	      self:output += "Status " + cStatus +  " em " + Dtoc(date()) + " " + time() +":"
	   endif

	EndIf
	conout(cHora+"InserePedido - passo 6 - Finalização")
	conout(cHora+"***********  InserePedido   *********")


Return .T.



*=====================================================================================================================================*
Static Function ToString(uVar, nTam)               // conversao de uVar para texto
*=====================================================================================================================================*
local	cRetorno	:=	""

Default nTam	:=	0

do case
	case Valtype(uVar)=="C" .or. Valtype(uVar)=="M"
		cRetorno:=uVar
	case Valtype(uVar)=="D"
		cRetorno:=DtoC(uVar)
		cRetorno:=StrTran(cRetorno,"/","")
	case Valtype(uVar)=="L"
		cRetorno:=if(uVar,"VERDADEIRO","FALSO")
	case Valtype(uVar)=="N"
		cRetorno:=AllTrim(str(uVar))
		cRetorno:=If(Empty(cRetorno),"0",cRetorno)
endcase
cRetorno:=If(cRetorno==""," ",cRetorno)


if len(cRetorno)<>nTam .and. nTam>0
	cRetorno:=padr(cRetorno,nTam)
endif

return cRetorno

*=====================================================================================================================================*
Static Function InicEnv( OnOff, Emp )
// inicializando ambiente com a primeira empresa/filial disponivel no sigamat
// efetuando logon sem usuario
*=====================================================================================================================================*
Private lConn := .F.
Private cEmpr:="R7"
Private cFil:="01"

if !Empty(Emp)
   cFil:="01"
end if


Set Deleted On

if OnOff = 'on'
   if select("SM0")=0
      DbUseArea(.T.,,"SIGAMAT.EMP","SM0",.T.,.F.)
      DbSetIndex("SIGAMAT.IND")
   endif
   SM0->(dbSetOrder(1))
   IF !SM0->(dbSeek(cEmpr+cFil))
      SM0->(dbGoTop())
      cEmpr := AllTrim(SM0->M0_CODIGO)
      cFil := AllTrim(SM0->M0_CODFIL)
   endif
   RpcClearEnv()
   RpcSetType(3)
   lConn := RpcSetEnv(cEmpr,cFil,,,"FAT")//,"Administrador","","FRT") // tenta conectar sem senha
   conout(cEmpant + " - " + cFilant)
   conout(cEmpr + " - " + cFil)
Elseif OnOff = 'off'
   SM0->( dbCloseArea() )
   RpcClearEnv() // desconecta
   lConn := .t.
endif

Return lConn


/*
cRetorno:=StrTran(cRetorno,"?,"CO")
cRetorno:=StrTran(cRetorno,"?","E")
cRetorno:=StrTran(cRetorno,"?","E")
cRetorno:=StrTran(cRetorno,"?,"a")
cRetorno:=StrTran(cRetorno,"?,"A")
cRetorno:=StrTran(cRetorno,"?,"a")
cRetorno:=StrTran(cRetorno,"?,"A")
cRetorno:=StrTran(cRetorno,"?,"a")
cRetorno:=StrTran(cRetorno,"?,"A")
cRetorno:=StrTran(cRetorno,"?,"a")
cRetorno:=StrTran(cRetorno,"?,"A")
cRetorno:=StrTran(cRetorno,"?,"a")
cRetorno:=StrTran(cRetorno,"?,"A")
cRetorno:=StrTran(cRetorno,"?,"e")
cRetorno:=StrTran(cRetorno,"