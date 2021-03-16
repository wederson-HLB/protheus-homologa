#Include "TOTVS.ch"  
#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : HHFIN007
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio Excel Modelo SE2.
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
*/
*--------------------------*
 User Function HHFIN007()
*--------------------------*
//Local cPerg := "HHFIN007"

Private cDest	:= ""
Private cArq	:= ""
Private cVenctoDe := ""
Private cVenctoAte := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Perguntas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()

If ( !Pergunte("HHFIN007",.T.) )
	Return .F.
EndIf    

cDest	:= Alltrim(MV_PAR03)
cArq	:= Alltrim( RetSQLName("SE2") )+"_PAGAR_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".XLS"	//"HHFIN007.XLS"

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
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
*/
*-------------------------*
 Static Function MainGT()
*-------------------------*
Local cQuery := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery 		:= "SELECT '"+cEmpAnt+"' as COD_EMP,SE2.E2_FILIAL,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_NATUREZ,SE2.E2_FORNECE, SE2.E2_LOJA  " + CRLF	                       
cQuery 		+= ",SA2.A2_CGC AS 'CNPJ_CPF',SE2.E2_NOMFOR,SA2.A2_NOME  AS 'RAZ_SOCIAL' " + CRLF   
cQuery 		+= ",CONVERT(VARCHAR,CAST(SE2.E2_EMIS1 AS DATE),103) AS DT_Contab " + CRLF      	
cQuery 		+= ",CONVERT(VARCHAR,CAST(SE2.E2_EMISSAO AS DATE),103) AS E2_EMISSAO " + CRLF      	
cQuery 		+= ",CONVERT(VARCHAR,CAST(SE2.E2_VENCREA AS DATE),103) AS E2_VENCREA " + CRLF 
cQuery 		+= ",CASE E2_BAIXA WHEN '' THEN '' ELSE CONVERT(VARCHAR,CAST(E2_BAIXA AS DATE),103) END AS E2_BAIXA " + CRLF      	
cQuery 		+= ",SE2.E2_NUMBCO,SE2.E2_BCOPAG " + CRLF   
cQuery 		+= ",SE2.E2_VALOR,SE2.E2_SALDO,SE2.E2_MULTA,SE2.E2_JUROS,SE2.E2_VALLIQ AS 'Vlr_Pago' " + CRLF	
cQuery 		+= ",SE2.E2_SALDO AS 'Vlr_aPagar' " + CRLF			
cQuery 		+= ",SE2.E2_NUMBOR,SE2.E2_FATURA,SE2.E2_P_IDPRO " + CRLF   	
//AOA - 06/12/2017 - Tratamento dos campos customizados no projeto de cobrança ID 42	
cQuery 		+= ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='58' AND X5_CHAVE=E2_P_MODEL) AS MODELO" + CRLF     	  		
cQuery 		+= ",(SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_TABELA='HH' AND X5_CHAVE=E2_P_FOPAG) AS PAGAMENTO" + CRLF     	  		

cQuery		+= ",SE2.E2_HIST " + CRLF   
cQuery		+= ",SE2.E2_PIS,SE2.E2_COFINS,SE2.E2_CSLL,SE2.E2_VRETPIS,SE2.E2_VRETCOF,SE2.E2_VRETCSL,SE2.E2_PRETPIS,SE2.E2_PRETCOF,SE2.E2_PRETCSL,SE2.E2_DESCONT " + CRLF  		
cQuery 		+= "FROM "+RetSQLName("SE2")+" SE2 " + " LEFT JOIN " +RetSQLName("SA2")+" SA2 ON " + CRLF
cQuery 		+= "SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_FILIAL = SA2.A2_FILIAL AND SE2.E2_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*' " + CRLF
cQuery 		+= "WHERE SE2.D_E_L_E_T_ <> '*' "  + CRLF
cQuery 		+= " AND SE2.E2_EMISSAO  BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CRLF

If MV_PAR04 = 1  	
	cQuery	+= " AND SE2.E2_SALDO > 0 " + CRLF         
ElseIf MV_PAR04 = 2
	cQuery	+= " AND SE2.E2_SALDO = 0 " + CRLF         		 	
EndIf     
cQuery	+= " ORDER BY SE2.E2_EMISSAO,SE2.E2_NUM "

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
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
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
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
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
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
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
cRet += '  <Table ss:ExpandedColumnCount="28" ss:ExpandedRowCount="100000" x:FullColumns="1" x:FullRows="1" ss:StyleID="s242" ss:DefaultColumnWidth="46.5" ss:DefaultRowHeight="15">
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="100"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="140"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="180"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="70"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="88"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/>
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/> 
cRet += '   <Column ss:StyleID="s242" ss:Width="90"/> 
cRet += '   <Column ss:StyleID="s242" ss:Width="140"/>
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
cRet += '    <Cell ss:StyleID="s174"><Data ss:Type="String">COD_EMP			 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_NUM	     	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_PARCELA		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_TIPO			 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_NATUREZ		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_FORNECE   	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">CNPJ_CPF	  	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_NOMFOR	  	 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">RAZ_SOCIAL		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">DT_CONTAB	     </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_EMISSAO		 </Data></Cell>   
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_VENCREA		 </Data></Cell>   
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_BAIXA		 </Data></Cell>  
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_NUMBCO		 </Data></Cell>  
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_BCOPAG		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_VALOR		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s176"><Data ss:Type="String">E2_SALDO		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_MULTA		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_JUROS		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">VLR_PAGO 		 </Data></Cell>  
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">PCC_aReter 		 </Data></Cell>  
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">VLR_APAGAR 		 </Data></Cell>  
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_NUMBOR 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_FATURA 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_P_IDPRO 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">MODELO	 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">PAGAMENTO 		 </Data></Cell>
cRet += '    <Cell ss:StyleID="s175"><Data ss:Type="String">E2_HIST 		 </Data></Cell>
cRet += '   </Row>     


Return cRet

/*
Funcao      : NewRow()
Parametros  : 
Retorno     : 
Objetivos   : Gera Uma nova linha no arquivo XML
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
*/
*----------------------*
Static Function NewRow()
*----------------------*
Local cRet 		:= ""
Local cAgingBuc	:= ""
Local nVlr_Pago := 0, nPCC_aReter := 0
/*
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
*/
cRet += '<Row>
cRet += '    <Cell ss:StyleID="s237"><Data ss:Type="String">'+ALLTRIM(QRY->COD_EMP		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_NUM		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->E2_PARCELA	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->E2_TIPO		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_NATUREZ	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_FORNECE	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->CNPJ_CPF		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_NOMFOR	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->RAZ_SOCIAL	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="String">'+ALLTRIM(QRY->DT_CONTAB	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_EMISSAO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_VENCREA	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_BAIXA		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_NUMBCO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_BCOPAG	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_VALOR,"@R 99999999999999999.99") )+'</Data></Cell> 
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_SALDO,"@R 99999999999999999.99") )+'</Data></Cell>      
cRet += '    <Cell ss:StyleID="s239"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_MULTA,"@R 99999999999999999.99") )+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_JUROS,"@R 99999999999999999.99") )+'</Data></Cell> 

cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->Vlr_Pago,"@R 99999999999999999.99") )+'</Data></Cell>  
    
IF QRY->E2_SALDO > 0  
	nPCC_aReter := ((QRY->E2_PIS-QRY->E2_VRETPIS) + (QRY->E2_COFINS-QRY->E2_VRETCOF) + (QRY->E2_CSLL-QRY->E2_VRETCSL))
	cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(nPCC_aReter,"@R 99999999999999999.99") )+'</Data></Cell>
	
    cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(ROUND( QRY->E2_SALDO -((QRY->E2_PIS-QRY->E2_VRETPIS) + (QRY->E2_COFINS-QRY->E2_VRETCOF) + (QRY->E2_CSLL-QRY->E2_VRETCSL)),2),"@R 99999999999999999.99") )+'</Data></Cell>	  	
  //cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(TransForm(ROUND((QRY->E2_VALOR+QRY->E2_MULTA+QRY->E2_JUROS)-(QRY->E2_VALOR - QRY->E2_SALDO)-((QRY->E2_PIS-QRY->E2_VRETPIS) + (QRY->E2_COFINS-QRY->E2_VRETCOF) + (QRY->E2_CSLL-QRY->E2_VRETCSL))-(QRY->E2_DESCONT),2),"@R 99999999999999999.99") )+'</Data></Cell>	  	
Else
	cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_SALDO,"@R 99999999999999999.99") )+'</Data></Cell>   
	cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_SALDO,"@R 99999999999999999.99") )+'</Data></Cell>
EndIF           

cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_NUMBOR	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_FATURA	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="Number">'+ALLTRIM(TransForm(QRY->E2_P_IDPRO,"@R 9999999999")	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->MODELO		)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->PAGAMENTO	)+'</Data></Cell>
cRet += '    <Cell ss:StyleID="s238"><Data ss:Type="String">'+ALLTRIM(QRY->E2_HIST		)+'</Data></Cell>
cRet += '   </Row>

Return cRet

/*
Funcao      : EndXML()
Parametros  : 
Retorno     : 
Objetivos   : Finaliza o Arquivo XML
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
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


/*
Funcao      : AjustaSX1()
Objetivos   : Montar o Arquivo de Perguntas no SX1 
Autor       : Cesar	Alves
Data/Hora   : 29/09/2017
*/    

*--------------------------*
Static Function AjustaSX1()
*--------------------------*
Local aArea	:= GetArea()

U_PUTSX1(	'HHFIN007','01','Data Emissão Inicial'				  ,'Data Emissão Inicial'	 			 ,'Data Emissão Inicial'				,'mv_ch1','D',8 ,0,0,'C',''															  ,'','','','mv_par01',''			,''			,''			,''		 ,''		,''		  ,''	  ,''	  ,''	  ,'','','','','','',''		,{'Informe a data de Emissão inicial ','para cópia das tabelas.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN007','02','Data Emissão Final'				  ,'Data Emissão Final'					 ,'Data Emissão Final'					,'mv_ch2','D',8 ,0,0,'C',''															  ,'','','','mv_par02',''			,''			,''			,''		 ,''		,''		  ,''	  ,''	  ,''	  ,'','','','','','',''		,{'Informe a data de Emissão final ','para a cópia das tabelas.',''},{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN007','03','Diretorio p/salvar DBF <ENTER>'	  ,'Diretorio p/salvar DBF <ENTER>'		 ,'Diretorio p/salvar DBF <ENTER>'		,'mv_ch3','C',99,0,0,'G',"!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,176))",'','','','mv_par03',''		  	,''			,''			,''		 ,''	   	,''		  ,''	  ,''	  ,''	  ,'','','','','','',''		,{'Informe o diretorio para a cópia','das tabelas.',	''}			,{'','',''},{'','',''},'')
U_PUTSX1(	'HHFIN007','04','Situação (Em aberto, Baixado, Ambos)','Situação (Em aberto, Baixado, Ambos)','Situação (Em aberto, Baixado, Ambos)','mv_ch4','C',1 ,0,1,'C',''															  ,'','','','mv_par04','Em aberto'	,'Em aberto','Em aberto','Baixado','Baixado','Baixado','Ambos','Ambos','Ambos','','','','','','',''		,{'Exporta esta tabela ?','',''}									,{'Exporta esta tabela ?','',''},{'Exporta esta tabela ?','',''},'')

RestArea(aArea)

Return()