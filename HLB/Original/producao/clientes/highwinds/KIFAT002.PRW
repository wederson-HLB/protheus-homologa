#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include 'colors.ch'

/*
Funcao      : NKIFAT002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Novo Modelo Nota Fiscal Fatura de Serviços
Autor       : Juliana Mellao
Data        : 06/07/2012
TDN         :
Revisão     : Jean Victor Rocha
Data/Hora   : 26/07/2012
Objetivos   : Acerto geral da customização.
Módulo      : Faturamento.
*/

*-------------------------*
User Function KIFAT002()
*-------------------------*
Private cPerg := "NKIFAT02"
	IF SM0->M0_CODIGO $ "67/KI"
		Begin Sequence
			AjustaSx1()
			Pergunte(cPerg,.T.)
			cNotaDe		:= mv_par01
			cNotaAte	:= mv_par02
			cSerie		:= mv_par03
	
			Processa({|| MontaQuery() })
	
			If SQL->(!EoF())
				CriaLayout("SQL")
			Else
				Alert("Não foi encontrado registros. Por favor, verifique o filtro!")
			EndIf
		End Sequence
	EndIf
Return

*-------------------------*
STATIC Function AjustaSx1()
*-------------------------*
	U_PUTSX1( cPerg, "01","NF Inicial ?" ,"NF Inicial ?","NF Inicial ?"    				,"mv_ch1","C"   , 9     ,0      ,0     ,"G", "","","","", "mv_par01", " "  		 , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero da NF inicial." },     {},         {},        "")
	U_PUTSX1( cPerg, "02","NF Final ? "  ,"NF Final ?"  ,"NF Final ?"    	   				,"mv_ch2","C"   , 9     ,0      ,0     ,"G", "","","","", "mv_par02", " "  	     , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero da NF Final."   },     {},         {},        "")
	U_PUTSX1( cPerg, "03","Serie NF ? "  ,"Serie NF ?"  ,"Serie NF ?"    	   				,"mv_ch3","C"   , 3     ,0      ,0     ,"G", "","","","", "mv_par03", " "  	     , "     " , "      " , "" ,"    "		,"     ","      ","     "  ,"   ", "  " , "  " ,"     ","     ","   ", ""     ," ",   	{"Informe o Numero de Serie da NF."},     {},         {},        "")
Return

*---------------------------
Static Function MontaQuery()
*---------------------------
	Local i
	Local cQuery := ""
	
	If Select("SQL") > 0
		SQL->(dbCloseArea())
	EndIf
	
	aStru := {SF2->(dbStruct()),SD2->(dbStruct()), SE1->(dbStruct())}
	
	ProcRegua(Len(aStru))
	
	cQuery += " Select F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL,"
	cQuery += "		F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,"
	cQuery += "		SD2.D2_QUANT,SD2.D2_PRUNIT,SD2.D2_COD,SD2.D2_ITEMPV,SD2.D2_PEDIDO, SD2.D2_TES,"
	cQuery += "		SD2.D2_CF ,SD2.D2_PICM,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,"
	cQuery += "		SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_END, SA1.A1_EST, SA1.A1_MUN, "
	cQuery += "		SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_INSCR , SA1.A1_PESSOA, SA1.A1_TIPO,"
	cQuery += "		SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,"
	cQuery += "		SC6.C6_VALOR,SC6.C6_FILIAL,SC6.C6_CLI,SC6.C6_LOJA,"
	cQuery += "		SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VENCREA"
	cQuery += " From "+RetSqlName("SF2")+" SF2 inner join (Select D2_QUANT,D2_PRUNIT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,"
	cQuery += "								   						D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE"
	cQuery += "							From "+RetSqlName("SD2")
	cQuery += "							Where D_E_L_E_T_ <> '*') as SD2 on SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE"
	cQuery += "				left outer join(Select A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA, A1_TIPO"
	cQuery += "								From "+RetSqlName("SA1")
	cQuery += "								Where D_E_L_E_T_ <> '*' AND A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += "								) as SA1 on SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA"
	cQuery += "				left outer join(Select C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI"
	cQuery += "								From "+RetSqlName("SC5")
	cQuery += "								Where D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += "								) as SC5 on SD2.D2_PEDIDO = SC5.C5_NUM"
	cQuery += "				left outer join(Select C6_NUM,C6_ITEM,C6_VALOR,C6_FILIAL,C6_CLI,C6_LOJA"
	cQuery += "								From "+RetSqlName("SC6")
	cQuery += "								Where D_E_L_E_T_ <> '*' AND C6_FILIAL = '"+xFilial("SC6")+"'"
	cQuery += "								) as SC6 on SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM"
	cQuery += "				left outer join(Select E1_FILIAL,E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_VENCREA"
	cQuery += "								From "+RetSqlName("SE1")
	cQuery += "								Where D_E_L_E_T_ <> '*' AND E1_FILIAL = '"+xFilial("SE1")+"'"
	cQuery += "								) as SE1 on SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO"
	cQuery += " Where"
	cQuery += "		SF2.D_E_L_E_T_ <> '*'""
	cQuery += " 	AND SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
	
	If !EMPTY(cNotaDe)
		cQuery += "		AND SF2.F2_DOC >= '"+cNotaDe+"'"
	EndIf
	If !EMPTY(cNotaAte)
		cQuery += "		AND SF2.F2_DOC <= '"+cNotaAte+"'"
	EndIf
	If !EMPTY(cSerie)
		cQuery += "		AND SF2.F2_SERIE = '"+cSerie+"'"
	EndIf
	
	TCQuery cQuery ALIAS "SQL" NEW
	
	For i:=1 to len(aStru)
		For nX := 1 To Len(aStru[i])
			If aStru[i][nX,2]<>"C"
				TcSetField("SQL",aStru[i][nX,1],aStru[i][nX,2],aStru[i][nX,3],aStru[i][nX,4])
			EndIf
		Next nX
		IncProc("Buscando dados...")
	Next i
Return


*---------------------------------------
Static Function CriaLayout(cNomeArquivo)
*---------------------------------------
	//Declara a variável objeto do relatório
	Private oPrint
	
	//Cria os objetos fontes que serão utilizadoas através do método TFont()
	Private oFont5      := TFont():New( "Tahoma",,07,,.F.,,,,,.F. )             // 5        *
	Private oFont07     := TFont():New('Arial',,07,,.F.,,,,.T.,.F.)    // 07
	Private oFont07n    := TFont():New('Arial',,08,,.T.,,,,.T.,.F.)    // 07       *
	Private oFont07a    := TFont():New( "Arial",,07,,.t.,,,,,.f. )             // 07
	Private oFont08     := TFont():New('Courier New',08,10,,.F.,,,,.T.,.F.)    // 08
	Private oFont08a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )             // 08
	Private oFont08n    := TFont():New('Courier New',08,10,,.T.,,,,.T.,.F.)    // 08
	Private oFont10a    := TFont():New( "Arial",,10,,.t.,,,,,.f. )             // 10
	Private oFont10     := TFont():New('Tahoma',10,11,,.F.,,,,.T.,.F.)  // 11
	Private oFont10n    := TFont():New('Tahoma',10,11,,.T.,,,,.T.,.F.)  // 11
	Private oFont11     := TFont():New('Tahoma',11,13,,.F.,,,,.T.,.F.)  // 11
	Private oFont11n    := TFont():New('Tahoma',11,13,,.T.,,,,.T.,.F.)  // 11
	Private oFont11a    := TFont():New( "Arial",,13,,.t.,,,,,.f. )      // 11
	Private oFont12     := TFont():New("Arial",12,12,,,,,,.T.,.F.)  // 12
	Private oFont12n    := TFont():New('Tahoma',12,14,,.F.,,,,.T.,.F.)  // 12
	Private oFont12a    := TFont():New( "Arial",,12,,.t.,,,,,.f. )      // 12
	Private oFont13     := TFont():New('Tahoma',13,15,,.T.,,,,.T.,.F.)  // 13
	Private oFont14     := TFont():New('Tahoma',14,16,,.T.,,,,.T.,.F.)  // 14
	Private oFont14a    := TFont():New('Arial' ,,14,,.T.,,,,.T.,.F.)  // 14
	Private oFont15     := TFont():New('Courier New',15,16,,.T.,,,,.T.,.F.)  // 15
	Private oFont18     := TFont():New('Arial',18,20,,.T.,,,,.T.,.T.)   // 18
	Private oFont16     := TFont():New('Arial',16,18,,.T.,,,,.T.,.F.)   // 16
	Private oFont20t    := TFont():New('Tahoma',20,20,,.T.,,,,.T.,.F.)  // 20       *
	Private oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.)   // 20
	Private oFont22     := TFont():New('Arial',22,20,,.T.,,,,.T.,.F.)   // 20
	Private nPagina     := 1
	
	Begin Sequence
		//Cria objeto TMSPrinter()
		oPrint:= TMSPrinter():New( "Impressão de Nota Fiscal da Highwinds Brasil" )
		
		//Página tipo retrato
		oPrint:SetPortrait()
		
		//Inicia uma nova página
		oPrint:StartPage()
		
		//Papel A4
		oPrint:SetpaperSize(9)
		
		//Molduras externas
		BoxGeral(oPrint)
		
		//Cria o Cabeçalho do Relatório
		ReportHeader(oPrint)
		
		//Cria os Detalhes do Relatório
		ReportDetail(oPrint) 
		
		//Preview da Impressao
		oPrint:Preview()
		
		//Selecionar Impressora
		//oPrint:setup()
		
		//Imprime direto na impressora padrão do APx
		//oPrint:Print()
		
		//Finaliza a página
		oPrint:EndPage()
		
		//Finaliza Objeto
		oPrint:End()
		
		//Desativa Impressora
		ms_flush()
	End Sequence
Return

*------------------------------------
Static Function ReportHeader(oPrint)
*------------------------------------
	Begin Sequence
		//Logo
		oPrint:SayBitmap(180,350,"\System\Kilogo.bmp",620,220)
		//oPrint:Say(440,100,"HIGHWINDS DO BRASIL TECNOLOGIA DO BRASIL LTDA",oFont5,,CLR_BLACK)
		oPrint:Say(440,100,"HIGHWINDS DO BRASIL SERVICOS DE TECNOLOGIA DA INFORMACAO LTDA.",oFont5,,CLR_BLACK)
		//oPrint:Say(480,100,"AV. BERNARDINO DE CAMPOS, 98 - 11º ANDAR - SALA 11 - PARAISO - CEP 04004-040 - SÃO PAULO",oFont5,,CLR_BLACK)
		oPrint:Say(480,100,Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_COMPCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " -  CEP " + Alltrim(SM0->M0_CEPCOB) + " - " + Alltrim(SM0->M0_CIDCOB)+ " - " +AllTrim(SM0->M0_ESTCOB),oFont5,,CLR_BLACK)
	
		//Cabeçalho
		oPrint:Say(170,1310,"FATURA",oFont10n,,CLR_BLACK)
		oPrint:Say(170,1830,"Nº",oFont10n,,CLR_BLACK)
		//oPrint:Say(260,1310,"AV. BERNARDINO DE CAMPOS, 98    -    11º ANDAR     -     PARAISO",oFont07n,,CLR_BLACK)
		oPrint:Say(260,1310,Alltrim(SM0->M0_ENDCOB)+" - " + Alltrim(SM0->M0_COMPCOB)+" - "+AllTrim(SM0->M0_BAIRCOB),oFont07n,,CLR_BLACK)
		//oPrint:Say(300,1310,"SÃO PAULO                         -                        ESTADO DE SÃO PAULO",oFont07n,,CLR_BLACK)
		oPrint:Say(300,1310, Alltrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB),oFont07n,,CLR_BLACK)
		oPrint:Say(350,1310,"CNPJ: "+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont07n,,CLR_BLACK)
	
		IF !EMPTY(SM0->M0_INSC)
			oPrint:Say(350,1800,"INSCR. EST.: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),oFont07n,,CLR_BLACK)
		ENDIF
	
		oPrint:Say(400,1310,"NATUREZA DA OPERAÇÃO: ",oFont07n,,CLR_BLACK)
		oPrint:Say(450,1310,"DATA DE EMISSÃO: ",oFont07n,,CLR_BLACK)
		//Destinatario
		oPrint:Say(600,1060,"DESTINATÁRIO",oFont10n,,CLR_BLACK)
		oPrint:Say(700,180,"NOME: ",oFont07n,,CLR_BLACK)
		oPrint:Say(750,180,"ENDEREÇO: ",oFont07n,,CLR_BLACK)
		oPrint:Say(750,1250,"CEP: ",oFont07n,,CLR_BLACK)
		oPrint:Say(800,180,"MUNICÍPIO: ",oFont07n,,CLR_BLACK)
		oPrint:Say(800,1250,"UF: ",oFont07n,,CLR_BLACK)
		oPrint:Say(850,180,"CNPJ: ",oFont07n,,CLR_BLACK)
	
		IF !EMPTY(SQL->A1_CGC)
			oPrint:Say(850,1250,"INSCRIÇÃO ESTADUAL: ",oFont07n,,CLR_BLACK)
		ENDIF
	
		oPrint:Say(900,180,"VENC.",oFont07n,,CLR_BLACK)
		//Serviços
		//oPrint:Say(1040,150,"QUANT.",oFont07n,,CLR_BLACK)
		//oPrint:Say(1040,400,"UNID.",oFont07n,,CLR_BLACK)
		oPrint:Say(1040,560,"DESCRIÇÃO DOS SERVIÇOS",oFont07n,,CLR_BLACK)
		//oPrint:Say(1040,1600,"PREÇO UNITÁRIO",oFont07n,,CLR_BLACK)
		oPrint:Say(1040,1965,"PREÇO TOTAL",oFont07n,,CLR_BLACK)
		oPrint:Say(3100,1600,"VALOR R$",oFont07n,,CLR_BLACK)
		oPrint:Say(3200,1400,"VALOR TOTAL DA FATURA R$",oFont07n,,CLR_BLACK)
	End Sequence
Return

*-------------------------------------*
Static Function ReportDetail(oPrint)
*-------------------------------------*
	Local cMenFixo01   := ""
	Local cMsgCircuito := ""
	Local cMsgPeriodo  := ""
	Local n            := 1
	Local cPedido      := ""
	
	//TLM
	Local cCli, cDoc, cSerie
	Local nQtdItens    := 0
	Local cFil         := xFilial("SD2")
	
	Private nPagina    := 1
	Private nLinha     := 1080
	Private nTotal     := 0
	
	dbSelectArea("SQL")
	dbGoTop()
	
	//RRP - 16/01/2015 - Tratamento referente lei transparência. Chamado 023913.
	If SQL->A1_TIPO == "F"
		SF2->(DbSetOrder(1))
	 	If SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
			If (SF2->(FieldPos("F2_TOTIMP")) > 0)
				If SF2->F2_TOTIMP > 0
				 	cMenFixo01   += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
	    		EndIf
	   		EndiF
		EndIf
	EndIf
	
	cDoc    := SQL->F2_DOC
	cSer	:= SQL->F2_SERIE
	cPedido := SQL->D2_PEDIDO
	
	If Select("CONT") > 0
		CONT->(dbCloseArea())
	EndIf
	
	cQuery := "SELECT COUNT(*)  AS QTD"+Chr(10)
	cQuery += " FROM "+RetSqlName("SD2")+Chr(10)
	cQuery += " WHERE  D2_FILIAL ="+cFil+Chr(10)
	cQuery += " AND D2_PEDIDO ='"+Alltrim(cPedido)+"'"
	cQuery += " AND D2_SERIE  ='"+Alltrim(cSer)+"'"
	cQuery += " AND D2_DOC    ='"+Alltrim(cDoc)+"'"
	cQuery += " AND D_E_L_E_T_ <> '*' "
	
	TCQuery cQuery ALIAS "CONT" NEW
	
	nQtdItens := CONT->QTD
	
	ProcRegua(nQtdItens)
	
	CONT->(DbCloseArea())
	
	If nQtdItens <= 5
		nTotal:=1
	ElseIf nQtdItens <=11
		nTotal:=2
	ElseIf nQtdItens <=16
		nTotal:=3
	EndIf
	
	ImpCapa() 
	
	While SQL->F2_DOC <> '' .And. SQL->(!EOF())
		If cDoc+cSer <> SQL->F2_DOC+SQL->F2_SERIE
			
			//Chamada para preencher a mensagem da nota no corpo. JSS - 
        	Memnota(nLinha,cPedido,CMENFIXO01)
			oPrint:EndPage()
			oPrint:StartPage()
			oPrint:SetPortrait()
			oPrint:SetpaperSize(9)
			BoxGeral(oPrint)
			ReportHeader(oPrint)
			ImpCapa()
			nLinha:= 1080
			cDoc:= SQL->F2_DOC
			cSer:= SQL->F2_SERIE
			//RRP - 26/01/2015 - Tratamento referente lei transparência. Chamado 023913.
			cMenFixo01:= ""
			If SQL->A1_TIPO == "F"
				SF2->(DbSetOrder(1))
			 	If SF2->(DbSeek(xFilial("SF2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))
					If (SF2->(FieldPos("F2_TOTIMP")) > 0)
						If SF2->F2_TOTIMP > 0
						 	cMenFixo01   += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
			    		EndIf
			   		EndiF
				EndIf
			EndIf
		EndIf
	
		SC6->(DbSetOrder(2))
		If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
	
			cMsgCircuito:= Alltrim(SC6->C6_DESCRI)
			nLinha+=40
	
			oPrint:Say(nLinha,160,Substr(Alltrim(cMsgCircuito),1,160),oFont07,,CLR_BLACK)
			//oPrint:Say(nLinha,1560,Transform(SC6->C6_VALOR,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)
			oPrint:Say(nLinha,1960,Transform(SC6->C6_VALOR,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)
	
			If Len(Alltrim(cMsgCircuito)) > 160
				nLinha+=30
				cMsgCircuito:=Substr(Alltrim(cMsgCircuito),161,160)+cMsgPeriodo
				oPrint:Say(nLinha,160,Substr(Alltrim(cMsgCircuito),161,160¦),oFont07,,CLR_BLACK)
			EndIf
	
			nLinha+=40
			oPrint:Say(nLinha,160,Substr(Alltrim(cMsgPeriodo),1,084),oFont5,,CLR_BLACK)
			nLinha+=40
	
			nLinha+=30
	
			ChkLinha()
		EndIf
	
		oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK)
	
		SQL->(DbSkip())
	EndDo
	 
	Memnota(nLinha,cPedido,CMENFIXO01)  
	
	//Fecha o arquivo
	SQL->(dbCloseArea())
Return  .T.

//-------------------------------------------------------------------------------------------------------------------------------------------------

*------------------------------*
Static Function BoxGeral(oPrint)
*------------------------------*
	Local L:= 1420
	Private oPen := TPen():New(,7,CLR_BLACK)//,oPrint) // TLM - 26/05/2015 Apos atualização o função TPen() passou a utizar a seguinte estrutura oPen := TPen():New(,7,CLR_BLACK) caso contrario gera erro.

	
	Begin Sequence
	
		oPrint:Box(155,90,530,1250)     //Logo
		oPrint:Box(155,1270,530,2250)   //Numero nota
	
		oPrint:Box(570,90,970,2250)     //Destinatário
		oPrint:Box(1010,90,3050,2250)   //Itens
		oPrint:Box(3150,1880,3050,2250) //valor
		oPrint:Box(3250,1880,3150,2250) //valor total da fatura
	
		oPrint:Line(1080,90,1080,2250)  //Linha destinatário
	
		//oPrint:Line(1010,320,3050,320)   //Coluna 1
		//oPrint:Line(1010,570,3050,570)   //Coluna 2
		//oPrint:Line(1010,1550,3050,1550) //Coluna 3
		oPrint:Line(1010,1880,3050,1880)   //Coluna 4
	
	End Sequence
Return

*-----------------------*
Static Function ImpCapa()
*-----------------------*
	oPrint:Say(170,1910,Alltrim(SQL->F2_DOC),oFont10n,,CLR_BLACK)
	
	SF3->(DbSetOrder(6))
	SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE))
	
	dbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SQL->D2_TES))
	oPrint:Say(400,1700,"SERVIÇOS",oFont07,,CLR_BLACK)
	//oPrint:Say(450,1600,Substr(DtoC(SQL->F2_EMISSAO),1,6)+"20"+Substr(DtoC(SQL->F2_EMISSAO),7,2),oFont07,,CLR_BLACK) - RRP - 19/02/2013 - Acerto da impressão
	oPrint:Say(450,1600,DtoC(SQL->F2_EMISSAO),oFont07,,CLR_BLACK)
	oPrint:Say(700,300,Alltrim(SQL->A1_NOME),oFont07,,CLR_BLACK)
	oPrint:Say(750,370,Alltrim(SQL->A1_END),oFont07,,CLR_BLACK)
	oPrint:Say(750,1400,Alltrim(SA1->A1_CEP),oFont07,,CLR_BLACK)
	oPrint:Say(800,365,Alltrim(SQL->A1_MUN),oFont07,,CLR_BLACK)
	oPrint:Say(800,1340,Alltrim(SQL->A1_EST),oFont07,,CLR_BLACK)
	//oPrint:Say(900,290,Substr(DtoC(SQL->E1_VENCREA),1,6)+"20"+Substr(DtoC(SQL->E1_VENCREA),7,2),oFont07,,CLR_BLACK) - RRP - 19/02/2013 - Acerto da impressão
	oPrint:Say(900,290,DtoC(SQL->E1_VENCREA),oFont07,,CLR_BLACK)
	
	If SQL->A1_PESSOA = 'J' .AND. !EMPTY(SQL->A1_CGC)
		oPrint:Say(850,290,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont07,,CLR_BLACK)
	Else
		oPrint:Say(850,290,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont07,,CLR_BLACK)
	EndIf
	
	oPrint:Say(850,1600,Alltrim(SQL->A1_INSCR),oFont07,,CLR_BLACK)
	
	//VALORES DO FINAL DA FATURA
	oPrint:Say(3100,1960,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)
	oPrint:Say(3200,1960,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont07,,CLR_BLACK)
Return

*------------------------*
Static Function ChkLinha()
*------------------------*
	If nLinha > 2790
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SetPortrait()
		oPrint:SetpaperSize(9)
		//Molduras externas
		BoxGeral(oPrint)
		//Cria o Cabeçalho do Relatório
		ReportHeader(oPrint)
		ImpCapa()
	
		nLinha:= 1080
		nPagina++
		oPrint:Say(3350,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont5,,CLR_BLACK)
	EndIf

 /*
Funcao      : Memnota
Parametros  : Valor da linha tual, numero do pedido e mensagem
Retorno     : Nenhum
Objetivos   : Informar abaixo dos itens a mensagems padrão e mensagems do pedido.
Autor       : João Dos Santos Silva 
Data        : 25/03/2013
*/    
*--------------------------------------------------*
Static Function  Memnota(nLinha,cPedido,CMENFIXO01)    
*--------------------------------------------------*

	
	SC5->(DbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cPedido))
		SM4->(DbSetOrder(1))
		If SM4->(DbSeek(xFilial("SM4")+SC5->C5_MENPAD))
			oPrint:Say(nLinha,600,Substr(Alltrim(SM4->M4_FORMULA),1,53),oFont07,,CLR_BLACK)
	
			nLinha+=30
			ChkLinha()
	
			oPrint:Say(nLinha,600,Substr(Alltrim(SM4->M4_FORMULA),84,53),oFont07,,CLR_BLACK)
			ChkLinha()
	
			if len(Alltrim(SC5->C5_MENNOTA))>131
				nLMenN:=0  //controla a posição da coluna
				nPosMenN:=1 //controla a posição de corte da msg
	
				while !empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,131))
					cMenNota:=Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,131)
					// DFL - Alterada a distancia de 600 para 160
					oPrint:Say(nLinha,131,cMenNota,oFont07,,CLR_BLACK)
					nLMenN+=15
					nPosMenN+=131
					nLinha+=60
					ChkLinha()
				enddo
			else
				// DFL - Alterada a distancia de 600 para 160
				oPrint:Say(nLinha,131,Substr(Alltrim(SC5->C5_MENNOTA),1,131),oFont07,,CLR_BLACK)
				nLinha+=60
				ChkLinha()
			endif
		Else
			If Len(Alltrim(SC5->C5_MENNOTA))>131
	
				nLMenN:=0   //controla a posição da coluna
				nPosMenN:=1 //controla a posição de corte da msg
	
				while !empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,131))
					cMenNota:=Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,131)
					// DFL - Alterada a distancia de 600 para 160
					oPrint:Say(nLinha,131,cMenNota,oFont07,,CLR_BLACK)
					nLMenN+=15
					nPosMenN+=131
					nLinha+=60
					ChkLinha()
				enddo
			else
				// DFL - Alterada a distancia de 600 para 131
				oPrint:Say(nLinha,131,Substr(Alltrim(SC5->C5_MENNOTA),1,131),oFont07,,CLR_BLACK)
				nLinha+=60
				ChkLinha()
			endif
		EndIf
		
		//RRP - 26/01/2015 - Inclusão da Mensagem para Lei da Transparencia. Chamado 023913.
		for nR:=1 to len(cMenFixo01)
			ChkLinha()
			oPrint:Say(nLinha,131,Substr(Alltrim(cMenFixo01),nR,87),oFont07,,CLR_BLACK)
			nLinha+=60
			nR+=86
		next nR
	EndIf
	

Return
