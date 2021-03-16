#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT DiscStItPC
	WSDATA produto    As String
	WSDATA Quant      As Float
	WSDATA Preco      As Float
	WSDATA CC	      As String
	WSDATA Brand	  As String
	WSDATA Plataforma As String
ENDWSSTRUCT

WSSTRUCT DiscItensPed
	WSDATA ItemPed As Array of DiscStItPC
ENDWSSTRUCT

WSSTRUCT DiscResultPed
	WSDATA Numero As String
	WSDATA Log    As String 
ENDWSSTRUCT

WsService Mobile_Pedidos_PD Description "MOBILE LOGOS - Geração dos Pedidos de Compras."

   WSDATA Fornecedor As String
   WSDATA Loja       As String
   WSDATA CondPagto  As String
   WSDATA Itens      As DiscItensPed
   WSDATA Retorno    As Array of DiscResultPed
   
   WsMethod GeraPedidos Description "MOBILE LOGOS - Geração dos Pedidos."

EndWsService

WsMethod GeraPedidos WsReceive Fornecedor, Loja, CondPagto, Itens WsSend Retorno WsService Mobile_Pedidos_PD

Local nX        := 0     
Local cItem     := "0001"
Local cNumero   := ""
Local aCabPC	:= {}
Local aItPC		:= {}
Local aItens    := {}
lMsHelpAuto := .T.
lMsErroAuto := .F.

SA2->(dbSetOrder(1))                                    
SA2->(dbSeek(xFilial("SA2") + Fornecedor + Loja))       
       
cNumero := GetNumSC7() 

aCabPC := {{"C7_FILIAL"  , xFilial("SC7")	, Nil},;
			{"C7_NUM"    , cNumero        	, Nil},; 
			{"C7_EMISSAO", dDataBase      	, Nil},; 
           	{"C7_FORNECE", Fornecedor		, Nil},;
           	{"C7_LOJA"   , Loja 			, Nil},;
           	{"C7_COND"   , CondPagto	   	, Nil},;
           	{"C7_CONTATO", ""             	, Nil},;
           	{"C7_FILENT" , xFilial("SC7") 	, Nil}} 
           	
For nX := 1 to Len(::Itens:ItemPed)
	SB1->(dbSeek(xFilial("SB1") + ::Itens:ItemPed[nX]:Produto))
 
	aAdd(aItPC,{{"C7_ITEM"	  ,cItem							,Nil},; 
				{"C7_PRODUTO" ,::Itens:ItemPed[nX]:Produto		,Nil},;
				{"C7_QUANT"	  ,::Itens:ItemPed[nX]:Quant		,Nil},;
				{"C7_PRECO"	  ,::Itens:ItemPed[nX]:Preco		,Nil},; 
				{"C7_ITEMCTA" ,::Itens:ItemPed[nX]:Brand		,Nil},;
				{"C7_CLVL"	  ,::Itens:ItemPed[nX]:Plataforma	,Nil},;
				{"C7_CC"	  ,::Itens:ItemPed[nX]:CC			,Nil},;
				{"C7_OBS"	  , "."								,Nil},;
				{"C7_APROV"	  , "000001"						,Nil}})
	cItem := Soma1(cItem)
Next nX
		
MSExecAuto({|x, y, z, w, h| MATA120(x,y,z,w,h)}, 1, aCabPC, aItPC, 3, .F.)

If lMsErroAuto  
	aAdd(::Retorno, WSClassNew("DiscResultPed"))
	MostraErro('\system\','LOGMOBILE_' + cNumero + '.LOG')	
	cArqLog := MemoRead('LOGMOBILE_' + cNumero + '.LOG')		

	SC7->(dbSetOrder(1))
	SCR->(dbSetOrder(1))
	If SC7->(dbSeek(xFilial("SC7") + cNumero))
		While SC7->C7_NUM == cNumero .and. !SC7->(EOF())
			RecLock("SC7", .F.)
			SC7->C7_CONAPRO := "L"
			MsUnlock()
			SC7->(dbSkip())
		End
		SCR->(dbSeek(xFilial("SCR") + "PC" + cNumero))
		While SCR->CR_TIPO == "PC" .and. SCR->CR_NUM == cNumero .and. !SCR->(EOF())
			RecLock("SCR", .F.)
			SCR->(dbDelete())
			MSUnlock()
			SCR->(dbSkip())
		End
		::Retorno[1]:Numero := cNumero
		::Retorno[1]:Log    := "Transmissão OK!"
		ConfirmSX8()		   
		conout("Pedido: " + cNumero + " importado com sucesso.")
	Else
		::Retorno[1]:Numero := "ERR001"        
		::Retorno[1]:Log    := cArqLog
		RollBackSx8()
		conout("Erro ao gerar pedido.")
	EndIf
Else
	SC7->(dbSetOrder(1))
	SCR->(dbSetOrder(1))
	SC7->(dbSeek(xFilial("SC7") + cNumero))
	While SC7->C7_NUM == cNumero .and. !SC7->(EOF())
		RecLock("SC7", .F.)
		SC7->C7_CONAPRO := "L"
		MsUnlock()
		SC7->(dbSkip())
	End
	SCR->(dbSeek(xFilial("SCR") + "PC" + cNumero))
	While SCR->CR_TIPO == "PC" .and. SCR->CR_NUM == cNumero .and. !SCR->(EOF())
		RecLock("SCR", .F.)
		SCR->(dbDelete())
		MSUnlock()
		SCR->(dbSkip())
	End
	aAdd(::Retorno, WSClassNew("DiscResultPed"))
	::Retorno[1]:Numero := cNumero
	::Retorno[1]:Log    := "Transmissão OK!"
	ConfirmSX8()		   
	conout("Pedido: " + cNumero + " importado com sucesso.")
EndIf	                                               		

Return(.T.)