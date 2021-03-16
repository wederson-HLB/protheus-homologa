#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "topconn.ch"
#include "colors.ch"

/*
Funcao      : KIFAT001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Emitir Nota Fiscal Fatura de Serviços de Comunicação - Modelo 21
Autor       : Vitor Bedin
Data        : 09/11/2009
TDN         :
Revisão     : Tiago Luiz Mendonça
Data/Hora   : 07/02/2012
Módulo      : Faturamento.
*/

*-------------------------*
User Function KIFAT001()
*-------------------------*

IF SM0->M0_CODIGO $ "KI/99/8I"
	Begin Sequence
	TelaFiltro()
	End Sequence
Else
	MsgInfo("Programa não disponível para essa empresa!","HLB BRASIL!")
EndIf

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------

*---------------------------
Static Function TelaFiltro()
*---------------------------
Private oDlg
Private cNotaDe   := Space(09)
Private cNotaAte  := Space(09)
Private cSerie    := Space(03)

Begin Sequence

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Emissão Nota Fiscal Modelo 21 - Highwinds do Brasil") FROM 0,0 TO 300,380 OF oMainWnd PIXEL

@ 010,012 To 142,178

@ 030,023 Say "Nota De:" COLOR CLR_HBLUE, CLR_WHITE
@ 029,110 Get cNotaDe Size 40,8

@ 050,023 Say "Nota Ate:" COLOR CLR_HBLUE, CLR_WHITE
@ 049,110 Get cNotaAte Size 40,8

@ 070,023 Say "Série:" COLOR CLR_HBLUE, CLR_WHITE
@ 069,110 Get cSerie Size 40,8

@ 110, 30  Button "_Ok " Size 50,15 ACTION BuscaDados()
@ 110, 95 Button "_Cancelar    " Size 50,15 ACTION Close(oDlg)


ACTIVATE MSDIALOG oDlg CENTERED

End Sequence

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------

*----------------------------------------------------------
Static Function BuscaDados()
*----------------------------------------------------------

Private cNomeArquivo := ""

Begin Sequence

If !Empty(cNotaDe) .Or. !Empty(cNotaAte)
	MontaQuery()
	SQL->(dbGoTop())
Else
	MsgStop("Verifique os parâmetros preenchidos!","Atenção!")
EndIf

If SQL->(!EoF())
	CriaLayout("SQL")
Else
	Alert("Não foram encontrados dados de acordo com o filtro selecionado. Por favor, verifique o filtro!")
EndIf

End Sequence

Return

*---------------------------
Static Function MontaQuery()
*---------------------------

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSF2 :={}
aStruSD2 :={}
aStruSF2:= SF2->(dbStruct())
aStruSD2:= SD2->(dbStruct())

cQuery := "SELECT F2_DOC,F2_SERIE,F2_EMISSAO,F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DUPL, "+Chr(10)+CHR(13)
cQuery += "F2_BASEICM,F2_VALICM,F2_VALMERC,F2_VALBRUT,F2_DESCONT,D2_COD,D2_ITEMPV,D2_PEDIDO, D2_TES, D2_CF ,D2_PICM,D2_FILIAL,D2_DOC,D2_SERIE,"+Chr(10)+CHR(13)
cQuery += "A1_COD, A1_LOJA, A1_NOME,A1_END, A1_EST, A1_MUN, A1_BAIRRO, A1_CGC, A1_INSCR , A1_PESSOA, A1_TIPO" +Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1,"+RetSqlName("SD2")+ " SD2  WHERE "+Chr(10)
cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SF2.F2_FILIAL = '"+xFilial("SF2")+" ' AND SD2.D2_FILIAL = '"+xFilial("SD2")+" ' AND " +Chr(10)
cQuery += "SF2.F2_DOC BETWEEN '"+cNotaDe+"' AND '"+cNotaAte+"' AND "+Chr(10)
cQuery += "SF2.F2_SERIE = '"+cSerie+"' AND "+Chr(10)
cQuery += "SF2.F2_DOC+SF2.F2_SERIE = SD2.D2_DOC+SD2.D2_SERIE AND SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA AND "+Chr(10)
cQuery += "SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY SF2.F2_DOC,SF2.F2_SERIE"

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","F2_EMISSAO","D",08,0)

For nX := 1 To Len(aStruSF2)
	If aStruSF2[nX,2]<>"C"
		TcSetField("SQL",aStruSF2[nX,1],aStruSF2[nX,2],aStruSF2[nX,3],aStruSF2[nX,4])
	EndIf
Next nX

For nX := 1 To Len(aStruSD2)
	If aStruSD2[nX,2]<>"C"
		TcSetField("SQL",aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
	EndIf
Next nX

Return

*---------------------------------------*
Static Function CriaLayout(cNomeArquivo)
*---------------------------------------*

//Declara a variável objeto do relatório
Private oPrint

//Cria os objetos fontes que serão utilizadoas através do método TFont()
Private oFont5      := TFont():New( "Arial",,07,,.F.,,,,,.F. )             // 5
Private oFont07     := TFont():New('Arial',,07,,.F.,,,,.T.,.F.)    // 07
Private oFont07n    := TFont():New('Arial',,08,,.T.,,,,.T.,.F.)    // 07
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
Private oFont20t    := TFont():New('Tahoma',20,20,,.T.,,,,.T.,.F.)  // 20
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

Close(oDlg)

End Sequence

Return

*------------------------------------
Static Function ReportHeader(oPrint)
*------------------------------------

Begin Sequence

//Logo
oPrint:SayBitmap(010,200,"\System\Kilogo.bmp",1090,400)

oPrint:Say(170,1456,"NOTA FISCAL FATURA DE SERVICOS DE TELECOMUNICACAO ",oFont07,,CLR_BLACK)
oPrint:Say(200,1610,"MODELO 22 - SÉRIE C ÚNICA",oFont07,,CLR_BLACK)
oPrint:Say(260,1650,"Nº",oFont20t,,CLR_BLACK)
oPrint:Say(260,1750,Alltrim(SQL->F2_DOC),oFont20,,CLR_BLACK)
oPrint:Say(376,1470,"COD. DIGITAL:",oFont07a,,CLR_BLACK)
oPrint:Say(400,150,"HIGHWINDS DO BRASIL TELECOMUNICACOES LTDA.",oFont07n,,CLR_BLACK)
//oPrint:Say(500,150,Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_COMPCOB)+" "+Alltrim(SM0->M0_BAIRENT)+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - CEP: "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont07n,,CLR_BLACK) TLM 20150916 - Chamado 029522
oPrint:Say(450,150,Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_COMPCOB)+" "+Alltrim(SM0->M0_BAIRENT),oFont07n,,CLR_BLACK)
oPrint:Say(500,150,Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB)+" - CEP: "+Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999")),oFont07n,,CLR_BLACK)
oPrint:Say(550,150,"CNPJ.:"+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont07n,,CLR_BLACK)
oPrint:Say(550,955,"INSCR. EST.: "+Alltrim(Transform(SM0->M0_INSC,"@R 999.999.999.9999")),,CLR_BLACK)
//oPrint:Say(500,150,"Av. Pedro II, 329 - Parte  - São Cristovão - Rio de Janeiro - Brasil 20.941-070",oFont07n,,CLR_BLACK)
//oPrint:Say(550,150,"CNPJ.: 10.892.375/0002-48",oFont07n,,CLR_BLACK)
//oPrint:Say(550,955,"INSCR. EST.: 79.285.536",oFont07n,,CLR_BLACK)
oPrint:Say(470,1470,"NATUREZA DA OPERAÇÃO: ",oFont07a,,CLR_BLACK)
oPrint:Say(540,1470,"DATA DA EMISSÃO: ",oFont07a,,CLR_BLACK)
oPrint:Say(700,180,"USUÁRIO: ",oFont10a,,CLR_BLACK)
oPrint:Say(780,180,"ENDEREÇO: ",oFont10a,,CLR_BLACK)
oPrint:Say(860,180,"MUNICÍPIO: ",oFont10a,,CLR_BLACK)
oPrint:Say(860,1150,"U.F.: ",oFont10a,,CLR_BLACK)
oPrint:Say(940,180,"C.N.P.J: ",oFont10a,,CLR_BLACK)
oPrint:Say(940,1150,"INSCRIÇÃO ESTADUAL: ",oFont10a,,CLR_BLACK)
oPrint:Say(1020,180,"Nº DO CONTRATO: ",oFont10a,,CLR_BLACK)
oPrint:Say(1190,180,"FATURA ",oFont10a,,CLR_BLACK)
oPrint:Say(1348,800,"DESCRIÇÃO DOS SERVIÇOS ",oFont10a,,CLR_BLACK)
oPrint:Say(1348,2020,"VALOR ",oFont10a,,CLR_BLACK)
oPrint:Say(3150,170,"BASE DE CÁLC. DO ICMS ",oFont10a,,CLR_BLACK)
oPrint:Say(3150,685,"ALÍQUOTA",oFont10a,,CLR_BLACK)
oPrint:Say(3150,980,"VALOR DO ICMS",oFont10a,,CLR_BLACK)
//oPrint:Say(3150,1400,"DATA DO PERIODO",oFont10a,,CLR_BLACK)
oPrint:Say(3150,1910,"VALOR TOTAL ",oFont10a,,CLR_BLACK)
oPrint:Say(3310,150,"Emitida nos termos da Portaria CAT 79 de 10/09/2003.",oFont07n,,CLR_BLACK)
ImpCapa()

End Sequence

Return

*-------------------------------------*
Static Function ReportDetail(oPrint)
*-------------------------------------*

Local cMenFixo01   := "Contribuição p/ FUST e FUNTEL 1,5 do valor dos serviços não repassados ao cliente conf. Lei nº 9998/00 e 10052/00."
Local cMsgCircuito := ""
Local cMsgPeriodo  := ""
Local n            := 1
Local cPedido      := ""

//TLM
Local cCli, cDoc, cLojaCli, nBTotal, cSer, cTipoCli
Local nQtdItens    := 0
Local cFil         := xFilial("SD2")

Private nPagina    := 1
Private nLinha     := 0
Private nTotal     := 0
Private aForImp	   := SEPARA(AllTrim(GetMV("MV_P_00003",.F.,)),"/",.F.)

nLinha := 1438

dbSelectArea("SQL")
dbGoTop()

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
	
	cCli	:= SQL->F2_CLIENTE
	cLojaCli:= SQL->F2_LOJA
	cTipoCli:= SQL->A1_TIPO
	nBTotal	:= SQL->F2_VALBRUT
	cDoc	:= SQL->F2_DOC
	cSer 	:= SQL->F2_SERIE
	cPedido	:= SQL->D2_PEDIDO
	
	SC6->(DbSetOrder(2))
	If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
		
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
		
		// TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137
		If Alltrim(SC5->C5_TIPO) == "I"
			oPrint:Say(nLinha,177,Substr(Alltrim(SC5->C5_MENNOTA),1,084),oFont10,,CLR_BLACK)
			nLinha+=60
			oPrint:Say(nLinha,177,Substr(Alltrim(SC5->C5_MENNOTA),85,170),oFont10,,CLR_BLACK)
			nLinha+=120
		Else
			oPrint:Say(nLinha,180,"PRESTAÇÃO DE SERVIÇOS DE TELECOMUNICAÇÕES",oFont10,,CLR_BLACK)
			cMsgCircuito:= "Circuito "+alltrim(SQL->D2_COD)+" "+Alltrim(SC6->C6_DESCRI)
			nLinha+= 60
			If Alltrim(SC6->C6_P_PRO) == "N"
				//Alterado Matheus
				cMsgPeriodo:= "Periodo ("+Alltrim(SC6->C6_P_PER)+") "+Alltrim(Str(SC6->C6_QTDVEN))+"Mbps a R$ "+IIF(SC6->C6_P_VAL==0,Alltrim(Str(SC6->C6_PRCVEN)),Alltrim(Str(SC6->C6_P_VAL)))+"/Mbps"
			Else
				cMsgPeriodo:= "Periodo ("+Alltrim(SC6->C6_P_PER)+") "+Alltrim(Str(SC6->C6_QTDVEN))+"Mbps PRO-RATA a R$ "+Alltrim(Str(SC6->C6_P_VAL))+"/Mbps"
			EndIf
			
			//oPrint:Say(1438,180,Substr(Alltrim(cMsgNota),1,065),oFont10,,CLR_BLACK)
			oPrint:Say(nLinha,177,Substr(Alltrim(cMsgCircuito),1,084),oFont10,,CLR_BLACK)
			oPrint:Say(nLinha,1900,Transform(SC6->C6_VALOR,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
			If Len(Alltrim(cMsgCircuito)) > 84
				nLinha+=60
				cMsgCircuito:=Substr(Alltrim(cMsgCircuito),85,85)+cMsgPeriodo
				oPrint:Say(nLinha,177,Substr(Alltrim(cMsgCircuito),85,85),oFont10,,CLR_BLACK)
			EndIf
			
			nLinha+=60
			oPrint:Say(nLinha,177,Substr(Alltrim(cMsgPeriodo),1,084),oFont10,,CLR_BLACK)
			nLinha+=120
		EndIf
		
		nLinha+=60
		
		nLinha := ChkLinha(nLinha)
	EndIf
	
	oPrint:Say(3310,2100,"Pagina "+(Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont07n,,CLR_BLACK)
	
	nQtdItens++
	
	SQL->(DbSkip())
	
	//RRP - 06/02/2015 - Novo tratamento para impressão da Lei da Transparência e Impostos
	If cDoc+cSer <> SQL->F2_DOC+SQL->F2_SERIE .OR. SQL->(Eof())
		
		//cMenFixo01:= "" //JSS
		If cTipoCli == "F"
			SF2->(DbSetOrder(1))
			If SF2->(DbSeek(xFilial("SF2")+cDoc+cSer+cCli+cLojaCli))
				If (SF2->(FieldPos("F2_TOTIMP")) > 0)
					If SF2->F2_TOTIMP > 0
						cMenFixo01   += " Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99"))+" ("+Alltrim(Transform((SF2->F2_TOTIMP/SF2->F2_VALBRUT)*100,"@E 999,999,999,999.99"))+"%) Fonte: IBPT."
					EndIf
				EndiF
			EndIf
		EndIf
		//Chamada para preencher a mensagem da nota no corpo.
		Memnota(@nLinha,cPedido,CMENFIXO01)
		
		//Impressão dos impostos caso necessário
		ImpImpos(@nLinha, cCli, cDoc, cLojaCli,nBTotal, cSer)
		
		oPrint:EndPage()
		cMenFixo01   := "Contribuição p/ FUST e FUNTEL 1,5 do valor dos serviços não repassados ao cliente conf. Lei nº 9998/00 e 10052/00."
		//Nova Nota
		If SQL->(!Eof())
			oPrint:StartPage()
			oPrint:SetPortrait()
			oPrint:SetpaperSize(9)
			BoxGeral(oPrint)
			ReportHeader(oPrint)
			ImpCapa()
			nLinha	:= 1438
		EndIf
	EndIf
EndDo

//Fecha o arquivo
SQL->(dbCloseArea())

Return

*--------------------------------*
Static Function BoxGeral(oPrint)
*--------------------------------*
//Local L:= 1420
Private oPen := TPen():New(,7,CLR_BLACK)//,oPrint) JSS - 20150526 - Alterado para solucionar o caso 026657

Begin Sequence

oPrint:Box(160,1450,350,2250)   //Numero nota
oPrint:Box(420,1450,600,2250)   //CFOP e DT Emissao

oPrint:Line(500,1790,500,2200)   //Linha
oPrint:Line(580,1700,580,2200)   //Linha

oPrint:Box(650,150,1100,2250)     //Cabeçalho
oPrint:Box(1120,150,1300,2250)    //Fatura

oPrint:Line(1120,330,1300,330)     //Coluna 1


oPrint:Box(1320,150,3100,2250)    //Itens
oPrint:Box(3120,150,3300,2250)    //Rodapé


oPrint:Line(1320,1950,3100,1950)   //Coluna 1
oPrint:Line(3120,650,3300,650)     //Coluna 2
oPrint:Line(3120,900,3300,900)     //Coluna 3
oPrint:Line(3120,1400,3300,1400)   //Coluna 4
oPrint:Line(3120,1750,3300,1750)   //Coluna 5

oPrint:Line(540,150,540,1410)   //Linha

oPrint:Line(743,340,743,2210)   //Usuário
oPrint:Line(823,360,823,2210)   //Endereço
oPrint:Line(903,360,903,1130)   //Municipio
oPrint:Line(903,1230,903,2210)  //UF
oPrint:Line(983,300,983,1130)   //CNPJ
oPrint:Line(983,1525,983,2210)  //IE
oPrint:Line(1063,470,1063,2210) //Contrato

oPrint:Line(1420,150,1420,2250)

/*
For h:=1 to 58
oPrint:Line(L,150,L,2250)   //Linha
L:= L +60
h++
Next
*/

End Sequence

Return

*--------------------------*
Static Function ImpCapa()
*--------------------------*
Local cQry		:= ""
Local nLinFat	:= 0
Local nColFat	:= 0
Local nTotAbat	:= 0

SF3->(DbSetOrder(6))
SF3->(dbSeek(xFilial("SF3")+SQL->F2_DOC+SQL->F2_SERIE))
oPrint:Say(375,1660,Alltrim(SF3->F3_MDCAT79),oFont07,,CLR_BLACK)

dbSelectArea("SF4")
SF4->(DbSetOrder(1))
SF4->(dbSeek(xFilial("SF4")+SQL->D2_TES))
oPrint:Say(470,1800," SERVIÇO TELECOMUNICAÇÕES",oFont07,,CLR_BLACK)
//oPrint:Say(545,1730,Substr(DtoC(SQL->F2_EMISSAO),1,6)+"20"+Substr(DtoC(SQL->F2_EMISSAO),7,2),oFont07,,CLR_BLACK) - RRP - 19/02/2013 - Acerto da impressão
oPrint:Say(545,1730,DtoC(SQL->F2_EMISSAO),oFont07,,CLR_BLACK)
oPrint:Say(700,370,Alltrim(SQL->A1_NOME),oFont10,,CLR_BLACK)
oPrint:Say(780,400,Alltrim(SQL->A1_END),oFont10,,CLR_BLACK)
oPrint:Say(860,400,Alltrim(SQL->A1_MUN),oFont10,,CLR_BLACK)
oPrint:Say(860,1270,Alltrim(SQL->A1_EST),oFont10,,CLR_BLACK)
If SQL->A1_PESSOA = 'J'
	oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 99.999.999/9999-99"),oFont10,,CLR_BLACK)
Else
	oPrint:Say(940,350,Transform(Alltrim(SQL->A1_CGC),"@R 999.999.999-99"),oFont10,,CLR_BLACK)
EndIf
oPrint:Say(940,1575,Alltrim(SQL->A1_INSCR),oFont10,,CLR_BLACK)

//RRP - 09/02/2015 - Tratamento para demonstração das parcelas,valores,datas de vencimento, Chamado: 024311
//Tratamento para as informações da fatura
cQry:=" SELECT E1_PARCELA,E1_VENCREA,E1_VALOR,E1_PREFIXO,E1_NUM,E1_MOEDA,E1_CLIENTE,E1_LOJA FROM "+RETSQLNAME("SE1")
cQry+=" WHERE E1_NUM='"+alltrim(SQL->F2_DUPL)+"' AND E1_PREFIXO='"+alltrim(SQL->F2_PREFIXO)+"' AND E1_FILORIG='"+alltrim(SQL->F2_FILIAL)+"' "
cQry+="   AND E1_CLIENTE='"+alltrim(SQL->F2_CLIENTE)+"' AND E1_LOJA='"+alltrim(SQL->F2_LOJA)+"' AND D_E_L_E_T_='' AND E1_TIPO = 'NF'"

if select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount

nLinFat:= 1140
nColFat:= 380

if nRecCount >0
	oPrint:Say(nLinFat,nColFat,"Parcela:" ,oFont10,,CLR_BLACK)
	oPrint:Say(nLinFat+45,nColFat,"Vencto:" ,oFont10,,CLR_BLACK)
	oPrint:Say(nLinFat+90,nColFat,"Valor:" ,oFont10,,CLR_BLACK)
	
	nColFat+=180
	
	QRYTEMP->(DbGotop())
	//RRP - 02/03/2015 - Ajuste para descontar os impostos do valor total.
	While QRYTEMP->(!EOF())
		nTotAbat := 0
		nTotAbat := SomaAbat(QRYTEMP->E1_PREFIXO,QRYTEMP->E1_NUM,QRYTEMP->E1_PARCELA,"R",QRYTEMP->E1_MOEDA,STOD(QRYTEMP->E1_VENCREA),QRYTEMP->E1_CLIENTE,QRYTEMP->E1_LOJA)
		oPrint:Say(nLinFat,nColFat,QRYTEMP->(E1_PARCELA) ,oFont10,,CLR_BLACK)
		oPrint:Say(nLinFat+45,nColFat,DTOC(STOD((QRYTEMP->E1_VENCREA))) ,oFont10,,CLR_BLACK)
		oPrint:Say(nLinFat+90,nColFat,alltrim(Transform(QRYTEMP->E1_VALOR-nTotAbat,"@E 999,999,999,999.99")) ,oFont10,,CLR_BLACK)
		
		nColFat+=230
		
		QRYTEMP->(DbSkip())
	Enddo
endif

// TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137
SC6->(DbSetOrder(2))
If SC6->(dbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
		If Alltrim(SC5->C5_TIPO) == "I"
			oPrint:Say(3250,970,Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
		Else
			/*RRP - 03/02/2014 - Já está sendo tratado na função ReportDetail.
			oPrint:Say(1438,180,"PRESTAÇÃO DE SERVIÇOS DE TELECOMUNICAÇÕES",oFont10,,CLR_BLACK)*/
			oPrint:Say(3250,250,Transform(SQL->F2_BASEICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
			oPrint:Say(3250,700,Alltrim(Str(SQL->D2_PICM))+"%",oFont10,,CLR_BLACK)
			oPrint:Say(3250,970,Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
			oPrint:Say(3250,1880,Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99"),oFont10,,CLR_BLACK)
		EndIf
	EndIf
EndIf

Return

*----------------------------*
Static Function ChkLinha(nRet)
*----------------------------*
Default nRet := 0

If nRet > 3057
	
	oPrint:EndPage()
	oPrint:StartPage()
	oPrint:SetPortrait()
	oPrint:SetpaperSize(9)
	
	//Molduras externas
	BoxGeral(oPrint)
	//RRP - 03/02/2014 - Ajuste para impressão de uma nova página mesmo que chegou no final da nota.
	If Alltrim(SQL->F2_DOC) = '' .And. SQL->(EOF())
		DbSelectArea("SQL")
		DbGoTop()
	EndIf
	nRet:= 1438
	//Cria o Cabeçalho do Relatório
	ReportHeader(oPrint)
	ImpCapa()
	
	nPagina++
	
	oPrint:Say(3310,2100,"Pagina "+ (Alltrim(str(nPagina)))+"/"+(Alltrim(str(nTOTAL))),oFont07n,,CLR_BLACK)
	
EndIf

Return nRet

/*
Funcao      : Memnota
Parametros  : Valor da linha tual, numero do pedido e mensagem
Retorno     : Nenhum
Objetivos   : Informar abaixo dos itens a mensagems padrão e mensagems do pedido.
Autor       : João Dos Santos Silva
Data        : 22/03/2013
*/
*--------------------------------------------------*
Static Function  Memnota(nLinha,cPedido,CMENFIXO01)
*--------------------------------------------------*

SC5->(DbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cPedido))
	
	// TLM 19/04/2013  - Tratamento de complemento de ICMS - chamado 011137
	If Alltrim(SC5->C5_TIPO) <> "I"
		
		SM4->(DbSetOrder(1))
		If SM4->(DbSeek(xFilial("SM4")+SC5->C5_MENPAD))
			
			oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),1,83),oFont10,,CLR_BLACK)
			
			nLinha+=60
			nLinha := ChkLinha(nLinha)
			
			oPrint:Say(nLinha,180,Substr(Alltrim(SM4->M4_FORMULA),84,83),oFont10,,CLR_BLACK)
			nLinha := ChkLinha(nLinha)
		EndIf
		
		//ALTERADO MATHEUS
		If len(Alltrim(SC5->C5_MENNOTA))>84
			
			nLMenN:=0 //controla a posição da coluna
			nPosMenN:=1 //controla a posição de corte da msg
			
			while !empty(Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,83))
				cMenNota:=Substr(Alltrim(SC5->C5_MENNOTA),nPosMenN,83)
				oPrint:Say(nLinha,180,cMenNota,oFont10,,CLR_BLACK)
				nLMenN+=35
				nPosMenN+=83
				nLinha+=60
				nLinha := ChkLinha(nLinha)
			Enddo
		Else
			oPrint:Say(nLinha,180,Substr(Alltrim(SC5->C5_MENNOTA),1,83),oFont10,,CLR_BLACK)
			nLinha+=60
			nLinha := ChkLinha(nLinha)
		EndIf
	EndIf
	//RRP - 16/01/2015 - Ajuste para não encavalar e cortar a impressão do cMenFixo01
	for nR:=1 to len(cMenFixo01)
		nLinha := ChkLinha(nLinha)
		oPrint:Say(nLinha,180,Substr(Alltrim(cMenFixo01),nR,87),oFont10,,CLR_BLACK)
		nLinha+=60
		nR+=86
	next nR
EndIf

Return

/*
Funcao      : ImpImpos
Parametros  : nLinha,cCli, cDoc, cLojaCli,nBTotal, cSer
Retorno     : Nenhum
Objetivos   : Inclusão dos impostos para as faturas dos clientes contidos no parâmetro MV_P_00003. Chamado 014734.
Autor       : Renato Rezende
Data/Hora   : 27/02/2015
*/
*---------------------------------------------------------------------*
Static Function ImpImpos(nLinha,cCli, cDoc, cLojaCli,nBTotal, cSer)
*---------------------------------------------------------------------*
Local lRet			:=.F.
Local nR, nP, nQ	:= 0
Local aAreaSE1		:= {}

//Inclusão dos impostos para as faturas dos clientes contidos no parâmetro MV_P_00003.
For nR:=1 to Len(aForImp)
	If cCli == aForImp[nR]
		lRet := .T.
	EndIf
Next nR
//Ajuste para impressão do PCC.
If lRet
	aTp := {{"PI-","PIS",0},;
	{"CF-","COFINS",0},;
	{"CS-","CSLL",0},;
	{"IR-","IR",0}}
	
	aAreaSE1  := SE1->(GetArea())
	nVlPcc := 0
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
	//Verificando se possui títulos no financeiro
	For nP:=1 to Len(aTp)
		If SE1->(DbSeek(xFilial("SE1")+cCli+cLojaCli+cSer+cDoc+space(TamSx3("E1_PARCELA")[1])+aTp[nP][1]))
			aTp[nP][3] += SE1->E1_VALOR
			nVlPcc += SE1->E1_VALOR
		EndIf
	Next nP
	//Ajuste para as novas notas, pois parâmetro MV_BR10925 foi alterado
	If nVlPcc <> 0 .AND. DtoS(SC6->C6_DATFAT) >= "20140509"
		nLinha := ChkLinha(@nLinha)
		nLinha+=40
		oPrint:Say(nLinha,180,"RETENÇÕES:",oFont07n,,CLR_BLACK)
		nLinha+=40
		For nQ:=1 to Len(aTp)
			oPrint:Say(nLinha,200,aTp[nQ][2]+": R$ "+Alltrim(Transform(aTp[nQ][3],"@E 999,999,999,999.99")),oFont07,,CLR_BLACK)
			nLinha+=40
		Next nQ
		oPrint:Say(nLinha,200,"Val.Líq.: R$ "+Alltrim(Transform((nBTotal)-(nVlPcc),"@E 999,999,999,999.99")),oFont07,,CLR_BLACK)
	EndIf
	
	RestArea(aAreaSE1)
EndIf

Return
