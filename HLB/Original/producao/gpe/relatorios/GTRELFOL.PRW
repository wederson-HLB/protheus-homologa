#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "ap5mail.ch"
#INCLUDE "SHELL.CH"
#include "APWEBEX.CH"
/*
+-----------------------------------------------------------------------------
| Função | GTGRFOL()  | Autor | Ana Carolina Gabriel  	|  Data  | 24/01/2011|
+----------------------------------------------------------------------------+
| Descrição |  Gera um relatorio de folha de pagamento, com todas as verbas  |
|			|  e totais com data do periodo atual							 |
+----------------------------------------------------------------------------+
| Uso		|		 Geração de Relatorio                                    |
+----------------------------------------------------------------------------+
Funcao      : GTRELFOL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera um relatorio de folha de pagamento, com todas as verbas e totais com data do periodo atual
Autor     	: Ana Carolina Gabriel  	 	
Data     	: 24/01/2011
Obs         : Geração de Relatorio
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Gestão Pessoal.
Cliente     : Todos.
*/
*----------------------*
User Function GTRELFOL()
*----------------------*
Processa({|| Main()})
Return

*--------------------*
Static Function Main()
*--------------------*
Local cTipo	:= ""
Local cEmp	:= cEmpAnt
Local cHtml	:= ""

Local nValor:= 0
Local nDissi:= 0
Local nDfgts:= 0
Local nInss	:= 0
Local aDissi:= 0 

Local aArea	:= {}

cQry	:= ''
cAlias	:= 'TRT'
aVerba	:=	{}
aTRT := {}
aSRVxIdent := GetCodSRV()//Codigo Verba X codigo identificador de calculo.
aMatxProLab := {}
aTotais:= {}
ncont:= 0
nSalario:=0  
nSalarioB:=0
z:=1

nTot:= 0
nTotProv:= 0
nTotDesc:= 0
aTotTot:={}   

nTotTotP:=0
nTotTotD:=0
nTotTotT:=  0    
NINSSS :=0 
nIRFERIAS:=0 
nIr:= 0
NINSSSF:= 0 
NIRSF:= 0   
NINSDT:= 0  

Private aBaseFGTS		:={}
Private aBaseFGTSINSS	:={}

Private cDest		:= ""
Private cArq		:= ""
Private nBytesSalvo	:= 0
Private cPerg 		:= "PAYROLL"

//======================================================== PAYROLL PAYROLL FOR THE MONTH ========================================================
// Inclusão das perguntas no SX1
//RRP - 16/11/2015 - Inclusão ou Ajuste nos Perguntes.
AjustaSX1()

//	Se a Operação for Abortada.
If !Pergunte(cPerg,.T.)
	Return()
EndIf

nTime := VAL(STRTRAN(TIME(),":",""))
cMsg := "Inicio: "+Time()+CHR(10)+CHR(13)

cTipo		:= MV_PAR01 //Extensão de Arquivo Gerado
lZerado 	:= MV_PAR02 == 1
lFolha		:= MV_PAR03 == 1
lAdiant 	:= MV_PAR03 == 2
lAdiant13	:= MV_PAR03 == 3
lDecTer		:= MV_PAR03 == 4 
cDtPay		:= DTOS(MV_PAR04)
lSRC		:= EMPTY(cDtPay) .or. SUBSTR(cDtPay,1,6) == GETMV("MV_FOLMES") 
lSRI		:= lDecTer .and. SUBSTR(cDtPay,1,4) == LEFT(GETMV("MV_FOLMES"),4)

//RSB - 18/01/2017 - Tratamento para evitar error log , Chamado: 038698
If (lDecTer) .and. (!lSRI)
	MsgAlert("O período informado difere do período atual da folha.","HLB BRASIL")
	Return .F.
Endif 

If lDecTer //Folha.13o
	cDtPay	:= SUBSTR(DTOS(MV_PAR04),1,4)+"13"
	cDtSal	:= SUBSTR(DTOS(MV_PAR04),1,6)
	lSRC	:= .F.  //10/12/2015 - JSS - Impressão Payroll folha 13o. Chamado 031025.
EndIf

// Verificando qual será o formato do arquivo gerado
cDest	:=  GetTempPath()
If cValtochar(cTIPO) == '1'
	If FILE (cDest+"payroll.html")
		If FERASE(cDest+"payroll.html") <> 0
			MsgInfo("Não foi possivel sobrescrever o arquivo anterior.","HLB BRASIL")
			Return .F.
		EndIf
	endif
	cArq	:= "payroll.html"
ElseIf cValtochar(cTIPO) == '2' .OR. cValtochar(cTIPO) == '3'
	If FILE (cDest+"payroll.xls")
		If FERASE(cDest+"payroll.xls") <> 0
			MsgInfo("Não foi possivel sobrescrever o arquivo anterior.","HLB BRASIL")
			Return .F.
		EndIf
	EndIf
	cArq	:= "payroll.xls"
EndIf 

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TRT')>0
	TRT->(DBCLOSEAREA())
EndIf
If Select('TRV')>0
	TRV->(DBCLOSEAREA())
EndIf
If Select('TRB')>0
	TRB->(DBCLOSEAREA())
EndIf

//RSB - 06/06/2017 - 042126 -  O relatório esta calculando com as informações da filial 01 foi adicionado para calcular de acordo com a filial logada. 
//======================================================== Valores de Encargos de Empresas ========================================================   
////-----  Percorre parametros para valores dos calculos - Parametro 14, ENCARGOS DA EMPRESA
cQryTRV:= "SELECT * FROM "+RETSQLNAME("SRX")  + CRLF
cQryTRV +=   "WHERE RX_TIP = '14' AND LEFT(RX_COD,2) = RIGHT('0"+ FWCodFil() +"',2) AND D_E_L_E_T_ <> '*' "  + CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQryTRV),'TRV',.F.,.T.)  //execução da query

//Percorre a tabela temporaria onde estão indicados os valores dos encargos   para a  separação da sring por valores especificados
dbselectarea('TRV') 
TRV->(dbgotop())
cEncargos:=TRV->RX_TXT  

// %  Empresa
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos :=  val(cEncargos1)  /100

cEncargos :=  stuff(ltrim(cEncargos), 1, nPOS,' ')

//% Terceiros
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos +=  val(cEncargos1)  /100

cEncargos :=  stuff(ltrim(cEncargos), 1, nPOS,' ')

//% Acid.Trab.
nPOS:= AT(" ", ltrim(cEncargos) ) 
cEncargos1 :=  substr(ltrim(cEncargos), 1, nPOS) 
nEncargos +=  val(cEncargos1)  /100

//Verifica as Verbas MARCADAS COMO =  .T. 
cQuery := "SELECT RV_COD ,RV_PAYROLL ,RV_TIPOCOD, RV_DPAYROL, RV_DESC FROM "+RETSQLNAME("SRV")
cQuery += "	WHERE RV_PAYROLL = 'T' 
cQuery += "		AND D_E_L_E_T_ <> '*'
If lAdiant 
	cQuery+= "		AND (RV_CODFOL = '"+STRZERO(6 ,TAMSX3("RV_CODFOL")[1])+"' OR RV_CODFOL = '"+STRZERO(7 ,TAMSX3("RV_CODFOL")[1])+"')
//RRP - 16/11/2015 - Impressão Payroll Adiantamento 13o. Chamado 030616.
ElseIf lAdiant13 
	cQuery+= "		AND (RV_CODFOL = '"+STRZERO(22 ,TAMSX3("RV_CODFOL")[1])+"' OR RV_CODFOL = '"+STRZERO(108 ,TAMSX3("RV_CODFOL")[1])+"' OR "
	cQuery+= "			 RV_CODFOL = '"+STRZERO(109 ,TAMSX3("RV_CODFOL")[1])+"') "

//10/12/2015 - JSS - Impressão Payroll folha 13o. Chamado 031025.
ElseIf lDecTer
   	cQuery+= "		AND (RV_CODFOL = '"+STRZERO(109 ,TAMSX3("RV_CODFOL")[1])+"' OR RV_CODFOL = '"+STRZERO(149,TAMSX3("RV_CODFOL")[1])+"' OR
	cQuery+= "			 RV_CODFOL = '"+STRZERO(150 ,TAMSX3("RV_CODFOL")[1])+"' OR RV_CODFOL = '"+STRZERO(148,TAMSX3("RV_CODFOL")[1])+"' OR
	cQuery+= "			 RV_REF13 = 'S') 	
	If !lZerado
		cQuery+= "		AND ((Select COUNT(*) FROM "+RETSQLNAME("SRI")+" WHERE RI_FILIAL = '"+xFilial("SRI")+"' AND RI_PD = RV_COD) <> 0 )
	EndIf
Else
	If !lZerado
		If lSRC //Mês
			cQuery+= "		AND ((Select COUNT(*) FROM "+RETSQLNAME("SRC")+" WHERE RC_FILIAL = '"+xFilial("SRC")+"' AND RC_PD = RV_COD) <> 0		
		Else//Histórico
			cQuery+= "		AND ((Select COUNT(*) FROM "+RETSQLNAME("SRD")+" WHERE RD_FILIAL = '"+xFilial("SRD")+"' AND
			cQuery+= "		RD_PD = RV_COD AND RD_DATARQ = '"+SUBSTR(cDtPay,1,6)+"') <> 0
		EndIf
		cQuery+= "				OR RV_COD in(	'"+GetCOD('B00')+"','001',
		cQuery+= "								'"+GetCOD('B25')+"','"+GetCOD('B35')+"',
		cQuery+= "								'"+GetCOD('B40')+"','"+GetCOD('B45')+"',
		cQuery+= "								'"+GetCOD('B50')+"','"+GetCOD('B55')+"'  ))
	EndIf
EndIf
	cQuery+= "	ORDER BY RV_TIPOCOD,RV_COD
dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TRT',.F.,.T.)  //execução da query

//Só gerar a barra de progresso
ProcRegua(TRT->(RecCount()))
IncProc()

//Chave SRC, SRD ou SRI
Do Case
	Case lSRC
		cCpoVal := "RC.RC_VALOR"  
	Case lSRI//10/12/2015 - JSS - Impressão Payroll folha 13o. Chamado 031025.
		cCpoVal := "RI.RI_VALOR" 
	OtherWise
		cCpoVal := "RD.RD_VALOR"	
EndCase

// Separa por Empregado as verbas indicadas em TRT(TABELA TEMPORARIA DE Verbas MARCADAS COMO =  .T. ) 
cQry += " SELECT RA.RA_MAT AS ID ,RA.RA_NOME AS EMPLOYEE ,RA.RA_CC AS CC,CT.CTT_DESC01 AS DEPARTAMENTO ,
cQry += " 		RA.RA_ADMISSA AS HIRING_DATE, RA.RA_MAT" +CRLF
While TRT->(!eof())
  	If TRT->RV_COD <> GetCOD('B00')
  		If !EMPTY( ALLTRIM(TRT->RV_DPAYROL))
			cQry += " ,MAX(CASE WHEN RV.RV_COD = '"+ TRT->RV_COD +"' THEN "+cCpoVal+" ELSE 0 END) AS 'C"+TRT->RV_COD+"' " +CRLF
    		If TRT->RV_COD <> '001' .AND. TRT->RV_COD <> GetCOD('B00')
				//Adiciona as Colunas Dentro de um Array //JSS - Adicionaod tratamento para verbas com descrição em branco.
				AADD(aTRT, {TRT->RV_COD +"-"+iif(!EMPTY(ALLTRIM(TRT->RV_DPAYROL)),ALLTRIM(TRT->RV_DPAYROL),ALLTRIM(TRT->RV_DESC)),;
							 TRT->RV_COD ,;
							  TRT->RV_TIPOCOD }  )
			EndIf
		EndIf
	EndIf
	TRT->(DBSKIP())
EndDo
If lfolha
	cQry += " ,MAX(CASE WHEN RV.RV_COD = '001' THEN "+cCpoVal+" ELSE 0 END) AS 'SALARIO_BASE'  "   +CRLF
	cQry += " ,MAX(CASE WHEN RV.RV_COD = '"+GetCOD('B00')+"' THEN "+cCpoVal+" ELSE 0 END) AS 'SALARIO_B'  "  +CRLF	
Else
	cQry += " ,MAX(CASE WHEN RV.RV_COD = '"+GetCOD('B00')+"' THEN "+cCpoVal+" ELSE RA.RA_SALARIO END) AS 'SALARIO_B'  "  +CRLF
EndIf

If lSRC
	cQry += "  FROM "+RETSQLNAME("SRC")+" AS RC		"+CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRV")+" AS RV ON RC.RC_PD = RV.RV_COD		" +CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRA")+" AS RA ON RA.RA_MAT = RC.RC_MAT " +CRLF

ElseIf lSRI //10/12/2015 - JSS - Impressão Payroll folha 13o. Chamado 031025.
	cQry += "  FROM "+RETSQLNAME("SRI")+" AS RI		"+CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRV")+" AS RV ON RI.RI_PD = RV.RV_COD		" +CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRA")+" AS RA ON RA.RA_MAT = RI.RI_MAT " +CRLF
	//RRP - 26/05/2015 - O funcionário pode ter sido demitido e conter uma rescisão complementar. Chamado 026650.
	//cQry += "								AND (RA.RA_DEMISSA = '' OR SUBSTRING(RA.RA_DEMISSA,1,6) = '"+GETMV('MV_FOLMES')+"') "+CRLF

Else
	cQry += "  FROM "+RETSQLNAME("SRD")+" AS RD		"+CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRV")+" AS RV ON RD.RD_PD = RV.RV_COD		" +CRLF
	cQry += " INNER JOIN "+RETSQLNAME("SRA")+" AS RA ON RA.RA_MAT = RD.RD_MAT " +CRLF

EndIf
cQry += "								AND RA.RA_SALARIO <> 0 " +CRLF
cQry += " INNER JOIN "+RETSQLNAME("CTT")+" AS CT ON RA.RA_CC = CT.CTT_CUSTO  " +CRLF
cQry += " WHERE RV.D_E_L_E_T_ = '' AND RA.D_E_L_E_T_ = '' AND CT.D_E_L_E_T_ = ''  "+CRLF

If lSRC
	cQry += " 	AND RC.D_E_L_E_T_ = '' "+CRLF
	cQry += " 	AND RC.RC_FILIAL = '"+xFilial("SRC")+"'  "+CRLF

ElseIf lDecTer//10/12/2015 - JSS - Impressão Payroll folha 13o. Chamado 031025.
	cQry += " 	AND RI.D_E_L_E_T_ = '' "+CRLF
	cQry += "	AND RI.RI_FILIAL = '"+xFilial("SRI")+"'  "+CRLF
	cQry += "	AND Left(RI.RI_DATA,4) = '"+SUBSTR(cDtPay,1,4)+"' "+CRLF

Else
	cQry += " 	AND RD.D_E_L_E_T_ = '' "+CRLF
	cQry += "	AND RD.RD_FILIAL = '"+xFilial("SRD")+"'  "+CRLF
	cQry += "	AND RD.RD_DATARQ = '"+SUBSTR(cDtPay,1,6)+"'  "+CRLF

EndIf
cQry += " 		AND RV.RV_FILIAL = '"+xFilial("SRV")+"'  "+CRLF
cQry += " 		AND CT.CTT_FILIAL = '"+xFilial("CTT")+"' "+CRLF
cQry += " 		AND RA.RA_FILIAL = '"+xFilial("SRA")+"' "+CRLF
cQry += " GROUP BY RA.RA_MAT,RA.RA_NOME, RA.RA_SALARIO ,RA.RA_CC ,CT.CTT_DESC01 , RA.RA_ADMISSA" +CRLF
cQry += " ORDER BY RA.RA_NOME" +CRLF

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQry),'TRB',.F.,.T.)  //execução da query

//=====================================================	H T M L=====================================================
nHdl		:= FCREATE(cDest+cArq,0 )
nBytesSalvo	:= FWRITE(nHdl, cHtml )
fclose(nHdl)

cHtml:=''
cHtml+='<html>   '+CRLF
cHtml+='<head>'+CRLF
cHtml+='<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'+CRLF
cHtml+='<title>PAYROLL</title>'+CRLF
cHtml+='<style type="text/css">'+CRLF
cHtml+='<!--'+CRLF
cHtml+='.style1 {font-family: Arial, Helvetica, sans-serif}'+CRLF
cHtml+='.style3 {font-size: 16px}'+CRLF
cHtml+='.style5 {font-size: 12px}'+CRLF
cHtml+='.style6 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #FFFFFF; }'+CRLF
cHtml+='.style7 {color: #FFFFFF}'+CRLF
cHtml+='.style14 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; }'+CRLF
cHtml+='.style17 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; color: #FFFFFF; }'+CRLF
cHtml+='.style19 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }'+CRLF
cHtml+='.style2 {	color: #FF0000;	font-family: Arial, Helvetica, sans-serif;	font-weight: bold;	font-size: 14px;}'+CRLF
cHtml+='.style4 {	color: #000099;	font-family: Arial, Helvetica, sans-serif;	font-weight: bold;	font-size: 14px;}  '+CRLF
cHtml+='-->'+CRLF
cHtml+='</style>'+CRLF
cHtml+='</head>'+CRLF
cHtml+='<body>'+CRLF
cHtml+='<div>'+CRLF

//============================= Cabeçalho da tabela =============================
cHtml+='  <table border="0">'+CRLF
cHtml+=' <tr>'+CRLF
cHtml+='   <td height="36" colspan="'
nTam := 6
If SRA->(FieldPos("RA_P_CDEMP")) > 0
	nTam ++
EndIf
If lFolha .or. lDecTer
	cHtml += cValtoChar(nTam+len(aTRT)+3)	
Else
	cHtml += cValtoChar(nTam+len(aTRT)-1)
EndIf
cHtml+='" bgcolor="#bdaee1"><div align="Center" class="style1"><STRONG>'+Capital(FWEmpName(cEmp))+' - '+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")+'</STRONG></div></td>'+CRLF
cHtml+='   <td bgcolor="#bdaee1"><class="style1">'+SUBSTR(cDtPay,5,2)+'/'+LEFT(cDtPay,4)+'</td>'+CRLF
cHtml+=' </tr>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">ID</td>'+CRLF
//RRP - 20/01/2015 - Tratamento para o código do empregado. Chamado 023781. 
If SRA->(FieldPos("RA_P_CDEMP")) > 0
	cHtml+='    <td bgcolor="#451F45"><h4 class="style6">CODE EMPLOYEE</td>'+CRLF	
EndIf
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">COD.DEPART.</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">DEPARTAMENT</td>'+CRLF
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">BASE SALARY</td>'+CRLF  
cHtml+='      <td bgcolor="#451F45"><h4 class="style6">HIRING DATE</td>'+CRLF
If lFolha
	cHtml+='      <td bgcolor="#1306A6"><h4 class="style6">001-MONTH SALARY</td>'+CRLF 
EndIf

//=============================  Adicionando os nomes das verbas nos Cabeçalhos  ============================= 
For x:=1 to len(aTRT)
	Do Case
		Case aTRT[x][3] == "1"
			cHtml+='      <td bgcolor="#1306A6"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF
		Case aTRT[x][3] == "2"
			cHtml+='      <td bgcolor="#A60806"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF
		Case aTRT[x][3] == "3"
			cHtml+='      <td bgcolor="#000000"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF
		OtherWise
			cHtml+='      <td bgcolor="#451F45"><h4 class="style6">' + aTRT[x][1] + ' </td>' +CRLF	
	EndCase
Next 
If lFolha .or. lDecTer
	cHtml+='      <td bgcolor="#1306A6"><h4 class="style6">TOTAL PROVENTOS</td>'+CRLF
	cHtml+='      <td bgcolor="#A60806"><h4 class="style6">TOTAL DESCONTOS</td>'+CRLF
	cHtml+='      <td bgcolor="#451F45"><h4 class="style6">TOTAL</td>'+CRLF
EndIf
cHtml+='    </td>'+CRLF

TRB->(dbgotop())
While TRB->(!EOF())
	TRT->(dbgotop())      
	//--------      Linhas e colunas com os respectivos valores
	cHtml+='    <tr>'+CRLF
	cHtml+='   <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+ Capital(TRB->ID)	+'</td>'+CRLF
	//RRP - 20/01/2015 - Tratamento para o código do empregado. Chamado 023781. 
	If SRA->(FieldPos("RA_P_CDEMP")) > 0
		aArea:=GetArea()
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(xFilial("SRA")+TRB->RA_MAT))
			cHtml+='      <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+IIF(!Empty(SRA->RA_P_CDEMP),SRA->RA_P_CDEMP,"NOT FOUND")+'</td>'+CRLF
		Else
			cHtml+='      <td nowrap bgcolor="#F2E1F2"><span class="style14" >EMPLOYEE NOT FOUND</td>'+CRLF
		EndIf
		SRA->(DbCloseArea())
		RestArea(aArea)
	EndIf
	cHtml+='   <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+ Capital(TRB->EMPLOYEE)	+'</td>'+CRLF
	CHtml+='   <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+ Capital(TRB->CC)	 +'</td>'+CRLF
	CHtml+='   <td nowrap bgcolor="#F2E1F2"><span class="style14" >'+ Capital(TRB->DEPARTAMENTO)	 +'</td>'+CRLF
	cHtml+='   <td nowrap bgcolor="#bdaee1"><div align="right"><span class="style14">'+STRTRAN(cVALTOCHAR(TRB->SALARIO_B ),'.',',')	+'</td>'+CRLF
	cHtml+='   <td nowrap bgcolor="#F2E1F2"><div align="right"><span class="style14">'+cmonth(stod(cvaltochar(TRB->HIRING_DATE)))+' / '+;
   												cvaltochar(DAY(stod(TRB->HIRING_DATE)) )+' / '+cvaltochar(YEAR(STOD(TRB->HIRING_DATE)) )+'</td>'+CRLF

	If lfolha
		cHtml+='   <td nowrap bgcolor="#F2E1F2"><div align="right"><span class="style14"><font color="#1306A6">'+;
								STRTRAN(cVALTOCHAR(TRB->SALARIO_BASE ),'.',',')	+'</font></td>'+CRLF
	EndIf
	AADD(aTotais,{})
	ncont++

	//------------------------ Adiciona Verbas e Valores em um Array
	WHILE TRT->(!EOF())  
		If TRT->RV_COD <> '001' .AND. TRT->RV_COD <> GetCOD('B00') .AND. !EMPTY(ALLTRIM(TRT->RV_DPAYROL))
			//Busca o valor.
			nValor := 0
			If ValType(&(strtran(alltrim('C'+TRT->RV_COD)," ","_"))) <> 'c'
				If !Empty( &(strtran(alltrim('C'+TRT->RV_COD)," ","_")) )
					nValor := &(strtran(alltrim('C'+TRT->RV_COD),' ','_'))
				EndIf
    		Else
    			nValor := &(strtran(alltrim('C'+TRT->RV_COD)," ","_"))
			EndIf
			
			//Tratamento para pegar os valores das colunas especificadas por Apelidos
			AADD(aTotais[ncont],{ nValor, TRT->RV_TIPOCOD  })    
			//----- I R
			If TRT->RV_COD == GetCOD('510')//IRRF S/SALARIO
				nIR += nValor
			ElseIf TRT->RV_COD == GetCOD('521')//IRRF S/ FERIAS
				nIRFERIAS += nValor
	   	  	ElseIf TRT->RV_COD == GetCOD('515')//IRRF S/13º SAL.
				NIRSF += nValor
	   	  	ElseIf TRT->RV_COD == GetCOD('800')//DIF. IRRF S\FERIAS
				NIRSF += nValor

			//----- I N S S
			ElseIf TRT->RV_COD == GetCOD('500')//INSS
				NINSSS += nValor
			ElseIf TRT->RV_COD == GetCOD('502')//INSS S/ 13ºSAL.
				NINSDT += nValor
			ElseIf TRT->RV_COD == GetCOD('501')// INSS S/ FERIAS
				NINSSSF += nValor 
			EndIf
		EndIf
   		TRT->(DBSKIP())  
	EndDo

	//Soma do Cálculo Total - Coluna 
	If lFolha
		nSalario += TRB->SALARIO_BASE
	EndIf
	nSalarioB += TRB->SALARIO_B

	For y:=1 to len(aTRT)
		If aTRT[y][3] =='1'
	   		nTotProv += aTotais[z][y][1]
			cHtml+=' <td bgcolor="#F2E1F2"><div align="right"><span class="style14"><font color="#1306A6">' +;
					strtran( cvaltochar(aTotais[z][y][1]),'.',',') + '</font></td>'+CRLF
	    ElseIf aTRT[y][3] =='2'
	   		nTotDesc += aTotais[z][y][1]
			cHtml+=' <td bgcolor="#F2E1F2"><div align="right"><span class="style14"><font color="#A60806">' +;
					strtran( cvaltochar(aTotais[z][y][1]),'.',',') + '</font></td>'+CRLF
	   	Else
   			cHtml+=' <td bgcolor="#F2E1F2"><div align="right"><span class="style14">'+strtran( cvaltochar(aTotais[z][y][1]),'.',',')+'</td>'+CRLF
		EndIf
  	Next y
	
	If lFolha .or. lDecTer //JSS 
		If lFolha
		 	nTotProv  := TRB->SALARIO_BASE + nTotProv
		EndIf
		
		cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG><font color="#1306A6">'+;
				strtran( cValtoChar(nTotProv),'.',',') + '</font></TD>'+CRLF
		cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG><font color="#A60806">'+;
				strtran( cValtoChar(nTotDesc) ,'.',',')+ '</font></TD>'+CRLF
		nTot := nTotProv - nTotDesc  // Calculo da ultima coluna -  TOTAIS
		cHtml+='<td nowrap  bgcolor="#bdaee1"><div align="right"><span class="style14" ><STRONG>'+strtran(  cValtoChar( nTot ),'.',',') + '</TD>'+CRLF
	
		aadd(aTotTot,{nTotProv,nTotDesc,nTot})
		nTotTotP += nTotProv
		nTotTotD += nTotDesc
		nTotTotT += nTot

		If lFolha
			If aScan(	  aTRT, { |X,Y|  X[2] == GetCOD("B25") }) <> 0 .and.;
			   		aScan(aTRT, { |X,Y|  X[2] == GetCOD("B35") }) <> 0 .and.;
			   		aScan(aTRT, { |X,Y|  X[2] == GetCOD("B40") }) <> 0 .and.;
					aScan(aTRT, { |X,Y|  X[2] == GetCOD("B45") }) <> 0 .and.;
					aScan(aTRT, { |X,Y|  X[2] == GetCOD("B50") }) <> 0 .and.;
					aScan(aTRT, { |X,Y|  X[2] == GetCOD("B55") }) <> 0
				nProLab := 0
				
				If aScan(aTRT, { |X,Y|  X[2]	== GetCOD("008") })<>0   //MSM - 18/06/2015, Adicionado linha para corrigir error log, caso retorne 0(Zero) gerava erro embaixo.
					If aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("008") })][1] <> 0//Se tiver ProLabor faz outra regra na impressão do Custo empresa.
						aAdd(aMatxProLab, z)
						If aScan(aTRT, { |X,Y|  X[2] == GetCOD("B39") }) <> 0
							nProLab += aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B39") })][1]
						Else
							MsgInfo("Verbas: "+CRLF+;
									"    '"+GetCOD("B39")+" - B.INSS PRO-LABORE   ' "+CRLF+;
									" Não foram encontradas e/ou Ativadas para Payroll, favor verificar!")
				  			Return ""
						EndIf
					EndIf
		   		EndIf
		            
				aadd(aBaseFGTS, 	{aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B40") })][1]+;
									 aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B45") })][1]+;
								     aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B50") })][1]+;
								     aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B55") })][1]+;
								     nProLab})
		
				aadd(aBaseFGTSINSS, {aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B25") })][1]+;
									 aTotais[z][aScan(aTRT, { |X,Y|  X[2]	== GetCOD("B35") })][1] })				
			Else
				MsgInfo("Verbas: "+CRLF+;
						"    '"+GetCOD("B25")+" - FGTS SAL 8%         ' "+CRLF+;
						"    '"+GetCOD("B35")+" - FGTS 13             ' "+CRLF+;
						"    '"+GetCOD("B40")+" - BASE INSS SALARIO   ' "+CRLF+;
						"    '"+GetCOD("B45")+" - BASE INSS SAL. S/LIM' "+CRLF+;
						"    '"+GetCOD("B50")+" - BASE INSS 13        ' "+CRLF+;
						"    '"+GetCOD("B55")+" - BASE INSS 13  S/LIM ' "+CRLF+;
						" Não foram encontradas e/ou Ativadas para Payroll, favor verificar!")
				Return ""
			EndIf
		ElseIf lDecTer
			   aAdd(aBaseFGTS, {IIF(aScan(aTRT,{|X,Y| X[2]==GetCOD("B50")}) <> 0,aTotais[z][aScan(aTRT,{|X,Y| X[2] == GetCOD("B50")})][1],0)+;
							  	IIF(aScan(aTRT,{|X,Y| X[2]==GetCOD("B55")}) <> 0,aTotais[z][aScan(aTRT,{|X,Y| X[2] == GetCOD("B55")})][1],0)})
	
				aAdd(aBaseFGTSINSS, {IIF(aScan(aTRT,{|X,Y| X[2]==GetCOD("B35")}) <> 0,aTotais[z][aScan(aTRT,{|X,Y| X[2] == GetCOD("B35")})][1],0) })				
			EndIf		
		EndIf

	nTotProv:= 0
	nTotDesc:= 0

	z++
	cHtml+='    </tr>'+CRLF

	If Len(cHtml) >= 1000000//Proximo a 1Mega
		cHtml := Grv(cHtml)
	EndIf

	TRB->(DBSKIP())
ENDDO

//================================================= TOTAL =========================================
nTam := 4
If SRA->(FieldPos("RA_P_CDEMP")) > 0
	nTam ++
EndIf
cHtml+='<TR> <td height="36" colspan="'+ALLTRIM(STR(nTam))+'" bgcolor="#bdaee1"><div align="left" class="style1"><STRONG>TOTAL</STRONG></TD>'+CRLF   
cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(nSalarioB),'.',',')+ '</TD>'+CRLF
cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+'   '+ '</TD>'+CRLF
If lFolha
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG><font color="#1306A6">'+;
																	strtran(cvaltochar(nSalario),'.',',')+'</font></TD>'+CRLF
EndIf
For y:=1 to len(aTRT)
	cTotal := 0
	For z:=1 to len(aTotais)
		cTotal  += aTotais[z][y][1]
	Next z
	If aTRT[y][3] =='1'
		cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG><font color="#1306A6">'+;
			strtran( cvaltochar(cTotal),'.',',')+ '</font></td></TD>'+CRLF
	ElseIf aTRT[y][3] =='2'
		cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG><font color="#A60806">'+;
			strtran( cvaltochar(cTotal),'.',',')+ '</font></td></TD>'+CRLF
	ElseIf aTRT[y][3] =='3'
		cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+strtran( cvaltochar(cTotal),'.',',')+'</td></TD>'+CRLF
	Else
		cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+strtran( cvaltochar(cTotal),'.',',')+ '</td></TD>'+CRLF		
	EndIf
Next y
If lFolha .or. lDecTer //JSS
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG><font color="#1306A6">'+;
		strtran(cvaltochar(nTotTotP),'.',',')+ '</font></TD>'+CRLF 
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG><font color="#A60806">'+;
		strtran(cvaltochar(nTotTotD),'.',',')+ '</font></TD>'+CRLF
	cHtml+='<td height="36" bgcolor="#bdaee1"><div align="right" class="style1"><STRONG>'+ strtran(cvaltochar(nTotTotT),'.',',')+ '</TD>'+CRLF
EndIf
cHtml+='</tr>'+CRLF

If Len(cHtml) >= 1000000//Proximo a 1Mega
	cHtml := Grv(cHtml)
EndIf

//================================================= COMPANY COSTS OF EACH EMPLOYEE  =========================
If lFolha .or. lDecTer
	cHtml+='<tr><td>'+CRLF
	cHtml+='<P>&nbsp;</P>'+CRLF
	cHtml+='<P>&nbsp;</P>'+CRLF
	cHtml+='</tr></td>'+CRLF
	cHtml+='<tr><td height="36" colspan="3" bgcolor="#bdaee1"><div align="left" class="style1"><strong>COMPANY COSTS OF EACH EMPLOYEE</strong></td>'+CRLF
	cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
	cHtml+='      <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>'+CRLF
	cHtml+='      <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF

	i:= 1 
	nFgts :=0
	nInss :=0   

	TRB->(dbgotop())
	While TRB->(!EOF()) .and. i <= len(aTotTot)  
		cHtml+='<TR>'
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+Capital(TRB->EMPLOYEE)	+'</td>'+CRLF
		If LEN(aMatxProLab) <> 0 .and. aScan(aMatxProLab,{|x| x == i}) <> 0
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'
			cHtml+=												strtran(cValToChar(NOROUND(aBaseFGTS[i][1] * 0.2 ,2)),'.',',')	 +'</td>'+CRLF
			nInss += (aBaseFGTS[i][1] * 0.2)
		Else
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'
			cHtml+=												strtran(cValToChar(NOROUND(aBaseFGTS[i][1] * nEncargos ,2)),'.',',')	 +'</td>'+CRLF
			nInss += (aBaseFGTS[i][1] * nEncargos)
		EndIf
		cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'
		cHtml+=												strtran(cValToChar(	aBaseFGTSINSS[i][1] )			,'.',',') +'</td>'+CRLF
		cHtml+='</TR>'
		nFgts += aBaseFGTSINSS[i][1]

		i++                                           
		If Len(cHtml) >= 1000000//Proximo a 1Mega
			cHtml := Grv(cHtml)
		EndIf
		TRB->(DBSKIP())
	ENDDO
	                                                          
	cHtml+='<tr>'
	cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="left" class="style1"><strong>TOTAL </strong></td>'+CRLF
	cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="right"class="style1"><strong>'+;
		strtran(cValtoChar(NOROUND(nInss,2)),'.',',')+'</strong></td>'+CRLF
	cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="right"class="style1"><strong>'+;
		strtran(cValtoChar(NOROUND(nFgts,2)),'.',',')+'</strong></td>'+CRLF
	cHtml+='</TR>'+CRLF
	cHtml+='<td></td>'+CRLF
	cHtml+='<td></td></tr>'+CRLF
	//================================================= SOCIAL COST=================================================
	cHtml+='</tr><tr><td>'+CRLF
	cHtml+='<P>&nbsp;</P>'+CRLF
	cHtml+='<P>&nbsp;</P>'+CRLF
	cHtml+='</tr></td>'+CRLF
	cHtml+='<tr><td height="36" colspan="2" bgcolor="#CCCCCC"><div align="left" class="style1"><strong>SOCIAL COST</strong></td></tr>'+CRLF
	cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>  '+CRLF                                                             																	   
	cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'
	cHtml+=										strtran(cValtoChar(NOROUND(nInss + NINSSSF + NINSDT + NINSSS,2)),'.',',') +'</td> </tr> '+CRLF
	cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF            
	cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ strtran(cValtoChar(NOROUND(nFgts,2)),'.',',')+'</td> </tr> '+CRLF
	cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">WITHHOLDING INCOME TAX</td>'+CRLF  
	cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ strtran(cValtoChar(NIRSF+nIR+nIRFERIAS),'.',',')+'</td> </tr> '+CRLF

	cHtml := Grv(cHtml)

	//================================================= COMPANY COSTS OF EACH EMPLOYEE MANDATORY INCREASE =========================
	//RRP - 14/10/2015 - Validando se terá quadro de Dissídio. Chamado 030118. 
	If Type("TRB->CD01+TRB->CD02+TRB->CD03+TRB->CD52+TRB->C655") != "U"
		cHtml+='<tr><td>'+CRLF
		cHtml+='<P>&nbsp;</P>'+CRLF
		cHtml+='<P>&nbsp;</P>'+CRLF
		cHtml+='</tr></td>'+CRLF
		cHtml+='<tr><td height="36" colspan="3" bgcolor="#bdaee1"><div align="left" class="style1"><strong>COMPANY COSTS OF EACH EMPLOYEE MANDATORY INCREASE</strong></td>'+CRLF
		cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">EMPLOYEE</td>'+CRLF
		cHtml+='      <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>'+CRLF
		cHtml+='      <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF
	
		nDissi	:=0
		nDfgts	:=0
		nInss	:=0   
		TRB->(DbGoTop())
		While TRB->(!EOF()) 
			cHtml+='<TR>'
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'+Capital(TRB->EMPLOYEE)	+'</td>'+CRLF
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'
			cHtml+=												strtran(cValToChar(TRB->CD01+TRB->CD02+TRB->CD03),'.',',')	 +'</td>'+CRLF
			cHtml+='      <td  bgcolor="#F2E1F2" align="right" ><span class="style14" >'
			cHtml+=												strtran(cValToChar(TRB->CD52),'.',',') +'</td>'+CRLF
			cHtml+='</TR>'
	
			nDissi	+= TRB->CD01+TRB->CD02+TRB->CD03
			nDfgts	+= TRB->CD52
			nInss	+= TRB->C655 
	
			If Len(cHtml) >= 1000000//Proximo a 1Mega
				cHtml := Grv(cHtml)
			EndIf
			TRB->(DBSKIP())
		EndDo
		cHtml+='<tr>'
		cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="left" class="style1"><strong>TOTAL </strong></td>'+CRLF
		cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="right"class="style1"><strong>'+;
			strtran(cValtoChar(nDissi),'.',',')+'</strong></td>'+CRLF
		cHtml+='   <td height="36" bgcolor="#bdaee1"><div align="right"class="style1"><strong>'+;
			strtran(cValtoChar(nDfgts),'.',',')+'</strong></td>'+CRLF
		cHtml+='</TR>'+CRLF
		cHtml+='<td></td>'+CRLF
		cHtml+='<td></td></tr>'+CRLF
		//================================================= SOCIAL COST=================================================
		cHtml+='</tr><tr><td>'+CRLF
		cHtml+='<P>&nbsp;</P>'+CRLF
		cHtml+='<P>&nbsp;</P>'+CRLF
		cHtml+='</tr></td>'+CRLF
		cHtml+='<tr><td height="36" colspan="2" bgcolor="#CCCCCC"><div align="left" class="style1"><strong>SOCIAL COST</strong></td></tr>'+CRLF
		cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">SOCIAL SECURITY</td>  '+CRLF                                                             																	   
		cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'
		cHtml+=										strtran(cValtoChar(nDissi+nInss),'.',',') +'</td> </tr> '+CRLF
		cHtml+=' <tr> <td bgcolor="#451F45"><h4 class="style6">INDEMINITY FUND</td>'+CRLF            
		cHtml+='  <td bgcolor="#F2E1F2" align="right" ><h4 class="style14">'+ strtran(cValtoChar(nDfgts),'.',',')+'</td> </tr> '+CRLF
		cHtml+='  </table>'+CRLF
		cHtml+='</div>'+CRLF
		cHtml+='</body>'+CRLF
		cHtml+='</html>'+CRLF
		cHtml+=''+CRLF
	EndIf 
EndIf

cHtml := Grv(cHtml)

//RRP - 07/10/2013 - Ajuste no fonte para não causar estouro de variavel.
If nBytesSalvo <= 0
	If ferror()	== 516
		MsgStop("Erro de gravação do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl)
	If cValtochar(cTipo) == '3'
		SENDMAIL()	
	Else 
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel ou Html
	EndIf
Endif
TRV->(dbcloseAREA())
TRB->(dbcloseAREA())
TRT->(dbcloseAREA())

Return cHtml

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da variável cHtml em partes para não causar estouro de variavel
Autor     	:
Data     	:
Cliente     : Todos.
*/
*------------------------*
Static Function Grv(cHtml)
*------------------------*
Local nHdl := Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

//================================================================================================================
// 							   				Envia Email ?
//================================================================================================================
//(cPara,cMsg,cAssunto, cAnexo)
*------------------------*
Static Function SendMail()
*------------------------*
Local cArq  := "payroll.xls"
Local cDest :=  GetTempPath() 

cAnexo	 := cDest+cArq
cPara  	 := space(300)
cCCo	 := space(300)
cAssunto := space(100)
cMsg	 := ''

DEFINE MSDIALOG oDlg TITLE " Send PayRoll" FROM 000, 000  TO 350, 470 COLORS 0, 16777215 PIXEL
	@ 037, 007 SAY oParaS PROMPT "Para" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 052, 007 SAY oCCoS PROMPT "CCo" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 023, 007 SAY oAssuntoS PROMPT "Assunto" SIZE 024, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 072, 007 SAY oMsgS PROMPT "Mensagem" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 023, 033 MSGET oAssunto VAR cAssunto SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 033 MSGET oParaG VAR cPara SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 052, 033 MSGET oCCoG VAR cCCo SIZE 172, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 072, 033 GET 	oMsg VAR cMsg OF oDlg MULTILINE SIZE 171, 072 COLORS 0, 16777215 HSCROLL PIXEL
	
	@ 148, 124 BUTTON oEnviar PROMPT "Enviar" SIZE 037, 012 OF oDlg  ACTION {||U_GTFOLMAIL(cPara,cCCo,cMsg,cAssunto, cAnexo),oDlg:END()} PIXEL
	@ 148, 164 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION oDlg:END() PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

RETURN


/*
Funcao      : GetCodSRV
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Busca a Relação de Codigo da verba X Identificador de calculo.
Autor     	:
Data     	:
Cliente     : Todos.
*/
*-------------------------*
Static Function GetCodSRV()
*-------------------------*
Local aRet := {}
Local cQry := "" 
Local nPOs := 0

//COD BASE, CODFOL, CODBASE da empresa
//aAdd(aRet,{'001','   ',''})//Padrão em todas as empresas - Salario.
aAdd(aRet,{'500',STRZERO(64 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'501',STRZERO(65 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'502',STRZERO(70 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'510',STRZERO(66 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'515',STRZERO(71 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'521',STRZERO(67 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'800',STRZERO(101,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B00',STRZERO(318,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B20',STRZERO(17 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B25',STRZERO(18 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B30',STRZERO(108,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B35',STRZERO(109,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B40',STRZERO(13 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B45',STRZERO(14 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B50',STRZERO(19 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B55',STRZERO(20 ,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'008',STRZERO(217,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'B39',STRZERO(221,TAMSX3('RV_CODFOL')[1]),''}) 
aAdd(aRet,{'C83',STRZERO(183,TAMSX3('RV_CODFOL')[1]),''})
aAdd(aRet,{'C93',STRZERO(148,TAMSX3('RV_CODFOL')[1]),''}) 
aAdd(aRet,{'C94',STRZERO(150,TAMSX3('RV_CODFOL')[1]),''})

If Select('TRB')>0
	TRB->(DBCLOSEAREA())
EndIf

cQry += " Select *
cQry += " From "+RetSQLName("SRV")
cQry += " Where ( D_E_L_E_T_ <> '*'
cQry += "		AND RV_FILIAL = '"+xFilial("SRV")+"'
cQry += "		AND RV_CODFOL in (
For i:= 1 to Len(aRet)
	cQry += " '"+aRet[i][2]+"',
Next i
cQry := LEFT(cQry,Len(cQry)-1)
cQry += "						  )
cQry += "		)
cQry += "OR ( D_E_L_E_T_ <> '*' AND RV_COD = '001')

dbUseArea(.T., "TOPCONN",TCGENQRY(,,cQry),'TRB',.F.,.T.)
                    
TRB->(DBGoTop())
While TRB->(!EOF())
	If (nPos := aScan(aRet,{|x| x[2] == TRB->RV_CODFOL })) <> 0
		aRet[nPos][3] := TRB->RV_COD
	EndIf
	TRB->(DbSkip())
EndDo

TRB->(DBCLOSEAREA())

Return aRet

/*
Funcao      : GetCOD
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Função retorna a Referencia do Codigo da verba.
Autor     	:
Data     	:
Cliente     : Todos.
*/
*--------------------------*
Static Function GetCOD(cCod)
*--------------------------*
Local cRet := "???"

If (nPos:= aScan(aSRVxIdent,{|X| X[1] == cCod}) ) <> 0
	cRet := aSRVxIdent[nPos][3]
EndIf

Return cRet

/*
Funcao      : AjustaSX1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ajusta o grupo de perguntas.
Autor     	: Renato Rezende
Data     	: 16/11/2015
Cliente     : Todos.
*/
*-----------------------------*
 Static Function AjustaSX1()
*-----------------------------* 
Local nSpace	:= (LEN(SX1->X1_GRUPO))-Len(Alltrim(cPerg))
Local cPerg2	:= Alltrim(cPerg)+Space(nSpace)

// Inclusão das perguntas no SX1
U_PUTSX1(cPerg,"01","Tipo do Arquivo","Tipo do Arquivo","Tipo do Arquivo","","C",8,00,00,"C","",'',"","",;
			"MV_PAR01",'HTML','HTML','HTML','',"Excel" , "Excel ","Excel","Email" , 'Email' ,'Email',"")
U_PUTSX1(cPerg,"02","Exibe Zerado?","Exibe Zerado?","Exibe Zerado?","","C",1,00,00,"C","",'',"","",;
	  		"MV_PAR02",'Sim','Sim','Sim','',"Nao","Nao","Nao")
U_PUTSX1(cPerg,"03","Tipo Folha?","Tipo Folha?","Tipo Folha?","","C",1,00,00,"C","",'',"","",;
	   		"MV_PAR03",'Folha','Folha','Folha','',"Adiant.","Adiant.","Adiant.","Adiant.13o","Adiant.13o","Adiant.13o",;
	   		"Folha.13o","Folha.13o","Folha.13o")
U_PUTSX1( cPerg, "04", "Data ?" , "Data ?" , "Data ?" , "", "D",08,00,00,"G","" , "","","","MV_PAR04")

//Inclusão da nova opção Pag.13o
SX1->(DbSetOrder(1))
If SX1->(DbSeek(cPerg2+"03"))//MV_PAR03
	If Alltrim(SX1->X1_DEF03) <> "Adiant.13o"
		SX1->(RecLock("SX1",.F.))
			SX1->X1_DEF03	:= "Adiant.13o"
			SX1->X1_DEFSPA3	:= "Adiant.13o"
			SX1->X1_DEFENG3	:= "Adiant.13o"
			SX1->X1_DEF04	:= "Folha.13o"
			SX1->X1_DEFSPA4	:= "Folha.13o"
			SX1->X1_DEFENG4	:= "Folha.13o"
		SX1->(MsUnlock())
	EndIf
EndIf

Return Nil
