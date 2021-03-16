#INCLUDE "FILEIO.CH"
#Include "TOTVS.ch"  
#Include "tbiconn.ch"
#Include "topconn.ch"

/*
Funcao      : TPFAT006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Receipt report Twitter.
Autor       : Renato Rezende
Data/Hora   : 28/08/2017
*/
*--------------------------*
 User Function TPFAT006()
*--------------------------*
Local cPerg := "TPFAT006"

Private cDest	:= GetTempPath()+"\"
Private cArq	:= "TPFAT006.XLS"

Private cVenctoDe := ""
Private cVenctoAte := ""

//Monta a pergunta
U_PUTSX1( cPerg, "01", "Vencimento De:" , "Vencimento De:" , "Of Due Date:" , "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Vencimento Ate:", "Vencimento Ate:", "To Due Date:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")

If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

If !EMPTY(MV_PAR01)
	cVenctoDe	:= DTOS(MV_PAR01)
EndIf

If !EMPTY(MV_PAR02)
	cVenctoAte := DTOS(MV_PAR02)
EndIf

Processa({|| MainGT() },"Processando aguarde...")

Return .T.

/*
Funcao      : MainGT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Principal
Autor       : Renato Rezende
Data/Hora   : 28/08/2017
*/
*-------------------------*
 Static Function MainGT()
*-------------------------*
Local cQuery := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery := " SELECT "  + CRLF
cQuery += " SE5.E5_NUMERO, "  + CRLF
cQuery += " SE5.E5_TIPO, "  + CRLF
cQuery += " SE5.E5_VALOR, "  + CRLF
cQuery += " CONVERT(VARCHAR,CAST(SE5.E5_DATA AS DATE),103) AS E5_DATA, "  + CRLF
cQuery += " SE1.E1_VALOR, "  + CRLF
cQuery += " SF2.F2_DOC, "  + CRLF
cQuery += " SF2.F2_P_NUM, "  + CRLF
cQuery += " SA1.A1_P_ID, "  + CRLF
cQuery += " SA1.A1_NOME, "  + CRLF
cQuery += " SC6.C6_P_NOME, "  + CRLF
cQuery += " SC6.C6_P_AGEN, "  + CRLF
cQuery += " CONVERT(VARCHAR,CAST(SF2.F2_EMISSAO AS DATE),103) AS F2_EMISSAO, "  + CRLF
cQuery += " SE4.E4_P_DESC, "  + CRLF
cQuery += " CONVERT(VARCHAR,CAST(SE1.E1_VENCTO AS DATE),103) AS E1_VENCTO, "  + CRLF
cQuery += "  DATEDIFF(day, CAST(SE1.E1_VENCTO AS DATE),GETDATE()) AS DIFDIA, "  + CRLF
cQuery += " '' AS AGINGBUCKET, "  + CRLF
cQuery += " 'BRL' AS MOEDA, "  + CRLF
cQuery += " SF2.F2_VALBRUT, "  + CRLF
cQuery += " SE5.E5_VALOR AS VLRRECEB, "  + CRLF
cQuery += " CASE SE1.E1_BAIXA WHEN '' THEN '' ELSE CONVERT(VARCHAR,CAST(SE5.E5_DATA AS DATE),103) END AS E1_BAIXA, "  + CRLF
cQuery += " SE1.E1_SALDO, "  + CRLF
cQuery += " SE1.E1_IDCNAB, "  + CRLF
cQuery += " SE1.E1_DESCONT, "  + CRLF
cQuery += " SE1.E1_NUMBCO, "  + CRLF
cQuery += " SE1.E1_CONTA, "  + CRLF
cQuery += " SC5.C5_P_PO "  + CRLF
cQuery += " FROM "+RETSQLNAME("SE1")+" SE1 "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2 ON SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.F2_FILIAL = SE1.E1_FILORIG AND SF2.F2_CLIENT = SE1.E1_CLIENTE AND SF2.D_E_L_E_T_='' "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA AND SA1.D_E_L_E_T_='' "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.D_E_L_E_T_='' AND SC5.C5_NUM = SE1.E1_PEDIDO AND SC5.C5_FILIAL = E1_FILORIG "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+" SC6 ON SC6.D_E_L_E_T_='' AND SC6.C6_NUM = SE1.E1_PEDIDO AND SC6.C6_FILIAL = E1_FILORIG AND C6_ITEM='01' "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SE4")+" SE4 ON SE4.E4_CODIGO = SF2.F2_COND AND SF2.F2_FILIAL = SE4.E4_FILIAL AND SE4.D_E_L_E_T_='' "  + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON SE5.E5_FILORIG+SE5.E5_PREFIXO+SE5.E5_NUMERO+SE5.E5_PARCELA+SE5.E5_TIPO = SE1.E1_FILORIG+SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO "  + CRLF
cQuery += "  LEFT JOIN "+RETSQLNAME("SE5")+" SE5_ES on SE5_ES.E5_FILORIG = SE5.E5_FILORIG "  + CRLF
cQuery += "                                         AND SE5_ES.E5_PREFIXO = SE5.E5_PREFIXO "  + CRLF
cQuery += "                                         AND SE5_ES.E5_NUMERO = SE5.E5_NUMERO "  + CRLF
cQuery += "                                         AND SE5_ES.E5_PARCELA = SE5.E5_PARCELA "  + CRLF
cQuery += "                                         AND SE5_ES.E5_TIPO = SE5.E5_TIPO "  + CRLF
cQuery += "                                         AND SE5_ES.E5_SEQ = SE5.E5_SEQ "  + CRLF
cQuery += "                                         AND SE5_ES.E5_TIPODOC = 'ES' "  + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_='' "  + CRLF
cQuery += "        AND SE1.E1_P_NUM<>'' "  + CRLF
cQuery += "        AND SE5_ES.E5_NUMERO is NULL "  + CRLF
cQuery += "        AND (SE1.E1_SALDO = 0 OR (SE1.E1_SALDO <> 0  AND SE1.E1_BAIXA <> '')) "  + CRLF
cQuery += "        AND SE5.D_E_L_E_T_ <> '*' "  + CRLF
cQuery += "        AND SE5.E5_RECPAG = 'R' "  + CRLF
cQuery += "        AND SE5.E5_TIPODOC = 'VL' "  + CRLF


If !EMPTY(cVenctoDe)
	cQuery += "		AND SE1.E1_BAIXA >= '"+cVenctoDe+"' "  + CRLF
EndIf
If !EMPTY(cVenctoAte)
	cQuery += "		AND SE1.E1_BAIXA <= '"+cVenctoAte+"' "  + CRLF
EndIf

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

ProcRegua(QRY->(RecCount()))

QRY->(DbGoTop())
If QRY->(!EOF())
	If NewFileXML()
		cXML := StartXML()+CHR(13)+CHR(10)
		cXML := GrvXML(cXML)

		While QRY->(!EOF())
	  		cXML += NewRow()+CHR(13)+CHR(10)

			If Len(cXML) >= 1000000//Proximo a 1Mega
		   		cXML := GrvXML(cXML)
			EndIf
			IncProc()
			QRY->(DbSkip())
	   	EndDo
		
		cXML += EndXML()
		cXML := GrvXML(cXML)

		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel
	EndIf

Else
	MsgInfo("Sem dados para serem impressos!","HLB BRASIL")
EndIf

Return .T.

/*
Funcao      : NewFileXML()
Parametros  : 
Retorno     : 
Objetivos   : Cria um novo arquivo
Autor       : Renato Rezende
Data/Hora   : 28/08/2017
*/
*-----------------------------*
 Static Function NewFileXML()
*-----------------------------*

If File(cDest+cArq)
	If FErase(cDest+cArq) <> 0
		MsgAlert("Erro ao tentar apagar arquivo antigo '"+ALLTRIM(cArq)+"', caso esteja aberto, favor fechar e executar novamente!","HLB BRASIL")
		Return .F.
	EndIf
EndIf

If (nHandle:=FCreate(cDest+cArq, 0)) == -1
	MsgAlert("Erro na criação do Arquivo!","HLB BRASIL")
	Return .F.
EndIf
FClose(nHandle)	

Return .T.

/*
Funcao      : GrvXML()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Renato Rezende
Data/Hora   : 
*/
*--------------------------*
Static Function GrvXML(cMsg)
*--------------------------*
Local nHdl		:= Fopen(cDest+cArq,FO_READWRITE) 

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

/*
Funcao      : StartXML()
Parametros  : 
Retorno     : 
Objetivos   : Gera o inicio do XML
Autor       : Renato Rezende
Data/Hora   : 
*/
*------------------------*
Static Function StartXML()
*------------------------*
Local cRet := ""

cRet += '<?xml version="1.0"?>
cRet += '<?mso-application progid="Excel.Sheet"?>
cRet += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cRet += ' xmlns:o="urn:schemas-microsoft-com:office:office"
cRet += ' xmlns:x="urn:schemas-microsoft-com:office:excel"
cRet += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cRet += ' xmlns:html="http://www.w3.org/TR/REC-html40">
cRet += ' <Styles>
cRet += '  <Style ss:ID="Default" ss:Name="Normal">
cRet += '   <Alignment ss:Vertical="Bottom"/>
cRet += '   <Borders/>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cRet += '   <Interior/>
cRet += '   <NumberFormat/>
cRet += '   <Protection/>
cRet += CHR(13)+CHR(10)
cRet += '  </Style>
cRet += '  <Style ss:ID="s174">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s175">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s176">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s177">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s178">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s179">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s180">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s181">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s182">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '   <NumberFormat ss:Format="Short Date"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s183">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s230">
cRet += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s237">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '   <NumberFormat ss:Format="@"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s238">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s239">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '   <NumberFormat ss:Format="@"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s240">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '   </Borders>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '   <NumberFormat ss:Format="Short Date"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s241">
cRet += '   <Borders>
cRet += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cRet += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cRet += '   </Borders>
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += '  <Style ss:ID="s242">
cRet += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cRet += '  </Style>
cRet += ' <Style ss:ID="s65">
cRet += '    <Alignment ss:Vertical="Top" ss:WrapText="1"/>
cRet += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"
cRet += '     ss:Bold="1"/>
cRet += '    <Interior ss:Color="#F2DCDB" ss:Pattern="Solid"/>
cRet += ' </Style>

cRet += ' </Styles>

cRet += CHR(13)+CHR(10)
cRet += ' <Worksheet ss:Name="Report">
cRet += '  <Names>
cRet += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Report!R3C1:R3C17" ss:Hidden="1"/>
cRet += '  </Names>
cRet += '  <Table ss:ExpandedColumnCount="21" ss:ExpandedRowCount="100000" x:FullColumns="1" x:FullRows="1" ss:StyleID="s242" ss:DefaultColumnWidth="46.5" ss:DefaultRowHeight="15">
cRet += '   <Column ss:StyleID="s242" ss:Width="72"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="77"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="86"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="140"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="87"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="96"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75">
cRet += '    <Cell ss:StyleID="s65"><Data ss:Type="String">From date: </Data></Cell>
cRet += '	 <Cell><Data ss:Type="String">'+DTOC(MV_PAR01)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s65"><Data ss:Type="String">To date: </Data></Cell>
cRet += '	 <Cell><Data ss:Type="String">'+DTOC(MV_PAR02)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s65"><Data ss:Type="String">User: '+alltrim(UsrRetName(__cUserId) )+'</Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75" ss:StyleID="s230">
cRet += '    <Cell><Data ss:Type="String"></Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:StyleID="s230">
cRet += '    <Cell ss:StyleID="s174"><Data ss:Type="String">GT_Invoice_Num	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">IO_Number     	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Code	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Name	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Advertiser_Name  </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Agency_Name    	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Invoice_Date  	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Payment_Term  	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Due_Date		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Past_Due_Days    </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Aging_Bucket	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Currency  		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Invoice_Amount	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Bank	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Amount	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Date	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s176"><Data ss:Type="String">Adjustment_Amount</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Adjustment_Date  </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">PO_Number		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Id Cnab 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Nosso Número	 </Data></Cell>
cRet += '   </Row>     


Return cRet

/*
Funcao      : NewRow()
Parametros  : 
Retorno     : 
Objetivos   : Gera Uma nova linha no arquivo XML
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------*
Static Function NewRow()
*----------------------*
Local cRet 		:= ""
Local cAgingBuc	:= ""

Do Case
	Case QRY->DIFDIA <= 0
		cAgingBuc:= "Current due"
	Case QRY->DIFDIA >=1 .AND. QRY->DIFDIA <= 30
		cAgingBuc:= "1-30 Days"
	Case QRY->DIFDIA >=31 .AND. QRY->DIFDIA <= 60
		cAgingBuc:= "31-60 Days"
	Case QRY->DIFDIA >=61 .AND. QRY->DIFDIA <= 90
		cAgingBuc:= "61-90 Days"
	Case QRY->DIFDIA >=91 .AND. QRY->DIFDIA <= 120
		cAgingBuc:= "91-120 Days"
	Case QRY->DIFDIA >=121 .AND. QRY->DIFDIA <= 150
		cAgingBuc:= "121-150 Days"
	Case QRY->DIFDIA >=151	
		cAgingBuc:= "Over 150 days"
EndCase

cRet += '   <Row>
cRet += '    <Cell ss:StyleID="s237"><Data ss:Type="String">'+ALLTRIM(QRY->F2_DOC		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->F2_P_NUM		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->A1_P_ID		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->A1_NOME		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_P_NOME	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_P_AGEN	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->F2_EMISSAO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E4_P_DESC	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_VENCTO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+cvaltochar(QRY->DIFDIA)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(cAgingBuc	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->MOEDA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->F2_VALBRUT,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_CONTA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->VLRRECEB,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_BAIXA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E1_DESCONT,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E5_DATA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_P_PO		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_IDCNAB	)+'</Data></Cell> 
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_NUMBCO	)+'</Data></Cell>
cRet += '   </Row>

Return cRet

/*
Funcao      : EndXML()
Parametros  : 
Retorno     : 
Objetivos   : Finaliza o Arquivo XML
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------*
Static Function EndXML() 
*----------------------*
Local cRet := ""

cRet += '  </Table>
cRet += CHR(13)+CHR(10)
cRet += '   <AutoFilter x:Range="R3C1:R3C17" xmlns="urn:schemas-microsoft-com:office:excel"> </AutoFilter>
cRet += CHR(13)+CHR(10)
cRet += '  </Worksheet>
cRet += CHR(13)+CHR(10)
cRet += ' </Workbook>

Return cRet
