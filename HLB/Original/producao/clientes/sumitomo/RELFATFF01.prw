#include "rwmake.ch"
#include "protheus.ch"        
/*
Funcao      : RELFATFF01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão relatório de Faturamento
Autor     	: Adriane Sayuri Kamiya 	
Data     	: 30/05/2010
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.

Revisão     : Jean Victor Rocha
Data/Hora   : 19/04/2012
Objetivo    : Reformulação do fonte.
			  Alterado a forma de impressão do relatorio (TREPORT).
			  Adequado as colunas impressas.
			  Revisão do fluxo do relatorio.
			  Incluido Query do SD1(NF de devolução).
			  Alterado forma de execução de query.
			  Alterações diversas solicitadas pela Sumitomo.
*/
*----------------------------*
User Function RELFATFF01()      
*----------------------------*      
Private cTitRpt    := "Relatorio de Faturamento - Sumitomo"
Private cNome      := ""
Private oReport
Private aRetCrw    := {}

cPerg	:= "RELFATFF01"

If !(cEmpAnt $ "FF|99")
   MsgAlert("Rotina não disponivel para essa empresa","Atenção")
   Return .F.
EndIf

pergunte(cPerg,.T.)

dDataIni  := mv_par01
dDataFim  := mv_par02  
cDocDe    := mv_par03
cDocAte   := mv_par04
cSerieDe  := mv_par05
cSerieAte := mv_par06 
nFilial   := mv_par07  
cCCusto   := mv_par08
nExcel    := mv_par09

Processa({|| CriaWork()})
Processa({|| MontaQry1()}) //Busca informações SD2.
Processa({|| MontaQry2()}) //Busca informações SD1, devolução.

DET->(DbGoTop())
If DET->(Eof())
  MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
  DET->(DbCloseArea())
  Return .F.
EndIf

If nExcel == 1
	GeraXLS()//exporta para excel.
Else
	oReport := ReportDef()
	oReport:PrintDialog()
	CrwCloseFile(aRetCrw,.T.)
EndIf

Return .T.

*------------------------*
Static Function CriaWork()
*------------------------*
ProcRegua(2)
IncProc("Criando arquivos temporarios...")

If Select("WORK") > 0
   DET->(DbCloseArea())
EndIf  

aCampos := {   {"DIVISAO"   ,"C",25,0 },;
               {"CODCLI"    ,"C",06,0 },;
               {"LOJACLI"   ,"C",02,0 },;
               {"NF"        ,"C",09,0 },;
               {"SERIE"     ,"C",03,0 },;
               {"EMISSAO"   ,"C",10,0 },;
               {"MES"       ,"C",02,0 },;
               {"PEDIDO"    ,"C",06,0 },;               
               {"NOMECLI"   ,"C",50,0 },;
               {"SUMITOMO"  ,"C",10,2 },;               
               {"UF"        ,"C",02,0 },;
               {"CIDADE"    ,"C",30,0 },;
               {"TES"       ,"C",03,0 },;
               {"CFOP"      ,"C",05,0 },;
               {"NATUREZA"  ,"C",20,2 },;
               {"PRODUTO"   ,"C",15,0 },;
               {"NOMEPROD"  ,"C",30,0 },;
               {"QUANTIDADE","N",12,3 },;
               {"UNIDADE"   ,"C",02,0 },;
               {"VLUNITUS"  ,"N",14,6 },;
               {"VLTOTALUS" ,"N",14,2 },;
               {"TXPTAX"    ,"N",11,4 },;
               {"VLUNIT"    ,"N",14,6 },;
               {"VLLIQUI"   ,"N",14,2 },;               
               {"VLRICMS"   ,"N",14,2 },;
               {"VLTOTAL"   ,"N",14,2 },;
               {"PIS"       ,"N",14,2 },;
               {"COFINS"    ,"N",14,2 },;
               {"TRANSPORT" ,"C",40,2 },;
               {"TPFRETE"   ,"C",03,0 },;
               {"VLFRETE"   ,"N",14,2 },;
               {"CONDPAG"   ,"C",15,0 },;
               {"CONDPAG2"  ,"C",15,0 },;
               {"NPARCELAS" ,"N", 1,0 },;
               {"VENCTOA"   ,"C",10,0 },;
               {"VALORA"    ,"N",17,2 },;//RRP - 06/10/2014 - Alterado para o tamanho da mascara do E1_VALOR.
               {"VENCTOB"   ,"C",10,0 },;
               {"VALORB"    ,"N",14,6 },;
               {"VENCTOC"   ,"C",10,0 },;
               {"VALORC"    ,"N",14,6 },;
               {"VENCTOD"   ,"C",10,0 },;
               {"VALORD"    ,"N",14,6 },;
               {"VENCTOE"   ,"C",10,0 },;
               {"VALORE"    ,"N",14,6 },;
               {"VENCTOF"   ,"C",10,0 },;
               {"VALORF"    ,"N",14,6 },;
               {"ARMAZEM"   ,"C",02,0 },;
               {"VENDEDOR"  ,"C",40,0 },;
			   {"TIPO"      ,"C",01,0 },;
               {"CUSTO"     ,"N",14,2 }}

               //{"PTAXVENCTA","N",11,4 },;
               //{"PTAXVENCTB","N",11,4 },;
               //{"PTAXVENCTC","N",11,4 },;
               //{"PTAXVENCTD","N",11,4 },;
               //{"PTAXVENCTE","N",11,4 },;
               //{"PTAXVENCTF","N",11,4 },;


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,"DET",.F.,.F.)

DbSelectArea("DET")
cIndex:=CriaTrab(Nil,.F.)
IndRegua("DET",cIndex,"EMISSAO+NF+SERIE+PRODUTO",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

IncProc("Criação de arquivo temporario finalizado!")

Return .T. 

*-------------------------*
Static Function GravaWork()
*-------------------------*
Local cDoc:= ""

ProcRegua(QRB->(RECCOUNT()))

DbSelectArea("SE4");SE4->(DbSetOrder(1))
DbSelectArea("SE1");SE1->(DbSetOrder(2))
DbSelectArea("CTT");CTT->(DbSetOrder(1))
DbSelectArea("SA4");SA4->(DbSetOrder(1))
DbSelectArea("SA3");SA3->(DbSetOrder(1))
DbSelectArea("SB2");SB2->(DbSetOrder(1))

While QRB->(!Eof())
   RecLock("DET",.T.)
	cDoc:= ALLTRIM(QRB->D2_DOC+QRB->D2_SERIE+QRB->D2_COD)
	While QRB->(!Eof()) .and. ALLTRIM(QRB->D2_DOC+QRB->D2_SERIE+QRB->D2_COD) ==cDoc
	   If !EMPTY(QRB->D2_CCUSTO)
	      If CTT->(DBSEEK(XFILIAL("CTT")+QRB->D2_CCUSTO))
	         DET->DIVISAO    := Alltrim(CTT->CTT_DESC01)
	      EndIf
	   Else
	      DET->DIVISAO    := ""
	   EndIf
	   DET->CODCLI     := Alltrim(QRB->D2_CLIENTE)
	   DET->LOJACLI    := Alltrim(QRB->D2_LOJA)
	   DET->NOMECLI    := QRB->A1_NOME
	   DET->TES        := QRB->D2_TES
	   DET->CFOP       := QRB->D2_CF
	   DET->PEDIDO     := QRB->D2_PEDIDO
	   DET->TIPO       := QRB->D2_TIPO
	   DET->SERIE      := QRB->D2_SERIE
	   DET->NF         := QRB->D2_DOC
	   DET->EMISSAO    := Alltrim(DTOC(QRB->D2_EMISSAO))
	   DET->MES        := Alltrim(STR(MONTH(QRB->D2_EMISSAO)))
	   DET->PRODUTO    := QRB->D2_COD
	   DET->NOMEPROD   := QRB->B1_DESC
	   DET->QUANTIDADE += QRB->D2_QUANT
	   DET->UNIDADE    := QRB->D2_UM
	   DET->VLUNIT     := QRB->D2_PRUNIT
	   DET->VLTOTAL    += (QRB->D2_PRUNIT * QRB->D2_QUANT)
	   DET->ARMAZEM    := QRB->D2_LOCAL
	
	   If SM2->(DbSeek(QRB->D2_EMISSAO))
			DET->VLUNITUS   += QRB->D2_PRUNIT / SM2->M2_MOEDA2
			DET->VLTOTALUS  += (QRB->D2_PRUNIT * QRB->D2_QUANT )/SM2->M2_MOEDA2
			If QRB->C5_MOEDA <> 2
				DET->TXPTAX:= SM2->M2_MOEDA2
			EndIf
	   EndIf
	   If QRB->C5_MOEDA == 2
	      DET->TXPTAX     := QRB->C5_TXMOEDA
	   EndIf
	   DET->VLRICMS    += QRB->D2_VALICM
	   DET->PIS        += QRB->D2_VALIMP6
	   DET->COFINS     += QRB->D2_VALIMP5
	   DET->NATUREZA   := QRB->F4_TEXTO
	   DET->VLLIQUI    += ((QRB->D2_PRUNIT * QRB->D2_QUANT ) - QRB->D2_VALICM - QRB->D2_VALIMP5 - QRB->D2_VALIMP6)
	   If QRB->D2_CUSTO1 = 0
	      DET->CUSTO   := QRB->D2_P_CUSTO
	   Else
	      DET->CUSTO   := QRB->D2_CUSTO1
	   EndIf
	   DET->CIDADE     := QRB->A1_MUN
	   DET->UF         := QRB->A1_EST
	
	   If QRB->D2_FILIAL $ '03'
	      DET->SUMITOMO   := "FILIAL"
	   Else
	      DET->SUMITOMO   := "MATRIZ"
	   EndIf
	
	   If SE4->(DbSeek(xFilial("SE4")+QRB->C5_CONDPAG))
	      DET->CONDPAG    := SE4->E4_DESCRI
	      DET->CONDPAG2   := SE4->E4_COND
	   EndIf
	   DET->NPARCELAS  := 0
	   If SE1->(DbSeek(xFilial("SE1")+QRB->D2_CLIENTE+QRB->D2_LOJA+QRB->F2_PREFIXO+QRB->F2_DUPL)) 
	      Do While !SE1->(EOF()) .AND.	SE1->E1_CLIENTE+SE1->E1_LOJA == QRB->D2_CLIENTE+QRB->D2_LOJA .AND.;
	      								SE1->E1_NUM == QRB->F2_DUPL .AND. SE1->E1_PREFIXO == QRB->F2_PREFIXO
	         If SE1->E1_TIPO = 'NF'       
	            /*If SM2->(DbSeek(SE1->E1_VENCREA))
	               DET->PTAXVENCTA := SM2->M2_MOEDA2
	            EndIf    */
	            If EMPTY(SE1->E1_PARCELA)                        
	               DET->NPARCELAS  += 1
	               DET->VENCTOA := Alltrim(DTOC(SE1->E1_VENCREA))
	               DET->VALORA := SE1->E1_VALOR
	            Else
					/*nTx := 0
					If SM2->(DbSeek(SE1->E1_VENCREA))
	            		nTx := SM2->M2_MOEDA2
					EndIf*/
	               Do Case
	                  Case SE1->E1_PARCELA $ 'A'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOA    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORA := SE1->E1_VALOR
	                     //DET->PTAXVENCTA := nTx
	                  Case SE1->E1_PARCELA $ 'B'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOB    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORB := SE1->E1_VALOR
	                     //DET->PTAXVENCTB := nTx
	                  Case SE1->E1_PARCELA $ 'C'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOC    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORC := SE1->E1_VALOR
	                     //DET->PTAXVENCTC := nTx
	                  Case SE1->E1_PARCELA $ 'D'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOD    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORD := SE1->E1_VALOR
	                     //DET->PTAXVENCTD := nTx
	                  Case SE1->E1_PARCELA $ 'E'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOE    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORE := SE1->E1_VALOR
	                     //DET->PTAXVENCTE := nTx
	                  Case SE1->E1_PARCELA $ 'F'
	                     DET->NPARCELAS  += 1
	                     DET->VENCTOF    := Alltrim(DTOC(SE1->E1_VENCREA))
	                     DET->VALORF := SE1->E1_VALOR
	                     //DET->PTAXVENCTF := nTx
	               EndCase
	            EndIf                                
	         EndIf
	         SE1->(DbSkip())
	      EndDo   
	   EndIf 
	      
	   If !EMPTY(QRB->C5_TRANSP)
	      If SA4->(DBSEEK(XFILIAL("SA4")+QRB->C5_TRANSP))
	         DET->TRANSPORT  := Alltrim(SA4->A4_NOME)
	      EndIf
	   Else
	      DET->TRANSPORT  := ""
	   EndIf
	   
	   DET->VLFRETE    := QRB->C5_FRETE
	
	   If QRB->C5_TPFRETE $ 'C'
	      DET->TPFRETE    :=  "CIF"
	   ElseIf QRB->C5_TPFRETE $ 'F'
	      DET->TPFRETE    :=  "FOB"
	   Else 
	      DET->TPFRETE    :=  "   "   
	   EndIf
	
	   If QRB->(FieldPOs("C5_VEND1")) > 0 .and. !EMPTY(QRB->C5_VEND1)
	      If SA3->(DBSEEK(XFILIAL("SA3")+QRB->C5_VEND1))
	         DET->VENDEDOR   := Alltrim(SA3->A3_NOME)
	      EndIf   
	   Else
	      DET->VENDEDOR   := ""
	   Endif
    QRB->(DbSkip())
	EndDo

   DET->(MsUnLock())
   IncProc("Gravando dados...")
EndDo

Return .T.

****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"DET"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("FFFAT001", cTitRpt ,""         , {|oReport| ReportPrint(oReport)}, cTitRpt)

//Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait  := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"DIVISAO"	, "DET", "Divisao" 			, /*Picture*/                , 15  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CODCLI"	, "DET", "Cli./Forn." 		, /*Picture*/                , 06  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"LOJACLI"	, "DET", "Lj" 		  		, /*Picture*/                , 02  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"NOMECLI"	, "DET", "Nome Cli/Forn." 	, /*Picture*/                , 15  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TES"		, "DET", "TES" 			    , /*Picture*/                , 03  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CFOP"		, "DET", "CFOP" 			, /*Picture*/                , 05  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"PEDIDO"	, "DET", "Pedido" 			, /*Picture*/                , 06  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TIPO"		, "DET", "Tipo"				, /*Picture*/                , 02  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"NF"		, "DET", "NF" 				, /*Picture*/                , 10  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"SERIE"	, "DET", "Série" 			, /*Picture*/                , 03  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EMISSAO"	, "DET", "Emissao" 			, /*Picture*/                , 10  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TXPTAX"	, "DET", "Tx.Ptax" 			, /*Picture*/                , 08  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"PRODUTO"	, "DET", "Codigo" 			, /*Picture*/                , 15  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"NOMEPROD"	, "DET", "Produto" 			, /*Picture*/                , 15  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"UNIDADE"	, "DET", "UM" 				, /*Picture*/                , 02  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"QUANTIDADE","DET", "Qtde" 			, FFSX3("D2_QUANT"   , "PIC"), 15  , /*lPixel*/, /*{|| code-block de impressao }*/)
//TRCell():New(oSecao1,"VLUNIT"	, "DET", "Vlr.Unit" 		, FFSX3("D2_PRUNIT"  , "PIC"), 18  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VLTOTAL"	, "DET", "Vlr.Total" 		, FFSX3("D2_PRUNIT"  , "PIC"), 18  , /*lPixel*/, /*{|| code-block de impressao }*/)

AEVAL(oSecao1:aCell, {|X| X:SetColSpace(0) })

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Total:")
//oTotal:= TRFunction():New(oSecao1:Cell("QUANTIDADE"),NIL,"SUM",/*oBreak*/,"","@E 999,999,999,999.99",/*{|| code-block de impressao }*/,.T.,.F.)
//oTotal:= TRFunction():New(oSecao1:Cell("VLUNIT") 	,NIL,"SUM",/*oBreak*/,"","@E 999,999,999,999.99",/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("VLTOTAL")	,NIL,"SUM",/*oBreak*/,"","@E 999,999,999,999.99",/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:SetTotalInLine(.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Seção 1")

oReport:SetMeter(DET->(RecCount()))
DET->(dbGoTop())
  
//Inicio da impressão da seção 1.
oReport:Section("Seção 1"):Init()

//Laço principal
Do While DET->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Seção 1"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   DET->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Seção 1"):Finish()

Return .T.

*-----------------------*
Static Function GeraXLS()
*-----------------------*
Local nTOTQtde	:=0
Local nTotal	:=0
Local nTotalUS	:=0
Local nVLRICMS	:=0
Local nPIS 		:=0
Local nCOFINS	:=0
Local nVLLIQUI	:=0
Local nVLFRETE	:=0

//Appendar totalizadores para exibição no excel.
DET->(DbGoTop())
While DET->(!EOF())
	nTotal		+= DET->VLTOTAL
	nTotalUS	+= DET->VLTOTALUS
	nVLRICMS	+= DET->VLRICMS
	nPIS   		+= DET->PIS
	nCOFINS		+= DET->COFINS
	nVLLIQUI	+= DET->VLLIQUI
	nVLFRETE	+= DET->VLFRETE
	DET->(DbSkip())
EndDo

DET->(DbAppend());DET->(MsUnLock())//gera 1 registro em branco. estetico.
DET->(DbAppend())
DET->DIVISAO	:= "TOTAIS"
DET->VLTOTAL	:= nTotal
DET->VLTOTALUS	:= nTotalUS         
DET->VLRICMS	:= nVLRICMS
DET->PIS		:= nPIS   
DET->COFINS		:= nCOFINS
DET->VLLIQUI	:= nVLLIQUI
DET->VLFRETE	:= nVLFRETE
DET->(MsUnLock())

//Geração do XLS.
DbSelectArea("DET")                   
DbCloseArea()

cArqOrig  := "\SYSTEM\"+cNome+".DBF"
cPath     := AllTrim(GetTempPath())                                                   
CpyS2T(cArqOrig, cPath, .T.)
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
	oExcelApp:SetVisible(.T.)   
Else 
	Alert("Excel não instalado") 
EndIf

Erase &cNome+".DBF"

Return .T.

*------------------------------------*
Static Function FFSX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
	EndCase
EndIf
RestOrd(aOrd)
Return xRet

*-------------------------*  
Static Function MontaQry1()
*-------------------------*                                                                  
local aStruSD2:= SD2->(DbStruct())      
Local cWhere := "%"

If !empty(dDataIni) .Or. !empty(dDataFim)
	cWhere += " SD2.D2_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
	cWhere += " SD2.D2_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
EndIf
If !empty(cDocDe) .Or. !empty(cDocAte)
	cWhere += " SD2.D2_DOC >= '"+Alltrim(cDocDe) +"' AND "
	cWhere += " SD2.D2_DOC <= '"+Alltrim(cDocAte)+"' AND "
EndIf
If !empty(cSerieDe) .Or. !empty(cSerieAte)
	cWhere += " SD2.D2_SERIE >= '"+Alltrim(cSerieDe) +"' AND "
	cWhere += " SD2.D2_SERIE <= '"+Alltrim(cSerieAte)+"' AND "
EndIf
If nFilial < 3
	If nFilial = 1
		cWhere+=" SD2.D2_FILIAL <>'03' AND "
	Else                                  
		cWhere+=" SD2.D2_FILIAL = '03' AND "
	EndIf
EndIf
If !EMPTY(cCCusto)
	cWhere+=" SD2.D2_CCUSTO ='"+Alltrim(cCCusto)+"' AND "
EndIf

cWhere += "%"

BeginSQL alias 'QRB'
	SELECT	SD2.D2_FILIAL,SD2.D2_TIPO,SD2.D2_DOC,SD2.D2_SERIE,  SD2.D2_EMISSAO, SD2.D2_PEDIDO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_TES,
			SD2.D2_COD,SD2.D2_QUANT,SD2.D2_P_CUSTO,SD2.D2_UM, SD2.D2_PRUNIT, SD2.D2_TOTAL, SD2.D2_VALICM, SD2.D2_VALIMP5,
			SD2.D2_VALIMP6,SD2.D2_CF, SD2.D2_VALFRE,SD2.D2_CCUSTO,SD2.D2_CUSTO1,SD2.D2_LOCAL,
			SC5.C5_TRANSP,SC5.C5_CONDPAG, SC5.C5_VEND1, SC5.C5_TXMOEDA, SC5.C5_MOEDA, SC5.C5_TPFRETE,SC5.C5_FRETE,
			SB1.B1_DESC,
			SF4.F4_TEXTO,
			SA1.A1_NOME, SA1.A1_MUN, SA1.A1_EST,
			SF2.F2_DUPL, SF2.F2_PREFIXO
	
	FROM	%table:SD2% SD2,
			%table:SC5% SC5,
			%table:SB1% SB1,
			%table:SF4% SF4,
			%table:SA1% SA1,
			%table:SF2% SF2

	WHERE	SD2.%notDel% AND SC5.%notDel% AND SB1.%notDel% AND SF4.%notDel% AND SA1.%notDel% AND SF2.%notDel%
			AND SD2.D2_PEDIDO           = SC5.C5_NUM              AND SD2.D2_COD                 = SB1.B1_COD
			AND SD2.D2_TES              = SF4.F4_CODIGO           AND SD2.D2_CLIENTE+SD2.D2_LOJA = SA1.A1_COD+SA1.A1_LOJA
			AND SD2.D2_DOC+SD2.D2_SERIE = SF2.F2_DOC+SF2.F2_SERIE
			AND %exp:cWhere%
			SD2.D2_FILIAL               = SC5.C5_FILIAL

	ORDER by SD2.D2_EMISSAO+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_COD

EndSQL

For nI := 1 To Len(aStruSD2)
	If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
		TcSetField("QRB",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
	EndIf
Next nI

GravaWork()

QRB->(DbCloseArea())

Return .T.

/*
NFS devolução;
Utilizado nome dos campos os mesmos da Qry1 para utilizar a mesma função de gravação do DET.
*/
*-------------------------*  
Static Function MontaQry2()
*-------------------------* 
local aStruSD2:= SD2->(DbStruct())//Mantem como SD2 pois todos os campos foram renomeados para SD2 atraves da QUERY..      
Local cWhere  := "%"

If !empty(dDataIni) .Or. !empty(dDataFim)
	cWhere += " SD1.D1_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
	cWhere += " SD1.D1_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
EndIf
If !empty(cDocDe) .Or. !empty(cDocAte)
	cWhere += " SD1.D1_DOC >= '"+Alltrim(cDocDe)+ "' AND "
	cWhere += " SD1.D1_DOC <= '"+Alltrim(cDocAte)+"' AND "
EndIf
If !empty(cSerieDe) .Or. !empty(cSerieAte)
	cWhere += " SD1.D1_SERIE >= '"+Alltrim(cSerieDe)+ "' AND "
	cWhere += " SD1.D1_SERIE <= '"+Alltrim(cSerieAte)+"' AND "
EndIf
If nFilial < 3            
	If nFilial = 1
		cWhere+=" SD1.D1_FILIAL <>'03' AND "
	Else                                  
		cWhere+=" SD1.D1_FILIAL = '03' AND "
	EndIf
EndIf
If !EMPTY(cCCusto)
	cWhere+=" SD1.D1_CC ='"+Alltrim(cCCusto)+"' AND "
EndIf
             
cWhere += "%"

BeginSQL alias 'QRB'
	SELECT  SD1.D1_FILIAL as D2_FILIAL,SD1.D1_TIPO as D2_TIPO,SD1.D1_DOC as D2_DOC,SD1.D1_SERIE as D2_SERIE, SD1.D1_DTDIGIT as D2_EMISSAO,
			SD1.D1_PEDIDO as D2_PEDIDO,SD1.D1_FORNECE as D2_CLIENTE, SD1.D1_LOJA as D2_LOJA, SD1.D1_TES as D2_TES,SD1.D1_COD as D2_COD,
			(SD1.D1_QUANT*(-1)) as D2_QUANT,SD1.D1_CUSTO as D2_P_CUSTO,SD1.D1_UM as D2_UM, SD1.D1_VUNIT as D2_PRUNIT, SD1.D1_TOTAL as D2_TOTAL,
			(SD1.D1_VALICM*(-1)) as D2_VALICM, SD1.D1_VALIMP5 as D2_VALIMP5,SD1.D1_VALIMP6 as D2_VALIMP6,SD1.D1_CF as D2_CF, SD1.D1_VALFRE as D2_VALFRE,
			SD1.D1_CC as D2_CCUSTO,SD1.D1_CUSTO as D2_CUSTO1,SD1.D1_LOCAL as D2_LOCAL,
			SF1.F1_TRANSP as C5_TRANSP, SF1.F1_COND as C5_CONDPAG, SF1.F1_MOEDA as C5_MOEDA, SF1.F1_TPFRETE as C5_TPFRETE, SF1.F1_FRETE as C5_FRETE,
			SB1.B1_DESC,
			SF4.F4_TEXTO,
			SA1.A1_NOME, SA1.A1_MUN, SA1.A1_EST,
			SF1.F1_DUPL as F2_DUPL, SF1.F1_PREFIXO as F2_PREFIXO
	
	FROM 	%table:SD1% SD1,
			%table:SB1% SB1,
			%table:SF4% SF4,
			%table:SA1% SA1,
			%table:SF1% SF1,

	WHERE	SD1.%notDel% AND SB1.%notDel% AND SF4.%notDel% AND SA1.%notDel% AND SF1.%notDel%
			AND SD1.D1_COD					= SB1.B1_COD
			AND SD1.D1_TES					= SF4.F4_CODIGO
			AND SD1.D1_FORNECE+SD1.D1_LOJA	= SA1.A1_COD+SA1.A1_LOJA
			AND SD1.D1_DOC+SD1.D1_SERIE		= SF1.F1_DOC+SF1.F1_SERIE
			AND %exp:cWhere%
			SD1.D1_TIPO					= 'D'
	ORDER BY SD1.D1_EMISSAO+SD1.D1_DOC+SD1.D1_SERIE+SD1.D1_COD

EndSQL

For nI := 1 To Len(aStruSD2)
	If aStruSD2[nI][2] <> "C" .and.  FieldPos(aStruSD2[nI][1]) > 0
		TcSetField("QRB",aStruSD2[nI][1],aStruSD2[nI][2],aStruSD2[nI][3],aStruSD2[nI][4])
	EndIf
Next nI

GravaWork()

QRB->(DbCloseArea())

Return .T.