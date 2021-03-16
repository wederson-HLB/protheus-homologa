#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"


/*
Funcao      : 49CTB005
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório Payroll (Relatório gerado na Rede HLB BRASIL)
Autor       : Renato Rezende 
Cliente		: Discovery
Data/Hora   : 03/04/2017
*/                          
*-------------------------*
 User Function 49CTB005()
*-------------------------*
Private titulo		:= "Relatório Payroll - Discovery"
Private cPerg		:= ""
Private cDest		:= ""
Private cArq		:= "Payroll_Report_"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"
Private cQuery		:= ""
Private nBytesSalvo	:= 0 
Private nRecCount	:= 0

//Verificando se está na empresa Discovery
If !(cEmpAnt) $ "49"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "49CTB5"
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
Data     	: 03/04/2017
*/
*------------------------------*
 Static Function GeraTMP()
*------------------------------*
Local cQuery	:= ""
Local cQuery2	:= ""
Local cDtInicial:= DtoS(mv_par01)
Local cDtFinal	:= DtoS(mv_par02)
Local cMoeda	:= mv_par03

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf

//Início do Select
cQuery:= " DECLARE @INICIO NCHAR(8) "+CRLF
cQuery+= " DECLARE @FIM NCHAR(8) "+CRLF
cQuery+= " DECLARE @MOEDA NCHAR(2) "+CRLF
cQuery+= " "+CRLF
cQuery+= " DECLARE @COLUNAS NVARCHAR(MAX) "+CRLF
cQuery+= " DECLARE @TEXTO AS NVARCHAR(MAX) "+CRLF
cQuery+= " "+CRLF
cQuery+= " set @INICIO = '"+cDtInicial+"' "+CRLF
cQuery+= " set @FIM = '"+cDtFinal+"' "+CRLF
cQuery+= " set @MOEDA = '"+mv_par03+"' "+CRLF
cQuery+= " "+CRLF
cQuery+= " CREATE TABLE #CONTAS (CONTA CHAR(9)) "+CRLF
cQuery+= " "+CRLF
cQuery+= " INSERT #CONTAS (CONTA) VALUES ('211230002'),('211310004'),('211310005'),('211310009'),('511120201'),('511120202'),('511120203'),('511120207'), "+CRLF
cQuery+= " ('511120208'),('511120209'),('511120210'),('511122223'),('511122224'),('511122225'),('511122227'),('511122228'),('511122229'),('511122230'), "+CRLF
cQuery+= " ('511124241'),('511124242'),('511124243'),('511124244'),('511124245'),('511124246'),('511120213'),('511120211'),('511120206'), "+CRLF
cQuery+= " ('511124248'),('511124249'),('511124250'),('511124251'),('511124252'),('511122226'),('511122231'),('511122232'),('511122233'), ('511120212'), ('211310017'), ('211310018'), ('211310019'), ('211310020'), ('211310021') "+CRLF
cQuery+= " "+CRLF
cQuery+= " SELECT "+CRLF
cQuery+= " 	RTRIM(CT2_DEBITO) AS [CT2_DEBITO], "+CRLF
cQuery+= " 	RTRIM(CT2_CREDIT) AS [CT2_CREDIT], "+CRLF
cQuery+= " 	RTRIM(CT2_CCD) AS [CT2_CCD], "+CRLF
cQuery+= " 	RTRIM(CT2_CCC) AS [CT2_CCC], "+CRLF
cQuery+= " 	CT2_DC, "+CRLF
cQuery+= " 	CT2_VALOR "+CRLF
cQuery+= " INTO "+CRLF
cQuery+= " 	#CT2 "+CRLF
cQuery+= " FROM "+CRLF
cQuery+= " 	CT2490 "+CRLF
cQuery+= " WHERE "+CRLF
cQuery+= " 	D_E_L_E_T_<>'*' AND "+CRLF
cQuery+= " 	CT2_TPSALD='1' AND "+CRLF
cQuery+= " 	CT2_DC IN ('1','2','3') AND "+CRLF
cQuery+= " 	CT2_DATA>=@INICIO AND "+CRLF
cQuery+= " 	CT2_DATA<=@FIM AND "+CRLF
cQuery+= " 	CT2_MOEDLC=@MOEDA AND "+CRLF
cQuery+= " 	CT2_VALOR<>0 "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SELECT "+CRLF
cQuery+= " 	CONTA, "+CRLF
cQuery+= " 	CENTRO, "+CRLF
cQuery+= " 	SUM(VALOR) AS [VALOR] "+CRLF
cQuery+= " INTO "+CRLF
cQuery+= " 	##RESUMO "+CRLF
cQuery+= " FROM "+CRLF
cQuery+= " 	( "+CRLF
cQuery+= " 		SELECT "+CRLF
cQuery+= " 			CT2_DEBITO AS [CONTA], "+CRLF
cQuery+= " 			CT2_CCD AS [CENTRO], "+CRLF
cQuery+= " 			-CT2_VALOR AS [VALOR] "+CRLF
cQuery+= " 		FROM "+CRLF
cQuery+= " 			#CT2 "+CRLF
cQuery+= " 		LEFT OUTER JOIN "+CRLF
cQuery+= " 			#CONTAS "+CRLF
cQuery+= " 		ON "+CRLF
cQuery+= " 			CT2_DEBITO=CONTA COLLATE Latin1_General_100_BIN "+CRLF
cQuery+= " 		WHERE "+CRLF
cQuery+= " 			CT2_DC IN ('1','3') AND "+CRLF
cQuery+= " 			CT2_DEBITO<>'' AND "+CRLF
cQuery+= " 			CONTA IS NOT NULL "+CRLF
cQuery+= "  "+CRLF
cQuery+= " 		UNION ALL "+CRLF
cQuery+= "  "+CRLF
cQuery+= " 		SELECT "+CRLF
cQuery+= " 			CT2_CREDIT AS [CONTA], "+CRLF
cQuery+= " 			CT2_CCC AS [CENTRO], "+CRLF
cQuery+= " 			CT2_VALOR AS [VALOR] "+CRLF
cQuery+= " 		FROM "+CRLF
cQuery+= " 			#CT2 "+CRLF
cQuery+= " 		LEFT OUTER JOIN "+CRLF
cQuery+= " 			#CONTAS "+CRLF
cQuery+= " 		ON "+CRLF
cQuery+= " 			CT2_CREDIT=CONTA COLLATE Latin1_General_100_BIN "+CRLF
cQuery+= " 		WHERE "+CRLF
cQuery+= " 			CT2_DC IN ('2','3') AND "+CRLF
cQuery+= " 			CT2_CREDIT<>'' AND "+CRLF
cQuery+= " 			CONTA IS NOT NULL "+CRLF
cQuery+= " 	) AS T1 "+CRLF
cQuery+= " GROUP BY "+CRLF
cQuery+= " 	CONTA, "+CRLF
cQuery+= " 	CENTRO "+CRLF
cQuery+= " ORDER BY "+CRLF
cQuery+= " 	CONTA, "+CRLF
cQuery+= " 	CENTRO "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SET @COLUNAS = N'' "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SELECT @COLUNAS += QUOTENAME([CONTA])+ N', ' FROM (SELECT [CONTA] FROM ##RESUMO GROUP BY CONTA) AS T1 "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SET @COLUNAS = LEFT(@COLUNAS, LEN(@COLUNAS)-1) "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SET @TEXTO= N'' "+CRLF
cQuery+= "  "+CRLF
cQuery+= " SET @TEXTO = ' "+CRLF
cQuery+= " 	SELECT "+CRLF
cQuery+= " 		CENTRO,  "+CRLF
cQuery+= " 		' + @COLUNAS +' "+CRLF
cQuery+= " 	FROM  "+CRLF
cQuery+= " 		(SELECT * FROM ##RESUMO) AS T1 "+CRLF
cQuery+= " 	PIVOT  "+CRLF
cQuery+= " 		(  "+CRLF
cQuery+= " 			SUM([VALOR])  "+CRLF
cQuery+= " 	FOR  "+CRLF
cQuery+= " 		[CONTA] IN (' + @COLUNAS + ')  "+CRLF
cQuery+= " 		) AS T2 "+CRLF
cQuery+= " 	ORDER BY "+CRLF
cQuery+= " 		CENTRO "+CRLF
cQuery+= " 			' "+CRLF
cQuery+= " "+CRLF 
cQuery+= " DROP TABLE #CONTAS "+CRLF
cQuery+= " DROP TABLE #CT2 "+CRLF

If TcSqlExec(cQuery)<0
	Alert("Ocorreu um problema na busca das informações!!")
	Return
Else
	//Query na tabela temporaria criada no TcSqlExec anterior
	cQuery2:= " SELECT CENTRO,  "+CRLF
	cQuery2+= " [211230002] AS C211230002, [211310004] AS C211310004, [211310005] AS C211310005, [211310009] AS C211310009, [511120201] AS C511120201, "+CRLF
	cQuery2+= " [511120202] AS C511120202, [511120203] AS C511120203, [511120207] AS C511120207, [511120208] AS C511120208, [511120209] AS C511120209, "+CRLF 
	cQuery2+= " [511120210] AS C511120210, [511122223] AS C511122223, [511122224] AS C511122224, [511122225] AS C511122225, [511122227] AS C511122227, "+CRLF 
	cQuery2+= " [511122228] AS C511122228, [511122229] AS C511122229, [511122230] AS C511122230, [511124241] AS C511124241, [511124242] AS C511124242, "+CRLF 
	cQuery2+= " [511124243] AS C511124243, [511124244] AS C511124244, [511124245] AS C511124245, [511124246] AS C511124246, [511120213] AS C511120213, "+CRLF
	cQuery2+= " [511120211] AS C511120211, [511120206] AS C511120206, [511124248] AS C511124248, [511124249] AS C511124249, [511124250] AS C511124250, "+CRLF
	cQuery2+= " [511124251] AS C511124251, [511124252] AS C511124252, [511122226] AS C511122226, [511122231] AS C511122231, [511122232] AS C511122232, "+CRLF 
	cQuery2+= " [511122233] AS C511122233, [511120212] AS C511120212, [211310017] AS C211310017, [211310018] AS C211310018, [211310019] AS C211310019, [211310020] AS C211310020, [211310021] AS C211310021 "+CRLF
	cQuery2+= "FROM "+CRLF
	cQuery2+= "	(SELECT * FROM ##RESUMO) AS T1 "+CRLF
	cQuery2+= "PIVOT  "+CRLF
	cQuery2+= "	(  "+CRLF
	cQuery2+= "		SUM([VALOR])  "+CRLF
	cQuery2+= "FOR  "+CRLF
	cQuery2+= "	[CONTA] IN ([211230002], [211310004], [211310005], [211310009], [511120201], [511120202], [511120203], [511120207], [511120208], [511120209], [511120210], [511122223], [511122224], [511122225], [511122227], [511122228], [511122229], [511122230], [511124241], [511124242], [511124243], [511124244], [511124245], [511124246], [511120213], [511120211], [511120206], [511124248], [511124249], [511124250], [511124251], [511124252], [511122226], [511122231], [511122232], [511122233], [511120212], [211310017], [211310018], [211310019], [211310020], [211310021]) "+CRLF
	cQuery2+= "	) AS T2 "+CRLF
	cQuery2+= "ORDER BY CENTRO "+CRLF
	
	DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery2),'TMP',.F.,.T.) 


	count to nRecCount
	
	If nRecCount > 0 
		Processa({|| GeraHtm()},titulo)
	Else
		If Select('TMP')>0               	
			TMP->(DbCloseArea())
		EndIf
		MsgInfo("Não há dados para a data selecionada!","HLB BRASIL")
	EndIf
	
	TcSqlExec('DROP TABLE ##RESUMO')
EndIf

/*
Funcao      : GeraHtm
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Xml gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 03/04/2017
*/
*------------------------------*
 Static Function GeraHtm()
*------------------------------*
Local cHtml		:= ""
Local nLin		:= 1

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

cHtml+= '<?xml version="1.0" encoding="ISO-8859-1"?>
cHtml+= CRLF +'<?mso-application progid="Excel.Sheet"?>
cHtml+= CRLF +'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">

cHtml+= CRLF +' <Styles>
cHtml+= CRLF +'  <Style ss:ID="Default" ss:Name="Normal">
cHtml+= CRLF +'   <Alignment ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'   <NumberFormat/>
cHtml+= CRLF +'   <Protection/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s18" ss:Name="Moeda">
cHtml+= CRLF +'   <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s62">
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s63">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s64">
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s66">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#000000" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s67">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s68">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s69">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s70">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>
cHtml+= CRLF +'   <Interior ss:Color="#D8E4BC" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s71">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#808080"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s72">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s73">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF"
cHtml+= CRLF +'    ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#002060" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s74">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#76933C" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s75">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#C4BD97" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s76">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#CC3300" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s78">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#60497A" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s79">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#CC0099" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s80">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#33CC33" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s81">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#E26B0A" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s82">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#808080" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s83">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s84">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFF00" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#002060" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s85">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s86">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'   <NumberFormat/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s88" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#C4D79B" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s89" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#DDD9C4" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s90" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#FF9933" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s91" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#8DB4E2" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s92" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#B1A0C7" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s93" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#FF66CC" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s94" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#66FF66" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s95" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#FABF8F" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s96" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s97" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior ss:Color="#FDE9D9" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s98" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s99">
cHtml+= CRLF +'   <Borders/>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#000000"/>
cHtml+= CRLF +'   <Interior/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s100" ss:Parent="s18">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#002060" ss:Pattern="Solid"/>
cHtml+= CRLF +'   <NumberFormat ss:Format="_(&quot;$&quot;\ * #,##0_);_(&quot;$&quot;\ * \(#,##0\);_(&quot;$&quot;\ * &quot;-&quot;??_);_(@_)"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s101">
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#002060" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +'  <Style ss:ID="s102">
cHtml+= CRLF +'   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cHtml+= CRLF +'   <Borders>
cHtml+= CRLF +'    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cHtml+= CRLF +'   </Borders>
cHtml+= CRLF +'   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Color="#FFFFFF" ss:Bold="1"/>
cHtml+= CRLF +'   <Interior ss:Color="#002060" ss:Pattern="Solid"/>
cHtml+= CRLF +'  </Style>
cHtml+= CRLF +' </Styles>

cHtml+= CRLF +' <Worksheet ss:Name="Payroll Report">
cHtml+= CRLF +'  <Table ss:StyleID="s62" ss:DefaultRowHeight="15">
cHtml+= CRLF +'   <Column ss:StyleID="s62" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="82.5" ss:Span="4"/>
cHtml+= CRLF +'   <Column ss:Index="6" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="7" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="8" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="9" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="10" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="11" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="12" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="13" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="14" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="15" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="16" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="17" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="18" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="19" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="20" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="21" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="22" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="23" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="24" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="25" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="26" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="27" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="28" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="29" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="30" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="31" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="32" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="33" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="34" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="35" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="36" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="37" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="38" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="39" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="40" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="41" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="42" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="43" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="44" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="45" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="46" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="47" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="48" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="49" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="50" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="51" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="52" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="53" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="54" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="55" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="56" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="57" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="58" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="59" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="60" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="61" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="62" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="63" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="64" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>
cHtml+= CRLF +'   <Column ss:Index="65" ss:StyleID="s62" ss:Width="65" ss:AutoFitWidth="0"/>

cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25">
cHtml+= CRLF +'    <Cell ss:Index="61" ss:StyleID="s62"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="12">
cHtml+= CRLF +'    <Cell ss:Index="2" ss:StyleID="s63"/>
cHtml+= CRLF +'    <Cell ss:Index="6" ss:StyleID="s66"><Data ss:Type="String" x:Ticked="1">DISCOVERY - MONTHLY PAYROLL '+UPPER(cMonth(mv_par02))+' '+Alltrim(Str(Year(mv_par01)))+'</Data></Cell>
cHtml+= CRLF +'    <Cell ss:Index="61" ss:StyleID="s62"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25">
cHtml+= CRLF +'    <Cell ss:Index="17" ss:StyleID="s67"/>
cHtml+= CRLF +'    <Cell ss:Index="54" ss:StyleID="s67"/>
cHtml+= CRLF +'    <Cell ss:Index="61" ss:StyleID="s62"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25" ss:StyleID="s63">
cHtml+= CRLF +'    <Cell ss:Index="3" ss:StyleID="s68"><Data ss:Type="String">ACCOUNTS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s68"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s68"><Data ss:Type="String">SAP ACCOUNTS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50010</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50110</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50110</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50115</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50340</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">53620</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">53660</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">53650</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50310</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50330</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50360</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21030</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21030</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">21030</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"><Data ss:Type="Number">50210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s69"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25" ss:StyleID="s63">
cHtml+= CRLF +'    <Cell ss:Index="3" ss:StyleID="s70"><Data ss:Type="String">ACCOUNTS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="String">LOCAL ACCOUNTS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120201</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120206</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120213</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124241</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124242</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120212</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120202</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120203</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120208</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122225</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122224</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122231</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122232</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122233</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122226</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122223</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122227</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122228</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120207</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120210</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120209</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122229</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511122230</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511120211</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211230002</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310004</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310005</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310009</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310017</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310018</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310019</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310020</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">211310021</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124243</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124244</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124245</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124246</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124248</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124249</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124250</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124251</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"><Data ss:Type="Number">511124252</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s70"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25" ss:StyleID="s71">
cHtml+= CRLF +'    <Cell ss:Index="32" ss:StyleID="s62"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="45" ss:StyleID="s72">
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">CONTRACT</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">ID</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">NAME</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">fingreso</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">DEPARTMENT</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">COST CENTER</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">SALARY</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">Special Bonus</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">TERMINATION COMPENSATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">13th SALARY</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">VACATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s74"><Data ss:Type="String">OTHER INDENIZATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s75"><Data ss:Type="String">BONUS ICP</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s75"><Data ss:Type="String">OTHER BONUS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s76"><Data ss:Type="String">OTHER BONUS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String" x:Ticked="1">+MEAL TICKETS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">SALARY COMPLEMENT</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">OCCUPATIONAL MEDICINE - PCMSO</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">GYM PASS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">CAR ALLOWANCE</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">MARKET VOUCHERS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String" x:Ticked="1">LIFE INSURANCE</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TRANSPORTATION - VT</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String" x:Ticked="1">OTHER BENEFITS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s78"><Data ss:Type="String">OTHER COMISSIONS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s79"><Data ss:Type="String">BONUS AD SALES</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s80"><Data ss:Type="String">BONUS AFFILIATES</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s81"><Data ss:Type="String">MEDICAL INSURANCE</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s82"><Data ss:Type="String">PENSION PLAN</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s83"><Data ss:Type="String">BONUS STELLAR</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TOTAL SALARY + BENEFITS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">IRRF - INCOME TAX</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">INSS TAX</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">FGTS - TAX</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">OTHER TAXES</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">BONUS TAXES ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">INSS ON VACATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">FGTS ON VACATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">INSS ON 13TH SALARY</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">FGTS ON 13TH SALARY</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">-APORTE VOLUNTARIO PENSION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">-FONDO DE SOLIDARIDAD PENSIONAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">-LIBRANZA COMPENSAR</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">-RETENCION EN LA FUENTE</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">-RETENCION MINIMA</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TOTAL DEDUCTIONS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TOTAL NET</Data></Cell>
cHtml+= CRLF +'    <Cell ss:Index="50" ss:StyleID="s73"><Data ss:Type="String">PAYROLL- ICP BONUS AND INSS</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">IDEMINTY FUND (FGTS)</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">ACCRUAL PAYROLL TAX ON VACATION</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">ACCRUAL PAYROLL TAX ON 13TH SALARY</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">INSS ON 13TH SALARY ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">FGTS ON 13TH SALARY ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">INSS ON VACATION ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">FGTS ON VACATION ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TAXES BONUS ACCRUAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">XGASTO SALUD</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TOTAL - SOCIAL SECURITY TAX</Data></Cell>
cHtml+= CRLF +'    <Cell ss:Index="62" ss:StyleID="s84"><Data ss:Type="String">XCAUSACION DE INTERES/CESANTIA</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">XCAUSACION DE PRIMA LEGAL</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s84"><Data ss:Type="String">XCAUSACION DE VACACIONES</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s73"><Data ss:Type="String">TOTAL CONSOLIDADOS</Data></Cell>
cHtml+= CRLF +'   </Row>

TMP->(DbGoTop())

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()

	cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25">
	cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s86"><Data ss:Type="String">'+TMP->CENTRO+'</Data></Cell>'//CENTRO DE CUSTO
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120201),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120201
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120206),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120206
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120213),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120213
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124241),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124241
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124242),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124242
	cHtml+= CRLF +'    <Cell ss:StyleID="s88"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120212),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120212
	cHtml+= CRLF +'    <Cell ss:StyleID="s89"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120202),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120202
	cHtml+= CRLF +'    <Cell ss:StyleID="s89"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120203),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120203
	cHtml+= CRLF +'    <Cell ss:StyleID="s90"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120208),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120208
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122225),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122225
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122224),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122224
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122231),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122231
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122232),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122232
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122233),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122233
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122226),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122226
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122223),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122223
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122227),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122227
	cHtml+= CRLF +'    <Cell ss:StyleID="s91"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122228),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122228
	cHtml+= CRLF +'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120207),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120207
	cHtml+= CRLF +'    <Cell ss:StyleID="s93"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120210),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120210
	cHtml+= CRLF +'    <Cell ss:StyleID="s94"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120209),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120209
	cHtml+= CRLF +'    <Cell ss:StyleID="s95"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122229),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122229
	cHtml+= CRLF +'    <Cell ss:StyleID="s96"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511122230),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511122230
	cHtml+= CRLF +'    <Cell ss:StyleID="s97"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511120211),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511120211
	cHtml+= CRLF +'    <Cell ss:StyleID="s98" ss:Formula="=SUM(RC[-24]:RC[-1])"><Data ss:Type="Number"></Data></Cell>
	cHtml+= CRLF +'    <Cell ss:StyleID="s99"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211230002),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211230002
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310004),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310004
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310005),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310005
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310009),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310009
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310017),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310017
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310018),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310018
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310019),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310019
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310020),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310020
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C211310021),"@R 999999999999.999"),",","."))+'</Data></Cell>'//211310021
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s98" ss:Formula="=SUM(RC[-14]:RC[-1])"><Data ss:Type="Number"></Data></Cell>
	cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=RC[-17]-RC[-1]"><Data ss:Type="Number"></Data></Cell>
	cHtml+= CRLF +'    <Cell ss:Index="50" ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124243),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124243
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124244),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124244
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124245),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124245
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124246),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124246
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124248),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124248
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124249),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124249
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124250),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124250
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124251),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124251
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->C511124252),"@R 999999999999.999"),",","."))+'</Data></Cell>'//511124252
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"><Data ss:Type="Number">0</Data></Cell>'//
	cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(RC[-10]:RC[-2])"><Data ss:Type="Number"></Data></Cell>'
	cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
	cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=RC[-34]"><Data ss:Type="Number"></Data></Cell>
	cHtml+= CRLF +'   </Row>
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
	
	nLin+=1

	TMP->(DbSkip())
EndDo

//TOTAIS
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25">
cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s85"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s86"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:Index="33" ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s100"/>
cHtml+= CRLF +'    <Cell ss:Index="50" ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s100"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s98"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s100"/>
cHtml+= CRLF +'   </Row>
cHtml+= CRLF +'   <Row ss:AutoFitHeight="0" ss:Height="11.25">
cHtml+= CRLF +'    <Cell ss:StyleID="s101"><Data ss:Type="String">Grand Total</Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s101"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s101"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s101"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s101"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s102"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:Index="33" ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:Index="50" ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s62"/>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'    <Cell ss:StyleID="s100" ss:Formula="=SUM(R[-'+cvaltochar(nLin)+']C:R[-2]C)"><Data ss:Type="Number"></Data></Cell>
cHtml+= CRLF +'   </Row>
//FINAL DO TOTAIS

cHtml+= CRLF +'  </Table>
cHtml+= CRLF +'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cHtml+= CRLF +'   <DoNotDisplayGridlines/>
cHtml+= CRLF +'   <FreezePanes/>
cHtml+= CRLF +'   <FrozenNoSplit/>
cHtml+= CRLF +'   <SplitHorizontal>6</SplitHorizontal>
cHtml+= CRLF +'   <TopRowBottomPane>6</TopRowBottomPane>
cHtml+= CRLF +'   <ActivePane>2</ActivePane>
cHtml+= CRLF +'   <Panes>
cHtml+= CRLF +'    <Pane>
cHtml+= CRLF +'     <Number>3</Number>
cHtml+= CRLF +'     <ActiveCol>5</ActiveCol>
cHtml+= CRLF +'    </Pane>
cHtml+= CRLF +'    <Pane>
cHtml+= CRLF +'     <Number>2</Number>
cHtml+= CRLF +'     <ActiveRow>0</ActiveRow>
cHtml+= CRLF +'     <ActiveCol>5</ActiveCol>
cHtml+= CRLF +'    </Pane>
cHtml+= CRLF +'   </Panes>
cHtml+= CRLF +'  </WorksheetOptions>
cHtml+= CRLF +' </Worksheet>
cHtml+= CRLF +'</Workbook>

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel. 

GeraExcel()
 
Return cHtml 

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 03/04/2017
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
Data     	: 03/04/2017
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
Data     	: 03/04/2017
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

aHlpPor := {}
Aadd( aHlpPor, "Informe a moeda desejada para este")
Aadd( aHlpPor, "relatório.")      
Aadd( aHlpPor, "Utilize <F3> para escolher.") 

U_PUTSX1(cPerg,"03","Moeda ?","Moeda ?","Moeda ?","mv_ch3","C",02,0,0,"G","","CTO","","S","mv_par03","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)


Return 
