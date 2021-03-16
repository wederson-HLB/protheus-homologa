#include 'totvs.ch'

/*
Funcao      : 52CTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relatório contábil).
Autor       : Renato Rezende
Cliente		: NBCU (Universal Studio)
Data/Hora   : 17/07/2016
*/    
*-------------------------*
 User Function 52CTB001() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "52CTB001"

Private cTitulo		:= "Relatório GL FILE"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If !cEmpAnt $ "52/EK"//Verifica se é a empresa Universal 
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
	cMoeda    	:= mv_par06
	
	//Gera o Relatório
	Processa({|| lOk := GeraRel()},"Gerando o txt...")

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
Data    : 17/07/2016
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
Data    : 17/07/2016
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
aAdd(aStru,{"Filial	","C",001,0})
aAdd(aStru,{"ConDeb	","C",020,0})
aAdd(aStru,{"ConCre 	","C",020,0})
aAdd(aStru,{"Debit	","N",017,2})
aAdd(aStru,{"Credit	","N",017,2})
aAdd(aStru,{"CC		","C",009,0})
aAdd(aStru,{"CodHis	","C",050,0})
aAdd(aStru,{"Hist	","C",042,0})


cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o índice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->DATAPC",,,"Selecionando Registro...")


DbSelectArea("REL")
REL->(DbSetIndex(cIndex+OrdBagExt()))
REL->(DbSetOrder(1))

Return cArqTrab

/*
Função  : TmpRel
Retorno : lRet
Objetivo: Cria a tabela temporária que será utilizada para gerar o txt.
Autor   : Renato Rezende
Data    : 17/07/2016
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cHist		:= ""
Local lRet		:= .F.

//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := "SELECT CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ORIGEM, CT2_VALOR, CT2_DATA, CT2_HIST, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, CT2_CCC, CT2_ITEMC, CT2_CLVLCR, CT2_FILORI " + CRLF
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
		IncProc( "Preparando dados..." )
	
		cHist	:= ""
		
		//Histórico
		cHist := AllTrim(SQL->CT2_HIST)
		
		If SQL->CT2_DC=="1" .OR. SQL->CT2_DC=="3"

			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->FILIAL	:= SubStr(SQL->CT2_FILORI,2,1)
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->CONDEB	:= AllTrim(SQL->CT2_DEBITO)
	        REL->CONCRE := ""
			REL->DEBIT  := SQL->CT2_VALOR
			REL->CREDIT := 0
			REL->CC		:= Alltrim(SQL->CT2_CCD)
			REL->CODHIS := ""
			REL->HIST	:= Alltrim('"'+cHist+'"')
				
			REL->(MSUnlock())
		
		Endif
		
		If SQL->CT2_DC=="2" .OR. SQL->CT2_DC=="3"
		
			//Grava o arquivo temporário.
			REL->(RecLock("REL",.T.))
					
			REL->DATARD := DATE()
			REL->FILIAL	:= SubStr(SQL->CT2_FILORI,2,1)
			REL->DATAPC := StoD(SQL->CT2_DATA)
			REL->CONDEB	:= ""
	        REL->CONCRE := AllTrim(SQL->CT2_CREDIT)
			REL->DEBIT  := 0
			REL->CREDIT := SQL->CT2_VALOR
			REL->CC		:= Alltrim(SQL->CT2_CCC)
			REL->CODHIS := ""
			REL->HIST	:= Alltrim('"'+cHist+'"')
				
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
Data    : 17/07/2016
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local nHdl		:= 0
Local cValor	:= ""
Local cMsg		:= ""

nHdl := FCREATE(cArq,0 )  //Criação do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	cMsg:="O arquivo "+cArq+" nao pode ser executado." 
	MsgAlert(cMsg,"Atenção")
	lGrvDados := .F.
	Return 
EndIf

REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF()) 
	
	cValor := ""
	//Valida se é o débito ou crédito o valor
	If REL->DEBIT <> 0 
		cValor:= Alltrim(TRANSFORM((REL->DEBIT),"@R 99999999999.99"))
	ElseIf REL->CREDIT <> 0
		cValor:= Alltrim(TRANSFORM((REL->CREDIT),"@R 99999999999.99"))
	Else
		cValor:= "0.00"
	EndIf
	//Retirado da primeira posição a filial - REL->FILIAL+",";
	fWrite(nHdl,DtoC(REL->DATAPC)+",";
				+Alltrim(REL->CONDEB)+",";
				+Alltrim(REL->CONCRE)+",";
                +cValor+",";
                +Alltrim(REL->CODHIS)+",";
                +Alltrim(REL->HIST)+Chr(13)+Chr(10);
                )
    
	//Verifica se tem classe de valor
	If !Empty(REL->CC)
		fWrite(nHdl,Alltrim(REL->CC)+",";
					+cValor+Chr(13)+Chr(10);
     	)	    
    EndIf            
	
	REL->(DbSkip())
EndDo

fclose(nHdl) // Fecha o Arquivo que foi Gerado
 
REL->(DbSkip())
REL->(DbCloseArea())

Return

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 17/07/2016
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
  					{"06","Moeda ?"              }}
  					
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
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\52CTB001.txt","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
		
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatório.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"06","Moeda ?","Moeda ?","Moeda ?","mv_ch6","C",02,0,0,"G","","CTO","","S","mv_par06","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil
