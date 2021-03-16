#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#include "topconn.ch"

// #########################################################################################
// Projeto:	Leitura de XML NeoGrid
// Modulo :	Faturamento
// Fonte  : SUFAT003
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 28/03/16 | Joao Vitor		| Leitura de arquivo TXT para inclusao de pedido de vendas.
// ---------+-------------------+-----------------------------------------------------------
/*/{Protheus.doc} SUFAT003
Leitura de XML inclusao de pedido de vendas

@author		Joao Vitor
@version	1.xx
@since		28/03/2016
/*/
//------------------------------------------------------------------------------------------
User Function SUFAT003
	Private aCores := {{'ZX0->ZX0_STATUS == "1"','BR_VERDE'},{'ZX0->ZX0_STATUS == "2"','BR_VERMELHO'},{'ZX0->ZX0_STATUS == "3"','BR_AMARELO'}}
	Private cCadastro  := "Importaaao de pedidos de venda via NeoGrid"
	Private aRotina     := {}
	Private aFiles := {} // Array contendo nome e caminho para o arquivo
	Private cCaminho := SUPERGETMV("MV_P_00071",.F.,"C:\NeoGrid\bin\IN\")
	Private _a
	Private aDell:= {}// { nome arquivo}
	Private nOpc
	Private _aPedidos := {}
	Private lInic := .T.
	Private lErro := .F.
	Private _I := 0
	Private _k := 1
	Private _x := 1
	Private _y := 1
	Private _z := 1
	
	aRotina          := {{'Procurar','AxPesqui',0,1},;
						 {'Visualisar','AxVisual',0,2},;
						 {'Importar','U_ImpSuF1()',0,3},;
						 {'Excluir','AxDeleta',0,2},;
						 {"Legenda","u_LegSuF1()",0,3}}
	
	dbSelectArea('ZX0')
	dbSetOrder(1)
	ZX0->(dbGoTop())
	MBrowse(6,1,22,75,'ZX0',,,,,,aCores)
	
Return .T.

User Function LEGSUF1()
	
	Local	aLegenda := {}
	
	AADD(aLegenda ,{"BR_VERDE", "Importado" })
	AADD(aLegenda,{"BR_VERMELHO"  , "Falha na importaaao"})
	AADD(aLegenda,{"BR_AMARELO"  , "Pendente"})
	BrwLegenda(cCadastro, "Status", aLegenda)
	
Return

User Function IMPSUF1
	
	Processa( { || bSalvar() },, "Importaaaes em andamento." )
	
Return

Static Function bSalvar
	Local _lnP := .T.
	
	aFiles := Directory(cCaminho+"*.TXT*")
	
	ProcRegua(len(aFiles))
	
	If  Len(aFiles) == 0
		MsgAlert('Sem Pedidos para importaaao ou nao encontrados no diretorio : '+cCaminho)
		Return
	EndIf
	
	nOpc := cTela(aFiles)// cria tela para mostrar arquivos a serem importados
	
	If nOpc <> 1
		Return
	EndIf
	ZX0->(DbSetOrder(1))
	
	For _a := 1 to Len(aFiles)
		//Grava primeiras informaaaes referente a importaaao
		If ZX0->(dbseek(xFilial('ZX0')+aFiles[_a,1]))
			if ZX0->ZX0_STATUS == '1'
				MsgAlert('Arquivo ja importado sem erro, nao sera possivel importa-lo novamente.')
			EndIf
		Else
			RecLock('ZX0',.T.)
			ZX0->ZX0_FILIAL := xFilial('ZX0')// VERIFICAR
			ZX0->ZX0_ARQ 	:= aFiles[_a,1]
			ZX0->ZX0_DATA 	:= /*aFiles[_a,3]*/ dDataBase
			ZX0->ZX0_HORA 	:= /*aFiles[_a,4] */Time()
			MsUnlock()
		EndIf
		
	Next _a
	
	//La TXT e transforma o mesmo em OBJ
	bLerArq()
	
	For _a := 1 To Len(_aPedidos)
		_aPedidos[_a]:Grava()
		IncProc()
	Next _a
	
	//Deleta arquivos importados com sucesso
	For _x := 1 to Len(aDell)
		if FERASE(cCaminho+aDell[_x]) == -1
			MsgAlert('Erro ao excluir o arquivo'+aDell[_x])
		EndIf
	Next _x
	
	
Return

// ---------+-------------------+-----------------------------------------------------------
/*/{Protheus.doc} SUFAT003
Leitura de XML inclusao de pedido de vendas

@author		Joao Vitor
@version	1.xx
@since		28/03/2016
/*/
//------------------------------------------------------------------------------------------
Static Function cTela(aFiles)
	
	Local _nOpc := 0
	Private oTela
	Private aTela := aClone(aFiles)
	
	DEFINE MSDIALOG oDlgMark TITLE "Arquivos a serem importados" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
	@ 002, 002 LISTBOX oTela Fields HEADER "Data","Hora","Arquivo" SIZE 250, 200 OF oDlgMark PIXEL ColSizes 50,50
	oTela:SetArray(aTela)
	oTela:bLine := {||{;
		aTela[oTela:nAt,3],;
		aTela[oTela:nAt,4],;
		aTela[oTela:nAt,1]}}
	
	DEFINE SBUTTON oSButton1 FROM 230, 082 TYPE 01 OF oDlgMark ENABLE ACTION (_nOpc:=1,oDlgMark:End())
	DEFINE SBUTTON oSButton2 FROM 230, 138 TYPE 02 OF oDlgMark ENABLE ACTION oDlgMark:End()
	
	
	ACTIVATE MSDIALOG oDlgMark CENTERED
	
Return _nOpc

// ---------+-------------------+-----------------------------------------------------------
/*/{Protheus.doc} SUFAT003
Leitura de XML inclusao de pedido de vendas

@author		Joao Vitor
@version	1.xx
@since		28/03/2016
/*/
//------------------------------------------------------------------------------------------
Static Function bLerArq
	
	For _I := 1 To Len(aFiles)
		// Abre o arquivo
		nHandle := FT_FUse(cCaminho+aFiles[_I,1])
		// Se houver erro de abertura abandona processamento
		if nHandle = -1
			return
		endif
		// Posiciona na primeria linha
		FT_FGoTop()
		While !FT_FEOF()
			cLine  := FT_FReadLn()
			//inicializa a estrutura
			iF lInic
				aAdd(_aPedidos,TPedido():New())
				_aPedidos[_I]:Pgto := {}
				_aPedidos[_I]:Itens := {}
				_aPedidos[_I]:Grade := {}
				_aPedidos[_I]:Cross := {}
				lInic := .F.
				_k :=  _x := _y := _z := 1
			EndIf
			if SubStr(cLine,000,02) == '01'
				_aPedidos[_I]:cArquivo 	:= aFiles[_I,1]
				_aPedidos[_I]:cFunMsg 	:= SubStr(cLine,003,03)
				_aPedidos[_I]:cTpPed 	:= SubStr(cLine,006,03)
				_aPedidos[_I]:cNumPedC 	:= SubStr(cLine,009,20)
				_aPedidos[_I]:cNumPedS 	:= SubStr(cLine,029,20)
				_aPedidos[_I]:dDtEmPe 	:= StoD(SubStr(cLine,049,08))
				_aPedidos[_I]:cHEmPe 	:= SubStr(cLine,057,02)+':'+SubStr(cLine,059,02)
				_aPedidos[_I]:dDtIniEnt := StoD(SubStr(cLine,061,08))
				_aPedidos[_I]:cHIniEnt 	:= SubStr(cLine,068,02)+':'+SubStr(cLine,070,02)
				_aPedidos[_I]:dDtFimEnt := StoD(SubStr(cLine,073,08))
				_aPedidos[_I]:cHFimEnt 	:= SubStr(cLine,081,02)+':'+SubStr(cLine,083,02)
				_aPedidos[_I]:cNumContr := SubStr(cLine,085,15)
				_aPedidos[_I]:cListPr 	:= SubStr(cLine,100,15)
				_aPedidos[_I]:cEanFor 	:= SubStr(cLine,115,13)
				_aPedidos[_I]:cEanCom 	:= SubStr(cLine,128,13)
				_aPedidos[_I]:cEanCbFt 	:= SubStr(cLine,141,13)
				_aPedidos[_I]:cEanLcEnt := SubStr(cLine,154,13)
				_aPedidos[_I]:cCgcFor	:= SubStr(cLine,167,14)
				_aPedidos[_I]:cCgcCom 	:= SubStr(cLine,181,14)
				_aPedidos[_I]:cCgcCbFt 	:= SubStr(cLine,195,14)
				_aPedidos[_I]:cCgcLcEnt := SubStr(cLine,209,14)
				_aPedidos[_I]:cTpTrans 	:= SubStr(cLine,223,03)
				_aPedidos[_I]:cCodTrans := SubStr(cLine,226,14)
				_aPedidos[_I]:cDescTran := SubStr(cLine,240,30)
				_aPedidos[_I]:cTpFrete 	:= SubStr(cLine,270,03)
				_aPedidos[_I]:cSecPed 	:= SubStr(cLine,273,03)
				_aPedidos[_I]:cObsPed 	:= SubStr(cLine,276,40)
				FT_FSKIP()
			ElseIf SubStr(cLine,000,02) == '02'
				aAdd(_aPedidos[_I]:Pgto,TPgto():New())
				_aPedidos[_I]:Pgto[_x]:cCondPg	:= Alltrim(SubStr(cLine,003,03))
				_aPedidos[_I]:Pgto[_x]:dDtRef 	:= AllTrim(SubStr(cLine,006,03))
				_aPedidos[_I]:Pgto[_x]:dDtRefT 	:= AllTrim(SubStr(cLine,008,03))
				_aPedidos[_I]:Pgto[_x]:cTpPeri	:= AllTrim(SubStr(cLine,012,03))
				_aPedidos[_I]:Pgto[_x]:cNumPeri	:= AllTrim(SubStr(cLine,015,03))
				_aPedidos[_I]:Pgto[_x]:dDtVenc	:= StoD(SubStr(cLine,018,08))
				_aPedidos[_I]:Pgto[_x]:nValPg 	:= Val(SubStr(cLine,026,15))/100
				_aPedidos[_I]:Pgto[_x]:nPerPg	:= Val(SubStr(cLine,041,05))/100
				_x ++
				FT_FSKIP()
			ElseIf SubStr(cLine,000,02) == '03'
				_aPedidos[_I]:nPerDeF	:= Val(SubStr(cLine,002,05))/100
				_aPedidos[_I]:nValDeF 	:= Val(SubStr(cLine,008,15))/100
				_aPedidos[_I]:nPerDeC 	:= Val(SubStr(cLine,023,05))/100
				_aPedidos[_I]:nValDeC	:= Val(SubStr(cLine,028,15))/100
				_aPedidos[_I]:nPerDeP	:= Val(SubStr(cLine,043,05))/100
				_aPedidos[_I]:nValDeP	:= Val(SubStr(cLine,048,15))/100
				_aPedidos[_I]:nPerEnF	:= Val(SubStr(cLine,063,05))/100
				_aPedidos[_I]:nValEnF	:= Val(SubStr(cLine,068,15))/100
				_aPedidos[_I]:nPerEnFret:= Val(SubStr(cLine,083,05))/100
				_aPedidos[_I]:nValEnFret:= Val(SubStr(cLine,089,15))/100
				_aPedidos[_I]:nPerEnSeg	:= Val(SubStr(cLine,103,05))/100
				_aPedidos[_I]:nValEnSeg := Val(SubStr(cLine,108,15))/100
				FT_FSKIP()
			ElseIf SubStr(cLine,000,02) == '04'
				aAdd(_aPedidos[_I]:Itens,TItens():New())
				_aPedidos[_I]:Itens[_y]:nSeg  		:= SubStr(cLine,005,02)
				_aPedidos[_I]:Itens[_y]:nItem  		:= SubStr(cLine,007,05)
				_aPedidos[_I]:Itens[_y]:cQlAlt  	:= SubStr(cLine,012,03)
				_aPedidos[_I]:Itens[_y]:cTpCodProd  := SubStr(cLine,015,03)
				_aPedidos[_I]:Itens[_y]:cCodProd  	:= SubStr(cLine,018,14)
				_aPedidos[_I]:Itens[_y]:cDescProd  	:= SubStr(cLine,032,40)
				_aPedidos[_I]:Itens[_y]:cRefProd  	:= SubStr(cLine,072,20)
				_aPedidos[_I]:Itens[_y]:cUnMed  	:= SubStr(cLine,092,03)
				_aPedidos[_I]:Itens[_y]:nNumUCEP  	:= SubStr(cLine,095,05)
				_aPedidos[_I]:Itens[_y]:nQntProd  	:= Val(SubStr(cLine,100,15))/100
				_aPedidos[_I]:Itens[_y]:nQntBon  	:= Val(SubStr(cLine,115,15))/100
				_aPedidos[_I]:Itens[_y]:nQntTroc  	:= Val(SubStr(cLine,130,15))/100
				_aPedidos[_I]:Itens[_y]:nTpEmb  	:= SubStr(cLine,145,03)
				_aPedidos[_I]:Itens[_y]:nNumEmb  	:= SubStr(cLine,148,05)
				_aPedidos[_I]:Itens[_y]:nValBruL  	:= Val(SubStr(cLine,153,15))/100
				_aPedidos[_I]:Itens[_y]:nValLiqL  	:= Val(SubStr(cLine,168,15))/100
				_aPedidos[_I]:Itens[_y]:nPrcBruL  	:= Val(SubStr(cLine,183,15))/100
				_aPedidos[_I]:Itens[_y]:nPrcLiqL  	:= Val(SubStr(cLine,198,15))/100
				_aPedidos[_I]:Itens[_y]:nBasPrcUn  	:= Val(SubStr(cLine,213,05))/100
				_aPedidos[_I]:Itens[_y]:cUnMBPrcUn  := SubStr(cLine,218,03)
				_aPedidos[_I]:Itens[_y]:nValUnDeC  	:= Val(SubStr(cLine,221,15))/100
				_aPedidos[_I]:Itens[_y]:nPerDeC  	:= Val(SubStr(cLine,236,05))/100
				_aPedidos[_I]:Itens[_y]:nValUnIPI  	:= Val(SubStr(cLine,241,15))/100
				_aPedidos[_I]:Itens[_y]:nAliqIPI  	:= Val(SubStr(cLine,256,05))/100
				_aPedidos[_I]:Itens[_y]:nValUDAT  	:= Val(SubStr(cLine,261,15))/100
				_aPedidos[_I]:Itens[_y]:nValUDANT  	:= Val(SubStr(cLine,276,15))/100
				_aPedidos[_I]:Itens[_y]:nValEnFreI  := Val(SubStr(cLine,291,15))/100
				_aPedidos[_I]:Itens[_y]:nValPauta  	:= Val(SubStr(cLine,306,07))/100
				_aPedidos[_I]:Itens[_y]:cCodRMSIt  	:= SubStr(cLine,313,08)
				_aPedidos[_I]:Itens[_y]:nCodNCM  	:= SubStr(cLine,321,10)
				FT_FSKIP()
				_y ++
			ElseIf SubStr(cLine,000,02) == '05'
				aAdd(_aPedidos[_I]:Grade,TGrade():New())
				_aPedidos[_I]:Grade[_z]:cTpCodpdGr 	:= SubStr(cLine,002,03)
				_aPedidos[_I]:Grade[_z]:cCodPdGr 	:= SubStr(cLine,006,14)
				_aPedidos[_I]:Grade[_z]:nQntPdGR	:= Val(SubStr(cLine,020,15))/100
				_aPedidos[_I]:Grade[_z]:cUnMdGR 	:= SubStr(cLine,035,03)
				FT_FSKIP()
				_z ++
			ElseIf SubStr(cLine,000,02) == '06'
				aAdd(_aPedidos[_I]:Cross,TCros():New())
				_aPedidos[_I]:Cross[_k]:cEanLcEnCro	:= SubStr(cLine,002,13)
				_aPedidos[_I]:Cross[_k]:cCgcLcEnCro	:= SubStr(cLine,016,14)
				_aPedidos[_I]:Cross[_k]:dDtPeICro 	:= SubStr(cLine,030,12)
				_aPedidos[_I]:Cross[_k]:dDtPeFCro 	:= SubStr(cLine,042,12)
				_aPedidos[_I]:Cross[_k]:nQntCro 	:= Val(SubStr(cLine,054,15))/100
				_aPedidos[_I]:Cross[_k]:cUnMDCro 	:= SubStr(cLine,069,03)
				FT_FSKIP()
				_k ++
			ElseIf SubStr(cLine,000,02) == '09
				_aPedidos[_I]:nVlTotMerc	:= Val(SubStr(cLine,002,15))/100
				_aPedidos[_I]:nVlTotIPI 	:= Val(SubStr(cLine,018,15))/100
				_aPedidos[_I]:nVlTotAba 	:= Val(SubStr(cLine,033,15))/100
				_aPedidos[_I]:nVlTotEnc 	:= Val(SubStr(cLine,048,15))/100
				_aPedidos[_I]:nVlTotDesC 	:= Val(SubStr(cLine,063,15))/100
				_aPedidos[_I]:nVlTotDAT 	:= Val(SubStr(cLine,078,15))/100
				_aPedidos[_I]:nVlTotDANT 	:= Val(SubStr(cLine,093,15))/100
				_aPedidos[_I]:nVlTotPD 		:= Val(SubStr(cLine,108,15))/100
				FT_FSKIP()
			Else
				MsgAlert('Tipo de Registro Invalido '+SubStr(cLine,000,02))
				FT_FSKIP()
			EndIf
		EndDo
		// Fecha o Arquivo
		FT_FUSE()
		lInic := .T.
	Next _I
	
Return

Class TPedido
	//Registro 01 - CABEaALHO
	Data cArquivo //Nome do arquivo a ser importado
	Data cFunMsg //Funaao Mensagem
	Data cTpPed //Tipo de Pedido
	Data cNumPedC //Numero do Pedido do Comprador
	Data cNumPedS //Numero do Pedido do Sistema de Emissao
	Data dDtEmPe //Data -  de Emissao do Pedido
	Data cHEmPe // Hora  -  de Emissao do Pedido
	Data dDtIniEnt //Data -  Inicial do Peraodo de Entrega
	Data cHIniEnt // Hora-  Inicial do Peraodo de Entrega
	Data dDtFimEnt //Data -  Final do Peraodo de Entrega
	Data cHFimEnt // Hora -  Final do Peraodo de Entrega
	Data cNumContr //Numero do Contrato
	Data cListPr //Lista de Preaos
	Data cEanFor //EAN de Localizaaao do Fornecedor
	Data cEanCom //EAN de Localizaaao do Comprador
	Data cEanCbFt //EAN de Localizaaao de Cobranaa da Fatura
	Data cEanLcEnt //EAN de Localizaaao do Local de Entrega
	Data cCgcFor //CNPJ do Fornecedor
	Data cCgcCom //CNPJ do Comprador
	Data cCgcCbFt //CNPJ do Local da Cobranaa da Fatura
	Data cCgcLcEnt //CNPJ do Local de Entrega
	Data cTpTrans //Tipo de Cadigo da Transportadora
	Data cCodTrans //Cadigo da Transportadora
	Data cDescTran //Nome da Transportadora
	Data cTpFrete //Condiaao de Entrega (tipo de frete)
	Data cSecPed //Seaao do Pedido
	Data cObsPed //Observaaao do Pedido
	
	//Registro 03 - DESCONTOS E ENCARGOS DO PEDIDO
	Data nPerDeF // Percentual de Desconto Financeiro
	Data nValDeF // Valor de Desconto Financeiro
	Data nPerDeC // Percentual de Desconto Comercial
	Data nValDeC // Valor de Desconto Comercial
	Data nPerDeP // Percentual de Desconto Promocional
	Data nValDeP // Valor de Desconto Promocional
	Data nPerEnF // Percentual de Encargos Financeiros
	Data nValEnF // Valor de Encargos Financeiros
	Data nPerEnFret // Percentual de Encargos de Frete
	Data nValEnFret // Valor de Encargos de Frete
	Data nPerEnSeg // Percentual de Encargos de Seguro
	Data nValEnSeg // Valor de Encargos de Seguro
	
	//Registro 09 - SUMaRIO
	Data nVlTotMerc // Valor Total das Mercadorias
	Data nVlTotIPI // Valor Total do IPI
	Data nVlTotAba // Valor Total de Abatimentos
	Data nVlTotEnc // Valor Total de Encargos
	Data nVlTotDesC // Valor Total de Descontos Comerciais
	Data nVlTotDAT // Valor Total de Despesas Acessarias Tributadas
	Data nVlTotDANT // Valor Total de Despesas Acessarias Nao Tributadas
	Data nVlTotPD // Valor Total do Pedido
	
	//Arrays
	//Registro 02 - PAGAMENTO
	Data Pgto
	//Registro 04 - ITENS
	Data Itens // Array contendo  todos os itens
	//Registro 05 - GRADE
	Data Grade
	//Registro 06 a CROSSDOCKING
	Data Cross
	
	Method New() Constructor
	Method Grava()
EndClass

Method New() Class TPedido
Return Self

Class TPgto
	
	Data cCondPg //Condiaao de Pagamento
	Data dDtRef //Referancia da Data
	Data dDtRefT //Referancia de Tempo da Data
	Data cTpPeri //Tipo de Peraodo
	Data cNumPeri //Numero de Peraodos
	Data dDtVenc //Data de Vencimento
	Data nValPg //Valor a Pagar
	Data nPerPg //Percentual a Pagar do Valor Faturado
	
	Method New() Constructor
	
EndClass
Method New() Class TPgto
Return Self

Class TItens
	//Registro 04 - ITENS
	Data nSeg // Numero Seqaencial da Linha de Item
	Data nItem // Numero do Item no Pedido
	Data cQlAlt // Qualificador de Alteraaao
	Data cTpCodProd // Tipo de Cadigo do Produto
	Data cCodProd // Cadigo do Produto
	Data cDescProd // Descriaao do Produto
	Data cRefProd // Referancia do Produto
	Data cUnMed // Unidade de Medida
	Data nNumUCEP // Numero Unidades Consumo na Embalagem Pedida
	Data nQntProd // Quantidade Pedida
	Data nQntBon // Quantidade Bonificada
	Data nQntTroc // Quantidade Troca
	Data nTpEmb // Tipo de Embalagem
	Data nNumEmb // Numero de Embalagens
	Data nValBruL // Valor Bruto Linha Item
	Data nValLiqL // Valor Laquido Linha Item
	Data nPrcBruL // Preao Bruto Unitario
	Data nPrcLiqL // Preao Laquido Unitario
	Data nBasPrcUn // Base do Preao Unitario
	Data cUnMBPrcUn // Unidade de Medida da Base do Preao Unitario
	Data nValUnDeC // Valor Unitario do Desconto Comercial
	Data nPerDeC // Percentual do Desconto Comercial
	Data nValUnIPI // Valor Unitario do IPI
	Data nAliqIPI // Alaquota de IPI
	Data nValUDAT // Valor Unitario da Despesa Acessaria Tributada
	Data nValUDANT // Valor Unitario da Despesa Acessaria Nao Tributada
	Data nValEnFreI // Valor de Encargo de Frete
	Data nValPauta // Valor Pauta
	Data cCodRMSIt // Cadigo RMS do Item
	Data nCodNCM // Cadigo NCM
	
	Method New() Constructor
	
EndClass
Method New() Class TItens
Return Self

Class TGrade
	//Registro 05 - GRADE
	Data cTpCodpdGr // Tipo de Cadigo do Produto
	Data cCodPdGr // Cadigo do Produto
	Data nQntPdGR // Quantidade
	Data cUnMdGR // Unidade de Medida
	
	Method New() Constructor
	
EndClass
Method New() Class TGRADE
Return Self

Class TCros
	//Registro 06 a CROSSDOCKING
	Data cEanLcEnCro // EAN do Local de Entrega
	Data cCgcLcEnCro // CNPJ do Local de Entrega
	Data dDtPeICro // Data - Hora Inicial do Peraodo de Entrega
	Data dDtPeFCro // Data - Hora Final do Peraodo de Entrega
	Data nQntCro // Quantidade
	Data cUnMDCro // Unidade de Medida
	
	Method New() Constructor
	
EndClass
Method New() Class TCros
Return Self

Method Grava() Class TPedido
	
	Local cNomArqErro
	Local _lRet 	:= .F.
	Local cMsgLog 	:= ''
	Local _w 		:= 0
	Local nIndex 	:= 0
	Local _lOk  	:= .T.
	Local aErroP 	:= {}
	Local nSeque	:= '01'
	Local _pLin 	:= chr(13)+ chr(10)
	Local cPath 	:= GetSrvProfString("Startpath","")
	Local cCondPg 	:= Alltrim(SUPERGETMV('MV_P_00072',.F.,''))
	Local cTesInt	:= Alltrim(SUPERGETMV('MV_P_00073',.F.,''))
	Local cTes		:= Alltrim(SUPERGETMV('MV_P_00074',.F.,''))
	Local cNumPdC   := 'Numero do Pedido de Compra do sistema do comprador: '+_aPedidos[_a]:cNumPedC + _pLin
	Local nQnt 		:= '' // Quatidade de produtos.
	Local nEntSai 	:= '2' // Tipo documento 1 entrada 2 saida.
	Local cTipoCF	:= 'C'
	static nValU 	:= 0
	static nPerD	:= 0
	static nValD	:= 0
	Static nValT	:= 0
	
	aCabec     := {}
	aItens     := {}
	aLinha     := {}
	
	ZX0->(DbSetOrder(1))
	SA1->(DbSetOrder(3))//A1_FILIAL+A1_CGC
	_lOk := SA1->(DbSeek(xFilial('SA1')+ _aPedidos[_a]:cCgcCom))
	ZX0->(dbSeek(xFilial('ZX0')+_aPedidos[_a]:cArquivo)) // verificar isso
	
	if !_lOk
		RecLock("ZX0",.F.)
		ZX0->ZX0_STATUS := '3'
		ZX0->ZX0_OBS := 'Cliente com CPF/CNPJ : '+  _aPedidos[_a]:cCgcCom + ' nao encontrado no cadastro de clientes.'
		MsUnlock()
		_lRet :=  .T.
	Else
		_cPedido:= GetSxeNum("SC5","C5_NUM")
		
		aAdd(aCabec,{"C5_FILIAL"  , xFilial('SC5')         									,Nil})
		aAdd(aCabec,{"C5_NUM"     , _cPedido  		 										,Nil})
		if 	_aPedidos[_a]:cTpPed == '001'
			aAdd(aCabec,{"C5_TIPO"    , 'N'           										,Nil})
		ElseIf _aPedidos[_a]:cTpPed == '002'
			aAdd(aCabec,{"C5_TIPO"    , 'B'           										,Nil})
		EndIf
		aAdd(aCabec,{"C5_CLIENTE" , SA1->A1_COD     										,Nil})
		aAdd(aCabec,{"C5_LOJACLI" ,	SA1->A1_LOJA          									,Nil})
		aAdd(aCabec,{"C5_CONDPAG" ,	IIF(!Empty(SA1->A1_CONDPAG),SA1->A1_CONDPAG,cCondPg) 	,Nil})
		aAdd(aCabec,{"C5_EMISSAO" ,	dDataBase          										,Nil})
		
		iF _aPedidos[_a]:cCgcLcEnt == _aPedidos[_a]:cCgcCom
			aAdd(aCabec,{"C5_LOJAENT" , SA1->A1_LOJA         								,Nil})
		Elseif SA1->(DbSeek(xFilial('SA1')+ _aPedidos[_a]:cCgcLcEnt))
			aAdd(aCabec,{"C5_LOJAENT" , SA1->A1_LOJA         								,Nil})
		Else
			aAdd(aCabec,{"C5_LOJAENT" , SA1->A1_LOJA         								,Nil})
		EndIf
		
		aAdd(aCabec,{"C5_TPFRETE" , IIF(_aPedidos[_a]:cTpFrete == 'CIF','C','F')     		,Nil})
		aAdd(aCabec,{"C5_ESPECI1" ,'ALTERAR'									     		,Nil})
		
		For _w := 1 To Len(_aPedidos[_a]:Itens)
			nIndex := Len(Alltrim(_aPedidos[_a]:Itens[_w]:cCodProd))
			if nIndex == 13
				SB1->(DbSetOrder(5)) //B1_FILIAL+B1_CODBAR
				_lOk := SB1->(dbseek(xFilial('SB1')+_aPedidos[_a]:Itens[_w]:cCodProd)) // EAN 13
			Else
				_lOk := SB1->(dbseek(xFilial('SB1')+_aPedidos[_a]:Itens[_w]:cCodProd)) // DUN14
			EndIf
			
			if !_lOk
				cMsgLog += 'Produto com Codigo de barras: '+ _aPedidos[_a]:Itens[_w]:cCodProd + ',e descriaao: '+;
					_aPedidos[_a]:Itens[_w]:cDescProd +' nao encontrado.'+ _pLin
			Else
				aAdd(aLinha,{"C6_FILIAL" 	, xFilial('SC6')             			,Nil})
				aAdd(aLinha,{"C6_ITEM"   	, nSeque								,Nil})
				aAdd(aLinha,{"C6_PRODUTO"	, SB1->B1_COD               			,Nil})
				aAdd(aLinha,{"C6_LOCAL" 	, SB1->B1_LOCPAD         			 	,Nil})
				
				IF !Empty(cTesInt)
					aAdd(aLinha,{"C6_OPER" 	, cTesInt						    	,Nil})
				Else
					aAdd(aLinha,{"C6_TES" 	, cTes							   		 ,Nil})
				EndIf
				
				IF _aPedidos[_a]:cTpPed == '001'
					nQnt := _aPedidos[_a]:Itens[_w]:nQntProd
				ElseIF _aPedidos[_a]:cTpPed == '002' // bonificação
					nQnt := _aPedidos[_a]:Itens[_w]:nQntBon 
				EndIf
				
				aAdd(aLinha,{"C6_QTDVEN" 	, nQnt								    ,Nil})
				aAdd(aLinha,{"C6_QTDLIB" 	, 0 									,Nil})
				
				iF _aPedidos[_a]:Itens[_w]:nPrcLiqL > 0
					nValU := _aPedidos[_a]:Itens[_w]:nPrcLiqL
					nValT := nValU * nQnt
				Else
					nPerD := _aPedidos[_a]:Itens[_w]:nPerDeC /100
					nValD := _aPedidos[_a]:Itens[_w]:nValUnDeC
					if nPerD > 0
						nValU := Round((_aPedidos[_a]:Itens[_w]:nPrcBruL * (1 - nPerD)),2)
						nValT := Round(nValU * nQnt,2)
					Elseif nValD > 0
						nValU := Round((_aPedidos[_a]:Itens[_w]:nPrcBruL - nValD ),2)
						nValT := Round(nValU * nQnt,2)
					Else
						nValU := Round(_aPedidos[_a]:Itens[_w]:nPrcBruL,2)
						nValT := Round(nValU * nQnt,2)
					EndIf
				EndIf
				
				
				aAdd(aLinha,{"C6_PRCVEN" 	, nValU  ,Nil})
				
				if _aPedidos[_a]:Itens[_w]:nPrcLiqL > 0 // verificar como  os descontos do REGISTRO 3 influenciam no produto
					aAdd(aLinha,{"C6_PRUNIT" 	, nValU  ,Nil})
				Else
					aAdd(aLinha,{"C6_PRUNIT" 	, _aPedidos[_a]:Itens[_w]:nPrcBruL  ,Nil})
					
				EndIf
				
				aAdd(aLinha,{"C6_VALDESC" 	, Round(iiF(nValD > 0, nValD, _aPedidos[_a]:Itens[_w]:nPrcBruL * nPerD),2),Nil})
				aAdd(aLinha,{"C6_DESCONT" 	, nPerD*100    							,Nil})
				aAdd(aLinha,{"C6_VALOR" 	, nValT     							,Nil})
				aAdd(aItens,aLinha)
				
				aLinha := {}
				nSeque := soma1(nSeque)
			EndIf
		Next _w
		
		nSeque := '01'
		
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
		
		IF lMsErroAuto
			//			cNomArqErro := _aPedidos[_a]:cArquivo +".LOG"
			cNomArqErro := "Teste-Exeltis.LOG"
			MostraErro(cPath,cNomArqErro )
			cMsgLog1 := MemoRead(cPath + cNomArqErro)                                   //     carrega o log gravado
			MsErase(cNomArqErro)
			
			RecLock("ZX0",.F.)
			ZX0->ZX0_STATUS := '2'
			ZX0->ZX0_OBS := cNumPdC+ cMsgLog + cMsgLog1
			MsUnlock()
			_lRet :=  .T.
			RollBackSxE()
		Else
			ConfirmSX8()
			RecLock('ZX0',.F.)
			ZX0->ZX0_STATUS := '1'
			MsUnlock()
			aadd(aDell,aFiles[_a,1])
		EndIF
		
		If _lRet .AND. !Empty(cMsgLog)
			RecLock("ZX0",.F.)
			ZX0->ZX0_STATUS := '3'
			ZX0->ZX0_OBS := cNumPdC+ 'N. Pedido no protheus : '+_cPedido+' incluido, porem falta: '+_plin + cMsgLog
			MsUnlock()
			_lRet := .T.
		EndIf
	EndIf
	
Return(_lRet)

