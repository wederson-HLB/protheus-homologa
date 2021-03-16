#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"
/*
Funcao      : 49CTB001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório Brazil Template Balance Sheet (Portal do SQL Reposts)
Autor       : Renato Rezende 
Cliente		: Discovery
Data/Hora   : 23/01/2017
*/                          
*-------------------------*
 User Function 49CTB001()
*-------------------------*
Private titulo		:= "Relatório Brazil Template BS - Discovery"
Private cPerg		:= ""
Private cDest		:= ""
Private cArq		:= "Balance_Sheet_"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"
Private cQuery		:= ""
Private nBytesSalvo	:= 0 
Private nRecCount	:= 0

//Verificando se está na empresa Discovery
If !(cEmpAnt) $ "49"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "49CTB1"
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
Data     	: 23/01/2017
*/
*------------------------------*
 Static Function GeraTMP()
*------------------------------*
Local cPer0		:= ""
Local cCalendar	:= Alltrim(mv_par01)
Local cQuery2	:= ""
Local cQuery	:= ""
Local cMoedaRel	:= "" 

Local aResult	:= {}

//Carregar moeda
//CTE_FILIAL, CTE_MOEDA, CTE_CALEND, R_E_C_N_O_, D_E_L_E_T_ 
DbSelectArea("CTE")
CTE->(DbSetOrder(1))
If CTE->(DbSeek(xFilial("CTE")+"01"+Alltrim(mv_par01)))
	cMoedaRel:= "01"
ElseIf CTE->(DbSeek(xFilial("CTE")+"04"+Alltrim(mv_par01)))
	cMoedaRel:= "04" 
EndIf

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf

cPer0 := "(SELECT CTG_DTINI FROM "+RetSqlName("CTG")+" WHERE D_E_L_E_T_<>'*' AND CTG_CALEND="+cCalendar+" AND CTG_PERIOD='01')"
DbUseArea(.T., "TOPCONN",TCGENQRY(,,cPer0),'TMP',.F.,.T.) 
cPer0 := TMP->CTG_DTINI 
TMP->(DbCloseArea())

For nR:= 1 to 12
	cQuery2 := "(SELECT CTG_DTFIM FROM "+RetSqlName("CTG")+" WHERE D_E_L_E_T_<>'*' AND CTG_CALEND="+cCalendar+" 
	If nR >= 10
		cQuery2+= " AND CTG_PERIOD='"+Alltrim(cValToChar(nR))+"')"
	Else
		cQuery2+= " AND CTG_PERIOD='0"+Alltrim(cValToChar(nR))+"')"	
	EndIf
	DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery2),'TMP',.F.,.T.) 
	aadd(aResult,  TMP->CTG_DTFIM ) 
	TMP->(DbCloseArea())
Next nR

If Select('TMP')>0
	TMP->(DbCloseArea())
EndIf

//Início do Select
cQuery:= ""
cQuery+= " SELECT " + CRLF
cQuery+= " 	' ' AS [PRYOR_ACCOUNT], " + CRLF
cQuery+= " 	DISC_ACC, " + CRLF
cQuery+= " 	'307' AS [COMPANY_CODE], " + CRLF
cQuery+= " 	'9910' AS [BRAND], " + CRLF
cQuery+= " 	'120' AS [PLATFORM], " + CRLF
cQuery+= " 	'BR' AS [GEOGRAPHY], " + CRLF
cQuery+= " 	' ' AS [COST_CENTER], " + CRLF
cQuery+= "                 [PRJ], " + CRLF
cQuery+= " 	DESCRIPTION, " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<"+cPer0+" THEN VALUE ELSE 0 END) AS [PER_00A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='01' THEN VALUE ELSE 0 END) AS [PER_01], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[1]+" THEN VALUE ELSE 0 END) AS [PER_01A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='02' THEN VALUE ELSE 0 END) AS [PER_02], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[2]+" THEN VALUE ELSE 0 END) AS [PER_02A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='03' THEN VALUE ELSE 0 END) AS [PER_03], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[3]+" THEN VALUE ELSE 0 END) AS [PER_03A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='04' THEN VALUE ELSE 0 END) AS [PER_04], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[4]+" THEN VALUE ELSE 0 END) AS [PER_04A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='05' THEN VALUE ELSE 0 END) AS [PER_05], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[5]+" THEN VALUE ELSE 0 END) AS [PER_05A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='06' THEN VALUE ELSE 0 END) AS [PER_06], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[6]+" THEN VALUE ELSE 0 END) AS [PER_06A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='07' THEN VALUE ELSE 0 END) AS [PER_07], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[7]+" THEN VALUE ELSE 0 END) AS [PER_07A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='08' THEN VALUE ELSE 0 END) AS [PER_08], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[8]+" THEN VALUE ELSE 0 END) AS [PER_08A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='09' THEN VALUE ELSE 0 END) AS [PER_09], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[9]+" THEN VALUE ELSE 0 END) AS [PER_09A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='10' THEN VALUE ELSE 0 END) AS [PER_10], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[10]+" THEN VALUE ELSE 0 END) AS [PER_10A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='11' THEN VALUE ELSE 0 END) AS [PER_11], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[11]+" THEN VALUE ELSE 0 END) AS [PER_11A], " + CRLF
cQuery+= " 	-SUM(CASE WHEN CTG_PERIOD='12' THEN VALUE ELSE 0 END) AS [PER_12], " + CRLF
cQuery+= " 	-SUM(CASE WHEN DATE<="+aResult[12]+" THEN VALUE ELSE 0 END) AS [PER_12A] " + CRLF
cQuery+= " FROM " + CRLF
cQuery+= " 	( " + CRLF
cQuery+= " 		SELECT  " + CRLF
cQuery+= " 			CT2_DATA AS [DATE], " + CRLF
cQuery+= " 			CT2_DEBITO [PRYOR_ACCOUNT], " + CRLF
cQuery+= " 			CT1_GRUPO AS [DISC_ACC], " + CRLF
cQuery+= " 			CT2_CCD AS [COST_CENTER], " + CRLF
cQuery+= "          CT2_P_KEY AS [PRJ], " + CRLF
cQuery+= " 			-CT2_VALOR AS [VALUE], " + CRLF
cQuery+= " 			CT1_DESC04 AS [DESCRIPTION] " + CRLF
cQuery+= " 		FROM  " + CRLF
cQuery+= " 			"+RetSqlName("CT2")+"  " + CRLF
cQuery+= " 		LEFT OUTER JOIN " + CRLF
cQuery+= " 			"+RetSqlName("CT1")+" " + CRLF
cQuery+= " 		ON  " + CRLF
cQuery+= " 			CT2_DEBITO=CT1_CONTA " + CRLF
cQuery+= " 		WHERE " + CRLF 
cQuery+= " 			CT2490.D_E_L_E_T_<>'*' AND " + CRLF 
cQuery+= " 			CT1490.D_E_L_E_T_<>'*' AND " + CRLF 
cQuery+= " 			CT2_MOEDLC='"+cMoedaRel+"' AND " + CRLF
cQuery+= " 			LEFT(CT2_DEBITO,1) IN ('1','2') " + CRLF
cQuery+= CRLF
cQuery+= " 		UNION ALL " + CRLF
cQuery+= CRLF
cQuery+= " 		SELECT " + CRLF 
cQuery+= " 			CT2_DATA AS [DATE], " + CRLF
cQuery+= " 			CT2_CREDIT [PRYOR_ACCOUNT], " + CRLF
cQuery+= " 			CT1_GRUPO AS [DISC_ACC], " + CRLF
cQuery+= " 			CT2_CCC AS [COST_CENTER], " + CRLF
cQuery+= "          CT2_P_KEY AS [PRJ], " + CRLF
cQuery+= " 			CT2_VALOR AS [VALUE], " + CRLF
cQuery+= " 			CT1_DESC04 AS [DESCRIPTION] " + CRLF
cQuery+= " 		FROM " + CRLF 
cQuery+= " 			"+RetSqlName("CT2")+" " + CRLF 
cQuery+= " 		LEFT OUTER JOIN " + CRLF
cQuery+= " 			"+RetSqlName("CT1")+" " + CRLF
cQuery+= " 		ON  " + CRLF
cQuery+= " 			CT2_CREDIT=CT1_CONTA " + CRLF
cQuery+= " 		WHERE " + CRLF 
cQuery+= " 			CT2490.D_E_L_E_T_<>'*' AND " + CRLF 
cQuery+= " 			CT1490.D_E_L_E_T_<>'*' AND " + CRLF 
cQuery+= " 			CT2_MOEDLC='"+cMoedaRel+"' AND " + CRLF
cQuery+= " 			LEFT(CT2_CREDIT,1) IN ('1','2') AND " + CRLF
cQuery+= "          CT2490.R_E_C_N_O_<>'69453' " + CRLF
cQuery+= " 	) AS T1 " + CRLF
cQuery+= " LEFT OUTER JOIN " + CRLF
cQuery+= " 	( " + CRLF
cQuery+= " 		SELECT " + CRLF
cQuery+= " 			CTG_PERIOD, " + CRLF
cQuery+= " 			CTG_DTINI, " + CRLF
cQuery+= " 			CTG_DTFIM " + CRLF
cQuery+= " 		FROM " + CRLF
cQuery+= " 			"+RetSqlName("CTG")+" " + CRLF
cQuery+= " 		WHERE " + CRLF
cQuery+= " 			CTG490.D_E_L_E_T_<>'*' AND " + CRLF
cQuery+= " 			CTG490.CTG_CALEND="+cCalendar+" " + CRLF		
cQuery+= " 	) AS T2 " + CRLF
cQuery+= " ON  " + CRLF
cQuery+= " 	DATE>=CTG_DTINI AND " + CRLF 
cQuery+= " 	DATE<=CTG_DTFIM  " + CRLF
cQuery+= " GROUP BY " + CRLF
cQuery+= " 	DISC_ACC, " + CRLF
cQuery+= "                 PRJ, " + CRLF
cQuery+= " 	DESCRIPTION " + CRLF
cQuery+= " HAVING " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<"+cPer0+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='01' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[1]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='02' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[2]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='03' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[3]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='04' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[4]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='05' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[5]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='06' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[6]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='07' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[7]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='08' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[8]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='09' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[9]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='10' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[10]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='11' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[11]+" THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN CTG_PERIOD='12' THEN VALUE ELSE 0 END),2)<>0 OR " + CRLF
cQuery+= " 	ROUND(SUM(CASE WHEN DATE<="+aResult[12]+" THEN VALUE ELSE 0 END),2)<>0 " + CRLF
cQuery+= CRLF
cQuery+= " ORDER BY " + CRLF
cQuery+= " 	DISC_ACC, " + CRLF
cQuery+= " 	DESCRIPTION " + CRLF

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.) 

count to nRecCount

If nRecCount > 0 
	Processa({|| GeraHtm()},titulo)
Else
	If Select('TMP')>0               	
		TMP->(DbCloseArea())
	EndIf
	MsgInfo("Não há dados para o calendário selecionado!","HLB BRASIL")
EndIf

/*
Funcao      : GeraHtm
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Html gerado para relatório Analítico
Autor     	: Renato Rezende  	 	
Data     	: 23/01/2017
*/
*------------------------------*
 Static Function GeraHtm()
*------------------------------*
Local cHtml		:= ""
Local cAnoRel	:= Alltrim(SubStr(Alltrim(mv_par01),2,2))
Local nLin		:= 0

DbSelectArea("CTG")
CTG->(DbSetOrder(1))
CTG->(DbSeek(xFilial("CTG")+Alltrim(mv_par01)))

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.

cHtml+= '<?xml version="1.0" encoding="ISO-8859-1"?>'+ CRLF
cHtml+= '<?mso-application progid="Excel.Sheet"?>'+ CRLF
cHtml+= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'+ CRLF
cHtml+= ' <Styles>'+ CRLF
cHtml+= '  <Style ss:ID="Default" ss:Name="Normal">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat/>'+ CRLF
cHtml+= '   <Protection/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s21">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="13.95" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s22">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="13.95" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s23">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s24">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s25">'+ CRLF
cHtml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s26">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s27">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]#,##0"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s29">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s30">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s31">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders>'+ CRLF
cHtml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>'+ CRLF
cHtml+= '   </Borders>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]#,##0"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= '  <Style ss:ID="s35">'+ CRLF
cHtml+= '   <Alignment ss:Vertical="Top" ss:WrapText="1"/>'+ CRLF
cHtml+= '   <Borders/>'+ CRLF
cHtml+= '   <Font ss:FontName="Arial" x:CharSet="1" ss:Size="8" ss:Color="#000000"/>'+ CRLF
cHtml+= '   <Interior/>'+ CRLF
cHtml+= '   <NumberFormat ss:Format="[$-1010409]#,##0"/>'+ CRLF
cHtml+= '  </Style>'+ CRLF
cHtml+= ' </Styles>'+ CRLF
cHtml+= ' <Worksheet ss:Name="Brazil Template BS">'+ CRLF
//cHtml+= '  <Names>'
//cHtml+= '   <NamedRange ss:Name="Print_Titles" ss:RefersTo="='Brazil Template BS'!R1:R3"/>'
//cHtml+= '  </Names>'
cHtml+= '  <Table ss:ExpandedColumnCount="37" ss:ExpandedRowCount="99999999" x:FullColumns="1" x:FullRows="1">'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="50.25"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="54"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="45"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="36"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="21.75"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="23.25"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="54"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="30.75"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="32.25"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="63"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="242.25"/>'+ CRLF
cHtml+= '   <Column ss:AutoFitWidth="0" ss:Width="81" ss:Span="24"/>'+ CRLF
cHtml+= '   <Column ss:Index="37" ss:AutoFitWidth="0" ss:Width="0.75"/>'+ CRLF
cHtml+= '   <Row ss:AutoFitHeight="0" ss:Height="18">'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="4" ss:StyleID="s21"><Data ss:Type="String">BALANCE SHEET FY '+CTG->CTG_EXERC+'</Data><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF
cHtml+= '   <Row ss:AutoFitHeight="0" ss:Height="18">'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="7" ss:StyleID="s21"><Data ss:Type="String">DISCOVERY COMUNICAÇÕES DO BRASIL</Data><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF
cHtml+= '   <Row ss:AutoFitHeight="0" ss:Height="9">'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Titles"/></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF
cHtml+= '   <Row ss:Height="22.5">'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Pryor Acc</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Discovery Account</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Company</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Brand</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s23"><Data ss:Type="String">Platform</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Geography</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s23"><Data ss:Type="String">Cost Center</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Report Key</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">Description</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">December Closing</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">January Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of January '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">February Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of February '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">March Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of March '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">April Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of April '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">May Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of May '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">June Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of June '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">July Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of July '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">August Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of August '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">September Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of September '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">October Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of October '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">November Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">End of November '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s23"><Data ss:Type="String">December Activities '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s23"><Data ss:Type="String">End of December '+cAnoRel+'</Data></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF

TMP->(DbGoTop())

ProcRegua(nRecCount)

While TMP->(!Eof())
	IncProc()

	cHtml+= '   <Row>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s24"><Data ss:Type="String">'+Alltrim(TMP->PRYOR_ACCOUNT)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s25"><Data ss:Type="String">'+Alltrim(TMP->DISC_ACC)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s25"><Data ss:Type="String">'+Alltrim(TMP->COMPANY_CODE)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s25"><Data ss:Type="String">'+Alltrim(TMP->BRAND)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s25"><Data ss:Type="String">'+Alltrim(TMP->PLATFORM)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s25"><Data ss:Type="String">BR</Data>'+Alltrim(TMP->GEOGRAPHY)+'</Cell>'+ CRLF
	cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s25"><Data ss:Type="String">'+Alltrim(TMP->COST_CENTER)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s26"><Data ss:Type="String">'+Alltrim(TMP->PRJ)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s26"><Data ss:Type="String">'+Alltrim(TMP->DESCRIPTION)+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_00A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_01),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_01A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_02),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_02A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_03),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_03A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_04),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_04A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_05),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_05A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_06),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_06A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_07),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_07A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_08),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_08A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_09),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_09A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_10),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_10A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_11),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_11A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_12),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s35"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(TRANSFORM((TMP->PER_12A),"@R 999999999999.99"),",","."))+'</Data></Cell>'+ CRLF
	cHtml+= '   </Row>'+ CRLF	
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
	
	nLin+=1

	TMP->(DbSkip())
EndDo

//TOTAIS
cHtml+= '   <Row>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s29"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"/>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s30"><Data ss:Type="String">Total:</Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '    <Cell ss:MergeAcross="1" ss:StyleID="s31" ss:Formula="=+SUM(R[-'+cvaltochar(nLin)+']C:R[-1]C)"><Data ss:Type="Number"></Data></Cell>'+ CRLF
cHtml+= '   </Row>'+ CRLF
//FINAL DO TOTAIS
cHtml+= '   </Table>'+ CRLF
cHtml+= ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+ CRLF
cHtml+= '   <PageSetup>'+ CRLF
cHtml+= '    <Layout x:Orientation="Landscape"/>'+ CRLF
cHtml+= '    <Header x:Margin="1"/>'+ CRLF
cHtml+= '    <Footer x:Margin="1"/>'+ CRLF
cHtml+= '    <PageMargins x:Left="1" x:Right="1"/>'+ CRLF
cHtml+= '   </PageSetup>'+ CRLF
cHtml+= '   <NoSummaryRowsBelowDetail/>'+ CRLF
cHtml+= '   <NoSummaryColumnsRightDetail/>'+ CRLF
cHtml+= '   <Selected/>'+ CRLF
cHtml+= '   <DoNotDisplayGridlines/>'+ CRLF
cHtml+= '   <FreezePanes/>'+ CRLF
cHtml+= '   <SplitHorizontal>3</SplitHorizontal>'+ CRLF
cHtml+= '   <TopRowBottomPane>3</TopRowBottomPane>'+ CRLF
cHtml+= '   <ActivePane>2</ActivePane>'+ CRLF
cHtml+= '   <Panes>'+ CRLF
cHtml+= '    <Pane>'+ CRLF
cHtml+= '     <Number>3</Number>'+ CRLF
cHtml+= '    </Pane>'+ CRLF
cHtml+= '    <Pane>'+ CRLF
cHtml+= '     <Number>2</Number>'+ CRLF
cHtml+= '     <ActiveRow>6</ActiveRow>'+ CRLF
cHtml+= '     <ActiveCol>10</ActiveCol>'+ CRLF
cHtml+= '    </Pane>'+ CRLF
cHtml+= '   </Panes>'+ CRLF
cHtml+= '   <ProtectObjects>False</ProtectObjects>'+ CRLF
cHtml+= '   <ProtectScenarios>False</ProtectScenarios>'+ CRLF
cHtml+= '  </WorksheetOptions>'+ CRLF
cHtml+= ' </Worksheet>'+ CRLF
cHtml+= '</Workbook>'+ CRLF

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel. 

GeraExcel()
 
Return cHtml 

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 10/06/2014
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
Data     	: 10/06/2014
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
Data     	: 23/01/2017
*/
*-------------------------------*
 Static Function CriaPerg()
*-------------------------------*

U_PUTSX1(cPerg, "01", "Calendário ?",        "Calendário ?",        	"Calendário ?",         "mv_ch1","C",3,0,0, "G","","CTG",	"","","mv_par01","","","","","","","","","","","","","","","","",{"Digite o calendário contábil."},{},{},"")

Return 
