#include 'totvs.ch'

/*
Funcao      : JNCTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relatório contábil).
Autor       : Renato Rezende
Cliente		: Intuitive Surgical
Data/Hora   : 17/02/2017
*/    

*-------------------------*
 User Function JNCTB001() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "JNCTB001"

Private cTitulo		:= "Relatório GL FILE"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If cEmpAnt <> "JN"//Verifica se é a empresa Intuitive 
	MsgInfo("Este relatorio não esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cDataDe   	:= DtoS(mv_par01)
	cDataAte  	:= DtoS(mv_par02)
	cContaDe  	:= mv_par03
	cContaAte 	:= mv_par04
	cArq		:= Alltrim(mv_par05)+"GL_Intuitive"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".xls"
	lAbreExcel	:= If(mv_par06==2,.F.,.T.)
	cMoeda    	:= mv_par07
	
	//Gera o Relatório
	Processa({|| lOk := GeraRel()},"Gerando o relatório...")

	If !lOk
		MsgInfo("Não foram encontrados registros para os parâmetros informados.","Atenção")
		Return Nil
	EndIf

EndIf

Return Nil                           

/*
Função  : GeraRel
Retorno : lGrvDados
Objetivo: Gera o relatório
Autor   : Renato Rezende
Data    : 23/02/2017
*/
*--------------------------*
 Static Function GeraRel()
*--------------------------*
Local lGrvDados := .F.

Local cArqTrab := ""

//Cria a tabela temporária para impressão dos registros.
cArqTrab :=  GeraTMP()

//Grava os Dados na tabela temporária
If !Empty(cArqTrab)
	lGrvDados := TmpRel()
EndIf

If lGrvDados
	//Imprime o relatório
    ImpRel()
EndIf

Return lGrvDados

/*
Função  : GeraTMP
Retorno : cArqTrab 
Objetivo: Cria a tabela temporária que será utilizada para a impressão.
Autor   : Renato Rezende
Data    : 23/02/2017
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela temporária
aAdd(aStru,{"DataPC"	,"D",008,0})
aAdd(aStru,{"PK	"		,"C",002,0})//PK
aAdd(aStru,{"Conta"		,"C",020,0})//Conta
aAdd(aStru,{"Valor"		,"N",017,2})//Valor
aAdd(aStru,{"BArea"		,"C",010,0})//Branco
aAdd(aStru,{"CC"		,"C",050,0})//Centro de Custo
aAdd(aStru,{"ProfCtr"	,"C",010,0})//Branco
aAdd(aStru,{"IntOrder"	,"C",010,0})//Branco
aAdd(aStru,{"Assign"	,"C",030,0})//Payroll Brazil MM.YY
aAdd(aStru,{"Asset"		,"C",010,0})//Branco
aAdd(aStru,{"SubType"	,"C",010,0})//Branco
aAdd(aStru,{"Descri"	,"C",050,0})//Payroll Brazil MM.YY - Pay code name

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o índice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->CONTA",,,"Selecionando Registro...")

DbSelectArea("REL")
REL->(DbSetIndex(cIndex+OrdBagExt()))
REL->(DbSetOrder(1))

Return cArqTrab

/*
Função  : TmpRel
Retorno : lRet
Objetivo: Cria a tabela temporária que será utilizada para a impressão.
Autor   : Renato Rezende
Data    : 23/02/2017
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cDescVe	:= ""
Local lRet  	:= .F.
Local cAnoMes	:= ""

//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := "SELECT CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR, CT2_DATA, CT2_HIST, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_CCC, CT2_ITEMC, CT2_CLVLCR " + CRLF
cQry += "FROM " + RetSqlName("CT2")+" CT2 " + CRLF
cQry += "WHERE CT2.D_E_L_E_T_<>'*' AND CT2_ROTINA='GPEM110' AND CT2_DC <> '4' " + CRLF
cQry += "AND CT2.CT2_DATA BETWEEN '" + cDataDe +"' AND '" + cDataAte +"' " + CRLF
cQry +=	"AND CT2_MOEDLC = '"+cMoeda+"' " + CRLF
cQry +=	"AND ((CT2_DEBITO BETWEEN '" +cContaDe+"' AND '" +cContaAte+"') OR (CT2_CREDIT BETWEEN '" +cContaDe+"' AND '" +cContaAte+"'))" 
cQry += "ORDER BY CT2_DATA+CT2_DC" + CRLF

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "SQL", .F., .T.)

dbSelectArea("SQL")
ProcRegua(RecCount())
SQL->(dbGoTop())

//Caso o select retorno resultado
If SQL->(!Eof())
	//Retorno com registro
	lRet  := .T.
	Do While SQL->(!Eof())
		IncProc( "Preparando dados para Planilha..." )
	
		cDescVe := ""
		cAnoMes	:= SubStr(SQL->CT2_DATA,5,2)+"."+SubStr(SQL->CT2_DATA,3,2)
		
		//Descrição da Verba
		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+SUBSTR(Alltrim(SQL->CT2_ORIGEM),1,3)))
			cDescVe := SRV->RV_DESC
	    EndIf
	    
		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))

			REL->DataPC		:= StoD(SQL->CT2_DATA)
			REL->PK			:= "50"
			REL->Conta		:= SQL->CT2_DEBITO
			REL->Valor		:= SQL->CT2_VALOR
			REL->BArea		:= ""
			REL->CC			:= SQL->CT2_CCD
			REL->ProfCtr	:= ""
			REL->IntOrder	:= ""
			REL->Assign		:= "Payroll Brazil "+cAnoMes
			REL->Asset		:= ""
			REL->SubType	:= ""
			REL->Descri		:= Alltrim(SubStr("Payroll Brazil "+cAnoMes+" - "+AllTrim(cDescVe),1,50))
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"			
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DataPC		:= StoD(SQL->CT2_DATA)
			REL->PK			:= "40"
			REL->Conta		:= SQL->CT2_CREDIT
			REL->Valor		:= SQL->CT2_VALOR
			REL->BArea		:= ""
			REL->CC			:= SQL->CT2_CCC
			REL->ProfCtr	:= ""
			REL->IntOrder	:= ""
			REL->Assign		:= "Payroll Brazil "+cAnoMes
			REL->Asset		:= ""
			REL->SubType	:= ""
			REL->Descri		:= Alltrim(SubStr("Payroll Brazil "+cAnoMes+" - "+AllTrim(cDescVe),1,50))
				
			REL->(MSUnlock())
		
		Endif
		
		SQL->(dbSkip())
	
	EndDo
EndIf

SQL->(dbCloseArea())

Return lRet

/*
Funcao  : ImpRel()
Retorno : Nenhum
Objetivo: Imprime o relatório
Autor   : Renato Rezende
Data    : 23/02/2017
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local cXml		:= ""

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cXml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cXml	:= ""

cXml+= '<?xml version="1.0" encoding="ISO-8859-1"?>'+ CRLF
cXml+= '<?mso-application progid="Excel.Sheet"?>'+ CRLF
cXml+= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'+ CRLF

cXml+= ' <Styles>'+ CRLF
cXml+= '  <Style ss:ID="Default" ss:Name="Normal">'+ CRLF
cXml+= '   <Alignment ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Borders/>'+ CRLF
cXml+= '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+ CRLF
cXml+= '   <Interior/>'+ CRLF
cXml+= '   <NumberFormat/>'+ CRLF
cXml+= '   <Protection/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s76">'+ CRLF
cXml+= '   <Borders>'+ CRLF
cXml+= '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>'+ CRLF
cXml+= '   </Borders>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s74">'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Color="#000000"/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= ' </Styles>'+ CRLF
cXml+= ' <Worksheet ss:Name="Plan1">'+ CRLF
cXml+= '  <Table ss:ExpandedColumnCount="12" ss:ExpandedRowCount="99999999" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">'+ CRLF
cXml+= '   <Column ss:Index="2" ss:AutoFitWidth="0" ss:Width="70.5"/>'+ CRLF
cXml+= '   <Column ss:AutoFitWidth="0" ss:Width="102.75"/>'+ CRLF
cXml+= '   <Column ss:Width="40.5"/>'+ CRLF
cXml+= '   <Column ss:Width="45"/>'+ CRLF
cXml+= '   <Column ss:Width="47.25"/>'+ CRLF
cXml+= '   <Column ss:Width="50.25"/>'+ CRLF
cXml+= '   <Column ss:AutoFitWidth="0" ss:Width="187.5"/>'+ CRLF
cXml+= '   <Column ss:Width="59.25"/>'+ CRLF
cXml+= '   <Column ss:Width="50.25"/>'+ CRLF
cXml+= '   <Column ss:Width="87.75"/>'+ CRLF
cXml+= '   <Column ss:AutoFitWidth="0" ss:Width="180.75"/>'+ CRLF
cXml+= '   <Row ss:Height="15.75">'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">PK</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Account</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Amount</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">B. Area</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Cost Ctr.</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Prof. Ctr.</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Int. Order</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Assignment</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Asset (AUC)</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Sub Type</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Transaction Type</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s76"><Data ss:Type="String">Line Item Description</Data></Cell>'+ CRLF
cXml+= '   </Row>'+ CRLF

REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF())

	cXml+='   <Row ss:Height="12.75" ss:StyleID="s74">'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->PK+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->Conta+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+Alltrim(TRANSFORM((REL->Valor),"@E 99999999999,99"))+'</Data></Cell>'+ CRLF
    cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->BArea+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->CC+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->ProfCtr+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->IntOrder+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->Assign+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->Asset+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->SubType+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String"> </Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s74"><Data ss:Type="String">'+REL->Descri+'</Data></Cell>'+ CRLF
	cXml+='   </Row>'+ CRLF
	
	If LEN(cXml) >= 50000
		cXml := Grv(cXml) //Grava e limpa memoria da variavel.
	EndIf
		        
	REL->(DbSkip())
EndDo

cXml+= '  </Table>'+ CRLF
cXml+= ' </Worksheet>'+ CRLF
cXml+= '</Workbook>'+ CRLF



cXml := Grv(cXml) //Grava e limpa memoria da variavel.
	
//Abre o excel
GeraExcel()

Return

/*
Funcao      : Grv
Parametros  : cXml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cXml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 23/02/2017
*/
*------------------------------*
 Static Function Grv(cXml)
*------------------------------*
Local nHdl	:= Fopen(cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cXml )
fclose(nHdl)

Return ""

/*
Funcao  : GeraExcel()
Objetivo: Função para abrir o excel
Autor   : Renato Rezende
Data    : 23/02/2017
*/                   
*-------------------------------*
 Static Function GeraExcel()
*-------------------------------*

//Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	//Verifica se é para abrir o excel
	If lAbreExcel
		SHELLEXECUTE("open",(cArq),"","",5)   // Gera o arquivo em Excel ou Html
	EndIf
EndIf
 
REL->(DbSkip())
REL->(DbCloseArea())

Return

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 23/02/2017
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Data De ?"            },;
  					{"02","Data Ate ?"           },;
  					{"03","Da Conta ?"           },;
  					{"04","Ate Conta ?"          },;
  					{"05","Arquivo?"             },;
  					{"06","Abre Excel ?"         },;
  					{"07","Moeda ?"              }}
  					
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja o relatório.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatório.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final até a qual")
	Aadd( aHlpPor, "se desejá imprimir o relatório.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"será será gerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","!Vazio().or.(Mv_Par05:=cGetFile('Arquivos |*.*','',,,,176))","","","S","mv_par05","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo será aberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatório.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil
