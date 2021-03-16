#include 'totvs.ch'

/*
Funcao      : 68CTB002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relatório contábil) Excel.
Autor       : Anderson Arrais
Cliente		: ASCENSIA  
Data	    : 24/11/2016
*/    

*-------------------------*
 User Function 68CTB002() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "68CTB002"

Private cTitulo		:= "Relatório GL FILE"
Private cData		:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If cEmpAnt <> "68"//Verifica se é a empresa ASCENSIA 
	MsgInfo("Este relatorio não esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cData   	:= mv_par01
	cArq		:= mv_par02
	lAbreExcel	:= If(mv_par03==2,.F.,.T.)
	cMoeda    	:= mv_par04
	
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
Data    : 29/06/2016
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
Autor   : Anderson Arrais
Data    : 25/11/2016
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela temporária
aAdd(aStru,{"DataRD	","D",008,0})//Data base
aAdd(aStru,{"DataPC	","D",008,0})//Data CT2
aAdd(aStru,{"DataMe	","C",002,0})//Mes "MM"
aAdd(aStru,{"Pais	","C",002,0})//Pais "BR"
aAdd(aStru,{"NomeEmp","C",060,0})//Nome emp
aAdd(aStru,{"CliId	","C",004,0})//Cli ID 
aAdd(aStru,{"NomeSM0","C",060,0})//Nome SM0
aAdd(aStru,{"Moeda	","C",003,0})//Moeda "BRL"          
aAdd(aStru,{"Mat	","C",007,0})//Matricula
aAdd(aStru,{"Nome1Ra","C",060,0})//1 Nome SRA (primeiros)         
aAdd(aStru,{"Nome2Ra","C",060,0})//2 Nome SRA (apenas o ultimo)           
aAdd(aStru,{"Ct2DeC ","C",020,0})//CT2 debito ou credito      
aAdd(aStru,{"Ct1Desc","C",040,0})//CT1 descricao
aAdd(aStru,{"CCCeD	","C",009,0})//Centro Custo D e C
aAdd(aStru,{"CttDesc","C",040,0})//CTT descricao
aAdd(aStru,{"Ct2Ori ","C",100,0})//CT2 origem
aAdd(aStru,{"VerbaD ","C",020,0})//SRV descricao
aAdd(aStru,{"Credit ","N",017,2})//Valor Credt
aAdd(aStru,{"Debito ","N",017,2})//Valor Debit

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o índice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->MAT",,,"Selecionando Registro...")


DbSelectArea("REL")
REL->(DbSetIndex(cIndex+OrdBagExt()))
REL->(DbSetOrder(1))

Return cArqTrab

/*
Função  : TmpRel
Retorno : lRet
Objetivo: Cria a tabela temporária que será utilizada para a impressão.
Autor   : Anderson Arrais
Data    : 25/11/2016
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cHist		:= ""
Local cNomeRa	:= ""
Local cDescAc	:= ""
Local cDescCc	:= ""
Local cDescVb	:= ""
Local cMatri	:= ""
Local lRet  	:= .F.
Local cMesAno   := ""

//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cMesAno := cValToChar(SubStr(cData,3,4))+cValToChar(SubStr(cData,1,2))

cQry := "SELECT CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR, CT2_DATA, CT2_HIST, CT2_CCD, CT2_CCC " + CRLF
cQry += "FROM " + RetSqlName("CT2")+" CT2 " + CRLF
cQry += "WHERE CT2.D_E_L_E_T_<>'*' AND CT2_ROTINA='GPEM110' AND CT2_DC <> '4' " + CRLF
cQry += "AND CT2.CT2_DATA LIKE '" + cMesAno +"%' " + CRLF
cQry +=	"AND CT2_MOEDLC = '"+cMoeda+"' " + CRLF
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
	
		cNomeRa := ""
		cDescAc := ""
		cHist	:= ""
		cDescCc	:= ""
		cDescVb	:= ""
		cMatri	:= ""
	    
		//Buscando matrícula do funcionário
		cHist := AllTrim(SQL->CT2_HIST)
		cMatri:= Alltrim(SUBSTR(cHist, AT("MAT:",cHist)+4, 6))

		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"

	       	//Nome do funcionario
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(xFilial("SRA")+cMatri))
				cNomeRa := SRA->RA_NOME
	       	EndIf
			//Descrição da Conta Contábil	       	
			CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+SQL->CT2_DEBITO))
				cDescAc := CT1->CT1_DESC01
	       	EndIf
	       	//Descrição do Centro de Custo
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("CTT")+SQL->CT2_CCD))
				cDescCc := CTT->CTT_DESC01
	       	EndIf
	       	//Descrição da verba
			SRV->(DbSetOrder(1))
			If SRV->(DbSeek(xFilial("SRV")+SubStr(SQL->CT2_ORIGEM,1,3)))
				cDescVb := SRV->RV_DESC
	       	EndIf
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->DATAME := cValToChar(SubStr(cData,1,2))
			REL->PAIS	:= "BR"
			REL->NOMEEMP:= "Ascensia Diabetes Care Holdings AG"
			REL->CLIID  := "9078"
			REL->NOMESM0:= Alltrim(SM0->M0_NOMECOM)
			REL->MOEDA  := "BRL"
			REL->MAT	:= Alltrim(cMatri)
			REL->NOME1RA:= SubStr(AllTrim(cNomeRa),1,RAT(" ",AllTrim(cNomeRa))-1)   	 	
			REL->NOME2RA:= SubStr(AllTrim(cNomeRa),RAT(" ",AllTrim(cNomeRa))+1)
			REL->CT2DEC	:= AllTrim(SQL->CT2_DEBITO)
	        REL->CT1DESC:= AllTrim(cDescAc)
	        REL->CCCED  := AllTrim(SQL->CT2_CCD)
	        REL->CTTDESC:= AllTrim(cDescCc)
	        REL->CT2ORI := AllTrim(SQL->CT2_ORIGEM)
	        REL->VERBAD := AllTrim(cDescVb)
			REL->DEBITO := SQL->CT2_VALOR
			REL->CREDIT := 0
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"

	       	//Nome do funcionario
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(xFilial("SRA")+cMatri))
				cNomeRa := SRA->RA_NOME
	       	EndIf
			//Descrição da Conta Contábil	       	
			CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+SQL->CT2_CREDIT))
				cDescAc := CT1->CT1_DESC01
	       	EndIf
	       	//Descrição do Centro de Custo
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("CTT")+SQL->CT2_CCC))
				cDescCc := CTT->CTT_DESC01
	       	EndIf
	       	//Descrição da verba
			SRV->(DbSetOrder(1))
			If SRV->(DbSeek(xFilial("SRV")+SubStr(SQL->CT2_ORIGEM,1,3)))
				cDescVb := SRV->RV_DESC
	       	EndIf
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->DATAME := cValToChar(SubStr(cData,1,2))
			REL->PAIS	:= "BR"
			REL->NOMEEMP:= "Ascensia Diabetes Care Holdings AG"
			REL->CLIID  := "9078"
			REL->NOMESM0:= Alltrim(SM0->M0_NOMECOM)
			REL->MOEDA  := "BRL"
			REL->MAT	:= Alltrim(cMatri)
			REL->NOME1RA:= SubStr(AllTrim(cNomeRa),1,RAT(" ",AllTrim(cNomeRa))-1)   	 	
			REL->NOME2RA:= SubStr(AllTrim(cNomeRa),RAT(" ",AllTrim(cNomeRa))+1)
			REL->CT2DEC	:= AllTrim(SQL->CT2_CREDIT)
	        REL->CT1DESC:= AllTrim(cDescAc)
	        REL->CCCED  := AllTrim(SQL->CT2_CCC)
	        REL->CTTDESC:= AllTrim(cDescCc)
	        REL->CT2ORI := AllTrim(SQL->CT2_ORIGEM)
	        REL->VERBAD := AllTrim(cDescVb)
			REL->DEBITO := 0
			REL->CREDIT := SQL->CT2_VALOR
				
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
Autor   : Anderson Arrais
Data    : 25/11/2016
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local cHtml		:= ""
Local cLinha	:= ""
Local aTitCab	:= ""
Local lCor		:= .T.

//Para não causar estouro de variavel.
nHdl		:= FCREATE(cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""
aTitCab	:= ""

//Cabeçalho das colunas do relatório
aTitCab1:= {'Report Date',;
			'Pay Cycle',;
			'Payroll Month',;
			'Country Code',;
			'Company Name',;
			'Entity ID',;
			'Entity Name',;
			'Currency',;
			'Payroll Employee ID',;
			'First Name',;
			'Last Name',;
			'GL Account',;
			'GL Description',;
			'Cost Center Code',;
			'Cost Center Description',;
			'Pay Code',;
			'Pay Element Description',;
			'Amount Debit',;
			'Amount Credit'}
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha 
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para não quebrar a linha
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeçalho no relatório
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF()) 

	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor

	cHtml+='		<tr>'             
	cHtml+='			<td class="'+cLinha+'">'+DToC(REL->DATARD)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+DToC(REL->DATAPC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">="'+Alltrim(REL->DATAME)+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->PAIS)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NOMEEMP)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CLIID)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NOMESM0)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->MOEDA)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->MAT)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NOME1RA)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NOME2RA)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CT2DEC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CT1DESC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CCCED)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CTTDESC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CT2ORI)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->VERBAD)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((REL->CREDIT),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((REL->DEBITO),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='		</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
		        
	REL->(DbSkip())
EndDo

cHtml+='		</tr>'
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	
//Abre o excel
GeraExcel()

Return

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 05/04/2016
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl	:= Fopen(cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

/*
Funcao  : GeraExcel()
Objetivo: Função para abrir o excel
Autor   : Renato Rezende
Data    : 05/04/2016
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
Autor   : Anderson Arrais
Data    : 25/11/2016
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Mes e Ano(MMAAAA)?"   },;
  					{"02","Arquivo?"             },;
  					{"03","Abre Excel ?"         },;
  					{"04","Moeda ?"              }} 
  					
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
	Aadd( aHlpPor, "Informe a Data para gerar o arquivo")
	
	U_PUTSX1(cPerg,"01","Mes e Ano(MMAAAA)?","Mes e Ano(MMAAAA)?","Mes e Ano(MMAAAA)?","mv_ch1","C",06,0,0,"G","","","","S","mv_par01","","","","092016","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
			
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"será será gerado.")
	
	U_PUTSX1(cPerg,"02","Arquivo?","Arquivo ?","Arquivo ?","mv_ch2","C",60,0,0,"G","","","","S","mv_par02","","","","D:\GTCTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo será aberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"03","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch3","N",01,0,1,"C","","","","S","mv_par03","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatório.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"04","Moeda ?","Moeda ?","Moeda ?","mv_ch4","C",02,0,0,"G","","CTO","","S","mv_par04","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil
