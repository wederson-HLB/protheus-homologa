#include 'totvs.ch'      
#include "TOPCONN.CH"

/*
Funcao      : ZJFAT002()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório com informações de Faturamento em Excel.
Autor       : Anderson Arrais

Cliente		: LINKEDIN  
Data	    : 06/04/2018
*/    

*-------------------------*
 User Function ZJFAT002() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "ZJFAT002"

Private cTitulo		:= "Relatório com informações de Faturamento"
Private lAbreExcel	:= .T.
Private cDataDe		:= ""  
Private cDataAte	:= ""  
Private cStatus		:= ""  
Private cNFde		:= ""  
Private cNFate		:= ""
Private cArq		:= GetTempPath()+"ZJFAT002.XLS"  

If cEmpAnt <> "ZJ"//Verifica se é a empresa LINKEDIN 
	MsgInfo("Este relatorio não esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cDataDe   	:= DtoS(mv_par01)
	cDataAte   	:= DtoS(mv_par02)
	cStatus		:= mv_par03
	cNFde		:= mv_par04
	cNFate		:= mv_par05
	
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
Autor   : Anderson Arrais
Data    : 10/04/2018
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
Data    : 03/05/2018
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela temporária
aAdd(aStru,{"Nfiscal","C",009,0})//Nota Fiscal
aAdd(aStru,{"Serie	","C",003,0})//Serie
aAdd(aStru,{"ValNF	","N",014,2})//Valor NF
aAdd(aStru,{"Emissao","D",008,0})//Emissao
aAdd(aStru,{"VencRea","D",008,0})//Vencimento boleto
aAdd(aStru,{"Agencia","C",030,0})//Agencia (customizado) 
aAdd(aStru,{"Campan ","C",200,0})//Campanha (customizado)
aAdd(aStru,{"ID 	","C",020,0})//ID (customizado)          
aAdd(aStru,{"PI		","C",080,0})//PI (customizado)
aAdd(aStru,{"NomeCli","C",060,0})//Nome Cliente         
aAdd(aStru,{"CGCCli ","C",014,0})//CNPJ Cliente           
aAdd(aStru,{"CODRSEF","C",015,0})//Grava se NF esta cancelada

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o índice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->NFISCAL+REL->SERIE",,,"Selecionando Registro...")


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
Local lRet  	:= .F.

//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := "SELECT F3.F3_NFISCAL,F3.F3_SERIE,F2.F2_VALBRUT,F2.F2_EMISSAO,F2.F2_DUPL,F3.F3_CODRSEF,F2.F2_CLIENTE,F2.F2_LOJA " + CRLF
cQry += "FROM " + RetSqlName("SF3")+" F3 INNER JOIN " + RetSqlName("SF2")+" F2 ON F2.F2_NFELETR=F3.F3_NFELETR" + CRLF
cQry += "WHERE  F2.F2_NFELETR<>'' AND F3.F3_NFELETR<>'' AND F3.D_E_L_E_T_='' AND F3.F3_NFISCAL BETWEEN '"+cNFde+"' AND '"+cNFate+"'" + CRLF
cQry += "AND F2.F2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' " + CRLF
If cStatus == 1
	cQry +=	"AND F3.F3_CODRSEF <> 'C'" + CRLF
ElseIf cStatus == 2
	cQry +=	"AND F3.F3_CODRSEF = 'C'" + CRLF
EndIf

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
	
		cVencRe := ""
		cDescCc	:= ""
		cDescVb	:= ""
		cAg		:= ""
		cCampa	:= ""
		cID		:= ""
		cPI  	:= ""
		cNomeC	:= ""
		cCGCC 	:= ""
		
       	//Financeiro
		SE1->(DbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1")+SQL->F3_SERIE+SQL->F2_DUPL))
			cVencRe := DtoS(SE1->E1_VENCREA)
       	EndIf
		
		//Pedido de venda	       	
		SD2->(DbSetOrder(3))
		If SD2->(DbSeek(xFilial("SD2")+SQL->F3_NFISCAL+SQL->F3_SERIE+SQL->F2_CLIENTE))
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
				cAg 	:= SC5->C5_P_AG
	       	    cCampa	:= SC5->C5_P_CAMPA
	       	    cID		:= SC5->C5_P_REF
	       	    cPI		:= SC5->C5_P_PI	       	
	       	EndIf
       	EndIf
       	
       	//Cliente
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
			cNomeC 	:= SA1->A1_NOME
			cCGCC	:= SA1->A1_CGC
       	EndIf

		//Grava o arquivo temporário.
		REL->(RecLock("REL",.T.))
				
		REL->NFISCAL	:= SQL->F3_NFISCAL
		REL->SERIE  	:= SQL->F3_SERIE
		REL->VALNF	 	:= SQL->F2_VALBRUT
		REL->EMISSAO	:= StoD(SQL->F2_EMISSAO)
		REL->VENCREA	:= StoD(cVencRe)
		REL->AGENCIA  	:= Alltrim(cAg)
		REL->CAMPAN		:= Alltrim(cCampa)
		REL->ID		  	:= Alltrim(cID)
		REL->PI			:= Alltrim(cPI)
		REL->NOMECLI	:= AllTrim(cNomeC)   	 	
		REL->CGCCLI		:= AllTrim(cCGCC)
		If !Alltrim(SQL->F3_CODRSEF) $ "C"
			REL->CODRSEF  := "EMITIDO"
		Else
			REL->CODRSEF  := "CANCELADO"
		EndIf
			        	
		REL->(MSUnlock())
					
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

//Cabeçalho das colunas do relatório
aTitCab1:= {'Nota Fiscal',;
			'Valor da Nota Fiscal',;
			'Data de Emissão',;
			'Data Vencimento Boleto',;
			'Agencia',;
			'Campanha',;
			'ID',;
			'PI',;
			'Nome do Cliente',;
			'CNPJ do Cliente',;
			'Status da Nota Fiscal'}
			
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
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NFISCAL)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((REL->VALNF),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+DToC(REL->EMISSAO)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+DToC(REL->VENCREA)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->AGENCIA)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CAMPAN)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->ID)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->PI)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->NOMECLI)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CGCCLI)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CODRSEF)+'</td>'
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
Local aSX1    := {	{"01","Da Emissao ?"  		  },;
  					{"02","Ate a Emissao ?"       },;
  					{"03","Considerar Status ?"   },;
  					{"04","Da Nota Fiscal ?" 	  },;
  					{"05","Ate a Nota Fiscal ?"   }} 
  					
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
	Aadd( aHlpPor, "Data de emissão de")
	PutSx1(cPerg,"01","Da Emissao?","Da Emissao?","Da Emissao?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","//","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
			
	aHlpPor := {}
	Aadd( aHlpPor, "Data de emissão ate")	
	PutSx1(cPerg,"02","Ate Emissao?","Ate Emissao?","Ate Emissao?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","//","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Considerar status da nota") 
	PutSx1(cPerg,"03","Status NF?","Status NF?","Status NF?","mv_ch5","N",01,0,01,"C","","","","S","mv_par05","Emitido","Emitido","Emitido","Emitido","Cancelado","Cancelado","Cancelado","Ambas","Ambas","Ambas","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Número inicial da nota fiscal")
	PutSx1(cPerg,"04","Nota Fiscal de?" ,"Nota Fiscal de?","Nota Fiscal de?","mv_ch3","C",09,0,0,"C","","","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

	aHlpPor := {}
	Aadd( aHlpPor, "Número final da nota fiscal")
	PutSx1(cPerg,"05","Nota Fiscal ate?" ,"Nota Fiscal ate?","Nota Fiscal ate?","mv_ch4","C",09,0,0,"C","","","","S","mv_par04","","","","ZZZZZZ","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil