#include 'totvs.ch'

/*
Funcao      : DSCTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relatório contábil).
Autor       : Renato Rezende
Cliente		: NBCU (JV)
Data/Hora   : 29/06/2016
*/    

*-------------------------*
 User Function DSCTB001() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "DSCTB001"

Private cTitulo		:= "Relatório GL FILE"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If cEmpAnt <> "DS"//Verifica se é a empresa JV 
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
	cArq		:= mv_par05
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
Autor   : Renato Rezende
Data    : 29/06/2016
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela temporária
aAdd(aStru,{"DataRD	","D",008,0})
aAdd(aStru,{"DataPC	","D",008,0})
aAdd(aStru,{"Mat	","C",007,0})
aAdd(aStru,{"DescVe	","C",020,0})
aAdd(aStru,{"DescAc	","C",060,0})
aAdd(aStru,{"Debit	","N",017,2})          
aAdd(aStru,{"Credit ","N",017,2})
aAdd(aStru,{"CC		","C",050,0})
aAdd(aStru,{"ItemC	","C",050,0})
aAdd(aStru,{"ClVl	","C",050,0})


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
Autor   : Renato Rezende
Data    : 29/06/2016
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cHist		:= ""
Local cDescAc	:= ""
Local cDescVe	:= ""
Local cDescCc	:= ""
Local cDescIt	:= ""
Local cDescVl	:= ""
Local cMatri	:= ""
Local lRet  	:= .F.

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
	
		cDescAc := ""
		cDescVe := ""
		cHist	:= ""
		cDescCc	:= ""
		cDescIt	:= ""
		cDescVl	:= ""
		cMatri	:= ""
		
		//Descrição da Verba
		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+SUBSTR(Alltrim(SQL->CT2_ORIGEM),1,3)))
			cDescVe := SRV->RV_DESC
	    EndIf
	    
		//Buscando matrícula do funcionário
		cHist := AllTrim(SQL->CT2_HIST)
		cMatri:= Alltrim(SUBSTR(cHist, AT("MAT:",cHist)+4, 6))
       	//Código cutomizado no cadastro do funcionário
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(xFilial("SRA")+cMatri))
			If SRA->(FieldPos("RA_P_MAT"))>0
				cMatri := SRA->RA_P_MAT
			Else
				cMatri := ""
			EndIf
		Else
			cMatri := "" 	
       	EndIf

		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"

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
	       	//Descrição do Item Contabil
			CTD->(DbSetOrder(1))
			If CTD->(DbSeek(xFilial("CTD")+SQL->CT2_ITEMD))
				cDescIt := CTD->CTD_DESC01
	       	EndIf
	       	//Descrição da Classe de Valor
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+SQL->CT2_CLVLDB))
				cDescVl := CTH->CTH_DESC01
	       	EndIf
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->MAT	:= Alltrim(cMatri)   	 	
			REL->DESCAC	:= AllTrim(SQL->CT2_DEBITO)+" "+AllTrim(cDescAc)
	        REL->DESCVE := AllTrim(cDescVe)
			REL->DEBIT  := SQL->CT2_VALOR
			REL->CREDIT := 0
			REL->CC		:= Alltrim(cDescCc)
			REL->ITEMC  := Alltrim(cDescIt)
			REL->CLVL	:= Alltrim(cDescVl)
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"

	       	//Descrição da Conta Contábil
			CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+SQL->CT2_CREDIT))
				cDescAc := CT1->CT1_DESC01
	       	EndIf
	       	//Descrição do Centro de Custo
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("CTT")+SQL->CT2_CCC))
				cDescCc := &("CTT->CTT_DESC01")
	       	EndIf
	       	//Descrição do Item Contabil
			CTD->(DbSetOrder(1))
			If CTD->(DbSeek(xFilial("CTD")+SQL->CT2_ITEMC))
				cDescIt := CTD->CTD_DESC01
	       	EndIf
	       	//Descrição da Classe de Valor
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+SQL->CT2_CLVLCR))
				cDescVl := CTH->CTH_DESC01
	       	EndIf			
			
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->MAT	:= Alltrim(cMatri)	 	
			REL->DESCAC	:= AllTrim(SQL->CT2_CREDIT)+" "+AllTrim(cDescAc)
	        REL->DESCVE := AllTrim(cDescVe)
			REL->DEBIT  := 0
			REL->CREDIT := SQL->CT2_VALOR
			REL->CC		:= Alltrim(cDescCc)
			REL->ITEMC  := Alltrim(cDescIt)
			REL->CLVL	:= Alltrim(cDescVl)
				
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
Data    : 27/10/2015
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
aTitCab1:= {'Employee ID',;
			'Gross to Net Element',;
			'GL ACCOUNT',;
			'AMOUNT DEBIT',;
			'AMOUNT CREDIT',;
			'Cost Center',;
			'Product',;
			'Region'}
			
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
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->MAT)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->DESCVE)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->DESCAC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((REL->DEBIT),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(TRANSFORM((REL->CREDIT),"@E 99,999,999,999.99"))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CC)+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->ITEMC)+'</td>' 
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(REL->CLVL)+'</td>'
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
Autor   : Renato Rezende
Data    : 29/06/2016
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
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\GTCTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
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
