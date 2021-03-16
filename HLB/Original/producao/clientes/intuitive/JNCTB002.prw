#include 'totvs.ch'

/*
Funcao      : JNCTB002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relatório contábil).
Autor       : Renato Rezende
Cliente		: Intuitive Surgical
Data/Hora   : 17/02/2017
*/    

*-------------------------*
 User Function JNCTB002() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "JNCTB002"

Private cTitulo		:= "Relatório GL FILE V2.0"
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
	cArq		:= Alltrim(mv_par05)+"GL_Intuitive"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+"_V2.0.xls"
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
aAdd(aStru,{"DataPC"	,"D",008,0})//DATA
aAdd(aStru,{"Entry"		,"C",006,0})//Entry
aAdd(aStru,{"Account"	,"C",010,0})//Conta
aAdd(aStru,{"AccHolder"	,"C",010,0})//Conta Holder
aAdd(aStru,{"CGC"		,"C",014,0})//CNPJ/CPF
aAdd(aStru,{"EmpName"	,"C",014,0})//Company Name
aAdd(aStru,{"CC"		,"C",010,0})//Centro de Custo
aAdd(aStru,{"ProRata"	,"C",010,0})//Pro Rata Criteria
aAdd(aStru,{"Valor"		,"N",017,2})//Valor
aAdd(aStru,{"DebCred"	,"C",001,0})//Deb/Cred
aAdd(aStru,{"Reference"	,"C",060,0})//Historico

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o índice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->Account",,,"Selecionando Registro...")

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

cQry := "SELECT CT2_SEQUEN, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR, CT2_DATA, CT2_HIST, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_CCC, CT2_ITEMC, CT2_CLVLCR " + CRLF
cQry += "FROM " + RetSqlName("CT2")+" CT2 " + CRLF
cQry += "WHERE CT2.D_E_L_E_T_<>'*' AND CT2_ROTINA='GPEM110' AND CT2_DC <> '4' " + CRLF
cQry += "AND CT2.CT2_DATA BETWEEN '" + cDataDe +"' AND '" + cDataAte +"' " + CRLF
cQry +=	"AND CT2_MOEDLC = '"+cMoeda+"' " + CRLF
cQry +=	"AND ((CT2_DEBITO BETWEEN '" +cContaDe+"' AND '" +cContaAte+"') OR (CT2_CREDIT BETWEEN '" +cContaDe+"' AND '" +cContaAte+"'))" 
cQry +=	"AND ((CT2_FILIAL BETWEEN '" +mv_par08+"' AND '" +mv_par09+"'))" + CRLF
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
		cAnoMes	:= SubStr(SQL->CT2_DATA,5,2)+"/"+SubStr(SQL->CT2_DATA,3,2)
		
		//Descrição da Verba
		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+SUBSTR(Alltrim(SQL->CT2_ORIGEM),1,3)))
			cDescVe := SRV->RV_DESC
	    EndIf
	    
		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
			
			REL->DataPC		:= StoD(SQL->CT2_DATA)
			REL->Entry		:= "30000"//SubStr(SQL->CT2_SEQUEN,5,6)
			REL->Account	:= SQL->CT2_DEBITO
			REL->AccHolder	:= ""
			REL->CGC		:= ""
			REL->EmpName	:= ""
			REL->CC			:= SQL->CT2_CCD
			REL->ProRata	:= ""
			REL->Valor		:= SQL->CT2_VALOR
			REL->DebCred	:= "D"
			REL->Reference	:= Alltrim(SubStr(AllTrim(cDescVe)+" REF. "+cAnoMes,1,60))
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"			
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
			
			REL->DataPC		:= StoD(SQL->CT2_DATA)
			REL->Entry		:= "30000"//SubStr(SQL->CT2_SEQUEN,5,6)
			REL->Account	:= SQL->CT2_CREDIT
			REL->AccHolder	:= ""
			REL->CGC		:= ""
			REL->EmpName	:= ""
			REL->CC			:= SQL->CT2_CCC
			REL->ProRata	:= ""
			REL->Valor		:= SQL->CT2_VALOR
			REL->DebCred	:= "C"
			REL->Reference	:= Alltrim(SubStr(AllTrim(cDescVe)+" REF. "+cAnoMes,1,60))			
				
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
cXml+= '   <Font ss:FontName="Arial"/>'+ CRLF
cXml+= '   <Interior/>'+ CRLF
cXml+= '   <NumberFormat/>'+ CRLF
cXml+= '   <Protection/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s22">'+ CRLF
cXml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8" ss:Bold="1"/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s26">'+ CRLF
cXml+= '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s27">'+ CRLF
cXml+= '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>'+ CRLF
cXml+= '   <NumberFormat ss:Format="[$-1010409]#,##0.00;\-#,##0.00"/>'+ CRLF
cXml+= '  </Style>'+ CRLF 
cXml+= '  <Style ss:ID="s28">'+ CRLF
cXml+= '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>'+ CRLF
cXml+= '  </Style>'+ CRLF
cXml+= '  <Style ss:ID="s29">'+ CRLF
cXml+= '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>'+ CRLF
cXml+= '   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="8"/>'+ CRLF
cXml+= '  </Style>'+ CRLF 
cXml+= ' </Styles>'+ CRLF 

cXml+= ' <Worksheet ss:Name="Intuitive">'+ CRLF
cXml+= '   <Table ss:ExpandedColumnCount="11" ss:ExpandedRowCount="99999999" x:FullColumns="1" x:FullRows="1" ss:StyleID="s22" ss:DefaultRowHeight="11.25">'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="116.25"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:AutoFitWidth="0" ss:Width="66.75"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="134.25"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="66"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="120"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="108"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="82.5" ss:Span="1"/>'+ CRLF
cXml+= '   <Column ss:Index="9" ss:StyleID="s22" ss:Width="101.25"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="66"/>'+ CRLF
cXml+= '   <Column ss:StyleID="s22" ss:Width="180"/>'+ CRLF

cXml+= '   <Row>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Date</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Entry</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Account</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Account Holder</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">CPF/CNPJ Tax ID</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Company Name</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Cost Center</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Pro Rata Criteria</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String"> Value </Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">DEB/CRED</Data></Cell>'+ CRLF
cXml+= '    <Cell ss:StyleID="s22"><Data ss:Type="String">Reference</Data></Cell>'+ CRLF
cXml+= '   </Row>'+ CRLF

REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF())

	cXml+='   <Row>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+DtoC(REL->DataPC)+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+REL->Entry+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+Alltrim(REL->Account)+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+REL->AccHolder+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+REL->CGC+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+REL->EmpName+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+Alltrim(REL->CC)+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s29"><Data ss:Type="String">'+REL->ProRata+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s27"><Data ss:Type="Number">'+Alltrim(TRANSFORM((REL->Valor),"@R 99999999999.99"))+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s26"><Data ss:Type="String">'+REL->DebCred+'</Data></Cell>'+ CRLF
	cXml+='    <Cell ss:StyleID="s28"><Data ss:Type="String">'+Alltrim(REL->Reference)+'</Data></Cell>'+ CRLF
	cXml+='   </Row>
	
	If LEN(cXml) >= 50000
		cXml := Grv(cXml) //Grava e limpa memoria da variavel.
	EndIf
		        
	REL->(DbSkip())
EndDo

cXml+= '  </Table>'+ CRLF
cXml+= '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+ CRLF
cXml+= '   <DoNotDisplayGridlines/>'+ CRLF
cXml+= '  </WorksheetOptions>'+ CRLF
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
  					{"07","Moeda ?"              },;
  					{"08","Da Filial ?"          },;
 					{"09","Ate Filial ?"         }}
  					
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

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Filial Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatório.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as filiais,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"08","Da Filial ?","Da Filial ?","Da Filial ?","mv_ch8","C",02,0,0,"G","","SM0","","S","mv_par08","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a filiais Final até a qual")
	Aadd( aHlpPor, "se desejá imprimir o relatório.")
	Aadd( aHlpPor, "Caso queira imprimir todas as filiais ")
	Aadd( aHlpPor, "preencha este campo com 'ZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"09","Ate Filial ?","Ate Filial ?","Ate Filial ?","mv_ch9","C",02,0,0,"G","","SM0","","S","mv_par09","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	
EndIf
	
Return Nil
