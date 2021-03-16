#Include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

#Define CLR_RGB_VERD1		RGB(57,213,45)    //Cor VERDE em RGB
#Define CLR_RGB_VERD2		RGB(207,244,194)  //Cor VERDE em RGB
#Define CLR_RGB_GRAY		RGB(196,195,195)  //Cor CINZA em RGB


/*
Funcao      : V5FAT005()
Parametros  : lPreview
Retorno     : Nenhum
Objetivos   : Impressão de Fatura
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 08/08/2016
*/
*-----------------------------------------------*
 User Function V5FAT005( lV5FAT, lVisua )
*-----------------------------------------------*
Local lExec         := .T.

Private cLocal		:= GetTempPath()
Private cLogo		:= "\system\V5\imagens\logo.png" 
Private cLogo2		:= "\system\V5\imagens\logo2.png"
Private cFile		:= ""
Private cPerg 	 	:= "V5FAT005"

Private lVisual		:= IIF(ValType(lVisua)<>"L",.T.,lVisua)
Private lV5FAT1		:= IIF(ValType(lV5FAT)<>"L",.F.,lV5FAT)

If !(cEmpAnt $ u_EmpVogel())
	MsgStop( 'Empresa nao autorizada para utilizar essa rotina!', 'HLB BRASIL' )  
	Return
EndIf

If !lV5FAT1
	//Verifica os parâmetros do relatório
	CriaPerg(cPerg)
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF	
Else
	//Caso venha pela rotina automatica
	MV_PAR01 := SF2->F2_DOC
	MV_PAR02 := SF2->F2_DOC
	MV_PAR03 := SF2->F2_SERIE
EndIf

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf

cQuery:= "SELECT * FROM "+RETSQLNAME("SF2")
cQuery+= " WHERE (F2_DOC >= '"+MV_PAR01+"' AND F2_DOC <= '"+MV_PAR02+"' ) "
cQuery+= "   AND F2_SERIE = '"+MV_PAR03+"' "
cQuery+= "   AND D_E_L_E_T_ <> '*' "
cQuery+= "   AND F2_FILIAL = '"+xFilial("SF2")+"' "
cQuery+= "ORDER BY F2_EMISSAO+F2_DOC+F2_SERIE"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL",.T.,.T.)

If SQL->(EOF()) .OR. SQL->(BOF())
	lExec := .F.
EndIf

If lExec
	Processa({|| cFile := MontaRel()})
else
	Aviso("Aviso","Não existe informações.",{"Abandona"},2)	
Endif

Return (cFile)

/*
Função  : MontaRel
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 16/08/2016
*/
*-----------------------------------*
 Static Function MontaRel()
*-----------------------------------*

//ProcRegua(RecCount())
While SQL->(!EOF())
	cFile:= GeraRel()
	SQL->(DbSkip())
EndDo

Return cFile

/*
Função  : GeraRel
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 08/08/2016
*/
*-------------------------------*
 Static Function GeraRel()
*-------------------------------* 
Private oPrinter
Private oFont6n 		:= TFont():New("Arial",3, 6,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont7n 		:= TFont():New("Arial",3, 7,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont7 			:= TFont():New("Arial",3, 7,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont8 	   		:= TFont():New('Arial',3, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9 	   		:= TFont():New('Arial',3, 9,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New('Arial',3, 9,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10n 		:= TFont():New('Arial',3, 10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont11n 		:= TFont():New('Arial',3, 11,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont12   		:= TFont():New("Arial",3, 12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont12n   		:= TFont():New("Arial",3, 12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont17   		:= TFont():New('Arial',3, 17,,.F.)
Private oFont17n 		:= TFont():New('Arial',3, 17,,.T.)

Private oBrush1  		:= TBrush():New( , CLR_RGB_VERD1 )
Private oBrush2  		:= TBrush():New( , CLR_RGB_VERD2 )

Private nCol1 			:= 0
Private nCol2 			:= 14
Private nCol3 			:= 141
Private nCol4 			:= 236
Private nCol5 			:= 313
Private nCol6 			:= 347
Private nCol7 			:= 445
Private nCol8 			:= 487
Private nCol9 			:= 538
Private nSalto 			:= 10
Private nSalto2			:= 12
Private nLin			:= 0
Private nPage			:= 0
Private nTotal			:= 0
Private nTotIpi			:= 0

Private cNomeArq		:= 'Fatura_'+Alltrim(SQL->F2_DOC)+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)
Private cDirBol			:= "\FTP\" + cEmpAnt + "\V5FAT005\"


If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\V5FAT005\" )		
EndIf	

If !lVisual
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.F.,0)
Else
	oPrinter:= FWMSPrinter():New(cNomeArq,IMP_PDF,.F.,,.T.,.F.,,,,,,.T.,0)
EndIf

//Ordem obrigatoria de configuração do relatório
oPrinter:SetResolution(72)
oPrinter:SetPortrait()//Retrato ou SetLandScape para paisagem
oPrinter:SetPaperSize(9)
oPrinter:SetMargin(101,0,101,0)
oPrinter:cPathPDF := cLocal

//Impressao do cabecalho do relatorio
cFile:= ImpCabec(@nLin)	
oPrinter:= Nil

Return (cFile)

/*
Função  : ImpCabec
Retorno : cFile
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 10/08/2016
*/
*-------------------------------*
 Static Function ImpCabec(nLin)
*-------------------------------*

oPrinter:StartPage()

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))

DbSelectArea("SE1")
SE1->(DbSetOrder(2)) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
SE1->(DbSeek(xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_PREFIXO+SQL->F2_DUPL+Space(TamSX3("E1_PARCELA")[1])+"NF"))

SD2->(DbSetOrder(3))
SD2->(DbSeek(xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE))

SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))


nLin := 25
//Logo
oPrinter:SayBitmap(nLin , nCol1 , cLogo, 130,66)
nLin += 10+nSalto
oPrinter:SayAlign(nLin, nCol3, Alltrim(Capital(SM0->M0_NOMECOM)),oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol6, "www.         telecom.com",oFont17, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol6+31, "vogel",oFont17n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol8+18, "PÁGINA",oFont8, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol3, Alltrim(Capital(SM0->M0_ENDENT))+" "+Alltrim(Capital(SM0->M0_COMPENT)),oFont7, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol8+18, "01/01",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol3, Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999"))+" "+Alltrim(Capital(SM0->M0_BAIRCOB))+" - "+Alltrim(Capital(SM0->M0_CIDCOB))+" - "+Alltrim(SM0->M0_ESTCOB)+" - Brasil",oFont7, 500, 500, CLR_BLACK, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol6, "Fone ",oFont17, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol6+33, "0800.800.7878",oFont17n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol3, "CNPJ "+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")),oFont7, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol3, "Inscr. Estadual "+Alltrim(Transform(SM0->M0_INSC,"@R 999/9999999999")),oFont7, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto*2

//Primeiro Box
oPrinter:SayBitmap(nLin , nCol1 , "\system\V5\imagens\fundo4.png", nCol9,120)

nLin += nSalto

nLin += 5
oPrinter:SayAlign(nLin, nCol2, "CLIENTE",oFont9n, 500, 500, CLR_BLACK, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol4, "CÓDIGO CLIENTE",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol5, "PERÍODO DA FATURA",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7, "VENCIMENTO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto*1.5

oPrinter:SayAlign(nLin, nCol2, Alltrim(Capital(SA1->A1_NOME)),oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol4, Alltrim(SC5->C5_P_CID),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol5, DtoC(SC5->C5_P_DTINI)+" à "+DtoC(SC5->C5_P_DTFIM),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7, DtoC(SE1->E1_VENCREA),oFont12, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol2, Alltrim(Capital(SA1->A1_END)),oFont9, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol2, Alltrim(Transform(SA1->A1_CEP,"@R 99999-999"))+" "+Alltrim(Capital(SA1->A1_BAIRRO))+" - "+Alltrim(Capital(SA1->A1_MUN))+" - "+Alltrim(SA1->A1_EST),oFont9, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto
oPrinter:SayAlign(nLin, nCol2, "CNPJ "+Alltrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol5, "TERMINAL NUMÉRICO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7-11, "TOTAL A PAGAR R$",oFont9n, 500, 500, CLR_BLACK, 0, 1 )

nLin += nSalto
oPrinter:SayAlign(nLin, nCol5, Alltrim(Transform(SC5->C5_P_CONTA,"@R 99 9999.9999")),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7-11, Alltrim(Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99")),oFont12, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto*3.8

oPrinter:SayAlign(nLin, nCol2, "DISCRIMINAÇÃO DOS SERVIÇOS",oFont9n, 500, 500, CLR_WHITE, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol8, "VALOR R$",oFont9n, 500, 500, CLR_WHITE, 0, 1 )

//Colunas
nLin += nSalto
oPrinter:Line( nLin , nCol1+1, nLin+540 , nCol1+1, CLR_RGB_VERD1,'02' )
oPrinter:Line( nLin , nCol9-1, nLin+540 , nCol9-1, CLR_RGB_VERD1,'02' )
oPrinter:Line( nLin+540 , nCol1, nLin+540 , nCol9, CLR_RGB_VERD1,'02' )

//Conteudo da Descrição dos Servicos
//Linhas Box1
oPrinter:Line(nLin+33, nCol2, nLin+33, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+120, nCol2, nLin+120, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+134, nCol2, nLin+134, nCol9-15, CLR_RGB_VERD1 )
//Linhas Box2
oPrinter:Line(nLin+182, nCol2, nLin+182, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+257, nCol2, nLin+257, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+271, nCol2, nLin+271, nCol9-15, CLR_RGB_VERD1 ) 
//Linhas Box3
oPrinter:Line(nLin+319, nCol2, nLin+319, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+346, nCol2, nLin+346, nCol9-15, CLR_RGB_VERD1 )
oPrinter:Line(nLin+360, nCol2, nLin+360, nCol9-15, CLR_RGB_VERD1 )
//Linha Total
oPrinter:Line(nLin+511, nCol2, nLin+511, nCol9-15, CLR_RGB_VERD1, '02' )

nLin += nSalto*2

oPrinter:SayAlign(nLin, nCol2, "Serviços Contratados",oFont12n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto2+5 
oPrinter:SayAlign(nLin, nCol2, "Assinatura Mensal",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Franquia",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Chamadas Locais",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Longa Distância",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Chamadas Móvel Local (VC1)",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Móvel dentro do Estado (VC2)",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Internacionais",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Subtotal",oFont11n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont11n, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2

nLin += nSalto2*3
oPrinter:SayAlign(nLin, nCol2, "Utilização Excedente aos Serviços Contratados",oFont12n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto2+5 
oPrinter:SayAlign(nLin, nCol2, "Franquia",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Locais",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Longa Distância",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Chamadas Móvel Local (VC1)",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Móvel dentro do Estado (VC2)",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Chamadas Internacionais",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Subtotal",oFont11n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont11n, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2

nLin += nSalto2*3
oPrinter:SayAlign(nLin, nCol2, "Outros Lançamentos",oFont12n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto2+5
oPrinter:SayAlign(nLin, nCol2, "Juros",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2 
oPrinter:SayAlign(nLin, nCol2, "Multas",oFont9, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol2, "Subtotal",oFont11n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 75, 0, CLR_BLACK, 1, 0 )
nLin += nSalto2

nLin += nSalto2*13
oPrinter:SayAlign(nLin, nCol2, "TOTAL A PAGAR",oFont12n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7,Alltrim(Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99")),oFont12n, 75, 0, CLR_BLACK, 1, 0 )

If File( cLocal+cNomeArq+".pdf" )
	FErase(cLocal+cNomeArq+".pdf")
EndIf

//Visualizar o documento
If lVisual
	oPrinter:Preview()
Else
	oPrinter:Print()
	If CpyT2S( cLocal + cNomeArq + ".pdf" , cDirBol ,.T. )
		cFile := cDirBol + cNomeArq+".pdf"
	Else
		MsgStop( 'Erro na cópia para o servidor, boleto ' + cNomeArq+  ".pdf" )
	EndIf
EndIf
 
SA1->(DbCloseArea())
SE1->(DbCloseArea())

If !lV5FAT1
	SD2->(DbCloseArea())
	SC5->(DbCloseArea())
EndIf

Return (cFile)

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 16/08/2016
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Nota De ?"    },;
  					{"02","Nota Ate ?"   },;
  					{"03","Série ?"  	 }}
  					
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
	Aadd( aHlpPor, "Informe a Nota Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as notas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	
	U_PUTSX1(cPerg,"01","Nota De ?","Nota De ?","Nota De ?","mv_ch1","C",9,0,0,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Nota Final até a qual")
	Aadd( aHlpPor, "se desejá imprimir o relatório.")
	Aadd( aHlpPor, "Caso queira imprimir todas as notas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZ'.")
	
	U_PUTSX1(cPerg,"02","Nota Ate ?","Nota Ate ?","Nota Ate ?","mv_ch2","C",9,0,0,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Série da qual")
	Aadd( aHlpPor, "se desejá imprimir o relatório.")
	
	U_PUTSX1(cPerg,"03","Série ?","Série ?","Série ?","mv_ch3","C",3,0,0,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

EndIf
	
Return Nil
