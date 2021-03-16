#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#Include 'fileio.ch'

/*
Funcao      : TMFAT002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : O objetivo desse projeto é gerar as informações necessárias para alimentar o software Qliqview da VICTAULIC matriz
Autor     	: João Silva
Data     	: 28/04/2014
TDN         : 
Módulo      : Faturamento.
Empresa		: Victaulic
*/

*--------------------------*
User Function TMFAT002()
*--------------------------*
Private lJob	:= .F.

//RRP - 05/01/2017 - Inclusão da rotina via JOB.
//Testa para verificar se está sendo feito pelo JOB ou pelo menu				                        
If Select("SX3")<=0
	lJob := .T.
	RpcSetType(3)
	RpcSetEnv("TM", "01")  //Abre ambiente em rotinas automáticas  
	MainRel()
Else
	Processa( {|| MainRel() },"Processando aguarde...")
EndIf

Return

*------------------------*
Static Function MainRel()
*------------------------*   

Local aTabelas		:= {"CT1","CT2"}
Local aCabec		:= {}

Local oExcel		:= FWMSEXCEL():New()

Local cPerg			:= "GeraRelX1"
Local cQryA 		:= ""
Local cQryB 		:= ""
Local cRet			:= ""
Local cNomeEmp		:= ""
Local cAliasWork	:= "SQL"
Local cCfops		:= SUPERGETMV("MV_P_QLIQV" , .F. , "" )
Local cHtml			:= ""

Local nR			:= 0

Local lExec	   		:= .T.

Private cArq   		:= "Qliqview_"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)
Private cDest  		:= ""
Private cPath	 	:= Alltrim(GETMV("MV_P_FTP",,'ftp.victaulic.com'))
Private cLogin		:= Alltrim(GETMV("MV_P_USR",,'gthornton'))
Private cPass		:= Alltrim(GETMV("MV_P_PSW",,'GT_willow@57m'))

// Verificar se é a empresa correta.
If !cEmpAnt $ 'TM' //TM - Empresa Vicitaulic.
	MsgInfo("Esta função não está disponível para esta empresa! Função desenvolvida para empresa Vicitaulic.","Grant Thornton")
	Return()
EndIf

If lJob
	cArq:= cArq+".csv"
	cDest:= "\FTP\"+cEmpAnt+"\TMFAT002\"
	//Crindo diretório no servidor
	If !LisDir( cDest )
		MakeDir( "\FTP" )
		MakeDir( "\FTP\" + cEmpAnt )	
		MakeDir( "\FTP\" + cEmpAnt + "\TMFAT002\" )
		MakeDir( "\FTP\" + cEmpAnt + "\TMFAT002\processados" )
	EndIf
	//Geração do arquivo com D-1
	MV_PAR01	:= Date()-1
	MV_PAR02	:= Date()-1
Else
	cArq:= cArq+".xls"
	cDest:= GetTempPath()
	//Criação dos parametros do usuário
	U_PUTSX1( cPerg, "01", "Da Data de Emissao ?", "Da Data de Emissao ?", "Da Data de Emissao ?", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
	U_PUTSX1( cPerg, "02", "Ate Data de Emissao ?", "Ate Data de Emissao ?"	 , "Ate Data de Emissao ?"	 , "", "D",08,00,00,"G","" , "","","","MV_PAR02")
	
	If !pergunte(cPerg,.T.)
		Return()
	EndIf
	
	//Verificar se a data informada nos parametros esta coerente
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. MV_PAR01 > MV_PAR02
		Alert ("Data inserida no filtro invalida")
		Return()
	EndIf
EndIf

//Transforma datas em caracteres
cDataIni := DTOS(MV_PAR01)
cDataFim := DTOS(MV_PAR02)

//Contabiliza a quantidade de registros para barra de processamento.
cQryA:=" SELECT COUNT(*) as NCOUNT"
cQryA+=" FROM "+RETSQLNAME("SD2")+" AS SD2"

// Seleciona as notas de devolução
//cQryB:=" SELECT	SD2.D2_EMISSAO,SD2.D2_PEDIDO,SD2.D2_COD,SD2.D2_CLIENTE,SA1.A1_NOME,SC5.C5_NUM,SC5.C5_P_SALES,SC5.C5_P_ENDUS,SA4.A4_NOME,SC5.C5_P_SPF,SM2.M2_MOEDA2,"
cQryB:=" SELECT	SD2.D2_EMISSAO,SD2.D2_PEDIDO,SD2.D2_COD,SD2.D2_CLIENTE,SA1.A1_NOME,SC5.C5_NUM,SC5.C5_P_SALES,SC5.C5_P_ENDUS,SA4.A4_NOME,SC5.C5_P_SPF,"
cQryB+="			'0' AS [D2_TOTAL],SF2.F2_PBRUTO,SF2.F2_PLIQUI,'0' AS [D2_VALICM],'0' AS [D2_VALIPI],'0' AS [D2_VALCOF],'0' AS [D2_VALPIS], '0' AS [D2_ICMSRET],SD1.D1_VALICM,SD1.D1_VALIPI,SD1.D1_VALCOF,"
cQryB+="			SD1.D1_EMISSAO,SD1.D1_TOTAL,SD1.D1_VALPIS,SD1.D1_ICMSRET,SB1.B1_PESO,SD1.D1_QUANT,'0' AS [D2_QUANT],''[CUSTOD2],SD1.D1_CUSTO[CUSTOD1],SA1.A1_EST,"
cQryB+="			SD1.D1_DOC AS [INVOICE],SD1.D1_SERIE AS [SERIE],SC5.C5_OBRA,'' AS [D2_VALBRUT],SC6.C6_PEDCLI,SF1.F1_VALBRUT"
cQryB+=" FROM	"+RETSQLNAME("SF1")+" AS SF1"
cQryB+=" JOIN	"+RETSQLNAME("SD1")+" AS SD1"
cQryB+=" ON		SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA"
cQryB+=" JOIN	"+RETSQLNAME("SD2")+" AS SD2"
cQryB+=" ON		SD1.D1_FILIAL=SD2.D2_FILIAL AND SD1.D1_NFORI=SD2.D2_DOC AND SD1.D1_SERIORI=SD2.D2_SERIE AND SD1.D1_ITEMORI=SD2.D2_ITEM"
cQryB+=" JOIN	"+RETSQLNAME("SA1")+" AS SA1"
cQryB+=" ON		SD2.D2_CLIENTE=SA1.A1_COD AND SD2.D2_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_=''"
cQryB+=" JOIN	"+RETSQLNAME("SC5")+" AS SC5"
cQryB+=" ON		SC5.C5_FILIAL=SD2.D2_FILIAL AND SC5.C5_NUM=SD2.D2_PEDIDO"
cQryB+=" LEFT JOIN "+RETSQLNAME("SA4")+" AS SA4"
cQryB+=" ON		SC5.C5_TRANSP=SA4.A4_COD"
//cQryB+=" JOIN	SM2YY0	AS SM2"
//cQryB+=" ON		SM2.M2_DATA=(SD2.D2_EMISSAO-1)"
cQryB+=" JOIN	"+RETSQLNAME("SF2")+" AS SF2"
cQryB+=" ON		SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA"
cQryB+=" JOIN	"+RETSQLNAME("SB1")+" AS SB1"
cQryB+=" ON		SB1.B1_FILIAL=SD2.D2_FILIAL AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=''"
cQryB+=" JOIN	"+RETSQLNAME("SC6")+" AS SC6"
cQryB+=" ON		SC6.C6_NUM=SD2.D2_PEDIDO AND SC6.C6_ITEM = SD2.D2_ITEMPV AND SC6.C6_FILIAL = SD2.D2_FILIAL"
cQryB+=" WHERE  SF1.D_E_L_E_T_ <> '*'"
cQryB+="		AND	SF2.D_E_L_E_T_ <> '*'"
cQryB+="		AND	SD1.D_E_L_E_T_ <> '*'"
cQryB+="		AND	SD2.D_E_L_E_T_ <> '*'"    

// TLM 25/06/2014 - Notas de amostra não devem sair  
/*
cQryB+="   		AND	SD2.D2_CF<>'5911 '"
cQryB+="   		AND	SD2.D2_CF<>'6911 '"   
cQryB+="  		AND	SD2.D2_CF<>'5914 '"    // TLM adicionado novo CFOP 20140905
cQryB+="   		AND	SD2.D2_CF<>'6914 '"    // TLM adicionado novo CFOP 20140905
cQryB+="		AND	SD2.D2_CF<>'5949 '"    // TLM adicionado novo CFOP 20140905
cQryB+="		AND	SD2.D2_CF<>'6949 '"    // TLM adicionado novo CFOP 20140905
cQryB+="		AND	SD2.D2_CF<>'5910 '"    // TLM adicionado novo CFOP 20141106
cQryB+="		AND	SD2.D2_CF<>'6910 '"    // TLM adicionado novo CFOP 20141106
*/

if !empty(cCfops) //MSM - Inclusão de tratamento para cfop através de parametro - 07/11/2014
	cQryB+=" AND SD2.D2_CF NOT IN ("+alltrim(strtran(cCfops,";",","))+")"
endif

cQryB+="		AND	SC5.D_E_L_E_T_ <> '*'"
cQryB+="		AND	SC6.D_E_L_E_T_ <> '*'"
cQryB+="		AND	SF1.F1_TIPO	  = 'D'"
cQryB+="		AND	SD2.D2_TIPO	 IN ('N','C','I')"   // TLM adicionado complemento 20140905
cQryB+="		AND	SD1.D1_DTDIGIT >= '"+cDataIni+"'"
cQryB+="		AND	SD1.D1_DTDIGIT <= '"+cDataFim+"'"
cQryB+=" UNION ALL "

//--Seleciona as Notas de venda"
//cQryB+=" SELECT  SD2.D2_EMISSAO,SD2.D2_PEDIDO,SD2.D2_COD,SD2.D2_CLIENTE,SA1.A1_NOME,SC5.C5_NUM,SC5.C5_P_SALES,SC5.C5_P_ENDUS,SA4.A4_NOME,SC5.C5_P_SPF,SM2.M2_MOEDA2,"
cQryB+=" SELECT  SD2.D2_EMISSAO,SD2.D2_PEDIDO,SD2.D2_COD,SD2.D2_CLIENTE,SA1.A1_NOME,SC5.C5_NUM,SC5.C5_P_SALES,SC5.C5_P_ENDUS,SA4.A4_NOME,SC5.C5_P_SPF,"
cQryB+=" 		SD2.D2_TOTAL,SF2.F2_PBRUTO,SF2.F2_PLIQUI,SD2.D2_VALICM,SD2.D2_VALIPI,SD2.D2_VALCOF,SD2.D2_VALPIS,SD2.D2_ICMSRET,''[D1_VALICM],''[D1_VALIPI],''[D1_VALCOF],''[D1_EMISSAO],''[D1_TOTAL],"
cQryB+=" ''[D1_VALPIS],''[D1_ICMSRET],SB1.B1_PESO,''[D1_QUANT],SD2.D2_QUANT,SD2.D2_CUSTO1[CUSTOD2],''[CUSTOD1],SA1.A1_EST,
cQryB+=" SD2.D2_DOC AS [INVOICE],SD2.D2_SERIE AS [SERIE],SC5.C5_OBRA,SD2.D2_VALBRUT,SC6.C6_PEDCLI,0[D1_TOTAL]"     // TLM 20150610 de F1_VALBRUT para D1_TOTAL
cQryB+=" FROM	"+RETSQLNAME("SD2")+" AS SD2 "   
cQryB+=" JOIN	"+RETSQLNAME("SA1")+" AS SA1"
cQryB+=" ON		SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA AND SA1.D_E_L_E_T_=''"
cQryB+=" JOIN	"+RETSQLNAME("SC5")+" AS SC5"
cQryB+=" ON		SC5.C5_FILIAL=SD2.D2_FILIAL AND SC5.C5_NUM=SD2.D2_PEDIDO" 
cQryB+=" LEFT JOIN "+RETSQLNAME("SA4")+" AS SA4"
cQryB+=" ON		SC5.C5_TRANSP=SA4.A4_COD"
//cQryB+=" JOIN	SM2YY0	AS SM2"
//cQryB+=" ON		SM2.M2_DATA=(SD2.D2_EMISSAO-1)"  
cQryB+=" JOIN	"+RETSQLNAME("SF2")+" AS SF2"
cQryB+=" ON		SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA=SD2.D2_LOJA" 
cQryB+=" JOIN	"+RETSQLNAME("SB1")+" AS SB1"
cQryB+=" ON		SB1.B1_FILIAL=SD2.D2_FILIAL AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=''"
cQryB+=" JOIN	"+RETSQLNAME("SC6")+" AS SC6"
cQryB+=" ON		SC6.C6_NUM=SD2.D2_PEDIDO AND SC6.C6_ITEM = SD2.D2_ITEMPV AND SC6.C6_FILIAL = SD2.D2_FILIAL"
cQryB+=" WHERE  SF2.D_E_L_E_T_ <> '*'"
cQryB+=" 	AND	SC5.D_E_L_E_T_ <> '*'"
cQryB+=" 	AND	SC6.D_E_L_E_T_ <> '*'"
cQryB+=" 	AND	SD2.D_E_L_E_T_ <> '*'"   

// TLM 25/06/2014 - Notas de amostra não devem sair 
/*
cQryB+="	AND	SD2.D2_CF<>'5911 '"
cQryB+="	AND	SD2.D2_CF<>'6911 '"   
cQryB+="	AND	SD2.D2_CF<>'5914 '"	// TLM adicionado novo CFOP 20140905
cQryB+="	AND	SD2.D2_CF<>'6914 '" // TLM adicionado novo CFOP 20140905
cQryB+="	AND	SD2.D2_CF<>'5949 '" // TLM adicionado novo CFOP 20140905
cQryB+="	AND	SD2.D2_CF<>'6949 '" // TLM adicionado novo CFOP 20140905 
cQryB+="	AND	SD2.D2_CF<>'5910 '" // TLM adicionado novo CFOP 20141106
cQryB+="	AND	SD2.D2_CF<>'6910 '" // TLM adicionado novo CFOP 20141106 
*/
if !empty(cCfops) //MSM - Inclusão de tratamento para cfop através de parametro - 07/11/2014
	cQryB+=" AND SD2.D2_CF NOT IN ("+alltrim(strtran(cCfops,";",","))+")"
endif

cQryB+=" 	AND	SD2.D2_TIPO IN ('N','C','I')"    // TLM adicionado complemento 20140905
cQryB+="	AND	SD2.D2_EMISSAO >= '"+cDataIni+"'"
cQryB+="	AND	SD2.D2_EMISSAO <= '"+cDataFim+"'"

//Verificar se a tabela temporaria esta aberta se estiver fecha e Gera tabela temporaria
If Select("SQL")>0
	SQL->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryA), "SQL" ,.T.,.F.)
nRecCount := SQL->NCOUNT

//Verificar se a tabela temporaria esta aberta se estiver fecha e Gera tabela temporaria
If Select("SQL")>0
	SQL->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryB), "SQL" ,.T.,.F.)

//Barra de progresso
If nRecCount == 0
	lExec := .F.
	Alert("Não há dados com esses parâmetros!")
EndIf

//Cria variavel com nome da empresa
cNomeEmp:= FWEmpName(cEmpAnt)

If lJob
	aCabec:={"Invoice Date","Order Number","Currency(Currency code that is being invoiced)","Service Warehouse","Order Ship Warehouse",;
			 "Customer #","Customer Name","Salesperson","Enduse","Territory","Item","Freight_Carrier","Project_Ship_To","Gross_Amt_BRL",;
			 "Gross_Weight","Net_Amt_BRL","Net_Credit_Amt","Net_Return_Amt_BR","Gross_Return_Amt_BR","Net_Weight","Net_Units","Return_Units",;
			 "Credit_Units","AIC_Cost","Order_Country","Invoice_Number","PO_Number","Invoice_State","Intercompany"}
	//Incluindo o cabeçalho no relatório
	For nR := 1 to Len(aCabec)
		cHtml+= aCabec[nR]+';'
	Next nR
	cHtml+= Chr( 13 ) + Chr( 10 )
Else 
	//Cria tabela e colunas da tabela Excel.
	oExcel:AddworkSheet(cNomeEmp)
	oExcel:AddTable (cNomeEmp,"Qliqview")
	oExcel:AddColumn(cNomeEmp,"Qliqview","Invoice Date",1,4)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Order Number",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Currency(Currency code that is being invoiced)",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Service Warehouse",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Order Ship Warehouse",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Customer #",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Customer Name",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Salesperson",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Enduse",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Territory",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Item",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Freight_Carrier",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Project_Ship_To",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Gross_Amt_BRL",1,1)
	//oExcel:AddColumn(cNomeEmp,"Qliqview","Gross_Amt",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Gross_Weight",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Amt_BRL",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Credit_Amt",1,1)
	//oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Return_Amt",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Return_Amt_BR",1,1)  
	//oExcel:AddColumn(cNomeEmp,"Qliqview","Gross_Return_Amt",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Gross_Return_Amt_BR",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Weight",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Net_Units",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Return_Units",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Credit_Units",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","AIC_Cost",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Order_Country",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Invoice_Number",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","PO_Number",1,1)
	oExcel:AddColumn(cNomeEmp,"Qliqview","Invoice_State",1,1) 
	oExcel:AddColumn(cNomeEmp,"Qliqview","Intercompany",1,1)//AOA - 02/08/2016 - Inclusão da coluna intercompany
	
	procregua(nRecCount)
EndIf

//Cria o valor das linhas
If nRecCount > 0
	SQL->(DbGoTop())
	While SQL->(!EOF())

		If lJob
			cHtml+=/*A - Invoice Date*/IIF(SQL->D1_TOTAL > 0, DtoC(StoD(SQL->D1_EMISSAO)), DtoC(StoD(SQL->D2_EMISSAO)))+';'
			cHtml+=/*B - Order Number*/SQL->C5_NUM+';'
			cHtml+=/*C - Currency*/"BRL"+';'
			cHtml+=/*D - Service Warehouse*/"BRASIL"+';'
			cHtml+=/*E - Order Ship Warehouse*/"BRASIL"+';'
			cHtml+=/*F - Customer*/AllTrim(SQL->D2_CLIENTE)+';'
			cHtml+=/*G - Customer Name*/SubStr(SQL->A1_NOME,1,40)+';'
			cHtml+=/*H - Salesperson*/SQL->C5_P_SALES+';'
			cHtml+=/*I - Enduse*/SQL->C5_P_ENDUS+';'
			cHtml+=/*J - Territory*/"BRASIL"+';'
			cHtml+=/*K - Item*/SQL->D2_COD+';'
			cHtml+=/*L - Freight_Carrier*/SubStr(SQL->A4_NOME,1,40)+';'
			cHtml+=/*M - Project_Ship_To*/SQL->C5_P_SPF+';'
			cHtml+=/*N - Gross_Amt_BRL*/Transform(SQL->D2_VALBRUT,"@R 999999999999.99" )+';'
			cHtml+=/*O - Gross_Weight*/Transform(((SQL->F2_PBRUTO/SQL->F2_PLIQUI)*(SQL->D2_QUANT * SQL->B1_PESO)),"@R 9999999.9999" )+';'
			cHtml+=/*P - Net_Amt_BRL*/Transform(SQL->D2_TOTAL - SQL->D2_VALICM - SQL->D2_VALIPI - SQL->D2_VALCOF - SQL->D2_VALPIS - SQL->D2_ICMSRET,"@R 999999999999.99")+';'
			cHtml+=/*Q - Net_Credit_Amt*/"0"+';'
			cHtml+=/*R - Net_Return_Amt_BR*/ Transform(SQL->D1_TOTAL - SQL->D1_VALPIS - SQL->D1_ICMSRET - SQL->D1_VALCOF  - SQL->D1_VALICM - SQL->D1_VALIPI,"@R 999999999999.99")+';'
			cHtml+=/*S - Gross_Return_Amt_BR*/ Transform(SQL->D1_TOTAL+SQL->D1_VALIPI+SQL->D1_ICMSRET,"@R 999999999999.99")+';'
			cHtml+=/*T - Net_Weight*/Transform(SQL->D2_QUANT * SQL->B1_PESO,"@R 999999999999.99" )+';'
			cHtml+=/*U - Net_Units*/Transform(SQL->D2_QUANT,"@R 999999999.99" )+';'
			cHtml+=/*V - Return_Units*/Transform(SQL->D1_QUANT,"@R 999999999.99" )+';'
			cHtml+=/*W - Credit_Units*/"0"+';'
			cHtml+=/*X - AIC_Cost*/Iif( SQL->CUSTOD1 <= 0,Transform(SQL->CUSTOD2,"@R 999999999999.99" ),Transform(-1*SQL->CUSTOD1,"@R 999999999999.99" ))+';'
			cHtml+=/*Y - Order_Country*/"BRASIL"+';'
			cHtml+=/*Z- Invoice_Number*/StrZero(VAL(SQL->INVOICE),9)+';'
			cHtml+=/*AA- PO_Number*/SQL->C5_OBRA+';'
			cHtml+=/*AB- Invoice_State*/SQL->A1_EST+';'
			cHtml+=/*AC- Invoice_State*/Iif(AllTrim(SQL->D2_CLIENTE)$'000002/000021',"Y","N")+';'
			cHtml+= Chr( 13 ) + Chr( 10 )
    	
		Else
			IncProc("Gerando arquivo excel...") 
		
			/*Col*/	oExcel:AddRow(cNomeEmp,"Qliqview",{;
			/*A - Invoice Date*/Iif(SQL->D1_TOTAL > 0, StoD(SQL->D1_EMISSAO), StoD(SQL->D2_EMISSAO)),;//AOA - 10/06/2016 - Em caso de nota de devoução pega a emissão do SD1
			/*B - Order Number*/SQL->C5_NUM,;
			/*C - Currency*/"BRL",;
			/*D - Service Warehouse*/"BRASIL",;
			/*E - Order Ship Warehouse*/"BRASIL",;
			/*F - Customer*/AllTrim(SQL->D2_CLIENTE),;
			/*G - Customer Name*/SubStr(SQL->A1_NOME,1,40),;
			/*H - Salesperson*/SQL->C5_P_SALES,;
			/*I - Enduse*/SQL->C5_P_ENDUS,;
			/*J - Territory*/"BRASIL",;
			/*K - Item*/SQL->D2_COD,;
			/*L - Freight_Carrier*/SubStr(SQL->A4_NOME,1,40),;
			/*M - Project_Ship_To*/SQL->C5_P_SPF,;
			/*N - Gross_Amt_BRL*/Transform(SQL->D2_VALBRUT,"@R 999999999999.99" ),;
			/*O - Gross_Weight*/Transform(((SQL->F2_PBRUTO/SQL->F2_PLIQUI)*(SQL->D2_QUANT * SQL->B1_PESO)),"@R 9999999.9999" ),;
			/*P - Net_Amt_BRL*/Transform(SQL->D2_TOTAL - SQL->D2_VALICM - SQL->D2_VALIPI - SQL->D2_VALCOF - SQL->D2_VALPIS - SQL->D2_ICMSRET,"@R 999999999999.99"),;//Transform(((SQL->D2_TOTAL - SQL->D2_VALICM - SQL->D2_VALIPI - SQL->D2_VALCOF - SQL->D2_VALPIS - SQL->D2_ICMSRET) / SQL->M2_MOEDA2),"@R 999999999999.99" ),;
			/*Q - Net_Credit_Amt*/"0",; //Transform(SQL->D2_TOTAL,"@E 999999999999.99" ),;
			/*R - Net_Return_Amt_BR*/ Transform(SQL->D1_TOTAL - SQL->D1_VALPIS - SQL->D1_ICMSRET - SQL->D1_VALCOF  - SQL->D1_VALICM - SQL->D1_VALIPI,"@R 999999999999.99"),;//Transform(((SQL->D1_TOTAL - SQL->D1_VALPIS - SQL->D1_ICMSRET - SQL->D1_VALCOF  - SQL->D1_VALICM - SQL->D1_VALIPI) / SQL->M2_MOEDA2),"@R 999999999999.99" ),;
			/*S - Gross_Return_Amt_BR*/ Transform(SQL->D1_TOTAL+SQL->D1_VALIPI+SQL->D1_ICMSRET,"@R 999999999999.99"),; // TLM 20150610 - total por item SD1 e não por capa SF1 //JSS ALTEROU //Transform(SQL->D1_TOTAL+SQL->D1_VALIPI+SQL->D1_ICMSRET,"@R 999999999999.99"),;//Transform(((SQL->D1_TOTAL - SQL->D1_VALPIS - SQL->D1_ICMSRET - SQL->D1_VALCOF  - SQL->D1_VALICM - SQL->D1_VALIPI) / SQL->M2_MOEDA2),"@R 999999999999.99" ),;
			/*T - Net_Weight*/Transform(SQL->D2_QUANT * SQL->B1_PESO,"@R 999999999999.99" ),;
			/*U - Net_Units*/Transform(SQL->D2_QUANT,"@R 999999999.99" ),;
			/*V - Return_Units*/Transform(SQL->D1_QUANT,"@R 999999999.99" ),;
			/*W - Credit_Units*/"0",;//Transform(SQL->D2_QUANT,"@E 999999999.99" ),;
			/*X - AIC_Cost*/Iif( SQL->CUSTOD1 <= 0,Transform(SQL->CUSTOD2,"@R 999999999999.99" ),Transform(-1*SQL->CUSTOD1,"@R 999999999999.99" )),;
			/*Y - Order_Country*/"BRASIL",;
			/*Z- Invoice_Number*/StrZero(VAL(SQL->INVOICE),9),;//StrZero(VAL(SQL->INVOICE),9)+StrZero(VAL(SQL->SERIE),3),;
			/*AA- PO_Number*/SQL->C5_OBRA,;
			/*AB- Invoice_State*/SQL->A1_EST,;
			/*AC- Invoice_State*/Iif(AllTrim(SQL->D2_CLIENTE)$'000002/000021',"Y","N")})//AOA - 02/08/2016 - Inclusão da coluna intercompany 
			
			/*AB - AIC_Cost*/ //Iif( SQL->CUSTOD1 >= 0,Transform(SQL->CUSTOD2,"@R 999999999999.99" ),Transform(SQL->CUSTOD1,"@R 999999999999.99" )),;
			///*AA- PO_Number*/SQL->C6_PEDCLI,;   // TLM 20150819 - Solicitação email Hugo e Daniel
		EndIf
		SQL->(DbSkip())
	EndDo
	//Ativa Excel
	oExcel:Activate()
EndIf

If lJob
	//Criação do Arquivo
	nHdl := FCREATE(cDest+cArq,FC_NORMAL )
	If nHdl > 0
		nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
		FCLOSE(nHdl) // Fecha o Arquivo que foi Gerado
	Else
		Conout("Arquivo não foi criado! Erro:"+ Alltrim(STR(FERROR())))
		Return
	EndIf
Else
	oExcel:GetXMLFile(cDest+cArq) // Gera o arquivo em Excel
EndIf

//Tratamento para Job
If lJob
	//Envio do Arquivo para o FTP
	lEnvFtp:= ManuArqFTP(cDest+cArq)
	If lEnvFtp
		conout("Arquivo enviado para o FTP Victaulic: "+cArq )
	Else
		conout("Arquivo não foi enviado para o FTP Victaulic: "+cArq )
	EndIf
Else
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel
EndIf
oExcel:DeActivate()

Return

/*
Funcao      : ManuArqFTP()  
Parametros  : cArq
Retorno     : lRet
Objetivos   : Função responsavel por manipular os arquivos no FTP.
Autor       : Renato Rezende
Data/Hora   : 05/01/2017
*/
*--------------------------------------------*
Static Function ManuArqFTP(cArqServ)
*--------------------------------------------*
Local i				:= 0
Local lConnect		:= .F.
Local aArqs			:= {}
Local lRet			:= .F.

//Conexao com o FTP informado nos paramentros.
For i:=1 to 3// Tenta 3 vezes.
	lConnect := FTPConnect(cPath,,cLogin,cPass)
	If lConnect
 		i:=3
   	EndIf
Next
If !lConnect
	Conout("TMFAT002 - Não foi possivel estabelecer conexão com FTP!")		
 	lRet:= .F.
Else
	aArqs := Directory(cArqServ)
	For i:=1 to Len(aArqs)
		//Enviando para o FTP
		lRet:= FTPUpLoad(cDest+Alltrim(aArqs[i][1]),Alltrim(aArqs[i][1]))
		//Copiando arquivo para a pasta de enviados
		__CopyFile(cDest+Alltrim(aArqs[i][1]),cDest+"processados\"+Alltrim(aArqs[i][1]))
		//Excluindo arquivo da pasta principal
		FERASE(cDest+alltrim(aArqs[i][1]))
	Next i
EndIf

//Encerra conexão com FTP
FTPDisconnect()

Return lRet
