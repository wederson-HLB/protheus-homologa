#Include "FINR865.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ UFINR865	³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de titulos a pagar com rentencao PIS/Cofins/CSLL	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR865(void)			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
        
/*
Funcao      : UFINR865
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relacao de titulos a pagar com rentencao PIS/Cofins/CSLL
Autor     	: Tiago Luiz Mendonça
Data     	: 23/06/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 08/02/2012
Módulo      : Financeiro.
*/ 

*-------------------------*
  User Function UFINR865()
*-------------------------*

Local oReport                              
Local aArea		 := GetArea() 

If !( cEmpAnt $ "07"  )  
   MsgStop("Especifico Engecorps","A T E N C A O")  
   Return .F.
EndIf      
                                                             
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
   U_UFINENG() 
Endif

RestArea(aArea)  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Marcio Menon		  º Data ³  01/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 										                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport
Local oSection1        
Local oSection2
Local cReport 	:= "ENGECORPS" 				// Nome do relatorio      
Local cDescri 	:= "Relatorio de Titulos a Pagar Geral "  // "STR0001 	//"Imprime a relacao dos titulos a pagar que sofreram retencao de Impostos"
Local cTitulo 	:= "Relatorio de Titulos a Pagar Geral "  //STR0007  "Relacao de Titulos a Pagar com retencao de Impostos"
Local cPerg		:= "FIN865"					// Nome do grupo de perguntas
Local aOrdem	:= {STR0004,STR0005}	 	//"Por Codigo Fornecedor"###"Por Nome Fornecedor"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN865",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ³
//³ mv_par01		 // Do Fornecedor?     ³
//³ mv_par02		 // Ate Fornecedor?    ³
//³ mv_par03		 // Da Loja?      	  ³
//³ mv_par04		 // Ate Loja?          ³
//³ mv_par05		 // Da Emissao?	     ³
//³ mv_par06		 // Ate Emissao?       ³
//³ mv_par07		 // Do Vencimento?     ³
//³ mv_par08		 // Ate Vencimento?    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri) 

oReport:SetLandscape()	//Imprime o relatorio no formato paisagem
oReport:SetTotalInLine(.F.)		//Imprime o total em linha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                      Definicao das Secoes                              ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 01 (Dados Fornecedor)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0022, {"TRB","SA2"}, aOrdem)

TRCell():New(oSection1,"CODIGO" ,"TRB",STR0020,/*Picture*/, 06 ,/*lPixel*/,{ || TRB->CODIGO  } )		//"Codigo"
TRCell():New(oSection1,"LOJA"   ,"TRB",STR0021,/*Picture*/, 02 ,/*lPixel*/,{ || TRB->LOJA 	  } )		//"Loja"
TRCell():New(oSection1,"NOMEFOR","TRB",STR0022,/*Picture*/, 40 ,/*lPixel*/,{ || TRB->NOMEFOR } )		//"Fornecedor"
TRCell():New(oSection1,"CGC"    ,"TRB",STR0023,/*Picture*/, 14 ,/*lPixel*/,{ || If(!Empty(TRB->CGC), TRB->CGC, ) } )	//"CGC"

oSection1:SetNoFilter("TRB")	// Desabilita Filtro
oSection1:SetNoFilter("SA2")	// Desabilita Filtro
oSection1:SetHeaderSection(.F.)	//Nao imprime o cabeçalho da secao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 02 (Titulos)                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1, STR0014, {"TRB","SE2"}, aOrdem)		//"TITULOS"

TRCell():New(oSection2,"PRF"    ,"TRB",STR0024,/*Picture*/, TamSX3("E2_PREFIXO")[1],/*lPixel*/,{ || TRB->PREFIXO } )	//"Prf"
TRCell():New(oSection2,"NUM"    ,"TRB",STR0025,/*Picture*/, TamSX3("E2_NUM")[1]    ,/*lPixel*/,{ || TRB->NUM     } )	//"Numero"
TRCell():New(oSection2,"PARCELA","TRB",STR0026,/*Picture*/, TamSX3("E2_PARCELA")[1],/*lPixel*/,{ || TRB->PARCELA } )	//"Pc"
TRCell():New(oSection2,"TIPO"   ,"TRB",STR0027,/*Picture*/, TamSX3("E2_TIPO")[1]   ,/*lPixel*/,{ || TRB->TIPO    } )	//"Tipo"
TRCell():New(oSection2,"EMISSAO","TRB",STR0028,/*Picture*/, TamSX3("E2_EMISSAO")[1],/*lPixel*/,/*{ || TRB->EMISSAO }*/ )	//"Emissao"
TRCell():New(oSection2,"VENCTO" ,"TRB",STR0029,/*Picture*/, TamSX3("E2_VENCREA")[1],/*lPixel*/,/*{ || TRB->VENCTO  }*/ )	//"Vencto"
TRCell():New(oSection2,"VALBASE","TRB",STR0030+STR0031,TM(0,17), 17 ,/*lPixel*/,/*{ || TRB->VALBASE }*/ )		//"Valor "##"Original"
TRCell():New(oSection2,"VALSEST","TRB",STR0030+STR0032,TM(0,17), 17 ,/*lPixel*/,{ || If (lSest, TRB->VALSEST,) } )	//"Valor "##"SEST"
TRCell():New(oSection2,"VALIRRF","TRB",STR0030+STR0033,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALIRRF } )		//"Valor "##"IRRF"
TRCell():New(oSection2,"VALISS" ,"TRB",STR0030+STR0034,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALISS  } )		//"Valor "##"ISS"
TRCell():New(oSection2,"VALINSS","TRB",STR0030+STR0035,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALINSS } )		//"Valor "##"INSS"
TRCell():New(oSection2,"VALPIS" ,"TRB",STR0030+STR0036,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALPIS  } )		//"Valor "##"PIS"
TRCell():New(oSection2,"VALCOF" ,"TRB",STR0030+STR0037,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALCOF  } )		//"Valor "##"COFINS"
TRCell():New(oSection2,"VALCSLL","TRB",STR0030+STR0038,TM(0,17), 17 ,/*lPixel*/,{ || TRB->VALCSLL } )		//"Valor "##"CSLL"
TRCell():New(oSection2,"VALLIQ" ,"TRB",STR0030+STR0039,TM(0,17), 17 ,/*lPixel*/,/*{ || If (!lPccBaixa .or. !lContrRet, TRB->VALLIQ, TRB->(VALLIQ-VALPIS-VALCOF-VALCSLL) ) }*/ )	//"Valor "##"Liquido"
TRCell():New(oSection2,"TIPORET",""   ,Substr(STR0017,1,1)+Substr(STR0018,1,1)+Substr(STR0019,1,1),/*Picture*/, 01 ,/*lPixel*/,/*CodeBlock*/)

oSection2:Cell("VALBASE"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALSEST"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALIRRF"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALISS" ):SetHeaderAlign("RIGHT")
oSection2:Cell("VALINSS"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALPIS" ):SetHeaderAlign("RIGHT")
oSection2:Cell("VALCOF" ):SetHeaderAlign("RIGHT")
oSection2:Cell("VALCSLL"):SetHeaderAlign("RIGHT")
oSection2:Cell("VALLIQ" ):SetHeaderAlign("RIGHT")
oSection2:Cell("TIPORET"):HideHeader()	//Oculta o texto do cabeçalho

oSection2:SetNoFilter("TRB")  	// Desabilita Filtro
oSection2:SetHeaderPage()	//Define o cabecalho da secao como padrao
oSection2:SetLineBreak(.T.)		//Quebra a linha quando não couber na página
oSection2:SetTotalInLine(.F.)   //Imprime o total em linha

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³ReportPrint ³Autor³ Marcio Menon       ³ Data ³  01/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao  ³ Imprime o objeto oReport definido na funcao ReportDef.     º±±                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros ³ oReport - Objeto TReport do relatorio                      º±±
±±º           ³ 				   										   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Data    ³    Autor   ³ BOPS ³        Manutencao Efetuada             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º06/11/2007 ³Pedro P Lima³134275³ O relatorio nao considerava o valor    º±±
±±º           ³   TI6434   ³ P10  ³ original do titulo, que era impresso   º±±
±±º           ³            ³      ³ com o valor 0,00 e tabem nao           º±±
±±º           ³            ³      ³ considerava o valor do campo valor liq.º±±
±±º           ³            ³      ³ que era impresso incorretamente.       º±±  
±±º           ³            ³      ³ Foi corrigido o trecho onde a variavel º±±
±±º           ³            ³      ³ nValBase recebe o valor original do    º±±
±±º           ³            ³      ³ titulo e o tratamento do valor liquido.º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)
#IFDEF TOP
	Local cFilterUser := oSection1:GetSqlExp("SE2")
#ELSE
	Local cFilterUser := oSection1:GetADVPLExp("SE2")
#ENDIF
Local oBreak
Local nOrdem	:= oReport:Section(1):GetOrder()
Local nRegEmp   := SM0->(RecNo())
Local aTam	    := TAMSX3("E2_NUM")
Local CbCont
Local CbTxt
Local cCGCAnt
Local cChaveSe2
Local lContinua	:= .T.
Local nTitCli		:= 0
Local nTitRel		:= 0
Local nVlCliOri	:= 0
Local nVlCliIns	:= 0
Local nVlCliLiq	:= 0
Local nVlTotOri	:= 0
Local nVlTotIns	:= 0
Local nVlTotPis	:= 0
Local nVlTotCof	:= 0
Local nVlTotCsl	:= 0
Local nVlTotIrf	:= 0 
Local nVlCliIrf	:= 0
Local nVlTotIss	:= 0 
Local nVlCliIss	:= 0
Local nVlTotSes	:= 0 
Local nVlCliSes	:= 0
Local nVlCliPis	:= 0
Local nVlCliCof	:= 0
Local nVlCliCsl	:= 0
Local nVlTotLiq	:= 0
Local aCampos		:= {}                                   
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cNomFor		:= ""                       
Local aTamNum		:= TAMSX3("E2_NUM")
Local nValBase 	:= 0
Local nValLiq	 	:= 0
Local lFatura  	:= .F.
Local lCalcIssBx := !Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
                    !Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
Local cFilterSE2 := ""

#IFNDEF TOP
	Local nIndexSE2
	Local cIndexSe2
#ENDIF

Private lContrRet	:= !Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ; 
				 	   !Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
				 	   !Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )

Private lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ; 
                     !Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				 	 !Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				 	 !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Private lSest  := SE2->(FieldPos("E2_SEST"))	> 0  //Verifica campo de SEST

oReport:SetTotalText({|| STR0016+"("+ALLTRIM(STR(nTitRel))+" "+IIF(nTitRel > 1,STR0014,STR0015)+")"})
oReport:SetPageFooter(4,{|| If(!oSection2:Printing(),F865Legenda(oReport),"")})

TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2")+TRB->CODIGO+TRB->LOJA}) 
TRPosition():New(oSection2,"SE2",1,{|| xFilial("SE2")+TRB->PREFIXO+TRB->NUM+TRB->PARCELA+TRB->TIPO+TRB->CODIGO+TRB->LOJA})

oBreak := TRBreak():New(oSection1,{|| TRB->CODIGO+TRB->LOJA},{|| STR0013 + AllTrim(cNomFor) +" ("+AllTrim(STR(nTitCli))+" "+IiF(nTitCli>1,STR0014,STR0015)+")"})
oBreak:OnBreak({|x| cNomFor := SA2->A2_NOME })
								
TRFunction():New(oSection2:Cell("VALBASE"),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALSEST"),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALIRRF"),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALISS" ),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALINSS"),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALPIS" ),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALCOF" ),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALCSLL"),"","SUM",oBreak,,,,.F.,.T.)
TRFunction():New(oSection2:Cell("VALLIQ" ),"","SUM",oBreak,,,,.F.,.T.)

If !lSest		//Se o campo SEST nao existir, ele oculta as colunas das secoes
	oSection2:Cell("VALSEST"):Disable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a estrutura do TRB.				                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos	:= {{"CODIGO"	,"C",06,0 },;
				{"LOJA"	,"C",02,0 },;
				{"NOMEFOR"	,"C",40,0 },;
				{"CGC"		,"C",14,0 },;
				{"PREFIXO"	,"C",03,0 },;
				{"NUM"		,"C",aTamNum[1],0 },;
				{"PARCELA"	,"C",TamSx3("E2_PARCELA")[1],0 },;
				{"TIPO"		,"C",03,0 },;
				{"EMISSAO"	,"D",08,0 },;
				{"VENCTO"	,"D",08,0 },;
				{"VALBASE"  ,"N",17,2 },;
				{"VALINSS"	,"N",17,2 },;
				{"VALPIS"	,"N",17,2 },;
				{"VALCOF"	,"N",17,2 },;
				{"VALCSLL"	,"N",17,2 },;
				{"VALIRRF"	,"N",17,2 },;
				{"VALISS"	,"N",17,2 },;
				{"VALSEST"	,"N",17,2 },;
				{"VALLIQ"	,"N",17,2 },;
				{"VRETPIS"	,"N",17,2 },;
				{"VRETCOF"	,"N",17,2 },;
				{"VRETCSL"	,"N",17,2 },;
				{"PRETPIS"	,"C",01,0 },;
				{"PRETCOF"	,"C",01,0 },;
				{"PRETCSL"	,"C",01,0 },; 
				{"TRETISS"	,"C",01,0 },;				
				{"FATURA"	,"C",TamSx3("E2_FATURA")[1],0 } }

dbSelectArea("SE2")

If nOrdem == 1  //Por Codigo
	dbSetOrder(6)
Else            //Por Nome
	dbSetOrder(2)
Endif

cChaveSe2 := IndexKey()
cFilterSE2 := cFilterUser

#IFDEF TOP
	If nOrdem == 1  //Por Codigo
		cOrder := "CODIGO,LOJA"
	Else            //Por Nome
		cOrder := "NOMEFOR"
	Endif
	
	cQuery := "SELECT A2_COD CODIGO,A2_LOJA LOJA,A2_NOME NOMEFOR,A2_CGC CGC,E2_PREFIXO PREFIXO,"
	cQuery += "E2_NUM NUM,E2_PARCELA PARCELA,E2_TIPO TIPO,E2_EMISSAO EMISSAO,E2_VENCREA VENCTO,"
	cQuery += "E2_IRRF VALIRRF,E2_ISS VALISS,E2_INSS VALINSS,E2_FATURA FATURA,"
	cQuery += "E2_PIS VALPIS,E2_COFINS VALCOF,E2_CSLL VALCSLL,"	
	//Se controla Retencao
	If lContrRet
		cQuery += "E2_VRETPIS VRETPIS,E2_VRETCOF VRETCOF,E2_VRETCSL VRETCSL,"	
		cQuery += "E2_PRETPIS PRETPIS,E2_PRETCOF PRETCOF,E2_PRETCSL PRETCSL,"	
		If lSest  // So processa se existir o campo E2_SEST
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_SEST) VALBASE,"
			cQuery += "E2_SEST VALSEST,"
		Else
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS) VALBASE,"
		Endif	
	Else
		If lSest  // So processa se existir o campo E2_SEST
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL+E2_SEST) VALBASE,"
			cQuery += "E2_SEST VALSEST,"
		Else
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL) VALBASE,"
		Endif
	Endif					

	IF lCalcIssBx
		cQuery += "E2_TRETISS TRETISS,"
	Endif

	cQuery += "E2_VALOR VALLIQ"
	cQuery += "FROM "+RetSqlName("SE2")+" SE2,"
	cQuery +=         RetSqlName("SA2")+" SA2 "
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
	cQuery += " AND SA2.A2_FILIAL   = '" + xFilial("SA2") + "'"
	cQuery += " AND SE2.D_E_L_E_T_  <> '*' "
	cQuery += " AND SA2.D_E_L_E_T_  <> '*' "
	cQuery += " AND SE2.E2_FORNECE  =  SA2.A2_COD"
	cQuery += " AND SE2.E2_LOJA	  =  SA2.A2_LOJA"
	cQuery += " AND SE2.E2_FORNECE  between '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += " AND SE2.E2_LOJA     between '" + mv_par03 + "' AND '" + mv_par04 + "'"
	//cQuery += " AND (SE2.E2_INSS > 0 "
	//cQuery += " OR SE2.E2_ISS > 0 "
	//cQuery += " OR SE2.E2_PIS > 0 "
	//cQuery += " OR SE2.E2_COFINS > 0 "
	//cQuery += " OR SE2.E2_CSLL > 0 "
	//cQuery += " OR SE2.E2_IRRF > 0 ) "
	cQuery += " AND SE2.E2_VENCREA  between '" + DTOS(mv_par07)  + "' AND '" + DTOS(mv_par08) + "'"
	cQuery += " AND SE2.E2_EMISSAO  between '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
	cQuery += " AND SE2.E2_EMISSAO  <= '"      + DTOS(dDataBase) + "'"
	If !Empty(cFilterSE2)
      	cQuery += " AND " + cFilterSE2
	EndIf
	cQuery += " ORDER BY "+ cOrder
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SE2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
#ELSE
	cIndexSe2 := CriaTrab(nil,.f.)
	IndRegua("SE2",cIndexSe2,cChaveSe2,,FR865IndR(cFilterSE2),STR0011) //"Selecionando Registros..."
	nIndexSE2 := RetIndex("SE2")
	dbSetIndex(cIndexSe2+OrdBagExt())
	dbSetOrder(nIndexSE2+1)
	dbSeek(xFilial("SE2"))

	cArqTrab := CriaTrab( aCampos )
	dbUseArea( .T.,, cArqTrab, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
	If nOrdem == 1  //Por Codigo
		IndRegua("TRB",cArqTrab,"CODIGO+LOJA",,,)
	Else            //Por Nome
		IndRegua("TRB",cArqTrab,"NOMEFOR",,,)
	Endif
	dbSetIndex( cArqTrab +OrdBagExt())

	dbSelectArea("SE2")				

	While SE2->(!Eof())
	
		dbSelectArea("SA2")			
		dbSetOrder(1)
		
		If dbSeek(xFilial()+SE2->(E2_FORNECE+E2_LOJA))
			
			If	lContrRet
				nValBase	:= SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS)

				//Titulo nao gerou o Pis,Cofins e Csll
				If !lPccBaixa .and. (Empty(SE2->E2_PRETPIS) .or. Empty(SE2->E2_PRETCOF) .or. Empty(SE2->E2_PRETCSL))
	           		If SE2->E2_PRETPIS <> "2" .Or. SE2->E2_PRETCOF <> "2" .Or. SE2->E2_PRETCSL <> "2"
						nValBase += SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL)
	            	EndIf
				Endif
			Else
				nValBase	:= SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL)
			Endif
			If lSest
				nValBase += SE2->E2_SEST
			Endif
			
			dbSelectArea("TRB")
			RecLock("TRB",.T.)	
			TRB->CODIGO		:= SA2->A2_COD
			TRB->LOJA		:= SA2->A2_LOJA
			TRB->NOMEFOR	:= SA2->A2_NOME 
			TRB->CGC		:= SA2->A2_CGC
			TRB->PREFIXO	:= SE2->E2_PREFIXO
			TRB->NUM		:= SE2->E2_NUM
			TRB->PARCELA	:= SE2->E2_PARCELA
			TRB->TIPO		:= SE2->E2_TIPO
			TRB->EMISSAO	:= SE2->E2_EMISSAO
			TRB->VENCTO		:= SE2->E2_VENCREA
			TRB->VALBASE	:= nValBase
			TRB->VALINSS	:= SE2->E2_INSS
			TRB->VALPIS		:= SE2->E2_PIS
			TRB->VALCOF		:= SE2->E2_COFINS
			TRB->VALCSLL	:= SE2->E2_CSLL 
			TRB->VALIRRF	:= SE2->E2_IRRF
			TRB->VALISS		:= SE2->E2_ISS       
			TRB->FATURA		:= SE2->E2_FATURA
			TRB->TRETISS	:= SE2->E2_TRETISS 			
			
			If lSest  // So processa se existir o campo E2_SEST
				TRB->VALSEST := SE2->E2_SEST  
			Endif
			TRB->VALLIQ := SE2->E2_VALOR

			//Se controla retencao
			If lContrRet
				TRB->VRETPIS	:= SE2->E2_VRETPIS
				TRB->VRETCOF	:= SE2->E2_VRETCOF
				TRB->VRETCSL	:= SE2->E2_VRETCSL 
				TRB->PRETPIS	:= SE2->E2_PRETPIS
				TRB->PRETCOF	:= SE2->E2_PRETCOF
				TRB->PRETCSL	:= SE2->E2_PRETCSL 
			Endif			

			MSUnlock()
		Endif
		dbSelectArea("SE2")
		dbSkip()
	EndDo
#ENDIF

dbSelectArea("TRB")
dbGoTop()

oReport:SetMeter(TRB->(Reccount()))

While TRB->(!Eof())

	nTitCli		:= 0
	nVlCliOri	:= 0
	nVlCliIns	:= 0
	nVlCliLiq	:= 0
	nVlCliPis	:= 0
	nVlCliCof	:= 0
	nVlCliCsl	:= 0
	nVlCliSes	:= 0
	nVlCliIrf	:= 0
	nVlCliIss	:= 0
	nValBase	:= 0

	oSection1:Init()
	oSection1:Cell("CGC"):SetPicture(IIF(Len(Alltrim(TRB->CGC)) == 11 , "@R 999.999.999-99","@R 99.999.999/9999-99"))					
	oSection1:PrintLine()

	cCodFor		:= TRB->CODIGO
	cLojFor		:= TRB->LOJA
	cNomFor		:= TRB->NOMEFOR                       
	cCGCAnt		:= TRB->CGC
	
	oSection2:Init()
	
	While TRB->(!EOF()) .And. cCodFor+cLojFor == TRB->(CODIGO+LOJA) .And.	cNomFor == TRB->NOMEFOR                       

		lFatura := .F.

	 	If !Empty(TRB->FATURA) .And. TRB->FATURA == 'NOTFAT'
			lFatura := .T.
		EndIf 

		nValLiq := If (!lPccBaixa .or. !lContrRet, TRB->VALLIQ, TRB->(VALLIQ-VALPIS-VALCOF-VALCSLL) )

		#IFDEF TOP
			oSection2:Cell("EMISSAO"):SetBlock( { || STOD(TRB->EMISSAO) } )
			oSection2:Cell("VENCTO" ):SetBlock( { || STOD(TRB->VENCTO) } )
			If	lContrRet
				//Titulo que aglutinou os impostos
				If !lPccBaixa .and. (Empty(TRB->PRETPIS) .or. Empty(TRB->PRETCOF) .or. Empty(TRB->PRETCSL))
					nValBase := TRB->(VALBASE+VRETPIS+VRETCOF+VRETCSL)
				Else
					nValBase := TRB->VALBASE
				Endif

				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .and. TRB->TRETISS == "2"
					nValBase -= TRB->VALISS
					nValLiq	 -= TRB->VALISS					
				Endif
				oSection2:Cell("VALBASE"):SetBlock( { || nValBase } )
				oSection2:Cell("VALLIQ" ):SetBlock( { || nValLiq } )				
			Else
				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .and. TRB->TRETISS == "2"
					nValBase := TRB->VALBASE - TRB->VALISS
					nValLiq	 := TRB->VALLIQ - TRB->VALISS					
				Endif
				oSection2:Cell("EMISSAO"):SetBlock( { || TRB->EMISSAO } )
				oSection2:Cell("VENCTO" ):SetBlock( { || TRB->VENCTO  } )
				oSection2:Cell("VALBASE"):SetBlock( { || nValBase } )
				oSection2:Cell("VALLIQ" ):SetBlock( { || nValLiq } )
			Endif
		#ELSE
				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .and. TRB->TRETISS == "2"
					nValBase := TRB->VALBASE - TRB->VALISS
					nValLiq	 -= TRB->VALISS					
                Else
				  If TRB->TRETISS == "2" 
				  	nValBase := TRB->VALBASE - TRB->VALISS
				  	nValLiq  -= TRB->VALISS
				  Else
				    nValbase := TRB->VALBASE
				  EndIf
				Endif
				oSection2:Cell("VALBASE"):SetBlock( { || nValBase } )
				oSection2:Cell("VALLIQ" ):SetBlock( { || nValLiq } )				
		#ENDIF
                                                                                
		If lContrRet // Verifica se o sistema esta fazendo controle de retencao de impostos
			If lPccBaixa	// Geracao dos impostos lei 10925 pela baixa
				If TRB->(VALPIS+VALCOF+VALCSLL) > 0  
					If TRB->TIPO $ MVPAGANT 
						If TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
							If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0			                      
								oSection2:Cell("TIPORET"):SetBlock( { || "A" } )
							Endif
						Endif			                                               					
					Else
						If TRB->PRETPIS == "3" .or. TRB->PRETCOF == "3" .or. TRB->PRETCSL == "3"
							If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0
								oSection2:Cell("TIPORET"):SetBlock( { || "A" } )
							Endif
						ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
							oSection2:Cell("TIPORET"):SetBlock( { || "B" } )
						Endif
					Endif
				Endif			
			Else
				If TRB->PRETPIS == "2" .or. TRB->PRETCOF == "2" .or. TRB->PRETCSL == "2"
					oSection2:Cell("TIPORET"):SetBlock( { || "A" } )					
				ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
					oSection2:Cell("TIPORET"):SetBlock( { || "B" } )					
				Else 
					oSection2:Cell("TIPORET"):SetBlock( { || " " } )
				Endif
			Endif
		Endif
		
	 	If lFatura
			oSection2:Cell("TIPORET"):SetBlock( { || "C" } )
		EndIf

		oSection2:PrintLine()
		
		nTitCli++

		If !lFatura
			nVlCliOri += nValBase
		EndIf

		nVlCliLiq += nValLiq
		nVlCliIns += TRB->VALINSS
		nVlCliIrf += TRB->VALIRRF                  
		nVlCliIss += TRB->VALISS 

	 	If TRB->PRETPIS <> "2" .Or. TRB->PRETCOF <> "2" .Or. TRB->PRETCSL <> "2"
			nVlCliPis += TRB->VALPIS
			nVlCliCof += TRB->VALCOF
			nVlCliCsl += TRB->VALCSLL                  
		EndIf	

		If lSest   // So processa se existir o campo E2_SEST
			nVlCliSes += TRB->VALSEST                  
		Endif

		TRB->(dbSkip())
		oReport:IncMeter()
	Enddo	

	oSection1:Finish()
	oSection2:Finish()

	nTitRel   += nTitCli

	oReport:IncMeter()
Enddo


#IFNDEF TOP
	dbSelectArea("SE2")
	dbClearFil()
	RetIndex( "SE2" )
	If !Empty(cIndexSE2)
		FErase (cIndexSE2+OrdBagExt())
	Endif
	dbSetOrder(1)
	TRB->(dbCloseArea())
	fErase( cArqTrab + GetDBExtension() )
	fErase( cArqTrab + OrdBagExt() )
#ELSE
	dbSelectArea("SE2")
	dbCloseArea()
	ChKFile("SE2")
	dbSelectArea("SE2")
	dbSetOrder(1)
	TRB->(dbCloseArea())
#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F865Legendaº Autor ³ Marcio Menon	      º Data ³  09/05/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao da legenda de retencao de impostos.		      º±±
±±º          ³ 								                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 											                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finr865								                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F865Legenda(oReport)

Local lContrRet	:= 	!Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ;
					!Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
					!Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )

If lContrRet
	oReport:PrintText(STR0017)		// A = Os valores de Pis,Cofins e Csll deste titulo foram retidos em outro titulo.
	oReport:PrintText(STR0018)		// B = Os valores de Pis,Cofins e Csll deste titulo se referem a uma previsao, ainda nao foram retidos.
	oReport:PrintText(STR0019)		// C = Os registros referentes a fatura não são incluidos nos totalizadores.
Endif

Return

/*
---------------------------------------------- Release 3 ---------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	  ³ FINR865  ³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Relacao de titulos a pagar com rentencao PIS/Cofins/CSLL   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e  ³ FINR865(void)									           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ Generico 												   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Data    ³    Autor   ³ BOPS ³        Manutencao Efetuada             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º06/11/2007 ³Pedro P Lima³134275³ O relatorio nao considerava o valor    º±±
±±º           ³   TI6434   ³ P10  ³ original do titulo, que era impresso   º±±
±±º           ³            ³      ³ com o valor 0,00 e tabem nao           º±±
±±º           ³            ³      ³ considerava o valor do campo valor liq.º±±
±±º           ³            ³      ³ que era impresso incorretamente.       º±±  
±±º           ³            ³      ³ Foi corrigido o trecho onde a variavel º±±
±±º           ³            ³      ³ nValBase recebe o valor original do    º±±
±±º           ³            ³      ³ titulo e o tratamento do valor liquido.º±± 
±±º           ³            ³      ³ RELEASE 3                              º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UFINENG()

Local cDesc1    := "Relatorio de Titulos a Pagar Geral " // STR0001 //"Imprime a relacao dos titulos a pagar que sofreram retencao de Impostos"
Local cDesc2    := ""
Local cDesc3    := ""
Local wnrel
Local cString   := "SE2" //Contas a Pagar
Local nRegEmp   := SM0->(RecNo())
Local aTam	    := TAMSX3("E2_NUM")

Private titulo  := ""
Private cabec1  := ""
Private cabec2  := ""
Private aLinha  := {}
Private aReturn := { STR0002, 1,STR0003, 1, 2, 1, "",1 }   //"Zebrado"###"Administracao"
Private aOrd    := {STR0004,STR0005} //"Por Codigo Fornecedor"###"Por Nome Fornecedor"
Private cPerg	 := "FIN865"
Private nJuros  := 0
Private nLastKey:= 0
Private nomeprog:= "ENGECORPS"
Private tamanho := "G"
Private lSest   := SE2->(FieldPos("E2_SEST"))	> 0  //Verifica campo de SEST                                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg("FIN865",.T.)})
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ³
//³ mv_par01		 // Data de?   	     ³
//³ mv_par02		 // Data ate?          ³
//³ mv_par03		 // Organiza por?      ³
//³ mv_par04		 // Enviados?          ³
//³ mv_par05		 // De Emissao?	     ³
//³ mv_par06		 // Ate Emissao?       ³
//³ mv_par07		 // De Vencto?		     ³
//³ mv_par08		 // Ate Vencto?        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pergunte("FIN865",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o dos cabe‡alhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Relatorio de Titulos a Pagar Geral "  // STR0007 //"Relacao de Titulos a Pagar com retencao de Impostos"
cabec1 := STR0008 //"Codigo         Nome do Fornecedor             CGC"
If lSest  // So processa se existir o campo E2_SEST
	cabec2 := STR0009 //"     Prf Numero      Pc  Tipo  Dt.Emissao Dt.Vencto  Valor Original           Valor SEST         Valor IRFF           Valor ISS          Valor INSS           Valor PIS        Valor COFINS          Valor CSLL       Valor Liquido"
Else
	cabec2 := STR0010 //"     Prf Numero      Pc  Tipo  Dt Emissao Dt.Vencto  Valor Original                              Valor IRFF           Valor ISS          Valor INSS           Valor PIS        Valor COFINS          Valor CSLL       Valor Liquido"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros	³
//³ mv_par01		 // Do Cliente			³
//³ mv_par02		 // Ate o Cliente		³
//³ mv_par03		 // Da loja				³
//³ mv_par04		 // Ate a loja			³
//³ mv_par05		 // Da DaTa				³
//³ mv_par06		 // Ate Data			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a fun‡„o SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="ENGECORPS"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,"",.T.)

If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
RptStatus({|lEnd| FA865Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	  ³ FA865Imp ³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Imprime relat¢rio dos T¡tulos a Receber c/Retencao de INSS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e  ³ FA865Imp(lEnd,WnRel,cString)						               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd	  - A‡Æo do Codeblock								         ³±±
±±³			  ³ wnRel   - T¡tulo do relat¢rio							         ³±±
±±³			  ³ cString - Mensagem										            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ Generico												               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA865Imp(lEnd,WnRel,cString)

Local CbCont
Local CbTxt
Local cCGCAnt
Local cChaveSe2
Local lContinua	:= .T.
Local nTitCli	:= 0
Local nTitRel	:= 0
Local nVlCliOri	:= 0
Local nVlCliIns	:= 0
Local nVlCliLiq	:= 0
Local nVlTotOri	:= 0
Local nVlTotIns	:= 0
Local nVlTotPis	:= 0
Local nVlTotCof	:= 0
Local nVlTotCsl	:= 0
Local nVlTotIrf	:= 0 
Local nVlCliIrf	:= 0
Local nVlTotIss	:= 0 
Local nVlCliIss	:= 0
Local nVlTotSes	:= 0 
Local nVlCliSes	:= 0
Local nVlCliPis	:= 0
Local nVlCliCof	:= 0
Local nVlCliCsl	:= 0
Local nVlTotLiq	:= 0
Local aCampos	:= {}                                   
Local cCodFor	:= ""
Local cLojFor	:= ""
Local cNomFor	:= ""                       
Local aTamNum	:= TAMSX3("E2_NUM")
Local nOrdem	:= aReturn[8]   
Local nValBase := 0
Local nValLiq	:= 0
Local lFatura  := .F.
Local lContrRet := !Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ; 
				 !Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
				 !Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )
#IFNDEF TOP
	Local nIndexSE2
	Local cIndexSe2
#ENDIF

Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ; 
				 !Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				 !Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				 !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local lCalcIssBx := !Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
							!Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

Local cFilterUser := aReturn[7]
Local cFilADVPL   := ""
Local cFiltroSE2  := ""
aCampos	:= {	{"CODIGO"	,"C",06,0 },;
				{"LOJA"	,"C",02,0 },;
				{"NOMEFOR"	,"C",40,0 },;
				{"CGC"		,"C",14,0 },;
				{"PREFIXO"	,"C",03,0 },;
				{"NUM"		,"C",aTamNum[1],0 },;
				{"PARCELA"	,"C",TamSx3("E2_PARCELA")[1],0 },;
				{"TIPO"		,"C",03,0 },;
				{"EMISSAO"	,"D",08,0 },;
				{"VENCTO"	,"D",08,0 },;
				{"VALBASE"  ,"N",17,2 },;
				{"VALINSS"	,"N",17,2 },;
				{"VALPIS"	,"N",17,2 },;
				{"VALCOF"	,"N",17,2 },;
				{"VALCSLL"	,"N",17,2 },;
				{"VALIRRF"	,"N",17,2 },;
				{"VALISS"	,"N",17,2 },;
				{"VALSEST"	,"N",17,2 },;
				{"VALLIQ"	,"N",17,2 },;
				{"VRETPIS"	,"N",17,2 },;
				{"VRETCOF"	,"N",17,2 },;
				{"VRETCSL"	,"N",17,2 },;
				{"PRETPIS"	,"C",01,0 },;
				{"PRETCOF"	,"C",01,0 },;
				{"PRETCSL"	,"C",01,0 },;              
				{"TRETISS"	,"C",01,0 },;								
				{"FATURA"	,"C",TamSx3("E2_FATURA")[1],0 } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= ""
cbcont	:= 1
li 		:= 80
m_pag 	:= 1


dbSelectArea("SE2")

If nOrdem == 1  //Por Codigo
	dbSetOrder(6)
Else            //Por Nome
	dbSetOrder(2)
Endif

cChaveSe2 := IndexKey()

#IFDEF TOP
	If !Empty(cFilterUser)
		//Transforma a expressão do filtro de ADVPL para Query SQL
		cFilADVPL := PcoParseFil(cFilterUser,"SE2") 
    EndIf
	If nOrdem == 1  //Por Codigo
		cOrder := "CODIGO,LOJA"
	Else            //Por Nome
		cOrder := "NOMEFOR"
	Endif
	
	cQuery := "SELECT A2_COD CODIGO,A2_LOJA LOJA,A2_NOME NOMEFOR,A2_CGC CGC,E2_PREFIXO PREFIXO,"
	cQuery += "E2_NUM NUM,E2_PARCELA PARCELA,E2_TIPO TIPO,E2_EMISSAO EMISSAO,E2_VENCREA VENCTO,"
	cQuery += "E2_IRRF VALIRRF,E2_ISS VALISS,E2_INSS VALINSS,E2_FATURA FATURA,"
	cQuery += "E2_PIS VALPIS,E2_COFINS VALCOF,E2_CSLL VALCSLL,"	
	//Se controla Retencao
	If lContrRet
		cQuery += "E2_VRETPIS VRETPIS,E2_VRETCOF VRETCOF,E2_VRETCSL VRETCSL,"	
		cQuery += "E2_PRETPIS PRETPIS,E2_PRETCOF PRETCOF,E2_PRETCSL PRETCSL,"	
		If lSest  // So processa se existir o campo E2_SEST
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_SEST) VALBASE,"
			cQuery += "E2_SEST VALSEST,"
		Else
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS) VALBASE,"
		Endif	
	Else
		If lSest  // So processa se existir o campo E2_SEST
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL+E2_SEST) VALBASE,"
			cQuery += "E2_SEST VALSEST,"
		Else
			cQuery += "(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL) VALBASE,"
		Endif
	Endif					

	IF lCalcIssBx
		cQuery += "E2_TRETISS TRETISS,"
	Endif

	cQuery += "E2_VALOR VALLIQ"
	cQuery += "FROM "+RetSqlName("SE2")+" SE2,"
	cQuery +=         RetSqlName("SA2")+" SA2 "
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
	cQuery += " AND SA2.A2_FILIAL   = '" + xFilial("SA2") + "'"
	cQuery += " AND SE2.D_E_L_E_T_  <> '*' "
	cQuery += " AND SA2.D_E_L_E_T_  <> '*' "
	cQuery += " AND SE2.E2_FORNECE  =  SA2.A2_COD"
	cQuery += " AND SE2.E2_LOJA	  =  SA2.A2_LOJA"
	cQuery += " AND SE2.E2_FORNECE  between '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += " AND SE2.E2_LOJA     between '" + mv_par03 + "' AND '" + mv_par04 + "'"
	//cQuery += " AND (SE2.E2_INSS > 0 "
	//cQuery += " OR SE2.E2_ISS > 0 "
	//cQuery += " OR SE2.E2_PIS > 0 "
	//cQuery += " OR SE2.E2_COFINS > 0 "
	//cQuery += " OR SE2.E2_CSLL > 0 "         '
	//cQuery += " OR SE2.E2_IRRF > 0 ) "
	cQuery += " AND SE2.E2_VENCREA  between '" + DTOS(mv_par07)  + "' AND '" + DTOS(mv_par08) + "'"
	cQuery += " AND SE2.E2_EMISSAO  between '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
	cQuery += " AND SE2.E2_EMISSAO  <= '"      + DTOS(dDataBase) + "'"
	If !Empty(cFilADVPL)
		cQuery += " AND (" + cFilADVPL + ")"
	Else
		//Coloco o filtro de usuário em outra variável, pois quando seleciona a tabela TRB
		//a variável cFilterUser é zerada.
		cFiltroSE2 := cFilterUser
	EndIf		
	cQuery += " ORDER BY "+ cOrder
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SE2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
#ELSE
	cFiltroSE2 := cFilterUser
	cIndexSe2 := CriaTrab(nil,.f.)
	IndRegua("SE2",cIndexSe2,cChaveSe2,,FR865IndR(cFiltroSE2),STR0011) //"Selecionando Registros..."
	nIndexSE2 := RetIndex("SE2")
	dbSetIndex(cIndexSe2+OrdBagExt())
	dbSetOrder(nIndexSE2+1)
	dbSeek(xFilial("SE2"))

	cArqTrab := CriaTrab( aCampos )
	dbUseArea( .T.,, cArqTrab, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
	If nOrdem == 1  //Por Codigo
		IndRegua("TRB",cArqTrab,"CODIGO+LOJA",,,)
	Else            //Por Nome
		IndRegua("TRB",cArqTrab,"NOMEFOR",,,)
	Endif
	dbSetIndex( cArqTrab +OrdBagExt())

	dbSelectArea("SE2")				

	While SE2->(!Eof())   // SE2
	
		dbSelectArea("SA2")			
		dbSetOrder(1)
		
		If dbSeek(xFilial()+SE2->(E2_FORNECE+E2_LOJA))
			
			If	lContrRet
				nValBase	:= SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS)
				//Titulo nao gerou o Pis,Cofins e Csll
				If !lPccBaixa .and. (Empty(SE2->E2_PRETPIS) .or. Empty(SE2->E2_PRETCOF) .or. Empty(SE2->E2_PRETCSL))
					nValBase += SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL)
				Endif
			Else
				nValBase	:= SE2->(E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL)
			Endif
			If lSest
				nValBase += SE2->E2_SEST
			Endif
			
			dbSelectArea("TRB")
			RecLock("TRB",.T.)	
			TRB->CODIGO		:= SA2->A2_COD
			TRB->LOJA		:= SA2->A2_LOJA
			TRB->NOMEFOR	:= SA2->A2_NOME 
			TRB->CGC		:= SA2->A2_CGC
			TRB->PREFIXO	:= SE2->E2_PREFIXO
			TRB->NUM		:= SE2->E2_NUM
			TRB->PARCELA	:= SE2->E2_PARCELA
			TRB->TIPO		:= SE2->E2_TIPO
			TRB->EMISSAO	:= SE2->E2_EMISSAO
			TRB->VENCTO		:= SE2->E2_VENCREA
			TRB->VALBASE	:= nValBase
			TRB->VALINSS	:= SE2->E2_INSS
			TRB->VALPIS		:= SE2->E2_PIS
			TRB->VALCOF		:= SE2->E2_COFINS
			TRB->VALCSLL	:= SE2->E2_CSLL 
			TRB->VALIRRF	:= SE2->E2_IRRF
			TRB->VALISS		:= SE2->E2_ISS       
			TRB->FATURA		:= SE2->E2_FATURA
			TRB->TRETISS    := SE2->E2_TRETISS
			
			If lSest  // So processa se existir o campo E2_SEST
				TRB->VALSEST   := SE2->E2_SEST  
			Endif
			TRB->VALLIQ		:= SE2->E2_VALOR

			//Se controla retencao
			If lContrRet
				TRB->VRETPIS	:= SE2->E2_VRETPIS
				TRB->VRETCOF	:= SE2->E2_VRETCOF
				TRB->VRETCSL	:= SE2->E2_VRETCSL 
				TRB->PRETPIS	:= SE2->E2_PRETPIS
				TRB->PRETCOF	:= SE2->E2_PRETCOF
				TRB->PRETCSL	:= SE2->E2_PRETCSL 
			Endif			
			MSUnlock()
		Endif
		dbSelectArea("SE2")
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGoTop()
#ENDIF
SetRegua(TRB->(Reccount()))

While TRB->(!Eof())
	IF lEnd
		@PROW()+1,001 PSAY OemToAnsi(STR0012) //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	IncRegua()
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso a funçao PcoParseFil() retorne vazio, posiciono na      ³
	//³ tabela SE2 para fazer o filtro do usuário.				     ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	If Empty(cFilADVPL)	.And. !Empty(cFiltroSE2)
    	dbSelectArea("SE2")
    	dbSetOrder(1)
    	MsSeek(xFilial("SE2")+TRB->PREFIXO+TRB->NUM+TRB->PARCELA+TRB->TIPO+TRB->CODIGO+TRB->LOJA)
		If !SE2->(&cFiltroSE2)
			TRB->(dbSkip())
			Loop
		Endif
	EndIF

	nTitCli		:= 0
	nVlCliOri	:= 0
	nVlCliIns	:= 0
	nVlCliLiq	:= 0
	nVlCliPis	:= 0
	nVlCliCof	:= 0
	nVlCliCsl	:= 0
	nVlCliSes	:= 0
	nVlCliIrf	:= 0
	nVlCliIss	:= 0
	nValBase		:= 0

	@li,  0 PSAY TRB->CODIGO+"-"+TRB->LOJA
	@li, 15 PSAY Substr(TRB->NOMEFOR,1,30)
	@li, 46 PSAY TRB->CGC Picture IIF(Len(Alltrim(TRB->CGC)) == 11 , "@R 999.999.999-99","@R 99.999.999/9999-99")
	li++

	cCodFor		:= TRB->CODIGO
	cLojFor		:= TRB->LOJA
	cNomFor		:= TRB->NOMEFOR                       
	cCGCAnt		:= TRB->CGC
	
	li++
	While TRB->(!EOF()) .And. cCodFor+cLojFor == TRB->(CODIGO+LOJA) .And. cNomFor == TRB->NOMEFOR

		IF li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
		EndIF 
		
		lFatura := .F.

	 	If !Empty(TRB->FATURA) .And. TRB->FATURA == 'NOTFAT'
			lFatura := .T.
		EndIf 

		@li, 05 PSAY TRB->PREFIXO
		@li, 09 PSAY TRB->NUM
		
		@LI, 021 PSAY TRB->PARCELA
		@li, 025 PSAY TRB->TIPO

		nValLiq := If (!lPccBaixa .or. !lContrRet, TRB->VALLIQ, TRB->(VALLIQ-VALPIS-VALCOF-VALCSLL) )
		
		#IFDEF TOP
			@li, 031 PSAY STOD(TRB->EMISSAO)
			@li, 042 PSAY STOD(TRB->VENCTO)
			If	lContrRet
				//Titulo que aglutinou os impostos
				If !lPccBaixa .and. ( Empty(TRB->PRETPIS) .or. Empty(TRB->PRETCOF) .or. Empty(TRB->PRETCSL))
					nValBase := TRB->(VALBASE+VRETPIS+VRETCOF+VRETCSL)
				Else
					nValBase := TRB->VALBASE
				Endif
				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .and. TRB->TRETISS == "2"
					nValBase	-= TRB->VALISS
					nValLiq	-= TRB->VALISS
				Endif
				@li, 053 PSAY nValBase Picture tm (TRB->VALBASE ,15)			
			Else
				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .and. TRB->TRETISS == "2"
					nValBase	:= TRB->VALBASE - TRB->VALISS
					nValLiq	:= TRB->VALLIQ - TRB->VALISS					
				Endif                      
				@li, 053 PSAY nValBase Picture tm (TRB->VALBASE ,15)			
			Endif
		#ELSE
			@li, 031 PSAY TRB->EMISSAO
			@li, 042 PSAY TRB->VENCTO
			//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
			//valor base
			If lCalcIssBx .and. TRB->TRETISS == "2"
				nValBase := TRB->VALBASE - TRB->VALISS
				nValLiq	 -= TRB->VALISS					
            Else
			  If TRB->TRETISS == "2" 
			  	nValBase := TRB->VALBASE - TRB->VALISS
			  	nValLiq  -= TRB->VALISS
			  Else
			    nValbase := TRB->VALBASE
			  EndIf
			Endif
			@li, 053 PSAY nValBase Picture tm (TRB->VALBASE ,15)			

		#ENDIF
		If lSest  // So processa se existir o campo E2_SEST
			@li, 069 PSAY TRB->VALSEST	Picture tm (TRB->VALSEST ,15)
		Endif
		@li, 085 PSAY TRB->VALIRRF		Picture tm (TRB->VALIRRF ,15)
		@li, 101 PSAY TRB->VALISS		Picture tm (TRB->VALISS  ,15)
		@li, 117 PSAY TRB->VALINSS  	Picture tm (TRB->VALINSS ,15)
		@li, 133 PSAY TRB->VALPIS		Picture tm (TRB->VALPIS  ,15)
		@li, 149 PSAY TRB->VALCOF		Picture tm (TRB->VALCOF  ,15)
		@li, 165 PSAY TRB->VALCSLL		Picture tm (TRB->VALCSLL ,15)
		@li, 181 PSAY nValLiq			Picture tm (TRB->VALLIQ  ,15)		

		If lContrRet // Verifica se o sistema esta fazendo controle de retencao de impostos
			If lPccBaixa	// Geracao dos impostos lei 10925 pela baixa
				If TRB->(VALPIS+VALCOF+VALCSLL) > 0  
					If TRB->TIPO $ MVPAGANT 
						If TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
							If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0			                      
								@li, 197 PSAY "A"
							Endif
						Endif			                                               					
					Else
						If TRB->PRETPIS == "3" .or. TRB->PRETCOF == "3" .or. TRB->PRETCSL == "3"
							If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0
								@li, 197 PSAY "A"			                                               
							Endif
						ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
							@li, 197 PSAY "B"			
						Endif
					Endif
				Endif			
			Else
				If TRB->PRETPIS == "2" .or. TRB->PRETCOF == "2" .or. TRB->PRETCSL == "2"
					@li, 197 PSAY "A"
				ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
					@li, 197 PSAY "B"			
				Endif
			Endif
		Endif
		
	 	If lFatura
		 	@li, 198 PSAY "/C"
		EndIf

		li++
		nTitCli++
		If !lFatura
			nVlCliOri += nValBase
		EndIf

		nVlCliLiq += nValLiq
		nVlCliIns += TRB->VALINSS
		nVlCliIrf += TRB->VALIRRF                  
		nVlCliIss += TRB->VALISS 
		
	 	If TRB->PRETPIS <> "2" .Or. TRB->PRETCOF <> "2" .Or. TRB->PRETCSL <> "2"
			nVlCliPis += TRB->VALPIS
			nVlCliCof += TRB->VALCOF
			nVlCliCsl += TRB->VALCSLL                  
		EndIf	
		If lSest   // So processa se existir o campo E2_SEST
			nVlCliSes += TRB->VALSEST                  
		Endif
		TRB->(dbSkip())
	Enddo	
	li++
	IF nVlCliOri > 0 
		SubTot865(nTitCli,nVlCliOri,nVlCliIns,nVlCliLiq,cNomFor,cCgcAnt,nVlCliPis,nVlCliCof,nVlCliCsl,nVlCliSes,nVlCliIrf,nVlCliIss)
	Endif

	nTitRel	  += nTitCli
	nVlTotOri += nVlCliOri
	nVlTotLiq += nVlCliLiq
	nVlTotIns += nVlCliIns       
	nVlTotPis += nVlCliPis
	nVlTotCof += nVlCliCof
	nVlTotCsl += nVlCliCsl
	nVlTotIrf += nVlCliIrf
	nVlTotIss += nVlCliIss
	If lSest  // So processa se existir o campo E2_SEST
		nVlTotSes += nVlCliSes                  
	Endif
Enddo


IF li != 80
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF
	TotGeR865(nVlTotOri,nVlTotIns,nVlTotPis,nVlTotCof,nVlTotCsl,nVlTotLiq,nTitRel,nVlTotIrf,nVlTotIss,nVlTotSes)

	If lContrRet
		IF li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
		EndIF
		//@li, 001 PSAY STR0017 // A = Os valores de Pis,Cofins e Csll deste titulo foram retidos em outro titulo.
		//@li++            
		//@li, 001 PSAY STR0018 // B = Os valores de Pis,Cofins e Csll deste titulo se referem a uma previsao, ainda nao foram retidos.
		//@li++
		//@li, 001 PSAY STR0019  // C = Os registros referentes a fatura não são incluidos nos totalizadores.
	Endif

	Roda(cbcont,cbtxt,"G")
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE2")
	dbClearFil()
	RetIndex( "SE2" )
	If !Empty(cIndexSE2)
		FErase (cIndexSE2+OrdBagExt())
	Endif
	dbSetOrder(1)
	TRB->(dbCloseArea())
	fErase( cArqTrab + GetDBExtension() )
	fErase( cArqTrab + OrdBagExt() )

#ELSE
	dbSelectArea("SE2")
	dbCloseArea()
	ChKFile("SE2")
	dbSelectArea("SE2")
	dbSetOrder(1)
	TRB->(dbCloseArea())
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SubTot865 ³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprimir SubTotal do Relatorio							           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot865()												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function SubTot865(nTitCli,nVlCliOri,nVlCliIns,nVlCliLiq,cNomFor,cCgcAnt,nVlCliPis,nVlCliCof,nVlCliCsl,nVlCliSes,nVlCliIrf,nVlCliIss)

@li,000 PSAY Replicate("-",220)                              
li+=1     
@li,000 PSAY STR0013 + Substr(cNomFor,1,09) //"Total Fornecedor  - "

@li,030 PSAY " ("+ALLTRIM(STR(nTitCli))+" "+IiF(nTitCli > 1,STR0014,STR0015)+")" //"TITULOS"###"TITULO"

@li,053 PSAY nVlCliOri		Picture TM(nVlCliOri,15)
If lSest  // So processa se existir o campo E2_SEST
	@li,069 PSAY nVlCliSes		Picture TM(nVlCliSes,15)
Endif
@li,085 PSAY nVlCliIrf		Picture TM(nVlCliIrf,15)
@li,101 PSAY nVlCliIss		Picture TM(nVlCliIss,15)
@li,117 PSAY nVlCliIns		Picture TM(nVlCliIns,15)
@li,133 PSAY nVlCliPis		Picture TM(nVlCliLiq,15)
@li,149 PSAY nVlCliCof		Picture TM(nVlCliLiq,15)
@li,165 PSAY nVlCliCsl		Picture TM(nVlCliLiq,15)
@li,181 PSAY nVlCliLiq		Picture TM(nVlCliLiq,15)

li++
@li,000 PSAY Replicate("-",220)                            
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TotGeR865³ Autor ³ Nilton Pereira		³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGeR865()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TotGeR865(nVlTotOri,nVlTotIns,nVlTotPis,nVlTotCof,nVlTotCsl,nVlTotLiq,nTitRel,nVlTotIrf,nVlTotIss,nVlTotSes)

@li,000 PSAY Replicate("_",220)
li+= 2
@li,000 PSAY STR0016  //"TOTAL GERAL      ----> "
@li,030 PSAY "("+ALLTRIM(STR(nTitRel))+" "+IIF(nTitRel > 1,STR0014,STR0015)+")"	 //"TITULOS"###"TITULO"
@li,053 PSAY nVlTotOri	   Picture TM(nVlTotOri,15)
If lSest  // So processa se existir o campo E2_SEST
	@li,069 PSAY nVlTotSes		Picture TM(nVlTotSes,15)
Endif
@li,085 PSAY nVlTotIrf		Picture TM(nVlTotIrf,15)
@li,101 PSAY nVlTotIss		Picture TM(nVlTotIss,15)
@li,117 PSAY nVlTotIns	   Picture TM(nVlTotIns,15)
@li,133 PSAY nVlTotPis		Picture TM(nVlTotPis,15)
@li,149 PSAY nVlTotCof		Picture TM(nVlTotCof,15)
@li,165 PSAY nVlTotCsl		Picture TM(nVlTotCsl,15)
@li,181 PSAY nVlTotLiq	   Picture TM(nVlTotLiq,15)
li++
@li,000 PSAY Replicate("_",220)
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR865IndR ³ Autor ³ Nilton Pereira		³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Indregua para impressao do relat¢rio				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                 
±±³ Uso		 ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                           
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                              
#IFNDEF TOP
	Static Function FR865IndR(cFilterSE2)                        
	Local cFiltro                                                                                   
	                                                                        
	cFiltro := 'E2_FILIAL=="'+xFilial("SE2")+'".And.'
	cFiltro += 'E2_FORNECE>="'+mv_par01+'".and.E2_FORNECE<="'+mv_par02+'".And.'
	cFiltro += 'E2_LOJA>="'+mv_par03+'".And.E2_LOJA<="'+mv_par04+'".And.'
	cFiltro += '(E2_ISS>0.OR.E2_INSS>0.OR.E2_PIS>0.OR.E2_COFINS>0.OR.E2_CSLL>0.OR.E2_IRRF>0) .AND.'
	cFiltro += 'DTOS(E2_VENCREA) >="'+DTOS(mv_par07)+'".And.DTOS(E2_VENCREA)<="'+DTOS(mv_par08)+'".And.'
	cFiltro += 'DTOS(E2_EMISSAO)>="'+DTOS(mv_par05)+'".And.DTOS(E2_EMISSAO)<="'+DTOS(mv_par06)+'".And.'
	cFiltro += 'DTOS(E2_EMISSAO)<="'+DTOS(dDataBase)+'"'
	If !Empty(cFilterSE2)
		cFiltro += ' .And. ' + cFilterSE2
	EndIf
	
	Return cFiltro
#ENDIF
