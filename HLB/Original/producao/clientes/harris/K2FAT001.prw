#include "rwmake.ch"
#include "protheus.ch"
  
/*
Funcao      : K2FAT001
Parametros  : 
Retorno     : 
Objetivos   : Impressão de reltorio de demonstrativo de custo do produto.
Autor       : Jean Victor Rocha
Data/Hora   : 12/01/2012
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Faturamento.
*/

*-----------------------*
User Function K2FAT001()      
*-----------------------* 
     
Local i

Private cTitRpt    := "Receita x Custo"
Private cNome      := ""
Private cAliasWork := "DET"
Private cQRY1      := "QRY1"
Private cQRY2      := "QRY2"  
Private cPerg      := "K2FAT001"
Private cDtIni,cDtFim,cTipTES,cTipoNf,lGeraXLS
Private oReport
Private aRetCrw    := {}
Private lR4        := .T. //FindFunction("TRepInUse") .And. TRepInUse()

If !lR4
	MSGINFO("Este ambiente não esta preparado para executar este relatorio, entre em contato com o administrador do sistema.")
	Return .t.
EndIf

aCamposD:= {{"D2_CLIENTE", K2SX3("D2_CLIENTE","TIP"), K2SX3("D2_CLIENTE","TAM"), K2SX3("D2_CLIENTE","DEC") } ,;//Customer Name
			{"D2_DOC"    , K2SX3("D2_DOC"    ,"TIP"), K2SX3("D2_DOC"    ,"TAM"), K2SX3("D2_DOC"    ,"DEC") } ,;//Nota
			{"D2_EMISSAO", K2SX3("D2_EMISSAO","TIP"), K2SX3("D2_EMISSAO","TAM"), K2SX3("D2_EMISSAO","DEC") } ,;//Dt. Emissao
			{"C5_P_PROJ" , "C"                      , 10                       , 0                         } ,;//Projeto
			{"D2_COD"    , K2SX3("D2_COD"    ,"TIP"), K2SX3("D2_COD"    ,"TAM"), K2SX3("D2_COD"    ,"DEC") } ,;//Cod. Produto
			{"B1_DESC"   , K2SX3("B1_DESC"   ,"TIP"), K2SX3("B1_DESC"   ,"TAM"), K2SX3("B1_DESC"   ,"DEC") } ,;//Part Number
			{"D2_TES"    , "C"                      , 9                        , 0                         } ,;//Equipamento/Servico
			{"D2_TOTAL"  , K2SX3("D2_TOTAL"  ,"TIP"), K2SX3("D2_TOTAL"  ,"TAM"), K2SX3("D2_TOTAL"  ,"DEC") } ,;//Valor Faturado
			{"B1_GRUPO"  , K2SX3("B1_GRUPO"  ,"TIP"), K2SX3("B1_GRUPO"  ,"TAM"), K2SX3("B1_GRUPO"  ,"DEC") } ,;//Familia
			{"D2_VALICM" , K2SX3("D2_VALICM" ,"TIP"), K2SX3("D2_VALICM" ,"TAM"), K2SX3("D2_VALICM" ,"DEC") } ,;//Valor ICMS
			{"D2_VALIPI" , K2SX3("D2_VALIPI" ,"TIP"), K2SX3("D2_VALIPI" ,"TAM"), K2SX3("D2_VALIPI" ,"DEC") } ,;//Valor IPI
			{"D2_VALIMP5", K2SX3("D2_VALIMP5","TIP"), K2SX3("D2_VALIMP5","TAM"), K2SX3("D2_VALIMP5","DEC") } ,;//Valor PIS
			{"D2_VALIMP6", K2SX3("D2_VALIMP6","TIP"), K2SX3("D2_VALIMP6","TAM"), K2SX3("D2_VALIMP6","DEC") } ,;//Valor Confins
			{"D2_VALISS ", K2SX3("D2_VALISS" ,"TIP"), K2SX3("D2_VALISS" ,"TAM"), K2SX3("D2_VALISS" ,"DEC") } ,;//Valor ISS
			{"FATLIQUI"  , K2SX3("D2_TOTAL"  ,"TIP"), K2SX3("D2_TOTAL"  ,"TAM"), K2SX3("D2_TOTAL"  ,"DEC") } ,;//Faturamento liquido
			{"CUSTOPROD" , K2SX3("D2_TOTAL"  ,"TIP"), K2SX3("D2_TOTAL"  ,"TAM"), K2SX3("D2_TOTAL"  ,"DEC") }}  //Custo do produto

If !(cEmpAnt $ "K2/K9/LP")//Harris
	MsgAlert("Rotina não disponivel para essa empresa","Atenção")
	Return .F.
EndIf  

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf
If Select(cQRY1) > 0
	(cQRY1)->(DbCloseArea())
EndIf 
If Select(cQRY2) > 0
	(cQRY2)->(DbCloseArea())
EndIf   
               
cNome := CriaTrab(aCamposD,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)

DbSelectArea(cAliasWork)
cIndex:=CriaTrab(Nil,.F.)
IndRegua(cAliasWork,cIndex,"D2_COD+D2_DOC",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

pergunte(cPerg,.T.)

K2GeraDados()

oReport := ReportDef()
oReport:PrintDialog()

CrwCloseFile(aRetCrw,.T.)
            
Return .T.   

*----------------------------*
Static Function K2GeraDados()
*----------------------------*
Local nPos := 0

Private aNFServ := {}

cDtIni  := DTOS(mv_par01)
cDtFim  := DTOS(mv_par02)
cTipTES := mv_par03
lGeraXLS:= (mv_par04==2)

If cTipTES <> 3//Todas
	cTipoNf := GetMV("MV_P_TES",,"56V/5BL")
	While Len(cTipoNf) > 0
		nPos := At("/" , Upper(cTipoNf))
		If nPos == 0 .and. Len(cTipoNf)>0
			aAdd(aNFServ, cTipoNf)		
			cTipoNf := ""
		Else
			aAdd(aNFServ, Substr(Upper(cTipoNf),1,nPos-1))
			cTipoNf := Substr(Upper(cTipoNf),nPos+1,Len(cTipoNf))
		EndIf
	EndDo
EndIf


cFil:=CFILANT 
                    
K2Qry1()//CARREGA DADOS (NF DE SAIDA)
K2Qry2()//CARREGA DADOS (NF DE DEVOLUÇÂO)  

GrvWork()//Carrega a Work. 

Return .T.

*----------------------------*
Static Function K2Qry1()
*----------------------------*
Local i 
Local cQry      := ""
Local cAliasQry := "QRY1"

aStru:= SD2->(DbStruct())

cQry := "SELECT D2.*"
cQry += " FROM "+RetSqlName("SD2")+" D2"
cQry += " WHERE D2.D_E_L_E_T_ <> '*'"

If !Empty(cDtIni)
	cQry+=" AND D2.D2_EMISSAO>='"+cDtIni +"'"
EndIf
If !Empty(cDtFim)
	cQry+=" AND D2.D2_EMISSAO<='"+cDtFim +"'"
EndIf   

If Len(aNFServ) > 0 .and. cTipTES <> 3//Todas
	cQry +=" AND("
	For i:=1 to Len(aNFServ)
		If cTipTES == 2//Servico
			cQry +=" D2.D2_TES ='"+aNFServ[i]+"' OR"
		Else //Revenda
			cQry +=" D2.D2_TES <>'"+aNFServ[i]+"' AND"
		EndIf
	Next i                                    
	cQry := SUBSTR(cQry, 1, Len(cQry)-3)//Retira o ultimo AND inserido.
	cQry +=")"
EndIf

cQry += " AND D2.D2_FILIAL='"+cFil+"'"
cQry += " ORDER BY D2.D2_EMISSAO,D2.D2_DOC,D2.D2_SERIE,D2.D2_COD,D2.D2_CLIENTE

DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAliasQry,.F.,.T.)

For j := 1 To Len(aStru)
	If aStru[j][2] <> "C" .and.  FieldPos(aStru[j][1]) > 0
		TcSetField(cAliasQry,aStru[j][1],aStru[j][2],aStru[j][3],aStru[j][4])
	EndIf
Next j

Return .T.
*----------------------------*
Static Function K2Qry2()
*----------------------------*
Local j 
Local cQry      := ""
Local cAliasQry := "QRY2"

aStru:= SD1->(DbStruct())

cQry := "SELECT D1.*"
cQry += " FROM "+RetSqlName("SD1")+" D1"
cQry += " WHERE D1.D_E_L_E_T_ <> '*'"

If !Empty(cDtIni)
	cQry+=" AND D1.D1_EMISSAO>='"+cDtIni +"'"
EndIf
If !Empty(cDtFim)
	cQry+=" AND D1.D1_EMISSAO<='"+cDtFim +"'"
EndIf
cQry += " AND D1.D1_TIPO='D'"//DEVOLUCAO
cQry += " AND D1.D1_FILIAL='"+cFil+"'"
cQry += " ORDER BY D1.D1_EMISSAO,D1.D1_DOC,D1.D1_SERIE,D1.D1_COD,D1.D1_FORNECE

DbUseArea(.T.,"TOPCONN",TCGENQry(,,ChangeQuery(cQry)),cAliasQry,.F.,.T.)

For j := 1 To Len(aStru)
	If aStru[j][2] <> "C" .and.  FieldPos(aStru[j][1]) > 0
		TcSetField(cAliasQry,aStru[j][1],aStru[j][2],aStru[j][3],aStru[j][4])
	EndIf
Next j

Return .T.

*-----------------------------*
Static Function GrvWork()
*-----------------------------*
SC5->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))

(cQRY1)->(DbGoTop())
Do While (cQRY1)->(!Eof())  
	(cAliasWork)->(RecLock(cAliasWork,.T.))
	If SB1->(DbSeek(XFilial()+(cQRY1)->D2_COD))
		(cAliasWork)->B1_DESC  := SB1->B1_DESC 
		(cAliasWork)->B1_GRUPO := SB1->B1_GRUPO
	EndIf     
	(cAliasWork)->D2_CLIENTE := (cQRY1)->D2_CLIENTE
	(cAliasWork)->D2_DOC     := (cQRY1)->D2_DOC
	(cAliasWork)->D2_EMISSAO := (cQRY1)->D2_EMISSAO
	If SC5->(FieldPos("C5_P_PROJ")) > 0 .and. SC5->(DbSeek(xFilial()+(cQRY1)->D2_PEDIDO))
		(cAliasWork)->C5_P_PROJ := SC5->C5_P_PROJ
	EndIf
	(cAliasWork)->D2_COD     := (cQRY1)->D2_COD
	If (cQRY1)->D2_TES $ GetMV("MV_P_TES",,"56V/5BL")
		(cAliasWork)->D2_TES     := "Servico"
	Else
		(cAliasWork)->D2_TES     := "Revenda"
	EndIf
	(cAliasWork)->D2_TOTAL   := (cQRY1)->D2_TOTAL
	(cAliasWork)->D2_VALICM  := (cQRY1)->D2_VALICM 
	(cAliasWork)->D2_VALIPI  := (cQRY1)->D2_VALIPI
	(cAliasWork)->D2_VALIMP5 := (cQRY1)->D2_VALIMP5
	(cAliasWork)->D2_VALIMP6 := (cQRY1)->D2_VALIMP6 
	(cAliasWork)->D2_VALISS  := (cQRY1)->D2_VALISS 
	(cAliasWork)->FATLIQUI   := (cAliasWork)->(D2_TOTAL-D2_VALICM-D2_VALIPI-D2_VALIMP5-D2_VALIMP6-D2_VALISS)
	If SB2->(DbSeek(XFilial()+(cQRY1)->D2_COD+(cQRY1)->D2_LOCAL))
		(cAliasWork)->CUSTOPROD  := (cQRY1)->D2_QUANT*SB2->B2_CM1   
		If (cAliasWork)->CUSTOPROD == 0
			(cAliasWork)->CUSTOPROD  := (cQRY1)->D2_QUANT*SD2->D2_CUSTO1  
		EndIf		
	EndIf     
	(cAliasWork)->(MsUnLock())    
	(cQRY1)->(DbSkip())       
EndDo     

(cQRY2)->(DbGoTop())
Do While (cQRY2)->(!Eof())  
	(cAliasWork)->(RecLock(cAliasWork,.T.))
	If SB1->(DbSeek(XFilial()+(cQRY2)->D1_COD))
		(cAliasWork)->B1_DESC  := SB1->B1_DESC 
		(cAliasWork)->B1_GRUPO := SB1->B1_GRUPO
	EndIf     
	(cAliasWork)->D2_CLIENTE := (cQRY2)->D1_FORNECE
	(cAliasWork)->D2_DOC     := (cQRY2)->D1_DOC
	(cAliasWork)->D2_EMISSAO := (cQRY2)->D1_EMISSAO
	If SC5->(FieldPos("C5_P_PROJ")) > 0 .and. SC5->(DbSeek(xFilial()+(cQRY2)->D1_PEDIDO))
		(cAliasWork)->C5_P_PROJ := SC5->C5_P_PROJ
	EndIf
	(cAliasWork)->D2_COD     := (cQRY2)->D1_COD
	(cAliasWork)->D2_TES     := "Devolucao"
	(cAliasWork)->D2_TOTAL   := (cQRY2)->D1_TOTAL   *(-1)
	(cAliasWork)->D2_VALICM  := (cQRY2)->D1_VALICM  *(-1)
	(cAliasWork)->D2_VALIPI  := (cQRY2)->D1_VALIPI  *(-1)
	(cAliasWork)->D2_VALIMP5 := (cQRY2)->D1_VALIMP5 *(-1)
	(cAliasWork)->D2_VALIMP6 := (cQRY2)->D1_VALIMP6 *(-1)
	(cAliasWork)->D2_VALISS  := (cQRY2)->D1_VALISS  *(-1)
	(cAliasWork)->FATLIQUI   := (cQRY2)->(D1_TOTAL-D1_VALICM-D1_VALIPI-D1_VALIMP5-D1_VALIMP6-D1_VALISS) *(-1)
	If SB2->(DbSeek(XFilial()+(cQRY2)->D1_COD))
		(cAliasWork)->CUSTOPROD  := (cQRY2)->D1_QUANT*SB2->B2_CM1 *(-1)
	EndIf     
	(cAliasWork)->(MsUnLock())    
	(cQRY2)->(DbSkip())       
EndDo           

Return .T.

*------------------------------------*
Static Function K2SX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
	EndCase
EndIf
RestOrd(aOrd)
Return xRet

****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"DET"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("K2CUSTO", cTitRpt ,""         , {|oReport| ReportPrint(oReport)}, cTitRpt)

//Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait  := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"D2_CLIENTE", "DET", "Cod. Cli/Forn.", /*Picture*/               , K2SX3("D2_CLIENTE", "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_DOC"    , "DET", "Nº Nota"       , /*Picture*/               , K2SX3("D2_DOC"    , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_EMISSAO", "DET", "Dt. emissão"   , /*Picture*/               , K2SX3("D2_EMISSAO", "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"C5_P_PROJ" , "DET", "Projeto"       , /*Picture*/               , K2SX3("C5_P_PROJ" , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_COD"    , "DET", "Cod. Produto"  , /*Picture*/               , K2SX3("D2_COD"    , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"B1_DESC"   , "DET", "Desc. Produto" , /*Picture*/               , 30                            , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_TES"    , "DET", "Equip./Serv."  , /*Picture*/               , 9                             , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_TOTAL"  , "DET", "Val.Faturado"  , K2SX3("D2_TOTAL"  , "PIC"), K2SX3("D2_TOTAL"  , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"B1_GRUPO"  , "DET", "Familia"       , /*Picture*/               , K2SX3("B1_GRUPO"  , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_VALICM" , "DET", "Val. ICMS"     , K2SX3("D2_VALICM" , "PIC"), K2SX3("D2_VALICM" , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_VALIPI" , "DET", "Val. IPI"      , K2SX3("D2_VALIPI" , "PIC"), K2SX3("D2_VALIPI" , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_VALIMP5", "DET", "Val. PIS"      , K2SX3("D2_VALIMP5", "PIC"), K2SX3("D2_VALIMP5", "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_VALIMP6", "DET", "Val COFINS"    , K2SX3("D2_VALIMP6", "PIC"), K2SX3("D2_VALIMP6", "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"D2_VALISS" , "DET", "Val ISS"       , K2SX3("D2_VALISS" , "PIC"), K2SX3("D2_VALISS" , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FATLIQUI"  , "DET", "Val Liq."      , K2SX3("D2_TOTAL"  , "PIC"), K2SX3("FATLIQUI"  , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CUSTOPROD" , "DET", "Custo Prod."   , K2SX3("D2_TOTAL"  , "PIC"), K2SX3("CUSTOPROD" , "TAM")    , /*lPixel*/, /*{|| code-block de impressao }*/)

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Total:")
oTotal:= TRFunction():New(oSecao1:Cell("D2_TOTAL")  ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_TOTAL"  , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("D2_VALICM") ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_VALICM" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("D2_VALIPI") ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_VALIPI" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("D2_VALIMP5"),NIL,"SUM",/*oBreak*/,"",K2SX3("D2_VALIMP5", "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("D2_VALIMP6"),NIL,"SUM",/*oBreak*/,"",K2SX3("D2_VALIMP6", "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("D2_VALISS") ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_VALISS" , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("FATLIQUI")  ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_TOTAL"  , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:= TRFunction():New(oSecao1:Cell("CUSTOPROD") ,NIL,"SUM",/*oBreak*/,"",K2SX3("D2_TOTAL"  , "PIC"),/*{|| code-block de impressao }*/,.T.,.F.)
oTotal:SetTotalInLine(.F.)


Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Seção 1")

oReport:SetMeter(DET->(RecCount()))
DET->(dbGoTop())
  
//Inicio da impressão da seção 1.
oReport:Section("Seção 1"):Init()

//Laço principal
Do While DET->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Seção 1"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   DET->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Seção 1"):Finish()

GeraXLS()//exporta para excel.

Return .T.

*-----------------------*
Static Function GeraXLS()
*-----------------------*
If !lGeraXLS
	Return .T.
EndIf

AppendTot()//Appendar totalizadores para exibição no excel.

DbSelectArea(cAliasWork)                   
DbCloseArea()

cArqOrig  := "\SYSTEM\"+cNome+".DBF"
cPath     := AllTrim(GetTempPath())                                                   
CpyS2T(cArqOrig, cPath, .T.)
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
	oExcelApp:SetVisible(.T.)   
Else 
	Alert("Excel não instalado") 
EndIf

Erase &cNome+".DBF"

Return .T.
                                                           
*-------------------------*
Static Function AppendTot()              
*-------------------------*
Local nTOTAL    :=0
Local nVALICM   :=0
Local nVALIPI   :=0
Local nVALIMP5  :=0
Local nVALIMP6  :=0
Local nVALISS   :=0
Local nFATLIQUI :=0
Local nCUSTOPROD:=0

(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	nTOTAL    += (cAliasWork)->D2_TOTAL 
	nVALICM   += (cAliasWork)->D2_VALICM 
	nVALIPI   += (cAliasWork)->D2_VALIPI
	nVALIMP5  += (cAliasWork)->D2_VALIMP5
	nVALIMP6  += (cAliasWork)->D2_VALIMP6
	nVALISS   += (cAliasWork)->D2_VALISS
	nFATLIQUI += (cAliasWork)->FATLIQUI 
	nCUSTOPROD+= (cAliasWork)->CUSTOPROD
	(cAliasWork)->(DbSkip())
EndDo

(cAliasWork)->(DbAppend());(cAliasWork)->(MsUnLock())//gera 1 registro em branco. estetico.
(cAliasWork)->(DbAppend())

(cAliasWork)->D2_CLIENTE := "TOTAIS"
(cAliasWork)->D2_TOTAL   := nTOTAL
(cAliasWork)->D2_VALICM  := nVALICM 
(cAliasWork)->D2_VALIPI  := nVALIPI
(cAliasWork)->D2_VALIMP5 := nVALIMP5
(cAliasWork)->D2_VALIMP6 := nVALIMP6 
(cAliasWork)->D2_VALISS  := nVALISS 
(cAliasWork)->FATLIQUI   := nFATLIQUI
(cAliasWork)->CUSTOPROD  := nCUSTOPROD

(cAliasWork)->(MsUnLock())
Return .T.