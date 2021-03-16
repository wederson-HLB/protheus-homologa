#Include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

#Define CLR_RGB_VERD1		RGB(57,213,45)    //Cor VERDE em RGB
#Define CLR_RGB_VERD2		RGB(224,247,214)  //Cor VERDE em RGB
#Define CLR_RGB_VERD3		RGB(237,252,235)  //Cor VERDE em RGB


/*
Funcao      : V5FAT010()
Parametros  : lPreview
Retorno     : Nenhum
Objetivos   : Impressão de Fatura Modelo 21
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 30/08/2016
*/
*-----------------------------------------------*
 User Function V5FAT010( lV5FAT, lVisua )
*-----------------------------------------------*
Local lExec         := .T.

Private cLocal		:= GetTempPath()
Private cLogo		:= "\system\V5\imagens\logo3.png" 
Private cFile		:= ""
Private cPerg 	 	:= "V5FAT010"

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
Private oFont8n	   		:= TFont():New('Arial',3, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont9 	   		:= TFont():New('Arial',3, 9,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont9n			:= TFont():New('Arial',3, 9,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10 		:= TFont():New('Arial',3, 10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont10n 		:= TFont():New('Arial',3, 10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont11n 		:= TFont():New('Arial',3, 11,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont12   		:= TFont():New("Arial",3, 12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont12n   		:= TFont():New("Arial",3, 12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont13   		:= TFont():New("Arial",3, 13,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont14   		:= TFont():New("Arial",3, 14,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont17   		:= TFont():New('Arial',3, 17,,.F.)
Private oFont17n 		:= TFont():New('Arial',3, 17,,.T.)

Private oBrush1  		:= TBrush():New( , CLR_RGB_VERD1 )
Private oBrush2  		:= TBrush():New( , CLR_RGB_VERD2 )
Private oBrush3			:= TBrush():New( , CLR_RGB_VERD3 )
Private oBrush4			:= TBrush():New( , CLR_WHITE )

Private nCol1 			:= 0
//Cabecalho
Private nCol2c 			:= 29
Private nCol3c 			:= 163
Private nCol4c 			:= 247
Private nCol5c 			:= 323
Private nCol6c			:= 383
Private nCol7c 			:= 434
Private nCol8c 			:= 467
Private nCol9c 			:= 527
//Corpo
Private nCol1i 			:= 37
Private nCol2i			:= 295
Private nCol3i 			:= 345
Private nCol4i 			:= 395
Private nCol5i			:= 455
Private nCol6i			:= 495
//Rodape
Private nCol2r 			:= 93
Private nCol3r			:= 142
Private nCol4r 			:= 215
Private nCol5r 			:= 279
Private nCol6r			:= 308
Private nCol7r			:= 436
Private nCol8r			:= 547

Private nSalto 			:= 10
Private nSalto2			:= 15
Private nLin			:= 0
Private nLin2			:= 0
Private nPage			:= 0
Private nTotal			:= 0

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
oPrinter:SetMargin(0,0,0,0)
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
Local cFone := "" 

oPrinter:StartPage()

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))

DbSelectArea("SE1")
SE1->(DbSetOrder(2)) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
SE1->(DbSeek(xFilial("SE1")+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_PREFIXO+SQL->F2_DUPL+Space(TamSX3("E1_PARCELA")[1])+"NF"))

SD2->(DbSetOrder(3))
SD2->(DbSeek(xFilial("SD2")+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA))

SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))

//Retangulo verde escuro
oPrinter:Fillrect( {nLin, nCol1, nLin+82, 609 }, oBrush2, "-2")

nLin += nSalto*2
//Logo
oPrinter:SayBitmap(nLin-5 , nCol2c , cLogo, 132,66)
oPrinter:SayAlign(nLin-5, nCol9c, "VIA ÚNICA",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin-5, nCol7c, "Nº",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin-5, nCol7c+15, Alltrim(SQL->F2_DOC),oFont8, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol3c, Alltrim(SM0->M0_NOMECOM),oFont7n, 500, 500, CLR_BLACK, 0, 1 )

nLin += nSalto                            

oPrinter:SayAlign(nLin, nCol3c, Alltrim(Capital(SM0->M0_ENDENT))+" "+Alltrim(Capital(SM0->M0_COMPENT)),oFont7, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7c, "MODELO 21",oFont8, 500, 500, CLR_BLACK, 0, 1 )

nLin += nSalto
oPrinter:SayAlign(nLin, nCol3c, Alltrim(Transform(SM0->M0_CEPCOB,"@R 99999-999"))+" "+Alltrim(Capital(SM0->M0_BAIRCOB))+" - "+Alltrim(Capital(SM0->M0_CIDCOB))+" - "+Alltrim(SM0->M0_ESTCOB)+" - Brasil",oFont7, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7c, "SÉRIE 001",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol9c, "CLASSE 3",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

If !Empty(SM0->M0_FAX)
	cFone:="Fone +55 ("+Alltrim(SubStr(SM0->M0_TEL,4,2))+") "+Alltrim(Transform(SubStr(SM0->M0_TEL,7,8),"@R 9999.9999"))+" - Fax +55 ("+Alltrim(SubStr(SM0->M0_FAX,4,2))+") "+Alltrim(Transform(SubStr(SM0->M0_FAX,7,8),"@R 9999.9999"))
Else
	cFone:="Fone +55 ("+Alltrim(SubStr(SM0->M0_TEL,4,2))+") "+Alltrim(Transform(SubStr(SM0->M0_TEL,7,8),"@R 9999.9999"))
EndIf

oPrinter:SayAlign(nLin, nCol3c, cFone,oFont7, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

oPrinter:SayAlign(nLin, nCol3c, "CNPJ "+Alltrim(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"))+" - Inscr. Estadual "+Alltrim(Transform(SM0->M0_INSC,"@R "+u_V5IEMasc(SM0->M0_ESTCOB))),oFont7, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol7c, "NOTA FISCAL - FATURA",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

oPrinter:SayAlign(nLin, nCol7c, "DE SERVIÇO DE COMUNICAÇÃO",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto*2

//Primeiro Box
oPrinter:SayBitmap(nLin , 241 , "\system\V5\imagens\fundo6.png", 325,66)

nLin += 5
oPrinter:SayAlign(nLin, nCol2c, "SACADO",oFont9n, 500, 500, CLR_BLACK, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol4c, "CID/CONTRATO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol5c, "ANO/MÊS REF",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol6c, "DATA DA EMISSÃO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol8c, "VENCIMENTO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto*1.2

oPrinter:SayAlign(nLin, nCol2c, Alltrim(Capital(SA1->A1_NOME)),oFont10, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol4c, Alltrim(SC5->C5_P_CID),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol5c, Alltrim(SC5->C5_P_AM),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol6c, DtoC(StoD(SQL->F2_EMISSAO)),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin-2, nCol8c, DtoC(SE1->E1_VENCREA),oFont14, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

oPrinter:SayAlign(nLin, nCol2c, Alltrim(Capital(SA1->A1_END))+" - "+Alltrim(Capital(SA1->A1_COMPLEM)),oFont10, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

oPrinter:SayAlign(nLin, nCol2c, Alltrim(Transform(SA1->A1_CEP,"@R 99999-999"))+" "+Alltrim(Capital(SA1->A1_BAIRRO))+" - "+Alltrim(Capital(SA1->A1_MUN))+" - "+Alltrim(SA1->A1_EST),oFont10, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin, nCol4c, "PERÍODO",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+2, nCol8c, "VALOR R$",oFont9n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

If SA1->A1_PESSOA == "F"
	oPrinter:SayAlign(nLin, nCol2c, "CPF "+Alltrim(Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont10, 500, 500, CLR_BLACK, 0, 1 )
Else	
	oPrinter:SayAlign(nLin, nCol2c, "CNPJ "+Alltrim(Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFont10, 500, 500, CLR_BLACK, 0, 1 )
EndIf

oPrinter:SayAlign(nLin+2, nCol4c, DtoC(SC5->C5_P_DTINI)+" à "+DtoC(SC5->C5_P_DTFIM),oFont12, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+2, nCol8c, Alltrim(Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99")),oFont14, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto

nLin += nSalto*1.8

//Retangulo verde 1
oPrinter:Fillrect( {nLin, nCol1, nLin+16, 609 }, oBrush1, "-2")

//Retangulo verde 2
oPrinter:Fillrect( {nLin+16, nCol1, nLin+600, 609 }, oBrush3, "-2")

//Linha Final
oPrinter:Line(nLin+600, nCol1, nLin+600, 609, CLR_RGB_VERD1, '02' )

nLin += 3

oPrinter:SayAlign(nLin, nCol1i, "DISCRIMINAÇÃO DOS SERVIÇOS",oFont7n, 500, 500, CLR_WHITE, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol2i, "VALOR",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol3i, "DESCONTO",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol4i, "BASE CÁL.",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol5i, "ICMS",oFont7n, 60, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol6i, "VALOR TOTAL",oFont7n, 70, 0, CLR_WHITE, 1, 1 )
nLin += nSalto*1.8

//Impressao do rodape, pois so sai na primeira página.
ImpRod()

//Impressao dos itens
ImpItem()

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
		MsgStop( 'Erro na cópia para o servidor, Fatura ' + cNomeArq+  ".pdf" )
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
Função  : ImpItem
Objetivo: Impressao dos itens
Autor   : Renato Rezende
Data    : 16/08/2016             
*/
*--------------------------------*
Static Function ImpItem()
*--------------------------------*
Local cDesc		:= ""
Local cQuery	:= ""

Private nPagina	:= 1

nLin := 186 

If Select('AliasSD2') > 0
	AliasSD2->(DbCloseArea())
EndIf

cQuery:= "SELECT D2_PEDIDO,D2_ITEMPV,D2_COD,D2_BASEICM,D2_VALICM,D2_TOTAL,D2_DESCON,D2_TES,D2_ALQCOF,D2_BASIMP5,D2_VALIMP5,D2_ALQPIS,D2_BASIMP6,D2_VALIMP6,B1_DESC,B1_TIPO FROM "+RETSQLNAME("SD2")+" AS D2"
cQuery+= "  JOIN "+RETSQLNAME("SB1")+" AS B1 ON B1.D_E_L_E_T_ <> '*' AND B1.B1_COD = D2.D2_COD AND B1.B1_FILIAL='"+xFilial("SB1")+"' "
cQuery+= " WHERE D2.D2_SERIE = '"+SQL->F2_SERIE+"' "
cQuery+= "   AND D2.D_E_L_E_T_ <> '*' "
cQuery+= "   AND D2.D2_FILIAL = '"+SQL->F2_FILIAL+"' "
cQuery+= "   AND D2.D2_CLIENTE = '"+SQL->F2_CLIENTE+"' "
cQuery+= "   AND D2.D2_LOJA = '"+SQL->F2_LOJA+"' "
cQuery+= "   AND D2.D2_DOC = '"+SQL->F2_DOC+"' "
cQuery+= "ORDER BY D2.D2_FILIAL+D2.D2_ITEMPV"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"AliasSD2",.T.,.T.)

While AliasSD2->(!EOF())    
    //Posicionando na TES
    SF4->(DbSetOrder(1))
	SF4->(dbSeek(xFilial('SF4')+AliasSD2->D2_TES))
    
    //Descricao do produto
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+AliasSD2->D2_PEDIDO+AliasSD2->D2_ITEMPV+AliasSD2->D2_COD))
		cDesc:= Alltrim(SC6->C6_DESCRI)
	Else
		cDesc:= Alltrim(AliasSD2->B1_DESC)
	EndIf
	If Len(cDesc) > 73
		oPrinter:SayAlign(nLin, nCol1i, Alltrim(Substr(Alltrim(cDesc),1,72)) ,oFont9, 500, 500, CLR_BLACK, 0, 1 )
		nLin += nSalto
		oPrinter:SayAlign(nLin, nCol1i, Alltrim(Substr(Alltrim(cDesc),73,Len(Alltrim(cDesc)))) ,oFont9, 500, 500, CLR_BLACK, 0, 1 )		
	Else
		oPrinter:SayAlign(nLin, nCol1i, Alltrim(cDesc) ,oFont9, 500, 500, CLR_BLACK, 0, 1 )			
	EndIf
	oPrinter:SayAlign(nLin, nCol2i, Alltrim(Transform(AliasSD2->D2_TOTAL+AliasSD2->D2_DESCON,"@E 999,999,999,999.99")),oFont9, 80, 0, CLR_BLACK, 1, 1 )//VALOR TOTAL 
	oPrinter:SayAlign(nLin, nCol3i, Alltrim(Transform(AliasSD2->D2_DESCON,"@E 999,999,999,999.99")),oFont9, 80, 0, CLR_BLACK, 1, 1 )//VALOR TOTAL 
	If SF4->F4_ICM =='N'//Campo de ICMS no D2 vem com o valor do ISS tambem
		oPrinter:SayAlign(nLin, nCol4i, Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 80, 0, CLR_BLACK, 1, 1 )//BASE DE CÁLCULO
		oPrinter:SayAlign(nLin, nCol5i, Alltrim(Transform(0.00,"@E 999,999,999,999.99")),oFont9, 60, 0, CLR_BLACK, 1, 1 )//ICMS
	Else
		oPrinter:SayAlign(nLin, nCol4i, Alltrim(Transform(AliasSD2->D2_BASEICM,"@E 999,999,999,999.99")),oFont9, 80, 0, CLR_BLACK, 1, 1 )//BASE DE CÁLCULO
		oPrinter:SayAlign(nLin, nCol5i, Alltrim(Transform(AliasSD2->D2_VALICM,"@E 999,999,999,999.99")),oFont9, 60, 0, CLR_BLACK, 1, 1 )//ICMS
	EndIf
	oPrinter:SayAlign(nLin, nCol6i, Alltrim(Transform(AliasSD2->D2_TOTAL,"@E 999,999,999,999.99")),oFont9, 70, 0, CLR_BLACK, 1, 1 )//VALOR TOTAL 
	nLin += nSalto
	
	//Nova pagina
	If nLin>516 .AND. nPagina == 1
		oPrinter:SayAlign(nLin, nCol8c-20, "Demais itens na próxima página",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
		NvPagina()
	ElseIf nLin>746
		NvPagina()	
	EndIf

	AliasSD2->(DbSkip())
EndDo 

AliasSD2->(DbCloseArea())
SF4->(DbCloseArea())
SC6->(DbCloseArea())

Return

/*
Função  : NvPagina
Objetivo: Impressão de uma nova Pagina
Autor   : Renato Rezende
Data    : 26/08/2016
*/
*--------------------------------*
Static Function NvPagina()
*--------------------------------*
oPrinter:EndPage()
oPrinter:StartPage()

nPagina++
nLin := 0
//Fundo Verde
oPrinter:Fillrect( {nLin, nCol1, nLin+766, 609 }, oBrush3, "-2")

nLin+= nSalto
//Retangulo verde 1
oPrinter:Fillrect( {nLin, nCol1, nLin+16, 609 }, oBrush1, "-2")

//Linha Final
oPrinter:Line(nLin+756, nCol1, nLin+756, 609, CLR_RGB_VERD1, '02' )

nLin += 3

oPrinter:SayAlign(nLin, nCol1i, "DISCRIMINAÇÃO DOS SERVIÇOS",oFont7n, 500, 500, CLR_WHITE, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol2i, "VALOR",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol3i, "DESCONTO",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol4i, "BASE CÁL.",oFont7n, 80, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol5i, "ICMS",oFont7n, 60, 0, CLR_WHITE, 1, 1 ) 
oPrinter:SayAlign(nLin, nCol6i, "VALOR TOTAL",oFont7n, 70, 0, CLR_WHITE, 1, 1 )
nLin += nSalto*1.8

Return

/*
Função  : ImpRod
Objetivo: Impressão do Rodape
Autor   : Renato Rezende
Data    : 16/08/2016
*/
*--------------------------------*
 Static Function ImpRod()
*--------------------------------*
Local nPosMenN	:= 0
Local nBaseJr	:= 0
Local nValJr	:= 0
Local nAliqJr	:= 0
Local nBaseMt	:= 0
Local nValMt	:= 0
Local nAliqMt	:= 0
Local nPIcm		:= 0

Local cQuery1	:= ""
Local cQuery2	:= ""

//Select para o quadro de impostos no rodape
//PRODUTO
If Select('AliasSC') > 0
	AliasSC->(DbCloseArea())
EndIf
cQuery1	:="SELECT D2.D2_DOC,SUM(D2_BASIMP5) AS [BASE],SUM(D2_VALIMP5+D2_VALIMP6) AS [VALOR],D2.D2_PICM,D2.D2_ALQCOF,D2.D2_ALQPIS,D2.D2_ALQIRRF,D2.D2_ALQCSL FROM "+RETSQLNAME("SD2")+" AS D2 "
cQuery1	+="  JOIN "+RETSQLNAME("SB1")+" AS B1 ON  B1.B1_COD = D2.D2_COD AND B1.D_E_L_E_T_<> '*' AND B1.B1_FILIAL='"+xFilial("SB1")+"' "
cQuery1	+=" WHERE D2.D_E_L_E_T_ <> '*' "
cQuery1	+="   AND D2.D2_FILIAL+D2.D2_DOC+D2.D2_SERIE+D2.D2_CLIENTE+D2.D2_LOJA = '"+SQL->F2_FILIAL+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA+"' " 
cQuery1	+="   AND B1.B1_TIPO = ('SC') "
cQuery1	+=" GROUP BY D2.D2_FILIAL,D2.D2_DOC,D2.D2_SERIE,D2.D2_CLIENTE,D2.D2_LOJA,D2.D2_PICM,D2.D2_ALQCOF,D2_ALQPIS,D2_ALQIRRF,D2_ALQCSL "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"AliasSC",.T.,.T.)

//MULTA OU JUROS
If Select('AliasOU') > 0
	AliasOU->(DbCloseArea())
EndIf
cQuery2	:="SELECT D2.D2_DOC,SUM(D2_BASIMP5) AS [BASE],SUM(D2_VALIMP5+D2_VALIMP6) AS [VALOR],B1.B1_TIPO,D2.D2_ALQCOF,D2.D2_ALQPIS FROM "+RETSQLNAME("SD2")+" AS D2 "
cQuery2	+="  JOIN "+RETSQLNAME("SB1")+" AS B1 ON  B1.B1_COD = D2.D2_COD AND B1.D_E_L_E_T_ <> '*' AND B1.B1_FILIAL='"+xFilial("SB1")+"' "
cQuery2	+=" WHERE D2.D_E_L_E_T_ <> '*' "
cQuery2	+="   AND D2.D2_FILIAL+D2.D2_DOC+D2.D2_SERIE+D2.D2_CLIENTE+D2.D2_LOJA = '"+SQL->F2_FILIAL+SQL->F2_DOC+SQL->F2_SERIE+SQL->F2_CLIENTE+SQL->F2_LOJA+"' " 
cQuery2	+="   AND B1.B1_TIPO IN ('JR','MT') "
cQuery2	+=" GROUP BY D2.D2_FILIAL,D2.D2_DOC,D2.D2_SERIE,D2.D2_CLIENTE,D2.D2_LOJA,D2.D2_ALQCOF,D2.D2_ALQPIS,B1.B1_TIPO "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"AliasOU",.T.,.T.)

count to nRecCount

AliasOU->(DbGoTop())
For nR:=1 to nRecCount
	If Alltrim(AliasOU->B1_TIPO) == 'JR'
		nBaseJr	:= AliasOU->BASE
		nValJr	:= AliasOU->VALOR
		nAliqJr	:= AliasOU->D2_ALQCOF+D2_ALQPIS	
	ElseIf Alltrim(AliasOU->B1_TIPO) == 'MT'
		nBaseMt	:= AliasOU->BASE
		nValMt	:= AliasOU->VALOR
		nAliqMt	:= AliasOU->D2_ALQCOF+D2_ALQPIS
	EndIf
	AliasOU->(DbSkip())
Next nR

//Carregar Aliquota de ICMS
nPIcm := AliasSC->D2_PICM
If nPIcm == 0
	nPIcm:=	RetPIcm() 	
EndIf

SF3->(DbSetOrder(5))
SF3->(DbSeek(xFilial("SF3")+SQL->F2_SERIE+SQL->F2_DOC+SQL->F2_CLIENTE+SQL->F2_LOJA))

//Final do relatório
nLin:= 550
oPrinter:SayAlign(nLin, nCol1i, "INFORMAÇÕES COMPLEMENTARES:",oFont8n, 500, 500, CLR_BLACK, 0, 1 ) 
oPrinter:SayAlign(nLin, nCol1i+132, "O pagamento desta Fatura / Nota Fiscal não liquida débitos pendentes.",oFont9, 500, 500, CLR_BLACK, 0, 1 ) 
nLin += nSalto
oPrinter:SayAlign(nLin, nCol1i, "Encargos moratórios: em caso de atraso no pagamento, serão cobrados multa de 2%+1% de juros ao mês, na fatura seguinte.",oFont9, 500, 500, CLR_BLACK, 0, 1 ) 

//Valor Total
//Retangulo Total
oPrinter:Fillrect( {nLin-12, 440, nLin+9, 564 }, oBrush4, "-2")//Retangulo Branco
oPrinter:Line( nLin-12 , 440, nLin+9 , 440, CLR_RGB_VERD1 )//Coluna
oPrinter:Line( nLin-12 , 564, nLin+9 , 564, CLR_RGB_VERD1 )//Coluna
oPrinter:Line( nLin-12 , 440, nLin-12 , 564, CLR_RGB_VERD1 )//Linha
oPrinter:SayAlign(nLin-6, 445, "VALOR TOTAL R$",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin-8, 507,Alltrim(Transform(SQL->F2_VALBRUT,"@E 999,999,999,999.99")),oFont12, 55, 0, CLR_BLACK, 1, 1 )
oPrinter:Line( nLin+9 , 440, nLin+9 , 564, CLR_RGB_VERD1 )//Linha
nLin += nSalto

//Mensagens no final da nota
nLin2 := nLin
//Ato Cotepe
If SA1->A1_TPESSOA == 'AT'
	oPrinter:SayAlign(nLin2, nCol1i, "Documento Fiscal emitido nos termos do Convenio ICMS 126/98, bem como a identificação do protocolo do pedido a que se refere o inciso II do § 3º.",oFont8n, 600, 500, CLR_BLACK, 0, 1 ) 
    nLin2 += nSalto
EndIf
//Mensagem Impostos
If SA1->A1_TPESSOA == 'ER'
	oPrinter:SayAlign(nLin2, nCol1i, "Imposto(s) Retido(s): IR("+Alltrim(Str(AliasSC->D2_ALQIRRF))+"%), PIS("+Alltrim(Str(AliasSC->D2_ALQPIS))+"%), COFINS("+Alltrim(Str(AliasSC->D2_ALQCOF))+"%), CSLL("+Alltrim(Str(AliasSC->D2_ALQCSL))+"%) - R$ "+Alltrim(Transform(SQL->(F2_VALCSLL+F2_VALCOFI+F2_VALPIS+F2_VALIRRF),"@E 999,999,999,999.99"))+".",oFont8n, 600, 500, CLR_BLACK, 0, 1 ) 
	nLin2 += nSalto
EndIf
//Mensagem complementar
If !Empty(SC5->C5_MENNOTA)
	If Len(SC5->C5_MENNOTA)>129
		oPrinter:SayAlign(nLin2, nCol1i, Alltrim(Substr(Alltrim(SC5->C5_MENNOTA),1,128)) ,oFont7, 600, 500, CLR_BLACK, 0, 1 )
		nLin2 += nSalto-2
		oPrinter:SayAlign(nLin2, nCol1i, Alltrim(Substr(Alltrim(SC5->C5_MENNOTA),129,128)) ,oFont7, 600, 500, CLR_BLACK, 0, 1 )
	Else
		oPrinter:SayAlign(nLin2, nCol1i, Alltrim(SC5->C5_MENNOTA) ,oFont7, 600, 500, CLR_BLACK, 0, 1 )
	EndIf
EndIf

//Linha Verde
nLin += nSalto*4
oPrinter:Line(nLin, nCol2c, nLin, 564, CLR_RGB_VERD1, '02' )
nLin += nSalto-2

//Primeira Tabela
//Colunas
oPrinter:Line( nLin , nCol1i, nLin+90 , nCol1i, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol4r, nLin+90 , nCol4r, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol5r, nLin+90 , nCol5r, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol7r, nLin+90 , nCol7r, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol8r, nLin+90 , nCol8r, CLR_RGB_VERD1 )

//Linhas
oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+3, nCol1i+10, "IMPOSTO",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+3, nCol4r, "ALÍQUOTA",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, "BASE DE CÁLCULO",oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, "VALOR R$",oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+3, nCol1i+10, "ICMS",oFont8, 500, 500, CLR_BLACK, 0, 1 ) 
oPrinter:SayAlign(nLin+3, nCol4r, Alltrim(Str(nPIcm))+"%",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, Transform(SQL->F2_BASEICM,"@E 999,999,999,999.99"),oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, Transform(SQL->F2_VALICM,"@E 999,999,999,999.99"),oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+3, nCol1i+10, "PIS/COFINS - CUMULATIVO",oFont8, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+3, nCol4r, Alltrim(Str(AliasSC->D2_ALQCOF+AliasSC->D2_ALQPIS))+"%",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, Transform(AliasSC->BASE,"@E 999,999,999,999.99"),oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, Transform(AliasSC->VALOR,"@E 999,999,999,999.99"),oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+3, nCol1i+10, "PIS/COFINS - JUROS",oFont8, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+3, nCol4r, Alltrim(Str(nAliqJr))+"%",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, Transform(nBaseJr,"@E 999,999,999,999.99"),oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, Transform(nValJr,"@E 999,999,999,999.99"),oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+3, nCol1i+10, "PIS/COFINS - MULTA",oFont8, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+3, nCol4r, Alltrim(Str(nAliqMt))+"%",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, Transform(nBaseMt,"@E 999,999,999,999.99"),oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, Transform(nValMt,"@E 999,999,999,999.99"),oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 ) 
oPrinter:SayAlign(nLin+3, nCol1i+10, "PIS/COFINS - TOTAL",oFont8, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:SayAlign(nLin+3, nCol4r, "",oFont8n, 60, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol5r, Transform(nBaseMt+nBaseJr+AliasSC->BASE,"@E 999,999,999,999.99"),oFont8n, 155, 0, CLR_BLACK, 2, 1 )
oPrinter:SayAlign(nLin+3, nCol7r, Transform(nValMt+nValJr+AliasSC->VALOR,"@E 999,999,999,999.99"),oFont8n, 90, 0, CLR_BLACK, 1, 1 )
nLin += nSalto2
oPrinter:Line( nLin , nCol1i, nLin , nCol8r, CLR_RGB_VERD1 )

oPrinter:SayAlign(nLin+2, nCol1i, "As contribuições ao FUST (1%) e Funtel (0,5%) não são repassadas às tarifas.",oFont8, 500, 500, CLR_BLACK, 0, 1 )

nLin += nSalto*2
//Segundo quadrado
//Colunas
oPrinter:Line( nLin , nCol1i, nLin+30 , nCol1i, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol5r, nLin+30 , nCol5r, CLR_RGB_VERD1 )

oPrinter:Line( nLin , nCol6r, nLin+30 , nCol6r, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol8r, nLin+30 , nCol8r, CLR_RGB_VERD1 )

//Linhas
oPrinter:Line( nLin , nCol1i, nLin , nCol5r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+2, nCol1i+3, "RESERVADO AO FISCO",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
oPrinter:Line( nLin , nCol6r, nLin , nCol8r, CLR_RGB_VERD1 )
oPrinter:SayAlign(nLin+2, nCol6r+3, "CHAVE DE CÓDIGO DIGITAL",oFont8n, 500, 500, CLR_BLACK, 0, 1 )
nLin += nSalto2
oPrinter:SayAlign(nLin, nCol6r+3, Alltrim(UPPER(Transform(SF3->F3_MDCAT79,"@R XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX.XXXX"))),oFont13, 230, 0, CLR_BLACK, 2, 1 )
nLin += nSalto2

oPrinter:Line( nLin , nCol1i, nLin , nCol5r, CLR_RGB_VERD1 )
oPrinter:Line( nLin , nCol6r, nLin , nCol8r, CLR_RGB_VERD1 )

SF3->(DbCloseArea())
AliasSC->(DbCloseArea())
AliasOU->(DbCloseArea())

Return

/*
Função  : RetPIcm
Objetivo: Retirna a aliquota de ICMS da SF7
Autor   : Renato Rezende
Data    : 06/09/2016
*/
*--------------------------------*
 Static Function RetPIcm()
*--------------------------------*
Local nRet	:= 0 
Local cQuery:= 0

cQuery	:= "SELECT TOP 1 * FROM "+RETSQLNAME("SF7")+" " 
cQuery	+= " WHERE F7_FILIAL = '"+xFilial("SF7")+"' AND F7_EST = '"+SM0->M0_ESTCOB+"' AND D_E_L_E_T_ <> '*' "

//EXCEÇÃO FISCAL
If Select('AliasF7') > 0
	AliasF7->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"AliasF7",.T.,.T.)

count to nRecCount
AliasF7->(DbGoTop())
If nRecCount >= 1
	nRet:= AliasF7->F7_ALIQINT 
Else
	nRet:= 0
EndIf

AliasF7->(DbCloseArea())

Return nRet

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
