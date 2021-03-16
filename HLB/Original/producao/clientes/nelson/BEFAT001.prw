#Include "totvs.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

/*
Funcao      : BEFAT001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressão de Fatura.
Autor       : Renato Rezende
Cliente		: Nelson
Data/Hora   : 09/07/2016
*/    
*-----------------------------*
 User Function BEFAT001()
*-----------------------------*
Local lOk 			:= .F.
Local cTitulo		:= "Nelson - Impressão Orçamento"
Local aArea     	:= GetArea()

Private cPerg 	 	:= "BEFAT001"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cNotaDe		:= ""
Private cNotaAte	:= ""
Private	cSerieDe  	:= ""
Private	cSerieAte 	:= ""
Private cLocal		:= "C:\ORC\"
Private cLogo		:= "nelson.bmp"
Private lGrv		:= .T.

If cEmpAnt <> "BE"//Verifica se é a empresa Nelson 
	MsgInfo("Este relatorio não esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

MakeDir(cLocal) //Cria diretorio

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cDataDe   	:= DtoS(mv_par01)
	cDataAte  	:= DtoS(mv_par02)
	cPedidoDe  	:= mv_par03
	cPedidoAte 	:= mv_par04
	
	//Gera o Relatório
	Processa({|| lOk := MontaQuery()},"Gerando o Orçamento...")

	dbSelectArea("SQL")
	ProcRegua(RecCount())
	SQL->(dbGoTop())
	If SQL->(!EOF())
		Do While SQL->(!Eof())
			Processa({|| lGrv := GeraRel("SQL")},"Gerando Orçamento "+Alltrim(SQL->C5_NUM)+"...")
			SQL->(dbSkip())
			//Caso ocorra erro em algum orçamento sair do while
			If !lGrv
				EXIT
			EndIf      	
		EndDo
		If lGrv
			MsgInfo("Orçamentos gerados em C:\ORC\","HLB BRASIL")
		EndIf
	Else
		MsgInfo("Não foram encontrados registros para os parâmetros informados.","HLB BRASIL")
	EndIf
EndIf

SQL->(dbCloseArea())
RestArea(aArea)

Return Nil

Return

/*
Função  : MontaQuery
Retorno : Nenhum
Objetivo: Gera o relatório
kAutor   : Renato Rezende
Data    : 09/07/2016
*/
*-------------------------------*
 Static Function MontaQuery()
*-------------------------------*
Local nX		:= 0
Local i			:= 0
Local cQuery 	:= ""

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStru := {SC5->(dbStruct())}

ProcRegua(Len(aStru))

//Montando a query
cQuery += "SELECT * FROM " +RetSqlName("SC5")+ " " + CRLF
cQuery += "WHERE " + CRLF
cQuery += "	C5_FILIAL = '"+xFilial("SC5")+"' AND " + CRLF		
cQuery += "	(C5_NUM BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND " + CRLF
cQuery += " (C5_EMISSAO BETWEEN '" + cDataDe +"' AND '" + cDataAte +"') AND " + CRLF 
cQuery += "	D_E_L_E_T_ <> '*' AND " + CRLF
cQuery += "	C5_NOTA = '' " + CRLF
cQuery += "ORDER BY C5_EMISSAO+C5_NUM"

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "SQL", .F., .T.)

For i:=1 to len(aStru)
	For nX := 1 To Len(aStru[i])
		If aStru[i][nX,2]<>"C"
			TcSetField("SQL",aStru[i][nX,1],aStru[i][nX,2],aStru[i][nX,3],aStru[i][nX,4])
		EndIf
	Next nX
	IncProc("Buscando dados...")
Next i

Return nil

/*
Função  : GeraRel
Retorno : lGrv
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 09/07/2016
*/
*--------------------------*
 Static Function GeraRel()
*--------------------------*
Local cNomeArq			:= 'Fatura_'+SQL->C5_NUM+"_"+DtoS(SQL->C5_EMISSAO)
Local nExc				:= 0

Private oPrinter
Private oFont7n 		:= TFont():New("Arial",, 7,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont7 			:= TFont():New("Arial",, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9 			:= TFont():New("Arial",, 9,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New("Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)

Private oFont7 			:= TFont():New("Arial",, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont10n 		:= TFont():New("Arial",, 10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10   		:= TFont():New("Arial",, 10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont10i   		:= TFont():New("Arial",, 10,.T.,.F.,5,.T.,5,.T.,.F.,.T.)
Private oFont16   		:= TFont():New("Arial",, 16,,.F.)
Private oFont16n 		:= TFont():New("Arial",, 16,,.T.)

Private oBrush  		:= TBrush():New( , CLR_GRAY )
Private oBrush2  		:= TBrush():New( , CLR_WHITE )
Private oFont11n 		:= TFont():New("Arial",, 12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont26 		:= TFont():New("Arial",, 26,.T.,.T.,7,.T.,7,.T.,.F.)

Private oFont22n 		:= TFont():New("Arial",, 22,.T.,.T.,7,.T.,7,.T.,.F.)

Private nCol1 			:= 0
Private nCol2 			:= 80
Private nCol3 			:= 155
Private nCol4 			:= 230
Private nCol5 			:= 363
Private nCol6 			:= 510
Private nCol7 			:= 579
Private nCol8 			:= 645
Private nCol9 			:= 715
Private nCol10 			:= 774
Private nColC1			:= 576
Private nColC2			:= 563
Private nColC3			:= 660
Private nSalto 			:= 10
Private nLin			:= 0
Private nPage			:= 0
Private nTotal			:= 0
Private nTotIpi			:= 0

//Excluindo orçamento caso exista
If FILE(cLocal+cNomeArq+".pdf")
	nExc := FERASE(cLocal+cNomeArq+".pdf")
	//Nao conseguiu excluir. Stop na geracao dos orçamentos
	If nExc < 0
		lGrv := .F.
		If FError()	== 516
			MsgStop("Erro de gravação, o arquivo deve estar aberto. "+cNomeArq+".pdf","HLB BRASIL")
		Else
			MsgStop("Erro de gravação. Error = "+ str(ferror(),4),'Erro')
    	EndIf
		Return lGrv 
	EndIf
EndIf

oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,,,,,.F.,,.F.)

//Ordem obrigatoria de configuração do relatório
oPrinter:SetResolution(72)
oPrinter:SetLandScape()//Paisagem ou SetPortrait para retrato 
oPrinter:SetPaperSize(9)
oPrinter:SetMargin(135,20,135,20)
oPrinter:cPathPDF := cLocal

//Impressao do cabecalho do relatorio
ImpCabec(@nLin)
       
oPrinter:EndPage()
oPrinter:Preview()                                                                   
oPrinter:= Nil

Return lGrv

/*
Função  : ImpCabec
Retorno : Nenhum
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 09/07/2016
*/
*-------------------------------*
 Static Function ImpCabec(nLin)
*-------------------------------*
Local cPedido 	:= ""
Local cTpFrete	:= ""
Local cDtEntr	:= ""

//Cadastro de Clientes
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+SQL->C5_CLIENTE+SQL->C5_LOJACLI))

//Condição de Pagamento
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+SQL->C5_CONDPAG))

//Tipo do Frete
If Alltrim(SQL->C5_TPFRETE) == "C"
	cTpFrete := "CIF"
ElseIf Alltrim(SQL->C5_TPFRETE) == "F" 
	cTpFrete := "FOB"
ElseIf Alltrim(SQL->C5_TPFRETE) == "T"
	cTpFrete := "TERCEIRO"
ElseIf Alltrim(SQL->C5_TPFRETE) == "S"
	cTpFrete := "SEM FRETE"
EndIf

//Data de Entrega
If SC5->(FieldPos("C5_P_DTENT")) > 0
	cDtEntr := DtoC(SQL->C5_P_DTENT)
EndIf

oPrinter:StartPage()

nLin := 45
//Logo
oPrinter:SayBitmap(nLin , nCol1 , cLogo, 182,66)
nLin += nSalto
oPrinter:SayAlign(nLin, nColC1, "COTAÇÃO",oFont26, 500, 500, CLR_GRAY, 0, 1 )
nLin += nSalto*3.8

oPrinter:SayAlign( nLin,nColC2,"DATA:",oFont10n, 80, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin, nColC3, DtoC(dDataBase),oFont10, 60, 0, CLR_BLACK, 0, 0)
nLin += nSalto

oPrinter:SayAlign(nLin, nColC2, "Cotação nº:",oFont10n, 80, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin, nColC3, Alltrim(SQL->C5_NUM),oFont10, 80, 0, CLR_BLACK, 0, 0)
nLin += nSalto

oPrinter:SayAlign(nLin, nColC2, "Cód. Cliente:",oFont10n, 80, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin, nColC3, Alltrim(SQL->C5_CLIENTE),oFont10, 80, 0, CLR_BLACK, 0, 0 )

oPrinter:SayAlign(nLin,nCol1,AllTrim(SM0->M0_ENDCOB),oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1,AllTrim(SM0->M0_BAIRCOB)+" / "+AllTrim(SM0->M0_ESTCOB),oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto*2

oPrinter:SayAlign(nLin,nColC2, 'Cotação Válida Até: ',oFont10i,80, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin,nColC3, DtoC(SQL->C5_EMISSAO+10),oFont10,80, 0, CLR_BLACK, 0, 0 )

oPrinter:SayAlign(nLin,nCol1, 'Cliente ',oFont10n, 100, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nColC2, 'Enviada por: ',oFont10i, 80, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin,nColC3, Alltrim(UsrRetName(RetCodUsr())),oFont10,80, 0, CLR_BLACK, 0, 0 ) //Retorna o nome do usuario

oPrinter:SayAlign(nLin,nCol1, SA1->A1_NOME,oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1, Alltrim(Substr(Alltrim(SA1->A1_END),1,AT(",",Alltrim(SA1->A1_END))-1)),oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1, Alltrim(Substr(Alltrim(SA1->A1_END),AT(",",Alltrim(SA1->A1_END))+1)),oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1,AllTrim(SA1->A1_BAIRRO)+" / "+AllTrim(SA1->A1_EST),oFont10, 300, 100, CLR_BLACK, 0, 0 )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1, Alltrim(SA1->A1_TEL),oFont10, 100, 100, CLR_BLACK, 0, 0 )
nLin += nSalto*6

//Primeira Tabela
//Colunas
oPrinter:Line( nLin-3 , nCol1, nLin+40 , nCol1, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol2, nLin+40 , nCol2, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol3, nLin+40 , nCol3, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol4, nLin+40 , nCol4, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol5, nLin+40 , nCol5, CLR_GRAY )

//Linhas
oPrinter:Line( nLin-3 , nCol1, nLin-3 , nCol5, CLR_GRAY )
oPrinter:SayAlign(nLin,nCol1,"Prazo de",oFont11n, 60, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin+4,nCol2,"Tipo de Frete",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin+4,nCol4+3,"Termo de Pagamento",oFont11n, 150, 0, CLR_BLACK, 2, 2 )
nLin += nSalto
oPrinter:SayAlign(nLin,nCol1,"Entrega",oFont11n, 60, 0, CLR_BLACK, 2, 2 )
nLin += nSalto*1.5

oPrinter:Line( nLin , nCol1, nLin , nCol5, CLR_GRAY )
oPrinter:SayAlign(nLin+2,nCol1,cDtEntr,oFont10, 60, 0, CLR_BLACK, 2, 0 )
oPrinter:SayAlign(nLin+2,nCol2,cTpFrete,oFont10, 70, 0, CLR_BLACK, 2, 0 )
oPrinter:SayAlign(nLin+2,nCol4,Alltrim(SE4->E4_DESCRI),oFont10, 150, 0, CLR_BLACK, 2, 0 )

nLin += nSalto*1.5
oPrinter:Line( nLin , nCol1, nLin , nCol5, CLR_GRAY )
nLin += nSalto*2

//Impressao dos Itens
ImpItem()

//Impressao do rodape
ImpRdpe()

Return

/*
Função  : ImpItem
Objetivo: Impressao dos itens.
Autor   : Renato Rezende
Data    : 18/07/2016
*/
*--------------------------------*
 Static Function ImpItem()
*--------------------------------*
Local cQuery2	:= ""
Local nRecCount	:= 0
Local nPag		:= 1
Local nVlFor	:= 0
Local nCount	:= 0

If Select("QSC6") > 0
	QSC6->(dbCloseArea())
EndIf

//Montando a query SC6
cQuery2 += "SELECT C6_NUM, C6_PRODUTO, C6_CLI, C6_QTDVEN, C6_DESCRI, C6_PRCVEN, C6_VALOR,B1_IPI, A7_CODCLI FROM " +RetSqlName("SC6")+ " AS C6 " + CRLF
cQuery2 += "JOIN " +RetSqlName("SB1")+ " AS B1 ON B1.D_E_L_E_T_ <> '*' AND B1.B1_COD = C6.C6_PRODUTO AND B1.B1_LOCPAD = C6.C6_LOCAL " + CRLF
cQuery2 += "LEFT JOIN " +RetSqlName("SA7")+ " AS A7 ON A7.D_E_L_E_T_ <> '*' AND A7.A7_CLIENTE = C6.C6_CLI AND A7.A7_LOJA = C6.C6_LOJA AND A7.A7_PRODUTO = C6.C6_PRODUTO " + CRLF 
cQuery2 += "WHERE " + CRLF
cQuery2 += "	C6.C6_FILIAL = '"+xFilial("SC6")+"' AND " + CRLF		
cQuery2 += "	C6.C6_NUM ='"+SQL->C5_NUM+"'  AND " + CRLF
cQuery2 += "	C6.D_E_L_E_T_ <> '*' " + CRLF
cQuery2 += "ORDER BY C6_ITEM"

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery2), "QSC6", .F., .T.)

//Impressão das páginas
//Segunda Tabela
//Colunas
oPrinter:Line( nLin-3 , nCol1, nLin+195 , nCol1, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol2, nLin+195 , nCol2, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol3, nLin+195 , nCol3, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol4, nLin+195 , nCol4, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol6, nLin+195 , nCol6, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol7, nLin+195 , nCol7, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol8, nLin+195 , nCol8, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol9, nLin+195 , nCol9, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol10, nLin+195 , nCol10, CLR_GRAY )

//Linhas
oPrinter:Line( nLin-3 , nCol1, nLin-3 , nCol10, CLR_GRAY )
oPrinter:SayAlign(nLin,nCol1,"CÓD ITEM",oFont11n, 75, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol2,"CÓD CLIENTE",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol3,"QUANTIDADE",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol4,"DESCRIÇÃO",oFont11n, 320, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol6,"VALOR UNIT.",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol7,"TOTAL",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol8,"IPI A INCLUIR",oFont11n, 68, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol9,"VALOR IPI",oFont11n, 62, 0, CLR_BLACK, 2, 2 )

cPedido:= SQL->C5_NUM
QSC6->(DbGoTop())
While cPedido == QSC6->C6_NUM.And.!Empty(QSC6->C6_NUM)
	nCount++
	//Maior que 1 página
	If nLin >= 493
		//Fechando a tabela anterior
		nLin += nSalto*1.5
		oPrinter:Line( nLin , nCol1, nLin , nCol10, CLR_GRAY )
	   
		nPag++
		nCount:=1                                                                
		//Impressão de uma nova página
		ImpPag()		
	EndIf 
	nLin += nSalto*1.5
	oPrinter:Line( nLin , nCol1, nLin , nCol10, CLR_GRAY )
	oPrinter:SayAlign(nLin+2,nCol1,Alltrim(QSC6->C6_PRODUTO),oFont10, 75, 0, CLR_BLACK, 2, 0 )								   	  					//COD ITEM
	oPrinter:SayAlign(nLin+2,nCol2,Alltrim(QSC6->A7_CODCLI),oFont10, 75, 0, CLR_BLACK, 2, 0 )								   	  					//COD CLIENTE
	oPrinter:SayAlign(nLin+2,nCol3,Alltrim(Str(QSC6->C6_QTDVEN)),oFont10, 75, 0, CLR_BLACK, 2, 0 )   				   		   	   					//QUANTIDADE
	oPrinter:SayAlign(nLin+2,nCol4+2,Alltrim(SubStr(Alltrim(QSC6->C6_DESCRI),1,60)),oFont10, 300, 100, CLR_BLACK, 0, 0 )		   					//DESCRICAO
	oPrinter:SayAlign(nLin+2,nCol6+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )														   					//VALOR UNIT
	oPrinter:SayAlign(nLin+2,nCol6+2,Alltrim(Transform(QSC6->C6_PRCVEN,"@E 999,999,999,999.99")),oFont10, 60, 0, CLR_BLACK, 1, 0 )					//VALOR UNIT
	
	oPrinter:SayAlign(nLin+2,nCol7+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )														   					//TOTAL
	oPrinter:SayAlign(nLin+2,nCol7+2,Alltrim(Transform(QSC6->C6_VALOR,"@E 999,999,999,999.99")),oFont10, 58, 0, CLR_BLACK, 1, 0 )  					//TOTAL
	
	oPrinter:SayAlign(nLin+2,nCol8,Alltrim(Str(QSC6->B1_IPI))+"%",oFont10, 75, 0, CLR_BLACK, 2, 0 )								   					//IPI A INCLUIR
	
	oPrinter:SayAlign(nLin+2,nCol9+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )																			//VALOR IPI
	oPrinter:SayAlign(nLin+2,nCol9+2,Alltrim(Transform(QSC6->C6_VALOR*(QSC6->B1_IPI/100),"@E 999,999,999,999.99")),oFont10, 53, 0, CLR_BLACK, 1, 0 )//VALOR IPI
	
	//Armazenando total do orcamento
	nTotal	+= QSC6->C6_VALOR
	nTotIpi	+= QSC6->C6_VALOR*(QSC6->B1_IPI/100)
	
	QSC6->(DbSkip())	
EndDo

//Ajuste na tabela dos Itens.
If nCount < 12 .AND. nPag == 1
	nVlFor:= 12-nCount 
ElseIf nCount < 30
	nVlFor:= 30-nCount
EndIf

for i:=1 to nVlFor
	nLin += nSalto*1.5
	oPrinter:Line( nLin , nCol1, nLin , nCol10, CLR_GRAY )
Next i

nLin += nSalto*1.5
oPrinter:Line( nLin , nCol1, nLin , nCol10, CLR_GRAY )

QSC6->(dbCloseArea())

Return

/*
Função  : ImpPag
Objetivo: Impressao da página nova
Autor   : Renato Rezende
Data    : 17/07/2016
*/
*--------------------------------*
 Static Function ImpPag()
*--------------------------------*

nLin := 45
//Finalizando a página anterior
oPrinter:EndPage()

//Ordem obrigatoria de configuração do relatório
oPrinter:SetResolution(72)
oPrinter:SetLandScape()//Paisagem ou SetPortrait para retrato 
oPrinter:SetPaperSize(9)
oPrinter:SetMargin(135,20,135,20)

oPrinter:StartPage()

//Impressão das páginas
//Colunas
oPrinter:Line( nLin-3 , nCol1, nLin+465 , nCol1, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol2, nLin+465 , nCol2, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol3, nLin+465 , nCol3, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol4, nLin+465 , nCol4, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol6, nLin+465 , nCol6, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol7, nLin+465 , nCol7, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol8, nLin+465 , nCol8, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol9, nLin+465 , nCol9, CLR_GRAY )
oPrinter:Line( nLin-3 , nCol10, nLin+465 , nCol10, CLR_GRAY )

//Linhas
oPrinter:Line( nLin-3 , nCol1, nLin-3 , nCol10, CLR_GRAY )
oPrinter:SayAlign(nLin,nCol1,"CÓD ITEM",oFont11n, 75, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol2,"CÓD CLIENTE",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol3,"QUANTIDADE",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol4,"DESCRIÇÃO",oFont11n, 320, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol6,"VALOR UNIT.",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol7,"TOTAL",oFont11n, 70, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol8,"IPI A INCLUIR",oFont11n, 68, 0, CLR_BLACK, 2, 2 )
oPrinter:SayAlign(nLin,nCol9,"VALOR IPI",oFont11n, 62, 0, CLR_BLACK, 2, 2 )

Return

/*
Função  : ImpRdpe
Objetivo: Impressao do rodape.
Autor   : Renato Rezende
Data    : 17/07/2016
*/
*--------------------------------*
 Static Function ImpRdpe()
*--------------------------------*
nLin += nSalto*2

//Colunas
oPrinter:Line( nLin , nCol8, nLin+45 , nCol8, CLR_GRAY )
oPrinter:Line( nLin , nCol10, nLin+45 , nCol10, CLR_GRAY )

//Linhas
oPrinter:Line( nLin , nCol8, nLin , nCol10, CLR_GRAY )
oPrinter:SayAlign(nLin,nColC2,"SUBTOTAL",oFont11n, 75, 0, CLR_BLACK, 1, 2 )
oPrinter:SayAlign(nLin+2,nCol8+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )
//Valor do BANCO
oPrinter:SayAlign(nLin+2,nCol8,Alltrim(Transform(nTotal,"@E 999,999,999,999.99")),oFont10, 125, 0, CLR_BLACK, 1, 0 )
nLin += nSalto*1.5

oPrinter:Line( nLin , nCol8, nLin , nCol10, CLR_GRAY )
oPrinter:SayAlign(nLin,nColC2,"TOTAL IPI",oFont11n, 75, 0, CLR_BLACK, 1, 2 )
oPrinter:SayAlign(nLin+2,nCol8+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )
//Valor do BANCO
oPrinter:SayAlign(nLin+2,nCol8,Alltrim(Transform(nTotIpi,"@E 999,999,999,999.99")),oFont10, 125, 0, CLR_BLACK, 1, 0 )
oPrinter:SayAlign(nLin,nCol1,"ICMS, PIS/Cofins Inclusos.",oFont10, 600, 100, CLR_BLACK, 0, 0 )
nLin += nSalto*1.5

oPrinter:Line( nLin , nCol8, nLin , nCol10, CLR_GRAY )
oPrinter:SayAlign(nLin,nColC2,"TOTAL COM IPI",oFont11n, 75, 0, CLR_BLACK, 1, 2 )
oPrinter:SayAlign(nLin+2,nCol8+2,"R$",oFont10, 75, 0, CLR_BLACK, 0, 0 )
//Valor do BANCO
oPrinter:SayAlign(nLin+2,nCol8,Alltrim(Transform(nTotal+nTotIpi,"@E 999,999,999,999.99")),oFont10, 125, 0, CLR_BLACK, 1, 0 )
nLin += nSalto*1.5

oPrinter:Line( nLin , nCol8, nLin , nCol10, CLR_GRAY )
nLin += nSalto

oPrinter:SayAlign(nLin,nCol1,"Favor informar caso tenha qualquer dúvida sobre esta cotação.",oFont10, 600, 100, CLR_BLACK, 0, 0 )

Return

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 09/07/2016
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Data De ?"    },;
  					{"02","Data Ate ?"   },;
  					{"03","Nota De ?"    },;
  					{"04","Nota Ate ?"   }}
  					
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	                                        
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja o relatório.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatório.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Nota Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as notas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	
	U_PUTSX1(cPerg,"03","Pedido De ?","Pedido De ?","Pedido De ?","mv_ch3","C",6,0,0,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Nota Final até a qual")
	Aadd( aHlpPor, "se desejá imprimir o relatório.")
	Aadd( aHlpPor, "Caso queira imprimir todas as notas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZ'.")
	
	U_PUTSX1(cPerg,"04","Pedido Ate ?","Pedido Ate ?","Pedido Ate ?","mv_ch4","C",6,0,0,"G","","","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

EndIf
	
Return Nil
