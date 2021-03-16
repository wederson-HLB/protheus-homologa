//#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : TPFAT002
Parametros  : Nil
Retorno     : Nil
Objetivos   : Aging report Twitter.
Autor       : Matheus Massarotto           
Data/Hora   : 16/03/2015
*/
*----------------------*
User Function TPFAT002()
*----------------------*
Local cPerg := "TPFAT002"

Private cDest	:= GetTempPath()+"\"    
Private cArq	:= "TPFAT002.XLS"

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
Autor       : Matheus Massarotto
Data/Hora   : 17/03/2015
*/
*----------------------*
Static Function MainGT()
*----------------------*
Local cQuery := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
//RRP - 28/08/2017 - Inclusão de novas colunas Customer PO e Id Cnab
cQuery := " SELECT
cQuery += " F2_DOC,
cQuery += " F2_P_NUM,
cQuery += " A1_P_ID,
cQuery += " A1_NOME,
cQuery += " C6_P_NOME,
cQuery += " C6_P_AGEN,
cQuery += " CONVERT(VARCHAR,CAST(F2_EMISSAO AS DATE),103) AS F2_EMISSAO,
cQuery += " E4_P_DESC,
cQuery += " CONVERT(VARCHAR,CAST(E1_VENCTO AS DATE),103) AS E1_VENCTO,
cQuery += " DATEDIFF(day, CAST(E1_VENCTO AS DATE),GETDATE()) AS DIFDIA,
cQuery += " '' AS AGINGBUCKET,
cQuery += " 'BRL' AS MOEDA,
cQuery += " F2_VALBRUT,
cQuery += " E1_VALOR-E1_SALDO AS VLRRECEB,
cQuery += " CASE E1_BAIXA WHEN '' THEN '' ELSE CONVERT(VARCHAR,CAST(E1_BAIXA AS DATE),103) END AS E1_BAIXA,
cQuery += " E1_SALDO,
cQuery += " E1_P_OBS,
cQuery += " E1_IDCNAB,
cQuery += " E1_NUMBCO,
cQuery += " E1_TIPO,
cQuery += " C5_P_PO
cQuery += " FROM "+RETSQLNAME("SE1")+" SE1
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2 ON SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.F2_FILIAL = SE1.E1_FILORIG AND SF2.F2_CLIENT = SE1.E1_CLIENTE AND SF2.D_E_L_E_T_=''
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA AND SA1.D_E_L_E_T_=''
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.D_E_L_E_T_='' AND SC5.C5_NUM = SE1.E1_PEDIDO AND SC5.C5_FILIAL = E1_FILORIG
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+" SC6 ON SC6.D_E_L_E_T_='' AND SC6.C6_NUM = SE1.E1_PEDIDO AND SC6.C6_FILIAL = E1_FILORIG AND C6_ITEM='01' 
cQuery += " LEFT JOIN "+RETSQLNAME("SE4")+" SE4 ON SE4.E4_CODIGO = SF2.F2_COND AND SF2.F2_FILIAL = SE4.E4_FILIAL AND SE4.D_E_L_E_T_=''
cQuery += " WHERE SE1.D_E_L_E_T_='' AND E1_P_NUM<>''
cQuery += "   AND SE1.E1_SALDO <> 0 
//cQuery += " AND SE1.E1_VENCTO BETWEEN '20150201' AND '2015331'
cQuery += " AND SE1.E1_TIPO IN ('NF' , 'ND')

If !EMPTY(cVenctoDe)
	cQuery += "		AND SE1.E1_VENCTO >= '"+cVenctoDe+"'
EndIf
If !EMPTY(cVenctoAte)
	cQuery += "		AND SE1.E1_VENCTO <= '"+cVenctoAte+"'
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
Autor       : Matheus Massarotto
Data/Hora   : 17/03/2015
*/
*--------------------------*
Static Function NewFileXML()
*--------------------------*

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
Autor       : Matheus Massarotto
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
Autor       : Matheus Massarotto
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
//RRP - 28/08/2017 - Inclusão de novas colunas Customer PO e Id Cnab
cRet += '  <Table ss:ExpandedColumnCount="20" ss:ExpandedRowCount="100000" x:FullColumns="1" x:FullRows="1" ss:StyleID="s242" ss:DefaultColumnWidth="46.5" ss:DefaultRowHeight="15">
cRet += '   <Column ss:StyleID="s242" ss:Width="72"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="77"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="86"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="86"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="87"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="96"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="140"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="120"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="73"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="83"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="68"/>
//RRP - 28/08/2017 - Inclusão de novas colunas Customer PO e Id Cnab
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/> 
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
/*cRet += CHR(13)+CHR(10)
cRet += '   <Row>
cRet += '    <Cell><Data ss:Type="String">Empresa:</Data></Cell>
cRet += '    <Cell><Data ss:Type="String">'+ALLTRIM(FWEmpName(cEmpAnt))+'</Data></Cell>
cRet += '   </Row>
*/
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75">
cRet += '    <Cell ss:StyleID="s65"><Data ss:Type="String">As of date: </Data></Cell>
cRet += '	 <Cell><Data ss:Type="String">'+DTOC(Date())+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s65"><Data ss:Type="String">User: '+alltrim(UsrRetName(__cUserId) )+'</Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75" ss:StyleID="s230">
cRet += '    <Cell><Data ss:Type="String"></Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:StyleID="s230">
cRet += '    <Cell ss:StyleID="s174"><Data ss:Type="String">GT_Invoice_Num	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">IO_Number     	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Code	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Name	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Advertiser_Name </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Agency_Name    	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Invoice_Date  	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Payment_Term  	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Due_Date		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Past_Due_Days	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Aging_Bucket	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Currency 		</Data></Cell>
cRet += '    <Cell ss:StyleID="s176"><Data ss:Type="String">Invoice_Amount 	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Amount  </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Date  	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Remaining_Amount</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Comments 		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_PO		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Id Cnab 		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Nosso Número	</Data></Cell>
cRet += '   </Row>     


Return cRet

/*
Funcao      : NewRow()
Parametros  : 
Retorno     : 
Objetivos   : Gera Uma nova linha no arquivo XML
Autor       : Matheus Massarotto
Data/Hora   : 
*/
*----------------------*
Static Function NewRow()
*----------------------*
Local cRet 		:= ""
Local cValDif	:= QRY->DIFDIA
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
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->VLRRECEB,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_BAIXA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E1_SALDO,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_P_OBS		)+'</Data></Cell> 
//RRP - 28/08/2017 - Inclusão de novas colunas Customer PO e Id Cnab
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
Autor       : Matheus Massarotto
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
