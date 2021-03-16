#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
Funcao      : JKFAT010
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor       : Consultoria Totvs
Data/Hora   : 19/02/2015
Obs         :
Revisão     :
Data/Hora   :
Módulo      : Faturamento
Cliente     : Exeltis
*/

*-----------------------------*
 User Function JKFAT010()
*-----------------------------*

	Local cCliente := SubStr(Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),1,35)
	Local cCidade  := Alltrim(Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MUN")) +"-"+ Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")
	Local cTransp  := iif(Empty(SC5->C5_TRANSP), Space(6), Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"))
	Local cPedido  := SC5->C5_NUM
	Local cNF	   := SC5->C5_NOTA+"/"+SC5->C5_SERIE
	Local lCheck := .F.
	Private nVolume		:=	GravaVolume(cPedido,)
	Private nVolde		:=	Space(6)
	Private nVolAte		:=	GravaVolume(cPedido,)
	Private	oDlg,oVolume,oVolDe,oVolate,oCliente,oCidade,oVende,oPedido,oCidade,oEtq,oTransp,oCheck,oFont

	Define Font oFont Name 'Calibri' Size 0, -12

	DEFINE MSDIALOG oDlg FROM 2,3 TO 350,370 TITLE 'Volumes Pedido de Venda' Pixel

	//Objetos SAY - Texto
	@005,005	Say "Pedido: " 		Font oFont 	Pixel of oDlg
	@005,085	Say "Nota/Serie: "	Font oFont 	Pixel of oDlg
	@025,005	Say "Cliente:" 		Font oFont 	Pixel of oDlg
	@045,005	Say "Cidade:" 		Font oFont 	Pixel of oDlg
	@065,005	Say "Volume(s):"	Font oFont 	Pixel of oDlg
	@065,090	Say "Transp.:" 		Font oFont 	Pixel of oDlg
	@115,005	Say "Volume de:" 	Font oFont 	Pixel of oDlg
	@115,085	Say "Volume Ate:" 	Font oFont 	Pixel of oDlg

	//Objeto MSGET	- Captura de informação
	@005,030	Msget 		oPedido 	Var cPedido		when .F. 	Size 040,010 Pixel of oDlg
	@005,120	Msget 		oNF	 		Var cNF 		when .F. 	Size 040,010 Pixel of oDlg
	@025,030	Msget 		oCliente	Var cCliente 	when .F. 	Size 130,010 Pixel of oDlg
	@045,030	Msget 		oCidade		Var cCidade 	when .F. 	Size 085,010 Pixel of oDlg
	@065,040	Msget 		oVolume		Var nVolume 				Size 040,010 Pixel of oDlg
	@065,120	Msget 		oTranp 		Var cTransp 	when .F. 	Size 040,010 Pixel of oDlg
	@115,040	Msget 		oVolde		Var nVolde 		When lCheck	Size 040,010 Pixel of oDlg
	@115,120	Msget 		oVolate		Var nVolate 	When .F.	Size 040,010 Pixel of oDlg

	//Objeto CHECKBOX - Captura de informação
	@095,007	CHECKBOX 	oCheck		Var lCheck 		When (!Empty(nVolAte)) PROMPT "Reimpressão" SIZE 85,007 PIXEL OF oDlg ON CLICK(Marca(lCheck))

	//Objeto BUTTON - Botões de ação
	@145,80 BUTTON OemToAnsi('Confirma') SIZE 30,15 ACTION (btOk(cPedido,cNF,nVolume,cCliente,cCidade,cTransp,nVolde,nVolate),oDlg:End()) OF oDlg PIXEL
	@145,125 BUTTON OemToAnsi('Cancelar') SIZE 30,15 ACTION (oDlg:End()) OF oDlg PIXEL

	Activate MsDialog oDlg Centered

Return 

*--------------------------------*
 Static Function Marca(lCheck)
*--------------------------------*

	If lCheck
		oVolde:Enable()
		oVolate:Enable()
		oVolume:Disable()
	Else
		nVolde := Space(6)
		oVolde:Disable()
		oVolate:Disable()
		oVolume:Enable()
	EndIf

	oVolde:Refresh()
	oVolate:Refresh()
	oVolume:Refresh()

Return

*--------------------------------------------------------------------------------------*
 Static Function btOk(cPedido,cNF,nVolume,cCliente,cCidade,cTransp,nVolde,nVolate)
*--------------------------------------------------------------------------------------*

	//	Grava o Volume Imputado pela TELA
	GravaVolume(cPedido,nVolume)

	//	Imprime as etiquetas
	Processa({||Imprime(cPedido,cNF,nVolume,cCliente,cCidade,cTransp,nVolde,nVolate)})

Return

*--------------------------------------------------------------------------------------*
 Static Function Imprime(cPedido,cNF,nVolume,cCliente,cCidade,cTransp,nVolde,nVolate)
*--------------------------------------------------------------------------------------*

	//Variaveis de Orientação na Página
	Local nTamanho	:= 21	//Tamanho da Fonte
	Local nCol1		:= 001	//Primeira coluna
	Local nCol2		:= 020	//Segunda coluna
	Local nI		:= iif(Empty(nVolde),1,val(nVolde))
	Local nVolume 	:= iif(Empty(nVolate) .or. Empty(nVolDe),	iif(valtype(nVolume)="C",Val(nVolume),nVolume),	Val(nVolDe))
	Local nLin 		:= 00	//primeira margem
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo     	 := "Impressão de Etiquetas de Volume"
	Local Cabec1       	 := ""
	Local Cabec2       	 := ""
	Local imprime      	 := .T.
	Local aOrd 			 := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "JKFAT010" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt      	 := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "JKFAT010" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString      := ""

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//PEDIDO			CPEDIDO
	//VENDEDOR			CVENDE
	//VOLUME			STRZERO(nI,3,0)+"/"+STRZERO(GravaVolume(cPedido,),3,0)
	//CLIENTE			CCLIENTE
	//CIDADE			CCIDADE
	//TRANSPORTADORA	CTRANSP

	/*ADriver   := LEDriver()
	cCompac := aDriver[1]
	@nlin,00 PSAY &cCompac*/

	nLin++

	For nI := nI to nVolume

		@nLin,nCol1 PSAY "PEDIDO:"
		@nLin,nCol2 PSAY CPEDIDO
		nLin++
		@nLin,nCol1 PSAY "NOTA/SERIE:"
		@nLin,nCol2 PSAY CNF
		nLin++
		@nLin,nCol1 PSAY "VOLUME:"
		@nLin,nCol2 PSAY STRZERO(nI,3,0)+"/"+STRZERO(GravaVolume(cPedido,),3,0)
		nLin++
		@nLin,nCol1 PSAY "CLIENTE:"
		@nLin,nCol2 PSAY CCLIENTE
		nLin++
		@nLin,nCol1 PSAY "CIDADE:"
		@nLin,nCol2 PSAY CCIDADE
		nLin++
		@nLin,nCol1 PSAY "TRANSPORTADORA:"
		@nLin,nCol2 PSAY CTRANSP
		nLin+=4

	Next nI

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

*--------------------------------------------------*
 Static Function GravaVolume(cPedido,nVolume)
*--------------------------------------------------*

	DbSelectArea("SC5")
	SC5->(DBSetOrder(1))
	If SC5->(DBSeek(xFilial("SC5")+cPedido))

		// Se faturadoa
		if !(Empty(SC5->(C5_NOTA+C5_SERIE))) .and. !(Empty(nVolume))
			DbSelectArea("SF2")
			SF2->(DBSetOrder(1))
			SF2->(DBSeek(xFilial("SF2")+SC5->(C5_NOTA+C5_SERIE)))
			if Empty(SF2->F2_VOLUME1)
			
				RecLock("SF2",.F.)
				SF2->F2_VOLUME1 := Val(nVolume)
				SF2->(MsUnLock())
				
			endif

			SF2->(DBCloseArea())

		endif

		if Empty(SC5->C5_VOLUME1) .and. !(Empty(nVolume))
			RecLock("SC5",.F.)
			SC5->C5_VOLUME1	:= Val(nVolume)
			SC5->( MsUnlock() )
		else
			nVolume	:= SC5->C5_VOLUME1
			if nVolume = 0
				nVolume	:= Space(6)
			EndIf
		endif

	Else
		MsgStop("Falha ao gravar o volume!")
	EndIf

Return nVolume

*----------------------------------------------------------------------------------------*
 Static Function ImpTMS(cPedido,cVende,nVolume,cCliente,cCidade,cTransp,nVolde,nVolate)
*----------------------------------------------------------------------------------------*

	//Variaveis de Orientação na Página
	Local nTamanho	:= 21	//Tamanho da Fonte
	Local nPriMargem:= 50	//Margem superior da folha
	Local nCol		:= 050	//Primeira coluna
	Local nCol2		:= 620	//Segunda coluna
	Local nLinhas	:= 2900
	Local nColunas	:= 4000
	Local oFont		:= TFONT():New("ARIAL",7,nTamanho,.T.	,.F.,5	,.T.,5	,.T.,.F.)
	Local oFontN 	:= TFONT():New("ARIAL",7,nTamanho,		,.T.,	,	,	,.T.,.F.)
	Local nI		:= iif(Empty(nVolde),1,val(nVolde))
	Local nVolume 	:= iif(Empty(nVolate) .or. Empty(nVolDe),	nVolume,	Val(nVolDe))
	Local cStartPath:= ""
	Local nLin 		:= 50
	Local oPrint	:= TMSPRINTER():New("")
	Local nPag		:= 1

	#define DMPAPER_LETTER 1 //Validar!!
	oPrint:setPaperSize(DMPAPER_LETTER)
	oPrint:SetPortrait()
	oPrint:StartPage()
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")
	nLin += nPriMargem
	nTamanho := nTamanho * 2
	oPrint:Line(nLin,	nCol+005,		nLin														,	3000	)

	ProcRegua(nVolume)

	//	For nO := 1 to nColunas step 300
	For nI := nI to nVolume

		//		IncRegua()
		if nLin >= nLinhas
			oPrint:endPage()
			oPrint:StartPage()
			nLin := nPriMargem
			oPrint:Line(nLin,	nCol+005,		nLin												,	3000	)
		endif

		oPrint:Say(	nLin,	nCol+005,		"Pedido:"												,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		cPedido													,	oFont	)
		nLin += 20+nTamanho
		oPrint:Say(	nLin,	nCol+005,		"Vendedor:"												,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		cVende													,	oFont	)
		nLin += 20+nTamanho
		oPrint:Say(	nLin,	nCol+005,		"Volume:"												,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		STRZERO(nI,3,0)+"/"+STRZERO(GravaVolume(cPedido,),3,0)	,	oFont	)
		nLin += 20+nTamanho
		oPrint:Say(	nLin,	nCol+005,		"Cliente:"												,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		cCliente												,	oFont	)
		nLin += 20+nTamanho
		oPrint:Say(	nLin,	nCol+005,		"Cidade:"												,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		cCidade													,	oFont	)
		nLin += 20+nTamanho
		oPrint:Say(	nLin,	nCol+005,		"Transportadora:" 										,	oFontN	)
		oPrint:Say(	nLin,	nCol2+150,		cTransp													,	oFont	)
		nLin += 35+nTamanho
		oPrint:Line(nLin,	nCol+005,		nLin													,	3000	)
		nLin += 20+nTamanho

	next nI

	//	next nO
	oPrint:Preview()

Return