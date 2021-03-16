#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : GTFAT011
Parametros  : Nil
Retorno     : Nil
Objetivos   : Relatorio de TES x Ultima utilização.
Autor       : Jean Victor Rocha
Data/Hora   : 28/11/2014
*/
*----------------------*
User Function GTFAT011()
*----------------------*
Private aRelatorio := {}

Processa({|| MainGT() },"Processando aguarde...")
Return .T.   

/*
Funcao      : MainGT
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Principal
Autor       : Jean Victor Rocha
Data/Hora   : 28/11/2014
*/
*----------------------*
Static Function MainGT()
*----------------------*
Local i
Local cAmbAtu := ""
Local nConHD := 0
Local nConAMB:= 0
Local cData := ""
Local aEmpresas := {} 
Local lExistTab := .T.
Local cQry	:= ""
Local aGTHD := {"GTHD"  ,"MSSQL7/GTHD"     ,"10.0.30.5"}
Local aAmb := {	{"P11_01","MSSQL7/P11_01"   ,"10.0.30.5"},;
				{"P11_02","MSSQL7/P11_02"   ,"10.0.30.5"},;
				{"P11_03","MSSQL7/P11_03"   ,"10.0.30.5"},;
				{"P11_04","MSSQL7/P11_04"   ,"10.0.30.5"},;
				{"P11_05","MSSQL7/P11_05"   ,"10.0.30.5"},;
				{"P11_06","MSSQL7/P11_06"   ,"10.0.30.5"},;
				{"P11_07","MSSQL7/P11_07"   ,"10.0.30.5"},;
				{"P11_08","MSSQL7/P11_08"   ,"10.0.30.5"},;
				{"P11_09","MSSQL7/P11_09"   ,"10.0.30.5"},;
				{"P11_10","MSSQL7/P11_10"   ,"10.0.30.5"},;
				{"P11_11","MSSQL7/P11_11"   ,"10.0.30.5"},;
				{"P11_12","MSSQL7/P11_12"   ,"10.0.30.5"},;
				{"P11_13","MSSQL7/P11_13"   ,"10.0.30.5"},;
				{"P11_14","MSSQL7/P11_14"   ,"10.0.30.5"},;
				{"P11_15","MSSQL7/P11_15"   ,"10.0.30.5"},;
				{"P11_16","MSSQL7/P11_16"   ,"10.0.30.5"},;
				{"P11_17","MSSQL7/P11_17"   ,"10.0.30.5"},;
				{"P11_18","MSSQL7/P11_18"   ,"10.0.30.5"},;
				{"P11_19","MSSQL7/P11_19"   ,"10.0.30.5"},;
				{"P11_20","MSSQL7/P11_20"   ,"10.0.30.5"}}

If (nConHD := TCLink(aGTHD[2],aGTHD[3])) <> 0
	cQry += " Select Z04_AMB,Z04_CODIGO,Z04_NOME
	cQry += " From Z04010
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += " 		AND LEFT(Z04_AMB,4) = 'P11_'
	cQry += " 		AND Z04_AMB <> 'P11_16'
	cQry += " 		AND Z04_MSBLQL <> '1'
	cQry += " Group By Z04_AMB,Z04_CODIGO,Z04_NOME
	cQry += " Order By Z04_AMB,Z04_CODIGO,Z04_NOME

	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif  
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
	
	QRY->(DbGoTop())
	While QRY->(!EOF())
		If aScan(aEmpresas,{|x| X[1] == UPPER(ALLTRIM(QRY->Z04_AMB)) .and. X[2] == UPPER(ALLTRIM(QRY->Z04_CODIGO))  })  == 0
			aAdd(aEmpresas,{QRY->Z04_AMB,QRY->Z04_CODIGO,QRY->Z04_NOME})
		EndIf	
		QRY->(DbSkip())
	EndDo
Else
	Conout("GTFAT011 - Não foi possivel conexão ao Banco "+aGTHD[2])
EndIf
//Encerra a conexão
TCunLink(nConHD)    

//Caso possuir informações, executa as buscas.
If Len(aEmpresas) <> 0
	//Ordenação das empresas/Ambientes.
	aSort(aEmpresas)
    
	cAmbAtu := ""     
	nConAMB := 0
	ProcRegua(Len(aEmpresas))
	For i:=1 to Len(aEmpresas)
		IncProc("Aguarde...")
		If cAmbAtu <> aEmpresas[i][1]
			If nConAMB <> 0
				TCunLink(nConAMB)
				nConAMB := 0
			EndIf
			If (nPos:=aScan(aAmb,{|x| x[1] == ALLTRIM(aEmpresas[i][1]) })) <> 0
				//Conexão com o Banco das empresas.
				If (nConAMB := TCLink(aAmb[nPos][2],aAmb[nPos][3])) <> 0
					lExistTab := .T.
					cQry := ""
					cQry += " Select COUNT(*) AS COUNT
					cQry += " From sys.objects
					cQry += " Where type = 'U'
					cQry += " 	AND name like 'SD2"+ALLTRIM(aEmpresas[i][2])+"0'
					
					If Select("QRY") > 0
						QRY->(DbClosearea())
					Endif  
					
					dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
					
					lExistTab := QRY->COUNT <> 0
					
					//Executa caso tenha encontrado a Tabela SD2
					If lExistTab
						cQry := ""
						cQry += " Select Z2_TES,(Select MAX(D2_EMISSAO) 
						cQry += " From SD2"+ALLTRIM(aEmpresas[i][2])+"0 
						cQry += " Where D_E_L_E_T_ <> '*' 
						cQry += " 		AND D2_TES = Z2_TES) AS DATA
						cQry += " From SZ2YY0
						cQry += " Where D_E_L_E_T_ <> '*'
						cQry += " AND LEFT(Z2_EMPRESA,2) = '"+ALLTRIM(aEmpresas[i][2])+"'
				
						If Select("QRY") > 0
							QRY->(DbClosearea())
						Endif  
						
						dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
						QRY->(DbGoTop())
						While QRY->(!EOF())
							cData := IIF(EMPTY(QRY->DATA),"",DTOC(STOD(QRY->DATA)))
							aAdd(aRelatorio,{aEmpresas[i][1],aEmpresas[i][2],aEmpresas[i][3],QRY->Z2_TES,cData })
							QRY->(DbSkip())
						EndDo
					EndIf
				Else
 					Conout("GTFAT011 - Não foi possivel conexão ao Banco "+aAmb[nPos][2])
				EndIf
			EndIf
		EndIf
	Next i
	//Encerra as conexões caso exista.
	If nConAMB <> 0
		TCunLink(nConAMB)
		nConAMB := 0
	EndIf
EndIf

//
If Len(aRelatorio) <> 0
	SaveArq()
Else
	MsgAlert("Sem dados para exibição, verificar parametros!","HLB BRASIL")
EndIf


Return .T.

/*
Funcao      : SaveArq
Parametros  : Nil
Retorno     : Nil
Objetivos   : Geração do Arquivo Fisico.
Autor       : Jean Victor Rocha
Data/Hora   : 28/11/2014
*/
*-----------------------*
Static Function SaveArq()
*-----------------------*
Local nHdl
Local cXML 			:= ""
Private cDest 		:= GetTempPath()
Private cArq 		:= "TESxEmpresa.XLS"
Private nBytesSalvo := 0 

//Gera arquivo fisico. 
If FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 		:= FCREATE(cDest+cArq,0)	//Criação do Arquivo .
nBytesSalvo := FWRITE(nHdl, cXML ) 		// Gravação do seu Conteudo.
fclose(nHdl) 							// Fecha o Arquivo que foi Gerado	

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

cXML += '  <Worksheet ss:Name="TES X Emp.">
cXML += '   <Names>
cXML += '    <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=TES X Emp.!R4C1:R4C5" ss:Hidden="1"/>
cXML += '   </Names>
cXML += '   <Table ss:ExpandedColumnCount="5" ss:ExpandedRowCount="9999999" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXML += '    <Row ss:AutoFitHeight="0">
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s63"><Data ss:Type="String">HLB BRASIL.</Data></Cell>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:MergeAcross="4" ss:StyleID="s65"><Data ss:Type="String">Relat&oacute;rio de TES X Empresas</Data></Cell>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '     <Cell ss:StyleID="s62"/>
cXML += '    </Row>
cXML += '    <Row ss:AutoFitHeight="0" ss:Height="15.75">
cXML += '     <Cell ss:StyleID="s66"><Data ss:Type="String">Ambiente			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Cod.Empresa			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Nome Empresa		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">TES					</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '     <Cell ss:StyleID="s67"><Data ss:Type="String">Ultima Utilizacao	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXML += '    </Row>

For i:=1 to len(aRelatorio)
	cXML += ' 	   <Row ss:AutoFitHeight="0">
	cXML += ' 	    <Cell ss:StyleID="s69"><Data ss:Type="String">'+aRelatorio[i][1]+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+aRelatorio[i][2]+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+aRelatorio[i][3]+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+aRelatorio[i][4]+'</Data></Cell>
	cXML += ' 	    <Cell ss:StyleID="s70"><Data ss:Type="String">'+aRelatorio[i][5]+'</Data></Cell>
	cXML += ' 	   </Row>

	//Abre o Excel
	cXML := GrvXML(cXML)
Next i

cXML += '   </Table>
cXML += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXML += '    <Unsynced/>
cXML += '    <Selected/>
cXML += '    <ProtectObjects>False</ProtectObjects>
cXML += '    <ProtectScenarios>False</ProtectScenarios>
cXML += '   </WorksheetOptions>
cXML += '   <AutoFilter x:Range="R4C1:R4C5" xmlns="urn:schemas-microsoft-com:office:excel">
cXML += '   </AutoFilter>
cXML += '  </Worksheet>
cXML += ' </Workbook>

//Abre o Excel
cXML := GrvXML(cXML)

If nBytesSalvo >= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
Endif

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
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""