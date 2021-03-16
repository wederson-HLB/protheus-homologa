#include 'totvs.ch'

/*
Funcao      : EXCTB001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gl File (Relat�rio cont�bil).
Autor       : Anderson Arrais
Cliente		: AGRINOS
Data/Hora   : 01/09/2016
*/    
*-------------------------*
 User Function EXCTB001() 
*-------------------------*
Local lOk 			:= .F.
Local cPerg 		:= "EXCTB001"

Private cTitulo		:= "Relat�rio GL FILE"
Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private lAbreExcel	:= .F.
Private cMoeda		:= ""
Private cDescMoe	:= ""  

If cEmpAnt <> "EX"//Verifica se � a empresa Agrinos
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
	cArq		:= Alltrim(mv_par05)+"FW001."+SUBSTR(DtoS(mv_par02),5,2)
	cMoeda    	:= mv_par06
	
	//Gera o Relat�rio
	Processa({|| lOk := GeraRel()},"Gerando o txt...")

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
Autor   : Anderson Arrais
Data    : 01/09/2016
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
Autor   : Anderson Arrais
Data    : 01/09/2016
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local cArqTrab := ""
Local cIndex   := ""

Local aStru := {} 

//Cria a tabela tempor�ria
aAdd(aStru,{"ConDeb	","C",040,0})
aAdd(aStru,{"ConCre ","C",040,0})
aAdd(aStru,{"CodHis	","C",004,0})
aAdd(aStru,{"Valor	","N",018,2})
aAdd(aStru,{"DataL	","D",008,0})
aAdd(aStru,{"Depart	","C",004,0})
aAdd(aStru,{"Setor	","C",004,0})
aAdd(aStru,{"Secao	","C",004,0})
aAdd(aStru,{"PlanCC ","C",020,0})
aAdd(aStru,{"NCC    ","C",001,0})

cArqTrab := CriaTrab(aStru, .T.)

If Select("REL") > 0 
	REL->(DbCloseArea())
EndIf

dbUseArea(.T.,__LOCALDRIVER,cArqTrab,"REL",.T.,.F.)

//Cria o �ndice do arquivo.
cIndex:=CriaTrab(Nil,.F.)
IndRegua("REL",cIndex,"REL->DATAL",,,"Selecionando Registro...")


DbSelectArea("REL")
REL->(DbSetIndex(cIndex+OrdBagExt()))
REL->(DbSetOrder(1))

Return cArqTrab

/*
Fun��o  : TmpRel
Retorno : lRet
Objetivo: Cria a tabela tempor�ria que ser� utilizada para gerar o txt.
Autor   : Anderson Arrais
Data    : 01/09/2016
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
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

			//Grava o arquivo tempor�rio.
			REL->(RecLock("REL",.T.))
					
			REL->DATAL 	:= StoD(SQL->CT2_DATA)
			REL->CONDEB	:= AllTrim(SQL->CT2_DEBITO)
	        REL->CONCRE := AllTrim(SQL->CT2_CREDIT)
			REL->VALOR  := SQL->CT2_VALOR
			REL->CODHIS := ""
			REL->DEPART := ""
			REL->SETOR  := "" 
			REL->SECAO  := "" 
			REL->PLANCC := ""
			REL->NCC    := ""
							
			REL->(MSUnlock())
	
		SQL->(dbSkip())
	
	EndDo
EndIf

SQL->(dbCloseArea())

Return lRet

/*
Funcao  : ImpRel()
Retorno : Nenhum
Objetivo: Imprime o relat�rio
Autor   : Anderson Arrais
Data    : 01/09/2016
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local nHdl		:= 0
Local cMsg		:= ""

nHdl := FCREATE(cArq,0)  //Cria��o do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	cMsg:="O arquivo "+cArq+" nao pode ser executado." 
	MsgAlert(cMsg,"Aten��o")
	lGrvDados := .F.
	Return 
EndIf


REL->(DbSetOrder(1))
REL->(DbGoTop())
While REL->(!EOF()) 
	
	fWrite(nHdl,REL->CONDEB;
				+REL->CONCRE;
				+REL->CODHIS;
				+STRZERO(REL->VALOR*100,18);
				+GRAVADATA(REL->DATAL,.F.,5);
				+REL->DEPART;
				+REL->SETOR ;
				+REL->SECAO ;
				+"6";
				+"FOLHAMATIC";
				+SPACE(16)+"*";
				+REL->PLANCC;
                +REL->NCC+Chr(13)+Chr(10);
                )
          	
	REL->(DbSkip())
EndDo

fclose(nHdl) // Fecha o Arquivo que foi Gerado

frenameex(cValToChar(cArq),UPPER(cValToChar(cArq))) // Transforma o nome do arquivo em mai�sculo

REL->(DbSkip())
REL->(DbCloseArea())

Return

/*
Fun��o  : CriaPerg
Objetivo: Verificar se os parametros est�o criados corretamente.
Autor   : Anderson Arrais
Data    : 01/09/2016
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
  					{"05","Caminho do Arquivo?"  },;
  					{"06","Moeda ?"              }}
  					
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
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relat�rio.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
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
	Aadd( aHlpPor,"Diretorio do Arquivo que ")
	Aadd( aHlpPor,"ser� ser� gerado.")
	
	U_PUTSX1(cPerg,"05","Caminho do Arquivo?","Caminho do Arquivo ?","Caminho do Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","C:\ADP\","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
		
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relat�rio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"06","Moeda ?","Moeda ?","Moeda ?","mv_ch6","C",02,0,0,"G","","CTO","","S","mv_par06","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
EndIf
	
Return Nil
