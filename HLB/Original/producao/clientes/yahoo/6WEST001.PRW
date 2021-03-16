#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
/*
Funcao      : 6WEST001()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Gera relatório capa de Retenções
Autor       : Jean Victor Rocha
Data/Hora   : 17/12/2014
*/  
*----------------------*
User Function 6WEST001()
*----------------------*
Private cQry1:=""
Private cHtml:=""
Private nICor:=0

cHtml := ""

If IsInCallStack("MATA103")
	cHtml += CriaXml("1")
ElseIf IsInCallStack("FINA050")
	cHtml += CriaXml("2")
EndIf

GExecl(cHtml)

Return .T.

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para gerar o excel
Autor       : 
Data/Hora   :
*/
*-----------------------------*
Static Function GExecl(cConteu)
*-----------------------------*
Private cDest :=  GetTempPath()

cArq := cEmpAnt+"Capinha.xls"

If FILE(cDest+cArq)
	FERASE (cDest+cArq)
EndIf

nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cConteu ) // Gravação do seu Conteudo.

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
EndIf

Return

/*
Funcao      : CriaXml()
Parametros  : 
Retorno     : 
Objetivos   : Função para criar o xml com as informações
Autor       : 
Data/Hora   :
*/
*----------------------------*
Static Function CriaXml(cTipo)
*----------------------------*
Local cNomeFor  := ""
Local cCnpj		:= ""
Local cXml		:= ""

cXml+='	<?xml version="1.0" encoding="ISO-8859-1" ?>
cXml+='	<?mso-application progid="Excel.Sheet"?>
cXml+='	<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml+='	 xmlns:o="urn:schemas-microsoft-com:office:office"
cXml+='	 xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml+='	 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml+='	 xmlns:html="http://www.w3.org/TR/REC-html40">
cXml+='	 <Styles>
cXml+='	  <Style ss:ID="Default" ss:Name="Normal">
cXml+='	   <Alignment ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s62" ss:Name="Moeda 2">
cXml+='	   <NumberFormat
cXml+='	    ss:Format="_-* #,##0.00\ &quot;z?&quot;_-;\-* #,##0.00\ &quot;z?&quot;_-;_-* &quot;-&quot;??\ &quot;z?&quot;_-;_-@_-"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s63" ss:Name="Normal 2">
cXml+='	   <Alignment ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120820" ss:Parent="s63">
cXml+='	   <Alignment ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120840" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120860" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120880" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120576" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120596" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120616" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120636" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120656" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="24" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#CCFFCC" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120676" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#CCFFCC" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120352" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120128" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120148" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120168" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120188" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120208" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120228" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120248" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120268" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119904" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="24" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119924" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119944" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119964" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119984" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45120004" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119740" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119760" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119780" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119800" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45119820" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117664" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117684" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117704" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
//RRP - 22/01/2015 - Criação de sytle para o Amount.
cXml+='	  <Style ss:ID="a001" ss:Parent="s62">
cXml+='	     <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
cXml+='	     <Borders>
cXml+='	      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	     </Borders>
cXml+='	     <Font ss:FontName="Arial" x:Family="Swiss" ss:Bold="1"/>
cXml+='	     <Interior ss:Color="#FFFFCC" ss:Pattern="Solid"/>
cXml+='      <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>
cXml+='	     <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117744" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117764" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117784" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117804" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117460" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117540" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117560" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117580" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m45117600" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m43056680" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m43056700" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m43056720" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m43056760" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="18" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="General Date"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m43056436" ss:Parent="s63">
cXml+='	     <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
cXml+='	     <Borders>
cXml+='	      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	     </Borders>
cXml+='	     <Font ss:FontName="Arial" x:Family="Swiss" ss:Bold="1"/>
cXml+='	     <Interior ss:Color="#FFFFCC" ss:Pattern="Solid"/>
cXml+='	     <NumberFormat ss:Format="000000"/>
cXml+='	     <Protection ss:Protected="0"/>
cXml+='	    </Style>
cXml+='	  <Style ss:ID="m43056476" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	   <NumberFormat ss:Format="Short Date"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m62212736" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m62212776" ss:Parent="s63">
cXml+='	   <Alignment ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="7"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m62212796" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="m62212816" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFCC" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s75" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s76" ss:Parent="s63">
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s77" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s78" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFCC99" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s80" ss:Parent="s63">
cXml+='	   <Alignment ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="7"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s83" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cXml+='	   <Interior ss:Color="#FFFFCC" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s86" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s87" ss:Parent="s63">
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s88" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s97" ss:Parent="s63">
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s98" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s106" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s109" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s110" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s111" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s113" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s122" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s150" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s161" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="20" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s167" ss:Parent="s63">
cXml+='	   <Alignment ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000"/>
cXml+='	   <Interior ss:Color="#FFFFCC" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="Medium Date"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s168" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s186" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s188" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="General Date"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s200" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s205" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="General Date"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s209" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="General Date"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s210" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat/>
cXml+='	   <Protection x:HideFormula="1" ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s212" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <NumberFormat ss:Format="General Date"/>
cXml+='	   <Protection x:HideFormula="1" ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s214" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s235" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s236" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="13" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s243" ss:Parent="s63">
cXml+='	   <Alignment ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s250" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s262" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1" ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s279" ss:Parent="s63">
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s310" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s313" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s314" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s326" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s348" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s360" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="16" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s370" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s371" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s372" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000080" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s373" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#008000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s374" ss:Parent="s62">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="_([$BRL]\ * #,##0.00_);_([$BRL]\ * \(#,##0.00\);_([$BRL]\ * &quot;-&quot;??_);_(@_)"/>
cXml+='	   <Protection x:HideFormula="1"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s393" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s418" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s419" ss:Parent="s63">
cXml+='	   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#FF0000" ss:Bold="1"/>
cXml+='	   <Interior/>
cXml+='	   <NumberFormat ss:Format="Medium Date"/>
cXml+='	   <Protection/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s420" ss:Parent="s63">
cXml+='	   <Borders/>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s428" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s429" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	  <Style ss:ID="s430" ss:Parent="s63">
cXml+='	   <Borders>
cXml+='	    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXml+='	   </Borders>
cXml+='	   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXml+='	   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml+='	   <Protection ss:Protected="0"/>
cXml+='	  </Style>
cXml+='	 </Styles>
cXml+='	 <Worksheet ss:Name="Plan1">
cXml+='	  <Table ss:ExpandedColumnCount="12" ss:ExpandedRowCount="48" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXml+='	   <Column ss:Index="2" ss:AutoFitWidth="0" ss:Width="84.75"/>
cXml+='	   <Column ss:Index="5" ss:AutoFitWidth="0" ss:Width="71.25"/>
cXml+='	   <Column ss:Index="7" ss:AutoFitWidth="0" ss:Width="54"/>
cXml+='	   <Column ss:AutoFitWidth="0" ss:Width="76.5"/>
cXml+='	   <Column ss:AutoFitWidth="0" ss:Width="57"/>
cXml+='	   <Column ss:Index="11" ss:AutoFitWidth="0" ss:Width="70.5"/>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:MergeAcross="11" ss:MergeDown="2" ss:StyleID="m62212736">
cXml+='	      <Data ss:Type="String" x:Ticked="1">NOTA FISCAL - INSTRUÇÕES CONTÁBEIS&#10;NON-PO / PO e PRE-APPROVED</Data>
cXml+='	      <NamedCell ss:Name="Z_32F3C9F8_1AB3_4CA2_9B41_86F9B13CF195_.wvu.PrintArea"/><NamedCell ss:Name="Print_Area"/>
cXml+='	    </Cell>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0"/>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18"/>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXml+='	    <Cell ss:StyleID="s75"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s77"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18">
cXml+='	    <Cell ss:MergeAcross="11" ss:StyleID="m62212796"><Data ss:Type="String" x:Ticked="1">DADOS DA NF / INVOICE DATA</Data></Cell>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s97"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s97"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="s113"><Data ss:Type="String">Invoice #</Data></Cell>
If cTipo == "1"
	cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m43056436"><Data ss:Type="String">'+alltrim(SF1->F1_DOC)+'</Data></Cell>
Else
	cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m43056436"><Data ss:Type="String">'+alltrim(SE2->E2_NUM)+'</Data></Cell>
EndIf
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s98"><Data ss:Type="String">Inv Date:</Data></Cell>
If cTipo == "1"
	cData := DTOC(SF1->F1_EMISSAO)
Else
	cData := DTOC(SE2->E2_EMISSAO)
EndIf
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m43056436"><Data ss:Type="String">'+cData+'</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m43056476"><Data ss:Type="String"></Data></Cell>
cXml+='	   </Row>

cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>

//fornecedor
cNomeFor:= ""
cCnpj	:= ""
               
DbSelectArea("SA2")
SA2->(DbSetOrder(1))

If cTipo == "1"
	If DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		cNomeFor:= alltrim(SA2->A2_NOME)
		cCnpj	:= alltrim(SA2->A2_CGC)
	EndIf
Else
	If DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
		cNomeFor:= alltrim(SA2->A2_NOME)
		cCnpj	:= alltrim(SA2->A2_CGC)
	EndIf
EndIf
	
//Natureza
cDescNat:= ""
nPis	:= 0
nCofins	:= 0
nInss	:= 0
nIss	:= 0
nIrrf	:= 0
nCsll	:= 0

//Codigo de retenção
cRetPis	:= "5952"
cRetCof	:= "5952"
cRetIns := "2631/2100"
cRetIss	:= "ISS"
cRetIrr	:= "IRRF"
cRetCsl	:= "5952"

cVencto	:= ''

cQry:="  SELECT SED.ED_DESCRIC,SE2.E2_PIS,SE2.E2_COFINS,SE2.E2_INSS,SE2.E2_ISS,SE2.E2_IRRF,SE2.E2_CSLL,SE2.E2_VENCTO 
cQry+=" 	,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_VRETPIS	) AS 'RETPIS'
cQry+=" 	,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_VRETCOF	) AS 'RETCOFINS'
cQry+="		,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_INSS	) AS 'RETINSS'
cQry+="		,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_VRETCSL	) AS 'RETCSLL'
cQry+="		,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_ISS		) AS  'RETISS'
cQry+=" 	,(SELECT E2_CODRET FROM "+RETSQLNAME("SE2")
cQry+=" 		WHERE D_E_L_E_T_='' AND E2_TITPAI= SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
cQry+="                             AND E2_VALOR=SE2.E2_IRRF	) AS 'RETIRRF'
cQry+=" FROM "+RETSQLNAME("SED")+" SED
cQry+=" 	JOIN "+RETSQLNAME("SE2")+" SE2 ON SED.ED_CODIGO = SE2.E2_NATUREZ AND SED.ED_FILIAL='  ' 
cQry+=" WHERE SE2.D_E_L_E_T_	= ''
cQry+=" 	AND SED.D_E_L_E_T_	= ''
cQry+=" 	AND SE2.E2_FILIAL	= '"+xFilial("SE2")	+"'
If cTipo == "1"
	cQry+=" 	AND SE2.E2_NUM		= '"+SF1->F1_DUPL	+"' 
	cQry+=" 	AND SE2.E2_PREFIXO	= '"+SF1->F1_PREFIXO+"' 
	cQry+=" 	AND SE2.E2_FORNECE	= '"+SF1->F1_FORNECE+"'
	cQry+=" 	AND SE2.E2_LOJA		= '"+SF1->F1_LOJA	+"'
Else
	cQry+=" 	AND SE2.E2_NUM		= '"+SE2->E2_NUM	+"' 
	cQry+=" 	AND SE2.E2_PREFIXO	= '"+SE2->E2_PREFIXO+"' 
	cQry+=" 	AND SE2.E2_FORNECE	= '"+SE2->E2_FORNECE+"'
	cQry+=" 	AND SE2.E2_LOJA		= '"+SE2->E2_LOJA	+"'
EndIf

If tcsqlexec(cQry)<0
	Alert("Ocorreu um problema na busca das informações!!")
	Return .F.
EndIf

If select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )

Count to nRecCount
        
If nRecCount >0
	QRYTEMP->(DbGotop())

   	cDescNat:= alltrim(QRYTEMP->ED_DESCRIC)
   	nPis	:= QRYTEMP->E2_PIS
   	nCofins	:= QRYTEMP->E2_COFINS
   	nInss	:= QRYTEMP->E2_INSS
   	nIss	:= QRYTEMP->E2_ISS
   	nIrrf	:= QRYTEMP->E2_IRRF
   	nCsll	:= QRYTEMP->E2_CSLL

	cVencto	:= DTOC(STOD(QRYTEMP->E2_VENCTO))
EndIf
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="s113"><Data ss:Type="String" x:Ticked="1">VENDOR</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="4" ss:StyleID="m43056436"><Data ss:Type="String">'+cNomeFor+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s98"><Data ss:Type="String">VAT ID</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m43056436"><Data ss:Type="String">'+cCnpj+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="s113"><Data ss:Type="String">Amount:</Data></Cell>
If cTipo == "1"
	cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="a001"><Data ss:Type="Number">'+cvaltochar(SF1->F1_VALBRUT)+'</Data></Cell>
Else
	cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="a001"><Data ss:Type="Number">'+cvaltochar(SE2->E2_VALOR)+'</Data></Cell>
EndIf
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s98"><Data ss:Type="String">Currency:</Data></Cell>
cXml+='	    <Cell ss:StyleID="m43056436"><Data ss:Type="String">BRL</Data></Cell>'//BRL
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="s200"><Data ss:Type="String" x:Ticked="1">WHTAX Category</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="3" ss:StyleID="s205"><Data ss:Type="String">'+cDescNat+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s209"/>
cXml+='	    <Cell ss:StyleID="s210"><Data ss:Type="Number"></Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="s212"><Data ss:Type="String">'+cDescNat+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s214"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="33">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117540"><Data ss:Type="String">DESCRIPTION</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117560"><Data ss:Type="String">Natural Account</Data></Cell>
cXml+='	    <Cell ss:StyleID="s235"><Data ss:Type="String">SUB Account</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117580"><Data ss:Type="String">Natural Account</Data></Cell>
cXml+='	    <Cell ss:StyleID="s236"><Data ss:Type="String">TAX CODE (IRS Only)</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45117600"><Data ss:Type="String">Amount</Data></Cell>
cXml+='	    <Cell ss:StyleID="s243"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117664"><Data ss:Type="String">BS PCC WHTAX</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="Number">270500</Data></Cell>
cXml+='	    <Cell ss:StyleID="s250"><Data ss:Type="String">2474</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="Number">21116012</Data></Cell>'
cXml+='	    <Cell ss:StyleID="s262"><Data ss:Type="String">'+cRetPis+'</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nPis+nCofins+nCsll)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117664"><Data ss:Type="String" x:Ticked="1">BS INSS WHTAX</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="Number">270500</Data></Cell>
cXml+='	    <Cell ss:StyleID="s250"><Data ss:Type="String">2474</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="Number">21116013</Data></Cell>
cXml+='	    <Cell ss:StyleID="s262"><Data ss:Type="String">'+cRetIns+'</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nInss)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117664"><Data ss:Type="String">BS ISS WHTAX</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="Number">270500</Data></Cell>
cXml+='	    <Cell ss:StyleID="s250"><Data ss:Type="String">2474</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="Number">21116015</Data></Cell>
cXml+='	    <Cell ss:StyleID="s262"><Data ss:Type="String">'+cRetIss+'</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nIss)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117664"><Data ss:Type="String">BS IRRF WHTAX</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="Number">270500</Data></Cell>
cXml+='	    <Cell ss:StyleID="s250"><Data ss:Type="String">2474</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="Number">21116009</Data></Cell>
cXml+='	    <Cell ss:StyleID="s262"><Data ss:Type="String">'+cRetIrr+'</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nIrrf)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s279"/>
cXml+='	    <Cell ss:StyleID="s279"/>
cXml+='	    <Cell ss:StyleID="s279"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="30.75">
cXml+='	    <Cell ss:MergeAcross="7" ss:StyleID="m45119904"><Data ss:Type="String" x:Ticked="1">TOTAL SUPPLIER PAYABLE </Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119924" ss:Formula="=R[-11]C[-6]-SUM(R[-5]C:R[-2]C[2])"><Data ss:Type="Number"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="30">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="33">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45119944"><Data ss:Type="String">DESCRIPTION</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45119964"><Data ss:Type="String">Natural Account</Data></Cell>
cXml+='	    <Cell ss:StyleID="s310"><Data ss:Type="String">SUB Account</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45119984"><Data ss:Type="String">Natural Account</Data></Cell>
cXml+='	    <Cell ss:StyleID="s236"><Data ss:Type="String">TAX CODE (IRS Only)</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45120004"><Data ss:Type="String">Amount</Data></Cell>
cXml+='	    <Cell ss:StyleID="s313"/>
cXml+='	   </Row>

nIcms	:= 0
nIpi	:= 0
nCf2	:= 0
nPs2	:= 0

If cTipo == "1"
	cQry1 := " SELECT F3_VALICM,F3_VALIPI,F1_VALIMP5 AS 'CF2',F1_VALIMP6 AS 'PS2' 
	cQry1 += " FROM "+RETSQLNAME("SF1")+" SF1
	cQry1 += " 		LEFT JOIN "+RETSQLNAME("SF3")+" SF3 ON F3_FILIAL+F3_ENTRADA+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA = 
	cQry1 += " 						 							F1_FILIAL+F1_DTDIGIT+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
	cQry1 += " WHERE SF1.D_E_L_E_T_='' AND SF3.D_E_L_E_T_='' 
	cQry1 += " 		AND F1_FILIAL="+xFilial("SF1")+" AND F1_DOC='"+SF1->F1_DOC+"' AND F1_SERIE='"+SF1->F1_SERIE+"' 
	cQry1 += " 		AND F1_FORNECE='"+SF1->F1_FORNECE+"' AND F1_LOJA='"+SF1->F1_LOJA+"' AND F1_TIPO='"+SF1->F1_TIPO+"'"
	If tcsqlexec(cQry1)<0
		Alert("Ocorreu um problema na busca das informações!!")
		Return .F.
	EndIf
	If select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry1), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	
	If nRecCount > 0
		QRYTEMP->(DbGotop())
		nIcms   := QRYTEMP->F3_VALICM
		nIpi    := QRYTEMP->F3_VALIPI
		nCf2    := QRYTEMP->CF2
		nPs2	:= QRYTEMP->PS2
	EndIf
EndIf
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45120352"><Data ss:Type="String">PIS</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="String"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s314"><Data ss:Type="String"></Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="String">11320011</Data></Cell>
cXml+='	    <Cell ss:StyleID="s326"><Data ss:Type="String">N/A</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nPs2)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45120352"><Data ss:Type="String">COFINS</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117684"><Data ss:Type="String"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s314"><Data ss:Type="String"></Data></Cell>
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45117704"><Data ss:Type="String">11320009</Data></Cell>
cXml+='	    <Cell ss:StyleID="s326"><Data ss:Type="String">N/A</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45119740"><Data ss:Type="Number">'+cvaltochar(nCf2)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s150"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="18">
cXml+='	    <Cell ss:StyleID="s86"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s87"/>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="30.75">
cXml+='	    <Cell ss:MergeAcross="7" ss:StyleID="m45120656"><Data ss:Type="String" x:Ticked="1">TOTAL P&amp;L IMPACT</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45120676" ss:Formula="=R[-28]C[-6]-SUM(R[-7]C:R[-4]C[2])+R[-2]C"><Data ss:Type="Number"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s88"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXml+='	    <Cell ss:MergeAcross="3" ss:StyleID="s393"/>
cXml+='	    <Cell ss:StyleID="s76"><Data ss:Type="String" x:Ticked="1"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s76"/>
cXml+='	    <Cell ss:StyleID="s77"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:MergeAcross="11" ss:MergeDown="1" ss:StyleID="m45120820"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0"/>
cXml+='	   <Row ss:AutoFitHeight="0" ss:Height="20.25">
cXml+='	    <Cell ss:MergeAcross="1" ss:StyleID="m45120840"><Data ss:Type="String">Analyst</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="3" ss:StyleID="m45120860"><Data ss:Type="String">'+UsrFullName(__cUserID)+'</Data></Cell>
cXml+='	    <Cell ss:StyleID="s418"><Data ss:Type="String">Date:</Data></Cell>
cXml+='	    <Cell ss:StyleID="s419" ss:Formula="=TODAY()"><Data ss:Type="DateTime"></Data></Cell>
cXml+='	    <Cell ss:StyleID="s420"><Data ss:Type="String">Print name:</Data></Cell>
cXml+='	    <Cell ss:MergeAcross="2" ss:StyleID="m45120880"/>
cXml+='	   </Row>
cXml+='	   <Row ss:AutoFitHeight="0">
cXml+='	    <Cell ss:StyleID="s428"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s429"/>
cXml+='	    <Cell ss:StyleID="s430"/>
cXml+='	   </Row>
cXml+='	  </Table>
cXml+='	  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXml+='	   <PageSetup>
cXml+='	    <Header x:Margin="0.31496062000000002"/>
cXml+='	    <Footer x:Margin="0.31496062000000002"/>
cXml+='	    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024" x:Right="0.511811024" x:Top="0.78740157499999996"/>
cXml+='	   </PageSetup>
cXml+='	   <Unsynced/>
cXml+='	   <Zoom>80</Zoom>
cXml+='	   <Selected/>
cXml+='	   <Panes>
cXml+='	    <Pane>
cXml+='	     <Number>3</Number>
cXml+='	     <ActiveRow>10</ActiveRow>
cXml+='	     <ActiveCol>13</ActiveCol>
cXml+='	    </Pane>
cXml+='	   </Panes>
cXml+='	   <ProtectObjects>False</ProtectObjects>
cXml+='	   <ProtectScenarios>False</ProtectScenarios>
cXml+='	  </WorksheetOptions>
cXml+='	 </Worksheet>
cXml+='	</Workbook>

Return(cXml)