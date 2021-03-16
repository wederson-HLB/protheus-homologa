#include "PROTHEUS.CH"
#include "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORRFAT10   ºAutor  ³Andre Minelli      º Data ³  05/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do RPS - Recibo Provisorio de Servicos - referenteº±±
±±º          ³ao processo da Nota Fiscal Eletronica de Sao Paulo.         º±±
±±º          ³Impressao grafica - sem integracao com word.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ORANGE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ORRFAT10()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local tamanho		:= "G"
Local titulo		:= "Impressão RPS"
Local cDesc1		:= "Impressão do Recibo Provisório de Serviços - RPS"
Local cDesc2		:= " "
Local cDesc3		:= " "
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""                         

Local lPrinter		:= .T.
Local lOk			:= .F.
Local aSays     	:= {}, aButtons := {}, nOpca := 0

Private nomeprog 	:= "MATR968"
Private nLastKey 	:= 0
Private cPerg 		:= "ORFAT1"
Private nPagina		:= 0

Private oPrint

cString := "SF2"
wnrel   := "MATR968"

AtuX1()
Pergunte(cPerg,.T.)

AADD(aSays,"Impressão do Recibo Provisório de Serviços - RPS")

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )  

FormBatch( Titulo, aSays, aButtons,, 160 )

If nOpca == 0
   Return
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint := TMSPrinter():New("Impressão RPS")		
oPrint:SetPortrait()					// Modo retrato
oPrint:Setup()					
oPrint:SetPaperSize(9)					// Papel A4
oPrint:StartPage()

If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| Mt968Print(@lEnd,wnRel,cString)},Titulo)

oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt968Print³ Autor ³ Mary C. Hergert       ³ Data ³ 03/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do Processamento do Relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mt968Print(lEnd,wnRel,cString)

Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
Local aTMS			:= {}
Local aItensSD2     := {}
Local cDoc			:= ""
Local cSerie		:= ""
Local cCliente		:= ""
Local cLoja			:= ""

Local cServ			:= ""
Local cDescrServ	:= ""
Local cCNPJCli		:= ""                            
Local cTime			:= "" 
Local lNfeServ		:= AllTrim(SuperGetMv("MV_NFESERV",.F.,"1")) == "1"
Local cLogo			:= ""
Local cServPonto	:= ""               
Local cObsPonto		:= ""
Local cAliasSF3		:= "SF3"
Local cCli			:= ""
Local cIMCli		:= ""
Local cEndCli		:= ""
Local cBairrCli		:= ""
Local cCepCli		:= ""
Local cMunCli		:= ""
Local cUFCli		:= ""
Local cEmailCli		:= ""
Local cCampos		:= ""     
Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
Local cCodServ      := ""
Local cF3_NFISCAL   := ""
Local cF3_SERIE     := ""
Local cF3_CLIEFOR   := ""
Local cF3_LOJA      := ""
Local cF3_EMISSAO   := ""
Local cKey          := ""        
Local cObsRio       := ""
Local cLogAlter     := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo  

Local lCampBar      := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
Local lIssMat		:= (cAliasSF3)->(FieldPos("F3_ISSMAT")) > 0
Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
Local lObsNFE		:= ExistBlock("MTOBSNFE")
Local lCliNFE		:= ExistBlock("MTCLINFE")           
Local lPEImpRPS		:= ExistBlock("MTIMPRPS")           
Local lDescrBar     := GetNewPar("MV_DESCSRV",.F.)
Local lImpRPS		:= .T. 
Local lcmpAbat		:= SD2->( FieldPos("D2_ABATISS")>0 .And. FieldPos("D2_ABATMAT")>0 )

Local nValDed		  := 0
Local nTOTAL        := 0 
Local nDEDUCAO      := 0 
Local nBASEISS      := 0 
Local nALIQISS      := 0
Local nVALISS       := 0 
Local nDescIncond   := 0
Local nValLiq       := 0
Local nVlContab     := 0
Local nValDesc	     := 0

Local nAliqPis      := 0
Local nAliqCof      := 0
Local nAliqCSLL     := 0
Local nAliqIR       := 0
Local nAliqINSS     := 0
Local nValPis       := 0
Local nValCof       := 0
Local nValCSLL      := 0
Local nValIR        := 0
Local nValINSS      := 0 
Local cNatureza     := ""
Local cRecIss       := "" 
Local cRecCof       := ""
Local cRecPis       := ""
Local cRecIR        := ""
Local cRecCsl       := ""
Local cRecIns		:= ""

Local nCopias		:= mv_par09
Local nLinIni		:= 200
Local nColIni		:= 100
Local nColFim		:= 2250
Local nLinFim		:= 2180
Local nX			:= 1
Local nY			:= 1
Local nLinha		:= 0
Local nValBase		:= 0
Local nAliquota		:= 0
Local cCodAtiv		:= ""

#IFDEF TOP
	Local cQuery    := "" 
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""       
#ENDIF

Private oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Private oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
Private oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
Private oFont07 	:= TFont():New("Courier New",7,7,,.F.,,,,.T.,.F.)	//Normal s/negrito
Private oFont09 	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
Private oFont09n	:= TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito

Private lRecife	   := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RECIFE",.T.,.F.) 
Private lJoinville := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "JOINVILLE",.T.,.F.)
Private lSorocaba  := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "SOROCABA",.T.,.F.)
Private lRioJaneiro:= Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RIO DE JANEIRO",.T.,.F.)      
Private lBhorizonte:= Iif(GetNewPar("MV_ESTADO","xx") == "MG" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "BELO HORIZONTE",.T.,.F.)      

dbSelectArea("SF3")
dbSetOrder(6)

#IFDEF TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIssMat
    	cCampos := " ,F3_ISSMAT "
	Endif
	 
	If lRecife
    	cCampos += " ,F3_CNAE "
	Endif	     
	
	If Empty(cCampos)
		cCampos := "%%"
	Else       
		cCampos := "% " + cCampos + " %"
	Endif                              

    If TcSrvType()<>"AS/400"
    
		lQuery 		:= .T.
		cAliasSF3	:= GetNextAlias()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par10 == 2
			cQuery := "% SF3.F3_DTCANC = '' AND %"
		Else                                      
			cQuery := "%%"
		Endif
		
		BeginSql Alias cAliasSF3
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE
			COLUMN F3_DTCANC AS DATE
			COLUMN F3_EMINFE AS DATE
			SELECT F3_FILIAL,F3_ENTRADA,F3_EMISSAO,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_PDV,
				F3_LOJA,F3_ALIQICM,F3_BASEICM,F3_VALCONT,F3_TIPO,F3_VALICM,F3_ISSSUB,F3_ESPECIE,
				F3_DTCANC,F3_CODISS,F3_OBSERV,F3_NFELETR,F3_EMINFE,F3_CODNFE,F3_CREDNFE, F3_ISENICM
				%Exp:cCampos%
			
			FROM %table:SF3% SF3
				
			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND 
				SF3.F3_CFO >= '5' AND 
				SF3.F3_ENTRADA >= %Exp:mv_par01% AND 
				SF3.F3_ENTRADA <= %Exp:mv_par02% AND 
				SF3.F3_TIPO = 'S' AND
				SF3.F3_CODISS <> %Exp:Space(TamSX3("F3_CODISS")[1])% AND
				SF3.F3_CLIEFOR >= %Exp:mv_par03% AND
				SF3.F3_CLIEFOR <= %Exp:mv_par04% AND
				SF3.F3_LOJA	   >= %Exp:mv_par05% AND
				SF3.F3_LOJA    <= %Exp:mv_par06% AND
				SF3.F3_NFISCAL >= %Exp:mv_par07% AND
				SF3.F3_NFISCAL <= %Exp:mv_par08% AND
				%Exp:cQuery%
				SF3.%NotDel%                           
					
			ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA
		EndSql
	
		dbSelectArea(cAliasSF3)
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA+F3_CNAE"
		cFiltro := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
		cFiltro += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' .And. "	
		cFiltro += "DtOs(F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .And. "
		cFiltro	+= "DtOs(F3_ENTRADA) <= '" + Dtos(mv_par02) + "' .And. "
		cFiltro	+= "F3_TIPO == 'S' .And. F3_CODISS <> '" + Space(Len(F3_CODISS)) + "' .And. "
		cFiltro	+= "F3_CLIEFOR >= '" + mv_par03 + "' .And. F3_CLIEFOR <= '" + mv_par04 + "' .And. "
		cFiltro	+= "F3_LOJA >= '" + mv_par05 + "' .And. F3_LOJA <= '" + mv_par06 + "' .And. "
		cFiltro	+= "F3_NFISCAL >= '" + mv_par07 + "' .And. F3_NFISCAL <= '" + mv_par08 + "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cFiltro	+= " .And. Empty(F3_DTCANC)"
		Endif

		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros...")
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif    
#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasSF3)->(!Eof())		

		If Interrupcao(@lEnd)
			Exit
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa Deducoes do ISS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValDed := (cAliasSF3)->F3_ISSSUB		
		If lIssMat
			nValDed += (cAliasSF3)->F3_ISSMAT
		Endif	
           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor contabil ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nVlContab := (cAliasSF3)->F3_VALCONT		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o SF2 para verificar o horario de emissao do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF2->(dbSetOrder(1))
		cTime := ""
		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			cTime := Transform(SF2->F2_HORA,"@R 99:99")			
			// NF Cupom nao sera processada
			If !Empty(SF2->F2_NFCUPOM)
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS := (cAliasSF3)->(GetArea())
		lImpRPS	 := .T.
		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		
		If !lImpRPS
			(cAliasSF3)->(dbSKip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a descricao do codigo de servicos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDescrServ := ""
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
			cDescrServ := SX5->X5_DESCRI
		Endif
		If lDescrBar
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
					Endif
				Endif
			Endif
		Endif
		
		If lRecife
			cCodAtiv := Alltrim((cAliasSF3)->F3_CNAE)
		Else
			cCodServ := Alltrim((cAliasSF3)->F3_CODISS) + " - " + cDescrServ
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o pedido para discriminar os servicos prestados no documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cServ := ""
		If lNfeServ
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
				Endif
			Endif
		Else
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))
			If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				cServ := AllTrim(SubStr(SX5->X5_DESCRI,1,55))
			Endif
		Endif
		
		If Empty(cServ)
			cServ := cDescrServ
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para compor a descricao a ser apresentada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS	:= (cAliasSF3)->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
			cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
			cServ := cServPonto
		Endif
		aPrintServ	:= Mtr968Mont(cServ,99,5000)
		
		If lRioJaneiro
         cObsRio := ""
         nDescIncond := 0                         
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		         SF4->(DbSetOrder(1))		
					If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
		            If SF2->F2_DESCONT > 0
		               If SF4->F4_DESCOND == "1"  
		                  cObsRio := " Deconto Condic. de (R$) " 
		                  cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99")) 
		               Else
		                  nDescIncond := SF2->F2_DESCONT                  
		               EndIf
		            EndIf
		    		EndIf
				Endif
			Endif            
		Endif
		cObserv 	:= Alltrim((cAliasSF3)->F3_OBSERV) + Iif(!Empty((cAliasSF3)->F3_OBSERV)," | ","")
		cObserv 	+= Iif(!Empty((cAliasSF3)->F3_PDV) .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "CF","RPS generado por emisor de comp. fiscal(ECF)" + " | ","")
      If lRioJaneiro
		    cObsRio     += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
		EndIf
		aAreaRPS 	:= (cAliasSF3)->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para complementar as observacoes a serem apresentadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cObsPonto	:= ""
		If lObsNFE
			cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		cObserv 	:= cObserv + cObsPonto
		cObserv 	:= cObserv + cObsRio
		aPrintObs	:= Mtr968Mont(cObserv,11,675)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cLiente/fornecedor do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCNPJCli := ""
		cRecIss  := ""
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If RetPessoa(SA1->A1_CGC) == "F"
				cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cCli			:= SA1->A1_NOME
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
			cRecIss     := SA1->A1_RECISS
			cRecCof     := SA1->A1_RECCOFI
			cRecPis     := SA1->A1_RECPIS
			cRecIR      := SA1->A1_RECIRRF    
			cRecCsl     := SA1->A1_RECCSLL         
			cRecIns     := SA1->A1_RECINSS
		Else
			(cAliasSF3)->(dbSKip())
			Loop
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTms()
			aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para trocar o cliente a ser impresso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
				cCli		:= aMTCliNfe[01]
				cCNPJCli	:= aMTCliNfe[02]
				If RetPessoa(cCNPJCli) == "F"
					cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif

		If lBhorizonte                        
			nValDed     := 0
			nValDesc    := 0
			nDescIncond := 0
			nValLiq     := 0
			nVALISS     := 0
			nValPis     := 0
			nValCof     := 0
			nValCSLL    := 0
			nValIR      := 0
			nValINSS	:= 0
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
						If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->F3_CODISS) 
							SF4->(DbSetOrder(1))		
							If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								nValLiq		:= SD2->D2_TOTAL
								nVALISS		:= Iif(SD2->(FieldPos("D2_VALISS")) > 0,SD2->D2_VALISS, 0) 
								nValPis		:= Iif(SD2->(FieldPos("D2_VALPIS")) > 0,SD2->D2_VALPIS, 0) 
								nValCof		:= Iif(SD2->(FieldPos("D2_VALCOF")) > 0,SD2->D2_VALCOF, 0) 
								nValCSLL	:= Iif(SD2->(FieldPos("D2_VALCSL")) > 0,SD2->D2_VALCSL, 0) 
								nValIR		:= Iif(SD2->(FieldPos("D2_VALIRRF")) > 0,SD2->D2_VALIRRF, 0)
								nValINSS	:= Iif(SD2->(FieldPos("D2_VALINS")) > 0,SD2->D2_VALINS, 0)

								nValDesc	:= SD2->D2_DESCON

								If SF4->F4_DESCOND <> "1"  
									nDescIncond := nValDesc
								EndIf

								If SF4->F4_AGREG == "D"
									nValDesc += SD2->D2_DESCICM
									nValLiq -= SD2->D2_DESCICM
									//Acrescenta o ISS no valor Contábil, pois o ISS foi deduzido na emissão da NF e
									//para a impressão correta do RPS é necessario soma-lo
									//nVlContab é impresso como valor da mercadoria para Belo Horizonte
									nVlContab := nVlContab + SD2->D2_DESCICM
								Endif
								
								nValDed += SD2->( D2_ABATISS + D2_ABATMAT )
								
							EndIf
						Endif
						SD2->(dbSkip())
					Enddo 
				Endif 
			EndIf
			nRetFeder   := 0
	        If cRecIss == "1"
            	nValLiq := nValLiq - nValISS
	        EndIf
         	If cRecCof == "S"
            	nValLiq    := nValLiq - nValCof
			   	nRetFeder  := nRetFeder + nValCof
			EndIf
         	If cRecPis == "S"
            	nValLiq := nValLiq - nValPis     
            	nRetFeder  := nRetFeder + nValPis
			EndIf
         	If cRecCsl == "S"
            	nValLiq := nValLiq - nValCsll
            	nRetFeder  := nRetFeder + nValCsll
			EndIf
         	If cRecIr == "1"
            	nValLiq := nValLiq - nValIR    
            	nRetFeder  := nRetFeder + nValIR
			Endif            
			If cRecIns == "S"
				nValLiq := nValLiq - nValINSS
				nRetFeder  := nRetFeder + nValINSS
			EndIf
		Endif
		
		If lJoinville
			SF2->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE)))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						nValBase	:= Iif (Empty((cAliasSF3)->F3_BASEICM),(cAliasSF3)->F3_ISENICM,(cAliasSF3)->F3_BASEICM)
						nAliquota	:= SB1->B1_ALIQISS
					Endif
				EndIf
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Relatorio Grafico:                                                                                      ³
		//³* Todas as coordenadas sao em pixels	                                                                   ³
		//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
		//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to nCopias
			
			//Imprime Estrutura do RPS
			EstrRps(nLinIni,nColIni,nLinFim,nColFim,cAliasSF3,cCli,cCNPJCli,cIMCli,cEndCli,cBairrCli,cCepCli,cMunCli,cUFCli,cEmailCli,nVlContab,nValDed,nDescIncond,nValBase,nAliquota,cLogAlter,cTime,cCodAtiv,cCodServ,aPrintServ,aPrintObs,nCopias)

			//Imprime discrimincao dos servicos
			ImpDiscr(nLinIni,nColIni,nLinFim,nColFim,cAliasSF3,cCli,cCNPJCli,cIMCli,cEndCli,cBairrCli,cCepCli,cMunCli,cUFCli,cEmailCli,nVlContab,nValDed,nDescIncond,nValBase,nAliquota,cLogAlter,cTime,cCodAtiv,cCodServ,aPrintServ,aPrintObs,nCopias)
			
		Next
		
		cDoc 		 := (cAliasSF3)->F3_NFISCAL
		cSerie 		 := (cAliasSF3)->F3_SERIE
		cCliente	 := (cAliasSF3)->F3_CLIEFOR
		cLoja		 := (cAliasSF3)->F3_LOJA
		
		If  SuperGetMv( "OR_XGERBOL" , .F. , .T. , Nil )
			BLTCITI(cDoc, cSerie, cCliente, cLoja)
			oPrint:EndPage()                      
		End If
		
		(cAliasSF3)->(dbSkip())
		
		If !((cAliasSF3)->(Eof()))
			oPrint:EndPage()
		Endif
		
	Enddo
	
If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else

dbSelectArea(cAliasSF3)
dbCloseArea()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | EstrRPS   ºAutor  ³Andre Minelli      º Data ³  08/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a estrutura de impressao do RPS para quebra de pagina  º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ORANGE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EstrRPS(nLinIni,nColIni,nLinFim,nColFim,cAliasSF3,cCli,cCNPJCli,cIMCli,cEndCli,cBairrCli,cCepCli,cMunCli,cUFCli,cEmailCli,nVlContab,nValDed,nDescIncond,nValBase,nAliquota,cLogAlter,cTime,cCodAtiv,cCodServ,aPrintServ,aPrintObs,nCopias)

Local nLinRPS := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Box no tamanho do RPS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPagina++
oPrint:Say(160,nColFim-200,"Pagina " + StrZero(nPagina,2),oFont09n)

oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)
oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Título do Documento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say(160,740,"RECIBO PROVISÓRIO DE SERVIÇOS - RPS",oFont12n)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados da empresa emitente do documento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If Empty(cLogAlter)
    cLogo := FisxLogo("1")
Else
    cLogo := cLogAlter
EndIf
// o arquivo com o logo deve estar abaixo do rootpath (mp8\system)
oPrint:SayBitmap(280,nColIni+10,"logo_orange.bmp",480,215) 

oPrint:Line(nLinIni,1800,612,1800)
oPrint:Line(354,1800,354,nColFim)
oPrint:Line(483,1800,483,nColFim)
oPrint:Line(612,nColIni,612,nColFim)
oPrint:Say(245,730,PadC(Alltrim(SM0->M0_NOMECOM),40),oFont12n)
oPrint:Say(305,680,PadC(Alltrim(SM0->M0_ENDENT),50),oFont10)
oPrint:Say(355,680,PadC(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50),oFont10)
oPrint:Say(405,680,PadC(Alltrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT),50),oFont10)
oPrint:Say(455,680,PadC(Alltrim("Telefone:") + Alltrim(SM0->M0_TEL),50),oFont10)
oPrint:Say(505,680,PadC(Alltrim("C.N.P.J.:") + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFont10)
oPrint:Say(555,680,PadC(Alltrim("I.M.:") + Alltrim(SM0->M0_INSCM),50),oFont10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes sobre a emissao do RPS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say(250,1830,PadC(Alltrim("Número/Série RPS"),15),oFont10n)
oPrint:Say(295,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F3_NFISCAL) + Iif(!Empty((cAliasSF3)->F3_SERIE)," / " + Alltrim((cAliasSF3)->F3_SERIE),"")),15),oFont10)
oPrint:Say(375,1830,PadC(Alltrim("Data Emissão"),15),oFont10n)
oPrint:Say(420,1830,PadC((cAliasSF3)->F3_EMISSAO,15),oFont10)
oPrint:Say(510,1830,PadC(Alltrim("Hora Emissão"),15),oFont10n)
oPrint:Say(555,1830,PadC(Alltrim(cTime),15),oFont10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do destinatario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say(625,nColIni,PadC(Alltrim("DADOS DO DESTINATÁRIO"),75),oFont12n)
oPrint:Say(685,250,"Nome/Razão Social:",oFont10n)
oPrint:Say(745,250,"C.P.F./C.N.P.J.:",oFont10n)
oPrint:Say(805,250,"Inscrição Municipal:",oFont10n)
oPrint:Say(865,250,"Endereço:",oFont10n)
oPrint:Say(925,250,"CEP:",oFont10n)
oPrint:Say(985,250,"Município:",oFont10n)
oPrint:Say(985,1800,"UF:",oFont10n)
oPrint:Say(1045,250,"E-mail:",oFont10n)
oPrint:Say(685,750,Alltrim(cCli),oFont10)
oPrint:Say(745,750,Alltrim(cCNPJCli),oFont10)
oPrint:Say(805,750,Alltrim(cIMCli),oFont10)
oPrint:Say(865,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) ,oFont10)
oPrint:Say(925,750,Transform(cCepCli,"@R 99999-999"),oFont10)
oPrint:Say(985,750,Alltrim(cMunCli),oFont10)
oPrint:Say(985,1900,Alltrim(cUFCli),oFont10)
oPrint:Say(1045,750,Alltrim(cEmailCli),oFont10)
oPrint:Line(1105,nColIni,1105,nColFim)

oPrint:Line(1550,nColIni,1550,nColFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valores da prestacao de servicos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lBhorizonte
    oPrint:Say(1580,nColIni,PadC(Alltrim("VALOR TOTAL DA PRESTAÇÃO DE SERVIÇOS"),50),oFont12n)
    oPrint:Say(1585,1700,"R$ " + Transform(nVlContab,"@E 999,999,999.99"),oFont10)
    oPrint:Line(1650,nColIni,1650,nColFim)
EndIf 

oPrint:Say(1665,250,Alltrim("Código do Serviço"),oFont10n)
oPrint:Say(1705,250,Alltrim(cCodServ),oFont10)

oPrint:Line(1750,nColIni,1750,nColFim)

oPrint:Line(1750,712,1850,712)
oPrint:Line(1750,1199,1850,1199)
oPrint:Line(1750,1686,1850,1686)    
oPrint:Say(1765,250,Alltrim("Total deduções (R$)"),oFont10n)
oPrint:Say(1805,370,Transform(nValDed,"@E 999,999,999.99"),oFont10)
oPrint:Say(1765,737,Alltrim("Base de cálculo (R$)"),oFont10n)
oPrint:Say(1805,857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99")),oFont10)
oPrint:Say(1765,1224,Alltrim("Alíquota (%)"),oFont10n)
oPrint:Say(1805,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFont10)
oPrint:Say(1765,1711,Alltrim("Valor do ISS (R$)"),oFont10n)
oPrint:Say(1805,1831,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
oPrint:Line(1850,nColIni,1850,nColFim)

If !lBhorizonte
	oPrint:Say(1880,nColIni,PadC(Alltrim("INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"),75),oFont12n)
	oPrint:Line(1950,nColIni,1950,nColFim)
	oPrint:Line(1950,712,2050,712)
	oPrint:Line(1950,1070,2050,1070)
	oPrint:Line(1950,1686,2050,1686)
	oPrint:Say(1965,250,Alltrim("Número"),oFont10n)
	oPrint:Say(2005,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont10)
	oPrint:Say(1965,737,Alltrim("Emissão"),oFont10n)
	oPrint:Say(2005,757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont10)
	oPrint:Say(1965,1094,Alltrim("Código Verificação"),oFont10n)
	oPrint:Say(2005,1144,Padl((cAliasSF3)->F3_CODNFE,24),oFont10)
	oPrint:Say(1965,1711,Alltrim("Crédito IPTU"),oFont10n)
	oPrint:Say(2005,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont10)
	oPrint:Line(2050,nColIni,2050,nColFim)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outras Informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Say(2063,nColIni,PadC(Alltrim("OUTRAS INFORMAÇÕES"),75),oFont12n)
	nLinha	:= 2100
	For nY := 1 to Len(aPrintObs)
		If nY > 11
			Exit
		Endif
		oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont10)
		nLinRps	:= nLinRps + 50
	Next

EndIf

If nCopias > 1 .And. nX < nCopias
	oPrint:EndPage()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | ImpDiscr ºAutor  ³Andre Minelli       º Data ³  08/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime a discriminacao dos servicos prestados              º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ORANGE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpDiscr(nLinIni,nColIni,nLinFim,nColFim,cAliasSF3,cCli,cCNPJCli,cIMCli,cEndCli,cBairrCli,cCepCli,cMunCli,cUFCli,cEmailCli,nVlContab,nValDed,nDescIncond,nValBase,nAliquota,cLogAlter,cTime,cCodAtiv,cCodServ,aPrintServ,aPrintObs,nCopias)

Local nlinha := 1178
Local nZ	 := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Discriminacao dos Servicos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say(1118,nColIni,PadC(Alltrim("DISCRIMINAÇÃO DOS SERVIÇOS"),75),oFont12n)
For nZ := 1 to Len(aPrintServ)
	If Alltrim(aPrintServ[nZ]) # ""
		If nZ % 12 == 0
			oPrint:EndPage()
			oPrint:StartPage()
			EstrRPS(nLinIni,nColIni,nLinFim,nColFim,cAliasSF3,cCli,cCNPJCli,cIMCli,cEndCli,cBairrCli,cCepCli,cMunCli,cUFCli,cEmailCli,nVlContab,nValDed,nDescIncond,nValBase,nAliquota,cLogAlter,cTime,cCodAtiv,cCodServ,aPrintServ,aPrintObs,nCopias)
			nlinha := 1178
			oPrint:Say(1118,nColIni,PadC(Alltrim("DISCRIMINAÇÃO DOS SERVIÇOS"),75),oFont12n)
		Endif
			oPrint:Say(nLinha,120,Alltrim(aPrintServ[nZ]),oFont07)
			nLinha 	:= nLinha + 30
	End If
Next nZ

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±± 
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString),nLinhas)

	cMemo := MemoLine(cString,145,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,120),nLinhas)
			cAux := MemoLine(cMemo,145,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M968Discri³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array com a string quebrada em linhas com o tamanho³±±
±±³          ³da capacidade de impressao da linha utilizado RPS Sorocaba  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M968Discri(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,130),nLinhas)

	cMemo := MemoLine(cString,130,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
			cAux := MemoLine(cMemo,130,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintBox  ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do BOX atrave³±±
±±³          ³s do deslocamento dos pixels pelo for next                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintLine ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do PrintLine ³±±
±±³          ³Atraves do deslocamento dos pixels pelo for next            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BLTCITI  ³ Autor ³ Totvs                 ³ Data ³ 24/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO CITIBANK COM CODIGO DE BARRAS VVVV     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para TELIT                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BLTCITI(cDoc,cSerie,cCliente,cLoja)

LOCAL	aPergs := {} 
LOCAL   cQuery := ""
PRIVATE lExec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras-Banco do Citibank"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

cQuery := "SELECT * FROM " + RetSqlName("SE1") + " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND E1_SALDO > 0 AND E1_PREFIXO = '" + cSerie + "' AND E1_NUM = '" + cDoc + "'"
cQuery += " AND E1_CLIENTE = '" + cCliente + "' AND E1_LOJA = '" + cLoja + "' AND E1_VENCREA >= '" + DTOS(MV_PAR11) + "' AND E1_VENCREA <= '" + DTOS(MV_PAR12) + "' AND D_E_L_E_T_ = ''"
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSE1",.T.,.T.)

SQLSE1->(dbGoTop())

//If lExec
	Processa({|lEnd|MontaRel()})
//Endif

SQLSE1->(DbCloseArea())

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()
Local cAlphabt := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local _nParcela
LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
								Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
								Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado

Local aBolText := { MV_PAR14,MV_PAR15,MV_PAR16 }					   

LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat	   := 0         

While SQLSE1->(!EOF()) 

    //Quando nao estiver selecionado despreza o registro
    IF  ALLTRIM(SQLSE1->E1_PORTADO) <> ""
       If ALLTRIM(SQLSE1->E1_PORTADO) # "745"  .and.  ALLTRIM(SQLSE1->E1_PORTADO) # "000"
          DbSkip()
          Loop
       EndIf 
    EndIf     
    
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SQLSE1->E1_PORTADO+SQLSE1->E1_AGEDEP+SQLSE1->E1_CONTA,.T.)
	
	//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SQLSE1->E1_CLIENTE+SQLSE1->E1_LOJA,.T.)

	aDadosBanco  := {"745",; 																     // [1]Numero do Banco
				     SA6->A6_NREDUZ,;  																  // [2]Nome do Banco
	                 "0001",; // [3]Agência
                    SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10),; 	     // [4]Conta Corrente
                    ""  ,;    	  // [5]Dígito da conta corrente
                    "100"}																		   	  // [6]Codigo da Carteira 

		If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SA1->A1_COD )+" - "+SA1->A1_LOJA           ,;      	// [2]Código
		AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            ,;  			// [4]Cidade
		SA1->A1_EST                                      ,;     		// [5]Estado
		SA1->A1_CEP                                      ,;      	// [6]CEP
		SA1->A1_CGC										          ,;  			// [7]CGC
		SA1->A1_PESSOA										}       				// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
		AllTrim(SA1->A1_COD )+" - "+SA1->A1_LOJA              ,;   	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+" - "+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
		SA1->A1_ESTC	                                     ,;   	// [5]Estado
		SA1->A1_CEPC                                        ,;   	// [6]CEP
		SA1->A1_CGC												 		 ,;		// [7]CGC
		SA1->A1_PESSOA												 }				// [8]PESSOA
	Endif
	
	nVlrAbat   :=  SomaAbat(SQLSE1->E1_PREFIXO,SQLSE1->E1_NUM,SQLSE1->E1_PARCELA,"R",1,,SQLSE1->E1_CLIENTE,SQLSE1->E1_LOJA)

	//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 

	If AllTrim(SQLSE1->E1_PARCELA) $ cAlphabt
		_nParcela := at(AllTrim(SQLSE1->E1_PARCELA),cAlphabt)
	Else
		_nParcela := val(AllTrim(SQLSE1->E1_PARCELA))
	EndIf 
	
	//JSS - Alterado para solucionar o caso 022316
	//Inicio Alteração...
		//cNroDoc	:= Strzero(Val(Alltrim(SQLSE1->E1_NUM)),9)+StrZERO(_nParcela,2)               
		//cDigNNum:=KCALCDp(ALLTRIM(cNroDoc),"1")     
		//cNroDoc	:=cNroDoc+""+cDigNNum   
	If Empty(SQLSE1->E1_NUMBCO)
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		SEE->(DbGoTop())
		//EE_FILIAL + EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
		SEE->(DbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]))
		RecLock("SEE",.F.)
		cNroDoc			:= AllTrim (SEE->EE_FAXATU)
		SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
		MsUnLock()
	
		DbSelectArea("SE1")
		SE1->(RecLock("SE1",.f.))
		SE1->E1_NUMBCO 	:=	cNroDoc  
		SE1->(MsUnlock())
		Else
			cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
		EndIf
	//Fim Alteração.
	
	
	
	//Monta codigo de barras
	aCB_RN_NN    := Ret_cBarra( SQLSE1->E1_PREFIXO	,SQLSE1->E1_NUM	,SQLSE1->E1_PARCELA	,SQLSE1->E1_TIPO	,;
						       Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[4] ,aDadosBanco[5]	,;
						       cNroDoc		,(SQLSE1->E1_VALOR-nVlrAbat)	, "18"	,"9"	)
	DbSelectArea("SE1")
	aDadosTit	:= {AllTrim(SQLSE1->E1_NUM)+AllTrim(SQLSE1->E1_PARCELA)		,;  // [1] Número do título
						STOD(SQLSE1->E1_EMISSAO)                              	,;  // [2] Data da emissão do título
						dDataBase                    					,;  // [3] Data da emissão do boleto
						STOD(SQLSE1->E1_VENCTO)                               	,;  // [4] Data do vencimento
						(SQLSE1->E1_SALDO - nVlrAbat)                  	,;  // [5] Valor do título
						cNroDoc                             ,; //aCB_RN_NN[3],;  // [6] Nosso número (Ver fórmula para calculo)
						SQLSE1->E1_PREFIXO                               	,;  // [7] Prefixo da NF
						SQLSE1->E1_TIPO	                           		}   // [8] Tipo do Titulo
	
	nDataBase 	:= CtoD("07/10/1997") // data base para calculo do fator
	nFatorVen	:= STOD(SQLSE1->E1_VENCTO) - nDataBase // acha a diferenca em dias para o fator de vencimento
			
	Impress(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	nX := nX + 1

	SQLSE1->(dbSkip())

	nI++
	
EndDo

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impre³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASERDO BB COM CODIGO DE BARRAS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFontB8
LOCAL oFontB11c
LOCAL oFontB10
LOCAL oFontB15
Local oFontB075
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFontB8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFontB11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFontB10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFontB15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFontB15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFontB075 := TFont():New("Courier New",7.5,7.5,,.F.,,,,.T.,.F.)

nRow3 := 330

For nI := 100 to 2175 step 50
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
Next nI

oPrint:Say  (nRow3+1890,1800,"AUTENTICACAO MECANICA",oFontB075 )

oPrint:Line (nRow3+2000,100,nRow3+2000,2250)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)     

oPrint:SayBitmap(nRow3+1910, 110,"logo_citibank.bmp",300,070 )// Logotipo do Banco
oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-5",oFont21 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFontB15n)			//		Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2090,100,nRow3+2090,2250 )
oPrint:Line (nRow3+2230,100,nRow3+2230,2250 )
oPrint:Line (nRow3+2310,100,nRow3+2310,2250 )
oPrint:Line (nRow3+2380,100,nRow3+2380,2250 )

oPrint:Line (nRow3+2230,500 ,nRow3+2380,500 )
oPrint:Line (nRow3+2230,750 ,nRow3+2380,750 )
oPrint:Line (nRow3+2230,1000,nRow3+2380,1000)
oPrint:Line (nRow3+2230,1300,nRow3+2380,1300)
oPrint:Line (nRow3+2230,1480,nRow3+2380,1480)
oPrint:Line (nRow3+2230,1800,nRow3+2380,1800)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFontB8)
oPrint:Say  (nRow3+2015,400 ,"PAGAVEL NA REDE BANCARIA ATÉ O VENCIMENTO",oFontB10)

           
oPrint:Say  (nRow3+2000,1810,"Vencimento",oFontB8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFontB11c)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFontB8)
oPrint:Say  (nRow3+2140,100 ,Alltrim(aDadosEmp[1])+"-"+Alltrim(aDadosEmp[6]),oFontB8) //Nome + CNPJ
oPrint:Say  (nRow3+2190,100 ,Alltrim(aDadosEmp[2])+" - "+Alltrim(aDadosEmp[3])+" "+Alltrim(aDadosEmp[5])	,oFontB8) //Endereço + Estado + CEP

oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFontB8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFontB11c)

oPrint:Say (nRow3+2230,100 ,"Data do Documento"                              ,oFontB8)
oPrint:Say (nRow3+2270,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFontB10)


oPrint:Say  (nRow3+2230,505 ,"Nro.Documento"                                  ,oFontB8)
oPrint:Say  (nRow3+2270,505 ,aDadosTit[7]+aDadosTit[1]						,oFontB10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2230,1005,"Espécie Doc."                                   ,oFontB8)
oPrint:Say  (nRow3+2270,1050,"DMI"										,oFontB10) //Tipo do Titulo

oPrint:Say  (nRow3+2230,1305,"Aceite"                                         ,oFontB8)
oPrint:Say  (nRow3+2270,1400,"N"                                             ,oFontB10)

oPrint:Say  (nRow3+2230,1485,"Data do Processamento"                          ,oFontB8)
oPrint:Say  (nRow3+2270,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFontB10) // Data impressao

oPrint:Say  (nRow3+2230,1810,"Nosso Número"                                   ,oFontB8)

nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2270,nCol,aDadosTit[6],oFontB11c)


oPrint:Say  (nRow3+2310,100 ,"Uso do Banco"                  ,oFontB8)
oPrint:Say  (nRow3+2340,155 ,"CLIENTE"                     	,oFontB10)                                 

oPrint:Say  (nRow3+2310,505 ,"Carteira"                      ,oFontB8)
oPrint:Say  (nRow3+2340,555 ,aDadosBanco[6]                  ,oFontB10)

oPrint:Say  (nRow3+2310,755 ,"Espécie"                       ,oFontB8)
oPrint:Say  (nRow3+2340,805 ,"R$"                            ,oFontB10)

oPrint:Say  (nRow3+2310,1005,"Quantidade"                    ,oFontB8)
oPrint:Say  (nRow3+2310,1485,"Valor"                         ,oFontB8)

oPrint:Say  (nRow3+2310,1810,"Valor do Documento"            ,oFontB8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2340,nCol,cString,oFontB11c)

oPrint:Say  (nRow3+2380,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFontB8)

oPrint:Say  (nRow3+2480,100 ,aBolText[1] ,oFontB10)
oPrint:Say  (nRow3+2530,100 ,aBolText[2] ,oFontB10)
oPrint:Say  (nRow3+2580,100 ,aBolText[3] ,oFontB10)

oPrint:Say  (nRow3+2380,1810,"(-)Desconto/Abatimento"                         ,oFontB8)
oPrint:Say  (nRow3+2450,1810,"(-)Outras Deduções"                             ,oFontB8)
oPrint:Say  (nRow3+2520,1810,"(+)Mora/Multa"                                  ,oFontB8)
oPrint:Say  (nRow3+2590,1810,"(+)Outros Acréscimos"                           ,oFontB8)
oPrint:Say  (nRow3+2660,1810,"(=)Valor Cobrado"                               ,oFontB8)

oPrint:Say  (nRow3+2730,100 ,"Sacado"                                         ,oFontB8)
oPrint:Say  (nRow3+2730,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFontB10)
oPrint:Say  (nRow3+2804,400 ,aDatSacado[3]                                    ,oFontB10)
oPrint:Say  (nRow3+2854,400 ,+TRANSFORM(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFontB10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2737,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFontB10) // CGC
Else
	oPrint:Say  (nRow3+2737,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFontB10) 	// CPF
EndIf

oPrint:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFontB10)

oPrint:Say  (nRow3+2870,100 ,"Sacador/Avalista"                               ,oFontB8)
oPrint:Say  (nRow3+2895,1500,"Ficha de Compensação"                        ,oFontB8)

oPrint:Line (nRow3+2000,1800,nRow3+2700,1800 )
oPrint:Line (nRow3+2380,1800,nRow3+2380,2250 )
oPrint:Line (nRow3+2450,1800,nRow3+2450,2250 )
oPrint:Line (nRow3+2520,1800,nRow3+2520,2250 )
oPrint:Line (nRow3+2590,1800,nRow3+2590,2250 )
oPrint:Line (nRow3+2660,1800,nRow3+2660,2250 )
oPrint:Line (nRow3+2725,100 ,nRow3+2725,2250 )
oPrint:Line (nRow3+2900,100,nRow3+2900,2250  )

MSBAR("INT25",27.5,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.024,1.5,Nil,Nil,"A",.F.) ///19

DbSelectArea("SE1")
RecLock("SE1",.f.)
   SE1->E1_NUMBCO 	:=	aDadosTit[6] //aCB_RN_NN[3]  // Nosso número (Ver fórmula para calculo)
   SE1->E1_PORTADO := "745"
   SE1->E1_HIST := "BOLETO CITIBANK GERADO"
MsUnlock()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
						cBanco		,cAgencia	,cConta		,cDacCC	,;
						cNroDoc		,nValor		,cCart		,cMoeda	)


Local cNosso		:= ""
Local cDigNosso	:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra	:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

cAgencia:=STRZERO(Val(cAgencia),4)
cCart := "18"		
cNosso := ""
       
cNosso:= cNroDoc
nNum  := cNroDoc

If nValor > 0
	cFatorValor  := fator1347()+Strzero(nValor*100,10)
Else
	cFatorValor  := fator1347()+strzero(SQLSE1->E1_VALOR*100,10)
EndIf
                          

cConvenio := ALLTRIM(SA6->A6_NUMBCO) 

DO CASE 
  CASE LEN(ALLTRIM(cConvenio)) == 6
     cCampoL := cConvenio+alltrim(NNUM)+"21"
  CASE LEN(ALLTRIM(cConvenio)) == 7
     cCampoL := "000000"+alltrim(NNUM)+cCart   
ENDCASE
  
//cLivre := cBanco+cMoeda+cFatorValor+"3"+"100"+"049229"+"01"+"1"+nNum
cLivre := cBanco+cMoeda+cFatorValor+"3"+"100"+SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10)+nNum 

// campo do codigo de barra
cDigBarra := CALCDp(alltrim(cLivre),"2" )

cBarra    := Substr(cLivre,1,4)+cDigBarra+cFatorValor+Substr(cLivre,19,25)
//MSGALERT(cBarra,"Codigo de Barras")

// composicao da linha digitavel
cParte1  := cBanco+cMoeda+"3"+"100"+"0"
cDig1    := DIGIT0347( cParte1,1 )
//cParte2  := "49229"+"01"+"1"+SUBSTR(nNum,1,2 ) 
cParte2  := SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),3,10)+SUBSTR(nNum,1,2) 
cDig2    := DIGIT0347( cParte2,2 )
cParte3  := SUBSTR(nNum,3,10 )
cDig3    := DIGIT0347( cParte3,2 )
cParte4  := cDigBarra 
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+" "+;                                              
			cParte5
//MSGALERT(cDigital,"Linha Digitavel")

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)		

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCdiE  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do Citibank             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALCdiE(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT0347  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Citibank          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIGIT0347(cVariavel,nOp)

//Local Auxi := 0, sumdig := 0Local _aArea     := GetArea()
local aMultiplic := {}  // Resultado das Multiplicacoes de cada algarismo
local _cRet      := " "
local aBaseNum   := {}
local cDigVer    := 0 
local nB         := 0  
local nC         := 0 
local nSum       := 0 
local _cNossoNum := ""
local _cCalcdig  := ""
cbase  := cVariavel 
IF nOp == 1 
  aBaseNum   := { 2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
ELSE
  aBaseNum   := { 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
ENDIF

/*lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))
nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0         
	
EndIf 
*/ 
For nB := 1 To Len(cbase)
		
		nMultiplic := Val(Subs(cbase,nB,1) ) * aBaseNum[nB]
		Aadd(aMultiplic,StrZero(nMultiplic,2) )
		
next nB
For nC := 1 To Len(aMultiplic)
		nAlgarism1 := Val(Subs(aMultiplic[nC],1,1) )
		nAlgarism2 := Val(Subs(aMultiplic[nC],2,1) )
		nSum       := nSum + nAlgarism1 + nAlgarism2
Next nC

cDigVer := 10 - Mod(nSum,10)

IF cDigVer == 10 
   cDigVer := 0 
Endif


Return(str(cDigVer,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR1  de vencimento para linha digitavel.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fator1347()
If Len(ALLTRIM(SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4))) = 4
	cData := SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
Else
	cData := "20"+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)

Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCDp   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALCDp(cVariavel,_cRegra)
Local Auxi := 0, sumdig := 0
Local aBasecalc := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local aBaseNNum := {4,3,2,9,8,7,6,5,4,3,2}
Local nMult     := 0
Local nD        := 0      
Local nE        := 0      
Local aMult     := {}
Local nDigbar   := 0
Local nSoma     := 0
cbase  := cVariavel

/*lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf
  */
  
If _cRegra == "1"  
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBaseNNum[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Else
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBasecalc[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Endif
	
nSoma := 0 
nAlgarism1 := 0 
nAlgarism2 := 0 
For nE := 1 To Len(aMult)                         
    	nAlgarism1 := Val(aMult[nE])
		nSoma      := nSoma + nAlgarism1 // + nAlgarism2
Next nC
nDigbar := 11 - Mod(nSoma,11)

IF nDigbar == 0  .or. nDigbar == 1 .or. nDigbar == 10 .or. nDigbar == 11   
   nDigbar := 1 
Endif
  
  
Return(str(nDigbar,1,0))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |AtuX1     ºAutor  ³Andre Minelli       º Data ³  02/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para atualizacao do arquivo de perguntas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NFSERV                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuX1()
                                                                                        	
U_PUTSX1(cPerg, "01", "Da Emissao",        "Da Emissao",        	"Da Emissao",        		"mv_ch01","D",10,0,1,"G","","",   	"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Ate Emissao",       "Ate Emissao",       	"Ate Emissao",       		"mv_ch02","D",10,0,1,"G","","",	"","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Do Cliente",        "Do Cliente",        	"Do Cliente",        		"mv_ch03","C",9,0,1, "G","","SA1",	"","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Ate Cliente",       "Ate Cliente",       	"Ate Cliente",       		"mv_ch04","C",9,0,1, "G","","SA1",	"","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Da Loja",           "Da Loja",           	"Da Loja",    	   	 		"mv_ch05","C",9,0,1, "G","","",	"","","mv_par05","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Ate Loja",          "Ate Loja",           	"Ate Loja",          		"mv_ch06","C",9,0,1, "G","","",	"","","mv_par06","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Do RPS",            "Do RPS",             	"Do RPS",            		"mv_ch07","C",12,0,1,"G","","",   	"","","mv_par07","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "08", "Ate RPS",           "Ate RPS",            	"Ate RPS",           		"mv_ch08","C",12,0,1,"G","","",   	"","","mv_par08","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "09", "Num. Copias",       "Num. Copias",       	"Num. Copias",       		"mv_ch09","N",1, 0,1,"G","","",   	"","","mv_par09","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "10", "Imprime Cancelados ?","Imprime Cancelados ?",	"Imprime Cancelados ?",	"mv_ch10","N",1, 0,1,"C","","",   	"","","mv_par10","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "11", "Do Vecnto",         "Do Vecnto",         	"Do Vecnto",         		"mv_ch11","D",10,0,1,"G","","",   	"","","mv_par11","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "12", "Ate Vecnto",        "Ate Vecnto",        	"Ate Vecnto",        		"mv_ch12","D",10,0,1,"G","","",   	"","","mv_par12","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "13", "Serie RPS",         "Serie RPS",        	"Serie RPS",        		"mv_ch13","C",3 ,0,1,"G","","",   	"","","mv_par13","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "14", "Instrucao 1",       "Instrucao 1",	        "Instrucao 1",              "mv_ch14","C",60,0,1,"G","","",   "","" ,"mv_par14","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "15", "Instrucao 2",       "Instrucao 2",       	"Instrucao 2",       		"mv_ch15","C",60,0,1,"G","","",   "","" ,"mv_par15","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "16", "Instrucao 3",       "Instrucao 3",       	"Instrucao 3",       		"mv_ch16","C",60,0,1,"G","","",   "","" ,"mv_par16","","","","","","","","","","","","","","","","",{},{},{},"")

Return
