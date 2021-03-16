#include "Protheus.ch"
#include "rwmake.ch"

/*
----------------------------------------------------------------------------------------------------------------------------------------------
Funcao    	: TPCTB001()
Parametros  : Nenhum
Retorno     : Nil
Objetivos 	: Relatório de balanço das contas contábeis para que esse seja integrado ao ERP Oracle do TWITTER
Data      	: 15/01/2014
----------------------------------------------------------------------------------------------------------------------------------------------
*/

*--------------------------*
User Function TPCTB001()
*--------------------------*
Return Processa( {|| MainRel() },"Processando aguarde...")
/*
Funcao      : MainRel()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função primcipal do relatorio.
Autor       : Joao Silva
Data/Hora   : 15/01/2014
*/
*----------------------*
Static Function MainRel()
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
Private cDest	:=  "C:\TPCTB001\"

//Cria o diretorio na maquina do usuário para enviar no e-mail
MakeDir(cDest)

// Verificar se é a empresa correta.
If !cEmpAnt $ 'TP' //TP - Empresa Twitter e 33 Empresa teste do P11_16
	MsgInfo("Esta função não está disponível para esta empresa! Função desenvolvida para empresa Twitter.","HLB BRASIL")
	Return()
EndIf

//Criação dos parametros do usuário
U_PUTSX1( cPerg, "01", "Data Inicial?", "Data Inicial?", "Data Inicial", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Final?"	, "Data Final?"	 , "Data Final"	 , "", "D",08,00,00,"G","" , "","","","MV_PAR02")
//U_PUTSX1( cPerg, "03", "Data Final?"	, "Data Final?"	 , "Data Final"	 , "", "D",08,00,00,"G","" , "","","","MV_PAR02")

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
cQryA+="	AND CT2.CT2_TPSALD 	<> '9'"    //TLM Pre-Lançamento - Chamado 021869
cQryA+="	AND CT2.CT2_P_LOG 	=  ''"	//JSS
cQryA+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryA+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

//Verificar todo os registros para serem apresentados na tabela
cQryB:=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],''[DEBITO],CT2.CT2_VALOR[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC"
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+=" ON CT1.CT1_CONTA = CASE WHEN CT2.CT2_CREDIT <> ''THEN CT2.CT2_CREDIT END"
cQryB+=" WHERE"
cQryB+="     CT2.D_E_L_E_T_		<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC 	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'" //TLM Pre-Lançamento - Chamado 021869
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	//JSS
cQryB+="	AND CT2.CT2_DC 		=  '2'"
cQryB+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

cQryB+=" UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],CT2.CT2_VALOR[DEBITO],''[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC"
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+=" ON CT1.CT1_CONTA = CASE WHEN CT2.CT2_CREDIT = ''THEN  CT2.CT2_DEBITO END"
cQryB+=" WHERE"
cQryB+="     CT2.D_E_L_E_T_		<> '*'"
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC 	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'" //TLM Pre-Lançamento - Chamado 021869
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	//JSS
cQryB+="	AND CT2.CT2_DC 		=  '1'"
cQryB+="	AND CT2.CT2_DATA 		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA 		<= '"+cDataFim+"'"

cQryB+=" UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],''[DEBITO],CT2.CT2_VALOR[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC"	
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+="	ON CT1.CT1_CONTA = CT2.CT2_CREDIT"
cQryB+="	WHERE"
cQryB+="		CT2.D_E_L_E_T_	<> '*'" 
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'" //TLM Pre-Lançamento - Chamado 021869
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	//JSS 
cQryB+="	AND CT2.CT2_DC		=  '3'"
cQryB+="	AND CT2.CT2_DATA		>= '"+cDataIni+"'"
cQryB+="	AND CT2.CT2_DATA		<= '"+cDataFim+"'"

cQryB+="	UNION ALL"

cQryB+=" SELECT CT1.CT1_CONTA,CT1.CT1_DESC01,CT2.CT2_CCC[CENT_CUST],CT2.CT2_CCD[CENT_CUSTD],CT1.CT1_P_CONT,CT2.CT2_ITEMC[ITEM_CONT],CT2.CT2_VALOR[DEBITO],''[CREDITO],CT1.CT1_DESC04,CT2.CT2_DEBITO,CT2.CT2_CREDIT,"
cQryB+=" CT2.CT2_HIST,CT2.CT2_DATA,CT2.CT2_LOTE,CT2.CT2_SBLOTE,CT2.CT2_DOC,CT2.CT2_LINHA,CT2.CT2_TPSALD,CT2.CT2_EMPORI,CT2.CT2_FILORI,CT2.CT2_MOEDLC,CT2.CT2_ITEMD,CT2.CT2_ITEMC,CT2.CT2_DC"
cQryB+=" FROM "+RETSQLNAME("CT2")+" AS CT2"
cQryB+=" JOIN "+RETSQLNAME("CT1")+" AS CT1"
cQryB+="	ON CT1.CT1_CONTA = CT2.CT2_DEBITO	"
cQryB+="	WHERE"
cQryB+="		CT2.D_E_L_E_T_	<> '*'" 
cQryB+="	AND CT1.D_E_L_E_T_	<> '*'"
cQryB+="	AND CT2.CT2_MOEDLC	<> '01'"
cQryB+="	AND CT2.CT2_TPSALD 	<> '9'"  //TLM Pre-Lançamento - Chamado 021869
cQryB+="	AND CT2.CT2_P_LOG 	=  ''"	 //JSS
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
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryB), "SQL" ,.T.,.T.)



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
oExcel:AddColumn(cNomeEmp,"Balanço das contas","Debit",1,2,.F.)
oExcel:AddColumn(cNomeEmp,"Balanço das contas","CreCdit",1,2,.F.)
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
			AND CT2_TPSALD <> '9'//TLM Pre-Lançamento - Chamado 021869
			AND CT2_P_LOG = ''	 //JSS
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
		"720",;
		CostCenter(),;   //IIF(EMPTY(SQL->CENT_CUST),SQL->CENT_CUSTD,SQL->CENT_CUST) //Alterado conforme chamado 25833 - Sandro Ez4
		SQL->CT1_P_CONT,;
		"000",;
		IIF(SUBSTR(SQL->CT1_CONTA,1,1) >="5","720","000"),;
		"000",;		
		ChanelCod(),;   //Alterado conforme chamado 25833 - Sandro Ez4
		"00000",;
		If(SQL->DEBITO = 0,"",SQL->DEBITO),;   //Alterado conforme chamado 25833  Sandro-Ez4
		If(SQL->CREDITO = 0,"",SQL->CREDITO),; //Alterado conforme chamado 25833  Sandro-Ez4		
		cHist})
		
		/*JSS - Gravação da tabela de log (ZXC)
		Layout do campo ZXC_KEYCTB
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
		If Select("ZXC") > 0
			ZXC->(dbCloseArea())
		EndIf
		DbSelectArea("ZXC")
		ZXC->(DbSetOrder(1))
		ZXC->(DbGoTop())
		RecLock("ZXC",.T.) 
		ZXC->ZXC_FILIAL:=xFilial("CT2")
		ZXC->ZXC_ID:=AllTrim(RetCodUsr())
		ZXC->ZXC_USR:=AllTrim(cUserName)
		ZXC->ZXC_HOUR:=TIME()//conout(Time())
		ZXC->ZXC_DATE:=DATE()
		ZXC->ZXC_KEYCTB:=xFilial("CT2")+SQL->CT2_DATA+SQL->CT2_LOTE+SQL->CT2_SBLOTE+SQL->CT2_DOC+SQL->CT2_LINHA+SQL->CT2_TPSALD+SQL->CT2_EMPORI+SQL->CT2_FILORI+SQL->CT2_MOEDLC
		ZXC->ZXC_TYPE:="GERADO"
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

//Atualiza os itens ja enviados.
AtuCT2()

Return  
/*
Funcao      : AtuCT2()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que atualiza o campo CT2_P_LOG marcando como ja enviado.
Autor       : Joao Silva
Data/Hora   : 15/01/2014
*/
*-------------------------*
Static Function AtuCT2()
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
