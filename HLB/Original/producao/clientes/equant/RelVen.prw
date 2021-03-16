#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RELVENDAS³ Autor ³ Jose Carlos S. Veloso ³ Data ³ 15.09.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao de Vendas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG / Orange                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RelVen()
Local oReport
 
oReport := ReportDef()
oReport:PrintDialog()

Return()



//---------------------------------------------------------------------------
Static Function ReportDef()

Local oReport 
Local oSection1
Local oCell         
Local aOrdem := {}

AjustaSX1()
Pergunte("RELVEN",.f.)

oReport:= TReport():New("RELVEN","Relatorio de Vendas","RELVEN", {|oReport| ReportPrint(oReport)},"Relatorio de Vendas")
oReport:SetTotalInLine(.F.)
oReport:SetTitle(oReport:Title()+"Relatorio de Vendas")

oSection1:= TRSection():New(oReport,"Vendas",{"SD2"})
oSection1:SetTotalInLine(.F.)
oSection1:SetReadOnly()
oSection1:SetHeaderPage()
TRCell():New(oSection1,"E1_NOMCLI"  ,"SE1","Cliente"	,/*Picture*/		,TamSX3('E1_NOMCLI')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_CF"	 	,"SD2","CFOP"		,/*Picture*/		,TamSX3('D2_CF')[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_DOC"		,"SD2","N.Fiscal"	,/*Picture*/		,8						,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_EMISSAO"	,"SD2","Emissão"	,"@R 99/99/99"		,TamSX3('D2_EMISSAO')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"E1_VENCTO"  ,"SE1","Vencto."	,"@R 99/99/99"		,TamSX3('E1_VENCTO')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_TOTAL"   ,"SD2","Vl.Total"	,"@E 999,999,999.99",TamSX3('D2_TOTAL')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_BASEICM" ,"SD2","Base Calc."	,"@E 999,999,999.99",TamSX3('D2_BASEICM')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_ALQIMP5" ,"SD2","Al.COFINS"	,"@E 99.99"			,TamSX3('D1_ALQIMP5')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_VALIMP5" ,"SD2","Vl.COFINS"	,"@E 999,999,999.99",TamSX3('D2_VALIMP5')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_ALQIMP6" ,"SD2","Al.PIS"		,"@E 99.99"			,TamSX3('D2_ALQIMP6')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_VALIMP6" ,"SD2","Vl.PIS"		,"@E 999,999,999.99",TamSX3('D2_VALIMP6')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_PICM"    ,"SD2","Al.ICMS"	,"@E 99.99"			,TamSX3('D2_PICM')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_VALICM"  ,"SD2","Vl.ICMS"	,"@E 999,999,999.99",TamSX3('D2_VALICM')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_BASEIPI" ,"SD2","Base IPI"	,"@E 999,999,999.99",TamSX3('D2_BASEIPI')[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_IPI"     ,"SD2","Al.IPI"		,"@E 99.99"			,TamSX3('D2_IPI')[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D2_VALIPI"  ,"SD2","Vl.IPI"		,"@E 999,999,999.99",TamSX3('D2_VALIPI')[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"C5_MENNOTA" ,"SC5","PO SRF"		,/*Picture*/		,50						,/*lPixel*/,/*{|| code-block de impressao }*/)
//oBreak := TRBreak():New(oSection1,oSection1:Cell("D3_COD"),"Total da producao no periodo:",.F.)
TRFunction():New(oSection1:Cell("D2_TOTAL")  ,NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_BASEICM"),NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALIMP5"),NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALIMP6"),NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALICM") ,NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_BASEIPI"),NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALIPI") ,NIL,"SUM",,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³06.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local lFirst    := .T.
Local oBreak
Local aIndex	:= {}

oReport:Section(1):BeginQuery()

BeginSql Alias 'QRY'
	Column EMISSAO as Date
	Column VENCTO  as Date
	SELECT 
		E1_NOMCLI 		AS CLIENTE,
		D2_CF			AS CFOP,
		D2_DOC			AS NFISCAL,
		D2_EMISSAO		AS EMISSAO,
		E1_VENCTO		AS VENCTO,
		SUM(D2_TOTAL)	AS VLTOTAL,
		SUM(D2_BASEICM)	AS BASECAL,
		D2_ALQIMP5		AS ALQCOF,
		SUM(D2_VALIMP5)	AS VALCOF,
		D2_ALQIMP6		AS ALQPIS,
		SUM(D2_VALIMP5)	AS VALPIS,
		D2_PICM			AS ALQICM,
		SUM(D2_VALICM)	AS VALICM,
		SUM(D2_BASEIPI)	AS BASIPI,
		D2_IPI			AS ALQIPI,
		SUM(D2_VALIPI)	AS VALIPI,
		C5_MENNOTA		AS PO_SRF
	//MSM - Mudança na query para resolver o problema enviado por e-mail pela Adriane, Email de 27/01/2015 às 18:39
	FROM %table:SD2% SD2
	JOIN %table:SF2% SF2 ON F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA 
	JOIN %table:SE1% SE1 ON D2_DOC = E1_NUM AND D2_CLIENTE = E1_CLIENTE AND D2_LOJA = E1_LOJA AND E1_PREFIXO = F2_PREFIXO
	JOIN %table:SC5% SC5 ON D2_DOC = C5_NOTA AND D2_SERIE = C5_SERIE  
	WHERE SD2.D2_FILIAL =  %xfilial:SD2%  AND SE1.E1_FILIAL =  %xfilial:SE1%  AND SC5.C5_FILIAL =  %xfilial:SC5% AND SF2.F2_FILIAL =  %xfilial:SF2% AND  
		  SD2.D2_CLIENTE BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
		  SD2.D2_LOJA    BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% AND
		  SD2.D2_EMISSAO BETWEEN %exp:dtos(MV_PAR05)% AND %exp:dtos(MV_PAR06)% AND
          SD2.%notDel% AND
		  SE1.%notDel% AND
		  SF2.%notDel% AND
		  SC5.%notDel%
    GROUP BY D2_DOC,E1_NOMCLI,D2_CLIENTE,D2_LOJA,D2_CF,D2_EMISSAO,E1_VENCTO,D2_ALQIMP5,D2_ALQIMP6,D2_PICM,D2_IPI,C5_MENNOTA
/*	FROM %table:SD2% SD2, %table:SE1% SE1, %table:SC5% SC5
	WHERE SD2.D2_FILIAL 							= %xfilial:SD2% AND
	      SE1.E1_FILIAL 							= %xfilial:SE1% AND
	      SC5.C5_FILIAL 							= %xfilial:SC5% AND
	      //RRP - 22/01/2014 - Ajuste no fonte devido a empresa usar o financeiro compartilhado.
		  SubString((D2_SERIE),1,1)+%xfilial:SD2%  	= E1_PREFIXO	AND
		  D2_DOC       								= E1_NUM		AND
		  D2_CLIENTE   								= E1_CLIENTE	AND
		  D2_LOJA       							= E1_LOJA		AND
		  D2_DOC        							= C5_NOTA		AND
		  D2_SERIE      							= C5_SERIE	    AND
		  SD2.D2_CLIENTE BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
		  SD2.D2_LOJA    BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% AND
		  SD2.D2_EMISSAO BETWEEN %exp:dtos(MV_PAR05)% AND %exp:dtos(MV_PAR06)% AND
		  SD2.%notDel% AND
		  SE1.%notDel% AND
		  SC5.%notDel%
*/


EndSql

oReport:Section(1):EndQuery()

oReport:SetMeter(QRY->(LastRec()))

oSection1:Init()

While !oReport:Cancel() .and. QRY->(!Eof())

	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()

	oSection1:Cell("E1_NOMCLI"):SetValue(QRY->CLIENTE)
	oSection1:Cell("D2_CF"):SetValue(QRY->CFOP)
	oSection1:Cell("D2_DOC"):SetValue(QRY->NFISCAL)
	oSection1:Cell("D2_EMISSAO"):SetValue(QRY->EMISSAO)
	oSection1:Cell("E1_VENCTO"):SetValue(QRY->VENCTO)
	oSection1:Cell("D2_TOTAL"):SetValue(QRY->VLTOTAL+QRY->VALIPI)
	oSection1:Cell("D2_BASEICM"):SetValue(QRY->BASECAL)
	oSection1:Cell("D2_ALQIMP5"):SetValue(QRY->ALQCOF)
	oSection1:Cell("D2_VALIMP5"):SetValue(QRY->VALCOF)
	oSection1:Cell("D2_ALQIMP6"):SetValue(QRY->ALQPIS)
	oSection1:Cell("D2_VALIMP6"):SetValue(QRY->VALPIS)
	oSection1:Cell("D2_PICM"):SetValue(QRY->ALQICM)
	oSection1:Cell("D2_VALICM"):SetValue(QRY->VALICM)
	oSection1:Cell("D2_VALIMP5"):SetValue(QRY->VALCOF)
	oSection1:Cell("D2_BASEIPI"):SetValue(QRY->BASIPI)
	oSection1:Cell("D2_IPI"):SetValue(QRY->ALQIPI)
	oSection1:Cell("D2_VALIPI"):SetValue(QRY->VALIPI)
	oSection1:Cell("C5_MENNOTA"):SetValue(QRY->PO_SRF)
	oSection1:PrintLine()
					
	QRY->(dbSkip())
	
EndDo

oSection1:Finish()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ Alexandre Inacio Lemes³ Data ³26/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera descricao da pergunta no SX1                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aArea := { Alias(), IndexOrd() } , aPerg:={}
Local cPerg := "RELVEN"         

U_PUTSX1(cPerg,"01","Do Cliente?","Do Cliente?","Do Cliente?"   ,"mv_ch1","C",06,0,2,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","")
U_PUTSX1(cPerg,"02","Ate Cliente?","Ate Cliente?","Ate Cliente?","mv_ch2","C",06,0,2,"G","","SA1","","","mv_par02","","","","","","","","","","","","","","","","")
U_PUTSX1(cPerg,"03","Da Loja?","Da Loja?","Da Loja?"            ,"mv_ch3","C",02,0,2,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","")
U_PUTSX1(cPerg,"04","Ate Loja?","Ate Loja?","Ate Loja?"         ,"mv_ch4","C",02,0,2,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","")
U_PUTSX1(cPerg,"05","Emissao de?","Emissao de?","Emissao de?"   ,"mv_ch5","D",08,0,2,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","")
U_PUTSX1(cPerg,"06","Emissao ate?","Emissao ate?","Emissao ate?","mv_ch6","D",08,0,2,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","")

Return
