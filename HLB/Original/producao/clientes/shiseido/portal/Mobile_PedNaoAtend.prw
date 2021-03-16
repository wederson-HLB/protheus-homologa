#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WSSTRUCT Pedidos
	WSDATA Status      As String
	WSDATA Emissao     As String
	WSDATA Numero      As String
	WSDATA Cliente     As String  
	WSDATA Loja        As String  
	WSDATA Nome        As String
	WSDATA Entrega     As String
	WSDATA Item		   As String
	WSDATA Produto     As String
	WSDATA Descricao   As String
	WSDATA Quantidade  As Float
	WSDATA Entregue    As Float
	WSDATA Valor       As Float
ENDWSSTRUCT

WsService Mobile_PedNaoEntregues Description "LOGOS Mobile Consulta Pedidos Nao Entregues do ERP"

   WsData Vendedor As String
   WsData cPedIni  As String 
   WsData cPedFim  As String  
   WsData cProdIni As String
   WsData cProdFim As String
   WsData cDataIni As String
   WsData cDataFim As String
   WsData Retorno As Array of Pedidos
   
   WsMethod ConsultaPedidos Description "LOGOS Mobile Retorna Pedidos Nao Entregues para o mobile"

EndWsService

WsMethod ConsultaPedidos WsReceive Vendedor, cPedIni, cPedFim, cProdIni, cProdFim, cDataIni, cDataFim WsSend Retorno WsService Mobile_PedNaoEntregues

Local nX           := 0
Local cQuery       := "" 

::Retorno := {}

ConOut("Mobile Logos - Inicio da importação pedidos nao entregues.")
C680TRB(cPedIni, cPedFim, "", "ZZZZZZ", cProdIni, cProdFim, CtoD(cDataIni), cTod(cDataFim), 1)

ConOut("Mobile Logos - Carregando pedidos.")
If !TRB->(EOF())
	While !TRB->(EOF())
		nX++
		aAdd(::Retorno, WSClassNew("Pedidos"))
		::Retorno[nX]:Status      := "1"
		::Retorno[nX]:Emissao     := DtoC(TRB->EMISSAO)
		::Retorno[nX]:Numero      := TRB->NUM
		::Retorno[nX]:Cliente     := TRB->CLIENTE
		::Retorno[nX]:Loja        := TRB->LOJA
		::Retorno[nX]:Nome        := TRB->NOMECLI
		::Retorno[nX]:Entrega     := DtoC(TRB->DATENTR)
		::Retorno[nX]:Item        := TRB->ITEM
		::Retorno[nX]:Produto     := TRB->PRODUTO
		::Retorno[nX]:Descricao   := TRB->DESCRICAO
		::Retorno[nX]:Quantidade  := TRB->QUANTIDADE
		::Retorno[nX]:Entregue    := TRB->ENTREGUE
		::Retorno[nX]:Valor       := TRB->VALOR
		TRB->(dbSkip())
	End
Else
	nX++
		::Retorno[nX]:Status      := "0"
		::Retorno[nX]:Emissao     := ""
		::Retorno[nX]:Numero      := ""
		::Retorno[nX]:Cliente     := ""
		::Retorno[nX]:Loja        := ""
		::Retorno[nX]:Nome        := ""
		::Retorno[nX]:Entrega     := ""
		::Retorno[nX]:Item        := ""
		::Retorno[nX]:Produto     := ""
		::Retorno[nX]:Descricao   := ""
		::Retorno[nX]:Quantidade  := 0
		::Retorno[nX]:Entregue    := 0
		::Retorno[nX]:Valor       := 0
EndIf
TRB->(dbCloseArea())
ConOut("Mobile Logos - WebService de pedidos nao entregues finalizado.")

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ C680TRB	³ Autor ³ Alexandre Inacio Lemes³ Data ³ 15.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Arquivo de Trabalho                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ MATR660													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C680TRB(cPedIni, cPedFim, cCliIni, cCliFim, cProIni, cProFim, cDatIni, cDatFim, nOrdem)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aCampos   := {}
LOCAL aTam      := ""
LOCAL cAliasSC6 := "SC6"
LOCAL nTipVal   := 2 //IIF(cPaisLoc == "BRA",MV_PAR19,MV_PAR20)
LOCAL nSaldo    := 0
LOCAL nX        := 0
LOCAL nValor	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array para arquivo de trabalho                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("C6_FILIAL")
AADD(aCampos,{ "FILIAL"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_NUM")
AADD(aCampos,{ "NUM"       ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C5_EMISSAO")
AADD(aCampos,{ "EMISSAO"   ,"D",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_CLI")
AADD(aCampos,{ "CLIENTE"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A1_NOME")
AADD(aCampos,{ "NOMECLI"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_LOJA")
AADD(aCampos,{ "LOJA"      ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C5_VEND1")
AADD(aCampos,{ "VENDEDOR"  ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A3_NOME")
AADD(aCampos,{ "NOMEVEN"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_ENTREG")
AADD(aCampos,{ "DATENTR"   ,"D",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_ITEM")
AADD(aCampos,{ "ITEM"      ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_PRODUTO")
AADD(aCampos,{ "PRODUTO"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_DESCRI")
AADD(aCampos,{ "DESCRICAO" ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_QTDVEN")
AADD(aCampos,{ "QUANTIDADE","N",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_QTDENT")
AADD(aCampos,{ "ENTREGUE"  ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_GRADE")
AADD(aCampos,{ "GRADE"     ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_ITEMGRD")
AADD(aCampos,{ "ITEMGRD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_TES")
AADD(aCampos,{ "TES"       ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_BLQ")
AADD(aCampos,{ "BLQ"       ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_BLOQUEI")
AADD(aCampos,{ "BLOQUEI"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C6_VALOR")
AADD(aCampos,{ "VALOR"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("C5_MOEDA")
AADD(aCampos,{ "MOEDA"   ,"N",aTam[1],aTam[2] } )
AADD(aCampos,{ "SDATA"   ,"C",8 , 0 } )

//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------
cAliasTrb := CriaTrab(aCampos, .T.)
DbUseArea(.T., __Localdriver, cAliasTrb, "TRB")

dbSelectArea("TRB")
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Filtro                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC6")
dbSetOrder(1)

cAliasSC6 := "MR680Trab"
aStruSC6  := SC6->(dbStruct())
cQuery    := "SELECT * "
cQuery += "FROM "+RetSqlName("SC6")+" "
cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
cQuery += "C6_NUM >= '"+cPedIni+"' AND "
cQuery += "C6_NUM <= '"+cPedFim+"' AND "
cQuery += "C6_PRODUTO >= '"+cProIni+"' AND "
cQuery += "C6_PRODUTO <= '"+cProFim+"' AND "
cQuery += "C6_CLI >= '"+cCliIni+"' AND "
cQuery += "C6_CLI <= '"+cCliFim+"' AND "
cQuery += "C6_ENTREG >= '"+Dtos(cDatIni)+"' AND "
cQuery += "C6_ENTREG <= '"+Dtos(cDatFim)+"' AND  "
cQuery += "D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "+SqlOrder(IndexKey())

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC6,.T.,.T.)

For nX := 1 To Len(aStruSC6)
	If ( aStruSC6[nX][2] <> "C" )
		TcSetField(cAliasSC6,aStruSC6[nX][1],aStruSC6[nX][2],aStruSC6[nX][3],aStruSC6[nX][4])
	EndIf
Next nX

dbSelectArea(cAliasSC6)

While !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6")
		
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial()+ (cAliasSC6)->C6_CLI + (cAliasSC6)->C6_LOJA )
	
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek( xFilial(("SF4"))+(cAliasSC6)->C6_TES )
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek( xFilial(("SC5"))+(cAliasSC6)->C6_NUM )
	
	dbSelectArea(cAliasSC6)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se esta dentro dos parametros						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim((cAliasSC6)->C6_BLQ) == "R" //.and. mv_par13 == 2 // Se Foi Eliminado Residuos
		nSaldo  := 0
	Else
		nSaldo  := C6_QTDVEN-C6_QTDENT
	Endif
	
	If C6_QTDENT < C6_QTDVEN .and.;
		AllTrim((cAliasSC6)->C6_BLQ) <> "R" .and.;
		At(SC5->C5_TIPO,"DB") = 0

		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		
		REPLACE FILIAL     WITH (cAliasSC6)->C6_FILIAL
		REPLACE NUM        WITH (cAliasSC6)->C6_NUM
		REPLACE EMISSAO    WITH SC5->C5_EMISSAO
		REPLACE CLIENTE    WITH (cAliasSC6)->C6_CLI
		REPLACE NOMECLI    WITH SA1->A1_NOME
		REPLACE LOJA       WITH (cAliasSC6)->C6_LOJA
		REPLACE DATENTR    WITH (cAliasSC6)->C6_ENTREG
		REPLACE SDATA      WITH DtoS((cAliasSC6)->C6_ENTREG)
		REPLACE ITEM       WITH (cAliasSC6)->C6_ITEM
		REPLACE PRODUTO    WITH (cAliasSC6)->C6_PRODUTO
		REPLACE DESCRICAO  WITH (cAliasSC6)->C6_DESCRI
		REPLACE QUANTIDADE WITH (cAliasSC6)->C6_QTDVEN
		REPLACE ENTREGUE   WITH (cAliasSC6)->C6_QTDENT
		REPLACE GRADE      WITH (cAliasSC6)->C6_GRADE
		REPLACE ITEMGRD    WITH (cAliasSC6)->C6_ITEMGRD
		REPLACE TES        WITH (cAliasSC6)->C6_TES
		REPLACE BLQ        WITH (cAliasSC6)->C6_BLQ
		REPLACE BLOQUEI    WITH (cAliasSC6)->C6_BLOQUEI
		If nTipVal == 1 //--  Imprime Valor Total do Item
			nValor:=(cAliasSC6)->C6_VALOR						
		Else
			//--  Imprime Saldo
			If TRB->QUANTIDADE==0
				nValor:=(cAliasSC6)->C6_VALOR
			Else
				nValor := (TRB->QUANTIDADE - TRB->ENTREGUE) * (cAliasSC6)->C6_PRCVEN
				nValor := If(nValor<0,0,nValor)
			EndIf
		EndIf						
		REPLACE VALOR      WITH nValor
		REPLACE MOEDA      WITH SC5->C5_MOEDA
		
		MsUnLock()
	Endif

	dbSelectArea(cAliasSC6)
	dbSkip()

End

dbSelectArea(cAliasSC6)
dbClosearea()
dbSelectArea("SC6")

Return Nil 