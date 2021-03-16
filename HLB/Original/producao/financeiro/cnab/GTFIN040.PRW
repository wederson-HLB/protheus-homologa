#include "protheus.ch"
#include "topconn.ch"

#DEFINE ENTER CHR(13) + CHR(10)

*----------------------*
User Function GTFIN040()
*----------------------*
Local oReport

	Pergunte("GTFIN040",.T.)	
	oReport := ReportDef()
	oReport:SetParam("GTFIN040")	
	oReport:PrintDialog()	

Return

// definicção do corpo do relatório
*--------------------------*
Static Function ReportDef()
*--------------------------*
Local oReport
Local oSection1
//Local oSectionCab
Local oBreak

//New(cReport,cTitle,uParam,bAction,cDescription,lLandscape,uTotalText,lTotalInLine,cPageTText,lPageTInLine,lTPageBreak,nColSpace)
oReport   := TReport():New("GTFIN040","Relatorio Retorno Cnab","GTFIN040",{|oReport| PrintReport(oReport)},"Relatorio Retorno CNAB")
oReport:nFontBody   := 8
//oReport:cFontBody := 'Arial'
oReport:nLineHeight := 60
oReport:SetLandscape() 

//New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oSection1 := TRSection():New(oReport,"Relatorio Retorno Cnab",{"Z0F"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,/*uTotalText*/,/*lTotalInLine*/,/*lHeaderPage*/,/*lHeaderBreak*/,/*lPageBreak*/,/*lLineBreak*/,/*nLeftMargin*/,/*lLineStyle*/,/*nColSpace*/,/*lAutoSize*/,/*cCharSeparator*/,/*nLinesBefore*/,/*nCols*/,/*nClrBack*/,/*nClrFore*/,/*nPercentage*/)


//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection1 , "BANCO"     ,"", "Bco."           	     , /*Picture*/,         05, /*lPx*/,{||QRYCNAB->Z0F_BANCO })//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "AGECTA"    ,"", "Age/Cta"  	   		 , /*Picture*/,         20, /*lPx*/,{||QRYCNAB->(Z0F_AGE+"-"+Z0F_CTA)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "CONTA"  	 ,"", "Conta"   		     , /*Picture*/,         05, /*lPx*/,{||QRYCNAB->Z0F_CTA})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "TITULO" 	 ,"", "Nr. Titulo"   		 , /*Picture*/,         23, /*lPx*/,{||QRYCNAB->(Z0F_PREFIX+" "+Z0F_NUM+" "+Z0F_PARCEL)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "TITULO"    ,"", "Titulo"               , /*Picture*/,         10, /*lPx*/,{||QRYCNAB->Z0F_NUM})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "PARCELA"   ,"", "Parcela"        	     , /*Picture*/,         04, /*lPx*/,{||QRYCNAB->Z0F_PARCEL})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "TIPO"      ,"", "Tipo"  				 , /*PICTURE*/,         06, /*lPx*/,{||QRYCNAB->Z0F_TIPO})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "FORNCLI"   ,"", "Cod."      		     , /*Picture*/,         05, /*lPx*/,{||QRYCNAB->Z0F_FORCLI})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "FORNCLI"   ,"", "Cli/For"  	         , /*Picture*/,         35, /*lPx*/,{||QRYCNAB->(Z0F_FORCLI+"-"+Z0F_NOMFC)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "CGCCPF"    ,"", "CGC/CPF"              , /*PICTURE*/,         20, /*lPx*/,{||QRYCNAB->Z0F_CGCCPF})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "DTVENC"    ,"", "Vencimento"  	     , /*PICTURE*/,         14, /*lPx*/,{||SUBSTR(QRYCNAB->Z0F_DTVENC,7,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTVENC,5,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTVENC,3,2)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "DTBAIXA"   ,"", "Baixa"  				 , /*PICTURE*/,         14, /*lPx*/,{||SUBSTR(QRYCNAB->Z0F_DTBAIX,7,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTBAIX,5,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTBAIX,3,2)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "DTPROC"    ,"", "Processamento"        , /*PICTURE*/,         14, /*lPx*/,{||SUBSTR(QRYCNAB->Z0F_DTPROC,7,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTPROC,5,2)+"/"+SUBSTR(QRYCNAB->Z0F_DTPROC,3,2)})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "VALOR"     ,"", "Valor"                , "@E 999,999,999.99", 20, /*lPx*/,{||QRYCNAB->Z0F_VALOR})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "CODOCOR"   ,"", "Cod Ocor."           , /*Picture*/,         60, /*lPx*/,{||QRYCNAB->Z0F_OCORRE+"-"+QRYCNAB->Z0F_DESCOC})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1 , "OCORRE"    ,"", "Ocorrencia"           , /*Picture*/,         60, /*lPx*/,{||QRYCNAB->Z0F_DESCOC})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//TRCell():New(oSection1 , "IDCNAB"    ,"", "IDCNAB"               , /*Picture*/,         10, /*lPx*/,{||QRYCNAB->Z0F_IDCNAB})//,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)




//oBreak := TRBreak():New(oSection1,oSection1:Cell("PAIS_DESTINO"),"TOTAL")
//TRFunction():New(oSection1:Cell("VALOR_INCO")      , Nil, "SUM", oBreak,Nil,"@E 999,999,999.9999",Nil,.F.,.F.)

Return oReport

// executa impressão dos dados
*-----------------------------------*
Static Function PrintReport(oReport)
*-----------------------------------*
Local cFiltro  := ""

Local cFilialDe  := IF(EMPTY(MV_PAR02),' ',MV_PAR01), cFilialAt  := IF(EMPTY(MV_PAR02),'ZZ',MV_PAR02)
Local cBanco := MV_PAR03, cAgencia := MV_PAR04, cConta := MV_PAR05
Local cDataDe := IF(EMPTY(DTOS(MV_PAR06)),DTOS(DATE()),DTOS(MV_PAR06)), cDataAt := IF(EMPTY(DTOS(MV_PAR07)),DTOS(DATE()),DTOS(MV_PAR07))

Local oSection := oReport:Section(1)
Local cQry := ''

oSection:Init()

cQry += "SELECT"+ ENTER
cQry += " * "+ ENTER
cQry += "FROM " + RetSqlName('Z0F') + " Z0F"+ ENTER
cQry += "WHERE Z0F.D_E_L_E_T_ = '' "+ ENTER
cQry += "AND Z0F_FILIAL BETWEEN '"+cFilialDe+"' AND '"+cFilialAt+"' "+ ENTER
cQry += "AND Z0F_DTPROC BETWEEN '"+cDataDe+"' AND '"+cDataAt+"' "+ ENTER
IF !EMPTY(cBanco)
    cQry += "AND Z0F_BANCO = '"+cBanco+"' AND Z0F_AGE = '"+cAgencia+"' AND Z0F_CTA = '"+cConta+"' "+ ENTER
ENDIF
MemoWrit( "QRYCNAB.sql",cQry)

If Select("QRYCNAB") > 0 
   QRYCNAB->(DBCLOSEAREA())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYCNAB",.T.,.T.)

QRYCNAB->(dbGoTop())

While QRYCNAB->(!Eof()) .And. !oReport:Cancel()
    If oReport:Cancel()
        Exit
    EndIf
    oSection:PrintLine()	
    QRYCNAB->(DbSkip())
EndDo
QRYCNAB->( DBClosearea() )
oSection:Finish()

RETURN
