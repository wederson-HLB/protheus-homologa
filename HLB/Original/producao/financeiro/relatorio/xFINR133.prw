#Include "PROTHEUS.CH"
#INCLUDE "FINR133.CH"

Static _oFINR1331
Static _oFINR1332

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR133 ³ Autor ³Jose Lucas/Diego Rivero³ Data ³ 09.09.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razonete de Cliente                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR133(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizacoes paises ConeSul...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//

User Function xFINR133()       
Local oReport

/* GESTAO - inicio */
Private aSelFil	:= {}

/* GESTAO - fim */

//If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport	:= ReportDef()
	oReport:PrintDialog()
//Else
//	U_XFINR133R3()
//EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Paulo Augusto          ³ Data ³28/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport,oSection1,oSection2
Local cReport := "XFINR133"
Local cTitulo := OemToAnsi(STR0003) 
Local cDescri := OemToAnsi(STR0001)+" "+OemToAnsi(STR0002)
Local nTamEnd:= TamSx3("A1_END")[1]+ TamSx3("A1_MUN")[1] + TamSx3("A1_EST")[1]+TamSx3("A1_TEL")[1] + 22 
Local nTamSec1 :=TamSx3("A1_LOJA")[1]+TamSx3("A1_NREDUZ")[1]+nTamEnd+TamSx3("A1_VEND")[1]+TamSx3("A3_NOME")[1]
Local nTamSec2 :=FWSizeFilial()+TamSx3("E1_VENCREA")[1]+TamSx3("E1_TIPO")[1]+TamSx3("E1_PREFIXO")[1]+TamSx3("E1_NUM")[1]+5+TamSx3("E1_PARCELA")[1]+170
Pergunte( "FIR133" , .F. )

oReport := TReport():New( cReport, cTitulo, "FIR133" , { |oReport| ReportPrint( oReport, "TRB" ) }, cDescri )

oReport:SetUseGC(.F.)
/* GESTAO - fim */

oReport:SetLandScape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio Valores nas Moedas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport,STR0082 , {"TRB","SA1"},{STR0073,STR0074,STR0075},/*Campos do SX3*/,/*Campos do SIX*/)                      //"Cliente"

TRCell():New( oSection1, "A1_COD" 	,"SA1" ,/*X3Titulo*/  ,/*Picture*/,TamSx3("A1_COD")[1]+TamSx3("A1_LOJA")[1]+5,/*lPixel*/,{||TRB->CODIGO+"-"+TRB->LOJA})
TRCell():New( oSection1, "A1_NREDUZ","SA1" ,/*X3Titulo*/ ,/*Picture*/,TamSx3("A1_NREDUZ")[1]+5,/*lPixel*/,{||SA1->A1_NREDUZ})	
TRCell():New( oSection1, "A1_END"	,"SA1" ,/*X3Titulo*/ ,/*Picture*/,nTamEnd,/*lPixel*/,{||Alltrim(SA1->A1_END) + " - "  +Alltrim(SA1->A1_MUN) + "-"+ SA1->A1_EST +"  "+OemtoAnsi(STR0051) +SA1->A1_TEL})	
TRCell():New( oSection1, "A1_VEND"	,"SA1" ,/*X3Titulo*/  ,/*Picture*/,TamSx3("A1_VEND")[1]+5,/*lPixel*/,/*{SA1->A1_VEND}*/)
TRCell():New( oSection1, "A3_NOME"	,"SA3" ,/*X3Titulo*/  ,/*Picture*/,TamSx3("A3_NOME")[1]+nTamSec2-nTamSec1+17/*Tamanho*/,/*lPixel*/,/*{SA1->A1_VEND}*/)
//TRCell():New( oSection1, "NRINVOICE" ,""   , "Order Ref "/*X3Titulo()*/,"@!"/*Picture*/,30,/*lPixel*/,{||TRB->NRINVOICE })
 
oSection2 := TRSection():New( oSection1,STR0083 , {"TRB","SE1"} ) //"Titulos a receber"

TRCell():New( oSection2, "E1_FILORIG",""   , ,/*Picture*/,FWSizeFilial(),/*lPixel*/,{||TRB->FILORIG })
TRCell():New( oSection2, "E1_VENCREA","SE1", ,/*Picture*/,TamSx3("E1_VENCREA")[1],/*lPixel*/,)
TRCell():New( oSection2, "E1_TIPO" 	 ,"SE1", ,/*Picture*/,TamSx3("E1_TIPO")[1],/*lPixel*/,)	
TRCell():New( oSection2, "E1_PREFIXO","SE1", ,/*Picture*/,TamSx3("E1_PREFIXO")[1] ,/*lPixel*/,)	
TRCell():New( oSection2, "E1_NUM" 	 ,"SE1", ,/*Picture*/,TamSx3("E1_NUM")[1]+5,/*lPixel*/,)	
TRCell():New( oSection2, "E1_PARCELA","SE1", ,/*Picture*/,TamSx3("E1_PARCELA")[1] ,/*lPixel*/,)	
TRCell():New( oSection2, "VALOR00" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR00 })
TRCell():New( oSection2, "VALOR01" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR01 })
TRCell():New( oSection2, "VALOR02" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR02 })
TRCell():New( oSection2, "VALOR03" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR03 })
TRCell():New( oSection2, "VALOR04" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR04 })
TRCell():New( oSection2, "VALOR05" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR05 })
TRCell():New( oSection2, "VALOR06" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR06 })
TRCell():New( oSection2, "VALOR07" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR07 })
TRCell():New( oSection2, "VALOR08" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR08 })
TRCell():New( oSection2, "VALOR09" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR09 })
TRCell():New( oSection2, "VALOR10" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR10 })
TRCell():New( oSection2, "VALOR11" 	 ,""   , /*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB->VALOR11 })
TRCell():New( oSection2, "SALDOFIM"	 ,""   , STR0078/*X3Titulo()*/,PesqPict("SE1","E1_VALOR")/*Picture*/,13,/*lPixel*/,{||TRB-> SALDOFIM})
TRCell():New( oSection2, "TPSALDO" 	 ,""   , "Saldo('D/C')" /*X3Titulo()*/,/*Picture*/,1,/*lPixel*/,{||Iif(TRB->SALDOFIM<0,"C","D") })
 // SSS 07/07/2020 - Imprimir o numero da invoice / Nota 
TRCell():New( oSection2, "NRINVOICE" ,""   , "Order Ref "/*X3Titulo()*/,"@!"/*Picture*/,30,/*lPixel*/,{||TRB->NRINVOICE })   
TRCell():New( oSection2, "NRNOTA"    ,""   , "Nota Fiscal"/*X3Titulo()*/,"@!"/*Picture*/,30,/*lPixel*/,{||TRB->NRNOTA })      
 // SSS 07/07/2020 - Imprimir o numero da invoice / Nota  

oSection2:Cell("E1_FILORIG"):lHeaderSize	:=	.T.
oSection2:Cell("E1_VENCREA"):lHeaderSize	:=	.T.
oSection2:Cell("E1_TIPO" 	):lHeaderSize	:=	.T.
oSection2:Cell("E1_PREFIXO"):lHeaderSize	:=	.T.
oSection2:Cell("E1_NUM" 	):lHeaderSize	:=	.T.
oSection2:Cell("E1_PARCELA"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR00"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR01"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR02"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR03"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR04"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR05"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR06"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR07"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR08"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR09"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR10"):lHeaderSize	:=	.T.
oSection2:Cell("VALOR11"):lHeaderSize	:=	.T. 

Return oReport
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA133Imp ³ Autor ³ Lucas                 ³ Data ³ 11.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razonete de Cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA133Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local oBreak1 
Local nOrder	:=oReport:Section(1):GetOrder()
Local cIndice	:=	""
Local CbCont,CbTxt
Local nQuebra:=0,lImprAnt := .F.
Local cNome
Local aSaldos:={},j,dEmissao:=CTOD(""),dVencto:=CTOD("")
Local nRec,nPrim,cPrefixo,cNumero,cParcela,cNaturez,nValliq


Local nRegistro
Local lNoSkip:= .T.
Local lFlag  := .F.

Local aCampos:={},aTam:={}
Local aInd	 :={}
Local cCondE1:=cCondE5:=" "
Local cIndE1 :=cIndE5 :=cIndA1 :=" "
Local nRegAtu,lImprime
Local nRegSe1Atu := SE1->(RecNo())
Local nOrdSe1Atu := SE1->(IndexOrd())
Local lBaixa     := .F.
Local cChaveSe1
Local cRazSocial
Local cVendedor
Local cTelefone
Local	lPerg := .T., lChkDRef := .F.
Local 	I
Local cImpSldChq 
Local nTotCheque:=0
Local nAcumCh:=0
Local	nVlCli00	   
Local	nVlCli01	   
Local	nVlCli02	   
Local	nVlCli03	   
Local	nVlCli04	   
Local	nVlCli05	   
Local	nVlCli06	  
Local	nVlCli07	   
Local	nVlCli08	   
Local	nVlCli09	   
Local	nVlCli10	   
Local	nVlCli11	   
Local	nSalCliFim	
Private cClieIni  := mv_par01
Private cClieFim  := mv_par02
Private dFechaIni := mv_par03
Private dFechaFim := Min(mv_par04,dDataBase)
Private nInforme  := mv_par05
Private nMoeda    := mv_par10
Private lConverte := (mv_par11==1)
Private nDecs     := MsDecimais(nMoeda)
Private dData01
Private dData02
Private dData03
Private dData04
Private dData05
Private dData06
Private dData07
Private dData08
Private dData09
Private dData10
Private dData11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private dDataRef 	:= mv_par06
Private nPeriodos 	:= IIf(mv_par09==0,1,mv_par09)
Private nTipoPer	:= mv_par08
Private nPerAnt		:= IIf(mv_par07 > 9,9,mv_par07)
Private nImpSldChq	:= mv_par12

/* GESTAO - inicio */
If MV_PAR14 == 1
	If Empty(aSelFil)
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("FIR133",14,.F.,@aSelFil,"SE1",.F.)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE1")
			If Empty(aSelFil)
				Aadd(aSelFil,cFilAnt)
			Endif
		Endif
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif
/* GESTAO - fim */

cImpSldChq := IIF(nImpSldChq == 1,'nInforme == 1 .And. TRB->TIPO <> "CH "',"nInforme == 1")

If nTipoPer == 3 //Informado
	lOk	:=	.T.
	While lOk
		If Pergunte("FI133B",.T.)
			lPerg := .T.
			For I:=1 to 10
            cData1 := ("mv_par"+StrZero(I,2))
            cData2 := ("mv_par"+StrZero(I+1,2))
				If  &cData1. >= &cData2.
					lPerg := .F.
					I:=10
				Endif
			Next
			If lPerg
				For I:=1 to 11
               cData1 := ("mv_par"+StrZero(I,2))
					If &cData1. == dDataRef
						lChkDRef := .T.
						I := 11
					Endif
				Next
				If !lChkDRef
					MsgStop(OemToAnsi(STR0036)) //"Uma das datas deve coencidir com a Data de Referencia"
					Loop
				Endif
			Endif

			If lPerg
            dData01  := mv_par01
            dData02  := mv_par02
            dData03  := mv_par03
            dData04  := mv_par04
            dData05  := mv_par05
            dData06  := mv_par06
            dData07  := mv_par07
            dData08  := mv_par08
            dData09  := mv_par09
            dData10  := mv_par10
            dData11  := mv_par11
				//para restaurar os valores nas MV_PAR originais
				Pergunte("FIR133",.f.)
            lOk   := .F.
			Else
				MsgStop(OemToAnsi(STR0037)) //"Erro de sequencia nas datas"
			Endif
		Else
			Return .F.
		Endif
	Enddo
Else
	dData01 := Fr133Data(dDataRef,01,nPeriodos,nTipoPer,nPerAnt)
	dData02 := Fr133Data(dDataRef,02,nPeriodos,nTipoPer,nPerAnt)
	dData03 := Fr133Data(dDataRef,03,nPeriodos,nTipoPer,nPerAnt)
	dData04 := Fr133Data(dDataRef,04,nPeriodos,nTipoPer,nPerAnt)
	dData05 := Fr133Data(dDataRef,05,nPeriodos,nTipoPer,nPerAnt)
	dData06 := Fr133Data(dDataRef,06,nPeriodos,nTipoPer,nPerAnt)
	dData07 := Fr133Data(dDataRef,07,nPeriodos,nTipoPer,nPerAnt)
	dData08 := Fr133Data(dDataRef,08,nPeriodos,nTipoPer,nPerAnt)
	dData09 := Fr133Data(dDataRef,09,nPeriodos,nTipoPer,nPerAnt)
	dData10 := Fr133Data(dDataRef,10,nPeriodos,nTipoPer,nPerAnt)
	dData11 := Fr133Data(dDataRef,11,nPeriodos,nTipoPer,nPerAnt)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo := OemToAnsi(STR0004) //"DEUDAS VENCIDAS Y A VENCER DE CLIENTES"
Titulo += Space(1)
Titulo += OemToAnsi(STR0038)+DTOC(dFechaIni)+OemToAnsi(STR0039)+DTOC(dFechaFim)  //" De Emision: "###"  Hasta : "

AADD(aCampos,{"FILORIG" ,"C",FWSizeFilial(),0})
AADD(aCampos,{"CODIGO"  ,"C",TamSx3('E1_CLIENTE')[1],0})
AADD(aCampos,{"LOJA"    ,"C",TamSx3('E1_LOJA')[1],0})
AADD(aCampos,{"CLIENTE" ,"C",25,0})
AADD(aCampos,{"TELEFONE","C",15,0})
AADD(aCampos,{"VENDEDOR","C",06,0})
AADD(aCampos,{"NOMEVEND","C",25,0})
AADD(aCampos,{"TELEVEND","C",15,0})
AADD(aCampos,{"NATUREZA","C",10,0})
AADD(aCampos,{"PREFIXO" ,"C",TamSx3('E1_PREFIXO')[1],0})
AADD(aCampos,{"NUMERO"  ,"C",TamSx3('E1_NUM')[1],0})
AADD(aCampos,{"TIPO"    ,"C",TamSx3('E1_TIPO')[1],0})
AADD(aCampos,{"PARCELA" ,"C",TamSx3('E1_PARCELA')[1],0})
AADD(aCampos,{"BANCO"   ,"C",03,0})
AADD(aCampos,{"EMISSAO" ,"D",08,0})
AADD(aCampos,{"BAIXA"   ,"D",08,0})
AADD(aCampos,{"VENCTO"  ,"D",08,0})
AADD(aCampos,{"VALOR"   ,"N",18,nDecs})
AADD(aCampos,{"DEBITO"  ,"N",18,nDecs})
AADD(aCampos,{"CREDITO" ,"N",18,nDecs})
AADD(aCampos,{"SALDO"   ,"N",18,nDecs})
AADD(aCampos,{"SALTIT"  ,"N",18,nDecs})
AADD(aCampos,{"DC"      ,"C", 1,0})
AADD(aCampos,{"SIGLA"   ,"C",03,0})
AADD(aCampos,{"VALOR00" ,"N",18,nDecs})
AADD(aCampos,{"VALOR01" ,"N",18,nDecs})
AADD(aCampos,{"VALOR02" ,"N",18,nDecs})
AADD(aCampos,{"VALOR03" ,"N",18,nDecs})
AADD(aCampos,{"VALOR04" ,"N",18,nDecs})
AADD(aCampos,{"VALOR05" ,"N",18,nDecs})
AADD(aCampos,{"VALOR06" ,"N",18,nDecs})
AADD(aCampos,{"VALOR07" ,"N",18,nDecs})
AADD(aCampos,{"VALOR08" ,"N",18,nDecs})
AADD(aCampos,{"VALOR09" ,"N",18,nDecs})
AADD(aCampos,{"VALOR10" ,"N",18,nDecs})
AADD(aCampos,{"VALOR11" ,"N",18,nDecs})
AADD(aCampos,{"VALOR12" ,"N",18,nDecs})
AADD(aCampos,{"VALOR13" ,"N",18,nDecs})
AADD(aCampos,{"TOTCHEQ" ,"N",18,nDecs})
AADD(aCampos,{"SALDOFIM","N",18,nDecs}) 
// SSS 07/07/2020 - Adiciona campos no array acampos para imprimir o numero da invoice / Nota 
AADD(aCampos,{"NRINVOICE","C",30,0})
AADD(aCampos,{"NRNOTA","C",09,0})
// SSS 07/07/2020 - Adiciona campos no array acampos para imprimir o numero da invoice / Nota 
If _oFINR1331 <> Nil
	_oFINR1331:Delete()
	_oFINR1331 := Nil
Endif

_oFINR1331 := FWTemporaryTable():New( "TRB" )  
_oFINR1331:SetFields(aCampos) 	

If nOrder	==	1
	_oFINR1331:AddIndex("1", {"CODIGO","LOJA","VENCTO"})
ElseIf nOrder	==	2
	_oFINR1331:AddIndex("1", {"CODIGO","LOJA","PREFIXO","NUMERO","PARCELA","TIPO"})
Else
	_oFINR1331:AddIndex("1", {"CODIGO","LOJA","EMISSAO"})
Endif

//------------------
//Criação da tabela temporaria
//------------------
_oFINR1331:Create()				

Processa({|lEnd| GeraTra(oSection1:GetAdvplExp('SE1'),oSection1:GetAdvplExp('SA1'))},,OemToAnsi(STR0041))  //"Preparando Transit¢rio..."

R133fechas()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia rotina de impressao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()


oSection2:SetParentFilter({|cParam| TRB->CODIGO+TRB->LOJA == cParam },{||SA1->A1_COD+SA1->A1_LOJA}) 
If mv_par05 == 1
	oBreak1 := TRBreak():New( oSection2,{||.T.},STR0042)
	TRFunction():New(oSection2:Cell("VALOR00")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR01")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR02")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR03")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR04")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR05")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR06")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR07")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR08")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR09")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR10")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR11")	, ,"SUM", oBreak1, , , , .F. ,)
	TRFunction():New(oSection2:Cell("SALDOFIM")	, ,"SUM", oBreak1, , , , .F. ,)
Else
	//Totalizadores
	TRFunction():New(oSection2:Cell("VALOR00")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR01")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR02")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR03")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR04")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR05")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR06")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR07")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR08")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR09")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR10")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("VALOR11")	, ,"SUM", , , , , .F. ,)
	TRFunction():New(oSection2:Cell("SALDOFIM")	, ,"SUM", , , , , .F. ,)			
	
	//oculta
	oSection2:Cell("E1_VENCREA"):Hide()
	oSection2:Cell("E1_TIPO"):Hide()
	oSection2:Cell("E1_PREFIXO"):Hide()
	oSection2:Cell("E1_NUM"):Hide()
	oSection2:Cell("E1_PARCELA"):Hide()
	oSection2:Cell("E1_FILORIG"):Hide()
	
	//Define valores para as secoes
	oSection2:Cell("VALOR00"):SetBlock({|| nVlCli00 })
	oSection2:Cell("VALOR01"):SetBlock({|| nVlCli01 })
	oSection2:Cell("VALOR02"):SetBlock({|| nVlCli02 })
	oSection2:Cell("VALOR03"):SetBlock({|| nVlCli03 })
	oSection2:Cell("VALOR04"):SetBlock({|| nVlCli04 })
	oSection2:Cell("VALOR05"):SetBlock({|| nVlCli05 })
	oSection2:Cell("VALOR06"):SetBlock({|| nVlCli06 })
	oSection2:Cell("VALOR07"):SetBlock({|| nVlCli07 })
	oSection2:Cell("VALOR08"):SetBlock({|| nVlCli08 })
	oSection2:Cell("VALOR09"):SetBlock({|| nVlCli09 })
	oSection2:Cell("VALOR10"):SetBlock({|| nVlCli10 })
	oSection2:Cell("VALOR11"):SetBlock({|| nVlCli11 })
	oSection2:Cell("SALDOFIM"):SetBlock({|| nSalCliFim })	 
    
EndIf
oSection1:SetOrder(1) 
oSection1:SetTotalInLine(.T.)
oReport:SetTotalInLine(.F.)

Trposition():New(oSection1,"SA1",1,{|| xFilial('SA1',TRB->FILORIG)+TRB->CODIGO+TRB->LOJA})  
Trposition():New(oSection1,"SA3",1,{|| xFilial('SA3',TRB->FILORIG)+SA1->A1_VEND} )  

oSection2:SetLineCondition({||&cImpSldChq})

oSection2:Cell("VALOR00"):SetTitle(" " + CHR(13)+ CHR(10)+" " + CHR(13)+ CHR(10)+OemToAnsi(STR0079) + CHR(13)+ CHR(10)+  dToc(dData01) )
oSection2:Cell("VALOR01"):SetTitle(IIf(dDataRef=dData02,OemToAnsi(STR0084),Iif(dDataRef=dData01,STR0085," ")) + CHR(13)+ CHR(10)+dToc(dData01 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData02  ))
oSection2:Cell("VALOR02"):SetTitle(IIf(dDataRef=dData03,OemToAnsi(STR0084),Iif(dDataRef=dData02,STR0085," ")) + CHR(13)+ CHR(10)+dToc(dData02 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080)+ CHR(13)+ CHR(10)+  dToc(dData03  )  )
oSection2:Cell("VALOR03"):SetTitle(IIf(dDataRef=dData04,OemToAnsi(STR0084),Iif(dDataRef=dData03,STR0085," ")) + CHR(13)+ CHR(10)+dToc(dData03 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080)+ CHR(13)+ CHR(10)+  dToc(dData04  )   )
oSection2:Cell("VALOR04"):SetTitle(IIf(dDataRef=dData05,OemToAnsi(STR0084),Iif(dDataRef=dData04,STR0085," ")) + CHR(13)+ CHR(10)+dToc(dData04 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData05 )  )
oSection2:Cell("VALOR05"):SetTitle(IIf(dDataRef=dData06,OemToAnsi(STR0084),Iif(dDataRef=dData05,STR0085," "))+ CHR(13)+ CHR(10)+dToc(dData05 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData06 )  )
oSection2:Cell("VALOR06"):SetTitle(IIf(dDataRef=dData07,OemToAnsi(STR0084),Iif(dDataRef=dData06,STR0085," "))+ CHR(13)+ CHR(10)+dToc(dData06 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData07  ) )
oSection2:Cell("VALOR07"):SetTitle(IIf(dDataRef=dData08,OemToAnsi(STR0084),Iif(dDataRef=dData07,STR0085," "))+ CHR(13)+ CHR(10)+dToc(dData07 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData08  ) )
oSection2:Cell("VALOR08"):SetTitle(IIf(dDataRef=dData09,OemToAnsi(STR0084),Iif(dDataRef=dData08,STR0085," "))+ CHR(13)+ CHR(10)+dToc(dData08 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080) + CHR(13)+ CHR(10)+  dToc(dData09  )  )
oSection2:Cell("VALOR09"):SetTitle(IIf(dDataRef=dData10,OemToAnsi(STR0084),Iif(dDataRef=dData09,STR0085," "))+ CHR(13)+ CHR(10)+dToc(dData09 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080)+ CHR(13)+ CHR(10)+  dToc(dData10 )  )
oSection2:Cell("VALOR10"):SetTitle(" " + CHR(13)+ CHR(10)+dToc(dData10 +1)+ CHR(13)+ CHR(10)+OemToAnsi(STR0080)+ CHR(13)+ CHR(10)+  dToc(dData11 )  )
oSection2:Cell("VALOR11"):SetTitle("" + CHR(13)+ CHR(10)+"" + CHR(13)+ CHR(10)+OemToAnsi(STR0081) + CHR(13)+ CHR(10)+  dToc(dData11+1) )       

oSection2:SetHeaderPage()

Trposition():New(oSection2,"SE1",1,{|| xFilial('SE1',TRB->FILORIG)+TRB->PREFIXO+TRB->NUMERO+TRB->PARCELA+TRB->SIGLA})  

oReport:SetTitle(titulo)
oReport:SetMeter(RecCount())
dbSelectArea("TRB")
DbGotop()

oSection1:Init() 
nTotCheque:=0
While !TRB->(EOF())  
   oSection1:PrintLine()      
 	oSection2:Init()
  	If mv_par05 == 2 //Sintetico
		nVlCli00	   := 0
		nVlCli01	   := 0
		nVlCli02	   := 0
		nVlCli03	   := 0
		nVlCli04	   := 0
		nVlCli05	   := 0
		nVlCli06	   := 0
		nVlCli07	   := 0
		nVlCli08	   := 0
		nVlCli09	   := 0
		nVlCli10	   := 0
		nVlCli11	   := 0
		nSalCliFim	:= 0
	EndIf 	
	cCliente:=TRB->CODIGO+TRB->LOJA
   While cCliente==TRB->CODIGO+TRB->LOJA  .And. !TRB->(EOF())
		oReport:IncMeter()    	
  		If mv_par05 == 2 //Sintetico
			nVlCli00	   += TRB->VALOR00
			nVlCli01	   += TRB->VALOR01
			nVlCli02	   += TRB->VALOR02
			nVlCli03	   += TRB->VALOR03
			nVlCli04	   += TRB->VALOR04
			nVlCli05	   += TRB->VALOR05
			nVlCli06	   += TRB->VALOR06
			nVlCli07	   += TRB->VALOR07
			nVlCli08	   += TRB->VALOR08
			nVlCli09	   += TRB->VALOR09
			nVlCli10	   += TRB->VALOR10
			nVlCli11	   += TRB->VALOR11
			nSalCliFim	+= TRB->SALDOFIM
		EndIf
		If &cImpSldChq .and. mv_par05 == 1 // analitico
	   		oSection2:PrintLine()	
	   	EndIf
   		nTotCheque:= nTotCheque + TRB->TOTCHEQ
  		Dbskip()
  	EndDo               
  	If mv_par05 == 2 //Sintetico
  		oSection2:PrintLine()
  	EndIf
  	If nTotCheque >0
		oReport:ThinLine()
		oReport:PrintText(OemToAnsi(STR0043) + Space(01)+ Dtoc(dDataRef) + " : " +Alltrim(Transf(nTotCheque,PesqPict("SE1","E1_VALOR"))))
	EndIf 
 
	oSection2:Finish()	
	oReport:ThinLine()
	nAcumCh:=nAcumCh + nTotCheque
	nTotCheque:=0

EndDo     
If nAcumCh > 0
	oReport:PrintText(OemToAnsi(STR0045) + Space(01)+ Dtoc(dDataRef) + " : " + Alltrim(Transf(nAcumCh,PesqPict("SE1","E1_VALOR"))))
	oReport:ThinLine()
EndIf 
oSection1:Finish()		

dbSelectArea("TRB")
dbCloseArea()

//Deleta tabela temporária no banco de dados
If _oFINR1331 <> Nil
	_oFINR1331:Delete()
	_oFINR1331 := Nil
Endif

dbSelectArea("SA1")
RetIndex("SA1")
dbSetOrder(1)
DbClearFilter()

dbSelectArea("SE1")
RetIndex("SE1")
dbSetOrder(1)
DbClearFilter()

dbSelectArea("SE5")
RetIndex("SE5")
dbSetOrder(1)
DbClearFilter()

Return .T.







/*---------------------------------------------------------------------------R3--------------------------------------------------------------------------------------------*/







/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR133 ³ Autor ³Jose Lucas/Diego Rivero³ Data ³ 09.09.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razonete de Cliente                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR133(void)    / FASE 3                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizacoes paises ConeSul...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
User Function xFinR133R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1  := OemToAnsi(STR0001)   //"Este programa imprimir  la demsotraci¢n contable de Clientes."
Local cDesc2  := OemToAnsi(STR0002)   //"Se puede  emitir  todo  el movimiento de los "
Local cDesc3  := OemToAnsi(STR0003)   //"mismos, o apenas los valores originales. "
Local wnrel
Local limite  :=  220
Local Tamanho := "G"
Local cString := "SE1"
Local lOk 	  :=.F.


Private aOrd      := {STR0073,STR0074,STR0075} //"Vencimiento"###"Prefijo+Titulo"###"Emision"
Private titulo 	:= OemToAnsi(STR0004) //"Deudas Vencidas y a Vencer de Clientes"
Private cabec1 	:= ""
Private cabec2 	:= ""
Private aReturn := { OemToAnsi(STR0005), 1, OemToAnsi(STR0006) , 1, 2, 1, "",1 }   //""###"Administraci¢n"
Private nomeprog:= "FINR133"
Private aLinha 	:= {},nLastKey := 0
Private cPerg 	:= "FIR133"

cTipos := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("FIR133",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "FINR133"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,"",.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| lOk := Fa133Imp(@lEnd,wnRel,cString)},OemToAnsi(STR0004)) //"Deudas Vencidas y a Vencer de Clientes"

If lOk
	Set Device To Screen
	If aReturn[5] = 1
		Set Printer To
		Commit
		Ourspool(wnrel)
	Endif
	MS_FLUSH()
EndIf
Return
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA133Imp ³ Autor ³ Lucas                 ³ Data ³ 11.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razonete de Cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA133Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA133Imp(lEnd,wnRel,cString)
Local cIndice	:=	""
Local CbCont,CbTxt
Local tamanho:="G"
Local nQuebra:=0,lImprAnt := .F.
Local cNome,nTotDeb:=0,nTotCrd:=0,nSaldoAtu:=0,nTotDebG:=0,nTotCrdG:=0,nSalAtuG:=0,nSalAntG:=0
Local aSaldos:={},j,dEmissao:=CTOD(""),dVencto:=CTOD("")
Local nRec,nPrim,cPrefixo,cNumero,cParcela,cNaturez,nValliq
Local nAnterior:=0,cAnterior,cFornece,dDtDigit,cRecPag,nRec1,cSeq
Local nTotAbat
Local nRegistro
Local lNoSkip:= .T.
Local lFlag  := .F.
Local nSaldoFinal:=0
Local aCampos:={},aTam:={}
Local aInd	 :={}
Local cCondE1:=cCondE5:=" "
Local cIndE1 :=cIndE5 :=cIndA1 :=" "
Local nRegAtu,lImprime
Local nRegSe1Atu := SE1->(RecNo())
Local nOrdSe1Atu := SE1->(IndexOrd())
Local lBaixa     := .F.
Local cChaveSe1
Local cRazSocial
Local cVendedor
Local cTelefone
Local	lPerg := .T., lChkDRef := .F.
Local 	I
Local cImpSldChq 
Local nTamClie	:= TAMSX3("E1_CLIENTE")[1]
Local nTamLoja	:= TAMSX3("E1_LOJA")[1]

Private cCodClie
Private cLojaCli
Private cClieProv := ""
Private cLoja := ""
Private cClieIni  := mv_par01
Private cClieFim  := mv_par02
Private dFechaIni := mv_par03
Private dFechaFim := Min(mv_par04,dDataBase)
Private nInforme  := mv_par05
Private nMoeda    := mv_par10
Private lConverte := (mv_par11==1)
Private nDecs     := MsDecimais(nMoeda)
Private dData01
Private dData02
Private dData03
Private dData04
Private dData05
Private dData06
Private dData07
Private dData08
Private dData09
Private dData10
Private dData11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private dDataRef 	:= mv_par06
Private nPeriodos 	:= IIf(mv_par09==0,1,mv_par09)
Private nTipoPer	:= mv_par08
Private nPerAnt		:= IIf(mv_par07 > 9,9,mv_par07)
Private nImpSldChq	:= mv_par12
cImpSldChq := IIF(nImpSldChq == 1,'nInforme == 1 .And. TRB->TIPO <> "CH "',"nInforme == 1")

If nTipoPer == 3 //Informado
	lOk	:=	.T.
	While lOk
		If Pergunte("FI133B",.T.)
			lPerg := .T.
			For I:=1 to 10
            cData1 := ("mv_par"+StrZero(I,2))
            cData2 := ("mv_par"+StrZero(I+1,2))
				If  &cData1. >= &cData2.
					lPerg := .F.
					I:=10
				Endif
			Next
			If lPerg
				For I:=1 to 11
               cData1 := ("mv_par"+StrZero(I,2))
					If &cData1. == dDataRef
						lChkDRef := .T.
						I := 11
					Endif
				Next
				If !lChkDRef
					MsgStop(OemToAnsi("Uma das datas deve coencidir com a Data de Referencia")) //"Uma das datas deve coencidir com a Data de Referencia"
					Loop
				Endif
			Endif

			If lPerg
            dData01  := mv_par01
            dData02  := mv_par02
            dData03  := mv_par03
            dData04  := mv_par04
            dData05  := mv_par05
            dData06  := mv_par06
            dData07  := mv_par07
            dData08  := mv_par08
            dData09  := mv_par09
            dData10  := mv_par10
            dData11  := mv_par11
				//para restaurar os valores nas MV_PAR originais
				Pergunte("FIR133",.f.)
            lOk   := .F.
			Else
				MsgStop(OemToAnsi("Erro de sequencia nas datas")) //"Erro de sequencia nas datas"
			Endif
		Else
			Return .F.
		Endif
	Enddo
Else
	dData01 := Fr133Data(dDataRef,01,nPeriodos,nTipoPer,nPerAnt)
	dData02 := Fr133Data(dDataRef,02,nPeriodos,nTipoPer,nPerAnt)
	dData03 := Fr133Data(dDataRef,03,nPeriodos,nTipoPer,nPerAnt)
	dData04 := Fr133Data(dDataRef,04,nPeriodos,nTipoPer,nPerAnt)
	dData05 := Fr133Data(dDataRef,05,nPeriodos,nTipoPer,nPerAnt)
	dData06 := Fr133Data(dDataRef,06,nPeriodos,nTipoPer,nPerAnt)
	dData07 := Fr133Data(dDataRef,07,nPeriodos,nTipoPer,nPerAnt)
	dData08 := Fr133Data(dDataRef,08,nPeriodos,nTipoPer,nPerAnt)
	dData09 := Fr133Data(dDataRef,09,nPeriodos,nTipoPer,nPerAnt)
	dData10 := Fr133Data(dDataRef,10,nPeriodos,nTipoPer,nPerAnt)
	dData11 := Fr133Data(dDataRef,11,nPeriodos,nTipoPer,nPerAnt)
EndIf

Private nVlCli00	:= 0.00
Private nVlCli01	:= 0.00
Private nVlCli02	:= 0.00
Private nVlCli03	:= 0.00
Private nVlCli04	:= 0.00
Private nVlCli05	:= 0.00
Private nVlCli06	:= 0.00
Private nVlCli07	:= 0.00
Private nVlCli08	:= 0.00
Private nVlCli09	:= 0.00
Private nVlCli10 	:= 0.00
Private nVlCli11	:= 0.00
Private nTotChq		:= 0.00
Private nSalCliFim	:= 0.00

Private nVlVen00	:= 0.00
Private nVlVen01	:= 0.00
Private nVlVen02	:= 0.00
Private nVlVen03	:= 0.00
Private nVlVen04	:= 0.00
Private nVlVen05	:= 0.00
Private nVlVen06	:= 0.00
Private nVlVen07	:= 0.00
Private nVlVen08	:= 0.00
Private nVlVen09	:= 0.00
Private nVlVen10	:= 0.00
Private nVlVen11	:= 0.00
Private nSalVenFim	:= 0.00

Private nVlGer00	:= 0.00
Private nVlGer01	:= 0.00
Private nVlGer02	:= 0.00
Private nVlGer03	:= 0.00
Private nVlGer04	:= 0.00
Private nVlGer05	:= 0.00
Private nVlGer06	:= 0.00
Private nVlGer07	:= 0.00
Private nVlGer08	:= 0.00
Private nVlGer09	:= 0.00
Private nVlGer10 	:= 0.00
Private nVlGer11 	:= 0.00
Private nTotGerChq	:= 0.00
Private nSalGerFim 	:= 0.00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt	:= SPACE(10)
cbcont	:= 0
li		:= 80
m_pag	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo := OemToAnsi("Dívidas Vencidas E Por Vencer De Clientes") //"DEUDAS VENCIDAS Y A VENCER DE CLIENTES"

Titulo += Space(10)
Titulo += OemToAnsi(" de emissão: ")+DTOC(dFechaIni)+OemToAnsi("  até   : ")+DTOC(dFechaFim)  //" De Emision: "###"  Hasta : "
Titulo += Space(10) + OemToAnsi(STR0014)+Space(01)+DTOC(dDataRef)  //"Data  referencia"
Titulo += Space(10) + If(nInforme==1,OemToAnsi("Analítico"),OemToAnsi("Sintético"))  //"Analitico"###"Resumen"

AADD(aCampos,{"FILORIG" ,"C",Len(SE5->E5_FILIAL),0})
AADD(aCampos,{"CODIGO"  ,"C",nTamClie,0})
AADD(aCampos,{"LOJA"    ,"C",nTamLoja,0})
AADD(aCampos,{"CLIENTE" ,"C",25,0})
AADD(aCampos,{"TELEFONE","C",15,0})
AADD(aCampos,{"VENDEDOR","C",06,0})
AADD(aCampos,{"NOMEVEND","C",25,0})
AADD(aCampos,{"TELEVEND","C",15,0})
AADD(aCampos,{"NATUREZA","C",10,0})
AADD(aCampos,{"PREFIXO" ,"C",03,0})
AADD(aCampos,{"NUMERO"  ,"C",15,0})
AADD(aCampos,{"TIPO"    ,"C",03,0})
AADD(aCampos,{"PARCELA" ,"C",01,0})
AADD(aCampos,{"BANCO"   ,"C",03,0})
AADD(aCampos,{"EMISSAO" ,"D",08,0})
AADD(aCampos,{"BAIXA"   ,"D",08,0})
AADD(aCampos,{"VENCTO"  ,"D",08,0})
AADD(aCampos,{"VALOR"   ,"N",18,nDecs})
AADD(aCampos,{"DEBITO"  ,"N",18,nDecs})
AADD(aCampos,{"CREDITO" ,"N",18,nDecs})
AADD(aCampos,{"SALDO"   ,"N",18,nDecs})
AADD(aCampos,{"SALTIT"  ,"N",18,nDecs})
AADD(aCampos,{"DC"      ,"C", 1,0})
AADD(aCampos,{"SIGLA"   ,"C",03,0})
AADD(aCampos,{"VALOR00" ,"N",18,nDecs})
AADD(aCampos,{"VALOR01" ,"N",18,nDecs})
AADD(aCampos,{"VALOR02" ,"N",18,nDecs})
AADD(aCampos,{"VALOR03" ,"N",18,nDecs})
AADD(aCampos,{"VALOR04" ,"N",18,nDecs})
AADD(aCampos,{"VALOR05" ,"N",18,nDecs})
AADD(aCampos,{"VALOR06" ,"N",18,nDecs})
AADD(aCampos,{"VALOR07" ,"N",18,nDecs})
AADD(aCampos,{"VALOR08" ,"N",18,nDecs})
AADD(aCampos,{"VALOR09" ,"N",18,nDecs})
AADD(aCampos,{"VALOR10" ,"N",18,nDecs})
AADD(aCampos,{"VALOR11" ,"N",18,nDecs})
AADD(aCampos,{"VALOR12" ,"N",18,nDecs})
AADD(aCampos,{"VALOR13" ,"N",18,nDecs})
AADD(aCampos,{"TOTCHEQ" ,"N",18,nDecs})
AADD(aCampos,{"SALDOFIM","N",18,nDecs})  
// SSS 07/07/2020 - Adiciona campos no array acampos para imprimir o numero da invoice / Nota 
AADD(aCampos,{"NRINVOICE","C",30,0})
AADD(aCampos,{"NRNOTA","C",09,0})
// SSS 07/07/2020 - Adiciona campos no array acampos para imprimir o numero da invoice / Nota 
If _oFINR1332 <> Nil
	_oFINR1332:Delete()
	_oFINR1332 := Nil
Endif

_oFINR1332 := FWTemporaryTable():New( "TRB" )  
_oFINR1332:SetFields(aCampos) 	

If aReturn[8]	==	1
	_oFINR1332:AddIndex("1", {"CODIGO","LOJA","VENCTO"}) 
ElseIf aReturn[8]	==	2
	_oFINR1332:AddIndex("1", {"CODIGO","LOJA","PREFIXO","NUMERO","PARCELA","TIPO"}) 
Else
	_oFINR1332:AddIndex("1", {"CODIGO","LOJA","EMISSAO"}) 
Endif

//------------------
//Criação da tabela temporaria
//------------------
_oFINR1332:Create()	

Processa({|lEnd| GeraTra(aReturn[7])},,OemToAnsi("Preparando Transit¢rio..."))  //"Preparando Transit¢rio..."

R133fechas()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia rotina de impressao                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()

nTotClie := 0
nTotVend := 0

SetRegua(RecCount())

nVlGer00	:= 0.00
nVlGer01	:= 0.00
nVlGer02	:= 0.00
nVlGer03	:= 0.00
nVlGer04	:= 0.00
nVlGer05	:= 0.00
nVlGer06	:= 0.00
nVlGer07	:= 0.00
nVlGer08	:= 0.00
nVlGer09	:= 0.00
nVlGer10	:= 0.00
nVlGer11	:= 0.00
nSalGerFim	:= 0.00

While ! Eof()

	If li > 65
		R133CabRes(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	EndIf

	nVlCli00	:= 0.00
	nVlCli01	:= 0.00
	nVlCli02	:= 0.00
	nVlCli03	:= 0.00
	nVlCli04	:= 0.00
	nVlCli05	:= 0.00
	nVlCli06	:= 0.00
	nVlCli07	:= 0.00
	nVlCli08	:= 0.00
	nVlCli09	:= 0.00
	nVlCli10	:= 0.00
	nVlCli11	:= 0.00
	nTotChq		:= 0.00
	nSalCliFim	:= 0.00

	cCodClie    := TRB->CODIGO
	cLojaCli    := TRB->LOJA
	cRazSocial  := TRB->CLIENTE
	cVendedor   := TRB->VENDEDOR
	cTelefone   := TRB->TELEFONE 
	cInvoice    := TRB->NRINVOICE

	lImpClie := .T.

	While !Eof().and.TRB->CODIGO==cCodClie.and.TRB->LOJA==cLojaCli

		IncRegua()
		If lEnd
			Exit
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le registros com data anterior a data inicial (para compor   ³
		//³ os saldos anteriores) ate a data final.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If li>65
			R133CabRes(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
		EndIf


		If &(cImpSldChq)//Detallado
			If lImpClie
				R133CabCli()
				lImpClie := .F.
				li++
				li++
			EndIf
			@li,000 PSAY VENCTO
			@li,011 PSAY SIGLA
			@li,015 PSAY PREFIXO
			@li,019 PSAY NUMERO
			@li,035 PSAY PARCELA 
		    //@li,035 PSAY cInvoice
			@li,038 PSAY VALOR00      	Picture TM(VALOR00	, 13,nDecs)
			@li,052 PSAY VALOR01      	Picture TM(VALOR01	, 13,nDecs)
			@li,066 PSAY VALOR02      	Picture TM(VALOR02	, 13,nDecs)
			@li,080 PSAY VALOR03      	Picture TM(VALOR03	, 13,nDecs)
			@li,094 PSAY VALOR04      	Picture TM(VALOR04	, 13,nDecs)
			@li,108 PSAY VALOR05      	Picture TM(VALOR05	, 13,nDecs)
			@li,122 PSAY VALOR06      	Picture TM(VALOR06	, 13,nDecs)
			@li,136 PSAY VALOR07      	Picture TM(VALOR07	, 13,nDecs)
			@li,150 PSAY VALOR08      	Picture TM(VALOR08	, 13,nDecs)
			@li,164 PSAY VALOR09      	Picture TM(VALOR09	, 13,nDecs)
			@li,178 PSAY VALOR10      	Picture TM(VALOR10	, 13,nDecs)
			@li,192 PSAY VALOR11      	Picture TM(VALOR11	, 13,nDecs)
			@li,206 PSAY SALDOFIM		Picture TM(SALDOFIM	, 13,nDecs)
			@li,220 PSAY If(SALDOFIM<0,"C","D")   
			//@li,223 PSAY cInvoice		 
			li++
		EndIf
		nVlCli00	+= TRB->VALOR00
		nVlCli01	+= TRB->VALOR01
		nVlCli02	+= TRB->VALOR02
		nVlCli03	+= TRB->VALOR03
		nVlCli04	+= TRB->VALOR04
		nVlCli05	+= TRB->VALOR05
		nVlCli06	+= TRB->VALOR06
		nVlCli07	+= TRB->VALOR07
		nVlCli08	+= TRB->VALOR08
		nVlCli09	+= TRB->VALOR09
		nVlCli10	+= TRB->VALOR10
		nVlCli11	+= TRB->VALOR11
		nTotChq		+= TRB->TOTCHEQ
		nSalCliFim	+= TRB->SALDOFIM
		dbSelectArea("TRB")
		dbSkip()
	EndDo
	If nInforme == 1 //Detallado
		nTotClie ++
		li++
		@li, 0 PSAY Repl("-",220)
		li++
		@li,  0 PSAY OemtoAnsi("Total Cliente: ")+cCodClie+"-"+cLojaCli  //"Total Cliente: "
		@li, 38 PSAY nVlCli00		Picture TM(nVlCli00  , 13,nDecs)
		@li, 52 PSAY nVlCli01		Picture TM(nVlCli01  , 13,nDecs)
		@li, 66 PSAY nVlCli02		Picture TM(nVlCli02  , 13,nDecs)
		@li, 80 PSAY nVlCli03		Picture TM(nVlCli03  , 13,nDecs)
		@li, 94 PSAY nVlCli04		Picture TM(nVlCli04  , 13,nDecs)
		@li,108 PSAY nVlCli05		Picture TM(nVlCli05  , 13,nDecs)
		@li,122 PSAY nVlCli06		Picture TM(nVlCli06  , 13,nDecs)
		@li,136 PSAY nVlCli07		Picture TM(nVlCli07  , 13,nDecs)
		@li,150 PSAY nVlCli08		Picture TM(nVlCli08  , 13,nDecs)
		@li,164 PSAY nVlCli09		Picture TM(nVlCli09  , 13,nDecs)
		@li,178 PSAY nVlCli10		Picture TM(nVlCli10  , 13,nDecs)
		@li,192 PSAY nVlCli11		Picture TM(nVlCli11  , 13,nDecs)
		@li,206 PSAY nSalCliFim		Picture TM(nSalCliFim, 13,nDecs)
		@li,220 PSAY If(nSalCliFim<0,"C","D")
	 
		If (nImpSldChq ==1)
			li++
			@li,000 PSAY OemToAnsi(STR0043) + Space(01)+ Dtoc(dDataRef) + " -" //"Saldo de Cheques Al "
			@li,032 PSAY nTotChq Picture TM(nTotChq  , 13,nDecs)
		EndIf
	    li++
		@li, 0 PSAY Repl("-",220)
		li++
	ElseIf nInforme == 2 //Sint‚tico
		nTotClie ++
		@li,  0 PSAY cCodClie+"-"+cLojaCli
		@li,011 PSAY Subs(cRazSocial,1,16)
		@li,028 PSAY cVendedor
		@li,038 PSAY nVlCli00		Picture TM(nVlCli00  , 13,nDecs)
		@li,052 PSAY nVlCli01		Picture TM(nVlCli01  , 13,nDecs)
		@li,066 PSAY nVlCli02		Picture TM(nVlCli02  , 13,nDecs)
		@li,080 PSAY nVlCli03		Picture TM(nVlCli03  , 13,nDecs)
		@li,094 PSAY nVlCli04		Picture TM(nVlCli04  , 13,nDecs)
		@li,108 PSAY nVlCli05		Picture TM(nVlCli05  , 13,nDecs)
		@li,122 PSAY nVlCli06		Picture TM(nVlCli06  , 13,nDecs)
		@li,136 PSAY nVlCli07		Picture TM(nVlCli07  , 13,nDecs)
		@li,150 PSAY nVlCli08		Picture TM(nVlCli08  , 13,nDecs)
		@li,164 PSAY nVlCli09		Picture TM(nVlCli09  , 13,nDecs)
		@li,178 PSAY nVlCli10		Picture TM(nVlCli10  , 13,nDecs)
		@li,192 PSAY nVlCli11		Picture TM(nVlCli11  , 13,nDecs)
		@li,206 PSAY nSalCliFim		Picture TM(nSalCliFim, 13,nDecs)
		@li,220 PSAY If(nSalCliFim<0,"C","D")   
	 
		If (nImpSldChq ==1)
			li++
			@li,000 PSAY OemToAnsi(STR0043) + Space(01)+ Dtoc(dDataRef)  + " -" //"Saldo de Cheques Al "
			@li,032 PSAY nTotChq Picture TM(nTotChq  , 13,nDecs)
		EndIf
		li++
		li++
	EndIf
	nVlGer00	+= nVlCli00
	nVlGer01	+= nVlCli01
	nVlGer02	+= nVlCli02
	nVlGer03	+= nVlCli03
	nVlGer04	+= nVlCli04
	nVlGer05	+= nVlCli05
	nVlGer06	+= nVlCli06
	nVlGer07	+= nVlCli07
	nVlGer08	+= nVlCli08
	nVlGer09	+= nVlCli09
	nVlGer10	+= nVlCli10
	nVlGer11	+= nVlCli11
	nTotGerChq	+= nTotChq
	nSalGerFim	+= nSalCliFim
EndDo

If nTotClie > 1 .or. nTotVend > 0
	If li>65
		R133CabRes(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	EndIf
	li++
	@li, 0 PSAY Repl("-",220)
	li++
	@li,  0 PSAY OemtoAnsi(STR0044) //"T o t a l   G e n e r a l "
	@li,038 PSAY nVlGer00		Picture TM(nVlGer00   , 13,nDecs)
	@li,052 PSAY nVlGer01		Picture TM(nVlGer01   , 13,nDecs)
	@li,066 PSAY nVlGer02		Picture TM(nVlGer02   , 13,nDecs)
	@li,080 PSAY nVlGer03		Picture TM(nVlGer03   , 13,nDecs)
	@li,094 PSAY nVlGer04		Picture TM(nVlGer04   , 13,nDecs)
	@li,108 PSAY nVlGer05		Picture TM(nVlGer05   , 13,nDecs)
	@li,122 PSAY nVlGer06		Picture TM(nVlGer06   , 13,nDecs)
	@li,136 PSAY nVlGer07		Picture TM(nVlGer07   , 13,nDecs)
	@li,150 PSAY nVlGer08		Picture TM(nVlGer08   , 13,nDecs)
	@li,164 PSAY nVlGer09		Picture TM(nVlGer09   , 13,nDecs)
	@li,178 PSAY nVlGer10		Picture TM(nVlGer10   , 13,nDecs)
	@li,192 PSAY nVlGer11		Picture TM(nVlGer11   , 13,nDecs)
	@li,206 PSAY nSalGerFim		Picture TM(nSalGerFim , 13,nDecs)
	@li,220 PSAY If(nSalGerFim<0,"C","D")  
 
	If (nImpSldChq ==1)
		li++
		@li,000 PSAY OemToAnsi(STR0045) + Space(01)+ Dtoc(dDataRef)  + " -" //"S a l d o   G e n e r a l   d e   C h e q u e s  A l "
		@li,064 PSAY nTotGerChq Picture TM(nTotGerChq  , 13,nDecs)
	EndIf
	li++
	@li, 0 PSAY Repl("-",220)
EndIf

Roda( cbCont, cbTxt, Tamanho )

dbSelectArea("TRB")
dbCloseArea()

//Deleta tabela temporária do banco de dados
If _oFINR1332 <> Nil
	_oFINR1332:Delete()
	_oFINR1332 := Nil
Endif

dbSelectArea("SA1")
RetIndex("SA1")
dbSetOrder(1)
DbClearFilter()

dbSelectArea("SE1")
RetIndex("SE1")
dbSetOrder(1)
DbClearFilter()

dbSelectArea("SE5")
RetIndex("SE5")
dbSetOrder(1)
DbClearFilter()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R450CabRes³ Autor ³ Jose Lucas           ³ Data ³ 24.09.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Cabecalho do Resumo.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ R450CabRes(void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function R133CabRes(titulo,cabec1,cabec2,nomeprog,tamanho)
Local aDataRef:={}
Local aColR:={053,068,082,096,110,124,138,152,166,180,194}
Local i:=0

cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
@ li,000 PSAY Replicate("*",220)
li++
For i:=1 to 11
	cData := ("dData"+StrZero(i,2))
	If (Dtos(&cData) == Dtos(dDataRef))
		@ li,aColR[i]-Len(STR0046)/2 PSAY OemToAnsi(STR0046) //"Vencidos << >> A Vencer"###"Vencidos << >> A Vencer"
		i:=11
	Endif
Next
li++
@ li,057 PSAY dData01 + 1
@ li,071 PSAY dData02 + 1
@ li,085 PSAY dData03 + 1
@ li,099 PSAY dData04 + 1
@ li,113 PSAY dData05 + 1
@ li,127 PSAY dData06 + 1
@ li,141 PSAY dData07 + 1
@ li,155 PSAY dData08 + 1
@ li,169 PSAY dData09 + 1
@ li,183 PSAY dData10 + 1

li++
@ li,000 PSAY OemToAnsi(STR0047) //"Cliente/Comprobante            Vendedor     Hasta           A             A             A             A             A             A             A             A             A             A            Post.           Saldo"
li++

If nInforme == 1
	@ li,000 PSAY OemToAnsi(STR0048) //"Fecha    Tipo Serie Numero      Cuotas"
Endif

@ li,043 PSAY 	dData01
@ li,057 PSAY 	dData02
@ li,071 PSAY 	dData03
@ li,085 PSAY 	dData04
@ li,099 PSAY 	dData05
@ li,113 PSAY 	dData06
@ li,127 PSAY 	dData07
@ li,141 PSAY 	dData08
@ li,155 PSAY 	dData09
@ li,169 PSAY 	dData10
@ li,183 PSAY 	dData11
@ li,197 PSAY 	dData11 + 1
li++
@ li,000 PSAY Replicate("*",220)
li := 12
Return( Nil )

/*/

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R133Grav  ³ Autor ³ Jose Lucas            ³ Data ³ 03.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava um registro no arquivo de trabalho para impressao     ³±±
±±³          ³do Razonete.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³R133Grv()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR133                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R133Fechas()
Local nDiasAtrazo := 0
Local nDiasAVencer := 0
Local nValor := 0.00
Local nVlrCruz := 0.00
Local nSldTit := 0.00
Local cImpSldChq := IIf(nImpSldChq == 1,'TRB->TIPO <> "CH"',".T.")

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	nSldTit := TRB->SALDO
	RecLock("TRB",.F.)
	If (&cImpSldChq)
		If TRB->VENCTO <= dData01
			Replace VALOR00    With VALOR00 + nSldTit
		ElseIf TRB->VENCTO > dData01 .and. TRB->VENCTO <= dData02
			Replace VALOR01   With VALOR01 + nSldTit
		ElseIf TRB->VENCTO > dData02 .and. TRB->VENCTO <= dData03
			Replace VALOR02   With VALOR02 + nSldTit
		ElseIf TRB->VENCTO > dData03 .and. TRB->VENCTO <= dData04
			Replace VALOR03   With VALOR03 + nSldTit
		ElseIf TRB->VENCTO > dData04 .and. TRB->VENCTO <= dData05
			Replace VALOR04   With VALOR04 + nSldTit
		ElseIf TRB->VENCTO > dData05 .and. TRB->VENCTO <= dData06
			Replace VALOR05   With VALOR05 + nSldTit
		ElseIf TRB->VENCTO > dData06 .and. TRB->VENCTO <= dData07
			Replace VALOR06   With VALOR06 + nSldTit
		ElseIf TRB->VENCTO > dData07 .and. TRB->VENCTO <= dData08
			Replace VALOR07   With VALOR07 + nSldTit
		ElseIf TRB->VENCTO > dData08 .and. TRB->VENCTO <= dData09
			Replace VALOR08   With VALOR08 + nSldTit
		ElseIf TRB->VENCTO > dData09 .and. TRB->VENCTO <= dData10
			Replace VALOR09   With VALOR09 + nSldTit
		ElseIf TRB->VENCTO > dData10 .and. TRB->VENCTO <= dData11
			Replace VALOR10   With VALOR10 + nSldTit
		ElseIf TRB->VENCTO > dData11
			Replace VALOR11   With VALOR11 + nSldTit
		EndIf

		nValor := VALOR00+VALOR01+VALOR02+VALOR03+VALOR04+VALOR05+VALOR06
		nValor += VALOR11+VALOR10+VALOR09+VALOR08+VALOR07
		Replace SALDOFIM  With nValor
	Else
		Replace TOTCHEQ With nSldTit
	Endif
	MsUnLock()
	dbSkip()
End
Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R133CabClie  ³ Autor ³ Lucas             ³ Data ³ 12.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir el cabeca de los Clientes...                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R133CabClie()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR133                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function R133CabClie()

Local nTamClie	:= TAMSX3("E1_CLIENTE")[1]
Local nTamLoja	:= TAMSX3("E1_LOJA")[1]
Local nColNome := 14+nTamClie+nTamLoja

SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1")+TRB->CODIGO+TRB->LOJA) )
@li,  0 PSAY OemtoAnsi(STR0049)+TRB->CODIGO+"-"+TRB->LOJA   //"Cliente : "
@li, nColNome PSAY SA1->A1_NREDUZ + OemToAnsi(STR0050) + Alltrim(SA1->A1_END) + " - "  +;  //". Direccion : "
	Alltrim(SA1->A1_MUN) + "-"+ SA1->A1_EST +"  "+OemtoAnsi(STR0051) +SA1->A1_TEL  //"TEL: "

SA3->( dbSetOrder(1) )
SA3->( dbSeek(xFilial("SA3")+SA1->A1_VEND ))

If SA3->( Found() )
	@li, 140 PSAY OemToAnsi(STR0052) //"VENDEDOR: "
	@li, 150 PSAY SA1->A1_VEND + "-" + Alltrim(SA3->A3_NOME)+"  "+OemToAnsi(STR0051)+SA3->A3_TEL  //"TEL: "
EndIf

//@li, 170 PSAY "Order Ref : " + TRB->NRINVOICE

Return




/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GERATRA  ³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 20.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion del archivo temporal con la informacion de la   ³±±
±±³          ³ deuda con un Cliente.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraTra(cFltSE1,cFltSA1)
Local nDebito := 0.00
Local nCredito := 0.00
Local nSigno
Local nPosTip
Local cTipos 		:=	""
Local nTaxa:= 0
Local nValPCC := 0
Local nAbt	  := 0
Local lBr10925	:= SuperGetMv("MV_BR10925",,"2") == "2"
Local cQuery		:= ""
Local cAliasSE1		:= ""
Local cTmpSE1Fil	:= ""
Local cFilOrig		:= ""
Local aArea			:= {} 

If ExistBlock("FR133TIP")
	cTipos   := ExecBlock("FR133TIP",.F.,.F.)
Endif

/* GESTAO - inicio */
cFilOrig := cFilAnt
aArea := GetArea()
cQuery := "select E1_CLIENTE,R_E_C_N_O_ from " + RetSQLName("SE1") + " where" 
If !Empty(aSelFil)
	cQuery += " E1_FILIAL " + GetRngFil(aSelFil,"SE1",.T.,@cTmpSE1Fil)
Else
   cQuery += " E1_FILIAL = '" + FwxFilial("SE1") + "'"
Endif
cQuery += " and E1_CLIENTE >= '" + cClieIni + "'"
cQuery += " and E1_CLIENTE <= '" + cClieFim + "'"
cQuery += " and E1_EMISSAO >= '" + Dtos(dFechaIni) + "'"
cQuery += " and E1_EMISSAO <= '" + Dtos(MIN(dDataRef,dFechaFim)) + "'"
If cPaisLoc == "ARG" .And. nMoeda <> 1
	cQuery += " and E1_CONVERT <> 'N'"
Endif
If !lConverte
	cQuery += " and E1_MOEDA = " + AllTrim(Str(nMoeda))
Endif
cQuery += " and D_E_L_E_T_ = ' '"
cQuery += " order by E1_CLIENTE" 
cQuery := ChangeQuery(cQuery)
cAliasSE1 := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE1,.F.,.T.)

/* GESTAO - fim */
nCount := 1000

ProcRegua( nCount )

While !((cAliasSE1)->(Eof())) .and. (cAliasSE1)->E1_CLIENTE <= cClieFim

	DbSelectArea("SE1")
	SE1->(DbGoTo((cAliasSE1)->R_E_C_N_O_))
	cFilAnt := If(Empty(SE1->E1_FILORIG),SE1->E1_FILIAL,SE1->E1_FILORIG)
	
	If !Empty(cTipos).And. !(E1_TIPO $ cTipos)
		(cAlaisSE1)->(DbSkip())
		Loop
	Endif

	If !Empty(cFltSE1) .And. !(&(cFltSE1))
		(cAliasSE1)->(DbSkip())
		Loop
	Endif

	If !Empty(cFltSA1) 
		DbSelectArea( "SA1" )
		DbSetOrder(1)
		MSSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA )
		If !(&(cFltSA1))
			DbSelectArea( cAlaisSE1 )
			DbSkip()
			Loop
		Endif	
		DbSelectArea( cAliasSE1 )
	Endif

    nTaxa:=Iif(MV_PAR13==1,0,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)))
	nSigno := IIf(SE1->E1_TIPO $ "RA "+"/"+MV_CRNEG+"/"+MVABATIM ,-1,1)
	nSaldo := 0
	If !(SE1->E1_TIPO $ MVABATIM)
		nAbt   := RetAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA)
	EndIf
	nSaldo := Round( SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, nMoeda, dDataRef, ;
	                 dDataRef, SE1->E1_LOJA,,nTaxa ), nDecs ) - nAbt
	                 
	If (SE1->E1_TIPO $ MVABATIM .And. SE1->E1_SALDO == 0) .Or. (SE1->E1_TIPO $ "PIS#COF#CSL" .And. SE1->E1_SALDO == 0 .And. SE1->E1_BAIXA <= dDataBase)
		nSaldo := 0
	ElseIf lBr10925 .And. nSaldo == SE1->(E1_PIS + E1_COFINS + E1_CSLL + E1_INSS + E1_ISS + E1_IRRF) .And. SE1->E1_TIPO $ MVNOTAFIS .And. ( SE1->E1_SALDO == 0 .Or. SE1->E1_SALDO != SE1->E1_VALOR) .And. SE1->E1_BAIXA <= dDataBase
		nSaldo := 0
	Endif 

	If ! SE1->E1_TIPO $ MVABATIM .And. ;
   	   ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. nSaldo > 0      
   	
		nAbatim  := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",dDataRef)
		cChaveAb := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+"AB-"
		nValPCC  := CalcPCC(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA, mv_par10)
		
		If (SE1->E1_BAIXA <= dDataBase .And. !Empty(SE1->E1_BAIXA) .And. (nAbatim>0 .Or. nValPCC>0))
			If nSaldo == SE1->E1_VALOR
		  		nSaldo-= (nAbatim + nValPCC)
		  	ElseIf nSaldo == nValPCC
		  		nSaldo -= nValPCC
	  		Endif

			cArea := Alias()
			nInd  := IndexOrd()
			nRec  := Recno()   
		
			If nSaldo > 0
				DbSelectArea("SE1")
				DbSetOrder(1)
				DbGoTop()
			
				If DbSeek( cChaveAb)
					If SE1->E1_SALDO == 0 .And. !Empty(SE1->E1_BAIXA) .And. SE1->E1_BAIXA <= dDataBase 
						nSaldo -= SE1->E1_VALOR
					Else
						nSaldo += SE1->E1_VALOR
					EndIf
				EndIf
		
				DbSelectArea(cArea)
				DbSetOrder(nInd)
				DbGoTo(nRec)              
	    	EndIf
		  		
		EndIf   
	
	EndIf	                 

	IF nSaldo > 0

		DbSelectArea( "SA1" )
		DbSetOrder(1)
		MSSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA )
		IncProc(OemtoAnsi(STR0064)+Subst(SA1->A1_NREDUZ,1,27))  //"Procesando cliente "

		DbSelectArea( "SE1" )

		RecLock("TRB",.T.)
		/* GESTAO - inicio */
		TRB->FILORIG	:= If(Empty(SE1->E1_FILORIG),SE1->E1_FILIAL,SE1->E1_FILORIG)
		/* GESTAO - fim */
		TRB->CODIGO    :=  SE1->E1_CLIENTE
		TRB->LOJA      :=  SE1->E1_LOJA
		TRB->CLIENTE   :=  SA1->A1_NOME
		TRB->VENDEDOR  :=  SA1->A1_VEND
		TRB->TELEFONE  :=  SA1->A1_TEL
		TRB->NUMERO    :=  SE1->E1_NUM
		TRB->TIPO      :=  SE1->E1_TIPO
		TRB->SIGLA     :=  SE1->E1_TIPO
		TRB->PARCELA   :=  SE1->E1_PARCELA
		TRB->PREFIXO   :=  SE1->E1_PREFIXO
		TRB->EMISSAO   :=  SE1->E1_EMISSAO
		TRB->VENCTO    :=  SE1->E1_VENCREA
		TRB->VALOR     :=  SE1->E1_VALOR  * nSigno
		TRB->SALDO     :=  nSaldo         * nSigno  
		// SSS 07/07/2020 - Grava campos os campos numero da invoice / Nota 
		TRB->NRINVOICE :=  SE1->E1_P_ESA  //cRtInvoice()		
		TRB->NRNOTA    :=  SE1->E1_NFELETR
		// SSS 07/07/2020 - Grava campos os campos numero da invoice / Nota 
		MsUnLock()
	ENDIF
	dbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbSkip())
EndDo

DbSelectArea(cAliasSE1)
DbCloseArea()
If !Empty(cTmpSE1Fil)
	CtbTmpErase(cTmpSE1Fil)
Endif
cFilAnt := cFilOrig
RestArea(aArea)

/* GESTAO - fim */
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FR133Data³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 20.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a data correta segundo os parametros informados.   ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr133Data(dData,nColuna,nPeriodo,nTipo,nPeriodAnt)
Local dRet

If nTipo == 1 // Dia
	nDay 	 := Day(dData)
	nMonth   := Month(dData)
	nAno     := Year(dData)
	nRetPer  := nPeriodo * (nColuna - (nPeriodAnt+1) )
	dRet 	 := dData + nRetPer

ElseIf nTipo == 2  //Mes
	nMonth   := Month(dData)
	nAno     := Year(dData)
	nRetPer  := nPeriodo * (nColuna - (nPeriodAnt+1) )
	nMonth   := nMonth + nRetPer
	nAno     += IIf(nMonth <= 0, -1,Iif(nMonth >12 ,  1,0))
	nMonth   += IIf(nMonth <= 0, 12,Iif(nMonth >12 ,-12,0))
	If Month(dData) <> Month(dData+1)
		dRet	:=	LastDay(Ctod("01/"+StrZero(nMonth,2)+"/"+Str(nAno,4)),0)
	Else
		cMonth   := Strzero(nMonth,2)
		cDay	 := Str(Day(dData),2)
		dRet     := CTOD(cDay+"/"+cMonth+"/"+Str(nAno,4))
	Endif
Endif

Return dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CalcPCC   ³ Autor ³ Jose Delmondes		 ³ Data³29/01/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula PCC em caso de saldo retroativo               	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr133.prx                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcPCC(cPrefixo,cNumero,cParcela,dDataRef,cCodCli,cLoja,nMoeda)

Local cAlias	:= Alias()
Local nOrdem	:= indexord()
Local cQuery	:= ""
Local nTotPcc	:= 0

DEFAULT nMoeda	:= 1

cQryAlias := GetNextAlias()

cQuery	:= " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_EMISSAO, E1_VALOR, E1_TXMOEDA, E1_MOEDA, E1_TITPAI, R_E_C_N_O_ RECNO "
cQuery	+= " FROM "+RetSqlName("SE1")
cQuery	+= " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
cQuery	+= " E1_PREFIXO = '"+cPrefixo+"' AND "
cQuery	+= " E1_NUM = '"+cNumero+"' AND "
cQuery	+= " E1_CLIENTE = '"+cCodCli+"' AND "
cQuery	+= " E1_LOJA = '"+cLoja+"' AND "
cQuery	+= " E1_TIPO IN ('PIS','COF','CSL') AND "
cQuery	+= " E1_EMISSAO <= '"+Dtos(dDataRef)+"' AND "
cQuery	+= " D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias , .F., .T.)

While (cQryAlias)->( !Eof() )
	nTotPcc += xMoeda((cQryAlias)->E1_VALOR,(cQryAlias)->E1_MOEDA,nMoeda,dDataRef,,If(cPaisLoc=="BRA",(cQryAlias)->E1_TXMOEDA,0))
 	(cQryAlias)->(dbSkip())		
EndDo

(cQryAlias)->(dbCloseArea())

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

Return(nTotPcc)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetAbat	   º Autor ³ igor.nascimento  º Data ³  30/05/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna valor de titulos do tipo (AB-) apenas		      º±±
±±ºRetorno   ³ nValorAbt - Numerico									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - Localizacao Brasil                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 
Static Function RetAbat(cPref,cNum,cParcela)
Local aArea := GetArea()
Local cQuery:= ""
Local cAlias := ""
Local nValorAbt:= 0	// Retorno da funcao
Default cPref   := SE1->E1_PREFIXO
Default cNum    := SE1->E1_NUM
Default cParcela:= SE1->E1_PARCELA

cAlias := GetNextAlias()
cQuery := "SELECT SE1.E1_VALOR AS VLRABAT FROM "
cQuery += RetSqlName("SE1") + " SE1 " 
cQuery += "WHERE "
cQuery += "SE1.E1_FILIAL = '"+ xFilial("SE1") +"' AND "
cQuery += "SE1.E1_PREFIXO = '"+ cPref +"' AND "
cQuery += "SE1.E1_NUM = '"+ cNum +"' AND "
cQuery += "SE1.E1_PARCELA = '"+ cParcela +"' AND "
cQuery += "SE1.E1_TIPO = 'AB-' AND "
cQuery += "SE1.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

dbSelectArea(cAlias)
(cAlias)->(DbGoTop())
If (cAlias)->VLRABAT <> 0
	nValorAbt := (cAlias)->VLRABAT
EndIf
(cAlias)->(dbCloseArea())
MsErase(cAlias)
RestArea(aArea)
Return nValorAbt

//*-------------------------
Static Function cRtInvoice() 
//*-------------------------
Local aArea     := GetArea()
Local cQuery    := ""
Local cAlias    := ""
Local cInvoice  := "" // Retorno da funcao
Local cClient   := TRB->CODIGO
Local cLoja     := TRB->LOJA
Local cNum      := TRB->NUMERO

cAlias := "TMPINV"
cQuery := "SELECT SC5.C5_P_REF AS INVOICE FROM "                                    
cQuery += RetSqlName("SC5") + " SC5 " 
cQuery += "WHERE "
cQuery += "SC5.C5_FILIAL = '"+ xFilial("SC5") +"' AND "
cQuery += "SC5.C5_CLIENT = '"+ cClient +"' AND "
cQuery += "SC5.C5_LOJACLI = '"+ cLoja +"' AND "
cQuery += "SC5.C5_NOTA = '"+ cNum +"' AND "
cQuery += "SC5.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  	

dbSelectArea(cAlias)
(cAlias)->(DbGoTop())
If (cAlias)->INVOICE <> ""
	cInvoice := (cAlias)->INVOICE
EndIf
(cAlias)->(dbCloseArea())
MsErase(cAlias)
RestArea(aArea)
Return cInvoice

