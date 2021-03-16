#include 'totvs.ch'

/*
Funcao      : F1CTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relat�rio cont�bil).
Autor       : Renato Rezende
Cliente		: NBCU (INGRESSO.COM)
Data/Hora   : 04/07/2016
*/    

*-------------------------*
 User Function F1CTB001() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "F1CTB001"

Private cTitulo		:= "Relat�rio GL FILE"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If cEmpAnt <> "F1"//Verifica se � a empresa Ingresso.com 
	MsgInfo("Este relatorio n�o esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os par�metros do relat�rio
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os par�metros
	cDataDe   	:= DtoS(mv_par01)
	cDataAte  	:= DtoS(mv_par02)
	cContaDe  	:= mv_par03
	cContaAte 	:= mv_par04
	cArq		:= mv_par05
	lAbreExcel	:= If(mv_par06==2,.F.,.T.)
	cMoeda    	:= mv_par07
	
	//Gera o Relat�rio
	Processa({|| lOk := GeraRel()},"Gerando o relat�rio...")

	If !lOk
		MsgInfo("N�o foram encontrados registros para os par�metros informados.","Aten��o")
		Return Nil
	EndIf          	

EndIf

Return Nil                           

/*
Fun��o  : GeraRel
Retorno : lGrvDados
Objetivo: Gera o relat�rio
Autor   : Renato Rezende
Data    : 29/06/2016
*/
*--------------------------*
 Static Function GeraRel()
*--------------------------*
Local lGrvDados := .F.

Local cArqTrab := ""

//Cria a tabela tempor�ria para impress�o dos registros.
cArqTrab :=  GeraTMP()

//Grava os Dados na tabela tempor�ria
If !Empty(cArqTrab)
	lGrvDados := TmpRel()
EndIf

If lGrvDados
	//Imprime o relat�rio
    ImpRel()
EndIf

Return lGrvDados

/*
Fun��o  : GeraTMP
Retorno : cArqTrab 
Objetivo: Cria a tabela tempor�ria que ser� utilizada para a impress�o.
Autor   : Renato Rezende
Data    : 29/06/2016
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela tempor�ria
aAdd(aStru,{"DataRD	","D",008,0})
aAdd(aStru,{"DataPC	","D",008,0})
aAdd(aStru,{"Conta	","C",060,0})
aAdd(aStru,{"Debit	","N",017,2})          
aAdd(aStru,{"Credit ","N",017,2})
aAdd(aStru,{"CC		","C",010,0})
aAdd(aStru,{"Hist	","C",050,0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o �ndice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->DATAPC",,,"Selecionando Registro...")


DbSelectArea("REL")
REL->(DbSetIndex(cIndex+OrdBagExt()))
REL->(DbSetOrder(1))

Return cArqTrab

/*
Fun��o  : TmpRel
Retorno : lRet
Objetivo: Cria a tabela tempor�ria que ser� utilizada para a impress�o.
Autor   : Renato Rezende
Data    : 29/06/2016
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cHist		:= ""
Local cDescCc	:= ""
Local lRet  	:= .F.

//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := "SELECT CT2_FILIAL,CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR, CT2_DATA, CT2_HIST, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_CCC, CT2_ITEMC, CT2_CLVLCR " + CRLF
cQry += "FROM " + RetSqlName("CT2")+" CT2 " + CRLF
cQry += "WHERE CT2.D_E_L_E_T_<>'*' AND CT2_ROTINA='GPEM110' AND CT2_DC <> '4' " + CRLF
cQry += "AND CT2.CT2_FILIAL = '" + xFilial("CT2") +"' "+ CRLF
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

		cHist	:= ""
		cDescCc	:= ""
	    
		//Hist�rico
		cHist := AllTrim(SQL->CT2_HIST)

		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"

	       	//Descri��o do Centro de Custo
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("CTT")+SQL->CT2_CCD))
				cDescCc := CTT->CTT_DESC01
	       	EndIf
			
			//Grava o arquivo tempor�rio.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA) 	 	
			REL->CONTA	:= AllTrim(SQL->CT2_DEBITO)
			REL->DEBIT  := SQL->CT2_VALOR
			REL->CREDIT := 0
			REL->CC		:= Alltrim(SQL->CT2_CCD)
			REL->HIST	:= Alltrim(cHist)
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"

	       	//Descri��o do Centro de Custo
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("CTT")+SQL->CT2_CCC))
				cDescCc := &("CTT->CTT_DESC01")
	       	EndIf			
			
			//Grava o arquivo tempor�rio.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->CONTA	:= AllTrim(SQL->CT2_CREDIT)
			REL->DEBIT  := 0
			REL->CREDIT := SQL->CT2_VALOR
			REL->CC		:= Alltrim(SQL->CT2_CCC)
			REL->HIST	:= Alltrim(cHist)
				
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
Objetivo: Imprime o relat�rio
Autor   : Renato Rezende
Data    : 27/10/2015
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local cHtml		:= ""
Local aCabec1	:= {"Posting","Acccount","New Company","Cost","WBS","Internal","Profit","","Territory","Territory","Line Item","Market","User","User","User","User ","User ","Primary","Secondary","Third","Fourth","Set","System","Accounting","Source ","Original ","Reference","Sales","Sales","Alt Sales","Location","Source System","Source System","Source System","Source System","Reference","User","User","User","User","User","Labor","Union","Pay GL","Employee","Job","Earnings","","Long Text for","Settlement","Original","LOCAL CURR","GROUP CURR","Unit of","Material","Plant","Trading","Partner"}
Local aCabec2	:= {"Key","Number","Code","Center","Element","Order","Center","Amount","Type","Code","Text","Code","Field 1","Field 2","Field 3","Field 4","Field 5","Ref Field","Ref Field ","Ref Field","Ref Field","Number","Source Code","Source Code","Batch Number","Account","Company","Person","Type","Region","","Vendor","Customer","Refernece","Invoice","Account","Date 1","Date 2","Date 3","Date 4","Date 5","Department","Code","Type","ID","Code","Code","Quantity","Document Line Item","Status","Sender","Local Curr","Group Curr","Measure","","","Partner","Profit Ctr"}
Local nDebito	:= 0
Local nCredito	:= 0


//Para n�o causar estouro de variavel.
nHdl		:= FCREATE(cArq,0 )  //Cria��o do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Grava��o do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""

//Incluindo o cabe�alho no relat�rio
cHtml+='<table border="0" cellpadding="0" cellspacing="0" style="width:4261px;" width="4251">'
cHtml+='	<tr height="20">'
//Inclus�o da numera��o de 1 a 58
For nB := 1 to 58
	cHtml+='		<td align="right">'+Alltrim(Str(nB))+'</td>'
Next nB
cHtml+='	</tr>'
cHtml+='	<tr height="20">'
//Preenchendo a primeira linha do cabe�alho
For nC := 1 to Len(aCabec1)
	cHtml+='		<td height="20" style="height:20px;">'+aCabec1[nC]+'</td>'
Next nC
cHtml+='	</tr>'
cHtml+='	<tr height="20">' 
//Preenchendo a segunda linha do cabe�alho
For nD := 1 to Len(aCabec2)
	cHtml+='		<td height="20" style="height:20px;">'+aCabec2[nD]+'</td>'
Next nD
cHtml+='	</tr>'
cHtml+='	<tr height="20">'
//Preenchendo a terceira linha com = em todas as colunas
For nE := 1 to 58
	cHtml+='		<td align="right">=</td>'
Next nE
cHtml+='	</tr>'

REL->(DbSetOrder(1))
REL->(DbGoTop())
Do While REL->(!EOF())

	cHtml+='	<tr height="20">'             
	cHtml+='		<td style="height:20px;">40</td>'
	cHtml+='		<td style="height:20px;">'+Alltrim(REL->CONTA)+'</td>'
	cHtml+='		<td style="height:20px;">D0FP</td>'
	cHtml+='		<td style="height:20px;">'+IIF(SubStr(REL->CONTA,1,1)$'5/6',Alltrim(REL->CC),"")+'</td>'
	cHtml+='		<td style="height:20px;"></td>'
	cHtml+='		<td style="height:20px;"></td>'
	cHtml+='		<td style="height:20px;">'+IIF(SubStr(REL->CONTA,1,1)$'5/6',"",Alltrim(REL->CC))+'</td>'
	//Valida se � o d�bito ou cr�dito o valor
	If REL->DEBIT <> 0 
		cHtml+='		<td style="height:20px;">'+Alltrim(TRANSFORM((REL->DEBIT),"@R 999999999.99"))+'</td>'
	ElseIf REL->CREDIT <> 0
		cHtml+='		<td style="height:20px;">'+Alltrim(TRANSFORM((REL->CREDIT)*-1,"@R 999999999.99"))+'</td>'
	Else
		cHtml+='		<td style="height:20px;">0</td>'
	EndIf
	cHtml+='		<td style="height:20px;"></td>'
	cHtml+='		<td style="height:20px;"></td>'
	cHtml+='		<td style="height:20px;">'+Alltrim(StrTran(REL->HIST,","," "))+'</td>'
	
	//Completando com as colunas em branco das linhas
	For nF := 1 to 47
		cHtml+='		<td></td>'
	Next nF
	cHtml+='	</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
	
	//Totalizador
	nDebito:= nDebito+REL->DEBIT
	nCredito:=nCredito+REL->CREDIT
		        
	REL->(DbSkip())
EndDo

cHtml+='</table>'
cHtml+='<br />'
cHtml+='<table border="0" cellpadding="0" cellspacing="0" style="width:301px;" width="301">
cHtml+='	<tr height="20">
cHtml+='		<td height="20" style="height:20px;width:107px;">EOF</td>
cHtml+='			<td></td>
cHtml+='	</tr>
cHtml+='	<tr height="20">
cHtml+='		<td height="20" style="height:20px;"></td>
cHtml+='		<td></td>
cHtml+='	</tr>
cHtml+='	<tr height="20">
cHtml+='		<td height="20" style="height:20px;">Total Debits</td>
cHtml+='		<td align="right">'+Alltrim(TRANSFORM((nDebito),"@R 999999999.99"))+'</td>
cHtml+='	</tr>
cHtml+='	<tr height="20">
cHtml+='		<td height="20" style="height:20px;">Total Credits</td>
cHtml+='		<td align="right">'+Alltrim(TRANSFORM((nCredito)*-1,"@R 999999999.99"))+'</td>
cHtml+='	</tr>
cHtml+='	<tr height="20">
cHtml+='		<td height="20" style="height:20px;">Net Total</td>
cHtml+='		<td align="right">'+Alltrim(TRANSFORM((nCredito-nDebito)*-1,"@R 999999999.99"))+'</td>
cHtml+='	</tr>
cHtml+='</table>


cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	
//Abre o excel
GeraExcel()

Return

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da vari�vel cHtml em partes para n�o causar estouro de variavel
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
Objetivo: Fun��o para abrir o excel
Autor   : Renato Rezende
Data    : 05/04/2016
*/                   
*-------------------------------*
 Static Function GeraExcel()
*-------------------------------*

//Verifica��o do arquivo (GRAVADO OU NAO) e defini��o de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de grava��o do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de grava��o do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	//Verifica se � para abrir o excel
	If lAbreExcel
		SHELLEXECUTE("open",(cArq),"","",5)   // Gera o arquivo em Excel ou Html
	EndIf
EndIf
 
REL->(DbSkip())
REL->(DbCloseArea())

Return

/*
Fun��o  : CriaPerg
Objetivo: Verificar se os parametros est�o criados corretamente.
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
  					
//Verifica se o SX1 est� correto
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
	Aadd( aHlpPor, "se deseja o relat�rio.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/16","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relat�rio.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/16","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relat�rio.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final at� a qual")
	Aadd( aHlpPor, "se desej� imprimir o relat�rio.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"ser� ser� gerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\F1CTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo ser� aberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relat�rio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil
