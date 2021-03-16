#include "protheus.ch"
#include "SHELL.CH"
#include "topconn.ch"

/*
Funcao      : GTIS001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gera relatório de acumulados por item contábil(Cash Flows)
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 10/04/2012    11:08
Módulo      : Contabilidade Gerencial
*/

/*
Funcao      : GTIS001()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da da tela com barra de processamento, chamando a rotina principal
Autor       : Matheus Massarotto
Data/Hora   : 10/04/2012
*/

User function GTIS001
Private oDlg

//******************Régua de processamento*******************
                                           //retira o botão X
  DEFINE DIALOG oDlg TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
                                          
    // Montagem da régua
    nMeter := 0
    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},150,oDlg,150,14,,.T.)
    
  ACTIVATE DIALOG oDlg CENTERED ON INIT(GeraArq(oMeter,oDlg))
  
//*************************************
Return

/*
Funcao      : GeraArq()
Parametros  : oMeter,oDlg
Retorno     : Nil
Objetivos   : Execução da rotina principal
Autor       : Matheus Massarotto
Data/Hora   : 10/04/2012
*/

Static Function GeraArq(oMeter,oDlg)

Private cHtml:=""
Private cDest :=  GetTempPath()
Private cQry:=""
Private cQryPrinc:=""

Private nCol1:=0
Private lCol1Ent:=.F.
Private cHtmlAux:=""

Private nCol2:=0
Private cHtmlAux2:=""

Private nCol3:=0
Private cHtmlAux3:="" 
             
Private nCol4:=0
Private cHtmlAux4:=""

Private cPerg:="GTIS001"
	
	//Monta a pergunta
	U_PUTSX1( cPerg, "01", "Data De:"	, "Data De:"	, "Data De:"	, "", "D",08,00,00,"G","" , "","","","MV_PAR01")
	U_PUTSX1( cPerg, "02", "Data Ate:", "Data Ate:"	, "Data Ate:"	, "", "D",08,00,00,"G","" , "","","","MV_PAR02")
	U_PUTSX1( cPerg, "03", "Tipo: "	, "Tipo: "		, "Tipo: "		, "", "N",01,00,00,"C","" , "","","","MV_PAR03","Movimento","","","","Saldo") 
	U_PUTSX1( cPerg, "04", "Moeda: "	, "Moeda: "		, "Moeda: "		, "", "N",01,00,00,"C","" , "","","","MV_PAR04","1=Moeda 1","","","","2=Moeda 4","","","3=Ambas")
		
	if !Pergunte(cPerg,.T.)
		oDlg:end()//finaliza a barra
		Return
	endif

	cQryPrinc+=" SELECT SUBSTRING(CTD_ITEM,1,3) AS ITEM FROM "+RETSQLNAME("CTD") //YH0
	cQryPrinc+=" WHERE CTD_CLASSE=2
	cQryPrinc+=" GROUP BY SUBSTRING(CTD_ITEM,1,3)
	cQryPrinc+=" ORDER BY ITEM
	
	if select("QRYPRIN")>0
		QRYPRIN->(DbCloseArea())
	endif
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQryPrinc), "QRYPRIN", .F., .F. )


	if YEAR(MV_PAR01)==0 .OR. YEAR(MV_PAR02)==0
		Alert("Data inválida!")
		oDlg:end()//finaliza a barra
		return
	endif
	
	if YEAR(MV_PAR01)<>YEAR(MV_PAR02)
		Alert("Relatório somente contempla informações de um mesmo ano!")
		oDlg:end()//finaliza a barra
		return
	endif

	//Inicia a régua
	oMeter:Set(0)

	Private cQTit:=""
	Private cQConte:=""
	Private cCabMes:=""
	Private cCab2Mes:=""
	Private cCab3Mes:=""
	Private cQTot:=""
	Private cTipo:=""
	
	//*1, Montagem das subquerys com saldo por cada mês
	for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
		cQTit+=",SALDO"+cvaltochar(nI) //montagem dos campos que serão chamados no select, referenciados a cada subquery
	    
	    cQTot+="ISNULL(SALDO"+cvaltochar(nI)+",0)+" //montagem da coluna com totais 
		
		cQConte+=" LEFT JOIN"+CRLF
		cQConte+=" ("+CRLF
/*		//--QUERY PARA COMPOR OS SALDOS POR ITEM CONTABIL DAS CONTAS CLASSE 2
		cQConte+=" SELECT CTD_ITEM,CTD_DESC01,CTD_CLASSE,( CT4_ATUDEB-CT4_ATUCRD) AS SALDO"+cvaltochar(nI)+" FROM "+RETSQLNAME("CTD")+" CTD"+CRLF
		cQConte+=" JOIN "+RETSQLNAME("CT4")+" CT4 ON CT4_FILIAL=CTD_FILIAL AND CT4_ITEM=CTD_ITEM"+CRLF
		//--SELECT PARA PEGAR A MAIOR DATA DO MES QUE TEVE LANÇAMENTO OU SEJA O ULTIMO LANÇAMENTO
		cQConte+=" AND CT4_DATA=(SELECT MAX(CT4_DATA) FROM "+RETSQLNAME("CT4")+" WHERE D_E_L_E_T_='' AND CT4_ITEM=CT4.CT4_ITEM AND SUBSTRING(CT4_DATA,1,6)='"+cvaltochar(YEAR(MV_PAR01))+STRZERO(nI,2) +"')"+CRLF
		
		cQConte+=" WHERE CTD_CLASSE='2' AND CT4_MOEDA='01' AND CT4.D_E_L_E_T_='' AND CTD.D_E_L_E_T_=''"+CRLF
		cQConte+=" )AS TRBSALDO"+cvaltochar(nI)+CRLF
*/
		//--QUERY PARA COMPOR OS SALDOS POR ITEM CONTABIL DAS CONTAS CLASSE 2
		//**Tratamento para o tipo de saldo a ser apresentado no relatório.
		if MV_PAR03==1
			cTipo:="CT4_DEBITO-CT4_CREDIT"
		else
	   		cTipo:="CT4_ATUDEB-CT4_ATUCRD"
		endif

		cQConte+=" SELECT CTD_ITEM,CTD_DESC01,CTD_CLASSE,SUM( "+cTipo+") AS SALDO"+cvaltochar(nI)+" FROM "+RETSQLNAME("CTD")+" CTD"+CRLF
		cQConte+=" JOIN "+RETSQLNAME("CT4")+" CT4 ON CT4_FILIAL=CTD_FILIAL AND CT4_ITEM=CTD_ITEM"+CRLF
		
		//**Tratamento para o tipo de saldo a ser apresentado no relatório.
		if MV_PAR03==1
			//--SELECT PARA PEGAR TODAS OS MOVIMENTOS DENTRO DO MES 
			cQConte+=" AND CT4_CONTA+CT4_DATA IN (SELECT CT4_CONTA+CT4_DATA FROM "+RETSQLNAME("CT4")+" WHERE D_E_L_E_T_='' AND CT4_ITEM=CT4.CT4_ITEM AND SUBSTRING(CT4_DATA,1,6)='"+cvaltochar(YEAR(MV_PAR01))+STRZERO(nI,2) +"')"+CRLF
		else
			//--SELECT PARA PEGAR A MAIOR DATA DO MES QUE TEVE LANÇAMENTO OU SEJA O ULTIMO LANÇAMENTO
			cQConte+=" AND CT4_CONTA+CT4_DATA IN (SELECT CT4_CONTA+MAX(CT4_DATA) FROM "+RETSQLNAME("CT4")+" WHERE D_E_L_E_T_='' AND CT4_ITEM=CT4.CT4_ITEM AND SUBSTRING(CT4_DATA,1,6)='"+cvaltochar(YEAR(MV_PAR01))+STRZERO(nI,2) +"' GROUP BY CT4_CONTA)"+CRLF			
		endif
		//cQConte+=" WHERE CTD_CLASSE='2' AND CT4_MOEDA='01' AND CT4.D_E_L_E_T_='' AND CTD.D_E_L_E_T_=''"+CRLF
		cQConte+=" WHERE CTD_CLASSE='2'"
		If MV_PAR04 <> 3 //JVR - 17/10/2012 - Tratamento para moedas, chamado 007437
			If MV_PAR04 == 1
				cQConte+=" AND CT4_MOEDA='01'"
			ElseIf MV_PAR04 == 2
				cQConte+=" AND CT4_MOEDA='04'"
			EndIf
		EndIf
		cQConte+=" AND CT4.D_E_L_E_T_='' AND CTD.D_E_L_E_T_=''"+CRLF
		
		cQConte+=" GROUP BY CTD_ITEM,CTD_DESC01,CTD_CLASSE "+CRLF
		cQConte+=" )AS TRBSALDO"+cvaltochar(nI)+CRLF
//--				
		cQConte+=" ON CTD.CTD_ITEM=TRBSALDO"+cvaltochar(nI)+".CTD_ITEM"+CRLF
	
	
	cCabMes+="<td class='bordaBcoBx'>"+CMONTH(STOD("2000"+STRZERO(nI,2)+"01"))+"</td>"
	cCab2Mes+="<td>&nbsp;</td>"
	cCab3Mes+="<td class='fonteWhite'>&nbsp;</td>"
	next
    
  	cQTot:=SUBSTR(cQTot,1,len(cQTot)-1)+" AS TOTAL"

//%%Montagem da estrutura do excel  
cHtml+=" <style type='text/css'>
cHtml+=" .bordabx{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #000000 #CCCCCC; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0,5px;
cHtml+="  border-right-width: 0,5px;
cHtml+="  border-bottom-width: 1px;
cHtml+="  border-left-width: 0,5px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .bordabxes{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #000000 #000000; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0,5px;
cHtml+="  border-right-width: 0,5px;
cHtml+="  border-bottom-width: 1px;
cHtml+="  border-left-width: 1px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }
cHtml+=" .bordaes{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #CCCCCC #000000; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0,5px;
cHtml+="  border-right-width: 0,5px;
cHtml+="  border-bottom-width: 0,5px;
cHtml+="  border-left-width: 1px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+="  color:#00F;
cHtml+=" }

cHtml+=" .bordaes2{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #CCCCCC #000000; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0,5px;
cHtml+="  border-right-width: 0,5px;
cHtml+="  border-bottom-width: 0,5px;
cHtml+="  border-left-width: 1px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+="  color:#00F;
cHtml+="   background:#CCC;
cHtml+=" }

cHtml+=" .bordadi{ 
cHtml+=" border-color: #CCCCCC #000000 #CCCCCC #CCCCCC; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0,5px;
cHtml+="  border-right-width: 1px;
cHtml+="  border-bottom-width: 0,5px;
cHtml+="  border-left-width: 0,5px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .bordadici{ 
cHtml+=" border-color: #000000 #000000 #CCCCCC #CCCCCC; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 1px;
cHtml+="  border-right-width: 1px;
cHtml+="  border-bottom-width: 0,5px;
cHtml+="  border-left-width: 0,5px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .bordaBco{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #000000 #000000; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0px;
cHtml+="  border-right-width: 0px;
cHtml+="  border-bottom-width: 0px;
cHtml+="  border-left-width: 0px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .bordaBcoBx{ 
cHtml+=" border-color: #CCCCCC #CCCCCC #000000 #000000; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 0px;
cHtml+="  border-right-width: 0px;
cHtml+="  border-bottom-width: 1px;
cHtml+="  border-left-width: 0px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .bordaci{ 
cHtml+=" border-color: #000000 #CCCCCC #CCCCCC #CCCCCC; 
cHtml+=" border-style: solid;
cHtml+="  border-top-width: 1px;
cHtml+="  border-right-width: 0,5px;
cHtml+="  border-bottom-width: 0,5px;
cHtml+="  border-left-width: 0,5px; 
cHtml+="  font:Calibri;
cHtml+="  font-size:12px;
cHtml+=" }

cHtml+=" .fonte{ 
cHtml+="   font:Calibri;
cHtml+="   font-size:12px;
cHtml+=" }

cHtml+=" .fonteblue{ 
cHtml+="   font:Calibri;
cHtml+="   font-size:12px;
cHtml+="   color:#00F;
cHtml+=" }

cHtml+=" .fonteblue2{ 
cHtml+="   font:Calibri;
cHtml+="   font-size:12px;
cHtml+="   color:#00F;
cHtml+="   background:#CCC;
cHtml+=" }

cHtml+=" .fonteWhite{ 
cHtml+="   font:Calibri;
cHtml+="   font-size:12px;
cHtml+="   color:#FFF;
cHtml+="   background:#000;
cHtml+=" }


cHtml+=" </style>

cHtml+=" <table width='200' border='1' cellpadding='1' bordercolor='#CCCCCC'>
cHtml+="   <tr>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'><strong>Project Actuals Template</strong></td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'><strong>Cash Flows by Month</strong></td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td bgcolor='#CCCCCC' class='bordaBco'><strong>Project Name:</strong></td>
cHtml+="     <td bgcolor='#CCCCCC' class='bordaBco'>&nbsp;</td>
cHtml+="     <td bgcolor='#CCCCCC' class='bordaBco'>&nbsp;</td>
cHtml+="     <td bgcolor='#FEFF99' class='bordaBco'>"+alltrim(SM0->M0_NOME)+"</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="     <td class='bordaBco'>&nbsp;</td>
cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordaBcoBx'>&nbsp;</td>
cHtml+="     <td class='bordaBcoBx'><strong>Account Code</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Used</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Category</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Sub-Category</strong></td>
//cHtml+="     <td class='bordabxes'><strong>Total Budget</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Total Budget</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Spent-to-<br>Date</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>Remaining<br> to Spend</strong></td>
cHtml+="     <td class='bordaBcoBx'><strong>% Complete</strong></td>
cHtml+="     <td class='bordaBcoBx'>Total</td>
cHtml+=cCabMes

cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordabx'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>

/*	
	¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    Query para processar o conteúdo da tabela
    ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
*/
//cria a variável para total de cada grupo de item contábil na linha cinza
nTotal:=0
nTotCash1:=0
nTotCash2:=0
nTotCash3:=0

//cria a variável para total de cada mês na linha cinza
for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
	&("nSaldo"+cvaltochar(nI)):=0

//Cria variáveis para total de NET CASH - Linhas pretas
	&("nCash1"+cvaltochar(nI)):=0
	&("nCash2"+cvaltochar(nI)):=0
	&("nCash3"+cvaltochar(nI)):=0
next

DbSelectArea("QRYPRIN")
QRYPRIN->(DbGoTop())

	While QRYPRIN->(!EOF())
	
	
	    //Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=10 // atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
	
		cQry:=""
	/*	//Base da estrutura que está sendo criada em cima *1, é criado um select por mês referenciando a Join
		cQry+=" SELECT CTD.CTD_ITEM,CTD.CTD_DESC01,CTD.CTD_CLASSE,SALDO FROM "+RETSQLNAME("CTD")+" CTD
		cQry+=" LEFT JOIN
		cQry+=" (
		//--QUERY PARA COMPOR OS SALDOS POR ITEM CONTABIL DAS CONTAS CLASSE 2
		cQry+=" SELECT CTD_ITEM,CTD_DESC01,CTD_CLASSE,( CT4_ATUDEB-CT4_ATUCRD) AS  SALDO FROM "+RETSQLNAME("CTD")+" CTD
		cQry+=" JOIN "+RETSQLNAME("CT4")+" CT4 ON CT4_FILIAL=CTD_FILIAL AND CT4_ITEM=CTD_ITEM
		//--SELECT PARA PEGAR A MAIOR DATA DO MES QUE TEVE LANÇAMENTO OU SEJA O ULTIMO LANÇAMENTO
		cQry+=" AND CT4_DATA=(SELECT MAX(CT4_DATA) FROM "+RETSQLNAME("CT4")+" WHERE D_E_L_E_T_='' AND CT4_ITEM=CT4.CT4_ITEM AND SUBSTRING(CT4_DATA,1,6)='201202')
		
		cQry+=" WHERE CTD_CLASSE='2' AND CT4_MOEDA='01' AND CT4.D_E_L_E_T_='' AND CTD.D_E_L_E_T_=''
		cQry+=" )AS TRBSALDO
		
		cQry+=" ON CTD.CTD_ITEM=TRBSALDO.CTD_ITEM
		cQry+=" WHERE SUBSTRING(CTD.CTD_ITEM,1,3)='"+QRYPRIN->ITEM+"'  AND CTD.D_E_L_E_T_=''
		cQry+=" ORDER BY CTD_CLASSE DESC
	*/	
	
		cQry+=" SELECT CTD.CTD_ITEM,CTD.CTD_DESC01,CTD.CTD_CLASSE"+cQTit+","+cQTot+" FROM "+RETSQLNAME("CTD")+" CTD"+CRLF
		cQry+=cQConte
		cQry+=" WHERE SUBSTRING(CTD.CTD_ITEM,1,3)='"+QRYPRIN->ITEM+"'  AND CTD.D_E_L_E_T_=''"+CRLF

		cQry+=" ORDER BY CTD_CLASSE DESC"+CRLF
		if select("TRBQRY")>0
		TRBQRY->(DbCloseArea())
		endif
		
		MemoWrite("C:/teste/testSave.txt", cQry)
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "TRBQRY", .F., .F. )
		
		DbSelectArea("TRBQRY")
		TRBQRY->(DbGoTop())
	
		While TRBQRY->(!EOF())
	
	    //Montagem da primeira estrutura do arquivo - OPERATING PROPERTIES
		if SUBSTR(alltrim(TRBQRY->CTD_ITEM),1,2)<'11'
		    
			if TRBQRY->CTD_CLASSE=='2'
				cHtmlAux+="   <tr>
			else
				cHtmlAux+="   <tr>
			endif
			
			if SUBSTR(alltrim(TRBQRY->CTD_ITEM),1,2)=='10'
				nCol1:=nCol1+1
			else
				cHtmlAux+="     <td>&nbsp;</td>
			endif
			
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_ITEM+"</td>
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_DESC01+"</td>
	
			cHtmlAux+="     <td bgcolor='#FEFF99' class='bordaes"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>	
	
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			//**tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza
			if TRBQRY->CTD_CLASSE=='2'
				nTotal+=TRBQRY->TOTAL
				cHtmlAux+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
			else
				cHtmlAux+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(nTotal,"@E 999,999,999.99")+"</td>
				nTotCash1+=nTotal
				nTotal:=0
			endif
							
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					if TRBQRY->CTD_CLASSE=='2'
						&("nSaldo"+cvaltochar(nI))+=&("TRBQRY->SALDO"+cvaltochar(nI))
						cHtmlAux+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
					else
						cHtmlAux+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("nSaldo"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
							&("nCash1"+cvaltochar(nI))+=&("nSaldo"+cvaltochar(nI))
							&("nSaldo"+cvaltochar(nI)):=0
					endif
					
	    		next
	    	//**fim tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza
			cHtmlAux+="   </tr>
	
			if TRBQRY->CTD_CLASSE=='1'
				cHtmlAux+="   <tr>
				
				if !SUBSTR(alltrim(TRBQRY->CTD_ITEM),1,2)=='10'
					cHtmlAux+="     <td>&nbsp;</td>
				else
					nCol1:=nCol1+1
				endif			
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td class='bordaes'>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+="     <td>&nbsp;</td>
				cHtmlAux+=cCab2Mes
				cHtmlAux+="   </tr>		
			endif
	    //Montagem da segunda estrutura do arquivo - DEVELOPMENT PROPERTIES
		elseif SUBSTR(alltrim(TRBQRY->CTD_ITEM),1,2)<'40' 
	 
		
			if TRBQRY->CTD_CLASSE=='2'
				cHtmlAux2+="   <tr>
			else
				cHtmlAux2+="   <tr>
			endif
	
				nCol2:=nCol2+1
			
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_ITEM+"</td>
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_DESC01+"</td>
			cHtmlAux2+="     <td bgcolor='#FEFF99' class='bordaes"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
	
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux2+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
/*			cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
	    		next 
*/			//**tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza
			if TRBQRY->CTD_CLASSE=='2'
				nTotal+=TRBQRY->TOTAL
				cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
			else
				cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(nTotal,"@E 999,999,999.99")+"</td>
				nTotCash2+=nTotal
				nTotal:=0
			endif
							
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					if TRBQRY->CTD_CLASSE=='2'
						&("nSaldo"+cvaltochar(nI))+=&("TRBQRY->SALDO"+cvaltochar(nI))
						cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
					else
						cHtmlAux2+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("nSaldo"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
							&("nCash2"+cvaltochar(nI))+=&("nSaldo"+cvaltochar(nI))
							&("nSaldo"+cvaltochar(nI)):=0
					endif
					
	    		next
	    	//**fim tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza	
			cHtmlAux2+="   </tr>
	
			if TRBQRY->CTD_CLASSE=='1'
				cHtmlAux2+="   <tr>
				
				nCol2:=nCol2+1
	
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td class='bordaes'>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+="     <td>&nbsp;</td>
				cHtmlAux2+=cCab2Mes
				cHtmlAux2+="   </tr>		
			endif	
		//Montagem da terceira estrutura do arquivo - FINANCING
		elseif SUBSTR(alltrim(TRBQRY->CTD_ITEM),1,2)<'50' 
	 
		
			if TRBQRY->CTD_CLASSE=='2'
				cHtmlAux3+="   <tr>
			else
				cHtmlAux3+="   <tr>
			endif
	
			nCol3:=nCol3+1
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_ITEM+"</td>
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_DESC01+"</td>
			cHtmlAux3+="     <td bgcolor='#FEFF99' class='bordaes"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
	
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux3+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
/*			cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
	    		next 
*/			//**tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza
			if TRBQRY->CTD_CLASSE=='2'
				nTotal+=TRBQRY->TOTAL
				cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
			else
				cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(nTotal,"@E 999,999,999.99")+"</td>
				nTotCash3+=nTotal
				nTotal:=0
			endif
							
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					if TRBQRY->CTD_CLASSE=='2'
						&("nSaldo"+cvaltochar(nI))+=&("TRBQRY->SALDO"+cvaltochar(nI))
						cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
					else
						cHtmlAux3+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("nSaldo"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
							&("nCash3"+cvaltochar(nI))+=&("nSaldo"+cvaltochar(nI))
							&("nSaldo"+cvaltochar(nI)):=0
					endif
					
	    		next
	    	//**fim tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza	
			cHtmlAux3+="   </tr>
	
			if TRBQRY->CTD_CLASSE=='1'
				cHtmlAux3+="   <tr>
				
				nCol3:=nCol3+1
				
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td class='bordaes'>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+="     <td>&nbsp;</td>
				cHtmlAux3+=cCab2Mes			
				cHtmlAux3+="   </tr>		
			endif		
		//Montagem do restante que não pertence a um grupo
		else
		
			if TRBQRY->CTD_CLASSE=='2'
				cHtmlAux4+="   <tr>
			else
				cHtmlAux4+="   <tr>
			endif
	
				nCol4:=nCol4+1
			
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_ITEM+"</td>
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRBQRY->CTD_DESC01+"</td>
			cHtmlAux4+="     <td bgcolor='#FEFF99' class='bordaes"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
	
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
			cHtmlAux4+="     <td class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>&nbsp;</td>
/*			cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
	    		next 
*/			//**tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza
			if TRBQRY->CTD_CLASSE=='2'
				nTotal+=TRBQRY->TOTAL
				cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(TRBQRY->TOTAL,"@E 999,999,999.99")+"</td>
			else
				cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(nTotal,"@E 999,999,999.99")+"</td>
				nTotal:=0
			endif
							
				for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
					if TRBQRY->CTD_CLASSE=='2'
						&("nSaldo"+cvaltochar(nI))+=&("TRBQRY->SALDO"+cvaltochar(nI))
						cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("TRBQRY->SALDO"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
					else
						cHtmlAux4+="     <td bgcolor='#FEFF99' class='fonteblue"+IIF(TRBQRY->CTD_CLASSE=='1',"2","")+"'>"+TRANSFORM(&("nSaldo"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>
						&("nSaldo"+cvaltochar(nI)):=0
					endif
					
	    		next
	    	//**fim tratamento para o total de cada grupo de item contábil quando classe == 1 na linha cinza	
			cHtmlAux4+="   </tr>
	
			if TRBQRY->CTD_CLASSE=='1'
				cHtmlAux4+="   <tr>
				
				nCol4:=nCol4+1
	
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td class='bordaes'>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+="     <td>&nbsp;</td>
				cHtmlAux4+=cCab2Mes			
				cHtmlAux4+="   </tr>		
			endif			
			
		endif
		TRBQRY->(DbSkip())
		enddo
	
	QRYPRIN->(DbSkip())
	enddo

//%% continuação da montagem da estrutura do excel 
cHtml+="   <tr>
cHtml+="     <td bgcolor='#C2D699' rowspan='"+cvaltochar(nCol1+2)+"' class='bordadi'><pre>O<br>P<br>E<br>R<br>A<br>T<br>I<br>N<br>G<br><br>P<br>R<br>O<br>P<br>E<br>R<br>T<br>I<br>E<br>S<br></pre></td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>

cHtml+=cHtmlAux

cHtml+="   <tr>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>NET CASH FLOW FROM OPERATIONS</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>"+IIF(empty(nTotCash1),"&nbsp;",TRANSFORM(nTotCash1,"@E 999,999,999.99"))+"</td>
//cHtml+=cCab3Mes
	//Montagem do NET CASH por mês
	for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
		if empty(&("nCash1"+cvaltochar(nI)))
			cHtml+="	<td class='fonteWhite'>&nbsp;</td>"
		else
			cHtml+="	<td class='fonteWhite'>"+TRANSFORM(&("nCash1"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>"
		endif
    next
    
cHtml+="   </tr>

cHtml+="   <tr>
cHtml+="     <td class='bordaci'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>


cHtml+="   <tr>
cHtml+="     <td bgcolor='#BACCE0' rowspan='"+cvaltochar(nCol2+2)+"' class='bordadici'><pre>D<BR>E<BR>V<BR>E<BR>L<BR>O<BR>P<BR>M<BR>E<BR>N<BR>T<BR><BR>P<BR>R<BR>O<BR>P<BR>E<BR>R<BR>T<BR>I<BR>E<BR>S<BR></pre></td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>

cHtml+=cHtmlAux2

cHtml+="   <tr>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>NET CASH FLOW FROM OPERATIONS</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>"+IIF(empty(nTotCash2),"&nbsp;",TRANSFORM(nTotCash2,"@E 999,999,999.99"))+"</td>
//cHtml+=cCab3Mes
	//Montagem do NET CASH por mês
	for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
		if empty(&("nCash2"+cvaltochar(nI)))
			cHtml+="	<td class='fonteWhite'>&nbsp;</td>"
		else
			cHtml+="	<td class='fonteWhite'>"+TRANSFORM(&("nCash2"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>"
		endif
    next
cHtml+="   </tr>

/*cHtml+="   <tr>
cHtml+="     <td class='bordaci'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>*/


cHtml+="   <tr>
//RRP - 29/03/2016 - Chamado 032766. 
//cHtml+="     <td bgcolor='#F9C093' rowspan='"+cvaltochar(IIF((nCol3+2)<10,10,nCol3+2))+"' class='bordadici'><pre>F<br>I<br>N<br>A<br>N<br>C<br>I<br>N<br>G</pre></td>
cHtml+="     <td bgcolor='#F9C093' rowspan='"+cvaltochar(IIF((nCol3+2)<8,8,nCol3+2))+"' class='bordadici'><pre>F<br>I<br>N<br>A<br>N<br>C</pre></td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>

for nU:=nCol3+2 to 7//9
	cHtml+="   <tr>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td class='bordaes'>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+="     <td>&nbsp;</td>
	cHtml+=cCab2Mes
	cHtml+="   </tr>
next

cHtml+=cHtmlAux3

cHtml+="   <tr>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>NET CASH FLOW FROM OPERATIONS</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>&nbsp;</td>
cHtml+="     <td class='fonteWhite'>"+IIF(empty(nTotCash3),"&nbsp;",TRANSFORM(nTotCash3,"@E 999,999,999.99"))+"</td>
//cHtml+=cCab3Mes
	//Montagem do NET CASH por mês
	for nI:=MONTH(MV_PAR01) to MONTH(MV_PAR02)
		if empty(&("nCash3"+cvaltochar(nI)))
			cHtml+="	<td class='fonteWhite'>&nbsp;</td>"
		else
			cHtml+="	<td class='fonteWhite'>"+TRANSFORM(&("nCash3"+cvaltochar(nI)),"@E 999,999,999.99")+"</td>"
		endif
    next
cHtml+="   </tr>

/*Html+="   <tr>
cHtml+="     <td class='bordaci'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>*/

cHtml+="   <tr>
cHtml+="     <td rowspan='"+cvaltochar(nCol4+1)+"' class='bordaci'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td class='bordaes'>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+="     <td>&nbsp;</td>
cHtml+=cCab2Mes
cHtml+="   </tr>

cHtml+=cHtmlAux4

cHtml+=" </table>

/***********************GERANDO EXCEL************************************/
	oDlg:end()//finaliza a barra
	cArq := alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          
         
Return
