#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"         
#INCLUDE "TBICONN.CH"         

WsService Mobile_SaldoProduto Description "Mobile Logos - Estoque de Produto do ERP"

   WsData Produto As String
   WsData Saldo As Float
   
   WsMethod AtualizaEstoque Description "Mobile Logos - Estoque de Produto do ERP"

EndWsService

WsMethod AtualizaEstoque WsReceive Produto WsSend Saldo WsService Mobile_SaldoProduto

Local nX       := 0     
Local nPos     := 0     
Local nRec     := 0
Local aTabela  := {}
Local cTabela  := ""
Local cQuery   := "" 

ConOut("Mobile Logos - Inicio Webservice Saldo Produto.")

SB2->(dbSetOrder(1))
SB2->(dbSeek(xFilial("SB2") + Produto + Space(15-Len(Produto)) + "10"))

::Saldo := SaldoSB2()

ConOut("Mobile Logos - WebService Retorno do Saldo do Produto finalizado.")

Return(.T.)