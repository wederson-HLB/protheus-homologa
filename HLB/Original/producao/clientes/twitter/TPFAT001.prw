#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : TPFAT001
Parametros  : Nil
Retorno     : Nil
Objetivos   : Relatorio especifico Twitter.
Autor       : Jean Victor Rocha
Data/Hora   : 27/01/2015
*/
*----------------------*
User Function TPFAT001()
*----------------------*
Local cPerg := "TPFAT001"

Private cDest	:= GetTempPath()+"\"
Private cArq	:= "TPFAT001.XLS"
                                    
Private cEmissaoDe := ""
Private cEmissaoAte := ""

//Monta a pergunta
U_PUTSX1( cPerg, "01", "Emissao De:" , "Emissao De:" , "Emissao De:" , "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Emissao Ate:", "Emissao Ate:", "Emissao Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")

If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

If !EMPTY(MV_PAR01)
	cEmissaoDe	:= DTOS(MV_PAR01)
EndIf

If !EMPTY(MV_PAR02)
	cEmissaoAte := DTOS(MV_PAR02)
EndIf

Processa({|| MainGT() },"Processando aguarde...")

Return .T.

/*
Funcao      : MainGT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Principal
Autor       : Jean Victor Rocha
Data/Hora   : 27/01/2015
*/
*----------------------*
Static Function MainGT()
*----------------------*
Local cQuery := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery := " Select 
cQuery += "		UPPER(LEFT(DATENAME(month,CONVERT(Datetime, SC5.C5_EMISSAO, 112)),3)+'-'+SUBSTRING(SC5.C5_EMISSAO,3,2)) as EMISSAO,
cQuery += "		SC5.C5_P_NUM,
cQuery += "		SC6.C6_P_REF,
cQuery += "		SC5.C5_NUM,
cQuery += "		Case when SD2.D2_DOC is NULL then '' else SD2.D2_DOC end as D2_DOC,
cQuery += "		Case when SD2.D2_SERIE is NULL then '' else SD2.D2_SERIE end as D2_SERIE,
cQuery += "		SA1.A1_P_ID,
cQuery += "		SA1.A1_NOME,
cQuery += "		SC6.C6_P_NOME,
cQuery += "		SC6.C6_PRODUTO,
cQuery += "		SC6.C6_DESCRI,
cQuery += "		SC6.C6_P_AGEN,
cQuery += "		SC5.C5_P_EMAIL+SC5.C5_P_EMAI1+SC5.C5_P_EMAI2+SC5.C5_P_EMAI3 as C5_P_EMAIL,
cQuery += "		SC5.C5_P_PO,
cQuery += "		Case when SD2.D2_EMISSAO is NULL then '' else convert(varchar, CONVERT(Datetime, SD2.D2_EMISSAO, 112), 103) end as D2_EMISSAO,
cQuery += "		Case when SE4.E4_P_DESC is NULL then SC5.C5_CONDPAG  else SE4.E4_P_DESC end as C5_CONDPAG,
cQuery += "		SC5.C5_P_MOED,
cQuery += "		Case when SD2.D2_TOTAL is NULL then '' else SD2.D2_TOTAL end as D2_TOTAL,
cQuery += "		Case when SE1.E1_VALOR is NULL then '' else (Case when SE1.E1_BAIXA = '' then '' else SE1.E1_VALOR end) end as E1_VALOR,
cQuery += "		Case when SE1.E1_BAIXA is NULL then '' else (
cQuery += "					Case when SE1.E1_BAIXA = '' then '' else convert(varchar, CONVERT(Datetime, SE1.E1_BAIXA, 112), 103) end)
cQuery += "			 end as E1_BAIXA,
cQuery += "		Case when SE1.E1_P_OBS is NULL then '' else SE1.E1_P_OBS end as E1_P_OBS,
cQuery += " 	E1_IDCNAB
cQuery += " From "+RETSQLNAME("SC5")+" SC5
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SC6")+" Where D_E_L_E_T_ <> '*') as SC6 on SC6.C6_NUM = SC5.C5_NUM 
cQuery += "																							AND SC6.C6_FILIAL = SC5.C5_FILIAL 
cQuery += "																							AND SC6.C6_CLI = SC5.C5_CLIENTE
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SD2")+" Where D_E_L_E_T_ <> '*') as SD2 on SD2.D2_PEDIDO = SC6.C6_NUM 
cQuery += "																							AND SC6.C6_FILIAL = SD2.D2_FILIAL 
cQuery += "																							AND SC6.C6_PRODUTO = SD2.D2_COD 
cQuery += "																							AND SC6.C6_ITEM = SD2.D2_ITEMPV
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SA1")+" Where D_E_L_E_T_ <> '*') as SA1 on SC5.C5_CLIENTE = SA1.A1_COD
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SE1")+" Where D_E_L_E_T_ <> '*') as SE1 on SE1.E1_PREFIXO = SD2.D2_SERIE 
cQuery += "																							AND SE1.E1_NUM = SD2.D2_DOC 
cQuery += "																							AND SE1.E1_CLIENTE = SD2.D2_CLIENTE
cQuery += "		Left Outer Join (Select * From "+RETSQLNAME("SE4")+" Where D_E_L_E_T_ <> '*') as SE4 on SC5.C5_CONDPAG = SE4.E4_CODIGO
cQuery += " Where SC5.D_E_L_E_T_ <> '*'
cQuery += "		AND SC5.C5_EMISSAO <> ''
cQuery += "		AND SC5.C5_P_NUM <> ''
If !EMPTY(cEmissaoDe)
	cQuery += "		AND SC5.C5_EMISSAO >= '"+cEmissaoDe+"'
EndIf
If !EMPTY(cEmissaoAte)
	cQuery += "		AND SC5.C5_EMISSAO <= '"+cEmissaoAte+"'
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
Autor       : Jean Victor Rocha
Data/Hora   : 
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
Autor       : Jean Victor Rocha
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
Autor       : Jean Victor Rocha
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
cRet += ' </Styles>
cRet += CHR(13)+CHR(10)
cRet += ' <Worksheet ss:Name="Report">
cRet += '  <Names>
cRet += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Report!R4C1:R4C22" ss:Hidden="1"/>
cRet += '  </Names>
cRet += '  <Table ss:ExpandedColumnCount="22" ss:ExpandedRowCount="100000" x:FullColumns="1" x:FullRows="1" ss:StyleID="s242" ss:DefaultColumnWidth="46.5" ss:DefaultRowHeight="15">
cRet += '   <Column ss:StyleID="s242" ss:Width="72"/>
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
cRet += '   <Column ss:StyleID="s242" ss:Width="83"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="84"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="68"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="63"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="63"/>
cRet += CHR(13)+CHR(10)
cRet += '   <Row>
cRet += '    <Cell><Data ss:Type="String">Empresa:</Data></Cell>
cRet += '    <Cell><Data ss:Type="String">'+ALLTRIM(FWEmpName(cEmpAnt))+'</Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75">
cRet += '    <Cell><Data ss:Type="String">Extracao: </Data></Cell>
cRet += '	 <Cell><Data ss:Type="String">'+DTOC(Date())+'</Data></Cell>
cRet += '   </Row>
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:StyleID="s230">
cRet += '    <Cell ss:StyleID="s174"><Data ss:Type="String">Billing_Period		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">IO_Number	   		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Order Ref	   		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">IO_number_HLB		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">HLB_Invoice_Num		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">HLB_Invoice_serie	</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Number		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_Name		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Advertiser_Name		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Product				</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Product_name		</Data></Cell>
cRet += '    <Cell ss:StyleID="s176"><Data ss:Type="String">Agency_Name	   		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Billing_Email		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Customer_PO			</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Invoice_Date		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Payment_Term		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Currency	   		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Invoice_Amount		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Amount		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">Receipt_Date		</Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">ID_Cnab				</Data></Cell>
cRet += '    <Cell ss:StyleID="s177"><Data ss:Type="String">Comments	   		</Data></Cell>
cRet += '   </Row>     
cRet += CHR(13)+CHR(10)
cRet += '   <Row ss:Height="15.75" ss:StyleID="s230">
cRet += '    <Cell ss:StyleID="s178"><Data ss:Type="String">C5_EMISSAO		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">C5_P_NUM		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">C5_P_REF		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">C5_NUM	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">D2_DOC	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">D2_SERIE		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">A1_P_ID	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">A1_NOME	 		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">C5_P_NOME		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">C6_PRODUTO		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">C6_DESCRI		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s181"><Data ss:Type="String">C5_P_AGEN		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">C5_P_EMAIL		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">C5_P_PO			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">D2_EMISSAO		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s182"><Data ss:Type="String">C5_CONDPAG		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">C5_P_MOED		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">D2_TOTAL		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">E1_VALOR		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s179"><Data ss:Type="String">E1_BAIXA		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s180"><Data ss:Type="String">E1_IDCNAB		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '    <Cell ss:StyleID="s183"><Data ss:Type="String">E1_P_OBS		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cRet += '   </Row>

Return cRet

/*
Funcao      : NewRow()
Parametros  : 
Retorno     : 
Objetivos   : Gera Uma nova linha no arquivo XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
Static Function NewRow()
*----------------------*
Local cRet := ""

cRet += '   <Row>
cRet += '    <Cell ss:StyleID="s237"><Data ss:Type="String">'+ALLTRIM(QRY->EMISSAO		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_P_NUM		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->C6_P_REF		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_NUM		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->D2_DOC		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->D2_SERIE		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->A1_P_ID		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->A1_NOME		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_P_NOME	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_PRODUTO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_DESCRI	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C6_P_AGEN	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_P_EMAIL	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_P_PO		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->D2_EMISSAO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_CONDPAG	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->C5_P_MOED	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->D2_TOTAL,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E1_VALOR,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_BAIXA		)+'</Data></Cell>  
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_IDCNAB	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E1_P_OBS		)+'</Data></Cell>
cRet += '   </Row>

Return cRet

/*
Funcao      : EndXML()
Parametros  : 
Retorno     : 
Objetivos   : Finaliza o Arquivo XML
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------*
Static Function EndXML() 
*----------------------*
Local cRet := ""

cRet += '  </Table>
cRet += CHR(13)+CHR(10)
cRet += '   <AutoFilter x:Range="R4C1:R4C21" xmlns="urn:schemas-microsoft-com:office:excel"> </AutoFilter>
cRet += CHR(13)+CHR(10)
cRet += '  </Worksheet>
cRet += CHR(13)+CHR(10)
cRet += ' </Workbook>

Return cRet
