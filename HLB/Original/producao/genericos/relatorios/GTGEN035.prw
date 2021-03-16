#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "COLORS.CH"

/*
Funcao      : GTGEN035()
Parametros  : 
Retorno     : 
Objetivos   : Relatorio de Empresas do SIGAMAT.
Autor       : Jean Victor Rocha
Data/Hora   : 28/04/2015
*/
*----------------------*
User Function GTGEN035()
*----------------------*  
Private cDest := GetTempPath()
Private cArq := "Empresas.XLS"

Private cXML := ""

Return Processa({|| Main()})

*--------------------*
Static Function Main()
*--------------------*
Local cQry := ""
Local cQryVld := ""
Local cQryMain := ""

Local aBancos := {}

Private nHdl := 0

cQry += "Select * From SQLTB717.GTHD.dbo.Z10010 Where Z10_AMB like 'P11_%' AND Z10_AMB <> 'P11_16'

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQry),"QRY",.F.,.F.)

QRY->(DbGoTop())
While QRY->(!EOF())
	cQryVld := "Select COUNT(*) AS NUM From "+ALLTRIM(STRTRAN(QRY->Z10_BANCO,"MSSQL7/",""))+".dbo.sysobjects Where type = 'U' AND name = 'SIGAMAT'"
	If Select("VLD") > 0
		VLD->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQryVld),"VLD",.F.,.F.)
	
	If VLD->NUM <> 0
		aAdd(aBancos,ALLTRIM(STRTRAN(QRY->Z10_BANCO,"MSSQL7/","")) )
	EndIf
	
	QRY->(DbSkip())
EndDo

ProcRegua(Len(aBancos))

cXML := ""
cXML += ' <?xml version="1.0"?>
cXML += ' <?mso-application progid="Excel.Sheet"?>
cXML += ' <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXML += '  xmlns:o="urn:schemas-microsoft-com:office:office"
cXML += '  xmlns:x="urn:schemas-microsoft-com:office:excel"
cXML += '  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXML += '  xmlns:html="http://www.w3.org/TR/REC-html40">
cXML += CHR(13) + CHR(10)
cXML += '  <Styles>
cXML += '   <Style ss:ID="Default" ss:Name="Normal">
cXML += '    <Alignment ss:Vertical="Bottom"/>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s63">
cXML += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '    <Borders>
cXML += '     <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3"
cXML += '      ss:Color="#FFFFFF"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#333399"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s65">
cXML += '    <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '    <Borders>
cXML += '     <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#4F81BD"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#4F81BD"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
cXML += '     ss:Bold="1"/>
cXML += '    <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s66">
cXML += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '    <Borders>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#B8CCE4"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#B8CCE4"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '    <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '   <Style ss:ID="s67">
cXML += '    <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '    <Borders>
cXML += '     <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#DCE6F1"/>
cXML += '     <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"
cXML += '      ss:Color="#DCE6F1"/>
cXML += '    </Borders>
cXML += '    <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '    <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>
cXML += '   </Style>
cXML += '  </Styles>
cXML += CHR(13) + CHR(10)
cXML += '  <Worksheet ss:Name="Empresas">
cXML += CHR(13) + CHR(10)
cXML += '   <Table ss:ExpandedColumnCount="20" ss:ExpandedRowCount="99000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXML += '    <Column ss:Width="92.25"/>
cXML += '    <Column ss:Width="158.25"/>
cXML += '    <Column ss:Width="92.25"/>
cXML += '    <Column ss:Width="217.5"/>
cXML += '    <Column ss:Width="112.5"/>
cXML += '    <Column ss:Width="39.75"/>
cXML += '    <Column ss:Width="138.75"/>
cXML += '    <Column ss:Width="66"/>
cXML += '    <Column ss:Width="72.75"/>
cXML += '    <Column ss:Width="46.5"/>
cXML += '    <Column ss:Width="105.75"/>
cXML += '    <Column ss:Width="39.75"/>
cXML += '    <Column ss:Width="52.5"/>
cXML += '    <Column ss:Width="79.5"/>
cXML += '    <Column ss:Width="118.5"/>
cXML += '    <Column ss:Width="46.5"/>
cXML += '    <Column ss:Width="26.25"/>
cXML += '    <Column ss:Width="112.5"/>
cXML += '    <Column ss:Width="72.75"/>
cXML += '    <Column ss:Width="59.25"/>
cXML += '    <Row ss:AutoFitHeight="0">
cXML += '     <Cell ss:MergeAcross="19" ss:StyleID="s63"><Data ss:Type="String">Dados da empresa</Data></Cell>
cXML += '    </Row>
cXML += CHR(13) + CHR(10)
cXML += ' <Row ss:AutoFitHeight="0">
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Ambiente</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Razao social</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">CNPJ</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Nome filial</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Codigo da empresa</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Endereco</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Bairro</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Complemento</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Cidade</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Codigo Municipio</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Estado</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Cep</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Telefone</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Inscricao Estadual</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Cnae</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Fpas</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Natureza Juridica</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Nire</Data></Cell>
cXML += '     <Cell ss:StyleID="s65"><Data ss:Type="String">Data Nire</Data></Cell>
cXML += '    </Row>
cXML += CHR(13) + CHR(10)

//Apaga o arquivo antigo.
If File(cDest+"/"+cArq)
	If FErase(cDest+"/"+cArq) <> 0
		MsgInfo("Não foi possivel apagar o arquivo '"+cArq+"' na pasta temporaria!","HLB BRASIL")
		Return .F.
	EndIf
EndIf

nHdl := FCREATE(cDest+"/"+cArq,0 )
FWRITE(nHdl, "" )
fclose(nHdl)

lTemDados := .F.
lStyle := .T.
cStyle := ''

For i:=1 to len(aBancos)
	IncProc("Montando Relatorio...")
	cQryMain := ""
	cQryMain += " Select '"+aBancos[i]+"' as AMB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CODIGO collate latin1_general_100_bin as M0_CODIGO, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CODFIL collate latin1_general_100_bin as M0_CODFIL, "+CHR(13)+CHR(10)
	cQryMain += "			M0_FILIAL collate latin1_general_100_bin as M0_FILIAL, "+CHR(13)+CHR(10)
	cQryMain += "			M0_NOME collate latin1_general_100_bin as M0_NOME, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CGC collate latin1_general_100_bin as M0_CGC, "+CHR(13)+CHR(10)
	cQryMain += "			M0_NOMECOM collate latin1_general_100_bin as M0_NOMECOM, "+CHR(13)+CHR(10)
	cQryMain += "			M0_ENDCOB collate latin1_general_100_bin as M0_ENDCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_BAIRCOB collate latin1_general_100_bin as M0_BAIRCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_COMPCOB collate latin1_general_100_bin as M0_COMPCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CIDCOB collate latin1_general_100_bin as M0_CIDCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_ESTCOB collate latin1_general_100_bin as M0_ESTCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CODMUN collate latin1_general_100_bin as M0_CODMUN, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CEPCOB collate latin1_general_100_bin as M0_CEPCOB, "+CHR(13)+CHR(10)
	cQryMain += "			M0_TEL collate latin1_general_100_bin as M0_TEL, "+CHR(13)+CHR(10)
	cQryMain += "			M0_INSC collate latin1_general_100_bin as M0_INSC, "+CHR(13)+CHR(10)
	cQryMain += "			M0_CNAE collate latin1_general_100_bin as M0_CNAE, "+CHR(13)+CHR(10)
	cQryMain += "			M0_FPAS collate latin1_general_100_bin as M0_FPAS, "+CHR(13)+CHR(10)
	cQryMain += "			M0_NATJUR collate latin1_general_100_bin as M0_NATJUR, "+CHR(13)+CHR(10)
	cQryMain += "			M0_NIRE collate latin1_general_100_bin as M0_NIRE, "+CHR(13)+CHR(10)
	cQryMain += "			M0_DTRE collate latin1_general_100_bin as M0_DTRE "+CHR(13)+CHR(10)
	cQryMain += " From "+aBancos[i]+".dbo.SIGAMAT "+CHR(13)+CHR(10)

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQryMain),"QRY",.F.,.F.)

	QRY->(DbGoTop())
	While QRY->(!EOF())
		lTemDados := .T.
		lStyle := !lStyle
		If lStyle
			cStyle := '"s66"'
		Else
			cStyle := '"s67"'
		EndIf
		cXML += ' <Row ss:AutoFitHeight="0">
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(aBancos[i])+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_NOMECOM)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CGC)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_NOME)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CODIGO)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_FILIAL)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_ENDCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_BAIRCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_COMPCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CIDCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CODMUN)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_ESTCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CEPCOB)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_TEL)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_INSC)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_CNAE)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_FPAS)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_NATJUR)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(QRY->M0_NIRE)+'</Data></Cell>
	    cXML += ' <Cell ss:StyleID='+cStyle+'><Data ss:Type="String">'+ALLTRIM(DTOC(STOD(QRY->M0_DTRE)))+'</Data></Cell>
		cXML += ' </Row>
		cXML += CHR(13) + CHR(10)
		//Grava caso a variavel esteja com muitos dados.
		If Len(cXML) >= 1000000//Proximo a 1Mega
			cXML := GrvArq(cXML)
		EndIf
	
		QRY->(DbSkip())
	EndDo
Next i

cXML += '   </Table>
cXML += CHR(13) + CHR(10)
cXML += '  </Worksheet>
cXML += CHR(13) + CHR(10)
cXML += ' </Workbook>

GrvArq(cXML)

If lTemDados
	SHELLEXECUTE("open",cDest+"/"+cArq,"","",5)//Abre o Arquivo
Else
    Alert("Não Foi possivel carregar os dados!")
    FErase(cDest+"/"+cArq)
    Return .T.
EndIf

Return .T.

/*
Funcao      : GrvArq()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function GrvArq(cMsg)
*--------------------------*
Local nHdl := Fopen(cDest+"/"+cArq)

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""