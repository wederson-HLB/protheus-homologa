#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : 9NFAT001
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Payroll em Excel
Autor       : Jean Victor Rocha
Data/Hora   : 04/07/2013
Obs         : 
TDN         : 
Obs         : 
Cliente     : SteelCase
*/                 
*-----------------------*
User Function 9NFAT001()
*-----------------------*
Local nHdl
Local cXML 			:= ""
Private cDest 		:= GetTempPath()
Private cPerg		:= "9NFAT001"
Private oExcel 		:= FWMSEXCEL():New()
Private cDest 		:= GetTempPath()
Private cArq 		:= "COST.XLS"
Private cChvExpen	:= ""
Private cExpenses	:= ""
Private nExpenses	:= 0
Private nBytesSalvo := 0 
Private aConsol 	:= {}
Private aTotCC	 	:= {}

//Validação da empresa que esta executando a função.
If !(cEmpAnt $ "9N/1Z")
	MsgAlert("Customização não disponivel para empresa!","HLB BRASIL")
	Return .T.
EndIf

//Tela com Parametros.         
AjustaSX1()

If !Pergunte(cPerg,.T.)
	Return()
EndIf

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
		MsgAlert("Sem dados para exibição, verificar parametros!","HLB BRASIL")
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
Local aStruSD2	:= SD2->(dbStruct())
Local aStruSA1	:= SA1->(dbStruct())
Local aCfops	:= {}

aCfops := SEPARA(Alltrim(MV_PAR05),';',.F.)


cQry += " Select SD2.*,SA1.A1_NOME,SC6.C6_PEDCLI
cQry += " From "+RetSQLName("SD2")+" SD2
cQry += " 		Left outer Join (Select * 
cQry += " 						From "+RetSQLName("SA1")
cQry += " 						Where D_E_L_E_T_ <> '*') as SA1 on SA1.A1_COD = SD2.D2_CLIENTE
//RRP - 09/10/2013 - Ajuste conforme solicitado pelo cliente.
cQry += " 		Left outer Join (Select * 
cQry += " 						From "+RetSQLName("SC6")
cQry += " 						Where D_E_L_E_T_ <> '*') as SC6 on SC6.C6_NUM = SD2.D2_PEDIDO AND SC6.C6_ITEM = SD2.D2_ITEM
cQry += " Where SD2.D_E_L_E_T_ <> '*'

If !EMPTY(MV_PAR01)
	cQry += " AND SD2.D2_COD >= '"+MV_PAR01+"'
EndIf
If !EMPTY(MV_PAR02)
	cQry += " AND SD2.D2_COD <= '"+MV_PAR02+"'
EndIf
If !EMPTY(MV_PAR03)
	cQry += " AND SD2.D2_EMISSAO >= '"+DTOS(MV_PAR03)+"'
EndIf
If !EMPTY(MV_PAR04)
	cQry += " AND SD2.D2_EMISSAO <= '"+DTOS(MV_PAR04)+"'
EndIf

//RRP - 22/11/2013 - Ajuste conforme Chamado 015618.
If Len(aCfops) <> 0
    cQry += " AND SD2.D2_CF IN (
    For i:= 1 To Len(aCfops)
        cQry += " '"+Alltrim(aCfops[i])+"',
    Next i
    cQry := Left(cQry,Len(cQry)-1)+")
EndIf

cQry +="ORDER BY SD2.D2_EMISSAO"

If select("QRY")>0
	QRY->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)                         


For nX := 1 To Len(aStruSD2)
    If aStruSD2[nX,2]<>"C"
 	    TcSetField("QRY",aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
    EndIf
Next nX

For nX := 1 To Len(aStruSA1)
    If aStruSA1[nX,2]<>"C"
	    TcSetField("QRY",aStruSA1[nX,1],aStruSA1[nX,2],aStruSA1[nX,3],aStruSA1[nX,4])
    EndIf
Next nX

Return .T.

/*
Funcao      : OpenExcel()
Parametros  : cXml
Retorno     : 
Objetivos   : Função para abrir o excel
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function OpenExcel(cXml)
*------------------------------*
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF
 
If (nHandle:=FCreate(cDest+cArq, 0)) == -1
	MsgAlert("Erro na criação do Arquivo!","HLB BRASIL")
	Return .T.
EndIf
FClose(nHandle)	

nHandle := Fopen(cDest+cArq,2)
FSeek(nHandle,0,2)
FWRITE(nHandle, cXML )
fclose(nHandle) 

SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel

Return .T.    

/*
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
Funcao      : AjustaSX1()
Parametros  : 
Retorno     : 
Objetivos   : Ajusta o Dicionario SX1 da empresa.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function AjustaSX1()
*------------------------------*
PutSx1( cPerg, "01", "Do Produto ?" 			, "¿De Producto ?" 			, "From Product ?"			, "mv_ch1" 	, "C" 	,15,0,0,"G",'' , "SB1"	,"","","MV_PAR01","","","",""	,"","","","","","","","","","","","",{"Produto inicial a ser considerado na ","filtragem do cadastro de produtos (SB1).",""},{},{},"")
PutSx1( cPerg, "02", "Ate o Produto ?" 			, "¿A Producto ?" 			, "To Product ?"			, "mv_ch2" 	, "C" 	,15,0,0,"G",'' , "SB1"	,"","","MV_PAR02","","","",""	,"","","","","","","","","","","","",{"Produto final a ser considerado na   ","filtragem do cadastro de produtos (SB1).",""},{},{},"")
PutSx1( cPerg, "03", "Do Periodo ?" 			, "¿De Periodo ?" 			, "From Period ?"			, "mv_ch3" 	, "D" 	,08,0,0,"G",'' , ""		,"","","MV_PAR03","","","",""	,"","","","","","","","","","","","",{"Período inicial a ser considerado na ","filtragem do cadastro de itens da nota  ","fiscal de entrada (SD1)."},{},{},"")
PutSx1( cPerg, "04", "Ate o Period ?" 			, "¿A Period ?" 			, "To Period ?"		  		, "mv_ch4" 	, "D" 	,08,0,0,"G",'' , ""		,"","","MV_PAR04","","","",""	,"","","","","","","","","","","","",{"Período final a ser considerado na   ","filtragem do cadastro de itens da nota  ","fiscal de entrada (SD1)."},{},{},"")
PutSx1( cPerg, "05", "Cfop(s) ?"	 			, "¿Cfop(s) ?"	 			, "Cfop(s) ?"		  		, "mv_ch5" 	, "C" 	,99,0,0,"G",'' , ""		,"","","MV_PAR05","","","",""	,"","","","","","","","","","","","",{"CFOP(s) a serem consideradas nas 	","filtragens das notas fiscais de entrada.","Favor separar por ;."},{},{},"")

Return .T.

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
Local nRowsTable	:= 0	

cXML += '<?xml version="1.0"?>
cXML += '<?mso-application progid="Excel.Sheet"?>
cXML += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXML += ' xmlns:o="urn:schemas-microsoft-com:office:office"
cXML += ' xmlns:x="urn:schemas-microsoft-com:office:excel"
cXML += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXML += ' xmlns:html="http://www.w3.org/TR/REC-html40">
cXML += ' <Styles>
cXML += '  <Style ss:ID="Default" ss:Name="Normal">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders/>
cXML += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat/>
cXML += '   <Protection/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s62" ss:Name="Comma_APURACAO CUSTO 23_01 A 19_02_GER_">
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s63" ss:Name="Comma_APURACAO CUSTO 23_01 A 19_02_GER_ 2">
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s64" ss:Name="Normal 12">
cXML += '   <Font ss:FontName="Arial"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s65" ss:Name="Normal_APURACAO CUSTO 23_01 A 19_02_GER_">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders/>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat/>
cXML += '   <Protection/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s66" ss:Name="Normal_APURACAO CUSTO 23_01 A 19_02_GER_ 3">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders/>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat/>
cXML += '   <Protection/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s67" ss:Name="Porcentagem 2">
cXML += '   <NumberFormat ss:Format="0%"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s69" ss:Parent="s65">
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s71" ss:Parent="s64">
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s72" ss:Parent="s64">
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s73" ss:Parent="s64">
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="Short Date"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s74" ss:Parent="s65">
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"
cXML += '    ss:Underline="Single"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s75" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="Short Date"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s76" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s78" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s79" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s81" ss:Parent="s66">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="Short Date"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s83" ss:Parent="s63">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="0"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s84" ss:Parent="s63">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s85" ss:Parent="s63">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s86" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s87" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s88" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s89" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s90" ss:Parent="s62">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s91" ss:Parent="s62">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s93" ss:Parent="s67">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="0.00%;[Red]\(0.00%\)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s94" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="dd/mm/yy;@"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s95" ss:Parent="s62">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"
cXML += '    ss:Italic="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s96" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s97" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s98" ss:Parent="s62">
cXML += '   <Alignment ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"
cXML += '    ss:Italic="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="_(* #,##0.00_);[Red]_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s99" ss:Parent="s67">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"
cXML += '    ss:Italic="1"/>
cXML += '   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>
cXML += '   <NumberFormat ss:Format="Percent"/>
cXML += '  </Style>
cXML += '  <Style ss:ID="s100" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '  </Style> 
cXML += '<Style ss:ID="s101" ss:Parent="s65">
cXML += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Bold="1"
cXML += '    ss:Underline="Single"/>
cXML += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXML += '  </Style>        
cXML += '  <Style ss:ID="s102" ss:Parent="s63">
cXML += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '   <Borders>
cXML += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
cXML += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '    <Border ss:Position="Top" ss:LineStyle="Continuous"/>
cXML += '   </Borders>
cXML += '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14"/>
cXML += '   <Interior/>
cXML += '   <NumberFormat ss:Format="@"/>
cXML += '  </Style>
cXML += ' </Styles> 
cXML += '<Worksheet ss:Name="Cost">
cXML += '  <Table ss:ExpandedColumnCount="22" ss:ExpandedRowCount="20000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="090"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="300"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="100"/>
cXML += '   <Column ss:AutoFitWidth="1" ss:Width="80"/>
cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18">
cXML += '    <Cell ss:MergeAcross="3" ss:StyleID="s100"><Data ss:Type="String">'+SM0->M0_NOMECOM+'</Data></Cell>
//cXML += '    <Cell ss:StyleID="s71"/>
//cXML += '    <Cell ss:StyleID="s71"/>
//cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s72"><Data ss:Type="String"> Extraction:</Data></Cell>
cXML += '    <Cell ss:StyleID="s73"><Data ss:Type="DateTime">'+STRZERO(YEAR(Date()),4)+'-'+STRZERO(MONTH(DAte()),2)+'-'+STRZERO(DAY(Date()),2)+'T00:00:00.000</Data></Cell>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '   </Row>
cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18">
cXML += '    <Cell ss:StyleID="s69"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s72"/>
cXML += '    <Cell ss:StyleID="s73"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '   </Row>
cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18">
cXML += '    <Cell ss:MergeAcross="3" ss:StyleID="s101"><Data ss:Type="String">Sales - National Market</Data></Cell>
//cXML += '    <Cell ss:StyleID="s71"/>
//cXML += '    <Cell ss:StyleID="s71"/>
//cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s72"/>
cXML += '    <Cell ss:StyleID="s73"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '   </Row>
cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXML += '    <Cell ss:StyleID="s74"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '    <Cell ss:StyleID="s71"/>
cXML += '   </Row>
cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXML += '    <Cell ss:StyleID="s75"><Data ss:Type="String">DATE</Data></Cell>
cXML += '    <Cell ss:StyleID="s76"><Data ss:Type="String">Invoice</Data></Cell>
cXML += '    <Cell ss:StyleID="s76"><Data ss:Type="String">PO</Data></Cell>
cXML += '    <Cell ss:StyleID="s76"><Data ss:Type="String">CLIENT</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">SALE</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">PIS</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">COFINS</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">ISS</Data></Cell>
cXML += '    <Cell ss:StyleID="s76"><Data ss:Type="String">IPI</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">ICMS</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Return</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Net Act 30001</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">CPV</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Steady Cost</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Telelok</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Novo Visual</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Marimex Cost</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Demurrage</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Commission</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Total Cost</Data></Cell>
cXML += '    <Cell ss:StyleID="s78"><Data ss:Type="String">Margin</Data></Cell>
cXML += '    <Cell ss:StyleID="s79"><Data ss:Type="String">GP %</Data></Cell>
cXML += '   </Row>
                 
nRowsTable := 0
QRY->(DbGoTop())
While QRY->(!EOF())    
	cXML += '   <Row ss:AutoFitHeight="0" ss:Height="18">
	cXML += '    <Cell ss:StyleID="s81"><Data ss:Type="DateTime">'+STRZERO(YEAR(QRY->D2_EMISSAO),4)+'-'+STRZERO(MONTH(QRY->D2_EMISSAO),2)+'-'+STRZERO(DAY(QRY->D2_EMISSAO),2)+'T00:00:00.000</Data></Cell>
//	cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="String">'+ALLTRIM(QRY->D2_PEDIDO)+'</Data></Cell> - RRP - 09/10/2013 - Ajuste conforme solicitado pelo cliente.
	cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="String">'+ALLTRIM(QRY->D2_DOC)+'</Data></Cell>
//	cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="String">'+ALLTRIM(QRY->D2_DOC)+'-'+ALLTRIM(QRY->D2_SERIE)+'</Data></Cell> - RRP - 09/10/2013 - Ajuste conforme solicitado pelo cliente.
//	cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="String">'+ALLTRIM(QRY->C6_PEDCLI)+'</Data></Cell> - RRP - 09/10/2013 - Ajuste conforme solicitado no chamado 030377.
	cXML += '    <Cell ss:StyleID="s102"><Data ss:Type="String">'+ALLTRIM(QRY->D2_LOTECTL)+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s84" ><Data ss:Type="String">'+ALLTRIM(QRY->A1_NOME)+'</Data></Cell> 
	cXML += '    <Cell ss:StyleID="s85" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALBRUTO		,"9999999999.99"),",","."))+'</Data></Cell>'//RRP - 30/10/2013 - Campo antigo D2_TOTAL. Chamado 015259. 
	cXML += '    <Cell ss:StyleID="s86" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALIMP6*(-1)	,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALIMP5*(-1)	,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s88" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALISS*(-1)	,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s89" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALIPI*(-1)	,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s90" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_VALICM*(-1)	,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s91" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s90" ss:Formula="=RC[-7]+SUM(RC[-6]:RC[-2])"><Data ss:Type="Number"></Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(QRY->D2_CUSTO1,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ><Data ss:Type="Number">0</Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ss:Formula="=SUM(RC[-7]:RC[-1])"><Data ss:Type="Number"></Data></Cell>
	cXML += '    <Cell ss:StyleID="s87" ss:Formula="=RC[-9]-RC[-1]"><Data ss:Type="Number"></Data></Cell>
	cXML += '    <Cell ss:StyleID="s93" ss:Formula="=RC[-1]/RC[-10]"><Data ss:Type="Number"></Data></Cell>
	cXML += '   </Row>
	nRowsTable ++	
	QRY->(DbSkip())
EndDo   

cXML += '<Row ss:AutoFitHeight="0" ss:Height="19.5">
cXML += '    <Cell ss:StyleID="s94"/>
cXML += '    <Cell ss:StyleID="s95"/>
cXML += '    <Cell ss:StyleID="s96"><Data ss:Type="String">TOTAL</Data></Cell>
cXML += '    <Cell ss:StyleID="s97"/>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s95" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>
cXML += '    <Cell ss:StyleID="s99" ss:Formula="=RC[-1]/RC[-10]"><Data ss:Type="Number"></Data></Cell>
cXML += '   </Row>
cXML += '   </Table>
cXML += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXML += '   <PageSetup>
cXML += '    <Header x:Margin="0.31496062000000002"/>
cXML += '    <Footer x:Margin="0.31496062000000002"/>
cXML += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"
cXML += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>
cXML += '   </PageSetup>
cXML += '   <Unsynced/>
cXML += '   <Print>
cXML += '    <ValidPrinterInfo/>
cXML += '    <PaperSizeIndex>9</PaperSizeIndex>
cXML += '    <HorizontalResolution>600</HorizontalResolution>
cXML += '    <VerticalResolution>600</VerticalResolution>
cXML += '   </Print>
cXML += '   <Zoom>85</Zoom>
cXML += '   <Selected/>
cXML += '   <FreezePanes/>
cXML += '   <FrozenNoSplit/>
cXML += '   <SplitHorizontal>5</SplitHorizontal>
cXML += '   <TopRowBottomPane>5</TopRowBottomPane>
cXML += '   <ActivePane>2</ActivePane>
cXML += '   <Panes>
cXML += '    <Pane>
cXML += '     <Number>3</Number>
cXML += '    </Pane>
cXML += '    <Pane>
cXML += '     <Number>2</Number>
cXML += '     <ActiveRow>13</ActiveRow>
cXML += '     <ActiveCol>2</ActiveCol>
cXML += '    </Pane>
cXML += '   </Panes>
cXML += '   <ProtectObjects>False</ProtectObjects>
cXML += '   <ProtectScenarios>False</ProtectScenarios>
cXML += '  </WorksheetOptions>
cXML += ' </Worksheet>
cXML += '</Workbook>
 
Return cXML