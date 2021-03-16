#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : 49CTB004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório Brazil Upload Template (Portal do SQL Reposts)
Autor       : Renato Rezende 
Cliente		: Discovery
Data/Hora   : 02/02/2017
*/                          
*-------------------------*
 User Function 49CTB004()
*-------------------------*
Private titulo		:= "Relatório Brazil Upload Template - Discovery"
Private cPerg		:= ""
Private cDest		:= ""
Private cArq		:= "Upload_Template_"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"
Private cQuery		:= ""
Private nBytesSalvo	:= 0 
Private nRecCount	:= 0

//Verificando se está na empresa Discovery
If !(cEmpAnt) $ "49"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "49CTB4"
//Criando Pergunte
CriaPerg()
//Chamando Pergunte
If !Pergunte(cPerg,.T.)
	Return  
EndIf

//Destino do temporário da máquina
cDest	:=  GetTempPath()

If FILE (cDest+cArq)
	FERASE (cDest+cArq)
EndIf

//Chamada da Query
GeraTMP()

Return

/*
Funcao      : GeraTMP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Query gerada para relatório
Autor     	: Renato Rezende  	 	
Data     	: 23/01/2017
*/
*------------------------------*
 Static Function GeraTMP()
*------------------------------*
Local cQuery	:= ""
Local cDtInicial:= DtoS(mv_par01)
Local cDtFinal	:= DtoS(mv_par02)

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf

//Início do Select
cQuery:= ""
cQuery+= "SELECT " + CRLF
cQuery+= "	T1.CONTA, " + CRLF
cQuery+= "	RTRIM(CT1_GRUPO) AS [SAP], " + CRLF
cQuery+= "	T1.HISTORICO AS [DESCR], " + CRLF
cQuery+= "	T1.COMPANY AS [COMPANY]," + CRLF
cQuery+= "	T1.CENTRO [CC], " + CRLF
cQuery+= "                PRJ," + CRLF
cQuery+= "	CASE WHEN T1.TIPO='D' THEN '40' ELSE '50' END AS [DC], " + CRLF
cQuery+= "	CASE WHEN T1.TIPO='D' THEN T1.VALOR ELSE 0 END AS [DEBIT]," + CRLF
cQuery+= "	CASE WHEN T1.TIPO='C' THEN T1.VALOR ELSE 0 END AS [CREDIT]," + CRLF
cQuery+= "	T1.PROJETO," + CRLF
cQuery+= "	T1.BRAND," + CRLF
cQuery+= "	T1.PLATFORM," + CRLF
cQuery+= "	T1.GEOGRAPHY " + CRLF
cQuery+= "FROM " + CRLF
cQuery+= "	( " + CRLF
cQuery+= "		SELECT  " + CRLF
cQuery+= "			CT2_DEBITO AS [CONTA], " + CRLF
cQuery+= "			CT2_P_CODE AS [COMPANY], " + CRLF
cQuery+= "			CT2_CCD AS [CENTRO]," + CRLF 
cQuery+= "          CT2_P_KEY AS [PRJ]," + CRLF
cQuery+= "			CT2_VALOR AS [VALOR], " + CRLF
cQuery+= "			CT2_HIST AS [HISTORICO], " + CRLF
cQuery+= "			'D' AS [TIPO]," + CRLF
cQuery+= "			CT2_P_PROJ AS [PROJETO]," + CRLF
cQuery+= "			CT2_ITEMD AS [BRAND]," + CRLF
cQuery+= "			CT2_CLVLDB AS [PLATFORM]," + CRLF
cQuery+= "			CT2_P_GEOG AS [GEOGRAPHY] " + CRLF
cQuery+= "		FROM  " + CRLF
cQuery+= "			"+RetSqlName("CT2") + CRLF
cQuery+= "		WHERE  " + CRLF
cQuery+= "			D_E_L_E_T_<>'*' AND  " + CRLF
cQuery+= "			CT2_DATA>='"+cDtInicial+"' AND " + CRLF
cQuery+= "			CT2_DATA<='"+cDtFinal+"' AND " + CRLF
cQuery+= "			CT2_FILIAL='01' AND  " + CRLF
cQuery+= "			CT2_MOEDLC='04' " + CRLF
cQuery+= "" + CRLF
cQuery+= "		UNION ALL " + CRLF
cQuery+= "" + CRLF
cQuery+= "		SELECT " + CRLF 
cQuery+= "			CT2_CREDIT AS [CONTA], " + CRLF
cQuery+= "			CT2_P_CODE AS [COMPANY], " + CRLF
cQuery+= "			CT2_CCC AS [CENTRO], " + CRLF
cQuery+= "          CT2_P_KEY AS [PRJ]," + CRLF
cQuery+= "			CT2_VALOR AS [VALOR], " + CRLF
cQuery+= "			CT2_HIST AS [HISTORICO], " + CRLF
cQuery+= "			'C' AS [TIPO]," + CRLF
cQuery+= "			CT2_P_PROJ AS [PROJETO], " + CRLF
cQuery+= "			CT2_ITEMC AS [BRAND]," + CRLF
cQuery+= "			CT2_CLVLCR AS [PLATFORM]," + CRLF
cQuery+= "			CT2_P_GEOG AS [GEOGRAPHY] " + CRLF
cQuery+= "		FROM  " + CRLF
cQuery+= "			"+RetSqlName("CT2") + CRLF
cQuery+= "		WHERE  " + CRLF
cQuery+= "			D_E_L_E_T_<>'*' AND  " + CRLF
cQuery+= "			CT2_DATA>='"+cDtInicial+"' AND " + CRLF
cQuery+= "			CT2_DATA<='"+cDtFinal+"' AND " + CRLF
cQuery+= "			CT2_FILIAL='01' AND  " + CRLF
cQuery+= "			CT2_MOEDLC='04' " + CRLF
cQuery+= "	) AS T1 " + CRLF
cQuery+= "LEFT OUTER JOIN " + CRLF
cQuery+= "	"+RetSqlName("CT1") + CRLF
cQuery+= "ON " + CRLF
cQuery+= "	CT1_CONTA=T1.CONTA " + CRLF
cQuery+= "WHERE " + CRLF
cQuery+= "	D_E_L_E_T_<>'*' " + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) 

count to nRecCount

If nRecCount > 0 
	Processa({|| GeraHtm()},titulo)
Else
	If Select('TMP')>0               	
		TMP->(DbCloseArea())
	EndIf
	MsgInfo("Não há dados para a data selecionada!","HLB BRASIL")
EndIf

/*
Funcao      : GeraHtm
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 23/01/2017
*/
*------------------------------*
 Static Function GeraHtm()
*------------------------------*
Local cHtml		:= ""
Local nLin		:= 0

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

cHtml+= '<?xml version="1.0" encoding="ISO-8859-1"?>'+ CRLF
cHtml+= '<?mso-application progid="Excel.Sheet"?>'+ CRLF
cHtml+= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'+ CRLF

cHtml+= ' <Styles>'+ CRLF
cHtml+= '  <Style ss:ID="Default" ss:Name="Normal">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat/>'+ CRLF
cHtml+= '   <Protection/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s21">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Center" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s22">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s23">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s24">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s25">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]General"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s26">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Right" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]#,##0.00;\-#,##0.00"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s27">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s28">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s29">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s30">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]#,##0.00;\-#,##0.00"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= ' </Styles>'+ CRLF

cHtml+= ' <Worksheet ss:Name="Upload Template">'+ CRLF
cHtml+= '  <Table ss:ExpandedColumnCount="15" ss:ExpandedRowCount="99999999" x:FullColumns="1" x:FullRows="1">'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="81"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="72"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="45"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="63"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="72" ss:Span="1"/>'+ CRLF
cHtml+= '   <Column ss:Index="7" ss:AutoFitWidth="0" ss:Width="54"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="36"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="27"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="54"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="81"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="270"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="63" ss:Span="1"/>'+ CRLF
cHtml+= '   <Column ss:Index="15" ss:AutoFitWidth="0" ss:Width="0.75"/>'+ CRLF
cHtml+= '   <Row ss:AutoFitHeight="0" ss:Height="27">'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="8" ss:StyleID="s21"><Data ss:Type="String">DISCOVERY COMUNICAÇÕES UPLOAD - '+Alltrim(DtoC(mv_par01))+' A '+Alltrim(DtoC(mv_par02))+'</Data><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF
cHtml+= '   <Row>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">PRYOR ACCOUNT</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">SAP ACCOUNT</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">BRAND</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">COMPANY</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">COST CENTER</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">REPORT KEY</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">PROJECT</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">D/C</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s22"><Data ss:Type="String">DEBIT</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">CREDIT</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">DESCRIPTION</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">GEOGRAPHY</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">PLATFORM</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"/>'+ CRLF
cHtml+= '   </Row>'+ CRLF

TMP->(DbGoTop())

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()

	cHtml+= '   <Row>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->CONTA)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->SAP)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->BRAND)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->COMPANY)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->CC)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->PRJ)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s25"><Data ss:Type="Number">'+ALLTRIM(cValToChar(TMP->PROJETO))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->DC)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s26"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->DEBIT),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s26"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->CREDIT),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="String">'+Alltrim(TMP->DESCR)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->GEOGRAPHY)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->PLATFORM)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s23"/>'+ CRLF
	cHtml+= '   </Row>'+ CRLF
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
	
	nLin+=1

	TMP->(DbSkip())
EndDo

//TOTAIS
cHtml+= '   <Row>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s29"><Data ss:Type="String">TOTAL:</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s30" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s28"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"/>'+ CRLF
cHtml+= '   </Row>'+ CRLF
//FINAL DO TOTAIS
cHtml+= '  </Table>'+ CRLF
cHtml+= '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+ CRLF
cHtml+= '   <PageSetup>'+ CRLF
cHtml+= '    <Header x:Margin="1"/>'+ CRLF
cHtml+= '    <Footer x:Margin="1"/>'+ CRLF
cHtml+= '    <PageMargins x:Left="1" x:Right="1"/>'+ CRLF
cHtml+= '   </PageSetup>'+ CRLF
cHtml+= '   <NoSummaryRowsBelowDetail/>'+ CRLF
cHtml+= '   <NoSummaryColumnsRightDetail/>'+ CRLF
cHtml+= '   <Print>'+ CRLF
cHtml+= '    <ValidPrinterInfo/>'+ CRLF
cHtml+= '    <VerticalResolution>0</VerticalResolution>'+ CRLF
cHtml+= '   </Print>'+ CRLF
cHtml+= '   <Selected/>'+ CRLF
cHtml+= '   <DoNotDisplayGridlines/>'+ CRLF
cHtml+= '   <FreezePanes/>'+ CRLF
cHtml+= '   <SplitHorizontal>1</SplitHorizontal>'+ CRLF
cHtml+= '   <TopRowBottomPane>1</TopRowBottomPane>'+ CRLF
cHtml+= '   <ActivePane>2</ActivePane>'+ CRLF
cHtml+= '   <Panes>'+ CRLF
cHtml+= '    <Pane>'+ CRLF
cHtml+= '     <Number>3</Number>'+ CRLF
cHtml+= '    </Pane>'+ CRLF
cHtml+= '    <Pane>'+ CRLF
cHtml+= '     <Number>2</Number>'+ CRLF
cHtml+= '     <ActiveRow>0</ActiveRow>'+ CRLF
cHtml+= '    </Pane>'+ CRLF
cHtml+= '   </Panes>'+ CRLF
cHtml+= '   <ProtectObjects>False</ProtectObjects>'+ CRLF
cHtml+= '   <ProtectScenarios>False</ProtectScenarios>'+ CRLF
cHtml+= '  </WorksheetOptions>'+ CRLF
cHtml+= ' </Worksheet>'+ CRLF
cHtml+= '</Workbook>'+ CRLF

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel. 

GeraExcel()
 
Return cHtml 

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq,FO_READWRITE)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

/*
Funcao      : GeraExcel
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera o Excel com o Html gravado.
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
*/
*---------------------------------*
 Static Function GeraExcel()
*---------------------------------*

//Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel ou Html
EndIf
 
TMP->(DbSkip())

TMP->(DbCloseArea())

Return

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende  	 	
Data     	: 23/01/2017
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*
Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}

aHlpPor := {}
Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
Aadd( aHlpPor, "se deseja o relatório.") 

U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/17","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

aHlpPor := {}
Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
Aadd( aHlpPor, "se deseja o relatório.")

U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/17","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)



Return 
