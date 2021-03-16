#Include "FINR150.CH"
#Include "PROTHEUS.Ch"
#INCLUDE "FWCOMMAND.CH"

#DEFINE QUEBR			1
#DEFINE FORNEC			2
#DEFINE TITUL			3
#DEFINE TIPO			4
#DEFINE NATUREZA		5
#DEFINE EMISSAO			6
#DEFINE VENCTO			7
#DEFINE VENCREA			8
#DEFINE VL_ORIG			9
#DEFINE VL_NOMINAL		10
#DEFINE VL_CORRIG		11
#DEFINE VL_VENCIDO		12
#DEFINE PORTADOR		13
#DEFINE VL_JUROS		14
#DEFINE ATRASO			15
#DEFINE HISTORICO		16
#DEFINE VL_SOMA			17
#DEFINE CODFORN			18
#DEFINE LOJFORN 		19
#DEFINE VL_SOMA			20
#DEFINE MICROVE			21
#DEFINE CODBARR			22
#DEFINE DETALHE			23
#DEFINE VLRLIQD         24
#DEFINE VLRBRUT         25
#DEFINE VLRRETI         26


Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FIN150	³ Autor ³ Daniel Tadashi Batori ³ Data ³ 07.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posi‡„o dos Titulos a Pagar					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR150(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION xFINR150()

Local oReport  

Private cTitAux := ""    // Guarda o titulo do relatório para R3 e R4 

//GESTAO - inicio 
Private aSelFil	:= {}
 
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ Daniel Batori         ³ Data ³ 07.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do layout do Relatorio							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cPictTit
Local nTamVal, nTamCli, nTamQueb
Local aOrdem := {"Por Numero"     ,;	     
				 "Por Natureza"   ,;	     
				 "Por Vencimento" ,;	     
    		     "Por Banco"      ,;	     
		         "Fornecedor"     ,;	     
		         "Por Emissao"    ,;	     
		         "Por Cod.Fornec."}	       
                                                                              
oReport := TReport():New("xFINR150","Posição Dos Títulos A Pagar","XFIN150   ",{|oReport| ReportPrint(oReport)},"Imprime a posição dos títulos a pagar relativo a data base do sistema.")

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)		//Imprime o total em linha

/*
GESTAO - inicio */
oReport:SetUseGC(.F.)
/* GESTAO - fim
*/

dbSelectArea("SX1")

pergunte("XFIN150",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros  ³
//³ mv_par01	  // do Numero 			  ³
//³ mv_par02	  // at‚ o Numero 		  ³
//³ mv_par03	  // do Prefixo			  ³
//³ mv_par04	  // at‚ o Prefixo		  ³
//³ mv_par05	  // da Natureza  	      ³
//³ mv_par06	  // at‚ a Natureza		  ³
//³ mv_par07	  // do Vencimento		  ³
//³ mv_par08	  // at‚ o Vencimento	  ³
//³ mv_par09	  // do Banco			  ³
//³ mv_par10	  // at‚ o Banco		  ³
//³ mv_par11	  // do Fornecedor		  ³
//³ mv_par12	  // at‚ o Fornecedor	  ³
//³ mv_par13	  // Da Emiss„o			  ³
//³ mv_par14	  // Ate a Emiss„o		  ³
//³ mv_par15	  // qual Moeda			  ³
//³ mv_par16	  // Imprime Provis¢rios  ³
//³ mv_par17	  // Reajuste pelo vencto ³
//³ mv_par18	  // Da data contabil	  ³
//³ mv_par19	  // Ate data contabil	  ³
//³ mv_par20	  // Imprime Rel anal/sint³
//³ mv_par21	  // Saldo retroativo?    ³
//³ mv_par22	  // Cons filiais abaixo ?³
//³ mv_par23	  // Filial de            ³
//³ mv_par24	  // Filial ate           ³
//³ mv_par25	  // Loja de              ³
//³ mv_par26	  // Loja ate             ³
//³ mv_par27 	  // Considera Adiantam.? ³
//³ mv_par28	  // Imprime Nome 		  ³
//³ mv_par29	  // Outras Moedas 		  ³
//³ mv_par30     // Imprimir os Tipos     ³
//³ mv_par31     // Nao Imprimir Tipos	  ³
//³ mv_par32     // Consid. Fluxo Caixa   ³
//³ mv_par33     // DataBase              ³
//³ mv_par34     // Tipo de Data p/Saldo  ³
//³ mv_par35     // Quanto a taxa		  ³
//³ mv_par36     // Tit.Emissao Futura	  ³
//³ mv_par37     // Seleciona filiais     ³
//³ mv_par38     // Considera Tit Exclu   ³
//³ mv_par39     // Considera Abatimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cPictTit := PesqPict("SE2","E2_VALOR")
If cPaisLoc == "CHI"
	cPictTit := SubStr(cPictTit,1,At(".",cPictTit)-1)
EndIf   

nTamVal	 := TamSX3("E2_VALOR")[1]
nTamCli	 := TamSX3("E2_FORNECE")[1] + TamSX3("E2_LOJA")[1] + 25
nTamTit	 := TamSX3("E2_PREFIXO")[1] + TamSX3("E2_NUM")[1] + TamSX3("E2_PARCELA")[1] + 8
nTamQueb := nTamCli + nTamTit + TamSX3("E2_TIPO")[1] + TamSX3("E2_NATUREZ")[1] + TamSX3("E2_EMISSAO")[1] +;
			TamSX3("E2_VENCTO")[1] + TamSX3("E2_VENCREA")[1] + 14
			
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Secao 1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ

//TRCell():New(/*oSection*/, /*X3_CAMPO*/, /*Tabela*/, /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

oSection1 := TRSection():New(oReport,"Títulos a paga",{"SE2","SA2"},aOrdem)

TRCell():New(oSection1,"ORACLE"     ,     ,"Oracle Code"           ,,       ,.F.,)  
TRCell():New(oSection1,"FORNECEDOR"	,     ,"Vendor - Name - Oracle",,       ,.F.,) 
TRCell():New(oSection1,"FORNECEDO"	,	  ,"Código-nome Do Fornecedor",,nTamCli,.F.,)  		//"Codigo-Nome do Fornecedor"
TRCell():New(oSection1,"TITULO"		,	  ,"Prf-Numero" +CRLF+"Parcela" ,,nTamTit,.F.,)  		//"Prf-Numero" + "Parcela"
TRCell():New(oSection1,"FORNECE"    ,     ,"Cod. Fornecedor"       ,,       ,.F.,)
TRCell():New(oSection1,"LOJAFOR"    ,     ,"Loja Fornecedor"       ,,       ,.F.,)
TRCell():New(oSection1,"E2_TIPO"	,"SE2","TP"				   ,,       ,.F.,)  				//"TP"
TRCell():New(oSection1,"E2_NATUREZ"	,"SE2","Natureza"				   ,,TamSX3("E2_NATUREZ")[1] + 5,.F.,)  				//"Natureza"
TRCell():New(oSection1,"VENDORNAME" ,""   ,"Microsiga Vendor Name" ,,       ,.F.,)  
TRCell():New(oSection1,"E2_EMISSAO"	,"SE2","Data de"+CRLF+"Emissao"	,,,.F.,) 				//"Data de" + "Emissao"
TRCell():New(oSection1,"E2_VENCTO"	,"SE2","Vencto"+CRLF+"Titulo"	,,,.F.,)  				//"Vencto" + "Titulo"
TRCell():New(oSection1,"E2_VENCREA"	,"SE2","Vencto"+CRLF+"Real"	,,,.F.,)  				//"Vencto" + "Real"
TRCell():New(oSection1,"VAL_ORIG"	,	  ,"Valor Original"				          ,cPictTit,nTamVal+3,.F.,) //"Valor Original"
TRCell():New(oSection1,"VAL_NOMI"	,	  ,"Tit Vencidos"+CRLF+"Valor Nominal"	  ,cPictTit,nTamVal+3,.F.,) //"Tit Vencidos" + "Valor Nominal" 
TRCell():New(oSection1,"VAL_CORR"	,	  ,"Tit Vencidos"+CRLF+"Valor Corrigido"  ,cPictTit,nTamVal+3,.F.,) //"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection1,"VAL_VENC"	,	  ,"Titulos a Vencer"+CRLF+"Valor Nominal",cPictTit,nTamVal+3,.F.,) //"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection1,"E2_VALOR"	,	  ,"Valor Bruto"        ,,,.F.,) //"IIF(E2_ORIGEM == "MATA100",POSICIONE("SF1", FINDBYDUPL, xFilial("SF1")+E2_NUM+E2_FORNECE+E2_LOJA, "F1_VALBRUT"), E2_VALOR+E2_IRRF+E2_ISS+E2_INSS)"
TRCell():New(oSection1,"E2_PORTADO"	,"SE2","Porta-"+CRLF+"dor"	,,,.F.,)  				//"Porta-" + "dor"
TRCell():New(oSection1,"JUROS"		,	  ,"Vlr.juros ou"+CRLF+"permanencia"	,cPictTit,nTamVal+3,.F.,) //"Vlr.juros ou" + "permanencia"
TRCell():New(oSection1,"DIA_ATR"	,	  ,"Dias" +CRLF+"Atraso"	,,4,.F.,)  				//"Dias" + "Atraso"
TRCell():New(oSection1,"RETIDO"		,	  ,"Impostos Retidos"   ,, ,.F.,)        //"E2_IRRF+E2_ISS+E2_INSS+E2_PIS+E2_CSLL+E2_COFINS"
TRCell():New(oSection1,"LIQUIDO"	,	  ,"Valor Liquido"      ,, ,.F.,)        //"E2_VALOR-E2_PIS-E2_CSLL-E2_COFINS-E2_DECRESC"
TRCell():New(oSection1,"E2_HIST"	,"SE2","Historico(Vencidos+Vencer)" ,,35,.F.,)  			//"Historico(Vencidos+Vencer)"
TRCell():New(oSection1,"E2_HIST"	,"SE2","PO NUMBER"	      			,,35,.F.,) 	//"(Vencidos+Vencer)"
TRCell():New(oSection1,"EXPENSE"	,"SE2","EXPENSE ACOUNT NUMBER"		,,35,.F.,) 	//"(Vencidos+Vencer)"
TRCell():New(oSection1,"E2_CODBAR"	,	  ,"BAR CODE"           ,, ,.F.,)
TRCell():New(oSection1,"DETALHES"	,	  ,"Bank Details"       ,, ,.F.,)  //SA2->(A2_BANCO+" "+A2_AGENCIA+" "+A2_NUMCON)
TRCell():New(oSection1,"TIPO"		,	  ,"Type"               ,, ,.F.,)  //STANDARD
TRCell():New(oSection1,"SITE"		,	  ,"Supplier Site"      ,, ,.F.,)  //SAO PAULO

oSection1:Cell("VAL_ORIG"):SetHeaderAlign("RIGHT")
oSection1:Cell("VAL_NOMI"):SetHeaderAlign("RIGHT")             
oSection1:Cell("VAL_CORR"):SetHeaderAlign("RIGHT")
oSection1:Cell("VAL_VENC"):SetHeaderAlign("RIGHT")
oSection1:Cell("JUROS")   :SetHeaderAlign("RIGHT")  
//oSection1:Cell("VAL_SOMA"):SetHeaderAlign("RIGHT") 

oSection1:SetLineBreak(.f.)		//Quebra de linha automatica

oSection2 := TRSection():New(oReport,"Títulos a pagar",{"SM0"},aOrdem)

TRCell():New(oSection2,"FILIAL"		,  ,"Total por Filial:",			,105) //"Total por Filial:"
TRCell():New(oSection2,"FILLER1"    ,"",                 "",            ,10,.F.,)
TRCell():New(oSection2,"VALORORIG"	,,"Valor Original"				,cPictTit	,nTamVal+3)//"Valor Original"
TRCell():New(oSection2,"VALORNOMI"	,,"Tit Vencidos"+CRLF+"Valor Nominal"	,cPictTit	,nTamVal+3)//"Tit Vencidos" + "Valor Nominal"
TRCell():New(oSection2,"VALORCORR"	,,"Tit Vencidos" +CRLF+"Valor Corrigido"	,cPictTit	,nTamVal+3)//"Tit Vencidos" + "Valor Corrigido"
TRCell():New(oSection2,"VALORVENC"	,,"Titulos a Vencer" +CRLF+"Valor Nominal"	,cPictTit	,nTamVal+3)//"Titulos a Vencer" + "Valor Nominal"
TRCell():New(oSection2,"JUROS"		,,"Vlr.juros ou"+CRLF+"permanencia"	,cPictTit	,nTamVal+5)//"Vlr.juros ou" + "permanencia"
TRCell():New(oSection2,"VALORSOMA"	,,"(Vencidos+Vencer)"				,cPictTit	,nTamVal+20)//"(Vencidos+Vencer)"

oSection2:Cell("VALORORIG"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALORNOMI"):SetHeaderAlign("RIGHT")             
oSection2:Cell("VALORCORR"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALORVENC"):SetHeaderAlign("RIGHT")
oSection2:Cell("JUROS"    ):SetHeaderAlign("RIGHT")  
oSection2:Cell("VALORSOMA"):SetHeaderAlign("RIGHT")

oSection2:SetLineBreak(.F.)

Return oReport                                                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Daniel Batori          ³ Data ³08.08.06	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oSection1	:=	oReport:Section(1) 
Local oSection2	:=	oReport:Section(2)
Local nOrdem 	:=  oSection1:GetOrder()
Local oBreak
Local oBreak2
Local aDados[26]
Local nRegEmp := SM0->(RecNo())
Local nRegSM0 := SM0->(Recno())
Local nAtuSM0 := SM0->(Recno())
Local dOldDtBase := dDataBase
Local dOldData := dDataBase
Local nJuros  :=0
Local nQualIndice := 0
Local lContinua := .T.
Local nTit0:=0,nTit1:=0,nTit2:=0,nTit3:=0,nTit4:=0,nTit5:=0
Local nTot0:=0,nTot1:=0,nTot2:=0,nTot3:=0,nTot4:=0,nTotTit:=0,nTotJ:=0,nTotJur:=0
LOcal nTotFil0:=0, nTotFil1:=0, nTotFil2:=0, nTotFil3:=0,nTotFil4:=0, nTotFilTit:=0, nTotFilJ:=0
Local nFil0:=0,nFil1:=0,nFil2:=0,nFil3:=0,nFil4:=0,nFilTit:=0,nFilJ:=0
Local cCond1,cCond2,cCarAnt,nSaldo:=0,nAtraso:=0
Local dDataReaj
Local dDataAnt := dDataBase , lQuebra
Local nMestit0:= nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
Local cIndexSe2
Local cChaveSe2
Local nIndexSE2
Local cFilDe,cFilAte
Local nTotsRec := SE2->(RecCount())
Local aTamFor := TAMSX3("E2_FORNECE")
Local nDecs := Msdecimais(mv_par15)
Local lFr150Flt := EXISTBLOCK("FR150FLT")
Local cFr150Flt := iif(lFr150Flt,ExecBlock("FR150FLT",.F.,.F.),"")
Local cMoeda    := LTrim(Str(mv_par15))
Local cFilterUser
Local cFilUserSA2 := oSection1:GetADVPLExp("SA2")

Local cNomFor	:= ""
Local cNomNat	:= ""
Local cNomFil	:= ""
Local cNumBco	:= ""
Local nTotVenc	:= 0
Local nTotMes	:= 0
Local nTotGeral := 0
Local nTotTitMes:= 0
Local nTotFil	:= 0
Local dDtVenc	:= CToD("  /  /    ")
Local aFiliais	:= {}
Local lTemCont := .F.
Local cNomFilAnt := ""
Local cFilialSE2	:= ""
Local nInc := 0    
Local aSM0 := {}
Local cPictTit := ""
Local nGerTot := 0
Local nFilTot := 0
Local nAuxTotFil := 0
Local nRecnoSE2 := 0
Local aTotFil :={}
local lQryEmp := .F.
Local nI := 0
Local dUltBaixa	:= STOD("")
Local nCont	:= 0
Local nTamFil	:= FWSizeFilial()
Local lExistFJU := FJU->(ColumnPos("FJU_RECPAI")) > 0 .and. FindFunction("FinGrvEx")
Local cCampos := ""
Local cQueryP := ""
Local aStru := SE2->(dbStruct())
Local nFilAtu		:= 0
Local nLenSelFil	:= 0
Local nTamUnNeg		:= 0
Local nTamEmp		:= 0
Local nTotEmp		:= 0
Local nTotEmpJ		:= 0
Local nTotEmp0		:= 0
Local nTotEmp1		:= 0
Local nTotEmp2		:= 0
Local nTotEmp3		:= 0
Local nTotEmp4		:= 0
Local nTotTitEmp	:= 0
Local cNomEmp		:= ""
Local cTmpFil		:= ""
Local cQryFilSE1	:= ""
Local cQryFilSE5	:= ""
Local lTotEmp		:= .F.
Local aTmpFil		:= {}
Local oBrkFil		:= Nil
Local oBrkEmp		:= Nil
Local oBrkNat		:= Nil
Local nBx			:= 0
Local lFValAcess	:= ExistFunc('FValAcess')
Local nVa			:= 0
Local lImprimeAb	:= Type("mv_par39") == "N" .and. mv_par39 == 1
Local lSemTaxaM2	:= .F.
Local nTaxaDia		:= 1

Private dBaixa  := dDataBase
Private cTitulo := ""

cPictTit := PesqPict("SE2","E2_VALOR")
If cPaisLoc == "CHI"
	cPictTit := SubStr(cPictTit,1,At(".",cPictTit)-1)
EndIf   

//Valida data base (mv_par33)
If Empty(mv_par33)
    Help(" ",1,'FINDTBASE',,"Data Base nao informada na parametrizacao do relatorio.",1,0,,,,,,{"Por favor, informe a data base nos parƒmetros do relatorio (pergunte)."} ) //"Data Base nao informada na parametrizacao do relatorio."  ###  "Por favor, informe a data base nos parƒmetros do relatorio (pergunte)."
    oReport:CancelPrint()
    Return
Endif

/*
GESTAO - inicio */
If MV_PAR37 == 1
	If Empty(aSelFil)
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("xFIN150",37,.F.,@aSelFil,"SE2",.F.)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SE2")
			If Empty(aSelFil)
				Aadd(aSelFil,cFilAnt)
			Endif
		Endif
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif
nLenSelFil := Len(aSelFil)
lTotFil := (nLenSelFil > 1)
nTamEmp := Len(FWSM0LayOut(,1))
nTamUnNeg := Len(FWSM0LayOut(,2))
lTotEmp := .F.
If nLenSelFil > 1
	nX := 1 
	While nX < nLenSelFil .And. !lTotEmp
		nX++
		lTotEmp := !(Substr(aSelFil[nX-1],1,nTamEmp) == Substr(aSelFil[nX],1,nTamEmp))
	Enddo
Else
	nTotTmp := .F.
Endif
cQryFilSE2 := GetRngFil( aSelFil, "SE2", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
cQryFilSE5 := GetRngFil( aSelFil, "SE5", .T., @cTmpFil)
Aadd(aTmpFil,cTmpFil)
/* GESTAO - fim
*/

//*******************************************************
// Solução para o problema no filtro de Serie minuscula *
//*******************************************************
//mv_par04 := LOWER(mv_par04)

oSection1:Cell("FORNECEDO"	):SetBlock( { || aDados[FORNEC] 			})
oSection1:Cell("FORNECE"	):SetBlock( { || aDados[CODFORN]			})
oSection1:Cell("LOJAFOR"	):SetBlock( { || aDados[LOJFORN] 			})
oSection1:Cell("VENDORNAME"	):SetBlock( { || aDados[MICROVE] 			})
oSection1:Cell("TITULO"		):SetBlock( { || aDados[TITUL] 				})
oSection1:Cell("E2_TIPO"	):SetBlock( { || aDados[TIPO] 				})
oSection1:Cell("E2_NATUREZ"	):SetBlock( { || MascNat(aDados[NATUREZA])  })
oSection1:Cell("E2_EMISSAO"	):SetBlock( { || aDados[EMISSAO] 			})
oSection1:Cell("E2_VENCTO"	):SetBlock( { || aDados[VENCTO] 			})
oSection1:Cell("E2_VENCREA"	):SetBlock( { || aDados[VENCREA] 			})
oSection1:Cell("VAL_ORIG"	):SetBlock( { || aDados[VL_ORIG] 			})
oSection1:Cell("VAL_NOMI"	):SetBlock( { || aDados[VL_NOMINAL] 		})
oSection1:Cell("VAL_CORR"	):SetBlock( { || aDados[VL_CORRIG] 	    	})
oSection1:Cell("VAL_VENC"	):SetBlock( { || aDados[VL_VENCIDO] 		})
oSection1:Cell("E2_PORTADO"	):SetBlock( { || aDados[PORTADOR] 			})
oSection1:Cell("JUROS"		):SetBlock( { || aDados[VL_JUROS] 			})
oSection1:Cell("DIA_ATR"	):SetBlock( { || aDados[ATRASO] 			})
oSection1:Cell("E2_HIST"	):SetBlock( { || aDados[HISTORICO] 			})
oSection1:Cell("TIPO"		):SetBlock( { || "STANDARD" 		        }) 
oSection1:Cell("SITE"		):SetBlock( { || "SAO PAULO" 			    })
oSection1:Cell("E2_CODBAR"  ):SetBlock( { || aDados[CODBARR]            })
oSection1:Cell("DETALHES"   ):SetBlock( { || aDados[DETALHE]            })
oSection1:Cell("LIQUIDO"    ):SetBlock( { || aDados[VLRLIQD]            })
oSection1:Cell("E2_VALOR"   ):SetBlock( { || aDados[VLRBRUT]            })
oSection1:Cell("RETIDO"     ):SetBlock( { || aDados[VLRRETI]            })

//oSection1:Cell("VAL_SOMA"	):SetBlock( { || aDados[VL_SOMA] 			})

//oSection1:Cell("VAL_SOMA"):Disable()

TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as quebras da seção, conforme a ordem escolhida.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 2	//Natureza
	oBreak := TRBreak():New(oSection1,{|| IIf(!MV_MULNATP,SE2->E2_NATUREZ,aDados[NATUREZA]) },{|| cNomNat })
	oBrkNat := oBreak
ElseIf nOrdem == 3	.Or. nOrdem == 6	//Vencimento e por Emissao
	oBreak  := TRBreak():New(oSection1,{|| IIf(nOrdem == 3,SE2->E2_VENCREA,SE2->E2_EMISSAO) },{|| "S u b - total ----> " + DtoC(dDtVenc) })	//"S U B - T O T A L ----> "
	oBreak2 := TRBreak():New(oSection1,{|| IIf(nOrdem == 3,Month(SE2->E2_VENCREA),Month(SE2->E2_EMISSAO)) },{|| "T o t a l   d o  m ê s ---> " + "("+ALLTRIM(STR(nTotTitMes))+" "+IIF(nTotTitMes > 1,OemToAnsi("Movimentos"),OemToAnsi("Título"))+")" })		//"T O T A L   D O  M E S ---> "
	If mv_par20 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak2,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak2,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport, nTotGeral, nTotMes)},.F.,.F.)
	EndIf
ElseIf nOrdem == 4	//Banco
	oBreak := TRBreak():New(oSection1,{|| SE2->E2_PORTADO },{|| "S u b - total ----> " + cNumBco })	//"S U B - T O T A L ----> "
ElseIf nOrdem == 5	//Fornecedor
	oBreak := TRBreak():New(oSection1,{|| SE2->(E2_FORNECE+E2_LOJA) },{|| cNomFor })
ElseIf nOrdem == 7	//Codigo Fornecedor
	oBreak := TRBreak():New(oSection1,{|| SE2->E2_FORNECE },{|| cNomFor })	
EndIf                                                                       


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimir TOTAL por filial somente quando ³
//³ houver mais do que uma filial.	         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SM0->(Reccount()) > 1 .And. nLenSelFil > 1
	If nOrdem  == 3 .Or. nOrdem == 6
		oSection2:Cell("FILIAL"	)	:SetBlock( { || aTotFil[ni,1] + aTotFil[ni,9]})
		oSection2:Cell("VALORORIG")	:SetBlock( { || aTotFil[ni,2]})
		oSection2:Cell("VALORNOMI")	:SetBlock( { || aTotFil[ni,3]})
		oSection2:Cell("VALORCORR")	:SetBlock( { || aTotFil[ni,4]})
		oSection2:Cell("VALORVENC")	:SetBlock( { || aTotFil[ni,5]})
		oSection2:Cell("JUROS")		:SetBlock( { || aTotFil[ni,8]})
		oSection2:Cell("VALORSOMA")	:SetBlock( { || aTotFil[ni,4] + aTotFil[ni,5]})

		TRPosition():New(oSection2,"SM0",1,{|| xFilial("SM0")+SM0->M0_CODIGO+	SM0->M0_CODFIL })
	Else
		oBreak2 := TRBreak():New(oSection1,{|| SE2->E2_FILIAL },{|| "Total   f i l i a l --->"+" "+cNomFil })	//"T O T A L   F I L I A L ----> " 
		If mv_par20 == 1	//1- Analitico  2-Sintetico
			TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak2,,,,.F.,.F.)
			TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak2,,,,.F.,.F.)
			//nTotGeral nao estava imprimindo corretamente o totalizador por isso foi necessario o ajuste abaixo
			//embora seja estranho mas neste caso foi necessario inicializar a variavel nFilTot:=0 no break 
			//por isso salvei o conteudo na variavel nAuxTotFil antes de inicializar e depois imprimo nAuxTotFil
			TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak2,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport, ( nAuxTotFil:=nFilTot,nFilTot:=0,nAuxTotFil )/*nTotGeral*/, nTotFil)},.F.,.F.)
		EndIf
	EndIf 
EndIf

cLinha := "Código-Nome do Fornecedor PRF-Número           Tp  Natureza   Data de    Vencto     Vencto      Valor Original|        Títulos vencidos         | Títulos a vencer | Porta-| Vlr.juros ou  Dias   Hist.(Vds+Venc.)"

/*
GESTAO - inicio */
/* quebra por empresa */
If lTotEmp .And. MV_MULNATP .And. nOrdem == 2 
	oBrkEmp := TRBreak():New(oSection1,{|| Substr(SE2->E2_FILIAL,1,nTamEmp)},{|| cLinha + " " + cNomEmp })		//"T O T A L  E M P R E S A -->" 
	// "Salta pagina por cliente?" igual a "Sim" e a ordem eh por cliente ou codigo do cliente
/*	If mv_par35 == 1 .And. (nOrdem == 1 .Or. nOrdem == 8)
		oBrkEmp:OnPrintTotal( { || oReport:EndPage() } )	// Finaliza pagina atual
	Else
		oBrkEmp:OnPrintTotal( { || oReport:SkipLine()} )
	EndIf*/
	If mv_par20 == 1	//1- Analitico  2-Sintetico
		TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBrkEmp,,,,.F.,.F.)
		TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBrkEmp,,,,.F.,.F.)
		//TRFunction():New(oSection1:Cell("VAL_SOMA"),"","ONPRINT",oBrkEmp,,PesqPict("SE2","E2_VALOR"),{|lSection,lReport| If(lReport, nTotGeral, nTotEmp)},.F.,.F.)
	EndIf
Endif
/* GESTAO - fim 
*/

If mv_par20 == 1	//1- Analitico  2-Sintetico
	//Altero o texto do Total Geral
	oReport:SetTotalText({|| "Total crial ----> " + "(" + ALLTRIM(STR(nTotTit))+" "+If(nTotTit > 1,"Movimentos","Título")+")" })
	TRFunction():New(oSection1:Cell("VAL_ORIG"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_NOMI"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_CORR"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VAL_VENC"),"","SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("JUROS"	  ),"","SUM",oBreak,,,,.F.,.T.)
	//nTotGeral nao estava imprimindo corretamente o totalizador por isso foi necessario o ajuste abaixo
	//portanto foi criado a variavel nGerTot que eh o acumulador geral da coluna
	TRFunction():New(oSection1:Cell("E2_HIST"),"","ONPRINT",oBreak,,Iif(cPaisLoc == "CHI",cPictTit, PesqPict("SE2","E2_VALOR")),{|lSection,lReport| If(lReport,Iif(nOrdem==2,nTotGeral,nGerTot), nTotVenc)},.F.,.T.)
EndIf

dbSelectArea ( "SE2" )
Set Softseek On

If mv_par37 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
Endif

//Acerta a database de acordo com o parametro
dDataBase := mv_par33

dbSelectArea("SM0")

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

//Caso nao preencha o mv_par15 um erro ocorre ao procurar o parametro do sistema MV_MOEDA0.
If Val(cMoeda) == 0
	cMoeda := "1"
Endif

cTitulo := oReport:title()
cTitAux := cTitulo

cTitulo += " " + "Não imprimir tipos" + GetMv("MV_MOEDA"+cMoeda)  //"Posicao dos Titulos a Pagar" + " em "

// Cria vetor com os codigos das filiais da empresa corrente                     
aFiliais := FinRetFil()

oSection1:Init()      

aSM0	:= AdmAbreSM0()

/*
GESTAO - inicio */
If nLenSelFil == 0
	// Cria vetor com os codigos das filiais da empresa corrente
	aFiliais := FinRetFil()
	lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
Else
	aFiliais := Aclone(aSelFil)
	cFilDe := aSelFil[1]
	cFilAte := aSelFil[nLenSelFil]
	nFilAtu := 1
	lContinua := nFilAtu <= nLenSelFil
	aSM0 := FWLoadSM0()
Endif
/* GESTAO - fim 
*/

nInc := 1

While nInc <= Len( aSM0 )
	
	If !Empty(cFilAte) .AND. aSM0[nInc][1] == cEmpAnt .AND. (aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte) .and. lContinua
		
		//UTILIZADO PARA VALIDAR AS FILIAIS SELECIONADAS PELO USUARIO.
		If Ascan(aSelFil,aSM0[nInc][2]) == 0
			nInc++
			Loop						
		Endif
		
		dbSelectArea("SE2")
		/*
		GESTAO - inicio */
		If nLenSelFil > 0
			nPosFil := aScan( aSM0 ,{ | sm0 | sm0[SM0_GRPEMP] + sm0[SM0_CODFIL] == aSM0[nInc][1] + aSelFil[nFilAtu] } )
			If nPosFil > 0
				SM0->( DbGoTo( aSM0[nPosFil,SM0_RECNO] ) )
			Else
				SM0->( MsSeek( cEmpAnt + aSelFil[nFilAtu] ) )
			EndIf
		EndIf
		cFilAnt := aSM0[nInc][2]
		/* GESTAO - fim
		*/ 
		
		IF cFilialSE2 == cFilAnt
			nInc++
			Loop
		ELSE
			cFilialSE2 := cFilAnt
		ENDIF
			
		cFilterUser := oSection1:GetSqlExp("SE2")
		If TcSrvType() != "AS/400"
			cQueryP := ""
			cCampos := ""
			aEval(SE2->(DbStruct()),{|e| If(e[2]<> "M", cCampos += ",SE2."+AllTrim(e[1]),Nil)})
			cCampos += ",SE2.R_E_C_N_O_, SE2.R_E_C_D_E_L_, SE2.D_E_L_E_T_ " 
			cQuery := "SELECT " + SubStr(cCampos,2)
			cQuery += "  FROM "+	RetSqlName("SE2")+ " SE2"
			cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
			cQuery += "   AND D_E_L_E_T_ = ' ' " 
			If !empty(cFilterUser)
				cQueryP += " AND ( "+cFilterUser + " ) "
			Endif
		Endif
	
		IF nOrdem == 1
			SE2->(dbSetOrder(1))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_PREFIXO <= mv_par04"
			cCond2 := "SE2->E2_PREFIXO"
			cTitulo += OemToAnsi(" - Por Numero")  //" - Por Numero"
			nQualIndice := 1
		Elseif nOrdem == 2
			SE2->(dbSetOrder(2))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_NATUREZ <= mv_par06"
			cCond2 := "SE2->E2_NATUREZ"
			cTitulo += " - Por Natureza"  //" - Por Natureza"
			nQualIndice := 2
		Elseif nOrdem == 3
			SE2->(dbSetOrder(3))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_VENCREA <= mv_par08"
			cCond2 := "SE2->E2_VENCREA"
			cTitulo += " - Por Vencimento"  //" - Por Vencimento"
			nQualIndice := 3
		Elseif nOrdem == 4
			SE2->(dbSetOrder(4))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_PORTADO <= mv_par10"
			cCond2 := "SE2->E2_PORTADO"
			cTitulo += OemToAnsi(" - Por Banco")  //" - Por Banco"
			nQualIndice := 4
		Elseif nOrdem == 6
			SE2->(dbSetOrder(5))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_EMISSAO <= mv_par14"
			cCond2 := "SE2->E2_EMISSAO"
			cTitulo += " - Por Emissao" //" - Por Emissao"
			nQualIndice := 5
		Elseif nOrdem == 7
			SE2->(dbSetOrder(6))
			cOrder := SqlOrder(indexkey())
			cCond1 := "SE2->E2_FORNECE <= mv_par12"
			cCond2 := "SE2->E2_FORNECE"
			cTitulo += " - Por Cod.Fornecedor" //" - Por Cod.Fornecedor"
			nQualIndice := 6
		Else
			cChaveSe2 := "E2_FILIAL+E2_NOMFOR+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
			cOrder := SqlOrder(cChaveSe2)
			cCond1 := "SE2->E2_FORNECE <= mv_par12"
			cCond2 := "SE2->E2_FORNECE+SE2->E2_LOJA"
			cTitulo += " - Por Fornecedor" //" - Por Fornecedor"
			nQualIndice := IndexOrd()
		EndIF
	
		If mv_par20 == 1	//1- Analitico  2-Sintetico	
			cTitulo += " - Analitico"  //" - Analitico"
		Else
			cTitulo += " - Sintetico"  // " - Sintetico"
		EndIf
	
		oReport:SetTitle(cTitulo)
		cTitulo := cTitAux
		
		dbSelectArea("SE2")
	
		Set Softseek Off

		cQueryP += " AND SE2.E2_NUM     BETWEEN '"+ mv_par01+ "' AND '"+ mv_par02 + "'"
		cQueryP += " AND SE2.E2_PREFIXO BETWEEN '"+ mv_par03+ "' AND '"+ mv_par04 + "'"
		cQueryP += " AND SE2.E2_NATUREZ BETWEEN '"+ mv_par05+ "' AND '"+ mv_par06 + "'"
		cQueryP += " AND SE2.E2_VENCREA BETWEEN '"+ DTOS(mv_par07)+ "' AND '"+ DTOS(mv_par08) + "'"
		cQueryP += " AND SE2.E2_PORTADO BETWEEN '"+ mv_par09+ "' AND '"+ mv_par10 + "'"
		cQueryP += " AND SE2.E2_FORNECE BETWEEN '"+ mv_par11+ "' AND '"+ mv_par12 + "'"
		cQueryP += " AND SE2.E2_EMISSAO BETWEEN '"+ DTOS(mv_par13)+ "' AND '"+ DTOS(mv_par14) + "'"
		cQueryP += " AND SE2.E2_EMIS1   BETWEEN '"+ DTOS(mv_par18)+ "' AND '"+ DTOS(mv_par19) + "'"		
		cQueryP += " AND SE2.E2_LOJA    BETWEEN '"+ mv_par25 + "' AND '"+ mv_par26 + "'"
		//Considerar titulos cuja emissao seja maior que a database do sistema
		If mv_par36 == 2
			cQueryP += " AND SE2.E2_EMISSAO <= '" + DTOS(dDataBase) +"'"
		Endif

		If !Empty(mv_par30) // Deseja imprimir apenas os tipos do parametro 30
			cQueryP += " AND SE2.E2_TIPO IN "+FormatIn(mv_par30,";") 
		ElseIf !Empty(mv_par31) // Deseja excluir os tipos do parametro 31
			cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(mv_par31,";")
		EndIf

		If mv_par32 == 1
			cQueryP += " AND SE2.E2_FLUXO != 'N'"
		Endif

		If !lImprimeAb
			cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")
		EndIf

		If mv_par16 == 2
			cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVPROVIS,";")			
		Endif
		
		If mv_par27 == 2
			cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")			 
			cQueryP += " AND SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG,"|")			
		Endif		

		IF mv_par34 == 2 .And. !Empty(mv_par33)
			cQueryP += " AND SE2.E2_EMIS1 <= '" + DTOS(mv_par33) +"'"
		Endif

		//verifica moeda do campo=moeda parametro
		If mv_par29 == 2 // nao imprime
			cQueryP += " AND SE2.E2_MOEDA = " + Alltrim(Str(mv_par15))
		Endif  

		// Metodo de seleção de Filiais, considerando que o MV_PAR37 (Selecione Filiais) e mais forte que o MV_PAR22 (Considera Filiais a Baixo?)
		If  mv_par37 == 1 // Caso Selecione Filiais = Sim
			cQueryP += " AND SE2.E2_FILORIG   = '"+cFilAnt+ "'"	
		ElseIf MV_PAR22 == 1 // Considerar Filiais a baixo ? = Sim 
			cQueryP += " AND SE2.E2_FILORIG   BETWEEN '"+mv_par23+ "' AND '"+mv_par24+ "'"				
		Endif

		cQuery += cQueryP
		If lExistFJU
			If MV_PAR38 == 1
				cQuery += " AND SE2.R_E_C_N_O_ NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
				cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
				cQuery += " PAI.FJU_CART = 'P' AND "
				cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
				cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "			    		
				cQuery += "UNION "
				
				cQuery += "SELECT " + SubStr(cCampos,2)
				cQuery += " FROM "+ RetSqlName("SE2")+" SE2,"+ RetSqlName("FJU") +" FJU"
				cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
				cQuery += " AND FJU.FJU_FILIAL	 = '" + xFilial("FJU") + "'"
				cQuery += " AND SE2.E2_PREFIXO 	= FJU.FJU_PREFIX "
				cQuery += " AND SE2.E2_NUM 		= FJU.FJU_NUM "
				cQuery += " AND SE2.E2_PARCELA 	= FJU.FJU_PARCEL "
				cQuery += " AND SE2.E2_TIPO 	= FJU.FJU_TIPO "
				cQuery += " AND SE2.E2_FORNECE	= FJU.FJU_CLIFOR "
				cQuery += " AND SE2.E2_LOJA 	= FJU.FJU_LOJA "
				cQuery += " AND FJU.FJU_EMIS   <= '" + DTOS(dDataBase) +"'"
				cQuery += " AND FJU.FJU_DTEXCL >= '" + DTOS(dDataBase) +"'"
				cQuery += " AND FJU.FJU_CART = 'P' "
				cQuery += " AND SE2.R_E_C_N_O_ = FJU.FJU_RECORI "
				cQuery += " AND FJU.FJU_RECORI IN ( SELECT MAX(FJU_RECORI) "

				cQuery +=   "FROM "+ RetSqlName("FJU")+" LASTFJU "
				cQuery +=   "WHERE LASTFJU.FJU_FILIAL = FJU.FJU_FILIAL "
				cQuery +=   "AND LASTFJU.FJU_PREFIX = FJU.FJU_PREFIX "
				cQuery +=   "AND LASTFJU.FJU_NUM = FJU.FJU_NUM "
				cQuery +=   "AND LASTFJU.FJU_PARCEL = FJU.FJU_PARCEL "
				cQuery +=   "AND LASTFJU.FJU_TIPO = FJU.FJU_TIPO "
				cQuery +=   "AND LASTFJU.FJU_CLIFOR = FJU.FJU_CLIFOR "
				cQuery +=   "AND LASTFJU.FJU_LOJA = FJU.FJU_LOJA "	
				cQuery +=   "AND FJU.FJU_DTEXCL = LASTFJU.FJU_DTEXCL "
					
				cQuery +=   "GROUP BY FJU_FILIAL "
				cQuery +=   ",FJU_PREFIX "
				cQuery +=   ",FJU_NUM "
				cQuery +=   ",FJU_PARCEL "
				cQuery +=   ",FJU_CLIFOR "
				cQuery +=   ",FJU_LOJA ) "

				cQuery += " AND SE2.D_E_L_E_T_ = '*' " 
				cQuery += " AND FJU.D_E_L_E_T_ = ' ' " 
				
				cQuery += " AND " 
				cQuery += " (SELECT COUNT(*) " 
				cQuery += " FROM "+ RetSqlName("SE2")+" NOTDEL " 
				cQuery += " WHERE NOTDEL.E2_FILIAL = FJU.FJU_FILIAL "         
				cQuery += " AND NOTDEL.E2_PREFIXO = FJU.FJU_PREFIX     "      
				cQuery += " AND NOTDEL.E2_NUM = FJU.FJU_NUM            "
				cQuery += " AND NOTDEL.E2_PARCELA = FJU.FJU_PARCEL      "        
				cQuery += " AND NOTDEL.E2_TIPO = FJU.FJU_TIPO "        
				cQuery += " AND NOTDEL.E2_FORNECE = FJU.FJU_CLIFOR       "     
				cQuery += " AND NOTDEL.E2_LOJA = FJU.FJU_LOJA  	"
				cQuery += " AND FJU.FJU_RECPAI = 0 "
				cQuery += " AND NOTDEL.E2_EMIS1   <= '" + DTOS(dDataBase) +"'"
				cQuery += " AND NOTDEL.D_E_L_E_T_ = '') = 0 " 
					
				cQuery += " AND FJU.FJU_RECORI NOT IN (SELECT PAI.FJU_RECPAI FROM "+ RetSqlName("FJU")+" PAI " 
				cQuery += " WHERE PAI.D_E_L_E_T_ = ' ' AND "
				cQuery += " PAI.FJU_CART = 'P' AND "
				cQuery += " PAI.FJU_DTEXCL >= '" + DTOS(dDataBase) + "' "
				cQuery += " AND PAI.FJU_EMIS1 <= '" + DTOS(dDataBase) + "') "			    		
					
				cQuery += cQueryP
			Endif	
		Endif									

		cQuery += " ORDER BY "+ cOrder

		cQuery := ChangeQuery(cQuery)	
		dbSelectArea("SE2")
		dbCloseArea()
		dbSelectArea("SA2")

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
		
		oReport:SetMeter(nTotsRec)	
		
		If MV_MULNATP .And. nOrdem == 2
			If dDataBase > SE2->E2_VENCREA 		//vencidos 
				dBaixa := dDataBase
			EndIf
			
			//GESTAO - inicio
			If nLenSelFil == 0
				Finr155(cFr150Flt, .F., @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ, oReport, aDados, @cNomNat, @nTotVenc, @nTotGeral)
			Else
				cTitBkp := cTitulo
				Finr155(cFr150Flt, .F., @nTotFil0, @nTotFil1, @nTotFil2, @nTotFil3, @nTotFilTit, @nTotFilJ, oReport, aDados, @cNomNat, @nTotVenc, @nTotGeral)
				nTot0 += nTotFil0
				nTot1 += nTotFil1
				nTot2 += nTotFil2
				nTot3 += nTotFil3
				nTot4 += nTotFil4
				nTotJ += nTotFilJ
				nTotTit += nTotFilTit
				cNomFil := cFilAnt + " - " + AllTrim(SM0->M0_FILIAL)
				cNomEmp := Substr(cFilAnt,1,nTamEmp) + " - " + AllTrim(SM0->M0_NOMECOM)
				cTitulo := cTitBkp
			Endif
			//GESTAO - fim
			
			dbSelectArea("SE2")
			dbCloseArea()
			ChKFile("SE2")
			dbSetOrder(1)
			
			//GESTAO - inicio
			If nLenSelFil == 0
				dbSelectArea("SM0")
				dbSkip()
				lContinua := SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
			Else
				nFilAtu++
				lContinua := (nFilAtu <= nLenSelFil)
				If lContinua
					If oBrkNat:Execute()
						oBrkNat:PrintTotal()
					Endif
					If nTotFil0 <> 0
						oBrkFil := oBreak
						If oBrkFil:Execute()
							oBrkFil:PrintTotal()
						Endif
					Endif
					Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
					If !(Substr(aSelFil[nFilAtu-1],1,nTamEmp) == Substr(aSelFil[nFilAtu],1,nTamEmp))
						If nTotEmp0 <> 0
							oBrkEmp:PrintTotal()
						Endif
						nTotEmp0 := 0
						nTotEmp1 := 0
						nTotEmp2 := 0
						nTotEmp3 := 0
						nTotEmp4 := 0
						nTotEmpJ := 0
						nTotTitEmp := 0
					Endif
				Endif
			Endif
			
			//GESTAO - fim
			If Empty(xFilial("SE2")) .and. mv_par22 = 2
				Exit
			Endif
			
			nInc ++
			Loop
		Endif  
		
		lQryEmp := Eof()
		
		While &cCond1 .and. !Eof() .and. lContinua .and. SE2->E2_FILIAL == xFilial("SE2")
		
			oReport:IncMeter()
	
			dbSelectArea("SE2")
	
			Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
	
			If nOrdem == 3 .And. Str(Month(SE2->E2_VENCREA)) <> Str(Month(dDataAnt))
				nMesTTit := 0
			Elseif nOrdem == 6 .And. Str(Month(SE2->E2_EMISSAO)) <> Str(Month(dDataAnt))
				nMesTTit := 0
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega data do registro para permitir ³
			//³ posterior analise de quebra por mes.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
			cCarAnt := &cCond2
	        
			lTemCont := .F.

			While &cCond2 == cCarAnt .and. !Eof() .and. lContinua .and. SE2->E2_FILIAL == xFilial("SE2")
				
				oReport:IncMeter()
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtro de usuário pela tabela SA2.					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SA2")
				MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				If !Empty(cFilUserSA2).And.!SA2->(&cFilUserSA2)
					SE2->(dbSkip())
					Loop
				Endif
				
				dbSelectArea("SE2")
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera filtro do usuario no ponto de entrada.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFr150flt
					If &cFr150flt
						DbSkip()
						Loop
					Endif
				Endif					
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se titulo, apesar do E2_SALDO = 0, deve aparecer ou ³
				//³ nÆo no relat¢rio quando considera saldo retroat. (mv_par21=1)³
				//³ ou caso nÆo se considere a database, se o titulo foi totalmen³
				//³ te baixado.																  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE2")
				IF !Empty(SE2->E2_BAIXA) .and. Iif(mv_par21 == 2 ,SE2->E2_SALDO == 0 ,SE2->E2_SALDO == 0 .and. SE2->E2_BAIXA <= dDataBase)						
					dbSkip()
					Loop
				EndIF
	            
				 // Tratamento da correcao monetaria para a Argentina
				If  cPaisLoc=="ARG" .And. mv_par15 <> 1  .And.  SE2->E2_CONVERT == 'N'
					dbSkip()
					Loop
				Endif
	
				dbSelectArea("SA2")
				MSSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				dbSelectArea("SE2")
	
				// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
				If SE2->E2_VENCREA < dDataBase
					If mv_par17 == 2 .And. RecMoeda(SE2->E2_VENCREA,cMoeda) > 0
						dDataReaj := SE2->E2_VENCREA
					Else
						dDataReaj := dDataBase
					EndIf	
				Else
					dDataReaj := dDataBase
				EndIf       

				lSemTaxaM2 := ( nTaxaDia := RecMoeda(dDataReaj,SE2->E2_MOEDA) ) == 0
				
				If mv_par21 == 1
					nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par15,dDataReaj,,SE2->E2_LOJA,,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)),IIF(mv_par34 == 2,3,1)) // 1 = DT BAIXA    3 = DT DIGIT
					//Verifica se existem compensações em outras filiais para descontar do saldo, pois a SaldoTit() somente
					//verifica as movimentações da filial corrente. Nao deve processar quando existe somente uma filial.
					If !Empty(xFilial("SE2")) .And. !Empty(xFilial("SE5"))
						nSaldo -= FRVlCompFil("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,IIF(mv_par34 == 2,3,1),,,,mv_par15,SE2->E2_MOEDA,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)),dDataReaj,.T.)
					EndIf
					// Subtrai decrescimo para recompor o saldo na data escolhida.
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_DECRESC > 0 .And. SE2->E2_SDDECRE == 0
						nSAldo -= SE2->E2_DECRESC
					Endif	
					// Soma Acrescimo para recompor o saldo na data escolhida.
					If Str(SE2->E2_VALOR,17,2) == Str(nSaldo,17,2) .And. SE2->E2_ACRESC > 0 .And. SE2->E2_SDACRES == 0
						nSAldo += SE2->E2_ACRESC
					Endif				
				Else
					nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par15,dDataReaj,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
				Endif
				
				If nSaldo == 0 .and. !EMPTY(SE2->E2_MOVIMEN)
					SE2->(DBSKIP())
					LOOP
				EndIf
				
				If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. !(SE2->E2_TIPO $ MVABATIM) .And. !lImprimeAb .And.;
				   !( MV_PAR21 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
	
					//Quando considerar Titulos com emissao futura, eh necessario
					//colocar-se a database para o futuro de forma que a Somaabat()
					//considere os titulos de abatimento
					If mv_par36 == 1
						dOldData := dDataBase
						dDataBase := CTOD("31/12/40")
					Endif
	
					nSaldo-=SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",mv_par15,dDataReaj,SE2->E2_FORNECE,SE2->E2_LOJA)
	
					If mv_par36 == 1
						dDataBase := dOldData
					Endif
				EndIf

				nSaldo := Round(NoRound(nSaldo,3),2)
				
				aDados[FORNEC]   := SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"-"+If(mv_par28 == 1, SA2->A2_NREDUZ, SA2->A2_NOME)
				aDados[MICROVE]  := SA2->A2_NREDUZ
 				aDados[CODFORN]  := SE2->E2_FORNECE 
 				aDados[LOJFORN]  := SE2->E2_LOJA
				aDados[TITUL]	 := SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA
				aDados[TIPO]	 := SE2->E2_TIPO
				aDados[NATUREZA] := SE2->E2_NATUREZ
				aDados[EMISSAO]  := SE2->E2_EMISSAO
				aDados[VENCTO] 	 := SE2->E2_VENCTO
				aDados[VENCREA]  := SE2->E2_VENCREA
				aDados[CODBARR]  := SE2->E2_CODBAR
				aDados[DETALHE]  := SA2->(A2_BANCO+" "+A2_AGENCIA+" "+A2_NUMCON)
				aDados[VLRLIQD]  := SE2->(E2_VALOR-E2_PIS-E2_CSLL-E2_COFINS-E2_DECRESC)
				aDados[VLRBRUT]  := IIF(E2_ORIGEM == "MATA100",POSICIONE("SF1", FINDBYDUPL, xFilial("SF1")+E2_NUM+E2_FORNECE+E2_LOJA, "F1_VALBRUT"), E2_VALOR+E2_IRRF+E2_ISS+E2_INSS)
                aDados[VLRRETI]  := SE2->(E2_IRRF+E2_ISS+E2_INSS+E2_PIS+E2_CSLL+E2_COFINS)

				If SE2->E2_TIPO $ MVABATIM .and. nSaldo > 0
					aDados[VL_ORIG]	:= xMoeda(SE2->E2_VALOR * -1,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia))) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) 
					nSaldo := nSaldo * -1	// Garante que valor de abatimento sera subtraido e nao somado
				Else
					aDados[VL_ORIG]	:= xMoeda( SE2->E2_VALOR , SE2->E2_MOEDA , mv_par15 , SE2->E2_EMISSAO , ndecs+1 , If( mv_par35 == 1 , SE2->E2_TXMOEDA , If( lSemTaxaM2 , 1 , nTaxaDia )),  If( SE2->E2_TXMOEDA <> 0, SE2->E2_TXMOEDA, RecMoeda( dDataReaj , mv_par15 )) ) * If( SE2->E2_TIPO $ MV_CPNEG + "/" + MVPAGANT , -1 , 1 ) 
				EndIf
	
				If dDataBase > SE2->E2_VENCREA 		//vencidos
					aDados[VL_NOMINAL] := "" //nSaldo * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1) 
					nJuros := 0
					dBaixa := dDataBase
					
					// Cálculo dos Juros retroativo.
					dUltBaixa := SE2->E2_BAIXA
					If MV_PAR21 == 1 // se compoem saldo retroativo verifico se houve baixas
						If !Empty(dUltBaixa) .And. dDataBase < dUltBaixa
							dUltBaixa := FR150DBX() // Ultima baixa até DataBase
						EndIf
					EndIf
					
					dbSelectArea("SE2")
					nJuros := fa080Juros(mv_par15,nSaldo,"SE2",dUltBaixa)

					nVa := If(lFValAcess, FValAcess(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, !Empty(SE2->E2_BAIXA), "", "P",,, SE2->E2_MOEDA, mv_par15, SE2->E2_TXMOEDA), 0)
					If nVa > 0
						nJuros += nVa
					EndIf

					dbSelectArea("SE2")
					aDados[VL_CORRIG] := "" //(nSaldo+nJuros) * If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1)
					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nTit1 -= nSaldo
						nTit2 -= nSaldo+nJuros
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nMesTit1 -= nSaldo
						nMesTit2 -= nSaldo+nJuros
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nTit1 += nSaldo
						nTit2 += nSaldo+nJuros
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nMesTit1 += nSaldo
						nMesTit2 += nSaldo+nJuros
					Endif
					nTotJur += (nJuros)
					nMesTitJ += (nJuros)
				Else				  //a vencer
					nVa := If(lFValAcess, FValAcess(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, !Empty(SE2->E2_BAIXA), "", "R",,, SE2->E2_MOEDA, mv_par15, SE2->E2_TXMOEDA), 0)
					aDados[VL_VENCIDO] := ""  //(nSaldo * If(SE2->E2_TIPO $ MV_CPNEG + "/" + MVPAGANT, -1, 1)) + nVa

					If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
						nTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nTit3 -= nSaldo + nVa
						nTit4 -= nSaldo + nVa
						nMesTit0 -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nMesTit3 -= nSaldo + nVa
						nMesTit4 -= nSaldo + nVa
					Else
						nTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nTit3 += nSaldo
						nTit4 += nSaldo
						nMesTit0 += xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,mv_par15,SE2->E2_EMISSAO,ndecs+1,If(mv_par35==1,SE2->E2_TXMOEDA,If(lSemTaxaM2,1,nTaxaDia)))
						nMesTit3 += nSaldo + nVa
						nMesTit4 += nSaldo + nVa
					Endif
				Endif
	
				ADados[PORTADOR] := SE2->E2_PORTADO
	
				If nJuros > 0
					aDados[VL_JUROS] := nJuros
					nJuros := 0
				Endif
	
				IF dDataBase > E2_VENCREA
					nAtraso:=dDataBase-E2_VENCTO
					IF Dow(E2_VENCTO) == 1 .Or. Dow(E2_VENCTO) == 7
						IF Dow(dBaixa) == 2 .and. nAtraso <= 2
							nAtraso:=0
						EndIF
					EndIF
					nAtraso := If(nAtraso<0,0,nAtraso)
					IF nAtraso>0
						aDados[ATRASO] := ""  //nAtraso
					EndIF
				EndIF
				If mv_par20 == 1	//1- Analitico  2-Sintetico
					If nLenSelFil > 1 .and. nOrdem != 4
						obreak2:execute(.F.)
					EndIf					
					aDados[HISTORICO] := SUBSTR(SE2->E2_HIST,1,25)+If(E2_TIPO $ MVPROVIS,"*"," ")
					nRecnoSE2 := SE2->(R_E_C_N_O_)

					DbChangeAlias("SE2","SE2QRY")
					DbChangeAlias("__SE2","SE2")
					SE2->(DBGoto(nRecnoSE2))
					oSection1:PrintLine()
					DbChangeAlias("SE2","__SE2")
					DbChangeAlias("SE2QRY","SE2")
					aFill(aDados,nil)
				EndIf
				cNomFil 	:= cFilAnt + " - " + AllTrim(aSM0[nInc][7])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega data do registro para permitir ³
				//³ posterior analise de quebra por mes.	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dDataAnt := Iif(nOrdem == 3, SE2->E2_VENCREA, SE2->E2_EMISSAO)
	
				If nOrdem == 5		//Forncedor
					cNomFor := If(mv_par28 == 1,AllTrim(SA2->A2_NREDUZ),AllTrim(SA2->A2_NOME))+" "+Substr(SA2->A2_TEL,1,15)
	            ElseIf nOrdem == 7	//Codigo Fornecedor
					cNomFor :=	SA2->A2_COD+" "+SA2->A2_LOJA+" "+AllTrim(SA2->A2_NOME)+" "+Substr(SA2->A2_TEL,1,15)
				EndIf
				
				If nOrdem == 2		//Natureza
					dbSelectArea("SED")
					dbSetOrder(1)
					dbSeek(xFilial("SED")+SE2->E2_NATUREZ)
					cNomNat	:= MascNat(SED->ED_CODIGO)+" "+SED->ED_DESCRIC
				EndIf
				
				cNumBco	 := SE2->E2_PORTADO
				dDtVenc  := IIf(nOrdem == 3,SE2->E2_VENCREA,SE2->E2_EMISSAO)
				nTotVenc := nTit2+nTit3
				nTotMes	 := nMesTit2+nMesTit3
	
				SE2->(dbSkip())
	
				nTotTit ++
				nMesTTit ++
				nFiltit++
				nTit5 ++
				nTotTitEmp++		/* GESTAO */				
			EndDo
	
			If nTit5 > 0 .and. nOrdem != 1 .And. mv_par20 == 2	//1- Analitico  2-Sintetico	
				XSubT150R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,oReport,oSection1)
			EndIF
					
		   	nTotGeral  := nTotMes 
			nTotTitMes := nMesTTit
			nGerTot  += nTit2+nTit3
			nFilTot  += nTit2+nTit3
	
			If mv_par20 == 2	//1- Analitico  2-Sintetico	
				lQuebra := .F.
				If nOrdem == 3 .and. Month(SE2->E2_VENCREA) # Month(dDataAnt)
					lQuebra := .T.
				Elseif nOrdem == 6 .and. Month(SE2->E2_EMISSAO) # Month(dDataAnt)
					lQuebra := .T.
				Endif
				If lQuebra .And. nMesTTit # 0
					oReport:SkipLine()
					IMes150R(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nTotTitMes,oReport,oSection1)
					oReport:SkipLine()
					nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
				Endif
			EndIf
					
			dbSelectArea("SE2")
	
			nTot0 += nTit0
			nTot1 += nTit1
			nTot2 += nTit2
			nTot3 += nTit3
			nTot4 += nTit4
			nTotJ += nTotJur
			
			/*
			GESTAO - inicio */
			nTotEmp0 += nTit0
			nTotEmp1 += nTit1
			nTotEmp2 += nTit2
			nTotEmp3 += nTit3
			nTotEmp4 += nTit4
			nTotEmpJ += nTotJur
			/* GESTAO - fim
			 */	
	
			nFil0 += nTit0
			nFil1 += nTit1
			nFil2 += nTit2
			nFil3 += nTit3
			nFil4 += nTit4
			nFilJ += nTotJur
			Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur
			
			nTotMes 	:= nTotVenc
			nTotFil 	:= nFil2 + nFil3
			nTotEmp 	+= nTotFil		
			
		Enddo					
	        
		
		IF !lQryEmp .And. (nOrdem == 3 .OR. nOrdem == 6)
			aAdd(aTotFil,{aSM0[nInc][2],nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj,aSM0[nInc][7]})
		EndIf
		
			
		If mv_par20 == 1 .and.  nTotFil <> 0 .and. nLenSelFil > 1 .and. nOrdem != 4
			obreak2:PrintTotal()
			oReport:Skipline()
		EndIF
		

		If mv_par20 == 2	//1- Analitico  2-Sintetico	
			if mv_par22 == 1 .and. Len(aSM0) > 1 
				oReport:SkipLine()
				IFil150R(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilj,oReport,oSection1,aSM0[nInc][7])
				Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ
				oReport:SkipLine()			
			Endif	
		EndIf
		
		Store 0 To nFil0,nFil1,nFil2,nFil3,nFil4,nFilJ,nTotJur
		if nOrdem != 4
			Store 0 To nTotFil
		EndIF
		
		dbSelectArea("SE2")		
		
		// mv_par22 (Considerar Filiais a Baixo?) = Sim, não executar o loop pois é retornado somente atraves do range de Filiais
		If mv_par22 == 1 .And. mv_par37 == 2
			Exit
		Endif

		dbSelectArea("SE2")
		dbCloseArea()
		ChKFile("SE2")
		dbSetOrder(1)
	
	EndIf
	nInc++
EndDo
	
SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL 


If mv_par20 == 2	//1- Analitico  2-Sintetico	
	If (nLenSelFil > 1) .Or. (mv_par22 == 1 .And. SM0->(Reccount()) > 1) 		
		oReport:ThinLine()  
		ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)
		oReport:SkipLine()
	Else
		ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)	
	EndIf
EndIf

If !nLenSelFil > 1 	
	oSection1:Finish()
Else
	If oBreak <> NIL 
		oBreak:Execute()
		oBreak:PrintTotal() //  I M P R I M E   O   S U B   T O T A L 
		if nOrdem == 4
			obreak2:PrintTotal() //  I M P R I M E   O    T O T A L   D A   F I L I A L   P O S I C I O N A D A 
			oReport:Skipline()
		Endif
	Endif
	
EndIf


IF nOrdem == 3 .OR. nOrdem == 6
	
	oSection2:Init()   
	For ni := 1 to Len(aTotFil)
		oSection2:printline()
	Next
	
	oSection2:Finish()
EndIf

dbSelectArea("SE2")
dbCloseArea()
ChKFile("SE2")
dbSetOrder(1)
If !Empty(aTmpFil)
	For nBx := 1 To Len(aTmpFil)
		CtbTmpErase(aTmpFil[nBx])
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura empresa / filial original    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SM0->(dbGoto(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//Acerta a database de acordo com a database real do sistema
dDataBase := dOldDtBase

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SubT150R  ³ Autor ³ Wagner Xavier 		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR SUBTOTAL DO RELATORIO 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubT150R()  															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XSubT150R(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur,oReport,oSection1)

Local cQuebra := ""

If nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 6
	cQuebra := "S u b - total ----> " + DtoC(cCarAnt) //"S U B - T O T A L ----> "
ElseIf nOrdem == 2
	dbSelectArea("SED")
	dbSeek(xFilial("SED")+cCarAnt)
	cQuebra := cCarAnt +" "+SED->ED_DESCRIC
ElseIf nOrdem == 4
	cQuebra := "S u b - total ----> " + cCarAnt //"S U B - T O T A L ----> "
Elseif nOrdem == 5
	cQuebra := If(mv_par28 == 1,SA2->A2_NREDUZ,SA2->A2_NOME)+" "+Substr(SA2->A2_TEL,1,15)
ElseIf nOrdem == 7
	cQuebra := SA2->A2_COD+" "+SA2->A2_LOJA+" "+SA2->A2_NOME+" "+Substr(SA2->A2_TEL,1,15)
Endif

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| cQuebra })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nTit1   })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nTit2   })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nTit3   })
oSection1:Cell("JUROS"     ):SetBlock({|| nTotJur })
//oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nTit2+nTit3 })

oSection1:PrintLine()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ImpT150R  ³ Autor ³ Wagner Xavier 		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpT150R()	 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ImpT150R(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ,nTotTit,oReport,oSection1)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| "Total crial ----> " + "(" + ALLTRIM(STR(nTotTit))+" "+If(nTotTit > 1,"Movimentos","Título")+")" })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nTot1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nTot2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nTot3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nTotJ })
//oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nTot2+nTot3 })

oSection1:PrintLine()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³IMes150R  ³ Autor ³ Vinicius Barreira	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IMes150R()  															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function IMes150R(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ,nTotTitMes,oReport,oSection1)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| "T o t a l   d o  m ê s ---> " + "("+ALLTRIM(STR(nTotTitMes))+" "+IIF(nTotTitMes > 1,OemToAnsi("Movimentos"),OemToAnsi("Título"))+")" })
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nMesTit1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nMesTit2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nMesTit3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nMesTitJ })
//oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nMesTit2+nMesTit3 })

oSection1:PrintLine()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ IFil150R	³ Autor ³ Paulo Boschetti 	     ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IFil150R()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico				   									 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function IFil150R(nFil0,nFil1,nFil2,nFil3,nFil4,nFilTit,nFilJ,oReport,oSection1,cFilSM0)

HabiCel(oReport)

oSection1:Cell("FORNECEDOR"):SetBlock({|| "Total   f i l i a l --->" + " " + cFilAnt + " - " + AllTrim(cFilSM0) })	//"T O T A L   F I L I A L ----> " 
oSection1:Cell("VAL_NOMI"  ):SetBlock({|| nFil1 })
oSection1:Cell("VAL_CORR"  ):SetBlock({|| nFil2 })
oSection1:Cell("VAL_VENC"  ):SetBlock({|| nFil3 })
oSection1:Cell("JUROS"     ):SetBlock({|| nFilJ })
//oSection1:Cell("VAL_SOMA"  ):SetBlock({|| nFil2+nFil3 })

oSection1:PrintLine()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³HabiCel	³ Autor ³ Daniel Tadashi Batori ³ Data ³ 04/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³habilita ou desabilita celulas para imprimir totais		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ HabiCel()	 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±³			 ³ oReport ->objeto TReport que possui as celulas 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function HabiCel(oReport)

Local oSection1 := oReport:Section(1)

oSection1:Cell("FORNECEDO"):SetSize(50)
oSection1:Cell("TITULO"    ):Disable()
oSection1:Cell("E2_TIPO"   ):Hide()
oSection1:Cell("E2_NATUREZ"):Hide()
oSection1:Cell("E2_EMISSAO"):Hide()
oSection1:Cell("E2_VENCTO" ):Hide()
oSection1:Cell("E2_VENCREA"):Hide()
oSection1:Cell("VAL_ORIG"  ):Hide()
oSection1:Cell("E2_PORTADO"):Hide()
oSection1:Cell("DIA_ATR"   ):Hide()
oSection1:Cell("E2_HIST"   ):Disable()
//oSection1:Cell("VAL_SOMA"  ):Enable()

oSection1:Cell("FORNECEDO"):HideHeader()
oSection1:Cell("E2_TIPO"   ):HideHeader()
oSection1:Cell("E2_NATUREZ"):HideHeader()
oSection1:Cell("E2_EMISSAO"):HideHeader()
oSection1:Cell("E2_VENCTO" ):HideHeader()
oSection1:Cell("E2_VENCREA"):HideHeader()
oSection1:Cell("VAL_ORIG"  ):HideHeader()
oSection1:Cell("E2_PORTADO"):HideHeader()
oSection1:Cell("DIA_ATR"   ):HideHeader()	

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
	Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0


//-------------------------------------------------------------------
/*/{Protheus.doc} FR150DBX

Busca a data da ultima baixa realizada do titulo a pagar até a
DataBase do sistema.

@author leonardo.casilva

@since 20/05/2016
@version P1180
 
@return
/*/
//-------------------------------------------------------------------
Static Function FR150DBX()

Local dDataRet := SE2->E2_VENCREA
Local cQuery	 := "SELECT"

cQuery += " MAX(SE5.E5_DATA) DBAIXA"
cQuery += " FROM "+ RetSQLName( "SE5" ) + " SE5 "
cQuery += " WHERE SE5.E5_FILIAL IN ('" + xFilial("SE2")  + "') " 
cQuery += " AND SE5.E5_PREFIXO = '" + SE2->E2_PREFIXO	 + "'"
cQuery += " AND SE5.E5_NUMERO = '"  + SE2->E2_NUM		 + "'"
cQuery += " AND SE5.E5_PARCELA = '" + SE2->E2_PARCELA	 + "'"
cQuery += " AND SE5.E5_TIPO = '"	+ SE2->E2_TIPO	 	 + "'"
cQuery += " AND SE5.E5_CLIFOR = '"	+ SE2->E2_FORNECE	 + "'"
cQuery += " AND SE5.E5_LOJA = '"	+ SE2->E2_LOJA	 	 + "'"
cQuery += " AND SE5.E5_TIPODOC IN('BA','VL')"
cQuery += " AND SE5.E5_RECPAG  = 'P'"
cQuery += " AND SE5.E5_DATA <= '"	+ DTOS(dDataBase) + "'"
cQuery += " AND SE5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBDATA",.T.,.T.)

If TRBDATA->(!EOF())
	If !Empty(AllTrim(TRBDATA->DBAIXA))
		dDataRet := STOD(TRBDATA->DBAIXA)
	Endif
EndIf
TRBDATA->(dbCloseArea())

Return dDataRet
