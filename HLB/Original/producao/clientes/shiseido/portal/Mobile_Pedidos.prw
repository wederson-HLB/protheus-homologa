#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT StItensPed
	WSDATA produto  As String
	WSDATA Quant    As Float
	WSDATA Preco    As Float
ENDWSSTRUCT

WSSTRUCT ItensPed
	WSDATA ItemPed As Array of StItensPed
ENDWSSTRUCT

WSSTRUCT ResultPed
	WSDATA Numero As String
	WSDATA Log    As String 
ENDWSSTRUCT

WsService Mobile_Pedidos Description "MOBILE LOGOS - Geração dos Pedidos de Vendas."

   WSDATA Vendedor  As String
   WSDATA Emissao   As String
   WSDATA TipoPed   As String
   WSDATA Cliente   As String
   WSDATA Loja      As String
   WSDATA CCusto    As String
   WSDATA Desconto  As Float
   WSDATA ItemConta As String
   WSDATA TipoFrete As String
   WSDATA Frete     As Float
   WSDATA Despesa   As Float
   WSDATA Seguro    As Float
   WSDATA Volumes   As Float
   WSDATA PesoBruto As Float
   WSDATA PesoLiq   As Float 
   WSDATA MenNota   As String
   WSDATA Obs       As String
   WSDATA Itens     As ItensPed
   WSDATA Retorno   As Array of ResultPed
   
   WsMethod GeraPedidos Description "MOBILE LOGOS - Geração dos Pedidos."

EndWsService

WsMethod GeraPedidos WsReceive Vendedor, Emissao, TipoPed, Cliente, Loja, Desconto, CCusto, ItemConta, TipoFrete, Frete, Despesa, Seguro,;
							   Volumes, PesoBruto, PesoLiq, MenNota, Obs, Itens WsSend Retorno WsService Mobile_Pedidos

Local nX        := 0     
Local cItem     := "01"
Local cOper     := "01"
Local cNum      := ""
Local aCabSC5   := {}
Local aItSC6    := {}
Local aItens    := {}
lMsHelpAuto := .T.
lMsErroAuto := .F.

SA1->(dbSetOrder(1))                                    
SA1->(dbSeek(xFilial("SA1") + Cliente + Loja))       

If TipoPed == "V"    
	cOper := "01"
ElseIf TipoPed == "A"
	cOper := "02"
ElseIf TipoPed == "T"
	cOper := "03"
ElseIf TipoPed == "R"
	cOper := "04"
EndIf

cNum := U_R7FAT003() //GetSxeNum("SC5","C5_NUM")
       
aAdd(aCabSC5,{"C5_FILIAL" 		, xFilial("SC5")	,Nil})
aAdd(aCabSC5,{"C5_NUM"	  		, cNum			   	,Nil})
aAdd(aCabSC5,{"C5_TIPO"	  		, "N"			   	,Nil})
aAdd(aCabSC5,{"C5_CLIENTE"		, Cliente			,Nil})
aAdd(aCabSC5,{"C5_LOJACLI"		, Loja				,Nil})
aAdd(aCabSC5,{"C5_EMISSAO"		, dDataBase			,Nil})
aAdd(aCabSC5,{"C5_CCUSTO"		, CCusto			,Nil})
aAdd(aCabSC5,{"C5_P_ITEMC"		, ItemConta			,Nil})
aAdd(aCabSC5,{"C5_TPFRETE"		, TipoFrete			,Nil})
aAdd(aCabSC5,{"C5_FRETE"		, Frete				,Nil})
aAdd(aCabSC5,{"C5_DESPESA"		, Despesa			,Nil})
aAdd(aCabSC5,{"C5_SEGURO"		, Seguro			,Nil})
aAdd(aCabSC5,{"C5_VOLUME1"		, Volumes			,Nil})
aAdd(aCabSC5,{"C5_PBRUTO"		, PesoBruto			,Nil})
aAdd(aCabSC5,{"C5_PESOL"		, PesoLiq			,Nil})
aAdd(aCabSC5,{"C5_MENNOTA"		, MenNota			,Nil})
aAdd(aCabSC5,{"C5_P_OBSB2"		, Obs   			,Nil})
If TipoPed $ "A/T/R"
	aAdd(aCabSC5,{"C5_CONDPAG"     	, "***"            	,Nil})
	If TipoPed == "A"
		aAdd(aCabSC5,{"C5_TABELA"		, "007"            	,Nil})
	EndIf
EndIf

For nX := 1 to Len(::Itens:ItemPed)
	aItSC6 := {}
	SB1->(dbSeek(xFilial("SB1") + ::Itens:ItemPed[nX]:Produto))
	
	ConOut("Preço: " + Str(::Itens:ItemPed[nX]:Preco))
	
	aAdd(aItSC6,{"C6_FILIAL"	  ,xFilial("SC6")				,Nil})
	aAdd(aItSC6,{"C6_ITEM"	      ,cItem						,Nil}) 
	aAdd(aItSC6,{"C6_PRODUTO"	  ,::Itens:ItemPed[nX]:Produto	,Nil}) 
	aAdd(aItSC6,{"C6_QTDVEN"	  ,::Itens:ItemPed[nX]:Quant	,Nil})
	If TipoPed $ "A/T/R"
		aAdd(aItSC6,{"C6_PRCVEN"	  ,::Itens:ItemPed[nX]:Preco	,Nil}) 
	EndIf
	aAdd(aItSC6,{"C6_OPER"	      ,cOper						,Nil}) 
	aAdd(aItens, aItSC6)
	cItem := Soma1(cItem)
Next nX
		
MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCabSC5, aItens, 3)

If lMsErroAuto
	aAdd(::Retorno, WSClassNew("ResultPed"))
	MostraErro('\system\','LOGMOBILE_' + AllTrim(SA1->A1_VEND) + '.LOG')	
	cArqLog := MemoRead('LOGMOBILE_' + AllTrim(SA1->A1_VEND) + '.LOG')		
	::Retorno[1]:Numero := "ERR001"        
	::Retorno[1]:Log    := cArqLog
	RollBackSXE()
	conout("Erro ao gerar pedido.")
Else
	aAdd(::Retorno, WSClassNew("ResultPed"))
	::Retorno[1]:Numero := SC5->C5_NUM
	::Retorno[1]:Log    := "Transmissão OK!"
	ConfirmSX8()		   
	conout("Pedido: " + SC5->C5_NUM + " importado com sucesso.")
EndIf	                                               		

Return(.T.)