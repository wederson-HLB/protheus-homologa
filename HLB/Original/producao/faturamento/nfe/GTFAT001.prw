#INCLUDE 'totvs.ch'
#INCLUDE 'FWPrintSetup.ch'
#INCLUDE "RPTDEF.CH"

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   025//038                                      	  // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  090                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  011//009                                           // Máximo de caracteres por linha de valores numéricos
#DEFINE ENTER      CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTFAT001  ºAutor  ³Eduardo C. Romanini º Data ³  16/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de prEimpressão da Danfe.                           º±±
±±º          ³Chamado a partir da rotina padrão de NFeSefaz.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------*
User Function GTFAT001()
*----------------------*
Local cNumNf  := ""
Local cSerie  := ""
Local cCliFor := ""
Local cLoja   := ""
Local cNfOri  := ""
Local cSerOri := ""
Local cXml    := ""

Local aParam  := {}
Local aRetXml := {}
Local aArea   := {}

Private cTipo := ""

//Define o tipo da Nf
cTipo := Left(MV_PAR01,1)

If cTipo <> "1"
	cTipo := "0"
EndIf

If cTipo == "1" //Nf de Saida

	aArea := SF2->(GetArea())
		
	cNumNf  := SF2->F2_DOC
	cSerie  := SF2->F2_SERIE
	cCliFor := SF2->F2_CLIENTE
	cLoja   := SF2->F2_LOJA
	cNfOri  := SF2->F2_NFORI
	cSerOri := SF2->F2_SERIORI 

	If !Empty(SF2->F2_CHVNFE) .or. SF2->F2_FIMP $ 'S'
		MsgInfo("Essa nota jEfoi transmitida para a Sefaz, favor utilizar botão 'Danfe'","Atenção")
		Return .F.	
    EndIf

Else //Nf de Entrada

	aArea := SF1->(GetArea())

	cNumNf  := SF1->F1_DOC
	cSerie  := SF1->F1_SERIE
	cCliFor := SF1->F1_FORNECE
	cLoja   := SF1->F1_LOJA
	cNfOri  := SF1->F1_NFORIG
	cSerOri := SF1->F1_SERORIG

	If !Empty(SF1->F1_CHVNFE) .or. SF1->F1_FIMP $ 'S'
		MsgInfo("Essa nota jEfoi transmitida para a Sefaz, favor utilizar botão 'Danfe'","Atenção")
		Return .F.	
    EndIf

EndIf

//Confirma a impressão
If !MsgYesNo("Confirma a impressão da Pre-Danfe para a Nota Fiscal: "+AllTrim(cNumNf)+" Serie: " + AllTrim(cSerie),"Atenção")
	RestArea(aArea)
	Return .F.
EndIf

//Cria o arquivo xml
//AOA - 13/08/2018 - Atualizado fonte para nova versão da NF-e 4
aParam := {{cTipo,,cSerie,cNumNf,cCliFor,cLoja,{}},"4.00","",{cNfOri,cSerOri}}
aRetXml := ExecBlock("XmlNfeSef",.F.,.F.,aParam)

cXml := aRetXml[2]

If !Empty(cXml)
	//Chama a rotina de impressão
	PreDanfe(cXml)
EndIf

RestArea(aArea)

Return .T.

/*
Funcao      : PreDanfe()
Objetivos   : Rotina de impressão da Danfe
Autor       : Eduardo C. Romanini
Data/Hora   : 16/12/11 15:00
*/
*----------------------------*
Static Function PreDanfe(cXml)
*----------------------------*
Local cAviso := ""
Local cErro  := ""

Local oNfe

Private oDanfe

oNfe := XmlParser(cXml,"_",@cAviso,@cErro)

//Apaga o arquivo antigo, se existir.
If File(AllTrim(GetTempPath())+"PRE-DANFE.PDF")
	If fErase(AllTrim(GetTempPath())+"PRE-DANFE.PDF") <> 0
		MsgInfo("Existe uma janela de impressão de Pre-Danfe aberta. Feche-a para imprimir a nova Pre-Danfe.","Atenção")
		Return .F.
	EndIf
EndIf

// Inicialize o objeto desta forma
oDanfe:=FwMSPrinter():New('PRE-DANFE',6,.F.,,.T.)

oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
oDanfe:SetPortrait()
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(60,60,60,60)

oDanfe:nDevice := IMP_PDF

// Caminho onde serEgravado o PDF
oDanfe:cPathPDF := AllTrim(GetTempPath())

If Empty(cAviso) .And. Empty(cErro)
	RptStatus({|| LoadFonte(@oDanfe,oNfe)},"Imprimindo Danfe...")
EndIf

// Gera e abre o arquivo em tela, e finaliza a impressao.
oDanfe:Preview()

//Fecha o Objeto
FreeObj(oDanfe)
oDanfe := Nil

Return Nil 

/*
Funcao      : LoadFonte()
Objetivos   : Carrega as fontes da Danfe
Autor       : Eduardo C. Romanini
Data/Hora   : 16/12/11 16:20
*/
*------------------------------------*
Static Function LoadFonte(oDanfe,oNfe)
*------------------------------------*
PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12
PRIVATE oFont12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 13

//Imprime a Danfe
ImpDanfe(@oDanfe,oNfe)

Return Nil

/*
Funcao      : ImpDanfe()
Objetivos   : Realiza a impressão da Danfe
Autor       : Eduardo C. Romanini
Data/Hora   : 16/12/11 16:20
*/
*-----------------------------------*
Static Function ImpDanfe(oDanfe,oNfe)
*-----------------------------------*
Local lConverte   := GetNewPar("MV_CONVERT",.F.)
Local lImpAnfav   := GetNewPar("MV_IMPANF",.F.)
Local lImpInfAd   := GetNewPar("MV_IMPADIC",.F.)
Local lMv_Logod   := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local lArt488MG   := .F.
Local lArt274SP   := .F.
Local lMv_ItDesc  := Iif( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )
Local lLote       := .F.
Local lPontilhado := .F.
Local lFlag       := .F.
Local lFimpar	    := .T.
Local lCompleECF  := .F.

Local cStrAux    := ""
Local cLogoD     := ""
Local cLogo      := FisxLogo("1")
Local cMVCODREG  := SuperGetMV("MV_CODREG", ," ")
Local cEsp       := ""
Local cGuarda    := ""
Local cModFrete  := ""
Local cAux       := ""
Local cAuxLote   := ""
Local cSitTrib   := ""
Local cLote      := ""
Local cPedido    := ""
Local cCompl     := ""
Local cAuxItem   := ""
Local cCodAutSef := ""
Local cCodAutDPEC:= ""
Local cDtHrRecCab:= ""

Local nHPage     := 0
Local nVPage     := 0
Local nLinCalc   := 0
Local nForTo     := 0
Local nE         := 0
Local nI         := 0
Local nL         := 0
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nLin       := 0
Local nCol       := 0
Local nFolha     := 1
Local nFolhas    := 0
Local nFaturas   := 0
Local nColuna    := 0
Local nLenVol    := 0
Local nLenDet    := 0
Local nLenSit    := 0
Local nXAux      := 0
Local nVolume    := 0
Local nPesoB     := 0
Local nPesoL     := 0
Local nQtd       := 0
Local nItem      := 0
Local nBaseICM   := 0
Local nValICM    := 0
Local nValIPI    := 0
Local nPICM      := 0
Local nPIPI      := 0
Local nVTotal    := 0
Local nVUnit     := 0
Local nDesc      := 0
Local nVUniLiq   := 0
Local nMaxCod    := 10
Local nMaxDes    := MAXITEMC
Local nLinhavers := 0
Local nMsgCompl  := 0
Local nMaxItemP2 := MAXITEM // Variável utilizada para tratamento de quantos itens devem ser impressos na página corrente
Local nVlProd    := 0
Local nVlDesc    := 0
Local nVlFrete   := 0
Local nVlSeg     := 0
Local nVlOutro   := 0
Local nTotIPI    := 0
 
Local aUF       := {}
Local aAux      := {}
Local aItens    := {}
Local aTransp   := {}
Local aFaturas  := {}
Local aEspecie  := {}
Local aSitTrib  := {}
Local aSitSN    := {}
Local aEspVol   := {}
Local aISSQN    := {}
Local aTotais   := {}
Local aMensagem := {}
Local aLote     := {}
Local aResFisco := {}
Local aIndAux   := {}
Local aIndImp   := {}
Local aTmpPed   := {}
Local aKits     := {}    
Local aCabProd  := {}

Private nPrivate   := 0
Private nPrivate2  := 0

Private oEmitente  := oNFe:_InfNfe:_Emit
Private oNF        := oNFe
Private oIdent     := oNFe:_InfNfe:_IDE
Private oDestino   := oNFe:_InfNfe:_Dest
Private oTotal     := oNFe:_InfNfe:_Total
Private oTransp    := oNFe:_InfNfe:_Transp
Private oDet       := oNFe:_InfNfe:_Det
Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
Private oImposto
Private oNfeDPEC

Private PixelX := oDanfe:nLogPixelX()
Private PixelY := oDanfe:nLogPixelY()

nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as variaveis de impressao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")

aadd(aSitSN,"101")
aadd(aSitSN,"102")
aadd(aSitSN,"201")
aadd(aSitSN,"202")
aadd(aSitSN,"500")
aadd(aSitSN,"900")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Destinatario                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDest := {NoChar(oDestino:_EnderDest:_Lgr:Text,lConverte)+IIF(", SN"$NoChar(oDestino:_EnderDest:_Lgr:Text,lConverte),"",", "+oDestino:_EnderDest:_NRO:Text + IIf(Type("oDestino:_EnderDest:_cpl")=="U","",", " + NoChar(oDestino:_EnderDest:_cpl:Text,lConverte))),;
NoChar(oDestino:_EnderDest:_Bairro:Text,lConverte),;
IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text),;
oDestino:_EnderDest:_Mun:Text,;
IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
oDestino:_EnderDest:_UF:Text,;
IIF(Type("oDestino:_IE")=="U","",oDestino:_IE:Text),;
"",;
IIF(Type("oIdent:_hSaiEnt")=="U","",oIdent:_hSaiEnt:Text)}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Faturas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)

If nFaturas > 0
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, AllTrim(oFatura:_Dup[nY]:_Dup:TEXT))
					Else
						AAdd(aAux, AllTrim(oFatura:_Dup:_Dup:TEXT))
					EndIf
				Case nX == 2
					If nFaturas > 1
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup[nY]:_dtVenc:TEXT)))
					Else
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup:_dtVenc:TEXT)))
					EndIf
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro transportadora                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTransp := {"","0","","","","","","","","","","","","","",""}

If Type("oTransp:_ModFrete")<>"U"
	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
EndIf
If Type("oTransp:_Transporta")<>"U"
	aTransp[01] := IIf(Type("oTransp:_Transporta:_Nome:TEXT")<>"U",NoChar(oTransp:_Transporta:_Nome:TEXT,lConverte),"")
	//	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
	EndIf
	aTransp[07] := IIf(Type("oTransp:_Transporta:_Ender:TEXT")<>"U",NoChar(oTransp:_Transporta:_Ender:TEXT,lConverte),"")
	aTransp[08] := IIf(Type("oTransp:_Transporta:_Mun:TEXT")<>"U",oTransp:_Transporta:_Mun:TEXT,"")
	aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
	aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
ElseIf Type("oTransp:_VEICTRANSP")<>"U"
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
EndIf
If Type("oTransp:_Vol")<>"U"
	If ValType(oTransp:_Vol) == "A"
		nX := nPrivate
		nLenVol := Len(oTransp:_Vol)
		For nX := 1 to nLenVol
			nXAux := nX
			nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
		Next nX
		aTransp[11]	:= AllTrim(str(nVolume))
		aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp")=="U","Diversos","")
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
			nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
			aTransp[15] := AllTrim(str(nPesoB))
		EndIf
		If Type("oTransp:_Vol[1]:_PesoL") <>"U"
			nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
			aTransp[16] := AllTrim(str(nPesoL))
		EndIf
	Else
		aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT")<>"U",oTransp:_Vol:_qVol:TEXT,"")
		aTransp[12] := IIf(Type("oTransp:_Vol:_Esp")=="U","",oTransp:_Vol:_Esp:TEXT)
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
		aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")
	EndIf
	aTransp[15] := strTRan(aTransp[15],".",",")
	aTransp[16] := strTRan(aTransp[16],".",",")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volumes / Especie Nota de Saida                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1"  .And. Empty(aTransp[12])
	
	If (SF2->(FieldPos("F2_ESPECI1")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI1" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI2")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI2" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI3")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI3" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI4")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI4" )))  ))
		
		aEspecie := {}
		aadd(aEspecie,SF2->F2_ESPECI1)
		aadd(aEspecie,SF2->F2_ESPECI2)
		aadd(aEspecie,SF2->F2_ESPECI3)
		aadd(aEspecie,SF2->F2_ESPECI4)
		
		cEsp := ""
		nx 	 := 0
		For nE := 1 To Len(aEspecie)
			If !Empty(aEspecie[nE])
				nx ++
				cEsp := aEspecie[nE]
			EndIf
		Next
		
		cGuarda := ""
		If nx > 1
			cGuarda := "Diversos"
		Else
			cGuarda := cEsp
		EndIf
		
		If !Empty(cGuarda)
			aadd(aEspVol,{cGuarda,Iif(SF2->F2_PLIQUI>0,str(SF2->F2_PLIQUI),""),Iif(SF2->F2_PBRUTO>0, str(SF2->F2_PBRUTO),"")})
		Else
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1
			//³Aqui seguindo a mesma regra da criação da TAG de Volumes no xml  ³
			//³ caso não esteja preenchida nenhuma das especies de Volume não se³
			//³ envia as informações de volume.                   				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1
			*/
			aadd(aEspVol,{cGuarda,"",""})
		Endif
	Else
		aadd(aEspVol,{cGuarda,"",""})
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Especie Nota de Entrada                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "0"  .And. Empty(aTransp[12])
	If (SF1->(FieldPos("F1_ESPECI1")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI1" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI2")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI2" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI3")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI3" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI4")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI4" )))  ))
		
		aEspecie := {}
		aadd(aEspecie,SF1->F1_ESPECI1)
		aadd(aEspecie,SF1->F1_ESPECI2)
		aadd(aEspecie,SF1->F1_ESPECI3)
		aadd(aEspecie,SF1->F1_ESPECI4)
		
		cEsp := ""
		nx 	 := 0
		For nE := 1 To Len(aEspecie)
			If !Empty(aEspecie[nE])
				nx ++
				cEsp := aEspecie[nE]
			EndIf
		Next
		
		cGuarda := ""
		If nx > 1
			cGuarda := "Diversos"
		Else
			cGuarda := cEsp
		EndIf
		
		If  !Empty(cGuarda)
			aadd(aEspVol,{cGuarda,Iif(SF1->F1_PLIQUI>0,str(SF1->F1_PLIQUI),""),Iif(SF1->F1_PBRUTO>0, str(SF1->F1_PBRUTO),"")})
		Else
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1
			//³Aqui seguindo a mesma regra da criação da TAG de Volumes no xml  ³
			//³ caso não esteja preenchida nenhuma das especies de Volume não se³
			//³ envia as informações de volume.                   				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1
			*/
			aadd(aEspVol,{cGuarda,"",""})
		Endif
	Else
		aadd(aEspVol,{cGuarda,"",""})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo do frete    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(3)
MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SD2")+SD2->D2_TES)
dbSelectArea("SF3")
dbSetOrder(4)
MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)

lArt488MG := Iif(SF4->(FIELDPOS("F4_CRLEIT"))>0,Iif(SF4->F4_CRLEIT == "1",.T.,.F.),.F.)
lArt274SP := Iif(SF4->(FIELDPOS("F4_ART274"))>0,Iif(SF4->F4_ART274 $ "1S",.T.,.F.),.F.)

If SC5->C5_TPFRETE=="C"
	cModFrete := "0"
ElseIf SC5->C5_TPFRETE=="F"
	cModFrete := "1"
ElseIf SC5->C5_TPFRETE=="T"
	cModFrete := "2"
ElseIf SC5->C5_TPFRETE=="S"
	cModFrete := "9"
Else
	cModFrete := "1"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Dados do Produto / Serviço                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLenDet := Len(oDet)
If lMv_ItDesc
	For nX := 1 To nLenDet
		Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte),1,MAXITEMC)})
	Next
	
	aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })
	
	For nX := 1 To nLenDet
		Aadd(aIndImp, aIndAux[nX][1] )
	Next
EndIf

If SM0->M0_CODIGO $ "IS|4M|2C" //Promega e Illumina

	If oIdent:_TpNf:Text == "1" //Nota de Saúa

    	//Verifica se o alias 'TMP' estEem uso.
    	If Select("TMP") > 0
    		TMP->(DbCloseArea()) 	
    	EndIf
    	
    	//Query que retorna os itens da nota com a mesma ordenação
    	//que foram gravados no arquivo xml.
    	BeginSql Alias 'TMP'
    		SELECT D2_PEDIDO,D2_ITEMPV
    		FROM %table:SD2%
    		WHERE %notDel%
    		  AND D2_DOC = %exp:SF2->F2_DOC%
    		  AND D2_SERIE = %exp:SF2->F2_SERIE%
    		ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD	
    	EndSql
    	
    	//Adiciona no array aTmpPed o numero do pedido de venda
    	//do item da nota fiscal.
	   	TMP->(DbGoTop())
    	While TMP->(!EOF())
    	
    		TMP->(aAdd(aTmpPed,{D2_PEDIDO,D2_ITEMPV}))
    	
    		TMP->(DbSkip())
    	EndDo	
		
		//Fecha a tabela temporaria.
		TMP->(DbCloseArea())
	EndIf		

EndIf

//Looping em todos os itens para saber se hEcontrole de lote.
For nZ := 1 To nLenDet

	If lMv_ItDesc
		nX := aIndImp[nZ]
	Else
		nX := nZ
	EndIf
	nPrivate := nX

	If SM0->M0_CODIGO == 'FF' //Sumitomo
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					lLote := .T.
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO == 'IS' //Promega
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					lLote := .T.
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO $ 'A6|LN' //Perstorp, Neogen
		
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					If AT("#",oDet[nX]:_InfAdProd:TEXT) > 0
						If Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,AT("#",oDet[nX]:_InfAdProd:TEXT)) <> ''
							lLote := .T.
						EndIf  
					Else
                       If !(SM0->M0_CODIGO $ 'A6')
					      lLote := .T.
					   EndIf 
					EndIf
				EndIf
			EndIf 
		EndIf

	ElseIf SM0->M0_CODIGO $ '4M|2C' //Illumina
		lLote := .T.	
	EndIf
    
	//Se tiver lote em algum dos itens, sai do loop.
	If lLote
		Exit
	EndIf
Next

nVlProd  := 0
nVlDesc  := 0
nVlFrete := 0
nVlSeg   := 0
nVlOutro := 0
nTotIPI  := 0

//Looping nos itens para impressão.
For nZ := 1 To nLenDet

	cCompl:="" //RRP - 20/05/2013 - Acerto para impressão do lote. Chamado 012348

	If lMv_ItDesc
		nX := aIndImp[nZ]
	Else
		nX := nZ
	EndIf
	nPrivate := nX
	If lArt488MG .And. SuperGetMv("MV_ESTADO")$"MG"
		nVTotal  := 0
		nVUnit   := 0
	Else
		nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)
		nVUnit   := Val(oDet[nX]:_Prod:_vUnCom:TEXT)
	EndIf
	nQtd     := Val(oDet[nX]:_Prod:_qTrib:TEXT)
	nBaseICM := 0
	nValICM  := 0
	nValIPI  := 0
	nPICM    := 0
	nPIPI    := 0
	oImposto := oDet[nX]
	cSitTrib := ""
        
	//ER - 02/01/2012: Alteração na leitura das tags de impostos
	If Type("oImposto:_Imposto")<>"U"
		For nI:=1 To Len(oImposto:_Imposto)		
			If oImposto:_Imposto[nI]:_Codigo:TEXT == "ICMS"
				If aScan(aSitTrib,oImposto:_Imposto[nI]:_Tributo:_CST:TEXT) > 0
					nBaseICM := Val(oImposto:_Imposto[nI]:_Tributo:_VBC:TEXT)
					nValICM  := Val(oImposto:_Imposto[nI]:_Tributo:_Valor:TEXT)
					nPICM    := Val(oImposto:_Imposto[nI]:_Tributo:_Aliquota:TEXT)
					cSitTrib := AllTrim(oImposto:_Imposto[nI]:_CPL:_Orig:TEXT) + AllTrim(oImposto:_Imposto[nI]:_Tributo:_CST:TEXT)
				EndIf

			ElseIf oImposto:_Imposto[nI]:_Codigo:TEXT == "ICMSST"
				If oEmitente:_CRT:TEXT == "1"
					If aScan(aSitTrib,oImposto:_Imposto[nI]:_Tributo:_CST:TEXT) > 0
						nBaseICM := Val(oImposto:_Imposto[nI]:_Tributo:_VBC:TEXT)
						nValICM  := Val(oImposto:_Imposto[nI]:_Tributo:_Valor:TEXT)
						nPICM    := Val(oImposto:_Imposto[nI]:_Tributo:_Aliquota:TEXT)
						cSitTrib := AllTrim(oImposto:_Imposto[nI]:_CPL:_Orig:TEXT) + AllTrim(oImposto:_Imposto[nI]:_Tributo:_CST:TEXT)
					EndIf
	            EndIf

			ElseIf oImposto:_Imposto[nI]:_Codigo:TEXT == "IPI"
				nValIPI := Val(oImposto:_Imposto[nI]:_Tributo:_Valor:TEXT)
				nPIPI   := Val(oImposto:_Imposto[nI]:_Tributo:_Aliquota:TEXT)
			EndIf
		Next nY
	EndIf		

 	//Tratamento customizado para os clientes.
	If SM0->M0_CODIGO == 'FF' //Sumitomo
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					If At("#",oDet[nX]:_InfAdProd:TEXT) > 0
						If Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,At("#",oDet[nX]:_InfAdProd:TEXT)) <> ''
							cLote :=Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,AT("#",oDet[nX]:_InfAdProd:TEXT)-1)
						EndIf  
						cCompl:=Alltrim(Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),AT("#",oDet[nX]:_InfAdProd:TEXT)+2))
					Else
						cLote :=Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,10)					    
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO == 'IS' //Promega
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					cLote :=Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,10)
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO == 'I7' //Donaldson
   	   If Type("oDet[nPrivate]:_InfAdProd")<>"U"
	   	  If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
              If !Empty(oDet[nX]:_InfAdProd:TEXT)
                 cPedido:=Alltrim(oDet[nX]:_InfAdProd:TEXT)   
              EndIf
          EndIf   
       EndIf

	ElseIf SM0->M0_CODIGO $ 'A6|LN' //Perstorp, Neogen
		
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					If AT("#",oDet[nX]:_InfAdProd:TEXT) > 0
						If Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,AT("#",oDet[nX]:_InfAdProd:TEXT)) <> ''
							cLote :=Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),1,AT("#",oDet[nX]:_InfAdProd:TEXT)-1)
						EndIf  
						cCompl:=Alltrim(Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),AT("#",oDet[nX]:_InfAdProd:TEXT)+2))
					Else
						If SM0->M0_CODIGO $ 'A6'
						  	cCompl:=Alltrim(oDet[nX]:_InfAdProd:TEXT)
						Else
							cLote :=Alltrim(oDet[nX]:_InfAdProd:TEXT)
						EndIf 
					EndIf
				EndIf
			EndIf 
		EndIf
	
	//RRP - 12/02/2014 Empresas - Angelmed, Ceres, Illumina, Dr. Reddys, Meda Phamra, Alliance e inclusão da Steelcase/Equant Brasil/Dexa/Equant Services/ALLIED
	ElseIf SM0->M0_CODIGO $ 'PL/6H/HM/CZ/2C/U2/3R/5F/9N/LW/KQ/LX/9P' //Polaris/Chery/Angelmed/Ceres/Illumina/Dr. Reddys/Meda Pharma/Alliance/Steelcase/Equant Brasil/Dexa/Equant Services/ALLIED

		If Type("oDet[nPrivate]:_InfAdProd")<>"U" 
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					cCompl :=Alltrim(oDet[nX]:_InfAdProd:TEXT)
				EndIf
			EndIf
		EndIf

	//RRP - 15/03/2013 Alteração para impressão não sair a validade do lote	
	ElseIf SM0->M0_CODIGO $ 'SI' //Sirona

		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote 
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					cCompl 	 := Alltrim(oDet[nX]:_InfAdProd:TEXT)
					//Cortando a informação da Validade do lote.
					cCompl 	 := SubStr(cCompl,1,At("Validade:",cCompl)-1)					
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO == 'R7' //Shiseido
    	
		If Type("oDet[nPrivate]:_Prod:_vDesc:TEXT")<>"U"
			nDesc := Val( oDet[nX]:_Prod:_vDesc:TEXT )
		Else
			nDesc := 0
		EndIf

		nVUniLiq := nVUnit-(nDesc/nQtd)
		
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" //Lote
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					If AT("/",oDet[nX]:_InfAdProd:TEXT) > 0
						If AT("#",oDet[nX]:_InfAdProd:TEXT) = 0
							cCompl:=Alltrim(Substr(Alltrim(oDet[nX]:_InfAdProd:TEXT),AT("/",oDet[nX]:_InfAdProd:TEXT)+2))
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf SM0->M0_CODIGO == "ED" //Okuma

		If oIdent:_TpNf:TEXT == "1" //Nf de Saida
			If Type("oDet[nPrivate]:_prod:_xPed")<>"U"
				If Type("oDet[nPrivate]:_prod:_xPed:TEXT")<>"U"
					If !Empty(oDet[nX]:_prod:_xPed:TEXT)
						cCompl:="Ped. Cliente:"+Alltrim(oDet[nX]:_prod:_xPed:TEXT)   
					EndIf
				EndIf   
			EndIf	
	    EndIf
	
	ElseIf SM0->M0_CODIGO $ "4M|2C" //Illumina

		If Type("oDet[nPrivate]:_InfAdProd")<>"U"
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					
					//Verifica se o produto não Eum Kit
					If !ProdKit(Alltrim(oDet[nX]:_Prod:_cProd:TEXT))					
						cLote:=Alltrim(oDet[nX]:_InfAdProd:TEXT)
					EndIf   
				EndIf
			EndIf   
		EndIf
		
    ElseIf SM0->M0_CODIGO == "IS" //Promega
	   	
	   	If oIdent:_TpNf:TEXT == "1" //Nf de Saida
	        
	        SC6->(DbSetOrder(1))
	        If SC6->(DbSeek(xFilial("SC6")+aTmpPed[nX,1]+aTmpPed[nX,2]))
	        
	        	If !Empty(SC6->C6_P_KIT)
	       		    
	       			SB1->(DbSetOrder(1))
	       			If SB1->(DbSeek(xFilial("SB1")+SC6->C6_P_KIT))
	       		
	        			If aScan(aKits,SC6->C6_P_KIT) == 0
	       				    
	       				aAdd(aKits,SC6->C6_P_KIT)
	       				    
	       				nMaxCod := MaxCod(AllTrim(SC6->C6_P_KIT), 63)
							nMaxDes := MaxCod(NoChar(AllTrim(SB1->B1_DESC),lConverte), 120)
	       				
	        				aAdd(aItens,{	SubStr(AllTrim(SC6->C6_P_KIT),1,nMaxCod),;
	        								SubStr(NoChar(AllTrim(SB1->B1_DESC),lConverte),1,nMaxDes),;
	    		    						"",;
	    		    						"",;
	       		 						"",;
	        								"",;
	        								AllTrim(TransForm(SC6->C6_P_QKIT,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))),;
	        								"",;
				        					"",;
		   				     				"",;
		   					     			"",;
	   		    		 					"",;
	    		    						"",;
			        						"" })
	        			     
	        				If lLote
								aAdd(aItens[Len(aItens)],"")
								aIns(aItens[Len(aItens)],3)
								aItens[Len(aItens)][3] := ""
	        				EndIf

	        				cAuxItem	:= AllTrim(SubStr(SC6->C6_P_KIT,nMaxCod+1))
							cAux 		:= AllTrim(SubStr(NoChar(SB1->B1_DESC,lConverte),(nMaxDes+1)))	
	
							While !Empty(cAux) .Or. !Empty(cAuxItem)
								nMaxCod := MaxCod(cAuxItem, 63)
								nMaxDes := MaxCod(cAux, 120)
			
								aadd(aItens,{SubStr(cAuxItem,1,nMaxCod),;
									SubStr(cAux,1,nMaxDes),;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""})

		        				If lLote
									aAdd(aItens[Len(aItens)],"")
									aIns(aItens[Len(aItens)],3)
									aItens[Len(aItens)][3] := ""
		        				EndIf
	
								cAux 		:= 	SubStr(cAux,(nMaxDes+1))
								cAuxItem	:=	SubStr(cAuxItem,nMaxCod+1)
							EndDo
	                        
	                        aadd(aItens,{"",;
										 "",;
										 "",;
										 "",;
									  	 "",;
									 	 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 ""})

	        				If lLote
								aAdd(aItens[Len(aItens)],"")
								aIns(aItens[Len(aItens)],3)
								aItens[Len(aItens)][3] := ""
	        				EndIf
	
							cAux 		:= 	""
							cAuxItem	:=	""
	        			EndIf
					EndIf        		
	        	
	        	Else
	
					aadd(aItens,{"",;
								 "",;
								 "",;
								 "",;
							  	 "",;
							 	 "",;
								 "",;
								 "",;
								 "",;
								 "",;
								 "",;
								 "",;
								 "",;
								 ""})        	
       				If lLote
						aAdd(aItens[Len(aItens)],"")
						aIns(aItens[Len(aItens)],3)
						aItens[Len(aItens)][3] := ""
       				EndIf

	        	EndIf
	         
	    	EndIf
    	EndIf
    //RRP - 25/10/2013 - Caso a empresa não tenha tratamento 
    ElseIf !(SM0->M0_CODIGO) == "BH" //RRP - 28/10/2013 - Retirada empresa SNF do tratamento. Chamado 015268 
		If Type("oDet[nPrivate]:_InfAdProd")<>"U" 
			If Type("oDet[nPrivate]:_InfAdProd:TEXT")<>"U"
				If !Empty(oDet[nX]:_InfAdProd:TEXT)
					cCompl 	 := Alltrim(oDet[nX]:_InfAdProd:TEXT)
				EndIf
			EndIf
		EndIf    
    EndIf

	If SM0->M0_CODIGO == "ED" //Okuma
		nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 85)
		nMaxDes := MaxCod(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte), 165)

	ElseIf SM0->M0_CODIGO == "VR" //Power e Telepho
		nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 55)
		nMaxDes := MaxCod(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte), 165)
		
	ElseIf SM0->M0_CODIGO == "EF" //FSI
		nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 90)
		nMaxDes := MaxCod(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte), 100)

    Else
		nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 50)
		nMaxDes := MaxCod(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte), 100)
	EndIf
	
	aadd(aItens,{	SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;
					SubStr(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte),1,nMaxDes),;
					IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
					cSitTrib,;
					oDet[nX]:_Prod:_CFOP:TEXT,;
					oDet[nX]:_Prod:_utrib:TEXT,;
					AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))),;
					AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],4))),;
					AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;
					AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))),;
					AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))),;
					AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))),;
					AllTrim(TransForm(nPICM,"@r 99.99%")),;
					AllTrim(TransForm(nPIPI,"@r 99.99%"))})
	   
	//Tratamento customizado para os clientes.
	//RRP - 16/05/2013 retirada da empresa Ceres U2.
	If SM0->M0_CODIGO $ 'IS' //Promega.
		
		//Adiciona a coluna de lote na posição 3.
		If lLote
			aAdd(aItens[Len(aItens)],"")
			aIns(aItens[Len(aItens)],3)
			aItens[Len(aItens)][3] := cLote
		EndIf	

	ElseIf SM0->M0_CODIGO $ "FF" //Sumitomo

		aItens[Len(aItens)][8] := AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],6)))	

		aAdd(aItens[Len(aItens)],"")
		aIns(aItens[Len(aItens)],3)
		aItens[Len(aItens)][3] := cLote

	ElseIf SM0->M0_CODIGO $ 'A6|LN' //Perstorp

		If lLote
		   aAdd(aItens[Len(aItens)],"")
		   aIns(aItens[Len(aItens)],3)
		   aItens[Len(aItens)][3] := cLote
		EndIf
		
	ElseIf SM0->M0_CODIGO == 'I7' //Donaldson

		//Adiciona a coluna de pedido na posição 3.
		aAdd(aItens[Len(aItens)],"")
		aIns(aItens[Len(aItens)],3)
		aItens[Len(aItens)][3] := cPedido

	ElseIf SM0->M0_CODIGO == 'R7' //Shiseido

		//Adiciona a coluna de lote na posição 3.
		aAdd(aItens[Len(aItens)],"")
		aIns(aItens[Len(aItens)],9)
		aItens[Len(aItens)][9] := AllTrim(TransForm(nVUniLiq,TM(nValICM,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])))

	EndIf

	cLote       := ''		
	cAuxItem	:= AllTrim(SubStr(oDet[nX]:_Prod:_cProd:TEXT,nMaxCod+1))
	cAux 		:= AllTrim(SubStr(NoChar(oDet[nX]:_Prod:_Prod:TEXT,lConverte),(nMaxDes+1)))
	
	lPontilhado := .F.

	If SM0->M0_CODIGO $ '4M/2C'//Illumina

		//Adiciona a coluna de lote na posição 3.
		aAdd(aItens[Len(aItens)],"")
		aIns(aItens[Len(aItens)],3)
		aItens[Len(aItens)][3] := cLote

		If Empty(cAux) .And. Empty(cAuxItem)		
			If !ProdKit(oDet[nX]:_Prod:_cProd:TEXT) //Verifica se o produto EKit
				lPontilhado := .T.	
			EndIf
		EndIf
	EndIf
	
	While !Empty(cAux) .Or. !Empty(cAuxItem)

		If SM0->M0_CODIGO == 'IS' //Promega
			nMaxCod := MaxCod(cAuxItem, 63)
			nMaxDes := MaxCod(cAux, 120)		

		ElseIf SM0->M0_CODIGO == 'ED' //Okuma
			nMaxCod := MaxCod(cAuxItem, 85)
			nMaxDes := MaxCod(cAux, 165)		

		ElseIf SM0->M0_CODIGO == 'VR' //Power e Telepho
			nMaxCod := MaxCod(cAuxItem, 55)
			nMaxDes := MaxCod(cAux, 165)		
		
		ElseIf SM0->M0_CODIGO == 'EF' //FSI
			nMaxCod := MaxCod(cAuxItem, 90)
			nMaxDes := MaxCod(cAux, 100)		
		Else
			nMaxCod := MaxCod(cAuxItem, 50)
			nMaxDes := MaxCod(cAux, 100)
		EndIf
		
		aadd(aItens,{SubStr(cAuxItem,1,nMaxCod),;
		SubStr(cAux,1,nMaxDes),;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		""})   
		
		//Tratamento customizado para os clientes.
		//RRP - 16/10/2012 retirada da empresa Angelmed HM para alterar a impressão do lote solicitado no chamado 006866.
		//RRP - 19/12/2012 retirada da empresa Ceres CZ.
		//RRP - 16/05/2013 retirada da empresa Ceres U2.
		If SM0->M0_CODIGO $ 'FF|I7|IS|4M|2C'
		
			//Adiciona a coluna de lote na posição 3.
			aAdd(aItens[Len(aItens)],"")
			aIns(aItens[Len(aItens)],3)
			aItens[Len(aItens)][3] := ""

		ElseIf SM0->M0_CODIGO $ "A6|LN" 

			If lLote
		      aAdd(aItens[Len(aItens)],"")
		      aIns(aItens[Len(aItens)],3)
		      aItens[Len(aItens)][3] := ""
		   EndIf
		
		ElseIf SM0->M0_CODIGO == 'R7'

			aAdd(aItens[Len(aItens)],"")
			aIns(aItens[Len(aItens)],9)
			aItens[Len(aItens)][9] := ""
		
		EndIf		
		
		cAux 		:= 	SubStr(cAux,(nMaxDes+1))
		cAuxItem	:=	SubStr(cAuxItem,nMaxCod+1)
		lPontilhado := .T. 
		
		If SM0->M0_CODIGO == 'ED'//Okuma - não devem ser exibidos os pontilhados.
			lPontilhado := .F.

		ElseIf SM0->M0_CODIGO == '4M/2C'//Illumina
			If ProdKit(oDet[nX]:_Prod:_cProd:TEXT) //Verifica se o produto EKit
				lPontilhado := .F.	
	        EndIf
		EndIf		

	EndDo
	
	If (Type("oNf:_infnfe:_det[nPrivate]:_Infadprod:TEXT") <> "U" .Or. Type("oNf:_infnfe:_det:_Infadprod:TEXT") <> "U") .And. ( lImpAnfav .Or. lImpInfAd ).or. !Empty(cCompl)
	
		If !Empty(cCompl)
			cAux := AllTrim(cCompl)
		EndIf
		
		If lImpAnfav
			cAux := AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1))
    	EndIf

		If SM0->M0_CODIGO == 'IS' //Promega
			nMaxDes := MaxCod(cAux, 120)		
		ElseIf SM0->M0_CODIGO == 'ED' //Okuma
			nMaxDes := MaxCod(cAux, 165)		
		ElseIf SM0->M0_CODIGO == 'VR' //Power e Telepho
			nMaxDes := MaxCod(cAux, 165)		
		ElseIf SM0->M0_CODIGO == 'EF' //FSI
			nMaxDes := MaxCod(cAux, 100)		
		Else
			nMaxDes := MaxCod(cAux, 100)
		EndIf

		While !Empty(cAux)
			aadd(aItens,{"",;
			SubStr(cAux,1,nMaxDes),;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			""})

			//Tratamento customizado para os clientes.
			//RRP - 16/10/2012 retirada da empresa Angelmed HM para alterar a impressão do lote solicitado no chamado 006866.
			//RRP - 19/12/2012 retirada da empresa Ceres CZ.
			//RRP - 16/05/2013 retirada da empresa Ceres U2.
			If SM0->M0_CODIGO $ 'FF|I7|IS|4M|2C'
		
				//Adiciona a coluna de lote na posição 3.
				aAdd(aItens[Len(aItens)],"")
				aIns(aItens[Len(aItens)],3)
				aItens[Len(aItens)][3] := ""
            
			ElseIf SM0->M0_CODIGO $ "A6|LN" 
				If lLote
		      		aAdd(aItens[Len(aItens)],"")
					aIns(aItens[Len(aItens)],3)
					aItens[Len(aItens)][3] := ""
		   		EndIf

			ElseIf SM0->M0_CODIGO == 'R7'

				aAdd(aItens[Len(aItens)],"")
				aIns(aItens[Len(aItens)],9)
				aItens[Len(aItens)][9] := ""
		
			EndIf

			cAux := SubStr(cAux,(nMaxDes + 1))
			lPontilhado := .T.

			If SM0->M0_CODIGO $ '4M|2C'//Illumina
				If ProdKit(oDet[nX]:_Prod:_cProd:TEXT) //Verifica se o produto EKit
					lPontilhado := .F.	
		        EndIf
			EndIf		

		EndDo
	EndIf
	If lPontilhado

		If SM0->M0_CODIGO $ 'IS|ED|EF' //Promega,Okuma e FSI
			nMaxPont := nMaxDes
		
		ElseIf SM0->M0_CODIGO $ 'VR' //Power & Telepho
			nMaxPont := 35
		Else
			nMaxPont := MAXITEMC
		EndIf
	
		aadd(aItens,{Replicate("- ",12),;
		Replicate("- ",nMaxPont),;
		Replicate("- ",12),;
		Replicate("- ",05),;
		Replicate("- ",07),;
		Replicate("- ",05),;
		Replicate("- ",08),;
		Replicate("- ",10),;
		Replicate("- ",10),;
		Replicate("- ",10),;
		Replicate("- ",08),;
		Replicate("- ",08),;
		Replicate("- ",06),;
		Replicate("- ",06)})
        
		//Tratamento customizado para os clientes.
		//RRP - 19/12/2012 retirada da empresa Ceres CZ.
		//RRP - 16/05/2013 retirada da empresa Ceres U2.
		If SM0->M0_CODIGO $ 'FF|I7|IS|4M|2C'
		                               
			//Adiciona a coluna de lote na posição 3.
			aAdd(aItens[Len(aItens)],"")
			aIns(aItens[Len(aItens)],3)
			aItens[Len(aItens)][3] := Replicate("- ",10)
		
		ElseIf SM0->M0_CODIGO $ "A6|LN"
			If lLote
				aAdd(aItens[Len(aItens)],"")
				aIns(aItens[Len(aItens)],3)
				aItens[Len(aItens)][3] := Replicate("- ",10)
			EndIf

		ElseIf SM0->M0_CODIGO == 'R7'

			aAdd(aItens[Len(aItens)],"")
			aIns(aItens[Len(aItens)],9)
			aItens[Len(aItens)][9] := Replicate("- ",10)
		
		EndIf

	EndIf

	//Tratamento para exibir os itens do Kit na Danfe	
	If SM0->M0_CODIGO $ "4M|2C" //Illumina
		
   		If oIdent:_TpNf:TEXT == "1" //Nf de Saida
	        
			SC6->(DbSetOrder(1))
	       If SC6->(DbSeek(xFilial("SC6")+aTmpPed[nX,1]+aTmpPed[nX,2]))
				
				nI := 0
				 
				If !Empty(SC6->C6_P_OP)
				
					SD3->(DbSetOrder(1))
					If SD3->(DbSeek(xFilial("SD3")+SC6->C6_P_OP))
						While SD3->(!EOF()) .and. SD3->(D3_FILIAL+D3_OP) == xFilial("SD3")+SC6->C6_P_OP
	               	
							If SD3->D3_CF <> "PR0"
	
								nI++
	                            
								SB1->(DbSetOrder(1))
								If SB1->(DbSeek(xFilial("SB1")+SD3->D3_COD))
		
									nMaxCod := MaxCod(SD3->D3_COD, 63)
									nMaxDes := MaxCod(NoChar(SB1->B1_DESC,lConverte), 120)
		       				
		        					aAdd(aItens,{	SubStr(AllTrim(SD3->D3_COD),1,nMaxCod),;
		        									SubStr(NoChar(AllTrim(SB1->B1_DESC),lConverte),1,nMaxDes),;
		    			    						"",;
		    		    							"",;
		       		 							"",;
		        									"",;
		        									AllTrim(TransForm(SD3->D3_QUANT,TM(SD3->D3_QUANT,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))),;
		        									"",;
					        						"",;
				   				     				"",;
				   					     			"",;
		   			    		 					"",;
		    			    						"",;
				    	    						"" })
	
									BeginSql Alias 'TMP'
									    SELECT D5_LOTECTL, D5_DTVALID
									    FROM %table:SD5%
									    WHERE %notDel%
									      AND D5_OP = %exp:SD3->D3_OP%
									      AND D5_NUMSEQ = %exp:SD3->D3_NUMSEQ%
									      AND D5_PRODUTO = %exp:SD3->D3_COD%
									      AND D5_LOCAL = %exp:SD3->D3_LOCAL%
									EndSql
	                                
									TMP->(DbGoTop())
									If TMP->(!EOF() .and. !BOF())
									
			        					//Adiciona o lote
										aAdd(aItens[Len(aItens)],"")
										aIns(aItens[Len(aItens)],3)
										aItens[Len(aItens)][3] := AllTrim(TMP->D5_LOTECTL)  
		        			
		    	    					cAuxItem := AllTrim(SubStr(SD3->D3_COD ,nMaxCod+1))
										cAux     := AllTrim(SubStr(NoChar(AllTrim(SB1->B1_DESC),lConverte),nMaxDes+1))
										cAuxLote := "Vld:" + AllTrim(DtoC(StoD(TMP->D5_DTVALID)))
									EndIf
	
									TMP->(DbCloseArea())
		
									While !Empty(cAux) .Or. !Empty(cAuxItem) .Or. !Empty(cAuxLote)
										nMaxCod := MaxCod(cAuxItem, 63)
										nMaxDes := MaxCod(cAux, 120)
				
										aadd(	aItens,{SubStr(cAuxItem,1,nMaxCod),;
												SubStr(cAux,1,nMaxDes),;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												"",;
												""})
	
										aAdd(aItens[Len(aItens)],"")
										aIns(aItens[Len(aItens)],3)
										aItens[Len(aItens)][3] := Substr(cAuxLote,1,50)
		
										cAux     := SubStr(cAux,(nMaxDes+1))
										cAuxItem := SubStr(cAuxItem,nMaxCod+1)
										cAuxLote := SubStr(cAuxLote,51)
									EndDo
		                        
									cAux 		:= ""
									cAuxItem	:= ""
									cAuxLote 	:= "" 
								EndIf	
							EndIf
								
							SD3->(DbSkip())
						EndDo
						
						If nI >0 
	
							nMaxPont := MAXITEMC
						
							aadd(aItens,{Replicate("- ",12),;
								Replicate("- ",nMaxPont),;
								Replicate("- ",12),;
								Replicate("- ",05),;
								Replicate("- ",07),;
								Replicate("- ",05),;
								Replicate("- ",08),;
								Replicate("- ",10),;
								Replicate("- ",10),;
								Replicate("- ",10),;
								Replicate("- ",08),;
								Replicate("- ",08),;
								Replicate("- ",06),;
								Replicate("- ",06)})
	
							//Adiciona a coluna de lote na posição 3.
							aAdd(aItens[Len(aItens)],"")
							aIns(aItens[Len(aItens)],3)
							aItens[Len(aItens)][3] := Replicate("- ",10)
						
						EndIf
					EndIf
				EndIf
			EndIf		
		EndIf	   
	EndIf

	//ER - 03/01/12: Calculo dos totais que não são enviados no objeto oTotal.
	nVlProd  += Val(oDet[nX]:_Prod:_vProd:TEXT)
	
	If Type("oDet[nPrivate]:_Prod:_vFrete:TEXT") <> "U" 
		nVlFrete += Val(oDet[nX]:_Prod:_vFrete:TEXT)
	EndIf
	
	If Type("oDet[nPrivate]:_Prod:_vSeg:TEXT") <> "U"
		nVlSeg   += Val(oDet[nX]:_Prod:_vSeg:TEXT)
	EndIf
	
	If Type("oDet[nPrivate]:_Prod:_vDesc:TEXT") <> "U"
		nVlDesc  += Val(oDet[nX]:_Prod:_vDesc:TEXT)
	EndIf
	
	If Type("oDet[nPrivate]:_Prod:_vOutro:TEXT") <> "U"	
		nVlOutro += Val(oDet[nX]:_Prod:_vOutro:TEXT)
	EndIf
	
    nTotIPI  += nValIPI
			
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotais := {"","","","","","","","","","",""}
aTotais[01] := Transform(Val(oTotal:_vBC:TEXT),"@ze 9,999,999,999,999.99")
aTotais[02] := Transform(Val(oTotal:_vICMS:TEXT),"@ze 9,999,999,999,999.99")
aTotais[03] := Transform(Val(oTotal:_vBCST:TEXT),"@ze 9,999,999,999,999.99")
aTotais[04] := Transform(Val(oTotal:_vICMSST:TEXT),"@ze 9,999,999,999,999.99")
aTotais[05] := Transform(nVlProd,"@ze 9,999,999,999,999.99") //Valor dos Produtos
aTotais[06] := Transform(nVlFrete,"@ze 9,999,999,999,999.99") //Valor do Frete
aTotais[07] := Transform(nVlSeg,"@ze 9,999,999,999,999.99") //Valor do Seguro
aTotais[08] := Transform(nVlDesc,"@ze 9,999,999,999,999.99")//Valor do Desconto
aTotais[09] := Transform(nVlOutro,"@ze 9,999,999,999,999.99") //Valor de Outras Despesas
aTotais[10] := Transform(nTotIPI,"@ze 9,999,999,999,999.99") //Valor do IPI
aTotais[11] := Transform(Val(oTotal:_vNF:TEXT),"@ze 9,999,999,999,999.99")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro ISSQN                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aISSQN := {"","","",""}
If Type("oEmitente:_IM:TEXT")<>"U"
	aISSQN[1] := oEmitente:_IM:TEXT
EndIf
If Type("oTotal:_ISSQNtot")<>"U"
	aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@ze 999,999,999.99")
	aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@ze 999,999,999.99")
	aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@ze 999,999,999.99")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro de informacoes complementares                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMensagem := {}    

// JSS - 04/08/2015 Criado mensagem padrão para atender o caso 028172   
If cEmpAnt $ 'O8'
	cAux :="Doravante, a ser depositados exclusivamente na conta corrente de n.º 000217801, na agêncian.º001,do Banco BTG Pactual S.A., de titularidade da Notificante.i. Conta corrente:217801(se a eneva precisar de digito considerar o 1 ultimo numero) ii. Agencia: 001 iii. Banco: Banco BTG Pactual - 208 iv. CNPJ: 14.165.334.0001-20 v. Empresa: BPMB Parnaiba S.A. "	
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf               

cAux := "PRE-DANFE emitida no ambiente de homologação - SEM VALOR FISCAL"
While !Empty(cAux)
	aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
	cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
EndDo

If Type("oNF:_InfNfe:_infAdic:_Fisco:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_Fisco:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_Cpl:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_Cpl:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If cTipo == "0" //Nf Entrada
	If SF1->F1_TIPO == "D"
		If Type("oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT")<>"U"
			cAux := "Valor do Ipi : " + oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
		EndIf
	EndIf
EndIf

If lArt274SP .And. SuperGetMv("MV_ESTADO")$"SP"
	If Type("oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT") <> "U"
		If oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT <> "0"
			cAux := "Imposto recolhido por Substituição - Art 274 do RICMS"
			If oNF:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT == "SP"
				cAux += ": "
				aLote := RastroNFOr(SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA)
				For nX := 1 To Len(aLote)
					nBaseICM := aLote[nX][33]
					nValICM  := aLote[nX][38]
					cAux += Alltrim(aLote[nX][3]) + " - BCST: " + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D1_BRICMS")[1],TamSX3("D1_BRICMS")[2]))) + " e ICMSST: " + ;
					AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D1_ICMSRET")[1],TamSX3("D1_ICMSRET")[2]))) + "/ "
				Next nX
			Endif
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
		Endif
	Endif
Endif

//impressao do valor das Informacoes do cupom fiscal referenciado
If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
	If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
		aInfNf := oNF:_INFNFE:_IDE:_NFREF
	Else
		aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
	EndIf
	
	For Nx := 1 to Len(aInfNf)
		If Type("aInfNf["+Str(nX)+"]:_REFECF:TEXT")<>"U"
			
			//Buscar do SFT, pois no XML nao tem o numero da Serie do Cupom
			//Exemplo de conteudo do SFT->FT_OBSERV = "CF/SERIE:000014 /001 ECF:001"
			dbSelectArea("SFT")
			dbSetOrder(1)
			MsSeek(xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC			+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
			While !SFT->(Eof()) .And. xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA == SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA
				If !Empty(SFT->FT_OBSERV) .And. "CF/SERIE" $ SFT->FT_OBSERV
					cAux := Alltrim(SFT->FT_OBSERV)
					Exit
				Else
					dbSkip()
				EndIf
			EndDo
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
				lCompleECF := .T.
			EndDo
		EndIF
		If lCompleECF
			Exit
		EndIF
	Next
	
EndIf

//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
If !SF3->(Eof()) .And. SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE == SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
	If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
		cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ "
		cAux += Alltrim(Transform(SF3->F3_DS43080,"@ze 9,999,999,999,999.99")) + " ref.reducao de base de calculo"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
		
	EndIf
EndIf

For Nx := 1 to Len(aMensagem)
	NoChar(aMensagem[Nx],lConverte)
Next

If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
	If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
		aInfNf := oNF:_INFNFE:_IDE:_NFREF
	Else
		aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
	EndIf
	
	For nX := 1 to Len(aMensagem)
		If "ORIGINAL"$ Upper(aMensagem[nX])
			lNFori2 := .F.
		EndIf
	Next Nx
	
	cAux1 := ""
	cAux2 := ""
	For Nx := 1 to Len(aInfNf)
		If Type("aInfNf["+Str(nX)+"]:_REFNFE:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNFE:TEXT)$cAux1
			If !"CHAVE"$Upper(cAux1)
				cAux1 += "Chave de acesso da NF-E referenciada: "
			EndIf
			cAux1 += aInfNf[nx]:_REFNFE:TEXT+","
		ElseIf Type("aInfNf["+Str(nX)+"]:_REFNF:_NNF:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNF:_NNF:TEXT)$cAux2 .And. lNFori2
			If !"ORIGINAL"$Upper(cAux2)
				cAux2 += " Numero da nota original: "
			EndIf
			cAux2 += aInfNf[nx]:_REFNF:_NNF:TEXT+","
		EndIf
	Next
	
	cAux	:=	""
	If !Empty(cAux1)
		cAux1	:=	Left(cAux1,Len(cAux1)-1)
		cAux 	+= cAux1
	EndIf
	If !Empty(cAux2)
		cAux2	:=	Left(cAux2,Len(cAux2)-1)
		cAux 	+= 	Iif(!Empty(cAux),CRLF,"")+cAux2
	EndIf
	
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	
	For Nx := 1 to Len(aMensagem)
		NoChar(aMensagem[Nx],lConverte)
	Next
	
EndIf

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³Quadro "RESERVADO AO FISCO"                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResFisco := {}
nBaseIcm  := 0

If GetNewPar("MV_BCREFIS",.F.) .And. SuperGetMv("MV_ESTADO")$"PR"
	If Val(&("oTotal:_ICMSTOT:_VBCST:TEXT")) <> 0
		cAux := "Substituição Tributária: Art. 471, II e §1º do RICMS/PR: "
		nLenDet := Len(oDet)
		For nX := 1 To nLenDet
			oImposto := oDet[nX]
			If Type("oImposto:_Imposto")<>"U"
				If Type("oImposto:_Imposto:_ICMS")<>"U"
					nLenSit := Len(aSitTrib)
					For nY := 1 To nLenSit
						nPrivate2 := nY
						If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
							If Type("oImposto:_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U"
								nBaseIcm := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
								cAux += oDet[nX]:_PROD:_CPROD:TEXT + ": BCICMS-ST R$" + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))) + " / "
							Endif
						Endif
					Next nY
				Endif
			Endif
		Next nX
	Endif
	While !Empty(cAux)
		aadd(aResFisco,SubStr(cAux,1,60))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, 59, MAXMENLIN) +2)
	EndDo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFolhas	  := 1
nLenItens := Len(aItens) - MAXITEM // Todos os produtos/serviços excluindo a primeira página
nMsgCompl := Len(aMensagem) - MAXMSG // Todas as mensagens complementares excluindo a primeira página
lFlag     := .T.
While lFlag
	// Caso existam produtos/serviços e mensagens complementares a serem escritas
	If nLenItens > 0 .And. nMsgCompl > 0
		nFolhas++
		nLenItens -= MAXITEMP2
		nMsgCompl -= MAXMSG
	// Caso existam apenas mensagens complementares a serem escritas
	ElseIf nLenItens <= 0 .And. nMsgCompl > 0
		nFolhas++
		nMsgCompl := 0
		// Caso existam apenas produtos/serviços a serem escritos
	ElseIf nLenItens > 0 .And. nMsgCompl <= 0
		nFolhas++
		nLenItens -= MAXITEMP2F
		// Se não tiver mais nada a ser escrito fecha a contagem
	Else
		lFlag := .F.
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Box - Recibo de entrega                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(000,000,010,501)
//oDanfe:Say(006, 002, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
oDanfe:Box(009,000,037,101)
oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
oDanfe:Box(009,100,037,500)
oDanfe:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
oDanfe:Box(000,500,037,603)
oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
oDanfe:Say(017, 510, "N. "+StrZero(Val(oIdent:_NNf:Text),9), oFont08:oFont)
oDanfe:Say(027, 510, "SÉRIE "+oIdent:_Serie:Text, oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,000,137,250)

//Customização para o logo da Sumitomo.
If SM0->M0_CODIGO == 'FF'

	oDanfe:Say(067,002, "Identificação do emitente",oFont12N:oFont)	
	nLinCalc	:=	080
	cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))
	nForTo		:=	Len(cStrAux)/35
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*35)+1),35), oFont12N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX

	If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_Bairro:Text)
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf                                                       		
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
	 	oDanfe:Say(nLinCalc,002, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
 		nLinCalc+=10
	 	oDanfe:Say(nLinCalc,002, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,002, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
	 	nLinCalc+=10
		oDanfe:Say(nLinCalc,002, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	 	nLinCalc+=10
		oDanfe:Say(nLinCalc,002, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf

Else
	
	oDanfe:Say(052,098, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	065
	cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))

	cStrAux 	:= EECBrkLine(cStrAux,24)//Quebra a string por palavras
	aStrAux  	:= StrToKArr(cStrAux,ENTER) //Adiciona cada linha da string em uma posição do array.
    
    nForTo		:= Len(aStrAux)

	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,aStrAux[nX], oFont12N:oFont )
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_Bairro:Text)
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,248,137,351)
oDanfe:Say(055,275, "DANFE",oFont18N:oFont)
oDanfe:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
oDanfe:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
oDanfe:Box(078,315,095,325)
oDanfe:Say(089,318, oIdent:_TpNf:Text,oFont08N:oFont)
oDanfe:Say(110,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
oDanfe:Say(120,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
oDanfe:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_Logod
	cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
	EndIf
EndIf

If nfolha==1

	If SM0->M0_CODIGO == 'FF' //Sumitomo
		If lMv_Logod
			oDanfe:SayBitmap(042,000,cLogoD,248,11.2)	
	    Else
			oDanfe:SayBitmap(042,000,cLogo,248,11.2)	
		EndIF
	Else

		If lMv_Logod
			oDanfe:SayBitmap(042,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(042,000,cLogo,095,096)
		EndIF
	
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barra                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,350,088,603)
oDanfe:Say(062,450,"PRE-DANFE",oFont18N:oFont,,CLR_HRED)
oDanfe:Box(075,350,110,603)
//oDanfe:Say(095,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
oDanfe:Box(105,350,137,603)

If nFolha == 1
	oDanfe:Say(085,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	//oDanfe:Code128C(072,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
EndIf

oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(139,000,162,603)
oDanfe:Box(139,000,162,350)
oDanfe:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
oDanfe:Say(158,002,oIdent:_NATOP:TEXT,oFont08:oFont)

oDanfe:Say(148,352,"DADOS DA NF-E",oFont08N:oFont)

nFolha++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 5                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(164,000,187,603)
oDanfe:Box(164,000,187,200)
oDanfe:Box(164,200,187,400)
oDanfe:Box(164,400,187,603)
oDanfe:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(180,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(180,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
oDanfe:Say(180,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Type("oDestino:_CNPJ")=="O"
		cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	Case Type("oDestino:_CPF")=="O"
		cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
	OtherWise
		cAux := Space(14)
EndCase


oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(197,000,217,450)
oDanfe:Say(205,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(215,002,NoChar(oDestino:_Nome:TEXT,lConverte),oFont08:oFont)
oDanfe:Box(197,280,217,500)
oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(215,283,cAux,oFont08:oFont)

oDanfe:Box(217,000,237,500)
oDanfe:Box(217,000,237,260)
oDanfe:Say(224,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(234,002,aDest[01],oFont08:oFont)
oDanfe:Box(217,230,237,380)
oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(234,232,aDest[02],oFont08:oFont)
oDanfe:Box(217,380,237,500)
oDanfe:Say(224,382,"CEP",oFont08N:oFont)
oDanfe:Say(234,382,aDest[03],oFont08:oFont)

oDanfe:Box(236,000,257,500)
oDanfe:Box(236,000,257,180)
oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(255,002,aDest[05],oFont08:oFont)
oDanfe:Box(236,150,257,256)
oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(255,152,aDest[06],oFont08:oFont)
oDanfe:Box(236,255,257,341)
oDanfe:Say(245,257,"UF",oFont08N:oFont)
oDanfe:Say(255,257,aDest[07],oFont08:oFont)
oDanfe:Box(236,340,257,500)
oDanfe:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(255,342,aDest[08],oFont08:oFont)

oDanfe:Box(197,502,217,603)
oDanfe:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
oDanfe:Say(215,504,ConvDate(Substr(oIdent:_dhEmi:TEXT,1,10)),oFont08:oFont)
oDanfe:Box(217,502,237,603)
oDanfe:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(233,504,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
oDanfe:Box(236,502,257,603)
oDanfe:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(252,503,Iif(Empty(aDest[10]),"",aDest[10]),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro fatura                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
For nX := 1 To Len(aFaturas)
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][4])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][5])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][6])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][7])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][8])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][9])
	If nY >= 9
		nY := 0
	EndIf
Next nX

oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
oDanfe:Box(265,000,296,068)
oDanfe:Box(265,067,296,134)
oDanfe:Box(265,134,296,202)
oDanfe:Box(265,201,296,268)
oDanfe:Box(265,268,296,335)
oDanfe:Box(265,335,296,403)
oDanfe:Box(265,402,296,469)
oDanfe:Box(265,469,296,537)
oDanfe:Box(265,536,296,603)

nColuna := 002
If Len(aFaturas) >0
	For nY := 1 To 9
		If SM0->M0_CODIGO $ "IS"  //Promega      
			If !Empty(aAux[1][nY][1])
				oDanfe:Say(273,nColuna,"Nº: "+aAux[1][nY][1],oFont08:oFont)
				oDanfe:Say(281,nColuna,"Vecto: "+aAux[1][nY][2],oFont08:oFont)
	   			oDanfe:Say(289,nColuna,"Valor: "+aAux[1][nY][3],oFont08:oFont) 
	   		EndIf
		Else
			oDanfe:Say(273,nColuna,aAux[1][nY][1],oFont08:oFont)
			oDanfe:Say(281,nColuna,aAux[1][nY][2],oFont08:oFont)
			oDanfe:Say(289,nColuna,aAux[1][nY][3],oFont08:oFont)
		EndIf
		nColuna:= nColuna+67
	Next nY
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
oDanfe:Box(307,000,330,121)
oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
If cMVCODREG $ "2|3" 
	oDanfe:Say(326,002,aTotais[01],oFont08:oFont)
ElseIf lImpSimpN
	oDanfe:Say(326,002,aSimpNac[01],oFont08:oFont)	
Endif
oDanfe:Box(307,120,330,200)
oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
If cMVCODREG $ "2|3" 
	oDanfe:Say(326,125,aTotais[02],oFont08:oFont)
ElseIf lImpSimpN
	oDanfe:Say(326,125,aSimpNac[02],oFont08:oFont)
Endif
oDanfe:Box(307,199,330,360)
oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,202,aTotais[03],oFont08:oFont)
oDanfe:Box(307,360,330,490)
oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,363,aTotais[04],oFont08:oFont)
oDanfe:Box(307,490,330,603)
oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(327,491,aTotais[05],oFont08:oFont)


oDanfe:Box(330,000,353,110)
oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
oDanfe:Say(349,002,aTotais[06],oFont08:oFont)
oDanfe:Box(330,100,353,190)
oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
oDanfe:Say(349,102,aTotais[07],oFont08:oFont)
oDanfe:Box(330,190,353,290)
oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
oDanfe:Say(349,194,aTotais[08],oFont08:oFont)
oDanfe:Box(330,290,353,415)
oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
oDanfe:Say(349,295,aTotais[09],oFont08:oFont)
oDanfe:Box(330,414,353,500)
oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
oDanfe:Say(349,420,aTotais[10],oFont08:oFont)
oDanfe:Box(330,500,353,603)
oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(349,506,aTotais[11],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transportador/Volumes transportados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
oDanfe:Box(363,000,386,603)
oDanfe:Say(372,002,"RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(382,002,aTransp[01],oFont08:oFont)
oDanfe:Box(363,245,386,315)
oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
If cModFrete =="0"
	oDanfe:Say(382,247,"0-EMITENTE",oFont08:oFont)
ElseIf cModFrete =="1"
	oDanfe:Say(382,247,"1-DEST/REM",oFont08:oFont)
ElseIf cModFrete =="2"
	oDanfe:Say(382,247,"2-TERCEIROS",oFont08:oFont)
ElseIf cModFrete =="3"
	oDanfe:Say(382,247,"3-REMETENTE",oFont08:oFont)
ElseIf cModFrete =="4"
	oDanfe:Say(382,247,"4-DESTINATARIO",oFont08:oFont)
ElseIf cModFrete =="9"
	oDanfe:Say(382,247,"9-SEM FRETE",oFont08:oFont)
Else
	oDanfe:Say(382,247,"",oFont08:oFont)
Endif
//oDanfe:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
oDanfe:Box(363,315,386,370)
oDanfe:Say(372,317,"CÓDIGO ANTT",oFont08N:oFont)
oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
oDanfe:Box(363,370,386,490)
oDanfe:Say(372,375,"PLACA DO VEÍCULO",oFont08N:oFont)
oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
oDanfe:Box(363,450,386,510)
oDanfe:Say(372,452,"UF",oFont08N:oFont)
oDanfe:Say(382,452,aTransp[05],oFont08:oFont)
oDanfe:Box(363,510,386,603)
oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(382,512,aTransp[06],oFont08:oFont)

oDanfe:Box(385,000,409,603)
oDanfe:Box(385,000,409,241)
oDanfe:Say(393,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(404,002,aTransp[07],oFont08:oFont)
oDanfe:Box(385,240,409,341)
oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(404,242,aTransp[08],oFont08:oFont)
oDanfe:Box(385,340,409,440)
oDanfe:Say(393,342,"UF",oFont08N:oFont)
oDanfe:Say(404,342,aTransp[09],oFont08:oFont)
oDanfe:Box(385,440,409,603)
oDanfe:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(404,442,aTransp[10],oFont08:oFont)


oDanfe:Box(408,000,432,603)
oDanfe:Box(408,000,432,101)
oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
oDanfe:Say(428,002,aTransp[11],oFont08:oFont)
oDanfe:Box(408,100,432,200)
oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
oDanfe:Say(428,102,Iif(!Empty(aTransp[12]),aTransp[12],Iif(Len(aEspVol)>0,aEspVol[1][1],"")),oFont08:oFont)
//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(408,200,432,301)
oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
oDanfe:Say(428,202,aTransp[13],oFont08:oFont)
oDanfe:Box(408,300,432,400)
oDanfe:Say(418,302,"NUMERAÇÃO",oFont08N:oFont)
oDanfe:Say(428,302,aTransp[14],oFont08:oFont)
oDanfe:Box(408,400,432,501)
oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(428,402,Iif(!Empty(aTransp[15]),aTransp[15],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][3])>0,Transform(Val(aEspVol[1][3]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
oDanfe:Box(408,500,432,603)
oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(428,502,Iif(!Empty(aTransp[16]),aTransp[16],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][2])>0,Transform(Val(aEspVol[1][2]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do ISSQN                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
oDanfe:Box(688,000,711,151)
oDanfe:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
oDanfe:Box(688,150,711,301)
oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
oDanfe:Box(688,300,711,451)
oDanfe:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
oDanfe:Box(688,450,711,603)
oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
oDanfe:Box(721,000,865,351)
oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)

nLenMensagens:= Len(aMensagem)
nLin:= 741
nMensagem := 0
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,002,aMensagem[nX],oFont08:oFont)
	nLin:= nLin+10
Next nX
nMensagem := nX

oDanfe:Box(721,350,865,603)
oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

nLenMensagens:= Len(aResFisco)
nLin:= 741
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,351,aResFisco[nX],oFont08:oFont)
	nLin:= nLin+10
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}

//Tratamento customizado para os clientes.
//RRP - 19/12/2012 retirada da empresa Ceres CZ.
//RRP - 16/05/2013 retirada da empresa Ceres U2.
If SM0->M0_CODIGO $ 'FF|I7|R7|4M|2C'

	aAdd(aAux[1],{})
//RRP - 16/10/2012 retirada da empresa Angelmed HM para alterar a impressão do lote solicitado no chamado 006866.
ElseIf SM0->M0_CODIGO $ "A6|LN|IS|HB"
	If lLote
		aAdd(aAux[1],{})
	EndIf
EndIf

nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])
  
	If Len(aAux[1]) == 14

		If nY >= 14
			nY := 0
		EndIf

	ElseIf Len(aAux[1]) == 15

    	nY++
		aadd(Atail(aAux)[nY],aItens[nX][15])	
	
		If nY >= 15
			nY := 0
		EndIf
	EndIf
Next nX

For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
  
	If Len(aAux[1]) == 14
		If nY >= 14
			nY := 0
		EndIf

	ElseIf Len(aAux[1]) == 15

		nY++
		aadd(Atail(aAux)[nY],"")
	
		If nY >= 15
			nY := 0
		EndIf
	EndIf
	
Next nX

//Define o tamanho das colunas da seção de produtos.
//Estrutura do array: 	[1]: Tamanho da coluna
//						[2]: Descrição do campo
//						[3]: Tipo do campo
//                      [4]: Tamanho do campo
//RRP - 19/12/2012 retirada da empresa Ceres CZ.
//RRP - 16/05/2013 retirada da empresa Ceres U2.
If SM0->M0_CODIGO $ '4M|2C' //Dr. Reddy's, Ceres e Illumina

	aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
				{100,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{050,"LOTE"						,"C",},; //Lote
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{049,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{044,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{035,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{025,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'FF' //Sumitomo

	aCabProd:= {{043,"COD. PROD"				,"C",},; //Cod. Prod.
				{094,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{046,"LOTE"						,"C",},; //Lote
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{018,"UN"						,"C",},; //UN
				{060,"QUANT."					,"N",060},; //Quant.
				{049,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{044,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{035,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{025,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'IS' //Promega

	//If oIdent:_TpNf:Text == "1" //Nota de Saúa
	If lLote
		aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
					{100,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
					{050,"LOTE"						,"C",},; //Lote
					{035,"NCM/SH"					,"C",},; //NCM 
					{020,"CST"						,"C",},; //CST
					{020,"CFOP"						,"C",},; //CFOP
					{020,"UN"						,"C",},; //UN
					{039,"QUANT."					,"N",045},; //Quant.
					{049,"V.UNITARIO"				,"N",052},; //Vl. Unit.
					{054,"V.TOTAL"					,"N",050},; //Vl. Total
					{044,"BC.ICMS"					,"N",050},; //Bc. ICMS
					{035,"V.ICMS"					,"N",045},; //V. ICMS
					{035,"V.IPI"					,"N",045},; //V. IPI
					{025,"A.ICMS"					,"N",030},; //A. ICMS
					{025,"A.IPI"					,"N",036}} //A. IPI

	Else
		aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
					{103,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
					{035,"NCM/SH"					,"C",},; //NCM 
					{020,"CST"						,"C",},; //CST
					{020,"CFOP"						,"C",},; //CFOP
					{020,"UN"						,"C",},; //UN
					{039,"QUANT."					,"N",045},; //Quant.
					{057,"V.UNITARIO"				,"N",052},; //Vl. Unit.
					{054,"V.TOTAL"					,"N",050},; //Vl. Total
					{065,"BC.ICMS"					,"N",050},; //Bc. ICMS
					{050,"V.ICMS"					,"N",045},; //V. ICMS
					{035,"V.IPI"					,"N",045},; //V. IPI
					{028,"A.ICMS"					,"N",030},; //A. ICMS
					{025,"A.IPI"					,"N",036}} //A. IPI
	EndIf
	
ElseIf SM0->M0_CODIGO $ 'LN|A6' //Sirona, NeoGen e Perstorp

	If lLote
		aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
					{090,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
					{045,"LOTE"						,"C",},; //Lote
					{035,"NCM/SH"					,"C",},; //NCM 
					{020,"CST"						,"C",},; //CST
					{020,"CFOP"						,"C",},; //CFOP
					{020,"UN"						,"C",},; //UN
					{039,"QUANT."					,"N",045},; //Quant.
					{054,"V.UNITARIO"				,"N",052},; //Vl. Unit.
					{054,"V.TOTAL"					,"N",050},; //Vl. Total
					{054,"BC.ICMS"					,"N",050},; //Bc. ICMS
					{035,"V.ICMS"					,"N",045},; //V. ICMS
					{035,"V.IPI"					,"N",045},; //V. IPI
					{025,"A.ICMS"					,"N",030},; //A. ICMS
					{025,"A.IPI"					,"N",036}} //A. IPI
	Else

		aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
					{135,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
					{035,"NCM/SH"					,"C",},; //NCM 
					{020,"CST"						,"C",},; //CST
					{020,"CFOP"						,"C",},; //CFOP
					{020,"UN"						,"C",},; //UN
					{039,"QUANT."					,"N",045},; //Quant.
					{054,"V.UNITARIO"				,"N",052},; //Vl. Unit.
					{054,"V.TOTAL"					,"N",050},; //Vl. Total
					{054,"BC.ICMS"					,"N",050},; //Bc. ICMS
					{035,"V.ICMS"					,"N",045},; //V. ICMS
					{035,"V.IPI"					,"N",045},; //V. IPI
					{025,"A.ICMS"					,"N",030},; //A. ICMS
					{025,"A.IPI"					,"N",036}} //A. IPI
	EndIf


ElseIf SM0->M0_CODIGO == 'I7' //Donaldson

	aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
				{100,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{041,"PEDIDO"					,"C",},; //Lote
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{037,"QUANT."					,"N",045},; //Quant.
				{050,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{054,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{035,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{025,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'R7' //Shiseido

	aCabProd:= {{051,"COD. PROD"				,"C",},; //Cod. Prod.
				{098,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{050,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{050,"V.LIQ"					,"N",052},; //Vl. Liqui.
				{050,"V.TOTAL"					,"N",050},; //Vl. Total
				{050,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{035,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{025,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'ED' //Okuma

	aCabProd:= {{067,"COD. PROD"				,"C",},; //Cod. Prod.
				{140,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{050,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{035,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{035,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{028,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'EF' //FSI

	aCabProd:= {{070,"COD. PROD"				,"C",},; //Cod. Prod.
				{103,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{054,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{050,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{050,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{028,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

ElseIf SM0->M0_CODIGO == 'VR' //Power e Telepho

	aCabProd:= {{050,"COD. PROD"				,"C",},; //Cod. Prod.
				{140,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{018,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{054,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{050,"V.TOTAL"					,"N",050},; //Vl. Total
				{049,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{040,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{028,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI

Else

	aCabProd:= {{052,"COD. PROD"				,"C",},; //Cod. Prod.
				{103,"DESCRIÇÃO DO PROD./SERV."	,"C",},; //Descrição
				{035,"NCM/SH"					,"C",},; //NCM 
				{020,"CST"						,"C",},; //CST
				{020,"CFOP"						,"C",},; //CFOP
				{020,"UN"						,"C",},; //UN
				{039,"QUANT."					,"N",045},; //Quant.
				{057,"V.UNITARIO"				,"N",052},; //Vl. Unit.
				{054,"V.TOTAL"					,"N",050},; //Vl. Total
				{065,"BC.ICMS"					,"N",050},; //Bc. ICMS
				{050,"V.ICMS"					,"N",045},; //V. ICMS
				{035,"V.IPI"					,"N",045},; //V. IPI
				{028,"A.ICMS"					,"N",030},; //A. ICMS
				{025,"A.IPI"					,"N",036}} //A. IPI
EndIf

nLin := 440
nCol := 002

oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)

//Desenha o retangulo total de dados do produto
oDanfe:Box(442,000,678,603)

nLin := 450

//Impressão dos produtos
For nI := 1 To Len(aCabProd)
    
	If nI == 1
		nLinIni := 442+nLinhavers
		nColIni := 000
		nLinFim := 678+nLinhavers
		nColFim := aCabProd[1][1]
	Else
		nColIni := nColFim
		nColFim += aCabProd[nI][1]
		nCol    := nColIni + 2
	EndIf    

	oDanfe:Box(nLinIni,nColIni,nLinFim,nColFim)
	oDanfe:Say(nLin,nCol,aCabProd[nI][2],oFont08N:oFont)
Next

// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
nLinha    :=460
nL:=0

For nY := 1 To nLenItens
	nL:= nL +1
	
	nLin:= 741
	nCont := 0
	
	If lflag
		If nL > nMaxItemP2

			oDanfe:EndPage()
			oDanfe:StartPage()
			nLinhavers := 0
			nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)
			
			oDanfe:Box(000+nLinhavers,000,095+nLinhavers,250)

			//Customização de logo da Sumitomo			
			If SM0->M0_CODIGO == 'FF'

				oDanfe:Say(025,002, "Identificação do emitente",oFont12N:oFont)
				
				nLinCalc	:=	038
				cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))
				nForTo		:=	Len(cStrAux)/35
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*35)+1),35), oFont12N:oFont )
					nLinCalc+=10
				Next nX
			
				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
			
				If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
					cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
					nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX
			
					cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte))
					If Type("oEmitente:_EnderEmit:_Cep")<>"U"
						cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
					EndIf                                                       		
						nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,002,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX
				 	oDanfe:Say(nLinCalc,002, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				 	nLinCalc+=10
				 	oDanfe:Say(nLinCalc,002, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				Else
					oDanfe:Say(nLinCalc,002, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,002, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,002, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				EndIf
			
			Else
				oDanfe:Say(010+nLinhavers,098, "Identificação do emitente",oFont12N:oFont)
				
				nLinCalc	:=	023 + nLinhavers
				cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))

				cStrAux 	:= EECBrkLine(cStrAux,24)//Quebra a string por palavras
				aStrAux  	:= StrToKArr(cStrAux,ENTER) //Adiciona cada linha da string em uma posição do array.
    
			    nForTo		:= Len(aStrAux)

				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,aStrAux[nX], oFont12N:oFont )
					nLinCalc+=10
				Next nX

				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				
				If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
					cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
					nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX
					
					cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte))
					If Type("oEmitente:_EnderEmit:_Cep")<>"U"
						cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
					EndIf
					nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX
					oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				Else
					oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				EndIf

			EndIf
						
			oDanfe:Box(000+nLinhavers,248,095+nLinhavers,351)
			oDanfe:Say(013+nLinhavers,255, "DANFE",oFont18N:oFont)
			oDanfe:Say(023+nLinhavers,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
			oDanfe:Say(033+nLinhavers,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
			oDanfe:Say(043+nLinhavers,255, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(053+nLinhavers,255, "1-SAÍDA"  ,oFont08:oFont)
			oDanfe:Box(037+nLinhavers,305,047+nLinhavers,315)
			oDanfe:Say(045+nLinhavers,307, oIdent:_TpNf:Text,oFont08N:oFont)
			oDanfe:Say(062+nLinhavers,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
			oDanfe:Say(072+nLinhavers,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
			oDanfe:Say(082+nLinhavers,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
			
			oDanfe:Box(000+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Box(000+nLinhavers,350,040+nLinhavers,603)
			oDanfe:Box(040+nLinhavers,350,062+nLinhavers,603)
			oDanfe:Box(063+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Say(058+nLinhavers,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
			
			oDanfe:Say(048+nLinhavers,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
			nFontSize := 28
			oDanfe:Code128C(036+nLinhavers,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )

			//Customização Sumitomo
			If SM0->M0_CODIGO == 'FF'
				If lMv_Logod
					oDanfe:SayBitmap(000,000,cLogoD,248,11.2)	
				Else
					oDanfe:SayBitmap(000,000,cLogo,248,11.2)	
				EndIf
			Else			
				If lMv_Logod
					oDanfe:SayBitmap(000+nLinhavers,000,cLogoD,095,096)
				Else
					oDanfe:SayBitmap(000+nLinhavers,000,cLogo,095,096)
				EndIf
			EndIf
				
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,603)
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,300)
			oDanfe:Say(109+nLinhavers,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
			oDanfe:Say(119+nLinhavers,002,oIdent:_NATOP:TEXT,oFont08:oFont)
			oDanfe:Say(119+nLinhavers,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(substr(oNF:_InfNfe:_IDE:_dhEmi:Text,1,10)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(substr(oNF:_InfNfe:_IDE:_dhEmi:Text,1,10)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
			
			nFolha++
			
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,603)
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,200)
			oDanfe:Box(126+nLinhavers,200,153+nLinhavers,400)
			oDanfe:Box(126+nLinhavers,400,153+nLinhavers,603)
			oDanfe:Say(135+nLinhavers,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,405,"CNPJ",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
			
			nLenMensagens:= Len(aMensagem)
			
			nColLim		:=	Iif(nMensagem < nLenMensagens,680,865) + nLinhavers
			oDanfe:Say(161+nLinhavers,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
			oDanfe:Box(163+nLinhavers,000,nColLim,603)
			
			nLin    := 171+nLinhavers
            
			//Impressão dos produtos
			For nI := 1 To Len(aCabProd)
                
				If nI == 1
					nLinIni := 163+nLinhavers
					nColIni := 000
					nLinFim := nColLim
					nColFim := aCabProd[1][1]
				Else
					nColIni := nColFim
					nColFim += aCabProd[nI][1]
					nCol    := nColIni + 2
				EndIf

				oDanfe:Box(nLinIni,nColIni,nLinFim,nColFim)
				oDanfe:Say(nLin,nCol,aCabProd[nI][2],oFont08N:oFont)

			Next
			
			// FINALIZANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
			nL :=0
			lFlag:=.F.
			
			//Verifico se ainda existem Dados Adicionais a serem impressos
			If nMensagem < nLenMensagens
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados Adicionais                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721+nLinhavers,000,865+nLinhavers,351)
				oDanfe:Say(729+nLinhavers,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
				
				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX
				
				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
				
				// Seta o máximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
			Else
				// Seta o máximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
		Endif
	Endif

	// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 3 E DIANTE
	If	nL > nMaxItemP2
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLenMensagens:= Len(aMensagem)
		nColLim		:=	Iif(nMensagem < nLenMensagens,680,865)
		lFimpar		:=  ((nfolha-1)%2==0)
		nLinha    	:=	181
		If nfolha >= 3
			nLinhavers := 0
		EndIf
		oDanfe:Box(000,000,095,250)

		//Customização Sumitomo
		If SM0->M0_CODIGO == 'FF'
			
			oDanfe:Say(025,000, "Identificação do emitente",oFont12N:oFont)
			nLinCalc	:=	038
			cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))
			nForTo		:=	Len(cStrAux)/35
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,000,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*35)+1),35), oFont12N:oFont )
				nLinCalc+=10
			Next nX
		
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,000,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
		
			If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
				cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,000,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
		
				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte))
				If Type("oEmitente:_EnderEmit:_Cep")<>"U"
					cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
				EndIf                                                       		
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,000,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				 	oDanfe:Say(nLinCalc,000, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			 	nLinCalc+=10
			 	oDanfe:Say(nLinCalc,000, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			Else
				oDanfe:Say(nLinCalc,000, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,000, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,000, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			EndIf

	    Else

			oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
			nLinCalc	:=	023
			cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))
			
			cStrAux 	:= EECBrkLine(cStrAux,24)//Quebra a string por palavras
			aStrAux  	:= StrToKArr(cStrAux,ENTER) //Adiciona cada linha da string em uma posição do array.
    
		    nForTo		:= Len(aStrAux)

			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,aStrAux[nX], oFont12N:oFont )
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			
			If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
				cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				
				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte))
				If Type("oEmitente:_EnderEmit:_Cep")<>"U"
					cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
				EndIf
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			Else
				oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			EndIf
		
		EndIf
		
		oDanfe:Box(000,248,095,351)
		oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
		oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
		oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
		oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
		oDanfe:Box(037,305,047,315)
		oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
		oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
		oDanfe:Say(072,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
		oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
		
		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
		
		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		
		//Customização Sumitomo
		If SM0->M0_CODIGO == 'FF'
			If lMv_Logod
				oDanfe:SayBitmap(000,000,cLogoD,248,11.2)	
			Else
				oDanfe:SayBitmap(000,000,cLogo,248,11.2)				
			EndIf	
		Else
			If lMv_Logod
				oDanfe:SayBitmap(000,000,cLogoD,095,096)
			Else	
				oDanfe:SayBitmap(000,000,cLogo,095,096)
			EndIf
		EndIf
		
		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
		oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
		nFolha++
		
		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
		oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
		
		oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
		oDanfe:Box(163,000,nColLim,603)
	    
		nLin    := 171+nLinhavers
		nCol    := 002 
			
		//Impressão dos produtos
		For nI := 1 To Len(aCabProd)
            
			If nI == 1
				nLinIni := 163+nLinhavers
				nColIni := 000
				nLinFim := nColLim
				nColFim := aCabProd[1][1]
			Else
				nColIni := nColFim
				nColFim += aCabProd[nI][1]
				nCol    := nColIni + 2
			EndIf

			oDanfe:Box(nLinIni,nColIni,nLinFim,nColFim)
			oDanfe:Say(nLin,nCol,aCabProd[nI][2],oFont08N:oFont)

		Next
		
		//Verifico se ainda existem Dados Adicionais a serem impressos
		nLenMensagens:= Len(aMensagem)
		IF nMensagem < nLenMensagens
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados Adicionais                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
			oDanfe:Box(721,000,865,351)
			oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
			
			nLin:= 741
			nLenMensagens:= Len(aMensagem)
			--nMensagem
			For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
				oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
				nLin:= nLin+10
			Next nX
			nMensagem := nMensagem+nX
			
			oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
			oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
			
			// Seta o máximo de itens para o MAXITEMP2
			nMaxItemP2 := MAXITEMP2
		Else
			// Seta o máximo de itens para o MAXITEMP2F
			nMaxItemP2 := MAXITEMP2F
		EndIF
		nL:=0
	EndIf
	
	//Impressão dos dados dos produtos
	For nI := 1 To Len(aCabProd)

		If aCabProd[nI][3] == "C"

			If nI == 1
				nColIni := 000
				nColFim := aCabProd[nI][1]
			Else
				nColIni := nColFim
				nColFim += aCabProd[nI][1]
			EndIf
					
			nCol    := nColIni + 2
			
			oDanfe:Say(nLinha,nCol,aAux[1][nI][nY],oFont08:oFont)

		ElseIf aCabProd[nI][3] == "N"
			
			nColIni := nColFim
			nColFim := nColIni + aCabProd[nI][1]
		
			nCol    := nColFim - aCabProd[nI][4] 
			
			oDanfe:SayAlign(nLinha-5,nCol,aAux[1][nI][nY],oFont08:oFont,aCabProd[nI][4],10,,1,)  

		EndIf    

	Next	
	nLinha :=nLinha + 10
Next nY

nLenMensagens := Len(aMensagem)
While nMensagem < nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab, cLogoD)
EndDo

oDanfe:EndPage()

Return Nil                                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Complemento da NFe                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab, cLogoD)
Local nX            := 0
Local nLinha        := 0
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForMensagens := 0
Local lMensagens    := .F.
Local cLogo      	:= FisxLogo("1")
Local cChaveCont 	:= ""
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lMv_Logod     := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄ¿
//³Dados Adicionais segunda parte em diante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄÙ
If lMensagens
	nLenMensagens := Len(aMensagem)
	nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
	oDanfe:EndPage()
	oDanfe:StartPage()
	nLinha    :=180
	oDanfe:Say(160,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(172,000,865,351)
	oDanfe:Say(170,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	oDanfe:Box(172,350,865,603)
	oDanfe:Say(170,352,"RESERVADO AO FISCO",oFont08N:oFont)
	
	oDanfe:Box(000,000,095,250)
	oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	023
	cStrAux		:=	AllTrim(NoChar(oEmitente:_Nome:Text,lConverte))
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Lgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	If Type("oEmitente:_EnderEmit:_Cpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_Cpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_Bairro:Text,lConverte))
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Bairro:Text+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_Mun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
	
	oDanfe:Box(000,248,095,351)
	oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
	oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
	oDanfe:Box(037,305,047,315)
	oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
	oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
	oDanfe:Say(072,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
	oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
	
	oDanfe:Box(000,350,095,603)
	oDanfe:Box(000,350,040,603)
	oDanfe:Box(040,350,062,603)
	oDanfe:Box(063,350,095,603)
	//oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
	
	oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	//oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
	
	If SM0->M0_CODIGO == 'FF' //Sumitomo
		If lMv_Logod
			oDanfe:SayBitmap(000,000,cLogoD,248,11.2)	
		Else
			oDanfe:SayBitmap(000,000,cLogo,248,11.2)				
		EndIf	
	Else
		If lMv_Logod
			oDanfe:SayBitmap(000,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(000,000,cLogo,095,096)
		EndIf
	EndIf
	
	oDanfe:Box(100,000,123,603)
	oDanfe:Box(100,000,123,300)
	oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
	If(!Empty(cCodAutDPEC))
		oDanfe:Say(109,300,"NÚMERO DE REGISTRO DPEC",oFont08N:oFont)
	Endif
	If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_INFNFE:_IDE:_TPNFE:TEXT)$"2") .Or. (oNFe:_INFNFE:_IDE:_TPNFE:TEXT)$"1")
		oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
	Endif
	If((oNFe:_INFNFE:_IDE:_TPNFE:TEXT)$"25")
		oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
	Endif
	oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(substr(oNF:_InfNfe:_IDE:_dhEmi:Text,1,10)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_INFNFE:_IDE:_TPNFE:TEXT)$"23") .Or. (oNFe:_INFNFE:_IDE:_TPNFE:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(substr(oNF:_InfNfe:_IDE:_dhEmi:Text,1,10)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
	nFolha++
	
	oDanfe:Box(126,000,153,603)
	oDanfe:Box(126,000,153,200)
	oDanfe:Box(126,200,153,400)
	oDanfe:Box(126,400,153,603)
	oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
	oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
	
	For nX := nMensagem To nForMensagens
		oDanfe:Say(nlinha,002,aMensagem[nX],oFont08:oFont)
		nMensagem++
		nLinha:= nLinha+ 10
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:EndPage()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Fabio Santana	     º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte caracteres espceiais						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
*---------------------------------------*
Static Function NoChar(cString,lConverte)
*---------------------------------------*
Default lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf

Return(cString)

*-----------------------------*
Static Function ConvDate(cData)
*-----------------------------*
Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para saber quantos caracteres irão caber na linha ³
//³ visto que letras ocupam mais espaço do que os números.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*--------------------------------------*
STATIC FUNCTION MaxCod(cString,nTamanho)
*--------------------------------------*
Local nMax	:= 0
Local nY   	:= 0
Default nTamanho := 45

For nMax := 1 to Len(cString)
	If IsAlpha(SubStr(cString,nMax,1)) .And. SubStr(cString,nMax,1) $ "MOQW"  // Caracteres que ocupam mais espaço em pixels
		nY += 7
	Else
		nY += 5
	EndIf
	
	If nY > nTamanho   // Eo máximo de espaço para uma coluna
		nMax--
		Exit
	EndIf
Next

Return nMax

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Marcos Taranta      º Data ³  10/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega uma posição (nTam) na string cString, e retorna o      º±±
±±º          ³caractere de espaço anterior.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
* inválido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espaço anterior a posição e retorna a posição
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso não encontre nenhum caractere de espaço, Eretornado 0.
*/
nRetorno := 0

Return nRetorno       

/*
Função  : ProdKit
Objetivo: Verifica se o produto Eum Kit.
Autor   : Eduardo C. Romanini
Data    : 11/10/2012 15:54
*/
*----------------------------*
Static Function ProdKit(cProd)
*----------------------------*
Local lRet := .F.

//Illumina
If SM0->M0_CODIGO $ "4M/2C"

	SG1->(DbSetOrder(1))
	If SG1->(DbSeek(xFilial("SG1")+cProd))
    	lRet := .T.
	EndIf
	
EndIf                              

Return lRet
