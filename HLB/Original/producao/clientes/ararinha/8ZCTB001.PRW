#include "Protheus.ch"
#include "rwmake.ch"

/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: 8ZCTB001()
Parametros  : Nenhum
Retorno     : Nil
Objetivos 	: Relatório de balanço das contas contábeis para que esse seja integrado ao ERP Oracle do Ararinha
Data      	: 01/12/2015
----------------------------------------------------------------------------------------------------------------------------------------------
*/

*--------------------------*
User Function 8ZCTB001()
*--------------------------*
Return Processa( {|| Funcao1() },"Processando aguarde...")

*----------------------*
Static Function Funcao1()
*----------------------*
Local aTabelas	:= {"CT1","CT2"}
Local oExcel	:= FWMSEXCEL():New()
Local cPerg		:= "GeraRelX1"
Local lExec		:= .T.
Local cQry 		:= ""
Local cRet		:= ""
Local cNomeEmp	:= ""
Local cAliasWork:= "SQL"

Private cArq	:= "Balanco_"+DTOS(date())+"_"+SubStr(TIME(),7,2)+".xls"
Private cDest	:=  "C:\8ZCTB001\"

//Cria o diretorio na maquina do usuário para enviar no e-mail
MakeDir(cDest)

// Verificar se é a empresa correta.
If !cEmpAnt $ '8Z/TP' //8Z - Empresa Ararinha 
	MsgInfo("Esta função não está disponível para esta empresa! Função desenvolvida para empresa Ararinha.","HLB BRASIL")
	Return()
EndIf

//Criação dos parametros do usuário
U_PUTSX1( cPerg, "01", "Data Inicial?", "Data Inicial?", "Data Inicial", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Final?"	, "Data Final?"	 , "Data Final"	 , "", "D",08,00,00,"G","" , "","","","MV_PAR02")
//PutSx1( cPerg, "03", "Data Final?"	, "Data Final?"	 , "Data Final"	 , "", "D",08,00,00,"G","" , "","","","MV_PAR02")

If !pergunte(cPerg,.T.)
	Return()
EndIf

//Verificar se a data informada nos parametros esta coerente
If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. MV_PAR01 > MV_PAR02
	Alert ("Data inserida no filtro invalida")
	Return()
EndIf

//Transforma datas em caracteres
cDataIni := DTOS(MV_PAR01)
cDataFim := DTOS(MV_PAR02)

//Verifica quantidade de registris para a barra de processamento
cQryA:=" SELECT COUNT(*) as NCOUNT"
cQryA+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryA+=" WHERE"
cQryA+="		CT2.D_E_L_E_T_	<> '*'"
cQryA+="	AND CT2.CT2_MOEDLC 	<> '01'"
cQryA+="	AND CT2.CT2_DC 		IN ('1','2','3')"
cQryA+="	AND CT2.CT2_TPSALD 	<> '9'"   
cQryA+="	AND CT2.CT2_P_LOG 	=  ''"	
cQryA+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryA+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

//Verificar todo os registros para serem apresentados na tabela
cQryB:=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],''[DEBITO],CT2.CT2_VALOR[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC""
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+=" ON CT1.CT1_CONTA = CASE WHEN CT2.CT2_CREDIT <> ''THEN CT2.CT2_CREDIT END"
cQryB+=" WHERE"
cQryB+="     CT2.D_E_L_E_T_		<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC 	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'" 
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	
cQryB+="	AND CT2.CT2_DC 		=  '2'"
cQryB+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

cQryB+=" UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],CT2.CT2_VALOR[DEBITO],''[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC""
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+=" ON CT1.CT1_CONTA = CASE WHEN CT2.CT2_CREDIT = ''THEN  CT2.CT2_DEBITO END"
cQryB+=" WHERE"
cQryB+="     CT2.D_E_L_E_T_		<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC 	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'" 
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"
cQryB+="	AND CT2.CT2_DC 		=  '1'"
cQryB+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

cQryB+=" UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],''[DEBITO],CT2.CT2_VALOR[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC""
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+="	ON CT1.CT1_CONTA = CT2.CT2_CREDIT"
cQryB+="	WHERE"
cQryB+="		CT2.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'"
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	
cQryB+="	AND CT2.CT2_DC		=  '3'"
cQryB+="	AND CT2.CT2_DATA		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA		<= '"+cDataFim+"'"

cQryB+="	UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],CT2.CT2_VALOR[DEBITO],''[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC""
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+="	ON CT1.CT1_CONTA = CT2.CT2_DEBITO	"
cQryB+="	WHERE"
cQryB+="		CT2.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'" 
cQryB+="	AND CT2.CT2_MOEDLC	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'"  
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	
cQryB+="	AND CT2.CT2_DC		=  '3'"
cQryB+="	AND CT2.CT2_DATA		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA		<= '"+cDataFim+"'"

If Select("SQL")>0
	SQL->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryA), "SQL" ,.T.,.T.)
nRecCount := SQL->NCOUNT

If Select("SQL")>0
	SQL->(DbCloseArea())
EndIf
cQryB:=TcGenQry(,,cQryB)
DbUseArea(.T.,"TOPCONN",cQryB, "SQL" ,.T.,.T.)

//Barra de progresso
If nRecCount == 0
	lExec := .F.
	Alert("Não há dados com esses parâmetros!")
	Return
EndIf

//Cria variavel com nome da empresa
cNomeEmp:= FWEmpName(cEmpAnt)

//Cria tabela e colunas da tabela Excel.
oExcel:AddworkSheet(cNomeEmp)
oExcel:AddTable (cNomeEmp,"Balanço das contas")
oExcel:AddColumn(cNomeEmp,"Balanço das contas","HLB Account",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Account description",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Company Code",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Cost Center",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Account Code",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Product",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Region",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Intercompany",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Channel Code",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Future use 2",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Debit",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","CreCdit",1,1)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Journal description",1,1)

procregua(nRecCount)

//Cria o valor das linhas
If nRecCount > 0
	SQL->(DbGoTop())
	While SQL->(!EOF())
		
		//Tratamento para o Histórico
		cHist := AllTrim(SQL->CT2_HIST)
		
		BeginSql Alias 'CT2HIST'
			SELECT CT2_HIST,CT2_DC
			FROM %table:CT2%
			WHERE %notDel%
			AND CT2_DATA = %exp:SQL->CT2_DATA%
			AND CT2_LOTE = %exp:SQL->CT2_LOTE%
			AND CT2_SBLOTE = %exp:SQL->CT2_SBLOTE%
			AND CT2_DOC = %exp:SQL->CT2_DOC%
			AND CT2_LINHA > %exp:SQL->CT2_LINHA%
			AND CT2_MOEDLC <> '01'
			AND CT2_TPSALD <> '9'	
			AND CT2_P_LOG = ''	
			ORDER BY CT2_LINHA
		EndSql
		
		CT2HIST->(DbGoTop())
		While CT2HIST->(!EOF())
			
			If CT2HIST->CT2_DC == "4"
				cHist += AllTrim(CT2HIST->CT2_HIST)
			Else
				Exit
			EndIf
			
			CT2HIST->(DbSkip())
		EndDo
		CT2HIST->(DbCloseArea())
		
		IncProc("Gerando arquivo excel...")
		oExcel:AddRow(cNomeEmp,"Balanço das contas",{;
		SQL->CT1_CONTA,;
		SQL->CT1_DESC01,;
		"725",;
		CostCenter(),;  //Sandro Ez4 - Chamado 32456           //IIF(EMPTY(SQL->CENT_CUST),SQL->CENT_CUSTD,SQL->CENT_CUST)  
		SQL->CT1_P_CONT,;
		"000",;
		IIF(SUBSTR(SQL->CT1_CONTA,1,1) >="5","720","000"),;
		"000",;		
		ChanelCod(),;     //Sandro Ez4 - chamado 32456 
		"00000",;
		If(SQL->DEBITO = 0,"",SQL->DEBITO),;
		If(SQL->CREDITO = 0,"",SQL->CREDITO),;
		cHist})
		/*  //Trecho original desativado  04/03/2021
		SQL->CT1_CONTA,;
		SQL->CT1_DESC01,;
		"725",;
		IIF(SUBSTR(SQL->CT1_CONTA,1,1) >="4",(IIF(EMPTY(SQL->CENT_CUST),SQL->CENT_CUSTD,SQL->CENT_CUST)),"0000.000"),;	//IIF(EMPTY(SQL->CENT_CUST),SQL->CENT_CUSTD,SQL->CENT_CUST),;
		SQL->CT1_P_CONT,;
		"000",;
		IIF(SUBSTR(SQL->CT1_CONTA,1,1) >="4","720","000"),;
		"000",;
		SQL->ITEM_CONT,;
		"000",;
		SQL->DEBITO,;
		SQL->CREDITO,;
		cHist})	
		*/	 //Trecho original desativado  04/03/2021 
		/*JSS - Gravação da tabela de log (ZXE)
		Layout do campo ZXE_KEYCTB
		CT2_FILIAL	=2
		CT2_DATA	=8
		CT2_LOTE	=6	
		CT2_SBLOTE	=3
		CT2_DOC		=6
		CT2_LINHA	=3	
		CT2_TPSALD	=1		
		CT2_EMPORI	=2
		CT2_FILORI	=2
		CT2_MOEDLC	=5
		*/
		//Inicio
		If Select("ZXE") > 0
			ZXE->(dbCloseArea())
		EndIf
		DbSelectArea("ZXE")
		ZXE->(DbSetOrder(1))
		ZXE->(DbGoTop())
		RecLock("ZXE",.T.) 
		ZXE->ZXE_FILIAL:=xFilial("CT2")
		ZXE->ZXE_ID:=AllTrim(RetCodUsr())
		ZXE->ZXE_USR:=AllTrim(cUserName)
		ZXE->ZXE_HOUR:=TIME()//conout(Time())
		ZXE->ZXE_DATE:=DATE()
		ZXE->ZXE_KEYCTB:=xFilial("CT2")+SQL->CT2_DATA+SQL->CT2_LOTE+SQL->CT2_SBLOTE+SQL->CT2_DOC+SQL->CT2_LINHA+SQL->CT2_TPSALD+SQL->CT2_EMPORI+SQL->CT2_FILORI+SQL->CT2_MOEDLC
		ZXE->ZXE_TYPE:="GERADO"
		MsUnLock()
		//Fim
		
		SQL->(DbSkip())
	EndDo
	//Ativa Excel
	oExcel:Activate()
EndIf


IF FILE(cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

oExcel:GetXMLFile(cDest+cArq) // Gera o arquivo em Excel

SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel

//sleep(2000)
//FERASE (cDest+cArq)
//FERASE (cArq)
oExcel:DeActivate()

//Função que atualiza o campo CT2_P_LOG marcando como ja enviado.
Funcao2()

Return   
/*
Funcao      : Funcao2()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que atualiza o campo CT2_P_LOG marcando como ja enviado.
Autor       : Joao Silva
Data/Hora   : 15/01/2014
*/
*-------------------------*
Static Function Funcao2()
*-------------------------*
SQL->(DbGoTop())
While SQL->(!EOF())
	If Select("CT2") > 0
		CT2->(dbCloseArea())
	EndIf
	DbSelectArea("CT2")
	CT2->(DbSetOrder(1))
	CT2->(DbGoTop())
	If DbSeek(xFilial("CT2")+SQL->CT2_DATA+SQL->CT2_LOTE+SQL->CT2_SBLOTE+SQL->CT2_DOC+SQL->CT2_LINHA+SQL->CT2_TPSALD+SQL->CT2_EMPORI+SQL->CT2_FILORI+SQL->CT2_MOEDLC)
		RecLock("CT2",.F.)
		CT2->CT2_P_LOG :='S'
		MsUnLock()
	Else
		MsgInfo("Não foi possivel localizar o lançamento","HLB BRASIL")
	EndIf

	SQL->(DbSkip())
EndDo
Return()


/*
Funcao      : ChanelCod()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que define o item contabil de acordo com o tipo de conta (debito/credito)
Autor       :  Sandro Silva (EZ4)
Data/Hora   : 03/03/2021
*/
Static Function ChanelCod()

Local cCod
 
If !Empty(SQL->DEBITO)
    If Empty(SQL->CT2_ITEMD)
      cCod := "000"
    Else	
      cCod := SQL->CT2_ITEMD
	EndIf  
ElseIf !Empty(SQL->CREDITO)     
   If Empty(SQL->CT2_ITEMC)
      cCod := "000"
   Else	  
      cCod := SQL->CT2_ITEMC
   EndIf	  
EndIf
Return cCod   	  

/*
Funcao      : CostCenter()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que define o centro de custo de acordo com o tipo de conta (debito/credito)
Autor       : Sandro Silva (EZ4)
Data/Hora   : 03/03/2021
*/
Static Function CostCenter()

Local cCod
 
If !Empty(SQL->CREDITO)   
   If Empty(SQL->CENT_CUST)  
      cCod := "0000"
   Else    
      cCod := SQL->CENT_CUST
   EndIf	  
Elseif !Empty(SQL->DEBITO)
   If Empty(SQL->CENT_CUSTD) 
      cCod := "0000"
   Else 
      cCod := SQL->CENT_CUSTD
   EndIf	  
EndIf
Return cCod   
