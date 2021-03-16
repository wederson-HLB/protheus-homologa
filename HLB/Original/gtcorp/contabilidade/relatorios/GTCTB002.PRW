#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"  
#INCLUDE "topconn.ch"

/*
Funcao      : GTCTB002
Parametros  : 
Retorno     : 
Objetivos   : Relatorio Verba X Lançamentos.
Autor       : Jean Victor Rocha
Data/Hora   : 22/07/2013
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Contabil.
*/ 
*-------------------------*
USER FUNCTION GTCTB002()
*-------------------------*
Local nHdl
Local cXML 			:= ""
Private cDest 		:= GetTempPath()
Private cArq 		:= "VerbaXLanc.XML"
Private nBytesSalvo := 0 


//Gera arquivo fisico. 
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
nBytesSalvo := FWRITE(nHdl, cXML ) 		// Gravação do seu Conteudo.
fclose(nHdl) 							// Fecha o Arquivo que foi Gerado	
    
	//Processamento ---------------------------------------------------------
	//Busca os Dados, tabela temporaria.
	GetInfo()
	
	QRY->(DbGoTop())
	If QRY->(!EOF())
		//Monta em XML
		cXML := WriteXML()	
		
		//Abre o Excel
		GrvXML(cXML)	
	Else
		MsgAlert("Sem dados para exibição, verificar parametros!","Grant Thornton Brasil")
	EndIF
	
	//Fecha tabela Temporaria.
	If select("QRY")>0
		QRY->(DbCloseArea())
	Endif
	//---------------------------------------------------------
	
If nBytesSalvo >= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif


Return .T.

/*
Funcao      : GetInfo()
Parametros  : 
Retorno     : 
Objetivos   : Função que executara a query na busca dos dados a serem impressos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GetInfo()
*------------------------------*
Local cQry 		:= ""
                          
cQry := " Select	SRD.RD_PD, 
cQry += " 			SRV.RV_DESC, 
cQry += " 			SRV.RV_LCTOP, 
cQry += " 			isnull(CT5.CT5_DESC		,'') as CT5_DESC,
cQry += " 			isnull(CT5.CT5_DEBITO	,'') as CT5_DEBITO,
cQry += " 			isnull(CT5.CT5_CREDIT	,'') as CT5_CREDIT
cQry += " From "+RetSqlName("SRD")+" SRD 
cQry += " 		Left Outer Join (Select * From "+RetSqlName("SRV")+" Where D_E_L_E_T_ <> '*') as SRV on SRD.RD_PD	 = SRV.RV_COD
cQry += " 		Left Outer Join (Select * From "+RetSqlName("CT5")+" Where D_E_L_E_T_ <> '*') as CT5 on SRV.RV_LCTOP = CT5.CT5_LANPAD
cQry += " Where SRD.D_E_L_E_T_ <> '*'
cQry += " Group By SRD.RD_PD, SRV.RV_DESC, SRV.RV_LCTOP, CT5.CT5_DESC, CT5.CT5_DEBITO, CT5.CT5_CREDIT
cQry += " Union All
cQry += " 	Select	SRT.RT_VERBA as RD_PD,
cQry += "		 SRV.RV_DESC,
cQry += "		 SRV.RV_LCTOP,
cQry += "		 isnull(CT5.CT5_DESC		,'') as CT5_DESC,
cQry += "		 isnull(CT5.CT5_DEBITO	,'') as CT5_DEBITO,
cQry += "		 isnull(CT5.CT5_CREDIT	,'') as CT5_CREDIT 
cQry += "	 From "+RetSqlName("SRT")+" SRT  		
cQry += "		 Left Outer Join (Select * From "+RetSqlName("SRV")+" Where D_E_L_E_T_ <> '*') as SRV on SRT.RT_VERBA = SRV.RV_COD 		
cQry += "		 Left Outer Join (Select * From "+RetSqlName("CT5")+" Where D_E_L_E_T_ <> '*') as CT5 on SRV.RV_LCTOP = CT5.CT5_LANPAD 
cQry += "	 Where SRT.D_E_L_E_T_ <> '*' AND SRT.RT_VERBA <> ''
cQry += "	 Group By SRT.RT_VERBA, SRV.RV_DESC, SRV.RV_LCTOP, CT5.CT5_DESC, CT5.CT5_DEBITO, CT5.CT5_CREDIT
cQry += " Order By RD_PD

If select("QRY")>0
	QRY->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)

Return .T.              


/*                                                                   '
Funcao      : GrvXML()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GrvXML(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""


/*
Funcao      : WriteXML()
Parametros  : 
Retorno     : 
Objetivos   : Cria o Arquivo XMl para geração do Excel
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function WriteXML()
*------------------------*
Local cXML := ""      

cXML += ' <?xml version="1.0"?>
cXML += ' <?mso-application progid="Excel.Sheet"?>
cXML += ' <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXML += '  xmlns:o="urn:schemas-microsoft-com:office:office"
cXML += '  xmlns:x="urn:schemas-microsoft-com:office:excel"
cXML += '  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXML += '  xmlns:html="http://www.w3.org/TR/REC-html40">
cXML += '  <Styles>
cXML += '   <Style ss:ID="Default" ss:Name="Normal">
cXML += '    <Alignment ss:Vertical="Bottom"/>
cXML += '    <Borders/>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '    <Interior/>
cXML += '    <NumberFormat/>
cXML += '    <Protection/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s62">
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s63">
cXML += '    <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s65">
cXML += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s66">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s67">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s68">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s69">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s70">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s71">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s72">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s73">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s74">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s75">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s76">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s77">
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    </Borders>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '    <NumberFormat ss:Format="@"/>
cXML += '   </Style>
cXML += '  </Styles>
cXML += '  <Worksheet ss:Name="Verbas X Lanc.">
cXML += '   <Names>
cXML += '    <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Verbas X Lanc.!R4C1:R4C6" ss:Hidden="1"/>
cXML += '   </Names>
cXML += '   <Table ss:ExpandedColumnCount="6" ss:ExpandedRowCount="15000" x:FullColumns="1"
cXML += '    x:FullRows="1" ss:DefaultRowHeight="15">
cXML += '    <Column ss:AutoFitWidth="0" ss:Width="45"/>
cXML += '    <Column ss:AutoFitWidth="0" ss:Width="266.25"/>
cXML += '    <Column ss:AutoFitWidth="0" ss:Width="73.5"/>
cXML += '    <Column ss:AutoFitWidth="0" ss:Width="266.25"/>
cXML += '    <Column ss:AutoFitWidth="0" ss:Width="161.25" ss:Span="1"/>
cXML += '    <Row ss:AutoFitHeight="0">
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s63"><Data ss:Type="String">Grant Thornton Brasil.</Data></Cell>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:MergeAcross="5" ss:StyleID="s65"><Data ss:Type="String">Relat&oacute;rio de Verbas X Lancamentos Padr&otilde;es</Data></Cell>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:StyleID="s66"><Data ss:Type="String">Verba</Data>		<NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Desc. Verba</Data>	<NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Lanc. Padr&atilde;o</Data>	<NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Desc. Lanc.</Data>	<NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Conta D&eacute;bito</Data>	<NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s68"><Data ss:Type="String">Conta Cr&eacute;dito</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '    </Row>

QRY->(DbGoTop())
While QRY->(!EOF())    
	cXML += ' 	   <Row ss:AutoFitHeight="0">
	cXML += ' 	    <Cell ss:StyleID="s69"><Data ss:Type="String">'+QRY->RD_PD				+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+CharXml(QRY->RV_DESC)	+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+QRY->RV_LCTOP			+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+CharXml(QRY->CT5_DESC)	+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+CharXml(QRY->CT5_DEBITO)+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s71"><Data ss:Type="String">'+CharXml(QRY->CT5_CREDIT)+'</Data></Cell>
	cXML += ' 	   </Row>
	QRY->(DbSkip())
EndDo   

cXML += '   </Table>
cXML += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXML += '    <Unsynced/>
cXML += '    <Selected/>
cXML += '    <FreezePanes/>
cXML += '    <FrozenNoSplit/>
cXML += '    <SplitHorizontal>4</SplitHorizontal>
cXML += '    <TopRowBottomPane>4</TopRowBottomPane>
cXML += '    <SplitVertical>1</SplitVertical>
cXML += '    <LeftColumnRightPane>1</LeftColumnRightPane>
cXML += '    <ActivePane>0</ActivePane>
cXML += '    <Panes>
cXML += '     <Pane>
cXML += '      <Number>3</Number>
cXML += '     </Pane>
cXML += '     <Pane>
cXML += '      <Number>1</Number>
cXML += '     </Pane>
cXML += '     <Pane>
cXML += '      <Number>2</Number>
cXML += '     </Pane>
cXML += '     <Pane>
cXML += '      <Number>0</Number>
cXML += '      <ActiveRow>16</ActiveRow>
cXML += '     </Pane>
cXML += '    </Panes>
cXML += '    <ProtectObjects>False</ProtectObjects>
cXML += '    <ProtectScenarios>False</ProtectScenarios>
cXML += '   </WorksheetOptions>
cXML += '   <AutoFilter x:Range="R4C1:R4C6" xmlns="urn:schemas-microsoft-com:office:excel">
cXML += '   </AutoFilter>
cXML += '  </Worksheet>
cXML += ' </Workbook>

Return cXML     
       

/*
Funcao      : CharXml()
Parametros  : 
Retorno     : 
Objetivos   : Troca caracteres speciais por comandos XML.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function CharXml(cData)
*------------------------------*                         
Local aChar := {{"&","&amp;"},;//Executar primeiro a busca pelo &
				{'Á','&Aacute;'},{'á','&aacute;'},{'Â','&Acirc;'} ,{'â','&acirc;'} ,{'À','&Agrave;'},{'à','&agrave;'},;
				{'Å','&Aring;'} ,{'å','&aring;'} ,{'Ã','&Atilde;'},{'ã','&atilde;'},{'Ä','&Auml;'}  ,{'ä','&auml;'}  ,;
				{'Æ','&AElig;'} ,{'æ','&aelig;'} ,{'É','&Eacute;'},{'é','&eacute;'},{'Ê','&Ecirc;'} ,{'ê','&ecirc;'} ,;
				{'È','&Egrave;'},{'è','&egrave;'},{'Ë','&Euml;'}  ,{'ë','&euml;'}  ,{'Ð','&ETH;'}   ,{'ð','&eth;'}   ,;
				{'Í','&Iacute;'},{'í','&iacute;'},{'Î','&Icirc;'} ,{'î','&icirc;'} ,{'Ì','&Igrave;'},{'ì','&igrave;'},;
				{'Ï','&Iuml;'}  ,{'ï','&iuml;'}  ,{'Ó','&Oacute;'},{'ó','&oacute;'},{'Ô','&Ocirc;'} ,{'ô','&ocirc;'} ,;
				{'Ò','&Ograve;'},{'ò','&ograve;'},{'Ø','&Oslash;'},{'ø','&oslash;'},{'Õ','&Otilde;'},{'õ','&otilde;'},;
				{'Ö','&Ouml;'}  ,{'ö','&ouml;'}  ,{'Ú','&Uacute;'},{'ú','&uacute;'},{'Û','&Ucirc;'} ,{'û','&ucirc;'} ,;
				{'Ù','&Ugrave;'},{'ù','&ugrave;'},{'Ü','&Uuml;'}  ,{'ü','&uuml;'}  ,{'Ç','&Ccedil;'},{'ç','&ccedil;'},;
				{'Ñ','&Ntilde;'},{'ñ','&ntilde;'},{'Ý','&Yacute;'},{'ý','&yacute;'},{'"','&quot;'}  ,{'<','&lt;'}    ,;
				{'>','&gt;'}    ,{'®','&reg;'}   ,{'©','&copy;'}  ,{'Þ','&THORN;'} ,{'þ','&thorn;'} ,{'ß','&szlig;'}  ;
			   }

For i := 1 to len(aChar)
	cData := STRTRAN(cData,aChar[i][1],aChar[i][2])
Next i

Return ALLTRIM(cData)